-- 520 (2026-10-05) — CASA: chase the scores that are not in yet.
-- Owner: "the objective is to get all scores in by sunday night or monday
-- morning … treat it like the not rsvp yet function for lighthouse players.
-- on fh every time i open results page … it should check casa website for
-- scores as source of truth on what is in. then it should for each game
-- have a text and email button to request the score from the manager …
-- each manager or person should have its own button on the game card and
-- option to tag the person as main one to ask for score or message all too
-- or just one".
--
-- #casa-scores (hub tile "Scores to chase"): every open pulls the league's
-- SportsEngine feed (mig 488), then lists the games that have kicked off
-- and still carry no score, each with its two teams' managers — a Text and
-- an Email button per person, "all" per team, and a ★ for the one to ask
-- first.  Every ask is logged against the game, so the card says how often
-- and when it was chased.
--
--   club_contacts.score_role            'main' = the one to ask first for that
--                                       team, 'manager' = also on the game card
--   club_contact_messages.league_fixture_id   the game an ask was about
--   league_fixture_sources.score_due_after_minutes   how long after kick-off a
--                                       game without a score counts as missing;
--                                       NULL = that feed carries no scores
--                                       (the APSL iCal), nothing is chased
ALTER TABLE club_contacts ADD COLUMN IF NOT EXISTS score_role TEXT;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'club_contacts_score_role_check') THEN
    ALTER TABLE club_contacts ADD CONSTRAINT club_contacts_score_role_check CHECK (score_role IN ('main', 'manager'));
  END IF;
END $$;
COMMENT ON COLUMN club_contacts.score_role IS 'League score chasing (mig 520): main = ask this person first for the team''s score, manager = also listed on the game card; NULL = not a score contact.';

ALTER TABLE club_contact_messages ADD COLUMN IF NOT EXISTS league_fixture_id INTEGER REFERENCES league_fixtures(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS club_contact_messages_fixture_idx ON club_contact_messages (league_fixture_id) WHERE league_fixture_id IS NOT NULL;

ALTER TABLE league_fixture_sources ADD COLUMN IF NOT EXISTS score_due_after_minutes INTEGER;
COMMENT ON COLUMN league_fixture_sources.score_due_after_minutes IS 'Minutes after kick-off when a game still without a score is listed on the score chase (mig 520); NULL = this feed has no scores.';
UPDATE league_fixture_sources SET score_due_after_minutes = 120 WHERE system = 'sportsengine' AND score_due_after_minutes IS NULL;

-- ── Team managers ────────────────────────────────────────────────────────
-- The managers themselves (names, phones, emails) are NOT in this file: they
-- were read on 2026-10-05 from the league's SportsEngine team registration
-- "PHL 11v11 Select - 2026-27" and loaded straight into club_contacts
-- (source 'casa-registration', or completing a row already on file), the
-- registrant tagged main and the second contact manager.  Personal contact
-- details live in the database and are edited on #casa-contacts /
-- #casa-scores, not in git.

-- ── Copy, kind 'casa' (mig 486 pattern) ──────────────────────────────────
-- Tokens of the two score_request rows: {contact_first} {sender} {home}
-- {away} {division} {date} {from_email}.  To several people at once
-- {contact_first} is "all".
CREATE OR REPLACE FUNCTION pg_temp.casa_tpl(p_tier text, p_label text, p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'CASA', p_label, 'casa', p_tier, p_subject, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'casa' AND tier = p_tier);
$$;
SELECT pg_temp.casa_tpl('tile_scores',       'CASA hub — tile: scores to chase', 'Scores to chase', 'Games already played with no score on the league site — text or email the managers', 4);
SELECT pg_temp.casa_tpl('scores_title',      'CASA scores — title',              NULL, 'CASA scores to chase', 30);
SELECT pg_temp.casa_tpl('scores_subtitle',   'CASA scores — subtitle',           NULL, 'Checked against SportsEngine {when}. {n} game(s) played with no score yet.', 31);
SELECT pg_temp.casa_tpl('scores_waiting',    'CASA scores — heading: missing',   NULL, 'Waiting on a score', 32);
SELECT pg_temp.casa_tpl('scores_none',       'CASA scores — nothing missing',    NULL, 'Every game played so far has its score on the league site.', 33);
SELECT pg_temp.casa_tpl('scores_in',         'CASA scores — heading: in',        NULL, 'Scores in', 34);
SELECT pg_temp.casa_tpl('scores_ours',       'CASA scores — our own team',       NULL, 'Our team — enter this one on the league site.', 35);
SELECT pg_temp.casa_tpl('scores_no_contact', 'CASA scores — team has nobody',    NULL, 'Nobody tagged for scores yet — pick someone below or add a contact.', 36);
SELECT pg_temp.casa_tpl('scores_hint',       'CASA scores — how it works',       NULL, '★ is the one to ask first. Each tap opens your phone or Gmail with the message filled in and is counted on the game.', 37);
SELECT pg_temp.casa_tpl('scores_asked',      'CASA scores — asked tally',        NULL, 'Asked {n}× · last {when}', 38);
SELECT pg_temp.casa_tpl('score_request',     'CASA — score request (email)',     'CASA Select {division} — score needed: {home} v {away}',
'Hi {contact_first},

{sender} here, CASA Select Philadelphia commissioner. We do not have the score yet for {home} v {away} ({division}, {date}). Can you reply with the final score?

Thanks,
{sender}
{from_email}', 39);
SELECT pg_temp.casa_tpl('score_request_sms', 'CASA — score request (text)',      NULL,
'Hi {contact_first}, {sender} from CASA Select here. We still need the score for {home} v {away} on {date}. Can you text me the final score? Thanks', 40);
