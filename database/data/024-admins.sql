-- Admins - Foundation Data
-- This file contains core/foundational data for admins that always loads.
-- Tables 001-012 (lookup tables) have data inline in schema, this file is optional.

-- James Breslin as Super Admin
INSERT INTO admins (id, user_id, admin_level_id, notes)
VALUES (
    1,
    1,  -- user_id=1 (James Breslin from users table)
    1,  -- 1 = super_admin (from admin_levels lookup)
    'System administrator with full access to all entities and management capabilities'
) ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    admin_level_id = EXCLUDED.admin_level_id,
    notes = EXCLUDED.notes;

