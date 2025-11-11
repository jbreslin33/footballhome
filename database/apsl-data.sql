-- ========================================
-- APSL (American Premier Soccer League) DATA
-- ========================================
-- Data extracted from apslsoccer.com
-- Season: 2025/2026
-- Generated: 2025-11-11
--
-- League: American Premier Soccer League
-- Conferences: 6 (Mayflower, Constitution, Metropolitan, Delaware River, Mid-Atlantic, Terminus)
-- Teams: 57 teams across all conferences
--
-- Note: This data includes league structure and teams only.
-- Player rosters require individual team page scraping (manual or automated process).
--

-- ========================================
-- INSERT APSL LEAGUE
-- ========================================

INSERT INTO leagues (id, name, display_name, sport_id, season, description, website, contact_email, contact_phone, is_active) VALUES
('00000000-0000-0000-0000-000000000001', 'APSL', 'American Premier Soccer League', '550e8400-e29b-41d4-a716-446655440101', '2025/2026', 'Affordable. Sustainable. Open.', 'https://apslsoccer.com', 'office@apslsoccer.com', '(551) 244-0215', true)
ON CONFLICT (id) DO NOTHING;

-- ========================================
-- INSERT CONFERENCES
-- ========================================

INSERT INTO league_conferences (id, league_id, name, display_name, slug, is_active) VALUES
('00000000-0000-0000-0001-000000000001', '00000000-0000-0000-0000-000000000001', 'Mayflower', 'Mayflower Conference', 'mayflower', true),
('00000000-0000-0000-0001-000000000002', '00000000-0000-0000-0000-000000000001', 'Constitution', 'Constitution Conference', 'constitution', true),
('00000000-0000-0000-0001-000000000003', '00000000-0000-0000-0000-000000000001', 'Metropolitan', 'Metropolitan Conference', 'metropolitan', true),
('00000000-0000-0000-0001-000000000004', '00000000-0000-0000-0000-000000000001', 'Delaware River', 'Delaware River Conference', 'delaware-river', true),
('00000000-0000-0000-0001-000000000005', '00000000-0000-0000-0000-000000000001', 'Mid-Atlantic', 'Mid-Atlantic Conference', 'mid-atlantic', true),
('00000000-0000-0000-0001-000000000006', '00000000-0000-0000-0000-000000000001', 'Terminus', 'Terminus Conference', 'terminus', true)
ON CONFLICT (id) DO NOTHING;

-- ========================================
-- INSERT DIVISIONS (One per conference)
-- ========================================

INSERT INTO league_divisions (id, conference_id, name, display_name, slug, tier, skill_level, is_active) VALUES
('00000000-0000-0000-0002-000000000001', '00000000-0000-0000-0001-000000000001', 'Premier', 'Mayflower Premier Division', 'premier', 1, 'Premier', true),
('00000000-0000-0000-0002-000000000002', '00000000-0000-0000-0001-000000000002', 'Premier', 'Constitution Premier Division', 'premier', 1, 'Premier', true),
('00000000-0000-0000-0002-000000000003', '00000000-0000-0000-0001-000000000003', 'Premier', 'Metropolitan Premier Division', 'premier', 1, 'Premier', true),
('00000000-0000-0000-0002-000000000004', '00000000-0000-0000-0001-000000000004', 'Premier', 'Delaware River Premier Division', 'premier', 1, 'Premier', true),
('00000000-0000-0000-0002-000000000005', '00000000-0000-0000-0001-000000000005', 'Premier', 'Mid-Atlantic Premier Division', 'premier', 1, 'Premier', true),
('00000000-0000-0000-0002-000000000006', '00000000-0000-0000-0001-000000000006', 'Premier', 'Terminus Premier Division', 'premier', 1, 'Premier', true)
ON CONFLICT (id) DO NOTHING;

-- ========================================
-- INSERT CLUBS
-- ========================================

