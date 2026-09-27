-- 472 (2026-09-27) — Invoice periods: two Fri–Thu weeks, numbered per year.
-- Owner: "the invoice is 2 weeks from a friday to a thursday … 19 is from
-- fri [11]th of sept to thu [24]th of sep", "this week is #19", "the date
-- in title is for the monday of week".
--
-- Period k of a year starts anchor_start + (k - anchor_number) × 14 days
-- and runs 14 days; the invoice is dated the Friday after it ends.  The
-- title's two dates are the Mondays inside each Fri–Thu week.  Checks
-- against the PDFs: 2026.18 = 8/28–9/10 dated 9/11 (title 8/31 & 9/7),
-- 2026.19 = 9/11–9/24 dated 9/25 (9/14 & 9/21), Jamie 2026.10 = 5/8–5/21
-- dated 5/22.  Add a row for each new year by migration.

CREATE TABLE IF NOT EXISTS invoice_period_policies (
  invoice_year  INT PRIMARY KEY,
  anchor_number INT NOT NULL,
  anchor_start  DATE NOT NULL,        -- first day (a Friday) of period anchor_number
  period_days   INT NOT NULL DEFAULT 14
);
COMMENT ON TABLE invoice_period_policies IS 'Where the biweekly Fri–Thu invoice periods sit in each year (mig 472).';
INSERT INTO invoice_period_policies (invoice_year, anchor_number, anchor_start) VALUES (2026, 19, DATE '2026-09-11')
ON CONFLICT (invoice_year) DO NOTHING;

CREATE OR REPLACE FUNCTION fh_invoice_period_start(p_year int, p_number int) RETURNS date
LANGUAGE sql STABLE AS $$
  SELECT anchor_start + (p_number - anchor_number) * period_days
    FROM invoice_period_policies WHERE invoice_year = p_year
$$;
CREATE OR REPLACE FUNCTION fh_invoice_period_days(p_year int) RETURNS int
LANGUAGE sql STABLE AS $$
  SELECT period_days FROM invoice_period_policies WHERE invoice_year = p_year
$$;

-- Re-derive the seeded periods from their numbers.
UPDATE invoices v
   SET period_start = fh_invoice_period_start(v.invoice_year, v.invoice_number),
       period_end   = fh_invoice_period_start(v.invoice_year, v.invoice_number) + fh_invoice_period_days(v.invoice_year) - 1
 WHERE fh_invoice_period_start(v.invoice_year, v.invoice_number) IS NOT NULL;
COMMENT ON COLUMN invoices.period_start IS 'First day covered (a Friday); from fh_invoice_period_start(year, number), editable (mig 472).';
COMMENT ON COLUMN invoices.period_end   IS 'Last day covered (a Thursday, 13 days on) (mig 472).';
