-- 4022 U23: the T2 Starter/Subs other than Ali Kol → T3 Sub (lineup role
-- sub_late): Asif Nifaz, Dawens Erolias, Allen Morfoh II, Dylan Martinez,
-- Oumar Barry, Brian Ramos-Leiva, Jose Castillo, Jadon Hewitt. Owner 11/27
-- "move ali to starter/sub. move the other starter/subs on u23 to subs".
-- (Gap number.)
BEGIN;
UPDATE team_persons SET lineup_role_id = (SELECT id FROM lineup_roles WHERE name = 'sub_late')
 WHERE team_id = 957 AND removed_at IS NULL
   AND person_id IN (22796, 22756, 22683, 22311, 3487, 22427, 22487, 22257);
INSERT INTO schema_migrations (filename) VALUES ('4022-u23-t2-to-t3.sql') ON CONFLICT DO NOTHING;
COMMIT;
