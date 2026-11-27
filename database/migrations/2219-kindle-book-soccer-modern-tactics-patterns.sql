-- 2219 📚 Coaching book patterns: "Soccer: Modern Tactics" (Alessandro Zauli
-- ed., with Ancelotti, Ulivieri, Novellino, Lippi, Sacchi and others,
-- Reedswain) — Kindle library (spreads s001–s158 from Kindle Cloud Reader).
-- Every spread read by readers; each distinct team behaviour written up in
-- OUR OWN WORDS with who does what.  Biographies, opinion and front matter
-- left out.  Owner's personal library.  (James 11/27 Kindle picks)
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    team        = 'Italian Serie A coaches',
    season      = 'late 1990s-early 2000s',
    method_note = 'An Italian coaching manual on zonal play by formation: the back four alone (pressure and cover lines and every defensive situation), how midfield lines of three/four/five and the forwards defend, principles of attack and building from the back with three/four/five, attacking moves for 4-4-2, 4-3-3 and three-at-the-back shapes, defending with a back three, and individual 1v1 defending and attacking, with youth notes. Between chapters, Serie A coaches explain their own systems: Novellino 4-4-2, Lippi''s Juventus 4-3-3, Ancelotti''s Juventus 4-3-1-2, Sandreani 4-2-3-1, Viscidi 4-2-1-3, Sacchi''s Milan, Ulivieri''s Bologna 3-4-2-1, Mandorlini 3-4-1-2, Glerean''s Cittadella 3-3-4 and Terzulli 3-4-3. Patterns are the on-pitch behaviours in our words; drills folded into the behaviour they train. Kindle edition: page numbers are screen spreads.'
WHERE slug = 'kindle-soccer-modern-tactics';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics');

-- 1. pp.6-7
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.1 Coming out and control of the opponent in possession', 'Pressure plus diagonal cover lines',
    'Ball goes wide to an attacker in front of a back four; the nearest full back steps out and the rest stagger diagonally behind him.',
    'Ball played to a wide player',
    'Always one defender ready behind the presser if he is beaten, while staying near enough to the ball but not so tight that a switch kills the line.',
    NULL, 6, 7, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (2)', 'Steps out and pressures the ball'),
    (2, 'Near centre back (4)', 'Covers diagonally behind 2'),
    (3, 'Far centre back (6)', 'Aligned with 4 (one cover line) or diagonal to 4 (double cover)'),
    (4, 'Far full back (3)', 'Tucks in level with the line, or diagonal to 6 for triple cover')
) AS v(so, role, job);

-- 2. pp.6-7
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.1 Coming out and control of the opponent in possession', 'Pyramid shape on a central ball',
    'Ball held centrally in front of the back four; one centre back steps out and the others form a triangle behind him.',
    'Ball reaches a central attacker',
    'Pressure the central carrier while two covers sit behind and the far full back closes the field.',
    NULL, 6, 7, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (4)', 'Steps out onto the central carrier'),
    (2, 'Right back (2) and centre back (6)', 'Triangle cover behind 4'),
    (3, 'Left back (3)', 'Narrows and closes the field')
) AS v(so, role, job);

-- 3. pp.7-7
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.1 Coming out and control of the opponent in possession', 'Close the receiver while ball travels',
    'When a pass goes into an opponent, the nearest defender sprints at him during the ball''s flight and brakes just before the touch.',
    'Long pass played to an opponent',
    'Restrict the receiver''s space, time and above all his deep passing options.',
    NULL, 7, 7, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'Sprint during flight, stop balanced just before receipt'),
    (2, 'Rest of back line', 'Re-set cover behind him')
) AS v(so, role, job);

-- 4. pp.7-9
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.1 Coming out and control of the opponent in possession', 'How many cover lines to use',
    'The back line chooses one, two or three cover lines depending on 1v1 quality and whether the carrier can see goal; more lines invite the opponent to attack depth, a single line needs strong 1v1 defenders.',
    'Carrier turns to face goal vs. back to goal; quality of opposing dribblers',
    'Match depth of cover to the danger: one line when the carrier faces away, two when he faces goal, never so many that runners get in behind.',
    NULL, 7, 9, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'One flat cover line when carrier cannot see goal'),
    (2, 'Back four', 'Double cover line when carrier faces goal and can pass deep'),
    (3, 'Defenders who are slow in 1v1', 'Ask for multiple cover lines behind them')
) AS v(so, role, job);

-- 5. pp.7-9
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.1 Coming out and control of the opponent in possession', 'Tight or loose marking: can he see goal',
    'Zonal marking references are ball, zone, man; markers sit goal-side, see ball and man, and adjust tightness to the carrier''s view.',
    'Carrier''s body orientation',
    'Mark forwards tightly when the carrier cannot see goal or the attacker is near goal; mark looser when the carrier can shoot or play deep, or the man is far from the ball.',
    NULL, 7, 9, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Each defender', 'Stay between man and goal, see ball and man'),
    (2, 'Markers of the front men', 'Tight when carrier faces away or attacker near goal'),
    (3, 'Markers far from ball', 'Looser, protecting space')
) AS v(so, role, job);

-- 6. pp.10-10
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.2 Passing the marking duties from one defender to the next', 'Handing on the dribbler between zones',
    'A dribbler moves laterally across the back line; each defender passes him to the next zone''s defender, who is already shuffling level, then drops back into cover.',
    'Dribbler enters neighbouring defender''s zone',
    'No gap during the handover; receiver of the marking calls it because the old marker has his back turned.',
    NULL, 10, 10, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Current marker (2)', 'Holds the dribbler until told, then returns to cover'),
    (2, 'Next defender (4)', 'Moves close while still covering, calls ''mine'' and takes over'),
    (3, 'Other two', 'Stay short, never flat with the presser (3 in, 1 out)')
) AS v(so, role, job);

-- 7. pp.10-10
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.2 Passing the marking duties from one defender to the next', 'Squeeze up while carrier faces away',
    'When the ball moves away from goal and the carrier cannot see forward, the whole line advances the same distance, either leaving forwards offside or carrying the marking up with them.',
    'Ball carried or played away from our goal, carrier back to goal',
    'Gain ground safely while still seeing ball and opponents in case the carrier turns suddenly.',
    NULL, 10, 10, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Step up together the same distance as the ball'),
    (2, 'Markers of front men', 'Keep marking if forwards track back, else leave them offside')
) AS v(so, role, job);

-- 8. pp.11-11
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.3 Neutralizing deep penetrating runs', 'Defending the cut behind the line',
    'A forward cuts diagonally behind the full back into the channel in front of the centre back; the defender who can see the run takes it and stays half a step ahead of him.',
    'Forward starts a diagonal cut behind a defender',
    'Deny the run; release him to offside once he passes the last man, called by that last defender.',
    NULL, 11, 11, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (4)', 'Picks up the cutting forward, slightly goal-side and ahead'),
    (2, 'Full back (2)', 'Keeps closing the dribbler inside'),
    (3, 'Last defender (6)', 'Calls the offside step when the runner goes beyond'),
    (4, 'Defenders vs inward dribble', 'Exchange marking if time, otherwise cross over (intersection)')
) AS v(so, role, job);

-- 9. pp.12-12
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.4 Neutralizing triangular passing', 'Mobile shield against the one-two',
    'A dribbler attacks a defender and plays a wall pass to a forward to go behind; the defender turns and retreats on the return-ball line instead of stopping.',
    'Dribbler plays into a forward and runs past the defender',
    'Intercept or block the return ball; centrally, neighbours drop into a chain and the deeper defender decides whether to delay the wall player.',
    NULL, 12, 12, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender attacked (2)', 'Turns outside and runs back cutting the return pass'),
    (2, 'Defender near wall player (4)', 'Steps in only if he can win it, otherwise drops'),
    (3, 'Other defenders (6, 3)', 'Retreat with the play, form a chain')
) AS v(so, role, job);

-- 10. pp.13-13
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.5 Neutralizing overlapping', 'Delay the overlap 2v1',
    'A player passes and overlaps behind the receiver to create a wide 2v1; the full back backs off, keeps both in view and waits for the centre back to slide over.',
    'Overlapping run starting behind the carrier',
    'Restore 2v2 before engaging; tackle only when the carrier over-touches or the runner is offside.',
    NULL, 13, 13, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (2)', 'Retreat, don''t let the carrier get close, delay'),
    (2, 'Centre back (4)', 'Slides across, then calls who takes whom')
) AS v(so, role, job);

-- 11. pp.14-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.6 Neutralizing shots and headers', 'Line reaction to a long ball',
    'Ball moving across the opponent''s midfield is harmless; when it is struck deep the line drops with a sideways cross-step, ready to turn, then the nearest defender attacks it while others secure their men.',
    'Carrier goes vertical, plays short through or long',
    'Avoid being surprised behind without dropping so early that the team stretches and gives short passes in front.',
    NULL, 14, 14, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Cross-step drop on the strike, pivot on back foot'),
    (2, 'Engaged defender', 'Moves to the ball'),
    (3, 'Other defenders', 'Secure marks on the forwards')
) AS v(so, role, job);

-- 12. pp.14-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.6 Neutralizing shots and headers', 'Defending the flick-on behind',
    'Opponents beat a press with a high ball onto a forward who flicks or lays it into a runner cutting behind.',
    'High ball played into a target forward',
    'One defender contests the target while the rest tighten toward the ball so the knock-on finds cover.',
    NULL, 14, 15, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender on the target man (6)', 'Challenges the aerial ball'),
    (2, 'Other defenders (2, 4, 3)', 'Squeeze tightly toward the ball to cover the flick')
) AS v(so, role, job);

-- 13. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.7 Neutralizing penetrating passes', 'Stop the forward turning on feet',
    'A forward drops off and receives to feet with his back to goal; the marker approaches while the ball travels, stops beside him with an arm out to feel him.',
    'Pass to a forward''s feet in front of the line',
    'Keep a distance that stops him leaning in to turn or spinning 1v1; tackle when he is halfway through a turn; the other three stay tight behind.',
    NULL, 16, 16, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marker (4)', 'Close during the pass, stand off one side, block the turn'),
    (2, 'Other three defenders', 'Compact behind him for cover and exchanges')
) AS v(so, role, job);

-- 14. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.8 Conduct for back passes', 'Step up on the long back pass',
    'On a short back pass the line holds; on a long one it moves up quickly while the ball travels and stops just before the receiver controls it, then reads him.',
    'Opponent plays a long pass backwards',
    'Gain ground and squeeze the field; forwards must come out or be offside, while defenders keep eyes on their zone men.',
    NULL, 17, 17, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Advance during the ball''s flight, stop sideways-on before the touch'),
    (2, 'Each defender', 'Keep marking any forward who retreats with the line')
) AS v(so, role, job);

-- 15. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.9 Position of the line', 'Step out only when compact',
    'A defender steps out to the dribbler only if team-mates are close enough to cover; if there is space behind, the line drops and compacts toward its keeper.',
    'Dribbler advances with space behind the line',
    'Defend a small space: retreat and narrow, then engage with cover, with the keeper starting high and dropping with the line.',
    NULL, 18, 18, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Retreat, narrow toward the ball''s inside'),
    (2, 'First defender', 'Steps out once compact, then hands on the marking'),
    (3, 'Goalkeeper', 'Starts high, drops with the line')
) AS v(so, role, job);

-- 16. pp.19-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.10 When the defensive line is in a situation of numerical inferiority', 'Delay while short a defender',
    'With a defender out of position, the remaining three retreat and close up, delaying until the missing man runs back diagonally inside, then engage and swap marks; if no help is coming, accept the inferiority and wait for errors.',
    'A defender is beaten or upfield when attacked',
    'Buy time near our goal and the keeper; pounce on a heavy touch or on an offside runner.',
    NULL, 19, 20, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Out-of-position defender (2)', 'Recovers on a diagonal toward the goal area'),
    (2, 'Remaining three', 'Retreat and compact, no lunging'),
    (3, 'Nearest defender', 'Feints to engage; tackles on a poor touch'),
    (4, 'Defender who sees all', 'Calls the step-up when a forward runs offside')
) AS v(so, role, job);

