-- 2111 📚 Coaching book patterns: "The Complete Guide to Coaching Soccer
-- Systems and Tactics" (Jacob Daniel, Reedswain) — the first book read from
-- the owner's KINDLE library (Kindle Cloud Reader spreads, captured in
-- Chrome; page numbers here are spread numbers s001–s219).  Every spread read
-- by readers; each distinct team behaviour written up in OUR OWN WORDS with
-- who does what.  Drill layouts, coaching-method theory and front matter left
-- out.  Owner's personal library.  (James 11/27 "do the soccer ones in kindle")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    subtitle    = NULL,
    team        = NULL,
    season      = '1990s-2002',
    method_note = 'A general coaching textbook for youth to college coaches in four sections: principles of play (attack: support, depth, width, mobility, penetration, creativity; defence: pressure, recovery, cover, balance, compactness; team shape in attack, defence and transition); systems of play (man-to-man vs zonal marking and hybrids, pressing and channelling, 4-4-2 / 3-5-2 / 4-3-3 / 3-4-3 and their variations, illustrated with World Cup and Euro 2000 sides such as France 1998, Italy and Portugal 2000, Brazil 2002); methods of coaching (generic vs functional activities, six recurring game situations, patterns of play, shadow play); and finishing touches (developing forwards, possession rhythm, throw-ins, the offside trap). Patterns are the on-pitch behaviours it teaches, in our words. Kindle edition: page numbers are screen spreads.'
WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics');

-- 1. pp.6-6
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'The Evolution of Soccer Tactics', 'Sweeper behind man-markers (Italian catenaccio)',
    'History: Italian sides (Inter, AC Milan, 1960s) added a free sweeper behind tight man-markers to cover any lost duel.',
    'Opponent individuals stronger than our defenders',
    'Every beaten marker has a spare man behind him, turning lost 1v1s into 2v1s.',
    NULL, 6, 6, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Man-marking defenders', 'Track an assigned attacker tightly'),
    (2, 'Sweeper', 'Sit free behind the markers and cover whoever is beaten')
) AS v(so, role, job);

-- 2. pp.6-7
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'The Evolution of Soccer Tactics', 'Compact block attacking ball in groups',
    'Teams moved more players into midfield and learned to squeeze space so a beaten player is immediately backed up by a nearby team-mate.',
    'Ball carrier beats first defender',
    'Deny time on the ball in a congested midfield and keep numbers behind the ball.',
    NULL, 6, 7, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First defender', 'Engage the ball carrier'),
    (2, 'Nearest team-mates', 'Stay close enough to apply instant second pressure'),
    (3, 'Whole team', 'Keep more players behind the ball than ahead of it')
) AS v(so, role, job);

-- 3. pp.7-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The Evolution of Soccer Tactics / Mobility: Overlapping runs', 'Overlapping run by wide defender',
    'With the middle crowded, an unmarked wide defender runs from behind the ball past it into space down the flank (Roberto Carlos as the model); midfielders can overlap too.',
    'Ball with a team-mate ahead on the flank, no winger to mark',
    'Add a free runner on the flank beyond the ball for penetration and crosses.',
    NULL, 7, 30, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide defender', 'Sprint from behind the ball around the carrier into space ahead'),
    (2, 'Wide midfielder in possession', 'Hold, then release into the overlapping run'),
    (3, 'Forward', 'Occupy central defenders')
) AS v(so, role, job);

-- 4. pp.7-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The Evolution of Soccer Tactics / Mobility: Rotating runs', 'Rotating runs (Total Football interchange)',
    'Players swap positions to confuse markers: a forward drops into midfield while a midfielder attacks the space, or a wide midfielder comes inside while the inside midfielder goes wide (Holland 1970s).',
    'Markers following their men',
    'Ball can go to either rotating player depending on how defenders react.',
    NULL, 7, 33, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Drop into midfield, dragging his marker'),
    (2, 'Central midfielder', 'Run into the space the forward vacated'),
    (3, 'Wide midfielder', 'Slide inside, pulling his marker'),
    (4, 'Inside midfielder / defender', 'Fill the vacated flank')
) AS v(so, role, job);

-- 5. pp.8-13
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_attack', 'Evolution of Tactics / Characteristics of Successful Teams', 'Play forward fast on regain',
    'Because blocks defend well once set, the moment of winning the ball is the best chance; teams look to move it forward before the opponent regroups.',
    'Possession won',
    'Attack the opponent while still disorganised.',
    NULL, 8, 13, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Look forward first, pass early'),
    (2, 'Forwards', 'Break into space behind immediately'),
    (3, 'Midfielders', 'Support the counter at speed')
) AS v(so, role, job);

-- 6. pp.12-13
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Characteristics of Successful Teams', 'Possession in opponent half to tire them',
    'Keeping the ball, ideally in the opponent''s half, dictates where play goes, moves it into areas where we win 1v1s, and creates openings late as opponents tire.',
    'Settled possession',
    'Control tempo and location, then penetrate.',
    NULL, 12, 13, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back and midfield players', 'Circulate the ball securely'),
    (2, 'Players with 1v1 advantage', 'Receive in their favoured areas and attack')
) AS v(so, role, job);

-- 7. pp.13-13
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_defend', 'Characteristics of Successful Teams', 'Close down instantly, regain high',
    'Successful sides shut the ball down the moment they lose it and pounce on loose balls and passes, so many regains happen in the attacking half.',
    'Possession lost in opponent half',
    'Win the ball back close to goal, where chances follow quickly.',
    NULL, 13, 13, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player to ball', 'Pressure immediately'),
    (2, 'Surrounding players', 'Anticipate and intercept the escape pass'),
    (3, 'Whole team', 'High work rate on loss')
) AS v(so, role, job);

-- 8. pp.13-13
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Characteristics of Successful Teams', 'Penetrate centrally to open flanks',
    'Varying the attack between middle and wings; threatening through the middle forces the opponent to crowd central areas and concede flank space.',
    'Opponent narrow or wide',
    'Unpredictable attack that exploits whichever area is conceded.',
    NULL, 13, 13, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders/forwards', 'Threaten passes and runs through the middle'),
    (2, 'Wingers/wide players', 'Hold width to exploit space when defence narrows')
) AS v(so, role, job);

-- 9. pp.14-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Principles of Attack: Crossing from the goal line', 'Cut-back / cross from the end line',
    'Attacker reaches the goal line before crossing, so defenders are turned to face their own goal and cannot watch ball and runners together.',
    'Wide player beats defender to the end line',
    'Poor clearances, corners, and attackers arriving in front of defenders to finish.',
    NULL, 14, 15, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide attacker', 'Get to the goal line before delivering'),
    (2, 'Central forwards', 'Attack front space ahead of turned defenders'),
    (3, 'Late runners', 'Arrive at the edge for cut-backs')
) AS v(so, role, job);

-- 10. pp.14-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Principles of Attack: Getting the ball into the ''hole''', 'Attacker receiving in ''the hole''',
    'Get the ball to an attacker facing goal in the space just in front of the opposing centre backs.',
    'Ball reaches attacker in the hole, facing goal',
    'He dribbles at the line (forcing a defender out, breaking cover) or slips a killer pass behind, or shoots.',
    NULL, 14, 16, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacker in the hole', 'Turn and run at defenders, shoot or play through'),
    (2, 'Wide/other forwards', 'Make runs behind the defence for the through pass')
) AS v(so, role, job);

-- 11. pp.15-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Principles of Attack: Crossing from the goal line', 'Whipped cross behind line from deep',
    'From in front of the defence, a hard bending cross into the gap between back line and keeper, curling away from the keeper (Beckham, Man Utd).',
    'Wide player with time in a deep wide area',
    'Replicates the end-line effect by forcing defenders to turn and run back to clear.',
    NULL, 15, 15, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep crosser', 'Whip ball into space between defence and keeper'),
    (2, 'Forwards', 'Attack the space behind the line')
) AS v(so, role, job);

-- 12. pp.17-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Support', 'Support all around the ball, numbers up',
    'Ball carrier should have team-mates on both sides, behind and ahead, with more of our players near the ball than theirs, at angles that avoid interceptions.',
    'Team-mate in possession under pressure',
    'Keep possession with safe passing options.',
    NULL, 17, 19, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Side supporters', 'Offer passes on either side at an angle off the defender''s shadow'),
    (2, 'Back supporter', 'Offer a safe option behind'),
    (3, 'Front supporter', 'Offer the forward option')
) AS v(so, role, job);

-- 13. pp.19-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Support', 'Open support angle to see pressure',
    'Supporting player adjusts position so on receiving he can see both the ball and the approaching opponent and the field.',
    'About to receive near an opponent',
    'Better first-touch decision with opponent in view.',
    NULL, 19, 20, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Supporting receiver', 'Move to an angle showing ball and closing opponent in one view')
) AS v(so, role, job);

-- 14. pp.20-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Support', 'Passer stays behind until receiver turns',
    'After a defender passes into midfield he should not overlap at once; he holds or backpedals into a safe support spot away from his marker until the midfielder can face forward.',
    'Pass played into a midfielder under pressure with back to goal',
    'Pressured midfielder keeps a back pass outlet.',
    NULL, 20, 21, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passing defender', 'Drop into support behind, away from the opposing forward'),
    (2, 'Receiving midfielder', 'Use the back pass if unable to turn')
) AS v(so, role, job);

-- 15. pp.21-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Support', 'Diagonal support over flat support',
    'Supporters should stagger at diagonals rather than standing square or directly in line, which only allows sideways and back passes.',
    'Building play through a unit',
    'Diagonals create new passing lanes and forward penetration.',
    NULL, 21, 22, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Side supporters', 'Step off the flat line into diagonal spots'),
    (2, 'Deep player', 'Offset so a ground pass to the front player is possible')
) AS v(so, role, job);

-- 16. pp.22-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Depth', 'Strikers stretch on last line, vs sweeper',
    'At least one striker pushes up against the last defender to stretch the field; against a sweeper dropping 10-15 yards deep, the forward pushes level with the sweeper instead of checking into midfield.',
    'Opponent defends with a deep sweeper',
    'Creates midfield space and a forward target, then he shows for the ball to feet.',
    NULL, 22, 24, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Play as high as the deepest defender allows, then show to feet'),
    (2, 'Midfield', 'Use the space opened between lines')
) AS v(so, role, job);

-- 17. pp.24-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Width', 'Width opens vertical passing lanes',
    'Players spreading touchline to touchline stretch the opponent, open gaps for forward passes, allow escape from congestion and switches of play.',
    'Defence compact, central lanes blocked',
    'A direct ball from defence to forward becomes possible through the gap.',
    NULL, 24, 25, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielders', 'Hold position on the touchline'),
    (2, 'Defender in possession', 'Pass through the opened lane to the forward')
) AS v(so, role, job);

-- 18. pp.25-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Width', 'Wide and back to unlock gap',
    'When compact midfielders block lanes, the defender passes to the wide midfielder, an opponent shifts out to press, and the ball comes back to the defender who now threads the gap.',
    'Ground passes to forwards blocked',
    'Use the wide pass to pull an opponent out and open a central lane.',
    NULL, 25, 26, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender (D4)', 'Play wide, receive back, pass through the gap'),
    (2, 'Wide midfielder (M4)', 'Stay wide, draw the pressure, return the ball'),
    (3, 'Forward', 'Show for the penetrating pass')
) AS v(so, role, job);

-- 19. pp.26-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Mobility', 'Runs into open space',
    'Players move off the ball into unoccupied space where the carrier can find them, e.g. a full back or wide midfielder moving into width.',
    'Team-mate on ball with time',
    'Give the carrier forward or wide options; static attackers are easy to mark.',
    NULL, 26, 28, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Run into free space down the flank'),
    (2, 'Wide midfielder', 'Move into width ahead of the ball')
) AS v(so, role, job);

-- 20. pp.26-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Mobility', 'Decoy runs to create space',
    'A player runs to drag his marker away, e.g. forward checking towards the ball so the second forward exploits the space, or midfielder running away so a defender can step in.',
    'Opponents marking man to man',
    'Marker follows (space for a team-mate) or stays (runner free to turn).',
    NULL, 26, 28, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First forward (F1)', 'Check towards ball pulling the centre back'),
    (2, 'Second forward (F2)', 'Run into the space vacated'),
    (3, 'Midfielder (M1)', 'Run away from ball taking his marker'),
    (4, 'Defender (D2)', 'Step into the created space')
) AS v(so, role, job);

-- 21. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Mobility - Diagonal runs', 'Pass and run on opposite lines',
    'Pass and run should cross: straight pass into a diagonal run, or diagonal pass into a straight run; central attackers run diagonally, wide attackers straight.',
    'Ball played into a runner''s path',
    'Runner keeps the ball in view, passer judges weight, and receiver can shield from the defender.',
    NULL, 30, 30, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central attacker', 'Make diagonal runs, never turn back to the ball'),
    (2, 'Wide attacker', 'Make straight runs down the line'),
    (3, 'Passer', 'Match pass direction to cross the run')
) AS v(so, role, job);

-- 22. pp.30-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Mobility - Blind side runs', 'Blind side run behind ball-watchers',
    'A midfielder runs diagonally behind defenders'' backs while they watch the ball in front of them.',
    'Defenders ball-watching',
    'Runner arrives unmarked behind the line.',
    NULL, 30, 31, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder (M2)', 'Diagonal run behind the defenders'' backs'),
    (2, 'Ball carrier', 'Play into space behind')
) AS v(so, role, job);

-- 23. pp.31-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Mobility - The flat run', 'Flat run to stay onside',
    'Attacker delays going forward by running across the line to stay onside, then turns forward the instant the ball is played.',
    'Pass released',
    'Beat the offside line with a timed burst.',
    NULL, 31, 33, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Run flat along the line, burst behind on the pass'),
    (2, 'Passer', 'Release as the run turns')
) AS v(so, role, job);

-- 24. pp.33-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Mobility - Third Man Running', 'Third man run',
    'While two players combine and draw attention, a third, often from behind and often the one who started the move, sprints into space behind for the through ball.',
    'Two-player combination drawing defenders',
    'Unseen runner receives behind the defence two or three passes later.',
    NULL, 33, 34, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Third man (M2)', 'Pass forward, then sprint into space behind, timed onside'),
    (2, 'Combining pair', 'Interpass to hold defenders'' focus, then release through')
) AS v(so, role, job);

-- 25. pp.34-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Mobility - Dummy runs', 'Dummy run then real run',
    'Attacker feints one way to send the defender wrong then darts the other: fake in behind and check to feet, fake to ball and spin down the wing or into the centre; wide midfielder times the move as the defender in possession looks up.',
    'Team-mate gets ball under control and looks up',
    'Create a yard of separation for oneself to receive.',
    NULL, 34, 37, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Short feint, then sprint into the opposite space'),
    (2, 'Wide midfielder', 'Drift towards own half then spin down the wing (or run up and check back)'),
    (3, 'Defender in possession (D1/D3)', 'Pass as the real run starts')
) AS v(so, role, job);

