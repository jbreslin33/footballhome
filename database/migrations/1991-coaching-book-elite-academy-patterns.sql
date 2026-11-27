-- 1991 📚 Coaching book patterns: "Elite Academy Coaching" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Elite Academy Coaching',
    subtitle    = 'The Secrets Behind the Development Program for Pep Guardiola''s Methodology',
    author      = 'Darren Bowman',
    team        = 'Manchester City academy (the City Way)',
    season      = '2006-2015',
    method_note = 'Manchester City''s academy game model, the City Way, from a coach who ran its U13-U15 sides 2011-15 (Foden, Sancho, Palmer among his players) and worked under Rodolfo Borrell. A 4-3-3 with principles for attacking, defending and both transitions; three build-up phases (short build-up from the keeper, midfield combination play and rotations, finishing in the final third); then 17 sessions: side diamonds and 3v2 overloads, where the winger receives deciding cross or cut-back, the Set the Trap press (phase and full-pitch man for man), the diamond-midfield press, the defensive unit arc and the back four around the box. Patterns are the game-model behaviours and what the sessions train, in our words; academy management and load tables are left out.'
WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi');

-- 1. pp.25-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Working with Rodolfo Borrell - What I Learned', 'Triangles across width and depth',
    'In possession the team keeps passing triangles everywhere across the pitch, with a dominant, balanced central midfield; players hold their zones rather than leaving position.',
    'Any phase of possession',
    'Always offer the ball carrier angled options while the team stays balanced for a loss of the ball.',
    NULL, 25, 25, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfield trio', 'Dominate the middle and give the team its balance'),
    (2, 'All outfield players', 'Hold position so triangles exist across width and depth')
) AS v(so, role, job);

-- 2. pp.30-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Game Principles - Possession with a Purpose', 'Possession with a purpose: overload, break lines',
    'Every possession action aims to create a superiority (numerical or positional) that lets the team progress, attack, score or control the tempo, depending on game situation and time; the same overloads also leave extra numbers to defend with.',
    'Each phase of possession',
    'Gain an advantage to progress, or keep control when that is the right game-state choice.',
    NULL, 30, 31, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players near the ball', 'Create a local numerical advantage around the ball'),
    (2, 'Players ahead of the ball', 'Offer line-breaking options once the overload is formed'),
    (3, 'Team as a whole', 'Choose progress vs control by score and clock')
) AS v(so, role, job);

-- 3. pp.30-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Defending Tactics - Defending in Midfield', 'Defending in midfield: small field',
    'In midfield the team protects depth and keeps the ball in front, stays narrow and compact, crowds the ball side (leaving the far side empty), always pressures the ball, shows outside and blocks forward passes and switches, using zonal positioning.',
    'Opponent in possession in the middle third',
    'Steer the ball where we want it, win it with numerical superiority and counter to score.',
    NULL, 30, 36, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'Always pressure the ball and show outside'),
    (2, 'Ball-side players', 'Create high density around the ball'),
    (3, 'Far-side players', 'Shift across, leave the opposite flank empty but block switches'),
    (4, 'All', 'Zonal positioning, see man and ball, win duels and second balls')
) AS v(so, role, job);

-- 4. pp.30-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'to_defend', 'Transition Phase Tactics - Transition from Attack to Defence', 'Immediate press after losing the ball',
    'Because players are positioned ''in between'' while in possession (one player can cover two opponents), the team reacts instantly on loss with pressure to regain or delay, holds the midfield and defensive lines instead of dropping, watches the space behind the high full backs, then recovers behind the ball into shape.',
    'Moment possession is lost',
    'Regain quickly or stop the opponent progressing, then reorganise.',
    NULL, 30, 38, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players to the ball', 'Press at once to win it or delay'),
    (2, 'Midfield and back lines', 'Hold height, do not retreat in the first moment'),
    (3, 'Centre backs / DM', 'Guard the space behind the advanced full backs'),
    (4, 'All', 'Recover goal-side of the ball into formation if the press fails')
) AS v(so, role, job);

-- 5. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Game Principles - Play Your Position / The Ball Comes to You', 'Play your position: between and behind',
    'Players hold their positional spots and let the ball travel to them rather than coming to the ball; they occupy the gaps between and behind opposition lines and arrive in them at the right moment.',
    'Team in settled possession',
    'The ball does the work, giving the carrier many options and penetrating line-breaking passes while saving energy.',
    NULL, 31, 31, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Choose among the options created by correct shape; pass to break a line'),
    (2, 'Midfielders and wingers', 'Stand in the pockets between and behind lines, time the arrival'),
    (3, 'Off-ball players', 'Do not drift towards the ball; keep the shape')
) AS v(so, role, job);

-- 6. pp.32-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Attacking Tactics - Build-up Play Phase 1: Short Build-up from the GK', 'Short build-up from the goalkeeper',
    'From goal kicks and keeper possession the centre backs split wide, the full backs push high and wide, and the defensive midfielder drops as the keeper''s third option; rotations are used to find the free player.',
    'Goalkeeper has the ball',
    'Create a spare man and the quickest route forward with all units involved.',
    NULL, 32, 33, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Split wide to receive from the keeper'),
    (2, 'Full backs', 'Push high and wide'),
    (3, 'Defensive midfielder', 'Drop between/near the centre backs as third option'),
    (4, 'Goalkeeper', 'Find the free player identified by the rotations')
) AS v(so, role, job);

-- 7. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Attacking Tactics - Build-up Play Phase 1: Long Pass = 2nd Option', 'Long pass as second option',
    'When the short build-up is blocked the keeper or defenders go long instead.',
    'Short options pressed or covered',
    'Bypass the press by finding a high target.',
    NULL, 33, 33, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper / centre backs', 'Play long when short is closed'),
    (2, 'Forward', 'Main long target'),
    (3, 'Winger or high wide full back', 'Alternative long target')
) AS v(so, role, job);

