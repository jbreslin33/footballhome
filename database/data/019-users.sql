-- Users - Foundation Data
-- This file contains core/foundational data for users that always loads.
-- Tables 001-012 (lookup tables) have data inline in schema, this file is optional.

-- Admin User: James Breslin
INSERT INTO users (id, first_name, last_name, password_hash, is_active)
VALUES (
    1,
    'James',
    'Breslin',
    crypt('1893Soccer!', gen_salt('bf')),
    true
) ON CONFLICT (id) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    is_active = EXCLUDED.is_active;

