-- Selected v1 tag set for EBITDA extraction from companyfacts.csv

-- Core:
-- OperatingIncomeLoss (EBIT proxy)
-- DepreciationDepletionAndAmortization (D&A)
-- Revenues (top-line context)

-- Optional (can be extracted too; useful for additional breakdown views):
-- InterestExpense
-- IncomeTaxExpenseBenefit

CREATE TABLE IF NOT EXISTS staging.selected_sec_tags (
    tag text primary key
);

TRUNCATE staging.selected_sec_tags;

INSERT INTO staging.selected_sec_tags(tag) VALUES
    ('OperatingIncomeLoss'),
    ('DepreciationDepletionAndAmortization'),
    ('Revenues'),
    ('InterestExpense'),
    ('IncomeTaxExpenseBenefit');
