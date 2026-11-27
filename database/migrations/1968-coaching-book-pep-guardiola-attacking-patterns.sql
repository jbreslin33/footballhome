-- 1968 📚 Coaching book patterns: "Pep Guardiola Attacking Tactics" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Pep Guardiola Attacking Tactics',
    subtitle    = 'Tactical Analysis and Sessions from Manchester City''s 4-3-3',
    author      = 'Athanasios Terzis',
    team        = 'Manchester City',
    season      = '2017-18 / 2018-19',
    method_note = 'Analysis of Guardiola''s Manchester City 4-3-3 in attack over the 2017-18 and 2018-19 Premier League title seasons; a move counts as a pattern only if seen 10+ times. City build from a 2-3-2-3 with inverted full backs beside the holding midfielder. The book is split by opponent shape (v 4-4-2 / 4-2-3-1, v 4-3-3, v a back 5) into 12 tactical situations: link players beating the first press, inverted full-back triangles and rotations, the wide 2v1 overload and its options, the forward dropping as a link, the opposing centre back stepping out, weak-side switches, and switching to a 2-2-5-1 against a back five. Each has a diagram-by-diagram analysis then a progressive session. Patterns are the match behaviours, in our words, with who does what.'
WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c');

-- 1. pp.11-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Pep Guardiola''s 2-3-2-3 Attacking Formation / Attacking Against the 4-4-2 or 4-2-3-1', '2-3-2-3 build-up through second line',
    'In possession the 4-3-3 becomes a 2-3-2-3: both full backs tuck inside next to the holding midfielder, giving four lines. Against a 4-4-2 the two centre backs look for the three second-line players in the gaps between the opponent''s forwards and midfielders.',
    'Centre backs have the ball in the first phase',
    'Move the ball up one line at a time, then into the attacking midfielders, winger or a dropping forward, and then attack the final third.',
    '4-4-2', 11, 17, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Laporte, Otamendi)', 'Pass into whichever second-line player is free'),
    (2, 'Inverted full backs (Zinchenko, Walker)', 'Take up the free spaces on the left and right of the second line'),
    (3, 'Defensive midfielder (Fernandinho)', 'Find the central gap between the two forwards'),
    (4, 'Attacking midfielders (Silva, De Bruyne)', 'Wait between the lines for the next pass'),
    (5, 'Forward (Aguero)', 'Drop between the lines as an extra option')
) AS v(so, role, job);

-- 2. pp.13-13
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'The Manchester City Players (Wingers)', 'Winger cuts inside with give-and-go',
    'A common City move: the winger passes inside to a central player and runs inside to get it back with a one-two or give-and-go.',
    'Winger on the ball facing an isolated full back',
    'The winger receives the return pass inside the box in a good position to shoot or play a low cross.',
    NULL, 13, 13, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Sterling, Sane)', 'Pass inside, cut inside and run onto the return in the box'),
    (2, 'Central player (AM or forward)', 'Return the ball first time into the winger''s run')
) AS v(so, role, job);

-- 3. pp.18-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Attacking Against the 4-4-2 or 4-2-3-1', 'No.10 screens DM: build via inverted full backs',
    'Against a 4-2-3-1 the opposing No.10 sits on City''s holding midfielder, so the centre backs can rarely pass to him directly.',
    'Opposing No.10 marks or screens the defensive midfielder',
    'Get past the first line by playing to the inverted full backs on either side instead of through the middle.',
    '4-2-3-1', 18, 24, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Skip the screened holding midfielder and pass to an inverted full back'),
    (2, 'Inverted full backs', 'Stay open in the half-spaces either side of the No.10'),
    (3, 'Defensive midfielder (Fernandinho)', 'Keep the No.10 busy and hold the centre')
) AS v(so, role, job);

-- 4. pp.20-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 1: Overcoming the Pressing of the Opposing Forwards', 'Attacking midfielder drops as link player',
    'An opposing forward presses a centre back or full back and curves his run to cut off the switch, pushing the ball wide where the opponent wants to trap it. Against a 4-4-2 the holding midfielder is free behind that forward.',
    'Forward presses the centre back or full back and closes the pass back across',
    'The link player sets the ball back to the free holding midfielder, who switches play to the weak side before the trap closes.',
    '4-4-2', 20, 28, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Gundogan)', 'Drop deep the moment the press starts and set the ball back to the free man'),
    (2, 'Defensive midfielder (Fernandinho)', 'Receive facing forward and play to the weak side or into space'),
    (3, 'Pressed centre back or full back (Kompany or Walker)', 'Play into the dropping link player, not down the line'),
    (4, 'Weak-side full back, AM, winger and forward (Zinchenko, De Bruyne, Sane, Aguero)', 'Spread out in space ready for the switch')
) AS v(so, role, job);

-- 5. pp.22-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 1: Overcoming the Pressing of the Opposing Forwards', 'Link player sets back to weak-side centre back',
    'Against a 4-2-3-1 a forward presses the near centre back or full back. The holding midfielder is marked by the No.10, so the link player cannot set the ball to him.',
    'Forward presses ball-side, and the No.10 is tight on the holding midfielder',
    'Switch through the free weak-side centre back to the far full back, then into the weak-side attacking midfielder or winger.',
    '4-2-3-1', 22, 23, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Gundogan)', 'Drop to link, then pass back to the weak-side centre back'),
    (2, 'Weak-side centre back (Stones or Kompany)', 'Stay free and pass on to the far full back'),
    (3, 'Weak-side full back (Zinchenko)', 'Receive and pass forward to the AM or winger'),
    (4, 'Weak-side AM and winger (De Bruyne, Sane)', 'Stay open for the next pass')
) AS v(so, role, job);

-- 6. pp.24-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 1: Overcoming the Pressing of the Opposing Forwards', 'Forward drops as link when DM is pressed',
    'The holding midfielder gets the ball from a centre back and an opposing forward presses him. This mostly happened against a 4-4-2.',
    'Forward closes down the holding midfielder after the centre back''s pass',
    'The striker comes short as the link and passes to the free weak-side full back, who plays on to the winger.',
    '4-4-2', 24, 27, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Aguero)', 'Drop off the centre backs, receive and pass to the weak side'),
    (2, 'Defensive midfielder (Fernandinho)', 'Pass into the dropping forward under pressure'),
    (3, 'Weak-side full back (Zinchenko)', 'Stay unmarked to receive and pass up the line'),
    (4, 'Weak-side winger (Sane)', 'Hold the width, take the ball and attack')
) AS v(so, role, job);

