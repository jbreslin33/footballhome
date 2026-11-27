-- 1982 📚 Coaching book patterns: "Coaching Combination Play" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Coaching Combination Play',
    subtitle    = 'From Build Up to Finish',
    author      = 'Tag Lamche',
    team        = '4-3-3 academy model (12-16 year olds)',
    method_note = 'Possession earned by giving players a menu of rehearsed, coordinated movement patterns, built up from the keeper through four phases: build-up, consolidation, incision and finishing, in a 4-3-3 that also suits a 4-2-3-1. Each topic opens with a tactical picture then progressive practices: wide combinations (Classic 1/2/3, the winger as second striker, The X), the cut and drive inside, the open gate (set and spin, underlap), resets through the keeper, attacking runs and finishing combinations, locking down the box for crosses, counters, and set pieces including short corners. Patterns are the combinations and the team behaviours around them, in our words.'
WHERE slug = 'coaching-combination-play-from-build-up-to-finish';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish');

-- 1. pp.15-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Basic Shape & Movement Patterns', 'Back four open up at goal kick',
    'Keeper has the ball with time (goal kick or regain). The back line spreads to give him ground options.',
    'Keeper in possession with time and space',
    'Wide, staggered back line that gives the keeper short outlets and stretches the press.',
    NULL, 15, 15, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (5, 6)', 'Split to the corners of the 18-yard box'),
    (2, 'Full backs (2, 3)', 'Push high and wide, hug the touchline, ahead of the centre backs'),
    (3, 'All defenders', 'Half-turned body so ball and field ahead are both visible')
) AS v(so, role, job);

-- 2. pp.16-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Basic Shape & Movement Patterns', 'Midfield 3 rotating triangle',
    'The three central midfielders push up in front of the box and form a triangle, then rotate as a unit with curved runs to lose markers and receive side-on from keeper or centre back.',
    'Keeper looks up ready to play',
    'One midfielder arrives free in a pocket, side-on, able to turn and drive forward.',
    NULL, 16, 23, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (4)', 'Rotates into the space in front of the centre backs, open body'),
    (2, 'Shuttling midfielders (8, 10)', 'Arc runs across into space to receive side-on'),
    (3, 'Receiving midfielder', 'If pressed, one-touch bounce out to full back or winger'),
    (4, 'Keeper', 'Plays into whichever midfielder lost his marker, else to centre back')
) AS v(so, role, job);

-- 3. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Midfield Rotation: Coordinated Movement Patterns', 'Off-set triangle and spin away',
    'The midfield triangle is deliberately skewed toward the ball side so each rotating player gives a better support angle; if the pass is not on, the rotating player keeps moving and vacates the space for the next one.',
    'Pass into the rotating midfielder is not on',
    'Continuous rotation that keeps support angles and opens a pocket for a diagonal forward pass from the centre back.',
    NULL, 17, 17, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Rotating midfielder', 'Spin away from the pocket at the right distance when not found'),
    (2, 'Next midfielder', 'Arrive into the space just vacated'),
    (3, 'Centre back (6)', 'Play the diagonal forward pass into the free pocket')
) AS v(so, role, job);

-- 4. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'to_defend', 'Midfield Rotation: Coordinated Movement Patterns', 'Rotation keeps zone 14 secure',
    'Because one midfielder (No.4) always rotates centrally in front of the centre backs with an open body, the area in front of the box stays protected if a build-up pass is lost.',
    'Possession lost during build-up (misplaced pass)',
    'Compact central block right away, preventing a direct shot or through ball.',
    NULL, 17, 17, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (4)', 'Stays central screening the two centre backs'),
    (2, 'Other midfielders', 'Tuck in quickly toward the centre'),
    (3, 'Full backs', 'Drop back to give cover and balance')
) AS v(so, role, job);

-- 5. pp.18-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'The Transition from the Build Up to the Consolidation Phase', 'Rotation then bounce to the flank',
    'Centre back receives from the keeper and finds a rotating midfielder, who plays first time (''bounce'') out to the full back or winger; wide players then play diagonals into the forward-running No.10 or channel balls for the No.9''s diagonal run.',
    'Centre back receives and a midfielder arrives free',
    'Ball moved out of the box and over halfway into the wingers and striker.',
    NULL, 18, 19, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (6)', 'Play wide to full back or into the rotating midfielder'),
    (2, 'Rotating midfielder (8)', 'Bounce first time to full back or winger'),
    (3, 'Winger (7) / full back (2)', 'Diagonal pass to the advancing No.10 or channel ball'),
    (4, 'Striker (9)', 'Diagonal run into the channel'),
    (5, 'Keeper', 'Support angle behind the ball for a back pass')
) AS v(so, role, job);

-- 6. pp.20-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Passing Options of Rotating Midfield 3', 'Centre back drops to bait striker',
    'A centre back drops to the 18-yard line to receive; if the opposing striker presses him, space opens for the keeper to play straight into the dropping holding midfielder.',
    'Opposing striker steps out to press the dropping centre back',
    'Bypass the first presser and play out through the No.4.',
    NULL, 20, 20, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (5)', 'Drop to the box edge, drag the striker'),
    (2, 'Holding midfielder (4)', 'Drop into the vacated space half-turned'),
    (3, 'Full back (3)', 'If No.4 is pressed, run in front of his marker for a first-time pass, then drive or play to the running winger'),
    (4, 'Keeper', 'Available for a set-back pass, then team reloads its shape')
) AS v(so, role, job);

-- 7. pp.20-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'to_attack', 'When to ''Go Long''', 'Go long to winger against high press',
    'Opponents know the patterns, ignore decoys and press man-for-man including the keeper. Instead of a hopeful hoof, the keeper aims a precise long pass at the nearest winger who has found space between full back and winger.',
    'Opponent commits 2+ attackers high and man-marks, cutting the switch',
    'Eliminate several pressers, launch a quick counter, and discourage future high pressing.',
    NULL, 20, 49, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Keeper', 'Shape to go long and hit a precise lofted pass to the winger'),
    (2, 'Winger (7 or 11)', 'Anticipate, move into space between their full back and winger, open body'),
    (3, 'Full back (2)', 'Drop down the line and set back to keeper to trigger it'),
    (4, 'Advanced team-mates', 'Run into support so the team outnumbers around the landing spot')
) AS v(so, role, job);

-- 8. pp.23-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Exploring the Second Option Pass', 'Second option pass through a triangle',
    'Instead of always playing to the nearest teammate (first option), the passer looks past him to a more advanced player or one arriving beyond, threading the ball through a triangle of opponents.',
    'Further player is free and the lane is open',
    'Skip a line and gain ground quicker than a chain of short passes.',
    NULL, 23, 29, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Scan beyond nearest team-mate, ping it along the ground'),
    (2, 'Nearest player', 'Check away first, act as decoy if bypassed'),
    (3, 'Advanced player', 'Time the arc run to arrive in space, then play first time')
) AS v(so, role, job);