-- 26. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Attacking Principle: Penetration', 'Penetration behind opponents',
    'Penetration means getting the ball into spaces behind opponents, by dribble, combination (wall pass, crossover, overlap) or long ball, methodically or on the counter; needs runners willing to go behind and a carrier who spots it early.',
    'Opening appears before defence regroups',
    'Ball into goal-scoring areas: around a defender into a winger''s run, behind midfield to forward''s feet, or into space behind the back line.',
    NULL, 37, 37, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Recognise and play forward early'),
    (2, 'Winger', 'Run onto ball played around the full back'),
    (3, 'Forward', 'Receive to feet behind opposing midfield'),
    (4, 'Runners', 'Attack space behind defenders')
) AS v(so, role, job);

-- 27. pp.39-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_defend', 'Principles of Defense / Defending principle: Pressure', 'Immediate goal-side pressure on ball loss',
    'When the ball is lost, the nearest player closes the new ball carrier at once, ideally coming from a goal-side starting position so he can block forward play. Pressure is required in the defensive and middle thirds; pressing in the attacking third depends on the coach''s plan (full-field press or drop off).',
    'Possession lost',
    'Win the ball back straight away, or at least stop the forward pass and the counter so teammates can recover goal-side.',
    NULL, 39, 41, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest goal-side player (M2)', 'Closes the carrier at once and blocks the forward pass'),
    (2, 'Player who is not goal-side (M4)', 'Does not press from behind, because he cannot block the forward pass'),
    (3, 'Pressing defender', 'Stays on his feet, does not dive in, and tackles only when there is cover behind or the attacker shows too much of the ball')
) AS v(so, role, job);

-- 28. pp.39-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Defending principle: Pressure', 'Close down while the pass travels',
    'Pressure is kept up from receiver to receiver by moving toward the next receiver while the ball is still in the air. Arriving with the ball forces errors or sideways and backward passes, while loose pressure lets the receiver pick out a forward pass.',
    'Opponent passes the ball',
    'Intercept, the best result because it gives a ready-made counter, or arrive as the ball does and force a mistake.',
    NULL, 39, 41, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender nearest the receiver', 'Moves while the ball is in flight and aims to intercept or arrive with the ball'),
    (2, 'Teammates', 'Keep up the pressure until the ball is won or pushed back into the opponents'' half')
) AS v(so, role, job);

-- 29. pp.41-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_defend', 'Defending principle: Recovery', 'Recovery runs goal-side of ball',
    'While one player presses, everyone else, forwards included, sprints back goal-side of the ball and of their opponents. Each run has one of three jobs: press the ball, mark a man, or cover space behind teammates. A recovering midfielder lets a wide runner go and tucks into a central covering spot.',
    'Possession lost and the first presser engaged',
    'Put the whole team between ball and goal with extra numbers around the ball and at the back.',
    NULL, 41, 42, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (F1)', 'Chases back to press the ball, and is done once the ball goes past him; may be told to track a defender who runs forward'),
    (2, 'Midfielder (M3)', 'Gets goal-side to cover the presser'),
    (3, 'Midfielder (M1)', 'Chases back after a runner to mark him'),
    (4, 'Far midfielder (M5)', 'Drops into a central covering position instead of following a wide runner')
) AS v(so, role, job);

-- 30. pp.42-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Defending principle: Cover', 'Cover at angle, channel, then tackle',
    'A covering player sits close behind and at an angle to the presser: near enough to step in if the presser is beaten, but far enough that one pass or dribble cannot beat both. He tells the presser which way to force the carrier, usually down the sideline.',
    'Teammate pressing the ball',
    'Stop penetration and let the presser tackle safely, because a beaten presser has someone behind him.',
    NULL, 42, 43, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing defender (D1)', 'Forces the carrier toward the sideline and tackles at the right moment'),
    (2, 'Covering defender (D2)', 'Sits behind at an angle, tells the presser where to force, and presses if the presser is beaten')
) AS v(so, role, job);

-- 31. pp.43-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Defending principle: Cover', 'Cover, mark and block lane at once',
    'In a 2v2 or 3v3 around the ball the covering player also has to mark. He picks a spot where he can see the ball and his man, covers the presser, and cuts the pass into the striker. If the ball goes to his man he presses, and the first presser drops behind him to become the cover.',
    'Even numbers around the ball',
    'Keep pressure quick and from the front without one player running between two opponents; pressing and covering roles swap with each pass.',
    NULL, 43, 44, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Covering midfielder (M2)', 'Covers M1, marks opponent 2, blocks the pass to forward 9, and presses if 2 gets the ball'),
    (2, 'Pressing midfielder (M1)', 'Presses 1 and drops in behind M2 as the cover when the ball goes to 2'),
    (3, 'Centre back (D)', 'Marks the striker (9)')
) AS v(so, role, job);

-- 32. pp.44-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Defending principle: Balance', 'Far-side balance against the switch',
    'Defenders far from the ball stay deep and narrow enough to guard the space in front of goal, while staying close enough to close down a switched pass while it travels. If they are pulled too close to the ball, a cross-field pass beats them.',
    'Ball on the far side',
    'Get first to balls played into the scoring space and close down switches while the pass is in the air.',
    NULL, 44, 45, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Far-side defenders (D3, D4)', 'Stay deep and toward the middle, guard the space in front of goal, and move up on a switch'),
    (2, 'Ball-side defender (D1)', 'Engages the ball side')
) AS v(so, role, job);

-- 33. pp.45-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Defending principle: Compactness', 'Squeeze vertically and laterally',
    'The whole team squeezes up and across to shrink the playing area, which takes away the ''hole'' between defence and midfield. Defenders push up as the team moves forward, and forwards drop or midfield pushes up to close the gap at the front. When the ball is lost, the far-side wide player tucks in.',
    'Team moves forward or loses the ball',
    'Shrink the area to defend to a third or a quarter of the pitch, with players covering each other and outnumbering the opponents around the ball.',
    NULL, 45, 47, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Pushes up toward midfield to remove the hole'),
    (2, 'Far-side wide midfielder (M5)', 'Tucks inside for compactness and extra cover'),
    (3, 'Forwards (F1, F2)', 'Stop the ball being switched to the far opponents')
) AS v(so, role, job);

-- 34. pp.47-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Defending principle: Compactness', 'Sweeper-keeper behind a high line',
    'With a flat back line and no sweeper, the keeper comes off his line to cover the whole defensive third and intercept through balls behind the defence. With fast defenders and a mobile keeper the line can hold near halfway even after losing the ball; if they are slow, the whole team drops off when the ball is lost.',
    'High flat line, through ball in behind',
    'Stay compact without a sweeper by having the keeper guard the space behind the line.',
    NULL, 47, 47, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Plays far off his line and intercepts balls played behind the defence'),
    (2, 'Back line', 'Holds a high line if quick enough, otherwise retreats when the ball is lost')
) AS v(so, role, job);

-- 35. pp.47-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Team shape in attack', 'Spread out on regain, staggered triangles',
    'On winning the ball, players spread out at once to give width, depth ahead of the ball and support behind it. Players stand slightly ahead of or behind their neighbours, never flat, so the team forms many triangles. Example: a 3-5-2 building from the left centre back.',
    'Possession won',
    'Offer angled, diagonal passes and many options so the team keeps the ball while moving it forward.',
    NULL, 47, 49, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards (F1, F2)', 'Push high to give depth'),
    (2, 'Wide midfielders (M1, M5)', 'Hold the width to stretch the opponents'),
    (3, 'Central midfielders (M2, M3, M4)', 'Stand at different depths, each open to the ball carrier and out of the passing lane to the forwards'),
    (4, 'Non-ball centre backs (D2, D3)', 'Take angled support positions behind the ball')
) AS v(so, role, job);

-- 36. pp.48-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Team shape in attack', 'Bounce pass to the support behind',
    'Midfielders often receive with their back to goal and under pressure. A teammate stands just behind so the receiver can play back the way he faces, for example D1 to M4 and back to M3, instead of turning into pressure. The supporting player then faces forward with options.',
    'Midfielder receives facing his own goal under pressure',
    'Move the ball into midfield without losing it, with the new receiver facing forward.',
    NULL, 48, 49, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving midfielder (M4)', 'Plays straight back to the support instead of turning'),
    (2, 'Supporting midfielder (M3)', 'Stands just behind, receives facing forward, and looks for the next forward pass'),
    (3, 'Deeper midfielder (M2)', 'Supports M3 in the same way')
) AS v(so, role, job);

-- 37. pp.49-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Team shape in attack', 'Angled back support enables switch',
    'Defenders stand at an angle behind the ball carrier rather than in a flat line. If the carrier is pressed he can play back and across, and the play can be switched without going all the way back to the keeper. A flat back line leaves only the pass to the keeper, which gives up ground.',
    'Wide centre back pressed in build-up',
    'Escape pressure and switch sides while keeping the ground already gained.',
    NULL, 49, 49, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (D1)', 'Plays back and across when pressed'),
    (2, 'Other centre backs (D2, D3)', 'Stand at an angle behind to offer the back pass and carry the switch'),
    (3, 'Goalkeeper', 'Last-resort outlet only')
) AS v(so, role, job);

-- 38. pp.50-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Team shape in attack', 'Staggered lines to skip lines',
    'Midfielders and forwards should not stand in one straight vertical line, because the nearest player blocks the passes to the ones behind. Staggering their positions opens lanes so a pass can skip a line.',
    'Centre back on the ball with midfield and forwards in a straight line',
    'Open forward passing lanes that skip a line and lead to penetration.',
    NULL, 50, 51, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (M3, M4)', 'Move off the straight line to open lanes'),
    (2, 'Forward (F2)', 'Moves off the line of the midfielders'),
    (3, 'Ball-carrying centre back (D2)', 'Plays forward through the lanes this opens')
) AS v(so, role, job);

-- 39. pp.51-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Team shape in attack', 'Connected shape, not over-stretched',
    'A team that is spread too far in both directions ends up hitting long, risky passes, cannot support quickly, and is open to the counter. A safer shape keeps width and depth: the wide midfielders give the width, while the defenders step up close to midfield and tuck in to give cover and close support. The back line follows the attack up the pitch, keeping about 40-50 yards to the forwards.',
    'Settled possession in midfield',
    'Keep the ball with short options while staying set up against a counter.',
    NULL, 51, 53, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'Step up and tuck in behind the midfield; do not go wide when wide midfielders already give width'),
    (2, 'Wide midfielders (M1, M5)', 'Give the team''s width'),
    (3, 'Back line', 'Moves up with the attack, about 40-50 yards behind the forwards')
) AS v(so, role, job);

-- 40. pp.53-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Team shape in attack', 'Support for the switched winger',
    'Before a long switch to the far wide player, someone must be close enough to support him. Otherwise he gets double-teamed and the last defender will not leave his post to help. A deep midfielder or the near centre back shifts across so the switch can go either as one long pass or as two medium passes through the middle.',
    'Midfielder about to switch play to the far winger',
    'The winger can keep the ball after the switch, and if he loses it someone presses at once.',
    NULL, 53, 55, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Switching midfielder (M3)', 'Switches with one long pass or two medium passes through M2'),
    (2, 'Far-side holding midfielder (M2)', 'Shifts across to support the winger after the switch'),
    (3, 'Far-side centre back (D3)', 'Gets close enough to support and to press if M5 loses the ball'),
    (4, 'Far winger (M5)', 'Receives the switch')
) AS v(so, role, job);

-- 41. pp.55-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_defend', 'Team shape in attack / Team shape in defense', 'Rest-defence: numbers-up plus holding mid',
    'Even in possession, the team keeps one more defender back than the opponents leave forwards up front, for example three defenders against two strikers. A holding midfielder stays in front of them to press anyone who breaks out, block passes to the striker and win clearances. This risk can be dropped only when chasing a goal late on.',
    'Team committed to attack',
    'Stop 2v2 or 3v3 counters if the ball is lost.',
    NULL, 55, 56, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three (D1, D2, D3)', 'Stay back and mark the two strikers, always one more than them'),
    (2, 'Holding midfielder (M2)', 'Stays in front of the back three, presses anyone breaking out, cuts passes to the strikers and wins clearances'),
    (3, 'Midfielders', 'Fill in for full backs who overlap so the numbers at the back stay up')
) AS v(so, role, job);

-- 42. pp.55-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Team shape in defense', 'Defensive shape: tight near goal, loose far',
    'A good defending shape has everyone goal-side, pressure on the ball and one more defender than attackers at the back. The striker in the scoring area is marked tightly by two players. Opponents further from the ball and from goal are marked more loosely, but each defender stays close enough to press his man if he receives. This shape blocks penetration and invites square passes out wide.',
    'Opponent in possession near our third',
    'Keep the ball in front of the defence; any ball played in behind should be easy to win.',
    NULL, 55, 56, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders near the striker', 'Mark him tightly and double up'),
    (2, 'Players away from the ball', 'Mark loosely but stay close enough to close down'),
    (3, 'Nearest defender', 'Presses the ball')
) AS v(so, role, job);

-- 43. pp.57-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Team shape and transition', 'Keep depth, give up some width',
    'Spreading out helps keep the ball but leaves the team open if it is lost, and that matters more for less skilled teams that lose the ball often. One compromise keeps depth, which is needed to go forward, but narrows the team so it does not stretch touchline to touchline. Highly skilled teams (Brazil, Holland) spread wide; ''Latin'' sides such as Italy crowd the middle and push up with caution.',
    'Possession for a team prone to turnovers',
    'Strike a balance between attacking shape and protection against the counter.',
    NULL, 57, 58, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'Stay close together to cover the holding midfielder'),
    (2, 'Holding midfielder (M2)', 'Does not get stretched away from the defenders'),
    (3, 'Front players', 'Keep depth, and keep width only as far as skill allows')
) AS v(so, role, job);

-- 44. pp.61-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Man-to-man marking', 'Man-to-man with free sweeper',
    'Each marker is given one opponent and follows him wherever he goes, at least in the defensive half. A sweeper behind them has no man and closes gaps, covers beaten markers and guards the space in front of goal. The attacking midfielder and forwards also have no man but still defend and track runners. Example: a 3-5-2 against a 4-4-2.',
    'Opponent possession in our half',
    'Tight marking that makes it hard to receive and turn, with the sweeper as the safety net.',
    '4-4-2', 61, 64, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Man markers (Xm)', 'Follow their assigned man closely'),
    (2, 'Sweeper (X1)', 'Has no man; covers, closes gaps, keeps the team compact and runs the offside line'),
    (3, 'Attacking midfielder and forwards (X2, X3, X4)', 'Have no man; help defend and track overlapping defenders')
) AS v(so, role, job);

