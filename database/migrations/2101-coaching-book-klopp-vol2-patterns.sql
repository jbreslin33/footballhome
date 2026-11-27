-- 2101 📚 Coaching book patterns: "Jürgen Klopp - 80 Attacking Combinations (Vol. 2)" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Jürgen Klopp - 80 Attacking Combinations, Finishing, Positional Patterns of Play, Transition & SSGs',
    subtitle    = 'Direct from Klopp''s Training Sessions (Vol. 2)',
    author      = 'Alex Fitzgerald (ed.)',
    team        = 'Liverpool (Klopp, Pep Lijnders)',
    season      = '2016-2022',
    method_note = 'Practices taken directly from Klopp''s Liverpool training sessions 2016-22 (Stanford pre-season 2016, the AXA Training Centre 2021-22, many run by Pep Lijnders), all built on Liverpool''s 4-3-3. Unopposed or mannequin patterns of play (lofted diagonal switch to the far winger, winger''s cut-back, give-and-go curved runs, lateral third-man runs), multi-ball finishing for non-stop attacking pressure, small-sided and transition games (press the ball and block lanes, sprint back after a finish, fast break in three passes, attack the second ball) and set pieces (throw-ins, signalled corners, wide free kicks). Patterns are the behaviours the practices rehearse, in our words.'
WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra');

-- 1. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Positional Patterns of Play - 1. Central Midfield Combinations, Switch of Play to Winger, Cross & Finish', 'Midfield triangle then aerial switch to winger',
    'Ball circulates through the DM and both central midfielders with a one-two and a wide-and-back pass to draw the block, then a CM lofts it to the far winger running forward.',
    'DM re-receives facing forward after the winger plays back inside',
    'Winger crosses into a box filled by forwards and a late-arriving midfielder at the edge of the area.',
    NULL, 17, 17, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'one-two with RCM, recirculate to LCM, step forward again to re-receive'),
    (2, 'Left winger', 'receive wide, play firm ball back to centre, then attack forward for the switch and cross'),
    (3, 'Right central midfielder', 'aerial switch to far winger, then late run to meet cross near edge of box'),
    (4, 'Centre forward + far winger', 'attack the box for the cross')
) AS v(so, role, job);

-- 2. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Positional Patterns of Play - 2. Double Switch of Play with Lay-offs and Full Back''s Overlap Run', 'Double switch with lay-offs, full-back overlap',
    'Ball goes from right back through DM and LCM out to the left back (first switch); the left winger curves wide, plays back, and LCM switches aerially to the right winger cutting inside.',
    'Right winger receives the switch moving inside off the flank',
    'Winger''s lay-off lets the RCM release the overlapping right back, who combines with the CF set-back to shoot.',
    NULL, 18, 18, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left/right back', 'first-switch receiver on one side, deep overlapping run on the other'),
    (2, 'Left central midfielder', 'open body and play aerial second switch to far winger'),
    (3, 'Right winger', 'come inside to receive, lay off to RCM, vacate the flank for the overlap'),
    (4, 'Right central midfielder', 'through pass for the overlapping full back'),
    (5, 'Centre forward', 'receive in box and set back for the full back''s shot')
) AS v(so, role, job);

-- 3. pp.19-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Positional Patterns of Play - 3. Triple Switch of Play Combinations and Movements + Play into Forward to Shoot', 'Triple switch with inverted full back',
    'Ball is switched three times across the pitch using an inverted left back, winger play-backs and repeated curved re-offering movements by the DM before an advanced central midfielder links with the CF.',
    'DM keeps re-showing after each switch; CM makes advanced run',
    'Move the opponent side to side until a forward pass into the CF lets him turn and shoot from the edge of the box.',
    NULL, 19, 19, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'curved movements to re-receive after each switch and redirect play'),
    (2, 'Left back (inverted)', 'receive inside, feed LCM, re-receive from winger'),
    (3, 'Wingers', 'receive wide, play back inside to keep switching'),
    (4, 'Left central midfielder', 'advanced run, lay off to winger'),
    (5, 'Centre forward', 'open up on receiving and shoot from edge of box')
) AS v(so, role, job);

-- 4. pp.20-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Positional Patterns of Play - 4. Switching Point of Attack in Behind / 9. Playing OVER a High Defensive Line / + Counter-pressing 2. Switch of Play Over the Top', 'Lofted diagonal switch in behind to far winger',
    'Play is concentrated on one side (CF drops to the left, winger drops, LB and LCM combine; or DM carries sideways and RW lays off to RCM) to pull the back line across, then a long lofted pass goes over or behind it to the far-side winger; used vs a high 4-man line.',
    'Opposite winger makes a well-timed run into an advanced position as the ball is set for the passer',
    'Far winger receives in or near the box behind the line and scores, finishes or chips across, with several runners following for rebounds.',
    NULL, 20, 31, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'drop to the ball side to link, then attack the box / follow up rebound'),
    (2, 'Left back + left central midfielder', 'combine on the overloaded side; CM drops, opens up and lofts the switch'),
    (3, 'Right central midfielder', 'alternative switcher after the winger''s lay-off'),
    (4, 'Far-side winger', 'time run behind the line, receive and finish or chip across'),
    (5, 'Other front players', 'make forward runs into the box together with the switch')
) AS v(so, role, job);

-- 5. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Positional Patterns of Play - 5. Switch of Play + Quick Combinations with the Defensive Midfielder Moving Forward to Join the Attack', 'DM joins attack after switch and lay-back',
    'LCM switches to the high right winger, who lays back for the oncoming right back; RB dribbles inside and finds the DM running forward.',
    'Full back dribbles inside after the winger''s lay-back',
    'DM one-two with the CF, then through ball for the winger''s third-man run into the box to score.',
    NULL, 21, 21, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left central midfielder', 'switch play to the high far winger'),
    (2, 'Right winger', 'lay back to RB, then third-man run in behind to finish'),
    (3, 'Right back', 'come onto lay-back, dribble inside, release DM'),
    (4, 'Defensive midfielder', 'timed forward run, one-two with CF, through pass'),
    (5, 'Centre forward', 'wall pass for the DM')
) AS v(so, role, job);

