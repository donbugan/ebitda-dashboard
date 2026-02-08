-- Purpose:
-- Identify candidate tag names for Depreciation and Amortization inputs for EBITDA.
-- Notes:
-- SEC tags vary widely; this narrows the search and ranks by frequency.

SELECT
    line_item
    , count
    , left(description, 160) as description_sample
FROM raw.line_item_counts
WHERE
    line_item ilike '%depr%'
    or line_item ilike '%depreciat%'
    or line_item ilike '%amort%'
    or line_item ilike '%depletion%'
ORDER BY count DESC
LIMIT 200;
