-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - APSL
-- Total Records: 53
-- NOTE: division_id is now part of team identity (NOT NULL)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Falcons FC', '114814', 100, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Scrub Nation', '118063', 101, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Praia Kapital', '114837', 102, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'South Coast Union', '114844', 103, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Project Football', '114838', 104, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Invictus FC', '118064', 105, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Fitchburg FC', '114815', 106, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Somerville United FC', '131978', 107, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'KO Elites', '114826', 108, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Constitution Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Glastonbury Celtic', '114816', 109, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Constitution Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Wildcat FC', '114851', 110, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Constitution Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Hermandad Connecticut', '114819', 111, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Constitution Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Greek Americans', '114831', 112, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Hoboken FC 1912', '114820', 113, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Pancyprian Freedoms', '114832', 114, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lansdowne Yonkers FC', '114827', 115, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Doxa FCW', '114813', 116, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Leros SC', '115315', 117, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY International FC', '115102', 118, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Richmond County FC', '114841', 119, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Zum Schneider FC 03', '114852', 120, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers FC', '114811', 121, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'SC Vistula Garfield', '114842', 122, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Athletic Club', '114830', 123, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'WC Predators', '114850', 124, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Alloy Soccer Club', '114808', 125, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Oaklyn United FC', '114833', 126, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Real Central NJ Soccer', '114840', 127, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philadelphia Heritage SC', '114835', 128, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philadelphia Soccer Club', '114836', 129, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Vidas United FC', '114847', 130, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'GAK', '124946', 131, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lighthouse 1893 SC', '116079', 132, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Jersey Shore Boca', '114822', 133, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Sewell Old Boys FC', '116136', 134, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Medford Strikers', '115227', 135, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Nova FC', '114829', 136, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'VA Marauders FC', '114846', 137, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Wave FC', '114849', 138, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'PFA EPSL', '114834', 139, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Grove Soccer United', '114817', 140, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Christos FC', '114812', 141, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Delmarva Thunder', '118680', 142, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'PW Nova', '114839', 143, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Terminus FC', '115815', 144, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Prima FC', '115105', 145, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Majestic SC', '115108', 146, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Peachtree FC', '115101', 147, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Bel Calcio FC', '115106', 148, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Buckhead SC', '115104', 149, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Alliance SC', '115107', 150, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'SC Gwinnett', '119159', 151, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Georgia United FC', '133651', 152, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
