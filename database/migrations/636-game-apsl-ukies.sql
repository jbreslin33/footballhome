-- 636 (2026-10-22) — game: Lighthouse APSL vs Ukrainian Nationals, with
-- per-player ATTRIBUTES (game/DESIGN.md §8.26).
--
-- James: "lets make Lighthouse APSL vs Ukrainian Nationals. Ukies in 4231
-- us matching in our -1, +1 bielsa system so would end up a 433 but
-- flexible. … use ukies roster. use our apsl 'rsvp' able guys. give our
-- guys random attributes and i can fix them and describe the type of
-- player. give ukies random attributes. remember we have a lot more
-- concepts and skills and attributes to add over time. this will be an
-- attempt to start a game realistic for apsl".
--
-- This REVERSES mig 628's fictional-only rule for these two teams at
-- James's request: real people play here. No names are written in this
-- file — players are copied from the club's own rows when it runs
-- (CONVENTIONS: third-party PII lives in the DB, never in git).
--
-- 1. game_attributes — the attribute registry. 0-100 per player, 50 = the
--    team's level band exactly; only WIRED attributes get rows (each names
--    the engine number it scales). New attributes = new rows + wiring.
-- 2. game_demo_player_attributes — one rating per player per attribute.
-- 3. game_demo_players grows person_id (the real person, when there is
--    one), position (the formation slot label it boots in) and
--    description (James's words for the type of player).
-- 4. game_demo_teams grows formation_code (club `formations`; overrides
--    GAME_FORMATION_* for that team).
-- 5. The two teams. Shirt order = formation slot order (1 = GK …); 12+
--    = bench (loaded in order, not yet on the pitch).

CREATE TABLE IF NOT EXISTS game_attributes (
    code         TEXT PRIMARY KEY,
    name         TEXT NOT NULL,
    category     TEXT NOT NULL CHECK (category IN ('physical', 'technical', 'mental', 'goalkeeping')),
    description  TEXT NOT NULL,
    scales       TEXT NOT NULL,          -- the engine number it moves (game/src/core/Levels.hpp)
    sort_order   INT NOT NULL
);

INSERT INTO game_attributes (code, name, category, description, scales, sort_order) VALUES
 ('pace',         'Pace',         'physical',    'Top running speed.',
  'max_speed: 5.4 m/s at 0 … 6.4 at 50 … 7.4 at 100', 10),
 ('passing',      'Passing',      'technical',   'Accuracy and weight of passes and lofted balls.',
  'kick_angle_err_deg + kick_power_err_pct on passes (x1.5 at 0, x1 at 50, x0.5 at 100)', 20),
 ('shooting',     'Shooting',     'technical',   'Accuracy and weight of shots.',
  'shot angle/power error (x1.5 at 0, x1 at 50, x0.5 at 100)', 30),
 ('first_touch',  'First touch',  'technical',   'How fast a ball he can kill dead (and so how hard he can strike).',
  'control_speed_mps (x0.75 at 0, x1 at 50, x1.25 at 100)', 40),
 ('tackling',     'Tackling',     'technical',   'Chance a committed tackle wins the ball.',
  'tackle_success_pct (-30 at 0, band at 50, +30 at 100; 5-95)', 50),
 ('anticipation', 'Anticipation', 'mental',      'How early he reads the play off the ball.',
  'perception_delay_ticks (x1.5 at 0, x1 at 50, x0.5 at 100)', 60),
 ('decisions',    'Decisions',    'mental',      'How cleanly he picks the right option.',
  'decision_jitter_pct (x1.5 at 0, x1 at 50, x0.5 at 100)', 70),
 ('goalkeeping',  'Goalkeeping',  'goalkeeping', 'Keeper reactions and safe hands.',
  'keeper_reaction_ticks + keeper_fumble_pct (x1.5 at 0, x1 at 50, x0.5 at 100)', 80)
ON CONFLICT (code) DO NOTHING;
COMMENT ON TABLE game_attributes IS 'Game v2 player attribute registry (mig 636): 0-100, 50 = the level band; each row names the engine number it scales.';

ALTER TABLE game_demo_teams   ADD COLUMN IF NOT EXISTS formation_code TEXT;
ALTER TABLE game_demo_players ADD COLUMN IF NOT EXISTS person_id   INT REFERENCES persons(id) ON DELETE SET NULL;
ALTER TABLE game_demo_players ADD COLUMN IF NOT EXISTS position    TEXT;
ALTER TABLE game_demo_players ADD COLUMN IF NOT EXISTS description TEXT;

CREATE TABLE IF NOT EXISTS game_demo_player_attributes (
    team_id    INT  NOT NULL,
    shirt      INT  NOT NULL,
    attribute  TEXT NOT NULL REFERENCES game_attributes(code),
    rating     SMALLINT NOT NULL CHECK (rating BETWEEN 0 AND 100),
    PRIMARY KEY (team_id, shirt, attribute),
    FOREIGN KEY (team_id, shirt) REFERENCES game_demo_players(team_id, shirt) ON DELETE CASCADE
);
COMMENT ON TABLE game_demo_player_attributes IS 'One game_attributes rating per demo player (mig 636); a missing row = 50 (the band).';

INSERT INTO game_demo_teams (name, level_band, style_preset, formation_code) VALUES
    ('Lighthouse APSL',     'semipro', 'Lighthouse', '4-3-3'),
    ('Ukrainian Nationals', 'semipro', NULL,         '4-2-3-1')
ON CONFLICT (name) DO NOTHING;

-- ── Lighthouse APSL: the RSVP-able APSL roster (team 35, active, not an
-- invite-only paper spot — mig 619), seated in the 4-3-3 by the position
-- each last played in a Game Center lineup. Greedy: each slot in order
-- takes the free player whose last position fits it best; leftovers fill
-- empty slots, then the bench.
DO $$
DECLARE
    tid INT := (SELECT id FROM game_demo_teams WHERE name = 'Lighthouse APSL');
    slots TEXT[] := ARRAY['GK','RB','CB','CB','LB','CM','CM','CM','RW','ST','LW'];
    fit JSONB := '{
      "GK": ["Goalkeeper"],
      "RB": ["Right Back","Right Midfielder","Center Back","Center Back B"],
      "LB": ["Left Back","Left Midfielder","Center Back","Center Back B"],
      "CB": ["Center Back","Center Back B","Defensive Midfielder","Defensive Midfielder B","Right Back","Left Back"],
      "CM": ["Defensive Midfielder","Defensive Midfielder B","Central Midfielder","Attacking Midfielder","Right Midfielder","Left Midfielder"],
      "RW": ["Right Midfielder","Right Winger","Striker B","Striker","Left Midfielder"],
      "LW": ["Left Midfielder","Left Winger","Striker B","Striker","Right Midfielder"],
      "ST": ["Striker","Striker B","Attacking Midfielder"]
    }';
    s INT; lbl TEXT; pid INT; shirt INT := 0;
