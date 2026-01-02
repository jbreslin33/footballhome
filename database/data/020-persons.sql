-- Persons - Foundation Data
-- Core identity for all people in the system

-- James Breslin - System Administrator
INSERT INTO persons (id, first_name, last_name, birth_date)
VALUES (
    1,
    'James',
    'Breslin',
    '1985-06-15'  -- Birth date for age verification
) ON CONFLICT (id) DO UPDATE SET
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    birth_date = EXCLUDED.birth_date;

