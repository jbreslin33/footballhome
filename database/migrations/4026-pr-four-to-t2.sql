-- 4026 Puerto Rico: David Masi (3500), Lusayo Mwakatika (22298), Caleb Rojas
-- (3507), Josue David (13458) T3 Sub → T2 Starter/Sub (bench). Owner 11/27
-- "move masi, lusayo, caleb to starter sub and josue david". (Gap number.)
BEGIN;
UPDATE team_persons SET lineup_role_id = (SELECT id FROM lineup_roles WHERE name = 'bench')
 WHERE person_id IN (3500, 22298, 3507, 13458) AND removed_at IS NULL
   AND team_id = (SELECT id FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico');
INSERT INTO schema_migrations (filename) VALUES ('4026-pr-four-to-t2.sql') ON CONFLICT DO NOTHING;
COMMIT;
