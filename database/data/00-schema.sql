-- Football Home Database Schema - Real-World Aligned Architecture
-- Version: 7.0 - League-Centric Season Management
--
-- Architecture:
-- 1. Lookup Tables - Reference data for all enums (age calculation, chat providers, etc.)
-- 2. Governing Body Hierarchy - FIFA -> Confederations -> National -> Regional -> State
-- 3. Organizations (Universal) - APSL, CASA, Lighthouse 1893, Falcons FC, etc.
-- 4. Club Structure - Organizations -> Clubs -> Teams (persistent entities)
-- 5. League Structure - Organizations -> Leagues -> Seasons -> Conferences -> Divisions
-- 6. Seasonal Rosters - Teams register in Divisions via division_teams (league manages)
-- 7. Roster Details - division_team_players + division_team_coaches
-- 8. Identity System - Persons, Users, Players, Coaches (normalized roles)
-- 9. Chat System - Generic messaging with external platform integrations
-- 10. Supporting Tables - Venues, matches, audit log
--
-- Key Principles:
-- - Real-world naming: clubs (not sport_divisions), seasons (not in leagues table)
-- - League-centric: Leagues manage seasonal registrations via division_teams
-- - Teams are persistent: Don't duplicate teams across seasons
-- - Rosters are seasonal: Players + coaches attached to division_teams
-- - History tracking: Via seasons -> divisions -> division_teams
-- - NO table duplication (no apsl_* vs casa_*) - differentiate by FKs
-- - ALL text enums replaced with lookup tables
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

CREATE TABLE positions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    abbreviation VARCHAR(5) NOT NULL,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO positions (id, name, abbreviation, description, sort_order) VALUES
    (1, 'Goalkeeper', 'GK', 'Goalkeeper', 1),
    (2, 'Right Back', 'RB', 'Right defender', 2),
    (3, 'Center Back', 'CB', 'Central defender', 3),
    (4, 'Left Back', 'LB', 'Left defender', 4),
    (5, 'Defensive Midfielder', 'CDM', 'Defensive midfielder', 5),
    (6, 'Central Midfielder', 'CM', 'Central midfielder', 6),
    (7, 'Attacking Midfielder', 'CAM', 'Attacking midfielder', 7),
    (8, 'Right Winger', 'RW', 'Right wing/forward', 8),
    (9, 'Striker', 'ST', 'Center forward', 9),
    (10, 'Left Winger', 'LW', 'Left wing/forward', 10),
    (11, 'Right Midfielder', 'RM', 'Right midfielder', 11),
    (12, 'Left Midfielder', 'LM', 'Left midfielder', 12),
    (13, 'Wing Back', 'WB', 'Wing back (defensive winger)', 13),
    (14, 'Sweeper', 'SW', 'Sweeper (libero)', 14),
    (15, 'Forward', 'FW', 'Forward (general)', 15)
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
    (3, 'csl', 'Cosmopolitan Soccer League', true)
ON CONFLICT (id) DO NOTHING;

-- Scrape Target System Tables
CREATE TABLE scrape_target_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO scrape_target_types (id, name, description, sort_order) VALUES
    (1, 'conference_structure', 'League structure (conferences, divisions)', 1),
    (2, 'standings', 'Division standings', 2),
    (3, 'schedule', 'Match schedules', 3),
    (4, 'team_roster', 'Team rosters', 4),
    (5, 'team_stats', 'Team season statistics', 5),
    (6, 'player_stats', 'Player season statistics', 6),
    (7, 'player_profile', 'Player biographical data', 7),
    (8, 'match_lineups', 'Match lineups (starters/subs)', 8),
    (9, 'match_events', 'Match events (goals, cards, subs)', 9),
    (10, 'match_score', 'Match scores', 10),
    (11, 'venue_details', 'Venue information', 11),
    (12, 'chat_messages', 'Chat messages', 12),
    (13, 'chat_events', 'Chat events', 13),
    (14, 'chat_members', 'Chat members', 14),
    (15, 'chat_rsvps', 'Chat RSVPs', 15),
    (16, 'venues', 'Venue information from Google Places', 16),
    (17, 'countries', 'Country information', 17),
    (18, 'governing_bodies', 'Soccer governing bodies hierarchy', 18)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE scraper_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    parser_class VARCHAR(100),
    platform VARCHAR(50),
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO scraper_types (id, name, parser_class, platform, description, sort_order) VALUES
    (1, 'teampass_html', 'ApslHtmlParser', 'TeamPass', 'TeamPass HTML parser (APSL, other leagues)', 1),
    (2, 'google_sheets', 'CasaGoogleSheetsParser', 'Google Sheets', 'Google Sheets API parser (CASA)', 2),
    (3, 'groupme_api', 'GroupMeApiParser', 'GroupMe', 'GroupMe API v3 parser', 3),
    (4, 'google_places', 'GooglePlacesParser', 'Google Places', 'Google Places API for venue data', 4)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE scrape_execution_statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO scrape_execution_statuses (id, name, description, sort_order) VALUES
    (1, 'pending', 'Scrape queued but not yet started', 1),
    (2, 'running', 'Scrape currently in progress', 2),
    (3, 'success', 'Scrape completed successfully', 3),
    (4, 'partial', 'Scrape completed with some errors', 4),
    (5, 'failed', 'Scrape failed completely', 5),
    (6, 'timeout', 'Scrape exceeded time limit', 6),
    (7, 'cancelled', 'Scrape manually cancelled', 7)
ON CONFLICT (id) DO NOTHING;

-- Scrape Actions: What action to take on a scrape target
CREATE TABLE scrape_actions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO scrape_actions (id, name, description, sort_order) VALUES
    (1, 'download_and_parse', 'Fetch fresh HTML/API data and parse it', 1),
    (2, 'use_cache_only', 'Parse existing cached HTML without fetching', 2),
    (3, 'skip', 'Do not process this target (completed/archived)', 3),
    (4, 'force_refresh', 'Force fresh download even if recently scraped', 4),
    (5, 'verify_only', 'Check if data exists, report discrepancies', 5)
ON CONFLICT (id) DO NOTHING;

