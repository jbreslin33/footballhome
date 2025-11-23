-- ========================================
-- LIGHTHOUSE 1893 SC - CLUB SETUP
-- ========================================
-- Creates the Lighthouse 1893 SC club, divisions, and main APSL team
-- This is the foundational club data before adding additional teams

-- Prerequisites league data (APSL)
INSERT INTO leagues (id, name, display_name, sport_id, is_active)
VALUES ('0e4dfe0a-4757-0002-dc8e-92734ef56a74', 'American Premier Soccer League', 'American Premier Soccer League', '550e8400-e29b-41d4-a716-446655440101', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO league_conferences (id, league_id, name, display_name, slug, is_active)
VALUES ('0e4dfe0a-4757-0003-dc8e-92734ef56a74', '0e4dfe0a-4757-0002-dc8e-92734ef56a74', 'Delaware River Conference', 'Delaware River Conference', 'delaware-river-conference', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO league_divisions (id, conference_id, name, display_name, slug, tier, is_active)
VALUES ('0e4dfe0a-4757-0004-dc8e-92734ef56a74', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', 'Division 1', 'Division 1', 'division-1', 1, true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

-- Create Lighthouse club
INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('d37eb44b-8e47-0003-9060-f0cbe96fe089', 'Lighthouse 1893 SC', 'Lighthouse 1893 SC', 'lighthouse-1893-sc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  slug = EXCLUDED.slug,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

-- Create soccer sport division for Lighthouse
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

-- Create main APSL team (Lighthouse 1893 SC)
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
