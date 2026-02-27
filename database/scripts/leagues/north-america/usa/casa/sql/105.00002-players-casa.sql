-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Players - CASA
-- Player roster data from team pages
-- Total Records: 628
-- 
-- Architecture: Auto-generated IDs, name-based deduplication
-- Same name = same person across all sources (curation overrides via name change)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sammy', 'Amin', '2003-10-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sammy' AND last_name = 'Amin' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-sammy-amin', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sammy' AND per.last_name = 'Amin' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jeffrey', 'Asiedu', '2004-02-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jeffrey' AND last_name = 'Asiedu' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-jeffrey-asiedu', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jeffrey' AND per.last_name = 'Asiedu' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Theo', 'Biddle', '2000-07-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Theo' AND last_name = 'Biddle' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-theo-biddle', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Theo' AND per.last_name = 'Biddle' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Tyler', 'Caton', '1995-04-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Tyler' AND last_name = 'Caton' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-tyler-caton', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Tyler' AND per.last_name = 'Caton' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jorge', 'Cervantes', '2002-05-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jorge' AND last_name = 'Cervantes' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-jorge-cervantes', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jorge' AND per.last_name = 'Cervantes' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Manuel', 'Chacon Fallas', '1998-12-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Manuel' AND last_name = 'Chacon Fallas' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-manuel-chacon-fallas', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Manuel' AND per.last_name = 'Chacon Fallas' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Miguel', 'Cortes', '1991-10-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Miguel' AND last_name = 'Cortes' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-miguel-cortes', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Miguel' AND per.last_name = 'Cortes' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Tyler', 'Dautrich', '1992-08-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Tyler' AND last_name = 'Dautrich' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-tyler-dautrich', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Tyler' AND per.last_name = 'Dautrich' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Cameron', 'Dennis', '1995-11-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cameron' AND last_name = 'Dennis' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-cameron-dennis', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cameron' AND per.last_name = 'Dennis' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Aaron', 'Endres', '1999-03-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Aaron' AND last_name = 'Endres' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-aaron-endres', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Aaron' AND per.last_name = 'Endres' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Evan', 'Kent', '2003-07-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Evan' AND last_name = 'Kent' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-evan-kent', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Evan' AND per.last_name = 'Kent' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Lekan', 'King', '1992-09-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Lekan' AND last_name = 'King' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-lekan-king', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Lekan' AND per.last_name = 'King' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mateo', 'Loyo', '2004-11-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mateo' AND last_name = 'Loyo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-mateo-loyo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mateo' AND per.last_name = 'Loyo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christopher', 'Manful', '2001-07-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Christopher' AND last_name = 'Manful' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-christopher-manful', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christopher' AND per.last_name = 'Manful' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sammy', 'Monistere', '1993-09-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sammy' AND last_name = 'Monistere' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-sammy-monistere', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sammy' AND per.last_name = 'Monistere' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Rocco', 'Monteiro', '2004-02-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Rocco' AND last_name = 'Monteiro' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-rocco-monteiro', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Rocco' AND per.last_name = 'Monteiro' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Eli', 'Moraru', '2000-06-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Eli' AND last_name = 'Moraru' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-eli-moraru', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Eli' AND per.last_name = 'Moraru' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Zachery', 'Moyer', '2002-06-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Zachery' AND last_name = 'Moyer' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-zachery-moyer', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Zachery' AND per.last_name = 'Moyer' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Michael', 'Oh', '1992-10-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Michael' AND last_name = 'Oh' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-michael-oh', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Michael' AND per.last_name = 'Oh' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('David', 'Olukoya', '2005-05-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'David' AND last_name = 'Olukoya' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-david-olukoya', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'David' AND per.last_name = 'Olukoya' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Tamer', 'Ozturk', '2000-02-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Tamer' AND last_name = 'Ozturk' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-tamer-ozturk', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Tamer' AND per.last_name = 'Ozturk' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Joao', 'Patelli Ramos dos Santos', '2000-10-16') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Joao' AND last_name = 'Patelli Ramos dos Santos' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-joao-patelli-ramos-dos-santos', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Joao' AND per.last_name = 'Patelli Ramos dos Santos' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ethan', 'Reta', '2005-01-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ethan' AND last_name = 'Reta' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-ethan-reta', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ethan' AND per.last_name = 'Reta' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gonzalo', 'Reyes', '2002-02-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gonzalo' AND last_name = 'Reyes' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-gonzalo-reyes', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gonzalo' AND per.last_name = 'Reyes' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('justin', 'reynoso', '2006-09-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'justin' AND last_name = 'reynoso' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-justin-reynoso', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'justin' AND per.last_name = 'reynoso' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Cole', 'Roddy', '2002-04-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cole' AND last_name = 'Roddy' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-cole-roddy', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cole' AND per.last_name = 'Roddy' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Adam', 'Silberg', '2000-09-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Adam' AND last_name = 'Silberg' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-adam-silberg', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Adam' AND per.last_name = 'Silberg' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ethan', 'Spence', '2001-05-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ethan' AND last_name = 'Spence' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-ethan-spence', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ethan' AND per.last_name = 'Spence' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kevin', 'Taipe', '2004-10-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kevin' AND last_name = 'Taipe' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'ade-united-fc-kevin-taipe', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kevin' AND per.last_name = 'Taipe' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Djalilou', 'Adam-Djobo', '1990-12-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Djalilou' AND last_name = 'Adam-Djobo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-djalilou-adam-djobo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Djalilou' AND per.last_name = 'Adam-Djobo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mitchel', 'Alfaro', '1998-02-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mitchel' AND last_name = 'Alfaro' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-mitchel-alfaro', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mitchel' AND per.last_name = 'Alfaro' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Luke', 'Archibald', '2000-05-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Luke' AND last_name = 'Archibald' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-luke-archibald', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Luke' AND per.last_name = 'Archibald' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Noah', 'Blodget', '1996-02-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Noah' AND last_name = 'Blodget' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-noah-blodget', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Noah' AND per.last_name = 'Blodget' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gonazalo', 'Chiang', '1999-12-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gonazalo' AND last_name = 'Chiang' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-gonazalo-chiang', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gonazalo' AND per.last_name = 'Chiang' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Hayden', 'Cote', '2006-12-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Hayden' AND last_name = 'Cote' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-hayden-cote', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Hayden' AND per.last_name = 'Cote' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Brandon', 'Da Silva', '2007-03-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Brandon' AND last_name = 'Da Silva' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-brandon-da-silva', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Brandon' AND per.last_name = 'Da Silva' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Brandon', 'DeAngelo', '2003-07-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Brandon' AND last_name = 'DeAngelo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-brandon-deangelo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Brandon' AND per.last_name = 'DeAngelo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Khadim', 'Drame', '1994-03-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Khadim' AND last_name = 'Drame' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-khadim-drame', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Khadim' AND per.last_name = 'Drame' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Emin', 'Gunaydin', '2000-11-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Emin' AND last_name = 'Gunaydin' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-emin-gunaydin', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Emin' AND per.last_name = 'Gunaydin' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Vincent', 'Guzzo', '1995-02-16') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Vincent' AND last_name = 'Guzzo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-vincent-guzzo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Vincent' AND per.last_name = 'Guzzo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Rabah', 'Hameg', '1997-06-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Rabah' AND last_name = 'Hameg' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-rabah-hameg', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Rabah' AND per.last_name = 'Hameg' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Anthony', 'Jenkins', '2000-09-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Anthony' AND last_name = 'Jenkins' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-anthony-jenkins', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Anthony' AND per.last_name = 'Jenkins' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sincere', 'Kato', '2003-07-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sincere' AND last_name = 'Kato' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-sincere-kato', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sincere' AND per.last_name = 'Kato' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Cooper', 'Lang', '1999-06-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cooper' AND last_name = 'Lang' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-cooper-lang', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cooper' AND per.last_name = 'Lang' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alex', 'Lewis', '1990-05-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alex' AND last_name = 'Lewis' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-alex-lewis', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alex' AND per.last_name = 'Lewis' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Lucien', 'Maslin', '2005-05-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Lucien' AND last_name = 'Maslin' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-lucien-maslin', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Lucien' AND per.last_name = 'Maslin' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Dayvon', 'Mbu', '2002-11-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Dayvon' AND last_name = 'Mbu' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-dayvon-mbu', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Dayvon' AND per.last_name = 'Mbu' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kevin', 'Munive', '2003-05-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kevin' AND last_name = 'Munive' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-kevin-munive', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kevin' AND per.last_name = 'Munive' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Matthew', 'Pastore', '1995-08-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Matthew' AND last_name = 'Pastore' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-matthew-pastore', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Matthew' AND per.last_name = 'Pastore' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ethan', 'Spinatto', '2005-05-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ethan' AND last_name = 'Spinatto' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-ethan-spinatto', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ethan' AND per.last_name = 'Spinatto' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Travis', 'Spotts', '1997-02-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Travis' AND last_name = 'Spotts' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-travis-spotts', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Travis' AND per.last_name = 'Spotts' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marc', 'M’bia M’bida-Essind Pastor', '2002-06-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marc' AND last_name = 'M’bia M’bida-Essind Pastor' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-marc-m-bia-m-bida-essind-pastor', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marc' AND per.last_name = 'M’bia M’bida-Essind Pastor' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Logan', 'Shaw', '2007-02-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Logan' AND last_name = 'Shaw' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-logan-shaw', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Logan' AND per.last_name = 'Shaw' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Adrian', 'Rodriquez', '2008-10-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Adrian' AND last_name = 'Rodriquez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-adrian-rodriquez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Adrian' AND per.last_name = 'Rodriquez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Veysel', 'Tut', '2005-09-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Veysel' AND last_name = 'Tut' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-veysel-tut', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Veysel' AND per.last_name = 'Tut' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('John', 'Waddell', '2005-11-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'John' AND last_name = 'Waddell' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'oaklyn-united-fc-ii-john-waddell', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'John' AND per.last_name = 'Waddell' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Issac', 'Agyapong', '1994-09-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Issac' AND last_name = 'Agyapong' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-issac-agyapong', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Issac' AND per.last_name = 'Agyapong' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Abdul Razak', 'Alhassan', '2005-05-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Abdul Razak' AND last_name = 'Alhassan' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-abdul-razak-alhassan', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Abdul Razak' AND per.last_name = 'Alhassan' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Hassan', 'Bah', '1995-11-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Hassan' AND last_name = 'Bah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-hassan-bah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Hassan' AND per.last_name = 'Bah' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Abu', 'Bangura', '1998-08-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Abu' AND last_name = 'Bangura' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-abu-bangura', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Abu' AND per.last_name = 'Bangura' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mustapha', 'Bangura', '1989-10-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mustapha' AND last_name = 'Bangura' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-mustapha-bangura', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mustapha' AND per.last_name = 'Bangura' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Abubakarr', 'Bangura', '2001-12-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Abubakarr' AND last_name = 'Bangura' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-abubakarr-bangura', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Abubakarr' AND per.last_name = 'Bangura' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Demba', 'Camara', '1996-08-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Demba' AND last_name = 'Camara' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-demba-camara', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Demba' AND per.last_name = 'Camara' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Cephas', 'Forson', '1993-05-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cephas' AND last_name = 'Forson' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-cephas-forson', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cephas' AND per.last_name = 'Forson' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Richardo', 'Gaye', '1996-10-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Richardo' AND last_name = 'Gaye' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-richardo-gaye', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Richardo' AND per.last_name = 'Gaye' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('John', 'Gwah', '1996-01-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'John' AND last_name = 'Gwah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-john-gwah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'John' AND per.last_name = 'Gwah' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Abraham', 'Kamara', '2007-05-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Abraham' AND last_name = 'Kamara' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-abraham-kamara', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Abraham' AND per.last_name = 'Kamara' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Francis', 'Kamara', '1996-12-23') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Francis' AND last_name = 'Kamara' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-francis-kamara', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Francis' AND per.last_name = 'Kamara' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mohamed', 'Kamara', '2004-01-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mohamed' AND last_name = 'Kamara' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-mohamed-kamara', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mohamed' AND per.last_name = 'Kamara' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alpha', 'Kanu', '1994-08-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alpha' AND last_name = 'Kanu' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-alpha-kanu', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alpha' AND per.last_name = 'Kanu' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Nyakeh', 'Kiawoh', '1997-10-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Nyakeh' AND last_name = 'Kiawoh' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-nyakeh-kiawoh', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Nyakeh' AND per.last_name = 'Kiawoh' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sory', 'Konneh', '1979-07-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sory' AND last_name = 'Konneh' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-sory-konneh', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sory' AND per.last_name = 'Konneh' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Idrissa', 'Konobundor', '2007-05-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Idrissa' AND last_name = 'Konobundor' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-idrissa-konobundor', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Idrissa' AND per.last_name = 'Konobundor' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Yayah', 'Koroma', '2000-05-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Yayah' AND last_name = 'Koroma' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-yayah-koroma', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Yayah' AND per.last_name = 'Koroma' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alpha', 'Koroma', '2004-06-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alpha' AND last_name = 'Koroma' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-alpha-koroma', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alpha' AND per.last_name = 'Koroma' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Moses', 'Kpalu', '1980-04-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Moses' AND last_name = 'Kpalu' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-moses-kpalu', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Moses' AND per.last_name = 'Kpalu' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Foday', 'Kuyateh', '1997-01-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Foday' AND last_name = 'Kuyateh' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-foday-kuyateh', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Foday' AND per.last_name = 'Kuyateh' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Badamasie', 'Mujtabah', '1994-11-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Badamasie' AND last_name = 'Mujtabah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-badamasie-mujtabah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Badamasie' AND per.last_name = 'Mujtabah' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Benedict', 'Olaloye', '2003-04-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Benedict' AND last_name = 'Olaloye' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-benedict-olaloye', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Benedict' AND per.last_name = 'Olaloye' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Emmanuel', 'Onwubiko', '1996-10-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Emmanuel' AND last_name = 'Onwubiko' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-emmanuel-onwubiko', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Emmanuel' AND per.last_name = 'Onwubiko' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Samuel', 'Sandi', '2003-06-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Samuel' AND last_name = 'Sandi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-samuel-sandi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Samuel' AND per.last_name = 'Sandi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alim', 'Sesay', '2006-12-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alim' AND last_name = 'Sesay' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-alim-sesay', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alim' AND per.last_name = 'Sesay' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Abdul', 'Sesay', '1988-08-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Abdul' AND last_name = 'Sesay' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-abdul-sesay', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Abdul' AND per.last_name = 'Sesay' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Favor', 'WeahJr', '1997-02-16') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Favor' AND last_name = 'WeahJr' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sierra-stars-favor-weahjr', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Favor' AND per.last_name = 'WeahJr' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sulaiman', 'Adegoke', '2002-02-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sulaiman' AND last_name = 'Adegoke' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-sulaiman-adegoke', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sulaiman' AND per.last_name = 'Adegoke' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Promise', 'Adeyi', '2003-04-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Promise' AND last_name = 'Adeyi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-promise-adeyi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Promise' AND per.last_name = 'Adeyi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ashkon', 'Ashrafiuon', '1998-10-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ashkon' AND last_name = 'Ashrafiuon' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-ashkon-ashrafiuon', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ashkon' AND per.last_name = 'Ashrafiuon' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Thomas', 'Attamante', '1993-09-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Thomas' AND last_name = 'Attamante' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-thomas-attamante', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Thomas' AND per.last_name = 'Attamante' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mama', 'Bah', '2000-08-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mama' AND last_name = 'Bah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-mama-bah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mama' AND per.last_name = 'Bah' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Cee', 'Brown', '1992-07-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cee' AND last_name = 'Brown' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-cee-brown', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cee' AND per.last_name = 'Brown' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('John', 'Costello', '1994-08-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'John' AND last_name = 'Costello' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-john-costello', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'John' AND per.last_name = 'Costello' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('patrick', 'cronin', '1998-02-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'patrick' AND last_name = 'cronin' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-patrick-cronin', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'patrick' AND per.last_name = 'cronin' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jorge', 'Diaz', '1994-04-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jorge' AND last_name = 'Diaz' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-jorge-diaz', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jorge' AND per.last_name = 'Diaz' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('T-Ben', 'Donnie', '1994-07-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'T-Ben' AND last_name = 'Donnie' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-t-ben-donnie', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'T-Ben' AND per.last_name = 'Donnie' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Oluwaseun', 'Falayi', '2002-10-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Oluwaseun' AND last_name = 'Falayi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-oluwaseun-falayi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Oluwaseun' AND per.last_name = 'Falayi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alfred Wakai', 'Gibson jr', '1992-11-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alfred Wakai' AND last_name = 'Gibson jr' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-alfred-wakai-gibson-jr', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alfred Wakai' AND per.last_name = 'Gibson jr' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Peter', 'Jakubik', '2002-11-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Peter' AND last_name = 'Jakubik' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-peter-jakubik', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Peter' AND per.last_name = 'Jakubik' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mark', 'Manis', '1972-03-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mark' AND last_name = 'Manis' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-mark-manis', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mark' AND per.last_name = 'Manis' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kevin', 'Sadeghipour', '1990-02-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kevin' AND last_name = 'Sadeghipour' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-kevin-sadeghipour', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kevin' AND per.last_name = 'Sadeghipour' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Zouma', 'Sanya', '1999-06-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Zouma' AND last_name = 'Sanya' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-zouma-sanya', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Zouma' AND per.last_name = 'Sanya' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christopher', 'Selekpoh', '2004-09-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Christopher' AND last_name = 'Selekpoh' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-christopher-selekpoh', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christopher' AND per.last_name = 'Selekpoh' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('CJ', 'Smolyn', '1997-11-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'CJ' AND last_name = 'Smolyn' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-cj-smolyn', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'CJ' AND per.last_name = 'Smolyn' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Fawaz', 'Somoye', '2005-03-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Fawaz' AND last_name = 'Somoye' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-fawaz-somoye', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Fawaz' AND per.last_name = 'Somoye' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sebastain', 'Stelmach', '1996-03-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sebastain' AND last_name = 'Stelmach' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-sebastain-stelmach', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sebastain' AND per.last_name = 'Stelmach' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Tonny', 'Temple', '2000-09-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Tonny' AND last_name = 'Temple' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-tonny-temple', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Tonny' AND per.last_name = 'Temple' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christian', 'Toussaint', '1999-10-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Christian' AND last_name = 'Toussaint' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-christian-toussaint', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christian' AND per.last_name = 'Toussaint' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Henry', 'Tye', '1993-04-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Henry' AND last_name = 'Tye' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-henry-tye', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Henry' AND per.last_name = 'Tye' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Bill', 'Wilson', '2002-10-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Bill' AND last_name = 'Wilson' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-fc-bill-wilson', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Bill' AND per.last_name = 'Wilson' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kevin', 'Bowers', '1999-02-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kevin' AND last_name = 'Bowers' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-kevin-bowers', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kevin' AND per.last_name = 'Bowers' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Emile', 'Diderot', '1998-08-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Emile' AND last_name = 'Diderot' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-emile-diderot', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Emile' AND per.last_name = 'Diderot' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Joseph', 'Duddy', '1999-02-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Joseph' AND last_name = 'Duddy' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-joseph-duddy', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Joseph' AND per.last_name = 'Duddy' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ayoub', 'Fask', '2004-03-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ayoub' AND last_name = 'Fask' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-ayoub-fask', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ayoub' AND per.last_name = 'Fask' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alexander', 'Graul', '1998-01-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alexander' AND last_name = 'Graul' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-alexander-graul', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alexander' AND per.last_name = 'Graul' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Brendan', 'Hanratty', '1998-10-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Brendan' AND last_name = 'Hanratty' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-brendan-hanratty', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Brendan' AND per.last_name = 'Hanratty' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kevin', 'Hanuscin', '1999-09-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kevin' AND last_name = 'Hanuscin' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-kevin-hanuscin', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kevin' AND per.last_name = 'Hanuscin' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Malcolm', 'Kane', '1995-08-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Malcolm' AND last_name = 'Kane' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-malcolm-kane', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Malcolm' AND per.last_name = 'Kane' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Nicholas', 'LeFevre', '1998-09-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Nicholas' AND last_name = 'LeFevre' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-nicholas-lefevre', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Nicholas' AND per.last_name = 'LeFevre' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Juan', 'López', '2001-01-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Juan' AND last_name = 'López' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-juan-lopez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Juan' AND per.last_name = 'López' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jimmy', 'Manning', '2004-07-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jimmy' AND last_name = 'Manning' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-jimmy-manning', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jimmy' AND per.last_name = 'Manning' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alejandro', 'Medina', '1997-02-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alejandro' AND last_name = 'Medina' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-alejandro-medina', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alejandro' AND per.last_name = 'Medina' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Diego', 'Moreira Pereira', '1992-09-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Diego' AND last_name = 'Moreira Pereira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-diego-moreira-pereira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Diego' AND per.last_name = 'Moreira Pereira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jose', 'Moura Filho', '2006-01-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jose' AND last_name = 'Moura Filho' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-jose-moura-filho', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jose' AND per.last_name = 'Moura Filho' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Khalidi', 'Ponela', '2004-12-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Khalidi' AND last_name = 'Ponela' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-khalidi-ponela', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Khalidi' AND per.last_name = 'Ponela' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alec', 'Power', '1999-04-23') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alec' AND last_name = 'Power' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-alec-power', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alec' AND per.last_name = 'Power' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jim', 'Power', '1967-05-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jim' AND last_name = 'Power' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scm-jim-power', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jim' AND per.last_name = 'Power' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Myles', 'Addy', '1988-10-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Myles' AND last_name = 'Addy' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-myles-addy', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Myles' AND per.last_name = 'Addy' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Charles', 'Afful', '1997-02-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Charles' AND last_name = 'Afful' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-charles-afful', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Charles' AND per.last_name = 'Afful' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ahmed', 'Ali', '1997-09-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ahmed' AND last_name = 'Ali' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-ahmed-ali', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ahmed' AND per.last_name = 'Ali' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Fred', 'Amadi', '1977-10-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Fred' AND last_name = 'Amadi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-fred-amadi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Fred' AND per.last_name = 'Amadi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Edmond', 'Ansah', '2001-05-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Edmond' AND last_name = 'Ansah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-edmond-ansah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Edmond' AND per.last_name = 'Ansah' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Joe', 'Attakora', '1991-06-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Joe' AND last_name = 'Attakora' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-joe-attakora', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Joe' AND per.last_name = 'Attakora' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christian', 'Bamba', '1995-11-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Christian' AND last_name = 'Bamba' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-christian-bamba', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christian' AND per.last_name = 'Bamba' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Al hassane', 'Belemou', '1993-03-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Al hassane' AND last_name = 'Belemou' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-al-hassane-belemou', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Al hassane' AND per.last_name = 'Belemou' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Prince', 'Boafo', '1995-06-23') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Prince' AND last_name = 'Boafo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-prince-boafo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Prince' AND per.last_name = 'Boafo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Dilan', 'Carrasco-Palma', '2006-10-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Dilan' AND last_name = 'Carrasco-Palma' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-dilan-carrasco-palma', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Dilan' AND per.last_name = 'Carrasco-Palma' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Michael', 'Danquah', '1995-06-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Michael' AND last_name = 'Danquah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-michael-danquah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Michael' AND per.last_name = 'Danquah' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Bartels', 'Danquah', '2004-05-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Bartels' AND last_name = 'Danquah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-bartels-danquah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Bartels' AND per.last_name = 'Danquah' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Joshua', 'Deets', '2002-01-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Joshua' AND last_name = 'Deets' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-joshua-deets', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Joshua' AND per.last_name = 'Deets' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Landon', 'Goodison', '2007-03-16') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Landon' AND last_name = 'Goodison' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-landon-goodison', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Landon' AND per.last_name = 'Goodison' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Bernard', 'Kyei-Mensah', '1993-04-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Bernard' AND last_name = 'Kyei-Mensah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-bernard-kyei-mensah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Bernard' AND per.last_name = 'Kyei-Mensah' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Imoro', 'latif', '1998-03-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Imoro' AND last_name = 'latif' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-imoro-latif', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Imoro' AND per.last_name = 'latif' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Trinidad', 'Maldonado', '2006-11-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Trinidad' AND last_name = 'Maldonado' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-trinidad-maldonado', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Trinidad' AND per.last_name = 'Maldonado' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Landon', 'Neison', '2007-01-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Landon' AND last_name = 'Neison' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-landon-neison', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Landon' AND per.last_name = 'Neison' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Richard', 'Sarpong', '1993-04-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Richard' AND last_name = 'Sarpong' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-richard-sarpong', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Richard' AND per.last_name = 'Sarpong' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kwamina', 'Thompson', '1990-03-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kwamina' AND last_name = 'Thompson' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-kwamina-thompson', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kwamina' AND per.last_name = 'Thompson' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Patrick', 'Tierney', '2003-12-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Patrick' AND last_name = 'Tierney' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-patrick-tierney', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Patrick' AND per.last_name = 'Tierney' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Logan', 'Brock', '2006-10-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Logan' AND last_name = 'Brock' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philly-blackstars-logan-brock', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Logan' AND per.last_name = 'Brock' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Eljo', 'Agolli', '2003-01-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Eljo' AND last_name = 'Agolli' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-eljo-agolli', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Eljo' AND per.last_name = 'Agolli' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Carlos', 'Aroche', '2002-12-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Carlos' AND last_name = 'Aroche' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-carlos-aroche', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Carlos' AND per.last_name = 'Aroche' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jayden', 'Barragan', '2004-10-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jayden' AND last_name = 'Barragan' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-jayden-barragan', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jayden' AND per.last_name = 'Barragan' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christian', 'Cardenas', '2002-11-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Christian' AND last_name = 'Cardenas' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-christian-cardenas', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christian' AND per.last_name = 'Cardenas' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ermal', 'Caushi', '1986-02-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ermal' AND last_name = 'Caushi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-ermal-caushi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ermal' AND per.last_name = 'Caushi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ilir', 'Cepani', '1984-11-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ilir' AND last_name = 'Cepani' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-ilir-cepani', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ilir' AND per.last_name = 'Cepani' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Klevisi', 'Dervishi', '2005-05-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Klevisi' AND last_name = 'Dervishi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-klevisi-dervishi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Klevisi' AND per.last_name = 'Dervishi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sidiki', 'Fofana', '2002-01-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sidiki' AND last_name = 'Fofana' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-sidiki-fofana', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sidiki' AND per.last_name = 'Fofana' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Evlad', 'Fonda', '2002-02-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Evlad' AND last_name = 'Fonda' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-evlad-fonda', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Evlad' AND per.last_name = 'Fonda' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Zakaria', 'Gueddar', '2007-04-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Zakaria' AND last_name = 'Gueddar' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-zakaria-gueddar', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Zakaria' AND per.last_name = 'Gueddar' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gavin', 'Hagen', '2004-02-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gavin' AND last_name = 'Hagen' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-gavin-hagen', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gavin' AND per.last_name = 'Hagen' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mario', 'Kureta', '1997-04-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mario' AND last_name = 'Kureta' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-mario-kureta', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mario' AND per.last_name = 'Kureta' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Olen', 'Laze', '1984-05-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Olen' AND last_name = 'Laze' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-olen-laze', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Olen' AND per.last_name = 'Laze' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mario', 'Morina', '1995-05-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mario' AND last_name = 'Morina' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-mario-morina', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mario' AND per.last_name = 'Morina' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ramadan', 'Nazeraj', '1983-01-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ramadan' AND last_name = 'Nazeraj' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-ramadan-nazeraj', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ramadan' AND per.last_name = 'Nazeraj' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Youssef', 'Omer', '2004-08-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Youssef' AND last_name = 'Omer' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-youssef-omer', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Youssef' AND per.last_name = 'Omer' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Eldion', 'Pajollari', '1984-05-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Eldion' AND last_name = 'Pajollari' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-eldion-pajollari', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Eldion' AND per.last_name = 'Pajollari' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Albion', 'Pajollari', '2006-10-31') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Albion' AND last_name = 'Pajollari' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-albion-pajollari', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Albion' AND per.last_name = 'Pajollari' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Elsion', 'Pajollari', '1987-02-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Elsion' AND last_name = 'Pajollari' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-elsion-pajollari', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Elsion' AND per.last_name = 'Pajollari' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Brahim', 'Saouid', '2002-08-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Brahim' AND last_name = 'Saouid' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-brahim-saouid', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Brahim' AND per.last_name = 'Saouid' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Temur', 'Temirov', '2006-07-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Temur' AND last_name = 'Temirov' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-temur-temirov', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Temur' AND per.last_name = 'Temirov' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Achilles', 'Triantafyllos', '2004-10-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Achilles' AND last_name = 'Triantafyllos' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-achilles-triantafyllos', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Achilles' AND per.last_name = 'Triantafyllos' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Brendan', 'Werner', '2002-02-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Brendan' AND last_name = 'Werner' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'illyrians-fc-brendan-werner', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Brendan' AND per.last_name = 'Werner' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Victor', 'Baidel', '2004-09-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Victor' AND last_name = 'Baidel' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-victor-baidel', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Victor' AND per.last_name = 'Baidel' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Weder', 'Barretos', '2000-11-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Weder' AND last_name = 'Barretos' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-weder-barretos', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Weder' AND per.last_name = 'Barretos' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Aboubacar', 'Bayo', '2006-05-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Aboubacar' AND last_name = 'Bayo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-aboubacar-bayo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Aboubacar' AND per.last_name = 'Bayo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Igor', 'Bonfim', '1991-10-16') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Igor' AND last_name = 'Bonfim' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-igor-bonfim', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Igor' AND per.last_name = 'Bonfim' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Samuel', 'Botelho', '1997-01-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Samuel' AND last_name = 'Botelho' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-samuel-botelho', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Samuel' AND per.last_name = 'Botelho' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Inaldo', 'Botelho', '1991-05-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Inaldo' AND last_name = 'Botelho' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-inaldo-botelho', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Inaldo' AND per.last_name = 'Botelho' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Luke', 'Breslin', '2005-08-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Luke' AND last_name = 'Breslin' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-luke-breslin', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Luke' AND per.last_name = 'Breslin' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Walter', 'Candido', '1992-08-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Walter' AND last_name = 'Candido' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-walter-candido', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Walter' AND per.last_name = 'Candido' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christopher', 'Da Silva', '2004-05-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Christopher' AND last_name = 'Da Silva' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-christopher-da-silva', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christopher' AND per.last_name = 'Da Silva' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Nycolas', 'De Jesus', '1998-03-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Nycolas' AND last_name = 'De Jesus' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-nycolas-de-jesus', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Nycolas' AND per.last_name = 'De Jesus' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Lucas', 'De Morais', '1995-01-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Lucas' AND last_name = 'De Morais' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-lucas-de-morais', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Lucas' AND per.last_name = 'De Morais' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Abdoul', 'Diallo', '2006-06-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Abdoul' AND last_name = 'Diallo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-abdoul-diallo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Abdoul' AND per.last_name = 'Diallo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Cloves', 'Filho', '1997-12-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cloves' AND last_name = 'Filho' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-cloves-filho', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cloves' AND per.last_name = 'Filho' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Abouya', 'Gangue', '2003-10-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Abouya' AND last_name = 'Gangue' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-abouya-gangue', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Abouya' AND per.last_name = 'Gangue' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Andy', 'Hizdri', '2005-02-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Andy' AND last_name = 'Hizdri' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-andy-hizdri', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Andy' AND per.last_name = 'Hizdri' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alexander', 'Lara', '1997-08-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alexander' AND last_name = 'Lara' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-alexander-lara', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alexander' AND per.last_name = 'Lara' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Pedro', 'Lara', '1999-02-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Pedro' AND last_name = 'Lara' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-pedro-lara', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Pedro' AND per.last_name = 'Lara' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Reginaldo', 'Leite', '1981-10-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Reginaldo' AND last_name = 'Leite' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-reginaldo-leite', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Reginaldo' AND per.last_name = 'Leite' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Valentino', 'Martinez', '2002-10-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Valentino' AND last_name = 'Martinez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-valentino-martinez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Valentino' AND per.last_name = 'Martinez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('David', 'Masi', '2002-07-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'David' AND last_name = 'Masi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-david-masi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'David' AND per.last_name = 'Masi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('John', 'Oladele', '2000-06-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'John' AND last_name = 'Oladele' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-john-oladele', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'John' AND per.last_name = 'Oladele' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Junior', 'Oliveira', '1993-09-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Junior' AND last_name = 'Oliveira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-junior-oliveira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Junior' AND per.last_name = 'Oliveira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christian', 'Oliveira', '1998-10-21') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Christian' AND last_name = 'Oliveira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-christian-oliveira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christian' AND per.last_name = 'Oliveira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jemirkel', 'Ornaque', '1995-08-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jemirkel' AND last_name = 'Ornaque' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-jemirkel-ornaque', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jemirkel' AND per.last_name = 'Ornaque' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marcos', 'Ribeiro', '2000-09-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marcos' AND last_name = 'Ribeiro' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-marcos-ribeiro', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marcos' AND per.last_name = 'Ribeiro' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Denis', 'Sousa', '1999-12-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Denis' AND last_name = 'Sousa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-denis-sousa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Denis' AND per.last_name = 'Sousa' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Esnayder', 'Josue', '1998-04-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Esnayder' AND last_name = 'Josue' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-esnayder-josue', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Esnayder' AND per.last_name = 'Josue' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Majid', 'Kawa', '2001-12-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Majid' AND last_name = 'Kawa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-majid-kawa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Majid' AND per.last_name = 'Kawa' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Hamid', 'Afolabi', '2003-01-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Hamid' AND last_name = 'Afolabi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-hamid-afolabi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Hamid' AND per.last_name = 'Afolabi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Bassam', 'Ahmed', '2005-03-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Bassam' AND last_name = 'Ahmed' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-bassam-ahmed', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Bassam' AND per.last_name = 'Ahmed' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Clement', 'Atebi', '2007-09-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Clement' AND last_name = 'Atebi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-clement-atebi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Clement' AND per.last_name = 'Atebi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Nicholas', 'Bowman', '2001-07-31') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Nicholas' AND last_name = 'Bowman' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-nicholas-bowman', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Nicholas' AND per.last_name = 'Bowman' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Donavan', 'Brady', '1999-04-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Donavan' AND last_name = 'Brady' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-donavan-brady', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Donavan' AND per.last_name = 'Brady' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Uriel', 'Cabello', '1994-09-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Uriel' AND last_name = 'Cabello' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-uriel-cabello', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Uriel' AND per.last_name = 'Cabello' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Clarence', 'Cole', '2005-03-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Clarence' AND last_name = 'Cole' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-clarence-cole', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Clarence' AND per.last_name = 'Cole' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Joseph', 'Cunningham', '1996-06-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Joseph' AND last_name = 'Cunningham' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-joseph-cunningham', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Joseph' AND per.last_name = 'Cunningham' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Erick', 'David', '2004-07-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Erick' AND last_name = 'David' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-erick-david', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Erick' AND per.last_name = 'David' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Tushaar', 'Godbole', '1995-04-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Tushaar' AND last_name = 'Godbole' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-tushaar-godbole', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Tushaar' AND per.last_name = 'Godbole' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Benjamin', 'Goudvis', '2000-05-16') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Benjamin' AND last_name = 'Goudvis' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-benjamin-goudvis', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Benjamin' AND per.last_name = 'Goudvis' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jesse', 'Haines', '1999-03-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jesse' AND last_name = 'Haines' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-jesse-haines', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jesse' AND per.last_name = 'Haines' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Evan', 'Hodulik', '1994-01-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Evan' AND last_name = 'Hodulik' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-evan-hodulik', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Evan' AND per.last_name = 'Hodulik' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Francis', 'Kanu', '1999-07-21') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Francis' AND last_name = 'Kanu' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-francis-kanu', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Francis' AND per.last_name = 'Kanu' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alex', 'Kebuz', '2004-08-23') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alex' AND last_name = 'Kebuz' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-alex-kebuz', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alex' AND per.last_name = 'Kebuz' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sean', 'Khazael', '1994-02-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sean' AND last_name = 'Khazael' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-sean-khazael', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sean' AND per.last_name = 'Khazael' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Osman', 'Lopez', '2003-12-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Osman' AND last_name = 'Lopez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-osman-lopez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Osman' AND per.last_name = 'Lopez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Payman', 'Mirzaei', '1996-09-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Payman' AND last_name = 'Mirzaei' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-payman-mirzaei', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Payman' AND per.last_name = 'Mirzaei' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jevin', 'Nathaniel', '1996-04-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jevin' AND last_name = 'Nathaniel' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-jevin-nathaniel', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jevin' AND per.last_name = 'Nathaniel' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Armando', 'Samukai', '2002-09-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Armando' AND last_name = 'Samukai' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-armando-samukai', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Armando' AND per.last_name = 'Samukai' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Michael', 'Sottle', '1997-08-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Michael' AND last_name = 'Sottle' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-michael-sottle', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Michael' AND per.last_name = 'Sottle' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Boubacar', 'Traire', '2004-02-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Boubacar' AND last_name = 'Traire' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'persepolis-united-fc-ii-boubacar-traire', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Boubacar' AND per.last_name = 'Traire' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Hassane', 'Abdellaoui', '1999-07-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Hassane' AND last_name = 'Abdellaoui' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-hassane-abdellaoui', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Hassane' AND per.last_name = 'Abdellaoui' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Erwa', 'Babiker', '1996-01-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Erwa' AND last_name = 'Babiker' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-erwa-babiker', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Erwa' AND per.last_name = 'Babiker' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Oumar', 'Barry', '2003-10-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Oumar' AND last_name = 'Barry' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-oumar-barry', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Oumar' AND per.last_name = 'Barry' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Logan', 'Bersani', '1998-06-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Logan' AND last_name = 'Bersani' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-logan-bersani', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Logan' AND per.last_name = 'Bersani' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('James', 'Breslin', '1972-07-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'James' AND last_name = 'Breslin' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-james-breslin', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'James' AND per.last_name = 'Breslin' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Luis', 'De Jesus', '2007-04-16') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Luis' AND last_name = 'De Jesus' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-luis-de-jesus', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Luis' AND per.last_name = 'De Jesus' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marco', 'Delgado', '2001-12-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marco' AND last_name = 'Delgado' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-marco-delgado', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marco' AND per.last_name = 'Delgado' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Edwin', 'Garcia', '2006-02-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Edwin' AND last_name = 'Garcia' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-edwin-garcia', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Edwin' AND per.last_name = 'Garcia' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('John', 'Gonzalez', '2000-01-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'John' AND last_name = 'Gonzalez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-john-gonzalez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'John' AND per.last_name = 'Gonzalez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sangin', 'Hedayatullah', '2007-07-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sangin' AND last_name = 'Hedayatullah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-sangin-hedayatullah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sangin' AND per.last_name = 'Hedayatullah' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Miles', 'Henry', '2000-06-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Miles' AND last_name = 'Henry' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-miles-henry', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Miles' AND per.last_name = 'Henry' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Arif', 'Hossain', '2003-12-31') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Arif' AND last_name = 'Hossain' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-arif-hossain', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Arif' AND per.last_name = 'Hossain' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Zuhab', 'Imran', '2006-10-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Zuhab' AND last_name = 'Imran' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-zuhab-imran', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Zuhab' AND per.last_name = 'Imran' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Carl', 'Laroche', '1996-10-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Carl' AND last_name = 'Laroche' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-carl-laroche', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Carl' AND per.last_name = 'Laroche' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jervin', 'Lemus', '2007-06-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jervin' AND last_name = 'Lemus' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-jervin-lemus', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jervin' AND per.last_name = 'Lemus' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christian', 'Lopez', '2007-06-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Christian' AND last_name = 'Lopez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-christian-lopez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christian' AND per.last_name = 'Lopez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('John', 'Madureira', '2006-12-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'John' AND last_name = 'Madureira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-john-madureira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'John' AND per.last_name = 'Madureira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Elmer', 'Mendoza', '2003-08-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Elmer' AND last_name = 'Mendoza' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-elmer-mendoza', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Elmer' AND per.last_name = 'Mendoza' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Dylan', 'Moreno', '2005-02-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Dylan' AND last_name = 'Moreno' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-dylan-moreno', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Dylan' AND per.last_name = 'Moreno' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ibrahim', 'Nassar', '1993-06-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ibrahim' AND last_name = 'Nassar' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-ibrahim-nassar', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ibrahim' AND per.last_name = 'Nassar' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Babacar', 'Ndiaye', '2005-02-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Babacar' AND last_name = 'Ndiaye' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-babacar-ndiaye', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Babacar' AND per.last_name = 'Ndiaye' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Zion', 'Nwalipenja', '2005-01-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Zion' AND last_name = 'Nwalipenja' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-zion-nwalipenja', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Zion' AND per.last_name = 'Nwalipenja' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Fabian', 'Padilla', '1995-11-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Fabian' AND last_name = 'Padilla' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-fabian-padilla', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Fabian' AND per.last_name = 'Padilla' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Caleb', 'Rojas', '2001-12-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Caleb' AND last_name = 'Rojas' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-caleb-rojas', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Caleb' AND per.last_name = 'Rojas' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Anthony', 'Sagustume', '1995-07-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Anthony' AND last_name = 'Sagustume' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-anthony-sagustume', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Anthony' AND per.last_name = 'Sagustume' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ali', 'Salah', '2007-03-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ali' AND last_name = 'Salah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-ali-salah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ali' AND per.last_name = 'Salah' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Daniel', 'Salmanca', '2007-07-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Daniel' AND last_name = 'Salmanca' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-daniel-salmanca', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Daniel' AND per.last_name = 'Salmanca' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Leo', 'Santa', '1977-12-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Leo' AND last_name = 'Santa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-leo-santa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Leo' AND per.last_name = 'Santa' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christopher', 'Solis', '2005-10-21') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Christopher' AND last_name = 'Solis' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-old-timers-club-christopher-solis', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christopher' AND per.last_name = 'Solis' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Fritz', 'Amazan', '2000-06-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Fritz' AND last_name = 'Amazan' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-fritz-amazan', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Fritz' AND per.last_name = 'Amazan' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('David', 'Aquino', '2004-04-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'David' AND last_name = 'Aquino' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-david-aquino', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'David' AND per.last_name = 'Aquino' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christian', 'Aurand', '2000-11-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Christian' AND last_name = 'Aurand' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-christian-aurand', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christian' AND per.last_name = 'Aurand' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('TJ', 'Butler', '2002-02-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'TJ' AND last_name = 'Butler' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-tj-butler', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'TJ' AND per.last_name = 'Butler' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Troy', 'Eutermoser', '1996-06-23') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Troy' AND last_name = 'Eutermoser' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-troy-eutermoser', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Troy' AND per.last_name = 'Eutermoser' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alex', 'Freeman', '2004-06-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alex' AND last_name = 'Freeman' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-alex-freeman', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alex' AND per.last_name = 'Freeman' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('William', 'Hanratty', '2000-01-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'William' AND last_name = 'Hanratty' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-william-hanratty', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'William' AND per.last_name = 'Hanratty' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ryan', 'Kerr', '2004-03-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ryan' AND last_name = 'Kerr' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-ryan-kerr', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ryan' AND per.last_name = 'Kerr' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jake', 'Kucowski', '2000-08-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jake' AND last_name = 'Kucowski' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-jake-kucowski', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jake' AND per.last_name = 'Kucowski' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Rood charleson', 'Labossiere', '1995-04-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Rood charleson' AND last_name = 'Labossiere' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-rood-charleson-labossiere', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Rood charleson' AND per.last_name = 'Labossiere' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ed-steeve', 'Madere', '2001-08-31') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ed-steeve' AND last_name = 'Madere' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-ed-steeve-madere', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ed-steeve' AND per.last_name = 'Madere' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Daniel', 'Maggio', '1999-02-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Daniel' AND last_name = 'Maggio' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-daniel-maggio', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Daniel' AND per.last_name = 'Maggio' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christopher', 'McDonnell', '1998-09-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Christopher' AND last_name = 'McDonnell' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-christopher-mcdonnell', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christopher' AND per.last_name = 'McDonnell' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Merabi', 'Megreladze', '1999-10-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Merabi' AND last_name = 'Megreladze' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-merabi-megreladze', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Merabi' AND per.last_name = 'Megreladze' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marc Jerry', 'Midy', '2002-08-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marc Jerry' AND last_name = 'Midy' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-marc-jerry-midy', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marc Jerry' AND per.last_name = 'Midy' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Giorgi', 'Nikabadze', '2003-10-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Giorgi' AND last_name = 'Nikabadze' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-giorgi-nikabadze', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Giorgi' AND per.last_name = 'Nikabadze' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Fran', 'Pitonyak', '1982-08-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Fran' AND last_name = 'Pitonyak' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-fran-pitonyak', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Fran' AND per.last_name = 'Pitonyak' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Chris', 'Rutledge', '1994-03-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Chris' AND last_name = 'Rutledge' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-chris-rutledge', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Chris' AND per.last_name = 'Rutledge' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Revazi', 'Tcheshmaritashvili', '1993-05-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Revazi' AND last_name = 'Tcheshmaritashvili' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-revazi-tcheshmaritashvili', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Revazi' AND per.last_name = 'Tcheshmaritashvili' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Nick', 'Webster', '1992-11-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Nick' AND last_name = 'Webster' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'phoenix-scr-nick-webster', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Nick' AND per.last_name = 'Webster' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Costas', 'Angelis', '1999-06-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Costas' AND last_name = 'Angelis' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-costas-angelis', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Costas' AND per.last_name = 'Angelis' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jesus', 'Colin', '2004-10-16') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jesus' AND last_name = 'Colin' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-jesus-colin', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jesus' AND per.last_name = 'Colin' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Bryan', 'Da Silva', NULL) 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Bryan' AND last_name = 'Da Silva' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-bryan-da-silva', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Bryan' AND per.last_name = 'Da Silva' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Yoofi', 'Danquah', '2004-05-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Yoofi' AND last_name = 'Danquah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-yoofi-danquah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Yoofi' AND per.last_name = 'Danquah' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Bryan', 'De Quadros', '2004-12-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Bryan' AND last_name = 'De Quadros' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-bryan-de-quadros', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Bryan' AND per.last_name = 'De Quadros' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Robert', 'Ertel', '1993-09-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Robert' AND last_name = 'Ertel' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-robert-ertel', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Robert' AND per.last_name = 'Ertel' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Julio', 'Evangilista', '2006-10-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Julio' AND last_name = 'Evangilista' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-julio-evangilista', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Julio' AND per.last_name = 'Evangilista' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ahmed', 'Faik', '1991-04-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ahmed' AND last_name = 'Faik' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-ahmed-faik', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ahmed' AND per.last_name = 'Faik' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kaua', 'Freitas', NULL) 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kaua' AND last_name = 'Freitas' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-kaua-freitas', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kaua' AND per.last_name = 'Freitas' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kareem', 'Green', '1998-10-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kareem' AND last_name = 'Green' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-kareem-green', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kareem' AND per.last_name = 'Green' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Nigel', 'Johnson', '1997-12-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Nigel' AND last_name = 'Johnson' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-nigel-johnson', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Nigel' AND per.last_name = 'Johnson' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Paul', 'Kwoyelo', '1990-01-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Paul' AND last_name = 'Kwoyelo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-paul-kwoyelo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Paul' AND per.last_name = 'Kwoyelo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jonatan', 'Lopez', '2004-11-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jonatan' AND last_name = 'Lopez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-jonatan-lopez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jonatan' AND per.last_name = 'Lopez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Zach', 'Morrison', '2002-02-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Zach' AND last_name = 'Morrison' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-zach-morrison', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Zach' AND per.last_name = 'Morrison' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Diego', 'Murillo', '2005-07-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Diego' AND last_name = 'Murillo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-diego-murillo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Diego' AND per.last_name = 'Murillo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Paolo', 'Musumeci', '2004-04-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Paolo' AND last_name = 'Musumeci' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-paolo-musumeci', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Paolo' AND per.last_name = 'Musumeci' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Zabi', 'Naseri', '1994-02-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Zabi' AND last_name = 'Naseri' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-zabi-naseri', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Zabi' AND per.last_name = 'Naseri' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Roni', 'Rountree', '2000-11-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Roni' AND last_name = 'Rountree' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-roni-rountree', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Roni' AND per.last_name = 'Rountree' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Luca', 'Ruggiero', '1991-08-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Luca' AND last_name = 'Ruggiero' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-luca-ruggiero', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Luca' AND per.last_name = 'Ruggiero' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mohammad', 'Sanim', NULL) 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mohammad' AND last_name = 'Sanim' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-mohammad-sanim', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mohammad' AND per.last_name = 'Sanim' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Aaron', 'Sexton', '1997-06-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Aaron' AND last_name = 'Sexton' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-aaron-sexton', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Aaron' AND per.last_name = 'Sexton' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Lamin', 'Sidibeh', '1989-05-31') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Lamin' AND last_name = 'Sidibeh' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-lamin-sidibeh', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Lamin' AND per.last_name = 'Sidibeh' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Anis', 'Slimane', '2000-06-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Anis' AND last_name = 'Slimane' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-anis-slimane', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Anis' AND per.last_name = 'Slimane' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Casey', 'Sorell', '2000-10-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Casey' AND last_name = 'Sorell' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-casey-sorell', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Casey' AND per.last_name = 'Sorell' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Cavit', 'ULA', '1996-05-16') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cavit' AND last_name = 'ULA' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-cavit-ula', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cavit' AND per.last_name = 'ULA' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Thiago', 'Vazquez', '2003-02-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Thiago' AND last_name = 'Vazquez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-thiago-vazquez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Thiago' AND per.last_name = 'Vazquez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sergio', 'Villanueva', '2001-03-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sergio' AND last_name = 'Villanueva' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-sergio-villanueva', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sergio' AND per.last_name = 'Villanueva' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Michael', 'Wambold', NULL) 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Michael' AND last_name = 'Wambold' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-michael-wambold', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Michael' AND per.last_name = 'Wambold' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Phillip', 'Washington', '2001-07-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Phillip' AND last_name = 'Washington' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'philadelphia-sc-select-phillip-washington', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Phillip' AND per.last_name = 'Washington' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Michael', 'Abarca', '1991-02-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Michael' AND last_name = 'Abarca' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-michael-abarca', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Michael' AND per.last_name = 'Abarca' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Victor', 'Agudelo', '1984-12-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Victor' AND last_name = 'Agudelo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-victor-agudelo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Victor' AND per.last_name = 'Agudelo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jonatan', 'Alberto', '1985-05-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jonatan' AND last_name = 'Alberto' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-jonatan-alberto', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jonatan' AND per.last_name = 'Alberto' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Colon', 'Anthony', '2003-11-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Colon' AND last_name = 'Anthony' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-colon-anthony', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Colon' AND per.last_name = 'Anthony' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Diego', 'Beltran Vega', '1984-08-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Diego' AND last_name = 'Beltran Vega' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-diego-beltran-vega', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Diego' AND per.last_name = 'Beltran Vega' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Johan', 'Bolton', '1989-05-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Johan' AND last_name = 'Bolton' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-johan-bolton', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Johan' AND per.last_name = 'Bolton' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Manuel', 'Camayo', '1988-09-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Manuel' AND last_name = 'Camayo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-manuel-camayo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Manuel' AND per.last_name = 'Camayo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Errol', 'Castro', '1990-12-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Errol' AND last_name = 'Castro' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-errol-castro', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Errol' AND per.last_name = 'Castro' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Carlos', 'Chacon', '1999-09-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Carlos' AND last_name = 'Chacon' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-carlos-chacon', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Carlos' AND per.last_name = 'Chacon' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jose', 'Duarte', '1981-03-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jose' AND last_name = 'Duarte' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-jose-duarte', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jose' AND per.last_name = 'Duarte' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Arnoldo', 'Emeiler', '2000-07-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Arnoldo' AND last_name = 'Emeiler' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-arnoldo-emeiler', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Arnoldo' AND per.last_name = 'Emeiler' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Balron', 'Escobar', '2002-09-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Balron' AND last_name = 'Escobar' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-balron-escobar', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Balron' AND per.last_name = 'Escobar' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marcelo', 'Gamboa', '1995-10-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marcelo' AND last_name = 'Gamboa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-marcelo-gamboa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marcelo' AND per.last_name = 'Gamboa' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Miguel', 'Garcia', '1997-10-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Miguel' AND last_name = 'Garcia' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-miguel-garcia', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Miguel' AND per.last_name = 'Garcia' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Juan Carlos', 'Guevara', '1985-03-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Juan Carlos' AND last_name = 'Guevara' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-juan-carlos-guevara', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Juan Carlos' AND per.last_name = 'Guevara' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gustavo', 'Guitierez Cuervo', '1992-04-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gustavo' AND last_name = 'Guitierez Cuervo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-gustavo-guitierez-cuervo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gustavo' AND per.last_name = 'Guitierez Cuervo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Fabricio', 'Guzman', '2004-07-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Fabricio' AND last_name = 'Guzman' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-fabricio-guzman', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Fabricio' AND per.last_name = 'Guzman' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Smaikel Sibaja', 'Guzman', '1998-09-21') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Smaikel Sibaja' AND last_name = 'Guzman' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-smaikel-sibaja-guzman', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Smaikel Sibaja' AND per.last_name = 'Guzman' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Eder', 'Guzman', '1982-01-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Eder' AND last_name = 'Guzman' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-eder-guzman', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Eder' AND per.last_name = 'Guzman' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Danior', 'Hernandez', '1995-02-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Danior' AND last_name = 'Hernandez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-danior-hernandez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Danior' AND per.last_name = 'Hernandez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Yerald', 'Jimenez', '2001-02-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Yerald' AND last_name = 'Jimenez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-yerald-jimenez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Yerald' AND per.last_name = 'Jimenez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Maicol', 'Martinez', '1982-12-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Maicol' AND last_name = 'Martinez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-maicol-martinez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Maicol' AND per.last_name = 'Martinez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Obed', 'Mayorga Curtis', '1987-10-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Obed' AND last_name = 'Mayorga Curtis' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-obed-mayorga-curtis', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Obed' AND per.last_name = 'Mayorga Curtis' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Melber', 'Ortega', '2001-10-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Melber' AND last_name = 'Ortega' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-melber-ortega', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Melber' AND per.last_name = 'Ortega' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gelder', 'Ortiz', '1994-05-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gelder' AND last_name = 'Ortiz' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-gelder-ortiz', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gelder' AND per.last_name = 'Ortiz' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Joseph', 'Piedra Retana', '1998-01-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Joseph' AND last_name = 'Piedra Retana' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-joseph-piedra-retana', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Joseph' AND per.last_name = 'Piedra Retana' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Luis', 'Retana', '2000-10-21') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Luis' AND last_name = 'Retana' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-luis-retana', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Luis' AND per.last_name = 'Retana' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ronny', 'Rodriquez', '1993-12-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ronny' AND last_name = 'Rodriquez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-ronny-rodriquez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ronny' AND per.last_name = 'Rodriquez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alexander', 'Rodriquez', '1999-12-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alexander' AND last_name = 'Rodriquez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-alexander-rodriquez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alexander' AND per.last_name = 'Rodriquez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Andres', 'Rojas', '2003-08-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Andres' AND last_name = 'Rojas' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-andres-rojas', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Andres' AND per.last_name = 'Rojas' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kenneth', 'Salazar', '2000-01-21') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kenneth' AND last_name = 'Salazar' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-kenneth-salazar', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kenneth' AND per.last_name = 'Salazar' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Adilcer', 'Santiago', '2003-08-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Adilcer' AND last_name = 'Santiago' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-adilcer-santiago', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Adilcer' AND per.last_name = 'Santiago' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Axel', 'Villanueva', '1993-10-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Axel' AND last_name = 'Villanueva' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-axel-villanueva', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Axel' AND per.last_name = 'Villanueva' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sergio', 'Zuluaga', '1996-12-31') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sergio' AND last_name = 'Zuluaga' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'club-de-futbol-armada-sergio-zuluaga', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sergio' AND per.last_name = 'Zuluaga' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alexander', 'Garcia', '2006-06-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alexander' AND last_name = 'Garcia' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'sewell-s-old-boys-alexander-garcia', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alexander' AND per.last_name = 'Garcia' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jeshohaih', 'Hernandez', '2005-09-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jeshohaih' AND last_name = 'Hernandez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'sewell-s-old-boys-jeshohaih-hernandez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jeshohaih' AND per.last_name = 'Hernandez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Adam', 'Leal', '2006-02-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Adam' AND last_name = 'Leal' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'sewell-s-old-boys-adam-leal', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Adam' AND per.last_name = 'Leal' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alexander', 'Patton', '2006-02-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alexander' AND last_name = 'Patton' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'sewell-s-old-boys-alexander-patton', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alexander' AND per.last_name = 'Patton' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Fred', 'Renzulli', '2002-11-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Fred' AND last_name = 'Renzulli' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'sewell-s-old-boys-fred-renzulli', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Fred' AND per.last_name = 'Renzulli' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jackson', 'Stuetz', '2006-07-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jackson' AND last_name = 'Stuetz' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'sewell-s-old-boys-jackson-stuetz', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jackson' AND per.last_name = 'Stuetz' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Joseph', 'Romano', '2004-02-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Joseph' AND last_name = 'Romano' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'sewell-s-old-boys-joseph-romano', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Joseph' AND per.last_name = 'Romano' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Hector Ivan', 'Acosta', '1994-07-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Hector Ivan' AND last_name = 'Acosta' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-hector-ivan-acosta', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Hector Ivan' AND per.last_name = 'Acosta' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Yousef', 'Atrous', '2001-04-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Yousef' AND last_name = 'Atrous' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-yousef-atrous', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Yousef' AND per.last_name = 'Atrous' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('James', 'Barden', '2000-04-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'James' AND last_name = 'Barden' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-james-barden', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'James' AND per.last_name = 'Barden' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Oseche', 'Buliro', '2003-10-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Oseche' AND last_name = 'Buliro' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-oseche-buliro', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Oseche' AND per.last_name = 'Buliro' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('John', 'Burke', '2000-09-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'John' AND last_name = 'Burke' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-john-burke', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'John' AND per.last_name = 'Burke' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kevin', 'Callanan', '1998-11-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kevin' AND last_name = 'Callanan' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-kevin-callanan', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kevin' AND per.last_name = 'Callanan' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Michael', 'Chang', '1999-12-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Michael' AND last_name = 'Chang' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-michael-chang', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Michael' AND per.last_name = 'Chang' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Andrew', 'Cooke', '2001-09-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Andrew' AND last_name = 'Cooke' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-andrew-cooke', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Andrew' AND per.last_name = 'Cooke' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alex', 'Cooper-Hohn', '2001-06-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alex' AND last_name = 'Cooper-Hohn' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-alex-cooper-hohn', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alex' AND per.last_name = 'Cooper-Hohn' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Leon', 'Djusberg', '2000-03-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Leon' AND last_name = 'Djusberg' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-leon-djusberg', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Leon' AND per.last_name = 'Djusberg' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Trey', 'Donovan', '2000-11-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Trey' AND last_name = 'Donovan' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-trey-donovan', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Trey' AND per.last_name = 'Donovan' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Irobosa', 'Enabulele', '2000-07-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Irobosa' AND last_name = 'Enabulele' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-irobosa-enabulele', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Irobosa' AND per.last_name = 'Enabulele' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jack', 'Garrity', '2002-04-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jack' AND last_name = 'Garrity' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-jack-garrity', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jack' AND per.last_name = 'Garrity' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kevin', 'Gilligan', '1999-11-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kevin' AND last_name = 'Gilligan' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-kevin-gilligan', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kevin' AND per.last_name = 'Gilligan' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ian', 'Goodine', '1999-06-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ian' AND last_name = 'Goodine' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-ian-goodine', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ian' AND per.last_name = 'Goodine' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Trevor', 'Grafton', '2005-01-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Trevor' AND last_name = 'Grafton' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-trevor-grafton', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Trevor' AND per.last_name = 'Grafton' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Nicholas', 'Harper', '2000-03-23') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Nicholas' AND last_name = 'Harper' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-nicholas-harper', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Nicholas' AND per.last_name = 'Harper' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Josh', 'Harper', '2000-03-23') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Josh' AND last_name = 'Harper' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-josh-harper', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Josh' AND per.last_name = 'Harper' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('James', 'Helf', '1998-02-16') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'James' AND last_name = 'Helf' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-james-helf', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'James' AND per.last_name = 'Helf' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Lewis', 'Mustoe', '1998-03-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Lewis' AND last_name = 'Mustoe' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-lewis-mustoe', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Lewis' AND per.last_name = 'Mustoe' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Osasenaga', 'Owens', '2002-02-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Osasenaga' AND last_name = 'Owens' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-osasenaga-owens', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Osasenaga' AND per.last_name = 'Owens' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Nathan', 'Plano', '1999-03-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Nathan' AND last_name = 'Plano' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-nathan-plano', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Nathan' AND per.last_name = 'Plano' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jack', 'Sarkisian', '1999-04-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jack' AND last_name = 'Sarkisian' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-jack-sarkisian', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jack' AND per.last_name = 'Sarkisian' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Joaquin', 'Silvani', '2002-11-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Joaquin' AND last_name = 'Silvani' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-joaquin-silvani', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Joaquin' AND per.last_name = 'Silvani' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Stanislaus', 'Sokolov', '1999-05-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Stanislaus' AND last_name = 'Sokolov' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-stanislaus-sokolov', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Stanislaus' AND per.last_name = 'Sokolov' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kohei', 'Tomita', '1999-06-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kohei' AND last_name = 'Tomita' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-kohei-tomita', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kohei' AND per.last_name = 'Tomita' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Tomas', 'Trejo', '2001-09-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Tomas' AND last_name = 'Trejo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-tomas-trejo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Tomas' AND per.last_name = 'Trejo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Caleb', 'Weinstock', '1999-12-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Caleb' AND last_name = 'Weinstock' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'bcfc-all-stars-caleb-weinstock', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Caleb' AND per.last_name = 'Weinstock' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Moycir', 'Amarante', '2003-10-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Moycir' AND last_name = 'Amarante' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-moycir-amarante', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Moycir' AND per.last_name = 'Amarante' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ryan', 'Beardsley', '2001-10-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ryan' AND last_name = 'Beardsley' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-ryan-beardsley', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ryan' AND per.last_name = 'Beardsley' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Thomas', 'Bell', '1994-11-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Thomas' AND last_name = 'Bell' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-thomas-bell', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Thomas' AND per.last_name = 'Bell' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jaime', 'Cortez', '2006-09-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jaime' AND last_name = 'Cortez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-jaime-cortez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jaime' AND per.last_name = 'Cortez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jah', 'Cyrus', '1993-04-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jah' AND last_name = 'Cyrus' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-jah-cyrus', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jah' AND per.last_name = 'Cyrus' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Raney', 'Figueiredo', '2005-09-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Raney' AND last_name = 'Figueiredo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-raney-figueiredo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Raney' AND per.last_name = 'Figueiredo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Paolo', 'Filippi', '1997-12-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Paolo' AND last_name = 'Filippi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-paolo-filippi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Paolo' AND per.last_name = 'Filippi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alpha', 'Fofanah', '1997-09-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alpha' AND last_name = 'Fofanah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-alpha-fofanah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alpha' AND per.last_name = 'Fofanah' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Patrick', 'Freire', '2005-10-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Patrick' AND last_name = 'Freire' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-patrick-freire', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Patrick' AND per.last_name = 'Freire' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Matheus', 'Gomes', '2007-02-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Matheus' AND last_name = 'Gomes' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-matheus-gomes', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Matheus' AND per.last_name = 'Gomes' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ronnie', 'Gomez', '1997-02-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ronnie' AND last_name = 'Gomez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-ronnie-gomez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ronnie' AND per.last_name = 'Gomez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Matthew', 'Kearney', '1992-04-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Matthew' AND last_name = 'Kearney' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-matthew-kearney', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Matthew' AND per.last_name = 'Kearney' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ousmane', 'Keita', '1995-10-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ousmane' AND last_name = 'Keita' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-ousmane-keita', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ousmane' AND per.last_name = 'Keita' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('William', 'Martinez', '2006-07-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'William' AND last_name = 'Martinez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-william-martinez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'William' AND per.last_name = 'Martinez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ryan', 'McGourty', '2005-04-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ryan' AND last_name = 'McGourty' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-ryan-mcgourty', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ryan' AND per.last_name = 'McGourty' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Zion', 'Monteiro', '2004-03-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Zion' AND last_name = 'Monteiro' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-zion-monteiro', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Zion' AND per.last_name = 'Monteiro' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alejandro', 'Monterroso', '2006-12-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alejandro' AND last_name = 'Monterroso' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-alejandro-monterroso', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alejandro' AND per.last_name = 'Monterroso' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gracian', 'Moreira', '2004-06-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gracian' AND last_name = 'Moreira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-gracian-moreira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gracian' AND per.last_name = 'Moreira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Carlos', 'Neves', '2005-02-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Carlos' AND last_name = 'Neves' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-carlos-neves', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Carlos' AND per.last_name = 'Neves' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Lucas', 'Oliveira', '2006-10-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Lucas' AND last_name = 'Oliveira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-lucas-oliveira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Lucas' AND per.last_name = 'Oliveira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Felipe', 'Palacio', '2001-11-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Felipe' AND last_name = 'Palacio' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-felipe-palacio', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Felipe' AND per.last_name = 'Palacio' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Markelos', 'Papa', '2007-03-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Markelos' AND last_name = 'Papa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-markelos-papa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Markelos' AND per.last_name = 'Papa' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Angelos', 'Papa', '2003-06-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Angelos' AND last_name = 'Papa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-angelos-papa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Angelos' AND per.last_name = 'Papa' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Michael', 'Rendon', '1995-01-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Michael' AND last_name = 'Rendon' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-michael-rendon', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Michael' AND per.last_name = 'Rendon' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Edson', 'Robledano', '1992-03-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Edson' AND last_name = 'Robledano' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-edson-robledano', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Edson' AND per.last_name = 'Robledano' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('gustavo', 'sampaio', '2007-07-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'gustavo' AND last_name = 'sampaio' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-gustavo-sampaio', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'gustavo' AND per.last_name = 'sampaio' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Tjamael', 'Sillah', '2004-01-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Tjamael' AND last_name = 'Sillah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-tjamael-sillah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Tjamael' AND per.last_name = 'Sillah' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('William', 'Sousa', '2003-06-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'William' AND last_name = 'Sousa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-william-sousa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'William' AND per.last_name = 'Sousa' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Vlad', 'Ventura', '1998-06-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Vlad' AND last_name = 'Ventura' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-vlad-ventura', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Vlad' AND per.last_name = 'Ventura' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Albert', 'Williams', '1994-02-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Albert' AND last_name = 'Williams' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'flatley-fc-albert-williams', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Albert' AND per.last_name = 'Williams' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marouen', 'Ben Guebila', '1986-09-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marouen' AND last_name = 'Ben Guebila' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-marouen-ben-guebila', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marouen' AND per.last_name = 'Ben Guebila' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Muhammad Uzair', 'Butt', '1998-05-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Muhammad Uzair' AND last_name = 'Butt' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-muhammad-uzair-butt', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Muhammad Uzair' AND per.last_name = 'Butt' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Fredy', 'Castillo Hernandez', '1989-07-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Fredy' AND last_name = 'Castillo Hernandez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-fredy-castillo-hernandez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Fredy' AND per.last_name = 'Castillo Hernandez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ethan', 'Champlin', '2003-04-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ethan' AND last_name = 'Champlin' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-ethan-champlin', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ethan' AND per.last_name = 'Champlin' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kevin', 'De Leon', '2002-06-21') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kevin' AND last_name = 'De Leon' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-kevin-de-leon', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kevin' AND per.last_name = 'De Leon' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ian', 'Dhar', '2003-02-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ian' AND last_name = 'Dhar' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-ian-dhar', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ian' AND per.last_name = 'Dhar' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('William', 'Garcia', '1984-11-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'William' AND last_name = 'Garcia' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-william-garcia', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'William' AND per.last_name = 'Garcia' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Joshua', 'Hardester', '1981-09-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Joshua' AND last_name = 'Hardester' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-joshua-hardester', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Joshua' AND per.last_name = 'Hardester' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Norman', 'Jimenez Laverde', '1989-10-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Norman' AND last_name = 'Jimenez Laverde' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-norman-jimenez-laverde', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Norman' AND per.last_name = 'Jimenez Laverde' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Andrew', 'Lee', '1999-07-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Andrew' AND last_name = 'Lee' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-andrew-lee', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Andrew' AND per.last_name = 'Lee' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mateus', 'Loesch', '1992-10-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mateus' AND last_name = 'Loesch' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-mateus-loesch', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mateus' AND per.last_name = 'Loesch' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Austin', 'MBaye', '2002-05-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Austin' AND last_name = 'MBaye' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-austin-mbaye', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Austin' AND per.last_name = 'MBaye' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sam', 'McGrath', '1995-06-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sam' AND last_name = 'McGrath' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-sam-mcgrath', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sam' AND per.last_name = 'McGrath' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mike', 'Mizhirumbay', '2004-03-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mike' AND last_name = 'Mizhirumbay' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-mike-mizhirumbay', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mike' AND per.last_name = 'Mizhirumbay' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Leo', 'Mosquera', '1990-10-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Leo' AND last_name = 'Mosquera' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-leo-mosquera', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Leo' AND per.last_name = 'Mosquera' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Matt', 'Mourges', '1993-08-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Matt' AND last_name = 'Mourges' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-matt-mourges', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Matt' AND per.last_name = 'Mourges' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kevin', 'Ortiz', '1992-03-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kevin' AND last_name = 'Ortiz' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-kevin-ortiz', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kevin' AND per.last_name = 'Ortiz' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jose', 'Osorto', '1997-12-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jose' AND last_name = 'Osorto' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-jose-osorto', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jose' AND per.last_name = 'Osorto' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Haorui', 'Qin', '2007-06-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Haorui' AND last_name = 'Qin' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-haorui-qin', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Haorui' AND per.last_name = 'Qin' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Daniel', 'Ra', '1992-10-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Daniel' AND last_name = 'Ra' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-daniel-ra', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Daniel' AND per.last_name = 'Ra' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ethan', 'Rowe', '1999-09-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ethan' AND last_name = 'Rowe' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-ethan-rowe', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ethan' AND per.last_name = 'Rowe' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Rafael', 'Santos', '1989-04-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Rafael' AND last_name = 'Santos' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-rafael-santos', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Rafael' AND per.last_name = 'Santos' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Harrison', 'Snodgrass', '1993-06-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Harrison' AND last_name = 'Snodgrass' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-harrison-snodgrass', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Harrison' AND per.last_name = 'Snodgrass' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marshall', 'Tekell', '1996-01-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marshall' AND last_name = 'Tekell' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-marshall-tekell', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marshall' AND per.last_name = 'Tekell' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jose', 'Velazquez', '1997-12-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jose' AND last_name = 'Velazquez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'gambeta-fc-jose-velazquez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jose' AND per.last_name = 'Velazquez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gabriel', 'Barbosa', '2004-01-31') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gabriel' AND last_name = 'Barbosa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-gabriel-barbosa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gabriel' AND per.last_name = 'Barbosa' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Juliano', 'Bento', '1996-09-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Juliano' AND last_name = 'Bento' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-juliano-bento', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Juliano' AND per.last_name = 'Bento' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Andrés', 'Bustamante', '1996-02-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Andrés' AND last_name = 'Bustamante' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-andres-bustamante', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Andrés' AND per.last_name = 'Bustamante' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Itamar', 'Caldeira', '2000-05-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Itamar' AND last_name = 'Caldeira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-itamar-caldeira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Itamar' AND per.last_name = 'Caldeira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Vinicius', 'De Oliveira', '2005-04-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Vinicius' AND last_name = 'De Oliveira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-vinicius-de-oliveira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Vinicius' AND per.last_name = 'De Oliveira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('William', 'Dos Santos', '2000-07-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'William' AND last_name = 'Dos Santos' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-william-dos-santos', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'William' AND per.last_name = 'Dos Santos' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Leonardo', 'Fortunato', '1994-12-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Leonardo' AND last_name = 'Fortunato' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-leonardo-fortunato', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Leonardo' AND per.last_name = 'Fortunato' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Lucas', 'Franco', '1998-08-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Lucas' AND last_name = 'Franco' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-lucas-franco', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Lucas' AND per.last_name = 'Franco' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Javier', 'Garcia', '2000-09-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Javier' AND last_name = 'Garcia' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-javier-garcia', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Javier' AND per.last_name = 'Garcia' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('edson', 'junior', '2003-01-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'edson' AND last_name = 'junior' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-edson-junior', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'edson' AND per.last_name = 'junior' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Diego', 'Lorett', '1997-03-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Diego' AND last_name = 'Lorett' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-diego-lorett', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Diego' AND per.last_name = 'Lorett' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Vitor', 'Magalhaes', '2004-03-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Vitor' AND last_name = 'Magalhaes' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-vitor-magalhaes', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Vitor' AND per.last_name = 'Magalhaes' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Juann', 'Melo', '2001-10-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Juann' AND last_name = 'Melo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-juann-melo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Juann' AND per.last_name = 'Melo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Frank', 'Messina', '1997-04-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Frank' AND last_name = 'Messina' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-frank-messina', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Frank' AND per.last_name = 'Messina' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sidnei', 'Monteiro', '1982-02-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sidnei' AND last_name = 'Monteiro' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-sidnei-monteiro', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sidnei' AND per.last_name = 'Monteiro' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jefferson', 'Oliveira', '1995-07-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jefferson' AND last_name = 'Oliveira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-jefferson-oliveira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jefferson' AND per.last_name = 'Oliveira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Lenine', 'Pereira', '1995-12-31') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Lenine' AND last_name = 'Pereira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-lenine-pereira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Lenine' AND per.last_name = 'Pereira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Wenderson Kenedy', 'Pereira', '1999-10-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Wenderson Kenedy' AND last_name = 'Pereira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-wenderson-kenedy-pereira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Wenderson Kenedy' AND per.last_name = 'Pereira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gustavo', 'Ribeiro', '2000-11-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gustavo' AND last_name = 'Ribeiro' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-gustavo-ribeiro', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gustavo' AND per.last_name = 'Ribeiro' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marek', 'Rutkowki', '2005-08-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marek' AND last_name = 'Rutkowki' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-marek-rutkowki', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marek' AND per.last_name = 'Rutkowki' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Malek', 'Sakhri', '2006-01-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Malek' AND last_name = 'Sakhri' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-malek-sakhri', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Malek' AND per.last_name = 'Sakhri' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Souare', 'Saliou', '2001-02-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Souare' AND last_name = 'Saliou' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-souare-saliou', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Souare' AND per.last_name = 'Saliou' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Silvio', 'Silva', '2002-08-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Silvio' AND last_name = 'Silva' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-silvio-silva', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Silvio' AND per.last_name = 'Silva' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marcos', 'Souto', '2002-10-23') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marcos' AND last_name = 'Souto' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-marcos-souto', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marcos' AND per.last_name = 'Souto' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jhordan', 'Souza', '1998-05-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jhordan' AND last_name = 'Souza' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-jhordan-souza', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jhordan' AND per.last_name = 'Souza' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Carlos', 'Teixeira', '2000-02-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Carlos' AND last_name = 'Teixeira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-carlos-teixeira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Carlos' AND per.last_name = 'Teixeira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Elton j', 'Teixeira', '1991-01-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Elton j' AND last_name = 'Teixeira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-elton-j-teixeira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Elton j' AND per.last_name = 'Teixeira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Willian', 'Zanetti', '2001-04-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Willian' AND last_name = 'Zanetti' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'jaguars-united-fc-willian-zanetti', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Willian' AND per.last_name = 'Zanetti' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Elohim', 'Alves', '2004-02-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Elohim' AND last_name = 'Alves' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-elohim-alves', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Elohim' AND per.last_name = 'Alves' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Luis', 'Araujo', '2003-12-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Luis' AND last_name = 'Araujo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-luis-araujo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Luis' AND per.last_name = 'Araujo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Wesley', 'Borges', '1985-05-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Wesley' AND last_name = 'Borges' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-wesley-borges', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Wesley' AND per.last_name = 'Borges' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Adriel', 'Cordeiro', '1989-09-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Adriel' AND last_name = 'Cordeiro' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-adriel-cordeiro', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Adriel' AND per.last_name = 'Cordeiro' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Wagner', 'Da Silva', '1998-11-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Wagner' AND last_name = 'Da Silva' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-wagner-da-silva', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Wagner' AND per.last_name = 'Da Silva' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Luan', 'De Souza', '1992-01-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Luan' AND last_name = 'De Souza' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-luan-de-souza', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Luan' AND per.last_name = 'De Souza' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Carlos', 'De Souza', '1977-01-23') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Carlos' AND last_name = 'De Souza' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-carlos-de-souza', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Carlos' AND per.last_name = 'De Souza' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Israel', 'Duarte', '2001-04-23') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Israel' AND last_name = 'Duarte' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-israel-duarte', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Israel' AND per.last_name = 'Duarte' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gabriel', 'Fernandes', '2001-09-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gabriel' AND last_name = 'Fernandes' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-gabriel-fernandes', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gabriel' AND per.last_name = 'Fernandes' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marcelino', 'Ferreira', '2003-06-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marcelino' AND last_name = 'Ferreira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-marcelino-ferreira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marcelino' AND per.last_name = 'Ferreira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Walafy', 'Leonor', '1993-09-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Walafy' AND last_name = 'Leonor' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-walafy-leonor', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Walafy' AND per.last_name = 'Leonor' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Felipe', 'Lopes', '2006-05-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Felipe' AND last_name = 'Lopes' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-felipe-lopes', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Felipe' AND per.last_name = 'Lopes' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gustavo', 'Lopes', '2002-06-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gustavo' AND last_name = 'Lopes' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-gustavo-lopes', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gustavo' AND per.last_name = 'Lopes' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Raimon', 'marques', '1990-04-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Raimon' AND last_name = 'marques' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-raimon-marques', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Raimon' AND per.last_name = 'marques' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Rafael', 'Medeiros', '1996-02-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Rafael' AND last_name = 'Medeiros' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-rafael-medeiros', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Rafael' AND per.last_name = 'Medeiros' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Leandro', 'Pereira Ramos.', '1992-10-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Leandro' AND last_name = 'Pereira Ramos.' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-leandro-pereira-ramos', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Leandro' AND per.last_name = 'Pereira Ramos.' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Leandro', 'Pires', '1995-01-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Leandro' AND last_name = 'Pires' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-leandro-pires', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Leandro' AND per.last_name = 'Pires' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Douglas', 'Pires', '1989-09-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Douglas' AND last_name = 'Pires' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-douglas-pires', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Douglas' AND per.last_name = 'Pires' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Leandro', 'Ramos', '1988-04-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Leandro' AND last_name = 'Ramos' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-leandro-ramos', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Leandro' AND per.last_name = 'Ramos' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Caique', 'Reginaldo', '1995-02-23') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Caique' AND last_name = 'Reginaldo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-caique-reginaldo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Caique' AND per.last_name = 'Reginaldo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Eduardo', 'Reis', '1999-01-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Eduardo' AND last_name = 'Reis' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-eduardo-reis', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Eduardo' AND per.last_name = 'Reis' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Maxsuel', 'Ribeiro', '1995-10-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Maxsuel' AND last_name = 'Ribeiro' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-maxsuel-ribeiro', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Maxsuel' AND per.last_name = 'Ribeiro' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Luis', 'Santos', '1996-08-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Luis' AND last_name = 'Santos' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-luis-santos', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Luis' AND per.last_name = 'Santos' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Vanilson', 'Santos', '1998-09-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Vanilson' AND last_name = 'Santos' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-vanilson-santos', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Vanilson' AND per.last_name = 'Santos' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Deyvit', 'Silva', '1994-11-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Deyvit' AND last_name = 'Silva' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-deyvit-silva', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Deyvit' AND per.last_name = 'Silva' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Wenderson', 'Silva', '1999-05-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Wenderson' AND last_name = 'Silva' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-wenderson-silva', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Wenderson' AND per.last_name = 'Silva' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Pedro', 'Silva', '1993-06-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Pedro' AND last_name = 'Silva' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'south-shore-fc-pedro-silva', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Pedro' AND per.last_name = 'Silva' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Eder', 'Amado', '1989-11-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Eder' AND last_name = 'Amado' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-eder-amado', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Eder' AND per.last_name = 'Amado' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Helton', 'Brandao', '2003-02-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Helton' AND last_name = 'Brandao' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-helton-brandao', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Helton' AND per.last_name = 'Brandao' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Yuri', 'Brandao', '1996-06-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Yuri' AND last_name = 'Brandao' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-yuri-brandao', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Yuri' AND per.last_name = 'Brandao' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Derik', 'Brito', '2002-01-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Derik' AND last_name = 'Brito' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-derik-brito', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Derik' AND per.last_name = 'Brito' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Erick', 'Brito', '2002-01-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Erick' AND last_name = 'Brito' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-erick-brito', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Erick' AND per.last_name = 'Brito' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Belvick', 'da Silva', '2000-09-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Belvick' AND last_name = 'da Silva' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-belvick-da-silva', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Belvick' AND per.last_name = 'da Silva' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Brandon', 'Daluz', '2003-10-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Brandon' AND last_name = 'Daluz' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-brandon-daluz', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Brandon' AND per.last_name = 'Daluz' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jaylon', 'Darosa', '2002-09-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jaylon' AND last_name = 'Darosa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-jaylon-darosa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jaylon' AND per.last_name = 'Darosa' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Janilson', 'Debrito', '2007-11-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Janilson' AND last_name = 'Debrito' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-janilson-debrito', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Janilson' AND per.last_name = 'Debrito' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jayden', 'Depina', '2003-11-21') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jayden' AND last_name = 'Depina' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-jayden-depina', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jayden' AND per.last_name = 'Depina' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Lucas', 'Fernandes', '2002-04-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Lucas' AND last_name = 'Fernandes' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-lucas-fernandes', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Lucas' AND per.last_name = 'Fernandes' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Luis', 'Fortes', '2006-04-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Luis' AND last_name = 'Fortes' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-luis-fortes', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Luis' AND per.last_name = 'Fortes' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ty', 'Gomes', '2000-12-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ty' AND last_name = 'Gomes' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-ty-gomes', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ty' AND per.last_name = 'Gomes' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jorge', 'Goncalves', '1999-12-16') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jorge' AND last_name = 'Goncalves' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-jorge-goncalves', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jorge' AND per.last_name = 'Goncalves' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ricardo', 'Monteiro', '2004-10-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ricardo' AND last_name = 'Monteiro' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-ricardo-monteiro', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ricardo' AND per.last_name = 'Monteiro' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Carlos', 'Morais', '2003-06-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Carlos' AND last_name = 'Morais' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-carlos-morais', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Carlos' AND per.last_name = 'Morais' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Dany', 'Pina', '1994-11-21') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Dany' AND last_name = 'Pina' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-dany-pina', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Dany' AND per.last_name = 'Pina' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Johnathan', 'Pires', '1996-06-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Johnathan' AND last_name = 'Pires' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-johnathan-pires', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Johnathan' AND per.last_name = 'Pires' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Danny', 'Resende', '2002-03-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Danny' AND last_name = 'Resende' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-danny-resende', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Danny' AND per.last_name = 'Resende' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Anthony', 'Rodrigues', '2003-04-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Anthony' AND last_name = 'Rodrigues' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-anthony-rodrigues', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Anthony' AND per.last_name = 'Rodrigues' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jonathan', 'Rodrigues', '2000-12-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jonathan' AND last_name = 'Rodrigues' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-jonathan-rodrigues', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jonathan' AND per.last_name = 'Rodrigues' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jeremias', 'Rosa', '2003-05-23') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jeremias' AND last_name = 'Rosa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-jeremias-rosa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jeremias' AND per.last_name = 'Rosa' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kevin', 'Soares', '1995-08-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kevin' AND last_name = 'Soares' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-kevin-soares', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kevin' AND per.last_name = 'Soares' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Junior', 'Tavares', '2001-07-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Junior' AND last_name = 'Tavares' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-junior-tavares', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Junior' AND per.last_name = 'Tavares' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Edmilson', 'Vaz Tavares', '1998-07-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Edmilson' AND last_name = 'Vaz Tavares' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-edmilson-vaz-tavares', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Edmilson' AND per.last_name = 'Vaz Tavares' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Vanilton', 'Xavier', '2003-08-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Vanilton' AND last_name = 'Xavier' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'strictly-nos-fc-vanilton-xavier', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Vanilton' AND per.last_name = 'Xavier' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mohammed', 'Abdulrahman', '1998-01-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mohammed' AND last_name = 'Abdulrahman' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-mohammed-abdulrahman', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mohammed' AND per.last_name = 'Abdulrahman' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Omar', 'Ahmed', '2002-08-21') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Omar' AND last_name = 'Ahmed' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-omar-ahmed', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Omar' AND per.last_name = 'Ahmed' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Zain', 'AL-Ashoor', '1999-02-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Zain' AND last_name = 'AL-Ashoor' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-zain-al-ashoor', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Zain' AND per.last_name = 'AL-Ashoor' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Elhadj', 'Bah', '2003-03-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Elhadj' AND last_name = 'Bah' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-elhadj-bah', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Elhadj' AND per.last_name = 'Bah' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ethan', 'Buss', '2006-08-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ethan' AND last_name = 'Buss' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-ethan-buss', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ethan' AND per.last_name = 'Buss' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Shamanuel', 'Dominique', '2004-10-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Shamanuel' AND last_name = 'Dominique' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-shamanuel-dominique', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Shamanuel' AND per.last_name = 'Dominique' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Filip', 'Dordevic', '2002-02-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Filip' AND last_name = 'Dordevic' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-filip-dordevic', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Filip' AND per.last_name = 'Dordevic' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Habib', 'Emami', '1997-06-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Habib' AND last_name = 'Emami' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-habib-emami', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Habib' AND per.last_name = 'Emami' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Yeremosi', 'Foste', '2005-11-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Yeremosi' AND last_name = 'Foste' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-yeremosi-foste', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Yeremosi' AND per.last_name = 'Foste' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Terah', 'Garnett', '1992-11-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Terah' AND last_name = 'Garnett' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-terah-garnett', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Terah' AND per.last_name = 'Garnett' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ermias', 'Getnet', '1997-09-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ermias' AND last_name = 'Getnet' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-ermias-getnet', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ermias' AND per.last_name = 'Getnet' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jesse', 'Gutierrez', '1999-10-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jesse' AND last_name = 'Gutierrez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-jesse-gutierrez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jesse' AND per.last_name = 'Gutierrez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mohammed', 'Hassan', '1997-09-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mohammed' AND last_name = 'Hassan' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-mohammed-hassan', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mohammed' AND per.last_name = 'Hassan' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Miguel', 'Ikomo', '1995-10-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Miguel' AND last_name = 'Ikomo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-miguel-ikomo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Miguel' AND per.last_name = 'Ikomo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Stylianos', 'Ioannou', '2005-03-29') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Stylianos' AND last_name = 'Ioannou' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-stylianos-ioannou', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Stylianos' AND per.last_name = 'Ioannou' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Samuel', 'Kihorezo', '2000-02-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Samuel' AND last_name = 'Kihorezo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-samuel-kihorezo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Samuel' AND per.last_name = 'Kihorezo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Joshua', 'Logan', '1998-09-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Joshua' AND last_name = 'Logan' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-joshua-logan', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Joshua' AND per.last_name = 'Logan' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Abdoul', 'Mamaoudou', '2002-02-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Abdoul' AND last_name = 'Mamaoudou' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-abdoul-mamaoudou', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Abdoul' AND per.last_name = 'Mamaoudou' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('John', 'Moore', '1989-10-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'John' AND last_name = 'Moore' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-john-moore', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'John' AND per.last_name = 'Moore' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Moussa', 'Oumarou', '2006-01-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Moussa' AND last_name = 'Oumarou' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-moussa-oumarou', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Moussa' AND per.last_name = 'Oumarou' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Fernando', 'Salazar', '2005-11-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Fernando' AND last_name = 'Salazar' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-fernando-salazar', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Fernando' AND per.last_name = 'Salazar' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gerrit', 'Stech', '2002-02-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gerrit' AND last_name = 'Stech' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-gerrit-stech', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gerrit' AND per.last_name = 'Stech' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Shengda', 'Sun Lopez', '2004-01-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Shengda' AND last_name = 'Sun Lopez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-shengda-sun-lopez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Shengda' AND per.last_name = 'Sun Lopez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Daniel', 'Tema', '2002-08-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Daniel' AND last_name = 'Tema' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-daniel-tema', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Daniel' AND per.last_name = 'Tema' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Makan', 'Traore', '2003-11-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Makan' AND last_name = 'Traore' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-makan-traore', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Makan' AND per.last_name = 'Traore' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Robby', 'Waller', '1990-04-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Robby' AND last_name = 'Waller' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-robby-waller', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Robby' AND per.last_name = 'Waller' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jereme', 'Wells', '1996-10-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jereme' AND last_name = 'Wells' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-jereme-wells', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jereme' AND per.last_name = 'Wells' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Shenoda', 'Youssef', '1997-08-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Shenoda' AND last_name = 'Youssef' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'alloy-soccer-club-reserves-shenoda-youssef', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Shenoda' AND per.last_name = 'Youssef' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Harein', 'Abeysekera', '2005-05-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Harein' AND last_name = 'Abeysekera' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-harein-abeysekera', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Harein' AND per.last_name = 'Abeysekera' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sebastian', 'Carrilo', '2003-09-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sebastian' AND last_name = 'Carrilo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-sebastian-carrilo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sebastian' AND per.last_name = 'Carrilo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Drake', 'DeJute', '2004-04-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Drake' AND last_name = 'DeJute' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-drake-dejute', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Drake' AND per.last_name = 'DeJute' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kabeer', 'Ferhan', '2006-03-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kabeer' AND last_name = 'Ferhan' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-kabeer-ferhan', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kabeer' AND per.last_name = 'Ferhan' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jackson', 'Hellmann', '2005-06-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jackson' AND last_name = 'Hellmann' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-jackson-hellmann', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jackson' AND per.last_name = 'Hellmann' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marc', 'Iglesias', '2007-07-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marc' AND last_name = 'Iglesias' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-marc-iglesias', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marc' AND per.last_name = 'Iglesias' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Yussif Attabio', 'Ismail', '2003-05-23') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Yussif Attabio' AND last_name = 'Ismail' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-yussif-attabio-ismail', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Yussif Attabio' AND per.last_name = 'Ismail' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('An', 'Jaeyun', '2001-09-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'An' AND last_name = 'Jaeyun' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-an-jaeyun', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'An' AND per.last_name = 'Jaeyun' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Parth', 'Karki', '2007-06-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Parth' AND last_name = 'Karki' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-parth-karki', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Parth' AND per.last_name = 'Karki' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sergio', 'Marin Miralles', '2004-05-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sergio' AND last_name = 'Marin Miralles' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-sergio-marin-miralles', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sergio' AND per.last_name = 'Marin Miralles' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Calix', 'Milligan', '2004-07-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Calix' AND last_name = 'Milligan' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-calix-milligan', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Calix' AND per.last_name = 'Milligan' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Adeon', 'Muyskens', '2003-02-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Adeon' AND last_name = 'Muyskens' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-adeon-muyskens', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Adeon' AND per.last_name = 'Muyskens' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Faisal', 'Niazi', '2004-02-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Faisal' AND last_name = 'Niazi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-faisal-niazi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Faisal' AND per.last_name = 'Niazi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Vincent', 'Okyere', '2007-02-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Vincent' AND last_name = 'Okyere' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-vincent-okyere', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Vincent' AND per.last_name = 'Okyere' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Devin', 'Putnam', '2005-03-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Devin' AND last_name = 'Putnam' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-devin-putnam', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Devin' AND per.last_name = 'Putnam' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Bernard', 'Sakyi', '2003-12-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Bernard' AND last_name = 'Sakyi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-bernard-sakyi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Bernard' AND per.last_name = 'Sakyi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jordan', 'Samuels', '2003-04-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jordan' AND last_name = 'Samuels' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-jordan-samuels', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jordan' AND per.last_name = 'Samuels' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sanzhar', 'Sarynzhiev', '2007-03-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sanzhar' AND last_name = 'Sarynzhiev' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-sanzhar-sarynzhiev', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sanzhar' AND per.last_name = 'Sarynzhiev' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sam', 'Scherzer', '2007-02-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sam' AND last_name = 'Scherzer' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-sam-scherzer', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sam' AND per.last_name = 'Scherzer' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gabriel Antonio', 'Silva Gomes', '2006-04-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gabriel Antonio' AND last_name = 'Silva Gomes' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-gabriel-antonio-silva-gomes', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gabriel Antonio' AND per.last_name = 'Silva Gomes' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Benjamin', 'Winograd', '2005-09-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Benjamin' AND last_name = 'Winograd' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-benjamin-winograd', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Benjamin' AND per.last_name = 'Winograd' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Muhyadin', 'Yusuf', '2003-05-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Muhyadin' AND last_name = 'Yusuf' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-muhyadin-yusuf', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Muhyadin' AND per.last_name = 'Yusuf' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alex', 'Jacobs', '2004-01-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alex' AND last_name = 'Jacobs' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-alex-jacobs', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alex' AND per.last_name = 'Jacobs' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christopher', 'Wann', '2006-02-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Christopher' AND last_name = 'Wann' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'f-m-fc-christopher-wann', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christopher' AND per.last_name = 'Wann' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mohammed', 'Al Qudsi', '1997-08-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mohammed' AND last_name = 'Al Qudsi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-mohammed-al-qudsi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mohammed' AND per.last_name = 'Al Qudsi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gurnoor', 'Bagri', '2008-01-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gurnoor' AND last_name = 'Bagri' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-gurnoor-bagri', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gurnoor' AND per.last_name = 'Bagri' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Quinn', 'Bertoncini-Troutman', '2006-08-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Quinn' AND last_name = 'Bertoncini-Troutman' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-quinn-bertoncini-troutman', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Quinn' AND per.last_name = 'Bertoncini-Troutman' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Braedon', 'Bickford', '2006-11-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Braedon' AND last_name = 'Bickford' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-braedon-bickford', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Braedon' AND per.last_name = 'Bickford' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Albert', 'Corea', '2004-07-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Albert' AND last_name = 'Corea' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-albert-corea', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Albert' AND per.last_name = 'Corea' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Dylan', 'Crills', '2007-09-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Dylan' AND last_name = 'Crills' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-dylan-crills', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Dylan' AND per.last_name = 'Crills' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Amini', 'Diye', '2007-02-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Amini' AND last_name = 'Diye' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-amini-diye', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Amini' AND per.last_name = 'Diye' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Vincent', 'Edmond', '2007-12-21') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Vincent' AND last_name = 'Edmond' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-vincent-edmond', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Vincent' AND per.last_name = 'Edmond' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Chri', 'Ehgay', '2004-10-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Chri' AND last_name = 'Ehgay' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-chri-ehgay', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Chri' AND per.last_name = 'Ehgay' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ian', 'Frisbie', '2005-04-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ian' AND last_name = 'Frisbie' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-ian-frisbie', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ian' AND per.last_name = 'Frisbie' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mason', 'Harris', '2005-12-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Mason' AND last_name = 'Harris' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-mason-harris', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mason' AND per.last_name = 'Harris' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Bita', 'Imani', '2007-06-10') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Bita' AND last_name = 'Imani' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-bita-imani', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Bita' AND per.last_name = 'Imani' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Michael', 'Kasampilo', '2004-06-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Michael' AND last_name = 'Kasampilo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-michael-kasampilo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Michael' AND per.last_name = 'Kasampilo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Asende', 'Lubende', '2000-12-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Asende' AND last_name = 'Lubende' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-asende-lubende', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Asende' AND per.last_name = 'Lubende' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Faustin', 'Mucunguzi', '2003-01-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Faustin' AND last_name = 'Mucunguzi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-faustin-mucunguzi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Faustin' AND per.last_name = 'Mucunguzi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jack', 'Ngoy', '2005-12-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jack' AND last_name = 'Ngoy' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-jack-ngoy', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jack' AND per.last_name = 'Ngoy' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ibrahim', 'Ntege', '2004-06-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ibrahim' AND last_name = 'Ntege' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-ibrahim-ntege', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ibrahim' AND per.last_name = 'Ntege' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Brandon', 'Perez', '2004-09-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Brandon' AND last_name = 'Perez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-brandon-perez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Brandon' AND per.last_name = 'Perez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Lata', 'Petros', '1997-09-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Lata' AND last_name = 'Petros' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-lata-petros', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Lata' AND per.last_name = 'Petros' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gavin', 'Roberts', '2006-09-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gavin' AND last_name = 'Roberts' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-gavin-roberts', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gavin' AND per.last_name = 'Roberts' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ben', 'Singizwa', '2005-07-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ben' AND last_name = 'Singizwa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-ben-singizwa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ben' AND per.last_name = 'Singizwa' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Babo', 'Tereffe', '1999-04-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Babo' AND last_name = 'Tereffe' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-babo-tereffe', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Babo' AND per.last_name = 'Tereffe' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Gavin', 'Wiley', '1998-06-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Gavin' AND last_name = 'Wiley' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'keystone-elite-gavin-wiley', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Gavin' AND per.last_name = 'Wiley' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Antonio', 'Alonso-Hernandez', '2006-09-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Antonio' AND last_name = 'Alonso-Hernandez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-antonio-alonso-hernandez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Antonio' AND per.last_name = 'Alonso-Hernandez' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Daniel', 'Arraiz', '2003-11-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Daniel' AND last_name = 'Arraiz' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-daniel-arraiz', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Daniel' AND per.last_name = 'Arraiz' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Daviont', 'Baker-Alston', '2005-02-07') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Daviont' AND last_name = 'Baker-Alston' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-daviont-baker-alston', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Daviont' AND per.last_name = 'Baker-Alston' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Lucas', 'Cherniak', '2004-03-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Lucas' AND last_name = 'Cherniak' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-lucas-cherniak', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Lucas' AND per.last_name = 'Cherniak' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Andrew', 'Cui', '2007-01-16') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Andrew' AND last_name = 'Cui' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-andrew-cui', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Andrew' AND per.last_name = 'Cui' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Blake', 'Deluca', '2004-09-13') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Blake' AND last_name = 'Deluca' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-blake-deluca', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Blake' AND per.last_name = 'Deluca' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Matthew', 'DiCarlo', '2005-08-17') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Matthew' AND last_name = 'DiCarlo' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-matthew-dicarlo', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Matthew' AND per.last_name = 'DiCarlo' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Sleem', 'Emam', '2006-05-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Sleem' AND last_name = 'Emam' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-sleem-emam', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Sleem' AND per.last_name = 'Emam' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Rhenan', 'Ferreira', '2006-03-31') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Rhenan' AND last_name = 'Ferreira' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-rhenan-ferreira', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Rhenan' AND per.last_name = 'Ferreira' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Aiden', 'Fogarty', '2006-03-28') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Aiden' AND last_name = 'Fogarty' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-aiden-fogarty', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Aiden' AND per.last_name = 'Fogarty' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Leonardo', 'Guzman', '2006-08-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Leonardo' AND last_name = 'Guzman' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-leonardo-guzman', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Leonardo' AND per.last_name = 'Guzman' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Luke', 'Jones', '2005-03-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Luke' AND last_name = 'Jones' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-luke-jones', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Luke' AND per.last_name = 'Jones' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Samuel', 'Kaganzev', '2006-05-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Samuel' AND last_name = 'Kaganzev' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-samuel-kaganzev', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Samuel' AND per.last_name = 'Kaganzev' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('William', 'Maurek', '2005-11-16') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'William' AND last_name = 'Maurek' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-william-maurek', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'William' AND per.last_name = 'Maurek' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jared', 'Mikloski', '2006-07-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jared' AND last_name = 'Mikloski' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-jared-mikloski', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jared' AND per.last_name = 'Mikloski' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Logan', 'Rogers', '2007-04-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Logan' AND last_name = 'Rogers' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-logan-rogers', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Logan' AND per.last_name = 'Rogers' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ethan', 'Schrampf', '2005-09-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ethan' AND last_name = 'Schrampf' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-ethan-schrampf', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ethan' AND per.last_name = 'Schrampf' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alex', 'Schrampf', '2006-12-26') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alex' AND last_name = 'Schrampf' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-alex-schrampf', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alex' AND per.last_name = 'Schrampf' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Caden', 'Thompson', '2007-03-19') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Caden' AND last_name = 'Thompson' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-caden-thompson', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Caden' AND per.last_name = 'Thompson' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('David', 'Turchi', '2006-04-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'David' AND last_name = 'Turchi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-david-turchi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'David' AND per.last_name = 'Turchi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Johnny', 'Turchi', '2006-04-20') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Johnny' AND last_name = 'Turchi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-johnny-turchi', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Johnny' AND per.last_name = 'Turchi' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jacob', 'Warner', '2006-08-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jacob' AND last_name = 'Warner' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-jacob-warner', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jacob' AND per.last_name = 'Warner' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Koye', 'Whitman', '2003-09-08') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Koye' AND last_name = 'Whitman' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-koye-whitman', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Koye' AND per.last_name = 'Whitman' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Tim', 'Zellner', '2006-08-18') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Tim' AND last_name = 'Zellner' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'kutztown-men-s-soccer-tim-zellner', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Tim' AND per.last_name = 'Zellner' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Erick', 'Bernal', '1998-01-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Erick' AND last_name = 'Bernal' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-erick-bernal', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Erick' AND per.last_name = 'Bernal' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jordan', 'Brubaker', '1993-01-03') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jordan' AND last_name = 'Brubaker' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-jordan-brubaker', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jordan' AND per.last_name = 'Brubaker' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ian', 'Byrnes', '1995-12-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ian' AND last_name = 'Byrnes' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-ian-byrnes', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ian' AND per.last_name = 'Byrnes' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Julian', 'Carvajal', '1990-12-15') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Julian' AND last_name = 'Carvajal' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-julian-carvajal', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Julian' AND per.last_name = 'Carvajal' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Joel', 'Chachapoya', '1996-07-21') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Joel' AND last_name = 'Chachapoya' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-joel-chachapoya', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Joel' AND per.last_name = 'Chachapoya' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Andrea', 'DiSomma', NULL) 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Andrea' AND last_name = 'DiSomma' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-andrea-disomma', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Andrea' AND per.last_name = 'DiSomma' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Tyler', 'Hambright', '2004-11-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Tyler' AND last_name = 'Hambright' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-tyler-hambright', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Tyler' AND per.last_name = 'Hambright' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jessie', 'Herb', '1996-05-14') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jessie' AND last_name = 'Herb' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-jessie-herb', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jessie' AND per.last_name = 'Herb' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Shaquille', 'Hudson', '1991-03-12') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Shaquille' AND last_name = 'Hudson' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-shaquille-hudson', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Shaquille' AND per.last_name = 'Hudson' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Asher', 'Klahold', '1993-09-22') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Asher' AND last_name = 'Klahold' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-asher-klahold', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Asher' AND per.last_name = 'Klahold' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jordan', 'McMullen', '1997-08-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jordan' AND last_name = 'McMullen' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-jordan-mcmullen', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jordan' AND per.last_name = 'McMullen' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alex', 'Morales', '2000-01-11') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alex' AND last_name = 'Morales' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-alex-morales', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alex' AND per.last_name = 'Morales' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Garmonger', 'Morris', '1990-10-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Garmonger' AND last_name = 'Morris' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-garmonger-morris', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Garmonger' AND per.last_name = 'Morris' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Caden', 'Mullen', '2005-06-02') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Caden' AND last_name = 'Mullen' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-caden-mullen', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Caden' AND per.last_name = 'Mullen' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Zach', 'Oster', '1993-12-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Zach' AND last_name = 'Oster' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-zach-oster', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Zach' AND per.last_name = 'Oster' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Nikita', 'Patrushev', '1998-07-01') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Nikita' AND last_name = 'Patrushev' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-nikita-patrushev', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Nikita' AND per.last_name = 'Patrushev' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Joshua', 'Patrushey', NULL) 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Joshua' AND last_name = 'Patrushey' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-joshua-patrushey', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Joshua' AND per.last_name = 'Patrushey' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Andrey', 'Patrushey', '1999-11-09') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Andrey' AND last_name = 'Patrushey' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-andrey-patrushey', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Andrey' AND per.last_name = 'Patrushey' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Aaron', 'Pearson', '1986-09-24') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Aaron' AND last_name = 'Pearson' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-aaron-pearson', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Aaron' AND per.last_name = 'Pearson' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Josiah', 'Schendel', '1994-11-06') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Josiah' AND last_name = 'Schendel' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-josiah-schendel', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Josiah' AND per.last_name = 'Schendel' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Chris', 'Sosa', '1994-11-30') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Chris' AND last_name = 'Sosa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-chris-sosa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Chris' AND per.last_name = 'Sosa' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Daniel', 'Sosa', '1991-08-21') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Daniel' AND last_name = 'Sosa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-daniel-sosa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Daniel' AND per.last_name = 'Sosa' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ashton', 'Taughinbaugh', '1987-09-05') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Ashton' AND last_name = 'Taughinbaugh' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-ashton-taughinbaugh', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ashton' AND per.last_name = 'Taughinbaugh' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Michael', 'Tolley', '1997-09-04') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Michael' AND last_name = 'Tolley' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-michael-tolley', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Michael' AND per.last_name = 'Tolley' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Andrew', 'Weaver', '1996-03-27') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Andrew' AND last_name = 'Weaver' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-andrew-weaver', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Andrew' AND per.last_name = 'Weaver' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Tye', 'White', '2005-06-25') 
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Tye' AND last_name = 'White' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lancaster-city-fc-tye-white', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Tye' AND per.last_name = 'White' 
ON CONFLICT (source_system_id, external_id) DO NOTHING;

