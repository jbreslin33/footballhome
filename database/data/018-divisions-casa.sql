-- CASA Divisions

INSERT INTO divisions (id, league_id, conference_id, name, skill_level, skill_label, source_system_id, external_id, sort_order)
VALUES
  (1, 1, 1, 'Liga 1', 1, 'Tier 1', 2, 'casa-div-liga1', 1),
  (2, 1, 1, 'Liga 2', 2, 'Tier 2', 2, 'casa-div-liga2', 2)
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

