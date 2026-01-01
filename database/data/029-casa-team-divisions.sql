-- CASA Team Divisions

INSERT INTO team_divisions (id, team_id, division_id, season_id, is_active)
VALUES
  (1, 1, 2, NULL, true),
  (2, 2, 2, NULL, true),
  (3, 3, 2, NULL, true),
  (4, 4, 2, NULL, true),
  (5, 5, 2, NULL, true)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  division_id = EXCLUDED.division_id,
  season_id = EXCLUDED.season_id,
  is_active = EXCLUDED.is_active
;

