-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Clubs - CSL (Curated)
-- Only new clubs not in APSL. Matched clubs use APSL IDs. Total new: 48
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO clubs (id, name, organization_id) VALUES (10000, 'FC Sandzak', 10000) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10001, 'Block FC', 10001) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10002, 'Manhattan Kickers', 10002) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10003, 'Polonia SC', 10003) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10004, 'NY Ukrainians', 10004) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10006, 'Laberia FC', 10006) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10008, 'Manhattan Celtic', 10008) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10010, 'FC Ulqini', 10010) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10012, 'Brooklyn City FC', 10012) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10013, 'Stal Mielec NY', 10013) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10014, 'Vibes FC', 10014) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10015, 'NY Galicia', 10015) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10016, 'NY Shamrocks', 10016) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10017, 'NY Finest FC', 10017) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10018, 'Sporting Astoria South Bronx', 10018) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10019, 'ERFC', 10019) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10020, 'Williamsburg International FC', 10020) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10021, 'FC Japan', 10021) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10023, 'Kickoff FC', 10023) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10024, 'Yemen United SC', 10024) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10025, 'Vllaznia NYC', 10025) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10026, 'Desportiva Sociedad NY', 10026) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10027, 'Braza Futbol', 10027) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10028, 'SC Football Crew', 10028) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10030, 'Sporting Astoria SBU', 10030) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10031, 'FanDuel FC', 10031) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10032, 'Aurora FC', 10032) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10033, 'Riverside Squires', 10033) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10034, 'Panatha USA', 10034) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10035, 'Junior Mafia FC', 10035) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10036, 'NY Legacy FC', 10036) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10037, 'C.A. Islas Malvinas', 10037) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10038, 'Ollama FC', 10038) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10039, 'Barnstonworth Rovers FC', 10039) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10040, 'Warriors NYC', 10040) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10041, 'NY Titans FC', 10041) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10042, 'NYC AlphaStars Club', 10042) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10043, 'Al-Asad', 10043) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10044, 'SC Gjoa', 10044) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10045, 'Brooklyn New York SC', 10045) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10046, 'Pelham Parkway FC', 10046) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10047, 'Bolivia Si Existe FC', 10047) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10048, 'Desportiva Sociedad NY Samba', 10048) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10050, 'FC Kraja', 10050) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10051, 'FC Rush', 10051) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10052, 'Tiercel City FC', 10052) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10053, 'Cozmoz FC', 10053) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (10054, 'Polonez SC', 10054) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
