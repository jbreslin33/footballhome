-- 243-us-soccer-game-model-full-population.sql (2026-07-21)
-- Full normalized population of the U.S. Soccer U17+ Game Model, verbatim
-- from the source document, for Lighthouse 1893 SC (club_id 134) — the
-- only club actually using this feature. See
-- docs/game-model/us-soccer-full-extraction.md for the complete extraction
-- this migration is transcribed from (all 42 slides read/verified).
--
-- Schema note: the source models Player Actions as exactly TWO shared
-- catalogs of categories (each category has many bullet-point skill
-- definitions), each referenced by two phases:
--   - "in-possession" catalog: fully defined under Attacking, reused
--     (by category name only) under Defending-to-Attacking Transition.
--   - "out-of-possession" catalog: fully defined under Defending, reused
--     under Attacking-to-Defending Transition.
-- This is modeled as catalog -> category -> item tables plus a
-- phase <-> catalog join table so shared content is stored exactly once
-- (no duplicated rows across the two phases that reference each catalog).
--
-- No phase/principle/catalog ids are hardcoded below; every reference is
-- resolved dynamically via club_id + slug lookups so this migration is
-- safe to run against any environment regardless of serial id values.

BEGIN;

-- Drop the orphaned many-to-many scaffold from migration 235: it was
-- populated once for all clubs, then orphaned when principles were
-- rebuilt for club 134 (0 rows remain; no application code references
-- it). club_game_model_principles.phase_id already provides the direct
-- phase relationship, and the source document does not share principles
-- across phases (only player-action categories are shared).
DROP TABLE IF EXISTS club_game_model_phase_principles;

-- Replace the old flat/duplicating player-actions table with a proper
-- catalog -> category -> item schema (see note above).
DROP TABLE IF EXISTS club_game_model_player_actions;

CREATE TABLE club_game_model_action_catalogs (
    id bigserial PRIMARY KEY,
    club_id integer NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    slug text NOT NULL,
    title text NOT NULL,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (club_id, slug)
);

CREATE TABLE club_game_model_action_categories (
    id bigserial PRIMARY KEY,
    catalog_id bigint NOT NULL REFERENCES club_game_model_action_catalogs(id) ON DELETE CASCADE,
    slug text NOT NULL,
    title text NOT NULL,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (catalog_id, slug)
);

CREATE TABLE club_game_model_action_items (
    id bigserial PRIMARY KEY,
    category_id bigint NOT NULL REFERENCES club_game_model_action_categories(id) ON DELETE CASCADE,
    description text NOT NULL,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE club_game_model_phase_action_catalogs (
    phase_id bigint NOT NULL REFERENCES club_game_model_phases(id) ON DELETE CASCADE,
    catalog_id bigint NOT NULL REFERENCES club_game_model_action_catalogs(id) ON DELETE CASCADE,
    sort_order integer NOT NULL DEFAULT 0,
    PRIMARY KEY (phase_id, catalog_id)
);

CREATE INDEX idx_club_game_model_action_categories_catalog_id
    ON club_game_model_action_categories (catalog_id, sort_order, id);
CREATE INDEX idx_club_game_model_action_items_category_id
    ON club_game_model_action_items (category_id, sort_order, id);
CREATE INDEX idx_club_game_model_phase_action_catalogs_phase_id
    ON club_game_model_phase_action_catalogs (phase_id, sort_order);

-- ---------------------------------------------------------------------
-- Clear club 134's existing (incomplete/incorrect) principles and
-- definitions so they can be re-seeded verbatim from
-- docs/game-model/us-soccer-full-extraction.md below.
-- ---------------------------------------------------------------------
DELETE FROM club_game_model_principle_definitions
WHERE principle_id IN (
  SELECT pr.id FROM club_game_model_principles pr
  JOIN club_game_model_phases p ON p.id = pr.phase_id
  WHERE p.club_id = 134
);
DELETE FROM club_game_model_principles
WHERE phase_id IN (SELECT id FROM club_game_model_phases WHERE club_id = 134);
DELETE FROM club_game_model_phase_definitions
WHERE phase_id IN (SELECT id FROM club_game_model_phases WHERE club_id = 134);

-- ---------------------------------------------------------------------
-- 1. Correct club 134's phase descriptions to the verbatim Game Idea text
--    (previously a shortened paraphrase shared as generic template text).
-- ---------------------------------------------------------------------
UPDATE club_game_model_phases SET description = $$When in possession, we want to dominate by advancing the ball quickly in the attacking half with high energy and high tempo. Create balance with a minimum of 5 players ahead of the ball and use our positioning to create an advantage over the opponent, create goal scoring chances, and score.$$
WHERE club_id = 134 AND slug = 'attacking';

UPDATE club_game_model_phases SET description = $$When out of possession, we want to dominate by making play predictable and creating conditions to win the ball back as early and as high up the field as possible. Make the field small, reduce the opponent's time, space, and options.$$
WHERE club_id = 134 AND slug = 'defending';

UPDATE club_game_model_phases SET description = $$When we regain possession, we immediately think and play forward, look to attack aggressively with maximum speed and finish as fast as possible. When we recognize the opponent is balanced and organized, we keep the ball and move into our attacking shape.$$
WHERE club_id = 134 AND slug = 'defending-to-attacking-transition';

UPDATE club_game_model_phases SET description = $$When we lose possession, we want to regain the ball early and as high up the field as possible, by reacting immediately with maximum intensity and aggression. When we recognize we are unable to pressure the ball, we recover quickly into a compact shape.$$
WHERE club_id = 134 AND slug = 'attacking-to-defending-transition';

-- Re-seed the "Game Idea" phase_definitions rows deleted above, copying
-- the verbatim descriptions just set on club_game_model_phases.
INSERT INTO club_game_model_phase_definitions (phase_id, slug, title, definition, sort_order)
SELECT id, slug || '-game-idea', 'Game Idea', description, 1
FROM club_game_model_phases
WHERE club_id = 134;

-- ---------------------------------------------------------------------
-- 2. ATTACKING (slug 'attacking') — 5 main principles
-- ---------------------------------------------------------------------
INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order) VALUES
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'create-attacking-shape', 'main', 'Create Attacking Shape', 'Position to stretch opponent and create space', 1),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'provide-options-to-play-forward', 'main', 'Provide Options to Play Forward', '(Re-)position to create advantage and receive the ball', 2),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'break-lines-to-advance-attack', 'main', 'Break Lines to Advance Attack', 'Progress the ball forward and eliminate opponent(s)', 3),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'take-countermeasures-anticipate-opponent-counter', 'main', 'Take Countermeasures: Anticipate Opponent Counter', 'Position to protect against counterattack', 4),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'finish-the-attack', 'main', 'Finish the Attack', 'Create scoring opportunity and score', 5);

