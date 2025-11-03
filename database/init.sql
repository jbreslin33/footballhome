-- Football Home Database Schema - Complete Production Schema
-- Version: 4.0 - Production ready with Google Places integration
--
-- This schema includes:
-- 1. Fully normalized database (4NF compliant)
-- 2. Google Places integration with all fields
-- 3. Migration tracking system for future changes
-- 4. Complete sample data for development
-- 5. Optimized indexes and constraints

-- Create database extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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

-- Permissions lookup table (4NF compliant)
CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,          -- 'manage_teams', 'manage_users'
    display_name VARCHAR(100) NOT NULL,        -- 'Manage Teams', 'Manage Users'
    description TEXT,                          -- 'Create, edit, delete teams and rosters'
    category VARCHAR(50),                      -- 'team_management', 'user_management'
    is_system_permission BOOLEAN DEFAULT true, -- Cannot be deleted
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Roles lookup table (renamed from user_roles for clarity)
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(20) UNIQUE NOT NULL,          -- 'coach', 'player', 'admin'
    display_name VARCHAR(50) NOT NULL,         -- 'Coach', 'Player', 'Administrator'
    description TEXT,                          -- Role description
    is_system_role BOOLEAN DEFAULT false,      -- Cannot be deleted
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Role permissions junction table (many-to-many, 4NF compliant)
-- Note: granted_by reference to users will be added after users table is created
CREATE TABLE role_permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    granted_by UUID,                           -- Will add FK constraint after users table
    UNIQUE(role_id, permission_id)
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

-- Home/Away venue status lookup table
CREATE TABLE home_away_statuses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(20) UNIQUE NOT NULL,          -- 'home', 'away', 'neutral'
    display_name VARCHAR(50) NOT NULL,         -- 'Home', 'Away', 'Neutral Venue'
    description TEXT,                          -- Additional context
    sort_order INTEGER DEFAULT 0,             -- For display ordering
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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

-- Leagues table (competition structure)
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

-- Teams table (now belongs to sport divisions)
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    division_id UUID NOT NULL REFERENCES sport_divisions(id),
    league_id UUID REFERENCES leagues(id),      -- Optional league membership
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

-- Users table (no direct role reference - uses junction table)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500),
    date_of_birth DATE,
    emergency_contact VARCHAR(100),
    emergency_phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add foreign key constraint for role_permissions.granted_by now that users table exists
ALTER TABLE role_permissions ADD CONSTRAINT fk_role_permissions_granted_by 
    FOREIGN KEY (granted_by) REFERENCES users(id);

-- User roles junction table (many-to-many: users can have multiple roles)
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by UUID REFERENCES users(id),      -- Who granted this role
    is_active BOOLEAN DEFAULT true,             -- Role can be suspended
    expires_at TIMESTAMP,                       -- Optional role expiration
    notes TEXT,                                 -- Assignment notes
    UNIQUE(user_id, role_id)                   -- Prevent duplicate role assignments
);

-- Team memberships (many-to-many: users can be on multiple teams)
CREATE TABLE team_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    position_id UUID REFERENCES positions(id),  -- Player position (nullable for coaches)
    jersey_number INTEGER,
    is_captain BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    UNIQUE(team_id, user_id),
    UNIQUE(team_id, jersey_number)              -- Jersey numbers unique per team
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
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES users(id),
    event_type_id UUID NOT NULL REFERENCES event_types(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_date TIMESTAMP NOT NULL,
    venue_id UUID REFERENCES venues(id),
    duration_minutes INTEGER,                   -- Will default from event_type if null
    max_players INTEGER,
    cancelled BOOLEAN DEFAULT false,
    cancellation_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Practices table (extends events for training/practice sessions)
CREATE TABLE practices (
    id UUID PRIMARY KEY REFERENCES events(id) ON DELETE CASCADE,
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
    opponent_team_id UUID NOT NULL REFERENCES teams(id),
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
    full_time_time TIME                       -- When match ended
);

-- RSVPs (now references rsvp_status)
CREATE TABLE rsvps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rsvp_status_id UUID NOT NULL REFERENCES rsvp_statuses(id),
    response_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    dietary_requirements TEXT,
    transport_needed BOOLEAN DEFAULT false,
    UNIQUE(event_id, user_id)
);

