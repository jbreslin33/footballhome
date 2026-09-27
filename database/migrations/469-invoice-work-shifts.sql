-- 469 (2026-09-27) — Hours by day on an invoice.
-- Owner: "for hours for everyone we need it be by day and i enter their
-- work from and till."
--
-- One row per stint of work on an invoice: the day, from and till.  The
-- sheet's hours line (invoice_lines.category = 'labor') is no longer typed
-- in — its quantity is the sum of these rows and its amount hours × rate,
-- resynced by Invoice::syncLabor after every change.  Lighthouse's sheet
-- has no room for the day-by-day detail, so it stays on #invoices.

CREATE TABLE IF NOT EXISTS invoice_work_shifts (
  id         SERIAL PRIMARY KEY,
  invoice_id INT NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  work_date  DATE NOT NULL,
  start_at   TIME NOT NULL,
  end_at     TIME NOT NULL,
  note       TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (end_at > start_at)
);
CREATE INDEX IF NOT EXISTS invoice_work_shifts_invoice_idx ON invoice_work_shifts (invoice_id, work_date, start_at);
COMMENT ON TABLE invoice_work_shifts IS 'Day / from / till stints behind an invoice''s hours line (mig 469). Hours = end_at - start_at.';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'Invoices — hours by day hint', 'invoices', 'hours_hint', NULL,
       'Enter each day worked with from and till. The hours line on the sheet adds them up.',
       10, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'hours_hint');
