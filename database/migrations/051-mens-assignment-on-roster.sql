-- 051: per-assignment "on roster" status for mens columns.
-- A player can be assigned to multiple columns (U23 + Brazil/PR per
-- mutex rules) and each column independently tracks whether they are
-- currently on that team's official roster (vs interested / pool only).

ALTER TABLE mens_team_assignments
  ADD COLUMN IF NOT EXISTS on_roster BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_mens_team_assignments_on_roster
  ON mens_team_assignments(team_id, on_roster);
