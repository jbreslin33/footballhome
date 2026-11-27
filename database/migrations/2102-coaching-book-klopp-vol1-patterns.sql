-- 2102 📚 Coaching book patterns: "Jurgen Klopp - 102 Passing, Counter-pressing Possession Games (Vol. 1)" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Jurgen Klopp - 102 Passing, Counter-pressing Possession Games, Speed & Warm-ups',
    subtitle    = 'Direct from Klopp''s Training Sessions (Vol. 1)',
    author      = 'Alex Fitzgerald (ed.)',
    team        = 'Liverpool (Klopp, Pep Lijnders)',
    season      = '2016-2022',
    method_note = 'First volume of practices from Klopp''s Liverpool training (2016-22): pre-match and pre-season warm-ups, speed and agility, unopposed passing and diamond combinations (check away before showing, lay-off for the third man, central link player, tick-tick-boom under pressure), then the counter-press philosophy (overload the ball, press the receiver, block passing lines, stay compact, push play wide) and the rondos and possession games that train it. Patterns are the team behaviours the practices rehearse, in our words; warm-ups, speed work and technique drills are left out.'
WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct');

-- 1. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'to_defend', 'Liverpool Pre-Match Warm-up, Part 5/6: 4v4 (+2) End to End Possession Game', 'Instant counter-press after losing possession',
    'Team keeping the ball moves it from one end player to the other in tight space with 1-2 touches. When the ball is lost, the whole group switches straight to defending instead of dropping off.',
    'Ball lost to the opponent',
    'Win the ball back right away, close to where it was lost, before the opponent can play end to end.',
    NULL, 18, 18, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost the ball', 'Presses the new ball carrier at once'),
    (2, 'Nearest teammates', 'Close the short passing options around the ball'),
    (3, 'Whole team in possession', 'Circulate 1-2 touch, use the end players to switch the play end to end'),
    (4, 'End support players', 'Give a free outlet to whichever team has the ball')
) AS v(so, role, job);

-- 2. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Pre-season Training 2: Pass and Score Quickly vs. Speed of Middle Player Game', 'Quick circulation to beat a shifting defender',
    'Three attackers against one central defender who shifts to guard whichever side the ball is on. The attackers move the ball fast from side to side so they can finish on the side he has just left.',
    'Defender commits to the ball side',
    'Speed of passing beats the defender''s shift and opens a scoring chance on the far side.',
    NULL, 22, 22, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side attacker', 'Pull the defender over, then pass on quickly'),
    (2, 'Central/far-side attackers', 'Be ready to receive and finish on the side just left open'),
    (3, 'Central defender', 'Watch the ball at all times and react fast to shift across')
) AS v(so, role, job);

-- 3. pp.24-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Pre-season Training 4-8: Double Triangle circuits, Pass and Move, Attacking Combinations in Threes', 'Check away, lay-off and run beyond',
    'Receivers move away from the ball and then come back into space to get it, open to play forward. Short lay-offs and one-twos release a teammate running beyond, and a well-timed diagonal or through pass finds the runner to finish. Patterns are rehearsed at speed with 1-2 touches.',
    'Receiver checked off his marker / runner starts beyond',
    'Get a teammate running in behind facing goal through a quick combination of three players.',
    NULL, 24, 28, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First passer', 'Play in, then run forward to take the return pass or lay-off'),
    (2, 'Receiver (check-away player)', 'Check off the marker, open up at an angle, lay off or set first time'),
    (3, 'Third player', 'Time a run beyond, around the defender, and receive the final pass'),
    (4, 'All', 'Rotate positions, 1-2 touch, ''speed, simple passes''')
) AS v(so, role, job);

-- 4. pp.64-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Passing Combinations', 'One-two then move for support angle',
    'After passing, a player gets the ball straight back on the move (wall pass), and the next receiver moves off his line diagonally so the passer has an open angle to play into.',
    'Teammate checks away then shows for the ball',
    'Keep the ball moving forward at tempo with a supporting angle always ready for the next pass.',
    NULL, 64, 76, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'play in, then run onto the return (one-two)'),
    (2, 'Wall player', 'check away first, set the ball back first time into the passer''s path'),
    (3, 'Next receiver', 'move diagonally off the cone to give a good support angle'),
    (4, 'All', 'follow your pass; one touch where possible')
) AS v(so, role, job);

