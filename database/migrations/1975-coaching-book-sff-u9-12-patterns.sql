-- 1975 📚 Coaching book patterns: "Spanish Football Federation Coaching Program U9-12" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Spanish Football Federation Coaching Program U9-12',
    author      = 'Eduardo Valcárcel',
    team        = 'RFEF coaching school (foreword by Vicente del Bosque)',
    method_note = 'The Spanish Federation school''s practice programme for 9-12 year olds in 11 chapters: running with the ball, dribbling and 1v1s, duels (2v1 to 3v3), passing, rondos, possession games, heading, finishing, combination play, tactical development (building out in a 3-3-1) and circuits. Method: one child one ball, no queues, always with the ball, game-like practices with opposition scaled up gradually. Patterns are the decisions and team behaviours the practices teach, in our words; technique-only drills are left out.'
WHERE slug = 'spanish-football-federation-coaching-program-u9-12';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12');

-- 1. pp.15-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch.1 Running with the Ball at Speed - methodology', 'Carry at speed into open space',
    'The ball carrier has no good forward pass, and there is free space ahead with no opponent in it.',
    'No forward pass option and open space in front',
    'Gain ground fast with the ball, using the laces, still able to slow down, turn or change direction at a cone or near a defender.',
    NULL, 15, 24, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'push the ball forward with the laces at full speed, either foot'),
    (2, 'Ball carrier near a defender', 'slow down, then make one sharp change of direction to get past and away'),
    (3, 'Teammates', 'keep positions spread in the 3-3-1 so the carrier can hand on or pass at the next spot')
) AS v(so, role, job);

-- 2. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch.1 Quick Decision Making & RWTB at Speed in Different Situations', 'Read the defender: one-two, 1v1 or drive',
    'A carrier heading at one defender has to look up and pick a solution based on where that defender stands.',
    'Defender''s position seen when the carrier looks up',
    'Pick the right action every time instead of a fixed habit.',
    NULL, 21, 21, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'defender sitting central: play a one-two around him and collect the return'),
    (2, 'Ball carrier', 'defender square on in front: take him on 1v1'),
    (3, 'Ball carrier', 'defender close but off to one side: drive past into the free space at speed'),
    (4, 'Wall player / defender', 'after each action, move to a new corner so the picture keeps changing')
) AS v(so, role, job);

-- 3. pp.23-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch.1 RWTB at Speed to Lose a Marker (Shadowing in Pairs)', 'Break away from a tight shadow',
    'A player on the ball is being tight-marked and followed by one opponent.',
    'Marker tight on the ball carrier',
    'Keep the ball and create separation from the marker by speed and changes of direction.',
    NULL, 23, 31, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'sudden bursts and changes of direction to get out of the marker''s shadow'),
    (2, 'Marker', 'follow every movement and try to win the ball')
) AS v(so, role, job);

-- 4. pp.26-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch.2 Dribbling Past Opponents - methodology', 'Dribble when needed, more near goal',
    'Dribbling is a weapon to use when the situation calls for it, more freely the closer the player is to the opponents'' goal; beat a front-on defender with a move and a change of direction on either side.',
    'Front-on defender blocks the way, especially in the final third',
    'Beat the man and go through toward goal or the end zone, rather than just shielding.',
    NULL, 26, 34, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'run at the defender at speed, time the touch away from him, use both feet and both sides'),
    (2, 'Ball carrier in front of goal', 'beat the defender and finish quickly, inside about 7 seconds of receiving'),
    (3, 'Ball carrier under pressure', 'keep facing opponents and try to go past them, not just turn and shield')
) AS v(so, role, job);

-- 5. pp.28-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'out_of_possession', 'Ch.2 Dribbling to Beat an Opponent in a Zonal 1 v 1 Duel', '1v1 defending: drop, set, pick moment',
    'A lone defender faces a dribbler running at him.',
    'Attacker carries the ball toward the defender''s zone',
    'Stop the dribbler and win the ball rather than diving in early.',
    NULL, 28, 34, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '1v1 defender', 'drop back a step to buy room, set the body side-on, choose the moment to tackle'),
    (2, '1v1 defender', 'if passed, keep chasing to recover the ball')
) AS v(so, role, job);

