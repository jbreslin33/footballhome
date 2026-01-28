-- CSL Clubs and Team Associations
-- Fix orphan teams by creating clubs and associating teams with correct clubs
-- Pattern: Teams with "II", "III", "Old Boys" suffixes belong to same club
--
-- This file runs AFTER:
--   042-teams-complete.sql (creates teams from scraped data)
--   042a-clubs-from-teams.sql (creates clubs from team organizations)
--
-- Purpose: Associate teams that share a base name with the same club
-- Examples:
--   - Brooklyn City FC, Brooklyn City FC II, Brooklyn City FC III -> Brooklyn City FC club
--   - Central Park Rangers, CPR II, CPR Red, CPR United -> Central Park Rangers FC club
--   - Desportiva Sociedad variants -> Desportiva Sociedad club
--
-- NOTE: Clubs 200-209 and 22, 65 must exist before this runs (created by 042a-clubs-from-teams.sql)

-- Brooklyn City FC family
UPDATE teams SET club_id = 200 WHERE name IN ('Brooklyn City FC', 'Brooklyn City FC II', 'Brooklyn City FC III');

-- Manhattan FC family
UPDATE teams SET club_id = 201 WHERE name IN ('Manhattan FC', 'Manhattan FC II', 'Manhattan FC III');

-- Williamsburg International FC family
UPDATE teams SET club_id = 202 WHERE name IN ('Williamsburg International FC', 'Williamsburg International FC II', 'Williamsburg International FC III');

-- Barnstonworth Rovers FC family
UPDATE teams SET club_id = 203 WHERE name IN ('Barnstonworth Rovers FC', 'Barnstonworth Rovers FC Old Boys', 'Barnstonworth Rovers Old Boys');

-- Block FC family
UPDATE teams SET club_id = 204 WHERE name IN ('Block FC', 'Block FC II');

-- Borgetto FC family
UPDATE teams SET club_id = 205 WHERE name IN ('Borgetto FC', 'Borgetto FC II');

-- CD Iberia family
UPDATE teams SET club_id = 206 WHERE name IN ('CD Iberia', 'CD Iberia II');

-- Desportiva Sociedad family (multiple variants including City, Fury)
UPDATE teams SET club_id = 207 
WHERE name IN (
    'Desportiva Sociedad',
    'Desportiva Sociedad II',
    'Desportiva Sociedad City',
    'Desportiva Sociedad Fury'
);

-- Desportiva Sociedad NY family (separate club)
UPDATE teams SET club_id = 208 
WHERE name IN (
    'Desportiva Sociedad NY',
    'Desportiva Sociedad NY II'
);

-- ERFC family (includes Hudson location variant)
UPDATE teams SET club_id = 209 WHERE name IN ('ERFC', 'ERFC II', 'ERFC Hudson');

-- Central Park Rangers FC (massive club with many teams - club_id 22 already exists)
UPDATE teams SET club_id = 22 WHERE name ILIKE 'Central Park Rangers%';

-- Additional CSL team families (base team + variants should share club)
-- Pattern: Find base club_id from base team, apply to all variants

-- FC Japan family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'FC Japan') 
WHERE name IN ('FC Japan', 'FC Japan II');

-- FC Sandzak family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'FC Sandzak') 
WHERE name IN ('FC Sandzak', 'FC Sandzak II');

-- FC Ulqini family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'FC Ulqini') 
WHERE name IN ('FC Ulqini', 'FC Ulqini II');

-- Falco FC family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Falco FC') 
WHERE name IN ('Falco FC', 'Falco FC II');

-- Kaizen FC family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Kaizen FC') 
WHERE name IN ('Kaizen FC', 'Kaizen FC II');

-- Kelmendi FC NY family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Kelmendi FC NY') 
WHERE name IN ('Kelmendi FC NY', 'Kelmendi FC NY II');

-- Kickoff FC family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Kickoff FC') 
WHERE name IN ('Kickoff FC', 'Kickoff FC II');

-- Laberia FC family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Laberia FC') 
WHERE name IN ('Laberia FC', 'Laberia FC II');

-- Manhattan Kickers family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Manhattan Kickers') 
WHERE name IN ('Manhattan Kickers', 'Manhattan Kickers II');

-- Missile FC family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Missile FC') 
WHERE name IN ('Missile FC', 'Missile FC II');

-- NY Athletic Club family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'NY Athletic Club') 
WHERE name IN ('NY Athletic Club', 'NY Athletic Club II');

-- NY Finest FC family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'NY Finest FC') 
WHERE name IN ('NY Finest FC', 'NY Finest FC II');

-- NY Galicia family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'NY Galicia') 
WHERE name IN ('NY Galicia', 'NY Galicia II');

-- NY Shamrocks family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'NY Shamrocks') 
WHERE name IN ('NY Shamrocks', 'NY Shamrocks II');

-- NY Ukrainians family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'NY Ukrainians') 
WHERE name IN ('NY Ukrainians', 'NY Ukrainians II');

-- NYPD FC family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'NYPD FC') 
WHERE name IN ('NYPD FC', 'NYPD FC II');

