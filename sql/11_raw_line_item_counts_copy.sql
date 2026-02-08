TRUNCATE TABLE raw.line_item_counts;
COPY raw.line_item_counts (idx, line_item, count, description)
FROM '/data/raw/line_item_counts.csv'
WITH (
    FORMAT csv
    , HEADER true
    , QUOTE '"'
    , ESCAPE '"'
);
