-- Team Coaches - CASA
-- Assign coaches to teams after teams are loaded

-- James Breslin (coach_id=1) as head coach of Lighthouse Boys Club teams
INSERT INTO team_coaches (team_id, coach_id, coach_role_id)
SELECT t.id, 1, 1
FROM teams t
WHERE t.name IN ('Lighthouse Boys Club', 'Lighthouse Boys Club U23')
ON CONFLICT DO NOTHING;
