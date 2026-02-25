-- Coaches - Foundation Data
-- Bootstrap coach records for known users
-- NOTE: team_coaches assignments go in league load scripts (teams don't exist at bootstrap time)

-- James Breslin as coach (person_id=1)
INSERT INTO coaches (id, person_id)
VALUES (1, 1)
ON CONFLICT (person_id) DO NOTHING;
