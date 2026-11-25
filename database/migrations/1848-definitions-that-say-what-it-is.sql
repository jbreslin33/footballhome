-- 1848 (2026-11-24): definitions that say what a thing IS.
--
-- Owner 11/24, reading the concept clip viewer: "each concept needs a more detailed
-- definition. like hold the block spot does that mean their formation block or block a
-- pass lol".  The engine's own short names were on the screen as if everyone knew them.
--
-- game_engine_terms.definition and game_concepts.definition: what it is, when it happens,
-- and what it is NOT (the thing it gets mistaken for).  A term's title is also said in
-- plain words where the engine's name misleads.  Every state, decision and phase here; the
-- concepts the viewer can show today.  The other concepts keep their cue until theirs is
-- written — the page shows a definition where there is one and the cue where there is not.
ALTER TABLE game_engine_terms ADD COLUMN IF NOT EXISTS definition text;
ALTER TABLE game_concepts ADD COLUMN IF NOT EXISTS definition text;

UPDATE game_engine_terms t SET title = v.title, definition = v.def
  FROM (VALUES
    -- player states
    ('state', 'on_ball', 'On the ball',
     'He has the ball under control at his feet. From here he does exactly one thing: shoot, pass, cross, carry it forward, or clear it. Not this: a ball rolling near him that he has not reached yet (that is going for the loose ball).'),
    ('state', 'support', 'Support the man on the ball',
     'His team has the ball but he does not. He moves to where his position should be for where the ball is now — wide to stretch them, short to offer a pass, or behind the ball for safety — so the man on the ball has somewhere to play. Not this: a sprint in behind their defence (that is its own state).'),
    ('state', 'receive', 'Receive the pass',
     'A teammate has played the ball to him. He moves to meet it and take his first touch. It lasts only from the pass being struck to the ball arriving.'),
    ('state', 'attack_box', 'Attack the penalty area',
     'A cross or a ball into their penalty area is coming. He runs into the area to get on the end of it — near post, far post or the penalty spot. Not this: standing in the area waiting.'),
    ('state', 'run_line', 'Run in behind their defence',
     'He runs at and past their last defender to receive a ball played over the top or through the gap, timing it to stay onside.'),
    ('state', 'hold_block', 'Hold his place in the team''s defensive shape',
     'They have the ball and he is NOT the one going to it. He stands in his position within his team''s defensive shape and moves with that shape: across toward the side the ball is on, back as the ball comes forward, up as it goes back. He is guarding space and staying connected to the men beside him. "Block" here means the whole team''s compact shape — its lines of defence, midfield and attack. It does NOT mean blocking a pass or blocking a shot.'),
    ('state', 'press_ball', 'Press the man on the ball',
     'They have the ball and he is the one man who goes to it. He closes down the opponent with the ball and stops a short distance away on the side of his own goal, so the man cannot simply run past him. If he gets close enough and is goal-side he may try to win it. Only one player on a team is in this state at a time. Not this: several players swarming the ball.'),
    ('state', 'chase_ball', 'Go for the loose ball',
     'Nobody has the ball — it is rolling free, bouncing, or a pass that could be cut out — and he is the player on his team who can get to it first. He runs to where he can take it. Not this: pressing an opponent who already has it.'),
    ('state', 'mark_man', 'Mark the opponent in his area',
     'They have the ball and an opponent WITHOUT it is standing in this defender''s area. He stays close to that man, between him and his own goal, so a pass to him can be challenged. In the sim today this is zonal: when the man leaves the area he is passed on to the next defender. Only centre-backs, full-backs and the holding midfielder do it. Not this: following one opponent all over the pitch (man-oriented marking).'),
    ('state', 'keeper', 'Goalkeeper: set his position',
     'The ball is not in the keeper''s hands. He places himself between the ball and his goal, a little off his line, narrowing the angle, ready to save, come for a cross or sweep up behind his defence.'),
    -- decisions (what he is doing this instant)
    ('decision', 'hold', 'Hold his position',
     'No action on the ball: he is keeping or getting to his place in the team''s shape. With his team defending that is his place in the defensive shape; with his team attacking it is his supporting position.'),
    ('decision', 'shoot', 'Shoot', 'He strikes at goal.'),
    ('decision', 'pass', 'Pass', 'He plays the ball to a teammate''s feet.'),
    ('decision', 'cross', 'Cross', 'From a wide area he plays the ball into their penalty area for a teammate to attack.'),
    ('decision', 'dribble', 'Carry the ball', 'He runs with the ball at his feet. No better pass or shot is on yet, or he is taking it into space.'),
    ('decision', 'clear', 'Clear it', 'Under pressure near his own goal he kicks the ball away to safety rather than try to keep it.'),
    ('decision', 'keeper_punt', 'Keeper kicks long', 'The goalkeeper kicks the ball a long way up the pitch.'),
    ('decision', 'keeper_pos', 'Keeper sets his position', 'The goalkeeper moves to the right place between the ball and his goal.'),
    ('decision', 'keeper_dive', 'Keeper dives', 'The goalkeeper dives to save a shot.'),
    ('decision', 'press', 'Close down the man on the ball', 'He is stepping to the opponent who has the ball.'),
    ('decision', 'chase', 'Go for the loose ball', 'He is running to a ball nobody has.'),
    ('decision', 'meet_pass', 'Come to meet the pass', 'A pass is on its way to him and he moves to it instead of waiting for it.'),
    ('decision', 'restart', 'Take the restart', 'He is taking a goal kick, a free kick or a kick-off.'),
    ('decision', 'throw_in', 'Take the throw-in', 'He is taking a throw-in.'),
    ('decision', 'corner', 'Take the corner', 'He is taking a corner kick.'),
    ('decision', 'law_distance', 'Stand back the distance the Laws require', 'At an opponent''s free kick, corner, throw-in or goal kick he keeps the distance the Laws of the Game demand until the ball is played.'),
    ('decision', 'attack_box', 'Attack the penalty area', 'He is running into their area for a cross or a ball in.'),
    ('decision', 'in_behind', 'Play the ball in behind', 'On the ball, he passes into the space behind their defence for a running teammate.'),
    ('decision', 'run_line', 'Run in behind their defence', 'He is making the run past their last defender.'),
    ('decision', 'into_space', 'Play the ball into space', 'On the ball, he passes into an empty area for a teammate to run onto, rather than to feet.'),
    ('decision', 'mark', 'Mark his man', 'He is staying close to an opponent without the ball, between that man and his own goal.'),
    -- team phases
    ('phase', 'in_possession', 'We have the ball (settled)', 'His team has had the ball for a few seconds and is building an attack.'),
    ('phase', 'attacking_transition', 'We have just won the ball', 'The first few seconds after winning it, while the other team is out of shape: the chance to attack quickly.'),
    ('phase', 'defending_block', 'They have the ball (settled)', 'The other team has had the ball for a few seconds; his team is in its defensive shape.'),
    ('phase', 'defensive_transition', 'We have just lost the ball', 'The first few seconds after losing it, while his own team is out of shape: win it straight back, or delay and get back.'),
    ('phase', 'our_set_piece', 'Our set piece', 'His team has a corner, free kick, throw-in, goal kick or kick-off.'),
    ('phase', 'their_set_piece', 'Their set piece', 'The other team has a corner, free kick, throw-in, goal kick or kick-off.')
  ) AS v(kind, code, title, def)
 WHERE t.kind = v.kind AND t.code = v.code;

