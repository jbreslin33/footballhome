-- 5022 📚 Coaching book patterns: "The Modern Soccer Coach 2014: A Four
-- Dimensional Approach" (Gary Curneen, Bennion Kearny) — Kindle library
-- (spreads s001–s081 from Kindle Cloud Reader).  Every spread read; each
-- distinct team behaviour written up in OUR OWN WORDS with who does what.
-- Coaching philosophy, training-method theory and front matter left out.
-- Owner's personal library.  (James 11/27 Kindle picks)
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    season      = '2014',
    method_note = 'A US college coach''s guide to the modern game and how to coach it: the modern roles (deep playmaker, ball-playing centre back and keeper, fluid shape), a bridge model linking training to the match and the coach''s non-negotiables, then game-based sessions for scoring goals, defending, transitions and counter-attacking (near post / far post / late runner, the killer pass and second wave, regain and counter), ending with traits of a modern coach and Brendan Rodgers'' Liverpool decision tree. Patterns are the match behaviours the sessions train, in our words; philosophy left out. Kindle edition: page numbers are screen spreads.'
WHERE slug = 'kindle-modern-soccer-coach-2014';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014');

-- 1. pp.8-8
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'to_defend', 'Foreword (Gerry Armstrong)', 'Barcelona fast regain, starve opponent',
    'Guardiola''s Barcelona, per the foreword: they win the ball back very quickly after losing it, so the opponent hardly has it and Barca keep around 70 per cent possession.',
    'Ball lost',
    'Get the ball back almost at once and keep the opponent off the ball for most of the game.',
    NULL, 8, 8, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players to the ball (Xavi, Iniesta, Busquets)', 'Hunt the ball straight away after losing it'),
    (2, 'Whole team', 'High work rate so the regain is collective'),
    (3, 'Messi', 'Freed to create because the rest win it back')
) AS v(so, role, job);

-- 2. pp.15-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'out_of_possession', 'Ch1 Don''t Forget The Pressure', 'Deep compact block, lone striker',
    'Many international and Champions League sides set up first not to lose: a deep, compact defending block with one striker left up top.',
    'Opponent in possession, result-first game plan',
    'Deny space and goals, accepting less attacking threat.',
    NULL, 15, 15, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line and midfield', 'Sit deep and stay compact'),
    (2, 'Lone striker', 'Stay high as the only outlet')
) AS v(so, role, job);

-- 3. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch2 Role of Goalkeepers', 'Ball-playing keeper in build-up',
    'The modern keeper must handle tricky back-passes and build with his feet; because keepers are now trusted on the ball, attacks start further back. Forwards in turn chase back-passes to hurry the keeper''s distribution.',
    'Back-pass to the keeper',
    'Keeper keeps the build-up going under pressure; pressers try to spoil his service.',
    NULL, 17, 17, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Control a back-pass under pressure and pass out accurately'),
    (2, 'Centre backs', 'Use the keeper as a safe extra passer'),
    (3, 'Opposing forwards', 'Chase the back-pass to hurry the keeper')
) AS v(so, role, job);

-- 4. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch2 Deep Playmaker', 'Deep-lying playmaker sets the tempo',
    'The old number 10 playmaker has given way to a deep string-puller in front of the defence (Busquets, Pirlo, Alonso, Schweinsteiger, Carrick, Gundogan) who keeps the ball, changes the point of attack and controls the tempo.',
    'Team building from the back',
    'Dictate where and how fast the team attacks; opponents must plan to press him.',
    NULL, 17, 17, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Busquets / Pirlo type)', 'Drop in front of the back line, receive, switch play, set the tempo'),
    (2, 'Centre backs', 'Feed him early'),
    (3, 'Opponent', 'Must put pressure on him or he runs the game')
) AS v(so, role, job);

