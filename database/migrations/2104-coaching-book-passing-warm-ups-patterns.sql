-- 2104 📚 Coaching book patterns: "Passing Warm-Ups" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Passing Warm-Ups',
    subtitle    = 'Direct from Guardiola, Simeone, Ancelotti, Emery, Sarri & Heynckes',
    author      = 'Fausto Garcea, Daniele Zini',
    team        = 'Guardiola, Simeone, Ancelotti, Emery, Sarri, Heynckes',
    method_note = 'Part one covers the science of warming up (activation, mobility, load, the ladder from unopposed to opposed and competitive practices, psychological activation); part two gives tactical passing shapes (rhombus, triangle, Y shape, switches, runs) and passing circuits taken from six top coaches'' sessions. The circuits are unopposed, so patterns are the combinations they rehearse (give-and-go, third-man run, outside-to-inside movement, diagonal pass through inside support, deep overlap onto a through ball, Sarri''s synchronised multi-movement runs), in our words; physiology and fitness content is left out.'
WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes');

-- 1. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Unopposed Practice Example - Passing Warm-up Rhombus with Checking Away + One-Two', 'Check away, then show at an angle',
    'A receiver marked by a defender first moves away from them, then comes back off them into a diagonal line so the pass can reach him; the passer releases as he arrives.',
    'Receiver tightly marked in a rhombus passing line',
    'Get free of the marker and receive on a clean diagonal line, then combine with a one-two and a through pass for a runner.',
    NULL, 30, 30, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'Check away from the marker, then come back into the diagonal passing lane'),
    (2, 'Passer', 'Time the pass to when the receiver opens the angle'),
    (3, 'Wall player', 'Play the one-two return first time'),
    (4, 'Runner', 'Run onto the through pass behind the line')
) AS v(so, role, job);

-- 2. pp.32-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'to_defend', 'Global Practice Example - 4v4 (+1 Middle Joker) Possession and Transition Game', 'Counter-press before they escape',
    'A team keeping the ball with a central joker loses it; the opponents try to get the ball out of the crowded area at once and keep it.',
    'Ball lost inside the possession zone',
    'Win the ball straight back or block the way out of the zone before the opponent can escape with it.',
    NULL, 32, 32, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player to the ball', 'Press the new ball carrier at once'),
    (2, 'Other ex-possession players', 'Close the passing exits out of the area'),
    (3, 'Central joker', 'Stay inside the middle square as a free link for the team on the ball')
) AS v(so, role, job);

-- 3. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'to_attack', 'Special Practice Example - Forward Support Runs Practice with Pole Gates, Target Man and End Scoring Zones', 'Into the target man, lay-off for runner',
    'In a 3v3 midfield fight, the team that has or wins the ball plays straight into its striker standing in the end zone; he lays it off first time for a midfielder bursting forward through a gap.',
    'Ball won in midfield or a pass lane into the striker opens',
    'Use the striker as a wall so a supporting runner arrives facing goal and finishes in one touch.',
    NULL, 34, 34, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder on the ball', 'Play forward quickly into the target man'),
    (2, 'Target man (striker)', 'Receive in the end zone and lay off to the oncoming teammate'),
    (3, 'Supporting midfielder', 'Run forward through the gap in support and finish first time'),
    (4, 'Defending trio', 'Press to win the ball, then play forward into their own striker at once')
) AS v(so, role, job);

-- 4. pp.35-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Competitive Game Example - 5(+2) v 5(+2) Dynamic Bounce Game with End Support Players', 'Bounce off the end support player',
    'Goals only count from a return pass from a one-touch support player on the end line; the attacker plays into him and moves into a shooting spot for the bounce pass.',
    'Pass played into the end-line support player',
    'Finish from a one-touch return after a quick wall pass near goal.',
    NULL, 35, 35, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacker', 'Play into the end support and move straight away into a shooting position'),
    (2, 'End-line support player', 'Return the ball in one touch into the attacker''s path'),
    (3, 'Teammates', 'Keep alert and support to recycle if the bounce is blocked')
) AS v(so, role, job);

