-- 1979 📚 Coaching book patterns: "Catalan Academy Coaching U7-12" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Catalan Academy Coaching U7-12',
    subtitle    = 'The World''s Best Youth Training Program (110 Practices)',
    author      = 'Alex Fitzgerald (ed.), George Pallecaros',
    team        = 'Catalan elite academy (coaches Enrique Durán, Mickey Castiella)',
    method_note = 'The U7-12 programme of a Catalan elite academy, observed by SoccerTutor''s founder with views from its coaches. Every session starts with the ball and targets one key skill; about three quarters of the week is technical and one quarter tactical, taught through small-sided games. Chapters: warm-ups, running with the ball, passing and receiving, rondos, possession games, dribbling and duels, shooting, positional play and a tactical 7v7 (3-2-1) chapter (base shape, building out, full backs overlapping, third-man runs, defensive block and pressing trap), then example sessions. Patterns are the team behaviours taught, in our words; technique-only drills are left out.'
WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract');

-- 1. pp.9-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Passing and Receiving - 7. Play Through the Gates / Dribbling insights', 'Pass or dribble decision',
    'The player on the ball dribbles in 1v1 situations or when a scoring chance can be made, but passes when in the defensive third or when a pass is the better option; jokers or support are used when neither is on.',
    'Receiving with a defender close',
    'Choose the action that keeps possession and progresses play.',
    NULL, 9, 51, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Dribble in 1v1 or attacking areas, pass in own third'),
    (2, 'Support players', 'Offer a safe outlet when the dribble is off')
) AS v(so, role, job);

-- 2. pp.9-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Rondos / Passing and Receiving - Directional Control', 'Get into the passing line',
    'Teammates without the ball move early to an open line between ball and defender, open the body to see ball and next pass, and receive on the back foot to play away from pressure or forward.',
    'Defender cuts the current passing line',
    'Always give the ball carrier a clear option and keep possession flowing.',
    NULL, 9, 60, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Supporting player', 'Step into the clear line, open body shape'),
    (2, 'Receiver', 'First touch with the back foot in the next direction'),
    (3, 'Player on ball', 'Play the support that is open, not forced')
) AS v(so, role, job);

-- 3. pp.10-10
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Training Insights - Tactical Approach (3-2-1 in 7v7)', 'Start play from the back, full width',
    'In the 3-2-1 7v7 shape the team begins attacks by circulating among the defensive line, spread across the whole width.',
    'Goalkeeper or back line has the ball',
    'Make room and drag opponents out of position before playing forward.',
    NULL, 10, 10, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Comfortable on the ball, starts circulation'),
    (2, 'Centre back', 'Receives and builds from the back'),
    (3, 'Full backs', 'Hold width, cover large areas up and down'),
    (4, 'Midfielders', 'Set tempo and offer the next line')
) AS v(so, role, job);

-- 4. pp.10-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'out_of_possession', 'Training Insights - Defensive Principles / Warm-up 14', 'Shrink the pitch, nearest presses',
    'Without the ball the team makes the playing area as small as possible; the closest player presses the ball while the rest block passing lanes, keeping a numerical edge in key zones.',
    'Opponent has the ball',
    'Win the ball back quickly and break up the opponent''s build-up.',
    NULL, 10, 27, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'Press the ball carrier immediately'),
    (2, 'Other defenders', 'Screen and block passing lanes'),
    (3, 'Ball-side players', 'Create local superiority around the ball')
) AS v(so, role, job);

-- 5. pp.10-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Training Insights - Attacking Principles', 'Stretch width and depth, circulate patiently',
    'With the ball the team spreads wide and long, and moves the ball around to shift the opponent and open passing lanes; players keep it until a forward option is truly there.',
    'Settled possession with no safe forward pass',
    'Open a lane forward instead of forcing a risky pass.',
    NULL, 10, 52, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players', 'Hold the touchline to stretch the block'),
    (2, 'Forward', 'Give depth, pin the back line'),
    (3, 'Player on ball', 'Recognise forward pass vs keep possession'),
    (4, 'Off-ball players', 'Move to create space for others')
) AS v(so, role, job);

-- 6. pp.14-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Passing and Receiving - 2/3. Pass and Move', 'Pass and follow into new space',
    'After passing, the player moves straight away to support again, keeping spacing and clear lines across the area; receivers scan and call before the ball comes.',
    'Pass released',
    'Keep high tempo with constant fresh support for the next receiver.',
    NULL, 14, 46, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Move immediately after passing to a new support spot'),
    (2, 'Next receiver', 'Scan before receiving, call the name'),
    (3, 'All players', 'Keep spacing so lines stay open')
) AS v(so, role, job);

