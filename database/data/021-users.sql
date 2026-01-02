-- Users - Foundation Data
-- Authentication capability (links to persons)

-- James Breslin - User account (can log in)
INSERT INTO users (id, person_id, password_hash, is_active)
VALUES (
    1,
    1,  -- Links to person_id=1 (James Breslin)
    crypt('1893Soccer!', gen_salt('bf')),
    true
) ON CONFLICT (id) DO UPDATE SET
    person_id = EXCLUDED.person_id,
    password_hash = EXCLUDED.password_hash,
    is_active = EXCLUDED.is_active;
