-- 092-roster-tables-domain.sql (2026-07-05)
--
-- Normalize the mens-only roster tables into generic per-domain tables so
-- Boys/Girls/future rosters can share the same infrastructure (columns,
-- assignments, purgatory, dues logic, coach-order drag-and-drop).
--
-- Rename:
--   mens_team_columns     -> roster_columns
--   mens_team_assignments -> roster_assignments
--
-- Add:
--   domain TEXT NOT NULL  on both tables (existing rows default to 'mens',
--                         then default is dropped so future inserts must
--                         specify).
--
-- Constraints:
--   UNIQUE(team_id)                        -> UNIQUE(domain, team_id)
--   UNIQUE partial (uid, team) active      -> UNIQUE partial (domain, uid, team) active
--
-- The pool-team backfill trigger `trg_pool_team_membership_on_mens_assign`
-- is gated to `domain = 'mens'` so future domains don't accidentally get
-- inserted into every mens pool team.
--
-- All C++ models (MensTeamColumns / MensTeamAssignments / MensRoster) now
-- pass and filter `domain='mens'` on every query.

BEGIN;

-- ── Rename tables ────────────────────────────────────────────────────────
ALTER TABLE mens_team_columns     RENAME TO roster_columns;
ALTER TABLE mens_team_assignments RENAME TO roster_assignments;

-- Also rename the sequences so nextval() names stop lying.
ALTER SEQUENCE mens_team_columns_id_seq     RENAME TO roster_columns_id_seq;
ALTER SEQUENCE mens_team_assignments_id_seq RENAME TO roster_assignments_id_seq;

-- ── Add domain column ────────────────────────────────────────────────────
ALTER TABLE roster_columns     ADD COLUMN domain TEXT NOT NULL DEFAULT 'mens';
ALTER TABLE roster_assignments ADD COLUMN domain TEXT NOT NULL DEFAULT 'mens';

-- Drop the defaults so future inserts must specify the domain explicitly.
ALTER TABLE roster_columns     ALTER COLUMN domain DROP DEFAULT;
ALTER TABLE roster_assignments ALTER COLUMN domain DROP DEFAULT;

-- ── Swap uniqueness constraints to include domain ────────────────────────
-- roster_columns: was UNIQUE(team_id), now UNIQUE(domain, team_id).
ALTER TABLE roster_columns
    DROP CONSTRAINT mens_team_columns_team_unique;
ALTER TABLE roster_columns
    ADD CONSTRAINT roster_columns_domain_team_unique
    UNIQUE (domain, team_id);

-- roster_assignments: partial unique index on (uid, team) WHERE removed_at IS NULL
-- becomes partial unique on (domain, uid, team) WHERE removed_at IS NULL.
DROP INDEX IF EXISTS mens_team_assignments_unique_active;
CREATE UNIQUE INDEX roster_assignments_unique_active
    ON roster_assignments (domain, leagueapps_user_id, team_id)
    WHERE removed_at IS NULL;

-- ── Rename remaining indexes for hygiene ─────────────────────────────────
ALTER INDEX IF EXISTS idx_mens_team_columns_sort
    RENAME TO idx_roster_columns_sort;
ALTER INDEX IF EXISTS idx_mens_team_columns_active
    RENAME TO idx_roster_columns_active;
ALTER INDEX IF EXISTS idx_mens_team_assignments_user
    RENAME TO idx_roster_assignments_user;
ALTER INDEX IF EXISTS idx_mens_team_assignments_team
    RENAME TO idx_roster_assignments_team;
ALTER INDEX IF EXISTS idx_mens_team_assignments_on_roster
    RENAME TO idx_roster_assignments_on_roster;
ALTER INDEX IF EXISTS idx_mens_team_assignments_delinquent
    RENAME TO idx_roster_assignments_delinquent;
ALTER INDEX IF EXISTS idx_mens_team_assignments_coach_sort
    RENAME TO idx_roster_assignments_coach_sort_legacy;

-- Recreate coach-sort index scoped by (domain, team_id) so cross-domain
-- reorders stay independent.
DROP INDEX IF EXISTS idx_roster_assignments_coach_sort_legacy;
CREATE INDEX idx_roster_assignments_coach_sort
    ON roster_assignments (domain, team_id, coach_sort_order NULLS LAST, id)
    WHERE removed_at IS NULL;

-- Domain index for filter-by-domain queries (columns list, per-domain
-- assignment scan).
CREATE INDEX IF NOT EXISTS idx_roster_columns_domain
    ON roster_columns (domain, sort_order) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_roster_assignments_domain_user
    ON roster_assignments (domain, leagueapps_user_id)
    WHERE removed_at IS NULL;

-- ── Rename primary key + FK constraints for hygiene ──────────────────────
ALTER TABLE roster_columns     RENAME CONSTRAINT mens_team_columns_pkey     TO roster_columns_pkey;
ALTER TABLE roster_assignments RENAME CONSTRAINT mens_team_assignments_pkey TO roster_assignments_pkey;
ALTER TABLE roster_columns     RENAME CONSTRAINT mens_team_columns_team_id_fkey     TO roster_columns_team_id_fkey;
ALTER TABLE roster_assignments RENAME CONSTRAINT mens_team_assignments_team_id_fkey TO roster_assignments_team_id_fkey;

-- ── Gate the pool-team backfill trigger to domain='mens' ─────────────────
-- The trigger inserts newly assigned players into every mens pool team's
-- `rosters` table.  If a boys/girls assignment fires it, kids would end up
-- on mens pool rosters — bad.  Recreate the trigger with a WHEN clause.
DROP TRIGGER IF EXISTS trg_pool_team_membership_on_mens_assign ON roster_assignments;
CREATE TRIGGER trg_pool_team_membership_on_roster_assign
AFTER INSERT ON roster_assignments
FOR EACH ROW
WHEN (NEW.domain = 'mens')
EXECUTE FUNCTION fn_pool_team_membership_on_mens_assign();

COMMIT;
