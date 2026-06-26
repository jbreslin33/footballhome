-- Migration 062: Strip non-FH-members from pool team rosters
-- ============================================================================
-- FH-member = (LA mens registrant via external_person_aliases->mens_team_assignments)
--             OR persons.pickup_opt_in_at IS NOT NULL.
--
-- Practice (908) and Pickup (909) are pool teams (teams.is_pool=true) — they
-- must contain ONLY FH-members.  Migration 060 backfilled the FH-members onto
-- their rosters but left the pre-existing legacy GroupMe-only ghost rows
-- (chat scrapes from before the cutover) intact, which is why John Gonzalez,
-- Cristian Paredes et al still surface on the lineup.  Close those out.

BEGIN;

UPDATE rosters r
   SET left_at = NOW()
  FROM players p
  JOIN persons pe ON pe.id = p.person_id
 WHERE r.player_id = p.id
   AND r.left_at IS NULL
   AND r.team_id IN (
     SELECT id FROM teams WHERE is_pool
   )
   AND NOT EXISTS (
     SELECT 1 FROM external_person_aliases epa
       JOIN mens_team_assignments mta
         ON mta.leagueapps_user_id::text = epa.external_user_id
      WHERE epa.person_id = pe.id AND epa.provider = 'leagueapps'
   )
   AND pe.pickup_opt_in_at IS NULL;

COMMIT;
