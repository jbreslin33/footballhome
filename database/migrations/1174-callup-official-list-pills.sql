-- 1174 (2026-11-07) — 🎟 Call-ups: "Everyone" vs "<team> official" pills.
-- Owner: "there are too many players for call up for u10. OR atleast i
-- need to know which ones are on the u8 roster official so i know they
-- are eligible. i am fine with showing 'everyone' u10 and under but need
-- a pill to show 'U8 Official' etc … same with all teams that have call
-- up functionality."
--
-- Code: GET /calendar/events/:id/invites gives each candidate (and each
-- invite) official_lists = the teams whose active official roster source
-- (official_roster_sources + matched official_roster_names — league list
-- or the club's league file) carries that person.  game-center.js shows
-- one pill per list that has someone in the panel, plus Everyone (default).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', 'Call-up panel — pill: every eligible player', 'callup_panel', 'pill_everyone',
       NULL, 'Everyone', 1002, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'callup_panel' AND m.tier = 'pill_everyone');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', 'Call-up panel — pill: on a team''s official roster ({team})', 'callup_panel', 'pill_official',
       NULL, '{team} Official', 1003, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'callup_panel' AND m.tier = 'pill_official');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', 'Call-up panel — chip on a name that is on an official roster ({team})', 'callup_panel', 'official_chip',
       NULL, '✓ {team} official', 1004, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'callup_panel' AND m.tier = 'official_chip');

-- Which official rosters carry this person: [{team_id, team}], or NULL.
-- team = the team's label without its emoji (U8, APSL, Liga 1, APSL
-- Reserves), not the long club name.
CREATE OR REPLACE FUNCTION fh_person_official_lists(p_person_id INT)
RETURNS jsonb LANGUAGE sql STABLE AS $$
    SELECT jsonb_agg(jsonb_build_object('team_id', t.id, 'team',
             COALESCE(NULLIF(trim(regexp_replace(COALESCE(t.label, ''), '^[^[:alnum:]]+', '')), ''), t.name)) ORDER BY t.id)
      FROM teams t
     WHERE EXISTS (SELECT 1 FROM official_roster_sources s
                     JOIN official_roster_names n ON n.source_id = s.id
                    WHERE s.is_active AND s.team_id = t.id AND n.person_id = p_person_id)
$$;
COMMENT ON FUNCTION fh_person_official_lists(INT) IS 'mig 1174: teams whose active official roster source (league list or club league file) has this person matched — the 🎟 Call-ups "<team> Official" pills.';
