-- Football Home Database Schema - Consolidated Production Schema-- Football Home Database Schema - Complete Production Schema

-- Version: 5.0 - Complete Multi-Tenant Architecture-- Version: 4.0 - Production ready with Google Places integration

-- Date: 2025-11-03--

---- This schema includes:

-- This schema includes:-- 1. Fully normalized database (4NF compliant)

-- 1. Multi-sport club management with parent-child relationships-- 2. Google Places integration with all fields

-- 2. Multi-tenant permissions (club/league/team context)-- 3. Migration tracking system for future changes

-- 3. Google Places venue integration (Google-only)-- 4. Complete sample data for development

-- 4. Complete subscription and billing system-- 5. Optimized indexes and constraints

-- 5. Normalized 4NF compliant design

-- 6. NO test data - clean slate for real data-- Create database extensions

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create database extensions

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";-- Create migrations tracking table for future changes

CREATE TABLE IF NOT EXISTS schema_migrations (

-- Sports lookup table    id SERIAL PRIMARY KEY,

CREATE TABLE sports (    filename VARCHAR(255) UNIQUE NOT NULL,

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    name VARCHAR(50) UNIQUE NOT NULL,          -- 'soccer', 'basketball', 'hockey', 'boxing'    checksum VARCHAR(64)

    display_name VARCHAR(100) NOT NULL,        -- 'Soccer', 'Basketball', 'Ice Hockey', 'Boxing');

    default_event_duration INTEGER DEFAULT 90, -- Default minutes for this sport

    typical_team_size INTEGER,                 -- 11 for soccer, 5 for basketball, 2 for boxing-- Sports lookup table

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMPCREATE TABLE sports (

);    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name VARCHAR(50) UNIQUE NOT NULL,          -- 'soccer', 'basketball', 'hockey'

-- Permissions lookup table (4NF compliant)    display_name VARCHAR(100) NOT NULL,        -- 'Soccer', 'Basketball', 'Ice Hockey'

CREATE TABLE permissions (    default_event_duration INTEGER DEFAULT 90, -- Default minutes for this sport

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),    typical_team_size INTEGER,                 -- 11 for soccer, 5 for basketball

    name VARCHAR(50) UNIQUE NOT NULL,          -- 'manage_teams', 'manage_users', 'manage_club'    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

    display_name VARCHAR(100) NOT NULL,        -- 'Manage Teams', 'Manage Users', 'Manage Club');

    description TEXT,                          -- 'Create, edit, delete teams and rosters'

    category VARCHAR(50),                      -- 'team', 'user', 'club', 'league', 'billing'-- Permissions lookup table (4NF compliant)

    is_system_permission BOOLEAN DEFAULT true,CREATE TABLE permissions (

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

);    name VARCHAR(50) UNIQUE NOT NULL,          -- 'manage_teams', 'manage_users'

    display_name VARCHAR(100) NOT NULL,        -- 'Manage Teams', 'Manage Users'

-- Roles lookup table    description TEXT,                          -- 'Create, edit, delete teams and rosters'

CREATE TABLE roles (    category VARCHAR(50),                      -- 'team_management', 'user_management'

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),    is_system_permission BOOLEAN DEFAULT true, -- Cannot be deleted

    name VARCHAR(50) UNIQUE NOT NULL,          -- 'coach', 'player', 'admin', 'club_owner', 'club_admin'    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

    display_name VARCHAR(100) NOT NULL,        -- 'Coach', 'Player', 'Administrator', 'Club Owner');

    description TEXT,                          -- Role description

    is_system_role BOOLEAN DEFAULT false,-- Roles lookup table (renamed from user_roles for clarity)

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMPCREATE TABLE roles (

);    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name VARCHAR(20) UNIQUE NOT NULL,          -- 'coach', 'player', 'admin'

-- Role-Permission mapping (many-to-many)    display_name VARCHAR(50) NOT NULL,         -- 'Coach', 'Player', 'Administrator'

CREATE TABLE role_permissions (    description TEXT,                          -- Role description

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),    is_system_role BOOLEAN DEFAULT false,      -- Cannot be deleted

    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,);

    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    granted_by UUID REFERENCES users(id),-- Role permissions junction table (many-to-many, 4NF compliant)

    UNIQUE(role_id, permission_id)-- Note: granted_by reference to users will be added after users table is created

);CREATE TABLE role_permissions (

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

-- Clubs table - supports parent-child hierarchies for organizations    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,

CREATE TABLE clubs (    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    name VARCHAR(200) NOT NULL,    granted_by UUID,                           -- Will add FK constraint after users table

    short_name VARCHAR(50),    UNIQUE(role_id, permission_id)

    slug VARCHAR(100) UNIQUE NOT NULL,         -- for URLs: lighthouse-1893-sc);

    

    -- Organizational hierarchy-- Event types lookup table

    parent_club_id UUID REFERENCES clubs(id), -- NULL for top-level organizationsCREATE TABLE event_types (

        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Location & Contact    sport_id UUID REFERENCES sports(id),       -- Different types per sport

    city VARCHAR(100),    name VARCHAR(50) NOT NULL,                 -- 'training', 'match', 'meeting'

    state VARCHAR(50),    display_name VARCHAR(100) NOT NULL,        -- 'Training Session', 'Match', 'Team Meeting'

    country VARCHAR(100) DEFAULT 'USA',    category VARCHAR(20) NOT NULL,             -- 'practice', 'match', 'other'

    timezone VARCHAR(50) DEFAULT 'UTC',    default_duration INTEGER DEFAULT 90,       -- Default duration for this type

    website VARCHAR(500),    requires_opponent BOOLEAN DEFAULT false,   -- Does this event type need an opponent?

    email VARCHAR(255),    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    phone VARCHAR(20),    UNIQUE(sport_id, name),

        CONSTRAINT valid_category CHECK (category IN ('practice', 'match', 'other'))

    -- Branding);

    logo_url VARCHAR(500),

    primary_color VARCHAR(7),   -- hex color-- RSVP statuses lookup table

    secondary_color VARCHAR(7),CREATE TABLE rsvp_statuses (

    description TEXT,    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

        name VARCHAR(20) UNIQUE NOT NULL,          -- 'yes', 'no', 'maybe'

    -- Settings & Features    display_name VARCHAR(50) NOT NULL,         -- 'Attending', 'Not Attending', 'Maybe'

    settings JSONB DEFAULT '{}',                -- club preferences, feature flags    sort_order INTEGER DEFAULT 0,             -- For display ordering

    subscription_tier VARCHAR(20) DEFAULT 'free', -- free, premium, enterprise    color VARCHAR(7),                         -- Hex color for UI (#27ae60)

        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

    -- Status);

    is_active BOOLEAN DEFAULT true,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,-- Home/Away venue status lookup table

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,CREATE TABLE home_away_statuses (

        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Prevent circular parent references    name VARCHAR(20) UNIQUE NOT NULL,          -- 'home', 'away', 'neutral'

    CONSTRAINT check_not_self_parent CHECK (id != parent_club_id)    display_name VARCHAR(50) NOT NULL,         -- 'Home', 'Away', 'Neutral Venue'

);    description TEXT,                          -- Additional context

    sort_order INTEGER DEFAULT 0,             -- For display ordering

-- Leagues table (optional layer for competitions)    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

CREATE TABLE leagues ();

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name VARCHAR(200) NOT NULL,-- Player positions lookup table (sport-specific)

    short_name VARCHAR(50),CREATE TABLE positions (

    slug VARCHAR(100) UNIQUE NOT NULL,    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

        sport_id UUID NOT NULL REFERENCES sports(id),

    -- League Details    name VARCHAR(50) NOT NULL,                 -- 'goalkeeper', 'striker', 'point_guard'

    sport_id UUID NOT NULL REFERENCES sports(id),    display_name VARCHAR(100) NOT NULL,        -- 'Goalkeeper', 'Striker', 'Point Guard'

    league_type VARCHAR(50) DEFAULT 'recreational', -- recreational, competitive, tournament    abbreviation VARCHAR(5),                   -- 'GK', 'ST', 'PG'

        sort_order INTEGER DEFAULT 0,             -- For display ordering

    -- Season Info    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    season_start DATE,    UNIQUE(sport_id, name)

    season_end DATE,);

    registration_open DATE,

    registration_close DATE,-- Teams table (now references sport)

    CREATE TABLE teams (

    -- Location & Contact    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    city VARCHAR(100),    name VARCHAR(100) NOT NULL,

    state VARCHAR(50),     sport_id UUID NOT NULL REFERENCES sports(id),

    country VARCHAR(100) DEFAULT 'USA',    season VARCHAR(20),

    timezone VARCHAR(50) DEFAULT 'UTC',    description TEXT,

    website VARCHAR(500),    logo_url VARCHAR(500),

    email VARCHAR(255),    primary_color VARCHAR(7),                  -- Hex color

    phone VARCHAR(20),    secondary_color VARCHAR(7),                -- Hex color

        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Branding    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

    logo_url VARCHAR(500),);

    primary_color VARCHAR(7),

    secondary_color VARCHAR(7),-- Users table (no direct role reference - uses junction table)

    description TEXT,CREATE TABLE users (

        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- League Rules & Settings    email VARCHAR(255) UNIQUE NOT NULL,

    settings JSONB DEFAULT '{}',              -- league rules, scoring, divisions    name VARCHAR(100) NOT NULL,

        phone VARCHAR(20),

    -- Status    password_hash VARCHAR(255) NOT NULL,

    is_active BOOLEAN DEFAULT true,    avatar_url VARCHAR(500),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    date_of_birth DATE,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP    emergency_contact VARCHAR(100),

);    emergency_phone VARCHAR(20),

    is_active BOOLEAN DEFAULT true,

-- Junction table for league-club relationships (many-to-many)    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

CREATE TABLE league_clubs (    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),);

    league_id UUID NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,

    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,-- Add foreign key constraint for role_permissions.granted_by now that users table exists

    ALTER TABLE role_permissions ADD CONSTRAINT fk_role_permissions_granted_by 

    -- Membership Details    FOREIGN KEY (granted_by) REFERENCES users(id);

    joined_date DATE DEFAULT CURRENT_DATE,

    status VARCHAR(20) DEFAULT 'active',      -- active, pending, suspended, inactive-- User roles junction table (many-to-many: users can have multiple roles)

    division VARCHAR(50),                     -- if league has divisionsCREATE TABLE user_roles (

        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Fees & Financial    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    membership_fee DECIMAL(10,2),    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,

    fee_paid BOOLEAN DEFAULT false,    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

        assigned_by UUID REFERENCES users(id),      -- Who granted this role

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    is_active BOOLEAN DEFAULT true,             -- Role can be suspended

        expires_at TIMESTAMP,                       -- Optional role expiration

    UNIQUE(league_id, club_id)    notes TEXT,                                 -- Assignment notes

);    UNIQUE(user_id, role_id)                   -- Prevent duplicate role assignments

);

