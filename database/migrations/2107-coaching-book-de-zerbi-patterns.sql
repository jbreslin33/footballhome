-- 2107 📚 Coaching book patterns: "Roberto De Zerbi - 92 Build Up, Passing Combinations and Attacking Positional Practices" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Roberto De Zerbi - 92 Build Up, Passing Combinations and Attacking Positional Practices',
    subtitle    = 'Direct from De Zerbi''s Training Sessions',
    author      = 'SoccerTutor.com',
    team        = 'Brighton, Shakhtar Donetsk, Sassuolo, Benevento (De Zerbi)',
    season      = '2017-2023',
    method_note = 'Ninety-two practices taken from De Zerbi''s sessions at Brighton, Shakhtar, Sassuolo and Benevento, each with its session source. Rondos and passing circuits (wall pass and rotate, set back for the third man, open up on the half-turn, rhombus timing), a philosophy chapter (bait the press, avoid long balls, the 2-4-4 double box and 6v4 central overload, switching to a 2-3-5, high press), positional possession games and build-up set-ups against a compact block (switch to the winger with the full-back overlap, the forward''s lay-off and set-and-spin, box occupation on the cut-back, throw-in build-ups, after winning the ball go back to the keeper and rebuild). Patterns are the behaviours the practices rehearse, in our words.'
WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract');

-- 1. pp.13-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'out_of_possession', 'Rondos', 'Press in pairs to close angles',
    'Small-area rondos (5v2 up to 8v2+1) where the two defenders work as a unit against short one-touch passing.',
    'Ball played between outside players',
    'Win the ball quickly by one presser attacking the ball while the partner screens the next passing lane.',
    NULL, 13, 17, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First presser', 'Press the ball carrier, angle run to cut one side'),
    (2, 'Second presser', 'Cover and close the inside/next passing line'),
    (3, 'Pair', 'Win it inside ten passes or swap with the players who lost it')
) AS v(so, role, job);

-- 2. pp.13-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Rondos', 'One-touch circulation with central floater',
    'Outside players keep the ball against a pressing pair, using one touch, with a central floating player offering an angle through the middle.',
    'Pressing pair closes the outside lanes',
    'Keep possession by moving the ball faster than the press and using the central link to split it.',
    NULL, 13, 17, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside players', 'Play 1 (max 2) touches, keep the shape wide'),
    (2, 'Central floater', 'Find space between the two pressers and offer a split option'),
    (3, 'Receiver next to ball', 'Adjust position to give a clean angle')
) AS v(so, role, job);

-- 3. pp.20-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Passing Combinations', 'Wall pass, move on and rotate',
    'Short 3-4 player combinations: one-two, forward pass, then the passer follows to support and players take each other''s positions.',
    'Ball played forward into a teammate',
    'Progress the ball with quick combinations and keep a support option every time by rotating into the vacated spot.',
    NULL, 20, 21, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Play the one-two then run forward to the next support spot'),
    (2, 'Wall player', 'Return first time and take the passer''s position'),
    (3, 'Far player', 'Check off and time the forward movement to receive')
) AS v(so, role, job);

-- 4. pp.22-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Passing Combinations', 'Open up to receive on half-turn',
    'Every receiver checks away from a marker/pole, then opens the body and receives at an angle (inside or outside of the marker) so the first touch goes forward or across.',
    'Teammate is about to pass',
    'Receive already facing the next pass and play at speed with control + pass, instead of receiving square and back to play.',
    NULL, 22, 38, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'Check away, then open up and take the ball on the half-turn off the marker'),
    (2, 'Receiver', 'Choose inside or outside receiving side from the marker''s position'),
    (3, 'Passer', 'Firm, accurate pass to the open (far) foot'),
    (4, 'Receiver on ''bounce'' call', 'Set back first time instead of turning when told the turn is closed')
) AS v(so, role, job);

-- 5. pp.25-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Passing Combinations', 'Set back for the third man (give & go)',
    'A player receives a forward pass and lays it back first time for an oncoming teammate who arrives facing forward; often the layer then spins round for a return in behind.',
    'Forward pass into a checked-off receiver',
    'Get the ball to a player facing the play who can break the next line or find the runner.',
    NULL, 25, 41, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target / middle player', 'Check away, receive and set the ball back first time'),
    (2, 'Oncoming third man', 'Time the run to meet the lay-off facing forward'),
    (3, 'Layer after the set', 'Spin or move round the marker for the return (give & go)')
) AS v(so, role, job);

-- 6. pp.42-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Passing Combinations', 'Positional rhombus build-up timing',
    'Build-up circuit in real positions (LB, CB, RB, DM, LCM, RCM, F): CB and full back exchange a double pass, DM drops off his cone, full back steps out and back, midfielders and forward set and go.',
    'Centre back receives from the full back',
    'Players learn where and when to move in the build-up so a passing angle is always on and the ball travels from back to front through the DM and interiors.',
    NULL, 42, 45, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Play into DM or out to full back, then offer return'),
    (2, 'Defensive midfielder', 'Drop off the marker to give an angle and receive turned'),
    (3, 'Full back', 'Step forward with the ball then back to re-offer, timed with the DM'),
    (4, 'Interior midfielders / forward', 'Check away, receive, lay off for the oncoming midfielder')
) AS v(so, role, job);

-- 7. pp.46-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Passing Combinations', 'Break lines through a central box',
    'One-touch combinations between four central players arranged in a box, with one-twos and give & goes to play through the middle.',
    'Ball enters the central box',
    'Break opposition lines centrally with one-touch play and support on the far side of the marker.',
    NULL, 46, 46, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep pair', 'Play into the front of the box and follow to support'),
    (2, 'Advanced pair', 'Check before receiving, play one-two or set back'),
    (3, 'Runner', 'Receive on the other side of the marker after a give & go')
) AS v(so, role, job);

-- 8. pp.48-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Key Game Principles for Build-up Play from the Back', 'Bait the Press (draw opponents forward)',
    'The team deliberately invites pressure by keeping players deep, with the goalkeeper acting as a third centre back, and draws opponents in with short passes.',
    'Opponents start to step up and press the build-up',
    'Pull the opposition forward to open space higher up for the attacking players.',
    NULL, 48, 48, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Join the back line as third centre back'),
    (2, 'Centre backs', 'Stop the ball under the sole to hide the direction and invite the press'),
    (3, 'Build-up players', 'Keep short passing until the press commits')
) AS v(so, role, job);

