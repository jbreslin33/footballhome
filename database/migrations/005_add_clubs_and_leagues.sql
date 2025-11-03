-- Migration: Add Clubs and Leagues Support
-- Date: 2025-11-03
-- Description: Add club and league entities to support multi-tenant architecture

-- Create clubs table (sits above teams)
CREATE TABLE clubs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    short_name VARCHAR(50),
    slug VARCHAR(100) UNIQUE NOT NULL, -- for URLs: thunderfc.footballhome.org
    
    -- Location & Contact
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(100) DEFAULT 'USA',
    timezone VARCHAR(50) DEFAULT 'UTC',
    website VARCHAR(500),
    email VARCHAR(255),
    phone VARCHAR(20),
    
    -- Branding
    logo_url VARCHAR(500),
    primary_color VARCHAR(7), -- hex color
    secondary_color VARCHAR(7),
    description TEXT,
    
    -- Settings & Features
    settings JSONB DEFAULT '{}', -- club preferences, feature flags
    subscription_tier VARCHAR(20) DEFAULT 'free', -- free, premium, enterprise
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create leagues table (optional layer above clubs)
CREATE TABLE leagues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    short_name VARCHAR(50),
    slug VARCHAR(100) UNIQUE NOT NULL,
    
    -- League Details
    sport_id UUID NOT NULL REFERENCES sports(id),
    league_type VARCHAR(50) DEFAULT 'recreational', -- recreational, competitive, tournament
    
    -- Season Info
    season_start DATE,
    season_end DATE,
    registration_open DATE,
    registration_close DATE,
    
    -- Location & Contact
    city VARCHAR(100),
    state VARCHAR(50), 
    country VARCHAR(100) DEFAULT 'USA',
    timezone VARCHAR(50) DEFAULT 'UTC',
    website VARCHAR(500),
    email VARCHAR(255),
    phone VARCHAR(20),
    
    -- Branding
    logo_url VARCHAR(500),
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    description TEXT,
    
    -- League Rules & Settings
    settings JSONB DEFAULT '{}', -- league rules, scoring, divisions
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Junction table for league-club relationships (many-to-many)
CREATE TABLE league_clubs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    league_id UUID NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    
    -- Membership Details
    joined_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'active', -- active, pending, suspended, inactive
    division VARCHAR(50), -- if league has divisions
    
    -- Fees & Financial
    membership_fee DECIMAL(10,2),
    fee_paid BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(league_id, club_id)
);

-- Add club_id to teams table (teams belong to clubs)
ALTER TABLE teams ADD COLUMN club_id UUID REFERENCES clubs(id);

-- Make club_id required for new teams (but allow NULL for existing data during migration)
-- We'll update existing teams to belong to a default club

-- Create indexes for performance
CREATE INDEX idx_clubs_slug ON clubs(slug);
CREATE INDEX idx_clubs_location ON clubs(country, state, city);
CREATE INDEX idx_clubs_subscription ON clubs(subscription_tier);

CREATE INDEX idx_leagues_slug ON leagues(slug);
CREATE INDEX idx_leagues_sport ON leagues(sport_id);
CREATE INDEX idx_leagues_season ON leagues(season_start, season_end);

CREATE INDEX idx_league_clubs_league ON league_clubs(league_id);
CREATE INDEX idx_league_clubs_club ON league_clubs(club_id);
CREATE INDEX idx_league_clubs_status ON league_clubs(status);

CREATE INDEX idx_teams_club ON teams(club_id);

-- Add comments for documentation
COMMENT ON TABLE clubs IS 'Organizations that manage teams - can exist independently or as part of leagues';
COMMENT ON TABLE leagues IS 'Optional groupings of clubs for competitive play, tournaments, or shared management';
COMMENT ON TABLE league_clubs IS 'Many-to-many relationship between leagues and clubs';

COMMENT ON COLUMN clubs.slug IS 'URL-friendly identifier for subdomains/paths';
COMMENT ON COLUMN clubs.settings IS 'JSON object for club-specific configuration and preferences';
COMMENT ON COLUMN leagues.settings IS 'JSON object for league rules, scoring systems, divisions, etc.';

-- Create a default club for existing teams during migration
INSERT INTO clubs (name, short_name, slug, description) 
VALUES ('Default Club', 'DEFAULT', 'default-club', 'Temporary club for existing teams during migration');

-- Get the default club ID and update existing teams
UPDATE teams SET club_id = (SELECT id FROM clubs WHERE slug = 'default-club') WHERE club_id IS NULL;