-- 8. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Attacking Tactics - Build-up Play Phase 2: Midfield Combination Play (Rotations)', 'Midfield combination play and rotations',
    'In the middle third the DM and two central midfielders hold their positions, the central midfielders receive and turn to control the centre, full backs give width as flank outlets and wingers come inside between the lines to overload the opponent''s block.',
    'Ball progressed out of the first phase into midfield',
    'Control the centre and create a numerical edge inside the opposition shape while staying ready to defend.',
    NULL, 33, 33, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Receive on the half turn and turn forward'),
    (2, 'Defensive midfielder', 'Hold position, balance, ready to defend'),
    (3, 'Full backs', 'Move up to give width and a flank outlet'),
    (4, 'Wingers', 'Play between the lines, move to create an inside overload')
) AS v(so, role, job);

-- 9. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Attacking Tactics - Build-up Play Phase 3: Inside Support Play (Centre) -> Penetration', 'Inside support play to penetrate centrally',
    'In the final third players occupy spaces between and behind the back line, combine to overload, and use opposite movements: a central midfielder comes short while others run in behind, wide players make inside diagonal runs.',
    'Ball in the final third, central access',
    'Break the last line with through balls into space behind defenders.',
    NULL, 34, 34, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'Come short to receive and draw a defender'),
    (2, 'Forward / other midfielder', 'Run in behind as the opposite movement'),
    (3, 'Wingers', 'Diagonal runs inside behind the full back'),
    (4, 'Passer', 'Play through passes into space behind')
) AS v(so, role, job);

-- 10. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Attacking Tactics - Build-up Play Phase 3: Wide Support Play -> Crossing', 'Wide support play to cross',
    'Full backs and wingers provide width; receiving wide pulls defenders out and opens space inside, and when the ball is wide the team delivers quick, dynamic crosses.',
    'Ball to a wide player in the final third',
    'Either cross early into the box or use the space opened inside.',
    NULL, 34, 34, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back / winger', 'Hold width, receive wide, cross quickly'),
    (2, 'Inside players', 'Exploit space opened inside or attack the box')
) AS v(so, role, job);

-- 11. pp.35-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Defending Tactics - Pressing from the Front', 'Aggressive high press, chain reaction',
    'The team presses high as one, adapted to the opponent''s formation and weaknesses; the front players start it by showing the opponent outside, the first trigger sets off a chain reaction behind, and others shorten spaces with a high line and compact block (high or middle block chosen by game plan).',
    'Front player''s first pressing action',
    'Win the ball back quickly high up or force a mistake.',
    NULL, 35, 35, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front players', 'Trigger the press and show the opponent outside'),
    (2, 'Midfield', 'Follow the chain reaction, close nearest options'),
    (3, 'Back line', 'Hold a high line and keep the block compact')
) AS v(so, role, job);

-- 12. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Defending Tactics - Defending Around the Box: Stop Penetrative Passes in Behind', 'Defending around the box: central T-shape',
    'Near the box the unit keeps the ball in front and positions by the ball; centrally the DM and centre backs form a ''T-shape'' for cover and depth, midfielders drop in to protect the back four and control the edge of the box, any cut-back or pass away from goal is pressed, while forwards stay in touch for balance.',
    'Opponent in possession around our box',
    'Stop passes in behind and shots from the edge of the box.',
    NULL, 37, 37, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Key piece: screen in front of the centre backs in the T'),
    (2, 'Centre backs', 'Give depth and cover behind'),
    (3, 'Central midfielders', 'Fill in, protect the back four, cover edge of box'),
    (4, 'Forwards', 'Stay connected for attacking balance')
) AS v(so, role, job);

-- 13. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Defending Tactics - Defending Around the Box: Coordination of the Back 4', 'Back four coordination against crosses',
    'The back four narrows when the ball is in the central channel; when it goes wide the full back is aggressive to stop the cross and keep the attacker outside, and the far-side full back must not play the opposite winger onside; midfielders cover the full backs and the line keeps covering teammates and marking in the box.',
    'Ball moves wide near our box',
    'Prevent crosses, keep the line tight and leave no runner unmarked.',
    NULL, 37, 37, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back', 'Engage aggressively, block the cross, keep winger outside'),
    (2, 'Far-side full back', 'Tuck in but hold the line so the opposite winger is offside'),
    (3, 'Centre backs', 'Cover each other and mark in the box'),
    (4, 'Midfielders', 'Provide cover for the full backs')
) AS v(so, role, job);

-- 14. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'to_attack', 'Transition Phase Tactics - Transition from Defence to Attack', 'Counter at once, else keep it',
    'On winning the ball the team reacts fast and goes forward straight away, using players ahead of the ball and runs beyond it; if a counter is not on, the second option is to keep possession.',
    'Moment possession is won',
    'Hit the opponent before they reorganise, or secure the ball.',
    NULL, 38, 38, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Play forward quickly to players in front'),
    (2, 'Forwards / wingers', 'Run beyond the ball into space'),
    (3, 'Supporting players', 'Offer safe options to retain if the counter is closed')
) AS v(so, role, job);

-- 15. pp.53-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 1/2/7/8 - Short build-up from the GK; one-touch triangle drills', 'Set-back third-man pass through the thirds',
    'A player receives side-on past a defender (or a pole gate), lays the ball back or sideways, and the next pass goes into a runner who started further away. This is the basic way to play through each line.',
    'Defender screens the direct forward pass',
    'Get past a line with one-touch passing and runs timed off eye contact.',
    NULL, 53, 94, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving midfielder', 'Half-turn, side-on body shape; take the first touch forward through the line or set the ball back first time'),
    (2, 'Passer (deeper player)', 'Play into feet, then take the set-back and play the forward pass'),
    (3, 'Third man / runner', 'Check away from the defender, then time a deep or overlapping run onto the through ball'),
    (4, 'All', 'Receive on the back foot; the weight of the pass breaks the line')
) AS v(so, role, job);

