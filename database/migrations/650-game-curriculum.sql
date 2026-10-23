-- 650 (2026-10-23) — game: the concept registry IS the curriculum
-- (game/DESIGN.md §8.33).
--
-- James: "the concepts are also the curriculum to teach" / "there is
-- always room for a concept". Every concept is a lesson a coach can rate
-- and drill, so the list moves from C++ to rows: game_concepts (stable id,
-- name, lesson text, family, moment, the level it's a default from,
-- status, sources) + game_concept_requires (teach this before that).
-- fh-game loads it at boot; a concept without an engine class is still
-- rated and taught — it just doesn't drive behaviour yet.
--
-- Ids 0-30 are the wired concepts at their old wire numbers (append-only;
-- every saved rating and preset keys on name, the wire on id). taught_from
-- reproduces the old band bundles exactly (cover/support/placement/
-- line-hold from u10, the rest of the coached set from amateur, STYLE
-- concepts never). Queued lessons carry NULL until placed on the ladder.

CREATE TABLE IF NOT EXISTS game_concepts (
    id          SMALLINT PRIMARY KEY CHECK (id BETWEEN 0 AND 254),
    name        TEXT NOT NULL UNIQUE,
    title       TEXT NOT NULL,
    family      TEXT NOT NULL CHECK (family IN ('individual', 'group', 'team', 'keeper')),
    moment      TEXT NOT NULL CHECK (moment IN ('in_possession', 'out_of_possession', 'to_attack', 'to_defend')),
    kind        TEXT NOT NULL CHECK (kind IN ('core', 'style')),
    taught_from TEXT CHECK (taught_from IN ('u10', 'u14', 'amateur', 'semipro', 'pro', 'world')),
    status      TEXT NOT NULL CHECK (status IN ('wired', 'queued', 'teaching')),
    cue_answer  TEXT NOT NULL,
    lacking     TEXT NOT NULL,
    sources     TEXT NOT NULL,
    CHECK (kind = 'core' OR taught_from IS NULL)
);
COMMENT ON TABLE game_concepts IS 'The curriculum: every soccer concept a player HAS or LACKS (mig 650). id = wire id (append-only). fh-game loads it at boot.';
COMMENT ON COLUMN game_concepts.taught_from IS 'Lowest level band that knows it by default (band quality as rating); NULL = never a band default (style, or not yet placed).';
COMMENT ON COLUMN game_concepts.status IS 'wired = an engine class plays it; queued = planned engine behaviour; teaching = curriculum only.';

