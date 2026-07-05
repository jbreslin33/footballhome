-- 085-mens-purgatory-column.sql (2026-07-04)
--
-- Adds an admin-managed "Purgatory" bucket to the Mens Roster Board.
--
-- Design decision: reuse the existing team-assignment infrastructure
-- instead of introducing a separate admin_purgatory table.  Purgatory
-- becomes a normal `mens_team_columns` entry (team_id=910) that shares
-- the APSL/Liga 1 mutex group, so an admin move to Purgatory atomically
-- removes the player from any division roster.
--
-- Why mutex_group='35':
--   • APSL and Liga 1 both have mutex_group='35' (see 084).  Adding
--     Purgatory to the same group makes ALL FOUR columns
--     (Unassigned / APSL / Liga 1 / Purgatory) mutually exclusive from
--     the DB's point of view — the backend addAssignment() will delete
--     the sibling rows automatically.
--
-- Auto-management: this migration only adds the column.  The Practice +
-- Pickup backfill in MensRoster.cpp is updated separately to skip UIDs
-- currently on team 910, and the delinquency auto-sweep is disabled so
-- Purgatory becomes 100 % admin-driven (dues chip still displays on
-- cards for awareness — just no auto move).

BEGIN;

-- Team row for Purgatory.  Uses division 73 (the mens-club division
-- shared by U23 / Brazil / PR / Practice / Pickup).
INSERT INTO teams (id, division_id, name, is_pool, gender_category)
VALUES (910, 73, 'Purgatory (Admin)', false, 'boys')
ON CONFLICT (id) DO NOTHING;

-- Column entry.  sort_order=999 pins it to the right of the board.
-- mutex_group='mens-selection' makes it exclusive with APSL(35) and
-- Liga 1(120) — adding a player to any of the three deletes their
-- rows from the other two (see MensTeamAssignments::addAssignment
-- mutex handling).
INSERT INTO mens_team_columns (team_id, label, sort_order, color, mutex_group, short_label)
VALUES (910, '🚨 Purgatory', 999, '#ef4444', 'mens-selection', 'PURG')
ON CONFLICT (team_id) DO NOTHING;

-- Backfill mutex_group on APSL + Liga 1 (they were NULL prior).  Users
-- moving between division rosters now atomically vacate the other.
UPDATE mens_team_columns SET mutex_group = 'mens-selection' WHERE team_id IN (35, 120);

COMMIT;
