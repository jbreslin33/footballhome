-- CASA Teams
-- Generated at: 2025-12-17T13:30:51.939Z

INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
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
  '2025-12-17T13:29:57.757Z',
  '2025-12-17T13:29:57.757Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
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
  '2025-12-17T13:29:57.758Z',
  '2025-12-17T13:29:57.758Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
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
  '2025-12-17T13:29:57.758Z',
  '2025-12-17T13:29:57.758Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
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
  '2025-12-17T13:29:57.758Z',
  '2025-12-17T13:29:57.758Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
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
  '2025-12-17T13:29:57.758Z',
  '2025-12-17T13:29:57.758Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
