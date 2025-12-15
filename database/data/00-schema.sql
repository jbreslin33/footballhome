-- Football Home Database Schema - Complete Production Schema
-- Version: 4.0 - Production ready with Google Places integration
--
-- This schema includes:
-- 1. Fully normalized database (4NF compliant)
-- 2. Google Places integration with all fields
-- 3. Migration tracking system for future changes
-- 4. Essential lookup tables and system data only
-- 5. Optimized indexes and constraints
-- 6. Google Places venues (335 venues) loaded via separate SQL files

-- Create database extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create migrations tracking table for future changes
CREATE TABLE IF NOT EXISTS schema_migrations (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(255) UNIQUE NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    checksum VARCHAR(64)
);

-- Sports lookup table
CREATE TABLE sports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,          -- 'soccer', 'basketball', 'hockey'
    display_name VARCHAR(100) NOT NULL,        -- 'Soccer', 'Basketball', 'Ice Hockey'
    default_event_duration INTEGER DEFAULT 90, -- Default minutes for this sport
    typical_team_size INTEGER,                 -- 11 for soccer, 5 for basketball
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Permission categories lookup table
CREATE TABLE permission_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,          -- 'team_management', 'user_management'
    display_name VARCHAR(100) NOT NULL,        -- 'Team Management', 'User Management'
    description TEXT,                          -- Category description
    sort_order INTEGER DEFAULT 0,             -- Display ordering
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Permissions lookup table (4NF compliant)
CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,          -- 'manage_teams', 'manage_users'
    display_name VARCHAR(100) NOT NULL,        -- 'Manage Teams', 'Manage Users'
    description TEXT,                          -- 'Create, edit, delete teams and rosters'
    permission_category_id UUID REFERENCES permission_categories(id), -- Normalized category
    is_system_permission BOOLEAN DEFAULT true, -- Cannot be deleted
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Event types lookup table
CREATE TABLE event_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sport_id UUID REFERENCES sports(id),       -- Different types per sport
    name VARCHAR(50) NOT NULL,                 -- 'training', 'match', 'meeting'
    display_name VARCHAR(100) NOT NULL,        -- 'Training Session', 'Match', 'Team Meeting'
    category VARCHAR(20) NOT NULL,             -- 'practice', 'match', 'other'
    default_duration INTEGER DEFAULT 90,       -- Default duration for this type
    requires_opponent BOOLEAN DEFAULT false,   -- Does this event type need an opponent?
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sport_id, name),
    CONSTRAINT valid_category CHECK (category IN ('practice', 'match', 'other'))
);

-- RSVP statuses lookup table
CREATE TABLE rsvp_statuses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(20) UNIQUE NOT NULL,          -- 'yes', 'no', 'maybe'
    display_name VARCHAR(50) NOT NULL,         -- 'Attending', 'Not Attending', 'Maybe'
    sort_order INTEGER DEFAULT 0,             -- For display ordering
    color VARCHAR(7),                         -- Hex color for UI (#27ae60)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- RSVP change sources lookup table (how was RSVP submitted)
CREATE TABLE rsvp_change_sources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(30) UNIQUE NOT NULL,          -- 'app', 'coach_entry', 'magic_link', 'bulk_import'
    display_name VARCHAR(50) NOT NULL,         -- 'Mobile App', 'Coach Entry', 'Email Link', 'Bulk Import'
    description TEXT,                          -- Additional context
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Home/Away venue status lookup table
CREATE TABLE home_away_statuses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(20) UNIQUE NOT NULL,          -- 'home', 'away', 'neutral'
    display_name VARCHAR(50) NOT NULL,         -- 'Home', 'Away', 'Neutral Venue'
    description TEXT,                          -- Additional context
    sort_order INTEGER DEFAULT 0,             -- For display ordering
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- External data providers lookup table (data sources like APSL, CASA, GroupMe, etc)
CREATE TABLE external_providers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,          -- 'apsl', 'casa', 'groupme'
    display_name VARCHAR(100) NOT NULL,        -- 'APSL', 'CASA', 'GroupMe'
    description TEXT,                          -- 'Amateur Premier Soccer League', 'Youth soccer league', etc.
    data_type VARCHAR(50) NOT NULL,            -- 'roster', 'messaging', 'scheduling', 'multi'
    base_url VARCHAR(500),                     -- API base URL or app URL
    scraper_path VARCHAR(500),                 -- Path to scraper script
    requires_auth BOOLEAN DEFAULT false,       -- Does this source need authentication?
    auth_type VARCHAR(50),                     -- 'token', 'oauth', 'api_key', 'none'
    documentation_url VARCHAR(500),            -- Link to API docs or setup guide
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- External apps/platforms lookup table
CREATE TABLE external_apps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,         -- 'groupme', 'teamsnap', 'sportsengine', 'whatsapp'
    display_name VARCHAR(100) NOT NULL,        -- 'GroupMe', 'TeamSnap', 'SportsEngine'
    app_type VARCHAR(50) NOT NULL,             -- 'messaging', 'scheduling', 'roster_management', 'multi'
    base_url VARCHAR(500),                     -- API base URL or app URL
    scraper_path VARCHAR(500),                 -- Path to scraper script (e.g., 'scripts/import-groupme-*.js')
    requires_auth BOOLEAN DEFAULT false,       -- Does this app need authentication?
    auth_type VARCHAR(50),                     -- 'token', 'oauth', 'api_key', 'none'
    documentation_url VARCHAR(500),            -- Link to API docs or setup guide
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_app_type CHECK (app_type IN ('messaging', 'scheduling', 'roster_management', 'multi'))
);

-- Player positions lookup table (sport-specific)
CREATE TABLE positions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sport_id UUID NOT NULL REFERENCES sports(id),
    name VARCHAR(50) NOT NULL,                 -- 'goalkeeper', 'striker', 'point_guard'
    display_name VARCHAR(100) NOT NULL,        -- 'Goalkeeper', 'Striker', 'Point Guard'
    abbreviation VARCHAR(5),                   -- 'GK', 'ST', 'PG'
    sort_order INTEGER DEFAULT 0,             -- For display ordering
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sport_id, name)
);

-- Leagues table (top-level competition structure)
CREATE TABLE leagues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    display_name VARCHAR(150) NOT NULL,
    sport_id UUID NOT NULL REFERENCES sports(id),
    season VARCHAR(20),
    description TEXT,
    logo_url VARCHAR(500),
    website VARCHAR(500),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- League conferences (geographical/organizational groupings within leagues)
CREATE TABLE league_conferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    league_id UUID NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,              -- 'Philadelphia', 'Lancaster', 'New Jersey'
    display_name VARCHAR(150) NOT NULL,      -- 'Philadelphia Conference', 'Lancaster Conference'
    slug VARCHAR(100) NOT NULL,              -- 'philadelphia', 'lancaster', 'new-jersey'
    description TEXT,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(league_id, slug)                  -- Unique conference slug per league
);

-- League divisions (competition divisions within conferences)
CREATE TABLE league_divisions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conference_id UUID NOT NULL REFERENCES league_conferences(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,              -- 'Division 1', 'Premier', 'Over 30'
    display_name VARCHAR(150) NOT NULL,      -- 'Premier Division', 'Division 1', 'Over 30 Division'
    slug VARCHAR(100) NOT NULL,              -- 'premier', 'division-1', 'over-30'
    tier INTEGER NOT NULL DEFAULT 1,         -- Hierarchical ranking: 1=top tier, 2=second tier, etc.
    hierarchy_group VARCHAR(50),             -- Groups divisions that are connected (e.g., 'adult', 'over30')
    skill_level VARCHAR(50),                 -- 'Premier', 'Competitive', 'Recreational'
    age_group VARCHAR(50),                   -- 'Adult', 'Over 30', 'U23'
    description TEXT,
    max_teams INTEGER,                       -- Maximum teams allowed in division
    promotion_eligible BOOLEAN DEFAULT false, -- Can teams be promoted from this division
    relegation_eligible BOOLEAN DEFAULT false, -- Can teams be relegated to this division
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(conference_id, slug)              -- Unique division slug per conference
);

-- Division relationships (promotion/relegation between divisions, can cross leagues)
CREATE TABLE division_relationships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_division_id UUID NOT NULL REFERENCES league_divisions(id) ON DELETE CASCADE,
    to_division_id UUID NOT NULL REFERENCES league_divisions(id) ON DELETE CASCADE,
    relationship_type VARCHAR(50) NOT NULL,  -- 'promotion', 'relegation', 'lateral_transfer'
    geographic_condition TEXT,               -- e.g., 'northern_teams_to_metropolitan, southern_teams_to_delaware_river'
    priority_order INTEGER DEFAULT 1,       -- For multiple promotion/relegation options
    is_automatic BOOLEAN DEFAULT false,     -- Automatic vs discretionary moves
    season VARCHAR(20),                     -- Which season this relationship applies to
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(from_division_id, to_division_id, relationship_type, season) -- Prevent duplicate relationships
);

-- Clubs table (pure organizational entities - no sport mixing)
CREATE TABLE clubs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    display_name VARCHAR(150) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    parent_club_id UUID REFERENCES clubs(id),   -- For organizational hierarchy only
    description TEXT,
    logo_url VARCHAR(500),
    website VARCHAR(500),
    founded_year INTEGER,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50) DEFAULT 'USA',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sport divisions table (sport-specific divisions within clubs)
CREATE TABLE sport_divisions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES clubs(id),
    sport_id UUID NOT NULL REFERENCES sports(id),
    name VARCHAR(100) NOT NULL,                 -- "Soccer Division", "Youth Soccer", etc.
    display_name VARCHAR(150) NOT NULL,
    slug VARCHAR(100) NOT NULL,                 -- "lighthouse-1893-soccer"
    description TEXT,
    logo_url VARCHAR(500),
    primary_color VARCHAR(7),                   -- Division colors
    secondary_color VARCHAR(7),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(club_id, sport_id, slug)            -- One division per sport per club per slug
);

