-- 089: coach-defined roster ordering
--
-- Adds a per-(user, team) integer that captures the coach's ability
-- ranking within a column, replacing the default alpha sort with a
-- drag-and-drop ordering.  NULL means "no rank yet" and falls back to
-- the legacy on_roster / alphabetical sort.
--
-- Written by drag/drop endpoints as a dense 1..N sequence for the team
-- being reordered — so we can compare directly (NULLS LAST) without
-- any gap-management logic.
ALTER TABLE mens_team_assignments
  ADD COLUMN IF NOT EXISTS coach_sort_order INTEGER NULL;

-- Index used by MensRoster.cpp's bucket sort — filters to active rows
-- and orders NULL ranks last so alpha fallback still works.
CREATE INDEX IF NOT EXISTS idx_mens_team_assignments_coach_sort
  ON mens_team_assignments (team_id, coach_sort_order NULLS LAST, id)
  WHERE removed_at IS NULL;
