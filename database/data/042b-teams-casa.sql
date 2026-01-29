-- ============================================================================
-- CASA Select Teams with Clubs (2025/2026 Season)
-- Generated: 2026-01-29
-- Source: Standings pages from casasoccerleagues.com
-- Teams parsed: 20
-- ============================================================================
-- 
-- Pattern: Create org -> club -> team for each scraped team
-- Cleanup file (044e) will merge duplicate clubs later

DO $$
DECLARE
    team_names TEXT[] := ARRAY[
        'Adé United FC',
        'Alloy Soccer Club Reserves',
        'BCFC All Stars',
        'Club de Futbol Armada',
        'F&M FC',
        'Flatley FC',
        'Gambeta FC',
        'Illyrians FC',
        'Jaguars United FC',
        'Lancaster City FC',
        'Lighthouse Boys Club',
        'Lighthouse Old Timers Club',
        'Oaklyn United FC II',
        'Persepolis FC',
        'Persepolis United FC II',
        'Philadelphia SC II',
        'Phoenix SCM',
        'Phoenix SCR',
        'South Shore FC',
        'Strictly Nos Fc'
    ];
    team_name TEXT;
    org_id INTEGER;
    club_id INTEGER;
    team_id INTEGER;
BEGIN
    FOREACH team_name IN ARRAY team_names
    LOOP
        -- Create organization
        INSERT INTO organizations (name, short_name, is_active)
        VALUES (team_name, team_name, true)
        ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
        RETURNING id INTO org_id;

        -- Create club
        INSERT INTO clubs (organization_id, name, is_active)
        VALUES (org_id, team_name, true)
        ON CONFLICT (organization_id, name) DO UPDATE SET name = EXCLUDED.name
        RETURNING id INTO club_id;

        -- Create team with club association
        INSERT INTO teams (name, source_system_id, club_id)
        VALUES (team_name, 2, club_id)
        ON CONFLICT (source_system_id, name) DO UPDATE 
        SET club_id = EXCLUDED.club_id
        RETURNING id INTO team_id;
    END LOOP;

    RAISE NOTICE 'Created % CASA Select teams with clubs', array_length(team_names, 1);
END $$;

-- Update sequences
SELECT setval('organizations_id_seq', (SELECT COALESCE(MAX(id), 0) FROM organizations));
SELECT setval('clubs_id_seq', (SELECT COALESCE(MAX(id), 0) FROM clubs));
SELECT setval('teams_id_seq', (SELECT COALESCE(MAX(id), 0) FROM teams));