-- Teams table (now belongs to sport divisions and league divisions)
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    division_id UUID NOT NULL REFERENCES sport_divisions(id),
    league_division_id UUID REFERENCES league_divisions(id), -- Optional league division membership
    season VARCHAR(20),
    age_group VARCHAR(50),                      -- U12, U15, Adult, etc.
    skill_level VARCHAR(50),                    -- Beginner, Intermediate, Advanced
    description TEXT,
    logo_url VARCHAR(500),
    primary_color VARCHAR(7),                   -- Hex color
    secondary_color VARCHAR(7),                 -- Hex color
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Team external apps junction table (links teams to external platforms they use)
CREATE TABLE team_external_apps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    sport_division_id UUID REFERENCES sport_divisions(id) ON DELETE CASCADE, -- For division-wide apps (training chats)
    external_app_id UUID NOT NULL REFERENCES external_apps(id),
    external_group_id VARCHAR(255),            -- GroupMe group ID, TeamSnap team ID, etc.
    external_group_name VARCHAR(255),          -- Human-readable name from external system
    config JSONB,                              -- App-specific config (can store auth tokens, settings)
    is_active BOOLEAN DEFAULT true,            -- Can disable without deleting
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(team_id, external_app_id, external_group_id),
    UNIQUE(sport_division_id, external_app_id, external_group_id),
    CONSTRAINT team_or_division CHECK ((team_id IS NOT NULL AND sport_division_id IS NULL) OR (team_id IS NULL AND sport_division_id IS NOT NULL))
);

CREATE INDEX idx_team_external_apps_team ON team_external_apps(team_id);
CREATE INDEX idx_team_external_apps_division ON team_external_apps(sport_division_id);
CREATE INDEX idx_team_external_apps_app ON team_external_apps(external_app_id);
CREATE INDEX idx_team_external_apps_active ON team_external_apps(is_active) WHERE is_active = true;

-- Users table (no direct role reference - uses junction table)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    preferred_name VARCHAR(100),
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255),
    avatar_url VARCHAR(500),
    date_of_birth DATE,
    emergency_contact VARCHAR(100),
    emergency_phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_last_first_name ON users(last_name, first_name);
CREATE INDEX idx_users_first_name ON users(first_name);

-- External identity tracking (staged import pattern)
-- Scrapers create identities with user_id=NULL, then admin manually links/merges via UI
CREATE TABLE user_external_identities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- NULL = not yet linked to a user
    provider_id UUID NOT NULL REFERENCES external_providers(id), -- Which external provider
    external_app_id UUID REFERENCES external_apps(id),    -- Which external app/platform (optional, for multi-provider apps)
    external_id VARCHAR(255) NOT NULL,       -- ID from external system
    external_username VARCHAR(255),          -- Display name from external system
    
    -- Context fields for easier filtering/merging
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL, -- Which team they belong to in external system
    sport_division_id UUID REFERENCES sport_divisions(id) ON DELETE SET NULL, -- For training chats (all teams in division)
    first_name VARCHAR(100),                 -- Parsed first name
    last_name VARCHAR(100),                  -- Parsed last name
    email VARCHAR(255),                      -- Email if available (for auto-matching)
    
    external_data JSONB,                     -- Raw data from external system (jersey, position, etc)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Composite unique: provider + external_id (same person can have IDs on multiple platforms)
    UNIQUE(provider_id, external_id)
);

CREATE INDEX idx_user_external_identities_user_id ON user_external_identities(user_id);
CREATE INDEX idx_user_external_identities_provider ON user_external_identities(provider_id);
CREATE INDEX idx_user_external_identities_external_app ON user_external_identities(external_app_id);
CREATE INDEX idx_user_external_identities_team_id ON user_external_identities(team_id);
CREATE INDEX idx_user_external_identities_sport_division_id ON user_external_identities(sport_division_id);
CREATE INDEX idx_user_external_identities_unlinked ON user_external_identities(provider_id, external_id) WHERE user_id IS NULL;

-- ========================================
-- USER ENTITY TABLES (Normalized)
-- ========================================
-- Each user type extends the base users table with specific fields
-- Following the same pattern as events -> practices/matches/meetings

-- Players (athletes on teams)
CREATE TABLE players (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    preferred_position_id UUID REFERENCES positions(id),
    photo_url TEXT,                          -- Player headshot photo path
    height_cm INTEGER,
    weight_kg INTEGER,
    dominant_foot VARCHAR(10),               -- 'left', 'right', 'both'
    player_rating INTEGER,                   -- Skill rating 1-100
    notes TEXT,                              -- Coach notes about player
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Coaches (team instructors/trainers)
CREATE TABLE coaches (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    coaching_license VARCHAR(100),           -- 'UEFA A', 'USSF B', etc.
    license_expiry DATE,
    years_experience INTEGER,
    certifications TEXT[],                   -- ['First Aid', 'SafeSport', 'Concussion Protocol']
    specializations TEXT[],                  -- ['Youth Development', 'Goalkeeper', 'Fitness']
    bio TEXT,                                -- Coach biography
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Parents (guardians of players)
CREATE TABLE parents (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    occupation VARCHAR(100),
    volunteer_interests TEXT[],              -- ['Team Parent', 'Fundraising', 'Transportation']
    background_check_completed BOOLEAN DEFAULT false,
    background_check_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Referees (match officials)
CREATE TABLE referees (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    referee_grade VARCHAR(50),               -- 'Grade 7', 'Grade 5', 'National'
    certification_level VARCHAR(100),        -- 'Regional', 'State', 'National'
    certification_expiry DATE,
    years_experience INTEGER,
    specializations TEXT[],                  -- ['Center Referee', 'Assistant Referee']
    availability TEXT,                       -- General availability notes
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Medical Staff (trainers, physiotherapists, doctors)
CREATE TABLE medical_staff (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    role_type VARCHAR(50),                   -- 'trainer', 'physiotherapist', 'doctor', 'paramedic'
    license_number VARCHAR(100),
    license_expiry DATE,
    certifications TEXT[],                   -- ['CPR', 'AED', 'Sports Medicine']
    specializations TEXT[],                  -- ['Sports Injuries', 'Rehabilitation']
    insurance_provider VARCHAR(100),
    insurance_policy_number VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Managers (non-coach team management roles)
CREATE TABLE managers (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    manager_type VARCHAR(50),                -- 'team_manager', 'equipment_manager', 'operations'
    years_experience INTEGER,
    areas_of_responsibility TEXT[],          -- ['Logistics', 'Equipment', 'Travel']
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Volunteers (general volunteers for teams/clubs)
CREATE TABLE volunteers (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    volunteer_roles TEXT[],                  -- ['Fundraising', 'Event Coordinator', 'Photographer']
    skills TEXT[],                           -- ['Photography', 'Social Media', 'Web Design']
    availability TEXT,                       -- General availability
    background_check_completed BOOLEAN DEFAULT false,
    background_check_date DATE,
    hours_contributed INTEGER DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Spectators (fans following teams)
CREATE TABLE spectators (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    favorite_sport_id UUID REFERENCES sports(id),
    fan_since DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Admins (administrative users at various organizational levels)
CREATE TABLE admins (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    admin_level VARCHAR(50),                 -- 'system', 'league', 'club', 'team'
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Admin permissions junction table (many-to-many, normalized like role_permissions)
CREATE TABLE admin_permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    granted_by UUID REFERENCES users(id),     -- Who granted this permission
    UNIQUE(admin_id, permission_id)
);

-- ========================================
-- TEAM RELATIONSHIP TABLES
-- ========================================
-- Link entity tables to teams with role-specific fields

-- Roster Status Lookup Table
CREATE TABLE roster_statuses (
    id SERIAL PRIMARY KEY,
    code VARCHAR(30) UNIQUE NOT NULL,
    display_name VARCHAR(50) NOT NULL,
    description TEXT,
    show_in_rsvp BOOLEAN DEFAULT true,           -- Should they receive RSVP invitations?
    show_in_official_roster BOOLEAN DEFAULT true, -- Show on official roster reports?
    sort_order INTEGER DEFAULT 0,                 -- For UI display ordering
    is_active BOOLEAN DEFAULT true,               -- Can this status still be used?
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Team Players (players on teams)
CREATE TABLE team_players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    roster_status_id INTEGER NOT NULL REFERENCES roster_statuses(id) DEFAULT 1,
    position_id UUID REFERENCES positions(id),  -- Position on THIS team
    jersey_number INTEGER,                      -- Jersey number on THIS team
    is_captain BOOLEAN DEFAULT false,
    is_vice_captain BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,             -- Still on team (not departed)
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    notes TEXT,
    UNIQUE(team_id, player_id)
    -- Note: Jersey numbers not enforced as unique due to unreliable APSL data
);

-- Roster Status History (track changes over time)
CREATE TABLE team_players_status_history (
    id SERIAL PRIMARY KEY,
    team_player_id UUID REFERENCES team_players(id) ON DELETE CASCADE,
    roster_status_id INTEGER REFERENCES roster_statuses(id),
    changed_by_user_id UUID REFERENCES users(id),
    changed_at TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT
);

-- Indexes for team_players
CREATE INDEX idx_team_players_roster_status ON team_players(roster_status_id);
CREATE INDEX idx_team_players_team ON team_players(team_id);
CREATE INDEX idx_team_players_player ON team_players(player_id);
CREATE INDEX idx_team_players_active ON team_players(is_active) WHERE is_active = true;

-- Indexes for team_players_status_history
CREATE INDEX idx_team_players_status_history_player ON team_players_status_history(team_player_id, changed_at DESC);
CREATE INDEX idx_team_players_status_history_status ON team_players_status_history(roster_status_id);

-- Team Coaches (coaches for teams)
CREATE TABLE team_coaches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    coach_id UUID NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
    coach_role VARCHAR(50) NOT NULL,            -- 'head_coach', 'assistant_coach', 'goalkeeper_coach', 'fitness_coach'
    is_primary BOOLEAN DEFAULT false,           -- Is this the head/primary coach?
    is_active BOOLEAN DEFAULT true,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    notes TEXT,
    UNIQUE(team_id, coach_id)
);

-- Team Medical Staff (medical staff assigned to teams)
CREATE TABLE team_medical_staff (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    medical_staff_id UUID NOT NULL REFERENCES medical_staff(id) ON DELETE CASCADE,
    role VARCHAR(50),                           -- 'primary_trainer', 'backup_trainer', 'team_doctor'
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    notes TEXT,
    UNIQUE(team_id, medical_staff_id)
);

-- Team Managers (managers for teams)
CREATE TABLE team_managers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    manager_id UUID NOT NULL REFERENCES managers(id) ON DELETE CASCADE,
    manager_role VARCHAR(50),                   -- 'team_manager', 'equipment_manager'
    is_active BOOLEAN DEFAULT true,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    notes TEXT,
    UNIQUE(team_id, manager_id)
);

-- Team Volunteers (volunteers helping teams)
CREATE TABLE team_volunteers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    volunteer_id UUID NOT NULL REFERENCES volunteers(id) ON DELETE CASCADE,
    volunteer_role VARCHAR(50),                 -- 'team_parent', 'photographer', 'social_media'
    is_active BOOLEAN DEFAULT true,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    notes TEXT,
    UNIQUE(team_id, volunteer_id)
);

-- ========================================
-- PARENT/GUARDIAN RELATIONSHIPS
-- ========================================

-- Player Guardians (parents/guardians of players)
CREATE TABLE player_guardians (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    parent_id UUID NOT NULL REFERENCES parents(id) ON DELETE CASCADE,
    relationship VARCHAR(50) NOT NULL,          -- 'mother', 'father', 'guardian', 'grandparent'
    is_primary_contact BOOLEAN DEFAULT false,
    is_emergency_contact BOOLEAN DEFAULT false,
    can_pickup BOOLEAN DEFAULT true,            -- Authorized to pick up player
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(player_id, parent_id)
);

-- Team Parents (parents who volunteer with teams)
CREATE TABLE team_parents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    parent_id UUID NOT NULL REFERENCES parents(id) ON DELETE CASCADE,
    role VARCHAR(50),                           -- 'team_parent', 'snack_coordinator', 'fundraiser'
    is_active BOOLEAN DEFAULT true,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    notes TEXT,
    UNIQUE(team_id, parent_id)
);

-- ========================================
-- SPECTATOR FOLLOWERS
-- ========================================

-- Team Followers (spectators following teams)
CREATE TABLE team_followers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    spectator_id UUID NOT NULL REFERENCES spectators(id) ON DELETE CASCADE,
    following_since TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notifications_enabled BOOLEAN DEFAULT true,
    favorite_team BOOLEAN DEFAULT false,
    notes TEXT,
    UNIQUE(team_id, spectator_id)
);

-- ========================================
-- ADMIN HIERARCHY TABLES
-- ========================================
-- Admins at different organizational levels

-- League Admins (manage entire leagues)
CREATE TABLE league_admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    league_id UUID NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    admin_id UUID NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    admin_role VARCHAR(50) NOT NULL,            -- 'commissioner', 'director', 'secretary', 'treasurer'
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    appointed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    term_ends_at TIMESTAMP,
    notes TEXT,
    UNIQUE(league_id, admin_id)
);

-- League Conference Admins (manage conferences within leagues)
CREATE TABLE league_conference_admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conference_id UUID NOT NULL REFERENCES league_conferences(id) ON DELETE CASCADE,
    admin_id UUID NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    admin_role VARCHAR(50) NOT NULL,            -- 'conference_director', 'coordinator'
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    appointed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    term_ends_at TIMESTAMP,
    notes TEXT,
    UNIQUE(conference_id, admin_id)
);

-- League Division Admins (manage divisions within conferences)
CREATE TABLE league_division_admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    division_id UUID NOT NULL REFERENCES league_divisions(id) ON DELETE CASCADE,
    admin_id UUID NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    admin_role VARCHAR(50) NOT NULL,            -- 'division_director', 'scheduler'
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    appointed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    term_ends_at TIMESTAMP,
    notes TEXT,
    UNIQUE(division_id, admin_id)
);

