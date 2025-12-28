-- ========================================
-- CLUB ADMINS
-- ========================================
-- Associates users with clubs as administrators
-- This file is maintained manually and version controlled
-- Data persists across rebuilds

-- James Breslin as admin for Lighthouse 1893 SC
-- James ID from CASA scraped roster (Old Timers team): 311ee799-a6a1-450f-8bad-5140a021c92b
-- Club ID from APSL: 235a623c-7368-4c4e-8984-d42da5a47abf (main adult competitive team)
INSERT INTO club_admins (id, club_id, user_id, admin_role, is_primary, is_active)
VALUES (
    'db836e6f-1250-47e0-81ab-d4626595d63c',
    '235a623c-7368-4c4e-8984-d42da5a47abf',
    '311ee799-a6a1-450f-8bad-5140a021c92b',
    'club_manager',
    true,
    true
)
ON CONFLICT (id) DO UPDATE SET
    club_id = EXCLUDED.club_id,
    user_id = EXCLUDED.user_id,
    admin_role = EXCLUDED.admin_role,
    is_primary = EXCLUDED.is_primary,
    is_active = EXCLUDED.is_active;

