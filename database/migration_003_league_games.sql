-- League Games Enhancement for Football Home Database
-- This adds support for scraped league games with duplicate prevention

-- League games table - canonical source for official league matches
-- This represents the "official" game that exists regardless of which teams use the system
CREATE TABLE league_games (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- League/Competition Info
    league_division_id UUID REFERENCES league_divisions(id), -- Which division/league
    competition_name VARCHAR(100),             -- 'Premier League', 'Cup'
    competition_round VARCHAR(50),             -- 'Week 10', 'Quarter Final'
    season VARCHAR(20) NOT NULL,               -- '2024-25', '2025'
    
    -- Game Details  
    home_team_id UUID NOT NULL REFERENCES teams(id),
    away_team_id UUID NOT NULL REFERENCES teams(id),
    scheduled_date TIMESTAMP NOT NULL,
    venue_id UUID REFERENCES venues(id),
    
    -- Official Game Info
    league_game_id VARCHAR(100),              -- External league's game ID (for scraping)
    external_url VARCHAR(500),                -- Link to league website game page
    referee_name VARCHAR(100),
    referee_contact VARCHAR(100),
    
    -- Game Status & Timing
    game_status VARCHAR(20) DEFAULT 'scheduled', -- 'scheduled', 'in_progress', 'completed', 'postponed', 'cancelled'
    kickoff_time TIME,                         -- Actual kickoff time
    match_start_time TIMESTAMP,                -- When match actually started
    match_end_time TIMESTAMP,                  -- When match ended
    current_minute INTEGER,                    -- Current match minute (for live games)
    
    -- Final Results
    home_team_score INTEGER,
    away_team_score INTEGER,
    
    -- Half-time Results  
    home_team_ht_score INTEGER,                -- Half-time score
    away_team_ht_score INTEGER,                -- Half-time score
    
    -- Match Statistics (commonly available from scraping)
    home_possession_percent INTEGER,           -- Ball possession %
    away_possession_percent INTEGER,
    home_shots INTEGER,                        -- Total shots
    away_shots INTEGER,
    home_shots_on_target INTEGER,             -- Shots on target
    away_shots_on_target INTEGER,
    home_corners INTEGER,                      -- Corner kicks
    away_corners INTEGER,
    home_fouls INTEGER,                        -- Fouls committed
    away_fouls INTEGER,
    home_yellow_cards INTEGER,                -- Yellow cards
    away_yellow_cards INTEGER,
    home_red_cards INTEGER,                   -- Red cards
    away_red_cards INTEGER,
    
    -- Match Conditions
    weather_conditions VARCHAR(100),           -- Weather description
    temperature INTEGER,                       -- Temperature in Celsius
    attendance INTEGER,                        -- Actual attendance
    
    -- Additional scraped data (JSON for flexibility)
    raw_match_data JSONB,                     -- Complete scraped data
    match_events JSONB,                       -- Goals, cards, subs as JSON array
    
    -- Metadata
    data_source VARCHAR(50) DEFAULT 'manual',  -- 'scraped_apsl', 'scraped_casa', 'manual', 'imported'
    scraped_at TIMESTAMP,                      -- When this was last scraped
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints for duplicate prevention
    UNIQUE(home_team_id, away_team_id, scheduled_date), -- Same teams, same date = duplicate
    
    -- Ensure home != away
    CONSTRAINT different_teams CHECK (home_team_id != away_team_id)
);

