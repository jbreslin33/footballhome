-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Standings - CASA
-- Total Records: 25
-- Last updated: 2026-02-27T15:09:24.715Z
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 25, 8, 1, 1,
  10, 34, 12, 22,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Adé United FC'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 21, 7, 2, 0,
  9, 22, 12, 10,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Oaklyn United FC II'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 20, 6, 1, 2,
  9, 20, 11, 9,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Philadelphia Sierra Stars'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 16, 5, 0, 1,
  6, 24, 2, 22,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Persepolis FC'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 10, 3, 6, 1,
  10, 16, 21, -5,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Phoenix SCM'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 10, 3, 6, 1,
  10, 14, 29, -15,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Philly BlackStars'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 9, 3, 7, 0,
  10, 26, 35, -9,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Illyrians FC'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 6, 2, 7, 0,
  9, 17, 27, -10,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Lighthouse Boys Club'
  AND d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 9, 3, 0, 0,
  3, 19, 0, 19,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Persepolis United FC II'
  AND d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 9, 3, 5, 0,
  8, 11, 23, -12,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Phoenix SCR'
  AND d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 8, 2, 4, 2,
  8, 13, 16, -3,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Philadelphia SC Select'
  AND d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 3, 1, 7, 0,
  8, 4, 32, -28,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Lighthouse Old Timers Club'
  AND d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 0, 0, 0, 0,
  0, 0, 0, 0,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Club de Futbol Armada'
  AND d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 0, 0, 0, 0,
  0, 0, 0, 0,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Sewell''s Old Boys'
  AND d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 21, 7, 0, 0,
  7, 32, 10, 19,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'South Shore FC'
  AND d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 19, 6, 1, 1,
  8, 40, 10, 23,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Jaguars United FC'
  AND d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 11, 3, 2, 2,
  7, 21, 9, 10,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Strictly Nos Fc'
  AND d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 10, 3, 4, 1,
  8, 24, 22, 2,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'BCFC All Stars'
  AND d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 6, 2, 6, 0,
  8, 19, 43, -20,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Flatley FC'
  AND d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 0, 0, 8, 0,
  8, 15, 57, -34,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Gambeta FC'
  AND d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 17, 5, 1, 2,
  8, 16, 9, 7,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Kutztown Men''s Soccer'
  AND d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 16, 5, 2, 1,
  8, 15, 6, 8,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Alloy Soccer Club Reserves'
  AND d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 9, 3, 5, 0,
  8, 17, 17, 0,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Keystone Elite'
  AND d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 8, 2, 4, 2,
  8, 9, 20, -10,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'F&M FC'
  AND d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, 7, 2, 5, 1,
  8, 14, 19, -5,
  'CASA Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Lancaster City FC'
  AND d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;

