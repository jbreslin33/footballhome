-- 4017 U23: Oumar Barry (3487) depth → subs; Aboubacar Bayo II (3488) depth →
-- starter. Owner 11/27 "add barry to subs" · "add bay to starters". (Gap number.)
BEGIN;
UPDATE team_persons SET lineup_role_id = 2 WHERE person_id = 3487 AND removed_at IS NULL AND team_id = 957;
UPDATE team_persons SET lineup_role_id = 1 WHERE person_id = 3488 AND removed_at IS NULL AND team_id = 957;
INSERT INTO schema_migrations (filename) VALUES ('4017-u23-barry-subs-bayo-starter.sql') ON CONFLICT DO NOTHING;
COMMIT;
