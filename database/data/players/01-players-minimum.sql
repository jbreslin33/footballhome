-- ========================================
-- MINIMUM PLAYERS (Development)
-- ========================================
-- Just jbreslin as a player on Lighthouse 1893 SC

-- jbreslin as player
INSERT INTO players (id, jersey_number, position, notes)
VALUES (
    '77d77471-1250-47e0-81ab-d4626595d63c',
    10,
    'midfielder',
    'System admin - also a player'
)
ON CONFLICT (id) DO UPDATE SET
    jersey_number = EXCLUDED.jersey_number,
    position = EXCLUDED.position,
    notes = EXCLUDED.notes,
    updated_at = CURRENT_TIMESTAMP;
