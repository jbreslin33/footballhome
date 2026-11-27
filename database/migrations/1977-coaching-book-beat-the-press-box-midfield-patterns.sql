-- 1977 📚 Coaching book patterns: "Beat the Press With a Box Midfield" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Beat the Press With a Box Midfield',
    subtitle    = 'Build Up Play and Sessions from Guardiola, Alonso and Arteta''s Tactics',
    author      = 'Athanasios Terzis',
    team        = 'Man City (Guardiola), Bayer Leverkusen (Alonso), Arsenal (Arteta)',
    season      = '2022-24',
    method_note = 'How Guardiola''s Man City, Alonso''s Leverkusen and Arteta''s Arsenal build from the goalkeeper with a box midfield (3-2-2-3 / 2-4-2-2). It first studies how opponents press a 4-3-3 (high versus ultra-aggressive, zonal, man marking, full-pitch man marking, hybrid), then the rotations that form the box (inverted full back, centre back stepping into midfield, winger tucking in, Leverkusen''s 3-4-2-1 shift), then a tactical-analysis chapter per press type with 2 or 3 at the back, each followed by a training session. Patterns are the build-up behaviours (and the pressing team''s set-ups), in our words, with who does what.'
WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo');

-- 1. pp.13-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Build Up Play Factors: Essential Skills and Opposition Pressing Tactics', 'Back line scans and keeps re-offering',
    'Defenders and holding midfielders look around several times before the ball arrives and, after each pass, move again to give the passer a new angle.',
    'Teammate about to pass / just passed',
    'Receivers know the free space before receiving and possession keeps flowing under pressure.',
    NULL, 13, 14, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Composed distributor: short to defenders, through or over one or two lines, switches and long balls behind'),
    (2, 'Centre backs', 'Receive in tight space, carry forward when space opens, draw opponents to open lanes'),
    (3, 'Defensive midfielders', 'Scan repeatedly before receiving, then reposition straight after passing')
) AS v(so, role, job);

-- 2. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'out_of_possession', 'Build Up Play Factors: Essential Skills and Opposition Pressing Tactics', 'High press on the first receiver',
    'Pressing team lets the goalkeeper have the ball and jumps the first pass to a defender, defending a band of roughly 36 m (shown with a 4-4-2 against a 4-3-3 build up).',
    'Goalkeeper passes to a centre back',
    'Shorter area to defend keeps the block compact while still pressuring early.',
    '4-3-3', 16, 16, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest forward', 'Presses the centre back receiving the first pass'),
    (2, 'Rest of block', 'Stay compact inside the ~36 m band')
) AS v(so, role, job);

-- 3. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'out_of_possession', 'Build Up Play Factors: Essential Skills and Opposition Pressing Tactics', 'Ultra-aggressive press on the goalkeeper',
    'Press goes all the way onto the goalkeeper, so the block must cover about 44 m and one opposing outfield player is always unmarked.',
    'Ball with the goalkeeper',
    'Force errors deep while managing the inevitable free player and staying compact.',
    '4-3-3', 17, 17, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Presses the goalkeeper directly'),
    (2, 'Midfield and back lines', 'Stay compact and screen the free player; expect more opponents between the lines')
) AS v(so, role, job);

-- 4. pp.18-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Build Up Play Factors: Essential Skills and Opposition Pressing Tactics', 'Exploit a lone pressing forward',
    'Against a 4-2-3-1 press, one forward faces two centre backs plus the goalkeeper (1v3), so the back line has time; if he jumps one centre back the ball goes across to the free weak-side centre back.',
    'Lone forward presses one centre back or fails to press',
    'Bypass the first line and advance from the free centre back into space.',
    '4-2-3-1', 18, 20, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Split wide, receive, turn and pick passes; free one steps into space'),
    (2, 'Goalkeeper', 'Plays the first pass and the switch to the weak-side centre back'),
    (3, 'Holding midfielder', 'Acts as link to switch play when the direct lane is closed')
) AS v(so, role, job);

-- 5. pp.20-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'out_of_possession', 'Build Up Play Factors: Essential Skills and Opposition Pressing Tactics', 'Stop the switch after forward presses',
    'When the lone forward presses the ball-side centre back, the pressing team must stop the easy switch to the free weak-side centre back.',
    'Forward jumps the receiving centre back',
    'Close the far-side outlet so the press is not bypassed.',
    '4-3-3', 20, 20, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lone forward', 'Presses the receiving centre back'),
    (2, 'Nearest midfielder', 'Slides across to close the link pass'),
    (3, 'Weak-side winger', 'Anticipates the switch and presses the receiving centre back')
) AS v(so, role, job);

-- 6. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'out_of_possession', 'Build Up Play Factors: Essential Skills and Opposition Pressing Tactics', 'No.10 steps up: 4-2-3-1 into 4-4-2',
    'To fix the 1v3 at the top, the attacking midfielder pushes alongside the striker so two forwards press two centre backs and the goalkeeper (2v3).',
    'Opponent builds from the goalkeeper',
    'More pressure, more forced errors and regains high up; centre backs/full backs cannot play forward freely.',
    '4-3-3', 21, 21, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (No.10)', 'Pushes up next to the striker to press a centre back'),
    (2, 'Striker', 'Presses the other centre back'),
    (3, 'Midfield', 'Cover the lanes left behind')
) AS v(so, role, job);

-- 7. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'out_of_possession', 'Build Up Play Factors: Essential Skills and Opposition Pressing Tactics', 'Zonal defending in the press',
    'Each player owns a zone (shown for a 4-4-2) and defends space rather than opponents; zones move with the ball.',
    'Ball moves',
    'Disrupt the build up while keeping defensive organisation.',
    '4-3-3', 22, 22, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Every outfield player', 'Controls own zone; zones shift with ball position')
) AS v(so, role, job);

-- 8. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'out_of_possession', 'Build Up Play Factors: Essential Skills and Opposition Pressing Tactics', 'Man marking, spare man at back (option 1)',
    'Two centre backs double the opposing striker (2v1) while everyone else marks one-to-one; a winger pushes on to a centre back, leaving a 2v3 at the top with the goalkeeper free.',
    'Opponent builds from the back',
    'Safe centre with tight marking elsewhere; weakness is the winger covering two and the free goalkeeper.',
    '4-3-3', 23, 23, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Double the striker 2v1'),
    (2, 'Right winger', 'Pushes onto the left centre back while minding the full back'),
    (3, 'Others', '1v1 duels on the remaining opponents')
) AS v(so, role, job);

-- 9. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'out_of_possession', 'Build Up Play Factors: Essential Skills and Opposition Pressing Tactics', 'Man marking, spare man at back (option 2)',
    'Keeps the 2v1 on the striker but both wingers mark the centre backs and the striker presses the goalkeeper, giving 3v3 at the first build-up line.',
    'Ball with goalkeeper or centre backs',
    'Ultra-aggressive pressure up to the goalkeeper with balance; wingers covering two players are the weak points.',
    '4-3-3', 24, 24, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'Mark the centre backs, still responsible for the full backs'),
    (2, 'Striker', 'Presses the goalkeeper'),
    (3, 'Centre backs', '2v1 on the opposing striker')
) AS v(so, role, job);

