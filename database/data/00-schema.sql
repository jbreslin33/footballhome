-- Football Home Database Schema - Fully Normalized Architecture
-- Version: 6.2 - Normalized Users/Players/Chats + External Integrations
--
-- Architecture:
-- 1. Lookup Tables - Reference data for all enums (age calculation, chat providers, etc.)
-- 2. Governing Body Hierarchy - FIFA → Confederations → National → Regional → State
-- 3. Organizations & Leagues - APSL, CASA, Custom leagues with age/sex attributes
-- 4. Football Home Identity - Users (member/provisional/bot), clubs, sport divisions
-- 5. Unified League Data - Teams, players (entities), rosters (junctions)
-- 6. Chat System - Generic messaging with external platform integrations
-- 7. Player Identity - Junction tables linking users to league players
-- 8. Supporting Tables - Venues, audit log
--
-- Key Principles:
-- - NO table duplication (no apsl_* vs casa_*) - differentiate by FKs
-- - ALL text enums replaced with lookup tables
-- - Leagues = age + sex groupings, Divisions = skill tiers
-- - Teams join divisions via team_divisions, rosters via team_division_players
-- - Players = entities (data from scraping), Users = participants (can interact)
-- - Users can have multiple emails/phones (junction tables)
-- - External identities (GroupMe, Discord) link to provisional/member users
-- - Chats are platform-agnostic with optional external integrations
-- - Chat events (practices, games, social) with RSVPs
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
    (3, 'custom', 'User-created/custom data', true),
    (4, 'groupme', 'GroupMe integration', true)
ON CONFLICT (id) DO NOTHING;

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
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_countries_code ON countries(code);
CREATE INDEX idx_countries_fifa ON countries(fifa_code);

INSERT INTO countries (code, name, fifa_code) VALUES
    ('USA', 'United States', 'USA'),
    ('CAN', 'Canada', 'CAN'),
    ('MEX', 'Mexico', 'MEX'),
    ('BRA', 'Brazil', 'BRA'),
    ('ARG', 'Argentina', 'ARG'),
    ('GBR', 'United Kingdom', 'ENG'),
    ('ESP', 'Spain', 'ESP'),
    ('FRA', 'France', 'FRA'),
    ('DEU', 'Germany', 'GER'),
    ('ITA', 'Italy', 'ITA'),
    ('PRT', 'Portugal', 'POR'),
    ('NLD', 'Netherlands', 'NED')
ON CONFLICT (code) DO NOTHING;

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

INSERT INTO states (country_id, code, name) VALUES
    ((SELECT id FROM countries WHERE code = 'USA'), 'PA', 'Pennsylvania'),
    ((SELECT id FROM countries WHERE code = 'USA'), 'NJ', 'New Jersey'),
    ((SELECT id FROM countries WHERE code = 'USA'), 'NY', 'New York'),
    ((SELECT id FROM countries WHERE code = 'USA'), 'CA', 'California'),
    ((SELECT id FROM countries WHERE code = 'USA'), 'TX', 'Texas'),
    ((SELECT id FROM countries WHERE code = 'USA'), 'FL', 'Florida'),
    ((SELECT id FROM countries WHERE code = 'USA'), 'IL', 'Illinois'),
    ((SELECT id FROM countries WHERE code = 'USA'), 'OH', 'Ohio'),
    ((SELECT id FROM countries WHERE code = 'USA'), 'MA', 'Massachusetts'),
    ((SELECT id FROM countries WHERE code = 'USA'), 'MD', 'Maryland'),
    ((SELECT id FROM countries WHERE code = 'USA'), 'VA', 'Virginia'),
    ((SELECT id FROM countries WHERE code = 'USA'), 'DE', 'Delaware')
ON CONFLICT (country_id, code) DO NOTHING;

CREATE TABLE governing_bodies (
    id SERIAL PRIMARY KEY,
    scope_id INTEGER NOT NULL REFERENCES governing_body_scopes(id),
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(50),
    website_url TEXT,
    country_id INTEGER REFERENCES countries(id),
    state_id INTEGER REFERENCES states(id),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name)
);

CREATE INDEX idx_governing_bodies_scope ON governing_bodies(scope_id);
CREATE INDEX idx_governing_bodies_country ON governing_bodies(country_id);
CREATE INDEX idx_governing_bodies_state ON governing_bodies(state_id);

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
    UNIQUE(organization_id, name, season)
);

CREATE INDEX idx_leagues_organization ON leagues(organization_id);
CREATE INDEX idx_leagues_source ON leagues(source_system_id);
CREATE INDEX idx_leagues_age_method ON leagues(age_calculation_method_id);

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
    league_id INTEGER NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    conference_id INTEGER REFERENCES conferences(id) ON DELETE CASCADE,
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

