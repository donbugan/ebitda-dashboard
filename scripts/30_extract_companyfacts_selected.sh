#!/usr/bin/env bash
set -euo pipefail

# Extract a subset of companyfacts.csv limited to tags in staging.selected_sec_tags
#
# Usage:
#    scripts/30_extract_companyfacts_selected.sh \
#     /path/to/companyfacts.csv \
#     data/raw/companyfacts_selected.csv
#
# Requires:
# - docker (running container with Postgres)
# - miller (mlr)
#
# Notes:
# - Writes a temporary tag list to data/interim/selected_sec_tags.csv
# - Output columns align to staging.companyfacts_selected

if [[ $# -ne 2 ]]; then 
  echo "usage: $0 /path/to/companyfacts.csv data/raw/companyfacts_selected.csv" >&2
  exit 1
fi

SRC="$1"
OUT="$2"

# Load env (for PG_CONTAINER, PG_USER, PG_DB if you use them elsewhere)
set -a
source "$(dirname "$0")/../.env"
set +a

mkdir -p data/interim "$(dirname "$OUT")"
TAGS_TXT="data/interim/selected_sec_tags.txt"
TAGS_CSV="data/interim/selected_sec_tags.csv"
# Export tags (one per line)
docker exec -i "${PG_CONTAINER:-ebitda_pg16}" psql -U "${PG_USER:-ebitda}" -d "${PG_DB:-ebitda}" -Atc \
  "SELECT tag FROM staging.selected_sec_tags ORDER BY tag;" \
  > "${TAGS_TXT}"
# Make a proper 1-column CSV with header for mlr join
{ echo "companyFact"; cat "${TAGS_TXT}"; } > "${TAGS_CSV}"

# Cut columns first (faster), then join on companyFact
mlr --csv cut -f cik,entityName,companyFact,end,val,accn,fy,fp,form,filed,units "${SRC}" \
  | mlr --csv join --ul -j companyFact -f "${TAGS_CSV}" \
  > "${OUT}"

echo "Wrote: ${OUT}"
echo "Rows:"
wc -l "${OUT}" | awk '{print $1}'
