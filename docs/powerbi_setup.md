# Power BI Setup Guide

## Data Source

Connect to PostgreSQL via the native Power BI PostgreSQL connector:

- **Server:** `localhost` (or Docker host IP)
- **Port:** as configured in `.env` (`PG_PORT`, default `5432`)
- **Database:** as configured in `.env` (`PG_DB`, default `ebitda`)
- **Mode:** Import (recommended for portfolio — avoids live connection dependency)

## Tables to Import

| Table / View | Purpose |
|---|---|
| `mart.dim_company` | Company dimension — slicer and label source |
| `mart.dim_date` | Date dimension — year/quarter/month slicers |
| `mart.fct_company_period` | Base fact table — all tag values by company and period |
| `mart.v_ebitda_components` | Pre-pivoted EBITDA view — optional import for simpler DAX |

## Relationships

Set in the Power BI model view:

| From | To | Cardinality |
|---|---|---|
| `fct_company_period[cik]` | `dim_company[cik]` | Many → One |
| `fct_company_period[end_date]` | `dim_date[date_key]` | Many → One |

Both relationships should use single-direction cross-filter (from fact to dimension).

## DAX Measures

Create a dedicated `_Measures` table (blank query, no data) to keep measures organised.

```dax
Revenue =
CALCULATE(
    SUM(fct_company_period[val]),
    fct_company_period[company_fact] = "Revenues"
)

EBIT =
CALCULATE(
    SUM(fct_company_period[val]),
    fct_company_period[company_fact] = "OperatingIncomeLoss"
)

DA =
CALCULATE(
    SUM(fct_company_period[val]),
    fct_company_period[company_fact] = "DepreciationDepletionAndAmortization"
)

EBITDA = [EBIT] + COALESCE([DA], 0)

EBITDA Margin % =
DIVIDE([EBITDA], [Revenue], BLANK()) * 100

InterestExpense =
CALCULATE(
    SUM(fct_company_period[val]),
    fct_company_period[company_fact] = "InterestExpense"
)

IncomeTax =
CALCULATE(
    SUM(fct_company_period[val]),
    fct_company_period[company_fact] = "IncomeTaxExpenseBenefit"
)
```

> **Governance note:** DAX measures must produce the same EBITDA values as `mart.v_ebitda_components`. Validate after model build by cross-checking a sample of companies and periods between the Power BI visual and a direct SQL query on the view.

## Dashboard Pages

### Page 1 — EBITDA Overview

| Visual | Type | Fields |
|---|---|---|
| EBITDA waterfall | Waterfall chart | Categories: Revenue, EBIT, D&A, EBITDA. Values: respective DAX measures |
| EBITDA trend | Line chart | X: `dim_date[year]`, Y: `[EBITDA]`, Legend: `dim_company[entityname]` |
| EBITDA Margin % | Card | `[EBITDA Margin %]` |
| Company slicer | Slicer | `dim_company[entityname]` |
| Year slicer | Slicer | `dim_date[year]` |
| Filing type slicer | Slicer | `fct_company_period[form]` (filter to 10-K or 10-Q) |

### Page 2 — Component Analysis

| Visual | Type | Fields |
|---|---|---|
| Component contribution | Stacked bar | X: `dim_date[year]`, Values: Revenue, EBIT, D&A by company |
| EBIT vs EBITDA | Clustered bar | Compare EBIT and EBITDA side by side by company |
| Period detail table | Table | entityname, end_date, fy, fp, Revenue, EBIT, D&A, EBITDA, EBITDA Margin % |

### Page 3 — Company Comparison

| Visual | Type | Fields |
|---|---|---|
| EBITDA by company | Bar chart | X: `dim_company[entityname]`, Y: `[EBITDA]` |
| Margin ranking | Bar chart | X: `dim_company[entityname]`, Y: `[EBITDA Margin %]`, sorted descending |
| Scatter: Revenue vs EBITDA | Scatter chart | X: `[Revenue]`, Y: `[EBITDA]`, Details: `dim_company[entityname]` |

### Page 4 — Depreciation Schedule

| Visual | Type | Fields |
|---|---|---|
| D&A trend | Line chart | X: `dim_date[year]`, Y: `[DA]`, Legend: `dim_company[entityname]` |
| D&A by company table | Table | entityname, year, quarter_label, fy, fp, form, D&A |

> Import `mart.v_depreciation_schedule` as a separate table for this page if a dedicated capital-tracking view is preferred over using DAX filters on the fact table.

## Formatting Notes

- Format all currency measures in USD millions (`/ 1000000`) for readability if values are reported in full dollars.
- Use conditional formatting on the margin % column in tables (green above 15%, amber 5–15%, red below 5%).
- Set the report theme to a neutral corporate palette — avoid the default blue Power BI theme for a finance audience.
