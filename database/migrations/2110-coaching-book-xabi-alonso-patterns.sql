-- 2110 📚 Coaching book patterns: "Xabi Alonso - 82 Passing, Positional Possession, Games, Patterns, and Attacking Practices" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Xabi Alonso - 82 Passing, Positional Possession, Games, Patterns, and Attacking Practices',
    subtitle    = 'Direct from Bayer Leverkusen Training Sessions',
    author      = 'SoccerTutor.com',
    team        = 'Bayer Leverkusen (Xabi Alonso)',
    method_note = 'Practices from Xabi Alonso''s Leverkusen sessions. The tactical philosophy: a 3-4-2-1 whose wing backs at different heights turn it into a 4-2-4 or 3-2-5 / 2-3-5, rotations and position switches to overload, triangles and diamonds around the ball, patient short build-up under pressure, Wirtz in the pockets, counter-pressing and fast counters. Then passing combinations (up-back-through, set back and through ball, link players around a blocked lane), build-up tactics against named shapes, positional possession games, final-third patterns (3-1-5 and 2-5 shapes, second balls, crossing) and set pieces. Patterns are the behaviours the practices rehearse, in our words; warm-ups are left out.'
WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi');

-- 1. pp.18-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'to_defend', 'Key Aspects: High Intensity Counter-pressing / Key Attacking Tactics', 'Aggressive counter-press on ball loss',
    'Players positioned around the ball in possession press immediately when it is lost, backed by an organised defensive line and midfielders who intercept attempted through passes.',
    'Losing possession',
    'Win the ball back quickly and stop the opponent breaking out.',
    NULL, 18, 24, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players near the ball', 'Press the ball carrier at once'),
    (2, 'Double pivot', 'Break up the attack, cut passing lanes'),
    (3, 'Back three', 'Hold a strong high line, intercept through balls')
) AS v(so, role, job);

-- 2. pp.18-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'to_attack', 'Key Aspects: Efficient Attacking Transitions / Counter Attacks', 'Fast coordinated counter after regain',
    'After winning the ball with a compact defence, Leverkusen break quickly with coordinated movements to catch the opponent unorganised.',
    'Regain of possession',
    'Exploit the opponent''s disorganisation for goal chances.',
    NULL, 18, 24, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Release forward quickly'),
    (2, 'Attacking midfielders and forward', 'Run into space in coordinated lanes'),
    (3, 'Wing backs', 'Sprint forward to give width')
) AS v(so, role, job);

-- 3. pp.21-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Tactical Philosophy: 3-4-2-1 Formation / Innovative 3-4-2-1 with Wing Backs', 'Asymmetric wing backs reshape the 3-4-2-1',
    'Base 3-4-2-1 with the two wing backs at different heights; in possession one wing back drops into the back line while the other attacks (4-2-4), or both push up to make 3-2-5 / 2-3-5.',
    'Team settles into possession / build-up phase',
    'Shape imbalance and fluidity confuse the opponent''s marking and create space and overloads up front.',
    NULL, 21, 26, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Grimaldo)', 'More like a full back: can tuck into the back line to make a back four, or rotate inside'),
    (2, 'Right wing back (Frimpong)', 'Plays as a high right winger in the attacking phase'),
    (3, 'Back three (Tapsoba, Tah, Kossounou)', 'Hold rest-defence width; one shifts when a wing back joins'),
    (4, 'Double pivot (Xhaka, Andrich)', 'Stable base in midfield, link defence to attack'),
    (5, 'Two attacking midfielders (Wirtz, Hofmann)', 'Play as inside forwards, freeing the flank lanes for the wing backs')
) AS v(so, role, job);

-- 4. pp.22-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Tactical Philosophy: Structured and Patient Build Up Play / Possession and Midfield Control', 'Patient short build-up even under pressure',
    'Leverkusen develop play from the back with short accurate passes, defenders included, and keep doing so when pressed, waiting for the moment to play an incisive pass forward rather than forcing it.',
    'Goal kick / regain deep / opponent presses high',
    'Move the ball from defence to attacking areas without losing it, control tempo and dominate midfield.',
    NULL, 22, 25, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Play short and accurate, stay calm under pressure'),
    (2, 'Double pivot', 'Offer central support to break the first lines'),
    (3, 'Attacking midfielders', 'Wait in the gaps for the moment the ball can go forward')
) AS v(so, role, job);

-- 5. pp.23-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Relational Play and Positional Play: Switching of Positions / Rotations and Overloads', 'Position switches and rotations to overload',
    'Players are not locked to positions; they swap and rotate around the ball, e.g. the left wing back moves inside into the attacking midfield spot, to build a numerical edge in one area.',
    'Ball in a zone where a rotation can drag a marker',
    'Markers lose their references and the team gains a numerical advantage near the ball to progress.',
    NULL, 23, 25, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Grimaldo)', 'Rotates inside into the attacking midfielder''s zone'),
    (2, 'Attacking midfielder', 'Vacates or swaps outward to keep the structure filled'),
    (3, 'Nearby players', 'Rotate toward the ball side to create the overload')
) AS v(so, role, job);

-- 6. pp.23-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Relational Play and Positional Play: Triangle and Diamond Shapes / Positional Play', 'Triangles and diamonds around the ball',
    'Positional play rules (each player owns a zone, balanced spacing) combined with relational closeness: players keep triangles and diamonds so the man on the ball always has several lanes, and stay close enough for quick one-twos.',
    'Always, in possession',
    'Fast circulation with multiple passing options and the ability to keep the ball under pressure.',
    NULL, 23, 25, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player on the ball', 'Always has at least two angled options'),
    (2, 'Nearest supporters', 'Form triangle/diamond angles, stay close for one-twos'),
    (3, 'Far-side players', 'Hold width and depth to keep spacing')
) AS v(so, role, job);

-- 7. pp.23-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Relational Play and Positional Play: Third Man Runs / Passing Combinations 1-3', 'Drop, set back, third man forward',
    'A player drops to meet the pass and is pressed from behind, so he plays a one-touch wall pass; a central teammate runs around his marker and lays the ball off for the first player moving forward, who then finds the far target. The player not involved in the first pass becomes the third option.',
    'Receiver is pressed from behind and cannot turn',
    'Get the ball forward past pressure using one-touch up-back-through combinations and timed support movement.',
    NULL, 23, 49, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping receiver', 'Moves to meet the ball, plays first time back or into the centre'),
    (2, 'Central link player', 'Moves around his marker and sets the ball for the forward-facing teammate'),
    (3, 'Third man', 'Times his forward movement to arrive onto the lay-off'),
    (4, 'Target at the far end', 'Receives the final forward pass')
) AS v(so, role, job);

