-- ========================================
-- TEAMS
-- ========================================
-- Generated: 2025-12-03T18:47:35.056Z
-- Source: https://apslsoccer.com/standings/
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/scripts/apsl-scraper/scrape-apsl.js
-- ========================================

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('093a47d2-4a1d-0005-6ab0-93e9e96847d7', 'Falcons FC', '093a47d2-4a1d-0004-6ab0-93e9e96847d7', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/03/21/12/u_Falcons_FC_Logo1_1742587156174_1_245305.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'Praia Kapital', '2a1d62b2-aa71-0004-a6eb-1657e21800bf', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, 'https://app.teampass.com/mediacontent//2024/08/13/10/Praia_Kapital_80_243106.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('cd2f494d-83b2-0005-7009-2d86f0e05d52', 'Scrub Nation', 'cd2f494d-83b2-0004-7009-2d86f0e05d52', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/08/21/10/u_Scrub_1755796096678_1_80271343_247647.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('a9f395bc-b644-0005-057d-97f0afc4ca9c', 'Sete Setembro USA', 'a9f395bc-b644-0004-057d-97f0afc4ca9c', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, 'https://app.teampass.com/mediacontent//2023/04/20/09/Sete Setembro_235664.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('3b1d4171-c61d-0005-82fe-0b134f83622d', 'South Coast Union', '3b1d4171-c61d-0004-82fe-0b134f83622d', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/02/24/10/u_south_coast_union_logo__1__1740421275204_1_244950.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('d6dd2763-bfe0-0005-76b6-634bdffc6f2a', 'Project Football', 'd6dd2763-bfe0-0004-76b6-634bdffc6f2a', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, 'https://app.teampass.com/mediacontent//2024/12/11/10/PF_244117.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('aa0aab49-a007-0005-2697-8c6ceac5beb7', 'Invictus FC', 'aa0aab49-a007-0004-2697-8c6ceac5beb7', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/06/06/09/u_Invictus_1749228528014_1_246265.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('b8ec25f4-b6b4-0005-ce33-0da183347d70', 'Fitchburg FC', 'b8ec25f4-b6b4-0004-ce33-0da183347d70', '282679d6-baa5-0003-cac6-a8ec79406f30', '2024-2025', true, 'https://app.teampass.com/mediacontent//2024/07/24/15/F_F_C_2896_242912.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('a57bd844-e059-0005-1ea8-768f2a07223e', 'KO Elites', 'a57bd844-e059-0004-1ea8-768f2a07223e', '6718a93f-9f0c-0003-e639-c01213b5db55', '2024-2025', true, 'https://app.teampass.com/mediacontent//2022/08/20/15/81752260_614480686045826_2182093774371422208_n_230163.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('265404b6-e493-0005-2586-5ba8bae74fcc', 'Glastonbury Celtic', '265404b6-e493-0004-2586-5ba8bae74fcc', '6718a93f-9f0c-0003-e639-c01213b5db55', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/02/20/17/u_Celtic_1740100402142_1_244922.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('7f09e1bb-ee7f-0005-739b-caf0f540a273', 'Wildcat FC', '7f09e1bb-ee7f-0004-739b-caf0f540a273', '6718a93f-9f0c-0003-e639-c01213b5db55', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/01/15/14/u_Logo_1736979699693_1_244479.PNG')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('5c979af3-1b0d-0005-afb1-07227c8fb58c', 'Hermandad Connecticut', '5c979af3-1b0d-0004-afb1-07227c8fb58c', '6718a93f-9f0c-0003-e639-c01213b5db55', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/01/05/13/u_0e48b279_436c_42bf_8295_c6e52ef9550c_1736112177435_1_244309.jpeg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('a9e2b1a8-5969-0005-f674-2f918d293250', 'NY Greek Americans', 'a9e2b1a8-5969-0004-f674-2f918d293250', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, 'https://app.teampass.com/mediacontent//2022/08/20/15/1385542_530758417002357_263896856_n_230170.jpeg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('49df0225-be54-0005-699c-ee6cd5da686b', 'Hoboken FC 1912', '49df0225-be54-0004-699c-ee6cd5da686b', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, 'https://app.teampass.com/mediacontent//2023/02/28/00/HCF_circle_-_white_231278_235098.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('cd0f7cdf-7018-0005-51d9-cafefed696e5', 'NY Pancyprian Freedoms', 'cd0f7cdf-7018-0004-51d9-cafefed696e5', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, 'https://app.teampass.com/mediacontent//2022/08/12/03/NY_Pancyprian_Freedoms_logo_229973.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('fd2f4fc8-6cbd-0005-8199-96a395b40d55', 'Lansdowne Yonkers FC', 'fd2f4fc8-6cbd-0004-8199-96a395b40d55', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, 'https://app.teampass.com/mediacontent//2023/04/20/09/Lansdowne Yonkers FC_235666.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('77717fe0-fb4f-0005-cef3-260a0c447980', 'Leros SC', '77717fe0-fb4f-0004-cef3-260a0c447980', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/07/03/07/u_Leros_1751554635731_1_246975.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'Doxa FCW', '68b50f22-dddc-0004-06ca-622f3a3a0ea4', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, 'https://app.teampass.com/mediacontent//2022/09/29/14/Doxa_230155_230722.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('c99ade72-80a1-0005-bb2a-e36057334cac', 'NY International FC', 'c99ade72-80a1-0004-bb2a-e36057334cac', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, 'https://app.teampass.com/mediacontent//2022/08/08/21/STAR_229908.jpeg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('bad8aee7-4cea-0005-8995-4a25b932936d', 'Richmond County FC', 'bad8aee7-4cea-0004-8995-4a25b932936d', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, 'https://app.teampass.com/mediacontent//2023/09/14/11/Richmond-NEW_239003.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'Zum Schneider FC 03', '5951a8c4-ca8a-0004-8cb6-0cfaa8ed8a34', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, 'https://app.teampass.com/mediacontent//2022/08/08/18/Screenshot 2022-08-08 180027_229893.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('741624af-fbb6-0005-5186-2697c8c058e6', 'SC Vistula Garfield', '741624af-fbb6-0004-5186-2697c8c058e6', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, 'https://app.teampass.com/mediacontent//2023/07/21/16/Vistula_237645.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'NY Athletic Club', '7fd5026d-e9e6-0004-c04a-3c9bdf5901b6', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, 'https://app.teampass.com/mediacontent//2022/08/17/15/nyac_230131.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('48a40f97-9111-0005-2e29-709bd3953df2', 'Central Park Rangers FC', '48a40f97-9111-0004-2e29-709bd3953df2', 'cce826c6-2327-0003-eaa3-795e1b4fe3d0', '2024-2025', true, 'https://app.teampass.com/mediacontent//2024/09/03/09/cpr_Logo_243235.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('84a1029b-04c8-0005-5548-e180ad338d6b', 'WC Predators', '84a1029b-04c8-0004-5548-e180ad338d6b', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, 'https://app.teampass.com/mediacontent//2024/07/31/10/wc_predators_80_243009.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('0223b314-0973-0005-f017-a5527b76a814', 'Alloy Soccer Club', '0223b314-0973-0004-f017-a5527b76a814', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, 'https://app.teampass.com/mediacontent//2023/07/17/07/Alloy_237562.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('294a08ff-4f18-0005-c42b-a5fb0d5f0896', 'Philadelphia Heritage SC', '294a08ff-4f18-0004-c42b-a5fb0d5f0896', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, 'https://app.teampass.com/mediacontent//2022/08/20/15/krWybzcR_400x400_230174.jpeg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('5d95682c-0ec8-0005-0728-deae7986a2e0', 'Real Central NJ Soccer', '5d95682c-0ec8-0004-0728-deae7986a2e0', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, 'https://app.teampass.com/mediacontent//2022/08/20/15/143032720_238714007857483_1027119688519153835_n_230175.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('3dd92f09-4a7d-0005-c554-60df95cfb846', 'Vidas United FC', '3dd92f09-4a7d-0004-c554-60df95cfb846', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, 'https://app.teampass.com/mediacontent//2023/10/24/20/vidas_239197.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('907ece9f-5926-0005-cff6-7672dec05648', 'Philadelphia Soccer Club', '907ece9f-5926-0004-cff6-7672dec05648', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, 'https://app.teampass.com/mediacontent//2023/08/14/20/output-onlinepngtools(29)_238764.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('c2402f6c-0036-0005-d453-d68637ee8277', 'Oaklyn United FC', 'c2402f6c-0036-0004-d453-d68637ee8277', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, 'https://app.teampass.com/mediacontent//2023/10/20/16/Oaklyn_light_239177.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('f11cc01a-e8d3-0005-74f0-b00c38923236', 'GAK', 'f11cc01a-e8d3-0004-74f0-b00c38923236', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/08/29/13/u_GAK_1756497991011_1_81226896_247723.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('d37eb44b-8e47-0005-9060-f0cbe96fe089', 'Lighthouse 1893 SC', 'd37eb44b-8e47-0004-9060-f0cbe96fe089', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/07/14/16/u_Lighthouse_1752536482788_1_247163.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('7288846b-402d-0005-9d60-70d5ffcc5588', 'Jersey Shore Boca', '7288846b-402d-0004-9d60-70d5ffcc5588', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, 'https://app.teampass.com/mediacontent//2024/08/22/12/boca_logo_243173.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('50720c09-2e57-0005-da39-afc85228aaa9', 'Sewell Old Boys FC', '50720c09-2e57-0004-da39-afc85228aaa9', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/07/15/12/u_Sewell_1752608104421_1_247183.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('77b6674f-d598-0005-fd48-227b9e088c41', 'Medford Strikers', '77b6674f-d598-0004-fd48-227b9e088c41', '0e4dfe0a-4757-0003-dc8e-92734ef56a74', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/07/02/19/u_strikers_logo1_1_1751511344938_1_246963.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('4975b02e-8e62-0005-2030-8e154013c759', 'Nova FC', '4975b02e-8e62-0004-2030-8e154013c759', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, 'https://app.teampass.com/mediacontent//2023/08/24/20/Logo_238842.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('5cb8a2b2-4ca8-0005-2d81-819249f89f0d', 'Wave FC', '5cb8a2b2-4ca8-0004-2d81-819249f89f0d', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, 'https://app.teampass.com/mediacontent//2024/08/22/20/wave_243186.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('8d88ffe1-06ae-0005-6f19-0e9432e55afa', 'VA Marauders FC', '8d88ffe1-06ae-0004-6f19-0e9432e55afa', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, 'https://app.teampass.com/mediacontent//2023/08/24/11/EPSL_Virginia_Marauders_Alt_look_238819.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('cf7f17f3-b83d-0005-856e-8a0b8da24008', 'Grove Soccer United', 'cf7f17f3-b83d-0004-856e-8a0b8da24008', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, 'https://app.teampass.com/mediacontent//2022/08/26/11/Grover_logo_230306.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('226c892a-a28d-0005-ad0a-f9435e13f4e2', 'Christos FC', '226c892a-a28d-0004-ad0a-f9435e13f4e2', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, 'https://app.teampass.com/mediacontent//2024/08/22/20/christos_243184.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('d8e57bbb-92dd-0005-95c3-76a8d99bb683', 'PFA EPSL', 'd8e57bbb-92dd-0004-95c3-76a8d99bb683', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, 'https://app.teampass.com/mediacontent//2022/08/20/15/82890328_113230823566138_4461646361053364224_n_230173.jpeg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('7425cb8d-f81d-0005-8a67-7aa5c9dd6023', 'PW Nova', '7425cb8d-f81d-0004-8a67-7aa5c9dd6023', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, 'https://app.teampass.com/mediacontent//2024/09/15/20/pink_Artboard_1shieldlion2___Copy_243341.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('171f448b-97a3-0005-b875-35f9861c31b6', 'Delmarva Thunder', '171f448b-97a3-0004-b875-35f9861c31b6', '458151aa-915e-0003-2e19-a8b87de9b135', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/04/30/18/u_DT_Logo_1746062752994_1_245707.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('f05b54ff-8886-0005-29cd-ff42c703f657', 'Terminus FC', 'f05b54ff-8886-0004-29cd-ff42c703f657', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/07/15/12/u_Untitled_Background_Removed_1752608875644_1_247185.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('55bd7a24-ba77-0005-81a4-2f5bfb50c614', 'Majestic SC', '55bd7a24-ba77-0004-81a4-2f5bfb50c614', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/05/19/13/u_cropped_majestic_243302_1747687750678_1_246116.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('ec1718e1-142d-0005-ef5c-b49f0f144a3c', 'Peachtree FC', 'ec1718e1-142d-0004-ef5c-b49f0f144a3c', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, 'https://app.teampass.com/mediacontent//2024/07/10/09/peachtree_242739.jpeg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('07e8c5da-df90-0005-7ef3-b55105901be2', 'Prima FC', '07e8c5da-df90-0004-7ef3-b55105901be2', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, 'https://app.teampass.com/mediacontent//2024/07/10/09/prima_242741.jpeg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('268164a2-111d-0005-9ea6-900cd6c9f197', 'Bel Calcio FC', '268164a2-111d-0004-9ea6-900cd6c9f197', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, 'https://app.teampass.com/mediacontent//2024/07/10/09/Screenshot_2024_07_10_at_9_56_16_AM_242743.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('3ae0fc91-9acf-0005-06a7-2af9ccf19b51', 'Buckhead SC', '3ae0fc91-9acf-0004-06a7-2af9ccf19b51', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/09/09/17/u_Buckhead_SC_Logo_1757463223834_1_82306446_247806.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'Alliance SC', '6778fbca-ca21-0004-a2e2-d5b9dfc49df6', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/06/02/13/u_Alliance_1748897141192_1_246188.jpg')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('d2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'SC Gwinnett', 'd2c80f1f-3aa2-0004-9951-cacab62cb9fc', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/08/16/16/u_SC_GCO_Logo_1755388637823_1_80271343_247605.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES ('fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'Lithonia City FC', 'fcccc73d-ebb9-0004-64c9-ee520c7672f8', '222b808e-5cee-0003-80b6-a4f6fa9f2917', '2024-2025', true, 'https://app.teampass.com/mediacontent//2025/06/23/07/u_Outlook_luoo2llm_1750689455670_1_246723.png')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

