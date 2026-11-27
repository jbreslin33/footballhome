-- 1978 📚 Coaching book patterns: "Beat the Press With Single & Double Pivots" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Beat the Press With Single & Double Pivots',
    subtitle    = 'Build Up Play and Sessions from Flick, Klopp and Emery''s Tactics',
    author      = 'Athanasios Terzis',
    team        = 'Flick, Klopp and Emery sides',
    method_note = 'Companion to the Box Midfield book: building from the goalkeeper against high pressing with a single pivot (4-3-3) or a double pivot (4-2-3-1), from the tactics of Flick, Klopp and Emery. It first covers how opponents reshape to press (4-2-3-1, 4-3-3, 3-5-2 and 3-4-3 each into a 4-4-2 press; high versus ultra-aggressive; zonal, man, full-pitch man and hybrid marking), then a tactical-analysis chapter per press type for the single and double pivot, each followed by a training session (pivot turn-or-bounce decisions, link players, finding the free man). Patterns are the build-up behaviours and the pressing set-ups, in our words.'
WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k');

-- 1. pp.14-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Play from the Back Principles and Objectives', 'Build-up principles: break lines, safely',
    'Against the 4-4-2 high block (the most common pressing shape) the aim is to break as many lines as possible, read defensive shapes and their adjustments, adapt positions to the press, pass quickly and accurately and always offer the ball carrier safe and progressive options.',
    'Goal kick / GK possession against an organised high block',
    'Advance past the press safely and turn line-breaks into goal-scoring attacks.',
    '4-4-2', 14, 33, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'act as distributor with short, through, medium and long passes'),
    (2, 'Centre backs and pivots', 'scan before receiving, keep offering angles, carry when space opens'),
    (3, 'Supporting players', 'reposition after each pass to give multiple lanes')
) AS v(so, role, job);

-- 2. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up Play Factors: 3. Different Types of High Pressing', 'High pressing on the first receiver',
    'The press is triggered by the goalkeeper''s first pass to a centre back; because that receiver stands ahead of the keeper, the block only has to defend about 36 m of depth.',
    'GK plays first pass to a defender',
    'Press a smaller, more compact area and close the receiver down fast.',
    NULL, 16, 16, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest forward', 'jump the first receiver as the pass travels'),
    (2, 'Rest of the 4-4-2 block', 'stay compact in a roughly 36 m deep zone'),
    (3, 'Defensive line', 'hold height so lines stay close')
) AS v(so, role, job);

-- 3. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up Play Factors: 3. Different Types of High Pressing', 'Ultra-aggressive pressing up to the goalkeeper',
    'The press goes all the way onto the goalkeeper, stretching the block to about 44 m deep; since the keeper is pressed, one outfield opponent is always unmarked and more attackers sit between the lines.',
    'Ball with the goalkeeper',
    'Force rushed play from the keeper while managing the free man and staying compact enough to cover the gaps.',
    NULL, 17, 17, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'press the goalkeeper directly'),
    (2, 'Midfield and back lines', 'step up to shrink gaps despite the longer block'),
    (3, 'Whole team', 'decide who handles the guaranteed free outfield player')
) AS v(so, role, job);

-- 4. pp.18-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Play Factors: 4. Numerical Situation in the Low Area', 'Exploit lone forward with 3v1 at back',
    'When the opponent presses with one striker (e.g. 4-2-3-1 or 3-4-3 out of shape), the two centre backs plus keeper have a 3v1; if the striker cannot cover both centre backs they dictate tempo, and if he jumps one, the ball is shifted to the free weak-side centre back.',
    'Lone forward presses the centre back who got the first pass',
    'Switch to the free centre back in big space and step into midfield with little resistance.',
    NULL, 18, 20, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free centre back', 'receive in space, carry forward and pick a pass'),
    (2, 'Goalkeeper', 'circulate between centre backs, switch around the presser'),
    (3, 'Defensive midfielder / near CB as link', 'bounce the ball across when the direct switch is cut'),
    (4, 'Weak-side full back', 'offer the next pass after the switch')
) AS v(so, role, job);

-- 5. pp.20-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up Play Factors: 4. Numerical Situation in the Low Area', 'Shift to block the weak-side switch',
    'If a lone striker presses one centre back, the pressing side must stop the easy switch to the other one; otherwise the ball travels to a free defender in a large space.',
    'Forward presses the ball-side centre back',
    'Deny the switch so the press does not collapse after one pass.',
    NULL, 20, 20, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest midfielder', 'slide across to close the passing lane to the link player'),
    (2, 'Weak-side winger', 'pre-position to jump the far centre back when the switch comes'),
    (3, 'Forward', 'curve the press to cut the lateral pass')
) AS v(so, role, job);

-- 6. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up Play Factors: 4. Adjusting the 4-2-3-1 to a 4-4-2', '4-2-3-1 No10 steps up to 4-4-2 press',
    'A 4-2-3-1 pressing a back two plus keeper is 1v3 up front; the No10 pushes up beside the striker so the shape becomes 4-4-2 and both centre backs are pressed at once (2v3 with the keeper).',
    'Opponent builds from the back with two centre backs and GK',
    'Cut the centre backs'' time and space, force errors or long balls and win the ball high.',
    NULL, 21, 21, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (No10)', 'push high to press the second centre back'),
    (2, 'Forward (No9)', 'press the other centre back'),
    (3, 'Double pivot', 'hold behind to screen the midfield'),
    (4, 'Wide midfielders', 'squeeze the full backs, the key receivers')
) AS v(so, role, job);

-- 7. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up Play Factors: Adjusting the 4-3-3 to a 4-4-2', '4-3-3 advanced No8 joins striker',
    'A 4-3-3 has the same 1v3 problem up front; the more attacking of the two No8s (No10) moves up next to the striker while the other No8 drops beside the No6.',
    'Opponent builds through two centre backs and GK',
    'Create a 2v3 front press without losing security in front of the back four.',
    NULL, 22, 22, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking No8/No10', 'step up alongside the No9 to press a centre back'),
    (2, 'Forward (No9)', 'press the other centre back'),
    (3, 'Other No8', 'drop next to the No6 for defensive security')
) AS v(so, role, job);

-- 8. pp.23-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up Play Factors: 3-5-2 (A) and (B)', '3-5-2 shifts into 4-4-2 press',
    'A 3-5-2 already has two strikers on the centre backs, but opposing full backs and wingers find space beside the wing backs and three midfielders cannot cover the width; one wing back pushes onto the full back while the other drops, and the back three slide across into a back four.',
    'Ball goes wide to a full back, or build up starts vs a back four',
    'Keep the press compact, close the full backs and protect against long passes and quick switches.',
    NULL, 23, 24, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side wing back', 'push high to close the opposing full back'),
    (2, 'Far wing back', 'drop into a back-four slot to cover long balls and switches'),
    (3, 'Back three', 'shift across towards the ball side'),
    (4, 'Midfield three', 'shift across to block lanes and deny the far full back'),
    (5, 'Front two', 'stay on the two centre backs')
) AS v(so, role, job);

-- 9. pp.25-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up Play Factors: 3-4-3 (A) and (B)', '3-4-3 winger jumps the centre back',
    'A 3-4-3 covers the width well but its lone striker faces a 1v3; the winger pushes up to mark a centre back, the striker slides to the other, the far wing back drops to left back and the team shifts across into a 4-4-2.',
    'Opponent circulates between centre backs and GK',
    'Get a 2v3 high press that forces quicker decisions and restricts the centre backs and full backs.',
    NULL, 25, 26, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger', 'push up to press a centre back'),
    (2, 'Forward (No9)', 'shift to the other centre back'),
    (3, 'Far wing back', 'drop back into a full-back position for cover'),
    (4, 'Rest of team', 'shift across to the ball side')
) AS v(so, role, job);

-- 10. pp.27-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up Play Factors: 5A. Zonal Defending', 'Zonal pressing: zones move with ball',
    'In a zonal press (shown in 4-4-2) each player guards a zone of responsibility instead of a man, and the zones slide with the position of the ball.',
    'Ball moves',
    'Disrupt build up while keeping the defensive organisation intact.',
    NULL, 27, 27, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Each defender', 'own a zone and engage whoever enters it'),
    (2, 'Whole block', 'shift zones together with the ball')
) AS v(so, role, job);

