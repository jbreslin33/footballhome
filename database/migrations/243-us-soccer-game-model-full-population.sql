-- 243-us-soccer-game-model-full-population.sql (2026-07-21)
-- Full normalized population of the U.S. Soccer U17+ Game Model, verbatim
-- from the source document, for Lighthouse 1893 SC (club_id 134) — the
-- only club actually using this feature. See
-- docs/game-model/us-soccer-full-extraction.md for the complete extraction
-- this migration is transcribed from (all 42 slides read/verified).
--
-- Schema note: the source models Player Actions as exactly TWO shared
-- catalogs of categories (each category has many bullet-point skill
-- definitions), not a flat phase-owned list:
--   - "in_possession" catalog: fully defined under Attacking, reused
--     (by category name only) under Defending-to-Attacking Transition.
--   - "out_of_possession" catalog: fully defined under Defending, reused
--     under Attacking-to-Defending Transition.
-- Since only one club needs this, we duplicate the catalog rows per phase
-- (simplest fit for the existing phase_id-owned table) rather than build
-- new catalog/junction tables.

BEGIN;

ALTER TABLE club_game_model_player_actions ADD COLUMN IF NOT EXISTS category text;
ALTER TABLE club_game_model_player_actions ADD COLUMN IF NOT EXISTS category_group text;
CREATE INDEX IF NOT EXISTS idx_club_game_model_player_actions_category
    ON club_game_model_player_actions (phase_id, category, sort_order, id);

-- ---------------------------------------------------------------------
-- 1. Correct club 134's phase descriptions to the verbatim Game Idea text
--    (previously a shortened paraphrase shared as generic template text).
-- ---------------------------------------------------------------------
UPDATE club_game_model_phases SET description = $$When in possession, we want to dominate by advancing the ball quickly in the attacking half with high energy and high tempo. Create balance with a minimum of 5 players ahead of the ball and use our positioning to create an advantage over the opponent, create goal scoring chances, and score.$$
WHERE id = 349;

UPDATE club_game_model_phases SET description = $$When out of possession, we want to dominate by making play predictable and creating conditions to win the ball back as early and as high up the field as possible. Make the field small, reduce the opponent's time, space, and options.$$
WHERE id = 350;

UPDATE club_game_model_phases SET description = $$When we regain possession, we immediately think and play forward, look to attack aggressively with maximum speed and finish as fast as possible. When we recognize the opponent is balanced and organized, we keep the ball and move into our attacking shape.$$
WHERE id = 351;

UPDATE club_game_model_phases SET description = $$When we lose possession, we want to regain the ball early and as high up the field as possible, by reacting immediately with maximum intensity and aggression. When we recognize we are unable to pressure the ball, we recover quickly into a compact shape.$$
WHERE id = 352;

-- ---------------------------------------------------------------------
-- 2. ATTACKING (phase_id 349) — 5 main principles
-- ---------------------------------------------------------------------
INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order) VALUES
(349, 'create-attacking-shape', 'main', 'Create Attacking Shape', 'Position to stretch opponent and create space', 1),
(349, 'provide-options-to-play-forward', 'main', 'Provide Options to Play Forward', '(Re-)position to create advantage and receive the ball', 2),
(349, 'break-lines-to-advance-attack', 'main', 'Break Lines to Advance Attack', 'Progress the ball forward and eliminate opponent(s)', 3),
(349, 'take-countermeasures-anticipate-opponent-counter', 'main', 'Take Countermeasures: Anticipate Opponent Counter', 'Position to protect against counterattack', 4),
(349, 'finish-the-attack', 'main', 'Finish the Attack', 'Create scoring opportunity and score', 5);

INSERT INTO club_game_model_principles (phase_id, slug, level, title, sort_order, parent_principle_id) VALUES
(349, 'create-appropriate-height-width-depth', 'sub', 'Create appropriate height, width, depth', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'create-attacking-shape')),
(349, 'create-optimal-attacking-distances-between-players', 'sub', 'Create optimal attacking distances between players', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'create-attacking-shape')),

(349, 'provide-vertical-or-diagonal-passing-options', 'sub', 'Provide vertical or diagonal passing options', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'provide-options-to-play-forward')),
(349, 'create-overload-centrally-or-wide', 'sub', 'Create overload centrally or wide', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'provide-options-to-play-forward')),
(349, 'move-or-lose-opponent-when-marked', 'sub', 'Move or lose opponent when marked', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'provide-options-to-play-forward')),
(349, 'make-runs-behind-the-defensive-line', 'sub', 'Make runs behind the defensive line', 4, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'provide-options-to-play-forward')),
(349, 'give-immediate-support-to-teammate-under-pressure', 'sub', 'Give immediate support to teammate under pressure', 5, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'provide-options-to-play-forward')),

(349, 'drive-with-the-ball-to-exploit-space', 'sub', 'Drive with the ball to exploit space', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'break-lines-to-advance-attack')),
(349, 'engage-opponent-create-1v1-or-2v1', 'sub', 'Engage opponent: create 1v1 or 2v1', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'break-lines-to-advance-attack')),
(349, 'find-a-free-player-between-or-behind-the-lines', 'sub', 'Find a free player between or behind the lines', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'break-lines-to-advance-attack')),
(349, 'switch-play-pass-the-ball-to-opponents-weak-zone', 'sub', 'Switch play: pass the ball to opponent''s weak zone', 4, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'break-lines-to-advance-attack')),

(349, 'push-up-the-defensive-line-with-speed-attack', 'sub', 'Push up the defensive line with speed: stay connected and compact', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'take-countermeasures-anticipate-opponent-counter')),
(349, 'create-high-defensive-shape-behind-the-ball', 'sub', 'Create high defensive shape behind the ball', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'take-countermeasures-anticipate-opponent-counter')),

(349, 'separate-time-run-or-quick-movement-to-unmark', 'sub', 'Separate: time run or quick movement to unmark', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'finish-the-attack')),
(349, 'final-pass-through-ball-or-combination-play', 'sub', 'Final pass: through ball or combination play', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'finish-the-attack')),
(349, 'numbers-in-the-box-fill-zones-in-front-of-goal', 'sub', 'Numbers in the box: fill zones in front of goal', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'finish-the-attack')),
(349, 'cross-into-space-or-player', 'sub', 'Cross: into space or player', 4, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'finish-the-attack')),
(349, 'take-on-1v1-to-create-or-score', 'sub', 'Take on 1v1 to create or score', 5, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'finish-the-attack')),
(349, 'finish-use-limited-touches-attack', 'sub', 'Finish: use limited touches', 6, (SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'finish-the-attack'));