-- 5. pp.66-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Passing Combinations / Diamond Passing Combinations', 'Combine short, then switch',
    'A short combination (one-two, lay-off) on one side frees a player to play a longer pass, along the ground or lofted, across to the far side where a teammate is moving to receive.',
    'Lay-off arrives facing the far side',
    'Draw play to one side and change the point of attack quickly.',
    NULL, 66, 96, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lay-off player', 'set the ball back so the passer faces the far side'),
    (2, 'Switch passer', 'play the long diagonal or lofted ball first or second touch'),
    (3, 'Far-side receiver', 'check away, then move to receive the switch on the half-turn')
) AS v(so, role, job);

-- 6. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Passing Combinations', 'Trigger run changes direction in behind',
    'A group circulates the ball; when one player makes a forward run beyond the others, the ball is set back to a teammate who plays it (ground or lofted) into that run, and the whole group breaks forward towards the other end.',
    'Deepest player starts a forward run',
    'Think as a team: switch from keeping the ball to attacking space in behind together.',
    NULL, 67, 67, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Trigger player', 'make the forward run in behind'),
    (2, 'Nearest teammate', 'set the ball back'),
    (3, 'Passer', 'play the forward pass into the run'),
    (4, 'Rest of group', 'break forward with the play to the new end')
) AS v(so, role, job);

-- 7. pp.68-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Passing Combinations', 'Check away, open up, receive half-turned',
    'Receivers first move away from the ball (or to the other side of a marker), then open their body and take the ball on the half-turn, often on the back foot and outside the cone, so the first touch already faces the next target.',
    'Teammate looks up to pass',
    'Receive facing forward and play the next (often diagonal) pass with the second touch.',
    NULL, 68, 80, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'check away, then open up and take the ball on the half-turn'),
    (2, 'Receiver', 'first touch out of the body towards the next target, second touch pass diagonal'),
    (3, 'Supporting player (corner)', 'keep shifting left/right of the blocker to offer a clear angle')
) AS v(so, role, job);

-- 8. pp.69-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Passing Combinations', 'Quick support makes the easy pass',
    'Coaching principle stressed in the double-triangle and double-square drills: the faster the nearest teammate moves to support, the simpler and quicker the team''s play becomes; timing and speed of the support run matter more than the pass itself.',
    'Teammate is about to receive',
    'The ball carrier always has a simple, early option, so the team keeps tempo.',
    NULL, 69, 84, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Link/central player', 'drop or step around the blocker at the right moment to show for the ball'),
    (2, 'Wide supporters', 'time the move so you arrive as the pass is ready, not before'),
    (3, 'Middle players', 'constant movement and quick changes of direction to stay available')
) AS v(so, role, job);

-- 9. pp.72-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Passing Combinations', 'Receive away from the presser',
    'The passer immediately follows his pass to press the receiver; the receiver takes his first touch forward past the pressing side and moves around the presser to play on.',
    'Ball played in with a defender closing straight after',
    'Escape immediate pressure with a directional first touch and keep the ball moving one-touch.',
    NULL, 72, 72, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'touch the ball forward to the side away from the presser and go round him'),
    (2, 'Passer', 'follow the pass and press the receiver')
) AS v(so, role, job);

-- 10. pp.73-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Passing Combinations', 'Lay-off for the third-man run',
    'A forward receives with his back to play and sets the ball back; a third player who has made a run around the blocker gets the next forward pass from the player who received the lay-off.',
    'Pass into a player checking off his cone with back to goal',
    'Get a runner facing forward beyond the line the ball was played into.',
    NULL, 73, 86, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target player', 'check off, drop to receive and lay off first time'),
    (2, 'Lay-off receiver', 'play the next pass in front of the runner'),
    (3, 'Third man', 'start the run as the target receives, curve around the blocker to receive'),
    (4, 'All', 'one touch, rotate positions')
) AS v(so, role, job);

