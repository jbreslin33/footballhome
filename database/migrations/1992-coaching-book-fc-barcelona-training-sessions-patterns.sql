-- 1992 📚 Coaching book patterns: "FC Barcelona Training Sessions" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'FC Barcelona Training Sessions',
    subtitle    = '160 Practices from 34 Tactical Situations',
    author      = 'Athanasios Terzis',
    team        = 'FC Barcelona (Guardiola)',
    method_note = 'Companion to the author''s tactical analysis of Guardiola''s Barcelona (Messi, Xavi, Busquets, Piqué, Alves). Fifteen passing practices drawn from Barça''s typical combinations, then 26 attacking and 8 defending tactical situations, each with a diagram analysis and progressive practices: the winger dropping as a link player, the centre back carrying into midfield, rotations to free the 10, full back pushing up with the holding midfielder dropping, combinations between winger, 10 and full back, Busquets covering when a centre back steps out, negative and positive transitions (break within 6-8 seconds), and defending (slide across together, force wide and double, block passes forward, defend the switch and the box). Patterns are the match behaviours, in our words.'
WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations');

-- 1. pp.15-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Passing Practices - Analysis: FCB Passing Combinations (diagram 4)', 'Diagonal run toward touchline for overload',
    'After passing inside, a player runs diagonally out toward the sideline to add a body on the flank.',
    'Ball played into a central team-mate',
    'Create a numbers-up situation on the side and an outlet wide of the opposing block.',
    NULL, 15, 15, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide-ish passer', 'Pass inside then sprint diagonally toward the touchline'),
    (2, 'Receiver inside', 'Hold or play out to the runner arriving wide')
) AS v(so, role, job);

-- 2. pp.15-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Passing Practices - Turn, Pass and Move; Analysis diagram 5-6', 'Receive on the half-turn, play forward',
    'A player moves toward the ball carrier, takes it on the half-turn and plays a vertical or final pass to a forward who made a diagonal run; or a back pass followed by a diagonal run into the free space.',
    'Forward makes a diagonal movement into a gap',
    'Turn the play forward in one movement and hit the forward''s run.',
    NULL, 15, 20, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder', 'Come short, open body, receive on the half-turn and turn'),
    (2, 'Forward', 'Diagonal run timed to the turn, receive the vertical/final pass')
) AS v(so, role, job);

-- 3. pp.15-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Passing Practices - Analysis: FCB Passing Combinations', 'One-two: pass, move, take it back',
    'Short combinations all over the pitch where the passer immediately moves to a new angle and gets the return ball, often after a diagonal pass and a vertical lay-off.',
    'Pass played into a team-mate who can set it back first time',
    'Keep the ball moving at one or two touches and get the original passer on the ball facing forward past a marker.',
    NULL, 15, 22, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Play diagonally, then move straight away to the angle for the return'),
    (2, 'Wall player', 'Show for the ball, lay it back first time with the correct foot, then spin to the next corner/space'),
    (3, 'All', 'Time the pass to the run; weight on the front foot of the runner')
) AS v(so, role, job);

-- 4. pp.18-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Passing Practices - Creating Space Pattern of Play', 'Check away, then use the space',
    'Players first move away from the ball (toward a marker/cone) to pull a defender, then come back into the space; a second player exploits the space vacated by the first. Book notes this happened mostly near the sidelines for Barca.',
    'Team-mate about to receive with time to pass',
    'Free a receiver and let a third player run into the gap the decoy opened.',
    NULL, 18, 22, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Decoy (e.g. No.17)', 'Check away, receive, set it, then rotate round to rejoin'),
    (2, 'Third player (e.g. No.7)', 'Attack the space the decoy vacated and receive there'),
    (3, 'Holder (e.g. No.3)', 'Start and finish the sequence, play the final pass into the freed man')
) AS v(so, role, job);

-- 5. pp.21-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Passing Practices - One Touch Combination Play with an Overlapping Run', 'Combination followed by overlap',
    'A player passes into a team-mate and runs round the outside; the receiver takes a directional first touch inside away from his marker and combines before releasing the overlapper.',
    'Pass into a team-mate tight to a marker',
    'Use the overlap to arrive in space wide of the defender and receive first time.',
    NULL, 21, 22, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Overlapper', 'Pass, then curve round the outside of the receiver'),
    (2, 'Receiver', 'Directional first touch inside away from the marker, combine, release the runner'),
    (3, 'Support player', 'Drop back at the right moment to offer the wall pass')
) AS v(so, role, job);

-- 6. pp.23-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Passing Practices - First Touch and Awareness / Correct Body Shape', 'Open body, scan, touch into space',
    'Receivers keep moving and opening up, check who they get it from and who they pass to, receive on the back foot and take the first touch toward the next pass or into free space.',
    'Ball about to arrive',
    'Speed up play so each receiver is ready to pass on with one or two touches.',
    NULL, 23, 30, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'Open up, receive across the body on the back foot, first touch toward the next target'),
    (2, 'Next receiver', 'Represent the free space; sprint and move to show before the ball is played'),
    (3, 'Central neutral', 'Know the options before the ball arrives, play one touch')
) AS v(so, role, job);

-- 7. pp.26-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Passing Practices - Overcoming the Opposition''s Pressure Possession Game', 'Inside players move into open lanes',
    'Under pressure from defenders, the inside players constantly move into available passing lanes and use the numerical advantage with the outside players to keep the ball.',
    'Opponents press the ball carrier and block a lane',
    'Escape the press by always offering a free lane and exploiting space created by superiority in numbers.',
    NULL, 26, 27, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside midfielders', 'Keep moving to the available lane, take first touch into space'),
    (2, 'Outside players', 'Shift along the side, play one touch')
) AS v(so, role, job);

-- 8. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Passing Practices - Switching Play ''Double Square'' Possession Game', 'Blocked inside: find the free side',
    'The team tries to play into central players; when pressure blocks the angle, they recognise and switch to the free side, where a player will always be open, and centrals switch the play themselves.',
    'No passing angle into the centre due to opponent pressure',
    'Change direction quickly to the unpressured side.',
    NULL, 28, 28, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside players', 'Look for the free side when the inside pass is shut'),
    (2, 'Central players', 'Receive and switch the play to the opposite side')
) AS v(so, role, job);

