-- 1950 📚 Coaching book patterns: Terzis, "Marcelo Bielsa - Attacking Tactics
-- and Sessions" (SoccerTutor), Bielsa's Leeds United 4-1-4-1, 2019-20 and
-- 2020-21.  Every page (1-304) read; each team pattern the book describes
-- written up in OUR OWN WORDS (short paraphrase, nothing copied): moment,
-- trigger, aim, app page numbers as the citation, and who does what.  The
-- book names no opponent shapes, so vs_formation stays NULL.  Training
-- sessions / practices, intro, contents and adverts are left out.  Owner's
-- personal library.  (James 11/26 'continue with the reading of the coach
-- viewer books')
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Marcelo Bielsa - Attacking Tactics and Sessions',
    author      = 'Athanasios Terzis',
    team        = 'Leeds United',
    season      = '2019-20, 2020-21',
    method_note = 'The author analysed Bielsa''s Leeds United in the 4-1-4-1 across the 2019-20 Championship title season and 2020-21 Premier League (9th); a phase of play counted as a pattern only once it had been seen at least 10 times, then it was drawn up and turned into a training session. Covers the attacking style (four lines in build-up, target areas, triangles, width and depth) and 19 tactical situations: the DM dropping in build-up, finding the free player between the lines, midfield switches and rotations, forwards and attacking midfielders dropping or running in behind, wingers on the ''ideal line'', crosses, wide combinations with the full back advanced / normal / deep, switching play to the weak-side full back and winning the second ball.'
WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions');

-- 1. pp.19-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Marcelo Bielsa''s Attacking Style of Play', 'Four horizontal lines in build-up',
    'From the 4-1-4-1 Leeds spread into four staggered lines so players stand in the gaps between the opponent''s lines; the lines are only starting points and players swap lines freely.',
    'Build-up from the back under way',
    'Find free space between opposition lines and stay flexible to switch or rotate.',
    NULL, 19, 19, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'First line'),
    (2, 'Full backs + defensive midfielder', 'Second line'),
    (3, 'Two attacking midfielders', 'Third line, between opposition midfield and defence'),
    (4, 'Wingers + centre forward', 'Fourth line, highest'),
    (5, 'Any line player', 'May drop into the line behind or step up a line')
) AS v(so, role, job);

-- 2. pp.20-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Marcelo Bielsa''s Attacking Style of Play', 'Feed the key passing and crossing zones',
    'The team first works the ball into the two central zones just outside the box in front of the back line (where the AMs operate) or the wide crossing zones, and only then into the finishing area behind the defence; heat maps show the advanced wide areas and the two AM pockets as the busiest spaces.',
    'Ball reaches the middle third',
    'Final ball or shot comes from the zones with the highest scoring odds.',
    NULL, 20, 21, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielders (Rodrigo, Klich)', 'Occupy the two central key-pass pockets'),
    (2, 'Wingers / full backs', 'Occupy the advanced wide combination areas'),
    (3, 'Forward (Bamford)', 'Attack the finishing area behind the line')
) AS v(so, role, job);

-- 3. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Marcelo Bielsa''s Attacking Style of Play', 'Wide triangles for quick combinations',
    'In the busy wide areas the winger, full back, attacking midfielder and forward form linked triangles so two or three players can combine at speed to overload and unbalance the defence.',
    'Ball moved into an advanced wide area',
    'Numerical edge out wide and a way into the target areas.',
    NULL, 22, 22, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Wide high vertex of the triangle'),
    (2, 'Full back', 'Wide deeper vertex, support or overlap'),
    (3, 'Attacking midfielder', 'Inside vertex in the half-space'),
    (4, 'Forward', 'Central link for the wide triangle')
) AS v(so, role, job);

-- 4. pp.23-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Marcelo Bielsa''s Attacking Style of Play', 'Max width to stretch the block',
    'Wingers and/or full backs hug the touchlines. If the opponent stays narrow, the wide men get room for 1v1s or wide combos; if the opponent widens to cover them, the gaps between defenders grow and the channels open for passes into the key central area.',
    'Opponent sets a compact block',
    'Space is created either wide or in the inside channels.',
    NULL, 23, 24, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (Harrison, Raphinha)', 'Stay wide on the touchline, seek 1v1'),
    (2, 'Full backs (Alioski, Ayling)', 'Give width when the winger tucks in'),
    (3, 'Attacking midfielders', 'Receive in the widened channels')
) AS v(so, role, job);

-- 5. pp.25-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Marcelo Bielsa''s Attacking Style of Play', 'High front line, deep full backs',
    'For depth the wingers and especially the forward stay as high as possible, often on the last line or even offside, pinning the back four; the full backs stay deep to pull the opposing wide midfielders forward, leaving room for the wingers and between the lines.',
    'Attacking phase in middle third',
    'Bigger gap between opposition defence and midfield for third line players, and the forward free on the blind side.',
    NULL, 25, 25, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'Stay on or behind the last line, blind side of defenders'),
    (2, 'Wingers', 'Stay high and wide to pin full backs'),
    (3, 'Full backs (Alioski, Ayling)', 'Hold deep positions to draw wide midfielders out'),
    (4, 'Attacking midfielders', 'Use the extra space between the lines')
) AS v(so, role, job);

-- 6. pp.26-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Marcelo Bielsa''s Attacking Style of Play', 'Final pass range by line',
    'Passes into the finishing area can come long from the first line, medium from the second or short from the third; short passes from a third line player in the key central area are the most accurate and preferred.',
    'Ball near target areas',
    'Pick the shortest, most accurate supply route into the box.',
    NULL, 26, 26, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Long passes in behind (rare)'),
    (2, 'Full backs / DM', 'Medium-range passes in behind'),
    (3, 'Attacking midfielder (Klich)', 'Short final pass from the key central area, first choice')
) AS v(so, role, job);

-- 7. pp.27-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Marcelo Bielsa''s Attacking Style of Play', 'Through the second line, not past it',
    'When opposing midfielders keep compact spacing and have time to block a direct pass from a centre back to an AM, Leeds play first to the DM between the lines; from there the midfielders are too close to react and through passes to the AMs open up.',
    'Direct CB-to-AM lane can be closed in time',
    'Break the first line via the DM and then reach the third line.',
    NULL, 27, 28, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Koch)', 'Pass into the DM rather than force the direct ball'),
    (2, 'Defensive midfielder (Phillips)', 'Receive and turn between the lines, play through'),
    (3, 'Attacking midfielders (Rodrigo, Klich)', 'Wait for the through pass; can also drop into the second line'),
    (4, 'Full backs', 'Alternative second line receivers')
) AS v(so, role, job);

-- 8. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Marcelo Bielsa''s Attacking Style of Play', 'Centre back carries into open space',
    'When the centre backs find free space ahead of them they dribble forward, turning a first line player into a second line player and drawing a presser.',
    'Free space in front of the centre back',
    'Gain ground and commit an opponent.',
    NULL, 28, 28, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Drive forward with the ball'),
    (2, 'Midfielders', 'Adjust to offer next passing lines')
) AS v(so, role, job);

-- 9. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 1: Defensive Midfielder Drops Back to Create a Numerical Advantage for the Build-up', 'DM drops to form back three',
    'Against two forwards who press hard, the DM drops either between the two centre backs or beside one of them to make a back three and a 3v2 at the back; an AM then drops into the DM slot to keep a central short option. Against low pressure no drop is needed.',
    'Heavy pressure by the two forwards on the centre backs',
    '3v2 first line, ball to the unmarked of the three.',
    NULL, 30, 30, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'Drop between or beside the centre backs'),
    (2, 'Centre backs (Cooper, Koch)', 'Split wider to make a back three'),
    (3, 'Attacking midfielder', 'Drop into the vacated DM space'),
    (4, 'Full backs', 'Wide outlets if no AM drops')
) AS v(so, role, job);

-- 10. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 1: Defensive Midfielder Drops Back to Create a Numerical Advantage for the Build-up', 'Strong-side chain reaction',
    'When the DM drops and the strong-side AM drops into his spot, a chain of moves follows on that side: the winger comes inside into the key passing pocket left by the AM while the full back holds width; the strong side is thinner, the weak side fuller, so a free weak-side centre back often switches play.',
    'DM drops and strong-side AM (Klich) is closer to the DM slot',
    'Keep balance and a link between first and third lines; attack the overloaded side.',
    NULL, 31, 31, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'Drop to form the back three'),
    (2, 'Strong-side AM (Klich)', 'Drop into the DM position as link player'),
    (3, 'Right winger (Raphinha)', 'Move inside into the key passing area'),
    (4, 'Right back (Ayling)', 'Stay put to give width and a passing option'),
    (5, 'Weak-side centre back (Cooper)', 'Free player for a switch')
) AS v(so, role, job);