-- 6. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Positional Patterns of Play - 6. Switching Play for Advanced Run of the Full Back into the Box', 'Weak-side full back arrives in box',
    'Play goes right (RCB-RCM-RB) then inside to a forward-moving DM and on to the left winger checking off; LW lays off to the LCM running on.',
    'LCM receives the lay-off facing goal',
    'LCM threads a timed pass into the box for the far-side left back, who crosses to the opposite side where the RW cuts back for the CF.',
    NULL, 22, 22, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'move forward to receive and switch to left winger'),
    (2, 'Left winger', 'check off to receive, lay off, then attack box'),
    (3, 'Left central midfielder', 'through pass for full back''s run'),
    (4, 'Left back', 'advanced run into the box from the weak side, cross to far side'),
    (5, 'Right winger + centre forward', 'RW cuts back across, CF finishes')
) AS v(so, role, job);

-- 7. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Positional Patterns of Play - 7. Winger''s Movement Inside to Create Space for Midfielder''s Through Pass to Full Back on Overlap', 'Winger drops inside, full back overlaps',
    'After CF drops to link to the left and the LB switches to the RCM, the LCM plays a diagonal to the right winger who drops back inside and lays off.',
    'Winger''s inside movement drags his marker and empties the flank',
    'LCM plays in behind for the overlapping right back, who delivers into the box for three runners (CF scores at back post).',
    NULL, 23, 23, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'drop to link, then run into box'),
    (2, 'Right winger', 'drop back and inside, lay off to LCM, then attack box'),
    (3, 'Left central midfielder', 'run onto the ball and pass in behind for the overlap'),
    (4, 'Right back', 'overlap on the outside, deliver into box'),
    (5, 'Left winger', 'run into box for the cross')
) AS v(so, role, job);

-- 8. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Positional Patterns of Play - 8. Playing THROUGH a High Defensive Line and Advanced Runs to Finish the Attack (vs. 4 Defenders)', 'Through pass splitting high line gap',
    'Versus a high back four (10v4), the DM moves ball across to the RCM, who carries forward and slides a pass between the opposite centre back and full back.',
    'Midfielder carries forward unopposed toward the high line',
    'Winger running in behind receives and squares across the box, many runners arrive and the far-side CM scores at back post.',
    NULL, 24, 24, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder', 'drive forward with the ball, split the CB-FB gap'),
    (2, 'Right winger', 'advanced run in behind, square pass across box'),
    (3, 'Left central midfielder', 'late run to back post'),
    (4, 'Centre forward + left winger', 'fill the box')
) AS v(so, role, job);

-- 9. pp.26-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Positional Patterns of Play - 10./11. Maintaining Possession + Quick Reactions to Launch Attack and Score', 'Long circulation, then instant vertical attack',
    'Team circulates the ball in its 4-3-3 roles with typical positional combinations for 20-60 passes (narrow, then full width), then on a cue must switch at once into attack.',
    'Coach''s GO call (in a match: the moment a forward gap appears)',
    'First pass after the cue is penetrating (diagonal through ball to winger inside, or DM into dropping CF) and runners flood the box to finish.',
    NULL, 26, 27, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All outfield players', 'pass at match speed holding positional roles'),
    (2, 'Right central midfielder / defensive midfielder', 'play the first forward pass immediately on the cue'),
    (3, 'Centre forward', 'drop to receive and set a winger'),
    (4, 'Right back', 'advanced overlapping run on the outside and cut-back (full-width version)'),
    (5, 'Wingers', 'attack inside or across the box to finish')
) AS v(so, role, job);

-- 10. pp.30-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'to_defend', 'Attacking Positional Patterns of Play + Counter-pressing 1.-3.', 'Whole-team counter-press on new ball',
    'As soon as an attack ends (or the ball is lost at any moment), all 10 outfield players react to where the new ball is and press toward it.',
    'Loss of ball / attack finished (coach calls Counter-press)',
    'Immediate collective pressure around the ball to win it back right after losing it.',
    NULL, 30, 32, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players nearest the ball', 'sprint to pressure the ball carrier'),
    (2, 'Surrounding midfielders and forwards', 'close in to compact space and passing options around the ball'),
    (3, 'Back line', 'step up and shift toward the ball side'),
    (4, 'All 10 outfield players', 'move together relative to the new ball position')
) AS v(so, role, job);

-- 11. pp.30-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Patterns + Counter-pressing 1. / 2nd-3rd Ball Attacks 1.-2.', 'Winger ground cross for far winger',
    'Ball is moved quickly to an advanced winger (firm diagonal after a DM carry, or via CM lay-off and wide pass, or a DM through ball for a timed run into the box).',
    'Winger reaches the box or byline on the ball',
    'Winger drives into the box and cuts back or plays a ground cross for the opposite winger arriving at the far side, with CF and CM also in the box.',
    NULL, 30, 35, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'carry inside and play firm diagonal / through pass to the winger'),
    (2, 'Central midfielders', 'lay-offs to set the wide pass, run into box'),
    (3, 'Ball-side winger', 'drive in, ground cross / cut-back across goal'),
    (4, 'Opposite winger', 'attack far side of goal to finish'),
    (5, 'Centre forward', 'occupy central box')
) AS v(so, role, job);

-- 12. pp.32-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'to_attack', 'Counter-pressing 3. (Fast Break) / 2nd-3rd Ball Attacks 5. Pass and Move in Centre + Fast Attacks', 'Fast break within three passes',
    'When a new ball is won or suddenly appears (first ball abandoned), the nearest player takes it and the team breaks immediately.',
    'Regain / whistle, nearest player collects the loose ball',
    'Score as fast as possible using at most 3 passes, e.g. diagonal through pass to winger who cuts back for CF, or CF lay-off to CM who lofts over the top for the other CM''s run.',
    NULL, 32, 42, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'collect ball and play forward at once'),
    (2, 'Winger', 'diagonal through pass or run onto one, cut back'),
    (3, 'Centre forward', 'lay off or finish the cut-back'),
    (4, 'Central midfielders', 'lofted pass over top / sprint into box to finish'),
    (5, 'Wide players', 'sprint forward to give width to the break')
) AS v(so, role, job);

