-- CASA Conferences

INSERT INTO conferences (id, league_id, name, abbreviation, source_system_id, external_id, sort_order)
VALUES
  (1, 1, 'Philadelphia', 'Philadelph', 2, 'casa-conf-philadelphia', 1)
ON CONFLICT (id) DO UPDATE SET
  league_id = EXCLUDED.league_id,
  name = EXCLUDED.name,
  abbreviation = EXCLUDED.abbreviation,
  source_system_id = EXCLUDED.source_system_id,
  external_id = EXCLUDED.external_id,
  sort_order = EXCLUDED.sort_order
;

