-- 5003 📚 Coaching book patterns: "King Klopp: Rebuilding the Liverpool
-- Dynasty" (Lee Scott, Pitch Publishing) — Kindle library (spreads
-- s001–s115 from Kindle Cloud Reader).  Every spread read by readers; each
-- distinct team behaviour written up in OUR OWN WORDS with who does what.
-- Biography, recruitment, data tables and photo plates left out.  Owner's
-- personal library.  (James 11/27 Kindle picks)
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    team        = 'Liverpool (Jurgen Klopp)',
    season      = '2015-20',
    method_note = 'An analyst''s study of Klopp''s title-winning Liverpool built chapter by chapter around roles: Alexander-Arnold and the full backs as creators, defenders in possession, the 6, pressing as a playmaker, functional midfield, the 9 and the false wingers, then player chapters (Van Dijk, Henderson, Fabinho, Keita, Mane, Salah, Firmino) and an anatomy of seven 2019/20 goals. Patterns are the on-pitch behaviours in our words; biography, recruitment and data left out. Kindle edition: page numbers are screen spreads.'
WHERE slug = 'kindle-king-klopp';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp');

-- 1. pp.9-10
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch1 Trent Alexander-Arnold', 'Front-three rotation: wingers in, 9 drops',
    'Liverpool 2019/20 4-3-3: Mane and Salah drift from the wings into the half-spaces or centre while Firmino drops into the ''10'' pocket, forming a loose triangle.',
    'Settled possession, building into the final third',
    'Confuse markers: if a full back follows the winger inside or a centre back follows Firmino, space opens for players arriving from deeper.',
    NULL, 9, 10, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forwards (Mane, Salah)', 'Move inside to half-space/central lanes, pin centre backs'),
    (2, 'Centre forward (Firmino)', 'Drop off the line into the 10 space'),
    (3, 'Full backs', 'Take over the vacated width'),
    (4, 'Deeper players', 'Run into whatever space the defenders leave')
) AS v(so, role, job);

-- 2. pp.10-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch1 Trent Alexander-Arnold', 'Inverted right back with 8 pulling wide',
    'Alexander-Arnold steps in off the touchline into the right half-space to receive from the right centre back in a pocket; to stop the right side going narrow and empty, the right 8 (Henderson/Oxlade-Chamberlain) rotates out to hold the touchline.',
    'Right centre back has the ball, front three rotating',
    'Give the creator a central angle to play forward while keeping the wide player pinned out wide.',
    NULL, 10, 14, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Alexander-Arnold)', 'Invert into half-space, receive, touch forward'),
    (2, 'Right 8 (Henderson)', 'Pull out to the right touchline as width'),
    (3, 'Right centre back (Matip)', 'Feed the inverted full back'),
    (4, 'Front three', 'Rotate to open passing angles')
) AS v(so, role, job);

-- 3. pp.12-12
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch1 Trent Alexander-Arnold', 'Classic overlapping full back and far-post cross',
    'In the traditional 4-3-3 pattern, when the ball moves to the right 8 in the half-space the winger comes inside and the full back sprints high and wide; set back to him near the box corner he whips a curling cross to the far side.',
    'Winger moves inside, wide lane empties',
    'Provide width and deliver crosses over the offside line to the far post.',
    NULL, 12, 12, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right-sided 8', 'Receive in the right half-space'),
    (2, 'Right wide forward', 'Come inside to find space, empty the wing'),
    (3, 'Right back (Alexander-Arnold)', 'Overlap high, cross from near the box corner'),
    (4, 'Far-side runners', 'Attack the far side of the box')
) AS v(so, role, job);

-- 4. pp.13-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch1 Trent Alexander-Arnold', 'Half-space pivot: play into space behind the line',
    'From an advanced inverted position the right back has options: easy ball outside to the widened 8, feet of Salah/Firmino, or a weighted pass into the gap between back line and keeper; the 6 and other 8 stay level behind the ball.',
    'Inverted full back receives facing forward between opposition lines',
    'Dictate tempo and supply runners who break free of markers in the line.',
    NULL, 13, 14, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted right back (Alexander-Arnold)', 'Act as pivot, choose wide, feet or in-behind ball'),
    (2, 'Right 8 (Henderson)', 'Wide outlet'),
    (3, 'Front three', 'Lose markers, find pockets in the defensive line'),
    (4, '6 and left 8 (Fabinho, Wijnaldum)', 'Sit level behind the ball as support/recycling'),
    (5, 'Left back (Robertson)', 'Go high when Mane inverts')
) AS v(so, role, job);

-- 5. pp.15-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch1 Trent Alexander-Arnold', 'Overload ball side, diagonal switch to isolated full back',
    'With the inverted right back at the centre of a group of five, triangles draw the opponent towards the ball; he then drives a diagonal to Robertson on the far side.',
    'Opponent shuffles over to stop the right-side overload',
    'Create a 1v1 for the opposite full back in open space.',
    NULL, 15, 15, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted right back (Alexander-Arnold)', 'Draw players, then switch with a driven diagonal'),
    (2, 'Ball-side group (Henderson, Salah, Firmino, Fabinho)', 'Form triangles that suck the block over'),
    (3, 'Left back (Robertson)', 'Stay high and wide to receive 1v1'),
    (4, 'Left 8 (Wijnaldum)', 'Push forward into the space after the switch')
) AS v(so, role, job);

-- 6. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_defend', 'Ch2 Defenders in possession', 'High centre backs as rest defence',
    'Because Liverpool live in the opposition half, the centre backs sit high as a release valve and the team counter-presses straight after losing the ball; opponents answer with long balls into the space behind.',
    'Possession lost high up the pitch',
    'Win the ball back quickly while the centre backs cover space behind 1v1 and win aerial duels.',
    NULL, 17, 17, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Van Dijk, Gomez, Matip)', 'Hold a high line, run back to defend space behind 1v1'),
    (2, 'Centre backs', 'Win aerial duels against strikers on direct balls'),
    (3, 'Nearest players', 'Counter-press aggressively')
) AS v(so, role, job);

-- 7. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch2 Defenders in possession', 'Vertical first, else switch across the back',
    'Centre backs stand in the half-spaces; the first thought is a vertical progressive pass, and if it is not on the ball goes quickly across to the other centre back to open a lane before the block shifts.',
    'Centre back in possession',
    'Progress through the thirds with line-breaking passes.',
    NULL, 17, 17, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back', 'Look for the vertical pass first'),
    (2, 'Far centre back', 'Receive the switch with time to play forward')
) AS v(so, role, job);

-- 8. pp.17-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch2 Defenders in possession', 'Quick CB-to-CB pass, carry to commit a midfielder',
    'When the right centre back has no forward option he plays a quick flat pass to the left-footed left centre back, who takes it on the far foot and carries forward; an opposition midfielder steps out to stop the dribble and the 8 behind him slips into the vacated space.',
    'No vertical lane open, opponent block slow to shift',
    'Break the opposition midfield line, taking several players out of the game.',
    '4-1-4-1', 17, 18, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back (Matip)', 'Pace the lateral pass so the block can''t shift'),
    (2, 'Left centre back (Van Dijk)', 'Receive on the left foot, carry to commit a presser'),
    (3, 'Left back (Robertson)', 'Drop to give an angle outside, drag the winger'),
    (4, 'Left 8 (Wijnaldum)', 'Move off his marker into space left by the stepping midfielder')
) AS v(so, role, job);

