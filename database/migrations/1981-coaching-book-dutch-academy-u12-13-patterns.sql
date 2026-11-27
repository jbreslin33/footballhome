-- 1981 📚 Coaching book patterns: "Dutch Academy Football Coaching U12-13" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Dutch Academy Football Coaching U12-13',
    subtitle    = 'Technical and Tactical Practices from Top Dutch Coaches',
    author      = 'DeVoetbalTrainer (Henk Mariman, Han Berger, Louis Coolen)',
    team        = 'Dutch academy 4-3-3',
    method_note = 'A Dutch academy book for U12-13s, the age when players move to 11v11: the team learns the basic 4-3-3 (point-forward midfield triangle, two wingers, a striker) and each position''s job, while individual development stays first. Philosophy and coaching chapters, then 1v1 work, pattern play for 4-3-3 build-up and attacking routes (keeper and centre-back build-up, full-back route with third-man runs, switches, flank 2v1s, box runs for crosses, 9-10 combinations), and a ladder of small-sided positional games from 2v1 to 5v5 with defending duties. Patterns are the team behaviours taught, in our words.'
WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top');

-- 1. pp.11-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Style of Play / Step 4-5 intro (Self Confidence)', 'Dare the 1v1, choose move or pass',
    'Dominance in 1v1 duels is a core style aim: isolated attackers take on their man. In 2v2 the ball carrier must choose between the move and the pass while teammates position themselves as a real option; everyone keeps involved off the ball rather than only when they have it.',
    'Attacker isolated against one defender, or 2v2 near goal',
    'Beat the direct opponent or release the teammate he leaves free.',
    NULL, 11, 25, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Attack the defender with a feint/move; decide between beating him and passing'),
    (2, 'Teammate off the ball', 'Make himself available in a good position for the pass'),
    (3, 'Wingers (7/11)', 'Receive to face the opponent immediately and create chances with individual play')
) AS v(so, role, job);

-- 2. pp.25-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Style of Play', 'Make the pitch big in possession',
    'When we have the ball the team spreads as wide and long as possible: wingers hug the touchline, the striker plays as high as he can, midfield is a triangle with two holders and one attacking midfielder up front.',
    'Team wins or settles possession',
    'Stretch the opponent so many 1v1 situations appear all over the pitch.',
    NULL, 25, 26, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (7/11)', 'Stand as wide as possible near the sideline; give depth with runs behind the back line'),
    (2, 'Centre forward (9)', 'Stay as high as possible; can act as target man'),
    (3, 'Attacking midfielder (10)', 'Position to be available between lines; push on to receive behind the defence'),
    (4, 'Holding midfielders (6/8)', 'Form the base of the point-forward triangle behind the 10')
) AS v(so, role, job);

-- 3. pp.26-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', 'Style of Play', 'Make the pitch small, mark receivers',
    'When the opponent has the ball the team squeezes inwards, the nearest man closes down the ball carrier and the others mark likely receivers of the next pass. At this age players stay with their own man rather than swapping marks (the book deliberately does not teach the switch-over yet).',
    'Opponent gains possession',
    'Remove time and passing options and win the ball back high rather than sitting deep for counters.',
    NULL, 26, 27, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player to ball', 'Close down the ball carrier'),
    (2, 'Players near the ball', 'Mark the potential receivers of the next pass'),
    (3, 'Full backs (2/3)', 'Push inside to shrink the pitch or drop to provide cover'),
    (4, 'All markers', 'Keep your own opponent; no switching of marks yet')
) AS v(so, role, job);

-- 4. pp.26-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Style of Play', 'Both centre backs step into midfield',
    'Basic 4-3-3 where neither centre back is a pure stopper; both are taught to carry or push up through the centre into midfield to build up, instead of one man-marker and one ball player.',
    'Our centre back has the ball with space in front',
    'Extra man in midfield and a controlled, targeted build-up from the back.',
    NULL, 26, 31, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (4/5)', 'Dribble up into midfield with ball close, push up without ball too; play the final pass from midfield'),
    (2, 'Other centre back', 'Read when to push up and when to stay and provide cover'),
    (3, 'Goalkeeper (1)', 'Be available for the back pass and restart with a short throw or pass to keep the build-up going'),
    (4, 'Centre midfielders (6/8)', 'Call for the ball as soon as defenders have it; combine or dribble to continue')
) AS v(so, role, job);

