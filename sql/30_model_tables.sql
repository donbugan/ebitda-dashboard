-- Mart schema objects for Power BI-ready tables

CREATE SCHEMA IF NOT EXISTS mart;

CREATE TABLE IF NOT EXISTS mart.dim_company (
    cik             bigint PRIMARY KEY,
    entityname      text,
    peer_group      text
);

CREATE TABLE IF NOT EXISTS mart.dim_date (
    date_key        date PRIMARY KEY,
    year            integer,
    quarter         integer,
    quarter_label   text,
    month           integer,
    month_name      text
);

CREATE TABLE IF NOT EXISTS mart.fct_company_period (
    cik             bigint,
    end_date        date,
    company_fact    text,
    val             numeric,
    units           text,
    fy              integer,
    fp              text,
    form            text,
    filed           date,
    load_id         bigint,
    loaded_at       timestamptz
);
