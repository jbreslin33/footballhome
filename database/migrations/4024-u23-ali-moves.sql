-- 4024 U23: Ali Salah Alshami (3509) T1 → T2 Starter/Sub (bench); Ali Kol
-- (22688) T2 → T3 Sub (sub_late). Owner 11/27 "move salah to starter/sub move
-- ali kol to subs". (Gap number.)
BEGIN;
UPDATE team_persons SET lineup_role_id = (SELECT id FROM lineup_roles WHERE name = 'bench')
 WHERE person_id = 3509 AND removed_at IS NULL AND team_id = 957;
UPDATE team_persons SET lineup_role_id = (SELECT id FROM lineup_roles WHERE name = 'sub_late')
 WHERE person_id = 22688 AND removed_at IS NULL AND team_id = 957;
INSERT INTO schema_migrations (filename) VALUES ('4024-u23-ali-moves.sql') ON CONFLICT DO NOTHING;
COMMIT;
