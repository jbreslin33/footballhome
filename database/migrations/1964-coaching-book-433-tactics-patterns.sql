-- 1964 📚 Coaching book patterns: "Coaching 4-3-3 Tactics" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Coaching 4-3-3 Tactics',
    subtitle    = '154 Tactical Solutions and Practices',
    author      = 'Massimo Lucchesi',
    team        = '4-3-3 (Italian school, 9-zone pitch)',
    method_note = 'How a 4-3-3 solves each phase, on a pitch split into 3 bands (build-up, creating, finishing) and 3 channels, so 9 named zones. Runs: goal-kick distribution by the opponent''s attacking group; build-up against three kinds of press (forwards only, forwards plus midfield, whole team: Manovrata / Accelerata / Diretta); build-up against named shapes (4-4-2, 4-2-3-1, 4-3-1-2, 4-3-3, 3-4-3, 3-5-2); the creating phase (weak-side switch, six support options, rhombus switches, rotations, the imbucata entry ball); finishing; the defensive phase (positional defending, pressing per opponent shape, compacting and prevention, back-four movements); and sample sessions. Patterns are the tactical solutions and the behaviours the practices train, in our words; training theory and drill layouts are left out.'
WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices');

-- 1. pp.13-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'set_piece', 'Chapter 1: Goalkeeper''s Distribution from Goal Kicks', 'Goal kick: count numbers, pick length',
    'Before a goal kick the team decides how many attackers to leave past halfway. If the opponents match our front three man for man (3v3), the keeper goes long into the central far zone (C2) with the midfielders pushed up close to the forwards. If they keep a spare man at the back (4v3), our front three isolate their back line from the rest of their team and the keeper plays short or medium.',
    'Goal kick; read the opponent''s numbers in their back line',
    'Restart into whichever zone (short A, medium B, long C, wide or central) holds the free player.',
    NULL, 13, 14, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Read the opponent''s set-up; choose short, medium or long, and wide or central'),
    (2, 'Front three (wingers + forward)', 'Stay high to pin and isolate the opponent''s back line'),
    (3, 'Midfielders', 'Push up near the forwards when the keeper is going long')
) AS v(so, role, job);

-- 2. pp.14-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'set_piece', 'Chapter 1: Short Goal Kick', 'Centre backs split wide for short kick',
    'For a short goal kick both centre backs spread toward the flanks, outside the penalty box. How close they go to the touchline depends on where the opponent''s midfielders and forwards stand.',
    'Short goal kick chosen',
    'Give the keeper a safe short pass to start the build-up, adjusting quickly to the opponent''s positions.',
    NULL, 14, 14, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Split wide outside the box, spacing set by the opponent''s attackers'),
    (2, 'Goalkeeper', 'Check that the short option is really free before playing it')
) AS v(so, role, job);

-- 3. pp.15-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'set_piece', 'Chapter 1: Goal Kicks Against Opponents in a 5-1 Attacking Formation', '2-5 shape vs one pressing striker',
    'The opponent leaves one striker and five midfielders up (a 5-1 front). Their defenders are ignored because our three forwards hold them, and our back seven forms a 2-5.',
    'Goal kick against a single pressing forward',
    'Two centre backs against one striker in zone A, so the keeper has an easy short pass to either one.',
    NULL, 15, 15, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Split wide in zone A for the short pass'),
    (2, 'Full backs + midfield three', 'Form the five-man line in front'),
    (3, 'Goalkeeper', 'Short pass to the free centre back')
) AS v(so, role, job);

-- 4. pp.15-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'set_piece', 'Chapter 1: Goal Kicks Against Opponents in a 4-2 Attacking Formation', '3-4 shape, keeper finds spare DM',
    'Against two pressing forwards backed by four midfielders, our defence and midfield set up as a 3-4. The defensive midfielder becomes the spare man in zone A.',
    'Goal kick against a 4-2 front',
    'Numerical edge in zone A; short pass to the defensive midfielder in space.',
    NULL, 15, 15, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Spare man in zone A who receives and turns'),
    (2, 'Back line', 'Form the three that occupies the two forwards'),
    (3, 'Goalkeeper', 'Short pass to the defensive midfielder')
) AS v(so, role, job);

-- 5. pp.16-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'set_piece', 'Chapter 1: Goal Kicks Against Opponents in a 3-3 Attacking Formation', 'Three goal-kick routes vs 3-3 front',
    'Against three forwards and three midfielders pressing, three options. 1) Set up as a 4-3 and a central midfielder drops into zone A to take a short pass. 2) Set up as a 3-4 and a medium pass goes to a full back near the touchline in zone B. 3) If both are covered, go long into zone C to a winger in a 1v1, ideally the best header.',
    'Goal kick against a 3-3 front; try options in order as each gets marked',
    'Find the free player at short, then medium, then long range.',
    NULL, 16, 17, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'LCM / RCM', 'Drop off into zone A to receive short (4-3 version)'),
    (2, 'Full backs', 'Stay near the touchline in zone B for the medium pass (3-4 version)'),
    (3, 'Wingers', 'Hold 1v1 in zone C as the long target'),
    (4, 'Goalkeeper', 'Choose short, then medium, then long')
) AS v(so, role, job);

-- 6. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'set_piece', 'Chapter 1: Goal Kicks Against Opponents in a 2-4 Attacking Formation', '4-3 shape, medium ball to free full back',
    'Against two forwards and four midfielders, our defence and midfield set up as a 4-3. The back four and central midfielders usually get marked, which leaves one full back free in zone B.',
    'Goal kick against a 2-4 front',
    'Medium pass to the free full back in space.',
    NULL, 18, 18, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free full back', 'Hold width in zone B to receive'),
    (2, 'Centre backs + midfield three', 'Draw the markers'),
    (3, 'Goalkeeper', 'Medium-length pass out wide')
) AS v(so, role, job);

-- 7. pp.20-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 2: The Different Types of Build Up Play', 'Manovrata / Accelerata / Diretta build-up choice',
    'The type of build-up follows how high the opponent presses. Manovrata (patient): they press only with forwards, so we beat the front line and advance. Accelerata: forwards and midfield press but the back line stays deep, so we pass behind their midfield line, often to a winger coming inside. Diretta (direct): the whole team presses and the back line steps up, so we go long behind it.',
    'Read the height of the opponent''s press after distribution',
    'Match the build-up route to the space the press leaves open (zones A, B or C).',
    NULL, 20, 20, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line + goalkeeper', 'Read the press and pick the build-up type'),
    (2, 'Wingers', 'Come inside behind the midfield line (accelerata) or run in behind (diretta)'),
    (3, 'Forward', 'Pin the back line, or attack the space behind it')
) AS v(so, role, job);

-- 8. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 2: 1.1 Creating a Numerical Advantage at the Back', 'Overload the back, free the receiver',
    'When only their forwards press, our three attackers hold their back four. The rest of their team usually forms a 4-2, 5-1 or 3-3 shape. We use quick side-to-side passes (keeper included) to gain a spare man at the back, carry the ball past the forwards, then pass to a teammate who has escaped his marker, while the others make covering moves to keep the build-up safe.',
    'Opponent presses with forwards only',
    'Get past the first line and find a free player who can carry the ball forward.',
    NULL, 22, 22, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front three', 'Pin the opponent''s back four'),
    (2, 'Centre backs + goalkeeper', 'Switch play horizontally to make the overload'),
    (3, 'Midfielders', 'Lose their markers to receive; others move to cover')
) AS v(so, role, job);

-- 9. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 2: Defensive Midfielder Drops into the Centre of Defence vs 4-4-2', 'DM drops between centre backs',
    'Against two strikers, the defensive midfielder drops into the middle of the back line, which widens it to three. One centre back can then receive in space and dribble forward, while the front three keep the four defenders deep.',
    'Two strikers pressing our two centre backs',
    '3v2 at the back, so a centre back carries the ball out freely.',
    '4-4-2', 23, 23, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Drop between the centre backs'),
    (2, 'Centre back (LCB)', 'Receive wide and dribble forward'),
    (3, 'Front three', 'Hold the opponent''s back four deep'),
    (4, 'Goalkeeper', 'Stay available to restart the build-up')
) AS v(so, role, job);

-- 10. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 2: Central Midfielder Drops Back to Receive vs 4-4-2', 'Central midfielder drops, rhombus forms',
    'Instead of the defensive midfielder, a central midfielder drops into the back line to make the overload, then receives and dribbles. The left back, left winger and defensive midfielder form a rhombus around him. In a variation the left winger stays wide to pin the right back and the forward drops to the top of the rhombus.',
    'Two strikers pressing; central midfielder free to drop',
    'Overload at the back plus a rhombus of passing options for the next phase.',
    '4-4-2', 24, 24, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'LCM', 'Drop into the back line, receive and dribble'),
    (2, 'LB + DM', 'Side and inside points of the rhombus'),
    (3, 'LW', 'Top of the rhombus, or stay wide to pin the full back'),
    (4, 'Forward', 'Drop to the top of the rhombus in the variation')
) AS v(so, role, job);

-- 11. pp.25-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 2: Exploiting 2v1 Numerical Advantage at the Back Against 1 Forward', '2v1 vs lone striker, rhombus support',
    'The opponent has one striker and a No.10 marking our defensive midfielder (4-4-1-1, 4-5-1 or 4-2-3-1). The centre backs use their 2v1 and one carries the ball. Left back and LCM form a rhombus. The DM pulls the No.10 away to free the RCM. If the ball is switched to the other centre back, the forward tops a new rhombus on that side. Variation: both full backs push high and the forward drops to the top, with the LCM and DM as the side supports.',
    'One striker pressing two centre backs; No.10 tracking our DM',
    'A free centre back carries the ball forward with several options around him.',
    '4-4-1-1', 25, 26, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Use the 2v1; the free one dribbles forward'),
    (2, 'Defensive midfielder', 'Drag the No.10 away to open space'),
    (3, 'LB + LCM / RCM', 'Form the rhombus around the carrier'),
    (4, 'Forward', 'Drop to the top of the rhombus'),
    (5, 'Wingers', 'Stay wide and high to stretch the pitch')
) AS v(so, role, job);

-- 12. pp.27-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 2: How to Build Up Play Against 2 Forwards and a No.10', 'Free full back, wide rhombus swap',
    'Against two forwards plus a No.10, the full back is free at first, so midfielders and forwards move to his side and quickly form a rhombus. Option 1: the RCM goes wide as wide support and the RW becomes the top of the rhombus. Option 2: the RW drops wide and the forward moves across to the top.',
    'Full back receives unpressed',
    'Give the full back many options through swaps of position on his flank.',
    NULL, 27, 28, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (RB)', 'Receive free and advance'),
    (2, 'RCM', 'Move wide as wide support (option 1)'),
    (3, 'RW', 'Top of the rhombus (option 1) or drop wide (option 2)'),
    (4, 'Forward', 'Shift across to the top of the rhombus (option 2)')
) AS v(so, role, job);