INSERT INTO club_game_model_principles (phase_id, slug, level, title, sort_order, parent_principle_id) VALUES
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'create-appropriate-height-width-depth', 'sub', 'Create appropriate height, width, depth', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'create-attacking-shape')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'create-optimal-attacking-distances-between-players', 'sub', 'Create optimal attacking distances between players', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'create-attacking-shape')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'provide-vertical-or-diagonal-passing-options', 'sub', 'Provide vertical or diagonal passing options', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'provide-options-to-play-forward')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'create-overload-centrally-or-wide', 'sub', 'Create overload centrally or wide', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'provide-options-to-play-forward')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'move-or-lose-opponent-when-marked', 'sub', 'Move or lose opponent when marked', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'provide-options-to-play-forward')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'make-runs-behind-the-defensive-line', 'sub', 'Make runs behind the defensive line', 4, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'provide-options-to-play-forward')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'give-immediate-support-to-teammate-under-pressure', 'sub', 'Give immediate support to teammate under pressure', 5, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'provide-options-to-play-forward')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'drive-with-the-ball-to-exploit-space', 'sub', 'Drive with the ball to exploit space', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'break-lines-to-advance-attack')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'engage-opponent-create-1v1-or-2v1', 'sub', 'Engage opponent: create 1v1 or 2v1', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'break-lines-to-advance-attack')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'find-a-free-player-between-or-behind-the-lines', 'sub', 'Find a free player between or behind the lines', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'break-lines-to-advance-attack')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'switch-play-pass-the-ball-to-opponents-weak-zone', 'sub', 'Switch play: pass the ball to opponent''s weak zone', 4, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'break-lines-to-advance-attack')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'push-up-the-defensive-line-with-speed-attack', 'sub', 'Push up the defensive line with speed: stay connected and compact', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'take-countermeasures-anticipate-opponent-counter')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'create-high-defensive-shape-behind-the-ball', 'sub', 'Create high defensive shape behind the ball', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'take-countermeasures-anticipate-opponent-counter')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'separate-time-run-or-quick-movement-to-unmark', 'sub', 'Separate: time run or quick movement to unmark', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'finish-the-attack')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'final-pass-through-ball-or-combination-play', 'sub', 'Final pass: through ball or combination play', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'finish-the-attack')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'numbers-in-the-box-fill-zones-in-front-of-goal', 'sub', 'Numbers in the box: fill zones in front of goal', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'finish-the-attack')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'cross-into-space-or-player', 'sub', 'Cross: into space or player', 4, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'finish-the-attack')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'take-on-1v1-to-create-or-score', 'sub', 'Take on 1v1 to create or score', 5, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'finish-the-attack')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), 'finish-use-limited-touches-attack', 'sub', 'Finish: use limited touches', 6, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'finish-the-attack'));

INSERT INTO club_game_model_principle_definitions (principle_id, slug, title, definition, sort_order) VALUES
((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'create-appropriate-height-width-depth'), 'definition', 'Definition', $$Attacking players position as high as possible:
- Pin or move the opponent's back line to stretch the opponent's team in length.
- Lower the level of vertical compactness of opponent:
  - Create more space between the opponent's defensive lines (specifically, between the opponent's back line and midfield).
Wide forwards and/or fullbacks (wide players):
- Position wide while avoiding two players in a direct line: position attack across different lanes
- Lower level of horizontal (sideline to sideline) compactness of opponent
  - Create more space centrally: creating passing lanes into the opponent's block
  or
  - Take advantage of space in wide areas
Center backs and/or fullbacks (occasionally midfielders):
- Position behind the ball in supporting position.
- Lower the level of vertical compactness of opponent:
  - Create enough space to create strong ball circulation
  - Enable a switch of play$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'create-optimal-attacking-distances-between-players'), 'definition', 'Definition', $$Spread out with optimal passing distance between players.