-- 7. pp.27-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'to_attack', 'Warm-Ups - 14. Possession and Transition Handball to Football', 'Spread out fast on regain',
    'The moment the team gains or starts possession in a new area, players open up quickly to give width and depth.',
    'Ball won / transition into open space',
    'Give the ball carrier immediate options before the opponent organises.',
    NULL, 27, 27, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players', 'Sprint wide to give width'),
    (2, 'Furthest player', 'Push deep for depth'),
    (3, 'Ball carrier', 'Find the first free teammate')
) AS v(so, role, job);

-- 8. pp.30-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Running with the Ball - 10. 4v4 (+2) Possession Game', 'Carry into space before passing',
    'When space opens in front, the player runs with the ball for a few touches, scans, moves away from opponents and then picks the best pass.',
    'Free space ahead of the ball carrier',
    'Gain ground and draw defenders before releasing the ball.',
    NULL, 30, 40, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Run at speed, head up, ball on foot away from opponent'),
    (2, 'Teammates', 'Fluid movement, offer options as defenders are drawn')
) AS v(so, role, job);

-- 9. pp.44-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Passing and Receiving - 1. Creating Space to Receive', 'Check away to lose the marker',
    'A marked receiver moves away first and then comes back to meet the pass at the right moment, playing it back with one clean touch.',
    'Receiver is tightly marked',
    'Create a yard of space to receive under pressure.',
    NULL, 44, 44, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'Check away, then time the run to meet the ball'),
    (2, 'Passer', 'Wait for the moment the line opens, do not rush')
) AS v(so, role, job);

-- 10. pp.48-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Passing and Receiving - 5/6/9. Attacking Overloads 2v1', '2v1 overload to beat a defender',
    'Two attackers against one defender: the support player takes an angled position and the carrier releases at the moment the defender commits, or dribbles if he does not; once past, attack the next zone.',
    '2v1 in a zone, defender steps to the ball',
    'Beat the line with a pass or dribble and progress toward goal.',
    NULL, 48, 52, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Draw the defender, use disguise, choose pass or dribble'),
    (2, 'Support attacker', 'Angled run with width, timed to the release'),
    (3, 'Final attacker', 'Positive first touch, change of speed, finish 1v1 with keeper')
) AS v(so, role, job);

-- 11. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Passing and Receiving - 10. Attacking Overloads with Wide Jokers', 'Use wide men to overload the final half',
    'The team progresses into the attacking half using wide players to create a numerical advantage there, and only attacks the goal once that extra man exists.',
    'Team has numbers up in the attacking half',
    'Stretch the defence and create decisive openings to shoot.',
    NULL, 53, 53, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players', 'Stay in the wide lanes to add the extra man'),
    (2, 'Central attackers', 'Movement off the ball to stretch defenders'),
    (3, 'Ball carrier', 'Read how much space is available and where')
) AS v(so, role, job);

-- 12. pp.57-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'to_defend', 'Rondos - 2/3. 3v1 Dribble Out / 4v1 Transition', 'React instantly when the ball is lost',
    'As soon as possession changes, the players who lost it close down immediately and block the escape route instead of switching off.',
    'Possession lost',
    'Stop the ball winner escaping and force a quick error to win it back.',
    NULL, 57, 58, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost it', 'Press the ball winner at once'),
    (2, 'Nearby teammates', 'Block the escape path and passing lanes')
) AS v(so, role, job);

-- 13. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Rondos - 4. Spot the Gap 4v2', 'Split pass between two defenders',
    'Attackers keep clear lines around two defenders and time their movement so a pass can be threaded through the gap between them.',
    'Gap opens between two pressing defenders',
    'Break the pressing line with a pass through the middle.',
    NULL, 59, 59, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player on ball', 'Scan and play through the gap when it opens'),
    (2, 'Partner across the gap', 'Move to exploit the gap and receive'),
    (3, 'Other supports', 'Keep lines open so the passer has choices')
) AS v(so, role, job);

