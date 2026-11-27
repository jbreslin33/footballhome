-- 2152 📚 Coaching book patterns: "Creative Attacking Play" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Creative Attacking Play',
    subtitle    = 'From the Tactics of Conte, Allegri, Simeone, Mourinho, Wenger & Klopp',
    author      = 'Athanasios Terzis',
    team        = 'Wenger, Klopp, Simeone, Allegri, Conte, Mourinho sides',
    method_note = 'How six coaches'' teams create chances against a set defence (mostly a 4-4-2), one chapter each with analysis then a session. General principles (the final pass, pass-range zones, receiving between the lines, dragging a defender out); numerical set-ups by our shape against a 4-4-2; Wenger (the 6 behind the pressing forward, the winger as link to the 10); Klopp (making a 3v2 in midfield by dropping the winger, 10 or full back); Simeone (inside wingers'' 2v1 on the centre backs, blind-side runs); Allegri (forward or winger dropping into the pocket and what follows if marked); Conte (forwards shifting across to overload one centre back); Mourinho (wingers moving inside and the full back''s choice). Patterns are the match behaviours, in our words. App page 1 is the book''s printed page 1.'
WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge');

-- 1. pp.18-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Attacking Against Organised Defences - Final Pass / Direction and Angle of Passes', 'Diagonal final pass away from keeper',
    'Against a middle block a straight vertical ball through the middle runs towards the goalkeeper, who sweeps it up; against a deep block there is about 30 yards less space for it.',
    'Runner ready to attack space behind the back line',
    'Play the ball in behind on a diagonal into a wider lane, away from the keeper, so the runner can shoot or cross.',
    NULL, 18, 21, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder / passer', 'Angle the medium or long pass diagonally towards the wide channel behind the defence'),
    (2, 'Forward or winger', 'Time a diagonal run behind the full back / centre back into the wider space'),
    (3, 'All attackers', 'Read the goalkeeper''s position before choosing straight or diagonal')
) AS v(so, role, job);

-- 2. pp.21-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Attacking Against Organised Defences - Range and Distance of Passes', 'Move ball closer for short final pass',
    'Final passes can come from the long range zone (deep defenders), the medium zone (between opponent forwards and midfield) or the short zone (between their midfield and back line); against a deep block the zones are compressed.',
    'Possession against a settled middle or deep block',
    'Advance the ball into the short range zone so the final pass is short, accurate and leaves defenders little time to react.',
    NULL, 21, 23, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Long final passes only if top quality passers; otherwise circulate'),
    (2, 'Full backs / central midfielders', 'Deliver medium range final passes from advanced positions'),
    (3, 'Wingers (4-4-2 / 4-2-3-1)', 'Drop into the medium zone to receive and play the final pass'),
    (4, 'Players between the lines', 'Receive in the short zone and play the last pass to a forward runner')
) AS v(so, role, job);

-- 3. pp.25-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Build-Up Play to Receive in Space and Play Forward Passes', 'Receive between forward and midfield lines',
    'In build-up the key zone is the gap between the opponent''s forward and midfield lines (vs a 4-4-2 block). A CM who receives there with time can play forward; passes forced from deeper let the opposing midfield keep a safe distance and cut them out.',
    'Centre back or full back has the ball and a CM is free in the gap',
    'Get a CM on the ball in that gap facing forward so he can thread a medium pass to players between the lines or runners behind.',
    '4-4-2', 25, 27, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Pass into the CM in the gap rather than forcing a through ball from deep'),
    (2, 'Full back', 'Alternatively pass inside to the CM in the gap'),
    (3, 'Central midfielder (No.6)', 'Receive in the gap, look up and play forward to 7, 9 or 10'),
    (4, 'Wingers / No.10 / forward', 'Offer forward options between the lines or behind')
) AS v(so, role, job);

-- 4. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Build-Up Play to Receive in Space and Play Forward Passes - Scenario 4', 'Space in front of CBs vs one forward',
    'Against a lone forward with a No.10 behind him (4-2-3-1), the gap between their forward and midfield is crowded, but there is space beside the forward in front of our centre backs.',
    'Opponent defends with one forward plus a No.10',
    'Both CMs drop into the spaces beside the lone forward, receive from defenders and get heads up to play forward.',
    '4-2-3-1', 28, 28, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (6 and 8)', 'Take positions either side of the lone forward in front of the centre backs'),
    (2, 'Centre backs', 'Feed the free CM quickly'),
    (3, 'Advanced players', 'Prepare to receive the forward pass')
) AS v(so, role, job);

-- 5. pp.30-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Receiving Between the Lines and Attacking in a 4 v 4 Situation', 'Receive between lines with 4v4 numbers',
    'Against a back four, the favourable situation needs at least 4 attackers v 4 defenders and a player receiving between the opponent''s midfield and back lines either facing goal or with back to goal and time to turn.',
    'Attacker free between the lines, not double-marked',
    'Turn and exploit equality in numbers with a short shot or final pass; if he is double marked or cannot turn, the advantage is gone.',
    NULL, 30, 35, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player between the lines', 'Receive facing goal or, if back to goal, turn when there is time'),
    (2, 'Front attackers', 'Keep the 4v4 by occupying the back four'),
    (3, 'Passer (CM)', 'Choose the moment when the receiver is free of double marking')
) AS v(so, role, job);

-- 6. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Receiving Between the Lines - Receiving in Behind the Defensive Line', 'Drag defender out, run into gap',
    'Best way behind the line is first pulling a defender out of position; e.g. full back receives between midfield and back lines, drawing the opposing full back out.',
    'Opposing full back steps out to the receiver',
    'Open a lane through the gap so the forward can run in behind for a 1v1 with the keeper (central) or a cross (wide).',
    NULL, 31, 31, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right full back (2)', 'Advance and receive between the lines to draw the opposing full back'),
    (2, 'Forward (9)', 'Time a run into the gap behind the defender who stepped out'),
    (3, 'Centre backs / CMs', 'Switch the ball to the full back after building on the far side')
) AS v(so, role, job);