Create relationships - connections between players.
Exploit space in opponent's defending team shape.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'provide-vertical-or-diagonal-passing-options'), 'definition', 'Definition', $$Exploit the space in and around the opponent's defensive block and create a positional advantage:
- Avoid two players in a direct line.
- Move and provide a good supporting angle: receive facing forward to play forward when possible.
- Stay away from the ball when player on the ball has time and space to play forward.
Triangulate: we position to provide the player on the ball with at least two forward (diagonal/vertical) passing options on different levels of height and width.
Rotate: interchange position to create a dynamic advantage.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'create-overload-centrally-or-wide'), 'definition', 'Definition', $$Create a numerical advantage in a specific area of the field:
- Position to outnumber opponent in the area around the ball or area away from the ball
- Allow more players to attack - penetrations of midfielders or defenders
- Drop midfielders or attackers
If marked move to open space or move to open the space:$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'move-or-lose-opponent-when-marked'), 'definition', 'Definition', $$Lose opponent to receive the ball
- Distance from defender in space (get unmarked)/ move between the lines
Move opponent to receive the ball
- Draw opponent out of defending position to create space for self to receive (requires explosive change of direction)
Move to create space and passing options for teammate to receive
- Draw opponent out of defending position to create space for teammate to exploit and receive ball$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'make-runs-behind-the-defensive-line'), 'definition', 'Definition', $$Make run when player on the ball is facing forward and has no pressure or has pressure but can play forward
Use different runs and time run to avoid offside (straight run, curved run, ...)
Receive the ball facing forward$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'give-immediate-support-to-teammate-under-pressure'), 'definition', 'Definition', $$Recognize the player on the ball is under pressure and has no immediate options:
- Above the ball: move towards the ball to create a passing option
- Behind the ball: adjust position to create passing option$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'drive-with-the-ball-to-exploit-space'), 'definition', 'Definition', $$Recognize and exploit space.
Accelerate play through dribble: individually progress the ball into space with change of tempo.
Attract opponent (draw attention).$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'engage-opponent-create-1v1-or-2v1'), 'definition', 'Definition', $$Dribble and look for 1v1 or 2v1:
- Engage to isolate opponent:
- Eliminate through dribble: take opponent on in 1v1
- Eliminate through pass or give and go
Move or hold the ball to attract opponent:
- Move the opponent, invite pressure to create space for teammate.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'find-a-free-player-between-or-behind-the-lines'), 'definition', 'Definition', $$Pass quickly, accurately and with appropriate pace to a free player.
Skip a line: recognize opportunity & take risk: look furthest first, look nearest second.
Pass dictates the action: pass with intent.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'switch-play-pass-the-ball-to-opponents-weak-zone'), 'definition', 'Definition', $$Draw opponent to one side and find space on the opposite side:
- Direct change of point: long pass
- Indirect change of point: short pass$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'push-up-the-defensive-line-with-speed-attack'), 'definition', 'Definition', $$Provide balance (numbers).
We all move with the same speed and lose space in between lines that the opponent could exploit.
Create as high a line as possible.
GK take high position: stay connected with the backline.
- GK anticipate long pass from opponent and adjust quickly.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'create-high-defensive-shape-behind-the-ball'), 'definition', 'Definition', $$Defensive positioning by the players who are no longer directly involved in moving the ball forward.
Anticipate losing the ball and occupy positions to defend the opponent's counterattack.
- Defend the center of the field: block passing lanes
- Lock down the opponent's outlet(s): mark transition players$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'separate-time-run-or-quick-movement-to-unmark'), 'definition', 'Definition', $$Move into a position in and around the box to score or assist:
- Forward run behind the opponent's back line from a high position (attacking position)
- Forward run behind the opponent's back line from a deeper position (midfield position)
- Move out of sight to receive
Counter movement: opposite movement between two players
Quick movement from opponent to create space
Disguised pass to manipulate opponent$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'final-pass-through-ball-or-combination-play'), 'definition', 'Definition', $$Pass quickly, accurately and with appropriate pace:
- Through ball or chip ball to player who runs in behind
- Pass to unmarked player in or around the box
Quick combination play between 2 or more players to find a teammate in a goalscoring position
Recognize the player in the better position.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'numbers-in-the-box-fill-zones-in-front-of-goal'), 'definition', 'Definition', $$Efficient occupation of zones in the box on cross: near post, back post, penalty spot, edge of box
- Time your run in the box
- Get unmarked or in front of opponent
- Attack the ball$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'cross-into-space-or-player'), 'definition', 'Definition', $$Time the cross in front or behind the backline
- Recognize space (positioning of goalkeeper and defenders)
- Recognize the positions and runs of teammates in penalty box$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'take-on-1v1-to-create-or-score'), 'definition', 'Definition', $$Eliminate opponent through dribble to create goalscoring opportunity
Shoot from (short/long) distance$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking') AND slug = 'finish-use-limited-touches-attack'), 'definition', 'Definition', $$Finish off the cross: choose your final touch
React quickly on rebounds$$, 1);

-- ---------------------------------------------------------------------
-- 3. ATTACKING TO DEFENDING TRANSITION (slug 'attacking-to-defending-transition') — 5 main principles
-- ---------------------------------------------------------------------
INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order) VALUES
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'apply-immediate-pressure-on-the-ball', 'main', 'Apply Immediate Pressure on the Ball', 'React quickly to win the ball back and stop opponents'' forward play', 1),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'delay-the-counterattack-atd', 'main', 'Delay the Counterattack', 'Drop and narrow, reduce speed of opponents to allow players to recover', 2),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'recover-with-speed-atd', 'main', 'Recover with Speed', 'Sprint back to get balanced, organized and apply pressure', 3),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'take-countermeasures-anticipate-the-counter-atd', 'main', 'Take Countermeasures: Anticipate the Counter', 'Position to prepare the counterattack', 4),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'deny-finish-from-counterattack', 'main', 'Deny Finish from Counterattack', 'Deny scoring opportunity and prevent scoring', 5);

INSERT INTO club_game_model_principles (phase_id, slug, level, title, sort_order, parent_principle_id) VALUES
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'press-to-regain-or-prevent-progress-of-the-ball', 'sub', 'Press to regain or prevent progress of the ball', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'apply-immediate-pressure-on-the-ball')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'provide-cover-and-balance-eliminate-options', 'sub', 'Provide cover and balance: eliminate options', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'apply-immediate-pressure-on-the-ball')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'drop-off-and-block-direct-path-to-goal', 'sub', 'Drop off and block direct path to goal', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'apply-immediate-pressure-on-the-ball')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'slow-down-and-dictate-opponent', 'sub', 'Slow down and dictate opponent', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'delay-the-counterattack-atd')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'get-numbers-back-quickly-and-take-defensive-position', 'sub', 'Get numbers back quickly and take defensive position', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'recover-with-speed-atd')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'press-from-behind-as-quickly-as-possible', 'sub', 'Press from behind as quickly as possible', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'recover-with-speed-atd')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'stay-connected-look-to-win-the-second-ball', 'sub', 'Stay connected: look to win the second ball', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'recover-with-speed-atd')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'create-passing-options-between-the-lines-atd', 'sub', 'Create passing option(s): between the lines', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'take-countermeasures-anticipate-the-counter-atd')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'create-passing-options-look-to-run-in-behind-atd', 'sub', 'Create passing option(s): look to run in behind', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'take-countermeasures-anticipate-the-counter-atd')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'defend-the-goal-and-create-conditions-to-engage', 'sub', 'Defend the goal and create conditions to engage', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'deny-finish-from-counterattack')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), 'challenge-to-protect-against-a-goal-attempt', 'sub', 'Challenge to protect against a goal attempt', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'deny-finish-from-counterattack'));