-- 17. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '1.11 Marking against crosses', 'Man-marking in the box on crosses',
    'Near the penalty area marking becomes man-to-man; exchanges happen only if the crosser gives time.',
    'Ball wide in the final third, cross likely',
    'No forward left free close to goal; if a defender must choose, watch the man rather than the ball.',
    NULL, 21, 21, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (3)', 'Screens the crosser without diving in'),
    (2, 'Centre backs and far full back (2, 4, 6)', 'Each marks a forward into the box'),
    (3, 'Every marker', 'Prefer seeing the attacker over the ball')
) AS v(so, role, job);

-- 18. pp.22-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'to_attack', '1.12 A few training exercises / 2.5 Analysis of the team behaviors', 'Regain and restart into midfield',
    'After winning the ball the back line immediately moves it forward: back to midfielders who are free, or carrying/short passing up when midfielders are marked.',
    'Back line wins possession',
    'Defence never ends at the regain; a team set to restart at once counters before the opponent reorganises.',
    NULL, 22, 40, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'Pass to a free midfielder or dribble into midfield'),
    (2, 'Midfielders', 'Show for the ball; when marked, defenders step up to support them'),
    (3, 'Back line', 'Play short from the back or carry forward')
) AS v(so, role, job);

-- 19. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4:4:2 according to... Walter Novellino', 'Wide midfielders become forwards (4-2-4)',
    'Novellino''s 4-4-2 (his ideal is 4-4-1-1): in attack the two wide midfielders push up so the side attacks almost 4-2-4; the outside men are the real attackers.',
    'Possession won or settled',
    'Get the outer midfielders, or a makeshift striker between the lines, running in depth rather than width.',
    NULL, 24, 24, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielders', 'Complete players; break forward as attackers, deep runs'),
    (2, 'Central midfielders', 'Staggered, one quantity one quality, one free to go deep'),
    (3, 'Left back', 'The full back who pushes on more')
) AS v(so, role, job);

-- 20. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '4:4:2 according to... Walter Novellino', 'Don''t win the ball too high',
    'Novellino does not press high; he wants the regain in his own half so there is room behind the opponent to break into with fast wide players. If opponents stall, his defenders keep the ball to draw them out.',
    'Opponent in possession / opponent sits back',
    'Preserve space to counter into rather than squeezing it away.',
    NULL, 24, 24, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'Mid-low block, win it deeper'),
    (2, 'Wide midfielders', 'Ready to sprint on the regain'),
    (3, 'Defenders', 'Hold possession at the back to lure the opponent out')
) AS v(so, role, job);

-- 21. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4:4:2 according to... Walter Novellino', 'Second striker between the lines',
    'One fast forward plus a player in the final third who moves on a semicircle behind him, often settling between the opponent''s back line and midfield.',
    'Build-up reaches midfield',
    'Receive and turn where opponents struggle to hand over marking, without blocking the deep lanes of the wide midfielders.',
    NULL, 24, 24, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Second striker', 'Floats between lines, receives back passes, plays long balls'),
    (2, 'Centre forward', 'Fast and technical, attacks depth')
) AS v(so, role, job);

-- 22. pp.26-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4:3:3 according to... Marcello Lippi', 'Feed forwards to their strengths',
    'Lippi''s first Juventus 4-3-3 (Vialli, Ravanelli, Del Piero): strong but slow forwards, so the team pushed opponents back to start them near goal; with quick forwards (Boksic, Padovano, Inzaghi with Zidane) the aim was to find them early.',
    'Possession, type of forwards available',
    'Shape the attack around the attackers'' traits instead of fixed moves.',
    NULL, 26, 26, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Slow strong forwards', 'Receive close to the opponent''s box after team pushes up'),
    (2, 'Fast forwards', 'Targets for early forward passes')
) AS v(so, role, job);

-- 23. pp.26-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4:3:3 according to... Marcello Lippi', 'Always three at the back',
    'Lippi never leaves just two defenders behind; when full backs push high a midfielder drops between the centre backs as the third man (Deschamps at Juventus, Brazil 1994). Slow centre backs need more support and an offside line.',
    'Both full backs advance',
    'Secure rest defence so a counter never meets a 2v2.',
    NULL, 26, 27, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Deschamps)', 'Drops into the back line as third defender'),
    (2, 'Centre backs', 'Strong, fast, good in the air; hold an offside line if slow'),
    (3, 'Full backs', 'Free to attack')
) AS v(so, role, job);

-- 24. pp.27-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'to_defend', '4:3:3 according to... Marcello Lippi', 'Forwards track their direct opponent',
    'On losing the ball Lippi''s three forwards each mark the nearest opponent back to the halfway line (Del Piero returning to the left); Zidane as a modern ten chased the ball after losing it and otherwise fell back onto the midfield line.',
    'Possession lost',
    'Even unorganised, delay the opponent a few seconds so the team can regain shape.',
    NULL, 27, 27, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three forwards', 'Mark direct opponents until the midfield line'),
    (2, 'Left forward (Del Piero)', 'Returns to the left wing'),
    (3, 'Number ten (Zidane)', 'Counter-presses; if not, drops onto midfield line')
) AS v(so, role, job);

-- 25. pp.27-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '4:3:3 according to... Marcello Lippi', 'Halfback blocks the switch',
    'In Lippi''s 4-3-3 a midfielder (halfback) slides to cover the far side so the opponent''s change of play is cut out.',
    'Opponent tries to switch the ball',
    'Neutralise the shift without pulling the back line across.',
    NULL, 27, 27, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide central midfielder', 'Shifts to intercept or close the switch target'),
    (2, 'Forwards', 'Screen in front of the opponent''s back line')
) AS v(so, role, job);

-- 26. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '2.1 Midfield with 4 players', 'Midfield four defends like a back four',
    'A flat midfield four uses one cover line and the same pressure/cover/exchange rules, without offside; when a forward drops into the space between lines the defender follows and hands him to the midfielder by name.',
    'Ball in front of the midfield line; forward drops short',
    'Press higher when carrier faces away, cover more when he faces goal; midfielders drop facing defenders on long shots and back passes.',
    NULL, 31, 31, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield four', 'Single cover line, press or cover by carrier''s view'),
    (2, 'Centre back', 'Follows dropping forward, then calls the midfielder''s name and returns'),
    (3, 'Two central midfielders', 'Man-mark opposing midfield runners on crosses')
) AS v(so, role, job);

-- 27. pp.32-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '2.2 Midfield with 3 or 5 players', 'Midfield three and five slide',
    'A midfield three or five closes down a lateral ball with the near player out and the rest diagonal, and a central ball with the middle man out and the others in a funnel.',
    'Ball wide vs ball central in front of midfield',
    'Same pressure-and-cover geometry as the back line across a three or five.',
    NULL, 32, 33, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near midfielder', 'Steps out to the ball'),
    (2, 'Other midfielders', 'Diagonal cover / funnel behind'),
    (3, 'Wide men in a five (7, 11)', 'Tuck in on the far side')
) AS v(so, role, job);

-- 28. pp.34-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '2.3 Doubling teaming', 'Double team between lines',
    'Fixed pairs of defender plus midfielder double up on a receiver (midfield four: 2-7, 4-5, 6-10, 3-11 style pairs; midfield three: 8 with 2, etc.); wide men in a five cut the back pass.',
    'Opponent receives in a pair''s zone',
    'Two players on the ball from different lines so no single position is emptied; same-line doubling only with numbers up.',
    NULL, 34, 35, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender (2)', 'Takes the outside when carrier faces goal; in front stopping the turn when he faces away'),
    (2, 'Midfielder (8)', 'Takes the inside when carrier faces goal; behind him and tackles when he faces away'),
    (3, 'Wide midfielders in a five (7, 11)', 'Cut off the back pass')
) AS v(so, role, job);

-- 29. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '2.4 Position with 2, 1 or 3 forwards', 'Front two screen the centre backs',
    'With two forwards (4-4-2, 4-3-1-2, 4-4-1-1), one presses a centre back and the other covers; when the ball goes wide the nearer forward blocks the back pass and the other covers.',
    'Opponent centre back on the ball / ball goes wide',
    'Stop the centre backs stepping in or playing vertically through the middle and trap play on the side.',
    NULL, 36, 36, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side forward', 'Presses the centre back, or blocks back pass when ball wide'),
    (2, 'Other forward', 'Covers centrally'),
    (3, 'Second striker (in 4-4-1-1)', 'Doubles up alongside the forward')
) AS v(so, role, job);

-- 30. pp.36-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '2.4 Position with 2, 1 or 3 forwards', 'Lone striker vs back four',
    'A 4-3-3 front against four defenders: the 9 shuttles between the two centre backs without diving in while 7 and 11 shadow the full backs; when a centre back turns to the outside, the 9 presses and wingers block near the ball. Single-striker sides otherwise pass marking to midfielders or steer play to the touchline.',
    'Centre back faces the touchline',
    'Manage the numbers-down front line and press only when the sideline halves the carrier''s options.',
    NULL, 36, 37, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (9)', 'Shuttles between centre backs, presses the outward-facing one'),
    (2, 'Wingers (7, 11)', 'Block and mark the full backs near the ball'),
    (3, 'Midfielders', 'Take over marking when forwards are outnumbered')
) AS v(so, role, job);

-- 31. pp.37-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '2.4 Position with 2, 1 or 3 forwards', 'Proactive 4-3-3 press assignments',
    'Some coaches assign the jump by which of the four defenders has the ball: on a full back the near winger presses, the 9 and other winger mark and cover, two midfielders sit near the ball, the far one guards switches; on a centre back the 9 or a winger jumps similarly.',
    'Which opposing back (A/B/C/D) has the ball',
    'Refuse numerical inferiority by acting first; a midfielder can reach a full back''s forward pass before him.',
    NULL, 37, 39, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near winger (11 or 7)', 'Comes out on full back in possession'),
    (2, 'Centre forward (9)', 'Comes out on near centre back, or covers and marks'),
    (3, 'Two near midfielders', 'Stay close to the ball'),
    (4, 'Far midfielder', 'Watches for the switch')
) AS v(so, role, job);

-- 32. pp.42-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', 'The 4:3:1:2 according to Carlo Ancelotti (Juventus 1999)', 'Dynamic wing cover in 4-3-1-2',
    'With no fixed wingers, Ancelotti''s Juventus fill the flanks by turns with the full backs and the wide central midfielders, mixing wide and central play.',
    'Ball moves toward a flank',
    'Flanks occupied without static positions so the attack is less predictable.',
    NULL, 42, 42, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'Push on to hold the touchline when free'),
    (2, 'Wide central midfielders', 'Slide out to the flank in turn with the full back'),
    (3, 'Front two', 'Stay central for the end product')
) AS v(so, role, job);

-- 33. pp.42-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', 'The 4:3:1:2 according to Carlo Ancelotti (Juventus 1999)', 'Free back steps onto midfield runner',
    'In the 4-3-1-2, a defender with no forward to mark steps out onto an opposing midfielder; if that midfielder arrives from deep a home midfielder tracks him, if he stays high the back picks him up.',
    'Back has no direct opponent and a midfielder breaks forward',
    'No free opposing midfielder arriving between the lines.',
    NULL, 42, 42, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Spare centre back', 'Step out onto the advancing midfielder if nobody to mark, else hold the line'),
    (2, 'Central midfielders', 'Track a midfielder who starts deep'),
    (3, 'Back line', 'Stay compact behind the stepping defender')
) AS v(so, role, job);

-- 34. pp.42-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', 'The 4:3:1:2 according to Carlo Ancelotti (Juventus 1999)', 'Trequartista''s defensive job by opponent back line',
    'The attacking midfielder is not asked for long recovery runs but must defend: versus a back three he marks the middle centre back while the two forwards take the outer ones; versus a back four he closes the ball-side opposing midfielder when they pass sideways.',
    'Opponent circulates in their back line; lateral pass',
    'First pass out blocked without dropping the No.10 deep.',
    NULL, 42, 43, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Trequartista', 'Vs back three mark the central centre back; vs back four close the near midfielder on a lateral pass'),
    (2, 'Front two', 'Vs back three take the two outside centre backs'),
    (3, 'Midfield three', 'Hold shape behind the front press')
) AS v(so, role, job);