-- 6. pp.28-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'to_attack', 'Ch.2-3 duel games (role swap on regain)', 'Win the duel, break the other way',
    'In the 1v1, 2v2 and 3v2 games, a defender or defending pair who win the ball attack the opposite goal or end zone straight away, while the side that lost it tries to win it back.',
    'Ball won in a duel',
    'Turn the regain into an immediate attack before the attackers who lost it can recover.',
    NULL, 28, 46, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins the ball', 'carry or pass forward at once toward the far goal or end zone'),
    (2, 'Player who loses the ball', 'chase straight away to recover it'),
    (3, 'Neutral / support player', 'joins whichever side has the ball to give an extra man')
) AS v(so, role, job);

-- 7. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch.3 Lose Marker, Receive and Pass Back', 'Check away to receive in space',
    'A forward is marked tight and his teammate has the ball further back.',
    'Teammate on the ball looking to pass',
    'Get free of the marker so the pass can be received in space and played back or turned.',
    NULL, 37, 37, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'move one way, then spin the other way into space away from the marker'),
    (2, 'Passer', 'play the ball into the space the receiver has opened up'),
    (3, 'Marker', 'stay goal-side and try to intercept')
) AS v(so, role, job);

-- 8. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'out_of_possession', 'Ch.3 Quick Attack in a 2 v 1 (+1 Supporting Player) Duel', 'Lone defender delays for the recovering defender',
    'One defender caught 2v1 while a teammate sprints back.',
    'Outnumbered 2v1 with a recovering teammate',
    'Hold up the attack until the recovering defender gets back and makes it 2v2.',
    NULL, 38, 38, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First defender', 'delay: jockey and slow the ball without diving in'),
    (2, 'Recovering defender', 'sprint back as soon as the attack starts to get numbers level')
) AS v(so, role, job);

-- 9. pp.38-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch.3 Quick Attack in a 2 v 1 (+1 Supporting Player) Duel', 'Strike the 2v1 before help arrives',
    'Two attackers face one defender with a second defender recovering from behind.',
    '2v1 overload in the final third',
    'Score in a few seconds with a one-two, a carry or a pass, before the overload disappears.',
    NULL, 38, 42, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'drive at the defender to commit him, then pass or go alone'),
    (2, 'Second attacker', 'give a passing angle or a one-two and move up level'),
    (3, 'Both attackers', 'aim to finish within about 7 seconds')
) AS v(so, role, job);

-- 10. pp.41-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch.3 Fast Attack in a 3 v 2 Duel', 'Fast 3v2 combination to finish',
    'Three attackers break against two defenders who step forward the moment the first pass is played.',
    'Pass into the central attacker',
    'Use the spare man with quick passes to score in the shortest time.',
    NULL, 41, 46, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central attacker', 'receive and commit a defender, then lay it off'),
    (2, 'Two side attackers', 'move forward off the ball wide to give passing lanes'),
    (3, 'Neutral / side support players', 'add the extra man in 2v2 games to make the overload')
) AS v(so, role, job);

-- 11. pp.42-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch.3 Consecutive 2 v 1 Duels with Attackers Split into 2 Side Channels', 'Hold your lane to stretch the defender',
    'Two attackers in a 2v1 each stay in their own half-width channel while beating defenders one zone at a time.',
    '2v1 against a defender who can only cover one zone',
    'Width forces the lone defender to choose, so the free man receives or the carrier drives on to finish.',
    NULL, 42, 42, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side attacker', 'dribble into the next zone or release the ball once the defender commits'),
    (2, 'Far-side attacker', 'stay wide in your own channel ready to receive and finish'),
    (3, 'Zone defender', 'defends only his own half of the pitch')
) AS v(so, role, job);