-- Create League Match Events table for detailed event tracking
CREATE TABLE league_match_events (
    id SERIAL PRIMARY KEY,
    league_game_id UUID NOT NULL,
    event_type VARCHAR(30) NOT NULL,           -- 'goal', 'yellow_card', 'red_card', 'substitution', 'penalty', 'own_goal', 'var_decision'
    team_id UUID NOT NULL,                     -- Team that the event applies to
    player_name VARCHAR(100),                  -- Player involved (may not be in our players table if scraped)
    player_id UUID,                            -- Link to our players table if available
    minute INTEGER,                            -- Match minute when event occurred
    stoppage_minute INTEGER,                   -- Additional stoppage time
    description TEXT,                          -- Full event description from scraping
    additional_data JSONB,                     -- Extra event data (assist, card reason, etc)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    FOREIGN KEY (league_game_id) REFERENCES league_games(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams(id)
    -- Note: player_id FK will be added when players table exists
);

-- Create Player Statistics table for match performance data
CREATE TABLE league_match_player_stats (
    id SERIAL PRIMARY KEY,
    league_game_id UUID NOT NULL,
    team_id UUID NOT NULL,
    player_name VARCHAR(100) NOT NULL,         -- Player name from scraping
    player_id UUID,                            -- Link to our players table if available
    
    -- Basic stats commonly available from scraping
    minutes_played INTEGER DEFAULT 0,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    shots INTEGER DEFAULT 0,
    shots_on_target INTEGER DEFAULT 0,
    
    -- Advanced stats (may not always be available)
    passes_completed INTEGER,
    passes_attempted INTEGER,
    tackles_won INTEGER,
    tackles_attempted INTEGER,
    aerial_duels_won INTEGER,
    aerial_duels_attempted INTEGER,
    
    -- Position and status
    starting_position VARCHAR(20),             -- Position played ('GK', 'CB', 'CM', etc.)
    is_starter BOOLEAN DEFAULT false,
    is_captain BOOLEAN DEFAULT false,
    
    -- Substitution info
    substituted_on_minute INTEGER,             -- When player came on
    substituted_off_minute INTEGER,            -- When player went off
    
    -- Raw scraped data
    raw_stats_data JSONB,                     -- Complete scraped player data
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    FOREIGN KEY (league_game_id) REFERENCES league_games(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams(id),
    -- Note: player_id FK will be added when players table exists
    
    -- Ensure one record per player per game per team
    UNIQUE (league_game_id, team_id, player_name)
);

-- Link events to league games (optional - for team-specific event management)
ALTER TABLE events ADD COLUMN league_game_id UUID REFERENCES league_games(id);

-- Create unique index for external ID uniqueness (partial index)
CREATE UNIQUE INDEX idx_league_games_external_unique 
ON league_games(league_game_id, data_source) 
WHERE league_game_id IS NOT NULL;

-- Create indexes for performance and duplicate checking
CREATE INDEX idx_league_games_teams_date ON league_games(home_team_id, away_team_id, scheduled_date);
CREATE INDEX idx_league_games_season ON league_games(season);
CREATE INDEX idx_league_games_league ON league_games(league_division_id);
CREATE INDEX idx_league_games_external ON league_games(league_game_id, data_source);
CREATE INDEX idx_league_games_status ON league_games(game_status);
CREATE INDEX idx_league_games_venue ON league_games(venue_id);

-- Indexes for league_match_events table
CREATE INDEX idx_league_match_events_game ON league_match_events(league_game_id);
CREATE INDEX idx_league_match_events_team ON league_match_events(team_id);
CREATE INDEX idx_league_match_events_type ON league_match_events(event_type);
CREATE INDEX idx_league_match_events_minute ON league_match_events(minute);
CREATE INDEX idx_league_match_events_player ON league_match_events(player_id) WHERE player_id IS NOT NULL;

-- Indexes for league_match_player_stats table
CREATE INDEX idx_league_player_stats_game ON league_match_player_stats(league_game_id);
CREATE INDEX idx_league_player_stats_team ON league_match_player_stats(team_id);
CREATE INDEX idx_league_player_stats_player ON league_match_player_stats(player_id) WHERE player_id IS NOT NULL;
CREATE INDEX idx_league_player_stats_goals ON league_match_player_stats(goals) WHERE goals > 0;
CREATE INDEX idx_league_player_stats_cards ON league_match_player_stats(yellow_cards, red_cards) WHERE yellow_cards > 0 OR red_cards > 0;

-- Create a view for team-specific game queries
CREATE OR REPLACE VIEW team_league_games AS
SELECT 
    lg.id,
    lg.season,
    lg.competition_name,
    lg.scheduled_date,
    lg.game_status,
    
    -- Team perspective fields
    CASE 
        WHEN lg.home_team_id = t.id THEN 'home'
        WHEN lg.away_team_id = t.id THEN 'away'
    END as home_away,
    
    -- Opponent info
    CASE 
        WHEN lg.home_team_id = t.id THEN away_team.name
        WHEN lg.away_team_id = t.id THEN home_team.name
    END as opponent_name,
    
    CASE 
        WHEN lg.home_team_id = t.id THEN lg.away_team_id
        WHEN lg.away_team_id = t.id THEN lg.home_team_id
    END as opponent_id,
    
    -- Score from team's perspective
    CASE 
        WHEN lg.home_team_id = t.id THEN lg.home_team_score
        WHEN lg.away_team_id = t.id THEN lg.away_team_score
    END as team_score,
    
    CASE 
        WHEN lg.home_team_id = t.id THEN lg.away_team_score
        WHEN lg.away_team_id = t.id THEN lg.home_team_score
    END as opponent_score,
    
    -- Other fields
    v.name as venue_name,
    lg.venue_id,
    lg.external_url,
    lg.data_source,
    t.id as team_id
    
FROM league_games lg
JOIN teams t ON (t.id = lg.home_team_id OR t.id = lg.away_team_id)
LEFT JOIN teams home_team ON lg.home_team_id = home_team.id
LEFT JOIN teams away_team ON lg.away_team_id = away_team.id
LEFT JOIN venues v ON lg.venue_id = v.id;

-- Function to check for duplicate games before insertion
CREATE OR REPLACE FUNCTION check_duplicate_league_game(
    p_home_team_id UUID,
    p_away_team_id UUID,
    p_scheduled_date TIMESTAMP,
    p_venue_id UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    duplicate_count INTEGER;
BEGIN
    -- Check for exact match (same teams, same date)
    SELECT COUNT(*) INTO duplicate_count
    FROM league_games
    WHERE (
        (home_team_id = p_home_team_id AND away_team_id = p_away_team_id)
        OR 
        (home_team_id = p_away_team_id AND away_team_id = p_home_team_id) -- Reverse order
    )
    AND DATE(scheduled_date) = DATE(p_scheduled_date);
    
    -- Also check if venue is same (stricter duplicate check)
    IF p_venue_id IS NOT NULL THEN
        SELECT COUNT(*) INTO duplicate_count
        FROM league_games
        WHERE (
            (home_team_id = p_home_team_id AND away_team_id = p_away_team_id)
            OR 
            (home_team_id = p_away_team_id AND away_team_id = p_home_team_id)
        )
        AND DATE(scheduled_date) = DATE(p_scheduled_date)
        AND venue_id = p_venue_id;
    END IF;
    
    RETURN duplicate_count > 0;
END;
$$ LANGUAGE plpgsql;

-- Function to update match statistics from scraped data
CREATE OR REPLACE FUNCTION update_league_game_stats(
    p_league_game_id UUID,
    p_home_score INTEGER DEFAULT NULL,
    p_away_score INTEGER DEFAULT NULL,
    p_home_ht_score INTEGER DEFAULT NULL,
    p_away_ht_score INTEGER DEFAULT NULL,
    p_attendance INTEGER DEFAULT NULL,
    p_raw_data JSONB DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE league_games 
    SET 
        home_team_score = COALESCE(p_home_score, home_team_score),
        away_team_score = COALESCE(p_away_score, away_team_score),
        home_team_ht_score = COALESCE(p_home_ht_score, home_team_ht_score),
        away_team_ht_score = COALESCE(p_away_ht_score, away_team_ht_score),
        attendance = COALESCE(p_attendance, attendance),
        raw_match_data = COALESCE(p_raw_data, raw_match_data),
        game_status = CASE 
            WHEN p_home_score IS NOT NULL AND p_away_score IS NOT NULL THEN 'completed'
            ELSE game_status
        END,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_league_game_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Function to add match event safely
CREATE OR REPLACE FUNCTION add_league_match_event(
    p_league_game_id UUID,
    p_event_type VARCHAR(30),
    p_team_id UUID,
    p_player_name VARCHAR(100) DEFAULT NULL,
    p_minute INTEGER DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_additional_data JSONB DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    new_event_id INTEGER;
BEGIN
    INSERT INTO league_match_events (
        league_game_id, event_type, team_id, player_name, 
        minute, description, additional_data
    ) VALUES (
        p_league_game_id, p_event_type, p_team_id, p_player_name,
        p_minute, p_description, p_additional_data
    ) RETURNING id INTO new_event_id;
    
    RETURN new_event_id;
END;
$$ LANGUAGE plpgsql;

-- Table and function comments
COMMENT ON TABLE league_games IS 'Canonical league games table for scraped and official matches';
COMMENT ON COLUMN league_games.league_game_id IS 'External league system game identifier for scraping';
COMMENT ON COLUMN league_games.data_source IS 'Source of the game data: scraped_apsl, scraped_casa, manual, imported';
COMMENT ON COLUMN league_games.raw_match_data IS 'Complete scraped match data as JSON for debugging and future parsing';

COMMENT ON TABLE league_match_events IS 'Detailed match events (goals, cards, subs) from scraped league data';
COMMENT ON COLUMN league_match_events.player_name IS 'Player name as scraped - may not match our players table exactly';
COMMENT ON COLUMN league_match_events.additional_data IS 'JSON data for assists, card reasons, substitution details, etc.';

COMMENT ON TABLE league_match_player_stats IS 'Individual player performance statistics from scraped match data';
COMMENT ON COLUMN league_match_player_stats.player_name IS 'Player name from league source - use for matching with our players table';
COMMENT ON COLUMN league_match_player_stats.raw_stats_data IS 'Complete player statistics as scraped for full data preservation';

COMMENT ON FUNCTION check_duplicate_league_game IS 'Check if a game already exists before insertion';
COMMENT ON FUNCTION update_league_game_stats IS 'Update match results and statistics from scraping';
COMMENT ON FUNCTION add_league_match_event IS 'Add individual match events (goals, cards, etc.) safely';