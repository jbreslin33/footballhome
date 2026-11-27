-- 2901 Anthony Acevedo (person 22397) → U23. FH had no birth date for him, so
-- mig 2251 sorted him to Puerto Rico; LeagueApps shows him U21. Owner 11/27
-- "why is acevedo in pr?". Ends his Puerto Rico row, adds U23; he stays on
-- Liga 1. (His birth date is filled in the DB from LeagueApps, not here —
-- personal data stays out of git.)
BEGIN;
UPDATE team_persons SET removed_at = now(), removed_reason = 'moved to U23 — LeagueApps age U21 (mig 2901)'
 WHERE person_id = 22397 AND removed_at IS NULL
   AND team_id = (SELECT id FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico');
INSERT INTO team_persons (team_id, person_id, roster_status_id)
SELECT 957, 22397, 1
 WHERE NOT EXISTS (SELECT 1 FROM team_persons WHERE team_id = 957 AND person_id = 22397 AND removed_at IS NULL);
INSERT INTO schema_migrations (filename) VALUES ('2901-acevedo-to-u23.sql') ON CONFLICT DO NOTHING;
COMMIT;
