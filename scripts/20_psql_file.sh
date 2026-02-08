#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 sql/01_schemas.sql" >&2
  exit 1
fi

SQL_FILE="$1"

# Load env vars
set -a
source "$(dirname "$0")/../.env"
set +a

PG_CONTAINER="{PG_CONTAINER:-ebitda_pg16}"
docker exec -i "SPG_CONTAINER" psql -U "${PG_USER}" -d "${PG_DB}" < "${SQL_FILE}"