-- 7. pp.32-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Exploiting 1 v 1 Situations on the Flank', 'Isolate full back in 1v1 wide',
    '4-4-2 v 4-4-2 gives 1v1s on both flanks and a 2v2 in the centre (overall 4v4 high up). A skilful winger can be isolated against the opposing full back with no help nearby.',
    'Winger isolated on the far side, facing up or with time to turn',
    'Long diagonal from a CM to the winger who receives facing goal and attacks the isolated full back.',
    '4-4-2', 32, 33, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (6)', 'Play the long diagonal to the isolated winger'),
    (2, 'Winger (7)', 'Stay wide, receive facing goal and take on the full back'),
    (3, 'Forwards', 'Pin the centre backs so no cover arrives')
) AS v(so, role, job);

-- 8. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Exploiting a 2 v 2 Situation in the Centre (Forwards vs Centre Backs)', 'Forward drops, turns in 2v2',
    'With two forwards against a back four there is a 2v2 against the centre backs. One forward drops between the lines, receives through the centre and turns.',
    'Forward drops off and has time to turn',
    'Turn, drive forward and shoot or play the final pass behind the line.',
    '4-4-2', 34, 34, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (10)', 'Drop off the centre back, receive back to goal and turn'),
    (2, 'Central midfielder (8)', 'Pass through the centre into the dropping forward'),
    (3, 'Other forward (9)', 'Hold the other centre back and run behind for the final pass')
) AS v(so, role, job);

-- 9. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Exploiting a Numerical Equality (4-2-3-1 vs 4-4-2)', 'No.10 key player, 3v2 midfield',
    'Our 4-2-3-1 v 4-4-2 gives 1v1 on each flank, 1v2 for the striker and a 3v2 in central midfield via the No.10.',
    'No.10 receives between the lines',
    'If free, No.10 turns and attacks the 4v4; if pressed with back to goal, he quickly finds a winger to keep the 4v4.',
    '4-4-2', 36, 36, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'Receive between the lines; turn if free, else lay quickly to a winger'),
    (2, 'Wingers (7, 11)', 'Stay wide in 1v1 and receive the quick pass'),
    (3, 'Central midfielders (6, 8)', 'Form the 3v2 with the No.10 and feed him'),
    (4, 'Striker (9)', 'Occupy the centre backs')
) AS v(so, role, job);

-- 10. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Exploiting a Numerical Equality (4-3-3 vs 4-4-2)', 'Two No.8s attack between lines',
    'In 4-3-3 v 4-4-2, the two attacking midfielders (8 and 10) create the 3v2 in midfield and either one can push between the lines.',
    'An attacking midfielder gets between the lines',
    'Receive and attack the 4v4, or under pressure lay off quickly to a winger to keep the 4v4.',
    '4-4-2', 37, 37, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielders (8, 10)', 'Alternate advancing between the lines to receive'),
    (2, 'Holding midfielder (6)', 'Feed the advanced 8/10'),
    (3, 'Wingers (7, 11)', 'Hold width for the 1v1s and quick layoffs')
) AS v(so, role, job);

-- 11. pp.39-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 1: Intelligent Positioning to Receive Between the Lines (Arsene Wenger)', 'No.6 receives behind pressing forward',
    'Against two forwards pressing the centre backs, a gap opens behind a forward who steps up, especially if their forward-midfield distance is large.',
    'Opposing forward presses the centre back',
    'CB passes wide/across and the No.6 slides into the space behind the presser, receives, turns and drives forward.',
    '4-4-2', 39, 40, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (4, 5)', 'Circulate to pull a forward into pressing'),
    (2, 'Defensive midfielder (6)', 'Move into the space behind the pressing forward, receive and turn'),
    (3, 'Other CM (8)', 'Hold position so the opposing CM cannot step up into the space')
) AS v(so, role, job);

-- 12. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 1 (Wenger) - Creating Space in Centre by Passing Wide to the Full Back', 'Wide to full back frees No.6',
    'CB plays out to the right back while No.10 and winger offer for a through pass; the opposing CM must choose between supporting his winger (blocking the lane to 10) or tracking our No.6.',
    'Ball reaches our full back',
    'If their CM drops to cover, No.6 gets the square pass free in the centre; if he stays on No.6, the inside lane to No.10 opens for a 4v4 attack.',
    '4-4-2', 41, 41, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (4)', 'Pass wide to the right back'),
    (2, 'Right back (2)', 'Read the opposing CM and pass square to 6 or inside to 10'),
    (3, 'Defensive midfielder (6)', 'Shift across for the square pass'),
    (4, 'No.10 and right winger (7)', 'Offer for the through pass between the lines')
) AS v(so, role, job);

-- 13. pp.42-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 1 (Wenger) - Midfield Presses and Leaves Space; Link Player', 'Winger as link player to No.10',
    'The opposing CM steps up to deny or press our No.6, leaving space behind him between the lines, but a direct pass to No.10 is blocked.',
    'Their CM closes down our No.6 / the direct lane to 10 is shut',
    'The right winger acts as a ''link player'', receiving and playing first time inside to No.10 before their winger shifts across, giving a 3v3 that ends with a ball behind for the 9 or across to the far winger.',
    '4-4-2', 42, 43, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (2) / No.6', 'Pass to the right winger when the inside lane is closed'),
    (2, 'Right winger (7)', 'Link player: one-touch pass inside to No.10'),
    (3, 'No.10', 'Receive in the space behind the pressing CM and turn'),
    (4, 'Forward (9) and left winger (11)', 'Run behind and arrive from deep for the final ball')
) AS v(so, role, job);

