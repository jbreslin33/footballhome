-- 1965 📚 Coaching book patterns: "Coaching Transition Play" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Coaching Transition Play',
    subtitle    = 'Full Sessions from the Tactics of Simeone, Guardiola, Klopp, Mourinho & Ranieri',
    author      = 'Michail Tsokaktsidis',
    team        = 'Simeone''s Atlético, Guardiola''s Barcelona / Bayern / Man City, Klopp''s Dortmund / Liverpool, Mourinho''s Real Madrid, Ranieri''s Leicester',
    method_note = 'Both transitions, split by direction (defence to attack, attack to defence) and by the zone where the ball is won or lost (low, middle, high). Chapter 1 gives short analyses of how each coach handles transitions; each later tactical situation takes one recurring match pattern (seen 10+ times, many diagrams from Terzis''s team-analysis books) and builds a progressive session (possession game, transition game, position-specific / 11v11) with time limits to train it. App page = printed page + 1. Patterns are the match behaviours (counter-press rules, safety player, routes by zone, first/second/third defender roles), in our words; drill layouts are left out.'
WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo');

-- 1. pp.14-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch1 How important are the transition phases?', 'Immediate pressure on new ball carrier',
    'The moment the ball is lost, before the new carrier can get his head up to pass or dribble forward.',
    'Loss of possession',
    'Stop the counter at source and give the team time to rebalance.',
    NULL, 14, 14, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost the ball', 'Presses the new carrier straight away'),
    (2, 'Nearest teammate', 'Closes the area around the ball as a second presser'),
    (3, 'Rest of team', 'Mark likely receivers and block the passing lanes')
) AS v(so, role, job);

-- 2. pp.14-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 How important are the transition phases?', 'Move the ball forward before they close',
    'On winning the ball, the first aim is to get it forward quickly into the space the unbalanced opponent leaves, before they close down the carrier and mark the next receivers.',
    'Ball won',
    'Use the opponent''s moment of imbalance before they reorganise.',
    NULL, 14, 14, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Looks forward first and releases early'),
    (2, 'Attackers', 'Move into free space to give the forward option')
) AS v(so, role, job);

-- 3. pp.15-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'out_of_possession', 'Ch1 Diego Simeone''s tactics in the transition from defence to attack', 'Compact block shifts and doubles up',
    'Atletico (often 4-4-2) defend narrow and close together with no gaps between the lines. When the ball goes wide the whole unit slides across and presses, so a player who beats one man meets another.',
    'Opponent plays the ball wide',
    'Many bodies near the ball make loose balls easy to win and give a platform to counter.',
    NULL, 15, 15, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'Slide across as one unit towards the ball side'),
    (2, 'Nearest defender', 'Presses the wide ball carrier'),
    (3, 'Second defender', 'Covers behind to meet a carrier who beats the first man'),
    (4, 'Midfield and back line', 'Keep the distance between the lines short')
) AS v(so, role, job);

-- 4. pp.15-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Diego Simeone''s tactics - positive transition example', 'Inside pass to dropping striker, then run in behind',
    'A wide regain is played inside to a central midfielder, then forward to a striker (Griezmann) who drops short. He turns and drives at the open half while the second striker runs ahead of him and the winger overlaps outside, then a pass goes in behind for the runner.',
    'Full back tackles the winger and wins it wide',
    'Attack the space left by the opponent''s committed players within a few passes.',
    NULL, 15, 16, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Juanfran)', 'Wins the ball and passes inside straight away'),
    (2, 'Central midfielders (Tiago, Gabi)', 'Quick forward passes to the striker'),
    (3, 'Dropping striker (Griezmann)', 'Drops short, turns, drives forward, picks the final pass'),
    (4, 'Second striker (Gameiro)', 'Runs ahead to receive or pull a defender away'),
    (5, 'Winger (Correa)', 'Overlapping run into the space in behind and shoots')
) AS v(so, role, job);

-- 5. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Pep Guardiola''s tactics - transition from defence to attack', 'Wide regain: same flank or into centre',
    'Barca push the opponent''s play to the touchline and win it there. With more players near the ball they attack down the same flank. Without that overload they move the ball into the centre for a forward pass while the wingers run diagonally. If no forward pass is on, they go wide and the full backs push on quickly to give width.',
    'Ball won near the touchline',
    'Pick the quickest route to goal based on numbers around the ball.',
    NULL, 17, 17, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (e.g. winger Villa)', 'Dribbles inside or passes to the centre'),
    (2, 'Central playmaker (Messi)', 'Gives the central option and picks the forward pass'),
    (3, 'Wingers', 'Diagonal runs in behind'),
    (4, 'Full backs', 'Push on fast to give width if the forward pass is blocked')
) AS v(so, role, job);

-- 6. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch1 Pep Guardiola''s tactics - transition from attack to defence', '''6 second rule'' counter-press with safety player',
    'After losing the ball Barca press at once to isolate the carrier, stopping him dribbling forward and blocking his passing options. A holding midfielder kept near the ball as a ''safety player'' is first to close him down, and the others converge on the ball zone.',
    'Loss of possession',
    'Win the ball back within about six seconds, or force a mistake.',
    NULL, 18, 18, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Safety player / holding midfielder (Xavi in example, the 6)', 'Positioned near the ball before it is lost; first to press the new carrier'),
    (2, 'Players around the ball', 'Converge on the ball zone and shut passing options'),
    (3, 'Whole team', 'Everyone joins in; no one switches off')
) AS v(so, role, job);

-- 7. pp.19-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Jurgen Klopp''s tactics - Direct Positive Transition', 'Direct Positive Transition after high interception',
    'The ball is intercepted high up the pitch and the carrier is under no pressure, so the attackers burst forward into free space and take the pass on the move.',
    'High interception, no pressure on the ball',
    'Go straight at goal while the opponent is unbalanced.',
    NULL, 19, 19, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Plays forward at once into the path of the runners'),
    (2, 'Attackers', 'Forward runs into free space')
) AS v(so, role, job);

-- 8. pp.19-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Jurgen Klopp''s tactics - Indirect Positive Transition with a Forward Pass', 'Indirect Positive Transition with a Forward Pass',
    'The ball is won high but the carrier is under pressure and cannot pass into the free space. The most advanced forward moves into an open lane to give a pass (not into the space itself), then plays back to a midfielder, who plays forward into the free space from the open ball.',
    'High regain with pressure on the ball',
    'Escape the pressure in one or two passes, then attack the space.',
    NULL, 19, 19, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Most advanced forward', 'Shows in an open lane, then lays the ball back'),
    (2, 'Midfielder', 'Takes the lay-off facing forward and plays into the free space'),
    (3, 'Other attackers', 'Run into the space for the forward pass')
) AS v(so, role, job);

-- 9. pp.19-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Jurgen Klopp''s tactics - Indirect Positive Transition with a Switch of Play', 'Indirect Positive Transition with a Switch of Play',
    'Neither the forward pass nor the pass to the front man is on, so the carrier passes sideways, usually to the full back who breaks forward as soon as the ball is won. In the example a pressed holding midfielder finds the striker, who plays first time into a forward runner, while the far full back overlaps and the rest hold balance.',
    'Ball won but forward lanes blocked by players shifting across',
    'Move the ball away from the press to the free side, accepting that it takes longer.',
    NULL, 19, 20, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Kehl)', 'Intercepts; under pressure, passes to the striker or switches'),
    (2, 'Striker (Lewandowski)', 'First-time pass into a forward runner''s path'),
    (3, 'Runner (Aubameyang)', 'Carries forward; others (9, 10, 11) run to receive the final ball'),
    (4, 'Far full back (Piszczek)', 'Breaks forward at once and overlaps as the outlet for a switch or cross'),
    (5, 'Remaining players', 'Take up balanced, safe positions behind the ball')
) AS v(so, role, job);

