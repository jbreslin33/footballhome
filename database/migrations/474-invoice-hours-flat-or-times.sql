-- 474 (2026-09-27) — A day's hours as from/till OR a flat number.
-- Owner: "show all days for all persons straight down with ability to put
-- start and end time OR just a flat number of hours for that day. if we
-- fill time then hour is automatic or we can fill hours for the day and
-- time then blanks."  Also: "for luke and anthony default hours are
-- mondays and wednesdays 4 to 7 and friday 5 to 7."
--
-- invoice_work_shifts / invoice_default_shifts: start_at + end_at, or
-- hours, never both.  Hours counted = COALESCE(hours, end - start).

ALTER TABLE invoice_work_shifts ALTER COLUMN start_at DROP NOT NULL;
ALTER TABLE invoice_work_shifts ALTER COLUMN end_at   DROP NOT NULL;
ALTER TABLE invoice_work_shifts ADD COLUMN IF NOT EXISTS hours NUMERIC(6,2);
ALTER TABLE invoice_work_shifts DROP CONSTRAINT IF EXISTS invoice_work_shifts_check;
ALTER TABLE invoice_work_shifts ADD CONSTRAINT invoice_work_shifts_times_or_hours CHECK (
  (start_at IS NOT NULL AND end_at IS NOT NULL AND end_at > start_at AND hours IS NULL)
  OR (start_at IS NULL AND end_at IS NULL AND hours IS NOT NULL AND hours > 0));
COMMENT ON COLUMN invoice_work_shifts.hours IS 'Flat hours for the day when no from/till is given (mig 474).';

ALTER TABLE invoice_default_shifts ALTER COLUMN start_at DROP NOT NULL;
ALTER TABLE invoice_default_shifts ALTER COLUMN end_at   DROP NOT NULL;
ALTER TABLE invoice_default_shifts ADD COLUMN IF NOT EXISTS hours NUMERIC(6,2);
ALTER TABLE invoice_default_shifts DROP CONSTRAINT IF EXISTS invoice_default_shifts_check;
ALTER TABLE invoice_default_shifts ADD CONSTRAINT invoice_default_shifts_times_or_hours CHECK (
  (start_at IS NOT NULL AND end_at IS NOT NULL AND end_at > start_at AND hours IS NULL)
  OR (start_at IS NULL AND end_at IS NULL AND hours IS NOT NULL AND hours > 0));

-- Luke (3463) and Anthony (22397): Mon + Wed 4–7 pm, Fri 5–7 pm.
INSERT INTO invoice_default_shifts (issuer_id, weekday, start_at, end_at)
SELECT i.id, d.weekday, d.start_at, d.end_at
  FROM invoice_issuers i
  CROSS JOIN (VALUES (1, TIME '16:00', TIME '19:00'), (3, TIME '16:00', TIME '19:00'), (5, TIME '17:00', TIME '19:00')) AS d(weekday, start_at, end_at)
 WHERE i.person_id IN (3463, 22397)
   AND NOT EXISTS (SELECT 1 FROM invoice_default_shifts x WHERE x.issuer_id = i.id AND x.weekday = d.weekday AND x.start_at = d.start_at);