-- 9. pp.19-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch2 Defenders in possession', 'Centre back long diagonal to isolated winger',
    'With little forward space, the left centre back has time and fires a diagonal over the block to Salah, who has got himself 1v1 against a defender on the far right.',
    'Winger isolated 1v1 on the far side',
    'Change the point of attack and take six opponents out with one pass.',
    '4-1-4-1', 19, 19, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Van Dijk)', 'Strike a long diagonal switch'),
    (2, 'Right wide forward (Salah)', 'Hold width, isolate his full back 1v1')
) AS v(so, role, job);

-- 10. pp.20-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch2 Defenders in possession', 'Switch to the left CB vs deep block',
    'Opposition pushed deep; ball comes back from the right back to the right centre back and is moved across to Van Dijk in the left half-space before the block can slide.',
    'Deep compact block, ball switched to left centre back',
    'Three options: in behind the full back for Robertson, vertical for Mane''s run into the box, or into Firmino''s feet to set Salah.',
    NULL, 20, 20, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Van Dijk)', 'Pick ball in behind, vertical run or feet'),
    (2, 'Left back (Robertson)', 'Run in behind the right back'),
    (3, 'Left wide forward (Mane)', 'Run into the penalty area'),
    (4, 'Centre forward (Firmino)', 'Show for feet and lay through to Salah')
) AS v(so, role, job);

-- 11. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch2 Defenders in possession', 'Winger cuts in, 9 drops for line-breaker',
    'Firmino starts against the far centre back; Mane runs inside across a central midfielder, leaving him two players to watch, and that triggers Firmino to drop toward the ball.',
    'Wide forward''s outside-to-inside run',
    'Free the 9 in a pocket so the centre back can fire a pass through the line and the 9 turns at the box.',
    NULL, 21, 21, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back (Matip)', 'Play the sharp line-breaking pass'),
    (2, 'Left wide forward (Mane)', 'Run inside to overload a midfielder'),
    (3, 'Centre forward (Firmino)', 'Drop into the created pocket and turn')
) AS v(so, role, job);

-- 12. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch2 Defenders in possession', '8 drops to make 3v2 vs two pressers',
    'When two opponents press the centre backs (a striker plus a midfielder jumping from the 4-4-2), the left 8 drops between the centre backs to form a back three.',
    'Two opponents engage the two centre backs',
    'Restore numerical superiority so the dropped midfielder can play to the full back, the winger or diagonally to the 9 against a stretched block.',
    '4-4-2', 22, 22, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left 8 (Wijnaldum)', 'Drop into a chain of three, receive'),
    (2, 'Centre backs', 'Split to make a three'),
    (3, 'Left back (Robertson)', 'Wide option'),
    (4, 'Front players (Mane, Firmino)', 'Forward and diagonal options')
) AS v(so, role, job);

-- 13. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'out_of_possession', 'Ch2 Defenders in possession', 'Napoli''s strikers glue to centre backs',
    'Napoli (CL group 2019/20) played a strict 4-4-2: the two forwards stayed tight to Liverpool''s centre backs and the rest formed a compact block with no space between lines.',
    'Opponent centre backs in possession',
    'Kill build-up from the centre backs and leave the forwards ready to spring in behind on regains.',
    '4-3-3', 23, 23, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two forwards', 'Stay close to the centre backs, run in behind on regain'),
    (2, 'Midfield and back four', 'Hold a compact block, deny space between lines')
) AS v(so, role, job);

-- 14. pp.24-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'out_of_possession', 'Ch3 The importance of the ''6''', 'The 6 as ''lighthouse'' screening counters',
    'During the rotations (left back high, right back in the half-space, wingers inside) the single pivot stays central and protects the space counter-attacks would use.',
    'Team committed in the final third',
    'Provide control and immediate cover so a lost ball does not become a counter.',
    NULL, 24, 26, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Fabinho)', 'Hold the central position, intercept, cover wide spaces left or right'),
    (2, 'Mobile centre backs', 'Defend wide spaces when isolated'),
    (3, 'Front players', 'Rotate freely knowing the base is held')
) AS v(so, role, job);

-- 15. pp.25-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch3 The importance of the ''6''', 'Late vertical run from the 6',
    'Against a deep block after the first attack is reset, the 9 drops and a centre back follows him; the wide forwards pin their defenders and the 6 makes a delayed run into the gap.',
    'Defender follows the dropping 9, second/third phase vs deep block',
    'The 9 lays the ball into the 6''s path to break through the middle of the line.',
    NULL, 25, 28, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Fabinho)', 'Time a late run from deep into the vacated channel'),
    (2, 'Centre forward (Firmino)', 'Drop to drag a centre back, lay off into the run'),
    (3, 'Wide forwards (Mane, Salah)', 'Pin the nearest defenders'),
    (4, 'Right 8 (Henderson)', 'Feed the dropping 9 from the half-space')
) AS v(so, role, job);

-- 16. pp.27-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_defend', 'Ch3 The importance of the ''6''', '6 covers weak side after ball-side overload',
    'With the whole structure (centre backs included) shifted to the ball side, a turnover can be switched quickly to the empty weak side.',
    'Possession lost with the team overloaded on one side',
    'The 6 slides across to the weak side so the centre backs can hold the centre and ball side, stopping a quick switch-counter.',
    NULL, 27, 27, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Fabinho)', 'Slide across to defend the weak-side lane'),
    (2, 'Centre backs', 'Stay central and near the ball')
) AS v(so, role, job);

-- 17. pp.29-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch3 The importance of the ''6''', 'Draw a midfielder out, play into the 6',
    'Against a compact 4-5-1 with one forward, the full back''s possession lures a midfielder out to press; the ball goes back to the centre back and into the 6 in the space vacated.',
    'Opposition midfielder leaves his slot to press',
    '6 drives through the broken line, forcing a defender to step, then the 9 runs diagonally into that gap.',
    '4-5-1', 29, 29, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Alexander-Arnold)', 'Draw the presser'),
    (2, 'Right centre back (Matip)', 'Play into the 6'),
    (3, '6 (Fabinho)', 'Receive, carry into the gap, commit a defender'),
    (4, 'Centre forward (Firmino)', 'Diagonal run into the space behind'),
    (5, 'Left wide forward (Mane)', 'Drop deeper to free the channel')
) AS v(so, role, job);

-- 18. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch3 The importance of the ''6''', '6 shortens toward a non-creative full back',
    'When the right back is a weak progressor (Gomez), the 6 (Henderson) moves toward him rather than relying on a line-breaking pass into the 9.',
    'Full back on the ball unlikely to break lines',
    'Take a simple lateral pass and lift the progressive ball over the midfield line to the wide right runner.',
    NULL, 30, 30, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Henderson)', 'Shorten the distance, receive, pass over the midfield line'),
    (2, 'Right back (Gomez)', 'Simple pass to the 6'),
    (3, 'Right 8 (Oxlade-Chamberlain)', 'Run in the right channel to receive'),
    (4, 'Left 8 (Wijnaldum)', 'Stay level with the 6 as base')
) AS v(so, role, job);