-- Users table

CREATE TABLE users (-- Team memberships (many-to-many: users can be on multiple teams)

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),CREATE TABLE team_members (

    username VARCHAR(30) UNIQUE NOT NULL,    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    email VARCHAR(255) UNIQUE NOT NULL,    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,

    email_verified BOOLEAN DEFAULT false,    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

        position_id UUID REFERENCES positions(id),  -- Player position (nullable for coaches)

    -- Profile    jersey_number INTEGER,

    first_name VARCHAR(100),    is_captain BOOLEAN DEFAULT false,

    last_name VARCHAR(100),    is_active BOOLEAN DEFAULT true,

    date_of_birth DATE,    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    phone VARCHAR(20),    left_at TIMESTAMP,

        UNIQUE(team_id, user_id),

    -- Authentication (passwordless magic links)    UNIQUE(team_id, jersey_number)              -- Jersey numbers unique per team

    is_active BOOLEAN DEFAULT true,);

    last_login TIMESTAMP,

    -- Venues table (with complete Google Places integration)

    -- TimestampsCREATE TABLE venues (

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP    name VARCHAR(255) NOT NULL,

);    short_name VARCHAR(100),                    -- "Training Ground", "Stadium", etc.

    venue_type VARCHAR(50) NOT NULL,            -- 'field', 'stadium', 'gym', 'clubhouse', 'outdoor', 'indoor'

-- Teams table - belongs to clubs, plays specific sports    

CREATE TABLE teams (    -- Location details

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),    address TEXT,

    name VARCHAR(100) NOT NULL,    city VARCHAR(100),

    sport_id UUID NOT NULL REFERENCES sports(id),    state VARCHAR(50),

    club_id UUID NOT NULL REFERENCES clubs(id), -- Teams must belong to a club    postal_code VARCHAR(20),

    season VARCHAR(20),    country VARCHAR(100) DEFAULT 'USA',

    description TEXT,    latitude DECIMAL(10,8),                     -- For GPS coordinates

    logo_url VARCHAR(500),    longitude DECIMAL(11,8),

    primary_color VARCHAR(7),    formatted_address TEXT,                     -- Google formatted address

    secondary_color VARCHAR(7),    

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- Venue specifications

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP    surface_type VARCHAR(50),                   -- 'grass', 'artificial_turf', 'indoor_court', 'hardwood', etc.

);    capacity INTEGER,                           -- Max people/players

    field_dimensions VARCHAR(100),              -- "105x68m", "Full size", etc.

-- Multi-tenant user roles - context aware    

CREATE TABLE user_roles (    -- Facilities and features

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),    facilities TEXT[],                          -- ['changing_rooms', 'parking', 'floodlights', 'covered_seating']

    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,    equipment_available TEXT[],                 -- ['goals', 'cones', 'bibs', 'first_aid']

    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,    

        -- Accessibility and conditions

    -- Multi-tenant context - user can have different roles in different contexts    wheelchair_accessible BOOLEAN DEFAULT false,

    club_id UUID REFERENCES clubs(id),         -- Role within specific club    weather_covered BOOLEAN DEFAULT false,      -- Indoor or covered facility

    league_id UUID REFERENCES leagues(id),     -- Role within specific league      parking_available BOOLEAN DEFAULT true,

    team_id UUID REFERENCES teams(id),         -- Role within specific team    

        -- Contact and booking (Google-aligned field names)

    -- Assignment details    contact_name VARCHAR(100),

    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    phone VARCHAR(20),                          -- Renamed from contact_phone to match Google

    assigned_by UUID REFERENCES users(id),    email VARCHAR(255),                         -- Renamed from contact_email for consistency

    is_active BOOLEAN DEFAULT true,    international_phone_number VARCHAR(30),     -- Google Places field

    expires_at TIMESTAMP,    booking_required BOOLEAN DEFAULT false,

    notes TEXT    hourly_rate DECIMAL(8,2),                   -- Cost per hour if applicable

);    

    -- Usage restrictions

-- Club membership tracking    available_hours VARCHAR(100),               -- "9AM-10PM", "24/7", etc.

CREATE TABLE club_members (    restrictions TEXT,                          -- Age limits, sport restrictions, etc.

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),    

    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,    -- Additional info

    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,    directions TEXT,

        notes TEXT,

    -- Membership details    website VARCHAR(255),

    joined_date DATE DEFAULT CURRENT_DATE,    

    status VARCHAR(20) DEFAULT 'active',       -- active, inactive, suspended, pending    -- Ownership/management

    membership_type VARCHAR(50) DEFAULT 'member', -- member, coach, admin, owner    owned_by_team BOOLEAN DEFAULT false,

        venue_manager VARCHAR(100),

    -- Contact preferences for this club    

    receive_notifications BOOLEAN DEFAULT true,    -- Google Places integration fields

        place_id VARCHAR(255) UNIQUE,               -- Google Places unique identifier

    -- Membership metadata    rating DECIMAL(2,1),                        -- Google Places rating (1.0-5.0)

    invited_by UUID REFERENCES users(id),    user_ratings_total INTEGER DEFAULT 0,       -- Number of Google reviews

    notes TEXT,    price_level INTEGER,                        -- Google price level (0-4)

        business_status VARCHAR(50),                -- Google business status

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    google_types JSONB,                         -- Array of Google Place types

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    opening_hours JSONB,                        -- Google opening hours data

        photos JSONB,                               -- Array of Google photo references

    UNIQUE(club_id, user_id)    data_source VARCHAR(50) DEFAULT 'user_added', -- Source of venue data

);    last_google_update TIMESTAMP,               -- Last sync with Google Places

    

-- Subscription and billing    -- Standard fields

CREATE TABLE subscriptions (    is_active BOOLEAN DEFAULT true,

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

        

    -- Subscription details    -- Constraints

    plan_name VARCHAR(50) NOT NULL,           -- free, premium, enterprise    CONSTRAINT valid_coordinates CHECK (

    status VARCHAR(20) DEFAULT 'active',      -- active, cancelled, past_due        (latitude IS NULL AND longitude IS NULL) OR 

            (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)

    -- Billing    ),

    amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,    CONSTRAINT valid_rating CHECK (rating IS NULL OR (rating >= 1.0 AND rating <= 5.0)),

    currency VARCHAR(3) DEFAULT 'USD',    CONSTRAINT valid_price_level CHECK (price_level IS NULL OR (price_level >= 0 AND price_level <= 4))

    );

    -- Dates

    started_at DATE DEFAULT CURRENT_DATE,-- Base events table (common fields for all event types)

    current_period_end DATE,CREATE TABLE events (

        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP    created_by UUID NOT NULL REFERENCES users(id),

);    event_type_id UUID NOT NULL REFERENCES event_types(id),

    title VARCHAR(200) NOT NULL,