BEGIN
    IF tid IS NULL OR EXISTS (SELECT 1 FROM game_demo_players WHERE team_id = tid) THEN RETURN; END IF;
    CREATE TEMP TABLE apsl ON COMMIT DROP AS
    SELECT tp.person_id,
           COALESCE(NULLIF(trim(pe.first_name || ' ' || pe.last_name), ''), 'Player ' || tp.person_id) AS name,
           (SELECT pos.name FROM match_lineups ml
              JOIN players pl ON pl.id = ml.player_id
              JOIN positions pos ON pos.id = ml.position_id
             WHERE pl.person_id = tp.person_id AND ml.team_id = 35 AND ml.is_starter
             ORDER BY ml.created_at DESC LIMIT 1) AS last_pos,
           false AS taken
      FROM team_persons tp JOIN persons pe ON pe.id = tp.person_id
     WHERE tp.team_id = 35 AND tp.removed_at IS NULL AND NOT COALESCE(tp.invite_only, false);
    FOR s IN 1 .. array_length(slots, 1) LOOP
        lbl := slots[s];
        SELECT a.person_id INTO pid FROM apsl a
         WHERE NOT a.taken
         ORDER BY COALESCE((SELECT o FROM jsonb_array_elements_text(fit -> lbl) WITH ORDINALITY AS f(p, o)
                             WHERE f.p = a.last_pos), 99),
                  (a.last_pos IS NULL), a.person_id
         LIMIT 1;
        EXIT WHEN pid IS NULL;
        UPDATE apsl SET taken = true WHERE person_id = pid;
        shirt := shirt + 1;
        INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, person_id, position)
        SELECT tid, shirt, a.name, 640, a.person_id, lbl FROM apsl a WHERE a.person_id = pid;
    END LOOP;
    FOR pid IN SELECT person_id FROM apsl WHERE NOT taken ORDER BY last_pos NULLS LAST, person_id LOOP
        shirt := shirt + 1;
        INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, person_id, position)
        SELECT tid, shirt, a.name, 640, a.person_id, 'SUB' FROM apsl a WHERE a.person_id = pid;
    END LOOP;