-- 14. pp.44-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 1 (Wenger) - Centre Back Denies No.10 but Creates Space Behind', 'CB steps to 10, 9 runs behind',
    'A chain reaction: their CM closes our 6, their centre back steps out to mark our 10, leaving space behind that centre back.',
    'Opposing centre back follows No.10 out',
    'Forward times his run into the vacated space; No.6 plays a direct aerial pass behind, or via the right winger as link player.',
    '4-4-2', 44, 45, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (9)', 'Run into the space left by the stepping centre back'),
    (2, 'Defensive midfielder (6)', 'Accurate medium-range lofted pass behind'),
    (3, 'Right winger (7)', 'Link player into the space if the direct pass is blocked'),
    (4, 'No.10', 'Drag the centre back out'),
    (5, 'Left winger (11)', 'Arrive to finish a cut-back')
) AS v(so, role, job);

-- 15. pp.46-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 1 (Wenger) - Receiving Against One Forward', 'Switch to weak-side CM',
    'Against a lone forward with a No.10, their 10 shifts to close the strong-side CM, but space opens for our weak-side CM.',
    'Their No.10 shifts to restrict our strong-side No.6',
    'Switch quickly, directly to the weak-side No.8 or via the centre back (or goalkeeper) as link player, before their 9 and 10 can shift back.',
    '4-2-3-1', 46, 46, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back (4)', 'Switch directly to No.8 or back via the other CB'),
    (2, 'Weak-side CM (8)', 'Find the free space, receive and turn'),
    (3, 'Strong-side CM (6)', 'Drop to attract their No.10'),
    (4, 'Left centre back (5) / goalkeeper', 'Link player for the safer switch')
) AS v(so, role, job);

-- 16. pp.48-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Session 1 (Wenger): Receiving Between the Lines - Practice 1', 'CB-FB-CM-winger-forward combination patterns',
    'Unopposed position-specific pattern rehearsing the chapter''s moves: CB 1-2 with CM, full back inside, winger drops back, 1-2 with forward between the lines, third-man release behind.',
    'Centre back starts with the ball',
    'Automate the passing routes that free a player between the lines and a runner in behind.',
    NULL, 48, 48, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (4, 5)', '1-2 with the CM, then pass to the full back'),
    (2, 'Full backs (2, 3)', 'Pass inside to the CM or forward to the winger'),
    (3, 'Wingers (7, 11)', 'Drop back to receive, 1-2 with the forward, curved run behind'),
    (4, 'Forward (9)', 'Move into the between-lines space for the combination, then run in behind')
) AS v(so, role, job);

-- 17. pp.49-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Session for Wenger Tactics - Receiving Between the Lines', 'Link player to reach the No.10 between lines',
    'Back four plus two holding mids build against a midfield four and two forwards; the aim is to get the ball to the No.10 in the pocket between the opposition midfield and back lines, always via a full back first.',
    'Direct pass to the No.10 blocked (CM pressed or winger closes inside lane)',
    'No.10 receives facing goal between the lines and slips the striker in behind.',
    '4-4-2', 49, 53, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'receives first; plays into CM or forward to the winger when the inside lane is shut'),
    (2, 'Central midfielder (8)', 'pressed, uses the winger as a wall to reach the 10'),
    (3, 'Right winger (7)', 'acts as link player, lays the ball into the 10 between lines'),
    (4, 'No.10', 'times his move into the pocket, receives and plays in behind for the 9'),
    (5, 'Forward (9)', 'runs in behind for the final pass')
) AS v(so, role, job);

-- 18. pp.51-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Session for Wenger Tactics - Receiving Between the Lines (4-3-3 / 4-4-2 variations); Klopp session 4-3-3 variations', 'Interior mids rotate: one drops, one pushes up',
    'In a 4-3-3 the two attacking midfielders swap levels: the weak-side one drops into the deeper zone to support the build-up while the strong-side one steps into the pocket between the lines; in a 4-4-2 the strong-side forward drops into the pocket and the other forward shifts across.',
    'Centre back passes across to his partner / ball goes to the full back',
    'Keep balance behind the ball and still put a free receiver between the opposition lines.',
    '4-4-2', 51, 71, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side attacking midfielder', 'drops back into the first zone for balance and support'),
    (2, 'Strong-side attacking midfielder', 'moves up into the space between midfield and defence'),
    (3, 'Strong-side forward (4-4-2)', 'drops a few yards into the pocket when the full back has it'),
    (4, 'Other forward', 'shifts towards the strong side'),
    (5, 'Lone forward (9) in 4-3-3', 'drops as link player to set the advanced midfielder')
) AS v(so, role, job);

-- 19. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Session for Wenger Tactics - Zonal Game', 'Defender steps out to 10, exploit space behind',
    'When a centre back leaves the line to mark the No.10 in the pocket, the attack plays into the gap he left.',
    'Opposition defender steps into the zone to press the No.10',
    'No.10 plays first time through the vacated space to the winger, who crosses into the box.',
    '4-4-2', 53, 53, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'reads the stepping defender, plays first time behind him'),
    (2, 'Winger (7)', 'runs into the space out wide and crosses'),
    (3, 'Forward (9)', 'attacks the box for the cross')
) AS v(so, role, job);

-- 20. pp.55-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 2 Klopp - a) Winger Drops Back into Central Midfield to Create a 3 v 2 and Receive', 'Winger drops inside for central 3 v 2',
    'Against a 4-4-2 the strong-side winger drops inside into central midfield beside the two holding mids, making 3 v 2 against the opposition central pair and giving the centre back a free passing option.',
    'Centre back on the ball with time (space behind the opposition forward)',
    'Free player in midfield to progress the ball; strong-side full back''s forward run restores 4 v 4 up front.',
    '4-4-2', 55, 74, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side winger (7)', 'drops back and inside to receive from the centre back'),
    (2, 'Weak-side central midfielder (8)', 'moves forward into a balanced position, then runs between the lines'),
    (3, 'Strong-side full back (2)', 'pushes forward to replace the winger''s width'),
    (4, 'Weak-side full back (3)', 'drops back and inside for safety'),
    (5, 'Ball-side centre back (4)', 'passes to the free player in the 3 v 2')
) AS v(so, role, job);

