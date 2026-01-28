-- Cleanup orphan clubs (clubs with no teams)
-- This runs AFTER:
--   044-team-club-associations.sql (assigns teams to correct clubs)
--   044a-standalone-team-clubs.sql (creates clubs for remaining standalone teams)
--
-- Purpose: Remove duplicate/orphan clubs that were created before teams were properly associated
-- Example: "Central Park Rangers 1999" club gets created by 044a, but then the team gets 
--          assigned to "Central Park Rangers FC" club by 044. The orphan club remains.

-- Delete all clubs that have zero teams
DELETE FROM clubs
WHERE id IN (
    SELECT c.id 
    FROM clubs c
    LEFT JOIN teams t ON t.club_id = c.id
    GROUP BY c.id
    HAVING COUNT(t.id) = 0
);

-- Show remaining orphan clubs (if any - should be 0)
-- SELECT c.id, c.name, c.organization_id, COUNT(t.id) as team_count
-- FROM clubs c
-- LEFT JOIN teams t ON t.club_id = c.id
-- GROUP BY c.id
-- HAVING COUNT(t.id) = 0
-- ORDER BY c.name;