-- 14. pp.61-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Rondos / Possession Games', 'Switch play past the screening line',
    'Possession group circulates on one side while defenders in a middle band try to cut the lanes; once enough passes draw them, a pass beats the middle line to the far group or free side.',
    'Defenders committed to the ball side; lane through or over the middle opens',
    'Ball arrives in the free space on the opposite side with time for the receiver.',
    NULL, 61, 79, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side players', 'short quick passes to drag defenders over'),
    (2, 'Ball carrier', 'scan early, open body, play the line-breaking or aerial switch'),
    (3, 'Far-side players', 'stay wide and ready, then support the new ball carrier quickly'),
    (4, 'Middle defenders', 'screen and intercept the switch')
) AS v(so, role, job);

-- 15. pp.61-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Rondos / Possession Games', 'Back-foot receive with directional control',
    'Receiver gets open into a passing line and takes the ball across the body on the back (far) foot, first touch steering it away from the nearest presser.',
    'Pass travelling to you with a defender closing',
    'Body is open to play forward or switch in one more touch instead of facing back.',
    NULL, 61, 108, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'move into the passing line before the ball, open hips'),
    (2, 'Receiver', 'first touch with back foot away from pressure, into space'),
    (3, 'Passer', 'weight the pass to the receiver''s far foot')
) AS v(so, role, job);

-- 16. pp.62-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'to_defend', 'Rondos / Possession Games', 'Loser presses immediately (role swap)',
    'The player or team that loses the ball becomes the defender at once and presses at intensity, sometimes sprinting to the next zone to defend there.',
    'Ball lost',
    'No switch-off moment after a loss; immediate pressure to win it back and cut passing lanes.',
    NULL, 62, 89, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost it', 'turn instantly into presser on the ball'),
    (2, 'Teammates nearby', 'close passing lanes, press with intensity'),
    (3, 'Whole group', 'anticipate the transition, stay alert')
) AS v(so, role, job);

-- 17. pp.64-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'to_attack', 'Rondos', 'Regain and dribble out to safety',
    'Defender who wins the ball immediately carries it out of the pressure zone into a free zone or own team area to restart possession with teammates.',
    'Ball won in a tight area',
    'Secure possession away from the counter-press and start a new possession sequence fast.',
    NULL, 64, 70, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'dribble quickly out into the free square / end zone'),
    (2, 'Teammates', 'move to support in the new zone to start passing')
) AS v(so, role, job);

-- 18. pp.67-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Rondos 12-14', 'Attract pressure then penetrate centre',
    'Outside players circulate patiently until the central defenders are pulled out of position, then dribble or pass into the central space behind them.',
    'Gap opens between central defenders',
    'Break lines into the middle with a central receiver or dribble.',
    NULL, 67, 69, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside players', 'keep ball moving, draw defenders in before playing forward'),
    (2, 'Ball carrier', 'dribble decisively into the gap once it opens'),
    (3, 'Central player / joker', 'time movement to arrive in the central space unmarked')
) AS v(so, role, job);

-- 19. pp.68-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'out_of_possession', 'Rondos 13-14, 19-20', 'Compact shift to block central lanes',
    'Defenders shift together as a unit to close passing lanes into the central space or through the middle band rather than chase individually.',
    'Opponent circulates looking for a central or line-breaking pass',
    'Deny the central pass and force play around, creating chances to intercept.',
    NULL, 68, 75, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing defenders', 'press the ball side compactly'),
    (2, 'Screening defenders', 'stay between ball and centre, cut the lane'),
    (3, 'Unit', 'move together, keep distances short')
) AS v(so, role, job);

-- 20. pp.71-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Rondos 16', 'Triangles, never all in one',
    'Players form passing triangles but do not crowd the same triangle; they spread out to create space yet stay close enough to combine.',
    'Teammates bunching near the ball',
    'Constant triangle options and free space; ball circulation unbalances opponents.',
    NULL, 71, 71, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'circulate to the free triangle'),
    (2, 'Supporting players', 'balance: spread for space, stay near enough to combine'),
    (3, 'All', 'ask ''where is the free space?'' and scan')
) AS v(so, role, job);

-- 21. pp.72-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Possession Games 8', 'Play short to draw press, then long',
    'Team in possession strings short passes in a small area to suck opponents in, then plays a long or aerial pass to an outlet in the space they left.',
    'Opponents compressed toward the short combination',
    'Exploit the emptied zone far from the ball, then the passer moves to support again.',
    NULL, 72, 85, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside players', 'half-turn receive, play short to attract defenders'),
    (2, 'Ball carrier', 'switch with an accurate long pass once defenders bite'),
    (3, 'Outlets / wide players', 'hold width far side to receive the long ball'),
    (4, 'Passer', 'make a fresh support movement after the long pass')
) AS v(so, role, job);

