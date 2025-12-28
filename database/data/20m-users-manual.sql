-- James Breslin - System Administrator
-- Email: soccer@lighthouse1893.org
-- Password: same as before (bcrypt hash)
-- Role: super admin

INSERT INTO users (id, email, password_hash, first_name, last_name, phone, is_active)
VALUES (
    1,
    'soccer@lighthouse1893.org',
    crypt('1893Soccer!', gen_salt('bf')),  -- Password: 1893Soccer!
    'James',
    'Breslin',
    '+12158284924',
    true
)
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    password_hash = EXCLUDED.password_hash,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    phone = EXCLUDED.phone,
    is_active = EXCLUDED.is_active;
