-- 538 (2026-10-07) — the per-player RSVP reminder, shorter and less robotic.
-- Owner: "the message to be shorter. maybe we leave out what rsvp is
-- missing? and just say your missing practice rsvps, or games and
-- practice or game rsvp depening on what they are missing? and list
-- total missing? i fear the message seems robotic. also for men just lmk
-- its a fine for missed rsvps. for youth parents we just say its
-- important for team to know who is available."
--
-- The adult / parent reminders (kind rsvp_reminder, mig 363) no longer
-- list the events.  The backend counts the open ones by kind and fills:
--   {missing}    "a game RSVP" / "3 practice RSVPs" / "3 RSVPs — a game and
--                2 practices", from tiers missing_games / missing_practices /
--                missing_both ({games} {games_s} {practices} {practices_s}
--                {total}; "a" for one, the number past that)
--   {deadline}   the first open game's RSVP deadline note (mig 507) for a
--                player, "" otherwise — its [[ ]] drops
--   {fine_note}  tier fine_note ({practice_fine} {game_fine}) for a player
--                whose section fines missed RSVPs (Men), "" otherwise
-- {events} is still handed over for any template that wants the list back.
-- The rules-and-fines-so-far block (kind rsvp_reminder_fines, 9/27) is
-- retired: its rows go inactive.  Group reminders are unchanged.

CREATE OR REPLACE FUNCTION pg_temp.set_rr(p_tier text, p_label text, p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  UPDATE message_templates SET body = p_body, subject = p_subject, label = p_label, sort_order = p_sort,
                               is_active = true, updated_at = now()
   WHERE kind = 'rsvp_reminder' AND tier = p_tier;
  IF NOT FOUND THEN
    INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
    VALUES ('RSVP', p_label, 'rsvp_reminder', p_tier, p_subject, p_body, p_sort, true, false, false);
  END IF;
END $$;

SELECT pg_temp.set_rr('adult', 'RSVP reminder — adult player ({first} {missing} {link} {deadline} {fine_note} {travel} {sender})',
  'Lighthouse 1893 — please set your availability',
E'Hi {first} — you''re missing {missing}. Going or Not Going, one tap: {link}[[\n\n{deadline}]][[\n\n{fine_note}]][[\n\n{travel}]]\n\n— {sender}, Lighthouse 1893', 10);

SELECT pg_temp.set_rr('parent', 'RSVP reminder — parent ({first} {child} {missing} {link} {deadline} {travel} {sender})',
  'Lighthouse 1893 — please set {child}''s availability',
E'Hi {first} — {child} is missing {missing}. It really helps the team to know who''s available. Going or Not Going, one tap: {link}[[\n\n{deadline}]][[\n\n{travel}]]\n\n— {sender}, Lighthouse 1893', 11);

SELECT pg_temp.set_rr('missing_games',     'What is missing — games only ({games} {games_s})',             NULL, '{games} game RSVP[[{games_s}]]', 60);
SELECT pg_temp.set_rr('missing_practices', 'What is missing — practices only ({practices} {practices_s})', NULL, '{practices} practice RSVP[[{practices_s}]]', 61);
SELECT pg_temp.set_rr('missing_both',      'What is missing — both ({total} {games} {games_s} {practices} {practices_s})', NULL,
  '{total} RSVPs — {games} game[[{games_s}]] and {practices} practice[[{practices_s}]]', 62);
SELECT pg_temp.set_rr('fine_note', 'Fine line — Men ({practice_fine} {game_fine})', NULL,
  'Heads up: a missed RSVP is a fine — {practice_fine} for a practice, {game_fine} for a game.', 63);

UPDATE message_templates SET is_active = false, updated_at = now()
 WHERE kind = 'rsvp_reminder_fines' AND is_active;