-- 7. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 2: Positioning and Rotations with Inverted Full Backs', 'Inverted full backs tuck into midfield line',
    'Once both attacking midfielders have pushed up past the opponent''s midfield line, both full backs come inside to form a line of three with the holding midfielder. This was used against every kind of opponent shape.',
    'Attacking midfielders are high, between the lines',
    'Fill the spaces the attacking midfielders left, so there are short central options and cover in midfield.',
    NULL, 30, 30, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (Delph, Walker)', 'Move inside into the half-space beside the holding midfielder'),
    (2, 'Defensive midfielder (Fernandinho)', 'Anchor the middle of the line of three'),
    (3, 'Attacking midfielders (Silva, De Bruyne)', 'Push up beyond the opponent''s midfield line'),
    (4, 'Wingers', 'Hold the width high')
) AS v(so, role, job);

-- 8. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 2: The Benefits of Inverted Full Backs and Their Central Positioning', 'Wing triangles and double triangle',
    'With the full back tucked in, he, the winger and the attacking midfielder form a triangle. When the full back has the ball, the forward often drops between the lines to make a second triangle beside it.',
    'Inverted full back on the ball in the half-space',
    'Give the man on the ball several passing angles in the wide channel.',
    NULL, 31, 31, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted full back (Delph)', 'Base of the triangle, inside the half-space'),
    (2, 'Winger (Sane)', 'Wide point of the triangle'),
    (3, 'Attacking midfielder (Silva)', 'Inner point, between the lines'),
    (4, 'Forward (Aguero)', 'Drop into a deep position to complete the double triangle')
) AS v(so, role, job);

-- 9. pp.32-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 2: The Benefits of Inverted Full Backs and Their Central Positioning', 'Central DM forms double triangle or diamond',
    'Because the full backs come inside, the holding midfielder never has to drift wide to get the ball from the centre backs. He stays central and saves energy.',
    'Build-up with both full backs inverted',
    'The holding midfielder and two attacking midfielders form a triangle. A dropping forward makes it a double triangle, and a high forward makes it a diamond.',
    NULL, 32, 32, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Fernandinho)', 'Stay central as the base of the shape'),
    (2, 'Attacking midfielders (Silva, De Bruyne)', 'Take the two upper corners between the lines'),
    (3, 'Forward (Aguero)', 'Drop to make a double triangle, or stay high to make a diamond')
) AS v(so, role, job);

-- 10. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 2: The Benefits of Inverted Full Backs and Their Central Positioning', 'Inverted full back has three forward options',
    'A full back on the ball centrally can pass forward to the winger, the attacking midfielder or the forward. From a wide position he has only the winger and the AM.',
    'Full back receives in a central position',
    'More forward options, and the winger gets the ball on a diagonal, half-turned, so he can attack straight away instead of receiving with his back to goal.',
    NULL, 33, 33, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted full back (Delph)', 'Receive inside and choose from three forward passes'),
    (2, 'Winger (Sane)', 'Receive half-turned and drive forward'),
    (3, 'Attacking midfielder (Silva)', 'Offer the inside option'),
    (4, 'Forward (Aguero)', 'Offer the central option')
) AS v(so, role, job);

-- 11. pp.34-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 2: Rotating Positions of the Inverted Full Back, Att. Midfielder and Winger to Retain Balance', 'Full back, AM, winger rotation',
    'When the strong-side attacking midfielder drops deeper to get the ball from the centre back, the full back moves out wide and the winger comes inside. The triangle keeps its shape with new players in it.',
    'Attacking midfielder drops back to receive',
    'Keep the team''s balance and the wide triangle while unsettling the markers.',
    NULL, 34, 37, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Silva)', 'Drop to receive, which starts the rotation'),
    (2, 'Strong-side full back (Delph)', 'Move out into the wide position'),
    (3, 'Winger (Sane)', 'Come inside as an option between the lines'),
    (4, 'Centre back (Laporte)', 'Pass into the dropping AM')
) AS v(so, role, job);

-- 12. pp.39-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 3: Creating and Exploiting Overloads in Wide Areas', 'AM in full back''s zone makes 2v1',
    'The attacking midfielders take up positions inside the opposing full back''s zone, so he has to deal with both the winger and the AM out wide.',
    'Attacking midfielders move up high into the half-space',
    'Create a 2v1 against the opposing full back on each flank.',
    '4-4-2', 39, 39, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielders (Silva, De Bruyne)', 'Stand inside the opposing full back''s zone of responsibility'),
    (2, 'Wingers (Sane, Sterling)', 'Hold the touchline to pin the full back')
) AS v(so, role, job);

-- 13. pp.40-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 3: Exploiting the Overload in a Wide Area to Receive Between the Lines and Turn', 'Full back stays with winger: AM turns',
    'In the wide 2v1, the opposing full back holds his position to mark the winger. That leaves the attacking midfielder free in a passing lane between the lines.',
    'Opposing full back stays deep to control the winger',
    'The attacking midfielder gets free of his marker, turns towards goal and plays a final ball in behind or drives at the back line. Which option to take depends on the full back''s reaction, which the AM must read.',
    '4-4-2', 40, 56, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Silva)', 'Move into the free lane, receive, turn and play the final pass'),
    (2, 'Inverted full back (Zinchenko)', 'Pass to the AM'),
    (3, 'Winger (Sane)', 'Keep the full back pinned'),
    (4, 'Forward and far-side players (10, 17, 7)', 'Time runs into the gaps for the final pass')
) AS v(so, role, job);

-- 14. pp.41-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 3: Early Cross into the Space Between the Defenders and the GK', 'Early cross behind retreating back line',
    'The opposing full back drops to follow the winger''s run, so the attacking midfielder on the ball has space to carry forward and cross early from the zone just outside the box. Used mainly against compact back lines of five or six.',
    'Full back retreats with the winger, and there is space between the back line and the keeper',
    'Whip the ball into the space between the defenders and the goalkeeper, so defenders have to deal with it while running back towards their own goal.',
    '4-4-2', 41, 55, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder or full back (Silva or Zinchenko)', 'Carry forward and deliver an early cross'),
    (2, 'Forward (Aguero)', 'Attack the space between the defenders and the keeper'),
    (3, 'Far-side AM and winger (De Bruyne, Sterling)', 'Arrive in the box for the cross'),
    (4, 'Winger (Sane)', 'Run forward to drag the full back away')
) AS v(so, role, job);