-- Club Admins (manage clubs/organizations)
CREATE TABLE club_admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    admin_id UUID NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    admin_role VARCHAR(50) NOT NULL,            -- 'president', 'vice_president', 'director', 'treasurer', 'secretary'
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    appointed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    term_ends_at TIMESTAMP,
    notes TEXT,
    UNIQUE(club_id, admin_id)
);

-- Sport Division Admins (manage sport divisions within clubs)
CREATE TABLE sport_division_admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    division_id UUID NOT NULL REFERENCES sport_divisions(id) ON DELETE CASCADE,
    admin_id UUID NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    admin_role VARCHAR(50) NOT NULL,            -- 'division_director', 'coordinator', 'registrar'
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    appointed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    term_ends_at TIMESTAMP,
    notes TEXT,
    UNIQUE(division_id, admin_id)
);

-- Team Admins (manage individual teams)
CREATE TABLE team_admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    admin_id UUID NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    admin_role VARCHAR(50) NOT NULL,            -- 'team_administrator', 'registrar'
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    appointed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    term_ends_at TIMESTAMP,
    notes TEXT,
    UNIQUE(team_id, admin_id)
);

-- Venues table (with complete Google Places integration)
CREATE TABLE venues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(100),                    -- "Training Ground", "Stadium", etc.
    venue_type VARCHAR(50) NOT NULL,            -- 'field', 'stadium', 'gym', 'clubhouse', 'outdoor', 'indoor'
    
    -- Location details
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'USA',
    latitude DECIMAL(10,8),                     -- For GPS coordinates
    longitude DECIMAL(11,8),
    formatted_address TEXT,                     -- Google formatted address
    
    -- Venue specifications
    surface_type VARCHAR(50),                   -- 'grass', 'artificial_turf', 'indoor_court', 'hardwood', etc.
    capacity INTEGER,                           -- Max people/players
    field_dimensions VARCHAR(100),              -- "105x68m", "Full size", etc.
    
    -- Facilities and features
    facilities TEXT[],                          -- ['changing_rooms', 'parking', 'floodlights', 'covered_seating']
    equipment_available TEXT[],                 -- ['goals', 'cones', 'bibs', 'first_aid']
    
    -- Accessibility and conditions
    wheelchair_accessible BOOLEAN DEFAULT false,
    weather_covered BOOLEAN DEFAULT false,      -- Indoor or covered facility
    parking_available BOOLEAN DEFAULT true,
    
    -- Contact and booking (Google-aligned field names)
    contact_name VARCHAR(100),
    phone VARCHAR(20),                          -- Renamed from contact_phone to match Google
    email VARCHAR(255),                         -- Renamed from contact_email for consistency
    international_phone_number VARCHAR(30),     -- Google Places field
    booking_required BOOLEAN DEFAULT false,
    hourly_rate DECIMAL(8,2),                   -- Cost per hour if applicable
    
    -- Usage restrictions
    available_hours VARCHAR(100),               -- "9AM-10PM", "24/7", etc.
    restrictions TEXT,                          -- Age limits, sport restrictions, etc.
    
    -- Additional info
    directions TEXT,
    notes TEXT,
    website VARCHAR(255),
    
    -- Ownership/management
    owned_by_team BOOLEAN DEFAULT false,
    venue_manager VARCHAR(100),
    
    -- Google Places integration fields
    place_id VARCHAR(255) UNIQUE,               -- Google Places unique identifier
    rating DECIMAL(2,1),                        -- Google Places rating (1.0-5.0)
    user_ratings_total INTEGER DEFAULT 0,       -- Number of Google reviews
    price_level INTEGER,                        -- Google price level (0-4)
    business_status VARCHAR(50),                -- Google business status
    google_types JSONB,                         -- Array of Google Place types
    opening_hours JSONB,                        -- Google opening hours data
    photos JSONB,                               -- Array of Google photo references
    data_source VARCHAR(50) DEFAULT 'user_added', -- Source of venue data
    last_google_update TIMESTAMP,               -- Last sync with Google Places
    
    -- Standard fields
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT valid_coordinates CHECK (
        (latitude IS NULL AND longitude IS NULL) OR 
        (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
    ),
    CONSTRAINT valid_rating CHECK (rating IS NULL OR (rating >= 1.0 AND rating <= 5.0)),
    CONSTRAINT valid_price_level CHECK (price_level IS NULL OR (price_level >= 0 AND price_level <= 4))
);

-- Base events table (common fields for all event types)
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_by UUID NOT NULL REFERENCES users(id),
    event_type_id UUID NOT NULL REFERENCES event_types(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_date TIMESTAMPTZ NOT NULL,            -- Timezone-aware for correct display
    venue_id UUID REFERENCES venues(id),
    duration_minutes INTEGER,                   -- Will default from event_type if null
    cancelled BOOLEAN DEFAULT false,
    cancellation_reason TEXT,
    external_event_id VARCHAR(255),             -- ID from external system (GroupMe, TeamSnap, etc.)
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(external_event_id)                   -- Prevent duplicate imports
);

-- Practices table (extends events for training/practice sessions)
CREATE TABLE practices (
    id UUID PRIMARY KEY REFERENCES events(id) ON DELETE CASCADE,
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    max_players INTEGER,                       -- Optional attendance limit
    focus_areas TEXT[],                        -- ['passing', 'shooting', 'defense']
    drill_plan TEXT,                           -- Detailed practice plan
    equipment_needed TEXT[],                   -- ['cones', 'balls', 'bibs']
    fitness_focus TEXT,                        -- 'endurance', 'strength', 'agility'
    skill_level VARCHAR(20),                   -- 'beginner', 'intermediate', 'advanced'
    weather_dependent BOOLEAN DEFAULT true,     -- Can practice be moved indoors?
    indoor_alternative_location VARCHAR(255),  -- Backup venue
    notes TEXT                                 -- Coach notes and observations
);

-- Matches table (extends events for competitive games)
CREATE TABLE matches (
    id UUID PRIMARY KEY REFERENCES events(id) ON DELETE CASCADE,
    home_team_id UUID NOT NULL REFERENCES teams(id),
    away_team_id UUID NOT NULL REFERENCES teams(id),
    home_away_status_id UUID NOT NULL REFERENCES home_away_statuses(id),
    competition_name VARCHAR(100),             -- 'Premier League', 'Cup Final'
    competition_round VARCHAR(50),             -- 'Quarter Final', 'Group Stage'
    referee_name VARCHAR(100),
    referee_phone VARCHAR(20),
    home_team_score INTEGER,                   -- Final score (null if not played)
    away_team_score INTEGER,
    match_status VARCHAR(20) DEFAULT 'scheduled', -- 'scheduled', 'in_progress', 'completed', 'postponed'
    weather_conditions TEXT,                   -- Match day weather
    attendance INTEGER,                        -- Number of spectators
    match_report TEXT,                         -- Post-match report
    man_of_match UUID REFERENCES users(id),   -- Player of the match
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    kick_off_time TIME,                       -- Actual kick-off time
    full_time_time TIME,                      -- When match ended
    CONSTRAINT different_teams CHECK (home_team_id != away_team_id)
);