-- 13. pp.34-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Positional Patterns of Play with 2nd/3rd Ball Attacks 1.-3.', 'Sprint back into shape, attack again',
    'Straight after one attack finishes, players sprint back to their positions and a second ball is played in for another quick, structured attack (e.g. LW-LCM-lofted pass to RW, or RCM to oncoming RB, RB to RW, RW across for CF).',
    'First attack complete, new ball enters',
    'Repeat high-tempo attacks without losing positional structure, scoring from the second phase.',
    NULL, 34, 36, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All attackers', 'sprint back into 4-3-3 positions after the first attack'),
    (2, 'Right back', 'oncoming run to receive the second ball wide'),
    (3, 'Right winger', 'receive and pass into the centre for the CF'),
    (4, 'Left central midfielder', 'lofted pass to far winger'),
    (5, 'Centre forward', 'finish in the box')
) AS v(so, role, job);

-- 14. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Positional Patterns of Play with 2nd/3rd Ball Attacks 3. Possession in Midfield with Lay-offs, Play into Forward, and Lofted Pass in Behind to Winger', 'CF wall pass then lofted ball in behind',
    'Midfield possession with lay-offs (RCM to DM, DM to RW, RW back to RB) pulls the block; RB finds the LCM after a big movement to get free.',
    'LCM receives after a big movement and finds the CF',
    'LCM one-two with the CF then lofts the ball in behind for the left winger to shoot, with the CF following in to score the rebound.',
    NULL, 36, 36, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder + right central midfielder', 'lay-offs to circulate'),
    (2, 'Right back', 'inside pass to free LCM'),
    (3, 'Left central midfielder', 'big movement to receive, one-two with CF, lofted pass'),
    (4, 'Left winger', 'run in behind and shoot'),
    (5, 'Centre forward', 'wall pass then follow up rebound')
) AS v(so, role, job);

-- 15. pp.37-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Positional Patterns of Play with 2nd/3rd Ball Attacks 4. Short Fast Combination Play Around the Box (Part 1/3)', 'Forwards drop, combine, cross-over curved runs',
    'Around the box, a forward drops to receive from a midfielder, plays back, the second forward also drops; the midfielder or a forward lofts/slides a pass for a curved run between centre back and full back.',
    'Forward''s drop pulls defender, ball returned to midfielder',
    'Forwards make opposite curved runs into the gaps between CB and FB to score; forwards also shoot early from outside the box after shifting the ball off a defender.',
    NULL, 37, 38, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward 1', 'shift ball and shoot from outside box; drop to receive, then curved run between CB and FB'),
    (2, 'Forward 2', 'drop back to receive, play the final pass or make opposite curved run'),
    (3, 'Midfielder 1', 'hub for lay-backs, lofted pass for the curved run'),
    (4, 'Midfielder 2', 'start the combination into the dropping forward')
) AS v(so, role, job);

-- 16. pp.39-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Positional Patterns of Play with 2nd/3rd Ball Attacks 4. Parts 2/3 and 3/3 - Wing Play, Cross & Finish / Lofted Pass, Cut Back & Finish', 'Box occupation: near post, centre, cut-back',
    'Ball is switched aerially to the winger on the sideline, who beats his man 1v1 (or a midfielder delivers from the half-space) while forwards first sprint out of the box then attack it.',
    'Winger beats defender / delivery coming',
    'Three runners split the targets - near post, centre of box and cut-back/penalty spot - so a byline pass, high back-post cross or knock-down finds a scorer.',
    NULL, 39, 40, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger', '1v1 to the byline, pass back into centre or feed midfielder'),
    (2, 'Forward on near post', 'attack near post'),
    (3, 'Forward in centre / back post', 'attack centre, cut back to penalty spot from a back-post cross'),
    (4, 'Midfielder', 'hold the cut-back zone at penalty spot or deliver high cross to back post')
) AS v(so, role, job);

-- 17. pp.45-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Combinations and Finishing 1.-2. Pass Under Pressure, Curved Run / Short Passing Under Pressure, Movement + Finish', 'Give and go, curved run into box',
    'On the edge of the box under pressure, a player passes inside to a teammate (who checks to create space, 2 touches) and then bends a run in behind.',
    'Pass into the teammate who checked away to get free',
    'Return/third pass is timed into the box for the curved run and finished in 1-2 touches, taking time if available; alternative: pass back, receiver opens up, touches into the box and shoots.',
    NULL, 45, 46, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player A (e.g. Salah, wide forward)', 'pass, then curved run in behind and finish in 1-2 touches'),
    (2, 'Player B (central)', 'check to make space, receive in 2 touches, pass into the run or open up and finish')
) AS v(so, role, job);

-- 18. pp.47-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Combinations and Finishing 3.-4. One-two / Double One-two, Lateral Third Man Run + Finish', 'One-two then lateral third-man run',
    'Central player completes a one-two (or two in a row with players on each side) with teammates who check off to receive, while the third player runs laterally across the edge of the box.',
    'Completion of the one-two with the ball set facing goal',
    'Pass into the box for the curved third-man run to finish in 1-2 touches, while the other side player runs parallel to follow up any rebound.',
    NULL, 47, 48, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player A (central)', 'play one-two(s), then slide pass into the box'),
    (2, 'Player B / C (wide of the arc)', 'check off to receive and return; then curved lateral third-man run to finish'),
    (3, 'Opposite side player', 'parallel run to follow up rebounds')
) AS v(so, role, job);