-- 5. pp.17-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch2 Playmaking Center Backs', 'Centre back carries into opponent half',
    'When the opponent drops deep with ten men to counter, the centre backs get time on the ball; a ball-playing centre back (Pique, Gullit as libero) carries it forward into the opposition half to open attacking options.',
    'Opponent drops deep, space ahead of the centre back',
    'Add an extra man in midfield and pull a defender out of shape; a centre back weak on the ball invites pressure.',
    NULL, 17, 18, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (Pique)', 'Dribble into midfield and on into the opposition half'),
    (2, 'Other centre back / holding midfielder', 'Cover the space he leaves'),
    (3, 'Midfielders', 'Move to offer passes as he steps in')
) AS v(so, role, job);

-- 6. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch2 Decline of Fixed Systems of Play', 'Fluid shape, striker-less option',
    'Formations have grown close together (4-5-1 turns into 4-4-2 or 4-3-3 within seconds) and teams have separate attacking and defending shapes; Spain at Euro 2012 played without a recognised centre forward. Players carry several roles in attack and defence.',
    'Possession won or lost (shape changes)',
    'Solve each opponent''s problems with movement rather than a rigid system.',
    NULL, 18, 18, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielders / forwards', 'Push on to turn a 4-5-1 into a 4-3-3 when attacking'),
    (2, 'Midfield (Spain 2012)', 'Fill the striker space by movement, no fixed number 9'),
    (3, 'All outfield players', 'Know both attacking and defending roles')
) AS v(so, role, job);

-- 7. pp.33-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch5 Opposite Playing Styles Warm-Up: Possession v Pressure', 'Circulate across the pitch to switch',
    'The possession side tries to move the ball from one flank to the other against a team that presses to win it back; they use the keepers and wide players to create an overload in the middle.',
    'Pressure on one side of the pitch',
    'Get the ball across to the far side before the press shuts it in.',
    NULL, 33, 34, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player on the ball', 'Receive facing the options, open body shape, play quickly'),
    (2, 'Supporting players', 'Give options both wide and ahead of the ball, make angles'),
    (3, 'Goalkeeper', 'Join as an extra passer to make the overload'),
    (4, 'Wide target players', 'Hold width on both flanks for the switch')
) AS v(so, role, job);

-- 8. pp.33-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'to_attack', 'Ch5 Opposite Playing Styles Warm-Up: Possession v Pressure', 'High press, regain and shoot',
    'Against a possession team, the counter-attacking side presses high to win the ball, keeps its pressing organised so no presser gets isolated, and goes straight for goal on the regain.',
    'Opponent circulating the ball; ball won',
    'Turn a high regain into a quick shot before the possession team can recover shape.',
    NULL, 33, 34, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First presser', 'Close down the ball fast'),
    (2, 'Second / third pressers', 'Press together so nobody is isolated'),
    (3, 'Player who wins it', 'Attack at once, look for a shot'),
    (4, 'Possession team on losing it', 'Switch to defending right away to stop the goal')
) AS v(so, role, job);

-- 9. pp.35-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'out_of_possession', 'Ch5 Six Goal Transition Game', 'Cover several targets, nobody isolated',
    'With more than one goal to protect, each defender has more than one job: he minds his own target and also covers teammates, reading the play early so he gets to where he is needed.',
    'Opponent attacking with several options',
    'Stop every goal threat by shifting and covering as a unit.',
    NULL, 35, 35, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender near the ball', 'Block the nearest goal / option'),
    (2, 'Covering defenders', 'Shift to cover the next goal and back up teammates'),
    (3, 'Goalkeeper', 'Slide along the line, organise and talk to teammates')
) AS v(so, role, job);

-- 10. pp.35-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch5 Six Goal Transition Game', 'Change point of attack through middle',
    'When one target is guarded, the attacking side moves the ball through the central area to the other target; players spread to both sides of the ball. On a regain they attack straight away.',
    'Near target covered / ball won',
    'Find the unguarded goal by quick switches and decisions.',
    NULL, 35, 35, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Receive in the middle and switch to the far side'),
    (2, 'Players both sides of the ball', 'Take positions left and right so the switch is on'),
    (3, 'Player who wins it', 'Attack immediately')
) AS v(so, role, job);

