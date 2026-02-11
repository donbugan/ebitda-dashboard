CREATE SCHEMA IF NOT EXISTS audit;

CREATE TABLE IF NOT EXISTS audit.load_run (
    load_id             bigserial PRIMARY KEY
    , load_ts           timestamptz not null default now()
    , actor             text not null default current_user
    , source_name       text
    , source_path       text
    , git_sha           text
    , note              text
);
