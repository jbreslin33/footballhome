-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - CSL
-- Total Records: 1342
-- NOTE: division_id is now part of team identity (NOT NULL)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers Red', '6783', 10000, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Athletic Club', '6817', 10001, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Richmond County FC', '6843', 10002, d.id, 3
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
SELECT 'Zum Schneider FC 03 II', '6858', 10009, d.id, 3
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
SELECT 'Central Park Rangers Red II', '6784', 10000, d.id, 3
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
SELECT 'NY Athletic Club II', '6818', 10001, d.id, 3
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
SELECT 'Richmond County FC II', '6844', 10002, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Zum Schneider FC 03 III', '6859', 10009, d.id, 3
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
SELECT 'NY International FC', '6822', 10013, d.id, 3
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
SELECT 'Central Park Rangers United', '6779', 10000, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Hoboken FC 1912 II', '6800', 10016, d.id, 3
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
SELECT 'Central Park Rangers United II', '6781', 10000, d.id, 3
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
SELECT 'Hoboken FC 1912 III', '6801', 10016, d.id, 3
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
SELECT 'NY International FC II', '6823', 10013, d.id, 3
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
SELECT 'Central Park Rangers Green', '6776', 10000, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Falco FC', '6793', 10028, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers Young Boys', '6785', 10000, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'NY Pancyprian Freedoms II', '6826', 10029, d.id, 3
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
SELECT 'Lansdowne Yonkers FC Metro', '6807', 10037, d.id, 3
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
SELECT 'Central Park Rangers 1999', '6775', 10000, d.id, 3
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
SELECT 'Caribbean FCA', '12292', 10046, d.id, 3
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
SELECT 'Central Park Rangers Legends', '6780', 10000, d.id, 3
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
SELECT 'Doxa SC Legends', '7883', 10054, d.id, 3
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Central Park Rangers Orange', '6782', 10000, d.id, 3
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
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 114828', '114828', 10056, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116405', '116405', 10057, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116406', '116406', 10058, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116407', '116407', 10059, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116408', '116408', 10060, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116409', '116409', 10061, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116410', '116410', 10062, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116413', '116413', 10063, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116414', '116414', 10064, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116415', '116415', 10065, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116416', '116416', 10066, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116417', '116417', 10067, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116420', '116420', 10068, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116421', '116421', 10069, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116422', '116422', 10070, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116423', '116423', 10071, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116424', '116424', 10072, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116429', '116429', 10073, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116430', '116430', 10074, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116431', '116431', 10075, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116433', '116433', 10076, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116434', '116434', 10077, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116437', '116437', 10078, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116438', '116438', 10079, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116439', '116439', 10080, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116442', '116442', 10081, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116443', '116443', 10082, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116444', '116444', 10083, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116445', '116445', 10084, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116447', '116447', 10085, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116451', '116451', 10086, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116452', '116452', 10087, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116453', '116453', 10088, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116454', '116454', 10089, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116456', '116456', 10090, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116457', '116457', 10091, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116459', '116459', 10092, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116460', '116460', 10093, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116462', '116462', 10094, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116463', '116463', 10095, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116464', '116464', 10096, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116465', '116465', 10097, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116466', '116466', 10098, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116467', '116467', 10099, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116468', '116468', 10100, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116469', '116469', 10101, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116470', '116470', 10102, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116471', '116471', 10103, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116472', '116472', 10104, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116473', '116473', 10105, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116475', '116475', 10106, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116476', '116476', 10107, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116477', '116477', 10108, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116478', '116478', 10109, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116479', '116479', 10110, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116480', '116480', 10111, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116486', '116486', 10112, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116487', '116487', 10113, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116488', '116488', 10114, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116489', '116489', 10115, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116490', '116490', 10116, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116491', '116491', 10117, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116492', '116492', 10118, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116493', '116493', 10119, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116494', '116494', 10120, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116495', '116495', 10121, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116496', '116496', 10122, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116497', '116497', 10123, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116498', '116498', 10124, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 116499', '116499', 10125, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 117234', '117234', 10126, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 117235', '117235', 10127, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 117236', '117236', 10128, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 117364', '117364', 10129, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 117370', '117370', 10130, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 118202', '118202', 10131, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 118203', '118203', 10132, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 118353', '118353', 10133, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 118354', '118354', 10134, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 118355', '118355', 10135, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 118356', '118356', 10136, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 118357', '118357', 10137, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 118636', '118636', 10138, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 118637', '118637', 10139, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 119075', '119075', 10140, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 119337', '119337', 10141, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 119370', '119370', 10142, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 124917', '124917', 10143, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227496', '227496', 10144, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227500', '227500', 10145, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227503', '227503', 10146, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227505', '227505', 10147, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227509', '227509', 10148, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227512', '227512', 10149, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227513', '227513', 10150, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227515', '227515', 10151, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227520', '227520', 10152, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227524', '227524', 10153, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227530', '227530', 10154, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227533', '227533', 10155, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227535', '227535', 10156, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227537', '227537', 10157, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227543', '227543', 10158, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227550', '227550', 10159, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227551', '227551', 10160, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227558', '227558', 10161, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227560', '227560', 10162, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227564', '227564', 10163, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227565', '227565', 10164, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227567', '227567', 10165, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227572', '227572', 10166, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227577', '227577', 10167, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227579', '227579', 10168, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227580', '227580', 10169, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227588', '227588', 10170, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227591', '227591', 10171, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227592', '227592', 10172, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227596', '227596', 10173, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 227598', '227598', 10174, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230063', '230063', 10175, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230064', '230064', 10176, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230065', '230065', 10177, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230066', '230066', 10178, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230068', '230068', 10179, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230069', '230069', 10180, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230070', '230070', 10181, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230071', '230071', 10182, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230072', '230072', 10183, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230073', '230073', 10184, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230074', '230074', 10185, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230100', '230100', 10186, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230101', '230101', 10187, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230102', '230102', 10188, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230104', '230104', 10189, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230105', '230105', 10190, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230107', '230107', 10191, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230108', '230108', 10192, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230109', '230109', 10193, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230111', '230111', 10194, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230112', '230112', 10195, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230113', '230113', 10196, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230114', '230114', 10197, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230115', '230115', 10198, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230116', '230116', 10199, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230117', '230117', 10200, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230118', '230118', 10201, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230119', '230119', 10202, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230120', '230120', 10203, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230121', '230121', 10204, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230122', '230122', 10205, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230123', '230123', 10206, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230124', '230124', 10207, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230125', '230125', 10208, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230126', '230126', 10209, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230127', '230127', 10210, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230128', '230128', 10211, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230129', '230129', 10212, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230130', '230130', 10213, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230132', '230132', 10214, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230134', '230134', 10215, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230135', '230135', 10216, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230136', '230136', 10217, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230137', '230137', 10218, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230138', '230138', 10219, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230139', '230139', 10220, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230140', '230140', 10221, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230148', '230148', 10222, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230149', '230149', 10223, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230150', '230150', 10224, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230152', '230152', 10225, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230153', '230153', 10226, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230154', '230154', 10227, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230155', '230155', 10228, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230156', '230156', 10229, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230157', '230157', 10230, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230160', '230160', 10231, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 230161', '230161', 10232, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231156', '231156', 10233, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231158', '231158', 10234, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231159', '231159', 10235, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231160', '231160', 10236, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231161', '231161', 10237, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231162', '231162', 10238, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231165', '231165', 10239, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231166', '231166', 10240, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231167', '231167', 10241, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231168', '231168', 10242, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231169', '231169', 10243, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231170', '231170', 10244, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231172', '231172', 10245, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231175', '231175', 10246, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231176', '231176', 10247, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231177', '231177', 10248, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231178', '231178', 10249, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231181', '231181', 10250, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231182', '231182', 10251, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231183', '231183', 10252, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231184', '231184', 10253, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231185', '231185', 10254, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231186', '231186', 10255, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231291', '231291', 10256, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231293', '231293', 10257, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231294', '231294', 10258, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231295', '231295', 10259, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231297', '231297', 10260, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231300', '231300', 10261, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231301', '231301', 10262, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231302', '231302', 10263, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231303', '231303', 10264, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231305', '231305', 10265, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231306', '231306', 10266, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231307', '231307', 10267, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231308', '231308', 10268, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231309', '231309', 10269, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231310', '231310', 10270, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231311', '231311', 10271, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231314', '231314', 10272, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231315', '231315', 10273, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231316', '231316', 10274, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231317', '231317', 10275, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231318', '231318', 10276, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231319', '231319', 10277, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231321', '231321', 10278, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231322', '231322', 10279, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231323', '231323', 10280, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231324', '231324', 10281, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231326', '231326', 10282, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231327', '231327', 10283, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231329', '231329', 10284, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231331', '231331', 10285, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231334', '231334', 10286, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231335', '231335', 10287, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231336', '231336', 10288, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231337', '231337', 10289, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231338', '231338', 10290, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231339', '231339', 10291, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231342', '231342', 10292, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231343', '231343', 10293, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231344', '231344', 10294, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231345', '231345', 10295, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 231346', '231346', 10296, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232491', '232491', 10297, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232493', '232493', 10298, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232494', '232494', 10299, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232495', '232495', 10300, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232497', '232497', 10301, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232498', '232498', 10302, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232500', '232500', 10303, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232501', '232501', 10304, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232502', '232502', 10305, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232503', '232503', 10306, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232505', '232505', 10307, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232506', '232506', 10308, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232507', '232507', 10309, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232508', '232508', 10310, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232509', '232509', 10311, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232510', '232510', 10312, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232511', '232511', 10313, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232513', '232513', 10314, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232514', '232514', 10315, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232515', '232515', 10316, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232516', '232516', 10317, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232517', '232517', 10318, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232518', '232518', 10319, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232519', '232519', 10320, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232521', '232521', 10321, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232523', '232523', 10322, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232524', '232524', 10323, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232525', '232525', 10324, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232526', '232526', 10325, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232527', '232527', 10326, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232529', '232529', 10327, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232531', '232531', 10328, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232534', '232534', 10329, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232535', '232535', 10330, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232536', '232536', 10331, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232537', '232537', 10332, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232538', '232538', 10333, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232539', '232539', 10334, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232542', '232542', 10335, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232543', '232543', 10336, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232544', '232544', 10337, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 232546', '232546', 10338, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233705', '233705', 10339, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233706', '233706', 10340, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233707', '233707', 10341, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233708', '233708', 10342, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233710', '233710', 10343, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233711', '233711', 10344, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233712', '233712', 10345, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233713', '233713', 10346, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233714', '233714', 10347, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233715', '233715', 10348, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233718', '233718', 10349, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233719', '233719', 10350, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233729', '233729', 10351, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233730', '233730', 10352, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233731', '233731', 10353, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233732', '233732', 10354, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233733', '233733', 10355, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233735', '233735', 10356, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233736', '233736', 10357, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233738', '233738', 10358, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233739', '233739', 10359, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233740', '233740', 10360, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233742', '233742', 10361, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233743', '233743', 10362, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233744', '233744', 10363, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233745', '233745', 10364, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233746', '233746', 10365, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233747', '233747', 10366, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233772', '233772', 10367, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233773', '233773', 10368, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233774', '233774', 10369, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233775', '233775', 10370, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233776', '233776', 10371, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233777', '233777', 10372, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233778', '233778', 10373, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233779', '233779', 10374, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233780', '233780', 10375, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233789', '233789', 10376, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233790', '233790', 10377, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233791', '233791', 10378, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233792', '233792', 10379, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233797', '233797', 10380, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233853', '233853', 10381, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233854', '233854', 10382, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233855', '233855', 10383, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233856', '233856', 10384, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 233857', '233857', 10385, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238207', '238207', 10386, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238209', '238209', 10387, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238210', '238210', 10388, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238211', '238211', 10389, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238212', '238212', 10390, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238215', '238215', 10391, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238216', '238216', 10392, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238217', '238217', 10393, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238218', '238218', 10394, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238219', '238219', 10395, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238220', '238220', 10396, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238222', '238222', 10397, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238223', '238223', 10398, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238225', '238225', 10399, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238226', '238226', 10400, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238541', '238541', 10401, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238542', '238542', 10402, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238543', '238543', 10403, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238544', '238544', 10404, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238545', '238545', 10405, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238548', '238548', 10406, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238549', '238549', 10407, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238550', '238550', 10408, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238551', '238551', 10409, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238552', '238552', 10410, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238555', '238555', 10411, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238556', '238556', 10412, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238557', '238557', 10413, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238558', '238558', 10414, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238559', '238559', 10415, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238560', '238560', 10416, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238562', '238562', 10417, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238563', '238563', 10418, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238564', '238564', 10419, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238565', '238565', 10420, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238566', '238566', 10421, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238569', '238569', 10422, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238570', '238570', 10423, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238571', '238571', 10424, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238572', '238572', 10425, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238573', '238573', 10426, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238575', '238575', 10427, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238576', '238576', 10428, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238577', '238577', 10429, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238578', '238578', 10430, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238579', '238579', 10431, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 238583', '238583', 10432, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29381', '29381', 10433, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29384', '29384', 10434, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29385', '29385', 10435, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29386', '29386', 10436, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29389', '29389', 10437, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29402', '29402', 10438, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29404', '29404', 10439, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29406', '29406', 10440, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29408', '29408', 10441, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29412', '29412', 10442, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29413', '29413', 10443, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29417', '29417', 10444, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29418', '29418', 10445, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29419', '29419', 10446, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29421', '29421', 10447, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29425', '29425', 10448, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29426', '29426', 10449, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29429', '29429', 10450, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29430', '29430', 10451, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29431', '29431', 10452, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29432', '29432', 10453, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29433', '29433', 10454, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29436', '29436', 10455, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29439', '29439', 10456, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29440', '29440', 10457, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29441', '29441', 10458, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29443', '29443', 10459, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29444', '29444', 10460, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29446', '29446', 10461, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29447', '29447', 10462, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29449', '29449', 10463, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29452', '29452', 10464, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29455', '29455', 10465, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29457', '29457', 10466, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29459', '29459', 10467, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29461', '29461', 10468, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29463', '29463', 10469, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29467', '29467', 10470, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29468', '29468', 10471, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29472', '29472', 10472, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29473', '29473', 10473, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29474', '29474', 10474, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29476', '29476', 10475, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29480', '29480', 10476, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29481', '29481', 10477, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29484', '29484', 10478, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29485', '29485', 10479, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29486', '29486', 10480, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29487', '29487', 10481, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29488', '29488', 10482, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29491', '29491', 10483, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29494', '29494', 10484, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29495', '29495', 10485, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29496', '29496', 10486, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29498', '29498', 10487, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29499', '29499', 10488, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29592', '29592', 10489, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29593', '29593', 10490, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29594', '29594', 10491, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29595', '29595', 10492, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29596', '29596', 10493, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29597', '29597', 10494, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29598', '29598', 10495, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29601', '29601', 10496, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29602', '29602', 10497, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29603', '29603', 10498, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29604', '29604', 10499, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29605', '29605', 10500, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29608', '29608', 10501, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29609', '29609', 10502, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29610', '29610', 10503, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29611', '29611', 10504, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29612', '29612', 10505, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29613', '29613', 10506, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29616', '29616', 10507, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29617', '29617', 10508, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29618', '29618', 10509, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29619', '29619', 10510, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29620', '29620', 10511, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29621', '29621', 10512, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29624', '29624', 10513, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29625', '29625', 10514, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29626', '29626', 10515, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29627', '29627', 10516, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29628', '29628', 10517, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29629', '29629', 10518, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29630', '29630', 10519, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29632', '29632', 10520, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29633', '29633', 10521, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29634', '29634', 10522, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29635', '29635', 10523, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29636', '29636', 10524, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29637', '29637', 10525, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29638', '29638', 10526, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29640', '29640', 10527, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29641', '29641', 10528, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29642', '29642', 10529, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29643', '29643', 10530, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29644', '29644', 10531, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29645', '29645', 10532, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29646', '29646', 10533, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29647', '29647', 10534, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29648', '29648', 10535, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29650', '29650', 10536, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29651', '29651', 10537, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29652', '29652', 10538, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29653', '29653', 10539, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29655', '29655', 10540, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29656', '29656', 10541, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29658', '29658', 10542, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29659', '29659', 10543, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29660', '29660', 10544, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29661', '29661', 10545, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29669', '29669', 10546, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29670', '29670', 10547, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29671', '29671', 10548, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29672', '29672', 10549, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29673', '29673', 10550, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29674', '29674', 10551, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29675', '29675', 10552, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29678', '29678', 10553, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29679', '29679', 10554, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29680', '29680', 10555, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29681', '29681', 10556, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29682', '29682', 10557, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29685', '29685', 10558, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29686', '29686', 10559, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29687', '29687', 10560, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29688', '29688', 10561, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29689', '29689', 10562, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29690', '29690', 10563, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29694', '29694', 10564, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29695', '29695', 10565, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29696', '29696', 10566, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29697', '29697', 10567, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29698', '29698', 10568, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29699', '29699', 10569, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29702', '29702', 10570, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29703', '29703', 10571, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29704', '29704', 10572, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29705', '29705', 10573, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29706', '29706', 10574, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29707', '29707', 10575, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29708', '29708', 10576, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29710', '29710', 10577, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29711', '29711', 10578, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29712', '29712', 10579, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29713', '29713', 10580, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29714', '29714', 10581, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29715', '29715', 10582, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29717', '29717', 10583, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29719', '29719', 10584, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29720', '29720', 10585, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29721', '29721', 10586, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29722', '29722', 10587, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29723', '29723', 10588, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29724', '29724', 10589, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29725', '29725', 10590, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29726', '29726', 10591, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29727', '29727', 10592, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29729', '29729', 10593, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29730', '29730', 10594, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29731', '29731', 10595, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29732', '29732', 10596, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29734', '29734', 10597, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29735', '29735', 10598, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29737', '29737', 10599, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29738', '29738', 10600, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29739', '29739', 10601, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 29740', '29740', 10602, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30044', '30044', 10603, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30045', '30045', 10604, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30046', '30046', 10605, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30047', '30047', 10606, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30048', '30048', 10607, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30272', '30272', 10608, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30273', '30273', 10609, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30274', '30274', 10610, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30275', '30275', 10611, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30277', '30277', 10612, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30279', '30279', 10613, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30280', '30280', 10614, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30282', '30282', 10615, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30283', '30283', 10616, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30285', '30285', 10617, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30287', '30287', 10618, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30288', '30288', 10619, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30290', '30290', 10620, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30291', '30291', 10621, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30293', '30293', 10622, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30294', '30294', 10623, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30295', '30295', 10624, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30297', '30297', 10625, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30298', '30298', 10626, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30299', '30299', 10627, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30301', '30301', 10628, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30302', '30302', 10629, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30304', '30304', 10630, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30306', '30306', 10631, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30307', '30307', 10632, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30309', '30309', 10633, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30310', '30310', 10634, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30312', '30312', 10635, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30313', '30313', 10636, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30314', '30314', 10637, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30316', '30316', 10638, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30317', '30317', 10639, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30318', '30318', 10640, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30319', '30319', 10641, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30321', '30321', 10642, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30322', '30322', 10643, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30324', '30324', 10644, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30325', '30325', 10645, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30326', '30326', 10646, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30328', '30328', 10647, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30329', '30329', 10648, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30330', '30330', 10649, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30331', '30331', 10650, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30333', '30333', 10651, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30335', '30335', 10652, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30336', '30336', 10653, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30337', '30337', 10654, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30339', '30339', 10655, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30341', '30341', 10656, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30342', '30342', 10657, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30470', '30470', 10658, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30471', '30471', 10659, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30472', '30472', 10660, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30473', '30473', 10661, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30474', '30474', 10662, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30475', '30475', 10663, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30476', '30476', 10664, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30477', '30477', 10665, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30478', '30478', 10666, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30479', '30479', 10667, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30480', '30480', 10668, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30481', '30481', 10669, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30482', '30482', 10670, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30483', '30483', 10671, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30484', '30484', 10672, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30485', '30485', 10673, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30486', '30486', 10674, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30487', '30487', 10675, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30488', '30488', 10676, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30489', '30489', 10677, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30490', '30490', 10678, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30491', '30491', 10679, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30492', '30492', 10680, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30493', '30493', 10681, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30494', '30494', 10682, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30495', '30495', 10683, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30496', '30496', 10684, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30497', '30497', 10685, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30498', '30498', 10686, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30499', '30499', 10687, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30508', '30508', 10688, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30509', '30509', 10689, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30510', '30510', 10690, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30520', '30520', 10691, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30521', '30521', 10692, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30522', '30522', 10693, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30523', '30523', 10694, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30524', '30524', 10695, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30525', '30525', 10696, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30526', '30526', 10697, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30527', '30527', 10698, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30528', '30528', 10699, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30529', '30529', 10700, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30530', '30530', 10701, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30531', '30531', 10702, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30534', '30534', 10703, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30535', '30535', 10704, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30536', '30536', 10705, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30537', '30537', 10706, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30538', '30538', 10707, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30539', '30539', 10708, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30540', '30540', 10709, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30541', '30541', 10710, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30542', '30542', 10711, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30543', '30543', 10712, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30544', '30544', 10713, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30545', '30545', 10714, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30546', '30546', 10715, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30547', '30547', 10716, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30548', '30548', 10717, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30549', '30549', 10718, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30550', '30550', 10719, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30551', '30551', 10720, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30552', '30552', 10721, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30553', '30553', 10722, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 30554', '30554', 10723, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31463', '31463', 10724, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31464', '31464', 10725, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31465', '31465', 10726, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31466', '31466', 10727, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31467', '31467', 10728, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31468', '31468', 10729, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31469', '31469', 10730, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31470', '31470', 10731, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31471', '31471', 10732, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31472', '31472', 10733, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31473', '31473', 10734, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31474', '31474', 10735, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31545', '31545', 10736, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31546', '31546', 10737, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31547', '31547', 10738, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31548', '31548', 10739, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31549', '31549', 10740, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31607', '31607', 10741, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31608', '31608', 10742, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31609', '31609', 10743, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31610', '31610', 10744, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31611', '31611', 10745, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31612', '31612', 10746, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31613', '31613', 10747, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31614', '31614', 10748, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31615', '31615', 10749, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31616', '31616', 10750, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31617', '31617', 10751, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31618', '31618', 10752, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31619', '31619', 10753, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31620', '31620', 10754, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31621', '31621', 10755, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31660', '31660', 10756, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31661', '31661', 10757, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31662', '31662', 10758, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31663', '31663', 10759, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31664', '31664', 10760, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31665', '31665', 10761, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31666', '31666', 10762, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31667', '31667', 10763, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31668', '31668', 10764, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31669', '31669', 10765, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31670', '31670', 10766, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31671', '31671', 10767, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31672', '31672', 10768, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31673', '31673', 10769, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31674', '31674', 10770, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31675', '31675', 10771, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31676', '31676', 10772, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31677', '31677', 10773, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31678', '31678', 10774, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 31679', '31679', 10775, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37173', '37173', 10776, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37175', '37175', 10777, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37177', '37177', 10778, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37178', '37178', 10779, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37179', '37179', 10780, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37180', '37180', 10781, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37181', '37181', 10782, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37182', '37182', 10783, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37183', '37183', 10784, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37189', '37189', 10785, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37190', '37190', 10786, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37191', '37191', 10787, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37192', '37192', 10788, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37193', '37193', 10789, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37194', '37194', 10790, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37195', '37195', 10791, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37196', '37196', 10792, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37197', '37197', 10793, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37198', '37198', 10794, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37199', '37199', 10795, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37200', '37200', 10796, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37201', '37201', 10797, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37202', '37202', 10798, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37203', '37203', 10799, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37204', '37204', 10800, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37205', '37205', 10801, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37206', '37206', 10802, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37207', '37207', 10803, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37208', '37208', 10804, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37209', '37209', 10805, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37210', '37210', 10806, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37211', '37211', 10807, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37212', '37212', 10808, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37213', '37213', 10809, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37214', '37214', 10810, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37216', '37216', 10811, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37217', '37217', 10812, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 37224', '37224', 10813, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38968', '38968', 10814, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38969', '38969', 10815, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38970', '38970', 10816, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38971', '38971', 10817, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38972', '38972', 10818, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38973', '38973', 10819, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38974', '38974', 10820, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38975', '38975', 10821, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38976', '38976', 10822, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38977', '38977', 10823, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38978', '38978', 10824, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38979', '38979', 10825, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38980', '38980', 10826, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38981', '38981', 10827, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38982', '38982', 10828, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38983', '38983', 10829, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38984', '38984', 10830, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 38985', '38985', 10831, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39296', '39296', 10832, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39297', '39297', 10833, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39298', '39298', 10834, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39299', '39299', 10835, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39300', '39300', 10836, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39301', '39301', 10837, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39302', '39302', 10838, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39303', '39303', 10839, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39304', '39304', 10840, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39305', '39305', 10841, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39306', '39306', 10842, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39329', '39329', 10843, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39425', '39425', 10844, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39426', '39426', 10845, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39427', '39427', 10846, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39428', '39428', 10847, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39429', '39429', 10848, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39431', '39431', 10849, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39432', '39432', 10850, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39434', '39434', 10851, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39435', '39435', 10852, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39436', '39436', 10853, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39582', '39582', 10854, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39605', '39605', 10855, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39606', '39606', 10856, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39609', '39609', 10857, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39610', '39610', 10858, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39611', '39611', 10859, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39612', '39612', 10860, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39613', '39613', 10861, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39614', '39614', 10862, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39615', '39615', 10863, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39616', '39616', 10864, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39617', '39617', 10865, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39757', '39757', 10866, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39834', '39834', 10867, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39835', '39835', 10868, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 39976', '39976', 10869, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40386', '40386', 10870, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40387', '40387', 10871, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40388', '40388', 10872, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40389', '40389', 10873, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40395', '40395', 10874, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40396', '40396', 10875, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40397', '40397', 10876, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40400', '40400', 10877, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40401', '40401', 10878, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40402', '40402', 10879, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40403', '40403', 10880, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40427', '40427', 10881, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40428', '40428', 10882, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40429', '40429', 10883, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40430', '40430', 10884, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40432', '40432', 10885, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40433', '40433', 10886, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40434', '40434', 10887, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40435', '40435', 10888, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40437', '40437', 10889, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40438', '40438', 10890, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40439', '40439', 10891, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40440', '40440', 10892, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40449', '40449', 10893, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40450', '40450', 10894, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40451', '40451', 10895, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40452', '40452', 10896, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40456', '40456', 10897, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40457', '40457', 10898, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40458', '40458', 10899, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40459', '40459', 10900, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40460', '40460', 10901, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40461', '40461', 10902, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40462', '40462', 10903, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40463', '40463', 10904, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 40688', '40688', 10905, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41546', '41546', 10906, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41547', '41547', 10907, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41550', '41550', 10908, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41551', '41551', 10909, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41554', '41554', 10910, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41557', '41557', 10911, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41558', '41558', 10912, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41561', '41561', 10913, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41562', '41562', 10914, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41564', '41564', 10915, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41566', '41566', 10916, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41568', '41568', 10917, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41569', '41569', 10918, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41571', '41571', 10919, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41572', '41572', 10920, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41576', '41576', 10921, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41577', '41577', 10922, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41578', '41578', 10923, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41580', '41580', 10924, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41583', '41583', 10925, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41584', '41584', 10926, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41589', '41589', 10927, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41591', '41591', 10928, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41593', '41593', 10929, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41594', '41594', 10930, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41597', '41597', 10931, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41598', '41598', 10932, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41601', '41601', 10933, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41604', '41604', 10934, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41605', '41605', 10935, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41608', '41608', 10936, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41609', '41609', 10937, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41611', '41611', 10938, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41613', '41613', 10939, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41615', '41615', 10940, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41616', '41616', 10941, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41618', '41618', 10942, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41619', '41619', 10943, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41623', '41623', 10944, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41624', '41624', 10945, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41625', '41625', 10946, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41627', '41627', 10947, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41630', '41630', 10948, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41631', '41631', 10949, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41634', '41634', 10950, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41636', '41636', 10951, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41637', '41637', 10952, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41638', '41638', 10953, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41640', '41640', 10954, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41643', '41643', 10955, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41646', '41646', 10956, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41762', '41762', 10957, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41763', '41763', 10958, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41764', '41764', 10959, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41765', '41765', 10960, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41767', '41767', 10961, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41769', '41769', 10962, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41771', '41771', 10963, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41774', '41774', 10964, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41775', '41775', 10965, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41778', '41778', 10966, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41779', '41779', 10967, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41781', '41781', 10968, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41782', '41782', 10969, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41784', '41784', 10970, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41785', '41785', 10971, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41787', '41787', 10972, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41789', '41789', 10973, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41790', '41790', 10974, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41791', '41791', 10975, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41794', '41794', 10976, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41801', '41801', 10977, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41802', '41802', 10978, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41803', '41803', 10979, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41804', '41804', 10980, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41805', '41805', 10981, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41806', '41806', 10982, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41807', '41807', 10983, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41808', '41808', 10984, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41810', '41810', 10985, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41811', '41811', 10986, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41812', '41812', 10987, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41813', '41813', 10988, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41814', '41814', 10989, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41816', '41816', 10990, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41818', '41818', 10991, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41819', '41819', 10992, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41820', '41820', 10993, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41821', '41821', 10994, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41822', '41822', 10995, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41825', '41825', 10996, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41826', '41826', 10997, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41827', '41827', 10998, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41828', '41828', 10999, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41829', '41829', 11000, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41830', '41830', 11001, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41833', '41833', 11002, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41834', '41834', 11003, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41835', '41835', 11004, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41836', '41836', 11005, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41837', '41837', 11006, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41838', '41838', 11007, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41840', '41840', 11008, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41841', '41841', 11009, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41843', '41843', 11010, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41844', '41844', 11011, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41845', '41845', 11012, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41846', '41846', 11013, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41847', '41847', 11014, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41848', '41848', 11015, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41850', '41850', 11016, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41851', '41851', 11017, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41852', '41852', 11018, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41853', '41853', 11019, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41854', '41854', 11020, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41856', '41856', 11021, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41857', '41857', 11022, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41858', '41858', 11023, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41859', '41859', 11024, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41860', '41860', 11025, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41861', '41861', 11026, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41862', '41862', 11027, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41863', '41863', 11028, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41865', '41865', 11029, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41867', '41867', 11030, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41868', '41868', 11031, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41869', '41869', 11032, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41870', '41870', 11033, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41972', '41972', 11034, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41973', '41973', 11035, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41974', '41974', 11036, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41975', '41975', 11037, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41976', '41976', 11038, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41977', '41977', 11039, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41978', '41978', 11040, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41979', '41979', 11041, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41980', '41980', 11042, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41981', '41981', 11043, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41982', '41982', 11044, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41983', '41983', 11045, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41984', '41984', 11046, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41985', '41985', 11047, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41986', '41986', 11048, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41987', '41987', 11049, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41988', '41988', 11050, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41989', '41989', 11051, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41990', '41990', 11052, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41991', '41991', 11053, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41992', '41992', 11054, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41993', '41993', 11055, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41994', '41994', 11056, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41995', '41995', 11057, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41996', '41996', 11058, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41997', '41997', 11059, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41998', '41998', 11060, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 41999', '41999', 11061, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42000', '42000', 11062, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42001', '42001', 11063, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42002', '42002', 11064, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42003', '42003', 11065, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42004', '42004', 11066, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42005', '42005', 11067, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42006', '42006', 11068, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42007', '42007', 11069, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42008', '42008', 11070, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42009', '42009', 11071, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42010', '42010', 11072, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42011', '42011', 11073, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42012', '42012', 11074, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42013', '42013', 11075, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42014', '42014', 11076, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42015', '42015', 11077, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42021', '42021', 11078, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42114', '42114', 11079, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42115', '42115', 11080, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42116', '42116', 11081, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42118', '42118', 11082, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42119', '42119', 11083, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42121', '42121', 11084, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42122', '42122', 11085, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42123', '42123', 11086, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42125', '42125', 11087, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42127', '42127', 11088, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42129', '42129', 11089, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42130', '42130', 11090, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42132', '42132', 11091, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42133', '42133', 11092, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42134', '42134', 11093, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42136', '42136', 11094, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42137', '42137', 11095, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42139', '42139', 11096, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42140', '42140', 11097, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42141', '42141', 11098, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42142', '42142', 11099, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42144', '42144', 11100, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42145', '42145', 11101, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42146', '42146', 11102, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42148', '42148', 11103, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42150', '42150', 11104, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42151', '42151', 11105, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42152', '42152', 11106, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42153', '42153', 11107, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42154', '42154', 11108, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42155', '42155', 11109, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42156', '42156', 11110, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42158', '42158', 11111, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42159', '42159', 11112, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42160', '42160', 11113, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42162', '42162', 11114, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42163', '42163', 11115, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42164', '42164', 11116, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42167', '42167', 11117, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42168', '42168', 11118, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42169', '42169', 11119, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42170', '42170', 11120, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42171', '42171', 11121, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42172', '42172', 11122, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42173', '42173', 11123, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42174', '42174', 11124, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 42175', '42175', 11125, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43742', '43742', 11126, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43743', '43743', 11127, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43805', '43805', 11128, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43806', '43806', 11129, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43807', '43807', 11130, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43809', '43809', 11131, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43810', '43810', 11132, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43812', '43812', 11133, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43813', '43813', 11134, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43814', '43814', 11135, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43816', '43816', 11136, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43818', '43818', 11137, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43821', '43821', 11138, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43823', '43823', 11139, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43824', '43824', 11140, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43825', '43825', 11141, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43826', '43826', 11142, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43828', '43828', 11143, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 43829', '43829', 11144, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 48655', '48655', 11145, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 48824', '48824', 11146, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 48827', '48827', 11147, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 48828', '48828', 11148, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 48829', '48829', 11149, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 48832', '48832', 11150, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 49251', '49251', 11151, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 49252', '49252', 11152, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 49253', '49253', 11153, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 49254', '49254', 11154, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 49286', '49286', 11155, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 51443', '51443', 11156, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60131', '60131', 11157, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60132', '60132', 11158, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60133', '60133', 11159, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60134', '60134', 11160, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60135', '60135', 11161, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60136', '60136', 11162, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60137', '60137', 11163, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60138', '60138', 11164, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60139', '60139', 11165, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60140', '60140', 11166, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60202', '60202', 11167, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60203', '60203', 11168, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60204', '60204', 11169, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60205', '60205', 11170, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60380', '60380', 11171, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60381', '60381', 11172, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60382', '60382', 11173, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60383', '60383', 11174, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60384', '60384', 11175, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60385', '60385', 11176, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60386', '60386', 11177, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60387', '60387', 11178, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60388', '60388', 11179, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60389', '60389', 11180, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60390', '60390', 11181, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60392', '60392', 11182, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60393', '60393', 11183, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60394', '60394', 11184, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60395', '60395', 11185, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60396', '60396', 11186, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60397', '60397', 11187, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60398', '60398', 11188, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60399', '60399', 11189, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60400', '60400', 11190, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60401', '60401', 11191, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 60403', '60403', 11192, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 71096', '71096', 11193, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 71513', '71513', 11194, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 71516', '71516', 11195, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 71517', '71517', 11196, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 71518', '71518', 11197, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 71519', '71519', 11198, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 71520', '71520', 11199, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 71536', '71536', 11200, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 72495', '72495', 11201, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 72497', '72497', 11202, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 72498', '72498', 11203, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75079', '75079', 11204, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75093', '75093', 11205, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75099', '75099', 11206, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75147', '75147', 11207, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75162', '75162', 11208, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75163', '75163', 11209, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75239', '75239', 11210, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75240', '75240', 11211, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75241', '75241', 11212, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75242', '75242', 11213, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75243', '75243', 11214, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75245', '75245', 11215, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75246', '75246', 11216, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75249', '75249', 11217, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75250', '75250', 11218, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75251', '75251', 11219, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75254', '75254', 11220, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75255', '75255', 11221, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75259', '75259', 11222, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75260', '75260', 11223, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75261', '75261', 11224, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75262', '75262', 11225, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75265', '75265', 11226, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75266', '75266', 11227, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75267', '75267', 11228, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75268', '75268', 11229, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75269', '75269', 11230, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75271', '75271', 11231, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75277', '75277', 11232, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75278', '75278', 11233, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75280', '75280', 11234, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75281', '75281', 11235, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75282', '75282', 11236, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75283', '75283', 11237, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75284', '75284', 11238, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75285', '75285', 11239, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75286', '75286', 11240, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75287', '75287', 11241, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75288', '75288', 11242, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75289', '75289', 11243, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75293', '75293', 11244, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75296', '75296', 11245, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75297', '75297', 11246, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75298', '75298', 11247, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75299', '75299', 11248, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75300', '75300', 11249, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75301', '75301', 11250, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75302', '75302', 11251, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75303', '75303', 11252, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75304', '75304', 11253, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75305', '75305', 11254, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75307', '75307', 11255, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75308', '75308', 11256, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75310', '75310', 11257, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75311', '75311', 11258, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75312', '75312', 11259, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75317', '75317', 11260, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75318', '75318', 11261, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75319', '75319', 11262, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75320', '75320', 11263, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75323', '75323', 11264, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75324', '75324', 11265, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75325', '75325', 11266, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75326', '75326', 11267, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75327', '75327', 11268, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75328', '75328', 11269, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75329', '75329', 11270, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75330', '75330', 11271, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75332', '75332', 11272, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75334', '75334', 11273, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75335', '75335', 11274, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75336', '75336', 11275, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75339', '75339', 11276, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75340', '75340', 11277, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75850', '75850', 11278, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75851', '75851', 11279, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75853', '75853', 11280, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75855', '75855', 11281, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 75856', '75856', 11282, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 76531', '76531', 11283, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 76939', '76939', 11284, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 76940', '76940', 11285, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 77134', '77134', 11286, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 77135', '77135', 11287, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 77137', '77137', 11288, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 77138', '77138', 11289, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 77139', '77139', 11290, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 77140', '77140', 11291, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 77371', '77371', 11292, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 77372', '77372', 11293, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 92727', '92727', 11294, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 92728', '92728', 11295, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Team 96563', '96563', 11296, d.id, undefined
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Unknown'
  AND s.name = '2022/2023'
  AND s.league_id = 4
ON CONFLICT (division_id, name) DO NOTHING;
