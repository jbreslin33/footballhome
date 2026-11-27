-- 1971 📚 Coaching book patterns: "Del Bosque, Emery, Benitez & Luis Enrique" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Del Bosque, Emery, Benitez & Luis Enrique',
    subtitle    = 'Practices and Training Sessions',
    author      = 'SoccerTutor.com',
    team        = 'Del Bosque (Real Madrid / Spain), Emery (Sevilla / PSG / Arsenal), Benítez (Liverpool / Napoli), Luis Enrique (Roma / Barcelona)',
    method_note = 'Four Spanish coaches, each with an interview or profile, match analysis and practices from their own sessions. Del Bosque: his shapes (5-3-2, 4-3-3 single pivot, 4-2-3-1, 4-1-4-1), fast circulation through triangles, Y-shape combinations, play through the centre. Emery: speed of counter after a regain, back-three shapes to overload, build-up and final-third routines. Benítez: switching along the back line for a far-side 2v1, collapsing on a player between the lines, Napoli circulation practices. Luis Enrique: Barcelona''s front three v PSG, flank one-twos and three-man rotations, Roma and Barcelona positional practices and counter-press. Patterns are the match behaviours the analyses and practices train, in our words; warm-ups and technique drills are left out.'
WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions');

-- 1. pp.11-11
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Interview with Vicente Del Bosque', 'Back three with wing-backs (5-3-2)',
    'Against a specific strong opponent Del Bosque switched from a back four to three centre backs, with full backs pushed up as wing-backs, three midfielders and two forwards.',
    'Opponent-specific big match (Champions League knockout)',
    'Extra cover centrally while wing-backs still give width up the flanks.',
    NULL, 11, 11, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three centre backs (Karanka, Hierro, Ivan Campo)', 'Hold the middle, spare man covers'),
    (2, 'Wing-backs (Salgado, R. Carlos)', 'Provide all the width, run the full flank'),
    (3, 'Midfield three (McManaman, Redondo, Raul)', 'Redondo anchors, others link forward'),
    (4, 'Front two (Anelka, Morientes)', 'Pin the centre backs')
) AS v(so, role, job);

-- 2. pp.12-12
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Del Bosque''s 4-3-3 Real Madrid Formation with 1 Defensive Midfielder', 'Lone pivot covers, forwards rotate wide-central',
    'In a 4-3-3 one holding midfielder covers both flanks depending on where the full backs are; the creative wide forward looks to receive between the lines while the centre forward drifts wide and the other forward fills the striker slot.',
    'Full back advances / striker leaves the centre',
    'Keep balance behind the ball while creating rotation and between-the-lines receptions up front.',
    NULL, 12, 12, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Single holding midfielder (Makelele)', 'Shift to cover the side of the advanced full back'),
    (2, 'Central midfielders (McManaman, Redondo)', 'Conventional link play either side of pivot'),
    (3, 'Creative wide forward (Savio)', 'Receive between the lines'),
    (4, 'Centre forward (Morientes)', 'Move wide to offer a passing option'),
    (5, 'Inside forward (Raul)', 'Move into the vacated centre-forward spot'),
    (6, 'Left back (R. Carlos)', 'Overlap outside the wide forward')
) AS v(so, role, job);

-- 3. pp.12-13
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Del Bosque''s 4-2-3-1 / 4-1-4-1 Real Madrid Formations', 'Wide attacker tucks in, full back overlaps',
    'In both the 4-2-3-1 and the playmaker-led 4-1-4-1, the left-sided attacker or playmaker moves inside off the flank and the left back runs on the overlap to take the width.',
    'Wide attacker drifts inside with or without the ball',
    'Create a central overload while the overlapping full back attacks the space left outside.',
    NULL, 12, 13, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left-sided attacker / playmaker (Raul, Zidane)', 'Drift inside to combine centrally'),
    (2, 'Left back (R. Carlos)', 'Advanced overlapping run to hold the width'),
    (3, 'Holding midfielder(s) (Makelele, Helguera)', 'Stay behind to cover the full back''s space')
) AS v(so, role, job);

-- 4. pp.13-13
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Del Bosque''s 4-2-3-1 Real Madrid Formation with 2 Defensive Midfielders', 'Double pivot frees three attackers',
    'Two defensive midfielders sit together so three attacking players can play behind one centre forward.',
    'Need for more attackers without losing protection',
    'Free three creators to attack behind the striker while the pivot pair secures rest defence.',
    NULL, 13, 13, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Double pivot (Makelele, Helguera)', 'Screen the back four, recycle play'),
    (2, 'Three attacking midfielders (Figo, Guti, Raul)', 'Play behind and around the striker'),
    (3, 'Centre forward (Morientes)', 'Fix the centre backs, reference point')
) AS v(so, role, job);

-- 5. pp.19-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Real Madrid Passing Drills / Training Sessions 1-2', 'Fast circulation through support triangles',
    'In tight possession the team spreads for width and depth, forms triangles around the ball and moves after every pass, using one or two touches.',
    'Team has the ball under pressure',
    'Keep the ball moving quickly so pressure never settles, with passes played ahead of the receiver.',
    NULL, 19, 26, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Driven ground pass into the receiver''s path, one touch where possible'),
    (2, 'Nearest supporters', 'Form a triangle, open angle, signal where you want it'),
    (3, 'Receiver', 'Check away, receive half-turned with head up'),
    (4, 'Far players', 'Stretch width and depth to keep space big')
) AS v(so, role, job);