-- 16. pp.54-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 1 - Play inside and outside to break the line (3v3+2)', 'Always a short, medium and long option',
    'Every player keeps their position so that the man on the ball always has a short, a medium and a long pass on the ground. The team plays through the central joker into players between and behind the defenders.',
    'Teammate in possession',
    'Keep possession with purpose and get through the middle quickly rather than going round.',
    NULL, 54, 54, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central player (joker)', 'Sit between the defenders as the inside option to play through'),
    (2, 'Wide/end players', 'Hold position as the medium and long options'),
    (3, 'Ball carrier', 'Choose the forward combination quickly; pass on the floor'),
    (4, 'Off-ball players', 'Stay ready to defend the moment possession is lost')
) AS v(so, role, job);

-- 17. pp.55-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 1/2/6/8 - Attacking overload waves and duels (1v1 to 6v5, 3v2, 4v3)', 'Create and exploit overloads by combining fast',
    'In a small local area (2v1, 3v2, 4v3) attackers use quick one-twos, overlaps, diagonal runs and lay-offs to free the extra man, and the first touch changes the angle of attack. Good players can build the 3v2 themselves by timing when they join.',
    'Coach or GK serve; attack has a temporary extra man',
    'Turn the extra player into a shot before the defence gets back level.',
    NULL, 55, 96, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Commit a defender 1v1 or move the ball on; use the first touch to change the angle'),
    (2, 'Support attacker', 'Overlap or make a diagonal run timed to arrive behind'),
    (3, 'Extra/late runner', 'Join at the right moment to make the overload'),
    (4, 'All attackers', 'Decide between penetrating now and keeping the ball; pick the right finish')
) AS v(so, role, job);

-- 18. pp.59-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'to_defend', 'Session 2/5 - Dual-direction transition game; corner end-zones game', 'Fast reaction to win the ball back',
    'When possession is lost the team switches to defending at once and works to win the ball back or stop the counter before it reaches the end zone. Players stay ''ready to defend'' while attacking.',
    'Ball lost',
    'Win the ball back quickly or stop the quick counter.',
    NULL, 59, 80, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost it / nearest players', 'Press the ball straight away'),
    (2, 'Rest of team', 'Get back into shape to block the route to goal')
) AS v(so, role, job);

-- 19. pp.59-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'to_attack', 'Session 2/5/7 - Transition games (6v6 dual direction, 5v5, 2-zone SSGs)', 'Counter at once after winning the ball',
    'The moment the defending side wins the ball it attacks the far target fast. This is often a 3v2 or 5v4 before the opponent''s supporting players (for example advanced full backs) can recover.',
    'Ball won',
    'Score or reach the end zone before the two recovering players get back.',
    NULL, 59, 91, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins the ball', 'Play forward straight away into space or a forward'),
    (2, 'Nearest teammates', 'Sprint forward to make the counter overload'),
    (3, 'Defenders who were held back', 'Step up into the attacking half to join (e.g. 2 defenders move up)')
) AS v(so, role, job);

-- 20. pp.60-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 2/4/6/7 - 3v2 finish SSG; 2-zone 7v7 and 5v5 SSGs', 'Forward''s set-back triggers midfield runners',
    'The team keeps the ball patiently at the back (GK to full back, 2v1 or 4v3 in the low zone) until the right moment to play into the forward. He lays it back to a central midfielder, and that pass releases the second-line runners for a 3v2 or 5v4 attack.',
    'Clean pass into the forward''s feet',
    'Turn controlled possession into an overload in the final zone.',
    NULL, 60, 90, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (RB/LB)', 'Receive from the GK and play into the forward; stays back (not in the finish) in the basic version'),
    (2, 'Forward (F)', 'Stay high and central; set the ball back first time'),
    (3, 'Central midfielders (LCM/RCM)', 'Both break forward once the ball goes into F to join the attack'),
    (4, 'Opposite winger', 'Hold width and run in behind to finish'),
    (5, 'Progression: one full back', 'Joins to make it 4v3')
) AS v(so, role, job);

-- 21. pp.63-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 3/4 - Figure-of-8 diamond drill; side diamond circuit', 'Switch play through the DM pivot',
    'After a combination on one side, the forward sets the ball back to the defensive midfielder. He receives on the half-turn and moves it straight to the far centre back or far side to restart the attack there.',
    'One side closed or the combination is complete',
    'Change the point of attack through the centre rather than round the back.',
    NULL, 63, 69, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (DM)', 'Open body on the half-turn; play the switch with the first touch or the second'),
    (2, 'Forward (F)', 'Receive from the CM and lay it back to the DM'),
    (3, 'Far centre back / far side', 'Ready to receive and start the same pattern mirrored')
) AS v(so, role, job);

-- 22. pp.64-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 3/4 - Side and central diamond games with joker; 3-zone 7v7(+1)', 'Find the +1: DM drops, CB steps in',
    'The team uses its shape to create a spare man. The DM can drop between the centre backs (2-3-3 becomes 3-2-3), and one centre back can carry the ball into midfield. The wingers drop into the midfield pockets to overload the middle before going on to make a 3v2 in the end zone.',
    'Opponent''s forward has to pick up the dropping DM, or no one presses the CB',
    'Create a 4v3 in midfield and then a 3v2 overload to finish.',
    NULL, 64, 72, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (DM)', 'Drop between the CBs to draw a forward and free a midfield overload'),
    (2, 'Centre back', 'Step into midfield with the ball when unmarked as the +1'),
    (3, 'Central midfielders', 'Pick up the ball, turn and control the centre of the pitch'),
    (4, 'Wingers (LW/RW)', 'Play between the lines in the pockets, then break into the end zone')
) AS v(so, role, job);

