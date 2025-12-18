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

-- RSVP change sources (how the RSVP was submitted)
INSERT INTO rsvp_change_sources (id, name, display_name, description, sort_order) VALUES 
('550e8400-e29b-41d4-a716-446655440311', 'app', 'Mobile/Web App', 'RSVP submitted through the app by the user', 1),
('550e8400-e29b-41d4-a716-446655440312', 'coach_entry', 'Coach Entry', 'RSVP entered by coach on behalf of player', 2),
('550e8400-e29b-41d4-a716-446655440313', 'magic_link', 'Email/SMS Link', 'RSVP submitted via magic link in email or SMS', 3),
('550e8400-e29b-41d4-a716-446655440314', 'bulk_import', 'Bulk Import', 'RSVP imported in bulk by admin', 4),
('550e8400-e29b-41d4-a716-446655440315', 'parent_entry', 'Parent Entry', 'RSVP entered by parent on behalf of player', 5)
ON CONFLICT (id) DO NOTHING;

-- Home/Away venue statuses
INSERT INTO home_away_statuses (id, name, display_name, description, sort_order) VALUES 
('550e8400-e29b-41d4-a716-446655440801', 'home', 'Home', 'Event at our home venue', 1),
('550e8400-e29b-41d4-a716-446655440802', 'away', 'Away', 'Event at opponent or external venue', 2),
('550e8400-e29b-41d4-a716-446655440803', 'neutral', 'Neutral Venue', 'Event at a neutral/shared venue', 3)
ON CONFLICT (id) DO NOTHING;

-- Admin levels (organizational hierarchy)
INSERT INTO admin_levels (id, name, display_name, description, sort_order) VALUES 
('550e8400-e29b-41d4-a716-446655440810', 'system', 'System Administrator', 'Full system access - manages all clubs, divisions, and users', 1),
('550e8400-e29b-41d4-a716-446655440811', 'league', 'League Administrator', 'Manages a specific league and its divisions', 2),
('550e8400-e29b-41d4-a716-446655440812', 'club', 'Club Administrator', 'Manages a specific club and its sport divisions', 3),
('550e8400-e29b-41d4-a716-446655440813', 'team', 'Team Administrator', 'Manages a specific team and its roster', 4)
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

-- System Settings (default platform configuration)
INSERT INTO system_settings (setting_key, setting_value, value_type, category, display_name, description, is_sensitive, is_system_setting) VALUES
('app_name', 'Football Home', 'string', 'general', 'Application Name', 'Display name for the platform', false, true),
('app_tagline', 'Manage Your Teams, Events & Players', 'string', 'general', 'Application Tagline', 'Subtitle for the platform', false, true),
('default_timezone', 'America/New_York', 'string', 'general', 'Default Timezone', 'Default timezone for dates and times', false, true),
('default_language', 'en', 'string', 'general', 'Default Language', 'Default language code (en, es, fr)', false, true),
('default_event_duration', '90', 'integer', 'events', 'Default Event Duration', 'Default duration for events in minutes', false, true),
('rsvp_deadline_hours', '4', 'integer', 'events', 'RSVP Deadline', 'Hours before event when RSVPs close', false, true),
('email_from_address', 'noreply@footballhome.com', 'string', 'email', 'Email From Address', 'Email address for outgoing emails', false, true),
('email_from_name', 'Football Home', 'string', 'email', 'Email From Name', 'Name displayed on outgoing emails', false, true),
('smtp_host', '', 'string', 'email', 'SMTP Host', 'SMTP server hostname', true, true),
('smtp_port', '587', 'integer', 'email', 'SMTP Port', 'SMTP server port', false, true),
('smtp_username', '', 'string', 'email', 'SMTP Username', 'SMTP authentication username', true, true),
('smtp_password', '', 'string', 'email', 'SMTP Password', 'SMTP authentication password', true, true),
('google_places_api_key', '', 'string', 'integrations', 'Google Places API Key', 'API key for Google Places integration', true, true),
('groupme_access_token', '', 'string', 'integrations', 'GroupMe Access Token', 'Access token for GroupMe API', true, true),
('max_roster_size', '35', 'integer', 'teams', 'Maximum Roster Size', 'Maximum players per team roster', false, true),
('min_roster_size', '11', 'integer', 'teams', 'Minimum Roster Size', 'Minimum players for active team', false, true),
('enable_public_registration', 'false', 'boolean', 'security', 'Enable Public Registration', 'Allow users to self-register', false, true),
('require_email_verification', 'true', 'boolean', 'security', 'Require Email Verification', 'Require email verification for new accounts', false, true),
('session_timeout_minutes', '1440', 'integer', 'security', 'Session Timeout', 'Minutes before user session expires', false, true),
('max_login_attempts', '5', 'integer', 'security', 'Max Login Attempts', 'Maximum failed login attempts before lockout', false, true)
ON CONFLICT (setting_key) DO NOTHING;

-- Feature Flags (enable/disable platform features)
INSERT INTO feature_flags (flag_key, flag_name, description, is_enabled, category, requires_restart) VALUES
('enable_availability_tracking', 'Availability Tracking', 'Track player availability for practices and matches', true, 'player_management', false),
('enable_medical_records', 'Medical Records', 'Track player medical status and injuries', true, 'player_management', false),
('enable_academic_tracking', 'Academic Status Tracking', 'Track student athlete academic eligibility', true, 'player_management', false),
('enable_match_lineups', 'Match Lineups', 'Create and manage match day lineups and formations', true, 'event_management', false),
('enable_attendance_tracking', 'Attendance Tracking', 'Automatic attendance tracking from RSVPs', true, 'event_management', false),
('enable_recurring_events', 'Recurring Events', 'Create events that repeat on a schedule', true, 'event_management', false),
('enable_notifications', 'Notifications', 'Email and push notifications for events', true, 'communication', false),
('enable_magic_links', 'Magic Login Links', 'Email-based passwordless authentication', true, 'security', false),
('enable_external_calendar_sync', 'Calendar Sync', 'Sync events with external calendars (Google, Apple)', false, 'integrations', false),
('enable_groupme_integration', 'GroupMe Integration', 'Sync with GroupMe chats for RSVP tracking', true, 'integrations', false),
('enable_data_export', 'Data Export', 'Allow users to export their data (CSV, PDF)', true, 'data_management', false),
('enable_bulk_import', 'Bulk Import', 'Import users/teams from CSV files', true, 'data_management', false),
('enable_api_access', 'API Access', 'Enable REST API for external integrations', true, 'integrations', true),
('enable_analytics', 'Analytics Dashboard', 'Show analytics and statistics dashboards', false, 'analytics', false),
('enable_payment_processing', 'Payment Processing', 'Process team fees and payments', false, 'finance', true),
('maintenance_mode', 'Maintenance Mode', 'Put platform in maintenance mode (read-only)', false, 'system', false)
ON CONFLICT (flag_key) DO NOTHING;