-- 10. pp.25-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'out_of_possession', 'Build Up Play Factors: Essential Skills and Opposition Pressing Tactics', 'Full pitch man marking',
    'Every defender has one direct opponent, including a centre back stepping into midfield, leaving 3v3 at the back and no cover.',
    'Opponent builds up',
    'Constant 1v1 duels squeeze time and space; any lost duel is very dangerous.',
    '4-3-3', 25, 25, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'One centre back', 'Steps forward to mark an opposing midfielder'),
    (2, 'Back line', '3v3 against front three, tight marking'),
    (3, 'All players', 'Win individual duel; discipline and anticipation')
) AS v(so, role, job);

-- 11. pp.26-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'out_of_possession', 'Build Up Play Factors: Essential Skills and Opposition Pressing Tactics', 'Hybrid zonal-man balance player',
    'Players mark opponents inside their zone; where the team is outnumbered (e.g. 2v3 in midfield) one player sits between two opponents instead of marking one.',
    'Outnumbered in a zone',
    'Team stays compact and can still press; the balance player reacts to where the ball goes.',
    '4-3-3', 26, 26, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (No.6)', 'Marks one attacking midfielder'),
    (2, 'Central midfielder (No.8)', 'Sits between the other attacking midfielder and the holding midfielder, jumps on the receiver')
) AS v(so, role, job);

-- 12. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Positional Rotations to Play Out from Goalkeeper', 'Inverted full back makes the box',
    'From a 4-3-3 the right back steps into midfield beside the holding midfielder, the No.6 slides left, the goalkeeper takes the right centre back spot and that centre back goes to right back.',
    'Goal kick / goalkeeper has the ball',
    'Two defenders plus a deep goalkeeper at the back and four players in a box in midfield.',
    NULL, 28, 28, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (No.2, e.g. Rico Lewis)', 'Inverts into central midfield'),
    (2, 'Holding midfielder (No.6)', 'Shifts to the left of the box base'),
    (3, 'Goalkeeper', 'Moves wide into the right centre back spot'),
    (4, 'Right centre back (No.4)', 'Shifts out to right back'),
    (5, 'Left centre back (No.5)', 'Stays as the deep partner beside the goalkeeper')
) AS v(so, role, job);

-- 13. pp.29-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Positional Rotations to Play Out from Goalkeeper', 'Centre back steps into midfield box',
    'From a 4-3-3 the right centre back pushes into midfield beside the holding midfielder (City with Stones) while the goalkeeper fills his position.',
    'Goalkeeper has the ball',
    'Same 2-at-the-back box shape, an extra man in midfield and an overload to find the free player.',
    NULL, 29, 29, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back (No.4, e.g. Stones)', 'Steps into the right side of the box base'),
    (2, 'Holding midfielder (No.6)', 'Slides left'),
    (3, 'Goalkeeper', 'Moves wide to cover the centre back slot')
) AS v(so, role, job);

-- 14. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Positional Rotations to Play Out from Goalkeeper', 'Winger tucks in, 3 at back box',
    'From a 4-2-3-1 the left winger moves inside to attacking midfield, the No.10 shifts right and the left back pushes up for width, with keeper plus two centre backs behind.',
    'Goalkeeper has the ball',
    'Safer three-man base, more midfield numbers, weak side with one wide player and strong side with two.',
    NULL, 30, 30, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (No.11)', 'Comes inside into attacking midfield; must handle tight spaces'),
    (2, 'Attacking midfielder (No.10)', 'Moves to the right half-space'),
    (3, 'Left back (No.3)', 'Advances to give width on the weak side'),
    (4, 'Goalkeeper + two centre backs', 'Three-man first line')
) AS v(so, role, job);

-- 15. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Positional Rotations to Play Out from Goalkeeper', 'Lopsided 3-4-2-1 shift right',
    'In a 3-4-2-1 (Leverkusen) the back line slides right in a chain: right wing back to winger, right centre back to right back, middle centre back to right centre back, goalkeeper joins the base.',
    'Goalkeeper has the ball',
    'Three at the back with a natural box, a strong right side and a lighter left.',
    NULL, 31, 31, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (No.7)', 'Advances to winger'),
    (2, 'Right centre back (No.2)', 'Moves to right back'),
    (3, 'Middle centre back (No.4)', 'Moves to right centre back'),
    (4, 'Goalkeeper + left centre back', 'Form the base with No.4')
) AS v(so, role, job);

-- 16. pp.33-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Break Lines vs High Press Zonal Defending', 'Box occupies the gaps between lines',
    'Against a zonal 4-4-2 press the four box players sit in the gaps between the opposition lines, each equally spaced from the nearest opponents, and readjust as gaps open.',
    'Opponent sets a zonal high press',
    'Four of the six gaps are filled so the goalkeeper and defenders always have a central option.',
    '4-4-2', 33, 35, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (No.6)', 'Occupies base gap behind the forwards'),
    (2, 'Inverted full back (No.2)', 'Occupies the other base gap'),
    (3, 'Attacking midfielders (No.8, No.10)', 'Sit between midfield and back lines, between opponents'),
    (4, 'Goalkeeper / centre backs', 'Look to find a box player')
) AS v(so, role, job);

-- 17. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Break Lines vs High Press Zonal Defending', 'Goalkeeper breaks first line to box',
    'With the forward in front of him, the goalkeeper reads the press and passes through it to the defensive midfielder or inverted full back, or over it in the air to an attacking midfielder if those are blocked.',
    'Goalkeeper on the ball facing a two-man first line',
    'First pressing line bypassed and the receiver can turn.',
    '4-4-2', 36, 36, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Reads the press, through pass to base of box or aerial pass to AM'),
    (2, 'Defensive midfielder (No.6) / inverted right back (No.2)', 'Show good angles to receive and turn'),
    (3, 'Attacking midfielders (No.8, No.10)', 'Alternative aerial targets')
) AS v(so, role, job);

-- 18. pp.37-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Break Lines vs High Press Zonal Defending', 'Base receiver turns, finds AM via link',
    'Once the base of the box turns, wingers and striker pin the back four so the attacking midfielders are free between lines; the ball goes to them directly or via the striker as a link, using two triangles (a diamond).',
    'Base midfielder receives unmarked and turns',
    'Second line broken, six opponents out of the game, then a pass in behind.',
    '4-4-2', 37, 39, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder / inverted full back', 'Receive behind first line, turn, play forward'),
    (2, 'Attacking midfielders (No.8, No.10)', 'Target players between lines'),
    (3, 'Striker (No.9)', 'Link player; drops to set the ball to the free AM'),
    (4, 'Wingers (No.7, No.11)', 'Pin full backs, create 2v1 dilemmas, threaten in behind'),
    (5, 'Centre backs', 'Tuck in for balance if the ball is lost')
) AS v(so, role, job);

