-- ========================================
-- MANUAL ADMINS
-- ========================================
-- Manually managed admins with role assignments using normalized admin_levels lookup table

-- Assign soccer@lighthouse1893.org as club admin (club level administrator)
INSERT INTO admins (id, admin_level_id, notes)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    '550e8400-e29b-41d4-a716-446655440812',
    'Club administrator for Lighthouse 1893 SC with full club management access'
)
ON CONFLICT (id) DO UPDATE SET
    admin_level_id = EXCLUDED.admin_level_id,
    notes = EXCLUDED.notes,
    updated_at = CURRENT_TIMESTAMP;