-- 19. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_defend', 'Ch4 Pressing as a playmaker', 'Dortmund gegenpress: flood the ball',
    'Klopp''s Dortmund, after losing the ball in the final third, sent up to four players at the ball carrier at once instead of one or two.',
    'Ball given away in the final third',
    'Win it back high while the opponent is still turning into an attacking shape, near goal.',
    NULL, 31, 31, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest three or four players', 'Swarm the ball carrier immediately'),
    (2, 'Rest of team', 'Squeeze up behind the press')
) AS v(so, role, job);

-- 20. pp.32-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'out_of_possession', 'Ch4 Pressing as a playmaker', 'Funnel inside, spring from the second line',
    '2019/20 default press: wide forwards sit between centre back and full back using body shape to block the pass outside while the 9 engages the keeper or centre back; the full press only starts when the ball reaches the opposition second line.',
    'Ball played into a midfielder or the pivot, often facing his own goal',
    'Midfield engages from the front while the 6 and the front three press from behind, so the receiver can''t escape backwards and is forced into a turnover.',
    NULL, 32, 33, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Firmino)', 'Engage keeper/centre back, then press the pivot from behind'),
    (2, 'Wide forwards', 'Cut passing lanes to the full backs'),
    (3, '6 (Fabinho)', 'Jump onto the receiving pivot (no direct opponent)'),
    (4, 'Midfield line', 'Engage the ball at the second line')
) AS v(so, role, job);

-- 21. pp.32-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'out_of_possession', 'Ch4 Pressing as a playmaker', 'Aggressive first-line press with curved run',
    'When the keeper plays to centre backs dropped into the box, the near forward presses the receiver while the 9 curves his run to cut the pass back to the keeper or across; the next four nearest options are marked man to man.',
    'Goalkeeper pass to a deep centre back',
    'Force a turnover high or a rushed, poor pass.',
    NULL, 32, 35, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near wide forward (Salah)', 'Press the ball receiver'),
    (2, 'Centre forward (Firmino)', 'Curve run to block keeper and far centre back'),
    (3, 'Midfielders and full backs', 'Mark the nearest options man to man')
) AS v(so, role, job);

-- 22. pp.33-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_defend', 'Ch4 Pressing as a playmaker', 'Compact ball-side attack enables counter-press',
    'Liverpool attack in a tight unit on the ball side with centre backs up to the edge of the centre circle and the midfield squeezed close.',
    'Pass intercepted in the half-space',
    'Four players are immediately near the ball to win it back and overload the opponent before it can turn into defence.',
    NULL, 33, 36, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest four players', 'Counter-press the interceptor at once'),
    (2, 'Centre backs', 'Push up to the centre circle'),
    (3, 'Midfield line', 'Squeeze up behind the ball')
) AS v(so, role, job);

-- 23. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'out_of_possession', 'Ch4 Pressing as a playmaker', 'Touchline trap on the full back',
    'If the opponent reaches its full back in the wide area, three players close him from different angles while the whole block slides to that side.',
    'Pass out to the opposition full back on the touchline',
    'Leave no forward, backward or inside pass so he loses the ball or plays a poor one.',
    NULL, 34, 34, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Robertson)', 'Press forward to block the line'),
    (2, 'Left wide forward (Mane)', 'Press from in front to cut the back pass'),
    (3, 'Left 8 (Wijnaldum)', 'Close the inside pass'),
    (4, 'Rest of block', 'Slide across to deny central space')
) AS v(so, role, job);

-- 24. pp.37-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch5 Functional midfield', 'Functional midfield balance around the 6',
    'After 2018/19 transition problems with both 8s pushing up with the full backs, the 8s became functional: the left 8 stays level with the 6 as a recycler/second pivot and the right 8 swaps outside or makes late runs to the box edge.',
    'Full backs advanced, inverted right back central',
    'One player in each wide lane, two in each half-space and a solid base, so the team can overload the centre yet stay balanced on losing it.',
    NULL, 37, 39, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left 8 (Wijnaldum)', 'Stay level with the 6, recycle and switch play'),
    (2, 'Right 8 (Henderson)', 'Take width or make late runs to the box edge'),
    (3, '6 (Fabinho)', 'Feed the advanced full back'),
    (4, 'Left back (Robertson)', 'Run high from deep into space Mane leaves')
) AS v(so, role, job);

-- 25. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'out_of_possession', 'Ch5 Functional midfield', 'Midfielder screens the lane, others press',
    'The nearest midfielder does not jump at the receiver (which would let him shift the ball into the space behind) but uses body position to shield the passing lane behind the midfield line.',
    'Opponent receives in front of the Liverpool midfield',
    'Delay the forward pass so two team-mates can press from other angles and regain high.',
    NULL, 40, 40, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest 8 (Wijnaldum)', 'Shield the lane behind the midfield, delay'),
    (2, 'Two nearby team-mates', 'Engage the ball from different angles')
) AS v(so, role, job);

-- 26. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_defend', 'Ch5 Functional midfield', 'Midfield block slides to delay the counter',
    'A direct pass toward Salah at the box edge is cut out and the opponent tries to counter; the midfield unit slides across to close the space on that side.',
    'Turnover after a forward pass in the final third',
    'Delay the forward progression while other players press the ball from behind.',
    NULL, 40, 40, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield three', 'Slide across as a block, close forward lanes'),
    (2, 'Forwards', 'Press the ball carrier from behind')
) AS v(so, role, job);

-- 27. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'out_of_possession', 'Ch5 Functional midfield', 'Compact block with high front-two outlet',
    'When the opponent manages a long spell of possession Liverpool drop into a compact block; the midfield three screen the two centre backs to deny passes into the box while one wide forward (Mane) drops in and the other two attackers stay high.',
    'Opponent settles into sustained possession',
    'Keep the ball out of the penalty area while keeping forward reference points for the counter.',
    NULL, 41, 41, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding and left midfielders (Fabinho, Wijnaldum)', 'stay in position, screen the centre backs'),
    (2, 'Right midfielder (Henderson)', 'step out towards the ball to press'),
    (3, 'Left wide forward (Mane)', 'drop back into the block'),
    (4, 'Centre forward and right wide forward (Firmino, Salah)', 'stay high as outlets for a forward pass')
) AS v(so, role, job);

-- 28. pp.42-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch6 The ''9''', 'False-9 drop: centre-back dilemma',
    'The centre forward drops off the line into the 10 space or ball-side half-space; the centre back must choose between following him (opening a hole in the back line) or holding (letting him receive and turn), and the opposing 6 faces the same choice.',
    'Ball in midfield/build-up, striker free to come short',
    'Whatever the defender chooses, space opens either behind the line for the inside runners or in front of it for the 9.',
    NULL, 42, 46, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Firmino)', 'drop towards the ball between the lines'),
    (2, 'Centre back (Van Dijk) / central midfielder (Wijnaldum)', 'progress the ball into the 9 or into the gap left behind'),
    (3, 'Wide forwards (Mane, Salah)', 'attack the gap between centre back and full-back if the defender follows')
) AS v(so, role, job);

-- 29. pp.43-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch6 The ''9''', 'Advanced platform: striker receives, runners go',
    'A driven pass into the press-resistant 9 near the edge of the box or between the lines gives a platform; as soon as he controls it the wide forwards and the left-back make vertical runs beyond the line, and he slips, flicks or turns to find them.',
    'Ball played into the 9''s feet between the lines',
    'Turn one pass into a through ball for a runner behind the back line.',
    NULL, 43, 47, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Firmino)', 'receive under pressure, hold off marker, one-touch flick or turn and thread'),
    (2, 'Wide forwards (Mane, Salah)', 'immediate vertical runs beyond the defensive line'),
    (3, 'Left-back (Robertson)', 'advance high on the left and run beyond'),
    (4, 'Right midfielder (Henderson)', 'pivot out to the right as the front three move inside')
) AS v(so, role, job);