-- 9. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Passing Practices - Forming the Correct Shapes in an End to End Possession Game', 'Rhombus and triangles around the ball',
    'Players in possession arrange themselves in diamonds and triangles so the man on the ball always has several options, including a safe back pass to the player he received from.',
    'Team in possession moving the ball through a block',
    'Retain possession and progress the ball end to end.',
    NULL, 30, 30, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Supporting players', 'Form rhombus/triangle angles around the ball'),
    (2, 'Player in possession', 'Use the back pass to the giver if forward options are shut')
) AS v(so, role, job);

-- 10. pp.33-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 1 - Forward Passes Directly from the Defenders to the Forwards', 'Centre back steps up, forward drops as link',
    'With space ahead, the centre back carries the ball forward; a winger (No.17) drops into a passing lane as link player and lays off to No.10 (Messi) in the space behind the opposition midfield line.',
    'Centre back has free space in front of him',
    'Get a player receiving behind the midfield line with a body shape that faces goal, a step from the final pass.',
    NULL, 33, 38, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Pique 3)', 'Carry the ball forward quickly, then pass direct to the dropping forward'),
    (2, 'Winger (17)', 'Drop into the passing lane, check away from marker, lay off as link player'),
    (3, 'No.10 (Messi)', 'Receive behind the opposing midfielders facing goal'),
    (4, 'Midfielders', 'Offer passing lanes but do not need to be the next pass')
) AS v(so, role, job);

-- 11. pp.33-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 1 - Forward Passes Directly from the Defenders to the Forwards (Situation 2)', 'Midfielder''s late run past link player',
    'Same build as above, but instead of No.10 it is No.6 (Xavi) who times a forward run beyond the four opposing midfielders to take the lay-off from the dropping winger.',
    'Defender plays direct into the dropping forward',
    'A midfielder arrives in the space behind the midfield line facing the opposition goal.',
    NULL, 33, 38, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (17)', 'Drop and set the ball back/inside first time'),
    (2, 'Central midfielder (Xavi 6)', 'Well-timed forward run past the midfield line'),
    (3, 'Centre back', 'Find the vertical pass through the midfield line')
) AS v(so, role, job);

-- 12. pp.40-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 2 - Defenders Joining the Midfield', 'Centre back dribbles into midfield overload',
    'A defender (especially Pique) runs the ball out from the back into midfield, creating a 4v3 around the ball, and the ball goes to the free player (Dani Alves on the right).',
    'Defender receives with space in front',
    'Create superiority in numbers in midfield and release the free man to move the ball forward.',
    NULL, 40, 44, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Pique 3)', 'Dribble forward fast, ball close, into the midfield zone and combine'),
    (2, 'Midfielders', 'Check away from their marker to create space and passing options'),
    (3, 'Free player (Alves 2)', 'Receive the ball from the overload and drive forward'),
    (4, 'Rest of team', 'Keep cohesion and balance to be ready for losing the ball')
) AS v(so, role, job);

-- 13. pp.46-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 3 - Switching Positions During Build Up Play', 'Forward-midfielder switch to free No.10',
    'As Pique carries the ball, No.6 runs toward the sideline and drags his midfield marker with him, opening space deeper that No.10 (Messi) drops into, receives unmarked and turns; others then offer options, with a link player finding Xavi free in an advanced spot.',
    'Centre back has space before the opposing forward can close him',
    'Forwards and midfielders swap places so a forward can receive deeper, turn and face goal without pressure.',
    NULL, 46, 50, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Pique 3)', 'Move forward with the ball while unpressed'),
    (2, 'Midfielder (Xavi 6)', 'Run toward the sideline to drag the marker, then go forward into the free advanced space'),
    (3, 'Forward (Messi 10)', 'Drop into the vacated space on the half-turn and turn forward'),
    (4, 'Other forwards (8, 17)', 'Offer passes as soon as the dropping player has it; 17 acts as link')
) AS v(so, role, job);

-- 14. pp.52-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 4 - The Forward Dropping Deep to Maintain Possession', 'Forward drops as extra midfield outlet',
    'When the ball carrier (centre back 5) is pressed and his passes into the holding midfielders are screened by opposing forwards, the centre forward (Messi) drops at the right moment to give an extra option and act as link to a midfielder.',
    'Defender under pressure with lanes to the midfielders blocked',
    'Create a numerical advantage in midfield to keep the ball, then break quickly once it goes into the high zone.',
    NULL, 52, 56, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Messi 10)', 'Time the drop, body open for a first-time lay-off to a midfielder'),
    (2, 'Centre back under pressure', 'Play into the dropping forward'),
    (3, 'Midfielders (6, 16)', 'Receive the lay-off and move the ball on'),
    (4, 'Other forwards', 'Run forward as soon as the ball goes into the high zone for a quick attack')
) AS v(so, role, job);

-- 15. pp.58-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 5 - Creating Space for Others to Exploit in the Low Zone', 'Full back up, holding mid drops wide',
    'Against a compact block that shuts passes into Busquets and Xavi, the left back (22) pushes forward, the opposing wide midfielder follows him, and Busquets (16) drops into the space created in the low zone to receive unmarked, giving a 3v2 on that side; used with three at the back.',
    'Opponent compact and blocking passes to the central midfielders',
    'Receive unmarked in the low zone and gain superiority on the flank to move the ball forward.',
    NULL, 58, 62, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (22)', 'Push forward on the flank to pull the opposing wide midfielder'),
    (2, 'Defensive midfielder (Busquets 16)', 'Drop into the vacated wide-low space and receive from the centre back'),
    (3, 'Centre back (5)', 'Pass into the dropping midfielder'),
    (4, 'Midfielder (8)', 'Check away and set back for the third man (6) moving into space'),
    (5, 'Rest of team', 'Keep balance at the back; when a centre back steps out, the holding mid drops to cover')
) AS v(so, role, job);

-- 16. pp.63-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 5: Creating Space for Others to Exploit in the Low Zone', 'Full back pushes, holding mid fills low zone',
    'Against a compact block that shuts passes into the central midfielders, a full back advances so the opposing wide midfielder follows him, emptying the low zone beside the back line. Practised with both a 3 and a 4 man back line.',
    'Opponent wide midfielder tracks the advancing full back',
    'A defensive midfielder receives unmarked in the vacated low zone and creates a 3v2 on that side while balance at the back is kept.',
    NULL, 63, 64, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Abidal 22 / Alves 2)', 'Leave the low zone and push up to drag the wide midfielder'),
    (2, 'Defensive midfielder (Busquets 16 / Xavi 6)', 'Slide into the space the full back left and receive unmarked'),
    (3, 'Centre back with ball', 'Pass into the freed midfielder in the low zone'),
    (4, 'Remaining defenders', 'Hold balance behind the move')
) AS v(so, role, job);

