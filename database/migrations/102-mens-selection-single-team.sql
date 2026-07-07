-- 102-mens-selection-single-team.sql
--
-- Enforce the "one-of-three" rule for mens-selection teams:
--   A player may hold at most ONE active roster_assignment across
--   APSL (35), Liga 1 (120), Liga 2 (121).
--
-- Historically this was app-layer only (mutex_group='mens-selection' in
-- MensTeamAssignments::addAssignment).  Direct SQL, older codepaths and
-- edge cases have produced overlaps -- e.g. after promoting Liga 2 to a
-- first-class column in migration 101, 24 users ended up on both Liga 1
-- and Liga 2 simultaneously.
--
-- This migration:
--   1. Consolidates every over-assigned user onto Liga 2 (121)
--      (soft-delete their rows on 35 and 120).  Coach will then
--      manually move them to their real team.
--   2. Adds a partial unique index so the DB rejects any future attempt
--      to hold >1 active row in {35, 120, 121} per (domain, user).
--
-- Idempotent.

BEGIN;

-- 1. Soft-delete APSL / Liga 1 rows for any user who is also on Liga 2.
UPDATE roster_assignments ra
   SET removed_at     = now(),
       removed_reason = 'mens_selection_consolidated_to_liga2'
 WHERE ra.domain     = 'mens'
   AND ra.removed_at IS NULL
   AND ra.team_id    IN (35, 120)
   AND EXISTS (
     SELECT 1
       FROM roster_assignments other
      WHERE other.domain              = 'mens'
        AND other.removed_at          IS NULL
        AND other.leagueapps_user_id  = ra.leagueapps_user_id
        AND other.team_id             = 121
   );

-- 2. Any remaining users on BOTH APSL and Liga 1 (no Liga 2 row):
--    soft-delete their APSL row and add a Liga 2 row.  (No current
--    victims of this case, but keep it correct for idempotency.)
WITH dupes AS (
  SELECT leagueapps_user_id
    FROM roster_assignments
   WHERE domain     = 'mens'
     AND removed_at IS NULL
     AND team_id    IN (35, 120)
   GROUP BY leagueapps_user_id
  HAVING COUNT(*) > 1
),
soft_deleted AS (
  UPDATE roster_assignments ra
     SET removed_at     = now(),
         removed_reason = 'mens_selection_consolidated_to_liga2'
   WHERE ra.domain     = 'mens'
     AND ra.removed_at IS NULL
     AND ra.team_id    IN (35, 120)
     AND ra.leagueapps_user_id IN (SELECT leagueapps_user_id FROM dupes)
  RETURNING ra.leagueapps_user_id
)
INSERT INTO roster_assignments (leagueapps_user_id, team_id, domain, on_roster)
SELECT DISTINCT leagueapps_user_id, 121, 'mens', false
  FROM soft_deleted
ON CONFLICT (domain, leagueapps_user_id, team_id) WHERE removed_at IS NULL
  DO NOTHING;

-- 3. Partial unique index: at most ONE active row per user across
--    (35, 120, 121).  Postgres partial-unique-index syntax uses a
--    functional expression -- we key on (domain, leagueapps_user_id)
--    and restrict the index to rows where team_id is one of the
--    mens-selection teams.
CREATE UNIQUE INDEX IF NOT EXISTS
  uniq_roster_assignments_mens_selection_one_of
  ON roster_assignments (domain, leagueapps_user_id)
  WHERE removed_at IS NULL
    AND team_id IN (35, 120, 121);

COMMIT;
