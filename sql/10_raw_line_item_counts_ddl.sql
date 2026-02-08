DROP TABLE IF EXISTS raw.line_item_counts;

CREATE TABLE raw.line_item_counts (
  idx           numeric
  , line_item   text NOT NULL
  , count       numeric NOT NULL
  , description text
);

