-- 4012 Puerto Rico: Caleb Rojas (3507) depth → subs (lineup role 2). Owner
-- 11/27 "move caleb to subs". (Gap number.)
BEGIN;
UPDATE team_persons SET lineup_role_id = 2
 WHERE person_id = 3507 AND removed_at IS NULL
   AND team_id = (SELECT id FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico');
INSERT INTO schema_migrations (filename) VALUES ('4012-pr-caleb-to-subs.sql') ON CONFLICT DO NOTHING;
COMMIT;