-- 9. pp.48-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Key Game Principles for Build-up Play from the Back', 'Avoid long balls, wait for link pass',
    'The team limits long passes to avoid aerial duels and waits for the right forward pass into a link player who can wall-pass to a teammate in space facing goal.',
    'Link player free between the lines',
    'Keep control of the ball and only go forward when a player can receive facing the opposition goal.',
    NULL, 48, 48, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders and DMs', 'Keep possession, no hopeful long balls'),
    (2, 'Link player (AM/F)', 'Show for the forward pass and wall-pass first time'),
    (3, 'Free teammate', 'Receive the wall pass facing forward')
) AS v(so, role, job);

-- 10. pp.48-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Tactical Shape for Build-up Play from Back in Open Play', '2-4-4 build-up, double box',
    'Brighton 4-2-3-1 builds up in a 2-4-4: two centre backs, full backs wide in line with a double pivot, and four attackers high pinning the back four; CBs and DMs plus AM and F form a double box giving a 6v4 central overload.',
    'Build-up from the back in open play',
    'Hold the opponent''s back four deep and use the central overload to play through to the AM or forward in free space.',
    NULL, 48, 50, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Sole on ball to draw opponents, keep every passing direction open'),
    (2, 'Full backs', 'Wide, level with the two DMs'),
    (3, 'Double pivot (DMs)', 'Stay deep to control the build-up'),
    (4, 'Wingers', 'Push high and wide to pin the full backs/back line'),
    (5, 'AM and forward', 'Drift into free space once the press commits')
) AS v(so, role, job);

-- 11. pp.51-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Tactical Shape for Build-up Play from Back in Open Play', 'Square pass bait, third man to free DM',
    'A square pass between centre backs baits the front line to press; the DMs stay hidden in the shadow of the forwards, and the ball goes via a link player (AM/F) who bounces it to the now-free DM.',
    'Opponent front line jumps on a square pass',
    'Free a midfielder behind the first line of pressure, then play through to the forward with 6-7 opponents taken out of the game.',
    NULL, 51, 51, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Play the square bait pass, then the vertical pass to the link player'),
    (2, 'Defensive midfielders', 'Stay in the forwards'' shadow, do not show to the CB, wait for the bounce'),
    (3, 'Attacking midfielder (link)', 'Drop and set the ball first time to the free DM'),
    (4, 'Forward', 'Receive the DM''s pass breaking the midfield line')
) AS v(so, role, job);

-- 12. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Tactical Shape for Build-up Play from Back in Open Play', 'Switch to 2-3-5 build-up',
    'At Shakhtar (4-2-3-1), depending on the number of opposition pressers, one full back steps into the midfield line beside the DMs while the other joins the front five as a winger; the AM and that side''s winger tuck inside.',
    'Game situation / number of opponents in the first two pressing lines',
    'Keep a 6v4 central overload while recognising the middle is crowded, so the aim becomes playing out towards the wide areas.',
    NULL, 52, 52, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back', 'Move into the midfield line with the two DMs'),
    (2, 'Right back', 'Push up into the winger lane as part of the front five'),
    (3, 'Right winger and AM', 'Occupy central spaces between the lines'),
    (4, 'Centre backs', 'Build from the back, look for the route to the wide areas')
) AS v(so, role, job);

-- 13. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Build-up Play and Attacking Philosophy - 2b Square passes between CBs (bait to press)', 'Square CB passes bait press, go wide',
    'In a 2-3 build-up the opponent squeezes the middle with a narrow, numbers-up block (around 5-6 players high in an irregular hexagon). The CBs keep the ball between them with short sideways passes until the front line jumps.',
    'Opposition front runners step forward onto the square pass',
    'Ball moves away from the crowded centre to a wide winger, cutting out about six opponents and leaving a 5v4 attack.',
    NULL, 53, 53, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Short square passes to draw the front line forward, then play wide'),
    (2, 'Left winger', 'Hold width in space to receive the switch away from the press'),
    (3, 'Attacking midfielder and forward', 'Run forward to form the 5v4 overload')
) AS v(so, role, job);

-- 14. pp.54-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Build-up Play and Attacking Philosophy - 3a Build-up shape with 4-3-3 (Sassuolo)', 'Single pivot 4-3-3 build-up, 6v4 centre',
    'Sassuolo play out with five or six including the GK while the two wingers and the forward stay high to pin the opposing back four. With one DM, the two central midfielders hunt free pockets behind the opponent''s midfield line.',
    'Opponents commit players forward to press',
    'Create a 6v4 overload in central midfield and play through it.',
    NULL, 54, 54, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Stand on the ball to invite pressure, keep every passing direction open'),
    (2, 'Defensive midfielder', 'Single pivot, link CBs to the central midfielders'),
    (3, 'Central midfielders (LCM, RCM)', 'Find free space behind the opposition midfield line'),
    (4, 'Wingers and forward', 'Stay high to pin the four defenders')
) AS v(so, role, job);

-- 15. pp.55-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Build-up Play and Attacking Philosophy - 3b Adjusting to 2-3-2-3 with inverted full backs', 'Inverted full backs, bait then wide',
    'From a 4-3-3 the full backs step inside to join the DM in a second line of three, leaving the two CBs as the first line. The team lures the press deep into its own half with short square passes, then the CB plays wide to a winger who drops; when the opposing full back follows him, the near central midfielder receives in the space left behind.',
    'Two front opponents pressed onto the CB pass; opposing full back follows the dropping winger',
    'Turn behind the defensive line with a 4v3 or 5v4 overload.',
    NULL, 55, 55, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (LB, RB)', 'Tuck in beside the DM to form the second line'),
    (2, 'Centre back', 'Bait with square/short passes, then pass wide to the winger'),
    (3, 'Left winger', 'Drop to receive and lay off, pulling the opposing RB out'),
    (4, 'Left central midfielder', 'Receive in the vacated space, turn and play behind')
) AS v(so, role, job);

-- 16. pp.56-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Brighton Build-up Play from Goal Kicks - 1a Build-up shape (4-2-4)', 'Brighton goal kick 4-2-4 shape',
    'From goal kicks Brighton use seven including the GK to play out, full backs deep and narrow, two DMs behind the opposing front two, and four attackers high to pin the back four. This gives a 4(+GK)v2 against the first line of pressure.',
    'Goal kick',
    'Beat the first line with numbers, then AM and forward make a 4v2 in the centre once the ball moves up; opposing CBs cannot step out because the wingers would run in behind.',
    NULL, 56, 56, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'GK and centre backs', 'Wide split, form the back unit with the full backs'),
    (2, 'Full backs', 'Deep and narrow, part of the 4+GK first line'),
    (3, 'Defensive midfielders', 'Sit behind the two opposing forwards'),
    (4, 'Attacking midfielder and forward', 'Ready to create a 4v2 in the centre'),
    (5, 'Wingers', 'High and wide to pin defenders and threaten in behind')
) AS v(so, role, job);