-- 12. pp.43-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch.3 Awareness, Quick Reactions to Receive and 2 v 2 Duels', 'Scan, react, attack the open goal',
    'A pair has to react to a call, find which teammate has the ball, receive from them and attack either of two goals 2v2.',
    'Signal and the source of the ball',
    'Quick awareness: pick up the ball and attack whichever goal is less defended.',
    NULL, 43, 43, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking pair', 'look for the feeder, receive, and choose the goal the defenders are not covering'),
    (2, 'Defending pair', 'react to the receiving side and protect both goals')
) AS v(so, role, job);

-- 13. pp.45-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'to_attack', 'Ch.3 1 v 1 Duels into Collective 3 v 2 Duel', 'Duel winners join one collective attack',
    'After separate 1v1 battles, the players who end up with the ball push forward together to attack the goal, while the losers'' side drops back to defend.',
    'Coach''s signal ends the individual duels',
    'Turn several individual duels won into a shared numerical-advantage attack.',
    NULL, 45, 45, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central winner', 'collect the ball in the middle and start the 3v2'),
    (2, 'Wide winners', 'break forward on both sides as passing options'),
    (3, 'Defending side', 'leave their squares and get goal-side to defend 2v3')
) AS v(so, role, job);

-- 14. pp.47-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'to_attack', 'Chapter 3: Duels - Continuous 3 v 3 Duel Team Game', 'Win it and attack straight away',
    'Small-sided 3v3 between waves of teams; the side that wins the ball (or the GK save) immediately becomes the attacking team going the other way.',
    'Ball won or goal scored',
    'Attack fast before the new defenders organise, scoring as quickly as possible.',
    NULL, 47, 48, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'turn and go forward at once, no reset'),
    (2, 'Two teammates', 'spread to give 3v3 width and depth'),
    (3, 'Goalkeeper', 'restart quickly to the attacking trio')
) AS v(so, role, job);

-- 15. pp.50-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Chapter 4: Passing - Passing Training Methodology / Y Shape / Double Square', 'Check away, receive on the move',
    'Receivers do not wait on their spot; they step away from the cone (and the marker) and come back to take the ball moving, then play forward quickly.',
    'Teammate ready to pass',
    'Receive already moving with time to play the next pass, short or long.',
    NULL, 50, 57, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'check away opposite way, then come to the ball at an angle'),
    (2, 'Passer', 'play into the path, then follow the pass to the next spot')
) AS v(so, role, job);

-- 16. pp.51-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Chapter 4: Passing - Free Passing in Pairs / Continuous 2 v 1 / One-Two Combinations', 'Pair combines to beat a defender (one-two)',
    'Two attackers against one or two defenders guarding a gate or the ball; the carrier commits the defender and uses a wall pass or pass through the gate to get past.',
    'Defender steps to the ball carrier',
    'Get the ball and a runner beyond the defender while keeping possession.',
    NULL, 51, 54, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'dribble at the defender, release as he commits, run past'),
    (2, 'Support player', 'offer an angle beside the defender, return first time into the run')
) AS v(so, role, job);

-- 17. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Chapter 4: Passing - One-Two on the Outside, Pass and Supporting Run on the Inside', 'Wide one-two then inside lay-off (third man)',
    'Wide player plays a one-two down the side, then passes inside to a central player who lays the ball off into the path of the original wall-passer arriving on a supporting run.',
    'Return pass received in wide channel',
    'Third-man combination releases a runner moving forward with the ball.',
    NULL, 58, 58, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide carrier (A)', 'one-two with B, then pass inside to C'),
    (2, 'Wall player (B)', 'return first time, then make the supporting run forward'),
    (3, 'Central player (C)', 'lay off first time into B''s run, then shift across')
) AS v(so, role, job);

-- 18. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Chapter 4: Passing - Building Up Play to Pass and Switch Play in a 1 v 1 Channel Game', 'GK build-up through all three channels',
    'Pitch split into three channels each with a 1v1; GK starts in the middle and the team must use every channel (switching play) before scoring in a small goal.',
    'GK has the ball',
    'Patient build-up from the back that switches the point of attack to find the free channel.',
    NULL, 59, 59, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'start build-up to any channel player'),
    (2, 'Channel players', 'get free from the 1v1 to receive, then switch to another channel'),
    (3, 'Defenders (on regain)', 'leave channels freely to counter')
) AS v(so, role, job);