-- 13. pp.29-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 2: 1.2 Direct Pass into Midfield', 'Centre back splits strikers to DM',
    'Against a 4-4-2, our two central midfielders are taken by their four midfielders, which leaves our defensive midfielder free between the two strikers. The centre back passes straight into him (3v2 in the centre), and he turns and moves forward.',
    'Defensive midfielder free between the two strikers',
    'Bypass the first line with one pass and attack with many options.',
    '4-4-2', 29, 29, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (RCB)', 'Pass between the two strikers'),
    (2, 'Defensive midfielder', 'Receive, turn and drive forward'),
    (3, 'LCM / RCM', 'Occupy their midfielders')
) AS v(so, role, job);

-- 14. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 2: 1.3 Indirect Pass into Midfield Using a Link Player (2 forwards)', 'Link player bounces to DM',
    'When the opponent blocks the direct pass to the defensive midfielder, the centre back passes to the RCM at the top of the rhombus, who plays a one-touch pass on to the DM. If that lane is shut, the centre back plays back to the keeper.',
    'Lane to the defensive midfielder blocked',
    'Reach the free DM indirectly and avoid the press.',
    NULL, 30, 30, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (RCB)', 'Pass to the link player, or back to the keeper'),
    (2, 'RCM (link player)', 'Lay off one touch to the DM'),
    (3, 'Defensive midfielder', 'Receive free and advance'),
    (4, 'Goalkeeper', 'Safety outlet')
) AS v(so, role, job);

-- 15. pp.31-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 2: Using a Link Player Against 1 Forward', 'Draw a midfielder, link to free CM',
    'Against five midfielders and one striker, the centre back carries the ball to make an opposing midfielder step out of their line to press. A link player then passes to the teammate that midfielder left. Option 1: the DM links to the unmarked LCM. Option 2: the forward drops and links to the LCM.',
    'An opposing midfielder leaves his line to press the advancing centre back',
    'The freed central midfielder receives behind their midfield line, turns and progresses.',
    '4-5-1', 31, 32, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (LCB)', 'Carry the ball to draw a midfielder out'),
    (2, 'DM or Forward (link player)', 'Receive and set the ball to the free man'),
    (3, 'LCM', 'Stay free behind the pressing midfielder and turn')
) AS v(so, role, job);

-- 16. pp.33-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 2: 2. Build Up vs Forwards & Midfield Press (No Space in Behind)', 'Winger drops between lines vs 4-5-1',
    'Their forwards and midfielders press high but the back line stays deep, so there is no space behind. When our DM, RCM and RB are all marked tightly, the free centre back passes through the midfield line to the RW, who comes inside and drops between the lines.',
    'Near-side midfielders and full back tightly marked; deep back line',
    'The winger receives and turns between the lines, which the opponent cannot mark.',
    '4-5-1', 33, 34, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (RCB)', 'Carry the ball free and pass through the midfield line'),
    (2, 'Right winger', 'Come inside and drop off between the lines'),
    (3, 'DM / RCM / RB', 'Hold their markers')
) AS v(so, role, job);

-- 17. pp.35-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 2: Passing Through the Midfield Line Against the 4-3-1-2', 'Full back finds dropping winger',
    'Against a 4-3-1-2, the ball is with the right back, so the opponent has shifted across to that side. The right winger drops off and the full back passes into him to receive in space and turn.',
    'Opponent shifts toward our full back on the ball',
    'Play through the midfield line on the flank.',
    '4-3-1-2', 35, 35, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Pass into the dropping winger'),
    (2, 'Right winger', 'Drop off, receive and turn')
) AS v(so, role, job);

-- 18. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 2: 3. Direct Build Up vs Full Team Press (Space in Behind)', 'Diretta: long ball behind high line',
    'When the whole opponent presses after a short start, even with defenders anticipating passes, and their back line is near halfway, go direct. The full back plays long into the space behind the line for the winger, who checks away from his marker and then runs deep.',
    'All-out press with a high back line',
    'Exploit the space in the opponent''s half straight away. The author notes direct play stretches our own team and costs energy.',
    NULL, 37, 37, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (RB)', 'Long pass behind the defensive line'),
    (2, 'Right winger', 'Check away, then run in behind'),
    (3, 'Forward', 'Occupy the centre backs')
) AS v(so, role, job);

-- 19. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 2: Forward / Winger as a Link Player (Direct)', 'Link player sets direct runner free',
    'Two variations of the direct route. The forward takes the long pass and flicks it on for the right winger running behind, and the winger times his run to it. Or the left winger moves inside to take a long pass from the centre back and plays the forward in behind the line.',
    'Full-team press; direct pass to the runner not on',
    'Release a runner behind the high line using one intermediate player.',
    NULL, 38, 38, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Link player who sets the winger free, or the runner in behind'),
    (2, 'Winger', 'Time the run behind, or come inside as the link'),
    (3, 'Back line', 'Play the long pass into the link')
) AS v(so, role, job);

-- 20. pp.41-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 3: Build Up Play Against the 4-4-2', 'Beat two strikers via free DM',
    'Against a 4-4-2, use the free man in the centre: the centre back passes from zone A2 to the defensive midfielder in B2, who receives facing forward. The DM''s options: pass in front of the midfield line (closest CM, or wide to a full back if they defend deep), play between the lines (to a CM who has run beyond their midfield, or to the winger''s feet), go long behind for the forward when a gap opens, or restart by passing back to a centre back or the keeper.',
    'Two strikers press, DM free in B2',
    'Get past the first line, then pick the route the opponent''s reaction leaves open.',
    '4-4-2', 41, 42, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (RCB)', 'Pass into B2'),
    (2, 'Defensive midfielder', 'Receive facing forward and choose the route'),
    (3, 'Central midfielders', 'Offer short or make runs beyond their midfield line'),
    (4, 'Forward', 'Threaten the space behind')
) AS v(so, role, job);

-- 21. pp.43-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 3: Pass in Front of the Midfield Line (vs 4-4-2)', 'Deep block: DM switches to the flank',
    'If the 4-4-2 drops into its own half and closes the gap between midfield and defence, the defensive midfielder plays out to a flank, usually to the full back or winger, whichever has a clear lane. Or he plays short to the closest central midfielder.',
    'Opponent drops back and defends deep',
    'Move the ball wide around a compact block.',
    '4-4-2', 43, 43, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Switch to the free flank player or play short'),
    (2, 'Full back / winger', 'Offer a wide passing lane'),
    (3, 'LCM', 'Close short option')
) AS v(so, role, job);

-- 22. pp.44-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 3: Playing Between the Lines (vs 4-4-2)', 'Rhombus beats the midfield press',
    'When the 4-4-2 presses our defensive midfielder, the central midfielders move in opposite directions to form a rhombus. The RCM runs beyond their midfield line (his marker has left to press the DM), the LCM drops close, and the forward is the front support. The DM plays to the LCM, who acts as link player to the free RCM. If the LCM is pressed, the forward lays off to the RCM. Or the DM passes to a winger if their wide man is out of position.',
    'Opposing central midfielder leaves his man to press the DM',
    'Get the ball to the RCM free between the lines.',
    '4-4-2', 44, 44, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Carry the ball, attract the press, find the link'),
    (2, 'RCM', 'Run forward beyond their midfield line'),
    (3, 'LCM (link player)', 'Drop short and pass on quickly'),
    (4, 'Forward', 'Front support; alternative link'),
    (5, 'Wingers', 'Wide option')
) AS v(so, role, job);

-- 23. pp.45-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 3: Long Pass in Behind the Defensive Line (vs 4-4-2)', 'CB steps out, ball in behind',
    'When an opposing centre back steps up to mark our RCM between the lines, that option is gone but a gap opens in their back line. The defensive midfielder plays long into the gap for the forward to run onto.',
    'Opposing centre back leaves the line to follow our midfielder',
    'A well-timed pass and run can put the forward 1v1 with the keeper.',
    '4-4-2', 45, 45, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Long pass into the gap'),
    (2, 'Forward', 'Time the run into the space the centre back left'),
    (3, 'RCM', 'Pull the centre back out')
) AS v(so, role, job);

-- 24. pp.47-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 3: Build Up Play Against the 4-4-1-1 or 4-2-3-1', 'Centre back dribbles out vs striker + No.10',
    'The opponent''s striker and No.10 mark our LCB and defensive midfielder. The other centre back has the 2v1 and dribbles from zone A2 into B2, while the DM drops to cover his spot. The centre back''s options: pass in front of the midfield line (opposite CM or same-side full back), play between the lines (CM who runs beyond their midfield, helped by the winger and the other CM), go long behind for the forward, or restart backwards.',
    'Lone striker + No.10 on the DM; one centre back free',
    'Carry past the first line, then read their reaction.',
    '4-4-1-1', 47, 47, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free centre back (RCB)', 'Dribble forward into B2'),
    (2, 'Defensive midfielder', 'Drop to cover the centre back''s position'),
    (3, 'Central midfielders + winger', 'Give options in front of and between the lines'),
    (4, 'Forward', 'Threaten in behind')
) AS v(so, role, job);

-- 25. pp.48-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 3: Pass in Front of the Midfield Line (vs 4-4-1-1)', 'Carrying CB switches wide vs deep block',
    'After the centre back dribbles out, if the 4-4-1-1 drops back to tighten its lines, he passes to the flank, usually the right back or winger, depending on the free lane. Or he plays short to the near central midfielder.',
    'Opponent drops back and defends deep',
    'Move around a compact block through the wide players.',
    '4-4-1-1', 48, 48, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (RCB)', 'Pass wide or short after dribbling out'),
    (2, 'RB / RW', 'Hold width for the pass'),
    (3, 'RCM', 'Short option')
) AS v(so, role, job);

-- 26. pp.49-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 3: Playing Between the Lines (vs 4-4-1-1)', 'RCM beyond line, side supports link',
    'As the centre back dribbles, the RCM runs beyond their midfield line as the front of the rhombus, and the LCM and RW move inside as the side supports. When their central midfielder steps out to press, the ball goes to the RCM directly or through a side support (LCM or RW) acting as link player. Otherwise the right back stays wide as an extra option.',
    'Opposing central midfielder steps up to press the ball',
    'Get the RCM the ball free behind their midfield line.',
    '4-4-1-1', 49, 49, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (RCB)', 'Dribble, then pass to the RCM or a link'),
    (2, 'RCM', 'Front support beyond the midfield line'),
    (3, 'LCM + RW', 'Move inside as side supports / link players'),
    (4, 'Right back', 'Stay wide as an outlet')
) AS v(so, role, job);

