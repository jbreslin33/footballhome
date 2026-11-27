-- 1962 📚 Coaching book patterns: "Coaching Positional Play" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Coaching Positional Play',
    subtitle    = '"Expansive Football" Attacking Tactics & Practices',
    author      = 'Pasquale Casà Basile',
    team        = 'Spanish 4-3-3 game model (Catalan FA / RCD Espanyol youth)',
    method_note = 'A Spanish positional-attack game model the author calls Expansive Football, from a 4-3-3: make the pitch big (wingers and full backs wide, inside players staggered on diagonals), circulate side to side to find the free side, always pair width with depth, and keep balance behind the ball for the transition. Chapter 2 is the tactical model (build-up, the 6 as escape valve, switches, striker movement, balance); chapters 4-8 cover teamwork, competitive will, the game model''s principles per phase and a worked training week; chapter 9 grades practices from unopposed pattern play (IPTE) to opposed games (IPTETA), possession games and positional games. Patterns here are the on-pitch behaviours, in our words; learning theory, psychology and drill layouts are left out.'
WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices');

-- 1. pp.17-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Expansive Football Concepts - Two Vital Expansive Football Concepts', 'Between lines plus width, three supports',
    'Every situation needs width and depth: play between the opponent''s defensive and midfield lines (especially centrally) and use wide space the compact block leaves, moving the ball side to side until progress opens. Around the carrier there are always three supports.',
    'Any possession phase',
    'Invade the opponent''s half through continuity and constant support.',
    NULL, 17, 29, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Last defender', 'security behind the ball in case of loss'),
    (2, 'Close supporter', 'just behind the ball carrier for continuity'),
    (3, 'Deep attacking supporter', 'high up the pitch vertically for depth'),
    (4, 'Wide players', 'keep width so the ball can be switched'),
    (5, 'Midfielders', 'receive between the opponent''s lines')
) AS v(so, role, job);

-- 2. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Building Up Play from the Back - Passing Out from the Goalkeeper to the Full Back with Good Support Play', 'GK to CB to CB out wide',
    'Goal kick / GK in possession; ball goes GK to one CB, across to the other CB and out to a wide man, with nearby players always within passing range of the carrier.',
    'GK has the ball, no heavy press',
    'Ball reaches the full back or wide man with continuity and a safe outlet behind.',
    NULL, 21, 21, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'stand just outside the 6-yard box level with the ball carrier as an emergency option'),
    (2, 'Far centre back (5)', 'stay deep for support and security'),
    (3, 'Defensive midfielder (6)', 'stay close to the ball for continuity'),
    (4, 'Attacking midfielder (8)', 'hold central, support the wide players'),
    (5, 'Attacking midfielder (10)', 'move diagonally forward to support the full back'),
    (6, 'Full back (3)', 'receive high and wide')
) AS v(so, role, job);

-- 3. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Building Up Play from the Back - Building Up Play Using the Defensive Midfielder', 'Back rhombus GK-CBs-6 build-up',
    'Full backs very wide, CBs split wide, 6 just above and GK central form a rhombus that combines freely against an opponent waiting in the middle third. If they mark one 8/10, the 6 drops into the passing lane to pull doubt onto that marker and the ball is worked towards the unmarked side.',
    'Opponent not pressing high; one attacking mid tightly marked',
    'Create a free man / 2v1 in the first line and play out to the weaker-pressing side.',
    NULL, 22, 22, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (4, 5)', 'split wide, combine with GK and 6'),
    (2, 'Full backs (2, 3)', 'hold very wide'),
    (3, 'Defensive midfielder (6)', 'sit slightly higher than CBs, then drop into the passing channel to create doubt'),
    (4, 'Goalkeeper', 'central in the box as the rhombus base'),
    (5, 'Attacking midfielders (8, 10)', 'push up; free one is the target')
) AS v(so, role, job);

-- 4. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Building Up Play from the Back - When the Defensive Midfielder is Marked Closely', 'Bypass marked 6 with flank 3v1',
    'Opponent man-marks the 6 so the CB cannot find him; the 8, winger and full back gather near the flank to make a 3v1, and the CB dribbles at the nearest opposing winger to draw him before playing into the 8, who releases the advancing full back.',
    '6 closely marked, pass into 6 blocked',
    'Break the first press down the side and attack the opponent''s half.',
    NULL, 23, 23, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Unmarked centre back (4)', 'receive from GK, dribble at the opposing winger to draw him'),
    (2, 'Attacking midfielder (8)', 'drop toward the flank, receive and play first time to the full back'),
    (3, 'Full back (2)', 'advance down the line to receive'),
    (4, 'Winger (7)', 'join the flank to make the 3v1'),
    (5, 'Defensive midfielder (6)', 'stay marked, keep the marker busy')
) AS v(so, role, job);

-- 5. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Building Up Play from the Back - Against the Opposition''s High Press (2 Markers)', '6 drops to make back three',
    'Opponent''s two forwards press and mark both CBs; the 6 drops between them to form a flat back three, with the midfielders staggered on diagonals and not too close to the ball carrier.',
    'Two forwards mark both centre backs',
    'Free man in the first line, then progress through the near 8 to the full back.',
    NULL, 24, 24, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (6)', 'drop into a flat back three, receive from GK'),
    (2, 'Near attacking midfielder (8)', 'receive from 6; if free play straight to the full back (dribble first to draw his marker if needed), if marked set to the CB'),
    (3, 'Centre back (5)', 'receive the set and play out wide'),
    (4, 'Full back (3)', 'hold width as the outlet'),
    (5, 'Midfielders (8, 10)', 'stagger diagonally, keep markers away from the ball')
) AS v(so, role, job);

-- 6. pp.25-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Building Up Play from the Back - Against the Opposition''s High Press (3 Markers)', 'Full back drops vs three pressers',
    'Opponent uses three players to mark both CBs and the 6; one full back drops to give the GK an easy pass, then reads the cover to choose between the winger and the near midfielder.',
    'Three pressers on CBs and 6',
    'Get the ball out to the winger with superiority around the ball.',
    NULL, 25, 25, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (2)', 'drop deep for the GK; if the line pass is covered play to the 8, if the 8 is covered play straight down the line to the winger'),
    (2, 'Attacking midfielder (8)', 'offer inside, lay off to the winger'),
    (3, 'Winger (7)', 'hold the touchline as the target'),
    (4, 'Defensive midfielder (6)', 'drop back to keep numbers around the ball')
) AS v(so, role, job);

-- 7. pp.26-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Building Up Play from the Back - Using the Goalkeeper to Create a Numerical Superiority', 'Goalkeeper as extra outfield player',
    'GK passes to a CB who is closed down; the CB plays into the 6, who has a man behind him and returns to the free GK; the GK carries toward the next defender to draw the pressing forward, then releases the freed CB, who dribbles toward the flank to drag a winger before the ball goes out wide.',
    'CB or 6 closed down after GK''s first pass',
    'Use the GK to make a +1 at the back and finally play the full back.',
    NULL, 26, 26, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'always available, take the bait, carry to draw the presser, release the free CB'),
    (2, 'Centre back (4)', 'receive, play inside to 6 when closed'),
    (3, 'Defensive midfielder (6)', 'if an opponent is behind him, bounce back to GK'),
    (4, 'Centre back (5)', 'once freed, dribble toward the flank to draw the winger then play wide'),
    (5, 'Full back (3)', 'final wide receiver')
) AS v(so, role, job);

