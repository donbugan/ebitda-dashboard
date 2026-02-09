WITH ins AS (
  INSERT INTO audit.load_run (source_name, source_path, note)
  VALUES (
    'kaggle companyfacts.csv subset',
    '/data/raw/companyfacts_selected.csv',
    'backfill: initial load before audit was added'
  )
  RETURNING load_id, load_ts
)
UPDATE staging.companyfacts_selected s
SET load_id = ins.load_id,
    loaded_at = ins.load_ts
FROM ins
WHERE s.load_id IS NULL;