INSERT INTO club_game_model_principle_definitions (principle_id, slug, title, definition, sort_order) VALUES
((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'create-appropriate-height-width-depth'), 'definition', 'Definition', $$Attacking players position as high as possible:
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

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'create-optimal-attacking-distances-between-players'), 'definition', 'Definition', $$Spread out with optimal passing distance between players.
Create relationships - connections between players.
Exploit space in opponent's defending team shape.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'provide-vertical-or-diagonal-passing-options'), 'definition', 'Definition', $$Exploit the space in and around the opponent's defensive block and create a positional advantage:
- Avoid two players in a direct line.
- Move and provide a good supporting angle: receive facing forward to play forward when possible.
- Stay away from the ball when player on the ball has time and space to play forward.
Triangulate: we position to provide the player on the ball with at least two forward (diagonal/vertical) passing options on different levels of height and width.
Rotate: interchange position to create a dynamic advantage.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'create-overload-centrally-or-wide'), 'definition', 'Definition', $$Create a numerical advantage in a specific area of the field:
- Position to outnumber opponent in the area around the ball or area away from the ball
- Allow more players to attack - penetrations of midfielders or defenders
- Drop midfielders or attackers
If marked move to open space or move to open the space:$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'move-or-lose-opponent-when-marked'), 'definition', 'Definition', $$Lose opponent to receive the ball
- Distance from defender in space (get unmarked)/ move between the lines
Move opponent to receive the ball
- Draw opponent out of defending position to create space for self to receive (requires explosive change of direction)
Move to create space and passing options for teammate to receive
- Draw opponent out of defending position to create space for teammate to exploit and receive ball$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'make-runs-behind-the-defensive-line'), 'definition', 'Definition', $$Make run when player on the ball is facing forward and has no pressure or has pressure but can play forward
Use different runs and time run to avoid offside (straight run, curved run, ...)
Receive the ball facing forward$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'give-immediate-support-to-teammate-under-pressure'), 'definition', 'Definition', $$Recognize the player on the ball is under pressure and has no immediate options:
- Above the ball: move towards the ball to create a passing option
- Behind the ball: adjust position to create passing option$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'drive-with-the-ball-to-exploit-space'), 'definition', 'Definition', $$Recognize and exploit space.
Accelerate play through dribble: individually progress the ball into space with change of tempo.
Attract opponent (draw attention).$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'engage-opponent-create-1v1-or-2v1'), 'definition', 'Definition', $$Dribble and look for 1v1 or 2v1:
- Engage to isolate opponent:
- Eliminate through dribble: take opponent on in 1v1
- Eliminate through pass or give and go
Move or hold the ball to attract opponent:
- Move the opponent, invite pressure to create space for teammate.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'find-a-free-player-between-or-behind-the-lines'), 'definition', 'Definition', $$Pass quickly, accurately and with appropriate pace to a free player.
Skip a line: recognize opportunity & take risk: look furthest first, look nearest second.
Pass dictates the action: pass with intent.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'switch-play-pass-the-ball-to-opponents-weak-zone'), 'definition', 'Definition', $$Draw opponent to one side and find space on the opposite side:
- Direct change of point: long pass
- Indirect change of point: short pass$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'push-up-the-defensive-line-with-speed-attack'), 'definition', 'Definition', $$Provide balance (numbers).
We all move with the same speed and lose space in between lines that the opponent could exploit.
Create as high a line as possible.
GK take high position: stay connected with the backline.
- GK anticipate long pass from opponent and adjust quickly.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'create-high-defensive-shape-behind-the-ball'), 'definition', 'Definition', $$Defensive positioning by the players who are no longer directly involved in moving the ball forward.
Anticipate losing the ball and occupy positions to defend the opponent's counterattack.
- Defend the center of the field: block passing lanes
- Lock down the opponent's outlet(s): mark transition players$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'separate-time-run-or-quick-movement-to-unmark'), 'definition', 'Definition', $$Move into a position in and around the box to score or assist:
- Forward run behind the opponent's back line from a high position (attacking position)
- Forward run behind the opponent's back line from a deeper position (midfield position)
- Move out of sight to receive
Counter movement: opposite movement between two players
Quick movement from opponent to create space
Disguised pass to manipulate opponent$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'final-pass-through-ball-or-combination-play'), 'definition', 'Definition', $$Pass quickly, accurately and with appropriate pace:
- Through ball or chip ball to player who runs in behind
- Pass to unmarked player in or around the box
Quick combination play between 2 or more players to find a teammate in a goalscoring position
Recognize the player in the better position.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'numbers-in-the-box-fill-zones-in-front-of-goal'), 'definition', 'Definition', $$Efficient occupation of zones in the box on cross: near post, back post, penalty spot, edge of box
- Time your run in the box
- Get unmarked or in front of opponent
- Attack the ball$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'cross-into-space-or-player'), 'definition', 'Definition', $$Time the cross in front or behind the backline
- Recognize space (positioning of goalkeeper and defenders)
- Recognize the positions and runs of teammates in penalty box$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'take-on-1v1-to-create-or-score'), 'definition', 'Definition', $$Eliminate opponent through dribble to create goalscoring opportunity
Shoot from (short/long) distance$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 349 AND slug = 'finish-use-limited-touches-attack'), 'definition', 'Definition', $$Finish off the cross: choose your final touch
React quickly on rebounds$$, 1);

-- ---------------------------------------------------------------------
-- 3. ATTACKING TO DEFENDING TRANSITION (phase_id 352) — 5 main principles
-- ---------------------------------------------------------------------
INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order) VALUES
(352, 'apply-immediate-pressure-on-the-ball', 'main', 'Apply Immediate Pressure on the Ball', 'React quickly to win the ball back and stop opponents'' forward play', 1),
(352, 'delay-the-counterattack-atd', 'main', 'Delay the Counterattack', 'Drop and narrow, reduce speed of opponents to allow players to recover', 2),
(352, 'recover-with-speed-atd', 'main', 'Recover with Speed', 'Sprint back to get balanced, organized and apply pressure', 3),
(352, 'take-countermeasures-anticipate-the-counter-atd', 'main', 'Take Countermeasures: Anticipate the Counter', 'Position to prepare the counterattack', 4),
(352, 'deny-finish-from-counterattack', 'main', 'Deny Finish from Counterattack', 'Deny scoring opportunity and prevent scoring', 5);

INSERT INTO club_game_model_principles (phase_id, slug, level, title, sort_order, parent_principle_id) VALUES
(352, 'press-to-regain-or-prevent-progress-of-the-ball', 'sub', 'Press to regain or prevent progress of the ball', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'apply-immediate-pressure-on-the-ball')),
(352, 'provide-cover-and-balance-eliminate-options', 'sub', 'Provide cover and balance: eliminate options', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'apply-immediate-pressure-on-the-ball')),
(352, 'drop-off-and-block-direct-path-to-goal', 'sub', 'Drop off and block direct path to goal', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'apply-immediate-pressure-on-the-ball')),

(352, 'slow-down-and-dictate-opponent', 'sub', 'Slow down and dictate opponent', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'delay-the-counterattack-atd')),

(352, 'get-numbers-back-quickly-and-take-defensive-position', 'sub', 'Get numbers back quickly and take defensive position', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'recover-with-speed-atd')),
(352, 'press-from-behind-as-quickly-as-possible', 'sub', 'Press from behind as quickly as possible', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'recover-with-speed-atd')),
(352, 'stay-connected-look-to-win-the-second-ball', 'sub', 'Stay connected: look to win the second ball', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'recover-with-speed-atd')),

(352, 'create-passing-options-between-the-lines-atd', 'sub', 'Create passing option(s): between the lines', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'take-countermeasures-anticipate-the-counter-atd')),
(352, 'create-passing-options-look-to-run-in-behind-atd', 'sub', 'Create passing option(s): look to run in behind', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'take-countermeasures-anticipate-the-counter-atd')),

(352, 'defend-the-goal-and-create-conditions-to-engage', 'sub', 'Defend the goal and create conditions to engage', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'deny-finish-from-counterattack')),
(352, 'challenge-to-protect-against-a-goal-attempt', 'sub', 'Challenge to protect against a goal attempt', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'deny-finish-from-counterattack'));