-- 8. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Expansive Football Concepts - Expansive Football: The Second Phase', 'Winger-full back overlap, else recycle inside',
    'After gaining width, the full back connects with his winger down the flank: full back overlaps; if the overlap is not on, the winger turns back inside away from the crowded zone and the ball is circulated through the mids and out again for the overlap.',
    'Ball reaches the winger on the flank',
    'Gain depth down the flank while never forcing it; keep possession even by going back.',
    NULL, 28, 28, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (3)', 'overlap past the winger (unless winger already near the byline)'),
    (2, 'Winger (11)', 'find the overlap or carry back inside and pass to a mid'),
    (3, 'Attacking midfielder (10)', 'one supports deep, the other close for continuity'),
    (4, 'Defensive midfielder (6)', 'support and security'),
    (5, 'Striker (9)', 'move vertically for deep support, lay off to a mid'),
    (6, 'Attacking midfielder (8)', 'return the ball wide for the winger/overlap')
) AS v(so, role, job);

-- 9. pp.31-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'The Role of the Defensive Midfielder - Pros and Cons / Used as an ''Escape Valve''', '6 as escape valve, not hub',
    'Ball should move winger to 8/10 to winger without the 6 so it gets wide faster; the 6 stays behind the ball for security and is used only when needed, e.g. when the ball is wide and the near 10 has pushed up for a 3v1/2v1 and the other mid is tightly marked.',
    'Flank congested, near mids marked',
    '6 receives back, decongests and spreads play to the other side.',
    NULL, 31, 32, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (6)', 'sit deeper and central behind the ball, offer the back pass, switch to the far side; offer quick one-twos'),
    (2, 'Attacking midfielder (10)', 'move close to the winger to make the overload'),
    (3, 'Winger (11)', 'play back to 10 or 6 when blocked'),
    (4, 'Far attacking midfielder (8) / far winger (7)', 'receive the switch'),
    (5, 'Far full back (2)', 'push on to receive wide')
) AS v(so, role, job);

-- 10. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'The Role of the Defensive Midfielder - The Defensive Midfielder Plays a Long Pass to the Flank', 'Draw in, 6 long-switches',
    'A quick short sequence on one flank pulls the opposing defence into that zone; the 6 then plays a long high ball to the far flank over the grouped defenders. One of the few times a long pass is wanted.',
    'Opponent defenders grouped in one zone',
    'Free teammate receives in space on the weak side.',
    NULL, 33, 33, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (6)', 'receive after the drawing sequence and hit the long diagonal'),
    (2, 'Ball-side winger, 10 and full back', 'short combinations to draw the defence in'),
    (3, 'Far winger (7)', 'hold width, run onto the switch')
) AS v(so, role, job);

-- 11. pp.35-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Support Play When the Ball is Out Wide - Roles and Responsibilities (1) and (2)', 'Rhombus support when ball wide',
    'With the ball wide, full back, winger, 6 and near 10 form a rhombus for superiority, with passes on to the far full back or striker; CBs and GK give defensive depth but push up as the attack advances, the striker gives attacking depth. When the full back overlaps, the winger becomes the support behind the ball.',
    'Ball with full back or winger on the flank',
    'Superiority around the ball plus cover and immediate pressure if it is lost.',
    NULL, 35, 36, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (6)', 'close and behind the line of the ball, ready to press or cover on loss'),
    (2, 'Near attacking midfielder (10)', 'close and behind the ball, not in line with the 6 so passing lanes stay open'),
    (3, 'Full back / winger pair', 'one carries, the other overlaps or supports behind the ball'),
    (4, 'Centre backs (4, 5) and GK', 'defensive depth, step up as play progresses'),
    (5, 'Striker (9)', 'attacking depth')
) AS v(so, role, job);

-- 12. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Switching Play - Key Concepts when Switching Play / No Horizontal Passes', 'Staggered lines, no flat passes',
    'Ball from a wing goes forward or across to the other side; during wide attacks players stay staggered on different lines so passes are diagonal, never flat square balls that are easy to cut out. Short passes in tight spaces, long flat ones to distant zones; constant changes of direction.',
    'Ball on one wing, opponent overloading the ball zone',
    'Unbalance the block, escape their overload and find passive zones higher up.',
    NULL, 38, 38, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'stagger diagonally, never level with each other'),
    (2, 'Full backs and centre backs', 'join higher up so every added man ties down an opponent'),
    (3, 'Ball carrier', 'choose forward or cross-field, short in tight areas, long flat to far zones')
) AS v(so, role, job);

-- 13. pp.39-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Switching Play - Attacking With the Winger in an Advanced Position', 'Advanced winger options, far side ready',
    'Winger high on the ball side can cross to timed runs, play back to a supporting mid, or take his man on; the far winger stays wide near the touchline to receive a switch. If the ball winger comes inside, the full back fills the space; if the far winger''s marker tucks in, the far full back runs inside him on the break.',
    'Winger receives high on the flank',
    'Final-third chance or a ready switch to the other side.',
    NULL, 39, 39, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger (11)', 'cross, pass back to 10, or beat his man'),
    (2, 'Attacking midfielder (10)', 'support position behind the winger'),
    (3, 'Far winger (7)', 'stay wide, ready to cross, shoot or combine'),
    (4, 'Midfielders', 'make 3v1s with one-twos, triangles, overlaps'),
    (5, 'Far full back (2)', 'break forward inside the winger when his marker drifts across')
) AS v(so, role, job);

-- 14. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Switching Play - Creating a Numerical Advantage on the Flank (Overlapping Full Back)', 'Switch to create flank 3v1',
    'Numbers equal around the ball, so the ball is switched to the opposite side where winger, 8 and overlapping full back build a 3v1 (or 3v2 with cover) against their full back.',
    'Equality of numbers in the ball zone',
    '2v1 / 3v1 on the far flank and progress through the centre or down that wing.',
    NULL, 40, 40, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (8)', 'receive the switch, support the winger inside'),
    (2, 'Far winger (7)', 'receive wide, isolate their full back'),
    (3, 'Far full back (2)', 'overlap; if he cannot go, winger and 8 still make 2v1')
) AS v(so, role, job);

-- 15. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Switching Play - Switching Play When the Opposition Condenses the Space on the Flank', '3v3 on flank means switch',
    'Opponent covers and doubles up near the flank so it is 3v3 and progress is blocked; winger plays back to the supporting 8, who finds the central 10, who switches to the far winger while the far full back overlaps.',
    'Opponent condenses the ball-side flank (numbers equal)',
    '2v1 on the far flank and run in behind their defence.',
    NULL, 41, 41, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger (7)', 'pass back to the supporting 8'),
    (2, 'Attacking midfielder (8)', 'move the ball across to 10'),
    (3, 'Attacking midfielder (10)', 'central, complete the switch to the far winger'),
    (4, 'Far winger (11)', 'receive wide'),
    (5, 'Far full back (3)', 'overlap to receive in space')
) AS v(so, role, job);

