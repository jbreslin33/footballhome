-- ========================================
-- MANUAL TEAM COACHES
-- ========================================
-- Manually managed coach assignments (not from scraper)

-- Assign jbreslin as coach to Lighthouse 1893 SC
INSERT INTO team_coaches (id, team_id, coach_id, coach_role, is_primary, is_active)
VALUES (
    '00000001-0000-0000-0000-000000000001',
    'd37eb44b-8e47-0005-9060-f0cbe96fe089',  -- Lighthouse team (scraped UUID)
    '77d77471-1250-47e0-81ab-d4626595d63c',  -- jbreslin
    'Head Coach',
    true,
    true
)
ON CONFLICT (team_id, coach_id) DO UPDATE SET
    coach_role = EXCLUDED.coach_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active;
