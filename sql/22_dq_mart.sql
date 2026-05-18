-- Data quality checks for mart layer
\set ON_ERROR_STOP on

-- Row counts (all must be > 0)
SELECT 'dim_company'        AS table_name, count(*) AS row_count FROM mart.dim_company
UNION ALL
SELECT 'dim_date'           AS table_name, count(*) AS row_count FROM mart.dim_date
UNION ALL
SELECT 'fct_company_period' AS table_name, count(*) AS row_count FROM mart.fct_company_period;

-- Null key checks on fact (must return 0 for all)
SELECT
    sum((cik          IS NULL)::int) AS null_cik,
    sum((end_date     IS NULL)::int) AS null_end_date,
    sum((company_fact IS NULL)::int) AS null_company_fact,
    sum((val          IS NULL)::int) AS null_val
FROM mart.fct_company_period;

-- Referential integrity: ciks in fact must exist in dim_company (must return 0)
SELECT count(*) AS orphaned_ciks
FROM mart.fct_company_period f
WHERE NOT EXISTS (
    SELECT 1 FROM mart.dim_company dc WHERE dc.cik = f.cik
);

-- Date coverage: end_dates in fact must exist in dim_date (must return 0)
SELECT count(*) AS missing_dates
FROM mart.fct_company_period f
WHERE NOT EXISTS (
    SELECT 1 FROM mart.dim_date dd WHERE dd.date_key = f.end_date
);

-- Tag coverage: all 5 expected tags must be present
SELECT company_fact, count(*) AS rows
FROM mart.fct_company_period
GROUP BY company_fact
ORDER BY rows DESC;

-- EBITDA sanity: sample of company/periods with both EBIT and D&A
-- Shows computed EBITDA for review — not an assertion, but a trust check
SELECT
    dc.entityname,
    f.end_date,
    f.fy,
    f.fp,
    MAX(CASE WHEN f.company_fact = 'Revenues'                             THEN f.val END) AS revenue,
    MAX(CASE WHEN f.company_fact = 'OperatingIncomeLoss'                  THEN f.val END) AS ebit,
    MAX(CASE WHEN f.company_fact = 'DepreciationDepletionAndAmortization' THEN f.val END) AS da,
    MAX(CASE WHEN f.company_fact = 'OperatingIncomeLoss'                  THEN f.val END)
    + COALESCE(MAX(CASE WHEN f.company_fact = 'DepreciationDepletionAndAmortization' THEN f.val END), 0)
        AS ebitda
FROM mart.fct_company_period f
JOIN mart.dim_company dc ON dc.cik = f.cik
GROUP BY dc.entityname, f.end_date, f.fy, f.fp
HAVING
    MAX(CASE WHEN f.company_fact = 'OperatingIncomeLoss' THEN f.val END) IS NOT NULL
    AND MAX(CASE WHEN f.company_fact = 'DepreciationDepletionAndAmortization' THEN f.val END) IS NOT NULL
ORDER BY dc.entityname, f.end_date
LIMIT 20;
