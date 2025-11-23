-- ========================================
-- LIGHTHOUSE - USERS AND TEAM ASSIGNMENTS
-- ========================================
-- Creates admin user (jbreslin@footballhome.org) with multiple roles:
-- - System admin with full permissions
-- - Coach for all Lighthouse teams
-- - Player for all Lighthouse teams

-- Create admin user
-- Password: 1893Soccer! (bcrypt hash)
INSERT INTO users (id, email, password_hash, first_name, last_name, is_active)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'jbreslin@footballhome.org',
    '$2a$12$kDODGedFzf1BpWdjdCjHo.X3t5VwU4K9/KhlSDlymmHadhGuJslHS',
    'James',
    'Breslin',
    true
)
ON CONFLICT (email) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

-- Assign system admin role
INSERT INTO admins (id, admin_level, notes)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'system',
    'System administrator with full access'
)
ON CONFLICT (id) DO UPDATE SET
    admin_level = EXCLUDED.admin_level,
    notes = EXCLUDED.notes,
    updated_at = CURRENT_TIMESTAMP;

-- Grant all system permissions to admin
INSERT INTO admin_permissions (admin_id, permission_id)
SELECT 
    '77d77471-1250-47e0-81ab-d4626595d63c',
    id
FROM permissions
WHERE is_system_permission = true
ON CONFLICT (admin_id, permission_id) DO NOTHING;

-- Add coach entity
INSERT INTO coaches (id, coaching_license, license_expiry, years_experience, bio)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'USSF B License',
    '2026-12-31',
    15,
    'Experienced coach with 15 years in youth soccer development. Focuses on technical skills and positive team culture.'
)
ON CONFLICT (id) DO UPDATE SET
    coaching_license = EXCLUDED.coaching_license,
    license_expiry = EXCLUDED.license_expiry,
    years_experience = EXCLUDED.years_experience,
    bio = EXCLUDED.bio,
    updated_at = CURRENT_TIMESTAMP;

-- Add player entity
INSERT INTO players (id, preferred_position_id, height_cm, weight_kg, dominant_foot, player_rating, notes)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    '550e8400-e29b-41d4-a716-446655440503',
    180,
    75,
    'right',
    85,
    'Veteran player who also coaches. Strong tactical awareness and leadership on the field.'
)
ON CONFLICT (id) DO UPDATE SET
    preferred_position_id = EXCLUDED.preferred_position_id,
    height_cm = EXCLUDED.height_cm,
    weight_kg = EXCLUDED.weight_kg,
    dominant_foot = EXCLUDED.dominant_foot,
    player_rating = EXCLUDED.player_rating,
    notes = EXCLUDED.notes,
    updated_at = CURRENT_TIMESTAMP;

-- ========================================
-- TEAM ASSIGNMENTS
-- ========================================

-- Lighthouse 1893 SC (APSL team) - Head Coach
INSERT INTO team_coaches (team_id, coach_id, coach_role, is_primary, is_active)
VALUES (
    'd37eb44b-8e47-0005-9060-f0cbe96fe089',
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'head_coach',
    true,
    true
)
ON CONFLICT (team_id, coach_id) DO UPDATE SET
    coach_role = EXCLUDED.coach_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active;

-- Lighthouse 1893 SC - Player
INSERT INTO team_players (team_id, player_id, jersey_number, is_captain, is_active, position_id)
VALUES (
    'd37eb44b-8e47-0005-9060-f0cbe96fe089',
    '77d77471-1250-47e0-81ab-d4626595d63c',
    10,
    true,
    true,
    '550e8400-e29b-41d4-a716-446655440503'
)
ON CONFLICT (team_id, player_id) DO UPDATE SET
    jersey_number = EXCLUDED.jersey_number,
    is_captain = EXCLUDED.is_captain,
    is_active = EXCLUDED.is_active,
    position_id = EXCLUDED.position_id;

-- Lighthouse Boys Club - Head Coach
INSERT INTO team_coaches (team_id, coach_id, coach_role, is_primary, is_active)
VALUES (
    'bbb00000-0000-0000-0000-000000000001',
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'head_coach',
    true,
    true
)
ON CONFLICT (team_id, coach_id) DO UPDATE SET
    coach_role = EXCLUDED.coach_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active;

-- Lighthouse Boys Club - Player
INSERT INTO team_players (team_id, player_id, is_active)
VALUES (
    'bbb00000-0000-0000-0000-000000000001',
    '77d77471-1250-47e0-81ab-d4626595d63c',
    true
)
ON CONFLICT (team_id, player_id) DO UPDATE SET
    is_active = EXCLUDED.is_active;

-- Lighthouse Old Timers Club - Head Coach
INSERT INTO team_coaches (team_id, coach_id, coach_role, is_primary, is_active)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'head_coach',
    true,
    true
)
ON CONFLICT (team_id, coach_id) DO UPDATE SET
    coach_role = EXCLUDED.coach_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active;

-- Lighthouse Old Timers Club - Player
INSERT INTO team_players (team_id, player_id, is_active)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    '77d77471-1250-47e0-81ab-d4626595d63c',
    true
)
ON CONFLICT (team_id, player_id) DO UPDATE SET
    is_active = EXCLUDED.is_active;
