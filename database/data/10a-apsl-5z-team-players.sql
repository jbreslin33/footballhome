-- APSL Team Rosters

INSERT INTO team_players (id, team_id, player_id, jersey_number, position)
VALUES
  (2, 1, 1, '8', NULL),
  (3, 1, 2, NULL, NULL),
  (4, 1, 3, NULL, NULL),
  (5, 1, 4, NULL, NULL),
  (6, 1, 5, NULL, NULL),
  (7, 1, 6, '1', NULL),
  (8, 1, 7, NULL, NULL),
  (9, 1, 8, NULL, NULL),
  (10, 1, 9, NULL, NULL),
  (11, 1, 10, NULL, NULL),
  (12, 1, 11, '2', NULL),
  (13, 1, 12, NULL, NULL),
  (14, 1, 13, NULL, NULL),
  (15, 1, 14, '2', NULL),
  (16, 1, 15, NULL, NULL),
  (17, 1, 16, NULL, NULL),
  (18, 1, 17, NULL, NULL),
  (19, 1, 18, NULL, NULL),
  (20, 1, 19, NULL, NULL),
  (21, 1, 20, '1', NULL),
  (22, 1, 21, NULL, NULL),
  (23, 1, 22, NULL, NULL),
  (24, 1, 23, '2', NULL),
  (25, 1, 24, NULL, NULL),
  (26, 1, 25, NULL, NULL),
  (27, 1, 26, NULL, NULL),
  (28, 1, 27, NULL, NULL),
  (29, 1, 28, NULL, NULL)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  player_id = EXCLUDED.player_id,
  jersey_number = EXCLUDED.jersey_number,
  position = EXCLUDED.position
;