INSERT INTO club_game_model_principle_definitions (principle_id, slug, title, definition, sort_order) VALUES
((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'press-to-regain-or-prevent-progress-of-the-ball'), 'definition', 'Definition', $$Recognize situations when to press or hold and force wide (awareness).
Win the ball when opportunity to regain (distance, numbers and levels of compactness).
Nearest player(s):
- React immediately, reduce space with speed and intensity
- Apply (frontal/diagonal) pressure on the ball: Deny switch - Stop long ball - Prevent forward pass
- Stay disciplined: no foul
PROTECT THE NEAREST SPACE: ANTICIPATE SHORT PASSING
Teammates collectively reduce space and area around the ball
Mark outlet players - block passing lines - cover space
Push up the lines when opposition is forced backwards.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'provide-cover-and-balance-eliminate-options'), 'definition', 'Definition', $$PROTECT THE SPACE IN BEHIND: ANTICIPATE THE LONG BALL
Central defenders anticipate the long ball when inefficient pressure: read pass and drop
Wide defenders attach to the backline.
Adjust body position to anticipate opponent's movement or action$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'drop-off-and-block-direct-path-to-goal'), 'definition', 'Definition', $$Drop-off and protect the center:
- Drop centrally, get narrow and defend in relation to goal
- Create compact block - numbers between ball and goal (to force play wide)
Reduce the central space between the backline.
Identify and mark the most dangerous player.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'slow-down-and-dictate-opponent'), 'definition', 'Definition', $$Slow down the opponent when we are unable to pressure the player on the ball and in a disadvantage (ex. outnumbered) to allow players to return in the defensive block
Dictate direction (force backwards or wide) and speed of play (reduce speed)
Create equal numbers or overload (in area of the ball): eliminate passing options (2v1 à 1-1)$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'get-numbers-back-quickly-and-take-defensive-position'), 'definition', 'Definition', $$Sprint back to get behind the ball to support teammates
Attach to the backline and defend in relation to the goal$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'press-from-behind-as-quickly-as-possible'), 'definition', 'Definition', $$Sprint back and put pressure on the opponent in possession:
- Prevent the opponent from playing forward or dribbling with the ball
- Try to recover the ball (don't give up)
Recover quickly to defend the long ball (create numbers around the ball)$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'stay-connected-look-to-win-the-second-ball'), 'definition', 'Definition', $$Position or mark to prevent the opponent from playing forward after lay-off
Pressure to regain the ball$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'create-passing-options-between-the-lines-atd'), 'definition', 'Definition', $$Anticipate the moment when team wins the ball back:
- Stop defending
- Unmark from defender
- Position (diagonally) between the lines to set up a possible counter-attack$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'create-passing-options-look-to-run-in-behind-atd'), 'definition', 'Definition', $$Anticipate the moment when team wins the ball back
Stop defending and position to create the opportunity to make a run in behind the defensive line$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'defend-the-goal-and-create-conditions-to-engage'), 'definition', 'Definition', $$Be patient and don't commit too early (recognize distance from goal, wait for teammates)
Isolate opponent on the ball when possible: 2v1 à 1-1$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition') AND slug = 'challenge-to-protect-against-a-goal-attempt'), 'definition', 'Definition', $$Challenge with strong determination: block shot to tackle - intercept to prevent assist
- When we are organized and have a numerical advantage
- When opponent is in shooting distance$$, 1);

-- ---------------------------------------------------------------------
-- 4. DEFENDING (slug 'defending') — 5 main principles
-- ---------------------------------------------------------------------
INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order) VALUES
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'create-defending-shape', 'main', 'Create Defending Shape', 'Position to create compact team organization and reduce space', 1),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'build-pressure-on-the-ball', 'main', 'Build Pressure on the Ball', 'Create conditions to win the ball or to prevent forward play', 2),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'recover-when-pressure-is-broken', 'main', 'Recover When Pressure is Broken', 'Re-create conditions to win the ball and regain compactness', 3),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'take-countermeasures-anticipate-to-counter-def', 'main', 'Take Countermeasures: Anticipate to Counter', 'Position to prepare the counterattack', 4),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'deny-the-finish', 'main', 'Deny the Finish', 'Prevent opponent from scoring and creating scoring opportunities', 5);