-- Position lookup (sport-specific)    description TEXT,

CREATE TABLE positions (    event_date TIMESTAMP NOT NULL,

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),    venue_id UUID REFERENCES venues(id),

    sport_id UUID NOT NULL REFERENCES sports(id),    duration_minutes INTEGER,                   -- Will default from event_type if null

    name VARCHAR(50) NOT NULL,                -- 'Goalkeeper', 'Forward', 'Guard'    max_players INTEGER,

    abbreviation VARCHAR(10),                 -- 'GK', 'FW', 'G'    cancelled BOOLEAN DEFAULT false,

    description TEXT,    cancellation_reason TEXT,

    sort_order INTEGER DEFAULT 0,    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

    UNIQUE(sport_id, name));

);

-- Practices table (extends events for training/practice sessions)

-- Team membershipCREATE TABLE practices (

CREATE TABLE team_members (    id UUID PRIMARY KEY REFERENCES events(id) ON DELETE CASCADE,

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),    focus_areas TEXT[],                        -- ['passing', 'shooting', 'defense']

    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,    drill_plan TEXT,                           -- Detailed practice plan

    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,    equipment_needed TEXT[],                   -- ['cones', 'balls', 'bibs']

    position_id UUID REFERENCES positions(id),    fitness_focus TEXT,                        -- 'endurance', 'strength', 'agility'

    jersey_number INTEGER,    skill_level VARCHAR(20),                   -- 'beginner', 'intermediate', 'advanced'

    is_captain BOOLEAN DEFAULT false,    weather_dependent BOOLEAN DEFAULT true,     -- Can practice be moved indoors?

    joined_date DATE DEFAULT CURRENT_DATE,    indoor_alternative_location VARCHAR(255),  -- Backup venue

    status VARCHAR(20) DEFAULT 'active',      -- active, inactive, injured    notes TEXT                                 -- Coach notes and observations

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,);

    UNIQUE(team_id, user_id),

    UNIQUE(team_id, jersey_number)-- Matches table (extends events for competitive games)

);CREATE TABLE matches (

    id UUID PRIMARY KEY REFERENCES events(id) ON DELETE CASCADE,

-- Venues table - Google Places ONLY (no user-created venues)    opponent_team_id UUID NOT NULL REFERENCES teams(id),

CREATE TABLE venues (    home_away_status_id UUID NOT NULL REFERENCES home_away_statuses(id),

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),    competition_name VARCHAR(100),             -- 'Premier League', 'Cup Final'

    name VARCHAR(200) NOT NULL,    competition_round VARCHAR(50),             -- 'Quarter Final', 'Group Stage'

        referee_name VARCHAR(100),

    -- Google Places integration    referee_phone VARCHAR(20),

    place_id VARCHAR(100) UNIQUE,             -- Google Places ID    home_team_score INTEGER,                   -- Final score (null if not played)

    data_source VARCHAR(20) DEFAULT 'google' CHECK (data_source = 'google'), -- Only Google allowed    away_team_score INTEGER,

        match_status VARCHAR(20) DEFAULT 'scheduled', -- 'scheduled', 'in_progress', 'completed', 'postponed'

    -- Location    weather_conditions TEXT,                   -- Match day weather

    address TEXT,    attendance INTEGER,                        -- Number of spectators

    city VARCHAR(100),    match_report TEXT,                         -- Post-match report

    state VARCHAR(50),    man_of_match UUID REFERENCES users(id),   -- Player of the match

    country VARCHAR(100),    yellow_cards INTEGER DEFAULT 0,

    postal_code VARCHAR(20),    red_cards INTEGER DEFAULT 0,

    latitude DECIMAL(10, 8),    kick_off_time TIME,                       -- Actual kick-off time

    longitude DECIMAL(11, 8),    full_time_time TIME                       -- When match ended

    );

    -- Contact (from Google Places)

    phone VARCHAR(20),-- RSVPs (now references rsvp_status)

    email VARCHAR(255),CREATE TABLE rsvps (

    website VARCHAR(500),    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

        event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,

    -- Google Places metadata    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    rating DECIMAL(3,2),                      -- Google rating (1.0-5.0)    rsvp_status_id UUID NOT NULL REFERENCES rsvp_statuses(id),

    user_ratings_total INTEGER,               -- Number of Google reviews    response_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    business_status VARCHAR(50),              -- OPERATIONAL, CLOSED_TEMPORARILY, CLOSED_PERMANENTLY    notes TEXT,

    google_types TEXT[],                      -- Google place types array    dietary_requirements TEXT,

        transport_needed BOOLEAN DEFAULT false,

    -- Venue details    UNIQUE(event_id, user_id)

    description TEXT,);

    capacity INTEGER,

    surface_type VARCHAR(50),                 -- grass, artificial_turf, hardwood, etc.-- Magic tokens for RSVP links via email/SMS (unchanged)

    CREATE TABLE magic_tokens (

    -- Status    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    is_active BOOLEAN DEFAULT true,    token VARCHAR(255) UNIQUE NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

);    expires_at TIMESTAMP NOT NULL,

    used_at TIMESTAMP,

-- Event types lookup    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

CREATE TABLE event_types (    UNIQUE(event_id, user_id)

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),);

    sport_id UUID REFERENCES sports(id),

    name VARCHAR(50) UNIQUE NOT NULL,         -- 'practice', 'match', 'tournament'-- Indexes for performance

    display_name VARCHAR(100) NOT NULL,       -- 'Practice', 'Match', 'Tournament'CREATE INDEX idx_events_team_date ON events(team_id, event_date);

    category VARCHAR(50),                     -- 'training', 'competition', 'social'CREATE INDEX idx_events_type ON events(event_type_id);

    default_duration INTEGER DEFAULT 90,     -- minutesCREATE INDEX idx_practices_focus ON practices(focus_areas);

    requires_venue BOOLEAN DEFAULT true,CREATE INDEX idx_matches_opponent ON matches(opponent_team_id);

    requires_rsvp BOOLEAN DEFAULT true,CREATE INDEX idx_matches_competition ON matches(competition_name);

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMPCREATE INDEX idx_matches_status ON matches(match_status);

);CREATE INDEX idx_matches_home_away ON matches(home_away_status_id);

CREATE INDEX idx_rsvps_event ON rsvps(event_id);

-- Events table (practices, matches, etc.)CREATE INDEX idx_rsvps_status ON rsvps(rsvp_status_id);

CREATE TABLE events (CREATE INDEX idx_team_members_team ON team_members(team_id);

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),CREATE INDEX idx_team_members_user ON team_members(user_id);

    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,CREATE INDEX idx_team_members_position ON team_members(position_id);

    event_type_id UUID NOT NULL REFERENCES event_types(id),CREATE INDEX idx_user_roles_user ON user_roles(user_id);

    venue_id UUID REFERENCES venues(id),      -- Can be NULL for TBD locationsCREATE INDEX idx_user_roles_role ON user_roles(role_id);

    CREATE INDEX idx_user_roles_active ON user_roles(user_id, is_active);

    -- Event detailsCREATE INDEX idx_role_permissions_role ON role_permissions(role_id);

    title VARCHAR(200) NOT NULL,CREATE INDEX idx_role_permissions_permission ON role_permissions(permission_id);

    description TEXT,CREATE INDEX idx_teams_sport ON teams(sport_id);

    event_date DATE NOT NULL,CREATE INDEX idx_positions_sport ON positions(sport_id);

    start_time TIME,CREATE INDEX idx_event_types_sport ON event_types(sport_id);

    end_time TIME,CREATE INDEX idx_event_types_category ON event_types(category);

    duration_minutes INTEGER,CREATE INDEX idx_permissions_category ON permissions(category);

    CREATE INDEX idx_magic_tokens_token ON magic_tokens(token);

    -- Status and metadataCREATE INDEX idx_magic_tokens_expires ON magic_tokens(expires_at);

    status VARCHAR(20) DEFAULT 'scheduled',   -- scheduled, cancelled, completed

    is_home_game BOOLEAN,-- Google Places indexes

    created_by UUID REFERENCES users(id),CREATE INDEX idx_venues_place_id ON venues(place_id) WHERE place_id IS NOT NULL;

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,CREATE INDEX idx_venues_rating ON venues(rating) WHERE rating IS NOT NULL;

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMPCREATE INDEX idx_venues_data_source ON venues(data_source);

);CREATE INDEX idx_venues_business_status ON venues(business_status);