-- 11. pp.32-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 1: Defensive Midfielder Drops Back to Create a Numerical Advantage for the Build-up', 'Weak-side clockwise rotation',
    'If the weak-side AM is the one who drops, the left side rotates: the AM drops between the lines, the left winger tucks into the AM spot, the left back pushes higher and wider, and the left centre back slides toward the touchline, again giving a 3v2 at the back. Applies whether the DM drops centrally or to one side.',
    'DM drops and weak-side AM (Rodrigo) is closer to the DM slot',
    'Rebalance the shape and keep width; then attack the side with more players.',
    NULL, 32, 33, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'Drop centrally or beside a centre back'),
    (2, 'Left AM (Rodrigo)', 'Drop as link between first and third lines'),
    (3, 'Left winger (Harrison)', 'Move inside to the vacated AM position'),
    (4, 'Left back (Alioski)', 'Push higher and wider for width'),
    (5, 'Left centre back (Cooper)', 'Slide out toward the side-line')
) AS v(so, role, job);

-- 12. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 1: Defensive Midfielder Drops Back to Create a Numerical Advantage for the Build-up', 'Free man in back three steps up',
    'Once the 3v2 exists, the ball goes to the free first line player (often the dropped DM in a wide slot), who has time to carry or pass forward and becomes a second line player again, feeding the left back, the winger in the key central area or the AM now in the DM spot.',
    '3v2 at the back created',
    'Progress through the freed player; note one side is weakened by the rotation.',
    NULL, 34, 34, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'Free player: dribble forward, then pass on'),
    (2, 'Left back (Alioski)', 'Wide option'),
    (3, 'Left winger (Harrison)', 'Option in the key central area'),
    (4, 'AM in DM slot (Rodrigo)', 'Central option')
) AS v(so, role, job);

-- 13. pp.42-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 2: Effective Positioning Between the Lines to Move the Ball to a Free Player', 'Ball carrier invites first presser',
    'Against a compact two-line block, the player on the ball dribbles forward to draw the central first-line defender out; this stretches the vertical gap to the second line and the flanking pressers shift in, widening their spacing and opening space centrally behind the presser and on both flanks.',
    'Compact opponents with about 10 m spacing',
    'Create a free player between the lines and a 2v1 centrally.',
    NULL, 42, 45, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Dribble at the first presser to pull him out'),
    (2, 'Player between the lines', 'Drop a few metres into the freed central space, away from his marker'),
    (3, 'Wide players', 'Already hold the wide spaces, 1v1 against their marker')
) AS v(so, role, job);

-- 14. pp.46-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 2: Effective Positioning Between the Lines to Move the Ball to a Free Player', 'Receiver out of shadow, half-turned',
    'The man between the lines takes up a spot outside the presser''s cover shadow, between the two lines and between two second-line opponents (so neither knows who marks him), body half-turned; a third line through pass then lets him turn and drive forward.',
    'First line presser closes the ball carrier',
    'Break the first line with a direct through pass to the free man.',
    NULL, 46, 46, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player between the lines', 'Leave the shadow, stand between lines and opponents, half-turned'),
    (2, 'Ball carrier', 'Play the through pass when the lane is open')
) AS v(so, role, job);

-- 15. pp.47-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 2: Effective Positioning Between the Lines to Move the Ball to a Free Player', 'Link player bounce to free man',
    'If the free man is still in a presser''s shadow, a teammate comes inside to offer a second option: he takes the through pass and lays it first time to the free man (through + back pass). Under heavy close pressure the shadow widens, so instead a short pass goes sideways to a teammate who moves inside for a better angle and plays it through first time.',
    'Free player hidden in a shadow, or carrier pressed tightly',
    'Reach the free man indirectly via a triangle.',
    NULL, 47, 48, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Pass to the link player'),
    (2, 'Link player (wide/forward teammate)', 'Come inside for an angle, play first time to free man'),
    (3, 'Player between the lines', 'Expect indirect passes as well as direct ones')
) AS v(so, role, job);

-- 16. pp.49-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 2: Effective Positioning Between the Lines to Move the Ball to a Free Player', 'Go around the narrowed block',
    'When the covering defenders tuck in and close the through lanes, the ball is moved wide; as the block shifts toward the ball, a wide high player drops at the right moment (not too deep) and plays inside to the free man between the lines.',
    'Through lanes closed by inward-shifting cover',
    'Use the space wide to reach the free player around the opponents.',
    NULL, 49, 50, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Switch to the wide player'),
    (2, 'Wide player', 'Receive as block shifts, pass forward'),
    (3, 'Wide high player', 'Drop at the right moment, lay inside'),
    (4, 'Player between the lines', 'Stay in the gap ready for the inside pass')
) AS v(so, role, job);

-- 17. pp.51-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 2: Effective Positioning Between the Lines to Move the Ball to a Free Player', 'Exploit defender who follows the dropper',
    'If a second-line defender follows the dropping player to mark him, space opens behind that defender; a forward player with positional advantage runs into it for a lofted pass, or a 2nd line pass wide sets up a through pass for a diagonal run. If the other defenders tuck in to cover, lofted passes go to runs into the vacated wide spaces.',
    'Defender steps out to mark the player dropping between the lines',
    'Play in behind the second line of pressure.',
    NULL, 51, 53, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping player', 'Drag the marker out of the line'),
    (2, 'Forward runner', 'Run into the space left behind, centrally or diagonally'),
    (3, 'Ball carrier', 'Lofted pass into the space, or pass wide first'),
    (4, 'Wide player', 'Receive the 2nd line pass and play the through ball')
) AS v(so, role, job);

-- 18. pp.63-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 3: Moving the Ball to the Defensive Midfielder in Space', 'DM positioning to receive from CB',
    'When a centre back has the ball and the forward presses him, the DM sets up outside the forward''s shadow, between the lines and roughly equidistant from two midfielders, at about a 45 degree angle to the passer and half-turned, so he can receive, turn and drive past the first line; he may also show on the other side of the shadow. He also gives an inside option when the ball goes wide to the full back.',
    'Forward presses the centre back on the ball',
    'DM receives free between the lines and progresses or plays through to the AMs.',
    NULL, 63, 66, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'Leave shadow, sit between two midfielders, 45 degree angle, half-turned'),
    (2, 'Centre back (Koch)', 'Pass into the DM through the gap'),
    (3, 'Attacking midfielders', 'Receive the next through pass in the key central area')
) AS v(so, role, job);

-- 19. pp.67-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 3: Moving the Ball to the Defensive Midfielder in Space', 'AM as link to reach the DM',
    'If the forward''s pressing body shape keeps the DM in the shadow, the strong-side AM drops to offer the centre back a forward pass and lays it back first time to the DM in space.',
    'DM free but direct pass blocked by presser''s shadow',
    'DM receives indirectly and drives forward.',
    NULL, 67, 68, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Klich)', 'Drop to receive from CB, first-time back pass'),
    (2, 'Centre back (Koch)', 'Pass forward to the AM'),
    (3, 'Defensive midfielder (Phillips)', 'Stay alert for the indirect pass')
) AS v(so, role, job);

-- 20. pp.69-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 3: Moving the Ball to the Defensive Midfielder in Space', 'Full back as link to reach the DM',
    'If the forward pass to the AM is shut by a narrow wide midfielder, the centre back plays behind the first line to the full back, whose new angle opens the pass into the DM behind the forward. Must be played fast.',
    'AM lane closed by narrow wide midfielder',
    'DM receives free of marking behind the forward.',
    NULL, 69, 69, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Koch)', 'Pass to the full back past the forward'),
    (2, 'Right back (Ayling)', 'Play inside to the DM'),
    (3, 'Defensive midfielder (Phillips)', 'Receive in the space behind the forward')
) AS v(so, role, job);

-- 21. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 3: Moving the Ball to the Defensive Midfielder in Space', 'CB partner changes the angle',
    'When the forward presses one centre back hard with a wide shadow, a quick sideways pass to the other centre back changes the angle and he plays through to the DM before the forward can drop back.',
    'Heavy pressure and wide shadow on one centre back',
    'DM receives between the lines before the forward recovers.',
    NULL, 70, 70, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressed centre back (Koch)', 'Square pass to partner'),
    (2, 'Other centre back (Cooper)', 'First pass through to the DM'),
    (3, 'Defensive midfielder (Phillips)', 'Receive in space')
) AS v(so, role, job);

-- 22. pp.71-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 3: Moving the Ball to the Defensive Midfielder in Space', 'AM attacks space behind DM''s marker',
    'If an opposing central midfielder steps up to mark the DM, the AM moves into the space behind that midfielder; the ball goes CB to full back and the full back threads it to the AM. When an opposing forward marks the DM, he often drifts to the strong side to free space for a teammate.',
    'Opposing midfielder or forward man-marks the DM',
    'Use the space vacated by the marker to reach the AM.',
    NULL, 71, 71, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'Draw the marker; move away to strong side'),
    (2, 'Attacking midfielder (Klich)', 'Occupy the space behind the marker'),
    (3, 'Centre back (Koch)', 'Go around via the full back'),
    (4, 'Right back (Ayling)', 'Through pass to the AM')
) AS v(so, role, job);

-- 23. pp.79-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 4: Midfielders Switching Positions to Find Space Between the Lines', 'DM and strong-side AM swap places',
    'A centre back or full back has time on the ball, but the DM is tightly marked by an opposing central midfielder and cannot get free.',
    'Ball reaches a free CB/FB while the DM is man-marked',
    'Drag the DM''s marker away so the AM can receive between the lines, or reach the DM directly if the marker stays.',
    NULL, 79, 81, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'runs diagonally forward behind the opposing wide midfielder'),
    (2, 'Strong-side attacking midfielder (Klich)', 'drops into the vacated DM spot, receives, turns, plays forward'),
    (3, 'Ball-carrying centre back (Koch)', 'reads the marker: if he follows, pass to the AM; if not, find the DM'),
    (4, 'Right back (Ayling)', 'if the wide mid is narrow, gives a route around him to the DM')
) AS v(so, role, job);

