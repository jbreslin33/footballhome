-- Match lineups (exported 2026-03-07)
-- 23 lineup entry/entries

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, true, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Gian'
  AND pe.last_name = ''
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, true, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Igor'
  AND pe.last_name = 'Bonfim'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, true, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Luke'
  AND pe.last_name = 'Breslin'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, true, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Christopher'
  AND pe.last_name = 'Da Silva'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, true, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Luis'
  AND pe.last_name = 'De Jesus'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, true, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Andy'
  AND pe.last_name = 'Hizdri'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, true, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'John'
  AND pe.last_name = 'Madureira'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, true, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'David'
  AND pe.last_name = 'Masi'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, true, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Babacar'
  AND pe.last_name = 'Ndiaye'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, true, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Ali'
  AND pe.last_name = 'Salah'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, true, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Denis'
  AND pe.last_name = 'Sousa'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, false, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Hedayatullah'
  AND pe.last_name = ''
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, false, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Victor'
  AND pe.last_name = 'Baidel'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, false, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Oumar'
  AND pe.last_name = 'Barry'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, false, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Aboubacar'
  AND pe.last_name = 'Bayo'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, false, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Inaldo'
  AND pe.last_name = 'Botelho'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, false, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Walter'
  AND pe.last_name = 'Candido'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, false, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Elmer'
  AND pe.last_name = 'Diaz'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, false, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Cloves'
  AND pe.last_name = 'Filho'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, false, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Edwin'
  AND pe.last_name = 'Garcia'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, false, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Christian'
  AND pe.last_name = 'Lopez'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, false, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Fabian'
  AND pe.last_name = 'Padilla'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)
SELECT m.id, p.id, t.id, false, NULL
FROM matches m
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
CROSS JOIN players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN teams t
WHERE ht.name = 'Philly BlackStars'
  AND at.name = 'Lighthouse Boys Club'
  AND m.match_date = '2026-03-08'
  AND pe.first_name = 'Anthony'
  AND pe.last_name = 'Sagastume'
  AND t.name = 'Philly BlackStars'
ON CONFLICT (match_id, player_id)
DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;