-- 8. pp.25-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Tactical Philosophy: Florian Wirtz''s Key Playmaker Role', 'Pocket player receives, turns, slips runners',
    'The attacking midfielder stays in the pockets between the opponent''s midfield and back lines, receives there, turns away from his marker and plays timed through balls for teammates running in behind.',
    'Ball progressed to a midfielder or centre back facing forward',
    'Turn between the lines and create chances with passes in behind.',
    NULL, 25, 25, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Wirtz)', 'Hold position between the lines, receive on the half-turn and turn quickly'),
    (2, 'Centre forward / wing backs', 'Make forward runs in behind on his first touch'),
    (3, 'Midfield passer', 'Find him in the pocket')
) AS v(so, role, job);

-- 9. pp.50-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Passing Combinations 4: Pass and Move with Central Player Support', 'Passer takes over the central link role',
    'After a one-two with the central player and a wide pass, the passer moves into the centre and becomes the new link player while the old central player rotates outward.',
    'Having played the pass',
    'Keep the central support point permanently occupied through pass-and-move rotation.',
    NULL, 50, 50, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Moves inside after passing to become the central support'),
    (2, 'Previous central player', 'Rotates out to a wide receiving spot'),
    (3, 'Wide receivers', 'Use quick side-to-side feet before receiving')
) AS v(so, role, job);

-- 10. pp.51-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Passing Combinations 5, 7-8: Directional First Touch / Check Away with Defensive Pressure', 'Check away, then open up to receive',
    'A player marked from behind first moves away from his spot, then comes to receive and uses a directional first touch away from the presser, or opens his body to play the next pass.',
    'Defender close behind the receiver',
    'Receive under pressure and keep the combination going without being dispossessed.',
    NULL, 51, 54, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving midfielder', 'Checks away, then shows; takes the ball away from pressure with the first touch'),
    (2, 'Passer', 'Plays into the side away from the presser')
) AS v(so, role, job);

-- 11. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Passing Combinations 6: Switch of Play Diamond with Defensive Pressure', 'Switch when the near option is crowded',
    'In a diamond, the player on the ball reads the presser: if the defender is too close to the obvious target, he passes across to the far side instead, where a teammate sets for a third player who turns away from pressure.',
    'Pressing player too tight to the near receiver',
    'Make the right decision to switch the point of attack away from pressure.',
    NULL, 52, 52, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player on the ball', 'Scans the presser''s position before choosing near or far'),
    (2, 'Far-side receiver', 'Sets the ball back for a teammate'),
    (3, 'Drawing player', 'Pulls the presser, then turns to receive from the far side')
) AS v(so, role, job);

-- 12. pp.53-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Passing Combinations 7-8: Two Ball Circuit with Central Link Players', 'Wall pass then curved run in behind',
    'A wide player plays into a central link, who is pressed; the link opens up and plays a correctly weighted pass for the wide player''s curved forward run, or a give-and-go across.',
    'Link player receives with a defender closing',
    'Get a runner in motion past the defender using the central link as a wall.',
    NULL, 53, 54, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player', 'Passes inside then makes a curved run forward'),
    (2, 'Central link player', 'Checks off his marker, opens up, weights the return into the run')
) AS v(so, role, job);

-- 13. pp.55-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Passing Combinations 9-10: End to End Passing Combinations to Break the Lines', 'Short-short-long to break lines',
    'Chains of one-twos, forward passes to a player who drops, and set-backs that let a forward-facing player play a final pass, with supporters joining for one or two passes and then leaving. In the progression players choose their own sequences.',
    'A forward player drops to receive between lines',
    'Break the opponent''s lines through quick support play and finish the move end to end.',
    NULL, 55, 56, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Starting player', 'Plays a one-two, then passes forward'),
    (2, 'Dropping player', 'Comes short and sets the ball for a teammate'),
    (3, 'Supporting players', 'Join briefly, contribute one or two touches and move out'),
    (4, 'Final receiver', 'Gets the last forward pass at the far end')
) AS v(so, role, job);

-- 14. pp.59-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Build Up Play Tactics - 3-4-2-1 Formation with Wing Backs / 3-2-5 Build Up Play Shape', '3-2-5 build-up: wing backs as wingers',
    'From the 3-4-2-1, the back three and two holding midfielders form a 3-2 base while both wing backs push up level with the two attacking midfielders and the striker to make a front five.',
    'Team in possession in own half with a back three',
    'Stretch the opposition across the width, dominate possession and progress through the centre to the attacking midfielders, then attack quickly with overloads.',
    NULL, 59, 60, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing backs (LWB, RWB)', 'Push high and wide like wingers to stretch the back line'),
    (2, 'Centre backs (LCB, CB, RCB)', 'Play out; carry the ball forward to open passing lanes'),
    (3, 'Defensive midfielders (2)', 'Form the second line of the 3-2, link to the AMs'),
    (4, 'Attacking midfielders (2)', 'Sit between the lines as the targets of progression'),
    (5, 'Centre forward', 'Pins centre backs in the front five')
) AS v(so, role, job);

-- 15. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Build Up Play Tactics - Tactical Example of 3-2-5 Build Up Shape vs 2 Forwards', '3-2-5 vs two forwards: 3v2 and staggered pivots',
    'Against a 3-5-2 pressing with two forwards, the back three create a 3v2; one holding midfielder drops deep to help start play while the other pushes behind the forwards to receive between the lines.',
    'Opponent presses with two strikers',
    'Beat the first line with the extra man and link through a bounce pass and a dropping AM to attack with about a 6v5.',
    '3-5-2', 61, 61, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'Use the 3v2 to circulate and find the free man'),
    (2, 'DM1 (deep pivot)', 'Drops near the centre backs to help first phase'),
    (3, 'DM2 (advanced pivot)', 'Pushes behind the first pressing line to receive, set to RCB'),
    (4, 'Ball-side AM', 'Drops as a link player to receive from RCB'),
    (5, 'Wing backs', 'Hold width high')
) AS v(so, role, job);

-- 16. pp.61-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Build Up Play Tactics (notes on pages 61, 62, 65)', 'Early long pass to the free man',
    'During build-up the defenders always check for a clear passing lane to a free player further forward before going short.',
    'Clear lane to a free front player and low risk',
    'Skip the press entirely with one line-breaking long pass from back to front.',
    NULL, 61, 65, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Scan and play the long pass when the lane is open and the risk is small'),
    (2, 'Front players (AM, CF, wing back)', 'Stay available on the last line or between lines for the long ball')
) AS v(so, role, job);

