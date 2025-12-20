-- Registry of manageable lookup tables for System Admin
-- This allows super admins to view and edit reference data through the UI

CREATE TABLE IF NOT EXISTS lookup_tables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(150) NOT NULL,
    description TEXT,
    category VARCHAR(50),                      -- 'sports', 'events', 'players', 'system'
    is_system_managed BOOLEAN DEFAULT false,   -- If true, admins can't delete core entries
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Populate with existing lookup tables
INSERT INTO lookup_tables (table_name, display_name, description, category, is_system_managed, sort_order) VALUES
-- Sports-related lookups
('sports', 'Sports', 'Available sports/activities in the system', 'sports', true, 1),
('positions', 'Player Positions', 'Available positions for each sport', 'sports', true, 2),

-- Event-related lookups
('event_types', 'Event Types', 'Types of events (training, match, meeting)', 'events', true, 10),
('rsvp_statuses', 'RSVP Statuses', 'Attendance response options (yes, no, maybe)', 'events', true, 11),
('rsvp_change_sources', 'RSVP Change Sources', 'How RSVPs were submitted (app, coach, magic link)', 'events', true, 12),

-- Player-related lookups
('player_statuses', 'Player Statuses', 'Player roster statuses (active, injured, suspended)', 'players', false, 20),
('jersey_sizes', 'Jersey Sizes', 'Available jersey sizes', 'players', false, 21),
('skill_levels', 'Skill Levels', 'Player skill level classifications', 'players', false, 22),

-- Medical/Academic lookups
('medical_status_types', 'Medical Status Types', 'Types of medical conditions/injuries', 'players', false, 30),
('academic_status_types', 'Academic Status Types', 'Types of academic eligibility issues', 'players', false, 31),

-- System lookups
('admin_levels', 'Admin Levels', 'System administrator permission levels', 'system', true, 40),
('audit_action_types', 'Audit Action Types', 'Types of administrative actions logged', 'system', true, 41);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_lookup_tables_category ON lookup_tables(category, sort_order);
