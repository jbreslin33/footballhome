-- 1980 📚 Coaching book patterns: "Coach Your Team to Score More Goals" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Coach Your Team to Score More Goals',
    subtitle    = 'Data-Driven Analysis of Europe''s Elite Used to Create 16 Training Sessions',
    author      = 'Paco Cordobés',
    team        = '2022-23 Champions League group stage (304 goals)',
    season      = '2022-23',
    method_note = 'All 304 goals from the 96 matches of the 2022-23 Champions League group stage, classified by type of goal and assist, the zones the assist came from and the goal was scored from, and the tactical phase (build-up, counter, final-third combination, set piece). Each category gets real goal examples and a progressive four-practice session. Patterns are the goal-scoring behaviours (corner routines, cut-backs, through passes behind the line, side-of-box third-man runs, wide combinations, counters by zone, high press), in our words.'
WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-');

-- 1. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'set_piece', 'Tactical Examples 1: Corner Kicks (Barcelona v Plzen)', 'Crowd the six-yard line, late runner to spot',
    'Attackers line up along the six-yard box to pin the zonal defenders there, leaving the penalty spot area thinner. A centre back peels back and away from his marker while a midfielder arrives late from outside the box.',
    'Direct inswinging/outswinging corner to the penalty spot',
    'A runner arriving at speed beats static defenders to the first header.',
    NULL, 21, 21, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three attackers on six-yard line', 'Occupy and hold the zonal defenders'' attention'),
    (2, 'Centre back (Kounde)', 'Step back and away from marker to attack the cross'),
    (3, 'Central midfielder (Kessie)', 'Start outside the box and arrive late with timing at the spot'),
    (4, 'Corner taker (Dembele)', 'Deliver to the penalty spot area')
) AS v(so, role, job);

-- 2. pp.22-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'set_piece', 'Tactical Examples 1: Corner Kicks (Ajax v Napoli); Session 1 practices 3-4', 'Short corner to change the angle',
    'A short corner draws two defenders out of the box and the receiver crosses from a deeper spot before they can close; one-two with the taker, a pass back to the full back, or a link player feeding the full back are the variants. With defenders also left out for the counter, the box becomes a 2v3 or 3v3 at the back post.',
    'Corner taker signals a short routine',
    'Pull defenders out of the box and cross from a better angle into a numbers-even back post zone.',
    NULL, 22, 27, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Corner taker', 'Play short / one-two, then join'),
    (2, 'Winger or full back receiver (Kvaratskhelia)', 'Step forward from deep, lift head and cross early before defenders close'),
    (3, 'Link player', 'Offer the bounce pass to set up the full back''s cross'),
    (4, 'Far-post runner (Di Lorenzo)', 'Circle round the back of the last defender and attack the far post'),
    (5, 'Outside players', 'Hold for second balls and guard against the counter')
) AS v(so, role, job);

-- 3. pp.23-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'set_piece', 'Training Session 1: Corner Kicks', 'Signalled corner menu with zone runs',
    'The team agrees five corner types, each with a hand signal from the taker, split into direct and short options; each delivery goes near post, far post or penalty spot. Box runners cover every target zone and outside players sit for clearances while the rest guard against counter attacks.',
    'Taker''s signal before the corner',
    'Every target zone is attacked and second balls are recycled while staying protected against the break.',
    NULL, 23, 25, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Corner taker', 'Give the signal and hit near post, far post or spot'),
    (2, 'Box runners', 'Make set runs so all three target zones are covered'),
    (3, 'Edge-of-box players', 'Win second balls and keep the attack going'),
    (4, 'Rest defenders', 'Stay back to stop the counter if the ball is lost')
) AS v(so, role, job);

-- 4. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Tactical Examples 2: Cut Backs (Leipzig v Real Madrid)', 'Wide full back, decoy run, by-line cut back',
    'The full back holds the touchline width so the back line is stretched; a midfielder drags a defender toward the corner while another midfielder arrives from deep to receive and dribble to the by-line inside the box. The far winger times his run to meet the lifted cut back.',
    'Square pass to midfielder arriving from deep into space created by the decoy',
    'Reach the by-line inside the box and cut back to a late runner who beats his marker.',
    NULL, 31, 31, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Carvajal)', 'Hold width to open the defence, feed square pass'),
    (2, 'Decoy midfielder', 'Run toward the corner to drag a defender away'),
    (3, 'Attacking midfielder (Asensio)', 'Arrive from deep, carry to by-line, cut back'),
    (4, 'Far winger (Vinicius Jr)', 'Read the move and arrive on time to finish')
) AS v(so, role, job);

-- 5. pp.32-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Tactical Examples 2: Cut Backs (Man City v Copenhagen)', 'Forwards run in deep, cut back behind them',
    'After the winger dribbles past pressure and switches to the far-side winger, the front players keep sprinting toward goal instead of offering support, pulling the defenders back toward their own six-yard box. The wide player reaches the by-line and slides a cut back between defenders for the forward arriving into the vacated centre.',
    'Winger beats first pressure and finds the far-side winger running into the box',
    'Defenders retreating toward goal leave the penalty spot area free for a cut back.',
    NULL, 32, 32, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Grealish)', 'Beat pressure, then shape body to disguise the switch'),
    (2, 'Right winger (Mahrez)', 'Timed run, dribble to by-line, cut back between two defenders'),
    (3, 'Front runners', 'Keep running at goal to drag defenders back'),
    (4, 'Forward (Alvarez)', 'Delay then attack the free central space for the cut back')
) AS v(so, role, job);

