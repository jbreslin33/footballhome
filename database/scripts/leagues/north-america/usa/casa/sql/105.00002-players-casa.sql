-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Players - CASA
-- Player roster data from team pages
-- Total Records: 30
-- 
-- Architecture: Auto-generated IDs, name-based deduplication
-- Same name = same person across all sources (curation overrides via name change)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Hassane', 'Abdellaoui', '1999-07-30') 
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
VALUES ('Lucas', 'AMBROSIO  SOUSA', '1995-12-28') 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Lucas' AND last_name = 'AMBROSIO  SOUSA' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-lucas-ambrosio-sousa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Lucas' AND per.last_name = 'AMBROSIO  SOUSA' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Issac', 'Anderson', '2003-06-23') 
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
VALUES ('Oumar', 'Barry', '2003-10-17') 
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
VALUES ('Aboubacar', 'Bayo', '2004-06-08') 
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
VALUES ('Cesar', 'Coronado', '2005-11-01') 
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
VALUES ('Hamzah', 'Dabbour', '2000-08-29') 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Hamzah' AND last_name = 'Dabbour' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-hamzah-dabbour', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Hamzah' AND per.last_name = 'Dabbour' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Danilo', 'De almeida', '1993-07-01') 
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
VALUES ('Luis', 'De Jesus', '2007-04-16') 
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
VALUES ('Marco', 'Delgado', '2001-12-18') 
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
VALUES ('Cleiton', 'Dias', '1984-04-14') 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cleiton' AND last_name = 'Dias' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-cleiton-dias', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cleiton' AND per.last_name = 'Dias' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Cloves', 'Ferreira da Silva JÃºnior', '1989-11-14') 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cloves' AND last_name = 'Ferreira da Silva JÃºnior' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-cloves-ferreira-da-silva-ja-nior', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cloves' AND per.last_name = 'Ferreira da Silva JÃºnior' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Cloves', 'Filho', '1997-12-19') 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cloves' AND last_name = 'Filho' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-cloves-filho', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cloves' AND per.last_name = 'Filho' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Edwin', 'Garcia', '2006-02-19') 
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
VALUES ('Marcos', 'Gomes Santos', '1996-10-10') 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marcos' AND last_name = 'Gomes Santos' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-marcos-gomes-santos', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marcos' AND per.last_name = 'Gomes Santos' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Maccarrey', 'Guillaume', '2000-07-12') 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Maccarrey' AND last_name = 'Guillaume' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-maccarrey-guillaume', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Maccarrey' AND per.last_name = 'Guillaume' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Miles', 'Henry', '2000-06-20') 
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
VALUES ('Dolph', 'Janvier', '1997-09-23') 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Dolph' AND last_name = 'Janvier' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-dolph-janvier', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Dolph' AND per.last_name = 'Janvier' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Owen', 'Magee', '2003-01-13') 
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
VALUES ('Valentino', 'Martinez', '2002-10-18') 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Valentino' AND last_name = 'Martinez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-u23-valentino-martinez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Valentino' AND per.last_name = 'Martinez' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Elmer', 'Mendoza', '2003-08-04') 
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
VALUES ('Zion', 'Nwalipenja', '2005-01-07') 
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
VALUES ('Matheus', 'Rodrigues', '2005-01-03') 
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
VALUES ('Caleb', 'Rojas', '2001-12-03') 
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
VALUES ('Anthony', 'Sagustume', '1995-07-10') 
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
VALUES ('Ali', 'Salah', '2007-03-10') 
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
VALUES ('Hedayatullah', 'Sangin', '2007-09-24') 
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
VALUES ('Leo', 'Santa', '1977-12-12') 
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
VALUES ('Christopher', 'Solis', '2005-10-21') 
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
VALUES ('Idris', 'Washington', '2001-01-23') 
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