-- 21. pp.58-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 2 Klopp - b) No.10 Drops Back to Act as a ''Link Player'' & Move the Ball to the Free Player in the Final Third', 'No.10 link pass to free forward-running CM',
    'After the 3 v 2 is used, the man who drops (winger or No.10) is usually marked, so the No.10 or 9 comes towards the ball and plays a first-time lay-off inside to the CM running between the lines; if the receiving winger is pressed, the free deep CM (6) is used first.',
    'Winger receives and turns / is closed down quickly',
    'CM receives between the lines facing goal with three final-pass options in a 5 v 4.',
    '4-4-2', 58, 59, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'moves into the open lane, plays first time to the arriving 8; if blocked, gives to overlapping full back and runs behind'),
    (2, 'Central midfielder (8)', 'runs between the lines as soon as the winger turns'),
    (3, 'Holding midfielder (6)', 'free deep player when the winger is pressed'),
    (4, 'Forward (9)', 'alternative link player or runner in behind'),
    (5, 'Strong-side full back (2)', 'well-timed forward run as a wide option')
) AS v(so, role, job);

-- 22. pp.60-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 2 Klopp - c) The Opposition Winger is Central, so the Full Back Receives Wide & Moves into the Centre', 'Opposition winger tucks in, full back free',
    'If the opposing winger moves inside to stop the 3 v 2, the full back is left free wide and receives high up in a 5 v 4.',
    'Opposition winger converges to mark our dropping winger',
    'Full back plays behind the left back for the 10''s diagonal run, between full back and centre back for the 9, or dribbles inside and finds the 9 or the arriving 8.',
    '4-4-2', 60, 62, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (2)', 'receives in space wide, passes in behind or dribbles inside'),
    (2, 'No.10', 'diagonal run behind the full back, drags the centre back across'),
    (3, 'Forward (9)', 'runs between full back and centre back'),
    (4, 'Central midfielder (8)', 'arrives in space left in the centre to shoot'),
    (5, 'Right winger (7)', 'drops inside to pull the opposition winger in')
) AS v(so, role, job);

-- 23. pp.63-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 2 Klopp - d) No.10 Drops Back into Central Midfield to Create a 3 v 2 and Receive', 'No.10 drops into midfield, winger inverts',
    'Instead of the winger, the No.10 drops into central midfield for the 3 v 2 while the strong-side winger moves up and inside into the 10 position and the full back pushes on, keeping 4 v 4 in attack.',
    'Centre back on the ball with time',
    'No.10 turns if free or bounces to the 6, and the link player (9 or winger) finds the forward-running 8.',
    '4-4-2', 63, 63, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'drops into central midfield to receive'),
    (2, 'Strong-side winger (7)', 'moves inside into the vacated 10 space as link player'),
    (3, 'Weak-side central midfielder (8)', 'advances and runs between the lines'),
    (4, 'Strong-side full back (2)', 'goes forward for width'),
    (5, 'Weak-side full back (3)', 'drops back and inside for cover')
) AS v(so, role, job);

-- 24. pp.64-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 2 Klopp - e) Full Back Converges Towards the Centre and Creates a 3 v 2 Situation (Guardiola''s 4-3-3)', 'Full back inverts for central 3 v 2',
    'The full back moves inside in line with the two holding mids to make 3 v 2 in midfield, the advanced 8 pushes between the lines and the winger drops a little as an outlet.',
    'Centre back receives with time from his partner',
    'Progress via the inverted full back and a link player to the 8 between the lines, or out to the winger.',
    '4-4-2', 64, 74, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (2)', 'converges into central midfield to receive'),
    (2, 'Central midfielder (8)', 'moves up between the lines'),
    (3, 'Right winger (7)', 'drops a few yards wide as passing option'),
    (4, 'No.10 / forward (9)', 'link player to the 8')
) AS v(so, role, job);

-- 25. pp.65-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 2 Klopp - Opposition winger prevents the full back creating 3 v 2; Session practice 4 scenarios', 'Winger follows inverting full back: go wide',
    'If the opposition winger tracks the inverting full back inside (3 v 3 centrally), the ball goes out to our winger who is isolated 1 v 1 or 2 v 1 with the 10 or 8 running between the opposition full back and centre back.',
    'Opposition winger follows the full back inside',
    'Winger beats his man or the runner gets in behind for a cross or pass into the box.',
    '4-4-2', 65, 74, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'reads it: pass to inverted full back if 3 v 2, otherwise out to the winger'),
    (2, 'Winger (7/11)', 'stays wide, takes on the full back 1 v 1'),
    (3, 'No.10 / advanced 8', 'diagonal run behind or between full back and centre back for 2 v 1'),
    (4, 'Forwards and far winger', 'attack the box for the cross')
) AS v(so, role, job);

-- 26. pp.77-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 3 Simeone - Positioning of Atletico Madrid Players During the Attacking Phase (4-4-2)', 'Atletico 4-4-2: inside wingers, full-back width',
    'Both wingers come back and inside between the opposition lines while the full backs push high to give all the width, putting the opposing full backs in a dilemma.',
    'Attacking phase in the opposition half',
    'If the full back goes to our full back, space opens behind for the forwards; if he holds, the inside winger receives free and turns.',
    '4-4-2', 77, 77, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (7 & 11)', 'position centrally between midfield and back line'),
    (2, 'Full backs (2 & 3)', 'advance to provide width'),
    (3, 'Forwards (9 & 10)', 'pin the centre backs, ready to run in behind')
) AS v(so, role, job);