-- 11. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up Play Factors: 5B1. Man Marking with Numerical Advantage at the Back (Option 1)', 'Man press, spare CB, GK free',
    'Two centre backs double the lone striker (2v1) and everyone else marks man for man; one winger presses a centre back while also watching the full back, leaving the keeper unmarked.',
    'Opponent starts build up from the back',
    'Shut down central direct play with 1v1s across the pitch, accepting a free goalkeeper as the outlet.',
    NULL, 28, 28, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two centre backs', '2v1 on the opposing striker'),
    (2, 'Pressing winger', 'press a centre back while screening the full back (covers two)'),
    (3, 'Forward', 'press the other centre back'),
    (4, 'Other outfield players', '1v1 on their direct opponent')
) AS v(so, role, job);

-- 12. pp.29-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up Play Factors: 5B2. Man Marking with Numerical Advantage at the Back (Option 2)', 'Wingers on CBs, striker on keeper',
    'Still 2v1 on the striker at the back, but both wingers press the two centre backs and the striker presses the goalkeeper, making a 3v3 ultra-aggressive press with more balance elsewhere.',
    'Ball with GK or centre backs',
    'Raise the chance of forcing errors or winning the ball high; weakness is that each winger has to cover two players.',
    NULL, 29, 29, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Both wingers', 'press a centre back each, screening the full back'),
    (2, 'Forward (No9)', 'press the goalkeeper'),
    (3, 'Two centre backs', 'keep the 2v1 on the striker'),
    (4, 'Midfielders', 'mark their direct opponents')
) AS v(so, role, job);

-- 13. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up Play Factors: 5C. Full Pitch Man Marking', 'Full pitch man marking, no spare',
    'Every outfield player is matched 1v1, including a 3v3 in the defensive line; one centre back steps into midfield to mark an opponent so the matching holds everywhere.',
    'Opponent builds from the back',
    'Deny time and space everywhere, accepting high risk if any marker is beaten because there is no cover.',
    NULL, 30, 30, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Every defender', 'track the direct opponent tightly'),
    (2, 'One centre back', 'step forward to mark a midfielder'),
    (3, 'Back line', 'hold 3v3 without a spare man')
) AS v(so, role, job);

-- 14. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up Play Factors: 5D. Zonal Defending and Man Marking (Hybrid)', 'Hybrid press: balanced man covers two',
    'Players mark opponents inside their zones; where the team is outnumbered (e.g. 2v3 in midfield) one player sits between two opponents instead of marking one.',
    'Local numerical disadvantage in a zone',
    'Stay compact and keep pressing while reacting to which opponent receives.',
    NULL, 31, 31, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (No6)', 'man mark one attacking midfielder'),
    (2, 'Other central midfielder (No8)', 'take a balanced spot between two opponents and jump whoever receives'),
    (3, 'All', 'communicate and readjust to opponent movement')
) AS v(so, role, job);

-- 15. pp.34-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Play Against High Pressing and Zonal Defending with a Single Pivot (4-3-3)', 'Single pivot: midfield occupies line-gaps',
    'Against a zonal 4-4-2 there are six spaces between the three red lines; the 4-3-3 midfielders (No6, No8, No10) take three of them, each placed equally far from the nearest opponents, and an attacking midfielder drifts to a freer central gap if one appears.',
    'GK or centre back has the ball',
    'Provide unmarked receivers between the lines for the keeper or defenders.',
    '4-4-2', 34, 35, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (No6)', 'stand centrally equidistant between the two forwards and two central mids'),
    (2, 'Attacking midfielders (No8, No10)', 'sit in gaps behind the second line, equidistant from markers'),
    (3, 'GK and centre backs', 'find one of the midfielders')
) AS v(so, role, job);

-- 16. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Options for Breaking the First and Second Pressing Lines with a Single Pivot (4-3-3)', 'GK steps up, prefers line-breaking pass',
    'Build up is not only short passes: the goalkeeper steps forward with the ball to shorten the pass, plays to the No6 if the forwards do not close the central lane, but prefers a lofted or through pass straight to an attacking midfielder because it breaks two lines.',
    'Midfielders in place and no pressure on the GK',
    'Remove as many defenders as possible with one pass.',
    '4-4-2', 36, 36, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'carry forward, then pass through or over the first line'),
    (2, 'Defensive midfielder (No6)', 'receive behind the first line'),
    (3, 'Attacking midfielders (No8, No10)', 'be the preferred target behind the second line')
) AS v(so, role, job);

-- 17. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Free Players Behind the Second Pressing Line (Marking vs Balanced Positioning)', 'Pin defenders to free the No8s',
    'Once the No6 turns past the first line, the wingers and striker stand so each red defender has two opponents to watch; full backs and centre backs must choose whom to mark, and because the front three are more dangerous the attacking midfielders usually end up free.',
    'Defensive midfielder receives and turns behind the first line',
    'Create a free receiver behind the second line.',
    '4-4-2', 37, 37, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (No7, No11)', 'hold positions that tie the full backs'),
    (2, 'Forward (No9)', 'tie both centre backs'),
    (3, 'Attacking midfielders (No8, No10)', 'sit between lines in the gap the defenders leave'),
    (4, 'Defensive midfielder (No6)', 'turn and look for the free man')
) AS v(so, role, job);

-- 18. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Exploiting Passing Lanes to Beat the Second Pressing Line', 'Striker as link when lanes blocked',
    'After the first line is broken, the players behind the second line spread into different lanes so the ball carrier always has at least two passes (triangles); if the direct lane to a No8 / No10 is blocked, the No9 drops into a free lane and sets it to them.',
    'No6 receives, direct pass to an attacking midfielder blocked',
    'Reach a free attacking midfielder who turns and breaks the whole second line.',
    '4-4-2', 38, 38, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (No9)', 'drop into a free lane as link player'),
    (2, 'Attacking midfielder (No8)', 'find space off the pressing midfielder'),
    (3, 'Attacking midfielder (No10)', 'adjust out of a defender''s cover shadow'),
    (4, 'Defensive midfielder (No6)', 'pick direct or third-man route')
) AS v(so, role, job);

-- 19. pp.39-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Drawing Press with a Pass and Exploit Gaps to Play in Between the Lines (single pivot)', 'Draw midfielder out, play behind him',
    'A pass to the No6 behind the first line pulls a second-line midfielder forward to press; the team reads who stepped and moves the ball quickly into the space behind him, either back to the GK and out to the centre back who finds the No10, or directly No6 to centre back.',
    'Second-line midfielder steps up to press the receiving No6',
    'Find the attacking midfielder in the vacated space, breaking two lines.',
    '4-4-2', 39, 39, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (No6)', 'bait the press, then return to GK or play to the CB'),
    (2, 'Goalkeeper', 'react fast and pass to the centre back'),
    (3, 'Centre back (No4)', 'pass into the No10 between the lines'),
    (4, 'Attacking midfielder (No10)', 'occupy the space left by the pressing midfielder'),
    (5, 'Other attacking midfielder (No8)', 'become target if the red No6 presses instead')
) AS v(so, role, job);

-- 20. pp.40-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Goalkeeper Draws Press to Create Space for Centre Backs (4-3-3)', 'GK dribbles between forwards, CB drives',
    'The goalkeeper carries the ball between the two opposing forwards, who narrow to block the central lane; this frees a centre back wide, who receives, must drive forward quickly and passes to an attacking midfielder positioned in the lane between the full back and centre back.',
    'The two forwards narrow onto the dribbling goalkeeper',
    'Break two pressing lines and remove six opponents with a pass to the No8.',
    '4-4-2', 40, 41, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'dribble between the forwards to pull them inside'),
    (2, 'Centre back (No5)', 'receive wide, drive forward, pass firmly before midfield shifts'),
    (3, 'Attacking midfielder (No8)', 'target player in the lane between full back and centre back, causing marking doubt'),
    (4, 'Left back (No3)', 'push forward to form a triangle'),
    (5, 'Forward (No9)', 'stay high if lane open, else drop as link for a second triangle / diamond')
) AS v(so, role, job);

