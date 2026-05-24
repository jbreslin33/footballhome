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
DELETE FROM rosters WHERE team_id IN (SELECT id FROM teams WHERE source_system_id = 2 AND external_id IN ('9096430-lighthouse-boys-club-u23', '9096430-phoenix-scr', '9096430-lighthouse-boys-club', '9096430-philadelphia-sc-select', '9096430-ade-united-fc', '9096430-persepolis-fc-ii', '9096430-philly-black-stars', '9096430-sewell''s-old-boys', '9096430-oaklyn-united-nor''easters-ii', '9096430-philadelphia-sierra-stars', '9096430-illyrians'));

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Hassane' AND per.last_name = 'Abdellaoui'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Lucas' AND per.last_name = 'AMBROSIO  SOUSA'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Issac' AND per.last_name = 'Anderson'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Oumar' AND per.last_name = 'Barry'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Aboubacar' AND per.last_name = 'Bayo'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Cesar' AND per.last_name = 'Coronado'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Hamzah' AND per.last_name = 'Dabbour'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Danilo' AND per.last_name = 'De almeida'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Luis' AND per.last_name = 'De Jesus'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Marco' AND per.last_name = 'Delgado'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Cleiton' AND per.last_name = 'Dias'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Cloves' AND per.last_name = 'Ferreira da Silva JÃºnior'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Cloves' AND per.last_name = 'Filho'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Edwin' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Marcos' AND per.last_name = 'Gomes Santos'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Maccarrey' AND per.last_name = 'Guillaume'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Miles' AND per.last_name = 'Henry'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Dolph' AND per.last_name = 'Janvier'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Owen' AND per.last_name = 'Magee'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Valentino' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Elmer' AND per.last_name = 'Mendoza'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Zion' AND per.last_name = 'Nwalipenja'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Matheus' AND per.last_name = 'Rodrigues'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Caleb' AND per.last_name = 'Rojas'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Anthony' AND per.last_name = 'Sagustume'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Ali' AND per.last_name = 'Salah'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Hedayatullah' AND per.last_name = 'Sangin'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Leo' AND per.last_name = 'Santa'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Christopher' AND per.last_name = 'Solis'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club U23' AND t.source_system_id = 2
  AND per.first_name = 'Idris' AND per.last_name = 'Washington'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;

