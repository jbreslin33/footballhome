-- 1973 📚 Coaching book patterns: "SCANNING" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'SCANNING',
    subtitle    = 'How to Train it and Develop Game Awareness: See More, Think Quicker, Play Better',
    author      = 'Kevin McGreskin',
    team        = 'Soccer eyeQ method',
    method_note = 'Scanning (looking away from the ball to find ball, team-mates, opponents and space) as a trainable habit behind good decisions. The Soccer eyeQ method adds a perception layer to ordinary practices with colour cues players must see and use. Theory: a Decision Model (referencing, framing, localizing) and a three-level Game Awareness Model (observation, realization, anticipation) with six coaching points; then practices from unopposed sequences up to opposed games and rondos (including examples from Man City and Liverpool). Patterns are the on-pitch habits it teaches (scan while the ball travels, last look before the first touch, open body shape, know your next pass, receive away from pressure, third-man support), in our words.'
WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-');

-- 1. pp.10-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'What is Scanning? / Soccer eyeQ: Adding the Method to Any Practice', 'Scan while the ball travels',
    'Off-the-ball players keep refreshing their picture with several short looks before the pass arrives instead of watching the ball, especially during the pass to the previous player and the pass to themselves. Elite midfielders take roughly 6-8 looks in the 10 seconds before receiving.',
    'Ball is in flight to a team-mate or to you',
    'Know where team-mates, opponents and space are before the first touch so the next action is already chosen.',
    NULL, 10, 41, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving player', 'look away from the ball while the pass travels and identify the target before controlling'),
    (2, 'Next-but-one receiver', 'start checking as the ball goes to the trigger player so the picture is ready'),
    (3, 'Passer', 'has the picture before the ball arrives and plays the most effective option, forward first')
) AS v(so, role, job);

-- 2. pp.18-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'to_defend', 'Soccer eyeQ: Adding the Method to Any Practice (Pep Guardiola''s Juego de Posicion 4v4+3)', 'Instant counter-press after losing it',
    'In a tight rondo-style possession game with three jokers, the defending four close passing angles together to win the ball; the moment the side in possession loses it they swap roles and all collapse inside to win it straight back.',
    'Ball lost in a tight possession area',
    'Regain the ball immediately before the new possessing team can spread out and use its jokers.',
    NULL, 18, 19, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players who just lost the ball', 'step inside at once and press the ball together'),
    (2, 'Pressing unit', 'shut off passing angles to the jokers, not just chase the ball'),
    (3, 'Team that won it', 'spread to the outside at once to make the area big and use the jokers'),
    (4, 'Jokers', 'always support whichever side has the ball')
) AS v(so, role, job);

-- 3. pp.19-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Soccer eyeQ: Adding the Method to Any Practice (Juego de Posicion 4v4+3) / Dundee Utd practice example', 'Open body shape receiving from wide',
    'When the ball comes from a wide or end-line player, the receiver stands half-turned (panoramic positioning) so he can see forward and the far side as well as the ball. In the Dundee United game a team scores only by receiving from an outside ''slider'' after first making a pass inside.',
    'Pass coming from an outside or end player',
    'Receive already facing play, able to go forward or switch to the opposite side on the first touch.',
    NULL, 19, 27, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver inside the area', 'open hips sideways and check the opposite side before the ball arrives'),
    (2, 'Wide/end support player', 'offer the angle and give the ball to the player who can face play'),
    (3, 'Opposite wide player', 'stay visible on the far side as the switch option')
) AS v(so, role, job);

-- 4. pp.24-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Interview: Nigel Best', 'Playing out from the back against a high press',
    'When the goalkeeper plays short to a centre back or a holding midfielder dropping in, the receiver must have scanned beforehand; one who watches the ball onto his foot gets closed down or has his next pass read and intercepted in the most dangerous area (Fernandinho example).',
    'Goalkeeper or centre back passes short while the opponent presses high',
    'Keep the ball under a high press by knowing the free player before the ball arrives.',
    NULL, 24, 30, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'scan to see where the free player is before distributing'),
    (2, 'Centre back', 'look around while the keeper''s pass travels rather than watching it in'),
    (3, 'Holding midfielder dropping in', 'check for the presser behind before receiving facing own goal')
) AS v(so, role, job);

-- 5. pp.24-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'out_of_possession', 'Scanning to Defend Effectively: Man City''s Laporte Example / Interview: Jackie McNamara', 'Centre back scans to cover and support',
    'With his full back out of position, the centre back ends up wide and keeps turning his head left and right so he can mark the nearest attacker and still support his partner centre back; defenders who do not scan switch off or get caught on the wrong side.',
    'Full back out of position, centre back pulled into a wide channel',
    'Stay correctly placed between threats, win a tackle and launch a quick counter.',
    NULL, 24, 40, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Laporte)', 'scan repeatedly, mark the wide attacker and keep the distance to the partner CB, then tackle'),
    (2, 'Partner centre back (Stones)', 'hold the central position supported by the scanning CB'),
    (3, 'Out-of-position full back (Zinchenko)', 'recover while the CB covers'),
    (4, 'Midfielders', 'be ready to receive for the counter after the regain')
) AS v(so, role, job);