-- 22. pp.78-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Possession Games', 'Use the overload with width and depth',
    'Team with numerical advantage via jokers keeps width and depth, supports at good angle and distance and always offers the ball carrier two passing options.',
    'Team in possession with extra players',
    'Keep the ball and stretch the defence by quickly using the free man.',
    NULL, 78, 84, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Jokers / corner supports', 'give width and depth, recycle play'),
    (2, 'Nearest supports', 'show at angle and distance, two options always'),
    (3, 'Ball carrier', 'play quick ground passes to the free player')
) AS v(so, role, job);

-- 23. pp.80-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Possession Games 3, 5 / Dribbling 5', 'Drag defender to open dribbling lane',
    'A player moves away to pull his marker and create space for a teammate, who receives with a directional touch and dribbles into it.',
    'Defender follows a movement off the ball',
    'Free space ahead of the receiver to carry the ball forward.',
    NULL, 80, 93, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Decoy runner', 'move to drag a defender away'),
    (2, 'Receiver', 'directional first touch into the space and drive forward'),
    (3, 'Others', 'keep width and depth to open lanes')
) AS v(so, role, job);

-- 24. pp.86-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Possession Games 9 / Dribbling 5, 14', 'Attack the least defended target',
    'With several goals available, players scan and choose the target based on space and defensive position; after scoring they keep the ball and attack another goal.',
    'Defence shifts to protect one target',
    'Switch the point of attack quickly to an unprotected goal.',
    NULL, 86, 102, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'scan before receiving, pick best goal'),
    (2, 'Supports', 'give quick angles to switch play to another goal'),
    (3, 'Defending team', 'adjust shape and communicate to cover all goals')
) AS v(so, role, job);

-- 25. pp.91-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Dribbling 3 / Shooting 8', 'Combine with partner to beat a pair',
    'In 2v2 duels the ball carrier and partner communicate early and use quick combinations (one-two, dribble and pass) to unbalance the two defenders.',
    '2v2 in front of goal',
    'Create a shooting chance through a combination rather than solo play.',
    NULL, 91, 112, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'protect ball, attack space, release at right time'),
    (2, 'Partner', 'communicate, offer combination angle')
) AS v(so, role, job);

-- 26. pp.92-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Dribbling 4, 11', 'Dribble to commit, then release',
    'Ball carrier attacks his marker with a feint or skill to commit him, then passes once the defender is drawn in.',
    'Marker in front, space beyond',
    'Draws defender out of the passing line so the next player receives free.',
    NULL, 92, 99, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'beat or commit marker with feint before passing'),
    (2, 'Receiver', 'time run, receive on back foot and attack the next defender')
) AS v(so, role, job);

-- 27. pp.96-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'to_defend', 'Dribbling 8 / Shooting 6-7', 'Recovering defender sprints back',
    'Defender behind the play recovers at full pace to close the shooting angle and narrow space, then counters if he wins the ball.',
    'Opponent breaks away with the ball',
    'Delay or deny the shot and turn a regain into a quick counter.',
    NULL, 96, 111, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Recovering defender', 'sprint back, close angle, narrow space'),
    (2, 'Ball winner', 'counter at once toward goal')
) AS v(so, role, job);

-- 28. pp.100-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'to_attack', 'Dribbling 12 / Shooting 7', 'Finish the overload before recovery',
    'Attackers with a numerical edge (3v1, 3v2) go at speed and shoot early before recovering defenders even the numbers; players who are not finishing join to support.',
    'Numerical advantage after a break',
    'Score before the opposition gets level in numbers.',
    NULL, 100, 111, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'attack at speed to commit the defender'),
    (2, 'Wide attackers', 'wide runs and angled support to stretch defender'),
    (3, 'Already-finished attackers', 'rejoin to create a new overload')
) AS v(so, role, job);

-- 29. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Shooting 3', 'Wide dribble and cut-back to late runner',
    'Wide player dribbles past defenders toward the byline and cuts the ball back into the centre for a teammate making a timed supporting run.',
    'Wide player beats his man near the box',
    'Cut-back met at pace for a placed finish.',
    NULL, 107, 107, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player', 'dribble close past defenders, cut back into centre'),
    (2, 'Supporting runner', 'time an arcing run to meet the cut-back at pace')
) AS v(so, role, job);

