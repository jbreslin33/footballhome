-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Rosters - CASA
-- Player-team relationships from team roster pages
-- Total Records: 30
-- 
-- Architecture: Players looked up by name (no hardcoded IDs)
-- joined_at uses sentinel date '1970-01-01' for scraped rosters (deterministic for UPSERT)
-- Partial replace: DELETE only scoped teams for this sync, then re-INSERT current roster
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Remove existing roster entries for the teams covered by this sync
-- This ensures players removed from the official roster are also removed from the DB
DELETE FROM rosters WHERE team_id IN (SELECT id FROM teams WHERE source_system_id = 2 AND external_id IN ('9090889-lighthouse-boys-club', '9090889-oaklyn-united-fc-ii', '9090889-illyrians-fc', '9090889-phoenix-reserves', '9090889-lighthouse-old-timers-club', '9090889-adé-united-fc', '9090889-philadelphia-sierra-stars', '9090889-persepolis-fc', '9090889-philly-blackstars', '9090889-philadelphia-sc-ii', '9090889-lighthouse-boys-club-u23', '9090889-phoenix-scm'));

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Amar' AND per.last_name = 'Abdelrazek'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Weder' AND per.last_name = 'Aguire'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Lucas' AND per.last_name = 'AMBROSIO  SOUSA'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Victor' AND per.last_name = 'Baidel'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Inaldo' AND per.last_name = 'Botelho'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Samuel' AND per.last_name = 'Botelho'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Christopher' AND per.last_name = 'Braz'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Luke' AND per.last_name = 'Breslin'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Walter' AND per.last_name = 'Candido'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Kayke Maciel' AND per.last_name = 'Da Silva'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Hamzah' AND per.last_name = 'Dabbour'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Nycolas Kayke' AND per.last_name = 'De Jesus'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Emmanuel' AND per.last_name = 'Dennis'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Cleiton' AND per.last_name = 'Dias'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Cloves' AND per.last_name = 'Ferreira da Silva JÃºnior'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Cloves' AND per.last_name = 'Filho'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Abouya' AND per.last_name = 'Gangue'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Marcos' AND per.last_name = 'Gomes Santos'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Maccarrey' AND per.last_name = 'Guillaume'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Denis' AND per.last_name = 'Jhony'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Alexander' AND per.last_name = 'Lara'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Pedro' AND per.last_name = 'Lara'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Reginaldo' AND per.last_name = 'Leite'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Owen' AND per.last_name = 'Magee'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Valentino' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Lucas' AND per.last_name = 'Morais'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'John' AND per.last_name = 'Oladele'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Jemirkel' AND per.last_name = 'Ornaque'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Marcos' AND per.last_name = 'Ribeiro'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Igor' AND per.last_name = 'Santos Bonfim'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