-- 24. pp.82-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 4: Midfielders Switching Positions to Find Space Between the Lines', 'DM and weak-side AM swap places',
    'The DM is tightly marked and the strong-side AM is too high to drop back in time.',
    'CB free on the ball, DM marked, strong-side AM too far up',
    'The weak-side AM fills the DM spot that has been emptied and receives free between the lines.',
    NULL, 82, 83, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'moves away from the ball, taking his marker with him'),
    (2, 'Weak-side attacking midfielder (Rodrigo)', 'drops back and across into the DM''s starting spot to receive'),
    (3, 'Strong-side attacking midfielder (Klich)', 'stays high'),
    (4, 'Centre back (Koch)', 'plays into the freed central space')
) AS v(so, role, job);

-- 25. pp.92-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 5: Rotations of the Midfield Three', 'Balanced high-low midfield three',
    'The midfield three keep a staggered shape so they are ready to rotate: one AM high and one AM low, depending on which side the DM is on.',
    'Ball in build-up; where the DM stands decides the shape',
    'Keep a triangle that can rotate clockwise or anti-clockwise to free a central midfielder.',
    NULL, 92, 93, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'stands either near the strong side or away from it'),
    (2, 'Strong-side attacking midfielder (Rodrigo)', 'high when the DM is near the strong side, low when the DM is away from it'),
    (3, 'Weak-side attacking midfielder (Klich)', 'low when the DM is near the strong side, high when the DM is away from it')
) AS v(so, role, job);

-- 26. pp.94-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 5: Rotations of the Midfield Three', 'Anti-clockwise rotation started by the DM',
    'The DM is near the strong side but closely marked, so he cannot offer a passing option to the CB on the ball.',
    'DM near the strong side and man-marked; CB has time',
    'The weak-side AM arrives in the space the DM has emptied and receives free to turn and play forward.',
    NULL, 94, 95, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'runs diagonally behind the opposing wide midfielder, pulling his marker'),
    (2, 'Weak-side attacking midfielder (Klich)', 'drops back and across into that space to receive'),
    (3, 'Strong-side attacking midfielder (Rodrigo)', 'slides to the weak side to keep the balance'),
    (4, 'Centre back (Koch)', 'passes to Klich, or to Phillips (direct or via the RB) if the marker stayed')
) AS v(so, role, job);

-- 27. pp.96-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 5: Rotations of the Midfield Three', 'Clockwise rotation started by the strong-side AM',
    'The DM is on the weak side, hidden behind the opposing forward''s cover shadow, and the strong-side AM''s passing lane is too narrow.',
    'DM blocked by the forward''s shadow; space free between the lines',
    'The strong-side AM drops from his marker''s blind side to receive and turn, and the other two midfielders rotate to keep the balance.',
    NULL, 96, 97, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side attacking midfielder (Rodrigo)', 'drops quickly from behind his marker into the space; if marked, keeps it simple'),
    (2, 'Defensive midfielder (Phillips)', 'moves up into a more advanced spot'),
    (3, 'Weak-side attacking midfielder (Klich)', 'shifts across toward the right'),
    (4, 'Centre back (Koch)', 'must have time on the ball for the rotation to work')
) AS v(so, role, job);

-- 28. pp.105-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 6: Attacking Midfielder Drops Back to Receive Between the Lines', 'Strong-side AM drops to free the full back',
    'The full back has the ball wide and fairly deep. The winger''s space is limited and the DM is too far away or cannot get across to give an inside option.',
    'FB on the ball wide with no inside pass',
    'Give the FB an inside outlet between the lines so the ball can go forward or be switched.',
    NULL, 105, 106, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side attacking midfielder (Klich)', 'drops quickly from outside his marker''s view to receive and turn'),
    (2, 'Forward (Bamford)', 'drops back as well'),
    (3, 'Weak-side attacking midfielder (Rodrigo)', 'pushes forward into the gap between two defenders'),
    (4, 'Defensive midfielder (Phillips)', 'advances only if an AM receives with time; stays deep as cover if the AM is pressed'),
    (5, 'Left back (Alioski)', 'plays inside to the dropping AM')
) AS v(so, role, job);

-- 29. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 6: Attacking Midfielder Drops Back to Receive Between the Lines', 'Forward drops when the AM is tracked',
    'The opposing central midfielder follows the dropping AM, which leaves space behind that midfielder.',
    'Opposing CM tracks the dropping AM',
    'The forward takes the space between the lines, fed directly or through a link player.',
    NULL, 107, 107, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'drops into the space vacated behind the opposing CM'),
    (2, 'Attacking midfielder (Klich)', 'drops and pulls his marker'),
    (3, 'Left winger (Harrison)', 'drops to receive and plays first time inside to the forward'),
    (4, 'Left back (Alioski)', 'passes direct to the forward or to the winger')
) AS v(so, role, job);

-- 30. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 6: Attacking Midfielder Drops Back to Receive Between the Lines', 'Weak-side AM drops for the full back',
    'The strong-side AM is too high and the DM is far from the ball and blocked by the opposing forward.',
    'FB on the ball; strong-side AM high; DM blocked',
    'The weak-side AM gives the FB a pass inside, then turns and plays through or switches.',
    NULL, 108, 108, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side attacking midfielder (Rodrigo)', 'drops back quickly between the lines'),
    (2, 'Defensive midfielder (Phillips)', 'runs forward once Rodrigo has dropped, if there is space'),
    (3, 'Strong-side attacking midfielder (Klich)', 'stays high'),
    (4, 'Left back (Alioski)', 'plays inside to Rodrigo')
) AS v(so, role, job);

-- 31. pp.109-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 6: Attacking Midfielder Drops Back to Receive Between the Lines', 'AMs stand between lines and between defenders',
    'In the attacking phase both AMs stand between the opponent''s midfield and back lines and also in the gaps between full back and centre back.',
    'Attacking phase with the ball reaching the second line',
    'Give defenders two players to watch, so gaps open and the AMs can receive and turn or run in behind.',
    NULL, 109, 110, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielders (Rodrigo, Klich)', 'stand in the CB-FB gaps, between the lines'),
    (2, 'Winger (Harrison)', 'pins the full back wide so the FB has to pick between him and the AM'),
    (3, 'Forward (Bamford)', 'with the AM, gives the centre back two players near his zone')
) AS v(so, role, job);

-- 32. pp.112-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 7: The Forward Attacking the Space in Behind the Defensive Line', 'Forward between centre backs, level with them',
    'The forward stands in the gap between two defenders, almost level with them and the same distance from each. This gives him a zone in behind that he reaches before either defender.',
    'Free player on the ball ready to pass forward',
    'Receive a pass in behind for a 1v1 with the keeper, or drop to feet if free.',
    NULL, 112, 117, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'stays level with the back line in the widest gap; never starts deeper than the defenders'),
    (2, 'Wingers', 'stay near the touchlines so the full backs are stretched and the gaps widen'),
    (3, 'Passer (any line, e.g. CB Cooper)', 'plays an accurate ball into the forward''s area of advantage')
) AS v(so, role, job);

-- 33. pp.118-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 7: The Forward Attacking the Space in Behind the Defensive Line', 'Forward slips to the blind side of a goal-side marker',
    'On the strong side, the forward''s marker takes a goal-side position, which blocks the forward from getting in behind.',
    'Defender sits goal-side on the line from the forward to goal',
    'Move to the defender''s blind side between the CBs so he cannot see both man and ball, then receive in behind.',
    NULL, 118, 119, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'moves behind the defender''s back into the gap between the CBs, level with them'),
    (2, 'Attacking midfielder (Rodrigo)', 'plays the through ball into the new area of advantage')
) AS v(so, role, job);

-- 34. pp.120-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 7: The Forward Attacking the Space in Behind the Defensive Line', 'Forward shifts to the weak-side gap',
    'The two centre backs are too close together, so there is little space between them for the forward.',
    'Centre backs narrow with a small gap between them',
    'Take up a position between the weak-side CB and full back, on the CB''s blind side, for a lofted ball in behind.',
    NULL, 120, 121, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'moves across to sit between the weak-side CB and FB, level with them'),
    (2, 'Weak-side attacking midfielder (Klich)', 'moves inside to fill the space the forward left'),
    (3, 'Centre back (Cooper)', 'plays a lofted ball over the lines into the forward''s zone')
) AS v(so, role, job);

-- 35. pp.128-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 8: Forward Stays Behind Defensive Line (Blind) and Drops Back at the Correct Moment', 'Forward hides offside, gets onside, then runs in behind',
    'The forward waits behind the back line and out of the defenders'' sight, then drops to get onside just as a teammate gets the ball with time and a good angle.',
    'Full back, DM or CB gets the ball with time and a good passing angle',
    'Make a timed run through the gap the moment the pass is about to be played, for a 1v1 with the keeper.',
    NULL, 128, 130, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'stays blind behind the CBs, drops onside, then runs into his area of advantage'),
    (2, 'Right back (Ayling) / Defensive midfielder (Phillips)', 'receives with time and an angle and plays in behind'),
    (3, 'Centre back', 'can play the ball long or mid-length when he has stepped into the second line')
) AS v(so, role, job);

