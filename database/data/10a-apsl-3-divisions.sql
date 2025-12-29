-- APSL Divisions

INSERT INTO apsl_divisions (id, apsl_conference_id, name, age_group, skill_level, gender, sort_order)
VALUES
  (1, 1, 'Mayflower Conference', NULL, NULL, NULL, 1),
  (2, 2, 'Constitution Conference', NULL, NULL, NULL, 2),
  (3, 3, 'Metropolitan Conference', NULL, NULL, NULL, 3),
  (4, 4, 'Delaware River Conference', NULL, NULL, NULL, 4),
  (5, 5, 'Mid-Atlantic Conference', NULL, NULL, NULL, 5),
  (6, 6, 'Terminus Conference', NULL, NULL, NULL, 6)
ON CONFLICT (id) DO UPDATE SET
  apsl_conference_id = EXCLUDED.apsl_conference_id,
  name = EXCLUDED.name,
  age_group = EXCLUDED.age_group,
  skill_level = EXCLUDED.skill_level,
  gender = EXCLUDED.gender,
  sort_order = EXCLUDED.sort_order
;