-- 10. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch1 Jurgen Klopp''s tactics - transition from attack to defence', 'Weak-side full back drops to make a back three',
    'Dortmund counter-press immediately, which needs four things set up while attacking: extra numbers at the back, balance in midfield, cover near the touchline behind the attacking full back, and a safety player. When a forward pass is intercepted, a midfielder presses the new carrier towards the touchline, another midfielder drops into cover, the near full back tucks in on the winger, a centre back marks the striker tightly, and the other centre back and far full back slide over to form a compact back three.',
    'Forward pass from the back line intercepted in midfield',
    'Regain quickly while staying outnumbering at the back.',
    NULL, 21, 21, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Sahin)', 'Presses the new carrier at once and shows him to the touchline'),
    (2, 'Second midfielder (Bender)', 'Drops in to cover'),
    (3, 'Ball-side full back (Piszczek)', 'Moves inside and marks his winger, the likely receiver'),
    (4, 'Ball-side centre back (Sokratis)', 'Marks the striker tightly to attack a pass into him'),
    (5, 'Other centre back (Hummels) + weak-side full back (Schmelzer)', 'Slide across to cover and form a compact back three')
) AS v(so, role, job);

-- 11. pp.22-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Jose Mourinho - transition from defence to attack in the low zone', 'Deep block, fast forward pass to front pair',
    'Real defend with many players in the low zone and only one or two up near halfway. On winning it they pass forward fast into space so their quicker forwards can play 2 v 2 or 1 v 1.',
    'Ball won deep in own half',
    'Score from a 2 v 2 or 1 v 1 within about 9-12 seconds.',
    NULL, 22, 23, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Plays forward into space straight away'),
    (2, 'Front one or two forwards', 'Stay high and attack the space 2 v 2 or 1 v 1')
) AS v(so, role, job);

-- 12. pp.22-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Jose Mourinho - positive transition example', 'Lanes blocked: switch to advancing full back',
    'When forward and diagonal lanes are blocked after a midfield regain, Real move the ball to the opponent''s weak side, or keep it if no space is free. In the example the holding midfielder intercepts and the forward options are blocked, so he passes across to his partner. The partner hits a long switch to the far full back, who has pushed into free space. The full back carries forward while the winger runs inside to outnumber the opposing full back, two forwards attack the box and one waits at the edge for a cut-back.',
    'Midfield interception with central lanes blocked',
    'Turn a blocked central regain into a weak-side overload and a chance in the box.',
    NULL, 22, 24, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Xabi Alonso)', 'Intercepts and passes sideways to his midfield partner'),
    (2, 'Midfield partner (Khedira)', 'Long switch to the weak-side full back'),
    (3, 'Weak-side full back (Arbeloa)', 'Pushes forward into space, carries and delivers'),
    (4, 'Weak-side winger (Di Maria)', 'Inside run to outnumber the opposing full back and receive in behind'),
    (5, 'Strikers (Benzema, Ozil) + far winger (Ronaldo)', 'Two run into the box; Ronaldo waits at the edge for a cut-back'),
    (6, 'Remaining players', 'Shift across to support and guard against losing it')
) AS v(so, role, job);

-- 13. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Jose Mourinho - transition from defence to attack in the low zone', 'Four-man counter to the weak side',
    'Often four Real players break and the ball is moved wide at the right moment to use space on the opponent''s weak side.',
    'Low-zone regain with space on the far side',
    'A faster counter, finished in about 7-9 seconds.',
    NULL, 23, 23, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner / first passer', 'Gets the ball wide to the weak side at the right moment'),
    (2, 'Four attackers', 'Break together, using the width of the weak side')
) AS v(so, role, job);

-- 14. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Jose Mourinho - transition from defence to attack in the low zone', 'Crowded centre: support from back and sides',
    'When the opponent has many players in the centre, one or two Real players (often a wide forward) come in fast from the back and the sides to take the ball in front of them. The forwards then use their speed to assist or score.',
    'Regain with the opponent packed centrally',
    'Get around the central crowd with quick support, about 10 seconds to finish.',
    NULL, 23, 23, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forward (left or right)', 'Comes in quickly and calls for the ball in space ahead'),
    (2, 'Support runner from deep', 'Sprints up to give an option')
) AS v(so, role, job);

-- 15. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Jose Mourinho - transition from defence to attack in the low zone', 'Dribble at the line, delayed pass in behind',
    'When only four or five opponents are behind the ball and few track back, the carrier dribbles right up to the defensive line to unbalance it. He then slips a late pass to a free teammate on the flank, who plays a low cross between the last defenders and the goalkeeper.',
    'Regain against 4 or 5 defenders, giving 4 v 4 or 5 v 5',
    'Pull the defence apart by carrying, then finish from a low cross.',
    NULL, 23, 23, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Dribbles at the back line and releases late'),
    (2, 'Free flank player', 'Receives in space and plays a low cross between defenders and keeper'),
    (3, 'Central runners', 'Attack the gap between the last line and the keeper')
) AS v(so, role, job);

-- 16. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Jose Mourinho - transition from defence to attack in the middle zone', 'Middle-zone break with diagonal runs behind',
    'Real win it centrally and a player runs forward with the ball while only about four opponents are back and far from their midfield. The carrier dribbles up to the defensive line while the others make diagonal runs in behind.',
    'Central regain in midfield giving roughly 4 v 4',
    'Reach the box before the opponent''s midfield can recover.',
    NULL, 23, 23, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Dribbles up to the defensive line'),
    (2, 'Other attackers', 'Diagonal runs in behind to receive and score')
) AS v(so, role, job);

-- 17. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Jose Mourinho - transition from defence to attack in the middle zone', 'Attack the high line in two passes',
    'When an opponent losing the ball in midfield holds a high line, Real see it at once and attack the space behind with speed. The ball winner plays a quick safe pass and the second player plays the final ball into space for a runner.',
    'Midfield regain against a high defensive line',
    'Get a runner in behind before the line can drop.',
    NULL, 23, 23, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Quick pass that keeps possession'),
    (2, 'Second player', 'Final pass into the space behind'),
    (3, 'Runner', 'Times a sprint in behind the high line')
) AS v(so, role, job);

-- 18. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Jose Mourinho - transition from defence to attack in the middle zone', 'Overload from a late runner (+1)',
    'When the opponent loses the ball with many players ahead of it and only two or three behind, Real break with an extra man from deep, for example 2 (+1) v 2 or 3 (+1) v 3.',
    'Opponent caught with only 2-3 players behind the ball',
    'Create a free player through the timing of the deep run and the pass into him.',
    NULL, 23, 23, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep runner (+1)', 'Times a run from deep to become the spare man'),
    (2, 'Ball carrier', 'Times the pass into space for the spare man'),
    (3, 'Front attackers', 'Pin the remaining defenders')
) AS v(so, role, job);

-- 19. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Jose Mourinho - transition from defence to attack in the high zone', 'High-zone regain, forward pass within 6 seconds',
    'After losing the ball near the opponent''s box, Real press the carrier at very high tempo. On winning it back the winner plays forward at once to a teammate better placed near the box, exploiting gaps in a line that had no time to reorganise.',
    'Ball regained close to the opponent''s penalty area',
    'Finish within about six seconds.',
    NULL, 23, 23, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players', 'Press the carrier at high tempo to deny time and space'),
    (2, 'Ball winner', 'Plays forward immediately to a better-placed teammate'),
    (3, 'Attackers near the box', 'Find gaps in the disorganised line')
) AS v(so, role, job);

-- 20. pp.25-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch1 Jose Mourinho - transition from attack to defence', 'Safety player presses, full backs tuck goal-side',
    'Real stay compact and balanced while attacking, with a safety player (Alonso) sitting behind the ball as a back-pass outlet. When a pass is intercepted he is first to press the carrier. Both full backs move inside to goal-side positions on the wingers, the two holding midfielders block the carrier''s options, and the team closes in to outnumber the opponent around the ball.',
    'Midfield pass intercepted',
    'Win the ball back quickly by outnumbering the opponent in the ball zone.',
    NULL, 25, 26, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Safety player / holding midfielder (Xabi Alonso)', 'Sits behind the ball in possession; first to press after the loss'),
    (2, 'Second holding midfielder (Khedira)', 'Blocks the carrier''s passing options with Alonso'),
    (3, 'Full backs (Marcelo, Arbeloa)', 'Move inside to goal-side positions on the wingers'),
    (4, 'Rest of team', 'Close in on the ball zone')
) AS v(so, role, job);