-- 16. pp.42-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Switching Play - Diagonal Break Away ''The Taglio'' (and Continued)', 'The Taglio: crossing diagonal runs',
    'Mid receives, plays into the striker, who sets to the other mid; the first mid then breaks into space pulling his marker, and striker and mid make diagonal runs in opposite directions at the same time. The receiving mid chooses between the striker breaking in behind, the forward-breaking mid, or the winger overlapped by the full back.',
    'Midfielder receives facing play behind the striker',
    'Open the centre and release a runner in behind.',
    NULL, 42, 43, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'show to receive and set, then ''go dark'' and break diagonally behind'),
    (2, 'Attacking midfielder (8)', 'play into 9, then break diagonally forward the other way'),
    (3, 'Attacking midfielder (10)', 'receive the set and pick the best of three passes'),
    (4, 'Winger (11)', 'stay wide as third option'),
    (5, 'Full back (3)', 'overlap the winger')
) AS v(so, role, job);

-- 17. pp.44-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Switching Play - Playing a ''Wide Game'' to Stretch the Opposition (1)', 'Wide game vs narrow defence',
    'Players stay high and on diagonals so the ball is played to someone facing play (not back to goal), who can return it, find a third man or go wide. When their defence stays central and tight, the ball is moved quickly across before the unit shifts, or the winger and full back create a 2v1 on one defender.',
    'Opponent defence compact and central, flanks open',
    'Exploit the open flank before the block slides.',
    NULL, 44, 44, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders (10, 8)', 'move the ball across fast, pass to players facing forward'),
    (2, 'Far winger (7)', 'hold width in the free space'),
    (3, 'Far full back (2)', 'join to make 2v1 on their full back')
) AS v(so, role, job);

-- 18. pp.45-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Switching Play - Playing a ''Wide Game'' to Stretch the Opposition (2)', 'Wide play opens CB-FB gap',
    'The defence stretched by width opens space between its defenders; quick switching and one-twos let midfielders attack the centre, and the winger and 8 combine so the full back runs into the channel between their centre back and full back.',
    'Opponent defenders spread apart after wide attacks',
    'Penetrate the gap between centre back and full back or through the centre.',
    NULL, 45, 45, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (8)', 'carry inside, choose winger in the box or overlapping full back'),
    (2, 'Winger (7)', 'come inside to occupy their full back and receive in the box'),
    (3, 'Full back (2)', 'overlap into the space between CB and FB'),
    (4, 'Midfielders', 'one-twos to break through the centre')
) AS v(so, role, job);

-- 19. pp.47-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'The Role of the Striker - The Striker''s Role in Expansive Football', 'Striker as spearhead, roaming radius',
    'Centre forward stays high as the spearhead to give depth, stretch the opposition vertically, keep moving to lose markers and break into space behind the line; he also moves sideways to receive behind their holding midfielders (behind the two in a 4-2-3-1, behind the one in a 4-1-4-1).',
    'Team in possession',
    'Pin and stretch the back line and be free to run in behind.',
    NULL, 47, 47, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'stay high, move constantly, drop or slide to receive behind their DMs, break in behind')
) AS v(so, role, job);

-- 20. pp.48-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'The Role of the Striker - Escaping a Marker with Unseen Movement', 'Striker ''goes dark'' behind marker',
    'Before receiving, the striker moves round behind his marker into the zone where the defender cannot see both him and the ball, or runs onto a ball over his shoulder; then shows to receive and lays off.',
    'Midfielder on the ball looking to play in',
    'Free the striker from his marker.',
    NULL, 48, 48, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'drift behind the defender''s back out of sight, then appear to receive'),
    (2, 'Attacking midfielders (8, 10)', 'play into the striker and receive the lay-off')
) AS v(so, role, job);

-- 21. pp.50-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Retaining Balance in the Possession Phase - Effective Use of Dribbling / Dribbling to Draw a Marker Away', 'Dribble to drag a teammate''s marker',
    'A player who receives unmarked carries the ball, often diagonally, toward a teammate''s marker; when the marker commits he releases the pass to the freed teammate. Chains: CB draws the winger off the full back, full back draws the 10''s marker, 10 draws the full back off the winger.',
    'Receiver free of marking with space ahead',
    'Free a teammate in space and make defenders feel attacked.',
    NULL, 50, 51, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (5)', 'dribble diagonally toward the sideline to draw the opposing winger, pass to full back'),
    (2, 'Full back (3)', 'carry forward to draw the 10''s marker, pass inside'),
    (3, 'Attacking midfielder (10)', 'carry at an angle to draw the opposing full back, release the winger'),
    (4, 'Winger (11)', 'receive free on the flank, attack behind the line; can dribble inside to free space for the overlapping full back')
) AS v(so, role, job);

-- 22. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Retaining Balance in the Possession Phase - Compensatory Movements to Provide Cover and Balance', 'Compensatory movements keep balance',
    'When one player leaves his zone another compensates: if one full back goes forward the other stays a few yards behind (but higher than the CBs); if a free CB carries into midfield, the 6 drops into his place and they swap roles.',
    'Full back advances or CB steps up with the ball',
    'Keep shape and enough numbers at the back if the ball is lost.',
    NULL, 52, 52, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advancing full back (3)', 'push on'),
    (2, 'Opposite full back (2)', 'hold a few yards behind, level with the 6'),
    (3, 'Centre back (5)', 'dribble into midfield when unmarked'),
    (4, 'Defensive midfielder (6)', 'drop into the CB''s spot to cover')
) AS v(so, role, job);

-- 23. pp.53-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Retaining Balance in the Possession Phase - Retaining a Balanced Formation / Providing Support and Maintaining Defensive Shape', '4-3-3 becomes 2-3-2-3',
    'In the attacking phase the 4-3-3 turns into a 2-3-2-3 of four lines: two CBs and the 6 behind the ball, full backs level with the 6, the 8 and 10 a step higher, wingers and striker highest. Only one full back joins at a time; staying level with the 6 keeps full backs close to the ball area and short of ground to recover.',
    'Settled possession in the opponent''s half',
    'Triangles/rhombuses for support and four defensive lines ready for the transition.',
    NULL, 53, 55, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (4, 5)', 'rest defence with the 6'),
    (2, 'Defensive midfielder (6)', 'screen and cover'),
    (3, 'Full backs (2, 3)', 'same line as the 6; one may join, the other stays'),
    (4, 'Attacking midfielders (8, 10)', 'a step above the 6, form triangles'),
    (5, 'Wingers and striker (7, 9, 11)', 'front line, wide and high')
) AS v(so, role, job);