-- 27. pp.50-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Chapter 3: Long Pass in Behind the Defensive Line (vs 4-4-1-1)', 'Gap behind stepping CB, RCB goes long',
    'When an opposing centre back steps up to mark our RCM, their back line has a gap. Our dribbling centre back plays long into it for the forward to run onto.',
    'Opposing centre back steps out of the line',
    'Put the forward in behind, possibly 1v1 with the keeper.',
    '4-4-1-1', 50, 50, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (RCB)', 'Long pass into the gap'),
    (2, 'Forward', 'Run into the space behind'),
    (3, 'RCM', 'Draw the centre back out')
) AS v(so, role, job);

-- 28. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 4-3-1-2', 'Full back first: receive free out wide',
    'The diamond has no wide players and their No.10 sits on our DM, so the build-up is steered to the full back, who has space on the flank and then chooses between a 1-2 inside, a long ball in behind, a switch, or recycling to CB/GK.',
    'Opponent in narrow diamond, No.10 marking our DM',
    'Start the attack from the free full back with several options around him',
    '4-3-1-2', 52, 52, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back', 'Plays out to the right back'),
    (2, 'Right back', 'Receives wide in space and picks the option'),
    (3, 'Defensive midfielder', 'Marked by No.10; available for a 1-2'),
    (4, 'Centre backs / GK', 'Back outlet to restart')
) AS v(so, role, job);

-- 29. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 4-3-1-2', 'Rhombus round full back: 1-2 with DM frees LCM',
    'With the full back on the ball, a support rhombus forms: near CM goes beyond their midfield line as front support, DM comes close as side support, CB behind. Because the No.10 marks the DM, the full back plays a quick 1-2 with him and then passes inside to the far CM, free in the middle.',
    'Full back on ball, DM marked by No.10',
    'Move the ball in front of their midfield line to the unmarked far central midfielder',
    '4-3-1-2', 53, 53, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Plays 1-2 with DM, then passes to LCM'),
    (2, 'Right central midfielder', 'Pushes beyond their midfield line as front support'),
    (3, 'Defensive midfielder', 'Close side support; returns the wall pass then steps forward to open the lane'),
    (4, 'Right centre back', 'Back support at base of rhombus'),
    (5, 'Left central midfielder', 'Receives unmarked in the centre'),
    (6, 'Right winger', 'Drops off to make their full back choose; new rhombus if left free')
) AS v(so, role, job);

-- 30. pp.54-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 4-3-1-2', 'Winger cuts in, CB follows: long ball in behind',
    'The RCM goes wide and the winger cuts inside as front support, while the forward stays high on the defensive line to stretch it. If their full back stays and their centre back steps out to mark the inside winger, a gap opens and the full back plays long in behind for the forward.',
    'Opposing centre back steps out to mark our inward-cutting winger',
    '1 v 1 run on goal for the forward through the vacated gap',
    '4-3-1-2', 54, 54, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder', 'Swaps out wide, drags their full back'),
    (2, 'Right winger', 'Cuts inside to front support position'),
    (3, 'Forward', 'Holds high on the line, attacks the gap behind'),
    (4, 'Right back', 'Plays the long ball in behind (Plan B to short build-up)')
) AS v(so, role, job);

-- 31. pp.55-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 4-3-1-2', 'CB holds, winger marked: switch to weak side',
    'If their centre back stays put and their CM shuffles across onto our winger, neither the ball in behind nor the entry pass to the winger is on. The full back plays the 1-2 with the DM, the LCM receives free centrally and switches to the left back, who dribbles into space on the weak side.',
    'Entry ball to winger blocked, opposing CB stays in line',
    'Wide attack on the weak side via a free left back',
    '4-3-1-2', 55, 55, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', '1-2 with DM, steps back to receive'),
    (2, 'Defensive midfielder', 'Wall pass then edges forward to open lane'),
    (3, 'Left central midfielder', 'Receives free and plays the switch'),
    (4, 'Left back', 'Receives wide and dribbles forward')
) AS v(so, role, job);

-- 32. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 4-3-3', 'Centre back dribbles out with 2v1',
    'Against a 4-3-3 our two centre backs outnumber the lone forward, so one CB simply carries the ball out from the first zone into midfield. His options then: short to DM/CM, switch via the DM, play to the forward as link, or recycle to full back/GK.',
    'Opponent leaves only one forward on our two CBs',
    'Advance with a spare player and draw a midfielder out',
    '4-3-3', 57, 57, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back', 'Dribbles forward into midfield'),
    (2, 'Left centre back', 'Covers, forms the 2v1'),
    (3, 'Full back', 'Same-side outlet if their winger tucks in to block'),
    (4, 'Goalkeeper', 'Back outlet away from the forward')
) AS v(so, role, job);

-- 33. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 4-3-3', 'Opposing CM jumps alone: pass either side of him',
    'When an opposing CM steps up to press the dribbling CB without help from teammates, two short lanes open: inside of him to the DM or outside of him to the RCM, or a combination with the DM to reach the LCM. Four opponents are then behind the ball.',
    'A single opposing central midfielder presses our carrying CB unsupported',
    'Play short past the presser and attack with several opponents bypassed',
    '4-3-3', 58, 58, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back', 'Carries, then picks the free side of the presser'),
    (2, 'Defensive midfielder', 'Free in the centre to the presser''s left'),
    (3, 'Right central midfielder', 'Free to the presser''s right'),
    (4, 'Left central midfielder', 'Third option via DM')
) AS v(so, role, job);

-- 34. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 4-3-3', 'Deep compact block: DM switch and flank rotation',
    'If they drop into their own half and stay compact, the CB finds the DM in space and the attack is developed on the opposite flank. Before the switch the LCM, LB and LW rotate to shake off markers, with the winger moving inside to receive between the lines.',
    'Opponent withdraws and defends deep and compact',
    'Develop the attack on the flank opposite to the ball with a free receiver',
    '4-3-3', 59, 59, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back', 'Passes into DM'),
    (2, 'Defensive midfielder', 'Turns and switches play'),
    (3, 'Left winger', 'Moves inside between midfield and defensive lines to receive'),
    (4, 'Left back / Left central midfielder', 'Rotate with the winger to create space')
) AS v(so, role, job);

-- 35. pp.60-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 4-3-3', 'Aggressive press: forward as link player to RCM',
    'When their LCM presses our CB, their DM marks our DM and their winger tucks in to cut the lane to the RCM, the space between their lines opens. The CB plays to the forward who drops; though marked, he lays it back to the RCM arriving beyond their midfield line.',
    'Three opponents press aggressively and short options are blocked',
    'RCM receives between the lines facing forward',
    '4-3-3', 60, 60, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back', 'Plays straight into the dropping forward'),
    (2, 'Forward', 'Drops off, link player, lays off first time'),
    (3, 'Right central midfielder', 'Runs forward to receive the lay-off between lines'),
    (4, 'Defensive midfielder', 'Pins their DM')
) AS v(so, role, job);

-- 36. pp.62-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 3-4-3', 'Exploit zone superiorities vs unadjusted 3-4-3',
    'If a 3-4-3 does not adapt, we have 2v1 at the back (a CB can always step in with the ball), 3v2 in central midfield (a spare man always free) and 3v3 up front, where a long ball can set up 1 v 1s.',
    'Opponent stays in 3-4-3 shape',
    'Build through numerical superiority or go long into the 3v3',
    '3-4-3', 62, 62, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', '2v1 vs lone forward; one carries forward'),
    (2, 'DM + two CMs', '3v2 in midfield, find the spare man'),
    (3, 'Wingers and forward', '3v3 vs back three, target of long passes')
) AS v(so, role, job);

-- 37. pp.63-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 3-4-3', '3-4-3 drops a wide man to back four: lose the 1v1s',
    'A classic fix: one wide midfielder drops to make a back four (4v3 against our front line) and the other tucks inside to equalise central midfield 3v3. Long balls into the front three are no longer worth it, so the team uses its 4-3-3-vs-4-3-3 build-up patterns.',
    'Opponent changes from 3-4-3 to a 4-3-3 defensive shape',
    'Recognise the change and switch to short build-up patterns used vs 4-3-3',
    '3-4-3', 63, 63, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Still 2v1 at the back, keep building short'),
    (2, 'Front three', 'Now outnumbered 3v4, avoid isolated long balls'),
    (3, 'Midfield three', 'Now 3v3, use rotations and link players')
) AS v(so, role, job);

-- 38. pp.64-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 3-4-3', 'Man-for-man high press: GK makes 5v4, go long to 3v3',
    'The 3-4-3 becomes a 3-4-2-1 with both wingers moving in and wide mids pushing onto our full backs, giving 4v4 at the back and man marking in midfield. We bring the GK in to get 5v4, then he looks long or plays entry balls to the front three, who then face 1 v 1s in a 3v3.',
    'Opponent shifts to 3-4-2-1 and presses aggressively man to man',
    'Escape the press via the keeper and attack 3v3 in their half',
    '3-4-2-1', 64, 64, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Extra man in build-up; plays long or entry balls'),
    (2, 'Right back', 'Under pressure, plays back to GK'),
    (3, 'Front three', 'Hold width and height for 1 v 1s in the 3v3')
) AS v(so, role, job);

-- 39. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 3-5-2', 'Wing backs push onto full backs: back to GK, long to front three',
    'If both wing backs jump high to mark our full backs it is 4v4 at the back, which is dangerous. The pressed full back passes back to the keeper at the edge of the box (5v4), and the keeper goes long to exploit 3v3 against their back three.',
    'Opposing wing backs press our full backs high',
    'Bypass the press and isolate attackers 1 v 1',
    '3-5-2', 66, 66, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Under wing-back pressure, plays back to GK'),
    (2, 'Goalkeeper', 'Creates 5v4, plays long pass'),
    (3, 'Wingers and forward', 'Attack 3v3, look for 1 v 1')
) AS v(so, role, job);

-- 40. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 3-5-2', 'One wing back drops to back four: find free far full back',
    'When one wing back presses our ball-side full back but the other drops to make a back four, our far full back is left free. The pressed RB plays to the GK, who passes wide to the LB, who dribbles forward and then chooses between playing between the lines or long in behind.',
    'Far opposing wing back drops into a back four',
    'Free far full back carries the ball forward',
    '3-5-2', 67, 67, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Plays back to keeper under pressure'),
    (2, 'Goalkeeper', 'Switches out wide to the left back'),
    (3, 'Left back', 'Receives unmarked, dribbles into space')
) AS v(so, role, job);

