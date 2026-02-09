ALTER TABLE IF EXISTS staging.companyfacts_selected
  ADD COLUMN IF NOT EXISTS load_id bigint,
  ADD COLUMN IF NOT EXISTS loaded_at timestamptz;