-- 6. pp.26-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Interview: Jackie McNamara / Interview: Nigel Best', 'Supporting runs into receiver''s view, third man',
    'While the ball is on its way, supporting players move to spots where the receiver can see them, and a third player is already moving into position for the next pass; play is quick but not a counter attack, built on scanning, movement and third-man running.',
    'Team-mate about to receive the ball',
    'Quick one- and two-touch circulation that the opponent is too slow to react to.',
    NULL, 26, 32, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'know where the support and the third man are before receiving'),
    (2, 'Near supporting player', 'move into the receiver''s field of view at a good angle'),
    (3, 'Third man', 'run early into the space for the pass after next')
) AS v(so, role, job);

-- 7. pp.26-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Interview: Jackie McNamara / Interview: Geir Jordet (Paul Paton)', 'Midfielder''s first-time switch to far full back',
    'With both full backs pushed high, the central midfielder scans before receiving, takes a first touch out of feet and hits a long diagonal straight to the advanced full back on the far side (Paul Paton at Partick Thistle).',
    'Central midfielder about to receive with both full backs high and wide',
    'Move the ball quickly to the weak side before the opponent can shift across.',
    NULL, 26, 37, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Paul Paton)', 'check both sides early, touch out of feet, play the diagonal fast'),
    (2, 'Weak-side full back (Stephen O''Donnell / Aaron Taylor-Sinclair)', 'stay high and wide on the far side to receive the switch'),
    (3, 'Ball-side full back', 'push on to pin the near side')
) AS v(so, role, job);

-- 8. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Interview: Geir Jordet', 'Forward scans to pass or shoot',
    'Top forwards (Mbappe, Haaland) scan more than typical strikers; before shooting they check whether a team-mate is better placed and pass if so, otherwise they shoot quickly.',
    'Forward receiving in or near the box',
    'Choose the higher-percentage finish, pass or shot, from a ready picture.',
    NULL, 37, 37, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'look for a better-placed team-mate before receiving, shoot if none'),
    (2, 'Supporting attackers', 'get into the striker''s view in a better scoring spot')
) AS v(so, role, job);

-- 9. pp.39-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Xavi''s ''Off the Scale'' Scanning: Match Example', 'Repeated scans to find the pocket',
    'A central midfielder moving into space keeps swivelling (Xavi: 5 looks in 15 seconds) to pick out the gap between opponents, receives there, and already knows the best pass to create a chance.',
    'Team circulating the ball in front of a compact block',
    'Receive between the lines with the decisive pass already lined up.',
    NULL, 39, 39, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Xavi)', 'scan constantly while moving into the free space, then take the ball there'),
    (2, 'Players on the ball', 'find the midfielder once he is free in the pocket'),
    (3, 'Forward runner', 'attack the space the midfielder has spotted')
) AS v(so, role, job);

-- 10. pp.52-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'The Basic Decision Making Model 1.0 and its Limitations', 'Stay switched on after your action',
    'After passing, players must not stand and watch the ball or the next receiver; they scan and move straight away to support the attack or recover their defensive position.',
    'Player has just passed or finished an action',
    'Keep tempo high and avoid gaps in support, in attack and defence.',
    NULL, 52, 54, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who just passed', 'scan at once and move to a new support or cover position'),
    (2, 'Off-ball team-mates', 'keep refreshing the picture rather than following the ball'),
    (3, 'Defensive players', 'use the scan to stay in position, not get caught out')
) AS v(so, role, job);

-- 11. pp.55-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Referencing: Signals, Situations, and Scenarios', 'Scan for pre-planned scenario triggers',
    'Players carry a bank of team patterns of play and actively search the picture for the cues that switch a given pattern on, rather than waiting to read a fresh picture each time; under heavy pressure a familiar picture fires a rehearsed action almost automatically (priming).',
    'A recognised cue from the game plan (teammate posture, opponent movement, space opening)',
    'Whole team executes the coordinated pattern together and faster than the opponent can react.',
    NULL, 55, 62, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All outfield players', 'Know the team patterns of play and which cue starts each'),
    (2, 'Off-ball teammates', 'Read the ball carrier''s body cues for timing of runs and passes'),
    (3, 'Ball carrier', 'Read opponents'' body cues to see where they will close and play away from it')
) AS v(so, role, job);

-- 12. pp.59-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Localizing: Prospecting / 5 Key Moments to Scan (moment 1)', 'Last look as ball travels to you',
    'When a pass is coming, the receiver first judges the ball''s line and pace in the opening fraction of a second, then takes a final look around as late as possible (as early as pressure demands); good players fit two or three quick looks into a long pass. He never looks away at the instant the pass is struck.',
    'Teammate plays the pass to him',
    'Receiver arrives at the ball with the freshest picture and the feet already lined up for the next action.',
    NULL, 59, 76, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving player', 'Watch the strike, read ball flight, then scan late and adjust feet'),
    (2, 'Receiving player under tight pressure', 'Scan earlier, rely on the pre-scan picture')
) AS v(so, role, job);