-- 19. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Break Lines vs High Press Zonal Defending', 'Keeper to centre back when base screened',
    'When the opposing No.10 narrows the lane to the holding midfielder, the goalkeeper plays to the left centre back who finds the free left AM; if the opposing midfielder steps to the inverted full back, the goalkeeper goes long to the freed right AM.',
    'Pass to defensive midfielders is screened',
    'First two lines broken anyway; if the winger blocks the AM, the full back is open wide.',
    '4-4-2', 40, 40, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Switches to the centre back or chips to the free AM'),
    (2, 'Left centre back (No.5)', 'Receives and passes to the AM behind the second line'),
    (3, 'Attacking midfielders', 'Stay free in space vacated by stepping midfielders'),
    (4, 'Left back (No.3)', 'Wide outlet if the winger cuts the AM lane')
) AS v(so, role, job);

-- 20. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Break Lines vs High Press Zonal Defending', 'Wide centre back breaks second line',
    'When a winger jumps the inverted full back, the goalkeeper plays the wide right centre back, whose job is to break the second line with a pass into the AM or via the winger as link.',
    'Opposing winger presses the inverted full back',
    'Ball reaches the AM between lines; defence forced to shift.',
    '4-4-2', 41, 41, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back (No.4)', 'Receives wide, finds AM (No.10) directly or via winger'),
    (2, 'Right winger (No.7)', 'Link player set-back to the AM'),
    (3, 'Attacking midfielder (No.10)', 'Receives between the lines')
) AS v(so, role, job);

-- 21. pp.42-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Break Lines vs High Press Zonal Defending', 'Winger drops, AM runs in behind',
    'With the right centre back on the ball wide, the winger drops deep; if the full back does not follow he receives and turns, and when the full back does follow the AM runs into the space behind him.',
    'Opposing full back follows or ignores the dropping winger',
    'Bypass two lines and play in behind the back four.',
    '4-4-2', 42, 42, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (No.7)', 'Drops into space to receive and turn'),
    (2, 'Attacking midfielder (No.10)', 'Runs behind the full back who stepped out'),
    (3, 'Right centre back (No.4)', 'Plays to the winger or straight into the run')
) AS v(so, role, job);

-- 22. pp.43-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Break Lines vs High Press Zonal Defending', 'Draw press with a pass (2 at back)',
    'A pass to a box base player lures the opposing central midfielder to press; the ball goes back or wide (inverted full back to centre back, or goalkeeper back to centre back who dribbles) and then into the AM in the space the presser left.',
    'Opposing midfielder steps up to press the receiver',
    'Free AM behind the second line; read the press side and move the ball there fast.',
    '4-4-2', 43, 44, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Bait pass into midfield, then redirects to the free centre back'),
    (2, 'Inverted full back (No.2) / defensive midfielder (No.6)', 'Draw the presser then bounce or play the quick risky pass'),
    (3, 'Centre backs (No.4, No.5)', 'Carry and pass into the vacated space; shift central for balance'),
    (4, 'Attacking midfielders (No.8, No.10)', 'Receive behind the pressing midfielder'),
    (5, 'Winger', 'Link if the direct lane closes')
) AS v(so, role, job);

-- 23. pp.45-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Break Lines vs High Press Zonal Defending', '3-at-back keeper steps in, box receives',
    'With a three-man base the goalkeeper sits between the two forwards and can dribble forward to shorten passes into the four midfielders; the tucked-in winger creates a dilemma for the opposing right back, and the left back pushes into the space he leaves.',
    'Goalkeeper on the ball between two forwards',
    'Accurate central pass breaks more lines; defenders stay back so both AMs are free between the lines.',
    '4-4-2', 45, 47, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Steps forward with ball, plays to the base of the box'),
    (2, 'Winger in box (No.11)', 'Attacking midfielder; drags the full back'),
    (3, 'Left back (No.3)', 'Pushes high into space the full back leaves'),
    (4, 'Defensive midfielder (No.8)', 'Slides across for cover'),
    (5, 'Striker (No.9)', 'Link between base and AMs')
) AS v(so, role, job);

-- 24. pp.48-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Break Lines vs High Press Zonal Defending', 'Side route: centre back, DM, AM',
    'In the 3-at-back box, play goes keeper to side centre back to defensive midfielder, who decides quickly whether to hit the AM; if blocked the striker drops as link or the other DM links to the weak-side AM.',
    'Opposing midfielders shift and press the ball side',
    'AM receives behind the second line, then through pass in behind.',
    '4-4-2', 48, 49, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (No.8)', 'Receives, decides fast, may dribble'),
    (2, 'Striker (No.9)', 'Stays high if the pass is on, else drops as link'),
    (3, 'Other defensive midfielder (No.6)', 'Link to the weak-side AM'),
    (4, 'Attacking midfielders (No.10, No.11)', 'Free targets; then pass behind the back four')
) AS v(so, role, job);

-- 25. pp.50-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Break Lines vs High Press Zonal Defending', 'Draw press from midfielder (3 at back)',
    'Keeper threads a pass to a defensive midfielder to draw the opposing midfielder; the ball goes back via keeper to a centre back, or sideways DM to DM, and on to the AM in the space vacated.',
    'Opposing central midfielder steps to press',
    'AM free behind the second line before the defence recovers.',
    '4-4-2', 50, 51, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Through pass to bait the press, then recycle to the centre back'),
    (2, 'Defensive midfielders', 'Draw the presser; quick risky DM-to-DM option'),
    (3, 'Centre backs', 'Dribble forward and find the AM'),
    (4, 'Attacking midfielders (No.10 / No.11)', 'Receive in the space behind the presser')
) AS v(so, role, job);

-- 26. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Break Lines vs High Press Zonal Defending', 'Keeper dribbles, centre backs drive',
    'When the goalkeeper carries the ball between the two forwards they narrow to close the middle, which frees both wide centre backs to receive and dribble forward; a pass to an AM breaks two lines, or to the full back if wingers tuck in.',
    'Keeper carries forward, forwards squeeze inward',
    'Collapse the first line and break two lines from the centre backs.',
    '4-4-2', 52, 52, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Carries forward between the forwards'),
    (2, 'Centre backs (No.4, No.5)', 'Receive wide and dribble forward'),
    (3, 'Full backs (No.2, No.3)', 'Push high to form triangles'),
    (4, 'Attacking midfielders', 'Targets in the wide-to-central lane')
) AS v(so, role, job);

