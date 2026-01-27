-- ============================================================================
-- 030-clubs-from-teams.sql
-- Create clubs for team groups and associate teams with clubs
-- Fixes orphan teams and teams from same club not tied to same club
-- ============================================================================

-- First, create organizations for clubs that don't have them yet
-- (Some teams need parent organizations)

-- Brooklyn City FC
INSERT INTO organizations (id, name, short_name, is_active) VALUES
    (200, 'Brooklyn City FC', 'Brooklyn City', true)
ON CONFLICT (name) DO NOTHING;

-- Central Park Rangers FC (already exists as club 22, org 26)
-- Manhattan Celtic (already exists as club 66, org 75)
-- Manhattan FC
INSERT INTO organizations (id, name, short_name, is_active) VALUES
    (201, 'Manhattan FC', 'Manhattan', true)
ON CONFLICT (name) DO NOTHING;

-- NY International FC (already exists as club 20, org 24)
-- Williamsburg International FC
INSERT INTO organizations (id, name, short_name, is_active) VALUES
    (202, 'Williamsburg International FC', 'Williamsburg Intl', true)
ON CONFLICT (name) DO NOTHING;

-- Barnstonworth Rovers FC
INSERT INTO organizations (id, name, short_name, is_active) VALUES
    (203, 'Barnstonworth Rovers FC', 'Barnstonworth', true)
ON CONFLICT (name) DO NOTHING;

-- Block FC
INSERT INTO organizations (id, name, short_name, is_active) VALUES
    (204, 'Block FC', 'Block', true)
ON CONFLICT (name) DO NOTHING;

-- Borgetto FC
INSERT INTO organizations (id, name, short_name, is_active) VALUES
    (205, 'Borgetto FC', 'Borgetto', true)
ON CONFLICT (name) DO NOTHING;

-- CD Iberia
INSERT INTO organizations (id, name, short_name, is_active) VALUES
    (206, 'CD Iberia', 'Iberia', true)
ON CONFLICT (name) DO NOTHING;

-- Desportiva Sociedad
INSERT INTO organizations (id, name, short_name, is_active) VALUES
    (207, 'Desportiva Sociedad', 'Desportiva', true)
ON CONFLICT (name) DO NOTHING;

-- Desportiva Sociedad NY
INSERT INTO organizations (id, name, short_name, is_active) VALUES
    (208, 'Desportiva Sociedad NY', 'Desportiva NY', true)
ON CONFLICT (name) DO NOTHING;

-- ERFC
INSERT INTO organizations (id, name, short_name, is_active) VALUES
    (209, 'ERFC', 'ERFC', true)
ON CONFLICT (name) DO NOTHING;

-- Update sequence
SELECT setval('organizations_id_seq', (SELECT MAX(id) FROM organizations));

-- ============================================================================
-- Create clubs for organizations
-- ============================================================================

-- Brooklyn City FC
INSERT INTO clubs (id, organization_id, name, is_active) VALUES
    (200, 200, 'Brooklyn City FC', true)
ON CONFLICT (organization_id, name) DO NOTHING;

-- Manhattan FC
INSERT INTO clubs (id, organization_id, name, is_active) VALUES
    (201, 201, 'Manhattan FC', true)
ON CONFLICT (organization_id, name) DO NOTHING;

-- Williamsburg International FC
INSERT INTO clubs (id, organization_id, name, is_active) VALUES
    (202, 202, 'Williamsburg International FC', true)
ON CONFLICT (organization_id, name) DO NOTHING;

-- Barnstonworth Rovers FC
INSERT INTO clubs (id, organization_id, name, is_active) VALUES
    (203, 203, 'Barnstonworth Rovers FC', true)
ON CONFLICT (organization_id, name) DO NOTHING;

-- Block FC
INSERT INTO clubs (id, organization_id, name, is_active) VALUES
    (204, 204, 'Block FC', true)
ON CONFLICT (organization_id, name) DO NOTHING;

-- Borgetto FC
INSERT INTO clubs (id, organization_id, name, is_active) VALUES
    (205, 205, 'Borgetto FC', true)
ON CONFLICT (organization_id, name) DO NOTHING;

-- CD Iberia
INSERT INTO clubs (id, organization_id, name, is_active) VALUES
    (206, 206, 'CD Iberia', true)
ON CONFLICT (organization_id, name) DO NOTHING;

-- Desportiva Sociedad
INSERT INTO clubs (id, organization_id, name, is_active) VALUES
    (207, 207, 'Desportiva Sociedad', true)
ON CONFLICT (organization_id, name) DO NOTHING;

-- Desportiva Sociedad NY
INSERT INTO clubs (id, organization_id, name, is_active) VALUES
    (208, 208, 'Desportiva Sociedad NY', true)