-- 17. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Brighton Build-up Play from Goal Kicks - 1b Third man link player + central overload', 'DM link player bounce to free DM',
    'GK plays short to a CB to draw the two opposing forwards. One DM is screened by a red attacker pressing from behind, so the other DM drops slightly to open a passing angle; the CB plays diagonally to him and he bounces it forward to the free DM.',
    'Opponent forwards press the CB; one DM marked',
    'Break the first line and create a 4v2 in the centre (2 DMs, AM, F vs 2 central midfielders) because the opposing CBs stay back.',
    NULL, 57, 57, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'GK', 'Short pass to a CB to bait the press'),
    (2, 'Ball-side centre back', 'Diagonal pass into the dropping DM'),
    (3, 'Dropping DM', 'Create the angle and play a one-touch link pass'),
    (4, 'Free DM', 'Receive facing play and attack the second line')
) AS v(so, role, job);

-- 18. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Brighton Build-up Play from Goal Kicks - 2 When opposing CBs push forward', 'Punish CBs stepping up to mark',
    'If the opposing CBs step out to mark the AM and forward to stop the central overload, they leave space behind. GK-CB-GK-CB circulation, the CB breaks the midfield line with a pass into the AM, who under pressure plays across to the forward, who lays off to a DM; the DM sends the right back running forward.',
    'Opposition CBs jump forward to mark AM/F',
    'Exploit the hole behind their back line for a 4v2 or 5v2 finish.',
    NULL, 58, 58, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Through pass into AM when the midfield line can be broken'),
    (2, 'Attacking midfielder', 'Pass across to the forward when pressed from behind'),
    (3, 'Forward', 'Lay off to the DM'),
    (4, 'Defensive midfielder', 'Release the right back into the space'),
    (5, 'Right back', 'Run forward onto the pass into the open space')
) AS v(so, role, job);

-- 19. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Brighton Build-up Play from Goal Kicks - 3 Invite press on one side and switch', 'Invite press one side, long switch',
    'Brighton draw the whole opposition across to one side: CB is closed down, the first and second lines shift over, so he plays back to the GK, who hits a long aerial ball to the far full back running forward. The far winger runs inside to clear space for him to dribble.',
    'Opponents shift collectively towards the ball side and close the CB',
    'Attack the empty far side with a potential 5v4 as AM, F and RW run forward.',
    NULL, 59, 59, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back', 'Draw the press, return the ball to the GK'),
    (2, 'GK', 'Long aerial pass to the far full back'),
    (3, 'Left back', 'Run forward to receive and drive quickly'),
    (4, 'Left winger', 'Run inside to open the lane for the full back'),
    (5, 'AM, forward, right winger', 'Push on for the overload finish')
) AS v(so, role, job);

-- 20. pp.60-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Brighton Build-up Play from Goal Kicks - 4 Third man link player, lay-off and through pass', 'AM bounce to DM, through for forward',
    'The two DMs stay behind the opposing forwards and wait to receive via a link player rather than straight from the CBs. A CB finds the AM between the lines, the AM bounces it back to the free DM, who plays a through pass for the forward''s curved run into the space left by the opposing CB who tracked the AM.',
    'Opponents commit and the CB has a lane to the AM',
    '3v3 or 4v3 behind the midfield line with the forward running in behind.',
    NULL, 60, 63, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Circulate, then pass into the AM'),
    (2, 'Attacking midfielder', 'Third man link: one-touch bounce to DM, then run forward'),
    (3, 'Defensive midfielders', 'Hold position behind the forwards; free one meets the bounce'),
    (4, 'Forward', 'Curved run into space vacated by the tracking CB'),
    (5, 'GK', 'Acts as an extra CB')
) AS v(so, role, job);

-- 21. pp.61-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Tactics and Game Principles - 1 and 2a Keep possession + break lines at right moment (play out from back)', 'Bait, keep ball, break lines on cue',
    'Players play short, bait the press and circulate quickly, open up at angles to receive, while the double pivot controls tempo. After drawing the first line, the aim is a free player facing forward: play forward whenever it is not too risky, use link players for first-time bounces when the target is marked.',
    'Opposition first line drawn forward',
    'Free player facing goal; wingers attack at speed and CMs exploit the centre as the back line retreats, with many runners into the box.',
    NULL, 61, 64, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'GK', 'Acts as third CB'),
    (2, 'Centre backs', 'Receive deep and bait the press confidently'),
    (3, 'Midfielders', 'Dictate tempo, open up at angles to support'),
    (4, 'Link players', 'Bounce first time to the free man'),
    (5, 'Wingers', 'Stay high and wide, attack at speed when receiving'),
    (6, 'Full backs', 'Provide width and support')
) AS v(so, role, job);

-- 22. pp.65-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Tactics and Game Principles - 2b Keep possession + break lines (attacking half)', 'Patient possession, incisive between-line passes',
    'In the opponent''s half the central midfielders and CBs keep the ball with short passes, waiting for the moment to break lines. They pull defenders out of position, then play forward between the lines or use bounce passes from a marked link player.',
    'A defender is drawn out, opening a lane between the lines',
    'Disrupt the defensive structure and create chances, with wingers high and many runners into the box.',
    NULL, 65, 65, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Key players: set tempo, open up at angles'),
    (2, 'Centre backs', 'Join short circulation'),
    (3, 'Forward (link player)', 'Bounce first time even if marked'),
    (4, 'Wingers', 'Stay high and wide, attack at speed'),
    (5, 'Midfield runners', 'Run into the box for crosses or through balls')
) AS v(so, role, job);

-- 23. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Tactics and Game Principles - 3 Wide play (control, switching, overloads on flank)', 'Full width, switch when blocked, overlap',
    'The team uses the whole width and keeps short possession when no vertical pass is on. If progress is blocked on one flank, the CB and the DM reset and recycle the ball across to the far side, where the winger receives in space and the full back overlaps.',
    'Progression blocked on one flank',
    '2v1 on the far flank and a cross, mostly a cut-back.',
    NULL, 66, 66, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Reset and recycle the ball to the far side'),
    (2, 'Defensive midfielder', 'Offer an angle and keep the ball moving for the switch'),
    (3, 'Far winger', 'Wide, receive in space'),
    (4, 'Far full back', 'Overlap to make the 2v1 and cross'),
    (5, 'Box runners', 'Attack cut-back areas')
) AS v(so, role, job);

