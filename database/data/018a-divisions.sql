-- APSL Divisions

INSERT INTO divisions (id, league_id, conference_id, name, skill_level, skill_label, source_system_id, external_id, sort_order)
VALUES
  (1, 1, 1, 'Mayflower Conference', NULL, NULL, 1, 'apsl-conf-1', 1),
  (2, 1, 2, 'Constitution Conference', NULL, NULL, 1, 'apsl-conf-2', 2),
  (3, 1, 3, 'Metropolitan Conference', NULL, NULL, 1, 'apsl-conf-3', 3),
  (4, 1, 4, 'Delaware River Conference', NULL, NULL, 1, 'apsl-conf-4', 4),
  (5, 1, 5, 'Mid-Atlantic Conference', NULL, NULL, 1, 'apsl-conf-5', 5),
  (6, 1, 6, 'Terminus Conference', NULL, NULL, 1, 'apsl-conf-6', 6)
ON CONFLICT (id) DO UPDATE SET
  league_id = EXCLUDED.league_id,
  conference_id = EXCLUDED.conference_id,
  name = EXCLUDED.name,
  skill_level = EXCLUDED.skill_level,
  skill_label = EXCLUDED.skill_label,
  source_system_id = EXCLUDED.source_system_id,
  external_id = EXCLUDED.external_id,
  sort_order = EXCLUDED.sort_order
;

