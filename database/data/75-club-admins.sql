-- ========================================
-- CLUB ADMINS
-- ========================================
-- Associates users with clubs as administrators
-- This file is maintained manually and version controlled
-- Data persists across rebuilds

-- soccer@lighthouse1893.org (James Breslin) as admin for Lighthouse 1893 SC
INSERT INTO club_admins (id, club_id, admin_id, admin_role, is_primary, is_active)
VALUES (
    'db836e6f-1250-47e0-81ab-d4626595d63c',
    'd37eb44b-8e47-0003-9060-f0cbe96fe089',
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'club_manager',
    true,
    true
)
ON CONFLICT (id) DO UPDATE SET
    club_id = EXCLUDED.club_id,
    admin_id = EXCLUDED.admin_id,
    admin_role = EXCLUDED.admin_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active;

