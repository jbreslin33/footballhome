-- Lighthouse 1893 SC - Minimal Complete Team Data
-- This file contains essential data for Lighthouse 1893 SC including:
-- - Admin user (jbreslin@footballhome.org) with player, coach, and admin roles
-- - Club, sport division, and team records
-- - Required supporting data (leagues, divisions, positions, etc.)

-- ================================================================
-- SUPPORTING DATA REQUIRED FOR LIGHTHOUSE
-- ================================================================

-- Ensure required sports exist
INSERT INTO sports (id, name, display_name)
VALUES ('550e8400-e29b-41d4-a716-446655440101', 'Soccer', 'Soccer')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name;

-- Ensure required leagues exist
INSERT INTO leagues (id, name, display_name, sport_id, is_active)
VALUES ('0e4dfe0a-4757-0002-dc8e-92734ef56a74', 'American Premier Soccer League', 'American Premier Soccer League', '550e8400-e29b-41d4-a716-446655440101', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name;

-- Ensure required league conferences exist
INSERT INTO league_conferences (id, league_id, name, display_name, slug, is_active)
VALUES ('0e4dfe0a-4757-0003-dc8e-92734ef56a74', '0e4dfe0a-4757-0002-dc8e-92734ef56a74', 'Delaware River Conference', 'Delaware River Conference', 'delaware-river-conference', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name;

-- Ensure required league divisions exist
INSERT INTO league_divisions (id, conference_id, name, display_name, slug, tier, is_active)
VALUES ('0e4dfe0a-4757-0004-dc8e-92734ef56a74', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', 'Division 1', 'Division 1', 'division-1', 1, true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name;

-- ================================================================
-- LIGHTHOUSE CLUB AND TEAM DATA
-- ================================================================

-- Club record
INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('d37eb44b-8e47-0003-9060-f0cbe96fe089', 'Lighthouse 1893 SC', 'Lighthouse 1893 SC', 'lighthouse-1893-sc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  slug = EXCLUDED.slug,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

-- Sport division record
INSERT INTO sport_divisions (id, sport_id, club_id, name, display_name, slug, is_active)
VALUES (
  'd37eb44b-8e47-0004-9060-f0cbe96fe089',
  '550e8400-e29b-41d4-a716-446655440101',
  'd37eb44b-8e47-0003-9060-f0cbe96fe089',
  'Lighthouse 1893 SC Soccer',
  'Lighthouse 1893 SC Soccer',
  'lighthouse-1893-sc-soccer',
  true
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

-- Team record  
INSERT INTO teams (id, name, division_id, league_division_id, is_active)
VALUES (
  'd37eb44b-8e47-0005-9060-f0cbe96fe089',
  'Lighthouse 1893 SC',
  'd37eb44b-8e47-0004-9060-f0cbe96fe089',
  '0e4dfe0a-4757-0004-dc8e-92734ef56a74',
  true
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

-- ================================================================
-- ADMIN USER WITH MULTI-ROLE SUPPORT
-- ================================================================

-- Create jbreslin@footballhome.org as admin user
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

-- Assign admin role
INSERT INTO admins (id, admin_level, notes, created_at, updated_at)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'system',
    'System administrator with full access',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO UPDATE SET
    admin_level = EXCLUDED.admin_level,
    notes = EXCLUDED.notes,
    updated_at = CURRENT_TIMESTAMP;

-- Add as coach
INSERT INTO coaches (id, coaching_license, license_expiry, years_experience, bio, created_at, updated_at)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'USSF B License',
    '2026-12-31',
    15,
    'Experienced coach with 15 years in youth soccer development. Focuses on technical skills and positive team culture.',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO UPDATE SET
    coaching_license = EXCLUDED.coaching_license,
    license_expiry = EXCLUDED.license_expiry,
    years_experience = EXCLUDED.years_experience,
    bio = EXCLUDED.bio,
    updated_at = CURRENT_TIMESTAMP;

-- Add as player
INSERT INTO players (id, preferred_position_id, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    '550e8400-e29b-41d4-a716-446655440503',
    180,
    75,
    'right',
    85,
    'Veteran player who also coaches. Strong tactical awareness and leadership on the field.',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO UPDATE SET
    preferred_position_id = EXCLUDED.preferred_position_id,
    height_cm = EXCLUDED.height_cm,
    weight_kg = EXCLUDED.weight_kg,
    dominant_foot = EXCLUDED.dominant_foot,
    player_rating = EXCLUDED.player_rating,
    notes = EXCLUDED.notes,
    updated_at = CURRENT_TIMESTAMP;

-- Assign as head coach to Lighthouse team
INSERT INTO team_coaches (id, team_id, coach_id, coach_role, is_primary, is_active)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d69c',
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

-- Assign as player to Lighthouse team
INSERT INTO team_players (id, team_id, player_id, jersey_number, is_captain, is_active, position_id)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d70c',
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