-- 30. pp.44-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch6 The ''9'' / Ch7 False wingers', 'Wide forwards pin centre backs narrow',
    'With the striker dropped (or even staying central against a deep block) both wide forwards come inside and stand in the channels between centre backs and full-backs, so each centre back is man to man and cannot step out to the 9.',
    'Ball circulating along the back line or played into the 9',
    'Create a central overload where the striker receives freely and the wide forwards attack vertically the moment he has the ball.',
    NULL, 44, 53, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forwards (Salah, Mane)', 'move inside into the CB-FB lanes, pin the centre backs'),
    (2, 'Centre forward (Firmino)', 'receive in the 10 space or stay central as a third central attacker'),
    (3, 'Centre backs (Matip, Van Dijk)', 'circulate and play into the striker')
) AS v(so, role, job);

-- 31. pp.45-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch6 The ''9''', '9 turns and switches to the overlapping full-back',
    'Right-back passes into the dropped 9, bypassing several opponents; the inside-moving left wide forward has dragged the opposing right-back narrow, so the left-back runs high and the 9 turns and hits a diagonal into the space beside a high back line.',
    '9 receives facing forward with time; opposing full-back pulled inside',
    'Get the full-back in behind a high line so the defence must run back towards its goal.',
    NULL, 45, 45, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right-back (Alexander-Arnold)', 'play into the 9''s feet'),
    (2, 'Centre forward (Firmino)', 'drop, receive, turn, diagonal switch'),
    (3, 'Left wide forward (Mane)', 'move inside to drag the opposing full-back'),
    (4, 'Left-back (Robertson)', 'run past the midfielder into the space wide of the line')
) AS v(so, role, job);

-- 32. pp.47-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch6 The ''9''', '9 drags marker deep, 6 runs into slot',
    'In build-up the 9 drops right back towards halfway to take a vertical pass from a centre back; the opposing midfielder follows him out of his slot and the deepest Liverpool midfielder runs forward into the vacated space.',
    'Centre back on the ball, 9 drops very deep and is followed',
    'Use the defender''s pursuit to open a lane through the midfield line for a deep runner.',
    NULL, 47, 47, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Matip)', 'vertical pass into the dropping 9'),
    (2, 'Centre forward (Firmino)', 'drop to halfway, pull the midfielder out'),
    (3, 'Holding midfielder (Henderson as 6)', 'run vertically into the vacated slot')
) AS v(so, role, job);

-- 33. pp.48-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch7 False wingers', 'False wingers finish, full-backs give width',
    'The wide forwards play as inverted inside forwards who end up across the width of the box like strikers (most shots inside the box width, high-value chances), while the striker creates and the full-backs provide all the width.',
    'Settled attack in the final third',
    'Swap the classic roles so the wingers get the high-xG chances and the full-backs go round the block.',
    NULL, 48, 49, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forwards (Mane, Salah)', 'cut inside to occupy the back line and shoot from inside the box'),
    (2, 'Centre forward (Firmino)', 'drop and create rather than finish'),
    (3, 'Full-backs (Robertson, Alexander-Arnold)', 'push high and wide to stretch the block')
) AS v(so, role, job);

-- 34. pp.50-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch7 False wingers', 'Front three on three different lines',
    'With an unpressed centre back on the ball at the edge of the final third, the inverted front three split vertically: the 9 drops to receive, one wide forward shows to feet to isolate his man 1v1, the other pulls between defenders to run beyond.',
    'Free centre back in possession, no direct pressure',
    'Give the ball carrier three different targets so the back line cannot defend all of them.',
    NULL, 50, 51, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Van Dijk)', 'choose the line: feet short, feet isolated, or ball in behind'),
    (2, 'Centre forward (Firmino)', 'drop into the 10 space'),
    (3, 'Right wide forward (Salah)', 'receive to feet, back to goal, go 1v1'),
    (4, 'Left wide forward (Mane)', 'pull between defenders and stretch beyond the line')
) AS v(so, role, job);

-- 35. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'out_of_possession', 'Ch7 False wingers', 'Asymmetric wide-forward defending',
    'On the left, when the left-back steps out to engage the opponent''s receiving player, the left wide forward sprints back from a high spot to cover the man the left-back left; on the right the wide forward presses only in the first moments and stops once the ball crosses halfway, staying high.',
    'Opponent builds down the left; left-back jumps out',
    'Cover the gap behind the jumping full-back on one side while keeping a counter outlet high on the other.',
    NULL, 52, 52, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left-back (Robertson)', 'step out to engage the man on the ball'),
    (2, 'Left wide forward (Mane)', 'track back at speed to cover the freed opponent and challenge'),
    (3, 'Right wide forward (Salah)', 'press early, then hold a high position for the counter')
) AS v(so, role, job);

-- 36. pp.52-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_attack', 'Ch7 False wingers / Ch12 Sadio Mane', 'Left-side release: vertical pass for Mane',
    'Liverpool win the ball deep; the 9 and right wide forward are already central and high, pinning the opposition centre backs deep, so the left side is open; the left-back (receiving from the left-back slot or from Van Dijk after moving inside) plays a straight pass and the left wide forward runs outside his marker.',
    'Regain deep on the left; centre backs pinned by Salah and Firmino',
    'A single vertical pass and curved run unbalance the opponent''s defensive transition and send Mane at goal.',
    NULL, 52, 79, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward and right wide forward (Firmino, Salah)', 'stay high and central to pin the centre backs'),
    (2, 'Left-back (Robertson)', 'move inside towards the ball, receive, play the vertical pass into the lane'),
    (3, 'Left wide forward (Mane)', 'curved run outside the defender, knock past him with momentum'),
    (4, 'Left centre back (Van Dijk)', 'find the left-back when no vertical option is open')
) AS v(so, role, job);

-- 37. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch7 False wingers', 'Decoys draw four, isolate Salah 1v1',
    'The 9 and left wide forward position themselves to attract two defenders each, leaving the right wide forward to show for a pass into feet against a single marker near the box.',
    'Four defenders occupied by the other two forwards',
    'Feed the winger in a 1v1 where he lets the defender close then rolls him into the box to finish.',
    NULL, 53, 53, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward and left wide forward (Firmino, Mane)', 'occupy and attract two defenders each'),
    (2, 'Right wide forward (Salah)', 'demand the ball to feet, turn or roll the marker, shoot'),
    (3, 'Midfielder', 'feed the isolated winger')
) AS v(so, role, job);

