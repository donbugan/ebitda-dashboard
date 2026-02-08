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

## Repro:
- Install: `sudo apt install -y miller`
- Subset: see `scripts/` or `sql/discovery/12_selected_tags.sql` for the tag list.