INSERT INTO club_game_model_principles (phase_id, slug, level, title, sort_order, parent_principle_id) VALUES
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'make-team-compact-vertical-and-horizontal', 'sub', 'Make team compact: vertical and horizontal — (Re-)Position to create a high front line / (Re-)Position to create a high defensive line', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'create-defending-shape')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'create-optimal-defending-distances-between-players', 'sub', 'Create optimal defending distances between players', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'create-defending-shape')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'move-as-a-collective-unit-make-play-predictable', 'sub', 'Move as a collective unit: make play predictable', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'build-pressure-on-the-ball')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'initiate-pressure-on-the-opponent-with-the-ball', 'sub', 'Initiate pressure on the opponent with the ball', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'build-pressure-on-the-ball')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'engage-when-chance-of-regaining-the-ball', 'sub', 'Engage when chance of regaining the ball', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'build-pressure-on-the-ball')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'provide-cover-and-balance-eliminate-passing-options', 'sub', 'Provide cover and balance: eliminate passing options', 4, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'build-pressure-on-the-ball')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'prevent-the-switch-keep-opponent-on-one-side', 'sub', 'Prevent the switch: keep opponent on one side', 5, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'build-pressure-on-the-ball')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'protect-space-in-behind-anticipate-long-ball', 'sub', 'Protect space in behind: anticipate long ball', 6, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'build-pressure-on-the-ball')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'immediately-re-apply-pressure-on-the-ball', 'sub', 'Immediately (re-)apply pressure on the ball', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'recover-when-pressure-is-broken')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'delay-attack-and-regain-defensive-shape', 'sub', 'Delay attack and regain defensive shape', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'recover-when-pressure-is-broken')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'look-to-intercept-pass-or-win-second-ball', 'sub', 'Look to intercept pass or win second ball', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'recover-when-pressure-is-broken')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'create-passing-options-between-the-lines-def', 'sub', 'Create passing option(s): between the lines', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'take-countermeasures-anticipate-to-counter-def')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'create-passing-options-look-to-run-in-behind-def', 'sub', 'Create passing option(s): look to run in behind', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'take-countermeasures-anticipate-to-counter-def')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'get-narrow-and-close-the-center-denying-the-through-ball', 'sub', 'Get narrow and close the center: denying the through ball', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'deny-the-finish')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'marking-and-tracking-opponent', 'sub', 'Marking and tracking opponent', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'deny-the-finish')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'deny-the-cross', 'sub', 'Deny the cross', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'deny-the-finish')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'defending-the-cross-protect-the-width-of-the-goal', 'sub', 'Defending the cross: protect the width of the goal', 4, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'deny-the-finish')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), 'challenge-to-protect-against-goal-attempt', 'sub', 'Challenge to protect against goal attempt', 5, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'deny-the-finish'));

INSERT INTO club_game_model_principle_definitions (principle_id, slug, title, definition, sort_order) VALUES
((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'make-team-compact-vertical-and-horizontal'), 'definition', 'Definition', $$Create a defensive block and reduce passing options for the opponent on the ball - as high as possible
Attacking players (re-)position to create a high line of confrontation
Position to block passing lanes, make play predictable and build pressure
Center backs and/or fullbacks take a high defending position to support compactness
- Reduce space between different lines of the team
- Manage offside: central defender closest to the ball creates the offside line (if in own half)
High position of the goalkeeper to stay connected with the backline$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'create-optimal-defending-distances-between-players'), 'definition', 'Definition', $$Create relationships - connections between players through spacing and distances:
- Reduce options to penetrate with the ball
- Ensure cover
- Allow for interception$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'move-as-a-collective-unit-make-play-predictable'), 'definition', 'Definition', $$Move relative to the position of the ball while maintaining optimal distances between players:
- Reduce time and space for the opponent on the ball
- Shift and slide: no crossover with nearest teammate
- Step: when the ball is played backwards or when pressure on the ball
Direct the player on the ball:
- Reduce the options for the opponent on the ball and force to one area:
  - Block passing lanes
  - Allow passes to pressing area$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'initiate-pressure-on-the-opponent-with-the-ball'), 'definition', 'Definition', $$Nearest player pressures the ball:
- Prevent opponent from playing forward
- Limit time on the ball
- Force opponent to look down
- Force to make mistake$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'engage-when-chance-of-regaining-the-ball'), 'definition', 'Definition', $$Engage in the identified situations:
- Step out and intercept when possible: for example - slow pass, bad touch,...
- 1v1: don't get eliminated by dribble, touch or pass$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'provide-cover-and-balance-eliminate-passing-options'), 'definition', 'Definition', $$Block immediate passing options when teammate puts pressure on the ball
- Cover by the closest player to prevent forward passes / progression: mark, front or track
- Weakside players move centrally
- Bring numbers to the area / outnumber the opponent/bring numbers around the ball$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'prevent-the-switch-keep-opponent-on-one-side'), 'definition', 'Definition', $$Bring numbers around the ball.
Keep opponent locked and stop from getting out of the area.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'protect-space-in-behind-anticipate-long-ball'), 'definition', 'Definition', $$Anticipate the long ball behind the defensive line in case of inefficient pressure:
- Adjust body shape
- Hold the line when pressure on the ball
- Drop when no pressure on the ball$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'immediately-re-apply-pressure-on-the-ball'), 'definition', 'Definition', $$Re-apply pressure on opponent when line is broken:
- From behind: chase the player in possession and attempt to win the ball back without fouling
- In front: step up and press when cover is present
Recover from switch of play:
- Strong shift of the team when opponent was able to switch the play$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'delay-attack-and-regain-defensive-shape'), 'definition', 'Definition', $$Slow down the opponent's attack: drop and narrow. Reduce speed of opponent to allow teammates to recover
Recover with numbers between the ball and the goal
- Outnumber opponent when possible
- Get organized
Track and/or mark the most dangerous players$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'look-to-intercept-pass-or-win-second-ball'), 'definition', 'Definition', $$When the line is broken by the long ball: defending players
- Drop and narrow together
- Compete for the second ball$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'create-passing-options-between-the-lines-def'), 'definition', 'Definition', $$Anticipate the moment when team wins the ball back and set for transition:
- Stop defending
- Unmark from defender
- Scan field and position (diagonally) between the lines to set up a possible counter-attack$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'create-passing-options-look-to-run-in-behind-def'), 'definition', 'Definition', $$Anticipate the moment when team wins the ball back
Stop defending and position to create the opportunity to make a run in behind the defensive line$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'get-narrow-and-close-the-center-denying-the-through-ball'), 'definition', 'Definition', $$Always pressure the player on the ball: reduce time, space and options for the opponent on the ball.
Prevent opponent from passing and making runs to receive behind the defensive line.
Reduce space between teammates: narrow when closer to goal
- Get numbers in the central areas
- Always provide protection for center backs by fronting them
- Drive opponent's offensive play towards wide areas$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'marking-and-tracking-opponent'), 'definition', 'Definition', $$Close marking of direct opponent in zone:
- Split-vision: keep eye on ball and opponent
Change marking:
- Scan your surroundings and communicate
- Stay in your defensive zone when the opponent changes position
- Pass on opponent to teammate or mark opponent coming from another zone
Switch to player-marking: when necessary, switch from zonal marking to player marking$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'deny-the-cross'), 'definition', 'Definition', $$Defend the cross with support from midfielder or winger
- Deny cross into space or player
- Center backs stay in central position$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'defending-the-cross-protect-the-width-of-the-goal'), 'definition', 'Definition', $$Get organized and increase the protection in front of the goal on the cross:
- Weakside fullback is connecting to the backline
- Occupy strategic zones
Close marking of direct opponent:
- Split-vision: keep eye on ball and opponent
Challenge: be first on the ball
- Aggressiveness$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending') AND slug = 'challenge-to-protect-against-goal-attempt'), 'definition', 'Definition', $$Engage and commit when chance of attempt on goal
- Don't get eliminated by dribble.
- Block the shot.
- Win the second ball.
- Clearance$$, 1);