-- 17. pp.65-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 6: Creating Space for Others on the Flank', 'Full back overlaps, winger drops into space',
    'Full back and winger move in sync: the full back runs forward, the opposing winger follows him, and the own winger drops back into the freed pocket to receive facing forward.',
    'Full back starts his forward run and his marker follows',
    'Winger receives unmarked, turns and plays either into Messi centrally or a diagonal ball behind the back line for the far winger.',
    NULL, 65, 70, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Alves 2)', 'Sprint forward to pull the opposing winger with him'),
    (2, 'Winger (Pedro 17)', 'Drop into the freed space at the right moment, open up, turn'),
    (3, 'Number 10 (Messi)', 'Offer the central option between the lines'),
    (4, 'Far-side winger (Villa 7)', 'Run diagonally in behind the defensive line'),
    (5, 'Centre back', 'Pass into the dropping winger'),
    (6, 'Back line', 'Keep balance while the full back is high')
) AS v(so, role, job);

-- 18. pp.71-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 7: Using the Correct Body Shape', 'Open body shape before receiving',
    'As the ball travels between team-mates, the next possible receivers take positions with an open stance so they can see opponents and team-mates before the ball arrives; also applied in a ''Receiving Zone'' build-up where midfielders feed the forwards.',
    'Ball reaches a team-mate one pass away',
    'The receiver already knows his options (ideally three) and moves the ball on with minimal hesitation, raising passing tempo and accuracy.',
    NULL, 71, 76, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielders (Busquets 16, Xavi 6)', 'Take up open half-turn positions as soon as a centre back gets the ball'),
    (2, 'Receiver', 'Make eye contact with passer, scan, receive with back foot'),
    (3, 'Midfielders in middle zone', 'Face forward to play quickly into the forwards'),
    (4, 'Forwards', 'Move into free passing lanes to receive from midfield')
) AS v(so, role, job);

-- 19. pp.77-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 8: Creating a Numerical Superiority on the Flanks', 'Attacking mid diagonal run behind full back',
    'With the ball on a flank, the attacking midfielder runs diagonally towards the touchline into the space behind the opposition full back while the winger checks away from his marker to receive.',
    'Winger receives on the flank and the full back steps to him',
    'Create a 2v1 on the flank and get the midfielder in behind the line to cut back or combine with the striker.',
    NULL, 77, 85, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Iniesta 8)', 'Run diagonally outside and behind the opposition full back'),
    (2, 'Winger (Villa 7)', 'Check away from marker, receive, slip the runner in'),
    (3, 'Striker (Messi 10)', 'Attack the box for a short pass or return ball'),
    (4, 'Defensive midfielder (16)', 'Play into the winger, sometimes with a long ball')
) AS v(so, role, job);

-- 20. pp.78-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 8: Creating a Numerical Superiority on the Flanks', 'Full back overlap or underlap for 2v1',
    'The second route to a flank overload: the full back runs past the winger on the outside (overlap) or on the inside behind the opposing full back while the winger dribbles inside.',
    'Winger receives and carries the ball inside',
    'Full back arrives free in behind and delivers a low cross for the striker.',
    NULL, 78, 83, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Abidal 22)', 'Overlap outside or run inside behind the opposition full back'),
    (2, 'Winger (Villa 7)', 'Dribble inside to fix the defender, release the full back'),
    (3, 'Striker', 'Run through the back line to meet the low cross'),
    (4, 'Attacking midfielder (8)', 'Support with a short combination option')
) AS v(so, role, job);

-- 21. pp.84-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 8: Creating a Numerical Superiority on the Flanks', 'Switch to weak side for flank 2v1',
    'When the opponent has only three defenders across the back they cannot cover the full width, so quick switches to the weak side find a flank where overlaps or diagonal runs produce 2v1s.',
    'Opposition defence shifted to the ball side',
    'Get the ball to the uncovered flank fast and attack it with two players against one.',
    NULL, 84, 85, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders (16, 6)', 'Circulate quickly to the weak side'),
    (2, 'Weak-side full back', 'Overlap or underlap to create the 2v1'),
    (3, 'Weak-side attacking midfielder', 'Run diagonally behind the full back'),
    (4, 'Winger', 'Hold width to receive the switch')
) AS v(so, role, job);

-- 22. pp.86-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 9: Creating at Least 3 Passing Options for the Man in Possession', 'Three passing options near the touchline',
    'Near the sideline it is easy for the opponent to trap Barca, so team-mates around the ball form triangles and diamonds to give the man on the ball at least three options. When the flank cannot be broken they use those options to circulate the ball elsewhere.',
    'Ball played to the full back near the touchline with the flank crowded',
    'Keep the ball under pressure and move it to another area that better suits entering the third stage of attack, often by a diagonal switch.',
    NULL, 86, 91, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back with ball (22)', 'Keep head up and choose among at least three options'),
    (2, 'Winger and attacking mid (7, 8)', 'Form a triangle ahead and inside of the ball'),
    (3, 'Defensive mid (16) and centre back (5)', 'Offer back and inside support to restart the circulation'),
    (4, 'All supporting players', 'Keep moving into lanes, open up, receive on the back foot')
) AS v(so, role, job);

-- 23. pp.92-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 10: Receiving in Behind the Midfield Line and Approaching the Third Stage of Attack', 'Receive between the lines, turn, final pass',
    'Forwards or midfielders drop at the right moment into the space behind the opposition midfield line to receive unmarked from the deep midfielder or centre back.',
    'Free passing lane opens through the opposition midfield line',
    'The receiver turns towards goal with several options and plays the final pass in behind (or in front of) the back line.',
    NULL, 92, 99, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Busquets 16)', 'Receive facing forward and pass through the midfield line'),
    (2, 'Forwards / attacking mids (7, 8, 10)', 'Drop behind the midfield line on time, receive on the turn'),
    (3, 'Wide players and runners', 'Offer three options for the final pass after the turn'),
    (4, 'Centre backs', 'Feed the deep midfielder or pass through directly')
) AS v(so, role, job);

