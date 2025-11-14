-- Lighthouse 1893 SC - Complete Team Data
-- This file contains all data needed for Lighthouse 1893 SC including:
-- - Club, sport division, and team records
-- - All players and their details
-- - All coaches and their assignments
-- - Admin user (jbreslin@footballhome.org)
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
  updated_at = CURRENT_TIMESTAMP;

-- Sport division record
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('d37eb44b-8e47-0004-9060-f0cbe96fe089', 'd37eb44b-8e47-0003-9060-f0cbe96fe089', '550e8400-e29b-41d4-a716-446655440101', 'Lighthouse 1893 SC Soccer', 'Lighthouse 1893 SC Soccer', 'lighthouse-1893-sc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

-- Team record
INSERT INTO teams (id, name, division_id, league_division_id, season, is_active)
VALUES ('d37eb44b-8e47-0005-9060-f0cbe96fe089', 'Lighthouse 1893 SC', 'd37eb44b-8e47-0004-9060-f0cbe96fe089', '0e4dfe0a-4757-0004-dc8e-92734ef56a74', '2024-2025', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  updated_at = CURRENT_TIMESTAMP;

-- ================================================================
-- ADMIN USER (from existing lighthouse1893sc.sql)
-- ================================================================

-- Create jbreslin@footballhome.org as admin user
INSERT INTO users (id, email, password_hash, name, is_active)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'jbreslin@footballhome.org',
    '$2a$12$O5zBhYOYyB8ZvGcxo1s8L.hgOjNwj7Wr6x9Jp1SYQJwMeOE3gkMte',
    'James Breslin',
    true
)
ON CONFLICT (email) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    name = EXCLUDED.name,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

-- Assign admin role to jbreslin
INSERT INTO admins (id, user_id, admin_level, granted_by, granted_at, is_active)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d64c',
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'system',
    '77d77471-1250-47e0-81ab-d4626595d63c',
    CURRENT_TIMESTAMP,
    true
)
ON CONFLICT (user_id, admin_level) DO UPDATE SET
    granted_by = EXCLUDED.granted_by,
    granted_at = EXCLUDED.granted_at,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

-- Add jbreslin as a coach
INSERT INTO coaches (id, coaching_license, license_expiry, years_experience, certifications, specializations, bio, created_at, updated_at)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'USSF B License',
    '2026-12-31',
    15,
    ARRAY['USSF B License', 'Youth Safety Certification', 'First Aid/CPR'],
    ARRAY['Youth Development', 'Technical Skills', 'Team Strategy'],
    'Experienced coach with 15 years in youth soccer development. Focuses on technical skills and positive team culture.',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO UPDATE SET
    coaching_license = EXCLUDED.coaching_license,
    license_expiry = EXCLUDED.license_expiry,
    years_experience = EXCLUDED.years_experience,
    certifications = EXCLUDED.certifications,
    specializations = EXCLUDED.specializations,
    bio = EXCLUDED.bio,
    updated_at = CURRENT_TIMESTAMP;

