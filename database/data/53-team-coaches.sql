-- ========================================
-- AUTO-ASSIGN TEAM COACHES
-- ========================================
-- Dynamically assigns James Breslin as Head Coach to ALL Lighthouse teams
-- This runs after all scrapers (APSL, CASA) have populated the teams table.

/*
DO $$
DECLARE
    admin_user_id UUID := '77d77471-1250-47e0-81ab-d4626595d63c'; -- James Breslin
    team_record RECORD;
BEGIN
    -- Loop through all teams containing 'Lighthouse' (case-insensitive)
    FOR team_record IN 
        SELECT id, name 
        FROM teams 
        WHERE name ILIKE '%Lighthouse%'
    LOOP
        -- Insert coach assignment if it doesn't exist
        INSERT INTO team_coaches (id, team_id, coach_id, coach_role, is_primary, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'coach-' || team_record.id || '-' || admin_user_id), -- Deterministic UUID
            team_record.id,
            admin_user_id,
            'Head Coach',
            true,
            true
        )
        ON CONFLICT (team_id, coach_id) DO UPDATE SET
            coach_role = 'Head Coach',
            is_primary = true,
            is_active = true;
            
        RAISE NOTICE 'Assigned James Breslin as Head Coach for %', team_record.name;
    END LOOP;
END $$;
*/