-- 13. pp.60-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Key Aspects of Scanning (Level 1) - Panoramic Positioning', 'Panoramic positioning and open body shape',
    'Off the ball players move a yard or two or open their stance so they see as much of the pitch as possible; when receiving they stand half-turned to the passer rather than square on, so ball, teammates and space ahead are all in view.',
    'Constant, especially when a pass may come to you',
    'Wider field of view, more passing affordances and an extra teammate brought into range.',
    NULL, 60, 81, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Off-ball player', 'Adjust location and stance to maximise field of view'),
    (2, 'Receiving player', 'Open body shape relative to where the ball comes from')
) AS v(so, role, job);

-- 14. pp.67-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'A Simplified Model for Game Awareness - Levels 1 and 2 (Man City 2018-19)', 'Free 8 scans then turns and drives',
    'An advanced central midfielder (De Bruyne) scans the area ahead before receiving a pass from deeper; he sees the opposing defenders are far away and 3-4 teammates are ready to support. Without the scan he would just play back.',
    'Pass into the midfielder with the nearest defender distant',
    'He turns on the first touch and dribbles at goal, using the time and space instead of recycling.',
    NULL, 67, 69, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advanced central midfielder (De Bruyne 17)', 'Scan before receiving, turn and carry forward when space is confirmed'),
    (2, 'Supporting forwards/midfielders', 'Offer 3-4 options ahead for the attack'),
    (3, 'Passing centre midfielder', 'Feed the free 8 between the lines')
) AS v(so, role, job);

-- 15. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 3: Predicting How Play Will Develop (Man City 2018-19)', 'Narrow back four, release the far winger',
    'Having scanned before receiving, the central midfielder sees the opponent''s back four squeezed narrow inside the box width, the full back tucking in and a centre back stepping out to close him, while the right winger is free out wide and about to run in behind.',
    'Back line narrow plus a centre back stepping out to press the receiver',
    'Early pass in behind the line to the winger''s run, creating a goal chance.',
    NULL, 70, 70, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (De Bruyne 17)', 'Read the narrow line and play the early ball in behind'),
    (2, 'Wide forward (Sterling 7)', 'Stay wide and free, then run in behind the full back'),
    (3, 'Other forwards', 'Pin the centre backs inside')
) AS v(so, role, job);

-- 16. pp.75-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', '5 Key Moments a Player Should Engage in Scanning (moments 2-5)', 'Scan after passing and in dead moments',
    'Right after releasing a pass the player looks around as soon as possible instead of ball-watching, then re-engages quickly (follow-on). Off the ball, players also scan while a pass travels between two other players (two or three looks on a long pass, one on a short one), between the carrier''s touches when he is running with the ball unopposed, and during an opponent''s or teammate''s controlling touch.',
    'Ball leaves own foot; ball in flight between others; carrier''s big touches; a controlling touch',
    'Every player keeps an up-to-date map and moves into the next useful position without losing fractions of a second.',
    NULL, 75, 77, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Scan immediately after the pass, then reposition'),
    (2, 'Off-ball players', 'Look away from the ball while it travels between two others'),
    (3, 'Players near a carrier running with the ball', 'Scan between his long touches, not during close dribbling'),
    (4, 'Any player', 'Use an opponent''s controlling touch to take a quick look and read his intent')
) AS v(so, role, job);

-- 17. pp.85-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Adaptive Positioning and Identifying Key Reference Points (Level 2)', 'Adaptive positioning on key reference points',
    'Each player picks which of ball, teammates and opponents matter most right now, places himself to see them and to interact with them, and keeps re-adjusting body shape and location as they move; on a change of ball position or possession he reprioritises his reference points at once.',
    'Any movement of ball, teammates or opponents; possession changes',
    'Players are rarely caught a yard out of position because they stay in the most useful spot at every moment, attacking or defending.',
    NULL, 85, 90, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Every outfield player', 'Prioritise key reference points and keep them in view'),
    (2, 'Players near the ball', 'Adjust position to be able to receive or engage'),
    (3, 'All on a possession change', 'Re-rank reference points and reposition instantly')
) AS v(so, role, job);

-- 18. pp.87-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Incorrect and Correct Reading the Game Situation (Attack)', 'Holding midfielder opens up to play forward',
    'A defensive midfielder receiving from a centre back with a closed body shape can only see and play back to the centre back. Positioned and opened up correctly he sees the space to turn and the attacking midfielders beyond the opponent''s midfield line.',
    'Pass from centre back into the 6',
    'The 6 turns and plays forward through the opponent''s midfield line instead of recycling backwards.',
    NULL, 87, 87, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Open body shape, scan, turn and pass through the midfield line'),
    (2, 'Attacking midfielders', 'Sit beyond the opposing midfield line as targets'),
    (3, 'Centre backs', 'Feed the 6 when he is open')
) AS v(so, role, job);

