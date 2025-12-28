-- Football Home Database Schema - Fully Normalized Architecture
-- Version: 6.0 - Single Source of Truth + Chat System
--
-- Architecture:
-- 1. Lookup Tables - Reference data for all enums
-- 2. Governing Body Hierarchy - FIFA → Confederations → National → Regional → State
-- 3. Organizations & Leagues - APSL, CASA, Custom leagues
-- 4. Football Home Identity - Users, clubs, sport divisions
-- 5. Unified League Data - Single tables for teams, players, matches, stats
-- 6. Chat System - Built-in messaging and communication
-- 7. Player Identity - Junction tables linking users to league players
-- 8. GroupMe Integration - External chat platform data
-- 9. Supporting Tables - Venues, audit log
--
-- Key Principles:
-- - NO table duplication (no apsl_* vs casa_*) - differentiate by FKs
-- - ALL text enums replaced with lookup tables
-- - Chat members = users only (no OR logic)
-- - Single matches table for all match types
-- - Source tracking via source_system_id + external_id

-- Create database extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. LOOKUP TABLES (Reference Data - No More Text Enums!)
-- ============================================================================

CREATE TABLE match_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO match_types (id, name, description, sort_order) VALUES
    (1, 'league', 'Official league match from APSL/CASA', 1),
    (2, 'custom', 'Custom match created by users', 2),
    (3, 'practice', 'Team practice session', 3),
    (4, 'scrimmage', 'Friendly scrimmage match', 4),
    (5, 'tournament', 'Tournament match', 5)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE match_statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO match_statuses (id, name, description, sort_order) VALUES
    (1, 'scheduled', 'Match is scheduled', 1),
    (2, 'in_progress', 'Match is currently being played', 2),
    (3, 'completed', 'Match has finished', 3),
    (4, 'cancelled', 'Match was cancelled', 4),
    (5, 'postponed', 'Match was postponed to a later date', 5)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE rsvp_statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO rsvp_statuses (id, name, description, sort_order) VALUES
    (1, 'yes', 'Attending', 1),
    (2, 'no', 'Not attending', 2),
    (3, 'maybe', 'Might attend', 3)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE chat_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO chat_types (id, name, description, sort_order) VALUES
    (1, 'team', 'Team-based chat', 1),
    (2, 'league', 'League-wide chat', 2),
    (3, 'pickup', 'Pickup game group', 3),
    (4, 'friends', 'Friends group chat', 4),
    (5, 'training', 'Training session group', 5)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE chat_roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO chat_roles (id, name, description, sort_order) VALUES
    (1, 'admin', 'Can manage chat settings and members', 1),
    (2, 'member', 'Regular chat participant', 2)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE admin_levels (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO admin_levels (id, name, description, sort_order) VALUES
    (1, 'super', 'Super admin with full system access', 1),
    (2, 'club', 'Club administrator', 2),
    (3, 'team', 'Team administrator', 3)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE member_roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO member_roles (id, name, description, sort_order) VALUES
    (1, 'player', 'Team player', 1),
    (2, 'coach', 'Team coach', 2),
    (3, 'manager', 'Team manager', 3)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE coach_roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO coach_roles (id, name, description, sort_order) VALUES
    (1, 'head', 'Head coach', 1),
    (2, 'assistant', 'Assistant coach', 2),
    (3, 'trainer', 'Athletic trainer', 3)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE group_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO group_types (id, name, description, sort_order) VALUES
    (1, 'team', 'Competitive team', 1),
    (2, 'training', 'Training group', 2),
    (3, 'social', 'Social group', 3)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE source_systems (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

INSERT INTO source_systems (id, name, description, is_active) VALUES
    (1, 'apsl', 'American Premier Soccer League', true),
    (2, 'casa', 'CASA Soccer Leagues', true),
    (3, 'custom', 'User-created/custom data', true),
    (4, 'groupme', 'GroupMe integration', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 2. GOVERNING BODY HIERARCHY
-- ============================================================================

CREATE TABLE governing_body_scopes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0
);

INSERT INTO governing_body_scopes (id, name, description, sort_order) VALUES
    (1, 'Global', 'Global governing body (e.g., FIFA)', 1),
    (2, 'Continental', 'Continental confederation (e.g., CONCACAF, UEFA)', 2),
    (3, 'National', 'National federation (e.g., USSF)', 3),
    (4, 'Regional', 'Regional or secondary national body (e.g., USASA, US Club Soccer)', 4),
    (5, 'State', 'State association (e.g., EPSA)', 5),
    (6, 'Local', 'Local organization', 6)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE governing_bodies (
    id SERIAL PRIMARY KEY,
    scope_id INTEGER NOT NULL REFERENCES governing_body_scopes(id),
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(50),
    website_url TEXT,
    country_code CHAR(3),
    state_code CHAR(2),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name)
);

CREATE INDEX idx_governing_bodies_scope ON governing_bodies(scope_id);
CREATE INDEX idx_governing_bodies_country ON governing_bodies(country_code);

CREATE TABLE governing_body_relationships (
    id SERIAL PRIMARY KEY,
    parent_body_id INTEGER NOT NULL REFERENCES governing_bodies(id) ON DELETE CASCADE,
    child_body_id INTEGER NOT NULL REFERENCES governing_bodies(id) ON DELETE CASCADE,
    relationship_type VARCHAR(50) DEFAULT 'affiliated_with',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(parent_body_id, child_body_id),
    CHECK (parent_body_id != child_body_id)
);

CREATE INDEX idx_governing_body_rel_parent ON governing_body_relationships(parent_body_id);
CREATE INDEX idx_governing_body_rel_child ON governing_body_relationships(child_body_id);

-- ============================================================================
-- 3. ORGANIZATIONS & LEAGUES
-- ============================================================================

CREATE TABLE organizations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    short_name VARCHAR(50),
    website_url TEXT,
    governing_body_id INTEGER REFERENCES governing_bodies(id),
    affiliation VARCHAR(100),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_organizations_governing_body ON organizations(governing_body_id);

CREATE TABLE leagues (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER NOT NULL REFERENCES organizations(id),
    name VARCHAR(255) NOT NULL,
    season VARCHAR(50) NOT NULL,
    website_url TEXT,
    affiliation VARCHAR(100),
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(organization_id, name, season)
);

CREATE INDEX idx_leagues_organization ON leagues(organization_id);
CREATE INDEX idx_leagues_source ON leagues(source_system_id);

CREATE TABLE conferences (
    id SERIAL PRIMARY KEY,
    league_id INTEGER NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    abbreviation VARCHAR(10),
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(league_id, name)
);

CREATE INDEX idx_conferences_league ON conferences(league_id);
CREATE INDEX idx_conferences_source ON conferences(source_system_id);

CREATE TABLE league_divisions (
    id SERIAL PRIMARY KEY,
    league_id INTEGER NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    conference_id INTEGER REFERENCES conferences(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    age_group VARCHAR(50),
    skill_level VARCHAR(50),
    gender VARCHAR(20),
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_league_divisions_league ON league_divisions(league_id);
CREATE INDEX idx_league_divisions_conference ON league_divisions(conference_id);
CREATE INDEX idx_league_divisions_source ON league_divisions(source_system_id);

-- ============================================================================
-- 4. FOOTBALLHOME IDENTITY SYSTEM
-- ============================================================================

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

CREATE INDEX idx_users_email ON users(email);

CREATE TABLE admins (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    admin_level_id INTEGER NOT NULL REFERENCES admin_levels(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_admins_user ON admins(user_id);
CREATE INDEX idx_admins_level ON admins(admin_level_id);

CREATE TABLE clubs (
    id SERIAL PRIMARY KEY,
    display_name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    logo_url TEXT,
    website TEXT,
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_clubs_source ON clubs(source_system_id);

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

CREATE INDEX idx_club_admins_club ON club_admins(club_id);
CREATE INDEX idx_club_admins_admin ON club_admins(admin_id);

CREATE TABLE sport_divisions (
    id SERIAL PRIMARY KEY,
    club_id INTEGER NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    display_name VARCHAR(255) NOT NULL,
    sport VARCHAR(50) DEFAULT 'soccer',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(club_id, display_name)
);

CREATE INDEX idx_sport_divisions_club ON sport_divisions(club_id);

CREATE TABLE sport_division_groups (
    id SERIAL PRIMARY KEY,
    sport_division_id INTEGER NOT NULL REFERENCES sport_divisions(id) ON DELETE CASCADE,
    group_name VARCHAR(255) NOT NULL,
    group_type_id INTEGER REFERENCES group_types(id),
    age_group VARCHAR(50),
    skill_level VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sport_division_id, group_name)
);

CREATE INDEX idx_sport_division_groups_division ON sport_division_groups(sport_division_id);
CREATE INDEX idx_sport_division_groups_type ON sport_division_groups(group_type_id);

-- ============================================================================
-- 5. UNIFIED LEAGUE DATA (Replaces all apsl_*, casa_*, custom_* tables)
-- ============================================================================

CREATE TABLE league_teams (
    id SERIAL PRIMARY KEY,
    division_id INTEGER NOT NULL REFERENCES league_divisions(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    logo_url TEXT,
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(division_id, name)
);

CREATE INDEX idx_league_teams_division ON league_teams(division_id);
CREATE INDEX idx_league_teams_source ON league_teams(source_system_id);

CREATE TABLE league_players (
    id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL REFERENCES league_teams(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    jersey_number VARCHAR(10),
    position VARCHAR(50),
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_league_players_team ON league_players(team_id);
CREATE INDEX idx_league_players_source ON league_players(source_system_id);

CREATE TABLE coaches (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    license_level VARCHAR(50),
    certifications TEXT,
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_coaches_user ON coaches(user_id);
CREATE INDEX idx_coaches_source ON coaches(source_system_id);

CREATE TABLE team_coaches (
    id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL REFERENCES league_teams(id) ON DELETE CASCADE,
    coach_id INTEGER NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
    coach_role_id INTEGER REFERENCES coach_roles(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(team_id, coach_id)
);

CREATE INDEX idx_team_coaches_team ON team_coaches(team_id);
CREATE INDEX idx_team_coaches_coach ON team_coaches(coach_id);
CREATE INDEX idx_team_coaches_role ON team_coaches(coach_role_id);

-- Venues (shared across all matches)
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

-- Unified matches table (league, custom, practice, all in one)
CREATE TABLE matches (
    id SERIAL PRIMARY KEY,
    match_type_id INTEGER NOT NULL REFERENCES match_types(id),
    division_id INTEGER REFERENCES league_divisions(id),
    home_team_id INTEGER REFERENCES league_teams(id),
    away_team_id INTEGER REFERENCES league_teams(id),
    match_date DATE NOT NULL,
    match_time TIME,
    venue_id INTEGER REFERENCES venues(id),
    title VARCHAR(255),
    description TEXT,
    match_status_id INTEGER REFERENCES match_statuses(id) DEFAULT 1,
    home_score INTEGER,
    away_score INTEGER,
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100) UNIQUE,
    created_by_user_id INTEGER REFERENCES users(id),
    created_by_chat_id INTEGER,  -- Will reference chats(id) after that table is created
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_matches_type ON matches(match_type_id);
CREATE INDEX idx_matches_division ON matches(division_id);
CREATE INDEX idx_matches_date ON matches(match_date);
CREATE INDEX idx_matches_teams ON matches(home_team_id, away_team_id);
CREATE INDEX idx_matches_status ON matches(match_status_id);
CREATE INDEX idx_matches_source ON matches(source_system_id);

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

CREATE INDEX idx_player_match_stats_match ON player_match_stats(match_id);
CREATE INDEX idx_player_match_stats_player ON player_match_stats(player_id);

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

CREATE INDEX idx_team_standings_division ON team_standings(division_id);
CREATE INDEX idx_team_standings_team ON team_standings(team_id);

-- ============================================================================
-- 6. CHAT SYSTEM (Built-in messaging)
-- ============================================================================

CREATE TABLE chats (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    chat_type_id INTEGER REFERENCES chat_types(id),
    image_url TEXT,
    created_by_user_id INTEGER REFERENCES users(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chats_type ON chats(chat_type_id);
CREATE INDEX idx_chats_created_by ON chats(created_by_user_id);

-- Simple: chat members are users, that's it
CREATE TABLE chat_members (
    id SERIAL PRIMARY KEY,
    chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    chat_role_id INTEGER REFERENCES chat_roles(id) DEFAULT 2,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(chat_id, user_id)
);

CREATE INDEX idx_chat_members_chat ON chat_members(chat_id);
CREATE INDEX idx_chat_members_user ON chat_members(user_id);
CREATE INDEX idx_chat_members_role ON chat_members(chat_role_id);

CREATE TABLE chat_messages (
    id SERIAL PRIMARY KEY,
    chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id),
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chat_messages_chat ON chat_messages(chat_id);
CREATE INDEX idx_chat_messages_user ON chat_messages(user_id);
CREATE INDEX idx_chat_messages_created ON chat_messages(created_at DESC);

-- RSVPs for ANY match (league, custom, practice)
CREATE TABLE match_rsvps (
    id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id),
    rsvp_status_id INTEGER NOT NULL REFERENCES rsvp_statuses(id),
    responded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(match_id, user_id)
);

CREATE INDEX idx_match_rsvps_match ON match_rsvps(match_id);
CREATE INDEX idx_match_rsvps_user ON match_rsvps(user_id);
CREATE INDEX idx_match_rsvps_status ON match_rsvps(rsvp_status_id);

-- Now add the FK for created_by_chat_id
ALTER TABLE matches ADD CONSTRAINT fk_matches_chat 
    FOREIGN KEY (created_by_chat_id) REFERENCES chats(id) ON DELETE SET NULL;

CREATE INDEX idx_matches_chat ON matches(created_by_chat_id);

-- ============================================================================
-- 7. PLAYER IDENTITY (Junction Tables - Users claiming league players)
-- ============================================================================

-- Link users to league players (user claims "I am this player")
CREATE TABLE player_users (
    id SERIAL PRIMARY KEY,
    player_id INTEGER NOT NULL REFERENCES league_players(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    verified BOOLEAN DEFAULT false,
    verified_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(player_id, user_id)
);

CREATE INDEX idx_player_users_player ON player_users(player_id);
CREATE INDEX idx_player_users_user ON player_users(user_id);

-- Link sport division groups to league teams
CREATE TABLE group_teams (
    id SERIAL PRIMARY KEY,
    sport_division_group_id INTEGER NOT NULL REFERENCES sport_division_groups(id) ON DELETE CASCADE,
    league_team_id INTEGER NOT NULL REFERENCES league_teams(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sport_division_group_id, league_team_id)
);

CREATE INDEX idx_group_teams_group ON group_teams(sport_division_group_id);
CREATE INDEX idx_group_teams_team ON group_teams(league_team_id);

-- ============================================================================
-- 8. GROUPME INTEGRATION
-- ============================================================================

CREATE TABLE groupme_groups (
    id SERIAL PRIMARY KEY,
    groupme_group_id VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_groupme_groups_active ON groupme_groups(is_active);

CREATE TABLE groupme_members (
    id SERIAL PRIMARY KEY,
    groupme_group_id INTEGER NOT NULL REFERENCES groupme_groups(id) ON DELETE CASCADE,
    groupme_user_id VARCHAR(100) NOT NULL,
    user_id INTEGER REFERENCES users(id),
    nickname VARCHAR(255),
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(groupme_group_id, groupme_user_id)
);

CREATE INDEX idx_groupme_members_group ON groupme_members(groupme_group_id);
CREATE INDEX idx_groupme_members_user ON groupme_members(user_id);

CREATE TABLE groupme_messages (
    id SERIAL PRIMARY KEY,
    groupme_message_id VARCHAR(100) NOT NULL UNIQUE,
    groupme_group_id INTEGER NOT NULL REFERENCES groupme_groups(id) ON DELETE CASCADE,
    groupme_member_id INTEGER REFERENCES groupme_members(id),
    text TEXT,
    created_at_groupme TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_groupme_messages_group ON groupme_messages(groupme_group_id);
CREATE INDEX idx_groupme_messages_created ON groupme_messages(created_at_groupme DESC);

CREATE TABLE groupme_events (
    id SERIAL PRIMARY KEY,
    groupme_event_id VARCHAR(100) NOT NULL UNIQUE,
    groupme_group_id INTEGER NOT NULL REFERENCES groupme_groups(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    created_by_member_id INTEGER REFERENCES groupme_members(id),
    match_id INTEGER REFERENCES matches(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_groupme_events_group ON groupme_events(groupme_group_id);
CREATE INDEX idx_groupme_events_match ON groupme_events(match_id);
CREATE INDEX idx_groupme_events_start ON groupme_events(start_time);

CREATE TABLE groupme_event_rsvps (
    id SERIAL PRIMARY KEY,
    groupme_event_id INTEGER NOT NULL REFERENCES groupme_events(id) ON DELETE CASCADE,
    groupme_member_id INTEGER NOT NULL REFERENCES groupme_members(id) ON DELETE CASCADE,
    rsvp_status_id INTEGER NOT NULL REFERENCES rsvp_statuses(id),
    responded_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(groupme_event_id, groupme_member_id)
);

CREATE INDEX idx_groupme_rsvps_event ON groupme_event_rsvps(groupme_event_id);
CREATE INDEX idx_groupme_rsvps_status ON groupme_event_rsvps(rsvp_status_id);

-- Link GroupMe groups to sport division groups
CREATE TABLE group_groupme_groups (
    id SERIAL PRIMARY KEY,
    sport_division_group_id INTEGER NOT NULL REFERENCES sport_division_groups(id) ON DELETE CASCADE,
    groupme_group_id INTEGER NOT NULL REFERENCES groupme_groups(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sport_division_group_id, groupme_group_id)
);

CREATE INDEX idx_group_groupme_groups_group ON group_groupme_groups(sport_division_group_id);
CREATE INDEX idx_group_groupme_groups_groupme ON group_groupme_groups(groupme_group_id);

-- ============================================================================
-- 9. SUPPORTING TABLES
-- ============================================================================

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
-- SUMMARY
-- ============================================================================
-- Lookup Tables: 10 (match_types, match_statuses, rsvp_statuses, etc.)
-- Governing Bodies: 3 tables
-- Organizations & Leagues: 4 tables (organizations, leagues, conferences, league_divisions)
-- FootballHome Identity: 7 tables (users, admins, clubs, club_admins, sport_divisions, sport_division_groups)
-- Unified League Data: 8 tables (league_teams, league_players, coaches, team_coaches, matches, player_match_stats, team_standings, venues)
-- Chat System: 4 tables (chats, chat_members, chat_messages, match_rsvps)
-- Player Identity: 2 junction tables (player_users, group_teams)
-- GroupMe Integration: 6 tables
-- Supporting: 1 table (audit_log)
-- TOTAL: ~45 tables (down from 54!) - Eliminated all duplication!
-- ============================================================================
