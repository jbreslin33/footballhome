-- CASA Sport Divisions
-- Generated at: 2025-12-17T21:57:48.406Z

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
  '2025-12-17T21:56:03.570Z',
  '2025-12-17T21:56:03.570Z'
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
  '2025-12-17T21:56:03.570Z',
  '2025-12-17T21:56:03.570Z'
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
  '2025-12-17T21:56:03.570Z',
  '2025-12-17T21:56:03.570Z'
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
  '2025-12-17T21:56:03.570Z',
  '2025-12-17T21:56:03.570Z'
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
  '2025-12-17T21:56:03.570Z',
  '2025-12-17T21:56:03.570Z'
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
  '2025-12-17T21:56:03.571Z',
  '2025-12-17T21:56:03.571Z'
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
  '2025-12-17T21:56:03.571Z',
  '2025-12-17T21:56:03.571Z'
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
  '2025-12-17T21:56:03.571Z',
  '2025-12-17T21:56:03.571Z'
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
  '2025-12-17T21:56:36.803Z',
  '2025-12-17T21:56:36.803Z'
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
  '2025-12-17T21:56:36.803Z',
  '2025-12-17T21:56:36.803Z'
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
  '2025-12-17T21:56:36.803Z',
  '2025-12-17T21:56:36.803Z'
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
  '2025-12-17T21:56:36.803Z',
  '2025-12-17T21:56:36.803Z'
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
  '2025-12-17T21:56:36.803Z',
  '2025-12-17T21:56:36.803Z'
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
  'e8ff467a-48b7-457e-88b2-1f668a3c0f8e',
  '76670ffd-987c-41c2-8d37-0a7a08258864',
  '550e8400-e29b-41d4-a716-446655440101',
  'South Shore FC Soccer',
  'South Shore FC Soccer',
  'south-shore-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:07.581Z',
  '2025-12-17T21:57:07.581Z'
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
  '0feca70f-790d-4940-8336-1e522d7ab152',
  '2cf80496-5976-42f9-8db5-85c2119d7b28',
  '550e8400-e29b-41d4-a716-446655440101',
  'Jaguars United FC Soccer',
  'Jaguars United FC Soccer',
  'jaguars-united-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:07.581Z',
  '2025-12-17T21:57:07.581Z'
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
  'cf995e5b-82e0-43c8-8da9-749f73c35f14',
  'd31a3bfc-b0fd-4ac6-8bd1-26f78823e2c6',
  '550e8400-e29b-41d4-a716-446655440101',
  'Strictly Nos Fc Soccer',
  'Strictly Nos Fc Soccer',
  'strictly-nos-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:07.581Z',
  '2025-12-17T21:57:07.581Z'
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
  '0c0f068d-f69e-4e8e-8204-4b860f643b08',
  '77b1938b-8847-423c-862f-460065a57755',
  '550e8400-e29b-41d4-a716-446655440101',
  'BCFC All Stars Soccer',
  'BCFC All Stars Soccer',
  'bcfc-all-stars',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:07.581Z',
  '2025-12-17T21:57:07.581Z'
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
  '83a0786a-b0fe-4d6e-84cc-ab0b3e49ff75',
  '32313bee-73f7-4409-8c23-0af984caf69c',
  '550e8400-e29b-41d4-a716-446655440101',
  'Flatley FC Soccer',
  'Flatley FC Soccer',
  'flatley-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:07.581Z',
  '2025-12-17T21:57:07.581Z'
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
  '4bfcd095-ff89-4186-8137-07d565a0d184',
  '8e3aa175-c61e-4f1f-8a76-b3865aeef3a1',
  '550e8400-e29b-41d4-a716-446655440101',
  'Gambeta FC Soccer',
  'Gambeta FC Soccer',
  'gambeta-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:07.581Z',
  '2025-12-17T21:57:07.581Z'
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
  'c56dd188-c905-46bd-821f-3064053641e1',
  '6275e5bc-5378-4749-8242-097f28b8ee4f',
  '550e8400-e29b-41d4-a716-446655440101',
  'Kutztown Men''s Soccer Soccer',
  'Kutztown Men''s Soccer Soccer',
  'kutztown-mens-soccer',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:22.679Z',
  '2025-12-17T21:57:22.679Z'
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
  '8d6fb2ef-76a7-474a-85af-cd5dfff69825',
  '64b8ac68-e58b-4774-88ae-f38661d6ed95',
  '550e8400-e29b-41d4-a716-446655440101',
  'Alloy Soccer Club Reserves Soccer',
  'Alloy Soccer Club Reserves Soccer',
  'alloy-soccer-club-reserves',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:22.679Z',
  '2025-12-17T21:57:22.679Z'
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
  'dbc2c55f-5881-40f4-8e27-ceb96db2a042',
  '17667562-e396-4caa-8823-e738418ba859',
  '550e8400-e29b-41d4-a716-446655440101',
  'Keystone Elite Soccer',
  'Keystone Elite Soccer',
  'keystone-elite',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:22.679Z',
  '2025-12-17T21:57:22.679Z'
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
  '32f51b8b-7093-4d3a-8247-a744cda827bc',
  'c519762b-41e8-422f-8037-2d539f0c6019',
  '550e8400-e29b-41d4-a716-446655440101',
  'F&M FC Soccer',
  'F&M FC Soccer',
  'fm-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:22.679Z',
  '2025-12-17T21:57:22.679Z'
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
  'f5e07938-017e-4389-843e-ab0eb2991fad',
  'bb989b3a-3b07-4364-89f7-5b82c90c946f',
  '550e8400-e29b-41d4-a716-446655440101',
  'Lancaster City FC Soccer',
  'Lancaster City FC Soccer',
  'lancaster-city-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:22.679Z',
  '2025-12-17T21:57:22.679Z'
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
  '67594902-a33d-4f3a-80a6-3b10eca3924b',
  'a856fcc9-fee6-4a8f-831b-80cb2c5143a6',
  '550e8400-e29b-41d4-a716-446655440101',
  'Alaso FC Soccer',
  'Alaso FC Soccer',
  'alaso-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:37.810Z',
  '2025-12-17T21:57:37.810Z'
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
  '5b650522-22ca-42ce-8e73-011c55283773',
  'f4f8adda-8933-40c6-8617-e62e7450057f',
  '550e8400-e29b-41d4-a716-446655440101',
  'FeelsGood FC Soccer',
  'FeelsGood FC Soccer',
  'feelsgood-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:37.810Z',
  '2025-12-17T21:57:37.810Z'
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
  '792c0c5c-0ddf-457f-89bb-63025f75d279',
  'd78fa7b3-dd60-4ff7-8f13-8964a9b1b140',
  '550e8400-e29b-41d4-a716-446655440101',
  'Rondo Football Club Soccer',
  'Rondo Football Club Soccer',
  'rondo-football-club',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:37.810Z',
  '2025-12-17T21:57:37.810Z'
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
  '7d9eb7ff-cce8-4297-82ab-0a6d583bc645',
  'dbfa4c4a-296a-4785-8c4e-4a59730d1bbb',
  '550e8400-e29b-41d4-a716-446655440101',
  'Jersey Shore Boca Reserves Soccer',
  'Jersey Shore Boca Reserves Soccer',
  'jersey-shore-boca-reserves',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:37.810Z',
  '2025-12-17T21:57:37.810Z'
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
  '334b1bcc-06ee-4bf8-8094-c5374ae91dd1',
  '488b6ec6-4dde-4947-8481-11a025226660',
  '550e8400-e29b-41d4-a716-446655440101',
  'Monmouth Light FC Soccer',
  'Monmouth Light FC Soccer',
  'monmouth-light-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:37.811Z',
  '2025-12-17T21:57:37.811Z'
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
  '1588e454-9706-43cf-88b7-ee034d0adbdb',
  '723f8c18-918c-49f3-8d28-86b4d8546c17',
  '550e8400-e29b-41d4-a716-446655440101',
  'Milan Football Club Soccer',
  'Milan Football Club Soccer',
  'milan-football-club',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:37.811Z',
  '2025-12-17T21:57:37.811Z'
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
  '6b48354e-9d51-4e0a-8bfc-a91a196bd38e',
  '280f03c6-3da1-465e-8556-6692a1c3e747',
  '550e8400-e29b-41d4-a716-446655440101',
  'Princeton International FC Soccer',
  'Princeton International FC Soccer',
  'princeton-international-fc',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:37.811Z',
  '2025-12-17T21:57:37.811Z'
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
  'd2014b31-94c7-4d41-8562-8b394088b32d',
  '111c0b0e-5f2d-4107-8de8-2b36b676ce15',
  '550e8400-e29b-41d4-a716-446655440101',
  'MFC Stars Soccer',
  'MFC Stars Soccer',
  'mfc-stars',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:37.811Z',
  '2025-12-17T21:57:37.811Z'
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
  'f69d0113-7c84-42c9-8ad4-6f310bdc39c8',
  '4aed7032-ce11-496f-8b0b-33016acfe67a',
  '550e8400-e29b-41d4-a716-446655440101',
  'Real Central NJ II Soccer',
  'Real Central NJ II Soccer',
  'real-central-nj-ii',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:37.811Z',
  '2025-12-17T21:57:37.811Z'
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
  '43ac2ffe-f9c7-4266-85b9-a91350722967',
  '5ee52cb7-d376-404c-85b3-9a1dae4423fd',
  '550e8400-e29b-41d4-a716-446655440101',
  'Jersey Shore Hounds Soccer',
  'Jersey Shore Hounds Soccer',
  'jersey-shore-hounds',
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T21:57:37.811Z',
  '2025-12-17T21:57:37.811Z'
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