-- 21. pp.42-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Opposing Centre Back Moves Forward to Mark the Attacking Midfielder', 'Defender steps out, ball in behind',
    'If a red defender jumps forward to mark the attacking midfielder between the lines, he leaves space in behind; the centre back plays a long aerial pass for the striker''s run, or if the full back stepped, the winger runs in behind instead.',
    'Opposing centre back or full back steps up onto the No8',
    'Break all three pressing lines with one pass and bypass every outfield defender.',
    '4-4-2', 42, 42, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (No5)', 'long aerial pass into the space behind'),
    (2, 'Forward (No9)', 'run into the space the stepping centre back left'),
    (3, 'Winger (No11)', 'run behind if the full back is the one who stepped'),
    (4, 'Attacking midfielder (No8)', 'drag the defender out')
) AS v(so, role, job);

-- 22. pp.43-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Centre Back''s Options when the Opposing Winger Narrows the Through Passing Lane', 'Narrowed lane: go wide to full back',
    'When the opposing No6 and wide midfielder shift in time to close the through lane to the No8, the centre back passes to his full back, who has room on the flank; the striker drops into a free lane to link to the No8 or No10.',
    'Opposing wide midfielder tucks in to block the pass into the No8',
    'A pass wide to the full back still breaks the second line and removes six opponents.',
    '4-4-2', 43, 43, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (No5)', 'switch target to the full back'),
    (2, 'Full back (No3)', 'receive wide in the space the winger vacated and move forward'),
    (3, 'Forward (No9)', 'drop into a lane as link player'),
    (4, 'Attacking midfielders (No8, No10)', 'stay free between the lines as final targets')
) AS v(so, role, job);

-- 23. pp.44-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Playing Against a Compact Central Block Leaves Space Out Wide (4-3-3)', 'Compact block: GK long to flank',
    'When the opponent''s wide players tuck in to compact the centre, space opens on both flanks; the goalkeeper plays long to the winger or full back, who turns and plays or acts as link back inside, while the midfielders stay between lines and opponents to receive from the wide man.',
    'Opposing wide players shift inside for compactness',
    'Bypass the press via the flank and bring the ball back into central areas behind the lines.',
    '4-4-2', 44, 45, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'long pass to the free winger or full back'),
    (2, 'Winger (No7) / full back (No2)', 'receive wide, turn and play forward or link inside'),
    (3, 'Midfielders (No6, No10)', 'hold free positions between lines to receive from the wide player')
) AS v(so, role, job);

-- 24. pp.47-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Training Sessions 1 and 2: Passing Decisions / Breaking Lines Based on Opponent Reactions', 'Pivot turn-or-bounce decision',
    'The pivot receiving from the keeper behind the first line scans and reads the nearest midfielder: if he holds, receive on the half-turn and play forward (with forward / attacking midfielder in a triangle or diamond); if he presses, pass back to the GK or a centre back and switch quickly into the space behind the presser to the attacking midfielder.',
    'Nearest opposing central midfielder holds or presses the pivot',
    'Make the right quick decision so the ball reaches the attacking midfielder behind the second line.',
    NULL, 47, 64, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (pivot)', 'scan before receiving, turn if free, bounce back if pressed'),
    (2, 'Goalkeeper / centre backs', 'offer the return pass and switch quickly'),
    (3, 'Attacking midfielders', 'occupy space behind the presser and receive'),
    (4, 'Forward', 'link player, set back or run behind to score')
) AS v(so, role, job);

-- 25. pp.51-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Training Session 1: Break Lines Through Turning, Recycling the Ball, or Dribbling Forward 3 Zone Game', 'Read press: turn, recycle or dribble',
    'In an 11v11 conditioned game the blues must read the reds'' defensive actions and choose to turn, recycle the ball or dribble into space, aiming to find an attacking midfielder behind the second line, including when the GK dribbles forward to free the centre backs.',
    'Opponent defensive reaction to each pass',
    'Find the No8 or No10 behind the second line and then progress past the third line to score.',
    NULL, 51, 52, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'dribble forward to draw forwards and free the centre backs'),
    (2, 'Centre backs', 'receive wide and choose AM directly or via link players'),
    (3, 'Attacking midfielders (No8, No10)', 'target players behind the second line'),
    (4, 'Forward (No9)', 'diagonal run in behind once AM receives')
) AS v(so, role, job);

-- 26. pp.54-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Play from the Back Principles and Objectives with a Double Pivot (4-2-3-1)', 'Double pivot: No10 roams across lanes',
    'A 4-2-3-1 gives the keeper two central options behind the first line but only four players beyond the second line, so the No10 slides horizontally across left, central and right channels; if he stays in the striker''s lane the pivot''s forward options are narrow, so he moves into a different lane, giving two distinct passes.',
    'A defensive midfielder receives and turns, or a presser blocks the lane to the forward',
    'Create a free player between the lines and keep passing variety and tempo.',
    '4-4-2', 54, 57, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (No10)', 'move across channels, leave the striker''s lane to open a second option'),
    (2, 'Forward (No9)', 'hold a separate lane as second target / link'),
    (3, 'Defensive midfielder on the ball', 'pick whichever lane the presser leaves open')
) AS v(so, role, job);

-- 27. pp.55-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Play Against High Pressing and Zonal Defending with a Double Pivot (4-2-3-1)', 'Staggered pivots, GK carries forward',
    'With a double pivot three of the six between-line spaces are occupied; the goalkeeper steps forward to shorten passes, one pivot sits centrally between the two forwards and central midfielders and the other drifts wider between the wide and central midfielder, while the No10 finds the freest gap.',
    'GK in possession versus a 4-4-2 zonal high press',
    'Break the first line via a pivot, or two lines with an aerial pass to the No10 who turns.',
    '4-4-2', 55, 56, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'dribble forward, then pass to a pivot or lob to the No10'),
    (2, 'Central pivot (No6)', 'stand between the two forwards and central mids'),
    (3, 'Wide pivot (No8)', 'shift wider between opposing wide and central midfielder'),
    (4, 'Attacking midfielder (No10)', 'find the most free space between lines and opponents')
) AS v(so, role, job);

-- 28. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Play on Side and Moving the Ball to the Free Attacking Midfielder Behind the Second Pressing Line', 'Winger inside, full back up: dilemma',
    'When the ball goes to the wide-side pivot and the No10 is far away, the winger moves inside between the lines while the full back advances in sync, so the opposing full back must either follow the winger (freeing the full back) or hold (freeing the winger).',
    'Ball played to the pivot on the side away from the No10',
    'Get a free receiver behind the second line who turns and plays in behind the defence.',
    '4-4-2', 58, 58, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (No11)', 'move inside into the half-space behind the second line'),
    (2, 'Full back (No3)', 'advance wide at the same time'),
    (3, 'Defensive midfielder (No8)', 'use the triangle, find whichever man is free'),
    (4, 'Forward / far winger', 'make runs in behind for the next pass')
) AS v(so, role, job);

-- 29. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Drawing Press from Midfielder to Exploit Space Created Between the Lines Behind (double pivot)', 'Double pivot: draw midfielder, find No10',
    'The goalkeeper plays through the forwards to a pivot facing his own goal, which pulls a central midfielder forward; the ball goes back to the GK and out to the centre back who finds the No10 in the vacated space, or quicker and riskier via the other pivot.',
    'Opposing central midfielder steps up to press the pivot',
    'Reach the No10 in the space behind the pressing midfielder before the block resets.',
    '4-4-2', 59, 59, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (No6)', 'receive with back to goal, scan, bait the press'),
    (2, 'Goalkeeper', 'receive the bounce and play the centre back'),
    (3, 'Centre back (No4)', 'pass straight into the No10'),
    (4, 'Other pivot (No8)', 'quick alternative route to the No10'),
    (5, 'Attacking midfielder (No10)', 'occupy the gap; if the red No6 is pulled out, go behind him')
) AS v(so, role, job);