-- 27. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Build Up - Break Lines vs High Press Zonal Defending', 'Full backs exploit tucked-in wingers',
    'When the opposing wingers come inside to block passes to the AMs, the centre backs play to the high full backs, who use the 2v1 wide with an overlap, underlap or run behind while the central players stay inside.',
    'Opposing wingers narrow to block inside lanes',
    'Bypass central pressure and progress down the flank.',
    '4-4-2', 53, 53, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Find the full back in space'),
    (2, 'Full backs (No.2, No.3)', 'Carry forward, pass or combine'),
    (3, 'Winger / wide AM', 'Moves inside or runs behind the opposing full back'),
    (4, 'Central AM (No.10)', 'Stays central as final receiver'),
    (5, 'Striker (No.9)', 'Pins centre backs with a forward run')
) AS v(so, role, job);

-- 28. pp.55-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Training Session 1: Break Lines vs High Press Zonal Defending', 'Turn or bounce vs the presser',
    'Practice: the base midfielder scans the nearest midfielder; if not pressed he turns and plays forward, if pressed he bounces to the other base player, keeper or centre back so the AM behind the presser is found, with the striker linking.',
    'Nearest opponent midfielder holds or steps up to press',
    'Quick correct decision under pressure and ball into the space behind the press.',
    '4-4-2', 55, 58, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Scans early, turns on the half-turn or passes back'),
    (2, 'Other base player / centre back', 'Gives the bounce option, often as link'),
    (3, 'Attacking midfielder', 'Receives between lines, then through pass'),
    (4, 'Striker', 'Link or give-and-go, then finishes')
) AS v(so, role, job);

-- 29. pp.59-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Session 1: Break Lines vs High Press Zonal Defending', 'Holding mid reads presser: turn or bounce',
    'The holding midfielder receives from the GK or a centre back behind the first pressing line while the nearest opposing midfielder decides whether to step up.',
    'Whether the closest opposing midfielder moves to press',
    'Turn and break the second line when free, or recycle/switch when pressed, to find an attacking mid behind the second line.',
    '4-4-2', 59, 61, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (No.8/6)', 'Scan before receiving; turn if unpressed, else lay off or switch'),
    (2, 'Centre backs', 'Circulate with GK to pull the first line across'),
    (3, 'Attacking midfielders (No.10/11)', 'Sit behind the second line ready to receive and turn'),
    (4, 'Full backs', 'Push high and wide to stretch the block')
) AS v(so, role, job);

-- 30. pp.60-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Session 1: Break Lines vs High Press Zonal Defending', 'GK dribbles in to free the centre back',
    'The GK carries the ball forward so the two opposing forwards tuck in to close the central lane, leaving a centre back free wide.',
    'Opposing forwards narrow onto the GK',
    'The free centre back reads the midfielders'' reactions and plays straight into the attacking mid or via a link player.',
    '4-4-2', 60, 60, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Dribble forward to attract the front two, then pass wide to the CB'),
    (2, 'Centre back (No.4)', 'Read whether the near winger tucks inside; pass direct to No.10 or use a link'),
    (3, 'Attacking midfielder (No.10)', 'Find the gap between lines and finish the move behind'),
    (4, 'Full backs', 'Advance to give support and width')
) AS v(so, role, job);

-- 31. pp.63-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Goalkeeper''s Passing Over Pressing Lines', 'GK lofted pass to unmarked attacking mid',
    'With the press set on the first line, the GK plays a direct aerial ball to an attacking mid sitting between lines; the defender near him is torn between two players and stays.',
    'Nearby defender (e.g. full back covering winger and AM) does not step out',
    'Skip the midfield press in one pass; the AM receives on the half-turn, turns and slips a runner behind.',
    '4-4-2', 63, 77, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Choose short build-up or the lofted pass over the second line'),
    (2, 'Attacking midfielder (No.10)', 'Find space between lines, receive half-turned, turn and play through'),
    (3, 'Winger and forward', 'Stretch the back line, run in behind once AM turns'),
    (4, 'Teammates near receiver', 'Communicate whether pressure is coming')
) AS v(so, role, job);

-- 32. pp.65-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Goalkeeper''s Passing Over Pressing Lines', 'Full back jumps: flick behind for winger',
    'When the opposing full back steps forward to stop the attacking mid turning from the GK''s long pass, space opens behind him.',
    'Opposing full back steps out to press the receiving AM',
    'AM plays a first-time pass or header into the vacated channel for the winger running in behind.',
    '4-4-2', 65, 76, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (No.10)', 'Scan or be told the FB is coming; first-time pass or header behind'),
    (2, 'Winger (No.7)', 'Time the run into the space the FB left; call it early'),
    (3, 'Goalkeeper', 'Deliver the aerial pass into the AM''s zone')
) AS v(so, role, job);

-- 33. pp.66-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Goalkeeper''s Passing Over Pressing Lines', 'Centre back jumps: flick in for striker',
    'If an opposing centre back steps out of the line to press the attacking mid, a central hole opens in the back line.',
    'Opposing centre back leaves the line to press the AM',
    'AM flicks or heads first time into the gap for the striker, who is placed between the two CBs, to run onto toward goal.',
    '4-4-2', 66, 76, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (No.9)', 'Stand between the two CBs unmarked; attack the gap at once'),
    (2, 'Attacking midfielder (No.10)', 'Recognise the CB stepping; first-time ball into the gap'),
    (3, 'Winger / forward', 'Alert the AM verbally')
) AS v(so, role, job);

-- 34. pp.67-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Goalkeeper''s Passing Over Pressing Lines (3 at Back)', 'Left back surge forces decisions vs long ball',
    'With three at the back only two forwards are high, so the back four marks them easily; the left back''s forward run (holding mid shifting left to cover) forces the opposing winger and full back to choose whom to track.',
    'GK has the ball; LB pushes on',
    'If the winger does not track, a pass reaches the LB or the free AM; if the FB steps, GK goes long behind for the LB; if the FB holds, the AM receives unmarked behind the second line.',
    '4-4-2', 67, 68, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (No.3)', 'Run forward to overload the flank'),
    (2, 'Holding midfielder (No.8)', 'Slide left to keep rest-defence balance'),
    (3, 'Forward (No.9)', 'Shift across to occupy both CBs'),
    (4, 'Goalkeeper', 'Read winger/FB choices and pick the free man or long pass'),
    (5, 'Attacking midfielder (No.11)', 'Hold the pocket behind the second line')
) AS v(so, role, job);

-- 35. pp.79-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Strong Side Advantage vs High Press Zonal Defending', 'Box midfield +2: 4v3 on both sides',
    'Against a 4-4-2 zonal press, the 2-at-the-back box (GK stepping in as a centre back) gives 7+GK v 6 in defence and midfield, and a 4v3 on each half of the pitch with no extra movement.',
    'Opponent sets a 4-4-2 high zonal press',
    'Keep ball control and progress through the half with the overload while keeping defensive balance.',
    '4-4-2', 79, 80, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Act as an extra centre back so one outfield player can push higher'),
    (2, 'Centre back', 'Partner the GK at the back'),
    (3, 'Box midfield (2 holding + 2 attacking)', 'Form the square that creates 4v3 per side')
) AS v(so, role, job);