-- 19. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'out_of_possession', 'Incorrect and Correct Reading the Game Situation (Defence)', 'Full back guards the blind-side run',
    'With the ball on the far side, a right back who sits too high and faces the ball cannot see the opposing left winger behind him and is beaten by a blind-side run. Dropping deeper with an open stance lets him see ball, teammates and the winger at once.',
    'Ball on the opposite side, opposing weak-side winger high and wide',
    'Full back tracks the blind-side runner and denies the far-post or in-behind opportunity.',
    NULL, 88, 88, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side full back', 'Drop deeper, open body to see both ball and winger'),
    (2, 'Centre backs', 'Hold line, communicate on the far-side runner'),
    (3, 'Defensive midfielder', 'Screen the centre while the full back holds width')
) AS v(so, role, job);

-- 20. pp.93-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'out_of_possession', 'Anticipation (Level 3) - Defensive Game Actions', 'Pre-shift for an expected switch',
    'When defenders read that the opponent is about to switch play, they relax their current distances and drift a step toward the side the ball will go, so they can slide across and engage as soon as the switch arrives; the same prospective positioning readies interceptions, presses and tackles.',
    'Ball carrier''s posture and options signal a switch of play',
    'Block shifts in time and defends the switch effectively, or intercepts it.',
    NULL, 93, 93, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side defenders', 'Loosen marking slightly once the switch is read'),
    (2, 'Weak-side defenders', 'Edge toward the expected receiving area, ready to press'),
    (3, 'Midfield line', 'Shift across early with the anticipated ball')
) AS v(so, role, job);

-- 21. pp.94-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Anticipation (Level 3) - Attacking Game Actions', 'Support with a plan, third-man runs',
    'Supporting players do not just get open for the ball; they keep scanning so they already know what to do with it, and better anticipators read where the supporter of the ball carrier will play next and make the third-man run into that space early.',
    'Teammate is about to support the ball carrier',
    'Possession is kept and penetrating third-man runs become hard to defend.',
    NULL, 94, 94, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Direct supporting player', 'Get open while keeping the bigger picture, know the next action before receiving'),
    (2, 'Third player', 'Anticipate the next pass and run into space beyond the support'),
    (3, 'Ball carrier', 'Find the supporter or the third-man runner')
) AS v(so, role, job);

-- 22. pp.96-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Incorrect and Correct Predicting How Play Will Develop', 'Don''t turn into the closing full back',
    'An attacking midfielder receiving a pass from the centre back in a wide pocket who has not scanned tries to turn and is tackled by the opposing right back stepping in. After a scan and a final look as the ball travels, he sees the full back coming and a teammate free.',
    'Opposing full back steps in to close as the pass arrives',
    'Receiver does not turn; he plays an early pass to the free teammate and keeps the ball.',
    NULL, 96, 96, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder', 'Scan plus final look, recognise the presser, play early instead of turning'),
    (2, 'Nearby teammate (wide/forward)', 'Be free in space for the early ball'),
    (3, 'Centre back', 'Play the pass into the pocket')
) AS v(so, role, job);

-- 23. pp.109-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 1 Observation - Pass to Opposite Colour / Coaching points A-B', 'Scan before receiving, open panoramic stance',
    'A player about to receive who has only watched the ball stands square or faces the line, sees a narrow slice of the pitch and can only play back. Looking around beforehand lets him set his body so most of the field is in front of him.',
    'Teammate on the ball who may pass to you',
    'Receiver already knows his options and has an open body shape that faces both passer and next target, telling the passer which foot he wants it on.',
    NULL, 109, 119, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving player', 'Look away from the ball repeatedly before the pass; position half-open to passer and next target'),
    (2, 'Receiving player', 'Maximise viewpoint: keep as much of the field as possible in front, never back to the play'),
    (3, 'Passer', 'Read the receiver''s stance as a signal of where he wants the ball')
) AS v(so, role, job);

-- 24. pp.117-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 1 & 2 - Coaching point C: Confirm (check again)', 'Final look after pass, before first touch',
    'The picture changes while the ball travels; a player who only looked early, or only once the ball is on its way, acts on stale or missing information. The author wants an early pre-scan plus one last check while the ball is rolling to him.',
    'Pass has left the teammate''s foot',
    'Receiver takes his first touch with the most up-to-date picture, so he can play forward rather than just keep the ball.',
    NULL, 117, 136, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving player', 'Pre-scan early (praise it), then make the confirming look as late as possible while the ball travels'),
    (2, 'Receiving player', 'With correct body shape, make the last look with minimal head movement to keep eyes free for the ball'),
    (3, 'Off-ball players', 'Stay switched on between involvements; do not wait until you are about to receive')
) AS v(so, role, job);

-- 25. pp.119-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 1 & 2 - Coaching point F: Follow-on', 'Follow-on: rescan straight after passing',
    'Many players ball-watch the moment they release a pass and only scan again when the next ball is coming. The author treats the instant after the pass as the start of the next receiving action.',
    'Player has just released a pass',
    'The sooner he rescans, the sooner his body position is sorted and he is ready to support or receive again.',
    NULL, 119, 124, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who just passed', 'Immediately take eyes off the ball and re-locate key teammates'),
    (2, 'Player who just passed', 'Move to a supporting position for the player he will next receive from')
) AS v(so, role, job);

