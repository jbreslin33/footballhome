-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Organizations - CASA (Curated)
-- Only new organizations not in APSL or CSL. Total: 19
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO organizations (id, name) VALUES (20000, 'Adé United FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20001, 'Persepolis FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20002, 'Philly BlackStars') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20003, 'Phoenix SCM') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20004, 'Illyrians FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20005, 'South Shore FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20006, 'Jaguars United FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20007, 'Strictly Nos Fc') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20008, 'BCFC All Stars') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20009, 'Flatley FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20010, 'Gambeta FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20011, 'Kutztown Men''s Soccer') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20012, 'Lancaster City FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20013, 'F&M FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20014, 'Keystone Elite') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20015, 'Millersville Men''s Club Soccer') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20016, 'Lancaster Bible College') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20017, 'West Chester University Club') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) VALUES (20018, 'YorkPA FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
