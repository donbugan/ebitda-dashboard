-- Mart layer transforms: populate dimensions and fact from staging

-- dim_company: one row per company, upsert to handle reruns
WITH deduped AS (
    SELECT cik, entityname,
        ROW_NUMBER() OVER (PARTITION BY cik ORDER BY filed DESC) as rn
    FROM staging.companyfacts_selected
)

INSERT INTO mart.dim_company (cik, entityname)
SELECT cik, entityname
FROM deduped
WHERE rn = 1
ON CONFLICT (cik) DO UPDATE
    SET entityname = EXCLUDED.entityname;

-- dim_date: generate one row per calendar day across the full staging date range
INSERT INTO mart.dim_date (date_key, year, quarter, quarter_label, month, month_name)
SELECT
    d::date                                         AS date_key,
    EXTRACT(year    FROM d)::integer                AS year,
    EXTRACT(quarter FROM d)::integer                AS quarter,
    'Q' || EXTRACT(quarter FROM d)::integer         AS quarter_label,
    EXTRACT(month   FROM d)::integer                AS month,
    TO_CHAR(d, 'Month')                             AS month_name
FROM generate_series(
    (SELECT MIN(end_date) FROM staging.companyfacts_selected),
    (SELECT MAX(end_date) FROM staging.companyfacts_selected),
    '1 day'::interval
) AS d
ON CONFLICT (date_key) DO NOTHING;

-- fct_company_period: full replace from staging (idempotent)
-- Grain: one row per cik / end_date / company_fact (long format)
-- Deduped to keep only latest filing per (cik, end_date, companyfact)
TRUNCATE mart.fct_company_period;

INSERT INTO mart.fct_company_period (
    cik, end_date, company_fact, val, units, fy, fp, form, filed, load_id, loaded_at
)
WITH deduped AS (
  SELECT
    cik, end_date, companyfact, val, units, fy, fp, form, filed, load_id, loaded_at,
    ROW_NUMBER() OVER (PARTITION BY cik, end_date, companyfact ORDER BY filed DESC) as rn
  FROM staging.companyfacts_selected
)
SELECT
    cik, end_date, companyfact, val, units, fy, fp, form, filed, load_id, loaded_at
FROM deduped
WHERE rn = 1;
