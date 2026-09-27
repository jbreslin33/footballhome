-- 470 (2026-09-27) — Weekly default hours per issuer + the invoice period.
-- Owner: "most of the schedule is set so a defulat should be able to be
-- set that i can edit fully."
--
-- invoice_default_shifts: the usual week for an issuer (weekday, from,
-- till).  An invoice covers two Monday-started weeks — owner: "the title
-- should be Invoice #18 8/31 & 09/07, Breslin, Luke … this week is #19" —
-- so period_start is the Monday of the week before the invoice's week and
-- period_end the Sunday of the invoice's week.  A new invoice is
-- pre-filled with one invoice_work_shifts row per matching day — plain
-- rows afterwards, edited or deleted like any other.  "Fill from weekly
-- default" on the page redoes it for an invoice with no days.

ALTER TABLE invoices ADD COLUMN IF NOT EXISTS period_start DATE;
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS period_end   DATE;
UPDATE invoices SET period_start = date_trunc('week', invoice_date)::date - 7, period_end = date_trunc('week', invoice_date)::date + 6 WHERE period_start IS NULL;
COMMENT ON COLUMN invoices.period_start IS 'Monday of the first week covered; default the Monday before the invoice''s week (mig 470).';
COMMENT ON COLUMN invoices.period_end   IS 'Sunday of the second week covered (mig 470).';

CREATE TABLE IF NOT EXISTS invoice_default_shifts (
  id         SERIAL PRIMARY KEY,
  issuer_id  INT NOT NULL REFERENCES invoice_issuers(id) ON DELETE CASCADE,
  weekday    SMALLINT NOT NULL CHECK (weekday BETWEEN 0 AND 6),   -- 0 = Sunday, as EXTRACT(DOW)
  start_at   TIME NOT NULL,
  end_at     TIME NOT NULL,
  note       TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (end_at > start_at)
);
CREATE INDEX IF NOT EXISTS invoice_default_shifts_issuer_idx ON invoice_default_shifts (issuer_id, weekday, start_at);
COMMENT ON TABLE invoice_default_shifts IS 'An issuer''s usual week; copied onto each new invoice''s days (mig 470).';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'Invoices — weekly default hint', 'invoices', 'default_hint', NULL,
       'The usual week for {name}. A new invoice starts with these days filled in for its period; change or delete any of them there.',
       11, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'default_hint');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'Invoices — period hint', 'invoices', 'period_hint', NULL,
       'Work from {start} to {end}. Change the dates to move the period; “Fill from weekly default” adds the usual days when the list is empty.',
       12, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'period_hint');