-- 24. pp.100-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 11: Breaking Through the Opposition''s Pressing in the First Stage of Attack Using 2 Players at the Back', 'Holding mid drops in, find free man',
    'Short build-up from the goalkeeper against a high press: the defensive midfielder drops between the centre backs, the centre backs split to the touchlines and the full backs push high. Against two forwards this gives a 3v2 and the dropping midfielder is the first-phase free player; if an opposition midfielder jumps on him, the next midfielder (Xavi) becomes free and receives via Messi dropping deep.',
    'Opponent presses high with two forwards',
    'Always a free player to receive from the goalkeeper and a second free player once the press shifts, so the ball breaks the first line on the ground.',
    NULL, 100, 110, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Busquets 16)', 'Drop between the centre backs and be the first free player'),
    (2, 'Centre backs (3, 5)', 'Split wide towards the touchlines'),
    (3, 'Full backs (2, 22)', 'Push into advanced positions'),
    (4, 'Central midfielder (Xavi 6)', 'Become second-phase free man when his marker presses 16'),
    (5, 'Number 10 (Messi)', 'Drop deeper to add a midfield extra man and act as link'),
    (6, 'Goalkeeper', 'Start with short passes to the free player')
) AS v(so, role, job);

-- 25. pp.101-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 11: Breaking Through the Opposition''s Pressing in the First Stage of Attack Using 2 Players at the Back', 'Wide centre back free versus three forwards',
    'Against three forwards (or pressure directly on the keeper) the dropping midfielder is covered, so a wide centre back becomes the first-phase free player; when the opposition winger steps out to him, the advanced full back becomes the second-phase free player, reached through a link player.',
    'Opposition winger leaves the full back to press the centre back',
    'Ball reaches the free full back near the touchline, often creating a 2v1 to carry the ball over halfway.',
    NULL, 101, 110, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back (Pique 3 / Puyol 5)', 'First free player receiving from the goalkeeper'),
    (2, 'Full back (Alves 2 / Abidal 22)', 'Push high to pull the winger, then be the second free player'),
    (3, 'Winger (17)', 'Act as link player to the full back'),
    (4, 'Goalkeeper', 'Read who is free and pass to him')
) AS v(so, role, job);

-- 26. pp.103-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 11: Breaking Through the Opposition''s Pressing in the First Stage of Attack Using 2 Players at the Back', 'Link player when free man is blocked',
    'When the direct pass to the free player is cut off, a nearby midfielder (Xavi 6 or Messi 10) moves into the passing lane to become the ''link player'' who bounces the ball on to the free man, usually with one touch.',
    'Ball carrier under pressure with direct lane to free man shut',
    'Get the ball to the free player in two passes instead of losing it or going long.',
    NULL, 103, 110, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Link player (Xavi 6 / Messi 10)', 'Step into the lane, open body, pass on with the back foot'),
    (2, 'Free player (Iniesta 8 / full back)', 'Stay free of marking and receive from the link'),
    (3, 'Ball carrier (Busquets 16)', 'Play the link when the direct ball is blocked')
) AS v(so, role, job);

-- 27. pp.111-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 12: Breaking Through the Opposition''s Pressing in the First Stage of Attack Using 3 Players at the Back', 'Three-man back line, midfielder as free man',
    'The right back (Alves) advances into midfield and the other three defenders form a trio, which makes it hard to press high. The defensive midfielder drops a few yards and is usually free; if marked, one of the two attacking midfielders stays free and Messi dropping deep becomes the link player.',
    'Opposition forwards press close to the box with midfielders pushed up on 6 and 16',
    'Extra numbers in midfield guarantee a free man and break the press on the ground.',
    NULL, 111, 114, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Alves 2)', 'Push into an advanced midfield position'),
    (2, 'Three defenders (3, 5, 22)', 'Form the back trio and start play'),
    (3, 'Defensive midfielder (16)', 'Drop a few yards, be the free player most of the time'),
    (4, 'Attacking midfielders (Iniesta 8, Xavi 6)', 'Stay free when 16 is marked'),
    (5, 'Number 10 (Messi)', 'Drop deeper to act as link player')
) AS v(so, role, job);

-- 28. pp.115-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 13: Building Up Play on the Right Flank Using a 3 Man Defence', 'Right flank rotation, full back exploits space',
    'With three at the back, the right back is free to play high. He and the right winger rotate: the full back drops while the winger runs forward, the opposing full back follows the winger, and the flank space opens for the full back after a combination via centre back, winger and central midfielder.',
    'Opposing full back follows the winger''s forward run',
    'Full back receives on the flank with space; flank zones are built to give a 4v3 (centre back, full back, attacking mid, forward).',
    NULL, 115, 121, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Alves 2)', 'Drop to start the rotation, then attack the opened space'),
    (2, 'Right winger (Pedro 17)', 'Run forward to drag the opposing full back'),
    (3, 'Central midfielder (Xavi 6)', 'Combine to release the full back'),
    (4, 'Right centre back (Pique 3)', 'Start the combination from the back')
) AS v(so, role, job);

-- 29. pp.122-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 14: Switching Play', 'One-touch central switch to weak side',
    'When the flank is crowded, the full back gets three options and plays back to the centre back; the ball is then switched across through a quick, mostly one-touch combination between the central midfielders to the weak-side full back.',
    'Many opponents massed on the ball side, flank attack blocked',
    'Reach the far full back in space before the opponent can shift across.',
    NULL, 122, 124, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (22)', 'Recycle to the centre back when the flank is closed'),
    (2, 'Central midfielders (16, 10, 6)', 'Keep moving and switch the ball with one-touch passes'),
    (3, 'Weak-side full back (Alves 2)', 'Stay wide and high to receive the switch'),
    (4, 'Centre back (5)', 'Feed the central combination')
) AS v(so, role, job);

-- 30. pp.125-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 14: Switching Play (practices)', 'Switching play side to side via width',
    'Team keeps the ball on one side, completes a couple of passes inside to drag the block, then moves it to the far wide player, ideally in 2-3 consecutive switches.',
    'Opponent has shifted and crowded the ball side',
    'Ball arrives on the weak side where there is time and space to attack.',
    NULL, 125, 127, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Keep moving, receive half-turned to see the far side before the switch'),
    (2, 'Weak-side full back', 'Hold width in the wide channel, receive the switch and attack the space'),
    (3, 'Wingers / wide outlets', 'Stretch the pitch to give a switch target'),
    (4, 'Whole team', 'Keep shape and balance while the ball travels')
) AS v(so, role, job);

