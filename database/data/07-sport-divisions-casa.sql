-- CASA Sport Divisions
-- Generated at: 2025-12-17T13:30:51.939Z

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '0e55b2d6-1109-472d-8bb3-a15b1c53ef7a',
  'd4dd8adc-da97-4fd1-8813-df055df744db',
  '550e8400-e29b-41d4-a716-446655440101',
  'Persepolis United FC II Soccer',
  'Persepolis United FC II Soccer',
  'persepolis-united-fc-ii',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:29:57.757Z',
  '2025-12-17T13:29:57.757Z'
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '56c8c4d4-a468-4c91-8dfd-89078e05a424',
  'd4c522c8-5fd7-4f1f-8492-d17235f5ad06',
  '550e8400-e29b-41d4-a716-446655440101',
  'Phoenix SCR Soccer',
  'Phoenix SCR Soccer',
  'phoenix-scr',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:29:57.758Z',
  '2025-12-17T13:29:57.758Z'
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '0e98871f-efed-42f2-8610-33a88dfffa24',
  '35e7bde5-fe74-4e1b-8ebc-279fc2c1bfe2',
  '550e8400-e29b-41d4-a716-446655440101',
  'Philadelphia SC II Soccer',
  'Philadelphia SC II Soccer',
  'philadelphia-sc-ii',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:29:57.758Z',
  '2025-12-17T13:29:57.758Z'
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '6362c82a-4383-4d2f-8ecc-8b0e87ab1788',
  '0cbce3a7-0e0b-45a6-8233-ee4eac102978',
  '550e8400-e29b-41d4-a716-446655440101',
  'Lighthouse Old Timers Club Soccer',
  'Lighthouse Old Timers Club Soccer',
  'lighthouse-old-timers-club',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:29:57.758Z',
  '2025-12-17T13:29:57.758Z'
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '92dfb780-1b14-4127-855b-2abedb3fc592',
  '5aa3d6f5-68d5-4218-8e49-566b6485639d',
  '550e8400-e29b-41d4-a716-446655440101',
  'Club de Futbol Armada Soccer',
  'Club de Futbol Armada Soccer',
  'club-de-futbol-armada',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T13:29:57.758Z',
  '2025-12-17T13:29:57.758Z'
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;