-- 5. pp.27-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', 'Style of Play', 'Press on the side, force outside',
    'Pressure is aimed at steering the opponent towards one flank: show him outside, block the ball in behind, and let the central players step forward.',
    'Opponent builds up / ball carrier faces our block',
    'Trap the opponent near the touchline and deny the dangerous pass behind our line.',
    NULL, 27, 27, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Presser on ball', 'Angle the run to force the opponent towards the sideline'),
    (2, 'Back line', 'Prevent the pass in behind'),
    (3, 'Central players', 'Push forward through the middle to stay compact'),
    (4, 'Centre midfielders (6/8)', 'Know when to tuck inside and when to push out towards the sideline')
) AS v(so, role, job);

-- 6. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Requirements for Full Backs', 'Full back joins attack when free',
    'The wing back moves forward when he gets the ball unmarked with space ahead, or wins it in the opponent''s half and has time; he can beat his man and then pass, dribble or combine. Defensively he stays goal-side and blocks crosses.',
    'Full back receives free with space in front, or wins the ball in the opposition half',
    'Add an extra attacker on the flank without leaving the defence exposed.',
    NULL, 30, 30, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (2/3)', 'Carry forward, cut past his opponent, continue with pass, dribble or combination'),
    (2, 'Full back (2/3) when defending', 'Stand between goal and opponent, block the cross, avoid needless slide tackles'),
    (3, 'Centre backs (4/5)', 'Provide cover behind the advancing full back')
) AS v(so, role, job);

-- 7. pp.33-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', 'Requirements for Attacking Midfielders / Wingers / Centre Forwards', 'Front line disrupts opponent build-up',
    'The 10, wingers and striker are expected to disturb the opponent''s build-up, read it early and not get dribbled past; the striker even works 1v2 against the two centre backs.',
    'Opponent defenders or keeper have the ball',
    'Slow or break the opponent''s build-up high up the pitch.',
    NULL, 33, 35, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (9)', 'Disturb the build-up, also alone against both centre backs'),
    (2, 'Wingers (7/11)', 'Disturb the build-up, anticipate, know when to come inside'),
    (3, 'Attacking midfielder (10)', 'Know how and when to push up into the centre to press'),
    (4, 'All front players', 'Do not let the opponent past when pressing')
) AS v(so, role, job);

-- 8. pp.40-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Functional Training of Ball Control (Step 2)', 'Switch play via curved-run midfielder',
    'A full back with no forward option dribbles up and turns back; the holding midfielder or centre back makes a curved run, fakes the back pass, opens up and turns in one touch, then plays forward to the far-side attacking midfielder or winger, or switches straight to the other side.',
    'Ball side has no forward passing option',
    'Shift the point of attack to the free side quickly.',
    NULL, 40, 46, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (2/3)', 'Feint a forward pass, turn back and play an accurate inside-foot pass to the midfielder'),
    (2, 'Holding midfielder / centre back (B)', 'Curved run, keep distance from the full back, open up and turn in one touch, pass forward onto the defender''s blind side or switch'),
    (3, 'Attacking midfielder or winger (C)', 'Shield the ball with body shape, sense the defender, turn or lay off first-time for the midfielder'),
    (4, 'Far-side full back / winger', 'Hold width to receive the switch')
) AS v(so, role, job);

-- 9. pp.48-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Duels with a Passive Defender (Step 3)', 'Midfielder scans, turns, feeds winger',
    'From the centre back''s pass the central midfielder checks off his marker, glances over the shoulder before receiving, turns quickly and passes to the winger, after which the two attack 2v2.',
    'Centre back passes into midfield',
    'Get the ball turned in midfield and attack quickly with the winger.',
    NULL, 48, 48, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (4/5)', 'Firm pass along the ground into the midfielder'),
    (2, 'Centre midfielder (6/8)', 'Move off the marker, look over the shoulder first, turn fast and accelerate, pass to the winger'),
    (3, 'Winger (7/11)', 'Move to receive and attack the goal 2v2 with the midfielder')
) AS v(so, role, job);

-- 10. pp.49-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', '1 v 1 Duels / Technical Training Step 4', 'Lure the defender, then attack the space',
    'Ball carrier facing a defender, often a winger receiving wide, attacks the space with conviction, draws the defender into a chosen position, then accelerates past him with a change of direction, feint or turn, or shields and turns back.',
    'Receiving the ball with one defender to beat',
    'Beat the man and score, or keep the ball when the dribble is too risky.',
    NULL, 49, 96, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacker / winger', 'good first touch, positive attitude, lure defender then accelerate, feint inside/outside'),
    (2, 'Attacker tracked by defender', 'dribble at speed, use body as barrier between defender and ball'),
    (3, 'Support player', 'offer a backward option when the attacker turns back')
) AS v(so, role, job);

