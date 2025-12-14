-- ========================================
-- POPULATE DIVISION PLAYERS FROM EXISTING TEAM ROSTERS
-- ========================================
-- This script backfills division_players from existing team_players data
-- 
-- IMPORTANT: This is now LEAGUE-AGNOSTIC
-- It populates division_players for ALL clubs across ALL leagues
-- (APSL, CASA, TCWL, etc.) automatically
--
-- Key behavior:
-- - No WHERE clause limiting to specific clubs
-- - ON CONFLICT handles duplicate entries (same player on multiple teams in same division)
-- - Uses DISTINCT to prevent duplicates at query level
-- - Preserves 'active' status over 'inactive' on conflict
-- - Automatically handles new leagues and clubs as they're added
-- - Idempotent: Safe to run multiple times (ON CONFLICT prevents duplicates)

-- NOTE: Some records may already be in division_players from external_identities
-- This query ensures completeness and consistency across all sources

-- Populate division_players for ALL clubs (all leagues)
-- This finds all players on any team and adds them to their division roster
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
-- Intentionally NO WHERE clause - this gets ALL clubs from ALL leagues
ON CONFLICT (division_id, player_id) DO UPDATE SET
    status = CASE 
        WHEN EXCLUDED.status = 'active' THEN 'active'  -- Prefer active status
        ELSE division_players.status
    END,
    last_active_season = COALESCE(EXCLUDED.last_active_season, division_players.last_active_season),
    updated_at = CURRENT_TIMESTAMP;

-- Verify results - Summary across ALL divisions
SELECT 
    'Division Players Summary (All Leagues)' as report_section,
    COUNT(*) as total_players,
    COUNT(*) FILTER (WHERE status = 'active') as active_players,
    COUNT(*) FILTER (WHERE status = 'inactive') as inactive_players
FROM division_players;

-- Breakdown by club/division (for visibility)
SELECT 
    'Players by Club/Division' as report_section,
    c.display_name as club,
    sd.display_name as division,
    COUNT(DISTINCT dp.player_id) as total_players,
    COUNT(DISTINCT dp.player_id) FILTER (WHERE dp.status = 'active') as active_players
FROM division_players dp
JOIN sport_divisions sd ON dp.division_id = sd.id
JOIN clubs c ON sd.club_id = c.id
GROUP BY c.id, c.display_name, sd.id, sd.display_name
ORDER BY c.display_name, sd.display_name;