-- Polonia SC family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Polonia SC') 
WHERE name IN ('Polonia SC', 'Polonia SC II');

-- Richmond County FC family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Richmond County FC') 
WHERE name IN ('Richmond County FC', 'Richmond County FC II');

-- SC Eintracht family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'SC Eintracht') 
WHERE name IN ('SC Eintracht', 'SC Eintracht II');

-- SC Gjoa Yellow Hook family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'SC Gjoa Yellow Hook') 
WHERE name IN ('SC Gjoa Yellow Hook', 'SC Gjoa Yellow Hook II');

-- Soricha Foot SC family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Soricha Foot SC') 
WHERE name IN ('Soricha Foot SC', 'Soricha Foot SC II');

-- South Bronx United family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'South Bronx United') 
WHERE name IN ('South Bronx United', 'South Bronx United II');

-- Sporting Astoria SC family (all variants including SBU, Dawgz, OG'S)
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Sporting Astoria SC') 
WHERE name IN (
    'Sporting Astoria SC',
    'Sporting Astoria SC II',
    'Sporting Astoria SC OG''S',
    'Sporting Astoria SBU Dawgz',
    'Sporting Astoria SBU OG''S',
    'Sporting Astoria Dawgz'
);

-- Sporting Astoria South Bronx United family (separate club from Sporting Astoria SC)
UPDATE teams SET club_id = 213
WHERE name IN (
    'Sporting Astoria South Bronx United',
    'Sporting Astoria South Bronx United II'
);

-- South Bronx United family
UPDATE teams SET club_id = 212
WHERE name IN (
    'South Bronx United',
    'South Bronx United II'
);

-- Manhattan Celtic family (including Masters, Bhoys)
UPDATE teams SET club_id = 66
WHERE name IN (
    'Manhattan Celtic',
    'Manhattan Celtic II',
    'Manhattan Celtic III',
    'Manhattan Celtic Masters',
    'Manhattan Celtic Bhoys'
);

-- Manhattan Kickers family (including Legends)
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Manhattan Kickers') 
WHERE name IN (
    'Manhattan Kickers',
    'Manhattan Kickers Legends'
);

-- Astoria Knights family
UPDATE teams SET club_id = 210
WHERE name IN (
    'Astoria Knights',
    'Astoria Knights II'
);

-- NY Irish SC family (including Legends)
UPDATE teams SET club_id = 211
WHERE name IN (
    'NY Irish SC',
    'NY Irish SC Legends'
);

-- NY Shamrocks family (including Legends)
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'NY Shamrocks') 
WHERE name IN (
    'NY Shamrocks',
    'NY Shamrocks Legends'
);

-- SC Eintracht family (including Legends)
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'SC Eintracht') 
WHERE name IN (
    'SC Eintracht',
    'SC Eintracht Legends'
);

-- NY Pancyprian Freedoms family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'NY Pancyprian Freedoms') 
WHERE name IN (
    'NY Pancyprian Freedoms',
    'NY Pancyprian Freedoms II'
);

-- Stal Mielec NY family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Stal Mielec NY') 
WHERE name IN ('Stal Mielec NY', 'Stal Mielec NY II');

-- Vibes FC family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Vibes FC') 
WHERE name IN ('Vibes FC', 'Vibes FC II');

-- Vllaznia NYC family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Vllaznia NYC') 
WHERE name IN ('Vllaznia NYC', 'Vllaznia NYC II');

-- Yemen United SC family
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Yemen United SC') 
WHERE name IN ('Yemen United SC', 'Yemen United SC II');

-- Doxa SC family (club_id 65 already exists)
UPDATE teams SET club_id = 65 WHERE name ILIKE 'Doxa SC%' OR name ILIKE 'Doxa FCW%';

-- Lansdowne Yonkers FC family (including Metro variant)
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Lansdowne Yonkers FC')
WHERE name IN (
    'Lansdowne Yonkers FC',
    'Lansdowne Yonkers FC Metro'
);

-- SC Gjoa family (including Over-40 and Yellow Hook variants)
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'SC Gjoa')
WHERE name ILIKE 'SC Gjoa%';

-- NY Eagles family (FC vs SC variants)
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'NY Eagles FC')
WHERE name IN (
    'NY Eagles FC',
    'NY Eagles SC'
);

-- VA Marauders FC family (including WL variant)
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'VA Marauders FC')
WHERE name IN (
    'VA Marauders FC',
    'VA Marauders FC WL'
);

-- Villanovence FC family (F.C. vs FC variants)
UPDATE teams SET club_id = (SELECT club_id FROM teams WHERE name = 'Villanovence FC')
WHERE name IN (
    'Villanovence FC',
    'Villanovence F.C.'
);

-- Verification query (comment out for production)
-- SELECT t.id, t.name, t.club_id, c.name AS club_name
-- FROM teams t
-- LEFT JOIN clubs c ON c.id = t.club_id
-- WHERE t.source_system_id = 3
-- ORDER BY c.name, t.name;
