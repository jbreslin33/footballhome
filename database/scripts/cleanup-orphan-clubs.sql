-- Cleanup Orphan Clubs Script
-- 
-- Problem: Files 043-clubs-from-teams.sql and 044a-standalone-team-clubs.sql
-- created clubs from every CSL team name including variants (II, III, Legends, etc.)
-- when they should only create clubs for base teams.
-- 
-- This script:
-- 1. Reports clubs with 0 teams (orphan clubs)
-- 2. Deletes them (safe since they have no teams/foreign keys)
-- 
-- Usage:
--   podman exec footballhome_db psql -U footballhome_user -d footballhome -f database/scripts/cleanup-orphan-clubs.sql

-- First, show what will be deleted
\echo '=== ORPHAN CLUBS (0 teams) ==='
\echo ''

SELECT 
  c.id,
  c.name as club_name,
  o.name as organization_name,
  COUNT(t.id) as team_count
FROM clubs c
LEFT JOIN teams t ON t.club_id = c.id
LEFT JOIN organizations o ON o.id = c.organization_id
GROUP BY c.id, c.name, o.name
HAVING COUNT(t.id) = 0
ORDER BY c.name;

\echo ''
\echo '=== DELETING ORPHAN CLUBS ==='
\echo ''

-- Delete orphan clubs
WITH orphan_clubs AS (
  SELECT c.id, c.name
  FROM clubs c
  LEFT JOIN teams t ON t.club_id = c.id
  GROUP BY c.id, c.name
  HAVING COUNT(t.id) = 0
),
deleted AS (
  DELETE FROM clubs 
  WHERE id IN (SELECT id FROM orphan_clubs)
  RETURNING id, name
)
SELECT 
  COUNT(*) as deleted_count,
  STRING_AGG(name, ', ' ORDER BY name) as deleted_clubs
FROM deleted;

\echo ''
\echo '=== VERIFICATION: Remaining orphan clubs ==='
\echo ''

SELECT 
  COUNT(*) as remaining_orphan_clubs
FROM clubs c
LEFT JOIN teams t ON t.club_id = c.id
GROUP BY c.id
HAVING COUNT(t.id) = 0;

\echo ''
\echo '=== SUMMARY: Clubs and Teams ==='
\echo ''

SELECT 
  COUNT(DISTINCT c.id) as total_clubs,
  COUNT(DISTINCT t.id) as total_teams,
  COUNT(DISTINCT CASE WHEN t.id IS NOT NULL THEN c.id END) as clubs_with_teams,
  COUNT(DISTINCT CASE WHEN t.id IS NULL THEN c.id END) as clubs_without_teams
FROM clubs c
LEFT JOIN teams t ON t.club_id = c.id;