-- 30. pp.60-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Goalkeeper Draws Press to Create Space Wide (double pivot)', 'GK carry frees CBs and wide lanes',
    'The goalkeeper drives between the two forwards who shift inside, opening a lane for a centre back or pivot; full backs push forward and a winger moves inside so the opposing full back must choose whom to follow, giving the receiver a triangle of options.',
    'Two forwards collapse centrally onto the dribbling GK',
    'Find a free player between the lines; a pass to the inside winger breaks two lines and removes six opponents.',
    '4-4-2', 60, 60, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'dribble forward between the forwards'),
    (2, 'Centre back (No4/No5)', 'receive in the space wide of the collapsed first line'),
    (3, 'Full backs (No2, No3)', 'push forward to stretch the wide midfielders'),
    (4, 'Winger (No11 or No7)', 'move inside unless the No10 already sits in that lane'),
    (5, 'Defensive midfielder (No8)', 'alternative receiver depending on which lane opens')
) AS v(so, role, job);

-- 31. pp.65-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Training Session 2: Break Lines vs High Press Zonal Defending with a Double Pivot', 'Pivot reads nearest presser: turn or pass',
    'A defensive midfielder takes the GK''s pass behind the first pressing line while a 4-2 block waits; he must check whether the closest opposing midfielder jumps at him.',
    'First pass from GK to the pivot inside the zone',
    'Turn and break the second line when unpressed, or bounce out and play beyond the pressing midfielder when he jumps.',
    NULL, 65, 67, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'scan before receiving, turn if free, play first time if pressed'),
    (2, 'Attacking midfielder / strong-side winger', 'find the free pocket behind the second pressing line'),
    (3, 'Centre backs + GK', 'circulate to set the pass and recycle if the lane closes')
) AS v(so, role, job);

-- 32. pp.66-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Training Session 2: Break Lines vs High Press Zonal Defending with a Double Pivot', 'GK dribbles in to free the centre back',
    'The goalkeeper carries the ball forward so the opposing forwards narrow to shut the central lane, which leaves a centre back with space to receive and step up.',
    'Forwards squeeze inward toward the dribbling GK',
    'Centre back gets the ball in space, reads the midfielders and finds the winger as link to the attacking midfielder.',
    NULL, 66, 67, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'dribble forward to attract the front two, pass wide to the freed CB'),
    (2, 'Centre back (No.4/No.5)', 'receive, carry, read whether the near midfielder or winger shifts'),
    (3, 'Full back', 'push up as support/option'),
    (4, 'Winger', 'act as link player to the attacking midfielder between the lines')
) AS v(so, role, job);

-- 33. pp.69-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Goalkeeper''s Passing Over Pressing Lines', 'GK passes over the second pressing line',
    'Instead of short build up under pressure, the keeper plays straight to a player stationed behind the opposing midfield line, skipping their press in one pass.',
    'Opponent presses high with forwards and midfield line',
    'Progress quickly while avoiding risky short passes near own goal.',
    NULL, 69, 69, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver between the lines', 'stand between lines and opponents, receive on the half-turn after scanning'),
    (2, 'Nearby teammates', 'position to give defenders marking dilemmas and stretch their back line'),
    (3, 'Wingers', 'stay as wide as possible so the opposing full backs must choose who to track'),
    (4, 'Forward', 'sit high between the two centre backs to pin them')
) AS v(so, role, job);

-- 34. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Goalkeeper''s Passing Over Pressing Lines', 'AM free when full back sits in between',
    'The GK steps up and lofts the ball to the attacking midfielder in space behind the midfield line; the opposing full back is stuck covering both the AM and the winger and does not step out.',
    'Full back hesitates between the AM and the winger',
    'AM turns unmarked and slides a through ball behind the defence for a runner.',
    '4-4-2', 70, 70, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'carry forward to shorten distance, aerial pass to the AM'),
    (2, 'Left attacking midfielder (No.8)', 'find space between the lines, turn, play in behind'),
    (3, 'Left winger (No.11)', 'hold width to freeze the full back, run in behind'),
    (4, 'Forward (No.9)', 'alternative runner behind the line')
) AS v(so, role, job);

-- 35. pp.71-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Goalkeeper''s Passing Over Pressing Lines', 'First-time ball behind jumping full back',
    'When the opposing full back steps forward to stop the attacking midfielder turning, space opens behind him on the flank.',
    'Full back jumps to press the AM receiving the GK''s pass',
    'AM flicks or heads first time into the vacated space for the winger, bypassing the press.',
    '4-4-2', 71, 71, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (No.8)', 'scan or be told, play first-time pass/header into space behind'),
    (2, 'Winger (No.11)', 'time a run in behind the stepping full back'),
    (3, 'Forward (No.9) / winger', 'communicate the full back''s approach to the AM')
) AS v(so, role, job);

-- 36. pp.72-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Goalkeeper''s Passing Over Pressing Lines', 'Flick behind the stepping centre back',
    'An opposing centre back leaves the line to press the attacking midfielder receiving the GK''s long pass, opening a hole in the middle of their back four. Shown for the single pivot (No.8) and the double pivot (No.10).',
    'Centre back steps out to press the receiver',
    'First-time pass/header into the central gap for the striker to run onto and drive at goal.',
    '4-4-2', 72, 73, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (No.8 or No.10)', 'first-time pass or header into the gap'),
    (2, 'Forward (No.9)', 'stay between the two centre backs, attack the space when one steps'),
    (3, 'Winger / forward', 'call the centre back''s movement to the receiver'),
    (4, 'Goalkeeper', 'deliver accurate aerial pass to the AM')
) AS v(so, role, job);

-- 37. pp.75-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Training Session 3: Goalkeeper''s Passing Over Pressing Lines', 'Receiver decides: hold-and-turn or first time',
    'Practices from passing patterns to an 11v11 game drill the AM receiving the keeper''s long pass in a target zone behind the second line, with a nearby defender who may hold or press.',
    'Ball in flight from GK; defender holds position or steps up',
    'If the defender holds, receive, turn and play in behind; if he presses, play first time into the space he left for a wide or central runner.',
    NULL, 75, 81, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'hit target zones accurately once the back players free him'),
    (2, 'Attacking midfielder(s)', 'scan for pressure before the ball arrives, decide turn or first-time'),
    (3, 'Wingers / forward', 'run into the space the stepping defender vacates and finish'),
    (4, 'Back players', 'circulate until the GK can play forward')
) AS v(so, role, job);

-- 38. pp.83-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Strong Side Advantage vs High Press Zonal Defending', 'Extra player in the first build-up zone',
    'With a 4-3-3 against a 4-4-2 high press, the possession team has 7 outfield players plus GK against 6 in its defensive and midfield thirds, and still 7v6 outfield once the GK plays out.',
    'Opponent starts pressing on the GK''s first pass',
    'Use the spare outfield player as a reliable outlet to progress under pressure.',
    '4-4-2', 83, 83, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'counts as extra man to start the build up'),
    (2, 'Back four + midfield three', 'spread out so the spare man is always findable'),
    (3, 'Free player', 'offer the outlet to progress')
) AS v(so, role, job);

-- 39. pp.84-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Strong Side Advantage vs High Press Zonal Defending', 'Pivot slides across for a 4v3',
    'With a single pivot there is 3v3 on each side at the start; as the GK passes to a centre back and the opposing forward presses, the No.6 shifts to that side and makes 4v3 around the ball.',
    'GK passes to a centre back and a forward presses him',
    'Free player (No.6 or No.8) receives directly or through the full back as link, bypassing the press on the strong side.',
    '4-4-2', 84, 85, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (No.6)', 'shift quickly toward the ball side to create the overload'),
    (2, 'Attacking midfielder (No.8)', 'keep good distance from No.6 so the opposing central midfielder cannot cover both'),
    (3, 'Full back (No.3)', 'link player to bounce the ball to the free midfielder'),
    (4, 'Centre back (No.5)', 'read and find the free player')
) AS v(so, role, job);

-- 40. pp.86-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Strong Side Advantage vs High Press Zonal Defending', 'AM drifts early to the strong side',
    'In the double pivot the No.10 starts central and could be screened, so he slides wide before the GK''s pass; No.8 drops while No.10 stays higher, keeping vertical distance, to make 4v3 near the ball.',
    'GK about to pass to the centre back; forward shifts to press',
    'Opposing midfielder can mark only one of No.8/No.10, so the other is free; if a centre back steps up to No.10, the CB plays long into the space behind for the No.9.',
    '4-4-2', 86, 87, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (No.10)', 'move to strong side early, stay higher, become the free player'),
    (2, 'Defensive midfielder (No.8)', 'drop deeper to stretch the opposing midfielder'),
    (3, 'Full back / winger', 'link players to reach No.10'),
    (4, 'Centre back (No.5)', 'long aerial ball behind if an opposing CB steps out'),
    (5, 'Forward (No.9)', 'run into space behind the stepping centre back')
) AS v(so, role, job);

