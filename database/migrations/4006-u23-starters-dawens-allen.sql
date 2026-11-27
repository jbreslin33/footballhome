-- 4006 U23 starters: Dawens Erolias (22756), Allen Morfoh II (22683) bench →
-- starter. Owner 11/27 "add dawens to u23 starters" · "add allen to u23
-- starters". (Gap number below the max.)
BEGIN;
UPDATE team_persons SET lineup_role_id = 1
 WHERE person_id IN (22756, 22683) AND removed_at IS NULL AND team_id = 957;
INSERT INTO schema_migrations (filename) VALUES ('4006-u23-starters-dawens-allen.sql') ON CONFLICT DO NOTHING;
COMMIT;