-- 6. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Real Madrid Training Session 1: 6 (+2) v 6 (+2) Possession Game with Rotating Outside Players', 'Pass and swap with the end player',
    'When an inside player passes to a teammate stationed at the end of the area, that teammate steps in and the passer takes his spot, so positions rotate after the pass.',
    'Pass played to the outside/end player',
    'Rotate positions without losing shape and offer fresh support angles straight after the pass.',
    NULL, 23, 23, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Move out to take over the vacated end position'),
    (2, 'End player', 'Enter the area and continue the move'),
    (3, 'Inside teammates', 'Re-form support angles for the new ball holder')
) AS v(so, role, job);

-- 7. pp.24-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Playing Forward Quickly (Sessions 1-3, incl. Del Bosque''s Favourite Practice)', 'Play forward quickly, extra man joins',
    'Build-up uses a numbers-up first line (a midfielder may drop in to make it), then the middle zone is only a passage: the ball goes quickly with one touch into the forwards, and one midfielder breaks forward to make the final attack numbers-up. A variant goes out to a free wide full back first.',
    'Ball won by the back line / goalkeeper starts play',
    'Reach the final zone fast with an overload before the defence can reorganise.',
    NULL, 24, 32, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping midfielder', 'Drop into the first line to create a spare man in build-up'),
    (2, 'Middle-zone players', 'Open body, one-touch driven pass into the high zone'),
    (3, 'Advancing midfielder', 'Run forward to join the attack and make it numbers-up'),
    (4, 'Forwards', 'Check away from markers to open a passing lane'),
    (5, 'Wide full back (variant)', 'Receive the free ball wide and play it into the attacking half')
) AS v(so, role, job);

-- 8. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'out_of_possession', 'Real Madrid Training Session 3: Dynamic Game with 2 Opposite Facing Goals', 'Block goal path and mark next receivers',
    'When the opponent has the ball near goals that can be attacked from either side, defenders press together, cut off the route to goal and mark whoever could receive the next pass.',
    'Opponent in possession within shooting range',
    'Deny the shot and win the ball to counter and score.',
    NULL, 30, 30, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Presser', 'Close the ball and block the line to goal'),
    (2, 'Covering defenders', 'Mark the likely next receivers tightly'),
    (3, 'Attackers in possession (mirror rule)', 'Shoot as soon as a yard of space opens')
) AS v(so, role, job);

-- 9. pp.34-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Real Madrid Training Session 4: Passing Y Shape', 'Y-shape one-two to wide forward cutting in',
    'A midfielder plays a one-two with a forward who has checked off his marker, then a first-time pass reaches the wide forward who checks out and comes inside to shoot; in the variant the lay-off player turns, runs on, gets the lay-off back and finds the opposite forward cutting in.',
    'Forward checks away and shows for the ball',
    'Unlock the edge of the box with quick one-touch combinations ending in a shot on the move.',
    NULL, 34, 35, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep midfielder (A)', 'One-two then first-time pass to the wide forward'),
    (2, 'Target forward (B)', 'Check off marker, lay off, then turn and run on (variant)'),
    (3, 'Wide forward (C/D)', 'Check outside, cut inside onto a pushed first touch and shoot')
) AS v(so, role, job);

-- 10. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Real Madrid Training Session 4: Playing Out from the Back', 'Short combinations or direct forward pass',
    'The goalkeeper starts play to a full back and the team works rehearsed midfield combinations to move it forward, but defenders may instead play a long direct ball straight to a forward when it is on.',
    'Goalkeeper has the ball; opponent leaves space behind or presses midfield',
    'Balance short and long game to move the ball from back to front by the best route.',
    NULL, 36, 36, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Start play out wide to the full back'),
    (2, 'Full back', 'Combine inside with midfield or hit the forward directly'),
    (3, 'Central midfielders', 'Offer staggered short options to progress'),
    (4, 'Forward', 'Run the channel for the long option')
) AS v(so, role, job);

-- 11. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Real Madrid Training Session 4: Playing Through the Centre and Fast Attacks', 'Through the centre to the 9, wingers break',
    'In a 4-3-3 the team must keep the ball through its central midfield and wingers and then find the striker; once he receives, both wingers sprint forward to support and full backs may overlap.',
    'Pass into the striker',
    'Turn central possession into a fast attack with immediate support around the striker.',
    NULL, 37, 37, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Keep moving to open a passing line to receive'),
    (2, 'Wingers', 'Leave the midfield zone and make direct runs forward to support'),
    (3, 'Central midfielders', 'Circulate centrally until the striker pass is on'),
    (4, 'Full backs', 'Overlap to add width to the attack')
) AS v(so, role, job);

-- 12. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'to_attack', 'Real Madrid Training Session 4: Playing Through the Centre and Fast Attacks', 'Central regain launches fast break',
    'When the defending side wins the ball inside the congested central area, it attacks the goal immediately instead of building.',
    'Ball won in central midfield',
    'Strike while the opponent''s shape is open after losing the ball.',
    NULL, 37, 37, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Play forward at once'),
    (2, 'Front players', 'Break toward goal for the quick attack')
) AS v(so, role, job);

