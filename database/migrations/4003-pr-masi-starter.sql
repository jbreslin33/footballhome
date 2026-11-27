-- 4003 Puerto Rico: David Masi (3500) bench → starter. Owner 11/27 "add masi
-- to pr starters". lineup_roles 1 = starter. (Gap number below the max.)
BEGIN;
UPDATE team_persons SET lineup_role_id = 1
 WHERE person_id = 3500 AND removed_at IS NULL
   AND team_id = (SELECT id FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico');
INSERT INTO schema_migrations (filename) VALUES ('4003-pr-masi-starter.sql') ON CONFLICT DO NOTHING;
COMMIT;
