TRUNCATE staging.companyfacts_selected;

COPY staging.companyfacts_selected (
    companyFact
    , cik
    , entityName
    , end_date 
    , val
    , accn
    , fy
    , fp
    , form
    , filed
    , units
)
FROM '/data/raw/companyfacts_selected.csv'
WITH (
    FORMAT csv
    , HEADER true
);