-- 6. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 2: Cut Backs - practice 1', 'Overlapping full back cut back',
    'Three attackers combine against one defender in the wide zone, then release the full back on an overlap into the high corner area. As the pass goes, the two teammates split into the box, one near post and one far post.',
    'Wide 3v1 combination frees the full back''s overlap',
    'Full back cuts back from the corner area to a near-post or far-post runner.',
    NULL, 34, 34, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Overlap into the high corner zone and cut back'),
    (2, 'Wide midfielders', 'Combine to commit the defender and release the overlap'),
    (3, 'Near-post runner', 'Attack front post after the release pass'),
    (4, 'Far-post runner', 'Attack back post after the release pass')
) AS v(so, role, job);

-- 7. pp.35-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 2: Cut Backs - practices 2 and 4', 'Winger 1v1 then cut back to box runners',
    'A midfielder plays the winger in front of him so he can run onto the ball, the winger takes on the corner-area defender, gets past and cuts back to the forward and midfielder running near and far post. In the game version goals only count if the final pass is played from a wide corner zone.',
    'Ball into the winger''s path with space in the corner area',
    'Beat the wide defender and serve a cut back to arriving runners.',
    NULL, 35, 37, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Run onto pass, beat defender 1v1 in corner area, cut back'),
    (2, 'Central midfielder', 'Play the ball in front of the winger, then run to the near post'),
    (3, 'Forward', 'Run to the far post area'),
    (4, 'Defenders', 'Cannot follow into the corner zone in the game, only intercept passes')
) AS v(so, role, job);

-- 8. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 2: Cut Backs - practice 3 (variation)', 'Cut back to the edge of the box',
    'Full back finds the winger high on the flank, who goes 1v1 and cuts back toward the edge of the box rather than the six-yard area. The forward and midfielder check their movements so one shows through the middle and one wide of it, giving two options.',
    'Winger wins the 1v1 in the corner area',
    'Pull the ball back to a shooter arriving at the edge of the box at the right speed.',
    NULL, 36, 36, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Feed the winger high up the flank'),
    (2, 'Winger', 'Beat defender, lift head and cut back to the right teammate'),
    (3, 'Forward and midfielder', 'Time staggered movements to offer two cut back options at the box edge')
) AS v(so, role, job);

-- 9. pp.39-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'to_attack', 'Tactical Examples 3: Through Passes (Barcelona v Bayern)', 'Regain, release through ball behind high line',
    'Opponent defends with a high line; after an aggressive regain the full back finds the winger in space who immediately threads a pass between the opposing right back and centre back for the far winger''s run.',
    'Ball won in the first phase against a high defensive line',
    'Two passes, one of them a through ball, put a fast attacker clean through on goal.',
    NULL, 39, 39, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Mazraoui)', 'Win the ball and pass forward to the winger in space'),
    (2, 'Right winger (Gnabry)', 'Play the through ball between full back and centre back'),
    (3, 'Left winger (Mane)', 'Sprint in behind, carry into the box and finish')
) AS v(so, role, job);

-- 10. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Tactical Examples 3: Through Passes (Napoli v Liverpool)', 'One-two through pass at box edge',
    'A midfielder surrounded near the box has no route to goal, so he lays the ball back to a teammate and spins into the gap; the teammate threads a precise pass into the space behind the defenders.',
    'Ball carrier hemmed in by several defenders near the box',
    'A timed onside run plus a precise return pass gets the runner to the ball before the keeper.',
    NULL, 40, 40, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Anguissa)', 'Lay off under pressure, then run in behind staying onside'),
    (2, 'Attacking midfielder (Zielinski)', 'Play the through pass into the space behind the line'),
    (3, 'Winger (Kvaratskhelia)', 'Start the move by attacking the full back and recycling inside')
) AS v(so, role, job);

-- 11. pp.42-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 3: Through Passes - practices 1-2', 'Circulate in midfield, then through pass',
    'The team keeps the ball in the central zone, using a few passes to pull the pressing midfielders around until one player has time and a passing lane. The forward times his run off the last line to receive behind and go 1v1 with the keeper.',
    'A midfielder gets time on the ball and a lane opens (after about three passes)',
    'Draw the press, then release the forward in behind with a seen, accurate through pass.',
    NULL, 42, 43, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Keep possession, find the free man with time and a lane'),
    (2, 'Forward', 'Time run in behind from the last line, finish 1v1'),
    (3, 'Pressing defenders', 'Work together to block through-pass lanes')
) AS v(so, role, job);

-- 12. pp.44-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 3: Through Passes - practices 3-4', 'Build up, then through ball into attacking half',
    'Building from the keeper against a high press, the defenders either play into midfielders who then slide a pass in behind, or hit a direct long ball through into the attacking half. A runner times his move to collect behind and finish against the keeper.',
    'Opponent presses high, leaving space behind its line',
    'Beat the press through the lines or over it and exploit the space in behind.',
    NULL, 44, 45, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper and defenders', 'Start build-up, choose midfielder or direct long through ball'),
    (2, 'Midfielders', 'Receive between lines and play the pass in behind'),
    (3, 'Runner', 'Break into the attacking half, finish 1v1 with the keeper')
) AS v(so, role, job);

-- 13. pp.49-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Tactical Examples 4: Side of Box (Plzen v Barcelona)', 'Give to side of box, return for finish',
    'A winger receives inside from the full back and dribbles between three opponents, then feeds the other winger positioned in the side-of-box zone. That winger holds space, waits for the dribbler to find the gap and returns the ball for a near-post finish, while the striker''s far-post run opens the centre.',
    'Dribbler breaks between the lines toward the box',
    'A quick give-and-go through the side of the box beats the line.',
    NULL, 49, 49, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Bellerin)', 'Feed the inside winger'),
    (2, 'Left winger (Ferran Torres)', 'Dribble between opponents, pass, then run to receive back'),
    (3, 'Right winger (Raphinha)', 'Occupy side of box, wait and return the ball at the right moment'),
    (4, 'Forward (Fati)', 'Run to the far post to create central space')
) AS v(so, role, job);