-- 35. pp.43-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', 'The 4:3:1:2 according to Carlo Ancelotti (Juventus 1999)', 'Width rules and two directors (4-3-1-2)',
    'Width comes from full backs and wide central midfielders; if neither can hold it, one forward goes wide and the trequartista steps up beside the other forward. In our half the holding midfielder runs the play, in their half the trequartista does.',
    'Ball in own half vs opponent half; no one holding width',
    'Keep width and a clear playmaker at every stage of the attack.',
    NULL, 43, 44, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'First choice to hold the width; need attacking quality'),
    (2, 'Forward (one of two)', 'Go wide when nobody else holds it'),
    (3, 'Trequartista', 'Join the remaining forward; lead play in the opponent half, play between the lines'),
    (4, 'Holding midfielder', 'Director in own half, helps build from the back, rarely bombs on')
) AS v(so, role, job);

-- 36. pp.44-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', 'The 4:3:1:2 according to Carlo Ancelotti (Juventus 1999)', 'Handling an opposing trequartista',
    'Against a side with a No.10 behind two strikers: with a back four, one defender is dedicated mainly to defensive work on him; with a back three the central defender can take him in a 1v1.',
    'Opponent''s attacking midfielder drops between our lines',
    'The opposing No.10 always has a designated defender.',
    '4-3-1-2', 44, 44, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four: one centre back', 'Focus mainly on the trequartista zone'),
    (2, 'Back three: central defender', 'Accept a 1v1 against the No.10')
) AS v(so, role, job);

-- 37. pp.45-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', 'The 4:2:3:1 according to Mauro Sandreani', '4-2-3-1: delay, don''t press high',
    'With four attackers high, often only six players defend, so the side slows the opponent down instead of pressing high, buying time for forwards to recover; the two holding midfielders brake the play and screen the back four.',
    'Possession lost with attackers upfield',
    'Gain time and protect the back four until the shape is rebuilt.',
    NULL, 45, 46, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two holding midfielders', 'Slow the ball carrier, shield the back four'),
    (2, 'Back four', 'Hold a safe, compact line'),
    (3, 'Front four', 'Get back toward position while play is delayed')
) AS v(so, role, job);

-- 38. pp.45-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', 'The 4:2:3:1 according to Mauro Sandreani', '4-2-3-1 attack: four attackers plus limited full backs',
    'The four forwards attack with wingers cutting inside as in a 4-3-3, 1v1 on the flank and third-man play; full backs only push up to the halfway line, using space opened by the wingers'' diagonal runs. Style follows players: vertical deep runs (Valencia) or horizontal possession for 1v1 wingers (Real Madrid).',
    'Possession in midfield with four attackers high',
    'Mix numerical superiority with individual 1v1 quality.',
    NULL, 45, 46, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (9)', 'Strong target who moves to open space for runners from behind'),
    (2, 'Wingers (7, 11)', 'Diagonal runs inside, beat men 1v1'),
    (3, 'No.10', 'Link and insert behind the striker'),
    (4, 'Full backs', 'Support only up to halfway into space the wingers vacate'),
    (5, 'Two holding midfielders', 'One may be a passer (Redondo type), protect the defence')
) AS v(so, role, job);

-- 39. pp.46-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', 'The 4:2:3:1 according to Mauro Sandreani', 'Front four on a lateral pass',
    'Sandreani''s attacking four join defending: on a sideways pass the No.10 attacks the nearest supporting back, the striker shuffles between the two or three centre backs, the wingers drop back onto the opponent''s wide players.',
    'Opponent plays a lateral pass in their back line',
    'Disrupt build-up with the four attackers while a solid back block holds behind.',
    NULL, 46, 46, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'Press the first supporting back on the lateral pass'),
    (2, 'Centre forward (9)', 'Move between the centre backs to cut passes'),
    (3, 'Wingers (7, 11)', 'Recover onto the opponent''s wide players')
) AS v(so, role, job);

-- 40. pp.46-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'to_defend', 'The 4:2:3:1 according to Mauro Sandreani', 'Recover to the nearest zone after loss',
    'When possession is lost and the attackers are mixed up, each player recovers to the nearest free zone to rebuild the shape quickly, not necessarily his starting post.',
    'Possession lost with positions swapped',
    'Shape restored fast rather than everyone running back to his own spot.',
    NULL, 46, 46, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Each attacker', 'Drop into the closest open zone'),
    (2, 'Holding midfielders', 'Screen while the rest recover')
) AS v(so, role, job);

-- 41. pp.46-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', 'The 4:2:3:1 according to Mauro Sandreani', 'Striker sets for winger''s diagonal',
    'A wide player serves the striker; the striker, backed by the No.10, plays on for the far winger''s diagonal run in behind.',
    'Pass into the striker''s feet',
    'Release the far winger running diagonally behind the defence.',
    NULL, 46, 47, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player (11)', 'Serve the centre forward'),
    (2, 'Centre forward (9)', 'Lay off or play on with 10''s support'),
    (3, 'No.10', 'Offer close support to the striker'),
    (4, 'Far winger (7)', 'Run diagonally in behind to receive')
) AS v(so, role, job);

-- 42. pp.46-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', 'The 4:2:3:1 according to Mauro Sandreani', 'Striker drops, No.10 runs beyond',
    'The striker comes deep to open space for the No.10 to break through from behind; or the No.10 cuts in behind the opposing full back while the striker takes the ball short.',
    'Centre back follows striker, or full back distracted',
    'Get the No.10 into the box through the space the striker vacates.',
    NULL, 46, 47, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (9)', 'Drop deep / receive short and pull a defender out'),
    (2, 'No.10', 'Insert from behind or cut behind the full back'),
    (3, 'Winger (7)', 'Supply the pass')
) AS v(so, role, job);

-- 43. pp.49-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3.1 In-depth disposition, upward movement, width, mobility, unpredictability', 'Five attacking principles: depth, forward, width, mobility, unpredictability',
    'Free players form triangles with the ball carrier and never get free in line with him; two from the same zone use opposite depths (short/long, in/out). Prefer the most advanced team-mate, use the whole width incl. the far side, move several players at once (feint, diagonal, change of direction, overlap for 2v1), and let talent choose among options.',
    'Team in possession',
    'Keep the ball and progress with many options instead of predictable single runs.',
    NULL, 49, 49, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Choose the most forward safe option'),
    (2, 'Two nearest team-mates', 'Form a triangle, one short and one long'),
    (3, 'Far-side players', 'Hold width when progress centrally is blocked'),
    (4, 'Runner', 'Overlap or diagonal run to create 2v1')
) AS v(so, role, job);

-- 44. pp.50-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3.2 Layout from behind with a defense with 4, 3 or 5 players', 'Back four build-up through the full back',
    'A centre back who can see forward has the ball; the full back moves to receive in space while the other centre back and holder cover. If the full back is closed, he returns it to the centre back who switches to the far full back, with the second centre back offering backup.',
    'Centre back in possession; full back closed down',
    'Progress through the flanks with cover kept behind.',
    NULL, 50, 50, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back on the ball (4)', 'Find the full back or switch'),
    (2, 'Full back (2)', 'Move into space to receive; play back if closed'),
    (3, 'Other centre back (6)', 'Cover and offer the backwards option'),
    (4, 'Far full back (3)', 'Receive the switch')
) AS v(so, role, job);

-- 45. pp.50-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3.2 Layout from behind with a defense with 4, 3 or 5 players', 'If you are closed down, bypass',
    'When the back line cannot pass between themselves and no midfielder can support, the defenders go long to the forwards, but as an organised play with team-mates ready for the second ball.',
    'All short options pressed out',
    'Escape the press with a planned long ball, not a random clearance.',
    NULL, 50, 51, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender on the ball', 'Play long into the forwards'),
    (2, 'Forwards', 'Contest the long ball'),
    (3, 'Midfield', 'Push up for knockdowns')
) AS v(so, role, job);

-- 46. pp.51-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3.2 Layout from behind with a defense with 4, 3 or 5 players', 'Centre back steps into midfield',
    'A centre back carries forward into midfield; the other centre back advances to receive or to clear space for a midfielder dropping short, then the first covers. After a goalkeeper pass to the full back, a centre back can push up while his partner covers.',
    'Free space ahead of the centre back',
    'Add a man in midfield from the back line.',
    NULL, 51, 51, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (4)', 'Step up with the ball or after a GK-to-full-back pass'),
    (2, 'Other centre back (6)', 'Advance to receive or cover behind'),
    (3, 'Midfielder', 'Come short into the space freed')
) AS v(so, role, job);

-- 47. pp.51-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3.2 Layout from behind with a defense with 4, 3 or 5 players', 'Back three / five build-up',
    'With three at the back the two outside defenders split wide while the central one covers, also when he takes the goal kick himself. With five, the wing-backs go wide and the two outer centre backs plus the middle one cover from behind.',
    'Goalkeeper restart or back-line possession',
    'Wide outlets with three cover players behind if the ball is lost.',
    NULL, 51, 53, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside defenders / wing-backs', 'Split wide to receive'),
    (2, 'Central defender (5)', 'Cover, or start play after the GK pass'),
    (3, 'Outer centre backs (back five)', 'Cover and support from behind')
) AS v(so, role, job);

-- 48. pp.54-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3.3 Midfield with 4, 3 or 5 players', 'Midfield four: support behind, third man ahead, swaps',
    'Ball on the right: the near central midfielder supports from behind in an open body position; the other one steps slightly ahead as the third man to attack space the attacker makes. If he is marked he swaps with the far wide midfielder; if the near one is pressed the other comes to help or the near one pushes on to free space. With the ball central the two central midfielders swap to get free.',
    'Ball on a flank, or centrally with central midfielders marked',
    'Always a supporting and a penetrating option near the ball.',
    NULL, 54, 55, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near central midfielder (5)', 'Support behind the carrier, seeing the field'),
    (2, 'Far central midfielder (10)', 'Step ahead as third man; swap with wide mid 8 when marked'),
    (3, 'Far wide midfielder (8)', 'Exchange positions inward'),
    (4, 'Ball-side wide midfielder', 'Carry/attack, draw defender')
) AS v(so, role, job);

-- 49. pp.55-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3.3 Midfield with 4, 3 or 5 players', 'Midfield three: ''method'' centre-half and space-making',
    'The deep central player (''centre-half of the method'') switches play and supports. He receives in space made by a mezzala moving away; the other mezzala then widens. If he must drop to get free he uses space from the mezzala moving inside; if he is pressed, a centre back steps into midfield in space opened by a mezzala cutting in. With five in midfield the same applies, plus wingers or a trequartista.',
    'Deep midfielder closely marked or pressed',
    'Keep a free organiser and a free route forward through midfield.',
    NULL, 55, 57, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep central midfielder (5)', 'Organise, switch, support possession'),
    (2, 'Mezzala (10)', 'Move away to open space for 5'),
    (3, 'Mezzala (8)', 'Widen, or cut inside to open space'),
    (4, 'Centre back (2)', 'Step into midfield when 5 is pressed')
) AS v(so, role, job);

-- 50. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3.4 Attack with 2 or 3 forwards', 'Two forwards: opposite movements',
    'The forward nearest the ball moves first, the other answers: one comes, one goes; one in, one out. Example: one striker runs long, the other drops to support and lays off so a midfielder can release a wide runner, who crosses to the far post for both forwards and an arriving midfielder.',
    'Midfielder in possession facing the forwards',
    'Ball carrier always has two different options.',
    NULL, 58, 58, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near forward', 'Move first (short or long)'),
    (2, 'Other forward', 'Do the opposite, close the triangle'),
    (3, 'Wide midfielder (8)', 'Run deep and cross'),
    (4, 'Central midfielder (5)', 'Arrive at the edge of the area')
) AS v(so, role, job);