INSERT INTO club_game_model_principle_definitions (principle_id, slug, title, definition, sort_order) VALUES
((SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'press-to-regain-or-prevent-progress-of-the-ball'), 'definition', 'Definition', $$Recognize situations when to press or hold and force wide (awareness).
Win the ball when opportunity to regain (distance, numbers and levels of compactness).
Nearest player(s):
- React immediately, reduce space with speed and intensity
- Apply (frontal/diagonal) pressure on the ball: Deny switch - Stop long ball - Prevent forward pass
- Stay disciplined: no foul
PROTECT THE NEAREST SPACE: ANTICIPATE SHORT PASSING
Teammates collectively reduce space and area around the ball
Mark outlet players - block passing lines - cover space
Push up the lines when opposition is forced backwards.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'provide-cover-and-balance-eliminate-options'), 'definition', 'Definition', $$PROTECT THE SPACE IN BEHIND: ANTICIPATE THE LONG BALL
Central defenders anticipate the long ball when inefficient pressure: read pass and drop
Wide defenders attach to the backline.
Adjust body position to anticipate opponent's movement or action$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'drop-off-and-block-direct-path-to-goal'), 'definition', 'Definition', $$Drop-off and protect the center:
- Drop centrally, get narrow and defend in relation to goal
- Create compact block - numbers between ball and goal (to force play wide)
Reduce the central space between the backline.
Identify and mark the most dangerous player.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'slow-down-and-dictate-opponent'), 'definition', 'Definition', $$Slow down the opponent when we are unable to pressure the player on the ball and in a disadvantage (ex. outnumbered) to allow players to return in the defensive block
Dictate direction (force backwards or wide) and speed of play (reduce speed)
Create equal numbers or overload (in area of the ball): eliminate passing options (2v1 à 1-1)$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'get-numbers-back-quickly-and-take-defensive-position'), 'definition', 'Definition', $$Sprint back to get behind the ball to support teammates
Attach to the backline and defend in relation to the goal$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'press-from-behind-as-quickly-as-possible'), 'definition', 'Definition', $$Sprint back and put pressure on the opponent in possession:
- Prevent the opponent from playing forward or dribbling with the ball
- Try to recover the ball (don't give up)
Recover quickly to defend the long ball (create numbers around the ball)$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'stay-connected-look-to-win-the-second-ball'), 'definition', 'Definition', $$Position or mark to prevent the opponent from playing forward after lay-off
Pressure to regain the ball$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'create-passing-options-between-the-lines-atd'), 'definition', 'Definition', $$Anticipate the moment when team wins the ball back:
- Stop defending
- Unmark from defender
- Position (diagonally) between the lines to set up a possible counter-attack$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'create-passing-options-look-to-run-in-behind-atd'), 'definition', 'Definition', $$Anticipate the moment when team wins the ball back
Stop defending and position to create the opportunity to make a run in behind the defensive line$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'defend-the-goal-and-create-conditions-to-engage'), 'definition', 'Definition', $$Be patient and don't commit too early (recognize distance from goal, wait for teammates)
Isolate opponent on the ball when possible: 2v1 à 1-1$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 352 AND slug = 'challenge-to-protect-against-a-goal-attempt'), 'definition', 'Definition', $$Challenge with strong determination: block shot to tackle - intercept to prevent assist
- When we are organized and have a numerical advantage
- When opponent is in shooting distance$$, 1);

-- ---------------------------------------------------------------------
-- 4. DEFENDING (phase_id 350) — 5 main principles
-- ---------------------------------------------------------------------
INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order) VALUES
(350, 'create-defending-shape', 'main', 'Create Defending Shape', 'Position to create compact team organization and reduce space', 1),
(350, 'build-pressure-on-the-ball', 'main', 'Build Pressure on the Ball', 'Create conditions to win the ball or to prevent forward play', 2),
(350, 'recover-when-pressure-is-broken', 'main', 'Recover When Pressure is Broken', 'Re-create conditions to win the ball and regain compactness', 3),
(350, 'take-countermeasures-anticipate-to-counter-def', 'main', 'Take Countermeasures: Anticipate to Counter', 'Position to prepare the counterattack', 4),
(350, 'deny-the-finish', 'main', 'Deny the Finish', 'Prevent opponent from scoring and creating scoring opportunities', 5);

INSERT INTO club_game_model_principles (phase_id, slug, level, title, sort_order, parent_principle_id) VALUES
(350, 'make-team-compact-vertical-and-horizontal', 'sub', 'Make team compact: vertical and horizontal — (Re-)Position to create a high front line / (Re-)Position to create a high defensive line', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'create-defending-shape')),
(350, 'create-optimal-defending-distances-between-players', 'sub', 'Create optimal defending distances between players', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'create-defending-shape')),

(350, 'move-as-a-collective-unit-make-play-predictable', 'sub', 'Move as a collective unit: make play predictable', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'build-pressure-on-the-ball')),
(350, 'initiate-pressure-on-the-opponent-with-the-ball', 'sub', 'Initiate pressure on the opponent with the ball', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'build-pressure-on-the-ball')),
(350, 'engage-when-chance-of-regaining-the-ball', 'sub', 'Engage when chance of regaining the ball', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'build-pressure-on-the-ball')),
(350, 'provide-cover-and-balance-eliminate-passing-options', 'sub', 'Provide cover and balance: eliminate passing options', 4, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'build-pressure-on-the-ball')),
(350, 'prevent-the-switch-keep-opponent-on-one-side', 'sub', 'Prevent the switch: keep opponent on one side', 5, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'build-pressure-on-the-ball')),
(350, 'protect-space-in-behind-anticipate-long-ball', 'sub', 'Protect space in behind: anticipate long ball', 6, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'build-pressure-on-the-ball')),

(350, 'immediately-re-apply-pressure-on-the-ball', 'sub', 'Immediately (re-)apply pressure on the ball', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'recover-when-pressure-is-broken')),
(350, 'delay-attack-and-regain-defensive-shape', 'sub', 'Delay attack and regain defensive shape', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'recover-when-pressure-is-broken')),
(350, 'look-to-intercept-pass-or-win-second-ball', 'sub', 'Look to intercept pass or win second ball', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'recover-when-pressure-is-broken')),

(350, 'create-passing-options-between-the-lines-def', 'sub', 'Create passing option(s): between the lines', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'take-countermeasures-anticipate-to-counter-def')),
(350, 'create-passing-options-look-to-run-in-behind-def', 'sub', 'Create passing option(s): look to run in behind', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'take-countermeasures-anticipate-to-counter-def')),

(350, 'get-narrow-and-close-the-center-denying-the-through-ball', 'sub', 'Get narrow and close the center: denying the through ball', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'deny-the-finish')),
(350, 'marking-and-tracking-opponent', 'sub', 'Marking and tracking opponent', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'deny-the-finish')),
(350, 'deny-the-cross', 'sub', 'Deny the cross', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'deny-the-finish')),
(350, 'defending-the-cross-protect-the-width-of-the-goal', 'sub', 'Defending the cross: protect the width of the goal', 4, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'deny-the-finish')),
(350, 'challenge-to-protect-against-goal-attempt', 'sub', 'Challenge to protect against goal attempt', 5, (SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'deny-the-finish'));

INSERT INTO club_game_model_principle_definitions (principle_id, slug, title, definition, sort_order) VALUES
((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'make-team-compact-vertical-and-horizontal'), 'definition', 'Definition', $$Create a defensive block and reduce passing options for the opponent on the ball - as high as possible
Attacking players (re-)position to create a high line of confrontation
Position to block passing lanes, make play predictable and build pressure
Center backs and/or fullbacks take a high defending position to support compactness
- Reduce space between different lines of the team
- Manage offside: central defender closest to the ball creates the offside line (if in own half)
High position of the goalkeeper to stay connected with the backline$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'create-optimal-defending-distances-between-players'), 'definition', 'Definition', $$Create relationships - connections between players through spacing and distances:
- Reduce options to penetrate with the ball
- Ensure cover
- Allow for interception$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'move-as-a-collective-unit-make-play-predictable'), 'definition', 'Definition', $$Move relative to the position of the ball while maintaining optimal distances between players:
- Reduce time and space for the opponent on the ball
- Shift and slide: no crossover with nearest teammate
- Step: when the ball is played backwards or when pressure on the ball
Direct the player on the ball:
- Reduce the options for the opponent on the ball and force to one area:
  - Block passing lanes
  - Allow passes to pressing area$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'initiate-pressure-on-the-opponent-with-the-ball'), 'definition', 'Definition', $$Nearest player pressures the ball:
- Prevent opponent from playing forward
- Limit time on the ball
- Force opponent to look down
- Force to make mistake$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'engage-when-chance-of-regaining-the-ball'), 'definition', 'Definition', $$Engage in the identified situations:
- Step out and intercept when possible: for example - slow pass, bad touch,...
- 1v1: don't get eliminated by dribble, touch or pass$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'provide-cover-and-balance-eliminate-passing-options'), 'definition', 'Definition', $$Block immediate passing options when teammate puts pressure on the ball
- Cover by the closest player to prevent forward passes / progression: mark, front or track
- Weakside players move centrally
- Bring numbers to the area / outnumber the opponent/bring numbers around the ball$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'prevent-the-switch-keep-opponent-on-one-side'), 'definition', 'Definition', $$Bring numbers around the ball.
Keep opponent locked and stop from getting out of the area.$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'protect-space-in-behind-anticipate-long-ball'), 'definition', 'Definition', $$Anticipate the long ball behind the defensive line in case of inefficient pressure:
- Adjust body shape
- Hold the line when pressure on the ball
- Drop when no pressure on the ball$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'immediately-re-apply-pressure-on-the-ball'), 'definition', 'Definition', $$Re-apply pressure on opponent when line is broken:
- From behind: chase the player in possession and attempt to win the ball back without fouling
- In front: step up and press when cover is present
Recover from switch of play:
- Strong shift of the team when opponent was able to switch the play$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'delay-attack-and-regain-defensive-shape'), 'definition', 'Definition', $$Slow down the opponent's attack: drop and narrow. Reduce speed of opponent to allow teammates to recover
Recover with numbers between the ball and the goal
- Outnumber opponent when possible
- Get organized
Track and/or mark the most dangerous players$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'look-to-intercept-pass-or-win-second-ball'), 'definition', 'Definition', $$When the line is broken by the long ball: defending players
- Drop and narrow together
- Compete for the second ball$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'create-passing-options-between-the-lines-def'), 'definition', 'Definition', $$Anticipate the moment when team wins the ball back and set for transition:
- Stop defending
- Unmark from defender
- Scan field and position (diagonally) between the lines to set up a possible counter-attack$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'create-passing-options-look-to-run-in-behind-def'), 'definition', 'Definition', $$Anticipate the moment when team wins the ball back
Stop defending and position to create the opportunity to make a run in behind the defensive line$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'get-narrow-and-close-the-center-denying-the-through-ball'), 'definition', 'Definition', $$Always pressure the player on the ball: reduce time, space and options for the opponent on the ball.
Prevent opponent from passing and making runs to receive behind the defensive line.
Reduce space between teammates: narrow when closer to goal
- Get numbers in the central areas
- Always provide protection for center backs by fronting them
- Drive opponent's offensive play towards wide areas$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'marking-and-tracking-opponent'), 'definition', 'Definition', $$Close marking of direct opponent in zone:
- Split-vision: keep eye on ball and opponent
Change marking:
- Scan your surroundings and communicate
- Stay in your defensive zone when the opponent changes position
- Pass on opponent to teammate or mark opponent coming from another zone
Switch to player-marking: when necessary, switch from zonal marking to player marking$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'deny-the-cross'), 'definition', 'Definition', $$Defend the cross with support from midfielder or winger
- Deny cross into space or player
- Center backs stay in central position$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'defending-the-cross-protect-the-width-of-the-goal'), 'definition', 'Definition', $$Get organized and increase the protection in front of the goal on the cross:
- Weakside fullback is connecting to the backline
- Occupy strategic zones
Close marking of direct opponent:
- Split-vision: keep eye on ball and opponent
Challenge: be first on the ball
- Aggressiveness$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 350 AND slug = 'challenge-to-protect-against-goal-attempt'), 'definition', 'Definition', $$Engage and commit when chance of attempt on goal
- Don't get eliminated by dribble.
- Block the shot.
- Win the second ball.
- Clearance$$, 1);

-- ---------------------------------------------------------------------
-- 5. DEFENDING TO ATTACKING TRANSITION (phase_id 351) — 5 main principles
-- ---------------------------------------------------------------------
INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order) VALUES
(351, 'play-forward-quickly', 'main', 'Play Forward Quickly', 'Play forward with as few passes as possible', 1),
(351, 'secure-the-ball', 'main', 'Secure the Ball', 'Escape counterpress from closest opponent(s)', 2),
(351, 'join-the-attack-with-speed', 'main', 'Join the Attack with Speed', 'Sprint forward to attack or support', 3),
(351, 'take-countermeasures-anticipate-the-counter-dta', 'main', 'Take Countermeasures: Anticipate the Counter', 'Position to protect against counterattack', 4),
(351, 'finish-the-counterattack-as-fast-as-possible', 'main', 'Finish the Counterattack as Fast as Possible', 'Create scoring opportunity and score', 5);

INSERT INTO club_game_model_principles (phase_id, slug, level, title, sort_order, parent_principle_id) VALUES
(351, 'first-action-forward', 'sub', 'First action forward', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'play-forward-quickly')),
(351, 'continue-to-play-forward', 'sub', 'Continue to play forward', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'play-forward-quickly')),

(351, 'play-out-of-pressure', 'sub', 'Play out of pressure', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'secure-the-ball')),
(351, 'keep-the-ball-initiate-build-up', 'sub', 'Keep the ball: initiate build up', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'secure-the-ball')),

(351, 'provide-support-in-front-of-the-ball', 'sub', 'Provide support in front of the ball', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'join-the-attack-with-speed')),
(351, 'provide-as-much-width-as-necessary', 'sub', 'Provide as much width as necessary', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'join-the-attack-with-speed')),
(351, 'provide-support-behind-the-ball', 'sub', 'Provide support behind the ball', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'join-the-attack-with-speed')),

(351, 'push-up-the-defensive-line-with-speed-dta', 'sub', 'Push up the defensive line with speed: stay connected and compact', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'take-countermeasures-anticipate-the-counter-dta')),
(351, 'create-prevention-shape-behind-the-ball', 'sub', 'Create prevention shape behind the ball', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'take-countermeasures-anticipate-the-counter-dta')),

(351, 'create-and-exploit-space-for-self-or-teammate', 'sub', 'Create and exploit space for self or teammate', 1, (SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'finish-the-counterattack-as-fast-as-possible')),
(351, 'attack-space-or-engage-opponent', 'sub', 'Attack space or engage opponent', 2, (SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'finish-the-counterattack-as-fast-as-possible')),
(351, 'recognize-player-in-a-better-position-to-score', 'sub', 'Recognize player in a better position to score', 3, (SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'finish-the-counterattack-as-fast-as-possible')),
(351, 'finish-use-limited-touches-dta', 'sub', 'Finish: use limited touches', 4, (SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'finish-the-counterattack-as-fast-as-possible'));