-- 17. pp.62-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Build Up Play Tactics - Tactical Example of 3-2-5 Build Up Shape vs 1 Forward', '3-2-5 vs one forward: pockets for AMs',
    'Against a 4-3-3 the holding midfielders take the ball in tight spaces and play sharp line-breaking passes into the attacking midfielders hidden in the pockets between the lines.',
    'Opponent presses with one striker and a midfield three',
    'Bypass 5-6 opponents, then release the far wing back or striker; wing backs join for a 4v4 in the final third, or the DMs reset and recycle.',
    '4-3-3', 62, 62, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielders', 'Receive under pressure, play incisive passes or reset possession'),
    (2, 'Attacking midfielders', 'Find pockets between midfield and defence lines'),
    (3, 'Wing backs', 'Both join the attack to make a front four or five'),
    (4, 'Centre forward / far wing back', 'Targets once the AM receives')
) AS v(so, role, job);

-- 18. pp.63-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Build Up Play Tactics - 2-3-5 Build Up Play Shape (Variation)', '2-3-5: right centre back steps into midfield',
    'The right centre back pushes up into the midfield line beside the two holding midfielders, leaving a back two and a midfield three behind the unchanged front five.',
    'Opponent shape or pressure that a back three is not needed against',
    'Add a midfield layer to keep the ball more easily under pressure and let the advanced RCB overload midfield and unsettle the opponent''s structure.',
    NULL, 63, 63, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'RCB', 'Steps into midfield as a third central midfielder'),
    (2, 'LCB + CB', 'Form the back two'),
    (3, 'Defensive midfielders', 'Shift across to make the midfield three'),
    (4, 'Front five (wing backs, AMs, CF)', 'Same as 3-2-5, wing backs wide as wingers')
) AS v(so, role, job);

-- 19. pp.64-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Build Up Play Tactics - 4-2-4 Build Up Play Shape', '4-2-4 asymmetric build-up shape',
    'The left wing back drops into a back four, the right centre back slides to right back, and the right wing back goes high as an unbalanced winger while the left AM tucks in to make a front four with the striker and right AM; the double pivot stays.',
    'Building up against pressing where a back four suits better',
    'Give adaptable passing options against different pressing schemes using versatile players. Practice game 11 (p110) rehearses a 4-2 base this way.',
    NULL, 64, 64, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'LWB', 'Drops into the left-back slot of a back four'),
    (2, 'RCB', 'Shifts out to right back'),
    (3, 'RWB', 'Goes high and wide as an advanced winger'),
    (4, 'Left AM', 'Moves inside into the front four'),
    (5, 'Defensive midfielders', 'Stay as the double pivot; one may drop to help')
) AS v(so, role, job);

-- 20. pp.65-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Build Up Play Tactics - Tactical Example of 4-2-4 Build Up Shape vs 2 Forwards; Box Midfield', '4-2-4 vs two forwards: 4v2 plus box midfield',
    'Against a two-man first press, the back four gain a 4v2; the two holding midfielders stand flat side by side and, with the two AMs, form a central ''Box Midfield''.',
    'Opponent presses with two forwards',
    'Win the first phase with a 4v2 then use the box for a 4v3 in central areas to progress through the middle.',
    NULL, 65, 65, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back', 'Receives from the GK and starts play'),
    (2, 'RCB (as right back)', 'Width on the right of the back four'),
    (3, 'Defensive midfielders', 'Horizontal pivot behind the first line, short passes in tight spaces'),
    (4, 'Attacking midfielders', 'Top of the box between the lines')
) AS v(so, role, job);

-- 21. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Build Up Play Tactics - Creating Overload on Right Side of Pitch and then Switching Play', 'Right-side 5v4 then switch to weak side',
    'Building out of the 3-2-5, five players crowd the right side for a 5v4; one DM pushes up while the other stays, and the striker drifts across to stop defenders stepping out.',
    'Opponents shift across to the overloaded side',
    'Drag the block to one side, play through the right into the centre, then switch to the weak side where a 2v1 is waiting.',
    NULL, 66, 66, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'RCB, CB, DMs, right AM', 'Form the 5v4 overload on the right'),
    (2, 'One DM', 'Pushes forward to help break the line, the other stays deep'),
    (3, 'Centre forward', 'Moves across to pin defenders and deny space'),
    (4, 'LWB + left AM', 'Wait on the weak side for the 2v1 after the switch')
) AS v(so, role, job);

-- 22. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Build Up Play Tactics - 4-2-4 Build Up Play Shape from Goal Kicks', 'Goal-kick 4-2-4: overload right, long switch',
    'From goal kicks against a 4-3-3, the LWB stays deep in a back four and the RWB goes high to pin, giving 6+GK v 5 on the right; similar to De Zerbi''s goal-kick build-up.',
    'Goal kick vs a 4-3-3 press',
    'Dictate speed on the right; when the opponent slides over, space opens on the left for a long switch to the LWB.',
    '4-3-3', 67, 67, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'GK + CB + RCB', 'Start the overload on the right side'),
    (2, 'RWB', 'High to pin back the opposition and free room for build-up'),
    (3, 'DMs + right AM', 'Combine around the blocked lane on the right'),
    (4, 'LWB', 'Deep in the back four, then the target of the long switch')
) AS v(so, role, job);

-- 23. pp.69-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Build Up Play Combinations - Build Up and Breaking Midfield Line Circuits 1-5', 'Set-back then through ball behind midfield',
    'A defender plays into a pressed midfielder or AM, who sets it back first time for a player moving onto the ball; that player threads a pass between midfield blockers for a wing back or wide runner arriving behind the midfield line.',
    'Receiver pressed from behind, cannot turn',
    'Use the third-man set to face forward and break the midfield line with a weighted through pass or a switch plus give-and-go.',
    NULL, 69, 73, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Plays into DM/AM and receives the set back'),
    (2, 'DM / AM under pressure', '1-2 touch set back to the man facing play'),
    (3, 'DM facing play', 'Through pass between the midfield line or switch to the far wing back'),
    (4, 'Wing back', 'Timed forward run behind the midfield line')
) AS v(so, role, job);

-- 24. pp.74-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Build Up Play Combinations - Passing Circuit with Pressing Variations (1)(2)', 'Pick the combination from the presser''s angle',
    'The build-up unit reads how the presser comes (blocking the DM, curved run onto CB/DM) and picks the route: CB to AM with the DM moving to receive, or four quick passes to the AM, then LCB to LWB and a give-and-go with the AM.',
    'Shape and angle of the opponent''s press',
    'Play through pressure by choosing the open side rather than a fixed pattern.',
    NULL, 74, 75, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Reads the block; goes to the AM if the DM is shadowed'),
    (2, 'DM', 'Re-positions to get on the ball after being blocked'),
    (3, 'AM', 'Drops to receive and sets for LCB / plays give-and-go'),
    (4, 'LCB + LWB', 'Move onto the set ball and go wide, LWB combines and goes')
) AS v(so, role, job);