-- 19. pp.49-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Combinations and Finishing', 'Double movement to lose marker before receiving',
    'A forward or receiver near the box first moves away (steps back or drops at an angle) and then makes the opposite movement forward to meet the pass, so the marker is caught on the wrong foot.',
    'Pass about to be played into the box area',
    'Receive with space and time to finish first time.',
    NULL, 49, 77, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving forward (e.g. Salah as central finisher)', 'Step back or drop at an angle, then attack forward to meet the ball'),
    (2, 'Passer', 'Time the pass to the second movement, not the first'),
    (3, 'Finisher', 'Finish first time or with one forward touch')
) AS v(so, role, job);

-- 20. pp.50-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Combinations and Finishing', 'Diagonal lofted ball to far side, cut across box',
    'From one side a diagonal lofted pass is dropped to the far side of the box for a wide runner, who plays it back across goal first time.',
    'Wide player on one side has time on the ball facing the far side',
    'Ball across an open goal face for three arriving runners.',
    NULL, 50, 50, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side wide player', 'Weight a diagonal lofted pass to the far edge of the box'),
    (2, 'Far-side wide player', 'Time run onto it and play it across goal'),
    (3, 'Left winger, centre forward, right winger', 'Attack near post, centre and far post')
) AS v(so, role, job);

-- 21. pp.51-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Combinations and Finishing', 'Lay-off and third-man run in behind',
    'A player with his back to goal lays the ball off to a supporting team-mate, who plays forward diagonally or wide for a third player who has run past (in behind or on the overlap) to cross.',
    'Back-to-goal receiver under pressure, team-mate facing play',
    'Third man receives in behind facing goal and crosses for runners.',
    NULL, 51, 57, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back-to-goal player', 'Lay the ball off to the facing team-mate'),
    (2, 'Supporting midfielder', 'Play the diagonal or wide pass for the third man first time'),
    (3, 'Third man (wide runner)', 'Run past the line, receive in behind and cross'),
    (4, 'Opposite-side runners', 'Make runs into the centre of the box to meet the cross')
) AS v(so, role, job);

-- 22. pp.52-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Combinations and Finishing', 'Switch wide, full back overlap and cross',
    'Central players combine one touch and switch the ball out to the full back (or a long switch from centre back to far full back); the full back plays into the winger who checks to receive and returns it for the full back''s advanced run outside, or the full back drives inside and a midfielder overlaps, then crosses.',
    'Ball circulated centrally, far side full back free',
    'Full back or overlapping midfielder delivers a ground or aerial cross with forwards making opposite runs.',
    NULL, 52, 82, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central forwards/midfield', 'One-touch combination then firm switch out wide'),
    (2, 'Left centre back (long switch variant)', 'Long aerial switch to far full back'),
    (3, 'Full back', 'Pass into winger, overlap and receive return, cross (or dribble inside)'),
    (4, 'Winger', 'Check before moving to receive, return pass into the full back''s run'),
    (5, 'Two forwards', 'Wait, then go late: one near post, one far post')
) AS v(so, role, job);

-- 23. pp.53-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Combinations and Finishing', 'Set-back for oncoming shooter',
    'Around the edge of the box the ball is played into a player who sets it back first time (often after a one-two) to a team-mate arriving facing goal to shoot from distance or just inside the box.',
    'Pass into a player with back to goal at the edge of the box',
    'Shot by a player running onto a set ball facing goal.',
    NULL, 53, 59, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target player at edge of box', 'Set the ball back first time into the runner''s path'),
    (2, 'Oncoming shooter', 'Arrive at pace, directional touch or first-time shot'),
    (3, 'Next attacker', 'Move to the opposite area ready for the next ball')
) AS v(so, role, job);

-- 24. pp.58-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'to_attack', 'Attacking Combinations and Finishing', 'Fast break from centre with deep runs',
    'On winning the ball (coach feed) in the central circle or from a resting group, the whole unit breaks immediately: simple combination and lay-offs, a first forward pass to a wide runner, an overlap, and runners flood the box; Klopp versions demand a score within about 5 seconds.',
    'Ball won / coach call (''Go! Go! Attack!'')',
    'Reach the box and score before the opponent can recover.',
    NULL, 58, 89, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player receiving first', 'Lay off to the facing midfielder at once'),
    (2, 'Central midfielder', 'First forward pass to a sprinting wide runner'),
    (3, 'Wingers and full backs', 'Make deep forward runs immediately'),
    (4, 'Overlapping central midfielder', 'Overlap outside, receive and enter the box to square it'),
    (5, 'All attackers', 'Score within roughly 5 seconds')
) AS v(so, role, job);

-- 25. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Combinations and Finishing', 'Chain of one-touch overlaps',
    'Players move up the pitch in waves, each passer overlapping the receiver so the ball keeps moving forward one touch until a cross for the runners.',
    'Ball played across to a forward-moving team-mate',
    'Progress at full speed with every player involved and arriving in the box.',
    NULL, 61, 61, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Pass and overlap the receiver at full speed'),
    (2, 'Receiver', 'One-touch pass into the overlap'),
    (3, 'Final overlapping player', 'Cross for the three runners'),
    (4, 'Box runners', 'Attack separate zones of the box')
) AS v(so, role, job);

-- 26. pp.62-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Attacking Combinations and Finishing', 'Criss-cross, overlap, underlap in small groups',
    'Groups of three move the length of the pitch using criss-crossing runs, overlaps, underlaps and direct passes, and finish with combination play in the final third.',
    'Group in possession progressing up the pitch',
    'Create a scoring chance through constantly changing combinations.',
    NULL, 62, 63, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Choose between direct pass and combination'),
    (2, 'Supporting player', 'Criss-cross, overlap or underlap to offer forward'),
    (3, 'Third player', 'Offer depth then arrive to finish')
) AS v(so, role, job);

-- 27. pp.65-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Multi-Ball Attacking Combinations and Finishing', 'Relentless re-attack (attacking pressure)',
    'Klopp''s Liverpool aim to attack non-stop: as soon as one attack ends the next ball is in and the team attacks again, so players have rehearsed answers for every final-third situation.',
    'End of an attack (goal, save or ball dead)',
    'Continuous attacking pressure that overwhelms opponents.',
    NULL, 65, 66, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All attackers', 'Recover position quickly and go again on the next ball'),
    (2, 'Finishers', 'Know the runs and finishes for each scenario')
) AS v(so, role, job);