-- 45. pp.61-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Man-to-man marking', 'Markers tuck in to cover',
    'Inside a man-to-man system the defensive principles still apply. While one marker presses his man on the ball, the other midfielders drop back and in to cover the presser while staying responsible for their own men. Each keeps both ball and man in view, picks his man up if he runs in behind, and presses at once if the ball goes to him. A marker may let his man drift back into his own half and wait for him.',
    'Opponent receives against his marker',
    'Stay compact with cover around the ball without losing anyone''s man.',
    NULL, 61, 64, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing marker (M3)', 'Presses his own man on the ball'),
    (2, 'Adjacent markers (M1, M2, M4)', 'Drop back and in, cover M3, keep their man in view and press if he receives'),
    (3, 'Forwards', 'Track overlapping defenders')
) AS v(so, role, job);

-- 46. pp.64-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Zonal defending', 'Zonal back line on a string',
    'Four (or three) defenders in a line move up, back and across together and never swap places. When one steps out to press, the others slide across and slightly behind him to cover. Each guards the space between himself and the next defender, picks up anyone who enters it and hands him on when he leaves. The closer to goal, the narrower the gaps.',
    'Ball moves or a defender steps out to press',
    'A compact back line that is hard to break and saves on chasing.',
    NULL, 64, 65, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing defender (D4 or D2)', 'Steps out of the line to press the ball'),
    (2, 'Other defenders', 'Slide across and slightly behind to cover, and close up nearer goal'),
    (3, 'Each defender', 'Marks anyone in his zone and hands him on to the next defender')
) AS v(so, role, job);

-- 47. pp.66-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Zonal defending', 'Zonal 4-4-2 shift to ball side',
    'In a zonal 4-4-2, when the ball goes to the opposing full back, the forwards slide across to press, the far centre backs slide toward the middle to close the gaps, and the far midfielder tucks in for balance. The team moves as a block but keeps its order: centre backs inside, full backs outside. The central pair can sit side by side, sharing holding and distributing, or one behind the other.',
    'Ball played to the opposing full back',
    'A compact, symmetrical block that is hard to get through.',
    NULL, 66, 67, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards (F1, F2)', 'Slide across to press the full back'),
    (2, 'Far centre backs (D3, D4)', 'Slide toward the middle to close gaps'),
    (3, 'Far wide midfielder (M4)', 'Drops inside for balance'),
    (4, 'Central midfield pair (M2, M3)', 'Share holding and distributing, or play one behind the other')
) AS v(so, role, job);

-- 48. pp.67-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Zonal defending', 'Break the system to stop a breakdown',
    'When the system fails, the nearest player deals with the danger even if he leaves his role. In man-to-man, if a man gets behind his marker and the sweeper is too far away, the closest defender leaves his own man to press, the sweeper or another defender picks up the man left free, and the beaten markers sprint back. In a zonal line, a striker dropping short is followed by his zone defender, and the neighbour follows the second runner into the gap. Normal roles return once the ball is won or goes dead.',
    'Runner gets behind his marker, or forwards make linked runs at a zonal line',
    'Pressure on the ball and every dangerous runner picked up, even if the shape is lost for a moment.',
    NULL, 67, 69, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender (X2 or D2)', 'Leaves his man or zone to press the ball, or follows the striker who drops short'),
    (2, 'Sweeper or neighbouring defender (X1, X4 or D3)', 'Picks up the man left free or the runner into the gap'),
    (3, 'Beaten and far markers (X5, X7, X8)', 'Sprint back to give cover and numbers')
) AS v(so, role, job);

-- 49. pp.69-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'How to decide on a marking system', 'Man-mark a direct or target-man attack',
    'Man-to-man works best when the defenders are fit, strong in duels and as quick as their opponents. It also works when the opponents play direct to the forwards or build through a target man, or have a poor first touch. Markers can stay tight and try to intercept passes to feet because the sweeper covers the ball in behind. Modern sweepers play closer to the markers so the line stays compact and can step up, but they cover less ground.',
    'Opponent plays long early to its forwards or target man',
    'Disrupt direct build-up and force many turnovers.',
    NULL, 69, 72, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Markers on the forwards', 'Mark tight and attack passes to feet'),
    (2, 'Sweeper', 'Covers balls in behind; plays close behind the markers to push the line up')
) AS v(so, role, job);

-- 50. pp.70-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'How to decide on a marking system', 'Beat man-to-man: drag sweeper, hit flank',
    'Against man-to-man with a sweeper, a forward holds the ball up so the sweeper is drawn across to cover him. He lays it back to a midfielder, who plays through into the empty flank, or out wide where a winger runs at his isolated marker while a teammate overlaps to make 2v1.',
    'Sweeper drawn toward a forward holding the ball',
    'Exploit gaps the markers leave and the lack of extra numbers out wide.',
    NULL, 70, 72, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding forward (1)', 'Receives, holds it to draw the sweeper, lays it back'),
    (2, 'Supporting midfielder', 'Plays it first time into the empty flank or out wide'),
    (3, 'Winger (3)', 'Runs at his isolated marker'),
    (4, 'Overlapping player (2)', 'Overlaps to make 2v1 in the wide channel')
) AS v(so, role, job);

-- 51. pp.71-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_attack', 'How to decide on a marking system', 'Counter from intact zonal shape',
    'Because zonal defenders stay in their areas, the team has its usual shape when it wins the ball, so practised counters and attacking patterns can be used. Man-markers get dragged out of position, so when the ball is won the shape is muddled and planned moves are hard to run.',
    'Ball won by a zonal team',
    'Counter straight away with rehearsed patterns from known positions.',
    NULL, 71, 72, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'Are in their usual spots when the ball is won and can start rehearsed patterns'),
    (2, 'Wide defenders', 'Are where teammates expect them for the counter')
) AS v(so, role, job);

-- 52. pp.72-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'How to decide on a marking system', 'Beat zonal line: drop-off and diagonal runs',
    'A zonal line struggles with players moving between zones. A striker who drops into midfield is often left free to turn because defenders do not want to leave the line. Diagonal runs across zones into the space behind a flat line, by the striker or by a midfielder arriving from deep, leave defenders watching the ball and unsure who to take. A well-timed run beats the offside trap and leaves a 1v1 with no cover.',
    'Flat zonal back line with no sweeper',
    'Receive between the lines and turn, or get through behind the line.',
    NULL, 72, 73, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'Drops between the lines to receive and turn, or runs diagonally behind'),
    (2, 'Attacking midfielder (8)', 'Runs late from deep across zones behind the line'),
    (3, 'Passer', 'Plays the through ball into the space behind')
) AS v(so, role, job);

-- 53. pp.72-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'How to decide on a marking system', 'Zonal line: hold line, offside, double-team',
    'Strengths of a well-run zonal line: it holds firm across the pitch, keeps the left and right defenders on their own sides, stays pushed up behind midfield, can double-team around the ball and can play offside. Defenders hold the line and let runners go offside instead of following them. The cost is constant talk and decisions, and it is harder for young players to learn.',
    'Runner sets off behind a flat line',
    'Run offside or let the next zone pick him up, keep the shape, and counter from an intact team.',
    NULL, 72, 74, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Holds the line together and steps up to catch runners offside'),
    (2, 'Defender in the zone', 'Picks up anyone who enters and passes him on'),
    (3, 'Players near the ball', 'Double-team the ball carrier')
) AS v(so, role, job);

-- 54. pp.74-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Combination of man-to-man and zonal defending', 'Zonal line plus a man-marker',
    'A hybrid against a creative attacking midfielder who times runs from deep behind a flat line: keep the zonal back line and give one player the job of marking him all game. Another hybrid puts a sweeper behind a zonal line to pick up runners from midfield, and he can also step up to defend the space in front of the defenders.',
    'Opponent has a dangerous deep runner',
    'Take out the main threat while keeping zonal compactness.',
    NULL, 74, 74, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Designated marker', 'Man-marks the opposing playmaker for the whole game'),
    (2, 'Zonal back line', 'Keeps its line and zones'),
    (3, 'Sweeper behind zonal line', 'Picks up runners from midfield and steps up in front of the defenders when needed')
) AS v(so, role, job);

-- 55. pp.74-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_defend', 'Pressing systems', 'Instant press on loss (gegenpress)',
    'Coaches choose where to start pressing: full-field, high or low. Many top sides flood the area around the ball the moment they lose it, because the team that has just won it is not yet in a possession shape. Pressing the whole pitch for 90 minutes is too tiring, so teams set a plan for when, where and how to press, and change it by opponent. The section continues past s074.',
    'Moment of losing possession',
    'Win the ball back in the few seconds before the opponents settle into a possession shape.',
    NULL, 74, 74, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players around the ball', 'Swarm the ball carrier at once'),
    (2, 'Coach''s press plan', 'Sets when, where and how to press for each opponent')
) AS v(so, role, job);

-- 56. pp.75-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Pressing Systems - High Pressure', 'Compact attacking block to enable pressing',
    'Team in possession deep in the other half (example 3-4-3) keeps lines close: defence pushed to halfway, midfield close to forwards.',
    'Ball advanced into the opponent''s half',
    'Everyone stays close enough that if the ball is lost the team can swarm it in numbers.',
    NULL, 75, 77, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Push up to the halfway line as the ball goes deep'),
    (2, 'Midfield', 'Stay close behind the forwards'),
    (3, 'Goalkeeper', 'Advance to the edge of the area to cover space behind')
) AS v(so, role, job);

-- 57. pp.75-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_defend', 'Pressing Systems - High Pressure', 'Full-field high pressure: hunt in packs',
    'Team has pushed everyone up, back line near halfway, while attacking in the opponent''s half; ball is lost there.',
    'Ball lost in the attacking half',
    'Win the ball back near the opponent''s goal before they can build out, so little distance is needed to score.',
    NULL, 75, 78, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player to ball', 'Press immediately at an angle that cuts the inside pass and steers the carrier toward the line or into a crowd'),
    (2, 'Second nearest player', 'Close cover, double-team the ball'),
    (3, 'Forwards', 'Block the back pass and the square pass to the centre backs'),
    (4, 'Rest of team', 'Push up and tight-mark every possible receiver'),
    (5, 'Far-side midfielders and defenders', 'Slide inside to give cover and be ready to re-press after a switch'),
    (6, 'Goalkeeper', 'Stand at top of the box to sweep up balls behind the high line')
) AS v(so, role, job);

-- 58. pp.77-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Pressing Systems - High Pressure', 'Selective high press situations',
    'Because full-time high pressure is tiring and risky (balls over the top, slow back line or keeper), the press is switched on only at chosen moments: first 10 minutes, when a weak-footed or technically suspect player has the ball, or when chasing the game late.',
    'Game phase, score, or a weak opponent on the ball',
    'Gain the initiative or force turnovers without being exposed all game.',
    NULL, 77, 78, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Spring the press on the signal player or moment'),
    (2, 'Back line and keeper', 'Must have pace to cover space behind; otherwise keep the press short')
) AS v(so, role, job);

-- 59. pp.77-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Pressing Systems - High Pressure', 'Play into corners and chase',
    'Team deliberately plays the ball deep into the opponent''s corners and sends two or three players to chase while the rest push up together to win any clearance.',
    'Opponent back line under no pressure; ball available to play long into corner',
    'Pin the opponent in the corner, win the ball, a throw-in or a corner high up.',
    NULL, 77, 78, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two or three chasers', 'Hunt the ball carrier in the corner'),
    (2, 'Rest of team', 'Push forward in concert to win clearances')
) AS v(so, role, job);

-- 60. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Pressing Systems - High Pressure', 'Crossing barrage with second-ball ring',
    'British-style repeated crosses into the box to wear down opponents, with forwards attacking every cross and midfielders arranged around the box.',
    'Ball in wide areas of the attacking third',
    'Create scoring chances from crosses and from knock-downs and clearances.',
    NULL, 78, 78, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Attack the cross aggressively'),
    (2, 'Midfielders', 'Ring the box to win second balls and knock-downs')
) AS v(so, role, job);

-- 61. pp.78-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Pressing Systems - Low Pressure', 'Low pressure: retreat and trigger zone (Italy 1994)',
    'On losing the ball the team drops back to a compact block (4-4-2 example, Italy 1994 under Sacchi) with forwards between halfway and about 10 yards into the opponent''s half; the opponent may keep the ball deep, but entry into a pre-set zone triggers aggressive pressure.',
    'Ball played into the pre-determined pressing area',
    'Stay compact, outnumber around the ball, need less keeper range and invite opponents forward to counter into the space behind them.',
    NULL, 78, 79, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Backtrack to the line just inside the opponent half and wait'),
    (2, 'Midfield and back four', 'Each unit pressed tight to the one ahead; flood around the ball once the zone is entered'),
    (3, 'Back four and keeper', 'Deal with balls over the top with pace and aggression'),
    (4, 'All', 'Never let an opponent receive and turn freely in own half')
) AS v(so, role, job);

-- 62. pp.79-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Channeling the Ball - Forcing the Ball Down the Line', 'Show the full back down the line (Sacchi Italy)',
    'Forwards let the centre backs build, but when the ball goes to an opposing wide back they close down from the inside so the only pass is down the flank.',
    'Pass to the opposing wide back',
    'Make the next pass predictable so midfielders can slide across and pounce on it with numbers; blind-side opponents become irrelevant.',
    NULL, 79, 81, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near forward', 'Close the wide back from the inside angle, forcing the pass down the line'),
    (2, 'Other forward', 'Screen the inside / square option'),
    (3, 'Midfielders', 'Cheat and slide toward the ball side to ambush the line pass'),
    (4, 'Back line', 'Shift across to the ball side')
) AS v(so, role, job);

-- 63. pp.81-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Channeling the Ball - Forcing the Ball Inside', 'Show the ball inside into midfield triangle (USA 1999)',
    'High-pressing 4-3-3 (US women, 1999 World Cup): the winger blocks the outside pass and forces the wide back inside onto her weaker foot, toward three compact central midfielders.',
    'Ball at the opposing wide back',
    'Win the ball centrally with physical midfielders, ideal spot to launch a counter.',
    NULL, 81, 82, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger', 'Block the line pass, force the carrier inside'),
    (2, 'Centre forward', 'Block the square pass to the centre back'),
    (3, 'Far winger', 'Sit to intercept or pressure any switch'),
    (4, 'Three central midfielders', 'Close triangle waiting to win the ball')
) AS v(so, role, job);