-- 31. pp.128-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 15: Switching Play Towards the Flanks Using Long Balls', 'Long diagonal to the flank vs compact block',
    'Against a narrow, compact opponent packed around the ball zone, a midfielder (e.g. 6) hits a long ball to the far winger or advanced full back who holds width; the near full back then pushes on to make a 2v1 on that flank.',
    'Opponent compact and crowded around the ball zone',
    'Ball reaches the flank before the defence can slide across, creating a 2v1 wide.',
    NULL, 128, 133, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive / central midfielder (6)', 'Read the compact block and play an accurate long diagonal'),
    (2, 'Far winger (7)', 'Stay wide to give width as the switch target'),
    (3, 'Same-side full back (22)', 'Use the ball''s travel time to push forward and overlap for a 2v1'),
    (4, 'Weak-side full back', 'Wait wide for the switch, then rejoin after passing on')
) AS v(so, role, job);

-- 32. pp.135-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 16: Winger & Attacking Midfielder - Decision Making in the Final Third (Situation 1)', 'Winger drops, full back pushes up',
    'Winger comes short to receive while his full back moves forward in a coordinated move; the opposing full back does not follow for fear of leaving space behind, so the winger gets the ball free.',
    'Ball played past the opponent''s midfield line to the dropping winger',
    'Winger turns facing goal with two options: through ball inside or release to the overlapping full back.',
    NULL, 135, 137, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (7)', 'Drop off the full back, receive half-turned and turn to face goal'),
    (2, 'Full back (22)', 'Move forward in sync into the flank space vacated'),
    (3, 'Attacking midfielder (8)', 'Offer the inside option behind the defence'),
    (4, 'Centre midfielder (16/6)', 'Play the forward pass to the dropping man')
) AS v(so, role, job);

-- 33. pp.135-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 16: Winger & Attacking Midfielder - Decision Making in the Final Third (Situation 2)', 'Attacking midfielder free behind midfield line',
    'The attacking midfielder slips in behind the midfield line; the centre back stays put because stepping out would open space for 10 or 7, so 8 receives unmarked.',
    'Centre back declines to step out on the 8',
    '8 turns and either slides 7 in behind or finds the full back in the free flank space.',
    NULL, 135, 137, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (8)', 'Find the pocket behind midfield line, receive and turn'),
    (2, 'Winger (7)', 'Run in behind as option one'),
    (3, 'Full back (22)', 'Exploit flank space opened by 7 as option two'),
    (4, 'Centre forward (10)', 'Pin the centre back so he cannot step out')
) AS v(so, role, job);

-- 34. pp.139-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 17: Winger & Attacking Midfielder - Creating a Numerical Advantage on the Flank (Situation 3)', 'Pass wide then diagonal run behind full back',
    'Attacking midfielder receives behind the midfield line, passes to the winger standing near the touchline, then runs diagonally behind the opposing full back.',
    'Winger receives wide with the full back engaged',
    '2v1 against the full back high on the flank, winger slips 8 in behind for a cross or shot.',
    NULL, 139, 141, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (8)', 'Pass to winger, then diagonal run behind the full back'),
    (2, 'Winger (7)', 'Hold the touchline, receive, play 8 in behind or go himself'),
    (3, 'Centre midfielder (16)', 'Feed 8 between the lines')
) AS v(so, role, job);

-- 35. pp.139-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 17: Winger & Attacking Midfielder - Creating a Numerical Advantage on the Flank (Situation 4)', 'Attacking midfielder overlaps the high winger',
    '8 gives to the winger high on the flank and immediately overlaps outside him, making another 2v1 on the full back.',
    'Pass into the high winger',
    'Ball carrier has two options: play the overlapper wide or cut inside.',
    NULL, 139, 141, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (8)', 'Pass and overlap straight away'),
    (2, 'Winger (7)', 'Drive inside or release the overlap for a low cross'),
    (3, 'Centre forward', 'Attack the box for the cutback')
) AS v(so, role, job);

-- 36. pp.142-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 18: Winger & Attacking Midfielder - Create and Attack the Free Space (Situation 5)', 'Midfielder drops, winger attacks central gap',
    'Attacking midfielder drops deep behind the midfield line and drags the centre back with him, leaving a hole in the middle of the back line.',
    'Centre back follows the dropping 8',
    'Winger runs inside into the vacated central gap and receives in behind.',
    NULL, 142, 146, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (8)', 'Drop to drag the centre back out, lay the ball on'),
    (2, 'Winger (7)', 'Time the run inside into the gap left by the centre back'),
    (3, 'Centre midfielder (16/6)', 'Play the ball into the space created')
) AS v(so, role, job);

-- 37. pp.143-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 18: Winger & Attacking Midfielder - Create and Attack the Free Space (Situation 6)', 'Winger drops, midfielder attacks behind full back',
    'Winger drops to receive and the opposing full back follows him, opening space on the flank behind that full back.',
    'Full back follows the dropping winger',
    'Attacking midfielder runs into the space behind the full back, receives the long ball and finishes or crosses.',
    NULL, 143, 146, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (7)', 'Drop to pull the full back out'),
    (2, 'Attacking midfielder (8)', 'Run outside into the space behind the full back'),
    (3, 'Centre midfielder (16)', 'Play the ball in behind for 8')
) AS v(so, role, job);

-- 38. pp.147-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 19: Overloading the Side in the Third Stage of Attack (Situation 7)', 'Overload: overlap plus second midfielder joins',
    '8 receives from the left back, gives to the winger and overlaps; the winger dribbles inside while the other midfielder (6) shifts across to overload the side.',
    'Winger cuts inside after 8''s overlap',
    'Winger chooses between the overlapping 8 on the flank and combining with 6 who has joined the strong side.',
    NULL, 147, 152, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (22)', 'Feed 8 between the lines'),
    (2, 'Attacking midfielder (8)', 'Pass to the winger and overlap'),
    (3, 'Winger (7)', 'Dribble inside and pick the option'),
    (4, 'Second attacking midfielder (6)', 'Move across to overload the ball side as extra option')
) AS v(so, role, job);

