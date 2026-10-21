-- 628: Fictional demo rosters for the game sandbox (game/DESIGN.md §5.2).
--
-- Development players + teams that FILL the level ladder, so experimental
-- ratings never attach to real club members (James, 10/21: "we need
-- players that fill the levels... fictional players for now, and teams").
-- Entirely fictional — no club PII; safe in git.
--
-- level_band = a Levels.hpp band name. Per-player max_speed_cms varies
-- around the band; concept_mask (NULL = band bundle) carries the
-- characterful outliers: the coached kid on the U-10 swarm team, the slow
-- veteran who knows everything. Bit ids: game/CONCEPTS.md.

CREATE TABLE game_demo_teams (
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    level_band  TEXT NOT NULL
);

CREATE TABLE game_demo_players (
    team_id       INT NOT NULL REFERENCES game_demo_teams(id),
    shirt         INT NOT NULL,
    name          TEXT NOT NULL,
    max_speed_cms INT NOT NULL,
    concept_mask  INT,          -- NULL = the band's default bundle
    PRIMARY KEY (team_id, shirt)
);

INSERT INTO game_demo_teams (name, level_band) VALUES
    ('Lighthouse XI',   'world'),
    ('Harbor Athletic', 'semipro'),
    ('Sunday Albion',   'amateur'),
    ('Tide U14',        'u14'),
    ('Minnows U10',     'u10');

-- Lighthouse XI (world): fast, full knowledge (bundle = all bits).
INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, concept_mask)
SELECT t.id, v.shirt, v.name, v.spd, NULL
FROM game_demo_teams t,
     (VALUES (1,'Viktor Hale',620),(2,'Sam Okafor',700),(3,'Dario Mestre',680),
             (4,'Lev Marchetti',670),(5,'Joao Pinto',690),(6,'Karl Brandt',660),
             (7,'Ale Fontaine',710),(8,'Mateo Ruiz',680),(9,'Erik Sund',700),
             (10,'Nico Vidal',690),(11,'Timo Krause',720)
     ) AS v(shirt, name, spd)
WHERE t.name = 'Lighthouse XI';

-- Harbor Athletic (semipro).
INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, concept_mask)
SELECT t.id, v.shirt, v.name, v.spd, NULL
FROM game_demo_teams t,
     (VALUES (1,'Pete Garvey',580),(2,'Donal Walsh',640),(3,'Marcus Lee',620),
             (4,'Tom Brennan',610),(5,'Luis Serra',630),(6,'Jack Moran',600),
             (7,'Andre Costa',660),(8,'Robbie Finch',620),(9,'Stan Novak',650),
             (10,'Chris Doyle',640),(11,'Felix Braun',670)
     ) AS v(shirt, name, spd)
WHERE t.name = 'Harbor Athletic';

-- Sunday Albion (amateur). Shirt 4 'Old Gio' = the slow veteran: FULL
-- knowledge (1023 = all ten bits), legs long gone.
INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, concept_mask)
SELECT t.id, v.shirt, v.name, v.spd, v.mask
FROM game_demo_teams t,
     (VALUES (1,'Bazza Hughes',540,NULL),(2,'Kev Mulligan',600,NULL),
             (3,'Tony Platt',580,NULL),(4,'Old Gio',480,1023),
             (5,'Mick Shaw',590,NULL),(6,'Dec Rooney',570,NULL),
             (7,'Ben Archer',630,NULL),(8,'Paulie Vance',590,NULL),
             (9,'Gaz Holt',620,NULL),(10,'Dan Keane',600,NULL),
             (11,'Spud Murphy',610,NULL)
     ) AS v(shirt, name, spd, mask)
WHERE t.name = 'Sunday Albion';

-- Tide U14.
INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, concept_mask)
SELECT t.id, v.shirt, v.name, v.spd, NULL
FROM game_demo_teams t,
     (VALUES (1,'Ollie Finn',500),(2,'Max Teller',560),(3,'Jonas Reed',540),
             (4,'Leo Marsh',550),(5,'Owen Pike',560),(6,'Theo Lund',530),
             (7,'Ravi Patel',580),(8,'Cole Bennett',550),(9,'Ian Sorren',570),
             (10,'Noah Quinn',560),(11,'Finn Harlow',590)
     ) AS v(shirt, name, spd)
WHERE t.name = 'Tide U14';

-- Minnows U10. Shirt 5 'Lily Park' = the coached kid: holds position and
-- marks while teammates swarm (delay|marking|cover|line-hold = 1+2+4+512
-- = 519... bits: delay(1)+marking(2)+cover(4)+line_hold(512) = 519).
INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, concept_mask)
SELECT t.id, v.shirt, v.name, v.spd, v.mask
FROM game_demo_teams t,
     (VALUES (1,'Milo Grant',420,NULL),(2,'Pip Sanders',470,NULL),
             (3,'Ezra Cole',450,NULL),(4,'Juno Reyes',460,NULL),
             (5,'Lily Park',460,519),(6,'Ozzy Flint',440,NULL),
             (7,'Remy Boone',490,NULL),(8,'Tate Ellis',450,NULL),
             (9,'Ivy Chen',480,NULL),(10,'Beau Nixon',460,NULL),
             (11,'Ash Riley',470,NULL)
     ) AS v(shirt, name, spd, mask)
WHERE t.name = 'Minnows U10';
