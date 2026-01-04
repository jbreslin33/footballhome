-- Post-Load Processing
-- This script runs after all scraped data is loaded
-- Handles: coach assignments and other post-scrape setup

-- ============================================================================
-- SECTION 1: Assign Coaches to Division Rosters
-- ============================================================================

-- Assign James Breslin as head coach to all Lighthouse division rosters
INSERT INTO division_roster_coaches (division_roster_id, coach_id, coach_role_id, is_active)
SELECT 
    dr.id,
    1,  -- coach_id=1 (James Breslin from coaches table)
    1,  -- coach_role_id=1 (head_coach from coach_roles lookup)
    true
FROM division_rosters dr
JOIN teams t ON dr.team_id = t.id
JOIN clubs c ON t.club_id = c.id
JOIN organizations o ON c.organization_id = o.id
WHERE o.id = 1  -- Lighthouse 1893 organization
ON CONFLICT (division_roster_id, coach_id) DO NOTHING;

-- End of post-load processing
