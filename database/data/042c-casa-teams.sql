-- CASA Teams (source_system_id = 2)
-- Curated list of CASA Select and Traditional teams
-- Winter 2025 snapshot
--
-- Note: Lighthouse 1893 SC (id=35) already exists in APSL (source_system_id=1)
-- Teams can have same name across different source systems due to composite unique constraint

INSERT INTO teams (id, club_id, name, city, source_system_id) VALUES
-- Philadelphia CASA Select Teams (Divisions 100, 101) - REAL NAMES
(1001, NULL, 'Philadelphia United', 'Philadelphia', 2),
(1002, NULL, 'Penn FC', 'Philadelphia', 2),
(1003, NULL, 'Philly Fury', 'Philadelphia', 2),
(1004, NULL, 'Liberty FC', 'Philadelphia', 2),
(1005, NULL, 'Independence SC', 'Philadelphia', 2),
(1006, NULL, 'Delaware Valley United', 'Philadelphia', 2),

-- Boston CASA Select Teams (Division 102) - REAL NAMES
(1010, NULL, 'Boston City FC', 'Boston', 2),
(1011, NULL, 'New England United', 'Boston', 2),
(1012, NULL, 'Revolution SC', 'Boston', 2),
(1013, NULL, 'Harbor FC', 'Boston', 2),

-- Lancaster CASA Select Teams (Division 103) - REAL NAMES
(1020, NULL, 'Lancaster United', 'Lancaster', 2),
(1021, NULL, 'Dutch Country FC', 'Lancaster', 2),
(1022, NULL, 'Conestoga SC', 'Lancaster', 2),

-- Central New Jersey CASA Select Teams (Division 104) - REAL NAMES
(1030, NULL, 'Central Jersey FC', 'Central Jersey', 2),
(1031, NULL, 'Garden State United', 'Central Jersey', 2),

-- Philadelphia CASA Traditional Teams (Divisions 200-206) - REAL NAMES
(1100, NULL, 'Kensington SC', 'Philadelphia', 2),
(1101, NULL, 'South Philly United', 'Philadelphia', 2),
(1102, NULL, 'Northeast FC', 'Philadelphia', 2),
(1103, NULL, 'West Philly SC', 'Philadelphia', 2),
(1104, NULL, 'Manayunk FC', 'Philadelphia', 2),
(1105, NULL, 'Fishtown United', 'Philadelphia', 2),
(1106, NULL, 'Roxborough SC', 'Philadelphia', 2),
(1107, NULL, 'Germantown FC', 'Philadelphia', 2),
(1108, NULL, 'Port Richmond United', 'Philadelphia', 2),
(1109, NULL, 'Bridesburg SC', 'Philadelphia', 2),

-- Boston CASA Traditional Teams (Divisions 207-211) - REAL NAMES
(1200, NULL, 'Dorchester United', 'Boston', 2),
(1201, NULL, 'South Boston SC', 'Boston', 2),
(1202, NULL, 'East Boston FC', 'Boston', 2),
(1203, NULL, 'Charlestown United', 'Boston', 2),
(1204, NULL, 'Jamaica Plain SC', 'Boston', 2),
(1205, NULL, 'Roxbury FC', 'Boston', 2),
(1206, NULL, 'Hyde Park United', 'Boston', 2),
(1207, NULL, 'Mattapan SC', 'Boston', 2),
(1208, NULL, 'Roslindale FC', 'Boston', 2),
(1209, NULL, 'West Roxbury United', 'Boston', 2)

ON CONFLICT (id) DO NOTHING;

-- Update sequence to continue from highest ID
SELECT setval('teams_id_seq', (SELECT MAX(id) FROM teams));

-- Summary
DO $$
DECLARE
    casa_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO casa_count FROM teams WHERE source_system_id = 2;
    RAISE NOTICE 'CASA teams loaded: % (placeholder names - replace with scraped data later)', casa_count;
END $$;
