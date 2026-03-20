-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Organizations - CASA
-- Total Records: 28
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO organizations (id, name) SELECT 20000, 'Adé United FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Adé United FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20001, 'Oaklyn United FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Oaklyn United FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20002, 'Philadelphia Sierra Stars' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Philadelphia Sierra Stars') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20003, 'Persepolis FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Persepolis FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20004, 'Philly BlackStars' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Philly BlackStars') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20005, 'Phoenix SCM' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Phoenix SCM') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20006, 'Illyrians FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Illyrians FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20007, 'Lighthouse' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Lighthouse') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20008, 'Philadelphia SC Select' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Philadelphia SC Select') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20009, 'Sewell''s' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Sewell''s') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20010, 'Lighthouse Boys Club U23' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Lighthouse Boys Club U23') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20011, 'Club de Futbol Armada' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Club de Futbol Armada') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20012, 'South Shore FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'South Shore FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20013, 'Jaguars United FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Jaguars United FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20014, 'Strictly Nos Fc' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Strictly Nos Fc') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20015, 'BCFC All Stars' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'BCFC All Stars') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20016, 'Flatley FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Flatley FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20017, 'Gambeta FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Gambeta FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20018, 'Somerville United FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Somerville United FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20019, 'Alloy Soccer Club' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Alloy Soccer Club') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20020, 'Kutztown Men''s Soccer' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Kutztown Men''s Soccer') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20021, 'Lancaster City FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Lancaster City FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20022, 'F&M FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'F&M FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20023, 'Keystone Elite' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Keystone Elite') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20024, 'Millersville Men''s Club Soccer' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Millersville Men''s Club Soccer') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20025, 'Lancaster Bible College' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Lancaster Bible College') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20026, 'West Chester University Club' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'West Chester University Club') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20027, 'YorkPA FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'YorkPA FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
