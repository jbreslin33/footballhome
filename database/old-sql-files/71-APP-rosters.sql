-- ========================================
-- APP-MANAGED ROSTERS
-- ========================================
-- Roster changes made via the web application
-- This file is manually maintained and version controlled
--
-- Add roster modifications here to persist across rebuilds
-- ========================================

-- Example (commented out):
-- -- Add player to team
-- INSERT INTO team_players (team_id, player_id, is_active, jersey_number)
-- VALUES (
--   'team-uuid',
--   'player-uuid',
--   true,
--   10
-- ) ON CONFLICT (team_id, player_id) DO UPDATE SET
--   is_active = EXCLUDED.is_active,
--   jersey_number = EXCLUDED.jersey_number;
--
-- -- Remove player from team
-- UPDATE team_players SET is_active = false
-- WHERE team_id = 'team-uuid' AND player_id = 'player-uuid';

-- Add your roster changes below:

