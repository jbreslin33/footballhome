-- Club-admins - Foundation Data
-- This file contains core/foundational data for club-admins that always loads.
-- Tables 001-012 (lookup tables) have data inline in schema, this file is optional.

-- Assign James Breslin to Lighthouse 1893 SC club
-- Note: Requires club_id 1 to exist in clubs table (should be loaded from scraped data)
INSERT INTO club_admins (club_id, admin_id, admin_role, is_primary, is_active)
SELECT 
    c.id,
    1,  -- James Breslin's admin_id
    'Owner',
    true,
    true
FROM clubs c
WHERE c.slug = 'lighthouse-1893-sc'
ON CONFLICT DO NOTHING;