-- 21. pp.27-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'out_of_possession', 'Ch1 Claudio Ranieri''s tactics', 'Two banks of four, striker stays up',
    'Leicester defend in two compact lines of four, close together. The second striker (Okazaki) works hard to press the ball or track back, and the main striker (Vardy) stays high ready to counter. When the ball is lost they drop straight back into this 4-4-2.',
    'Opponent in possession / ball lost',
    'Deny space and be hard to break down while keeping an outlet for the counter.',
    NULL, 27, 27, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four and midfield four', 'Two tight lines, short distances, strong against crosses'),
    (2, 'Second striker (Okazaki)', 'Presses the ball or tracks back to cover'),
    (3, 'Main striker (Vardy)', 'Stays high as the counter outlet')
) AS v(so, role, job);

-- 22. pp.27-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch1 Claudio Ranieri''s tactics - positive transition example', 'Long ball between centre back and full back',
    'After a low-zone regain Leicester go direct and fast. A midfielder with good range plays long into the space behind the defence, between the centre backs or between a centre back and full back, for the very quick striker. Other forwards sprint up in support.',
    'Ball won in or near own box',
    'Use the striker''s pace to get past the defence in one pass.',
    NULL, 27, 28, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (Morgan/Kante)', 'Moves it forward quickly to a midfielder'),
    (2, 'Ball-carrying midfielder (Kante)', 'Carries forward and passes to the long-passing midfielder'),
    (3, 'Long passer (Drinkwater)', 'Long pass into the space behind the defence'),
    (4, 'Striker (Vardy)', 'Sprints in behind past the centre back, controls and finishes'),
    (5, 'Second striker and winger (Okazaki, Mahrez)', 'Sprint forward to support')
) AS v(so, role, job);

-- 23. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch3 Technical and tactical requirements', 'Clear with purpose, never aimlessly',
    'When defending passes in behind or crosses into the box, players should not hoof the ball away or out of play. They aim the clearance at a teammate or into space for a runner.',
    'Defending a pass in behind or a cross into the box',
    'Turn the defensive action into the first pass of the counter.',
    NULL, 41, 41, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender clearing', 'Clears towards a teammate or into running space'),
    (2, 'Forwards', 'Ready to run onto the clearance')
) AS v(so, role, job);

-- 24. pp.43-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch4 Transition from defence to attack in the low zone', 'Low-zone regain: play through the lines',
    'The opponent has many players high in our half, our defenders have equal or more numbers, and there is lots of space in their half. On winning it the team gets out of pressure with a quick forward pass, plays through the lines, and one or two front players are backed by one to three deep runners. In the example a centre back intercepts and passes straight to the 10, the 10 plays first time into a running 8, and the winger and striker run wide and central.',
    'Ball won in own half against an opponent committed forward',
    'Leave many opponents behind the ball and get in behind within 8-12 seconds.',
    NULL, 43, 44, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (5)', 'Intercepts and plays forward at once'),
    (2, 'Number 10', 'First-time pass into a running midfielder'),
    (3, 'Central midfielder (8)', 'Breaks forward with the ball from deep'),
    (4, 'Winger (11) + striker (9)', 'Run into the space wide and centrally')
) AS v(so, role, job);

-- 25. pp.45-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch4 Tactical Situation 1 (Pep Guardiola tactics)', 'Win it, drop-off, switch to weak-side winger',
    'Bayern defend deep with the whole opposing outfield in one half on Bayern''s right. A centre back dispossesses the winger and passes up the line. The midfield plays forward, and a midfielder drops to receive and switches play long into the empty weak side for the far winger, who has already started running. Two players make fast supporting runs into the box. The session trains pressing to win, then switching to the other zone, with the whole team crossing within about 5 seconds. In the 11 v 11 version the counter goes out wide through gates with a limited group (4 v 3) and must finish within 10-12 seconds.',
    'Tackle in own half while the opponent has overloaded one side',
    'Exploit the free space in the opponent''s half with quick combinations and a long switch.',
    NULL, 45, 50, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Dante)', 'Tackles and passes up the line'),
    (2, 'Midfielder (Kroos)', 'Plays forward to the attacking midfielder'),
    (3, 'Dropping midfielder (Thiago)', 'Drops to receive and switches long to the weak side'),
    (4, 'Weak-side winger (Robben)', 'Starts the forward run early; receives in space, drives in and finishes'),
    (5, 'Support forwards (Muller, Gotze)', 'Fast supporting runs into the box'),
    (6, 'Whole team in practice', 'Move up into the attacking zone within 5 seconds of the regain')
) AS v(so, role, job);

-- 26. pp.51-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'out_of_possession', 'Ch4 Tactical Situation 2 (Diego Simeone tactics)', 'Low block traps the pass into the striker',
    'Atletico defend in the low zone in a compact shape with many players central. A forward closes down the carrier as he tries to pass into the target striker, who is already surrounded by three players, and a central midfielder steps in to intercept. In the session the forwards press the centre backs to block or intercept passes, and the outnumbered midfield presses as one unit.',
    'Carrier tries to pass into the opponent''s centre forward',
    'Force a predictable pass into a crowded centre and win it.',
    NULL, 51, 54, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Villa)', 'Closes down the carrier and makes the pass predictable'),
    (2, 'Three defenders around the target', 'Surround the opponent''s striker'),
    (3, 'Central midfielder (Koke)', 'Steps in to intercept'),
    (4, 'Midfield unit', 'Presses together even when outnumbered, limiting time and space')
) AS v(so, role, job);

-- 27. pp.52-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch4 Tactical Situation 2 (Diego Simeone tactics)', 'Quick one-twos then counter in limited space',
    'After the interception, quick short combinations in tight space (1-2s between the midfielder, a wide player and the forward) release the press. Then a winger makes a long run up the flank, takes the return pass and crosses for the forward, who has kept running, to finish first time. The session adds that if the counter is not on, the team keeps the ball under pressure. In the zonal game at least two players leave the deep zone to support the two forwards, finishing within 10-12 seconds.',
    'Interception in a compact low block',
    'Escape a tight area with one-touch combinations, then finish fast with supporting runs.',
    NULL, 52, 55, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Interceptor (Koke)', 'Plays a short pass and runs forward for the return'),
    (2, 'Wide midfielder (Turan)', 'Carries, combines, then sprints up the flank for the return pass and crosses'),
    (3, 'Forward (Villa)', 'Plays one-twos, keeps running into the box, finishes first time'),
    (4, 'Two or more midfielders', 'Leave the deep zone to support the front two'),
    (5, 'Team when the counter is blocked', 'Keeps possession with good support angles and one-touch passing')
) AS v(so, role, job);

-- 28. pp.57-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch4 Low zone - Tactical Situation 3 (Ranieri): Defensive Organisation to Win the Ball and Fast Running to Support Counter Attack', 'Low-zone regain, ball-winner keeps running forward',
    'Opponent attacks into our half; a forward presses the carrier so a winger can tackle, and the ball-winner immediately carries forward while midfield and forwards sprint up in support.',
    'Tackle/regain after teammate''s pressure on the carrier',
    'Strike before the opponent recovers shape, with the ball-winner arriving in the box as a scorer.',
    NULL, 57, 58, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Okazaki)', 'press the ball carrier from behind to force the error'),
    (2, 'Wide midfielder (Schlupp)', 'win the ball, carry forward, pass and keep running into the box'),
    (3, 'Central midfielder (Kante)', 'sprint forward wide-left to give the first outlet, then play into the box'),
    (4, 'Striker (Vardy) and far winger (Albrighton)', 'fast supporting runs to offer finishing options')
) AS v(so, role, job);

-- 29. pp.58-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch4 Low zone - Ranieri session (Passer Zone practices)', 'Forward pass, then support and team push-up',
    'After winning the ball as a compact, ball-oriented defending unit, the first pass goes to a forward; the passer races up to receive it back while the whole team steps up a zone keeping its shape.',
    'Ball won in own third',
    'Fast counter with numbers arriving behind the forward and no gap left between lines.',
    NULL, 58, 61, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four and midfield', 'press as a unit with tight distances to win the ball'),
    (2, 'Ball-winner / passer', 'play forward at once, then sprint to receive the lay-off'),
    (3, 'Target forward (No.10)', 'hold and lay the ball back to the arriving runner'),
    (4, 'Whole team', 'push up into the next zone before the return pass, keeping shape')
) AS v(so, role, job);