-- 25. pp.76-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Build Up Play Combinations - Combinations Through Blocked Lanes Passing Circuit (Variations 1-7)', 'Link player around a blocked lane',
    'In the 3-4-2-1 back three, DM, two AMs and striker, blocked passing lanes are bypassed with a third player as link: the DM or RCB moves the ball to AM1, AM1 to the striker, the striker or AM2 sets back; ''closed inside, open outside'' and the reverse.',
    'Direct lane to AM1, DM or CF blocked by a presser',
    'Always keep a supporting link player so the ball reaches the blocked target in two passes; the striker shifts across to make a forward angle when needed.',
    NULL, 76, 82, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'DM', 'Always supporting; link to AM1 or CF around the blocked lane'),
    (2, 'RCB', 'Plays inside or outside depending on the block; link to AM1'),
    (3, 'AM1 / AM2', 'Link players; decide inside or outside, set for the next runner'),
    (4, 'Centre forward', 'Moves across to create a passing angle, one-two with AM2'),
    (5, 'LCB', 'Sets for the AM''s movement, completes the switch')
) AS v(so, role, job);

-- 26. pp.85-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Possession and Midfield Control - 3-2-5 Possession Phase Shape; Midfield Control (3-2-5)', 'Central 3-2 / 2-3 overload, short passes',
    'Against a 4-2-3-1 the team groups many players centrally in a 3-2 or 2-3 for a 5v4 (and a 7v6 including the AMs), using short passes to draw opponents in while the wing backs stay high and wide.',
    'Possession phase vs a 4-2-3-1',
    'Dense central passing network limits the press; when defenders commit, thread passes through the gaps for a 4v4 against the back line with runs in behind.',
    '4-2-3-1', 85, 87, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three + two DMs', 'Central 5v4 short-passing control, find the free man'),
    (2, 'Attacking midfielders', 'Join for the 7v6, receive through gaps'),
    (3, 'Wing backs', 'Stay high and wide to pin the back line'),
    (4, 'Centre forward', 'Runs in behind for the 4v4 attack')
) AS v(so, role, job);

-- 27. pp.86-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Possession and Midfield Control - The Tempo and Rhythm of Bayer Leverkusen''s Possession Play', 'Slow-slow-fast: overload then accelerate',
    'The team mixes patient build-up with sudden bursts, concentrating players around the ball so the opponent commits defenders into one zone.',
    'Opponent drawn out of shape into the ball zone',
    'Increase tempo at the right moment and exploit the gaps left elsewhere, often by quick passing into the opposite flank, while every player keeps role discipline for security.',
    NULL, 86, 86, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-zone players', 'Overload and keep the ball patiently to attract pressure'),
    (2, 'Far-side players', 'Hold positions ready for the quick switch'),
    (3, 'All players', 'Know their role in build-up, possession and attack')
) AS v(so, role, job);

-- 28. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Possession and Midfield Control - Body Shape and Positioning to Play ''Bounce'' Passes', '''Bounce'' pass: forward, back, forward',
    'Players set their body to face play; a defender passes into the DM, who returns it to a defender, who then plays forward to an attacking player, exploiting space left by defenders following their men.',
    'DM marked tight, cannot turn',
    'Create a new angle to advance and break into a 3v3 on the right after bypassing the midfield line.',
    NULL, 88, 88, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Plays into the DM and receives the return'),
    (2, 'Defensive midfielder', 'One-touch bounce back to a defender'),
    (3, 'RCB / receiving defender', 'Plays forward into the AM or wide area'),
    (4, 'Attacking midfielder + RWB + CF', 'Make the 3v3 in the attacking area')
) AS v(so, role, job);

-- 29. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Possession and Midfield Control - Body Shape and Awareness to Break Midfield Line', 'Half-turn, scan, attract and play through',
    'Midfielders scan before receiving and take the ball on the half-turn with an open body shape; the DM receives and turns while drawing pressers, then breaks the midfield line into an AM between lines.',
    'Pressure arriving on the receiving midfielder',
    'Keep the ball first, then turn forward and play through the opponent''s lines into a 3v2 on the right flank with the RWB running in behind.',
    NULL, 89, 89, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Scans, half-turn receive, turns and breaks the line'),
    (2, 'Attacking midfielder', 'Receives in the pocket with space to turn'),
    (3, 'RWB', 'Always looking to run behind the defence'),
    (4, 'Centre forward', 'Third player for the 3v2')
) AS v(so, role, job);

-- 30. pp.90-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Possession and Midfield Control - Creating Overload on Right Side of Pitch and then Switching Play (4-2-4)', '4-2-4 8v5 right overload, switch to LWB',
    'Against a 4-2-3-1, the 4-2-4 builds an 8v5 on the right, pulling midfielders over; forward lanes then open and the DM plays a long ground pass into the striker''s feet.',
    'Opposing midfield drawn to one side, out of shape',
    'From the striker the ball reaches the left wing back via the AM''s forward run for a 1v1 on the weak side.',
    '4-2-3-1', 90, 90, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right-side unit (CB, RCB, DM, AM, RWB)', 'Keep possession with the 8v5'),
    (2, 'DM', 'Long ground pass into the CF''s feet'),
    (3, 'Centre forward', 'Receives and lays/plays toward the weak side'),
    (4, 'Left AM', 'Forward run to carry the attack'),
    (5, 'LWB', 'Isolated 1v1 on the far side')
) AS v(so, role, job);

-- 31. pp.91-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Possession and Midfield Control - Progression from Possession to Attack', 'AMs as playmakers after passing the three',
    'Against a 4-2-3-1, short central passes pull pressers in; the DMs then find the AMs, who, once past the opponent''s line of three, act as playmakers.',
    'AM receives behind the opposing midfield three',
    'AM drives forward or plays to the wing back''s feet or in behind, a short pass to the striker, or a through ball for the striker''s run.',
    '4-2-3-1', 91, 91, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielders', 'Pass into the AM once gaps open'),
    (2, 'Attacking midfielder', 'Playmaker: dribble, release wing back or striker'),
    (3, 'Wing backs', 'Receive in behind or to feet'),
    (4, 'Centre forward', 'Short option or run in behind for the through pass')
) AS v(so, role, job);