-- 15. pp.42-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 3: Moving the Ball to the Free Winger', 'Full back steps to AM: free winger',
    'The opposing full back steps up to close down the attacking midfielder and stop him turning, which leaves the winger free high up the flank.',
    'Opposing full back moves forward onto the attacking midfielder',
    'The AM plays a first-time pass to the free winger, who runs forward and crosses into the box.',
    '4-4-2', 42, 54, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Silva or De Bruyne)', 'Read the press and pass first time to the winger'),
    (2, 'Winger (Sane)', 'Stay away from markers high up the flank, receive and cross'),
    (3, 'Forward and far-side players', 'Make runs into the box for the cross')
) AS v(so, role, job);

-- 16. pp.43-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 3: Exploiting the Overload by Receiving, Turning and Moving Inside with the Ball', 'Receive via DM link, carry inside',
    'Instead of passing straight in from the full back, City played the ball sideways into the holding midfielder. He then passed to the attacking midfielder between the lines, an inside-to-outside pass that let the AM receive half-turned and dribble inside. When the centre back steps out to meet him, the forward runs diagonally behind that centre back.',
    'Full back cannot find the AM directly, or the AM needs an open body shape. Second trigger: the centre back leaves the line to close down the dribble.',
    'The AM turns and carries the ball inside. When the centre back steps out, slip the forward into the space behind him, or the forward''s run opens space for the AM to shoot.',
    '4-4-2', 43, 50, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted full back (Zinchenko)', 'Pass sideways inside to the holding midfielder'),
    (2, 'Defensive midfielder (Fernandinho)', 'Link: pass into the AM between the lines'),
    (3, 'Attacking midfielder (Silva, De Bruyne, Gundogan or Bernardo)', 'Receive half-turned, dribble inside and play the final pass'),
    (4, 'Forward (Aguero)', 'Run diagonally behind the centre back who stepped out')
) AS v(so, role, job);

-- 17. pp.46-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 3: Moving the Ball to the Free Winger when Put Under Pressure Receiving Between the Lines', 'Combination to winger when pass blocked',
    'The pressing full back also blocks the attacking midfielder''s direct pass to the winger. The ball still reaches the winger through a short combination.',
    'Direct pass to the free winger is cut off',
    'Get the free winger on the ball another way: the AM passes back so the full back or holding midfielder can play an aerial ball, or passes inside to a dropping forward who plays a diagonal out wide.',
    '4-4-2', 46, 52, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Silva)', 'Pass back or square inside instead of forcing the pass'),
    (2, 'Full back or defensive midfielder (Zinchenko or Fernandinho)', 'Play a lofted pass to the winger'),
    (3, 'Forward or other AM (Aguero or De Bruyne)', 'Drop as an inside link and play the diagonal out wide'),
    (4, 'Winger (Sane)', 'Stay free on the flank to receive')
) AS v(so, role, job);

-- 18. pp.47-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 3: Exploiting Gaps Between Defenders', 'AM runs into full back-centre back gap',
    'When the opposing full back and centre back are too far apart, which usually happens after a switch when the centre back has not shifted across in time, the attacking midfielder does not drop to receive.',
    'Gap opens between the opposing full back and centre back',
    'The AM runs forward into the gap, takes the full back''s pass in behind and puts in a low cross.',
    '4-4-2', 47, 47, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Silva)', 'Run forward into the gap, not short'),
    (2, 'Full back (Zinchenko)', 'Pass forward into the run'),
    (3, 'Forward and far-side players', 'Attack the box for the low cross')
) AS v(so, role, job);

-- 19. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 4: Attacking Options when the Overload Out Wide is Blocked', 'Diagonal inside lane to dropping forward',
    'One opposing central midfielder shifts a long way across to stop the wide overload, and his partner does not follow. This widens the diagonal passing lane from the full back into the forward.',
    'Central midfielder over-shifts to the flank and the gap beside him opens',
    'The forward drops and receives. If the centre back stays back, the forward turns and has at least three passes in behind (winger and both AMs).',
    '4-4-2', 58, 58, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Zinchenko)', 'Play the diagonal inside pass to the forward'),
    (2, 'Forward (Aguero)', 'Drop into the lane, turn if not pressed, and feed runners'),
    (3, 'Winger and attacking midfielders (Sane, Silva, Bernardo)', 'Run in behind for the forward''s pass')
) AS v(so, role, job);

-- 20. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 4: Attacking Options when the Overload Out Wide is Blocked', 'Centre back follows forward: space behind',
    'When the opposing centre back steps out to press the dropping forward, the forward cannot turn, but the space the centre back left is open.',
    'Centre back moves forward to stop the forward turning',
    'Play into the hole behind the centre back: forward set back to the holding midfielder, then a forward pass in behind to the attacking midfielder.',
    '4-4-2', 59, 59, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Aguero)', 'Draw the centre back out and lay the ball off'),
    (2, 'Defensive midfielder (Gundogan)', 'Receive the lay-off and pass in behind'),
    (3, 'Attacking midfielder (Silva)', 'Run into the space the centre back left')
) AS v(so, role, job);

-- 21. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 4: Attacking Options when the Overload Out Wide is Blocked', 'Switch to weak side for 2v1',
    'When the whole opposing midfield shifts towards the ball and the passing lanes through the middle close, the far side is left open with a likely overload.',
    'Whole midfield shifts to the ball side and the central lanes are narrow',
    'A long switch to the far winger, who gets a 2v1 out wide. The book covers this in more depth later, in Tactical Situation 11.',
    '4-4-2', 59, 59, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Gundogan)', 'Play the long switch'),
    (2, 'Weak-side winger (Sterling)', 'Hold the width and receive in space'),
    (3, 'Weak-side AM and full back', 'Join him to make the 2v1')
) AS v(so, role, job);

-- 22. pp.61-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Session 4: Attacking Options when the Overload Out Wide is Blocked', 'One CM shifts wide: forward drops into lane',
    'The 2v1 out wide is taken away because one opposing central midfielder slides across into the wide zone. That widens the diagonal lane from the full back to the centre forward between the lines (opponent 4-4-2, also used vs 4-2-3-1).',
    'Ball-side opposing CM moves into the wide zone',
    'Forward receives between the lines, turns if his centre back stays and slips the far-side winger in behind.',
    '4-4-2', 61, 67, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Zinchenko 35)', 'Reads the CM shift and passes diagonally inside to the forward'),
    (2, 'Centre forward (10)', 'Drops off the line into the widened lane, turns and plays in behind'),
    (3, 'Ball-side attacking midfielder (21)', 'Runs into the wide zone to offer the 2v1 if the CM does not follow'),
    (4, 'Weak-side winger (19)', 'Runs in behind for the forward''s pass')
) AS v(so, role, job);

