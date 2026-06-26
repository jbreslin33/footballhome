-- 054: bump person_billing default next_bill_date from 7/1 to 7/2 to
-- match operational reality.  Existing rows are NOT touched (the column
-- default only kicks in on INSERTs that omit the column, which our app
-- never does — it always supplies a value).  Future ALTER will be safe.

ALTER TABLE person_billing
  ALTER COLUMN next_bill_date SET DEFAULT DATE '2026-07-02';
