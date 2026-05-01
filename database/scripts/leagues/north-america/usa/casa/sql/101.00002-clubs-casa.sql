-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Clubs - CASA
-- Total Records: 12
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO clubs (id, name, organization_id) SELECT 20000, 'Oaklyn United FC', (SELECT id FROM organizations WHERE name = 'Oaklyn United FC') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Oaklyn United FC') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20001, 'Adé United FC', (SELECT id FROM organizations WHERE name = 'Adé United FC') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Adé United FC') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20002, 'Persepolis FC', (SELECT id FROM organizations WHERE name = 'Persepolis FC') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Persepolis FC') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20003, 'Philadelphia Sierra Stars', (SELECT id FROM organizations WHERE name = 'Philadelphia Sierra Stars') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Philadelphia Sierra Stars') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20004, 'Lighthouse', (SELECT id FROM organizations WHERE name = 'Lighthouse') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Lighthouse') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20005, 'Illyrians FC', (SELECT id FROM organizations WHERE name = 'Illyrians FC') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Illyrians FC') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20006, 'Phoenix SCM', (SELECT id FROM organizations WHERE name = 'Phoenix SCM') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Phoenix SCM') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20007, 'Philly BlackStars', (SELECT id FROM organizations WHERE name = 'Philly BlackStars') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Philly BlackStars') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20008, 'Sewell''s', (SELECT id FROM organizations WHERE name = 'Sewell''s') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Sewell''s') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20009, 'Philadelphia SC Select', (SELECT id FROM organizations WHERE name = 'Philadelphia SC Select') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Philadelphia SC Select') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20010, 'Lighthouse Boys Club U23', (SELECT id FROM organizations WHERE name = 'Lighthouse Boys Club U23') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Lighthouse Boys Club U23') ON CONFLICT DO NOTHING;
INSERT INTO clubs (id, name, organization_id) SELECT 20011, 'Club de Futbol Armada', (SELECT id FROM organizations WHERE name = 'Club de Futbol Armada') WHERE NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Club de Futbol Armada') ON CONFLICT DO NOTHING;