-- 36. pp.131-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 8: Forward Stays Behind Defensive Line (Blind) and Drops Back at the Correct Moment', 'Forward drops between centre backs to receive',
    'The ball carrier has no angle to play in behind, or the centre backs are close together or retreat once the DM is free.',
    'DM free on the ball without a passing angle in behind; CBs close together',
    'Drop quickly from the blind side to receive between the lines, turn, and pass in behind or to an AM.',
    NULL, 131, 131, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'drops quickly between the CBs from their blind side'),
    (2, 'Defensive midfielder (Phillips)', 'plays into the forward''s feet'),
    (3, 'Wingers / attacking midfielders', 'run in behind for the forward''s key pass')
) AS v(so, role, job);

-- 37. pp.132-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 8: Forward Stays Behind Defensive Line (Blind) and Drops Back at the Correct Moment', 'Forward drops a few yards and shoots',
    'The centre backs are far apart and hold a high line instead of dropping when the DM gets the ball.',
    'DM receives; opposing CBs stay high with a big gap between them',
    'Receive half-turned just onside, take a first touch forward and shoot before the defenders close.',
    NULL, 132, 132, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'drops only a short way, receives half-turned, shoots'),
    (2, 'Defensive midfielder (Phillips)', 'passes into the forward''s advanced spot')
) AS v(so, role, job);

-- 38. pp.140-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 9: Moving the Ball to the Attacking Midfielders and Forward to Create Chances', 'Front three spread across the defensive gaps',
    'The two AMs and the forward each take a different gap in the back line and adjust to one another. With the forward between the CBs, the AMs sit in the FB-CB gaps; if the forward goes wide, one AM moves between the CBs.',
    'Forward changes position across the line',
    'Give the ball carrier three options in the key central area, use the gaps, and give each defender two attackers to worry about.',
    NULL, 140, 141, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'picks a gap: usually between the CBs, sometimes FB-CB on either side'),
    (2, 'Attacking midfielder (Klich)', 'moves between the CBs when the forward goes to the strong side'),
    (3, 'Attacking midfielder (Rodrigo)', 'takes the remaining CB-FB gap')
) AS v(so, role, job);

-- 39. pp.142-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 9: Moving the Ball to the Attacking Midfielders and Forward to Create Chances', 'Three passing options for the DM',
    'The DM, or a dropped AM, has the ball centrally with time between the lines, so the first line of pressure has been beaten.',
    'DM receives centrally with time between the lines',
    'Break the midfield line with a pass to one of three front players who are out of the shadows and half-turned.',
    NULL, 142, 144, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'chooses between two diagonal passes and a vertical one'),
    (2, 'Right attacking midfielder (Klich)', 'moves slightly wide, out of the CM''s shadow, open body'),
    (3, 'Left attacking midfielder (Rodrigo)', 'moves inside into the CM-wide-mid gap, half-turned'),
    (4, 'Forward (Bamford)', 'drops into the space behind the pressing CM for a vertical pass; stays high to run in behind if an AM is clearly on')
) AS v(so, role, job);

-- 40. pp.145-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 9: Moving the Ball to the Attacking Midfielders and Forward to Create Chances', 'Through pass after the CM steps out',
    'The DM has turned between the lines and the nearest opposing CM steps up to press him, leaving space behind.',
    'Opposing CM moves forward to press the DM',
    'Pass through to an AM in the space behind the CM, who turns and plays a key pass.',
    NULL, 145, 145, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Klich)', 'moves out of the CM''s shadow into the space, half-turned'),
    (2, 'Forward (Bamford)', 'drops a few yards to form a triangle and give another option'),
    (3, 'Defensive midfielder (Phillips)', 'plays the forward pass through the lane')
) AS v(so, role, job);

-- 41. pp.146-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 9: Moving the Ball to the Attacking Midfielders and Forward to Create Chances', 'Forward as a wall pass to the AM',
    'The CM presses the DM in a way that keeps the AM in his shadow, so the AM cannot be reached directly.',
    'AM stuck in the pressing CM''s shadow',
    'Use the dropping forward to lay the ball off to the free AM, while the CB who followed the forward leaves space behind.',
    NULL, 146, 146, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'drops followed by a CB and lays off without turning'),
    (2, 'Attacking midfielder (Klich)', 'receives from the lay-off and plays to the RW or switches to the LW'),
    (3, 'Other attacking midfielder (Rodrigo)', 'runs into the space behind the CB who followed'),
    (4, 'Defensive midfielder (Phillips)', 'plays into the forward')
) AS v(so, role, job);

-- 42. pp.147-148
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 9: Moving the Ball to the Attacking Midfielders and Forward to Create Chances', 'Play around a compact midfield',
    'The opposing midfield is compact or presses the DM hard, which casts a wide shadow and blocks every through pass.',
    'DM under heavy pressure with the lanes to the front three blocked',
    'Go around the midfield via the full back to reach the AM between the lines before the CM can drop.',
    NULL, 147, 148, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'plays wide to the right back'),
    (2, 'Right back (Ayling)', 'passes inside to the AM if the angle has opened, or to the dropping winger'),
    (3, 'Right winger (Raphinha)', 'starts high, drops at the right moment, plays inside to the AM'),
    (4, 'Attacking midfielder (Klich)', 'receives free in the space, turns and plays a key pass')
) AS v(so, role, job);

-- 43. pp.149-149
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 9: Moving the Ball to the Attacking Midfielders and Forward to Create Chances', 'CM drops: full back pass-and-move',
    'The opposing central midfielder drops quickly to close the space between the lines around the AM.',
    'Opposing CM drops off to cover the AM',
    'Keep the ball by using the space that opens in front of the pressure, then switch play if needed.',
    NULL, 149, 149, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'plays a quick pass and moves into support in front of the line of pressure'),
    (2, 'Attacking midfielder (Klich)', 'holds the CM''s attention'),
    (3, 'Team', 'switches play when the other side is open')
) AS v(so, role, job);

-- 44. pp.150-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 9: Moving the Ball to the Attacking Midfielders and Forward to Create Chances', 'Front three run in behind',
    'The second line has been broken and an AM has received facing forward between the lines while the defence tries to close the centre.',
    'AM receives with an open body shape and turns',
    'The other two run through the defensive gaps to receive in the finishing area.',
    NULL, 150, 151, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving attacking midfielder (Rodrigo)', 'turns and plays the key pass in behind'),
    (2, 'Forward (Bamford)', 'runs through the gap next to him'),
    (3, 'Other attacking midfielder (Klich)', 'runs between the CB and FB, or between the CBs when the three have swapped'),
    (4, 'Front three', 'keep adjusting to each other so the balance holds')
) AS v(so, role, job);

-- 45. pp.160-160
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 10: Forward Drops Back to Get Free of Marking or Create Space for Teammates', 'CB follows dropping 9, ball-side AM runs in behind',
    'The centre forward drops off into the gap between the lines and the near centre back follows him, leaving a hole in the back line on the ball side.',
    'Opposing CB steps out with the dropping forward',
    'The ball-side attacking midfielder runs into the vacated space and gets a lofted ball over the top for a chance.',
    NULL, 160, 160, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'drop between the lines and pull his CB out'),
    (2, 'Ball-side attacking midfielder (Rodrigo)', 'time a run into the space the CB left'),
    (3, 'Defensive midfielder (Phillips)', 'read it and loft the pass into the hole')
) AS v(so, role, job);

-- 46. pp.161-161
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 10: Forward Drops Back to Get Free of Marking or Create Space for Teammates', 'Far CB follows 9, weak-side AM attacks gap',
    'This time the far-side centre back follows the dropping forward. The weak-side attacking midfielder is level with, or ahead of, the opposing full back near that gap.',
    'Weak-side CB leaves the line to mark the dropping forward',
    'The weak-side AM runs diagonally into the hole and gets a lofted ball into the box.',
    NULL, 161, 161, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'drop and drag the far CB'),
    (2, 'Weak-side attacking midfielder (Klich)', 'spot the gap and run in from the blind side'),
    (3, 'Defensive midfielder (Phillips)', 'lofted pass into the runner''s path')
) AS v(so, role, job);

-- 47. pp.162-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 10: Forward Drops Back to Get Free of Marking or Create Space for Teammates', 'Lay-off combination when CB steps late',
    'The CBs hold their zone and let the forward drop, then one jumps on him as the pass arrives to stop him turning, which still opens a gap behind.',
    'Pass into the forward and a CB steps up to press him',
    'The forward lays it off first time and a through ball reaches the other AM running in behind with only the keeper to beat.',
    NULL, 162, 163, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'receive and play a square lay-off to the near AM; if that lane is blocked, play back to the DM'),
    (2, 'Strong-side attacking midfielder (Rodrigo)', 'one-touch through pass behind the stepping CB'),
    (3, 'Defensive midfielder (Phillips)', 'if the square ball is blocked, loft it in behind from the back pass'),
    (4, 'Weak-side attacking midfielder (Klich)', 'start the forward run early into the space')
) AS v(so, role, job);