-- ========================================
-- RSVP HISTORY TABLES (Append-Only)
-- ========================================
-- Each RSVP change creates a new row, preserving full audit trail.
-- Use the *_current views to get the latest RSVP for each person/event.

-- Player RSVP History (append-only log of all player RSVP changes)
CREATE TABLE player_rsvp_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    rsvp_status_id UUID NOT NULL REFERENCES rsvp_statuses(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by UUID REFERENCES users(id),      -- Who made the change (player or coach on behalf)
    change_source_id UUID REFERENCES rsvp_change_sources(id),  -- How it was submitted
    notes TEXT
    -- NO unique constraint - multiple rows per player/event allowed
);

CREATE INDEX idx_player_rsvp_history_lookup ON player_rsvp_history(event_id, player_id, changed_at DESC);
CREATE INDEX idx_player_rsvp_history_event ON player_rsvp_history(event_id);
CREATE INDEX idx_player_rsvp_history_player ON player_rsvp_history(player_id);
CREATE INDEX idx_player_rsvp_history_status ON player_rsvp_history(rsvp_status_id);

-- Coach RSVP History (append-only log of all coach RSVP changes)
CREATE TABLE coach_rsvp_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    coach_id UUID NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
    rsvp_status_id UUID NOT NULL REFERENCES rsvp_statuses(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by UUID REFERENCES users(id),      -- Who made the change
    change_source_id UUID REFERENCES rsvp_change_sources(id),
    notes TEXT
);

CREATE INDEX idx_coach_rsvp_history_lookup ON coach_rsvp_history(event_id, coach_id, changed_at DESC);
CREATE INDEX idx_coach_rsvp_history_event ON coach_rsvp_history(event_id);
CREATE INDEX idx_coach_rsvp_history_coach ON coach_rsvp_history(coach_id);
CREATE INDEX idx_coach_rsvp_history_status ON coach_rsvp_history(rsvp_status_id);

-- Parent RSVP History (append-only log of all parent RSVP changes)
CREATE TABLE parent_rsvp_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    parent_id UUID NOT NULL REFERENCES parents(id) ON DELETE CASCADE,
    rsvp_status_id UUID NOT NULL REFERENCES rsvp_statuses(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by UUID REFERENCES users(id),      -- Who made the change
    change_source_id UUID REFERENCES rsvp_change_sources(id),
    notes TEXT
);

CREATE INDEX idx_parent_rsvp_history_lookup ON parent_rsvp_history(event_id, parent_id, changed_at DESC);
CREATE INDEX idx_parent_rsvp_history_event ON parent_rsvp_history(event_id);
CREATE INDEX idx_parent_rsvp_history_parent ON parent_rsvp_history(parent_id);
CREATE INDEX idx_parent_rsvp_history_status ON parent_rsvp_history(rsvp_status_id);

-- ========================================
-- CURRENT RSVP VIEWS
-- ========================================
-- These views return only the latest RSVP for each person/event

CREATE VIEW player_rsvps_current AS
SELECT DISTINCT ON (event_id, player_id)
    id,
    event_id,
    player_id,
    rsvp_status_id,
    changed_at,
    changed_by,
    change_source_id,
    notes
FROM player_rsvp_history
ORDER BY event_id, player_id, changed_at DESC;

CREATE VIEW coach_rsvps_current AS
SELECT DISTINCT ON (event_id, coach_id)
    id,
    event_id,
    coach_id,
    rsvp_status_id,
    changed_at,
    changed_by,
    change_source_id,
    notes
FROM coach_rsvp_history
ORDER BY event_id, coach_id, changed_at DESC;

CREATE VIEW parent_rsvps_current AS
SELECT DISTINCT ON (event_id, parent_id)
    id,
    event_id,
    parent_id,
    rsvp_status_id,
    changed_at,
    changed_by,
    change_source_id,
    notes
FROM parent_rsvp_history
ORDER BY event_id, parent_id, changed_at DESC;

-- Match Officials (referees assigned to matches)
CREATE TABLE match_officials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    referee_id UUID NOT NULL REFERENCES referees(id) ON DELETE CASCADE,
    official_role VARCHAR(50) NOT NULL,         -- 'center_referee', 'assistant_referee_1', 'assistant_referee_2', 'fourth_official'
    assignment_confirmed BOOLEAN DEFAULT false,
    payment_amount DECIMAL(10,2),
    payment_status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'paid', 'waived'
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(match_id, referee_id, official_role)
);

-- ========================================
-- MATCH ROSTER & LINEUP TABLES
-- ========================================
-- Formations reference table (4-4-2, 4-3-3, etc.)
CREATE TABLE formations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,          -- '4-4-2', '4-3-3', '3-5-2'
    name VARCHAR(50) NOT NULL,                 -- 'Four-Four-Two'
    positions JSONB NOT NULL,                  -- Array of position codes with coordinates
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Match Rosters (who is available/selected for game day)
CREATE TABLE match_rosters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    added_by UUID REFERENCES users(id),        -- Coach who added them
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(match_id, player_id)
);

CREATE INDEX idx_match_rosters_match ON match_rosters(match_id);
CREATE INDEX idx_match_rosters_player ON match_rosters(player_id);

-- Match Lineups (starting 11 + bench with positions)
CREATE TABLE match_lineups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    formation_id UUID REFERENCES formations(id), -- Formation used for this match
    lineup_type VARCHAR(10) NOT NULL,          -- 'starting' or 'bench'
    formation_position VARCHAR(20),            -- 'GK', 'LB', 'CB1', 'CB2', 'RB', etc.
    bench_order INTEGER,                       -- Order on bench (1, 2, 3...)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(match_id, player_id),
    CONSTRAINT valid_lineup_type CHECK (lineup_type IN ('starting', 'bench'))
);

CREATE INDEX idx_match_lineups_match ON match_lineups(match_id);
CREATE INDEX idx_match_lineups_player ON match_lineups(player_id);
CREATE INDEX idx_match_lineups_type ON match_lineups(lineup_type);

-- Meetings table (extends events for team meetings, parent meetings, etc.)
CREATE TABLE meetings (
    id UUID PRIMARY KEY REFERENCES events(id) ON DELETE CASCADE,
    meeting_type VARCHAR(50),                  -- 'team', 'parent', 'board', 'social'
    agenda TEXT,                               -- Meeting agenda
    minutes TEXT,                              -- Meeting minutes/notes
    organizer_id UUID REFERENCES users(id),   -- Person organizing the meeting
    attendee_limit INTEGER,                    -- Optional maximum attendees
    required_attendance BOOLEAN DEFAULT false, -- Is attendance mandatory?
    online_meeting_url VARCHAR(500),           -- Zoom/Teams/etc link
    online_meeting_password VARCHAR(100),      -- Meeting password if needed
    recording_url VARCHAR(500)                 -- Link to recording if available
);

-- Meeting attendees (many-to-many for meetings that involve multiple teams or individuals)
CREATE TABLE meeting_teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    meeting_id UUID NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    UNIQUE(meeting_id, team_id)
);

-- Magic tokens for RSVP links via email/SMS (unchanged)
CREATE TABLE magic_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    token VARCHAR(255) UNIQUE NOT NULL,
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- NULL = not yet linked to a user
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(event_id, user_id)
);

-- Indexes for performance
CREATE INDEX idx_events_date ON events(event_date);
CREATE INDEX idx_events_type ON events(event_type_id);
CREATE INDEX idx_practices_team ON practices(team_id);
CREATE INDEX idx_practices_focus ON practices(focus_areas);
CREATE INDEX idx_matches_home_team ON matches(home_team_id);
CREATE INDEX idx_matches_away_team ON matches(away_team_id);
CREATE INDEX idx_matches_competition ON matches(competition_name);
CREATE INDEX idx_matches_status ON matches(match_status);
CREATE INDEX idx_matches_home_away ON matches(home_away_status_id);

-- User entity indexes
CREATE INDEX idx_players_position ON players(preferred_position_id);
CREATE INDEX idx_coaches_license ON coaches(coaching_license);
CREATE INDEX idx_referees_grade ON referees(referee_grade);
CREATE INDEX idx_medical_staff_role ON medical_staff(role_type);
CREATE INDEX idx_managers_type ON managers(manager_type);
CREATE INDEX idx_admins_level ON admins(admin_level);

-- Admin permissions indexes
CREATE INDEX idx_admin_permissions_admin ON admin_permissions(admin_id);
CREATE INDEX idx_admin_permissions_permission ON admin_permissions(permission_id);

-- Team relationship indexes (defined earlier in file)
CREATE INDEX idx_team_coaches_team ON team_coaches(team_id);
CREATE INDEX idx_team_coaches_coach ON team_coaches(coach_id);
CREATE INDEX idx_team_coaches_active ON team_coaches(team_id, is_active);
CREATE INDEX idx_team_medical_staff_team ON team_medical_staff(team_id);
CREATE INDEX idx_team_medical_staff_staff ON team_medical_staff(medical_staff_id);
CREATE INDEX idx_team_managers_team ON team_managers(team_id);
CREATE INDEX idx_team_managers_manager ON team_managers(manager_id);
CREATE INDEX idx_team_volunteers_team ON team_volunteers(team_id);
CREATE INDEX idx_team_volunteers_volunteer ON team_volunteers(volunteer_id);

-- Parent/guardian indexes
CREATE INDEX idx_player_guardians_player ON player_guardians(player_id);
CREATE INDEX idx_player_guardians_parent ON player_guardians(parent_id);
CREATE INDEX idx_team_parents_team ON team_parents(team_id);
CREATE INDEX idx_team_parents_parent ON team_parents(parent_id);

-- Match officials indexes
CREATE INDEX idx_match_officials_match ON match_officials(match_id);
CREATE INDEX idx_match_officials_referee ON match_officials(referee_id);
CREATE INDEX idx_match_officials_role ON match_officials(official_role);

-- Team followers indexes
CREATE INDEX idx_team_followers_team ON team_followers(team_id);
CREATE INDEX idx_team_followers_spectator ON team_followers(spectator_id);