-- 23. pp.64-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 3/4/5 - Side Diamond Combination (patterns of play)', 'Side Diamond Combination: CB, full back, CM, winger',
    'A centre back steps in and plays into the winger, who has come off the line to receive in the middle of the half space. The winger sets back to the central midfielder, who takes a forward touch and plays between the lines or through for the forward''s double movement. Used opposed in a 10v8 against a 4-3-1 to overload the wide area.',
    'CB steps forward with the ball and the half space is open',
    'Get a midfielder facing forward between the lines and release the forward or a runner in behind.',
    NULL, 64, 78, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (CB)', 'Take the first touch forward into space, then pass into the half space'),
    (2, 'Winger (LW/RW)', 'Time the move inside off the line; receive at the right height in the half space (not too high, not too low) and set back'),
    (3, 'Central midfielder (LCM/RCM)', 'Wait behind the screen to keep the lane open, step up for the set-back, touch forward to open all options'),
    (4, 'Forward (F)', 'Double movement to receive the through ball in behind and finish'),
    (5, 'Full back', 'Gives width and is the fourth point of the diamond')
) AS v(so, role, job);

-- 24. pp.74-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 4/5 - CMs break forward; final-third triangle drills', 'Third-man diagonal final pass to winger''s run',
    'In the final third the midfielders combine with the forward (one-two, set-back, give-and-go). A central midfielder opens up past his marker and plays a diagonal pass into the winger''s run from the far side. The finish goes across goal, first time where possible.',
    'Forward receives and sets back at the edge of the box',
    'Free a runner in behind for a quick shot across the goalkeeper.',
    NULL, 74, 77, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (CM)', 'Open up and receive past the marker, then play the diagonal final pass'),
    (2, 'Forward (F)', 'Set the ball for the CM or play a give-and-go with the winger'),
    (3, 'Winger (W)', 'Third-man run in behind; take the first touch forward and finish across goal in 2 touches at most'),
    (4, 'Defensive midfielder (DM)', 'Start the move with a pass or one-two into the CM/F')
) AS v(so, role, job);

-- 25. pp.79-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 5 - Switching play in corner end zones; 4-goal SSG', 'Keep the ball, then switch to the far zone',
    'The team stays in shape in and out of possession and moves the ball zone to zone with combinations. Once enough passes have pulled the opponent over, it switches play to the far corner or attacks the open goal.',
    'Opponent shifted to the ball side; pass target reached',
    'Attack where the opponent is not, while controlling the tempo.',
    NULL, 79, 80, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central players', 'Circulate and combine to draw the opponent over'),
    (2, 'Corner/wide players', 'Bounce the ball back with one touch and stay ready for the switch'),
    (3, 'All', 'Ready to attack and ready to defend; control the tempo')
) AS v(so, role, job);

-- 26. pp.83-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 6/7/8/9 - Crossing rules (functional overloads)', 'Where the winger receives decides the cross',
    'The wide player''s crossing area sets the delivery. From the wide channel he crosses to the front post (forward) or back post (far winger). From the zone near the byline inside the box he cuts it back to a central midfielder arriving at the edge of the box.',
    'Winger dribbles or receives in behind out wide',
    'Give the delivery that suits the angle, with every finishing zone filled.',
    NULL, 83, 99, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger / crosser', 'Wide zone: cross front or back post; byline zone: cut back'),
    (2, 'Forward (F)', 'Attack the front post'),
    (3, 'Opposite winger', 'Attack the back post'),
    (4, 'Central midfielders (LCM/RCM)', 'Arrive at the edge of the box for the cut-back')
) AS v(so, role, job);

-- 27. pp.89-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 7/8 - Central Diamond pattern of play', 'Central Diamond: DM, CMs and forward',
    'The DM plays to an attacking midfielder in the half space, who plays to the forward. The forward has come short between the opponent''s DM and CB, sets back, then spins to time his run into the box. The midfielder plays into the winger''s feet or in behind for the cross, with an overlapping full back as an option.',
    'Forward free between DM and CB',
    'Get the ball wide in behind with runners arriving in the box.',
    NULL, 89, 95, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (DM)', 'Take a touch forward and pass into either CM in the half space'),
    (2, 'Central midfielders (LCM/RCM)', 'Combine with F; set left with the left foot and right with the right; touch forward, then feed the winger'),
    (3, 'Forward (F)', 'Receive between DM and CB, set back, spin into the box (front post)'),
    (4, 'Winger (LW/RW)', 'Receive to feet or in behind; can come inside to free the full back''s overlap'),
    (5, 'Opposite winger', 'Attack the back post')
) AS v(so, role, job);

-- 28. pp.91-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 7 - Position-specific 7v7 2-zone SSG', 'Full backs push on to overload the front',
    'When the ball reaches the front three, both full backs move up to make 5v4 in the attacking zone. This leaves 2v3 behind, so the attack has to finish or protect the ball, because a turnover gives the opponent a quick 3v2 counter.',
    'Clean entry into the front three',
    'Outnumber the opponent''s back four, knowing the rest defence is exposed.',
    NULL, 91, 91, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (LB/RB)', 'Push forward to join the attack once the ball is played into the front 3'),
    (2, 'Centre backs', 'Stay as the 2 behind the ball against the opponent''s counter'),
    (3, 'Front three', 'Hold the ball in the high zone until the full backs arrive')
) AS v(so, role, job);