-- 13. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'to_attack', 'Interview with Unai Emery', 'Choose counter speed after regain',
    'On winning the ball the team reads the moment and picks the best option: a faster or slower counter-attack, or an organised attack.',
    'Possession regained',
    'Exploit the opponent''s weaknesses in transition with the right tempo.',
    NULL, 41, 41, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Judge whether a quick forward route is on'),
    (2, 'Team', 'Either break fast or secure the ball and organise')
) AS v(so, role, job);

-- 14. pp.45-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery''s Formation and Tactics', '3-4-3 to use width vs narrow diamond',
    'Against Tottenham''s narrow 4-1-2-1-2, Emery switched from his 4-2-3-1 to a 3-4-3 (3-4-2-1) to exploit the width the diamond leaves.',
    'Opponent plays a narrow midfield diamond',
    'Stretch a narrow opponent with wing-backs and wide forwards.',
    '4-1-2-1-2', 45, 45, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing-backs (Bellerin, Kolasinac)', 'Hold the touchlines to use the free width'),
    (2, 'Back three (Mustafi, Sokratis, Holding)', 'Cover the two strikers with a spare man'),
    (3, 'Wide forwards (Mkhitaryan, Iwobi)', 'Play inside channels behind the striker')
) AS v(so, role, job);

-- 15. pp.45-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery''s Formation and Tactics', '3-4-1-2 to overload a weak defence',
    'Against Manchester United (shape not given) Emery played a 3-4-1-2 with a No10 behind two strikers, fielding more attackers than usual.',
    'Opponent defence judged vulnerable',
    'Overload the opposing back line with extra forwards.',
    NULL, 45, 45, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two strikers (Lacazette, Aubameyang)', 'Occupy and run at the centre backs'),
    (2, 'No10 (Ozil)', 'Play between the lines behind the strikers'),
    (3, 'Wing-backs', 'Provide width from the 3-4 base')
) AS v(so, role, job);

-- 16. pp.46-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery''s Tactics in the Build-Up Phase', 'Switch along the back line',
    'In the 4-2-3-1 build-up the full backs push high while goalkeeper and centre backs move the ball flank to flank with short passes; the two pivots drop low and shift to the strong side.',
    'Goal kick / possession in own third',
    'Shift the press and release the far full back free out wide to progress.',
    NULL, 46, 46, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper and centre backs (Leno, Sokratis, Koscielny)', 'Short passes across to switch the side'),
    (2, 'Full backs (Bellerin, Kolasinac)', 'Start high and wide, receive on the far side'),
    (3, 'Pivots (Xhaka, Torreira)', 'Drop low toward the strong side to offer options')
) AS v(so, role, job);

-- 17. pp.47-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery''s Tactics in the Build-Up Phase', 'Strong-side winger drops as link',
    'When the centre back cannot pass straight to the full back because both pivots have crowded the strong side, the winger drops to receive and lays it to the full back.',
    'Pass lane from centre back to full back closed',
    'Get the ball to the full back so he can dribble forward.',
    NULL, 47, 47, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side winger (Aubameyang)', 'Drop back as a link option'),
    (2, 'Centre back (Koscielny)', 'Play into the dropping winger'),
    (3, 'Full back (Kolasinac)', 'Receive the lay-off and carry forward')
) AS v(so, role, job);

-- 18. pp.47-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery''s Tactics in the Build-Up Phase', 'Pivot options: 10, striker or full back',
    'The centre back finds the deep midfielder who has shifted across; his first look is the No10 behind the pressing line, then the striker or a forward run by the full back as the winger moves inside to clear space.',
    'Deep midfielder receives facing forward',
    'Bypass the first pressing line and progress centrally or wide.',
    NULL, 47, 47, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep central midfielder (Xhaka)', 'Shift across, receive, look forward first'),
    (2, 'No10 (Ozil)', 'Position behind the pressure zone'),
    (3, 'Striker (Lacazette)', 'Offer a forward option'),
    (4, 'Full back (Kolasinac)', 'Run forward wide'),
    (5, 'Winger (Aubameyang)', 'Move inside to clear the flank')
) AS v(so, role, job);

-- 19. pp.48-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery''s Tactics in the Build-Up Phase', 'Unpressed centre back hits space behind',
    'When the opponent defends high but no one pressures the centre back, he plays directly over the back line for a fast winger to run onto, with the striker supporting.',
    'High line with free ball holder at the back',
    'Use fast forwards to get in behind for a scoring chance.',
    NULL, 48, 48, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Sokratis)', 'Direct pass over the top'),
    (2, 'Winger (Aubameyang)', 'Sprint in behind from the flank'),
    (3, 'Striker (Lacazette)', 'Support the run centrally')
) AS v(so, role, job);

-- 20. pp.49-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery''s Tactics in the Creating Phase', 'Winger runs, 8 drops, full back chooses',
    'In the middle third the ball circulates out to the free full back; as it travels the winger runs forward and the attacking midfielder drops into the space he left (synchronised switch), giving the full back a safe short pass or a through ball for the winger.',
    'Pass travelling to the free full back',
    'Create space and numbers through rotation, then keep the ball or release a runner in behind.',
    NULL, 49, 50, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Bellerin)', 'Receive free wide; short to the 8 or through ball behind'),
    (2, 'Right winger (Ozil)', 'Timed forward run in behind'),
    (3, 'Attacking midfielder (Ramsey)', 'Drop into the vacated space for the safe option'),
    (4, 'Front players (Lacazette, Aubameyang)', 'Sit between the lines ready to run in behind')
) AS v(so, role, job);