END $$;

-- ── Ukrainian Nationals (team 46): the six players the club has on file
-- (all marked left — an older roster; used anyway), then
-- numbered placeholders up to eleven (the full APSL roster isn't in the DB
-- yet — James to supply). 4-2-3-1 slot order.
DO $$
DECLARE
    tid INT := (SELECT id FROM game_demo_teams WHERE name = 'Ukrainian Nationals');
    slots TEXT[] := ARRAY['GK','RB','CB','CB','LB','CDM','CDM','RW','CAM','LW','ST'];
    r RECORD; shirt INT := 0;
BEGIN
    IF tid IS NULL OR EXISTS (SELECT 1 FROM game_demo_players WHERE team_id = tid) THEN RETURN; END IF;
    FOR r IN SELECT DISTINCT ON (pe.id) pe.id AS person_id,
                    COALESCE(NULLIF(trim(pe.first_name || ' ' || pe.last_name), ''), 'Ukies player') AS name
               FROM rosters ro JOIN players pl ON pl.id = ro.player_id JOIN persons pe ON pe.id = pl.person_id
              WHERE ro.team_id = 46   -- every row on file has left_at set (an older roster)
              ORDER BY pe.id LIMIT 11 LOOP
        shirt := shirt + 1;
        INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, person_id, position)
        VALUES (tid, shirt, r.name, 640, r.person_id, slots[shirt]);
    END LOOP;
    WHILE shirt < 11 LOOP
        shirt := shirt + 1;
        INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, position)
        VALUES (tid, shirt, 'Ukies #' || shirt, 640, slots[shirt]);
    END LOOP;
END $$;

-- ── Random attributes (James: "random … i can fix them"): 40-75 for
-- outfield skills, keepers 60-80 in goal and outfielders 15-35 there.
-- Deterministic per player (hashtext), so re-running gives the same draw.
INSERT INTO game_demo_player_attributes (team_id, shirt, attribute, rating)
SELECT p.team_id, p.shirt, a.code,
       CASE WHEN a.code = 'goalkeeping' AND p.position = 'GK' THEN 60 + abs(hashtext(p.team_id || ':' || p.shirt || ':' || a.code)) % 21
            WHEN a.code = 'goalkeeping'                       THEN 15 + abs(hashtext(p.team_id || ':' || p.shirt || ':' || a.code)) % 21
            ELSE 40 + abs(hashtext(p.team_id || ':' || p.shirt || ':' || a.code)) % 36 END
  FROM game_demo_players p
  JOIN game_demo_teams t ON t.id = p.team_id AND t.name IN ('Lighthouse APSL', 'Ukrainian Nationals')
 CROSS JOIN game_attributes a
ON CONFLICT DO NOTHING;