-- 29. pp.97-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 8 - Patterns of play in 8v8 (4-3-1 vs 3-3-2); Session 3 10v8', 'Forward pass blocked: go via full back',
    'When the opponent''s forward blocks the centre back''s pass into midfield, the ball goes wide to the full back. He plays into the forward, who sets back to a central midfielder, and that midfielder plays through for the other midfielder''s deep run. The team keeps choosing the pattern that makes an overload, even at equal numbers. The opponent here is a 3-3-2 (not a listed shape).',
    'Central lane closed by the opponent''s forward',
    'Get round the first press and go through with a third-man deep run.',
    NULL, 97, 97, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (CB)', 'Play out to the full back when the direct pass is blocked'),
    (2, 'Full back (LB)', 'Play the forward pass into F'),
    (3, 'Forward (F)', 'Set the ball back for the near CM'),
    (4, 'Near CM (LCM)', 'Play a through pass first time'),
    (5, 'Far CM (RCM)', 'Make the deep run in behind')
) AS v(so, role, job);

-- 30. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 9 - Switching play and attacking combination in the final third', 'Forward lay-off switches play to the far CM',
    'The full back plays inside to a central midfielder, who passes to the forward. The forward sets the ball for the other, oncoming midfielder, who takes a forward touch and plays to the winger near the touchline or through into the zone near the byline. The winger''s movement decides whether the ball goes to feet or in behind.',
    'Forward receives centrally facing his own goal',
    'Move the attack across to the far flank and finish from a cross or cut-back.',
    NULL, 99, 99, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (LB)', 'Start the move inside to the near CM'),
    (2, 'Forward (F)', 'Set the ball back for the far CM'),
    (3, 'Far CM (RCM)', 'Touch forward; pass to the winger''s feet or in behind as he moves'),
    (4, 'Winger (RW)', 'Dribble into the wide zone and cross, or cut back from the byline zone')
) AS v(so, role, job);

-- 31. pp.100-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 9 - Winger receiving inside + overlapping full back', 'Winger tucks inside, full back overlaps',
    'The winger moves inside into the half space to receive and sets back to the central midfielder, which empties the flank. The midfielder plays in behind for the full back''s overlapping run, and the full back crosses to the back post or cuts back.',
    'Winger draws his marker inside',
    'Use the full back to exploit the space left on the flank.',
    NULL, 100, 100, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (RW)', 'Come inside to the half space, receive and set back to the CM'),
    (2, 'Central midfielder (RCM)', 'Touch forward and pass in behind for the full back'),
    (3, 'Full back (RB)', 'Overlap, then cross to the back post or cut back to a CM or F'),
    (4, 'Opposite winger (LW)', 'Attack the back post'),
    (5, 'Forward (F)', 'Available for the cut-back to score')
) AS v(so, role, job);

-- 32. pp.101-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 9 - Build-up, Midfield Combinations + Finish the Attack', 'Diamond shape to break the line',
    'Small-sided possession where the attacking team keeps a diamond shape and looks to penetrate the opponent''s block by playing into a teammate between the lines or in the end zone behind.',
    'Defender is out of position or a lane opens through the block',
    'Break the defensive line with a penetrating pass or a line-breaking first touch, then keep the ball and go again the other way.',
    NULL, 101, 101, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Dribble in and look for the pass through the defenders'),
    (2, 'Supporting players', 'Hold diamond: one behind, one ahead, two wide, between and behind the opponents'),
    (3, 'Receiver between lines', 'Let the ball come to you, take first touch forward past the line'),
    (4, 'All', 'Ready to defend the moment the ball is lost')
) AS v(so, role, job);

-- 33. pp.102-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 9 - Build-up, Midfield Combinations + Finish the Attack', 'Two-channel 3v2 with inside diagonal runs',
    'Attack played in only two vertical channels (wide + central) by full back, winger, central midfielder and forward against two defenders; wide players run diagonally inside into space behind.',
    'Full back one-two with winger, pass into forward''s feet',
    'Create a 3v2 in a narrow strip and finish via a lay-off and through pass, with a late midfield run.',
    NULL, 102, 102, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (RB)', 'Start with a one-two with the winger, then feed the forward'),
    (2, 'Winger (RW)', 'Sprint inside on the diagonal to take the forward''s lay-off and play through'),
    (3, 'Forward (F)', 'Lay the ball off, then follow in for rebounds'),
    (4, 'Central midfielder (LCM)', 'Late penetrating run beyond to finish')
) AS v(so, role, job);

-- 34. pp.103-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 9/10 - Attacking Overloads (2-zone 5v5, back-to-back goals 5v5)', 'Patient build then 3v2 attacking overload',
    'Team builds in a 2v1 low zone then, at the right moment, plays into the forward, who lays off for a wide player arriving from outside so three attack two; or creates the 3v2 anywhere through fast combinations.',
    'Forward free to receive / the right moment to play forward',
    'Turn controlled possession into a 3v2 and score, with the far winger running in behind.',
    NULL, 103, 108, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs + GK', 'Keep controlled possession 2v1 until the pass into the forward is on'),
    (2, 'Forward (F)', 'Receive and set the ball back for an arriving wide player'),
    (3, 'Near winger (LW)', 'Join from the outside, take a forward touch, attack'),
    (4, 'Far winger (RW)', 'Hold width on the far side then run in behind to score')
) AS v(so, role, job);

