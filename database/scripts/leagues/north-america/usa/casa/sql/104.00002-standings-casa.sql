-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Standings - CASA
-- Current season standings data
-- Total Records: 11
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO standings (team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT t.id, 0, 6, 2, 13, 0, 15, 13, 59, -46, '2026-04-29T17:33:24.546Z', 'CASA Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Lighthouse Boys Club U23'
  AND d.name = 'Philadelphia Liga 2'
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
SELECT t.id, 0, 15, 5, 9, 0, 14, 19, 38, -19, '2026-04-29T17:33:24.546Z', 'CASA Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Phoenix SCR'
  AND d.name = 'Philadelphia Liga 2'
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
SELECT t.id, 0, 15, 4, 7, 3, 14, 25, 25, 0, '2026-04-29T17:33:24.546Z', 'CASA Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Philadelphia SC Select'
  AND d.name = 'Philadelphia Liga 2'
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
SELECT t.id, 0, 17, 5, 4, 2, 11, 24, 13, 11, '2026-04-29T17:33:24.546Z', 'CASA Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Persepolis FC II'
  AND d.name = 'Philadelphia Liga 2'
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
SELECT t.id, 0, 16, 5, 2, 1, 8, 17, 15, 2, '2026-04-29T17:33:24.546Z', 'CASA Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Sewell''s Old Boys'
  AND d.name = 'Philadelphia Liga 2'
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