-- 11. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch5 Goalkeeper Quarterback Game', 'Switch the play through the keeper',
    'The keeper is used as a central quarterback to change the point of attack and to play the forward ''killer pass'' into runners.',
    'Pressure on one side, keeper free',
    'Use the keeper''s distribution to switch play and release forward runs.',
    NULL, 36, 36, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Take the ball and distribute fast (throw or pass) to the far side or a forward runner'),
    (2, 'Outfield players', 'Move off the ball at once to give the keeper options'),
    (3, 'Passer to the keeper', 'Get the pass in cleanly')
) AS v(so, role, job);

-- 12. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'out_of_possession', 'Ch5 Goalkeeper Quarterback Game', 'Show away from middle, drop if broken',
    'Defending players angle their pressure to force the ball carrier away from the centre (and the central playmaker); if the press is beaten they drop and cover the space behind.',
    'Opponent on the ball near the middle; press bypassed',
    'Cut out central service and avoid giving up deep runs behind.',
    NULL, 36, 36, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Presser on the ball', 'Show him wide, away from the middle'),
    (2, 'Nearby defenders', 'Block passing lanes into the centre'),
    (3, 'Back players', 'Drop and cover the space behind once the press is broken')
) AS v(so, role, job);

-- 13. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch5 Angles and Movement Game', 'No square balls, staggered support angles',
    'Support players avoid standing level with or straight in line with a teammate (same horizontal or vertical channel), taking diagonal angles instead, and the player on the ball scans early.',
    'Teammate on the ball',
    'Create forward diagonal passing lanes, more time on the ball, and make defenders work to close space.',
    NULL, 37, 37, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player on the ball', 'Scan the field early, play forward-diagonal'),
    (2, 'Supporting players', 'Move into a different line/channel from the ball carrier to give a clear angle'),
    (3, 'Goalkeeper', 'Move to offer support')
) AS v(so, role, job);

-- 14. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch5 Early Cross Game', 'Early ball to winger, early cross',
    'Instead of chasing balls to the corner flag, the wide player gets the ball early to feet in the wide area and crosses quickly with few touches, while as many attackers as possible flood the box.',
    'Ball played to a wide attacker in the wide channel',
    'Cross before the defence settles, into the gap between back line and keeper, with box overloads.',
    NULL, 38, 38, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide attacker', 'Take the ball early, control and cross in two touches'),
    (2, 'Central players', 'Pass early and well to the wide man''s feet'),
    (3, 'Strikers / midfield runners', 'Sprint into the box as soon as the ball goes wide'),
    (4, 'Goalkeeper (after the cross)', 'Restart the next attack quickly')
) AS v(so, role, job);

-- 15. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'out_of_possession', 'Ch5 Early Cross Game', 'Show wide carrier away from danger',
    'Defenders angle their pressure to keep the ball carrier away from the threatening areas from which he can serve a cross.',
    'Opponent building toward the wide channels',
    'Stop clean service into the wide crossing zones.',
    NULL, 38, 38, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'Press and steer the carrier away from the crossing zone'),
    (2, 'Back line', 'Defend the space between defence and keeper')
) AS v(so, role, job);

-- 16. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch6 Four Dimensions Of Attacking Soccer', 'Movement of ball and players vs set defence',
    'Top teams get numbers behind the ball quickly; the answer to a rigid, organised defence is movement of the ball and of players, and attackers who know where their system creates chances so they arrive in those spots at speed.',
    'Opponent set and compact in its defensive third',
    'Create space and chances by constant movement and quick tactical recognition.',
    NULL, 40, 40, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Know where chances come in the system and get there early'),
    (2, 'Midfielders', 'Keep moving off the ball, combine to drag defenders'),
    (3, 'Wide players', 'Deliver crosses that beat the first defender')
) AS v(so, role, job);

