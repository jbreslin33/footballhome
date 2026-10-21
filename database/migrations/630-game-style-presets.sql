-- 630: Style presets — the auteur canon + the club preset as DB rows
-- (game/CONCEPTS.md "Schools & auteurs": a school is a PRESET VECTOR).
--
-- A preset is an OVERLAY: it carries ratings only for the dials the school
-- cares about; applying it leaves every unnamed concept at the player's
-- current value (so "Bielsa base + modifications" composes). concept is the
-- registry NAME (game/CONCEPTS.md / Levels.hpp kConceptNames) — names
-- survive bit growth, ids don't. An explicit 0 row is meaningful (Sacchi's
-- zonal marking SETS man-mark to 0).
--
-- source: the verbatim principle line a rating is derived from — required
-- for the club preset per CONCEPTS.md ("every principle row cites its
-- verbatim source line"; docs/game-model/us-soccer-full-extraction.md).

CREATE TABLE game_style_presets (
    id         SERIAL PRIMARY KEY,
    name       TEXT NOT NULL UNIQUE,
    sort_order INT  NOT NULL,
    note       TEXT          -- one-line identity, shown nowhere yet
);

CREATE TABLE game_style_preset_ratings (
    preset_id INT  NOT NULL REFERENCES game_style_presets(id),
    concept   TEXT NOT NULL,          -- Levels.hpp kConceptNames entry
    rating    INT  NOT NULL CHECK (rating BETWEEN 0 AND 100),
    source    TEXT,                   -- verbatim citation (club preset)
    PRIMARY KEY (preset_id, concept)
);

INSERT INTO game_style_presets (name, sort_order, note) VALUES
    ('Lighthouse',      1,  'The club game model: Bielsa base + modifications (docs/game-model/)'),
    ('Bielsa',          2,  'Man-orientation everywhere, murderball running, forward first'),
    ('Positional Play', 3,  'Michels/Cruyff → Guardiola: width, support, control over verticality'),
    ('Sacchi',          4,  'The 4-4-2 pressing block on one string — strictly zonal'),
    ('Gegenpress',      5,  'Klopp/Rangnick: the counter-press is the playmaker'),
    ('Mourinho',        6,  'Low-block transition: deep line, cover, spring forward'),
    ('Simeone',         7,  'Mid-block two banks: delay, balance, touchline traps'),
    ('Lobanovskyi',     8,  'Universality: the vector is flat and high'),
    ('Zeman',           9,  'Vertical chaos: defense left as an exercise'),
    ('Gasperini',       10, 'Man-orientation all over, back line included'),
    ('De Zerbi',        11, 'Bait-press build: the keeper is a player'),
    ('Herrera',         12, 'Catenaccio: the libero is permanent cover');

-- THE CLUB PRESET — Lighthouse [FH]: first-pass vector from the U.S.
-- Soccer U17+ extraction's stated principles; man-mark 55 is the club
-- modification (nearer zonal than full Bielsa — James).
INSERT INTO game_style_preset_ratings (preset_id, concept, rating, source)
SELECT p.id, v.concept, v.rating, v.source
FROM game_style_presets p,
     (VALUES
        ('verticality',   85, 'advancing the ball quickly in the attacking half with high energy and high tempo'),
        ('counter-press', 85, 'regain the ball early and as high up the field as possible, by reacting immediately with maximum intensity'),
        ('width',         90, 'Create appropriate height, width, depth'),
        ('runs',          85, 'Make runs behind the defensive line'),
        ('push-up',       85, 'Push up the defensive line with speed: stay connected and compact'),
        ('support',       90, 'Give immediate support to teammate under pressure'),
        ('outlet',        80, 'Create balance with a minimum of 5 players ahead of the ball'),
        ('man-mark',      55, 'club modification: nearer zonal than full Bielsa (James)')
     ) AS v(concept, rating, source)
WHERE p.name = 'Lighthouse';

-- The auteur canon (CONCEPTS.md vectors; wired dials only — queued
-- concepts join their preset rows when their bits land).
INSERT INTO game_style_preset_ratings (preset_id, concept, rating)
SELECT p.id, v.concept, v.rating
FROM game_style_presets p
JOIN (VALUES
    ('Bielsa', 'man-mark', 95), ('Bielsa', 'counter-press', 90),
    ('Bielsa', 'verticality', 90), ('Bielsa', 'width', 85),
    ('Bielsa', 'push-up', 85),
    ('Positional Play', 'width', 90), ('Positional Play', 'support', 95),
    ('Positional Play', 'push-up', 80),
    ('Positional Play', 'counter-press', 80),
    ('Positional Play', 'verticality', 35),
    ('Sacchi', 'line-hold', 95), ('Sacchi', 'push-up', 90),
    ('Sacchi', 'balance', 95), ('Sacchi', 'man-mark', 0),
    ('Gegenpress', 'counter-press', 100), ('Gegenpress', 'verticality', 80),
    ('Gegenpress', 'push-up', 85),
    ('Mourinho', 'push-up', 25), ('Mourinho', 'line-hold', 90),
    ('Mourinho', 'balance', 90), ('Mourinho', 'cover', 95),
    ('Mourinho', 'verticality', 85),
    ('Simeone', 'balance', 95), ('Simeone', 'double-team', 90),
    ('Simeone', 'delay', 95),
    ('Zeman', 'verticality', 100), ('Zeman', 'push-up', 95),
    ('Zeman', 'placement', 90),
    ('Gasperini', 'man-mark', 100),
    ('De Zerbi', 'sweep', 95),
    ('Herrera', 'cover', 100)
) AS v(preset, concept, rating) ON v.preset = p.name;

-- Lobanovskyi: every wired concept at 90 — the flat, high vector.
INSERT INTO game_style_preset_ratings (preset_id, concept, rating)
SELECT p.id, c.name, 90
FROM game_style_presets p,
     unnest(ARRAY['delay','marking','cover','support','outlet','runs',
                  'over-top','sweep','placement','line-hold','jockey-angle',
                  'recover','double-team','width','give-and-go','push-up',
                  'counter-press','balance','man-mark','verticality'])
       AS c(name)
WHERE p.name = 'Lobanovskyi';