-- 64. pp.82-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Channeling the Ball', 'Inside in middle third, outside in defensive third',
    'Channeling direction depends on zone: force the ball inside into the crowded centre in the middle third, but force it wide in the defensive third so nobody dribbles inside into shooting range.',
    'Ball location (middle third vs defensive third)',
    'Use the crowded centre to win the ball while keeping danger away from goal.',
    NULL, 82, 83, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing player in midfield third', 'Approach from outside to show inside'),
    (2, 'Pressing defender in defensive third', 'Approach from inside to show outside toward the line')
) AS v(so, role, job);

-- 65. pp.83-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Channeling the Ball', 'Channel by opponent''s strong foot',
    'Against a winger who likes to beat men on the outside and cross, show him inside; against an inverted winger cutting in to shoot, show him outside; generally force a player onto his weaker foot.',
    'Known individual tendency of the ball carrier',
    'Steer the ball where the opponent is least effective and duels are most winnable; keep it simple for youth.',
    NULL, 83, 83, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing defender', 'Choose the approach angle from scouting on the opponent''s strong side')
) AS v(so, role, job);

-- 66. pp.84-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The 4-4-2 Formation', 'Box midfield 4-2-2-2 (Brazil)',
    '4-4-2 with a box midfield: two holding midfielders behind two attacking midfielders, flanks left for the wide backs.',
    'Team in possession, flanks open',
    'Both wide backs can attack freely because the two holders and two centre backs stay back to cover.',
    NULL, 84, 84, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two holding midfielders', 'Rarely go forward; provide cover'),
    (2, 'Two attacking midfielders', 'Play behind the forwards'),
    (3, 'Wide backs', 'Overlap and attack at will')
) AS v(so, role, job);

-- 67. pp.84-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The 4-4-2 Formation', '4-4-2 wide backs overlap for width',
    'In a 4-4-2 the wide backs join the attack by overlapping, sharing flank width with the wide midfielders, especially when the opponent plays one or two forwards and no wingers to mark.',
    'Possession with no opposing winger to track',
    'Two players per flank create width and penetration and let a tired wide midfielder rest while the back overlaps.',
    NULL, 84, 87, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide back', 'Overlap to provide width and flank penetration'),
    (2, 'Wide midfielder', 'Tuck in or stay wide in tandem with the overlap'),
    (3, 'Remaining three defenders', 'Stay home to cover')
) AS v(so, role, job);

-- 68. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_attack', 'The 4-4-2 Formation', 'Outlet to the free wide back',
    'When the ball is won centrally and no forward pass is on, it goes square to a wide back (or back to a centre back who switches it out wide).',
    'Regain in central midfield, forward pass blocked',
    'The wide back has time and space, buys time for the team to regain attacking shape and can start a counter down the flank.',
    NULL, 85, 85, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Play square to the wide back or back to a centre back'),
    (2, 'Wide back', 'Receive in space, hold or launch the counter down the line'),
    (3, 'Centre back', 'Recycle out to the wide back')
) AS v(so, role, job);

-- 69. pp.85-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'The 4-4-2 Formation', 'Wide midfielders tuck in, wide backs press wide',
    'To avoid being outnumbered centrally (vs 3-5-2 or 4-5-1 crowding midfield), wide midfielders tuck inside and the wide back steps out from a narrow starting spot to close the opposing wide midfielder when the ball goes wide.',
    'Ball played to the opposing wide midfielder',
    'Numbers-up in the centre, an extra defender still covering, and a free midfielder to double up.',
    NULL, 85, 87, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide back (D4)', 'Start inside near the centre back; close the ball fast when played wide; return to cover if switched'),
    (2, 'Opposite full back (D1)', 'Pressure if the ball is switched to his side'),
    (3, 'Tucked wide midfielders', 'Stay inside to outnumber the centre'),
    (4, 'Defensive midfielder (M2)', 'Free player: double up on a forward who receives, or sit as cover'),
    (5, 'Wide midfielder (M3)', 'Can double up with the wide back on the wide player')
) AS v(so, role, job);

-- 70. pp.87-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The 4-4-2 Formation', 'Strike pair complementary runs',
    'The two forwards stay central and close; when one checks toward the ball the other runs away into space behind, or both peel laterally to drag markers out and open the middle for an attacking midfielder.',
    'Midfielder on the ball facing forward',
    'Give the passer the option to feet or into space, and create a lane through the middle.',
    NULL, 87, 89, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First forward', 'Show for the ball to feet; spin toward the box after a pass to his partner'),
    (2, 'Second forward', 'Run in behind the defence away from the ball'),
    (3, 'Attacking midfielder', 'Slice into the space vacated in the middle'),
    (4, 'Midfielder on ball', 'Choose feet or space')
) AS v(so, role, job);

-- 71. pp.88-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The 4-4-2 Formation', 'Forwards receive central, not wide',
    'Forwards should get the ball in the central shaded zone in front of goal rather than drifting to the touchline, where they face backwards, have few options and get double-teamed.',
    'Forward choosing where to show',
    'Keep forwards dangerous near goal, leave flanks for wide runners and keep many combinations open.',
    NULL, 88, 90, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Show in central areas; avoid receiving with back to field on the line'),
    (2, 'Wide midfielder', 'Attack the flank space left open; early cross or take on and cross')
) AS v(so, role, job);

-- 72. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_attack', 'The 4-4-2 Formation', 'Drop a forward to avoid isolation',
    'When the eight behind the ball defend in a deep block a big gap opens to the two forwards and long balls get intercepted.',
    'Team defending deep, forwards cut off',
    'Keep a link for the counter; otherwise counter through the wide midfielders with the forwards.',
    NULL, 89, 89, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'One forward', 'Drop deeper to connect with midfield'),
    (2, 'Wide midfielders', 'Break out on the flanks with the forwards')
) AS v(so, role, job);

-- 73. pp.89-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'The 4-4-2 Formation', '4-4-2 forwards force play to a dead end',
    'The forwards apply first pressure on the opposing defenders: one closes the ball carrier at an angle that pushes play down one flank, the other cuts the route back across to the other centre back.',
    'Opposing centre back or full back receives (e.g. from the keeper)',
    'Condense play onto one side so teammates can anticipate and double-team; the ball ends in a dead end.',
    NULL, 89, 90, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward on ball (F1)', 'Angle the approach to show the ball down the flank'),
    (2, 'Other forward (F2)', 'Close the other centre back to block the switch round the back'),
    (3, 'Ball-side full back (D1)', 'Close the wide midfielder in anticipation'),
    (4, 'Far wide midfielder (M3)', 'Slide inside since the far switch is blocked'),
    (5, 'Ball-side midfielder (M1)', 'Free to double-team the next receiver')
) AS v(so, role, job);

-- 74. pp.90-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'The 4-4-2 Formation', 'Back four adapts to forward count',
    'A flat four can handle one, two or three forwards without changing system: vs one forward the wide backs step into midfield; vs three the four cope alone.',
    'Opponent''s number of forwards',
    'Stable platform without disrupting rhythm, unlike a back three facing three forwards.',
    NULL, 90, 91, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide backs', 'Step into midfield against a lone forward'),
    (2, 'Back four', 'Handle three forwards without extra midfield help')
) AS v(so, role, job);

-- 75. pp.91-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_defend', 'The 3-5-2 Formation', '3-5-2 drops to 5-3-2',
    'In a 3-5-2 the wide midfielders drop into line with the three defenders when the ball is lost, because opponents'' forwards staying central open big spaces beside the back three.',
    'Possession lost',
    'Close the flank spaces beside a back three; the system depends on how fast this transition happens.',
    NULL, 91, 96, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielders', 'Sprint back into the back line, shuttling box to box'),
    (2, 'Three defenders', 'Hold the centre')
) AS v(so, role, job);

-- 76. pp.92-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The 3-5-2 Formation', 'Attacking sweeper step-up (German 3-5-2)',
    'With two man-markers and a sweeper, the sweeper (Beckenbauer model) steps into midfield to start attacks while the defensive midfielder drops into the back line to keep three at the back.',
    'Sweeper has the ball or space ahead of him',
    'Sweeper arrives unmarked in midfield and is hard to pick up.',
    NULL, 92, 92, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Sweeper', 'Step up into midfield as distributor'),
    (2, 'Defensive midfielder', 'Drop into the back three to cover'),
    (3, 'Man-markers', 'Stay tight on their forwards even in possession')
) AS v(so, role, job);

-- 77. pp.92-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'The 3-5-2 Formation', 'Flat zonal three with weak-side wide midfielder',
    'A zonal back three does not cover the full width; they slide across and stay close together, while the far wide midfielder drops level to cover the weak side, looking like a back four.',
    'Ball on the far flank',
    'Balance on the weak side: wide midfielder beats attackers to balls behind and intercepts switches to start a counter.',
    NULL, 92, 92, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'Slide toward the ball and stay compact'),
    (2, 'Weak-side wide midfielder', 'Drop back facing upfield to cover the danger zone and intercept square balls')
) AS v(so, role, job);

-- 78. pp.93-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The 3-5-2 Formation', 'Five-man midfield possession and late runs',
    'A 3-5-2 floods the centre to outnumber a four-man midfield, keeps the ball patiently and springs one of two attacking midfielders from deep at the right moment (Portugal and Romania vs England, Euro 2000).',
    'Possession settled in midfield against a 4-4-2',
    'Dominate possession and break the defence with unmarked runs from deep.',
    '4-4-2', 93, 95, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder', 'Sit in front of the defence'),
    (2, 'Two attacking midfielders', 'Support forwards and time runs beyond them'),
    (3, 'Wide midfielders', 'Provide width or act as distributor if lacking pace'),
    (4, 'At least one central midfielder', 'Must make forward runs so the midfield does not clog with short square passes')
) AS v(so, role, job);

-- 79. pp.95-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_attack', 'The 3-5-2 Formation', 'Inside players run the flank on counters',
    'When the 3-5-2 wide midfielder is too deep after defending, a central midfielder or forward makes a diagonal run out to the flank.',
    'Regain with wide midfielder deep',
    'Keep counter momentum without waiting for the wide player.',
    NULL, 95, 95, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder or forward', 'Diagonal run inside to outside'),
    (2, 'Wide midfielder', 'Join later')
) AS v(so, role, job);

-- 80. pp.96-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'The 3-5-2 Formation', '3-5-2 forwards force the ball inside',
    'Because the flanks are the weak spot of a 3-5-2, the forwards start wide when the opponent builds from the back and approach so as to invite the pass inside toward three central midfielders.',
    'Opponent building from the back',
    'Funnel the ball into the strong central triangle rather than the exposed flanks.',
    NULL, 96, 96, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Start wide, approach from outside to show the ball inside'),
    (2, 'Three central midfielders', 'Wait to win the ball')
) AS v(so, role, job);

-- 81. pp.96-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'The 3-5-2 Formation', 'Adjust 3-5-2 vs three forwards',
    'Against three forwards a back three is too risky: drop the defensive midfielder into the back line to play four with the sweeper behind three markers, or pull a forward back for 4-5-1.',
    'Opponent fields three forwards',
    'Avoid numbers-even at the back.',
    '4-3-3', 96, 96, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Drop into the back line'),
    (2, 'Sweeper', 'Stay behind three markers'),
    (3, 'One forward', 'Optionally drop to midfield (4-5-1)')
) AS v(so, role, job);

-- 82. pp.97-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The 4-3-3 Formation', '4-3-3 winger stance: hug the line, open body',
    'In build-up from own half the wingers stay very wide on the touchline facing inside with an open body, below the striker so they can time runs; each decides to show to feet, run behind or stay for a switch based on his marker.',
    'Midfielder facing forward with the ball in own half',
    'Give the passer multiple options (feet, in behind, switch) and stretch the defence; the far winger attacks the box once the ball reaches the final third.',
    NULL, 97, 99, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'Hug the line, open stance, start slightly deeper than striker; choose pass to feet, run behind or wait for switch'),
    (2, 'Striker', 'Push high, back to goal, stay central as target; keep out of wingers'' lanes'),
    (3, 'Far winger', 'Sprint into the box when the ball enters the attacking third'),
    (4, 'Midfield triangle', 'Stay compact in centre, not spread across')
) AS v(so, role, job);

-- 83. pp.98-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The 4-3-3 Formation', 'Midfield runs and full back overlaps break 4-3-3 predictability',
    'Because three forwards tend to stay in lanes, midfielders run beyond the defence between the forwards or swap with the striker, and wide backs overlap for 2v1 on the flank.',
    'Attack becoming static',
    'Add surprise and variety; interchange between units makes the 4-3-3 hard to stop.',
    NULL, 98, 101, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder', 'Run behind the defence between forwards or interchange with the striker'),
    (2, 'Striker', 'Drop to swap with the midfielder'),
    (3, 'Wide backs', 'Overlap to create 2v1 with the winger'),
    (4, 'Forwards', 'Keep shape rather than chaotic interchange')
) AS v(so, role, job);

-- 84. pp.101-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_defend', 'The 4-3-3 Formation', '4-3-3 forwards as first defenders; wingers drop to 4-5-1',
    'When the 4-3-3 loses the ball the forwards defend first: in a high press they push against the defenders; when retreating the wingers drop into midfield for a 4-5-1, always tracking overlapping full backs.',
    'Possession lost',
    'Either win the ball early or restore midfield numbers.',
    NULL, 101, 101, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Press defenders high when the plan says so'),
    (2, 'Wingers', 'Drop into midfield to make 4-5-1; follow overlapping opposing full backs')
) AS v(so, role, job);

-- 85. pp.102-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'The 4-3-3 Formation', 'Closing the 4-3-3 wide pockets',
    'Empty wide-midfield pockets between defenders and wingers: the wide back steps up to challenge the opposing wide midfielder; versus three forwards a midfielder must close instead.',
    'Opponent receives in the wide pocket',
    'No danger as long as someone enters the zone quickly and the winger tracks the overlapping defender.',
    NULL, 102, 102, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide back', 'Step up and close the ball in the pocket'),
    (2, 'Midfielder', 'Close the pocket when the wide back is pinned by a third forward'),
    (3, 'Winger', 'Follow the overlapping opposing defender')
) AS v(so, role, job);

-- 86. pp.102-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The 3-4-3 Formation', '3-4-3 possession in advanced areas (Ajax)',
    '3-4-3 with a diamond midfield (holder, two wide, one attacking): wide midfielders combine with wingers or tuck in for a compact diamond; the three defenders distribute early and stay to cover; the team keeps the ball in the opponent''s half until a defence-splitting pass appears.',
    'Settled possession',
    'Dictate the game in the opponent''s half with numbers in attack and midfield.',
    NULL, 102, 103, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three defenders', 'Build quickly with early distribution, rarely overlap, stay and cover'),
    (2, 'Holding midfielder', 'Anchor behind the diamond'),
    (3, 'Wide midfielders', 'Combine with wingers on the flank or tuck in'),
    (4, 'Attacking midfielder', 'Make runs beyond the forwards, covered by the other three')
) AS v(so, role, job);

