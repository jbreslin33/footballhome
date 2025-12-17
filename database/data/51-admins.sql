-- ========================================
-- MANUAL ADMINS
-- ========================================
-- Manually managed admins with role assignments using normalized admin_levels lookup table
-- NOTE: Authentication credentials (email/password) are set in 50m-auth-credentials.sql

-- James Breslin - Club Administrator
INSERT INTO admins (id, admin_level_id, notes)
VALUES (
    '311ee799-a6a1-450f-8bad-5140a021c92b',
    '550e8400-e29b-41d4-a716-446655440812',
    'Club administrator for Lighthouse 1893 SC with full club management access'
)
ON CONFLICT (id) DO UPDATE SET
    admin_level_id = EXCLUDED.admin_level_id,
    notes = EXCLUDED.notes,
    updated_at = CURRENT_TIMESTAMP;
