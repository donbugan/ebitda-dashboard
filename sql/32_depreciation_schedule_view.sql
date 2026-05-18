-- Depreciation schedule view: D&A by company, period, and filing
-- Structured for capital tracking and depreciation analysis reporting

CREATE OR REPLACE VIEW mart.v_depreciation_schedule AS
SELECT
    f.cik,
    dc.entityname,
    f.end_date,
    dd.year,
    dd.quarter,
    dd.quarter_label,
    f.fy,
    f.fp,
    f.form,
    f.filed,
    f.val       AS depreciation_and_amortization,
    f.units,
    f.load_id,
    f.loaded_at
FROM mart.fct_company_period f
JOIN mart.dim_company dc ON dc.cik = f.cik
JOIN mart.dim_date dd    ON dd.date_key = f.end_date
WHERE f.company_fact = 'DepreciationDepletionAndAmortization'
ORDER BY f.cik, f.end_date;