-- 11. pp.85-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Passing Combinations', 'Breaking lines: angled support, lay-off, forward run',
    'In small groups around mannequin lines near the box, the ball is played into an angled supporter, set back to a player who has moved forward past the first line, then into the next player who sets it back again for a curved run past the second line.',
    'Midfielder steps past the first line after passing',
    'Progress through successive defensive lines by combining pass in, set back, run past.',
    NULL, 85, 86, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side midfielder (A)', 'pass in, move forward past the first line, then curve past the second'),
    (2, 'Angled supporters (B, C)', 'take angled positions, receive and set back'),
    (3, 'Advanced player (D)', 'show between lines, lay the ball off for A''s run')
) AS v(so, role, job);

-- 12. pp.87-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Passing Combinations', 'Rotate into the passed player''s spot',
    'Players choose to receive inside (between the lines, in the middle of a box of mannequins) or outside (wide); after each pass the passer takes the receiver''s position, and the wide player gets a pass out in front for a forward run.',
    'Receiver chooses inside or outside position',
    'Constant rotation keeps both the inside and wide options filled while the ball moves forward.',
    NULL, 87, 88, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central receiver', 'pick inside or outside first, then set back or turn and play'),
    (2, 'Passer', 'take the position of the player you passed to'),
    (3, 'Wide player', 'run onto a pass played wide and in front of the mannequin')
) AS v(so, role, job);

-- 13. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Passing Combinations', 'Keep it, then change direction',
    'Five players keep the ball in one end zone through a constantly rotating middle player; after enough passes the ball goes long to the lone free player in the far zone and all but one sprint across to support him.',
    'Possession settled (15+ passes) and free player open far side',
    'Use possession to draw the opponent, then change the direction of play and arrive fast in support.',
    NULL, 89, 89, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle player', 'keep rotating in, exchanging places after receiving'),
    (2, 'Outside players', 'circulate through the middle player'),
    (3, 'Far free player', 'stay open for the long switch'),
    (4, 'Group', 'sprint across to support after the switch; one stays')
) AS v(so, role, job);

-- 14. pp.90-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'to_attack', 'Passing Combinations', 'Whistle transition: fast break to score',
    'Seven players keep the ball and rotate in midfield; on a signal they either drop the ball and attack a new one played in, or attack with the same ball, breaking quickly to score in mini goals with freely chosen combinations.',
    'Coach''s whistle (stands in for winning the ball)',
    'Switch instantly from possession to a direct, fast attack on goal.',
    NULL, 90, 91, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players', 'attack the ball and play forward quickly'),
    (2, 'Wide players', 'sprint forward to give width and run onto passes'),
    (3, 'All', 'decide the combination freely, finish fast')
) AS v(so, role, job);

-- 15. pp.93-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Diamond Passing Combinations', 'Diamond combination then through ball',
    'In a diamond, a give-and-go and lay-offs move the ball round, ending in a pass played into the path of a player curling around a blocker into space.',
    'Runner starts around the mannequin as the set-back is played',
    'Finish a short combination with a penetrating pass into a moving player.',
    NULL, 93, 96, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Base player (A)', 'start with a give-and-go, then play the next pass'),
    (2, 'Wide player (B)', 'set back, then run around the mannequin to receive'),
    (3, 'Top player (C)', 'lay off or play the final pass into the run'),
    (4, 'Far player (D)', 'time the run around the mannequin onto the final pass')
) AS v(so, role, job);

-- 16. pp.97-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Diamond Passing Combinations', 'Check away, then show for the ball',
    'Every receiver first moves away from the ball (or off a marker) and then comes back at an angle to receive, often round a defender, keeping the ball moving on one or two touches.',
    'Teammate is about to play to you',
    'Create a yard of space and an open body shape before the ball arrives.',
    NULL, 97, 106, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving player', 'step away first, then arrive at an angle into the passing line'),
    (2, 'Passer', 'play into the space the receiver arrives in, on the front foot'),
    (3, 'Next player in the chain', 'rotate into the vacated spot to keep the shape')
) AS v(so, role, job);

-- 17. pp.98-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Diamond Passing Combinations', 'Lay-off for the third-man runner',
    'After a one-two or a set-back, the ball goes into a player who moves round a defender while a third player times a run beyond to receive the final pass.',
    'Ball set back by a player with his back to goal',
    'Get a runner on the ball facing forward beyond a defender.',
    NULL, 98, 104, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wall / link player', 'set the ball back on one touch'),
    (2, 'Supporting midfielder', 'receive the lay-off facing play and pass early'),
    (3, 'Third-man runner', 'time the run round the defender to receive in stride')
) AS v(so, role, job);

