CREATE SCHEMA IF NOT EXISTS audit;

CREATE TABLE IF NOT EXISTS audit.ingestion_runs (
    run_id                      text PRIMARY KEY
    , run_ts                    timestamptz NOT NULL DEFAULT now()
    
    , source_path               text NOT NULL
    , source_bytes              bigint
    , source_sha256             text

    , selected_tags_sha256      text
    , selected_tags_count       integer
    
    , output_path               text NOT NULL
    , output_bytes              bigint
    , output_sha256             text

    , rows_loaded               bigint
    , ciks_loaded               bigint
    , min_end_date              date
    , max_end_date              date
    , future_end_date_rows      bigint

    , notes                     text
);
