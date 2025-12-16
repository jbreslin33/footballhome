-- CASA Teams
-- Generated at: 2025-12-16T16:00:55.059Z

INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '0000611f-ee9e-4288-8d0e-d3250a6b7aac',
  'Adé United FC',
  '58049ce0-2df3-4c6f-8791-bac03a5a5280',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.245Z',
  '2025-12-16T15:59:49.245Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'c6d0a80d-bbd1-4506-83ed-271f6efab6d7',
  'Oaklyn United FC II',
  '89d12bd6-4687-499a-84b8-bd15cfc76bb5',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.245Z',
  '2025-12-16T15:59:49.245Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '54833b52-b5f9-4ed2-8b65-ce99d5d3aeb3',
  'Philadelphia Sierra Stars',
  '107cd7a3-447e-460e-85c9-39257a4008c4',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.246Z',
  '2025-12-16T15:59:49.246Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '2cc098cc-4723-4cbe-8892-4013b8d8da6a',
  'Persepolis FC',
  'b8d87d7b-5a29-498d-8009-0cf1e159ea2c',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.246Z',
  '2025-12-16T15:59:49.246Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '973cfd4d-e110-40f6-8bd4-8a730f7e5ca6',
  'Phoenix SCM',
  'a8c80a9c-f5e4-41a6-868c-ce862fc01d47',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.246Z',
  '2025-12-16T15:59:49.246Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '1d7fc937-ae4c-4084-8a53-ad1f6df662a2',
  'Philly BlackStars',
  'd36abbb8-b496-4f48-885f-feac11f869a7',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.246Z',
  '2025-12-16T15:59:49.246Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '6c9e49e0-1101-40bb-83fd-0f4a45f59d80',
  'Illyrians FC',
  '4162a632-99d8-4c8e-8d8a-99d5c886f29d',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.246Z',
  '2025-12-16T15:59:49.246Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '0ba654a6-3f06-4b64-8ff4-d988bc8aed4d',
  'Lighthouse Boys Club',
  '53fc92be-bae0-45dc-8e68-a2d3cb6b81e7',
  '9f708557-d2bf-4192-82f5-9ea58a3978cc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:49.246Z',
  '2025-12-16T15:59:49.246Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '6d10865d-cebf-47df-8be4-91941848efd9',
  'Persepolis United FC II',
  '8513743c-672a-4985-8103-575f958fb132',
  'bfa1da60-e9cf-4677-80ad-3c98a240f75f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:57.267Z',
  '2025-12-16T15:59:57.267Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '866dd3f1-efde-4c39-86a2-413c32fce962',
  'Phoenix SCR',
  'b551aad3-5b40-4fa4-897f-da9302a02ff4',
  'bfa1da60-e9cf-4677-80ad-3c98a240f75f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:57.268Z',
  '2025-12-16T15:59:57.268Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '32c5507a-28d4-425d-8e9e-2a8021d8d47c',
  'Philadelphia SC II',
  '5952c361-acd9-4e76-8837-58cea99937f1',
  'bfa1da60-e9cf-4677-80ad-3c98a240f75f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:57.268Z',
  '2025-12-16T15:59:57.268Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '40b68e65-765b-4ed3-88d8-5629903f1060',
  'Lighthouse Old Timers Club',
  '65cce3c8-1964-4832-8929-9047ad2a7ab2',
  'bfa1da60-e9cf-4677-80ad-3c98a240f75f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:57.268Z',
  '2025-12-16T15:59:57.268Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'a8da746e-cc91-487f-8c51-11514cd9ccdb',
  'Club de Futbol Armada',
  '3f74a3bc-8b77-4ad7-814e-d9e6041169fe',
  'bfa1da60-e9cf-4677-80ad-3c98a240f75f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-16T15:59:57.268Z',
  '2025-12-16T15:59:57.268Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