-- ---------------------------------------------------------------------
-- 5. DEFENDING TO ATTACKING TRANSITION (slug 'defending-to-attacking-transition') — 5 main principles
-- ---------------------------------------------------------------------
INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order) VALUES
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'play-forward-quickly', 'main', 'Play Forward Quickly', 'Play forward with as few passes as possible', 1),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'secure-the-ball', 'main', 'Secure the Ball', 'Escape counterpress from closest opponent(s)', 2),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'join-the-attack-with-speed', 'main', 'Join the Attack with Speed', 'Sprint forward to attack or support', 3),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'take-countermeasures-anticipate-the-counter-dta', 'main', 'Take Countermeasures: Anticipate the Counter', 'Position to protect against counterattack', 4),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'finish-the-counterattack-as-fast-as-possible', 'main', 'Finish the Counterattack as Fast as Possible', 'Create scoring opportunity and score', 5);

INSERT INTO club_game_model_principles (phase_id, slug, level, title, sort_order, parent_principle_id) VALUES
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'first-action-forward', 'sub', 'First action forward', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'play-forward-quickly')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'continue-to-play-forward', 'sub', 'Continue to play forward', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'play-forward-quickly')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'play-out-of-pressure', 'sub', 'Play out of pressure', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'secure-the-ball')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'keep-the-ball-initiate-build-up', 'sub', 'Keep the ball: initiate build up', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'secure-the-ball')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'provide-support-in-front-of-the-ball', 'sub', 'Provide support in front of the ball', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'join-the-attack-with-speed')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'provide-as-much-width-as-necessary', 'sub', 'Provide as much width as necessary', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'join-the-attack-with-speed')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'provide-support-behind-the-ball', 'sub', 'Provide support behind the ball', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'join-the-attack-with-speed')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'push-up-the-defensive-line-with-speed-dta', 'sub', 'Push up the defensive line with speed: stay connected and compact', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'take-countermeasures-anticipate-the-counter-dta')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'create-prevention-shape-behind-the-ball', 'sub', 'Create prevention shape behind the ball', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'take-countermeasures-anticipate-the-counter-dta')),

((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'create-and-exploit-space-for-self-or-teammate', 'sub', 'Create and exploit space for self or teammate', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'finish-the-counterattack-as-fast-as-possible')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'attack-space-or-engage-opponent', 'sub', 'Attack space or engage opponent', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'finish-the-counterattack-as-fast-as-possible')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'recognize-player-in-a-better-position-to-score', 'sub', 'Recognize player in a better position to score', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'finish-the-counterattack-as-fast-as-possible')),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), 'finish-use-limited-touches-dta', 'sub', 'Finish: use limited touches', 4, (SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'finish-the-counterattack-as-fast-as-possible'));

