-- ========================================
-- LIGHTHOUSE - ADDITIONAL TEAMS
-- ========================================
-- Creates additional recreational teams under Lighthouse club:
-- - Lighthouse Boys Club (youth)
-- - Lighthouse Old Timers Club (adult)

-- Create Lighthouse Boys Club team
INSERT INTO teams (id, division_id, name, age_group, skill_level, is_active)
VALUES (
    'bbb00000-0000-0000-0000-000000000001',
    'd37eb44b-8e47-0004-9060-f0cbe96fe089',
    'Lighthouse Boys Club',
    'youth',
    'recreational',
    true
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    age_group = EXCLUDED.age_group,
    skill_level = EXCLUDED.skill_level,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

-- Create Lighthouse Old Timers Club team
INSERT INTO teams (id, division_id, name, age_group, skill_level, is_active)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'd37eb44b-8e47-0004-9060-f0cbe96fe089',
    'Lighthouse Old Timers Club',
    'adult',
    'recreational',
    true
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    age_group = EXCLUDED.age_group,
    skill_level = EXCLUDED.skill_level,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;