-- 21. pp.51-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery''s Tactics in the Finishing Phase', 'Pin back four, full back crosses to five',
    'Three attackers hold advanced central positions occupying the whole back four, leaving the flank free for the full back to receive, dribble forward and cross while five players attack the box.',
    'Full back receives wide with no winger closing',
    'Fill the box with near post, centre, far post, edge and late runs for a high-quality chance.',
    NULL, 51, 52, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Bellerin)', 'Carry forward and cross'),
    (2, 'Attacking midfielder (Ramsey)', 'Near-post run'),
    (3, 'Striker (Lacazette)', 'Central run toward the six-yard box'),
    (4, 'Far winger (Aubameyang)', 'Far-post run'),
    (5, 'Near winger (Ozil)', 'Edge of box for cut-back or rebound'),
    (6, 'Opposite full back (Kolasinac)', 'Late arrival from the other side')
) AS v(so, role, job);

-- 22. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery''s Tactics in the Finishing Phase', 'Diagonal runs through back-line gaps',
    'With three players between the lines and the full back free wide, two attackers make aggressive diagonal runs either side of a centre back and the full back slides a through ball instead of crossing.',
    'Full back receives in space wide',
    'Get a fast runner in behind to shoot or cross for teammates.',
    NULL, 53, 53, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Kolasinac)', 'Through pass into the gap instead of crossing'),
    (2, 'Winger (Aubameyang)', 'Diagonal run between full back and centre back'),
    (3, 'Attacking midfielder (Ramsey)', 'Run through the other side of the centre back'),
    (4, 'Striker (Lacazette)', 'Hold position between the lines')
) AS v(so, role, job);

-- 23. pp.56-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery Technical Practices / Possession Games', 'Open up and progress end to end',
    'Players check away from their marker, open up half-turned and play forward, changing the direction of play when facing back; in game form the team moves the ball from one goalkeeper to the other using positional support and spare players while the opponent presses collectively.',
    'Team has the ball deep with a target at the far end',
    'Progress through the press via positional support and forward passing.',
    NULL, 56, 58, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receivers', 'Check away, open body on the half-turn, play forward'),
    (2, 'Players facing own goal', 'Redirect play toward the far end'),
    (3, 'Neutral/spare players', 'Offer support to create the overload'),
    (4, 'Defending team', 'Press together; on winning it, become the attacking side')
) AS v(so, role, job);

-- 24. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery Possession Games', 'Keep it in one zone, then switch',
    'Team in possession plus neutrals build a local overload in one area and keep the ball there with a set number of passes before moving it to a teammate in a different zone; players flood across to rebuild the same overload around the new ball.',
    'Enough passes completed in the crowded zone (opponent drawn in)',
    'Draw pressure to one area, then change the point of attack and recreate superiority on the far side.',
    NULL, 59, 59, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players in ball zone', 'Short support angles, keep the 3v3+3 alive until the pass count is met'),
    (2, 'Players waiting in other zones', 'Stay spread, offer the switch target'),
    (3, 'Nearest players to new zone', 'Move across quickly to recreate the overload'),
    (4, 'Defenders', 'On regain swap roles and become the possession team')
) AS v(so, role, job);

-- 25. pp.64-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery Attacking Combination Play', 'Inside carry, overlap and cut-back',
    'Around the edge of the box a midfielder carries the ball at the defence while the deeper player who started the move overlaps outside him; the overlapper receives wide in the box and cuts back for the carrier or a late runner, with the other forward attacking the far post.',
    'Ball carrier dribbles at the last line, overlapper sprints around',
    'Pull the defence inside with the dribble and create a cut-back chance from the byline area.',
    NULL, 64, 65, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Starting midfielder (A)', 'Pass forward then make the overlapping run around the outside'),
    (2, 'Second forward (B)', 'Receive off the mannequin, set across, then attack the far post / second ball'),
    (3, 'Carrier (C)', 'Run onto the square pass and dribble at the defence, release the overlap, arrive for the cut-back'),
    (4, 'Overlapper on the ball', 'Cut back or shoot (variation) under pressure')
) AS v(so, role, job);

-- 26. pp.67-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery Finishing Practices', 'Wall pass in behind plus rebound runner',
    'Near the box a player plays a one-two with a teammate standing in front of the defenders and runs around the defender to receive in behind and shoot; a second forward follows in to finish any rebound or a second ball.',
    'Defender facing the ball carrier at the edge of the box',
    'Get a runner past the last defender with a first-time return pass, and always have a second man crashing for loose balls.',
    NULL, 67, 69, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Runner (A)', 'Pass in, spin around the defender, finish the return pass'),
    (2, 'Wall player (B)', 'Return first time into the box, then follow in for the rebound'),
    (3, 'Second forward', 'Attack the keeper''s parry with a first-time shot')
) AS v(so, role, job);

