-- Team Coaches - CASA
-- Assign coaches to teams after teams are loaded

-- James Breslin (coach_id=1) as head coach of Lighthouse Boys Club teams
-- Using explicit team IDs (120, 121) to avoid matching duplicate team records
-- with the same name created across different CASA divisions.
INSERT INTO team_coaches (team_id, coach_id, coach_role_id)
VALUES (120, 1, 1), (121, 1, 1)
ON CONFLICT (team_id, coach_id) WHERE ended_at IS NULL DO NOTHING;
