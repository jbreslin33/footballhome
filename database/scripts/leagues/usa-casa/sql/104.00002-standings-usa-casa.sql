-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Standings - CASA
-- Current season standings data
-- Total Records: 22
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 20000, 0, 25, 8, 1, 1, 10, 34, 12, 22, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20001, 0, 21, 7, 2, 0, 9, 22, 12, 10, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20002, 0, 20, 6, 1, 2, 9, 20, 11, 9, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20003, 0, 16, 5, 0, 1, 6, 24, 2, 22, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20004, 0, 10, 3, 6, 1, 10, 16, 21, -5, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20005, 0, 10, 3, 6, 1, 10, 14, 29, -15, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20006, 0, 9, 3, 7, 0, 10, 26, 35, -9, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20007, 0, 6, 2, 7, 0, 9, 17, 27, -10, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20008, 0, 9, 3, 0, 0, 3, 19, 0, 19, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20009, 0, 9, 3, 5, 0, 8, 11, 23, -12, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20010, 0, 8, 2, 4, 2, 8, 13, 16, -3, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20011, 0, 3, 1, 7, 0, 8, 4, 32, -28, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20012, 0, 21, 7, 0, 0, 7, 32, 10, 19, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20013, 0, 19, 6, 1, 1, 8, 40, 10, 23, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20014, 0, 11, 3, 2, 2, 7, 21, 9, 10, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20015, 0, 10, 3, 4, 1, 8, 24, 22, 2, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20016, 0, 6, 2, 6, 0, 8, 19, 43, -20, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20017, 0, 17, 5, 1, 2, 8, 16, 9, 7, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20018, 0, 16, 5, 2, 1, 8, 15, 6, 8, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20019, 0, 9, 3, 5, 0, 8, 17, 17, 14, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20020, 0, 8, 2, 4, 2, 8, 9, 20, -10, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
SELECT d.id, s.id, 20021, 0, 7, 2, 5, 1, 8, 14, 19, -5, '2026-02-02T12:56:09.501Z', 'CASA Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
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