-- 5. pp.35-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'out_of_possession', 'Competitive Game Example - 5(+2) v 5(+2) Dynamic Bounce Game with End Support Players', 'Track the runner on the wall pass',
    'When the opponent plays into a wide or end support player for a return, the defenders must react the moment that pass is played.',
    'Opponent passes to their outside or end support player',
    'Follow the attacker who wants the return so the bounce pass cannot be received and shot.',
    NULL, 35, 35, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marking defender', 'Go with the attacker as soon as the ball goes to the support player'),
    (2, 'Covering defenders', 'Close the space in front of goal where the return will land'),
    (3, 'Goalkeeper', 'Set for a quick shot after the bounce')
) AS v(so, role, job);

-- 6. pp.48-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Warm-ups: Using Different Tactical Shapes - The Rhombus and Triangle Shapes', 'Play in triangles and rhombuses',
    'Players set themselves in triangles (a rhombus is two triangles) so the ball carrier always has angled options, which supports angles, penetration and covering.',
    'Team in possession organising support around the ball',
    'Create several passing lanes and quick, synchronised combinations among three or four players.',
    NULL, 48, 48, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Choose between the angled options the shape offers'),
    (2, 'Two nearest supports', 'Form a triangle with the ball, never in a straight line'),
    (3, 'Fourth player (rhombus tip)', 'Give the deeper or higher point that completes the rhombus')
) AS v(so, role, job);

-- 7. pp.49-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Warm-ups: Technical and Tactical Elements - Movements Without the Ball', 'Cutting, forward and overlap runs',
    'Players off the ball attack space in three ways: a diagonal cut across the defensive line, a straight forward run into free space, or an overlap round the outside of the teammate on the ball.',
    'Teammate on the ball able to pass forward',
    'Get open behind or past the defence; the overlap takes the carrier''s direct opponent out of the play.',
    NULL, 49, 50, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Cutting runner', 'Run diagonally across the defensive line into a receiving space'),
    (2, 'Forward runner', 'Run straight ahead into unmarked space to receive'),
    (3, 'Overlapping player', 'Run round the outside of the ball carrier, who can then pass forward'),
    (4, 'Ball carrier', 'Use the run: pass to it or use the defender''s hesitation')
) AS v(so, role, job);

-- 8. pp.50-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Warm-ups: Technical and Tactical Elements - Receiving and Ball Control', 'Directed first touch, open or closed',
    'Under intense pressing, the receiver''s first touch takes the ball into the space where he plans to play next, open or closed depending on where the opponent is and the direction of play.',
    'Pass arriving with an opponent near',
    'Move straight into the next action without a dead touch so pressure cannot settle.',
    NULL, 50, 50, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'Check the opponent''s position before the ball arrives and steer the touch away from him'),
    (2, 'Receiver', 'Keep moving straight after the touch into the next pass or dribble')
) AS v(so, role, job);

-- 9. pp.50-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Warm-ups: Technical and Tactical Elements - Various Types of Pass', 'Switch of play to the free side',
    'A long pass sends the ball to a free teammate in an area with few opponents and lots of space, usually the far side.',
    'Opponents crowded on one side, a teammate free on the other',
    'Make the game bigger and attack where the opponent is weak.',
    NULL, 50, 50, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Spot the free teammate and play the long switch'),
    (2, 'Far-side player', 'Stay wide and free to receive the switch')
) AS v(so, role, job);

-- 10. pp.52-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'The Rhombus Tactical Shape - Tactical Example 1', 'Rhombus: reach the tip via the wide point',
    'In the opponent''s half four players form a central rhombus (DM base, two CMs wide, CF tip between the lines). When the direct pass from DM to CF is blocked, the ball goes to a side point of the rhombus, who finds the CF.',
    'Direct vertical lane DM to CF covered',
    'CF gets the ball unmarked between the lines with room to turn and attack (3v4).',
    NULL, 52, 53, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (base)', 'Looks for CF first; if closed, plays to the side point'),
    (2, 'Right central midfielder (side point)', 'Takes the ball and passes on to the tip'),
    (3, 'Centre forward (tip)', 'Holds position between midfield and defensive lines, receives and turns')
) AS v(so, role, job);

