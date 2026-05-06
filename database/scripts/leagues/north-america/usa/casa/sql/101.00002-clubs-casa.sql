-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Clubs - CASA
-- Total Records: 12
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO clubs (id, name, organization_id) SELECT 20000, 'Persepolis FC', (SELECT id FROM organizations WHERE name = 'Persepolis FC') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Persepolis FC') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20001, 'Sewell''s', (SELECT id FROM organizations WHERE name = 'Sewell''s') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Sewell''s') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20002, 'Philadelphia SC Select', (SELECT id FROM organizations WHERE name = 'Philadelphia SC Select') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Philadelphia SC Select') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20003, 'Phoenix SCR', (SELECT id FROM organizations WHERE name = 'Phoenix SCR') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Phoenix SCR') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20004, 'Lighthouse Boys Club U23', (SELECT id FROM organizations WHERE name = 'Lighthouse Boys Club U23') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Lighthouse Boys Club U23') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20005, 'Club de Futbol Armada', (SELECT id FROM organizations WHERE name = 'Club de Futbol Armada') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Club de Futbol Armada') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20006, 'Lighthouse', (SELECT id FROM organizations WHERE name = 'Lighthouse') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Lighthouse') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20007, 'Ade United FC', (SELECT id FROM organizations WHERE name = 'Ade United FC') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Ade United FC') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20008, 'Philly Black Stars', (SELECT id FROM organizations WHERE name = 'Philly Black Stars') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Philly Black Stars') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20009, 'Oaklyn United Nor''Easters', (SELECT id FROM organizations WHERE name = 'Oaklyn United Nor''Easters') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Oaklyn United Nor''Easters') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20010, 'Philadelphia Sierra Stars', (SELECT id FROM organizations WHERE name = 'Philadelphia Sierra Stars') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Philadelphia Sierra Stars') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20011, 'Illyrians', (SELECT id FROM organizations WHERE name = 'Illyrians') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Illyrians') ON CONFLICT DO NOTHING;
