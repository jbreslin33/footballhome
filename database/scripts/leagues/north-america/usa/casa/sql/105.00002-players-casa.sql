-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Players - CASA
-- Player roster data from team pages
-- Total Records: 30
-- 
-- Architecture: Auto-generated IDs, name-based deduplication
-- Same name = same person across all sources (curation overrides via name change)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Amar', 'Abdelrazek', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Amar' AND last_name = 'Abdelrazek' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-amar-abdelrazek', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Amar' AND per.last_name = 'Abdelrazek' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Weder', 'Aguire', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Weder' AND last_name = 'Aguire' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-weder-aguire', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Weder' AND per.last_name = 'Aguire' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Lucas', 'AMBROSIO  SOUSA', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Lucas' AND last_name = 'AMBROSIO  SOUSA' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-lucas-ambrosio-sousa', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Lucas' AND per.last_name = 'AMBROSIO  SOUSA' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Victor', 'Baidel', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Victor' AND last_name = 'Baidel' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-victor-baidel', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Victor' AND per.last_name = 'Baidel' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Inaldo', 'Botelho', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Inaldo' AND last_name = 'Botelho' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-inaldo-botelho', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Inaldo' AND per.last_name = 'Botelho' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Samuel', 'Botelho', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Samuel' AND last_name = 'Botelho' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-samuel-botelho', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Samuel' AND per.last_name = 'Botelho' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Christopher', 'Braz', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Christopher' AND last_name = 'Braz' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-christopher-braz', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Christopher' AND per.last_name = 'Braz' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Luke', 'Breslin', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Luke' AND last_name = 'Breslin' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-luke-breslin', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Luke' AND per.last_name = 'Breslin' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Walter', 'Candido', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Walter' AND last_name = 'Candido' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-walter-candido', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Walter' AND per.last_name = 'Candido' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Kayke Maciel', 'Da Silva', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Kayke Maciel' AND last_name = 'Da Silva' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-kayke-maciel-da-silva', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Kayke Maciel' AND per.last_name = 'Da Silva' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Hamzah', 'Dabbour', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Hamzah' AND last_name = 'Dabbour' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-hamzah-dabbour', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Hamzah' AND per.last_name = 'Dabbour' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Nycolas Kayke', 'De Jesus', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Nycolas Kayke' AND last_name = 'De Jesus' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-nycolas-kayke-de-jesus', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Nycolas Kayke' AND per.last_name = 'De Jesus' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Emmanuel', 'Dennis', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Emmanuel' AND last_name = 'Dennis' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-emmanuel-dennis', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Emmanuel' AND per.last_name = 'Dennis' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Cleiton', 'Dias', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cleiton' AND last_name = 'Dias' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-cleiton-dias', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cleiton' AND per.last_name = 'Dias' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Cloves', 'Ferreira da Silva JÃºnior', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cloves' AND last_name = 'Ferreira da Silva JÃºnior' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-cloves-ferreira-da-silva-ja-nior', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cloves' AND per.last_name = 'Ferreira da Silva JÃºnior' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Cloves', 'Filho', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Cloves' AND last_name = 'Filho' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-cloves-filho', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Cloves' AND per.last_name = 'Filho' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Abouya', 'Gangue', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Abouya' AND last_name = 'Gangue' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-abouya-gangue', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Abouya' AND per.last_name = 'Gangue' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marcos', 'Gomes Santos', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marcos' AND last_name = 'Gomes Santos' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-marcos-gomes-santos', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marcos' AND per.last_name = 'Gomes Santos' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Maccarrey', 'Guillaume', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Maccarrey' AND last_name = 'Guillaume' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-maccarrey-guillaume', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Maccarrey' AND per.last_name = 'Guillaume' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Denis', 'Jhony', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Denis' AND last_name = 'Jhony' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-denis-jhony', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Denis' AND per.last_name = 'Jhony' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Alexander', 'Lara', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Alexander' AND last_name = 'Lara' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-alexander-lara', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Alexander' AND per.last_name = 'Lara' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Pedro', 'Lara', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Pedro' AND last_name = 'Lara' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-pedro-lara', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Pedro' AND per.last_name = 'Lara' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Reginaldo', 'Leite', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Reginaldo' AND last_name = 'Leite' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-reginaldo-leite', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Reginaldo' AND per.last_name = 'Leite' 
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
SELECT pl.id, 2, 'lighthouse-boys-club-owen-magee', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Owen' AND per.last_name = 'Magee' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Valentino', 'Martinez', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Valentino' AND last_name = 'Martinez' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-valentino-martinez', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Valentino' AND per.last_name = 'Martinez' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Lucas', 'Morais', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Lucas' AND last_name = 'Morais' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-lucas-morais', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Lucas' AND per.last_name = 'Morais' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('John', 'Oladele', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'John' AND last_name = 'Oladele' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-john-oladele', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'John' AND per.last_name = 'Oladele' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Jemirkel', 'Ornaque', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Jemirkel' AND last_name = 'Ornaque' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-jemirkel-ornaque', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Jemirkel' AND per.last_name = 'Ornaque' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Marcos', 'Ribeiro', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Marcos' AND last_name = 'Ribeiro' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-marcos-ribeiro', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Marcos' AND per.last_name = 'Ribeiro' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('Igor', 'Santos Bonfim', NULL) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);
INSERT INTO players (person_id, source_system_id) 
SELECT id, 2 FROM persons 
WHERE first_name = 'Igor' AND last_name = 'Santos Bonfim' 
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, 2, 'lighthouse-boys-club-igor-santos-bonfim', NULL
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = 'Igor' AND per.last_name = 'Santos Bonfim' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;