-- 41. pp.89-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Training Session 4: Strong Side Advantage vs High Press Zonal Defending', 'Midfielder joins to overload and find free man',
    'Rondos, a 3-team game, split-pitch games and an 11v11 drill: just before the first pass a midfielder (No.6 in 4-3-3, No.10 in 4-2-3-1) enters each half to make 4v3 around the ball; nearest defender must press.',
    'Nearest defender steps to press after the first pass',
    'Assess options fast, use a link player if needed, get the ball to the free player and attack (goal after a strong-side overload counts double).',
    NULL, 89, 94, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Joining midfielder', 'arrive in the ball area to make the overload'),
    (2, 'Ball carrier', 'identify the free player quickly'),
    (3, 'Link player', 'bounce the ball to the free player when the direct lane is shut'),
    (4, 'Supporting players', 'keep diamond-shaped passing lanes and high tempo')
) AS v(so, role, job);

-- 42. pp.96-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Strong Side Equality vs High Press Zonal Defending', 'Strong-side 4v4 means weak-side 3v2',
    'The opponent shifts hard after the GK''s first pass and matches numbers on the strong side (forward closes the CB, central midfielder tracks the No.6), producing 4v4 there.',
    'Pressing team achieves equality around the ball',
    'Recognise that the far side now has a 3v2 with space for the weak-side full back and winger.',
    '4-4-2', 96, 96, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (No.5)', 'recognise equality near the ball'),
    (2, 'Weak-side full back (No.2)', 'hold space on the far side'),
    (3, 'Weak-side winger (No.7)', 'stay wide and high to exploit the 3v2')
) AS v(so, role, job);

-- 43. pp.97-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Strong Side Equality vs High Press Zonal Defending', 'Reset through GK to switch',
    'When progression through the strong side is blocked, players there first look for a teammate who can switch directly; if none, they keep the ball and recycle to the closest free player, often the keeper.',
    'No forward option on the strong side under equal numbers',
    'GK''s switch takes out six pressers and creates a 4v4 attack in an advanced area on the weak side.',
    '4-4-2', 97, 97, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side players', 'keep possession, look for a direct switch first'),
    (2, 'Goalkeeper', 'free receiver who switches long to the far side'),
    (3, 'Weak-side full back (No.2) + winger (No.7)', 'receive and attack the space')
) AS v(so, role, job);

-- 44. pp.98-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Strong Side Equality vs High Press Zonal Defending', 'CB long ball with second-ball support',
    'Under pressure with equal numbers, a centre back plays long to a forward or winger with strong hold-up play, after the AM drops to drag his marker away.',
    'Centre back pressed, AM''s drop pulls the opposing midfielder out',
    'Target wins the first ball unmarked and nearby players arrive at once to win the second ball; centre backs push up to leave the opposing forwards offside.',
    '4-4-2', 98, 98, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (No.5)', 'aerial pass to winger or forward'),
    (2, 'Attacking midfielder (No.8)', 'drop to drag his marker, then spin into the vacated space'),
    (3, 'Winger (No.11) / forward (No.9)', 'contest the first ball, hold it up'),
    (4, 'Centre backs (No.4, No.5)', 'step up together to push the forwards offside'),
    (5, 'Nearby midfielders', 'close in fast to win the second ball')
) AS v(so, role, job);

-- 45. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Strong Side Equality vs High Press Zonal Defending', 'Winger drops, AM runs behind full back',
    'With equal numbers the full back drops to receive from the CB while the winger comes short and drags the opposing full back out of the line.',
    'Opposing full back follows the dropping winger',
    'AM times a run into the space behind; full back plays an aerial pass over, potentially eliminating seven opponents.',
    '4-4-2', 99, 99, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (No.3)', 'drop, receive, turn, aerial pass into space'),
    (2, 'Left winger (No.11)', 'drop to pull the opposing full back out'),
    (3, 'Attacking midfielder (No.8)', 'well-timed run behind the full back')
) AS v(so, role, job);

-- 46. pp.100-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Strong Side Equality vs High Press Zonal Defending', 'Full back one-two into the centre',
    'When the opposing central midfielder follows the AM tightly and kills the aerial option, the AM''s movement instead empties the central area.',
    'Central midfielder tracks the AM out of the middle',
    'Full back plays a wall pass with the winger and arrives in the centre, then passes behind for the forward, switches to the weak-side winger, or finds the free No.10.',
    '4-4-2', 100, 100, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (No.3)', 'one-two with the winger, carry into central space'),
    (2, 'Left winger (No.11)', 'set the wall pass'),
    (3, 'Attacking midfielder (No.8)', 'drag his marker out of the middle'),
    (4, 'Forward (No.9) / weak-side winger (No.7)', 'run in behind or receive the switch'),
    (5, 'Other AM (No.10)', 'free option inside')
) AS v(so, role, job);

-- 47. pp.101-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Strong Side Equality vs High Press Zonal Defending', 'Forward drops as link for wide overload',
    'Same coordinated winger and AM movements, but now the forward drops to link; as the full back receives, winger, AM and No.9 move in sync to give lanes to the forward or the winger.',
    'Full back receives with a lane to the dropping No.9 or the winger',
    'No.9 plays through for the AM''s run, lays off for the winger to switch to the far winger, or finds the free No.10.',
    '4-4-2', 101, 101, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (No.9)', 'drop to link, play forward or lay off'),
    (2, 'Left back (No.3)', 'pass to the forward or the winger'),
    (3, 'Winger (No.11)', 'alternative link, switch to the opposite winger'),
    (4, 'Attacking midfielder (No.8)', 'run in behind'),
    (5, 'AM (No.10)', 'free option in space')
) AS v(so, role, job);

-- 48. pp.103-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Training Session 5: Strong Side Equality vs High Press Zonal Defending', 'Read overload or equality, then combine or switch',
    'Combination and switching drills, a 3-team switch game and split-pitch/3-zone games teach players to see whether the ball side holds an overload or only equal numbers.',
    'Opponent shifts early to match numbers near the ball, or fails to',
    'With an advantage, combine quickly and score; with equality, either play long with support for the second ball or switch to the weak side.',
    NULL, 103, 109, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (No.6)', 'free player when the side is overloaded'),
    (2, 'Forward (No.9)', 'link player or target for the long pass'),
    (3, 'Wide players', 'receive the switch and attack the far side'),
    (4, 'All players', 'communicate overload/equality/switch with verbal cues')
) AS v(so, role, job);

-- 49. pp.111-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Against High Press with Zonal Defending and Man Marking', 'Stretch the midfielder covering two',
    'Against a hybrid zonal/man press the opponent is 2v3 in central midfield: one central midfielder marks closely while the other sits between the No.6 and No.10. Shown for 4-3-3 (single pivot).',
    'Opposing central midfielder sets up between two of our midfielders',
    'No.6 and No.10 widen the gap from each other and keep equal distance from nearby opponents so one is always in a passing lane; GK plays direct to No.6 or lofts over two lines to No.10.',
    '4-4-2', 111, 112, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (No.6)', 'move away from No.10 into the GK''s passing lane'),
    (2, 'Attacking midfielder (No.10)', 'move away too, sit behind the second pressing line'),
    (3, 'Goalkeeper', 'pick the midfielder with most space; lofted pass over two lines if needed'),
    (4, 'Other AM (No.8)', 'occupy his close marker')
) AS v(so, role, job);

-- 50. pp.113-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Against High Press with Zonal Defending and Man Marking', 'Diamond around the pivot, striker links',
    'Once the No.6 receives and is pressed, the first line is beaten; the two AMs and the forward spread into different lanes forming two triangles or a diamond around him.',
    'Pivot receives and the opposing midfielder presses him; direct lanes to AMs blocked',
    'No.9 drops as link and moves the ball to whichever AM is free behind the second line.',
    '4-4-2', 113, 113, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (No.6)', 'receive and find the link'),
    (2, 'Forward (No.9)', 'drop to be the diamond''s top/link player'),
    (3, 'Attacking midfielders (No.8, No.10)', 'take separate lanes as target players')
) AS v(so, role, job);