-- 32. pp.94-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'to_defend', 'Positional Possession Games (1, 7 and others)', 'Immediate collective counter-press on loss',
    'In all the possession games, when the ball is lost the team that had it must react at once and press together, closing angles to win it back.',
    'Ball lost (still in play)',
    'Win the ball back as fast as possible before the opponent can settle into possession.',
    NULL, 94, 103, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players to the ball', 'Press immediately and close passing angles'),
    (2, 'Rest of the team', 'Shift together to cut options and win the ball')
) AS v(so, role, job);

-- 33. pp.95-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Possession Games - 2, 9, 10 Build Up in 3-2 / 2-3 Shape; 10.3 Quickly Breaking Lines', 'CBs fix the presser, DM free behind',
    'In the 3-2 (or 2-3) base the centre backs deliberately invite pressure from their direct opponent, often by pausing on the ball, to free a DM behind the first line; a 3v2 around the ball is the aim.',
    'Presser commits to a centre back',
    'DM receives behind the first line and plays forward to the AMs or middle players, then the team quickly progresses to the other end.',
    NULL, 95, 109, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (LCB, CB, RCB)', 'Pause to draw a presser, then play past him'),
    (2, 'Defensive midfielders', 'Position behind the first line of pressure to receive'),
    (3, 'Middle-zone players / AMs', 'Receive from the DM and move play forward')
) AS v(so, role, job);

-- 34. pp.96-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Possession Games - 3 Three Team High Speed; 10.3 Quickly Breaking Lines', 'Tac-tac quick passing and switch side',
    'Positional quick one- and two-touch passing breaks the press on one side and the ball is moved fast to the opposite side, with a central player helping to switch.',
    'Press committed to one side',
    'Play through the press and switch to the other side before the opponent can shift.',
    NULL, 96, 109, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back players', 'Quick passes to break the first press'),
    (2, 'Central player', 'Helps switch play to the opposite side'),
    (3, 'Far-side players', 'Hold positions ready to receive the switch')
) AS v(so, role, job);

-- 35. pp.97-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Possession Games - 4 Support Play in the Centre; 4.1/4.2 Alonso''s Coaching Points', 'Two central players support on diagonals',
    'Two central midfielders always support on diagonal lines, not flat; from the build-up end there is a 3v2 and a 2v1 in the centre, and players keep positions when in possession.',
    'Teammate on the ball needs a passing angle',
    'Create an angle to receive away from the marker, or draw a marker away and play first time to the other free central player.',
    NULL, 97, 99, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (e.g. Aleix Garcia, Florian Wirtz)', 'Move on diagonals to offer support angles'),
    (2, 'Back players', 'Use the 3v2 to find the free central man'),
    (3, 'Free central player', 'Receives first time and plays to the far end')
) AS v(so, role, job);

-- 36. pp.100-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Possession Games - 4.3 Alonso''s Coaching Points for Wide Players', 'Wide players step up and inside',
    'Wide players do not stay stuck in the corners; they move up and inside toward the centre when it helps.',
    'Teammate needs a closer option',
    'Shorten the space, give support to teammates and help progress play to the other side.',
    NULL, 100, 100, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players (e.g. Boniface)', 'Move up and inside to receive'),
    (2, 'Central players', 'Use the shorter link to progress')
) AS v(so, role, job);

-- 37. pp.101-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Possession Games - 5 Open Up and Spread Out; 10.1 Opening Up Wide', 'Wide centre backs open into the corners',
    'The outside centre backs open up in the corners to make the pitch as wide as possible, giving support and space before playing through pressure.',
    'Team regains or starts possession at the back',
    'Draw in pressers, move the ball to DMs behind the first line, then middle players, and quickly switch to the other side.',
    NULL, 101, 107, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'LCB + RCB', 'Spread wide into the corners to receive'),
    (2, 'Central CB', 'Base of the build-up'),
    (3, 'Defensive midfielders', 'Receive behind the first line once the press commits')
) AS v(so, role, job);

-- 38. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Possession Games - 10.2 Alonso''s Coaching Points for Decision Making', 'Closed down? Play out; otherwise reset',
    'In the 3-2 build-up, the wide centre backs receive in open wide positions to attract an opponent; it is positional possession, not keep-ball, so shape is held.',
    'Opponent steps up to press the centre back',
    'If he is pressed, the defender plays out past the presser; if not, recycle possession and start again.',
    NULL, 108, 108, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'LCB / RCB', 'Receive wide, attract a presser, decide play out or recycle'),
    (2, 'DMs', 'Hold structured positions behind the first line'),
    (3, 'All players', 'Keep positional discipline')
) AS v(so, role, job);

-- 39. pp.113-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Attacking Through the Centre', 'Line-breaking pass or bounce, attack between lines',
    'In the 3-2-5 the double pivot stands in front of the back three as safe outlets; the team either splits the lines straight through the middle or plays short bounce passes to pull opponents out first. Once the ball reaches an attacking midfielder between the lines, the attack speeds up.',
    'Lane through the centre open, or lanes closed so a bounce pass is needed to pull someone out',
    'Get an attacking midfielder turned between the lines, then slip the wing back in behind for a cut back to the centre forward.',
    NULL, 113, 113, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielders (double pivot)', 'Stand in front of the defenders to receive; bounce back when lanes are shut'),
    (2, 'Centre backs', 'Drive forward if there is space; play the line-breaking pass after drawing the press'),
    (3, 'Attacking midfielder', 'Receives between the lines, carries forward, slips the wing back in'),
    (4, 'Right wing back', 'Plays as a winger, runs in behind and cuts back'),
    (5, 'Centre forward', 'Attacks the cut back')
) AS v(so, role, job);

-- 40. pp.114-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Tactical and Positional Fluidity in Attack: Left Wing Back Grimaldo', 'Late wing back as free outside man',
    'The left wing back starts deeper than the right one and only moves into the attacking half later in the move. There he often receives unmarked on the outside from an attacking midfielder. Just the threat of him keeps defenders wide and frees space in the middle.',
    'Attacking midfielder has the ball inside with the wing back free outside',
    'Wing back carries forward and either crosses or shoots.',
    NULL, 114, 115, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Grimaldo)', 'Arrive late on the outside as the free player; cross or shoot'),
    (2, 'Left attacking midfielder', 'Draw defenders inside, release the wing back'),
    (3, 'Right wing back (Frimpong)', 'Stays higher on the far side')
) AS v(so, role, job);

-- 41. pp.116-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Moving into Attacking Midfield "Playmaker" Position', 'Wing back inverts, swaps with attacking midfielder',
    'The left wing back comes inside into a midfield or number 10 role while the attacking midfielder swaps out wide. This gives an extra man in the centre to control the tempo, and the swap pulls markers out of position.',
    'Team settled in possession in the attacking phase',
    'Gain central superiority and open gaps for a quick combination or a long-range shot by the inverted wing back.',
    NULL, 116, 116, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Grimaldo)', 'Move inside to the AM spot, move the ball quickly, shoot from distance'),
    (2, 'Left attacking midfielder', 'Rotate outside to hold the width the wing back left'),
    (3, 'Defensive midfielders', 'Feed the inverted wing back')
) AS v(so, role, job);