-- 41. pp.68-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 3-5-2', 'LB carries: between lines depending on wing back',
    'As the LB dribbles forward their CM goes out to close him. LCM pushes beyond their midfield as front support, DM gives side support, LW drops as other side support. If their wing back does not follow LW, LB plays forward to him between the lines; if he follows, LB plays inside to DM who finds LCM between the lines.',
    'Opposing CM leaves position to press the carrying left back',
    'Reach a 4v4 between the lines with a free receiver',
    '3-5-2', 68, 68, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back', 'Dribbles in, reads whether wing back follows LW'),
    (2, 'Left winger', 'Drops back to force the wing back''s choice'),
    (3, 'Left central midfielder', 'Front support beyond their midfield line'),
    (4, 'Defensive midfielder', 'Side support, links to LCM')
) AS v(so, role, job);

-- 42. pp.69-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 3-5-2', 'All four near ball press: long in behind for forward',
    'The forward does not come towards the ball; he keeps their defenders occupied so they cannot squeeze our LCM. When the four nearest opponents mark all short options (their CB steps onto LCM, DM marked, wing back on LW), a gap opens in their back line and the LB plays long in behind for the forward.',
    'Aggressive press marks every nearby receiver and a CB steps out',
    '1 v 1 with the keeper through the gap left by the stepping CB',
    '3-5-2', 69, 69, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Stays high to pin defenders, then runs in behind'),
    (2, 'Left back', 'Plays the long ball into the gap'),
    (3, 'Left central midfielder', 'Drags their CB forward'),
    (4, 'Left winger', 'Holds their wing back')
) AS v(so, role, job);

-- 43. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / vs 3-5-2', 'Their DM drops to make back four: CB free 2v1',
    'Variation where their DM drops into a back four, turning the 3-5-2 into a 4-2-3-1 defensively. Our CBs now have 2v1 against the lone forward, so one receives (via the GK if needed) and dribbles forward, then we use the patterns for 4-4-1-1/4-2-3-1 and 4-3-3.',
    'Opposing DM drops into the defensive line',
    'Advance via the free centre back',
    '3-5-2', 70, 70, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back', 'Receives in space and dribbles forward'),
    (2, 'Goalkeeper', 'Links CB to CB around the forward'),
    (3, 'Right back / Right centre back', 'Recycle when pressed')
) AS v(so, role, job);

-- 44. pp.72-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Build Up Play Against Different Formations / Practice examples for build up play', 'Keeper picks distribution by opponent shape; midfielder drops for +1',
    'In the practices the keeper reads the opposition shape and distributes to the spare man: vs 2 forwards the DM drops so we build in a 3-4 shape, vs a 3-3 the LCM drops to make 4v3; the team then plays through the lines into the high zone or past halfway. A positional end-to-end game with two neutral CMs trains keeping the ball and moving it keeper to keeper in the 4-3-3.',
    'Goal kick/keeper in possession against a set press',
    'Create a numerical advantage at the back and move through the lines',
    NULL, 72, 74, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Reads shape, finds the free player'),
    (2, 'Defensive midfielder', 'Drops between CBs vs two forwards'),
    (3, 'Left central midfielder', 'Drops deep vs a front three'),
    (4, 'Back four', 'Spread to give the keeper options')
) AS v(so, role, job);

-- 45. pp.76-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase', 'Creating phase: get ball between the lines via weak-side switch',
    'With the opponent set in a mid block (4-1-4-1 or 4-4-1-1, nearly all behind the ball) the aim is to place the ball between their midfield and defensive lines, by dribbling or passing. Patient circulation forces their compact unit to shift to one zone, then quick accurate passing switches to the weak side to find space and break gaps between players.',
    'Opponent organised in compact mid block in own half',
    'Open a gap and play in between midfield and defensive lines to start accelerating',
    NULL, 76, 78, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield three', 'Circulate to draw the block to one side'),
    (2, 'Full backs and wingers', 'Hold width to receive the switch'),
    (3, 'Ball carrier', 'Dribble or pass forward once a gap opens')
) AS v(so, role, job);

-- 46. pp.79-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 1.1 Passing options for the ball carrier', 'Six support options around the carrier',
    'Players are trained to give the ball carrier (example: DM) six solutions at once: entry ball forward to the forward (imbucata), lateral support, front support, back support, a long switch to a free player, and a reset pass back.',
    'Any midfielder receiving in the creating zone',
    'Ball carrier always has forward, side, back and switch options',
    NULL, 79, 79, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Entry ball target'),
    (2, 'Near central midfielder', 'Lateral support'),
    (3, 'Other central midfielder', 'Front support'),
    (4, 'Full back', 'Back support'),
    (5, 'Far winger', 'Free target for the switch'),
    (6, 'Centre back', 'Pass back to reset')
) AS v(so, role, job);

-- 47. pp.80-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 1.2 Tactical grids: passing patterns to switch', 'Rhombus switch: CM goes wide, DM opens up',
    'From a right-side rhombus with the right back on the ball, the RCM moves wide and drags his marker, opening a lane to the DM, who opens up and switches to the left back or left winger. Requirement: play beyond the nearest teammate, with the forward as front support.',
    'Close central receiver marked, opponent well organised',
    'Switch to the free weak-side flank through the centre',
    NULL, 80, 81, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Plays inside past the RCM to the DM'),
    (2, 'Right central midfielder', 'Moves wide to drag his marker'),
    (3, 'Forward', 'Front support at top of rhombus'),
    (4, 'Defensive midfielder', 'Receives, opens body and switches'),
    (5, 'Left winger / Left back', 'Weak-side receivers')
) AS v(so, role, job);

-- 48. pp.81-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 1.2 Tactical grids', 'Weak-side winger inside, full back high',
    'In every switch pattern a second weak-side version exists: the left winger comes inside to receive a forward pass in the centre and pulls their full back with him, freeing our left back to push high and take the switch closer to goal.',
    'Ball being switched to the weak side',
    'Left back receives the switch high up the pitch, closer to goal',
    NULL, 81, 87, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger', 'Moves inside, drags opposing full back'),
    (2, 'Left back', 'Advances into the freed lane to receive'),
    (3, 'Switching midfielder', 'Chooses winger or full back')
) AS v(so, role, job);

-- 49. pp.82-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 1.2 Tactical grids', 'Winger as front support link for the switch',
    'The RCM stays marked, so the right winger comes inside and back to the top of the rhombus. The right back plays into him, he lays it first time to the DM, who switches to the left side.',
    'RCM marked, lane to DM not direct',
    'Reach the DM indirectly and switch play',
    NULL, 82, 82, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger', 'Moves inside to front support, one-touch lay-off to DM'),
    (2, 'Right back', 'Passes forward into winger'),
    (3, 'Defensive midfielder', 'Receives and switches'),
    (4, 'Left winger / Left back', 'Receive on the weak side')
) AS v(so, role, job);

-- 50. pp.83-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 1.2 Tactical grids', 'RCM to front support, DM fills, LCM switches',
    'The RCM pushes up to the top of the rhombus as front support and the DM shifts into the space he left. The right back plays into the RCM as link player, who passes into the centre for the LCM, who has come inside, to switch to the left flank. Midfielders rotate without the ball as the pattern develops.',
    'Wide winger not available as front support',
    'LCM receives centrally and switches',
    NULL, 83, 83, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder', 'Front support, link pass inside'),
    (2, 'Defensive midfielder', 'Moves into the RCM''s vacated space'),
    (3, 'Left central midfielder', 'Comes inside to receive and switch'),
    (4, 'Right back', 'Passes into the RCM')
) AS v(so, role, job);

-- 51. pp.84-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 1.2 Tactical grids', 'Front support blocked: 1-2 to unlock the centre',
    'When the lane to the front support is blocked, the right back plays a 1-2 with a nearby midfielder and steps away from his marker to get the return; a teammate edges forward to open the lane. In one version the 1-2 is with the RCM then inside to the DM; in another the RCM goes top and the 1-2 is with the tightly marked DM, then inside to the LCM, who moves across and switches.',
    'Forward pass to front support cut off by an opponent',
    'Wall pass frees a central receiver who switches play',
    NULL, 84, 85, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Plays 1-2 and moves off his marker'),
    (2, 'Right central midfielder', 'Wall player or moves to top of rhombus'),
    (3, 'Defensive midfielder', 'Wall player or central receiver'),
    (4, 'Left central midfielder', 'Moves across, receives and switches')
) AS v(so, role, job);

-- 52. pp.85-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 1.2 Tactical grids', 'Centre back as back support to reach centre',
    'When the front support and the RCM are both blocked, the right back uses the RCB behind him as back support; the CB passes into the DM (or into the LCM if the DM has moved wide and is occupying a marker), who receives in space and switches.',
    'Front and side lanes from the full back blocked',
    'Go back to go through the centre and switch',
    NULL, 85, 87, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Plays back to RCB'),
    (2, 'Right centre back', 'Back support, passes into the centre'),
    (3, 'Defensive midfielder', 'Receives, or moves wide to occupy a marker'),
    (4, 'Left central midfielder', 'Moves into DM''s spot to receive and switch')
) AS v(so, role, job);

-- 53. pp.88-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 1.3 Rotations without the ball', 'Full back, CM and winger rotate with CB on ball',
    'With a centre back in possession, the right back, RCM and right winger swap positions in a three-man rotation (anti-clockwise or clockwise) to unsettle their markers, so one or two of them come free to receive from the CB. Mirrored on the left.',
    'Centre back on the ball, flank players marked',
    'Destabilise markers to create one or two free receivers',
    NULL, 88, 89, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Rotates into a new position'),
    (2, 'Right central midfielder', 'Rotates, aims to lose his marker'),
    (3, 'Right winger', 'Rotates, aims to lose his marker'),
    (4, 'Right centre back', 'Passes to whoever comes free')
) AS v(so, role, job);

-- 54. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 1.3 Rotations without the ball', 'Midfield three rotate with CB on ball',
    'With a centre back in possession, the DM and both central midfielders swap positions in a clockwise or anti-clockwise rotation so at least one loses his marker and receives from the CB.',
    'Centre back on the ball, central midfielders marked',
    'Free a central midfielder to receive',
    NULL, 89, 89, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Rotates with the CMs'),
    (2, 'Left / Right central midfielders', 'Rotate, break away from markers'),
    (3, 'Centre back', 'Passes to the free midfielder')
) AS v(so, role, job);