CREATE INDEX idx_divisions_league ON divisions(league_id);
CREATE INDEX idx_divisions_conference ON divisions(conference_id);
CREATE INDEX idx_divisions_type ON divisions(division_type_id);
CREATE INDEX idx_divisions_source ON divisions(source_system_id);
CREATE INDEX idx_divisions_skill ON divisions(skill_level);

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

-- ============================================================================
-- 5. UNIFIED LEAGUE DATA (Replaces all apsl_*, casa_*, custom_* tables)
-- ============================================================================

CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    sport_division_id INTEGER REFERENCES sport_divisions(id),  -- Nullable for external league teams
    name VARCHAR(255) NOT NULL UNIQUE,
    city VARCHAR(100),
    logo_url TEXT,
    source_system_id INTEGER REFERENCES source_systems(id),
    external_id VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_teams_sport_division ON teams(sport_division_id);
CREATE INDEX idx_teams_source ON teams(source_system_id);

-- Junction table linking teams to league divisions
CREATE TABLE team_divisions (
    id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    division_id INTEGER NOT NULL REFERENCES divisions(id) ON DELETE CASCADE,
    season_id INTEGER,  -- For future: track historical membership
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(team_id, division_id)
);

CREATE INDEX idx_team_divisions_team ON team_divisions(team_id);
CREATE INDEX idx_team_divisions_division ON team_divisions(division_id);

-- Track external IDs for team-division relationships
CREATE TABLE team_division_external_ids (
    id SERIAL PRIMARY KEY,
    team_division_id INTEGER NOT NULL REFERENCES team_divisions(id) ON DELETE CASCADE,
    source_system_id INTEGER NOT NULL REFERENCES source_systems(id),
    external_id VARCHAR(255) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(source_system_id, external_id)
);

CREATE INDEX idx_team_division_external_ids_team_division ON team_division_external_ids(team_division_id);
CREATE INDEX idx_team_division_external_ids_source ON team_division_external_ids(source_system_id, external_id);

COMMENT ON TABLE team_division_external_ids IS 'Tracks external identifiers (e.g., APSL team ID) for team-division relationships';
COMMENT ON COLUMN team_division_external_ids.external_id IS 'Source system identifier (e.g., "114808" from APSL)';

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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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

-- Team rosters (junction table - THE ATOMIC UNIT)
-- team_id is always correct (from scraping), player_id may initially be wrong and corrected later
-- source_system_id tracks WHERE we learned about this roster entry (not the player identity)
CREATE TABLE team_division_players (
    id SERIAL PRIMARY KEY,
    team_division_id INTEGER NOT NULL REFERENCES team_divisions(id) ON DELETE CASCADE,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    jersey_number VARCHAR(10),
    is_active BOOLEAN DEFAULT true,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    UNIQUE(team_division_id, player_id)
);

CREATE INDEX idx_team_division_players_team_division ON team_division_players(team_division_id);
CREATE INDEX idx_team_division_players_player ON team_division_players(player_id);
CREATE INDEX idx_team_division_players_active ON team_division_players(team_division_id, is_active) WHERE is_active = true;

-- Track external IDs for roster entries
CREATE TABLE team_division_player_external_ids (
    id SERIAL PRIMARY KEY,
    team_division_player_id INTEGER NOT NULL REFERENCES team_division_players(id) ON DELETE CASCADE,
    source_system_id INTEGER NOT NULL REFERENCES source_systems(id),
    external_id VARCHAR(255) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(source_system_id, external_id)
);

CREATE INDEX idx_team_division_player_external_ids_team_division_player ON team_division_player_external_ids(team_division_player_id);
CREATE INDEX idx_team_division_player_external_ids_source ON team_division_player_external_ids(source_system_id, external_id);

COMMENT ON TABLE team_division_player_external_ids IS 'Tracks external identifiers (e.g., APSL roster entry) for team-player relationships';
COMMENT ON COLUMN team_division_player_external_ids.external_id IS 'Source system roster entry identifier (e.g., "114808-chris-richards" from APSL)';

-- Position assignments for team rosters (what position they play for THIS specific team)
CREATE TABLE team_division_player_positions (
    id SERIAL PRIMARY KEY,
    team_division_player_id INTEGER NOT NULL REFERENCES team_division_players(id) ON DELETE CASCADE,
    position_id INTEGER NOT NULL REFERENCES positions(id),
    is_primary BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(team_division_player_id, position_id)
);

CREATE INDEX idx_team_division_player_positions_team_division_player ON team_division_player_positions(team_division_player_id);
CREATE INDEX idx_team_division_player_positions_position ON team_division_player_positions(position_id);
CREATE INDEX idx_team_division_player_positions_primary ON team_division_player_positions(team_division_player_id, is_primary) WHERE is_primary = true;

COMMENT ON TABLE team_division_player_positions IS 'Position assignment for specific team roster (what position they play for THIS team)';

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

CREATE TABLE team_coaches (
    id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
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
