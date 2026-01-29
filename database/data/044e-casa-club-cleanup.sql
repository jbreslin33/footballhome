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

-- Lighthouse teams -> Lighthouse 1893 SC (existing club 35, org 39)
-- Remove duplicate clubs created by 042b-teams-casa.sql
UPDATE teams SET club_id = 35
WHERE name IN ('Lighthouse Boys Club', 'Lighthouse Old Timers Club') AND source_system_id = 2;

-- Delete duplicate CASA-created clubs for Lighthouse teams
DELETE FROM clubs WHERE id IN (110, 111) AND organization_id IN (198, 199);
DELETE FROM organizations WHERE id IN (198, 199) AND name IN ('Lighthouse Boys Club', 'Lighthouse Old Timers Club');

-- Phoenix Sport Club family
-- Use Phoenix SCM club (116) as parent, merge Phoenix SCR under it
UPDATE clubs SET name = 'Phoenix Sport Club' WHERE id = 116;
UPDATE organizations SET name = 'Phoenix Sport Club', short_name = 'Phoenix SC' WHERE id = 204;

-- Merge Phoenix SCR team under Phoenix SCM club
UPDATE teams SET club_id = 116 WHERE name = 'Phoenix SCR' AND source_system_id = 2;

-- Delete duplicate Phoenix SCR club and org
DELETE FROM clubs WHERE id = 117;
DELETE FROM organizations WHERE id = 205;

-- Persepolis family
-- Use Persepolis FC club (113) as parent, merge Persepolis United FC II under it
-- Clubs already have correct names, just merge the teams

UPDATE teams SET club_id = 113 WHERE name = 'Persepolis United FC II' AND source_system_id = 2;

-- Delete duplicate Persepolis United FC II club and org
DELETE FROM clubs WHERE id = 114;
DELETE FROM organizations WHERE id = 202;

-- Philadelphia SC family (merge II team under existing Philadelphia Soccer Club 32)
-- Club 32 is the actual Philadelphia SC from APSL
UPDATE teams SET club_id = 32 WHERE name = 'Philadelphia SC II' AND source_system_id = 2;

-- Delete duplicate Philadelphia SC II club and org
DELETE FROM clubs WHERE id = 115;
DELETE FROM organizations WHERE id = 203;

-- Oaklyn United FC family (merge II team under existing Oaklyn United FC club 28)
-- Club 28 already exists from APSL, merge CASA II team under it
UPDATE teams SET club_id = 28 WHERE name = 'Oaklyn United FC II' AND source_system_id = 2;

-- Delete duplicate Oaklyn United FC II club and org
DELETE FROM clubs WHERE id = 112;
DELETE FROM organizations WHERE id = 200;

-- All other CASA teams remain as standalone clubs (created by 042b-teams-casa.sql):
-- Adé United FC, Alloy Soccer Club Reserves, BCFC All Stars, Club de Futbol Armada,
-- F&M FC, Flatley FC, Gambeta FC, Illyrians FC, Jaguars United FC, Lancaster City FC,
-- South Shore FC, Strictly Nos Fc
