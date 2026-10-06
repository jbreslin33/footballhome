-- 531 (2026-10-06) — #invoices: a coach's games come off the calendar.
-- Owner: "we are missing youth games that were played. u12 parkwood game
-- on sunday def" (the 10/4 U12 Travel game at Parkwood was not on the
-- hours-by-day invoice; the usual week has no Sundays).  Every game in
-- the period of a team the issuer coaches (team_coaches) — or whose
-- coaching policy names them (coach_issuer_id, mig 500) — is listed under
-- the days with a tick, played ones ticked; the policy's hours_per_game
-- make the till, else the calendar length.  A new invoice adds the
-- policy-paid games by itself.  A day row remembers its game so it is
-- never added twice.
ALTER TABLE invoice_work_shifts ADD COLUMN IF NOT EXISTS fh_event_id BIGINT REFERENCES fh_events(id) ON DELETE SET NULL;
COMMENT ON COLUMN invoice_work_shifts.fh_event_id IS 'The calendar game this day row came from (mig 531); NULL = typed by hand or the usual week.';
CREATE UNIQUE INDEX IF NOT EXISTS invoice_work_shifts_event_uq ON invoice_work_shifts (invoice_id, fh_event_id) WHERE fh_event_id IS NOT NULL;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Invoices', l, 'invoices', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('games_title',  'Invoices — games block title',          'Games on the calendar', 760),
    ('games_hint',   'Invoices — games block hint',           'Games in this period of a team you coach. Tick the ones you worked and add them as days — kick-off to the coaching hours for that league, or the calendar length.', 761),
    ('games_button', 'Invoices — add games button ({n})',     '🏟 Add {n} game(s) as days', 762),
    ('games_empty',  'Invoices — no games waiting',           'No games of yours in this period that are not already on the days.', 763),
    ('games_added',  'Invoices — games added ({n})',          '{n} game(s) added to the days.', 764)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'invoices' AND m.tier = v.t);
