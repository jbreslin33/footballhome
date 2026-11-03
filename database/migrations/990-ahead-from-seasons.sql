-- 990 (2026-11-03) — referee fees and game coaching ahead come from the
-- season model (ref_fee_policies × ref_fee_seasons over the league feeds),
-- not the calendar alone, so Money in & out and Expenses agree.
-- Owner 2026-11-03: "coach pay at 780 for year lol for apsl?" — the calendar
-- held one future APSL game while the feed has five, and the spring was the
-- stopgap rows of mig 896.  Those planned referee / coach-pay rows are turned
-- off (kept for the record); APSL is 11 home games for refs (mig 968).
ALTER TABLE cash_flow_planned ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;
UPDATE cash_flow_planned SET is_active = false WHERE category IN ('referees', 'labor');
