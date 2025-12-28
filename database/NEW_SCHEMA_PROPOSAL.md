# Proposed Normalized Schema

## Core Principle
**Single source of truth** - one table per entity type, differentiated by foreign keys, not by table duplication.

## Unified League Structure

```sql
-- ============================================================================
-- UNIFIED LEAGUE HIERARCHY
-- Organization -> League -> Conference -> Division -> Team -> Player
-- ============================================================================

CREATE TABLE leagues (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER NOT NULL REFERENCES organizations(id),
    name VARCHAR(255) NOT NULL,
    season VARCHAR(50) NOT NULL,
    website_url TEXT,
    affiliation VARCHAR(100),  -- "US Soccer", "Unaffiliated", etc.
    source_system VARCHAR(50),  -- 'apsl', 'casa', 'custom' for tracking data origin
    external_id VARCHAR(100),   -- Original ID from source system
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(organization_id, name, season)
);

CREATE TABLE conferences (
    id SERIAL PRIMARY KEY,
    league_id INTEGER NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    abbreviation VARCHAR(10),
    source_system VARCHAR(50),
    external_id VARCHAR(100),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(league_id, name)
);

CREATE TABLE league_divisions (
    id SERIAL PRIMARY KEY,
    league_id INTEGER NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    conference_id INTEGER REFERENCES conferences(id) ON DELETE CASCADE,  -- NULL if no conference
    name VARCHAR(255) NOT NULL,
    age_group VARCHAR(50),
    skill_level VARCHAR(50),
    gender VARCHAR(20),
    source_system VARCHAR(50),
    external_id VARCHAR(100),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(league_id, COALESCE(conference_id, 0), name)
);

CREATE TABLE league_teams (
    id SERIAL PRIMARY KEY,
    division_id INTEGER NOT NULL REFERENCES league_divisions(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    logo_url TEXT,
    source_system VARCHAR(50),
    external_id VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(division_id, name)
);

CREATE TABLE league_players (
    id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL REFERENCES league_teams(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    jersey_number VARCHAR(10),
    position VARCHAR(50),
    source_system VARCHAR(50),
    external_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE matches (
    id SERIAL PRIMARY KEY,
    division_id INTEGER NOT NULL REFERENCES league_divisions(id) ON DELETE CASCADE,
    home_team_id INTEGER REFERENCES league_teams(id),
    away_team_id INTEGER REFERENCES league_teams(id),
    match_date DATE NOT NULL,
    match_time TIME,
    venue_id INTEGER REFERENCES venues(id),
    status VARCHAR(20) DEFAULT 'scheduled' 
        CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled', 'postponed')),
    home_score INTEGER,
    away_score INTEGER,
    source_system VARCHAR(50),
    external_id VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE player_match_stats (
    id SERIAL PRIMARY KEY,
    match_id INTEGER REFERENCES matches(id) ON DELETE CASCADE,
    player_id INTEGER NOT NULL REFERENCES league_players(id) ON DELETE CASCADE,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(match_id, player_id)
);

CREATE TABLE team_standings (
    id SERIAL PRIMARY KEY,
    division_id INTEGER NOT NULL REFERENCES league_divisions(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES league_teams(id) ON DELETE CASCADE,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    ties INTEGER DEFAULT 0,
    goals_for INTEGER DEFAULT 0,
    goals_against INTEGER DEFAULT 0,
    points INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(division_id, team_id)
);

-- Indexes
CREATE INDEX idx_leagues_organization ON leagues(organization_id);
CREATE INDEX idx_conferences_league ON conferences(league_id);
CREATE INDEX idx_league_divisions_league ON league_divisions(league_id);
CREATE INDEX idx_league_divisions_conference ON league_divisions(conference_id);
CREATE INDEX idx_league_teams_division ON league_teams(division_id);
CREATE INDEX idx_league_players_team ON league_players(team_id);
CREATE INDEX idx_matches_division ON matches(division_id);
CREATE INDEX idx_matches_date ON matches(match_date);
CREATE INDEX idx_matches_teams ON matches(home_team_id, away_team_id);
```

## GroupMe Integration (Messaging + Events)