-- 26. pp.119-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Coaching point E: Execution', 'Pass to the open side, back foot',
    'Passes struck vaguely toward a teammate waste the time his scan bought. The passer should play into the space just in front of the receiver''s open stance, on his far (back) foot.',
    'Teammate has opened his body to receive',
    'Receiver can take the ball across his body and play on in the direction he is facing.',
    NULL, 119, 154, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Play into the space in front of the receiver''s open body, toward his back foot'),
    (2, 'Passer', 'Pace and line the pass so it does not force the receiver to turn back'),
    (3, 'Receiver', 'Hold an open shape so the target side is obvious')
) AS v(so, role, job);

-- 27. pp.120-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 1 Observation - Progressions 2-3: Colour-coded flashers', 'Scan across several reference points',
    'In matches the receiver must track more than two references. With two or three possible targets on the outside the player has to build a scanning pattern covering all of them, weighting looks toward the one he is most likely to need.',
    'Several possible next targets around the ball',
    'Player holds a running picture of every relevant teammate and can redirect play to whichever is right.',
    NULL, 120, 124, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving player', 'Cycle looks between all key targets, not just one'),
    (2, 'Receiving player', 'When a particular ball is likely to come, open the body toward that target and alternate quick looks between ball and target'),
    (3, 'Player expecting a pass that does not come', 'Re-orient to all references again rather than losing track')
) AS v(so, role, job);

-- 28. pp.125-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 2 Realization - Vision and Awareness Sequence Passing', 'Know your next pass before receiving',
    'Players who control first and then look for the next teammate are too slow; frantic head-turning while the ball arrives shows no pre-scan was done. The receiver should already know where the next pass goes. Also used in the Ajax-square drill variants with direction changes.',
    'You are next in line to receive',
    'Ball moves on in the fewest touches and shortest time because the decision is made before the ball arrives.',
    NULL, 125, 136, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving player', 'Locate the intended next receiver before the ball arrives, not after control'),
    (2, 'Receiving player', 'Be open to the player passing to you and to the one you will pass to'),
    (3, 'Next receiver in the chain', 'Switch on at least one pass early, positioning before the ball reaches the teammate before you')
) AS v(so, role, job);

-- 29. pp.137-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 2 Realization - Progression 2: Sequence Passing with Positional Play', 'Never share passer''s lane (column/row)',
    'Receivers often drift into the same vertical or horizontal line as the passer, giving poor angles. The author wants constant small (even one-yard) adjustments based on where the passer is, with three fixes when lined up: receiver moves out, ball carrier shifts lane, or the pass is played into space for the receiver to run onto.',
    'Receiver finds himself in the same column or row as the ball carrier',
    'Support angle is always offset so the pass can be received open and played on quickly.',
    NULL, 137, 139, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving player', 'Keep adjusting position relative to the passer; step into a different lane'),
    (2, 'Ball carrier', 'Dribble into a different lane if quicker'),
    (3, 'Ball carrier', 'Or pass into space in another lane for the receiver to run onto')
) AS v(so, role, job);

-- 30. pp.140-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 2 Realization - Third Man Support (tennis balls)', 'Third-man support, thinking two passes ahead',
    'Once a player passes or sees the next pass coming, he moves early off the ball to support the player who will receive it, rather than waiting for his own turn. Tracking four people (who passes to me, who I pass to, plus the next link) is the aim.',
    'Ball is travelling to the teammate ahead of you in the move',
    'A free supporting option is already in place when the next receiver gets the ball, as in a third-man run.',
    NULL, 140, 146, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Third man (off-ball supporter)', 'Move early into a free lane to support the next receiver before he receives'),
    (2, 'Receiving player', 'Spot the supporter and release to him accurately before or on the first touch'),
    (3, 'Player who just passed', 'Do not switch off; immediately move to support a teammate who needs an option')
) AS v(so, role, job);

-- 31. pp.145-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 2 Realization - Progressions 5-6 / Practice 2 Progressions 1-2', 'Receive in space away from pressure',
    'Supporting players must also keep their distance from opponents (floaters or taggers) while staying open to passer and next target; when one player moves the others shift in a chain of complementary movements. Passers choose only a teammate who has enough space.',
    'Opponents moving near the receiving area',
    'Ball is received by a free player out of pressure; possession is kept and the team can build.',
    NULL, 145, 154, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Supporting player', 'Track where opponents are and take a supporting spot away from them, not toward the ball'),
    (2, 'Ball carrier', 'Identify before receiving which teammates are free; pass only to one in enough space'),
    (3, 'Other teammates', 'Re-adjust when a teammate relocates so lanes stay filled')
) AS v(so, role, job);

