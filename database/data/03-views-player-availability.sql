-- =====================================================
-- Player Availability Views
-- =====================================================
-- Convenient views for checking player availability
-- =====================================================

-- Current active medical issues
CREATE OR REPLACE VIEW v_active_medical_issues AS
SELECT 
    m.id,
    m.player_id,
    u.first_name,
    u.last_name,
    m.status,
    m.injury_type,
    m.severity,
    m.available_for_practices,
    m.available_for_games,
    m.injury_date,
    m.expected_return_date,
    m.medical_clearance_required,
    m.affects_all_teams,
    m.team_id,
    t.name as team_name,
    m.notes,
    m.created_at,
    m.updated_at
FROM player_medical_status m
JOIN players p ON m.player_id = p.id
JOIN users u ON p.id = u.id
LEFT JOIN teams t ON m.team_id = t.id
WHERE m.resolved_at IS NULL
  AND m.status != 'healthy'
ORDER BY m.severity DESC, m.injury_date ASC;

-- Current active academic issues
CREATE OR REPLACE VIEW v_active_academic_issues AS
SELECT 
    a.id,
    a.player_id,
    u.first_name,
    u.last_name,
    a.status,
    a.gpa,
    a.required_gpa,
    a.available_for_practices,
    a.available_for_games,
    a.status_start_date,
    a.status_end_date,
    a.review_date,
    a.affects_all_teams,
    a.team_id,
    t.name as team_name,
    a.academic_term,
    a.notes,
    a.created_at,
    a.updated_at
FROM player_academic_status a
JOIN players p ON a.player_id = p.id
JOIN users u ON p.id = u.id
LEFT JOIN teams t ON a.team_id = t.id
WHERE a.resolved_at IS NULL
  AND a.status != 'eligible'
ORDER BY a.status_start_date DESC;

-- Complete player availability summary
CREATE OR REPLACE VIEW v_player_availability AS
SELECT 
    p.id as player_id,
    u.first_name,
    u.last_name,
    
    -- Medical availability
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM player_medical_status m 
            WHERE m.player_id = p.id 
            AND m.resolved_at IS NULL 
            AND m.status != 'healthy'
        ) THEN 'Has Medical Issue'
        ELSE 'Medically Clear'
    END as medical_status,
    
    -- Academic availability
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM player_academic_status a 
            WHERE a.player_id = p.id 
            AND a.resolved_at IS NULL 
            AND a.status != 'eligible'
        ) THEN 'Has Academic Issue'
        ELSE 'Academically Eligible'
    END as academic_status,
    
    -- Overall practice availability (ALL issues must allow practices)
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM player_medical_status m 
            WHERE m.player_id = p.id 
            AND m.resolved_at IS NULL 
            AND m.available_for_practices = false
        ) OR EXISTS (
            SELECT 1 FROM player_academic_status a 
            WHERE a.player_id = p.id 
            AND a.resolved_at IS NULL 
            AND a.available_for_practices = false
        ) THEN false
        ELSE true
    END as can_practice,
    
    -- Overall game availability (ALL issues must allow games)
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM player_medical_status m 
            WHERE m.player_id = p.id 
            AND m.resolved_at IS NULL 
            AND m.available_for_games = false
        ) OR EXISTS (
            SELECT 1 FROM player_academic_status a 
            WHERE a.player_id = p.id 
            AND a.resolved_at IS NULL 
            AND a.available_for_games = false
        ) THEN false
        ELSE true
    END as can_play_games,
    
    -- Count of active issues
    (SELECT COUNT(*) FROM player_medical_status m 
     WHERE m.player_id = p.id AND m.resolved_at IS NULL AND m.status != 'healthy') as medical_issues_count,
    (SELECT COUNT(*) FROM player_academic_status a 
     WHERE a.player_id = p.id AND a.resolved_at IS NULL AND a.status != 'eligible') as academic_issues_count,
    
    -- Division status
    dp.status as division_status
    
FROM players p
JOIN users u ON p.id = u.id
LEFT JOIN division_players dp ON p.id = dp.player_id
WHERE dp.status = 'active'
ORDER BY u.last_name, u.first_name;

-- Team-specific availability view
CREATE OR REPLACE VIEW v_team_player_availability AS
SELECT 
    tp.team_id,
    t.name as team_name,
    tp.player_id,
    u.first_name,
    u.last_name,
    tp.is_active,
    rs.display_name as roster_status,
    
    -- Medical availability for this team
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM player_medical_status m 
            WHERE m.player_id = p.id 
            AND m.resolved_at IS NULL 
            AND m.status != 'healthy'
            AND (m.affects_all_teams = true OR m.team_id = tp.team_id)
        ) THEN 'Has Issue'
        ELSE 'Clear'
    END as medical_status,
    
    -- Academic availability for this team
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM player_academic_status a 
            WHERE a.player_id = p.id 
            AND a.resolved_at IS NULL 
            AND a.status != 'eligible'
            AND (a.affects_all_teams = true OR a.team_id = tp.team_id)
        ) THEN 'Has Issue'
        ELSE 'Eligible'
    END as academic_status,
    
    -- Can practice with this team?
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM player_medical_status m 
            WHERE m.player_id = p.id 
            AND m.resolved_at IS NULL 
            AND m.available_for_practices = false
            AND (m.affects_all_teams = true OR m.team_id = tp.team_id)
        ) OR EXISTS (
            SELECT 1 FROM player_academic_status a 
            WHERE a.player_id = p.id 
            AND a.resolved_at IS NULL 
            AND a.available_for_practices = false
            AND (a.affects_all_teams = true OR a.team_id = tp.team_id)
        ) THEN false
        ELSE true
    END as can_practice,
    
    -- Can play games with this team?
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM player_medical_status m 
            WHERE m.player_id = p.id 
            AND m.resolved_at IS NULL 
            AND m.available_for_games = false
            AND (m.affects_all_teams = true OR m.team_id = tp.team_id)
        ) OR EXISTS (
            SELECT 1 FROM player_academic_status a 
            WHERE a.player_id = p.id 
            AND a.resolved_at IS NULL 
            AND a.available_for_games = false
            AND (a.affects_all_teams = true OR a.team_id = tp.team_id)
        ) THEN false
        ELSE true
    END as can_play_games

FROM team_players tp
JOIN teams t ON tp.team_id = t.id
JOIN players p ON tp.player_id = p.id
JOIN users u ON p.id = u.id
LEFT JOIN roster_statuses rs ON tp.roster_status_id = rs.id
WHERE tp.is_active = true
ORDER BY t.name, u.last_name, u.first_name;

-- Comments
COMMENT ON VIEW v_active_medical_issues IS 'All unresolved medical issues affecting player availability';
COMMENT ON VIEW v_active_academic_issues IS 'All unresolved academic issues affecting player eligibility';
COMMENT ON VIEW v_player_availability IS 'Overall availability summary for all active division players';
COMMENT ON VIEW v_team_player_availability IS 'Team-specific availability considering team scope of issues';