-- 11. pp.51-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Technical Training / Passing Practices - receiving principle', 'Check away and receive half-turned',
    'Repeated across all build-up patterns: before receiving, the player moves away as if leaving a marker, then comes diagonally or on a curve and takes the ball on the half-turn, often with the outside of the foot, after looking over his shoulder.',
    'Teammate about to pass to you under (imaginary) marking',
    'Create space and receive facing forward so the next action is forward in one movement.',
    NULL, 51, 67, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving midfielder / defender', 'check away low, accelerate diagonally, scan, open body, receive and turn in one movement'),
    (2, 'Passer', 'pass at the moment the receiver is ready, with weight to his far foot')
) AS v(so, role, job);

-- 12. pp.58-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Passing Practices - Building Up Play from the Goalkeeper Through the Centre Back', 'Keeper to turning centre back, then wide',
    'Keeper has the ball in hand; a centre back peels away diagonally to take it on the half-turn and turns in one touch toward the flank.',
    'Keeper gathers the ball and CB is free to turn',
    'Get the ball out of the keeper''s hands to a full back pushed high and wide, then into the No.10.',
    NULL, 58, 59, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'roll out, pass when the CB is ready to receive'),
    (2, 'Centre back', 'diagonal movement as if leaving a marker, receive half-turned with outside of foot, turn and play the free full back'),
    (3, 'Full backs', 'start wide and push as high as possible'),
    (4, 'No.10 / second striker', 'protect the ball with body shape, good first touch, finish or set back to full back')
) AS v(so, role, job);

-- 13. pp.60-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Passing Practices - Building Up Play from the Back Through the Full Backs', 'Full back route with third-man runs',
    'Centre back passes into the space ahead of the full back; the full back either wall-passes with the centre midfielder and finds the striker, or goes straight to the striker who sets for an onrushing midfielder.',
    'Centre back on the ball with the full back free on the flank',
    'Progress down the flank into the striker and finish via striker turn or a third-man layoff.',
    NULL, 60, 61, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'pass into the space in front of the full back with good weight, organise players ahead'),
    (2, 'Full back', '1-2 with centre midfielder or play straight into the striker'),
    (3, 'Centre midfielder', 'check off the cone, diagonal run, receive half-turned; third-man run onto striker''s layoff'),
    (4, 'Striker', 'do not come to the ball too early, turn and shoot or weight the set-back')
) AS v(so, role, job);

-- 14. pp.62-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Passing Practices - Centre Back Receiving from the Goalkeeper and Building Up Through the Centre', 'Through the centre via No.10 wall pass',
    'Centre back makes a curved run to take the keeper''s pass; with open body he drives the ball into the No.10, who sets it off for the holding midfielder who has moved into a supporting spot.',
    'Keeper''s pass to the open-bodied centre back',
    'Break the first line centrally and let the holding midfielder arrive facing goal to shoot first time.',
    NULL, 62, 63, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'time and weight the pass so the CB can turn in one movement, coach him'),
    (2, 'Centre back', 'receive half-turned with outside of foot, see the space ahead, pass forward to No.10'),
    (3, 'Defensive midfielder (6)', 'first check back to support, then step forward at the right moment'),
    (4, 'No.10 / second striker', 'lay off with outside of foot, weighted for a first-time shot')
) AS v(so, role, job);

-- 15. pp.64-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Passing Practices - Building Up Play from the Back with Various Passing Combinations', 'Keeper build-up, No.10 drops to combine',
    'Two mirrored routes: keeper to centre back who goes wide to the full back, who plays a 1-2 with the dropping No.10; or keeper to the 6, who finds the No.10, who sets wide to the full back checking away from his marker.',
    'Keeper in possession, No.10 dropping off',
    'Use the dropping No.10 as wall to release the full back forward.',
    NULL, 64, 65, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'right moment and weight so receiver turns in one movement'),
    (2, 'Centre back', 'check away, diagonal receive, play wide to full back'),
    (3, 'No.10', 'drop back, combine 1-2 or lay off to the full back'),
    (4, 'Full back', 'check away from cone, then run on to receive and finish')
) AS v(so, role, job);

-- 16. pp.66-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Passing Practices - Building Up Play Through the Centre and Spreading the Ball Out Wide', 'CB layoff, other CB spreads wide',
    'One centre back drops to take the keeper''s pass and lays it back to his partner, who has stepped forward and plays a firm pass out to a centre midfielder in the wide channel.',
    'Keeper passes to the dropping centre back',
    'Shift the ball across the back line and out to a midfielder who turns in one movement and attacks diagonally.',
    NULL, 66, 67, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'roll or throw out at the correct speed'),
    (2, 'First centre back (4)', 'drop, lay off so partner can pass wide first time'),
    (3, 'Second centre back (5)', 'do not rush to the ball, scan the space, play a fast accurate pass wide'),
    (4, 'Centre midfielders (6/8)', 'look over shoulder, receive half-turned, max 2 touches to shoot')
) AS v(so, role, job);