-- 14. pp.50-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Tactical Examples 4: Side of Box (Sevilla v Man City)', 'Quick pass into free side of box, low cross',
    'A wide player spots the empty side-of-box zone and immediately plays an attacking midfielder running into it. He crosses fast and low across the box first time, and the striker anticipates it reaching the far post.',
    'Side-of-box zone left open',
    'Speed of vision and delivery beats defenders and keeper before they reset.',
    NULL, 50, 50, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Cancelo)', 'Feed the wide player'),
    (2, 'Wide player (Foden)', 'See the free space and pass quickly into it'),
    (3, 'Attacking midfielder (De Bruyne)', 'Run into the side of the box, cross low and fast first time'),
    (4, 'Centre forward (Haaland)', 'Read the far post delivery and arrive to finish')
) AS v(so, role, job);

-- 15. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 4: Side of Box - practice 1', 'Double one-two into side of box',
    'Two players combine with consecutive one-twos past defenders, the second return being a through pass into the side-of-box zone. The receiver cuts back for his partner who has run through into the box.',
    'Inside player carries the ball centrally, outside player runs past his marker',
    'Arrive in the side of the box and cut back to a central finisher.',
    NULL, 52, 52, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside player (A)', 'Pass in, run past defender, receive in side of box, cut back'),
    (2, 'Inside player (B)', 'Carry inside, return passes, then run into the box to finish')
) AS v(so, role, job);

-- 16. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 4: Side of Box - practice 2a', 'Full back releases winger into side of box',
    'Right back, two midfielders and the winger combine: the ball goes inside and back out to the full back, who either slides a through pass into the winger''s run in behind or plays short to the winger to dribble into the side of the box. From there the winger picks a cut back to a midfielder or forward, or a low cross across the box.',
    'Ball returns to the full back facing forward with the winger''s run on',
    'Choose feet or space correctly and finish with a cut back or low cross versus two box defenders.',
    NULL, 53, 53, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Decide: through pass into space or short to feet'),
    (2, 'Two central midfielders', 'Combine to switch the ball back out to the full back'),
    (3, 'Winger', 'Run in behind or dribble into side of box, then cut back or cross low'),
    (4, 'Forward and second midfielder', 'Attack the box for the cut back or cross')
) AS v(so, role, job);

-- 17. pp.54-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 4: Side of Box - practice 2b', 'Midfielder runs into side of box',
    'The full back plays a one-two with a midfielder and then threads a through pass for the second midfielder running beyond into the side-of-box zone. The winger comes off the flank on a long run toward the box with the forward also attacking it.',
    'Full back receives the return pass beyond the first midfielder',
    'An unmarked third-line runner reaches the side of box and cuts back or crosses low to two box attackers.',
    NULL, 54, 54, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'One-two with first midfielder, then through pass'),
    (2, 'Second midfielder', 'Run in behind into side of box, cut back or low cross'),
    (3, 'Winger', 'Leave the flank on a long run into the box'),
    (4, 'Forward', 'Attack the box')
) AS v(so, role, job);

-- 18. pp.55-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 4: Goals Assisted from Side of Box', 'Third-man run into side of box, cut back',
    'Full back plays inside to a midfielder, ball goes forward to the striker who sets it into the side-of-box channel for the winger arriving off the flank; the winger then cuts back or crosses low.',
    'Forward receives facing play with channel between full back and centre back open',
    'Get a runner into the side of the box with time to pick out a cut back or low near/far-post ball for arriving teammates.',
    NULL, 55, 56, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Start the move with a pass inside to the first midfielder'),
    (2, 'Midfielders M1/M2', 'Move the ball forward quickly and then attack the box for the cut back'),
    (3, 'Forward', 'Lay the ball into the side-of-box space for the winger'),
    (4, 'Winger', 'Run off the flank into the side of the box, look up, cut back or cross low')
) AS v(so, role, job);

-- 19. pp.58-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '5. Goals Assisted from Wide Areas - Low Wide Zones', 'Diagonal switch to far-side forward',
    'With play on one flank, a precise long diagonal is hit over the defence to the opposite winger/forward who has started a run from the far side into the low wide zone or box (Mane to Sane; Messi breaks the line to Hakimi, who carries and switches to Mbappe).',
    'Far-side forward unmarked and starting his run; passer has time after breaking the first line',
    'Find the free far-side attacker in behind at speed for a first-time or one-touch finish across the keeper.',
    NULL, 58, 59, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger / full back', 'Look up early and hit the long diagonal with timing'),
    (2, 'Opposite winger / forward', 'Time the run from far side to arrive with the ball, control at speed and finish far corner'),
    (3, 'Forward dropping (Messi)', 'First pass between two opponents to release the overlapping full back')
) AS v(so, role, job);

-- 20. pp.60-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '5. Goals Assisted from Wide Areas - High Wide Zones', 'Full back drives free corridor, striker checks run',
    'Central midfielder switches to the full back who has a free corridor; he carries into the high wide zone and crosses toward the penalty spot, while the striker lets defenders run past then stops to create space (Gundogan-Cancelo-Haaland).',
    'Free corridor ahead of the full back after a switch from the centre',
    'Cross into the space the striker created by holding up his run at the penalty spot.',
    NULL, 60, 64, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'Spot the free flank and switch the ball to the full back'),
    (2, 'Full back', 'Drive forward fast, stop, look up and cross to the penalty spot'),
    (3, 'Centre forward', 'Let the defenders drop past, slow down and stop to find two metres of space, finish low'),
    (4, 'Winger (practice)', 'Drop to receive, dribble into high wide zone and cross')
) AS v(so, role, job);

