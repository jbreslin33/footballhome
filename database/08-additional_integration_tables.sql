-- Additional tables needed for external data integration

-- Seasons management
CREATE TABLE IF NOT EXISTS seasons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,              -- '2024-25', 'Fall 2024', etc.
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name)
);

-- Team standings (if not exists)
CREATE TABLE IF NOT EXISTS team_standings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    season_id UUID REFERENCES seasons(id) ON DELETE CASCADE,
    division_id UUID NOT NULL REFERENCES league_divisions(id) ON DELETE CASCADE,
    games_played INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    draws INTEGER DEFAULT 0,
    goals_for INTEGER DEFAULT 0,
    goals_against INTEGER DEFAULT 0,
    points INTEGER DEFAULT 0,
    position INTEGER,                        -- Current league position
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(team_id, season_id, division_id)
);

-- Create current season
INSERT INTO seasons (name, start_date, is_current) 
VALUES ('2024-25', '2024-08-01', true)
ON CONFLICT (name) DO NOTHING;

-- Add PostgreSQL extension for similarity matching if not exists
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Add similarity indexes for team matching
CREATE INDEX IF NOT EXISTS idx_teams_name_trgm ON teams USING gin (name gin_trgm_ops);

-- Indexes for team standings
CREATE INDEX IF NOT EXISTS idx_team_standings_team ON team_standings(team_id);
CREATE INDEX IF NOT EXISTS idx_team_standings_season ON team_standings(season_id);
CREATE INDEX IF NOT EXISTS idx_team_standings_division ON team_standings(division_id);
CREATE INDEX IF NOT EXISTS idx_team_standings_points ON team_standings(points DESC);

-- Add created_from_external column to teams if not exists
ALTER TABLE teams ADD COLUMN IF NOT EXISTS created_from_external BOOLEAN DEFAULT false;