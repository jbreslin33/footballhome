-- Create Admin User and Initial Data for Football Home
-- This script creates the initial admin user, team, and sample data

-- Create the admin user
INSERT INTO users (
    id, 
    email, 
    name, 
    phone, 
    password_hash, 
    is_active
) VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'jbreslin@footballhome.org',
    'John Breslin', 
    '(555) 123-4567',
    '$2b$10$rqgX8YHKQr1HsrK8O1234uXHZY3K7dY8HqPXW2QHyZc1J3L5M7N9O', -- Password: m13m13m1
    true
) ON CONFLICT (email) DO NOTHING;

-- Assign admin role to the user
INSERT INTO user_roles (user_id, role_id, assigned_at) VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    '550e8400-e29b-41d4-a716-446655440201', -- admin role
    CURRENT_TIMESTAMP
) ON CONFLICT (user_id, role_id) DO NOTHING;

-- Assign coach role to the user
INSERT INTO user_roles (user_id, role_id, assigned_at) VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    '550e8400-e29b-41d4-a716-446655440202', -- coach role
    CURRENT_TIMESTAMP
) ON CONFLICT (user_id, role_id) DO NOTHING;

-- Assign player role to the user
INSERT INTO user_roles (user_id, role_id, assigned_at) VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    '550e8400-e29b-41d4-a716-446655440203', -- player role
    CURRENT_TIMESTAMP
) ON CONFLICT (user_id, role_id) DO NOTHING;

-- Create Lighthouse 1893 SC club
INSERT INTO clubs (
    id,
    name,
    display_name,
    slug,
    description,
    website,
    founded_year,
    contact_email,
    contact_phone,
    address,
    city,
    state,
    postal_code,
    country,
    is_active
) VALUES (
    '550e8400-e29b-41d4-a716-446655440901',
    'Lighthouse 1893 SC',
    'Lighthouse 1893 Soccer Club',
    'lighthouse-1893-sc',
    'Lighthouse 1893 Soccer Club - Philadelphia area soccer club',
    'https://lighthouse1893.com',
    1893,
    'info@lighthouse1893.com',
    '(215) 555-1893',
    '123 Soccer Way',
    'Philadelphia',
    'PA',
    '19103',
    'USA',
    true
) ON CONFLICT (slug) DO NOTHING;

-- Create Soccer Division for Lighthouse 1893 SC
INSERT INTO sport_divisions (
    id,
    club_id,
    sport_id,
    name,
    display_name,
    slug,
    description,
    primary_color,
    secondary_color,
    is_active
) VALUES (
    '550e8400-e29b-41d4-a716-446655440902',
    '550e8400-e29b-41d4-a716-446655440901', -- Lighthouse 1893 SC
    '550e8400-e29b-41d4-a716-446655440101', -- Soccer
    'Soccer Division',
    'Lighthouse 1893 Soccer Division',
    'lighthouse-1893-soccer',
    'Main soccer division for Lighthouse 1893 SC',
    '#003366', -- Navy blue
    '#FFD700', -- Gold
    true
) ON CONFLICT (club_id, sport_id, slug) DO NOTHING;

-- Create Men's First Team
INSERT INTO teams (
    id,
    name,
    division_id,
    season,
    age_group,
    skill_level,
    description,
    primary_color,
    secondary_color,
    is_active
) VALUES (
    '550e8400-e29b-41d4-a716-446655440903',
    'Men''s First Team',
    '550e8400-e29b-41d4-a716-446655440902', -- Soccer Division
    '2025',
    'Adult',
    'Competitive',
    'Lighthouse 1893 SC Men''s First Team',
    '#003366', -- Navy blue
    '#FFD700', -- Gold
    true
) ON CONFLICT DO NOTHING;

-- Add John as team manager
INSERT INTO team_members (
    id,
    team_id,
    user_id,
    position_id,
    jersey_number,
    is_captain,
    is_active,
    joined_at
) VALUES (
    uuid_generate_v4(),
    '550e8400-e29b-41d4-a716-446655440903', -- Men's First Team
    '77d77471-1250-47e0-81ab-d4626595d63c', -- John Breslin
    '550e8400-e29b-41d4-a716-446655440503', -- Midfielder
    10,
    true,
    true,
    CURRENT_TIMESTAMP
) ON CONFLICT (team_id, user_id) DO NOTHING;

-- Insert notification types
INSERT INTO notification_types (name, display_name, description, category, default_enabled, is_system_notification) VALUES
('event_created', 'Event Created', 'Notification when new events are created', 'event_management', true, true),
('event_cancelled', 'Event Cancelled', 'Notification when events are cancelled', 'event_management', true, true),
('event_updated', 'Event Updated', 'Notification when event details are changed', 'event_management', true, false),
('rsvp_reminder', 'RSVP Reminder', 'Reminder to respond to event invitations', 'rsvp_system', true, false),
('rsvp_deadline', 'RSVP Deadline', 'Final reminder before RSVP deadline', 'rsvp_system', true, true),
('team_announcement', 'Team Announcement', 'General team announcements', 'team_updates', true, false)
ON CONFLICT (name) DO NOTHING;

-- Insert default notification preferences for existing users
INSERT INTO user_notification_preferences (user_id, notification_type_id, email_enabled, sms_enabled, push_enabled)
SELECT 
    u.id,
    nt.id,
    nt.default_enabled, -- email_enabled
    false, -- sms_enabled (default off)
    nt.default_enabled -- push_enabled
FROM users u
CROSS JOIN notification_types nt
WHERE NOT EXISTS (
    SELECT 1 FROM user_notification_preferences unp 
    WHERE unp.user_id = u.id AND unp.notification_type_id = nt.id
);

-- Insert recurrence patterns
INSERT INTO recurrence_patterns (name, display_name, description) VALUES
('weekly', 'Weekly', 'Repeats every week on the same day'),
('biweekly', 'Every 2 Weeks', 'Repeats every 2 weeks on the same day'),
('monthly', 'Monthly', 'Repeats monthly on the same date'),
('daily', 'Daily', 'Repeats every day')
ON CONFLICT (name) DO NOTHING;

-- Add sample training venue
INSERT INTO venues (
    id,
    name,
    short_name,
    venue_type,
    address,
    city,
    state,
    postal_code,
    country,
    latitude,
    longitude,
    surface_type,
    capacity,
    facilities,
    equipment_available,
    wheelchair_accessible,
    weather_covered,
    parking_available,
    contact_name,
    phone,
    email,
    available_hours,
    notes,
    owned_by_team,
    is_active
) VALUES (
    '550e8400-e29b-41d4-a716-446655440904',
    'Lighthouse Training Ground',
    'Training Ground',
    'field',
    '456 Training Field Rd',
    'Philadelphia',
    'PA',
    '19103',
    'USA',
    39.9526,
    -75.1652,
    'grass',
    50,
    ARRAY['changing_rooms', 'parking', 'floodlights'],
    ARRAY['goals', 'cones', 'bibs', 'first_aid'],
    true,
    false,
    true,
    'John Breslin',
    '(215) 555-TRAIN',
    'training@lighthouse1893.com',
    '6AM-10PM',
    'Main training facility for Lighthouse 1893 SC',
    true,
    true
) ON CONFLICT DO NOTHING;

COMMIT;