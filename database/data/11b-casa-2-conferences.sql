-- CASA Conferences

INSERT INTO casa_conferences (id, casa_league_id, name, abbreviation, sort_order)
VALUES
  (1, 1, 'Philadelphia', 'Philadelph', 1),
  (2, 1, 'Boston', 'Boston', 2),
  (3, 1, 'Lancaster', 'Lancaster', 3),
  (4, 1, 'Central NJ', 'Central NJ', 4)
ON CONFLICT (id) DO UPDATE SET
  casa_league_id = EXCLUDED.casa_league_id,
  name = EXCLUDED.name,
  abbreviation = EXCLUDED.abbreviation,
  sort_order = EXCLUDED.sort_order
;

