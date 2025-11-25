-- ========================================
-- MANUAL PLAYERS
-- ========================================
-- Manually managed player profiles
-- This file is idempotent - can be run multiple times safely

-- jbreslin@footballhome.org player entity
INSERT INTO players (id, position, jersey_number, height_cm, weight_kg, date_of_birth, bio)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    'Midfielder',
    18,
    178,
    75,
    '1980-01-15',
    'Experienced midfielder who also coaches. Focuses on ball control and tactical awareness.'
)
ON CONFLICT (id) DO UPDATE SET
    position = EXCLUDED.position,
    jersey_number = EXCLUDED.jersey_number,
    height_cm = EXCLUDED.height_cm,
    weight_kg = EXCLUDED.weight_kg,
    date_of_birth = EXCLUDED.date_of_birth,
    bio = EXCLUDED.bio,
    updated_at = CURRENT_TIMESTAMP;
