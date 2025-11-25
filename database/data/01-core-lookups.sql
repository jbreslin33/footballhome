-- ========================================
-- CORE LOOKUP DATA
-- ========================================
-- Essential lookup/reference data required for system operation
-- This includes sports, permissions, positions, event types, etc.
-- Load this AFTER schema creation, BEFORE any club-specific data

-- Sports
INSERT INTO sports (id, name, display_name, default_event_duration, typical_team_size) VALUES 
('550e8400-e29b-41d4-a716-446655440101', 'soccer', 'Soccer (Football)', 90, 11),
('550e8400-e29b-41d4-a716-446655440102', 'basketball', 'Basketball', 60, 5),
('550e8400-e29b-41d4-a716-446655440103', 'hockey', 'Ice Hockey', 60, 6),
('550e8400-e29b-41d4-a716-446655440104', 'baseball', 'Baseball', 180, 9),
('550e8400-e29b-41d4-a716-446655440105', 'volleyball', 'Volleyball', 90, 6)
ON CONFLICT (id) DO NOTHING;

-- Permission Categories
INSERT INTO permission_categories (id, name, display_name, description, sort_order) VALUES
('550e8400-e29b-41d4-a716-446655440701', 'team_management', 'Team Management', 'Permissions for managing teams and rosters', 1),
('550e8400-e29b-41d4-a716-446655440702', 'user_management', 'User Management', 'Permissions for managing users and roles', 2),
('550e8400-e29b-41d4-a716-446655440703', 'event_management', 'Event Management', 'Permissions for managing events and practices', 3),
('550e8400-e29b-41d4-a716-446655440704', 'communication', 'Communication', 'Permissions for notifications and messaging', 4),
('550e8400-e29b-41d4-a716-446655440705', 'team_access', 'Team Access', 'Permissions for viewing team information', 5),
('550e8400-e29b-41d4-a716-446655440706', 'event_access', 'Event Access', 'Permissions for viewing and responding to events', 6),
('550e8400-e29b-41d4-a716-446655440707', 'user_access', 'User Access', 'Permissions for user profile access', 7),
('550e8400-e29b-41d4-a716-446655440708', 'system_admin', 'System Administration', 'System-level administrative permissions', 8),
('550e8400-e29b-41d4-a716-446655440709', 'league_management', 'League Management', 'Permissions for managing leagues and conferences', 9),
('550e8400-e29b-41d4-a716-446655440710', 'club_management', 'Club Management', 'Permissions for managing clubs and divisions', 10),
('550e8400-e29b-41d4-a716-446655440711', 'venue_management', 'Venue Management', 'Permissions for managing venues', 11)
ON CONFLICT (id) DO NOTHING;

-- Permissions
INSERT INTO permissions (id, name, display_name, description, permission_category_id, is_system_permission) VALUES 
('550e8400-e29b-41d4-a716-446655440601', 'manage_teams', 'Manage Teams', 'Create, edit, delete teams and rosters', '550e8400-e29b-41d4-a716-446655440701', true),
('550e8400-e29b-41d4-a716-446655440602', 'manage_users', 'Manage Users', 'Create, edit, delete user accounts', '550e8400-e29b-41d4-a716-446655440702', true),
('550e8400-e29b-41d4-a716-446655440603', 'manage_events', 'Manage Events', 'Create, edit, delete events and practices', '550e8400-e29b-41d4-a716-446655440703', true),
('550e8400-e29b-41d4-a716-446655440604', 'send_notifications', 'Send Notifications', 'Send email/SMS notifications to team members', '550e8400-e29b-41d4-a716-446655440704', true),
('550e8400-e29b-41d4-a716-446655440605', 'manage_roles', 'Manage Roles', 'Assign and revoke user roles and permissions', '550e8400-e29b-41d4-a716-446655440702', true),
('550e8400-e29b-41d4-a716-446655440606', 'view_team', 'View Team', 'View team roster and member details', '550e8400-e29b-41d4-a716-446655440705', true),
('550e8400-e29b-41d4-a716-446655440607', 'manage_roster', 'Manage Roster', 'Add/remove players from team roster', '550e8400-e29b-41d4-a716-446655440701', true),
('550e8400-e29b-41d4-a716-446655440608', 'view_events', 'View Events', 'View team events and schedules', '550e8400-e29b-41d4-a716-446655440706', true),
('550e8400-e29b-41d4-a716-446655440609', 'rsvp_events', 'RSVP to Events', 'Respond to event invitations', '550e8400-e29b-41d4-a716-446655440706', true),
('550e8400-e29b-41d4-a716-446655440610', 'view_profile', 'View Profile', 'View own profile and basic information', '550e8400-e29b-41d4-a716-446655440707', true),
('550e8400-e29b-41d4-a716-446655440611', 'system_admin', 'System Administrator', 'Full system access - all permissions', '550e8400-e29b-41d4-a716-446655440708', true),
('550e8400-e29b-41d4-a716-446655440612', 'manage_leagues', 'Manage Leagues', 'Create, edit, delete leagues and conferences', '550e8400-e29b-41d4-a716-446655440709', true),
('550e8400-e29b-41d4-a716-446655440613', 'manage_clubs', 'Manage Clubs', 'Create, edit, delete clubs and divisions', '550e8400-e29b-41d4-a716-446655440710', true),
('550e8400-e29b-41d4-a716-446655440614', 'manage_venues', 'Manage Venues', 'Create, edit, delete venues', '550e8400-e29b-41d4-a716-446655440711', true),
('550e8400-e29b-41d4-a716-446655440615', 'manage_permissions', 'Manage Permissions', 'Grant and revoke admin permissions', '550e8400-e29b-41d4-a716-446655440708', true),
('550e8400-e29b-41d4-a716-446655440616', 'view_system_logs', 'View System Logs', 'Access system logs and audit trails', '550e8400-e29b-41d4-a716-446655440708', true)
ON CONFLICT (id) DO NOTHING;