-- 23. pp.62-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Session 4: Attacking Options when the Overload Out Wide is Blocked', 'Both CMs shift: go inside to weak-side AM',
    'Both opposing central midfielders slide towards the ball, shutting the lane to the forward and the wide overload. The weak side of their midfield is left open.',
    'Second opposing CM makes a big shift across and the lane to the forward closes',
    'Full back plays inside to the defensive midfielder, who finds the weak-side attacking midfielder between the lines or switches long to the far winger for a 2v1.',
    '4-4-2', 62, 67, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (35)', 'Passes inside to the defensive midfielder instead of forcing it wide'),
    (2, 'Defensive midfielder (8)', 'Moves the ball to the weak side: to the AM between the lines or a long switch to the winger'),
    (3, 'Weak-side attacking midfielder (20)', 'Receives in space between the lines, turns and plays in behind'),
    (4, 'Weak-side winger (7)', 'Holds width for the switch and the 2v1 out wide')
) AS v(so, role, job);

-- 24. pp.63-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Session 4: Attacking Options when the Overload Out Wide is Blocked', 'CB jumps forward: lay-off and chip behind',
    'The forward drops to receive the diagonal pass but the opposing centre back follows him and stops him turning, leaving space behind that defender.',
    'Opposing centre back steps out to press the dropping forward',
    'Use a third man: forward sets the ball back so a deeper player can play an aerial pass into the space the centre back vacated.',
    '4-4-2', 63, 66, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (10)', 'Bounces the ball back first time to the defensive midfielder'),
    (2, 'Defensive midfielder (8)', 'Plays the lofted pass over into the gap behind the advanced centre back'),
    (3, 'Attacking midfielder (21)', 'Runs into the vacated space to receive and score or set up a team-mate')
) AS v(so, role, job);

-- 25. pp.69-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 5: Moving the Ball Wide and Receiving in Behind the Full Back', 'Winger spins behind a tight full back',
    'The opposing full back takes a wide position close to City''s winger, so the winger cannot receive to feet facing goal.',
    'Opposing full back positioned wide and tight on the winger',
    'Winger drops to drag the full back, then changes direction (or runs diagonally) into the gap between full back and centre back for a through ball.',
    '4-4-2', 69, 76, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Sane 19 / Sterling 7)', 'Drops short to unbalance his marker, then sprints in behind between FB and CB'),
    (2, 'Full back (Zinchenko 35 / Walker 2)', 'Plays the through ball into the space behind the opposing full back')
) AS v(so, role, job);

-- 26. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 5: Moving the Ball Wide and Receiving in Behind the Full Back', 'Inverted full back feeds winger facing goal',
    'The opposing full back stays balanced in line with his centre backs, so the through ball is off but the winger has room out wide.',
    'Opposing full back sits narrow / balanced',
    'From a central (inverted) position the full back has a passing angle that lets the winger receive with an open body facing goal.',
    '4-4-2', 70, 70, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted full back (35)', 'Takes a central starting spot to create a diagonal angle to the winger'),
    (2, 'Winger (Sane 19)', 'Receives wide with an open body shape facing the opponent''s goal')
) AS v(so, role, job);

-- 27. pp.70-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 5: Moving the Ball Wide and Receiving in Behind the Full Back', 'AM runs behind the pressing full back',
    'The winger gets the ball and the opposing full back steps out to close him, leaving space behind him near the box.',
    'Opposing full back moves out to close the winger',
    'Attacking midfielder runs behind the full back into the box to receive and cross; if the centre back goes with him City get a 3v2 inside the area.',
    '4-4-2', 70, 73, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Sane 19)', 'Lets the full back come, then plays into the space behind him'),
    (2, 'Attacking midfielder (Silva 21)', 'Starts his run as the full back commits, receives in the box and crosses'),
    (3, 'Forward and far-side players', 'Attack the box for the cross')
) AS v(so, role, job);

-- 28. pp.71-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 5: Using the Run Behind the Full Back to Create Space for an Inside Pass', 'Deep AM run frees forward between lines',
    'The attacking midfielder''s run behind the full back is tracked by the near centre back, and the rest of the back line drops to stay balanced, opening space between the lines.',
    'Opposing centre back follows the attacking midfielder''s deep run',
    'Forward slides across into the free pocket, receives the winger''s inside pass, turns and has three options in behind (4v3 near the box).',
    '4-4-2', 71, 76, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Silva 21)', 'Makes the deep run to pull the centre back away'),
    (2, 'Centre forward (Aguero 10)', 'Shifts across unmarked into the pocket and turns'),
    (3, 'Winger (Sane 19)', 'Reads the centre back''s reaction and passes inside instead of in behind'),
    (4, 'Far-side winger and AM', 'Run in behind as the forward''s three passing options')
) AS v(so, role, job);

-- 29. pp.78-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 6: Combination Play Out Wide when the Overload is Blocked', 'One-two between winger and AM',
    'The ball reaches the winger but the opposing central midfielder sits near City''s attacking midfielder and blocks the run behind the full back, while the centre back steps up on the forward. The strong side is crowded; switching is one answer, quick combinations the other.',
    'Overload out wide blocked; pass behind FB and inside pass to forward both shut',
    'Break the wide block with a one-two: AM checks away then shows, winger dribbles at the full back, passes in and runs behind him for the return, then crosses.',
    '4-4-2', 78, 90, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (De Bruyne 17)', 'Fake movement away, then comes across to offer a short wall pass'),
    (2, 'Winger (Sane 19)', 'Dribbles towards the opposing full back, plays the 1-2 and runs behind him'),
    (3, 'Box attackers (10, 7, 8)', 'Arrive for the cross')
) AS v(so, role, job);

-- 30. pp.81-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 6: Give-and-Go Combination when the Overload is Blocked', 'Give-and-go with the defensive midfielder',
    'With the wide overload blocked, the attacking midfielder runs forward to drag his marker away instead of offering for the ball, opening space in front of the defence for the defensive midfielder.',
    'Winger receives with the opposing CM tight on City''s attacking midfielder',
    'Winger dribbles inside, passes diagonally back to the stepping-in defensive midfielder, then makes a curved inside-then-behind run for a through or aerial ball and crosses or shoots.',
    '4-4-2', 81, 90, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (De Bruyne 17)', 'Runs diagonally forward to take his marker away'),
    (2, 'Defensive midfielder (Fernandinho 25)', 'Moves up into the freed space, receives and plays the lofted/through pass'),
    (3, 'Winger (Sane 19)', 'Dribbles inside, gives it back, cuts inside then behind (staying onside) to receive in the box'),
    (4, 'Back line note', 'Defenders stepping up to compress lose track of the winger''s run')
) AS v(so, role, job);