-- 28. pp.66-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Multi-Ball Attacking Combinations and Finishing', '3v2 overload: commit and pass into gap',
    'Three attackers against two defenders: the ball carrier drives in to commit a defender and plays a through pass into the gap between the two for a timed run, or a give-and-go and square ball for a team-mate; if defenders win it they must dribble out.',
    'Live 3v2 starts after a finishing sequence',
    'Exploit the extra man for a tap-in or one-on-one.',
    NULL, 66, 93, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier (e.g. centre forward or left winger)', 'Drive inside to fix a defender, then release'),
    (2, 'Runner (e.g. right winger)', 'Time run into the gap between the two defenders'),
    (3, 'Third attacker', 'Offer give-and-go or square option'),
    (4, 'Defenders on regain', 'Dribble past the marked line to counter')
) AS v(so, role, job);

-- 29. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Multi-Ball Attacking Combinations and Finishing', 'Lay-off to midfielder, through ball for winger',
    'The centre forward or a winger drops, receives and lays it back to a central midfielder, who plays a through pass between defenders for the far winger''s well-timed diagonal run into the box.',
    'Forward receives in front of the defensive line',
    'Winger runs onto a through ball inside the box.',
    NULL, 67, 67, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward / right winger', 'Show short and lay off first time'),
    (2, 'Central midfielder', 'Play the through pass past the defenders'),
    (3, 'Opposite winger', 'Time a diagonal run into the box')
) AS v(so, role, job);

-- 30. pp.68-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Multi-Ball Attacking Combinations and Finishing', 'Box occupation for full back crosses',
    'When a full back takes a touch forward to cross, the forward, winger and an arriving midfielder fill the central box zones; the full back varies the delivery including a pull-back to the late midfielder.',
    'Full back in crossing position on the flank',
    'Several targets in the box and one late arrival for the pull-back.',
    NULL, 68, 71, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Touch forward and choose cross type, including pull-back'),
    (2, 'Forward', 'Attack the back post'),
    (3, 'Winger', 'Attack the near post'),
    (4, 'Midfielder', 'Arrive late for the pull-back')
) AS v(so, role, job);

-- 31. pp.70-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Multi-Ball Attacking Combinations and Finishing', 'Winger-to-winger lofted ball',
    'One winger, after a short slow pass inside to set it, plays a lofted pass into the box for the opposite winger arriving at the far side.',
    'Winger on the ball with the far winger running in behind',
    'Far winger finishes at the back post.',
    NULL, 70, 96, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger', 'Lofted pass into the far side of the box'),
    (2, 'Opposite winger', 'Time run round the back of the defence and finish'),
    (3, 'Inside player', 'Slow pass to set up the delivery angle')
) AS v(so, role, job);

-- 32. pp.70-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Multi-Ball Attacking Combinations and Finishing', 'Winger give-and-go with CF, ground cross',
    'The winger steps back, plays a give-and-go with the centre forward who moves across, gets round the defender and delivers a ground cross for the centre forward or the opposite winger; variation is a deep cross instead.',
    'Winger receives wide near the box',
    'Low cross across goal for two arriving finishers.',
    NULL, 70, 96, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Give-and-go, run round the defender, cross low or deep'),
    (2, 'Centre forward', 'Move across to return the pass, then attack the box'),
    (3, 'Opposite winger', 'Arrive at the far post')
) AS v(so, role, job);

-- 33. pp.72-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Multi-Ball Attacking Combinations and Finishing', 'Positional circulation around the box',
    'Midfielders, wingers and full backs on both sides keep the ball moving around the box while the centre forward and defensive midfielder interchange; a central midfielder then switches play across before a lofted pass in behind.',
    'Settled possession in front of the box',
    'Move the block, then find a runner in behind on the far side.',
    NULL, 72, 73, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Exchange passes with the centre forward who turns and shoots'),
    (2, 'Central midfielders', 'Switch play across the pitch'),
    (3, 'Wingers and full backs', 'Keep width and circulate around the box')
) AS v(so, role, job);

-- 34. pp.72-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Multi-Ball Attacking Combinations and Finishing', 'Full back third-man run into box',
    'Around the box the defensive midfielder starts a ball to a winger (or the full back plays into the centre forward who finds the winger); the winger lays off to the central midfielder or the centre forward, who slides a through pass for the overlapping full back into the box to cut back for runners.',
    'Winger receives inside with the full back free outside',
    'Full back reaches the byline area inside the box and cuts back.',
    NULL, 72, 81, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Feed the winger'),
    (2, 'Winger', 'Lay off to the central midfielder or centre forward'),
    (3, 'Central midfielder / centre forward', 'Through pass for the overlapping full back'),
    (4, 'Full back', 'Overlap into the box, beat the defender and cut back'),
    (5, 'Forwards and opposite winger', 'Run in for the cut-back')
) AS v(so, role, job);

-- 35. pp.75-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Multi-Ball Attacking Combinations and Finishing', 'Centre forward dummy, winger one-two inside box',
    'The full back passes in towards the centre forward, who lets it run through to the winger; the winger plays a one-two with the centre forward into the box, then feeds the full back''s advanced run for a cross.',
    'Pass from full back along the ground towards the forward',
    'Wrong-foot defenders and get the winger or full back free inside the box.',
    NULL, 75, 75, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Pass in, then make an advanced run for the cross'),
    (2, 'Centre forward', 'Dummy over the ball, then return the one-two'),
    (3, 'Left winger', 'Receive, one-two into the box, release the full back')
) AS v(so, role, job);

