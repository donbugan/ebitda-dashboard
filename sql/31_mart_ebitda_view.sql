-- EBITDA components view: pivots long-format fact into one row per company/period
-- Used for SQL exploration, validation, and as an optional Power BI import table

CREATE OR REPLACE VIEW mart.v_ebitda_components AS
WITH pivoted AS (
    SELECT
        cik,
        end_date,
        fy,
        fp,
        MAX(CASE WHEN company_fact = 'Revenues'                             THEN val END) AS revenue,
        MAX(CASE WHEN company_fact = 'OperatingIncomeLoss'                  THEN val END) AS ebit,
        MAX(CASE WHEN company_fact = 'DepreciationDepletionAndAmortization' THEN val END) AS da,
        MAX(CASE WHEN company_fact = 'InterestExpense'                      THEN val END) AS interest_expense,
        MAX(CASE WHEN company_fact = 'IncomeTaxExpenseBenefit'              THEN val END) AS income_tax
    FROM mart.fct_company_period
    GROUP BY cik, end_date, fy, fp
)
SELECT
    p.cik,
    dc.entityname,
    p.end_date,
    p.fy,
    p.fp,
    p.revenue,
    p.ebit,
    p.da,
    p.interest_expense,
    p.income_tax,
    p.ebit + COALESCE(p.da, 0)                                              AS ebitda,
    CASE
        WHEN p.revenue IS NOT NULL AND p.revenue <> 0
        THEN ROUND(((p.ebit + COALESCE(p.da, 0)) / p.revenue) * 100, 2)
    END                                                                     AS ebitda_margin_pct
FROM pivoted p
JOIN mart.dim_company dc ON dc.cik = p.cik;