-- 51. pp.58-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3.4 Attack with 2 or 3 forwards', 'Three forwards: rotation started by the near player',
    'Whether two forwards plus a trequartista or two wingers plus a striker, the man closest to the ball moves first and starts the rotation of the other two. E.g. a forward comes short and the trequartista feeds the striker in depth; or the striker sets to a winger who serves the far winger''s diagonal or the full back overlapping into the space it leaves.',
    'Midfielder on the ball',
    'Coordinated runs that free a man in behind or on the far side.',
    NULL, 58, 59, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest forward', 'Start the move by coming short'),
    (2, 'Trequartista / striker', 'Serve or receive in depth'),
    (3, 'Winger (7)', 'Receive the set, serve the diagonal or overlap'),
    (4, 'Far winger (11)', 'Diagonal run inside'),
    (5, 'Full back (3)', 'Run into the space the winger vacates')
) AS v(so, role, job);

-- 52. pp.59-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3.4 Attack with 2 or 3 forwards', 'Vertex midfielder joins the front three',
    'With a three-man midfield whose top man supports three forwards: a penetrating pass to the striker, supported by the No.10 while two midfielders stay behind; the left winger cuts in and the full back fills the open flank. Variants: a 9-7 exchange frees the No.10 to break centrally, or both central midfielders support the striker for a winger''s diagonal.',
    'Penetrating pass to the centre forward',
    'Four attackers in the final third with cover kept behind.',
    NULL, 59, 60, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (9)', 'Receive the vertical pass, combine'),
    (2, 'Vertex midfielder (10)', 'Support 9, break centrally after exchanges'),
    (3, 'Left winger (11)', 'Cut inside'),
    (4, 'Left back (3)', 'Run into the space left by 11'),
    (5, 'Deep midfielders (8, 5)', 'Stay behind as cover')
) AS v(so, role, job);

-- 53. pp.60-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3.4 Attack with 2 or 3 forwards', '4-3-3 route: target striker and cutting wings',
    'In a 4-3-3 the centre forward, back to goal, acts as a wall, then serves the wingers'' diagonal runs or sets for team-mates to find runners into the space the wings create. Midfield three must sacrifice defensively since wingers do not always help.',
    'Ball played into the centre forward',
    'Wingers cutting in and the follow-up runs become the main threat.',
    NULL, 60, 61, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Wall pass, serve diagonals'),
    (2, 'Wingers', 'Cut inside on diagonals'),
    (3, 'Midfield three', 'Cover large spaces, insert into vacated lanes')
) AS v(so, role, job);

-- 54. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3.4 Attack with 2 or 3 forwards', 'Two-forwards-plus-trequartista route: ground and lateral',
    'In 4-3-1-2 or 3-4-1-2 the ball moves on the ground with lateral movement; the trequartista roams across the front line to find where he hurts the opponent most. In 4-4-2 the wide midfielders keep the ball moving or support a central insertion instead of overlapping. Back-three teams build from the back or go long.',
    'Possession in midfield',
    'Unpredictable final-third entries through movement and the No.10''s freedom.',
    NULL, 61, 61, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Trequartista', 'Drift along the front line to the weak spot'),
    (2, 'Two forwards', 'Lateral movements to open lanes'),
    (3, 'Midfielders', 'Ground passing, central insertion')
) AS v(so, role, job);

-- 55. pp.62-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', 'The 4:2:1:3 according to Maurizio Viscidi', 'Count men behind the ball; accept 2v2 centrally',
    'Viscidi judges defence by how many are behind the ball (wingers chasing back turn a 4-3-3 into a 4-5-1). A back four covers the whole front line: if both forwards are ball-side the central 2v2 is accepted with two cover lines; if one forward stays wide he is left to the full back and the 2v2 is accepted in a narrow space.',
    'Opponent forwards positioned ball-side or one wide',
    'Back four handles two strikers without dropping a man.',
    NULL, 62, 62, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Accept the 2v2 with staggered cover lines'),
    (2, 'Ball-side full back', 'Take the forward who stays wide'),
    (3, 'Far full back', 'Tuck in as a second cover line')
) AS v(so, role, job);

-- 56. pp.63-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', 'The 4:2:1:3 according to Maurizio Viscidi', 'Beat the press in 4-2-1-3 build-up',
    'A full back is pressed while another opponent screens the pass to the striker: keep the ball moving to a central midfielder and on to the other; if that one is closed the two holders swap positions to get free, or play to the striker moving to the side. Wingers act as wingers in attack and as extra midfielders when defending.',
    'Opponent presses the full back and screens the striker',
    'Keep possession and find a free man through quick circulation.',
    NULL, 63, 63, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (2)', 'Play inside when pressed'),
    (2, 'Holding midfielders (5, 8)', 'Circulate; swap positions to shake the marker'),
    (3, 'Striker (9)', 'Move to the side to offer a line'),
    (4, 'Wingers (7, 11)', 'Width in attack, drop into midfield when defending')
) AS v(so, role, job);

-- 57. pp.64-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', 'The 4:2:1:3 according to Maurizio Viscidi', 'Winger moves inside after ball to striker',
    'When the ball reaches the striker the near winger comes inside, as his defender tends to follow the striker. If a midfielder has it and the winger gets in behind, he crosses between back line and goal line for three runners; if he receives cutting in, the striker cuts in, the No.10 goes straight and the far winger moves inside. Wingers play on the opposite flank to their foot. Full backs only push on when wingers cut in, or to overlap after a winger turns.',
    'Pass into the striker; defender drawn out',
    'Create a 1v1 or a cut-back from inside or behind the full back.',
    NULL, 64, 64, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near winger (7)', 'Move inside into the gap behind the defender'),
    (2, 'Striker (9)', 'Cut in or attack the box'),
    (3, 'No.10', 'Run straight through'),
    (4, 'Far winger (11)', 'Come inside for the cross'),
    (5, 'Full backs', 'Overlap only when wingers cut in')
) AS v(so, role, job);

-- 58. pp.64-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', 'The 4:2:1:3 according to Maurizio Viscidi', 'Midfielder feeds striker to feet; combinations',
    'A holder plays a firm straight ball to the striker''s feet. The striker turns to shoot, or lays to the No.10 coming in who serves the wingers; if he cannot see the No.10, a midfielder or winger backs him and the No.10 follows the play; the No.10 can receive while the striker runs in front of or behind his marker; receiving in depth he shoots/crosses, or shields and serves a winger.',
    'Straight pass into the centre forward',
    'Turn a pass into the striker into a shot, a release to a winger or a run behind.',
    NULL, 64, 66, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder', 'Play to the striker''s feet'),
    (2, 'Centre forward (9)', 'Turn, lay off, or run behind after a lay-off'),
    (3, 'No.10', 'Arrive in support and serve wingers'),
    (4, 'Wingers (7, 11)', 'Receive after the lay-off')
) AS v(so, role, job);

-- 59. pp.66-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', 'The 4:2:1:3 according to Maurizio Viscidi', 'Holders circulate, winger chooses wide or inside',
    'After the two holders exchange passes, the winger receives wide if his defender closes him down, or inside if the defender stays wide; the full back then runs into the space created.',
    'Midfield circulation between the two holders',
    'Use the defender''s position to free the winger, then add the full back.',
    NULL, 66, 67, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielders (5, 8)', 'Exchange to shift the opponent'),
    (2, 'Winger (11)', 'Receive opposite to where the defender stands'),
    (3, 'Full back (3)', 'Run into the vacated space')
) AS v(so, role, job);

-- 60. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', 'The 4:2:1:3 according to Maurizio Viscidi', 'Six defenders are not enough',
    'Defending with only four backs and two holders fails: with the opposing wide midfielders in possession the full backs must hold position and leave wide men free; if the full backs mark them tighter, a dangerous 1v1 opens between centre back and striker with no cover. Seven or eight behind the ball are needed.',
    'Only six players behind the ball',
    'Recognise the gap and get seven or eight men back.',
    NULL, 67, 67, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'Hold position or risk leaving the centre back uncovered'),
    (2, 'Centre backs', 'Need cover when a full back steps out'),
    (3, 'Two holders', 'Can only stop penetrating balls to forwards'),
    (4, 'Wingers', 'Must recover to make seven or eight')
) AS v(so, role, job);

-- 61. pp.69-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', 'Formations according to Arrigo Sacchi (Milan)', 'Sacchi: overload the ball zone with five attackers',
    'Sacchi''s Milan attacked with at least five players manoeuvring together instead of playing long, aiming for numerical superiority in the ball area, with one ''filter'' player between attackers and defenders.',
    'Team in possession',
    'Outnumber the opponent around the ball and keep the side short.',
    NULL, 69, 69, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Five attackers', 'Combine together near the ball'),
    (2, 'Filter midfielder', 'Sit between attack and defence, link and screen'),
    (3, 'Back line', 'Stay close to keep the team short')
) AS v(so, role, job);

-- 62. pp.69-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', 'Formations according to Arrigo Sacchi (Milan)', 'Sacchi: short team and offside trap',
    'The whole side stays very short so everyone can attack and defend; as defenders were often outnumbered after committing men forward, Milan used the offside trap a lot, with otherwise classic 1v1 defending.',
    'Opponent attacks after Milan committed numbers',
    'Compact block; push up to catch forwards offside.',
    NULL, 69, 69, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Step up together to spring the trap; else defend 1v1'),
    (2, 'Midfield', 'Keep short distance to the back line'),
    (3, 'Forwards', 'Stay close to the midfield')
) AS v(so, role, job);

-- 63. pp.72-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.1 4:4:2 Back player in overlapping situation', 'Full back overlap with triangle and cross',
    'The back line circulates with feints; the left back plays to the wide midfielder who has gone wider and overlaps; the wide midfielder plays to the forward or central midfielder closing the triangle so the full back can cross for the two forwards, the far wide midfielder and a midfielder at the edge of the box. If the wide mid is tightly marked, the central midfielder supports and serves the full back in depth.',
    'Wide midfielder receives with the full back behind him',
    'Free the overlapping full back to cross with four arriving.',
    NULL, 72, 72, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (3)', 'Pass and overlap, cross'),
    (2, 'Left midfielder (8)', 'Go wide, receive, combine'),
    (3, 'Forward (11) / central mid (10)', 'Close the triangle, release the full back'),
    (4, 'Striker (9) and far wide mid (7)', 'Attack the cross'),
    (5, 'Central midfielder (5)', 'Arrive at the edge of the box')
) AS v(so, role, job);

-- 64. pp.73-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.2 Midfield player inside and back outside', 'Wide midfielder inside, full back outside',
    'With the ball on the centre back, wide midfielder and full back both hold the line; when the centre back can play forward the wide midfielder cuts in and the full back runs into the freed flank. If the wide mid receives: triangle with near forward, shot, release a central midfielder into the space, or play deep as the forwards cross over. If the full back receives: triangle with the wide mid to cross, or criss-cross.',
    'Centre back faces play with time',
    'Combine inside and outside runs on one flank.',
    NULL, 73, 73, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (8)', 'Cut inside when the centre back looks up'),
    (2, 'Full back (3)', 'Attack the space outside'),
    (3, 'Centre back (6)', 'Choose the free man'),
    (4, 'Forwards', 'Triangle and criss-cross runs')
) AS v(so, role, job);

-- 65. pp.74-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.3 When the central midfield player is shooting', 'Forward drops, central midfielder plays in',
    'Right back in possession: the wide midfielder runs deep, the nearest forward drops to receive and lays to the central midfielder; the other forward cuts in and the second central midfielder runs into the free space; the midfielder finds either or shoots.',
    'Full back on the ball, forward available to drop',
    'Set up a shot or through-ball for a central midfielder arriving.',
    NULL, 74, 74, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (2)', 'Play to the dropping forward'),
    (2, 'Wide midfielder (7)', 'Run deep to stretch the line'),
    (3, 'Near forward', 'Drop, lay off to 5'),
    (4, 'Central midfielder (5)', 'Shoot or pass to 9/10'),
    (5, 'Other forward (9) and central mid (10)', 'Cut in / run into free space')
) AS v(so, role, job);