-- Mayflower Conference Teams
INSERT INTO clubs (id, name, display_name, slug, is_active) VALUES
('00000000-0000-0000-0003-000000000001', 'Praia Kapital', 'Praia Kapital', 'praia-kapital', true),
('00000000-0000-0000-0003-000000000002', 'Falcons FC', 'Falcons FC', 'falcons-fc', true),
('00000000-0000-0000-0003-000000000003', 'Scrub Nation', 'Scrub Nation', 'scrub-nation', true),
('00000000-0000-0000-0003-000000000004', 'Sete Setembro USA', 'Sete Setembro USA', 'sete-setembro-usa', true),
('00000000-0000-0000-0003-000000000005', 'South Coast Union', 'South Coast Union', 'south-coast-union', true),
('00000000-0000-0000-0003-000000000006', 'Project Football', 'Project Football', 'project-football', true),
('00000000-0000-0000-0003-000000000007', 'Invictus FC', 'Invictus FC', 'invictus-fc', true),
('00000000-0000-0000-0003-000000000008', 'Fitchburg FC', 'Fitchburg FC', 'fitchburg-fc', true),
-- Constitution Conference Teams
('00000000-0000-0000-0003-000000000009', 'KO Elites', 'KO Elites', 'ko-elites', true),
('00000000-0000-0000-0003-000000000010', 'Glastonbury Celtic', 'Glastonbury Celtic', 'glastonbury-celtic', true),
('00000000-0000-0000-0003-000000000011', 'Wildcat FC', 'Wildcat FC', 'wildcat-fc', true),
('00000000-0000-0000-0003-000000000012', 'Hermandad Connecticut', 'Hermandad Connecticut', 'hermandad-connecticut', true),
-- Metropolitan Conference Teams
('00000000-0000-0000-0003-000000000013', 'NY Greek Americans', 'NY Greek Americans', 'ny-greek-americans', true),
('00000000-0000-0000-0003-000000000014', 'Hoboken FC 1912', 'Hoboken FC 1912', 'hoboken-fc-1912', true),
('00000000-0000-0000-0003-000000000015', 'Lansdowne Yonkers FC', 'Lansdowne Yonkers FC', 'lansdowne-yonkers-fc', true),
('00000000-0000-0000-0003-000000000016', 'NY Pancyprian Freedoms', 'NY Pancyprian Freedoms', 'ny-pancyprian-freedoms', true),
('00000000-0000-0000-0003-000000000017', 'NY International FC', 'NY International FC', 'ny-international-fc', true),
('00000000-0000-0000-0003-000000000018', 'Leros SC', 'Leros SC', 'leros-sc', true),
('00000000-0000-0000-0003-000000000019', 'Doxa FCW', 'Doxa FCW', 'doxa-fcw', true),
('00000000-0000-0000-0003-000000000020', 'NY Athletic Club', 'NY Athletic Club', 'ny-athletic-club', true),
('00000000-0000-0000-0003-000000000021', 'SC Vistula Garfield', 'SC Vistula Garfield', 'sc-vistula-garfield', true),
('00000000-0000-0000-0003-000000000022', 'Zum Schneider FC 03', 'Zum Schneider FC 03', 'zum-schneider-fc-03', true),
('00000000-0000-0000-0003-000000000023', 'Richmond County FC', 'Richmond County FC', 'richmond-county-fc', true),
('00000000-0000-0000-0003-000000000024', 'Central Park Rangers FC', 'Central Park Rangers FC', 'central-park-rangers-fc', true),
-- Delaware River Conference Teams
('00000000-0000-0000-0003-000000000025', 'WC Predators', 'WC Predators', 'wc-predators', true),
('00000000-0000-0000-0003-000000000026', 'Alloy Soccer Club', 'Alloy Soccer Club', 'alloy-soccer-club', true),
('00000000-0000-0000-0003-000000000027', 'Philadelphia Heritage SC', 'Philadelphia Heritage SC', 'philadelphia-heritage-sc', true),
('00000000-0000-0000-0003-000000000028', 'Vidas United FC', 'Vidas United FC', 'vidas-united-fc', true),
('00000000-0000-0000-0003-000000000029', 'Real Central NJ Soccer', 'Real Central NJ Soccer', 'real-central-nj-soccer', true),
('00000000-0000-0000-0003-000000000030', 'Philadelphia Soccer Club', 'Philadelphia Soccer Club', 'philadelphia-soccer-club', true),
('00000000-0000-0000-0003-000000000031', 'Lighthouse 1893 SC', 'Lighthouse 1893 SC', 'lighthouse-1893-sc', true),
('00000000-0000-0000-0003-000000000032', 'Oaklyn United FC', 'Oaklyn United FC', 'oaklyn-united-fc', true),
('00000000-0000-0000-0003-000000000033', 'GAK', 'GAK', 'gak', true),
('00000000-0000-0000-0003-000000000034', 'Medford Strikers', 'Medford Strikers', 'medford-strikers', true),
('00000000-0000-0000-0003-000000000035', 'Sewell Old Boys FC', 'Sewell Old Boys FC', 'sewell-old-boys-fc', true),
('00000000-0000-0000-0003-000000000036', 'Jersey Shore Boca', 'Jersey Shore Boca', 'jersey-shore-boca', true),
-- Mid-Atlantic Conference Teams
('00000000-0000-0000-0003-000000000037', 'Nova FC', 'Nova FC', 'nova-fc', true),
('00000000-0000-0000-0003-000000000038', 'Wave FC', 'Wave FC', 'wave-fc', true),
('00000000-0000-0000-0003-000000000039', 'VA Marauders FC', 'VA Marauders FC', 'va-marauders-fc', true),
('00000000-0000-0000-0003-000000000040', 'Christos FC', 'Christos FC', 'christos-fc', true),
('00000000-0000-0000-0003-000000000041', 'PFA EPSL', 'PFA EPSL', 'pfa-epsl', true),
('00000000-0000-0000-0003-000000000042', 'PW Nova', 'PW Nova', 'pw-nova', true),
('00000000-0000-0000-0003-000000000043', 'Grove Soccer United', 'Grove Soccer United', 'grove-soccer-united', true),
('00000000-0000-0000-0003-000000000044', 'Delmarva Thunder', 'Delmarva Thunder', 'delmarva-thunder', true),
-- Terminus Conference Teams
('00000000-0000-0000-0003-000000000045', 'Terminus FC', 'Terminus FC', 'terminus-fc', true),
('00000000-0000-0000-0003-000000000046', 'Peachtree FC', 'Peachtree FC', 'peachtree-fc', true),
('00000000-0000-0000-0003-000000000047', 'Majestic SC', 'Majestic SC', 'majestic-sc', true),
('00000000-0000-0000-0003-000000000048', 'Bel Calcio FC', 'Bel Calcio FC', 'bel-calcio-fc', true),
('00000000-0000-0000-0003-000000000049', 'Prima FC', 'Prima FC', 'prima-fc', true),
('00000000-0000-0000-0003-000000000050', 'Buckhead SC', 'Buckhead SC', 'buckhead-sc', true),
('00000000-0000-0000-0003-000000000051', 'Lithonia City FC', 'Lithonia City FC', 'lithonia-city-fc', true),
('00000000-0000-0000-0003-000000000052', 'Alliance SC', 'Alliance SC', 'alliance-sc', true),
('00000000-0000-0000-0003-000000000053', 'SC Gwinnett', 'SC Gwinnett', 'sc-gwinnett', true)
ON CONFLICT (id) DO NOTHING;

