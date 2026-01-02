-- ============================================================================
-- STATISTICS VIEWS - Replace Denormalized Stats Tables
-- ============================================================================
-- These views calculate statistics on-the-fly from normalized source data,
-- eliminating data redundancy and synchronization issues.

-- Team Season Standings View
-- Calculates wins, losses, ties, goals, and points per team per division
CREATE OR REPLACE VIEW team_season_standings AS
SELECT 
    t.id as team_id,
    t.name as team_name,
    md.division_id,
    d.name as division_name,
    COUNT(DISTINCT m.id) as games_played,
    
    -- Wins: home team won OR away team won
    SUM(CASE 
        WHEN m.home_team_id = t.id AND m.home_score > m.away_score THEN 1
        WHEN m.away_team_id = t.id AND m.away_score > m.home_score THEN 1
        ELSE 0 
    END) as wins,
    
    -- Losses: home team lost OR away team lost
    SUM(CASE 
        WHEN m.home_team_id = t.id AND m.home_score < m.away_score THEN 1
        WHEN m.away_team_id = t.id AND m.away_score < m.home_score THEN 1
        ELSE 0 
    END) as losses,
    
    -- Ties: scores equal
    SUM(CASE 
        WHEN m.home_score = m.away_score THEN 1
        ELSE 0 
    END) as ties,
    
    -- Goals For: team's score in each match
    SUM(CASE 
        WHEN m.home_team_id = t.id THEN m.home_score
        WHEN m.away_team_id = t.id THEN m.away_score
        ELSE 0 
    END) as goals_for,
    
    -- Goals Against: opponent's score in each match
    SUM(CASE 
        WHEN m.home_team_id = t.id THEN m.away_score
        WHEN m.away_team_id = t.id THEN m.home_score
        ELSE 0 
    END) as goals_against,
    
    -- Goal Differential
    SUM(CASE 
        WHEN m.home_team_id = t.id THEN (m.home_score - m.away_score)
        WHEN m.away_team_id = t.id THEN (m.away_score - m.home_score)
        ELSE 0 
    END) as goal_differential,
    
    -- Points (3 for win, 1 for tie, 0 for loss)
    SUM(CASE 
        WHEN m.home_team_id = t.id AND m.home_score > m.away_score THEN 3
        WHEN m.away_team_id = t.id AND m.away_score > m.home_score THEN 3
        WHEN m.home_score = m.away_score THEN 1
        ELSE 0 
    END) as points

FROM teams t
JOIN match_divisions md ON md.match_id IN (
    SELECT m2.id FROM matches m2 
    WHERE m2.home_team_id = t.id OR m2.away_team_id = t.id
)
JOIN divisions d ON d.id = md.division_id
JOIN matches m ON m.id = md.match_id
WHERE m.match_status_id = 3  -- Only completed matches
  AND m.home_score IS NOT NULL
  AND m.away_score IS NOT NULL
GROUP BY t.id, t.name, md.division_id, d.name;

COMMENT ON VIEW team_season_standings IS 'Calculates team standings from completed match results. Always accurate, no manual sync needed.';


-- Player Season Stats View
-- Calculates goals, assists, cards from match_events
CREATE OR REPLACE VIEW player_season_stats_view AS
SELECT 
    p.id as player_id,
    p.first_name,
    p.last_name,
    p.first_name || ' ' || p.last_name as full_name,
    tp.team_id,
    t.name as team_name,
    '2025' as season,  -- TODO: Make dynamic based on match dates
    
    -- Goals scored (event_type_id = 1)
    COUNT(CASE WHEN me.event_type_id = 1 THEN 1 END) as goals,
    
    -- Assists (event_type_id = 2, OR assisted_by_player_id matches)
    COUNT(CASE WHEN me.event_type_id = 2 THEN 1 END) + 
    COUNT(CASE WHEN me2.assisted_by_player_id = p.id THEN 1 END) as assists,
    
    -- Yellow cards (event_type_id = 3)
    COUNT(CASE WHEN me.event_type_id = 3 THEN 1 END) as yellow_cards,
    
    -- Red cards (event_type_id = 4)
    COUNT(CASE WHEN me.event_type_id = 4 THEN 1 END) as red_cards,
    
    -- Games played (distinct matches with events OR lineups)
    COUNT(DISTINCT COALESCE(me.match_id, ml.match_id)) as games_played