-- 30. pp.113-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Shooting 9', 'Break lines and follow the pass',
    'Attack progresses zone by zone (4v2 build-up, 2v1 middle, 2+2v1 scoring zone); the player who breaks a line with a pass follows it forward to support.',
    'Pass played into the next zone',
    'Keep an overload in each new zone up to the finish.',
    NULL, 113, 113, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Build-up players', 'beat the press quickly with a line-breaking pass'),
    (2, 'Passer', 'move forward to support the receiver'),
    (3, 'Front pair', 'advance into scoring zone, use wide jokers to finish')
) AS v(so, role, job);

-- 31. pp.115-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Shooting 11-13', 'Shoot quickly before defence settles',
    'On a restart or new possession the team plays at high tempo and shoots early, using support players to combine, before the opponent is organised; limited passes enforce directness.',
    'Opponent disorganised / new ball',
    'Early shot on goal exploiting a disorganised defence.',
    NULL, 115, 117, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving team', 'transition instantly, play direct'),
    (2, 'Support players', 'combine quickly to open shooting space'),
    (3, 'Shooter', 'decide fast, shoot with either foot')
) AS v(so, role, job);

-- 32. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Tactical Positional Play 1', 'Positional build-up end to end',
    'Small team (2 full backs, 2 central mids) plus neutral centre back and forward build from one end zone to the other; full backs give width, mids give angles, forward offers across the width; on reaching the forward, he becomes the centre back and play goes back the other way.',
    'Centre back starts with the ball',
    'Players learn exact positions and where to be when the team has the ball.',
    NULL, 120, 120, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (neutral)', 'start build-up, support from behind'),
    (2, 'Full backs', 'hold width'),
    (3, 'Central midfielders', 'find support angles between lines'),
    (4, 'Forward (neutral)', 'offer options across the width; becomes CB on receiving')
) AS v(so, role, job);

-- 33. pp.121-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Tactical Positional Play / Example Session 3: Dribbling', 'Play wide, full back dribbles forward',
    'In the 3-2-1, the ball is moved early out to a full back, who carries it forward into open flank space rather than passing straight away, then combines with midfielders.',
    'Full back receives wide with space ahead',
    'Progress up the flank by dribbling and create a scoring chance with midfield support.',
    NULL, 121, 164, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'Receive early and wide, recognise when to dribble forward into space'),
    (2, 'Centre back', 'Find the full back with a switch or direct pass'),
    (3, 'Central midfielders', 'Move to support and combine with the dribbling full back'),
    (4, 'Forward', 'Offer a target in the box for the final pass')
) AS v(so, role, job);

-- 34. pp.122-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'out_of_possession', 'Tactical Positional Play / Defensive Roles and Positioning (7c)', 'Forward''s curved press forces play one way',
    'The forward presses the opposing centre back with an angle that cuts the central option and the switch, steering the ball to one side; the CMs stay close enough to intercept and the team slides across as a unit. The trap is sprung on the pass into the channel or wide.',
    'Opposing CB on the ball / pass made out wide',
    'Make the opponent''s play predictable and win the ball near the touchline, never letting it go inside or be switched long.',
    NULL, 122, 145, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Press with a body angle that blocks central lanes and the switch; force play wide'),
    (2, 'Ball-side central midfielder', 'Push high in sync with the forward to close the receiver'),
    (3, 'Other central midfielder', 'Hold the middle for balance'),
    (4, 'Ball-side full back', 'Press the receiver in the channel'),
    (5, 'Weak-side full back', 'Tuck in, ready to intercept, cover the switch or the centre back'),
    (6, 'Centre back + goalkeeper', 'Hold the line and cover the space behind; GK high to sweep')
) AS v(so, role, job);

-- 35. pp.125-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Tactical 7v7: Academy Playing Philosophy (3-2-1)', '3-2-1 shape: maximum width and depth',
    'Base attacking structure of the 7v7 3-2-1: full backs on the touchlines, two midfielders always offering lanes, forward high as the deepest outlet, keeper building on the ground. Every position has fixed responsibilities that are respected.',
    'Team has possession / goalkeeper has the ball',
    'Keep the ball as long as possible and take the initiative by using the full width and depth of the pitch.',
    NULL, 125, 128, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Keep the ball on the ground, find the best passing line to start build-up'),
    (2, 'Centre back', 'Always be the keeper''s first option (''saviour'')'),
    (3, 'Full backs', 'Stretch to maximum width when the keeper has it; step on when space allows'),
    (4, 'Central midfielders', 'Constantly offer passing lanes, look for wing space, combine/rotate with the forward'),
    (5, 'Forward', 'Stay high and central; make diagonal runs into space behind advanced full backs')
) AS v(so, role, job);