-- 30. pp.63-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch4 Low zone - Guardiola session (3 zone possession game)', 'Secure regain, progress zone by zone',
    'After a collective press wins the ball, the team keeps it with a few quick passes (max 2 touches) and then plays into the next zone, where teammates have run forward to receive.',
    'Ball won after collective press',
    'Keep possession through the transition instead of losing it straight back, then progress.',
    NULL, 63, 65, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defending group', 'press collectively, win the ball and pass forward fast'),
    (2, 'Players near the ball', 'two-touch circulation so pressers cannot close the carrier'),
    (3, 'Support players', 'make fast forward runs into the next zone to receive a one-touch lay-off')
) AS v(so, role, job);

-- 31. pp.63-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch4 Low zone - Tactical Situation 4 (Guardiola): Fast Transition to Attack from the Back - Exploiting Space in Behind', 'Clearance to running full back, run in behind',
    'Ball is won or cleared inside our box (e.g. after an opponent corner); a first touch finds the full back who runs into the empty opposition half, feeds the striker''s run, and the striker beats his centre back 1v1 and cuts back to arriving runners.',
    'Interception/clearance in own box with opponents committed forward',
    'Exploit the free space behind a high opponent; 5 players arrive in the box.',
    NULL, 63, 67, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder (Vidal)', 'clear/redirect the loose ball to a teammate in space'),
    (2, 'Striker (Costa)', 'first touch to the full back, then run the channel, take on the centre back 1v1'),
    (3, 'Right back (Rafinha)', 'carry the ball into the opponent half and pass into the striker''s path'),
    (4, 'Wingers and midfielders (Robben, Muller, Lewandowski)', 'long supporting runs into the box for the cutback'),
    (5, 'Whole team', 'stay compact in own half to draw the opponent deep before regaining')
) AS v(so, role, job);

-- 32. pp.69-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch5 Middle zone - Transition from Defence to Attack in the Middle Zone', 'Striker drags centre back, runner fills centre',
    'A midfielder intercepts in the middle zone and runs at the unbalanced defence; the striker runs wide drawing a centre back, opening the centre for the carrier, while a winger arrives in the box.',
    'Interception in midfield after limiting opponent time/space and blocking lanes',
    'Exploit the disorganised defence within about 8 seconds with up to 5-6 attackers.',
    NULL, 69, 70, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 / ball-winner', 'carry forward at speed, then run into the space the striker vacates'),
    (2, 'Striker (9)', 'run wide to drag the centre back, then cross/square into the centre'),
    (3, 'Far winger (7)', 'run into the box to support the finish'),
    (4, '2-3 midfielders', 'run beyond the forwards to give options')
) AS v(so, role, job);

-- 33. pp.71-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch5 Middle zone - Tactical Situation 1 (Klopp): Fast Break Attack from the Middle Zone', 'Central interception, striker moves to open side',
    'Attacking midfielder steps across to intercept a pass into the central midfielder and drives forward; the striker drifts to the free side to receive on the run, one winger comes inside, the other runs between the centre backs.',
    'Opponent pass into central midfielder after a few passes',
    'Finish while opponent unorganised (8-10 s), passing between CBs or FB-CB gap with a timed run behind.',
    NULL, 71, 77, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Mkhitaryan)', 'intercept, run forward, release the striker'),
    (2, 'Striker (Lewandowski)', 'move into free space wide, receive on the run, dribble inside and choose'),
    (3, 'Wide forward (Reus)', 'move into the centre as a lay-off option'),
    (4, 'Wide forward (Aubameyang)', 'run between the two converging centre backs'),
    (5, 'Ball-winners near the ball', 'after regain, first secure the ball with quick passes to outside players before going forward')
) AS v(so, role, job);

-- 34. pp.78-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch5 Middle zone - Tactical Situation 2 (Mourinho): Creating an Overload with a Fast Break Attack', 'Overload counter: winger and striker stretch CBs',
    'No.10 wins the ball in midfield and carries; winger moves wide to take the pass on the run and draws one centre back, striker runs behind and receives, pulling the other centre back, and the No.10 runs straight into the centre forward spot for the cross.',
    'Interception in midfield giving a temporary numerical advantage',
    'Use the overload (e.g. 5v3) to stretch the back line and score within ~10 s before recovering defenders return.',
    NULL, 78, 83, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 (Ozil)', 'intercept, carry, release wide, then direct run into centre-forward spot'),
    (2, 'Left winger (Ronaldo)', 'move wide to receive on the run, draw a centre back'),
    (3, 'Striker (Benzema)', 'run in behind the drawn CB, receive and cross'),
    (4, 'Far winger (Di Maria)', 'support run on the weak side'),
    (5, 'Recovering defenders', 'sprint back, short steps to turn, to close the overload fast')
) AS v(so, role, job);

-- 35. pp.84-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch5 Middle zone - Tactical Situation 3 (Simeone): Fast Break Attacks with Support Players', 'Interception, curved overlapping run from striker',
    'A forward intercepts a misplaced switch in the centre and dribbles at the box while the other striker sprints across on a curved overlap outside him, receives in stride and checks back past his marker to finish.',
    'Short/misplayed opponent pass in the centre',
    'High-speed positive runs into space to finish while opponent unbalanced.',
    NULL, 84, 88, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Griezmann)', 'intercept, drive at the box, slip the overlapping runner'),
    (2, 'Striker (Torres)', 'curved overlap on the outside, receive, cut back past defender and finish'),
    (3, 'Midfield runners', 'run from behind into the next zone to support, ask for the ball into space'),
    (4, 'Team after regain', 'move the ball quickly away from pressure to the other zone, finish within ~12 s; overlaps/underlaps allowed')
) AS v(so, role, job);

-- 36. pp.89-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch5 Middle zone - Tactical Situation 4 (Mourinho): Exploiting a Numerical Advantage in the Centre with Fast Support Play', 'Central regain, inside pass, diagonal runs',
    'Holding midfielder intercepts a forward pass, is pressed and plays inside to a free central midfielder, who finds the winger before the opponent winger blocks; the winger drives at the box while striker and opposite winger make diagonal runs.',
    'Interception of a centre back''s forward pass',
    'Exploit the central overload with fast support; finishing options of two diagonal runners or a shot.',
    NULL, 89, 94, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Alonso)', 'intercept and switch inside under pressure'),
    (2, 'Central midfielder (Khedira)', 'receive in space and release the winger'),
    (3, 'Winger (Di Maria)', 'drive towards the box, pass or shoot'),
    (4, 'Striker (Benzema) and far winger (Ronaldo)', 'diagonal runs into the box'),
    (5, 'Player from next line', 'step up into the next zone on the counter to make it 3v2/5v3'),
    (6, 'Team on regain', 'spread out to use all space; out of possession close space to force errors')
) AS v(so, role, job);

-- 37. pp.95-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'out_of_possession', 'Ch5 Middle zone - Mourinho session: Blocking Passes Out Wide to Exploit a Numerical Advantage in the Centre', 'Block wide passes, funnel into central overload',
    'Against a 4-2-3-1 building up, a 4-4-2 diamond blocks the passing lanes to the flanks (where it would be outnumbered 2v1) so the play is forced inside into a 4v3 central midfield advantage, where the ball is won and countered.',
    'Opponent build-up from their goalkeeper',
    'Win the ball where we have numbers and launch a fast break with combination play.',
    '4-2-3-1', 95, 95, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Diamond midfielders', 'angle pressure to block passes out wide, then double up in the centre'),
    (2, 'Front two', 'screen and press centre backs inward'),
    (3, 'Ball-winner', 'counter at once with quick combinations and supporting runs')
) AS v(so, role, job);

-- 38. pp.97-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch5 Middle zone - Tactical Situation 5 (Guardiola): Fast Break Attacks Using Wide Players', 'Double-team carrier, instant 2v1 counter',
    'When the opponent plays forward, the nearest two players immediately double the new ball carrier; whoever wins it has his partner free beside him, giving an instant 2v1.',
    'Opponent''s forward pass to a receiver near two of our players',
    'Turn the double-team regain directly into a 2v1 break.',
    NULL, 97, 99, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Busquets)', 'press the receiver and intercept'),
    (2, 'Winger (Pedro)', 'double the carrier, then spin into space to receive'),
    (3, 'Ball-winner', 'draw the first defender then pass, or attack goal if the defender covers the partner'),
    (4, 'Second attacker', 'time the run to receive on the move, finish in two touches')
) AS v(so, role, job);

