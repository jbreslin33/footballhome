-- ========================================
-- TEAM ADMINS
-- ========================================
-- Associates users with teams as administrators
-- This file is maintained manually and version controlled
-- Data persists across rebuilds

-- James Breslin as admin for all 3 Lighthouse teams
-- James ID: 311ee799-a6a1-450f-8bad-5140a021c92b

-- Lighthouse 1893 SC team
INSERT INTO team_admins (id, team_id, user_id, admin_role, is_primary, is_active)
VALUES (
    'd1a85f3c-1250-47e0-81ab-d4626595d63c',
    'a16e9445-9bed-4fe6-804d-e77c56258610',
    '311ee799-a6a1-450f-8bad-5140a021c92b',
    'team_manager',
    true,
    true
)
ON CONFLICT (id) DO UPDATE SET
    team_id = EXCLUDED.team_id,
    user_id = EXCLUDED.user_id,
    admin_role = EXCLUDED.admin_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active;

-- Lighthouse Boys Club team
INSERT INTO team_admins (id, team_id, user_id, admin_role, is_primary, is_active)
VALUES (
    'd2b96f4d-2361-58f1-92bc-e5737606e74d',
    '57d88568-993d-4411-8aa3-6244ca7ff704',
    '311ee799-a6a1-450f-8bad-5140a021c92b',
    'team_manager',
    true,
    true
)
ON CONFLICT (id) DO UPDATE SET
    team_id = EXCLUDED.team_id,
    user_id = EXCLUDED.user_id,
    admin_role = EXCLUDED.admin_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active;

-- Lighthouse Old Timers Club team
INSERT INTO team_admins (id, team_id, user_id, admin_role, is_primary, is_active)
VALUES (
    'd3c07f5e-3472-6902-a3cd-f6848717f85e',
    'da5e129e-1d82-4c59-85f9-1f5efd3d6c11',
    '311ee799-a6a1-450f-8bad-5140a021c92b',
    'team_manager',
    true,
    true
)
ON CONFLICT (id) DO UPDATE SET
    team_id = EXCLUDED.team_id,
    user_id = EXCLUDED.user_id,
    admin_role = EXCLUDED.admin_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active;
