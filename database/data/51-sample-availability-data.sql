-- =====================================================
-- Sample Player Availability Data
-- =====================================================
-- Demonstrates various availability scenarios
-- =====================================================

-- Sample medical issues
-- Get a few player IDs to work with
DO $$
DECLARE
    v_player1 UUID;
    v_player2 UUID;
    v_player3 UUID;
    v_coach UUID;
BEGIN
    -- Get some random active players
    SELECT player_id INTO v_player1 FROM division_players WHERE status = 'active' LIMIT 1 OFFSET 0;
    SELECT player_id INTO v_player2 FROM division_players WHERE status = 'active' LIMIT 1 OFFSET 5;
    SELECT player_id INTO v_player3 FROM division_players WHERE status = 'active' LIMIT 1 OFFSET 10;
    
    -- Get a coach user (first user will be coach)
    SELECT id INTO v_coach FROM users LIMIT 1;
    
    -- Example 1: Minor ankle sprain - can practice but not play games
    IF v_player1 IS NOT NULL THEN
        INSERT INTO player_medical_status (
            player_id, status, injury_type, severity,
            available_for_practices, available_for_games,
            injury_date, expected_return_date,
            affects_all_teams, notes, created_by
        ) VALUES (
            v_player1, 'injured', 'ankle_sprain', 'minor',
            true, false,
            CURRENT_DATE - INTERVAL '3 days', CURRENT_DATE + INTERVAL '7 days',
            true, 'Light training only. Can jog but no cutting movements.',
            v_coach
        );
    END IF;
    
    -- Example 2: Concussion protocol - no activity
    IF v_player2 IS NOT NULL THEN
        INSERT INTO player_medical_status (
            player_id, status, injury_type, severity,
            available_for_practices, available_for_games,
            injury_date, expected_return_date,
            medical_clearance_required, affects_all_teams,
            notes, created_by
        ) VALUES (
            v_player2, 'concussion_protocol', 'concussion', 'moderate',
            false, false,
            CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '10 days',
            true, true,
            'Return to play protocol step 2. Medical clearance required before full contact.',
            v_coach
        );
    END IF;
    
    -- Example 3: Recovering from knee injury - cleared for everything
    IF v_player3 IS NOT NULL THEN
        INSERT INTO player_medical_status (
            player_id, status, injury_type, severity,
            available_for_practices, available_for_games,
            injury_date, expected_return_date, actual_return_date,
            medical_clearance_date, affects_all_teams,
            notes, created_by
        ) VALUES (
            v_player3, 'recovering', 'knee', 'moderate',
            true, true,
            CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE - INTERVAL '5 days',
            CURRENT_DATE - INTERVAL '5 days', true,
            'Fully cleared. Monitor workload for first few games back.',
            v_coach
        );
    END IF;
    
END $$;

-- Sample academic issues
-- Example of player on academic probation
DO $$
DECLARE
    v_player UUID;
    v_coach UUID;
BEGIN
    SELECT player_id INTO v_player FROM division_players WHERE status = 'active' LIMIT 1 OFFSET 15;
    SELECT id INTO v_coach FROM users LIMIT 1;
    
    IF v_player IS NOT NULL THEN
        INSERT INTO player_academic_status (
            player_id, status, gpa, required_gpa,
            available_for_practices, available_for_games,
            status_start_date, review_date,
            academic_term, affects_all_teams,
            notes, created_by
        ) VALUES (
            v_player, 'probation', 2.3, 2.5,
            true, false,
            CURRENT_DATE - INTERVAL '14 days', CURRENT_DATE + INTERVAL '30 days',
            'Fall 2025', true,
            'Player must maintain 2.5 GPA to regain game eligibility. Can practice to stay fit.',
            v_coach
        );
    END IF;
END $$;

-- Show summary of created test data
SELECT 
    'Medical Issues' as type,
    COUNT(*) as count
FROM player_medical_status
WHERE resolved_at IS NULL
UNION ALL
SELECT 
    'Academic Issues',
    COUNT(*)
FROM player_academic_status
WHERE resolved_at IS NULL;