-- 87. pp.103-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_defend', 'The 3-4-3 Formation', 'Risk: diagonal ball beats a high-pressing back three',
    'A 3-4-3 committing to high pressure is vulnerable to a long diagonal pass from the opponent''s back line to the far flank, which three defenders cannot cover across the width; versus three forwards the holder must drop or the back three accepts numbers-even.',
    'Opponent escapes the press with a long diagonal switch',
    'Be aware of the exposed far flank; a back four handles such passes better.',
    NULL, 103, 103, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'Recover across to the far flank'),
    (2, 'Defensive midfielder', 'Drop in against three forwards')
) AS v(so, role, job);

-- 88. pp.104-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Variations - Italy in Euro 2000', 'No attacking midfielder, rotate into the hole (Italy 2000)',
    'Italy (Zoff, Euro 2000) played a flat 4-4-2 with two holding midfielders and no playmaker: forwards took turns dropping into the hole to receive and spin, or one holder stepped into it while the other stayed home.',
    'Ball in midfield, space in front of the back line',
    'Solid central cover, freedom for wide backs and wide midfielders to overlap, and surprise over who arrives in the hole.',
    NULL, 104, 105, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Alternate dropping into the hole to receive and turn'),
    (2, 'Holding midfielders (Di Biagio, Baggio)', 'One steps into the hole, the other stays to cover'),
    (3, 'Wide backs and wide midfielders', 'Overlap freely')
) AS v(so, role, job);

-- 89. pp.105-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_attack', 'Variations - France in 1998', 'Compact 4-3-3 with two withdrawn forwards (France 1998)',
    'France 1998: two holding midfielders (Petit, Deschamps), free-role Zidane, one high striker with two forwards tucked inside behind him (2-1-2-1 / 4-5-1 in defence); no true wingers.',
    'Regain from a compact defensive block',
    'Compact when defending, then unpredictable breaks as withdrawn forwards run diagonally to wide spaces and wide backs overlap.',
    NULL, 105, 106, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two holding midfielders', 'Win the ball and cover so others can roam'),
    (2, 'Playmaker (Zidane)', 'Free role'),
    (3, 'Withdrawn forwards', 'Diagonal runs into wide spaces on the break'),
    (4, 'Wide backs', 'Overlap to give width'),
    (5, 'Lone striker', 'Hold high as target')
) AS v(so, role, job);

-- 90. pp.106-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Variations - Playing With Only One Forward', 'Lone target forward vs flat back four',
    'One strong target forward holds the ball while the rest flood midfield; a flat four tends to mark only him, so withdrawn strikers and midfielders get space in the hole in front of the back four.',
    'Opponent plays a flat back four reluctant to step out',
    'Numbers-up in midfield and withdrawn strikers receiving and turning to run at the back line; build-up must go through midfield, not long balls.',
    NULL, 106, 107, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lone striker', 'Hold the ball with back to goal until help arrives, run to stay available'),
    (2, 'Withdrawn strikers / attacking midfielders', 'Receive in the hole, turn and attack the back line; slashing runs past the striker'),
    (3, 'Midfield', 'Flood the centre and support quickly')
) AS v(so, role, job);

-- 91. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Variations - Playing With Two Defensive Midfielders', 'Double anchor screens the hole',
    'Two defensive midfielders (France, Italy, Brazil) clog the space in front of the defence and give cover so defenders and other midfielders can attack; anchors must also pass and score (Petit, Davids).',
    'Opponent trying to play into the hole',
    'Deny penetration through the hole while freeing others to attack.',
    NULL, 107, 107, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two anchoring midfielders', 'Screen the hole, tackle, then distribute or arrive to score'),
    (2, 'Defenders and other midfielders', 'Attack with more freedom thanks to the cover')
) AS v(so, role, job);

-- 92. pp.107-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Variations - Romania in Euro 2000', 'Sweeper behind four, push wide backs when behind',
    'Romania (Euro 2000) defended deep with a sweeper behind a back four, two holders and free playmaker Hagi with two forwards (1-4-3-2) and countered; when trailing, the wide backs pushed into wide midfield to become 3-5-2.',
    'Falling behind in the score',
    'Switch from a deep counter-attacking block to more attacking numbers.',
    NULL, 107, 108, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Sweeper', 'Cover behind the back four'),
    (2, 'Playmaker (Hagi)', 'Free of defensive duties, launches counters'),
    (3, 'Wide backs', 'Push into wide midfield when chasing the game')
) AS v(so, role, job);

-- 93. pp.108-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Variations - Brazilian System 1982 to 1998', 'Brazilian 4-2-2-2: both full backs overlap',
    'Brazil''s box-midfield 4-2-2-2 sends both wide backs forward at once (unlike European one-up-one-in); the holding midfielders stay and cover.',
    'Possession with flanks open',
    'Width on both sides from the full backs while cover is kept centrally.',
    NULL, 108, 109, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Both wide backs', 'Push high and wide simultaneously'),
    (2, 'Holding midfielder', 'Slot into vacated full-back space or drop between the centre backs'),
    (3, 'Centre backs', 'Hold the middle')
) AS v(so, role, job);

-- 94. pp.109-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Variations - Brazilian System 1982 to 1998', 'Brazilian forwards split: one combines, one waits blind side',
    'Brazilian forwards stay apart: the ball-side forward shows to feet or runs behind to combine with the overlapping back and attacking midfielder, while the second forward drifts away to the blind side ready for a long switch 1v1; the split opens a lane for a midfielder through the middle.',
    'Wide back in possession on one flank',
    'Ball-side triangle penetrates the flank; if not, switch to the isolated forward or far back for a 1v1 near goal or through-ball run.',
    NULL, 109, 111, 940)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side forward', 'Show to feet or run behind for a through ball'),
    (2, 'Overlapping wide back', 'Combine with forward and midfielder on the flank'),
    (3, 'Attacking midfielder', 'Support; options: through ball, switch to second forward''s feet, ball in behind, or pass to a midfielder running the middle'),
    (4, 'Second forward', 'Slide away to the blind side, attack the goal on a switch'),
    (5, 'Far wide back', 'Stay wide awaiting the switch')
) AS v(so, role, job);

-- 95. pp.111-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Variations - Brazilian System 1982 to 1998', 'Flank, drop, long diagonal switch',
    'Brazilian teams switch play often: ball into the flank, drop pass to a supporting player, then a long diagonal to the far wide back or forward, to feet or into space; forwards are happy receiving wide with back to play.',
    'Opponent shifted to the ball side',
    'Stretch and unbalance the defence with one long pass to the open side.',
    NULL, 111, 111, 950)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player', 'Receive in the flank and lay back'),
    (2, 'Supporting player', 'Hit the long diagonal'),
    (3, 'Far wide back or forward', 'Receive the switch to feet or in space')
) AS v(so, role, job);

-- 96. pp.112-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Variations of traditional formations - rigid defensive block behind flexible attack', 'Six-man block, free attacking trio',
    'Portugal at Euro 2000 in a 4-2-3-1: a flat zonal back four and two holding midfielders stay put while three skilful attacking midfielders roam and swap freely behind a lone striker.',
    'Team in settled possession in the middle third',
    'The striker pins both centre backs so the wide defenders are left alone to face 1v1 dribblers, while the six behind keep the team safe on the turnover.',
    NULL, 112, 113, 960)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lone forward', 'Stay high and central, occupy both centre backs'),
    (2, 'Wide attacking midfielder (Figo)', 'Start wide, beat the full back outside to cross or cut in to shoot; without the ball lurk wide then ghost into the hole'),
    (3, 'Three attacking midfielders', 'Interchange positions freely, seek 1v1 duels with defenders'),
    (4, 'Back four + two holding midfielders', 'Hold a rigid zonal block of six, do not join the attack')
) AS v(so, role, job);

-- 97. pp.113-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Three at the back - defending zonally', 'Zonal back three wall',
    'Instead of two man-markers plus a sweeper, three central defenders defend zonally as one unit; the wide defenders are replaced by wide midfielders who must drop back to guard the flanks.',
    'Opposing forwards rotate or pull markers out of position',
    'A compact three-man wall that clever forward movement cannot pull apart, without spending extra players at the back.',
    NULL, 113, 113, 970)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three central defenders', 'Move together as a zonal line, hand runners on rather than following them'),
    (2, 'Wide midfielders', 'Drop back to defend the flanks whenever the ball is wide'),
    (3, 'Defensive midfielders', 'Screen in front of the three')
) AS v(so, role, job);

-- 98. pp.114-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Brazil in 2002 - 3-6-1 with zonal defending', 'Shape oscillates 5-4-1 / 3-6-1 / 3-2-5',
    'Scolari''s Brazil (2002 World Cup) used a flat zonal back three, two holding midfielders, wing backs Cafu and Roberto Carlos, two free creators (Ronaldinho, Rivaldo) and Ronaldo high and central. The shape changes with the phase.',
    'Phase of play: defending, building in midfield, or entering the final third',
    'Defend with five at the back, build with six in midfield and attack with five up front, keeping defensive cover while giving wing play.',
    NULL, 114, 114, 980)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing backs (Cafu, Roberto Carlos)', 'Drop into the back line when defending, become wingers when attacking'),
    (2, 'Two defensive midfielders (Gilberto Silva, Kleberson)', 'Protect the back three and give midfield cover; second holder added after 3-5-2 proved fragile'),
    (3, 'Attacking midfielders (Ronaldinho, Rivaldo)', 'Free to pop up anywhere, but drop back to chase and tackle on the loss'),
    (4, 'Lone striker (Ronaldo)', 'Stay high and central')
) AS v(so, role, job);

-- 99. pp.114-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Positions and their role - sweeper, central defender, defensive midfielder', 'Sweeper and holding midfielder cover',
    'With a sweeper, the central defenders mark man-to-man while the free sweeper sits behind them to sweep through balls, slide wide to make 2v1 or step up to press; the holding midfielder acts as a second sweeper in the hole in front of the defence.',
    'Through ball, or a defender beaten wide',
    'Always have a spare covering player behind and in front of the defence so the space behind and the hole are protected.',
    NULL, 114, 115, 990)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Sweeper', 'Organise, cover space behind, intercept through balls, sprint wide for 2v1, step up to pressure when free'),
    (2, 'Central defenders', 'Mark the target forward tightly, stop him turning, play simple'),
    (3, 'Defensive midfielder', 'Hold the hole, mark the attacking midfielder, win the ball, release with one or two touches'),
    (4, 'Keeper', 'Come off the line to sweep through balls behind the defence')
) AS v(so, role, job);

-- 100. pp.115-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_defend', 'Positions and their role - forward, wide midfielder, defensive midfielder', 'Forwards as first defenders',
    'When the ball is lost, the forwards immediately close down the ball in the opponent''s half while the wide midfielders sprint back into midfield to pick up opponents and the holding midfielder snuffs out the counter.',
    'Loss of possession in the attacking half',
    'Win the ball back high or at least delay the opponent long enough for teammates to recover behind the ball.',
    NULL, 115, 116, 1000)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Close the ball down at once in the opponent''s half, contain if they cannot win it'),
    (2, 'Wide midfielders', 'Recover back into midfield and pick up an opponent'),
    (3, 'Defensive midfielder', 'Stay in the hole, stop the counterattack at source')
) AS v(so, role, job);

-- 101. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_defend', 'Selecting a system of play - attack or counterattack', 'Drop off and counter with pace',
    'A team lacking speed at the back, or overall fitness, drops back into its own half whenever the ball is lost, stays compact and relies on quick, skilful forwards to break.',
    'Ball lost; team without speed in the back line',
    'Remove the dangerous space behind a slow defence and keep players close enough to cover each other, then counter with the forwards.',
    NULL, 117, 117, 1010)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'Retreat into own half on the loss and stay compact'),
    (2, 'Defenders', 'Avoid being isolated 1v1, cover each other'),
    (3, 'Quick forwards', 'Stay available as the counterattack outlet')
) AS v(so, role, job);

-- 102. pp.122-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_attack', 'Planning a practice session - the game analysis (breakdown scenario)', 'Back line drops to receive on regain',
    'A 4-4-2 that wins the ball in midfield keeps losing it because the back line does not drop and spread, so defenders receive under immediate pressure and hit rushed balls to forwards running into the touchline.',
    'Ball won by a midfielder in own half',
    'Defenders back-pedal into an open possession shape so the back has time on the ball, the team can breathe and wide players can receive facing the field.',
    NULL, 122, 123, 1020)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Drop off quickly and spread to offer an easy, safe outlet'),
    (2, 'Wide back on the ball', 'Use the extra time to pick a good forward pass instead of rushing'),
    (3, 'Wide midfielders', 'Get width and offer angled support facing the field'),
    (4, 'Strikers', 'Do not have to sprint to the sidelines to show; receive in better positions')
) AS v(so, role, job);

-- 103. pp.126-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The ''situational'' approach - situation 1: wide back with the ball in the defending third', 'Wide back as quarterback shape',
    'In a 4-4-2, whenever a full back has the ball in his own third the whole team snaps into one agreed shape: centre backs support behind, wide midfielders give width, forwards stretch the field.',
    'Ball reaches a wide back in the defending third',
    'Give the full back several good passing options every time, with runs chosen from the opponent''s reaction.',
    NULL, 126, 128, 1030)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide back', 'Springboard of the attack; pick the best option from the shape'),
    (2, 'Centre backs', 'Support from behind the ball'),
    (3, 'Wide midfielders', 'Provide width; the far one runs through'),
    (4, 'Forwards', 'One checks towards the ball, the other attacks the space behind the defence')
) AS v(so, role, job);

-- 104. pp.129-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The ''situational'' approach - situation 2: wide midfielder with the ball in the middle third', 'Back-door run by far winger',
    'With the wide midfielder on the ball in the middle third, the holding midfielder supports close and slightly behind to switch it, and he plus three defenders form a four-man block even when a full back overlaps.',
    'Wide midfielder in possession in the middle third',
    'Penetrate the attacking third through overlaps and diagonal runs, especially the opposite midfielder''s surprise run in behind, while staying balanced against the counter.',
    NULL, 129, 129, 1040)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back', 'Overlap'),
    (2, 'Forward', 'Blind-side diagonal run'),
    (3, 'Attacking midfielder', 'Run into the space the forward vacates'),
    (4, 'Far-side wide midfielder', 'Back-door run in behind for a long diagonal or bent pass'),
    (5, 'Defensive midfielder + three defenders', 'Four-man block against the counter; holder offers the switch'),
    (6, 'Keeper', 'Edge of the box as sweeper-keeper')
) AS v(so, role, job);