-- 39. pp.97-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch5 Middle zone - Guardiola session: Fast Break Attacks with Wide Players - Crossing and Finishing', 'Regain centrally, release winger, crowd box',
    'After pressing collectively in the centre, the ball goes out quickly to a winger behind the opponent''s defensive line who crosses or plays a final ball while 2-3 central players and the opposite winger run into the box.',
    'Ball won in the central zone',
    'Cross or final ball into a filled penalty area as fast as possible.',
    NULL, 97, 102, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'press, win, play out wide immediately'),
    (2, 'Ball-side winger (Pedro)', 'receive behind the defensive line, carry and cross'),
    (3, 'Attacking midfielders (Iniesta, Messi)', 'run into the box for the cross'),
    (4, 'Deep midfielder (Xavi)', 'take position at the edge of the area'),
    (5, 'Far winger', 'arrive at the back post')
) AS v(so, role, job);

-- 40. pp.103-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch5 Middle zone - Tactical Situation 6 (Simeone): Fast Break Attacks with Quick Combination Play in the Centre', 'Squeeze centre, combine out, full back crosses',
    'Compact team squeezes the centre to win the ball, then breaks pressure with quick one-touch combinations in tight space before going wide to the overlapping full back, who crosses for many runners in the box.',
    'Tackle on a squeezed opponent midfielder',
    'Escape pressure by combination play and counter effectively, finishing within 10-12 s.',
    NULL, 103, 107, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Tiago)', 'tackle and pass forward, then make a forward run'),
    (2, 'Central midfielders (Garcia, Niguez, Turan)', 'quick one-touch combinations in tight space, then switch wide'),
    (3, 'Right back (Juanfran)', 'run forward, receive wide and cross'),
    (4, 'Forward (Griezmann) and others', 'timed runs into the box to attack the cross'),
    (5, 'Central players behind forward', 'after the pass into the striker, run up to support under pressure')
) AS v(so, role, job);

-- 41. pp.109-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch6 High zone - Transition from Defence to Attack in the High Zone', 'High press regain, quick ball behind',
    'Team presses high in the opponent half, closes the carrier and blocks lanes; after an interception, the carrier moves inside to draw the holding midfielder, a teammate receives in space at the box edge and plays a diagonal between centre back and full back for a winger''s run.',
    'Interception from a forced pass during the high press',
    'Get into the box before defenders recover; finish within 4-8 seconds.',
    NULL, 109, 110, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder (8)', 'intercept high and dribble inside to draw the defensive midfielder'),
    (2, 'No.10', 'move forward into the freed space, play the through ball'),
    (3, 'Winger (7)', 'timed run between CB and FB, first-time finish'),
    (4, 'All pressers', 'tight marking and positioning to limit the carrier''s options')
) AS v(so, role, job);

-- 42. pp.111-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch6 High zone - Tactical Situation 1 (Ranieri): Pressing High Up the Pitch and Fast Break Attack (1a)', 'Tight marking on opponent throw-in, steal',
    'On an opponent throw-in in their defensive third, the team marks tightly high up so the receiver must play back; the winger reads the back pass and intercepts, the striker runs inside and slips the other striker in behind.',
    'Opponent throw-in in their defensive third',
    'Steal the ball near goal and play in behind into the box at once.',
    NULL, 111, 112, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Albrighton)', 'anticipate the pass back to the full back, intercept, block return pass'),
    (2, 'Striker (Vardy)', 'pick up the loose ball, run inside, draw the centre back, pass in'),
    (3, 'Striker (Okazaki)', 'run into the box, take a touch away from defender, finish low'),
    (4, 'Rest of team', 'mark tight to stop the opponent playing out')
) AS v(so, role, job);

-- 43. pp.113-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch6 High zone - Ranieri TS1: Pressing High Up the Pitch and Fast Break Attack (1b)', 'High regain, straight ball in behind',
    'Opponent has cleared to their own half; front three push up to rush the receivers while a centre back heads the clearance on. A winger reads the next pass, steps in front and intercepts.',
    'Interception of a hurried pass in the opponent''s half',
    'Play the ball behind the back line into the box at once so the striker can beat the keeper before the defence turns.',
    NULL, 113, 113, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front three (Vardy, Mahrez, Schlupp)', 'sprint up on the clearance to cut the receivers'' time'),
    (2, 'Centre back', 'win the clearance header and knock it forward to a teammate'),
    (3, 'Right winger (Mahrez)', 'anticipate the full back pass, intercept, first-time ball in behind'),
    (4, 'Striker (Vardy)', 'run in behind, get there before the keeper, lift it over and finish')
) AS v(so, role, job);

-- 44. pp.114-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch6 High zone - Ranieri TS1 session (practices 1-2)', 'Win it, release into free space',
    'After winning the ball in a crowded zone, the first action is a quick pass to a free teammate in another area (support player or other grid) and the whole team follows into that space.',
    'Ball won in a congested area',
    'Escape the pressing zone within about 4 seconds and finish within 4-8 seconds with everyone moved up.',
    NULL, 114, 115, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'pass immediately (within 4 s) to a free support player'),
    (2, 'Support / far-side players', 'offer an outlet in the free zone'),
    (3, 'Rest of team', 'run forward into that zone so the attack has numbers')
) AS v(so, role, job);

-- 45. pp.116-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'out_of_possession', 'Ch6 High zone - Ranieri TS1 session (practices 3-5)', 'Strong-side high press then 8-second break',
    'Opponent builds up from a full back or keeper in their own third; the pressing team squeezes the ball side to create a strong side and a numerical advantage around the ball.',
    'Build-up pass into the pressed side / pass to the pivot',
    'Win the ball high and get it into the end zone within 5 seconds, finishing within 6-8 seconds.',
    NULL, 116, 118, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (10)', 'step in front of the opposition 6 to intercept'),
    (2, 'Near-side forwards and midfielders', 'lock the strong side, outnumber around the ball'),
    (3, 'Winger (11)', 'receive the first pass after the regain and launch the break'),
    (4, 'Whole team', 'synchronised pressing movements; finish inside 8 s')
) AS v(so, role, job);

-- 46. pp.119-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'out_of_possession', 'Ch6 High zone - Guardiola TS2: Pressing High Up the Pitch and Fast Break Attack (2) (Barcelona)', 'Triple-mark the pivot in build-up',
    'Opponent centre back looks to pass into the defensive midfielder in the middle of the pitch. Three Barcelona players (striker and two central midfielders) close him at once.',
    'Centre back''s pass aimed at the opposition 6',
    'Intercept centrally, high up, with the opposition centre backs drawn towards the middle.',
    NULL, 119, 120, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Villa)', 'drop onto the pivot from in front'),
    (2, 'Central midfielders (Xavi, Iniesta)', 'squeeze the pivot from the sides; Xavi intercepts'),
    (3, 'Front line', 'stay high so the regain is near goal')
) AS v(so, role, job);

-- 47. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch6 High zone - Guardiola TS2 analysis (Barcelona)', 'Three quick options after high regain',
    'Midfielder wins the ball in the centre near the opponent''s box while the two centre backs have moved inwards.',
    'Central interception close to the opponent''s goal',
    'Finish fast using whichever is open: slip to the 10 between the lines, carry and slide to a wide forward, or carry and shoot.',
    NULL, 120, 120, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (Xavi)', 'read the centre backs and pick pass, carry-and-pass or shot'),
    (2, 'False 9 / 10 (Messi)', 'show between the centre backs for the easy pass'),
    (3, 'Wide forward (Pedro)', 'run off the shoulder for the carried-then-slipped pass')
) AS v(so, role, job);

-- 48. pp.121-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch6 High zone - Guardiola TS2 session (practice 1)', 'Close space without ball, open with it',
    'Out of possession the team compresses to press and win the ball; the instant it is won the shape flips, players spread wide and deep to keep it.',
    'Regain of possession',
    'Secure the ball after winning it by opening the pitch, not only countering.',
    NULL, 121, 121, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing players', 'close space around the ball to win it'),
    (2, 'All players on regain', 'move outward to open angles and width'),
    (3, 'Neutral / free players', 'act as safe outlets for the first pass')
) AS v(so, role, job);

