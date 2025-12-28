-- James Breslin - Super Admin
-- Links user_id=1 to super admin privileges

INSERT INTO admins (id, user_id, admin_level, notes)
VALUES (
    1,
    1,  -- James Breslin from users table
    'super',
    'System administrator with full access to all entities and management capabilities'
)
ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    admin_level = EXCLUDED.admin_level,
    notes = EXCLUDED.notes;