-- 42. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Right Wing Back Frimpong Used as a "High Flying Winger"', 'Go wide for winger 1v1 when centre blocked',
    'When the central lanes are closed, the ball goes out early to the right wing back, who stays high and wide like a winger. He takes on his full back 1v1 with pace and dribbling.',
    'Central passing lanes blocked',
    'Beat the full back and cross or cut back, with the far wing back attacking the back post.',
    NULL, 117, 117, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Frimpong)', 'Stay high and wide, take on the defender 1v1, cross or cut back'),
    (2, 'Defensive midfielder / attacking midfielder', 'Switch the ball out to him quickly'),
    (3, 'Left wing back', 'Attack the back post'),
    (4, 'Centre forward', 'Attack the near and centre spaces')
) AS v(so, role, job);

-- 43. pp.118-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Bayer Leverkusen''s Overloading Final Zone of Pitch to Finish Attacks', 'Front five overload, 5v5 or 5v4',
    'Both wide players hold the touchline and pin the opposing full backs. That widens the back line and leaves gaps for central players to run forward, so the attack ends as a front five against four or five defenders. The team would rather dribble, cut back or play through passes than cross from wide.',
    'Ball reaches the final third with a centre back and DM pushed up behind',
    'Make a 5v4 or 5v5 in the last zone so the player on the ball has several finishing passes, usually the centre forward''s run.',
    NULL, 118, 118, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Both wing backs', 'Pin the full backs wide'),
    (2, 'Left wing back (in AM spot)', 'Receive the DM''s bounce pass, thread the centre forward''s run'),
    (3, 'Right centre back / DM', 'Push into advanced positions to play through the centre'),
    (4, 'Centre forward', 'Run in behind the centre backs'),
    (5, 'Attacking midfielders', 'Fill the inside channels as extra finishing options')
) AS v(so, role, job);

-- 44. pp.123-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Attacking Positional Patterns of Play (3-1-5 setup)', 'Play out, switch to half-space AM, slip wing back',
    'The ball is played back to the middle centre back to draw the press. A 4v2 at the back frees a centre back to drive forward, who switches to the far attacking midfielder standing high in the half space. Variants have the far centre back running out with the ball, or a double switch across all three centre backs.',
    'First pressers commit to the ball side and leave the far centre back free',
    'Attacking midfielder plays a through pass for the wing back''s inside run behind the full back, followed by a cross or cut back into a full box.',
    NULL, 123, 126, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back', 'Draw the press, then pass to the free side'),
    (2, 'Wide centre back', 'Carry the ball forward, switch to the far AM'),
    (3, 'Attacking midfielder (half space)', 'Receive high and play the through pass in behind'),
    (4, 'Wing back', 'Inside run behind the full back to the by-line; cross or cut back'),
    (5, 'Centre forward + other AM + far wing back', 'Fill near post, centre and back post')
) AS v(so, role, job);

-- 45. pp.125-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Attacking Positional Patterns of Play (3-1-5 setup)', 'Through ball, cut back to the passer',
    'A pressed DM bounces the ball back to the centre back and the 4v2 lets play go out to the far side. The attacking midfielder turns and sends the wing back to the by-line, then keeps running into the box.',
    'Defensive midfielder pressed from behind',
    'Wing back cuts back for the late run of the attacking midfielder who released him.',
    NULL, 125, 125, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Bounce back to the centre back when pressed'),
    (2, 'Left centre back', 'Drive and switch to the far AM'),
    (3, 'Right attacking midfielder', 'Turn, pass to the wing back, keep running into the box'),
    (4, 'Right wing back', 'High run to the by-line, cut back'),
    (5, 'Centre forward, left AM, left wing back', 'Support runs into the box')
) AS v(so, role, job);

-- 46. pp.127-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Attacking Positional Patterns of Play (3-1-5 setup)', 'Forward comes short, AM third-man run',
    'A pressed centre back breaks the first line with a short pass into the DM. Play goes through the right centre back to the right wing back, and the centre forward moves across to show for a pass to feet.',
    'Ball travelling to the centre forward''s feet',
    'Near-side attacking midfielder runs in behind as the third man, takes the forward''s first-time pass and cuts back for the other AM.',
    NULL, 127, 127, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back', 'Break the first pressing line with a short pass to the DM'),
    (2, 'Right wing back', 'Play into the centre forward''s feet'),
    (3, 'Centre forward', 'Come across and short, set first time in behind'),
    (4, 'Right attacking midfielder', 'Third-man run behind the line, cut back'),
    (5, 'Left attacking midfielder', 'Time the forward run to finish')
) AS v(so, role, job);

-- 47. pp.128-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Attacking Positional Patterns of Play (3-1-5 setup)', 'AM drops wide, wing back goes inside',
    'After a short build-up through the centre, the right attacking midfielder drops back and wide to take the ball off the centre back. The right wing back swaps inside into the half space.',
    'Attacking midfielder dropping pulls his marker out',
    'Wing back receives high in the half space, dribbles into the box and passes across for the far attacking midfielder.',
    NULL, 128, 128, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right attacking midfielder', 'Drop back and wide to receive, play forward'),
    (2, 'Right wing back', 'Move inside to the half space, dribble into the box'),
    (3, 'Left attacking midfielder', 'Finish in the centre'),
    (4, 'Centre forward, left wing back', 'Support runs')
) AS v(so, role, job);

-- 48. pp.129-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Attacking Positional Patterns of Play (3-1-5 setup)', 'Long aerial switch, AM third-man run behind',
    'Once the ball has been worked to one side, a centre back or the DM hits a long aerial ball to the far wing back, who has run forward to receive beyond the full back. The near attacking midfielder has already slid across to that side.',
    'Opponent shifted to the ball side, far wing back free',
    'Wing back plays the AM in behind the full back for a cut back to the centre forward, or crosses to the far wing back at the back post.',
    NULL, 129, 130, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back / defensive midfielder', 'Play the long aerial switch'),
    (2, 'Far wing back', 'Run forward to receive beyond the full back, release the AM or cross'),
    (3, 'Attacking midfielder on that side', 'Shift across early, third-man run in behind'),
    (4, 'Centre forward', 'Finish the cut back'),
    (5, 'Opposite wing back', 'Attack the back post')
) AS v(so, role, job);

