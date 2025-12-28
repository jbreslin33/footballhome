-- CASA Divisions

INSERT INTO casa_divisions (id, casa_conference_id, name, age_group, skill_level, gender, sort_order)
VALUES
  (1, 1, 'Liga 1', NULL, 'Tier 1', NULL, 1),
  (2, 1, 'Liga 2', NULL, 'Tier 2', NULL, 2)
ON CONFLICT (id) DO UPDATE SET
  casa_conference_id = EXCLUDED.casa_conference_id,
  name = EXCLUDED.name,
  age_group = EXCLUDED.age_group,
  skill_level = EXCLUDED.skill_level,
  gender = EXCLUDED.gender,
  sort_order = EXCLUDED.sort_order
;