-- 24. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Tactics and Game Principles - 4 Quick and incisive attacking play', 'Optimal attacking zone, third man bounce',
    'In the final third players receive between the lines, use third-man runs to get bounce passes and play quick through balls behind, with timed runs. The team prefers its optimal attacking zone (edge of box / half-spaces) rather than going too deep into the corner or to the byline to cross.',
    'Ball received between the lines',
    'Penetrate with through passes into space behind the back line before the defence can track runners.',
    NULL, 67, 67, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player between the lines (AM/F)', 'Receive and set the bounce'),
    (2, 'Third man runner', 'Arrive on the bounce pass free in space'),
    (3, 'Wingers', 'Time runs in behind the defensive line'),
    (4, 'Passer', 'Quick incisive pass in behind')
) AS v(so, role, job);

-- 25. pp.69-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Positional Roles in Build-up and Attacking Philosophy - 1 and 2', 'Positional roles from GK to box',
    'Patient build-up from the GK with ball-playing CBs who stop, carry and break lines with forward passes; full backs give width then push on. A structured midfield circulates and links defence to attack, wingers high and wide stretch the line, the forward holds up and links.',
    'Possession from the goalkeeper',
    'Progress smoothly through the middle and create flank overloads (full back overlap 2v1) to create and score.',
    NULL, 69, 70, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Bait press, carry, stop the ball, pass forward to break lines'),
    (2, 'Full backs', 'Width in build-up, overlap high to make 2v1'),
    (3, 'Midfielders (DM pair, AM)', 'Circulate and link defence to attack'),
    (4, 'Wingers', 'High and wide in the front three, cross or cut inside'),
    (5, 'Forward', 'Hold up, link midfield and wingers, run behind, attack box')
) AS v(so, role, job);

-- 26. pp.71-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'out_of_possession', 'High Pressing and Regaining Possession Tactics', 'Collective high press to regain',
    'Even as a possession team, De Zerbi''s sides press high as a unit to stop the opponent playing out, committing many players around the ball.',
    'Opponent building up from the back',
    'Force mistakes and win the ball in advanced areas, then attack quickly before their defence is organised.',
    NULL, 71, 71, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front line', 'Press the build-up high'),
    (2, 'Midfielders', 'Push up and crowd the ball area'),
    (3, 'Whole team', 'Work collectively, commit numbers forward')
) AS v(so, role, job);

-- 27. pp.74-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Positional Possession Games 1-6', 'Keep ball in roles with supports',
    'Small positional possession games (3v3+4 up to 7v7+2) where inside players represent real positions (CB, DM, CM, full backs, wingers) and outside supports play for the team in possession. Players keep their positional roles while moving to support, using quick combinations, two-touch and firm passes, and must read the picture before receiving.',
    'Team has the ball under collective pressure',
    'Retain possession and move the ball end to end through the pressers via support angles.',
    NULL, 74, 79, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside midfielders (DM, CM)', 'Constant support movements, combine quickly'),
    (2, 'Centre backs', 'Start and recycle play'),
    (3, 'Full backs / wingers on sides', 'Provide width and support angles, stay in role'),
    (4, 'Defending team', 'Press together to close passing angles')
) AS v(so, role, job);

-- 28. pp.79-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'to_attack', 'Positional Possession Games - 6 7v7 (+2) build-up game with GK end players', 'On regain, reset via GK',
    'In the 7v7 build-up game, a team that wins the ball does not rush forward but plays back to its own GK to restart a structured build-up.',
    'Ball won from the opponent',
    'Restore build-up shape and play out again through the opposition.',
    NULL, 79, 79, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins the ball', 'Play back to own GK'),
    (2, 'GK', 'Restart build-up to a defender'),
    (3, 'Back four, DMs, AM', 'Drop into build-up positions'),
    (4, 'Jokers', 'Become winger and forward for the team with the ball')
) AS v(so, role, job);

-- 29. pp.82-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Positional Build-up Play - 1 and 2 Centre backs build-up through the centre (5+GK v1)', 'CBs carry into second zone, find DM',
    'GK to RCB, who carries forward into the second central zone; when the forward pass is blocked he plays across to the LCB who has also stepped up. The DM shifts across to receive (back to goal) and lays off or passes on to the oncoming CB.',
    'Forward pass blocked by the presser',
    'Break the line through the DM and finish with a through pass into the gap between opposing full back and centre back (diagonal or vertical).',
    NULL, 82, 83, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Carry forward into the second zone, switch across when blocked'),
    (2, 'Defensive midfielder', 'Shift to the ball side, receive and lay off to the oncoming CB'),
    (3, 'Full backs', 'Supporting movements, provide width'),
    (4, 'CB on the ball at the end', 'Through pass into the FB-CB channel')
) AS v(so, role, job);

-- 30. pp.84-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'out_of_possession', 'Positional Build-up Play - 3a Pressing movements + reset positioning (5+GK v2)', 'Press shifts relative to the ball',
    'When the opponent has the ball on one side, all players make pressing movements relative to the ball''s position while teammates shift across to cover passing options. When the ball goes back to their GK, they drop straight into build-up positions.',
    'Opponent carries the ball to one side',
    'Block passing options while pressing, then reset quickly into the build-up shape when the ball goes back to the keeper.',
    NULL, 84, 84, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front players', 'Press towards the ball side'),
    (2, 'Midfield/back players', 'Shift across relative to ball position'),
    (3, 'Centre backs', 'On reset drop deep either side of the GK'),
    (4, 'Full backs', 'On reset go wide just outside the area')
) AS v(so, role, job);

-- 31. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Positional Build-up Play - 3b(1) Bait the press vs forward pressing high (5+GK v2)', 'Vs high forward: bounce and carry',
    'GK to LCB, who passes into the DM marked from behind; the DM drops, receives and plays back to the RCB. RCB passes to LCB, who is pressed by the forward but moves forward into the second zone and finds the LB, who moves up and plays a diagonal back across to the oncoming RCB.',
    'Opposing forward presses the CB high',
    'Drag the forward to one side, then let the far CB dribble freely up to halfway.',
    NULL, 85, 85, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back', 'Receive under pressure, carry into second zone'),
    (2, 'Defensive midfielder', 'Drop when marked from behind, bounce to RCB'),
    (3, 'Left back', 'Move forward to receive, pass diagonally across'),
    (4, 'Right centre back', 'Arrive free and dribble to halfway')
) AS v(so, role, job);

