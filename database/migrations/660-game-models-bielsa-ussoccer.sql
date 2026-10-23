-- 660 (2026-10-23) — game: the two game models the match plays
-- (game/DESIGN.md §8.38).
--
-- James: "only game model we really need right now is bielsa copied by lh.
-- you have to construct his game model from lit. ukies can use us soccer
-- game model" / on 85 for a main principle, 75 for a sub-principle:
-- "yes fine".
--
-- Bielsa: every demand cites the Leeds 2019/20 book ([BL] ch / f = figure)
-- or the school; Lighthouse APSL's team model inherits it. U.S. Soccer
-- U17+: built from the club's copy of the framework (docs/game-model),
-- main principle 85 / sub-principle 75; the Ukrainian Nationals' team model
-- inherits it (their formation stays the 4-2-3-1). Abilities cap every
-- demand (min(demand, ability)), so the numbers say what the model ASKS.

INSERT INTO game_models (name, kind, formation_code, note, sort_order)
VALUES ('U.S. Soccer U17+', 'federation', NULL,
        'U.S. Soccer Player Development Framework, U17+ game model (club copy, docs/game-model): main principle 85, sub-principle 75.', 50)
ON CONFLICT (name) DO UPDATE SET kind = EXCLUDED.kind, note = EXCLUDED.note;
UPDATE game_models SET note = 'Marcelo Bielsa, from the literature: the Leeds 2019/20 book chapter by chapter, plus the school (game/CONCEPTS.md).' WHERE name = 'Bielsa';

INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, c.id, v.demand, v.citation FROM (VALUES
 ('man-mark', 95, '[BL ch2] extreme man-orientation: a CB followed Firmino into Liverpool''s half; ball first, then your man.'),
 ('marking', 90, '[BL ch2 f9] every outfielder paired with a man except the keeper, the spare CB and the 9.'),
 ('libero', 95, '[BL ch1/ch2 f10, ch8] +1 on the first line: the free CB (White) covers the whole line and the ball in behind.'),
 ('match-up', 90, '[BL ch1] CBs = their strikers + 1; back three against two strikers (3-3-1-3).'),
 ('follow-the-dropper', 90, '[BL ch2] the marker follows his man anywhere, even into their half.'),
 ('track-the-runner', 90, '[BL ch2 f11, ch6] wide men track their man deep; runners are followed, never handed off.'),
 ('tighten-near-goal', 85, '[BL ch2] the ball is the first reference: get tight, cover from behind the ball.'),
 ('take-most-dangerous', 70, '[BL ch2] when someone is beaten the marking re-shuffles around the ball.'),
 ('find-your-man', 90, '[BL ch2 f12] on the loss: near your man get tight; far, slide across onto the lane to him (Phillips).'),
 ('chain-recover', 90, '[BL f11/f18-19] beaten: the nearest man AHEAD of the ball recovers goal-side; the spare CB never steps out.'),
 ('recover', 85, '[BL ch6] wide players sprint back to keep the +1.'),
 ('counter-press', 90, '[BL ch3/ch10] murderball fitness; win it back where it was lost.'),
 ('screen-transition', 85, '[BL ch1, f59] the 6 is first into the space in front of the back line on a turnover.'),
 ('press-minus-one', 90, '[BL ch3 f14-16/36] press their build-up line with one fewer: 2 CBs → the 9 alone; 3 → the 9 + a wide forward.'),
 ('cover-shadow', 90, '[BL ch3 f14/15] the 9''s curved run cuts the lateral pass to the other CB.'),
 ('nine-starts-press', 85, '[BL ch3 f14-17] the 9 starts the press only with the angle to cut the lateral.'),
 ('touchline-trap', 85, '[BL ch3 f16] pass to the touchline = trigger: two press, a third cuts the line pass.'),
 ('double-team', 75, '[BL ch3 f16] the touchline as the extra defender.'),
 ('back-to-goal-trap', 85, '[BL ch3 f17] receiver facing his own goal = trigger: three close, the 9 screens the back pass.'),
 ('loose-pass-trap', 80, '[BL f41/f55] a loose pass inside: the nearest 8s or full-back jump it.'),
 ('press-through', 85, '[BL f60/f64] Phillips keeps pressing the next man after the lay-off; Klich jumps the return pass.'),
 ('intercept', 80, '[BL ch2] a player with no man cuts the passing lane to the nearest one.'),
 ('compact-block', 20, '[BL ch1 f2] out of possession there is NO structured midfield block — everyone marks his man.'),
 ('balance', 30, '[BL ch2 f9] no balance or cover except the spare CB.'),
 ('near-tight-far-zone', 20, '[BL ch2] man-orientation everywhere, not zone away from the ball.'),
 ('tactical-foul', 60, '[BL ch11] Klich commits the professional foul to stop a transition.'),
 ('push-up', 85, '[BL ch1/ch5] the team pushes up behind a high, aggressive press.'),
 ('verticality', 90, '[BL ch4] look first for the forward pass that breaks a line.'),
 ('pass-ladder', 90, '[BL ch4] the six-rung order: behind (central, wide), the pocket, between the lines.'),
 ('runs', 90, '[BL ch4 f21] attack the space behind their line.'),
 ('blind-side-run', 85, '[BL f7/21/35/46/48/51/65/78/81/82] the 9 and the far winger go on the defender''s blind side.'),
 ('rotation', 90, '[BL ch5 f5/27-31/62/80] rotations everywhere: a mover drags his marker, the nearest man fills the gap.'),
 ('eights-high', 85, '[BL ch1/ch5/ch7] both 8s go high as soon as we build; the centre is used only by rotating into it.'),
 ('find-the-pocket', 85, '[BL ch7] advanced platforms: the 8s occupy pockets between their midfield and back line.'),
 ('pivot-drop', 85, '[BL ch1, f57, ch10] the 6 drops beside a CB (left, so the LB pushes on) when the CBs are pressed.'),
 ('cb-split', 80, '[BL ch1] the 6''s central position lets the CBs split.'),
 ('cb-step-in', 80, '[BL f44/f48/f49, ch8] White carries through the lane a rotation opened.'),
 ('inverted-fullback', 80, '[BL ch1, ch9] the full-back takes the lane his winger leaves — inside beside the 6, or around the outside.'),
 ('overlap', 80, '[BL f52, goal 5] the full-back overlaps when the winger carries inside.'),
 ('underlap', 70, '[BL ch5] runs inside the winger into the channel.'),
 ('width', 85, '[BL ch6] wide players tight to the touchline in build-up.'),
 ('pin-the-fullback', 85, '[BL ch6 f33] wingers on the touchline: their full-back can''t tuck in or step out.'),
 ('hold-width-weak-side', 85, '[BL ch6 f34, ch13] the far winger (Harrison) holds width 1v1 with his full-back.'),
 ('overload-to-isolate', 85, '[BL ch6 f34] overload the right (Hernandez, Costa, Ayling), switch to the isolated left.'),
 ('switch-play', 80, '[BL f4/f45] the long diagonal to the isolated far winger.'),
 ('drive-into-space', 85, '[BL f31/44/48/50/53/58] carry into the lane a rotation emptied.'),
 ('third-man', 85, '[BL ch4 f6/f23] up, back and through.'),
 ('lay-off', 85, '[BL ch4 f23, ch14 f80] the 9 sets it first time to the arriving 8.'),
 ('give-and-go', 85, '[BL f50] Dallas plays in to Klich and runs on for the return.'),
 ('support', 85, '[BL ch1] short support so the vertical pass always has a next option.'),
 ('release-timing', 80, '[BL f54/f67/f71] the passer waits for the runner, then plays it.'),
 ('body-feint-pass', 70, '[BL f46/61/63/69/73] show the switch, play the other pass.'),
 ('drag-run', 80, '[BL f21] the 9 drops, dragging his CB, and the winger attacks the hole.'),
 ('box-occupancy', 85, '[BL f75/f84, goals 1-3] the 9 at the far post, the far full-back at the back post, an 8 late.'),
 ('cross-zone-runs', 75, '[BL goals 1-3] runners split the box.'),
 ('cut-back', 70, '[BL goal 3] the cut-back to the arriving midfielder.'),
 ('safe-pass', 45, 'Bielsa: verticality over security — accepts losing it going forward.'),
 ('settle-in-possession', 20, '[BL ch4] progress quickly; not possession for its own sake.'),
 ('tempo-control', 40, '[BL ch12] only the 10 (Hernandez) slows the game; the team plays high tempo.'),
 ('counter-attack', 85, '[BL ch6 f37] on the regain, wide forwards run into the half-spaces at once.'),
 ('regain-spread', 90, '[BL f13/f37] make the pitch big: wide men sprint back to the touchlines.'),
 ('anticipate-regain', 80, '[BL f83-84] Bamford holds a pocket while they have it, ready to go on the regain.'),
 ('second-ball', 80, '[BL f66/f79] Klich wins the dropping clearance; Harrison arrives under the 9''s knock-down.'),
 ('quick-restart', 75, '[BL f68] Hernandez demands the ball from the goal kick before they''re set.')
) AS v(concept, demand, citation)
  JOIN game_models m ON m.name = 'Bielsa'
  JOIN game_concepts c ON c.name = v.concept
ON CONFLICT (model_id, concept_id) DO UPDATE SET demand = EXCLUDED.demand, citation = EXCLUDED.citation;

INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, c.id, v.demand, v.citation FROM (VALUES
 ('width', 85, 'Attacking main: create attacking shape — height, width, depth.'),
 ('optimal-spacing', 85, 'Attacking main: create attacking shape (sub: optimal attacking distances).'),
 ('staggered-shape', 75, 'Attacking sub: create appropriate height, width, depth.'),
 ('support', 85, 'Attacking main: provide options to play forward (sub: immediate support under pressure).'),
 ('find-the-pocket', 75, 'Attacking sub: provide vertical or diagonal passing options.'),
 ('overload-to-isolate', 75, 'Attacking sub: create overload centrally or wide.'),
 ('runs', 85, 'Attacking main: break lines to advance (sub: runs behind the defensive line).'),
 ('drag-run', 75, 'Attacking sub: move or lose opponent when marked.'),
 ('drive-into-space', 75, 'Attacking sub: drive with the ball to exploit space.'),
 ('fix-and-release', 75, 'Attacking sub: engage opponent — create 1v1 or 2v1.'),
 ('beat-man-1v1', 75, 'Attacking sub: take on 1v1 to create or score.'),
 ('pass-ladder', 75, 'Attacking sub: find a free player between or behind the lines.'),
 ('switch-play', 75, 'Attacking sub: switch play to the opponent''s weak zone.'),
 ('verticality', 75, 'Game idea: advance the ball quickly, high tempo; transition sub: first action forward.'),
 ('shot-selection', 85, 'Attacking main: finish the attack as fast as possible.'),
 ('box-occupancy', 75, 'Attacking sub: numbers in the box.'),
 ('third-man', 75, 'Attacking sub: final pass — through ball or combination play.'),
 ('wall-pass', 75, 'Attacking sub: final pass — combination play.'),
 ('placement', 75, 'Attacking sub: finish with limited touches.'),
 ('push-up', 75, 'Attacking / transition sub: push up the defensive line with speed, stay connected.'),
 ('rest-defense', 85, 'Attacking / transition main: take countermeasures — high defensive shape behind the ball.'),
 ('compact-block', 85, 'Defending main: create defending shape — compact vertically and horizontally.'),
 ('press-as-unit', 75, 'Defending sub: move as a collective unit, make play predictable.'),
 ('jockey-angle', 75, 'Defending sub: initiate pressure on the ball; force play wide.'),
 ('cover', 75, 'Defending sub: provide cover and balance, eliminate passing options.'),
 ('balance', 75, 'Defending sub: cover and balance; protect the middle.'),
 ('deny-the-switch', 75, 'Defending sub: prevent the switch — keep the opponent on one side.'),
 ('line-hold', 75, 'Defending sub: protect the space behind — anticipate the long ball.'),
 ('sweep', 75, 'Defending sub: protect the space behind (keeper).'),
 ('close-the-centre', 75, 'Defending sub: get narrow and close the centre — deny the through ball.'),
 ('marking', 75, 'Defending sub: marking and tracking opponent.'),
 ('track-the-runner', 75, 'Defending sub: marking and tracking opponent.'),
 ('deny-the-cross', 75, 'Defending sub: deny the cross.'),
 ('defend-the-cross', 75, 'Defending sub: defending the cross — protect the width of the goal.'),
 ('block-shot-line', 85, 'Defending / transition main: challenge to protect against a goal attempt; deny the finish.'),
 ('delay', 85, 'Transition main: delay the counterattack.'),
 ('recover', 85, 'Defending / transition main: recover with speed when pressure is broken.'),
 ('counter-press', 85, 'Transition main: apply immediate pressure on the ball.'),
 ('press-backward', 75, 'Transition sub: press from behind as quickly as possible.'),
 ('second-ball', 75, 'Transition sub: stay connected — win the second ball.'),
 ('drop-on-loss', 75, 'Transition sub: drop off and block the direct path to goal.'),
 ('defend-outnumbered', 75, 'Transition sub: slow down and dictate the opponent.'),
 ('intercept', 75, 'Defending sub: look to intercept the pass or win the second ball.'),
 ('anticipate-regain', 85, 'Transition main: take countermeasures — anticipate the counter.'),
 ('counter-attack', 85, 'Transition main: finish the counterattack as fast as possible.'),
 ('escape-and-advance', 75, 'Transition sub: play out of pressure.'),
 ('counter-or-keep', 75, 'Transition sub: keep the ball — initiate build up.'),
 ('regain-spread', 75, 'Transition sub: provide as much width as necessary.')
) AS v(concept, demand, citation)
  JOIN game_models m ON m.name = 'U.S. Soccer U17+'
  JOIN game_concepts c ON c.name = v.concept
ON CONFLICT (model_id, concept_id) DO UPDATE SET demand = EXCLUDED.demand, citation = EXCLUDED.citation;

-- The Ukies play the U.S. Soccer model now (their line step stays theirs).
UPDATE game_models SET parent_id = (SELECT id FROM game_models WHERE name = 'U.S. Soccer U17+'),
       note = 'Ukrainian Nationals: the U.S. Soccer U17+ game model in their 4-2-3-1, plus their line step.'
 WHERE name = 'Ukrainian Nationals';
