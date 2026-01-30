-- ============================================================================
-- 044-auto-create-clubs.sql
-- Auto-create clubs for ALL teams without club_id (works for any league)
-- ============================================================================
--
-- Purpose: Every team needs a club. This creates org + club for any orphan team.
-- Runs BEFORE curation (045) which will merge related teams under parent clubs.
--
-- Strategy:
--   1. For each team without club_id (any league/source_system_id)
--   2. Create organization with team name
--   3. Create club with team name under that org
--   4. Link team to new club
--
-- NOTE: Many of these will be orphans that get merged in 045-cross-league-curation.sql

DO $$
DECLARE
    team_record RECORD;
    org_id INTEGER;
    new_club_id INTEGER;
    teams_processed INTEGER := 0;
BEGIN
    RAISE NOTICE 'Auto-creating clubs for teams without club_id...';
    
    -- Process EVERY team without a club, regardless of source_system_id
    FOR team_record IN 
        SELECT id, name, source_system_id
        FROM teams 
        WHERE club_id IS NULL
        ORDER BY source_system_id, name
    LOOP
        -- First, check if there's already a club with this exact name (cross-league matching)
        -- This handles teams from different leagues that are actually the same club
        SELECT c.id INTO new_club_id
        FROM clubs c
        WHERE c.name = team_record.name
        LIMIT 1;
        
        -- If no existing club found, create new org + club
        IF new_club_id IS NULL THEN
            -- Check if organization with this name already exists
            SELECT id INTO org_id 
            FROM organizations 
            WHERE name = team_record.name;
            
            -- If org doesn't exist, create it
            IF org_id IS NULL THEN
                INSERT INTO organizations (name, short_name, is_active)
                VALUES (
                    team_record.name,
                    CASE 
                        WHEN LENGTH(team_record.name) > 30 THEN LEFT(team_record.name, 30)
                        ELSE team_record.name
                    END,
                    true
                )
                RETURNING id INTO org_id;
            END IF;
            
            -- Create club with team name under that org
            INSERT INTO clubs (organization_id, name, sport_id, is_active)
            VALUES (
                org_id,
                team_record.name,
                1,  -- Soccer
                true
            )
            RETURNING id INTO new_club_id;
        END IF;
        
        -- Link team to club (either existing or newly created)
        UPDATE teams 
        SET club_id = new_club_id 
        WHERE id = team_record.id;
        
        teams_processed := teams_processed + 1;
        
        -- Progress indicator every 50 teams
        IF teams_processed % 50 = 0 THEN
            RAISE NOTICE '  Processed % teams...', teams_processed;
        END IF;
    END LOOP;
    
    RAISE NOTICE '✓ Created clubs for % teams', teams_processed;
END $$;

-- Update sequences to prevent ID conflicts
SELECT setval('organizations_id_seq', (SELECT COALESCE(MAX(id), 0) FROM organizations));
SELECT setval('clubs_id_seq', (SELECT COALESCE(MAX(id), 0) FROM clubs));