-- 55. pp.90-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 1.3 Rotations without the ball', 'CM, winger and forward rotate with full back on ball',
    'With the right back on the ball, the RCM, right winger and forward swap positions anti-clockwise so one or two get away from their markers and receive from the full back. Mirrored on the left.',
    'Full back on the ball, front players marked',
    'Create a free receiver high on the ball side',
    NULL, 90, 90, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Passes to the freed player'),
    (2, 'Right central midfielder', 'Rotates forward'),
    (3, 'Right winger', 'Rotates inside'),
    (4, 'Forward', 'Rotates wide/back')
) AS v(so, role, job);

-- 56. pp.91-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 1.4 Rotations in the centre with the ball', 'One-touch central rotations then out wide',
    'With the ball already among the DM, LCM and RCM, they exchange quick one-touch passes (simple chains, 1-2s, extra passes depending on a pressing opponent) while rotating positions, drawing opponents into the centre; then the DM, free again, plays out to the open flank (left back), helped by the LW moving inside to clear space.',
    'Ball in central midfield trio, opponents drawn in',
    'Pull opponents into the centre then exploit the free flank',
    NULL, 91, 93, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left central midfielder', 'Starts combinations, plays 1-2 with RCM'),
    (2, 'Right central midfielder', 'Wall player, rotates'),
    (3, 'Defensive midfielder', 'Moves across, receives free and plays wide'),
    (4, 'Left winger', 'Moves inside to clear the flank'),
    (5, 'Left back', 'Receives in space wide')
) AS v(so, role, job);

-- 57. pp.95-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 2 Accelerating the attack', 'Accelerating: opening, entry ball or dribble forward',
    'Once the ball can be played between the lines the game changes from patient circulation to attacking their back line in the final third, through one of three routes: an opening to a flank player on the weak side, an entry ball (imbucata), or a player dribbling forward.',
    'Conditions created to play between their lines',
    'Move quickly from the creating zone to the finishing zone',
    NULL, 95, 95, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Flank players', 'Receive the opening on the weak side'),
    (2, 'Forward', 'Target for entry ball'),
    (3, 'Midfielder in possession', 'Choose pass or dribble forward')
) AS v(so, role, job);

-- 58. pp.96-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 2.2 Imbucata (entry ball)', 'Imbucata to midfielder: turn if free, link if marked',
    'A central midfielder who moved up between the lines receives the entry ball. With time and space he turns, moves forward and tries to finish the move; if he is marked with his back to goal he does not try to turn but acts as link player and plays back to a free teammate (DM).',
    'Entry pass to a midfielder between the lines',
    'Keep the attack going without losing possession',
    NULL, 96, 97, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder', 'Turns if free; lays off if marked'),
    (2, 'Defensive midfielder', 'Free option for the lay-off'),
    (3, 'Right back', 'Plays the entry ball')
) AS v(so, role, job);

-- 59. pp.96-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 2.2 Imbucata (entry ball)', 'Imbucata to forward with support runs',
    'A forward pass (usually on the ground) through their midfield to the forward, who receives with his back to goal; teammates must support him: e.g. RCM pushes between the lines to take the lay-off and plays a 1-2 in behind for the forward. Same idea with a winger who comes inside off the flank. Without support the ball is usually lost.',
    'Lane open to the forward between the lines',
    'Forward lays off to a supporting runner then attacks space in behind',
    NULL, 96, 98, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Receives back to goal, lays off, runs in behind'),
    (2, 'Right central midfielder', 'Arrives between lines for lay-off, plays it in behind'),
    (3, 'Right back', 'Plays the entry ball'),
    (4, 'Winger', 'Alternative target, cutting inside')
) AS v(so, role, job);

-- 60. pp.98-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 The Creating Phase / 2.3 Dribbling the ball forward', 'Dribble up to their back line, then final ball',
    'A midfielder or winger (centrally or wide) dribbles past their midfield line up to the front of the defensive line, helped by teammates stretching the space between opposing midfielders, then plays a final pass in behind. If the dribble does not break in, keep the ball and go back to the creating process instead of forcing it.',
    'Space opens between opposing midfielders',
    'Arrive in front of the defensive line to play in behind',
    NULL, 98, 98, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder', 'Dribbles forward to their defensive line'),
    (2, 'Forward', 'Runs in behind for the final pass'),
    (3, 'Teammates', 'Stretch distances between opposing midfielders')
) AS v(so, role, job);

-- 61. pp.101-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 Practice Examples for the Creating Phase', 'Forward shows between lines for entry pass',
    'Back line and midfield circulate the ball looking for a free lane into the lone forward positioned behind the opponent''s midfield line; the forward receives, controls and sets the ball back, then the team can attack through the centre.',
    'Lane opens past the opponent''s midfielders',
    'Bypass the midfield line with a vertical pass and keep the ball.',
    NULL, 101, 103, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Keep moving sideways to open a line, receive behind midfield, lay back'),
    (2, 'Central midfielders', 'Circulate to shift the block and find the gap'),
    (3, 'Centre backs', 'Restart circulation after the lay-back'),
    (4, 'Full backs', 'Hold width to stretch the midfield line')
) AS v(so, role, job);

-- 62. pp.101-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'to_attack', 'Ch4 Practice Examples for the Creating Phase', 'Regain and carry forward fast',
    'Defending midfield block that wins the ball immediately drives it forward past halfway (or into the next zone) instead of slowing down, catching the attacking team unbalanced.',
    'Ball won by press or interception',
    'Turn a regain into a fast counter before the opponent reorganises.',
    NULL, 101, 105, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Regaining midfielder', 'Carry the ball forward immediately'),
    (2, 'Nearest teammates', 'Support the carrier on both sides'),
    (3, 'Forward', 'Offer depth for an early forward pass')
) AS v(so, role, job);

-- 63. pp.102-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 Practice Examples for the Creating Phase', 'Secure possession then quick attack in behind',
    'Team first strings together a run of passes (6-8) in the build zone, then switches tempo and attacks the space behind the defence with one-touch play.',
    'Possession secured after a set number of passes',
    'Combine control with a sudden fast attack before the defence resets.',
    NULL, 102, 102, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield three', 'Circulate with width players to complete the pass sequence'),
    (2, 'Wingers', 'Run in behind once the attack is released'),
    (3, 'Centre forward', 'Attack the goal at speed with one-touch finishes')
) AS v(so, role, job);

-- 64. pp.104-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch4 Practice Examples for the Creating Phase', 'Entry to winger or forward behind midfield, then finish',
    'Ball is moved through the back and midfield to a winger or the forward positioned behind the opposition midfield; after the set-back the team finishes either by finding the far winger who feeds the box, or by the forward laying off to an oncoming midfielder who chooses centre or flank. Example opponent is a 4-4-2 but adaptable.',
    'Free receiver behind midfield line; full back to winger direct pass not allowed in the drill',
    'Exploit width and depth to finish through set combinations.',
    NULL, 104, 106, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'Hold width high, receive behind midfield; far winger feeds the box'),
    (2, 'Centre forward', 'Receive and lay off to the running midfielder'),
    (3, 'Central midfielders', 'Arrive from deep onto the lay-off, choose centre or wide'),
    (4, 'Full backs', 'Circulate the ball wide but play inside rather than straight down the line')
) AS v(so, role, job);

-- 65. pp.108-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 The Finishing Phase', 'Three ways to finish an attack',
    'Final-third principle: an attack ends either around the defence from the flank with a cross, through it with a final pass or dribble through the centre, or with a shot from outside the box by a technically strong shooter.',
    'Ball reaches the final third',
    'Players choose the finishing route the situation allows.',
    NULL, 108, 112, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players', 'Go around the defence and cross'),
    (2, 'Central players', 'Play the final pass or dribble through'),
    (3, 'Arriving midfielder', 'Shoot from outside the area when space allows')
) AS v(so, role, job);

-- 66. pp.109-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 Conditions and Situations for Finishing', 'Open ball situation triggers runs',
    'When the ball carrier is unpressed and facing forward (''open ball''), teammates time runs in behind; a frontal open ball feeds a through pass for a runner, while a back-to-goal receiver uses a deflecting touch or lay-off for a runner or an arriving teammate. A general open ball far from goal is just a possession moment, not an assist moment.',
    'Carrier has time and no immediate pressure near the box',
    'Convert freedom on the ball into a final pass for a shot.',
    NULL, 109, 109, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Read pressure; play the final pass when open'),
    (2, 'Forwards', 'Time runs off markers in behind the line'),
    (3, 'Back-to-goal forward', 'Deflect or lay off for runners')
) AS v(so, role, job);

-- 67. pp.110-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 The Finishing Phase: Tactical Contexts', 'Defence drops: push up, then show short',
    'When the opponent''s line retreats as soon as space appears behind it, forwards first move up to force it deeper, then come back in front of the line close to their box to receive (especially when a defender steps to the ball carrier), and from there play a through ball or shoot.',
    'Opposing line retreats with an open ball',
    'Receive in front of a deep line where through balls and shots become possible.',
    NULL, 110, 110, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Push line back, then drop short in front of it'),
    (2, 'Ball carrier', 'Find the forward before the pressure arrives'),
    (3, 'Runners', 'Run behind once the forward receives')
) AS v(so, role, job);

-- 68. pp.110-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 The Finishing Phase: Tactical Contexts', 'Closed ball near the line: combine, don''t run',
    'If the carrier is pressed or receivers are too tightly marked close to the defensive line (closed ball), teammates stop running in behind, come close for a give-and-go to turn it into an open ball, or keep possession and restart.',
    'Pressure on carrier blocks the final pass',
    'Turn a closed ball into an open one or keep the ball.',
    NULL, 110, 110, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest teammates', 'Move close to the carrier'),
    (2, 'Ball carrier', 'Use a 1-2 to escape the pressure'),
    (3, 'All', 'Reread and restart if nothing opens')
) AS v(so, role, job);

-- 69. pp.110-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 How to Create an Open Ball Situation', 'Five ways to create the open ball',
    'Tools to free a player for the final pass: beat the marker on the dribble, a give-and-go, an ''imbucata'' (entry ball) to a back-to-goal player near the defence who deflects or lays off, a diagonal through ball to a teammate near the defence who then has space, or a lay-off to a supporting player facing goal between the lines who feeds cutting runners.',
    'No open ball available yet',
    'Manufacture a free, forward-facing passer in the final third.',
    NULL, 110, 110, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Dribble or combine to get free'),
    (2, 'Target forward', 'Receive the entry ball and deflect or set'),
    (3, 'Supporting midfielder', 'Face goal between lines to receive lay-offs'),
    (4, 'Runners', 'Cut in behind for the final pass')
) AS v(so, role, job);