-- 27. pp.68-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery Finishing Practices', 'Back-to-goal hold, lay-off and spin',
    'A striker receives with his back to goal and a defender tight on him, shields the ball and lays it off to a supporting teammate, then turns and runs in behind for the return pass to finish.',
    'Ball played into feet of a marked striker',
    'Keep the ball under contact and use the lay-off to turn the marker and break into the box.',
    NULL, 68, 68, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (A)', 'Receive half-shielding, lay off first time, spin into the box'),
    (2, 'Supporting forward (B)', 'Receive the lay-off and slide the ball ahead of A''s run')
) AS v(so, role, job);

-- 28. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery Finishing Practices', 'Timed box runs from both sides',
    'One attacker carries forward and slips a teammate who opens his body to receive in the box and shoot, while the first passer arcs around the defence to attack a cross delivered from the opposite flank.',
    'Ball carrier drives into the space in front of the box',
    'Arrive in the box at the right moment and on the half-turn so the first touch sets the shot, then reload the box for a second-phase cross.',
    NULL, 70, 70, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Carrier (A)', 'Dribble, pass into the box, then curve run to the far side for the cross'),
    (2, 'Box runner (B)', 'Run around the defence, open the body, finish'),
    (3, 'Opposite winger (C)', 'Dribble down the side and cross the second ball')
) AS v(so, role, job);

-- 29. pp.71-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery Finishing Practices', 'Winger beats full back, two runners attack',
    'The ball goes out wide to a winger who must get past his defender to make room for a cross, while two forwards time runs into the box; one attacks the ball and the other stays alert for the rebound.',
    'Winger isolated 1v1 with the full back',
    'Win the wide duel and deliver to two runners split between first and second ball.',
    NULL, 71, 71, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (B)', 'Beat the defender to create crossing space, cross'),
    (2, 'Forward C', 'Attack the cross and shoot'),
    (3, 'Forward D', 'Hold off slightly to pounce on a rebound or second ball'),
    (4, 'Feeder (A)', 'One-two with the defender, then switch the ball out wide')
) AS v(so, role, job);

-- 30. pp.73-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'to_attack', 'Unai Emery Small Sided Games', 'Score fast, then go again',
    'In a three-team game the attacking side tries to finish a quick combination before the defence settles; whoever wins the ball immediately plays out and attacks the other end while the team that lost it drops into a defending role.',
    'Ball won or new ball received after a goal',
    'Train attacking at speed straight after a regain and an instant switch of mindset for both sides.',
    NULL, 73, 73, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking team', 'Few touches, combine and shoot quickly'),
    (2, 'Defending team on regain', 'Release to the middle immediately and attack the opposite goal'),
    (3, 'Team that lost it', 'Retreat and get ready to defend the next phase')
) AS v(so, role, job);

-- 31. pp.74-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery Small Sided Games', 'Circulate, then enter the final zone',
    'In a 7v7 game the team moves the ball across the middle zones until a player can dribble or pass into the final zone; only then can everyone follow into it to finish on one of two goals.',
    'Gap to run or pass into the end zone',
    'Patient build-up and circulation, then a decisive entry with the whole team supporting the attack into the scoring area.',
    NULL, 74, 74, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield circulators', 'Switch the ball between the two mini goals'' sides to find the gap'),
    (2, 'Player who breaks in', 'Dribble or receive in the end zone and attack the goal'),
    (3, 'Teammates', 'Follow into the zone straight away to support the finish'),
    (4, 'Defenders', 'Win it and reverse roles')
) AS v(so, role, job);

-- 32. pp.75-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Unai Emery Small Sided Games', 'Use wide outlets to feed box shooters',
    'Each team has extra players outside the area on the flanks; inside players pass out to them and they either lay it back or cross for the inside players to shoot.',
    'Inside player blocked, wide outlet free',
    'Use width to create shooting chances and crosses for runners.',
    NULL, 75, 75, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide end players', 'Return first-time or cross into the box'),
    (2, 'Inside players', 'Release wide, then move to attack the return or the cross')
) AS v(so, role, job);

-- 33. pp.81-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Benitez Tactical Example (Attacking)', 'Switch the back line to make a 2v1',
    'Against an organised block sitting in its own half, Benitez''s Liverpool full back has no forward option because the winger presses him, so the ball goes back and across the defence and the centre back plays forward to the far-side winger; full back and winger then form a 2v1 on that flank.',
    'No forward pass available on the ball side',
    'Move the opponents across, then exploit the imbalance with a 2v1 out wide, either dribbling past the defender or a one-two, and cross into the box.',
    NULL, 81, 81, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back', 'Recognise the press, play back to the centre backs'),
    (2, 'Centre backs', 'Switch along the back line, drive a pass forward to the far winger'),
    (3, 'Far-side winger', 'Receive and attack the defender, dribble or one-two, then cross'),
    (4, 'Far-side full back', 'Overlap to create the 2v1'),
    (5, 'Strikers', 'Attack the box for the cross')
) AS v(so, role, job);

-- 34. pp.82-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'out_of_possession', 'Benitez Tactical Example (Defending)', 'Collapse on the floater between lines',
    'Benitez''s Liverpool defended zonally with midfield and back lines close together; when an opponent drifting between the lines receives, every nearby player squeezes towards the ball to shrink the space around him.',
    'Pass into a floating player between midfield and defence',
    'Stop him turning, cut his passing lanes and his time, and win the ball.',
    NULL, 82, 82, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield line', 'Stay compact with the back four; drop and turn in on the receiver'),
    (2, 'Nearest centre back', 'Step in to stop the turn'),
    (3, 'Ball-side midfielders and full back', 'Close inward and block the forward and square lanes'),
    (4, 'Whole team', 'Mark zones, stay narrow to limit the space between lines')
) AS v(so, role, job);