-- 9. pp.25-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Team Shape & Rotations When Playing Out from the Back', 'Triangles and diamonds team shape',
    'Whole team''s attacking shape for building from the back: consistent spacing, triangles and diamonds everywhere, width and depth, room for mobility centrally, bodies open relative to the ball.',
    'Team preparing to play out from the keeper',
    'Every ball carrier has several angled options even against a high press.',
    NULL, 25, 26, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four + keeper', 'Form base triangles with the midfield'),
    (2, 'Midfield three', 'Diamond links between defence and front three, rotate to lose markers'),
    (3, 'Wingers and striker', 'Hold width and depth to stretch the opponent')
) AS v(so, role, job);

-- 10. pp.28-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Position Specific Second Option Passing Combinations', 'Full back set, centre back splits',
    'Keeper plays to the full back, who checks away and sets back to the centre back; the centre back plays a penetrating second-option pass into the forward, who sets to a supporting midfielder, who releases the winger cutting inside to shoot.',
    'Full back closed after receiving from keeper',
    'Quick wall-pass chain that goes from goal kick to a shot; same pattern reused in the final third.',
    NULL, 28, 30, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Check away, receive, set back first time'),
    (2, 'Centre back', 'Penetrating pass into the forward'),
    (3, 'Forward / attacking midfielder', 'Lay off to the supporting midfielder'),
    (4, 'Central midfielder', 'Pass into the winger''s inside run'),
    (5, 'Winger', 'Cut inside to finish')
) AS v(so, role, job);

-- 11. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Creating Space to Play Through Pressure', 'Centre backs tuck in, midfield rotates',
    'At a goal kick the two centre backs stay narrow along the 18-yard line (called out ''tuck in'') and the midfield three are no wider than them, so space opens wide of the centre backs for a rotating midfielder to arrive into.',
    'Verbal or hand signal ''tuck in'' at goal kick / keeper regain',
    'Opponent second-guessing; keeper finds a midfielder in the wide channel to advance.',
    NULL, 33, 33, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (5, 6)', 'Stay narrow on the box line'),
    (2, 'Rotating midfielder (4)', 'Arc run into space wide of the centre back'),
    (3, 'Full back (3)', 'If midfielder is closed, receive the bounce, then blind-side run for a diagonal pass'),
    (4, 'Winger (11) / No.10 / striker', 'Runs in behind for the full back''s forward pass')
) AS v(so, role, job);

-- 12. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Creating Space to Play Through Pressure', 'Drop & Split',
    'Centre backs drop and split wide of the box while the keeper sits central on the six-yard box; full backs go high and wide, wingers stretch, holding midfielder drops with an arcing run and the two advanced midfielders split side-on. Works naturally for back-three teams too.',
    'Keeper looks up ready to play',
    'Up to five passing options for the keeper; draws pressing strikers in and leaves the opponent short centrally.',
    NULL, 34, 34, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (5, 6)', 'Drop back and split wide, side-on'),
    (2, 'Holding midfielder (4)', 'Arc into the gap to receive or bounce'),
    (3, 'Midfielders (8, 10)', 'Split into side-on positions to receive straight from keeper'),
    (4, 'Full backs', 'Push high and wide'),
    (5, 'Keeper', 'Pick the best of five options and follow up with support')
) AS v(so, role, job);

-- 13. pp.35-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Drop & Split Continued: Variation', 'Striker drops, winger runs in behind',
    'After Drop & Split gets the ball to a midfielder, the striker drops to drag his centre back away and the far winger makes a diagonal run inside; the midfielder plays a driven ball into the channel or a lofted ball over to the near winger (''passing through a triangle into a mobile attacker'').',
    'Midfielder receives free in midfield after the drop and split',
    'Quick incision behind a high-pressing back line.',
    NULL, 35, 35, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'Decoy drop to pull the centre back out'),
    (2, 'Far winger (11)', 'Diagonal run inside timed to beat offside'),
    (3, 'Midfielder (8)', 'Driven channel pass or lofted ball, disguised'),
    (4, 'Near winger (7)', 'Run in behind for the ball over the top')
) AS v(so, role, job);

-- 14. pp.37-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', '''The Cut'' Movement Pattern', '''The Cut'' basic pattern',
    'Two-man trigger at a goal kick: the nearest centre back calls ''Cut'' and runs diagonally across and in front of the pressing striker as a decoy, while the full back drops down the line to receive side-on from the keeper; midfield three rotate in support.',
    'Keeper looks up; centre back calls ''Cut''',
    'Full back freed to run forward or find the rotating midfielder in the pocket, who plays first time to the winger.',
    NULL, 37, 39, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (6)', 'Call ''Cut'', decoy run inside across the presser'),
    (2, 'Full back (2)', 'Drop down the line to receive side-on'),
    (3, 'Rotating midfielder (8)', 'Arc into the pocket for the full back''s pass, bounce wide'),
    (4, 'Winger (7)', 'Run down the flank to receive the first-time pass'),
    (5, 'Keeper', 'If centre back is untracked, play into his run instead')
) AS v(so, role, job);

-- 15. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', '''The Cut'' Variation', 'Centre back forward run off ''The Cut''',
    'Centre back tucks in early, then runs across his marker to receive from the keeper and drive forward, with a rotation of three between centre back, nearest midfielder and full back.',
    'Centre back gets in front of his marker and space opens',
    'Centre back carries forward and plays a diagonal, channel or lofted pass for running forwards.',
    NULL, 40, 40, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (6)', 'Run across marker, receive, drive forward'),
    (2, 'Nearest midfielder (4)', 'Cut across to clear space, finish in the wide spot'),
    (3, 'Full back (2)', 'Tuck inside into the centre-back spot for security'),
    (4, 'Midfielder (8)', 'Hold position as a second security player'),
    (5, 'Forwards (9, 10, 11)', 'Run onto channel or over-the-top passes')
) AS v(so, role, job);

-- 16. pp.42-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'The Role of the Keeper When Building Up Play', '''The Switch'' via the keeper',
    'When ''The Cut'' is closed down, the full back plays back to the keeper; the far centre back drops down the side of the box and the keeper switches to him, turning the failed attempt into a decoy that pulls the opponent onto one flank.',
    'Ball-side full back pressed after ''The Cut''',
    'Rapid attack down the opposite, under-populated weak side, treated like a counter.',
    NULL, 42, 45, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (2)', 'Play back to keeper, acts as the bait'),
    (2, 'Keeper', 'Open up with first touch and switch; if far centre back is marked, dribble across or loft to the far winger'),
    (3, 'Far centre back (5)', 'Drop down the box line side-on; play to far full back or bounce off No.4'),
    (4, 'Far full back (3)', 'Get out wide, or cut inside into the channel if his centre back is marked'),
    (5, 'Front three + No.10', 'Accelerate into channels and behind the back line')
) AS v(so, role, job);

