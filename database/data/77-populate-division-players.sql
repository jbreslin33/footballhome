-- ========================================
-- POPULATE DIVISION PLAYERS
-- ========================================
-- Insert all players from teams in sport divisions into division_players table
-- This recreates the aggregated view for division roster management

-- For Lighthouse 1893 SC division, insert all team players
INSERT INTO division_players (division_id, player_id, status, last_active_season)
SELECT 
  sd.id as division_id,
  tp.player_id,
  'active' as status,
  '2024-2025' as last_active_season
FROM sport_divisions sd
JOIN teams t ON sd.id = t.division_id
JOIN team_players tp ON t.id = tp.team_id
WHERE sd.display_name = 'Lighthouse 1893 SC Soccer'
ON CONFLICT (division_id, player_id) DO NOTHING;