-- 36. pp.94-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Multi-Ball Attacking Combinations and Finishing', '6v4/7v4 transition overload attack',
    'After the finishing sequence two extra attackers join and the reds attack four defenders: combination play to get behind, a give-and-go round the opponent, and runners attacking the box for a ground cross; defenders who win it must dribble past a line.',
    'Coach serves the next ball as the finishing phase ends',
    'Use numbers quickly before defenders reorganise to score.',
    NULL, 94, 96, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central attacker', 'Receive the new ball and circulate to the wide player'),
    (2, 'Wide attacker', 'Give-and-go to get in behind and deliver low'),
    (3, 'Forwards', 'Make runs into the box to finish'),
    (4, 'Defenders', 'Defend the goal and dribble out on regain')
) AS v(so, role, job);

-- 37. pp.97-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Multi-Ball Attacking Combinations and Finishing - 16. 4-Ball Finishing + Quick Transition to 7v4 Attack', 'Overload attack vs back four, spin in behind',
    'A fresh ball arrives and seven attackers face a back four; the ball is worked back and across by wide players coming in from the touchline before a midfielder feeds the striker''s partner.',
    'New ball in with numbers up against a set back four',
    'Create a runner in behind the full back and finish from a low cross.',
    NULL, 97, 97, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players coming in from the sideline', 'Offer back and across to circulate and shift the back four'),
    (2, 'Advanced forward (R2)', 'Pass back, then spin in behind his direct marker'),
    (3, 'Central receiver on edge of box (R1)', 'Play the diagonal ball in behind, then attack the box for the cutback'),
    (4, 'Runner in behind', 'Deliver a ground cross across the six-yard area')
) AS v(so, role, job);

-- 38. pp.100-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'set_piece', 'Small to Large Sided Games - 1/2. Receiving from a Throw-in and Breaking Out of Pressure (3v2, 5v4)', 'Throw-in receive and break the press',
    'From a throw-in near the touchline the attacking group is pressed by a smaller defending group in a narrow channel and must escape to a goal at the far end.',
    'Own throw-in under tight pressure',
    'Keep the ball after the throw and play through the press with short lay-offs and runs to score quickly.',
    NULL, 100, 101, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Thrower', 'Throw to a moving receiver, then re-enter as a support option'),
    (2, 'First receiver', 'Check away and back, lay off or turn away from the presser'),
    (3, 'Second / third attacker', 'Make runs beyond the press into space to receive the forward pass'),
    (4, 'Whole group', 'On loss, the press group counters; restart always with a new throw')
) AS v(so, role, job);

-- 39. pp.102-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Small to Large Sided Games - 3/4/5. ''Shoot On Sight'' / ''Winner Stays On'' / Direct Play SSGs', 'Shoot on sight, early and from deep',
    'In small sided games with keepers the team in possession plays direct and shoots whenever any space or angle opens, including from its own half; keepers may also shoot when unpressed.',
    'Any window of space to shoot, even under chaos',
    'Generate many shots by playing direct and exploiting hectic, unbalanced moments rather than over-elaborating.',
    NULL, 102, 104, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Restart fast with short, medium or long roll-outs; shoot from deep if not pressed'),
    (2, 'Ball carrier', 'Look for the shot first; shoot early when space appears'),
    (3, 'Teammates', 'Follow shots in for rebounds and offer quick wall passes'),
    (4, 'Team after regaining', 'Shoot early on the counter before the opponent resets')
) AS v(so, role, job);

-- 40. pp.103-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'out_of_possession', 'Small to Large Sided Games / Transition Games - pressing rules (SSG 4,5,6,8,10; TG 8-11)', 'Collective press, block lanes, no shot',
    'Throughout the SSGs and zone games the defending side presses the ball as a unit, closes the shooter and screens passing lanes (''close on the ball, no shot'', ''put pressure'', ''guys, show'').',
    'Opponent in possession / about to shoot',
    'Deny shots, force the ball into covered lanes and win it back to counter immediately.',
    NULL, 103, 133, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'Close down the ball carrier fast and block the shot'),
    (2, 'Second defenders', 'Cut off the passing lanes around the ball, show the carrier one way'),
    (3, 'Rest of defending unit', 'Squeeze together and track runners'),
    (4, 'Whole team on regain', 'Counter at once toward goal')
) AS v(so, role, job);

-- 41. pp.105-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Small to Large Sided Games - 6. Support Play and Finishing in a 4v4 (+4) + GKs SSG', 'Bounce off end players, quick support',
    'Neutral players beside the goals give a numerical advantage; the team uses them as one-touch wall players and supports immediately after each bounce.',
    'Pressure on the ball carrier with an outside player free',
    'Use set-and-go bounce passes to beat pressure and create many chances.',
    NULL, 105, 105, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside end players', 'One-touch bounce passes back into play'),
    (2, 'Passer', 'Play into the outside player and move to receive the return or the third-man ball'),
    (3, 'Nearby teammates', 'Provide fast close support angles'),
    (4, 'Finisher', 'Attack the space for a quick shot after the combination')
) AS v(so, role, job);

-- 42. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Small to Large Sided Games - 7. Attacking Using the Full Width in a 5v5 (+GKs) SSG with Side Zones', 'Use full width, triangles with wide receiver',
    'Wide zones can only be entered by a receiving player (no dribbling in, no shooting from them) and only one defender can follow; the team stretches play and builds triangles.',
    'Central area congested',
    'Stretch the opponent with width and attack the gaps it opens toward goal.',
    NULL, 106, 106, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player in side zone', 'Receive the pass wide and move it on quickly inside or forward'),
    (2, 'Central players', 'Form triangles with the wide man and attack the gaps'),
    (3, 'Goalkeeper', 'Start play and find width early'),
    (4, 'Defending side', 'Only one presser into the wide zone; block the pass')
) AS v(so, role, job);

-- 43. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Small to Large Sided Games - 8. Playing in Behind + Attacking Against a Low Block (Game Conditions 1)', 'Play in behind a high line',
    'With a joker overload and one-touch play, the attackers exploit a defending team that presses high in their half by passing behind its back line.',
    'Opponent pushed up high to press',
    'Beat the high press by a ball into space behind for a runner to score.',
    NULL, 107, 107, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Joker', 'Extra man to create the overload'),
    (2, 'Passer', 'One-touch circulation, then the ball in behind'),
    (3, 'Forward runner', 'Time runs beyond the last defender'),
    (4, 'Defending side on regain', 'Transition fast to attack')
) AS v(so, role, job);