-- 105. pp.129-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The ''situational'' approach - situation 3: central midfielder under pressure facing own goal', 'Back-pedal and recycle when pinned',
    'A central midfielder receives or wins the ball with his back to goal and pressure on him; rather than turn into pressure, he lays it back.',
    'Central midfielder on the ball, facing own goal, under pressure',
    'Keep the ball, relieve pressure and buy time for midfield and forwards to regain an attacking shape; also takes the sting out after a long spell defending.',
    NULL, 129, 130, 1050)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'Do not turn; play back to a defender'),
    (2, 'Defenders', 'Back-pedal automatically and call for the ball back'),
    (3, 'Midfielders and forwards', 'Use the time to spread into an attacking shape')
) AS v(so, role, job);

-- 106. pp.130-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_attack', 'The ''situational'' approach - situation 4: central midfielder facing up field', 'Faced-up midfielder plays forward',
    'A midfielder wins or receives the ball facing up field with space: a key transition moment that should produce quick, decisive penetration.',
    'Midfielder ''faced up'' with the ball in midfield',
    'Get opponents turned with forward passes into runs behind, while keeping one support so the ball carrier is not isolated.',
    NULL, 130, 130, 1060)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder on the ball', 'Look forward first and play it forward'),
    (2, 'Players ahead of the ball', 'Run in behind defenders'),
    (3, 'Players level or behind the ball', 'Run outward to create width'),
    (4, 'One forward', 'Stay as stationary support to check to the ball')
) AS v(so, role, job);

-- 107. pp.130-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The ''situational'' approach - situation 5: player wide in the attacking third, about to cross', 'Crossing shape with clearance pickers',
    'A player is wide in the attacking third ready to cross. Not everyone sprints into the box: the shape fills the box, gives a safe support behind the crosser, leaves players on the edge for clearances and keeps a covering block.',
    'Wide player in position to cross',
    'Attack the cross with numbers while preventing the gap between attack and defence that lets the opponent chase its own clearance and counter.',
    NULL, 130, 131, 1070)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Box attackers', 'Get into the box to meet the cross'),
    (2, 'Support player', 'Safe option behind the ball if the crosser is pressed'),
    (3, 'Edge-of-box players', 'Stay outside the area to pounce on clearances'),
    (4, 'Rear block', 'Maintain cover against the counterattack')
) AS v(so, role, job);

-- 108. pp.131-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_attack', 'The ''situational'' approach - situation 6: goalkeeper catches a cross', 'Keeper''s catch launches counter',
    'The keeper has just gathered a cross; most teammates break with runs aimed at penetration.',
    'Keeper catches a cross',
    'Exploit the opponent''s committed attackers with a fast, direct counter.',
    NULL, 131, 131, 1080)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'First look long for a quick throw or punt; next best is wide to the flank opposite where the cross came from'),
    (2, 'Outfield players', 'Break out and make penetrating runs')
) AS v(so, role, job);

-- 109. pp.133-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Generic activity: penetration', 'Work it to a faced-up player',
    'Narrow, long game with target players: the team in possession tries to get the ball to a player facing the opponent''s goal with time, using pass-and-follow or lay-off combinations.',
    'Forward pass available',
    'Penetrate rather than circulate; never play square when forward is on.',
    NULL, 133, 134, 1090)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player on the ball', 'Play forward to the target whenever possible'),
    (2, 'Nearest teammates', 'Sprint immediately to support the forward pass, set up a lay-off for the faced-up player')
) AS v(so, role, job);

-- 110. pp.134-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Generic activity: possession', 'Possession with uneven numbers',
    '6v4 possession: the side with extra players uses the whole area with quick one- and two-touch passing; the outnumbered side shields and dribbles out of tight spaces.',
    'Numbers up in own third or numbers down in the attacking third',
    'Players read the pressure and know when to hold the ball and when to release it first time.',
    NULL, 134, 134, 1100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Team with numbers up', 'Keep good support angles, use full width and depth, move it quickly'),
    (2, 'Team with numbers down', 'Shield, dribble out of trouble, keep the ball under pressure')
) AS v(so, role, job);

-- 111. pp.134-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_defend', 'Generic activity: pressure on transition / pressing in defense', 'Close the ball instantly on loss',
    'The moment the ball is lost (or right after scoring), the nearest players close the ball fast and press frontally to block the forward pass to the target.',
    'Loss of possession or own goal scored',
    'Deny the penetrating pass, force backward or square passes and win the ball back anywhere on the pitch.',
    NULL, 134, 136, 1110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost the ball', 'Turn and defend at once'),
    (2, 'Nearest defender', 'Close the ball down quickly, from the front, to block the forward pass'),
    (3, 'Rest of team', 'Press across the area to win the ball')
) AS v(so, role, job);

-- 112. pp.137-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Generic activity: cover in defense', 'Pressure, cover and slide',
    'In a three-defender group, one presses the ball, the middle defender takes a covering position behind him and the far one tucks in behind the middle; when a square pass goes across, the receiving-side defender intercepts if he can, else presses while teammates slide behind him.',
    'Ball carrier approached; square pass across the group',
    'Solid cover that discourages passes behind and invites square passes, with roles shifting each pass.',
    NULL, 137, 138, 1120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First defender', 'Apply immediate pressure on the ball'),
    (2, 'Covering defender', 'Behind and at an angle to the presser, communicate'),
    (3, 'Far defender', 'Tuck inside and slightly behind the cover; on a square pass intercept or press')
) AS v(so, role, job);

-- 113. pp.138-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Generic activity: setting a defensive trap', 'Channel into dead-end corner',
    'Defenders approach on a bent line to get goal-side, then shepherd the attacker away from goal toward the touchline corner and away from his support, flood that zone and pounce.',
    'Attacker driven into the ''dead end'' area: the ''point of no return''',
    'Create numbers up (2v1), isolate the ball carrier and win the ball or force it out, without opening the shooting lane.',
    NULL, 138, 140, 1130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First defender', 'Curved approach, then channel toward the sideline and block the pass back to support'),
    (2, 'Covering defender', 'Stay close enough to pounce, block the shot, call when to tackle'),
    (3, 'Third defender', 'Provide cover and balance, guard the shot'),
    (4, 'Pair at the trap', 'Commit together at the point of no return')
) AS v(so, role, job);

-- 114. pp.140-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Generic activity: switching the point of attack', 'Spread shape to switch',
    'In a wide, short game with goals in the corners, if the near goal is crowded the team switches to the far side; bunched players cannot switch, so the shape stays spread with a safe support behind the ball.',
    'Ball side heavily defended',
    'Move the ball quickly to the weak side and attack there.',
    NULL, 140, 141, 1140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Support player behind the ball (X2)', 'Offer the easy outlet that carries the switch'),
    (2, 'Attacking players', 'Keep spread across the width, do not crowd one side')
) AS v(so, role, job);

-- 115. pp.142-143
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Functional activity: wide defender playing out of the back', 'Full back starts the attack',
    'The keeper throws to the left defender, who must bring the ball into the other half, first unopposed then with a forward pressing him.',
    'Keeper''s throw to the wide defender',
    'Full back picks the right option and delivery, then joins the attack.',
    NULL, 142, 143, 1150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide defender', 'Good first touch, pick a pass to wide midfielder, forward''s feet, second forward''s run, attacking or defensive midfielder, or dribble forward; under pressure go back to keeper or square to centre back; then step up or overlap'),
    (2, 'Goalkeeper', 'Serve the wide defender and remain an outlet')
) AS v(so, role, job);

-- 116. pp.143-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_attack', 'Functional activity: the back 3 playing out of the defense', 'Back three open up from keeper',
    'In a 3-5-2, when the keeper or sweeper collects a ball played in behind, the team opens out from a compact defending shape into a build-up shape.',
    'Keeper or sweeper gathers the ball',
    'Create a 5v2 in the defending third so the keeper can find a defender with time to play a quality forward pass, usually into a faced-up midfielder first.',
    NULL, 143, 146, 1160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside defenders', 'Push wide and as high as possible while keeping a safe angle for the keeper; open the body to the field'),
    (2, 'Sweeper/central defender and defensive midfielder', 'Stay central, staggered one high one low, sideways-on'),
    (3, 'Other midfielders', 'Push up just below the halfway line'),
    (4, 'Forwards', 'Stretch the field by stepping into the other half'),
    (5, 'Goalkeeper', 'Serve a wide defender; if forwards are spread wide, go to the sweeper or holding midfielder'),
    (6, 'Defender on the ball', 'First touch forward to lose the chaser; if no forward pass, switch via other defenders or keeper')
) AS v(so, role, job);

-- 117. pp.146-148
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Functional activity: switching play using the back four', 'Back four bowl shape',
    'When the back line receives the ball in the middle third, it drops off and spreads into a bowl (full backs wide and high, centre backs deeper) so the ball can travel across the line and be played long to the other side.',
    'Back line receives the ball',
    'Make switching the play across the back line safe and quick.',
    NULL, 146, 148, 1170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back receiving', 'Back-pedal as the ball arrives'),
    (2, 'Full backs', 'Spread wide into the bowl'),
    (3, 'Back four', 'Move the ball across the line, then play long to switch; continues past s148')
) AS v(so, role, job);

-- 118. pp.146-148
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Functional activity: switching play using the back four', 'Back four slides with ball',
    'The back four without the ball follows each pass by sliding across as a unit, staying compact and goal-side; after passing long, a line pushes up flat and shifts toward the ball.',
    'Ball switched across the field',
    'Keep the back line compact and covering on the ball side.',
    NULL, 146, 148, 1180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side defender', 'Press out to the ball'),
    (2, 'Other three defenders', 'Stay flat but just behind the ball-side defender in cover, shuffle across together; continues past s148')
) AS v(so, role, job);

-- 119. pp.149-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Functional Activity: Switching Play Using The Back Four', 'Switching through the back line with midfield link',
    'Back line circulates the ball side to side with crisp passes into the front foot; a midfielder slides with the ball to link centre backs or swaps with a centre back who dribbles up, and a checking forward lays balls back to the midfielder.',
    'Ball in the back line, forward checking or midfielder free',
    'Keep a quick two-touch switching rhythm and move the ball from one side to the other through or past the centre backs.',
    NULL, 149, 150, 1190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Keep angles and spacing, pass in front of feet, occasionally skip a centre back on the switch'),
    (2, 'Central midfielder', 'Slide with ball, receive from a defender and keep it moving the same direction'),
    (3, 'Midfielder interchanging', 'Take a centre back''s place when he dribbles into midfield'),
    (4, 'Checking forward', 'Show for the ball and lay it back to the supporting midfielder'),
    (5, 'Defenders without ball', 'Mark the checking forward, hand him on when zonal')
) AS v(so, role, job);

-- 120. pp.150-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Functional Training: Zonal Defending With 4-4-2 / Activity #1: Teaching Central Defenders to Mark the Target Player', 'Centre-back pair sandwiches the target man',
    'Two centre backs share a target forward: one marks tight off his shoulder within touching distance, the other drops behind as cover and steps back in line when the ball goes back. With two forwards they switch between marking and covering on the fly.',
    'Pass played into the target forward; pass back to a deeper attacker',
    'Win or deny the ball to the target man while never leaving the space behind uncovered.',
    NULL, 150, 154, 1200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marking centre back', 'Stand off the forward''s shoulder, follow him tight when he checks, attack balls to feet'),
    (2, 'Free centre back', 'Drop behind the marker the moment the ball goes in, take balls into space behind, step back up on the return pass'),
    (3, 'Centre-back pair', 'Push up as a unit while a back pass travels, stop when it arrives, stay within about 40 yards of the ball'),
    (4, 'Leader centre back', 'Call when to push up and how far'),
    (5, 'Goalkeeper', 'Act as sweeper-keeper behind a flat line')
) AS v(so, role, job);

-- 121. pp.155-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Activity #2: Teaching the Back Four to Work as a Unit', 'Back four adjusts to ball location',
    'A compact back four keeps small gaps; centre backs mark the inside shoulder of the forwards. On a pass into a forward the next centre back drops 3-4 yards (deeper for a high ball) to cover and the far full back tucks in; on a ball wide the full back sprints to the wide midfielder while the ball is in flight.',
    'Ball circulates centrally, into a forward or out wide',
    'Every pass sees a tight marker plus a cover player responsible for the space behind him (''sandwich'').',
    NULL, 155, 158, 1210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back on ball-side forward', 'Mark tight, cut out balls to feet, stand off the outside shoulder when ball is wide'),
    (2, 'Other centre back', 'Drop behind for balls in behind, mark the second forward more loosely'),
    (3, 'Ball-side full back', 'Close down the wide midfielder while the pass travels'),
    (4, 'Far full back', 'Slide inside and stay level with the covering centre back')
) AS v(so, role, job);

-- 122. pp.158-160
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Activity #2: Teaching the Back Four to Work as a Unit', 'Back four vs twin striker movement',
    'Strikers switch sides laterally, run across together, or one checks into midfield while the other runs into the space. Defenders pass forwards on to each other, but stick to a checking forward so he cannot turn; a striker drifting wide is released to the centre back when the full back must close the ball.',
    'Forwards'' off-ball runs; striker drifts wide; danger of a weak-side 1v1',
    'Keep alignment and avoid 1v1s near goal while no striker turns or runs free.',
    NULL, 158, 160, 1220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Communicate hand-overs on lateral runs, follow a forward who drops into midfield'),
    (2, 'Full back marking a drifted forward', 'Leave him to close down the ball when it goes wide'),
    (3, 'Inside centre back', 'Pick up the released forward immediately'),
    (4, 'Centre back facing weak-side 1v1', 'Call teammate back to the mark and slide across to cover'),
    (5, 'Free defender', 'Step out to close a midfielder who dribbles through')
) AS v(so, role, job);

-- 123. pp.161-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Activity #2 Progression: adding midfielders', 'Midfield three double-teams and always pressures',
    'Holding midfielder tracks the attacking midfielder''s runs; the three midfielders stay compact centrally so the wide two, free of fixed marks, can double up or sandwich receivers and cover overlaps. Whoever is nearest pressures the ball at once regardless of assignments, and teammates shift to release him.',
    'Pass into any opponent in the defensive half; overlapping run',
    'Create numbers around the ball and deny time on it, intercepting by reading body language.',
    NULL, 161, 163, 1230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (M1)', 'Track the attacking midfielder, hand him to a defender or let him run offside'),
    (2, 'Wide midfielders (M2, M3)', 'Start compact centrally, double team with the full back, slide to pick up overlapping full backs'),
    (3, 'Nearest player', 'Pressure the ball immediately even if it is not his man'),
    (4, 'Adjacent midfielder', 'Shift over to pick up the pressing player''s man'),
    (5, 'All midfielders', 'Block passing lanes to forwards, bait a pass and jump the receiver')
) AS v(so, role, job);