CREATE INDEX idx_venues_phone ON venues(phone) WHERE phone IS NOT NULL;

-- RSVP Status lookup

CREATE TABLE rsvp_statuses (-- Insert lookup data

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name VARCHAR(20) UNIQUE NOT NULL,         -- 'yes', 'no', 'maybe'-- Sports

    display_name VARCHAR(50) NOT NULL,        -- 'Yes', 'No', 'Maybe'INSERT INTO sports (id, name, display_name, default_event_duration, typical_team_size) VALUES 

    sort_order INTEGER DEFAULT 0,('550e8400-e29b-41d4-a716-446655440101', 'soccer', 'Soccer (Football)', 90, 11),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP('550e8400-e29b-41d4-a716-446655440102', 'basketball', 'Basketball', 60, 5),

);('550e8400-e29b-41d4-a716-446655440103', 'hockey', 'Ice Hockey', 60, 6),

('550e8400-e29b-41d4-a716-446655440104', 'baseball', 'Baseball', 180, 9),

-- RSVP responses('550e8400-e29b-41d4-a716-446655440105', 'volleyball', 'Volleyball', 90, 6);

CREATE TABLE rsvps (

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),-- Permissions (4NF compliant)

    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,INSERT INTO permissions (id, name, display_name, description, category, is_system_permission) VALUES 

    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,('550e8400-e29b-41d4-a716-446655440601', 'manage_teams', 'Manage Teams', 'Create, edit, delete teams and rosters', 'team_management', true),

    rsvp_status_id UUID NOT NULL REFERENCES rsvp_statuses(id),('550e8400-e29b-41d4-a716-446655440602', 'manage_users', 'Manage Users', 'Create, edit, delete user accounts', 'user_management', true),

    notes TEXT,('550e8400-e29b-41d4-a716-446655440603', 'manage_events', 'Manage Events', 'Create, edit, delete events and practices', 'event_management', true),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,('550e8400-e29b-41d4-a716-446655440604', 'send_notifications', 'Send Notifications', 'Send email/SMS notifications to team members', 'communication', true),

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,('550e8400-e29b-41d4-a716-446655440605', 'manage_roles', 'Manage Roles', 'Assign and revoke user roles and permissions', 'user_management', true),

    UNIQUE(event_id, user_id)('550e8400-e29b-41d4-a716-446655440606', 'view_team', 'View Team', 'View team roster and member details', 'team_access', true),

);('550e8400-e29b-41d4-a716-446655440607', 'manage_roster', 'Manage Roster', 'Add/remove players from team roster', 'team_management', true),

('550e8400-e29b-41d4-a716-446655440608', 'view_events', 'View Events', 'View team events and schedules', 'event_access', true),

-- Home/Away status lookup('550e8400-e29b-41d4-a716-446655440609', 'rsvp_events', 'RSVP to Events', 'Respond to event invitations', 'event_access', true),

CREATE TABLE home_away_statuses (('550e8400-e29b-41d4-a716-446655440610', 'view_profile', 'View Profile', 'View own profile and basic information', 'user_access', true);

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name VARCHAR(20) UNIQUE NOT NULL,         -- 'home', 'away', 'neutral'-- Roles (without permissions array)

    display_name VARCHAR(50) NOT NULL,        -- 'Home', 'Away', 'Neutral Site'INSERT INTO roles (id, name, display_name, description, is_system_role) VALUES 

    sort_order INTEGER DEFAULT 0,('550e8400-e29b-41d4-a716-446655440201', 'admin', 'Administrator', 'System administrator with full access', true),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP('550e8400-e29b-41d4-a716-446655440202', 'coach', 'Coach', 'Team coach with management capabilities', true),

);('550e8400-e29b-41d4-a716-446655440203', 'player', 'Player', 'Team player with basic access', true),

('550e8400-e29b-41d4-a716-446655440204', 'assistant_coach', 'Assistant Coach', 'Assistant coach with limited management', false),

-- Matches (extends events)('550e8400-e29b-41d4-a716-446655440205', 'parent', 'Parent/Guardian', 'Parent or guardian of a player', false);

CREATE TABLE matches (

    id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE PRIMARY KEY,-- Role permissions assignments (many-to-many junction)

    opponent_team_id UUID REFERENCES teams(id),INSERT INTO role_permissions (role_id, permission_id) VALUES

    opponent_name VARCHAR(200),               -- For external opponents not in system-- Admin gets all permissions

    home_away_status_id UUID REFERENCES home_away_statuses(id),('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440601'), -- manage_teams

    ('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440602'), -- manage_users

    -- Match details('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440603'), -- manage_events

    competition_name VARCHAR(200),            -- League name, tournament, etc.('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440604'), -- send_notifications

    match_type VARCHAR(50),                   -- regular, playoff, friendly, etc.('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440605'), -- manage_roles

    ('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440606'), -- view_team

    -- Scoring('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440607'), -- manage_roster

    our_score INTEGER,('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440608'), -- view_events

    opponent_score INTEGER,('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440609'), -- rsvp_events

    match_status VARCHAR(20) DEFAULT 'scheduled', -- scheduled, in_progress, completed, cancelled('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440610'), -- view_profile

    -- Coach permissions

    -- Match metadata('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440603'), -- manage_events

    man_of_match UUID REFERENCES users(id),('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440604'), -- send_notifications

    match_report TEXT,('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440606'), -- view_team

    ('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440607'), -- manage_roster

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440608'), -- view_events

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440610'), -- view_profile

);-- Player permissions

('550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440608'), -- view_events

-- Practices (extends events)('550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440609'), -- rsvp_events

CREATE TABLE practices (('550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440610'), -- view_profile

    id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE PRIMARY KEY,-- Assistant coach permissions

    focus_areas TEXT[],                       -- ['passing', 'shooting', 'fitness']('550e8400-e29b-41d4-a716-446655440204', '550e8400-e29b-41d4-a716-446655440606'), -- view_team

    intensity_level VARCHAR(20),              -- low, medium, high('550e8400-e29b-41d4-a716-446655440204', '550e8400-e29b-41d4-a716-446655440604'), -- send_notifications

    equipment_needed TEXT,('550e8400-e29b-41d4-a716-446655440204', '550e8400-e29b-41d4-a716-446655440608'), -- view_events

    notes TEXT,('550e8400-e29b-41d4-a716-446655440204', '550e8400-e29b-41d4-a716-446655440610'), -- view_profile

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP-- Parent permissions

);('550e8400-e29b-41d4-a716-446655440205', '550e8400-e29b-41d4-a716-446655440608'), -- view_events

('550e8400-e29b-41d4-a716-446655440205', '550e8400-e29b-41d4-a716-446655440610'); -- view_profile

-- User sessions for authentication

CREATE TABLE user_sessions (-- RSVP statuses

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),INSERT INTO rsvp_statuses (id, name, display_name, sort_order, color) VALUES 

    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,('550e8400-e29b-41d4-a716-446655440301', 'yes', 'Attending', 1, '#27ae60'),

    session_token VARCHAR(255) UNIQUE NOT NULL,('550e8400-e29b-41d4-a716-446655440302', 'maybe', 'Maybe', 2, '#f39c12'),

    refresh_token VARCHAR(255) UNIQUE,('550e8400-e29b-41d4-a716-446655440303', 'no', 'Not Attending', 3, '#e74c3c');

    expires_at TIMESTAMP NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,-- Home/Away venue statuses

    last_accessed TIMESTAMP DEFAULT CURRENT_TIMESTAMPINSERT INTO home_away_statuses (id, name, display_name, description, sort_order) VALUES 

);('550e8400-e29b-41d4-a716-446655440801', 'home', 'Home', 'Event at our home venue', 1),

('550e8400-e29b-41d4-a716-446655440802', 'away', 'Away', 'Event at opponent or external venue', 2),

-- Magic tokens for passwordless auth('550e8400-e29b-41d4-a716-446655440803', 'neutral', 'Neutral Venue', 'Event at a neutral/shared venue', 3);

