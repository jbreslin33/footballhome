-- Football Home Database Schema - Normalized Version
-- Version: 2.0 - Fully normalized with lookup tables

-- Create database extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Sports lookup table
CREATE TABLE sports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,          -- 'soccer', 'basketball', 'hockey'
    display_name VARCHAR(100) NOT NULL,        -- 'Soccer', 'Basketball', 'Ice Hockey'
    default_event_duration INTEGER DEFAULT 90, -- Default minutes for this sport
    typical_team_size INTEGER,                 -- 11 for soccer, 5 for basketball
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Roles lookup table (renamed from user_roles for clarity)
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(20) UNIQUE NOT NULL,          -- 'coach', 'player', 'admin'
    display_name VARCHAR(50) NOT NULL,         -- 'Coach', 'Player', 'Administrator'
    description TEXT,                          -- Role description
    permissions TEXT[],                        -- Array of permissions
    is_system_role BOOLEAN DEFAULT false,      -- Cannot be deleted
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Event types lookup table
CREATE TABLE event_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sport_id UUID REFERENCES sports(id),       -- Different types per sport
    name VARCHAR(50) NOT NULL,                 -- 'training', 'match', 'meeting'
    display_name VARCHAR(100) NOT NULL,        -- 'Training Session', 'Match', 'Team Meeting'
    default_duration INTEGER DEFAULT 90,       -- Default duration for this type
    requires_opponent BOOLEAN DEFAULT false,   -- Does this event type need an opponent?
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sport_id, name)
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

-- Teams table (now references sport)
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    sport_id UUID NOT NULL REFERENCES sports(id),
    season VARCHAR(20),
    description TEXT,
    logo_url VARCHAR(500),
    primary_color VARCHAR(7),                  -- Hex color
    secondary_color VARCHAR(7),                -- Hex color
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

-- Events (now references event_type)
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES users(id),
    event_type_id UUID NOT NULL REFERENCES event_types(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_date TIMESTAMP NOT NULL,
    location VARCHAR(255),
    duration_minutes INTEGER,                   -- Will default from event_type if null
    max_players INTEGER,
    opponent_team_id UUID REFERENCES teams(id), -- For matches against other teams
    home_away VARCHAR(10) CHECK (home_away IN ('home', 'away')),
    cancelled BOOLEAN DEFAULT false,
    cancellation_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
CREATE INDEX idx_rsvps_event ON rsvps(event_id);
CREATE INDEX idx_rsvps_status ON rsvps(rsvp_status_id);
CREATE INDEX idx_team_members_team ON team_members(team_id);
CREATE INDEX idx_team_members_user ON team_members(user_id);
CREATE INDEX idx_team_members_position ON team_members(position_id);
CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role_id);
CREATE INDEX idx_user_roles_active ON user_roles(user_id, is_active);
CREATE INDEX idx_teams_sport ON teams(sport_id);
CREATE INDEX idx_positions_sport ON positions(sport_id);
CREATE INDEX idx_event_types_sport ON event_types(sport_id);
CREATE INDEX idx_magic_tokens_token ON magic_tokens(token);
CREATE INDEX idx_magic_tokens_expires ON magic_tokens(expires_at);

-- Insert lookup data

-- Sports
INSERT INTO sports (id, name, display_name, default_event_duration, typical_team_size) VALUES 
('550e8400-e29b-41d4-a716-446655440101', 'soccer', 'Soccer (Football)', 90, 11),
('550e8400-e29b-41d4-a716-446655440102', 'basketball', 'Basketball', 60, 5),
('550e8400-e29b-41d4-a716-446655440103', 'hockey', 'Ice Hockey', 60, 6),
('550e8400-e29b-41d4-a716-446655440104', 'baseball', 'Baseball', 180, 9),
('550e8400-e29b-41d4-a716-446655440105', 'volleyball', 'Volleyball', 90, 6);

-- Roles (renamed from user_roles)
INSERT INTO roles (id, name, display_name, description, permissions, is_system_role) VALUES 
('550e8400-e29b-41d4-a716-446655440201', 'admin', 'Administrator', 'System administrator with full access', ARRAY['manage_teams', 'manage_users', 'manage_events', 'send_notifications', 'manage_roles'], true),
('550e8400-e29b-41d4-a716-446655440202', 'coach', 'Coach', 'Team coach with management capabilities', ARRAY['manage_events', 'send_notifications', 'view_team', 'manage_roster'], true),
('550e8400-e29b-41d4-a716-446655440203', 'player', 'Player', 'Team player with basic access', ARRAY['view_events', 'rsvp_events', 'view_profile'], true),
('550e8400-e29b-41d4-a716-446655440204', 'assistant_coach', 'Assistant Coach', 'Assistant coach with limited management', ARRAY['view_team', 'send_notifications'], false),
('550e8400-e29b-41d4-a716-446655440205', 'parent', 'Parent/Guardian', 'Parent or guardian of a player', ARRAY['view_events', 'view_profile'], false);

-- RSVP statuses
INSERT INTO rsvp_statuses (id, name, display_name, sort_order, color) VALUES 
('550e8400-e29b-41d4-a716-446655440301', 'yes', 'Attending', 1, '#27ae60'),
('550e8400-e29b-41d4-a716-446655440302', 'maybe', 'Maybe', 2, '#f39c12'),
('550e8400-e29b-41d4-a716-446655440303', 'no', 'Not Attending', 3, '#e74c3c');

