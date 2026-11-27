-- 4014 Puerto Rico: Josue David (13458) depth → subs (lineup role 2). Owner
-- 11/27 "move josue to sub". (Gap number.)
BEGIN;
UPDATE team_persons SET lineup_role_id = 2
 WHERE person_id = 13458 AND removed_at IS NULL
   AND team_id = (SELECT id FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico');
INSERT INTO schema_migrations (filename) VALUES ('4014-pr-josue-to-subs.sql') ON CONFLICT DO NOTHING;
COMMIT;