-- 17. pp.68-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Passing Practices - Playing the Ball Along the Defensive Line to Switch the Point of Attack', 'Switch across back four, long ball forward',
    'Right back passes in front of the centre back, who moves into the space and plays across to the left back; the left back checks away, receives and plays a long ball onto the striker''s chest, and the No.10 joins for a 2v1.',
    'Ball moved across the back line to the free far full back',
    'Change the point of attack, go direct to the striker and create a 2v1 with the arriving No.10.',
    NULL, 68, 69, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'pass weighted in front of the centre back'),
    (2, 'Centre back', 'leave the space open then move into it, pass in front of the left back'),
    (3, 'Left back', 'check away from cone, scan, long accurate pass aimed at the forward''s chest'),
    (4, 'Striker', 'receive the long ball'),
    (5, 'No.10', 'join in to make 2v1 against the defender')
) AS v(so, role, job);

-- 18. pp.70-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Passing Practices - Position Specific Flank Play with Attacking Combination, Crossing and Finishing', 'No.10-8-9 combination releases winger',
    'No.10 plays to the right midfielder, who finds the striker; the striker drops and sets for the No.10, who has opened towards the flank and plays the ball wide and high for the winger to run onto and cross. Variant: midfielder goes straight to the winger.',
    'Striker drops off to receive and set back',
    'Release the winger high on the flank behind the full back to cross.',
    NULL, 70, 73, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre midfielder (8)', 'see the space, firm pass to the striker so he can play first time, away from the defender'),
    (2, 'Striker (9)', 'check away from the defender, lay off with outside of foot at a diagonal to the No.10'),
    (3, 'No.10', 'do not join too soon, open body to the flank before receiving, pass into winger''s path'),
    (4, 'Wingers (7/11)', 'keep the space free, do not go too high too early, make the forward run at the right moment')
) AS v(so, role, job);

-- 19. pp.70-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Passing Practices - Crossing and Finishing (flank play sections)', 'Box runs: near, far, cut-back',
    'When the winger reaches the cross, the attackers spread their runs so each one attacks a different zone: striker near post or ahead of the keeper, opposite winger far post, No.10 arriving late for the cut-back.',
    'Winger dribbling to cross position',
    'Fill every finishing zone so the cross always has a target.',
    NULL, 70, 77, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'lose the defender, attack the near post / space in front of keeper'),
    (2, 'Opposite winger (11)', 'timed run to the far post'),
    (3, 'No.10', 'late run behind for the cut-back'),
    (4, 'Crossing winger (7)', 'dribble forward and deliver into the box')
) AS v(so, role, job);

-- 20. pp.74-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Passing Practices - Beating the Full Back in a 2 v 1 on the Flank', '2v1 against the full back',
    'Centre midfielder checks away to take the full back''s pass, then with the winger beats the defender: 1-2 and return to winger beyond, 1-2 to run in behind himself, give to winger to dribble, or give to winger while the full back makes a third-man run behind.',
    'Midfielder receives on the flank facing a lone defender with the winger alongside',
    'Get past the full back and cross for runs into the box.',
    NULL, 74, 75, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (2)', 'accurate pass to the midfielder, coach players ahead; third-man run in behind'),
    (2, 'Centre midfielder (8)', 'check away, receive and dribble forward, draw the defender in before the final pass'),
    (3, 'Winger (7)', 'wall pass or take the defender on immediately, then cross'),
    (4, 'Striker and far winger', 'near-post and far-post runs for the cross')
) AS v(so, role, job);

-- 21. pp.76-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Passing Practices - Switching Play to Change the Point of Attack + Timing Runs into the Box', 'Drag marker, back to 6, diagonal switch',
    'Left midfielder runs forward taking his marker, which frees the passing lane for the left winger to play back to the holding midfielder or centre back, who lofts a slightly lifted ball over to the far winger running into space high on the flank.',
    'Ball-side midfielder''s forward run drags his marker away',
    'Switch the play to the far winger with space to dribble and cross.',
    NULL, 76, 77, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (11)', 'first pass back with correct weight, then attack far post'),
    (2, 'Left centre midfielder (6)', 'run forward to take the marker and free the lane'),
    (3, 'Centre back / defensive midfielder (5)', 'instep pass, lifted only slightly, to the far winger'),
    (4, 'Right winger (7)', 'leave the space high on the flank free, move into it at the right time, dribble and cross')
) AS v(so, role, job);

