-- Purpose:
-- Identify candidate SEC tag names (line_item) relevant to EBITDA building blocks.
-- Source:
-- raw.line_item_counts (derived from Kaggle SEC EDGAR company facts dataset)
-- Output:
-- A ranked list of tag candidates by availability (count).

SELECT line_item
    , count
FROM raw.line_item_counts
WHERE
    line_item ilike '%revenue%'
    or line_item ilike '%sales%'
    or line_item ilike '%costofrevenue%'
    or line_item ilike '%costofgoods%'
    or line_item ilike '%operatingincome%'
    or line_item ilike '%operatingprofit%'
    or line_item ilike '%depreciation%'
    or line_item ilike '%amort%'
    or line_item ilike '%interest%'
    or line_item ilike '%incometax%'
ORDER BY count DESC
LIMIT 80;
