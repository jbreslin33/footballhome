-- Migration 006: Match lineup metadata for game day settings persistence
-- Stores formation, roster size, and zone assignments so edits survive rebuilds

-- Match lineup metadata (persists game day settings per match)
CREATE TABLE IF NOT EXISTS match_lineup_metadata (
    id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    formation_id INTEGER REFERENCES formations(id),
    roster_size INTEGER NOT NULL DEFAULT 20,  -- 18 or 20 man game day roster
    notes TEXT,
    created_by_user_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(match_id, team_id)
);

CREATE INDEX IF NOT EXISTS idx_match_lineup_metadata_match ON match_lineup_metadata(match_id);
CREATE INDEX IF NOT EXISTS idx_match_lineup_metadata_team ON match_lineup_metadata(team_id);

-- Add slot_number to match_lineups for formation position tracking
-- and zone field for three-zone management (starter/bench/not_selected)
ALTER TABLE match_lineups ADD COLUMN IF NOT EXISTS slot_number INTEGER;
ALTER TABLE match_lineups ADD COLUMN IF NOT EXISTS zone VARCHAR(20) NOT NULL DEFAULT 'not_selected';

COMMENT ON COLUMN match_lineups.slot_number IS 'Formation slot index (0-10 for starters)';
COMMENT ON COLUMN match_lineups.zone IS 'Zone: starter, bench, not_selected';

-- Tracking is handled automatically by run-migrations.sh via schema_migrations table