-- 17. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch 6 Scoring Goals - Find Your Danger Zone', 'Define the team''s danger zone',
    'Coach decides where his side should score from given its system: from wide crosses (Ferguson''s Man United), intricate combinations at the box edge (Arsenal/Barcelona) or balls over the top of the back line (Gerrard to Torres, Liverpool).',
    'Ball reaches the final third',
    'Players know their roles and get numbers into the agreed scoring areas.',
    NULL, 41, 41, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players', 'Deliver from wide if the team scores from crosses'),
    (2, 'Forwards', 'Occupy the agreed scoring zone and make the numbers up in the box'),
    (3, 'Midfielders', 'Feed the chosen route: combination at box edge or ball in behind')
) AS v(so, role, job);

-- 18. pp.41-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch 6 Scoring Goals - The Importance of Tap-In Goals', 'Gamble on rebounds and scrambles',
    'Attacks rarely finish cleanly; players should follow every shot and cross into the six yard box to win rebounds, goalmouth scrambles and loose balls instead of abandoning the move.',
    'Shot taken or ball about to be delivered into the area',
    'Extra ''ugly'' goals from second balls because a runner reacts first.',
    NULL, 41, 42, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Follow every shot in toward goal and react first to the bounce'),
    (2, 'Wide / late midfielders', 'Make opportunistic runs into the six yard box when a delivery looks likely')
) AS v(so, role, job);

-- 19. pp.43-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch 6 Attacking Exercises 1, 2 and 5', 'Near post, far post, late runner',
    'When the ball goes wide, two forwards split to attack the near and far post while a third player arrives late for anything played behind them; the wide player crosses early and with pace, across the six yard box, without needing to look up.',
    'Wide player gets free on the flank',
    'Every crossing zone is filled at full speed so an early, driven delivery finds a finisher.',
    NULL, 43, 47, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward 1', 'Sprint across to attack the near post, timing the run not too early'),
    (2, 'Forward 2', 'Attack the far post'),
    (3, 'Late midfielder', 'Arrive late at the edge of the box / penalty spot for cut-backs and balls behind'),
    (4, 'Wide player', 'Cross early, driven toward near post or across the six yard box; pace on the ball means a simple finish')
) AS v(so, role, job);

-- 20. pp.45-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch 6 Attacking Exercise 3', 'Multi-player movement beats a back four',
    'Against a good back four, long diagonals to the winger rarely work; instead quick passes with support angles ahead of the ball, a give-and-go to release a wide runner, and two players arriving at the penalty spot for the cross.',
    'Ball switched from one central player to the next at speed',
    'Defenders are pulled around by several moving players and the cross arrives before they reset.',
    NULL, 45, 45, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer A', 'Play and sprint forward to support ahead, then run into the box'),
    (2, 'Link player B', 'Open up quickly, pass on and spin around to arrive in the box'),
    (3, 'Wide player C', 'Play a wall pass, take the return in the wide area and cross early to the penalty spot')
) AS v(so, role, job);

-- 21. pp.46-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch 6 Attacking Exercise 4', 'Killer pass and second wave',
    'A short combination in front of the defence frees a player to slide a through ball for a runner timed from deep; if that ends, two players flood the box for a wide cross and another arrives at the edge of the area to strike first time.',
    'Combination draws a defender, opening a lane behind',
    'Three ways of scoring in one attack: through ball, cross, and edge-of-box shot.',
    NULL, 46, 46, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Combination players', 'Quick one-twos to free the passer'),
    (2, 'Deep runner', 'Time the run from deep onto the through ball, then sit at the box edge for a first-time strike'),
    (3, 'Box runners', 'Sprint into the box for the second-wave cross'),
    (4, 'Wide servers', 'Deliver quickly once the first attack ends')
) AS v(so, role, job);

