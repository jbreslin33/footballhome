-- ========================================
-- LEAGUES (Hardcoded)
-- ========================================
-- These league IDs are used by scrapers as foreign keys
-- DO NOT change these IDs - they are referenced throughout the codebase
-- ========================================

-- APSL League
INSERT INTO leagues (id, name, display_name, sport_id, season, description, logo_url, website, contact_email, contact_phone, is_active)
VALUES (
  '00000000-0000-0000-0001-000000000001',
  'APSL',
  'American Premier Soccer League',
  '550e8400-e29b-41d4-a716-446655440101',
  NULL,
  'American Premier Soccer League - Adult recreational soccer',
  NULL,
  'https://apslsoccer.com',
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  website = EXCLUDED.website,
  is_active = EXCLUDED.is_active;

-- CASA League
INSERT INTO leagues (id, name, display_name, sport_id, season, description, logo_url, website, contact_email, contact_phone, is_active)
VALUES (
  '00000000-0000-0000-0001-000000000002',
  'CASA',
  'CASA Soccer Leagues',
  '550e8400-e29b-41d4-a716-446655440101',
  NULL,
  'CASA Soccer Leagues - Philadelphia area adult soccer',
  NULL,
  'https://casasoccerleagues.com',
  NULL,
  NULL,
  true
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  website = EXCLUDED.website,
  is_active = EXCLUDED.is_active;