-- 51. pp.114-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Against High Press with Zonal Defending and Man Marking', 'Double pivot: GK picks AM or pivot',
    'In 4-2-3-1 vs the hybrid press, No.6 and No.10 split apart; the GK reads where the in-between midfielder goes.',
    'Opposing midfielder stays between them, or shifts inside to shut the lane to No.10',
    'If he stays, GK passes through to No.10 between the lines (breaks two lines, takes out six); if he narrows, No.6 is free and gets the ball via the centre back as link.',
    '4-4-2', 114, 116, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'read the midfielder''s position and choose the route'),
    (2, 'Attacking midfielder (No.10)', 'receive between the lines and play behind the defence'),
    (3, 'Defensive midfielder (No.6)', 'drift wide away from No.10 to stretch the cover'),
    (4, 'Centre back (No.4)', 'link pass into No.6 when the GK lane is closed')
) AS v(so, role, job);

-- 52. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Against High Press with Zonal Defending and Man Marking', 'Winger tucks in, full back overlaps high',
    'After No.6 receives on the strong side, the lane to No.10 is blocked; the winger comes inside while the full back pushes on, forming triangles/diamond around No.6.',
    'Pass to No.10 blocked by the pressing midfielder',
    'Opposing full back faces a dilemma; winger links the ball to No.10, who then plays behind for the forward or the full back.',
    '4-4-2', 117, 117, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (No.7)', 'move inside to be link player'),
    (2, 'Full back (No.2)', 'push forward, run in behind'),
    (3, 'Attacking midfielder (No.10)', 'target player between the lines'),
    (4, 'Forward (No.9)', 'run in behind the back line'),
    (5, 'Defensive midfielder (No.6)', 'receive and pick the link')
) AS v(so, role, job);

-- 53. pp.119-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Training Session 6: Against High Press with Zonal Defending and Man Marking', 'Exploit 3v2 midfield vs 2-2 press',
    'Positional small-sided games and an 11v11 drill: blues in 2-3-1 or 2-2-1-1 shape vs a 2-2 press where one opposing midfielder must cover two; the GK reads which pass is on.',
    'Opposing forwards narrow to block the lane to the pivot, or midfielders block the AM',
    'Go direct to the free midfielder when open; otherwise via the centre back, using the forward or a midfielder as link to the free player in the end zone.',
    NULL, 119, 123, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'read the pressing cues, choose direct or via CB'),
    (2, 'Midfielders (No.6, No.10)', 'increase distance between each other'),
    (3, 'Forward (No.9)', 'link player to the free midfielder'),
    (4, 'Centre back (No.4)', 'alternative route into midfield')
) AS v(so, role, job);

-- 54. pp.125-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Tactical Analysis: Against Ultra-Aggressive Pressing with Zonal Defending and Man Marking', 'Ultra-aggressive press onto the goalkeeper',
    'When the press reaches the keeper, the possession team has 7 plus GK v 6; the pressing side responds with two rules: the forward presses the GK on a curve that blocks the lane to one centre back, and every short receiver near the ball is marked tightly (zonal plus man marking in midfield).',
    'Goalkeeper in possession',
    'Remove the spare centre back and deny any easy short pass from the GK so the first pass at worst only neutralises the presser.',
    '4-4-2', 125, 127, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing forward (No.9)', 'press the GK on a curved run that screens his own centre back'),
    (2, 'Other forward (No.10)', 'drop distance to the far centre back, ready to press as he receives'),
    (3, 'Central midfielder (No.8)', 'first sit between two of our midfielders, then jump forward to mark the pivot'),
    (4, 'Central midfielder (No.6)', 'mark the nearest attacking midfielder'),
    (5, 'Midfield unit', 'mark in zone, stop short-pass receivers turning')
) AS v(so, role, job);

-- 55. pp.127-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Tactical Analysis: Against Ultra-Aggressive Pressing with Zonal Defending and Man Marking', 'Beat the GK press via the closest link',
    'Against the ultra-aggressive press (4-3-3 build up) two players stay free: the centre back in the shadow of the pressing forward and the AM left after the opposing midfielder jumps to the pivot.',
    'All short options look marked, but the pivot is close to the GK',
    'GK plays the nearest link (pivot), who sets to the free centre back; the CB carries forward and the ball reaches the free No.10 between the lines. Continues past p128.',
    '4-4-2', 127, 128, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'pass to the closest link player'),
    (2, 'Defensive midfielder (No.6)', 'link: lay the ball to the free centre back'),
    (3, 'Centre back (No.4)', 'receive in the presser''s shadow, carry forward into the overload'),
    (4, 'Attacking midfielder (No.10)', 'stay free between the lines as final target')
) AS v(so, role, job);

-- 56. pp.129-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Against Ultra-Aggressive Pressing with Zonal Defending and Man Marking (Single Pivot)', 'Link player principles: height, scanning, timing',
    'Opponent presses up to the goalkeeper and marks every short option; the defensive midfielder acts as link player to reach the free centre back.',
    'Opponent forward starts his run at the goalkeeper',
    'Create a short, narrow diagonal passing angle to the link player so the blind-side winger cannot intercept the pass on to the free centre back.',
    '4-4-2', 129, 131, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (link player)', 'Start relatively high, scan the space and the nearest dangerous opponent (the winger) before the GK is pressed'),
    (2, 'Defensive midfielder (link player)', 'Drop in sync with the presser''s run, not early; dropping too early or too deep flattens the angle and invites interception'),
    (3, 'Goalkeeper', 'Play into the link player once he has dropped at the right moment'),
    (4, 'Free centre back', 'Hold width as the target of the link player''s pass')
) AS v(so, role, job);

-- 57. pp.132-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Against Ultra-Aggressive Pressing (Single Pivot)', 'Free centre back attacks the 3v1',
    'After the link pass, the free centre back has space in front and a 3v1 with full back and attacking midfielder near the ball against the opposing winger.',
    'Free centre back receives from the link player',
    'Progress immediately before the far central midfielder can shift across and close the lane.',
    '4-4-2', 132, 132, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free centre back', 'Decide fast: carry forward, pass to full back or to attacking midfielder depending on the winger'),
    (2, 'Ball-side full back', 'Free option if the winger closes the line to the attacking midfielder'),
    (3, 'Ball-side attacking midfielder', 'Free option if the winger blocks the full back; stay wide of the far central midfielder')
) AS v(so, role, job);

-- 58. pp.133-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Against Ultra-Aggressive Pressing (Single and Double Pivot)', 'Free attacking midfielder between the lines',
    'When an opposing central midfielder steps up to mark the pivot, a blue attacking midfielder is left unmarked between the lines.',
    'Opposing central midfielder jumps onto the defensive midfielder',
    'Reach the free attacking midfielder directly from the GK or via the forward''s lay-off, bypassing most of the press.',
    '4-4-2', 133, 137, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'If time to scan, pass straight to the free attacking midfielder; under heavy pressure, play long and straight to the forward'),
    (2, 'Centre forward (advanced link player)', 'Drop off the ball to receive and set the ball back to the free attacking midfielder'),
    (3, 'Attacking midfielder', 'Drift away from nearby markers into the pocket between midfield and defence')
) AS v(so, role, job);

-- 59. pp.134-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up Against Ultra-Aggressive Pressing (Double Pivot)', 'Ultra-aggressive press marking all short options',
    'Pressing team against a 4-2-3-1 build-up: everyone near the goalkeeper is marked or cut off; two blue players (far centre back, attacking midfielder) end up free.',
    'Goalkeeper has the ball',
    'Leave the goalkeeper no safe short pass.',
    '4-2-3-1', 134, 135, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing forward', 'Curve run at the GK so his body blocks the pass to his own direct centre back'),
    (2, 'Second forward', 'Squeeze close to the other centre back to press him on receipt'),
    (3, 'Central midfielder', 'Step forward to mark one defensive midfielder'),
    (4, 'Other central midfielder', 'Sit between the second defensive midfielder and the attacking midfielder to cover both (3v2 midfield)')
) AS v(so, role, job);