-- 49. pp.122-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'out_of_possession', 'Ch6 High zone - Guardiola TS2 session (practices 2-5)', 'High press on goal-kick build-up',
    'Opponent builds from the keeper with a back line and midfield; pressing side presses the carrier and the area around him, blocking all passing lanes, often with a man extra.',
    'Keeper''s first pass into the build-up',
    'Win it while the opponent is spread for build-up and score within 6-10 seconds; if the ball is lost again, transition straight back to defending.',
    NULL, 122, 125, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest presser', 'pressure the ball carrier'),
    (2, 'Surrounding players', 'screen every nearby passing lane'),
    (3, 'Ball winner', 'play quickly into the box while the defence is disorganised'),
    (4, 'Team after losing it again', 'react immediately to defend (no keeper behind them in the drill)')
) AS v(so, role, job);

-- 50. pp.126-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'out_of_possession', 'Ch6 High zone - Simeone TS3: Pressing High Up the Pitch and Fast Break Attack (3) (Atletico Madrid)', 'Block inside, force long ball, jump full back',
    'Atletico keep seven players in the opponent half against build-up. A wide midfielder closes the opposition 6 and screens his pass to one side, forcing a long pass to the other flank.',
    'Forced long pass to the far full back / poor first touch',
    'Trap the full back on the touchline and win the ball with the stepping full back.',
    NULL, 126, 127, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfielder (Sosa)', 'close the opposition 6 and cut his pass to the left'),
    (2, 'Left back (Insua)', 'jump forward on the receiving full back''s bad touch and win it'),
    (3, 'Front seven', 'stay in the opponent half to stop easy build-up')
) AS v(so, role, job);

-- 51. pp.127-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch6 High zone - Simeone TS3 analysis (Atletico Madrid)', 'Full back carries, striker overlaps, near post',
    'Full back wins the ball high and drives toward the box; a centre back comes out to him.',
    'Centre back steps to the ball carrier',
    'Exploit the gap behind the stepping centre back: striker runs in behind, low ball to the near post, second striker attacks between the centre backs.',
    NULL, 127, 127, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Insua)', 'carry at the box, release when the centre back commits'),
    (2, 'Striker (Costa)', 'overlapping run into the space behind, cut it back near post'),
    (3, 'Second striker (Villa)', 'dart between the two centre backs to finish')
) AS v(so, role, job);

-- 52. pp.128-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch6 High zone - Simeone TS3 session (practices 1-4)', 'First pass to the free man, 8-second break',
    'After a regain in the high zone, the first pass goes to a teammate free in space so he can choose the direction; wide support players join only during the transition, creating a numerical edge.',
    'Ball won in a press',
    'From regain to shot within about 8 seconds, attacking the players left in front before those behind can recover.',
    NULL, 128, 131, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'first pass straight to a free teammate'),
    (2, 'Free receiver', 'pick the attacking direction and speed'),
    (3, 'Wide / support players', 'join the attack only on the transition to add numbers'),
    (4, 'Pressing unit', 'press high so regains happen where few defenders remain')
) AS v(so, role, job);

-- 53. pp.134-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch7 Technical and Tactical Requirements in the Transition from Attack to Defence', '1st, 2nd and 3rd defender roles',
    'Ball just lost. Nearest player slows the attack with angled pressure; next player covers him and marks the nearest option; a third balances by screening the switch. Others cut passing lanes and may leave only the longest, hardest passes open.',
    'Loss of possession',
    'Win the ball back (not just push it back) by pressing in unison and steering play wide into a numerical advantage.',
    NULL, 134, 137, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '1st defender (nearest)', 'close fast, curve the run to force back, wide or into cover; do not dive in'),
    (2, '2nd defender', 'mark nearest passing option, cover behind the presser, double-team if numbers allow'),
    (3, '3rd defender', 'balance: block the long switch to the far wing'),
    (4, 'Players away from ball', 'get compact in width and depth and intercept passing lines')
) AS v(so, role, job);

-- 54. pp.136-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'in_possession', 'Ch7 Tactical Requirements / zone framework', 'Rest balance while attacking',
    'While in possession the team keeps short distances between midfield and back lines and at least three players near the ball, choosing where it can afford to lose possession.',
    'Team in possession / build-up',
    'Be positioned to counter-press immediately the ball is lost.',
    NULL, 136, 137, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield and back lines', 'stay close together during possession'),
    (2, 'Players near the ball', 'at least three around it, ready to press'),
    (3, 'Team', 'pick the attacking zone so a loss there is survivable')
) AS v(so, role, job);

-- 55. pp.137-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch7 Tactical Requirements', 'Push up or drop: read the pressure',
    'After losing the ball, the back line''s step depends on the ball carrier: if he is contained or forced backwards the defence squeezes up; if he is unpressed it drops to protect the space behind.',
    'Ball carrier forced backwards vs free to look up',
    'Compress the attack away from goal when safe, and never leave runs in behind uncovered.',
    NULL, 137, 137, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '1st defender', 'keep tight pressure once the carrier turns back'),
    (2, 'Back line', 'step up together under pressure, drop together without it'),
    (3, 'Weak-side players', 'be ready to switch the point of defence if play is switched')
) AS v(so, role, job);

-- 56. pp.139-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch8 Transition from Attack to Defence in the Low Zone', 'Low-zone loss: shift, block, regroup',
    'Ball lost during build-up in own half (e.g. winger intercepts a full back''s pass) with the team stretched wide; opponent usually tries to finish in 6-8 seconds.',
    'Interception during own build-up',
    'Delay the attack with instant pressure, cover the danger zone in the centre and get players goal-side so the opponent must play backwards or lose it.',
    NULL, 139, 140, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost it and nearest midfielder (right back, 8)', 'apply direct pressure to the new carrier'),
    (2, 'Other centre back', 'step forward to block the forward pass'),
    (3, 'Far full back and near centre back', 'shift across and mark their direct opponents'),
    (4, 'Defensive midfielder (6)', 'slide across to block passes inside'),
    (5, 'Number 10', 'track and mark the opposing 10')
) AS v(so, role, job);

-- 57. pp.141-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch8 Low zone - Klopp TS1: Building Up From the Back and Quick Transition to Defence (Liverpool)', 'Lost wide in build-up: show outside',
    'Liverpool build out to a full back near the touchline; a short pass back is intercepted by the opposition winger, who finds the striker running forward.',
    'Interception near the touchline in own third',
    'Stop the carrier cutting inside or into the box, push him to the sideline, outnumber around the ball and end the attack (regain within about 6 s).',
    NULL, 141, 147, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near centre back (Klavan)', 'close the striker, then tackle when he is forced wide'),
    (2, 'Near full back (Milner)', 'press the new carrier from the inside'),
    (3, 'Forward and midfielder (Firmino, Wijnaldum)', 'sprint back to close space and add numbers'),
    (4, 'Other midfielder (Henderson)', 'track the run of the player who won the ball'),
    (5, 'Far centre back (Lovren)', 'track the striker''s run into the box')
) AS v(so, role, job);

-- 58. pp.148-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch8 Low zone - Guardiola TS2: Condensing the Space in the Centre and Blocking the Direct Path to Goal (Man City)', 'Condense the centre, force play wide',
    'Ball lost in own half during build-up; the team collapses inward to close the middle and the straight route to goal, accepting play going wide, then slides across together if it does.',
    'Loss of possession in own half',
    'Remove the most dangerous central path, isolate the carrier without passing options and win the ball under pressure.',
    NULL, 148, 154, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back and defensive midfielder (Otamendi, Fernando)', 'close the new carrier from both sides'),
    (2, 'Central midfielder (Garcia)', 'track back to outnumber in the centre'),
    (3, 'Ball-side full back (Maffeo)', 'follow the run of the attacker on his side'),
    (4, 'Far full back (Clichy)', 'tuck into the box to cover'),
    (5, 'Whole team', 'press at angles that block passes to the wide outlets; shift across if the ball goes wide')
) AS v(so, role, job);