-- 35. pp.87-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Rafael Benitez Napoli Training Session 1', 'Fast circulation to switch point of attack',
    'Possession under pressure is limited to a few passes or touches in one area, after which the ball has to move to another zone; players keep switching play quickly and the nearest teammates rush to support the new ball carrier.',
    'Pressure collapsing on the ball zone',
    'Move the ball faster than the opponents can shift and always have quick support close to the new holder.',
    NULL, 87, 92, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'One or two touches, switch before the pass limit or press closes'),
    (2, 'Far-zone players', 'Spread out, be ready to receive the switch'),
    (3, 'Nearest teammates to the switch', 'Move quickly into support angles'),
    (4, 'Central player', 'Link both ends of the area'),
    (5, 'Defenders', 'Only a few can press at once; whoever intercepts swaps in')
) AS v(so, role, job);

-- 36. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Rafael Benitez Napoli Training Session 1', 'Build from GK in set shape',
    'A 9v9 game where the team builds from the keeper while keeping its formation, with bonus points for passing through cone gates on the way; players move to open passing lines and drive passes along the ground.',
    'Goalkeeper in possession',
    'Progress the ball through the thirds while keeping team shape, finishing with a goal.',
    NULL, 88, 88, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Start the build-up short'),
    (2, 'Defenders and midfielders', 'Hold formation positions, move to create passing lanes'),
    (3, 'Ball player', 'Hit accurate driven ground passes through the gates and lines'),
    (4, 'Forwards', 'Finish the attack')
) AS v(so, role, job);

-- 37. pp.93-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Rafael Benitez Napoli Training Session 2', 'Pass through the line to the moving target',
    'A unit circulates the ball in front of a defending line that slides sideways to block lanes, waiting for the right moment to play through it to a teammate beyond who keeps moving to open a lane.',
    'A gap opens in the sliding defensive line',
    'Break a line with an accurate pass; the defending side learns to stay compact, communicate and anticipate the interception.',
    NULL, 93, 93, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players in front of the line', 'Move the ball side to side to shift the defenders'),
    (2, 'Target beyond the line', 'Keep moving to stay in a passing lane'),
    (3, 'Defending line', 'Close distances, slide together, block angles and intercept')
) AS v(so, role, job);

-- 38. pp.94-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Rafael Benitez Napoli Training Session 2', 'Bounce pass off outside support',
    'In a 7v7+7 game the team in possession uses players around the outside as one-touch rebounders: a pass out and a direct return to the same player beats the press.',
    'Pressing team closing in on the ball carrier',
    'Escape pressure and keep the ball by playing off an outside support and receiving it straight back.',
    NULL, 94, 94, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside player', 'Pass to the outside man and move to receive the return'),
    (2, 'Outside support players', 'One touch only, play it back to the passer'),
    (3, 'Pressing team', 'Work together to press and intercept')
) AS v(so, role, job);

-- 39. pp.98-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Luis Enrique''s Tactics in the Champions League vs Paris Saint-Germain', 'Front three set-up vs PSG',
    'Barcelona in a 4-3-3 against PSG''s 4-3-3, played more cautiously: Neymar dropped to follow the opponent right back, Suarez stayed between the two centre backs, and Messi left the left back to drift inside and make 2v2 against the centre backs; Busquets, Iniesta and Rakitic dominated the ball and Alba pushed up on the left.',
    'Settled possession in midfield',
    'Dominate the ball and create a central 2v2 for Suarez and Messi while the left back gives width.',
    '4-3-3', 98, 98, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Suarez)', 'Sit between the two centre backs'),
    (2, 'Right winger (Messi)', 'Leave the left back, come inside to make 2v2 vs the centre backs'),
    (3, 'Left winger (Neymar)', 'Track the opposition right back when defending'),
    (4, 'Midfield three (Busquets, Iniesta, Rakitic)', 'Take many touches and combine with the front three'),
    (5, 'Left back (Alba)', 'Attack, combine with Iniesta and Neymar, get into advanced space')
) AS v(so, role, job);

-- 40. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Luis Enrique''s Attacking Combination Play on the Flank', 'Two-man flank 1-2 for overlapping left back',
    'Busquets finds Alba, who passes to Neymar wide on the touchline; Neymar draws both the opposing winger and right back, opening space behind them, and returns the ball to Alba running forward into that space.',
    'Winger receives wide and attracts two defenders',
    'Release the full back high up the flank in space behind the defence to cross or attack.',
    '4-3-3', 99, 99, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Busquets)', 'Play the left back'),
    (2, 'Left back (Alba)', 'Pass wide to the winger then sprint forward for the return'),
    (3, 'Left winger (Neymar)', 'Hold the touchline, draw the winger and full back, return first time'),
    (4, 'Centre forward (Suarez)', 'Attack the box for the cross')
) AS v(so, role, job);