-- 31. pp.92-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 7: Stretching the Opposition''s Defence and Switching Play', 'Stretch strong side, DM switches',
    'Versus a 4-4-2 the attacking midfielder''s run is tracked by the centre back and the opposing CM drops to block the pass to the forward, so the defence is stretched and there is a big space centrally for City''s defensive midfielder.',
    'Opposing CM drops to cover the inside pass after the AM''s run stretches the line',
    'Winger finds the defensive midfielder directly or via the full back, and he switches play to exploit gaps on the weak side.',
    '4-4-2', 92, 105, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Bernardo 20)', 'Chooses a direct pass to the DM or goes via the full back, depending on the weak-side full back'),
    (2, 'Attacking midfielder (Silva 21)', 'Runs in behind to pull the centre back and stretch the line'),
    (3, 'Full back (Delph 18)', 'Support option to relay the ball to the DM'),
    (4, 'Defensive midfielder (Fernandinho 25)', 'Receives in the space vacated by the dropping CM and switches'),
    (5, 'Centre forward (10)', 'Threat of a pass to him drags a CM deeper')
) AS v(so, role, job);

-- 32. pp.93-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 7: Stretching the Opposition''s Defence and Switching Play', 'Weak-side full back tucks in to switch',
    'Versus a 4-2-3-1 the opposing No.10 sits on City''s defensive midfielder, so he cannot receive freely to switch.',
    'Opposing No.10 controls the space in front of the defensive midfielder',
    'The weak-side full back moves into a central position and takes over the job of receiving and switching, fed via the left back, the DM, or the centre back.',
    '4-2-3-1', 93, 105, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side full back (Walker 2)', 'Tucks into central midfield to receive and play the long switch'),
    (2, 'Left back (Delph 18)', 'Relays the ball across, or back to the centre back'),
    (3, 'Centre back (Laporte 14)', 'Alternative route to the tucked-in full back'),
    (4, 'Defensive midfielder (Fernandinho 25)', 'Uses a pass to him only if the No.10 lets him receive')
) AS v(so, role, job);

-- 33. pp.94-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 7: Long Passes into the Available Space on the Weak Side', 'Long ball into the FB-CB gap',
    'After stretching the defence, the weak-side attacking midfielder moves into the channel between the opposing full back and centre back.',
    'Weak-side gap between FB and CB is wide enough and the FB does not close it',
    'Long pass into that gap for the attacking midfielder to receive and score.',
    '4-4-2', 94, 105, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Fernandinho 25)', 'Plays the long pass into the gap (vs 4-2-3-1 the tucked-in full back Walker plays it)'),
    (2, 'Weak-side attacking midfielder (De Bruyne 17)', 'Times his run into the FB-CB channel'),
    (3, 'Weak-side winger (Sterling 7)', 'Holds width, keeping the full back honest')
) AS v(so, role, job);

-- 34. pp.95-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 7: Long Passes into the Available Space on the Weak Side', 'Long ball to the free far winger',
    'The weak-side attacking midfielder''s inside movement forces the opposing full back to slide in and close the gap, leaving the winger alone in a wider area. Also used whenever defenders over-shift to the strong side.',
    'Weak-side full back shifts inside to close the AM',
    'Long pass to the winger in the open wide space to go in behind and score or cut back a low cross.',
    '4-4-2', 95, 105, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Fernandinho 25)', 'Reads the full back''s shift and plays long to the winger'),
    (2, 'Weak-side attacking midfielder (De Bruyne 17)', 'Moves centrally to drag the full back inside'),
    (3, 'Weak-side winger (Sterling 7)', 'Receives in behind wide, shoots or crosses low')
) AS v(so, role, job);

-- 35. pp.107-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 8: Attacking Midfielders Move into Available Passing Lanes to Receive', 'AMs open lanes in FB-CB pocket',
    'When the defensive midfielder has the ball there is always the chance to go through the centre; both attacking midfielders step inside into open lanes in the space between the opposing centre back and full back.',
    'Ball reaches the defensive midfielder with an open body',
    'Give the DM two free lanes to the AMs, who receive on the half-turn and attack facing goal.',
    '4-4-2', 107, 117, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Fernandinho 25)', 'Receives with an open body and picks one of the two AMs'),
    (2, 'Attacking midfielders (Silva 21, De Bruyne 17)', 'Move inside into the lanes between CB and FB zones, open body, ready to turn'),
    (3, 'Wingers (20, 7)', 'Stay wide to pin the full backs')
) AS v(so, role, job);

-- 36. pp.109-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 8: Attacking Options After Receiving Between the Lines', 'Full back holds: AM turns, key pass',
    'The attacking midfielder receives between the lines and the opposing full back stays in the back line to keep balance.',
    'Opposing full back does not step out',
    'AM turns and drives forward with a 5v4 to play a key pass or shoot.',
    '4-4-2', 109, 117, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (De Bruyne 17)', 'Turns on the half-turn and attacks the back line'),
    (2, 'Forward and winger', 'Make runs in behind for the key pass'),
    (3, 'Far-side AM and winger', 'Join to complete the 5v4')
) AS v(so, role, job);

-- 37. pp.109-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 8: Attacking Options After Receiving Between the Lines', 'Full back presses: lay-off, aerial to winger',
    'The opposing full back steps forward to stop the attacking midfielder turning, leaving space behind him for the winger.',
    'Opposing full back jumps onto the attacking midfielder',
    'AM sets the ball back to the defensive midfielder, who lofts it into the space behind for the winger to shoot or cross.',
    '4-4-2', 109, 117, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (De Bruyne 17 / Silva 21)', 'Reads the press and lays the ball back first time'),
    (2, 'Defensive midfielder (Fernandinho 25)', 'Plays the aerial pass over the full back'),
    (3, 'Winger (Sterling 7 / Bernardo 20)', 'Times his run behind (onside), then shoots or crosses low')
) AS v(so, role, job);

-- 38. pp.119-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 9: Exploiting Space Created when the Opposing Centre Back Pushes Out', 'CB presses wide AM: vertical to forward',
    'The defensive midfielder finds the attacking midfielder in a wide position between the lines and the near centre back leaves the line to close him at an angle, blocking the diagonal to the forward.',
    'Opposing centre back steps out of the line towards a wide-positioned AM',
    'AM, seeing the CB with an open body, plays a vertical pass into the vacated space for the forward to run onto and score.',
    '4-4-2', 119, 120, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Fernandinho 25)', 'Plays into the attacking midfielder between the lines'),
    (2, 'Attacking midfielder (De Bruyne 17)', 'Open body to see the CB coming; plays straight into the space behind'),
    (3, 'Centre forward (Aguero 10)', 'Reads and communicates, runs into the gap the CB left')
) AS v(so, role, job);