-- Admin hierarchy indexes
CREATE INDEX idx_league_admins_league ON league_admins(league_id);
CREATE INDEX idx_league_admins_admin ON league_admins(admin_id);
CREATE INDEX idx_league_conference_admins_conference ON league_conference_admins(conference_id);
CREATE INDEX idx_league_conference_admins_admin ON league_conference_admins(admin_id);
CREATE INDEX idx_league_division_admins_division ON league_division_admins(division_id);
CREATE INDEX idx_league_division_admins_admin ON league_division_admins(admin_id);
CREATE INDEX idx_club_admins_club ON club_admins(club_id);
CREATE INDEX idx_club_admins_admin ON club_admins(admin_id);
CREATE INDEX idx_sport_division_admins_division ON sport_division_admins(division_id);
CREATE INDEX idx_sport_division_admins_admin ON sport_division_admins(admin_id);
CREATE INDEX idx_team_admins_team ON team_admins(team_id);
CREATE INDEX idx_team_admins_admin ON team_admins(admin_id);

CREATE INDEX idx_permission_categories_name ON permission_categories(name);
CREATE INDEX idx_permissions_category ON permissions(permission_category_id);
CREATE INDEX idx_teams_division ON teams(division_id);
CREATE INDEX idx_teams_league_division ON teams(league_division_id);
CREATE INDEX idx_league_conferences_league ON league_conferences(league_id);
CREATE INDEX idx_league_conferences_slug ON league_conferences(slug);
CREATE INDEX idx_league_divisions_conference ON league_divisions(conference_id);
CREATE INDEX idx_league_divisions_slug ON league_divisions(slug);
CREATE INDEX idx_league_divisions_tier ON league_divisions(tier);
CREATE INDEX idx_league_divisions_hierarchy_group ON league_divisions(hierarchy_group) WHERE hierarchy_group IS NOT NULL;
CREATE INDEX idx_division_relationships_from ON division_relationships(from_division_id);
CREATE INDEX idx_division_relationships_to ON division_relationships(to_division_id);
CREATE INDEX idx_division_relationships_type ON division_relationships(relationship_type);
CREATE INDEX idx_division_relationships_season ON division_relationships(season);
CREATE INDEX idx_sport_divisions_club ON sport_divisions(club_id);
CREATE INDEX idx_sport_divisions_sport ON sport_divisions(sport_id);
CREATE INDEX idx_sport_divisions_slug ON sport_divisions(slug);
CREATE INDEX idx_clubs_parent ON clubs(parent_club_id) WHERE parent_club_id IS NOT NULL;
CREATE INDEX idx_clubs_slug ON clubs(slug);
CREATE INDEX idx_leagues_sport ON leagues(sport_id);
CREATE INDEX idx_positions_sport ON positions(sport_id);
CREATE INDEX idx_event_types_sport ON event_types(sport_id);
CREATE INDEX idx_event_types_category ON event_types(category);
CREATE INDEX idx_magic_tokens_token ON magic_tokens(token);
CREATE INDEX idx_magic_tokens_expires ON magic_tokens(expires_at);

-- Google Places indexes
CREATE INDEX idx_venues_place_id ON venues(place_id) WHERE place_id IS NOT NULL;
CREATE INDEX idx_venues_rating ON venues(rating) WHERE rating IS NOT NULL;
CREATE INDEX idx_venues_data_source ON venues(data_source);
CREATE INDEX idx_venues_business_status ON venues(business_status);
CREATE INDEX idx_venues_phone ON venues(phone) WHERE phone IS NOT NULL;

-- Insert lookup data

-- External Providers (data sources)
INSERT INTO external_providers (id, name, display_name, description, data_type, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440a01', 'apsl', 'APSL', 'Amateur Premier Soccer League', 'roster', true),
('550e8400-e29b-41d4-a716-446655440a02', 'casa', 'CASA', 'Community Amateur Soccer Association youth leagues', 'roster', true),
('550e8400-e29b-41d4-a716-446655440a03', 'groupme', 'GroupMe', 'Group messaging platform', 'messaging', true);

-- Sports
INSERT INTO sports (id, name, display_name, default_event_duration, typical_team_size) VALUES 
('550e8400-e29b-41d4-a716-446655440101', 'soccer', 'Soccer (Football)', 90, 11),
('550e8400-e29b-41d4-a716-446655440102', 'basketball', 'Basketball', 60, 5),
('550e8400-e29b-41d4-a716-446655440103', 'hockey', 'Ice Hockey', 60, 6),
('550e8400-e29b-41d4-a716-446655440104', 'baseball', 'Baseball', 180, 9),
('550e8400-e29b-41d4-a716-446655440105', 'volleyball', 'Volleyball', 90, 6);

-- Permission Categories
INSERT INTO permission_categories (id, name, display_name, description, sort_order) VALUES
('550e8400-e29b-41d4-a716-446655440701', 'team_management', 'Team Management', 'Permissions for managing teams and rosters', 1),
('550e8400-e29b-41d4-a716-446655440702', 'user_management', 'User Management', 'Permissions for managing users and roles', 2),
('550e8400-e29b-41d4-a716-446655440703', 'event_management', 'Event Management', 'Permissions for managing events and practices', 3),
('550e8400-e29b-41d4-a716-446655440704', 'communication', 'Communication', 'Permissions for notifications and messaging', 4),
('550e8400-e29b-41d4-a716-446655440705', 'team_access', 'Team Access', 'Permissions for viewing team information', 5),
('550e8400-e29b-41d4-a716-446655440706', 'event_access', 'Event Access', 'Permissions for viewing and responding to events', 6),
('550e8400-e29b-41d4-a716-446655440707', 'user_access', 'User Access', 'Permissions for user profile access', 7),
('550e8400-e29b-41d4-a716-446655440708', 'system_admin', 'System Administration', 'System-level administrative permissions', 8),
('550e8400-e29b-41d4-a716-446655440709', 'league_management', 'League Management', 'Permissions for managing leagues and conferences', 9),
('550e8400-e29b-41d4-a716-446655440710', 'club_management', 'Club Management', 'Permissions for managing clubs and divisions', 10),
('550e8400-e29b-41d4-a716-446655440711', 'venue_management', 'Venue Management', 'Permissions for managing venues', 11);

-- Permissions (4NF compliant)
INSERT INTO permissions (id, name, display_name, description, permission_category_id, is_system_permission) VALUES 
('550e8400-e29b-41d4-a716-446655440601', 'manage_teams', 'Manage Teams', 'Create, edit, delete teams and rosters', '550e8400-e29b-41d4-a716-446655440701', true),
('550e8400-e29b-41d4-a716-446655440602', 'manage_users', 'Manage Users', 'Create, edit, delete user accounts', '550e8400-e29b-41d4-a716-446655440702', true),
('550e8400-e29b-41d4-a716-446655440603', 'manage_events', 'Manage Events', 'Create, edit, delete events and practices', '550e8400-e29b-41d4-a716-446655440703', true),
('550e8400-e29b-41d4-a716-446655440604', 'send_notifications', 'Send Notifications', 'Send email/SMS notifications to team members', '550e8400-e29b-41d4-a716-446655440704', true),
('550e8400-e29b-41d4-a716-446655440605', 'manage_roles', 'Manage Roles', 'Assign and revoke user roles and permissions', '550e8400-e29b-41d4-a716-446655440702', true),
('550e8400-e29b-41d4-a716-446655440606', 'view_team', 'View Team', 'View team roster and member details', '550e8400-e29b-41d4-a716-446655440705', true),
('550e8400-e29b-41d4-a716-446655440607', 'manage_roster', 'Manage Roster', 'Add/remove players from team roster', '550e8400-e29b-41d4-a716-446655440701', true),
('550e8400-e29b-41d4-a716-446655440608', 'view_events', 'View Events', 'View team events and schedules', '550e8400-e29b-41d4-a716-446655440706', true),
('550e8400-e29b-41d4-a716-446655440609', 'rsvp_events', 'RSVP to Events', 'Respond to event invitations', '550e8400-e29b-41d4-a716-446655440706', true),
('550e8400-e29b-41d4-a716-446655440610', 'view_profile', 'View Profile', 'View own profile and basic information', '550e8400-e29b-41d4-a716-446655440707', true),
-- System-level admin permissions
('550e8400-e29b-41d4-a716-446655440611', 'system_admin', 'System Administrator', 'Full system access - all permissions', '550e8400-e29b-41d4-a716-446655440708', true),
('550e8400-e29b-41d4-a716-446655440612', 'manage_leagues', 'Manage Leagues', 'Create, edit, delete leagues and conferences', '550e8400-e29b-41d4-a716-446655440709', true),
('550e8400-e29b-41d4-a716-446655440613', 'manage_clubs', 'Manage Clubs', 'Create, edit, delete clubs and divisions', '550e8400-e29b-41d4-a716-446655440710', true),
('550e8400-e29b-41d4-a716-446655440614', 'manage_venues', 'Manage Venues', 'Create, edit, delete venues', '550e8400-e29b-41d4-a716-446655440711', true),
('550e8400-e29b-41d4-a716-446655440615', 'manage_permissions', 'Manage Permissions', 'Grant and revoke admin permissions', '550e8400-e29b-41d4-a716-446655440708', true),
('550e8400-e29b-41d4-a716-446655440616', 'view_system_logs', 'View System Logs', 'Access system logs and audit trails', '550e8400-e29b-41d4-a716-446655440708', true);

-- RSVP statuses
INSERT INTO rsvp_statuses (id, name, display_name, sort_order, color) VALUES 
('550e8400-e29b-41d4-a716-446655440301', 'yes', 'Attending', 1, '#27ae60'),
('550e8400-e29b-41d4-a716-446655440302', 'maybe', 'Maybe', 2, '#f39c12'),
('550e8400-e29b-41d4-a716-446655440303', 'no', 'Not Attending', 3, '#e74c3c');

-- Home/Away venue statuses
INSERT INTO home_away_statuses (id, name, display_name, description, sort_order) VALUES 
('550e8400-e29b-41d4-a716-446655440801', 'home', 'Home', 'Event at our home venue', 1),
('550e8400-e29b-41d4-a716-446655440802', 'away', 'Away', 'Event at opponent or external venue', 2),
('550e8400-e29b-41d4-a716-446655440803', 'neutral', 'Neutral Venue', 'Event at a neutral/shared venue', 3);

-- Event types for soccer
INSERT INTO event_types (id, sport_id, name, display_name, category, default_duration, requires_opponent) VALUES 
('550e8400-e29b-41d4-a716-446655440401', '550e8400-e29b-41d4-a716-446655440101', 'training', 'Training Session', 'practice', 90, false),
('550e8400-e29b-41d4-a716-446655440402', '550e8400-e29b-41d4-a716-446655440101', 'match', 'Match', 'match', 120, true),
('550e8400-e29b-41d4-a716-446655440403', '550e8400-e29b-41d4-a716-446655440101', 'meeting', 'Team Meeting', 'other', 60, false),
('550e8400-e29b-41d4-a716-446655440404', '550e8400-e29b-41d4-a716-446655440101', 'scrimmage', 'Scrimmage', 'practice', 90, false),
('550e8400-e29b-41d4-a716-446655440405', '550e8400-e29b-41d4-a716-446655440101', 'friendly', 'Friendly Match', 'match', 90, true),
('550e8400-e29b-41d4-a716-446655440406', '550e8400-e29b-41d4-a716-446655440101', 'fitness', 'Fitness Training', 'practice', 60, false);

-- Soccer positions
INSERT INTO positions (id, sport_id, name, display_name, abbreviation, sort_order) VALUES 
('550e8400-e29b-41d4-a716-446655440501', '550e8400-e29b-41d4-a716-446655440101', 'goalkeeper', 'Goalkeeper', 'GK', 1),
('550e8400-e29b-41d4-a716-446655440502', '550e8400-e29b-41d4-a716-446655440101', 'defender', 'Defender', 'DEF', 2),
('550e8400-e29b-41d4-a716-446655440503', '550e8400-e29b-41d4-a716-446655440101', 'midfielder', 'Midfielder', 'MID', 3),
('550e8400-e29b-41d4-a716-446655440504', '550e8400-e29b-41d4-a716-446655440101', 'forward', 'Forward', 'FWD', 4);

-- Roster statuses (for team_players)
INSERT INTO roster_statuses (code, display_name, description, show_in_rsvp, show_in_official_roster, sort_order) VALUES
('active', 'Active Player', 'Currently playing with the team', true, true, 1),
('official_inactive', 'Official Roster (Inactive)', 'On APSL roster but not participating', false, true, 2),
('trial', 'On Trial', 'Trialing with team, not official yet', true, false, 3),
('injured_reserve', 'Injured Reserve', 'Injured, not on official roster', true, false, 4),
('suspended', 'Suspended', 'Temporarily suspended from team', false, true, 5),
('departed', 'Departed', 'No longer with team', false, false, 6);

-- Formations (common soccer formations)
INSERT INTO formations (id, code, name, positions) VALUES
('550e8400-e29b-41d4-a716-446655440f01', '4-4-2', 'Four-Four-Two', '["GK", "LB", "CB1", "CB2", "RB", "LM", "CM1", "CM2", "RM", "ST1", "ST2"]'),
('550e8400-e29b-41d4-a716-446655440f02', '4-3-3', 'Four-Three-Three', '["GK", "LB", "CB1", "CB2", "RB", "CM1", "CM2", "CM3", "LW", "ST", "RW"]'),
('550e8400-e29b-41d4-a716-446655440f03', '3-5-2', 'Three-Five-Two', '["GK", "CB1", "CB2", "CB3", "LWB", "CM1", "CM2", "CM3", "RWB", "ST1", "ST2"]'),
('550e8400-e29b-41d4-a716-446655440f04', '4-2-3-1', 'Four-Two-Three-One', '["GK", "LB", "CB1", "CB2", "RB", "CDM1", "CDM2", "LAM", "CAM", "RAM", "ST"]'),
('550e8400-e29b-41d4-a716-446655440f05', '5-3-2', 'Five-Three-Two', '["GK", "LWB", "CB1", "CB2", "CB3", "RWB", "CM1", "CM2", "CM3", "ST1", "ST2"]'),
('550e8400-e29b-41d4-a716-446655440f06', '4-1-4-1', 'Four-One-Four-One', '["GK", "LB", "CB1", "CB2", "RB", "CDM", "LM", "CM1", "CM2", "RM", "ST"]');

-- Sample teams - removed fake data

-- Sample data removed - database ready for real data only

-- =============================================================================
-- ADDITIONAL NORMALIZED TABLES FOR COMPLETE SYSTEM
-- =============================================================================

-- Notification types lookup table (for granular notification control)
CREATE TABLE notification_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,          -- 'event_created', 'event_cancelled', 'rsvp_reminder'
    display_name VARCHAR(100) NOT NULL,        -- 'Event Created', 'Event Cancelled', 'RSVP Reminder'
    description TEXT,                          -- 'Notification when new events are created'
    category VARCHAR(50),                      -- 'event_management', 'rsvp_system', 'team_updates'
    default_enabled BOOLEAN DEFAULT true,      -- Default setting for new users
    is_system_notification BOOLEAN DEFAULT true, -- Cannot be disabled
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User notification preferences (many-to-many with notification types)
CREATE TABLE user_notification_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- NULL = not yet linked to a user
    notification_type_id UUID NOT NULL REFERENCES notification_types(id) ON DELETE CASCADE,
    email_enabled BOOLEAN DEFAULT true,        -- Send via email
    sms_enabled BOOLEAN DEFAULT false,         -- Send via SMS  
    push_enabled BOOLEAN DEFAULT true,         -- Send push notifications
    advance_hours INTEGER DEFAULT 24,         -- Hours in advance to send (for reminders)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, notification_type_id)
);