-- 11. pp.54-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Rhombus Shape - Tactical Examples 2 and 3', 'Lay-off to a forward-running midfielder',
    'The ball reaches the CF at the tip of the rhombus (directly, or after a DM-RCM one-two and the CF sliding across to open the lane), but a centre back steps up tight behind him so he cannot turn.',
    'Centre back jumps onto the CF''s back',
    'A central midfielder running forward takes the first-time lay-off between the lines, facing goal in a 4v4 (or 4v4+1).',
    NULL, 54, 55, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (tip)', 'Shifts to open the lane, receives with marker behind, lays off first time'),
    (2, 'Central midfielder (side point)', 'Times a forward run past the midfield line to take the lay-off facing goal'),
    (3, 'Defensive midfielder (base)', 'Plays into the CF, or one-two with the near CM to shift the press first')
) AS v(so, role, job);

-- 12. pp.56-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Rhombus Shape - Tactical Example 4', 'Give and go through the midfield line',
    'The lane from DM to CF is shut. The DM plays to a side-point midfielder, who is pressed, returns the ball to the DM and immediately runs between the opponent''s midfield and back lines.',
    'Side-point midfielder pressed as he receives',
    'DM''s third pass finds the runner between the lines facing goal for a 4v4 attack.',
    NULL, 56, 56, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder', 'Bounces ball back to DM and sprints into the gap between the lines'),
    (2, 'Defensive midfielder (base)', 'Plays the wall pass and then the forward pass into the runner'),
    (3, 'Centre forward', 'Pins the centre backs so the gap stays open')
) AS v(so, role, job);

-- 13. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Rhombus Shape - Tactical Example 5', 'Overlap from the base of a wide rhombus',
    'The rhombus is formed out wide with the winger at the tip, tightly marked by the full back. DM plays to the pressed RCM, who switches across to LCM, while the DM at the base overlaps around the RCM.',
    'Winger at the tip closely marked; RCM pressed',
    'LCM plays a diagonal into space by the touchline for the overlapping DM, creating a 2v1 on the flank.',
    NULL, 57, 57, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (base)', 'Passes and then makes the overlapping run outside the RCM'),
    (2, 'Right central midfielder', 'Under pressure, moves the ball across to LCM'),
    (3, 'Left central midfielder', 'Plays the diagonal ball into the space near the side-line'),
    (4, 'Right winger (tip)', 'Holds the full back so the space behind him opens')
) AS v(so, role, job);

-- 14. pp.58-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Triangle Shape - Tactical Example 1', 'Overlap from base of triangle behind line',
    'Near the opponent''s box RCM, right winger and CF form a triangle. RCM plays to the winger who is marked from behind; winger passes across to CF while RCM overlaps outside the winger.',
    'Winger receives with a marker on his back',
    'CF slips the overlapping RCM in behind the back line inside the box with a chance to score.',
    NULL, 58, 59, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder (base)', 'Passes then overlaps outside the winger into the box'),
    (2, 'Right winger', 'Receives under pressure and passes across to CF'),
    (3, 'Centre forward', 'Plays the through ball in behind for the overlap')
) AS v(so, role, job);

-- 15. pp.60-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Triangle Shape - Tactical Example 2', 'One-two then CF third-man run',
    'Same triangle, but the CF is higher and tight to his marker so cannot receive. The winger instead returns the ball to the now-free RCM, and as soon as it is played back the CF bends a run between the two centre backs.',
    'CF too close to his marker to receive; ball played back to RCM',
    'RCM threads a through pass for the CF''s curved run in behind, giving a scoring chance in the box.',
    NULL, 60, 60, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger', 'Plays the ball back to RCM rather than forcing it to CF'),
    (2, 'Right central midfielder', 'Receives free and plays the through pass'),
    (3, 'Centre forward', 'Times a curved run between the centre backs as the ball goes back')
) AS v(so, role, job);

