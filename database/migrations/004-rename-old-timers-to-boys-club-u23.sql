-- Migration 004: Rename "Lighthouse Old Timers Club" to "Lighthouse Boys Club U23"
-- The website (casasoccerleagues.com) renamed this team for the 2025/2026 season.

BEGIN;

-- Rename the team
UPDATE teams
SET name = 'Lighthouse Boys Club U23'
WHERE name = 'Lighthouse Old Timers Club'
  AND source_system_id = 2;

-- Rename the GroupMe chat reference
UPDATE chats
SET name = 'Lighthouse Boys Club U23'
WHERE name = 'Lighthouse Old Timers Club';

-- Update the external_id for the team (used by scrapers)
UPDATE teams
SET external_id = REPLACE(external_id, 'lighthouse-old-timers-club', 'lighthouse-boys-club-u23')
WHERE external_id LIKE '%lighthouse-old-timers-club%'
  AND source_system_id = 2;

COMMIT;