-- 24. pp.54-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Retaining Balance in the Possession Phase - Intervention, Phase and Cooperation Spaces', 'Intervention and cooperation spaces',
    'Zones defined around the ball: the intervention space where the ball is; the direct cooperation space holding the players directly supporting the carrier (e.g. advanced LB, 8, striker beside a winger); and the indirect cooperation space for the far players who make compensatory moves (far full back drops, 6 covers).',
    'Ball high up with a winger',
    'Every player knows his job relative to the ball zone, in attack and for the loss.',
    NULL, 54, 54, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier (winger 11)', 'act in the intervention space'),
    (2, 'Direct cooperators (LB 3, 8, 9)', 'support close to the ball'),
    (3, 'Indirect cooperators (RB 2, 6, CBs)', 'balance and cover away from the ball')
) AS v(so, role, job);

-- 25. pp.56-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'to_defend', 'Retaining Balance in the Possession Phase - The Transition from Attack to Defence', 'Double press in intervention space',
    'Winger loses the ball to their full back high up; the winger presses at once with the 8 to double the new carrier inside the intervention space, the advanced LB steps up to mark the likely receiver tightly, and the 6 and far full back hold balance.',
    'Ball lost in the intervention space high up',
    'Win it back quickly or block the outlet; protect against a break.',
    NULL, 56, 56, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (11)', 'first presser on the new carrier'),
    (2, 'Attacking midfielder (8)', 'double the carrier'),
    (3, 'Left back (3)', 'step up and mark the nearest receiver tightly'),
    (4, 'Defensive midfielder (6)', 'balance behind'),
    (5, 'Far full back (2)', 'balance in case they break through')
) AS v(so, role, job);

-- 26. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'to_defend', 'Retaining Balance in the Possession Phase - Cohesion Between Dynamic Spaces', 'Compact on loss, step up',
    'Many players are already in the intervention and direct support spaces, so on loss everyone moves closer together and onto the nearest opponent, and the line steps up so their highest player can be caught offside; if not won quickly, settle into a narrow, short compact block.',
    'Ball lost near the opponent''s goal',
    'Numerical superiority around the ball, deny time and space, recover fast.',
    NULL, 57, 57, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players near the ball', 'close down quickly, move toward the ball'),
    (2, 'All players', 'move closer to each other and their nearest opponent'),
    (3, 'Back line', 'push up to play the highest opponent offside')
) AS v(so, role, job);

-- 27. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Retaining Balance in the Possession Phase - Importance of Cohesion to Prevent Isolating One Player', 'Avoid isolating long balls',
    'Mids should not keep hitting long high balls out to a winger: he ends up 1v1 and, if it is lost, the team is too far apart to press and the opponent counters (diagram: their left back steals a long pass).',
    'Temptation to go long to the wing',
    'Keep numbers around the ball so a loss can be pressed immediately.',
    NULL, 58, 58, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders (6, 8, 10)', 'prefer short supported passes over long balls to the winger'),
    (2, 'Winger', 'receive with support nearby, not isolated')
) AS v(so, role, job);

-- 28. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'out_of_possession', 'Methodologies to Use in Training - Tactical Periodization (fundamental principles example)', 'Line closes behind stepping CB',
    'Fundamental principle regardless of system: when a centre back steps out to intercept, his teammates in the back line close the space behind him; there must always be a back line of 4 or 5.',
    'Centre back steps out of the line',
    'No gap left behind the stepping defender.',
    NULL, 61, 61, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Stepping centre back', 'step out to intercept'),
    (2, 'Other defenders', 'slide across and close the space behind him, keep a line of 4-5')
) AS v(so, role, job);

-- 29. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Ch4 Collaboration of Movement', 'Chain rotation to free the ball carrier',
    'Centre back has the ball; several attackers move at once so each vacated space is refilled by the next player, giving the carrier multiple options.',
    'Centre back in possession, no clear forward pass',
    'Keep constant, coordinated movement so the carrier always has several solutions and markers are pulled away.',
    NULL, 66, 66, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'Drops short to offer to the centre back'),
    (2, 'Attacking midfielder (10)', 'Moves into the space the 9 left'),
    (3, 'Full back (3)', 'Pushes high into the winger''s lane'),
    (4, 'Central midfielder (8)', 'Slides into the space left by the full back'),
    (5, 'Winger (11)', 'Comes inside into the space the 8 left')
) AS v(so, role, job);

-- 30. pp.66-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'out_of_possession', 'Ch4 Social-Affective Dimension / Principles of the 4 Game Phases', 'Cover, double up, swap positions',
    'Defending as a collective: nearest teammate covers the man engaging the ball, a second player doubles on the carrier, and players exchange positions when one is pulled out.',
    'Teammate engages a dribbler or is beaten',
    'No defender is left alone against an opponent; the block stays intact while players swap roles.',
    NULL, 66, 88, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest teammate', 'Covers behind the player pressing the ball'),
    (2, 'Second defender', 'Doubles up on the ball carrier'),
    (3, 'Displaced defender''s neighbour', 'Takes over his zone (position exchange)')
) AS v(so, role, job);

-- 31. pp.70-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Social-Affective Practices / Emotional Will practice', 'Two-man combination: one-two, overlap, vertical pass',
    'Small attacking pairs (or pairs vs pairs) solve the defender with one-twos, vertical passes and overlapping runs; the receiver of a long ball sets himself in line with the passer so his first touch sets up his partner.',
    '2v2 or 2v1 in front of goal, or a long pass arriving',
    'Beat the defending pair through cooperation and finish quickly.',
    NULL, 70, 78, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Plays a one-two or vertical pass and follows'),
    (2, 'Partner', 'Offers the wall pass or overlaps outside'),
    (3, 'Receiver of long pass', 'Positions in line with passer; one-touch controlled set to partner')
) AS v(so, role, job);

-- 32. pp.73-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'to_defend', 'Social-Affective Practices / Warm Ups / Principles of the 4 Game Phases', 'Partner of the loser closes the winner',
    'When a pass is intercepted, the teammate nearest the player who lost it immediately closes down the new ball carrier to stop his first pass, rather than leaving it to the culprit.',
    'Interception / ball lost in a tight area',
    'Block the regaining team''s first outlet pass and win the ball back straight away.',
    NULL, 73, 120, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Teammate of the player who lost it', 'Sprints at the new carrier, blocks his passing line'),
    (2, 'Player who lost it', 'Closes the nearest receiving lane'),
    (3, 'Two-man pressing unit', 'Work together to shut passing angles and press the ball')
) AS v(so, role, job);

-- 33. pp.74-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'to_attack', 'Social-Affective Practices / Warm Ups / Transition from Defence to Attack', 'Secure first pass out of recovery zone',
    'The player who wins the ball moves it at once to a nearby teammate in a good position (often out wide), who then decides whether to counter or keep it.',
    'Ball won in a crowded area',
    'Escape the high-density regain zone before the opponent counter-presses.',
    NULL, 74, 120, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Immediately passes to the nearest free teammate or plays out wide'),
    (2, 'Nearby teammate / partner', 'Gets into an open receiving position before the regain completes'),
    (3, 'Receiver', 'Chooses counter (depth) or combined attack (possession)')
) AS v(so, role, job);

-- 34. pp.86-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Principles of the 4 Game Phases - Attacking Phase', 'Find the third man',
    'When the direct receiver is marked, the ball goes to a nearby or distant teammate who can play the free third man facing play.',
    'Intended receiver marked tight',
    'Bypass pressure through a set-and-release with a third player.',
    NULL, 86, 86, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Plays into the set player'),
    (2, 'Set player', 'Lays off first time'),
    (3, 'Third man (near or far)', 'Arrives free to receive facing goal')
) AS v(so, role, job);