-- 16. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'The Tactical ''Y Shape''', 'Overlapping rhombus, triangle and Y shapes',
    'In a 4-3-3 possession shape several units overlap: a rhombus (DM, LCM, RCM, CF), a triangle (RB, DM, RCM) and a ''Y shape'' (RCB deep, DM, then both CMs). Also fits 4-4-2 or 4-2-3-1.',
    'Team settled in possession',
    'Every player sits in several shapes at once so the carrier always has multiple passing lines to progress.',
    '4-3-3', 61, 61, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back', 'Base of the Y, deepest option'),
    (2, 'Defensive midfielder', 'Hub of rhombus, triangle and Y'),
    (3, 'Right back', 'Wide point of the triangle'),
    (4, 'Central midfielders', 'Side points of rhombus and arms of the Y'),
    (5, 'Centre forward', 'Tip of the rhombus between the lines')
) AS v(so, role, job);

-- 17. pp.62-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Training Individual Tactical Principles: Player Movement', 'Check away or open up to receive',
    'Each receiver first moves away from his marker (the cone) and then comes back, or opens up at an angle, before the ball arrives; base player moves up to support, side players come inside or open wide, the tip player comes towards the ball or cuts in behind his marker.',
    'Teammate about to pass; receiver has a marker near him',
    'Lose the marker and receive with time on a directional first touch towards the next pass.',
    NULL, 62, 63, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Base player (DM)', 'Steps off the marker and moves up to support'),
    (2, 'Side players (CMs/full backs)', 'Check away, then open up wide or come inside to receive'),
    (3, 'Tip player (forward)', 'Shows to feet or cuts in behind the marker')
) AS v(so, role, job);

-- 18. pp.64-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Coaching Link Play and Decision Making: Practices', 'Receivers choose the space, not a script',
    'Inside a rhombus combination (one-two, forward pass, lay-off, final ball in behind, or through pass then diagonal into feet) each receiver decides whether to open up, come inside to meet the ball or drop, and the top player decides to come short or run behind.',
    'Movement of the teammate before you',
    'Players link freely and read each other, so the combination adapts to what the defender gives.',
    NULL, 64, 65, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Side player B', 'Chooses to check and drop, or run round his marker into depth'),
    (2, 'First passer A', 'Moves across to offer a short return option'),
    (3, 'Top player D', 'Checks to support and lays off, or spins in behind for the final pass')
) AS v(so, role, job);

-- 19. pp.74-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Ancelotti 2,8,10 / Guardiola 1,9 - Give and Go', 'Give and go round the marker',
    'Player passes into a teammate who has checked away and dropped, then runs round his own marker for the return (one-two) to beat a line in tight areas; chains of give-and-gos move the ball through midfield.',
    'Pass played into a dropping teammate',
    'Passer receives back on the run beyond his marker, facing forward.',
    NULL, 74, 93, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer (full back / midfielder)', 'Plays in and immediately runs past the cone/marker'),
    (2, 'Wall player', 'Checks away, drops to receive, returns first time into the run')
) AS v(so, role, job);

-- 20. pp.75-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Ancelotti 3,6 - Outside to Inside', 'Check outside, receive moving inside',
    'Wide players (full backs, side midfielders) first move outward away from the ball, then come inside to receive on the move with a directional touch with the outside of the foot.',
    'Ball moving towards your side of the shape',
    'Escape the marker and progress the play quickly with the body already facing forward.',
    NULL, 75, 78, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player (full back / side midfielder)', 'Checks outside, then comes inside to receive on the move'),
    (2, 'Supporting midfielder', 'Offers the one-two option inside')
) AS v(so, role, job);

