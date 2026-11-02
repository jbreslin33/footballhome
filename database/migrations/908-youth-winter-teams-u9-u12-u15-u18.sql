-- 908 (2026-10-30) — Winter youth teams are U9, U12, U15, U18.
--
-- Owner 2026-10-30: "think u12 has to be a team", "try for winter u9, u12,
-- u15, u18".  Replaces the U10, U13, U16, U19 of mig 907.  Same four team
-- rows, so nothing else about them changes.  No winter team has an event, a
-- league list or a roster status yet, so every player just moves to the
-- smallest team that fits their age, the rule fh_youth_place already uses.
UPDATE teams SET name = 'U9',  label = '❄️ U9',  short_label = '❄️ U9'  WHERE id = 942;
UPDATE teams SET name = 'U12', label = '❄️ U12', short_label = '❄️ U12' WHERE id = 940;
UPDATE teams SET name = 'U15', label = '❄️ U15', short_label = '❄️ U15' WHERE id = 941;
UPDATE teams SET name = 'U18', label = '❄️ U18', short_label = '❄️ U18' WHERE id = 944;

UPDATE team_persons tp
   SET team_id = fit.id
  FROM persons p
  CROSS JOIN LATERAL (
    SELECT t.id FROM teams t
     WHERE t.id IN (940, 941, 942, 944)
       AND fh_team_age(t.id) >= fh_youth_single_age(p.birth_date,
             extract(year FROM now() AT TIME ZONE 'America/New_York')::int
             + CASE WHEN extract(month FROM now() AT TIME ZONE 'America/New_York') >= 6 THEN 1 ELSE 0 END)
     ORDER BY fh_team_age(t.id) LIMIT 1) fit
 WHERE p.id = tp.person_id
   AND tp.removed_at IS NULL
   AND tp.team_id IN (940, 941, 942, 944)
   AND tp.team_id <> fit.id;

DELETE FROM gcal_team_aliases WHERE team_id IN (940, 941, 942, 944) AND notes = 'mig 907';
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'boys', lower(name) || ' winter', id, 'mig 908' FROM teams WHERE id IN (940, 941, 942, 944)
ON CONFLICT DO NOTHING;
