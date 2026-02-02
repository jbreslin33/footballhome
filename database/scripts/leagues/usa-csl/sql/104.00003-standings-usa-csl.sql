-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Standings - CSL
-- Current season standings data
-- Total Records: 101
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, 10000, 1, 20, 13, 0, 7, 50, 27, 23, 39, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10001, 2, 20, 10, 7, 3, 36, 21, 15, 37, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10002, 3, 20, 10, 4, 6, 49, 37, 12, 34, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10003, 4, 20, 10, 4, 6, 40, 39, 1, 34, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10004, 5, 20, 9, 3, 8, 38, 43, -5, 27, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10005, 6, 20, 7, 5, 8, 43, 29, 14, 26, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10006, 7, 20, 6, 7, 7, 34, 27, 7, 25, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10007, 8, 20, 6, 7, 7, 34, 46, -12, 25, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10008, 9, 20, 7, 2, 11, 43, 47, -4, 23, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10009, 10, 20, 7, 1, 12, 38, 42, -4, 22, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10010, 11, 20, 3, 4, 13, 18, 65, -47, 10, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10011, 1, 20, 17, 1, 2, 69, 10, 59, 52, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10012, 2, 20, 10, 4, 6, 53, 29, 24, 34, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10013, 3, 20, 11, 1, 8, 43, 41, 2, 34, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10014, 4, 20, 10, 3, 7, 39, 28, 11, 33, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10015, 5, 20, 11, 0, 9, 47, 41, 6, 33, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10016, 6, 20, 8, 4, 8, 41, 33, 8, 28, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10017, 7, 20, 8, 1, 11, 39, 52, -13, 25, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10018, 8, 20, 6, 4, 10, 41, 63, -22, 22, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10019, 9, 20, 6, 3, 11, 36, 38, -2, 21, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10020, 10, 20, 5, 3, 12, 35, 62, -27, 18, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10021, 11, 20, 5, 2, 13, 29, 75, -46, 14, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 1 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10022, 1, 16, 11, 4, 1, 47, 15, 32, 37, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10023, 2, 16, 11, 2, 3, 45, 18, 27, 35, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10024, 3, 16, 10, 4, 2, 30, 15, 15, 34, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10025, 4, 16, 10, 3, 3, 44, 15, 29, 33, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10026, 5, 16, 10, 3, 3, 32, 15, 17, 32, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10027, 6, 16, 10, 2, 4, 36, 21, 15, 32, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10028, 7, 16, 7, 4, 5, 31, 22, 9, 25, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10029, 8, 16, 7, 4, 5, 29, 18, 11, 25, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10030, 9, 15, 6, 4, 5, 33, 30, 3, 22, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10031, 10, 16, 6, 2, 8, 34, 27, 7, 20, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10032, 11, 16, 5, 3, 8, 24, 37, -13, 18, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10033, 12, 16, 5, 2, 9, 24, 36, -12, 17, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10034, 13, 16, 5, 2, 9, 23, 45, -22, 17, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10035, 14, 16, 3, 5, 8, 14, 32, -18, 14, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10036, 15, 15, 4, 1, 10, 20, 34, -14, 13, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10037, 16, 16, 3, 2, 11, 23, 46, -23, 11, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10038, 17, 16, 2, 2, 12, 18, 49, -31, 8, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10039, 18, 16, 3, 1, 12, 16, 48, -32, -2, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10040, 1, 16, 15, 0, 1, 68, 16, 52, 45, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10041, 2, 16, 12, 2, 2, 42, 13, 29, 38, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10042, 3, 16, 10, 2, 4, 42, 26, 16, 32, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10043, 4, 16, 10, 1, 5, 46, 25, 21, 31, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10044, 5, 16, 9, 4, 3, 38, 22, 16, 31, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10045, 6, 16, 9, 0, 7, 37, 26, 11, 27, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10046, 7, 16, 8, 3, 5, 30, 23, 7, 27, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10047, 8, 16, 8, 1, 7, 25, 27, -2, 25, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10048, 9, 16, 7, 2, 7, 33, 36, -3, 23, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10049, 10, 16, 7, 2, 7, 31, 34, -3, 23, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10050, 11, 16, 6, 5, 5, 16, 19, -3, 23, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10051, 12, 16, 6, 0, 10, 28, 42, -14, 18, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10052, 13, 16, 4, 3, 9, 34, 39, -5, 15, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10053, 14, 16, 5, 0, 11, 24, 42, -18, 15, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10054, 15, 16, 3, 5, 8, 19, 29, -10, 14, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10055, 16, 16, 3, 2, 11, 18, 32, -14, 11, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10056, 17, 16, 3, 2, 11, 14, 51, -37, 11, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10057, 18, 16, 1, 2, 13, 14, 57, -43, 5, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 2 Reserve'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10058, 1, 18, 15, 1, 2, 59, 16, 43, 46, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10059, 2, 18, 13, 1, 4, 30, 16, 14, 40, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10060, 3, 18, 12, 4, 2, 42, 17, 25, 40, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10061, 4, 18, 12, 2, 4, 47, 22, 25, 38, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10062, 5, 18, 11, 3, 4, 47, 31, 16, 34, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10063, 6, 17, 8, 2, 7, 35, 28, 7, 26, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10064, 7, 18, 7, 1, 10, 37, 34, 3, 22, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10065, 8, 18, 5, 6, 7, 30, 33, -3, 21, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10066, 9, 18, 5, 2, 11, 24, 43, -19, 17, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10067, 10, 17, 5, 2, 10, 28, 43, -15, 17, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10068, 11, 17, 4, 3, 10, 26, 42, -16, 15, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10069, 12, 17, 3, 1, 13, 20, 48, -28, 10, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10070, 13, 17, 0, 2, 15, 25, 74, -49, 2, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10071, 14, 1, 0, 0, 1, 0, 3, -3, 0, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 3'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10072, 1, 18, 16, 2, 0, 59, 12, 47, 50, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10073, 2, 18, 12, 2, 4, 46, 28, 18, 38, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10074, 3, 18, 11, 0, 7, 53, 44, 9, 33, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10075, 4, 18, 9, 4, 5, 42, 26, 16, 30, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10076, 5, 18, 9, 2, 7, 42, 32, 10, 29, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10077, 6, 18, 8, 1, 9, 38, 27, 11, 25, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10078, 7, 18, 4, 4, 10, 26, 48, -22, 16, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10079, 8, 18, 5, 1, 12, 29, 52, -23, 16, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10080, 9, 18, 2, 5, 11, 17, 50, -33, 11, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10081, 10, 18, 3, 1, 14, 24, 57, -33, 10, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Division 4'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10082, 1, 10, 8, 1, 1, 41, 6, 35, 25, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10083, 2, 10, 6, 1, 3, 22, 16, 6, 19, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10084, 3, 10, 3, 3, 4, 24, 19, 5, 12, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10085, 4, 10, 2, 5, 3, 17, 20, -3, 11, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10086, 5, 9, 2, 2, 5, 13, 32, -19, 8, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10087, 6, 9, 1, 2, 6, 9, 33, -24, 5, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Spring Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10088, 1, 16, 13, 1, 2, 53, 21, 32, 40, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10089, 2, 16, 11, 2, 3, 46, 27, 19, 35, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10090, 3, 16, 11, 2, 3, 57, 14, 43, 35, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10091, 4, 16, 9, 5, 2, 52, 27, 25, 32, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10092, 5, 16, 9, 3, 4, 51, 21, 30, 30, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10093, 6, 19, 8, 2, 9, 39, 39, 0, 26, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10094, 7, 19, 8, 1, 10, 48, 44, 4, 25, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10095, 8, 19, 8, 1, 10, 35, 54, -19, 25, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10096, 9, 19, 7, 0, 12, 35, 56, -21, 21, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10097, 10, 17, 6, 1, 10, 34, 52, -18, 19, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10098, 11, 18, 5, 0, 13, 24, 52, -28, 15, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10099, 12, 18, 4, 3, 11, 25, 52, -27, 15, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
SELECT d.id, s.id, 10100, 13, 19, 4, 1, 14, 26, 66, -40, 13, '2026-02-02T00:41:26.396Z', 'CSL Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Over-40 Division'
  AND s.name = '2022/2023'
  AND s.league_id = 4
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
