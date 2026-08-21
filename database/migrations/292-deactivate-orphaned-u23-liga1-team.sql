-- 292 — Deactivate team 461 (Lighthouse Boys Club U23 Liga 1), clear its
-- stale team_persons rows.
--
-- Owner report (2026-08-21): "why is Lighthouse Boys Club U23 Liga 1
-- showing as a team players are on in addition to the one whose col
-- they are in. that is not an active team and if it is it should not
-- be!" — the "also on" card badge (ActiveTeamBadges.cpp) queries
-- team_persons JOIN teams WHERE t.is_active = true, and team 461 was
-- still flagged active despite having:
--   - no team_membership_requirements row (already flagged as a gap in
--     migration 268's comment — "Liga 1 U23 (461)... never got swept")
--   - no gcal_team_aliases, team_roster_sources, or
--     team_eligible_genders row — completely unwired from every other
--     feature
--   - 7 active team_persons rows, every one dated joined_at =
--     1970-01-01 (Unix epoch) — a migration artifact, not a real
--     assignment anyone made
--
-- Fix: flip is_active off (stops the badge immediately — the backend
-- query already filters on it) and close out the 7 garbage rows so no
-- future feature can resurface this stale data by trusting
-- team_persons without also checking is_active.

BEGIN;

UPDATE team_persons
   SET removed_at      = NOW(),
       removed_reason  = 'stale_epoch_row_orphaned_team',
       removed_details = jsonb_build_object(
           'note', 'Migration 292: team 461 deactivated — team_persons row had joined_at=1970-01-01, no team_membership_requirements gate, unwired from gcal/roster-sources/eligible-genders.'
       )
 WHERE team_id = 461
   AND removed_at IS NULL;

UPDATE teams
   SET is_active = false
 WHERE id = 461;

COMMIT;