-- 49. pp.132-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Patterns Training Setup with 2-5 Shape (from 3-2-5)', 'Switch to wing back, DM runs beyond',
    'A defensive midfielder in the half space hits a long aerial switch to the far wing back. As he does, the other defensive midfielder runs forward from deep.',
    'Switch lands with the wing back',
    'Wing back plays a give-and-go with the forward-running DM to get in behind, then cuts back for the centre forward.',
    NULL, 132, 132, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right defensive midfielder', 'Play the long aerial switch'),
    (2, 'Left wing back', 'Give-and-go with the DM, cut back from behind'),
    (3, 'Left defensive midfielder', 'Forward support run to give the wall pass'),
    (4, 'Centre forward', 'Finish'),
    (5, 'Both attacking midfielders', 'Run into the box')
) AS v(so, role, job);

-- 50. pp.133-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Patterns Training Setup with 2-5 Shape (from 3-2-5)', 'Diagonal into AM, give-and-go with dropping nine',
    'A defensive midfielder plays diagonally to the far attacking midfielder, who has dropped to receive in the half space. The centre forward drops off his centre back to offer a wall pass.',
    'AM receives in the half space and the striker drops',
    'Centre forward plays the AM through in behind for a first-time finish in the box.',
    NULL, 133, 133, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Diagonal pass into the far half space'),
    (2, 'Attacking midfielder', 'Drop to receive, give-and-go, time the run in behind'),
    (3, 'Centre forward', 'Drop and play the return through pass')
) AS v(so, role, job);

-- 51. pp.134-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Patterns Training Setup with 2-5 Shape (from 3-2-5)', 'Drop-offs pull the line, shot from distance',
    'The centre forward and attacking midfielders drop off the back line to receive and pull defenders with them. The ball is laid back or across into the space in front of the box.',
    'Forward receives with his back to goal or drops off the line',
    'Shoot from outside the box, either by the forward carrying it into a shooting angle or by a DM arriving late as the deep third man, while the others run into the box for rebounds.',
    NULL, 134, 135, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Drop to receive; lay off or carry the ball into a shooting angle'),
    (2, 'Attacking midfielder', 'Drop back, pass back across for the arriving DM'),
    (3, 'Right defensive midfielder', 'Pass forward and follow, deep third-man run, shoot between the defenders'),
    (4, 'Other attackers', 'Run into the box for rebounds')
) AS v(so, role, job);

-- 52. pp.136-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Patterns Training Setup with 2-5 Shape (from 3-2-5)', 'DM''s deep ground through ball for nine',
    'A defensive midfielder checks away from his marker and then comes forward at an angle to receive. Meanwhile the centre forward and near attacking midfielder move away from the defenders, ready to spin.',
    'DM receives facing forward with the forward''s run timed',
    'Long ground through pass behind the line for the centre forward to go one-on-one with the keeper.',
    NULL, 136, 136, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left defensive midfielder', 'Check off, come onto the ball, play the deep through pass'),
    (2, 'Centre forward', 'Check away, then spin in behind and finish'),
    (3, 'Left attacking midfielder', 'Check away and threaten a run to hold a defender')
) AS v(so, role, job);

-- 53. pp.139-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Attacking Positional Patterns of Play + 2nd Ball Finishing', 'Wide combination, cut back to timed AM',
    'A centre back finds the attacking midfielder dropping between the midfield line, who sets the DM. Alternatively the centre back plays a one-two with his wing back and then hits a long aerial switch. The ball reaches the far wing back, who combines with the centre forward (a through pass for the forward''s curved run, or a give-and-go in behind).',
    'Ball switched to the far wing back',
    'Cut back or low cross for the attacking midfielder, who holds his run (''wait, wait, go'') to arrive on time at the near post or penalty spot.',
    NULL, 139, 142, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back', 'Receive in the half space, one-two with the wing back, switch long'),
    (2, 'Attacking midfielder', 'Drop to set the DM, then hold and time the late run into the box'),
    (3, 'Defensive midfielder', 'Complete the switch to the far wing back'),
    (4, 'Left wing back', 'Combine with the forward, cut back or cross low'),
    (5, 'Centre forward', 'Curved run in behind or wall pass, then cut back'),
    (6, 'Right wing back', 'Run into the box')
) AS v(so, role, job);

-- 54. pp.139-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Attacking Positional Patterns of Play + 2nd Ball Finishing', 'Attack the second ball, shoot from distance',
    'Straight after the first chance is finished, a second ball arrives around the edge of the box. A player who has pushed up behind the attack (centre back, centre forward or wing back) drops in to collect it.',
    'First chance over, loose or new ball outside the box',
    'Carry it a touch forward and shoot from outside the box at once, so the attack keeps going.',
    NULL, 139, 142, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advancing centre back', 'Push up behind the attack, take a touch, shoot from range'),
    (2, 'Centre forward', 'Come back off the box to receive and shoot'),
    (3, 'Right wing back', 'Drop back to collect, drive toward the box, shoot')
) AS v(so, role, job);

-- 55. pp.144-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Attacking and Finishing', 'Crossing with near/centre/back-post runs',
    'A long cross-field ball lands with the wide player in a target zone, or the wide player gets free with a one-two or a return pass. He then delivers a ground or aerial cross, in-swinging or out-swinging. Runners split up so each covers a different area of the box.',
    'Wide player controls the ball in the crossing zone',
    'Box covered at the near post, the six-yard line and a curved back-post run, so every type of cross has a target.',
    NULL, 144, 145, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player / wing back', 'Time the run to control in the zone; vary the cross type'),
    (2, 'Near-post runner', 'Attack the near post'),
    (3, 'Central runner', 'Attack the six-yard line'),
    (4, 'Back-post runner', 'Curved run to the back post')
) AS v(so, role, job);

-- 56. pp.146-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Attacking and Finishing', 'Flank give-and-go, low cross 3v3',
    'Play goes from the centre back to the wide centre back and on to the wing back. The wing back plays a give-and-go with the attacking midfielder to get in behind on the flank. Three attackers attack the box against three markers.',
    'Wing back receives with the AM close by',
    'Low cross for one of three runs (near post, centre, far post). If the defenders win it, they counter straight away and the attackers must react.',
    NULL, 146, 146, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back', 'Move the ball out to the wing back'),
    (2, 'Left wing back', 'Give-and-go with the AM, low cross'),
    (3, 'Attacking midfielder', 'Wall pass, then run into the box'),
    (4, 'Three box runners', 'Near post, centre, far post against markers')
) AS v(so, role, job);