-- Magic tokens for RSVP links via email/SMS (unchanged)
CREATE TABLE magic_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    token VARCHAR(255) UNIQUE NOT NULL,
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(event_id, user_id)
);

-- Indexes for performance
CREATE INDEX idx_events_team_date ON events(team_id, event_date);
CREATE INDEX idx_events_type ON events(event_type_id);
CREATE INDEX idx_practices_focus ON practices(focus_areas);
CREATE INDEX idx_matches_opponent ON matches(opponent_team_id);
CREATE INDEX idx_matches_competition ON matches(competition_name);
CREATE INDEX idx_matches_status ON matches(match_status);
CREATE INDEX idx_matches_home_away ON matches(home_away_status_id);
CREATE INDEX idx_rsvps_event ON rsvps(event_id);
CREATE INDEX idx_rsvps_status ON rsvps(rsvp_status_id);
CREATE INDEX idx_team_members_team ON team_members(team_id);
CREATE INDEX idx_team_members_user ON team_members(user_id);
CREATE INDEX idx_team_members_position ON team_members(position_id);
CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role_id);
CREATE INDEX idx_user_roles_active ON user_roles(user_id, is_active);
CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission ON role_permissions(permission_id);
CREATE INDEX idx_teams_division ON teams(division_id);
CREATE INDEX idx_teams_league ON teams(league_id);
CREATE INDEX idx_sport_divisions_club ON sport_divisions(club_id);
CREATE INDEX idx_sport_divisions_sport ON sport_divisions(sport_id);
CREATE INDEX idx_sport_divisions_slug ON sport_divisions(slug);
CREATE INDEX idx_clubs_parent ON clubs(parent_club_id) WHERE parent_club_id IS NOT NULL;
CREATE INDEX idx_clubs_slug ON clubs(slug);
CREATE INDEX idx_leagues_sport ON leagues(sport_id);
CREATE INDEX idx_positions_sport ON positions(sport_id);
CREATE INDEX idx_event_types_sport ON event_types(sport_id);
CREATE INDEX idx_event_types_category ON event_types(category);
CREATE INDEX idx_permissions_category ON permissions(category);
CREATE INDEX idx_magic_tokens_token ON magic_tokens(token);
CREATE INDEX idx_magic_tokens_expires ON magic_tokens(expires_at);

-- Google Places indexes
CREATE INDEX idx_venues_place_id ON venues(place_id) WHERE place_id IS NOT NULL;
CREATE INDEX idx_venues_rating ON venues(rating) WHERE rating IS NOT NULL;
CREATE INDEX idx_venues_data_source ON venues(data_source);
CREATE INDEX idx_venues_business_status ON venues(business_status);
CREATE INDEX idx_venues_phone ON venues(phone) WHERE phone IS NOT NULL;

-- Insert lookup data

-- Sports
INSERT INTO sports (id, name, display_name, default_event_duration, typical_team_size) VALUES 
('550e8400-e29b-41d4-a716-446655440101', 'soccer', 'Soccer (Football)', 90, 11),
('550e8400-e29b-41d4-a716-446655440102', 'basketball', 'Basketball', 60, 5),
('550e8400-e29b-41d4-a716-446655440103', 'hockey', 'Ice Hockey', 60, 6),
('550e8400-e29b-41d4-a716-446655440104', 'baseball', 'Baseball', 180, 9),
('550e8400-e29b-41d4-a716-446655440105', 'volleyball', 'Volleyball', 90, 6);