-- 41. pp.100-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Luis Enrique''s Attacking Combination Play on the Flank', 'Three-man rotation: winger drops, midfielder breaks',
    'With Neymar starting inside and Alba wide, Neymar drops off to receive from Busquets; at the same moment Iniesta pushes forward unmarked into the space Neymar left, takes a first-time pass, draws the right back and slides Alba into space behind the defence.',
    'Winger drops toward the ball and his marker follows',
    'Synchronised drop-and-run breaks through the midfield line and frees the full back high up.',
    '4-3-3', 100, 100, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Neymar)', 'Start inside, drop off and play first time to the runner'),
    (2, 'Left central midfielder (Iniesta)', 'Move forward into the vacated space, receive between lines, draw the full back, pass wide'),
    (3, 'Left back (Alba)', 'Hold wide on the line, then run onto the ball behind the defence'),
    (4, 'Defensive midfielder (Busquets)', 'Feed the dropping winger')
) AS v(so, role, job);

-- 42. pp.101-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Attack with a Third Man Run to Receive in Behind a Deep Defensive Line', 'Full back third man run into box',
    'Against a compact 4-4 sitting deep in its own half (PSG), Neymar dribbles inside from the left and passes to Messi in a tight space; as soon as that pass goes, Alba runs forward from deep and Messi plays him in behind into the box.',
    'Inside pass from the winger to the playmaker between lines',
    'Use a deeper runner the defence is not tracking to get in behind a packed defence.',
    NULL, 101, 101, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Neymar)', 'Dribble inside, pass to Messi'),
    (2, 'Playmaker (Messi)', 'Receive in tight space, play first-time into the run in behind'),
    (3, 'Left back (Alba)', 'Third man: start the run the moment Neymar passes, receive in the box'),
    (4, 'Box forwards', 'Pin the centre backs')
) AS v(so, role, job);

-- 43. pp.102-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'to_attack', 'Luis Enrique''s Counter Attack Tactics', 'Halfway regain, fast break 3v2',
    'Busquets wins the ball near the left side at halfway while PSG''s midfield and defence are disorganised; a quick forward pass to Rakitic draws the opposing right back out, Messi receives to make 3v2, and Messi times a pass into the space for Neymar who moves inside to score.',
    'Ball won while opponents are unbalanced and a defender steps out',
    'Exploit the moment after the regain with quick passes into the space a defender has left.',
    NULL, 102, 102, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Busquets)', 'Win the ball and play forward at once'),
    (2, 'Right central midfielder (Rakitic)', 'Receive and move it to Messi as the full back steps in'),
    (3, 'Messi', 'Receive with the 3v2, pass at the right moment into the space'),
    (4, 'Left winger (Neymar)', 'Run into the gap vacated by the full back, control, cut inside and finish')
) AS v(so, role, job);

-- 44. pp.104-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Luis Enrique Roma Training Session', 'Keep the ball in tight spaces',
    'In a small rondo with players around the edges and one inside, the team must keep the ball against three pressers, using precise weighted passes, all the space available and quick decisions to find the free man.',
    'Three pressers closing the ball',
    'Keep possession under tight pressure by spatial awareness and fast choices.',
    NULL, 104, 104, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside players', 'Stretch the area, give passing angles'),
    (2, 'Inside player', 'Find space between pressers for a split pass'),
    (3, 'Ball carrier', 'Decide quickly and pick the free teammate'),
    (4, 'Pressers', 'Press together; the player who wins it swaps in')
) AS v(so, role, job);

-- 45. pp.105-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Luis Enrique Roma Training Session', 'Build via full back and link striker',
    'In a 6v6 game with a neutral striker the attack starts from a full back and uses the central link player to play through the opponents and score in mini goals; on losing the ball the side must transition straight away to defend.',
    'Full back in possession at the start of build-up',
    'Play through the opposition using a central link, with immediate transitions both ways.',
    NULL, 105, 105, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'Start the build-up, defend their own side goal on loss'),
    (2, 'Neutral striker', 'One touch link player for the team in possession'),
    (3, 'Central midfielders', 'Combine with the striker to break lines, defend the middle goal'),
    (4, 'Wingers', 'Receive beyond the line and finish')
) AS v(so, role, job);

-- 46. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Luis Enrique Roma Training Session', 'Advanced full backs exploit width',
    'An 8-man attacking team starting from the defensive midfielder uses combinations and its numerical advantage against a back four plus holding midfielder; the full backs push high and use the space out wide to create the chance.',
    'Defensive block narrows to protect the centre',
    'Turn numerical superiority into a chance by stretching the block wide with advanced full backs.',
    NULL, 106, 106, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Start the attack and switch it'),
    (2, 'Full backs', 'Push high into wide space, cross or combine'),
    (3, 'Wingers and forward', 'Occupy the back line, attack the box'),
    (4, 'Central midfielders', 'Combine through the middle to draw the block in')
) AS v(so, role, job);

-- 47. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'to_attack', 'Luis Enrique Roma Training Session', 'Regain then hit the wide outlets',
    'Defending team (back four plus holding midfielder) stays compact, presses and wins the ball, then immediately looks to pass into the zones where its wingers and striker would be waiting near halfway.',
    'Ball recovered in own half',
    'Turn a regain into an immediate counter by finding the forward outlets.',
    NULL, 106, 106, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Stay compact, defend the goal, press to recover'),
    (2, 'Holding midfielder', 'Screen and pick up second balls'),
    (3, 'First receiver after regain', 'Look forward first, pass into the winger or forward outlet zone')
) AS v(so, role, job);

