-- ========================================
-- SYSTEM ADMINS
-- ========================================
-- System-level administrators with full access to all entities
-- NOTE: Authentication credentials (email/password) are set in 50m-auth-credentials.sql
-- NOTE: Admin assignments are in junction tables: system_admins, league_admins, club_admins, etc.
-- NOTE: Users can have multiple admin roles (e.g., system admin + club admin for specific club)

-- James Breslin - System Administrator
INSERT INTO system_admins (user_id, notes, is_active)
VALUES (
    '311ee799-a6a1-450f-8bad-5140a021c92b',
    'System administrator with full access to all entities and management capabilities',
    true
)
ON CONFLICT (user_id) DO UPDATE SET
    notes = EXCLUDED.notes,
    is_active = EXCLUDED.is_active;
