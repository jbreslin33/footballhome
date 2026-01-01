-- CASA Team Divisions

INSERT INTO team_divisions (id, team_id, division_id, season_id, is_active)
VALUES
  (1, 1, 1, NULL, true),
  (2, 2, 1, NULL, true),
  (3, 3, 1, NULL, true),
  (4, 4, 1, NULL, true),
  (5, 5, 1, NULL, true),
  (6, 6, 1, NULL, true),
  (7, 7, 1, NULL, true),
  (8, 8, 1, NULL, true),
  (9, 12, 2, NULL, true),
  (10, 13, 2, NULL, true),
  (11, 11, 2, NULL, true),
  (12, 10, 2, NULL, true),
  (13, 14, 2, NULL, true)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  division_id = EXCLUDED.division_id,
  season_id = EXCLUDED.season_id,
  is_active = EXCLUDED.is_active
;