-- 48. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Luis Enrique Roma Training Session', 'Finish the 3v2 overload quickly',
    'Three attackers against two defenders in front of goal must exploit the extra man to score; if the defenders win the ball, a teammate joins them to counter in a 3v2 the other way.',
    'Numerical advantage in the final third',
    'Commit defenders and give the ball to the free man to score; defenders press to win it and become the attack.',
    NULL, 107, 107, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Commit one defender, pass to the free attacker'),
    (2, 'Free attacker', 'Stay wide of the cover, finish'),
    (3, 'Defending pair', 'Press and win the ball; on regain one extra player joins to make 3v2')
) AS v(so, role, job);

-- 49. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Luis Enrique Roma Training Session', 'Wide jokers overload the final zone',
    'A team builds out in 5v5 from its own third, dribbles or passes into the middle zone, then attacks the last zone with the help of two wide jokers in the side lanes, making 7v5 to finish.',
    'Ball reaches the middle zone',
    'Move up the pitch phase by phase and add wide players to create a numerical advantage for the final attack.',
    NULL, 108, 108, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper and builders', 'Play out 5v5 in the first zone'),
    (2, 'Midfield carriers', 'Dribble or pass into the middle zone'),
    (3, 'Wide jokers', 'Join from the side lanes to make the overload, cross or combine'),
    (4, 'Defending team', 'On regain, play forward into the middle zone')
) AS v(so, role, job);

-- 50. pp.110-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'to_defend', 'Luis Enrique FC Barcelona Training Practices', 'Close in and win it back',
    'When the possession team loses the ball, every player immediately closes in and presses the ball carrier to win it back, while the side that won it spreads to the outside to keep it.',
    'Interception / loss of possession',
    'Recover the ball as quickly as possible before the opponents can spread out.',
    NULL, 110, 110, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost it', 'Press the new ball carrier at once'),
    (2, 'Nearest teammates', 'Close in and cut the passing lanes'),
    (3, 'Team that won it', 'Move to the outside to stretch and keep possession')
) AS v(so, role, job);

-- 51. pp.111-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Luis Enrique FC Barcelona Training Practices', 'Switch through central joker',
    'Three teams of three: the side in possession in one half keeps the ball with two or three touches until it can find the joker on the halfway line, who sets it back and the play is switched to teammates in the other half.',
    'Joker free on halfway after opponents are drawn',
    'Create angles to keep the ball, then switch through a central link to the far side.',
    NULL, 111, 111, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Possession team', 'Limited touches, open angles, find the joker'),
    (2, 'Central joker', 'Lay it back to a player who switches to the far side'),
    (3, 'Far-side team', 'Receive the switch and start again')
) AS v(so, role, job);

-- 52. pp.111-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'out_of_possession', 'Luis Enrique FC Barcelona Training Practices', 'Slide across after the switch',
    'After the ball is switched to the other half, the pressing unit moves across together to defend again, pressing collectively, communicating and anticipating passes to intercept.',
    'Opponents switch the play',
    'Recover shape on the new side quickly and press again as a unit.',
    NULL, 111, 111, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing trio', 'Run across together, set pressure on the new ball'),
    (2, 'Nearest presser', 'Engage the ball carrier'),
    (3, 'Others', 'Cover lanes and anticipate interceptions')
) AS v(so, role, job);

-- 53. pp.112-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'to_attack', 'Luis Enrique FC Barcelona Training Practices', 'GK picks fastest route, all push up',
    'In a 5v5+1 game the keeper chooses short, medium or long distribution, whichever helps score fastest; once the ball is in the opposition half all outfield players run forward to support the attack.',
    'Goalkeeper has the ball / ball crosses halfway',
    'Play forward quickly and arrive in numbers to finish.',
    NULL, 112, 112, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Read the best option and distribute short, medium or long'),
    (2, 'Outfield players', 'Push up behind the ball once it is in the opposition half'),
    (3, 'Joker', 'Help the team in possession to attack')
) AS v(so, role, job);

-- 54. pp.113-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'del-bosque-emery-benitez-luis-enrique-practices-and-training-sessions'), 'in_possession', 'Luis Enrique FC Barcelona Training Practices', 'Zonal positional attack, 2v1 to 3+1v4',
    'Barcelona in 4-3-3 against a 4-4-1 (not in list) split into zonal bands: the centre backs build with a 2v1 against the striker, the ball progresses through midfield, and one player advances from the middle zone into the last zone to make 3+1 v 4 and get in behind by dribbling across the line or a pass; on loss the team transitions straight away.',
    'Coach serves a centre back; free man appears in each zone',
    'Build up positionally, add a player late into the final zone and play in behind; win it back fast after losing it.',
    NULL, 113, 113, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Use the 2v1 against the lone striker to play forward'),
    (2, 'Midfield three', 'Receive in space; one advances into the final zone with the ball or by a run'),
    (3, 'Front three', 'Hold the last line, receive in behind into the box'),
    (4, 'Defending side (4-4-1)', 'Stay in zones, press, block lanes; on regain counter to play in behind'),
    (5, 'Whole team on loss', 'Transition quickly to win the ball back')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1971-coaching-book-del-bosque-emery-benitez-enrique-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