-- 66. pp.75-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.4 Deep movement of the forward', 'Forward comes close to a marked wide midfielder',
    'A central midfielder feeds the wide midfielder who has an opponent right in front; the near forward comes close to form a triangle while the other forward prepares to cut in behind.',
    'Wide midfielder receives facing a defender',
    'Beat the marker with a combination and a run behind.',
    NULL, 75, 75, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (10)', 'Serve the wide midfielder'),
    (2, 'Wide midfielder (8)', 'Combine with the near forward'),
    (3, 'Near forward', 'Come short to make a triangle'),
    (4, 'Far forward', 'Cut in behind')
) AS v(so, role, job);

-- 67. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.5 Exchange of position between a central midfield player and an outer midfield player', 'Central and wide midfielder swap',
    'The right midfielder plays back to a central midfielder; the other central midfielder pushes up but, to lose his marker, swaps position with the left midfielder.',
    'Central midfielder marked as he advances',
    'Free a midfielder via a central-wide exchange.',
    NULL, 76, 76, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfielder (7)', 'Play back to 5'),
    (2, 'Central midfielder (5)', 'Receive, find the freed man'),
    (3, 'Central midfielder (10)', 'Move forward then swap to the flank'),
    (4, 'Left midfielder (8)', 'Swap inside')
) AS v(so, role, job);

-- 68. pp.77-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.6 Exchange of position between the forward and the outer midfield player', 'Forward and wide midfielder swap',
    'Left back on the ball, wide midfielder and near forward both marked: they swap positions so the full back can serve the wide midfielder cutting in or the forward running out wide.',
    'Both forward and wide midfielder marked',
    'Lose markers via a crossing exchange.',
    NULL, 77, 77, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (3)', 'Serve whichever man gets free'),
    (2, 'Left midfielder (8)', 'Cut inside'),
    (3, 'Near forward (11)', 'Run out wide')
) AS v(so, role, job);

-- 69. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.7 Movement of the outer pairs', 'Full back and wide midfielder pair movements',
    'When a centre back who can play long has the ball, the flank pair moves in opposition: one goes in depth while the other comes forward, one out while the other in; e.g. the full back runs deep and wide while the wide midfielder cuts in, or the full back cuts inside toward goal while the wide midfielder holds and widens.',
    'Centre back on the ball able to play long',
    'Give the centre back two contrasting targets on the flank.',
    NULL, 78, 78, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Run deep/wide or cut inside'),
    (2, 'Wide midfielder', 'Do the opposite: come in or hold wide'),
    (3, 'Centre back', 'Play long into the free man')
) AS v(so, role, job);

-- 70. pp.79-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.8 4:3:3 When the backs come out from behind', '4-3-3: full back runs beyond after centre back receives',
    'The centre back, after a feint, takes the goal kick pass and turns; as he can play, the full back runs deep and the near midfielder comes closer. The centre back serves the full back, or the midfielder turns and serves him while the winger comes inside to create more room.',
    'Centre back receives from the goalkeeper and turns',
    'Get the full back running in behind on the flank.',
    NULL, 79, 79, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (4)', 'Receive, turn, play forward'),
    (2, 'Full back (2)', 'Run in depth'),
    (3, 'Midfielder (8)', 'Come short, turn and feed 2'),
    (4, 'Winger (7)', 'Move inside to clear the flank')
) AS v(so, role, job);

-- 71. pp.80-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.9 When the backs come out from behind, but with switching of play', '4-3-3: switch via centre back carrying inside',
    'The full back tries to dribble out but is closed and returns it to the centre back; if possible the centre back turns and dribbles inside, switching to the far full back running deep as a midfielder approaches. If challenged, he has support from the other centre back behind.',
    'Full back closed down on the ball side',
    'Escape pressure by switching to the open far side.',
    NULL, 80, 80, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (2)', 'Attempt to dribble; play back when closed'),
    (2, 'Centre back (4)', 'Carry inside and switch'),
    (3, 'Far full back (3)', 'Run deep on the far side'),
    (4, 'Midfielder (10)', 'Approach to offer support'),
    (5, 'Other centre back (6)', 'Back up behind 4')
) AS v(so, role, job);

-- 72. pp.81-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.10 When the central halfback comes out (4-3-3)', 'Holding mid drops, turns, finds the 10',
    'The holding midfielder (5) shows short to the centre back after a feint, turns and plays the 10 who is cutting in behind the opposing midfield line; the left back covers the space and the left winger tucks inside to open room.',
    '5 receives from the centre back with time to turn',
    'Break the first midfield line with a pass into the 10 between the lines.',
    NULL, 81, 81, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (5)', 'feint, drop to receive, turn and serve 10'),
    (2, 'Attacking midfielder (10)', 'cut inside behind opposing midfielders; if 5 cannot turn, come short to support then play 3 or the cutting 11'),
    (3, 'Left back (3)', 'cover the space vacated and become an outlet'),
    (4, 'Left winger (11)', 'move inside to create space and cut in')
) AS v(so, role, job);

-- 73. pp.81-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.11 Bypass pressure with a penetrating pass to the central forward', 'Escape the press: ball into checking 9',
    'When the team is closed down near the ball, the back plays long into the 9, who has freed himself by faking a run in behind and then checking. What happens next depends on the wingers and midfield distances.',
    'Ball side closed down, long pass the only option',
    'Get out of pressure and attack the space the press leaves.',
    NULL, 81, 82, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (9)', 'fake deep run, check to receive; flick on if wingers have run beyond, else hold up'),
    (2, 'Wingers (7, 11)', 'if they ran beyond 9, receive the extended ball; if not, one faces 9 in support, the other cuts in'),
    (3, 'Midfielders (8, 10)', 'if close, take the lay-off and serve the cutting wingers; if far, move into freed space with 3'),
    (4, 'Centre back (4)', 'play the long pass into 9')
) AS v(so, role, job);

-- 74. pp.83-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.12 Bypass pressure with a deep pass to the central forward', 'One winger supports, one goes deep',
    'The 9 receives after running in behind; because the team cannot be close to him, the ball-side winger gives immediate support while the far winger attacks depth. In 4-3-3 build-up the wingers give the width and midfielders join only once a forward has the ball.',
    'Deep ball played to a running 9',
    'Keep the ball to let the team move up, or strike deep at once if the defence is badly set.',
    NULL, 83, 83, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (9)', 'run in behind and receive the deep ball'),
    (2, 'Ball-side winger (7)', 'come to support 9 immediately'),
    (3, 'Far winger (11)', 'run in depth behind the defence'),
    (4, 'Midfielders', 'after the forward receives, either support or insert into free space')
) AS v(so, role, job);

-- 75. pp.83-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.13 Penetration of the wing and other developments', 'Winger beats full back with 9 triangle',
    'Winger runs at the full back from behind; the back drops off and the winger takes the ball to feet, then plays a wall pass with the 9 to get past and either crosses for 9 and 11 or serves 11 cutting in, the inserting 10, or shoots. Used when the defender slides behind to stop the pass to the winger. Aim in the final third is a 2v1 wide or 2v2 up front, otherwise switch the play.',
    'Winger receives to feet with space; full back retreating',
    'Get behind the full back; 9 and his marker also screen the back trying to step up.',
    NULL, 83, 84, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (7)', 'attack the back, receive to feet, one-two with 9, cross or serve'),
    (2, 'Centre forward (9)', 'wall pass for 7, then attack the box'),
    (3, 'Left winger (11)', 'cut in for cross or through pass'),
    (4, 'Attacking midfielder (10)', 'insert into the box')
) AS v(so, role, job);

-- 76. pp.84-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.13 Penetration of the wing (diagrams 70b-70c)', 'Wide 1v1 isolation, in or out',
    'Alternative to the triangle: the winger takes his full back on alone. Going inside he serves 9 or 11 cutting in while 10 fills the free space; going outside he crosses.',
    'Winger isolated 1v1 with his full back',
    'Beat the full back individually and deliver.',
    NULL, 84, 85, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (7)', 'dribble inside then pass, or outside then cross'),
    (2, 'Centre forward (9) and left winger (11)', 'cut in to receive'),
    (3, 'Attacking midfielder (10)', 'move into the space left free')
) AS v(so, role, job);

-- 77. pp.85-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.13 Penetration of the wing (diagrams 72-73)', 'Winger can''t turn: lay off, spin long',
    'The winger receives but cannot turn, so he lays back to a supporting midfielder; then the winger spins long and the 9 comes short, and the supporter either serves one of them deep or switches. If the winger is doubled the lay-off is essential, otherwise a pass splitting the two defenders can be tried.',
    'Winger receives with back to goal / doubled',
    'Keep the ball and restart the attack via the supporter.',
    NULL, 85, 86, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (7)', 'lay off to 8, then run long behind'),
    (2, 'Right midfielder (8)', 'support; serve 7 deep, 9 short, or switch'),
    (3, 'Centre forward (9)', 'come short for a pass to feet')
) AS v(so, role, job);

-- 78. pp.87-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.14 Overlapping of the midfield player or of the back on the wing', 'Overlap 1-2-3 with third man',
    'After passing to the winger the midfielder overlaps; the winger can play to 9 who serves the overlapper for a cross, or combine inside with 9. If the winger is closed and cannot play forward, a third player (5 or the full back) supports him, the overlapper accelerates and receives behind him to cross. If the full back overlaps, the midfielder becomes the third man. Even without a local 2v1 the overlap drags defenders to the ball and opens the far side.',
    'Winger receives to feet on the flank',
    'Create a 2v1 on the wing or empty the opposite side for runners.',
    NULL, 87, 88, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfielder (8) or right back (2)', 'pass to 7 and overlap outside'),
    (2, 'Right winger (7)', 'play to 9, combine inside, or lay to the third man'),
    (3, 'Centre forward (9)', 'serve the overlapper or form a triangle'),
    (4, 'Third man (5, 2 or 8)', 'give support to the closed winger and release the overlap')
) AS v(so, role, job);

-- 79. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.15 Diagonal movement of the wing', 'Winger cuts inside, another fills wide',
    'When the winger is tightly marked but the defender leaves space inside, he runs diagonally into the middle and a teammate (full back or midfielder) takes the wide lane he vacated, giving the ball carrier two options.',
    'Winger marked tight, space inside his marker',
    'Open either the inside pass to the winger or the outside pass to the filler.',
    NULL, 89, 89, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (7)', 'cut diagonally inside; if served, find 9/11 cutting in or shoot'),
    (2, 'Right back (2)', 'push into the freed wide space; if served, triangle with 7 and cross'),
    (3, 'Right midfielder (8)', 'carry the ball, or fill the wide space when 2 has it'),
    (4, 'Attacking midfielder (10)', 'move into the free space')
) AS v(so, role, job);

-- 80. pp.90-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '4.16 Penetrating movements of the central forward', '9 checks; runners attack behind',
    'The 9 comes short to receive; the reading depends on whether his marker is tight (he cannot turn) or loose (he can turn). Wingers and wide midfielders run diagonally into the space behind; if 9 can only lay back to the holding midfielder, 5 serves the wingers and side midfielders cutting in.',
    '9 receives from midfield, marker tight or loose',
    'Use the 9''s checking run to release runners in behind.',
    NULL, 90, 91, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (9)', 'check to receive; turn if free, otherwise lay back to 5'),
    (2, 'Holding midfielder (5)', 'receive the lay-off and serve the runners'),
    (3, 'Wingers (7, 11)', 'diagonal runs in behind the back line'),
    (4, 'Side midfielders (8, 10)', 'cut in from the side as extra runners')
) AS v(so, role, job);

-- 81. pp.92-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3-4-2-1 according to Renzo Ulivieri (Bologna)', 'Two 10s drag the centre backs in',
    'Ulivieri''s 3-4-2-1 against a back four: the two attacking midfielders converge behind the lone striker, forcing the full backs to come inside to control them, then the wide midfielders attack the space outside. Weaker against a back three, and his own back three suffers against three forwards.',
    'Opponent defends with a flat back four',
    'Create wide space for the wing midfielders by pulling the back four narrow.',
    '4-4-2', 92, 92, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two attacking midfielders (10, 11)', 'converge behind the striker to pull defenders inside'),
    (2, 'Wide midfielders', 'attack the outside once the backs come in'),
    (3, 'Striker (9)', 'pin the centre backs')
) AS v(so, role, job);

