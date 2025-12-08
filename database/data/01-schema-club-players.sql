-- ========================================
-- CLUB/DIVISION PLAYER REGISTRY
-- ========================================
-- Purpose: Maintain club-level player association independent of team membership
-- This prevents deletion anomaly when players are removed from all teams
-- but still belong to the club/division (e.g., between seasons, on waitlist, etc.)

-- Division Players - Links players to sport divisions (e.g., Lighthouse Soccer)
-- This is the "master roster" for the division
CREATE TABLE division_players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    division_id UUID NOT NULL REFERENCES sport_divisions(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'active',  -- active, inactive, suspended, waitlist
    registration_date DATE DEFAULT CURRENT_DATE,
    registration_number VARCHAR(50),               -- Club-specific registration ID
    last_active_season VARCHAR(20),                -- Track last season played
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(division_id, player_id)
);

-- Track status changes over time
CREATE TABLE division_players_history (
    id SERIAL PRIMARY KEY,
    division_player_id UUID NOT NULL REFERENCES division_players(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL,
    changed_by_user_id UUID REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- Indexes
CREATE INDEX idx_division_players_division ON division_players(division_id);
CREATE INDEX idx_division_players_player ON division_players(player_id);
CREATE INDEX idx_division_players_status ON division_players(status) WHERE status = 'active';
CREATE INDEX idx_division_players_history_player ON division_players_history(division_player_id, changed_at DESC);

-- Comments
COMMENT ON TABLE division_players IS 'Master roster of players belonging to a sport division, independent of team membership';
COMMENT ON COLUMN division_players.status IS 'active: currently playing, inactive: not playing but still member, suspended: disciplinary, waitlist: awaiting placement';
COMMENT ON COLUMN division_players.registration_number IS 'Division-specific player registration/membership number';
COMMENT ON COLUMN division_players.last_active_season IS 'Last season the player was active on any team in this division';

-- Example data structure:
-- division_players: Links Luke Breslin to "Lighthouse Soccer Division"
-- team_players: Links Luke Breslin to "Lighthouse 1893 SC" team
-- If Luke leaves the team, he stays in division_players (still a Lighthouse Soccer player)
-- If he rejoins later or joins a different Lighthouse team, his division record persists