-- 18. pp.101-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Diamond Passing Combinations (Central Link Player)', 'Central link player opens up the play',
    'A central midfielder in the middle of the diamond receives from the side, bounces it back or lays it off, then turns and offers again so outside players can open up and carry the ball past the line.',
    'Outside player plays inside to the central player',
    'Use the middle player as a pivot to switch direction and let the outside player run with the ball.',
    NULL, 101, 104, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central link midfielder', 'lay off on one touch, turn and re-offer to left or right'),
    (2, 'Outside player', 'after the return pass, open up and dribble past the line'),
    (3, 'Far-side player', 'move across to support and receive the switch')
) AS v(so, role, job);

-- 19. pp.105-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Diamond + Triangle combinations', 'Tick, tick, boom under pressure',
    'When pressed, the team plays two quick short passes to draw and shift the pressure and then a forward pass into the run of a player going past.',
    'Opponent presses the ball area',
    'Escape a press by short-short-long and play forward immediately.',
    NULL, 105, 106, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player on ball', 'play short and quick, first time'),
    (2, 'Nearby support', 'set back and shift across in front of the defender'),
    (3, 'Forward runner', 'break past the marker for the final forward pass')
) AS v(so, role, job);

-- 20. pp.108-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'to_attack', 'Pressing and Counter-pressing Philosophy', 'High regain becomes the counter',
    'Winning the ball close to the opponent''s goal while their shape is open (players out of position after losing it) makes a quick attack the natural follow-up.',
    'Ball won high up the pitch',
    'Exploit the gaps in a disorganised opponent and score quickly.',
    NULL, 108, 109, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'play forward at once into the space left open'),
    (2, 'Front players', 'attack the space in front immediately'),
    (3, 'Supporting midfielders', 'push up so the regain is not lost again')
) AS v(so, role, job);

-- 21. pp.108-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'to_defend', 'Pressing and Counter-pressing Philosophy', 'Counter-press the moment the ball is lost',
    'Just after losing possession the opponent is disorientated and tired from winning it, so the nearest players attack the ball at once instead of retreating, swarming the ball area as a group.',
    'Loss of possession',
    'Win the ball back high and fast, before the opponent can organise a counter.',
    NULL, 108, 136, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Closest player', 'go 100% at the ball carrier, ideally while he is still controlling it'),
    (2, 'Second presser', 'join to double the carrier'),
    (3, 'Nearby teammates', 'block passing lines to likely receivers, cut off the forward pass while checking over the shoulder'),
    (4, 'Whole unit', 'stay compact round the ball; if no regain, force a mistake or push play wide')
) AS v(so, role, job);

-- 22. pp.110-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'out_of_possession', 'Pressing Rondos and Possession Games', 'Press as a pair, close the angles',
    'Two central players press together: one goes to the ball, the other cuts the angle to the obvious receiver, aiming to win the ball within a few passes; only the player who wins it leaves the middle, unless both are involved.',
    'Ball circulating around the middle pair',
    'Win the ball within about six passes by shutting passing lanes, not just chasing.',
    NULL, 110, 119, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First presser', 'go to the ball carrier and steer him'),
    (2, 'Second presser', 'screen the passing line behind the first presser'),
    (3, 'Pair', 'count passes and raise intensity to win it before the sixth pass')
) AS v(so, role, job);

-- 23. pp.113-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Pressing Rondos and Possession Games', 'Break the press, find the free man',
    'The team in possession beats a press with one- or two-touch passing, constantly forming new triangles and good angles, and using free outside or joker players as support to always have an open option.',
    'Pressure arrives on the ball carrier',
    'Keep the ball and move it to the free player before the press closes.',
    NULL, 113, 131, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'play quickly, know beforehand where the free player is'),
    (2, 'Near support players', 'move to form a new triangle and passing angle'),
    (3, 'Outside / free support players', 'stay available as the safe outlet and bounce it back')
) AS v(so, role, job);