-- 19. pp.60-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Chapter 4: Passing - Passing Forward in a 3 Zone Small Sided Game', 'Pass forward and step up a line',
    '8v8 in three zones (3v1 build-up, 3v3 midfield, 1v3 attack); after a forward pass one player may run up into the next zone to receive, making 4v3 then 3v2.',
    'Forward pass played into next zone',
    'Create a numerical superiority in each line by a player breaking forward behind the ball.',
    NULL, 60, 60, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three + GK', 'use the 3v1 to find a free midfielder'),
    (2, 'Midfielder who steps up', 'run forward into the next zone to receive'),
    (3, 'Lone forward', 'hold the ball against three until support arrives')
) AS v(so, role, job);

-- 20. pp.64-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Chapter 5: Rondos - 5 v 2 Rondo with Movement to Switch Sides', 'Rondo: pass and move to open side',
    '5v2 where two players share a side; they cannot pass to each other and whoever passes must move to the opposite side, max two touches.',
    'Pass made from the doubled side',
    'Keep angles open and possession under pressure by constant relocation after passing.',
    NULL, 64, 64, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer on doubled side', 'pass then move to the opposite side'),
    (2, 'Other outside players', 'keep the shape, offer both sides of the ball')
) AS v(so, role, job);

-- 21. pp.65-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Chapter 5: Rondos - 4 (+1) v 2 Rondo with Inside Player', 'Find the inside man, then swap',
    'Four outside and one inside player against two; play aims to find the central player, who must keep moving to stay available; after he passes out he swaps with that receiver.',
    'Gap opens between the two defenders',
    'Play through the middle of the pressure, not only around it.',
    NULL, 65, 65, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside player', 'never stand still, show between the defenders'),
    (2, 'Outside players', 'look inside first, swap in after receiving from him')
) AS v(so, role, job);

-- 22. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'out_of_possession', 'Chapter 5: Rondos - 5 v 2 Rondo Hit the Middle Cone', 'Pressing pair closes angles and centre',
    'Two defenders in a 5v2 must both intercept and stop passes through to a central target; outside players score for passes and more for hitting the middle.',
    'Ball moving around the outside',
    'Defend as a coordinated pair: one presses, one screens the central lane.',
    NULL, 66, 66, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing defender', 'close the ball carrier''s passing angle'),
    (2, 'Covering defender', 'screen the path to the centre and talk'),
    (3, 'Outside players', 'keep possession and split the pair when the centre opens')
) AS v(so, role, job);

-- 23. pp.67-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'to_defend', 'Chapter 5: Rondos - Transition from Attack to Defence in Simultaneous 4 v 1 Rondos / 4 v 2 Rondos', 'Lose it, become the defender',
    'Simultaneous rondos where the player (or pair) who loses the ball must instantly switch to defending role in another rondo.',
    'Ball lost',
    'Instant mental switch from attack to defence with no pause.',
    NULL, 67, 69, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost the ball', 'react at once and go defend'),
    (2, 'Ball winner', 'move straight to the outside to support possession')
) AS v(so, role, job);

-- 24. pp.68-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Chapter 5: Rondos - Changing 4 v 1 Rondo Positions with Support Play in 4 Squares', 'Switch the area, whole group shifts',
    '4v1 rondo in one of four squares; a player on the edge can turn and play into an adjacent square, and all but one teammate move across to rebuild the rondo there.',
    'Ball switched to new square',
    'Escape pressure by switching, then rebuild support quickly in the new space.',
    NULL, 68, 68, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Edge player', 'receive, turn and switch to waiting teammate'),
    (2, 'Supporting players', 'sprint across to recreate the shape'),
    (3, 'Defenders', 'spare defender enters the new square')
) AS v(so, role, job);

-- 25. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Chapter 5: Rondos - End to End 4 (+3) v 4 Rondo', 'Move the ball end to end through neutrals',
    '7v4 with two of the team at each end and neutrals at the sides and inside; aim is to shift the ball from one end to the other and back; on loss roles swap.',
    'Possession settled at one end',
    'Circulate through the middle to switch play end to end.',
    NULL, 70, 70, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'End players', 'receive and look to the far end'),
    (2, 'Central neutral', 'link between the ends'),
    (3, 'Inside players', 'show between defenders, swap to outside on loss')
) AS v(so, role, job);