-- 32. pp.86-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Positional Build-up Play - 3b(2) Find the right moment vs forward dropping off (5+GK v2)', 'Vs dropping forward: CBs dribble in',
    'When the opposing forward drops deeper instead of pressing, the free RCB dribbles into the second central zone until closed down, then passes across; the LCB also dribbles in and finds the LB, who returns a diagonal to the oncoming RCB.',
    'Forward drops off, CB has no opponent near',
    'Use the uncontested CB carry to gain ground and push the team up, switching sides when closed.',
    NULL, 86, 86, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back', 'Dribble into space until pressed, then pass across'),
    (2, 'Left centre back', 'Also carry forward, pass to the LB'),
    (3, 'Left back', 'Make forward movements, pass back diagonally'),
    (4, 'Other players', 'Push the team forward within the formation')
) AS v(so, role, job);

-- 33. pp.87-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Positional Build-up Play - 4 De Zerbi''s coached patterns through first and second lines (8+GK v6)', 'Marked-from-behind player sets to oncoming',
    'Through the first and second lines, any player marked from behind (RCM, DM, forward) sets the ball back to a free teammate arriving from deeper. If the DM is unmarked, the CB drives forward with the ball; at stoppages De Zerbi asks the CBs to push up and the RB to tuck inside.',
    'Receiver has an opponent on his back',
    'Keep breaking pressure line by line until the forward lays off for an oncoming midfielder; variation: the DM dribbles on and plays the through pass himself.',
    NULL, 87, 87, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Drive forward if DM unmarked; push up'),
    (2, 'Right central midfielder', 'Marked from behind: set back for the DM'),
    (3, 'Defensive midfielder', 'Pass into the forward or dribble and play through'),
    (4, 'Forward', 'Back to goal, set for the oncoming LCM'),
    (5, 'Right back', 'Tuck inside')
) AS v(so, role, job);

-- 34. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Positional Build-up Play - 5 Lay-off for DM''s third man run (8+GK v6)', 'Forward lay-off for DM third-man run',
    'RCB under pressure finds the marked DM, who returns it to the LCB in space; LCB carries and passes to the LCM, who turns away from his marker and hits the forward. The forward, back to goal, sets for the DM making a deep run beyond the midfield line.',
    'LCM turns free and forward is available with back to goal',
    'DM breaks the midfield line in possession and releases the forward on a curved run in behind.',
    NULL, 88, 88, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back', 'Forward touch under pressure, then pass to DM'),
    (2, 'Left centre back', 'Carry forward into space'),
    (3, 'Left central midfielder', 'Turn away from the marker, play into F'),
    (4, 'Forward', 'Lay off to DM, then curved run behind'),
    (5, 'Defensive midfielder', 'Third man deep run, carry and pass in behind')
) AS v(so, role, job);

-- 35. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Positional Build-up Play - 6 Right side build-up with CM''s third man run in behind (8+GK v6)', 'CM third-man run behind on right',
    'RCB advances with the ball because nobody presses him, plays to the RB, who passes inside to the DM who has shifted across. The DM plays through the midfield line to the forward, who has also shifted to the right side.',
    'RCB not pressed; DM shifted to ball side',
    'RCM runs beyond the line as third man and gets a wall pass from the forward in behind the defence.',
    NULL, 89, 89, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back', 'Advance with the ball when not pressed'),
    (2, 'Right back', 'Pass inside to DM'),
    (3, 'Defensive midfielder', 'Shift right, pass through the midfield line'),
    (4, 'Forward', 'Shift right, wall pass for the runner'),
    (5, 'Right central midfielder', 'Third man run beyond the line')
) AS v(so, role, job);

-- 36. pp.90-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Positional Build-up Play - 7 Patience to break lines with double switch and quick support (8+GK v6)', 'Patient double switch via GK',
    'GK-LCB-LB, and when the LB is pressed the ball goes back to the GK and out to the RCB on the other side. The RCM drops to receive and plays quick one-twos, first with the DM, then with the LCM, to get past pressing opponents.',
    'Full back pressed on the first side',
    'Switch the point of attack patiently, then break lines with quick support play and a final pass for the forward''s run to the right.',
    NULL, 90, 90, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'GK', 'Recycle and switch to the far CB'),
    (2, 'Left back', 'Return the ball to the GK when pressed'),
    (3, 'Right central midfielder', 'Drop to receive, play two quick one-twos'),
    (4, 'Defensive midfielder and LCM', 'Give quick return passes, LCM moves forward'),
    (5, 'Forward', 'Run towards the right side for the final ball')
) AS v(so, role, job);

-- 37. pp.91-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Positional Build-up Play - 8 One-two to break midfield line, play into forward''s path (8+GK v6)', 'DM-RCM give-and-go breaks midfield',
    'Ball circulates CB to CB to LB to a dropping DM and back across to the RCB. RCB finds the RCM inside under pressure while the DM shifts all the way across to support.',
    'RCM receives pressured with DM arriving beside him',
    'RCM and DM play a give-and-go to break the midfield line, then RCM passes into the forward''s run.',
    NULL, 91, 91, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Switch the ball across the back'),
    (2, 'Left back', 'Pass inside to DM'),
    (3, 'Defensive midfielder', 'Drop for support, then big shift across to give the return pass'),
    (4, 'Right central midfielder', 'Move inside, play one-two and go'),
    (5, 'Forward', 'Movement to receive the final pass')
) AS v(so, role, job);

-- 38. pp.92-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'set_piece', 'Positional Build-up Play - 9 and 10 Build-up from throw-in with CB exploiting space (8+GK v6)', 'Throw-in build-up, far CB drives',
    'Full back throws to the DM, marked from behind, who returns to the thrower; the full back carries backwards and plays inside to the far CB. The near CB has dropped away to drag the opposing forward with him, so the far CB has a big central space to drive into.',
    'Throw-in in own half',
    'CB dribbles forward through the centre; the far CM moves high and wide taking his marker, the forward shifts across and plays the CM in on a third man run (right-side version ends with the full back''s overlap).',
    NULL, 92, 93, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Thrower (full back)', 'Throw to DM, take it back, carry back and pass inside'),
    (2, 'Defensive midfielder', 'Return pass under marking, later link'),
    (3, 'Near centre back', 'Drop away to drag the forward and free the lane'),
    (4, 'Far centre back', 'Drive forward into the open central space'),
    (5, 'Far central midfielder', 'Move high and wide to pull his marker, then third man run'),
    (6, 'Forward', 'Shift away from marker and play the runner')
) AS v(so, role, job);

