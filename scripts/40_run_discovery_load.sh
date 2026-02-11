#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load env vars
set -a
source "${ROOT_DIR}/.env"
set +a

echo "== Extract subset CSV =="
SRC="${1:-$HOME/.cache/kagglehub/datasets/jamesglang/sec-edgar-company-facts-september2023/versions/6/companyfacts.csv}"
OUT="${2:-${ROOT_DIR}/data/raw/companyfacts_selected.csv}"

"${ROOT_DIR}/scripts/30_extract_companyfacts_selected.sh" "$SRC" "$OUT" 

echo "== Ensure schemas & tables =="
"${ROOT_DIR}/scripts/20_psql_file.sh" "${ROOT_DIR}/sql/01_schemas.sql"
"${ROOT_DIR}/scripts/20_psql_file.sh" "${ROOT_DIR}/sql/01_create_tables.sql"

echo "== Audit + lineage =="
"${ROOT_DIR}/scripts/20_psql_file.sh" "${ROOT_DIR}/sql/00_audit_tables.sql"
"${ROOT_DIR}/scripts/20_psql_file.sh" "${ROOT_DIR}/sql/03_audit.sql"
"${ROOT_DIR}/scripts/20_psql_file.sh" "${ROOT_DIR}/sql/04_add_lineage_cols.sql"
"${ROOT_DIR}/scripts/20_psql_file.sh" "${ROOT_DIR}/sql/05_backfill_lineage.sql"

echo "== Load staging.companyfacts_selected =="
"${ROOT_DIR}/scripts/20_psql_file.sh" "${ROOT_DIR}/sql/20_copy_companyfact_selected.sql"

echo "== Data quality checks =="
"${ROOT_DIR}/scripts/20_psql_file.sh" "${ROOT_DIR}/sql/21_dq_companyfacts_selected.sql"

echo "== Done =="