CREATE TABLE IF NOT EXISTS game_concept_requires (
    concept_id  SMALLINT NOT NULL REFERENCES game_concepts(id),
    requires_id SMALLINT NOT NULL REFERENCES game_concepts(id),
    PRIMARY KEY (concept_id, requires_id),
    CHECK (concept_id <> requires_id)
);
COMMENT ON TABLE game_concept_requires IS 'Teach this before that (mig 650): a compound concept needs its components first.';

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, sources) VALUES
 (0, 'delay', 'Delay the attack', 'individual', 'to_defend', 'core', 'amateur', 'wired', 'We lose the ball and you are nearest: get goal-side and jockey to buy time; step in only once help has arrived.', 'Dives in on every turnover and is beaten by one touch.', '[FH/James]'),
 (1, 'marking', 'Mark a dangerous man', 'individual', 'out_of_possession', 'core', 'amateur', 'wired', 'Our shape is set: pick up a dangerous opponent and stay goal-side of him, touch-close.', 'Ball-watching; opponents free between the lines.', 'Standard coaching frameworks'),
 (2, 'cover', 'Cover the presser', 'group', 'out_of_possession', 'core', 'u10', 'wired', 'A teammate presses the ball: sit behind him on the line between ball and goal.', 'One dribble beats the whole defence.', 'Standard coaching frameworks'),
 (3, 'support', 'Support the ball', 'group', 'in_possession', 'core', 'u10', 'wired', 'A teammate has the ball: the nearest player moves to an open spot ahead of him.', 'Statues; the carrier has no options.', '[Buckland]'),
 (4, 'outlet', 'Offer the outlet behind', 'group', 'in_possession', 'core', 'amateur', 'wired', 'The carrier is under pressure: the second supporter offers a pass behind the ball.', 'No way out of pressure.', 'Standard coaching frameworks'),
 (5, 'runs', 'Run in behind', 'individual', 'in_possession', 'core', 'amateur', 'wired', 'Most advanced attacker: attack the space behind their last line, staying onside.', 'Nobody stretches the defence.', 'Standard coaching frameworks'),
 (6, 'over-top', 'Play over the top', 'individual', 'in_possession', 'core', 'amateur', 'wired', 'A runner is beyond their line: lift the ball over the block into his path.', 'Only ground passes into traffic.', 'DESIGN.md §5.2'),
 (7, 'sweep', 'Sweeper keeper', 'keeper', 'out_of_possession', 'core', 'amateur', 'wired', 'A loose ball in our defensive third: the keeper comes and owns it.', 'Through balls go uncontested; the keeper stays on his line.', 'Standard coaching frameworks'),
 (8, 'placement', 'Place the shot', 'individual', 'in_possession', 'core', 'u10', 'wired', 'Shooting: aim inside the far post, away from the keeper.', 'Shoots at the keeper.', 'Standard coaching frameworks'),
 (9, 'line-hold', 'Hold the line', 'team', 'out_of_possession', 'core', 'u10', 'wired', 'Defending: the back line holds about 25 m from the ball instead of retreating into the goalmouth.', 'The retreat spiral — the line ends on the six-yard box.', '[FH]'),
 (10, 'jockey-angle', 'Show him the touchline', 'individual', 'out_of_possession', 'core', 'amateur', 'wired', 'Delaying the carrier: stand a step inside him so his only way is down the line.', 'Square-on; he picks either side.', 'Standard coaching frameworks'),
 (11, 'recover', 'Recover goal-side', 'individual', 'to_defend', 'core', 'amateur', 'wired', 'You''ve been beaten: sprint back onto the line between ball and goal, not at the ball.', 'Chasing the play from behind.', 'Standard coaching frameworks'),
 (12, 'double-team', 'Trap on the touchline', 'group', 'out_of_possession', 'core', 'amateur', 'wired', 'The carrier is pinned wide: the cover man closes in; the touchline is the third defender.', 'Wide carriers escape 1v1.', 'Standard coaching frameworks'),
 (13, 'width', 'Hold the width', 'team', 'in_possession', 'core', 'amateur', 'wired', 'We have the ball: wide players hold the touchline so the attack doesn''t bunch.', 'The attack narrows itself into their block.', '[FH/James]'),
 (14, 'give-and-go', 'Pass and move', 'group', 'in_possession', 'core', 'amateur', 'wired', 'You''ve just passed: run past your receiver for the return ball.', 'Pass and stand.', 'Standard coaching frameworks'),
 (15, 'push-up', 'Push up as a unit', 'team', 'out_of_possession', 'core', 'amateur', 'wired', 'The ball goes away from our goal: the line steps up and stays close behind it.', 'A line that only ever retreats.', 'DFB/RB school; [FH/James]'),
 (16, 'counter-press', 'Win it straight back', 'team', 'to_defend', 'core', 'amateur', 'wired', 'We''ve just lost the ball: the nearest players swarm to win it back before organising.', 'Jogging back and conceding the transition.', 'KNVB four moments; gegenpress'),
 (17, 'balance', 'Tuck in on the far side', 'team', 'out_of_possession', 'core', 'amateur', 'wired', 'The ball is on the far side: the weak-side defender tucks toward the centre.', 'A back line stretched square across the pitch.', 'English FA principles of play'),
 (18, 'man-mark', 'Man-oriented marking', 'individual', 'out_of_possession', 'style', NULL, 'wired', 'Out of possession: take YOUR man and follow him anywhere; 0 = zonal marking.', 'Zonal marking only.', '[Bielsa]; Gasperini; [Bielsa-Leeds ch2]'),
 (19, 'verticality', 'Play forward first', 'individual', 'in_possession', 'style', NULL, 'wired', 'On the ball: look forward before sideways and accept tighter lanes.', 'Safe sideways passing.', '[Bielsa]; Zeman; [Bielsa-Leeds ch4]'),
 (20, 'intercept', 'Read the pass', 'individual', 'out_of_possession', 'core', 'amateur', 'wired', 'A pass is played near you: meet the ball at the earliest point you can reach it.', 'Chasing where the ball is, always a step behind.', '[FH] G4.14'),
 (21, 'restraint', 'Stay on your feet', 'individual', 'out_of_possession', 'core', 'amateur', 'wired', 'Facing a carrier: don''t dive in; stay up and wait for the moment.', 'Rash, repeated diving in.', '[FH] G4.16'),
 (22, 'tackle-timing', 'Tackle when the ball is exposed', 'individual', 'out_of_possession', 'core', 'amateur', 'wired', 'Tackle on the ball side when it''s away from his feet — never through the man from behind.', 'Lunging from behind.', '[FH] G4.17'),
 (23, 'counter-attack', 'Break on the regain', 'team', 'to_attack', 'style', NULL, 'wired', 'We win it in our half: play forward at once and a second runner joins the break.', 'Wins it and recycles; nobody breaks.', 'KNVB moment 4; [Bielsa-Leeds f13/37]'),
 (24, 'safe-pass', 'Keep the ball', 'individual', 'in_possession', 'core', 'amateur', 'wired', 'Before passing: check no defender can cut it out; under pressure recycle to the safest man; clear only in your own third.', 'Passes into defenders; boots it away under any pressure.', '[Buckland]'),
 (25, 'shot-selection', 'Pick your shot', 'individual', 'in_possession', 'core', 'amateur', 'wired', 'Shoot when you can see enough of the goal, not just because you''re in range.', 'Shoots the moment he''s in range, through bodies.', '[FH] after the xG literature'),
 (26, 'libero', 'The free man at the back', 'individual', 'out_of_possession', 'style', NULL, 'wired', 'Behind man-marking: mark nobody, shadow the ball across, read the long ball.', 'A spare defender who just stands in the line.', '[Bielsa]; [Bielsa-Leeds ch1/ch8]'),
 (27, 'cover-shadow', 'Press on the cover shadow', 'individual', 'out_of_possession', 'style', NULL, 'wired', 'Pressing their centre back: run at him along the line to his nearest receiver, so that pass is blocked by your body.', 'Running straight at the carrier and leaving the 6 open.', '[Bielsa]; Klopp; [Bielsa-Leeds ch3]'),
 (28, 'line-step', 'Step up on a covered ball', 'team', 'out_of_possession', 'style', NULL, 'wired', 'The ball is covered (travelling, or the carrier is turned or pressed): the line steps up; a free man facing forward: hold.', 'A line that only drops, or steps into the long ball.', 'Sacchi; FA / KNVB / DFB back-four models'),
 (29, 'pass-ladder', 'Look forward in order', 'individual', 'in_possession', 'style', NULL, 'wired', 'On the ball: look in order — in behind (central, then wide), the pocket in front of their line, past their first line — and play the highest one that''s on.', 'Takes the most forward pass only if it gains a lot.', '[Bielsa-Leeds ch4]'),
 (30, 'blind-side-run', 'The blind-side run', 'individual', 'in_possession', 'style', NULL, 'wired', 'Up at their line: wait onside on the far shoulder of your defender; go in behind when our carrier is free and the defender can''t see you; come back if the ball doesn''t come.', 'Rides the line and runs only once the ball is already played.', '[Bielsa-Leeds f7/21/35/46/48/51/65/78/81/82]'),
 (31, 'first-touch-direction', 'Touch into space', 'individual', 'in_possession', 'core', NULL, 'queued', 'Receiving: take the first touch into space, away from pressure, not under your feet.', 'The ball stops dead and the defender arrives.', 'Standard coaching frameworks'),
 (32, 'shield-ball', 'Shield the ball', 'individual', 'in_possession', 'core', NULL, 'queued', 'Pressed from behind: put your body between the man and the ball.', 'Ball poked away from behind.', 'Standard coaching frameworks; [Bielsa-Leeds f62/74]'),
 (33, 'scan-before-receive', 'Check your shoulder', 'individual', 'in_possession', 'core', NULL, 'queued', 'Before the ball arrives: look over your shoulder to know where the pressure and the space are.', 'Receives blind and turns into a defender.', 'Standard coaching frameworks'),
 (34, 'half-turn-receive', 'Receive on the half-turn', 'individual', 'in_possession', 'core', NULL, 'queued', 'Receiving in midfield: open your body so the next pass can go forward.', 'Receives facing his own goal every time.', 'Standard coaching frameworks'),
 (35, 'beat-man-1v1', 'Beat your man', 'individual', 'in_possession', 'core', NULL, 'queued', 'Isolated 1v1 with space: take him on.', 'Always passes backwards from a 1v1.', '[v1] feint behavior'),
 (36, 'match-up', 'Match up: +1 at the back, -1 up top', 'team', 'out_of_possession', 'style', NULL, 'queued', 'Read their shape: one more defender than their strikers, one fewer presser than their back line; switch to a back three against two strikers.', 'A fixed shape whatever the opponent plays.', '[Bielsa-Leeds ch1]; James 10/22'),
 (37, 'pivot-drop', 'The 6 drops beside a centre back', 'group', 'in_possession', 'style', NULL, 'queued', 'Their first line presses with as many as our centre backs: the 6 drops beside a centre back to make three.', 'Two centre backs outnumbered by the press.', '[Bielsa-Leeds ch1, f57, ch10]; sportmonks 4-2-3-1'),
 (38, 'pivot-step', 'One pivot steps up', 'group', 'out_of_possession', 'style', NULL, 'queued', 'Double pivot: one steps up to press beside the 10 while the other covers across.', 'Both pivots sit; their midfield builds freely.', 'Premier League 4-2-3-1 explainer'),
 (39, 'inside-forward', 'Cut inside', 'individual', 'in_possession', 'style', NULL, 'queued', 'Wide forward on his unnatural side: come inside to shoot or combine; the full-back gives the width.', 'Wingers who only cross.', 'Premier League 4-2-3-1 explainer; [Bielsa-Leeds ch6]'),
 (40, 'ten-arrives', 'The 10 arrives', 'individual', 'in_possession', 'style', NULL, 'queued', 'The ball goes into the 9: the 10 arrives late behind him.', 'The 9 alone in the box.', 'Premier League 4-2-3-1 explainer'),
 (41, 'overlap', 'Overlap', 'group', 'in_possession', 'core', NULL, 'queued', 'The winger carries inside: the full-back runs around the outside of him.', 'The winger isolated with no run outside.', '[Bielsa-Leeds f52, goal 5]'),
 (42, 'underlap', 'Underlap', 'group', 'in_possession', 'core', NULL, 'queued', 'The winger holds the touchline: the full-back or 8 runs inside him into the channel.', 'Nobody attacks the gap between full-back and centre back.', '[Bielsa-Leeds ch5]'),
 (43, 'rotation', 'Rotate to open a lane', 'group', 'in_possession', 'style', NULL, 'queued', 'The carrier has time but no forward pass: a teammate leaves his spot, dragging his marker; the nearest teammate fills the gap and takes the pass. The 6 never rotates.', 'Fixed positions that a man-marking team simply follows.', '[Bielsa-Leeds ch5, f5/27-31/62/80]'),
 (44, 'press-minus-one', 'Press with one fewer', 'team', 'out_of_possession', 'style', NULL, 'queued', 'They build from the back: press their first line with one fewer than they have; everyone else tight on his man.', 'Everyone presses and is played through.', '[Bielsa-Leeds f14-16/36]'),
 (45, 'touchline-trap', 'The touchline trap', 'group', 'out_of_possession', 'style', NULL, 'queued', 'A pass to their man on the touchline: two press with their own men behind them, a third cuts the pass down the line.', 'The wide man turns and escapes down the line.', '[Bielsa-Leeds f16]'),
 (46, 'back-to-goal-trap', 'Trap the man facing his own goal', 'group', 'out_of_possession', 'style', NULL, 'queued', 'Their receiver faces his own goal: the three nearest close him and the 9 screens the pass back.', 'He lays it back and they reset.', '[Bielsa-Leeds f17]'),
 (47, 'loose-pass-trap', 'Jump the loose pass', 'group', 'out_of_possession', 'core', NULL, 'queued', 'A heavy touch or a bad pass: the nearest two jump on it.', 'Watching the mistake instead of punishing it.', '[Bielsa-Leeds f41/55]'),
 (48, 'press-through', 'Keep pressing the next man', 'individual', 'out_of_possession', 'core', NULL, 'queued', 'Your man lays it off: carry your press on to the new carrier.', 'Stopping after the first pass.', '[Bielsa-Leeds f60/64]'),
 (49, 'chain-recover', 'Recover from ahead of the ball', 'team', 'to_defend', 'style', NULL, 'queued', 'A teammate is beaten: the nearest player ahead of the ball sprints back goal-side of the carrier and the next man takes his runner; the back line never steps out.', 'The free centre back steps out and the line is broken.', '[Bielsa-Leeds f11/18-19]'),
 (50, 'find-your-man', 'Find your man', 'individual', 'to_defend', 'style', NULL, 'queued', 'We lose the ball: near your man, get tight; far from him, slide across onto the pass to him.', 'Chasing the ball, leaving his man free.', '[Bielsa-Leeds ch2, f12]'),
 (51, 'screen-transition', 'Screen the transition', 'individual', 'to_defend', 'core', NULL, 'queued', 'We lose it: the 6 is first into the space in front of the back line and steps to a carrier entering it.', 'A turnover runs straight at the back four.', '[Bielsa-Leeds ch1, f59]'),
 (52, 'regain-spread', 'Make the pitch big', 'team', 'to_attack', 'core', NULL, 'queued', 'We win it: wide men sprint back to the touchlines and forward; the 9 attacks the gap between their centre backs.', 'Everyone still bunched from defending.', '[Bielsa-Leeds f13/37/83-84]'),
 (53, 'second-ball', 'Win the second ball', 'group', 'to_attack', 'core', NULL, 'queued', 'A clearance drops in midfield: attack it; when the 9 wins a header, a teammate arrives underneath for the knock-down.', 'Second balls all go to them.', '[Bielsa-Leeds f66/79]'),
 (54, 'eights-high', '8s high, centre empty', 'group', 'in_possession', 'style', NULL, 'queued', 'We start to build: both 8s go up toward the 9; the centre is used only by rotating into it.', '8s sitting beside the 6, crowding the build-up.', '[Bielsa-Leeds ch1/5/7]'),
 (55, 'inverted-fullback', 'Take the lane your winger leaves', 'individual', 'in_possession', 'style', NULL, 'queued', 'Your winger holds the touchline: come inside beside the 6; your winger comes inside: go round the outside.', 'Full-back and winger in the same lane.', '[Bielsa-Leeds ch9, f52]'),
 (56, 'hold-width-weak-side', 'Stay wide on the far side', 'individual', 'in_possession', 'core', NULL, 'queued', 'The ball is on the other side: hold the touchline and stay 1v1 with your full-back.', 'Drifting toward the ball and killing the switch.', '[Bielsa-Leeds ch6, f34]'),
 (57, 'switch-play', 'Switch the play', 'team', 'in_possession', 'core', NULL, 'queued', 'Their block has shifted to the ball: a diagonal to the isolated man on the far side.', 'Attacking into the crowded side again and again.', 'DESIGN.md §5.2; [Bielsa-Leeds f34/45]'),
 (58, 'box-occupancy', 'Fill the box', 'team', 'in_possession', 'core', NULL, 'queued', 'A cross or cut-back is coming: the 9 attacks the far post, the far full-back the back post, an 8 arrives late at the edge.', 'One man in the box.', '[Bielsa-Leeds f75/84, goals 1-3]'),
 (59, 'drive-into-space', 'Drive into the space', 'individual', 'in_possession', 'core', NULL, 'queued', 'A rotation empties a lane in front of you: run the ball into it to draw another defender out.', 'Passes sideways into the space instead of using it.', '[Bielsa-Leeds f31/44/48/50/53/58]'),
 (60, 'release-timing', 'Time the release', 'individual', 'in_possession', 'core', NULL, 'queued', 'A runner is about to break: hold the ball until he goes, then play it; if the run is already on, play first time.', 'Plays too early (offside) or too late (run dead).', '[Bielsa-Leeds f54/67/71/72]'),
 (61, 'body-feint-pass', 'Show one pass, play another', 'individual', 'in_possession', 'core', NULL, 'queued', 'Open your body to the obvious pass so they shift, then play the other one.', 'Every pass telegraphed.', '[Bielsa-Leeds f46/61/63/69/70/73]'),
 (62, 'change-of-pace', 'Change of pace', 'individual', 'in_possession', 'core', NULL, 'queued', '1v1 out wide: slow down, let the defender commit, then accelerate past him.', 'Runs into the defender at one speed.', '[Bielsa-Leeds f76-77]'),
 (63, 'block-shot-line', 'Block the shot', 'individual', 'out_of_possession', 'core', NULL, 'queued', 'A shooter in range: get your body in the line of the shot instead of delaying.', 'Delays while he shoots.', '[FH] G4.22'),
 (64, 'win-duel', 'Win the 1v1 duel', 'individual', 'out_of_possession', 'core', NULL, 'queued', 'A dribbler running at you: win the ball, not just slow him.', 'Never dispossesses a moving dribbler.', '[FH] G4.22'),
 (65, 'wall-pass', 'The wall pass', 'group', 'in_possession', 'core', NULL, 'queued', 'Pressed: play off a teammate and run past your man for the return.', 'Holds the ball into the tackle.', 'Standard coaching frameworks'),
 (66, 'third-man', 'Find the third man', 'group', 'in_possession', 'core', NULL, 'queued', 'The pass to the free man is blocked: play it through a teammate who sets it to him.', 'Only ever passes to the man he can see.', '[v1]; [Bielsa-Leeds f6/23]'),
 (67, 'compact-block', 'Defend compact', 'team', 'out_of_possession', 'core', NULL, 'queued', 'Out of possession: keep the team within about 35 m from front to back.', 'Gaps between the lines.', 'Standard coaching frameworks'),
 (68, 'press-as-unit', 'Press as a unit', 'team', 'out_of_possession', 'core', NULL, 'queued', 'On the trigger: everyone steps together.', 'One man presses alone and is bypassed.', 'Sacchi; standard coaching frameworks'),
 (69, 'play-out-back', 'Play out from the back', 'team', 'in_possession', 'core', NULL, 'queued', 'Keeper and back line against their press: make the extra man and play through it.', 'Every goal kick hit long.', 'Standard coaching frameworks'),
 (70, 'rest-defense', 'Rest defence', 'team', 'in_possession', 'core', NULL, 'queued', 'While we attack: keep enough men behind the ball to stop the counter.', 'Everyone forward, countered every time.', 'Standard coaching frameworks'),
 (71, 'offside-trap', 'Step for offside', 'team', 'out_of_possession', 'core', NULL, 'queued', 'On the pass cue: the whole line steps together.', 'One defender drops and plays everyone on.', 'Standard coaching frameworks'),
 (72, 'tempo-control', 'Control the tempo', 'team', 'in_possession', 'core', NULL, 'queued', 'Ahead late on, or under pressure: slow the game down with the ball; speed it up when the chance is there.', 'One speed all game.', 'Standard coaching frameworks; [Bielsa-Leeds ch12]'),
 (73, 'narrow-angle', 'Narrow the angle', 'keeper', 'out_of_possession', 'core', NULL, 'queued', 'A shooter approaches: come off the line onto the ball-goal line.', 'Stays on the line; the whole goal is open.', 'Standard coaching frameworks'),
 (74, 'distribute-quickly', 'Distribute quickly', 'keeper', 'to_attack', 'core', NULL, 'queued', 'Keeper catches it and they''re unset: release it fast to start the counter.', 'Holds the ball while they reorganise.', 'Standard coaching frameworks; [Bielsa-Leeds f68]'),
 (75, 'command-box', 'Command the box', 'keeper', 'out_of_possession', 'core', NULL, 'queued', 'A cross comes in: come and claim it.', 'Stuck on the line for every cross.', 'Standard coaching frameworks')