-- 39. pp.94-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Positional Build-up Play - 11 5v3 build-up in centre to finish in small goals', 'CB-DM-CB triangle passing pattern',
    'With two CBs and three CMs against three pressers, the team repeatedly uses a CB to DM to CB triangle, choosing it depending on whether the DM is marked or has space. A CB then takes a forward touch and finds a CM who is pressed and passes across for the oncoming CB.',
    'DM free or marked decides the route',
    'Break the midfield line with a pass to a CM who dribbles into the finish zone.',
    NULL, 94, 94, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Run the triangle, carry forward until closed'),
    (2, 'Defensive midfielder', 'Pivot of the triangle, bounce between CBs'),
    (3, 'Central midfielders (LCM, RCM)', 'Receive under pressure, pass across or turn and dribble through')
) AS v(so, role, job);

-- 40. pp.95-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Positional Build-up Play - 12 Possession, switching play and wing play 10v6 (+4)', 'Consolidate, double switch before attacking',
    'In a 4-3-3 vs a 4-3-3 shape, the coaches stress keeping the ball and switching rather than launching an attack the moment one appears. The ball travels winger to winger with a double switch before going forward with intent.',
    'Possession gained in build-up even if attack is on',
    'Once the end zone is entered with intent, quick combinations against the four retreating defenders to score.',
    '4-3-3', 95, 95, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs and DM', 'Circulate and consolidate'),
    (2, 'Wingers', 'Hold width in their zones, receive switches'),
    (3, 'Central midfielders', 'Link the switch, then combine quickly'),
    (4, 'Front players', 'Attack the end zone with quick combinations')
) AS v(so, role, job);

-- 41. pp.96-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Positional Build-up Play - 13 and 14 Positional build-up to break lines and finish (10v6, 10v9)', 'Lay-off then everyone joins attack',
    'The back four, DMs and AM build up against a pressing unit while wingers and forward wait high. The ball goes into the forward, who lays off for an oncoming AM or DM; the AM may drop into the first zone to give a 7v4.',
    'Ball reaches the forward / second zone',
    'All except the CBs push forward to finish quickly against defenders tracking back, e.g. full back deep run or winger low cross.',
    NULL, 96, 97, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder', 'Drop to overload build-up, then attack the lay-off and finish'),
    (2, 'Forward', 'Receive and lay off to oncoming midfielder'),
    (3, 'Defensive midfielder', 'Receive the lay-off and play the runner'),
    (4, 'Right back', 'Deep forward run to receive'),
    (5, 'Winger', 'Dribble on and deliver low cross'),
    (6, 'Centre backs', 'Stay back')
) AS v(so, role, job);

-- 42. pp.101-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Positional Patterns of Play - De Zerbi''s 2-3-2-3 attacking phase formation', '2-3-2-3 attacking phase roles',
    'Sassuolo''s 4-3-3 becomes a 2-3-2-3 in attack: two CBs for stability, full backs forming the second line with the DM (but leaving for forward runs and crosses), two CMs in the third line between the lines, two wingers and a forward up top.',
    'Settled attacking possession',
    'Keep ball circulation through the centre while the CMs link to the front three and wingers stretch the line.',
    NULL, 101, 101, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'First line, defensive stability'),
    (2, 'Full backs', 'Second line with the DM, then forward runs for width and crosses'),
    (3, 'Defensive midfielder', 'Deep in the second line, circulation'),
    (4, 'Central midfielders', 'Receive between the lines, link to attackers'),
    (5, 'Wingers', 'Width, cross or cut inside'),
    (6, 'Forward', 'Hold up, link, score')
) AS v(so, role, job);

-- 43. pp.104-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Patterns of Play Training Set-up 1 - 1 Switch to winger and full back''s underlapping run', 'Switch to winger, full back underlaps',
    'RB is pressed and passes to RCM, who plays back to the DM; the DM, under pressure, turns left and passes diagonally to the LCM, who finds the advanced LW. The LB makes a long, deep run inside of the opposing full back (underlap) to receive in behind.',
    'Pressure on the right side',
    'LB crosses low across the box for the far winger arriving off the flank, with both CMs and the forward filling other box zones.',
    NULL, 104, 104, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back and RCM', 'Draw pressure on the right'),
    (2, 'Defensive midfielder', 'Turn away from pressure and switch diagonally'),
    (3, 'Left central midfielder', 'Pass out wide to the winger'),
    (4, 'Left winger', 'Receive high and slip the LB in'),
    (5, 'Left back', 'Underlapping run in behind, low cross'),
    (6, 'Right winger, CMs, forward', 'Timed box runs, far winger finishes')
) AS v(so, role, job);

-- 44. pp.105-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Positional Patterns of Play - Set-ups 1, 2 and 4', 'Switch to winger, full back overlaps for cut-back',
    'The team builds on one side with the full back, the central midfielders and the holding midfielder until the press arrives, then moves the ball to the far winger, either through the midfield line or with an aerial switch from the holding midfielder. Opponent is a compact 4-5 block (4-4-2 in Set-up 4).',
    'Strong side closed by pressure on the ball carrier or a blocked forward lane',
    'Winger attacks the opposite full back inside, which frees the outside lane for the overlapping full back to get to the byline and cut back.',
    NULL, 105, 137, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back / winger / central mid', 'Circulate and draw the block, then give it back to the holding midfielder'),
    (2, 'Holding midfielder (DM)', 'Move forward with the ball and switch diagonally or in the air to the far winger'),
    (3, 'Weak-side winger', 'Stay high and wide, receive, drive inside at the full back'),
    (4, 'Weak-side full back', 'Time a deep overlapping run outside the winger and cut the ball back from near the byline'),
    (5, 'Forward', 'Near-post run to meet the cut-back')
) AS v(so, role, job);

-- 45. pp.105-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Positional Patterns of Play - all set-ups', 'Box occupation on the cut-back',
    'Every final pass in these patterns is matched by fixed arrival runs. The forward attacks the near post or runs across goal, and both central midfielders and the opposite winger go into different areas of the box. The holding midfielder waits at the edge of the area.',
    'Ball reaches the byline or the runner in behind',
    'There is always more than one finishing option, plus cover for the second ball at the top of the box.',
    NULL, 105, 147, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Near-post or across-goal run, timed to the delivery'),
    (2, 'Central midfielders', 'One late run to the penalty spot, one into another area'),
    (3, 'Opposite winger', 'Attack the far post'),
    (4, 'Holding midfielder', 'Hold the edge of the box for cut-backs and second balls')
) AS v(so, role, job);

