#!/usr/bin/env bash
set -euo pipefail

# Extract a subset of companyfacts.csv limited to tags in staging.selected_sec_tags
#
# Usage:
#   scripts/30_extract_companyfacts_selected.sh /path/to/companyfacts.csv data/raw/companyfacts_selected.csv
#   scripts/30_extract_companyfacts_selected.sh /path/to/companyfacts.csv.gz data/raw/companyfacts_selected.csv
#
# Requires:
# - docker (running container with Postgres)
# - miller (mlr)
# Optional (recommended):
# - pv (for progress bar)

if [[ $# -ne 2 ]]; then
  echo "usage: $0 /path/to/companyfacts.csv(.gz) data/raw/companyfacts_selected.csv" >&2
  exit 1
fi

SRC="$1"
OUT="$2"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load env (PG_CONTAINER, PG_USER, PG_DB)
set -a
source "${ROOT_DIR}/.env"
set +a

mkdir -p "${ROOT_DIR}/data/interim" "$(dirname "$OUT")"

TAGS_TXT="${ROOT_DIR}/data/interim/selected_sec_tags.txt"
TAGS_CSV="${ROOT_DIR}/data/interim/selected_sec_tags.csv"

# Export tags (one per line)
docker exec -i "${PG_CONTAINER:-ebitda_pg16}" psql -U "${PG_USER:-ebitda}" -d "${PG_DB:-ebitda}" -Atc \
  "SELECT tag FROM staging.selected_sec_tags ORDER BY tag;" \
  > "${TAGS_TXT}"

# Make a proper 1-column CSV with header for mlr join
{ echo "companyFact"; cat "${TAGS_TXT}"; } > "${TAGS_CSV}"

TMP_OUT="${OUT}.tmp.$$"
trap 'rm -f "$TMP_OUT"' EXIT

echo "== Extract subset =="
echo "SRC: $SRC"
echo "OUT: $OUT"
echo "Tags: $(wc -l < "${TAGS_TXT}")"

# Build an input stream with progress if pv exists
input_stream() {
  if command -v pv >/dev/null 2>&1; then
    if [[ "$SRC" == *.gz ]]; then
      pv "$SRC" | gzip -dc
    else
      pv "$SRC"
    fi
  else
    if [[ "$SRC" == *.gz ]]; then
      gzip -dc "$SRC"
    else
      cat "$SRC"
    fi
  fi
}

# Cut columns first (faster), then join on companyFact
# Note: when streaming, tell mlr to read from stdin (no filename argument)
input_stream \
  | mlr --csv cut -f cik,entityName,companyFact,end,val,accn,fy,fp,form,filed,units \
  | mlr --csv join --ul -j companyFact -f "${TAGS_CSV}" \
  > "${TMP_OUT}"

mv -f "${TMP_OUT}" "${OUT}"
trap - EXIT

echo "Wrote: ${OUT}"
echo -n "Rows (excluding header): "
awk 'NR>1{c++} END{print c+0}' "${OUT}"
