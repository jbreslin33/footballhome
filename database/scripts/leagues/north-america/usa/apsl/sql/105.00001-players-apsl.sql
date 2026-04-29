-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Players - APSL
-- Player roster data from team pages
-- Total Records: 31
-- 
-- Architecture: Auto-generated IDs, name-based deduplication
-- Same name = same person across all sources (curation overrides via name change)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Musa', 'Abdelgadir', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Musa' AND last_name = 'Abdelgadir' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-musa-abdelgadir', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Musa' AND per.last_name = 'Abdelgadir' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Amar', 'Abdelrazek', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Amar' AND last_name = 'Abdelrazek' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-amar-abdelrazek', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Amar' AND per.last_name = 'Abdelrazek' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Abdelrahman', 'Ali', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Abdelrahman' AND last_name = 'Ali' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-abdelrahman-ali', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Abdelrahman' AND per.last_name = 'Ali' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ahmed', 'Ali', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Ahmed' AND last_name = 'Ali' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-ahmed-ali', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ahmed' AND per.last_name = 'Ali' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Erwa', 'Babiker', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Erwa' AND last_name = 'Babiker' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-erwa-babiker', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Erwa' AND per.last_name = 'Babiker' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Arsene', 'Bado', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Arsene' AND last_name = 'Bado' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-arsene-bado', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Arsene' AND per.last_name = 'Bado' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Logan', 'Bersani', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Logan' AND last_name = 'Bersani' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-logan-bersani', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Logan' AND per.last_name = 'Bersani' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mohamed', 'Bility', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Mohamed' AND last_name = 'Bility' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-mohamed-bility', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mohamed' AND per.last_name = 'Bility' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Hamzah', 'Dabbour', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Hamzah' AND last_name = 'Dabbour' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-hamzah-dabbour', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Hamzah' AND per.last_name = 'Dabbour' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Terrence', 'Doe', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Terrence' AND last_name = 'Doe' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-terrence-doe', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Terrence' AND per.last_name = 'Doe' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Musa', 'Donza', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Musa' AND last_name = 'Donza' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-musa-donza', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Musa' AND per.last_name = 'Donza' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alexander', 'Duopu', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Alexander' AND last_name = 'Duopu' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-alexander-duopu', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alexander' AND per.last_name = 'Duopu' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christopher', 'Fletcher', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Christopher' AND last_name = 'Fletcher' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-christopher-fletcher', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christopher' AND per.last_name = 'Fletcher' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mujtaba', 'Galas', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Mujtaba' AND last_name = 'Galas' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-mujtaba-galas', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mujtaba' AND per.last_name = 'Galas' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mustafa', 'Galas', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Mustafa' AND last_name = 'Galas' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-mustafa-galas', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mustafa' AND per.last_name = 'Galas' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Henry', 'Gamez', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Henry' AND last_name = 'Gamez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-henry-gamez', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Henry' AND per.last_name = 'Gamez' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Brian', 'Gately', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Brian' AND last_name = 'Gately' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-brian-gately', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Brian' AND per.last_name = 'Gately' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('John', 'Gonzalez', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'John' AND last_name = 'Gonzalez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-john-gonzalez', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'John' AND per.last_name = 'Gonzalez' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Ahmed', 'Gosie', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Ahmed' AND last_name = 'Gosie' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-ahmed-gosie', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Ahmed' AND per.last_name = 'Gosie' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Maccarrey', 'Guillaume', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Maccarrey' AND last_name = 'Guillaume' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-maccarrey-guillaume', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Maccarrey' AND per.last_name = 'Guillaume' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Otmane', 'Houasli', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Otmane' AND last_name = 'Houasli' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-otmane-houasli', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Otmane' AND per.last_name = 'Houasli' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Esnayder', 'Josue', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Esnayder' AND last_name = 'Josue' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-esnayder-josue', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Esnayder' AND per.last_name = 'Josue' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Abdoulaye', 'Kamagate', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Abdoulaye' AND last_name = 'Kamagate' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-abdoulaye-kamagate', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Abdoulaye' AND per.last_name = 'Kamagate' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Amadou', 'Kamagate', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Amadou' AND last_name = 'Kamagate' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-amadou-kamagate', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Amadou' AND per.last_name = 'Kamagate' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Majid', 'Kawa', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Majid' AND last_name = 'Kawa' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-majid-kawa', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Majid' AND per.last_name = 'Kawa' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Mohamed', 'Khalafalla', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Mohamed' AND last_name = 'Khalafalla' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-mohamed-khalafalla', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Mohamed' AND per.last_name = 'Khalafalla' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kouassi', 'Nguessan', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Kouassi' AND last_name = 'Nguessan' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-kouassi-nguessan', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kouassi' AND per.last_name = 'Nguessan' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Som', 'Safavi', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Som' AND last_name = 'Safavi' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-som-safavi', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Som' AND per.last_name = 'Safavi' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marcos', 'Santos', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Marcos' AND last_name = 'Santos' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-marcos-santos', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marcos' AND per.last_name = 'Santos' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Benell', 'Saygarn', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Benell' AND last_name = 'Saygarn' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-benell-saygarn', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Benell' AND per.last_name = 'Saygarn' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Oumar', 'Sylla', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 1 FROM persons 
WHERE first_name = 'Oumar' AND last_name = 'Sylla' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 1, 'lighthouse-1893-sc-oumar-sylla', '116079'
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Oumar' AND per.last_name = 'Sylla' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

