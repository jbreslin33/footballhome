-- 558 (2026-10-09) — league bodies as contact holders.
-- Owner: "i don't see opponent contacts and buttons to text or email them
-- individually or group. u8 travel vs ksc for instance."  The youth
-- opponent clubs have no contacts on file; what the league does publish
-- is its directors per age group (Philadelphia Parks & Recreation's
-- "League Directors" sheet).  A league body is a clubs row with
-- club_competitions rows of status 'league' (one per age group it runs,
-- league_label = fh_events.league, division_label = the age group) whose
-- club_contacts are the directors.  Game Center's 📇 panel shows them
-- under the opponent's own contacts, narrowed to the game's age group.
-- The directors themselves are loaded into the DB by hand, not here.
ALTER TABLE club_competitions DROP CONSTRAINT IF EXISTS club_competitions_status_check;
ALTER TABLE club_competitions ADD CONSTRAINT club_competitions_status_check
    CHECK (status = ANY (ARRAY['opponent'::text, 'prospect'::text, 'inactive'::text, 'league'::text]));
COMMENT ON COLUMN club_competitions.status IS 'opponent | prospect | inactive | league (mig 558: this clubs row IS the league body; its contacts are the league''s directors for division_label)';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Opponents', l, 'opponent', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('game_center_league', 'Game Center — league directors block title ({league})', '🏛 {league} league directors', 870),
    ('game_center_all_email', 'Game Center — email everyone in a block',             '✉️ Email all', 871),
    ('game_center_all_sms',   'Game Center — text everyone in a block',              '💬 Text all', 872)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'opponent' AND m.tier = v.t);