```sql
-- ============================================================================
-- GROUPME INTEGRATION
-- Chat groups, messages, events, and RSVPs
-- ============================================================================

CREATE TABLE groupme_groups (
    id SERIAL PRIMARY KEY,
    groupme_group_id VARCHAR(100) NOT NULL UNIQUE,  -- GroupMe's ID
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Link GroupMe groups to our entities (teams, divisions, clubs)
CREATE TABLE groupme_group_associations (
    id SERIAL PRIMARY KEY,
    groupme_group_id INTEGER NOT NULL REFERENCES groupme_groups(id) ON DELETE CASCADE,
    entity_type VARCHAR(50) NOT NULL,  -- 'team', 'division', 'club', 'league'
    entity_id INTEGER NOT NULL,  -- ID of the associated entity
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(groupme_group_id, entity_type, entity_id)
);

CREATE TABLE groupme_members (
    id SERIAL PRIMARY KEY,
    groupme_group_id INTEGER NOT NULL REFERENCES groupme_groups(id) ON DELETE CASCADE,
    groupme_user_id VARCHAR(100) NOT NULL,  -- GroupMe's user ID
    user_id INTEGER REFERENCES users(id),  -- Link to our users table if matched
    nickname VARCHAR(255),
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(groupme_group_id, groupme_user_id)
);

CREATE TABLE groupme_messages (
    id SERIAL PRIMARY KEY,
    groupme_message_id VARCHAR(100) NOT NULL UNIQUE,  -- GroupMe's message ID
    groupme_group_id INTEGER NOT NULL REFERENCES groupme_groups(id) ON DELETE CASCADE,
    groupme_member_id INTEGER REFERENCES groupme_members(id),
    text TEXT,
    created_at_groupme TIMESTAMP,  -- Timestamp from GroupMe
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE groupme_events (
    id SERIAL PRIMARY KEY,
    groupme_event_id VARCHAR(100) NOT NULL UNIQUE,  -- GroupMe's event ID
    groupme_group_id INTEGER NOT NULL REFERENCES groupme_groups(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    created_by_member_id INTEGER REFERENCES groupme_members(id),
    match_id INTEGER REFERENCES matches(id),  -- Link to official match if applicable
    practice_id INTEGER,  -- Link to practices table (future)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE groupme_event_rsvps (
    id SERIAL PRIMARY KEY,
    groupme_event_id INTEGER NOT NULL REFERENCES groupme_events(id) ON DELETE CASCADE,
    groupme_member_id INTEGER NOT NULL REFERENCES groupme_members(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('yes', 'no', 'maybe')),
    responded_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(groupme_event_id, groupme_member_id)
);

-- Indexes
CREATE INDEX idx_groupme_groups_active ON groupme_groups(is_active);
CREATE INDEX idx_groupme_members_group ON groupme_members(groupme_group_id);
CREATE INDEX idx_groupme_members_user ON groupme_members(user_id);
CREATE INDEX idx_groupme_messages_group ON groupme_messages(groupme_group_id);
CREATE INDEX idx_groupme_messages_created ON groupme_messages(created_at_groupme);
CREATE INDEX idx_groupme_events_group ON groupme_events(groupme_group_id);
CREATE INDEX idx_groupme_events_match ON groupme_events(match_id);
CREATE INDEX idx_groupme_events_start ON groupme_events(start_time);
CREATE INDEX idx_groupme_rsvps_event ON groupme_event_rsvps(groupme_event_id);
```

## Benefits

### Normalization
- **One table per entity**: No more `apsl_teams` vs `casa_teams`
- **Source tracking**: `source_system` + `external_id` fields track data origin
- **Foreign key integrity**: Organization → League → Conference → Division → Team chain

### Data Queries
```sql
-- Get all teams across APSL and CASA
SELECT * FROM league_teams;

-- Get only APSL teams
SELECT t.* FROM league_teams t
JOIN league_divisions d ON t.division_id = d.id
JOIN leagues l ON d.league_id = l.id
WHERE l.organization_id = 1;  -- APSL organization

-- Get all matches for a specific team (regardless of source)
SELECT * FROM matches 
WHERE home_team_id = 123 OR away_team_id = 123;
```

### Scraper Updates
- APSL scraper: Set `source_system='apsl'`, `external_id=<apsl_id>`
- CASA scraper: Set `source_system='casa'`, `external_id=<casa_id>`
- GroupMe scraper: Populate GroupMe tables, link events to matches

### GroupMe Use Cases
1. **Chat Archives**: Store message history for search/analysis
2. **Event Management**: GroupMe events sync with official matches/practices
3. **RSVP Tracking**: Track who's attending via GroupMe responses
4. **User Matching**: Link GroupMe users to app users for unified identity
5. **Team Communication**: Associate GroupMe groups with teams/divisions
