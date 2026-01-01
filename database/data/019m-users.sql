-- James Breslin - System Administrator
-- Email: soccer@lighthouse1893.org
-- Password: same as before (bcrypt hash)
-- Role: super admin

-- Insert user (no email/phone on users table anymore - they're in junction tables)
INSERT INTO users (id, password_hash, first_name, last_name, is_active)
VALUES (
    1,
    crypt('1893Soccer!', gen_salt('bf')),  -- Password: 1893Soccer!
    'James',
    'Breslin',
    true
)
ON CONFLICT (id) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    is_active = EXCLUDED.is_active;

-- Insert email into user_emails junction table
INSERT INTO user_emails (user_id, email, email_type, is_primary, is_verified)
VALUES (
    1,
    'soccer@lighthouse1893.org',
    'personal',
    true,
    true
)
ON CONFLICT (email) DO UPDATE SET
    is_primary = EXCLUDED.is_primary,
    is_verified = EXCLUDED.is_verified;

-- Insert phone into user_phones junction table
INSERT INTO user_phones (user_id, phone_number, phone_type, is_primary, is_verified, can_receive_sms, can_receive_calls)
VALUES (
    1,
    '+12158284924',
    'mobile',
    true,
    true,
    true,
    true
)
ON CONFLICT (phone_number) DO UPDATE SET
    is_primary = EXCLUDED.is_primary,
    is_verified = EXCLUDED.is_verified;