-- 36. pp.126-143
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'out_of_possession', 'Defensive Roles and Responsibilities / 7a Team Defensive Shape (3-2-1 High Press Mid Block)', '3-2-1 compact block, block central lanes',
    'Defending in 3-2-1: back three in a flat line, the two midfielders close together shifting with the ball, forward screening central passes. Full backs tuck in when the ball is central and close wingers without being dragged too wide; CB marks the forward and organises.',
    'Opponent in possession / building from GK',
    'Shrink the space, keep numbers around the ball and regain it as a team.',
    NULL, 126, 143, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'First press on the keeper''s pass out; force play to one side, block passes into midfield'),
    (2, 'Central midfielders', 'Move together as if tied by a rope: ball-side presses, weak-side protects the centre; never both chase'),
    (3, 'Full backs', 'Tuck in when ball is central, close wingers, help cover central runners'),
    (4, 'Centre back', 'Mark the forward, organise and communicate, delay when needed'),
    (5, 'Goalkeeper', 'Step high to read through balls and support the back line; command the box on set pieces')
) AS v(so, role, job);

-- 37. pp.129-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Tactical 7v7: ''Build Up from the Back''', 'Build up from the back, two options',
    'Keeper plays short to a centre back who receives half-turned and scans; full backs go as wide as possible and midfielders shift away from their markers to give angled support, so the carrier always has at least two safe passes.',
    'Goalkeeper restarts / has the ball',
    'Play out under control on the ground and progress or recycle safely.',
    NULL, 129, 129, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Play on the ground to the centre back or a wide full back'),
    (2, 'Centre back', 'Receive half-turned, scan all options, stay composed'),
    (3, 'Full backs', 'Stay as wide as possible'),
    (4, 'Central midfielders', 'Lose markers and offer angled support'),
    (5, 'Forward', 'Give depth or drop to link')
) AS v(so, role, job);

-- 38. pp.130-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Tactical 7v7: ''Advanced Attacking Full Backs''', 'Full back overlap creates wide overload',
    'When the ball goes wide to the forward or a midfielder, the full back overlaps to create a 2v1 on the flank, then pushes into the final third to cross, cut back or finish. Both CMs stay inside to leave the outside lane free and keep balance.',
    'Forward/CM receives wide and needs support',
    'Overload the flank and use the advanced full back to deliver the final action.',
    NULL, 130, 131, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back', 'Time an overlapping run, then cross, cut back or finish'),
    (2, 'Weak-side full back', 'Hold width to provide attacking support'),
    (3, 'Central midfielders', 'One tucks inside for balance, the other supports the overload; leave outside space free'),
    (4, 'Forward', 'Combine with the overlapping full back and attack the box')
) AS v(so, role, job);

