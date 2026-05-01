-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Standings - CASA
-- Current season standings data
-- Total Records: 15
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO standings (team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT t.id, 0, 28, 9, 8, 1, 18, 39, 37, 2, '2026-05-01T01:34:19.917Z', 'CASA Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Lighthouse Boys Club'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  position = EXCLUDED.position,
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = EXCLUDED.fetched_at;
INSERT INTO standings (team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT t.id, 0, 38, 12, 4, 2, 18, 49, 23, 26, '2026-05-01T01:34:19.917Z', 'CASA Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Oaklyn United FC II'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  position = EXCLUDED.position,
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = EXCLUDED.fetched_at;
INSERT INTO standings (team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT t.id, 0, 21, 7, 11, 0, 18, 46, 62, -16, '2026-05-01T01:34:19.917Z', 'CASA Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Illyrians FC'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  position = EXCLUDED.position,
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = EXCLUDED.fetched_at;
INSERT INTO standings (team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT t.id, 0, 38, 12, 4, 2, 18, 55, 31, 24, '2026-05-01T01:34:19.917Z', 'CASA Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Adé United FC'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  position = EXCLUDED.position,
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = EXCLUDED.fetched_at;
INSERT INTO standings (team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT t.id, 0, 33, 10, 5, 3, 18, 35, 23, 12, '2026-05-01T01:34:19.917Z', 'CASA Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Philadelphia Sierra Stars'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  position = EXCLUDED.position,
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = EXCLUDED.fetched_at;
INSERT INTO standings (team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT t.id, 0, 37, 11, 3, 4, 18, 62, 19, 43, '2026-05-01T01:34:19.917Z', 'CASA Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Persepolis FC'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  position = EXCLUDED.position,
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = EXCLUDED.fetched_at;
INSERT INTO standings (team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT t.id, 0, 16, 5, 12, 1, 18, 25, 59, -34, '2026-05-01T01:34:19.917Z', 'CASA Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Philly BlackStars'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  position = EXCLUDED.position,
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = EXCLUDED.fetched_at;
INSERT INTO standings (team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT t.id, 0, 19, 6, 11, 1, 18, 33, 38, -5, '2026-05-01T01:34:19.917Z', 'CASA Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Phoenix SCM'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  position = EXCLUDED.position,
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = EXCLUDED.fetched_at;