-- 21. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '5. Goals Assisted from Wide Areas - High Wide Zones', 'Overlapping centre back crosses to back post',
    'Midfielder releases the wing back, who immediately passes in behind for the advanced run of the outside centre back into the empty high wide zone; he dribbles to the byline and crosses high over the keeper while the striker pulls defenders to the near post (Inter: Barella-Di Marco-Bastoni, Mkhitaryan scores).',
    'Empty high wide space behind the opposing full back',
    'Overload the flank with a third player and find the free back-post runner.',
    NULL, 61, 61, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'Open the play out to the wing back quickly'),
    (2, 'Wing back', 'Pass first time in behind for the overlapping centre back'),
    (3, 'Outside centre back', 'Run beyond into the high wide zone, carry to byline, cross high'),
    (4, 'Centre forward', 'Attack the near post to drag defenders'),
    (5, 'Far central midfielder', 'Arrive free at the back post to finish')
) AS v(so, role, job);

-- 22. pp.63-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 5: Goals Assisted from Wide Areas', 'One-two releases winger for deep cross',
    'Midfielder plays into the winger, gets it back via a one-two and the winger is released into the low wide zone to deliver an early deep cross while two forwards split near and far post; small-sided games only count assists from wide zones, with a wide joker and mobile goals to drill both flanks.',
    'Winger receives in the wide zone after a one-two',
    'Deliver crosses from both low and high wide zones with two box runners on opposite posts.',
    NULL, 63, 66, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder', 'Feed the winger and return pass to release him'),
    (2, 'Winger', 'Receive in the wide zone, cross early and deep'),
    (3, 'Two forwards', 'Make opposite runs to near and far post'),
    (4, 'Central midfielder (game)', 'Choose which wide zone to feed based on the defender''s position')
) AS v(so, role, job);

-- 23. pp.68-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '6. Goals Assisted from Centre Space', 'Winger in centre space turns, slips runner',
    'Wide player passes inside to a winger occupying the central space between the lines; he turns on one touch and plays a through pass into the gap in the box for a midfielder''s run (Alexander-Arnold-Salah-Elliott). Practices: receiver chooses to turn inside or outside, striker''s run signals where the through pass goes, 4v2 in centre space then 2v1 in box, narrow 6v6 game where the final pass must come from centre space.',
    'Receiver in centre space can turn and a runner times a run through a defensive gap',
    'Move from wide to the most dangerous area in two passes and finish one-touch.',
    NULL, 68, 74, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Spot the free player in the centre space and find him'),
    (2, 'Winger/attacking midfielder in centre space', 'Receive, turn on first touch, play through pass in behind'),
    (3, 'Attacking midfielder / forward', 'Start central, time the run between defenders, make eye contact'),
    (4, 'Finisher', 'Beat first defender for speed, finish high')
) AS v(so, role, job);

-- 24. pp.69-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '6. Goals Assisted from Centre Space', 'Simultaneous zone swaps disorganise defence',
    'PSG front players all leave their zones at once: the wide forward drifts inside into midfield to receive, the striker drops toward the halfway line, the other forward moves into the centre; quick short passes then produce a diagonal ball for the inside forward to chip the keeper.',
    'Ball moves from right back into central midfield with attackers rotating',
    'Throw off marking references through fluid rotation and short fast passing.',
    NULL, 69, 69, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Pass inside to the central midfielder'),
    (2, 'Inside forward (Messi)', 'Leave the front line to receive, dribble inside, then make the final run'),
    (3, 'Striker (Neymar)', 'Drop toward midfield and play the short diagonal assist'),
    (4, 'Other forward (Mbappe)', 'Move across into the centre to receive, turn and pass on')
) AS v(so, role, job);

-- 25. pp.76-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '7. Goals Assisted from Half Spaces', 'Early cross from half space to far post',
    'Full back receives in the half space and with minimal time on the ball curls a cross over the defenders toward the far post, where the striker beats his man for speed (Cancelo-Haaland). Practice: long pass across to the opposite half space, receiver controls and quickly delivers an aerial or ground assist into the box.',
    'Ball arrives in the half space with the back line not yet set',
    'Deliver into the box in under a second before the defence can adjust.',
    NULL, 76, 79, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back in half space', 'Deliver early curling cross to far post'),
    (2, 'Centre forward', 'Anticipate, beat defender to the ball, finish'),
    (3, 'Deep player (practice)', 'Switch play long into the opposite half space')
) AS v(so, role, job);

-- 26. pp.77-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '7. Goals Assisted from Half Spaces', 'Half-space through ball between full back and centre back',
    'Attacking midfielder in the half space threads a tight through pass into the gap between the opposing full back and centre back for the striker''s run (Messi-Mbappe), choosing it over safer options. Practices: pass inside then into the half space for a through ball; conditioned games where the assist must come from a half space and only one attacker and one defender may enter the box zone.',
    'Half-space receiver sees a channel open between full back and centre back',
    'Release the striker in behind with correct pass weight for a finish before the keeper arrives.',
    NULL, 77, 82, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder in half space', 'Choose the risky through pass with correct weight'),
    (2, 'Central midfielder', 'Feed the half-space player from the centre'),
    (3, 'Centre forward', 'Run into the full back-centre back gap, adjust body, finish far corner')
) AS v(so, role, job);