-- 38. pp.56-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch8 Virgil van Dijk', 'Free far-side centre back carries forward',
    'Opponent is compact on the ball side and the far-side centre back is free in his half-space; Liverpool switch to him and he drives forward at once, before the block can slide across.',
    'Free centre back receives after a switch',
    'Force two opponents out of their slots to engage him, opening space behind for the left-back and left wide forward.',
    NULL, 56, 56, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Van Dijk)', 'carry straight forward into the block without waiting'),
    (2, 'Left-back (Robertson)', 'run into the space behind the players who step out'),
    (3, 'Left wide forward (Mane)', 'attack the space vacated on the left of the attack')
) AS v(so, role, job);

-- 39. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch8 Virgil van Dijk', 'Centre back diagonal to far-side full-back',
    'With the opponent set and pressing the left-back, the ball goes back to the left centre back to relieve pressure; with the vertical options closed he receives on one foot, opens his body and hits a high diagonal to the right-back in free space wide.',
    'Ball side pressed and vertical lanes covered',
    'Change the point of attack quickly to the free full-back on the far side.',
    NULL, 57, 57, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left-back (Robertson)', 'recycle to the centre back to escape pressure'),
    (2, 'Left centre back (Van Dijk)', 'open body, long diagonal switch'),
    (3, 'Right-back (Alexander-Arnold)', 'hold width on the far side to receive')
) AS v(so, role, job);

-- 40. pp.57-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_defend', 'Ch8 Virgil van Dijk', 'Recovering centre back defends 2v1',
    'When the counter-press is beaten and a quick ball goes into the space behind Liverpool''s high line, the left centre back runs back facing two attackers; he closes the ball while keeping the second attacker in his cover shadow and gets to the ball first.',
    'Opponent breaks the counter-press with runners into space behind',
    'Win the duel alone and start Liverpool''s own transition, which is what lets the left-back push so high.',
    NULL, 57, 58, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Van Dijk)', 'recover, close ball, cut the pass with his cover shadow, win the ball'),
    (2, 'Striker and right-sided forward', 'counter-press first to slow the release'),
    (3, 'Left-back (Robertson)', 'free to take advanced positions because of this cover')
) AS v(so, role, job);

-- 41. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'out_of_possession', 'Ch8 Virgil van Dijk', 'Defender controls space 1v1 in deep block',
    'In the deep block a defender facing a ball carrier just in front of him angles his body to cover the pass and layoff runs while staying balanced to defend a dribble either side; he defends a layoff-and-run by already being in the space.',
    'Ball carrier ahead of the defender in the final third',
    'Let the team leave defenders isolated 1v1 so the opponent cannot build overloads.',
    NULL, 59, 59, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Van Dijk)', 'angle body to cover passing option, stay balanced, defend both sides'),
    (2, 'Second centre back', 'cover the supporting attacker centrally')
) AS v(so, role, job);

-- 42. pp.61-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch9 Jordan Henderson', 'Right-side rotation: full-back in, 8 out',
    'The right-back moves inside into the half-space and drags his marker with him while the right midfielder runs outside to give width, keeping the centre from getting crowded; the 8 then uses his range to curl a ball into the space between back line and keeper.',
    'Right-back moves inside into the half-space',
    'Stretch the block and free the 8 in a wide area to deliver behind the line.',
    NULL, 61, 64, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right-back (Alexander-Arnold)', 'move inside to the half-space, pull the defender in'),
    (2, 'Right midfielder (Henderson)', 'run outside for width, receive, curl pass behind the line'),
    (3, 'Left wide forward (Mane)', 'position between two defenders to run onto the ball')
) AS v(so, role, job);

-- 43. pp.62-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_defend', 'Ch9 Jordan Henderson', '8''s recovery run after a lost attack',
    'After an attack breaks down and the opponent breaks on the ball side, the right midfielder makes a recovery run from well behind the ball to block the carrier and win it back while the other midfielders hold screening positions.',
    'Ball lost, opponent breaks wide on Liverpool''s right',
    'Stop the overload on the ball side and launch a transition straight away.',
    NULL, 62, 62, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfielder (Henderson)', 'sprint back, block the carrier''s path, win the ball'),
    (2, 'Right-back (Alexander-Arnold)', 'engage first in the half-space to slow it'),
    (3, 'Holding and left midfielders (Fabinho, Wijnaldum)', 'screen centrally')
) AS v(so, role, job);

-- 44. pp.63-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_defend', 'Ch9 Jordan Henderson', 'One 8 delays, front line collapses back',
    'After losing the ball one midfielder presses out towards it to close wide and direct options, while the other two midfielders stay in set positions behind the ball; the front players fall back onto the ball from behind and win it. The author contrasts this measured press with Klopp''s Dortmund.',
    'Ball lost, opponent tries a quick transition',
    'Delay the attack rather than chase it, so the regain comes from attackers collapsing from behind.',
    NULL, 63, 63, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfielder (Henderson)', 'press out to close forward/wide passes and delay'),
    (2, 'Other two midfielders', 'hold set positions behind the ball, do not join the press'),
    (3, 'Front players', 'drop back onto the ball from behind and win it')
) AS v(so, role, job);

-- 45. pp.63-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_attack', 'Ch9 Jordan Henderson', 'Second ball to wide 8, pass behind',
    'Goalkeeper goes direct into the opponent''s half; the 9 has dropped and pulled a defender with him, the ball runs loose to the right, the right midfielder breaks out wide to collect and bends a pass behind the line for the right wide forward running between two defenders.',
    'Long ball from the keeper not won cleanly, loose on the right',
    'Turn a scrappy second ball into a through ball while the line is disorganised.',
    NULL, 63, 63, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'direct ball into opposition half'),
    (2, 'Centre forward (Firmino)', 'drop to contest and drag a defender out'),
    (3, 'Right midfielder (Henderson)', 'move out wide, collect, bend the pass behind'),
    (4, 'Right wide forward (Salah)', 'vertical run between two defenders')
) AS v(so, role, job);

-- 46. pp.65-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch9 Jordan Henderson', '8 supports behind the full-back to cross',
    'When the right-back has gone wide and high and is tracked so his cross is hard, the right midfielder comes across at an angle behind the ball near the box corner, takes the pass back and crosses first time to the far post; he also adds late runs into the box when attacks slow.',
    'Advanced full-back tracked, cross blocked',
    'Deliver into the box from a deeper angle the defence is not set against.',
    NULL, 65, 65, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right-back (Alexander-Arnold)', 'advance wide, lay the ball back'),
    (2, 'Right midfielder (Henderson)', 'support at an angle behind the ball, first-time looped cross to far post'),
    (3, 'Forwards', 'attack the far post')
) AS v(so, role, job);

-- 47. pp.67-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_defend', 'Ch10 Fabinho', '6 as rest defence vs clearances',
    'With five Liverpool players in or around the box and others supporting, the opponent collapses into a deep block with no depth; the 6 holds a spot behind the attack, offers a back pass for a switch and steps in to intercept clearances before they reach anyone.',
    'Ball cleared from the box',
    'Win the second ball and restart a second wave of attack so the team can stay high.',
    NULL, 67, 68, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Fabinho)', 'sit behind the attack, intercept clearances, recycle or switch'),
    (2, 'Attackers', 'commit to the box and edge of the area')
) AS v(so, role, job);