-- 35. pp.86-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'out_of_possession', 'Principles of the 4 Game Phases - Defensive Phase', 'Covered/uncovered ball and elastic defence',
    'The back line reads whether the ball carrier is under pressure (covered) or free (uncovered): step up and squeeze when covered, drop when uncovered, using an ''elastic'' line to catch attackers offside.',
    'Change in pressure on the ball carrier',
    'Control depth behind the line and play opponents offside.',
    NULL, 86, 88, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Step up together when ball covered'),
    (2, 'Back four', 'Drop together when ball uncovered'),
    (3, 'Ball presser', 'Signals cover by engaging the carrier')
) AS v(so, role, job);

-- 36. pp.86-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'to_defend', 'Transition from Attack to Defence sub-principles', 'Mark counter threats, keep a spare defender',
    'While the ball is pressed, defenders tightly mark the players most likely to join a counter (the furthest and most dangerous), always keeping one free defender plus a goalkeeper who steps a little off his line; their strikers and midfielders are pressed very high.',
    'Ball lost, opponent looking to counter',
    'Neutralise the counter-attack outlets while the ball is being regained.',
    NULL, 86, 98, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'Mark the furthest and most dangerous attackers'),
    (2, 'Free defender', 'Stays unmarked as cover'),
    (3, 'Goalkeeper', 'Moves slightly off his line to sweep'),
    (4, 'Midfielders', 'Press their strikers and midfielders high')
) AS v(so, role, job);

-- 37. pp.86-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Principles of the 4 Game Phases - Attacking Phase (''Expansive Football'')', 'Circulate fast, make the pitch big',
    'Major principle of the model: quick ball circulation with width, depth and diagonal angles, continuous support, optimal distances, and constant interchanging of positions while staying aware of the furthest teammates.',
    'Settled possession',
    'Stretch the opponent in space and time so gaps open between his lines.',
    NULL, 86, 102, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers / far full back', 'Hold width on both sides'),
    (2, 'Striker', 'Gives depth'),
    (3, 'Midfielders', 'Offer diagonal support lines at optimal distance'),
    (4, 'All players', 'Keep moving and rotate positions')
) AS v(so, role, job);

-- 38. pp.86-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Principles of the 4 Game Phases - Attacking Phase', 'Start one side, finish the other',
    'Build on one flank to attract the block, cap play in one zone at about four passes, then switch to the far side to progress deeper.',
    'Opponent has shifted to the ball side, or four passes made in one zone',
    'Attack the weak side once the opponent is drawn over.',
    NULL, 86, 102, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side players', 'Circulate quickly to draw the block'),
    (2, 'Defensive midfielder / centre backs', 'Act as the switching hub'),
    (3, 'Weak-side full back and winger', 'Stay wide and ready to receive the switch')
) AS v(so, role, job);

-- 39. pp.86-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Principles of the 4 Game Phases - Attacking Phase', 'Play outside to play inside',
    'Use the flanks to pull the defence wide, then exploit the central gaps that open; once progression is possible, never pass backwards.',
    'Defence narrows or is drawn to the touchline',
    'Open central penetration lanes after drawing defenders wide.',
    NULL, 86, 102, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger / full back', 'Receive wide to stretch the back line'),
    (2, 'Inside midfielders / striker', 'Attack the inside channel that opens')
) AS v(so, role, job);

-- 40. pp.86-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Attacking Phase sub-principles / Operational strategy', 'Far-side 2v1 and assist to breaking runners',
    'Opposite-side full backs stay involved in the passive zone for width and diagonals; when the switch lands on that wing the team seeks at least a 2v1 on the flank (and inside), with the final pass going to strikers or inside players breaking in.',
    'Ball switched to the opposite wing',
    'Turn the switch into a numerical edge and a final-third assist.',
    NULL, 86, 102, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side full back / wing back', 'Stays engaged high and wide in passive zone'),
    (2, 'Weak-side winger', 'Forms the 2v1 with the full back'),
    (3, 'Strikers / inside players', 'Break into the box for the assist')
) AS v(so, role, job);

-- 41. pp.86-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Principles of the 4 Game Phases / Rules of specific tactical behaviours', 'Dribble to draw and divide',
    'A player alone with the ball carries it at a defender to pull him off a teammate, freeing that teammate or himself.',
    'Receiver has no immediate pass, marker nearby',
    'Commit a marker and create a free man.',
    NULL, 86, 114, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Dribbles toward a defender to fix him'),
    (2, 'Nearby teammate', 'Stays available to receive once his marker is drawn')
) AS v(so, role, job);

-- 42. pp.86-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'to_defend', 'Principles of the 4 Game Phases - Transition from Attack to Defence', 'Immediate press, body blocks the long ball',
    'On losing the ball the nearest player presses at once and aggressively, angling his body to block the long pass to the forwards, while teammates close the likely passing lines; the aim is to regain close to the opponent''s goal.',
    'Ball lost',
    'Win it back high before the opponent can counter (training rule: a loser who fails gives up a keeper-less shot).',
    NULL, 86, 114, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player to the ball', 'Presses immediately, body shape cuts the forward long pass'),
    (2, 'Players near the ball', 'Close possible and probable passing lanes'),
    (3, 'Whole team', 'Compact quickly and rebuild the defensive unit')
) AS v(so, role, job);

-- 43. pp.87-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'out_of_possession', 'Principles of the 4 Game Phases - Defensive Phase', 'High line, funnel to pressing zone',
    'Compact block with a high defensive line closes from outside to inside and in width and depth (especially centrally), steers the opponent into a chosen pressing area and creates numerical superiority around the ball; regains in their half are prized (count double in training).',
    'Opponent in possession in their half',
    'Win the ball high so the team can attack in the opponent''s half.',
    NULL, 87, 114, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Holds a high line, stays compact'),
    (2, 'Wide players', 'Close outside-in to force play to the pressing zone'),
    (3, 'Ball-side unit', 'Outnumbers the opponent in the active zone'),
    (4, 'All players', 'Keep optimal distances, watch the far opponents')
) AS v(so, role, job);

-- 44. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Adapting to the Opposition / Operational Strategy', 'Build away from, then into, their weak flank',
    'Scouting shows a weak opponent flank (e.g. their left does not press our winger and wing back hard); the goalkeeper starts attacks on the other side so the ball travels across and the team then drives down the weak channel.',
    'Scouted weakness on one opponent flank',
    'Apply the same model but aim circulation at the zone the opponent defends worst.',
    NULL, 88, 88, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Initiates on our left side'),
    (2, 'Midfield / back line', 'Circulate the ball across to the right'),
    (3, 'Right winger and wing back', 'Attack deep down the exposed channel')
) AS v(so, role, job);

