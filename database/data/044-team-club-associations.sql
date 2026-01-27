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

-- Desportiva Sociedad family (multiple variants)
UPDATE teams SET club_id = 207 WHERE name IN ('Desportiva Sociedad', 'Desportiva Sociedad II', 'Desportiva Sociedad City', 'Desportiva Sociedad Fury');

-- Desportiva Sociedad NY family (separate club)
UPDATE teams SET club_id = 208 WHERE name IN ('Desportiva Sociedad NY', 'Desportiva Sociedad NY II');

-- ERFC family
UPDATE teams SET club_id = 209 WHERE name IN ('ERFC', 'ERFC II');

-- Central Park Rangers FC (massive club with many teams - club_id 22 already exists)
UPDATE teams SET club_id = 22 WHERE name ILIKE 'Central Park Rangers%';

-- Doxa SC family (club_id 65 already exists)
UPDATE teams SET club_id = 65 WHERE name ILIKE 'Doxa SC%' OR name ILIKE 'Doxa FCW%';

-- Verification query (comment out for production)
-- SELECT t.id, t.name, t.club_id, c.name AS club_name
-- FROM teams t
-- LEFT JOIN clubs c ON c.id = t.club_id
-- WHERE t.source_system_id = 3
-- ORDER BY c.name, t.name;