INSERT INTO club_game_model_principle_definitions (principle_id, slug, title, definition, sort_order) VALUES
((SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'first-action-forward'), 'definition', 'Definition', $$Start attacking transition immediately with forward action:
- Pass forward into open space or feet to (highest) transition player (vertical / diagonal)
- Touch forward and run or dribble aggressively at maximum speed when space
GK distribution: throw/volley into space or feet$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'continue-to-play-forward'), 'definition', 'Definition', $$Continue to progress the ball forward at speed to prevent the opponent from returning into defensive shape: dribble or pass
Play with limited touches to increase the speed of the transition:
- Direct: open body shape to receive the ball facing forward or turn when time on the ball
- Indirect: lay-off / playing backwards to supporting teammate (3rd man running)$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'play-out-of-pressure'), 'definition', 'Definition', $$Stay central if possible
Take advantage of space behind the opponent's backline - pass behind
Shield the ball when pressure from opponent
Move the ball out of the zone when possession is regained to escape counter press
Play sideways or backwards when unable to dribble or pass forward (or draw foul)$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'keep-the-ball-initiate-build-up'), 'definition', 'Definition', $$Keep possession when opponent is balanced and organized
Recognize risk vs reward: priority is to secure possession$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'provide-support-in-front-of-the-ball'), 'definition', 'Definition', $$Move into attacking shape
Sprint forward and commit numbers into the attacking half
Get players in front of the ball as quickly as possible to attack the backline of the opponent
Provide a passing option: make a run in behind$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'provide-as-much-width-as-necessary'), 'definition', 'Definition', $$Occupy all three central-vertical channels
Restrict runs to width of penalty area, when possible, to facilitate quick passing, limit risk of interception, and create direct chance on goal$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'provide-support-behind-the-ball'), 'definition', 'Definition', $$Position to enable the attack to continue by creating passing options behind the ball
Recycle the attack when unable to continue the counter$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'push-up-the-defensive-line-with-speed-dta'), 'definition', 'Definition', $$Provide balance (numbers)
Close space in between lines that the opponent could exploit
Create as high a line as possible$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'create-prevention-shape-behind-the-ball'), 'definition', 'Definition', $$Defensive positioning with a specific amount of players
- Defend the center of the field: block passing lines
- Lock down the opponent's outlet(s): mark transition players
- GK take high position: stay connected with the backline$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'create-and-exploit-space-for-self-or-teammate'), 'definition', 'Definition', $$Separate from opponent and receive between the lines
Exploit space behind opponent backline: make a run to receive in behind
Make a run to free up space for teammate to receive$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'attack-space-or-engage-opponent'), 'definition', 'Definition', $$Dribble at speed into open space:
- Invite pressure to create (more) space for teammate(s)
Dribble at speed to isolate defender:
- Attract to free up teammate (2v1)
- Eliminate defender or create separation and shoot (1v1)
Keep composure (decision at full speed)$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'recognize-player-in-a-better-position-to-score'), 'definition', 'Definition', $$Recognize the right moment to pass to a teammate in a better position to score or assist
- We attack/occupy different areas in the box$$, 1),

((SELECT id FROM club_game_model_principles WHERE phase_id = 351 AND slug = 'finish-use-limited-touches-dta'), 'definition', 'Definition', $$Select the best surface and shoot on goal with a minimal touches.$$, 1);