-- 70. pp.113-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 1.1 Full Back High Up the Flank', 'Full back''s direct ball for checking winger',
    'Full back receiving high by the touchline looks first for a pass in behind: the winger drops to pull his marker up then spins into the space behind; alternatively the forward or near central midfielder runs into open space.',
    'Full back receives high with time',
    'Direct assist in behind as first priority.',
    NULL, 113, 113, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Play the ball in behind first if on'),
    (2, 'Same-side winger', 'Check short then spin in behind'),
    (3, 'Centre forward / near CM', 'Run into vacated space as alternative')
) AS v(so, role, job);

-- 71. pp.113-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 1.1 Full Back High Up the Flank', 'Full back 1-2s to break in behind',
    'When the direct pass is blocked by the opposing full back, the full back plays a quick 1-2 with the winger (or the near central midfielder if the opposing full back presses aggressively) and receives behind himself; variants use the 1-2 to then play in behind for the winger or for a third player such as the forward into the box.',
    'Direct assist blocked by opposing full back',
    'Get a runner in behind through a combination on the flank.',
    NULL, 113, 114, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Pass and run behind for the return'),
    (2, 'Same-side winger', 'Set the wall pass or run for the second ball'),
    (3, 'Near central midfielder', 'Offer 1-2 inside when the opposing full back presses'),
    (4, 'Centre forward', 'Third-man run into the box')
) AS v(so, role, job);

-- 72. pp.115-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 Options Blocked: Full Back Plays an Imbucata', 'Full back''s entry ball inside to forward',
    'With direct assist and near combination both blocked, the full back plays an ''imbucata'' inside to the forward, who moves across to receive and plays first time behind for the winger; against a deeper defence the winger checks back for a 1-2, or the forward sets to the winger who switches with an aerial ball for the far winger in behind or passes inside for a forward-running central midfielder to shoot or play through.',
    'Full back''s two nearest options blocked',
    'Use the forward as a link to unlock the flank or switch behind the weak side.',
    NULL, 115, 116, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Play the entry pass inside to the forward'),
    (2, 'Centre forward', 'Come across, play first time or set'),
    (3, 'Same-side winger', 'Run in behind or check back to combine'),
    (4, 'Far winger', 'Run behind the weak side for the switch'),
    (5, 'Opposite central midfielder', 'Forward run into the centre to shoot or play through')
) AS v(so, role, job);

-- 73. pp.116-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 Options Blocked: Full Back Plays an Imbucata', 'Back support then full back runs behind',
    'When no forward pass is on, there must always be a supporting player behind (here the near central midfielder) who receives the lay-off free and plays in behind for the full back''s timed run.',
    'No forward option from the wide player',
    'Create an open ball by playing back to a free supporter.',
    NULL, 116, 116, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near central midfielder', 'Offer back support, play in behind'),
    (2, 'Winger', 'Lay off to the supporter'),
    (3, 'Full back', 'Time the run in behind to stay onside')
) AS v(so, role, job);

-- 74. pp.117-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 1.2 Central Midfielder in the Middle', 'Advanced midfielder''s direct final pass',
    'A central midfielder who gets beyond the opponent''s midfield line (via entry pass or dribble) with no pressure plays straight in behind for the forward, or a diagonal ball between the opposing centre back and full back for the winger.',
    'Midfielder unpressed in front of the defensive line',
    'Direct assist from the centre.',
    NULL, 117, 118, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advancing central midfielder', 'Play the through or diagonal ball'),
    (2, 'Centre forward', 'Run in behind'),
    (3, 'Winger', 'Run between centre back and full back')
) AS v(so, role, job);

-- 75. pp.118-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 1.2 Central Midfielder in the Middle', 'Midfielder combinations to get in behind',
    'Under pressure the central midfielder plays a quick 1-2 with the forward and runs into the box; if an opposing centre back has stepped up leaving a staggered line he 1-2s with the winger instead; if the opposing full back is too far forward a lay-off and pass releases the winger; a pass into the forward that drags a centre back opens a gap for the midfielder''s run; with no gap the winger moves inside for an angle and the midfielder runs into the box.',
    'Pressure on the midfielder or a gap in a staggered line',
    'Use one or two teammates to put the midfielder or winger in behind.',
    NULL, 118, 119, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'Pass, then run into the box'),
    (2, 'Centre forward', 'Set wall passes, drag centre backs'),
    (3, 'Winger', 'Combine or come inside to open an angle')
) AS v(so, role, job);

-- 76. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 1.3 Winger on the Flank', 'Winger carrying inside: direct through ball',
    'Winger dribbling inside from the flank looks to pass behind: for the forward''s diagonal run between full back and centre back, for the far winger''s inside run between the centre backs; if both blocked, pass to the far central midfielder in space for a long shot or final pass.',
    'Winger drives inside with the ball',
    'Find a runner in behind or a free shooter.',
    NULL, 120, 120, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger', 'Carry inside, choose the final pass'),
    (2, 'Centre forward', 'Diagonal run between full back and centre back'),
    (3, 'Far winger', 'Inside run between the centre backs'),
    (4, 'Far central midfielder', 'Arrive in space for shot or pass')
) AS v(so, role, job);

-- 77. pp.121-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 The Winger''s Combination Play in the Final Third', 'Winger 1-2 read off the opposing full back',
    'If the opposing full back stands off, the winger plays a 1-2 with the forward and goes behind; if the full back closes him down the pass into the forward is blocked, so he 1-2s with the near central midfielder to exploit the space behind the pressing full back; a quick one-touch 1-2 with the forward can also free the forward to be played in behind.',
    'Opposing full back''s distance to the winger',
    'Beat the full back with the right wall-pass partner.',
    NULL, 121, 122, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger', 'Pass and go behind the full back'),
    (2, 'Centre forward', 'Wall pass when full back stands off'),
    (3, 'Near central midfielder', 'Wall pass when full back presses')
) AS v(so, role, job);

-- 78. pp.122-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 The Winger''s Combination Play in the Final Third', 'Pass, lay-off, third-man run by winger',
    'When the opposing full back holds position, the winger passes into the forward, who lays off to the near central midfielder, who plays first time behind for the winger''s third-man run.',
    'Opposing full back holds and marks space',
    'Release the winger behind with an extra pass he cannot track.',
    NULL, 122, 122, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger', 'Pass in and run behind'),
    (2, 'Centre forward', 'Lay the ball off'),
    (3, 'Near central midfielder', 'Play the ball behind for the winger')
) AS v(so, role, job);

-- 79. pp.123-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 The Winger''s Combination Play in the Final Third', 'Draw defence across, switch behind far side',
    'A 1-2 on the right drags defenders, including the opposing centre back, across; this opens a gap between the far centre back and full back for a pass in behind the opposite winger. If the centre back stays balanced, the far central midfielder acts as a link player to play the far winger in.',
    'Defence shifts across to the ball',
    'Finish on the weak side after overloading the strong side.',
    NULL, 123, 123, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger', 'Combine, then pass behind for the far winger'),
    (2, 'Far winger', 'Run in behind from the far side'),
    (3, 'Far central midfielder', 'Link pass when the direct ball is off'),
    (4, 'Centre forward', 'Wall pass that drags defenders')
) AS v(so, role, job);

-- 80. pp.123-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 The Winger''s Combination Play in the Final Third', 'Winger inside, full back overlaps',
    'Using the high full backs of the 4-3-3, the winger moves inside to draw defenders and clear the flank; after a 1-2 (or a pass, lay-off and pass from the central midfielder) the overlapping full back is played in behind.',
    'Winger moves inside carrying markers',
    'Create a numerical advantage high on the flank.',
    NULL, 123, 124, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger', 'Move inside to draw defenders'),
    (2, 'Ball-side full back', 'Overlap into the cleared flank'),
    (3, 'Near central midfielder', 'Play the final pass in behind'),
    (4, 'Centre forward', 'Set the ball back in the combination')
) AS v(so, role, job);

-- 81. pp.125-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 1.4 Winger Moves Inside Between the Lines', 'Winger receives inside between lines',
    'Instead of hugging the line the winger moves into the inside channel behind the midfield to receive an entry pass from the deep midfielder, which is hard to mark; receiving on the move he beats his man and slips the forward in.',
    'Winger escapes his marker into the half-space',
    'Receive between lines and play the final pass.',
    NULL, 125, 125, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger', 'Move inside behind midfield to receive'),
    (2, 'Deep midfielder', 'Play the entry pass'),
    (3, 'Centre forward', 'Run into the box')
) AS v(so, role, job);

-- 82. pp.125-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 1.4 Winger Moves Inside Between the Lines', 'Inside winger 1-2 exploits following full back',
    'When the opposing full back follows the inside winger aggressively, a quick 1-2 with the forward or the near central midfielder puts the winger behind; if nearby defenders all press, the 1-2 is followed by a quick shot from outside the box; the forward can drop then spin for a first-time return in behind.',
    'Opposing full back steps out to press the inside winger',
    'Exploit the space the pressing full back leaves.',
    NULL, 125, 128, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside winger', 'Play first time and spin behind or shoot'),
    (2, 'Centre forward', 'Drop, set, then spin in behind'),
    (3, 'Near central midfielder', 'Wall pass partner'),
    (4, 'Opposing full back (target)', 'Draw him out of the line')
) AS v(so, role, job);

-- 83. pp.129-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 1.4 Winger Moves Inside Between the Lines', 'Inside winger third-player and blind-side runs',
    'The inside winger 1-2s with the closest teammate who then plays in behind for a third player (forward or opposite winger); passes must go to the right foot and in front of the runner so the final pass can be first time. Variant: after a quick combination the winger makes a blind-side third-man run behind the pressing full back, timed to stay onside.',
    'Combination draws defenders onto the ball',
    'Find a third runner the defence cannot track.',
    NULL, 129, 130, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside winger', 'Combine, then run blind side or serve third man'),
    (2, 'Near central midfielder', 'Play the pass into the winger''s run'),
    (3, 'Centre forward', 'Set or run into box'),
    (4, 'Opposite winger', 'Run in behind into the box')
) AS v(so, role, job);

