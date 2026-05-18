#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set -a
source "${ROOT_DIR}/.env"
set +a

echo "== Create/fix mart schema objects =="
"${ROOT_DIR}/scripts/20_psql_file.sh" "${ROOT_DIR}/sql/30_model_tables.sql"

echo "== Populate mart dimensions and facts =="
"${ROOT_DIR}/scripts/20_psql_file.sh" "${ROOT_DIR}/sql/02_transforms.sql"

echo "== Create analytics views =="
"${ROOT_DIR}/scripts/20_psql_file.sh" "${ROOT_DIR}/sql/31_mart_ebitda_view.sql"
"${ROOT_DIR}/scripts/20_psql_file.sh" "${ROOT_DIR}/sql/32_depreciation_schedule_view.sql"

echo "== Mart data quality checks =="
"${ROOT_DIR}/scripts/20_psql_file.sh" "${ROOT_DIR}/sql/22_dq_mart.sql"

echo "== Done =="
