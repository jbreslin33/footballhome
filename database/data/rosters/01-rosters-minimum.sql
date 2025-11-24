-- ========================================
-- MINIMUM ROSTERS (Development)
-- ========================================
-- Just jbreslin on Lighthouse 1893 SC roster

-- Add jbreslin to Lighthouse 1893 SC roster
INSERT INTO rosters (id, team_id, player_id, jersey_number, position, status, is_active)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'b89d4e7f-6c5a-4b3d-9e2f-1a8c7d6e5f4a',  -- Lighthouse 1893 SC team_id
    '77d77471-1250-47e0-81ab-d4626595d63c',  -- jbreslin player_id
    10,
    'midfielder',
    'active',
    true
)
ON CONFLICT (id) DO UPDATE SET
    jersey_number = EXCLUDED.jersey_number,
    position = EXCLUDED.position,
    status = EXCLUDED.status,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;