INSERT INTO club_game_model_principle_definitions (principle_id, slug, title, definition, sort_order) VALUES
((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'first-action-forward'), 'definition', 'Definition', $$Start attacking transition immediately with forward action:
- Pass forward into open space or feet to (highest) transition player (vertical / diagonal)
- Touch forward and run or dribble aggressively at maximum speed when space
GK distribution: throw/volley into space or feet$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'continue-to-play-forward'), 'definition', 'Definition', $$Continue to progress the ball forward at speed to prevent the opponent from returning into defensive shape: dribble or pass
Play with limited touches to increase the speed of the transition:
- Direct: open body shape to receive the ball facing forward or turn when time on the ball
- Indirect: lay-off / playing backwards to supporting teammate (3rd man running)$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'play-out-of-pressure'), 'definition', 'Definition', $$Stay central if possible
Take advantage of space behind the opponent's backline - pass behind
Shield the ball when pressure from opponent
Move the ball out of the zone when possession is regained to escape counter press
Play sideways or backwards when unable to dribble or pass forward (or draw foul)$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'keep-the-ball-initiate-build-up'), 'definition', 'Definition', $$Keep possession when opponent is balanced and organized
Recognize risk vs reward: priority is to secure possession$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'provide-support-in-front-of-the-ball'), 'definition', 'Definition', $$Move into attacking shape
Sprint forward and commit numbers into the attacking half
Get players in front of the ball as quickly as possible to attack the backline of the opponent
Provide a passing option: make a run in behind$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'provide-as-much-width-as-necessary'), 'definition', 'Definition', $$Occupy all three central-vertical channels
Restrict runs to width of penalty area, when possible, to facilitate quick passing, limit risk of interception, and create direct chance on goal$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'provide-support-behind-the-ball'), 'definition', 'Definition', $$Position to enable the attack to continue by creating passing options behind the ball
Recycle the attack when unable to continue the counter$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'push-up-the-defensive-line-with-speed-dta'), 'definition', 'Definition', $$Provide balance (numbers)
Close space in between lines that the opponent could exploit
Create as high a line as possible$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'create-prevention-shape-behind-the-ball'), 'definition', 'Definition', $$Defensive positioning with a specific amount of players
- Defend the center of the field: block passing lines
- Lock down the opponent's outlet(s): mark transition players
- GK take high position: stay connected with the backline$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'create-and-exploit-space-for-self-or-teammate'), 'definition', 'Definition', $$Separate from opponent and receive between the lines
Exploit space behind opponent backline: make a run to receive in behind
Make a run to free up space for teammate to receive$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'attack-space-or-engage-opponent'), 'definition', 'Definition', $$Dribble at speed into open space:
- Invite pressure to create (more) space for teammate(s)
Dribble at speed to isolate defender:
- Attract to free up teammate (2v1)
- Eliminate defender or create separation and shoot (1v1)
Keep composure (decision at full speed)$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'recognize-player-in-a-better-position-to-score'), 'definition', 'Definition', $$Recognize the right moment to pass to a teammate in a better position to score or assist
- We attack/occupy different areas in the box$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = (SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition') AND slug = 'finish-use-limited-touches-dta'), 'definition', 'Definition', $$Select the best surface and shoot on goal with a minimal touches.$$, 1);

-- ---------------------------------------------------------------------
-- 6. PLAYER ACTIONS — normalized shared catalogs (catalog -> category ->
--    item). "In Possession" is fully defined once (Slides #18-21) and
--    linked to both Attacking and Defending-to-Attacking Transition.
--    "Out of Possession" is fully defined once (Slides #32-33) and
--    linked to both Defending and Attacking-to-Defending Transition.
-- ---------------------------------------------------------------------
INSERT INTO club_game_model_action_catalogs (club_id, slug, title, sort_order) VALUES
(134, 'in-possession', 'In Possession', 1),
(134, 'out-of-possession', 'Out of Possession', 2);

INSERT INTO club_game_model_action_categories (catalog_id, slug, title, sort_order) VALUES
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'in-possession'), 'controlling', 'Controlling', 1),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'in-possession'), 'protecting', 'Protecting', 2),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'in-possession'), 'driving', 'Driving', 3),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'in-possession'), 'dribbling', 'Dribbling', 4),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'in-possession'), 'passing', 'Passing', 5),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'in-possession'), 'shooting', 'Shooting', 6),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'in-possession'), 'scanning', 'Scanning', 7),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'in-possession'), 'supporting-positioning', 'Supporting (Positioning)', 8),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'in-possession'), 'adapting-body-shape', 'Adapting Body Shape', 9),

((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'out-of-possession'), 'intercepting', 'Intercepting', 1),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'out-of-possession'), 'pressing', 'Pressing', 2),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'out-of-possession'), 'challenging', 'Challenging', 3),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'out-of-possession'), 'delaying', 'Delaying', 4),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'out-of-possession'), 'block-the-shot', 'Block the Shot', 5),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'out-of-possession'), 'scanning', 'Scanning', 6),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'out-of-possession'), 'adapting-body-shape', 'Adapting Body Shape', 7),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'out-of-possession'), 'covering', 'Covering', 8),
((SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'out-of-possession'), 'marking', 'Marking', 9);

