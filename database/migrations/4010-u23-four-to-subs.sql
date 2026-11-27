-- 4010 U23: Asif Nifaz (22796), Dawens Erolias (22756), Allen Morfoh II
-- (22683), Dylan Martinez (22311) starter → subs (lineup role 2 = bench/subs).
-- Owner 11/27 "move asif, dawens, allen, dylan to subs". (Gap number.)
BEGIN;
UPDATE team_persons SET lineup_role_id = 2
 WHERE person_id IN (22796, 22756, 22683, 22311) AND removed_at IS NULL AND team_id = 957;
INSERT INTO schema_migrations (filename) VALUES ('4010-u23-four-to-subs.sql') ON CONFLICT DO NOTHING;
COMMIT;
