-- ============================================================================
-- 039 - Player Planner Notes
-- Adds per-player planning attributes (position) and resets injury flags
-- for a fresh start on squad planning.
-- ============================================================================

-- Position and planning notes per player
CREATE TABLE IF NOT EXISTS player_planner_notes (
    player_id  INT PRIMARY KEY REFERENCES players(id) ON DELETE CASCADE,
    position   VARCHAR(30),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Reset: clear all active injury flags (fresh slate for planning)
UPDATE player_availability
SET    until_date = CURRENT_DATE - INTERVAL '1 day'
WHERE  status     = 'injured'
  AND  (until_date IS NULL OR until_date >= CURRENT_DATE);