-- 48. pp.69-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_defend', 'Ch10 Fabinho', '6 counter-presses an interception at once',
    'A line-breaking pass from a centre back is intercepted, leaving the high Liverpool line exposed; the 6 reacts from his attacking position to challenge the interceptor and win the ball back before the first pass is played.',
    'Opponent intercepts a forward pass',
    'Kill the counter in the moment of chaos and regain high.',
    NULL, 69, 69, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Fabinho)', 'react immediately, close the interceptor, win the ball'),
    (2, 'Centre back (Matip)', 'attempt the line-breaking pass'),
    (3, 'Centre backs (Van Dijk)', 'cover space behind the high line')
) AS v(so, role, job);

-- 49. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch10 Fabinho', 'Forward''s pull-off opens vertical lane for 6',
    'At the edge of the final third the right wide forward drifts to the far side of the box, pulling his defender and opening a gap; the 6 plays a vertical pass through the block into it for the 9 moving forward.',
    'Defender follows a wide forward and leaves a gap',
    'One line-breaking pass that removes all outfield defenders from the play.',
    NULL, 70, 70, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Fabinho)', 'vertical pass through the gap'),
    (2, 'Right wide forward (Salah)', 'move away to the far side, drag the defender'),
    (3, 'Centre forward (Firmino)', 'move forward into the gap to collect')
) AS v(so, role, job);

-- 50. pp.70-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch10 Fabinho', '6 draws the block, lifts ball behind',
    'Against a box-line block with no gaps, the 6 combines quickly with a team-mate on his line (left-back, or a right-back being pressed after a switch) to draw opponents out, then steps forward to receive and lifts the ball over the line into the space before the keeper for a runner pulling off to the far side.',
    'Opponent compact across the edge of the box',
    'Pull the block forward so a chipped pass behind becomes possible.',
    NULL, 70, 71, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Fabinho)', 'combine to draw pressure, step forward, lift the ball over the line'),
    (2, 'Full-back (Robertson / Alexander-Arnold)', 'quick combination, pass inside'),
    (3, 'Far-side attacker', 'pull off the line and run in behind')
) AS v(so, role, job);

-- 51. pp.71-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch10 Fabinho / Ch11 Naby Keita', 'Midfield carrier beats the presser, overload',
    'A press-resistant midfielder receives with a presser close (central, half-space or near the touchline), waits for the defender to commit, then rolls or drops his shoulder past him and accelerates through the gap; each beaten player pulls another defender to him.',
    'Opponent engages the midfielder in possession',
    'Break a line by dribble so attackers already central plus an overlapping/underlapping full-back create an overload (even a defender facing 1v3).',
    NULL, 71, 76, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Keita / Fabinho)', 'invite contact, beat the man, drive into the final third'),
    (2, 'Left wide forward (Mane)', 'occupy the nearest defender'),
    (3, 'Left-back (Robertson)', 'overlap or underlap the defender pulled out of his slot'),
    (4, 'Front three', 'stay central to receive the overload')
) AS v(so, role, job);

-- 52. pp.77-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'out_of_possession', 'Ch11 Naby Keita', '6 holds, both 8s jump to press',
    'When the opponent builds through midfield, the 6 stays deep almost as part of a back five, letting the left and right midfielders step out aggressively to engage the ball carrier and use their bodies to stop him progressing. A more conservative left 8 (Wijnaldum) would instead block lanes and hold shape.',
    'Opponent in possession in the midfield area',
    'Higher, more aggressive midfield pressing while the 6 protects the space behind.',
    NULL, 77, 77, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Fabinho)', 'stay deep, form a line of five with the defence'),
    (2, 'Left midfielder (Keita)', 'step out and press the carrier'),
    (3, 'Right midfielder (Henderson)', 'step out and press the carrier')
) AS v(so, role, job);

-- 53. pp.80-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Ch12 Sadio Mane', 'Wide forward starts deeper to arrive at speed',
    'The left wide forward takes up a central/half-space position on a deeper line than the 9 and the right wide forward, so that when he receives a diagonal pass from the back he can turn and drive at the back line already at top speed and burst through gaps; near goal he squares to the central forwards rather than shoot from a tight angle.',
    'Ball progressed from the back, diagonal into the left half-space',
    'Use momentum from a deeper start to beat the first challenge and break into the box.',
    NULL, 80, 80, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wide forward (Mane)', 'start deeper in the left half-space, turn and drive, beat the defender, cut back'),
    (2, 'Centre forward and right wide forward (Firmino, Salah)', 'stay higher and attack the box for the cut-back'),
    (3, 'Defender in build-up', 'play the diagonal pass into the space')
) AS v(so, role, job);

-- 54. pp.81-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Sadio Mane', 'Deep-start half-space run past held ball',
    'Liverpool 2019/20: Salah, receiving centrally after swapping sides with Firmino, slows the move and waits; Mane starts from a deeper half-space position and is already at full speed when he passes Salah.',
    'Central forward receives facing a set back line and slows play',
    'Through pass behind the line onto a runner the defence never picked up.',
    NULL, 81, 81, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central forward (Salah)', 'Hold the ball, wait for support, release through the line'),
    (2, 'Left forward (Mane)', 'Start deep in the half-space, time the sprint to pass the ball carrier at speed'),
    (3, 'Striker (Firmino)', 'Swap to the wide side to open the centre')
) AS v(so, role, job);

-- 55. pp.81-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Sadio Mane', 'Wide forward attacks the line immediately',
    'Mane receives wide or in a half-space against a deep block (Spurs) and, instead of waiting, fakes inside and drives past the nearest defender on the outside, or combines one-two with Firmino at full speed.',
    'Receiving with a defender in front and space beyond',
    'Turn a slow attack into a run behind the line, then cut back or combine into the box.',
    NULL, 81, 82, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left forward (Mane)', 'Attack the nearest defender at once, fake and go outside'),
    (2, 'Other forwards', 'Run to the edge of the six-yard box for the cut-back'),
    (3, 'Striker (Firmino)', 'Offer a short wall pass/flick while Mane keeps running'),
    (4, 'Midfielder (Wijnaldum)', 'Short vertical pass into Mane to tempt defenders out')
) AS v(so, role, job);

-- 56. pp.82-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Sadio Mane', 'Full-back beats a man, winger takes vacated half-space',
    'From a free-kick Van Dijk finds Robertson wide; Robertson dribbles past one defender, a second steps out to him, and Mane drifts into the gap that defender left.',
    'Second defender steps out to the dribbling full-back',
    'Simple inside pass into the vacated half-space for a shot.',
    NULL, 82, 82, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left-back (Robertson)', 'Give width, carry down the outside and beat the first man'),
    (2, 'Left forward (Mane)', 'Drift into the space the stepping defender vacates'),
    (3, 'Centre-back (Van Dijk)', 'Switch play out to the full-back')
) AS v(so, role, job);

-- 57. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Mohamed Salah', 'Forward drops, full-back runs beyond',
    'Against a stubborn Bournemouth block, Salah drifts out of the centre to receive in space; instead of shooting he waits as Robertson runs from left-back through the half-space and times the pass through the line.',
    'Forward receives unpressured just outside the box while a full-back starts a run',
    'Through ball onto an unmarked full-back behind the back line.',
    NULL, 85, 85, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right forward (Salah)', 'Drift toward the ball, attract defenders, disguise and weight the through pass'),
    (2, 'Left-back (Robertson)', 'Vertical run through the half-space beyond the line'),
    (3, 'Left forward (Mane)', 'Start the move with the cross-field pass')
) AS v(so, role, job);