-- 82. pp.92-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3-4-2-1 according to Renzo Ulivieri: possession', 'Back three build: one wide, two inside',
    'Build-up is either short on the ground or long to a target striker (Bologna had Kennet Andersson); when the three defenders bring it out there is one wide supporter and two inside supporters across the width of the box. If a central midfielder cuts in deep, the middle defender steps up into midfield to make an extra man.',
    'Three defenders in possession at the back',
    'Build out with numbers; avoid predictable repeated long balls.',
    NULL, 92, 93, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central defender of the three', 'step into midfield when a central midfielder drops in'),
    (2, 'Central midfielders', 'inside supporters; one may drop deep'),
    (3, 'Wide midfielder', 'wide supporter'),
    (4, 'Target striker', 'outlet for the long route')
) AS v(so, role, job);

-- 83. pp.93-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3-4-2-1 according to Renzo Ulivieri: depth first', 'Seek depth, else play outside',
    'The guiding idea is depth: if central midfielders are marked, the ball goes outside to the forwards, and one of the two attacking midfielders drops under the striker on the side he moves to. Under pressure the ball goes to the central player overlapping the forward ahead; in the opponent''s half he may play deep. The 9 often comes short to stay connected and avoid hard long passes.',
    'Central midfielders marked or team pressed',
    'Progress via forwards and supporting runs instead of hopeful long balls.',
    NULL, 93, 94, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder', 'drop under the striker on his side'),
    (2, 'Striker (9)', 'come short to stay close to team'),
    (3, 'Central midfielder', 'overlap past the forward to receive under pressure')
) AS v(so, role, job);

-- 84. pp.94-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '3-4-2-1 according to Renzo Ulivieri: defensive stage', 'Front three press triggers vs back four',
    'Against a back three the two 10s and the 9 go 3v3. Against a back four: on a lateral ball one 10 attacks the full back and the 9 with the other 10 move onto the nearest supporters; on a central ball the lone 9 shuffles between the two centre backs while they pass, and the press starts when one plays to a full back. If an opposing centre back carries forward, the midfielders pick him up.',
    'Pass from centre back to full back; lateral ball',
    'Press with three up front without being split by the centre backs.',
    NULL, 94, 94, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'dance between the two centre backs, press on the pass wide'),
    (2, 'Ball-side attacking midfielder (10/11)', 'attack the opposing full back'),
    (3, 'Other attacking midfielder', 'close the nearest supporter'),
    (4, 'Midfielders', 'mark an opposing centre back stepping into midfield')
) AS v(so, role, job);

-- 85. pp.94-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '3-4-2-1 according to Renzo Ulivieri: players behind the ball', 'Seven plus one behind ball',
    'Mostly seven defend plus the ball-side attacking midfielder, who joins the midfield; from the final third down the wide midfielders either become a fourth defender or stay in midfield. Against one or three forwards the right-sided centre back (Paramatti at Bologna) must play central, wide or step into midfield.',
    'Opponent in possession',
    'Keep a compact eight-man block with flexible back line.',
    NULL, 94, 95, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side attacking midfielder', 'drop and press with the midfield'),
    (2, 'Wide midfielders', 'drop into a back four or hold midfield line'),
    (3, 'Right centre back (2, Paramatti)', 'adapt: central, wide, or step into midfield vs one/three forwards')
) AS v(so, role, job);

-- 86. pp.96-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3-4-1-2 according to Andrea Mandorlini (La Spezia)', 'Open game long, closed game come short',
    'Width from the wide midfielders, depth from the two forwards plus the 10. Against a back four the central players are 1v1: in an open game the forwards run deep to pull the line away and let the 10 receive; in a closed game the 10 moves up alongside the forwards, and the outside defenders push up behind the wide midfielders for a midfield overload and wide 1v1s.',
    'Open game (carrier free) vs closed game',
    'Use the 10 between lines and create wide 1v1 situations.',
    NULL, 96, 97, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (10)', 'receive between lines; join forwards when closed'),
    (2, 'Two forwards', 'run deep in open game; one good in air and pressing'),
    (3, 'Wide midfielders', 'width, crosses, win 1v1s'),
    (4, 'Outside defenders', 'advance behind wide midfielders')
) AS v(so, role, job);

-- 87. pp.96-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '3-4-1-2 according to Andrea Mandorlini: defensive castle', 'Five-man defensive castle',
    'The two central midfielders and the three defenders move together up/down and side to side; the 10 drops beside the midfield, keep central superiority and 3v3 against three forwards. On long balls to the forwards these five win the second ball from behind while the wide midfielders, closest to the landing zone, close the field. Forwards must filter so the wide midfielders can step up.',
    'Opponent in possession, especially long ball',
    'Compact central block that wins long balls and second balls.',
    NULL, 96, 97, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three defenders + two central midfielders', 'move as one block, win ball from behind'),
    (2, 'Wide midfielders', 'close the field near reception zone'),
    (3, 'Attacking midfielder (10)', 'drop next to midfield'),
    (4, 'Forwards', 'screen passes so midfield can push up')
) AS v(so, role, job);

-- 88. pp.98-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '5.1 To rationally fill the space (back three)', 'Back three slide and keep 20 yards',
    'The three defenders slide toward the new ball carrier on each lateral pass, the far defender not going beyond the far post; they also step up or drop as the ball moves forward/back. The line stays roughly 20 yards from the ball so it can react to a deep goal kick or long pass. Midfield and forwards are layered on with the same moves.',
    'Ball moves across or up/down the pitch',
    'Cover spaces near the ball without emptying the far ones.',
    NULL, 98, 100, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side defender', 'slide toward the ball'),
    (2, 'Far-side defender', 'slide but stay inside the far post'),
    (3, 'Whole back line', 'step up/drop with the ball, keep 20 yards'),
    (4, 'Midfield line', 'shift in unison ahead of the defence')
) AS v(so, role, job);

-- 89. pp.101-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '5.2 Coming out and covering the opposing player in possession', 'Step out and cover triangle',
    'Lateral ball: the wide defender steps out on the ball, the central one covers behind him and the far one stays level with the central defender. Central ball: the middle defender steps out and the two wide defenders cover, forming a triangle. With forwards present, the others mark while keeping cover.',
    'Opponent receives in front of the back three',
    'Pressure the ball with cover behind.',
    NULL, 101, 102, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back (3)', 'step out on a wide carrier'),
    (2, 'Middle centre back (5)', 'cover; step out on a central carrier'),
    (3, 'Far centre back (2)', 'stay level / form the triangle and mark a forward')
) AS v(so, role, job);

-- 90. pp.102-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '5.2 Coming out and covering: outside midfielders as balance players', 'Wing midfielders balance the back three',
    'With a lateral ball the area beside the far defender is empty. If the ball is open (carrier sees goal and can play deep) the far wide midfielder drops toward the defensive line according to his opponent; if closed he moves toward the ball without leaving the midfield line. Midfielders also close centrally. If the carrier can see, defenders drop off and midfielders cover the defender who stepped out; if not, defenders mark tight and midfielders press. Lippi''s variant: the central midfielder drops between defenders.',
    'Lateral ball; open vs closed ball',
    'Stop the back three stretching into a long line with big gaps.',
    NULL, 102, 104, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Far wide midfielder (8)', 'drop toward back line on open ball, shift in on closed ball'),
    (2, 'Ball-side wide midfielder', 'decide whether to become a fourth defender'),
    (3, 'Central midfielders', 'close the middle, approaching each other'),
    (4, 'Back three', 'drop off on open ball, mark tight on closed ball')
) AS v(so, role, job);

-- 91. pp.107-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '5.5 Issues with 3 v 2 and 3 v 3', 'Mark-and-cover position in 3v2/3v3',
    'Carrier dribbles at the middle defender while a supporter moves near the wide defender: the wide defender takes a spot where he can both mark and cover; too tight frees the pass, and once the pass option is gone he drops back to cover. In 3v3 with two supporters widening the line, the defender in the carrier''s field of view marks closer while the other leans to cover.',
    'Central dribble with support runners',
    'Deny the pass and keep cover for the defender facing the ball.',
    NULL, 107, 108, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back (5)', 'face the dribbler'),
    (2, 'Defender on the visible runner', 'mark tighter'),
    (3, 'Defender on the hidden runner', 'lean in to cover 5')
) AS v(so, role, job);

-- 92. pp.108-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '5.5 Issues with 3 v 4', 'Outnumbered: delay, recover, take goal-side man',
    'In numerical inferiority the defenders delay and retreat to gain help, defending a small space with the keeper''s support; a wide midfielder tracking back into the line turns 3v4 into 4v4. When two opponents are in one defender''s zone, he takes the one nearer goal and lets the other go.',
    'Back three faced by four attackers',
    'Buy time until numbers are restored; protect the goal.',
    NULL, 108, 109, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'retreat and delay, stay compact'),
    (2, 'Wide midfielder (7)', 'recover into the defensive line'),
    (3, 'Centre back with two in zone (3)', 'go with the runner nearest goal'),
    (4, 'Goalkeeper', 'support the small-space defence')
) AS v(so, role, job);

-- 93. pp.110-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '5.6 Doubling the marking', 'Doubling with back three plus midfield',
    'Back three with four midfielders: on a lateral ball the line slides, the wide centre back steps out and the wide midfielder doubles; if the wide man is too far or late, the near central midfielder doubles. Central ball: the middle defender closes, the wide ones cover, a central midfielder doubles and the other recovers to keep four in midfield. With five midfielders the wing-back pair doubles, and on central balls the far wide man tucks in to balance.',
    'Ball to a wide or central attacker',
    'Win the ball two-on-one without losing cover.',
    NULL, 110, 111, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back (2/3)', 'step out on the ball'),
    (2, 'Wide midfielder (7/11)', 'double from the front'),
    (3, 'Near central midfielder (6/8 or 4)', 'double if wide man late, or on central ball'),
    (4, 'Middle centre back (5)', 'close a central carrier; otherwise cover'),
    (5, 'Far wide midfielder (11)', 'tuck in to balance')
) AS v(so, role, job);

-- 94. pp.112-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'to_attack', '5.7 A few training exercises (back three)', 'Regain then spread and counter',
    'Back three play with an offside trap and on winning the ball spread out and counter toward wide targets; the 9v7 version has the 3-4 block (or 3-5 vs a 3-5-2 shape) counterattacking on three small goals at the halfway line, the attackers set in the next opponent''s formation.',
    'Defenders win the ball',
    'Turn a regain into an immediate counter through the wide lanes.',
    NULL, 112, 113, 940)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'hold line/offside trap, then spread wide on regain'),
    (2, 'Midfield four/five', 'break toward wide and central targets')
) AS v(so, role, job);

-- 95. pp.114-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '3-3-4 according to Ezio Glerean: closing laterally', 'Midfielder or defender steps out wide',
    'Who closes the wide ball depends on distance and speed of the attack: if there is time the midfielder steps out on the pass from A to B, otherwise the defender goes and the line slides. With no 2v2 the midfielder doubles, otherwise he slides inside. On a central ball against two wide forwards and a central one, cover the middle and ignore the wide pair.',
    'Pass to the wide receiver',
    'Pressure the wide ball while keeping the centre protected.',
    NULL, 114, 115, 950)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (8)', 'step out if in time; double or slide inside'),
    (2, 'Wide defender (3)', 'step out if midfielder late'),
    (3, 'Back line', 'slide toward ball; on central ball guard the middle')
) AS v(so, role, job);

-- 96. pp.114-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '3-3-4 according to Ezio Glerean (Cittadella)', 'Six defend, four recover centrally',
    'Glerean''s 3-3-4: three defenders plus three midfielders defend, the four attackers recover inside, not wide; when the team is pinned at its box the forwards also come back. Against three forwards he shifts to four defenders and two midfielders. Defenders often must handle 1v1 and 2v2 because doubling isn''t always possible.',
    'Opponent in possession',
    'Defend with six while keeping four forwards ready to attack.',
    NULL, 114, 117, 960)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three defenders', 'hold the line, accept 1v1/2v2'),
    (2, 'Three midfielders', 'screen and step out'),
    (3, 'Four attackers', 'recover centrally; join when pinned at the box')
) AS v(so, role, job);