-- 84. pp.131-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 1.5 Forward Receives an Imbucata', 'Forward rebound pass after entry ball',
    'Forward receiving the vertical entry pass side-on uses a first-time deflection (''rebound pass'') into the path of the winger running in behind; quick support around him is required so first-time play is possible and the ball isn''t lost.',
    'Entry pass to forward with winger running',
    'Accelerate the attack with one touch into space.',
    NULL, 131, 131, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Side-on body shape, deflect first time behind'),
    (2, 'Ball-side winger', 'Run in behind on the pass'),
    (3, 'Central midfielders', 'Close support for the forward')
) AS v(so, role, job);

-- 85. pp.131-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 1.5 Forward Receives an Imbucata', 'Forward 1-2 and lay-off options',
    'After the entry ball the forward 1-2s with the winger moving inside when the full back marks him tight, or with an unmarked midfielder arriving; or lays off to the winger who crosses for a central midfielder''s run into the box once the centre back is dragged across; or lays off to a midfielder who shoots or plays the far winger in.',
    'Forward receives vertical pass with support around him',
    'Use the forward as a wall to free runners or shooters.',
    NULL, 131, 133, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Set to the best supporter'),
    (2, 'Ball-side winger', 'Come inside for 1-2 or cross after lay-off'),
    (3, 'Central midfielders', 'Arrive unmarked, shoot or run into box'),
    (4, 'Far winger', 'Run behind for the final ball')
) AS v(so, role, job);

-- 86. pp.135-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 2. Options Blocked: Maintain Possession and Start New Attack', 'Back pass to restart attack',
    'When wide, central and shooting options are all stopped, the team plays back while keeping two passing lanes: a support player behind the carrier plus a second outlet. Passing back to the nearest supporter allows a quick new attack: if the line steps up he crosses early for a midfielder''s run, if it stays he 1-2s with the winger and shoots from outside the box.',
    'Attack is blocked in the final third',
    'Keep the ball and immediately attack again.',
    NULL, 135, 137, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back', 'Play back to the nearest supporter'),
    (2, 'Near central midfielder', 'Support behind; cross or combine and shoot'),
    (3, 'Far central midfielder', 'Run into the box for the early cross'),
    (4, 'Ball-side winger', 'Offer the 1-2')
) AS v(so, role, job);

-- 87. pp.137-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 2. Options Blocked: Maintain Possession and Start New Attack', 'Reset via furthest support player',
    'If the nearest supporter is tightly marked or nothing quick is on, the ball goes all the way back to the centre back (directly, via the nearest supporter, or after a 1-2 with him), moving play out of the final third into the middle third to start a fresh attack with low-risk passes.',
    'Nearest support marked or no quick re-attack',
    'Keep possession safely and rebuild.',
    NULL, 137, 138, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back', 'Pass back to the centre back or near midfielder'),
    (2, 'Ball-side centre back', 'Stay available as the deep outlet'),
    (3, 'Near central midfielder', 'Bounce the ball back to reset')
) AS v(so, role, job);

-- 88. pp.140-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 3. Finishing: Transforming an Open Ball into a Shot', 'Pass and move to get the shot',
    'With an open ball, a teammate runs behind or between the lines for the assist; if the lane is blocked he comes to feet. After passing, the passer runs behind if his marker can be attacked behind his back, otherwise repositions between the lines in front of the defence to receive the return. The receiver chooses: shoot if a good chance, else return the ball or find a third man.',
    'Open ball, passing lane open or blocked',
    'Turn space and time into a quality shot.',
    NULL, 140, 140, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Off-ball attacker', 'Run behind or between the lines; come short if blocked'),
    (2, 'Passer', 'Run behind or reposition between lines after passing'),
    (3, 'Receiver', 'Shoot, return or find a third teammate')
) AS v(so, role, job);

-- 89. pp.142-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'to_defend', 'Ch5 Crossing the Ball into the Penalty Area and Finishing', 'Preventive marking behind the ball',
    'While the team crosses or attacks, every player behind the line of the ball takes a sensible position and marks preventively so a loss of possession does not lead to a counter.',
    'Team commits players to the attack',
    'Stop the counter before it starts.',
    NULL, 142, 142, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Hold position, mark opposing forwards preventively'),
    (2, 'Deep midfielder', 'Screen the counter lane'),
    (3, 'Far full back', 'Tuck in to balance')
) AS v(so, role, job);

-- 90. pp.142-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 Crossing the Ball into the Penalty Area and Finishing', 'Box occupation for a wide cross',
    'With only one striker the 4-3-3 must fill the box on crosses: forward attacks the near post (keeps two defenders busy), far winger the back post, far central midfielder the penalty spot, same-side winger or midfielder sits at the edge of the box for clearances; the crosser has a supporter behind him and the centre back stays available to reset. Practice adds full backs crossing from overloaded side zones.',
    'Ball wide in the final third ready to cross',
    'Have the key finishing zones covered on every cross.',
    NULL, 142, 146, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Attack the near post'),
    (2, 'Far winger', 'Attack the back post'),
    (3, 'Far central midfielder', 'Arrive at the penalty spot'),
    (4, 'Same-side winger / midfielder', 'Edge of the box for rebounds'),
    (5, 'Crossing full back', 'Deliver with a supporter behind')
) AS v(so, role, job);

-- 91. pp.145-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Ch5 Practice Examples for the Finishing Phase', 'Wingers released behind after circulation',
    'Team circulates the ball in a central zone (8-10 passes), then plays it to a winger outside the zone who runs behind the three defenders guarding the box; teammates then sprint up in support to finish quickly.',
    'Possession quota reached, winger starts run',
    'Time the pass and run in behind to finish fast.',
    NULL, 145, 145, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield players', 'Circulate, then release the winger'),
    (2, 'Wingers', 'Time the run behind the back line'),
    (3, 'Forward and midfielders', 'Sprint to support the finish')
) AS v(so, role, job);

-- 92. pp.150-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'to_defend', 'Ch6 The Defensive Phase: Preliminary Considerations', 'Compact possession enables pressing on loss',
    'A team that keeps the ball with short, steady circulation stays compact and can press hard the moment it loses the ball, whereas a long-ball team is stretched between lines and transitions badly. Game strategy choice (concede the ball and counter, or dominate it and risk counters behind) frames the defensive plan.',
    'Loss of possession',
    'Lose the ball with short distances so the press can start at once.',
    NULL, 150, 150, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All outfield units', 'Keep short distances between lines in possession'),
    (2, 'Players near the ball', 'Press immediately when it is lost')
) AS v(so, role, job);

-- 93. pp.151-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'out_of_possession', 'Chapter 6: Defensive Processes - Positional defending', 'Positional defending from set restarts',
    'When the ball goes dead (goal kick, throw-in, our foul) or after our long ball, or when the opponent chooses a slow positional attack, the whole team has time to get goal-side of the ball.',
    'Ball out of play or opponent builds slowly',
    'Every player is behind the ball line and in shape before the opponent restarts.',
    NULL, 151, 151, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All outfield players', 'Recover behind the line of the ball into the block'),
    (2, 'Back four', 'Set the line before the restart')
) AS v(so, role, job);

-- 94. pp.151-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'to_defend', 'Chapter 6: Defensive Processes - Defensive reorganisation (Withdraw)', 'Withdraw: retreat behind the ball',
    'Ball lost in open play with only part of the team behind it and the opponent able to counter.',
    'Loss with few players near the ball, counter threat',
    'Shrink the space behind, slow the counter and buy time for forward players to recover.',
    NULL, 151, 151, 940)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players behind the ball', 'Drop back together to cut space in behind and delay'),
    (2, 'Players ahead of the ball', 'Sprint back to restore balance and help win it back')
) AS v(so, role, job);

-- 95. pp.151-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'to_defend', 'Chapter 6: Defensive Processes - Aggressive Reaction (reactive pressing)', 'Aggressive reaction: reactive pressing in numbers',
    'Ball lost where we already have many players around the ball zone.',
    'Loss with numbers near the ball',
    'Win the ball back at once; if they escape long, the defence wins it through tight marking.',
    NULL, 151, 151, 950)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'Press the new ball carrier immediately'),
    (2, 'Players around the ball', 'Close the short passing lanes to his support players'),
    (3, 'Defenders', 'Mark their forwards aggressively and squeeze up to win the long ball')
) AS v(so, role, job);

-- 96. pp.152-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'out_of_possession', 'Chapter 6: Pressing - Counteracting phase (pressing zones and types)', 'Counteracting phase: plan the opponent''s restart',
    'Before an opposition restart (e.g. goal kick) we read where their forwards are and choose between man-for-man equality at the back (inviting the long ball) or keeping a spare defender and adjusting shape against the short restart. Pressing is named by zone: ultra-offensive (high), offensive (middle), defensive (low).',
    'Opponent about to restart',
    'Steer the ball into the zone we want or toward their weakest player, then press there.',
    NULL, 152, 153, 960)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Decide: accept 1v1 equality vs their forwards or keep a spare man'),
    (2, 'Front three and midfield', 'Position to show the restart toward the chosen zone or weak receiver')
) AS v(so, role, job);

-- 97. pp.154-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'out_of_possession', 'Chapter 6: Pressing - Advanced pressing high up the pitch', 'Advanced pressing high, only vs weaker builders',
    'Pressing in their half is avoided against sides who circulate fast and use the keeper; it is used against teams of limited technical/tactical level.',
    'Opponent builds from the back and lacks quality',
    'Win the ball high while denying the long ball over the press.',
    NULL, 154, 154, 970)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest presser', 'Press the ball carrier'),
    (2, 'Next player', 'Cover the nearest unmarked opponent'),
    (3, 'Midfielders', 'Close down support players and block lanes with tight marking'),
    (4, 'Weak-side players', 'Shift across to create a numbers advantage at the ball'),
    (5, 'Defenders', 'Mark their forwards in advance but keep the space behind covered')
) AS v(so, role, job);

-- 98. pp.156-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'out_of_possession', 'Pressing with the 4-3-3 against different formations - 1. vs 4-4-2', 'Central midfielder jumps onto second centre back',
    'Their two centre backs make 2v1 against our lone forward; one of them gets free to carry forward.',
    'Ball switched between their centre backs',
    'Press both centre backs without leaving their midfielder free.',
    '4-4-2', 156, 156, 980)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Press one centre back, curving to invite a long ball or the pass across'),
    (2, 'Ball-side central midfielder (LCM)', 'Jump onto the receiving centre back before he receives, angling to block the lane to his midfielder'),
    (3, 'Defensive midfielder', 'Slide over to deny the freed opposing midfielder'),
    (4, 'Ball-side winger', 'Tuck in to give extra cover')
) AS v(so, role, job);

