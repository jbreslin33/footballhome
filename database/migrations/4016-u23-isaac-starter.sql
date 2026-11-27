-- 4016 U23: Isaac Anderson depth → starter (lineup role 1). Owner 11/27
-- "move issac to starter for u23". (Gap number.)
BEGIN;
UPDATE team_persons SET lineup_role_id = 1
 WHERE person_id = (SELECT id FROM persons WHERE first_name = 'Isaac' AND last_name = 'Anderson')
   AND removed_at IS NULL AND team_id = 957;
INSERT INTO schema_migrations (filename) VALUES ('4016-u23-isaac-starter.sql') ON CONFLICT DO NOTHING;
COMMIT;