-- Add jbreslin as a player
INSERT INTO players (id, preferred_position_id, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    (SELECT id FROM positions WHERE name = 'midfielder' LIMIT 1),
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

-- ================================================================
-- LIGHTHOUSE PLAYERS FROM APSL DATA
-- ================================================================

-- All Lighthouse 1893 SC players (extracted from APSL data)
INSERT INTO players (id, notes)
VALUES ('01aca9b0-ae64-0006-e96d-7e69a00ffec4', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('e7b6e3e7-4b6c-0006-c471-183c094b8b51', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('326e6bc0-e8ed-0006-62b1-b4e94dd6a079', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('1089a0ee-8eb6-0006-d3d5-20bf6ba6ee7a', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('52737162-6e42-0006-4a28-377d5fbdb22a', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('769b5796-c33c-0006-69b6-bc37abae18bf', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('f5dfe66e-8e08-0006-ff59-107bf2898b1a', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('dd7d3571-d69e-0006-7979-7a2ce126dac6', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('326e8020-b576-0006-761c-7e233e2fbba2', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('97b0d643-5b54-0006-be6b-066460c214b1', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('f9e55725-38a4-0006-4da9-32f792737ce3', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('8194c8f3-e9b5-0006-1b83-b544991ee783', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('6f56fb40-d2e7-0006-962f-ecf2b2125067', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('68b0bb11-c853-0006-7aca-7a06730bac1c', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('49385a1c-d37b-0006-f0c9-dac164502d9b', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('df029c0e-28c8-0006-5da8-18ab2837dcaa', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('ce93b48a-1f6b-0006-e2c1-47799cfcfff5', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('b128734e-616a-0006-94f9-740b7dab4b61', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('3cb5f823-9e5d-0006-e69f-35b97baec652', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('aecf8394-3dea-0006-c777-facfc9af77f9', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('4d8fb2ee-241e-0006-98a8-9f87f7b4be5a', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('57ae3eff-d209-0006-409d-b97ebabee860', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('1058e8dc-f991-0006-3421-156e9aae5a81', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('70b36e4b-b5bd-0006-dd9c-f58dfcd5c239', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('23dd5826-bb2e-0006-4dd3-59927f01b65e', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('87d3f035-c0d4-0006-ee7b-0637fb8b40fd', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('f57ec0ec-24ef-0006-a2f7-0aad81711c11', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO players (id, notes)
VALUES ('0af0fa43-db02-0006-b625-bf47c0eb6099', 'APSL player - position: not specified')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

-- ================================================================
-- LIGHTHOUSE TEAM PLAYERS FROM APSL DATA
-- ================================================================

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('0486bc2f-580e-0007-ac0f-d8b4773dcfbe', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '01aca9b0-ae64-0006-e96d-7e69a00ffec4', 5, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('c0265713-75f6-0007-0153-081d7e5cc272', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'e7b6e3e7-4b6c-0006-c471-183c094b8b51', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('e163565b-aa0b-0007-4e6a-b8503ba0564c', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '326e6bc0-e8ed-0006-62b1-b4e94dd6a079', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('6500d820-5ac0-0007-4a0a-09327ed238a3', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '1089a0ee-8eb6-0006-d3d5-20bf6ba6ee7a', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('396eb7c5-f7c3-0007-b29a-b5531cda400a', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '52737162-6e42-0006-4a28-377d5fbdb22a', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('9bb42ec8-0ea6-0007-0c6c-517d218f945a', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '769b5796-c33c-0006-69b6-bc37abae18bf', 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('3b5e79c0-f891-0007-3a44-8015dc0f0861', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'f5dfe66e-8e08-0006-ff59-107bf2898b1a', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('c5606c0b-4dce-0007-3d1c-8ddc4d0faf94', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'dd7d3571-d69e-0006-7979-7a2ce126dac6', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('0ffba232-0d64-0007-0d39-1ef36ed16cf4', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '326e8020-b576-0006-761c-7e233e2fbba2', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('bcfdeb7b-8845-0007-8431-353b91df14aa', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '97b0d643-5b54-0006-be6b-066460c214b1', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('2d2467ef-3991-0007-77f9-73c8bf46bcaf', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'f9e55725-38a4-0006-4da9-32f792737ce3', 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('457d3c4e-b1b1-0007-ef78-c6d7bdc19a9a', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '8194c8f3-e9b5-0006-1b83-b544991ee783', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('b57b663e-1cd8-0007-1854-bba8164f4310', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '6f56fb40-d2e7-0006-962f-ecf2b2125067', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('8bc89c0a-1fe3-0007-eac6-4e304111f663', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '68b0bb11-c853-0006-7aca-7a06730bac1c', 2, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('35f0c9d1-28f9-0007-baf6-86b75688a83b', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '49385a1c-d37b-0006-f0c9-dac164502d9b', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('63aa6e90-01f3-0007-46de-4dbaa24c1aa4', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'df029c0e-28c8-0006-5da8-18ab2837dcaa', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('78980bf3-259a-0007-9df9-4a7826711e27', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'ce93b48a-1f6b-0006-e2c1-47799cfcfff5', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('1e4511a1-c63d-0007-45c0-a20670581da6', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'b128734e-616a-0006-94f9-740b7dab4b61', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('3cc13982-1faf-0007-5f6c-0203895037c9', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '3cb5f823-9e5d-0006-e69f-35b97baec652', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('946e21dc-7d17-0007-de3f-9a7dcb11cc7f', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'aecf8394-3dea-0006-c777-facfc9af77f9', 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('358bda46-2207-0007-4a50-073267fac9cd', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '4d8fb2ee-241e-0006-98a8-9f87f7b4be5a', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('e9b4c63f-609d-0007-60b9-a128af691d27', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '57ae3eff-d209-0006-409d-b97ebabee860', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('4f301633-2290-0007-472e-862fd79b230d', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '1058e8dc-f991-0006-3421-156e9aae5a81', 2, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('a585affa-b23c-0007-b6c2-e2c29b6c319b', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '70b36e4b-b5bd-0006-dd9c-f58dfcd5c239', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('b9412ffc-06e1-0007-6c69-29978d57011a', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '23dd5826-bb2e-0006-4dd3-59927f01b65e', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('c7937ab7-c141-0007-73eb-55f7b69794e0', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '87d3f035-c0d4-0006-ee7b-0637fb8b40fd', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('927d2aee-c7fb-0007-386f-03f53bcb2bc1', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'f57ec0ec-24ef-0006-a2f7-0aad81711c11', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES ('4455d5de-0458-0007-ec7d-41b2a8c2c9ee', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '0af0fa43-db02-0006-b625-bf47c0eb6099', NULL, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

-- Create jbreslin as a player for testing (keeping separate from APSL data)
INSERT INTO players (id, notes)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'James Breslin - Admin/Player/Coach for testing'
)
ON CONFLICT (id) DO UPDATE SET
    notes = EXCLUDED.notes,
    updated_at = CURRENT_TIMESTAMP;

-- Assign jbreslin as player to Lighthouse team (jersey #10)
INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d66c',
    'd37eb44b-8e47-0005-9060-f0cbe96fe089',
    '77d77471-1250-47e0-81ab-d4626595d65c',
    10,
    true
)
ON CONFLICT (team_id, player_id) DO UPDATE SET
    jersey_number = EXCLUDED.jersey_number,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

-- ================================================================
-- PLACEHOLDER FOR EXTRACTED COACH DATA
-- (Will be populated with actual APSL data)
-- ================================================================

-- Create jbreslin as a coach for testing  
INSERT INTO coaches (id, notes)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'James Breslin - Admin/Player/Coach for testing'
)
ON CONFLICT (id) DO UPDATE SET
    notes = EXCLUDED.notes,
    updated_at = CURRENT_TIMESTAMP;

-- Assign jbreslin as assistant coach to Lighthouse team
INSERT INTO team_coaches (id, team_id, coach_id, coach_role, is_primary, is_active)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d68c',
    'd37eb44b-8e47-0005-9060-f0cbe96fe089',
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'assistant_coach',
    false,
    true
)
ON CONFLICT (team_id, coach_id) DO UPDATE SET
    coach_role = EXCLUDED.coach_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

-- Assign jbreslin as head coach of Lighthouse team
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
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

-- Assign jbreslin as player on Lighthouse team
INSERT INTO team_players (id, team_id, player_id, jersey_number, is_captain, is_active, position_id)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d70c',
    'd37eb44b-8e47-0005-9060-f0cbe96fe089',
    '77d77471-1250-47e0-81ab-d4626595d63c',
    10,
    true,
    true,
    (SELECT id FROM positions WHERE name = 'midfielder' LIMIT 1)
)
ON CONFLICT (team_id, player_id) DO UPDATE SET
    jersey_number = EXCLUDED.jersey_number,
    is_captain = EXCLUDED.is_captain,
    is_active = EXCLUDED.is_active,
    position_id = EXCLUDED.position_id,
    updated_at = CURRENT_TIMESTAMP;