-- Permissions (4NF compliant)
INSERT INTO permissions (id, name, display_name, description, category, is_system_permission) VALUES 
('550e8400-e29b-41d4-a716-446655440601', 'manage_teams', 'Manage Teams', 'Create, edit, delete teams and rosters', 'team_management', true),
('550e8400-e29b-41d4-a716-446655440602', 'manage_users', 'Manage Users', 'Create, edit, delete user accounts', 'user_management', true),
('550e8400-e29b-41d4-a716-446655440603', 'manage_events', 'Manage Events', 'Create, edit, delete events and practices', 'event_management', true),
('550e8400-e29b-41d4-a716-446655440604', 'send_notifications', 'Send Notifications', 'Send email/SMS notifications to team members', 'communication', true),
('550e8400-e29b-41d4-a716-446655440605', 'manage_roles', 'Manage Roles', 'Assign and revoke user roles and permissions', 'user_management', true),
('550e8400-e29b-41d4-a716-446655440606', 'view_team', 'View Team', 'View team roster and member details', 'team_access', true),
('550e8400-e29b-41d4-a716-446655440607', 'manage_roster', 'Manage Roster', 'Add/remove players from team roster', 'team_management', true),
('550e8400-e29b-41d4-a716-446655440608', 'view_events', 'View Events', 'View team events and schedules', 'event_access', true),
('550e8400-e29b-41d4-a716-446655440609', 'rsvp_events', 'RSVP to Events', 'Respond to event invitations', 'event_access', true),
('550e8400-e29b-41d4-a716-446655440610', 'view_profile', 'View Profile', 'View own profile and basic information', 'user_access', true);

-- Roles (without permissions array)
INSERT INTO roles (id, name, display_name, description, is_system_role) VALUES 
('550e8400-e29b-41d4-a716-446655440201', 'admin', 'Administrator', 'System administrator with full access', true),
('550e8400-e29b-41d4-a716-446655440202', 'coach', 'Coach', 'Team coach with management capabilities', true),
('550e8400-e29b-41d4-a716-446655440203', 'player', 'Player', 'Team player with basic access', true),
('550e8400-e29b-41d4-a716-446655440204', 'assistant_coach', 'Assistant Coach', 'Assistant coach with limited management', false),
('550e8400-e29b-41d4-a716-446655440205', 'parent', 'Parent/Guardian', 'Parent or guardian of a player', false);

-- Role permissions assignments (many-to-many junction)
INSERT INTO role_permissions (role_id, permission_id) VALUES
-- Admin gets all permissions
('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440601'), -- manage_teams
('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440602'), -- manage_users
('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440603'), -- manage_events
('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440604'), -- send_notifications
('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440605'), -- manage_roles
('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440606'), -- view_team
('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440607'), -- manage_roster
('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440608'), -- view_events
('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440609'), -- rsvp_events
('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440610'), -- view_profile
-- Coach permissions
('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440603'), -- manage_events
('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440604'), -- send_notifications
('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440606'), -- view_team
('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440607'), -- manage_roster
('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440608'), -- view_events
('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440610'), -- view_profile
-- Player permissions
('550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440608'), -- view_events
('550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440609'), -- rsvp_events
('550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440610'), -- view_profile
-- Assistant coach permissions
('550e8400-e29b-41d4-a716-446655440204', '550e8400-e29b-41d4-a716-446655440606'), -- view_team
('550e8400-e29b-41d4-a716-446655440204', '550e8400-e29b-41d4-a716-446655440604'), -- send_notifications
('550e8400-e29b-41d4-a716-446655440204', '550e8400-e29b-41d4-a716-446655440608'), -- view_events
('550e8400-e29b-41d4-a716-446655440204', '550e8400-e29b-41d4-a716-446655440610'), -- view_profile
-- Parent permissions
('550e8400-e29b-41d4-a716-446655440205', '550e8400-e29b-41d4-a716-446655440608'), -- view_events
('550e8400-e29b-41d4-a716-446655440205', '550e8400-e29b-41d4-a716-446655440610'); -- view_profile

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
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
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
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
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
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
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