-- 36. pp.81-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Strong Side Advantage vs High Press Zonal Defending', 'Stretch distances to break midfield zones',
    'Each side''s holding mid and attacking mid sit inside one opposing midfielder''s zone; if they stand close he can cover both.',
    'One opposing midfielder can screen two of our mids',
    'Increase the distance between the pair so the defender faces a hard choice, without drifting near other defenders.',
    '4-4-2', 81, 81, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielders (No.6, No.2)', 'Widen distance from the attacking mid on their side'),
    (2, 'Attacking midfielders (No.8, No.10)', 'Stay apart from partner and away from other defenders')
) AS v(so, role, job);

-- 37. pp.82-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Strong Side Advantage vs High Press Zonal Defending', 'Find the free man in the 4v3',
    'With a 4v3 near the ball on the GK''s side, the team quickly identifies which midfielder the opposing midfielder has left; the far-side CB and LB slide over for cover.',
    'Opposing midfielder commits to one of our two mids',
    'Pass to the free player to progress; the team shifts into a 3-2-2-3 shape as the ball goes forward.',
    '4-4-2', 82, 93, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (No.2)', 'Receive when his marker moves to No.10 and drive forward'),
    (2, 'Attacking midfielder (No.10)', 'Pull the marker toward him'),
    (3, 'Weak-side centre back (No.5)', 'Shift across toward the strong side to defend a turnover'),
    (4, 'Left back (No.3)', 'Tuck in for rest defence'),
    (5, 'Right centre back (No.4)', 'Start the build-up')
) AS v(so, role, job);

-- 38. pp.83-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Strong Side Advantage vs High Press Zonal Defending', 'Switch through GK when lanes shut',
    'On the 4v3 side the opposing 10 blocks the inside pass and their 8 marks our AM, closing forward lanes.',
    'Forward passing lanes on the strong side are blocked',
    'Go back to the GK and across the back to the other CB so the ball reaches the overload on the far side before the opponent can shift.',
    '4-4-2', 83, 83, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Offer a back pass and play across'),
    (2, 'Weak-side players (left back, winger)', 'Stay wide to prepare the switch'),
    (3, 'Left centre back (No.5)', 'Receive and play to LB to progress'),
    (4, 'Right centre back (No.4)', 'Recycle to GK')
) AS v(so, role, job);

-- 39. pp.84-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Strong Side Advantage vs High Press Zonal Defending', 'Draw press one side, switch to CB side',
    'Building on the left CB''s side with a 4v3, the LB finds the attacking mid between the opposing midfielders, or uses link players; the right CB tucks in for compactness.',
    'First pass to the GK''s side draws the press across',
    'Bypass two lines via the attacking mid; starting on the GK side and switching to the CB leaves more safety at the back.',
    '4-4-2', 84, 84, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (No.3)', 'Find the forward pass to the AM as the reds slide'),
    (2, 'Attacking midfielder (No.8)', 'Stand between two opposing midfielders'),
    (3, 'Right centre back (No.4)', 'Shift inside for defensive cover; if he goes too wide, RB drops into CB'),
    (4, 'Goalkeeper', 'Start on his side, then switch to No.5')
) AS v(so, role, job);

-- 40. pp.85-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Strong Side Advantage vs High Press Zonal Defending (3 at Back)', '3-back box: GK picks the 4v3 side',
    'With a 3-at-the-back box the opposing full back can follow the inverted winger, giving 4v4 on one side and 4v3 on the other.',
    'Opposing FB tracks the winger inside',
    'GK reads the numbers and plays to the stronger side, then the free player is found; the team becomes 3-2-3-2 with LB as wing back.',
    '4-4-2', 85, 92, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Recognise where the 4v3 is and play there'),
    (2, 'Inverted winger (No.11)', 'Move inside to form the box'),
    (3, 'Back three (No.4, No.5, No.2)', 'Hold the back line for safety'),
    (4, 'Left back (No.3)', 'Push on as a wing back on the side without a winger'),
    (5, 'Attacking midfielder (No.10)', 'Move to the overload side to create the free player')
) AS v(so, role, job);

-- 41. pp.95-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Strong Side Equality vs High Press Zonal Defending', 'Equal on strong side: switch to free winger',
    'The opponent shifts quickly after the GK''s first pass to create 4v4 on the ball side, which leaves the far CB, GK and weak-side winger free and a possible 2v1 in the centre.',
    'Defence shifts to match numbers on the ball side',
    'Beat the press with a central 2v1 or a nearby free player and switch to the weak-side winger who has time and space.',
    '4-4-2', 95, 96, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (No.8)', 'Carry inside to find space and pass to the free holding mid or other AM'),
    (2, 'Holding midfielder (No.2)', 'Exploit the 2v1 in the centre'),
    (3, 'Weak-side winger (No.7)', 'Stay wide for the switch and attack'),
    (4, 'Free centre back (No.4) and GK', 'Act as the outlets for the switch')
) AS v(so, role, job);

-- 42. pp.97-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Strong Side Equality vs High Press Zonal Defending', 'Reset via GK/CB to switch',
    'The opponent removes the central 2v1 by bringing a winger inside and blocking the path to the other attacking mid.',
    'Central progression blocked',
    'The AM drops to the centre back and the ball goes to GK or the far CB, who switches long to the weak-side winger; slower than switching from midfield.',
    '4-4-2', 97, 97, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (No.8)', 'Receive from CB and bounce back'),
    (2, 'Goalkeeper / far centre back (No.4)', 'Play the long switch'),
    (3, 'Weak-side winger (No.7)', 'Receive in space and run at the back line')
) AS v(so, role, job);

-- 43. pp.98-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Strong Side Equality vs High Press Zonal Defending', 'CB long ball with quick support',
    'With equal numbers on the strong side the AM drops to escape his marker, dragging the opposing midfielder and opening space behind for the winger or forward.',
    'Centre back under pressure; opposing midfielder follows the dropping AM',
    'CB plays long to a forward who holds it up; teammates support quickly to win the second ball and CBs push up to leave the striker offside.',
    '4-4-2', 98, 98, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (No.5)', 'Play the aerial pass to the winger/forward'),
    (2, 'Attacking midfielder (No.8)', 'Drop to pull the marker away'),
    (3, 'Winger (No.11) / forward (No.9)', 'Receive and hold up the ball'),
    (4, 'Centre backs (No.4, No.5)', 'Step up after the long pass to protect against the counter')
) AS v(so, role, job);

-- 44. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Strong Side Equality vs High Press Zonal Defending', 'Winger drops, AM runs behind FB',
    'The LB drops to receive from the CB while the left winger drops and drags the opposing right back out of position.',
    'Opposing full back follows the dropping winger',
    'LB plays an aerial ball into the space behind the full back for the AM''s forward run, potentially taking out seven players.',
    '4-4-2', 99, 99, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (No.3)', 'Drop, turn and play the aerial pass'),
    (2, 'Left winger (No.11)', 'Drop deep to pull the right back'),
    (3, 'Attacking midfielder (No.8)', 'Time the run into the space behind')
) AS v(so, role, job);