-- 27. pp.86-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '8. Goals Scored from Centre of Box - Front Centre', 'Cross to front centre, header knock-down',
    'Full back carries into the centre and switches to the winger high and wide; runners flood the box forcing defenders to protect goal, giving the winger time to cross into the front centre where the striker heads across for an arriving midfielder (Milan).',
    'Winger isolated high with multiple runners attacking the box',
    'Use aerial strength to win the first ball and set up a second header in the front centre of the box.',
    NULL, 86, 86, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Dribble inside and open play to the winger'),
    (2, 'Winger', 'Hold wide position, look up, cross to front centre'),
    (3, 'Centre forward', 'Win the header and knock it across'),
    (4, 'Attacking midfielder', 'Arrive late in the box for the second header')
) AS v(so, role, job);

-- 28. pp.87-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '8. Goals Scored from Centre of Box - Front Centre', 'Winger dribble, through ball, dummy, late midfielder',
    'Winger beats two defenders and the midfield line, plays a through ball for the striker running behind his marker, who crosses into the box; the number 10 lets the ball run and the central midfielder arriving late finishes from the centre (Coman-Muller-Sane-Goretzka).',
    'Winger breaks the midfield line by dribble and draws defenders',
    'Create a 2v1 in the box and a free late arriver at the front centre.',
    NULL, 87, 87, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Dribble past two and play through for the striker'),
    (2, 'Centre forward', 'Run behind marker, cross into the box'),
    (3, 'Number 10', 'Attack the ball then dummy it'),
    (4, 'Central midfielder', 'Arrive late, one touch to set, finish')
) AS v(so, role, job);

-- 29. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '8. Goals Scored from Centre of Box - Back Centre', 'Lofted pass over line for third-man run',
    'Full back finds a winger dropped into the central circle, who has time to chip a long pass over the defensive line for a central midfielder''s third-man run into the back centre of the box; the runner points to where he wants it (Alonso-Raphinha-Pablo Torre).',
    'Deep receiver unpressured and runner signals the gap behind the line',
    'Get a midfielder in behind the back line to finish from the back centre of the box.',
    NULL, 88, 88, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back', 'Pass to the winger in the centre circle'),
    (2, 'Winger dropped central', 'Look up and loft the ball over the defensive line'),
    (3, 'Central midfielder', 'Point the target, make a third-man run in behind, finish first time')
) AS v(so, role, job);

-- 30. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'to_attack', '8. Goals Scored from Centre of Box - Back Centre', 'Counter after regain, cut across to far winger',
    'Just after winning the ball against an unorganised opponent, the midfielder drives into the attacking half and passes wide; the winger carries inside into the box, slows, and squares across to the far winger in front of retreating defenders (Bennacer-Leao-Saelemaekers).',
    'Ball won while opponent has no defensive shape',
    'Exploit defenders running back toward goal by playing across them to the free far-side player.',
    NULL, 89, 89, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'Drive forward into the attacking half and release wide at the right moment'),
    (2, 'Ball-side winger', 'Carry inside, slow down, play across in front of defenders'),
    (3, 'Far-side winger', 'Arrive around the penalty spot unmarked and finish')
) AS v(so, role, job);

-- 31. pp.91-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 8A: Goals Scored from Front Centre of Box', 'Circulate in midfield, then feed front centre',
    'Team keeps the ball in a central zone (3+ passes) then plays forward into the front centre of the box directly or via wide players who pass or dribble in; two forwards combine 2v1, and if no shot is on they recycle back out wide or change the direction of attack to the other goal.',
    'Three passes completed and a forward free in the front centre zone',
    'Arrive in the front centre of the box where most goals are scored, keeping patience when the shot is blocked.',
    NULL, 91, 94, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield players', 'Complete passes and find the forward or wide player'),
    (2, 'Wide players / jokers', 'Pass or dribble into the front centre, deliver crosses'),
    (3, 'Forwards', 'Find free space, receive, finish or square to partner'),
    (4, 'Whole team', 'If no opportunity, play back out and switch direction quickly')
) AS v(so, role, job);

-- 32. pp.96-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 8B: Goals Scored from Back Centre of Box', '4-3-3 lay-off patterns into back centre',
    'From a 4-3-3: centre back to full back to midfielder, into the forward who lays off for an onrushing midfielder; finishes come from the second forward driving into the back centre, the winger running in behind and cutting back, or the central midfielder sending the opposite winger through. Games award double goals when the assist comes from corner crossing zones that defenders cannot enter.',
    'Forward receives and lays off to a midfielder running forward',
    'Generate shots from the back centre of the box (penalty area edge) via set-backs and cut backs.',
    NULL, 96, 99, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back / full back', 'Start the build-up wide'),
    (2, 'Centre forward', 'Lay the ball off for the forward-running midfielder'),
    (3, 'Central midfielders', 'Drive forward, play through for wingers'),
    (4, 'Wingers', 'Run in behind or drive inside to the back centre; cut back low')
) AS v(so, role, job);

-- 33. pp.104-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '9. Build-up Play / Attacks - Play Through Lines', 'Short quick passes break two lines',
    'Midfielder plays into a centrally positioned winger who sets the ball for the striker; the striker drives forward and plays through into the centre of the box for the far winger''s diagonal run (Valverde-Rodrygo-Benzema-Vinicius).',
    'Opposition disorganised by quick short passing, gap opens in the centre',
    'Break both midfield and defensive lines and finish through the middle.',
    NULL, 104, 104, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder', 'Pass forward into the central winger'),
    (2, 'Winger tucked in', 'Set the ball back for the oncoming striker'),
    (3, 'Centre forward', 'Receive, drive and play the through pass'),
    (4, 'Far winger', 'Start wide and deep, run diagonally in behind to finish')
) AS v(so, role, job);