-- 124. pp.163-165
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Activity #2 Progression: adding midfielders', 'Drop off unpressured, hold line under pressure',
    'With no pressure on the ball, centre backs drop off their forwards to face play and win the race to through balls; when a midfielder presses the passer they hold a flat line and mark tight. Full backs stay level with the centre backs rather than in a diagonal, with only the covering centre back dropping.',
    'Passer has time (no pressure) vs passer under pressure',
    'Avoid being turned by a through pass and keep an offside line that can step up together.',
    NULL, 163, 165, 1240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Drop off when the ball is free, step up and mark tight when it is pressed'),
    (2, 'Full backs', 'Stay in line with forwards and centre backs, never deepest'),
    (3, 'Covering centre back', 'Only player allowed to drop behind the line'),
    (4, 'Pressing midfielder', 'Pressure the passer so the line can hold high')
) AS v(so, role, job);

-- 125. pp.165-167
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'Activity #3: Teaching The Forwards To Apply First Pressure', 'Forwards squeeze build-up to one flank',
    'Against a 4-4-2 building from the keeper, the two strikers start central to invite the ball wide; as the full back receives, the near striker curves his run to block the inside pass while the other striker shuts the pass across to the centre back.',
    'Keeper plays to a wide defender',
    'Force the ball down the touchline into waiting midfielders, making play predictable to win it.',
    '4-4-2', 165, 167, 1250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near striker (F1)', 'Curved approach to cut the switch, stay on feet, challenge 10-20 yards above halfway'),
    (2, 'Far striker (F2)', 'Move toward the centre back to block the switch, cover a defender stepping into vacated midfield'),
    (3, 'Ball-side midfielders and full back (D1, D2)', 'Wait down the line to pounce on the forced pass'),
    (4, 'Both strikers', 'Slide back to central start when the ball goes back to the keeper')
) AS v(so, role, job);

-- 126. pp.167-169
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Functional Activity: Attacking From Middle Third in 3-5-2', '3-5-2 midfield runs into attacking third',
    'In a 3-5-2 the wide midfielders hug the touchlines; play goes to one wingman to draw the opponents over, back to a holding midfielder or defender, then long diagonally to the far wingman who runs in. Holding midfielders constantly offer for back passes, e.g. from a checking forward''s lay-off.',
    'Opponents drawn to one side; forward checks and lays off',
    'Get a midfielder running onto the ball in the attacking third with width and depth kept.',
    NULL, 167, 169, 1260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielders', 'Stay on the touchline to stretch play, attack the far side on the switch'),
    (2, 'Defensive midfielders', 'Adjust to receive back passes and deliver the final ball'),
    (3, 'Forwards', 'Check to feet and lay off; they do not make the forward run here'),
    (4, 'Defenders', 'Recycle the ball and hit long diagonals to the far wingman'),
    (5, 'Attacking midfielder', 'Run beyond into the attacking third')
) AS v(so, role, job);

-- 127. pp.171-172
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Patterns of Play', 'In-back-out sequence',
    'A pass into a player''s feet, a first-time layoff back to a supporter facing play, then a pass out to a third player in a new area.',
    'Marked team-mate available to feet',
    'Everyone passes the way he faces, no one turns under pressure, and fast circulation beats the press.',
    NULL, 171, 172, 1270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target receiver', 'Show for the ball in and lay it back first time'),
    (2, 'Supporting player', 'Face up behind the ball and play it out wide or forward'),
    (3, 'Wide or forward player', 'Receive the out pass in space')
) AS v(so, role, job);

-- 128. pp.172-173
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Patterns of Play', 'Third-man passing, never back to the passer',
    'Players avoid returning the ball to whoever gave it, passing on to a new player each time; open body shape lets receivers see passer and next target, and diagonal passes let a half-turned receiver check his marker and turn.',
    'Receiving in midfield with options',
    'Better circulation that opponents cannot chase down in numbers.',
    NULL, 172, 173, 1280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'Half-turned body, scan both passer and next option'),
    (2, 'Third player', 'Move to receive from the receiver, not the original passer'),
    (3, 'Passer', 'Prefer diagonal over straight vertical passes')
) AS v(so, role, job);

-- 129. pp.173-174
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Patterns in the Defending Third', 'Riskfree switch across the back',
    'When a defender cannot play forward, the bowl-shaped back four (or a 3-5-2 back three chained with the wide midfielders) moves the ball to the other side in one or two touches, skipping players when range allows; the keeper can join the chain.',
    'Full back in possession with no forward pass',
    'Gain time and space on the far side to play forward.',
    NULL, 173, 174, 1290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back on ball', 'Switch via centre backs or hit sideline to sideline'),
    (2, 'Centre backs', 'One- or two-touch through the chain, skip a man if possible'),
    (3, 'Wide midfielders (3-5-2)', 'Act as the outer links of the switching chain'),
    (4, 'Goalkeeper', 'Offer as an extra link in the switch')
) AS v(so, role, job);

-- 130. pp.174-175
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Patterns in the Defending Third', 'Midfielder as rebound wall vs high press',
    'When a pressing forward blocks the pass across the back line with his angle of approach, a tightly marked midfielder receives from one centre back and redirects first time to the other.',
    'Opponent forward closes a centre back and cuts the square pass',
    'Complete the switch against high pressure without anyone turning into trouble.',
    NULL, 174, 175, 1300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back under pressure', 'Play into the midfielder''s feet'),
    (2, 'Central midfielder', 'One-touch set to the far centre back'),
    (3, 'Far centre back', 'Receive and carry the switch on to the full back')
) AS v(so, role, job);

-- 131. pp.175-177
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Patterns in the Defending Third', 'Playing out past pressing forwards',
    'Rehearsed exits from the defensive third: defender to a checking forward who lays back to a midfielder; defender to the attacking midfielder who sets the holding midfielder; defender to a midfielder who squares to an overlapping full back; midfielders clear space so a centre back steps into midfield.',
    'Opponent forwards press the back line',
    'Get the ball to a faced-up player in the middle third behind the press; the marked receiver never turns into pressure.',
    NULL, 175, 177, 1310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender on ball', 'Drive a pass into a marked forward or midfielder, or step into vacated midfield'),
    (2, 'Checking forward / attacking midfielder', 'Lay back first time to a supporter'),
    (3, 'Holding midfielder', 'Receive the set facing forward and play on'),
    (4, 'Overlapping full back', 'Take the square ball from the midfielder'),
    (5, 'Midfielders', 'Pull away to open space for the centre back')
) AS v(so, role, job);

-- 132. pp.177-178
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Patterns in the Defending Third', 'Balls down the channels',
    'From the defensive third a defender plays long into the gap between opposing full back and centre back; one striker checks and drags his marker, the other runs into the channel to receive, and the wide midfielder sprints up to support.',
    'Defender with time and range, strikers in a complementary run',
    'Bypass midfield straight into the attacking third (typical of 4-4-2 twin strikers).',
    NULL, 177, 178, 1320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender', 'Hit a quality driven or floated pass into the channel'),
    (2, 'Checking striker', 'Come short to pull his centre back away'),
    (3, 'Running striker', 'Attack the channel and hold off the marker'),
    (4, 'Wide midfielder', 'Sprint forward as soon as the ball is struck')
) AS v(so, role, job);

-- 133. pp.178-179
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Patterns in the Middle Third', 'Work into the hole, relieve via flanks',
    'Against a back line holding in front of its box, the team aims to get the ball into the hole in front of the defence for a killer pass, around the defence via the flanks for crosses, or through combinations into the box; under pressure it resets into its own third or the wide middle-third zones, which have more time and space for relaunching.',
    'Possession in middle third',
    'Penetrate behind the defence, while the defenders swarm the hole and counter at once on winning it.',
    NULL, 178, 179, 1330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player in the hole', 'Receive between the lines and thread a quick through ball, combine or shoot'),
    (2, 'Wide players', 'Hold the ball in the wide middle-third zones to regroup'),
    (3, 'Defending side', 'Press the hole with numbers, deny turns, counter on regain')
) AS v(so, role, job);

-- 134. pp.179-180
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Patterns in the Middle Third', 'Spring the wide midfielder from wide zones',
    'In a 4-4-2 or 3-5-2, starting in a wide middle-third zone: an in-back-out springs the wide midfielder down the line, or the ball is switched through the checking forward and central midfielder to the far wide midfielder, who plays a wall pass with the second forward to get behind.',
    'Ball with the wide midfielder or central player in a wide zone',
    'Penetrate down a flank into the attacking third.',
    NULL, 179, 180, 1340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder', 'Release inside, then run in behind for the return'),
    (2, 'Checking forward', 'Show to feet and set the central midfielder'),
    (3, 'Central midfielder', 'Switch to the far wide midfielder'),
    (4, 'Second forward', 'Give the wall pass')
) AS v(so, role, job);

-- 135. pp.179-180
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Patterns in the Middle Third', 'Wide midfielder cuts in for overlap',
    'After the switch in a 4-4-2, the wide midfielder dribbles diagonally inside at the defender to open the touchline, then releases the overlapping full back.',
    'Wide midfielder receives the switch with full back behind him',
    'Create a free run down the flank for the overlapping full back.',
    NULL, 179, 180, 1350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder', 'Dribble inside toward the defender to drag him in, release the overlap'),
    (2, 'Full back', 'Overlap outside and receive in stride')
) AS v(so, role, job);

-- 136. pp.181-182
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Patterns in the Middle Third', 'Twin strikers spring one through',
    'In a 4-4-2 or 3-5-2: the second forward runs flat to stay onside then cuts behind for a through ball after the first forward''s lay-off; or the near forward checks, the ball goes to the far forward, and the first spins in behind for a pass from the forward or attacking midfielder.',
    'Midfielder on ball facing forward, forwards paired',
    'Get a striker through on goal behind the back line.',
    NULL, 181, 182, 1360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Checking forward', 'Come to the ball, lay off or draw a marker'),
    (2, 'Running forward', 'Flat run to beat offside, time the cut behind'),
    (3, 'Attacking midfielder', 'Play the through ball')
) AS v(so, role, job);

-- 137. pp.181-182
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Patterns in the Middle Third', 'Dummy in the shared passing lane',
    'Both forwards line up in the same diagonal lane; the first feints to take the pass but lets it run past and sprints for the return through ball from the second (cited as a Cole-Yorke and Klinsmann-Voller habit).',
    'Diagonal pass from midfield toward the forwards',
    'Fool markers and release the first forward in behind.',
    NULL, 181, 182, 1370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First forward', 'Shape to receive, let the ball run, sprint beyond'),
    (2, 'Second forward', 'Receive and play the first-time through ball'),
    (3, 'Midfielder', 'Play the diagonal into the lane')
) AS v(so, role, job);

-- 138. pp.182-183
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Patterns in the Middle Third', 'Midfielder as third man running',
    'In a 4-4-2 or 3-5-2 an attacking midfielder runs into space a forward has vacated; or one forward checks to combine with a midfielder while the other runs laterally to open space, and a central midfielder arrives as the third man.',
    'Forward checks or moves laterally, opening space',
    'Get a late-arriving midfielder into a scoring area to finish with a cross or shot.',
    NULL, 182, 183, 1380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Checking forward', 'Combine with the supporting midfielder'),
    (2, 'Second forward', 'Lateral run to drag defenders away'),
    (3, 'Attacking / central midfielder', 'Run late into the vacated scoring space')
) AS v(so, role, job);

-- 139. pp.183-184
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Patterns in the Middle Third (three-forward system)', 'Winger lay-inside and sprint (4-3-3/3-4-3)',
    'With a centre forward and two wingers, a defender feeds the winger, who sets inside to a midfielder in the hole and sprints down the flank for the through ball; the midfielder can instead hit the gap for the centre forward or switch to the far winger. Variations: overlaps around a winger for 2v1, and the centre forward checking while the attacking midfielder runs beyond.',
    'Ball reaches the winger from a defender',
    'Exploit winger pace with passes into the corner or 1v1s, with several final-ball options.',
    NULL, 183, 184, 1390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Lay inside, sprint down the line for the ball into space'),
    (2, 'Attacking midfielder (M2)', 'Receive in the hole, choose winger, centre forward gap or far-side switch'),
    (3, 'Centre forward', 'Run the gap, or check into midfield to swap with M1'),
    (4, 'Far winger', 'Attack space on the far side'),
    (5, 'Overlapping midfielder or full back', 'Run outside the winger for a 2v1')
) AS v(so, role, job);

-- 140. pp.186-187
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Shadow Plays: Shadow Play in Attacking Third', 'Midfield four slide and tuck in',
    'A flat midfield four circulates the ball side to side just outside the attacking third while a lone forward shifts with the ball.',
    'Ball switched to one wing',
    'Move the ball across the full width while the unit stays compact in case possession is lost.',
    NULL, 186, 187, 1400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Far-side wide midfielder', 'Slide inside when ball is on opposite flank'),
    (2, 'Ball-side wide midfielder', 'Take a few dribbling touches down the wing, then play back inside'),
    (3, 'Central midfielders', 'Two-touch rhythm, support behind the ball at an angle, pass to the receiver''s far foot'),
    (4, 'Lone forward', 'Slide laterally with the ball as a high outlet')
) AS v(so, role, job);

-- 141. pp.187-188
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Shadow Plays: Shadow Play in Attacking Third', 'Forward check-away, check-back lay-off',
    'While the midfield moves the ball, the striker joins the passing chain as a wall.',
    'Ball travelling between two central midfielders',
    'Forward gets free to receive and lays it first time to a third midfielder facing play.',
    NULL, 187, 188, 1410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Move away from the ball, then come back towards it and lay off first time'),
    (2, 'Central midfielder', 'Play the forward in when he checks back'),
    (3, 'Wide midfielder', 'Receive the lay-off facing forward')
) AS v(so, role, job);

-- 142. pp.188-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Shadow Plays: Shadow Play in Attacking Third', 'Flank combos: wall pass, third man, overlap',
    'Five attackers (four midfielders plus a forward) break down a back three to get a wide player to the byline.',
    'Ball reaches a wide midfielder or the forward checks to a midfielder',
    'Get a wide player behind the defence to cross.',
    NULL, 188, 190, 1420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder', 'Give and go with the forward, or run beyond for a third-man ball'),
    (2, 'Centre forward', 'Lay off first time to set up the third man'),
    (3, 'Central midfielder', 'Overlap around the wide man, calling ''hold it'''),
    (4, 'All attackers', 'Use sprints and calls as cues so everyone reads the same combination')
) AS v(so, role, job);