-- 17. pp.44-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'The Goalkeeper''s Support Position When Switching Play', 'Keeper support wide of the post',
    'After passing out, the keeper moves to a safe area beside a goalpost on the ball side so he can take a back pass, then shifts to the other post when he switches play.',
    'Keeper has just released the ball',
    'A safe back-pass outlet at all times; a missed control isn''t in front of goal.',
    NULL, 44, 48, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Keeper', 'Move wide of the near post after passing, adjust after each switch'),
    (2, 'Centre backs / full backs', 'Drop down the line side-on, available to receive'),
    (3, 'Keeper under pressure', 'Take a positive first touch away from presser, recycle or clear wide')
) AS v(so, role, job);

-- 18. pp.51-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Chapter 2: The Incision Phase', 'Through a compact block via rotation',
    'In midfield against a compact, balanced opponent, the off-set midfield triangle rotates so a midfielder receives on the half-turn from the centre back, eliminating several opponents.',
    'Midfielder (8) arrives free on half turn after rotation',
    'Find gaps in the block: drive and combine, bounce to winger, or release an overlapping full back.',
    NULL, 51, 52, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (6)', 'Pass through the lines into the rotating midfielder'),
    (2, 'Midfielder (8)', 'Receive half-turned: dribble to draw defenders, or bounce to winger, or play wide to overlapping full back'),
    (3, 'Winger (7)', 'Receive the bounce or tuck in to open the flank'),
    (4, 'Full back', 'Overlap into the wide channel for return pass')
) AS v(so, role, job);

-- 19. pp.53-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Switching Play Using Rotations in Advanced Areas', 'Switch with 8-9-10 rotation',
    'Against a sitting, compact opponent the ball is switched along the back line while No.8, No.9 and No.10 rotate to lose markers; the far winger runs inside, the far full back overlaps into the space, and the striker drifts opposite to the ball onto the blind side of a centre back.',
    'Switch along the back line; near option blocked',
    'Gaps between midfield and defence and a free overlap or blind-side finish.',
    NULL, 53, 54, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line (3, 5, 6)', 'Circulate the ball across to the far side'),
    (2, 'No.10', 'Drop to support the left back'),
    (3, 'No.8', 'Time the arrival to receive side-on from centre back, spread wide'),
    (4, 'Winger (7)', 'Run inside to create room for the full back''s overlap'),
    (5, 'Full back (2)', 'Overlap into the space wide'),
    (6, 'Striker (9)', 'Drift away from the ball to blind side of centre back, attack crosses')
) AS v(so, role, job);

-- 20. pp.55-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Ch2 Incision Phase - switching play SSGs', 'Switch flank to trigger central rotations',
    'Team recycles the ball quickly from flank to flank; each switch is the cue for the three central attackers (8, 9, 10) to rotate and lose markers, and the attack must go through one of them. Only one full back advances at a time; wide players on both flanks are used before shooting.',
    'Ball switched to the far side (e.g. full back to holding midfielder)',
    'Open gaps in the opponent''s back line to play through, then attack the far-side space with inverted wingers.',
    NULL, 55, 56, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (4)', 'Receives from full back and switches play'),
    (2, 'Central attackers (8, 9, 10)', 'Rotate positions, check away twice before receiving, find gaps'),
    (3, 'Striker (9)', 'Moves opposite to the ball to get on defenders'' blind side'),
    (4, 'Full backs (2, 3)', 'Only one pushes forward at a time to keep balance'),
    (5, 'Far-side winger', 'Leaves the flank late to attack the far post')
) AS v(so, role, job);

-- 21. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Ch2 Incision Phase - switching play SSGs', 'Front two high and wide, centre opens',
    'In the attacking third the two forwards push high and wide, dragging centre backs apart; a midfielder joins to make a 3 v 2 in the centre.',
    'Ball played into the attacking third',
    'Create space for a midfielder to attack centrally and combine quickly to score.',
    NULL, 57, 57, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two forwards', 'Push high and wide to stretch the back line, lose markers, turn or lay back'),
    (2, 'Attacking midfielder', 'Runs into the vacated central space for a 3 v 2'),
    (3, 'Midfielders', 'Play into the forwards early, switch while watching forwards'' movement')
) AS v(so, role, job);

-- 22. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Ch2 Incision Phase - switching play SSGs', 'Forwards tuck in, flanks open',
    'Variation: the two forwards tuck inside in the attacking third, keeping the flanks clear; a midfielder or full back attacks the empty wide channel with an overlap or inside run.',
    'Team attacks the final third',
    'Create a 3 v 2 out wide and finish from the flank or via third-man runs.',
    NULL, 58, 58, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two forwards', 'Tuck in to pin centre backs and keep flanks empty'),
    (2, 'Midfielder / full back', 'Overlap into the wide space at the right moment'),
    (3, 'Midfielders', 'Play into forwards, then start overlaps as third man')
) AS v(so, role, job);

-- 23. pp.60-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Combinations in Wide Areas', '''The Classic 1'': winger set and spin',
    'After a switch with the midfield 3 rotating, the tightly marked right winger drops inside, bounces the ball one-touch to the 8 and spins round his marker; the half-turned 8 plays a 1-2 into space for the winger to attack. The right back reads the winger: if the winger goes wide he drives inside with the ball, if the winger goes inside he overlaps.',
    'Gap opens after switching play and the winger is tightly marked',
    'Winger gets in behind his marker on the flank to attack, cross or cut back.',
    NULL, 60, 60, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (7)', 'Checks away, drops inside, sets one-touch and spins in behind'),
    (2, 'Rotating midfielder (8)', 'Receives half-turned and returns the 1-2 into space'),
    (3, 'Right back (2)', 'Overlaps if winger goes inside, drives inside if winger goes wide'),
    (4, 'Weak-side wide players', 'Anticipate the switch: stay wide, drop down line or tuck in'),
    (5, 'Midfield 3 (4, 8, 10)', 'Rotate to lose markers as the ball is recycled')
) AS v(so, role, job);

-- 24. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Combinations in Wide Areas', '''The Classic 2'': third man through 10',
    'Same start as Classic 1 (switch, winger drops inside and sets to 8) but the half-turned 8 plays first time forward to the arriving 10 instead of back to the winger.',
    'Winger''s set pass to a half-turned 8 with 10 free ahead',
    'Third-man pass breaks the midfield line into the advanced central area.',
    NULL, 61, 61, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (7)', 'Times drop inside and sets to 8'),
    (2, 'Midfielder (8)', 'Rotates half-turned, plays first time to 10'),
    (3, 'Advanced midfielder (10)', 'Arrives in the gap to receive and attack the box')
) AS v(so, role, job);

-- 25. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Combinations in Wide Areas', '''The Classic 3'': set to overlapping full back',
    'Winger drops inside and sets back to the 8, who plays first time round the corner into the overlapping right back running down the channel.',
    'Winger drags his full back inside; right back already overlapping',
    'Full back receives high and wide to cross, cut back or attack goal.',
    NULL, 61, 61, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (7)', 'Drops inside, sets to 8, drags marker'),
    (2, 'Midfielder (8)', 'Half-turned first-time pass to the overlap'),
    (3, 'Right back (2)', 'Early well-timed overlap into the wide channel')
) AS v(so, role, job);