-- 22. pp.49-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'out_of_possession', 'Ch 7 Defending - Tactical', 'Compact block, forwards as first line',
    'All eleven defend; forwards (Suarez, Tevez) are the first line and the team squeezes the space between its back line and furthest forward. When the opponent changes shape (Man United down to ten v Real Madrid 2013) the block must adjust or a spare midfielder like Modric runs the game.',
    'Opponent has the ball; opponent alters its attacking system',
    'Little space between the lines; no free man in midfield.',
    NULL, 49, 50, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Start the defending, close the first passes'),
    (2, 'Midfield line', 'Stay tight to forwards and back line, pick up any extra midfielder'),
    (3, 'Back four', 'Push up to keep the block short')
) AS v(so, role, job);

-- 23. pp.50-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'out_of_possession', 'Ch 7 What is Effective Pressure?', 'High, medium and low pressure',
    'Three distances: high pressure within a yard, aggressive, aiming to win the ball in 3-5 seconds and stopping the carrier seeing support; medium 3-5 yards to channel the carrier while help arrives (holding mids, full backs waiting for support); low over 5 yards which only blocks space and lets the carrier play anywhere. Coach must tell players where each is wanted.',
    'Distance to ball carrier and field zone',
    'Players apply the right pressure in the right area; low pressure avoided, delay used higher up not in the final third.',
    NULL, 50, 51, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'Get within a yard and attack the ball when high pressure is on'),
    (2, 'Holding midfielder', 'Use medium pressure to channel the carrier into another area'),
    (3, 'Full back', 'Hold at 3-5 yards until defensive support arrives, then commit')
) AS v(so, role, job);

-- 24. pp.51-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'to_defend', 'Ch 7 Reorganize Quickly!', 'Defend out of balance',
    'Opponents lure you forward then break; when the ball is lost the team makes recovery runs, the nearest player delays until help arrives, and numbers get back behind the ball before the space can be exploited.',
    'Possession lost with players committed forward',
    'Team is reorganised before the counter reaches goal.',
    NULL, 51, 51, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'Delay the carrier, don''t dive in'),
    (2, 'Out-of-position players', 'Sprint recovery runs goal-side'),
    (3, 'Back line', 'Communicate and organise numbers behind the ball')
) AS v(so, role, job);

-- 25. pp.51-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'out_of_possession', 'Ch 7 Final Product of Defending', 'Shift after the clearance',
    'Defending does not end at the clearance: if a defender goes long, the whole unit steps up and shifts according to how far the ball travelled; if he passes out, team mates move to give angles. Defenders stay switched on for the second wave or to join the attack.',
    'Defender clears long or chooses to play out',
    'Unit is positioned for the next attack instead of resetting passively.',
    NULL, 51, 52, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Step up and slide together in line with where the clearance landed'),
    (2, 'Defender on the ball', 'Choose long relief or a pass out'),
    (3, 'Nearby team mates', 'Move to offer passing angles if playing out')
) AS v(so, role, job);

-- 26. pp.53-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'out_of_possession', 'Ch 7 Defensive Exercises 1 and 2', 'Presser plus angled cover',
    'Small groups win the ball together: one player presses quickly, the partner drops at an angle to cut out the pass that splits them; nobody gets disconnected, and the group talks about who presses and who drops. No passive pressure.',
    'Opponent receives in a tight area',
    'Carrier''s options shrink and the group regains quickly (forfeit after 20 seconds in training).',
    NULL, 53, 54, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing player', 'Close down early and fast'),
    (2, 'Covering partner', 'Drop at an angle behind to block the splitting pass'),
    (3, 'Third defender', 'Stay connected so the group never gets split by one pass')
) AS v(so, role, job);

-- 27. pp.55-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'to_attack', 'Ch 7 Defensive Exercise 3', 'Win it, then find a pass',
    'After a regain under high pressure, defenders must find a team mate in space rather than kicking it clear; when the opponent has broken through, the first job is to take away the forward pass.',
    'Ball won inside a crowded area',
    'Regains become attacks; opponents breaking out are contained by denying forward play.',
    NULL, 55, 55, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins the ball', 'Look up and pass to an outside team mate or one who can get it there'),
    (2, 'Nearby team mates', 'Move into space to receive the first pass'),
    (3, 'Defenders facing a breakout', 'Block the forward pass to force a mistake')
) AS v(so, role, job);