-- Recurring pattern types lookup
CREATE TABLE recurrence_patterns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(30) UNIQUE NOT NULL,          -- 'weekly', 'biweekly', 'monthly'
    display_name VARCHAR(50) NOT NULL,         -- 'Weekly', 'Every 2 Weeks', 'Monthly'
    description TEXT,                          -- 'Repeats every week on the same day'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Event recurrence (for recurring training sessions, etc.)
CREATE TABLE event_recurrences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE, -- Template event
    recurrence_pattern_id UUID NOT NULL REFERENCES recurrence_patterns(id),
    start_date DATE NOT NULL,                  -- When recurrence begins
    end_date DATE,                            -- When recurrence ends (NULL = indefinite)
    interval_count INTEGER DEFAULT 1,         -- Every N weeks/months
    days_of_week INTEGER[],                   -- For weekly: [1,3,5] = Mon,Wed,Fri
    week_of_month INTEGER,                    -- For monthly: 1st week, 2nd week, etc.
    max_occurrences INTEGER,                  -- Alternative to end_date
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure either end_date or max_occurrences is specified, but not both
    CONSTRAINT recurrence_end_constraint CHECK (
        (end_date IS NOT NULL AND max_occurrences IS NULL) OR
        (end_date IS NULL AND max_occurrences IS NOT NULL) OR
        (end_date IS NOT NULL AND max_occurrences IS NOT NULL)
    )
);

-- Generated events from recurring patterns
CREATE TABLE recurring_event_instances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_recurrence_id UUID NOT NULL REFERENCES event_recurrences(id) ON DELETE CASCADE,
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    occurrence_date DATE NOT NULL,             -- Which occurrence this represents
    is_exception BOOLEAN DEFAULT false,       -- Was this instance modified from template?
    exception_reason TEXT,                    -- Why this instance was modified
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(event_recurrence_id, occurrence_date)
);

-- Notification log (audit trail of sent notifications)
CREATE TABLE notification_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- NULL = not yet linked to a user
    notification_type_id UUID NOT NULL REFERENCES notification_types(id),
    event_id UUID REFERENCES events(id) ON DELETE SET NULL, -- Related event (if applicable)
    delivery_method VARCHAR(20) NOT NULL,      -- 'email', 'sms', 'push'
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'sent',         -- 'sent', 'failed', 'delivered', 'read'
    message_content TEXT,                      -- The actual message sent
    recipient_address VARCHAR(255),            -- Email/phone where sent
    error_message TEXT,                       -- If delivery failed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT valid_delivery_method CHECK (delivery_method IN ('email', 'sms', 'push')),
    CONSTRAINT valid_status CHECK (status IN ('sent', 'failed', 'delivered', 'read', 'bounced'))
);

-- Session management (for better security)
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- NULL = not yet linked to a user
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE,
    ip_address INET,                          -- Client IP address
    user_agent TEXT,                          -- Browser/app info
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_accessed TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT true
);

-- Additional indexes for new tables
CREATE INDEX idx_notification_prefs_user ON user_notification_preferences(user_id);
CREATE INDEX idx_notification_prefs_type ON user_notification_preferences(notification_type_id);
CREATE INDEX idx_event_recurrences_parent ON event_recurrences(parent_event_id);
CREATE INDEX idx_event_recurrences_pattern ON event_recurrences(recurrence_pattern_id);
CREATE INDEX idx_recurring_instances_recurrence ON recurring_event_instances(event_recurrence_id);
CREATE INDEX idx_recurring_instances_event ON recurring_event_instances(event_id);
CREATE INDEX idx_notification_log_user ON notification_log(user_id);
CREATE INDEX idx_notification_log_event ON notification_log(event_id);
CREATE INDEX idx_notification_log_sent_at ON notification_log(sent_at);
CREATE INDEX idx_user_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_user_sessions_expires ON user_sessions(expires_at);
CREATE INDEX idx_notification_types_category ON notification_types(category);
CREATE INDEX idx_recurrence_patterns_name ON recurrence_patterns(name);

-- Insert notification types
INSERT INTO notification_types (id, name, display_name, description, category, default_enabled, is_system_notification) VALUES
('550e8400-e29b-41d4-a716-446655440901', 'event_created', 'Event Created', 'Notification when new events are created', 'event_management', true, false),
('550e8400-e29b-41d4-a716-446655440902', 'event_cancelled', 'Event Cancelled', 'Notification when events are cancelled', 'event_management', true, true),
('550e8400-e29b-41d4-a716-446655440903', 'event_updated', 'Event Updated', 'Notification when event details change', 'event_management', true, false),
('550e8400-e29b-41d4-a716-446655440904', 'rsvp_reminder', 'RSVP Reminder', 'Reminder to respond to event invitations', 'rsvp_system', true, false),
('550e8400-e29b-41d4-a716-446655440905', 'event_reminder', 'Event Reminder', 'Reminder about upcoming events', 'rsvp_system', true, false),
('550e8400-e29b-41d4-a716-446655440906', 'team_announcement', 'Team Announcement', 'General team announcements', 'team_updates', true, false),
('550e8400-e29b-41d4-a716-446655440907', 'roster_changes', 'Roster Changes', 'Notification of team roster updates', 'team_updates', false, false),
('550e8400-e29b-41d4-a716-446655440908', 'match_result', 'Match Results', 'Notification of match scores and results', 'team_updates', true, false);

