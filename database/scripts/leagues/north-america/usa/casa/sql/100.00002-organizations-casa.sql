-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Organizations - CASA
-- Total Records: 12
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO organizations (id, name) SELECT 20000, 'Persepolis FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Persepolis FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20001, 'Sewell''s' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Sewell''s') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20002, 'Philadelphia SC Select' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Philadelphia SC Select') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20003, 'Phoenix SCR' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Phoenix SCR') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20004, 'Lighthouse Boys Club U23' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Lighthouse Boys Club U23') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20005, 'Club de Futbol Armada' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Club de Futbol Armada') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20006, 'Lighthouse' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Lighthouse') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20007, 'Ade United FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Ade United FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20008, 'Philly Black Stars' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Philly Black Stars') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20009, 'Oaklyn United Nor''Easters' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Oaklyn United Nor''Easters') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20010, 'Philadelphia Sierra Stars' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Philadelphia Sierra Stars') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 20011, 'Illyrians' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Illyrians') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
