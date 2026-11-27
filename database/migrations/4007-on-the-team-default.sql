-- 4007 "On the team" is the default. Owner 11/27: "if a player is not listed
-- as starters or bench then they are just 'on the team'". U23 (957) and
-- Puerto Rico had everyone not named a starter defaulted to bench (mig 5001)
-- — nobody was actually named bench, so those go back to no role; the
-- team-card segment for no role reads "On the team" (was "No role yet").
-- (Gap number below the max.)
BEGIN;
UPDATE team_persons SET lineup_role_id = NULL
 WHERE lineup_role_id = 2 AND removed_at IS NULL
   AND team_id IN (957, (SELECT id FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico'));
UPDATE message_templates SET body = 'On the team', label = '#teams team card: segment header — no lineup role (just on the team)'
 WHERE kind = 'roster_sheet' AND tier = 'tc_seg_none';
INSERT INTO schema_migrations (filename) VALUES ('4007-on-the-team-default.sql') ON CONFLICT DO NOTHING;
COMMIT;
