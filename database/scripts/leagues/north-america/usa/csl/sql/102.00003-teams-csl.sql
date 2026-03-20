-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - CSL
-- Total Records: 98
-- NOTE: division_id is now part of team identity (NOT NULL)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FC Sandzak', '116433', 10000, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Block FC', '116409', 10001, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan Kickers', '116451', 10002, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Polonia SC', '116472', 10003, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Ukrainians', '116465', 10004, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Hoboken FC 1912 II', '116437', 10005, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Laberia FC', '116442', 10006, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers II', '116416', 10007, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan Celtic', '114828', 10008, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Zum Schneider FC 03 II', '116498', 10009, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FC Ulqini', '116435', 10010, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Block FC II', '116410', 10001, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Polonia SC II', '116473', 10003, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Ukrainians II', '116466', 10004, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers III', '116417', 10007, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FC Sandzak II', '116434', 10000, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Zum Schneider FC 03 III', '116499', 10009, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Hoboken FC 1912 III', '116438', 10005, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Laberia FC II', '116443', 10006, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan Kickers II', '116452', 10002, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan Celtic II', '116445', 10008, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FC Ulqini II', '116436', 10010, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY International FC II', '116459', 10011, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Brooklyn City FC', '116413', 10012, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Stal Mielec NY', '116490', 10013, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Vibes FC', '116492', 10014, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Galicia', '116456', 10015, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Shamrocks', '116462', 10016, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Finest FC', '116468', 10017, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Sporting Astoria South Bronx United', '116487', 10018, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'ERFC', '117364', 10019, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Williamsburg International FC', '116495', 10020, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FC Japan', '116430', 10021, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'SC Eintracht', '116476', 10022, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Kickoff FC', '117235', 10023, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Yemen United SC', '118636', 10024, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers Lower East', '116422', 10007, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Vllaznia NYC', '118202', 10025, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Desportiva Sociedad NY', '116427', 10026, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Finest FC II', '116469', 10017, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Sporting Astoria South Bronx United II', '116488', 10018, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY International FC III', '117234', 10011, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Shamrocks II', '116463', 10016, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Williamsburg International FC II', '116496', 10020, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Brooklyn City FC II', '116414', 10012, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers Lower East II', '116423', 10007, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Stal Mielec NY II', '116491', 10013, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Kickoff FC II', '117236', 10023, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Yemen United SC II', '118637', 10024, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Vllaznia NYC II', '118203', 10025, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'SC Eintracht II', '116477', 10022, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'ERFC II', '117370', 10019, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FC Japan II', '116431', 10021, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Galicia II', '116457', 10015, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Vibes FC II', '116493', 10014, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Desportiva Sociedad NY II', '116428', 10026, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Braza Futbol', '118354', 10027, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'SC Football Crew', '119337', 10028, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Athletic Club II', '116454', 10029, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Sporting Astoria SBU Dawgz', '116486', 10030, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FanDuel FC', '116429', 10031, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Aurora FC', '116406', 10032, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Riverside Squires', '116475', 10033, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Panatha USA', '116471', 10034, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Junior Mafia FC', '116439', 10035, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Legacy FC', '116460', 10036, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Brooklyn City FC III', '118357', 10012, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'C.A. Islas Malvinas', '116415', 10037, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Ollama FC', '116470', 10038, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Barnstonworth Rovers FC', '116407', 10039, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'ERFC Hudson', '118356', 10019, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Warriors NYC', '116494', 10040, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Williamsburg International FC III', '116497', 10020, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Titans FC', '118353', 10041, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NYC AlphaStars Club', '116467', 10042, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan Celtic Bhoys', '116444', 10008, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Al-Asad', '116405', 10043, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'SC Gjoa', '116479', 10044, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Brooklyn New York SC', '118355', 10045, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Pelham Parkway FC', '119075', 10046, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Bolivia Si Existe FC', '124917', 10047, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Desportiva Sociedad NY Samba', '118361', 10048, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers Lower East III', '135071', 10007, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FC Hudson United', '138544', 10049, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FC Kraja', '134746', 10050, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FC Rush', '140355', 10051, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Tiercel City FC', '134573', 10052, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers Old Boys', '116421', 10007, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan Kickers Legends', '116453', 10002, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Cozmoz FC', '116424', 10053, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers Legends', '116420', 10007, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Sporting Astoria SBU OG''S', '116489', 10030, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'SC Gjoa Over-40', '116480', 10044, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan Celtic Masters', '116447', 10008, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Polonez SC', '119370', 10054, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'SC Eintracht Legends', '116478', 10022, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Shamrocks Legends', '116464', 10016, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Barnstonworth Rovers FC Old Boys', '116408', 10039, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2025/2026'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
