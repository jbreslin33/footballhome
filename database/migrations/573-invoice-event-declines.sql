-- 573 (2026-10-12) — #invoices: every event answers ✓ worked / ✗ didn't.
-- Owner: "its very confusing still. too many ambiguous things. don't show
-- total of a day unless the box for an event is checked. if not it should
-- show 0 for day. allow each practice or game to be checked attended or
-- not as coach."
--
-- Each calendar row on a sheet now carries two marks: ✓ worked it as coach
-- (bills the hours — the invoice_work_shifts row) and ✗ did not (this
-- table).  An RSVP no shows as ✗ by itself; a stored ✗ covers the no-RSVP
-- rows.  Hours print as 0 until a row is ✓, and a day with nothing ✓
-- totals 0.  POST /api/invoices/:id/event-mark {fh_event_id, mark} with
-- mark = worked | no | clear.
CREATE TABLE IF NOT EXISTS invoice_event_declines (
  invoice_id  INT    NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  fh_event_id BIGINT NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (invoice_id, fh_event_id)
);
COMMENT ON TABLE invoice_event_declines IS 'Events the issuer marked ✗ — did not work as coach — on a sheet''s calendar breakdown (mig 573).';

UPDATE message_templates SET body = 'For each practice or game: ✓ you worked it as coach — its hours go on the sheet — or ✗ you did not. A day counts 0 until something is ✓. Tap ✏️ on a ✓ row to adjust the times if someone was late or stayed on.'
 WHERE kind = 'invoices' AND tier = 'games_hint';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Invoices', l, 'invoices', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('mark_yes_tip', 'Invoices — ✓ button tooltip', 'Worked this as coach — bill its hours', 774),
    ('mark_no_tip',  'Invoices — ✗ button tooltip', 'Did not work this',                    775)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'invoices' AND m.tier = v.t);
