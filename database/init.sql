-- Football Home Database Schema
-- Initial setup for coaches, players, teams, events, and RSVPs

-- Create database extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Teams table
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    sport VARCHAR(50) DEFAULT 'soccer',
    season VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users table (coaches and players)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) CHECK (role IN ('coach', 'player', 'admin')) DEFAULT 'player',
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Team memberships (many-to-many: users can be on multiple teams)
CREATE TABLE team_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) CHECK (role IN ('coach', 'player')) DEFAULT 'player',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(team_id, user_id)
);

-- Events (training, matches, meetings)
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_type VARCHAR(20) CHECK (event_type IN ('training', 'match', 'meeting')) DEFAULT 'training',
    event_date TIMESTAMP NOT NULL,
    location VARCHAR(255),
    duration_minutes INTEGER DEFAULT 90,
    max_players INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- RSVPs for events
CREATE TABLE rsvps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) CHECK (status IN ('yes', 'no', 'maybe')) NOT NULL,
    response_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    UNIQUE(event_id, user_id)
);

-- Magic tokens for RSVP links
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
CREATE INDEX idx_rsvps_event ON rsvps(event_id);
CREATE INDEX idx_team_members_team ON team_members(team_id);
CREATE INDEX idx_team_members_user ON team_members(user_id);
CREATE INDEX idx_magic_tokens_token ON magic_tokens(token);
CREATE INDEX idx_magic_tokens_expires ON magic_tokens(expires_at);

-- Sample data for development
INSERT INTO teams (id, name, sport, season) VALUES 
('550e8400-e29b-41d4-a716-446655440001', 'Thunder FC', 'soccer', '2025/26 Season'),
('550e8400-e29b-41d4-a716-446655440002', 'Lightning United', 'soccer', '2025/26 Season');

INSERT INTO users (id, email, name, role, password_hash) VALUES 
('550e8400-e29b-41d4-a716-446655440010', 'coach@footballhome.org', 'Coach Smith', 'coach', '$2b$12$sample_hash_here'),
('550e8400-e29b-41d4-a716-446655440011', 'player1@footballhome.org', 'John Player', 'player', '$2b$12$sample_hash_here'),
('550e8400-e29b-41d4-a716-446655440012', 'player2@footballhome.org', 'Jane Athlete', 'player', '$2b$12$sample_hash_here');

-- Add team memberships
INSERT INTO team_members (team_id, user_id, role) VALUES
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440010', 'coach'),
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', 'player'),
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', 'player');
