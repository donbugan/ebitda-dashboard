# EBITDA Power BI Dashboard Decision Log

## Purpose
To ensure our repo is walkable by documenting all decisions and the reasoning behind it.

## Heuristic
If a choice affects how data is loaded, transformed, modeled or measured, log it here.

## Decisions

| Decision | Date | Notes |
|---|---|---|
| Capture exploratory SQL for SEC tag discovery (including D&A candidates) in `sql/discovery/` | 2026-02-08 | Keeps the “why these tags?” reasoning reproducible and prevents it from being lost in chat history. Supports future refactoring and reviewer walkthroughs. |
| Use Miller (`mlr`) to subset `companyfacts.csv` instead of `xsv` | 2026-02-08 | `xsv` was not available via apt in this environment. Miller is available and streams CSV efficiently, letting us extract only selected SEC tags into a manageable subset for Postgres ingestion. |
| Keep `mart.fct_company_period` in long format (one row per cik/end_date/company_fact) | 2026-05-17 | Long format mirrors the source structure and keeps SQL transforms simple. Power BI DAX handles column pivoting efficiently via CALCULATE/FILTER. A wide/pivoted design would require DDL changes every time a new tag is added. The `mart.v_ebitda_components` view provides a pivoted representation for SQL exploration without committing the fact table to a fixed shape. |
| Compute EBITDA in both SQL view and Power BI DAX | 2026-05-17 | `mart.v_ebitda_components` pre-computes EBITDA for validation, spot-checking, and direct SQL querying. Power BI DAX measures recompute dynamically to respond to slicers and filters. The SQL view is the governance reference; DAX is the interactive layer. Both must produce the same values. |
| Retain `audit.ingestion_runs` table without dropping | 2026-05-17 | `sql/00_audit_tables.sql` creates `audit.ingestion_runs`, which was an early design superseded by `audit.load_run` (created in `sql/03_audit.sql`). `audit.load_run` is what lineage actually references. `audit.ingestion_runs` is unused but retained to preserve git history and avoid a migration. Future cleanup: drop `00_audit_tables.sql` and remove from runner when convenient. |

| Restructure peer groups — remove Accenture, add Enterprise Hardware group, redefine Cloud & Data Platforms | 2026-05-31 | Original grouping placed Accenture, Cisco, and HP in Cloud & Data Platforms — none are data platforms. Cisco/HP/Dell are hardware peers and were moved to a new Enterprise Hardware group. Cloud & Data Platforms redefined as pure-play SaaS/data companies: Snowflake, MongoDB, Elastic, Palantir, Alteryx, Domo, Teradata. Accenture set to NULL (no suitable peer group in this dataset). Final universe: 39 companies, 8 groups. |
| Fix Walt Disney duplicate CIK | 2026-05-31 | Two CIKs existed for Walt Disney: 1001039 (pre-Fox acquisition entity, data 2007–2018) and 1744489 (current entity, data 2017–2023). Set peer_group = NULL on CIK 1001039 to prevent double-counting the 2017–2018 overlap period. Dashboard uses CIK 1744489 only. |
| Expand selected SEC revenue tags to cover post-ASC 606 SaaS filers | 2026-05-31 | After peer group expansion, several Cloud & Data Platforms companies (Snowflake, Palantir, Elastic, Domo) had no revenue in fct_company_period. Root cause: post-ASC 606 adoption, SaaS companies file revenue under `RevenueFromContractWithCustomerExcludingAssessedTax` or `SalesRevenueNet` rather than `Revenues`. Added both tags to `staging.selected_sec_tags`. Also added `DepreciationAndAmortization` (separate from `DepreciationDepletionAndAmortization`) for Teradata. Tag list expanded from 5 to 8. |
| Exclude Revenue vs EBITDA scatter plot from Page 3 | 2026-05-31 | Revenue is unavailable for a significant portion of the dataset due to non-standard SEC tag usage. Plotting incomplete Revenue data against EBITDA would produce a misleading picture. Scatter excluded; limitation documented in the dashboard data notes panel. Candidate for future extension with a broader tag set or alternative data source. |
| Document Apple FY2022 D&A anomaly as known limitation — no fix | 2026-05-31 | Apple FY2022 `DepreciationDepletionAndAmortization` = $33.4B, approximately 3× FY2021 ($12.5B). This is a SEC EDGAR filing artefact (restated or reclassified filing), not a real tripling of depreciation. No correction applied — the source data is as-filed. Documented as a known limitation in the dashboard. The D&A trend chart on Page 4 makes the spike visually apparent to any reviewer. |
| YOY Growth DAX measure scoped to card context only | 2026-05-31 | `YoY_Growth` hardcodes `fy = 2022` and `fy = 2021` to compute a single point-in-time growth figure for the depreciation schedule KPI card. It is not suitable for use in table row context — in a table, it returns the same value for every row regardless of the row's period, and returns BLANK (evaluated as 0 via DAX `IF(DA_2021 = 0, 0, ...)`) when row context overrides slicer context. A proper time-intelligence YOY measure would be required for per-row use. |

## Repro:
- Install: `sudo apt install -y miller`
- Subset: see `scripts/` or `sql/discovery/12_selected_tags.sql` for the tag list.
