-- Migration 027: Create match_lineup_metadata table
CREATE TABLE IF NOT EXISTS match_lineup_metadata (
    id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    formation_id INTEGER,
    roster_size INTEGER NOT NULL DEFAULT 20,
    notes TEXT,
    created_by_user_id INTEGER REFERENCES users(id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (match_id, team_id)
);

CREATE INDEX IF NOT EXISTS idx_match_lineup_metadata_match ON match_lineup_metadata(match_id);
CREATE INDEX IF NOT EXISTS idx_match_lineup_metadata_team ON match_lineup_metadata(team_id);