-- 143. pp.189-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Shadow Plays: Shadow Play in Attacking Third', 'Box occupation for a wide cross',
    'Every flank combination finishes with a cross, and runners fill set zones.',
    'Wide player about to cross',
    'Cover near post, far post and the middle of the box, with someone left at the edge for clearances.',
    NULL, 189, 190, 1430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Near-post run'),
    (2, 'Opposite wide midfielder', 'Far-post run'),
    (3, 'One central midfielder', 'Attack the centre of the box'),
    (4, 'Other central midfielder', 'Stay outside the box for clearances')
) AS v(so, role, job);

-- 144. pp.189-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Shadow Plays: Shadow Play in Attacking Third', 'Through ball for the second forward',
    'With two forwards, one drags his marker away while a wide midfielder slides the ball through to the other.',
    'Wide midfielder in possession, first forward pulling his defender wide',
    'Get in behind centrally, as another option alongside the cross.',
    NULL, 189, 190, 1440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First forward', 'Pull the centre back across, out of the lane'),
    (2, 'Second forward', 'Curve a run into the gap he leaves'),
    (3, 'Central midfielder', 'Pick out the through ball')
) AS v(so, role, job);

-- 145. pp.190-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Shadow Plays: coaching points', 'Possession-penetration cycle',
    'Attackers knock the ball around patiently, then switch suddenly to a penetrating move.',
    'A sprint or a call from a team-mate',
    'Surprise the defence after lulling it, with runs timed to stay onside.',
    NULL, 190, 190, 1450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Runner', 'Speed burst and shout to ask for the ball'),
    (2, 'Passer', 'Match the pass pace to the run, keep spacing'),
    (3, 'All', 'Pick when and how to penetrate together')
) AS v(so, role, job);

-- 146. pp.190-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Shadow Plays: Full Field Shadow Play', 'Keeper throw to finish, end to end',
    'Full-field pattern for a 4-4-2 starting from a keeper throw: full back, long to a midfielder, forward lay-off, ball wide, cross.',
    'Keeper gathers and throws out to the full back',
    'Build through the thirds and finish with a shot, with every unit connected.',
    NULL, 190, 192, 1460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Throw to a wide defender'),
    (2, 'Full back', 'Long forward pass to a midfielder'),
    (3, 'Midfielder', 'Combine with the forward, then release the wide player'),
    (4, 'Forwards', 'Near and far runs to attack the cross')
) AS v(so, role, job);

-- 147. pp.192-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Shadow Plays: Full Field Shadow Play', 'Centre back feeds each flank group',
    'The central defender starts the move and alternates flanks; each side attacks as a group of four.',
    'Centre back in possession',
    'Repeat flank penetration patterns on both wings.',
    NULL, 192, 192, 1470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Play into the left or right flank group'),
    (2, 'Flank group (full back, wide mid, central mid, forward)', 'Combine down the wing and cross')
) AS v(so, role, job);

-- 148. pp.192-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Shadow Plays: Full Field Shadow Play', '3-5-2 diagonal switch, early cross',
    'Rehearsed in our 3-5-2 against an opponent known to leave the flanks open (opponent shape not given).',
    'Left defender gets the ball back from the left midfielder in the middle third',
    'Unbalance the opponent and cross early into the space behind their back line.',
    NULL, 192, 192, 1480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left defender', 'Exchange with the left midfielder, then hit a long diagonal'),
    (2, 'Left midfielder', 'Give and go to free the defender'),
    (3, 'Opposite wide midfielder', 'Stay wide, receive the switch, cross early behind the defence'),
    (4, 'Forwards', 'Attack the space behind the line')
) AS v(so, role, job);

-- 149. pp.194-195
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Developing Forwards', 'Lay off, spin in behind',
    'A tightly marked striker checks in, lays the ball back to a supporting midfielder, then keeps moving.',
    'The moment his lay-off is played',
    'Get a return through ball behind the marker, or at least pin the defender back.',
    NULL, 194, 195, 1490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Spin and sprint past the marker straight after the lay-off'),
    (2, 'Supporting midfielder', 'Play the ball in behind first time')
) AS v(so, role, job);

-- 150. pp.195-195
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Developing Forwards', 'Constant in-out movement vs markers',
    'A mobile forward keeps checking into midfield and spinning back out so his marker cannot see both him and the ball.',
    'Team in build-up, forward tightly marked',
    'Tire the marker and make him drop off, so the forward gets space to receive and turn.',
    NULL, 195, 195, 1500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Never stand still in front of the defender; keep moving to get goal-side'),
    (2, 'Midfielders', 'Find him when the marker sags off')
) AS v(so, role, job);

-- 151. pp.196-197
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Developing Forwards', 'Blind-shoulder poacher (Batistuta)',
    'A less mobile forward stays high, level with the last defender and on his far-side shoulder, as Batistuta did.',
    'Ball moves side to side',
    'Defender cannot watch man and ball, so the forward can run to goal, run diagonally, or come short.',
    NULL, 196, 197, 1510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Change shoulders so he is always opposite the ball'),
    (2, 'Midfielder', 'Play forward early as he goes')
) AS v(so, role, job);

-- 152. pp.196-197
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Developing Forwards', 'Target man holds it up',
    'A big, strong forward receives with a defender tight behind him and does not try to escape.',
    'Ball played into the forward''s feet under close marking',
    'Shield the ball and bring support into play (the author warns this gets predictable).',
    NULL, 196, 197, 1520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target forward', 'Step back into the marker, control and shield'),
    (2, 'Midfielders', 'Arrive in support for the next pass')
) AS v(so, role, job);

-- 153. pp.197-198
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Developing Forwards', 'Diagonal angle off the defender (Romario)',
    'A quick striker (Romario, Brazil 1994) stays central and moves so he is always diagonal to the ball while the midfield circulates.',
    'Ball moving across midfield',
    'Receive side-on and facing goal, then dribble or combine; a tight marker gets lay-and-run in behind.',
    NULL, 197, 198, 1530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'Move against the ball''s direction to offer an angled pass, come off side-on'),
    (2, 'Second forward', 'Attack the through ball into the space the striker opens'),
    (3, 'Midfielder', 'Feed angled passes, then a through ball after the lay-back')
) AS v(so, role, job);

-- 154. pp.199-199
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_attack', 'Developing Forwards', 'Forward drifts free while defending',
    'While the opponent spreads out to build, our forward slips away to where space will be when we win the ball.',
    'Opponent in possession and building up',
    'Be unmarked to receive at once on the regain.',
    NULL, 199, 199, 1540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Drift into the hole between their defence and midfield, or behind full backs who have pushed on'),
    (2, 'Ball winner', 'Find the free forward early')
) AS v(so, role, job);

-- 155. pp.199-200
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Developing Forwards', 'Near, far and central cross runs',
    'Three runs to score from crosses, each starting with a bent run away from the ball.',
    'Wide man about to deliver',
    'Arrive with momentum in the landing zones and beat static defenders to the ball.',
    NULL, 199, 200, 1550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near-post runner', 'Aggressive run timed to reach the six-yard box with the ball; score or flick on'),
    (2, 'Far-post runner', 'Delayed run, hold at the box edge to read the flight, attack balls over the top'),
    (3, 'Central runner', 'Wait near the penalty spot, then attack balls skimming across the six-yard line')
) AS v(so, role, job);

-- 156. pp.200-204
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Developing Forwards: Activity #1 Combination Plays on the Edge of the Penalty Area', '2v2 edge-of-box penetration',
    'Two attackers against two defenders at the top of the box, offside in force; progresses to 2v3 against a sweeper and 3v3 with an attacking midfielder.',
    'Forward receives facing two defenders',
    'Get behind quickly with a wall pass, crossover, overlap, through ball or dribble; shoot on sight and follow up rebounds.',
    NULL, 200, 204, 1560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward on ball', 'First touch towards goal to commit his defender, or use the partner''s run as a decoy'),
    (2, 'Partner forward', 'Feint one way and go the other to gain yards; overlap or cross over'),
    (3, 'Attacking midfielder (3v3)', 'Combine with the front two, shoot early'),
    (4, 'Both', 'Read the defenders'' spacing, keep a good support angle and distance, no square or back passes')
) AS v(so, role, job);

-- 157. pp.204-206
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Developing Forwards: Activity #2 Forwards Receiving and Turning', 'Check away, then into space to turn',
    'Front runners make space to receive from midfield, turn and shoot.',
    'Midfielder controls and looks up for eye contact',
    'Receive within shooting range: turn and shoot outside the box, finish first time low to the far post inside it.',
    NULL, 204, 206, 1570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Move away while the pass is controlled, then a sharp change of pace into space; glance at the keeper'),
    (2, 'Midfielder', 'Read the change of pace as the cue and pass into the right space'),
    (3, 'Forward vs live marker', 'Blind shoulder; vary between running in behind and checking short; lay back and spin')
) AS v(so, role, job);

-- 158. pp.206-206
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'to_attack', 'Developing a Possession Rhythm', 'Go back only to go forward',
    'Modern teams attack as soon as they win the ball; possession is kept to prepare a forward pass, not to avoid losing it.',
    'Ball won',
    'Exploit the opponent before it reorganises; a back pass sets up a forward one.',
    NULL, 206, 206, 1580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Look forward first'),
    (2, 'Supporting players', 'Offer a back option only as a set-up for a forward pass')
) AS v(so, role, job);

-- 159. pp.207-209
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Developing a Possession Rhythm', 'Six possession-rhythm habits',
    'A team keeps the ball under pressure by repeating a set of habits, whatever its formation.',
    'Team in settled possession',
    'Keep the ball moving into less crowded areas so the opponent is stretched and penetration opens up.',
    NULL, 207, 209, 1590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All', 'Stretch the field for width and depth'),
    (2, 'Off-ball players', 'Support on both sides, behind and ahead, near and far'),
    (3, 'Receiver', 'Play the way he faces, one or two touches'),
    (4, 'Team', 'Short-short-long: draw opponents in, then switch long'),
    (5, 'All', 'Early short calls: ''time'', ''man on'', ''hold it''')
) AS v(so, role, job);

-- 160. pp.210-210
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'Developing a Possession Rhythm', 'Outside relief players, inside rebound walls',
    'In 11v11 the back line and wide midfielders act as the outside players; central midfielders and forwards act as the inside players.',
    'Opponents close in with numbers in the centre',
    'Get out of pressure, then switch with speed until gaps appear.',
    NULL, 210, 210, 1600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line and wide midfielders', 'Relieve pressure, switch play, tell inside players when to turn'),
    (2, 'Central midfielders and forwards', 'Check to the ball and redirect it one touch, never stay long in the crowded middle')
) AS v(so, role, job);

-- 161. pp.210-211
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'set_piece', 'Throw Ins: defensive and middle thirds', 'Throw-in: drop deep, push up, stretch',
    'Throw in our half or the middle third when a quick throw is not on because opponents have marked up.',
    'Ball out for our throw, receivers marked',
    'Restart safely, get the ball out of the crowded area, and switch to the open side.',
    NULL, 210, 211, 1610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Thrower (wide defender in a back four, wide midfielder in a back three)', 'Throw; keep the rest of the defence behind the ball'),
    (2, 'Other defenders', 'Drop well back to pull forwards away or be a safe throw-back'),
    (3, 'Forwards', 'Push right up (no offside from a throw) to stretch the field'),
    (4, 'Central midfielders', 'Start 20-30 yards away, then one darts to the ball'),
    (5, 'Nearest defender', 'Stand inside the field ready to switch long'),
    (6, 'Far wide midfielder', 'Hold width')
) AS v(so, role, job);

-- 162. pp.211-212
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'set_piece', 'Throw Ins: defensive third', 'Defensive-third throw-in options',
    'Confined throw near our goal with everyone marked.',
    'Throw-in deep in our third',
    'Keep the ball, or clear it if nothing is on.',
    NULL, 211, 212, 1620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'One defender', 'Stand behind the thrower, even on the goal line'),
    (2, 'Midfielders', 'Clear space; one checks short so another can run into the space he leaves'),
    (3, 'Midfielder pair', 'Dummy run towards the thrower, then change direction to take a lay-back; or the nearer one spins for a back pass'),
    (4, 'Thrower', 'Last resort: throw to the deep defender to clear long')
) AS v(so, role, job);

-- 163. pp.212-213
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'set_piece', 'Throw Ins: attacking third', 'Long throw as a corner',
    'In the attacking third a long thrower aims for a crowd near the six-yard box.',
    'Throw-in near the opponent''s box',
    'A flicked or half-cleared throw drops within shooting range to be pounced on.',
    NULL, 212, 213, 1630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two attackers', 'Stand side by side near the six-yard box to draw a crowd'),
    (2, 'One attacker', 'In the six-yard box for flicks towards goal'),
    (3, 'Three attackers', 'Around the heading duel for knock-downs'),
    (4, 'Rest of team', 'Set against the counter')
) AS v(so, role, job);

-- 164. pp.213-214
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'The Offside Trap', 'Press and trap together (Dutch 1974)',
    'The Netherlands 1974 combined high pressing with a coordinated step-up by the whole back line.',
    'Opponent back pass or long square pass',
    'The receiver, pressed at once, plays forward into team-mates left offside.',
    NULL, 213, 214, 1640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players', 'Rush the receiver while the ball travels'),
    (2, 'Back line', 'Step up as one, angled towards the ball carrier so he cannot dribble past the trap')
) AS v(so, role, job);

-- 165. pp.214-215
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'out_of_possession', 'The Offside Trap', 'When to use the trap',
    'The trap is a situational tool, risky against runners from midfield and withdrawn strikers.',
    'Opponent plays direct long balls, commits three forwards, or we press high',
    'Win the ball or nullify faster attackers without chasing.',
    NULL, 214, 215, 1650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Step up only in these moments, not as the main defensive weapon'),
    (2, 'Defenders vs faster forwards', 'Choose between dropping for a head start or stepping up')
) AS v(so, role, job);

-- 166. pp.214-215
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-complete-guide-coaching-soccer-systems-tactics'), 'in_possession', 'The Offside Trap', 'Beat the trap with late midfield runs',
    'After a deep flank penetration, or at wide corners and free kicks, the wide player plays it back instead of crossing and defenders sprint out.',
    'Ball played back from the byline area while the opponent''s line clears out',
    'Midfielders arriving from behind get a free shot or run in on goal.',
    NULL, 214, 215, 1660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide attacker', 'Cut the ball back instead of an immediate cross'),
    (2, 'Forward', 'Stay where he is; may be left offside as a decoy'),
    (3, 'Midfielders', 'Time runs into the box as the defence runs out')
) AS v(so, role, job);

COMMIT;