-- 28. pp.56-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'out_of_possession', 'Ch 7 Defensive Exercise 4', 'Front two press, show one side',
    'When the opponent builds from the goalkeeper, a front two and four midfielders press high, cut off one side and show the play down a single flank so passes become predictable; Guardiola calling Messi his best defender illustrates attackers as first defenders.',
    'Goalkeeper plays out to a defender',
    'Force a mistake high up and attack straight away; get back to starting shape within 20 seconds if it fails.',
    NULL, 56, 56, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two', 'Press the receiving centre back and cut off the switch'),
    (2, 'Ball-side midfielders', 'Close passing angles down the side the ball is shown to'),
    (3, 'Far-side midfielders', 'Tuck in to cut support angles'),
    (4, 'Whole team', 'On a regain attack immediately; if beaten recover to start positions')
) AS v(so, role, job);

-- 29. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'out_of_possession', 'Ch 7 Defensive Exercise 5', 'Defending a 3v2 overload',
    'Opponents create overloads by forwards dropping, midfielders joining and full backs overlapping; two recovering defenders must organise fast, delay, show the carrier away from goal and take one runner out to make it 2v2.',
    'Three attackers break against two defenders',
    'Overload neutralised; no tackle or block committed until certain or inside the box.',
    NULL, 57, 57, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender nearest ball', 'Show the carrier away from goal and delay'),
    (2, 'Second defender', 'Cut off one of the other two attackers to make it 2v2'),
    (3, 'Both defenders', 'Communicate who has the ball, don''t commit until 100% sure')
) AS v(so, role, job);

-- 30. pp.59-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'to_attack', 'Ch 8 Successful Offensive Transitioning', 'Safe first pass, then move off ball',
    'Win the ball quickly, then the first pass must get the team out of the pressure area (Busquets finding team mates within two passes and setting the tempo); be quick but don''t rush; team mates move into dangerous support spaces and quick thinkers spot the forward runner early (Beckham).',
    'Possession regained',
    'Exploit an unorganised defence without giving the ball straight back.',
    NULL, 59, 60, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner / pivot (Busquets)', 'Play a secure first pass out of pressure, then set tempo'),
    (2, 'Forward runners', 'Break into spaces behind the disorganised defence'),
    (3, 'Supporting players', 'Move off the ball into dangerous areas to offer options'),
    (4, 'Passer (Beckham)', 'Pick out the advanced runner within seconds')
) AS v(so, role, job);

-- 31. pp.60-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'to_defend', 'Ch 8 Successful Defensive Transitioning', 'React, delay, get behind ball',
    'On losing the ball the player and team react at once to win it back with controlled aggression (no cheap fouls); the top priority is to stop forward play, forcing the opponent backwards or sideways; if that fails the team gets organised behind the ball as fast as possible, communicating.',
    'Possession lost',
    'Opponent''s first forward pass is denied and the team recovers numbers behind the ball.',
    NULL, 60, 60, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost it', 'React immediately, don''t dwell, try to win it back'),
    (2, 'Nearest team mates', 'Press to stop the forward pass, force it back or sideways'),
    (3, 'Rest of team', 'Recover goal-side and reorganise, talking')
) AS v(so, role, job);

-- 32. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'to_attack', 'Ch 8 Transition Exercise 1', 'Read the numbers on transition',
    'In the moment of change players read the count: with a spare player go forward quickly (or press aggressively when defending); without numbers, keep the ball (or delay and deny forward play).',
    'Possession changes while players are still arriving / leaving',
    'Superior numbers are punished quickly; equal or fewer numbers are managed safely.',
    NULL, 61, 61, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking team', 'Go forward fast with an extra man, otherwise keep possession'),
    (2, 'Defending team', 'Press hard with an extra man, otherwise delay'),
    (3, 'Players entering play', 'Get told by team mates where they are needed')
) AS v(so, role, job);