-- 60. pp.134-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Against Ultra-Aggressive Pressing (Double Pivot)', 'Two link players to the free centre back',
    'With a double pivot both defensive midfielders are potential link players near the goalkeeper to reach the centre back hidden behind the presser.',
    'Pressing forward blocks the direct GK-to-centre-back pass',
    'Move the ball to the free centre back, who then gets a 2v1 with the full back against the winger.',
    '4-2-3-1', 134, 136, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder nearer the free CB', 'Preferred link: shorter pass to the centre back gives the winger less time to intercept'),
    (2, 'Other defensive midfielder', 'Second link option, applying the same timing rules'),
    (3, 'Free centre back', 'Receive and attack the space with the full back for a 2v1 on the winger')
) AS v(so, role, job);

-- 61. pp.139-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Training Session 7: Against Ultra-Aggressive Pressing with Zonal Defending and Man Marking', 'Read the press: direct pass or link',
    'Practices (8v8 thirds game, 7+1v6 half pitch, 11v11) where blues must find the free player under an ultra-aggressive man-marking press using either the deep link (pivot) or advanced link (forward).',
    'Goalkeeper pressed immediately; all midfielders marked',
    'Get the ball to the free player (centre back or attacking midfielder) then exploit the 3v2/3v3 ahead.',
    '4-4-2', 139, 146, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Recognise whether the pivot or the forward can link and pick fast'),
    (2, 'Defensive midfielder', 'Deep link to the free centre back'),
    (3, 'Centre forward', 'Advanced link: receive aerial pass and set to the free attacking midfielder'),
    (4, 'Attacking midfielder', 'Be the free player between the lines and attack')
) AS v(so, role, job);

-- 62. pp.140-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Training Session 7: Against Ultra-Aggressive Pressing with Zonal Defending and Man Marking', 'Link player bypasses winger to full back',
    'The opposing winger steps forward anticipating the link pass to the centre back, leaving space behind him.',
    'Winger advances to intercept the pass toward the centre back',
    'Skip the centre back and play the full back directly into the space the winger vacated.',
    '4-4-2', 140, 142, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (link player)', 'Scan, spot the advanced winger and pass straight to the full back'),
    (2, 'Full back', 'Stay in space wide and higher, then play into the next zone'),
    (3, 'Centre back', 'Receive only when the winger stays deep')
) AS v(so, role, job);

-- 63. pp.148-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up to Exploit Space Out Wide and Bypass Midfield Marking', 'Midfield man marking with spare man at back',
    'Pressing team keeps a 4v3 at the back while man-marking in midfield: a forward drops onto the pivot, one winger covers two players, the far full back steps up. Same adjustment vs 4-3-3 and 4-2-3-1.',
    'Opponent builds up from the goalkeeper',
    'Deny midfield and keep defensive superiority while still pressing both centre backs.',
    '4-4-2', 148, 156, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping forward', 'Drop into midfield to mark the defensive midfielder'),
    (2, 'Weak-side winger', 'Push up between centre back and full back to control two players'),
    (3, 'Full back on that side', 'Step up slightly to intercept aerial passes to the blue full back while staying near the back line'),
    (4, 'Back line', 'Keep a 4v3 over the forwards')
) AS v(so, role, job);

-- 64. pp.149-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up to Exploit Space Out Wide and Bypass Midfield Marking (Single Pivot)', 'Stretch spacing against a winger covering two',
    'On the side where one opposing winger covers centre back and full back, the three blue wide players increase their distances. Against ultra-aggressive pressing both centre backs drop and both sides do it.',
    'One winger left marking two blue players',
    'Make it too hard for the opposing full back and winger to control three blue players.',
    '4-4-2', 149, 155, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side centre back', 'Drop deeper to lengthen distances'),
    (2, 'Weak-side full back', 'Sit equidistant between centre back and winger, between the two opponents'),
    (3, 'Weak-side winger', 'Hold the highest line he can without being offside'),
    (4, 'Goalkeeper', 'Against ultra-aggressive pressing start quickly before the forward arrives')
) AS v(so, role, job);

-- 65. pp.150-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up to Exploit Space Out Wide and Bypass Midfield Marking (Single Pivot)', 'Full back receives from GK, reads opposing full back',
    'The full back receives unmarked from the goalkeeper between the winger and full back, creating a 2v1 wide.',
    'Pass arrives with the opposing full back''s reaction',
    'If the opposing full back steps out, find the winger directly or via the attacking midfielder; if he drops, drive forward.',
    '4-4-2', 150, 150, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Position equidistant to receive, then read the opposing full back'),
    (2, 'Winger', 'Free when the opposing full back jumps'),
    (3, 'Ball-side attacking midfielder', 'Inside link to the winger')
) AS v(so, role, job);

-- 66. pp.151-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up to Exploit Space Out Wide and Bypass Midfield Marking (Single Pivot)', 'First-time flick to winger behind jumping full back',
    'The opposing full back jumps to press the full back while the ball travels from the goalkeeper, leaving space behind.',
    'Opposing full back steps out during ball flight',
    'First-time pass or header into the winger''s path behind the line, bypassing the presser.',
    '4-4-2', 151, 151, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Anticipate the jump and play first time (foot or head) into space'),
    (2, 'Winger', 'Start high and attack the space behind at speed'),
    (3, 'Goalkeeper', 'Accurate delivery to the full back')
) AS v(so, role, job);

-- 67. pp.152-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up to Exploit Space Out Wide and Bypass Midfield Marking (Single Pivot)', 'GK long pass to winger behind full back',
    'The opposing full back shifts early to cut off the blue full back; the rest of their line shifts across late.',
    'Opposing full back moves up before the pass',
    'Goalkeeper''s long pass reaches the winger behind, bypassing about 7 opponents.',
    '4-4-2', 152, 152, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Stay between opposing full back and winger to keep them occupied'),
    (2, 'Winger', 'Stay as far from defenders as possible, ready for the long pass'),
    (3, 'Goalkeeper', 'Deliver the long pass into the space before the line recovers')
) AS v(so, role, job);

-- 68. pp.153-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up to Exploit Space Out Wide and Bypass Midfield Marking (Single Pivot)', 'Deep wide markers free the centre back',
    'Both the opposing full back and winger stay deep to protect wide lanes.',
    'Opposing winger holds a deep position',
    'Centre back receives a short pass from the goalkeeper unpressured and progresses centrally.',
    '4-4-2', 153, 153, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Receive, scan, carry forward or connect with a midfielder'),
    (2, 'Goalkeeper', 'Play the short pass'),
    (3, 'Full back and winger', 'Keep the wide opponents pinned deep')
) AS v(so, role, job);

-- 69. pp.154-157
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up to Exploit Space Out Wide and Bypass Midfield Marking (Single and Double Pivot)', 'Link players reach the advanced free full back',
    'After GK to centre back, the opposing winger presses with a curved run that blocks the pass to the free advanced full back.',
    'Winger blocks the centre back to full back lane',
    'Relay via a link player to the free full back for a 2v1 wide.',
    '4-4-2', 154, 157, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (single pivot) / nearest defensive midfielder (double pivot)', 'Link player with wide visual field redirects to the full back'),
    (2, 'Ball-side attacking midfielder', 'Alternative higher link with lower risk; must follow link timing rules'),
    (3, 'Advanced full back', 'Hold width high to receive and attack the 2v1')
) AS v(so, role, job);

-- 70. pp.159-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Training Session 8: Exploit Space Out Wide to Bypass Midfield Marking', 'GK reads winger: low zone or middle zone',
    'Practices (wide-area drill, 5+GK v 4 small-sided, 6v5 split pitch for 4-3-3 and 4-2-3-1) where the goalkeeper and full back choose the build route from the opposing winger''s and full back''s actions.',
    'Opposing winger''s press (5 seconds for GK to decide)',
    'Play into the side with most space: centre back if the winger presses the full back, full back directly or via link if the winger stays on the centre back; first-time header into space if the full back jumps.',
    '4-4-2', 159, 162, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Decide within 5 seconds which zone to play into'),
    (2, 'Full back', 'If the defender holds, receive in space; if he jumps, first-time header/pass into space behind'),
    (3, 'Attacking midfielder', 'Link to the full back when the direct pass is blocked'),
    (4, 'Winger', 'Run onto the ball in space behind')
) AS v(so, role, job);

