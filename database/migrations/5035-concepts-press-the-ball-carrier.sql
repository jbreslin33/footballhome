-- 5035 (2026-11-27): "Press the ball carrier" — its own section (was "Pressure on the ball") with six
-- sub-sections, the owner's model: every card is a piece of understanding a player has or lacks (ratings, learning,
-- and the sim plays 'lacking it looks like'); the coach's plan sets the specifics as numbers (press / shadow / side /
-- from mark or free / who takes the man left), not new cards. 9 new cards fill the gaps the model shows.
-- DB only: new cards are queued; the engine is untouched.
BEGIN;
UPDATE game_principles SET title = 'Press the ball carrier', description = 'The foundation of defending: the first defender goes to the man on the ball. Every card here is a piece of understanding a player has or lacks — rated per player, taught by drills, and in the sim a player who lacks one plays its ''lacking it looks like'' instead. The coach''s plan sets the specifics as numbers, not new cards: whom to press, whom to shadow, which side, whether he presses from his mark or as the free man, and who takes the man he leaves (the 🎯 tactic plan job). When the plan says nothing, the player falls back on these cards'' default rules.' WHERE code = 'op-pressure';
INSERT INTO game_principles (code, moment, parent_id, title, description, sort_order) VALUES ('op-pb-approach', 'out_of_possession', (SELECT id FROM game_principles WHERE code = 'op-pressure'), '1 · Get to him', 'How you arrive: close him down, slow down at the end, curve the run so a pass sits in your shadow, come from his blind side, and turn and go again if he beats you.', 7);
INSERT INTO game_principles (code, moment, parent_id, title, description, sort_order) VALUES ('op-pb-shadow', 'out_of_possession', (SELECT id FROM game_principles WHERE code = 'op-pressure'), '2 · What you take away', 'While you press, the pass you shut: your own man when you leave him to press, the most dangerous pass when you were free, the switch, the back pass — or, in your own third, his path to goal.', 7);
INSERT INTO game_principles (code, moment, parent_id, title, description, sort_order) VALUES ('op-pb-show', 'out_of_possession', (SELECT id FROM game_principles WHERE code = 'op-pressure'), '3 · Which way you show him', 'Your angle decides where he can go: down the touchline, toward our trap or press direction, inside onto our cover when outnumbered, or onto his weaker foot.', 7);
INSERT INTO game_principles (code, moment, parent_id, title, description, sort_order) VALUES ('op-pb-jump', 'out_of_possession', (SELECT id FROM game_principles WHERE code = 'op-pressure'), '4 · Who jumps', 'Who presses, and who must not: the free man jumps and the markers stay; a marker who jumps keeps his man in his shadow or the chain shifts behind him; the spare and the screen hold their posts.', 7);
INSERT INTO game_principles (code, moment, parent_id, title, description, sort_order) VALUES ('op-pb-body', 'out_of_possession', (SELECT id FROM game_principles WHERE code = 'op-pressure'), '5 · Distance and body', 'Once you are there: side-on, on your feet, and turn and run with him when he goes at speed.', 7);
INSERT INTO game_principles (code, moment, parent_id, title, description, sort_order) VALUES ('op-pb-win', 'out_of_possession', (SELECT id FROM game_principles WHERE code = 'op-pressure'), '6 · Win it or hold him up', 'The decision at the end: step in or contain until help arrives, tackle when the ball is exposed, win it shoulder to shoulder, win the duel.', 7);
UPDATE game_concepts SET principle_id = (SELECT id FROM game_principles WHERE code = 'op-pb-approach') WHERE name IN ('close-down', 'cover-shadow', 'blind-side-press', 'double-press', 'press-through');
UPDATE game_concepts SET principle_id = (SELECT id FROM game_principles WHERE code = 'op-pb-show') WHERE name IN ('jockey-angle', 'side-on-jockey', 'winger-press-angle', 'outnumbered-show-cover');
UPDATE game_concepts SET principle_id = (SELECT id FROM game_principles WHERE code = 'op-pb-body') WHERE name IN ('drop-step', 'restraint');
UPDATE game_concepts SET principle_id = (SELECT id FROM game_principles WHERE code = 'op-pb-win') WHERE name IN ('engage-or-contain', 'tackle-timing', 'shoulder-charge', 'win-duel');
UPDATE game_concepts SET principle_id = (SELECT id FROM game_principles WHERE code = 'op-mark') WHERE name IN ('intercept');

