-- ============================================================================
-- 044e-casa-club-cleanup.sql
-- Cleanup CASA Select clubs - merge related teams under parent clubs
-- Generated: 2026-01-29
-- ============================================================================
--
-- This file runs AFTER:
--   042b-teams-casa.sql (creates initial club for each team)
--
-- Purpose: Merge related teams under same parent club
-- Examples:
--   - Lighthouse Boys Club, Lighthouse Old Timers Club -> Lighthouse 1893 SC (club 1)
--   - Phoenix SCM, Phoenix SCR -> Phoenix Sport Club
--   - Persepolis FC, Persepolis United FC II -> Persepolis
--

-- Lighthouse teams -> Lighthouse 1893 SC (existing club 1)
UPDATE teams SET club_id = 1 
WHERE name IN ('Lighthouse Boys Club', 'Lighthouse Old Timers Club') AND source_system_id = 2;

-- Phoenix Sport Club family
-- Merge SCM and SCR under single Phoenix Sport Club
DO $$
DECLARE
    phoenix_org_id INTEGER;
    phoenix_club_id INTEGER;
BEGIN
    -- Get or create Phoenix Sport Club organization
    INSERT INTO organizations (name, short_name, is_active)
    VALUES ('Phoenix Sport Club', 'Phoenix SC', true)
    ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO phoenix_org_id;

    -- Get or create Phoenix Sport Club club
    INSERT INTO clubs (organization_id, name, is_active)
    VALUES (phoenix_org_id, 'Phoenix Sport Club', true)
    ON CONFLICT (organization_id, name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO phoenix_club_id;

    -- Link Phoenix teams
    UPDATE teams SET club_id = phoenix_club_id
    WHERE name IN ('Phoenix SCM', 'Phoenix SCR') AND source_system_id = 2;
END $$;

-- Persepolis family
-- Merge Persepolis FC and Persepolis United FC II under single Persepolis club
DO $$
DECLARE
    persepolis_org_id INTEGER;
    persepolis_club_id INTEGER;
BEGIN
    -- Get or create Persepolis organization
    INSERT INTO organizations (name, short_name, is_active)
    VALUES ('Persepolis FC', 'Persepolis', true)
    ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO persepolis_org_id;

    -- Get or create Persepolis club
    INSERT INTO clubs (organization_id, name, is_active)
    VALUES (persepolis_org_id, 'Persepolis FC', true)
    ON CONFLICT (organization_id, name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO persepolis_club_id;

    -- Link Persepolis teams
    UPDATE teams SET club_id = persepolis_club_id
    WHERE name IN ('Persepolis FC', 'Persepolis United FC II') AND source_system_id = 2;
END $$;

-- Philadelphia SC family (II is reserves)
DO $$
DECLARE
    philly_sc_org_id INTEGER;
    philly_sc_club_id INTEGER;
BEGIN
    -- Get or create Philadelphia SC organization
    INSERT INTO organizations (name, short_name, is_active)
    VALUES ('Philadelphia SC', 'Philly SC', true)
    ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO philly_sc_org_id;

    -- Get or create Philadelphia SC club
    INSERT INTO clubs (organization_id, name, is_active)
    VALUES (philly_sc_org_id, 'Philadelphia SC', true)
    ON CONFLICT (organization_id, name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO philly_sc_club_id;

    -- Link Philadelphia SC II
    UPDATE teams SET club_id = philly_sc_club_id
    WHERE name = 'Philadelphia SC II' AND source_system_id = 2;
END $$;

-- Oaklyn United FC family (II is reserves)
DO $$
DECLARE
    oaklyn_org_id INTEGER;
    oaklyn_club_id INTEGER;
BEGIN
    -- Get or create Oaklyn United organization
    INSERT INTO organizations (name, short_name, is_active)
    VALUES ('Oaklyn United FC', 'Oaklyn United', true)
    ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO oaklyn_org_id;

    -- Get or create Oaklyn United club
    INSERT INTO clubs (organization_id, name, is_active)
    VALUES (oaklyn_org_id, 'Oaklyn United FC', true)
    ON CONFLICT (organization_id, name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO oaklyn_club_id;

    -- Link Oaklyn United FC II
    UPDATE teams SET club_id = oaklyn_club_id
    WHERE name = 'Oaklyn United FC II' AND source_system_id = 2;
END $$;

-- All other CASA teams remain as standalone clubs (created by 042b-teams-casa.sql):
-- Adé United FC, Alloy Soccer Club Reserves, BCFC All Stars, Club de Futbol Armada,
-- F&M FC, Flatley FC, Gambeta FC, Illyrians FC, Jaguars United FC, Lancaster City FC,
-- South Shore FC, Strictly Nos Fc
