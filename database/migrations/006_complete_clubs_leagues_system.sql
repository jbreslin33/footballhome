-- Migration: Complete Clubs/Leagues Database Design
-- Date: 2025-11-03
-- Description: Add missing pieces for multi-tenant club/league system

-- Add new roles for club/league management
INSERT INTO roles (id, name, description) VALUES
    (uuid_generate_v4(), 'club_owner', 'Club owner with full club management rights'),
    (uuid_generate_v4(), 'club_admin', 'Club administrator with most club management rights'),
    (uuid_generate_v4(), 'league_admin', 'League administrator with league management rights'),
    (uuid_generate_v4(), 'league_commissioner', 'League commissioner with full league authority');

-- Add context fields to user_roles to support multi-tenancy
ALTER TABLE user_roles ADD COLUMN club_id UUID REFERENCES clubs(id);
ALTER TABLE user_roles ADD COLUMN league_id UUID REFERENCES leagues(id);
ALTER TABLE user_roles ADD COLUMN team_id UUID REFERENCES teams(id);

-- Add constraint: role must have at least one context (global, club, league, or team)
ALTER TABLE user_roles ADD CONSTRAINT user_roles_context_check 
    CHECK (club_id IS NOT NULL OR league_id IS NOT NULL OR team_id IS NOT NULL OR 
           role_id IN (SELECT id FROM roles WHERE name = 'admin'));

-- Remove the old unique constraint and add new one that includes context
ALTER TABLE user_roles DROP CONSTRAINT user_roles_user_id_role_id_key;
ALTER TABLE user_roles ADD CONSTRAINT user_roles_context_unique 
    UNIQUE (user_id, role_id, COALESCE(club_id, '00000000-0000-0000-0000-000000000000'::uuid), 
            COALESCE(league_id, '00000000-0000-0000-0000-000000000000'::uuid),
            COALESCE(team_id, '00000000-0000-0000-0000-000000000000'::uuid));

-- Add new permissions for club/league management
INSERT INTO permissions (id, name, description, resource, action) VALUES
    (uuid_generate_v4(), 'manage_club', 'Manage club settings and members', 'club', 'manage'),
    (uuid_generate_v4(), 'view_club', 'View club information', 'club', 'view'),
    (uuid_generate_v4(), 'manage_league', 'Manage league settings and members', 'league', 'manage'),
    (uuid_generate_v4(), 'view_league', 'View league information', 'league', 'view'),
    (uuid_generate_v4(), 'join_league', 'Join leagues with club', 'league', 'join'),
    (uuid_generate_v4(), 'create_teams', 'Create teams within club', 'team', 'create'),
    (uuid_generate_v4(), 'manage_club_billing', 'Manage club billing and subscriptions', 'billing', 'manage'),
    (uuid_generate_v4(), 'view_club_analytics', 'View club analytics and reports', 'analytics', 'view');

-- Assign permissions to new roles
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'club_owner' AND p.name IN ('manage_club', 'view_club', 'create_teams', 'join_league', 'manage_club_billing', 'view_club_analytics');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'club_admin' AND p.name IN ('manage_club', 'view_club', 'create_teams', 'view_club_analytics');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'league_admin' AND p.name IN ('manage_league', 'view_league');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'league_commissioner' AND p.name IN ('manage_league', 'view_league');

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
    notification_email VARCHAR(255), -- might be different from user's main email
    
    -- Membership metadata
    invited_by UUID REFERENCES users(id),
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(club_id, user_id)
);

-- Create league_members table for league-level membership
CREATE TABLE league_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    league_id UUID NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- League membership details
    joined_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'active',
    membership_type VARCHAR(50) DEFAULT 'participant', -- participant, official, admin
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(league_id, user_id)
);

-- Add subscription and billing tables
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    
    -- Subscription details
    plan_name VARCHAR(50) NOT NULL, -- free, premium, enterprise
    status VARCHAR(20) DEFAULT 'active', -- active, cancelled, past_due, unpaid
    
    -- Billing cycle
    billing_interval VARCHAR(20) DEFAULT 'monthly', -- monthly, yearly
    amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'USD',
    
    -- Dates
    started_at DATE DEFAULT CURRENT_DATE,
    current_period_start DATE,
    current_period_end DATE,
    cancelled_at DATE,
    
    -- External billing system references
    stripe_subscription_id VARCHAR(100),
    stripe_customer_id VARCHAR(100),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add usage tracking for API and features
CREATE TABLE club_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    
    -- Usage period
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    -- Usage metrics
    api_calls_used INTEGER DEFAULT 0,
    api_calls_limit INTEGER DEFAULT 1000,
    teams_count INTEGER DEFAULT 0,
    players_count INTEGER DEFAULT 0,
    events_count INTEGER DEFAULT 0,
    
    -- Feature usage
    features_used JSONB DEFAULT '{}', -- track which premium features are used
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(club_id, period_start)
);

-- Add indexes for performance
CREATE INDEX idx_user_roles_club ON user_roles(club_id) WHERE club_id IS NOT NULL;
CREATE INDEX idx_user_roles_league ON user_roles(league_id) WHERE league_id IS NOT NULL;
CREATE INDEX idx_user_roles_team ON user_roles(team_id) WHERE team_id IS NOT NULL;

CREATE INDEX idx_club_members_club ON club_members(club_id);
CREATE INDEX idx_club_members_user ON club_members(user_id);
CREATE INDEX idx_club_members_status ON club_members(status);

CREATE INDEX idx_league_members_league ON league_members(league_id);
CREATE INDEX idx_league_members_user ON league_members(user_id);

CREATE INDEX idx_subscriptions_club ON subscriptions(club_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

CREATE INDEX idx_club_usage_club ON club_usage(club_id);
CREATE INDEX idx_club_usage_period ON club_usage(period_start, period_end);

-- Add some initial data for Thunder FC
-- Make a user the club owner (you'll need to adjust the user_id)
INSERT INTO club_members (club_id, user_id, membership_type, status)
SELECT c.id, u.id, 'owner', 'active'
FROM clubs c, users u 
WHERE c.slug = 'thunder-fc' 
AND u.email = 'admin@example.com' -- adjust this to your admin user
LIMIT 1;

-- Add a free subscription for Thunder FC
INSERT INTO subscriptions (club_id, plan_name, status, amount)
SELECT id, 'free', 'active', 0.00
FROM clubs WHERE slug = 'thunder-fc';

-- Add initial usage tracking
INSERT INTO club_usage (club_id, period_start, period_end, teams_count)
SELECT c.id, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 month', 
       (SELECT COUNT(*) FROM teams WHERE club_id = c.id)
FROM clubs c WHERE c.slug = 'thunder-fc';

-- Add comments for documentation
COMMENT ON TABLE club_members IS 'Explicit club membership with roles and preferences';
COMMENT ON TABLE league_members IS 'League membership for users participating in leagues';
COMMENT ON TABLE subscriptions IS 'Club subscription plans and billing information';
COMMENT ON TABLE club_usage IS 'Usage tracking for API limits and feature usage';

COMMENT ON COLUMN user_roles.club_id IS 'Club context for role (NULL = global role)';
COMMENT ON COLUMN user_roles.league_id IS 'League context for role (NULL = not league-specific)';
COMMENT ON COLUMN user_roles.team_id IS 'Team context for role (NULL = not team-specific)';