-- 26. pp.71-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Chapter 6: Possession Games - Increasing Opposition / Three Team 4 (+4) v 4 / Support Play in 8 v 6 / Quick Reaction Sprints', 'Constant support for the ball carrier',
    'Overload possession games (5v1 rising to 5v5, 8v4, 8v6 with neutrals) where outside players are limited to one touch so inside players must quickly offer a return option.',
    'Teammate receives under pressure',
    'Keep possession by always giving the carrier close, angled support.',
    NULL, 71, 81, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside players', 'move to an open angle to receive back immediately'),
    (2, 'Outside players', 'one or two touch, keep width'),
    (3, 'Defenders', 'press as numbers increase')
) AS v(so, role, job);

-- 27. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Chapter 6: Possession Games - Possession Game with Players Switching Inside / Outside', 'Pass wide and interchange positions',
    '6v4 using two wide outside players; the inside player who finds the wide man swaps places with him, who then carries or passes inside.',
    'Pass to wide player',
    'Rotation between inside and wide roles keeps the shape while changing who occupies it.',
    NULL, 76, 76, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside passer', 'pass wide then take the wide spot'),
    (2, 'Wide player', 'dribble inside or pass in, become an inside player')
) AS v(so, role, job);

-- 28. pp.77-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Chapter 6: Possession Games - Three Team Possession Game with Receiving Corners', 'Time the run into the free zone',
    '8v4 possession; points scored by receiving inside a corner zone, and in the variation players may only enter the zone after the pass is played.',
    'Pass about to be played into space',
    'Arrive in free space at the right moment instead of standing there early.',
    NULL, 77, 77, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'time the run to arrive in the zone with the ball'),
    (2, 'Ball carrier', 'play into the zone as the run starts'),
    (3, 'All teammates', 'stay mobile to support the carrier')
) AS v(so, role, job);

-- 29. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'to_attack', 'Chapter 6: Possession Games - Possession Play in a 2 Zone Transition Game', 'Regain, then exit to the other zone',
    'Two zones; possession 7v5 with neutrals in one; the side that wins the ball must pass quickly into the empty zone and everyone moves across.',
    'Ball won',
    'Escape the area of the regain with a quick forward or lateral pass, then keep it.',
    NULL, 78, 78, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'play quickly into the other zone'),
    (2, 'Teammates', 'sprint across to receive and support'),
    (3, 'Team that lost it', 'chase across to press again')
) AS v(so, role, job);

-- 30. pp.79-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Chapter 6: Possession Games - Retain the Ball and Switch Play / Possession and Switching Play in a Three Team Zonal Game', 'Keep it, then switch to far side',
    'Teams must complete a set number of passes (around five) in their zone and then play across or over the middle to the far target or team without being intercepted.',
    'Pass count reached',
    'Use possession to draw the opponent, then switch play to the far side.',
    NULL, 79, 80, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Team in possession', 'keep the ball, count passes, look for the far side'),
    (2, 'Middle defenders', 'two press, the rest cut the switching lane'),
    (3, 'Far team / GK target', 'be ready to receive the switch')
) AS v(so, role, job);

-- 31. pp.85-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'set_piece', 'Chapter 7: Heading - Competing for Headers / Hand + Header games / Sprint + Headed Finish', 'Attack the ball in the air',
    'Games and duels where finishing must be with the head from a throw or chip, often from wide, and a defender contests passively then actively.',
    'Ball served in the air',
    'Judge the flight, attack the ball first and head on target or to a teammate.',
    NULL, 85, 91, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Header / finisher', 'read the flight, jump and win the header'),
    (2, 'Server (wide)', 'deliver at varied heights and angles'),
    (3, 'Defender', 'contest the header, passive then active')
) AS v(so, role, job);

