-- Entity-Specific Scrape Target Junction Tables
-- Allows linking scrape targets to specific entities (matches, teams, players, etc.)
-- Many-to-many: One entity can have multiple scrape types, one scrape target can be for multiple entities

-- Match scrape targets (match lineups, match events, match stats)
CREATE TABLE IF NOT EXISTS match_scrape_targets (
    scrape_target_id INTEGER NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    PRIMARY KEY (scrape_target_id, match_id)
);
CREATE INDEX IF NOT EXISTS idx_match_scrape_targets_match ON match_scrape_targets(match_id);

-- Team scrape targets (team roster, team stats, team schedule)
CREATE TABLE IF NOT EXISTS team_scrape_targets (
    scrape_target_id INTEGER NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    PRIMARY KEY (scrape_target_id, team_id)
);
CREATE INDEX IF NOT EXISTS idx_team_scrape_targets_team ON team_scrape_targets(team_id);

-- Player scrape targets (player profile, player stats, player history)
CREATE TABLE IF NOT EXISTS player_scrape_targets (
    scrape_target_id INTEGER NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    PRIMARY KEY (scrape_target_id, player_id)
);
CREATE INDEX IF NOT EXISTS idx_player_scrape_targets_player ON player_scrape_targets(player_id);

-- Season scrape targets (season structure, season schedule, season standings)
CREATE TABLE IF NOT EXISTS season_scrape_targets (
    scrape_target_id INTEGER NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    season_id INTEGER NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    PRIMARY KEY (scrape_target_id, season_id)
);
CREATE INDEX IF NOT EXISTS idx_season_scrape_targets_season ON season_scrape_targets(season_id);

-- Conference scrape targets (conference structure, conference standings)
CREATE TABLE IF NOT EXISTS conference_scrape_targets (
    scrape_target_id INTEGER NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    conference_id INTEGER NOT NULL REFERENCES conferences(id) ON DELETE CASCADE,
    PRIMARY KEY (scrape_target_id, conference_id)
);
CREATE INDEX IF NOT EXISTS idx_conference_scrape_targets_conference ON conference_scrape_targets(conference_id);

-- Division scrape targets (division standings, division schedule, division stats)
CREATE TABLE IF NOT EXISTS division_scrape_targets (
    scrape_target_id INTEGER NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    division_id INTEGER NOT NULL REFERENCES divisions(id) ON DELETE CASCADE,
    PRIMARY KEY (scrape_target_id, division_id)
);
CREATE INDEX IF NOT EXISTS idx_division_scrape_targets_division ON division_scrape_targets(division_id);