-- 57. pp.146-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'to_attack', 'Positional Training Games', 'Second-ball counter after regain',
    'In the zonal games, once an attack ends, the defending side gets a fresh ball and attacks the other goal straight away.',
    'Possession won or new ball to the defending side',
    'Counter at speed before the opponent recovers its shape.',
    NULL, 146, 153, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who receives the second ball', 'Attack forward at once'),
    (2, 'Nearest attackers', 'Make forward runs to create a quick 3v3 or overload')
) AS v(so, role, job);

-- 58. pp.149-149
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'to_attack', 'Positional Training Games', 'Win it and shoot early',
    'In tight, fast small-sided games, a team that wins the ball looks for a quick early shot instead of building again.',
    'Ball won',
    'Hit the opponent before it is organised.',
    NULL, 149, 149, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who regains', 'Shoot or pass forward at once'),
    (2, 'Nearest teammates', 'Break forward to support the early shot')
) AS v(so, role, job);

-- 59. pp.149-149
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'to_defend', 'Positional Training Games', 'Immediate reaction to win it back',
    'When the ball is lost in a high-tempo game, the team that lost it does not drop off. It reacts straight away.',
    'Ball lost',
    'Win the ball back as quickly as possible before the opponent can get a shot away.',
    NULL, 149, 149, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost it', 'Press the new ball carrier at once'),
    (2, 'Nearest teammates', 'Close the passing options around the ball')
) AS v(so, role, job);

-- 60. pp.150-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Training Games', 'Switch sides to beat a compact middle block',
    'The keeper and back line build up against a compact central block that presses the middle zone. The ball goes from one side to the other to stretch the block, using the space underneath it.',
    'Block shifts to the ball side (''other side'' cue)',
    'Get around the press and progress toward goal; the pressing team tries to win the ball and finish quickly on small goals.',
    NULL, 150, 150, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Join the build-up as an extra man'),
    (2, 'Centre backs', 'Circulate quickly across the back line'),
    (3, 'Far-side players', 'Stay wide to receive the switch'),
    (4, 'Midfielders', 'Show underneath the block')
) AS v(so, role, job);

-- 61. pp.151-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Training Games', '4-2-4 build-up, then centre back and DM step up',
    'Using the 4-2-4 build-up shape, the back unit plays through the first press, getting the ball into the DM, or in the 5v2 version bypassing the midfield line, often by the DM passing wide for the wing back''s forward run. Then a centre back and the DM or wing back move up into the attacking zone.',
    'DM or wing back receives past the first line',
    'Turn a 4v4 into a 4v4+2 or 5v5 attack in the final zone.',
    NULL, 151, 153, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs + goalkeeper', 'Build through the first press'),
    (2, 'Defensive midfielder', 'Receive in the central zone; pass wide for the wing back or join the attack'),
    (3, 'Right centre back', 'Step into the attacking zone as an extra player'),
    (4, 'Right wing back', 'Start deep, then run forward into the attack'),
    (5, 'Front four', 'Hold positions to receive the extra men')
) AS v(so, role, job);

-- 62. pp.152-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Training Games', 'Switch to weak side, run in behind',
    'In the 3-4-2-1 with 4-2-4 build-up, the team breaks the pressing lines by quick combinations, through passes or a switch. Alonso especially praised switching to the weak side. An offside line means runs must be timed to get in behind.',
    'Press shifted to the ball side, far side open',
    'Switch play to the weak side and finish from in behind before reaching the end zone.',
    NULL, 152, 152, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs / DMs', 'Switch play to the weak side'),
    (2, 'Weak-side wing back / AM', 'Receive and attack in behind'),
    (3, 'Centre forward', 'Time runs to stay onside')
) AS v(so, role, job);

-- 63. pp.154-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'in_possession', 'Positional Training Games', 'Build-up adapting to the number of pressers',
    'The keeper starts short build-up while the press changes from none to one and then two pressers in the build-up zone. Alonso adjusts the team from the 4-2-4 to a 4-2-3 and changes the size of the build-up zone.',
    'Change in how many opponents press the build-up zone',
    'Break the pressing lines and create chances against whatever press appears, with players getting back into position after each pass.',
    NULL, 154, 155, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Short distribution to start'),
    (2, 'Back four', 'Spread the 4-2-4 to beat the press'),
    (3, 'Defensive midfielders', 'Adjust position to the number of pressers, link play'),
    (4, 'Attackers', 'Get back into their positions after each phase')
) AS v(so, role, job);

-- 64. pp.157-160
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'set_piece', 'Attacking Set Plays', 'Out-swinger: near, centre, back-post runs',
    'For out-swinging corners and wide free kicks (by the by-line, level with the penalty spot, or level with the edge of the box), the taker raises one arm to signal an out-swinger into a target area. Three or four runners start around the edge of the box with a rotating spare.',
    'Taker raises one arm',
    'Staggered runs so the delivery has a target at each post and in the middle.',
    NULL, 157, 160, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Taker', 'Raise an arm, deliver an out-swinger into the target area'),
    (2, 'Player A', 'Run first to the near post'),
    (3, 'Player B', 'Follow, attack the centre of the box'),
    (4, 'Player C (and D)', 'Run to the back post'),
    (5, 'Rotational player', 'Stay around the edge of the box')
) AS v(so, role, job);

-- 65. pp.161-161
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'set_piece', 'Attacking Set Plays', 'In-swinging free kick with back-post cover',
    'Wide free kicks are delivered as in-swingers into a target area, with five runners waiting at the edge of the box.',
    'In-swinging delivery',
    'Runners split across the box, with one held back to collect deliveries that go long.',
    NULL, 161, 161, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Taker', 'In-swinging ball into the target area'),
    (2, 'Player A', 'Near post'),
    (3, 'Player B', 'Centre'),
    (4, 'Players C and D', 'Back post'),
    (5, 'Player E', 'Cover the back post for overhit balls')
) AS v(so, role, job);

-- 66. pp.162-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'xabi-alonso-82-passing-positional-possession-games-patterns-and-attacking-practi'), 'set_piece', 'Attacking Set Plays', 'Throw-in: turn under pressure and cross',
    'From a wide throw-in in the attacking third, the receiver is marked tightly. He turns his marker and crosses into a target area.',
    'Throw received under close marking',
    'Fill the box with staggered runs and keep someone at the edge for second balls.',
    NULL, 162, 162, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Thrower', 'Throw to the receiver'),
    (2, 'Receiver', 'Turn the marker, cross into the target area'),
    (3, 'Players A / B', 'Near post / centre'),
    (4, 'Players C and D', 'Back post'),
    (5, 'Player E', 'Cover the back post for overhit crosses'),
    (6, 'Player F', 'Hold the edge of the box')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('2110-coaching-book-xabi-alonso-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
