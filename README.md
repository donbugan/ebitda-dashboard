# EBITDA Power BI Dashboard

Goal: Build an EBITDA metric dashboard with transparent building blocks:
Revenue -> (COGS) -> Gross Profit -> (Opex) -> EBIT -> (+ D&A) -> EBITDA

## Repo Structure
- data/raw: original datasets (not committed)
- data/interim: cleaned intermediate outputs (not committed)
- data/processed: curated model outputs (not committed)
- sql: schema + transformation queries ✅
- powerbi: PBIX + model notes ⏳
- docs: metric definitions + decisions ⏳
- scripts: helper scripts ⏳

## Discovery status (completed)
- Selected SEC tags for EBITDA building blocks (staging.selected_sec_tags)
- Extracted subset from Kaggle companyfacts.csv (scripts/30_extract_companyfacts_selected.sh)
- Loaded staging.companyfacts_selected (sql/01_create_tables.sql + sql/20_copy_companyfact_selected.sql)
- Added audit + lineage stamping (sql/00_audit_tables.sql + sql/03_audit.sql + sql/04_add_lineage_cols.sql + sql/05_backfill_lineage.sql)
- Data quality checks (sql/21_dq_companyfacts_selected.sql)
- End-to-end runner (scripts/40_run_discovery_load.sh)

## Next steps
1) Build a minimal star schema for Power BI
   - dim_company (cik, entityName)
   - dim_date (calendar)
   - fact_company_period (cik, end_date, tag/value)
2) Create EBITDA measures (EBIT + D&A) and sanity checks
3) Power BI model + visuals (waterfall, trends, slicers)
