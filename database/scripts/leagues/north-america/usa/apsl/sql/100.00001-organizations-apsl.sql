-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Organizations - APSL
-- Total Records: 1
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO organizations (id, name) SELECT 100, 'Lighthouse 1893 SC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Lighthouse 1893 SC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