-- 39. pp.147-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 19: Overloading the Side in the Third Stage of Attack (Situation 8)', 'Winger cuts in, third man through',
    'Winger drops, receives and dribbles inside; 8 makes a forward run while 6 moves to the strong side to offer a passing option.',
    'Winger dribbling inside draws defenders',
    'Ball goes to 6, who slides 8 through on goal (third-man run).',
    NULL, 147, 152, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (7)', 'Drop, receive, carry inside'),
    (2, 'Attacking midfielder (8)', 'Forward run in behind as the third man'),
    (3, 'Second attacking midfielder (6)', 'Arrive on the strong side, play the through ball')
) AS v(so, role, job);

-- 40. pp.153-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 20: Winger, Full Back & Attacking Midfielder - Create and Attack the Free Space on the Flank (Situation 9)', 'Winger drops, full back goes in behind',
    'Winger drops while his full back pushes forward in a coordinated move; the opposing full back follows the winger, opening the flank.',
    'Opposing full back tracks the dropping winger',
    'Full back receives in behind on the flank via a pass from the central striker (10) and crosses low.',
    NULL, 153, 158, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (7)', 'Drop to pull the opposing full back out, lay off'),
    (2, 'Full back (22)', 'Sprint forward into the freed flank space'),
    (3, 'Centre forward / Messi (10)', 'Play the full back in behind'),
    (4, 'Centre midfielder (16)', 'Start the move into the winger')
) AS v(so, role, job);

-- 41. pp.153-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 20: Winger, Full Back & Attacking Midfielder - Create and Attack the Free Space on the Flank (Situation 10)', 'Winger cuts in, slips overlapping full back',
    'Same coordinated drop and push-up, but this time the winger receives, dribbles inside and passes directly to the full back running into the free space.',
    'Winger has turned and carried inside',
    'Full back gets the ball in behind on the flank for a cross.',
    NULL, 153, 158, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (7)', 'Receive, turn with directional first touch, carry inside, release'),
    (2, 'Full back (22)', 'Time the forward run into the flank space'),
    (3, 'Attackers in the box', 'Arrive for the low cross')
) AS v(so, role, job);

-- 42. pp.159-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 21: Retaining Balance During the Attacking Phase Using a 2 Man Defence', 'Busquets drops for carrying centre back',
    'Building with two centre backs, when one of them carries the ball forward the defensive midfielder drops into his vacated spot.',
    'Centre back steps forward with the ball',
    'Back line keeps its numbers and superiority, ready if the ball is lost.',
    NULL, 159, 164, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-carrying centre back (5)', 'Dribble into midfield, pass, then return when covered position is free'),
    (2, 'Defensive midfielder (Busquets 16)', 'Drop back into the centre back''s slot as soon as he moves'),
    (3, 'Other centre back (3)', 'Stay back and keep the 2v1 vs the striker'),
    (4, 'Centre midfielder (6)', 'Drop to fill 16''s position')
) AS v(so, role, job);

-- 43. pp.165-170
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 22: Retaining Balance During the Attacking Phase Using a 3 Man Defence', 'Cover a carrying centre back in a back three',
    'With a three-man back line (full back 22 tucked in as third centre back), when a centre back such as Pique carries forward, Busquets drops to take his place.',
    'One of the back three steps forward with the ball',
    'Superiority at the back (e.g. 3v2) kept for a possible negative transition while the carrier joins the attack.',
    NULL, 165, 170, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Pique 3)', 'Carry forward into midfield, then get back'),
    (2, 'Defensive midfielder (Busquets 16)', 'Drop into the vacated slot'),
    (3, 'Tucked full back (22)', 'Act as third centre back'),
    (4, 'Remaining defenders', 'Keep numbers versus the opposing forwards')
) AS v(so, role, job);

-- 44. pp.171-175
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 23: Retaining Balance - The Defensive Midfielder''s Role', 'Defensive midfielder sets rest-defence numbers',
    'When building with 2 at the back against 2 forwards, 16 stays close to the defenders to make 3v2; with 3 at the back he can play higher since 3v2 already exists. If a forward drifts into midfield 16 follows to keep equality there and +1 at the back. Drill notes: higher vs a 4-2-3-1 lone striker than vs a 4-4-2 (opponent shape varies, so vs null).',
    'Number of opposing forwards relative to our back line',
    'Always a man over at the back so the team can react straight away after losing the ball.',
    NULL, 171, 175, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (16)', 'Position to give +1 at the back; follow a forward who leaves the back zone'),
    (2, 'Centre backs', 'Hold the last line against the forwards'),
    (3, 'Centre back (when both forwards push into midfield)', 'Step up with 16 to keep equality in midfield')
) AS v(so, role, job);

-- 45. pp.172-175
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'to_defend', 'Attacking Tactical Situation 23: Retaining Balance - The Defensive Midfielder''s Role (Situations 1-2)', 'Safety player and pivot close down on loss',
    'When the ball is lost in the build-up, the nearest safety player (8) closes the ball, the defensive midfielder and a centre back squeeze the receiver, and the other centre back covers. With a back three, 16 steps forward to press because 3v2 already exists behind; the remaining defenders mark the forwards and one covers.',
    'Possession lost in midfield or build-up',
    'Ball carrier pressed immediately with cover behind, regain quickly.',
    NULL, 172, 175, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Safety player (8)', 'Close the new ball carrier at once'),
    (2, 'Defensive midfielder (16)', 'Press the receiver (or step forward when there is a back three)'),
    (3, 'Near centre back (5)', 'Squeeze the receiver with 16, or cover'),
    (4, 'Far centre back / tucked full back (3, 22)', 'Mark the forwards, take a covering position')
) AS v(so, role, job);

-- 46. pp.177-180
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'in_possession', 'Attacking Tactical Situation 24: Retaining Balance - The Full Back''s Role', 'Full back timing and attacking midfielder cover',
    'Full backs stay in balanced positions in the build-up so they can defend their man if the ball is lost; one goes forward only when possession is clearly secure, and then an attacking midfielder (e.g. 6) slides across to cover. The other full back stays balanced.',
    'Team in clear possession and space ahead of the full back',
    'Full back joins to create a 2v1 or 4v4 overload while defensive balance is kept.',
    NULL, 177, 180, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advancing full back (2)', 'Wait for the right moment, then attack free space; run back quickly once done'),
    (2, 'Attacking midfielder (6)', 'Drop into covering position behind the advanced full back; press first if ball lost'),
    (3, 'Opposite full back (22)', 'Stay in a balanced defensive position'),
    (4, 'Winger (17)', 'Move inside to open the flank for the full back')
) AS v(so, role, job);