-- RSVP statuses
INSERT INTO rsvp_statuses (id, name, display_name, sort_order, color) VALUES 
('550e8400-e29b-41d4-a716-446655440301', 'yes', 'Attending', 1, '#27ae60'),
('550e8400-e29b-41d4-a716-446655440302', 'maybe', 'Maybe', 2, '#f39c12'),
('550e8400-e29b-41d4-a716-446655440303', 'no', 'Not Attending', 3, '#e74c3c')
ON CONFLICT (id) DO NOTHING;

-- Home/Away venue statuses
INSERT INTO home_away_statuses (id, name, display_name, description, sort_order) VALUES 
('550e8400-e29b-41d4-a716-446655440801', 'home', 'Home', 'Event at our home venue', 1),
('550e8400-e29b-41d4-a716-446655440802', 'away', 'Away', 'Event at opponent or external venue', 2),
('550e8400-e29b-41d4-a716-446655440803', 'neutral', 'Neutral Venue', 'Event at a neutral/shared venue', 3)
ON CONFLICT (id) DO NOTHING;

-- Event types for soccer
INSERT INTO event_types (id, sport_id, name, display_name, category, default_duration, requires_opponent) VALUES 
('550e8400-e29b-41d4-a716-446655440401', '550e8400-e29b-41d4-a716-446655440101', 'training', 'Training Session', 'practice', 90, false),
('550e8400-e29b-41d4-a716-446655440402', '550e8400-e29b-41d4-a716-446655440101', 'match', 'Match', 'match', 120, true),
('550e8400-e29b-41d4-a716-446655440403', '550e8400-e29b-41d4-a716-446655440101', 'meeting', 'Team Meeting', 'other', 60, false),
('550e8400-e29b-41d4-a716-446655440404', '550e8400-e29b-41d4-a716-446655440101', 'scrimmage', 'Scrimmage', 'practice', 90, false),
('550e8400-e29b-41d4-a716-446655440405', '550e8400-e29b-41d4-a716-446655440101', 'friendly', 'Friendly Match', 'match', 90, true),
('550e8400-e29b-41d4-a716-446655440406', '550e8400-e29b-41d4-a716-446655440101', 'fitness', 'Fitness Training', 'practice', 60, false)
ON CONFLICT (id) DO NOTHING;

-- Soccer positions
INSERT INTO positions (id, sport_id, name, display_name, abbreviation, sort_order) VALUES 
('550e8400-e29b-41d4-a716-446655440501', '550e8400-e29b-41d4-a716-446655440101', 'goalkeeper', 'Goalkeeper', 'GK', 1),
('550e8400-e29b-41d4-a716-446655440502', '550e8400-e29b-41d4-a716-446655440101', 'defender', 'Defender', 'DEF', 2),
('550e8400-e29b-41d4-a716-446655440503', '550e8400-e29b-41d4-a716-446655440101', 'midfielder', 'Midfielder', 'MID', 3),
('550e8400-e29b-41d4-a716-446655440504', '550e8400-e29b-41d4-a716-446655440101', 'forward', 'Forward', 'FWD', 4)
ON CONFLICT (id) DO NOTHING;

-- Notification types
INSERT INTO notification_types (id, name, display_name, description, category, default_enabled, is_system_notification) VALUES
('550e8400-e29b-41d4-a716-446655440901', 'event_created', 'Event Created', 'Notification when new events are created', 'event_management', true, false),
('550e8400-e29b-41d4-a716-446655440902', 'event_cancelled', 'Event Cancelled', 'Notification when events are cancelled', 'event_management', true, true),
('550e8400-e29b-41d4-a716-446655440903', 'event_updated', 'Event Updated', 'Notification when event details change', 'event_management', true, false),
('550e8400-e29b-41d4-a716-446655440904', 'rsvp_reminder', 'RSVP Reminder', 'Reminder to respond to event invitations', 'rsvp_system', true, false),
('550e8400-e29b-41d4-a716-446655440905', 'event_reminder', 'Event Reminder', 'Reminder about upcoming events', 'rsvp_system', true, false),
('550e8400-e29b-41d4-a716-446655440906', 'team_announcement', 'Team Announcement', 'General team announcements', 'team_updates', true, false),
('550e8400-e29b-41d4-a716-446655440907', 'roster_changes', 'Roster Changes', 'Notification of team roster updates', 'team_updates', false, false),
('550e8400-e29b-41d4-a716-446655440908', 'match_result', 'Match Results', 'Notification of match scores and results', 'team_updates', true, false)
ON CONFLICT (id) DO NOTHING;

-- Recurrence patterns
INSERT INTO recurrence_patterns (id, name, display_name, description) VALUES
('550e8400-e29b-41d4-a716-446655441001', 'weekly', 'Weekly', 'Repeats every week on the same day and time'),
('550e8400-e29b-41d4-a716-446655441002', 'biweekly', 'Every 2 Weeks', 'Repeats every two weeks on the same day'),
('550e8400-e29b-41d4-a716-446655441003', 'monthly', 'Monthly', 'Repeats monthly on the same date'),
('550e8400-e29b-41d4-a716-446655441004', 'monthly_by_day', 'Monthly by Day', 'Repeats monthly on the same day of week (e.g., first Monday)'),
('550e8400-e29b-41d4-a716-446655441005', 'custom', 'Custom Pattern', 'Custom recurrence pattern defined by interval')
ON CONFLICT (id) DO NOTHING;
