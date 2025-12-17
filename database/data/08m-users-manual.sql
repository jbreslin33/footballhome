-- Manual User Additions
-- Add users not in scraped rosters (admins, coaches, parents, etc.)

-- James Breslin - Lighthouse 1893 SC Club Administrator
INSERT INTO users (id, email, password_hash, first_name, last_name, preferred_name, is_active)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'soccer@lighthouse1893.org',
    crypt('password123', gen_salt('bf')),
    'James',
    'Breslin',
    'James',
    true
)
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    password_hash = EXCLUDED.password_hash,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    preferred_name = EXCLUDED.preferred_name,
    is_active = EXCLUDED.is_active;