-- 39. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 9: Exploiting Space Created when the Opposing Centre Back Pushes Out', 'CB presses central AM: one-two with forward',
    'The attacking midfielder is positioned more centrally and the centre back closes him with a straight run, blocking the vertical pass to the forward.',
    'Opposing centre back steps straight out onto a central AM',
    'AM turns if he can; if not, plays a 1-2 with the forward and receives the return in the space behind the centre back.',
    '4-4-2', 120, 120, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (De Bruyne 17)', 'Turns if free, otherwise wall pass off the forward and runs past the CB'),
    (2, 'Centre forward (Aguero 10)', 'Offers short and returns the ball into the vacated space')
) AS v(so, role, job);

-- 40. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 9: Exploiting Space Created when the Opposing Centre Back Pushes Out', 'CB presses AM: square, first-time to forward',
    'Variation: with the centre back out on the central attacking midfielder, the ball goes across to the other attacking midfielder rather than to the forward.',
    'Opposing centre back steps out; forward free to run behind him',
    'Other AM plays first time into the space behind the pushed-out CB for the forward''s curved run, a clear chance.',
    '4-4-2', 120, 120, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (De Bruyne 17)', 'Draws the centre back, passes inside to the other AM'),
    (2, 'Other attacking midfielder (Silva 21)', 'Plays a first-time pass into the space behind'),
    (3, 'Centre forward (Aguero 10)', 'Curved run behind the pushed-out centre back to finish')
) AS v(so, role, job);

-- 41. pp.121-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Session 9: Exploiting Space Created when the Opposing Centre Back Pushes Out to Press the Ball', 'CB steps out diagonally: vertical ball behind',
    'The 6 receives on the half-turn and both 8s move into open lanes. When a wide-placed 8 gets the ball, the opposing centre back steps out at a diagonal angle to press him, which opens a vertical lane behind.',
    'Opposing CB leaves the line diagonally to press the wide 8',
    'Forward receives in the space the CB vacated and shoots.',
    NULL, 121, 128, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Receive between the lines on the half-turn and feed an 8'),
    (2, 'Attacking midfielder (wide)', 'Max 2 touches: receive and play straight forward behind the stepping CB'),
    (3, 'Centre forward', 'Read the CB''s angle and run into the vacated space to finish')
) AS v(so, role, job);

-- 42. pp.123-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Session 9: Exploiting Space Created when the Opposing Centre Back Pushes Out to Press the Ball', 'CB steps out straight: one-two in behind',
    'When the 8 receives centrally, the opposing CB presses him head-on, so the vertical pass to the forward is no longer on.',
    'CB presses the central 8 at a straight/vertical angle',
    'The 8 gets the return pass in the space behind the CB and goes to goal.',
    NULL, 123, 128, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (central)', 'Lay the ball into the forward and spin past the CB for the return'),
    (2, 'Centre forward', 'Set up the wall pass first time into the space behind'),
    (3, 'Defensive midfielder', 'Supply the 8 between the lines')
) AS v(so, role, job);

-- 43. pp.124-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Session 9: Exploiting Space Created when the Opposing Centre Back Pushes Out to Press the Ball', 'Blocked vertical: inside to free 8',
    'The wide 8 is pressed by the stepping CB and the straight pass to the forward is cut off.',
    'Vertical lane to forward closed',
    'The other 8 receives inside and finds the forward behind the line.',
    NULL, 124, 128, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressed attacking midfielder', 'Pass inside to the other 8 instead of forcing the vertical ball'),
    (2, 'Far attacking midfielder', 'Hold a lane in the central zone, then play the forward in behind'),
    (3, 'Centre forward', 'Stay ready to run into the gap left by the CB')
) AS v(so, role, job);

-- 44. pp.129-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 10: Attacking Through the Centre with the Forward Dropping Back to Receive', 'Forward drops as link to strong-side 8',
    'The 6 has no pass to either 8. The centre forward drops a few yards to offer a link pass and sets the ball to the strong-side 8, who then faces goal in a 2v1 with the winger against the full back.',
    'Lanes from the 6 to both 8s blocked',
    'The 8 dribbles into the space behind the CB to shoot, or slips the winger, who crosses low.',
    NULL, 129, 135, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Jesus)', 'Drop off the CB, take the 6''s pass and set it to the strong-side 8'),
    (2, 'Strong-side attacking midfielder (De Bruyne)', 'Receive facing goal; drive into the space behind the CB or release the winger'),
    (3, 'Strong-side winger (Bernardo)', 'Hold the width for the 2v1, receive and cross low'),
    (4, 'Defensive midfielder (Fernandinho)', 'Find the dropping forward when the 8s are covered')
) AS v(so, role, job);

-- 45. pp.131-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 10: Attacking Through the Centre with the Forward Dropping Back to Receive', 'Link forward plus third-man run',
    'The dropping forward is half-turned towards the weak side and lays the ball to the weak-side 8, creating a 2v2 there. The space behind the near CB is attacked by the other 8.',
    'Forward''s body shape faces the weak-side 8; ball reaches the forward''s feet',
    'A first-time diagonal pass puts the running 8 through on goal.',
    NULL, 131, 135, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Jesus)', 'Drop, then pass to whichever 8 his body is angled towards'),
    (2, 'Weak-side attacking midfielder (Silva)', 'Play first time diagonally into the runner''s path'),
    (3, 'Strong-side attacking midfielder (De Bruyne)', 'Start the diagonal run behind the CB as the ball reaches the forward')
) AS v(so, role, job);

-- 46. pp.137-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Attacking Against the 4-3-3', '6 drops between the two opposing 8s',
    'Against a 4-3-3, space between the lines is tight. The opposing 6 slides across to block the winger''s inside pass, and the opposing 8 marks City''s 6.',
    'Opponent in a 4-3-3 with two 8s screening',
    'City''s 6 finds a free pocket to receive and turn.',
    '4-3-3', 137, 137, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Fernandinho)', 'Stand in the gap between the two opposing 8s to get free'),
    (2, 'Winger (Sane)', 'If the inside pass is blocked, play back to the full back')
) AS v(so, role, job);