-- 99. pp.157-157
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'out_of_possession', 'Pressing with the 4-3-3 against different formations - 2. vs 4-3-3', 'Invert the midfield triangle to press',
    'Against a 4-3-3 we must press the centre back and also block the lane to their holding midfielder; our triangle flips so the DM steps up to mark his counterpart as they build.',
    'Opponents start building from the back',
    'Cut both the centre back and the passing lanes into their midfield.',
    '4-3-3', 157, 157, 990)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Step forward onto their holding midfielder'),
    (2, 'Central midfielder (LCM)', 'Press the centre back before the pass arrives'),
    (3, 'Ball-side full back (LB)', 'Push up aggressively onto their central midfielder as soon as he is the target'),
    (4, 'Ball-side centre back (RCB)', 'Match their centre forward; if too quick, the line drops instead'),
    (5, 'Winger (LW)', 'Come inside if their midfielder drifts wide to receive')
) AS v(so, role, job);

-- 100. pp.158-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'out_of_possession', 'Pressing with the 4-3-3 against different formations - 3. vs 4-3-1-2', 'Control the diamond while pressing',
    'Opponent''s two strikers and midfield diamond: we must balance numbers against the centre backs and control the rhombus.',
    'Ball played between their centre backs',
    'Press their back line while every diamond player is marked or screened.',
    '4-3-1-2', 158, 158, 1000)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (LCM)', 'Press the receiving centre back'),
    (2, 'Other central midfielder (RCM)', 'Press their defensive midfielder'),
    (3, 'Far-side winger (RW)', 'Move inside to cover for RCM'),
    (4, 'Defensive midfielder', 'Hold, mark their attacking midfielder and watch their right central midfielder'),
    (5, 'Full back (LB) or a centre back', 'Contest their wide central midfielder: full back if strikers stay central, a centre back if a striker pulls wide (then the DM pushes on)'),
    (6, 'Strong-side winger (LW)', 'Tuck inside to block their central midfielder, then open out')
) AS v(so, role, job);

-- 101. pp.159-159
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'out_of_possession', 'Pressing with the 4-3-3 against different formations - 4. vs 4-2-3-1', 'Press the CB, centre back steps on No.10',
    'Same as against 4-4-2 but one striker and a No.10; our DM''s forward move is covered by a centre back stepping onto the No.10.',
    'Ball switched to the free centre back',
    'Press high with the back line still balanced.',
    '4-2-3-1', 159, 159, 1010)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (LCM)', 'Press the centre back, angled to block the lane to their midfielder'),
    (2, 'Defensive midfielder', 'Get close to their midfielder to prevent him receiving'),
    (3, 'Winger (LW)', 'Move inside for extra cover'),
    (4, 'Centre back (RCB)', 'Step forward onto their No.10'),
    (5, 'Other centre back (LCB) and weak-side full back (RB)', 'Protect the space behind and tuck in for balance')
) AS v(so, role, job);

-- 102. pp.160-160
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'out_of_possession', 'Pressing with the 4-3-3 against different formations - 5. vs 3-5-2', 'Wingers take the wide centre backs',
    'Their back three plus a holding midfielder give them a spare man in build-up.',
    'Their back three in possession',
    'Match their build-up and keep a spare defender against their two strikers.',
    '3-5-2', 160, 160, 1020)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (RW, LW)', 'Press their wide centre backs'),
    (2, 'Forward', 'Screen their defensive midfielder'),
    (3, 'Central midfielder (LCM)', 'Press the centre back on the ball'),
    (4, 'Defensive midfielder', 'Push up to mark their right central midfielder'),
    (5, 'Ball-side full back (LB)', 'Step to the central midfielder if he opens toward the flank'),
    (6, 'Weak-side full back (RB)', 'Tuck in so the back line outnumbers their two strikers')
) AS v(so, role, job);

-- 103. pp.162-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'out_of_possession', 'Defensive Compactness - Compacting phase', 'Compacting phase: short distances between lines',
    'Alternative to high pressing: defend in our own half with defence, midfield and attack close together so the opponent cannot play between our midfield and back lines; less space behind and fewer direct attacks.',
    'Opponent in possession in our half / mid-block',
    'Block passing lanes between the lines and kill the opponent''s rhombus shapes.',
    NULL, 162, 162, 1030)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Stay dynamic, ready to step up with the ball'),
    (2, 'Wingers', 'Track back into the block'),
    (3, 'Midfielders', 'Swing forward and back to block lanes; mark the front and back support of the opponent''s rhombus'),
    (4, 'Forward', 'Press the rhombus'' back support but stay ready to break when we win it')
) AS v(so, role, job);

-- 104. pp.163-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'out_of_possession', 'Defensive Compactness - Prevention phase', 'Prevention phase: squeeze time around the ball',
    'When the opponent does play between or behind our midfield line to speed up, we react collectively to deny an open ball and a final pass in behind. Trained in practice p171 (compact block, then swarm the ball if they play into the zone between the lines).',
    'Ball played forward between our lines',
    'Limit time, space and options around the receiver and his nearest teammates.',
    NULL, 163, 163, 1040)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender/midfielder', 'Press the ball carrier at once'),
    (2, 'Back line', 'Block passing lanes in behind'),
    (3, 'Midfielders', 'Drop back to compress the space together with the defence')
) AS v(so, role, job);

-- 105. pp.165-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'out_of_possession', 'Defensive Reactions - 1. Collective reactions of the defensive line', 'Back four moves as one unit',
    'Standard line movements: ball from flank to centre, line returns to its base shape; ball from centre to flank, line slides across keeping short gaps; long pass back, line steps up together; short pass back, line steps up by a similar small distance.',
    'Ball moves sideways or backward',
    'Keep the line connected and correctly placed, judged on whether the ball is open/closed, its distance, and the space behind.',
    NULL, 165, 166, 1050)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Slide, return, or step up together according to the ball movement'),
    (2, 'Defenders', 'Drop if the ball carrier is unpressed with space to play behind')
) AS v(so, role, job);

-- 106. pp.167-167
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'out_of_possession', 'Defensive Reactions - 2. Reactions of individual defenders', 'Centre back: man-mark or hold line',
    'Last-ditch duels when an attacker is about to receive and finish, or already has the ball to shoot. Either the centre back leaves the line to go man-to-man (others cover near and far post), or stays in line to cover the space behind his partner.',
    'Opponent about to receive or shoot near our box',
    'Stop the reception or the shot while keeping cover behind.',
    NULL, 167, 167, 1060)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (man marking)', 'Step out to the direct opponent to block the cut-back'),
    (2, 'Other defenders', 'Cover near post and far post areas'),
    (3, 'Centre back (zonal)', 'Stay in line to cover if the ball goes behind his partner')
) AS v(so, role, job);

-- 107. pp.169-170
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'to_attack', 'Practice Examples for the Defensive Phase - 1-2. Pressing to win the ball high', 'Win it high, score within 5 seconds',
    'Front three and three central midfielders press the opponent''s build-up from the keeper; a regain in the high zone is worth double, a regain further back forces a long possession first.',
    'Ball regained in the attacking third',
    'Turn a high regain into a fast break and shot within about 5 seconds while only their back four can defend.',
    '4-4-2', 169, 170, 1070)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front three', 'Press the build-up and attack goal immediately after the regain'),
    (2, 'Central midfielders', 'Squeeze up to win the ball high and support the break')
) AS v(so, role, job);

-- 108. pp.190-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Training Session Example 1 - 3. Tactical build-up pattern of play', 'Build-up route via winger and imbucata',
    'Rehearsed 4-3-3 build-up: centre back to DM, DM to the other centre back, to the full back, strong pass forward to the winger who comes inside, lay-off to the oncoming central midfielder, who plays the vertical entry (imbucata) to the forward; repeat to the other side.',
    'Free centre back in build-up',
    'Move the ball through the midfield line into the forward.',
    NULL, 190, 190, 1080)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs and DM', 'Circulate across the back to change the side'),
    (2, 'Full back', 'Drive a strong pass forward to the winger'),
    (3, 'Winger', 'Move inside to receive, lay off to the central midfielder'),
    (4, 'Central midfielder', 'Arrive onto the lay-off and play the vertical pass to the forward'),
    (5, 'Forward', 'Receive, set back to restart')
) AS v(so, role, job);

-- 109. pp.191-191
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Training Session Example 1 - 4. Build-up play from the back to finish', 'CB drops wide, midfielder steps up to equalise',
    'Building from the keeper against the next opponent''s press: a centre back drops into the first zone to take a free pass; in the final zone the attack starts 3v4 down, so one central midfielder pushes forward to level numbers. On losing the ball the team must transition instantly to stop a 6-8 second counter.',
    'Goal kick / keeper in possession under pressure',
    'Escape the press, reach the final third with equal numbers and finish; regain fast if lost.',
    NULL, 191, 191, 1090)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Find the dropping centre back'),
    (2, 'Centre back', 'Drop into space to receive unpressed'),
    (3, 'Central midfielder (LCM)', 'Join the front three to make numbers equal'),
    (4, 'Whole team', 'Counter-press immediately after a loss')
) AS v(so, role, job);

-- 110. pp.194-194
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Training Session Example 2 - 2. Checking away and playing forward', 'Check away, wall pass, third-man run',
    'Receiver checks away from his marker before coming to the ball; he plays forward one touch to a teammate and gets the return, while a third player checks away and runs forward to be played in behind.',
    'Pass into a marked midfielder',
    'Lose the marker and release a runner in behind with quick combination play.',
    NULL, 194, 194, 1100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving midfielder', 'Check away, come back to receive, play forward one touch and take the return'),
    (2, 'Advanced player', 'Bounce the ball back'),
    (3, 'Third man', 'Check away from his marker then run onto the pass in behind')
) AS v(so, role, job);

-- 111. pp.195-196
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-4-3-3-tactics-154-tactical-solutions-and-practices'), 'in_possession', 'Training Session Example 2 - 3-4. Creating an opening and passing in behind', 'Overload, find free man, play in behind',
    'Use the extra man (keeper, DM and central midfielders) in build-up and the width of the pitch to create an opening; when a player receives in space (e.g. the full back) he plays forward into the next line, the central midfielders push up to make 5v4, and the ball goes in behind to finish fast.',
    'Player receives with space after overloading build-up',
    'Play through and in behind within about 6 seconds; if lost, the opponent counters so the block must recover.',
    NULL, 195, 196, 1110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper and centre backs', 'Start build-up and use the numerical advantage'),
    (2, 'Full backs', 'Exploit width to receive free and play forward'),
    (3, 'Central midfielders (LCM, RCM)', 'Push into the attacking zone to create 5v4'),
    (4, 'Wingers and forward', 'Receive between the lines and run in behind to finish')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1964-coaching-book-433-tactics-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
