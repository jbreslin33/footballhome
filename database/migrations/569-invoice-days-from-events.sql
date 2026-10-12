-- 569 (2026-10-12) — #invoices: per-coach event check-off, practices included.
-- Owner: get the invoices done for James, Luke and Anthony — per-coach event
-- check-off incl. practices, ticks prefilled from the coach's own RSVPs.
--
-- The mig-531 "Games on the calendar" block becomes "On the calendar": every
-- match AND practice in the period of a team the issuer coaches, each row
-- carrying the issuer's own RSVP (fh_event_rsvps).  Ticks are prefilled from
-- RSVP = yes.  The u16+ evening practices tag only the mens teams, so Luke
-- and Anthony — players there, not paid coaches — never see them listed.
--
-- days_source says where a NEW invoice's day rows come from:
--   week    the usual 2 weeks (invoice_default_shifts, mig 470) + the
--           policy-paid games (mig 531) — James, whose hours are the fixed
--           manager week.
--   events  the issuer's RSVP-yes practices and games in the period, plus
--           policy-paid games — Luke and Anthony, whose real weeks swing
--           with who covered which session (Luke skipped 10/2 and 10/7,
--           Anthony covered; the usual week gets that wrong).
ALTER TABLE invoice_issuers ADD COLUMN IF NOT EXISTS days_source TEXT NOT NULL DEFAULT 'week'
  CHECK (days_source IN ('week', 'events'));
COMMENT ON COLUMN invoice_issuers.days_source IS 'Where a new invoice''s day rows come from (mig 569): week = usual 2 weeks + policy games; events = the issuer''s RSVP-yes practices and games.';

UPDATE invoice_issuers SET days_source = 'events' WHERE person_id IN (3463, 22397);  -- Luke, Anthony

-- Owner (same day): "i should not even have to hit new invoice right? it
-- should auto make them but be editable."  Opening the board creates the
-- missing drafts itself — the previous and the current pay period, for every
-- issuer flagged here, whenever that period number is past the issuer's
-- latest.  Jamie stays off the flag: her last invoice is 2026.11 and
-- auto-drafting her usual week would bill Sundays nobody confirmed.
ALTER TABLE invoice_issuers ADD COLUMN IF NOT EXISTS auto_create BOOLEAN NOT NULL DEFAULT false;
COMMENT ON COLUMN invoice_issuers.auto_create IS 'Opening #invoices creates this issuer''s missing drafts for the previous + current pay period (mig 569).';

UPDATE invoice_issuers SET auto_create = true WHERE person_id IN (1, 3463, 22397);  -- James, Luke, Anthony

-- ── Copy: the block now holds practices too, ticks follow RSVPs ────────────
UPDATE message_templates SET body = 'Biweekly invoices to The Lighthouse, Inc. Drafts make themselves each period — check the days, fix the dates or number on the row, print or email.'
 WHERE kind = 'invoices' AND tier = 'subtitle';

UPDATE message_templates SET body = 'On the calendar'
 WHERE kind = 'invoices' AND tier = 'games_title';
UPDATE message_templates SET body = 'Practices and games in this period of a team you coach, with your RSVP. Tick the ones you worked and add them as days — kick-off to the coaching hours for that league (games), or the calendar length.'
 WHERE kind = 'invoices' AND tier = 'games_hint';
UPDATE message_templates SET body = '📅 Add {n} as days'
 WHERE kind = 'invoices' AND tier = 'games_button';
UPDATE message_templates SET body = 'Nothing of yours in this period that is not already on the days.'
 WHERE kind = 'invoices' AND tier = 'games_empty';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Invoices', l, 'invoices', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('games_rsvp_yes',  'Invoices — event row, issuer RSVP’d yes',  '✓ yes',    765),
    ('games_rsvp_no',   'Invoices — event row, issuer RSVP’d no',   '✗ no',     766),
    ('games_rsvp_none', 'Invoices — event row, no RSVP',            'no RSVP',  767),
    ('days_hint_events','Invoices — issuer whose days come from events',
     'New invoices build their days from {name}’s RSVP-yes practices and games in the period, not the usual week.', 768)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'invoices' AND m.tier = v.t);