UPDATE game_concepts c SET definition = v.def
  FROM (VALUES
    ('pressing-distance',
     'How close a defender stays to the opponent he is responsible for. Close enough that if the ball is passed to that man, the defender can get to him while the ball is still travelling — so the man never gets a free first touch. In the sim today it is the gap the one presser keeps from the man on the ball: he closes to a stand-off distance and holds it. Not this: winning the ball. Staying in pressing distance is being close enough to press, not the tackle.'),
    ('compact-block',
     'The whole team staying close together when it does not have the ball: about 35 metres from the back line to the front line, and narrow across the pitch. "Block" is the team''s shape, not blocking a shot. Close together means no big gaps between the lines for the opponent to receive in, and a defender always has a teammate near him. Each player''s part is to hold his place in that shape and move with it.'),
    ('recover',
     'Getting back behind the ball after being caught on the wrong side of it. A player who is further up the pitch than he should be runs back toward his own goal to his place in the shape, at full pace, before doing anything else. Goal-side means between the ball and his own goal.'),
    ('cover',
     'Backing up the teammate who has gone to press. When one defender steps to the man on the ball, the nearest teammate drops in behind him, on the line between the ball and their goal. If the presser is beaten, the covering man is already there. In the sim today it is the deeper of the two centre-backs.'),
    ('nearest-decides',
     'When the ball is loose, or the team has just lost it, the player nearest the ball is the one who must act — go for it, or delay the opponent — and everyone else works off his decision. It stops two players going for the same ball and stops nobody going.'),
    ('zonal-marking',
     'Each defender looks after an area, not a particular opponent. Whoever comes into his area is his to mark — close, between the man and the goal. When that opponent moves out of the area the defender lets him go to the next defender and stays where he is. It keeps the team''s shape; the risk is the moment of handing a man over.'),
    ('man-mark',
     'Each defender is given one particular opponent and stays with him wherever he goes, even out of the defender''s normal position. It denies that opponent the ball; the risk is that a clever runner drags the defender away and leaves a hole. The opposite of zonal marking.'),
    ('cover-shadow',
     'Pressing the man on the ball while blocking a pass at the same time. The presser approaches on a curve so that an opponent behind him stays hidden — in his "shadow" — and the ball cannot be passed to that man along the ground. One defender takes two opponents out: the one he presses and the one he screens. Not this: running straight at the ball, which leaves the pass behind you open.'),
    ('engage-or-contain',
     'The presser''s choice once he is close: step in and try to win the ball, or hold off and just stay in front of the man. Step in when a teammate is covering behind you, or when the opponent is trapped by the touchline. Hold off when you are alone, because if you dive in and miss there is nobody behind you.')
  ) AS v(name, def)
 WHERE c.name = v.name;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Taxonomy of Football — field: definition', 'taxonomy', 'f_definition', NULL, 'What it is', 95, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = 'f_definition');