-- Scrape Statuses: Current state of a scrape target
CREATE TABLE scrape_statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO scrape_statuses (id, name, description, sort_order) VALUES
    (1, 'not_started', 'Never been scraped', 1),
    (2, 'in_progress', 'Currently being scraped', 2),
    (3, 'completed', 'Successfully scraped and up-to-date', 3),
    (4, 'needs_refresh', 'Data exists but may be stale', 4),
    (5, 'failed', 'Last scrape failed', 5),
    (6, 'archived', 'Historical data, will not update', 6)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE scrape_targets (
    id SERIAL PRIMARY KEY,
    source_system_id INTEGER NOT NULL REFERENCES source_systems(id),
    scraper_type_id INTEGER NOT NULL REFERENCES scraper_types(id),
    target_type_id INTEGER NOT NULL REFERENCES scrape_target_types(id),
    url TEXT NOT NULL,
    label VARCHAR(255),
    -- State machine fields
    scrape_action_id INTEGER REFERENCES scrape_actions(id) DEFAULT 1,
    scrape_status_id INTEGER REFERENCES scrape_statuses(id) DEFAULT 1,
    last_success_at TIMESTAMP,
    last_error_at TIMESTAMP,
    last_error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_scrape_targets_source ON scrape_targets(source_system_id);
CREATE INDEX idx_scrape_targets_scraper ON scrape_targets(scraper_type_id);
CREATE INDEX idx_scrape_targets_type ON scrape_targets(target_type_id);
CREATE INDEX idx_scrape_targets_action ON scrape_targets(scrape_action_id);
CREATE INDEX idx_scrape_targets_status ON scrape_targets(scrape_status_id);

CREATE TABLE scrape_executions (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER NOT NULL REFERENCES scrape_targets(id),
    status_id INTEGER NOT NULL REFERENCES scrape_execution_statuses(id),
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    duration_ms INTEGER,
    entities_created INTEGER DEFAULT 0,
    entities_updated INTEGER DEFAULT 0,
    error_message TEXT,
    metadata JSONB
);

CREATE INDEX idx_scrape_executions_target ON scrape_executions(scrape_target_id);
CREATE INDEX idx_scrape_executions_status ON scrape_executions(status_id);
CREATE INDEX idx_scrape_executions_started ON scrape_executions(started_at DESC);

-- ============================================================================
-- ============================================================================
-- NOTE: Entity-specific scrape target tables moved to end of file
-- (after all entity tables are created to avoid forward references)
-- ============================================================================

CREATE TABLE chat_providers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

INSERT INTO chat_providers (id, name, description, is_active) VALUES
    (1, 'groupme', 'GroupMe messaging platform', true),
    (2, 'discord', 'Discord chat platform', true),
    (3, 'slack', 'Slack workspace', true),
    (4, 'teamsnap', 'TeamSnap messaging', true),
    (5, 'whatsapp', 'WhatsApp groups', true)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE age_calculation_methods (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO age_calculation_methods (id, name, description, sort_order) VALUES
    (1, 'birth_year', 'Age based on birth year (e.g., "Over 40" = born 1984 or earlier)', 1),
    (2, 'age_on_date', 'Age as of specific cutoff date (e.g., Sept 1, Aug 1)', 2),
    (3, 'calendar_year', 'Age during calendar year', 3),
    (4, 'grade_based', 'Based on school grade level', 4),
    (5, 'minimum_age', 'Minimum age requirement only (e.g., "Over 40")', 5),
    (6, 'age_range', 'Specific age range (e.g., "U19" = under 19)', 6),
    (7, 'open', 'No age restriction', 7)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE sports (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO sports (id, name, description, sort_order) VALUES
    (1, 'Soccer', 'Association Football', 1),
    (2, 'Basketball', 'Basketball', 2),
    (3, 'Baseball', 'Baseball', 3),
    (4, 'Hockey', 'Ice Hockey', 4),
    (5, 'Volleyball', 'Volleyball', 5)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- Continents (lookup with data inline)
-- ============================================================================

CREATE TABLE continents (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    code CHAR(2) NOT NULL UNIQUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Continents are populated by CountryScraperV2.js (via REST Countries API)
-- Run: ./update.sh

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

CREATE TABLE countries (
    id SERIAL PRIMARY KEY,
    code CHAR(3) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL UNIQUE,
    fifa_code CHAR(3),
    continent_id INTEGER REFERENCES continents(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_countries_code ON countries(code);
CREATE INDEX idx_countries_fifa ON countries(fifa_code);
CREATE INDEX idx_countries_continent ON countries(continent_id);

-- Countries are populated by CountryScraperV2.js (via REST Countries API)
-- Run: ./update.sh

CREATE TABLE states (
    id SERIAL PRIMARY KEY,
    country_id INTEGER NOT NULL REFERENCES countries(id),
    code CHAR(2) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(country_id, code)
);

CREATE INDEX idx_states_country ON states(country_id);
CREATE INDEX idx_states_code ON states(code);

-- States are populated by UsStatesScraper.js (all 50 US states + DC)

-- ============================================================================
-- 3. ORGANIZATIONS (Universal Superclass)
-- ============================================================================
-- Organizations are the universal top-level entity:
-- - Governing bodies (FIFA, US Soccer, USASA, NorCal)
-- - League operators (APSL, CASA)
-- - Club owners (Lighthouse 1893, Falcons FC)

CREATE TABLE organizations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    short_name VARCHAR(50),
    website_url TEXT,
    logo_url TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE organizations IS 'Universal top-level entities (governing bodies, league operators, club owners)';

-- Insert static organizations (league operators)
INSERT INTO organizations (id, name, short_name, website_url, is_active) VALUES
    (1, 'American Premier Soccer League', 'APSL', 'https://www.apslsoccer.com', true),
    (2, 'CASA Soccer Leagues', 'CASA', 'https://www.casasoccerleagues.com', true),
    (3, 'Cosmopolitan Soccer League', 'CSL', 'https://www.cosmosoccerleague.com', true)
ON CONFLICT (id) DO NOTHING;

SELECT setval('organizations_id_seq', (SELECT MAX(id) FROM organizations));

-- Governing bodies are a subset of organizations that govern soccer
CREATE TABLE governing_bodies (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER NOT NULL UNIQUE REFERENCES organizations(id) ON DELETE CASCADE,
    parent_governing_body_id INTEGER REFERENCES governing_bodies(id),
    scope_id INTEGER NOT NULL REFERENCES governing_body_scopes(id),
    country_id INTEGER REFERENCES countries(id),
    state_id INTEGER REFERENCES states(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (id != parent_governing_body_id)
);

CREATE INDEX idx_governing_bodies_organization ON governing_bodies(organization_id);
CREATE INDEX idx_governing_bodies_parent ON governing_bodies(parent_governing_body_id);
CREATE INDEX idx_governing_bodies_scope ON governing_bodies(scope_id);
CREATE INDEX idx_governing_bodies_country ON governing_bodies(country_id);
CREATE INDEX idx_governing_bodies_state ON governing_bodies(state_id);

COMMENT ON TABLE governing_bodies IS 'Subset of organizations that govern soccer (FIFA -> CONCACAF -> US Soccer -> USASA/State Associations)';
COMMENT ON COLUMN governing_bodies.parent_governing_body_id IS 'Hierarchy: FIFA -> CONCACAF -> US Soccer -> USASA -> etc.';

CREATE TABLE leagues (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER NOT NULL REFERENCES organizations(id),
    name VARCHAR(255) NOT NULL,
    website_url TEXT,
    sanctioned_by_governing_body_id INTEGER REFERENCES governing_bodies(id),
    
    -- Age attributes (leagues define age groupings)
    age_calculation_method_id INTEGER REFERENCES age_calculation_methods(id),
    age_min INTEGER,  -- For "Over 40" leagues (minimum age)
    age_max INTEGER,  -- For "U19" leagues (maximum age)
    age_cutoff_month_day VARCHAR(5),  -- '09-01', '08-01' for school year cutoffs
    age_display_label VARCHAR(50),  -- 'Over 40', 'U19', 'Open', etc.
    
    -- Sex restriction (leagues define gender groupings)
    sex_restriction VARCHAR(20) CHECK (sex_restriction IN ('men', 'women', 'coed', 'mixed', 'open')),
    
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(organization_id, name)
);

CREATE INDEX idx_leagues_organization ON leagues(organization_id);
CREATE INDEX idx_leagues_sanctioned_by ON leagues(sanctioned_by_governing_body_id);
CREATE INDEX idx_leagues_source ON leagues(source_system_id);
CREATE INDEX idx_leagues_age_method ON leagues(age_calculation_method_id);

COMMENT ON TABLE leagues IS 'Competitions run by organizations (APSL org runs APSL league), sanctioned by governing bodies';
COMMENT ON COLUMN leagues.organization_id IS 'Organization that runs this league (e.g., APSL, CASA)';
COMMENT ON COLUMN leagues.sanctioned_by_governing_body_id IS 'Governing body that sanctions this league (e.g., USASA, NorCal)';

-- Insert static leagues
INSERT INTO leagues (id, organization_id, name, website_url, sex_restriction, source_system_id, is_active) VALUES
    (1, 1, 'American Premier Soccer League', 'https://www.apslsoccer.com', 'open', 1, true),
    (2, 2, 'CASA Select', 'https://www.casasoccerleagues.com', 'open', 2, true),
    (3, 2, 'CASA Traditional', 'https://www.casasoccerleagues.com', 'open', 2, true),
    (4, 3, 'Cosmopolitan Soccer League', 'https://www.cosmosoccerleague.com', 'open', 3, true)
ON CONFLICT (organization_id, name) DO NOTHING;

SELECT setval('leagues_id_seq', (SELECT MAX(id) FROM leagues));

CREATE TABLE seasons (
    id SERIAL PRIMARY KEY,
    league_id INTEGER NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT true,
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(league_id, name)
);

CREATE INDEX idx_seasons_league ON seasons(league_id);
CREATE INDEX idx_seasons_active ON seasons(is_active) WHERE is_active = true;

COMMENT ON TABLE seasons IS 'Time-bounded competitions within leagues (e.g., "2025", "2024-2025")';

CREATE TABLE conferences (
    id SERIAL PRIMARY KEY,
    season_id INTEGER NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    abbreviation VARCHAR(10),
    region VARCHAR(100),
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(season_id, name)
);

CREATE INDEX idx_conferences_season ON conferences(season_id);
CREATE INDEX idx_conferences_source ON conferences(source_system_id);

COMMENT ON TABLE conferences IS 'Geographic/organizational groupings within seasons (required - use "Default Conference" for single-conference leagues)';

CREATE TABLE division_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO division_types (id, name, description, sort_order) VALUES
    (1, 'league', 'Standard league play with home/away schedule', 1),
    (2, 'tournament_group', 'Tournament group stage (round-robin within group)', 2),
    (3, 'knockout_round', 'Knockout/elimination tournament bracket', 3)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE divisions (
    id SERIAL PRIMARY KEY,
    season_id INTEGER NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    conference_id INTEGER NOT NULL REFERENCES conferences(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    
    -- Division type (league play vs tournament structures)
    division_type_id INTEGER REFERENCES division_types(id) DEFAULT 1,
    
    -- Skill level (divisions define competitive tiers)
    skill_level INTEGER,  -- 1=highest (Premier/Division 1), 2=mid, 3=rec
    skill_label VARCHAR(50),  -- 'Premier', 'Division 1', 'Championship', etc.
    
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_divisions_season ON divisions(season_id);
CREATE INDEX idx_divisions_conference ON divisions(conference_id);
CREATE INDEX idx_divisions_type ON divisions(division_type_id);
CREATE INDEX idx_divisions_source ON divisions(source_system_id);
CREATE INDEX idx_divisions_skill ON divisions(skill_level);

COMMENT ON TABLE divisions IS 'Competitive tiers within conferences (every division must belong to a conference)';

-- ============================================================================
-- 4. FOOTBALLHOME IDENTITY SYSTEM
-- ============================================================================

-- Persons: Core identity table (everyone in the system is a person)
-- A person may have multiple roles: player, coach, admin, etc.
CREATE TABLE persons (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE,  -- Required for age verification/safety
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_persons_name ON persons(first_name, last_name);
CREATE INDEX idx_persons_birth_date ON persons(birth_date);

COMMENT ON TABLE persons IS 'Core identity for all people in the system (players, coaches, admins, etc.)';
COMMENT ON COLUMN persons.birth_date IS 'Birth date for age verification and safety compliance';

-- Users: Authentication entity (represents "can log in")
-- Links to a person but adds authentication capability
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    person_id INTEGER UNIQUE NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    password_hash TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_person ON users(person_id);
CREATE INDEX idx_users_active ON users(is_active);

COMMENT ON TABLE users IS 'Authentication entity - a person who can log in';
COMMENT ON COLUMN users.person_id IS 'FK to persons table - every user must be a person';

-- Email types lookup (must come BEFORE person_emails)
CREATE TABLE email_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO email_types (id, name, description, sort_order) VALUES
    (1, 'personal', 'Personal email address', 1),
    (2, 'work', 'Work/business email address', 2),
    (3, 'other', 'Other email address', 3)
ON CONFLICT (id) DO NOTHING;

-- Phone types lookup (must come BEFORE person_phones)
CREATE TABLE phone_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO phone_types (id, name, description, sort_order) VALUES
    (1, 'mobile', 'Mobile/cell phone', 1),
    (2, 'home', 'Home phone', 2),
    (3, 'work', 'Work phone', 3),
    (4, 'other', 'Other phone type', 4)
ON CONFLICT (id) DO NOTHING;

-- Person emails (junction table - emails belong to persons, not users)
CREATE TABLE person_emails (
    id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_type_id INTEGER REFERENCES email_types(id),
    is_primary BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(person_id, email)
);

CREATE INDEX idx_person_emails_person ON person_emails(person_id);
CREATE INDEX idx_person_emails_email ON person_emails(email);
CREATE INDEX idx_person_emails_primary ON person_emails(person_id, is_primary) WHERE is_primary = true;

COMMENT ON TABLE person_emails IS 'Email addresses belong to persons (used for login when person has a user account)';

-- Person phone numbers (junction table - phones belong to persons, not users)
CREATE TABLE person_phones (
    id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    phone_type_id INTEGER REFERENCES phone_types(id),
    is_primary BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP,
    can_receive_sms BOOLEAN DEFAULT true,
    can_receive_calls BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(person_id, phone_number)
);

CREATE INDEX idx_person_phones_person ON person_phones(person_id);
CREATE INDEX idx_person_phones_number ON person_phones(phone_number);
CREATE INDEX idx_person_phones_type ON person_phones(phone_type_id);
CREATE INDEX idx_person_phones_primary ON person_phones(person_id, is_primary) WHERE is_primary = true;

COMMENT ON TABLE person_phones IS 'Phone numbers belong to persons';

-- External identities (GroupMe, Discord, etc.) - link to persons
CREATE TABLE external_identities (
    id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    provider_id INTEGER NOT NULL REFERENCES chat_providers(id),
    external_user_id VARCHAR(255) NOT NULL,
    external_username VARCHAR(255),
    external_display_name VARCHAR(255),
    external_avatar_url TEXT,
    last_synced_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(provider_id, external_user_id)
);

CREATE INDEX idx_external_identities_person ON external_identities(person_id);
CREATE INDEX idx_external_identities_provider ON external_identities(provider_id);
CREATE INDEX idx_external_identities_external ON external_identities(provider_id, external_user_id);

COMMENT ON TABLE external_identities IS 'Links persons to external chat provider accounts';

CREATE TABLE admins (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    admin_level_id INTEGER NOT NULL REFERENCES admin_levels(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_admins_user ON admins(user_id);
CREATE INDEX idx_admins_level ON admins(admin_level_id);

CREATE TABLE organization_admins (
    organization_id INTEGER NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    admin_id INTEGER NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    admin_role VARCHAR(50),
    is_primary BOOLEAN DEFAULT false,
    -- No is_active - derived from ended_at IS NULL
    -- Multiple rows track admin tenure history
    CHECK (ended_at IS NULL OR ended_at > started_at),
    PRIMARY KEY (organization_id, admin_id, started_at)
);

CREATE INDEX idx_organization_admins_organization ON organization_admins(organization_id);
CREATE INDEX idx_organization_admins_admin ON organization_admins(admin_id);
CREATE INDEX idx_organization_admins_current ON organization_admins(organization_id, admin_id) WHERE ended_at IS NULL;

COMMENT ON TABLE organization_admins IS 'Admins assigned to organizations (Lighthouse 1893, etc.)';

CREATE TABLE league_admins (
    league_id INTEGER NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    admin_id INTEGER NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    admin_role VARCHAR(50),
    is_primary BOOLEAN DEFAULT false,
    -- No is_active - derived from ended_at IS NULL
    -- Multiple rows track admin tenure history
    CHECK (ended_at IS NULL OR ended_at > started_at),
    PRIMARY KEY (league_id, admin_id, started_at)
);

CREATE INDEX idx_league_admins_league ON league_admins(league_id);
CREATE INDEX idx_league_admins_admin ON league_admins(admin_id);
CREATE INDEX idx_league_admins_current ON league_admins(league_id, admin_id) WHERE ended_at IS NULL;

COMMENT ON TABLE league_admins IS 'Admins assigned to leagues (APSL, CASA, etc.) - commissioners, schedulers, etc.';

CREATE TABLE clubs (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    sport_id INTEGER NOT NULL DEFAULT 1 REFERENCES sports(id),
    logo_url TEXT,
    website TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(organization_id, name)
);

CREATE INDEX idx_clubs_organization ON clubs(organization_id);
CREATE INDEX idx_clubs_sport ON clubs(sport_id);

COMMENT ON TABLE clubs IS 'Competitive units within organizations (e.g., "Lighthouse 1893 SC", "Boys Club")';

CREATE TABLE club_admins (
    club_id INTEGER NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    admin_id INTEGER NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    admin_role VARCHAR(50),
    is_primary BOOLEAN DEFAULT false,
    -- No is_active - derived from ended_at IS NULL
    -- Multiple rows track admin tenure history
    CHECK (ended_at IS NULL OR ended_at > started_at),
    PRIMARY KEY (club_id, admin_id, started_at)
);

CREATE INDEX idx_club_admins_club ON club_admins(club_id);
CREATE INDEX idx_club_admins_admin ON club_admins(admin_id);
CREATE INDEX idx_club_admins_current ON club_admins(club_id, admin_id) WHERE ended_at IS NULL;

COMMENT ON TABLE club_admins IS 'Admins assigned to clubs (Lighthouse SC, Boys Club, etc.) - grants app permissions';

-- ============================================================================
-- 5. UNIFIED LEAGUE DATA (Replaces all apsl_*, casa_*, custom_* tables)
-- ============================================================================

CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    club_id INTEGER REFERENCES clubs(id),  -- Nullable for standalone teams
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    logo_url TEXT,
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100),
    scrape_target_id INTEGER REFERENCES scrape_targets(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(source_system_id, name),  -- Teams must be unique within a source system
    UNIQUE(source_system_id, external_id)  -- External IDs unique within source system
);

-- Partial unique constraint: (club_id, name, source_system_id) unique when club_id IS NOT NULL
-- This allows same club to have teams with same name from different sources (APSL Flatley FC + CASA Flatley FC)
-- Same team plays in multiple divisions via division_teams junction table
CREATE UNIQUE INDEX idx_teams_club_name_source_unique ON teams(club_id, name, source_system_id) WHERE club_id IS NOT NULL;

CREATE INDEX idx_teams_club ON teams(club_id);
CREATE INDEX idx_teams_source ON teams(source_system_id);
CREATE INDEX idx_teams_name ON teams(name);  -- For searching by name

COMMENT ON TABLE teams IS 'Persistent team entities (e.g., "Lighthouse 1893 SC", "Lighthouse Boys Club"). Same name allowed across different source systems. Same club can have teams with same name from different leagues (tracked via source_system_id). Team plays in multiple divisions via division_teams junction table.';

CREATE TABLE team_admins (
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    admin_id INTEGER NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    admin_role VARCHAR(50),
    -- No is_active - derived from ended_at IS NULL
    -- Multiple rows track admin tenure history
    CHECK (ended_at IS NULL OR ended_at > started_at),
    PRIMARY KEY (team_id, admin_id, started_at)
);

CREATE INDEX idx_team_admins_team ON team_admins(team_id);
CREATE INDEX idx_team_admins_admin ON team_admins(admin_id);
CREATE INDEX idx_team_admins_current ON team_admins(team_id, admin_id) WHERE ended_at IS NULL;

COMMENT ON TABLE team_admins IS 'Admins assigned to teams - grants app permissions. Separate from coaches table (identity vs authorization).';

-- Teams register in divisions (seasonal participation)
CREATE TABLE division_teams (
    id SERIAL PRIMARY KEY,
    division_id INTEGER NOT NULL REFERENCES divisions(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    unregistered_at TIMESTAMP,
    -- No is_active - derived from unregistered_at IS NULL
    -- No UNIQUE constraint - allows promotion/relegation history
    -- Team can appear in multiple divisions over time
    CHECK (unregistered_at IS NULL OR unregistered_at > registered_at)
);

CREATE INDEX idx_division_teams_division ON division_teams(division_id);
CREATE INDEX idx_division_teams_team ON division_teams(team_id);
CREATE INDEX idx_division_teams_current ON division_teams(division_id, team_id) WHERE unregistered_at IS NULL;
CREATE INDEX idx_division_teams_history ON division_teams(team_id, registered_at, unregistered_at);

COMMENT ON TABLE division_teams IS 'Team registrations in divisions - temporal history for promotion/relegation';

-- Standings table (mirrors standings from source sites - no calculations)
CREATE TABLE standings (
    id SERIAL PRIMARY KEY,
    competition_id INTEGER NOT NULL,  -- For APSL: division_id (each division is a competition)
    season_id INTEGER NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (competition_id, season_id, team_id)
);

CREATE INDEX idx_standings_comp_season ON standings(competition_id, season_id);
CREATE INDEX idx_standings_team ON standings(team_id);
CREATE INDEX idx_standings_season ON standings(season_id);

COMMENT ON TABLE standings IS 'League standings data mirrored from source sites (APSL, CSL, etc.) - no calculations, direct copy of published standings';
COMMENT ON COLUMN standings.competition_id IS 'Competition identifier - for APSL this is the division_id since each division is its own competition';
COMMENT ON COLUMN standings.source IS 'Source of standings data (e.g., "APSL Standings Page")';

-- Optional snapshots for historical tracking
CREATE TABLE standings_snapshots (
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
    source TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_snapshots_comp_season ON standings_snapshots(competition_id, season_id);
CREATE INDEX idx_snapshots_fetched ON standings_snapshots(fetched_at);

COMMENT ON TABLE standings_snapshots IS 'Historical snapshots of standings for tracking changes over time';

-- Track external IDs for division team entries
CREATE TABLE division_team_external_ids (
    id SERIAL PRIMARY KEY,
    division_team_id INTEGER NOT NULL REFERENCES division_teams(id) ON DELETE CASCADE,
    source_system_id INTEGER NOT NULL REFERENCES source_systems(id),
    external_id VARCHAR(255) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(source_system_id, external_id)
);

CREATE INDEX idx_division_team_external_ids_team ON division_team_external_ids(division_team_id);
CREATE INDEX idx_division_team_external_ids_source ON division_team_external_ids(source_system_id, external_id);

COMMENT ON TABLE division_team_external_ids IS 'Tracks external identifiers (e.g., APSL team ID) for division team entries';
COMMENT ON COLUMN division_team_external_ids.external_id IS 'Source system identifier (e.g., "114808" from APSL)';

-- Lookup table for team alias types
CREATE TABLE alias_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO alias_types (name, description) VALUES
    ('abbreviation', 'Abbreviated team name (e.g., "LFC" for "Liverpool FC")'),
    ('alternate_spelling', 'Alternative spelling or formatting'),
    ('historical_name', 'Previous team name (rebranding, merger)'),
    ('nickname', 'Informal nickname (e.g., "The Reds")'),
    ('translation', 'Name in different language'),
    ('social_media', 'Name used on social media platforms'),
    ('common_misspelling', 'Common misspelling to help with search/matching')
ON CONFLICT (name) DO NOTHING;

-- Team aliases for name variations
CREATE TABLE team_aliases (
    id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    alias_name VARCHAR(255) NOT NULL,
    alias_type_id INTEGER NOT NULL REFERENCES alias_types(id),
    source_system_id INTEGER REFERENCES source_systems(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(team_id, alias_name)
);

CREATE INDEX idx_team_aliases_team ON team_aliases(team_id);
CREATE INDEX idx_team_aliases_name ON team_aliases(alias_name);
CREATE INDEX idx_team_aliases_type ON team_aliases(alias_type_id);


-- Players (sports role - links to persons)
-- player.person_id references the person's identity (name, birth_date)
-- A person can be a player without having a user account (scraped players)
CREATE TABLE players (
    id SERIAL PRIMARY KEY,
    person_id INTEGER UNIQUE NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    height_cm INTEGER,                      -- Height in centimeters
    nationality VARCHAR(3),                 -- ISO 3166-1 alpha-3 (USA, BRA, MEX)
    photo_url TEXT,
    scrape_target_id INTEGER REFERENCES scrape_targets(id),
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(source_system_id, external_id)
);

CREATE INDEX idx_players_person ON players(person_id);

COMMENT ON TABLE players IS 'Sports role - links persons to soccer player data. Person may or may not have user account.';
COMMENT ON COLUMN players.person_id IS 'FK to persons table - name and birth_date stored in persons';

-- Player positions (player profile - multiple positions a player CAN play)
CREATE TABLE player_positions (
    id SERIAL PRIMARY KEY,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    position_id INTEGER NOT NULL REFERENCES positions(id),
    is_primary BOOLEAN DEFAULT false,  -- Primary/preferred position
    sort_order INTEGER DEFAULT 0,
    UNIQUE(player_id, position_id)
);

CREATE INDEX idx_player_positions_player ON player_positions(player_id);
CREATE INDEX idx_player_positions_position ON player_positions(position_id);
CREATE INDEX idx_player_positions_primary ON player_positions(player_id, is_primary) WHERE is_primary = true;

COMMENT ON TABLE player_positions IS 'Positions a player CAN play (general profile across all teams)';

-- Player rosters for division team entries
CREATE TABLE division_team_players (
    id SERIAL PRIMARY KEY,
    division_team_id INTEGER NOT NULL REFERENCES division_teams(id) ON DELETE CASCADE,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    jersey_number VARCHAR(10),
    -- No is_active - derived from left_at IS NULL
    -- Multiple rows per player track transfer history
    -- Current roster: WHERE left_at IS NULL
    -- History: All rows ordered by joined_at
    CHECK (left_at IS NULL OR left_at > joined_at),
    UNIQUE (division_team_id, player_id, joined_at)
);

CREATE INDEX idx_division_team_players_team ON division_team_players(division_team_id);
CREATE INDEX idx_division_team_players_player ON division_team_players(player_id);
CREATE INDEX idx_division_team_players_current ON division_team_players(division_team_id, player_id) WHERE left_at IS NULL;
CREATE INDEX idx_division_team_players_history ON division_team_players(player_id, joined_at, left_at);

COMMENT ON TABLE division_team_players IS 'Players assigned to division team entries (official league roster). Multiple rows per player track transfer history - each row is one period of team membership.';

-- Track external IDs for division team player entries
CREATE TABLE division_team_player_external_ids (
    id SERIAL PRIMARY KEY,
    division_team_player_id INTEGER NOT NULL REFERENCES division_team_players(id) ON DELETE CASCADE,
    source_system_id INTEGER NOT NULL REFERENCES source_systems(id),
    external_id VARCHAR(255) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(source_system_id, external_id)
);

CREATE INDEX idx_division_team_player_external_ids_team_player ON division_team_player_external_ids(division_team_player_id);
CREATE INDEX idx_division_team_player_external_ids_source ON division_team_player_external_ids(source_system_id, external_id);

COMMENT ON TABLE division_team_player_external_ids IS 'Tracks external identifiers (e.g., APSL roster entry) for team player entries';
COMMENT ON COLUMN division_team_player_external_ids.external_id IS 'Source system roster entry identifier (e.g., "114808-chris-richards" from APSL)';

-- Position assignments for division team players (what position they play for THIS team in THIS division)
CREATE TABLE division_team_player_positions (
    id SERIAL PRIMARY KEY,
    division_team_player_id INTEGER NOT NULL REFERENCES division_team_players(id) ON DELETE CASCADE,
    position_id INTEGER NOT NULL REFERENCES positions(id),
    is_primary BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(division_team_player_id, position_id)
);

CREATE INDEX idx_division_team_player_positions_team_player ON division_team_player_positions(division_team_player_id);
CREATE INDEX idx_division_team_player_positions_position ON division_team_player_positions(position_id);
CREATE INDEX idx_division_team_player_positions_primary ON division_team_player_positions(division_team_player_id, is_primary) WHERE is_primary = true;

COMMENT ON TABLE division_team_player_positions IS 'Position assignment for team players (what position they play for THIS team in THIS division)';

CREATE TABLE coaches (
    id SERIAL PRIMARY KEY,
    person_id INTEGER UNIQUE NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    license_level VARCHAR(50),
    certifications TEXT,
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE coaches IS 'Coaching role - links persons to coach-specific data. Person may or may not have user account.';
COMMENT ON COLUMN coaches.person_id IS 'FK to persons table - name stored in persons table';
CREATE INDEX idx_coaches_person ON coaches(person_id);
CREATE INDEX idx_coaches_source ON coaches(source_system_id);

CREATE TABLE division_team_coaches (
    division_team_id INTEGER NOT NULL REFERENCES division_teams(id) ON DELETE CASCADE,
    coach_id INTEGER NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    coach_role_id INTEGER REFERENCES coach_roles(id),
    -- No is_active - derived from ended_at IS NULL
    -- Multiple rows track coaching tenure history
    CHECK (ended_at IS NULL OR ended_at > started_at),
    PRIMARY KEY (division_team_id, coach_id, started_at)
);

CREATE INDEX idx_division_team_coaches_team ON division_team_coaches(division_team_id);
CREATE INDEX idx_division_team_coaches_coach ON division_team_coaches(coach_id);
CREATE INDEX idx_division_team_coaches_role ON division_team_coaches(coach_role_id);
CREATE INDEX idx_division_team_coaches_current ON division_team_coaches(division_team_id, coach_id) WHERE ended_at IS NULL;

COMMENT ON TABLE division_team_coaches IS 'Coaches assigned to division team entries (same level as players)';

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
    home_team_id INTEGER REFERENCES teams(id),
    away_team_id INTEGER REFERENCES teams(id),
    match_date DATE NOT NULL,
    match_time TIME,
    venue_id INTEGER REFERENCES venues(id),
    title VARCHAR(255),
    description TEXT,
    match_status_id INTEGER REFERENCES match_statuses(id) DEFAULT 1,
    home_score INTEGER,
    away_score INTEGER,
    
    -- Bracket tournament support (NULL for league games)
    round_name VARCHAR(50),  -- 'Quarterfinals', 'Semifinals', 'Final', 'Third Place', etc.
    bracket_position VARCHAR(20),  -- 'A1', 'B2', 'W1', 'L2', etc.
    next_match_id INTEGER REFERENCES matches(id),  -- Winner advances to this match
    loser_next_match_id INTEGER REFERENCES matches(id),  -- Loser advances here (double elimination)
    seed_home INTEGER,  -- Tournament seeding for home team
    seed_away INTEGER,  -- Tournament seeding for away team
    
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100),  -- Unique per source system
    scrape_target_id INTEGER REFERENCES scrape_targets(id),
    created_by_user_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Validation: league/cup matches require both teams, practice/tournament can be NULL (for TBD)
    CONSTRAINT check_match_teams CHECK (
        (match_type_id IN (3, 5)) OR  -- Practice (3) or Tournament (5) can have NULL teams
        (home_team_id IS NOT NULL AND away_team_id IS NOT NULL)  -- League/Cup require both teams
    ),
    
    -- External ID is unique per source system (APSL match 123 != CASA match 123)
    UNIQUE(source_system_id, external_id)
);

CREATE INDEX idx_matches_type ON matches(match_type_id);
CREATE INDEX idx_matches_date ON matches(match_date);
CREATE INDEX idx_matches_teams ON matches(home_team_id, away_team_id);
CREATE INDEX idx_matches_status ON matches(match_status_id);
CREATE INDEX idx_matches_source ON matches(source_system_id);
CREATE INDEX idx_matches_next_match ON matches(next_match_id);
CREATE INDEX idx_matches_loser_next ON matches(loser_next_match_id);

-- Match-Division association (supports cross-division games)
CREATE TABLE match_divisions (
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    division_id INTEGER NOT NULL REFERENCES divisions(id) ON DELETE CASCADE,
    counts_for_standings BOOLEAN DEFAULT true,  -- Whether this match counts toward division standings
    PRIMARY KEY (match_id, division_id)
);

CREATE INDEX idx_match_divisions_match ON match_divisions(match_id);
CREATE INDEX idx_match_divisions_division ON match_divisions(division_id);

-- player_match_stats table removed - see 99-stats-views.sql for player_match_performance view
-- Statistics are calculated on-the-fly from match_events for accuracy

-- team_standings table removed - see 99-stats-views.sql for team_season_standings view
-- Standings are calculated on-the-fly from match results for accuracy and consistency

-- Team stats (comprehensive season statistics)
-- team_stats table removed - see 99-stats-views.sql for team_season_standings view
-- Statistics are calculated on-the-fly from matches table for accuracy

-- ============================================================================
-- 5d. SCHEDULING SYSTEM (Fully Normalized)
-- ============================================================================

-- Parent table for a schedule generation job
CREATE TABLE schedule_generations (
    id SERIAL PRIMARY KEY,
    division_id INTEGER NOT NULL REFERENCES divisions(id) ON DELETE CASCADE,
    season_start_date DATE NOT NULL,
    season_end_date DATE NOT NULL,
    algorithm_used VARCHAR(50),  -- 'round_robin', 'balanced_unbalanced', 'tournament_seeded'
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'failed')),
    generated_match_count INTEGER DEFAULT 0,
    error_message TEXT,
    created_by_user_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE INDEX idx_schedule_generations_division ON schedule_generations(division_id);
CREATE INDEX idx_schedule_generations_status ON schedule_generations(status);

-- Key-value configuration options for schedule generation
CREATE TABLE schedule_generation_options (
    id SERIAL PRIMARY KEY,
    schedule_generation_id INTEGER NOT NULL REFERENCES schedule_generations(id) ON DELETE CASCADE,
    option_key VARCHAR(100) NOT NULL,  -- 'games_per_team', 'home_away_balanced', 'bye_weeks_allowed', etc.
    option_value TEXT NOT NULL,  -- JSON string or simple value
    UNIQUE(schedule_generation_id, option_key)
);

CREATE INDEX idx_schedule_options_generation ON schedule_generation_options(schedule_generation_id);

-- Rivalry pairs for unbalanced schedules (teams that should play multiple times)
CREATE TABLE schedule_rivalry_pairs (
    id SERIAL PRIMARY KEY,
    schedule_generation_id INTEGER NOT NULL REFERENCES schedule_generations(id) ON DELETE CASCADE,
    team_id_1 INTEGER NOT NULL REFERENCES teams(id),
    team_id_2 INTEGER NOT NULL REFERENCES teams(id),
    games_count INTEGER DEFAULT 2,  -- How many times these teams should play
    UNIQUE(schedule_generation_id, team_id_1, team_id_2),
    CONSTRAINT check_different_rivalry_teams CHECK (team_id_1 < team_id_2)
);

CREATE INDEX idx_schedule_rivalries_generation ON schedule_rivalry_pairs(schedule_generation_id);
CREATE INDEX idx_schedule_rivalries_teams ON schedule_rivalry_pairs(team_id_1, team_id_2);

-- Tournament group assignments (for group stage scheduling)
CREATE TABLE schedule_group_assignments (
    id SERIAL PRIMARY KEY,
    schedule_generation_id INTEGER NOT NULL REFERENCES schedule_generations(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id),
    group_name VARCHAR(10) NOT NULL,  -- 'A', 'B', 'C', etc.
    seed INTEGER,  -- Seeding within the group
    UNIQUE(schedule_generation_id, team_id)
);

CREATE INDEX idx_schedule_groups_generation ON schedule_group_assignments(schedule_generation_id);
CREATE INDEX idx_schedule_groups_team ON schedule_group_assignments(team_id);
CREATE INDEX idx_schedule_groups_name ON schedule_group_assignments(group_name);

-- Venue availability constraints (hard constraints)
CREATE TABLE schedule_venue_constraints (
    id SERIAL PRIMARY KEY,
    schedule_generation_id INTEGER NOT NULL REFERENCES schedule_generations(id) ON DELETE CASCADE,
    venue_id INTEGER NOT NULL REFERENCES venues(id),
    blocked_date DATE NOT NULL,
    blocked_start_time TIME,
    blocked_end_time TIME,
    reason VARCHAR(255),
    UNIQUE(schedule_generation_id, venue_id, blocked_date, blocked_start_time)
);

CREATE INDEX idx_schedule_venue_constraints_generation ON schedule_venue_constraints(schedule_generation_id);
CREATE INDEX idx_schedule_venue_constraints_venue ON schedule_venue_constraints(venue_id);

-- Team blackout dates (teams unavailable to play)
CREATE TABLE schedule_team_blackouts (
    id SERIAL PRIMARY KEY,
    schedule_generation_id INTEGER NOT NULL REFERENCES schedule_generations(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id),
    blackout_date DATE NOT NULL,
    reason VARCHAR(255),
    UNIQUE(schedule_generation_id, team_id, blackout_date)
);

CREATE INDEX idx_schedule_team_blackouts_generation ON schedule_team_blackouts(schedule_generation_id);
CREATE INDEX idx_schedule_team_blackouts_team ON schedule_team_blackouts(team_id);

-- Day-of-week constraints (e.g., "Division A always plays on Tuesdays")
CREATE TABLE schedule_day_constraints (
    id SERIAL PRIMARY KEY,
    schedule_generation_id INTEGER NOT NULL REFERENCES schedule_generations(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),  -- 0=Sunday, 6=Saturday
    preferred_time TIME,
    is_required BOOLEAN DEFAULT false,  -- Hard constraint vs soft preference
    UNIQUE(schedule_generation_id, day_of_week)
);

CREATE INDEX idx_schedule_day_constraints_generation ON schedule_day_constraints(schedule_generation_id);

-- Division weights for unbalanced scheduling (how many games against each division)
CREATE TABLE schedule_division_weights (
    id SERIAL PRIMARY KEY,
    schedule_generation_id INTEGER NOT NULL REFERENCES schedule_generations(id) ON DELETE CASCADE,
    opponent_division_id INTEGER NOT NULL REFERENCES divisions(id),
    games_per_opponent INTEGER DEFAULT 1,  -- How many games to play vs each team in that division
    UNIQUE(schedule_generation_id, opponent_division_id)
);

CREATE INDEX idx_schedule_division_weights_generation ON schedule_division_weights(schedule_generation_id);
CREATE INDEX idx_schedule_division_weights_opponent ON schedule_division_weights(opponent_division_id);

-- Lookup table for schedule preference types (normalized)
CREATE TABLE schedule_preference_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO schedule_preference_types (id, name, description, sort_order) VALUES
    (1, 'avoid_back_to_back', 'Avoid scheduling teams on consecutive days', 1),
    (2, 'prefer_home_field_parity', 'Balance home/away games evenly', 2),
    (3, 'minimize_travel', 'Minimize travel distance between venues', 3),
    (4, 'cluster_bye_weeks', 'Group bye weeks together', 4),
    (5, 'avoid_early_rematches', 'Avoid rematches in first half of season', 5)
ON CONFLICT (id) DO NOTHING;

-- Soft preferences for scheduling (non-blocking)
CREATE TABLE schedule_preferences (
    id SERIAL PRIMARY KEY,
    schedule_generation_id INTEGER NOT NULL REFERENCES schedule_generations(id) ON DELETE CASCADE,
    preference_type_id INTEGER NOT NULL REFERENCES schedule_preference_types(id),
    preference_value TEXT,  -- JSON or simple value
    weight INTEGER DEFAULT 1  -- Priority/importance of this preference
);

CREATE INDEX idx_schedule_preferences_generation ON schedule_preferences(schedule_generation_id);
CREATE INDEX idx_schedule_preferences_type ON schedule_preferences(preference_type_id);

-- ============================================================================
-- 5e. MATCH EVENTS (Event Sourcing Architecture)
-- ============================================================================

-- Lookup table for event types (normalized)
CREATE TABLE match_event_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(10),
    sort_order INTEGER DEFAULT 0
);

INSERT INTO match_event_types (id, name, description, icon, sort_order) VALUES
    (1, 'goal', 'Goal scored', '⚽', 1),
    (2, 'assist', 'Assist on goal', '🅰️', 2),
    (3, 'yellow_card', 'Yellow card received', '🟨', 12),
    (4, 'red_card', 'Red card received', '🟥', 13),
    (5, 'sub_in', 'Substituted into match', '⬆️', 14),
    (6, 'sub_out', 'Substituted out of match', '⬇️', 15),
    (7, 'shot_on_target', 'Shot on target (requires save or goal)', '🎯', 6),
    (8, 'shot_off_target', 'Shot off target (missed)', '↗️', 7),
    (9, 'save', 'Goalkeeper save', '🧤', 8),
    (10, 'corner', 'Corner kick awarded', '📐', 9),
    (11, 'foul', 'Foul committed', '🚫', 10),
    (12, 'offside', 'Offside call', '🚩', 11),
    (13, 'penalty_awarded', 'Penalty kick awarded', '⚡', 3),
    (14, 'penalty_missed', 'Penalty kick missed/saved', '❌', 4),
    (15, 'own_goal', 'Own goal (credited against team)', '⚽', 5),
    (16, 'injury', 'Player injured/treatment', '🚑', 16),
    (17, 'captain', 'Captain for this match', '©️', 17)
ON CONFLICT (id) DO NOTHING;

-- Individual match events (atomic records)
CREATE TABLE match_events (
    id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id),
    event_type_id INTEGER NOT NULL REFERENCES match_event_types(id),
    minute INTEGER NOT NULL CHECK (minute BETWEEN 0 AND 150),  -- Allow up to 150 for extra time
    assisted_by_player_id INTEGER REFERENCES players(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_match_events_match ON match_events(match_id);
CREATE INDEX idx_match_events_player ON match_events(player_id);
CREATE INDEX idx_match_events_team ON match_events(team_id);
CREATE INDEX idx_match_events_type ON match_events(event_type_id);
CREATE INDEX idx_match_events_minute ON match_events(minute);

-- Match lineups (who started vs who was available substitute)
-- Separate from events because lineup is pre-match state, not an in-match action
CREATE TABLE match_lineups (
    id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id),
    is_starter BOOLEAN NOT NULL,
    position_id INTEGER REFERENCES positions(id),  -- Position played in this match (single position)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(match_id, player_id)
);

CREATE INDEX idx_match_lineups_match ON match_lineups(match_id);
CREATE INDEX idx_match_lineups_player ON match_lineups(player_id);
CREATE INDEX idx_match_lineups_team ON match_lineups(team_id);
CREATE INDEX idx_match_lineups_starter ON match_lineups(is_starter);

-- Player season stats (aggregated from roster pages)
-- Used for season totals including assists that aren't tracked per-match
-- player_season_stats table removed - see 99-stats-views.sql for player_season_stats_view
-- Statistics are calculated on-the-fly from match_events for accuracy

-- ============================================================================
-- 6. CHAT SYSTEM (Built-in messaging)
-- ============================================================================

CREATE TABLE chats (
    id SERIAL PRIMARY KEY,
    team_id INTEGER REFERENCES teams(id),  -- Optional: link to team if chat is for a team
    name VARCHAR(255) NOT NULL,
    description TEXT,
    chat_type_id INTEGER REFERENCES chat_types(id),
    image_url TEXT,
    created_by_user_id INTEGER REFERENCES users(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chats_team ON chats(team_id);
CREATE INDEX idx_chats_type ON chats(chat_type_id);
CREATE INDEX idx_chats_created_by ON chats(created_by_user_id);

-- Chat integrations with external platforms
CREATE TABLE chat_integrations (
    id SERIAL PRIMARY KEY,
    chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    provider_id INTEGER NOT NULL REFERENCES chat_providers(id),
    external_id VARCHAR(255) NOT NULL,  -- GroupMe group_id, Discord channel_id, etc.
    external_name VARCHAR(255),
    is_primary BOOLEAN DEFAULT false,  -- Which system is source of truth
    sync_messages BOOLEAN DEFAULT false,
    sync_members BOOLEAN DEFAULT false,
    sync_events BOOLEAN DEFAULT false,
    last_synced_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(provider_id, external_id)
);

CREATE INDEX idx_chat_integrations_chat ON chat_integrations(chat_id);
CREATE INDEX idx_chat_integrations_provider ON chat_integrations(provider_id);
CREATE INDEX idx_chat_integrations_primary ON chat_integrations(chat_id, is_primary) WHERE is_primary = true;

-- Chat members with temporal tracking (people can leave and rejoin chats)
CREATE TABLE chat_members (
    chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    chat_role_id INTEGER REFERENCES chat_roles(id) DEFAULT 2,
    -- No is_active - derived from left_at IS NULL
    -- Multiple rows track chat membership history (leave and rejoin)
    CHECK (left_at IS NULL OR left_at > joined_at),
    PRIMARY KEY (chat_id, user_id, joined_at)
);

CREATE INDEX idx_chat_members_chat ON chat_members(chat_id);
CREATE INDEX idx_chat_members_user ON chat_members(user_id);
CREATE INDEX idx_chat_members_role ON chat_members(chat_role_id);
CREATE INDEX idx_chat_members_current ON chat_members(chat_id, user_id) WHERE left_at IS NULL;
CREATE INDEX idx_chat_members_history ON chat_members(user_id, joined_at, left_at);

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

-- Chat events (games, practices, social events posted in chats)
CREATE TABLE chat_events (
    id SERIAL PRIMARY KEY,
    chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    match_id INTEGER REFERENCES matches(id),  -- Optional: link to official match
    title VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    event_date DATE,
    event_time TIME,
    created_by_user_id INTEGER REFERENCES users(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chat_events_chat ON chat_events(chat_id);
CREATE INDEX idx_chat_events_match ON chat_events(match_id);
CREATE INDEX idx_chat_events_date ON chat_events(event_date);
CREATE INDEX idx_chat_events_created_by ON chat_events(created_by_user_id);

-- RSVPs for chat events
CREATE TABLE chat_event_rsvps (
    id SERIAL PRIMARY KEY,
    chat_event_id INTEGER NOT NULL REFERENCES chat_events(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id),
    rsvp_status_id INTEGER NOT NULL REFERENCES rsvp_statuses(id),
    response_note TEXT,
    responded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(chat_event_id, user_id)
);

CREATE INDEX idx_chat_event_rsvps_event ON chat_event_rsvps(chat_event_id);
CREATE INDEX idx_chat_event_rsvps_user ON chat_event_rsvps(user_id);
CREATE INDEX idx_chat_event_rsvps_status ON chat_event_rsvps(rsvp_status_id);

-- created_by_chat_id column removed - use chat_events junction table instead

-- ============================================================================
-- 7. SUPPORTING TABLES
-- ============================================================================

-- ============================================================================
-- Entity-Specific Scrape Target Tables (Normalized)
-- ============================================================================
-- NOTE: These tables are placed here (at the end) to avoid forward references
-- They reference entity tables (seasons, divisions, teams, matches, chats, etc.)
-- that are created earlier in this schema file.
-- ============================================================================

CREATE TABLE conference_structure_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    season_id INTEGER NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_conference_structure_scrape_targets_target ON conference_structure_scrape_targets(scrape_target_id);
CREATE INDEX idx_conference_structure_scrape_targets_season ON conference_structure_scrape_targets(season_id);

COMMENT ON TABLE conference_structure_scrape_targets IS 'Scrapes league structure (conferences, divisions)';

CREATE TABLE standings_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    division_id INTEGER NOT NULL REFERENCES divisions(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_standings_scrape_targets_target ON standings_scrape_targets(scrape_target_id);
CREATE INDEX idx_standings_scrape_targets_division ON standings_scrape_targets(division_id);

COMMENT ON TABLE standings_scrape_targets IS 'Scrapes division standings';

CREATE TABLE schedule_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    division_id INTEGER NOT NULL REFERENCES divisions(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_schedule_scrape_targets_target ON schedule_scrape_targets(scrape_target_id);
CREATE INDEX idx_schedule_scrape_targets_division ON schedule_scrape_targets(division_id);

COMMENT ON TABLE schedule_scrape_targets IS 'Scrapes match schedules for division';

CREATE TABLE team_roster_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    division_team_id INTEGER NOT NULL REFERENCES division_teams(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_team_roster_scrape_targets_target ON team_roster_scrape_targets(scrape_target_id);
CREATE INDEX idx_team_roster_scrape_targets_team ON team_roster_scrape_targets(division_team_id);

COMMENT ON TABLE team_roster_scrape_targets IS 'Scrapes team rosters (players)';

CREATE TABLE team_season_stats_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    division_team_id INTEGER NOT NULL REFERENCES division_teams(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_team_season_stats_scrape_targets_target ON team_season_stats_scrape_targets(scrape_target_id);
CREATE INDEX idx_team_season_stats_scrape_targets_team ON team_season_stats_scrape_targets(division_team_id);

COMMENT ON TABLE team_season_stats_scrape_targets IS 'Scrapes team season statistics';

CREATE TABLE player_season_stats_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    division_team_player_id INTEGER NOT NULL REFERENCES division_team_players(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_player_season_stats_scrape_targets_target ON player_season_stats_scrape_targets(scrape_target_id);
CREATE INDEX idx_player_season_stats_scrape_targets_player ON player_season_stats_scrape_targets(division_team_player_id);

COMMENT ON TABLE player_season_stats_scrape_targets IS 'Scrapes player season statistics';

CREATE TABLE player_profile_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_player_profile_scrape_targets_target ON player_profile_scrape_targets(scrape_target_id);
CREATE INDEX idx_player_profile_scrape_targets_player ON player_profile_scrape_targets(player_id);

COMMENT ON TABLE player_profile_scrape_targets IS 'Scrapes player biographical data';

CREATE TABLE match_lineups_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_match_lineups_scrape_targets_target ON match_lineups_scrape_targets(scrape_target_id);
CREATE INDEX idx_match_lineups_scrape_targets_match ON match_lineups_scrape_targets(match_id);

COMMENT ON TABLE match_lineups_scrape_targets IS 'Scrapes match lineups (starters vs subs)';

CREATE TABLE match_events_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_match_events_scrape_targets_target ON match_events_scrape_targets(scrape_target_id);
CREATE INDEX idx_match_events_scrape_targets_match ON match_events_scrape_targets(match_id);

COMMENT ON TABLE match_events_scrape_targets IS 'Scrapes match events (goals, cards, subs)';

CREATE TABLE match_score_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_match_score_scrape_targets_target ON match_score_scrape_targets(scrape_target_id);
CREATE INDEX idx_match_score_scrape_targets_match ON match_score_scrape_targets(match_id);

COMMENT ON TABLE match_score_scrape_targets IS 'Scrapes match scores';

CREATE TABLE venue_details_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    venue_name_search VARCHAR(255) NOT NULL,
    requires_api_key BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_venue_details_scrape_targets_target ON venue_details_scrape_targets(scrape_target_id);

COMMENT ON TABLE venue_details_scrape_targets IS 'Scrapes venue information (Google Places)';

CREATE TABLE chat_messages_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    external_group_id VARCHAR(255),
    requires_api_key BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chat_messages_scrape_targets_target ON chat_messages_scrape_targets(scrape_target_id);
CREATE INDEX idx_chat_messages_scrape_targets_chat ON chat_messages_scrape_targets(chat_id);

COMMENT ON TABLE chat_messages_scrape_targets IS 'Scrapes chat messages';

CREATE TABLE chat_events_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chat_events_scrape_targets_target ON chat_events_scrape_targets(scrape_target_id);
CREATE INDEX idx_chat_events_scrape_targets_chat ON chat_events_scrape_targets(chat_id);

COMMENT ON TABLE chat_events_scrape_targets IS 'Scrapes chat events';

CREATE TABLE chat_members_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chat_members_scrape_targets_target ON chat_members_scrape_targets(scrape_target_id);
CREATE INDEX idx_chat_members_scrape_targets_chat ON chat_members_scrape_targets(chat_id);

COMMENT ON TABLE chat_members_scrape_targets IS 'Scrapes chat members';

CREATE TABLE chat_rsvps_scrape_targets (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER UNIQUE NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    chat_event_id INTEGER NOT NULL REFERENCES chat_events(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chat_rsvps_scrape_targets_target ON chat_rsvps_scrape_targets(scrape_target_id);
CREATE INDEX idx_chat_rsvps_scrape_targets_event ON chat_rsvps_scrape_targets(chat_event_id);

COMMENT ON TABLE chat_rsvps_scrape_targets IS 'Scrapes chat event RSVPs';

-- ============================================================================
-- Team Name Mapping (for club assignment)
-- ============================================================================

CREATE TABLE team_name_mappings (
    id SERIAL PRIMARY KEY,
    source_system_id INTEGER NOT NULL REFERENCES source_systems(id),
    scraped_name VARCHAR(255) NOT NULL,
    club_id INTEGER NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(source_system_id, scraped_name)
);

CREATE INDEX idx_team_name_mappings_source ON team_name_mappings(source_system_id);
CREATE INDEX idx_team_name_mappings_club ON team_name_mappings(club_id);
CREATE INDEX idx_team_name_mappings_name ON team_name_mappings(source_system_id, scraped_name);

COMMENT ON TABLE team_name_mappings IS 'Maps scraped team names to clubs for automatic assignment';

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
-- SCHEMA SUMMARY (Version 6.2 - Normalized Users/Players/Chats)
-- ============================================================================
-- Lookup Tables: 12 (match_types, match_statuses, rsvp_statuses, age_calculation_methods, chat_providers, etc.)
-- Governing Bodies: 3 tables
-- Organizations & Leagues: 4 tables (organizations, leagues, conferences, divisions)
-- FootballHome Identity: 9 tables (users, user_emails, user_phones, external_identities, admins, clubs, club_admins, sport_divisions)
-- Unified League Data: 10 tables (teams, team_divisions, players, team_division_players, coaches, team_coaches, matches, player_match_stats, team_standings, venues)
-- Chat System: 7 tables (chats, chat_integrations, chat_members, chat_messages, chat_events, chat_event_rsvps)
-- Player Identity: 1 junction table (player_users)
-- Supporting: 1 table (audit_log)
-- TOTAL: ~49 tables
--
-- Key Architecture:
-- - Leagues = Age + Sex groupings (e.g., "Men's Over 40", "Women's U19")
-- - Divisions = Skill tiers within leagues (Premier, Division 1, 2, 3)
-- - Players = roster entities (from scraping), Users = participants (interact with system)
-- - Users have provisional/member/bot types, multiple emails/phones via junctions
-- - Teams → team_divisions (league membership), team_division_players (rosters)
-- - Chats are platform-agnostic with chat_integrations to external providers
-- - Chat events with optional match_id link + chat_event_rsvps
-- - No platform-specific tables (GroupMe, Discord data in generic structure)
-- ============================================================================
