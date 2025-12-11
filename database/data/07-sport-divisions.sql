-- ========================================
-- SPORT DIVISIONS
-- ========================================
-- Generated: 2025-12-11T19:17:01.986Z
-- Source: https://apslsoccer.com/standings/
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/scripts/apsl-scraper/scrape-apsl.js
-- ========================================

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('093a47d2-4a1d-0004-6ab0-93e9e96847d7', '093a47d2-4a1d-0003-6ab0-93e9e96847d7', '550e8400-e29b-41d4-a716-446655440101', 'Falcons FC Soccer', 'Falcons FC Soccer', 'falcons-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('cd2f494d-83b2-0004-7009-2d86f0e05d52', 'cd2f494d-83b2-0003-7009-2d86f0e05d52', '550e8400-e29b-41d4-a716-446655440101', 'Scrub Nation Soccer', 'Scrub Nation Soccer', 'scrub-nation-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('2a1d62b2-aa71-0004-a6eb-1657e21800bf', '2a1d62b2-aa71-0003-a6eb-1657e21800bf', '550e8400-e29b-41d4-a716-446655440101', 'Praia Kapital Soccer', 'Praia Kapital Soccer', 'praia-kapital-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('3b1d4171-c61d-0004-82fe-0b134f83622d', '3b1d4171-c61d-0003-82fe-0b134f83622d', '550e8400-e29b-41d4-a716-446655440101', 'South Coast Union Soccer', 'South Coast Union Soccer', 'south-coast-union-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('d6dd2763-bfe0-0004-76b6-634bdffc6f2a', 'd6dd2763-bfe0-0003-76b6-634bdffc6f2a', '550e8400-e29b-41d4-a716-446655440101', 'Project Football Soccer', 'Project Football Soccer', 'project-football-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('aa0aab49-a007-0004-2697-8c6ceac5beb7', 'aa0aab49-a007-0003-2697-8c6ceac5beb7', '550e8400-e29b-41d4-a716-446655440101', 'Invictus FC Soccer', 'Invictus FC Soccer', 'invictus-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('b8ec25f4-b6b4-0004-ce33-0da183347d70', 'b8ec25f4-b6b4-0003-ce33-0da183347d70', '550e8400-e29b-41d4-a716-446655440101', 'Fitchburg FC Soccer', 'Fitchburg FC Soccer', 'fitchburg-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('a9f395bc-b644-0004-057d-97f0afc4ca9c', 'a9f395bc-b644-0003-057d-97f0afc4ca9c', '550e8400-e29b-41d4-a716-446655440101', 'Sete Setembro USA Soccer', 'Sete Setembro USA Soccer', 'sete-setembro-usa-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('146b59a9-f1e5-0004-222d-8a966f83da24', '146b59a9-f1e5-0003-222d-8a966f83da24', '550e8400-e29b-41d4-a716-446655440101', 'Somerville United FC Soccer', 'Somerville United FC Soccer', 'somerville-united-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('a57bd844-e059-0004-1ea8-768f2a07223e', 'a57bd844-e059-0003-1ea8-768f2a07223e', '550e8400-e29b-41d4-a716-446655440101', 'KO Elites Soccer', 'KO Elites Soccer', 'ko-elites-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('265404b6-e493-0004-2586-5ba8bae74fcc', '265404b6-e493-0003-2586-5ba8bae74fcc', '550e8400-e29b-41d4-a716-446655440101', 'Glastonbury Celtic Soccer', 'Glastonbury Celtic Soccer', 'glastonbury-celtic-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('7f09e1bb-ee7f-0004-739b-caf0f540a273', '7f09e1bb-ee7f-0003-739b-caf0f540a273', '550e8400-e29b-41d4-a716-446655440101', 'Wildcat FC Soccer', 'Wildcat FC Soccer', 'wildcat-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('5c979af3-1b0d-0004-afb1-07227c8fb58c', '5c979af3-1b0d-0003-afb1-07227c8fb58c', '550e8400-e29b-41d4-a716-446655440101', 'Hermandad Connecticut Soccer', 'Hermandad Connecticut Soccer', 'hermandad-connecticut-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('a9e2b1a8-5969-0004-f674-2f918d293250', 'a9e2b1a8-5969-0003-f674-2f918d293250', '550e8400-e29b-41d4-a716-446655440101', 'NY Greek Americans Soccer', 'NY Greek Americans Soccer', 'ny-greek-americans-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('49df0225-be54-0004-699c-ee6cd5da686b', '49df0225-be54-0003-699c-ee6cd5da686b', '550e8400-e29b-41d4-a716-446655440101', 'Hoboken FC 1912 Soccer', 'Hoboken FC 1912 Soccer', 'hoboken-fc-1912-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('cd0f7cdf-7018-0004-51d9-cafefed696e5', 'cd0f7cdf-7018-0003-51d9-cafefed696e5', '550e8400-e29b-41d4-a716-446655440101', 'NY Pancyprian Freedoms Soccer', 'NY Pancyprian Freedoms Soccer', 'ny-pancyprian-freedoms-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('fd2f4fc8-6cbd-0004-8199-96a395b40d55', 'fd2f4fc8-6cbd-0003-8199-96a395b40d55', '550e8400-e29b-41d4-a716-446655440101', 'Lansdowne Yonkers FC Soccer', 'Lansdowne Yonkers FC Soccer', 'lansdowne-yonkers-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('77717fe0-fb4f-0004-cef3-260a0c447980', '77717fe0-fb4f-0003-cef3-260a0c447980', '550e8400-e29b-41d4-a716-446655440101', 'Leros SC Soccer', 'Leros SC Soccer', 'leros-sc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('68b50f22-dddc-0004-06ca-622f3a3a0ea4', '68b50f22-dddc-0003-06ca-622f3a3a0ea4', '550e8400-e29b-41d4-a716-446655440101', 'Doxa FCW Soccer', 'Doxa FCW Soccer', 'doxa-fcw-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('c99ade72-80a1-0004-bb2a-e36057334cac', 'c99ade72-80a1-0003-bb2a-e36057334cac', '550e8400-e29b-41d4-a716-446655440101', 'NY International FC Soccer', 'NY International FC Soccer', 'ny-international-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('bad8aee7-4cea-0004-8995-4a25b932936d', 'bad8aee7-4cea-0003-8995-4a25b932936d', '550e8400-e29b-41d4-a716-446655440101', 'Richmond County FC Soccer', 'Richmond County FC Soccer', 'richmond-county-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('5951a8c4-ca8a-0004-8cb6-0cfaa8ed8a34', '5951a8c4-ca8a-0003-8cb6-0cfaa8ed8a34', '550e8400-e29b-41d4-a716-446655440101', 'Zum Schneider FC 03 Soccer', 'Zum Schneider FC 03 Soccer', 'zum-schneider-fc-03-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('48a40f97-9111-0004-2e29-709bd3953df2', '48a40f97-9111-0003-2e29-709bd3953df2', '550e8400-e29b-41d4-a716-446655440101', 'Central Park Rangers FC Soccer', 'Central Park Rangers FC Soccer', 'central-park-rangers-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('741624af-fbb6-0004-5186-2697c8c058e6', '741624af-fbb6-0003-5186-2697c8c058e6', '550e8400-e29b-41d4-a716-446655440101', 'SC Vistula Garfield Soccer', 'SC Vistula Garfield Soccer', 'sc-vistula-garfield-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('7fd5026d-e9e6-0004-c04a-3c9bdf5901b6', '7fd5026d-e9e6-0003-c04a-3c9bdf5901b6', '550e8400-e29b-41d4-a716-446655440101', 'NY Athletic Club Soccer', 'NY Athletic Club Soccer', 'ny-athletic-club-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('84a1029b-04c8-0004-5548-e180ad338d6b', '84a1029b-04c8-0003-5548-e180ad338d6b', '550e8400-e29b-41d4-a716-446655440101', 'WC Predators Soccer', 'WC Predators Soccer', 'wc-predators-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('0223b314-0973-0004-f017-a5527b76a814', '0223b314-0973-0003-f017-a5527b76a814', '550e8400-e29b-41d4-a716-446655440101', 'Alloy Soccer Club Soccer', 'Alloy Soccer Club Soccer', 'alloy-soccer-club-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('c2402f6c-0036-0004-d453-d68637ee8277', 'c2402f6c-0036-0003-d453-d68637ee8277', '550e8400-e29b-41d4-a716-446655440101', 'Oaklyn United FC Soccer', 'Oaklyn United FC Soccer', 'oaklyn-united-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('5d95682c-0ec8-0004-0728-deae7986a2e0', '5d95682c-0ec8-0003-0728-deae7986a2e0', '550e8400-e29b-41d4-a716-446655440101', 'Real Central NJ Soccer Soccer', 'Real Central NJ Soccer Soccer', 'real-central-nj-soccer-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('294a08ff-4f18-0004-c42b-a5fb0d5f0896', '294a08ff-4f18-0003-c42b-a5fb0d5f0896', '550e8400-e29b-41d4-a716-446655440101', 'Philadelphia Heritage SC Soccer', 'Philadelphia Heritage SC Soccer', 'philadelphia-heritage-sc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('907ece9f-5926-0004-cff6-7672dec05648', '907ece9f-5926-0003-cff6-7672dec05648', '550e8400-e29b-41d4-a716-446655440101', 'Philadelphia Soccer Club Soccer', 'Philadelphia Soccer Club Soccer', 'philadelphia-soccer-club-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('3dd92f09-4a7d-0004-c554-60df95cfb846', '3dd92f09-4a7d-0003-c554-60df95cfb846', '550e8400-e29b-41d4-a716-446655440101', 'Vidas United FC Soccer', 'Vidas United FC Soccer', 'vidas-united-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('f11cc01a-e8d3-0004-74f0-b00c38923236', 'f11cc01a-e8d3-0003-74f0-b00c38923236', '550e8400-e29b-41d4-a716-446655440101', 'GAK Soccer', 'GAK Soccer', 'gak-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('d37eb44b-8e47-0004-9060-f0cbe96fe089', 'd37eb44b-8e47-0003-9060-f0cbe96fe089', '550e8400-e29b-41d4-a716-446655440101', 'Lighthouse 1893 SC Soccer', 'Lighthouse 1893 SC Soccer', 'lighthouse-1893-sc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('7288846b-402d-0004-9d60-70d5ffcc5588', '7288846b-402d-0003-9d60-70d5ffcc5588', '550e8400-e29b-41d4-a716-446655440101', 'Jersey Shore Boca Soccer', 'Jersey Shore Boca Soccer', 'jersey-shore-boca-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('50720c09-2e57-0004-da39-afc85228aaa9', '50720c09-2e57-0003-da39-afc85228aaa9', '550e8400-e29b-41d4-a716-446655440101', 'Sewell Old Boys FC Soccer', 'Sewell Old Boys FC Soccer', 'sewell-old-boys-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('77b6674f-d598-0004-fd48-227b9e088c41', '77b6674f-d598-0003-fd48-227b9e088c41', '550e8400-e29b-41d4-a716-446655440101', 'Medford Strikers Soccer', 'Medford Strikers Soccer', 'medford-strikers-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('4975b02e-8e62-0004-2030-8e154013c759', '4975b02e-8e62-0003-2030-8e154013c759', '550e8400-e29b-41d4-a716-446655440101', 'Nova FC Soccer', 'Nova FC Soccer', 'nova-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('8d88ffe1-06ae-0004-6f19-0e9432e55afa', '8d88ffe1-06ae-0003-6f19-0e9432e55afa', '550e8400-e29b-41d4-a716-446655440101', 'VA Marauders FC Soccer', 'VA Marauders FC Soccer', 'va-marauders-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('5cb8a2b2-4ca8-0004-2d81-819249f89f0d', '5cb8a2b2-4ca8-0003-2d81-819249f89f0d', '550e8400-e29b-41d4-a716-446655440101', 'Wave FC Soccer', 'Wave FC Soccer', 'wave-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('d8e57bbb-92dd-0004-95c3-76a8d99bb683', 'd8e57bbb-92dd-0003-95c3-76a8d99bb683', '550e8400-e29b-41d4-a716-446655440101', 'PFA EPSL Soccer', 'PFA EPSL Soccer', 'pfa-epsl-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('cf7f17f3-b83d-0004-856e-8a0b8da24008', 'cf7f17f3-b83d-0003-856e-8a0b8da24008', '550e8400-e29b-41d4-a716-446655440101', 'Grove Soccer United Soccer', 'Grove Soccer United Soccer', 'grove-soccer-united-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('226c892a-a28d-0004-ad0a-f9435e13f4e2', '226c892a-a28d-0003-ad0a-f9435e13f4e2', '550e8400-e29b-41d4-a716-446655440101', 'Christos FC Soccer', 'Christos FC Soccer', 'christos-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('171f448b-97a3-0004-b875-35f9861c31b6', '171f448b-97a3-0003-b875-35f9861c31b6', '550e8400-e29b-41d4-a716-446655440101', 'Delmarva Thunder Soccer', 'Delmarva Thunder Soccer', 'delmarva-thunder-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('7425cb8d-f81d-0004-8a67-7aa5c9dd6023', '7425cb8d-f81d-0003-8a67-7aa5c9dd6023', '550e8400-e29b-41d4-a716-446655440101', 'PW Nova Soccer', 'PW Nova Soccer', 'pw-nova-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('f05b54ff-8886-0004-29cd-ff42c703f657', 'f05b54ff-8886-0003-29cd-ff42c703f657', '550e8400-e29b-41d4-a716-446655440101', 'Terminus FC Soccer', 'Terminus FC Soccer', 'terminus-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('55bd7a24-ba77-0004-81a4-2f5bfb50c614', '55bd7a24-ba77-0003-81a4-2f5bfb50c614', '550e8400-e29b-41d4-a716-446655440101', 'Majestic SC Soccer', 'Majestic SC Soccer', 'majestic-sc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('07e8c5da-df90-0004-7ef3-b55105901be2', '07e8c5da-df90-0003-7ef3-b55105901be2', '550e8400-e29b-41d4-a716-446655440101', 'Prima FC Soccer', 'Prima FC Soccer', 'prima-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('ec1718e1-142d-0004-ef5c-b49f0f144a3c', 'ec1718e1-142d-0003-ef5c-b49f0f144a3c', '550e8400-e29b-41d4-a716-446655440101', 'Peachtree FC Soccer', 'Peachtree FC Soccer', 'peachtree-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('268164a2-111d-0004-9ea6-900cd6c9f197', '268164a2-111d-0003-9ea6-900cd6c9f197', '550e8400-e29b-41d4-a716-446655440101', 'Bel Calcio FC Soccer', 'Bel Calcio FC Soccer', 'bel-calcio-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('3ae0fc91-9acf-0004-06a7-2af9ccf19b51', '3ae0fc91-9acf-0003-06a7-2af9ccf19b51', '550e8400-e29b-41d4-a716-446655440101', 'Buckhead SC Soccer', 'Buckhead SC Soccer', 'buckhead-sc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('6778fbca-ca21-0004-a2e2-d5b9dfc49df6', '6778fbca-ca21-0003-a2e2-d5b9dfc49df6', '550e8400-e29b-41d4-a716-446655440101', 'Alliance SC Soccer', 'Alliance SC Soccer', 'alliance-sc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('d2c80f1f-3aa2-0004-9951-cacab62cb9fc', 'd2c80f1f-3aa2-0003-9951-cacab62cb9fc', '550e8400-e29b-41d4-a716-446655440101', 'SC Gwinnett Soccer', 'SC Gwinnett Soccer', 'sc-gwinnett-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES ('fcccc73d-ebb9-0004-64c9-ee520c7672f8', 'fcccc73d-ebb9-0003-64c9-ee520c7672f8', '550e8400-e29b-41d4-a716-446655440101', 'Lithonia City FC Soccer', 'Lithonia City FC Soccer', 'lithonia-city-fc-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