-- 39. pp.132-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Tactical 7v7: ''Third Man and Overlapping Runs''', 'Third-man midfield run, full back covers',
    'A central midfielder makes a forward or overlapping third-man run beyond the forward; to keep rest-defence, the full back on that side steps infield to cover and the other CM stays central.',
    'Ball reaches the forward / third man is free to run',
    'Break lines with a third-man run while keeping cover behind the attack.',
    NULL, 132, 133, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Running central midfielder', 'Make the penetrating run past the forward, with or without the ball'),
    (2, 'Other central midfielder', 'Hold the central position for cover and balance'),
    (3, 'Same-side full back', 'Move inside to cover the space the running CM left'),
    (4, 'Forward', 'Lay off/release to the third man, then attack the box')
) AS v(so, role, job);

-- 40. pp.134-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Tactical 7v7: ''Build Up Play Options'' 5a (Option 1)', 'CM wall pass or switch, read full back',
    'Ball goes GK to full back to central midfielder; the midfielder, half-turned and scanning, chooses between a wall pass back to an advancing full back or a switch to the other side, depending on whether the full back has stayed deep or pushed up.',
    'CM receives from the full back',
    'Pick the right build-up route (combine or switch) from the full back''s position.',
    NULL, 134, 134, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'Open body, receive on back foot, scan; wall pass or switch'),
    (2, 'Full backs', 'Take a deep or advanced position to offer different options'),
    (3, 'Centre back', 'Distribute calmly, play forward or recycle'),
    (4, 'Forward', 'Give a central option by dropping short or running in behind')
) AS v(so, role, job);

-- 41. pp.135-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Tactical 7v7: ''Build Up Play Options'' 5b (Option 2)', 'Direct diagonal to forward, CM exploits',
    'A full back pulls wide to receive from the keeper and plays a direct diagonal into the forward; the high opposite full back and the forward''s movement open central space for a midfielder to arrive into, who then runs with the ball toward goal.',
    'Full back wide with a clear diagonal lane to the forward',
    'Skip the press with a direct pass and exploit the space created in the centre at speed.',
    NULL, 135, 152, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back on the ball', 'Pull wide to receive from GK, play the direct diagonal'),
    (2, 'Opposite full back', 'Push high to stretch play and provide wide support'),
    (3, 'Forward', 'Move to receive and drag defenders, opening space'),
    (4, 'Central midfielders', 'Time runs into the vacated space, combine, then drive at goal')
) AS v(so, role, job);

-- 42. pp.136-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Tactical 7v7: ''Build Up Play Options'' 5c (Option 3)', 'Switch play through central midfielders',
    'With both full backs high and wide, the ball is circulated via the centre back to a midfielder who switches it to the far full back; if the CB shifts across, the near full back goes high and wide.',
    'Full backs high and wide; ball-side is crowded',
    'Stretch the opponent and switch the point of attack into the free flank.',
    NULL, 136, 136, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Scan before receiving, spot the switch trigger, adjust for balance'),
    (2, 'Full backs', 'Stay wide and high to stretch the pitch and receive the switch'),
    (3, 'Centre back', 'Circulate the ball and offer safe recycling'),
    (4, 'Forward', 'Offer a central option and pull defenders out of position')
) AS v(so, role, job);

-- 43. pp.137-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Tactical 7v7: ''Build Up Play Options'' 5d (Option 4)', 'Reset via CB escape, rotate play',
    'When the forward route is blocked, the team goes back to the centre back as the ''escape option'' or the keeper and moves the ball quickly to the other side, with midfielders ''tied by a rope'' (one pushes, one covers) always offering angles.',
    'No way forward: forward lanes blocked',
    'Keep the ball patiently and switch the point of attack instead of forcing it.',
    NULL, 137, 158, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Stay behind the ball as constant support / escape option'),
    (2, 'Goalkeeper', 'Join circulation on the ground with the CB'),
    (3, 'Central midfielders', 'One pushes forward, the other holds; always offer a passing angle'),
    (4, 'Full backs', 'Stay wide, advance only when space allows'),
    (5, 'Forward', 'Occupy defenders and give depth; ready to exploit the switch')
) AS v(so, role, job);

-- 44. pp.138-171
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Tactical 7v7: ''Attacking Combinations'' 6a (Option 1)', 'Inside combination releases full back wide',
    'Midfielders dictate tempo by combining centrally with the forward (who drops into a passing lane) to draw the defence inside, then release the full back into the space outside.',
    'Opponent narrows to stop central combinations',
    'Attract pressure inside and exploit the wide space with the full back, then attack the box.',
    NULL, 138, 171, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Play centrally to attract pressure, then release wide or combine'),
    (2, 'Forward', 'Drop into the passing lane to combine, then get into the box'),
    (3, 'Full back', 'Exploit wide space after the inside combination'),
    (4, 'Centre back', 'Circulate and support behind')
) AS v(so, role, job);

-- 45. pp.139-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Tactical 7v7: ''Attacking Combinations'' 6b (Option 2)', 'Forward drags CB wide, CM attacks centre',
    'The forward moves out to the ball-side channel, pulling the opposing centre back with him; the central space he leaves is attacked by a midfielder. If the full back''s pass down the line is blocked, play inside to the CM.',
    'Forward''s wide movement is followed by the centre back',
    'Open the key central area for a midfielder to receive and progress.',
    NULL, 139, 139, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Move wide to drag the centre back out, link play'),
    (2, 'Central midfielder', 'Scan and time a run into the vacated centre'),
    (3, 'Ball-side full back', 'Give the wide option; play inside if the line is blocked'),
    (4, 'Opposite full back', 'Push high when space opens'),
    (5, 'Centre back', 'Support and recycle if progress is blocked')
) AS v(so, role, job);

-- 46. pp.140-172
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Tactical 7v7: ''Attacking Combinations'' 6c (Option 3)', 'Forward weak-side run frees CM, attack box',
    'The forward makes a diagonal run toward the weak side, taking the opposing centre back away from the ball; the midfielder arrives into the freed space to shoot or play the final pass while the forward continues into the box. Full backs keep width so the defence stays stretched.',
    'Ball on one side, CB tracking the forward',
    'Create a central shooting chance from the space the forward''s run leaves.',
    NULL, 140, 172, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Diagonal run to the weak side to drag the CB, then attack the box to finish'),
    (2, 'Central midfielders', 'Exploit the vacated space, shoot or play the final pass, or support inside'),
    (3, 'Full backs', 'Stay wide to stretch play and offer lanes'),
    (4, 'Centre back', 'Circulate and give a recycle option')
) AS v(so, role, job);

-- 47. pp.141-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Tactical 7v7: ''Attacking Combinations'' 6d (Option 4)', 'Full back inside, forward rotates wide',
    'When the central pass is blocked, the full back runs inside and his marker follows, opening wide space; the forward reads it and makes a diagonal run into that channel to receive, while midfielders support and cover behind.',
    'Central passing option blocked; full back''s marker tracks him inside',
    'Rotate positions to unbalance the back line and get the forward on the ball in wide space.',
    NULL, 141, 141, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back', 'Run inside to drag the marker away'),
    (2, 'Opposite full back', 'Hold the wide position'),
    (3, 'Forward', 'Time a diagonal run into the channel left free'),
    (4, 'Central midfielders', 'Support, create passing angles and cover behind'),
    (5, 'Centre back', 'Support possession, recycle via the keeper if needed')
) AS v(so, role, job);

-- 48. pp.144-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'out_of_possession', 'Defensive Roles and Positioning 7b (Option 2)', 'Response to keeper''s pass wide to full back',
    'When the keeper plays out to a full back, the forward presses him and cuts the pass back to GK/CB; the team shifts to the ball side, ball-side full back engages, ball-side CM drops in support, other CM holds the centre and far full back tucks into the back line.',
    'Goalkeeper passes wide to an opposing full back',
    'Trap the ball near the touchline with the centre protected.',
    NULL, 144, 144, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Press the full back and block the pass back to GK and CB'),
    (2, 'Ball-side full back', 'Engage the ball directly'),
    (3, 'Ball-side central midfielder', 'Drop back to support'),
    (4, 'Other central midfielder', 'Hold a central position for cover and balance'),
    (5, 'Centre back', 'Cover inside space and support the full back'),
    (6, 'Far full back + GK', 'Tuck in to protect the centre; GK advanced to cover behind the CB')
) AS v(so, role, job);

-- 49. pp.156-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Example Session 2 / Attacking Overloads (2v1)', '2v1 overload: angled support, timed release',
    'In a 2v1 the supporting player offers an angled run and the carrier holds the ball to draw the defender before releasing at the right moment; defenders read the lane and press with control.',
    'Defender commits to the ball carrier',
    'Beat a single defender through a well-timed pass or disguise.',
    NULL, 156, 156, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Draw the defender, use disguise, release at the right moment'),
    (2, 'Support player', 'Make an angled supporting run to give the pass'),
    (3, 'Defender', 'Read the passing lane, press with controlled aggression')
) AS v(so, role, job);

-- 50. pp.162-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Example Session 3 / Dribbling (Dribble to Commit Defender)', 'Beat or commit marker before passing',
    'In possession with a numerical edge, the carrier uses a feint or dribble to draw/beat his marker before releasing the pass, then moves away from pressure with directional control.',
    'Marker approaches the carrier',
    'Commit a defender to free a teammate and open a better passing line.',
    NULL, 162, 162, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Feint or dribble to draw the defender in, then pass'),
    (2, 'Supporting players', 'Create and use passing lines in the space opened')
) AS v(so, role, job);

-- 51. pp.169-169
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'catalan-academy-coaching-u7-12-the-world-s-best-youth-training-program-110-pract'), 'in_possession', 'Example Session 4 / Breaking Lines Through Zones', 'Break the press zone by zone, follow pass',
    'Build-up 4v2 breaks the first line with a pass into a teammate in the middle zone; the passer runs on to support, making 2v1, then the attack enters the scoring zone with extra support (2+2v1) to finish. Dribbling into the middle zone instead brings three attackers forward.',
    'Pass breaks a line into the next zone',
    'Progress through successive lines with numerical superiority and finish decisively.',
    NULL, 169, 169, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Build-up players', 'Move the ball quickly to break the first press'),
    (2, 'Middle-zone receiver', 'Receive between lines and turn/combine'),
    (3, 'Passer', 'Follow the pass forward to create the 2v1'),
    (4, 'Wide supports', 'Join the finish in the scoring zone')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1979-coaching-book-catalan-academy-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
