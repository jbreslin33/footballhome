-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Players - CASA
-- Player roster data from team pages
-- Total Records: 30
-- 
-- Architecture: Auto-generated IDs, name-based deduplication
-- Same name = same person across all sources (curation overrides via name change)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Hassane', 'Abdellaoui', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Hassane' AND last_name = 'Abdellaoui' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-hassane-abdellaoui', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Hassane' AND per.last_name = 'Abdellaoui' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Issac', 'Anderson', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Issac' AND last_name = 'Anderson' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-issac-anderson', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Issac' AND per.last_name = 'Anderson' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Oumar', 'Barry', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Oumar' AND last_name = 'Barry' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-oumar-barry', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Oumar' AND per.last_name = 'Barry' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Aboubacar', 'Bayo', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Aboubacar' AND last_name = 'Bayo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-aboubacar-bayo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Aboubacar' AND per.last_name = 'Bayo' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Cesar', 'Coronado', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cesar' AND last_name = 'Coronado' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-cesar-coronado', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cesar' AND per.last_name = 'Coronado' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Danilo', 'De almeida', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Danilo' AND last_name = 'De almeida' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-danilo-de-almeida', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Danilo' AND per.last_name = 'De almeida' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Luis', 'De Jesus', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Luis' AND last_name = 'De Jesus' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-luis-de-jesus', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Luis' AND per.last_name = 'De Jesus' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marco', 'Delgado', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marco' AND last_name = 'Delgado' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-marco-delgado', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marco' AND per.last_name = 'Delgado' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Abdoul', 'Diallo', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Abdoul' AND last_name = 'Diallo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-abdoul-diallo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Abdoul' AND per.last_name = 'Diallo' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Louis', 'Estrada', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Louis' AND last_name = 'Estrada' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-louis-estrada', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Louis' AND per.last_name = 'Estrada' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Edwin', 'Garcia', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Edwin' AND last_name = 'Garcia' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-edwin-garcia', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Edwin' AND per.last_name = 'Garcia' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('John', 'Gonzalez', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'John' AND last_name = 'Gonzalez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-john-gonzalez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'John' AND per.last_name = 'Gonzalez' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Miles', 'Henry', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Miles' AND last_name = 'Henry' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-miles-henry', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Miles' AND per.last_name = 'Henry' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Andy', 'Hizdri', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Andy' AND last_name = 'Hizdri' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-andy-hizdri', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Andy' AND per.last_name = 'Hizdri' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Owen', 'Magee', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Owen' AND last_name = 'Magee' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-owen-magee', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Owen' AND per.last_name = 'Magee' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('David', 'Masi', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'David' AND last_name = 'Masi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-david-masi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'David' AND per.last_name = 'Masi' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Elmer', 'Mendoza', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Elmer' AND last_name = 'Mendoza' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-elmer-mendoza', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Elmer' AND per.last_name = 'Mendoza' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Babacar', 'Ndiaye', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Babacar' AND last_name = 'Ndiaye' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-babacar-ndiaye', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Babacar' AND per.last_name = 'Ndiaye' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Zion', 'Nwalipenja', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Zion' AND last_name = 'Nwalipenja' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-zion-nwalipenja', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Zion' AND per.last_name = 'Nwalipenja' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Fabian', 'Padilla', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Fabian' AND last_name = 'Padilla' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-fabian-padilla', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Fabian' AND per.last_name = 'Padilla' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Owen', 'Rhydderch', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Owen' AND last_name = 'Rhydderch' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-owen-rhydderch', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Owen' AND per.last_name = 'Rhydderch' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Matheus', 'Rodrigues', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Matheus' AND last_name = 'Rodrigues' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-matheus-rodrigues', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Matheus' AND per.last_name = 'Rodrigues' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Caleb', 'Rojas', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Caleb' AND last_name = 'Rojas' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-caleb-rojas', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Caleb' AND per.last_name = 'Rojas' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Anthony', 'Sagustume', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Anthony' AND last_name = 'Sagustume' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-anthony-sagustume', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Anthony' AND per.last_name = 'Sagustume' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ali', 'Salah', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ali' AND last_name = 'Salah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-ali-salah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ali' AND per.last_name = 'Salah' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Hedayatullah', 'Sangin', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Hedayatullah' AND last_name = 'Sangin' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-hedayatullah-sangin', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Hedayatullah' AND per.last_name = 'Sangin' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Leo', 'Santa', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Leo' AND last_name = 'Santa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-leo-santa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Leo' AND per.last_name = 'Santa' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christopher', 'Solis', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Christopher' AND last_name = 'Solis' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-christopher-solis', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christopher' AND per.last_name = 'Solis' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Cleubimar Teixeira', 'Souza', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cleubimar Teixeira' AND last_name = 'Souza' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-cleubimar-teixeira-souza', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cleubimar Teixeira' AND per.last_name = 'Souza' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Idris', 'Washington', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Idris' AND last_name = 'Washington' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-idris-washington', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Idris' AND per.last_name = 'Washington' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