-- Insert recurrence patterns
INSERT INTO recurrence_patterns (id, name, display_name, description) VALUES
('550e8400-e29b-41d4-a716-446655441001', 'weekly', 'Weekly', 'Repeats every week on the same day and time'),
('550e8400-e29b-41d4-a716-446655441002', 'biweekly', 'Every 2 Weeks', 'Repeats every two weeks on the same day'),
('550e8400-e29b-41d4-a716-446655441003', 'monthly', 'Monthly', 'Repeats monthly on the same date'),
('550e8400-e29b-41d4-a716-446655441004', 'monthly_by_day', 'Monthly by Day', 'Repeats monthly on the same day of week (e.g., first Monday)'),
('550e8400-e29b-41d4-a716-446655441005', 'custom', 'Custom Pattern', 'Custom recurrence pattern defined by interval');

-- Insert default notification preferences for existing users
INSERT INTO user_notification_preferences (user_id, notification_type_id, email_enabled, sms_enabled, push_enabled)
SELECT 
    u.id as user_id,
    nt.id as notification_type_id,
    nt.default_enabled as email_enabled,
    false as sms_enabled,  -- SMS disabled by default
    nt.default_enabled as push_enabled
FROM users u
CROSS JOIN notification_types nt
ON CONFLICT (user_id, notification_type_id) DO NOTHING;

-- === GOOGLE PLACES INTEGRATION VIEWS ===

-- Venues with Google data view
CREATE OR REPLACE VIEW venues_with_google_data AS
SELECT 
    id, name, venue_type, address, formatted_address, city, state, postal_code, country,
    latitude, longitude, place_id, rating, user_ratings_total, price_level, business_status,
    google_types, opening_hours, photos, data_source, phone, website, capacity, surface_type,
    parking_available, wheelchair_accessible, notes, is_active, created_at, updated_at,
    last_google_update,
    CASE 
        WHEN rating IS NOT NULL AND rating >= 4.5 THEN 'Excellent'
        WHEN rating IS NOT NULL AND rating >= 4.0 THEN 'Very Good'
        WHEN rating IS NOT NULL AND rating >= 3.5 THEN 'Good'
        WHEN rating IS NOT NULL AND rating >= 3.0 THEN 'Average'
        WHEN rating IS NOT NULL THEN 'Below Average'
        ELSE 'No Rating'
    END as rating_category,
    CASE WHEN data_source = 'google_places' THEN true ELSE false END as is_google_venue,
    CASE WHEN place_id IS NOT NULL THEN true ELSE false END as has_google_data
FROM venues
WHERE is_active = true;

-- Venues Google mapping view
CREATE OR REPLACE VIEW venues_google_mapping AS
SELECT 
    id, name, place_id, formatted_address,
    latitude as lat, longitude as lng,
    phone as formatted_phone_number, international_phone_number,
    website, rating, user_ratings_total, price_level, business_status,
    google_types as types, opening_hours, photos,
    venue_type, capacity, surface_type, parking_available, wheelchair_accessible, data_source
FROM venues
WHERE is_active = true;

-- Record this as the baseline schema (no migrations needed for fresh installs)
INSERT INTO schema_migrations (filename, checksum) VALUES
('000_baseline_schema.sql', 'production_ready_baseline_v4.0')
ON CONFLICT (filename) DO NOTHING;

-- Add helpful comments for Google Places integration
COMMENT ON TABLE venues IS 'Venues table with complete Google Places integration';
COMMENT ON COLUMN venues.phone IS 'Primary phone number (Google: formatted_phone_number)';
COMMENT ON COLUMN venues.email IS 'Contact email address';
COMMENT ON COLUMN venues.international_phone_number IS 'International format phone number from Google Places';
COMMENT ON COLUMN venues.place_id IS 'Google Places unique identifier';
COMMENT ON COLUMN venues.rating IS 'Google Places rating (1.0-5.0)';
COMMENT ON COLUMN venues.user_ratings_total IS 'Number of Google reviews';
COMMENT ON COLUMN venues.data_source IS 'Source of venue data (google_places, user_added, imported)';
COMMENT ON VIEW venues_with_google_data IS 'Enhanced venue view with Google Places data and calculated fields';
COMMENT ON VIEW venues_google_mapping IS 'Venue data with Google Places standard field names for API consistency';

-- ========================================
-- INITIAL USER SETUP
-- ========================================
-- Create admin user with bcrypt password hash (password: 1893Soccer!)
-- Hash generated using: SELECT crypt('1893Soccer!', gen_salt('bf'));
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'soccer@lighthouse1893.org',
    'James',
    'Breslin',
    crypt('1893Soccer!', gen_salt('bf')),
    true
)
ON CONFLICT (email) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    updated_at = CURRENT_TIMESTAMP;

-- Create admin entity for this user
INSERT INTO admins (id, admin_level, notes)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'system',
    'System administrator with full access'
)
ON CONFLICT (id) DO NOTHING;

-- Grant all permissions to system admin via junction table
INSERT INTO admin_permissions (admin_id, permission_id)
SELECT 
    '77d77471-1250-47e0-81ab-d4626595d63c',
    id
FROM permissions
WHERE is_system_permission = true
ON CONFLICT (admin_id, permission_id) DO NOTHING;

-- ========================================
-- APSL LEAGUE DATA (AUTO-LOADED)
-- ========================================
-- APSL data is scraped from apslsoccer.com and auto-loaded on rebuild
-- Includes: All conferences, divisions, teams, and player rosters
-- 
-- File: apsl-data.sql (generated by scrape-apsl.sh)
-- Control scraping with APSL_SCRAPE environment variable:
--   APSL_SCRAPE=true   - Force fresh scrape on rebuild
--   APSL_SCRAPE=false  - Skip scraping, use existing data
--   (not set)          - Auto-scrape if data is >24 hours old
--
-- Note: This file is loaded automatically via docker-entrypoint-initdb.d
-- PostgreSQL loads SQL files in alphabetical order:
--   01-init.sql    (this file - schema)
--   02-apsl-data.sql (APSL league data)
--
-- To regenerate manually:
--   cd database && ./scrape-apsl.sh

-- ========================================
-- GOOGLE PLACES VENUES DATA
-- ========================================
-- Venues fetched from Google Places API and saved as static SQL inserts
-- This avoids API costs on every rebuild and ensures consistent venue data
-- 
-- Files:
--   - venues-google-philadelphia.sql: Philadelphia area venues (50km radius)
--
-- To add new areas:
--   1. Run: node ~/fetch-google-venues.js --location "Lancaster, PA" --radius 25000 > database/venues-google-lancaster.sql
--   2. Add: \i database/venues-google-lancaster.sql
--
-- Note: These files are imported when running database initialization
-- Using Docker: docker exec -i footballhome-database-1 psql -U postgres -d footballhome < database/venues-google-philadelphia.sql

-- ==============================================
-- Login History Table
-- ==============================================
-- Tracks all login instances for audit and security purposes

CREATE TABLE IF NOT EXISTS login_history (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- NULL = not yet linked to a user
    login_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),  -- IPv6 can be up to 45 chars
    user_agent TEXT,
    success BOOLEAN NOT NULL DEFAULT true
);

-- Indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_login_history_user_id ON login_history(user_id);
CREATE INDEX IF NOT EXISTS idx_login_history_login_time ON login_history(login_time);

-- Comments
COMMENT ON TABLE login_history IS 'Tracks all login attempts for security auditing';
COMMENT ON COLUMN login_history.user_id IS 'Reference to the user who logged in';
COMMENT ON COLUMN login_history.login_time IS 'Timestamp when login occurred';
COMMENT ON COLUMN login_history.ip_address IS 'IP address of the login attempt';
COMMENT ON COLUMN login_history.user_agent IS 'Browser user agent string';
COMMENT ON COLUMN login_history.success IS 'Whether the login was successful';

-- ==============================================
-- ATTENDANCE SYSTEM
-- ==============================================
-- Tracks player attendance at events, auto-populated from RSVPs

-- Attendance statuses lookup table
CREATE TABLE attendance_statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20) UNIQUE NOT NULL,          -- 'present', 'absent', 'late', 'excused', 'unknown'
    display_name VARCHAR(50) NOT NULL,         -- 'Present', 'Absent', 'Late', 'Excused', 'Unknown'
    sort_order INTEGER DEFAULT 0,
    color VARCHAR(7),                          -- Hex color for UI
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert attendance statuses
INSERT INTO attendance_statuses (name, display_name, sort_order, color) VALUES
('present', 'Present', 1, '#27ae60'),
('absent', 'Absent', 2, '#e74c3c'),
('late', 'Late', 3, '#f39c12'),
('excused', 'Excused', 4, '#3498db'),
('unknown', 'Unknown', 5, '#95a5a6');

-- Event attendance table (one row per player per event)
CREATE TABLE event_attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    status_id INT NOT NULL REFERENCES attendance_statuses(id),
    rsvp_snapshot_id UUID REFERENCES rsvp_statuses(id),  -- What their RSVP was when record created
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),       -- Coach who edited, if any
    UNIQUE(event_id, player_id)
);

-- Indexes for attendance queries
CREATE INDEX idx_event_attendance_event ON event_attendance(event_id);
CREATE INDEX idx_event_attendance_player ON event_attendance(player_id);
CREATE INDEX idx_event_attendance_status ON event_attendance(status_id);
CREATE INDEX idx_event_attendance_created ON event_attendance(created_at);

-- Comments
COMMENT ON TABLE event_attendance IS 'Player attendance records, auto-populated from RSVPs at event start/end';
COMMENT ON COLUMN event_attendance.rsvp_snapshot_id IS 'RSVP status at time attendance was created';
COMMENT ON COLUMN event_attendance.updated_by IS 'Coach who manually edited, NULL if auto-generated';

-- ==============================================
-- ATTENDANCE AUTO-CREATION FUNCTION
-- ==============================================
-- This function creates attendance records from RSVPs
-- Called by pg_cron at event start and event end

CREATE OR REPLACE FUNCTION create_attendance_from_rsvps(p_event_id UUID)
RETURNS INTEGER AS $$
DECLARE
    rows_affected INTEGER := 0;
    v_team_id UUID;
    v_rsvp_yes_id UUID;
    v_rsvp_no_id UUID;
    v_rsvp_maybe_id UUID;
    v_status_present INT;
    v_status_absent INT;
    v_status_unknown INT;