-- 48. pp.164-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 10: Forward Drops Back to Get Free of Marking or Create Space for Teammates', 'Full back tucks in, switch to winger wide',
    'The CB follows the dropping forward, but the opposing full back narrows to cover the space behind him, so the AM has no edge in that gap.',
    'Opposing full back shifts inside to close the hole left by the CB',
    'The DM sends the ball out wide to the free winger, who has time to carry it forward and cross before the full back can recover.',
    NULL, 164, 164, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'drop to pull the CB out'),
    (2, 'Attacking midfielder (Rodrigo)', 'threaten the inside gap to hold the full back'),
    (3, 'Defensive midfielder (Phillips)', 'read the full back''s shift and play wide'),
    (4, 'Right winger (Raphinha)', 'receive in space, drive on and cross')
) AS v(so, role, job);

-- 49. pp.172-173
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 11: Attacking Midfielder and Winger Switch Positions to Receive Between the Lines', 'AM-winger swap opens central lane',
    'A centre back carries the ball into open space in front of him. The attacking midfielder goes wide and the winger comes inside, and the opposing central midfielder follows the AM out.',
    'CB dribbles forward; opposing CM tracks the AM wide',
    'The gap between the opposing midfielders opens, and the CB passes through it to the winger between the lines, who turns and slips in a runner.',
    NULL, 172, 173, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Koch)', 'carry into space, read the reaction, pass between the lines'),
    (2, 'Attacking midfielder (Rodrigo)', 'move wide to drag his marker'),
    (3, 'Right winger (Raphinha)', 'come inside into the gap, turn and play the key pass'),
    (4, 'Forward and other midfielders', 'run in behind the back line')
) AS v(so, role, job);

-- 50. pp.174-174
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 11: Attacking Midfielder and Winger Switch Positions to Receive Between the Lines', 'CM stays central, go round to wide AM',
    'After the swap, the opposing CM does not follow the AM wide and stays central to block the through ball, so the AM is free out wide between the lines.',
    'Opposing CM holds the middle instead of tracking',
    'The ball goes round via the full back to the free AM, who drives at the full back for a 2v1 with the winger. The winger runs diagonally behind and crosses.',
    NULL, 174, 174, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Koch)', 'pass wide to the full back'),
    (2, 'Right back (Ayling)', 'pass forward to the free AM'),
    (3, 'Attacking midfielder (Rodrigo)', 'turn, run at the full back, play the winger in'),
    (4, 'Right winger (Raphinha)', 'diagonal run behind the full back, then cross')
) AS v(so, role, job);

-- 51. pp.176-178
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 12: Positioning of the Wingers to Receive in Behind the Defensive Line', 'Winger attacks the ''ideal line'' behind FB',
    'The wingers stay near the touchline to stretch the back line. A central passer looks for them in behind the full back, and the space each winger controls depends on whether he starts level with his full back or deeper.',
    'Central midfielder on the ball facing forward with the winger wide',
    'The winger gets the ball behind the full back, as close as possible to the line from that full back to the centre of the goal, so the defender is cut off from his goal.',
    NULL, 176, 178, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Raphinha / Harrison)', 'stay wide, start level with or just deeper than the FB, receive close to the ideal line'),
    (2, 'Defensive midfielder (Phillips)', 'from a central spot play the diagonal pass, inside to outside, into the winger''s zone')
) AS v(so, role, job);

-- 52. pp.179-180
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 12: Positioning of the Wingers to Receive in Behind the Defensive Line', 'Timing the winger''s run past his FB',
    'The winger times his run behind the full back. From a deeper start he runs diagonally before the pass so he arrives level with the full back at full speed. From a level start he drifts parallel close to the full back, then breaks diagonally in behind.',
    'Passer about to play, full back standing still or with the winger out of his eyeline',
    'The winger beats a flat-footed full back to the ball, stays onside and receives close to the ideal line.',
    NULL, 179, 180, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Raphinha)', 'run before the pass, level with the FB as it is struck, then break inside-diagonal'),
    (2, 'Defensive midfielder (Phillips)', 'release at the moment the winger is level')
) AS v(so, role, job);

-- 53. pp.181-181
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 12: Positioning of the Wingers to Receive in Behind the Defensive Line', 'FB reads the run, winger checks wide',
    'The full back sees the winger coming and drops early, closing the through lane and the space behind him.',
    'Full back anticipates the diagonal run',
    'The winger changes direction away from the full back and takes the ball free in a wider position.',
    NULL, 181, 181, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Raphinha)', 'sell the run in behind, then check out wide'),
    (2, 'Defensive midfielder (Phillips)', 'switch the pass to the wider spot')
) AS v(so, role, job);

-- 54. pp.182-184
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 12: Positioning of the Wingers to Receive in Behind the Defensive Line', 'FB-CB gap decides the pass to winger',
    'The weak-side winger works off the gap between the opposing full back and the nearest centre back. A wide gap allows a ground through ball. A narrow full back leaves only a small gap.',
    'Ball central, weak-side winger starting deeper than his full back',
    'Wide gap: ground ball for a diagonal run onto the ideal line. Small gap: a very accurate lofted ball over the full back. Or the safe option: receive wide and take the full back 1v1.',
    NULL, 182, 184, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Harrison)', 'read the gap, run early to get level with the FB, or stay wide for the safe ball'),
    (2, 'Defensive midfielder (Phillips)', 'pick a ground through ball, a lofted ball in behind or a safe ball wide')
) AS v(so, role, job);

-- 55. pp.192-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 13: Positioning and Runs to Score from Crosses', 'Forward attacks space between centre backs',
    'The ball is wide and about to be crossed, and the centre forward picks the open gap among the defenders in the box.',
    'Wide player set to cross, enough distance between the CBs',
    'The forward gets to the ball first in the gap between the CBs, or between the far CB and the weak-side full back, and finishes.',
    NULL, 192, 192, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'scan, stay between defenders, attack the biggest gap'),
    (2, 'Crosser (winger)', 'aim at the space the forward picks')
) AS v(so, role, job);

-- 56. pp.193-193
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 13: Positioning and Runs to Score from Crosses', 'CBs close up, forward darts near post',
    'A centre back spots the forward''s run and tucks closer to his partner, so the gap between the CBs is too small to win a cross.',
    'Centre backs squeeze the central gap',
    'The forward cuts sharply to the open near-post space to get ahead of his marker and win the ball by a yard.',
    NULL, 193, 193, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'read the defenders and change direction to the near post'),
    (2, 'Crosser (winger)', 'low or driven ball to the near post')
) AS v(so, role, job);

-- 57. pp.194-194
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 13: Positioning and Runs to Score from Crosses', 'Forward spins off marker''s blind side',
    'A centre back marks the forward tightly, within half a metre, and would win any cross if the forward stays still.',
    'Forward tightly marked as the cross comes',
    'The forward moves off the defender''s blind side into free space in the middle of the box, and the cross goes over the defender''s head for a close-range finish.',
    NULL, 194, 194, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'move behind the marker''s back into space'),
    (2, 'Left winger (Harrison)', 'cross over the marker into the freed space')
) AS v(so, role, job);

-- 58. pp.195-196
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 13: Positioning and Runs to Score from Crosses', 'Five or six in box, safety behind',
    'When the cross is coming from the flank, Leeds commit many players to the box and keep a structured safety group behind the ball. Here the winger is the crosser.',
    'Winger ready to cross from the flank',
    'The forward takes the central gap, the weak-side AM takes the other gap, the weak-side winger takes the far post and the strong-side AM takes the edge of the box for cut-backs, while 2v1 or 3v2 cover stays at the back.',
    NULL, 195, 196, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'attack the gap between defenders, usually between the CBs'),
    (2, 'Weak-side attacking midfielder (Rodrigo)', 'attack whichever gap the forward leaves'),
    (3, 'Weak-side winger (Harrison)', 'far-post position'),
    (4, 'Strong-side attacking midfielder (Klich)', 'edge of the box for a cut-back or low cross; Bielsa wants this spot always filled'),
    (5, 'Weak-side full back (Alioski)', 'join as fifth or sixth man in the box'),
    (6, 'Centre backs (Cooper, Koch) + DM (Phillips) + strong-side FB (Ayling)', 'keep 2v1 or 3v2 at the back; the FB stays behind the ball to offer a back pass and counter-press')
) AS v(so, role, job);

-- 59. pp.197-197
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 13: Positioning and Runs to Score from Crosses', 'AM crosses: winger and FB fill box',
    'An attacking midfielder has moved wide and is the crosser, so the other runners rotate to fill the same box spots.',
    'Strong-side AM ready to cross from the flank',
    'Forward between the CBs, winger between CB and FB, the other AM to the edge of the box, weak-side FB to the far post, and the strong-side FB also runs for a fifth attacker.',
    NULL, 197, 197, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side attacking midfielder (Klich)', 'cross from the flank'),
    (2, 'Forward (Bamford)', 'space between the centre backs'),
    (3, 'Winger (Harrison)', 'space between CB and full back'),
    (4, 'Weak-side attacking midfielder (Rodrigo)', 'edge of the box'),
    (5, 'Weak-side full back (Alioski)', 'far post'),
    (6, 'Strong-side full back (Ayling)', 'extra run into the box')
) AS v(so, role, job);

