# EBITDA Power BI Dashboard
Goal: Build an EBITDA metric dashboard with transparent building blocks:
Revenue -> (COGS) -> Gross Profit -> (Opex) -> EBIT -> (+ D&A) -> EBITDA

## Repo Structure
- data/raw: original datasets (not committed)
- data/interim: cleaned intermediate outputs (not committed)
- data/processed: curated model outputs (not committed)
- sql: schema + transformation queries
- powerbi: PBIX + model notes
- docs: metric definitions + decisions
- scripts: helper scripts

## Next steps
1) Pick a Kaggle fundamentals Dataset (CSV) ✅ - 2026-02-08
2) Load into staging table (or PowerBI import)
3) Build star schema + measures
4) Create visuals: waterfall, trends, slicers