-- 35. pp.105-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 10/14 - Final Third Combination + Cross (City rule)', 'Set, wide release, receive zone decides cross',
    'Midfielder plays into the forward who sets for the oncoming central midfielder; he releases the winger. Where the winger takes the ball decides the finish: deep wide zone = cross to front/back post, half-space zone at box edge = cut-back.',
    'Forward''s lay-off to oncoming CM; winger''s receiving area',
    'Final-third chance from a cross or cut-back with the right box occupation for each.',
    NULL, 105, 126, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (F)', 'Set the ball back, then attack the front post'),
    (2, 'Central midfielder (RCM/LCM)', 'Touch forward, pass to winger''s feet or in behind depending on his run; arrive edge of box for cut-backs'),
    (3, 'Ball-side winger', 'Dribble to the wide zone and cross, or receive in the small half-space zone and cut back'),
    (4, 'Far-side winger', 'Attack the back post'),
    (5, 'Full back', 'Variation: overlap to deliver instead')
) AS v(so, role, job);

-- 36. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 10 - Runs from Deep in Behind the Defensive Line', 'Half-turn receive, aerial ball for deep run',
    'A central midfielder receives on the back foot (half-turned) and plays a diagonal ball over the line for the other central midfielder timing a straight run between full back and centre back.',
    'CM receives half-turned with space to pass forward',
    'Midfield runner arrives behind the line and finishes in two touches; alternative: release a winger to cross with three runners.',
    NULL, 106, 106, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving CM (RCM)', 'Open up on the back foot and play in behind in max two touches'),
    (2, 'Running CM (LCM)', 'Time a straight run between FB and CB, control and finish'),
    (3, 'Wingers', 'Option 2: receive wide and cross'),
    (4, 'Three other attackers', 'Fill the box on the cross')
) AS v(so, role, job);

-- 37. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 10 - Side Diamond Patterns in a 10v8 Functional Practice', 'Side Diamond overload in wide areas',
    '4-3-3 attacking a back four plus midfield (shown vs a 4-3-1) uses its numerical advantage by forming a side diamond (CB, FB, CM, winger) on one flank to overload, receive between the lines and play through for the forward.',
    'Ball reaches a CB or FB with the side diamond formed',
    'Overload the wide area, find the player between the lines, then a through pass for the forward''s run.',
    NULL, 107, 107, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Start the pattern from the side'),
    (2, 'Winger (LW)', 'Receive between the lines and set'),
    (3, 'Central midfielder (LCM)', 'Take the set and play the through ball'),
    (4, 'Forward (F)', 'Run in behind to finish')
) AS v(so, role, job);

-- 38. pp.110-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 11 - Side Diamond when Forward Pass is Blocked', 'Side Diamond Combination when CB is pressed',
    'When the centre back''s pass forward is shut by a pressing opponent, the full back drops level with him and plays into the forward, who sets for the oncoming central midfielder; the other CM runs in behind.',
    'Opponent steps across to block the CB''s forward pass',
    'Bypass the press via the full back and forward and release a midfield runner into the box.',
    NULL, 110, 111, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Step forward; when blocked, pass to the full back'),
    (2, 'Full back (LB)', 'Be level with the CB, then play into the forward'),
    (3, 'Winger (LW)', 'Stay high and wide to open the channel'),
    (4, 'Forward (F)', 'Drop and set for the oncoming CM'),
    (5, 'Ball-side CM (LCM)', 'Open-up touch (not first time), then diagonal pass into the box'),
    (6, 'Far CM (RCM)', 'Penetrating run between the centre backs to finish')
) AS v(so, role, job);

-- 39. pp.112-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Session 11/15 - Defensive Organisation and Pressing (4v4+3)', 'Defensive diamond forcing play wide',
    'A unit of four (forward, two CMs, DM) defends as a diamond against a team with extra jokers, stopping passes through the centre and steering the ball down the sides.',
    'Ball in front of the diamond; angles to close',
    'Deny central penetration, create 1v1/2v2s on the side, win the ball and swap roles.',
    NULL, 112, 132, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Press, close angles back into the centre'),
    (2, 'Central midfielders', 'Close passing lanes, press together with right distances'),
    (3, 'Defensive midfielder', 'Protect space behind, keep ball in front'),
    (4, 'Unit', 'Know when to press and when to drop and regroup')
) AS v(so, role, job);

-- 40. pp.113-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Session 11 - Pressing from the Front to ''Set the Trap'' (6v8 phase)', 'Set the Trap: forward curves press wide',
    'Opponent GK plays out to a CB; our CM steps onto their DM so the forward is free to press, curving between the CBs to force play one way, wide, where the near winger presses the full back.',
    'GK pass to a centre back',
    'Make the build-up predictable so the coordinated press can win the ball wide.',
    NULL, 113, 113, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (RCM)', 'Step forward to mark their DM, releasing the forward'),
    (2, 'Forward (F)', 'Position between the CBs, show play one way wide, then press'),
    (3, 'Near winger (LW)', 'Press the full back as the ball travels wide'),
    (4, 'Near CM (LCM)', 'Mark his opponent tightly'),
    (5, 'Defensive midfielder', 'Balanced position marking their forward and covering LCM'),
    (6, 'Far winger (RW)', 'Tuck into a balanced spot to discourage the switch')
) AS v(so, role, job);

-- 41. pp.114-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Session 11 - Defending in Midfield (5v5+1, 4-goal SSG)', '2-1-2 block, trigger sets chain reaction',
    'Outnumbered midfield unit holds a 2-1-2 shape, keeps the ball in front and protects the depth; once the first player presses, the rest follow in a chain to win the ball.',
    'First pressing trigger by the nearest player',
    'Force the ball where we want it, win it and counter quickly to score.',
    NULL, 114, 114, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two', 'Show the ball where we want it, first press'),
    (2, 'Middle player (DM)', 'Protect the depth and screen'),
    (3, 'Back two', 'Step in as the chain reaction follows'),
    (4, 'All', 'On regain, attack the other goals fast')
) AS v(so, role, job);

