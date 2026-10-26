-- 725 (2026-10-26) — Going but not on the league's roster: the player is
-- told right there and handed the form.  Owner: "a popup that says your
-- set going but not on liga 1 roster click here to fill out form so casa
-- can put you on official roster so you can play".
--
-- POST /api/calendar/rsvp, on a Going the player gives for THEMSELVES
-- (never a coach or parent answering for them), runs the Game Center gap
-- check (fh_event_registration_gaps, migs 638/645) and, when they are a
-- gap, returns reg_ask = {url, copy} — the league's form
-- (league_registration_forms → its {form:code} → club_forms).  Submitted
-- and waiting on the league (roster_statuses.player_done) gets the
-- waiting words and no form.  The Going always saves.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', v.l, 'reg_ask', v.t, NULL, v.b, v.o, true, false, false
  FROM (VALUES
    ('title',         'Going popup — title ({league})',
                      'You''re not on the {league} roster yet', 1000),
    ('body',          'Going popup — not on the roster ({league}, {when}, {opponent})',
                      'You''re set Going for {when} vs {opponent}, but you''re not on the {league} roster yet. Fill out the form so the club can get you on the official {league} roster — then you can play.', 1001),
    ('calldown_body', 'Going popup — call-down spots full ({league}, {when}, {opponent})',
                      'You''re set Going for {when} vs {opponent}, but both call-down spots are taken, so you need to be on the {league} roster to play. Fill out the form so the club can get you on it.', 1002),
    ('fill',          'Going popup — form button',
                      '📝 Fill out the form', 1003),
    ('later',         'Going popup — dismiss button',
                      'Later', 1004),
    ('waiting_title', 'Going popup — submitted title ({league})',
                      'Waiting on {league}', 1005),
    ('waiting_body',  'Going popup — submitted, waiting ({league}, {when}, {opponent})',
                      'You''re set Going for {when} vs {opponent}. Your registration is in — we''re waiting on {league} to put you on the official roster.', 1006),
    ('ok',            'Going popup — close button on the waiting card',
                      'OK', 1007)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'reg_ask' AND m.tier = v.t);
