-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Clubs - APSL
-- Total Records: 1
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO clubs (id, name, organization_id) VALUES (100, 'Lighthouse 1893 SC', (SELECT id FROM organizations WHERE name = 'Lighthouse 1893 SC')) ON CONFLICT DO NOTHING;
