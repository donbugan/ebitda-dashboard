# Metric Definitions

## Governance Header

| Field | Value |
|---|---|
| Owner | Data & Analytics |
| Version | 1.0 |
| Effective Date | 2026-05-17 |
| Review Cycle | Quarterly |
| Source | SEC EDGAR Company Facts (Kaggle subset, September 2023) |

> **Governing Principle:** "If you do not define the metric, someone else will."
>
> This document is the authoritative definition of every metric surfaced in the EBITDA dashboard. All calculations in Power BI DAX and in SQL views must conform to these definitions. Any deviation must be logged as a decision in `docs/decisions.md`.

---

## EBITDA Building Blocks

The EBITDA metric is constructed from the following building blocks in order:

```
Revenue
  - Cost of Goods Sold (COGS)        [not available in this dataset — see note]
= Gross Profit                        [not available in this dataset — see note]
  - Operating Expenses (Opex)        [not available in this dataset — see note]
= EBIT                                [sourced directly: OperatingIncomeLoss]
  + Depreciation & Amortization (D&A) [sourced directly: DepreciationDepletionAndAmortization]
= EBITDA
```

> **Data Availability Note:** COGS, Gross Profit, and Opex are not consistently available across the SEC tag set used in this project. The dataset includes `OperatingIncomeLoss` as a direct EBIT proxy, bypassing the need to compute it from sub-components. This is a known and accepted limitation documented in the discovery phase.

---

## Metric Definitions

### Revenue

| Field | Value |
|---|---|
| Definition | Total revenue recognised by the company in the reporting period |
| SEC Tag | `Revenues` |
| Formula | Direct source value |
| Units | USD (as reported) |
| Nulls | Present for companies that do not report under this tag. Some companies report under `SalesRevenueNet` or `RevenueFromContractWithCustomerExcludingAssessedTax` — these are excluded from v1 of this dataset. |

---

### EBIT (Operating Income / Loss)

| Field | Value |
|---|---|
| Definition | Earnings Before Interest and Taxes — operating profit after all operating expenses but before financing costs and taxes |
| SEC Tag | `OperatingIncomeLoss` |
| Formula | Direct source value |
| Units | USD (as reported) |
| Nulls | Present where companies do not separately disclose operating income |
| Note | Used as a direct EBIT proxy. The label "EBIT" is common in finance; `OperatingIncomeLoss` is the SEC-standardised equivalent. |

---

### Depreciation & Amortization (D&A)

| Field | Value |
|---|---|
| Definition | Non-cash charges representing the reduction in value of tangible assets (depreciation) and intangible assets (amortization) over their useful lives |
| SEC Tag | `DepreciationDepletionAndAmortization` |
| Formula | Direct source value |
| Units | USD (as reported) |
| Nulls | Present where companies do not separately disclose D&A in cash flow statements |
| Note | This tag typically appears in the cash flow statement as an add-back. It is the aggregate of depreciation and amortization and is not split in this dataset. |

---

### EBITDA

| Field | Value |
|---|---|
| Definition | Earnings Before Interest, Taxes, Depreciation and Amortization — a measure of core operating profitability before non-cash and financing adjustments |
| Formula | `OperatingIncomeLoss + DepreciationDepletionAndAmortization` |
| Units | USD |
| Nulls | Null if either EBIT or D&A is missing for a given company/period. D&A is treated as 0 via COALESCE where absent, but EBIT null results in a null EBITDA. |
| Governance | This is the single authoritative EBITDA definition for this project. No alternative calculations are permitted without a documented decision entry. |

---

### EBITDA Margin %

| Field | Value |
|---|---|
| Definition | EBITDA expressed as a percentage of Revenue — measures operating profitability relative to top-line revenue |
| Formula | `(EBITDA / Revenue) × 100` |
| Units | Percentage, rounded to 2 decimal places |
| Nulls | Null if Revenue is null or zero (division-by-zero guard applied) |
| Interpretation | Higher margin = greater efficiency. Used for cross-company and period-over-period comparison. |

---

### Interest Expense

| Field | Value |
|---|---|
| Definition | Cost of debt financing — interest paid on borrowings in the reporting period |
| SEC Tag | `InterestExpense` |
| Formula | Direct source value |
| Units | USD (as reported) |
| Role in this project | Supplementary context. Included in the dataset to support bridge from EBIT to EBITDA and for analyst exploration. Not used in the core EBITDA formula. |

---

### Income Tax Expense

| Field | Value |
|---|---|
| Definition | Tax charges recognised in the income statement for the reporting period |
| SEC Tag | `IncomeTaxExpenseBenefit` |
| Formula | Direct source value |
| Units | USD (as reported) |
| Role in this project | Supplementary context. Not used in the core EBITDA formula. |

---

## SEC Tag to Metric Mapping

| Metric | SEC Tag | Available |
|---|---|---|
| Revenue | `Revenues` | Yes |
| EBIT | `OperatingIncomeLoss` | Yes |
| D&A | `DepreciationDepletionAndAmortization` | Yes |
| Interest Expense | `InterestExpense` | Yes |
| Income Tax | `IncomeTaxExpenseBenefit` | Yes |
| COGS | `CostOfRevenue` | Not in v1 dataset |
| Gross Profit | `GrossProfit` | Not in v1 dataset |
| Opex | `OperatingExpenses` | Not in v1 dataset |

---

## Known Limitations

1. **Fiscal vs calendar periods:** SEC filings use fiscal year and quarter (`fy`, `fp`). These do not always align to calendar quarters. `end_date` is used as the reporting period anchor.
2. **Non-standard tags:** Some companies use company-specific extensions of US-GAAP tags. These are excluded from this dataset.
3. **Annual vs quarterly filings:** Both 10-K (annual) and 10-Q (quarterly) filings are included. Mixing these periods in trend analysis requires filtering by `form`.
4. **D&A sourced from cash flow:** `DepreciationDepletionAndAmortization` is typically disclosed in the cash flow statement as a non-cash add-back, not in the income statement directly. This is consistent with standard EBITDA calculation practice.
5. **Dataset vintage:** Source data is from September 2023. Companies with filings after that date are not represented.