-- 46. pp.106-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Positional Patterns of Play - Set-ups 1, 2 and 4', 'Switch then central midfielder''s penetrating run',
    'Same switch to the far winger, but the run in behind comes from the far-side central midfielder, who breaks beyond the full back into the box, not from the full back.',
    'Winger receives the switch and drives inside, drawing the full back',
    'The midfielder arrives unmarked in the box behind the defensive line to finish or square the ball across goal.',
    NULL, 106, 132, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side winger', 'Drive inside at the full back, then slip the ball in behind'),
    (2, 'Weak-side central midfielder', 'Penetrating or curved run beyond the full back into the box'),
    (3, 'Other central midfielder', 'Late run to the penalty spot for the cut-back'),
    (4, 'Forward', 'Run across the goal to finish the square ball')
) AS v(so, role, job);

-- 47. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Positional Patterns of Play - Set-up 1 (3-2-3)', 'Central midfielder drops when two lanes are shut',
    'The full back on the ball is pressed and both his forward options are blocked, so he plays back to the holding midfielder. The nearest central midfielder then drops beside the holding midfielder to restart.',
    'Presser blocks the forward pass and a second lane is also closed',
    'A new angle lets the midfielder move inside with the ball and switch across the front of the block to the far full back.',
    NULL, 107, 107, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressed full back', 'Do not force it, play back to the holding midfielder'),
    (2, 'Holding midfielder', 'Shift across to give the outlet, then find the dropping midfielder'),
    (3, 'Ball-side central midfielder', 'Drop to receive, carry inside, play the switch'),
    (4, 'Far full back / winger', 'Receive beyond the block. Winger drives in and slips the midfielder through')
) AS v(so, role, job);

-- 48. pp.108-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Positional Patterns of Play - Set-ups 1-3; Combinations and Finishing', 'Forward''s lay-off, midfielder''s through ball to winger',
    'With the midfielder closely marked or a lane blocked, the forward drops or slides across into the open lane between the lines. He sets the ball back to an onrushing central midfielder, who passes in behind for the winger''s run off the flank. Works on the strong or weak side.',
    'Direct lane to the forward opens while the closest midfielder is marked',
    'Break the midfield and defensive lines with a third-man combination. The winger runs diagonally between full back and centre back into the box.',
    NULL, 108, 146, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder', 'Bounce with a midfielder to shift the block, then play the vertical pass into the forward'),
    (2, 'Forward', 'Come short or across into the free lane, set first time to the oncoming midfielder'),
    (3, 'Receiving central midfielder', 'Arrive facing play, thread a diagonal through ball between full back and centre back'),
    (4, 'Winger', 'Hold width, then cut inside on a curved run in behind. Finish or cut back'),
    (5, 'Other attackers', 'Fill the box. Holding midfielder to the edge of the area')
) AS v(so, role, job);

-- 49. pp.109-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Positional Patterns of Play - Set-ups 1, 3 and 4', 'Forward''s set and spin (give and go)',
    'The forward receives a vertical pass with his back to goal. He lays it off to a central midfielder, then spins round or between the centre backs to take a return pass in behind.',
    'Vertical lane to the forward open, often while the press blocks a pass to a midfielder',
    'The forward ends up 1v1 with the keeper, using the centre backs'' focus on the lay-off.',
    NULL, 109, 135, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder', 'Under pressure, pick the open vertical pass into the forward'),
    (2, 'Forward (target man)', 'Receive in front of the centre backs, set back, spin in behind for the return'),
    (3, 'Central midfielder', 'Spin away from his marker to receive the set, play the return through ball first time'),
    (4, 'Wingers and other midfielder', 'Run into the box for rebounds or a square ball')
) AS v(so, role, job);

-- 50. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Positional Patterns of Play - Set-up 2 (3-2-3)', 'Forward turns and slips the winger',
    'After the midfielders combine to shift the block, the holding midfielder finds the forward between the lines. The forward is free enough to turn and face goal.',
    'Forward receives with time and no tight marker behind him',
    'The forward plays a diagonal through ball between the centre backs for the winger''s inside run.',
    NULL, 117, 117, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder', 'Use the central midfielders'' bounce to step forward and feed the forward'),
    (2, 'Forward', 'Receive, turn, play a diagonal through ball'),
    (3, 'Weak-side winger', 'Run between full back and centre back to shoot'),
    (4, 'Midfielders and other winger', 'Fill the box as passing options')
) AS v(so, role, job);

-- 51. pp.119-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Positional Patterns of Play - Set-up 2 (3-2-3)', 'Reset when overlap is blocked',
    'The ball is switched to the winger, who drives inside and finds the overlapping full back. When the full back''s way forward is shut, he turns back and carries away from goal. A central midfielder slides toward the touchline to give him a new angle.',
    'Overlapping full back''s route to the byline is blocked',
    'Keep the ball and attack again: the midfielder dribbles toward the box and plays a give and go with the forward, or chips a lofted diagonal into the box for the far winger''s run.',
    NULL, 119, 121, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Overlapping full back', 'If blocked, turn and carry backwards, then play to the midfielder'),
    (2, 'Ball-side central midfielder', 'Shift toward the touchline, receive, then give and go with the forward or loft a ball into the box'),
    (3, 'Forward', 'Short wall pass for the midfielder''s run into the box'),
    (4, 'Far winger', 'Attack the space behind the far full back to meet the lofted ball')
) AS v(so, role, job);

-- 52. pp.124-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Positional Patterns of Play - Set-up 3 (2-3-2-3)', 'Reset to centre back, re-attack',
    'A wide triangle of full back, winger and central midfielder combines, but the press closes it, so the full back plays back to a centre back to reset. The centre backs and holding midfielder move the ball (one-twos, across to the other centre back) under coach pressure.',
    'Wide combination closed and full back faces his own goal',
    'After the reset, attack again through the flank (midfielder to winger, full back''s deep overlap), through the centre with the forward as target man, or with a midfielder''s through ball to the winger.',
    NULL, 124, 126, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Drop off, receive the set, play back to the centre back'),
    (2, 'Centre back', 'Take a touch under pressure, one-two with the holding midfielder or pass across'),
    (3, 'Other centre back', 'Step forward with the ball, find the holding midfielder or a midfielder'),
    (4, 'Holding midfielder', 'Move deep or across to receive and feed a turning midfielder'),
    (5, 'Central midfielder', 'Turn to face forward and pick the route: wide, through the centre or in behind')
) AS v(so, role, job);