-- 45. pp.88-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'to_attack', 'Principles of the 4 Game Phases - Transition from Defence to Attack', 'Counter or keep: choose after regain',
    'After the first pass out of the recovery zone, the team decides between a fast vertical counter (depth) and keeping possession (combined attack), opening wide, deep and diagonally toward areas of numerical superiority; when on, attack at speed and shoot.',
    'Ball recovered and moved out of the regain zone',
    'Exploit the opponent''s disorganisation or settle into Expansive Football.',
    NULL, 88, 114, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First receiver', 'Reads space and picks counter or possession'),
    (2, 'Wingers', 'Spread wide immediately'),
    (3, 'Striker', 'Runs in behind for depth'),
    (4, 'Midfielders', 'Support toward the overloaded zone')
) AS v(so, role, job);

-- 46. pp.96-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Operational Strategy / Methods of Training (rules)', 'Safe-pass possession, restart if blocked',
    'Keep-the-ball principle: take no risks, pass to the teammate in the best position, go backwards to restart when no progression exists, vary the spaces used, and never clear the ball or hit hopeful high balls (a high pass only when it is an assist).',
    'No safe forward option',
    'Retain possession and find new progression routes without becoming predictable.',
    NULL, 96, 114, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Plays the safe pass to the best-placed teammate'),
    (2, 'Rear players', 'Offer the backward restart option'),
    (3, 'All players', 'Keep the ball individually, in triangles, then collectively')
) AS v(so, role, job);

-- 47. pp.97-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Operational Strategy within our Game Model - next opponent', '2v1 on the uncovered wing back',
    'Against a bottom-half 4-4-2 whose left centre back sits too far from his wing back, the team overloads that wing back with winger plus wing back or winger plus central midfielder, using one-twos and runs off the marker.',
    'Gap between their centre back and wing back',
    'Penetrate the space between their centre back and full back.',
    '4-4-2', 97, 97, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Engages the wing back, plays one-twos'),
    (2, 'Our wing back / full back', 'Overlaps to make the 2v1'),
    (3, 'Central midfielder', 'Alternative partner, runs into the channel')
) AS v(so, role, job);

-- 48. pp.97-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Attacking Phase sub-principles', 'Support rhombus around every receiver',
    'Each receiver should have four close options - left, right, ahead, behind - forming a rhombus at optimal distance; when the ball goes wide, midfielders, strikers and the defensive midfielder stagger at different heights.',
    'Any player receives, especially wide',
    'Give the receiver multiple layered solutions to keep the ball moving forward.',
    NULL, 97, 102, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Side supports', 'Offer left and right'),
    (2, 'Forward support', 'Offers a pass ahead'),
    (3, 'Rear support', 'Offers a safe ball behind'),
    (4, 'Midfielders / striker / DM', 'Stagger heights when the ball is wide')
) AS v(so, role, job);

-- 49. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Methods of Training - Individual and collective solutions', 'Midfielder drops, full back climbs, winger receives deep',
    'When one midfielder comes close to receive and turn, the full back on that side pushes up the wing at the same moment, anticipating the cross-field ball that finds the winger in space deep on the flank.',
    'Midfielder shows short to receive and can turn',
    'Complementary opposite movements open the flank for the winger.',
    NULL, 108, 108, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder', 'Drops close to receive and turn'),
    (2, 'Full back', 'Advances up the wing simultaneously'),
    (3, 'Winger', 'Receives the switch in space deep on the flank')
) AS v(so, role, job);

-- 50. pp.114-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Positional Game Methods', 'Fixed positions with a free-man superiority',
    'Players hold their formation positions (4-3-3) and move only within their role; numerical superiority is mandatory, supplied by utility/neutral players positioned for width, depth or a reference striker for diagonal play.',
    'Settled possession',
    'Train the real associations between neighbouring roles (full back-winger, 10-striker) while always having a spare man.',
    NULL, 114, 115, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide utility player', 'Gives width'),
    (2, 'High neutral', 'Gives depth'),
    (3, 'Reference striker', 'Target for diagonal passes'),
    (4, 'Each outfield player', 'Stays in his positional zone and loses markers within it')
) AS v(so, role, job);

-- 51. pp.123-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Tactical Small Sided Games', 'Progress zone by zone through the middle',
    'Build-up must pass through each third/zone of our half and then theirs, and through the centre rather than corner to corner or winger to winger directly.',
    'Goal kick / possession from the back',
    'Patient progression that uses central players to link the lines.',
    NULL, 123, 124, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs / goalkeeper', 'Start in zone one'),
    (2, 'Central midfielders', 'Link each zone through the middle'),
    (3, 'Wingers', 'Do not switch directly to each other; go via the centre')
) AS v(so, role, job);

-- 52. pp.124-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Tactical Small Sided Games - Attacking from Back to Front 8v6', 'Full back 2v1, striker pinned as outlet',
    'In attack the full backs push on to create 2v1s wide while the striker stays high on the last line as the depth outlet; in defence the holding midfielder drops in line with the back four.',
    'Ball progressed past halfway',
    'Overload the flank while keeping depth up front and a stable line behind.',
    NULL, 124, 124, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'Overlap to make 2v1 with the winger'),
    (2, 'Striker (9)', 'Stays high in the opponent''s half for depth'),
    (3, 'Defensive midfielder (6), when defending', 'Drops in line with the defence')
) AS v(so, role, job);

-- 53. pp.125-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Tactical Small Sided Games - Positional Play in a Dynamic 3 Team 5v5 (+4)', 'Central four use wide neutrals before finishing',
    'The central unit (6, two 8/10s, 9) keeps the ball inside but must go through a full back or winger out wide before a goal counts; scoring off a cross from wide is rewarded.',
    'Central lane congested',
    'Width players are always part of the move, so the opponent is stretched before the final action.',
    NULL, 125, 125, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder + attacking midfielders', 'Circulate centrally and release to a wide player'),
    (2, 'Full backs and wingers (wide neutrals)', 'Hold width, one or two touches, cross or return inside'),
    (3, 'Striker', 'Attack the cross')
) AS v(so, role, job);

-- 54. pp.128-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'IPTE - Build Up Play, Quick Attacking Runs, Combination Play and Finishing', 'CB-to-CB, through the 6, full back crosses',
    'One centre back plays across the box to the other, who finds the 6; the 6 combines with the 8/10 and striker, who releases a full back bombing forward to cross.',
    'Second centre back receives facing forward',
    'Full-pitch route from the back line to a cross with box runners.',
    NULL, 128, 128, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Switch across in front of the box, then pass into the 6'),
    (2, 'Defensive midfielder', 'Link to the attacking midfielders'),
    (3, 'Full backs', 'Both push high early; one receives and crosses'),
    (4, 'Striker + far full back', 'Run into the box to finish')
) AS v(so, role, job);

-- 55. pp.129-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'IPTE/IPTETA - Dribbling Forwards to Draw in a Marker / Create a Numerical Advantage', 'Carry forward to draw a marker',
    'A defender (CB, FB) or winger dribbles forward at an opponent; just before the defender commits, he passes diagonally to the teammate that opponent left. Carrying across a line puts an extra man in the next zone (3v2).',
    'Free space ahead of the ball carrier',
    'Fix a defender with the carry and release the freed teammate, creating superiority higher up.',
    NULL, 129, 141, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (ball carrier)', 'Drive forward until a marker steps out, then pass diagonally'),
    (2, 'Freed teammate', 'Check away from marker before receiving, open body shape'),
    (3, 'Full backs / wingers', 'Same carry-and-release on the flank')
) AS v(so, role, job);

