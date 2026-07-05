-- 084-mens-team-columns-archive.sql
--
-- Adds a soft-archive column to `mens_team_columns` so retired grassroots
-- groupings (Brazil, Puerto Rico) can be hidden from the Mens Roster board
-- without losing referential history in `mens_team_assignments`.
--
-- Backend behavior:
--   * `MensTeamColumns::loadAll()` / `findByTeamId()` now filter
--     `WHERE archived_at IS NULL` so archived columns disappear from the
--     board and from the `/api/mens-roster` payload.
--   * `mens_team_assignments` rows for archived team_ids remain intact so
--     historical assignment data is preserved.  If the operator re-archives
--     back to NULL later, existing assignments simply reappear.
--
-- Reversal: `UPDATE mens_team_columns SET archived_at = NULL WHERE team_id IN (...)`

BEGIN;

ALTER TABLE mens_team_columns
    ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;

-- Partial index for the common lookup: only live columns are returned to
-- the roster board.  Keeps the archived rows out of the hot path.
CREATE INDEX IF NOT EXISTS idx_mens_team_columns_active
    ON mens_team_columns (sort_order)
    WHERE archived_at IS NULL;

-- Archive every column EXCEPT APSL (35) and Liga 1 (120) — retired
-- 2026-07-04 per admin directive.  The Mens Roster Board now shows only
-- 4 columns: Unassigned, APSL, Liga 1, Purgatory.
--
-- Practice (908) and Pickup (909) are *not* selection columns any more —
-- they're auto-managed by the delinquency sweep so every member in good
-- standing (delinquencyState != 'purgatory') is on both teams.  The
-- team rows themselves stay in `teams` and existing
-- `mens_team_assignments` rows are untouched; only the *column* config
-- is archived so no pill appears on the Roster Board.
--
-- Reversal: `UPDATE mens_team_columns SET archived_at = NULL WHERE team_id IN (...)`
UPDATE mens_team_columns
   SET archived_at = NOW()
 WHERE team_id NOT IN (35, 120)
   AND archived_at IS NULL;

COMMIT;