-- Helper: category lookups below are scoped by catalog slug + category
-- slug since category slugs (e.g. "scanning") repeat across catalogs.
INSERT INTO club_game_model_action_items (category_id, description, sort_order) VALUES
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'controlling'), 'Receiving and preparing the ball from short passes (distance of 5 to 20 yards)', 1),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'controlling'), 'Receiving and preparing the ball in such a way that you can immediately go to goal', 2),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'controlling'), 'Receiving and preparing the ball in such a way that it stays as close to you as possible', 3),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'controlling'), 'Receiving by moving towards the ball when opponent is close by (attacking the ball)', 4),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'controlling'), 'Receiving and preparing the ball from a long pass in the air', 5),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'controlling'), 'Receiving and preparing the ball on the bounce', 6),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'controlling'), $$Receiving and preparing the ball on the turn towards the opponent's goal as quickly as possible$$, 7),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'controlling'), 'Receiving and playing in 1 touch if you can pass accurately', 8),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'controlling'), 'Avoiding looking at the ball when receiving and preparing the ball', 9),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'controlling'), 'Scanning for a free teammate after performing the control', 10),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'controlling'), 'Scanning for a free teammate before or while receiving and preparing the ball', 11),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'controlling'), 'Avoiding a long ball from bouncing - receiving before the bounce', 12),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'controlling'), 'Receiving and playing a long ball in 1 touch if you can pass accurately', 13),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'protecting'), 'Shielding and maintaining possession of the ball, by placing most of the body between the ball and opponent, keeping the ball on the furthest foot away from the defender while looking for teammates', 1),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'protecting'), 'Turning away from and out of reach of your opponent', 2),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'driving'), 'Running with the ball, keeping the ball as close as possible to the body', 1),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'driving'), 'Avoiding looking at the ball while driving the ball', 2),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'driving'), 'Keeping your body between the ball and the approaching opponent while driving the ball', 3),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'driving'), 'Running as fast as possible with the ball, picking up speed to gain as much time and territory as possible', 4),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'driving'), 'Creating space in advance (before controlling) in which you want to drive the ball', 5),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'dribbling'), 'Taking on the opponent', 1),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'dribbling'), 'Reading the body shape of the opponent and engaging on the most obvious/weak side', 2),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'dribbling'), 'Accelerating when eliminating the opponent', 3),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'dribbling'), 'Avoiding looking at the ball while dribbling', 4),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'dribbling'), 'Keeping your body between the ball and the opponent while dribbling', 5),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'dribbling'), 'Holding off the opponent and creating distance from the opponent', 6),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'dribbling'), 'Dribbling through a change of direction at the right time, or through a change of speed or through a feint', 7),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'dribbling'), 'Dribbling when you can cause direct danger on target', 8),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'passing'), 'Playing the ball intentionally with different surfaces to a free teammate, into feet or space, within a distance of 5 to 20 yards', 1),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'passing'), 'Playing the ball to the foot so that the player receiving the ball can continue to play forward', 2),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'passing'), 'Making a leading pass in front of your teammate, making sure that the teammate can take the ball without having to slow down', 3),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'passing'), 'Looking at the player you are passing to when passing', 4),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'passing'), 'Trying to take out an opponent with a quick wall pass (give and go) in a small space', 5),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'passing'), 'Making a long pass in the air', 6),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'passing'), 'Playing a long ball in space so a teammate can receive the ball while running', 7),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'passing'), 'Avoiding passing to a player surrounded by opponents who can be immediately put under pressure', 8),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'passing'), 'Playing the cross at the right time and with the right ball speed outside the action area of the goalkeeper and the defender', 9),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'passing'), 'Disguising the pass', 10),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'shooting'), 'Striking the ball intentionally with different surfaces from short and medium range (1-10 yards; 11-20 yards) on the goal (finishing)', 1),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'shooting'), 'Looking at the position of the goalkeeper before shooting at goal, and selecting a target', 2),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'shooting'), 'Aiming for the far side if you shoot from an angle and the goalkeeper is protecting near post', 3),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'shooting'), 'Finishing in 1 time/touch when closely marked', 4),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'shooting'), 'Finishing on the volley / bounce', 5),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'shooting'), 'Following the ball after the shot', 6),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'shooting'), 'Dribbling at the goalkeeper when he/she comes out at full speed or when he or she protects the goal well and scoring from the shot becomes difficult', 7),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'shooting'), 'Chipping the goalkeeper', 8),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'shooting'), 'Disguising the finish', 9),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'scanning'), $$Searching for the ball, teammates and the goal:
- scanning for a free teammate after performing the control
- scanning for a free teammate before or while receiving and preparing the ball (passing)
- scanning and avoiding looking at the ball while dribbling
- scanning and looking at the position of the goalkeeper before shooting at goal, and selecting a target (shooting)$$, 1),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'supporting-positioning'), 'Looking at the player in possession of the ball', 1),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'supporting-positioning'), 'Finding open space for self and indicating this, verbally or non-verbally, to the player in possession of the ball', 2),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'supporting-positioning'), 'Repositioning after giving a pass (ex. give and go)', 3),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'supporting-positioning'), $$Assessing teammates' movements and moving off each other$$, 4),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'supporting-positioning'), 'Unmarking and running behind opponent when a teammate on the ball is looking for options', 5),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'supporting-positioning'), $$Looking to get out of sight from the defender's vision$$, 6),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'supporting-positioning'), 'Losing direct opponent by switching positions with a teammate', 7),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'supporting-positioning'), 'Anticipating as the third player who will get the ball after a pass between two teammates', 8),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'adapting-body-shape'), 'Adjusting shoulders and hips to be 45 - 90 degrees towards the attacking goal.', 1),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'in-possession' AND cc.slug = 'adapting-body-shape'), 'While approaching, have an optimal overview of the game situation.', 2),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'intercepting'), 'Intercept when a chance of winning or deflecting the ball, if not stay in position', 1),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'intercepting'), $$Deflecting an opponent's pass away from the intended target$$, 2),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'intercepting'), 'Staying in possession of the ball after stealing it and continuing with an attacking action', 3),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'intercepting'), 'Playing in one touch to a teammate', 4),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'intercepting'), 'Intercept the ball as high as possible (high point) on a long (high) ball', 5),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'pressing'), 'Running to the opponent who is about to receive the ball (approx. 2 yards distance) while the ball is moving (to reduce the space for the opponent or force error)', 1),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'pressing'), 'Having fast approach but slow arrival', 2),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'pressing'), 'Approach is forcing into desired area', 3),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'challenging'), 'Taking good defensive posture (on toes, knees are bent, staggered stance, …) that allows to start the 1v1 in favorable conditions', 1),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'challenging'), 'Always looking at the ball', 2),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'challenging'), 'Staying on your feet', 3),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'challenging'), 'Retaining possession of the ball after winning the duel', 4),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'challenging'), $$If you are eliminated, don't give up, challenge again immediately$$, 5),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'delaying'), $$Slowing down, reducing speed from the opponent's action$$, 1),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'delaying'), 'Driving the player on the ball to the outside (away from goal)', 2),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'block-the-shot'), 'Getting in between the ball and the defending goal to redirect the ball away from goal', 1),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'scanning'), 'Searching for the ball, nearest teammates and nearest opponents in relationship to the goal we are protecting', 1),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'adapting-body-shape'), 'Adjusting shoulders and hips to be 45 - 90 degrees towards the defending goal', 1),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'covering'), 'Positioning at the appropriate distance from the challenging teammate, allowing to quickly put pressure again if needed', 1),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'covering'), 'Preventing the opponent behind your back (between the lines) from being an option', 2),

((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'marking'), 'Preventing direct opponent from receiving the ball in favorable circumstances by positioning next to the opponent (proactive stance)', 1),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'marking'), 'Trying to look at both the ball and direct opponent', 2),
((SELECT cc.id FROM club_game_model_action_categories cc JOIN club_game_model_action_catalogs c ON c.id = cc.catalog_id WHERE c.club_id = 134 AND c.slug = 'out-of-possession' AND cc.slug = 'marking'), 'Marking closer when closer to goal', 3);

-- Link each catalog to the two phases that reference it in the source.
INSERT INTO club_game_model_phase_action_catalogs (phase_id, catalog_id, sort_order) VALUES
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking'), (SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'in-possession'), 1),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending-to-attacking-transition'), (SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'in-possession'), 1),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'defending'), (SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'out-of-possession'), 1),
((SELECT id FROM club_game_model_phases WHERE club_id = 134 AND slug = 'attacking-to-defending-transition'), (SELECT id FROM club_game_model_action_catalogs WHERE club_id = 134 AND slug = 'out-of-possession'), 1);

COMMIT;