-- 21. pp.76-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Ancelotti 4,7 / Guardiola 2,3,8 - Finding the Third Man', 'Third man run onto the lay-off',
    'A plays to B, B lays the ball to C, and a third player who has dropped back then runs forward (or round the cone) to take C''s pass; often he carries the ball on before the next pass.',
    'Ball played into a player who can only lay it off',
    'A free runner arrives facing forward beyond the line the first pass could not break.',
    NULL, 76, 92, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Third man runner', 'Drops off first, then times a forward run to receive the lay-off and dribbles on'),
    (2, 'Lay-off player', 'Receives with marker behind and sets the ball first time'),
    (3, 'Final passer', 'Plays the through or diagonal ball into the run')
) AS v(so, role, job);

-- 22. pp.77-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Ancelotti 5,9 / Guardiola 4-6 - Progressing via Inside Support', 'Progress through inside support and diagonal',
    'The ball goes wide; the wide player checks and drops, then plays inside for a central midfielder who has checked off and moved across to support, who opens up on the back foot and plays a hard diagonal ground pass forward, while others make angled movements to give width and depth.',
    'Ball reaches the wide player under pressure',
    'Move the ball forward quickly through the middle with angled support and incisive forward passes.',
    NULL, 77, 90, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player', 'Checks away, receives, plays inside'),
    (2, 'Central midfielder', 'Moves across to support, receives on back foot, plays the diagonal'),
    (3, 'Advanced player', 'Drops at an angle to receive or lays off for a forward run'),
    (4, 'Full back / wide midfielders', 'Make angled movements to stretch width and depth')
) AS v(so, role, job);

-- 23. pp.89-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Guardiola 5,7,8,10 / Sarri 3 - Deep Overlap Run', 'Long through ball for deep overlap',
    'After short combinations in a rhombus or triangle, a wide player who first drops back curls a deep overlapping run around his marker, and a teammate who has got the ball on the half-turn plays a long incisive or diagonal through pass into it.',
    'Midfielder receives facing forward after a lay-off',
    'Runner gets in behind the line at full speed with the ball in front of him.',
    NULL, 89, 99, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Overlapping runner', 'Drops off first, then makes a curved deep run around the marker'),
    (2, 'Playmaker', 'Turns after the lay-off and plays the long through ball'),
    (3, 'Lay-off player', 'Cuts in or comes short to set the ball back')
) AS v(so, role, job);

-- 24. pp.97-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Sarri 1-4 - Y Shape Circuits', 'Synchronised multi-movement deep run',
    'In a Y shape with two support options for every carrier, the forward-side receiver makes up to three movements: checks off his marker, comes back to receive and return the ball (one-two or lay-off), then spins the opposite way into depth for a through pass and carries forward.',
    'Return pass played from the receiver to the midfielder',
    'Precise ''game timing'' between passer and runner releases the runner in behind in a fast combination.',
    NULL, 97, 100, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forward (D)', 'Checks off, returns the ball, then makes the opposite run in behind and carries'),
    (2, 'Central midfielder (C)', 'Shifts to one side of his marker, combines, then plays the through pass'),
    (3, 'Base player (B)', 'Plays forward and offers the second support option')
) AS v(so, role, job);

-- 25. pp.101-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Maurizio Sarri - Short Triangle Combination Play + Through Pass for Overlap / Forward Pass and Move to Support', 'Lay-off then overlap around the receiver',
    'In a tight triangle, a forward player checks off his marker and lays the ball off. A wide player who has dropped to receive then plays a give-and-go with him and runs round the outside to get the return in behind.',
    'Forward pass played into the checking player''s feet',
    'Free the wide player running onto the ball beyond the line with a through pass after a quick combination.',
    NULL, 101, 103, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep midfielder (passer)', 'Plays into the checking player, then moves up to support the lay-off'),
    (2, 'Checking forward', 'Moves to one side of his marker, lays off first time, then slips the through pass'),
    (3, 'Wide player', 'Checks and drops to receive, gives and goes, runs round the outside (overlap) onto the return'),
    (4, 'Ball side', 'Passes and receives with one or two touches only, so the move stays sharp')
) AS v(so, role, job);