-- 26. pp.62-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Combinations in Wide Areas', 'Classic 3 variation: winger stays wide, back underlaps',
    'Winger hugs the touchline to stretch the back line; after the switch a diagonal pass (CB to 8) goes through the gap in the midfield line, the right back underlaps inside into the space. The 8 either plays forward to 10 or sets wide into the right back; the winger then makes a blind-side run inside towards the near post while 10 makes an arced side-on run between centre backs and 9 attacks the back post.',
    'Forward pass from right back / gap in opponent midfield line',
    'Several runners arrive in the box from different angles for a shot, cross or cut back.',
    NULL, 62, 62, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (7)', 'Stays wide, then blind-side diagonal run inside behind full back'),
    (2, 'Right back (2)', 'Underlaps inside into space when winger stays wide'),
    (3, 'Midfielder (8)', 'Turns to 10 if free, else sets wide to the right back'),
    (4, 'Advanced midfielder (10)', 'Arced run between two defenders, receives side-on, near-post run'),
    (5, 'Striker (9)', 'Blind side of centre back, attacks back post / rebounds')
) AS v(so, role, job);

-- 27. pp.63-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Combinations in Wide Areas', 'Far winger becomes ''second striker''',
    'In a 4-3-3 or 4-2-3-1, as play advances down one flank past halfway the opposite winger makes a strong diagonal run inside to become a second striker; the striker drifts wide to drag his centre back away; the ball-side full back drives forward and plays a long diagonal into the run. The run also clears the wide area for the far full back to overlap.',
    'Team advances into the attacking half on the opposite flank',
    'More bodies in the box and a direct diagonal to goal, or a 1 v 1 for the overlapping full back.',
    NULL, 63, 63, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Far-side winger (11)', 'Times diagonal run inside to beat offside as second striker'),
    (2, 'Striker (9)', 'Drifts wide to pull his marker and open the centre; plays killer pass to overlapping LB'),
    (3, 'Ball-side full back (2)', 'Drives forward, plays diagonal into the inside run'),
    (4, 'Far-side full back (3)', 'Overlaps into the space the winger vacated')
) AS v(so, role, job);

-- 28. pp.64-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Combinations in Wide Areas', '''The X'': two crossing diagonals',
    'Winger stays wide then drops down the line; centre back plays a diagonal to him, he sets back to the full back who has moved into support behind the ball, and the full back plays a second diagonal the other way into the 9 or 10 arriving after a double movement. The two diagonals cross, cutting out the opponent''s forward and midfield lines in about three first-time passes. Can also start deep from the build-up (CB wide from edge of box, FB plays into channel between opposing FB and CB).',
    'Winger tightly marked after dropping down the line',
    'Ball arrives in the advanced central area in front of the box; then 10 shoots, combines with the winger, or full back overlaps.',
    NULL, 64, 69, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (5)', 'First diagonal pass into the winger'),
    (2, 'Winger (11)', 'Stays wide, drops down line, sets back, then spins out wide for support'),
    (3, 'Full back (3)', 'Supports behind the ball, plays the second diagonal; may overlap after'),
    (4, 'Advanced midfielder (10) / striker (9)', 'Double movement to arrive in space for the final diagonal')
) AS v(so, role, job);

-- 29. pp.71-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Conditioned Games to Progress Training', 'Pressed midfielder 1-2, winger blind-side run',
    'Variation of Classic 2 (a third-man run): the rotating 8 receives from the centre back, and as pressure arrives plays a one-two with the right back; this cues the right winger to start a diagonal blind-side run behind the opposing left back, and the 8 slides a killer pass through the channel between left back and centre back.',
    'Midfielder pressed on receiving from the centre back',
    'Winger through on goal in the channel for the finishing phase.',
    NULL, 71, 73, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (5)', 'Starts with pass into rotating midfielder'),
    (2, 'Rotating midfielder (8)', 'Plays 1-2 under pressure, then killer pass'),
    (3, 'Right back (2)', 'Gives the wall pass'),
    (4, 'Right winger (7)', 'Well-timed diagonal blind-side run behind full back')
) AS v(so, role, job);

-- 30. pp.75-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', '''The Cut'' & ''The Open Gate'' Combinations', '''The Cut'': winger cuts in, striker wide',
    'Striker pulls out wide as the full back gets the ball; that is the winger''s cue to cut inside in front of his marker, calling for the ball, which opens the wide channel for a vertical pass from the full back to the striker running down it.',
    'Full back receives with striker pulling wide',
    'Force the opposing full back to choose between tracking the winger and holding; whoever is left free is used, striker then cuts in or crosses.',
    NULL, 75, 75, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'Pulls wide, then runs down the opened channel'),
    (2, 'Winger (11)', 'Cuts inside across his marker as decoy and option'),
    (3, 'Full back (3)', 'Vertical pass into the channel or to the cutting winger')
) AS v(so, role, job);

-- 31. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', '''The Cut'' & ''The Open Gate'' Combinations', '''The Cut'': ''Drive Inside & Provoke''',
    'Plan B when the opposing full back holds to screen the pass to the striker: the winger takes the pass from the full back inside and drives at the centre backs, with the 4 supporting inside to unsettle the opposing midfielder; he then provokes, passes to the arriving 10 or bounces to the striker who is now behind the defence.',
    'Opposing full back stays put instead of tracking the cut',
    'Full back is beaten either way; winger attacks central space with options either side.',
    NULL, 76, 76, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (11)', 'Receives inside and drives at the centre backs'),
    (2, 'Holding midfielder (4)', 'Supports inside, creates space for the cut'),
    (3, 'Advanced midfielder (10)', 'Moves in to occupy centre backs and receive'),
    (4, 'Striker (9)', 'From wide, attacks space behind the centre back')
) AS v(so, role, job);

-- 32. pp.77-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', '''The Cut'' & ''The Open Gate'' Combinations', '''The Open Gate'' with ''Set & Spin''',
    'Around the D against a compact defence, the striker drifts off his marker, takes a diagonal pass from the right back, sets it one-touch to the 10 while staying side-on, then peels away in the opposite direction for the return pass. Far winger runs inside as second striker, near winger pulls wide to stretch the line.',
    'Diagonal pass into the striker near the box',
    'If the centre back follows the peel, 10 shoots; if not, 10 returns to striker for a shot; with the inside winger it becomes a 3 v 1.',
    NULL, 77, 77, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'Sets one-touch, curls away side-on, signals for the return'),
    (2, 'Advanced midfielder (10)', 'Shoots first time or returns the pass'),
    (3, 'Far winger (11)', 'Runs inside as second striker'),
    (4, 'Near winger (7)', 'Pulls wide to stretch the back line'),
    (5, 'Right back (2)', 'Plays the diagonal into the striker')
) AS v(so, role, job);

-- 33. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', '''The Cut'' & ''The Open Gate'' Combinations', '''The Open Gate'' with underlap run',
    'Instead of setting, the striker makes a curved underlapping run across the front of the midfielder dribbling forward, moving opposite to the ball''s travel; he gets side-on to receive or drags the nearest centre back, opening the gate for the far winger driving in front of the other centre back.',
    'Midfielder carrying the ball forward centrally',
    'Isolate a centre back who must choose between holding and tracking; striker or winger through on goal.',
    NULL, 78, 78, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'Curved underlap run in front of the carrier, side-on to receive'),
    (2, 'Advancing midfielder (8)', 'Drives forward, picks striker or winger'),
    (3, 'Far winger (11)', 'Runs in front of the other centre back into the gap')
) AS v(so, role, job);