-- The clip viewer's caption when the ball is out of play (owner: "i saw the ball go off the pitch lol").
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — caption: ball out of play ({team})', 'taxonomy', 'cap_ball_dead', NULL, '⚽ out of play — restart for {team}', 268, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = 'cap_ball_dead');

-- The clip viewer's progress bar while the first example is found (owner: "we need to show a
-- progress bar on the loading of the video").
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — loading: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('title', 'load_title', 'Getting the first example from the live match', 270),
    ('step: words', 'load_words', 'Loading the concept', 271),
    ('step: connecting', 'load_connect', 'Connecting to the live match', 272),
    ('step: watching ({s} seconds so far)', 'load_watch', 'Watching for a player to do it… {s} s', 273),
    ('step: recording, not started', 'load_record_wait', 'Then recording the five seconds after', 274),
    ('step: recording ({num}, {player}, {s} seconds left)', 'load_record', 'Found one — #{num} {player}. Recording what happens next… {s} s', 275)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);

-- The side panel shows titles only; a tap opens the meaning.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — panel hint', 'taxonomy', 'clip_sm_tap', NULL, 'Tap any name ⓘ for what it means.', 226, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = 'clip_sm_tap');
DELETE FROM message_templates WHERE kind = 'taxonomy' AND tier IN ('clip_sm_note', 'clip_sm_side', 'clip_sm_with', 'clip_sm_without', 'clip_sm_concept');
