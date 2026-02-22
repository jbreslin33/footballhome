-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - CSL
-- Total Records: 101
-- NOTE: division_id is now part of team identity (NOT NULL)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers Red', '6783', 121, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Athletic Club', '6817', 124, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Richmond County FC', '6843', 120, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FC Sandzak', '6797', 10003, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Borgetto FC', '6768', 10004, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Shamrocks', '6828', 10005, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan Kickers', '6811', 10006, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Kelmendi FC NY', '6802', 10007, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Polonia SC', '6841', 10008, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Zum Schneider FC 03 II', '6858', 123, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Missile FC', '6814', 10010, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers Red II', '6784', 121, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Polonia SC II', '6842', 10008, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Borgetto FC II', '6770', 10004, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan Kickers II', '6813', 10006, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Shamrocks II', '6831', 10005, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Athletic Club II', '6818', 124, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FC Sandzak II', '6798', 10003, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Richmond County FC II', '6844', 120, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Zum Schneider FC 03 III', '6859', 123, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Kelmendi FC NY II', '6803', 10007, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Missile FC II', '6815', 10010, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Ukrainians', '6832', 10011, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NYPD FC', '6836', 10012, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY International FC', '6822', 119, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan Celtic II', '6808', 10014, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Block FC', '6766', 10015, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers United', '6779', 121, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Hoboken FC 1912 II', '6800', 115, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Brooklyn City FC', '6772', 10017, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Stal Mielec NY', '6850', 10018, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FC Japan', '6794', 10019, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Williamsburg International FC', '6854', 10020, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Yemen United SC', '6857', 10021, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan FC', '6908', 10022, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Desportiva Sociedad', '6788', 10023, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'KidSuper Samba AC II', '6804', 10024, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'SC Gjoa Yellow Hook', '6852', 10025, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'SC Eintracht', '6846', 10026, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'CD Iberia', '6774', 10027, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers United II', '6781', 121, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Ukrainians II', '6834', 10011, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Hoboken FC 1912 III', '6801', 115, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Yemen United SC II', '7213', 10021, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NYPD FC II', '6837', 10012, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY International FC II', '6823', 119, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan Celtic III', '6809', 10014, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Desportiva Sociedad II', '6791', 10023, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'KidSuper Samba AC III', '7584', 10024, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'CD Iberia II', '7678', 10027, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Brooklyn City FC II', '6773', 10017, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'SC Eintracht II', '6848', 10026, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan FC II', '7212', 10022, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'SC Gjoa Yellow Hook II', '7211', 10025, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Block FC II', '6767', 10015, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Williamsburg International FC II', '6856', 10020, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FC Japan II', '6795', 10019, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Stal Mielec NY II', '6851', 10018, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers Green', '6776', 121, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Falco FC', '6793', 100, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers Young Boys', '6785', 121, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Pancyprian Freedoms II', '6826', 116, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Albanians FC', '6816', 10030, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Laberia FC', '6805', 10031, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Afghan Ittihad FC', '6759', 10032, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Barnstonworth Rovers FC', '6762', 10033, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Panatha USA', '6840', 10034, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Aurora FC', '6761', 10035, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Vera FC', '7717', 10036, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lansdowne Yonkers FC Metro', '6807', 114, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Legacy FC', '6909', 10038, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Guyana Sunnydale Veterans FC', '7885', 10039, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Galicia', '6820', 10040, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NYC AlphaStars Club', '6835', 10041, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Tibet FC', '6853', 10042, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Vibes FC', '7598', 10043, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers 1999', '6775', 121, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Williamsburg International FC III', '6855', 10020, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Desportiva Sociedad City', '6789', 10023, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Croatia', '6819', 10044, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'FC Partizani NY', '6796', 10045, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Desportiva Sociedad Fury', '6790', 10023, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Caribbean FCA', '12292', 112, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Riverside Squires', '10041', 10047, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Astoria Knights II', '11550', 10048, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Bajas FC', '9849', 10049, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Clarkstown SC', '12632', 10050, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Soccer Legion FC Men', '8335', 10051, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NYPD FC Veterans', '6838', 10012, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Ridgewood Romac SC', '6845', 10052, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan Kickers Legends', '6812', 10006, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Manhattan Celtic Masters', '6810', 10014, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers Legends', '6780', 121, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'SC Gjoa Over-40', '6849', 10025, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Cozmoz FC', '6787', 10053, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'SC Eintracht Legends', '6847', 10026, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Barnstonworth Rovers Old Boys', '6763', 10033, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Doxa SC Legends', '7883', 118, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers Orange', '6782', 121, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Shamrocks Legends', '6829', 10005, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Irish SC Legends', '6825', 10055, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