-- 32. pp.92-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'to_attack', 'Chapter 7: Heading - Headed Passes and Quick Break Away with Finish', 'First to the ball breaks to goal',
    'Groups heading the ball between them; on a call, whichever called player gets the ball controls it and dribbles at full speed to the far goal.',
    'Coach''s call / ball won',
    'React fastest, control and break at speed to finish.',
    NULL, 92, 92, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Called player with ball', 'control and dribble at top speed to goal'),
    (2, 'Uncalled players', 'defend to stop the breakaway')
) AS v(so, role, job);

-- 33. pp.93-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'to_attack', 'Ch7 Heading - Connected 2 Zone Duels with Headers + Counter Attacks', 'Keeper save or regain launches instant counter',
    'Attackers try to score in a 2 v 2 zone; when the keeper saves or a defender wins it, that side breaks straight away towards the opposite goal through traffic.',
    'Keeper save or ball won by defenders',
    'Turn defence into a fast attack before the opponent can recover.',
    NULL, 93, 93, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Release quickly to a defender after the save'),
    (2, 'Defenders who won it', 'Drive forward and attack the far goal immediately'),
    (3, 'Former attackers', 'Recover or obstruct the counter')
) AS v(so, role, job);

-- 34. pp.93-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch7 Heading - Connected 2 Zone Duels / Hands + Headers SSG with Wide Players', 'Play wide, run into box, attack delivery',
    'In a small game the ball is moved out to a wide player, the passer runs on into the next zone and the wide man serves the ball back for a headed finish.',
    'Ball played to the wide player',
    'Use width to create a delivery for an arriving runner to finish in the air.',
    NULL, 93, 94, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside attacker', 'Pass wide, then run into the scoring zone'),
    (2, 'Wide player', 'Deliver the ball to the head of the arriving runner'),
    (3, 'Defenders', 'Mark a man each and compete for the header')
) AS v(so, role, job);

-- 35. pp.96-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch8 Finishing - Finishing Training Methodology', '''Pass at goal'' finishing rule',
    'Close to the keeper the finisher''s last touch sets the ball in front at the right weight, towards goal or angled away from a defender, then places it far from the keeper instead of blasting.',
    'Attacker approaching the goalkeeper',
    'Higher scoring rate through accurate placement and a good preparatory touch.',
    NULL, 96, 101, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Finisher', 'Touch towards goal or away from defender, then place the shot far from the keeper'),
    (2, 'Finisher', 'Use both feet and different parts of the foot')
) AS v(so, role, job);

-- 36. pp.100-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch8 Finishing - One-Two, Open Up, Receive + Shoot', 'One-two then receive on the half-turn',
    'The attacker plays into a teammate and moves to one side; the teammate reads the movement and returns the ball to that side so the attacker opens up, receives half-turned and takes a touch into the box to shoot.',
    'Attacker''s movement to one side after passing',
    'Arrive facing goal with the ball after a wall pass.',
    NULL, 100, 101, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacker (A)', 'Pass, move to one side, open body and receive on the half-turn'),
    (2, 'Wall player (B)', 'Read the movement and set the ball into that side; then press the shooter')
) AS v(so, role, job);

-- 37. pp.102-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch8 Finishing / Ch9 Combination Play - Three Player Combination; Inside Movement to Receive', 'Read the drop, move opposite (third man)',
    'A front player drops off to one side; the next player reads it and moves the opposite way or inside, receives the set and plays in a runner moving forward who receives on the move and shoots.',
    'First player''s drop or movement to one side',
    'Create a free third man arriving at the box through coordinated opposite movements.',
    NULL, 102, 115, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping forward (B)', 'Drop at an angle to either side and lay the ball off'),
    (2, 'Second player (C)', 'Move the opposite way or inside off the marker and pass in front'),
    (3, 'Deep player (A)', 'Pass to the side the forward chose, then support'),
    (4, 'Runner (D)', 'Make the advanced run and finish first time or after a control')
) AS v(so, role, job);