-- 58. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Mohamed Salah', 'Receive on high line and run at goal',
    'Salah takes a loose ball after a quick throw-in where two opponents missed the header, and immediately angles his run at the penalty area, beating two challengers with a shooting feint.',
    'Receiving in space on the highest line',
    'Turn and engage defenders at once (verticality) instead of recycling.',
    NULL, 85, 85, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right forward (Salah)', 'First thought: attack the box; feint to shoot and carry on'),
    (2, 'Thrower / wide player', 'Take the throw quickly before the defence sets')
) AS v(so, role, job);

-- 59. pp.85-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_attack', 'Mohamed Salah / Anatomy of a goal', 'Front line stays high out of possession',
    'Klopp''s forwards (Salah especially, often Mane too) do little defending beyond pressing the immediate transition; they stay central and high, saving energy, so the moment the ball is won there is an outlet on the last line. Cited for the Wolves and Arsenal examples and goals four (Newcastle) and seven (Arsenal).',
    'Ball regained anywhere',
    'Instant vertical pass to a forward on the highest line with defenders unable to cover, often 1v1.',
    NULL, 85, 100, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right forward (Salah)', 'Stay central/high, ready to explode into space on the regain'),
    (2, 'Left forward (Mane)', 'Stay on the highest line in space when not needed in the press'),
    (3, 'Midfielders', 'Win the ball and play forward at once')
) AS v(so, role, job);

-- 60. pp.86-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'out_of_possession', 'Mohamed Salah', 'Press trigger: bad pass near own box',
    'Wolves try to build through the box; a hard, slightly lofted diagonal pass reaches a player close to his own area facing his goal, with Salah and Firmino central and no opponent between them and the ball.',
    'Poor pass: hard/bouncing, receiver near own box facing own goal',
    'Win the ball high and give it straight to the central forward.',
    NULL, 86, 86, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest forward', 'Engage the receiver as soon as the pass is played'),
    (2, 'Midfielder (Henderson)', 'Step up high to win the knocked-on ball'),
    (3, 'Right forward (Salah)', 'Stay central to receive the regain')
) AS v(so, role, job);

-- 61. pp.87-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Mohamed Salah', 'Blindside double movement vs back five',
    'Against a five-man back line, with little movement around him, Salah first runs away from the ball onto the blindside of his marker, forcing him to adjust, then cuts back across him onto a pass Henderson drops between the line and the keeper. Back five not tied to a listed shape.',
    'Ball reaches the half-space midfielder with the front line static',
    'Unbalance the marker and get in behind for a chance.',
    NULL, 87, 87, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right forward (Salah)', 'Move away to the blindside, then cut across the defender'),
    (2, 'Right midfielder (Henderson)', 'Read the run and drop the ball between line and goalkeeper')
) AS v(so, role, job);

-- 62. pp.87-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'out_of_possession', 'Mohamed Salah', 'Lopsided block covering the right-back',
    'Because Salah stays high, the defensive block is uneven: on the left Mane tracks back to cover Robertson, while on the right Henderson and Fabinho slide across to protect Alexander-Arnold from being isolated.',
    'Ball goes to the opponent''s left (Liverpool''s right)',
    'Keep Salah high for counters without leaving the right-back 2v1.',
    NULL, 87, 87, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left forward (Mane)', 'Drop to cover the left-back'),
    (2, 'Right forward (Salah)', 'Stay high and central'),
    (3, 'Midfielders (Henderson, Fabinho)', 'Drift across to the right to help the right-back'),
    (4, 'Right-back (Alexander-Arnold)', 'Defend with midfield help rather than a winger')
) AS v(so, role, job);

-- 63. pp.87-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_attack', 'Mohamed Salah', 'Counter after opponent set piece',
    'With the opposition still recovering shape after their own set piece, Liverpool move the ball to the left where Mane has a free vertical lane; as it crosses halfway Salah starts a vertical run to stretch the line.',
    'Regain while opponent is out of shape after a set piece',
    'Angled forward pass into Salah''s run while the defender is isolated.',
    NULL, 87, 87, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left forward (Mane)', 'Carry up the free vertical lane, play the angled ball forward'),
    (2, 'Right forward (Salah)', 'Sprint vertically from halfway to stretch the line')
) AS v(so, role, job);

-- 64. pp.88-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Mohamed Salah / Roberto Firmino', 'High/low movement vs deep block',
    'Against a compact, passive back line, Firmino drops into the ''10'' space (nobody follows) while a forward on the other side makes a diagonal run beyond; or Firmino drops off to lose his marker and then re-enters the box (Salzburg, compact blocks) as Mane combines.',
    'Deep block refuses to step out; striker drops unfollowed',
    'Distract the line with the drop and break it with the run in behind.',
    NULL, 88, 93, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Firmino)', 'Drop into the 10 space to show, then turn back toward the box'),
    (2, 'Right forward (Salah)', 'Diagonal run onto the highest line beyond the drop'),
    (3, 'Left forward (Mane)', 'Spot the run and play the pass / lateral feed')
) AS v(so, role, job);

-- 65. pp.91-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Roberto Firmino', 'Striker drifts wide, near post opens',
    'Firmino pulls out to the left wide area; Mane moves central and Salah sits on the right. Firmino attacks the box at an angle, drags the nearest defender to him, beats him both ways, and squares to the near post.',
    'Defender leaves the centre to engage the wide striker',
    'Use the defender''s step-out to free Mane at the near post.',
    NULL, 91, 91, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Firmino)', 'Drift wide, carry at an angle, draw and beat the defender'),
    (2, 'Left forward (Mane)', 'Move inside to the near post'),
    (3, 'Right forward (Salah)', 'Hold the far side')
) AS v(so, role, job);

-- 66. pp.91-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Roberto Firmino', 'Tight-space one-two in a packed box',
    'With no space inside the Spurs box, the ball goes centrally to Salah, who plays Firmino on the left; Firmino lets it run past his marker and shifts quickly beyond the line.',
    'Crowded box, short pass to a forward with a defender tight',
    'Manipulate the ball in tight areas to create a shooting chance.',
    NULL, 91, 91, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Firmino)', 'Let the ball run, spin past the defender beyond the line'),
    (2, 'Right forward (Salah)', 'Receive centrally and circulate quickly to Firmino')
) AS v(so, role, job);

-- 67. pp.92-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Roberto Firmino', 'Dropping 9 dribbles, draws, slips through',
    'Firmino drops into central space while Salah moves high and central and Mane stays wide left. He beats the nearest defender into the gap in front of the back line, pulls three players onto him, then slips a through ball for Mane''s diagonal run.',
    'Defenders converge on the striker in front of the line',
    'Overload the back line by attracting defenders, then release the runner they left.',
    NULL, 92, 92, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Firmino)', 'Isolate and beat a defender, carry into the pocket, draw pressure, slide pass'),
    (2, 'Left forward (Mane)', 'Diagonal run into the box behind the drawn defenders'),
    (3, 'Right forward (Salah)', 'Move higher and central to pin the line')
) AS v(so, role, job);