CREATE TABLE magic_tokens (

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),-- Event types for soccer

    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,INSERT INTO event_types (id, sport_id, name, display_name, category, default_duration, requires_opponent) VALUES 

    event_id UUID REFERENCES events(id) ON DELETE CASCADE, -- Optional: token for specific event('550e8400-e29b-41d4-a716-446655440401', '550e8400-e29b-41d4-a716-446655440101', 'training', 'Training Session', 'practice', 90, false),

    token VARCHAR(255) UNIQUE NOT NULL,('550e8400-e29b-41d4-a716-446655440402', '550e8400-e29b-41d4-a716-446655440101', 'match', 'Match', 'match', 120, true),

    token_type VARCHAR(50) DEFAULT 'login',   -- login, rsvp, invite('550e8400-e29b-41d4-a716-446655440403', '550e8400-e29b-41d4-a716-446655440101', 'meeting', 'Team Meeting', 'other', 60, false),

    expires_at TIMESTAMP NOT NULL,('550e8400-e29b-41d4-a716-446655440404', '550e8400-e29b-41d4-a716-446655440101', 'scrimmage', 'Scrimmage', 'practice', 90, false),

    used_at TIMESTAMP,('550e8400-e29b-41d4-a716-446655440405', '550e8400-e29b-41d4-a716-446655440101', 'friendly', 'Friendly Match', 'match', 90, true),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP('550e8400-e29b-41d4-a716-446655440406', '550e8400-e29b-41d4-a716-446655440101', 'fitness', 'Fitness Training', 'practice', 60, false);

);

-- Soccer positions

-- Notification typesINSERT INTO positions (id, sport_id, name, display_name, abbreviation, sort_order) VALUES 

CREATE TABLE notification_types (('550e8400-e29b-41d4-a716-446655440501', '550e8400-e29b-41d4-a716-446655440101', 'goalkeeper', 'Goalkeeper', 'GK', 1),

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),('550e8400-e29b-41d4-a716-446655440502', '550e8400-e29b-41d4-a716-446655440101', 'defender', 'Defender', 'DEF', 2),

    name VARCHAR(50) UNIQUE NOT NULL,         -- 'event_reminder', 'team_invite'('550e8400-e29b-41d4-a716-446655440503', '550e8400-e29b-41d4-a716-446655440101', 'midfielder', 'Midfielder', 'MID', 3),

    display_name VARCHAR(100) NOT NULL,       -- 'Event Reminder', 'Team Invitation'('550e8400-e29b-41d4-a716-446655440504', '550e8400-e29b-41d4-a716-446655440101', 'forward', 'Forward', 'FWD', 4);

    category VARCHAR(50),                     -- 'event', 'team', 'system'

    default_enabled BOOLEAN DEFAULT true,-- Sample teams

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMPINSERT INTO teams (id, name, sport_id, season, primary_color, secondary_color) VALUES 

);('550e8400-e29b-41d4-a716-446655440001', 'Thunder FC Demo', '550e8400-e29b-41d4-a716-446655440101', '2025/26 Season', '#e74c3c', '#ffffff'),

('550e8400-e29b-41d4-a716-446655440002', 'Lightning United', '550e8400-e29b-41d4-a716-446655440101', '2025/26 Season', '#3498db', '#ffffff');

-- User notification preferences

CREATE TABLE user_notification_preferences (-- Sample users (no direct role references)

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),INSERT INTO users (id, email, name, phone, password_hash) VALUES 

    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,('550e8400-e29b-41d4-a716-446655440100', 'coach@thunderfc.com', 'Coach Sarah Martinez', '+1-555-1893', '$2b$12$sample_hash_here'),

    notification_type_id UUID NOT NULL REFERENCES notification_types(id) ON DELETE CASCADE,('550e8400-e29b-41d4-a716-446655440101', 'player@thunderfc.com', 'Alex Johnson', '+1-555-2001', '$2b$12$sample_hash_here'),

    enabled BOOLEAN DEFAULT true,('550e8400-e29b-41d4-a716-446655440102', 'keeper@thunderfc.com', 'Maria Rodriguez', '+1-555-2002', '$2b$12$sample_hash_here'),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,('550e8400-e29b-41d4-a716-446655440103', 'defender@thunderfc.com', 'Emma Thompson', '+1-555-2003', '$2b$12$sample_hash_here'),

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,('550e8400-e29b-41d4-a716-446655440104', 'striker@thunderfc.com', 'David Kim', '+1-555-2004', '$2b$12$sample_hash_here'),

    UNIQUE(user_id, notification_type_id)('550e8400-e29b-41d4-a716-446655440105', 'demo@footballhome.org', 'Demo User', '+1-555-2005', '$2b$12$sample_hash_here'),

);('550e8400-e29b-41d4-a716-446655440106', 'admin@thunderfc.com', 'Admin Alice Cooper', '+1-555-1000', '$2b$12$sample_hash_here');



-- Notification log-- User role assignments (many-to-many junction table)

CREATE TABLE notification_log (INSERT INTO user_roles (user_id, role_id, assigned_by, notes) VALUES

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),-- Admin user has admin role

    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,('550e8400-e29b-41d4-a716-446655440106', '550e8400-e29b-41d4-a716-446655440201', NULL, 'System administrator'),

    event_id UUID REFERENCES events(id) ON DELETE SET NULL,-- Coach has coach role

    notification_type_id UUID NOT NULL REFERENCES notification_types(id),('550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440106', 'Head coach of Thunder FC'),

    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,-- Players have player role

    delivery_method VARCHAR(20),              -- email, sms, push('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440100', 'Team captain and midfielder'),

    status VARCHAR(20) DEFAULT 'sent',        -- sent, delivered, failed('550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440100', 'Team goalkeeper'),

    message_content TEXT('550e8400-e29b-41d4-a716-446655440103', '550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440100', 'Team defender'),

);('550e8400-e29b-41d4-a716-446655440104', '550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440100', 'Team striker'),

('550e8400-e29b-41d4-a716-446655440105', '550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440100', 'Demo player account'),

-- Recurrence patterns for recurring events-- Example: Alex Johnson (captain) also has assistant coach role for youth team

CREATE TABLE recurrence_patterns (('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440204', '550e8400-e29b-41d4-a716-446655440100', 'Assists with youth development');

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name VARCHAR(50) UNIQUE NOT NULL,         -- 'weekly', 'biweekly', 'monthly'-- Team memberships with positions

    display_name VARCHAR(100) NOT NULL,       -- 'Weekly', 'Every Two Weeks', 'Monthly'INSERT INTO team_members (team_id, user_id, position_id, jersey_number, is_captain) VALUES

    description TEXT,('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440100', NULL, NULL, false), -- Coach (no position/jersey)

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440503', 10, true),  -- Alex - Midfielder, Captain

);('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440501', 1, false),  -- Maria - Goalkeeper

('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440103', '550e8400-e29b-41d4-a716-446655440502', 4, false),  -- Emma - Defender

-- Event recurrences('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440104', '550e8400-e29b-41d4-a716-446655440504', 9, false),  -- David - Forward

CREATE TABLE event_recurrences (('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440105', '550e8400-e29b-41d4-a716-446655440504', 11, false); -- Demo - Forward

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    parent_event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,-- Sample venues (with Google Places field structure)

    recurrence_pattern_id UUID NOT NULL REFERENCES recurrence_patterns(id),INSERT INTO venues (id, name, short_name, venue_type, address, city, surface_type, capacity, 

    start_date DATE NOT NULL,                   facilities, equipment_available, owned_by_team, directions, notes, phone, email) VALUES

    end_date DATE,                            -- NULL for indefinite

    max_occurrences INTEGER,                  -- Alternative to end_date-- Thunder FC venues (team-owned)

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP('550e8400-e29b-41d4-a716-446655440801', 

); 'Thunder FC Training Ground', 'Training Ground', 'field',

 '123 Soccer Way', 'Thunderville', 'grass', 30,

-- Individual instances of recurring events ARRAY['changing_rooms', 'equipment_storage', 'parking', 'water_fountain'],

CREATE TABLE recurring_event_instances ( ARRAY['goals', 'cones', 'bibs', 'balls', 'first_aid'],

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), true, 

    event_recurrence_id UUID NOT NULL REFERENCES event_recurrences(id) ON DELETE CASCADE, 'Enter through main gate, training fields are behind the clubhouse',

    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE, 'Primary training facility with 2 full-size grass fields',

    occurrence_date DATE NOT NULL, '+1-555-0123', 'training@thunderfc.com'),

    is_modified BOOLEAN DEFAULT false,        -- True if this instance was customized

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP('550e8400-e29b-41d4-a716-446655440802',

); 'Thunder FC Stadium', 'Stadium', 'stadium', 

 '456 Championship Blvd', 'Thunderville', 'grass', 500,

-- League member tracking (for users directly in leagues) ARRAY['changing_rooms', 'covered_seating', 'scoreboard', 'floodlights', 'parking', 'concessions'],

