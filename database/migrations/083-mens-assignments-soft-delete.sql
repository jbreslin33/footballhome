-- 083-mens-assignments-soft-delete.sql
--
-- Add soft-delete columns to mens_team_assignments so the backend can
-- auto-remove players from rosters when they cross the delinquency
-- threshold (default 7 days past nextBillDate), then auto-restore them
-- once they pay.  Existing assignment rows are untouched (all get NULL).
--
-- Replaces the hard UNIQUE(leagueapps_user_id, team_id) constraint with a
-- partial unique index that only covers the ACTIVE set (removed_at IS
-- NULL).  This lets a soft-deleted historical row coexist with a fresh
-- active row on the same (user, team) pair, which matters if a player
-- churns in/out of purgatory over a season.
--
-- Pattern mirrors person_la_memberships (migration 079) which uses the
-- same "partial UNIQUE WHERE ended_at IS NULL" shape.

BEGIN;

ALTER TABLE mens_team_assignments
  ADD COLUMN IF NOT EXISTS removed_at      TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS removed_reason  TEXT,
  ADD COLUMN IF NOT EXISTS removed_details JSONB;

-- Swap the hard unique constraint for a partial index on active rows.
ALTER TABLE mens_team_assignments
  DROP CONSTRAINT IF EXISTS mens_team_assignments_unique;

CREATE UNIQUE INDEX IF NOT EXISTS mens_team_assignments_unique_active
  ON mens_team_assignments (leagueapps_user_id, team_id)
  WHERE removed_at IS NULL;

-- Helper index for auto-restore lookups (soft-deleted 'delinquent' rows
-- keyed by user).  Small partial index, negligible cost.
CREATE INDEX IF NOT EXISTS idx_mens_team_assignments_delinquent
  ON mens_team_assignments (leagueapps_user_id, team_id)
  WHERE removed_at IS NOT NULL AND removed_reason = 'delinquent';

COMMIT;
