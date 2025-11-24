-- ========================================
-- CASA SELECT LEAGUE STRUCTURE
-- ========================================
-- CASA Select League - Recreational soccer league
-- Includes Lighthouse Boys Club and Lighthouse Old Timers Club

-- Create CASA Select League
INSERT INTO leagues (id, name, display_name, slug, sport_id, is_active)
VALUES (
    'ca5a0000-0000-0000-0000-000000000001',
    'CASA Select',
    'CASA Select League',
    'casa-select',
    (SELECT id FROM sports WHERE name = 'soccer'),
    true
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    display_name = EXCLUDED.display_name,
    updated_at = CURRENT_TIMESTAMP;

-- Create CASA Select Conference (single conference for now)
INSERT INTO league_conferences (id, league_id, name, display_name, slug, tier, is_active)
VALUES (
    'ca5a0000-0000-0000-0001-000000000001',
    'ca5a0000-0000-0000-0000-000000000001',
    'CASA Select',
    'CASA Select',
    'casa-select',
    1,
    true
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    display_name = EXCLUDED.display_name,
    tier = EXCLUDED.tier,
    updated_at = CURRENT_TIMESTAMP;

-- Create CASA Select Division
INSERT INTO league_divisions (id, conference_id, name, display_name, slug, tier, is_active)
VALUES (
    'ca5a0000-0000-0000-0002-000000000001',
    'ca5a0000-0000-0000-0001-000000000001',
    'CASA Select Division',
    'CASA Select Division',
    'casa-select-division',
    1,
    true
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    display_name = EXCLUDED.display_name,
    tier = EXCLUDED.tier,
    updated_at = CURRENT_TIMESTAMP;

-- Lighthouse club already exists from APSL data, we'll just reference it
-- Create sport divisions and teams for CASA

DO $$
DECLARE
    lighthouse_club_id UUID;
    soccer_sport_id UUID;
    casa_division_id UUID := 'ca5a0000-0000-0000-0002-000000000001';
    boys_division_id UUID := 'ca5a0001-0000-0000-0000-000000000001';
    old_timers_division_id UUID := 'ca5a0002-0000-0000-0000-000000000001';
BEGIN
    -- Get the Lighthouse club ID (created by APSL data)
    SELECT id INTO lighthouse_club_id FROM clubs WHERE name = 'Lighthouse 1893 SC';
    
    -- Get soccer sport ID
    SELECT id INTO soccer_sport_id FROM sports WHERE name = 'soccer';
    
    IF lighthouse_club_id IS NOT NULL AND soccer_sport_id IS NOT NULL THEN
        -- Create Sport Division for Boys Club
        INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
        VALUES (
            boys_division_id,
            lighthouse_club_id,
            soccer_sport_id,
            'Lighthouse Boys Club',
            'Lighthouse Boys Club',
            'lighthouse-boys-club',
            true
        )
        ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            display_name = EXCLUDED.display_name,
            updated_at = CURRENT_TIMESTAMP;
        
        -- Create Sport Division for Old Timers Club
        INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
        VALUES (
            old_timers_division_id,
            lighthouse_club_id,
            soccer_sport_id,
            'Lighthouse Old Timers Club',
            'Lighthouse Old Timers Club',
            'lighthouse-old-timers-club',
            true
        )
        ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            display_name = EXCLUDED.display_name,
            updated_at = CURRENT_TIMESTAMP;
        
        -- Create Lighthouse Boys Club team
        INSERT INTO teams (id, division_id, league_division_id, name, season, age_group, skill_level, is_active)
        VALUES (
            'ca5a0001-0000-0000-0001-000000000001',
            boys_division_id,
            casa_division_id,
            'Lighthouse Boys Club',
            '2024-2025',
            'youth',
            'recreational',
            true
        )
        ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            updated_at = CURRENT_TIMESTAMP;
        
        -- Create Lighthouse Old Timers Club team
        INSERT INTO teams (id, division_id, league_division_id, name, season, age_group, skill_level, is_active)
        VALUES (
            'ca5a0002-0000-0000-0001-000000000001',
            old_timers_division_id,
            casa_division_id,
            'Lighthouse Old Timers Club',
            '2024-2025',
            'adult',
            'recreational',
            true
        )
        ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            updated_at = CURRENT_TIMESTAMP;
    END IF;
END $$;