-- 60. pp.210-212
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 14: Exploiting a 2v1 Advantage Wide with the Full Back in an Advanced Position', 'Quick switch to advanced FB for 2v1',
    'The opponent stays compact and blocks passes into the midfield between the lines, so Leeds go round them. The full back takes the ball in the space between the opposing midfield and back lines, beyond his direct opponent.',
    'Compact block, quick switch of play before the wide midfielder shifts across',
    'The full back gets on the ball a few yards past the wide midfielder, out of his pressure, and makes a 2v1 with the winger against the opposing full back.',
    NULL, 210, 212, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'push up behind the opposing wide midfielder to receive'),
    (2, 'Centre back (Koch)', 'switch play quickly to the full back'),
    (3, 'Right winger (Raphinha)', 'hold width near the touchline to fix the opposing full back')
) AS v(so, role, job);

-- 61. pp.213-214
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 14: Exploiting a 2v1 Advantage Wide with the Full Back in an Advanced Position', 'Winger cuts in behind FB, AM inside',
    'The full back receives in the advanced spot. The opposing full back marks the winger tightly or steps out to press the ball.',
    'Pass arrives at the advanced full back',
    'The winger runs inside between the opposing FB and CB into the space behind and crosses. At the same time the AM offers an inside pass into the key central area.',
    NULL, 213, 214, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'receive, pick the ball in behind or inside'),
    (2, 'Right winger (Raphinha)', 'move inside as the ball travels and attack behind the full back'),
    (3, 'Attacking midfielder (Klich)', 'forward run for an inside option between the lines')
) AS v(so, role, job);

-- 62. pp.215-215
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 14: Exploiting a 2v1 Advantage Wide with the Full Back in an Advanced Position', 'CB covers winger, AM runs behind CB',
    'The near centre back slides out to cover the winger who has got in behind and closes him down before he can cross.',
    'Opposing CB leaves the middle to close the winger',
    'The AM runs into the space behind that CB. The other CB can''t cover without leaving the box empty, so the AM crosses across the six-yard box or cuts back to the other AM.',
    NULL, 215, 215, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Raphinha)', 'draw the CB and pass to the runner'),
    (2, 'Attacking midfielder (Klich)', 'attack the space behind the displaced CB, then cross or cut back'),
    (3, 'Other attacking midfielder (Rodrigo)', 'arrive at the edge of the box for the cut-back')
) AS v(so, role, job);

-- 63. pp.216-217
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 14: Exploiting a 2v1 Advantage Wide with the Full Back in an Advanced Position', 'Line stretched: key pass from central area',
    'The CB tracks the winger wide, the rest of the back line shifts across and drops, and gaps open between the defenders and between the lines.',
    'Defenders shift and drop towards the strong side',
    'The AM takes an inside pass in the key central area and plays a lofted ball into a gap for the other AM''s run, or switches to the weak-side winger if the line has shifted across as a unit.',
    NULL, 216, 217, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'pass inside to the AM between the lines'),
    (2, 'Right winger (Raphinha)', 'run behind to pull the CB and stretch the line'),
    (3, 'Attacking midfielder (Klich)', 'receive centrally and play the key pass or switch'),
    (4, 'Other attacking midfielder (Rodrigo)', 'run into the gap between defenders'),
    (5, 'Weak-side winger (Harrison)', 'stay wide for the switch into empty weak-side space')
) AS v(so, role, job);

-- 64. pp.218-219
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 14: Exploiting a 2v1 Advantage Wide with the Full Back in an Advanced Position', 'Give-and-go overlap to exploit wide 2v1',
    'The winger is far enough from the opposing full back to receive free (directly, or by dropping deep to receive from the CB). The full back passes and overlaps at speed so the wide midfielder can''t recover.',
    'Winger has time and space; opposing full back not tight to him',
    'The winger moves inside and either feeds the overlapping full back behind the opposing full back to cross, or finds the AM for a key pass. If the direct ball is off, the AM acts as a link to reach the overlapper.',
    NULL, 218, 219, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Raphinha)', 'receive free (or drop to receive), carry inside, choose overlap or inside'),
    (2, 'Right back (Ayling)', 'pass and overlap at high speed behind the full back, then cross'),
    (3, 'Attacking midfielder (Klich)', 'offer inside; link pass to the overlapper if the direct lane is shut')
) AS v(so, role, job);

-- 65. pp.228-229
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 15: Combination Play Out Wide with the Full Back in a Normal Position', 'Full back threads ball behind for forward',
    'Right back gets the ball in a mid-height wide spot before the opposing wide midfielder can close him; the forward, sitting between two centre backs almost level with them, runs into the gap behind.',
    'FB on the ball with time before the wide midfielder arrives',
    'Break the last line with the fewest passes and finish in the box.',
    NULL, 228, 229, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Koch)', 'Feeds the right back wide'),
    (2, 'Right back (Ayling)', 'Plays an accurate early ball into space behind the CBs'),
    (3, 'Forward (Bamford)', 'Starts between CBs, level with them, times run to stay onside')
) AS v(so, role, job);

-- 66. pp.230-231
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 15: Combination Play Out Wide with the Full Back in a Normal Position', '3v3 wide: receivers off the shadow',
    'When the FB is held to a 3v3 on his flank, winger and attacking midfielder take half-turned spots outside the pressers'' cover shadows, between the lines of pressure and at different heights.',
    'FB in possession facing an equal-numbers press on the flank',
    'Either play through to space behind or reach a free central player who switches to the weak side.',
    NULL, 230, 231, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'Ball carrier, picks the open receiver'),
    (2, 'Right winger (Raphinha)', 'Stays wide and higher, off the shadow, open body'),
    (3, 'Attacking midfielder (Rodrigo)', 'Inside channel, at a different height to the winger'),
    (4, 'Defensive midfielder (Phillips)', 'Holds a balancing support position behind')
) AS v(so, role, job);

-- 67. pp.232-232
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 15: Combination Play Out Wide with the Full Back in a Normal Position', 'Winger drops off to face his full back',
    'The winger comes a few yards short to gain distance from the opposing full back, receives and turns to run at him; without teammates moving, a 1v1 is the only way through.',
    'Opposing FB tight; no support runs from FB or AM',
    'Win the 1v1, best when the defender is isolated after a switch and the near CB is far away.',
    NULL, 232, 232, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Raphinha)', 'Drops to get turning room, then takes on the FB'),
    (2, 'Right back (Ayling)', 'Passes into the winger''s feet')
) AS v(so, role, job);

-- 68. pp.233-233
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 15: Combination Play Out Wide with the Full Back in a Normal Position', 'FB overlap or winger give-and-go with AM',
    'Right back passes to the winger and overlaps; defenders swap marks so the winger instead drives or plays inside to a free attacking midfielder and keeps running behind the centre back, whom the wide midfielder rarely tracks.',
    'FB-to-winger pass and FB overlap pulls the opposing FB''s attention',
    'Winger gets in behind the centre back with space to run at goal.',
    NULL, 233, 233, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'Passes then overlaps to pull the opposing FB'),
    (2, 'Right winger (Raphinha)', 'Acts before the wide midfielder closes; plays inside and runs in behind'),
    (3, 'Attacking midfielder (Rodrigo)', 'Unmarked receiver who returns the final ball behind the line')
) AS v(so, role, job);

-- 69. pp.234-234
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 15: Combination Play Out Wide with the Full Back in a Normal Position', 'Third-man run to get the winger behind',
    'A fourth player is added: winger plays inside to the attacking midfielder and runs; AM finds the forward who has dropped, and the forward plays first time into the space behind the centre back for the winger.',
    'Winger passes inside and sprints behind the CB',
    'Third-man runs are hard to defend: attract defenders to one spot then release elsewhere.',
    NULL, 234, 234, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Raphinha)', 'Passes inside then runs behind the centre back'),
    (2, 'Attacking midfielder (Rodrigo)', 'Links the ball on to the forward'),
    (3, 'Forward (Bamford)', 'Drops to support, one-touch pass into space behind')
) AS v(so, role, job);

-- 70. pp.235-235
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 15: Combination Play Out Wide with the Full Back in a Normal Position', 'Read the cover: overlap or forward in behind',
    'If the opposing FB covers behind his centre back, space opens wide for the overlapping right back via the free AM; if the CB steps to mark the AM, the forward splitting the centre backs runs into the space he left.',
    'Opposing FB covering inside, or CB stepping to the AM',
    'Constant movement unbalances the back line so someone always gets behind.',
    NULL, 235, 235, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'Overlaps into the space the covering FB leaves'),
    (2, 'Attacking midfielder (Rodrigo)', 'Receives from winger, picks overlap or through ball'),
    (3, 'Forward (Bamford)', 'Stays ahead of the far CB between defenders and runs behind'),
    (4, 'Right winger (Raphinha)', 'Passes inside to start it')
) AS v(so, role, job);