-- 45. pp.100-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Strong Side Equality vs High Press Zonal Defending', 'One-two in vacated centre then switch',
    'If the opposing central mid follows our AM tightly, the aerial lane to the AM closes but a space opens centrally.',
    'Opposing midfielder tracks the attacking mid''s run',
    'LB plays a one-two with the winger into the central space, then passes to the forward or weak-side winger to get behind the line.',
    '4-4-2', 100, 100, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (No.3)', 'Play the one-two and receive centrally'),
    (2, 'Left winger (No.11)', 'Give the wall pass'),
    (3, 'Attacking midfielder (No.8)', 'Run to drag his marker out'),
    (4, 'Holding midfielder (No.6)', 'Stay away from the strong side so the space is not crowded'),
    (5, 'Forward (No.9) / weak-side winger (No.7)', 'Offer the next pass')
) AS v(so, role, job);

-- 46. pp.101-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Strong Side Equality vs High Press Zonal Defending', 'Striker drops to link wide overload',
    'As the LB receives, the left winger and AM move together and the striker drops to offer a link.',
    'LB receives on the strong side',
    'Striker plays the AM in behind or sets for the winger, or the winger combines with the striker; then the ball can switch to the weak-side winger.',
    '4-4-2', 101, 101, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (No.9)', 'Drop to link; lay off or play through'),
    (2, 'Left back (No.3)', 'Pass direct to the striker or to the winger'),
    (3, 'Left winger (No.11)', 'Play first time to No.9 and run for the return'),
    (4, 'Attacking midfielder (No.8)', 'Run in behind'),
    (5, 'Weak-side winger (No.7)', 'Wait for the switch')
) AS v(so, role, job);

-- 47. pp.102-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Strong Side Equality vs High Press Zonal Defending (3 at Back)', '3-back strong side turns 4v4',
    'With three at the back the strong side starts 4v3, but when the ball goes there the opposing forward slides across quickly and makes it 4v4.',
    'Opposing forward shifts across',
    'Use the same equal-numbers solutions as the 2-at-back version: CB long ball with support, FB aerial behind, combination for the switch, striker link.',
    '4-4-2', 102, 102, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Play into the strong-side wide player'),
    (2, 'Strong-side wide defender (No.4)', 'Choose among the equal-numbers solutions'),
    (3, 'Attacking midfielders', 'Drop or run to open space')
) AS v(so, role, job);

-- 48. pp.103-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Weak Side Build Up with Numerical Equality (3 at Back)', 'Weak side 4v4: LB runs, CB goes long',
    'Building on the side with no winger gives a 4v4 with fewer options but more space for the centre back.',
    'Ball played to the weak-side centre back',
    'AM drops to pull the right back away, holding mid drops to drag the central mid, and the CB plays long for the LB''s run or into the striker to hold and link.',
    '4-4-2', 103, 103, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (No.5)', 'Long aerial pass to LB or striker'),
    (2, 'Left back (No.3)', 'Make the forward run as there is no winger'),
    (3, 'Attacking midfielder (No.11)', 'Drop to pull the right back out'),
    (4, 'Holding midfielder (No.8)', 'Drop to drag the opposing central mid forward'),
    (5, 'Forward (No.9)', 'Hold the ball up; teammates win the second ball')
) AS v(so, role, job);

-- 49. pp.105-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Session 4: Strong Side Equality vs High Press Zonal Defending', 'Equal numbers: combine, go long or switch',
    'Practices train the box midfield building with equal numbers on one side and the option of an outside support player or weak side.',
    'No overload on the ball side (reds shift early)',
    'Read overload vs equality: exploit an overload with quick combinations, otherwise play long with support for the second ball or switch to the weak side.',
    '4-4-2', 105, 112, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielders', 'Read the numbers and choose combine, long, or switch'),
    (2, 'Attacking midfielders', 'Off-ball movement to open lanes'),
    (3, 'Weak-side winger', 'Stay as the target for the switch'),
    (4, 'Supporting players', 'Arrive quickly after long passes for the second ball')
) AS v(so, role, job);

-- 50. pp.114-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Against High Press with Zonal Defending and Man Marking', 'Hybrid press: stretch the man covering two',
    'A hybrid press man-marks inside zones; a 4v2 in midfield forces the opponent to drop a forward (4-4-2 becomes 4-1-4-1), leaving 1v2 on the first line and 3v4 in midfield, where one opposing mid must cover two.',
    'Opposing No.10 drops into midfield; No.9 presses CB alone',
    'Make it hard for the midfielder covering two players and move the ball to the midfielder with most space.',
    '4-4-2', 114, 116, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper and centre back', 'Use the 2v1 against the lone forward to get the ball into midfield'),
    (2, 'Attacking midfielders (No.8, No.10)', 'Increase distance from each other so the single central marker cannot cover both'),
    (3, 'Holding midfielders (No.6, No.2)', 'Note their direct markers')
) AS v(so, role, job);

-- 51. pp.116-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Tactical Analysis: Against High Press with Zonal Defending and Man Marking (2 at Back)', 'Holders drop to open lanes to AMs',
    'Both holding mids are man-marked and one opposing central mid covers both attacking mids; our AMs move wide while staying away from nearby defenders.',
    'Opposing central mid left to cover two AMs',
    'Holding mids drop and shift inward to drag their markers and keep the lane to an AM open; the GK carries forward first to improve the pass, with the weak-side AM reached by an aerial pass. Continues past p.116.',
    '4-4-2', 116, 116, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielders (No.6, No.2)', 'Drop and move centrally taking markers with them'),
    (2, 'Attacking midfielder (No.10)', 'Move wider at equal distance from two defenders for a direct pass'),
    (3, 'Attacking midfielder (No.8)', 'Go wide on the weak side; receive an aerial ball'),
    (4, 'Goalkeeper', 'Dribble forward before passing for accuracy')
) AS v(so, role, job);

-- 52. pp.117-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Against High Press with Zonal Defending and Man Marking (2 at Back)', 'Free holding pair receives from keeper',
    'Opponent shifts from 4-4-2 to 4-2-3-1: two central mids man-mark our advanced pair, their No.10 drops and must cover both our holding midfielders while the No.9 presses 1v2 on CB and GK.',
    'Opposing 10 left alone to cover two holding mids',
    'Get the ball to an unmarked holding midfielder straight from the goalkeeper and bypass the first line.',
    '4-2-3-1', 117, 118, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielders (6 and inverted RB 2)', 'Split far apart, stay equidistant from markers, step into open passing lanes'),
    (2, 'Advanced midfielders (8 and 10)', 'Move a few metres wider and higher to drag their markers away and open the centre'),
    (3, 'Goalkeeper', 'Carry the ball forward first to sharpen the pass angle, then play the free holder')
) AS v(so, role, job);

