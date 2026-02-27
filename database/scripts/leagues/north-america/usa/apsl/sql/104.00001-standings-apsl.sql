-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Standings - APSL
-- Current season standings data
-- Total Records: 78
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO standings (team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT t.id, 1, 8, 5, 1, 2, 20, 8, 12, 16, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Falcons FC'
  AND d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 2, 5, 4, 1, 0, 20, 2, 18, 13, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Scrub Nation'
  AND d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 3, 5, 4, 1, 0, 17, 3, 14, 13, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Praia Kapital'
  AND d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 4, 5, 2, 0, 3, 15, 11, 4, 6, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'South Coast Union'
  AND d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 5, 6, 1, 1, 4, 12, 17, -5, 4, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Invictus FC'
  AND d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 6, 5, 1, 0, 4, 7, 22, -15, 3, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Project Football'
  AND d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 7, 6, 1, 0, 5, 6, 34, -28, 3, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Fitchburg FC'
  AND d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 8, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Somerville United FC'
  AND d.name = 'Mayflower Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 1, 5, 5, 0, 0, 30, 10, 20, 15, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'KO Elites'
  AND d.name = 'Constitution Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 2, 6, 4, 0, 2, 21, 20, 1, 12, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Glastonbury Celtic'
  AND d.name = 'Constitution Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 3, 6, 1, 1, 4, 10, 24, -14, 4, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Wildcat FC'
  AND d.name = 'Constitution Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 4, 5, 0, 1, 4, 8, 15, -7, 1, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Hermandad Connecticut'
  AND d.name = 'Constitution Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 5, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Caribbean FCA'
  AND d.name = 'Constitution Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 1, 11, 10, 1, 0, 37, 11, 26, 31, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'NY Greek Americans'
  AND d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 2, 11, 7, 2, 2, 29, 10, 19, 23, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Lansdowne Yonkers FC'
  AND d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 3, 10, 7, 1, 2, 34, 13, 21, 22, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Hoboken FC 1912'
  AND d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 4, 10, 7, 0, 3, 26, 13, 13, 21, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'NY Pancyprian Freedoms'
  AND d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 5, 11, 6, 1, 4, 25, 19, 6, 19, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Doxa FCW'
  AND d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 6, 11, 5, 2, 4, 19, 18, 1, 17, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Leros SC'
  AND d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 7, 11, 4, 1, 6, 18, 28, -10, 13, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'NY International FC'
  AND d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 8, 11, 3, 3, 5, 20, 36, -16, 12, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Richmond County FC'
  AND d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 9, 11, 2, 2, 7, 17, 31, -14, 8, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Central Park Rangers FC'
  AND d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 10, 11, 2, 1, 8, 16, 33, -17, 7, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'SC Vistula Garfield'
  AND d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 11, 11, 3, 0, 8, 11, 31, -20, 6, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Zum Schneider FC 03'
  AND d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 12, 11, 2, 0, 9, 17, 26, -9, 6, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'NY Athletic Club'
  AND d.name = 'Metropolitan Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 1, 11, 11, 0, 0, 65, 9, 56, 33, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'WC Predators'
  AND d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 2, 11, 7, 2, 2, 39, 21, 18, 23, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Alloy Soccer Club'
  AND d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 3, 10, 6, 0, 4, 18, 22, -4, 18, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Oaklyn United FC'
  AND d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 4, 11, 6, 0, 5, 18, 17, 1, 18, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Real Central NJ Soccer'
  AND d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 5, 11, 5, 2, 4, 22, 19, 3, 17, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Philadelphia Heritage SC'
  AND d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 6, 11, 5, 1, 5, 31, 23, 8, 16, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Vidas United FC'
  AND d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 7, 9, 4, 3, 2, 20, 23, -3, 15, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Philadelphia Soccer Club'
  AND d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 8, 11, 4, 1, 6, 18, 23, -5, 13, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Jersey Shore Boca'
  AND d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 9, 10, 4, 0, 6, 17, 40, -23, 12, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'GAK'
  AND d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 10, 11, 3, 2, 6, 16, 25, -9, 11, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Lighthouse 1893 SC'
  AND d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 11, 11, 1, 2, 8, 11, 31, -20, 5, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Sewell Old Boys FC'
  AND d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 12, 11, 1, 1, 9, 15, 37, -22, 4, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Medford Strikers'
  AND d.name = 'Delaware River Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 1, 7, 7, 0, 0, 34, 10, 24, 21, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Nova FC'
  AND d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 2, 9, 6, 0, 3, 20, 13, 7, 18, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'VA Marauders FC'
  AND d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 3, 7, 5, 0, 2, 25, 7, 18, 15, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Wave FC'
  AND d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 4, 6, 3, 0, 3, 20, 20, 0, 9, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'PFA APSL'
  AND d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 5, 8, 3, 0, 5, 17, 18, -1, 9, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Grove Soccer United'
  AND d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 6, 5, 2, 0, 3, 6, 10, -4, 6, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Christos FC'
  AND d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 7, 8, 2, 0, 6, 13, 31, -18, 6, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Delmarva Thunder'
  AND d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 8, 8, 1, 0, 7, 7, 33, -26, 3, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'PW Nova'
  AND d.name = 'Mid-Atlantic Conference Fall'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 1, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Balitimore City FC'
  AND d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 2, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'CF Armada'
  AND d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 3, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Chiefs United'
  AND d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 4, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Christos FC'
  AND d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 5, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Club Petrolero'
  AND d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 6, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Delmarva Thunder'
  AND d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 7, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Germantown City FC'
  AND d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 8, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Grove Soccer United'
  AND d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 9, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Nova FC'
  AND d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 10, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'PFA APSL'
  AND d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 11, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'PW Nova'
  AND d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 12, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'VA Marauders FC'
  AND d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 13, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Wave FC'
  AND d.name = 'Mid-Atlantic Conference Spring'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 1, 10, 8, 1, 1, 39, 20, 19, 25, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Terminus FC'
  AND d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 2, 11, 7, 2, 2, 45, 15, 30, 23, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Prima FC'
  AND d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 3, 10, 5, 4, 1, 46, 19, 27, 19, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Majestic SC'
  AND d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 4, 9, 5, 1, 3, 36, 18, 18, 16, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Peachtree FC'
  AND d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 5, 9, 4, 1, 4, 23, 18, 5, 13, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Bel Calcio FC'
  AND d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 6, 10, 3, 0, 7, 24, 22, 2, 9, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Buckhead SC'
  AND d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 7, 4, 2, 1, 1, 10, 10, 0, 7, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Georgia United FC'
  AND d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 8, 10, 2, 0, 8, 22, 39, -17, 6, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Alliance SC'
  AND d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 9, 9, 0, 0, 9, 2, 86, -84, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'SC Gwinnett'
  AND d.name = 'Terminus Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 1, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Alianza FC'
  AND d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 2, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Hoverla FC'
  AND d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 3, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Imlay City FC'
  AND d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 4, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Intra United SC'
  AND d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 5, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Livonia City FC'
  AND d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 6, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'World Class FC'
  AND d.name = 'Mitten Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 1, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'AC Arlington FC'
  AND d.name = 'Trinity Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 2, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Carrollton Old Boyz'
  AND d.name = 'Trinity Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 3, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Foro SC'
  AND d.name = 'Trinity Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 4, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'North Texas Prowl FC'
  AND d.name = 'Trinity Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
SELECT t.id, 5, 0, 0, 0, 0, 0, 0, 0, 0, '2026-02-27T16:35:52.877Z', 'APSL Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = 'Texas Rage FC'
  AND d.name = 'Trinity Conference'
  AND s.name = '2025/2026'
  AND s.league_id = 1
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