-- 34. pp.79-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Ch2 Incision Phase', 'Reset via keeper when game gets scrappy',
    'When pressure or loss of focus makes play scrappy, the team plays back to the goalkeeper rather than forcing it, reloads its build-up shape and spacing, then plays through the press again.',
    'Can''t play forward, link-up breaking down, shape lost',
    'Regain composure, positional discipline and control of possession.',
    NULL, 79, 79, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player under pressure', 'Plays back to the keeper instead of forcing the pass'),
    (2, 'Goalkeeper', 'Recycles to a free defender or midfielder'),
    (3, 'Outfield team', 'Restore build-up positions and spacing before going again')
) AS v(so, role, job);

-- 35. pp.84-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Key Attacking Runs & Combinations', 'Two-attacker runs: blind side, flat, dummy',
    'Near goal, two attackers coordinate: a blind-side run behind the defender, a flat run across the line timed to stay onside, or a dummy run where the runner signals and a decoy clears space; carrier plays a weighted pass into the run.',
    'Eye contact or signal between carrier and runner',
    'Get an attacker in behind a 2-man defence for a shot.',
    NULL, 84, 86, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Dribbles diagonally to draw marker, plays weighted pass into the run'),
    (2, 'Runner', 'Times blind-side, flat or dummy run and signals where he wants it'),
    (3, 'Both attackers', 'Follow up shots for secondary chances')
) AS v(so, role, job);

-- 36. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Key Attacking Runs & Combinations', '''Cross-over'' and ''take-over'' runs',
    'Cross-over: carrier dribbles diagonally, defenders shift across, partner runs the opposite way into the space and receives. Take-over: carrier dribbles diagonally and partner takes the ball off his foot going the other way, the original carrier carrying on his line as a decoy or receiver.',
    'Carrier''s strong diagonal dribble across the defence',
    'Shift defenders one way and attack the space they leave, especially around the box.',
    NULL, 85, 85, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Carrier', 'Diagonal dribble to drag defenders'),
    (2, 'Partner', 'Crosses behind or takes the ball over, attacks the opposite space')
) AS v(so, role, job);

-- 37. pp.87-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Key Attacking Runs & Combinations', 'Rotating ''drop'' and ''lateral'' runs',
    'Drop: one forward drops towards the ball drawing a defender, another runs in behind into the space. Lateral: one forward runs across to pull a defender away and a teammate rotates into the gap he leaves.',
    'Defender follows the decoy movement',
    'Selfless decoy runs create space for a timed run in behind and a killer pass.',
    NULL, 87, 87, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Decoy forward', 'Drops or runs across to drag a defender'),
    (2, 'Second forward', 'Reads it early and rotates into the created space'),
    (3, 'Passer', 'Weighted pass into the run, beat offside')
) AS v(so, role, job);

-- 38. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Key Attacking Runs & Combinations', 'Flat-pass underlap, diagonal-pass overlap',
    'Flat pass and under-lap: player passes square then runs diagonally between two opponents to receive the ball back up the line while the teammate moves the other way. Diagonal pass and overlap: forward diagonal pass, then curved overlap to get it back as the teammate moves opposite.',
    'Pass made, defenders'' attention on the receiver',
    'Passer arrives in an advanced position to score or the teammate is left free to finish.',
    NULL, 88, 88, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Passes then accelerates on the underlap or overlap'),
    (2, 'Receiver', 'Moves opposite to the runner, returns the ball into his path'),
    (3, 'Advanced attacker', 'Opens the gate by dragging markers away')
) AS v(so, role, job);

-- 39. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Key Attacking Runs & Combinations', 'Third-man run and classic one-two',
    'Third man: a square pass to a second player who plays first time into a third attacker running forward into space. One-two: pass to a teammate and get it straight back on the run.',
    'Defender drawn to the receiver',
    'Lose markers with a first-time combination and shoot.',
    NULL, 89, 89, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First passer', 'Plays the flat pass or wall pass, keeps running'),
    (2, 'Middle player', 'One-touch lay-off or return'),
    (3, 'Third man', 'Times forward run to arrive in space for the shot')
) AS v(so, role, job);

-- 40. pp.90-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Key Attacking Runs & Combinations', 'Back-heel take-over and ''nutmeg'' dummy',
    'Back-heel take-over: carrier runs forward drawing defenders, back-heels the opposite way to an overlapping teammate. Nutmeg dummy and spin: receiver lets a pass run through his legs to a teammate behind who has moved up, then spins away to join the attack.',
    'Defenders drawn to the carrier or receiver',
    'Disguise wrong-foots defenders and frees the overlapping/second player.',
    NULL, 90, 90, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Decoy player', 'Draws defenders, back-heels or dummies, then spins forward'),
    (2, 'Overlapping teammate', 'Runs onto the drag-back or dummied ball and drives forward')
) AS v(so, role, job);

-- 41. pp.91-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Key Attacking Runs & Combinations', 'Drop-set open gate; Cut with third man',
    'Drop-set and open the gate: pass to a player who drops back drawing a marker and sets to a third player, the furthest forward pulls wide, and the original passer overlaps into the space. Cut with third man: one player cuts inside to drag a marker and receive the first pass, while the most advanced player makes a double-movement third-man run for the second pass in behind.',
    'Marker follows the dropping or cutting player',
    'Elaborate 4 v 3 patterns with decoys open space for a scoring chance.',
    NULL, 91, 91, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping/cutting player', 'Decoy movement, sets or receives first pass'),
    (2, 'Most advanced attacker', 'Pulls wide or makes double-movement third-man run'),
    (3, 'Original passer', 'Overlaps into the opened space')
) AS v(so, role, job);

-- 42. pp.93-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Attacking Combinations to Finish', 'Combine off a setter to shoot',
    'Attacker combines with a setting teammate near the box: one-two and shoot, set and spin (forward pass, set back, curved run round to receive again), third-man run with a second setter, or set then a further one-two, finishing first time where possible.',
    'Setter checks away and opens body to receive',
    'Quick first-time combinations create a shot in front of goal.',
    NULL, 93, 96, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Setter (striker)', 'Checks away, half-turned, one-touch lay-off into the shooter''s path'),
    (2, 'Shooter', 'Signals, plays firm pass, runs on and finishes first time'),
    (3, 'Second setter', 'Curved run to receive the third pass in space')
) AS v(so, role, job);

