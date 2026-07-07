-- 100-retire-dues-owed-columns.sql (2026-07-07)
--
-- User directive: "get rid of dues owed column since we can see who
-- owes dues" on the OVERDUE chip already.  The auto-sweep + /assign
-- 409 gate were both disabled on 2026-07-04 ("don't auto manage it"),
-- so team 910 (mens) and team 915 (boys) have been UI-only sin-bins
-- with no functional teeth for three days.  Rosters are under cap;
-- parking warm bodies in Dues Owed costs playable spots.
--
-- What this migration does:
--   1. Soft-delete any remaining active roster_assignments rows on
--      team 910 / 915 (audit trail preserved via removed_at + reason).
--   2. Archive the two roster_columns rows (partial index
--      `idx_roster_columns_active WHERE archived_at IS NULL` hides
--      them from every board render — no code change required).
--
-- NOT deleted (kept for audit / history):
--   - teams.id = 910, 915                            (rows stay)
--   - roster_assignments history                     (rows stay; soft-deleted)
--   - person_billing / delinquency compute           (untouched)
--
-- The "🚨 Nd OVERDUE" chip on player cards is driven by
-- MensRoster::run() computing `daysOverdue` + `delinquencyState`
-- from person_billing.next_bill_date — it does NOT depend on team
-- 910 membership, so it keeps working after this migration.
--
-- Idempotent: safe to re-apply.

BEGIN;

-- 1) Soft-delete stragglers.  Any coach can still see them by
-- unarchiving the column, or by inspecting roster_assignments
-- directly.  The `dues_owed_column_retired` marker in
-- removed_reason makes them easy to find later.
UPDATE roster_assignments
   SET removed_at     = COALESCE(removed_at, now()),
       removed_reason = COALESCE(removed_reason, 'dues_owed_column_retired')
 WHERE team_id IN (910, 915)
   AND removed_at IS NULL;

-- 2) Archive the columns themselves.  Partial index
-- `idx_roster_columns_active WHERE archived_at IS NULL` +
-- `idx_roster_columns_domain WHERE archived_at IS NULL` already
-- hide archived rows from every SELECT the render paths use.
UPDATE roster_columns
   SET archived_at = COALESCE(archived_at, now()),
       updated_at  = now()
 WHERE team_id IN (910, 915)
   AND archived_at IS NULL;

COMMIT;