-- Event types for soccer
INSERT INTO event_types (id, sport_id, name, display_name, default_duration, requires_opponent) VALUES 
('550e8400-e29b-41d4-a716-446655440401', '550e8400-e29b-41d4-a716-446655440101', 'training', 'Training Session', 90, false),
('550e8400-e29b-41d4-a716-446655440402', '550e8400-e29b-41d4-a716-446655440101', 'match', 'Match', 120, true),
('550e8400-e29b-41d4-a716-446655440403', '550e8400-e29b-41d4-a716-446655440101', 'meeting', 'Team Meeting', 60, false),
('550e8400-e29b-41d4-a716-446655440404', '550e8400-e29b-41d4-a716-446655440101', 'scrimmage', 'Scrimmage', 90, false);

-- Soccer positions
INSERT INTO positions (id, sport_id, name, display_name, abbreviation, sort_order) VALUES 
('550e8400-e29b-41d4-a716-446655440501', '550e8400-e29b-41d4-a716-446655440101', 'goalkeeper', 'Goalkeeper', 'GK', 1),
('550e8400-e29b-41d4-a716-446655440502', '550e8400-e29b-41d4-a716-446655440101', 'defender', 'Defender', 'DEF', 2),
('550e8400-e29b-41d4-a716-446655440503', '550e8400-e29b-41d4-a716-446655440101', 'midfielder', 'Midfielder', 'MID', 3),
('550e8400-e29b-41d4-a716-446655440504', '550e8400-e29b-41d4-a716-446655440101', 'forward', 'Forward', 'FWD', 4);

-- Sample teams
INSERT INTO teams (id, name, sport_id, season, primary_color, secondary_color) VALUES 
('550e8400-e29b-41d4-a716-446655440001', 'Thunder FC Demo', '550e8400-e29b-41d4-a716-446655440101', '2025/26 Season', '#e74c3c', '#ffffff'),
('550e8400-e29b-41d4-a716-446655440002', 'Lightning United', '550e8400-e29b-41d4-a716-446655440101', '2025/26 Season', '#3498db', '#ffffff');

-- Sample users (no direct role references)
INSERT INTO users (id, email, name, phone, password_hash) VALUES 
('550e8400-e29b-41d4-a716-446655440100', 'coach@thunderfc.com', 'Coach Sarah Martinez', '+1-555-1893', '$2b$12$sample_hash_here'),
('550e8400-e29b-41d4-a716-446655440101', 'player@thunderfc.com', 'Alex Johnson', '+1-555-2001', '$2b$12$sample_hash_here'),
('550e8400-e29b-41d4-a716-446655440102', 'keeper@thunderfc.com', 'Maria Rodriguez', '+1-555-2002', '$2b$12$sample_hash_here'),
('550e8400-e29b-41d4-a716-446655440103', 'defender@thunderfc.com', 'Emma Thompson', '+1-555-2003', '$2b$12$sample_hash_here'),
('550e8400-e29b-41d4-a716-446655440104', 'striker@thunderfc.com', 'David Kim', '+1-555-2004', '$2b$12$sample_hash_here'),
('550e8400-e29b-41d4-a716-446655440105', 'demo@footballhome.org', 'Demo User', '+1-555-2005', '$2b$12$sample_hash_here'),
('550e8400-e29b-41d4-a716-446655440106', 'admin@thunderfc.com', 'Admin Alice Cooper', '+1-555-1000', '$2b$12$sample_hash_here');

-- User role assignments (many-to-many junction table)
INSERT INTO user_roles (user_id, role_id, assigned_by, notes) VALUES
-- Admin user has admin role
('550e8400-e29b-41d4-a716-446655440106', '550e8400-e29b-41d4-a716-446655440201', NULL, 'System administrator'),
-- Coach has coach role
('550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440106', 'Head coach of Thunder FC'),
-- Players have player role
('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440100', 'Team captain and midfielder'),
('550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440100', 'Team goalkeeper'),
('550e8400-e29b-41d4-a716-446655440103', '550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440100', 'Team defender'),
('550e8400-e29b-41d4-a716-446655440104', '550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440100', 'Team striker'),
('550e8400-e29b-41d4-a716-446655440105', '550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440100', 'Demo player account'),
-- Example: Alex Johnson (captain) also has assistant coach role for youth team
('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440204', '550e8400-e29b-41d4-a716-446655440100', 'Assists with youth development');

-- Team memberships with positions
INSERT INTO team_members (team_id, user_id, position_id, jersey_number, is_captain) VALUES
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440100', NULL, NULL, false), -- Coach (no position/jersey)
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440503', 10, true),  -- Alex - Midfielder, Captain
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440501', 1, false),  -- Maria - Goalkeeper
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440103', '550e8400-e29b-41d4-a716-446655440502', 4, false),  -- Emma - Defender
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440104', '550e8400-e29b-41d4-a716-446655440504', 9, false),  -- David - Forward
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440105', '550e8400-e29b-41d4-a716-446655440504', 11, false); -- Demo - Forward

-- Sample events using normalized event types
INSERT INTO events (id, team_id, created_by, event_type_id, title, description, event_date, location, duration_minutes) VALUES
('550e8400-e29b-41d4-a716-446655440701', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440401', 'Weekly Training Session', 'Regular training focusing on passing and shooting', '2025-10-30 18:00:00', 'Thunder FC Training Ground', 90),
('550e8400-e29b-41d4-a716-446655440702', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440402', 'Match vs Lightning United', 'League match against Lightning United', '2025-11-02 15:00:00', 'Thunder FC Stadium', 120),
('550e8400-e29b-41d4-a716-446655440703', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440403', 'Team Strategy Meeting', 'Discussing tactics for upcoming matches', '2025-10-29 19:00:00', 'Thunder FC Clubhouse', 60);