-- 32. pp.147-149
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 2 Realization - Progression 6: Maintain Space + Outside Visual Cues', 'Break autopilot when teammate demands ball',
    'Players running a familiar routine stop noticing an unexpected free teammate calling for it (inattentional blindness). If a teammate in a better spot demands the ball, the carrier must suppress the habitual pass and give it to him; the next player then re-positions to receive the return.',
    'Free teammate calls for the ball',
    'Team uses the best available option rather than the pre-planned one.',
    NULL, 147, 149, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Inhibit the automatic pass and play to the teammate demanding it'),
    (2, 'Teammate demanding', 'Call and show clearly, then move it on quickly'),
    (3, 'Next receiver', 'Re-scan and change lane to be free for the ball coming back')
) AS v(so, role, job);

-- 33. pp.151-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Practice Example 2 Progression 1 - Key point', 'Under sudden pressure, secure the first touch',
    'Even after scanning well, a receiver can be closed down fast while the ball travels. Then keeping possession with a clean first touch matters more than completing the scan.',
    'Opponent closing the receiver as the ball arrives',
    'Ball is retained and recycled so the attack can be rebuilt elsewhere.',
    NULL, 151, 152, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving player', 'Prioritise a secure first touch over the final look'),
    (2, 'Receiving player', 'Recycle possession rather than force a forward pass')
) AS v(so, role, job);

-- 34. pp.160-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 3 Anticipation - Opposed 6v3 (+4) Vision and Awareness', 'Wide supporters scan, set tempo',
    'In an overload possession game the outside support players tend to switch off and then return the ball to the first teammate they see. They should scan constantly and act as playmakers, speeding up or slowing the game; inside players should receive from them open to the field and look upfield for the option that hurts the opponent most. Practice continues past p162.',
    'Ball near or coming to an outside support player',
    'Support players find the inside teammate with most time and space, and the team keeps the ball under pressure or exploits space opened elsewhere.',
    NULL, 160, 162, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside support players (sliders)', 'Keep scanning when the ball is far away; know where teammates are before receiving'),
    (2, 'Outside support players (sliders)', 'Control tempo: move it quickly or slow down to draw pressure and open space'),
    (3, 'Inside players', 'Receive from sliders open, not square-on; look upfield first'),
    (4, 'Ball carrier', 'Choose the teammate with most time and space')
) AS v(so, role, job);

-- 35. pp.163-183
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 3 Anticipation - Anticipation Practices Summary', 'Score or keep it: prioritise under pressure',
    'With limited time from opposition pressure or a hard pass, the receiver must judge whether there is time for the forward/scoring action or whether to simply retain possession; possession is the top priority.',
    'Pressure arrives quickly or the pass is poor',
    'Avoid forced forward actions that lose the ball; take the chance only when the picture says there is time.',
    NULL, 163, 183, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver under pressure', 'Drop the ambitious option and recycle when time is short'),
    (2, 'Supporting players', 'Be available for the safe recycle pass')
) AS v(so, role, job);

-- 36. pp.163-205
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 3 Anticipation - Opposed 6v3 (+4) Progression 1; Possession Game Ex 3 6v4+6 Outside Support', 'Receive from wide, check the opposite outlet',
    'When an inside player gets the ball back from a wide or outside support player, he must already have looked across to the far-side outlet and at nearby opponents, so his first touch can go away from pressure or he can play first time into space.',
    'Pass played in from a wide/outside support player',
    'Keep the ball under pressure and find the free player on the far side instead of turning blind into opponents.',
    NULL, 163, 205, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside receiver', 'Open body towards far side; snapshot opponents'' positions; direct first touch or play first time'),
    (2, 'Wide/outside support player', 'Hold width, play the ball back in, keep concentration to be the far-side outlet'),
    (3, 'Nearest teammates', 'Offer a close option for a quick lay-off')
) AS v(so, role, job);

-- 37. pp.163-213
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Soccer eyeQ 6-step cycle (all practices)', 'Last look before the first touch (Confirm)',
    'Every receiver runs a fixed cycle: scan while play builds, open body to passer and far side, take one final look away from the ball while it travels, then decide, execute and re-scan straight after passing.',
    'Teammate is about to pass to me / ball in flight',
    'Receiver already knows pressure, support and the best forward option before the ball arrives, so first touch and next action are quicker.',
    NULL, 163, 213, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'Scan early, open body, final look as the ball travels, then choose one-touch or controlling touch'),
    (2, 'Passer', 'After the pass, re-engage scanning and reposition (follow-on)'),
    (3, 'Off-ball teammates', 'Keep updating their map of ball, teammates and opponents; never switch off')
) AS v(so, role, job);

-- 38. pp.165-182
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 3 Anticipation - Progression 2 Increased Scanning + Tennis Ball Throwing; 4 Cone Gates Prog 2; Floating Players Prog 2', 'Off-ball players support the danger man',
    'Off-ball players must carry a dual job: position to support the teammate who can hurt the opponent (the scoring-ready player) while still offering a safe option for recycling the ball.',
    'A teammate is in a position to receive in a dangerous area',
    'The danger man always has a free supporting teammate nearby to combine with, and the team can still retain possession if the chance closes.',
    NULL, 165, 182, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free off-ball players', 'Adjust position relative to the danger man for a potential combination; remain an option for the ball'),
    (2, 'Wide passers (sliders)', 'Constantly judge which pass hurts the defence most and pick that receiver'),
    (3, 'Receiver', 'Know the flasher, the free teammates and the pressing opponents before touching the ball')
) AS v(so, role, job);

