-- Data quality checks for staging.companyfacts_selected
\set ON_ERROR_STOP on

-- Row count
SELECT count(*) AS total_rows
FROM staging.companyfacts_selected;

-- Tag breakdown (sanity)
SELECT companyfact, count(*) AS rows
FROM staging.companyfacts_selected
GROUP BY 1
ORDER BY 2 DESC;

-- Only expected tags: count + sample
WITH unexpected AS (
    SELECT companyfact
    FROM staging.companyfacts_selected
    GROUP BY 1
    EXCEPT
    SELECT tag FROM staging.selected_sec_tags
)
SELECT count(*) AS unexpected_tag_count
FROM unexpected;

WITH unexpected AS (
    SELECT companyfact
    FROM staging.companyfacts_selected
    GROUP BY 1
    EXCEPT
    SELECT tag FROM staging.selected_sec_tags
)
SELECT companyfact
FROM unexpected
ORDER BY companyfact
LIMIT 20;

-- Null checks (should be 0 for these)
SELECT
    sum((cik IS NULL)::int)           AS null_cik,
    sum((companyfact IS NULL)::int)   AS null_companyfact,
    sum((end_date IS NULL)::int)      AS null_end_date,
    sum((val IS NULL)::int)           AS null_val,
    sum((units IS NULL)::int)         AS null_units
FROM staging.companyfacts_selected;

-- Date sanity
SELECT
    min(end_date) AS min_end_date,
    max(end_date) AS max_end_date,
    count(*) FILTER (WHERE end_date > CURRENT_DATE) AS future_end_date_rows
FROM staging.companyfacts_selected;
