-- ========================================
-- MANUAL ROSTERS (Development)
-- ========================================
-- Manually managed roster assignments (jbreslin on Lighthouse)

-- Add jbreslin to Lighthouse 1893 SC roster
INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'b89d4e7f-6c5a-4b3d-9e2f-1a8c7d6e5f4a',  -- Lighthouse 1893 SC team_id
    '77d77471-1250-47e0-81ab-d4626595d63c',  -- jbreslin player_id
    10,
    true
)
ON CONFLICT (team_id, player_id) DO UPDATE SET
    jersey_number = EXCLUDED.jersey_number,
    is_active = EXCLUDED.is_active;