-- 38. pp.103-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch8 Finishing - Quick Combination, Supporting Run from Wide + Finish', 'Wide player''s diagonal run onto through pass',
    'After a quick inside combination between central players, the wide player makes a forward diagonal run inside and the ball is played in front of him into the penalty area to shoot.',
    'Central player receives facing forward after the combination',
    'Break into the box from the flank with a timed diagonal run.',
    NULL, 103, 103, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (A)', 'Combine short, then pass ahead of the runner'),
    (2, 'Forward (B) / opposite wide (C)', 'Move off markers to set and switch the ball'),
    (3, 'Wide player (D)', 'Diagonal run inside to receive and finish')
) AS v(so, role, job);

-- 39. pp.104-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch8 Finishing - Double One-Two and Finishing Practice', 'Double one-two to reach goal',
    'The ball carrier plays two consecutive wall passes with teammates who step off their markers to bounce it back, receiving each time on the move before shooting.',
    'Teammates step off markers to offer a return',
    'Advance through a defence with quick returned passes received on the run.',
    NULL, 104, 104, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier (A)', 'Keep moving forward and receive each return on the move'),
    (2, 'Wall players (B, C)', 'Come off the cone and return first or second touch')
) AS v(so, role, job);

-- 40. pp.105-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch8 Finishing - Short and Long Passing with Finishing from Cut Backs', 'Deep ball wide, byline cut-back',
    'A player plays inside and runs long down the side; the inside man plays a deep pass outside the line into his path, he carries to the byline area and cuts the ball back to a central teammate who turns and shoots.',
    'Space behind the defence out wide',
    'Finish from a cut-back delivered from near the byline.',
    NULL, 105, 105, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide runner', 'Pass inside, long run forward, dribble round and cut back'),
    (2, 'Inside player', 'Play the deep pass into the runner''s path'),
    (3, 'Central finisher', 'Arrive in the centre and finish the cut-back first time')
) AS v(so, role, job);

-- 41. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch8 Finishing - Finishing in a 3 v 3 SSG with 2 Extra Attacking Outside Players', 'Quick attack using wide outlet players',
    'From the goalkeeper the team attacks fast in a 3 v 3, using touchline outlet players in the attacking half who play one touch, including passes or crosses straight into a finish.',
    'Goalkeeper restart / possession won',
    'Score quickly by exploiting the wide numerical advantage.',
    NULL, 106, 106, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside players', 'Two touches max, attack quickly and use the outside man'),
    (2, 'Outside players', 'One touch: return or deliver for a direct finish'),
    (3, 'Goalkeeper', 'Start the attack quickly')
) AS v(so, role, job);

-- 42. pp.109-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch9 Attacking Combination Play - Two Mirrored One Touch Combinations', 'Lead pass then square ball across box',
    'Two attacking sequences arrive simultaneously; the last pass is played ahead of the runner and he slides it across to the teammate arriving on the other side to score.',
    'Final pass played in front of the runner',
    'Beat the keeper with a square pass between two simultaneous arrivals.',
    NULL, 109, 110, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Runner on receiving side (No.5)', 'Run onto the lead pass and square it across first time'),
    (2, 'Runner on opposite side', 'Time the arrival to finish the square ball'),
    (3, 'Midfield passers', 'One-touch combinations, follow the pass')
) AS v(so, role, job);

-- 43. pp.111-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch9 Attacking Combination Play - Combination Play to Receive High Up on Flank / Fast Support / Receive on the Flank', 'Striker drop, lay-off, ball out wide, cross',
    'The forward drops to receive, lays the ball off to a supporting midfielder who plays it out to a wide player bombing high up the flank; the wide man crosses while forward and midfielder (and every earlier passer) run into the box.',
    'Forward drops off his marker to receive',
    'Use the forward''s lay-off to switch the ball wide and fill the box for the cross.',
    NULL, 111, 117, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (C)', 'Drop to receive, lay off, then turn and attack the box'),
    (2, 'Supporting midfielder (B)', 'Move forward for the lay-off and pass wide high up'),
    (3, 'Wide player (A/D)', 'Advance up the flank, receive on the move and cross'),
    (4, 'Every passer', 'After the pass, run into the box to finish')
) AS v(so, role, job);