FROM players p
LEFT JOIN team_division_players tp ON tp.player_id = p.id
LEFT JOIN teams t ON t.id = tp.team_id
LEFT JOIN match_events me ON me.player_id = p.id
LEFT JOIN match_events me2 ON me2.assisted_by_player_id = p.id  -- Count assists via assisted_by
LEFT JOIN match_lineups ml ON ml.player_id = p.id
WHERE me.match_id IN (SELECT id FROM matches WHERE match_status_id = 3)  -- Completed matches only
   OR ml.match_id IN (SELECT id FROM matches WHERE match_status_id = 3)
GROUP BY p.id, p.first_name, p.last_name, tp.team_id, t.name;

COMMENT ON VIEW player_season_stats_view IS 'Calculates player statistics from match_events. Always accurate and up-to-date.';


-- Team Match History View
-- Per-match record for each team (useful for historical analysis)
CREATE OR REPLACE VIEW team_match_history AS
SELECT 
    m.id as match_id,
    m.match_date,
    m.match_time,
    t.id as team_id,
    t.name as team_name,
    md.division_id,
    d.name as division_name,
    
    -- Opponent info
    CASE 
        WHEN m.home_team_id = t.id THEN m.away_team_id
        ELSE m.home_team_id 
    END as opponent_id,
    CASE 
        WHEN m.home_team_id = t.id THEN at.name
        ELSE ht.name 
    END as opponent_name,
    
    -- Home/Away
    CASE 
        WHEN m.home_team_id = t.id THEN 'HOME'
        ELSE 'AWAY'
    END as location,
    
    -- Score
    CASE 
        WHEN m.home_team_id = t.id THEN m.home_score
        ELSE m.away_score 
    END as goals_for,
    CASE 
        WHEN m.home_team_id = t.id THEN m.away_score
        ELSE m.home_score 
    END as goals_against,
    
    -- Result
    CASE 
        WHEN m.home_team_id = t.id AND m.home_score > m.away_score THEN 'WIN'
        WHEN m.away_team_id = t.id AND m.away_score > m.home_score THEN 'WIN'
        WHEN m.home_score = m.away_score THEN 'TIE'
        ELSE 'LOSS'
    END as result,
    
    -- Points earned
    CASE 
        WHEN m.home_team_id = t.id AND m.home_score > m.away_score THEN 3
        WHEN m.away_team_id = t.id AND m.away_score > m.home_score THEN 3
        WHEN m.home_score = m.away_score THEN 1
        ELSE 0
    END as points_earned

FROM matches m
JOIN teams t ON (t.id = m.home_team_id OR t.id = m.away_team_id)
JOIN match_divisions md ON md.match_id = m.id
JOIN divisions d ON d.id = md.division_id
LEFT JOIN teams ht ON ht.id = m.home_team_id
LEFT JOIN teams at ON at.id = m.away_team_id
WHERE m.match_status_id = 3  -- Completed matches only
  AND m.home_score IS NOT NULL
  AND m.away_score IS NOT NULL
ORDER BY m.match_date DESC, m.match_time DESC;

COMMENT ON VIEW team_match_history IS 'Per-match results for each team. Useful for analyzing trends over time.';


-- Player Match Performance View
-- Per-match stats for each player
CREATE OR REPLACE VIEW player_match_performance AS
SELECT 
    m.id as match_id,
    m.match_date,
    p.id as player_id,
    p.first_name || ' ' || p.last_name as player_name,
    t.id as team_id,
    t.name as team_name,
    
    -- Events in this match
    COUNT(CASE WHEN me.event_type_id = 1 THEN 1 END) as goals,
    COUNT(CASE WHEN me.event_type_id = 2 THEN 1 END) + 
        COUNT(CASE WHEN me2.assisted_by_player_id = p.id THEN 1 END) as assists,
    COUNT(CASE WHEN me.event_type_id = 3 THEN 1 END) as yellow_cards,
    COUNT(CASE WHEN me.event_type_id = 4 THEN 1 END) as red_cards,
    
    -- Lineup info
    MAX(ml.position_id) as position_id,
    BOOL_OR(ml.is_starter) as was_starter

FROM matches m
JOIN match_lineups ml ON ml.match_id = m.id
JOIN players p ON p.id = ml.player_id
JOIN teams t ON t.id = ml.team_id
LEFT JOIN match_events me ON me.match_id = m.id AND me.player_id = p.id
LEFT JOIN match_events me2 ON me2.match_id = m.id AND me2.assisted_by_player_id = p.id
WHERE m.match_status_id = 3  -- Completed matches
GROUP BY m.id, m.match_date, p.id, p.first_name, p.last_name, t.id, t.name
ORDER BY m.match_date DESC;

COMMENT ON VIEW player_match_performance IS 'Per-match performance stats for each player.';