-- 47. pp.181-186
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'to_defend', 'Attacking Tactical Situation 25: The Negative Transition', 'Safety player plus 5-second counter-press',
    'There is always a safety player near the ball zone; when the ball is lost he closes the new carrier at once, cutting his time and space, while everyone else reacts and moves toward the ball zone.',
    'Loss of possession',
    'Regain the ball within about 5 seconds before the opponent can break or settle.',
    NULL, 181, 186, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Safety player (e.g. 6)', 'Sit near the ball zone; close down the new ball carrier immediately'),
    (2, 'Nearby midfielders and forwards', 'Collapse toward the ball zone to box in the carrier'),
    (3, 'Defenders', 'Step up and keep balance behind the pressure'),
    (4, 'All players', 'Take part; no one switches off after losing it')
) AS v(so, role, job);

-- 48. pp.188-191
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'to_attack', 'Attacking Tactical Situation 26: The Positive Transition (Situation 1)', 'Wide regain with overload: attack same flank',
    'Ball won near the touchline where Barca have more players than the opponent; the beaten wide midfielder leaves a 2v1 behind him.',
    'Regain near sideline with numerical superiority',
    'Get the winger free in space high on that flank immediately.',
    NULL, 188, 191, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-winning full back (22)', 'wins it and plays straight to the winger or via the 10'),
    (2, 'Ball-side winger (7)', 'runs into the free space down the flank'),
    (3, 'Centre forward (10)', 'offers a supporting option to bounce the ball to the winger')
) AS v(so, role, job);

-- 49. pp.188-193
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'to_attack', 'Attacking Tactical Situation 26: The Positive Transition (Situation 2)', 'Wide regain, no overload: go inside',
    'Ball won near the sideline but the winger is only 1v1 with the opposing full back, so the flank is closed.',
    'Regain near sideline without superiority',
    'Move the ball into the big central gap (or switch) where the receiver has several options including a shot.',
    NULL, 188, 193, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (7)', 'in a 1v1, plays the ball inside instead of forcing the flank'),
    (2, 'Centre forward (10)', 'drops in as the central passing option and then picks a pass or shoots'),
    (3, 'Central midfielders', 'provide angles in the middle so the switch can be made')
) AS v(so, role, job);

-- 50. pp.188-195
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'to_attack', 'Attacking Tactical Situation 26: The Positive Transition (Situation 3)', 'Central regain: 10 receives, wingers cut inside',
    'Ball won in the centre, e.g. from a goalkeeper''s long ball.',
    'Regain in central area',
    'Play forward at once to the 10 on the half turn, who feeds diagonal runs from the wingers or shoots.',
    NULL, 188, 195, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (10)', 'drops to give an immediate forward option, receives half-turned'),
    (2, 'Wingers (7, 17)', 'time diagonal runs inside behind the line'),
    (3, 'Ball winner (midfielder)', 'looks forward first, quick pass to the 10')
) AS v(so, role, job);

-- 51. pp.189-197
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'to_attack', 'Attacking Tactical Situation 26: The Positive Transition (Situation 4)', 'Central regain, no forward pass: full back flies wide',
    'Defensive midfielder wins the ball centrally but pressure blocks every forward pass.',
    'Regain in centre with forward lanes closed',
    'Release the ball wide to a full back who drives forward into a potential 2v1 on the flank.',
    NULL, 189, 197, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (16)', 'wins it and plays out to the wide full back'),
    (2, 'Full back (22)', 'reacts instantly to give width, then carries forward to exploit the 2v1'),
    (3, 'Winger', 'combines with the overlapping full back')
) AS v(so, role, job);

-- 52. pp.189-198
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'to_attack', 'Attacking Tactical Situation 26: The Positive Transition (Analysis + Progression)', 'Read the regain spot, attack within seconds',
    'General rule: Barca forced the ball wide when defending so regains happened there; on winning it the side read where they were and where the space was.',
    'Any regain',
    'Attack the free space with a quick break inside about 6-8 seconds, flank if overloaded, centre if not, else wide via full backs.',
    NULL, 189, 198, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All players near the ball', 'move into free space and give correct passing angles at once'),
    (2, 'Full backs', 'react quickly to provide width as the fallback outlet'),
    (3, 'Wingers', 'diagonal runs when the ball is won centrally')
) AS v(so, role, job);

-- 53. pp.201-204
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'out_of_possession', 'Defending Tactical Situation 1: Chain Reaction of the Midfielders and the Forwards', 'Chain reaction shift, weak side empty',
    'Forwards and midfielders slide across together as one unit according to the ball''s position, each with a set task.',
    'Opponent''s ball moves to one side (pass into a wide channel)',
    'Stay compact with short distances, create a strong side and abandon the far side so no switch or forward pass is on.',
    NULL, 201, 204, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (10)', 'curved press on the centre back, body shape cuts off the switch'),
    (2, 'Attacking midfielders (8, 6)', 'mark tightly the opponents near the ball zone'),
    (3, 'Ball-side winger (7)', 'blocks forward passes and controls the opposing full back, tracks his runs'),
    (4, 'Weak-side players', 'shift in within about 3 seconds and leave the far channel unoccupied')
) AS v(so, role, job);

-- 54. pp.206-208
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'out_of_possession', 'Defending Tactical Situation 2: Cohesion Between the Back 4 and the Defensive Midfielder', 'Busquets screen: DM fills back-four gaps',
    'Defensive midfielder stays close in front of the back four while the line shifts and a full back steps out to press.',
    'Full back steps up on a pass travelling to his man',
    'Keep a numerical edge at the back; markers switch quickly and the DM plugs any gap, dropping into the centre-back slot if needed.',
    NULL, 206, 208, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (2)', 'steps up on the transmission pass to press the receiver'),
    (2, 'Centre backs (5, 3)', 'slide across and swap marks (5 to the 9, 3 to the winger)'),
    (3, 'Defensive midfielder (16, Busquets)', 'drops close to the line, fills gaps, becomes a centre back if distances get big'),
    (4, 'Back line', 'use offside line when the DM is pushed higher')
) AS v(so, role, job);