-- 97. pp.115-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '3-3-4 according to Ezio Glerean: neutralising 1-2 and 2v1', 'Absorbing the one-two run',
    'Against a one-two between A and B: if the midfielder doesn''t track A, the middle defender absorbs A''s run and the midfielder fills in to cover; if he tracks, no issue. Against an external 2v1: if the midfielder has time he closes the leader and the defender absorbs the run; if not, defenders handle the 2v1 and the midfielder recovers to rebalance.',
    'Wall pass or overlap creating a wide 2v1',
    'Pass the runner on so no one is free behind.',
    NULL, 115, 117, 970)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder (8)', 'track the passer or close the leader; else recover position'),
    (2, 'Middle centre back (5)', 'take the inside run if 8 doesn''t follow'),
    (3, 'Wide centre back (3)', 'absorb the overlap when 8 closes the ball')
) AS v(so, role, job);

-- 98. pp.117-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3-3-4 according to Ezio Glerean: offensive principles', 'Never restart from behind; four creators',
    'With two lines already outnumbered, the team never starts actions with balls back; defenders play short to midfield if possible or long to the front, where the second striker and the two wide forwards gather around the centre forward. The wide forwards hold width and look for one-twos or depth, the second striker plays between opposing lines, the centre forward on the last line.',
    'Ball won by defenders/midfield',
    'Get the ball forward quickly to the four attackers.',
    NULL, 117, 118, 980)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'simple play: short to midfield or long to forwards'),
    (2, 'Wide forwards', 'hold width, seek one-two or run deep; win 1v1'),
    (3, 'Second striker', 'between the lines, see the game'),
    (4, 'Centre forward', 'physical, on the defensive line')
) AS v(so, role, job);

-- 99. pp.117-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3-3-4 according to Ezio Glerean: offensive themes', 'Diagonal runs off the ball carrier',
    'When the second striker has the ball, the centre forward and the wide forward in his view run diagonally and the other wide forward comes inside. When a wide forward plays a one-two with the centre forward, the second striker and the opposite wide forward make diagonal runs.',
    'Second striker on ball, or wide one-two with 9',
    'Create crossing diagonal runs to unbalance the back line.',
    NULL, 117, 118, 990)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Second striker', 'carry and pick a runner; or diagonal run after the one-two'),
    (2, 'Centre forward (9)', 'diagonal run, or wall pass for wide forward'),
    (3, 'Wide forward in view (7)', 'diagonal run, or one-two with 9'),
    (4, 'Opposite wide forward (11)', 'come inside / diagonal run')
) AS v(so, role, job);

-- 100. pp.119-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '3-4-3 according to Claudio Terzulli (Castel San Pietro)', 'Steer to back, front three press',
    'Terzulli''s 3-4-3 with three tight forwards gives seven in midfield to close and press and a 3v2 at the back. Against a 4-4-2 using two forwards and a second striker, the team leads play toward the full back then presses: the far forward marks the opposing central midfielder if he comes to the ball, otherwise blocks the other centre back or full back. Closing that midfielder frees a midfielder to pick up the second striker, keeping 3v3 at the back. Interview continues past spread 119.',
    'Ball played to the opposing full back',
    'Press with numbers while keeping a back-line overload.',
    '4-4-2', 119, 119, 1000)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Far-side forward (A)', 'mark the central midfielder coming to the ball, else block CB/full back'),
    (2, 'Ball-side forwards', 'steer play to the full back and press'),
    (3, 'Midfielder freed', 'mark the opposing second striker'),
    (4, 'Back three', 'hold 3v2 / 3v3')
) AS v(so, role, job);

-- 101. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3:4:3 According to Claudio Terzulli', 'Three tight forwards pin a back two',
    'Against a 4-4-2 the three forwards stay high and narrow; the two centre backs will not step out to the wide forwards, so the middle centre back is left 2v1 against the striker.',
    'Opponent defends with two centre backs',
    'A wide forward gets the ball free between the opposing midfield and back line, or the opponent drops a midfielder and loses a man in midfield.',
    '4-4-2', 120, 120, 1010)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (9)', 'pin both centre backs, hold the ball up'),
    (2, 'Wide forwards (7, 11)', 'stay tight and high, receive in the pocket between lines'),
    (3, 'Midfield four', 'find the free wide forward between the lines')
) AS v(so, role, job);

-- 102. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3:4:3 According to Claudio Terzulli', 'Front-three rotation off a wide run',
    'Attack principles: attack space, play wide, use one-twos, alternate the ball between front and back. When a wide forward moves (wide, straight, inside or toward the ball) the other two forwards rotate to fill.',
    'Wide forward starts a movement (e.g. 7 comes inside)',
    'Defenders are dragged and space opens for the rotating forward.',
    NULL, 120, 120, 1020)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right forward (7)', 'moves inside to start the rotation'),
    (2, 'Centre forward (9)', 'moves out wide to replace him'),
    (3, 'Left forward (11)', 'attacks the vacated central space')
) AS v(so, role, job);

-- 103. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '3:4:3 According to Claudio Terzulli', 'Defend far from goal, accept back-line equality',
    'With the ball far from goal the back three accept 1v1s and equal numbers since there is time to recover; near goal they narrow and stack extra covers.',
    'Ball location relative to own goal',
    'Defending happens high; 1v1 is only dangerous when the forward is goal side.',
    NULL, 120, 120, 1030)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'accept 1v1 high up, narrow and cover when ball nears goal'),
    (2, 'Goalkeeper', 'read position from own back line, sweep behind')
) AS v(so, role, job);

-- 104. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3:4:3 According to Claudio Terzulli', 'Back three as preventive cover',
    'When the team has the ball the three defenders do not join in; they position as preventive cover relative to where the attack is happening, and the goalkeeper must play with his feet in build-up.',
    'Team in possession',
    'Rest defence ready to stop the counter when the ball is lost.',
    NULL, 120, 120, 1040)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'shift as preventive cover behind the attack, restart play technically'),
    (2, 'Goalkeeper', 'restart with the feet, read the line')
) AS v(so, role, job);

-- 105. pp.120-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '3:4:3 According to Claudio Terzulli', 'Balance players and front-three roles',
    'Role split in the 3-4-3: two high-endurance outside midfielders (''balance players'') choose between back line and midfield as play demands; one central mid is the quality receiver from defence, the other presses and breaks centrally; the central forward holds play up for wide forwards, who are quick 1v1 players (one makeshift striker, one secondary forward).',
    'Phase of play changes',
    'Shape stays balanced while the front three and wide mids attack.',
    NULL, 120, 121, 1050)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside midfielders (balance players)', 'drop to the defensive line or step into midfield by situation'),
    (2, 'Playmaking central mid', 'receive from the defenders and distribute'),
    (3, 'Ball-winning central mid', 'press and penetrate centrally'),
    (4, 'Central forward (vertex)', 'hold possession, free the wide forwards wide and in depth'),
    (5, 'Wide forwards', 'win 1v1s, one acts as a striker, one as a secondary forward')
) AS v(so, role, job);

-- 106. pp.123-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '6.1 3:5:2 ''Header'' of the forward', 'Centre forward lay-off with runners',
    'Right back 2 plays into the attacking centre half 4, who returns to 2; 2 drives the ball into the centre forward 9 after a feint; link men 10 and 7 run beyond for 9''s flick-on/lay-off while 11 supports 9.',
    'Centre forward checks short and is fed from the back',
    'Wide link men arrive beyond the forward to receive his touch near the box.',
    NULL, 123, 123, 1060)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back (2)', 'feed 9 directly after the return pass'),
    (2, 'Attacking centre half (4)', 'feint, receive, give back to 2'),
    (3, 'Centre forward (9)', 'feint, lay off or flick on'),
    (4, 'Link men (7, 10)', 'run in behind for the knock-on'),
    (5, 'Second forward (11)', 'support 9; variant: run in behind 9 while 7 supports and 10 fills')
) AS v(so, role, job);

-- 107. pp.124-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '6.2 Penetrating movement of the forward', 'Forward sets attacking mid, partner spins in',
    'Back 2 feeds the forward 9 who has checked with a feint; the attacking centre half 4 supports and gets the set from 9; the other forward 11 cuts in behind 9 for the through ball while the link men 10 and 7 push deep.',
    'Forward receives back to goal with a supporting mid',
    'Third-man through ball to the forward running behind the line.',
    NULL, 124, 124, 1070)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (9)', 'check, receive, lay to 4'),
    (2, 'Attacking centre half (4)', 'support under 9, play through'),
    (3, 'Second forward (11)', 'cut behind 9 into depth'),
    (4, 'Link men (7, 10)', 'move deep to stretch the line')
) AS v(so, role, job);

-- 108. pp.125-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '6.3 Attacking with a link man', 'Link man wide feeds three runners',
    'Back 3 plays to wide mid 6, who is marked and passes inside to 4; 4 plays forward to the link man 10 high and wide; 9 cuts in, 11 goes wide and 7 comes in from the far side. Variant: 11 swaps with 10, 9 attacks the space behind 11, 7 hits the blind side.',
    'Link man receives high on the flank',
    'Ball played behind the opposing back line to one of three timed runs.',
    NULL, 125, 125, 1080)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (6)', 'receive, bounce inside to 4'),
    (2, 'Attacking centre half (4)', 'play the link man forward'),
    (3, 'Link man (10)', 'receive wide and serve the runs'),
    (4, 'Forwards (9, 11)', '9 cuts in, 11 goes wide (or swaps with 10)'),
    (5, 'Far link man (7)', 'attack the blind side')
) AS v(so, role, job);

-- 109. pp.126-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '6.4 Attacking with the link man inside', 'Wing pair in-out, mid under the forwards',
    'The wing pair interchange: 8 comes inside and 7 goes outside, getting space to receive; because neither forward comes short, wide mid 6 takes a central spot under the strikers to receive. Variant: when the forwards are marked tight inside they criss-cross to get free and the forward without the ball cuts toward goal.',
    'Forwards do not drop to receive',
    'A free receiver appears between the lines or out wide.',
    NULL, 126, 126, 1090)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing pair (7, 8)', 'one in, one out to free the outside man'),
    (2, 'Midfielder (6)', 'step centrally under the forwards'),
    (3, 'Forwards (9, 11)', 'criss-cross; non-receiver runs at goal')
) AS v(so, role, job);

-- 110. pp.127-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '6.5 Combination with three players', 'Overlap-and-cross three-man combination',
    'Link man 7 comes toward 2 and stays wide, 8 runs into the wing lane, 9 drops into the freed space after a feint and sets 4, who plays 8 in for the cross; 11 runs diagonally and 10 arrives. Variant: unsupported 9 turns inside and finds 11, 6 fills, 8 cuts in from the right.',
    'Link man drops toward ball carrier, emptying the wing',
    'Overlapping midfielder crosses with box runners arriving.',
    NULL, 127, 127, 1100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Link man (7)', 'come short and wide to drag his marker'),
    (2, 'Wide midfielder (8)', 'run into the vacated wing, cross'),
    (3, 'Centre forward (9)', 'drop, set back to 4 or turn to 11'),
    (4, 'Attacking centre half (4)', 'play 8 in behind'),
    (5, 'Box runners (11, 10)', 'diagonal run and late insertion')
) AS v(so, role, job);

-- 111. pp.128-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '6.6 Coming out on the attacking center half', 'Attacking mid drops to receive from back',
    'Attacking centre half 4 drops with a feint to take the ball from right centre back 2; 8 goes wide below link man 7 who has pushed up; with no forward coming in, 7 cuts inside and holds the ball until teammates arrive. Variant: 7 plays a one-two with 9 first, letting 6 and 11 swap positions.',
    'Back line in possession, midfield marked',
    'Clean exit to midfield and time for players to insert.',
    NULL, 128, 128, 1110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking centre half (4)', 'drop and receive from the back'),
    (2, 'Right midfielder (8)', 'widen below the link man'),
    (3, 'Link man (7)', 'cut inside, hold, or one-two with 9'),
    (4, 'Midfielder (6) / forward (11)', 'exchange positions on the one-two')
) AS v(so, role, job);