-- 22. pp.78-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Forward Play: Creating Space, Receiving with Back to Goal / 1 v 1 Receiving with Back to Goal', 'Striker holds off marker and turns',
    'A forward with a defender behind checks away, comes back diagonally, feels the opponent with his arms and keeps his body between ball and defender, then turns away to the open side or sets back.',
    'Pass played into the forward with a defender tight behind',
    'Turn and attack goal, or retain the ball with a layoff when turning is not on.',
    NULL, 78, 79, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'check away, push off the opponent, feel where he is, shield and turn to the free side'),
    (2, 'Passer', 'eye contact, pass away from the defender with enough pace that the defender cannot close in transit'),
    (3, 'Defender behind', 'do not step too far forward, try to get in front and win the ball')
) AS v(so, role, job);

-- 23. pp.79-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', '1 v 1 Duels - pressure from behind', 'Defend the back-to-goal receiver',
    'When the attacker receives with his back to goal, the defender stays close but not too far forward and picks the right moment to step in front and win the ball without fouling.',
    'Pass played into a forward with his back to goal',
    'Prevent the turn and intercept or win the ball cleanly.',
    NULL, 79, 96, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marking defender', 'do not overcommit forward, judge timing to get in front of the attacker, no foul')
) AS v(so, role, job);

-- 24. pp.80-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Forward Play: Receiving with Back to Goal, Target Man Play and Finishing', 'Target man combinations from wide',
    'Wide player feeds a midfielder who finds the deep striker; options are striker turns and shoots, striker plays a 1-2 with the midfielder who shoots, or the wide player sprints to the byline and the striker plays him in to cross back for the striker.',
    'Deep striker receives a pass into feet',
    'Use the target man to set up a shot or an overlap to the byline.',
    NULL, 80, 81, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player (A)', 'pass with outside of foot, keep space near the byline free, attack it at the right moment'),
    (2, 'Midfielder (B)', 'do not run forward too soon, receive with outside of foot, take ball on in one movement'),
    (3, 'Deep striker (C)', 'check away, receive across the body, turn and shoot or combine')
) AS v(so, role, job);

-- 25. pp.82-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Passing Practices - Attacking Combination Play Between the No.10 and the Striker', 'No.10 and striker combine centrally',
    'No.10 checks away to receive, turns and plays a 1-2 with the striker before shooting, or the striker turns himself; when the striker is fed directly he turns or sets it for the No.10.',
    'Ball fed into No.10 or striker in front of the box',
    'Create a central shot through quick 9-10 combination play.',
    NULL, 82, 82, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'check away, receive, combine 1-2 or shoot from the striker''s layoff'),
    (2, 'Striker (9)', 'check away, wall pass, or turn and shoot')
) AS v(so, role, job);

-- 26. pp.86-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'to_attack', '1 v 1 Duels - defender scores on regain', 'Win the duel, counter immediately',
    'In every duel format the defender who wins the ball immediately goes the other way, dribbling or passing to a counter goal (or back to his keeper) rather than just clearing.',
    'Defender wins the ball in a duel',
    'Turn the regain straight into an attack on the opposite goal.',
    NULL, 86, 96, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender who regains', 'turn and attack the counter goal at once, or pass back to keeper to restart')
) AS v(so, role, job);

-- 27. pp.87-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', '1 v 1 Duels - frontal and side pressure', 'Close down fast, show to weaker foot',
    'A defender facing a ball carrier closes him down as early as possible to shrink his space, stands low with bent knees and does not dive in, forcing the attacker onto his weaker foot or away from goal.',
    'Attacker receives facing the defender',
    'Deny the attacker space and time and win the ball without being beaten.',
    NULL, 87, 96, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender', 'close down immediately, push him back, low stance, do not lunge (tackle is last resort), show to weak foot')
) AS v(so, role, job);

-- 28. pp.90-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', '1 v 1 Duel + 1 v 1 Against the Goalkeeper', 'Defender and keeper work together',
    'When an attacker dribbles in on goal, the defender and goalkeeper cooperate: the defender delays and channels while the keeper stays low, one foot ahead, pushes the attacker wide and stays upright until the last moment.',
    'Attacker carrying the ball into the box',
    'Stop the attacker scoring by narrowing angle and forcing him wide.',
    NULL, 90, 91, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender', 'approach from the front, delay and steer the attacker'),
    (2, 'Goalkeeper', 'low, bent knees, one foot ahead, push attacker wide, stay standing until the last moment')
) AS v(so, role, job);

-- 29. pp.95-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'to_defend', '2 Phase 1 v 1 Duel on the Flank with Transition Play', 'Next attacker presses after loss',
    'After the wide attacker loses the 1v1 and the defender breaks out, the second attacker positioned nearby steps forward to confront him, win the ball back and score.',
    'Defender wins the ball from the wide attacker and turns to counter',
    'Stop the counter early and win the ball back for a second attack.',
    NULL, 95, 95, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacker who lost the ball', 'first duel on the flank, then becomes support'),
    (2, 'Second attacker (near counter goal)', 'move forward, press the new ball carrier, regain and score')
) AS v(so, role, job);