-- 42. pp.116-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 12 - Side Diamond to Receive Between Lines + Overlap', 'Winger in half-space, set, overlap cross',
    'From a short GK pass the CB plays forward into the winger, who has dropped off the line into the middle of the half-space; he sets for the CM, who plays in between FB and CB for the overlapping full back to cross.',
    'CB steps forward with the ball; winger free in half-space',
    'Break the midfield line through the half-space and deliver from the overlap with forward and far winger attacking the box.',
    NULL, 116, 116, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Switch across; the receiving CB steps forward and passes into the half-space'),
    (2, 'Winger (RW)', 'Drop off the line inside, receive in the middle of the half-space, set back'),
    (3, 'Central midfielder (RCM)', 'Open-up touch, slide pass between FB and CB'),
    (4, 'Full back (RB)', 'Overlapping run and cross'),
    (5, 'Forward + far winger', 'Attack the box')
) AS v(so, role, job);

-- 43. pp.117-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'to_defend', 'Session 12/13 - Pressing with a Numerical Disadvantage (2-zone transition)', 'Sprint across to press outnumbered',
    'When the opponent wins the ball and switches it into the other zone, two to four of our players sprint over to press a larger group there.',
    'Ball lost and transferred to the other zone',
    'React instantly, create even numbers around the ball (1v1, 2v2) and regain before the opponent strings passes together.',
    NULL, 117, 122, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest 2-4 players', 'Sprint across and press collectively'),
    (2, 'Pressers', 'Make numbers even around the ball'),
    (3, 'Rest of team', 'Keep shape out of possession'),
    (4, 'After regain', 'Move the ball quickly to a free teammate in the other zone')
) AS v(so, role, job);

-- 44. pp.118-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Session 12/15 - ''Set the Trap'' in a Full Man for Man Press (10v10)', 'Set the Trap man-for-man press',
    'Full-pitch man-to-man version: CM marks their DM to release the forward; the other CM sprints to press the CB in possession, the DM picks up their CM, the CB steps to their forward, the near winger presses the full back and our full back steps onto their winger.',
    'GK plays to a CB; ball then played to their full back',
    'Equal numbers (4v4) around the ball on one side to win it and counter, with the back line shifted and far winger dropped to stop the switch.',
    NULL, 118, 134, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (RCM)', 'Mark their DM, releasing the forward to press'),
    (2, 'Other CM (LCM)', 'Sprint out to press the ball-side CB'),
    (3, 'Defensive midfielder', 'Mark their central midfielder'),
    (4, 'Near-side CB + winger + full back', 'CB steps to their forward; winger presses FB; FB steps to their winger'),
    (5, 'Far CB + far full back', 'Shift across for balance at the back'),
    (6, 'Far winger', 'Drop back to block the switch')
) AS v(so, role, job);

-- 45. pp.119-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Session 12 - Pressing from the Front in a Compact Block (3-team 6v6)', 'Compact press, far CM left free',
    'Press from the front, showing the opponent outside, in a compact block with a high line; the leading CM presses while blocking the pass to the far CM, creating an overload around the ball.',
    'Angles and distances of the units right; first player presses',
    'Overload around the ball (e.g. 5v2) and win it; the far-side midfielder can stay unmarked because the pass to him is hard.',
    NULL, 119, 119, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing CM (RCM)', 'Lead the press and cut off the pass to their other CM'),
    (2, 'Forward', 'Show opponents outside'),
    (3, 'Other midfielders', 'Squeeze to the ball side'),
    (4, 'Centre backs', 'Hold a high line behind the compact block')
) AS v(so, role, job);

-- 46. pp.121-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 13 - Winger Comes Inside to Set', 'Winger inside, set, forward opens up',
    'The CB steps forward and finds the winger coming inside at an angle; the winger sets for the CM, who is already positioned inside his marker and moves forward as the CB passes; the CM''s forward touch opens both sides and he finds the forward.',
    'CB pass into the winger; passing channel to CM open',
    'Break the line and give the forward the ball, who opens his body to shoot across goal into the far corner.',
    NULL, 121, 121, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Step forward with the ball and pass to the winger'),
    (2, 'Winger (RW)', 'Come off the line at the right angle and lay off'),
    (3, 'Central midfielder (RCM)', 'Sit inside the defender, first touch forward, then pass'),
    (4, 'Forward (F)', 'Stay high and central first, then open up to receive wide of the defender and finish')
) AS v(so, role, job);

-- 47. pp.123-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Session 13 - Defending Outnumbered (2v1 to 6v5, 3v2 back-to-back)', 'Defending overloads: close, show away',
    'Defenders facing attacks with one extra man close down fast to even the numbers near the ball, force play one way away from goal and sit in balanced cover positions.',
    'Attack with numerical advantage starts',
    'Delay and steer the overload so it never becomes a clean 3v2 on goal; win it and counter.',
    NULL, 123, 124, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'Close down quickly and force play one way'),
    (2, 'Covering defenders', 'Balanced positions to cover players and protect depth'),
    (3, 'All', 'See man and ball, communicate when to press and when to drop')
) AS v(so, role, job);

-- 48. pp.127-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Session 14 - Possession Play and Pressing in a 3-Team Transition Game', 'Press group plus central screen',
    'When the ball goes into an end zone three of our players run in to press while two hold the middle zone to cut out any pass played through.',
    'Ball played into the opponent''s zone',
    'Win the ball before they complete three passes or play through the middle.',
    NULL, 127, 127, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three pressers', 'Run in and press the ball zone'),
    (2, 'Two middle players', 'Screen and intercept passes through'),
    (3, 'Team on regain', 'Switch roles and keep possession')
) AS v(so, role, job);