-- 53. pp.119-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Against High Press with Zonal Defending and Man Marking (2 at Back)', 'Holder carries to free his partner',
    'Once a holding midfielder (inverted right back) has the ball, he drives forward so the opposing 10 must press him, leaving the other holder free.',
    'Opposing 10 steps to press the ball-carrying holder',
    'Find the freed holder via a link player, then the advanced mid whose marker was pulled out, to carry into the attacking half.',
    '4-2-3-1', 119, 119, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted right back (holder 2)', 'Carry forward to attract the 10'),
    (2, 'Other holder (6)', 'Stay open as the free player in the centre'),
    (3, 'Advanced mid 10 / forward 9', 'Act as link players for a wall pass to the free holder'),
    (4, 'Advanced mid 8', 'Receive and drive forward when his marker leaves to help on the 9')
) AS v(so, role, job);

-- 54. pp.120-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Against High Press with Zonal Defending and Man Marking (3 at Back)', 'Keeper chips to stretched advanced mids',
    'Against a 3-at-the-back box (GK plus two CBs) the opponent turns 4-2-3-1 into 3-2-3-2: a forward drops to make 3v4 in midfield, winger pushes up for 2v3, full back steps onto our wide man; one of their mids covers both our advanced players.',
    'One opposing midfielder covering both advanced midfielders',
    'Bypass the first line with a direct aerial pass from the goalkeeper to an advanced midfielder, taking five pressers out of the game.',
    NULL, 120, 121, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advanced midfielders (11 and 10)', 'Move away from each other to stretch the lone covering midfielder'),
    (2, 'Left back 3 and holder 8', 'Push up and drop deeper respectively to open more room for 11'),
    (3, 'Holder 6', 'Drop back to clear space for 10'),
    (4, 'Goalkeeper', 'Step forward a few metres and play a medium aerial pass to 11 or 10')
) AS v(so, role, job);

-- 55. pp.122-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Against High Press with Zonal Defending and Man Marking (3 at Back)', 'Beat dropping forward between holders',
    'Opponent goes 4-4-2 to 3-3-2-2: one forward drops between our two holding midfielders, the others man-mark the advanced pair and the full back pushes onto our wide defender.',
    'A forward sits between our holders and must cover both',
    'Move the ball to the holder he cannot cover, directly from the GK or through a centre back used as a link player.',
    NULL, 122, 123, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielders (8 and 6)', 'Widen the gap from the dropping forward, stay equidistant, sit in open lanes'),
    (2, 'Advanced midfielders (11 and 10)', 'Push forward so their markers follow, freeing space for the holders'),
    (3, 'Ball-side centre back (4)', 'Serve as link player to bounce the ball to the far holder'),
    (4, 'Goalkeeper', 'Carry forward then pass to the open holder')
) AS v(so, role, job);

-- 56. pp.125-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Session 5: Against High Press with Zonal Defending and Man Marking', 'Find the midfielder with most space',
    'Practices against a single or double pivot (mannequins, then 6v4, 5v4 and an 11v11 game) where one defender always marks two box players.',
    'Opponent player covering two box midfielders',
    'Box players stretch the overloaded defender, the keeper reads the press and finds the free midfielder, then the team progresses quickly; defenders counter within 8-12 seconds if they win it.',
    NULL, 125, 129, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holders', 'Drop deeper and wider vs a double pivot, centrally vs a single pivot'),
    (2, 'Advanced midfielders', 'Push higher and wider to make the covering player choose'),
    (3, 'Goalkeeper', 'Read who is free and pass short or aerial to that player'),
    (4, 'All box players', 'Synchronise off-ball movement and play line-breaking passes quickly')
) AS v(so, role, job);

-- 57. pp.131-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'out_of_possession', 'Against Ultra-Aggressive Pressing with Zonal Defending and Man Marking', 'Ultra-aggressive press on the keeper',
    'Pressing team presses up to the goalkeeper, facing 8+GK v 7; uses a zonal/man-marking hybrid with a forward dropping into midfield (3-2-3-2 vs a 3-back box, 4-1-4-1 vs a 2-back box).',
    'Goalkeeper has the ball',
    'Remove the free centre back and every short option so the keeper has no safe pass.',
    NULL, 131, 133, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing forward (9)', 'Curve the run at the GK to block the lane to one centre back'),
    (2, 'Midfielders', 'Tight-mark anyone in their zone who could get a short pass, deny turning'),
    (3, 'Single covering midfielder (6)', 'Sit between the two advanced box players rather than commit to one'),
    (4, 'Same-side winger and full back', 'Push up to close the wide outlet')
) AS v(so, role, job);

-- 58. pp.134-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Against Ultra-Aggressive Pressing with Zonal Defending and Man Marking (3 at Back)', 'Link player timing (link player principles)',
    'When the keeper is pressed, one centre back becomes the free defender, but a winger lurks on his blind side to intercept; a holding midfielder near the ball links to him.',
    'Opponent commits to pressing the goalkeeper',
    'Bounce the ball through a link player to the free defender on a narrow angle the winger cannot cut out.',
    NULL, 134, 136, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Link players (holders 8 and 6)', 'Scan the zone in front of the GK before the press starts, start high and drop only once the press is triggered'),
    (2, 'Holder 6', 'Re-scan for the blind-side winger, receive and set the ball short to the free CB'),
    (3, 'Free centre back (4)', 'Stay wide to give the target'),
    (4, 'Coaching rule', 'Dropping early or deep flattens the angle and invites interception')
) AS v(so, role, job);

-- 59. pp.137-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Against Ultra-Aggressive Pressing with Zonal Defending and Man Marking (3 at Back)', 'Free defender exploits space or 2v1',
    'The free centre back receives via the link player and has the winger reacting to him with the right back outside.',
    'Free defender receives under the opposing winger''s approach',
    'Act at once: dribble into space, or pass to whichever of the full back or advanced mid the winger leaves open.',
    NULL, 137, 137, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free centre back (4)', 'Drive forward if the winger retreats, else pass to the open option'),
    (2, 'Right back (2)', 'Hold width to make the 2v1'),
    (3, 'Advanced midfielder (10)', 'Offer inside; links to 2 if the winger blocks that pass')
) AS v(so, role, job);

-- 60. pp.138-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Against Ultra-Aggressive Pressing with Zonal Defending and Man Marking (3 at Back)', 'Keeper options when pressed (3-back)',
    'Their 9 presses the GK while two mids man-mark our holders, leaving one midfielder between our two advanced players.',
    'Red 9 presses the goalkeeper',
    'Keeper picks by time available: link via a holder to the free CB, or directly / via the forward to whichever advanced mid is unmarked.',
    NULL, 138, 138, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Decide quickly based on the press trigger'),
    (2, 'Holders (8 and 6)', 'Act as link players to the free centre back; 6 is the safer, shorter route away from the blind-side winger'),
    (3, 'Advanced midfielders (11 and 10)', 'Use the space their markers vacated; the one not approached is the target'),
    (4, 'Forward (9)', 'Drop as a link player away from the ball')
) AS v(so, role, job);