-- 47. pp.137-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Attacking Against the 4-3-3', 'Recycle and long switch vs 4-3-3',
    'The overload on the ball side is blocked. The ball goes back to the full back and is switched through the 6, or across the back via the CB to the far full back.',
    'Inside pass from the winger blocked by the shifting 6',
    'A long pass reaches the weak-side 8 or winger, whichever the gap between the red CB and full back favours.',
    '4-3-3', 137, 137, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back', 'Receive the recycle and move it on to the 6 or CB'),
    (2, 'Defensive midfielder / far full back', 'Receive the circulation and play the long switch'),
    (3, 'Weak-side 8 or winger', 'Offer the target the gap allows')
) AS v(so, role, job);

-- 48. pp.139-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 11: Switching Play to the Weak Side when the Overload is Blocked Against the 4-3-3', 'Quick ball to weak-side 8',
    'The opposing 6 shifts across to control the strong-side 8, which kills the 2v1 on that side. That leaves space between the lines and a 2v1 for the weak-side 8 and winger against their full back.',
    'Opposing 6 shuts down the strong-side 8',
    'The weak-side 8 receives free, turns and puts the forward or the winger in.',
    '4-3-3', 139, 140, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Fernandinho)', 'Pass diagonally straight to the weak-side 8, or go via the shifting full back'),
    (2, 'Weak-side full back (Walker)', 'Shift infield to offer the relay pass'),
    (3, 'Weak-side attacking midfielder (Gundogan)', 'Receive, turn and look first for the forward; if the full back steps up, play the free winger'),
    (4, 'Centre forward (Aguero)', 'Main target for the through pass')
) AS v(so, role, job);

-- 49. pp.141-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 11: Switching Play to the Weak Side when the Overload is Blocked Against the 4-3-3', 'Wide switch: 8 runs in behind',
    'A long switch finds the weak-side winger high and wide, making a 2v1 on the full back with the 8. The nearest CB is too far away to cover the 8.',
    'Winger receives wide; nearest CB too far away',
    'The 8 runs diagonally behind the full back, takes the winger''s pass and crosses low.',
    '4-3-3', 141, 142, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Play the long switch to the weak-side winger'),
    (2, 'Weak-side winger (Sterling)', 'Receive wide, pin the full back, slip the runner'),
    (3, 'Weak-side attacking midfielder (Gundogan)', 'Diagonal (underlapping) run behind the full back, then low cross')
) AS v(so, role, job);

-- 50. pp.142-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 11: Switching Play to the Weak Side when the Overload is Blocked Against the 4-3-3', '8 supports, receives back, early cross',
    'After the wide switch, the nearest CB is close enough to track the 8''s run in behind.',
    'Nearest CB close to the 8',
    'The 8 takes a lay-off from the winger and whips an early cross between the back line and the keeper.',
    '4-3-3', 142, 155, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side attacking midfielder', 'Hold a supporting spot inside/behind the winger and cross early first time'),
    (2, 'Weak-side winger', 'Play the ball back to the supporting 8'),
    (3, 'Forward and far-side attackers', 'Attack the space between defenders and goalkeeper')
) AS v(so, role, job);

-- 51. pp.143-157
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 11: Switching Play to the Weak Side when the Overload is Blocked Against the 4-3-3', 'Full back joins: underlap behind',
    'The weak-side 8 is too central to make the wide 2v1, so the full back gets forward as the switch is played. The nearest CB is too far away, or stays central to defend a cross.',
    'Switch played; 8 can''t help wide; CB too far to track',
    'The full back underlaps behind the opposing full back, who is busy with the winger, and crosses.',
    '4-3-3', 143, 157, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side full back (Walker)', 'Push on during the ball''s flight, then underlap inside the opposing full back'),
    (2, 'Weak-side winger (Sterling)', 'Draw the opposing full back and slide the pass inside'),
    (3, 'Weak-side attacking midfielder', 'Drop out of the zone to clear the lane'),
    (4, 'Defensive midfielder (Fernandinho)', 'Play the switch')
) AS v(so, role, job);

-- 52. pp.145-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 11: Switching Play to the Weak Side when the Overload is Blocked Against the 4-3-3', 'Full back supports, early cross',
    'The full back has joined after the switch, but the nearest CB is close enough to cover any underlap or run behind the full back.',
    'Nearest CB close enough to track runs',
    'The full back stays in support, takes the winger''s lay-off in the early-cross zone and bends it between defence and keeper.',
    '4-3-3', 145, 145, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side full back (Walker)', 'Hold a supporting position and cross early from the half-space'),
    (2, 'Weak-side winger (Sterling)', 'Lay the ball back to the full back'),
    (3, 'Forward and 8s', 'Run onto the space between back line and goalkeeper')
) AS v(so, role, job);

-- 53. pp.146-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 11: Switching Play to the Weak Side when the Overload is Blocked Against the 4-3-3', 'Narrow winger: 8 overlaps',
    'The winger drifts inside to take the switch in a narrow position. That lets the CB mark the 8 and keeps the full back''s gap small, so runs in behind are harder.',
    'Winger receives the switch infield',
    'The 8 overlaps outside for a 2v1 and crosses low. If the full back follows him, the winger is briefly free to cross early.',
    '4-3-3', 146, 152, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side winger (Sterling)', 'Receive narrow; feed the overlap or cross early if left alone'),
    (2, 'Weak-side attacking midfielder (Gundogan)', 'Overlap round the outside, receive in behind, cross low')
) AS v(so, role, job);

-- 54. pp.148-157
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 11: Switching Play to the Weak Side when the Overload is Blocked Against the 4-3-3', 'Narrow winger: full back overlaps',
    'The winger has taken the switch narrow and the 8 is not available out wide.',
    'Winger narrow; full back free to go',
    'The full back overlaps for a 2v1 and crosses. If the opposing full back tracks him, the winger has a moment to cross early.',
    '4-3-3', 148, 157, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side full back (Walker)', 'Overlap round the winger, receive in behind and cross'),
    (2, 'Weak-side winger (Sterling)', 'Feed the overlap, or exploit the free seconds to cross early'),
    (3, 'Left full backs (Delph/Zinchenko)', 'Book note: more midfield-type, so they favour early crosses and key passes over underlaps')
) AS v(so, role, job);

-- 55. pp.160-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 12: Attacking Against a Back 5', 'Reading how a back 5 blocks overloads',
    'A five-man line (shown as 5-4-1) gives 2v2 in both wide areas. The wide CBs follow the 8s'' diagonal runs and step up to stop them turning between the lines. The weak-side wide CB can still tuck in and close the middle.',
    'Opponent drops into a back 5',
    'City see that overloads behind the wing back and receiving between the lines are both blocked, and switch to the back-5 solutions.',
    '5-4-1', 160, 162, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielders (Silva/Bernardo)', 'Expect to be tracked and stepped on; keep the ball rather than force a turn'),
    (2, 'Centre forward (Aguero)', 'Offer the inside lane that opens when the wide CB follows a runner'),
    (3, 'Winger (Sane)', 'Ball is directed to him; he looks for the 8''s diagonal run')
) AS v(so, role, job);