-- 49. pp.128-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Session 14/15 - Pressing from the Front with Diamond Midfield', 'Diamond midfield press keeps 3v3 central',
    'In a diamond midfield variation, the forward pushes play to one side, the ball-side CM marks their DM and releases our attacking midfielder to press; the forward can also press the CB while blocking the pass back to GK or other CB.',
    'GK plays out to a full back or CB receives',
    'Keep 3v3 (or 4v3) in the central area when the ball goes wide, win it and counter; may allow an initial 3v1 build-up then press at the right moment.',
    NULL, 128, 133, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (F)', 'Force play one side; create 1v1 by blocking pass to GK/other CB'),
    (2, 'Ball-side CM (RCM)', 'Step onto their DM, releasing the ACM'),
    (3, 'Attacking midfielder (ACM)', 'Press the ball'),
    (4, 'Far CM (LCM) + DM', 'LCM marks tightly; DM marks their ACM and can cover the unmarked far CM as the ball travels'),
    (5, 'Full backs', 'Ball-side FB steps up; far FB tucks across leaving 3v1/2v1 vs their forward')
) AS v(so, role, job);

-- 50. pp.136-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Session 16 - Defending Around the Box and the Defensive Unit Arc', 'Defensive Unit Arc: close down and cover',
    'Back four reacts to where the ball goes: pass into a forward = nearest CB closes him down and the others tuck in to cover; ball back to the DM = reset; ball wide to a winger = full back presses and the other three shift across in an arc.',
    'Each pass to a new opponent (forward, DM, winger)',
    'Keep the ball in front and make it as hard as possible to play in behind the line.',
    NULL, 136, 137, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest centre back', 'Close down the forward receiving'),
    (2, 'Ball-side full back (LB)', 'Press the winger when the ball goes wide'),
    (3, 'Other three defenders', 'Move inside to cover / shift together into the arc, 10-12 yards apart'),
    (4, 'Back four', 'Travel while the ball travels; body shape for 1v1s and aware of others'' body shape')
) AS v(so, role, job);

-- 51. pp.138-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'in_possession', 'Session 16 - 8v4 Attacking Overload Possession Game', 'Round or through: purposeful possession',
    'Possession with a big overload where outside players play one-touch; players must judge when to circulate around the block and when to play through it, controlling tempo.',
    'Opponent shifts to cover one side / gap appears',
    'Keep the ball with purpose and penetrate when it is on; react instantly on loss.',
    NULL, 138, 138, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside players', 'One touch, quick support'),
    (2, 'Inside players', 'Create space and offer through the block'),
    (3, 'All', 'Control tempo; ready to defend on transition')
) AS v(so, role, job);

-- 52. pp.139-143
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Session 16/17 - Back 4 Defending Around the Box (6v4, 8v6, 8v8)', 'Back four compact around the box',
    'Back four (plus DMs) keeps a compact shape in front of the box, with angles and distances set by the ball''s position: tight and narrow when the ball is central, arc when it is wide, dropping when a winger dribbles and crosses.',
    'Ball switched left/right by their DM; winger runs at the line',
    'Protect the space behind, keep the ball in front, win it and play out to the target.',
    NULL, 139, 143, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Arc when ball wide, compact when central, protect the depth'),
    (2, 'Ball-side defender', 'Press the ball carrier'),
    (3, 'Defensive midfielders', 'Screen in front of the line and tighten centrally'),
    (4, 'All', 'Communicate when to press and when to drop off')
) AS v(so, role, job);

-- 53. pp.142-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Session 17 - Defending First and Second Phase Long Passes and Crosses', 'Clear long ball, reset for second ball',
    'Back four defends a long pass from a full back, then readjusts for a second-phase cross from either side; with no pressure on the passer the line drops a few yards.',
    'No pressure on the ball / long pass struck',
    'Clear high and wide or out of play, then reorganise quickly for the second phase.',
    NULL, 142, 142, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Drop when the ball is unpressured'),
    (2, 'Clearing defender', 'Head or volley high and wide away from pressure'),
    (3, 'Unit', 'Readjust fast to defend the next cross')
) AS v(so, role, job);

-- 54. pp.144-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Session 17 - Defending the Box from Crosses', 'Centre backs defend crosses, then build',
    'Two centre backs drop into position relative to the ball as a winger attacks his full back and chooses whipped, lofted or cut-back delivery; GK sets his position and communicates.',
    'Ball played wide to the winger',
    'Clear back the way the ball came, or better, control and start the build-up via the DM; GK catches and throws to DM.',
    NULL, 144, 144, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Stay in line with the ball, anticipate, clear with head or volley back where it came from'),
    (2, 'Centre back on clean ball', 'Control and pass to DM to start build-up'),
    (3, 'Goalkeeper', 'Start position relative to ball, communicate, decide catch or punch, distribute to DM')
) AS v(so, role, job);

-- 55. pp.145-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'elite-academy-coaching-the-secrets-behind-the-development-program-for-pep-guardi'), 'out_of_possession', 'Session 17 - Zonal 2v3 Defensive Organisation', 'Centre-back pair stops central pass',
    'Two centre backs defend a 3v2 after their DM plays to a side, working as a pair to stop the ball going into the forward and forcing it down the side; when switching is added, the full back four works as one unit.',
    'Their DM plays the ball to one side',
    'Deny the central pass, keep ball in front and depth protected, win it and play to the DM target.',
    NULL, 145, 145, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (pair)', 'Block the pass into the forward, keep angles and distances'),
    (2, 'Deepest defender', 'Lead communication and organisation'),
    (3, 'Pressing defender', 'Press when angles are right, drop when not'),
    (4, 'Back four (progression)', 'Shift together when play is switched via DM')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1991-coaching-book-elite-academy-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