-- 59. pp.155-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch8 Low zone - Guardiola TS3: Quick Transition to Defend Inside the Penalty Area (Man City)', 'Collapse into the box after a turnover',
    'Pass lost just outside own box during build-up; opponent moves it quickly to a dribbler running at the area.',
    'Bad touch / interception at the edge of own third',
    'Three players close the carrier while the rest sprint back so about five defend inside the box; the far full back sweeps across to clear the cut-back or cross. Keep defending even when outnumbered and press to prevent a shot within 8 seconds.',
    NULL, 155, 163, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest three (Zabaleta, Sterling, Otamendi)', 'close the new carrier together'),
    (2, 'Other outfield players', 'track back fast to fill the box'),
    (3, 'Far full back (Kolarov)', 'slide across and clear the low cross'),
    (4, 'Central players', 'guard the danger zone in front of goal')
) AS v(so, role, job);

-- 60. pp.157-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch8 Low zone - Guardiola TS3 session (practices 1-2, 4)', 'Win the race to defend the cross',
    'Team has just finished an attack at the other end; a cross is coming into its own box and a defender must contest a 1v1 with an attacker.',
    'Cross delivered from either flank after own attack ends',
    'Get into the box before the attacker, take a goal-side, side-on position and clear.',
    NULL, 157, 163, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Recovering defender', 'sprint back, get goal-side of the attacker'),
    (2, 'Recovering defender', 'stand side-on to see ball and man, then clear'),
    (3, 'Other recovering players', 'pick up the 3v3 runners into the box')
) AS v(so, role, job);

-- 61. pp.165-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch9 Transition from Attack to Defence in the Middle Zone', 'Middle-zone loss: press and pack centre',
    'Ball lost around halfway with both teams crowded centrally and open space behind our line; the opponent can counter with 5-6 players and typically takes about 8 seconds.',
    'Opponent wins the ball in midfield',
    'Immediate pressure on the new carrier while everyone moves into the central area to deny the pass wide or in behind; one non-reacting player can concede a chance.',
    NULL, 165, 166, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (6)', 'close the carrier and block the pass to the striker'),
    (2, 'Full backs, central midfielder, wingers', 'track back and mark a man to stop forward passes'),
    (3, 'Centre backs and central mids', 'read open-ball situations and drop to protect space behind'),
    (4, 'Whole team', 'converge on the ball zone to make a strong side')
) AS v(so, role, job);

-- 62. pp.167-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch9 Middle zone - Klopp TS1: Quick Transition to Defence in the Middle Zone (Dortmund)', 'Double the new carrier, overlapper recovers',
    'Dortmund winger dribbles inside with the right back overlapping and loses it to a centre back, who plays forward into midfield.',
    'Ball lost in the middle zone',
    'Immediate pressure plus a second presser on the receiver and tight marking of the next option gives a numerical edge and a quick regain.',
    NULL, 167, 168, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Bender)', 'press the receiver straight away'),
    (2, 'Attacking midfielder (Mkhitaryan)', 'double up on the same receiver'),
    (3, 'Overlapping right back (Piszczek)', 'drop back immediately'),
    (4, 'Other midfielder (Sahin)', 'mark the opposing 10 tightly')
) AS v(so, role, job);

-- 63. pp.169-173
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch9 Transition from Attack to Defence in the Middle Zone - Tactical Situation 1 (Klopp): Quick Transition to Defence in the Middle Zone', 'Middle-zone counter-press blocking forward passes',
    'Ball lost in the middle third, often during build-up from the back, with the opponent looking for a quick forward pass or direct ball to start a counter.',
    'Ball lost in the middle zone',
    'Shut the quick forward pass and regain the ball within about 6 seconds before the opponent can use its numbers in a fast break.',
    NULL, 169, 173, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players to the ball', 'Sprint onto the new carrier at once, no time to lift his head'),
    (2, 'Midfielders around the ball', 'Collapse together and block forward passing lanes'),
    (3, 'Players far from the ball', 'Re-orient fast to the new situation and take the nearest defensive job, regardless of usual role'),
    (4, 'Back line', 'Hold compact behind the press so a direct ball has no space')
) AS v(so, role, job);

-- 64. pp.174-175
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch9 Tactical Situation 2 (Klopp): Defensive Reactions to an Open Ball Situation', 'Open ball: drop and delay',
    'The ball is lost and the new carrier has time and space (open ball, no immediate pressure possible); opposition forwards start runs in behind.',
    'Carrier unpressured with time to look forward',
    'Deny the pass in behind and buy time for team-mates to reach good defensive positions.',
    NULL, 174, 175, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive line', 'Drop back as forwards run to remove space behind'),
    (2, 'Defensive midfielder (Bender)', 'Close the carrier down without diving in, to delay'),
    (3, 'Ball-side full back (Piszczek)', 'Use the delay to recover into a sound position'),
    (4, 'Attacking midfielder (Mkhitaryan)', 'Track back to give balance in midfield')
) AS v(so, role, job);

-- 65. pp.176-179
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch9 Tactical Situation 2 (Klopp) sessions: Defensive Reactions After Finishing an Attack / Team Shape and Reactions', 'Re-set after the attack ends',
    'An attack finishes (shot, loss, ball out) and the opponent restarts quickly, possibly in a different area of the pitch than where play was.',
    'Own attack finishes or a new ball appears elsewhere',
    'Get everyone back goal-side and organised as a unit before the counter can be finished, adapting to wherever the new ball is.',
    NULL, 176, 179, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players who were in the attack', 'Recover at full speed behind the ball, no switching off after the shot'),
    (2, 'Players nearest the new ball', 'Engage it immediately to slow the counter'),
    (3, 'Whole team', 'Read the new ball position and re-form shape collectively, keeping short distances')
) AS v(so, role, job);

-- 66. pp.180-184
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch9 Tactical Situation 3 (Guardiola): Defensive Reactions When Regaining Possession Immediately Isn''t Possible', 'No instant press: drop, steer wide, double',
    'Barcelona lose the ball (intercepted pass) where the nearest man cannot press at once, so the defence must restore balance first.',
    'Loss where immediate pressure on the carrier is impossible',
    'Cover the forwards'' runs, gain time, then trap the carrier near the touchline and double up.',
    NULL, 180, 184, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive line', 'Drop off to limit space behind'),
    (2, 'Defensive midfielder (Busquets)', 'Recover back to support the defenders'),
    (3, 'Nearest midfielder (Iniesta)', 'Become first defender and keep the carrier near the sideline'),
    (4, 'Winger who lost the ball (Villa)', 'Tuck in towards the centre'),
    (5, 'Ball-side full back (Abidal)', 'First drop to block the diagonal pass to the striker, then step up to double the carrier')
) AS v(so, role, job);

-- 67. pp.184-186
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'out_of_possession', 'Ch9 Tactical Situation 3 (Guardiola) sessions: Team Shape and Quickly Switching the Point of Defence', 'Shift as a unit on the switch',
    'Defending a middle-zone possession team that switches play to a wide player on the far side, often while short of numbers.',
    'Ball switched to the weak side or out wide',
    'Stay a compact block that can move across as one and still protect the goal.',
    NULL, 184, 186, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player to ball', 'Press the carrier'),
    (2, 'Remaining defenders', 'Cover the presser and position relative to the ball, not the man'),
    (3, 'Whole unit', 'On the switch, drop and slide across together without leaving big gaps'),
    (4, 'Far-side players', 'Track back first, giving time for others to recover')
) AS v(so, role, job);

-- 68. pp.186-186
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch9 Tactical Situation 3 (Guardiola) session: Closing the Space in the Centre', 'Collapse into the centre after loss',
    'After losing the ball in midfield the team rushes into the central corridor (about penalty-box width) to cut the passing channels to goal. Practice uses a 4-3-3 vs a 4-2-3-1.',
    'Ball lost in the middle zone',
    'Force the opponent to play back or wide instead of through the middle.',
    NULL, 186, 186, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'Press the new carrier instantly'),
    (2, 'Nearby team-mates', 'Support quickly to create numbers around the ball'),
    (3, 'Centre backs and central midfielders', 'Read the play and converge to block passes through the centre')
) AS v(so, role, job);

