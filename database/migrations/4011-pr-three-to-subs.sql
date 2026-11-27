-- 4011 Puerto Rico: David Masi (3500), Leo Santa (3511), Lusayo Mwakatika
-- (22298) starter → subs (lineup role 2). Owner 11/27 "move masi, leo,
-- lusayo to subs". (Gap number.)
BEGIN;
UPDATE team_persons SET lineup_role_id = 2
 WHERE person_id IN (3500, 3511, 22298) AND removed_at IS NULL
   AND team_id = (SELECT id FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico');
INSERT INTO schema_migrations (filename) VALUES ('4011-pr-three-to-subs.sql') ON CONFLICT DO NOTHING;
COMMIT;
