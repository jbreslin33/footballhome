-- ========================================
-- ALL USERS
-- ========================================
-- All users in the system (admin, coaches, players)
-- This file is idempotent - can be run multiple times safely

-- System Admin (jbreslin@footballhome.org)
INSERT INTO users (id, email, password_hash, first_name, last_name, is_active)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'jbreslin@footballhome.org',
    '$2a$12$kDODGedFzf1BpWdjdCjHo.X3t5VwU4K9/KhlSDlymmHadhGuJslHS',
    'James',
    'Breslin',
    true
)
ON CONFLICT (email) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

-- Assign system admin role
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

