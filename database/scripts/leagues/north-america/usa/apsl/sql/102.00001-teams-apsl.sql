-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - APSL
-- Total Records: 84
-- NOTE: division_id is now part of team identity (NOT NULL)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'KO Elites', '114826', 100, d.id, 1
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
SELECT 'Glastonbury Celtic', '114816', 101, d.id, 1
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
SELECT 'Wildcat FC', '114851', 102, d.id, 1
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
SELECT 'Caribbean FCA', '135760', 103, d.id, 1
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
SELECT 'Hermandad Connecticut', '114819', 104, d.id, 1
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
SELECT 'WC Predators', '114850', 105, d.id, 1
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
SELECT 'Alloy Soccer Club', '114808', 106, d.id, 1
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
SELECT 'Oaklyn United FC', '114833', 107, d.id, 1
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
SELECT 'Real Central NJ Soccer', '114840', 108, d.id, 1
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
SELECT 'Philadelphia Soccer Club', '114836', 109, d.id, 1
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
SELECT 'Philadelphia Heritage SC', '114835', 110, d.id, 1
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
SELECT 'Jersey Shore Boca', '114822', 111, d.id, 1
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
SELECT 'Vidas United FC', '114847', 112, d.id, 1
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
SELECT 'Lighthouse 1893 SC', '116079', 113, d.id, 1
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
SELECT 'GAK', '124946', 114, d.id, 1
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
SELECT 'Sewell Old Boys FC', '116136', 115, d.id, 1
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
SELECT 'Medford Strikers', '115227', 116, d.id, 1
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
SELECT 'Scrub Nation', '118063', 117, d.id, 1
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
SELECT 'Praia Kapital', '114837', 118, d.id, 1
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
SELECT 'Falcons FC', '114814', 119, d.id, 1
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
SELECT 'South Coast Union', '114844', 120, d.id, 1
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
SELECT 'Project Football', '114838', 121, d.id, 1
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
SELECT 'Somerville United FC', '131978', 122, d.id, 1
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
SELECT 'Invictus FC', '118064', 123, d.id, 1
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
SELECT 'Fitchburg FC', '114815', 124, d.id, 1
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
SELECT 'NY Greek Americans', '114831', 125, d.id, 1
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
SELECT 'Lansdowne Yonkers FC', '114827', 126, d.id, 1
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
SELECT 'NY Pancyprian Freedoms', '114832', 127, d.id, 1
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
SELECT 'Hoboken FC 1912', '114820', 128, d.id, 1
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
SELECT 'Doxa FCW', '114813', 129, d.id, 1
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
SELECT 'Leros SC', '115315', 130, d.id, 1
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
SELECT 'Richmond County FC', '114841', 131, d.id, 1
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
SELECT 'NY International FC', '115102', 132, d.id, 1
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
SELECT 'SC Vistula Garfield', '114842', 133, d.id, 1
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
SELECT 'Zum Schneider FC 03', '114852', 134, d.id, 1
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
SELECT 'NY Athletic Club', '114830', 135, d.id, 1
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
SELECT 'Central Park Rangers FC', '114811', 136, d.id, 1
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
SELECT 'Nova FC', '114829', 137, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'VA Marauders FC', '114846', 138, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Wave FC', '114849', 139, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'PFA APSL', '114834', 140, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Grove Soccer United', '114817', 141, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Christos FC', '114812', 142, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Delmarva Thunder', '118680', 143, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'PW Nova', '114839', 144, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Club Petrolero', '140256', 145, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Delmarva Thunder', '140730', 143, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Nova FC', '140753', 137, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Wave FC', '140779', 139, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Baltimore City FC', '140784', 146, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'DMV Rangers', '143012', 147, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'PFA APSL', '140760', 140, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Grove Soccer United', '140739', 141, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'VA Marauders FC', '140777', 138, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'PW Nova', '140766', 144, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Baltimore City Academy', '144871', 148, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Chiefs United', '140359', 149, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Christos FC', '140728', 142, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Germantown City FC', '136127', 150, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Alianza FC', '137726', 151, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Cavaliers United FC', '143291', 152, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Drita SC', '143309', 153, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Hoverla FC', '140960', 154, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Imlay City FC', '137728', 155, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Inter Detroit', '143114', 156, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Intra United SC', '141264', 157, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Livonia City FC', '137729', 158, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Monroe United', '141493', 159, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'World Class FC', '137727', 160, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Majestic SC', '115108', 161, d.id, 1
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
SELECT 'Terminus FC', '115815', 162, d.id, 1
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
SELECT 'Prima FC', '115105', 163, d.id, 1
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
SELECT 'Peachtree FC', '115101', 164, d.id, 1
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
SELECT 'Bel Calcio FC', '115106', 165, d.id, 1
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
SELECT 'Georgia United FC', '133651', 166, d.id, 1
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
SELECT 'Buckhead SC', '115104', 167, d.id, 1
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
SELECT 'Alliance SC', '115107', 168, d.id, 1
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
SELECT 'SC Gwinnett', '119159', 169, d.id, 1
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
SELECT 'Foro SC', '136241', 170, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Trinity Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Carrollton Old Boyz', '137416', 171, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Trinity Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'AC Arlington FC', '136243', 172, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Trinity Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Texas Coyotes', '142766', 173, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Trinity Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Texas Rage FC', '136242', 174, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Trinity Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philadelphia SC Over-30', '142479', 175, d.id, 1
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'State Cups'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
