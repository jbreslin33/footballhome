-- ========================================
-- TEAMS
-- ========================================
-- Generated: 2025-12-11T13:47:59.248Z
-- Source: https://apslsoccer.com/standings/
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/scripts/apsl-scraper/scrape-apsl.js
-- ========================================

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('093a47d2-4a1d-0005-6ab0-93e9e96847d7', 'Falcons FC', '093a47d2-4a1d-0004-6ab0-93e9e96847d7', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'Praia Kapital', '2a1d62b2-aa71-0004-a6eb-1657e21800bf', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('cd2f494d-83b2-0005-7009-2d86f0e05d52', 'Scrub Nation', 'cd2f494d-83b2-0004-7009-2d86f0e05d52', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('a9f395bc-b644-0005-057d-97f0afc4ca9c', 'Sete Setembro USA', 'a9f395bc-b644-0004-057d-97f0afc4ca9c', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('3b1d4171-c61d-0005-82fe-0b134f83622d', 'South Coast Union', '3b1d4171-c61d-0004-82fe-0b134f83622d', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('d6dd2763-bfe0-0005-76b6-634bdffc6f2a', 'Project Football', 'd6dd2763-bfe0-0004-76b6-634bdffc6f2a', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('aa0aab49-a007-0005-2697-8c6ceac5beb7', 'Invictus FC', 'aa0aab49-a007-0004-2697-8c6ceac5beb7', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('b8ec25f4-b6b4-0005-ce33-0da183347d70', 'Fitchburg FC', 'b8ec25f4-b6b4-0004-ce33-0da183347d70', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('a57bd844-e059-0005-1ea8-768f2a07223e', 'KO Elites', 'a57bd844-e059-0004-1ea8-768f2a07223e', '6718a93f-9f0c-0003-e639-c01213b5db55', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('265404b6-e493-0005-2586-5ba8bae74fcc', 'Glastonbury Celtic', '265404b6-e493-0004-2586-5ba8bae74fcc', '6718a93f-9f0c-0003-e639-c01213b5db55', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('7f09e1bb-ee7f-0005-739b-caf0f540a273', 'Wildcat FC', '7f09e1bb-ee7f-0004-739b-caf0f540a273', '6718a93f-9f0c-0003-e639-c01213b5db55', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('5c979af3-1b0d-0005-afb1-07227c8fb58c', 'Hermandad Connecticut', '5c979af3-1b0d-0004-afb1-07227c8fb58c', '6718a93f-9f0c-0003-e639-c01213b5db55', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('a9e2b1a8-5969-0005-f674-2f918d293250', 'NY Greek Americans', 'a9e2b1a8-5969-0004-f674-2f918d293250', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('49df0225-be54-0005-699c-ee6cd5da686b', 'Hoboken FC 1912', '49df0225-be54-0004-699c-ee6cd5da686b', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('cd0f7cdf-7018-0005-51d9-cafefed696e5', 'NY Pancyprian Freedoms', 'cd0f7cdf-7018-0004-51d9-cafefed696e5', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('fd2f4fc8-6cbd-0005-8199-96a395b40d55', 'Lansdowne Yonkers FC', 'fd2f4fc8-6cbd-0004-8199-96a395b40d55', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('77717fe0-fb4f-0005-cef3-260a0c447980', 'Leros SC', '77717fe0-fb4f-0004-cef3-260a0c447980', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'Doxa FCW', '68b50f22-dddc-0004-06ca-622f3a3a0ea4', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('c99ade72-80a1-0005-bb2a-e36057334cac', 'NY International FC', 'c99ade72-80a1-0004-bb2a-e36057334cac', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('bad8aee7-4cea-0005-8995-4a25b932936d', 'Richmond County FC', 'bad8aee7-4cea-0004-8995-4a25b932936d', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'Zum Schneider FC 03', '5951a8c4-ca8a-0004-8cb6-0cfaa8ed8a34', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('48a40f97-9111-0005-2e29-709bd3953df2', 'Central Park Rangers FC', '48a40f97-9111-0004-2e29-709bd3953df2', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('741624af-fbb6-0005-5186-2697c8c058e6', 'SC Vistula Garfield', '741624af-fbb6-0004-5186-2697c8c058e6', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'NY Athletic Club', '7fd5026d-e9e6-0004-c04a-3c9bdf5901b6', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('84a1029b-04c8-0005-5548-e180ad338d6b', 'WC Predators', '84a1029b-04c8-0004-5548-e180ad338d6b', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('0223b314-0973-0005-f017-a5527b76a814', 'Alloy Soccer Club', '0223b314-0973-0004-f017-a5527b76a814', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('c2402f6c-0036-0005-d453-d68637ee8277', 'Oaklyn United FC', 'c2402f6c-0036-0004-d453-d68637ee8277', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('5d95682c-0ec8-0005-0728-deae7986a2e0', 'Real Central NJ Soccer', '5d95682c-0ec8-0004-0728-deae7986a2e0', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('294a08ff-4f18-0005-c42b-a5fb0d5f0896', 'Philadelphia Heritage SC', '294a08ff-4f18-0004-c42b-a5fb0d5f0896', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('907ece9f-5926-0005-cff6-7672dec05648', 'Philadelphia Soccer Club', '907ece9f-5926-0004-cff6-7672dec05648', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('3dd92f09-4a7d-0005-c554-60df95cfb846', 'Vidas United FC', '3dd92f09-4a7d-0004-c554-60df95cfb846', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('f11cc01a-e8d3-0005-74f0-b00c38923236', 'GAK', 'f11cc01a-e8d3-0004-74f0-b00c38923236', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('d37eb44b-8e47-0005-9060-f0cbe96fe089', 'Lighthouse 1893 SC', 'd37eb44b-8e47-0004-9060-f0cbe96fe089', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, '/images/teams/logos/lighthouse-1893-sc.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('7288846b-402d-0005-9d60-70d5ffcc5588', 'Jersey Shore Boca', '7288846b-402d-0004-9d60-70d5ffcc5588', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('50720c09-2e57-0005-da39-afc85228aaa9', 'Sewell Old Boys FC', '50720c09-2e57-0004-da39-afc85228aaa9', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('77b6674f-d598-0005-fd48-227b9e088c41', 'Medford Strikers', '77b6674f-d598-0004-fd48-227b9e088c41', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('4975b02e-8e62-0005-2030-8e154013c759', 'Nova FC', '4975b02e-8e62-0004-2030-8e154013c759', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('8d88ffe1-06ae-0005-6f19-0e9432e55afa', 'VA Marauders FC', '8d88ffe1-06ae-0004-6f19-0e9432e55afa', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('5cb8a2b2-4ca8-0005-2d81-819249f89f0d', 'Wave FC', '5cb8a2b2-4ca8-0004-2d81-819249f89f0d', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('d8e57bbb-92dd-0005-95c3-76a8d99bb683', 'PFA EPSL', 'd8e57bbb-92dd-0004-95c3-76a8d99bb683', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('cf7f17f3-b83d-0005-856e-8a0b8da24008', 'Grove Soccer United', 'cf7f17f3-b83d-0004-856e-8a0b8da24008', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('226c892a-a28d-0005-ad0a-f9435e13f4e2', 'Christos FC', '226c892a-a28d-0004-ad0a-f9435e13f4e2', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('171f448b-97a3-0005-b875-35f9861c31b6', 'Delmarva Thunder', '171f448b-97a3-0004-b875-35f9861c31b6', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('7425cb8d-f81d-0005-8a67-7aa5c9dd6023', 'PW Nova', '7425cb8d-f81d-0004-8a67-7aa5c9dd6023', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('f05b54ff-8886-0005-29cd-ff42c703f657', 'Terminus FC', 'f05b54ff-8886-0004-29cd-ff42c703f657', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('55bd7a24-ba77-0005-81a4-2f5bfb50c614', 'Majestic SC', '55bd7a24-ba77-0004-81a4-2f5bfb50c614', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('07e8c5da-df90-0005-7ef3-b55105901be2', 'Prima FC', '07e8c5da-df90-0004-7ef3-b55105901be2', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('ec1718e1-142d-0005-ef5c-b49f0f144a3c', 'Peachtree FC', 'ec1718e1-142d-0004-ef5c-b49f0f144a3c', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('268164a2-111d-0005-9ea6-900cd6c9f197', 'Bel Calcio FC', '268164a2-111d-0004-9ea6-900cd6c9f197', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('3ae0fc91-9acf-0005-06a7-2af9ccf19b51', 'Buckhead SC', '3ae0fc91-9acf-0004-06a7-2af9ccf19b51', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'Alliance SC', '6778fbca-ca21-0004-a2e2-d5b9dfc49df6', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('d2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'SC Gwinnett', 'd2c80f1f-3aa2-0004-9951-cacab62cb9fc', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'Lithonia City FC', 'fcccc73d-ebb9-0004-64c9-ee520c7672f8', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