-- 26. pp.104-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Maurizio Sarri - Deep Forward Pass + Give and Go within a Rhombus / One-Two, Deep Forward Pass, Third Man Run', 'Deep pass, lay-off, opposite-side third man',
    'A hard ground pass goes straight to the top of the rhombus. The target opens up and lays off to a side player coming inside, who plays across the rhombus into the curved run of the original target around his marker.',
    'Side player checks away (or plays a one-two) as the pass goes into the top man',
    'Get the top player, now facing goal, onto the ball running into space after a third-man sequence.',
    NULL, 104, 105, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder', 'Plays the hard vertical ground pass into the top man, or a one-two with the side player first'),
    (2, 'Top player (striker)', 'Opens up, lays off, then curls round his marker to receive in behind'),
    (3, 'Side midfielder', 'Checks back, then runs forward and inside (opposite to the striker''s move) to meet the lay-off and play across')
) AS v(so, role, job);

-- 27. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Maurizio Sarri - Three Player Combinations within a Double Triangle Structure', 'Diagonal into the far triangle, give-and-go',
    'Two triangles side by side. After a one-two with the near midfielder, the deep player hits a hard diagonal to the far-side forward, who sets it back for the midfielder''s forward run and then spins round for the give-and-go return. The move is repeated mirrored on the other side.',
    'Near midfielder moves up at an angle to give the return of the one-two',
    'Use a diagonal across the shape plus a set-back to put a forward running onto the ball, alternating sides.',
    NULL, 106, 106, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep player', 'One-two with the near midfielder, then the hard diagonal ground pass to the far forward'),
    (2, 'Near midfielder', 'Gives the one-two, then runs forward to take the set-back and play the return'),
    (3, 'Far forward', 'Moves off his cone, sets the ball back, then runs around for the give-and-go and carries the ball out')
) AS v(so, role, job);

-- 28. pp.109-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Unai Emery - Triangle Passing Circuit / Directional Touch Through the Cone Gate / Double One-Two and Feint', 'Check away, open up, play forward',
    'Receivers in a triangle step away from the marker before coming to the ball, open the body and take a directional first touch into the space they want, then carry at a defender and feint past him.',
    'Ball about to be played to you while marked',
    'Receive already facing forward and beat the nearest defender rather than receive square and static.',
    NULL, 109, 111, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'Checks off the cone (marker), opens up, takes the first touch away from pressure in the direction of play'),
    (2, 'Ball carrier', 'Runs at the defender, feints to go past him on either side, then passes on'),
    (3, 'Passer', 'Passes accurately to the receiver''s open side (through the gate)')
) AS v(so, role, job);

-- 29. pp.112-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Unai Emery - Quick Combination, Through Pass, Check Away + Incisive Third Man Run / Triangle Support Play with Lay-Offs and Third Man Runs', 'One-two then incisive third man run',
    'After a quick one-two, the ball goes into a team-mate who has moved round to receive. Meanwhile the third player first drops (checks away), then cuts forward past the defender to take the through pass on the move. In the longer version a lay-off from the forward sets up each third-man run.',
    'One-two completed and the middle player receives facing the run',
    'Find a well-timed runner behind the defender with one forward pass after a short combination.',
    NULL, 112, 118, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Starting player', 'Plays the one-two, then the pass into the middle player'),
    (2, 'Middle player', 'Bounces the first pass, moves round to receive again and slides the through pass'),
    (3, 'Third man', 'Checks away first, then runs across and past the defender to receive on the move and carry it'),
    (4, 'Forward (longer version)', 'Comes towards the ball and lays off for the third man''s run')
) AS v(so, role, job);

