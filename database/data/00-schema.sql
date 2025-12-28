-- Football Home Database Schema - Complete Refactored Architecture
-- Version: 5.0 - External League Systems + FootballHome Identity Layer
--
-- Architecture:
-- 1. APSL League System (8 tables) - Source of truth for APSL data
-- 2. CASA League System (8 tables) - Source of truth for CASA data
-- 3. Custom Leagues (8 tables) - Club-created leagues
-- 4. GroupMe Integration (2 tables) - Calendar events and RSVPs
-- 5. FootballHome Identity (10 tables) - Users, clubs, players, groups
-- 6. Junction Tables (8 tables) - Link external systems to FootballHome
-- 7. Events & RSVP (7 tables) - Event orchestration layer
-- 8. Supporting Tables (3 tables) - Venues, audit log

-- Create database extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- SUPPORTING TABLES
-- ============================================================================

-- Venues (shared across all leagues)
CREATE TABLE venues (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(2),
    zip VARCHAR(10),
    google_place_id VARCHAR(255) UNIQUE,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    field_count INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit logging
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id INTEGER,
    operation VARCHAR(10) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by INTEGER,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_log_table_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_log_changed_at ON audit_log(changed_at DESC);

-- ============================================================================
-- 1. APSL LEAGUE SYSTEM (Source of Truth)
-- ============================================================================

CREATE TABLE apsl_leagues (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    season VARCHAR(50) NOT NULL,
    website_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, season)
);

