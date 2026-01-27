-- ============================================================================
-- 042c-standalone-team-clubs.sql  
-- Create clubs for standalone CSL teams (teams without "II", "III", "Old Boys" variants)
-- ============================================================================
--
-- This file runs AFTER:
--   042-teams-complete.sql (creates teams from scraped data)
--   042a-clubs-from-teams.sql (creates clubs for team families)
--   042b-team-club-associations.sql (associates team families with clubs)
--
-- Purpose: Every team should have a club. Standalone teams get their own club.
-- For teams without variants, we create a club with the same name as the team.
--
-- Strategy:
--   1. Find all CSL teams without club_id (orphan teams)
--   2. For each orphan team, create an organization + club with matching name
--   3. Associate the team with its new club
--
-- NOTE: This uses dynamic SQL to avoid hardcoding 120+ team names

DO $$
DECLARE
    team_record RECORD;
    org_id INTEGER;
    new_club_id INTEGER;
    teams_processed INTEGER := 0;
BEGIN
    -- Process each orphan CSL team
    FOR team_record IN 
        SELECT id, name 
        FROM teams 
        WHERE source_system_id = 3 
          AND club_id IS NULL
        ORDER BY name
    LOOP
        -- Generate unique org_id (starting from 300 to avoid conflicts)
        org_id := 300 + team_record.id;
        
        -- Create organization (if it doesn't exist)
        INSERT INTO organizations (id, name, short_name, is_active)
        VALUES (
            org_id,
            team_record.name,
            CASE 
                WHEN LENGTH(team_record.name) > 30 THEN LEFT(team_record.name, 30)
                ELSE team_record.name
            END,
            true
        )
        ON CONFLICT (name) DO UPDATE 
            SET id = organizations.id
        RETURNING id INTO org_id;
        
        -- If organization already existed, get its ID
        IF org_id IS NULL THEN
            SELECT id INTO org_id FROM organizations WHERE name = team_record.name;
        END IF;
        
        -- Create club with same name as team
        INSERT INTO clubs (id, organization_id, name, sport_id, is_active)
        VALUES (
            org_id,  -- Use same ID as organization for consistency
            org_id,
            team_record.name,
            1,  -- Soccer
            true
        )
        ON CONFLICT (organization_id, name) DO UPDATE
            SET id = clubs.id
        RETURNING id INTO new_club_id;
        
        -- If club already existed, get its ID
        IF new_club_id IS NULL THEN
            SELECT id INTO new_club_id 
            FROM clubs 
            WHERE organization_id = org_id AND name = team_record.name;
        END IF;
        
        -- Associate team with its club
        UPDATE teams 
        SET club_id = new_club_id 
        WHERE id = team_record.id;
        
        teams_processed := teams_processed + 1;
    END LOOP;
    
    -- Report results
    RAISE NOTICE 'Standalone Team Clubs Created:';
    RAISE NOTICE '  Teams processed: %', teams_processed;
    RAISE NOTICE '  Orphan teams remaining: %', (
        SELECT COUNT(*) 
        FROM teams 
        WHERE source_system_id = 3 AND club_id IS NULL
    );
END $$;

-- Verification: Show sample of teams with their clubs
DO $$
BEGIN
    RAISE NOTICE 'Sample of CSL teams with clubs (first 10):';
END $$;

SELECT 
    t.id,
    t.name AS team_name,
    c.name AS club_name,
    o.name AS organization_name
FROM teams t
JOIN clubs c ON c.id = t.club_id
JOIN organizations o ON o.id = c.organization_id
WHERE t.source_system_id = 3
ORDER BY t.name
LIMIT 10;