-- 27. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 3 Simeone - Potential Overloads Created by the Wingers Moving Inside', 'Inside wingers overload the centre backs',
    'With the wingers inside, each centre back''s zone holds a forward and a winger, a 2 v 1 near the box (linked to the book''s later Mourinho winger-shift chapter).',
    'Wingers shift inside alongside the forwards',
    'Centre backs cannot choose between stepping to press the winger and staying with their forward.',
    '4-4-2', 78, 78, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (7 & 11)', 'move into the centre backs'' zones of responsibility'),
    (2, 'Forwards (9 & 10)', 'stay on the centre backs'),
    (3, 'Central midfielders', 'find the free man in the 2 v 1')
) AS v(so, role, job);

-- 28. pp.79-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 3 Simeone - Central Midfielder Receives from Wide & Forward on Weak Side Makes Blind Side Run in Behind', 'Weak-side forward blind-side run behind CB',
    'A central midfielder receives from the full back in space between the opposition forward and midfield lines; the weak-side forward moves onto the blind side of his centre back and then runs in behind.',
    'CM receives with time between the opposition forwards and midfield',
    'Medium-range lofted pass into the forward''s run behind the line, angled away from the keeper.',
    '4-4-2', 79, 88, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (6/8)', 'receives from the full back, plays the medium-range aerial pass'),
    (2, 'Weak-side forward (10)', 'moves away and wide, then onto the CB''s blind side and into the space behind'),
    (3, 'Full back (3)', 'feeds the central midfielder'),
    (4, 'Centre back (5)', 'passes to the full back to start it')
) AS v(so, role, job);

-- 29. pp.80-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 3 Simeone - Variation: The Opposing Full Back Stays Deep so the Winger Receives Between the Lines', 'Full back holds deep: winger free inside',
    'If the weak-side opposing full back stays deep to shut off the blind-side run, the inside winger on that side is unmarked between the lines.',
    'Opposing full back keeps a deep position near his centre back',
    'CM passes to the winger, who turns and attacks in a 4 v 4.',
    '4-4-2', 80, 89, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (6/8)', 'reads the weak-side full back and picks the winger instead of the run'),
    (2, 'Inside winger (7/11)', 'receives between the lines unmarked and turns'),
    (3, 'Forwards', 'attack the back line once the winger turns')
) AS v(so, role, job);

-- 30. pp.81-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 3 Simeone - Central Midfielder Receives in Centre and Both Forwards Make Blind Side Runs in Behind', 'Both forwards blind-side runs behind CBs',
    'A winger drops to receive from the centre back and lays it to the CM in the centre; with both opposing full backs high, both forwards move onto the blind side of their centre backs and run into the space behind the full backs.',
    'CM receives centrally facing forward; opposition full backs high',
    'Accurate medium-range pass behind the line; works even against a deep block if the passer is good.',
    '4-4-2', 81, 89, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping winger (11)', 'drops to receive from the centre back and sets the CM'),
    (2, 'Central midfielder (6/8)', 'plays the lofted or through pass to whichever run is open'),
    (3, 'Forwards (9 & 10)', 'both go to the blind side of a centre back, then run in behind, avoiding offside'),
    (4, 'Central midfield partner', 'readjusts position for support')
) AS v(so, role, job);

-- 31. pp.85-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Session for Simeone Tactics - Reading the Tactical Situation (practices 2-5, 4-2-3-1 variation)', 'Read the weak-side full back to choose',
    'The CM between the lines reads the weak-side opposing full back: if he follows our winger inside (high), play aerial into the blind-side run behind him; if he holds deep, find the winger. In a 4-2-3-1 the lone 9 moves to the weak side as soon as a strong side is formed.',
    'First pass made; CM receives between the lines',
    'Always pick the open option, in behind or between the lines.',
    '4-4-2', 85, 89, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (9) in 4-2-3-1', 'takes a weak-side position early to run off the blind side'),
    (2, 'No.10', 'moves to the strong side'),
    (3, 'Central midfielder (8)', 'checks the weak-side full back, then decides through ball or aerial pass'),
    (4, 'Winger', 'moves inside between the lines and drags the full back')
) AS v(so, role, job);

-- 32. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Session for Simeone Tactics - 11 v 11 Game', 'Centre back steps to winger: combine behind',
    'When both full backs hold deep and the CM finds the inside winger between the lines, a centre back steps out to close him, leaving a gap behind.',
    'Centre back leaves the line to press the receiving winger',
    'Quick combination play into the space the centre back vacated.',
    '4-4-2', 89, 89, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (6)', 'passes to the inside winger'),
    (2, 'Inside winger (11)', 'receives between the lines, draws the centre back, combines'),
    (3, 'Forwards (9 & 10)', 'run into the gap left by the stepping centre back')
) AS v(so, role, job);

-- 33. pp.91-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 4 Allegri - Forward Dropping Back to Receive or Create Space in Behind', 'Forward drops between lines, receives unmarked',
    'With Juventus'' 4-2-3-1 (or 4-4-2), the forward drops off into the pocket between the opposition midfield and back line; the two forwards should be on different sides, one weak and one strong.',
    'CM receives and turns; the centre back does not follow the forward',
    'Forward turns for a 4 v 4 and plays through for the 10''s diagonal run, between centre back and full back for the left winger, or a diagonal lofted ball to the far winger.',
    '4-4-2', 91, 93, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (9)', 'drops into the pocket, receives and turns'),
    (2, 'Central midfielder (8)', 'plays into the dropping forward (a playmaker like Pjanic reads it)'),
    (3, 'No.10', 'diagonal run through the middle'),
    (4, 'Left winger (11)', 'runs between centre back and full back'),
    (5, 'Right winger (7)', 'far-side run for the aerial diagonal')
) AS v(so, role, job);