-- 44. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Small to Large Sided Games - 8. Playing in Behind + Attacking Against a Low Block (Game Conditions 2/3)', 'Attacking a low block, still offer in behind',
    'The defenders drop into their own half and only one can press; attackers on two touches keep probing and keep making runs behind even though the line is deep.',
    'Opponent sits deep with a compact low block',
    'Unlock the deep block with continuous runs in behind and quick 1-2 touch finishes.',
    NULL, 108, 108, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield circulators', 'Two-touch circulation to move the block side to side'),
    (2, 'Joker', 'Overload to free a passer'),
    (3, 'Next runner', 'Keep offering in behind after every pass'),
    (4, 'Finisher', 'One or two touch finish')
) AS v(so, role, job);

-- 45. pp.109-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'to_attack', 'Small to Large Sided Games - 9. Play Out and Score Quickly in a 5v5v5 (+GKs) 3-Goal Game', 'Regain and attack the open goal',
    'Three teams and three goals: the team that wins the ball can attack either of two goals and must pick the less protected one quickly.',
    'Ball won from the attacking team',
    'Read which goal is open and score before the other teams recover.',
    NULL, 109, 109, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Look up and choose the less defended goal'),
    (2, 'Supporting players', 'Spread and run forward toward that goal'),
    (3, 'Goalkeeper', 'Restart quickly after a goal')
) AS v(so, role, job);

-- 46. pp.110-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Small to Large Sided Games - 10. Playing Through Pressure and Collective Defending in a 5v5 (+1) + GKs SSG', 'Build up through press via spare man',
    'From the keeper the possession side builds up against an aggressive press, using a joker as the free man and quick combinations.',
    'Opponent presses the build-up',
    'Play through the first line of pressure to create a goal chance.',
    NULL, 110, 110, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Start the build-up and act as an outlet'),
    (2, 'Joker', 'Find the free pocket and receive between pressers'),
    (3, 'Build-up players', 'Short combinations, third-man options to break lines'),
    (4, 'Forwards', 'Offer forward to receive once the press is broken')
) AS v(so, role, job);

-- 47. pp.111-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Small to Large Sided Games - 11. 5v5 Possession Conditions / 14. Conditioned 10v10 4-Sided/4-Goal Game', 'Secure passes first, then attack free goal',
    'A team must string 5 (5v5) or 6 (10v10) passes before it may score; in the 10v10 it may score in any of four goals, so it keeps the ball then switches to the weakest-defended goal.',
    'Possession won or kept under pressure',
    'Combine keeping the ball under pressure with a quick switch to attack where the opponent is thin.',
    NULL, 111, 114, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All outfield players', 'Two-touch passing, count the passes out loud'),
    (2, 'Goalkeepers', 'Support as extra passers (team cannot score in that keeper''s goal)'),
    (3, 'Players far from ball', 'Prepare the switch toward an unguarded goal'),
    (4, 'Defending side', 'Press, regain and complete own pass count')
) AS v(so, role, job);

-- 48. pp.112-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'set_piece', 'Small to Large Sided Games - 12. Attacking and Defending Corner Kicks + Counter Attacks in an 8v8 (+GKs) Game', 'Corner variants signalled by arm',
    'The corner taker signals the routine: one arm up for a short corner, two for a near-post delivery, none for a deep cross; attackers attack zones and fight for the second ball.',
    'Corner kick for us',
    'Vary corner delivery and win the second ball to keep attacking.',
    NULL, 112, 112, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Corner taker', 'Signal and deliver short, near post or deep'),
    (2, 'Short option', 'Come to the corner for the short variant'),
    (3, 'Box attackers', 'Attack near post, far post and centre zones'),
    (4, 'Edge of box players', 'Win the cleared second ball and restart the attack')
) AS v(so, role, job);

-- 49. pp.112-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'to_attack', 'Small to Large Sided Games - 12/13. Corner and Free Kick + Counter Attacks', 'Defend set piece then counter fast',
    'The defending side clears the corner or free kick, wins the ball and immediately breaks to the far goal while the attackers are still committed forward.',
    'Set piece cleared and won',
    'Punish the opponent''s committed set-piece numbers with a fast counter.',
    NULL, 112, 113, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders in box', 'Clear and win the first contact'),
    (2, 'Players left high/wide', 'Offer outlets to receive and run forward'),
    (3, 'Runners', 'Sprint forward in numbers to finish the counter')
) AS v(so, role, job);

-- 50. pp.113-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'set_piece', 'Small to Large Sided Games - 13. Attacking and Defending Free Kicks + Counter Attacks in an 8v8 (+GKs) Game', 'Wide free kick crossed, second ball',
    'A wide free kick is crossed into the box against a two-man wall and packed defence; attackers then hunt the clearance to sustain pressure.',
    'Free kick in a wide position',
    'Score from the delivery or recycle the second ball into a new attack.',
    NULL, 113, 113, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free kick taker', 'Cross into the attacking zones'),
    (2, 'Box attackers', 'Time runs to the delivery'),
    (3, 'Edge/outside players', 'Collect clearances and continue the attack')
) AS v(so, role, job);

-- 51. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'to_attack', 'Transition Games - 1. Supporting Runs to Score Quickly in a Dynamic 2v1 Attack / 3v2 Transition Game', '2v1 overlap and supporting runs',
    'With a man advantage the carrier drives forward while a partner overlaps; in the following 3v2 the carrier dribbles at speed and two teammates make support runs either side.',
    'Numerical advantage on a fast attack',
    'Exploit the overload with overlap / support runs and score before defenders recover.',
    NULL, 117, 117, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Drive at speed and commit the defender'),
    (2, 'Overlapping partner', 'Run around the carrier to receive and finish'),
    (3, 'Second supporting runner', 'Run the other side to stretch the defenders')
) AS v(so, role, job);

