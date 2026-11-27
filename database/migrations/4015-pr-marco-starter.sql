-- 4015 Puerto Rico: Marco Delgado (3492) depth → starter (lineup role 1).
-- Owner 11/27 "move marco to starters". (Gap number.)
BEGIN;
UPDATE team_persons SET lineup_role_id = 1
 WHERE person_id = 3492 AND removed_at IS NULL
   AND team_id = (SELECT id FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico');
INSERT INTO schema_migrations (filename) VALUES ('4015-pr-marco-starter.sql') ON CONFLICT DO NOTHING;
COMMIT;