-- 53. pp.127-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Positional Patterns of Play - Set-up 3 (2-3-2-3)', 'Quick triangle, then switch via back line',
    'A fast one- or two-touch triangle on one side (full back, holding midfielder, central midfielder) draws the block. The ball then goes the other way through both centre backs, or a centre back who steps past halfway, or an aerial ball from the holding midfielder. The holding midfielder can let a pass run round him into space to receive the fourth pass.',
    'Block shifts across to a quick combination on the near side',
    'Find the far winger on the touchline with time. He drives inside or gives and goes with a midfielder, and the full back overlaps in behind.',
    NULL, 127, 129, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near-side full back / midfielders', 'Quick triangle to pull the block across'),
    (2, 'Holding midfielder', 'Drop away from his marker or open up, then switch or pass to a centre back'),
    (3, 'Centre back', 'Carry past halfway and pass to the far winger'),
    (4, 'Far winger', 'Stay wide on the touchline, receive, drive in or give and go'),
    (5, 'Far full back', 'Deep overlap for the pass in behind and cut-back')
) AS v(so, role, job);

-- 54. pp.132-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Positional Patterns of Play - Set-up 4 (2-3-2-3, 5v2 wide zones)', 'Double switch via centre back and holding midfielder',
    'Against a 4-4-2, the team circulates across the back line and overloads one wide zone (full back-winger one-two, centre back moving wide into the zone). It then plays back through the holding midfielder to the far centre back.',
    'Opponent shifts its midfield and wide players toward the first wide overload',
    'The far centre back carries past halfway and switches to the far winger. The winger drives inside and slips in the midfielder''s curved run.',
    '4-4-2', 132, 132, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Pass across. One goes wide into the zone, the other carries past halfway on the switch'),
    (2, 'Holding midfielder', 'Hub: turn and link to midfielder or winger, then open up to the far centre back'),
    (3, 'Near winger / full back', 'One-two inside the wide zone to fix opponents'),
    (4, 'Far winger', 'Receive the switch, drive inside, pass in behind'),
    (5, 'Far central midfielder', 'Curved run into the box to finish or square')
) AS v(so, role, job);

-- 55. pp.133-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Positional Patterns of Play - Set-up 4 (2-3-2-3, 5v2 wide zones)', 'Wide 5v2 overload, then attack through centre',
    'Against a 4-4-2, the full back, winger, centre back and a midfielder who moves wide out of the centre keep the ball in a wide zone where only two opponents can defend. The ball then comes back inside to the holding midfielder.',
    'Opponent''s wide pair and nearby midfielders are drawn into the wide zone',
    'The holding midfielder finds a midfielder facing forward or the forward. That leads to a through ball for the forward between the centre backs, a forward give and go with a spinning midfielder, or a forward wall pass for the far winger in behind.',
    '4-4-2', 133, 136, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back / winger / centre back', 'Combine in the 5v2 wide zone, recycle back to the centre back'),
    (2, 'Central midfielder', 'Drift from the centre into the wide zone to add a player, or receive on the back foot facing forward'),
    (3, 'Holding midfielder', 'Shift to receive on the half-turn and carry or play forward'),
    (4, 'Forward', 'Run between the centre backs, or come short as a wall for give and go / wall pass'),
    (5, 'Far winger', 'Run in behind off the wall pass')
) AS v(so, role, job);

-- 56. pp.138-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Positional Patterns of Play - Set-up 4', 'Back-three circulation, inverted forward combination',
    'In a 3-4-3, the wing back passes back to the right centre back and the ball moves along the three centre backs to the left one. He carries forward until pressed while the other two push past halfway. A central midfielder makes a long move across to receive. Opponent is 4-4-2.',
    'Left centre back is pressed after carrying forward',
    'The midfielder plays diagonally to the narrow (inverted) right forward, who gives and goes with the centre forward to get in behind.',
    '4-4-2', 138, 138, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'Pass along the line. The ball-side centre back carries until pressed. The others step past halfway'),
    (2, 'Right central midfielder', 'Long movement across to the ball side, then diagonal pass forward'),
    (3, 'Inverted right forward', 'Receive narrow between the lines, carry, give and go with the striker'),
    (4, 'Centre forward', 'Wall pass, then join the box'),
    (5, 'Wing backs and left forward', 'Run into the box')
) AS v(so, role, job);

-- 57. pp.141-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Combinations and Finishing', 'Full back''s third-man underlap',
    'On the flank, the holding midfielder and attacking midfielder play a one-two or pass to the winger, who touches inside. The full back, who dropped off to receive, makes a deep inside run between the opponent''s full back and centre back.',
    'Winger or attacking midfielder receives facing inside with the half-space channel open',
    'The through ball finds the full back as the third man in the channel, and he cuts back to the penalty spot for the forward.',
    NULL, 141, 144, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Check away from the marker, then come short, touch inside'),
    (2, 'Attacking midfielder', 'Check away and play the through ball, or set the one-two'),
    (3, 'Full back', 'Drop to receive, then underlap in behind as the third man and cut back'),
    (4, 'Forward', 'Time a curved run round the defender to finish')
) AS v(so, role, job);

-- 58. pp.142-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Combinations and Finishing', 'Full back''s overlap as third man',
    'The full back drops off, takes a diagonal touch past his opponent and finds the winger, who checks away before showing. The winger plays inside to the attacking midfielder, and the full back bends round on a deep overlapping run.',
    'Attacking midfielder receives inside the full back with the outside lane free',
    'The attacking midfielder plays in behind for the overlapping full back, who cuts back to the penalty spot or plays a low cross for the forward''s run.',
    NULL, 142, 145, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Diagonal touch past the opponent, pass wide, overlap deep, then cut back or low cross'),
    (2, 'Winger', 'Check away and show, touch inside to the attacking midfielder'),
    (3, 'Attacking midfielder', 'Check away, receive running, pass in behind'),
    (4, 'Forward', 'Run round the outside of the defender, timed to the delivery')
) AS v(so, role, job);

-- 59. pp.147-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'roberto-de-zerbi-92-build-up-passing-combinations-and-attacking-positional-pract'), 'in_possession', 'Attacking Combinations and Finishing', 'Forward''s set for midfielder''s third-man run',
    'A defender blocks the holding midfielder''s pass to the forward, so the forward moves diagonally off his line to open a new angle and receives.',
    'Direct lane to the forward blocked by a defender',
    'The forward plays a diagonal through ball between the centre backs for the far central midfielder''s third-man run into the box.',
    NULL, 147, 147, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder', 'Open up, wait for the forward''s new angle, pass forward'),
    (2, 'Forward', 'Move diagonally to beat the blocked lane, play through first time'),
    (3, 'Right central midfielder', 'Third-man run into the box to shoot'),
    (4, 'Wingers / other midfielder', 'Arrive in the box for rebounds')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('2107-coaching-book-de-zerbi-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
