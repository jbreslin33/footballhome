-- ========================================
-- USER EMAILS
-- ========================================
-- Populate user_emails table with emails from users table
-- This file runs after auth credentials are set (50m-auth-credentials.sql)

-- Insert all existing user emails into user_emails table
INSERT INTO user_emails (user_id, email, is_primary, is_verified, auth_provider)
SELECT 
    id as user_id,
    email,
    true as is_primary,
    true as is_verified,
    'password' as auth_provider
FROM users
WHERE email IS NOT NULL
ON CONFLICT (email) DO NOTHING;
