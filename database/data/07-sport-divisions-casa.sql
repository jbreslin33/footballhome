-- CASA Sport Divisions
-- Generated at: 2025-12-16T17:15:28.075Z

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'e682b07d-a81a-4a9c-85b3-a9f6b4d22403',
  'd4919747-10b7-480b-8992-daaa784d5a13',
  '550e8400-e29b-41d4-a716-446655440101',
  'Adé United FC Soccer',
  'Adé United FC Soccer',
  'ad-united-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T17:14:27.351Z',
  '2025-12-16T17:14:27.351Z'
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
  'd0f58266-b474-4d1f-8221-7e47736867a0',
  '7020080f-095e-487e-8989-f484f640900d',
  '550e8400-e29b-41d4-a716-446655440101',
  'Oaklyn United FC II Soccer',
  'Oaklyn United FC II Soccer',
  'oaklyn-united-fc-ii',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T17:14:27.352Z',
  '2025-12-16T17:14:27.352Z'
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
  'f35b58d7-6586-40f4-8ac9-da0fe8c02126',
  '5846de6d-db0a-411f-877d-d5434ce689f8',
  '550e8400-e29b-41d4-a716-446655440101',
  'Philadelphia Sierra Stars Soccer',
  'Philadelphia Sierra Stars Soccer',
  'philadelphia-sierra-stars',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T17:14:27.352Z',
  '2025-12-16T17:14:27.352Z'
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
  'c32fbb43-2070-416b-80ff-9b24228e95d6',
  '45166977-281d-4a83-8e36-1d73e13cafe5',
  '550e8400-e29b-41d4-a716-446655440101',
  'Persepolis FC Soccer',
  'Persepolis FC Soccer',
  'persepolis-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T17:14:27.352Z',
  '2025-12-16T17:14:27.352Z'
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
  '99af25a0-d197-414b-89fe-6839d8de852b',
  '6ea90c99-a637-4811-865f-ed0441331bb2',
  '550e8400-e29b-41d4-a716-446655440101',
  'Phoenix SCM Soccer',
  'Phoenix SCM Soccer',
  'phoenix-scm',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T17:14:27.352Z',
  '2025-12-16T17:14:27.352Z'
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
  'e301f3dd-ebc7-49c0-8039-3638a4c45294',
  '48158d16-cbd1-4236-8f8e-c0b5524a171f',
  '550e8400-e29b-41d4-a716-446655440101',
  'Philly BlackStars Soccer',
  'Philly BlackStars Soccer',
  'philly-blackstars',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T17:14:27.352Z',
  '2025-12-16T17:14:27.352Z'
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
  '6a033594-743d-4150-8c28-0b19dce38563',
  '35a3bcbd-7397-47ee-836e-61e8f79a7f9f',
  '550e8400-e29b-41d4-a716-446655440101',
  'Illyrians FC Soccer',
  'Illyrians FC Soccer',
  'illyrians-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T17:14:27.352Z',
  '2025-12-16T17:14:27.352Z'
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
  '105ab0d0-6d89-4e8b-8c4b-ce637c610e1c',
  '555c3845-32c1-4d0f-8408-a73af2d063f1',
  '550e8400-e29b-41d4-a716-446655440101',
  'Lighthouse Boys Club Soccer',
  'Lighthouse Boys Club Soccer',
  'lighthouse-boys-club',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T17:14:27.352Z',
  '2025-12-16T17:14:27.352Z'
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
  '2025-12-16T17:14:35.213Z',
  '2025-12-16T17:14:35.213Z'
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
  '2025-12-16T17:14:35.213Z',
  '2025-12-16T17:14:35.213Z'
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
  '2025-12-16T17:14:35.213Z',
  '2025-12-16T17:14:35.213Z'
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
  '2025-12-16T17:14:35.213Z',
  '2025-12-16T17:14:35.213Z'
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
  '2025-12-16T17:14:35.213Z',
  '2025-12-16T17:14:35.213Z'
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