-- 34. pp.94-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 4 Allegri - Forward Drops Back and is Tightly Marked, Which Creates Space in the Centre', 'Tightly marked forward drops: long ball into gap',
    'If the centre back follows the dropping forward tightly, the CM ignores the forward and plays a long pass into the centre-back space he vacated, for the winger in a 4-2-3-1 or the second forward in a 4-4-2.',
    'Opposing centre back follows the dropping forward',
    'Runner arrives 1 v 1 with the keeper; if the full back tucks in, the overlapping full back is free wide. Best against a mid block (about 30 yards behind).',
    '4-4-2', 94, 95, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (9)', 'drops to pull the centre back out'),
    (2, 'Central midfielder (8)', 'plays a very accurate long pass into the vacated centre'),
    (3, 'Winger (11) / second forward (10)', 'times a diagonal run into the space behind the centre back'),
    (4, 'Full back (3)', 'runs forward wide if the opposition full back narrows')
) AS v(so, role, job);

-- 35. pp.96-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Chapter 4 Allegri - Exploiting Space in Behind with Quick Passing Combination After the Opposition Centre Back Follows the Forward''s Movement', 'CB presses late: first-time lay-off and run behind',
    'The centre back lets the forward drop, then jumps on him once the pass is played; the forward does not turn but plays first time wide to the winger, and the No.10, already running, gets the next pass in the space the centre back left.',
    'Opposing centre back steps up to the forward as the pass arrives',
    'Short final pass behind the line, useful even against a deep block (roles of 10 and winger can swap). Chapter likely continues past page 96.',
    '4-4-2', 96, 96, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (9)', 'drops, plays first time to the winger instead of turning'),
    (2, 'Winger (11)', 'receives inside, plays the ball in behind'),
    (3, 'No.10', 'runs early into the space behind the stepping centre back'),
    (4, 'Central midfielder (8)', 'passes into the forward')
) AS v(so, role, job);

-- 36. pp.97-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch4 Creating & Exploiting Space in the Final Third (Allegri) - Winger Dropping Back to Receive or Create Space Out Wide', 'Winger drops between lines, turns unmarked',
    'When a central midfielder gets the ball with time, the winger drops off the line into the gap between the opposition midfield and back line. If his full back does not follow, he receives, turns and attacks a 5 v 4 near goal.',
    'Central midfielder receives facing forward; opposing full back stays in his line',
    'Winger turns between the lines and plays a short final pass to one of three runners, or shoots. This is effective against a deep block.',
    NULL, 97, 105, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (11)', 'Drop back between the lines as soon as the No.8 receives, turn and pick one of three final passes'),
    (2, 'Central midfielder (8/6)', 'Read the full back and pass to the winger''s feet when he is left free'),
    (3, 'Forward (9), No.10, far winger (7)', 'Make forward runs to give three final-pass options'),
    (4, 'Same-side full back (3)', 'Push forward to add width')
) AS v(so, role, job);

-- 37. pp.98-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch4 Allegri - Winger Drops Back and is Tightly Marked', 'Marked winger drop frees overlapping full back',
    'The winger drops and the opposing full back follows him tightly. That empties the flank behind, so the midfielder skips the winger and plays long into the wide space for the advancing full back.',
    'Opposing full back follows the dropping winger',
    'The full back crosses from the free flank to three runners in a 4 v 3, with the opposition midfield and full back taken out of the play.',
    NULL, 98, 104, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (11)', 'Drop back to pull the full back inside and out of position'),
    (2, 'Central midfielder (8/6)', 'Do not force the pass to the marked winger; play long into the wide space instead'),
    (3, 'Same-side full back (3)', 'Time an advanced run into the empty flank and cross'),
    (4, 'Forwards (9, 10) and far winger (7)', 'Attack the box for the cross')
) AS v(so, role, job);

-- 38. pp.99-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch4 Allegri - Exploiting Space Out Wide with Quick Passing Combination', 'Late-marked winger: combo into wide space',
    'The full back lets the winger drop at first, then closes him quickly once the pass arrives, so he cannot turn. The winger does not try to turn. He uses a quick combination to send the ball into the wide space the full back has left.',
    'Pressure arrives on the winger as he receives',
    'The left back receives free out wide and crosses for three runners.',
    NULL, 99, 107, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (11)', 'Do not turn under pressure; lay off to the No.8 or into the forward'),
    (2, 'Central midfielder (8)', 'Play a long pass into the wide space for the full back after the lay-off'),
    (3, 'Forward (9) or No.10', 'Drop a few yards as the link player and redirect the ball wide (the No.10 does this when he is on the strong side)'),
    (4, 'Left back (3)', 'Run beyond into the vacated space and cross')
) AS v(so, role, job);

-- 39. pp.100-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch4 Allegri - Forward Exploits the Space Out Wide After the Winger Creates Space', 'Forward runs across into vacated flank',
    'The winger''s drop is followed, but the full back is too deep to use the space. The forward runs diagonally across into the channel behind the full back and gets a long pass from the No.8.',
    'Winger is followed and the full back is in a low position',
    'The forward turns the move into a 3 v 3 near the box, with the No.10 and far winger running to finish. This suits a quick forward.',
    NULL, 100, 100, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (9) (or the No.10 when he is on the strong side)', 'Run across into the space behind the opposing full back'),
    (2, 'Central midfielder (8)', 'Play the long pass into that channel'),
    (3, 'No.10 and far winger (7)', 'Make runs into the box to finish'),
    (4, 'Winger (11)', 'Drop back to drag the full back out')
) AS v(so, role, job);

