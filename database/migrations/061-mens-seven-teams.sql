-- Migration 061: Mens club lineup of 7 teams (Lighthouse, club 134)
-- ============================================================================
-- The mens program now consistently has 7 teams:
--   APSL, Liga 1, Liga 2, Puerto Rico, U23 Men, Practice, Pickup
-- 
-- Practice + Pickup are the two pool teams (teams.is_pool = true) — i.e. every
-- FH mens member auto-appears on those rosters.  Migration 060 already flipped
-- Training Lighthouse (Practice) to is_pool; this migration finishes the set:
--   * adds Liga 2 (was missing)
--   * flips Pickup Lighthouse to is_pool + backfills its rosters
--   * removes the orphan "Pool" team (id 906, no rosters / matches / assigns)
--
-- Brazil (904) is left alone — World Cup mini-event, has ended.

BEGIN;

-- 1. Liga 2 already exists as a CASA scrape (id 121) but with no club_id —
--    attach it to club 134 so it appears in the lineup screen alongside
--    APSL (35) and Liga 1 (120).  If for some reason 121 disappears in the
--    future, INSERT a fresh row below.
UPDATE teams SET club_id = 134 WHERE id = 121 AND club_id IS NULL;

INSERT INTO teams (name, club_id, division_id, source_system_id, slug)
SELECT 'Lighthouse Boys Club Liga 2',
       134,
       (SELECT division_id      FROM teams WHERE id = 120),
       (SELECT source_system_id FROM teams WHERE id = 120),
       'lighthouse-boys-club-liga-2'
 WHERE NOT EXISTS (
   SELECT 1 FROM teams WHERE slug = 'lighthouse-boys-club-liga-2'
 );

-- 2. Pickup is a pool team — flip the flag, then backfill rosters for every
--    FH mens member.  (Migration 060's trigger only fires going forward.)
UPDATE teams SET is_pool = true WHERE id = 909;  -- Pickup Lighthouse

INSERT INTO rosters (player_id, team_id, joined_at)
SELECT DISTINCT p.id, 909, NOW()
  FROM players p
 WHERE (
   EXISTS (
     SELECT 1 FROM external_person_aliases epa
       JOIN mens_team_assignments mta
         ON mta.leagueapps_user_id::text = epa.external_user_id
      WHERE epa.person_id = p.person_id
        AND epa.provider = 'leagueapps'
   )
   OR EXISTS (
     SELECT 1 FROM persons pe
      WHERE pe.id = p.person_id AND pe.pickup_opt_in_at IS NOT NULL
   )
 )
 AND NOT EXISTS (
   SELECT 1 FROM rosters r
    WHERE r.player_id = p.id AND r.team_id = 909 AND r.left_at IS NULL
 );

-- 3. Drop the orphan "Pool" team (id 906) — no rosters / matches / assignments.
DELETE FROM teams WHERE id = 906;

COMMIT;