-- 69. pp.187-189
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch9 Tactical Situation 4 (Mourinho): Team Shape and Collective Pressing When Possession is Lost', 'Wide loss: press and pin to the line',
    'Real Madrid lose a pass to their winger near the sideline; the opponent full back and winger win it.',
    'Ball lost close to the touchline',
    'Regain or keep the ball trapped wide so the rest of the team can recover; if lost centrally and no regain, midfielders force it out wide.',
    NULL, 187, 189, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (Marcelo)', 'Pressure the new carrier straight away'),
    (2, 'Ball-side central midfielder (Alonso)', 'Take the inside position so the ball stays near the line'),
    (3, 'Centre back (Ramos)', 'Mark the striker'),
    (4, 'Other centre back (Pepe)', 'Shift across to cover'),
    (5, 'Holding midfielder (Khedira)', 'Balance in midfield'),
    (6, 'Far full back (Arbeloa)', 'Tuck in towards the centre')
) AS v(so, role, job);

-- 70. pp.190-193
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch9 Tactical Situation 4 (Mourinho) sessions: Team Shape and Collective Pressing', 'Compact shift, close and mark tight',
    'Middle-zone loss in an 11 v 11 where the opponent then switches to attack the weak side.',
    'Ball lost / opponent restarts on weak side',
    'Reduce time and space, force a bad decision and win the ball.',
    NULL, 190, 193, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'Accelerate onto the carrier and close him down'),
    (2, 'Other players', 'Mark opponents tightly and block direct lanes to goal'),
    (3, 'Whole team', 'Slide across collectively with short distances; react quickly to the weak-side switch'),
    (4, 'Players in possession beforehand', 'Keep good positions while attacking so the loss can be handled')
) AS v(so, role, job);

-- 71. pp.193-193
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_attack', 'Ch9 Tactical Situation 4 (Mourinho) session phase 3', 'Regain in midfield, ball in behind',
    'After winning the ball in the middle zone while the opponent is still pushed forward.',
    'Ball won in middle zone',
    'Score before the opponent can recover.',
    NULL, 193, 193, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner / first receiver', 'Play quickly into space behind the defensive line, relative to where opponents are'),
    (2, 'Supporting attackers', 'Make fast, well-timed runs into the penalty area')
) AS v(so, role, job);

-- 72. pp.195-196
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch10 Transition from Attack to Defence in the High Zone (introduction)', 'High-zone loss: congest centre, block long ball',
    'Ball lost high up with many own players in the opposition half, short distances between lines and lots of space behind the back line; opponent counters typically take 8-12 seconds.',
    'Opponent defender wins the ball in their own half',
    'Press before the carrier lifts his head, win it back or force an error, and never allow the early ball in behind.',
    NULL, 195, 196, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three central midfielders', 'Close the carrier immediately and block passes to their 6 and 10'),
    (2, 'Other attackers/midfielders', 'Move inside to crowd the centre and mark tightly, forcing play wide'),
    (3, 'Defenders', 'Prevent long balls behind; track back fast if the first press fails'),
    (4, 'All', 'Create a strong side with numbers around the ball; avoid fouls that release the pressure')
) AS v(so, role, job);

-- 73. pp.197-203
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch10 Tactical Situation 1 (Mourinho): Losing Possession Near the Opposition''s Penalty Area (1)', 'Lost in their box area: two press, DM marks',
    'Real Madrid switch to an overlapping full back high on the flank; he is dispossessed by the opposing full back near their box.',
    'Ball lost near the opponent''s penalty area',
    'Numerical superiority around the ball wins it back quickly, with spare men behind if the opponent plays through.',
    NULL, 197, 203, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest central midfielder (Alonso)', 'Press the carrier immediately'),
    (2, 'Attacking midfielder (Ozil)', 'Join the press from the other side'),
    (3, 'Defensive midfielder (Khedira)', 'Mark the striker to remove the outlet'),
    (4, 'Back line', 'Keep a spare man in defence and stop balls in behind'),
    (5, 'Whole team', 'Synchronised press of ball and area, aim to regain within ~8 seconds')
) AS v(so, role, job);

-- 74. pp.204-205
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch10 Tactical Situation 2 (Mourinho): Losing Possession Near the Opposition''s Penalty Area (2)', 'Safety full back becomes first defender',
    'Play switched to the winger (Ronaldo) high on the left; he tries to beat the right back and loses it, with the full back held back as safety player.',
    'Winger dispossessed high on the flank',
    'Regain at once; if not, keep the ball pinned near the sideline so others recover.',
    NULL, 204, 205, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (Marcelo)', 'Act as safety player, then become first defender and press'),
    (2, 'Central midfielder (Alonso)', 'Track the opposing winger''s run'),
    (3, 'Striker and No.10 (Benzema, Ozil)', 'Shift across to block the pass into the centre'),
    (4, 'Holding midfielder (Khedira)', 'Move over to balance after Alonso''s shift'),
    (5, 'Centre back (Ramos)', 'Edge to the strong side in case of a long pass'),
    (6, 'Far full back (Arbeloa)', 'Drop back for numbers at the back')
) AS v(so, role, job);

-- 75. pp.205-208
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch10 Tactical Situation 2 (Mourinho) sessions: Quick Reactions / High Press to Block Forward Options', 'Open wide, close small; deny forward options',
    'In possession the team makes the pitch big; on losing it the team instantly makes it small around the ball.',
    'Ball lost',
    'Deny the new carrier any forward pass or dribble and force a mistake within about 6 seconds.',
    NULL, 205, 208, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Team in possession', 'Spread wide and long to keep the ball'),
    (2, 'Nearest players on loss', 'Pressure the carrier immediately and converge on the ball area'),
    (3, 'Rest of team', 'Close space and block forward passing and dribbling routes'),
    (4, 'Team without a keeper behind', 'Synchronise reactions fast because any escape means an easy goal')
) AS v(so, role, job);

-- 76. pp.209-210
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch10 Tactical Situation 2 (Mourinho) session: High Press After Losing Possession in a 3 Zone Game', 'Reaction depends on loss zone',
    'Pitch read as low / middle / high zones; the reaction to losing the ball depends on where it happens.',
    'Loss in high zone vs middle zone',
    'Win the ball high when possible; otherwise stop the opponent progressing into the final zone.',
    NULL, 209, 210, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All players (high-zone loss)', 'Immediate high pressure on the carrier to block forward play'),
    (2, 'Players ahead of the ball (middle-zone loss)', 'Track back and converge on the ball area'),
    (3, 'Players behind the ball (middle-zone loss)', 'Push up to squeeze the space'),
    (4, 'Players caught in front of the ball', 'Get back within 6 seconds')
) AS v(so, role, job);

-- 77. pp.211-212
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'to_defend', 'Ch10 Tactical Situation 3 (Guardiola): Regaining Possession High Up the Pitch', 'Intercepted high: double the receiver, mark forwards',
    'Barcelona''s forward pass from the holding midfielder is cut out by the opposing centre back near the edge of his box.',
    'Forward pass intercepted near the opponent''s box',
    'Whole team converges and recovers the ball high.',
    NULL, 211, 212, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (Xavi, Iniesta)', 'Double mark the carrier'),
    (2, 'Holding midfielder (Busquets)', 'Block the pass to the opposing No.10'),
    (3, 'Centre backs (Abidal, Pique)', 'Mark the two forwards closely to cut passes to them'),
    (4, 'Whole team', 'Squeeze the space around the ball')
) AS v(so, role, job);

-- 78. pp.213-218
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-transition-play-full-sessions-from-the-tactics-of-simeone-guardiola-klo'), 'out_of_possession', 'Ch10 Tactical Situation 3 (Guardiola) sessions: High Pressing and Blocking Forward Passes', 'Press high to block passes forward',
    'Opponent builds from the keeper toward advanced/outside players where they hold a numerical edge; also used straight after losing the ball in the high zone.',
    'Opponent keeper''s first pass, or own loss high',
    'Stop long and short passes through the press into the half where the opponent has more players, and score from the regain.',
    NULL, 213, 218, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front players', 'Push up together and pressure the carrier, denying time to look forward'),
    (2, 'Midfielders', 'Mark tightly around the ball zone and shut passing lanes'),
    (3, 'Players nearest the loss', 'Immediate high press on the new carrier'),
    (4, 'Whole team', 'If the press is beaten, track back quickly to defend own goal')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1965-coaching-book-transition-play-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
