-- CASA Teams
-- Generated at: 2025-12-17T18:01:25.957Z

INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'da9e701d-7752-495a-8145-fe967b40c0d3',
  'Adé United FC',
  'e682b07d-a81a-4a9c-85b3-a9f6b4d22403',
  'd5d544d1-1f35-4b7d-80e0-67c5fd63258f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:02.079Z',
  '2025-12-17T18:01:02.079Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '158e321e-2dd5-4926-82ce-c31822bde965',
  'Oaklyn United FC II',
  'd0f58266-b474-4d1f-8221-7e47736867a0',
  'd5d544d1-1f35-4b7d-80e0-67c5fd63258f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:02.079Z',
  '2025-12-17T18:01:02.079Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '3a2468dd-a31c-456a-88a9-fe7699d2b079',
  'Philadelphia Sierra Stars',
  'f35b58d7-6586-40f4-8ac9-da0fe8c02126',
  'd5d544d1-1f35-4b7d-80e0-67c5fd63258f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:02.080Z',
  '2025-12-17T18:01:02.080Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'e1fe8b60-1ff9-46ae-8274-feccfd31eb8c',
  'Persepolis FC',
  'c32fbb43-2070-416b-80ff-9b24228e95d6',
  'd5d544d1-1f35-4b7d-80e0-67c5fd63258f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:02.080Z',
  '2025-12-17T18:01:02.080Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'aad58707-7310-4751-86c5-e403a28757f4',
  'Phoenix SCM',
  '99af25a0-d197-414b-89fe-6839d8de852b',
  'd5d544d1-1f35-4b7d-80e0-67c5fd63258f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:02.080Z',
  '2025-12-17T18:01:02.080Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'bbef7779-4ba7-4939-891e-6d6f96a34577',
  'Philly BlackStars',
  'e301f3dd-ebc7-49c0-8039-3638a4c45294',
  'd5d544d1-1f35-4b7d-80e0-67c5fd63258f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:02.080Z',
  '2025-12-17T18:01:02.080Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '28134f76-23f8-4e68-80ce-9f9ab2a3942f',
  'Illyrians FC',
  '6a033594-743d-4150-8c28-0b19dce38563',
  'd5d544d1-1f35-4b7d-80e0-67c5fd63258f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:02.080Z',
  '2025-12-17T18:01:02.080Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '57d88568-993d-4411-8aa3-6244ca7ff704',
  'Lighthouse Boys Club',
  '105ab0d0-6d89-4e8b-8c4b-ce637c610e1c',
  'd5d544d1-1f35-4b7d-80e0-67c5fd63258f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:02.080Z',
  '2025-12-17T18:01:02.080Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '4b2e5bca-3534-463e-8304-4ea9f4136646',
  'Persepolis United FC II',
  '0e55b2d6-1109-472d-8bb3-a15b1c53ef7a',
  '311fe53c-88df-4efe-8fa9-6f397992b826',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:08.112Z',
  '2025-12-17T18:01:08.112Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'c72c8463-2d38-455d-87d3-1afcd4da53c7',
  'Phoenix SCR',
  '56c8c4d4-a468-4c91-8dfd-89078e05a424',
  '311fe53c-88df-4efe-8fa9-6f397992b826',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:08.112Z',
  '2025-12-17T18:01:08.112Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '0033b87c-9650-4c9d-80b3-69ec4751c7cc',
  'Philadelphia SC II',
  '0e98871f-efed-42f2-8610-33a88dfffa24',
  '311fe53c-88df-4efe-8fa9-6f397992b826',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:08.112Z',
  '2025-12-17T18:01:08.112Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',
  'Lighthouse Old Timers Club',
  '6362c82a-4383-4d2f-8ecc-8b0e87ab1788',
  '311fe53c-88df-4efe-8fa9-6f397992b826',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:08.113Z',
  '2025-12-17T18:01:08.113Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '443c2788-3747-4197-8835-8861e67dbaae',
  'Club de Futbol Armada',
  '92dfb780-1b14-4127-855b-2abedb3fc592',
  '311fe53c-88df-4efe-8fa9-6f397992b826',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:08.113Z',
  '2025-12-17T18:01:08.113Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '895ff6df-959f-4a46-80c9-fbef6eed5b78',
  'South Shore FC',
  'e8ff467a-48b7-457e-88b2-1f668a3c0f8e',
  '9f1b6ea8-e94f-482c-8231-b8dcb2ddf278',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:14.023Z',
  '2025-12-17T18:01:14.023Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '9795925d-4af7-449a-86fd-e27cdfe9eced',
  'Jaguars United FC',
  '0feca70f-790d-4940-8336-1e522d7ab152',
  '9f1b6ea8-e94f-482c-8231-b8dcb2ddf278',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:14.023Z',
  '2025-12-17T18:01:14.023Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '16b6860e-6657-4bc8-87a5-9b35d0bcb2a7',
  'Strictly Nos Fc',
  'cf995e5b-82e0-43c8-8da9-749f73c35f14',
  '9f1b6ea8-e94f-482c-8231-b8dcb2ddf278',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:14.023Z',
  '2025-12-17T18:01:14.023Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '8b6ce6db-f6d5-4e0d-8524-ce184200c6c9',
  'BCFC All Stars',
  '0c0f068d-f69e-4e8e-8204-4b860f643b08',
  '9f1b6ea8-e94f-482c-8231-b8dcb2ddf278',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:14.023Z',
  '2025-12-17T18:01:14.023Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '3ded57de-85a3-41e5-8b3e-87ea2a84de13',
  'Flatley FC',
  '83a0786a-b0fe-4d6e-84cc-ab0b3e49ff75',
  '9f1b6ea8-e94f-482c-8231-b8dcb2ddf278',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:14.023Z',
  '2025-12-17T18:01:14.023Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '2bf2f14b-8e84-44ec-825c-bc6031d385de',
  'Gambeta FC',
  '4bfcd095-ff89-4186-8137-07d565a0d184',
  '9f1b6ea8-e94f-482c-8231-b8dcb2ddf278',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:14.023Z',
  '2025-12-17T18:01:14.023Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '5541a60c-6517-4e66-8c25-a513298fd487',
  'Kutztown Men''s Soccer',
  'c56dd188-c905-46bd-821f-3064053641e1',
  '78c7666c-a894-4cd7-8256-3a04b98228cb',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:20.000Z',
  '2025-12-17T18:01:20.000Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'c3bfdfa9-ce51-4af4-8c64-778323eff661',
  'Alloy Soccer Club Reserves',
  '8d6fb2ef-76a7-474a-85af-cd5dfff69825',
  '78c7666c-a894-4cd7-8256-3a04b98228cb',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:20.000Z',
  '2025-12-17T18:01:20.000Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '9dbe9c4a-6108-44fc-898d-33defc0155da',
  'Keystone Elite',
  'dbc2c55f-5881-40f4-8e27-ceb96db2a042',
  '78c7666c-a894-4cd7-8256-3a04b98228cb',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:20.000Z',
  '2025-12-17T18:01:20.000Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '1b742914-50d5-4105-81b9-f980ec0fb53e',
  'F&M FC',
  '32f51b8b-7093-4d3a-8247-a744cda827bc',
  '78c7666c-a894-4cd7-8256-3a04b98228cb',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:20.000Z',
  '2025-12-17T18:01:20.000Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '525d469e-dbdf-475c-8bb3-ecddc849cfe0',
  'Lancaster City FC',
  'f5e07938-017e-4389-843e-ab0eb2991fad',
  '78c7666c-a894-4cd7-8256-3a04b98228cb',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:20.001Z',
  '2025-12-17T18:01:20.001Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'dda012cd-f081-48df-8903-d997d9fa6f96',
  'Alaso FC',
  '67594902-a33d-4f3a-80a6-3b10eca3924b',
  'b2cf2684-c283-4c5f-8518-4cc259041f44',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:25.932Z',
  '2025-12-17T18:01:25.932Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'a3120f9e-c8ef-4cd8-8014-92f5e67fbfbc',
  'FeelsGood FC',
  '5b650522-22ca-42ce-8e73-011c55283773',
  'b2cf2684-c283-4c5f-8518-4cc259041f44',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:25.932Z',
  '2025-12-17T18:01:25.932Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '5e07fe31-75ac-4d95-8224-c762b2411566',
  'Rondo Football Club',
  '792c0c5c-0ddf-457f-89bb-63025f75d279',
  'b2cf2684-c283-4c5f-8518-4cc259041f44',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:25.932Z',
  '2025-12-17T18:01:25.932Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '2da3f1d4-be7f-4cff-89d8-fea82a640d06',
  'Jersey Shore Boca Reserves',
  '7d9eb7ff-cce8-4297-82ab-0a6d583bc645',
  'b2cf2684-c283-4c5f-8518-4cc259041f44',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:25.932Z',
  '2025-12-17T18:01:25.932Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'd9b9ff4c-052c-4c9f-8d2d-483f66125de4',
  'Monmouth Light FC',
  '334b1bcc-06ee-4bf8-8094-c5374ae91dd1',
  'b2cf2684-c283-4c5f-8518-4cc259041f44',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:25.932Z',
  '2025-12-17T18:01:25.932Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'cc98cc5e-8b54-4c55-8564-a7ebeaccc68b',
  'Milan Football Club',
  '1588e454-9706-43cf-88b7-ee034d0adbdb',
  'b2cf2684-c283-4c5f-8518-4cc259041f44',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:25.932Z',
  '2025-12-17T18:01:25.932Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '7708a49e-8512-43b2-8b85-13e98a4af318',
  'Princeton International FC',
  '6b48354e-9d51-4e0a-8bfc-a91a196bd38e',
  'b2cf2684-c283-4c5f-8518-4cc259041f44',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:25.932Z',
  '2025-12-17T18:01:25.932Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  '3e87d61d-3093-41a0-888a-83f66923a34b',
  'MFC Stars',
  'd2014b31-94c7-4d41-8562-8b394088b32d',
  'b2cf2684-c283-4c5f-8518-4cc259041f44',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:25.932Z',
  '2025-12-17T18:01:25.932Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'bb5768e2-fac3-42e0-8d07-f18a63fb2278',
  'Real Central NJ II',
  'f69d0113-7c84-42c9-8ad4-6f310bdc39c8',
  'b2cf2684-c283-4c5f-8518-4cc259041f44',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:25.932Z',
  '2025-12-17T18:01:25.932Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
INSERT INTO teams (id, name, sport_division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  'eb1511a3-cc96-4387-80c1-c8e470338ddc',
  'Jersey Shore Hounds',
  '43ac2ffe-f9c7-4266-85b9-a91350722967',
  'b2cf2684-c283-4c5f-8518-4cc259041f44',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  true,
  '2025-12-17T18:01:25.932Z',
  '2025-12-17T18:01:25.932Z'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;
