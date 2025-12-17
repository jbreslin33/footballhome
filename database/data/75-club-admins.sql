-- ========================================
-- CLUB ADMINS
-- ========================================
-- Associates users with clubs as administrators
-- This file is maintained manually and version controlled
-- Data persists across rebuilds

-- soccer@lighthouse1893.org (James Breslin) as admin for Lighthouse 1893 SC
-- Note: Using the APSL Lighthouse 1893 SC club (235a623c-7368-4c4e-8984-d42da5a47abf)
-- which is the main adult competitive team
INSERT INTO club_admins (id, club_id, admin_id, admin_role, is_primary, is_active)
VALUES (
    'db836e6f-1250-47e0-81ab-d4626595d63c',
    '235a623c-7368-4c4e-8984-d42da5a47abf',
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

