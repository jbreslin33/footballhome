-- APSL League
-- Generated at: 2025-12-17T15:40:45.028Z

INSERT INTO leagues (id, name, display_name, sport_id, season, description, logo_url, website, contact_email, contact_phone, is_active, created_at, updated_at)
VALUES (
  '00000000-0000-0000-0001-000000000001',
  'APSL',
  'American Premier Soccer League',
  '550e8400-e29b-41d4-a716-446655440101',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T15:38:29.758Z',
  '2025-12-17T15:38:29.758Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  season = EXCLUDED.season,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  website = EXCLUDED.website,
  contact_email = EXCLUDED.contact_email,
  contact_phone = EXCLUDED.contact_phone,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
