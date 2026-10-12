-- 571 (2026-10-12) — #invoices: reality check from gcal on every load.
-- Owner: "we need to reality check from gcal on every load."
--
-- Code side (same commit, Invoice::realityCheck, run by GET /api/invoices/:id
-- on the admin path only): every time a DRAFT sheet is opened, its
-- event-backed day rows are held against the calendar as it is now — a row
-- whose gcal event has been cancelled or deleted comes off (the hours line
-- resyncs), and a row whose event moved is re-dated to the new start,
-- keeping its length.  Hand-typed rows and the usual week are never
-- touched; a final (sent) sheet is left exactly as it was sent.  These two
-- rows are the notice the page flashes when something changed.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Invoices', l, 'invoices', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('reality_removed', 'Invoices — days removed, event cancelled on the calendar',
     '{n} day(s) came off — cancelled on the calendar: {list}', 770),
    ('reality_moved',   'Invoices — days re-dated, event moved on the calendar',
     '{n} day(s) moved to match the calendar: {list}', 771)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'invoices' AND m.tier = v.t);