-- 56. pp.163-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 12: Attacking Against a Back 5', 'Winger spins in behind wing back',
    'The 8 can''t turn between the lines, so play goes to the winger. A wing back marking him tight leaves space behind.',
    'Wing back squeezes the winger closely',
    'The winger checks back then spins, or simply sprints, into the space behind for a pass to cross.',
    '5-4-1', 163, 163, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Sterling)', 'Fake to drop, then change direction into the space behind the wing back'),
    (2, 'Full back / passer (Walker)', 'Play the ball in behind for the run'),
    (3, 'Centre forward (Aguero)', 'Drift to the weak side, taking his marker away to free space near the ball')
) AS v(so, role, job);

-- 57. pp.164-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 12: Attacking Against a Back 5', 'Winger-8 one-two behind wing back',
    'The wing back stands off, so the winger gets the ball facing goal. The wide CB marks the 8 on his goal side.',
    'Winger receives facing goal with the wing back not tight',
    'A wall pass with the 8 puts the winger in behind the wing back to cross low.',
    '5-4-1', 164, 164, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Sterling)', 'Play into the 8 and run behind the wing back for the return'),
    (2, 'Attacking midfielder (Bernardo)', 'Move off his marker to offer the wall pass'),
    (3, 'Centre forward (Aguero)', 'Pull his marker towards the weak side')
) AS v(so, role, job);

-- 58. pp.165-165
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 12: Attacking Against a Back 5', '8 drops, then spins behind wide CB',
    'The wide CB marks the 8 tight in anticipation, which leaves space behind that CB.',
    'Wide CB steps tight to the 8',
    'The 8 drops to drag the CB, then sprints in behind onto the winger''s timed pass, dribbles on and crosses.',
    '5-4-1', 165, 165, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Bernardo)', 'Drop to pull the CB, then turn and attack the space he left'),
    (2, 'Winger (Sterling)', 'Carry the ball inside to open a lane and time the pass in behind'),
    (3, 'Centre forward (Aguero)', 'Pull his marker to the weak side')
) AS v(so, role, job);

-- 59. pp.166-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 12: Attacking Against a Back 5', 'Switch to isolate wing back 1v1',
    'This simple answer to a five-man defence uses City''s 1v1 wingers.',
    'Weak-side winger isolated against the wing back',
    'The winger beats the wing back on the outside and crosses low for an onrushing 8.',
    '5-4-1', 166, 166, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Fernandinho)', 'Switch play quickly to the weak-side winger'),
    (2, 'Weak-side winger (Sane)', 'Take on the wing back 1v1, go outside and cross low'),
    (3, 'Far attacking midfielder (Bernardo)', 'Arrive in the box to finish')
) AS v(so, role, job);

-- 60. pp.167-167
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 12: Attacking Against a Back 5', 'Full back makes 2v1, early cross',
    'Early crosses against the five-man line come from the full back, the 8 or the winger as the three wide players rotate.',
    '6 plays the switch',
    'The full back steps up for a 2v1 with the winger, takes the lay-off and crosses early between defenders and keeper.',
    '5-4-1', 167, 167, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side full back (Zinchenko)', 'Push forward on the switch, receive back and cross early'),
    (2, 'Weak-side winger (Sane)', 'Hold the wing back and lay the ball back'),
    (3, 'Defensive midfielder (Fernandinho)', 'Play the switch'),
    (4, 'Forward and 8s', 'Attack the space in front of the keeper')
) AS v(so, role, job);

-- 61. pp.168-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 12: Attacking Against a Back 5 - Switching to a 2-2-5-1', 'Switch to a 2-2-5-1 shape',
    'When chances dry up against a back 5, Pep adds a player beside the forward. An 8 or a winger moves inside, the full back takes the width, the 6 shifts across and the far full back tucks in next to him, forming 2-2-5-1.',
    'No scoring chances against a back 5',
    'The extra central body pulls the wide CBs inside, so 2v1s open again in both wide areas.',
    '5-4-1', 168, 168, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Silva)', 'Push up next to the forward'),
    (2, 'Winger (Sane)', 'Come inside into the half-space'),
    (3, 'Full back (Zinchenko)', 'Push high and wide to give width'),
    (4, 'Defensive midfielder (Fernandinho) and other full back (Walker)', 'Form the two-man midfield base for balance')
) AS v(so, role, job);

-- 62. pp.169-176
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Tactical Situation 12: Attacking Against a Back 5 - Switching to a 2-2-5-1', '2-2-5-1 through the middle',
    'The wide CBs stay wide to stop the 2v1s, and the inside players get a 4v3 in the centre.',
    'Opposing wide CBs hold wide positions',
    'An 8 receives and turns between the lines for a final pass. If closed down, he plays first time to the free 8, or the forward drops and sets it to the free man.',
    '5-4-1', 169, 176, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Silva)', 'Move into a passing lane; turn if unmarked, otherwise set first time to the free 8'),
    (2, 'Other attacking midfielder (Bernardo)', 'Be the free player and play the key pass in behind'),
    (3, 'Centre forward (Aguero)', 'Drop to receive when no lane to the 8 exists, then turn or lay off'),
    (4, 'Defensive midfielder / back pair', 'Feed the central players')
) AS v(so, role, job);

-- 63. pp.172-176
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-attacking-tactics-tactical-analysis-and-sessions-from-manchester-c'), 'in_possession', 'Session 12: Attacking Against a Back 5', 'Advanced full back reads, recycles, switches',
    'In the 2-2-5-1, the advanced full back gets the ball in the wide zone with a 2v1. His choice depends on how the defenders react.',
    'Ball reaches the advanced full back wide',
    'If the near CB is too far away, he plays the winger in behind the wing back. If the CB tracks the winger, he plays back to the 6, who switches to the free weak-side winger or into a central gap.',
    '5-4-1', 172, 176, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advanced full back (Zinchenko)', 'Read the CB''s reaction; play in behind or recycle to the 6'),
    (2, 'Winger (Sane)', 'Run behind the wing back when the CB can''t track'),
    (3, 'Defensive midfielder (Fernandinho)', 'Long switch to the far winger, or long pass into a gap between defenders'),
    (4, 'Weak-side winger (Sterling)', 'Stay wide to receive unmarked after the block shifts')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1968-coaching-book-pep-guardiola-attacking-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