CREATE TABLE league_members ( ARRAY['goals', 'corner_flags', 'nets', 'first_aid', 'PA_system'],

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), true,

    league_id UUID NOT NULL REFERENCES leagues(id) ON DELETE CASCADE, 'Main entrance on Championship Blvd, player entrance on the east side',

    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, 'Home stadium for matches and major events',

     '+1-555-0124', 'stadium@thunderfc.com'),

    -- Membership details

    joined_date DATE DEFAULT CURRENT_DATE,('550e8400-e29b-41d4-a716-446655440803',

    status VARCHAR(20) DEFAULT 'active', 'Thunder FC Clubhouse', 'Clubhouse', 'clubhouse',

    role VARCHAR(50) DEFAULT 'member', '123 Soccer Way', 'Thunderville', NULL, 50,

     ARRAY['meeting_room', 'kitchen', 'parking', 'wifi', 'projector'],

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, ARRAY['tables', 'chairs', 'whiteboard', 'projector_screen'],

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, true,

     'Located at the training ground complex, main building',

    UNIQUE(league_id, user_id) 'Meeting space, strategy sessions, team meals',

); '+1-555-0123', 'clubhouse@thunderfc.com');



-- Club usage tracking (for billing/analytics)-- Sample events (base table) - using only venues that exist