-- 61. pp.139-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Against Ultra-Aggressive Pressing with Zonal Defending and Man Marking (2 at Back)', 'Keeper options when pressed (2-back)',
    'Opponent goes 4-4-2 to 4-1-4-1: their 10 drops to mark our only centre back, their 9 presses 1v2, mids shift so the 6 covers both advanced players.',
    'Red 9 presses the goalkeeper',
    'Holders link the ball to the free centre back, or the keeper finds an advanced midfielder directly or through the dropping forward.',
    '4-1-4-1', 139, 140, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holders (inverted RB 2 and 6)', 'Draw the opposing mids, then link to the free CB 5'),
    (2, 'Advanced midfielders (8 and 10)', 'Exploit space created; the one the covering 6 leaves is the target'),
    (3, 'Forward (9)', 'Link player for lay-offs'),
    (4, 'Goalkeeper', 'Choose by time and apply link player principles')
) AS v(so, role, job);

-- 62. pp.142-148
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Session 6: Against Ultra-Aggressive Pressing', 'Link player feeds the free player',
    'Progressive practices (passing pattern, 3v2 waves, 3v2+GK, 8+1 v 7, 7+1 v 6, 11v11 with 2- and 3-back boxes) where a presser always closes one lane.',
    'Nearest defender steps out to press the ball carrier',
    'Identify the free player and reach him directly or via a link player before the press recovers; defenders counter in 8-12 seconds.',
    NULL, 142, 148, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Dribble to commit the presser'),
    (2, 'Link player', 'Drop into the lane once the press triggers and set the ball on'),
    (3, 'Free player', 'Stay unmarked, receive and progress or score'),
    (4, 'Outside forward (9)', 'Support with one-touch lay-offs only')
) AS v(so, role, job);

-- 63. pp.150-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'out_of_possession', 'Against Full Pitch Man Marking', 'Full pitch man marking vs box',
    'Defending team marks man for man across the whole pitch: the wide player follows our inverting full back or winger, and a centre back steps out onto the free advanced midfielder, leaving 3v3 / 2v2 at the back and 4v4 in midfield.',
    'Opponent builds with a box midfield from the keeper',
    'Tight coverage everywhere removes passing options and central progression.',
    NULL, 150, 153, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Opposing wide player', 'Track the full back or winger who inverts into the box'),
    (2, 'Stepping centre back', 'Push up to mark the extra advanced midfielder'),
    (3, 'Remaining defenders', 'Hold 3v3 or 2v2 with our forwards')
) AS v(so, role, job);

-- 64. pp.151-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Against Full Pitch Man Marking', 'Long pass to target forward',
    'Against man marking everywhere, the keeper plays long to the centre forward after an advanced midfielder drops to drag a holding midfielder out of the zone in front of the defence.',
    'Advanced midfielder drops and his marker follows',
    'Forward receives without a double mark and lays off to runners facing goal, beating 6-7 pressers.',
    NULL, 151, 154, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advanced midfielder (8 or 11)', 'Drop deep to pull his marker out and open space'),
    (2, 'Forward (9)', 'Hold up the long ball and lay off'),
    (3, 'Other box mids (10, 2 or 6)', 'Make support runs to offer short lay-off and combination options'),
    (4, 'Goalkeeper', 'Accurate long pass into the forward')
) AS v(so, role, job);

-- 65. pp.152-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Against Full Pitch Man Marking', 'Free centre back via link players',
    'With man marking plus their 10 pressing the keeper, one centre back is left unmarked near the ball.',
    'Opposing forward presses the goalkeeper',
    'Reach the free CB through a holding midfielder link, then the next freed player (e.g. left back) as the press shifts, repeating as needed.',
    NULL, 152, 152, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Read the press quickly and pick the link'),
    (2, 'Holders (6 or 2)', 'Link players to the free centre back'),
    (3, 'Free centre back (5)', 'Drive into space ahead; pass on when pressed'),
    (4, 'Left back (3)', 'Become the next free outlet')
) AS v(so, role, job);

-- 66. pp.155-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Against Full Pitch Man Marking (3 at Back)', 'Long ball behind advanced full back',
    'Their full back steps high to track our inverting winger, leaving space behind him on that flank.',
    'Opposing full back pushes up to mark',
    'Keeper sends a quick forward running into the space for a 1v1 against a centre back and a direct chance.',
    NULL, 155, 155, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Accurate long pass into space behind the full back'),
    (2, 'Pacy forward (9)', 'Run into the channel, drive at goal or into a better area'),
    (3, 'Advanced midfielders / wingers', 'Overlap or support to add threat')
) AS v(so, role, job);

-- 67. pp.156-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Against Full Pitch Man Marking (3 at Back)', 'Attacking full back long-ball run',
    'In a 3-back box the wide full back owns the whole flank; the opposing winger tucks inside, leaving space behind him.',
    'Opposing winger positioned narrow',
    'Keeper releases the full back into space beyond the winger to break lines and neutralise six or more opponents.',
    NULL, 156, 156, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (3)', 'Run into space beyond the winger, carry forward at speed'),
    (2, 'Goalkeeper', 'Precise long pass to the full back'),
    (3, 'Forward (9)', 'Alternative long-pass target')
) AS v(so, role, job);

-- 68. pp.158-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Session 7: Against Full Pitch Man Marking', 'Lose markers with timed support runs',
    'Practices (zone circuits, long pass with support runs, 7v7/8v8 half-pitch games, 7v7 long-pass games) against tight man marking.',
    'Defender commits to press or track a player',
    'One player drops to pull his marker away while another runs into the vacated space; keeper plays within 4-5 seconds to the forward or full back.',
    NULL, 158, 163, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Space creator (C)', 'Drop back as if to receive, dragging his man away'),
    (2, 'Space exploiter (D)', 'Overlap into the vacated zone and receive'),
    (3, 'Long passer / GK', 'Play a well-weighted long pass to the target'),
    (4, 'Receiver (forward)', 'Set the ball into the runner''s path')
) AS v(so, role, job);

-- 69. pp.164-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'beat-the-press-with-a-box-midfield-build-up-play-and-sessions-from-guardiola-alo'), 'in_possession', 'Box Midfield Session 7: Reading Tactical Triggers', 'Read the press type, choose solution',
    '11v11 where the opponent switches between ultra-aggressive pressing up to the keeper and high pressing on the first receiver, with full pitch man marking.',
    'Pressing type the opponent shows',
    'Against pressure on the keeper find the free player; against pressure on the first receiver use synchronised movements to create and exploit space.',
    NULL, 164, 164, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Recognise the pressing type and start the right option'),
    (2, 'Box midfield', 'Link or stretch depending on the trigger'),
    (3, 'Forward (9)', 'Target player for long passes')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1977-coaching-book-beat-the-press-box-midfield-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
