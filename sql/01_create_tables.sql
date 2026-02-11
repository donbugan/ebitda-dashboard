--Staging subset extracted from companyfacts.csv
DROP TABLE IF EXISTS staging.companyfacts_selected;

CREATE TABLE staging.companyfacts_selected (
    cik             bigint
    , entityname    text
    , companyfact   text
    , end_date      date
    , val           numeric
    , accn          text
    , fy            integer
    , fp            text
    , form          text
    , filed         date
    , units         text
);