-- 34. pp.105-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '9. Build-up Play / Attacks - Switch of Play', 'Overload one side, switch long',
    'Four players accumulate on one side, pulling the opponent across; a midfielder then sends a long high ball to the advancing opposite full back, who cuts it back to the penalty spot for the striker (Mendy-Camavinga-Kroos-Carvajal-Hazard).',
    'Opponent shifted to the overload side, large space on the weak side',
    'Exploit weak-side space with a long switch and a quick cut back.',
    NULL, 105, 105, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Overload group (4 players)', 'Accumulate on one side to draw the opponent'),
    (2, 'Defensive midfielder (Kroos)', 'Switch with a long pass to the far side'),
    (3, 'Weak-side full back', 'Run toward the byline and cut back'),
    (4, 'Centre forward', 'Anticipate the cut back ahead of defenders')
) AS v(so, role, job);

-- 35. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '9. Build-up Play / Attacks - Attack Wide/Crossing', 'Ball into channel, first-time low cross',
    'Winger passes into the free space near the byline for a fast midfielder overlapping outside; he crosses low first time to the near post before defenders set, where the far winger anticipates and finishes (Asensio-Valverde-Vinicius).',
    'Free space near the byline for a quick runner',
    'Cross before the defence organises and attack the near post.',
    NULL, 106, 106, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Play the deep pass into the channel'),
    (2, 'Attacking midfielder', 'Run outside, cross first touch to near post'),
    (3, 'Far winger', 'Anticipate the delivery, attack near post, one-touch finish')
) AS v(so, role, job);

-- 36. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '9. Build-up Play / Attacks - Attack Through Centre', 'Long pass to striker''s feet, one-two',
    'Central midfielder plays a long pass past the midfield line into the striker at the box edge; the strong striker shields, turns and passes to his strike partner, who returns a first-time ball as the striker runs in behind (Barella-Lukaku-Correa).',
    'Striker free to receive between lines with back to goal',
    'Bypass midfield and finish through the centre with a front-two one-two.',
    NULL, 107, 107, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'Long accurate pass into striker''s feet'),
    (2, 'Target striker', 'Shield, turn, pass and run in behind'),
    (3, 'Second forward', 'Play quickly between defenders, one-touch return')
) AS v(so, role, job);

-- 37. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', '9. Build-up Play / Attacks - Long Pass', 'Keeper long ball, second ball, winger runs',
    'Keeper (used as an extra outfield player to create 3v3 high) kicks long toward the winger who contests; the striker wins the second ball, dribbles, and slips the opposite winger who attacks the space at speed (Alisson-Diaz-Jota-Salah).',
    'Equal numbers 3v3 high up after the keeper joins build-up',
    'Win the second ball in a pre-agreed zone and release the far winger 1v1 at goal.',
    NULL, 108, 108, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Step out to add a player, then hit long to the winger''s zone'),
    (2, 'Ball-side winger', 'Challenge for the long ball'),
    (3, 'Centre forward', 'Win the second ball, carry, pass for the run'),
    (4, 'Far winger', 'Wait for the ball to land in the zone and attack the space at speed')
) AS v(so, role, job);

-- 38. pp.109-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 9A: Play Through Lines & Attack Through Centre', 'Play through the lines, attack through centre',
    'Team builds from the back through central midfield with set-backs and wall passes, moving the ball zone by zone through the middle before a through pass releases wingers running inside the box.',
    'Midfielder or forward receives facing forward between lines after a lay-off',
    'Arrive centrally in the final third and slip a winger in behind for a finish.',
    NULL, 109, 113, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Split pass to start, then step in and play into the near central midfielder'),
    (2, 'Central midfielders (LCM/RCM)', 'Lay back to DM or drive forward with the ball after a set-back'),
    (3, 'Defensive midfielder', 'Receive the lay-off facing forward and play into the deep forward'),
    (4, 'Deep forward (F)', 'Drop between lines, set back to a midfielder, then thread the through ball'),
    (5, 'Wingers', 'Start wide, run diagonally inside the box onto the through pass'),
    (6, 'All', 'Heads up to see options; keep a minimum pass count before penetrating so play is patient')
) AS v(so, role, job);

-- 39. pp.114-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 9B: Attacking Out Wide / Crossing', 'One-two then overlap, cross for three runners',
    'A central player switches out wide to the winger, who plays a one-two with an inside midfielder who has pushed on, then receives high near the byline and crosses while three players attack near post, penalty spot and far post.',
    'Winger receives wide with space to combine',
    'Get the winger to the byline and deliver into a filled box.',
    NULL, 114, 118, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Play the one-two, collect the return high on the flank and cross early'),
    (2, 'Inside midfielder', 'Move forward, give the return pass, then run into the box'),
    (3, 'Centre forward', 'Attack the near/far post area'),
    (4, 'Weak-side winger', 'Attack the far post'),
    (5, 'Wide joker / full back', 'Overlap to make 2v1 out wide when the winger is marked'),
    (6, 'Box rule', 'Only a limited number of attackers enter the box: arrive late with timed runs, 3v2 or 4v3')
) AS v(so, role, job);

-- 40. pp.119-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 9C: Switch of Play & Long Passes', 'Long diagonal, second switch, cut back',
    'A deep player hits a long diagonal to a wide receiver; he controls and switches play again across to the far wide player stepping forward, who drives inside the box and cuts back for a forward timing his run.',
    'Defence shifted to one side after the long ball',
    'Move the block twice so the last receiver is free inside the box for a cut back.',
    NULL, 119, 120, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep passer (CB/DM)', 'Vary angles of the long diagonal from different start spots'),
    (2, 'First wide receiver', 'Control the long ball, switch again immediately'),
    (3, 'Far-side wide player', 'Step off the line to receive, carry into the box, cut back'),
    (4, 'Forward', 'Hold then time the run to meet the cut back')
) AS v(so, role, job);

