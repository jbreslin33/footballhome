-- 966-match-plan.sql (2026-11-03)
--
-- 🎯 Match plan — one Game Center section that runs a game in order, from
-- getting there to the tactics.  Owner 11/3: "we need a game warmup
-- section … or it can also be part of corner tactics and free kick
-- assignments etc. … it can go through everything from warmups to
-- tactics" — "before that should be a checklist for players to get to
-- game. then arrival, then dress, then non ball fifa 11. then a few
-- minutes to get themselves together and get water. then ball warmup.
-- 4v4+3. 4 outside players 2,3,7 & 11 vs the 4 inside players 6,8,10,9.
-- neutrals 4,5 and then 1 extra player who is not starting gets to be
-- neutral. he will be selected as next best player not starting … then
-- ref check in."  Everyone on the game reads it; coaches and club staff
-- edit the set pieces and tactics.
--
-- MATCH DAY — the timeline, in order.
--   match_day_stages          one step of the day: title, how-to, minutes,
--                             time_key (fh_events arrival/warmup/kickoff
--                             time shown on it), job_slug (the
--                             job_definitions slug whose holder leads it —
--                             migs 625/960/962/963/964).
--   match_day_checklist_items what a player has with them / has done to
--                             get to the game (the first stage).
--   event_checklist_ticks     a player's own tick on an item for one game.
--   warmup_routines           what a stage runs, per league (league_label
--                             NULL = every league).  level picks the step
--                             level for a routine that has levels (FIFA
--                             11+ Part 2 runs Level 1 / 2 / 3).
--   warmup_routine_sections   the blocks of a routine, with minutes.
--   warmup_steps              one exercise: number, title, sets, how-to;
--                             level NULL = every level.
--   warmup_routine_teams      the sides of a game-shaped drill (4v4+3):
--                             shirt numbers from the lineup's position
--                             numbers (positions.sort_order), plus
--                             bench_extras = how many of the first bench
--                             players (the coach's bench order = the next
--                             best not starting) join that side.
--                             bib_label/bib_color = what the side wears
--                             (owner 11/3: "blue shirt for training …
--                             double sided red / white pinnies … blue is
--                             always neutral … outside red, inside white").
--   warmup_routine_team_numbers  the shirt numbers of a side.
-- The no-ball warm-up is the FIFA 11+ (owner 11/3, FIFA Medical poster
-- https://digitalhub.fifa.com/transform/267e6937-b83a-478e-b585-a99196afe744/The-11-_FIFA-Medical).
-- [FIFA 11+] F-MARC injury-prevention programme — wording below is the
-- poster's, shortened.  The ball warm-up is the owner's 4v4+3 [FH].
--
-- SET PIECES — takers and marks per game.
--   set_piece_groups          Attacking corners, Defending corners, Free
--                             kicks, Penalties, Throw-ins.
--   set_piece_roles           a slot in a group (Corner taker — right
--                             side, Near post, …); needed_count = how many
--                             players the slot takes (the wall).
--   event_set_piece_picks     who fills a slot at one game.  A game with
--                             no picks shows its team's last game's picks
--                             until a coach saves (read, never copied).
--
-- TACTICS — event_match_plans.tactics: the coach's notes for the game,
-- under the formation and the opponent match-up already picked in the
-- lineup (mig 912).

-- ── Match day ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS match_day_stages (
    id           SERIAL PRIMARY KEY,
    slug         TEXT NOT NULL UNIQUE,
    title        TEXT NOT NULL,
    description  TEXT NOT NULL DEFAULT '',
    minutes      INT,
    time_key     TEXT CHECK (time_key IN ('arrival', 'warmup', 'kickoff')),
    job_slug     TEXT,                 -- job_definitions.slug of the leader
    sort_order   INT  NOT NULL DEFAULT 0,
    is_active    BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS match_day_checklist_items (
    id          SERIAL PRIMARY KEY,
    stage_id    INT  NOT NULL REFERENCES match_day_stages(id) ON DELETE CASCADE,
    slug        TEXT NOT NULL,
    title       TEXT NOT NULL,
    sort_order  INT  NOT NULL DEFAULT 0,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    UNIQUE (stage_id, slug)
);

CREATE TABLE IF NOT EXISTS event_checklist_ticks (
    fh_event_id  BIGINT NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    item_id      INT    NOT NULL REFERENCES match_day_checklist_items(id) ON DELETE CASCADE,
    person_id    INT    NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    ticked_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (fh_event_id, item_id, person_id)
);

CREATE TABLE IF NOT EXISTS warmup_routines (
    id            SERIAL PRIMARY KEY,
    stage_id      INT  NOT NULL REFERENCES match_day_stages(id) ON DELETE CASCADE,
    league_label  TEXT,               -- NULL = every league
    title         TEXT NOT NULL,
    source_url    TEXT,
    level         INT,                -- step level in use; NULL = no levels
    is_active     BOOLEAN NOT NULL DEFAULT true
);
CREATE UNIQUE INDEX IF NOT EXISTS warmup_routines_stage_league
    ON warmup_routines (stage_id, COALESCE(league_label, '')) WHERE is_active;

CREATE TABLE IF NOT EXISTS warmup_routine_sections (
    id          SERIAL PRIMARY KEY,
    routine_id  INT  NOT NULL REFERENCES warmup_routines(id) ON DELETE CASCADE,
    title       TEXT NOT NULL,
    minutes     INT,
    sort_order  INT  NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS warmup_steps (
    id          SERIAL PRIMARY KEY,
    section_id  INT  NOT NULL REFERENCES warmup_routine_sections(id) ON DELETE CASCADE,
    step_no     INT  NOT NULL,
    level       INT,                  -- NULL = every level
    title       TEXT NOT NULL,
    sets_label  TEXT NOT NULL DEFAULT '',
    description TEXT NOT NULL DEFAULT '',
    sort_order  INT  NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS warmup_routine_teams (
    id            SERIAL PRIMARY KEY,
    routine_id    INT  NOT NULL REFERENCES warmup_routines(id) ON DELETE CASCADE,
    slug          TEXT NOT NULL,
    title         TEXT NOT NULL,
    bench_extras  INT  NOT NULL DEFAULT 0,
    bib_label     TEXT NOT NULL DEFAULT '',  -- what the side wears
    bib_color     TEXT,                      -- swatch, CSS colour
    sort_order    INT  NOT NULL DEFAULT 0,
    UNIQUE (routine_id, slug)
);

CREATE TABLE IF NOT EXISTS warmup_routine_team_numbers (
    team_id   INT NOT NULL REFERENCES warmup_routine_teams(id) ON DELETE CASCADE,
    shirt_no  INT NOT NULL,
    PRIMARY KEY (team_id, shirt_no)
);

INSERT INTO match_day_stages (slug, title, description, minutes, time_key, job_slug, sort_order) VALUES
    ('get-there', 'Getting to the game', 'Tick these off before you leave.', NULL, NULL, NULL, 1),
    ('arrival',   'Arrive',              'Be at the field by the arrival time.', NULL, 'arrival', NULL, 2),
    ('dress',     'Get dressed',         'Kit on — jersey, shorts, socks, shin guards, boots — and ready for the warm-up.', NULL, NULL, NULL, 3),
    ('no-ball',   'Warm-up (no ball)',   'The FIFA 11+ — everyone, together.', 20, 'warmup', 'warmup', 4),
    ('regroup',   'Get yourselves together', 'A few minutes: water, boots, gear.', NULL, NULL, NULL, 5),
    ('ball',      'Warm-up (ball)',      '4v4+3 to keep the ball.', NULL, NULL, 'ball-warmup', 6),
    ('ref-check-in', 'Ref check-in',     'Line up for the referee''s check-in.', NULL, NULL, 'roster', 7),
    ('regroup-2', 'Get yourselves together again', 'Water, boots, gear — last chance before the walk out.', NULL, NULL, NULL, 8),
    ('walk-out',  'Walk out',            'Walk out together to the center of the field.', NULL, NULL, NULL, 9),
    ('huddle',    'Captain''s huddle',   'The captain gathers the team.', NULL, NULL, NULL, 10),
    ('kickoff',   'Kickoff',             '', NULL, 'kickoff', NULL, 11)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO match_day_checklist_items (stage_id, slug, title, sort_order)
SELECT s.id, v.slug, v.title, v.sort_order
  FROM match_day_stages s
 CROSS JOIN (VALUES
    ('rsvp',     'RSVP''d Going',                       1),
    ('ride',     'Ride sorted (🚗 Carpool if you need one)', 2),
    ('kit',      'Game kit: jersey, shorts, socks',     3),
    ('boots',    'Boots',                               4),
    ('shins',    'Shin guards',                         5),
    ('water',    'Water',                               6),
    ('id',       'Player ID / league card',             7),
    ('leave',    'Leave in time to make the arrival time', 8)
 ) AS v(slug, title, sort_order)
 WHERE s.slug = 'get-there'
ON CONFLICT (stage_id, slug) DO NOTHING;

-- The FIFA 11+, every league, Part 2 at Level 1.
INSERT INTO warmup_routines (stage_id, league_label, title, source_url, level)
SELECT s.id, NULL, 'FIFA 11+',
       'https://digitalhub.fifa.com/transform/267e6937-b83a-478e-b585-a99196afe744/The-11-_FIFA-Medical', 1
  FROM match_day_stages s
 WHERE s.slug = 'no-ball'
   AND NOT EXISTS (SELECT 1 FROM warmup_routines r WHERE r.stage_id = s.id AND r.league_label IS NULL AND r.is_active);

INSERT INTO warmup_routine_sections (routine_id, title, minutes, sort_order)
SELECT r.id, v.title, v.minutes, v.sort_order
  FROM warmup_routines r
  JOIN match_day_stages p ON p.id = r.stage_id AND p.slug = 'no-ball'
 CROSS JOIN (VALUES
    ('Part 1 · Running',                            8, 1),
    ('Part 2 · Strength · plyometrics · balance',  10, 2),
    ('Part 3 · Running',                            2, 3)
 ) AS v(title, minutes, sort_order)
 WHERE r.title = 'FIFA 11+' AND r.league_label IS NULL
   AND NOT EXISTS (SELECT 1 FROM warmup_routine_sections s WHERE s.routine_id = r.id);

INSERT INTO warmup_steps (section_id, step_no, level, title, sets_label, description, sort_order)
SELECT s.id, v.step_no, v.level, v.title, v.sets_label, v.description, v.step_no * 10 + COALESCE(v.level, 0)
  FROM warmup_routine_sections s
  JOIN warmup_routines r ON r.id = s.routine_id AND r.title = 'FIFA 11+' AND r.league_label IS NULL
  JOIN (VALUES
    (1, 1, NULL::int, 'Running: straight ahead', '2 sets',
        '6–10 pairs of parallel cones, 5–6 m apart. Two players start together at the first pair and jog together to the last. On the way back, build speed as you warm up.'),
    (1, 2, NULL, 'Running: hip out', '2 sets',
        'Walk or jog easily, stopping at each pair of cones to lift your knee and rotate your hip outwards. Alternate legs at successive cones.'),
    (1, 3, NULL, 'Running: hip in', '2 sets',
        'Walk or jog easily, stopping at each pair of cones to lift your knee and rotate your hip inwards. Alternate legs at successive cones.'),
    (1, 4, NULL, 'Running: circling partner', '2 sets',
        'Run as a pair to the first cones. Shuffle sideways 90° to meet in the middle, shuffle an entire circle around one another, then return to the cones. Stay on your toes, hips and knees bent.'),
    (1, 5, NULL, 'Running: shoulder contact', '2 sets',
        'Run as a pair to the first cones. Shuffle sideways 90° to meet in the middle, jump sideways towards each other for shoulder-to-shoulder contact. Land on both feet, hips and knees bent — knees never buckle inwards.'),
    (1, 6, NULL, 'Running: quick forwards & backwards', '2 sets',
        'As a pair, run quickly to the second set of cones, then run backwards quickly to the first, hips and knees slightly bent. Repeat: two cones forwards, one back. Small, quick steps.'),
    (2, 7, 1, 'The bench: static', '3 sets',
        'On your front, on forearms and feet, elbows under shoulders. Lift your body up, stomach in, hold 20–30 sec in a straight line — no sway, no arched back.'),
    (2, 7, 2, 'The bench: alternate legs', '3 sets',
        'Bench position on forearms and feet. Lift each leg in turn, holding for a count of 2 sec. Continue 40–60 sec. Body straight — no sway, no arched back.'),
    (2, 7, 3, 'The bench: one leg lift and hold', '3 sets',
        'Bench position on forearms and feet. Lift one leg 10–15 cm and hold 20–30 sec. Body straight, opposite hip does not dip. Short break, change legs, repeat.'),
    (2, 8, 1, 'Sideways bench: static', '3 sets each side',
        'On your side, lower knee bent 90°, on forearm and knee, elbow under shoulder. Lift upper leg and hips until shoulder, hip and knee are in a straight line. Hold 20–30 sec. Change sides.'),
    (2, 8, 2, 'Sideways bench: raise & lower hip', '3 sets each side',
        'On your side, both legs straight, on forearm and side of foot, body straight. Lower hip to the ground and raise it back up. Repeat 20–30 sec. Change sides.'),
    (2, 8, 3, 'Sideways bench: with leg lift', '3 sets each side',
        'Sideways bench on forearm and side of foot, body straight. Lift the upper leg and slowly lower it. Repeat 20–30 sec. Change sides.'),
    (2, 9, 1, 'Hamstrings: beginner', '1 set',
        'Kneel on a soft surface, partner holds your ankles. Body straight shoulder to knee, lean forward as far as you can control, then fall into a push-up. Minimum 3–5 reps and/or 60 sec.'),
    (2, 9, 2, 'Hamstrings: intermediate', '1 set',
        'Kneel on a soft surface, partner holds your ankles. Body straight shoulder to knee, lean forward as far as you can control, then fall into a push-up. Minimum 7–10 reps and/or 60 sec.'),
    (2, 9, 3, 'Hamstrings: advanced', '1 set',
        'Kneel on a soft surface, partner holds your ankles. Body straight shoulder to knee, lean forward as far as you can control, then fall into a push-up. Minimum 12–15 reps and/or 60 sec.'),
    (2, 10, 1, 'Single-leg stance: hold the ball', '2 sets',
        'Stand on one leg holding the ball in both hands, weight on the ball of your foot, knee never buckling inwards. Hold 30 sec, change legs. Harder: pass the ball around your waist or under your other knee.'),
    (2, 10, 2, 'Single-leg stance: throwing ball with partner', '2 sets',
        'Stand 2–3 m from your partner, each on one leg. Throw the ball to one another, stomach in, weight on the ball of your foot, knee slightly flexed. 30 sec, change legs.'),
    (2, 10, 3, 'Single-leg stance: test your partner', '2 sets',
        'On one leg, an arm''s length from your partner. Take turns trying to push each other off balance. Weight on the ball of your foot, knee never buckling inwards. 30 sec, change legs.'),
    (2, 11, 1, 'Squats: with toe raise', '2 sets',
        'Feet hip-width apart, hands on hips. Squat slowly until hips and knees reach 90°, knees not buckling inwards, straighten up more quickly, then rise onto your toes and slowly lower. 30 sec.'),
    (2, 11, 2, 'Squats: walking lunges', '2 sets',
        'Feet hip-width apart, hands on hips. Lunge forward slowly until hip and knee reach 90°, knee not buckling inwards, upper body and hips steady. Lunge across the pitch (about 10 each leg), jog back.'),
    (2, 11, 3, 'Squats: one-leg squats', '2 sets',
        'On one leg, loosely holding your partner. Slowly bend the knee as far as you can, knee not buckling inwards, then straighten slightly more quickly. 10 each leg.'),
    (2, 12, 1, 'Jumping: vertical jumps', '2 sets',
        'Feet hip-width apart, hands on hips. Bend until knees reach about 90°, hold 2 sec, then jump as high as you can. Land softly on the balls of your feet, hips and knees slightly bent. 30 sec.'),
    (2, 12, 2, 'Jumping: lateral jumps', '2 sets',
        'On one leg, upper body bent slightly forward. Jump about 1 m sideways onto the free leg, landing gently on the ball of your foot, hips and knees slightly bent, knee not buckling inwards. 30 sec.'),
    (2, 12, 3, 'Jumping: box jumps', '2 sets',
        'Feet hip-width apart, standing on an imaginary cross. Jump forwards and backwards, side to side and diagonally across it, quickly and explosively. Land softly, knees not buckling inwards. 30 sec.'),
    (3, 13, NULL, 'Running: across the pitch', '2 sets',
        'Run across the pitch, side to side, at 75–80% of maximum pace.'),
    (3, 14, NULL, 'Running: bounding', '2 sets',
        'High bounding steps with a high knee lift, landing gently on the ball of your foot, exaggerated arm swing (opposite arm and leg). Leading leg never crosses the midline, knees not buckling inwards. To the far side, jog back.'),
    (3, 15, NULL, 'Running: plant & cut', '2 sets',
        'Jog 4–5 steps, plant on the outside leg and cut to change direction. Sprint 5–7 steps at 80–90% pace, decelerate, plant and cut again. Knee not buckling inwards. To the far side, jog back.')
  ) AS v(section_no, step_no, level, title, sets_label, description) ON v.section_no = s.sort_order
 WHERE NOT EXISTS (SELECT 1 FROM warmup_steps w WHERE w.section_id = s.id);

-- The ball warm-up: 4v4+3, every league [FH, owner 11/3].  Outside four
-- (2, 3, 7, 11) against the inside four (6, 8, 10, 9); 4, 5 and the next
-- best player not starting (first on the coach's bench order) are the
-- neutrals — on the two ends of the rectangle and one in the middle
-- (owner 11/3).
INSERT INTO warmup_routines (stage_id, league_label, title, source_url, level)
SELECT s.id, NULL, '4v4+3', NULL, NULL
  FROM match_day_stages s
 WHERE s.slug = 'ball'
   AND NOT EXISTS (SELECT 1 FROM warmup_routines r WHERE r.stage_id = s.id AND r.league_label IS NULL AND r.is_active);

INSERT INTO warmup_routine_sections (routine_id, title, minutes, sort_order)
SELECT r.id, '4v4+3', NULL, 1
  FROM warmup_routines r JOIN match_day_stages s ON s.id = r.stage_id AND s.slug = 'ball'
 WHERE r.title = '4v4+3' AND r.league_label IS NULL
   AND NOT EXISTS (SELECT 1 FROM warmup_routine_sections x WHERE x.routine_id = r.id);

INSERT INTO warmup_steps (section_id, step_no, level, title, sets_label, description, sort_order)
SELECT x.id, 1, NULL, 'Keep the ball', '',
       'In a rectangle: the outside four against the inside four. Neutrals play with whichever side has the ball — 4 and 5 on the two ends of the rectangle, the bench neutral in the middle.', 1
  FROM warmup_routine_sections x
  JOIN warmup_routines r ON r.id = x.routine_id AND r.title = '4v4+3' AND r.league_label IS NULL
 WHERE NOT EXISTS (SELECT 1 FROM warmup_steps w WHERE w.section_id = x.id);

INSERT INTO warmup_routine_teams (routine_id, slug, title, bench_extras, bib_label, bib_color, sort_order)
SELECT r.id, v.slug, v.title, v.extras, v.bib, v.color, v.sort_order
  FROM warmup_routines r
  JOIN match_day_stages s ON s.id = r.stage_id AND s.slug = 'ball'
 CROSS JOIN (VALUES ('outside', 'Outside 4', 0, 'Red pinnies',          '#dc2626', 1),
                    ('inside',  'Inside 4',  0, 'White pinnies',        '#f8fafc', 2),
                    ('neutral', 'Neutrals',  1, 'Blue training shirts', '#2563eb', 3))
       AS v(slug, title, extras, bib, color, sort_order)
 WHERE r.title = '4v4+3' AND r.league_label IS NULL
ON CONFLICT (routine_id, slug) DO NOTHING;

INSERT INTO warmup_routine_team_numbers (team_id, shirt_no)
SELECT t.id, n
  FROM warmup_routine_teams t
  JOIN warmup_routines r ON r.id = t.routine_id AND r.title = '4v4+3' AND r.league_label IS NULL
  JOIN (VALUES ('outside', 2), ('outside', 3), ('outside', 7), ('outside', 11),
               ('inside', 6), ('inside', 8), ('inside', 10), ('inside', 9),
               ('neutral', 4), ('neutral', 5)) AS v(slug, n) ON v.slug = t.slug
ON CONFLICT DO NOTHING;

-- ── Set pieces ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS set_piece_groups (
    id          SERIAL PRIMARY KEY,
    slug        TEXT NOT NULL UNIQUE,
    title       TEXT NOT NULL,
    sort_order  INT  NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS set_piece_roles (
    id            SERIAL PRIMARY KEY,
    group_id      INT  NOT NULL REFERENCES set_piece_groups(id) ON DELETE CASCADE,
    slug          TEXT NOT NULL,
    title         TEXT NOT NULL,
    description   TEXT NOT NULL DEFAULT '',
    needed_count  INT  NOT NULL DEFAULT 1,
    sort_order    INT  NOT NULL DEFAULT 0,
    is_active     BOOLEAN NOT NULL DEFAULT true,
    UNIQUE (group_id, slug)
);

CREATE TABLE IF NOT EXISTS event_set_piece_picks (
    id                SERIAL PRIMARY KEY,
    fh_event_id       BIGINT NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    set_piece_role_id INT    NOT NULL REFERENCES set_piece_roles(id) ON DELETE CASCADE,
    person_id         INT    NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    slot              INT    NOT NULL DEFAULT 1,     -- 1..needed_count
    picked_by         INT    REFERENCES persons(id) ON DELETE SET NULL,
    picked_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (fh_event_id, set_piece_role_id, slot)
);
CREATE INDEX IF NOT EXISTS event_set_piece_picks_event ON event_set_piece_picks (fh_event_id);

INSERT INTO set_piece_groups (slug, title, sort_order) VALUES
    ('corners-for',     'Attacking corners', 1),
    ('corners-against', 'Defending corners', 2),
    ('free-kicks',      'Free kicks',        3),
    ('penalties',       'Penalties',         4),
    ('throw-ins',       'Throw-ins',         5)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO set_piece_roles (group_id, slug, title, description, needed_count, sort_order)
SELECT g.id, v.slug, v.title, v.description, v.needed, v.sort_order
  FROM (VALUES
    ('corners-for',     'taker-right',   'Taker — right side',      'Takes corners from the right.', 1, 1),
    ('corners-for',     'taker-left',    'Taker — left side',       'Takes corners from the left.', 1, 2),
    ('corners-for',     'near-post',     'Near post',               'Attacks the near post.', 1, 3),
    ('corners-for',     'far-post',      'Far post',                'Attacks the far post.', 1, 4),
    ('corners-for',     'penalty-spot',  'Penalty spot',            'Attacks the middle of the goal from the spot.', 1, 5),
    ('corners-for',     'keeper',        'On the keeper',           'Stands on the goalkeeper.', 1, 6),
    ('corners-for',     'edge',          'Edge of the box',         'Waits at the edge for the clearance.', 1, 7),
    ('corners-for',     'stay-back',     'Stay back',               'Stays back against the counter.', 2, 8),
    ('corners-against', 'near-post',     'Near post',               'Guards the near post.', 1, 1),
    ('corners-against', 'far-post',      'Far post',                'Guards the far post.', 1, 2),
    ('corners-against', 'zone',          'Six-yard zone',           'Holds the zone in front of the six-yard box.', 2, 3),
    ('corners-against', 'markers',       'Man-markers',             'Each takes one of their attackers.', 3, 4),
    ('corners-against', 'short',         'Short corner',            'Goes out to stop the short corner.', 1, 5),
    ('corners-against', 'outlet',        'Counter outlet',          'Stays up for the counter.', 1, 6),
    ('free-kicks',      'direct',        'Direct — shooter',        'Shoots free kicks in range.', 1, 1),
    ('free-kicks',      'cross-right',   'Crossing — right foot',   'Crosses wide free kicks with the right foot.', 1, 2),
    ('free-kicks',      'cross-left',    'Crossing — left foot',    'Crosses wide free kicks with the left foot.', 1, 3),
    ('free-kicks',      'wall',          'Our wall',                'Stands in the wall when they have a free kick in range.', 4, 4),
    ('penalties',       'taker',         'Taker',                   'Takes our penalties.', 1, 1),
    ('penalties',       'second',        'Second taker',            'Takes them if the first taker is off.', 1, 2),
    ('throw-ins',       'long-throw',    'Long throw',              'Takes long throws into the box.', 1, 1)
  ) AS v(group_slug, slug, title, description, needed, sort_order)
  JOIN set_piece_groups g ON g.slug = v.group_slug
ON CONFLICT (group_id, slug) DO NOTHING;

-- ── Tactics ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS event_match_plans (
    fh_event_id  BIGINT PRIMARY KEY REFERENCES fh_events(id) ON DELETE CASCADE,
    tactics      TEXT NOT NULL DEFAULT '',
    updated_by   INT REFERENCES persons(id) ON DELETE SET NULL,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Copy ────────────────────────────────────────────────────────────────
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Match plan', l, 'match_plan', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('title',          'Game Center section title',                    '🎯 Match plan', 960),
    ('hint',           'Section hint',                                  'The whole game in order — getting there, the warm-ups, the walk out, then set pieces and tactics.', 961),
    ('times',          'Times line ({arrival} {warmup} {kickoff})',     '[[Arrive {arrival} · ]][[Warm-up {warmup} · ]][[Kickoff {kickoff}]]', 962),
    ('day_h',          'Match day timeline heading',                    '🕐 Match day', 963),
    ('ready',          'Checklist count ({done} {total})',              '{done} of {total} ready', 985),
    ('open_no',        'Drill position nobody starts at ({n})',          '#{n} open', 986),
    ('bench_extra',    'Drill side: the next best not starting',        'next best on the bench', 987),
    ('lineup_first',   'Drill sides before the lineup is set',          'Sides fill in once the starting lineup is set.', 988),
    ('led_by',         'Who leads a warm-up ({names})',                 'Led by {names}', 964),
    ('no_leader',      'No one holds the warm-up job',                  'No leader yet — see the jobs.', 965),
    ('no_routine',     'Warm-up part with no routine yet',              'Routine coming.', 966),
    ('level',          'Level of a levelled routine ({level})',         'Level {level}', 967),
    ('minutes',        'Minutes of a block ({n})',                      '{n} min', 968),
    ('source',         'Link to the routine''s source',                 'Poster', 969),
    ('setpieces_h',    'Set pieces heading',                            '🚩 Set pieces', 970),
    ('from_last',      'Picks shown from the team''s last game ({when})','From the last game ({when}) — save to keep them for this one.', 971),
    ('none_picked',    'Slot with nobody in it',                        '—', 972),
    ('pick',           'Dropdown placeholder',                          'Pick…', 973),
    ('squad_group',    'Dropdown group: the game-day squad',            'Squad', 974),
    ('others_group',   'Dropdown group: rest of the roster',            'Others', 975),
    ('mine',           'Player''s own set-piece jobs ({roles})',        'Your set pieces: {roles}', 976),
    ('save',           'Save button',                                   '💾 Save plan', 977),
    ('saved',          'Saved toast',                                   '✓ Match plan saved', 978),
    ('save_failed',    'Save failed ({reason})',                        'Could not save: {reason}', 979),
    ('tactics_h',      'Tactics heading',                               '♟️ Tactics', 980),
    ('formation',      'Formation line ({formation})',                  'Shape: {formation}', 981),
    ('matchup',        'Opponent match-up line ({matchup})',            'Against: {matchup}', 982),
    ('tactics_ph',     'Tactics notes placeholder',                     'Key points for this game — pressing, build-up, who marks their danger man…', 983),
    ('no_tactics',     'No tactics notes yet (players)',                'No notes from the coach yet.', 984)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'match_plan' AND m.tier = v.t);

-- ── Who reads / who edits ───────────────────────────────────────────────
-- Reads: everyone on the game — rostered on a tagged team (call-up-gated
-- teams and paper spots only through an invite), an open invite, a parent
-- of one of those, a coach of a tagged team, club staff (the carpool
-- audience, CarpoolController kParty).  Edits: a coach of a tagged team
-- or club staff; club/super admins pass in the controller.
CREATE OR REPLACE FUNCTION fh_match_plan_editor(p_fh_event_id BIGINT, p_person_id INTEGER)
RETURNS BOOLEAN LANGUAGE sql STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM fh_event_teams fet
                   JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
                   JOIN coaches co ON co.id = tc.coach_id
                  WHERE fet.fh_event_id = p_fh_event_id AND co.person_id = p_person_id)
      OR fh_event_staff(p_fh_event_id, p_person_id)
$$;

CREATE OR REPLACE FUNCTION fh_match_plan_reader(p_fh_event_id BIGINT, p_person_id INTEGER)
RETURNS BOOLEAN LANGUAGE sql STABLE AS $$
  WITH party AS (
      SELECT tp.person_id FROM fh_event_teams fet
        JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.removed_at IS NULL
                            AND NOT fh_team_callup_only(tp.team_id) AND NOT tp.invite_only
       WHERE fet.fh_event_id = p_fh_event_id
      UNION
      SELECT i.person_id FROM fh_event_invites i
       WHERE i.fh_event_id = p_fh_event_id AND i.revoked_at IS NULL)
  SELECT EXISTS (SELECT 1 FROM party WHERE person_id = p_person_id)
      OR EXISTS (SELECT 1 FROM party pa WHERE fh_is_guardian(p_person_id, pa.person_id))
      OR fh_match_plan_editor(p_fh_event_id, p_person_id)
$$;