-- 40. pp.102-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Session 4 (Allegri) practice 1 - Forward Dropping Back in Between the Lines', 'Forward drop: read the centre back',
    'The central midfielder on the forward''s side receives after build-up passes, and the forward drops into the gap in front of the centre backs. The man on the ball reads the centre back. Unfollowed means play to feet; followed means play into the space behind for the No.10 or winger; if the forward is marked tight, a combination still uses the space.',
    'Forward drops back; centre back follows or stays',
    'Either the forward turns with three options in behind, or a runner attacks the space the centre back left.',
    NULL, 102, 107, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (9) (in 4-4-2, the forward on the ball side)', 'Drop into the zone between the lines and turn if left free'),
    (2, 'Central midfielder (6)', 'Read the centre back: pass to feet, into the space behind, or start a combination'),
    (3, 'No.10 / wingers (7, 11)', 'Run into the space behind a centre back who follows')
) AS v(so, role, job);

-- 41. pp.109-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch5 Creating an Overload with a Forward Shifting Across (Conte) - Forward on the Weak Side Shifts Across to the Strong Side', 'Weak-side forward shifts to overload centre back',
    'In Conte''s two-striker shape (3-5-2 or 4-4-2), the weak-side forward drops and moves across into the strong-side centre back''s zone once the defensive midfielder has the ball with time. That puts two forwards on one centre back. The ball goes into the strong-side forward, who sets it back to his partner arriving free.',
    'Defensive midfielder receives from the wing back/full back and has time',
    'The shifted forward turns between the lines and attacks a 4 v 4, 5 v 4 or 6 v 4, with one wing back running forward while three stay behind for a 3 v 2 at the back.',
    NULL, 109, 124, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side forward (10)', 'Drop back and across into the strong centre back''s zone, take the lay-off, turn and drive forward'),
    (2, 'Strong-side forward (9)', 'Show for the pass, then lay off to his partner'),
    (3, 'Defensive midfielder (8)', 'Play into the strong-side forward. Pass direct to the No.10 only if he is close enough'),
    (4, 'Wing back / full back (2)', 'Make a forward run as a wide option. The other wing back may join for 6 v 4'),
    (5, 'Back line (3 CBs or deeper full back)', 'Hold a 3 v 2 rest defence behind the attack')
) AS v(so, role, job);

-- 42. pp.111-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch5 Conte - Centre Back Prevents the Overload Which Leads to a Long Pass', 'Followed shift: long ball behind the centre back',
    'The other centre back tracks the shifting forward inside to stop the overload. That leaves a gap in the middle of the back line, which the second forward attacks with a run on the blind side of his marker while the midfielder plays a long pass over.',
    'Centre back follows the shifting forward out of the line',
    'The forward runs in behind on the blind side of his marker and goes through on goal.',
    NULL, 111, 125, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Shifting forward (10)', 'Pull the centre back out of the line'),
    (2, 'Other forward (9)', 'Run quickly on the blind side of his centre back into the vacated central space'),
    (3, 'Defensive midfielder (8)', 'Spot the run and play the long or aerial pass into the space')
) AS v(so, role, job);

-- 43. pp.112-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch5 Conte - Receiving and Dribbling the Ball into the Created Space', 'Marked forward turns into vacated gap',
    'The defensive midfielder still passes to a forward who is being marked by a centre back. With the other centre back pulled away, that forward turns his man and dribbles into the hole.',
    'Pass arrives at a marked forward with space beside him',
    'The forward beats his man 1 v 1 and drives at goal. This is best with a quick forward who is strong over the first 5 steps.',
    NULL, 112, 112, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (9)', 'Receive under pressure, turn and carry into the space the other centre back left'),
    (2, 'Defensive midfielder (8)', 'Play to the forward''s feet even though he is marked'),
    (3, 'Shifting forward (10)', 'Pull the second centre back away')
) AS v(so, role, job);

-- 44. pp.113-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch5 Conte - Centre Back Prevents Overload, Ball Moved to the Attacking Midfielder via a Third Man Run', 'Third-man diagonal run into vacated gap',
    'When a centre back follows the shifting forward, a midfielder from the weak side (attacking midfielder in 3-5-2, wide man in 4-4-2) makes a timed diagonal run into the gap. The forward sets him up with a first-time pass, or the defensive midfielder lofts the ball straight to him if the run starts earlier.',
    'Centre back follows the forward; space opens behind him',
    'The third man runs in behind the back line for a 1 v 1 with the goalkeeper.',
    NULL, 113, 127, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side attacking midfielder (11)', 'Time a diagonal run into the centre behind the defensive line'),
    (2, 'Forward (9)', 'Play the first-time pass into the runner'),
    (3, 'Defensive midfielder (8)', 'Play an aerial pass straight to the runner when he goes earlier'),
    (4, 'Shifting forward (10)', 'Drag the centre back out to open the gap')
) AS v(so, role, job);

-- 45. pp.114-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch5 Conte - Forward on the Strong Side Shifts Across to the Weak Side', 'Narrow lane: overload on the weak side',
    'The strong-side forward drops to receive but his passing lane is too narrow, for example because a holding midfielder is screening it. The man on the ball switches to the weak-side forward instead, and the first forward moves across into that centre back''s zone to take the set-back. The rule is to overload the side whose lane is open.',
    'Passing lane to the strong-side forward is narrow or blocked by a midfielder',
    'The overload forms on the weak side. The receiver plays a final pass through the middle for the attacking midfielder''s run, or out wide to the advancing full back for a cross.',
    NULL, 114, 124, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side forward (9)', 'Drop, then shift across to the other centre back''s zone and take the set-back'),
    (2, 'Weak-side forward (10)', 'Receive the ball and lay it back to his partner'),
    (3, 'Defensive midfielder (8)', 'Read which lane the opposing midfielder blocks and play to the open side'),
    (4, 'Attacking midfielder (11)', 'Run through the middle for the final pass'),
    (5, 'Full back (3)', 'Push into the wide space as a crossing option')
) AS v(so, role, job);

