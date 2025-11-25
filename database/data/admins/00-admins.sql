-- ========================================
-- MANUAL ADMINS
-- ========================================
-- Manually managed system administrators

-- Assign jbreslin system admin role
INSERT INTO admins (id, admin_level, notes)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'system',
    'System administrator with full access'
)
ON CONFLICT (id) DO UPDATE SET
    admin_level = EXCLUDED.admin_level,
    notes = EXCLUDED.notes,
    updated_at = CURRENT_TIMESTAMP;