-- 39. pp.168-170
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 3 Anticipation - Progression 3 Scan, Position, Third Man Support, and Player Rotation', 'Wide player drives in, inside player rotates out',
    'A wide player who receives can drive with the ball into the inside area when space opens; the nearest inside player rotates out to fill the vacated wide slot, and inside players read the drive to position for the next pass.',
    'Space opens in front of the wide player as he receives',
    'Create a direct attacking opportunity from the drive while the shape is kept by the swap of positions.',
    NULL, 168, 170, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player (slider)', 'Spot the space and the moment, drive in, then pass to another wide teammate or inside player'),
    (2, 'Nearest inside player', 'Rotate out to fill the wide gap'),
    (3, 'Other inside players', 'Anticipate the drive and move to support it (third-man support)')
) AS v(so, role, job);

-- 40. pp.171-178
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 3 Anticipation - Practice Example 2 Awareness Game (6v3) with 4 Cone Gates; Practice Example 3 Floating Players', 'Picture away from the ball: switch to free space',
    'Players build a picture of what is away from the ball, not just around it, so that on receiving they can move the ball quickly away from pressure, switch into free areas and spot imbalances to find teammates in advanced dangerous spaces.',
    'Opponents crowd one side / an imbalance appears',
    'Escape pressure and launch quick attacks into the space the defence has left.',
    NULL, 171, 178, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'Scan the full area, come open (not square-on), switch or play forward early'),
    (2, 'Far-side/advanced teammates', 'Occupy free space and be ready for the switch')
) AS v(so, role, job);

-- 41. pp.173-176
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 3 Anticipation - Progression 1 Visual Cues and Colour-Coded Cone Gates', 'Pre-scan the target before moving to support',
    'While moving towards an area to support play, the player takes quick preparatory glances to locate the specific teammate in a specific zone he plans to play to next, so his body is set before the ball comes.',
    'Play building towards the zone where I will receive',
    'Know the next pass before receiving; avoid looking only when the pass is already on its way, which is too late.',
    NULL, 173, 176, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Supporting player', 'Pre-scan the target teammate and his movement while moving into the support position'),
    (2, 'Target teammate', 'Keep moving to stay visible and free for the next pass')
) AS v(so, role, job);

-- 42. pp.173-204
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'to_attack', 'Level 3 Anticipation and Section 3 (cone gates, floaters, Liverpool rondo, pocket box)', 'On regain, first pass to the outside target',
    'In many of the opposed games the defending side, on winning the ball, scores by quickly finding an outside player or target (flasher, target player) or dribbling out; variations ask them to keep possession through floaters and flashers until the ball is won back.',
    'Ball won by the defending group',
    'Exploit the moment of transition by playing out immediately to a free outside teammate.',
    NULL, 173, 204, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins the ball', 'Look for the outside target first, pass out or dribble out of the area'),
    (2, 'Outside players/targets', 'Stay available as the escape pass'),
    (3, 'Teammates nearby', 'Support to keep possession if the out-ball is not on')
) AS v(so, role, job);

-- 43. pp.177-182
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 3 Anticipation - Practice Example 3 6(+2)v3 Pass to Floating Players Game; Progression 1', 'Bounce off the central floaters',
    'The team moves the ball quickly around defenders and plays quick passes into the central floaters/playmakers in brief windows; floaters scan constantly off the ball and set it back first time or turn and switch to another area.',
    'A brief passing lane to a floater opens',
    'Use central free men to bypass pressure and change the point of attack.',
    NULL, 177, 182, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central floaters (playmakers)', 'Find space, scan off the ball, play one-touch set-backs or turn and switch'),
    (2, 'Outside players', 'Circulate quickly and hit the floater when the window appears'),
    (3, 'Off-ball players', 'Use moments when the ball travels between two teammates to scan')
) AS v(so, role, job);

-- 44. pp.180-180
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Level 3 Anticipation - Progression 1 Visual Cues to Promote Scanning and Positioning (note)', 'Drag the marker, partner steps in',
    'When an inside free man is tightly man-marked, he drags his marker out of the area, and his paired outside player moves inside into the vacated space unmarked; the team must spot and exploit the new free man.',
    'Inside floater is man-marked tightly',
    'Beat man-marking through interchange and find the newly free player.',
    NULL, 180, 180, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marked inside player', 'Drag the marker away and step out of the area'),
    (2, 'Paired outside player', 'Move inside into the freed space'),
    (3, 'Ball side team', 'Recognise the change quickly and play to the free man')
) AS v(so, role, job);

