-- 1046: winter youth = U10 and U12 only (owner 2026-11-04: "retire the
-- winter u18 team too", "winter we want u12 and u10").
--   • U9 (942) is renamed U10 (name/label — fh_team_age reads the name, so
--     it now takes ages ≤ 10); calendar tag "u10 winter" added, "u9 winter"
--     kept.
--   • U15 (941) and U18 (944) retired: coach rows end (James, who also
--     coaches U10/U12), their tags point at U12 (940), is_active = false.
--     No events link to either.
--   • Every winter kid is re-placed by the age rule (US Club Soccer 2026-27
--     chart, mig 1044; no winter team has a league list): ≤ 10 → U10,
--     11 and up → U12.

BEGIN;

UPDATE teams SET name = 'U10', label = '❄️ U10', short_label = '❄️ U10' WHERE id = 942;
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'boys', 'u10 winter', 942, 'mig 1046'
 WHERE NOT EXISTS (SELECT 1 FROM gcal_team_aliases WHERE club_alias = 'boys' AND team_alias = 'u10 winter');

UPDATE team_coaches SET ended_at = now() WHERE team_id IN (941, 944) AND ended_at IS NULL;
UPDATE gcal_team_aliases SET team_id = 940, notes = COALESCE(notes, '') || ' · retired → U12 (mig 1046)' WHERE team_id IN (941, 944);
UPDATE teams SET is_active = false WHERE id IN (941, 944);

-- Re-place every winter kid on his fit team.
CREATE TEMP TABLE winter_moves ON COMMIT DROP AS
SELECT tp.id AS tp_id, tp.person_id, tp.roster_status_id,
       fh_youth_fit_team(fh_youth_us_age(p.birth_date), 'winter') AS to_team, tp.team_id AS from_team
  FROM team_persons tp
  JOIN team_terms tt ON tt.team_id = tp.team_id AND tt.term = 'winter'
  JOIN teams t ON t.id = tp.team_id AND t.gender_category IN ('boys', 'girls') AND t.name ~ '^U[0-9]+$'
  JOIN persons p ON p.id = tp.person_id AND p.birth_date IS NOT NULL
 WHERE tp.removed_at IS NULL AND tp.team_id IN (940, 941, 942, 944);
DELETE FROM winter_moves WHERE to_team IS NULL OR to_team = from_team;

UPDATE team_persons tp SET removed_at = now(), removed_reason = 'board_move',
       removed_details = jsonb_build_object('to_team_id', m.to_team, 'mig', 1046, 'why', 'winter = U10 + U12')
  FROM winter_moves m WHERE tp.id = m.tp_id;

INSERT INTO team_persons (team_id, person_id, roster_status_id)
SELECT DISTINCT m.to_team, m.person_id, m.roster_status_id FROM winter_moves m
 WHERE NOT EXISTS (SELECT 1 FROM team_persons x WHERE x.team_id = m.to_team AND x.person_id = m.person_id AND x.removed_at IS NULL);

COMMIT;