-- 30. pp.98-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', '2 v 1 Positional Play', 'Outnumbered defender delays, no diving in',
    'A lone defender faces two attackers. He stays patient, steers the carrier so the second attacker is cut off and only commits when the carrier is isolated.',
    'Defender caught 1v2',
    'Buy time and turn the 2v1 into a 1v1 the defender can win.',
    NULL, 98, 98, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lone defender', 'Approach, slow the carrier, angle to isolate him from the support, never lunge early'),
    (2, 'Ball carrier', 'Commit the defender before releasing')
) AS v(so, role, job);

-- 31. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', '2 v 1 Positional Play', 'Keeper and defender split the attackers',
    'Two attackers against one defender plus goalkeeper near goal. Defender and keeper talk and each takes responsibility for one attacker, so the attackers must choose.',
    '2v1 + GK in or near the box',
    'Force a hurried choice and deny a free tap-in.',
    NULL, 99, 99, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender', 'Mark or screen one attacker, usually the pass option'),
    (2, 'Goalkeeper', 'Cover the ball side / carrier and organise by voice')
) AS v(so, role, job);

-- 32. pp.100-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', '2 v 1 / 3 v 2 / 3 v 3 / 4 v 3 Positional Play', 'Centre backs split wide off the keeper',
    'Building from the goalkeeper, the centre backs separate wide to escape the forward, receive half-turned on the outside foot; the keeper only plays to a free man, chooses the furthest-forward option and stays available for a return.',
    'Keeper has the ball at his feet',
    'Exit the first line cleanly and as far up the pitch as possible.',
    NULL, 100, 126, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Split wide, call for it, receive on the half turn'),
    (2, 'Goalkeeper', 'Pass only to a free man, prefer the highest option, offer back-pass support'),
    (3, 'Two outfield players', 'Pull wide and receive to feet as high as possible')
) AS v(so, role, job);

-- 33. pp.101-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', '2 v 1 / 2 v 2 Positional Play', 'Box movement for the cross',
    'Wide player crosses while the central attacker checks away first, then times his run to near post, far post, in front of keeper or the cut-back spot.',
    'Wide player has time to cross',
    'Arrive late and unmarked for the finish.',
    NULL, 101, 104, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player', 'Hold width, read the runner and defender, pick the cross'),
    (2, 'Central attacker', 'Check away, time the run, offer near/far/cut-back')
) AS v(so, role, job);

-- 34. pp.102-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', '2 v 1 / 2 v 2 / 3 v 2', 'No.10 and striker combination',
    'The No.10 drives at the defender and chooses between taking him on, slipping the striker in space or a 1-2; the striker checks away then moves diagonally, and the two forwards never occupy the same area.',
    'No.10 receives facing goal',
    'Commit the defender into a choice and exploit the run.',
    NULL, 102, 111, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'Commit the defender, pick dribble / pass / wall pass'),
    (2, 'Striker', 'Check away, diagonal run, create space for the partner'),
    (3, 'Supporting midfielder', 'Feed in and join to make 3v1')
) AS v(so, role, job);

-- 35. pp.104-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', '2 v 2 Positional Play', 'Defending the flank and the cross',
    'Attack down the wing with a runner into the box. The wide defender limits the winger to jogging pace and blocks the cross; the central defender stays in contact with the striker.',
    'Ball played forward to the winger',
    'Prevent a clean cross and a free header/finish.',
    NULL, 104, 104, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide defender', 'Show inside/slow down, get body in the crossing line'),
    (2, 'Central defender', 'Keep touch-tight contact with the box runner')
) AS v(so, role, job);

-- 36. pp.105-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', '2 v 2 / 3 v 2 / 5 v 5', 'Check away before showing to receive',
    'A recurring rule: attackers move away from their marker first then come to the ball (often diagonally), never just running straight at the ball.',
    'Teammate about to pass',
    'Receive free of the marker.',
    NULL, 105, 139, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Any receiver', 'Check away, then move into space diagonally'),
    (2, 'Striker', 'Make himself available in space')
) AS v(so, role, job);

-- 37. pp.106-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', '2 v 2 / 3 v 3 / 4 v 3 / 5 v 5', 'Keeper dribbles out to lure a marker',
    'If no teammate is free the goalkeeper carries the ball forward, drawing an opponent onto him and freeing a teammate (2v2 becomes 3v2).',
    'All outfield options marked',
    'Create a spare man in build-up using the keeper.',
    NULL, 106, 139, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Dribble forward, commit a defender, pass to the freed player'),
    (2, 'Outfield players', 'Check away from markers then show to receive')
) AS v(so, role, job);

