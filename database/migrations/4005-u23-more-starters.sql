-- 4005 U23 starters: Issiaga Soumah (14496), Asif Nifaz (22796), Dylan
-- Martinez (22311) bench → starter. Owner 11/27 "add soumah to u23 starters"
-- · "add asif to u23 starters" · "add dylan martinez to u23 starters".
-- (Gap number below the max.)
BEGIN;
UPDATE team_persons SET lineup_role_id = 1
 WHERE person_id IN (14496, 22796, 22311) AND removed_at IS NULL AND team_id = 957;
INSERT INTO schema_migrations (filename) VALUES ('4005-u23-more-starters.sql') ON CONFLICT DO NOTHING;
COMMIT;