-- 56. pp.130-143
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'IPTE/IPTETA - Passing Across the Defensive and Midfield Lines / Quick Combination to Switch the Play', 'Circulate along the lines to switch',
    'The back four plus GK and the midfield line (wingers, 8/10, 9) each move the ball along their line; when the winger is closed he plays inside to the 8, on to the 9 and across to the far side, then back down to the full back.',
    'Ball-side winger closed down',
    'Quick one/two-touch circulation that relocates the attack to the free side.',
    NULL, 130, 143, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'Start and finish the circulation, feed winger in front'),
    (2, 'Wingers', 'If closed off, pass inside rather than force it'),
    (3, 'Attacking midfielders + striker', 'Pivot the ball across the line'),
    (4, 'Goalkeeper + centre backs', 'Extra links in the back-line switch')
) AS v(so, role, job);

-- 57. pp.132-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'IPTE - Positional Passing Square with Short and Long Support Play', 'Short support then deep pass on break',
    'Players combine short through 8, 9 and 10, then the last pass goes long to a teammate far away, like the deep ball to a winger or overlapping full back on the break.',
    'Short combination has drawn opponents in',
    'Mix short and long support so the ball can be played early into depth.',
    NULL, 132, 132, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielders', 'Combine short around the striker'),
    (2, 'Striker', 'Wall pass for the third man'),
    (3, 'Receiver', 'Check away before showing to receive first time'),
    (4, 'Winger / overlapping full back', 'Target of the long pass')
) AS v(so, role, job);

-- 58. pp.133-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'IPTE - Quick Combination Play with Positional Inter-Changing of Diagonal Movements', 'Diagonal rotations among front five',
    'In the opposition half the 8/10 play to a winger, who finds the other 8, who plays the near winger, who finds the 9; each player moves on to the next position after passing.',
    'Ball in opposition half between lines',
    'Constant diagonal interchanges keep markers unsure while the shape stays filled.',
    NULL, 133, 133, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielders', 'Play wide then take the next slot diagonally'),
    (2, 'Wingers', 'Play inside to the other 8 or the 9'),
    (3, 'Striker', 'Lay off and rotate')
) AS v(so, role, job);

-- 59. pp.134-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'IPTE/IPTETA - Switching the Point of Attack in the Final Third / ''Expansive Football'' Combination 7v2', 'Blocked flank: switch for far-side cross',
    'With the full back blocked by at least equal numbers on his flank, the ball goes FB -> winger -> 10 -> (9) -> 8 -> far winger -> far full back, who crosses while runners attack the box past the centre backs.',
    'Opponent level or better in numbers on the near flank',
    'Move the attack to the far flank and finish from a cross with several runners.',
    NULL, 134, 144, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near full back + winger', 'Start the move, then join the box'),
    (2, 'Attacking midfielder (10)', 'Find the other 8 directly or via the 9'),
    (3, 'Far winger', 'Shift the ball out to the far full back'),
    (4, 'Far full back', 'Overlap and cross'),
    (5, 'Striker + midfielders', 'Time runs into the box, escape the centre backs')
) AS v(so, role, job);

-- 60. pp.135-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'IPTE - Technical/Tactical Actions on the Wing: Dribble, Support Play & Finishing', 'Winger cuts in, one-two, runs behind',
    'The winger dribbles at the full back, comes inside and plays a one-two with the striker or AM who drops to support, then runs in behind for the return and finishes.',
    'Winger isolated against the full back',
    'Beat the full back with a carry plus wall pass and get in behind.',
    NULL, 135, 135, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Dribble, cut in, one-two, run behind, finish (weaker foot too)'),
    (2, 'Striker / attacking midfielder', 'Drop off to offer the wall pass')
) AS v(so, role, job);

-- 61. pp.136-157
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'IPTE/IPTETA - Attacking Through the Centre / Support Play for the Striker (''go dark'')', 'Striker goes dark, turns on half-turn',
    'While a midfielder or CB carries forward, the 9 drops into a spot where his marker cannot see both him and the ball (''go dark''), checks his shoulder, receives on the back foot on the half-turn, turns and shoots. In a 2-1-3 zonal game, once a defender dribbles into midfield the striker drops into that zone to support.',
    'Teammate dribbles into midfield',
    'Get the striker the ball facing goal between the lines.',
    NULL, 136, 157, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'Move into marker''s blind side, scan, receive half-turned, turn and finish'),
    (2, 'Centre midfielder (8)', 'Dribble at a defender, then feed the striker'),
    (3, 'Centre back', 'Dribble into midfield to trigger the striker''s drop'),
    (4, 'Wide neutrals', 'Give an outlet before the final pass')
) AS v(so, role, job);

-- 62. pp.138-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'IPTETA - Centre Backs: Building Up Play Through the Defensive Midfielder', 'Beat a two-man press via the 6',
    'Against two forwards pressing the CBs and GK, the 6 drops in once both CBs and the keeper have touched the ball, making 3v2 (+GK); the team must exploit the edge and finish fast before a third opponent arrives.',
    'Two forwards press the back two',
    'Use the extra man to break the first press and attack quickly, inside about 7 seconds.',
    NULL, 138, 138, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Start play and act as extra passer'),
    (2, 'Centre backs', 'Split, receive under pressure, find the free man'),
    (3, 'Defensive midfielder', 'Arrive to make 3v2 and drive the attack')
) AS v(so, role, job);

-- 63. pp.139-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'IPTETA - Building Up from the Back with Interplay in Specific Zones / Passing Out Within Position Specific Zones (6v6)', 'Circulate CBs and 6, then full back to winger',
    'Both centre backs and the 6 must all handle the ball before it moves to the full back, who then finds the winger; defenders receive in their own position and the 6 is the only player linking both zones. Versus a 4-1 press of five, the 6 must touch the ball before the attack goes on.',
    'Opponent presses the first line',
    'Positional build-up that moves the press across before releasing the wide pair.',
    NULL, 139, 140, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Receive in position with open body shape, back foot, head up'),
    (2, 'Defensive midfielder', 'Only player crossing between zones, must be involved'),
    (3, 'Full backs', 'Receive wide and pass on to the winger'),
    (4, 'Wingers', 'Wide target high up')
) AS v(so, role, job);

-- 64. pp.145-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'IPTETA - ''Expansive Football'': Utilising the Full Backs 8v6 / Full Backs in Wide Positions 8v8 (+1)', 'Full backs as the extra attacker',
    'With a numerical edge, full backs supply width and use overlapping or inside runs to receive behind the defence; when a CB carries into midfield and finds the full back, the nearest midfielder moves closer for a pass or one-two.',
    'Defender passes to the free full back',
    'Turn the spare man into width and penetration on the flank.',
    NULL, 145, 151, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'Hold width, overlap or underlap to get in behind'),
    (2, 'Centre backs', 'Dribble out of the first zone with support'),
    (3, 'Near midfielder', 'Move closer to the full back for a pass or one-two'),
    (4, 'Box runners', 'Time runs into the area for the cross')
) AS v(so, role, job);