-- 71. pp.236-236
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 15: Combination Play Out Wide with the Full Back in a Normal Position', 'Chain run behind the full back',
    'When the opposing central midfielder pushes up to mark the DM, a gap opens between the lines; as the winger turns, the AM runs between CB and FB into the space behind, and the right back pushes on after passing.',
    'Strong-side opposing CM in an advanced position; winger receives and turns',
    'Winger can pass into the AM''s run on the flank or inside to the onrushing FB for a key pass or switch.',
    NULL, 236, 236, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Raphinha)', 'Receives, turns, picks AM run or inside pass'),
    (2, 'Attacking midfielder (Rodrigo)', 'Runs between CB and FB into space behind'),
    (3, 'Right back (Ayling)', 'Runs forward after passing to occupy the inside lane'),
    (4, 'Defensive midfielder (Phillips)', 'Draws the opposing CM forward')
) AS v(so, role, job);

-- 72. pp.237-237
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 15: Combination Play Out Wide with the Full Back in a Normal Position', 'Forward shifts across into vacated centre',
    'If the opposing CM sits deeper and the FB cannot go inside, the AM runs diagonally to the flank taking the centre back with him; the forward slides across into the central hole, rarely followed by the far CB.',
    'CB follows the AM''s diagonal run outward',
    'Forward receives in the key central area for a final pass or switch, though with one fewer player high.',
    NULL, 237, 237, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Rodrigo)', 'Diagonal run to the flank drags the centre back'),
    (2, 'Forward (Bamford)', 'Moves across into the space the CB left'),
    (3, 'Right winger (Raphinha)', 'Finds the forward inside')
) AS v(so, role, job);

-- 73. pp.238-239
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 15: Combination Play Out Wide with the Full Back in a Normal Position', 'Pass-and-move support run',
    'After every pass the passer moves again: forward into space ahead if the receiver can turn, or into space behind/beside if the receiver is under pressure, to give a back pass; from that back pass the FB has time to play the AM in behind the opposing FB.',
    'Receiver pressed and unable to turn',
    'Keep a passing option always open and use the recycled ball to break pressure.',
    NULL, 238, 239, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'Passes then supports inside around the wide midfielder or outside toward the touchline'),
    (2, 'Right winger (Raphinha)', 'Under pressure, lays the ball back to the supporting FB'),
    (3, 'Attacking midfielder (Rodrigo)', 'Runs behind the opposing FB for the through or lofted pass')
) AS v(so, role, job);

-- 74. pp.240-240
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 15: Combination Play Out Wide with the Full Back in a Normal Position', 'AM in the centre switches to weak side',
    'Wide combinations pull defenders across; when an attacking midfielder receives with time in the key central area he looks up and plays a long pass to the weak side, helped by the forward dragging a CB away.',
    'AM receives between the lines with time after wide combination play',
    'Exploit the free space on the weak side, usually the far winger.',
    NULL, 240, 240, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Raphinha)', 'Drives inside and passes to the AM'),
    (2, 'Attacking midfielder (Rodrigo)', 'Receives centrally and switches'),
    (3, 'Forward (Bamford)', 'Run drags a CB to open space'),
    (4, 'Left winger (Harrison)', 'Ends up with most space on the far side')
) AS v(so, role, job);

-- 75. pp.241-241
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 15: Combination Play Out Wide with the Full Back in a Normal Position', 'AM pressed: winger gets ball back',
    'If the AM between the lines is pressed and cannot turn, the winger plays a give-and-go with him, then threads between defenders for the other AM or switches to the far winger; or the AM recycles to the DM who switches.',
    'AM receives under pressure with back to goal',
    'Keep the ball safe and still progress; inverted wingers suit this best.',
    NULL, 241, 241, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Raphinha)', 'Passes in, moves to receive the return, then through ball or switch'),
    (2, 'Attacking midfielder (Rodrigo)', 'Lays off to winger or to the DM'),
    (3, 'Other attacking midfielder (Klich)', 'Runs between FB and CB for the through ball'),
    (4, 'Left winger (Harrison)', 'Free on weak side for the switch'),
    (5, 'Defensive midfielder (Phillips)', 'Receives in space between lines and switches')
) AS v(so, role, job);

-- 76. pp.251-252
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 16: Combination Play Out Wide with the Full Back in a Deep Position', 'AM runs behind FB, deep FB steps in',
    'Winger receives wide with the right back about 15 yards deeper, so no overlap; quick circulation leaves the opposing FB late; the strong-side AM, positioned between CB and FB, runs behind the FB, while the right back advances inside into the space the AM left.',
    'Winger receives with time near the touchline, FB too deep to overlap',
    'Two options for the winger: pass behind the FB to the AM, or inside to the FB between the lines, giving a possible 5v3.',
    NULL, 251, 252, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Raphinha)', 'Drops slightly, receives, turns and chooses'),
    (2, 'Attacking midfielder (Klich)', 'Starts between CB and FB, runs behind the full back'),
    (3, 'Right back (Ayling)', 'Moves forward and inside to receive between the lines'),
    (4, 'Forward (Bamford)', 'Target behind once the ball is in'),
    (5, 'Left winger (Harrison)', 'Far-side target')
) AS v(so, role, job);

-- 77. pp.253-253
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 16: Combination Play Out Wide with the Full Back in a Deep Position', 'Forward drops into space AM vacates',
    'With the FB too deep to help, the AM''s diagonal toward the flank drags the centre back out and the forward drops into the hole between the lines to receive from the winger and turn.',
    'CB follows the AM''s run wide',
    'Forward turns and plays the other AM in behind or lofts to the far winger.',
    NULL, 253, 253, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Klich)', 'Diagonal run toward the flank to drag CB'),
    (2, 'Forward (Bamford)', 'Drops into the vacated space, receives and turns'),
    (3, 'Right winger (Raphinha)', 'Passes inside to the forward'),
    (4, 'Attacking midfielder (Rodrigo)', 'Runs in behind for the through ball')
) AS v(so, role, job);

-- 78. pp.254-254
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 16: Combination Play Out Wide with the Full Back in a Deep Position', 'Weak-side AM slides across between lines',
    'When the forward sits on the far side between FB and CB, the weak-side AM moves across between the two centre backs and then into the space between the lines to receive in the key central area.',
    'Forward on the weak side; strong-side space between lines free',
    'AM receives centrally and gives the final pass to the forward or far winger.',
    NULL, 254, 254, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Rodrigo)', 'Moves across between centre backs, then drops into space'),
    (2, 'Right winger (Raphinha)', 'Passes inside to him'),
    (3, 'Forward (Bamford)', 'Run in behind on the far side'),
    (4, 'Left winger (Harrison)', 'Far-post option')
) AS v(so, role, job);

-- 79. pp.255-256
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 16: Combination Play Out Wide with the Full Back in a Deep Position', 'AM overlaps the winger for 2v1',
    'When the winger has room, the AM is deep and the CB has shifted close to the FB, the AM goes on an overlapping run around the winger rather than a diagonal, creating a 2v1 against the full back.',
    'Winger receives wide with space; CB already near FB',
    'Either AM gets in behind to cross, or the FB''s dilemma frees the winger inside; the far winger and forward one-two are extra options.',
    NULL, 255, 256, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Rodrigo)', 'Overlaps around the winger, receives and crosses'),
    (2, 'Right winger (Raphinha)', 'Drives forward; plays overlap, cuts inside, or switches'),
    (3, 'Forward (Bamford)', 'Offers a one-two inside'),
    (4, 'Left winger (Harrison)', 'Receives a switch after defenders over-shift')
) AS v(so, role, job);

-- 80. pp.257-258
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 16: Combination Play Out Wide with the Full Back in a Deep Position', 'Winger isolates full back 1v1',
    'If the winger has time and his marker has no help, he takes him on: outside then cross; inside then a pass behind for the forward or AM. If the CB drops to block that, the forward gets the ball to feet for a one-two in behind.',
    'Winger with space vs isolated FB, teammates away from ball',
    'Make the most of the winger''s dribbling to create a cross or shot.',
    NULL, 257, 258, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Raphinha)', 'Dribbles at the FB, crosses or passes inside, plays one-two'),
    (2, 'Forward (Bamford)', 'Runs behind the CB or offers feet for one-two'),
    (3, 'Attacking midfielder (Rodrigo)', 'Attacks space between defenders'),
    (4, 'Left winger (Harrison)', 'Arrives back post')
) AS v(so, role, job);

-- 81. pp.259-260
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 16: Combination Play Out Wide with the Full Back in a Deep Position', 'Winger drops to pull marker, run behind',
    'When the winger is tightly marked, he drops short so the opposing FB follows; the player stationed between that FB and the CB (usually the AM, sometimes the forward) attacks the space behind.',
    'Opposing FB follows the dropping winger',
    'Get in behind the full back and cross into a box filled by AMs, with the winger moving up to the edge of the area.',
    NULL, 259, 260, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Raphinha)', 'Drops to draw the full back, then edges toward the box'),
    (2, 'Right back (Ayling)', 'Plays the pass from deep'),
    (3, 'Attacking midfielder (Klich)', 'Nearest player between FB and CB, runs behind and crosses'),
    (4, 'Forward (Bamford)', 'Alternative runner, starting a few yards from the CB'),
    (5, 'Attacking midfielder (Rodrigo)', 'Attacks box spaces for the cross')
) AS v(so, role, job);

