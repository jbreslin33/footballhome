-- ========================================
-- POPULATE DIVISION PLAYERS FROM EXISTING TEAM ROSTERS
-- ========================================
-- This script backfills division_players from existing team_players data

-- First, ensure the Lighthouse Soccer division exists
-- (Assuming it's already created in your 10-clubs-teams.sql)

-- Populate division_players for Lighthouse 1893 SC Soccer Division
-- This finds all players on any Lighthouse team and adds them to the division roster
INSERT INTO division_players (division_id, player_id, status, registration_date, last_active_season, notes)
SELECT DISTINCT
    t.division_id,
    tp.player_id,
    CASE 
        WHEN tp.is_active = true THEN 'active'
        ELSE 'inactive'
    END as status,
    tp.joined_at::date as registration_date,
    t.season as last_active_season,
    'Imported from team roster' as notes
FROM team_players tp
JOIN teams t ON tp.team_id = t.id
JOIN sport_divisions sd ON t.division_id = sd.id
JOIN clubs c ON sd.club_id = c.id
WHERE c.slug = 'lighthouse-1893-sc'  -- Adjust to your actual club slug
ON CONFLICT (division_id, player_id) DO UPDATE SET
    status = CASE 
        WHEN EXCLUDED.status = 'active' THEN 'active'  -- Prefer active status
        ELSE division_players.status
    END,
    last_active_season = COALESCE(EXCLUDED.last_active_season, division_players.last_active_season),
    updated_at = CURRENT_TIMESTAMP;

-- Verify results
SELECT 
    'Division Players Summary' as report_section,
    COUNT(*) as total_players,
    COUNT(*) FILTER (WHERE status = 'active') as active_players,
    COUNT(*) FILTER (WHERE status = 'inactive') as inactive_players
FROM division_players dp
JOIN sport_divisions sd ON dp.division_id = sd.id
JOIN clubs c ON sd.club_id = c.id
WHERE c.slug = 'lighthouse-1893-sc';
