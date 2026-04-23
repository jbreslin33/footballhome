-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Organizations - CASA
-- Total Records: 12
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO organizations (id, name) SELECT 20000, 'Adé United FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Adé United FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20001, 'Persepolis FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Persepolis FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20002, 'Oaklyn United FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Oaklyn United FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20003, 'Philadelphia Sierra Stars' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Philadelphia Sierra Stars') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20004, 'Illyrians FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Illyrians FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20005, 'Lighthouse' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Lighthouse') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20006, 'Phoenix SCM' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Phoenix SCM') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20007, 'Philly BlackStars' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Philly BlackStars') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20008, 'Sewell''s' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Sewell''s') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20009, 'Philadelphia SC Select' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Philadelphia SC Select') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20010, 'Lighthouse Boys Club U23' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Lighthouse Boys Club U23') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20011, 'Club de Futbol Armada' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Club de Futbol Armada') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
