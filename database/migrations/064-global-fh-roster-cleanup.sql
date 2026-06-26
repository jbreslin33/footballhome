-- Migration 064: Global FH-member roster cleanup
-- ============================================================================
-- Migration 062 closed ghost roster rows on pool teams (Training, Pickup).
-- This migration extends the same hard rule to ALL teams: a roster row only
-- belongs in the database if the underlying person is a FootballHome member.
--
-- FH-member definition (canonical):
--   1. LeagueApps mens registrant (external_person_aliases JOIN
--      mens_team_assignments), OR
--   2. Self-registered FH member (persons.fh_member_at IS NOT NULL).
--
-- Any open roster row whose person fails BOTH tests is a leftover from the
-- pre-June-2026 GroupMe scrape and gets closed (left_at = NOW()).  We do
-- NOT delete the row — keeping it lets us reconstruct historical lineups.

BEGIN;

UPDATE rosters r
   SET left_at = NOW()
  FROM players p
  JOIN persons pe ON pe.id = p.person_id
 WHERE r.player_id = p.id
   AND r.left_at IS NULL
   AND pe.fh_member_at IS NULL
   AND NOT EXISTS (
         SELECT 1
           FROM external_person_aliases epa
           JOIN mens_team_assignments mta
             ON mta.leagueapps_user_id::text = epa.external_user_id
          WHERE epa.person_id = pe.id
            AND epa.provider  = 'leagueapps'
       );

COMMIT;