CREATE TABLE apsl_conferences (
    id SERIAL PRIMARY KEY,
    apsl_league_id INTEGER NOT NULL REFERENCES apsl_leagues(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    abbreviation VARCHAR(10),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(apsl_league_id, name)
);

CREATE TABLE apsl_divisions (
    id SERIAL PRIMARY KEY,
    apsl_conference_id INTEGER NOT NULL REFERENCES apsl_conferences(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    age_group VARCHAR(50),
    skill_level VARCHAR(50),
    gender VARCHAR(20),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(apsl_conference_id, name)
);

CREATE TABLE apsl_teams (
    id SERIAL PRIMARY KEY,
    apsl_division_id INTEGER NOT NULL REFERENCES apsl_divisions(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    logo_url TEXT,
    apsl_team_id VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(apsl_division_id, name)
);

CREATE TABLE apsl_players (
    id SERIAL PRIMARY KEY,
    apsl_team_id INTEGER NOT NULL REFERENCES apsl_teams(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    jersey_number VARCHAR(10),
    position VARCHAR(50),
    apsl_player_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE apsl_matches (
    id SERIAL PRIMARY KEY,
    apsl_division_id INTEGER NOT NULL REFERENCES apsl_divisions(id) ON DELETE CASCADE,
    home_team_id INTEGER REFERENCES apsl_teams(id),
    away_team_id INTEGER REFERENCES apsl_teams(id),
    match_date DATE NOT NULL,
    match_time TIME,
    venue_id INTEGER REFERENCES venues(id),
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled', 'postponed')),
    home_score INTEGER,
    away_score INTEGER,
    apsl_match_id VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE apsl_player_stats (
    id SERIAL PRIMARY KEY,
    apsl_match_id INTEGER REFERENCES apsl_matches(id) ON DELETE CASCADE,
    apsl_player_id INTEGER NOT NULL REFERENCES apsl_players(id) ON DELETE CASCADE,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(apsl_match_id, apsl_player_id)
);

CREATE TABLE apsl_team_stats (
    id SERIAL PRIMARY KEY,
    apsl_division_id INTEGER NOT NULL REFERENCES apsl_divisions(id) ON DELETE CASCADE,
    apsl_team_id INTEGER NOT NULL REFERENCES apsl_teams(id) ON DELETE CASCADE,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    ties INTEGER DEFAULT 0,
    goals_for INTEGER DEFAULT 0,
    goals_against INTEGER DEFAULT 0,
    points INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(apsl_division_id, apsl_team_id)
);

-- APSL Indexes
CREATE INDEX idx_apsl_conferences_league ON apsl_conferences(apsl_league_id);
CREATE INDEX idx_apsl_divisions_conference ON apsl_divisions(apsl_conference_id);
CREATE INDEX idx_apsl_teams_division ON apsl_teams(apsl_division_id);
CREATE INDEX idx_apsl_players_team ON apsl_players(apsl_team_id);
CREATE INDEX idx_apsl_matches_division ON apsl_matches(apsl_division_id);
CREATE INDEX idx_apsl_matches_date ON apsl_matches(match_date);
CREATE INDEX idx_apsl_matches_teams ON apsl_matches(home_team_id, away_team_id);

-- ============================================================================
-- 2. CASA LEAGUE SYSTEM (Mirror of APSL)
-- ============================================================================

CREATE TABLE casa_leagues (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    season VARCHAR(50) NOT NULL,
    website_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, season)
);

CREATE TABLE casa_conferences (
    id SERIAL PRIMARY KEY,
    casa_league_id INTEGER NOT NULL REFERENCES casa_leagues(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    abbreviation VARCHAR(10),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(casa_league_id, name)
);

CREATE TABLE casa_divisions (
    id SERIAL PRIMARY KEY,
    casa_conference_id INTEGER NOT NULL REFERENCES casa_conferences(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    age_group VARCHAR(50),
    skill_level VARCHAR(50),
    gender VARCHAR(20),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(casa_conference_id, name)
);

CREATE TABLE casa_teams (
    id SERIAL PRIMARY KEY,
    casa_division_id INTEGER NOT NULL REFERENCES casa_divisions(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    logo_url TEXT,
    casa_team_id VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(casa_division_id, name)
);

CREATE TABLE casa_players (
    id SERIAL PRIMARY KEY,
    casa_team_id INTEGER NOT NULL REFERENCES casa_teams(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    jersey_number VARCHAR(10),
    position VARCHAR(50),
    casa_player_id VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE casa_matches (
    id SERIAL PRIMARY KEY,
    casa_division_id INTEGER NOT NULL REFERENCES casa_divisions(id) ON DELETE CASCADE,
    home_team_id INTEGER NOT NULL REFERENCES casa_teams(id),
    away_team_id INTEGER NOT NULL REFERENCES casa_teams(id),
    match_date DATE NOT NULL,
    match_time TIME,
    venue_id INTEGER REFERENCES venues(id),
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled', 'postponed')),
    home_score INTEGER,
    away_score INTEGER,
    casa_match_id VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE casa_player_stats (
    id SERIAL PRIMARY KEY,
    casa_match_id INTEGER NOT NULL REFERENCES casa_matches(id) ON DELETE CASCADE,
    casa_player_id INTEGER NOT NULL REFERENCES casa_players(id) ON DELETE CASCADE,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(casa_match_id, casa_player_id)
);

CREATE TABLE casa_team_stats (
    id SERIAL PRIMARY KEY,
    casa_division_id INTEGER NOT NULL REFERENCES casa_divisions(id) ON DELETE CASCADE,
    casa_team_id INTEGER NOT NULL REFERENCES casa_teams(id) ON DELETE CASCADE,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    ties INTEGER DEFAULT 0,
    goals_for INTEGER DEFAULT 0,
    goals_against INTEGER DEFAULT 0,
    points INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(casa_division_id, casa_team_id)
);

-- CASA Indexes
CREATE INDEX idx_casa_conferences_league ON casa_conferences(casa_league_id);
CREATE INDEX idx_casa_divisions_conference ON casa_divisions(casa_conference_id);
CREATE INDEX idx_casa_teams_division ON casa_teams(casa_division_id);
CREATE INDEX idx_casa_players_team ON casa_players(casa_team_id);
CREATE INDEX idx_casa_matches_division ON casa_matches(casa_division_id);
CREATE INDEX idx_casa_matches_date ON casa_matches(match_date);
CREATE INDEX idx_casa_matches_teams ON casa_matches(home_team_id, away_team_id);

-- ============================================================================
-- 3. CUSTOM LEAGUES (Club-Created)
-- ============================================================================

CREATE TABLE custom_leagues (
    id SERIAL PRIMARY KEY,
    created_by_club_id INTEGER,  -- Will reference clubs after that table is created
    name VARCHAR(255) NOT NULL,
    season VARCHAR(50),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE custom_conferences (
    id SERIAL PRIMARY KEY,
    custom_league_id INTEGER NOT NULL REFERENCES custom_leagues(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    abbreviation VARCHAR(10),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(custom_league_id, name)
);

CREATE TABLE custom_divisions (
    id SERIAL PRIMARY KEY,
    custom_conference_id INTEGER NOT NULL REFERENCES custom_conferences(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    age_group VARCHAR(50),
    skill_level VARCHAR(50),
    gender VARCHAR(20),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(custom_conference_id, name)
);

CREATE TABLE custom_teams (
    id SERIAL PRIMARY KEY,
    custom_division_id INTEGER NOT NULL REFERENCES custom_divisions(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    logo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(custom_division_id, name)
);

CREATE TABLE custom_players (
    id SERIAL PRIMARY KEY,
    custom_team_id INTEGER NOT NULL REFERENCES custom_teams(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    jersey_number VARCHAR(10),
    position VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE custom_matches (
    id SERIAL PRIMARY KEY,
    custom_division_id INTEGER NOT NULL REFERENCES custom_divisions(id) ON DELETE CASCADE,
    home_team_id INTEGER NOT NULL REFERENCES custom_teams(id),
    away_team_id INTEGER NOT NULL REFERENCES custom_teams(id),
    match_date DATE NOT NULL,
    match_time TIME,
    venue_id INTEGER REFERENCES venues(id),
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled', 'postponed')),
    home_score INTEGER,
    away_score INTEGER,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE custom_player_stats (
    id SERIAL PRIMARY KEY,
    custom_match_id INTEGER NOT NULL REFERENCES custom_matches(id) ON DELETE CASCADE,
    custom_player_id INTEGER NOT NULL REFERENCES custom_players(id) ON DELETE CASCADE,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(custom_match_id, custom_player_id)
);

CREATE TABLE custom_team_stats (
    id SERIAL PRIMARY KEY,
    custom_division_id INTEGER NOT NULL REFERENCES custom_divisions(id) ON DELETE CASCADE,
    custom_team_id INTEGER NOT NULL REFERENCES custom_teams(id) ON DELETE CASCADE,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    ties INTEGER DEFAULT 0,
    goals_for INTEGER DEFAULT 0,
    goals_against INTEGER DEFAULT 0,
    points INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(custom_division_id, custom_team_id)
);

-- Custom League Indexes
CREATE INDEX idx_custom_conferences_league ON custom_conferences(custom_league_id);
CREATE INDEX idx_custom_divisions_conference ON custom_divisions(custom_conference_id);
CREATE INDEX idx_custom_teams_division ON custom_teams(custom_division_id);
CREATE INDEX idx_custom_players_team ON custom_players(custom_team_id);
CREATE INDEX idx_custom_matches_division ON custom_matches(custom_division_id);
CREATE INDEX idx_custom_matches_date ON custom_matches(match_date);

-- ============================================================================
-- 4. GROUPME INTEGRATION
-- ============================================================================

CREATE TABLE groupme_calendar_events (
    id SERIAL PRIMARY KEY,
    groupme_event_id VARCHAR(100) UNIQUE NOT NULL,
    groupme_group_id VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    location TEXT,
    starts_at TIMESTAMP,
    ends_at TIMESTAMP,
    scraped_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE groupme_calendar_event_rsvps (
    id SERIAL PRIMARY KEY,
    groupme_calendar_event_id INTEGER NOT NULL REFERENCES groupme_calendar_events(id) ON DELETE CASCADE,
    groupme_user_id VARCHAR(100) NOT NULL,
    groupme_user_name VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('going', 'not_going', 'maybe')),
    scraped_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(groupme_calendar_event_id, groupme_user_id)
);

CREATE INDEX idx_groupme_events_group ON groupme_calendar_events(groupme_group_id);
CREATE INDEX idx_groupme_rsvps_event ON groupme_calendar_event_rsvps(groupme_calendar_event_id);

-- ============================================================================
-- 5. FOOTBALLHOME IDENTITY LAYER
-- ============================================================================

-- Users (authentication)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Admin privileges
CREATE TABLE admins (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    admin_level VARCHAR(20) NOT NULL CHECK (admin_level IN ('super', 'club', 'team')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Clubs (ALL clubs exist - from scraping)
CREATE TABLE clubs (
    id SERIAL PRIMARY KEY,
    display_name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    logo_url TEXT,
    website TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Club admins junction (presence = active club, absence = NPC)
CREATE TABLE club_admins (
    id SERIAL PRIMARY KEY,
    club_id INTEGER NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    admin_id INTEGER NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    admin_role VARCHAR(50),
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(club_id, admin_id)
);

-- Unified player identity across leagues
CREATE TABLE players (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    primary_name VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Coaches (players who also coach)
CREATE TABLE coaches (
    id SERIAL PRIMARY KEY,
    player_id INTEGER UNIQUE NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    license_level VARCHAR(50),
    certifications TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sport divisions (organizational units within clubs)
CREATE TABLE sport_divisions (
    id SERIAL PRIMARY KEY,
    club_id INTEGER NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    display_name VARCHAR(255) NOT NULL,
    sport VARCHAR(50) DEFAULT 'soccer',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(club_id, display_name)
);

-- Groups within sport divisions (teams, training groups, etc.)
CREATE TABLE sport_division_groups (
    id SERIAL PRIMARY KEY,
    sport_division_id INTEGER NOT NULL REFERENCES sport_divisions(id) ON DELETE CASCADE,
    group_name VARCHAR(255) NOT NULL,
    group_type VARCHAR(50) DEFAULT 'team' CHECK (group_type IN ('team', 'training', 'social')),
    age_group VARCHAR(50),
    skill_level VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sport_division_id, group_name)
);

-- Group membership (THE SOURCE OF TRUTH for access control)
CREATE TABLE sport_division_group_members (
    id SERIAL PRIMARY KEY,
    sport_division_group_id INTEGER NOT NULL REFERENCES sport_division_groups(id) ON DELETE CASCADE,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    member_role VARCHAR(50) DEFAULT 'player' CHECK (member_role IN ('player', 'coach', 'manager')),
    jersey_number VARCHAR(10),
    is_active BOOLEAN DEFAULT true,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sport_division_group_id, player_id)
);

-- Team coaching assignments
CREATE TABLE team_coaches (
    id SERIAL PRIMARY KEY,
    sport_division_group_id INTEGER NOT NULL REFERENCES sport_division_groups(id) ON DELETE CASCADE,
    coach_id INTEGER NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
    coach_role VARCHAR(50) DEFAULT 'assistant' CHECK (coach_role IN ('head', 'assistant', 'trainer')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sport_division_group_id, coach_id)
);

-- FootballHome Identity Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_admins_user ON admins(user_id);
CREATE INDEX idx_club_admins_club ON club_admins(club_id);
CREATE INDEX idx_club_admins_admin ON club_admins(admin_id);
CREATE INDEX idx_players_user ON players(user_id);
CREATE INDEX idx_coaches_player ON coaches(player_id);
CREATE INDEX idx_sport_divisions_club ON sport_divisions(club_id);
CREATE INDEX idx_sport_division_groups_division ON sport_division_groups(sport_division_id);
CREATE INDEX idx_group_members_group ON sport_division_group_members(sport_division_group_id);
CREATE INDEX idx_group_members_player ON sport_division_group_members(player_id);

-- ============================================================================
-- 6. JUNCTION TABLES (Link External Systems → FootballHome)
-- ============================================================================

-- Link FootballHome players to APSL profiles
CREATE TABLE players_apsl_players (
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    apsl_player_id INTEGER NOT NULL REFERENCES apsl_players(id) ON DELETE CASCADE,
    verified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified_by INTEGER REFERENCES users(id),
    PRIMARY KEY(player_id, apsl_player_id)
);

-- Link FootballHome players to CASA profiles
CREATE TABLE players_casa_players (
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    casa_player_id INTEGER NOT NULL REFERENCES casa_players(id) ON DELETE CASCADE,
    verified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified_by INTEGER REFERENCES users(id),
    PRIMARY KEY(player_id, casa_player_id)
);

-- Link FootballHome players to custom league profiles
CREATE TABLE players_custom_players (
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    custom_player_id INTEGER NOT NULL REFERENCES custom_players(id) ON DELETE CASCADE,
    PRIMARY KEY(player_id, custom_player_id)
);

-- Link FootballHome groups to APSL teams
CREATE TABLE sport_division_groups_apsl_teams (
    sport_division_group_id INTEGER NOT NULL REFERENCES sport_division_groups(id) ON DELETE CASCADE,
    apsl_team_id INTEGER NOT NULL REFERENCES apsl_teams(id) ON DELETE CASCADE,
    PRIMARY KEY(sport_division_group_id, apsl_team_id)
);

-- Link FootballHome groups to CASA teams
CREATE TABLE sport_division_groups_casa_teams (
    sport_division_group_id INTEGER NOT NULL REFERENCES sport_division_groups(id) ON DELETE CASCADE,
    casa_team_id INTEGER NOT NULL REFERENCES casa_teams(id) ON DELETE CASCADE,
    PRIMARY KEY(sport_division_group_id, casa_team_id)
);

-- Link FootballHome groups to custom teams
CREATE TABLE sport_division_groups_custom_teams (
    sport_division_group_id INTEGER NOT NULL REFERENCES sport_division_groups(id) ON DELETE CASCADE,
    custom_team_id INTEGER NOT NULL REFERENCES custom_teams(id) ON DELETE CASCADE,
    PRIMARY KEY(sport_division_group_id, custom_team_id)
);

-- Link FootballHome groups to GroupMe chats
CREATE TABLE sport_division_groups_groupme (
    sport_division_group_id INTEGER NOT NULL REFERENCES sport_division_groups(id) ON DELETE CASCADE,
    groupme_group_id VARCHAR(100) NOT NULL,
    PRIMARY KEY(sport_division_group_id)
);

-- Link users to GroupMe profiles
CREATE TABLE users_groupme (
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    groupme_user_id VARCHAR(100) NOT NULL,
    groupme_user_name VARCHAR(255),
    PRIMARY KEY(user_id, groupme_user_id)
);

-- Junction Indexes
CREATE INDEX idx_players_apsl_apsl ON players_apsl_players(apsl_player_id);
CREATE INDEX idx_players_casa_casa ON players_casa_players(casa_player_id);
CREATE INDEX idx_groups_apsl_apsl ON sport_division_groups_apsl_teams(apsl_team_id);
CREATE INDEX idx_groups_casa_casa ON sport_division_groups_casa_teams(casa_team_id);

-- ============================================================================
-- 7. EVENTS & RSVP SYSTEM (Orchestration Layer)
-- ============================================================================

-- Events (pure RSVP orchestrator - no date/time/venue stored here)
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    created_by INTEGER NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Link event to EXACTLY ONE primary source (match)
CREATE TABLE events_apsl_matches (
    event_id INTEGER PRIMARY KEY REFERENCES events(id) ON DELETE CASCADE,
    apsl_match_id INTEGER NOT NULL REFERENCES apsl_matches(id) ON DELETE CASCADE
);

CREATE TABLE events_casa_matches (
    event_id INTEGER PRIMARY KEY REFERENCES events(id) ON DELETE CASCADE,
    casa_match_id INTEGER NOT NULL REFERENCES casa_matches(id) ON DELETE CASCADE
);

CREATE TABLE events_custom_matches (
    event_id INTEGER PRIMARY KEY REFERENCES events(id) ON DELETE CASCADE,
    custom_match_id INTEGER NOT NULL REFERENCES custom_matches(id) ON DELETE CASCADE
);

-- Optional link to GroupMe discussion (secondary source)
CREATE TABLE events_groupme_calendar_events (
    event_id INTEGER PRIMARY KEY REFERENCES events(id) ON DELETE CASCADE,
    groupme_calendar_event_id INTEGER NOT NULL REFERENCES groupme_calendar_events(id) ON DELETE CASCADE
);

-- Which groups can see/RSVP to this event
CREATE TABLE events_groups (
    event_id INTEGER NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    sport_division_group_id INTEGER NOT NULL REFERENCES sport_division_groups(id) ON DELETE CASCADE,
    PRIMARY KEY(event_id, sport_division_group_id)
);

-- Native FootballHome RSVPs (only if NO GroupMe link)
CREATE TABLE event_rsvps (
    id SERIAL PRIMARY KEY,
    event_id INTEGER NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('going', 'not_going', 'maybe')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(event_id, user_id)
);

-- Event Indexes
CREATE INDEX idx_events_created_by ON events(created_by);
CREATE INDEX idx_events_apsl_match ON events_apsl_matches(apsl_match_id);
CREATE INDEX idx_events_casa_match ON events_casa_matches(casa_match_id);
CREATE INDEX idx_events_custom_match ON events_custom_matches(custom_match_id);
CREATE INDEX idx_events_groupme ON events_groupme_calendar_events(groupme_calendar_event_id);
CREATE INDEX idx_events_groups_group ON events_groups(sport_division_group_id);
CREATE INDEX idx_event_rsvps_event ON event_rsvps(event_id);
CREATE INDEX idx_event_rsvps_user ON event_rsvps(user_id);

-- ============================================================================
-- TRIGGERS & CONSTRAINTS
-- ============================================================================

-- Prevent FootballHome RSVPs if event has GroupMe link
CREATE OR REPLACE FUNCTION check_rsvp_source_conflict()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM events_groupme_calendar_events 
        WHERE event_id = NEW.event_id
    ) THEN
        RAISE EXCEPTION 'Cannot create FootballHome RSVP: event is linked to GroupMe (RSVPs managed there)';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_rsvp_source_footballhome
    BEFORE INSERT ON event_rsvps
    FOR EACH ROW EXECUTE FUNCTION check_rsvp_source_conflict();

-- Add FK constraint now that clubs table exists
ALTER TABLE custom_leagues ADD CONSTRAINT fk_custom_leagues_club 
    FOREIGN KEY (created_by_club_id) REFERENCES clubs(id) ON DELETE SET NULL;

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- Total Tables: 54
--   APSL: 8 tables
--   CASA: 8 tables
--   Custom: 8 tables
--   GroupMe: 2 tables
--   FootballHome Identity: 10 tables
--   Junction: 8 tables
--   Events: 7 tables
--   Supporting: 3 tables
-- ============================================================================