ON CONFLICT (id) DO UPDATE SET
   name = EXCLUDED.name, title = EXCLUDED.title, family = EXCLUDED.family,
   moment = EXCLUDED.moment, kind = EXCLUDED.kind, taught_from = EXCLUDED.taught_from,
   status = EXCLUDED.status, cue_answer = EXCLUDED.cue_answer,
   lacking = EXCLUDED.lacking, sources = EXCLUDED.sources;

INSERT INTO game_concept_requires (concept_id, requires_id)
SELECT c.id, r.id FROM (VALUES
 ('wall-pass', 'give-and-go'),
 ('wall-pass', 'support'),
 ('third-man', 'wall-pass'),
 ('press-as-unit', 'delay'),
 ('press-as-unit', 'marking'),
 ('press-as-unit', 'cover'),
 ('press-as-unit', 'push-up'),
 ('offside-trap', 'line-hold'),
 ('offside-trap', 'line-step'),
 ('double-team', 'cover'),
 ('libero', 'cover'),
 ('libero', 'man-mark'),
 ('pass-ladder', 'safe-pass'),
 ('blind-side-run', 'runs'),
 ('release-timing', 'pass-ladder'),
 ('rotation', 'support'),
 ('overlap', 'width'),
 ('underlap', 'width'),
 ('switch-play', 'width'),
 ('box-occupancy', 'runs'),
 ('touchline-trap', 'double-team'),
 ('press-minus-one', 'cover-shadow'),
 ('press-minus-one', 'man-mark'),
 ('chain-recover', 'recover'),
 ('half-turn-receive', 'scan-before-receive'),
 ('hold-width-weak-side', 'width')
) AS v(concept, requires)
  JOIN game_concepts c ON c.name = v.concept
  JOIN game_concepts r ON r.name = v.requires
ON CONFLICT DO NOTHING;
