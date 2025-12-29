-- APSL Conferences

INSERT INTO apsl_conferences (id, apsl_league_id, name, abbreviation, sort_order)
VALUES
  (1, 1, 'Mayflower Conference', NULL, 1),
  (2, 1, 'Constitution Conference', NULL, 2),
  (3, 1, 'Metropolitan Conference', NULL, 3),
  (4, 1, 'Delaware River Conference', NULL, 4),
  (5, 1, 'Mid-Atlantic Conference', NULL, 5),
  (6, 1, 'Terminus Conference', NULL, 6)
ON CONFLICT (id) DO UPDATE SET
  apsl_league_id = EXCLUDED.apsl_league_id,
  name = EXCLUDED.name,
  abbreviation = EXCLUDED.abbreviation,
  sort_order = EXCLUDED.sort_order
;