-- 41. pp.121-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 9C: Switch of Play & Long Passes', 'Long ball into a 2v1 receiving zone',
    'A long pass from deep lands in a final-third receiving zone; if it goes wide the receiver either finds the byline runner for a cut back or crosses, if it goes central two players combine for a through pass. In the full game the team must switch zone to zone twice to find a 2v1 before scoring and attack the second ball.',
    'Long ball reaches a zone with a 2v1',
    'Use the numerical edge created by the switch to finish quickly.',
    NULL, 121, 123, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep passer', 'Hit the long pass left, right or centre, picking the zone with the overload'),
    (2, 'Wide receiver', 'Control, then cut back for the byline runner or cross for the forward'),
    (3, 'Overlapping or byline runner', 'Run off the receiver to get the cut back'),
    (4, 'Central pair', 'Combine and play a through pass for the wide runner inside'),
    (5, 'Team', 'Switch zone to zone until a 2v1 is found; chase the second ball')
) AS v(so, role, job);

-- 42. pp.124-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Tactical Examples 10: Attacking Combination Play in Final Third (Barcelona, centre)', 'Lay-off to facing player, lob for full back',
    'A midfielder with his back to goal lays the ball back to a winger who sees the whole picture; he lobs over a crowded back line for the deep-arriving full back, who squares across the six-yard box for the far winger.',
    'Receiver has back to goal in a packed centre',
    'Lose metres to gain vision, then beat a compact block with an open pass to a late runner.',
    NULL, 124, 125, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Alonso)', 'Start inside to the central midfielder'),
    (2, 'Defensive midfielder (Kessie)', 'Drive forward, then lay back when facing his own goal'),
    (3, 'Right winger (Raphinha)', 'Receive facing play, lob over the line rather than force an inside pass'),
    (4, 'Advanced left back (J. Alba)', 'Arrive from deep unmarked into the box, pass across the six-yard box'),
    (5, 'Left winger / striker (Ferran)', 'Attack the far side of the six-yard box for a tap-in')
) AS v(so, role, job);

-- 43. pp.126-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Tactical Examples 10: Attacking Combination Play in Final Third (Napoli, wide)', 'Wide 4v3 overload, free full back passes in behind',
    'From a throw-in on the right, the opposite winger drifts across out of position to join the full back, midfielder and winger, creating 4v3 wide; the full back is freed by a lay-off and passes into the box for the centre forward running behind the line.',
    'Throw-in or restart wide with a drifting winger',
    'Create a free man wide with time to look up and play in behind.',
    NULL, 126, 126, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Di Lorenzo)', 'Take the throw, get the return, touch and pass in behind'),
    (2, 'Central midfielder (Ndombele)', 'Drop to receive the throw and pass on'),
    (3, 'Left winger out of position (Raspadori)', 'Drift to the ball side to add the extra man and set the full back free'),
    (4, 'Centre forward (Simeone)', 'Time the run behind the line, good first touch, finish far corner')
) AS v(so, role, job);

-- 44. pp.127-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 10A: Attacking Combination Play in Final Third CENTRE', 'Combine round the box, through pass behind line',
    'Players combine quickly in front of the box (forwards, backwards, sideways) and on the right moment slip a pass behind the edge-of-box line for a runner, while defenders shift horizontally to intercept.',
    'Defender steps or a runner gets across his man in the zone behind',
    'Find a player on the run behind the back line at the edge of the box to finish.',
    NULL, 127, 131, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield trio', 'Keep the ball with speed and precision (3 passes) before choosing the through pass'),
    (2, 'Front runners', 'Make diagonal runs into the box from the line in front'),
    (3, 'Receiver behind the line', 'Shoot or square for a teammate if better placed'),
    (4, 'Passer', 'After the through ball follow up into the zone'),
    (5, 'Team on loss', 'Expect a counter; recover at once')
) AS v(so, role, job);

-- 45. pp.132-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Training Session 10B: Attacking Combination Play in Final Third WIDE', 'Give and go on flank, back-post or cut-back cross',
    'A diagonal pass into the centre is laid out wide; the wide player gives and goes with a teammate and receives high on the flank, or a through pass is slipped for the forward. The final ball is an aerial cross to the back post or a low cut back for oncoming runners; in the game version the wide player may also dribble between defenders into the box.',
    'Ball reaches the flank with a teammate close to combine',
    'Break down one flank and deliver to runners arriving from deep.',
    NULL, 132, 136, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'Play out wide, then run into the box as the oncoming runner'),
    (2, 'Wide player', 'Give and go, receive high, choose aerial back-post cross or low cut back'),
    (3, 'Inside forward / striker', 'Offer the wall pass then attack the box or run onto the through ball'),
    (4, 'Opposite attackers', 'Fill near post, penalty spot and back post'),
    (5, 'Team', 'Attack down the same flank, keep 3+ passes in the zone before going forward')
) AS v(so, role, job);

-- 46. pp.137-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'to_attack', 'Tactical Examples 11: Counter Attacks (Liverpool, low zone)', 'Win header, long ball, forward wins duel',
    'After a defensive header in the low zone, the full back plays a long pass up to the centre forward, who fights for it, drives inside and releases the winger running beyond his marker.',
    'Aerial ball won by the defence in its own third',
    'Turn a clearance into a quick final-third chance with few passes.',
    NULL, 137, 138, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (van Dijk)', 'Win the header and direct it to the full back'),
    (2, 'Left back (Robertson)', 'First-time long pass up the pitch to the forward'),
    (3, 'Centre forward (Jota)', 'Fight for every ball, beat his man, drive inside, release the winger'),
    (4, 'Right winger (Salah)', 'Sprint beyond his direct opponent, carry at speed into the box, finish')
) AS v(so, role, job);