ON CONFLICT (organization_id, name) DO NOTHING;

-- ERFC
INSERT INTO clubs (id, organization_id, name, is_active) VALUES
    (209, 209, 'ERFC', true)
ON CONFLICT (organization_id, name) DO NOTHING;

-- Update sequence
SELECT setval('clubs_id_seq', (SELECT MAX(id) FROM clubs));

-- ============================================================================
-- Associate teams with their clubs
-- ============================================================================

-- Brooklyn City FC (all variants)
UPDATE teams SET club_id = 200 WHERE name IN (
    'Brooklyn City FC',
    'Brooklyn City FC II',
    'Brooklyn City FC III'
);

-- Central Park Rangers FC (all variants) - club 22 already exists
UPDATE teams SET club_id = 22 WHERE name IN (
    'Central Park Rangers II',
    'Central Park Rangers III',
    'Central Park Rangers Old Boys',
    'Central Park Rangers Kickoff',
    'Central Park Rangers Kickoff II',
    'Central Park Rangers Lower East',
    'Central Park Rangers Lower East II',
    'Central Park Rangers Red',
    'Central Park Rangers Red II',
    'Central Park Rangers United',
    'Central Park Rangers United II'
);

-- Hoboken FC 1912 (all variants) - club 16 already exists
UPDATE teams SET club_id = 16 WHERE name IN (
    'Hoboken FC 1912',
    'Hoboken FC 1912 II',
    'Hoboken FC 1912 III'
);

-- KidSuper Samba AC (all variants) - club 67 already exists
UPDATE teams SET club_id = 67 WHERE name IN (
    'KidSuper Samba AC',
    'KidSuper Samba AC II',
    'KidSuper Samba AC III'
);

-- Manhattan Celtic (all variants) - club 66 already exists
UPDATE teams SET club_id = 66 WHERE name IN (
    'Manhattan Celtic',
    'Manhattan Celtic II',
    'Manhattan Celtic III'
);

-- Manhattan FC (all variants)
UPDATE teams SET club_id = 201 WHERE name IN (
    'Manhattan FC',
    'Manhattan FC II',
    'Manhattan FC III'
);

-- NY International FC (all variants) - club 20 already exists
UPDATE teams SET club_id = 20 WHERE name IN (
    'NY International FC',
    'NY International FC II',
    'NY International FC III'
);

-- Williamsburg International FC (all variants)
UPDATE teams SET club_id = 202 WHERE name IN (
    'Williamsburg International FC',
    'Williamsburg International FC II',
    'Williamsburg International FC III'
);

-- Zum Schneider FC 03 (all variants) - club 24 already exists
UPDATE teams SET club_id = 24 WHERE name IN (
    'Zum Schneider FC 03',
    'Zum Schneider FC 03 II',
    'Zum Schneider FC 03 III'
);

-- Barnstonworth Rovers FC (all variants)
UPDATE teams SET club_id = 203 WHERE name IN (
    'Barnstonworth Rovers FC',
    'Barnstonworth Rovers FC Old Boys',
    'Barnstonworth Rovers Old Boys'
);

-- Block FC (all variants)
UPDATE teams SET club_id = 204 WHERE name IN (
    'Block FC',
    'Block FC II'
);

-- Borgetto FC (all variants)
UPDATE teams SET club_id = 205 WHERE name IN (
    'Borgetto FC',
    'Borgetto FC II'
);

-- CD Iberia (all variants)
UPDATE teams SET club_id = 206 WHERE name IN (
    'CD Iberia',
    'CD Iberia II'
);

-- Desportiva Sociedad (all variants)
UPDATE teams SET club_id = 207 WHERE name IN (
    'Desportiva Sociedad',
    'Desportiva Sociedad II'
);

-- Desportiva Sociedad NY (all variants)
UPDATE teams SET club_id = 208 WHERE name IN (
    'Desportiva Sociedad NY',
    'Desportiva Sociedad NY II'
);

-- ERFC (all variants)
UPDATE teams SET club_id = 209 WHERE name IN (
    'ERFC',
    'ERFC II'
);

-- Report results
DO $$
DECLARE
    orphan_count INTEGER;
    total_teams INTEGER;
BEGIN
    SELECT COUNT(*) INTO orphan_count FROM teams WHERE club_id IS NULL;
    SELECT COUNT(*) INTO total_teams FROM teams;
    
    RAISE NOTICE 'Team-Club Association Complete:';
    RAISE NOTICE '  Total teams: %', total_teams;
    RAISE NOTICE '  Teams without clubs: %', orphan_count;
    RAISE NOTICE '  Teams with clubs: %', (total_teams - orphan_count);
END $$;
