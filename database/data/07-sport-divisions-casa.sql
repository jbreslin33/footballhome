-- CASA Sport Divisions
-- Generated at: 2025-12-16T16:00:55.059Z

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '58049ce0-2df3-4c6f-8791-bac03a5a5280',
  'a3c030a1-81c5-4c4e-8150-c90b89d50d66',
  '550e8400-e29b-41d4-a716-446655440101',
  'Adé United FC',
  'Adé United FC',
  'ad-united-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.245Z',
  '2025-12-16T15:59:49.245Z'
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
  '89d12bd6-4687-499a-84b8-bd15cfc76bb5',
  'aaee9b96-1eb7-4edf-851d-fe7e9ab764cf',
  '550e8400-e29b-41d4-a716-446655440101',
  'Oaklyn United FC II',
  'Oaklyn United FC II',
  'oaklyn-united-fc-ii',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.245Z',
  '2025-12-16T15:59:49.245Z'
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
  '107cd7a3-447e-460e-85c9-39257a4008c4',
  'ae3183e0-c581-40a9-8a86-dcd387c002a2',
  '550e8400-e29b-41d4-a716-446655440101',
  'Philadelphia Sierra Stars',
  'Philadelphia Sierra Stars',
  'philadelphia-sierra-stars',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.246Z',
  '2025-12-16T15:59:49.246Z'
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
  'b8d87d7b-5a29-498d-8009-0cf1e159ea2c',
  '0c584a6b-5a57-4e40-8211-085f97a0c955',
  '550e8400-e29b-41d4-a716-446655440101',
  'Persepolis FC',
  'Persepolis FC',
  'persepolis-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.246Z',
  '2025-12-16T15:59:49.246Z'
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
  'a8c80a9c-f5e4-41a6-868c-ce862fc01d47',
  '866a4f40-6218-43d5-8f54-c02a3c0c682e',
  '550e8400-e29b-41d4-a716-446655440101',
  'Phoenix SCM',
  'Phoenix SCM',
  'phoenix-scm',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.246Z',
  '2025-12-16T15:59:49.246Z'
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
  'd36abbb8-b496-4f48-885f-feac11f869a7',
  'a4f93014-00f2-4d18-8087-5c6923c6618a',
  '550e8400-e29b-41d4-a716-446655440101',
  'Philly BlackStars',
  'Philly BlackStars',
  'philly-blackstars',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.246Z',
  '2025-12-16T15:59:49.246Z'
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
  '4162a632-99d8-4c8e-8d8a-99d5c886f29d',
  '7201fb67-e47a-4943-8695-b61dba13b32e',
  '550e8400-e29b-41d4-a716-446655440101',
  'Illyrians FC',
  'Illyrians FC',
  'illyrians-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.246Z',
  '2025-12-16T15:59:49.246Z'
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
  '53fc92be-bae0-45dc-8e68-a2d3cb6b81e7',
  'f3d0358a-871e-4246-8872-edcacb3ecb0d',
  '550e8400-e29b-41d4-a716-446655440101',
  'Lighthouse Boys Club',
  'Lighthouse Boys Club',
  'lighthouse-boys-club',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.246Z',
  '2025-12-16T15:59:49.246Z'
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
  '8513743c-672a-4985-8103-575f958fb132',
  '4aae8682-ae06-447d-8429-b5ba1ce98225',
  '550e8400-e29b-41d4-a716-446655440101',
  'Persepolis United FC II',
  'Persepolis United FC II',
  'persepolis-united-fc-ii',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:57.267Z',
  '2025-12-16T15:59:57.267Z'
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
  'b551aad3-5b40-4fa4-897f-da9302a02ff4',
  '2b169aae-5fab-47da-849d-5cffcc568a85',
  '550e8400-e29b-41d4-a716-446655440101',
  'Phoenix SCR',
  'Phoenix SCR',
  'phoenix-scr',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:57.268Z',
  '2025-12-16T15:59:57.268Z'
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
  '5952c361-acd9-4e76-8837-58cea99937f1',
  'f82c71f4-4ef8-4280-858a-dc20faf05761',
  '550e8400-e29b-41d4-a716-446655440101',
  'Philadelphia SC II',
  'Philadelphia SC II',
  'philadelphia-sc-ii',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:57.268Z',
  '2025-12-16T15:59:57.268Z'
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
  '65cce3c8-1964-4832-8929-9047ad2a7ab2',
  'e9478fd5-433f-41d0-80ef-7a10145c9587',
  '550e8400-e29b-41d4-a716-446655440101',
  'Lighthouse Old Timers Club',
  'Lighthouse Old Timers Club',
  'lighthouse-old-timers-club',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:57.268Z',
  '2025-12-16T15:59:57.268Z'
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
  '3f74a3bc-8b77-4ad7-814e-d9e6041169fe',
  '69d1dd77-ad38-489c-840c-6eab211e87f0',
  '550e8400-e29b-41d4-a716-446655440101',
  'Club de Futbol Armada',
  'Club de Futbol Armada',
  'club-de-futbol-armada',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:57.268Z',
  '2025-12-16T15:59:57.268Z'
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