-- ========================================
-- INSERT SPORT DIVISIONS
-- ========================================

-- Mayflower Conference
INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active) VALUES
('00000000-0000-0000-0004-000000000001', '00000000-0000-0000-0003-000000000001', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Praia Kapital Soccer', 'praia-kapital-soccer', true),
('00000000-0000-0000-0004-000000000002', '00000000-0000-0000-0003-000000000002', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Falcons FC Soccer', 'falcons-fc-soccer', true),
('00000000-0000-0000-0004-000000000003', '00000000-0000-0000-0003-000000000003', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Scrub Nation Soccer', 'scrub-nation-soccer', true),
('00000000-0000-0000-0004-000000000004', '00000000-0000-0000-0003-000000000004', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Sete Setembro USA Soccer', 'sete-setembro-usa-soccer', true),
('00000000-0000-0000-0004-000000000005', '00000000-0000-0000-0003-000000000005', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'South Coast Union Soccer', 'south-coast-union-soccer', true),
('00000000-0000-0000-0004-000000000006', '00000000-0000-0000-0003-000000000006', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Project Football Soccer', 'project-football-soccer', true),
('00000000-0000-0000-0004-000000000007', '00000000-0000-0000-0003-000000000007', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Invictus FC Soccer', 'invictus-fc-soccer', true),
('00000000-0000-0000-0004-000000000008', '00000000-0000-0000-0003-000000000008', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Fitchburg FC Soccer', 'fitchburg-fc-soccer', true),
-- Constitution Conference
('00000000-0000-0000-0004-000000000009', '00000000-0000-0000-0003-000000000009', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'KO Elites Soccer', 'ko-elites-soccer', true),
('00000000-0000-0000-0004-000000000010', '00000000-0000-0000-0003-000000000010', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Glastonbury Celtic Soccer', 'glastonbury-celtic-soccer', true),
('00000000-0000-0000-0004-000000000011', '00000000-0000-0000-0003-000000000011', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Wildcat FC Soccer', 'wildcat-fc-soccer', true),
('00000000-0000-0000-0004-000000000012', '00000000-0000-0000-0003-000000000012', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Hermandad Connecticut Soccer', 'hermandad-connecticut-soccer', true),
-- Metropolitan Conference
('00000000-0000-0000-0004-000000000013', '00000000-0000-0000-0003-000000000013', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'NY Greek Americans Soccer', 'ny-greek-americans-soccer', true),
('00000000-0000-0000-0004-000000000014', '00000000-0000-0000-0003-000000000014', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Hoboken FC 1912 Soccer', 'hoboken-fc-1912-soccer', true),
('00000000-0000-0000-0004-000000000015', '00000000-0000-0000-0003-000000000015', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Lansdowne Yonkers FC Soccer', 'lansdowne-yonkers-fc-soccer', true),
('00000000-0000-0000-0004-000000000016', '00000000-0000-0000-0003-000000000016', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'NY Pancyprian Freedoms Soccer', 'ny-pancyprian-freedoms-soccer', true),
('00000000-0000-0000-0004-000000000017', '00000000-0000-0000-0003-000000000017', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'NY International FC Soccer', 'ny-international-fc-soccer', true),
('00000000-0000-0000-0004-000000000018', '00000000-0000-0000-0003-000000000018', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Leros SC Soccer', 'leros-sc-soccer', true),
('00000000-0000-0000-0004-000000000019', '00000000-0000-0000-0003-000000000019', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Doxa FCW Soccer', 'doxa-fcw-soccer', true),
('00000000-0000-0000-0004-000000000020', '00000000-0000-0000-0003-000000000020', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'NY Athletic Club Soccer', 'ny-athletic-club-soccer', true),
('00000000-0000-0000-0004-000000000021', '00000000-0000-0000-0003-000000000021', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'SC Vistula Garfield Soccer', 'sc-vistula-garfield-soccer', true),
('00000000-0000-0000-0004-000000000022', '00000000-0000-0000-0003-000000000022', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Zum Schneider FC 03 Soccer', 'zum-schneider-fc-03-soccer', true),
('00000000-0000-0000-0004-000000000023', '00000000-0000-0000-0003-000000000023', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Richmond County FC Soccer', 'richmond-county-fc-soccer', true),
('00000000-0000-0000-0004-000000000024', '00000000-0000-0000-0003-000000000024', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Central Park Rangers FC Soccer', 'central-park-rangers-fc-soccer', true),
-- Delaware River Conference
('00000000-0000-0000-0004-000000000025', '00000000-0000-0000-0003-000000000025', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'WC Predators Soccer', 'wc-predators-soccer', true),
('00000000-0000-0000-0004-000000000026', '00000000-0000-0000-0003-000000000026', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Alloy Soccer Club Soccer', 'alloy-soccer-club-soccer', true),
('00000000-0000-0000-0004-000000000027', '00000000-0000-0000-0003-000000000027', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Philadelphia Heritage SC Soccer', 'philadelphia-heritage-sc-soccer', true),
('00000000-0000-0000-0004-000000000028', '00000000-0000-0000-0003-000000000028', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Vidas United FC Soccer', 'vidas-united-fc-soccer', true),
('00000000-0000-0000-0004-000000000029', '00000000-0000-0000-0003-000000000029', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Real Central NJ Soccer Soccer', 'real-central-nj-soccer-soccer', true),
('00000000-0000-0000-0004-000000000030', '00000000-0000-0000-0003-000000000030', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Philadelphia Soccer Club Soccer', 'philadelphia-soccer-club-soccer', true),
('00000000-0000-0000-0004-000000000031', '00000000-0000-0000-0003-000000000031', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Lighthouse 1893 SC Soccer', 'lighthouse-1893-sc-soccer', true),
('00000000-0000-0000-0004-000000000032', '00000000-0000-0000-0003-000000000032', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Oaklyn United FC Soccer', 'oaklyn-united-fc-soccer', true),
('00000000-0000-0000-0004-000000000033', '00000000-0000-0000-0003-000000000033', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'GAK Soccer', 'gak-soccer', true),
('00000000-0000-0000-0004-000000000034', '00000000-0000-0000-0003-000000000034', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Medford Strikers Soccer', 'medford-strikers-soccer', true),
('00000000-0000-0000-0004-000000000035', '00000000-0000-0000-0003-000000000035', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Sewell Old Boys FC Soccer', 'sewell-old-boys-fc-soccer', true),
('00000000-0000-0000-0004-000000000036', '00000000-0000-0000-0003-000000000036', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Jersey Shore Boca Soccer', 'jersey-shore-boca-soccer', true),
-- Mid-Atlantic Conference
('00000000-0000-0000-0004-000000000037', '00000000-0000-0000-0003-000000000037', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Nova FC Soccer', 'nova-fc-soccer', true),
('00000000-0000-0000-0004-000000000038', '00000000-0000-0000-0003-000000000038', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Wave FC Soccer', 'wave-fc-soccer', true),
('00000000-0000-0000-0004-000000000039', '00000000-0000-0000-0003-000000000039', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'VA Marauders FC Soccer', 'va-marauders-fc-soccer', true),
('00000000-0000-0000-0004-000000000040', '00000000-0000-0000-0003-000000000040', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Christos FC Soccer', 'christos-fc-soccer', true),
('00000000-0000-0000-0004-000000000041', '00000000-0000-0000-0003-000000000041', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'PFA EPSL Soccer', 'pfa-epsl-soccer', true),
('00000000-0000-0000-0004-000000000042', '00000000-0000-0000-0003-000000000042', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'PW Nova Soccer', 'pw-nova-soccer', true),
('00000000-0000-0000-0004-000000000043', '00000000-0000-0000-0003-000000000043', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Grove Soccer United Soccer', 'grove-soccer-united-soccer', true),
('00000000-0000-0000-0004-000000000044', '00000000-0000-0000-0003-000000000044', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Delmarva Thunder Soccer', 'delmarva-thunder-soccer', true),
-- Terminus Conference
('00000000-0000-0000-0004-000000000045', '00000000-0000-0000-0003-000000000045', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Terminus FC Soccer', 'terminus-fc-soccer', true),
('00000000-0000-0000-0004-000000000046', '00000000-0000-0000-0003-000000000046', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Peachtree FC Soccer', 'peachtree-fc-soccer', true),
('00000000-0000-0000-0004-000000000047', '00000000-0000-0000-0003-000000000047', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Majestic SC Soccer', 'majestic-sc-soccer', true),
('00000000-0000-0000-0004-000000000048', '00000000-0000-0000-0003-000000000048', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Bel Calcio FC Soccer', 'bel-calcio-fc-soccer', true),
('00000000-0000-0000-0004-000000000049', '00000000-0000-0000-0003-000000000049', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Prima FC Soccer', 'prima-fc-soccer', true),
('00000000-0000-0000-0004-000000000050', '00000000-0000-0000-0003-000000000050', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Buckhead SC Soccer', 'buckhead-sc-soccer', true),
('00000000-0000-0000-0004-000000000051', '00000000-0000-0000-0003-000000000051', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Lithonia City FC Soccer', 'lithonia-city-fc-soccer', true),
('00000000-0000-0000-0004-000000000052', '00000000-0000-0000-0003-000000000052', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'Alliance SC Soccer', 'alliance-sc-soccer', true),
('00000000-0000-0000-0004-000000000053', '00000000-0000-0000-0003-000000000053', '550e8400-e29b-41d4-a716-446655440101', 'Soccer Division', 'SC Gwinnett Soccer', 'sc-gwinnett-soccer', true)
ON CONFLICT (id) DO NOTHING;

-- ========================================
-- INSERT TEAMS
-- ========================================

-- Mayflower Conference
INSERT INTO teams (id, name, division_id, league_division_id, season, is_active) VALUES
('00000000-0000-0000-0005-000000000001', 'Praia Kapital', '00000000-0000-0000-0004-000000000001', '00000000-0000-0000-0002-000000000001', '2025/2026', true),
('00000000-0000-0000-0005-000000000002', 'Falcons FC', '00000000-0000-0000-0004-000000000002', '00000000-0000-0000-0002-000000000001', '2025/2026', true),
('00000000-0000-0000-0005-000000000003', 'Scrub Nation', '00000000-0000-0000-0004-000000000003', '00000000-0000-0000-0002-000000000001', '2025/2026', true),
('00000000-0000-0000-0005-000000000004', 'Sete Setembro USA', '00000000-0000-0000-0004-000000000004', '00000000-0000-0000-0002-000000000001', '2025/2026', true),
('00000000-0000-0000-0005-000000000005', 'South Coast Union', '00000000-0000-0000-0004-000000000005', '00000000-0000-0000-0002-000000000001', '2025/2026', true),
('00000000-0000-0000-0005-000000000006', 'Project Football', '00000000-0000-0000-0004-000000000006', '00000000-0000-0000-0002-000000000001', '2025/2026', true),
('00000000-0000-0000-0005-000000000007', 'Invictus FC', '00000000-0000-0000-0004-000000000007', '00000000-0000-0000-0002-000000000001', '2025/2026', true),
('00000000-0000-0000-0005-000000000008', 'Fitchburg FC', '00000000-0000-0000-0004-000000000008', '00000000-0000-0000-0002-000000000001', '2025/2026', true),
-- Constitution Conference
('00000000-0000-0000-0005-000000000009', 'KO Elites', '00000000-0000-0000-0004-000000000009', '00000000-0000-0000-0002-000000000002', '2025/2026', true),
('00000000-0000-0000-0005-000000000010', 'Glastonbury Celtic', '00000000-0000-0000-0004-000000000010', '00000000-0000-0000-0002-000000000002', '2025/2026', true),
('00000000-0000-0000-0005-000000000011', 'Wildcat FC', '00000000-0000-0000-0004-000000000011', '00000000-0000-0000-0002-000000000002', '2025/2026', true),
('00000000-0000-0000-0005-000000000012', 'Hermandad Connecticut', '00000000-0000-0000-0004-000000000012', '00000000-0000-0000-0002-000000000002', '2025/2026', true),
-- Metropolitan Conference
('00000000-0000-0000-0005-000000000013', 'NY Greek Americans', '00000000-0000-0000-0004-000000000013', '00000000-0000-0000-0002-000000000003', '2025/2026', true),
('00000000-0000-0000-0005-000000000014', 'Hoboken FC 1912', '00000000-0000-0000-0004-000000000014', '00000000-0000-0000-0002-000000000003', '2025/2026', true),
('00000000-0000-0000-0005-000000000015', 'Lansdowne Yonkers FC', '00000000-0000-0000-0004-000000000015', '00000000-0000-0000-0002-000000000003', '2025/2026', true),
('00000000-0000-0000-0005-000000000016', 'NY Pancyprian Freedoms', '00000000-0000-0000-0004-000000000016', '00000000-0000-0000-0002-000000000003', '2025/2026', true),
('00000000-0000-0000-0005-000000000017', 'NY International FC', '00000000-0000-0000-0004-000000000017', '00000000-0000-0000-0002-000000000003', '2025/2026', true),
('00000000-0000-0000-0005-000000000018', 'Leros SC', '00000000-0000-0000-0004-000000000018', '00000000-0000-0000-0002-000000000003', '2025/2026', true),
('00000000-0000-0000-0005-000000000019', 'Doxa FCW', '00000000-0000-0000-0004-000000000019', '00000000-0000-0000-0002-000000000003', '2025/2026', true),
('00000000-0000-0000-0005-000000000020', 'NY Athletic Club', '00000000-0000-0000-0004-000000000020', '00000000-0000-0000-0002-000000000003', '2025/2026', true),
('00000000-0000-0000-0005-000000000021', 'SC Vistula Garfield', '00000000-0000-0000-0004-000000000021', '00000000-0000-0000-0002-000000000003', '2025/2026', true),
('00000000-0000-0000-0005-000000000022', 'Zum Schneider FC 03', '00000000-0000-0000-0004-000000000022', '00000000-0000-0000-0002-000000000003', '2025/2026', true),
('00000000-0000-0000-0005-000000000023', 'Richmond County FC', '00000000-0000-0000-0004-000000000023', '00000000-0000-0000-0002-000000000003', '2025/2026', true),
('00000000-0000-0000-0005-000000000024', 'Central Park Rangers FC', '00000000-0000-0000-0004-000000000024', '00000000-0000-0000-0002-000000000003', '2025/2026', true),
-- Delaware River Conference
('00000000-0000-0000-0005-000000000025', 'WC Predators', '00000000-0000-0000-0004-000000000025', '00000000-0000-0000-0002-000000000004', '2025/2026', true),
('00000000-0000-0000-0005-000000000026', 'Alloy Soccer Club', '00000000-0000-0000-0004-000000000026', '00000000-0000-0000-0002-000000000004', '2025/2026', true),
('00000000-0000-0000-0005-000000000027', 'Philadelphia Heritage SC', '00000000-0000-0000-0004-000000000027', '00000000-0000-0000-0002-000000000004', '2025/2026', true),
('00000000-0000-0000-0005-000000000028', 'Vidas United FC', '00000000-0000-0000-0004-000000000028', '00000000-0000-0000-0002-000000000004', '2025/2026', true),
('00000000-0000-0000-0005-000000000029', 'Real Central NJ Soccer', '00000000-0000-0000-0004-000000000029', '00000000-0000-0000-0002-000000000004', '2025/2026', true),
('00000000-0000-0000-0005-000000000030', 'Philadelphia Soccer Club', '00000000-0000-0000-0004-000000000030', '00000000-0000-0000-0002-000000000004', '2025/2026', true),
('00000000-0000-0000-0005-000000000031', 'Lighthouse 1893 SC', '00000000-0000-0000-0004-000000000031', '00000000-0000-0000-0002-000000000004', '2025/2026', true),
('00000000-0000-0000-0005-000000000032', 'Oaklyn United FC', '00000000-0000-0000-0004-000000000032', '00000000-0000-0000-0002-000000000004', '2025/2026', true),
('00000000-0000-0000-0005-000000000033', 'GAK', '00000000-0000-0000-0004-000000000033', '00000000-0000-0000-0002-000000000004', '2025/2026', true),
('00000000-0000-0000-0005-000000000034', 'Medford Strikers', '00000000-0000-0000-0004-000000000034', '00000000-0000-0000-0002-000000000004', '2025/2026', true),
('00000000-0000-0000-0005-000000000035', 'Sewell Old Boys FC', '00000000-0000-0000-0004-000000000035', '00000000-0000-0000-0002-000000000004', '2025/2026', true),
('00000000-0000-0000-0005-000000000036', 'Jersey Shore Boca', '00000000-0000-0000-0004-000000000036', '00000000-0000-0000-0002-000000000004', '2025/2026', true),
-- Mid-Atlantic Conference
('00000000-0000-0000-0005-000000000037', 'Nova FC', '00000000-0000-0000-0004-000000000037', '00000000-0000-0000-0002-000000000005', '2025/2026', true),
('00000000-0000-0000-0005-000000000038', 'Wave FC', '00000000-0000-0000-0004-000000000038', '00000000-0000-0000-0002-000000000005', '2025/2026', true),
('00000000-0000-0000-0005-000000000039', 'VA Marauders FC', '00000000-0000-0000-0004-000000000039', '00000000-0000-0000-0002-000000000005', '2025/2026', true),
('00000000-0000-0000-0005-000000000040', 'Christos FC', '00000000-0000-0000-0004-000000000040', '00000000-0000-0000-0002-000000000005', '2025/2026', true),
('00000000-0000-0000-0005-000000000041', 'PFA EPSL', '00000000-0000-0000-0004-000000000041', '00000000-0000-0000-0002-000000000005', '2025/2026', true),
('00000000-0000-0000-0005-000000000042', 'PW Nova', '00000000-0000-0000-0004-000000000042', '00000000-0000-0000-0002-000000000005', '2025/2026', true),
('00000000-0000-0000-0005-000000000043', 'Grove Soccer United', '00000000-0000-0000-0004-000000000043', '00000000-0000-0000-0002-000000000005', '2025/2026', true),
('00000000-0000-0000-0005-000000000044', 'Delmarva Thunder', '00000000-0000-0000-0004-000000000044', '00000000-0000-0000-0002-000000000005', '2025/2026', true),
-- Terminus Conference
('00000000-0000-0000-0005-000000000045', 'Terminus FC', '00000000-0000-0000-0004-000000000045', '00000000-0000-0000-0002-000000000006', '2025/2026', true),
('00000000-0000-0000-0005-000000000046', 'Peachtree FC', '00000000-0000-0000-0004-000000000046', '00000000-0000-0000-0002-000000000006', '2025/2026', true),
('00000000-0000-0000-0005-000000000047', 'Majestic SC', '00000000-0000-0000-0004-000000000047', '00000000-0000-0000-0002-000000000006', '2025/2026', true),
('00000000-0000-0000-0005-000000000048', 'Bel Calcio FC', '00000000-0000-0000-0004-000000000048', '00000000-0000-0000-0002-000000000006', '2025/2026', true),
('00000000-0000-0000-0005-000000000049', 'Prima FC', '00000000-0000-0000-0004-000000000049', '00000000-0000-0000-0002-000000000006', '2025/2026', true),
('00000000-0000-0000-0005-000000000050', 'Buckhead SC', '00000000-0000-0000-0004-000000000050', '00000000-0000-0000-0002-000000000006', '2025/2026', true),
('00000000-0000-0000-0005-000000000051', 'Lithonia City FC', '00000000-0000-0000-0004-000000000051', '00000000-0000-0000-0002-000000000006', '2025/2026', true),
('00000000-0000-0000-0005-000000000052', 'Alliance SC', '00000000-0000-0000-0004-000000000052', '00000000-0000-0000-0002-000000000006', '2025/2026', true),
('00000000-0000-0000-0005-000000000053', 'SC Gwinnett', '00000000-0000-0000-0004-000000000053', '00000000-0000-0000-0002-000000000006', '2025/2026', true)
ON CONFLICT (id) DO NOTHING;

-- ========================================
-- SUMMARY
-- ========================================
-- League: American Premier Soccer League (APSL)
-- Conferences: 6
--   - Mayflower Conference (8 teams)
--   - Constitution Conference (4 teams)
--   - Metropolitan Conference (12 teams)
--   - Delaware River Conference (12 teams)
--   - Mid-Atlantic Conference (8 teams)
--   - Terminus Conference (9 teams)
-- Total Teams: 53 teams
--
-- Note: Player rosters not included in this initial data set.
-- To add players, scrape individual team roster pages from apslsoccer.com