-- 68. pp.93-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Roberto Firmino', 'Firmino as reference point in the 10',
    'Dropping off the front line into the ''10'' space, Firmino sits centrally where he can reach every part of the final third; from there he takes possession, links the attacking structure and switches play (e.g. to Robertson high on the left).',
    'Team settled in its attacking structure',
    'Give the attack one central hub that connects and changes the point of attack.',
    NULL, 93, 93, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Firmino)', 'Drop off the line into the 10, receive and link, switch wide'),
    (2, 'Left-back (Robertson)', 'Push high to receive the switch'),
    (3, 'Wide forwards', 'Occupy the box/half-spaces around him')
) AS v(so, role, job);

-- 69. pp.93-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Roberto Firmino', 'Delayed late run from deep',
    'Against a well-drilled Salzburg block, Robertson feeds Mane down the outside, dragging a defender wide; Firmino, from the deeper space, times an unnoticed vertical run that splits the block and arrives at the front post for the ball in.',
    'Wide forward carries down the flank and pulls a defender out',
    'Arrive late in the box on timing rather than pace.',
    NULL, 93, 93, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Firmino)', 'Start deep, run late and vertically into the front post'),
    (2, 'Left forward (Mane)', 'Go high down the wide area, drag a defender, deliver'),
    (3, 'Left-back (Robertson)', 'Play the pass down the outside')
) AS v(so, role, job);

-- 70. pp.94-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Anatomy of a goal (Goal One, Salah vs West Ham)', 'Pinned front three, switch, cut-back',
    'Mane left and Salah right pin defenders while Firmino drops deep; Mane drags the full-back inside, opening the switch to Robertson, who breaks into the box at an angle; Firmino''s deep run into the area pulls defenders and frees Salah for the cut-back.',
    'Opposition full-back follows the inside forward',
    'Overlapping full-back cut-back to an unmarked central forward.',
    NULL, 94, 95, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left forward (Mane)', 'Move inside, take the full-back with him'),
    (2, 'Left-back (Robertson)', 'Receive the switch, break into the box, cut back'),
    (3, 'Striker (Firmino)', 'Decoy run deep into the box'),
    (4, 'Right forward (Salah)', 'Find space as his marker is distracted, finish centrally'),
    (5, 'Midfielder (Oxlade-Chamberlain)', 'Receive in the opposition half and switch')
) AS v(so, role, job);

-- 71. pp.96-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Anatomy of a goal (Goal Two, Firmino vs Leicester)', 'Drop, lay-off, stretch, run the gap',
    'Mane, high in the centre, drops to receive from Fabinho and pulls a centre-back out; he lays off to the unmarked Firmino, who stretches play wide to Alexander-Arnold; as the block slides over, Firmino angles his run through the gap to meet the cross.',
    'Centre-back follows the dropping forward',
    'Make the block shift and narrow, then attack the gap it opens.',
    NULL, 96, 96, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left forward (Mane)', 'Drop to show for the vertical pass, pull a centre-back, lay off'),
    (2, 'Striker (Firmino)', 'Receive free, switch wide, then run through the gap'),
    (3, 'Right-back (Alexander-Arnold)', 'Advance into space and cross'),
    (4, 'Defensive midfielder (Fabinho)', 'Play the forward pass into the dropping forward')
) AS v(so, role, job);

-- 72. pp.97-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Anatomy of a goal (Goal Three, Keita vs Monterrey)', 'Back-to-goal touch triggers midfield run',
    'Two high central forwards pin three defenders; the ball goes from centre-back to right-back, changing the angle, and a diagonal finds Salah, whose first touch goes back toward his own goal instead of spinning. That touch cues Keita to run vertically beyond the line for Salah''s through ball.',
    'Forward''s backward first touch',
    'Midfielder arrives unmarked behind the pinned defence.',
    NULL, 97, 97, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left central midfielder (Keita)', 'Run vertically past the defenders on the cue touch'),
    (2, 'Right forward (Salah)', 'Receive the diagonal, set it back toward own goal, play the through ball'),
    (3, 'Two forwards', 'Stay high and pin three defenders'),
    (4, 'Right-back', 'Receive from the centre-back and play the diagonal')
) AS v(so, role, job);

-- 73. pp.98-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_defend', 'Anatomy of a goal (Goal Four, Mane vs Newcastle)', 'Two-man counter-press, forwards stay high',
    'Newcastle break centrally; two Liverpool players move forward together to press the ball and force a turnover while two forwards stay high, out of the press. The regain is central and Mane is still on the last line in space.',
    'Opponent carries the ball centrally in transition',
    'Win it back and play an immediate vertical pass for the run in behind.',
    NULL, 98, 98, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two nearest players', 'Step forward together and press the ball carrier'),
    (2, 'Left forward (Mane)', 'Stay on the highest line, run beyond on the regain'),
    (3, 'Second forward', 'Stay high, ignore the defensive transition')
) AS v(so, role, job);

-- 74. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'in_possession', 'Anatomy of a goal (Goal Five, Salah vs Newcastle)', 'Wall pass off the high nine',
    'Salah, in the half-space, drops to receive ahead of Newcastle''s midfield and plays straight to Firmino on the highest line; Firmino holds off his marker and flicks it back into Salah''s path as he follows his pass at pace.',
    'Forward receives ahead of the midfield block with the striker on the last line',
    'Progress immediately and get the runner through with a return pass.',
    NULL, 99, 99, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right forward (Salah)', 'Drop to receive in the half-space, play forward, follow the pass at speed'),
    (2, 'Striker (Firmino)', 'Hold the last line, shield the ball, flick it back')
) AS v(so, role, job);

-- 75. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'out_of_possession', 'Anatomy of a goal (Goal Six, Mane vs Burnley)', 'Positional press forces error, direct ball',
    'Burnley look for a way round or through a well-set Liverpool block; Salah''s position against their left-back pushes the ball back to the centre-back, who under little direct pressure plays it straight to Firmino. Firmino immediately plays beyond the line for Mane running from deep in the half-space.',
    'Opponent forced back to the centre-back with no forward option',
    'Provoke a mistake and punish it with a direct pass behind.',
    NULL, 99, 99, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right forward (Salah)', 'Position on the full-back to block the forward pass'),
    (2, 'Striker (Firmino)', 'Intercept and play first-time beyond the line'),
    (3, 'Left forward (Mane)', 'Run from a deep half-space position onto the pass')
) AS v(so, role, job);

-- 76. pp.100-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-king-klopp'), 'to_attack', 'Anatomy of a goal (Goal Seven, Salah vs Arsenal)', 'Diagonals out, then isolate far forward',
    'After winning the ball deep in their own half with no vertical pass on, Liverpool go quickly right then back central with diagonal passes to beat Arsenal''s first press line, then pass vertically into the half-space to Salah. Firmino and Mane sit close together, leaving Salah 1v1 on the far side.',
    'Deep regain with the forward pass blocked',
    'Overload one side with two forwards so the third is isolated 1v1 with no cover.',
    NULL, 100, 100, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders / midfielders', 'Quick diagonal passes through the first line, then vertical'),
    (2, 'Right forward (Salah)', 'Stay isolated on the far side, collect and roll the defender'),
    (3, 'Firmino and Mane', 'Stay close together to occupy defenders and deny cover')
) AS v(so, role, job);

COMMIT;
