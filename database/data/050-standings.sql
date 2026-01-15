-- 050-standings.sql
-- Schema for storing league standings and snapshot history

CREATE TABLE IF NOT EXISTS standings (
  id SERIAL PRIMARY KEY,
  competition_id INTEGER REFERENCES competitions(id) ON DELETE CASCADE,
  season_id INTEGER REFERENCES seasons(id) ON DELETE CASCADE,
  team_id INTEGER REFERENCES teams(id) ON DELETE CASCADE,
  position INTEGER,
  played INTEGER,
  wins INTEGER,
  draws INTEGER,
  losses INTEGER,
  goals_for INTEGER,
  goals_against INTEGER,
  goal_diff INTEGER,
  points INTEGER,
  fetched_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  source TEXT,
  UNIQUE (competition_id, season_id, team_id)
);

-- Optional snapshots for historical tracking
CREATE TABLE IF NOT EXISTS standings_snapshots (
  id SERIAL PRIMARY KEY,
  competition_id INTEGER,
  season_id INTEGER,
  team_id INTEGER,
  position INTEGER,
  played INTEGER,
  wins INTEGER,
  draws INTEGER,
  losses INTEGER,
  goals_for INTEGER,
  goals_against INTEGER,
  goal_diff INTEGER,
  points INTEGER,
  fetched_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  source TEXT
);

CREATE INDEX IF NOT EXISTS idx_standings_comp_season ON standings(competition_id, season_id);
CREATE INDEX IF NOT EXISTS idx_snapshots_comp_season ON standings_snapshots(competition_id, season_id);