-- 38. pp.107-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', '2 v 2 / 3 v 2 / 3 v 3 Positional Play', 'Press-and-cover pair, deepest man coaches',
    'When one defender steps out to the ball carrier the partner drops on a diagonal behind him, blocking the pass to the other attacker; the deepest defender talks the others into place. Defenders cover each other''s positions after any switch.',
    'Teammate steps to press the ball',
    'Pressure on the ball with cover behind, no straight-line retreat and no free pass in behind.',
    NULL, 107, 128, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing defender', 'Close the carrier quickly and tight'),
    (2, 'Covering defender', 'Drop diagonally behind, cut the pass to the second attacker'),
    (3, 'Deepest defender', 'Coach / organise the others by voice')
) AS v(so, role, job);

-- 39. pp.113-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', '3 v 2 / 3 v 3 / 4 v 3 / 4 v 4 / 5 v 5', 'Wing play: beat the full back or combine',
    'The ball goes quickly to a moving winger in space away from his defender; he takes his man on and crosses, plays a 1-2 with a support player, or uses an overlapping run from behind; the far winger and striker attack the box.',
    'Winger receives in wide space',
    'Create crossing and cut-back chances from the flank.',
    NULL, 113, 140, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Check away, receive on the move, be positive 1v1'),
    (2, 'Supporting player', 'Offer 1-2 or run in behind'),
    (3, 'Far winger + striker', 'Attack the penalty area'),
    (4, 'Passer', 'Fast ground pass to winger away from his defender')
) AS v(so, role, job);

-- 40. pp.114-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'to_attack', '3 v 2 / 3 v 3 / 4 v 3 Positional Play', 'Win it, pass forward immediately',
    'Defenders who regain the ball pass it at once to teammates higher up, who turn and attack the other goal with a numbers advantage.',
    'Ball won by the defending unit',
    'Fast transition attack before the opponent reorganises.',
    NULL, 114, 129, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Regaining defender', 'Pass forward quickly to the free teammate'),
    (2, 'Forward teammates', 'Show, turn and attack the far goal')
) AS v(so, role, job);

-- 41. pp.116-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', '3 v 3 Positional Play', 'Keep depth versus keeper long ball',
    'When the opposing goalkeeper can hit a long ball forward, the pressing team must not all push up; someone stays behind.',
    'Pressing a goal-kick / keeper build-up',
    'Avoid being bypassed by one long pass.',
    NULL, 116, 131, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing forwards', 'Press the short options'),
    (2, 'Last defender', 'Hold depth to defend the long ball')
) AS v(so, role, job);

-- 42. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'to_defend', '3 v 3 Positional Play', 'Recovery run to restore numbers',
    'After a forward pass beats the midfield, the third defender sprints back to rejoin so the attack is no longer an overload.',
    'Ball passed past him to the wing',
    'Equal numbers again before the attack reaches goal.',
    NULL, 117, 117, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Third defender', 'Track back at full speed'),
    (2, 'First defender', 'Contest the winger'),
    (3, 'Second defender', 'Cover')
) AS v(so, role, job);

-- 43. pp.118-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', '3 v 3 Positional Play', 'Work a shooter free from distance',
    'Players check away from markers and move the ball to set one teammate up for a long-range shot.',
    'Shooting lane opens outside the box',
    'Goals from distance through collective help.',
    NULL, 118, 118, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Shooter', 'Find a pocket of space, strike early'),
    (2, 'Teammates', 'Check away, draw markers, lay it into the shooter')
) AS v(so, role, job);

-- 44. pp.119-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', '3 v 3 / 5 v 4 Positional Play', 'Step forward and press when ball enters zone',
    'Defenders hold until the ball enters their zone, then all move forward together to squeeze and close down the carrier, never backing off; gaps between them stay small.',
    'Ball/pass arrives in the defenders'' zone',
    'Deny the carrier time to lift his head and pick a pass, win it high.',
    NULL, 119, 136, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'Close down the carrier at speed'),
    (2, 'Other defenders', 'Move up together, keep distances short')
) AS v(so, role, job);

-- 45. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', '3 v 3 Positional Play', 'Force attackers wide, shift to ball side',
    'In 3v3 the defending unit slides towards the ball side and shows attackers away from the goal.',
    'Opponent attacks through the middle',
    'Push the play to harmless areas.',
    NULL, 120, 120, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defending trio', 'Shift as a block to the ball side'),
    (2, 'Ball-side defender', 'Show the carrier outside, away from goal')
) AS v(so, role, job);

