-- ========================================
-- MANUAL PLAYERS
-- ========================================
-- Manually managed player profiles
-- This file is idempotent - can be run multiple times safely

-- soccer@lighthouse1893.org player entity
INSERT INTO players (id, height_cm, weight_kg, notes)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    178,
    75,
    'Experienced midfielder who also coaches. Focuses on ball control and tactical awareness.'
)
ON CONFLICT (id) DO UPDATE SET
    height_cm = EXCLUDED.height_cm,
    weight_kg = EXCLUDED.weight_kg,
    notes = EXCLUDED.notes,
    updated_at = CURRENT_TIMESTAMP;