-- 52. pp.117-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'to_defend', 'Transition Games - 1-7 (3v2, 4v6, 3v3, 4v4+4, 5v4, 5v8, 9v7 transitions)', 'Finish then sprint back, press carrier',
    'As soon as an attack ends (shot, goal or loss) the attackers must immediately switch to defending a new attack, pressing the ball carrier and tracking runners back toward their goal.',
    'Attack ends / new ball enters for the opponent',
    'Stop the opponent''s fast break by instant pressure and recovery runs.',
    NULL, 117, 129, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest attacker', 'Press the new ball carrier at once'),
    (2, 'Other attackers', 'Sprint back goal-side and track the runners'),
    (3, 'Recovering player', 'Intercept the forward pass as the runner arrives'),
    (4, 'Whole group', 'On regain, launch an immediate counter')
) AS v(so, role, job);

-- 53. pp.119-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'to_attack', 'Transition Games - 2-9 regain-and-counter phases (4v6, 4v4+4, 5v4, 5v8, 9v7)', 'Win it, release wide, counter fast',
    'After intercepting, the defending team quickly passes to a free player in space or to wide outlets entering the pitch, creating an overload that is finished with a cross or through ball.',
    'Interception or tackle against an attack',
    'Turn defence into a quick goal before the opponent can recover.',
    NULL, 119, 129, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Pass immediately to the free man in space'),
    (2, 'Wide outlets', 'Receive in advanced wide positions and deliver a ground cross'),
    (3, 'Winger cutting inside', 'Cut in and slide a through pass to the striker'),
    (4, 'Centre forward', 'Run in behind and finish 1v1')
) AS v(so, role, job);

-- 54. pp.120-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Transition Games - 3/4/5. Receiving from Different Angles / 5-Ball and 3-Ball Finishing with Give and Go', 'Box-edge combos: set, give-and-go, lofted ball',
    'Finishing phases around the box: a central player receives, turns and shoots; a wide player plays in and the receiver sets back for a shot; give-and-goes and a lofted pass for a runner into the box; a drop-and-cut-back for a teammate.',
    'Ball arrives on the edge of the box',
    'Create a clean shot through quick set-backs, wall passes and runs behind.',
    NULL, 120, 124, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central striker', 'Turn and shoot or set back for the arriving player'),
    (2, 'Wide passer', 'Feed inside and support for a give-and-go'),
    (3, 'Midfielder', 'Play a lofted pass over the line for a box run'),
    (4, 'Dropping player', 'Drop to receive, give-and-go, then cut back'),
    (5, 'Box runner', 'Arrive late to finish')
) AS v(so, role, job);

-- 55. pp.126-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Transition Games - 6. Crossing and Finishing with Side Zones + 5v4/5v8 Transition Game', 'Wide cross with timed box runs',
    'The ball goes out to a winger in a side zone; three runners attack the box (one to front post) while another holds for a cutback, then everyone recovers before the next attack.',
    'Winger receives in wide zone',
    'Score from crosses aimed at the front post or a cutback.',
    NULL, 126, 127, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger in side zone', 'Move forward with the ball and cross'),
    (2, 'Front-post runner', 'Attack the near post'),
    (3, 'Other box runners', 'Fill centre and far post'),
    (4, 'Cutback player', 'Position for the pulled-back ball')
) AS v(so, role, job);

-- 56. pp.128-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'in_possession', 'Transition Games - 7. Wingers/Centre Forward Finishing in and Around the Box + 9v7 (+GKs) Transition', 'CF links wingers, midfielder arrives late',
    'A midfielder exchanges return passes with the centre forward, then feeds wingers who drop to receive; the CF drifts wide to set for the winger or exchange a give-and-go, and the midfielder makes a deep run into the box for the cross.',
    'Midfielder has the ball facing forward',
    'Use the CF as a link to free wingers and arriving midfielders for shots.',
    NULL, 128, 129, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder', 'Pass into CF/wingers, then make a deep run into the box'),
    (2, 'Centre forward', 'Return passes, drift toward the ball side to set or give-and-go'),
    (3, 'Wingers', 'Drop to receive, shoot from the set or cross')
) AS v(so, role, job);

-- 57. pp.130-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'to_attack', 'Transition Games - 8/9/10/11. 3-Team 5v5v5 and 6v6v6 Zone Counter Attack Games', 'Win it, cross halfway, counter (40s)',
    'Three teams on a halved pitch: the defending team wins the ball and must get over halfway to attack the third team, sometimes within 40 seconds, with an offside line or wide jokers in side zones.',
    'Ball won in own half',
    'Break out of the regain zone fast and finish the counter with timed runs.',
    NULL, 130, 133, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Release forward over halfway at once'),
    (2, 'Forward runners', 'Sprint beyond, time runs against the offside line'),
    (3, 'Wide jokers', 'Receive in side zones and deliver to runners'),
    (4, 'Scorers', 'Take a new ball and go again at the other goal')
) AS v(so, role, job);

-- 58. pp.134-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'j-rgen-klopp-80-attacking-combinations-finishing-positional-patterns-of-play-tra'), 'to_attack', 'Transition Games - 12. 8v8 (+3) + GKs ''5-Second Rule'' Fast Counter Attack Transition Game', '5-Second Rule counter finish',
    'Once the ball crosses halfway, whether after a build-up through pressure with the overload or after a regain, the attacking team must finish its attack within five seconds.',
    'Ball carried or passed over halfway / possession regained',
    'Attack with maximum speed and directness so the opponent cannot reorganise.',
    NULL, 134, 136, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Build-up players', 'Use the joker and overload to play through pressure into the attacking half'),
    (2, 'Ball winner', 'Dribble or pass past halfway immediately'),
    (3, 'Forwards', 'Sprint ahead to receive in behind'),
    (4, 'Finisher', 'Shoot within the five-second window')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('2101-coaching-book-klopp-vol2-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
