-- 4018 U23 subs: Brian Ramos-Leiva (22427), Ali Kol (22688 — the depth Ali;
-- Ali Salah Alshami is a starter), Jose Castillo (22487), Jadon Hewitt
-- (22257) depth → subs. Owner 11/27 "add brian to subs add ali to subs add
-- jose castillo to subs" · "add jadon to subs". (Gap number.)
BEGIN;
UPDATE team_persons SET lineup_role_id = 2
 WHERE person_id IN (22427, 22688, 22487, 22257) AND removed_at IS NULL AND team_id = 957;
INSERT INTO schema_migrations (filename) VALUES ('4018-u23-four-more-subs.sql') ON CONFLICT DO NOTHING;
COMMIT;