-- 33. pp.62-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch 8 Transition Exercise 2', 'Move ball from high to low pressure',
    'Possession only helps transition if the ball travels from the pressured area to a free one; inside players take new positions after each pass and receive on the half-turn to find the far side quickly, and on losing it they re-press close.',
    'Ball played to a player under pressure',
    'Ball reaches the open side before the press can shift.',
    NULL, 62, 62, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside players', 'Re-position after every pass and receive on the half-turn'),
    (2, 'Outside players', 'Two-touch maximum to keep tempo'),
    (3, 'Team that loses it', 'Get tight immediately, no ball watching')
) AS v(so, role, job);

-- 34. pp.63-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'to_defend', 'Ch 8 Transition Exercises 3 and 5', 'Vulnerable after scoring',
    'Teams switch off after scoring or around the box; the side that has just scored must refocus immediately, and the defending side must reorganise fast when play restarts quickly near goal (training adds numbers into the box within 5 seconds of a goal, creating a 5v2 the recovering players must close).',
    'Goal scored or quick restart near the goal',
    'No easy goal conceded in the seconds after a goal or restart.',
    NULL, 63, 65, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Scoring team', 'Refocus and recover into position at once'),
    (2, 'Defenders near goal', 'Organise loudly and pick up runners on the restart'),
    (3, 'Attackers', 'Exploit the seconds after a restart with quick movement')
) AS v(so, role, job);

-- 35. pp.64-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'to_attack', 'Ch 8 Transition Exercise 4', 'Everyone breaks, carrier drives diagonally',
    'On breaking out, everyone joins the attack at full speed with no one sitting as a holding player; the carrier drives diagonally rather than straight into the middle to drag defenders, and runners take high, varied positions to stretch the defence and keep penetrating.',
    'Ball won in own third',
    'Attack reaches the box before the defence sets.',
    NULL, 64, 64, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'First into the zone, drive diagonally to move defenders'),
    (2, 'Supporting runners', 'Sprint high and wide, avoid straight-line or static runs'),
    (3, 'Target player (progression)', 'Receive the ball over midfield and hold for support')
) AS v(so, role, job);

-- 36. pp.67-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'to_attack', 'Ch 9 Counter Attacking - six aspects (FA B Licence)', 'Set up, break, split, play, move up',
    'Counter attacking is not only for defensive teams (Mourinho''s Chelsea scored 42% of open-play goals from counters). Six stages: set up with numbers behind the ball and an agreed pressing area; break up (tackle, interception, poor cross); split up so players spread on regain; play up early to forwards; move up to overload; keep security behind. Counter only when the opponent is unorganised, otherwise build through possession.',
    'Ball won in the chosen pressing area against an unbalanced opponent',
    'Goal within 10-15 seconds of the regain while staying protected.',
    NULL, 67, 68, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive block', 'Sit with numbers behind ball and press in the agreed zone'),
    (2, 'Players near the regain', 'Spread out immediately to open passing options'),
    (3, 'Player on the ball', 'Play forward as early as possible; first pass quality is key (Wenger)'),
    (4, 'Supporting runners', 'Sprint forward to outnumber the defenders'),
    (5, 'Rest defenders', 'Hold balance so the team isn''t countered back')
) AS v(so, role, job);

-- 37. pp.68-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'to_attack', 'Ch 9 Making Counter Attacking Practices Realistic - Outlet Pass', 'Outlet pass away from pressure',
    'After winning the ball, dribble or pass it away from the pressure, switching the play, but the outlet must go forward; players recognise that this pass is the signal to break and adjust their runs.',
    'Regain in a congested area',
    'Ball escapes the crowd and the counter starts.',
    NULL, 68, 68, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Carry or pass out of pressure, forward'),
    (2, 'Team mates', 'Read the outlet pass as the cue to sprint forward')
) AS v(so, role, job);