CREATE TABLE club_usage (INSERT INTO events (id, team_id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, max_players) VALUES

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),('550e8400-e29b-41d4-a716-446655440701', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440401', 'Weekly Training Session', 'Regular training focusing on passing and shooting', '2025-10-30 18:00:00', '550e8400-e29b-41d4-a716-446655440801', 90, 16),

    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,('550e8400-e29b-41d4-a716-446655440702', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440402', 'Match vs Lightning United', 'League match against Lightning United', '2025-11-02 15:00:00', '550e8400-e29b-41d4-a716-446655440802', 120, 18),

    ('550e8400-e29b-41d4-a716-446655440703', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440403', 'Team Strategy Meeting', 'Discussing tactics for upcoming matches', '2025-10-29 19:00:00', '550e8400-e29b-41d4-a716-446655440803', 60, NULL);

    -- Usage period

    period_start DATE NOT NULL,-- Sample practices (extends specific events)

    period_end DATE NOT NULL,INSERT INTO practices (id, focus_areas, drill_plan, equipment_needed, fitness_focus, skill_level, weather_dependent, indoor_alternative_location, notes) VALUES

    ('550e8400-e29b-41d4-a716-446655440701', 

    -- Usage metrics ARRAY['passing', 'shooting', 'ball_control'], 

    active_users INTEGER DEFAULT 0, 'Warm-up (10min) → Passing drills (30min) → Shooting practice (30min) → Small-sided games (20min)',

    events_created INTEGER DEFAULT 0, ARRAY['cones', 'balls', 'training_bibs', 'goals'],

    teams_count INTEGER DEFAULT 0, 'moderate',

    storage_used_mb INTEGER DEFAULT 0, 'intermediate',

     true,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 'Thunder FC Indoor Hall',

); 'Focus on short passing accuracy and first touch'

);

-- Performance Indexes

CREATE INDEX idx_clubs_slug ON clubs(slug);-- Sample matches (extends specific events)

CREATE INDEX idx_clubs_parent ON clubs(parent_club_id) WHERE parent_club_id IS NOT NULL;INSERT INTO matches (id, opponent_team_id, home_away_status_id, competition_name, competition_round, referee_name, match_status, kick_off_time) VALUES

CREATE INDEX idx_clubs_location ON clubs(country, state, city);('550e8400-e29b-41d4-a716-446655440702', 

CREATE INDEX idx_clubs_subscription ON clubs(subscription_tier); '550e8400-e29b-41d4-a716-446655440002', 

 '550e8400-e29b-41d4-a716-446655440801', 

CREATE INDEX idx_leagues_slug ON leagues(slug); 'Local Premier League', 

CREATE INDEX idx_leagues_sport ON leagues(sport_id); 'Round 8', 

CREATE INDEX idx_leagues_season ON leagues(season_start, season_end); 'John Smith', 

 'scheduled',

CREATE INDEX idx_league_clubs_league ON league_clubs(league_id); '15:00'

CREATE INDEX idx_league_clubs_club ON league_clubs(club_id););

CREATE INDEX idx_league_clubs_status ON league_clubs(status);

-- =============================================================================

CREATE INDEX idx_teams_club ON teams(club_id);-- ADDITIONAL NORMALIZED TABLES FOR COMPLETE SYSTEM

CREATE INDEX idx_teams_sport ON teams(sport_id);-- =============================================================================



CREATE INDEX idx_user_roles_user ON user_roles(user_id);-- Notification types lookup table (for granular notification control)

CREATE INDEX idx_user_roles_role ON user_roles(role_id);CREATE TABLE notification_types (

CREATE INDEX idx_user_roles_active ON user_roles(user_id, is_active);    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

CREATE INDEX idx_user_roles_club ON user_roles(club_id) WHERE club_id IS NOT NULL;    name VARCHAR(50) UNIQUE NOT NULL,          -- 'event_created', 'event_cancelled', 'rsvp_reminder'

CREATE INDEX idx_user_roles_league ON user_roles(league_id) WHERE league_id IS NOT NULL;    display_name VARCHAR(100) NOT NULL,        -- 'Event Created', 'Event Cancelled', 'RSVP Reminder'

CREATE INDEX idx_user_roles_team ON user_roles(team_id) WHERE team_id IS NOT NULL;    description TEXT,                          -- 'Notification when new events are created'

    category VARCHAR(50),                      -- 'event_management', 'rsvp_system', 'team_updates'

CREATE INDEX idx_club_members_club ON club_members(club_id);    default_enabled BOOLEAN DEFAULT true,      -- Default setting for new users

CREATE INDEX idx_club_members_user ON club_members(user_id);    is_system_notification BOOLEAN DEFAULT true, -- Cannot be disabled

CREATE INDEX idx_club_members_status ON club_members(status);    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE INDEX idx_subscriptions_club ON subscriptions(club_id);

CREATE INDEX idx_subscriptions_status ON subscriptions(status);-- User notification preferences (many-to-many with notification types)

CREATE TABLE user_notification_preferences (

CREATE INDEX idx_venues_place_id ON venues(place_id) WHERE place_id IS NOT NULL;    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

CREATE INDEX idx_venues_data_source ON venues(data_source);    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

CREATE INDEX idx_venues_rating ON venues(rating) WHERE rating IS NOT NULL;    notification_type_id UUID NOT NULL REFERENCES notification_types(id) ON DELETE CASCADE,

CREATE INDEX idx_venues_business_status ON venues(business_status);    email_enabled BOOLEAN DEFAULT true,        -- Send via email

CREATE INDEX idx_venues_phone ON venues(phone) WHERE phone IS NOT NULL;    sms_enabled BOOLEAN DEFAULT false,         -- Send via SMS  

    push_enabled BOOLEAN DEFAULT true,         -- Send push notifications

CREATE INDEX idx_events_team_date ON events(team_id, event_date);    advance_hours INTEGER DEFAULT 24,         -- Hours in advance to send (for reminders)

CREATE INDEX idx_events_type ON events(event_type_id);    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

CREATE INDEX idx_team_members_team ON team_members(team_id);    UNIQUE(user_id, notification_type_id)

CREATE INDEX idx_team_members_user ON team_members(user_id););

CREATE INDEX idx_team_members_position ON team_members(position_id);

-- Recurring pattern types lookup

CREATE INDEX idx_positions_sport ON positions(sport_id);CREATE TABLE recurrence_patterns (

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

CREATE INDEX idx_rsvps_event ON rsvps(event_id);    name VARCHAR(30) UNIQUE NOT NULL,          -- 'weekly', 'biweekly', 'monthly'

CREATE INDEX idx_rsvps_status ON rsvps(rsvp_status_id);    display_name VARCHAR(50) NOT NULL,         -- 'Weekly', 'Every 2 Weeks', 'Monthly'

    description TEXT,                          -- 'Repeats every week on the same day'

CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

CREATE INDEX idx_role_permissions_permission ON role_permissions(permission_id););



CREATE INDEX idx_matches_opponent ON matches(opponent_team_id);-- Event recurrence (for recurring training sessions, etc.)

CREATE INDEX idx_matches_home_away ON matches(home_away_status_id);CREATE TABLE event_recurrences (

CREATE INDEX idx_matches_status ON matches(match_status);    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

CREATE INDEX idx_matches_competition ON matches(competition_name);    parent_event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE, -- Template event

    recurrence_pattern_id UUID NOT NULL REFERENCES recurrence_patterns(id),

CREATE INDEX idx_practices_focus ON practices(focus_areas);    start_date DATE NOT NULL,                  -- When recurrence begins

    end_date DATE,                            -- When recurrence ends (NULL = indefinite)

CREATE INDEX idx_user_sessions_user ON user_sessions(user_id);    interval_count INTEGER DEFAULT 1,         -- Every N weeks/months

CREATE INDEX idx_user_sessions_token ON user_sessions(session_token);    days_of_week INTEGER[],                   -- For weekly: [1,3,5] = Mon,Wed,Fri

CREATE INDEX idx_user_sessions_expires ON user_sessions(expires_at);    week_of_month INTEGER,                    -- For monthly: 1st week, 2nd week, etc.

    max_occurrences INTEGER,                  -- Alternative to end_date

CREATE INDEX idx_magic_tokens_token ON magic_tokens(token);    is_active BOOLEAN DEFAULT true,

CREATE INDEX idx_magic_tokens_expires ON magic_tokens(expires_at);    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

CREATE INDEX idx_notification_prefs_user ON user_notification_preferences(user_id);    

CREATE INDEX idx_notification_prefs_type ON user_notification_preferences(notification_type_id);    -- Ensure either end_date or max_occurrences is specified, but not both

    CONSTRAINT recurrence_end_constraint CHECK (

CREATE INDEX idx_notification_log_user ON notification_log(user_id);        (end_date IS NOT NULL AND max_occurrences IS NULL) OR

CREATE INDEX idx_notification_log_event ON notification_log(event_id);        (end_date IS NULL AND max_occurrences IS NOT NULL) OR

CREATE INDEX idx_notification_log_sent_at ON notification_log(sent_at);        (end_date IS NOT NULL AND max_occurrences IS NOT NULL)

    )

CREATE INDEX idx_notification_types_category ON notification_types(category););



CREATE INDEX idx_event_types_sport ON event_types(sport_id);-- Generated events from recurring patterns

CREATE INDEX idx_event_types_category ON event_types(category);CREATE TABLE recurring_event_instances (

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

CREATE INDEX idx_event_recurrences_parent ON event_recurrences(parent_event_id);    event_recurrence_id UUID NOT NULL REFERENCES event_recurrences(id) ON DELETE CASCADE,

CREATE INDEX idx_event_recurrences_pattern ON event_recurrences(recurrence_pattern_id);    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,

    occurrence_date DATE NOT NULL,             -- Which occurrence this represents

CREATE INDEX idx_recurring_instances_recurrence ON recurring_event_instances(event_recurrence_id);    is_exception BOOLEAN DEFAULT false,       -- Was this instance modified from template?

CREATE INDEX idx_recurring_instances_event ON recurring_event_instances(event_id);    exception_reason TEXT,                    -- Why this instance was modified

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

CREATE INDEX idx_recurrence_patterns_name ON recurrence_patterns(name);    UNIQUE(event_recurrence_id, occurrence_date)

);

CREATE INDEX idx_league_members_league ON league_members(league_id);

CREATE INDEX idx_league_members_user ON league_members(user_id);-- Notification log (audit trail of sent notifications)

CREATE TABLE notification_log (

CREATE INDEX idx_club_usage_club ON club_usage(club_id);    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

CREATE INDEX idx_club_usage_period ON club_usage(period_start, period_end);    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    notification_type_id UUID NOT NULL REFERENCES notification_types(id),

-- Insert base sports (including boxing for multi-sport support)    event_id UUID REFERENCES events(id) ON DELETE SET NULL, -- Related event (if applicable)

INSERT INTO sports (id, name, display_name, default_event_duration, typical_team_size) VALUES    delivery_method VARCHAR(20) NOT NULL,      -- 'email', 'sms', 'push'

    ('550e8400-e29b-41d4-a716-446655440101', 'soccer', 'Soccer (Football)', 90, 11),    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    ('550e8400-e29b-41d4-a716-446655440102', 'basketball', 'Basketball', 60, 5),    status VARCHAR(20) DEFAULT 'sent',         -- 'sent', 'failed', 'delivered', 'read'

    ('550e8400-e29b-41d4-a716-446655440103', 'hockey', 'Ice Hockey', 60, 6),    message_content TEXT,                      -- The actual message sent

    ('550e8400-e29b-41d4-a716-446655440104', 'baseball', 'Baseball', 180, 9),    recipient_address VARCHAR(255),            -- Email/phone where sent

    ('550e8400-e29b-41d4-a716-446655440105', 'volleyball', 'Volleyball', 90, 6),    error_message TEXT,                       -- If delivery failed

    ('550e8400-e29b-41d4-a716-446655440106', 'boxing', 'Boxing', 60, 2);    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    

-- Insert base roles    CONSTRAINT valid_delivery_method CHECK (delivery_method IN ('email', 'sms', 'push')),

INSERT INTO roles (name, display_name, description, is_system_role) VALUES    CONSTRAINT valid_status CHECK (status IN ('sent', 'failed', 'delivered', 'read', 'bounced'))

    ('admin', 'Administrator', 'System administrator with full access', true),);

    ('coach', 'Coach', 'Team coach with team management rights', true),

    ('player', 'Player', 'Team player with basic access', true),-- Session management (for better security)

    ('parent', 'Parent', 'Parent/guardian with limited access to child info', true),CREATE TABLE user_sessions (

    ('club_owner', 'Club Owner', 'Club owner with full club management rights', true),    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    ('club_admin', 'Club Admin', 'Club administrator with most club management rights', true),    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    ('league_admin', 'League Admin', 'League administrator with league management rights', true),    session_token VARCHAR(255) UNIQUE NOT NULL,

    ('league_commissioner', 'League Commissioner', 'League commissioner with full league authority', true);    refresh_token VARCHAR(255) UNIQUE,

    ip_address INET,                          -- Client IP address

-- Insert base permissions    user_agent TEXT,                          -- Browser/app info

INSERT INTO permissions (name, display_name, description, category) VALUES    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    ('manage_teams', 'Manage Teams', 'Create, edit, delete teams and rosters', 'team'),    last_accessed TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    ('manage_users', 'Manage Users', 'Manage user accounts and profiles', 'user'),    expires_at TIMESTAMP NOT NULL,

    ('manage_events', 'Manage Events', 'Create and manage team events', 'event'),    is_active BOOLEAN DEFAULT true

    ('view_reports', 'View Reports', 'Access reports and analytics', 'reporting'),);

    ('manage_club', 'Manage Club', 'Manage club settings and members', 'club'),

    ('view_club', 'View Club', 'View club information', 'club'),-- Additional indexes for new tables

    ('manage_league', 'Manage League', 'Manage league settings and members', 'league'),CREATE INDEX idx_notification_prefs_user ON user_notification_preferences(user_id);

    ('view_league', 'View League', 'View league information', 'league'),CREATE INDEX idx_notification_prefs_type ON user_notification_preferences(notification_type_id);

    ('join_league', 'Join League', 'Join leagues with club', 'league'),CREATE INDEX idx_event_recurrences_parent ON event_recurrences(parent_event_id);

    ('create_teams', 'Create Teams', 'Create teams within club', 'team'),CREATE INDEX idx_event_recurrences_pattern ON event_recurrences(recurrence_pattern_id);

    ('manage_club_billing', 'Manage Billing', 'Manage club billing and subscriptions', 'billing'),CREATE INDEX idx_recurring_instances_recurrence ON recurring_event_instances(event_recurrence_id);

    ('view_club_analytics', 'View Analytics', 'View club analytics and reports', 'analytics');CREATE INDEX idx_recurring_instances_event ON recurring_event_instances(event_id);

CREATE INDEX idx_notification_log_user ON notification_log(user_id);

-- Assign permissions to rolesCREATE INDEX idx_notification_log_event ON notification_log(event_id);

INSERT INTO role_permissions (role_id, permission_id)CREATE INDEX idx_notification_log_sent_at ON notification_log(sent_at);

SELECT r.id, p.id FROM roles r, permissions p CREATE INDEX idx_user_sessions_user ON user_sessions(user_id);

WHERE r.name = 'admin' AND p.name IN ('manage_teams', 'manage_users', 'manage_events', 'view_reports');CREATE INDEX idx_user_sessions_token ON user_sessions(session_token);

CREATE INDEX idx_user_sessions_expires ON user_sessions(expires_at);

INSERT INTO role_permissions (role_id, permission_id)CREATE INDEX idx_notification_types_category ON notification_types(category);

SELECT r.id, p.id FROM roles r, permissions p CREATE INDEX idx_recurrence_patterns_name ON recurrence_patterns(name);

WHERE r.name = 'coach' AND p.name IN ('manage_teams', 'manage_events', 'view_reports');

-- Insert notification types

INSERT INTO role_permissions (role_id, permission_id)INSERT INTO notification_types (id, name, display_name, description, category, default_enabled, is_system_notification) VALUES

SELECT r.id, p.id FROM roles r, permissions p ('550e8400-e29b-41d4-a716-446655440901', 'event_created', 'Event Created', 'Notification when new events are created', 'event_management', true, false),

WHERE r.name = 'club_owner' AND p.name IN ('manage_club', 'view_club', 'create_teams', 'join_league', 'manage_club_billing', 'view_club_analytics');('550e8400-e29b-41d4-a716-446655440902', 'event_cancelled', 'Event Cancelled', 'Notification when events are cancelled', 'event_management', true, true),

('550e8400-e29b-41d4-a716-446655440903', 'event_updated', 'Event Updated', 'Notification when event details change', 'event_management', true, false),

INSERT INTO role_permissions (role_id, permission_id)('550e8400-e29b-41d4-a716-446655440904', 'rsvp_reminder', 'RSVP Reminder', 'Reminder to respond to event invitations', 'rsvp_system', true, false),

SELECT r.id, p.id FROM roles r, permissions p ('550e8400-e29b-41d4-a716-446655440905', 'event_reminder', 'Event Reminder', 'Reminder about upcoming events', 'rsvp_system', true, false),

WHERE r.name = 'club_admin' AND p.name IN ('manage_club', 'view_club', 'create_teams', 'view_club_analytics');('550e8400-e29b-41d4-a716-446655440906', 'team_announcement', 'Team Announcement', 'General team announcements', 'team_updates', true, false),

('550e8400-e29b-41d4-a716-446655440907', 'roster_changes', 'Roster Changes', 'Notification of team roster updates', 'team_updates', false, false),

INSERT INTO role_permissions (role_id, permission_id)('550e8400-e29b-41d4-a716-446655440908', 'match_result', 'Match Results', 'Notification of match scores and results', 'team_updates', true, false);

SELECT r.id, p.id FROM roles r, permissions p 

WHERE r.name = 'league_admin' AND p.name IN ('manage_league', 'view_league');-- Insert recurrence patterns

INSERT INTO recurrence_patterns (id, name, display_name, description) VALUES

-- Insert basic lookups('550e8400-e29b-41d4-a716-446655441001', 'weekly', 'Weekly', 'Repeats every week on the same day and time'),

INSERT INTO rsvp_statuses (name, display_name, sort_order) VALUES('550e8400-e29b-41d4-a716-446655441002', 'biweekly', 'Every 2 Weeks', 'Repeats every two weeks on the same day'),

    ('yes', 'Yes', 1),('550e8400-e29b-41d4-a716-446655441003', 'monthly', 'Monthly', 'Repeats monthly on the same date'),

    ('no', 'No', 2),('550e8400-e29b-41d4-a716-446655441004', 'monthly_by_day', 'Monthly by Day', 'Repeats monthly on the same day of week (e.g., first Monday)'),

    ('maybe', 'Maybe', 3);('550e8400-e29b-41d4-a716-446655441005', 'custom', 'Custom Pattern', 'Custom recurrence pattern defined by interval');



INSERT INTO home_away_statuses (name, display_name, sort_order) VALUES-- Insert default notification preferences for existing users

    ('home', 'Home', 1),INSERT INTO user_notification_preferences (user_id, notification_type_id, email_enabled, sms_enabled, push_enabled)

    ('away', 'Away', 2),SELECT 

    ('neutral', 'Neutral Site', 3);    u.id as user_id,

    nt.id as notification_type_id,

INSERT INTO event_types (sport_id, name, display_name, category, default_duration) VALUES    nt.default_enabled as email_enabled,

    ((SELECT id FROM sports WHERE name = 'soccer'), 'practice', 'Practice', 'training', 90),    false as sms_enabled,  -- SMS disabled by default

    ((SELECT id FROM sports WHERE name = 'soccer'), 'match', 'Match', 'competition', 90),    nt.default_enabled as push_enabled

    ((SELECT id FROM sports WHERE name = 'basketball'), 'practice', 'Practice', 'training', 60),FROM users u

    ((SELECT id FROM sports WHERE name = 'basketball'), 'game', 'Game', 'competition', 60),CROSS JOIN notification_types nt

    ((SELECT id FROM sports WHERE name = 'boxing'), 'training', 'Training', 'training', 60),ON CONFLICT (user_id, notification_type_id) DO NOTHING;

    ((SELECT id FROM sports WHERE name = 'boxing'), 'bout', 'Bout', 'competition', 30);

-- === GOOGLE PLACES INTEGRATION VIEWS ===

INSERT INTO notification_types (name, display_name, category, default_enabled) VALUES

    ('event_reminder', 'Event Reminder', 'event', true),-- Venues with Google data view

    ('event_cancelled', 'Event Cancelled', 'event', true),CREATE OR REPLACE VIEW venues_with_google_data AS

    ('team_invite', 'Team Invitation', 'team', true),SELECT 

    ('club_invite', 'Club Invitation', 'club', true),    id, name, venue_type, address, formatted_address, city, state, postal_code, country,

    ('rsvp_deadline', 'RSVP Deadline', 'event', true);    latitude, longitude, place_id, rating, user_ratings_total, price_level, business_status,

    google_types, opening_hours, photos, data_source, phone, website, capacity, surface_type,

INSERT INTO recurrence_patterns (name, display_name, description) VALUES    parking_available, wheelchair_accessible, notes, is_active, created_at, updated_at,

    ('weekly', 'Weekly', 'Repeats every week'),    last_google_update,

    ('biweekly', 'Every Two Weeks', 'Repeats every two weeks'),    CASE 

    ('monthly', 'Monthly', 'Repeats every month');        WHEN rating IS NOT NULL AND rating >= 4.5 THEN 'Excellent'

        WHEN rating IS NOT NULL AND rating >= 4.0 THEN 'Very Good'

-- Insert soccer positions        WHEN rating IS NOT NULL AND rating >= 3.5 THEN 'Good'

INSERT INTO positions (sport_id, name, abbreviation, sort_order) VALUES        WHEN rating IS NOT NULL AND rating >= 3.0 THEN 'Average'

    ((SELECT id FROM sports WHERE name = 'soccer'), 'Goalkeeper', 'GK', 1),        WHEN rating IS NOT NULL THEN 'Below Average'

    ((SELECT id FROM sports WHERE name = 'soccer'), 'Defender', 'DEF', 2),        ELSE 'No Rating'

    ((SELECT id FROM sports WHERE name = 'soccer'), 'Midfielder', 'MID', 3),    END as rating_category,

    ((SELECT id FROM sports WHERE name = 'soccer'), 'Forward', 'FWD', 4);    CASE WHEN data_source = 'google_places' THEN true ELSE false END as is_google_venue,

    CASE WHEN place_id IS NOT NULL THEN true ELSE false END as has_google_data

-- Insert basketball positionsFROM venues

INSERT INTO positions (sport_id, name, abbreviation, sort_order) VALUESWHERE is_active = true;

    ((SELECT id FROM sports WHERE name = 'basketball'), 'Point Guard', 'PG', 1),

    ((SELECT id FROM sports WHERE name = 'basketball'), 'Shooting Guard', 'SG', 2),-- Venues Google mapping view

    ((SELECT id FROM sports WHERE name = 'basketball'), 'Small Forward', 'SF', 3),CREATE OR REPLACE VIEW venues_google_mapping AS

    ((SELECT id FROM sports WHERE name = 'basketball'), 'Power Forward', 'PF', 4),SELECT 

    ((SELECT id FROM sports WHERE name = 'basketball'), 'Center', 'C', 5);    id, name, place_id, formatted_address,

    latitude as lat, longitude as lng,

-- Insert boxing positions (weight classes)    phone as formatted_phone_number, international_phone_number,

INSERT INTO positions (sport_id, name, abbreviation, sort_order) VALUES    website, rating, user_ratings_total, price_level, business_status,

    ((SELECT id FROM sports WHERE name = 'boxing'), 'Lightweight', 'LW', 1),    google_types as types, opening_hours, photos,

    ((SELECT id FROM sports WHERE name = 'boxing'), 'Welterweight', 'WW', 2),    venue_type, capacity, surface_type, parking_available, wheelchair_accessible, data_source

    ((SELECT id FROM sports WHERE name = 'boxing'), 'Middleweight', 'MW', 3),FROM venues

    ((SELECT id FROM sports WHERE name = 'boxing'), 'Heavyweight', 'HW', 4);WHERE is_active = true;



-- Database is now ready for real Lighthouse 1893 data-- Record this as the baseline schema (no migrations needed for fresh installs)

-- NO test data included - clean slate for production useINSERT INTO schema_migrations (filename, checksum) VALUES
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
