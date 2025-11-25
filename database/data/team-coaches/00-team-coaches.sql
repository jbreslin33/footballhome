-- ========================================
-- MANUAL TEAM COACHES
-- ========================================
-- Manually managed coach assignments (not from scraper)

-- Assign jbreslin as coach to Lighthouse 1893 SC
INSERT INTO team_coaches (id, team_id, coach_id, coach_role, is_primary, is_active)
VALUES (
    '00000001-0000-0000-0000-000000000001',
    'b89d4e7f-6c5a-4b3d-9e2f-1a8c7d6e5f4a',  -- Lighthouse team
    '77d77471-1250-47e0-81ab-d4626595d63c',  -- jbreslin
    'Head Coach',
    true,
    true
)
ON CONFLICT (team_id, coach_id) DO UPDATE SET
    coach_role = EXCLUDED.coach_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active;
