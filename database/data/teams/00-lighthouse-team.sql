-- ========================================
-- LIGHTHOUSE 1893 SC TEAM (MANUAL)
-- ========================================
-- Manually maintained Lighthouse team entry

-- Insert Lighthouse 1893 SC team
-- Note: Requires sport-divisions and clubs to be loaded first
INSERT INTO teams (id, name, division_id, season, is_active)
VALUES (
    'b89d4e7f-6c5a-4b3d-9e2f-1a8c7d6e5f4a',
    'Lighthouse 1893 SC',
    (SELECT id FROM sport_divisions WHERE club_id = (SELECT id FROM clubs WHERE name = 'Lighthouse 1893 SC') LIMIT 1),
    '2024-2025',
    true
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    division_id = EXCLUDED.division_id,
    updated_at = CURRENT_TIMESTAMP;
