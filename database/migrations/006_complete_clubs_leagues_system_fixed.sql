-- Migration: Complete Clubs/Leagues Database Design (Fixed)
-- Date: 2025-11-03
-- Description: Add missing pieces for multi-tenant club/league system

-- Add new roles for club/league management (with correct field names)
INSERT INTO roles (id, name, display_name, description) VALUES
    (uuid_generate_v4(), 'club_owner', 'Club Owner', 'Club owner with full club management rights'),
    (uuid_generate_v4(), 'club_admin', 'Club Admin', 'Club administrator with most club management rights'),
    (uuid_generate_v4(), 'league_admin', 'League Admin', 'League administrator with league management rights'),
    (uuid_generate_v4(), 'league_commissioner', 'League Commissioner', 'League commissioner with full league authority');

-- Add context fields to user_roles to support multi-tenancy
ALTER TABLE user_roles ADD COLUMN club_id UUID REFERENCES clubs(id);
ALTER TABLE user_roles ADD COLUMN league_id UUID REFERENCES leagues(id);
ALTER TABLE user_roles ADD COLUMN team_id UUID REFERENCES teams(id);

-- Remove the old unique constraint and add new simpler one
ALTER TABLE user_roles DROP CONSTRAINT user_roles_user_id_role_id_key;

-- Add new permissions for club/league management (with correct field names)
INSERT INTO permissions (id, name, display_name, description, category) VALUES
    (uuid_generate_v4(), 'manage_club', 'Manage Club', 'Manage club settings and members', 'club'),
    (uuid_generate_v4(), 'view_club', 'View Club', 'View club information', 'club'),
    (uuid_generate_v4(), 'manage_league', 'Manage League', 'Manage league settings and members', 'league'),
    (uuid_generate_v4(), 'view_league', 'View League', 'View league information', 'league'),
    (uuid_generate_v4(), 'join_league', 'Join League', 'Join leagues with club', 'league'),
    (uuid_generate_v4(), 'create_teams', 'Create Teams', 'Create teams within club', 'team'),
    (uuid_generate_v4(), 'manage_club_billing', 'Manage Billing', 'Manage club billing and subscriptions', 'billing'),
    (uuid_generate_v4(), 'view_club_analytics', 'View Analytics', 'View club analytics and reports', 'analytics');

-- Assign permissions to new roles
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'club_owner' AND p.name IN ('manage_club', 'view_club', 'create_teams', 'join_league', 'manage_club_billing', 'view_club_analytics');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'club_admin' AND p.name IN ('manage_club', 'view_club', 'create_teams', 'view_club_analytics');

-- Create club_members table for explicit club membership tracking
CREATE TABLE club_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Membership details
    joined_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'active', -- active, inactive, suspended, pending
    membership_type VARCHAR(50) DEFAULT 'member', -- member, coach, admin, owner
    
    -- Contact preferences for this club
    receive_notifications BOOLEAN DEFAULT true,
    
    -- Membership metadata
    invited_by UUID REFERENCES users(id),
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(club_id, user_id)
);

-- Create subscriptions table
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    
    -- Subscription details
    plan_name VARCHAR(50) NOT NULL, -- free, premium, enterprise
    status VARCHAR(20) DEFAULT 'active', -- active, cancelled, past_due
    
    -- Billing
    amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'USD',
    
    -- Dates
    started_at DATE DEFAULT CURRENT_DATE,
    current_period_end DATE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes
CREATE INDEX idx_user_roles_club ON user_roles(club_id) WHERE club_id IS NOT NULL;
CREATE INDEX idx_user_roles_league ON user_roles(league_id) WHERE league_id IS NOT NULL;
CREATE INDEX idx_user_roles_team ON user_roles(team_id) WHERE team_id IS NOT NULL;

CREATE INDEX idx_club_members_club ON club_members(club_id);
CREATE INDEX idx_club_members_user ON club_members(user_id);

CREATE INDEX idx_subscriptions_club ON subscriptions(club_id);

-- Add a free subscription for Thunder FC
INSERT INTO subscriptions (club_id, plan_name, status, amount)
SELECT id, 'free', 'active', 0.00
FROM clubs WHERE slug = 'thunder-fc';