-- 47. pp.139-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'to_attack', 'Tactical Examples 11: Counter Attacks (AC Milan, middle zone)', 'Forward wins it, turns, releases fast winger',
    'The centre forward wins the ball in his own half, protects it, turns away with a pivot and dribbles forward before passing out to the fast winger who runs into the empty space and carries into the box.',
    'Ball won in the middle zone with space behind the opponent',
    'Exploit the empty space left by an attacking opponent with one pass and a carry.',
    NULL, 139, 139, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Giroud)', 'Defensive duel, shield, turn, carry, release into space'),
    (2, 'Winger (Messias)', 'Run into free space, carry safely, cut inside and curl into far corner')
) AS v(so, role, job);

-- 48. pp.140-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'out_of_possession', 'Tactical Examples 11: High Press + Counter (Manchester City)', 'Man-to-man high press steals from CB',
    'Forwards press man to man high up the pitch, accepting numerical disadvantage at the back, so the centre back carrying out has no passing lanes; the striker steals and releases the winger to score.',
    'Centre back carries the ball with no free passing lane',
    'Force errors near the opponent''s goal and score before the defence resets.',
    NULL, 140, 140, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Alvarez)', 'Stay alert, press the carrier, steal, carry and slip the winger'),
    (2, 'Wingers (Mahrez)', 'Press their man, then run to receive the release pass'),
    (3, 'Back line', 'Hold man-to-man even if outnumbered to keep the press on')
) AS v(so, role, job);

-- 49. pp.141-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'to_attack', 'Training Session 11A: Counter Attacks from Low or Middle Zone', 'Clear the free kick, launch 3v2 counter',
    'While defending a wide free kick with a few players in the box, two midfielders and a forward stay high; as soon as the ball is cleared or caught they break against two defenders.',
    'Clearance or keeper catch leaves the box',
    'Score from a defensive set piece with a fast 3v2.',
    NULL, 141, 142, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders in box', 'Clear the ball or win it for the keeper'),
    (2, 'Two midfielders', 'Wait outside the box, break forward the moment the ball leaves it'),
    (3, 'Forward', 'Stay high as an outlet and lead the 3v2'),
    (4, 'Goalkeeper', 'Catch and release quickly to start the counter')
) AS v(so, role, job);

-- 50. pp.143-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'to_attack', 'Training Session 11A: Counter Attacks from Low or Middle Zone', 'Win in own half, pass forward first',
    'Defending in the defensive half, the team wins the ball and plays first to a forward or attacker waiting near halfway; teammates join so the break becomes 3v2 or 4v3, while the opponent sprints back.',
    'Ball regained in the low or middle zone',
    'Exploit the moment the opponent is unbalanced with a forward pass and supporting runs.',
    NULL, 143, 145, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four / defenders', 'Step out together to win the ball at the edge of the box'),
    (2, 'Ball winner', 'Play the first pass forward to the target forward'),
    (3, 'Target forward (F)', 'Receive and lay or turn; must link with a teammate'),
    (4, 'Waiting attackers', 'Stay near halfway to give the counter a 3v2'),
    (5, 'Supporting players', 'Sprint forward to add numbers while the opponent recovers')
) AS v(so, role, job);

-- 51. pp.146-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'out_of_possession', 'Training Session 11B: High Press + Counter', 'Press together high, counter at once',
    'From short goal kicks and passes into the opponent''s box area, the front players press together to win the ball and immediately attack the goal; in the game version the opponent must complete 3 passes to escape the half, giving the pressing team the edge.',
    'Goal kick or pass into a receiver near the opponent''s box',
    'Win the ball high and score before the opponent can recover.',
    NULL, 146, 150, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front players (3-5)', 'Move forward as a unit to press the receiver and close passing options'),
    (2, 'Nearest presser', 'Attack the ball and steal it'),
    (3, 'Other pressers', 'Cut the inside pass lanes, then attack the box when the ball is won'),
    (4, 'Team', 'Score quickly on regain; no offside so run straight at goal')
) AS v(so, role, job);

-- 52. pp.151-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Combined Training Session (data-driven)', 'Wide 1v1 or combination into side of box, cut back',
    'Session chaining the top statistics: a midfielder feeds the winger in front of him for a 1v1 into the corner area, or a full back-midfielder-midfielder combination frees the full back on an overlap to receive in the side of the box; the wide player beats his man and cuts back or crosses low to near/far post runners.',
    'Wide player isolated 1v1 or reached in the side of the box',
    'Produce cut backs from the side of the box to the front-centre area, the highest-yield assist and finish zones.',
    NULL, 151, 154, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (W)', 'Beat the defender 1v1, get into the side-of-box area, cut back'),
    (2, 'Right back (RB)', 'Overlap for the through pass, or feed the winger short to dribble inside'),
    (3, 'Midfielders (M1/M2)', 'Combine inside, then run to near post and edge of box'),
    (4, 'Forward (F)', 'Attack near post / front centre for the cut back')
) AS v(so, role, job);

-- 53. pp.155-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coach-your-team-to-score-more-goals-data-driven-analysis-of-europe-s-elite-used-'), 'in_possession', 'Combined Training Session (data-driven)', 'Feed the front-centre forward from wide',
    'A team keeps 3 passes in midfield, then feeds a forward isolated 1v1 in the front centre of the box or a wide joker in a crossing lane; the forward shoots, or if not, recycles to a wide player who crosses while players move into the box.',
    'Third pass completed in midfield',
    'Get the finish in the front centre of the box, where over half the goals are scored.',
    NULL, 155, 155, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'Complete 3 passes before going forward'),
    (2, 'Forward', 'Win the 1v1 in front centre and shoot, or lay out wide'),
    (3, 'Wide players', 'Stay in the crossing lanes and deliver early'),
    (4, 'Box runners', 'Arrive in front centre to meet crosses')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1980-coaching-book-score-more-goals-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