-- 112. pp.129-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '6.7 Change of direction of the ball by the attacking center half', 'Dribble inside to switch the angle',
    'Left mid 6 receives and dribbles inside, changing the direction of play using 10''s run; on the pass 11 goes forward and 4 readies to receive; 9 then clears space for 8''s diagonal run on the right. Variant: 11 supports 6, sets 4, who plays link man 10 in on the run.',
    'Wide midfielder receives with space to carry inside',
    'Play is switched and a diagonal runner attacks the far side.',
    NULL, 129, 129, 1120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left midfielder (6)', 'carry inside, change direction'),
    (2, 'Link man (10)', 'run to open the lane, receive on the run'),
    (3, 'Attacking centre half (4)', 'receive and redistribute'),
    (4, 'Forwards (9, 11)', '9 vacates space, 11 goes forward or supports'),
    (5, 'Right midfielder (8)', 'diagonal run on the far side')
) AS v(so, role, job);

-- 113. pp.130-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '6.8 3:4:3 Exercises for the technical aspect', 'Back three switch for lateral or vertical support',
    'The back three, with only two passes available, move the ball across to find whichever support the opponent''s defending allows, lateral (wide) or vertical (into midfield); if neither is on, the ball goes long. Body shape and look on receiving are coached; the drill builds into chains of the full team.',
    'Opponent blocks one support option',
    'Ball progresses through the side or centre that is open; long ball only as last resort.',
    NULL, 130, 131, 1130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three (2, 5, 3)', 'circulate, open body, choose lateral or vertical support'),
    (2, 'Wide supports', 'offer lateral outlet'),
    (3, 'Central midfielders', 'offer vertical outlet')
) AS v(so, role, job);

-- 114. pp.132-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '6.9 Hand pass of the goalkeeper', 'Keeper throw to vertical attack and cross',
    'Goalkeeper throws to 5, who plays 2; 2 hits a vertical pass to 10, who moves inside and finds 9, opening space for 7 to overlap; 9 receives after a feint and opens up for 7 to cross. Variants: 9 sets back to 10 for a shot, or 9 plays 10 who sends 11 into the box.',
    'Goalkeeper has the ball in hand',
    'Fast attack from the keeper to a cross or shot in a few passes.',
    NULL, 132, 133, 1140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'throw to the central defender'),
    (2, 'Right centre back (2)', 'play vertical into 10'),
    (3, 'Link man (10)', 'move inside, combine with 9, shoot or serve 11'),
    (4, 'Centre forward (9)', 'feint, set to 7 or 10'),
    (5, 'Right link man (7)', 'overlap and cross')
) AS v(so, role, job);

-- 115. pp.132-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '6.9 Hand pass of the goalkeeper', 'Three box targets plus preventive covers',
    'On a wide delivery the attackers fill three references: near post, far post and penalty spot, while the three midfielders sit behind as preventive cover for a cleared or recycled ball and the back three hold their positions.',
    'Wide player about to cross',
    'Cross has three targets and the team is protected against the counter.',
    NULL, 132, 135, 1150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards / link man (9, 11, 10)', 'occupy near post, far post, penalty spot'),
    (2, 'Midfielders (4, 6, 8)', 'preventive cover at the edge for clearances and recycles'),
    (3, 'Back three (2, 5, 3)', 'hold rest-defence line')
) AS v(so, role, job);

-- 116. pp.135-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '6.10 ''Cable'' movement', 'Cable movement: link man drops, back plays forward',
    'Link man 10 comes toward the back 2, pulling his marker and freeing the space behind him; 2 then plays straight into 9 (after a feint), who controls or opens up for 7 to cross. Midfield again takes preventive covers.',
    'Link man checks back toward the ball carrier',
    'Vacated space lets the back find the forward, then a cross from the overlapping wide man.',
    NULL, 135, 135, 1160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Link man (10)', 'drop toward 2 to drag the marker'),
    (2, 'Right centre back (2)', 'play into 9'),
    (3, 'Centre forward (9)', 'feint, control, open to the wing'),
    (4, 'Wide link man (7)', 'run the flank and cross')
) AS v(so, role, job);

-- 117. pp.137-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '7.1 1v1 with the ball in front or on the side', '1v1 defending: stance, side, tackle moment',
    'Defender is low on the balls of the feet watching the ball; centrally he blocks the goal with his body, wide he angles his feet to show the attacker outside. Tackle when the carrier''s foot leaves the ball (outer foot if he goes outside, inner foot if inside), weight forward, stay active with feints and never let the ball come too close, especially high up, wide or outnumbered.',
    'Opponent dribbles at the defender',
    'Win the ball or steer the attacker away from goal.',
    NULL, 137, 141, 1170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender facing the carrier', 'low stance, show outside, tackle when ball leaves the foot'),
    (2, 'Defender beaten by a knock-on', 'slide on the ball if ahead, else cut across the runner''s path as a legal shield')
) AS v(so, role, job);

-- 118. pp.138-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '7.2 1v1 with opponent receiving in front', 'Close down while the pass travels',
    'When the opponent is about to receive facing play, the defender sprints while the ball is moving to engage as far from goal as possible, then brakes and sets his position at the right distance.',
    'Pass played to an opponent in front',
    'Receiver is engaged early, away from goal, with the defender balanced.',
    NULL, 138, 138, 1180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Closing defender', 'sprint on the pass, slow down, set distance and angle')
) AS v(so, role, job);

-- 119. pp.139-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '7.3 1v1 with the opponent receiving and turning his back', 'Stop the back-to-goal receiver turning',
    'Against a receiver with his back to goal, stay goal side and inside, contain from the inside when the ball is slow, use a hand to feel him without letting him lean on you, deny the turn, and tackle when he is halfway round; very near goal stay at his side with arms out to block.',
    'Opponent receives back to goal',
    'Receiver is forced back or dispossessed mid-turn.',
    NULL, 139, 141, 1190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marking defender', 'goal side, contain, deny the turn, tackle at half-turn')
) AS v(so, role, job);

-- 120. pp.140-143
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '7.4 1v1 with the ball far away', 'Off-ball marking: tight or loose rule',
    'Away from the ball, see both ball and man, stay inside between him and goal and do not get caught by a ball played over you. Marking distance depends on both players'' distance from the ball and where the action is: tight when near the ball or when the carrier cannot see goal or cannot play forward, loose otherwise. Practised in a set-pairs model game where each side''s one free player is the only one allowed to pick up an unmarked man.',
    'Ball elsewhere; marker adjusts to carrier''s vision and distance',
    'Marker is always in position to intercept or engage.',
    NULL, 140, 143, 1200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marking defender far from ball', 'goal side, watch ball and man, tighten or loosen by rule'),
    (2, 'Free defender', 'pick up whoever is left unmarked')
) AS v(so, role, job);

-- 121. pp.145-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '7.7 To elude the marking with no direction', 'Step out of the marker''s shadow',
    'The off-ball player moves to open a clear line between himself and the carrier, getting out of the defender''s interception line, and does it inside the carrier''s field of vision.',
    'Defender sits in the passing line',
    'A clean passing lane is created.',
    NULL, 145, 145, 1210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Off-ball receiver', 'slide out of the defender''s cover shadow, stay in the passer''s view'),
    (2, 'Ball carrier', 'play the opened lane')
) AS v(so, role, job);

-- 122. pp.146-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '7.8 To elude the marking related to the player in possession', 'Backup, clearance or high support',
    'Support choice follows the carrier''s situation and never in a straight line with him: backup support behind (not too close) when he cannot see goal and is pressed from behind; a clearance/penetrating run when he sees goal but a defender stops the forward pass; high support deep upfield when he can see goal and play vertically. The receiver keeps carrier and goal in view.',
    'Carrier''s body orientation and pressure',
    'Carrier always has the right type of option.',
    NULL, 146, 146, 1220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Supporting player behind', 'offer a back pass at an angle when carrier faces own goal'),
    (2, 'Penetrating runner', 'run beyond when carrier faces up but is blocked'),
    (3, 'High supporter', 'move deep upfield when carrier can play vertically')
) AS v(so, role, job);

-- 123. pp.147-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '7.9 To elude the marking related to your own marking duty', 'Get free by reading your marker',
    'Four movements: feint long then come short, come short then spin in behind, drift wide/in depth then come inside, or come inside then go wide. Pick by the marker: check away then come short against a loose marker who is inside; feint short then go behind against a tight inside marker; wide-to-inside run against a tight marker behind who leaves the inside open; curved inside-out when he blocks the inside reception.',
    'Marker''s distance and side',
    'Receiver gets free in the space the marker leaves.',
    NULL, 147, 147, 1230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver being marked', 'feint then move to the side the marker leaves open'),
    (2, 'Ball carrier', 'time the pass to the receiver''s second movement')
) AS v(so, role, job);

-- 124. pp.149-149
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '7.11 Different kinds of passes', 'Pass-and-go vs pass-and-follow',
    'When the receiver can play again unopposed, the passer moves on: one-two/triangle to beat a man, overlap behind the receiver to make a 2v1, cut into the defender''s blind side, or move away to a new space. When the receiver is closed down and cannot play forward, the passer follows and stays in support behind him.',
    'Whether the receiver is free or pressed',
    'Passer immediately becomes a useful option again.',
    NULL, 149, 149, 1240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'go (one-two, overlap, blind-side cut, move away) or follow in support'),
    (2, 'Receiver', 'return, lay off or hold depending on pressure')
) AS v(so, role, job);

-- 125. pp.150-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '7.11 Different kinds of passes', '1-2-3 third-man combination',
    'A player passes to a marked teammate and runs on because a third player supports the receiver; the receiver lays to the third man, who serves the deep run of the original passer. The runner waits behind the receiver until the supporter can no longer see the runner''s marker and can pass, then accelerates, so the supporter is not left without cover if the ball is lost.',
    'Pass into a marked teammate with a third man in support',
    'Original passer is released in depth via the third man.',
    NULL, 150, 150, 1250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First passer', 'play in, wait behind, then sprint deep'),
    (2, 'Marked receiver', 'lay off to the third man'),
    (3, 'Third man', 'support angle, play the runner in')
) AS v(so, role, job);

-- 126. pp.153-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '8.1 Space training', 'Youth: spread out, switch the play',
    'Young players bunch around the ball and never switch play because they misread space. Fix posture, knowledge of the pitch and its lines, and awareness of teammates/opponents/ball before teaching shape.',
    'Players crowd the ball zone',
    'Players occupy width and depth and switch to the free side.',
    NULL, 153, 153, 1260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All outfield players (youth)', 'hold width/depth, look for the open side and switch')
) AS v(so, role, job);

-- 127. pp.155-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'out_of_possession', '8.3 Choosing the formation', 'Youth zonal 4-3-3, slide to the ball',
    'For youth teams the author recommends a zonal 4-3-3: clear roles, natural chains and depth/width, no paired movements like a 4-4-2. The zone is a means of cooperation: the whole group slides toward the ball and helps each other defend.',
    'Ball moves across the pitch',
    'Compact mutual cover without man-marking.',
    NULL, 155, 155, 1270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'slide as a unit toward the ball, cover each other'),
    (2, 'Midfield three', 'shift with the ball side, close inside lanes'),
    (3, 'Front three', 'join the slide and the defensive phase')
) AS v(so, role, job);

-- 128. pp.156-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-soccer-modern-tactics'), 'in_possession', '8.4 Formations for the very young players', '7v7 3-3: defenders and attackers interchange',
    'For 7v7 (ages 8-10) the author proposes a two-line 3-3 instead of 3-2-1, 3-1-2 or 2-3-1, so defenders and attackers swap freely and every child both scores and defends.',
    'Youth 7v7 match',
    'All kids take part in every phase without fixed roles.',
    NULL, 156, 156, 1280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three (youth)', 'push up and attack when the chance comes'),
    (2, 'Front three (youth)', 'drop and defend, swap with the back line')
) AS v(so, role, job);

COMMIT;