-- 65. pp.146-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'IPTETA - Maintaining Possession in the Centre with Quick Break Attack and Finishing', 'Hold the centre, then diagonal to winger',
    'A small central group keeps the ball with one-touch support from the centre midfielders, then plays a long low ball out to a winger; all the others sprint forward to meet his cross.',
    'Several passes completed in the centre',
    'Draw opponents into the middle, then exploit the space wide fast.',
    NULL, 146, 146, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central players', 'Keep the ball in tight space'),
    (2, 'Centre midfielders', 'Support from outside, one touch'),
    (3, 'Winger', 'Receive the long diagonal and cross'),
    (4, 'Striker + far winger + CMs', 'Make forward runs to the cross')
) AS v(so, role, job);

-- 66. pp.147-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'IPTETA - ''Expansive Football'' 10v10 Eight Goal Game / Switching Play in a 7v7 with Side Zones / Numerical Advantage on the Flank 9v8', 'Switch to free side, overload flank',
    'When play is congested on one side or the centre is outnumbered, move the ball quickly to the free full back in the wide lane; on the ball-side flank have 2-3 players (FB, winger, plus a midfielder) to make 2v1 or 3v2 and reach the byline to cross, with 1-2 players kept on the far side.',
    'Opponent packed in the centre or on one side',
    'Exploit the free wide channel and create flank superiority for a high or low cross.',
    NULL, 147, 150, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'Stay wide and free; receive the switch'),
    (2, 'Ball-side winger', 'On receiving wide, dribble inside to open the lane for the overlapper'),
    (3, 'Joining midfielder', 'Make the 3rd man in the wide overload'),
    (4, 'Far-side full back + winger', 'Stay ready on the far side, never in line with each other'),
    (5, 'Strikers / box runners', 'Attack high or low crosses')
) AS v(so, role, job);

-- 67. pp.152-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'to_attack', 'IPTETA - Switching Play Across the Back Line with Quick Transition Attacking Play', 'Regain wide, break with neutrals widening',
    'As the opposing back line circulates against passive pressing, the ball is won when their full back finds the winger; the winning side attacks at once and the wide players go out to the flanks to make 8v7.',
    'Ball regained from the full back-winger link',
    'Turn the regain into an immediate wide-supported attack on goal.',
    NULL, 152, 153, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front players', 'Press passively, then break on the regain'),
    (2, 'Attacking midfielder (8)', 'First receiver after the regain, drives forward'),
    (3, 'Wingers', 'Move out wide immediately to support')
) AS v(so, role, job);

-- 68. pp.154-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'IPTETA - Midfielders and Striker Combining 3v2 / 3v3 / 3 Zone SSG', 'Attacking mid follows his pass to 9',
    'An AM plays into the striker, who lays it back to the other AM; the passer pushes up beside the 9 to make 2v2 or 3v2 against the centre backs, and attack fast.',
    'Pass into the striker''s feet',
    'Exploit the momentary overload around the striker before defenders recover.',
    NULL, 154, 156, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielders', 'Feed the 9, then one follows into the last zone'),
    (2, 'Striker', 'Lay off or turn, combine in 2v2'),
    (3, 'Centre backs + 6', 'Build up through the zones first')
) AS v(so, role, job);

-- 69. pp.160-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'to_attack', 'Possession Games for ''Expansive Football'' - Dynamic 8v3/10v8 / Counter Attacking Possession Game', 'Win it centrally, expand to wide team',
    'When the central trio (6, 8, 10) win the ball in the middle, they immediately pass out to teammates in their match positions around the hexagon, turning a 3-man scramble into 10v8 possession and then an attack the other way.',
    'Ball won in the central circle',
    'Escape pressure by expanding wide straight after the regain.',
    NULL, 160, 162, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder + attacking midfielders', 'Win the ball and play out at once'),
    (2, 'Back four + wingers + striker', 'Already positioned wide to receive'),
    (3, 'Whole team', 'Attack ''expansively'' through the goals at the sides')
) AS v(so, role, job);

-- 70. pp.161-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'to_defend', 'Possession Games for ''Expansive Football'' - Dynamic 8v3/10v8 / Counter Attacking Possession Game', 'Lose it: recover shape, protect goal',
    'If the team loses the ball after expanding, the opponent counters at the big goal; players react at once, retake their tactical shape and defend, then win it back and go again.',
    'Ball lost during the 10v8 phase',
    'Fast collective reaction to block the counter and regain.',
    NULL, 161, 162, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'Switch to defensive positions immediately'),
    (2, 'Nearest players', 'Press and tackle to win the ball back'),
    (3, 'Back line + goalkeeper', 'Defend the goal against the counter')
) AS v(so, role, job);

-- 71. pp.164-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Positional Games - 4v4 (+3) Wide / Through the Centre, 7v7 (+3), 6v6 (+4)', 'Open the pitch, mix outside and inside',
    'Possession games in fixed positions with neutrals in key roles (full backs, 6, GK, 9, wingers): the team on the ball spreads wide and deep, alternating superiority out wide with superiority through the central channels and also playing forwards back to front.',
    'Team gains possession',
    'Keep the ball by staying in position and using width, depth and the free neutral.',
    NULL, 164, 168, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Stay wide apart, start play forwards'),
    (2, 'Full backs / wingers', 'Give width, favoured outlet'),
    (3, 'Defensive midfielder', 'Central link between sides'),
    (4, 'Goalkeeper + striker', 'Give depth at each end')
) AS v(so, role, job);

-- 72. pp.165-167
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'out_of_possession', 'Positional Games - 4v4 (+3) Wide / Through the Centre, 7v7 (+3)', 'Close up the space when defending',
    'In the same positional games, the moment the team loses the ball it narrows and compacts to shut the space the attackers want to open.',
    'Ball lost',
    'Deny width and the central lanes by compacting the shape.',
    NULL, 165, 167, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'Close up and compact the space'),
    (2, 'Midfielders', 'Hold position and shrink gaps between lines')
) AS v(so, role, job);

-- 73. pp.171-174
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-positional-play-expansive-football-attacking-tactics-practices'), 'in_possession', 'Positional Games with Finishing - 4v4 (+3), 6v6 (+4), 9v9 Zonal', 'Connect defence, midfield, attack centrally',
    'Team in possession always plays towards goal: a CB dribbles into the central zone for a 4v3, the midfield three link to find the striker after a set number of passes, and the striker turns with wide support for a 3v1 or 3v2 finish.',
    'Central zone superiority after the CB carry',
    'Move the ball through the lines into the striker and finish with numbers.',
    NULL, 171, 174, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Dribble into midfield to add the extra man'),
    (2, 'Midfield three (6, 8, 10)', 'Circulate and connect with the 9'),
    (3, 'Striker', 'Receive, turn and enter the end zone'),
    (4, 'Wingers / wide support', 'Join to make 3v1 or 3v2 near goal')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1962-coaching-book-positional-play-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