-- 46. pp.115-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch5 Conte - Centre Back Prevents Overload, Ball Moved to the Strong Side via a Third Man Run', 'Strong-side runner exploits followed weak shift',
    'When the forward shifts toward the weak side and his centre back follows, the space opens on the strong side. The strong-side attacking midfielder (3-5-2) or winger (4-4-2) runs into it and gets a first-time pass from the other forward.',
    'Centre back follows the forward toward the weak side',
    'A runner from the strong side is played in behind.',
    NULL, 115, 115, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side attacking midfielder / winger (7)', 'Run into the space the centre back left'),
    (2, 'Other forward (9/10)', 'Play the first-time pass to the runner'),
    (3, 'Defensive midfielder (8)', 'Feed the forward')
) AS v(so, role, job);

-- 47. pp.116-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch5 Conte - Overloading the Centre Back''s Zone with the Forward Shifting Across (4-2-3-1)', 'No.10 shifts to striker''s side',
    'The same overload done from a one-striker shape. As the defenders start to shift for a switch of play, the No.10 moves across from the strong side toward the striker''s side, so both sit in one centre back''s zone. The midfielder plays into the striker, who sets it back to the No.10.',
    'Full back has the ball and the opposition starts shifting for the switch',
    'Two players overload one centre back and the attack plays 4 v 4 in the final third. In 4-2-3-1 the No.10 already starts deep, so he only needs to shift across.',
    NULL, 116, 120, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'Move across to the striker''s side early and take the lay-off facing goal'),
    (2, 'Forward (9)', 'Receive and set it back'),
    (3, 'Central midfielder (8)', 'Receive, turn and play forward into the striker')
) AS v(so, role, job);

-- 48. pp.129-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch6 Creating an Overload with a Winger Shifting Inside (Mourinho) - The Winger on the Weak Side Shifts Inside', 'Weak-side winger converges inside',
    'As soon as the ball goes from the strong side into a central midfielder with time, the weak-side winger runs in toward the centre into the centre back''s zone. Mourinho likes an inverted winger here. The midfielder plays into the forward, who lays it off to the winger, or plays the winger directly. In 4-2-3-1 the winger on the side where the striker stands is the one who moves in.',
    'Central midfielder receives from the full back and has time',
    'The winger receives facing goal with four options in a 4 v 4 or 5 v 4: through balls to the 9 or 10, a lofted pass wide to the far winger, or a shot with his stronger foot. Effective against middle and deep blocks.',
    NULL, 129, 142, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side winger (11)', 'Start not too wide, make a quick converging run into the centre back''s zone, receive facing goal'),
    (2, 'Forward (9)', 'Hold the ball and lay off to the winger'),
    (3, 'Central midfielder (6)', 'Read which side the forward is on and play into him or straight to the winger'),
    (4, 'No.10 and far winger (7)', 'Make runs in behind as final-pass options'),
    (5, 'Full backs', 'Move up in time with the winger''s inward run')
) AS v(so, role, job);

-- 49. pp.131-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch6 Mourinho - When the Winger''s Movement is Followed, Play is Switched to the Full Back on the Weak Side', 'Followed winger: switch to weak-side full back',
    'If the opposing full back follows the weak-side winger inside, the flank empties. The midfielder switches play with an accurate long pass to his own full back running into that space. The other central midfielder stays deep for balance.',
    'Opposing full back tracks the winger into the centre',
    'The weak-side full back receives in lots of space and crosses to runners, while a 3 v 2 or 4 v 3 is kept at the back.',
    NULL, 131, 142, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side full back (3)', 'Time a forward run into the space behind the opposing full back, then cross'),
    (2, 'Central midfielder (6)', 'Switch play with an accurate long pass'),
    (3, 'Other central midfielder (8)', 'Stay deep to keep 3 v 2 / 4 v 3 at the back'),
    (4, 'Weak-side winger (11)', 'Run inside to pull the full back with him')
) AS v(so, role, job);

-- 50. pp.132-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch6 Mourinho - The Winger on the Strong Side Shifts Inside', 'Strong-side winger converges inside',
    'With the forward on the strong side, the strong-side winger moves inside into that centre back''s zone while the midfielder plays into the forward. The space is tighter than on the weak side, so movements must be well synchronised.',
    'Central midfielder has time and the forward is positioned on the strong side',
    'The winger gets the lay-off facing goal and plays in behind, for example for the far winger''s diagonal run to go 1 v 1 with the keeper. In 4-4-2 the overload can happen on both sides at once, so it is easier.',
    NULL, 132, 136, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side winger (7)', 'Move inside into the centre back''s zone and take the lay-off'),
    (2, 'Forward (9)', 'Receive and set it back to the winger'),
    (3, 'Far winger (11)', 'Make a diagonal run in behind'),
    (4, 'Central midfielder (6)', 'Play into the forward')
) AS v(so, role, job);

-- 51. pp.133-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'creative-attacking-play-from-the-tactics-of-conte-allegri-simeone-mourinho-wenge'), 'in_possession', 'Ch6 Mourinho - When the Winger''s Movement is Followed, the Full Back Exploits the Space on the Strong Side', 'Followed strong winger: first-time ball wide',
    'The opposing full back follows the strong-side winger inside. Seeing that the winger is covered, the forward plays a first-time pass out into the empty flank for his own full back to run onto.',
    'Opposing full back follows the strong-side winger inside',
    'The right back carries the ball forward with time and space and crosses for runners.',
    NULL, 133, 141, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side full back (2)', 'Make a well-timed forward run into the vacated flank, carry and cross'),
    (2, 'Forward (9)', 'Pass first time into the wide space instead of to the marked winger'),
    (3, 'Strong-side winger (7)', 'Run inside to pull the full back with him')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('2152-coaching-book-creative-attacking-play-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