-- 30. pp.113-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Unai Emery - Close Combination Play / Triangle Support Play with Double Give and Go / Forward Pass and Give and Go / Forward Pass and Lay-off', 'Follow your pass to support',
    'In tight spaces the passer follows his ball straight away to offer close support, so the receiver can bounce it back, combine (single or double give-and-go) or lay off, and the third player of the triangle times a drop or run to get the next pass.',
    'Any short pass in a congested area',
    'Always keep a nearby support option so the ball keeps moving quickly through the triangle and onto a forward runner.',
    NULL, 113, 116, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Follows his pass at once to give a support angle'),
    (2, 'Receiver', 'Plays a give-and-go or a lay-off with the supporting player and spins round for the return'),
    (3, 'Third player', 'Checks away, then drops or moves forward to take the next pass, receiving on the move with a directional touch')
) AS v(so, role, job);

-- 31. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Unai Emery - Triangle Support Play with Dummy + One-Two (Give and Go)', 'Dummy to take defenders out',
    'The first player on the line of a pass pretends to receive but lets the ball run through his legs to a team-mate behind, then makes his next movement, while the receiver plays a quick give-and-go.',
    'Team-mate behind is free on the same pass line',
    'Wrong-foot the nearest opponent and gain a passing line without an extra pass.',
    NULL, 117, 117, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front receiver', 'Shapes to receive, dummies the ball through his legs, then moves to support again'),
    (2, 'Second receiver', 'Takes the ball the dummy let through and plays a short give-and-go'),
    (3, 'Passer', 'Plays firmly along the line so the dummy is possible')
) AS v(so, role, job);

-- 32. pp.121-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Diego Simeone - Creating Space to Receive in a "Y Shape" / Forward Run to Receive Return Pass + Give and Go', '"Y Shape" check away and call the side',
    'Played in a Y shape: line pass into a midfielder who calls the side he will play to, checks away (up, down or across) off his marker, opens up and plays diagonally to a wide player. The wide player either turns with a directional touch, or sets the ball back for the midfielder''s diagonal forward run and goes round for a give-and-go.',
    'Pass into the central midfielder',
    'Good game timing: the midfielder picks the side and makes a run that frees a forward pass rather than just receiving.',
    NULL, 121, 122, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep player (base of the Y)', 'Plays into the midfielder''s chosen side'),
    (2, 'Central midfielder', 'Calls the side, checks off his marker, opens up, passes diagonally, then runs forward diagonally for the return'),
    (3, 'Wide forward (top of the Y)', 'Moves off his marker, turns with a directional touch or sets the ball back and runs round for the return')
) AS v(so, role, job);

-- 33. pp.123-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Diego Simeone - Double One-Two, Long Pass, Third Man Run / Deep Forward Pass, Lay-Off for Third Man Run', 'Long ball to forward, lay-off for third man',
    'A long forward pass goes straight to the top player of the Y (sometimes after a one-two with the midfielder). He sets it back into the diagonal third-man run of the midfielder, who then slides the ball into the path of the forward spinning round his marker.',
    'Forward moves off his marker towards the long pass',
    'Skip the midfield line with one long pass, then use a lay-off and a third-man run to get the forward running in behind.',
    NULL, 123, 124, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep player', 'Hits the long forward ground pass to the forward (after a one-two with the midfielder in one version)'),
    (2, 'Forward', 'Comes off his marker, lays off first time, then spins round for the through pass'),
    (3, 'Central midfielder', 'Makes the diagonal third-man run onto the lay-off and plays into the forward''s path')
) AS v(so, role, job);

-- 34. pp.125-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Diego Simeone - "Double Triangle" Combinations (Different Movements / Give and Go and Third Man Run / Forward Movement) / Pass and Receive High Up / Complex Sequence of Checking Away', '"Double Triangle" switch and break the line',
    'After a one-two with the dropping midfielder, the deep player plays a long diagonal to a far-side forward who has also checked back. That forward sets it back for the midfielder''s forward run and the ball is then switched across to the other forward, who first drops and then runs in behind (via a give-and-go, a third-man run, an overlap or an angled through pass).',
    'Midfielder checks and drops to one side, then plays the one-two',
    'Shift the ball across the top of the shape and break the line with a timed run into space on the far side.',
    NULL, 125, 130, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep player', 'One-two with the dropping midfielder, then the long diagonal to the far forward'),
    (2, 'Central midfielder', 'Checks and drops, gives the one-two, then runs forward to take the set-back and play across or give-and-go'),
    (3, 'Ball-side forward', 'Checks back, sets the ball back, or plays across and supports again for an angled through pass'),
    (4, 'Far-side forward', 'Moves forward, then opens up, or times a run round his marker (overlap or third-man) to receive in space')
) AS v(so, role, job);

