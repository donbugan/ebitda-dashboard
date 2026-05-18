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

## Repro:
- Install: `sudo apt install -y miller`
- Subset: see `scripts/` or `sql/discovery/12_selected_tags.sql` for the tag list.
