-- ========================================
-- Fix Team Division Assignments
-- ========================================
-- Ensure all three Lighthouse teams are in the same division
-- Context: Boys Club and Old Timers were in their own divisions
-- This fix consolidates them into "Lighthouse 1893 SC Soccer" division

-- Update Boys Club team to Lighthouse 1893 SC Soccer division
UPDATE teams 
SET sport_division_id = 'd37eb44b-8e47-0004-9060-f0cbe96fe089'
WHERE id = '04b164cd-4e35-4302-84b0-60e2a5e71500'
  AND name = 'Lighthouse Boys Club';

-- Update Old Timers team to Lighthouse 1893 SC Soccer division
UPDATE teams 
SET sport_division_id = 'd37eb44b-8e47-0004-9060-f0cbe96fe089'
WHERE id = '449ef257-2d8f-43c0-8ae1-6374894d17f1'
  AND name = 'Lighthouse Old Timers';

-- Verify all three teams are now in same division
SELECT 
  t.name,
  sd.display_name as division_name,
  COUNT(tp.player_id) as player_count
FROM teams t
LEFT JOIN sport_divisions sd ON t.sport_division_id = sd.id
LEFT JOIN team_players tp ON t.id = tp.team_id
WHERE t.sport_division_id = 'd37eb44b-8e47-0004-9060-f0cbe96fe089'
GROUP BY t.id, t.name, sd.display_name
ORDER BY t.name;