-- 24. pp.116-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'out_of_possession', 'Pressing Rondos and Possession Games', 'Sprint across to re-press after a switch',
    'If the ball escapes the press and is moved to the other end or another area, the pressing players sprint across immediately and press again rather than giving up.',
    'Ball switched away from the pressing pair',
    'Keep constant pressure so the opponent never has calm possession.',
    NULL, 116, 118, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing pair', 'sprint across together to the new ball area'),
    (2, 'Recovering player', 'arrive on the new carrier while the partner cuts the nearest pass')
) AS v(so, role, job);

-- 25. pp.118-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Pressing and Counter-pressing Rondos and Possession Games', 'Play through the press to the far end',
    'Rather than only keeping it, the team aims to move the ball through the pressing players to a free teammate at the opposite end or zone, then go again the other way.',
    'Possession won or kept under a midfield press',
    'Progress the ball through or past the pressing line, not just around it.',
    NULL, 118, 133, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back players', 'circulate quickly to shift the press'),
    (2, 'Middle players', 'find gaps to receive between pressers or let the ball through'),
    (3, 'Far-end target', 'stay open to receive the forward pass')
) AS v(so, role, job);

-- 26. pp.120-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Pressing Rondos and Possession Games', 'Pass and receive between the lines',
    'In a possession game a goal counts only when a pass travels through a gap (pole gate) and is received by a teammate on the other side, optionally with a target player in an end zone.',
    'A passing lane opens through a gap',
    'Reward passes that split defenders and are controlled on the far side.',
    NULL, 120, 121, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'look for the split pass through the gap'),
    (2, 'Receiver', 'move to the far side of the gap to receive'),
    (3, 'End-zone target', 'offer depth as the deepest outlet')
) AS v(so, role, job);

-- 27. pp.124-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'to_defend', 'Pressing and Counter-pressing Rondos and Possession Games', 'Hunt the ball in a triangle',
    'Three players press as a triangle around the ball, hunting it at high intensity; on losing it the team that lost it immediately swaps into the hunters'' job.',
    'Ball lost or opponent gets the ball',
    'Win it back with a compact triangle that cuts passes on both sides.',
    NULL, 124, 124, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front of the triangle', 'press the ball carrier'),
    (2, 'Two back corners', 'cover the passing lines either side of the presser')
) AS v(so, role, job);

-- 28. pp.132-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'to_defend', 'Pressing and Counter-pressing Rondos and Possession Games', 'Outside players compress inward on loss',
    'When players who were spread wide for possession lose the ball, they all move inside together and squeeze the ball area, with the coach stressing triangle shapes in possession so the compress is short.',
    'Ball lost while team is spread out',
    'Compress quickly and win the ball back before the opponent spreads.',
    NULL, 132, 136, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide / outside players', 'step in fast toward the ball'),
    (2, 'Players near the ball', 'press immediately'),
    (3, 'Far players', 'close the inside passing lanes')
) AS v(so, role, job);

-- 29. pp.134-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'to_attack', 'Pressing and Counter-pressing Rondos and Possession Games', 'Spread wide on regain',
    'The moment the pressing team wins the ball, its players move to the outsides and use jokers to make the area big for keeping possession.',
    'Ball won',
    'Stretch the opponent''s counter-press and secure possession.',
    NULL, 134, 136, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'secure the ball and find the nearest outlet'),
    (2, 'Teammates', 'run out to the edges to give width and depth'),
    (3, 'Jokers / central midfielders', 'offer inside support')
) AS v(so, role, job);

-- 30. pp.136-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-102-passing-counter-pressing-possession-games-speed-warm-ups-direct'), 'in_possession', 'Pressing and Counter-pressing Rondos and Possession Games', 'Positional structure for keeping the ball',
    'Possession is kept in a positional layout: centre backs at the base, a forward at the top, wide players on the touchlines and central midfielders in the middle, so the shape is ready to counter-press when the ball is lost.',
    'Settled possession',
    'Hold width and depth so passing lanes exist and losses can be pressed at once.',
    NULL, 136, 136, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'stay as the base and start play'),
    (2, 'Wide players (LW/RW, LB/RB)', 'keep the width on the sides'),
    (3, 'Central midfielders', 'link in the middle'),
    (4, 'Forward', 'hold the top for depth')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('2102-coaching-book-klopp-vol1-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
