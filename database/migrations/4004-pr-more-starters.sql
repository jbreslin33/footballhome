-- 4004 Puerto Rico starters: Lusayo Mwakatika (22298), Leo Santa (3511),
-- Som Safavi (10878) bench → starter. Owner 11/27 "add lusayo to starters pr
-- and leo" · "add som to pr starters". (Gap number below the max.)
BEGIN;
UPDATE team_persons SET lineup_role_id = 1
 WHERE person_id IN (22298, 3511, 10878) AND removed_at IS NULL
   AND team_id = (SELECT id FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico');
INSERT INTO schema_migrations (filename) VALUES ('4004-pr-more-starters.sql') ON CONFLICT DO NOTHING;
COMMIT;