-- 35. pp.133-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Jupp Heynckes - Switches of Play and Finding Third Man in a Rhombus / Drop and Shift Across in a Double Mirrored Rhombus / Switch of Play', 'Switch play to the third man',
    'In a rhombus, a side player drops to receive, comes forward again for the return and switches across to the far side. The top player checks one way, then makes an opposite run to take the far player''s lay-off, while the far player overlaps round him for the return; the central player drops and curves across to receive the cutting pass on the opposite side.',
    'Ball reaches the side player of the rhombus facing the far side',
    'Move the ball from one side to the other and find a free third man on the far side.',
    NULL, 133, 135, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Side player (near)', 'Drops to receive, steps forward to take the return, switches play across'),
    (2, 'Far side player', 'Lays off to the top or central player, then overlaps round for the return'),
    (3, 'Top / central player', 'Checks one way, then curves across the opposite way to receive and play on'),
    (4, 'Every player', 'Scans for the third man before receiving')
) AS v(so, role, job);

-- 36. pp.136-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Jupp Heynckes - Two-Ball Double Rhombus Circuit (Opening Up and Give and Go / One-Twos and Third Man Runs / Forward Runs and Overlaps)', 'Counter-movement to receive in space',
    'A wide forward first drops back, then makes a counter-movement forward into space to receive a through pass and dribble on. Before that pass, the central players combine (opening up with a directional touch, a one-two, a third-man run onto a lay-off, or a give-and-go with an overlap around the cone).',
    'Central player receives facing forward after the combination',
    'Get the wide forward the ball behind the line while running, set up by a short central combination.',
    NULL, 136, 138, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Starting player', 'Plays into the checking midfielder, or a one-two and runs forward'),
    (2, 'Inside midfielder', 'Checks with a counter-movement, opens up, or makes a third-man run onto the lay-off'),
    (3, 'Advanced central player', 'Opens up with a directional touch, plays a one-two and then the through pass'),
    (4, 'Wide forward', 'Drops first, then counter-moves (or overlaps round) to take the through pass and dribble forward')
) AS v(so, role, job);

-- 37. pp.139-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'passing-warm-ups-direct-from-guardiola-simeone-ancelotti-emery-sarri-heynckes'), 'in_possession', 'Jupp Heynckes - Open Up, Receive, Pass in Central Rhombus / Double Support Play in Central Rhombus / Triple One-Two / Different Runs to Receive Lay-Offs + Give and Go Overlap', 'Central rhombus, then wide give-and-go overlap',
    'The ball moves through a central rhombus with players moving off cones to open up, one-twos and lay-offs for inside runs, until the top central player finds the wide forward. The wide forward moves one way, then plays a give-and-go with him and runs round the outside onto the return.',
    'Ball reaches the top central player with the wide forward ready',
    'Work the ball up through the centre, then release the wide forward running onto the return outside his marker.',
    NULL, 139, 142, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Base player', 'Passes into the opening-up midfielder, or plays one-twos with two team-mates in turn'),
    (2, 'Side midfielders of the rhombus', 'Move off the cone to open up, play forward, make inside runs onto lay-offs'),
    (3, 'Top central player', 'Lays off or plays to the wide forward and returns the give-and-go'),
    (4, 'Wide forward', 'Moves one way to receive, gives and goes, overlaps round to collect and run with the ball')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('2104-coaching-book-passing-warm-ups-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
