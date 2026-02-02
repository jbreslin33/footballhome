-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Standings - APSL
-- Current season standings data
-- Total Records: 59
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 100, 1, 8, 5, 1, 2, 20, 8, 12, 16, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 101, 2, 6, 4, 2, 0, 22, 4, 18, 14, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 102, 3, 6, 4, 2, 0, 18, 4, 14, 14, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 103, 4, 6, 2, 1, 3, 17, 13, 4, 7, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 104, 5, 6, 2, 0, 4, 9, 23, -14, 6, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 105, 6, 7, 1, 2, 4, 13, 18, -5, 5, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 106, 7, 7, 1, 0, 6, 7, 36, -29, 3, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 107, 8, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 108, 1, 5, 5, 0, 0, 30, 10, 20, 15, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Constitution Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 109, 2, 6, 4, 0, 2, 21, 20, 1, 12, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Constitution Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 110, 3, 6, 1, 1, 4, 10, 24, -14, 4, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Constitution Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 111, 4, 5, 0, 1, 4, 8, 15, -7, 1, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Constitution Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 112, 5, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Constitution Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 113, 1, 11, 10, 1, 0, 37, 11, 26, 31, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 114, 2, 11, 7, 2, 2, 29, 10, 19, 23, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 115, 3, 10, 7, 1, 2, 34, 13, 21, 22, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 116, 4, 10, 7, 0, 3, 26, 13, 13, 21, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 117, 5, 11, 5, 3, 3, 23, 19, 4, 18, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 118, 6, 11, 5, 2, 4, 26, 23, 3, 17, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 119, 7, 11, 4, 1, 6, 18, 28, -10, 13, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 120, 8, 11, 3, 3, 5, 20, 36, -16, 12, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 121, 9, 11, 2, 2, 7, 17, 31, -14, 8, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 122, 10, 11, 2, 1, 8, 16, 33, -17, 7, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 123, 11, 11, 3, 0, 8, 11, 31, -20, 6, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 124, 12, 11, 2, 0, 9, 17, 26, -9, 6, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 125, 1, 11, 11, 0, 0, 65, 9, 56, 33, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 126, 2, 11, 7, 2, 2, 39, 21, 18, 23, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 127, 3, 10, 6, 0, 4, 18, 22, -4, 18, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 128, 4, 11, 6, 0, 5, 18, 17, 1, 18, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 129, 5, 11, 5, 2, 4, 22, 19, 3, 17, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 130, 6, 11, 5, 1, 5, 31, 23, 8, 16, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 131, 7, 9, 4, 3, 2, 20, 23, -3, 15, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 132, 8, 11, 4, 1, 6, 18, 23, -5, 13, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 133, 9, 10, 4, 0, 6, 17, 40, -23, 12, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 134, 10, 11, 3, 2, 6, 16, 25, -9, 11, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 135, 11, 11, 1, 2, 8, 11, 31, -20, 5, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 136, 12, 11, 1, 1, 9, 15, 37, -22, 4, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 137, 1, 7, 7, 0, 0, 34, 10, 24, 21, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 138, 2, 9, 6, 0, 3, 20, 13, 7, 18, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 139, 3, 7, 5, 0, 2, 25, 7, 18, 15, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 140, 4, 6, 3, 0, 3, 20, 20, 0, 9, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 141, 5, 8, 3, 0, 5, 17, 18, -1, 9, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 142, 6, 5, 2, 0, 3, 6, 10, -4, 6, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 143, 7, 8, 2, 0, 6, 13, 31, -18, 6, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 144, 8, 8, 1, 0, 7, 7, 33, -26, 3, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 145, 9, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Mid-Atlantic Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 146, 1, 8, 7, 1, 0, 36, 14, 22, 22, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 147, 2, 8, 6, 1, 1, 38, 10, 28, 19, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 148, 3, 8, 5, 2, 1, 41, 14, 27, 17, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 149, 4, 8, 4, 1, 3, 32, 18, 14, 13, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 150, 5, 7, 2, 1, 4, 16, 16, 0, 7, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 151, 6, 7, 2, 0, 5, 19, 15, 4, 6, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 152, 7, 7, 2, 0, 5, 19, 31, -12, 6, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 153, 8, 1, 0, 0, 1, 1, 4, -3, 0, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 154, 9, 8, 0, 0, 8, 2, 82, -80, 0, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 155, 1, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Trinity Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 156, 2, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Trinity Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 157, 3, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Trinity Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 158, 4, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-01T23:50:47.227Z', 'APSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Trinity Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
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
