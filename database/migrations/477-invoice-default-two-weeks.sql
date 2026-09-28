-- 477 (2026-09-28) — The default is a usual 2 weeks, not a usual week.
-- Owner: "its confusing. so i think it should be usual 2 weeks?" — the
-- default is laid out exactly like an invoice window, Fri … Thu twice, so
-- both Wednesdays are there to edit.  day_index 0 = the first Friday,
-- 13 = the closing Thursday; a new invoice's day = period_start + day_index.
-- Existing weekly rows are copied into both weeks.

ALTER TABLE invoice_default_shifts ADD COLUMN IF NOT EXISTS day_index SMALLINT;
ALTER TABLE invoice_default_shifts ALTER COLUMN weekday DROP NOT NULL;

-- weekday (0 = Sun … 6 = Sat) → index within a Fri-start week, in both weeks.
INSERT INTO invoice_default_shifts (issuer_id, day_index, start_at, end_at, hours, note)
SELECT d.issuer_id, ((d.weekday - 5 + 7) % 7) + 7, d.start_at, d.end_at, d.hours, d.note
  FROM invoice_default_shifts d
 WHERE d.day_index IS NULL AND d.weekday IS NOT NULL;
UPDATE invoice_default_shifts SET day_index = (weekday - 5 + 7) % 7 WHERE day_index IS NULL AND weekday IS NOT NULL;

ALTER TABLE invoice_default_shifts ALTER COLUMN day_index SET NOT NULL;
ALTER TABLE invoice_default_shifts DROP CONSTRAINT IF EXISTS invoice_default_shifts_weekday_check;
ALTER TABLE invoice_default_shifts DROP COLUMN IF EXISTS weekday;
ALTER TABLE invoice_default_shifts ADD CONSTRAINT invoice_default_shifts_day_index_check CHECK (day_index BETWEEN 0 AND 13);
DROP INDEX IF EXISTS invoice_default_shifts_issuer_idx;
CREATE INDEX IF NOT EXISTS invoice_default_shifts_issuer_idx ON invoice_default_shifts (issuer_id, day_index, start_at);
COMMENT ON TABLE invoice_default_shifts IS 'An issuer''s usual 2 weeks, day_index 0 (first Friday) … 13 (closing Thursday); copied onto each new invoice''s days (mig 470/477).';

UPDATE message_templates
   SET body = 'The usual 2 weeks for {name}, Friday to the closing Thursday. A new invoice starts with these days filled in; change or delete any of them there.',
       label = 'Invoices — usual 2 weeks hint'
 WHERE kind = 'invoices' AND tier = 'default_hint';