-- 44. pp.112-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch9 Attacking Combination Play - Flank Play / Pass High Up the Flank', 'Ball high up flank, curved run into box',
    'A central player receives and plays out to a teammate who has run high up the flank; the passer makes a curved run around into the penalty area while the original passer arrives diagonally, and the wide player crosses for either.',
    'Winger''s advanced run up the flank',
    'Deliver from high wide areas to two arriving finishers.',
    NULL, 112, 113, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central receiver (B)', 'Move forward to receive, pass wide, then curve run into the box'),
    (2, 'Starter (A)', 'Pass inside then diagonal run to the box'),
    (3, 'Wide player (C)', 'Advanced run up the flank, receive high and cross or cut back')
) AS v(so, role, job);

-- 45. pp.118-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'to_attack', 'Ch9 Attacking Combination Play - Win the Ball (2 v 4) in the Centre and Counter Attack Combination', 'Central regain, forward ball to striker',
    'Two players pressing a 4 v 2 in midfield win the ball and immediately pass to a forward who comes to receive, with a wide player available on one side; both ball-winners sprint forward to join, while two opponents track back.',
    'Ball won in the central area',
    'Finish a counter quickly before the trackers recover.',
    NULL, 118, 118, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two central ball-winners', 'Press the 4 v 2, win it, pass forward and join the attack'),
    (2, 'Forward', 'Move to receive the first pass and combine'),
    (3, 'Wide player', 'Offer width high on either side and deliver'),
    (4, 'Two opponents nearest', 'Track back to defend; others stay central')
) AS v(so, role, job);

-- 46. pp.120-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'in_possession', 'Ch10 Tactical Development - Build Up to Finish in 8 v 2 / 8 v 3 / 8 v 4 / 8 v 8 Zonal Games', '3-3-1 build-up from goalkeeper on the ground',
    'In 8 v 8 with a 3-3-1 the team starts from the goalkeeper and moves the ball through the back three, midfield three and forward with ground passes, against zonal defenders added stage by stage, often running a coach-called set pattern or restart (throw-in, ball just won).',
    'Goalkeeper has the ball / coach calls pattern number',
    'Progress from the keeper to a finish through the lines without long balls.',
    NULL, 120, 125, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Start every attack with a short pass to a back three player'),
    (2, 'Back three (2, 4, 3)', 'Spread wide, receive and pass into midfield; all three may be required to touch it'),
    (3, 'Midfield three (5, 6, 7)', 'Wide mids offer width and carry into the final zone; 6 links centrally'),
    (4, 'Forward (8)', 'Show to receive between lines, lay off or attack the cross')
) AS v(so, role, job);

-- 47. pp.122-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'to_defend', 'Ch10 Tactical Development - Build Up to Finish in an 8 v 3 Zonal Game + Quick Transition', 'Press immediately after losing the ball',
    'When a defender intercepts during the build-up, the nearest attackers close him down at once so he cannot find a teammate; regaining it before his pass lets the attack continue.',
    'Ball lost during build-up',
    'Win the ball back before the opponent can make a first pass.',
    NULL, 122, 124, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest attackers', 'Sprint to the ball winner and block his passing line'),
    (2, 'Other attackers', 'Cut off the pass to his teammate and be ready to resume the attack')
) AS v(so, role, job);

-- 48. pp.131-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-football-federation-coaching-program-u9-12'), 'to_attack', 'Ch11 Circuits - Speed & Agility Circuit Training with Finishing (3 v 1) / 3 v 2 Duel', 'Fast numbers-up break into box',
    'A player carries the ball forward and launches a quick 3 v 1 or 3 v 2 attack: a ball out wide for a runner to cross, while the other attackers sprint into the box, against recovering defenders.',
    'Ball carried forward with a numerical advantage',
    'Exploit the extra man quickly before defenders recover.',
    NULL, 131, 132, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central carrier', 'Drive forward and release wide at the right moment'),
    (2, 'Wide runner', 'Sprint onto the pass and cross for arriving teammates'),
    (3, 'Third attacker', 'Run into the box to finish'),
    (4, 'Recovering defenders', 'Sprint into the centre of the box to defend')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1975-coaching-book-sff-u9-12-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
