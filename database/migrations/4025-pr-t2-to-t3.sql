-- 4025 Puerto Rico: every T2 Starter/Sub (bench) → T3 Sub (sub_late). Owner
-- 11/27 "move all starter/sub from pr to subs". (Gap number.)
BEGIN;
UPDATE team_persons SET lineup_role_id = (SELECT id FROM lineup_roles WHERE name = 'sub_late')
 WHERE removed_at IS NULL
   AND lineup_role_id = (SELECT id FROM lineup_roles WHERE name = 'bench')
   AND team_id = (SELECT id FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico');
INSERT INTO schema_migrations (filename) VALUES ('4025-pr-t2-to-t3.sql') ON CONFLICT DO NOTHING;
COMMIT;
