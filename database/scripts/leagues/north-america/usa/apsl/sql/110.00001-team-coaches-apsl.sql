-- Team Coaches - APSL
-- Assign coaches to teams after teams are loaded

-- James Breslin (coach_id=1) as head coach of Lighthouse 1893 SC
INSERT INTO team_coaches (team_id, coach_id, coach_role_id)
SELECT t.id, 1, 1
FROM teams t
WHERE t.name = 'Lighthouse 1893 SC'
ON CONFLICT DO NOTHING;