-- ---------------------------------------------------------------------
-- 6. PLAYER ACTIONS — "in_possession" catalog (Slides #18-21). Fully
--    defined once under ATTACKING (phase_id 349); reused (name-only on the
--    source slides) by Defending-to-Attacking Transition (phase_id 351,
--    inserted as an identical duplicate block further below).
-- ---------------------------------------------------------------------
-- BEGIN IN_POSSESSION CATALOG (phase 349)
INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, category, category_group, sort_order) VALUES
(349, 'controlling-1', 'Controlling', 'Receiving and preparing the ball from short passes (distance of 5 to 20 yards)', 'Controlling', 'with_the_ball', 1),
(349, 'controlling-2', 'Controlling', 'Receiving and preparing the ball in such a way that you can immediately go to goal', 'Controlling', 'with_the_ball', 2),
(349, 'controlling-3', 'Controlling', 'Receiving and preparing the ball in such a way that it stays as close to you as possible', 'Controlling', 'with_the_ball', 3),
(349, 'controlling-4', 'Controlling', 'Receiving by moving towards the ball when opponent is close by (attacking the ball)', 'Controlling', 'with_the_ball', 4),
(349, 'controlling-5', 'Controlling', 'Receiving and preparing the ball from a long pass in the air', 'Controlling', 'with_the_ball', 5),
(349, 'controlling-6', 'Controlling', 'Receiving and preparing the ball on the bounce', 'Controlling', 'with_the_ball', 6),
(349, 'controlling-7', 'Controlling', $$Receiving and preparing the ball on the turn towards the opponent's goal as quickly as possible$$, 'Controlling', 'with_the_ball', 7),
(349, 'controlling-8', 'Controlling', 'Receiving and playing in 1 touch if you can pass accurately', 'Controlling', 'with_the_ball', 8),
(349, 'controlling-9', 'Controlling', 'Avoiding looking at the ball when receiving and preparing the ball', 'Controlling', 'with_the_ball', 9),
(349, 'controlling-10', 'Controlling', 'Scanning for a free teammate after performing the control', 'Controlling', 'with_the_ball', 10),
(349, 'controlling-11', 'Controlling', 'Scanning for a free teammate before or while receiving and preparing the ball', 'Controlling', 'with_the_ball', 11),
(349, 'controlling-12', 'Controlling', 'Avoiding a long ball from bouncing - receiving before the bounce', 'Controlling', 'with_the_ball', 12),
(349, 'controlling-13', 'Controlling', 'Receiving and playing a long ball in 1 touch if you can pass accurately', 'Controlling', 'with_the_ball', 13),

(349, 'protecting-1', 'Protecting', 'Shielding and maintaining possession of the ball, by placing most of the body between the ball and opponent, keeping the ball on the furthest foot away from the defender while looking for teammates', 'Protecting', 'with_the_ball', 14),
(349, 'protecting-2', 'Protecting', 'Turning away from and out of reach of your opponent', 'Protecting', 'with_the_ball', 15),

(349, 'driving-1', 'Driving', 'Running with the ball, keeping the ball as close as possible to the body', 'Driving', 'with_the_ball', 16),
(349, 'driving-2', 'Driving', 'Avoiding looking at the ball while driving the ball', 'Driving', 'with_the_ball', 17),
(349, 'driving-3', 'Driving', 'Keeping your body between the ball and the approaching opponent while driving the ball', 'Driving', 'with_the_ball', 18),
(349, 'driving-4', 'Driving', 'Running as fast as possible with the ball, picking up speed to gain as much time and territory as possible', 'Driving', 'with_the_ball', 19),
(349, 'driving-5', 'Driving', 'Creating space in advance (before controlling) in which you want to drive the ball', 'Driving', 'with_the_ball', 20),

(349, 'dribbling-1', 'Dribbling', 'Taking on the opponent', 'Dribbling', 'with_the_ball', 21),
(349, 'dribbling-2', 'Dribbling', 'Reading the body shape of the opponent and engaging on the most obvious/weak side', 'Dribbling', 'with_the_ball', 22),
(349, 'dribbling-3', 'Dribbling', 'Accelerating when eliminating the opponent', 'Dribbling', 'with_the_ball', 23),
(349, 'dribbling-4', 'Dribbling', 'Avoiding looking at the ball while dribbling', 'Dribbling', 'with_the_ball', 24),
(349, 'dribbling-5', 'Dribbling', 'Keeping your body between the ball and the opponent while dribbling', 'Dribbling', 'with_the_ball', 25),
(349, 'dribbling-6', 'Dribbling', 'Holding off the opponent and creating distance from the opponent', 'Dribbling', 'with_the_ball', 26),
(349, 'dribbling-7', 'Dribbling', 'Dribbling through a change of direction at the right time, or through a change of speed or through a feint', 'Dribbling', 'with_the_ball', 27),
(349, 'dribbling-8', 'Dribbling', 'Dribbling when you can cause direct danger on target', 'Dribbling', 'with_the_ball', 28),

(349, 'passing-1', 'Passing', 'Playing the ball intentionally with different surfaces to a free teammate, into feet or space, within a distance of 5 to 20 yards', 'Passing', 'with_the_ball', 29),
(349, 'passing-2', 'Passing', 'Playing the ball to the foot so that the player receiving the ball can continue to play forward', 'Passing', 'with_the_ball', 30),
(349, 'passing-3', 'Passing', 'Making a leading pass in front of your teammate, making sure that the teammate can take the ball without having to slow down', 'Passing', 'with_the_ball', 31),
(349, 'passing-4', 'Passing', 'Looking at the player you are passing to when passing', 'Passing', 'with_the_ball', 32),
(349, 'passing-5', 'Passing', 'Trying to take out an opponent with a quick wall pass (give and go) in a small space', 'Passing', 'with_the_ball', 33),
(349, 'passing-6', 'Passing', 'Making a long pass in the air', 'Passing', 'with_the_ball', 34),
(349, 'passing-7', 'Passing', 'Playing a long ball in space so a teammate can receive the ball while running', 'Passing', 'with_the_ball', 35),
(349, 'passing-8', 'Passing', 'Avoiding passing to a player surrounded by opponents who can be immediately put under pressure', 'Passing', 'with_the_ball', 36),
(349, 'passing-9', 'Passing', 'Playing the cross at the right time and with the right ball speed outside the action area of the goalkeeper and the defender', 'Passing', 'with_the_ball', 37),
(349, 'passing-10', 'Passing', 'Disguising the pass', 'Passing', 'with_the_ball', 38),

(349, 'shooting-1', 'Shooting', 'Striking the ball intentionally with different surfaces from short and medium range (1-10 yards; 11-20 yards) on the goal (finishing)', 'Shooting', 'with_the_ball', 39),
(349, 'shooting-2', 'Shooting', 'Looking at the position of the goalkeeper before shooting at goal, and selecting a target', 'Shooting', 'with_the_ball', 40),
(349, 'shooting-3', 'Shooting', 'Aiming for the far side if you shoot from an angle and the goalkeeper is protecting near post', 'Shooting', 'with_the_ball', 41),
(349, 'shooting-4', 'Shooting', 'Finishing in 1 time/touch when closely marked', 'Shooting', 'with_the_ball', 42),
(349, 'shooting-5', 'Shooting', 'Finishing on the volley / bounce', 'Shooting', 'with_the_ball', 43),
(349, 'shooting-6', 'Shooting', 'Following the ball after the shot', 'Shooting', 'with_the_ball', 44),
(349, 'shooting-7', 'Shooting', 'Dribbling at the goalkeeper when he/she comes out at full speed or when he or she protects the goal well and scoring from the shot becomes difficult', 'Shooting', 'with_the_ball', 45),
(349, 'shooting-8', 'Shooting', 'Chipping the goalkeeper', 'Shooting', 'with_the_ball', 46),
(349, 'shooting-9', 'Shooting', 'Disguising the finish', 'Shooting', 'with_the_ball', 47),

(349, 'scanning-1', 'Scanning', $$Searching for the ball, teammates and the goal:
- scanning for a free teammate after performing the control
- scanning for a free teammate before or while receiving and preparing the ball (passing)
- scanning and avoiding looking at the ball while dribbling
- scanning and looking at the position of the goalkeeper before shooting at goal, and selecting a target (shooting)$$, 'Scanning', 'spatial_positional_awareness', 48),

(349, 'supporting-1', 'Supporting (Positioning)', 'Looking at the player in possession of the ball', 'Supporting (Positioning)', 'spatial_positional_awareness', 49),
(349, 'supporting-2', 'Supporting (Positioning)', 'Finding open space for self and indicating this, verbally or non-verbally, to the player in possession of the ball', 'Supporting (Positioning)', 'spatial_positional_awareness', 50),
(349, 'supporting-3', 'Supporting (Positioning)', 'Repositioning after giving a pass (ex. give and go)', 'Supporting (Positioning)', 'spatial_positional_awareness', 51),
(349, 'supporting-4', 'Supporting (Positioning)', $$Assessing teammates' movements and moving off each other$$, 'Supporting (Positioning)', 'spatial_positional_awareness', 52),
(349, 'supporting-5', 'Supporting (Positioning)', 'Unmarking and running behind opponent when a teammate on the ball is looking for options', 'Supporting (Positioning)', 'spatial_positional_awareness', 53),
(349, 'supporting-6', 'Supporting (Positioning)', $$Looking to get out of sight from the defender's vision$$, 'Supporting (Positioning)', 'spatial_positional_awareness', 54),
(349, 'supporting-7', 'Supporting (Positioning)', 'Losing direct opponent by switching positions with a teammate', 'Supporting (Positioning)', 'spatial_positional_awareness', 55),
(349, 'supporting-8', 'Supporting (Positioning)', 'Anticipating as the third player who will get the ball after a pass between two teammates', 'Supporting (Positioning)', 'spatial_positional_awareness', 56),

(349, 'adapting-body-shape-1', 'Adapting Body Shape', 'Adjusting shoulders and hips to be 45 - 90 degrees towards the attacking goal.', 'Adapting Body Shape', 'spatial_positional_awareness', 57),
(349, 'adapting-body-shape-2', 'Adapting Body Shape', 'While approaching, have an optimal overview of the game situation.', 'Adapting Body Shape', 'spatial_positional_awareness', 58);
-- END IN_POSSESSION CATALOG (phase 349)

-- BEGIN IN_POSSESSION CATALOG (phase 351) — duplicate of phase 349's catalog;
-- Defending-to-Attacking Transition reuses this catalog by category name
-- only on Slide #38, no separate definitions given in the source.
INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, category, category_group, sort_order) VALUES
(351, 'controlling-1', 'Controlling', 'Receiving and preparing the ball from short passes (distance of 5 to 20 yards)', 'Controlling', 'with_the_ball', 1),
(351, 'controlling-2', 'Controlling', 'Receiving and preparing the ball in such a way that you can immediately go to goal', 'Controlling', 'with_the_ball', 2),
(351, 'controlling-3', 'Controlling', 'Receiving and preparing the ball in such a way that it stays as close to you as possible', 'Controlling', 'with_the_ball', 3),
(351, 'controlling-4', 'Controlling', 'Receiving by moving towards the ball when opponent is close by (attacking the ball)', 'Controlling', 'with_the_ball', 4),
(351, 'controlling-5', 'Controlling', 'Receiving and preparing the ball from a long pass in the air', 'Controlling', 'with_the_ball', 5),
(351, 'controlling-6', 'Controlling', 'Receiving and preparing the ball on the bounce', 'Controlling', 'with_the_ball', 6),
(351, 'controlling-7', 'Controlling', $$Receiving and preparing the ball on the turn towards the opponent's goal as quickly as possible$$, 'Controlling', 'with_the_ball', 7),
(351, 'controlling-8', 'Controlling', 'Receiving and playing in 1 touch if you can pass accurately', 'Controlling', 'with_the_ball', 8),
(351, 'controlling-9', 'Controlling', 'Avoiding looking at the ball when receiving and preparing the ball', 'Controlling', 'with_the_ball', 9),
(351, 'controlling-10', 'Controlling', 'Scanning for a free teammate after performing the control', 'Controlling', 'with_the_ball', 10),
(351, 'controlling-11', 'Controlling', 'Scanning for a free teammate before or while receiving and preparing the ball', 'Controlling', 'with_the_ball', 11),
(351, 'controlling-12', 'Controlling', 'Avoiding a long ball from bouncing - receiving before the bounce', 'Controlling', 'with_the_ball', 12),
(351, 'controlling-13', 'Controlling', 'Receiving and playing a long ball in 1 touch if you can pass accurately', 'Controlling', 'with_the_ball', 13),

(351, 'protecting-1', 'Protecting', 'Shielding and maintaining possession of the ball, by placing most of the body between the ball and opponent, keeping the ball on the furthest foot away from the defender while looking for teammates', 'Protecting', 'with_the_ball', 14),
(351, 'protecting-2', 'Protecting', 'Turning away from and out of reach of your opponent', 'Protecting', 'with_the_ball', 15),

(351, 'driving-1', 'Driving', 'Running with the ball, keeping the ball as close as possible to the body', 'Driving', 'with_the_ball', 16),
(351, 'driving-2', 'Driving', 'Avoiding looking at the ball while driving the ball', 'Driving', 'with_the_ball', 17),
(351, 'driving-3', 'Driving', 'Keeping your body between the ball and the approaching opponent while driving the ball', 'Driving', 'with_the_ball', 18),
(351, 'driving-4', 'Driving', 'Running as fast as possible with the ball, picking up speed to gain as much time and territory as possible', 'Driving', 'with_the_ball', 19),
(351, 'driving-5', 'Driving', 'Creating space in advance (before controlling) in which you want to drive the ball', 'Driving', 'with_the_ball', 20),

(351, 'dribbling-1', 'Dribbling', 'Taking on the opponent', 'Dribbling', 'with_the_ball', 21),
(351, 'dribbling-2', 'Dribbling', 'Reading the body shape of the opponent and engaging on the most obvious/weak side', 'Dribbling', 'with_the_ball', 22),
(351, 'dribbling-3', 'Dribbling', 'Accelerating when eliminating the opponent', 'Dribbling', 'with_the_ball', 23),
(351, 'dribbling-4', 'Dribbling', 'Avoiding looking at the ball while dribbling', 'Dribbling', 'with_the_ball', 24),
(351, 'dribbling-5', 'Dribbling', 'Keeping your body between the ball and the opponent while dribbling', 'Dribbling', 'with_the_ball', 25),
(351, 'dribbling-6', 'Dribbling', 'Holding off the opponent and creating distance from the opponent', 'Dribbling', 'with_the_ball', 26),
(351, 'dribbling-7', 'Dribbling', 'Dribbling through a change of direction at the right time, or through a change of speed or through a feint', 'Dribbling', 'with_the_ball', 27),
(351, 'dribbling-8', 'Dribbling', 'Dribbling when you can cause direct danger on target', 'Dribbling', 'with_the_ball', 28),

(351, 'passing-1', 'Passing', 'Playing the ball intentionally with different surfaces to a free teammate, into feet or space, within a distance of 5 to 20 yards', 'Passing', 'with_the_ball', 29),
(351, 'passing-2', 'Passing', 'Playing the ball to the foot so that the player receiving the ball can continue to play forward', 'Passing', 'with_the_ball', 30),
(351, 'passing-3', 'Passing', 'Making a leading pass in front of your teammate, making sure that the teammate can take the ball without having to slow down', 'Passing', 'with_the_ball', 31),
(351, 'passing-4', 'Passing', 'Looking at the player you are passing to when passing', 'Passing', 'with_the_ball', 32),
(351, 'passing-5', 'Passing', 'Trying to take out an opponent with a quick wall pass (give and go) in a small space', 'Passing', 'with_the_ball', 33),
(351, 'passing-6', 'Passing', 'Making a long pass in the air', 'Passing', 'with_the_ball', 34),
(351, 'passing-7', 'Passing', 'Playing a long ball in space so a teammate can receive the ball while running', 'Passing', 'with_the_ball', 35),
(351, 'passing-8', 'Passing', 'Avoiding passing to a player surrounded by opponents who can be immediately put under pressure', 'Passing', 'with_the_ball', 36),
(351, 'passing-9', 'Passing', 'Playing the cross at the right time and with the right ball speed outside the action area of the goalkeeper and the defender', 'Passing', 'with_the_ball', 37),
(351, 'passing-10', 'Passing', 'Disguising the pass', 'Passing', 'with_the_ball', 38),

(351, 'shooting-1', 'Shooting', 'Striking the ball intentionally with different surfaces from short and medium range (1-10 yards; 11-20 yards) on the goal (finishing)', 'Shooting', 'with_the_ball', 39),
(351, 'shooting-2', 'Shooting', 'Looking at the position of the goalkeeper before shooting at goal, and selecting a target', 'Shooting', 'with_the_ball', 40),
(351, 'shooting-3', 'Shooting', 'Aiming for the far side if you shoot from an angle and the goalkeeper is protecting near post', 'Shooting', 'with_the_ball', 41),
(351, 'shooting-4', 'Shooting', 'Finishing in 1 time/touch when closely marked', 'Shooting', 'with_the_ball', 42),
(351, 'shooting-5', 'Shooting', 'Finishing on the volley / bounce', 'Shooting', 'with_the_ball', 43),
(351, 'shooting-6', 'Shooting', 'Following the ball after the shot', 'Shooting', 'with_the_ball', 44),
(351, 'shooting-7', 'Shooting', 'Dribbling at the goalkeeper when he/she comes out at full speed or when he or she protects the goal well and scoring from the shot becomes difficult', 'Shooting', 'with_the_ball', 45),
(351, 'shooting-8', 'Shooting', 'Chipping the goalkeeper', 'Shooting', 'with_the_ball', 46),
(351, 'shooting-9', 'Shooting', 'Disguising the finish', 'Shooting', 'with_the_ball', 47),

(351, 'scanning-1', 'Scanning', $$Searching for the ball, teammates and the goal:
- scanning for a free teammate after performing the control
- scanning for a free teammate before or while receiving and preparing the ball (passing)
- scanning and avoiding looking at the ball while dribbling
- scanning and looking at the position of the goalkeeper before shooting at goal, and selecting a target (shooting)$$, 'Scanning', 'spatial_positional_awareness', 48),

(351, 'supporting-1', 'Supporting (Positioning)', 'Looking at the player in possession of the ball', 'Supporting (Positioning)', 'spatial_positional_awareness', 49),
(351, 'supporting-2', 'Supporting (Positioning)', 'Finding open space for self and indicating this, verbally or non-verbally, to the player in possession of the ball', 'Supporting (Positioning)', 'spatial_positional_awareness', 50),
(351, 'supporting-3', 'Supporting (Positioning)', 'Repositioning after giving a pass (ex. give and go)', 'Supporting (Positioning)', 'spatial_positional_awareness', 51),
(351, 'supporting-4', 'Supporting (Positioning)', $$Assessing teammates' movements and moving off each other$$, 'Supporting (Positioning)', 'spatial_positional_awareness', 52),
(351, 'supporting-5', 'Supporting (Positioning)', 'Unmarking and running behind opponent when a teammate on the ball is looking for options', 'Supporting (Positioning)', 'spatial_positional_awareness', 53),
(351, 'supporting-6', 'Supporting (Positioning)', $$Looking to get out of sight from the defender's vision$$, 'Supporting (Positioning)', 'spatial_positional_awareness', 54),
(351, 'supporting-7', 'Supporting (Positioning)', 'Losing direct opponent by switching positions with a teammate', 'Supporting (Positioning)', 'spatial_positional_awareness', 55),
(351, 'supporting-8', 'Supporting (Positioning)', 'Anticipating as the third player who will get the ball after a pass between two teammates', 'Supporting (Positioning)', 'spatial_positional_awareness', 56),

(351, 'adapting-body-shape-1', 'Adapting Body Shape', 'Adjusting shoulders and hips to be 45 - 90 degrees towards the attacking goal.', 'Adapting Body Shape', 'spatial_positional_awareness', 57),
(351, 'adapting-body-shape-2', 'Adapting Body Shape', 'While approaching, have an optimal overview of the game situation.', 'Adapting Body Shape', 'spatial_positional_awareness', 58);
-- END IN_POSSESSION CATALOG (phase 351)

-- ---------------------------------------------------------------------
-- 7. PLAYER ACTIONS — "out_of_possession" catalog (Slides #32-33). Fully
--    defined once under DEFENDING (phase_id 350); reused (name-only on the
--    source slides) by Attacking-to-Defending Transition (phase_id 352,
--    inserted as an identical duplicate block further below).
-- ---------------------------------------------------------------------
-- BEGIN OUT_OF_POSSESSION CATALOG (phase 350)
INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, category, category_group, sort_order) VALUES
(350, 'intercepting-1', 'Intercepting', 'Intercept when a chance of winning or deflecting the ball, if not stay in position', 'Intercepting', 'against_the_ball', 1),
(350, 'intercepting-2', 'Intercepting', $$Deflecting an opponent's pass away from the intended target$$, 'Intercepting', 'against_the_ball', 2),
(350, 'intercepting-3', 'Intercepting', 'Staying in possession of the ball after stealing it and continuing with an attacking action', 'Intercepting', 'against_the_ball', 3),
(350, 'intercepting-4', 'Intercepting', 'Playing in one touch to a teammate', 'Intercepting', 'against_the_ball', 4),
(350, 'intercepting-5', 'Intercepting', 'Intercept the ball as high as possible (high point) on a long (high) ball', 'Intercepting', 'against_the_ball', 5),

(350, 'pressing-1', 'Pressing', 'Running to the opponent who is about to receive the ball (approx. 2 yards distance) while the ball is moving (to reduce the space for the opponent or force error)', 'Pressing', 'against_the_ball', 6),
(350, 'pressing-2', 'Pressing', 'Having fast approach but slow arrival', 'Pressing', 'against_the_ball', 7),
(350, 'pressing-3', 'Pressing', 'Approach is forcing into desired area', 'Pressing', 'against_the_ball', 8),

(350, 'challenging-1', 'Challenging', 'Taking good defensive posture (on toes, knees are bent, staggered stance, …) that allows to start the 1v1 in favorable conditions', 'Challenging', 'against_the_ball', 9),
(350, 'challenging-2', 'Challenging', 'Always looking at the ball', 'Challenging', 'against_the_ball', 10),
(350, 'challenging-3', 'Challenging', 'Staying on your feet', 'Challenging', 'against_the_ball', 11),
(350, 'challenging-4', 'Challenging', 'Retaining possession of the ball after winning the duel', 'Challenging', 'against_the_ball', 12),
(350, 'challenging-5', 'Challenging', $$If you are eliminated, don't give up, challenge again immediately$$, 'Challenging', 'against_the_ball', 13),

(350, 'delaying-1', 'Delaying', $$Slowing down, reducing speed from the opponent's action$$, 'Delaying', 'against_the_ball', 14),
(350, 'delaying-2', 'Delaying', 'Driving the player on the ball to the outside (away from goal)', 'Delaying', 'against_the_ball', 15),

(350, 'block-the-shot-1', 'Block the Shot', 'Getting in between the ball and the defending goal to redirect the ball away from goal', 'Block the Shot', 'against_the_ball', 16),

(350, 'scanning-1', 'Scanning', 'Searching for the ball, nearest teammates and nearest opponents in relationship to the goal we are protecting', 'Scanning', 'spatial_positional_awareness', 17),

(350, 'adapting-body-shape-1', 'Adapting Body Shape', 'Adjusting shoulders and hips to be 45 - 90 degrees towards the defending goal', 'Adapting Body Shape', 'spatial_positional_awareness', 18),

(350, 'covering-1', 'Covering', 'Positioning at the appropriate distance from the challenging teammate, allowing to quickly put pressure again if needed', 'Covering', 'spatial_positional_awareness', 19),
(350, 'covering-2', 'Covering', 'Preventing the opponent behind your back (between the lines) from being an option', 'Covering', 'spatial_positional_awareness', 20),

(350, 'marking-1', 'Marking', 'Preventing direct opponent from receiving the ball in favorable circumstances by positioning next to the opponent (proactive stance)', 'Marking', 'spatial_positional_awareness', 21),
(350, 'marking-2', 'Marking', 'Trying to look at both the ball and direct opponent', 'Marking', 'spatial_positional_awareness', 22),
(350, 'marking-3', 'Marking', 'Marking closer when closer to goal', 'Marking', 'spatial_positional_awareness', 23);
-- END OUT_OF_POSSESSION CATALOG (phase 350)

-- BEGIN OUT_OF_POSSESSION CATALOG (phase 352) — duplicate of phase 350's catalog;
-- Attacking-to-Defending Transition reuses this catalog by category name
-- only on Slide #26, no separate definitions given in the source.
INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, category, category_group, sort_order) VALUES
(352, 'intercepting-1', 'Intercepting', 'Intercept when a chance of winning or deflecting the ball, if not stay in position', 'Intercepting', 'against_the_ball', 1),
(352, 'intercepting-2', 'Intercepting', $$Deflecting an opponent's pass away from the intended target$$, 'Intercepting', 'against_the_ball', 2),
(352, 'intercepting-3', 'Intercepting', 'Staying in possession of the ball after stealing it and continuing with an attacking action', 'Intercepting', 'against_the_ball', 3),
(352, 'intercepting-4', 'Intercepting', 'Playing in one touch to a teammate', 'Intercepting', 'against_the_ball', 4),
(352, 'intercepting-5', 'Intercepting', 'Intercept the ball as high as possible (high point) on a long (high) ball', 'Intercepting', 'against_the_ball', 5),

(352, 'pressing-1', 'Pressing', 'Running to the opponent who is about to receive the ball (approx. 2 yards distance) while the ball is moving (to reduce the space for the opponent or force error)', 'Pressing', 'against_the_ball', 6),
(352, 'pressing-2', 'Pressing', 'Having fast approach but slow arrival', 'Pressing', 'against_the_ball', 7),
(352, 'pressing-3', 'Pressing', 'Approach is forcing into desired area', 'Pressing', 'against_the_ball', 8),

(352, 'challenging-1', 'Challenging', 'Taking good defensive posture (on toes, knees are bent, staggered stance, …) that allows to start the 1v1 in favorable conditions', 'Challenging', 'against_the_ball', 9),
(352, 'challenging-2', 'Challenging', 'Always looking at the ball', 'Challenging', 'against_the_ball', 10),
(352, 'challenging-3', 'Challenging', 'Staying on your feet', 'Challenging', 'against_the_ball', 11),
(352, 'challenging-4', 'Challenging', 'Retaining possession of the ball after winning the duel', 'Challenging', 'against_the_ball', 12),
(352, 'challenging-5', 'Challenging', $$If you are eliminated, don't give up, challenge again immediately$$, 'Challenging', 'against_the_ball', 13),

(352, 'delaying-1', 'Delaying', $$Slowing down, reducing speed from the opponent's action$$, 'Delaying', 'against_the_ball', 14),
(352, 'delaying-2', 'Delaying', 'Driving the player on the ball to the outside (away from goal)', 'Delaying', 'against_the_ball', 15),

(352, 'block-the-shot-1', 'Block the Shot', 'Getting in between the ball and the defending goal to redirect the ball away from goal', 'Block the Shot', 'against_the_ball', 16),

(352, 'scanning-1', 'Scanning', 'Searching for the ball, nearest teammates and nearest opponents in relationship to the goal we are protecting', 'Scanning', 'spatial_positional_awareness', 17),

(352, 'adapting-body-shape-1', 'Adapting Body Shape', 'Adjusting shoulders and hips to be 45 - 90 degrees towards the defending goal', 'Adapting Body Shape', 'spatial_positional_awareness', 18),

(352, 'covering-1', 'Covering', 'Positioning at the appropriate distance from the challenging teammate, allowing to quickly put pressure again if needed', 'Covering', 'spatial_positional_awareness', 19),
(352, 'covering-2', 'Covering', 'Preventing the opponent behind your back (between the lines) from being an option', 'Covering', 'spatial_positional_awareness', 20),

(352, 'marking-1', 'Marking', 'Preventing direct opponent from receiving the ball in favorable circumstances by positioning next to the opponent (proactive stance)', 'Marking', 'spatial_positional_awareness', 21),
(352, 'marking-2', 'Marking', 'Trying to look at both the ball and direct opponent', 'Marking', 'spatial_positional_awareness', 22),
(352, 'marking-3', 'Marking', 'Marking closer when closer to goal', 'Marking', 'spatial_positional_awareness', 23);
-- END OUT_OF_POSSESSION CATALOG (phase 352)

COMMIT;
