-- CASA Teams
-- Generated at: 2025-12-16T19:19:35.611Z

INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '1ae28486-6def-431e-8d1c-4af9ea56a3fd',
  'Adé United FC',
  'e682b07d-a81a-4a9c-85b3-a9f6b4d22403',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T19:18:38.245Z',
  '2025-12-16T19:18:38.245Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '3bf9c8b4-1edf-42d6-8b8f-63d248c1ea92',
  'Oaklyn United FC II',
  'd0f58266-b474-4d1f-8221-7e47736867a0',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T19:18:38.246Z',
  '2025-12-16T19:18:38.246Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '986cc709-88f7-4923-8404-ec24350a0bcd',
  'Philadelphia Sierra Stars',
  'f35b58d7-6586-40f4-8ac9-da0fe8c02126',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T19:18:38.246Z',
  '2025-12-16T19:18:38.246Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '79571455-9a4b-4e3e-8a40-bc5fefa21a1c',
  'Persepolis FC',
  'c32fbb43-2070-416b-80ff-9b24228e95d6',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T19:18:38.246Z',
  '2025-12-16T19:18:38.246Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '7b5fcaec-c079-4132-8087-de29ad6ff2db',
  'Phoenix SCM',
  '99af25a0-d197-414b-89fe-6839d8de852b',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T19:18:38.246Z',
  '2025-12-16T19:18:38.246Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '62f6fce0-9646-4dc4-802b-fbd4bf066b0e',
  'Philly BlackStars',
  'e301f3dd-ebc7-49c0-8039-3638a4c45294',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T19:18:38.246Z',
  '2025-12-16T19:18:38.246Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '7bf6867b-ae73-42ee-82dc-ce4b3502b828',
  'Illyrians FC',
  '6a033594-743d-4150-8c28-0b19dce38563',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T19:18:38.246Z',
  '2025-12-16T19:18:38.246Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'de13b049-e584-4672-84e3-a24668a88c57',
  'Lighthouse Boys Club',
  '105ab0d0-6d89-4e8b-8c4b-ce637c610e1c',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T19:18:38.247Z',
  '2025-12-16T19:18:38.247Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '003dd334-88bf-4682-857f-b0571daa11ac',
  'Persepolis United FC II',
  '0e55b2d6-1109-472d-8bb3-a15b1c53ef7a',
  'bfa1da60-e9cf-4677-80ad-3c98a240f75f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T19:18:44.243Z',
  '2025-12-16T19:18:44.243Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'b8dcec03-3f55-44cc-838a-d50739f9b342',
  'Phoenix SCR',
  '56c8c4d4-a468-4c91-8dfd-89078e05a424',
  'bfa1da60-e9cf-4677-80ad-3c98a240f75f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T19:18:44.243Z',
  '2025-12-16T19:18:44.243Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '089b437b-dcc8-4004-8136-0b2efeec1a5e',
  'Philadelphia SC II',
  '0e98871f-efed-42f2-8610-33a88dfffa24',
  'bfa1da60-e9cf-4677-80ad-3c98a240f75f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T19:18:44.243Z',
  '2025-12-16T19:18:44.243Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'cbb53b2c-26ce-488f-8c6f-3c589fadddbe',
  'Lighthouse Old Timers Club',
  '6362c82a-4383-4d2f-8ecc-8b0e87ab1788',
  'bfa1da60-e9cf-4677-80ad-3c98a240f75f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T19:18:44.243Z',
  '2025-12-16T19:18:44.243Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'ff392ab7-84c1-4113-8e15-5e9c15eee3cb',
  'Club de Futbol Armada',
  '92dfb780-1b14-4127-855b-2abedb3fc592',
  'bfa1da60-e9cf-4677-80ad-3c98a240f75f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T19:18:44.243Z',
  '2025-12-16T19:18:44.243Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
