-- ========================================
-- POST-DATA SETUP
-- ========================================
-- This file runs AFTER data files (02-*.sql) are loaded
-- Used to establish relationships that depend on loaded data

-- Link James Breslin as head coach to Lighthouse 1893 SC
-- This requires the team to exist first (loaded via 02-*.sql)
INSERT INTO team_coaches (team_id, coach_id, coach_role, is_primary, is_active)
VALUES (
    (SELECT id FROM teams WHERE name = 'Lighthouse 1893 SC'),
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'head_coach',
    true,
    true
)
ON CONFLICT DO NOTHING;