-- 46. pp.122-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', '4 v 2 / 4 v 3 Positional Play', 'Narrow back line, leave widest attacker',
    'Three defenders against four attackers near their goal stay central and compact, conceding the widest attacker and side-on shuffling as a unit to guard the line.',
    'Defending a numbers-down attack near goal',
    'Protect the central goal area and make the attack go wide and slow.',
    NULL, 122, 123, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three defenders', 'Stay narrow and close together, side-on body shape'),
    (2, 'Goalkeeper', 'Communicate and organise the line'),
    (3, 'Widest attacker (opponent)', 'Left free on purpose')
) AS v(so, role, job);

-- 47. pp.124-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', '4 v 2 / 4 v 3 Positional Play', 'Keep the ball at the back with keeper',
    'Three players plus the goalkeeper keep possession in their own box area against two pressers, using width and the keeper as spare man.',
    'Opponent presses with fewer players',
    'Retain the ball (string passes) and avoid losses near goal.',
    NULL, 124, 124, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Spare man and recycler'),
    (2, 'Back three', 'Spread wide, move to open angles')
) AS v(so, role, job);

-- 48. pp.125-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', '4 v 2 / 4 v 4 Positional Play', 'Long pass to the most advanced player',
    'From the back, the first look is the teammate highest up the pitch; the keeper or defender plays a long accurate pass to him while he moves into space away from his marker; if the striker receives with his back to goal he sets it back for an onrushing teammate.',
    'Highest player free/moving away from marker',
    'Skip lines and attack quickly.',
    NULL, 125, 131, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper / defender', 'Look long first, pass accurately'),
    (2, 'Striker', 'Move into space, receive and lay off to the runner'),
    (3, 'Supporting midfielder', 'Arrive onto the lay-off')
) AS v(so, role, job);

-- 49. pp.128-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', '4 v 3 / 4 v 4 / 5 v 4', 'Front four combination, ball in behind first',
    'Wingers, No.10 and striker combine in and around the box; the man on the ball always looks for the pass behind the defenders to the furthest-forward player, and the No.10 turns or sets back to a joining midfielder depending on his marker.',
    'Ball reaches No.10 or a forward pass goes high up',
    'Fast through-ball chances at high tempo.',
    NULL, 128, 137, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'Turn if free, else lay back to the arriving midfielder'),
    (2, 'Striker (9)', 'Stay high to receive in behind'),
    (3, 'Wingers (7, 11)', 'Offer width and attack the box'),
    (4, 'Centre midfielder (6/8)', 'Join the attack to make 5v4')
) AS v(so, role, job);

-- 50. pp.129-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', '4 v 3 / 4 v 4 Positional Play', 'Midfielder crosses zones as third man',
    'After the pass to the striker, a midfielder (or defender) leaves his zone to join the attack, adding the extra man as a third-man runner.',
    'Ball played into the striker',
    'Turn 3v3 into 4v3 / 4v4 into 5v4 at the front.',
    NULL, 129, 136, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder (6)', 'Run forward past the ball into the attack'),
    (2, 'Striker (9)', 'Hold and release to the runner')
) AS v(so, role, job);

-- 51. pp.134-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', '4 v 4 Positional Play', 'Man-to-man squeeze on every receiver',
    'Each defender takes one attacker and stays tight and moving, anticipating the pass and pressing hardest when the attacker tries to shoot or play to target.',
    'Opponent in possession in midfield',
    'No attacker receives in space; shots under pressure lose accuracy.',
    NULL, 134, 134, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Every defender', 'Pick up one man, stay tight, anticipate'),
    (2, 'Defender of shooter', 'Pressure the strike/pass')
) AS v(so, role, job);

-- 52. pp.136-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'out_of_possession', '5 v 4 Positional Play', 'Block through balls to the striker',
    'Defenders outnumbered in midfield deny the forward pass into the striker behind them by pressure on the ball and small gaps.',
    'Opponent midfield looks for a through ball',
    'Keep the ball in front and win it before it reaches the striker.',
    NULL, 136, 136, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield defenders', 'Pressure the ball, close passing lanes forward'),
    (2, 'Defender on striker', 'Stay goal-side and in contact')
) AS v(so, role, job);

-- 53. pp.141-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u12-13-technical-and-tactical-practices-from-top'), 'in_possession', 'Match Specific 5 v 5', 'Striker shields and plays with back',
    'The striker receiving under pressure puts his body between defender and ball, feels where the defender is and turns or creates a chance.',
    'Pass into striker tightly marked',
    'Keep the ball and create scoring chances from hold-up play.',
    NULL, 141, 141, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'Shield, feel the defender, turn or lay off'),
    (2, 'Supporting players', 'Move to receive the lay-off')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1981-coaching-book-dutch-academy-u12-13-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
