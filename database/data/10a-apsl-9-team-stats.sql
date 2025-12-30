-- APSL Team Statistics

INSERT INTO team_stats (id, division_id, team_id, wins, losses, ties, goals_for, goals_against, points)
VALUES
  (1, 4, 1, 3, 6, 2, 16, 25, 11)
ON CONFLICT (id) DO UPDATE SET
  division_id = EXCLUDED.division_id,
  team_id = EXCLUDED.team_id,
  wins = EXCLUDED.wins,
  losses = EXCLUDED.losses,
  ties = EXCLUDED.ties,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  points = EXCLUDED.points
;