-- 45. pp.187-188
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Section 3 - Liverpool Rondo with Magic Player (Jurgen Klopp, Melwood, 20 July 2021)', 'Rondo free man plus far-side check',
    'In a 5v2 rondo with four limited-touch outside players and one free ''magic player'' who moves inside and out with unlimited touches, whoever receives from the magic player must look beyond the grid before receiving instead of relying on peripheral vision.',
    'Pass from the free man',
    'Keep the ball (15-pass target) while lifting heads to see the bigger picture beyond the rondo.',
    NULL, 187, 188, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Magic player (free man)', 'Move inside and outside the square to give the extra option'),
    (2, 'Outside players (2 touches)', 'Receive with the head up and scan away from the ball'),
    (3, 'Two defenders', 'Close angles to win the ball; on winning, pass out')
) AS v(so, role, job);

-- 46. pp.187-204
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'out_of_possession', 'Section 3 - Liverpool Rondo with Magic Player; Pocket Box; 6v4+6 Outside Support', 'Pressers close angles together',
    'The outnumbered defenders work as a unit to close passing angles and press the ball carrier to win it, while the possession team try to reach a target number of passes or an outside outlet.',
    'Ball in the possession team''s circulation',
    'Win the ball by shutting angles, then transition out.',
    NULL, 187, 204, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First presser', 'Press the ball carrier and cut the main angle'),
    (2, 'Second presser', 'Close the next passing lane, intercept')
) AS v(so, role, job);

-- 47. pp.189-195
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Section 3 - Passing Drill Examples 1-3 (Y drill, short-long circuit, dynamic double square)', 'Lay-off and third-man run',
    'Classic combination: pass into a player who lays it off first time for a teammate running onto it, followed by a diagonal pass; inside players set the ball and a third man times his run into the space to play the ball out. Receivers check away before showing and take a last look before receiving.',
    'Pass played into the inside player',
    'Quick one-touch combination that moves the ball past the line with the run timed to the lay-off.',
    NULL, 189, 195, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside/set player', 'Lay off first time with the right weight for the runner'),
    (2, 'Third man', 'Time the run onto the lay-off, then play the ball out'),
    (3, 'Next receiver', 'Check away to make space, scan and spot before the first touch')
) AS v(so, role, job);

-- 48. pp.196-198
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Section 3 - Possession Game Example 1 Pocket Box Possession Game', 'Hit the target when he shows in the pocket',
    'A target player steps into a pocket zone for a short window (5 seconds); the team must already be aware of the targets and play into him quickly. In progression the target rotates into the possession team after receiving and players adapt their positions.',
    'Forward target appears in the pocket',
    'Play forward early to the target before the window closes, then re-adjust shape as players rotate.',
    NULL, 196, 198, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target player', 'Time the step into the pocket; receive and rotate into the area'),
    (2, 'Possession players', 'Keep aware of both targets, open body up the pitch, release quickly'),
    (3, 'Pressing defenders', 'Close angles; on regain pass to either target')
) AS v(so, role, job);

-- 49. pp.199-202
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Section 3 - Possession Game Example 2 End to End 3 Zone Possession Game', 'Middle player decides: transfer or recycle',
    'Players in the end zone pass into central jokers who aim to transfer the ball to the far end zone; the joker reads the far zone while the ball circulates, transferring when the right option is free and passing back to the first zone when it is not.',
    'Ball reaches the middle player between the zones',
    'Move the ball end to end through midfield only when the far picture allows it, otherwise keep it.',
    NULL, 199, 202, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central jokers', 'Take early looks at the far zone, open body, transfer or play back'),
    (2, 'End-zone players', 'Circulate and find the joker past the middle defender'),
    (3, 'Middle defender', 'Block and intercept passes into the jokers')
) AS v(so, role, job);

-- 50. pp.206-209
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Section 3 - Small Sided Game Example 1 Scan to Play Forward Bounce Game', 'Play forward early via bounce players',
    '3v3 with bounce players beside both goals; the team plays forward early to the bounce players near the opposition goal when it is on, and teammates quickly join to support and finish first time from the bounce pass.',
    'Forward bounce player free',
    'Create quick scoring chances through forward bounces and fast support runs.',
    NULL, 206, 209, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside players', 'Scan up the pitch, play forward early, join the attack'),
    (2, 'Attacking bounce players', 'Set the ball back for a one-touch finish; give a visual cue for teammates'),
    (3, 'Own-half bounce players', 'Help keep and recycle possession and build up')
) AS v(so, role, job);

-- 51. pp.210-212
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'scanning-how-to-train-it-and-develop-game-awareness-see-more-think-quicker-play-'), 'in_possession', 'Section 3 - Small Sided Game Example 2 Play to Advanced Wide Players Game', 'Get it wide, run in for the cross',
    '3v3 plus wide players restricted high and wide; the team tries to get the ball wide so the wide players can cross, and inside players make quick supporting runs to score; if no chance appears they combine with the wide player or recycle possession. Receivers coming back from the wide player check across to the other wide player.',
    'Ball reaches an advanced wide player',
    'Score from crosses, or keep the ball and switch when the cross is not on.',
    NULL, 210, 212, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advanced wide players', 'Deliver crosses, combine, or recycle'),
    (2, 'Inside attackers', 'Make fast supporting runs into the box'),
    (3, 'Receiver from wide', 'Scan across to the far wide player before receiving')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1973-coaching-book-scanning-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