-- 43. pp.97-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Attacking Combinations to Finish', 'Striker set-and-spin, wingers run in',
    'Central midfielders combine and wait for the moment to pass behind the defensive line; the striker sets and spins to open the gate for a winger making a blind-side or near-side run in front of his marker, who gets the killer pass. If defenders win it they play quickly to a target player.',
    'Midfielder on the ball with a run starting behind the line',
    'Three forwards coordinate runs to beat a back three and finish.',
    NULL, 97, 98, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Combine, time the pass behind the line'),
    (2, 'Striker (9)', 'Set and spin to open the gate'),
    (3, 'Wingers (7, 11)', 'Read early cues, start wide/overlapping runs to steal space behind')
) AS v(so, role, job);

-- 44. pp.99-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Attacking Combinations to Finish', '''Shoot on sight''',
    'Players shoot whenever they find half a yard of space and time, from near or far; if they cannot shoot themselves they set up a teammate for a first-time shot, and all follow up for rebounds.',
    'Half a yard of space within range',
    'More shots and secondary chances from spills.',
    NULL, 99, 100, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Shoots on sight, else sets a supporting player'),
    (2, 'Supporting attackers', 'Run onto weighted passes, follow up keeper spills')
) AS v(so, role, job);

-- 45. pp.102-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Crossing & Finishing', 'Lock down the box on crosses',
    'When a winger wins space to cross or cut back, five runs are triggered: striker to near post in line with the post, opposite winger in at the back post, attacking midfielder to the penalty spot for a cut back, a central midfielder holding at the D for knock-downs, and a full back supporting behind the winger. A ''3 second rule'': if an attacker has stood in a finishing spot 3 seconds without the ball, he moves or rotates with another attacker.',
    'Winger has won space to cross or cut back',
    'Fill every key finishing area so the winger has a target for low near-post, lofted back-post or cut-back ball, with security behind.',
    NULL, 102, 106, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (A)', 'Accelerates to near post, run ends roughly in line with post, one-touch finish'),
    (2, 'Opposite winger (B)', 'Drives in at the back post'),
    (3, 'Attacking midfielder (C)', 'Times arrival at the penalty spot for the cut back'),
    (4, 'Central midfielder (D)', 'Delays, sits outside box at the D for clearances and knock-downs'),
    (5, 'Full back (E)', 'Supports behind the winger as outlet and cover if dispossessed'),
    (6, 'Winger', 'Picks the best option: near post, back post or cut back')
) AS v(so, role, job);

-- 46. pp.107-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'to_attack', 'Counter Attacking Practices', 'Exploit overload before recovery',
    'Attacking team with a numerical advantage attacks at pace with set-backs and coordinated runs (drop-set, third man, cross-over, rotating lateral) before recovering defenders get back; defenders who win the ball counter-attack straight away.',
    'Overload (e.g. 3 v 1) with opponents still recovering; or ball regained',
    'Score quickly while the overload lasts; turn a regain straight into a counter.',
    NULL, 107, 108, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'Checks away, sets back or turns, drifts to pull a defender away'),
    (2, 'Attacking midfielders', 'Combine at pace with 1-3 touches to finish before recovery'),
    (3, 'Defenders who regain', 'Counter immediately (play through a gate/forward)')
) AS v(so, role, job);

-- 47. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'to_defend', 'Counter Attacking Practices', 'Centre back delays, midfielders recover',
    'Facing a 3 v 1 counter, the lone centre back delays the attack rather than diving in, buying time for the two holding midfielders who sprint back to recover defensive positions.',
    'Opponent attacks with an overload against a lone defender',
    'Slow the counter until recovering midfielders restore numbers.',
    NULL, 108, 108, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Delays, holds up the attack'),
    (2, 'Holding midfielders (DMs)', 'Sprint back to recover and engage opponents')
) AS v(so, role, job);

-- 48. pp.109-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'to_attack', 'Counter Attacking Practices - Attack v Defence 6 v 2 (+3 Recovering Players)', 'Strike fast while the overload lasts',
    'After a regain, six attackers including two wingers and a striker break against two centre backs while three midfielders sprint back to recover.',
    'Midfielder plays the first pass into a forward with recoverers still behind the ball',
    'Finish in one to three touches per player before the recovering defenders cancel the 6v2.',
    NULL, 109, 109, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'Checks away from his marker, takes it side-on or sets it back, drifts wide to drag a centre back away'),
    (2, 'Wingers', 'Sprint forward wide to stretch the two centre backs and arrive for crosses'),
    (3, 'Supporting midfielders', 'Use drop-set, third-man, crossover and rotating lateral runs at pace'),
    (4, 'Defending centre backs', 'Delay and hold up the attack so their recovering midfielders can get back'),
    (5, 'Recovering midfielders', 'Sprint back goal-side and engage the attackers; on a regain play out through a gate')
) AS v(so, role, job);

-- 49. pp.112-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Shooting Practices - Quick Combination Play to Finish with Third Man Run', 'Third-man run for first-time finish',
    'Near the box, a midfielder passes into a wide-ish attacker, takes it on and lays to a second attacker while curling his run toward goal; the third player slips it into his path.',
    'Second player sets the ball back to the third player as the runner arcs into the box',
    'Open a clear one-touch scoring chance for the runner.',
    NULL, 112, 112, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player A (runner)', 'Passes on and bends his run so he arrives facing goal for a first-time shot'),
    (2, 'Player B (setter)', 'Sets the ball back to C with one touch'),
    (3, 'Player C (third man)', 'Plays the through ball into A''s path in front of goal')
) AS v(so, role, job);

-- 50. pp.113-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Shooting Practices - Variation: Quick Combination Play to Finish with Overlapping Run', 'Overlap round the wall-pass to finish',
    'Attacker A passes to B and immediately overlaps him; B feeds a central player C who slides the ball into A arriving from the outside.',
    'A''s pass is the first step of his overlapping sprint',
    'Get an attacker running onto a return pass in the box with momentum.',
    NULL, 113, 113, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player A (overlapper)', 'Passes and accelerates round B, picks place or power on the shot'),
    (2, 'Player B', 'Receives and plays inside to C'),
    (3, 'Player C', 'Threads the ball into A''s overlapping run')
) AS v(so, role, job);

-- 51. pp.114-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Shooting Practices - Quick Combination Play to Finish with Set and Spin', 'Set and spin around the edge',
    'A plays a one-two with B; B then spins off his marker while A finds C, who slips the next pass into B''s arcing run for a shot.',
    'B sets the ball back to A then turns away',
    'Free the spinning player for a first-time shot at a good angle.',
    NULL, 114, 114, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player B', 'Sets the ball back, spins and arcs his run to shoot first time'),
    (2, 'Player A', 'Returns from the one-two to C'),
    (3, 'Player C', 'Plays the pass into B''s spin run')
) AS v(so, role, job);

-- 52. pp.117-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Supplementary Technical Training - Dribbling / Moves to Beat Opponents; Running With the Ball in a Directional 7 v 7 and 7 v 7 SSG', 'Run with the ball into space',
    'When there is open space ahead, the ball carrier drives forward at speed, sucking opponents in front and behind him, then beats a man or releases a teammate; others spread wide and deep and rotate to cover.',
    'Space available in front of the receiver, especially in advanced areas',
    'Commit defenders so a compact block is carved open for a teammate or a shot.',
    NULL, 117, 128, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Directional first touch forward, big touches into space, then a move to beat or a pass when drawn'),
    (2, 'Teammates ahead', 'Exploit the space vacated by defenders the run drags across'),
    (3, 'Deeper players (2-2-2 rotation)', 'Make compensatory movements to cover for whoever runs forward from deep'),
    (4, 'All players', 'Spread for width and depth so the runner has room')
) AS v(so, role, job);

-- 53. pp.117-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Supplementary Technical Training - Receiving; Directional First Touch + Controlled Passing; Exploring Opening Up to Receive', 'Check away and receive half-turned',
    'A marked receiver first moves away to drag his marker then comes short (go-to-show), lines up with the pass with an open, half-turned body and takes the first touch away from the pressing side.',
    'Pressure coming from one side as the ball travels to him',
    'Receive already facing forward and away from pressure so the next action is quick.',
    NULL, 117, 132, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'Scans before the ball, checks away then shows, opens up side-on and takes it into space away from the presser'),
    (2, 'Passer', 'Ground pass with pace, weighted to the receiver''s preferred foot, then presses or supports')
) AS v(so, role, job);

-- 54. pp.123-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Supplementary Technical Training - Moves to Beat Opponents in a 2 v 2 Hide & Seek / 2 v 3 Close Control', 'Hide then reappear for the beaten defender',
    'In a tight duel area the teammate of the ball carrier deliberately screens himself behind an opponent while the carrier shields and takes on his man.',
    'Ball carrier beats or unbalances his marker, opening a channel',
    'Keep possession when outnumbered by combining 1v1 skill with a late appearing pass option.',
    NULL, 123, 124, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Shields on the safe side, uses feints and drag-backs to beat his opponent'),
    (2, 'Teammate', 'Hides behind the second opponent, then moves into the channel the dribble opens')
) AS v(so, role, job);

-- 55. pp.133-143
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Passing & Possession Practices - 5 v 5 v 5 Three Zone Game; Playing Through the Thirds (Zonal / 6 v 3 / 8 v 4)', 'Play through the thirds zone by zone',
    'The team is split across horizontal zones; after a few passes in one zone it plays through or over the pressing middle line to teammates in the next zone, and must touch each zone before scoring.',
    'Two or three passes completed and a gap opens in the pressing line',
    'Progress up the pitch line by line with driven ground passes, using the local 2v1 in each zone.',
    NULL, 133, 143, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players in the ball zone', 'Use full width and depth, exchange quick short passes to shift the pressers'),
    (2, 'Players in the next zone', 'Stay mobile and keep adjusting to open a channel between opponents'),
    (3, 'Passer', 'Driven, well-weighted ground pass into the next zone; lofted when the lane is closed'),
    (4, 'Team that lost the ball', 'Presses straight away to win it back')
) AS v(so, role, job);

-- 56. pp.134-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Passing & Possession Practices - One / Two-Touch Technical Pass & Move (1)-(4); 6 (+4) v 4 Rotating Corner Players', 'Set-back and open a channel',
    'Players pass and follow the ball; central players set the ball back first time and immediately open up so a longer through or diagonal pass can go past them to the next player.',
    'A set-back pass from a central player',
    'Keep a rhythm of short-short-long passing where each pass becomes the first step of a support run.',
    NULL, 134, 138, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central setter', 'Lays the ball back first time, then moves to open a passing lane'),
    (2, 'Receiver of the set', 'Plays first time beyond the setter to the wide or far player'),
    (3, 'Passer', 'Follows his pass to a new support angle and signals the foot he wants it on'),
    (4, 'Off-ball players', 'Make decoy runs to open a channel for the through pass')
) AS v(so, role, job);

-- 57. pp.139-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Passing & Possession Practices - Advance the Play Through Pressure in a 2 (+8) v 4 Rondo', 'Bounce off the central player to cross',
    'Players around a central square need to move the ball from one side to the other, which counts only if it goes via a central teammate who is outnumbered by pressers.',
    'Central player checks away then shows between the defenders',
    'Use one-touch bounce passes through the middle to advance the play past pressure.',
    NULL, 139, 139, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central players', 'Two movements to get free, bounce the ball first time to a support player'),
    (2, 'Outside players', 'Pass quickly and move along the edge to give a good angle')
) AS v(so, role, job);

-- 58. pp.140-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Passing & Possession Practices - Switching Play Against High Intensity Pressure in a Possession Game with Target Players', 'Switch play away from the press',
    'Against an intense press the team spreads wide and deep, forms quick triangles and moves the ball from one corner target to the opposite one with driven ground or lofted passes.',
    'Pressure crowding the ball side',
    'Escape a high press by switching to the far, open side quickly.',
    NULL, 140, 140, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All players', 'Spread for width and depth, form triangles for support angles'),
    (2, 'Ball player', 'First-time or open-up two-touch pass, aware of near and far teammates'),
    (3, 'Target / far-side player', 'Holds the width to receive the switch; swaps roles with the passer')
) AS v(so, role, job);

-- 59. pp.141-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Passing & Possession Practices - Creating Space to Finish in a 4 v 4 (+5) Possession Practice', 'Shoot on sight, else combine',
    'In and around the box the team uses outside support players and mobility to drag markers; anyone with half a yard shoots, otherwise they combine into a striker who sets it back.',
    'Space and time to shoot, or a striker who can receive and set',
    'Create and take shooting chances quickly from anywhere in the area.',
    NULL, 141, 141, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'Checks away, receives, calls set-me and lays off for a shot'),
    (2, 'Midfielders', 'Pass into the striker and follow, shoot on sight from the set-back'),
    (3, 'Outside players', 'Provide width and depth to drag defenders apart')
) AS v(so, role, job);

-- 60. pp.144-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Passing & Possession Practices - Possession, Crossing & Finishing in a SSG with Side Zones', 'Release the winger and fill the box',
    'The team switches the ball quickly to a winger in the wide channel; a player from deep joins the two strikers so three attack the box against two defenders.',
    'Ball played into the winger',
    'Turn a wide release into a 3v2 or 4v2 in the box with key finishing runs.',
    NULL, 144, 144, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Takes two touches max, reads the runs and crosses driven, lofted or cut back'),
    (2, 'Strikers', 'Attack near post and far post, readjust if the cross is delayed'),
    (3, 'Arriving midfielder', 'Runs from deep to the penalty spot or the cut-back area'),
    (4, 'Far-side winger', 'Joins late at the far post')
) AS v(so, role, job);

-- 61. pp.146-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'set_piece', 'Set Pieces - Why Use Short Corners / Free Kicks?', 'Go short when they leave attackers up',
    'If the opponent leaves several attackers on the halfway line and the defence man-marks them, a hit-and-hope corner risks a counter; possession teams should play the corner short.',
    'Corner awarded with opponents leaving four attackers forward',
    'Keep the ball to craft a better chance and keep defensive balance for the recovery.',
    NULL, 146, 146, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest attackers', 'Offer themselves short to the corner taker'),
    (2, 'Corner taker', 'Avoids lumping it in when the box is even numbers and the counter is on'),
    (3, 'Back line', 'Stays balanced versus the opponents'' forwards')
) AS v(so, role, job);

-- 62. pp.147-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'set_piece', 'Set Pieces - Short Corner Routine: Sole Roll & Scoop', 'Sole roll and scoop corner',
    'Two takers stand over the ball; one rolls it with his sole and runs between the two pressers, the other scoops it over them into his path for a cut-back, near-post ball or lofted back-post ball.',
    'Two opponents come out to stop the short corner',
    'Beat the two pressers and deliver from a better angle while defenders are drawn out.',
    NULL, 147, 147, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.8 (taker)', 'Sole-rolls and runs between the pressers to receive the scoop'),
    (2, 'No.7 (taker)', 'Scoops the ball over the pressers into No.8''s run'),
    (3, 'No.10 and No.9', 'Near-post run and back-post run for the delivery'),
    (4, 'No.4', 'Arrives in the penalty spot / D area for a cut-back'),
    (5, 'No.2, No.3, No.5, No.6', 'Full back advanced to draw a defender, No.3 covers the D, centre backs stay back')
) AS v(so, role, job);

-- 63. pp.148-148
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'set_piece', 'Set Pieces - Short Corner Routine: Set & Spin', 'Set and spin short corner',
    'No.8 runs late toward the flag and is tracked; the taker passes to him, he sets it back and spins around or between his markers, and the taker chips the return into his spin run.',
    'No.8 tracked by one or two defenders as he comes short',
    'Use disguise to escape the markers and deliver from inside the box.',
    NULL, 148, 148, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.7 (taker)', 'Short pass, then chips the return into No.8''s run'),
    (2, 'No.8', 'Sets first time, spins and picks a cut-back, near-post or back-post option'),
    (3, 'Box attackers', 'Same runs as the sole-roll routine: near post, back post, penalty spot')
) AS v(so, role, job);

-- 64. pp.149-149
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'set_piece', 'Set Pieces - Short Corner Routine: One-Two Set & Shoot', 'One-two corner for edge shot',
    'No.8 comes short from the box edge, sets the ball back to the taker while No.4 runs inside as a decoy to drag his marker; No.10 arcs out of the cluster into the space and shoots first time from the edge.',
    'Taker receives the return pass from No.8',
    'Create a first-time shot from the edge of the area in space vacated by the decoy.',
    NULL, 149, 149, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.8', 'Times his run to come short and set it back'),
    (2, 'No.7 (taker)', 'Weighted pass into space for No.10'),
    (3, 'No.4', 'Decoy run inside to open a channel'),
    (4, 'No.10', 'Starts in the cluster, arcs his run late to shoot with power'),
    (5, 'No.2 and centre backs', 'Full back high to occupy a man, centre backs mark the lone striker')
) AS v(so, role, job);

-- 65. pp.150-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'set_piece', 'Set Pieces - Short Corner Routine: One-Two Set & Cross', 'One-two corner for short cross',
    'Variation: after the one-two, the taker plays into No.10''s arced run (rotating with No.4), who delivers a shorter diagonal cross from the box edge to the back post or drives it across the spot.',
    'No.10 free in the space after rotating with No.4',
    'A shorter, more accurate cross from closer to goal, confusing markers.',
    NULL, 150, 150, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'Arcs his run, crosses lofted to back post or drives along the ground'),
    (2, 'No.4', 'Rotates with No.10 to lose markers'),
    (3, 'Back-post attackers', 'Attack the back post for a header'),
    (4, 'Late runner', 'Times a run into space for a first-time shot')
) AS v(so, role, job);

-- 66. pp.151-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'set_piece', 'Set Pieces - Free Kick Routine on the Edge of the Box', 'Square free kick to arcing shooter',
    'A wide free kick by the 18-yard line: the group outside the box fakes an attack on a back-post cross and runs to drag markers, while a designated player arcs from the rear into space and the taker rolls the ball square for a first-time strike.',
    'Free kick taker runs up as if to cross high',
    'Strike on goal through space opened by decoys, with others following up rebounds.',
    NULL, 151, 151, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Taker', 'Disguises a cross then plays a weighted ground pass across the line of the box'),
    (2, 'Designated shooter', 'Starts at the back of the group, arcs in to strike first time'),
    (3, 'Cluster', 'Forward run toward the back post to pull markers away'),
    (4, 'Wide decoy', 'Runs inside to occupy another marker'),
    (5, 'All others', 'Follow up for secondary chances')
) AS v(so, role, job);

-- 67. pp.152-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'set_piece', 'Set Pieces - Free Kick Routine: Cross-Over Decoy', 'Cross-over decoy to split the wall',
    'Central free kick: A short-passes to C who stops it with his sole; A and B make crossing overlapping runs as if to receive, then D runs up feinting a pass to them and shoots through gaps they open in the wall.',
    'C traps the short pass and the decoy runs start',
    'Split the wall and shoot through the opened gap; decoys and the far-side trio follow up.',
    NULL, 152, 152, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player A and Player B', 'Simultaneous crossing decoy runs to split the wall'),
    (2, 'Player C', 'Traps the ball with the sole, then stays on the box edge to press after'),
    (3, 'Player D (shooter)', 'Feints a pass into the runs, then shoots for power through the gap'),
    (4, 'Far-side trio', 'Drive into the box for rebounds'),
    (5, 'Centre backs', 'Hold deep positions to cover any counter')
) AS v(so, role, job);

-- 68. pp.153-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'set_piece', 'Set Pieces - Free Kick Routine: Mix-Up Disguise', 'Mix-up disguise tap-pass free kick',
    'Two players stand with their backs to goal in front of the ball as if to set it for a third player''s run-up; instead A taps it sideways and B spins and curls it round the end of the wall.',
    'Player C breaks into his run-up',
    'Fool the wall and keeper and get a shot around the wall on the turn.',
    NULL, 153, 153, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players A and B', 'Hide the ball, check the wall, fake splitting apart or a mock argument'),
    (2, 'Player A', 'Slips the short sideways pass'),
    (3, 'Player B', 'Spins and strikes with a 2-3 step run round the wall'),
    (4, 'Player C', 'Fake run-up as if to strike'),
    (5, 'Cluster outside box', 'Attacks the back post as a decoy to hold markers')
) AS v(so, role, job);

-- 69. pp.155-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-combination-play-from-build-up-to-finish'), 'in_possession', 'Visual Awareness & Game Intelligence - What is Game Intelligence?', 'Read cues, avoid ball-watching',
    'Expert players anticipate by reading opponents'' body shape and posture, recognise unfolding patterns, use fewer but longer visual fixations, judge which options are most threatening, and stay calm under pressure.',
    'Any moment before receiving or defending',
    'Faster, better decisions from scanning the right players and spaces instead of the ball.',
    NULL, 155, 155, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Every player', 'Scan off-ball players and spaces, not just the ball'),
    (2, 'Player on the ball', 'Pick the option with the highest threat value, not the safest'),
    (3, 'Defender', 'Read the opponent''s hips and posture to anticipate his action')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1982-coaching-book-combination-play-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
