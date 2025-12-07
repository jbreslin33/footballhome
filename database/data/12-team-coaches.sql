-- ========================================
-- MANUAL TEAM COACHES
-- ========================================
-- Manually managed coach assignments (not from scraper)

-- Assign James Breslin as coach to Lighthouse 1893 SC (APSL team)
INSERT INTO team_coaches (id, team_id, coach_id, coach_role, is_primary, is_active)
VALUES (
    '00000001-0000-0000-0000-000000000001',
    'd37eb44b-8e47-0005-9060-f0cbe96fe089',  -- Lighthouse 1893 SC (APSL scraped UUID)
    '77d77471-1250-47e0-81ab-d4626595d63c',  -- James Breslin (soccer@lighthouse1893.org)
    'Head Coach',
    true,
    true
)
ON CONFLICT (team_id, coach_id) DO UPDATE SET
    coach_role = EXCLUDED.coach_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active;

-- Assign James Breslin as coach to Lighthouse Boys Club (CASA Liga 1)
INSERT INTO team_coaches (id, team_id, coach_id, coach_role, is_primary, is_active)
VALUES (
    '00000002-0000-0000-0000-000000000002',
    'b0c1abb0-c1ab-0001-b0c1-ab0c1abb0c1a',  -- Lighthouse Boys Club
    '77d77471-1250-47e0-81ab-d4626595d63c',  -- James Breslin (soccer@lighthouse1893.org)
    'Head Coach',
    true,
    true
)
ON CONFLICT (team_id, coach_id) DO UPDATE SET
    coach_role = EXCLUDED.coach_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active;

-- Assign James Breslin as coach to Lighthouse Old Timers Club (CASA Liga 2)
INSERT INTO team_coaches (id, team_id, coach_id, coach_role, is_primary, is_active)
VALUES (
    '00000003-0000-0000-0000-000000000003',
    '01d71me5-01d7-0002-1me5-01d71me501d7',  -- Lighthouse Old Timers Club
    '77d77471-1250-47e0-81ab-d4626595d63c',  -- James Breslin (soccer@lighthouse1893.org)
    'Head Coach',
    true,
    true
)
ON CONFLICT (team_id, coach_id) DO UPDATE SET
    coach_role = EXCLUDED.coach_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active;
