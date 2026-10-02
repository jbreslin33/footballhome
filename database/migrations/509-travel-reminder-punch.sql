-- 509 (2026-10-02) — RSVP reminders: shorter, and a line for travel games.
--
-- Owner: "We need a little punch for travel team reminders to rsvp to
-- games … can we change message to say that travel spots carry extra
-- responsibilty and in general we need the messsage shorter lol. but stil
-- say what they have not set availabilty for."  (U8 was one short of 7
-- for a 7v7 game with two families silent.)
--
--   teams.is_travel            a selected travel squad (mig 306 split the
--                              boys board into Travel and Intramural but
--                              only the team NAME said which was which)
--   fh_is_travel_game(event)   a game tagged to a travel team
--   rsvp_reminder / travel     the line itself; the backend hands it to
--                              the reminder as {travel} only when the list
--                              of unanswered events holds a travel game,
--                              so its [[ ]] drops everywhere else
--
-- Every reminder body is rewritten shorter.  Nothing is dropped: the list
-- of unanswered events, the link, "you can change it later", the Men's
-- team rule and fines block, and the deadline line under each game.

ALTER TABLE teams ADD COLUMN IF NOT EXISTS is_travel boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN teams.is_travel IS
  'A selected travel squad, as opposed to the house (intramural) programme (mig 509). Read by fh_is_travel_game().';

UPDATE teams SET is_travel = true WHERE id IN (912, 913, 914) AND NOT is_travel;   -- U8 / U10 / U12 Travel

CREATE OR REPLACE FUNCTION fh_is_travel_game(p_fh_event_id bigint)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT EXISTS (
    SELECT 1
      FROM fh_events fe
      JOIN fh_event_teams fet ON fet.fh_event_id = fe.id
      JOIN teams t ON t.id = fet.team_id
     WHERE fe.id = p_fh_event_id AND fe.kind = 'match' AND t.is_travel)
$$;
COMMENT ON FUNCTION fh_is_travel_game(bigint) IS
  'True when the event is a game of a travel team (teams.is_travel, mig 509) — its RSVP reminder carries the rsvp_reminder / travel line.';

-- ── The travel line ──────────────────────────────────────────────────
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'RSVP', 'RSVP reminder — travel game line', 'rsvp_reminder', 'travel', NULL,
       'A travel spot carries extra responsibility — we can''t field a team without every answer.', 24
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder' AND tier = 'travel');

-- ── Shorter bodies ───────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION pg_temp.set_reminder(p_tier text, p_body text)
RETURNS void LANGUAGE sql AS $$
  UPDATE message_templates SET body = p_body, updated_at = now()
   WHERE kind = 'rsvp_reminder' AND tier = p_tier AND is_active AND body IS DISTINCT FROM p_body;
$$;

-- One player, magic link.
SELECT pg_temp.set_reminder('parent',
E'Hi {first} — {child} still has no answer for:\n{events}[[\n\n{travel}]]\n\nGoing or Not Going, one tap (you can change it later): {link}\n\n— {sender}, Lighthouse 1893');
SELECT pg_temp.set_reminder('adult',
E'Hi {first} — you still have no answer for:\n{events}[[\n\n{travel}]]\n\nGoing or Not Going, one tap (you can change it later): {link}\n\nAnswering every event is a team rule.[[\n\n{fines}]]\n\n— {sender}, Lighthouse 1893');

-- One event, everyone who has not answered it, no link.
SELECT pg_temp.set_reminder('group_parent',
E'Hi all — your player still has no answer for:\n• {event}[[\n\n{travel}]]\n\nGoing or Not Going at https://footballhome.org — you can change it later.\n\n— {sender}, Lighthouse 1893');
SELECT pg_temp.set_reminder('group_adult',
E'Hi all — you still have no answer for:\n• {event}[[\n\n{travel}]]\n\nGoing or Not Going at https://footballhome.org — you can change it later. Answering every event is a team rule.\n\n— {sender}, Lighthouse 1893');

-- The game's unanswered players, their whole week listed.
SELECT pg_temp.set_reminder('group_week_parent',
E'Hi all — your player has no answer for the game yet. Please answer any of these you haven''t:\n{events}[[\n\n{travel}]]\n\nGoing or Not Going at https://footballhome.org — you can change it later.\n\n— {sender}, Lighthouse 1893');
SELECT pg_temp.set_reminder('group_week_adult',
E'Hi all — you have no answer for the game yet. Please answer any of these you haven''t:\n{events}[[\n\n{travel}]]\n\nGoing or Not Going at https://footballhome.org — you can change it later. Answering every event is a team rule.\n\n— {sender}, Lighthouse 1893');

-- The deadline line under a game (mig 507/508).
SELECT pg_temp.set_reminder('deadline',              'Due {day} midnight to be eligible to start.');
SELECT pg_temp.set_reminder('deadline_passed',       'Was due {day} midnight to be eligible to start — please still answer.');
SELECT pg_temp.set_reminder('deadline_plain',        'Due {day} midnight.');
SELECT pg_temp.set_reminder('deadline_plain_passed', 'Was due {day} midnight — please answer now.');
