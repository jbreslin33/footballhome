-- ========================================
-- CLUBS
-- ========================================
-- Generated: 2025-12-08T17:05:28.172Z
-- Source: https://apslsoccer.com/standings/
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/scripts/apsl-scraper/scrape-apsl.js
-- ========================================

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('093a47d2-4a1d-0003-6ab0-93e9e96847d7', 'Falcons FC', 'Falcons FC', 'falcons-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('2a1d62b2-aa71-0003-a6eb-1657e21800bf', 'Praia Kapital', 'Praia Kapital', 'praia-kapital', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('cd2f494d-83b2-0003-7009-2d86f0e05d52', 'Scrub Nation', 'Scrub Nation', 'scrub-nation', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('a9f395bc-b644-0003-057d-97f0afc4ca9c', 'Sete Setembro USA', 'Sete Setembro USA', 'sete-setembro-usa', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('3b1d4171-c61d-0003-82fe-0b134f83622d', 'South Coast Union', 'South Coast Union', 'south-coast-union', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('d6dd2763-bfe0-0003-76b6-634bdffc6f2a', 'Project Football', 'Project Football', 'project-football', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('aa0aab49-a007-0003-2697-8c6ceac5beb7', 'Invictus FC', 'Invictus FC', 'invictus-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('b8ec25f4-b6b4-0003-ce33-0da183347d70', 'Fitchburg FC', 'Fitchburg FC', 'fitchburg-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('a57bd844-e059-0003-1ea8-768f2a07223e', 'KO Elites', 'KO Elites', 'ko-elites', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('265404b6-e493-0003-2586-5ba8bae74fcc', 'Glastonbury Celtic', 'Glastonbury Celtic', 'glastonbury-celtic', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('7f09e1bb-ee7f-0003-739b-caf0f540a273', 'Wildcat FC', 'Wildcat FC', 'wildcat-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('5c979af3-1b0d-0003-afb1-07227c8fb58c', 'Hermandad Connecticut', 'Hermandad Connecticut', 'hermandad-connecticut', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('a9e2b1a8-5969-0003-f674-2f918d293250', 'NY Greek Americans', 'NY Greek Americans', 'ny-greek-americans', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('49df0225-be54-0003-699c-ee6cd5da686b', 'Hoboken FC 1912', 'Hoboken FC 1912', 'hoboken-fc-1912', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('cd0f7cdf-7018-0003-51d9-cafefed696e5', 'NY Pancyprian Freedoms', 'NY Pancyprian Freedoms', 'ny-pancyprian-freedoms', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('fd2f4fc8-6cbd-0003-8199-96a395b40d55', 'Lansdowne Yonkers FC', 'Lansdowne Yonkers FC', 'lansdowne-yonkers-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('77717fe0-fb4f-0003-cef3-260a0c447980', 'Leros SC', 'Leros SC', 'leros-sc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('68b50f22-dddc-0003-06ca-622f3a3a0ea4', 'Doxa FCW', 'Doxa FCW', 'doxa-fcw', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('c99ade72-80a1-0003-bb2a-e36057334cac', 'NY International FC', 'NY International FC', 'ny-international-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('bad8aee7-4cea-0003-8995-4a25b932936d', 'Richmond County FC', 'Richmond County FC', 'richmond-county-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('5951a8c4-ca8a-0003-8cb6-0cfaa8ed8a34', 'Zum Schneider FC 03', 'Zum Schneider FC 03', 'zum-schneider-fc-03', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('48a40f97-9111-0003-2e29-709bd3953df2', 'Central Park Rangers FC', 'Central Park Rangers FC', 'central-park-rangers-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('741624af-fbb6-0003-5186-2697c8c058e6', 'SC Vistula Garfield', 'SC Vistula Garfield', 'sc-vistula-garfield', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('7fd5026d-e9e6-0003-c04a-3c9bdf5901b6', 'NY Athletic Club', 'NY Athletic Club', 'ny-athletic-club', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('84a1029b-04c8-0003-5548-e180ad338d6b', 'WC Predators', 'WC Predators', 'wc-predators', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('0223b314-0973-0003-f017-a5527b76a814', 'Alloy Soccer Club', 'Alloy Soccer Club', 'alloy-soccer-club', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('c2402f6c-0036-0003-d453-d68637ee8277', 'Oaklyn United FC', 'Oaklyn United FC', 'oaklyn-united-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('5d95682c-0ec8-0003-0728-deae7986a2e0', 'Real Central NJ Soccer', 'Real Central NJ Soccer', 'real-central-nj-soccer', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('294a08ff-4f18-0003-c42b-a5fb0d5f0896', 'Philadelphia Heritage SC', 'Philadelphia Heritage SC', 'philadelphia-heritage-sc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('3dd92f09-4a7d-0003-c554-60df95cfb846', 'Vidas United FC', 'Vidas United FC', 'vidas-united-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('907ece9f-5926-0003-cff6-7672dec05648', 'Philadelphia Soccer Club', 'Philadelphia Soccer Club', 'philadelphia-soccer-club', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('f11cc01a-e8d3-0003-74f0-b00c38923236', 'GAK', 'GAK', 'gak', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('d37eb44b-8e47-0003-9060-f0cbe96fe089', 'Lighthouse 1893 SC', 'Lighthouse 1893 SC', 'lighthouse-1893-sc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('7288846b-402d-0003-9d60-70d5ffcc5588', 'Jersey Shore Boca', 'Jersey Shore Boca', 'jersey-shore-boca', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('50720c09-2e57-0003-da39-afc85228aaa9', 'Sewell Old Boys FC', 'Sewell Old Boys FC', 'sewell-old-boys-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('77b6674f-d598-0003-fd48-227b9e088c41', 'Medford Strikers', 'Medford Strikers', 'medford-strikers', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('4975b02e-8e62-0003-2030-8e154013c759', 'Nova FC', 'Nova FC', 'nova-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('8d88ffe1-06ae-0003-6f19-0e9432e55afa', 'VA Marauders FC', 'VA Marauders FC', 'va-marauders-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('5cb8a2b2-4ca8-0003-2d81-819249f89f0d', 'Wave FC', 'Wave FC', 'wave-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('d8e57bbb-92dd-0003-95c3-76a8d99bb683', 'PFA EPSL', 'PFA EPSL', 'pfa-epsl', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('cf7f17f3-b83d-0003-856e-8a0b8da24008', 'Grove Soccer United', 'Grove Soccer United', 'grove-soccer-united', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('226c892a-a28d-0003-ad0a-f9435e13f4e2', 'Christos FC', 'Christos FC', 'christos-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('171f448b-97a3-0003-b875-35f9861c31b6', 'Delmarva Thunder', 'Delmarva Thunder', 'delmarva-thunder', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('7425cb8d-f81d-0003-8a67-7aa5c9dd6023', 'PW Nova', 'PW Nova', 'pw-nova', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('f05b54ff-8886-0003-29cd-ff42c703f657', 'Terminus FC', 'Terminus FC', 'terminus-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('55bd7a24-ba77-0003-81a4-2f5bfb50c614', 'Majestic SC', 'Majestic SC', 'majestic-sc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('07e8c5da-df90-0003-7ef3-b55105901be2', 'Prima FC', 'Prima FC', 'prima-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('ec1718e1-142d-0003-ef5c-b49f0f144a3c', 'Peachtree FC', 'Peachtree FC', 'peachtree-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('268164a2-111d-0003-9ea6-900cd6c9f197', 'Bel Calcio FC', 'Bel Calcio FC', 'bel-calcio-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('3ae0fc91-9acf-0003-06a7-2af9ccf19b51', 'Buckhead SC', 'Buckhead SC', 'buckhead-sc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('6778fbca-ca21-0003-a2e2-d5b9dfc49df6', 'Alliance SC', 'Alliance SC', 'alliance-sc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('d2c80f1f-3aa2-0003-9951-cacab62cb9fc', 'SC Gwinnett', 'SC Gwinnett', 'sc-gwinnett', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES ('fcccc73d-ebb9-0003-64c9-ee520c7672f8', 'Lithonia City FC', 'Lithonia City FC', 'lithonia-city-fc', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