-- 55. pp.208-209
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'out_of_possession', 'Defending Tactical Situation 2: Cohesion Between the Back 4 and the Defensive Midfielder (practices 2-3)', 'Full back press-or-hold timing rule',
    'Pressing near the touchline in the first phase of the opponent''s build-up, opposing full back about to receive.',
    'Pass going to the opposing full back',
    'Full back only jumps if he can arrive in time; otherwise the line drops and a midfielder closes the full back.',
    NULL, 208, 209, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Our full back', 'presses the opposing full back if timing is good; if late, holds and drops with the line'),
    (2, 'Attacking midfielder / DM', 'closes down the opposing full back when our full back holds'),
    (3, 'Back four', 'drop together to buy time, communicate so the DM reads it')
) AS v(so, role, job);

-- 56. pp.211-216
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'out_of_possession', 'Defending Tactical Situation 3: Pressing High up the Pitch and Forcing the Ball Wide', 'Force it wide, then double-team',
    'High press near the opponent''s box steers the ball to the touchline where winning it is easier.',
    'Ball played wide to the opposing winger by the line',
    'Block every inside option, prevent the switch, create superiority and double mark the receiver to win the ball.',
    NULL, 211, 216, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (10)', 'presses the centre back first with a body shape that shuts the switch'),
    (2, 'Ball-side winger (7) + full back (22)', 'double mark the wide receiver'),
    (3, 'Defensive midfielder (16)', 'moves toward the ball zone for numbers'),
    (4, 'Central midfielders (8, 6)', 'block forward passes from the centre backs; variant: attacking mid makes the first press while striker sits on the other side')
) AS v(so, role, job);

-- 57. pp.218-221
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'out_of_possession', 'Defending Tactical Situation 4: The Winger Puts Pressure on the Centre Back to Prevent the Pass Towards the Advanced Full Back', 'Winger presses centre back, blocks full back',
    'High press with the striker stranded on the weak side; goalkeeper plays to the near centre back while the opposing full back is pushed high.',
    'Keeper''s pass to the centre back on the side away from our striker',
    'Deny time and the forward pass by having the winger jump the centre back while cutting the lane to the advanced full back.',
    NULL, 218, 221, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger (17, Pedro)', 'presses the centre back on the transmission pass, curved run blocks the pass to the full back'),
    (2, 'Central midfielder (6, Xavi)', 'marks the nearby midfielder so he cannot receive and feed the full back'),
    (3, 'Centre forward (10, Messi)', 'stays near the midfielders to double mark when the ball is forced inside'),
    (4, 'Defensive midfielder (16)', 'covers centrally for superiority')
) AS v(so, role, job);

-- 58. pp.223-226
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'out_of_possession', 'Defending Tactical Situation 5: Defending Against a Centre Midfielder with Space to Create', 'Open ball centre: block vertical and diagonal lanes',
    'Pressure is impossible and an opposing central midfielder has time and space to drive forward through the middle.',
    'Open ball in the centre (unpressured midfielder facing forward)',
    'Squeeze toward the centre and cut the most dangerous straight and diagonal passes to the forwards, pushing play wide.',
    NULL, 223, 226, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'move toward the centre to close passing lanes rather than charge the ball'),
    (2, 'Defenders', 'drop and follow the forwards'' runs while the ball is open'),
    (3, 'Centre forward', 'shifts with the ball, helps screen from the front'),
    (4, 'Wide players', 'tuck in, then press when the ball goes toward the touchline')
) AS v(so, role, job);

-- 59. pp.228-231
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'out_of_possession', 'Defending Tactical Situation 6: Cohesive Reactions When the Opposition Create Space Down the Flank to Attack', 'Open ball flank: drop, close, step up',
    'Opposing full back has time and space near the touchline; Barca''s line reacts to whether the ball is open or closed.',
    'Open ball wide (drop); closed ball once the carrier is pressured or turned (step up)',
    'Buy time for midfielders to shift and close the carrier, keep the ball by the line, then push up to restore compactness.',
    NULL, 228, 231, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'drop while the ball is open, then step forward together the moment it is closed'),
    (2, 'Attacking midfielder (or DM if the full back is higher)', 'shifts out and closes the ball carrier, forcing him to turn back'),
    (3, 'Ball-side winger', 'lets the full back come, then helps block inside passes'),
    (4, 'Whole team', 'block passes toward the inside so the carrier has no central option')
) AS v(so, role, job);

-- 60. pp.233-236
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'out_of_possession', 'Defending Tactical Situation 7: Defending a Switch of Play to the Weak Side', 'Weak-side switch: winger tracks, swap marks',
    'Opponent switches with a long ball to Barca''s empty weak side where their full back overlaps.',
    'Long switch to the weak side',
    'Stop a 2v1 on the flank and fill the box with numbers to deal with the cross.',
    NULL, 233, 236, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side winger (7)', 'pre-positions to control the opposing full back, follows his forward run'),
    (2, 'Weak-side full back (22)', 'engages the ball carrier while the winger picks up the overlapper (marks swap)'),
    (3, 'Defensive midfielder', 'drops into the box to keep superiority against crosses'),
    (4, 'Far centre back (5)', 'no time to slide over, so takes a good box position instead')
) AS v(so, role, job);

-- 61. pp.238-242
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'fc-barcelona-training-sessions-160-practices-from-34-tactical-situations'), 'out_of_possession', 'Defending Tactical Situation 8: Defending Near the Sideline and Close to the Penalty Area', 'Wide near the box: 2v1, fill box',
    'Opposing wide man carries the ball down the touchline near Barca''s penalty area to cross.',
    'Ball carried down the flank toward the box',
    'Double up on the carrier to block the cross and keep extra numbers inside the box.',
    NULL, 238, 242, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (2)', 'contests the carrier; tackles once support has arrived'),
    (2, 'Defensive midfielder (16, Busquets)', 'slides over to make 2v1 near the touchline'),
    (3, 'Ball-side centre back (3)', 'provides the 2v1 instead when the DM is too far away'),
    (4, 'Remaining defenders + DM', 'enter the box and take marking positions to avoid being outnumbered'),
    (5, 'Supporting player', 'calls when he arrives so the full back knows he can go to tackle')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1992-coaching-book-fc-barcelona-training-sessions-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
