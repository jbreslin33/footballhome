-- ========================================
-- MANUAL USERS
-- ========================================
-- Manually managed users (admins, coaches, non-APSL players)
-- Note: Admin role assignment is in admins/ folder

-- System Admin (soccer@lighthouse1893.org)
-- Password: 1893Soccer!
INSERT INTO users (id, email, password_hash, first_name, last_name, is_active)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'soccer@lighthouse1893.org',
    crypt('1893Soccer!', gen_salt('bf')),
    'James',
    'Breslin',
    true
)
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    password_hash = crypt('1893Soccer!', gen_salt('bf')),
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;