-- 82. pp.268-269
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 17: Solutions to Play into the Key Central Area when the Full Back Receives Deep', 'Deep FB finds AM between the lines',
    'With the FB deep and the opposing wide midfielder pressing, the FB plays a diagonal through a lane between wide and central midfielders to the AM; if the centre back holds his zone the AM turns.',
    'CB stays in line; through lane open',
    'AM turns in the key central area and feeds the winger behind the FB, the other AM, the forward, or the far winger.',
    NULL, 268, 269, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'Diagonal pass into the key central area'),
    (2, 'Attacking midfielder (Klich)', 'Positions between lines to receive and turn'),
    (3, 'Right winger (Raphinha)', 'Runs behind the full back'),
    (4, 'Forward (Bamford) / AM (Rodrigo)', 'Options in behind')
) AS v(so, role, job);

-- 83. pp.269-270
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 17: Solutions to Play into the Key Central Area when the Full Back Receives Deep', 'CB jumps to AM: ball behind him',
    'If the centre back leaves the line early to mark the AM, space opens behind him; the FB, if not yet closed, plays an aerial ball into it for the other attacking midfielder.',
    'Opposing CB steps out to mark AM before the pass',
    'Receive in a favourable area to shoot or cross.',
    NULL, 269, 270, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'Lofted pass behind the stepping CB'),
    (2, 'Attacking midfielder (Klich)', 'Draws the CB out'),
    (3, 'Attacking midfielder (Rodrigo)', 'Runs into the vacated space'),
    (4, 'Forward (Bamford)', 'If he is the nearer player between CB and FB, he takes the run instead')
) AS v(so, role, job);

-- 84. pp.270-270
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 17: Solutions to Play into the Key Central Area when the Full Back Receives Deep', 'CB presses after pass: lay-off and loft',
    'When the CB presses the AM as the pass arrives, the AM sets it back to the supporting FB, who lofts it into the space behind the CB and the advanced opposing FB.',
    'CB pressure on AM at the moment of reception',
    'Break the last line and cross from behind.',
    NULL, 270, 270, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'Passes, then supports and plays the lofted ball'),
    (2, 'Attacking midfielder (Klich)', 'Reads the press, lays off'),
    (3, 'Attacking midfielder (Rodrigo)', 'Receives behind and crosses')
) AS v(so, role, job);

-- 85. pp.271-273
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 17: Solutions to Play into the Key Central Area when the Full Back Receives Deep', 'Vertical stretch: AM goes, forward drops',
    'With the opposing FB advanced, the AM runs behind him and the forward (between the CBs) drops into the spot the AM vacated; if the CB follows the AM, the forward receives free; if not, the AM gets the lofted pass. If the other CB follows the forward deep, the far AM runs into the hole for a long pass.',
    'FB on the ball before the wide midfielder closes; opposing FB advanced',
    'Create a free man in the key central area or exploit the gap behind the CBs.',
    NULL, 271, 273, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'Passes between wide midfielder and FB or long behind'),
    (2, 'Attacking midfielder (Klich)', 'Runs behind the advanced opposing FB'),
    (3, 'Forward (Bamford)', 'Drops from between the CBs, receives and turns'),
    (4, 'Attacking midfielder (Rodrigo)', 'Weak-side runner into gap left by the CBs')
) AS v(so, role, job);

-- 86. pp.274-275
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 17: Solutions to Play into the Key Central Area when the Full Back Receives Deep', 'FB drops very deep to open the lines',
    'Strong-side FB drops very low to collect from the CB, escaping the wide midfielder and widening the space between lines; when the wide midfielder steps up and the winger pins the FB high, the AM shifts to the touchline for an overload, the winger cuts in then runs behind, and the forward comes inside.',
    'Wide midfielder steps out to press the deep FB',
    'AM drives forward with two passing options: space behind the FB or the key central area.',
    NULL, 274, 275, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'Drops very deep, receives with time, passes to AM'),
    (2, 'Centre back (Koch)', 'Feeds the deep FB'),
    (3, 'Attacking midfielder (Rodrigo)', 'Shifts wide, overloads the FB zone, carries forward'),
    (4, 'Right winger (Raphinha)', 'Stays high to pin the FB, then runs inside and behind'),
    (5, 'Forward (Bamford)', 'Offers the inside option')
) AS v(so, role, job);

-- 87. pp.286-286
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 18: The Full Back Exploits Space on the Weak Side when Switching Play', 'Weak-side FB starting spot for a switch',
    'When forward play fails and the ball goes back or inside, the far FB sits narrow and slightly deeper than the opposing wide midfielder so he can keep balance, stop that player breaking free in transition, and burst forward when a switch is on.',
    'Ball recycled to a midfielder; switch is possible',
    'Make a numbers advantage on the weak side; best to switch straight to the winger to save passes.',
    NULL, 286, 286, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side full back (Ayling)', 'Narrow, slightly deeper than his opponent; runs inside or outside when switch is on'),
    (2, 'Defensive midfielder', 'Receives the recycle and looks to switch'),
    (3, 'Weak-side winger', 'Preferred final receiver of the switch')
) AS v(so, role, job);

-- 88. pp.287-287
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 18: The Full Back Exploits Space on the Weak Side when Switching Play', 'Inverted FB arrives between the lines',
    'When the strong-side FB passes to the DM centrally, and the weak-side AM is near the strong side with the forward on the weak side, the far FB moves inside into an advanced slot between the lines and receives the DM''s diagonal.',
    'DM receives centrally at an angle for a diagonal pass',
    'FB has two or three key-pass options in behind depending on defenders'' reactions.',
    NULL, 287, 287, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Alioski)', 'Passes to the DM'),
    (2, 'Defensive midfielder (Phillips)', 'Diagonal pass into the area between the lines'),
    (3, 'Weak-side full back (Ayling)', 'Inverts into the gap between the lines'),
    (4, 'Forward (Bamford)', 'Alternative to drop there, but costs a man up front')
) AS v(so, role, job);

-- 89. pp.288-289
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 18: The Full Back Exploits Space on the Weak Side when Switching Play', 'AM drops as link, FB runs into gap',
    'After the opposition shifts fully to the strong side, the weak-side AM drops at speed (from between CB and FB or between the CBs) to link the switch, catching the CM; the weak-side FB runs diagonally into the space between the lines he left.',
    'DM receives after heavy opposition shift; no pass forward on',
    'FB receives in the key central area to play the forward behind or shoot; if the FB is blocked inside, the AM goes long to the winger.',
    NULL, 288, 289, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'Receives from left back and finds the dropping AM'),
    (2, 'Attacking midfielder (Klich)', 'Drops quickly as link player, turns'),
    (3, 'Weak-side full back (Ayling)', 'Diagonal run into vacated space between lines'),
    (4, 'Forward (Bamford)', 'Moves between CBs, target behind'),
    (5, 'Right winger (Raphinha)', 'Long-pass alternative')
) AS v(so, role, job);

-- 90. pp.290-293
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 18: The Full Back Exploits Space on the Weak Side when Switching Play', 'FB sprints for 2v1 after switch',
    'When the through lane is too narrow, a midfielder switches toward the far winger and the far FB sprints past his wide midfielder to create a 2v1 on the opposing FB, choosing overlap if the CB is close, underlap if the CB is far; the AM can serve as a link player for the overlapping FB.',
    'Long switch to the weak-side winger with time',
    'Receive free behind the last line and cross; underlaps give shorter, more dangerous low crosses.',
    NULL, 290, 293, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'Long switch, ideally straight to the winger'),
    (2, 'Right winger (Raphinha)', 'Receives, feeds the FB outside or inside'),
    (3, 'Right back (Ayling)', 'Overlap or underlap, crosses'),
    (4, 'Attacking midfielder (Klich)', 'Between CB and FB as link to the overlap')
) AS v(so, role, job);

-- 91. pp.301-302
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 19: Winning the Second Ball', 'Second ball near the touchline',
    'When forced to go long toward the winger, nearby players sprint to surround the target before the ball lands, creating a local overload, with others covering the inside and deeper zones for longer clearances.',
    'Long pass played toward the winger under pressure',
    'Win any clearance or knock-down and keep the attack alive.',
    NULL, 301, 302, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Phillips)', 'Plays the long ball, then moves up for longer clearances'),
    (2, 'Right winger (Raphinha)', 'Target'),
    (3, 'Attacking midfielder (Klich)', 'Covers the inside clearance'),
    (4, 'Right back (Ayling)', 'Gets tight to the wide midfielder'),
    (5, 'Centre back (Koch)', 'Steps up to the ball area')
) AS v(so, role, job);

-- 92. pp.302-302
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-attacking-tactics-and-sessions'), 'in_possession', 'Tactical Situation 19: Winning the Second Ball', 'Second ball in the centre',
    'When the long ball goes to the forward, the AMs crowd the landing area for short knock-downs, the DM and nearest FB control the zone for longer clearances, and the far FB tucks in on his winger; on winning it both FBs push wide again.',
    'Long ball toward the central forward',
    'Outnumber the opponent around the ball and cover all trajectories of a clearance.',
    NULL, 302, 302, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Bamford)', 'Target'),
    (2, 'Attacking midfielders (Rodrigo, Klich)', 'Close to the ball for short second balls'),
    (3, 'Defensive midfielder (Phillips)', 'Controls space for longer clearances'),
    (4, 'Right back (Ayling)', 'Helps cover longer clearances'),
    (5, 'Left back (Alioski)', 'Moves central to the wide midfielder, then out wide when won')
) AS v(so, role, job);

COMMIT;