-- 38. pp.70-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'to_attack', 'Ch 9 Counter Attacking Exercises 1 and 2', '3v2 counter with supporting runs',
    'When a counter becomes three against two recovering defenders, the carrier penetrates and drags a defender toward the ball to open space; supporters arrive fast and vary their runs, holding them if the defenders keep a high line; finish with combinations, overlaps, slashing runs or individual skill.',
    'Goalkeeper or defender releases a player against retreating defenders',
    'Overload converted into a shot before defenders recover.',
    NULL, 70, 71, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Run at and pull a defender to open space for supporters'),
    (2, 'Supporting runners A and B', 'Get there quickly, vary runs, stay onside against a high line'),
    (3, 'Recovering defender', 'Chase all the way; never give up the run')
) AS v(so, role, job);

-- 39. pp.72-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'to_attack', 'Ch 9 Counter Attacking Exercises 3 and 5', 'Target forward outlet and support',
    'The first counter pass is driven with pace into a target forward, to his outside shoulder so runners can go either side; one supporter offers a drop-back option while the other runs beyond to stretch the defence, both setting off as soon as the entry pass goes; a one-touch lay-off makes it hardest to stop.',
    'Possession side has a yard of space and opens its body to the target man',
    '3v2 toward goal within about 8 seconds.',
    NULL, 72, 74, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Find a yard, open body, drive pass to target man''s shoulder'),
    (2, 'Target forward', 'Hold up or lay off first time to arriving runners'),
    (3, 'Supporter 1', 'Offer the short drop pass'),
    (4, 'Supporter 2', 'Run beyond the forward to stretch the back line')
) AS v(so, role, job);

-- 40. pp.73-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'out_of_possession', 'Ch 9 Counter Attacking Exercise 4', 'Press to counter, then switch',
    'Instead of waiting for a mistake, the team presses aggressively but organised, showing opponents into dangerous areas; everyone shifts across when one player goes; pressure the goalkeeper as the opponent''s outlet; when the ball is won in a congested area, switch and attack the other goal.',
    'Opponent''s possession is shown into a trap area or goes back to the keeper',
    'Regain high and counter into the open side while the opponent is centrally packed.',
    NULL, 73, 73, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First presser', 'Close the ball and show it into the trap'),
    (2, 'Team mates', 'Shift across together behind the presser'),
    (3, 'Forward', 'Press the goalkeeper to spoil his distribution'),
    (4, 'Ball winner', 'Find a free player and switch to the open goal side')
) AS v(so, role, job);

-- 41. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'in_possession', 'Ch 10 Establish a Clear Philosophy - Rodgers decision tree', 'Rodgers in-possession decision tree',
    'Brendan Rodgers'' Liverpool framework: on just gaining the ball, make the pitch big (width and depth); with the ball, if you can play direct then penetrate (shoot, dribble, cross), otherwise keep possession with pass and move; when the ball can go direct, support runs go ahead of the ball, if not, support behind it.',
    'Team has just won or has the ball',
    'Every player follows the same yes/no logic for when to penetrate and when to keep it.',
    NULL, 78, 78, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team on regain', 'Spread for width and depth'),
    (2, 'Player on the ball', 'Penetrate if a direct option exists, else pass and move'),
    (3, 'Off-ball players', 'Run forward ahead of the ball if direct play is on, else support behind')
) AS v(so, role, job);

-- 42. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-modern-soccer-coach-2014'), 'out_of_possession', 'Ch 10 Establish a Clear Philosophy - Rodgers decision tree', 'Rodgers out-of-possession decision tree',
    'On just losing the ball, deny space, recover and get compact; the nearest player is first defender - if outnumbered he delays, otherwise he pressures; players close to him give support and cover, those further away give depth and balance.',
    'Team has just lost or does not have the ball',
    'Clear roles for first defender, cover and balance players.',
    NULL, 78, 78, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player (first defender)', 'Delay if outnumbered, otherwise press'),
    (2, 'Players close to first defender', 'Support and cover'),
    (3, 'Players further away', 'Provide depth and balance'),
    (4, 'Whole team on loss', 'Deny space, recover, compact')
) AS v(so, role, job);

COMMIT;