BEGIN
    -- Get RSVP status IDs
    SELECT id INTO v_rsvp_yes_id FROM rsvp_statuses WHERE name = 'yes';
    SELECT id INTO v_rsvp_no_id FROM rsvp_statuses WHERE name = 'no';
    SELECT id INTO v_rsvp_maybe_id FROM rsvp_statuses WHERE name = 'maybe';
    
    -- Get attendance status IDs
    SELECT id INTO v_status_present FROM attendance_statuses WHERE name = 'present';
    SELECT id INTO v_status_absent FROM attendance_statuses WHERE name = 'absent';
    SELECT id INTO v_status_unknown FROM attendance_statuses WHERE name = 'unknown';
    
    -- Get the team_id for this event (from practices table)
    SELECT team_id INTO v_team_id FROM practices WHERE id = p_event_id;
    
    -- If not a practice, try matches
    IF v_team_id IS NULL THEN
        SELECT home_team_id INTO v_team_id FROM matches WHERE id = p_event_id;
    END IF;
    
    -- If no team found, exit
    IF v_team_id IS NULL THEN
        RETURN 0;
    END IF;
    
    -- Insert/update attendance for all team players based on their current RSVP
    INSERT INTO event_attendance (event_id, player_id, status_id, rsvp_snapshot_id, notes)
    SELECT 
        p_event_id,
        tp.player_id,
        CASE 
            WHEN prc.rsvp_status_id = v_rsvp_yes_id THEN v_status_present
            WHEN prc.rsvp_status_id = v_rsvp_no_id THEN v_status_absent
            ELSE v_status_unknown
        END,
        prc.rsvp_status_id,
        CASE 
            WHEN prc.rsvp_status_id IS NULL THEN 'No RSVP submitted'
            ELSE NULL
        END
    FROM team_players tp
    LEFT JOIN player_rsvps_current prc 
        ON prc.player_id = tp.player_id 
        AND prc.event_id = p_event_id
    WHERE tp.team_id = v_team_id
        AND tp.is_active = true
    ON CONFLICT (event_id, player_id) 
    DO UPDATE SET
        -- Only update if the RSVP changed (for event-end re-run)
        status_id = CASE 
            WHEN EXCLUDED.rsvp_snapshot_id != event_attendance.rsvp_snapshot_id 
                 AND event_attendance.updated_by IS NULL  -- Don't overwrite coach edits
            THEN EXCLUDED.status_id
            ELSE event_attendance.status_id
        END,
        rsvp_snapshot_id = COALESCE(EXCLUDED.rsvp_snapshot_id, event_attendance.rsvp_snapshot_id),
        updated_at = CASE 
            WHEN EXCLUDED.rsvp_snapshot_id != event_attendance.rsvp_snapshot_id 
                 AND event_attendance.updated_by IS NULL
            THEN NOW()
            ELSE event_attendance.updated_at
        END;
    
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    RETURN rows_affected;
END;
$$ LANGUAGE plpgsql;

-- ==============================================
-- ATTENDANCE CRON JOB FUNCTION
-- ==============================================
-- This function is called every minute by pg_cron
-- It finds events that just started or just ended and creates attendance

CREATE OR REPLACE FUNCTION process_attendance_snapshots()
RETURNS TABLE(event_id UUID, snapshot_type TEXT, rows_created INTEGER) AS $$
DECLARE
    v_event RECORD;
    v_rows INTEGER;
BEGIN
    -- Process events that started in the last 2 minutes
    FOR v_event IN 
        SELECT e.id, 'start' as snap_type
        FROM events e
        JOIN event_types et ON e.event_type_id = et.id
        WHERE e.cancelled = false
        AND e.event_date <= NOW()
        AND e.event_date > NOW() - INTERVAL '2 minutes'
        AND NOT EXISTS (
            SELECT 1 FROM event_attendance ea WHERE ea.event_id = e.id
        )
    LOOP
        v_rows := create_attendance_from_rsvps(v_event.id);
        event_id := v_event.id;
        snapshot_type := v_event.snap_type;
        rows_created := v_rows;
        RETURN NEXT;
    END LOOP;
    
    -- Process events that ended in the last 2 minutes (catch late RSVPs)
    FOR v_event IN 
        SELECT e.id, 'end' as snap_type
        FROM events e
        JOIN event_types et ON e.event_type_id = et.id
        WHERE e.cancelled = false
        AND (e.event_date + INTERVAL '1 minute' * COALESCE(e.duration_minutes, et.default_duration)) <= NOW()
        AND (e.event_date + INTERVAL '1 minute' * COALESCE(e.duration_minutes, et.default_duration)) > NOW() - INTERVAL '2 minutes'
        AND EXISTS (
            SELECT 1 FROM event_attendance ea WHERE ea.event_id = e.id
        )
    LOOP
        v_rows := create_attendance_from_rsvps(v_event.id);
        event_id := v_event.id;
        snapshot_type := v_event.snap_type;
        rows_created := v_rows;
        RETURN NEXT;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Log table for attendance cron jobs
CREATE TABLE attendance_cron_log (
    id SERIAL PRIMARY KEY,
    run_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    events_processed INTEGER DEFAULT 0,
    details JSONB
);

COMMENT ON TABLE attendance_cron_log IS 'Log of attendance auto-creation cron job runs';

-- ========================================
-- CLUB/DIVISION PLAYER REGISTRY
-- ========================================
-- division_players table removed - players are now inferred from team memberships
-- Dynamic aggregation from team_players is used in API queries instead

-- =====================================================
-- Player Availability Tracking System
-- =====================================================
CREATE TABLE player_medical_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'healthy',
    injury_type VARCHAR(100),
    severity VARCHAR(20),
    available_for_practices BOOLEAN NOT NULL DEFAULT true,
    available_for_games BOOLEAN NOT NULL DEFAULT true,
    injury_date DATE,
    expected_return_date DATE,
    actual_return_date DATE,
    medical_clearance_required BOOLEAN DEFAULT false,
    medical_clearance_date DATE,
    medical_provider VARCHAR(200),
    affects_all_teams BOOLEAN DEFAULT true,
    team_id UUID REFERENCES teams(id),
    notes TEXT,
    treatment_plan TEXT,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    resolved_by UUID REFERENCES users(id),
    CONSTRAINT medical_status_values CHECK (status IN ('healthy', 'injured', 'recovering', 'ill', 'concussion_protocol')),
    CONSTRAINT severity_values CHECK (severity IN ('minor', 'moderate', 'severe') OR severity IS NULL),
    CONSTRAINT team_scope_valid CHECK ((affects_all_teams = true AND team_id IS NULL) OR (affects_all_teams = false AND team_id IS NOT NULL))
);

CREATE TABLE player_academic_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'eligible',
    gpa DECIMAL(3,2),
    required_gpa DECIMAL(3,2),
    credits_enrolled INTEGER,
    required_credits INTEGER,
    available_for_practices BOOLEAN NOT NULL DEFAULT true,
    available_for_games BOOLEAN NOT NULL DEFAULT true,
    status_start_date DATE NOT NULL,
    status_end_date DATE,
    review_date DATE,
    affects_all_teams BOOLEAN DEFAULT true,
    team_id UUID REFERENCES teams(id),
    academic_term VARCHAR(50),
    school_name VARCHAR(200),
    notes TEXT,
    improvement_plan TEXT,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    resolved_by UUID REFERENCES users(id),
    CONSTRAINT academic_status_values CHECK (status IN ('eligible', 'ineligible', 'probation', 'restricted')),
    CONSTRAINT academic_team_scope_valid CHECK ((affects_all_teams = true AND team_id IS NULL) OR (affects_all_teams = false AND team_id IS NOT NULL))
);

CREATE TABLE player_medical_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    medical_status_id UUID NOT NULL REFERENCES player_medical_status(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    field_changed VARCHAR(50) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_by UUID NOT NULL REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT
);

CREATE TABLE player_academic_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    academic_status_id UUID NOT NULL REFERENCES player_academic_status(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    field_changed VARCHAR(50) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_by UUID NOT NULL REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT
);

CREATE INDEX idx_medical_status_player ON player_medical_status(player_id);
CREATE INDEX idx_medical_status_active ON player_medical_status(player_id) WHERE resolved_at IS NULL;
CREATE INDEX idx_medical_status_team ON player_medical_status(team_id) WHERE team_id IS NOT NULL;
CREATE INDEX idx_academic_status_player ON player_academic_status(player_id);
CREATE INDEX idx_academic_status_active ON player_academic_status(player_id) WHERE resolved_at IS NULL;
CREATE INDEX idx_academic_status_team ON player_academic_status(team_id) WHERE team_id IS NOT NULL;
CREATE INDEX idx_medical_history_status ON player_medical_status_history(medical_status_id);
CREATE INDEX idx_academic_history_status ON player_academic_status_history(academic_status_id);

-- ========================================
-- PRACTICE TEAMS JUNCTION TABLE
-- ========================================
CREATE TABLE IF NOT EXISTS practice_teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    practice_id UUID NOT NULL REFERENCES practices(id) ON DELETE CASCADE,
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(practice_id, team_id)
);

CREATE INDEX idx_practice_teams_practice ON practice_teams(practice_id);
CREATE INDEX idx_practice_teams_team ON practice_teams(team_id);

CREATE OR REPLACE FUNCTION sync_practice_teams()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO practice_teams (practice_id, team_id, is_primary)
        VALUES (NEW.id, NEW.team_id, true)
        ON CONFLICT (practice_id, team_id) DO NOTHING;
    ELSIF (TG_OP = 'UPDATE' AND OLD.team_id != NEW.team_id) THEN
        DELETE FROM practice_teams 
        WHERE practice_id = OLD.id AND team_id = OLD.team_id AND is_primary = true;
        INSERT INTO practice_teams (practice_id, team_id, is_primary)
        VALUES (NEW.id, NEW.team_id, true)
        ON CONFLICT (practice_id, team_id) 
        DO UPDATE SET is_primary = true;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_practice_teams ON practices;
CREATE TRIGGER trg_sync_practice_teams
AFTER INSERT OR UPDATE OF team_id ON practices
FOR EACH ROW
EXECUTE FUNCTION sync_practice_teams();

INSERT INTO practice_teams (practice_id, team_id, is_primary)
SELECT id, team_id, true
FROM practices
ON CONFLICT DO NOTHING;