-- 71. pp.164-172
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'out_of_possession', 'Build Up Solutions Against Full Pitch Man Marking', 'Full-pitch man marking, CB steps in',
    'Pressing team marks everyone across the pitch: a centre back steps into midfield to mark the free attacking midfielder so both forwards can stay high, giving 3v3 in midfield and at the back.',
    'Opponent builds up from the goalkeeper',
    'No free player anywhere; the build-up team must win individual duels.',
    '4-4-2', 164, 172, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Stepping centre back', 'Push into midfield to man-mark the attacking midfielder'),
    (2, 'Both forwards', 'Stay high on the centre backs'),
    (3, 'Midfielders', 'Man-mark their direct opponents'),
    (4, 'Remaining defenders', 'Accept a 3v3 at the back')
) AS v(so, role, job);

-- 72. pp.165-165
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Solutions Against Full Pitch Man Marking (Single Pivot)', 'Target forward long ball with lay-off support',
    'Against full man marking, a strong target forward receives a long pass from the goalkeeper in a 1v1 with his marker.',
    'Goalkeeper in possession, all short options marked',
    'Forward holds and lays off to a midfielder, bypassing up to 7 opponents and the first two pressing lines.',
    '4-4-2', 165, 165, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (target player)', 'Shield and win the 1v1, lay off to an onrushing teammate'),
    (2, 'Central midfielders', 'Drop first to drag their markers away, then turn sharply to attack the space for the lay-off'),
    (3, 'Goalkeeper', 'Play the long aerial pass to the forward')
) AS v(so, role, job);

-- 73. pp.166-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Solutions Against Full Pitch Man Marking (Single Pivot)', 'Target forward flicks into space for wingers',
    'Long pass to the target forward with wingers timing runs in behind the defensive line.',
    'Long pass played to the forward',
    'Forward either lays back or heads into the space behind for the runners, stretching the line.',
    '4-4-2', 166, 166, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Challenge for the ball and choose lay-off or flick behind'),
    (2, 'Wingers', 'Time runs to arrive as the forward contests the ball'),
    (3, 'Goalkeeper', 'Long pass to the forward')
) AS v(so, role, job);

-- 74. pp.167-167
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Solutions Against Full Pitch Man Marking (Single Pivot)', 'Decoy run opens space for runner forward',
    'With a fast runner forward, a winger drops back and inside, dragging his full back with him and opening space behind.',
    'Opposing full back follows the dropping winger',
    'Goalkeeper''s long pass into the vacated space for the forward to run onto and beat his marker 1v1.',
    '4-4-2', 167, 167, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Decoy: drop back and inside to pull the full back out'),
    (2, 'Centre forward (runner)', 'Run diagonally into the vacated space and take the ball in stride'),
    (3, 'Goalkeeper', 'Time the long pass into the space')
) AS v(so, role, job);

-- 75. pp.168-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Solutions Against Full Pitch Man Marking (Single Pivot)', 'Forward drops, wingers run behind full backs',
    'The forward drops a few metres into midfield, pulling his centre back with him, so the full backs lose their cover.',
    'Opposing centre back follows the dropping forward',
    'Goalkeeper passes behind either full back for the wingers to run onto.',
    '4-4-2', 168, 168, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Drop to offer a passing option and drag the centre back'),
    (2, 'Central midfielders', 'Open a wider lane toward the forward'),
    (3, 'Wingers', 'Run in behind the opposing full backs'),
    (4, 'Goalkeeper', 'Well-weighted pass behind the full back')
) AS v(so, role, job);

-- 76. pp.169-174
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Solutions Against Full Pitch Man Marking (Single and Double Pivot)', 'Link to the CB in the presser''s shadow',
    'Under ultra-aggressive pressing a forward presses the goalkeeper and leaves his own centre back free but behind his cover shadow.',
    'Opponent forward presses the goalkeeper',
    'Link player moves the ball to the free centre back, then a 2v1 wide: full back if the winger steps up, winger as link (after shifting inside) if the full back is blocked.',
    '4-4-2', 169, 174, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder / ball-side attacking midfielder (single pivot); both defensive midfielders (double pivot)', 'Act as link players near the ball'),
    (2, 'Free centre back', 'Receive and read the opposing winger'),
    (3, 'Full back', 'Free option if the winger presses the centre back'),
    (4, 'Winger', 'Drop or shift inside as a link to the full back')
) AS v(so, role, job);

-- 77. pp.170-170
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Solutions Against Full Pitch Man Marking (Single Pivot)', 'CM jumps to CB, AM goes free',
    'An opposing central midfielder leaves the attacking midfielder to close down the free centre back.',
    'Central midfielder steps onto the centre back',
    'Play the now free attacking midfielder directly, or via the winger as link when the lane is blocked.',
    '4-4-2', 170, 170, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder', 'Move into the central space between the lines'),
    (2, 'Centre back', 'Pass directly if the lane is open'),
    (3, 'Winger', 'Drop as link player to set the ball inside')
) AS v(so, role, job);

-- 78. pp.171-171
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Solutions Against Full Pitch Man Marking (Single Pivot)', 'CM presses GK, pivot goes free',
    'An opposing central midfielder pushes up to press the goalkeeper, leaving the defensive midfielder unmarked centrally but with the direct pass blocked.',
    'Opposing central midfielder presses the goalkeeper',
    'Reach the free pivot quickly through a link (e.g. attacking midfielder) before the opponent recovers.',
    '4-4-2', 171, 171, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Recognise he is free and offer an angle'),
    (2, 'Attacking midfielder (link player)', 'Receive from the goalkeeper and set to the pivot'),
    (3, 'Goalkeeper', 'Read the change quickly and find the link')
) AS v(so, role, job);

-- 79. pp.173-173
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Build Up Solutions Against Full Pitch Man Marking (Double Pivot)', 'AM drops to free target forward',
    'In the 4-2-3-1, the attacking midfielder drops deeper and pulls the stepping-up centre back with him, opening space for the target forward.',
    'Opposing centre back follows the dropping attacking midfielder',
    'Long goalkeeper pass to the forward, who holds and lays off to the defensive midfielders, bypassing up to 7 opponents.',
    '4-4-2', 173, 173, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder', 'Drop deep to drag his marker away'),
    (2, 'Centre forward (target player)', 'Receive under pressure from his marker and lay off'),
    (3, 'Both defensive midfielders', 'Make quick curved runs to attack the space and receive the lay-off'),
    (4, 'Goalkeeper', 'Long pass to the forward')
) AS v(so, role, job);

-- 80. pp.176-177
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Training Session 9: Against Full Pitch Man Marking', 'Drop to drag marker, teammate runs into gap',
    'Functional combination: after a long pass to a receiver, one player drops as if to pull an opponent out while another runs into the vacated space.',
    'Long pass to the receiver',
    'Disrupt man marking with timed off-ball movement and finish in the vacated space.',
    NULL, 176, 177, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Long passer (GK/defender)', 'Play long to the receiver'),
    (2, 'Receiver', 'Direct the ball into the runner''s path'),
    (3, 'Space creator', 'Drop back as if dragging a marker'),
    (4, 'Runner', 'Overlap or run into the vacated space and finish')
) AS v(so, role, job);

-- 81. pp.178-182
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-single-double-pivots-build-up-play-and-sessions-from-flick-k'), 'in_possession', 'Training Session 9: Against Full Pitch Man Marking', 'Read the press type, adapt the build-up',
    'Half-pitch, 6v6 long-pass and 11v11 games vs full-pitch man marking applied either as high pressing (first receiver) or ultra-aggressive pressing (up to the GK).',
    'Type of opposition pressing',
    'Versus ultra-aggressive pressing find and use the free player (e.g. pivot when his marker presses the GK); versus high pressing create space with synchronised movement or the goalkeeper''s long pass to the forward/wingers.',
    '4-4-2', 178, 182, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Pass within 4-5 seconds; long pass to forward or wingers when all are marked'),
    (2, 'Defensive midfielder', 'Free player when his marker presses the goalkeeper'),
    (3, 'Centre forward', 'Hold-up/link or use speed to receive in behind'),
    (4, 'Midfielders', 'Off-ball movements to lose markers, apply link player rules')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1978-coaching-book-beat-the-press-pivots-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