INSERT INTO game_concepts (id, name, title, family, moment, status, kind, principle_id, definition, cue_answer, lacking)
SELECT v.id, v.name, v.title, v.family, 'out_of_possession', 'queued', 'behaviour', p.id, v.def, v.cue, v.lacking FROM (VALUES
  (266, 'slow-down-approach', 'Slow down on the approach', 'individual', 'op-pb-approach', 'Sprint to close the distance, then shorten your steps and lower your body over the last few metres so you arrive balanced and can still move either way.', 'Nearly there: shorten your steps, get low.', 'Arrives at full speed and is dribbled past with one touch.'),
  (267, 'keep-man-in-shadow', 'Leave your mark: keep him in your shadow', 'individual', 'op-pb-shadow', 'When you leave the man you were marking to press the ball, curve your run so your own man stays hidden behind you and the pass to him is shut.', 'Leaving your man to press: keep him behind you as you go.', 'Presses the ball and leaves his own man free for the easy pass.'),
  (268, 'free-shadow-danger', 'From free: shadow the most dangerous pass', 'individual', 'op-pb-shadow', 'Pressing as the free man (you were minding space, not a man): curve so the most dangerous pass near you — usually the nearest forward or central one — is in your shadow.', 'Free and pressing: which pass hurts us most? Hide it behind you.', 'The free man presses straight and shuts nothing.'),
  (269, 'cut-the-switch', 'Cut the switch', 'individual', 'op-pb-shadow', 'Approach so the pass across to the far side (their other centre-back or the far full-back) sits in your shadow, and he can only go the way we want.', 'Press from the middle side: the ball must not go across.', 'Presses, and the ball simply goes across to the free side.'),
  (270, 'cut-the-back-pass', 'Cut the back pass', 'individual', 'op-pb-shadow', 'Approach from the goal side of the carrier so the pass back to his keeper or centre-back is in your shadow, forcing him to play forward into our press or long.', 'Press so he cannot go back: make him play forward.', 'He resets through the keeper every time we press.'),
  (271, 'block-path-to-goal', 'Block the path to goal', 'individual', 'op-pb-shadow', 'In our own third the goal is the danger, not the pass: get goal-side on the line between him and the goal, block the dribble and the shot, and let him pass sideways.', 'Near our box: goal first — stand between him and the goal.', 'Chases the passing lanes in his own box and the carrier walks through to shoot.'),
  (272, 'show-weaker-foot', 'Show him onto his weaker foot', 'individual', 'op-pb-show', 'Angle your approach so the carrier has to use his weaker foot and away from his favourite move: a crosser inside, an inside-cutter outside.', 'Which foot is he? Show him the other one.', 'Lets him onto his strong foot for the move he always makes.'),
  (273, 'free-man-jumps', 'Free man jumps, markers stay', 'group', 'op-pb-jump', 'When their man receives, the nearest of ours who is free (marking nobody) goes to him; the players marking men stay on them, so pressing opens nobody.', 'Ball to their free man: if you are free, you go; if you have a man, stay.', 'A marker jumps while the free man watches, and now two of theirs are open.'),
  (274, 'know-when-not-to-jump', 'Know when you may not jump', 'individual', 'op-pb-jump', 'Some free men must not press: the spare man at the back and the screen in front of the back four hold their posts, because their job is the space behind the press.', 'You are the spare or the screen: let the ball come, hold your post.', 'The libero or the screen leaves his post to press and the back is exposed.')
) v(id, name, title, family, pcode, def, cue, lacking) JOIN game_principles p ON p.code = v.pcode;

INSERT INTO game_concept_links (concept_id, other_id, kind)
SELECT a.id, b.id, v.k FROM (VALUES
  ('slow-down-approach', 'close-down', 'refines'),
  ('keep-man-in-shadow', 'cover-shadow', 'refines'),
  ('free-shadow-danger', 'cover-shadow', 'refines'),
  ('cut-the-switch', 'cover-shadow', 'refines'),
  ('cut-the-back-pass', 'cover-shadow', 'refines'),
  ('block-path-to-goal', 'close-down', 'refines'),
  ('show-weaker-foot', 'jockey-angle', 'refines'),
  ('free-man-jumps', 'cover', 'refines'),
  ('know-when-not-to-jump', 'cover', 'refines'),
  ('keep-man-in-shadow', 'marking-chain-shift', 'lapses-to'),
  ('nine-curve-press', 'cut-the-switch', 'kind-of')
) v(a, b, k) JOIN game_concepts a ON a.name = v.a JOIN game_concepts b ON b.name = v.b ON CONFLICT DO NOTHING;
INSERT INTO game_concept_measures (concept, measure) VALUES
  ('slow-down-approach', 'press'),
  ('keep-man-in-shadow', 'press'),
  ('free-shadow-danger', 'press'),
  ('cut-the-switch', 'press'),
  ('cut-the-back-pass', 'press'),
  ('block-path-to-goal', 'duel'),
  ('show-weaker-foot', 'duel'),
  ('free-man-jumps', 'off_ball'),
  ('know-when-not-to-jump', 'off_ball')
ON CONFLICT DO NOTHING;
UPDATE game_principles SET sort_order = 6 WHERE code = 'op-pressure' OR parent_id = (SELECT id FROM game_principles WHERE code = 'op-pressure');  -- before Cover and balance (7)
COMMIT;
