-- 5013 📚 Coaching book patterns: "Mastering the Premier League: The
-- Tactical Concepts Behind Pep Guardiola's Manchester City" (Lee Scott,
-- Pitch Publishing) — Kindle library (spreads s001–s112 from Kindle Cloud
-- Reader).  Every spread read by readers; each distinct team behaviour
-- written up in OUR OWN WORDS with who does what.  Biography, stats and
-- photo plates left out.  Owner's personal library.  (James 11/27 Kindle picks)
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    team        = 'Manchester City (Pep Guardiola)',
    season      = '2016-19',
    method_note = 'An analyst''s study of Guardiola''s record-breaking City: half-spaces, playing out from the back, the inverted full backs, the Fernandinho role, overload-to-isolate, pressing and its re-press triggers, cutting passing lanes and compactness, 8s as 10s, then player chapters (Walker, Stones, Laporte, David Silva, De Bruyne, Sane, Bernardo Silva, Sterling) and an anatomy of City goals. Patterns are the on-pitch behaviours in our words; biography and stats left out. Kindle edition: page numbers are screen spreads.'
WHERE slug = 'kindle-mastering-the-premier-league';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league');

-- 1. pp.8-8
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Introduction', 'Occupy both half-spaces in attack',
    'City split the pitch into five vertical channels and make sure channels 2 and 4 (the half-spaces) are filled whenever they attack.',
    'Attacking phase',
    'Defenders are forced out of their shape to cover the half-spaces, which opens space elsewhere.',
    NULL, 8, 8, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advanced midfielders / inverted players', 'stand in the half-space channels'),
    (2, 'Wide forwards', 'hold the outside channels so the half-spaces stay open')
) AS v(so, role, job);

-- 2. pp.9-11
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Playing Out from the Back', 'Plus-one build-up rule',
    'In the first phase City always keep one more passing option than the number of opponents pressing. Against a single presser the centre backs split to the edges of the box and form a wide triangle with the keeper.',
    'Opponent commits N pressers to the first line',
    'There is always a free man, so the first pass out is clean.',
    NULL, 9, 11, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Ederson)', 'third point of the triangle, plays out of pressure'),
    (2, 'Centre backs', 'split wide to the corners of the box'),
    (3, '''6''', 'becomes the extra man once two press'),
    (4, 'Full back or an ''8''', 'drops in to add one more if three press')
) AS v(so, role, job);

-- 3. pp.9-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Playing Out from the Back', 'Keeper''s medium pass over the press',
    'When opponents press high and in numbers, Ederson skips the short route and plays a mid-range pass over the first line to a full back or ''8'' in space behind it.',
    'High press in numbers blocking the short options',
    'Beats the press directly, so the opponent has no safe choice between pressing high and dropping off.',
    NULL, 9, 17, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Ederson)', 'picks out the free man beyond the press with a medium-range pass'),
    (2, 'Full backs / ''8''s', 'find space just behind the first pressing line')
) AS v(so, role, job);

-- 4. pp.11-12
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Playing Out from the Back', '''6'' as free man through the keeper',
    'Both centre backs are tightly marked and pressed. The ball goes back to the keeper while the CBs spread wide, pulling the two attackers with them. That leaves a vertical lane from the keeper to the ''6'' dropping centrally. Against a 3v2 the free man drops into a pocket.',
    'Two forwards pressing the centre backs',
    'The keeper finds the ''6'', who turns away from pressure and plays forward.',
    NULL, 11, 12, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'split wide to drag the pressers apart'),
    (2, 'Goalkeeper', 'receives the back pass and plays vertically into the ''6'''),
    (3, '''6'' (Fernandinho)', 'drops into the gap between the pressers, turns and feeds forward')
) AS v(so, role, job);

-- 5. pp.12-12
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Playing Out from the Back', 'Full backs held on the ''6'' line',
    'As the keeper takes the ball, the full backs push up only as far as the ''6'' line, so players sit on staggered horizontal lines that give passing angles.',
    'Keeper in possession, structure set',
    'Full backs can drop back wide or inside to offer a bypass option if the press arrives.',
    NULL, 12, 12, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'level with the ''6'', ready to drop wide or inside'),
    (2, '''6''', 'central receiving point ahead of the keeper')
) AS v(so, role, job);

-- 6. pp.12-13
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Playing Out from the Back', 'Cycle across the line, vertical first',
    'The ball moves along the back line, but every receiver looks first for a vertical pass into midfield beyond the press and only passes sideways if it is not on. The full back steps inside into the half-space at CB height, receives, and plays forward to the ''8'' higher up in the same half-space.',
    'Opponent block shifted to the far side',
    'Fast circulation gets round the shifted block on the weak side.',
    NULL, 12, 13, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'scan for a vertical pass before moving it on'),
    (2, 'Full back (Laporte, Walker)', 'steps inside into the half-space on the CB line'),
    (3, 'Central midfielder (''8'')', 'higher in the same half-space to receive the forward pass')
) AS v(so, role, job);

-- 7. pp.14-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Playing Out from the Back', 'Carry out from the back line',
    'Against a deep, passive block that won''t press, a full back (Walker) or a centre back dribbles forward with the ball instead of passing through the line.',
    'Deep, passive opponent block',
    'A defender has to step out to engage, and the space he leaves behind is used by the creative players.',
    NULL, 14, 14, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Kyle Walker)', 'drives forward on the ball past the first line'),
    (2, 'Centre backs', 'may carry in the same way'),
    (3, 'Advanced midfielders / forwards', 'attack the space left by the defender who stepped out')
) AS v(so, role, job);

-- 8. pp.15-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Playing Out from the Back', 'Full back drops into the half-space for keeper',
    'The far-side presser bends his run to cover both the second centre back and the ''6'' while pressing the pass back to the keeper. With no time for the CB to spread wide, the right back drops back into the right half-space.',
    'Curved press cutting off CB2 and the ''6''',
    'Gives the keeper a clear lane out. The ball goes to the half-space first, then into the centre to the ''6'' or an ''8''.',
    NULL, 15, 15, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'plays quickly into the half-space'),
    (2, 'Right back', 'drops into the right half-space to open a lane'),
    (3, '''6'' / ''8''s', 'next target once the ball is in the half-space')
) AS v(so, role, job);

-- 9. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Playing Out from the Back', '''8'' drops between the pressers',
    'Two pressers close in on the keeper. A central midfielder drops from his advanced spot into the half-space, and the keeper''s pass splits the two pressers to reach him.',
    'Keeper pressed by two at close range',
    'Pressers who have stepped out are bypassed and City reach advanced areas comfortably.',
    NULL, 16, 16, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Ederson)', 'plays quickly through the gap between the pressers'),
    (2, 'Central midfielder (''8'')', 'drops into the half-space behind the pressing pair')
) AS v(so, role, job);

-- 10. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Playing Out from the Back', 'Line-splitting pass to advanced platform',
    'The keeper switches to the second centre back, who can turn with little pressure because the opponent pressed high without staying compact. He plays a vertical pass between two opponents on the same line to an ''8'' standing in space behind them.',
    'Opponent pressed high but not compact; CB can turn',
    'Gives City a platform behind the opponent''s lines to launch the attack from.',
    NULL, 16, 16, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'turns and splits the two pressers with a vertical pass'),
    (2, 'Advanced central midfielder', 'waits in the space behind the pressing line')
) AS v(so, role, job);

-- 11. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Playing Out from the Back', 'Full back slides inside to open lane',
    'The left-sided centre back has two opponents close to him but they are spread apart. The left back makes a small sideways move from wide into the left half-space, opening a lane between them.',
    'CB on the ball with two loose pressers',
    'The full back gets the ball through the line, then drives towards halfway or keeps the passing move going.',
    NULL, 17, 17, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left-sided centre back (Laporte)', 'plays through the gap'),
    (2, 'Left back', 'slides inside into the half-space, receives, then drives or combines')
) AS v(so, role, job);

-- 12. pp.18-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Role of the Full-Backs', 'Hybrid full backs, asymmetric',
    'City''s full backs switch between wide, half-space and central positions, sometimes in the same match. Often one full back supports the attack wide while the other stays deep, almost making a back three.',
    'Game plan / opponent / personnel',
    'Keeps both width and a secure base, and adapts to each match.',
    NULL, 18, 19, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking full back', 'advances wide to support the attack'),
    (2, 'Holding full back', 'stays deep beside the CBs as a back three'),
    (3, 'Wingers', 'keep width high when the full backs invert')
) AS v(so, role, job);

-- 13. pp.20-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Role of the Full-Backs', 'Inverted full backs flank the ''6''',
    'Both full backs make diagonal runs inside onto the ''6'' line, giving the base player company. The ball is often played diagonally to an inverted full back (Walker, Delph) who has moved into the half-space.',
    'CB on the ball in midfield build-up',
    'Builds a three-man base plus five forwards spread across all vertical lanes. The shifting block opens gaps, and players behind the ball guard against counters.',
    NULL, 20, 21, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (Walker, Delph)', 'run diagonally inside next to the ''6'''),
    (2, '''6''', 'centre of the three-man base'),
    (3, 'Five forward players', 'spread across wide, half-space and central lanes'),
    (4, 'Centre back', 'plays the diagonal pass into the inverted full back')
) AS v(so, role, job);

-- 14. pp.22-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Role of the Full-Backs', 'Full back fills the vacated half-space pocket',
    'When a touchline winger (Sterling, Sane) holds width and pulls a defender out, the full back makes an advanced diagonal run into the half-space pocket between the lines. With Bernardo Silva inside instead, the full back stays wide. The run is timed with the forward pass to the central midfielder, so the nearest defender can''t cover both.',
    'Ball played into the ''8'' while winger holds the touchline',
    'The full back receives in a dangerous pocket and plays a ball across the back line for the winger''s diagonal run. Key against deep compact blocks.',
    NULL, 22, 23, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Kyle Walker)', 'runs diagonally into the half-space pocket as the pass goes into the ''8'''),
    (2, 'Wide forward (Sterling)', 'holds the touchline, then runs inside behind the line'),
    (3, 'Central midfielder', 'receives and shifts the ball across to the full back')
) AS v(so, role, job);

-- 15. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Role of the Full-Backs', 'Supporting left back on the ''6'' line',
    'On the left, where David Silva drifts wide from the left half-space, the left back stays wide on the ''6'' line and receives in space. From there he can pass outside the winger or into Silva.',
    'Ball shifted across the back line to the left back',
    'Silva plays the winger in behind into the corner of the box.',
    NULL, 24, 24, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Delph, Laporte)', 'deep and wide support, connects to the winger or the ''8'''),
    (2, 'Left ''8'' (David Silva)', 'in the left half-space, slips the through ball'),
    (3, 'Left winger', 'runs into the corner of the penalty area')
) AS v(so, role, job);

-- 16. pp.25-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'The Fernandinho Role', 'Single pivot screens between the lines',
    'With the opponent attacking, City''s 4-3-3 shifts towards 4-1-4-1. The ''6'' guards the gap between the back four and the midfield line, sliding across the width of the box to close pockets. When an opponent drifts into a pocket, the ''6'' moves over to him.',
    'Opponent receiver drifting into a pocket between the lines',
    'Pockets are closed without a midfielder dropping or a defender stepping out, so the shape holds.',
    NULL, 25, 30, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '''6'' (Fernandinho)', 'shifts across to close the gap between the lines'),
    (2, 'Back four', 'hold the line and don''t step out'),
    (3, 'Midfield line', 'stays in shape ahead of the ''6''')
) AS v(so, role, job);

-- 17. pp.26-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'to_defend', 'The Fernandinho Role', 'Tactical foul to kill counters',
    'When City lose the ball, the ''6'' stops quick opposition breaks with small, deliberate fouls (''professional fouls''). The book describes this as a set strategy in 2018/19.',
    'Ball lost, opponent tries to move it forward quickly',
    'The counter is stopped before it builds momentum.',
    NULL, 26, 26, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '''6'' (Fernandinho)', 'commits a small foul to stop the counter'),
    (2, 'Rest of the team', 'recover shape during the stoppage')
) AS v(so, role, job);

-- 18. pp.26-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'The Fernandinho Role', '''6'' late run against low block',
    'When the full backs are wide or high, the ''6'' is the only player at the base, supporting the attack from behind. He picks his moments to join the final-third structure with a late run, mostly against teams in a low, passive block.',
    'Opponent sitting in a low, passive block',
    'Creates a central overload to break a stubborn block.',
    NULL, 26, 26, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '''6''', 'supports from behind, then arrives late centrally'),
    (2, 'Advanced players', 'hold positions that pin the block')
) AS v(so, role, job);

-- 19. pp.27-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'The Fernandinho Role', 'Press-resistant ''6'', disguised turn',
    'When the ''6'' receives with pressure on both sides, he shapes as if to take a backward touch, which pressers read as a cue to press. Instead he lets the ball run past him and turns into the space behind the pressers. Under three-man pressure he picks out the lane to the wide player.',
    '''6'' receives a pass from the CB with pressers on both sides',
    'Breaks the line by dribbling, or finds the lane out wide (e.g. to Sane).',
    NULL, 27, 28, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '''6'' (Fernandinho)', 'fakes a backward touch, lets the ball run, turns into space'),
    (2, 'Centre back', 'plays into the ''6'''),
    (3, 'Wide forward (Sane)', 'outlet once the press is beaten')
) AS v(so, role, job);

-- 20. pp.28-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'The Fernandinho Role', '''6'' as central conduit, probing circulation',
    'The ''6'' stays in the central lane and gets the ball from deep or from players further forward. In long possession spells he passes side to side to probe the block, seeing the whole structure ahead of him.',
    'Settled possession in the opponent''s half',
    'Moves the opponent until a clean forward lane opens, then plays into a teammate in a pocket.',
    NULL, 28, 29, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '''6'' (Fernandinho)', 'hub in the central lane, reads the block, picks safe or forward passes'),
    (2, 'Players in pockets', 'stay available for the forward pass')
) AS v(so, role, job);

-- 21. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'The Fernandinho Role', 'CB-6 steps up into double pivot',
    'In some 2018/19 games Fernandinho played right centre back with Gundogan as ''6''. In possession Gundogan slides to the left of central midfield and Fernandinho steps out of the back line into the right side of midfield. City used this only against teams that did not press hard. Ederson''s high starting position covered for the single centre back left behind.',
    'City in possession against a non-aggressive press',
    'Adds passing lanes out of the back. Fernandinho steps through the line as Gundogan moves away, giving Walker a diagonal pass and creating a central overload.',
    NULL, 31, 31, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back (Fernandinho)', 'steps forward into right central midfield, times the move'),
    (2, '''6'' (Gundogan)', 'slides to the left, away from the ball'),
    (3, 'Right back (Kyle Walker)', 'plays a diagonal pass into the stepping player'),
    (4, 'Goalkeeper (Ederson)', 'holds a high position behind the lone centre back')
) AS v(so, role, job);

-- 22. pp.32-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Overload and Isolate', 'Left-side staggered overload triangles',
    'On the left, David Silva moves into the left half-space to make a triangle with the left winger and left back, backed up by the ''6'' and the left centre back. That gives about 5v3, with players on staggered lines so the man on the ball always has more than one option. The far ''8'' and striker stay central, the right back stays deep for balance, and the right winger holds wide.',
    'Building on one flank',
    'Quick short passing breaks through on that side, and the opponent is stuck choosing between staying compact and pressing.',
    NULL, 32, 33, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left ''8'' (David Silva)', 'into the left half-space, forms the triangle'),
    (2, 'Left back (Zinchenko) and left winger (Sane)', 'outer points of the triangle'),
    (3, '''6'' (Fernandinho) and left CB (Laporte)', 'support behind the overload'),
    (4, 'Right back (Walker)', 'stays deep for balance'),
    (5, 'Right winger (Bernardo Silva)', 'holds the far width')
) AS v(so, role, job);

-- 23. pp.32-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Overload and Isolate', 'Overload and isolate: switch to the 1v1',
    'Short, quick passes in an overloaded zone pull the block towards the ball. Whatever else happens, one winger always stays wide on the far touchline. Once the block has shifted, the ball goes diagonally to that winger, now 1v1 with a single defender.',
    'Opponent block drawn across to the overloaded side',
    'The isolated winger (Sterling, Sane, Mahrez) attacks a lone defender. Opponents can''t stop the overload and the far-side 1v1 at once.',
    NULL, 32, 37, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Far-side winger', 'stays on the touchline at all times, waits for the switch'),
    (2, 'Overload players', 'short passes to draw the block in'),
    (3, 'Ball-side wide player', 'holds width so the ''8'' or full back can attack the half-space')
) AS v(so, role, job);

-- 24. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Overload and Isolate', 'Overload combination beyond the presser',
    'The left centre back passes out to the left back, who plays straight across to the ''6''. The positions of the two midfielders get the ball past the opponent who was pressing and blocking the direct lane. The ''6'' then plays a pass inside the opponent''s right back for the winger to run onto into the box.',
    'Presser blocking the direct pass to the ''6''',
    'Staggered lines move the ball forward at each step, ending in a final pass into the box.',
    NULL, 34, 34, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Laporte)', 'starts the move out to the left back'),
    (2, 'Left back (Zinchenko)', 'passes across inside to the ''6'''),
    (3, '''6'' (Fernandinho)', 'plays through the inside of the right back'),
    (4, 'Left winger (Sane)', 'runs in behind into the box')
) AS v(so, role, job);

-- 25. pp.35-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Overload and Isolate', 'Right-side 3v3 with deep fourth',
    'On the right, City have three players in an advanced 3v3, with the right centre back (Stones) deeper to make it 4v3. The ball goes back to the ''8'' (De Bruyne). He and the right winger (Mahrez) pin the two nearest defenders, and Walker''s diagonal run as the pass arrives breaks through.',
    'Pass played back into the ''8'' in the advanced area',
    'Opens a gap in the back line for the full back''s run and the ''8''''s vertical pass.',
    NULL, 35, 35, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back (Stones)', 'sits deeper as the recycle option, making 4v3'),
    (2, '''8'' (De Bruyne)', 'receives the layoff and plays the vertical pass'),
    (3, 'Right winger (Mahrez)', 'pins the nearest defender'),
    (4, 'Right back (Walker)', 'runs diagonally through the gap')
) AS v(so, role, job);

-- 26. pp.36-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Overload and Isolate', 'Secure switch via back-line chain',
    'When opponents block the forward route on the overloaded side, City keep passing short to pull them further over, then switch. The switch usually goes through a player on the first line rather than one long ball (De Bruyne is the exception): a back pass to the far centre back, or a full back to full back chain, then out to the isolated winger.',
    'Overload side blocked; far winger isolated',
    'A safe switch to the 1v1. If the opponent covers across in time, City go back into the overload.',
    NULL, 36, 37, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (Walker)', 'plays back to the first line to start the switch'),
    (2, 'Far-side centre back or full back (Laporte)', 'receives and plays the clean line out wide'),
    (3, 'Isolated winger (Sane, Sterling)', 'receives 1v1'),
    (4, '''8'' (De Bruyne)', 'may switch in a single long pass instead')
) AS v(so, role, job);

-- 27. pp.38-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'to_defend', 'Pressing', 'Immediate press, CB-6 triangle behind',
    'City''s first action on losing the ball is to press, a mix of Barcelona''s five-second rule and Bayern''s version, which closes lanes and invites passes into a deliberately open area before jumping on them. The two centre backs and the ''6'' normally hold position in a triangle.',
    'Possession lost',
    'Wins the ball back quickly while the triangle stops quick, long passes into the centre.',
    NULL, 38, 39, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest attackers and midfielders', 'press the ball at once, two or three players'),
    (2, 'Centre backs', 'hold position as the base of the triangle'),
    (3, '''6''', 'holds as the apex, guards the central lane')
) AS v(so, role, job);

-- 28. pp.38-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'Pressing', 'High press: wingers curve inside',
    'When the opponent keeps the ball with the keeper or CBs, City''s two wide forwards press first with curved runs, using their cover shadow to block the pass wide. The two ''8''s step onto the opponent midfielders. The striker and full backs react: the striker joins in on a hard press, and the full backs jump onto the opposition full backs or wingers if the ball goes over the top.',
    'Opponent goal kick or CBs in possession',
    'Forces a bad decision or pushes play centrally into City''s numerical superiority. Once the opponent reaches City''s half, the aim switches to closing the centre and forcing play wide.',
    NULL, 38, 39, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forwards', 'press first with curved runs, cover shadow on the wide pass'),
    (2, '''8''s', 'press the opponent midfielders'),
    (3, 'Centre forward', 'joins the press when City go hard'),
    (4, 'Full backs', 'push up onto opposition full backs or wingers on balls over the top')
) AS v(so, role, job);

-- 29. pp.39-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'Pressing', 'Drop to block, re-press on three triggers',
    'If the first press fails, City fall back into a compact block that cuts passing lanes and rests, but stay ready to press high again. The three triggers are a poor touch, a pass out to the wide area, and a forward pass to a player facing his own goal.',
    'Poor touch, pass wide, or receiver facing own goal',
    'Saves energy, then jumps back to a high press when the opponent is vulnerable.',
    NULL, 39, 40, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'compact block that cuts lanes'),
    (2, 'Nearest players', 'jump to press when a trigger fires')
) AS v(so, role, job);

-- 30. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'Pressing', 'Poor-touch press trigger',
    'An opposition CB passes into their base midfielder, whose first touch bounces away from him. The striker and both ''8''s (Aguero, David Silva, Gundogan) step in to close him down while he is focused on the ball and not scanning.',
    'Opponent receiver''s heavy first touch',
    'Uses the split second of distraction to close space and win the ball.',
    NULL, 40, 40, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Aguero)', 'closes from the front'),
    (2, 'Two ''8''s (David Silva, Gundogan)', 'close from the sides to shrink the space')
) AS v(so, role, job);

-- 31. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'Pressing', 'Poor first touch press trigger',
    'Opponent receiving in build-up takes a loose touch; nearest City players converge and, if the ball goes back, keep pressing the backward pass.',
    'Heavy or loose first touch by receiver',
    'Turnover forced from the hurried next pass.',
    NULL, 41, 41, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest 3-4 City players', 'Converge on the ball at once'),
    (2, 'Presser on backward pass', 'Follow the ball back to close the defender''s space'),
    (3, 'Rest of block', 'Sit on forward options to win the rushed pass')
) AS v(so, role, job);

-- 32. pp.41-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'Pressing', 'Wide pass touchline trap',
    'Ball played out to a full-back or wide player; touchline cuts his options to 180 degrees, so City jump him with angled runs, low or high up the pitch.',
    'Pass played into the wide area',
    'Ball trapped on the touchline, no escape inside or forward.',
    NULL, 41, 42, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First presser', 'Curved run cutting the pass back inside to the centre back'),
    (2, 'Second presser', 'Engage the ball carrier'),
    (3, 'Ball-side full back', 'Step tight onto the advanced wide opponent to kill the forward pass'),
    (4, 'Extra midfielder', 'Step out beside the central opponent to block the inside ball')
) AS v(so, role, job);

-- 33. pp.42-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'Pressing', 'Receiver facing own goal trigger',
    'Opponent receives a forward pass in central midfield with his back to City''s goal, often without having scanned.',
    'Pass to a player facing his own goal',
    'Two players collapse on him before he can turn for a turnover.',
    NULL, 42, 42, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Closest midfielder', 'Press from behind/blind side'),
    (2, 'Second midfielder', 'Squeeze from the side to block the turn')
) AS v(so, role, job);

-- 34. pp.43-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'Pressing', 'Wide forwards press inside-out, lure central',
    'When the opponent plays out, the two wide forwards (Sterling, Sane) press the centre backs from outside in, closing the pass to the flanks; striker drops slightly; open-looking central lane is the trap.',
    'Opponent starts building from the back',
    'Force play centrally into a three-man trap instead of around the press.',
    NULL, 43, 43, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forwards (Sterling, Sane)', 'Curve in on the centre backs, block passes wide'),
    (2, 'Central striker', 'Drop off slightly, rest and be ready to press a central pass'),
    (3, 'Two 8s', 'Push up to support and jump the central receiver')
) AS v(so, role, job);

-- 35. pp.44-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'Cutting Passing Lanes and Defensive Compactness', 'Compact 4-5-1 mid/low block',
    'Once the opponent settles into attack, City drop into a compact 4-5-1 with only the striker high; references are ball first, then opponents, then team-mates; centre protected, wide areas conceded.',
    'Opponent has an established attack',
    'No central penetration, every defender supported, players rest without the ball.',
    NULL, 44, 46, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Stay tight and central, keep spacing'),
    (2, 'Midfield five', 'Chain across the centre, deny pockets'),
    (3, '6 (Fernandinho)', 'Deny space between the lines'),
    (4, 'Lone striker', 'Stay advanced as outlet')
) AS v(so, role, job);

-- 36. pp.45-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'Cutting Passing Lanes and Defensive Compactness', 'Immediate block rotation after loss',
    'Just after losing the ball or as the opponent builds, the nearest players block central and wide progression lanes, then press with body angles that keep the lanes shut.',
    'Possession lost / opponent CB on ball deep',
    'Carrier forced to choose: risky lane, long ball or back to keeper (which triggers the press).',
    NULL, 45, 45, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two nearest players', 'Block central and wide forward passes'),
    (2, 'Next three players', 'Take up the open passing lanes'),
    (3, 'Whole unit', 'Press on back pass to keeper')
) AS v(so, role, job);

-- 37. pp.46-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'Cutting Passing Lanes and Defensive Compactness', 'Block shift to ball side, trap wide',
    'Opponent has the ball wide; the whole 4-5-1 slides across as a unit so the carrier has no space forward or inside; on a switch the process mirrors to the other side.',
    'Ball enters a wide area',
    'Carrier trapped on one side; short shifts keep energy for the counter.',
    NULL, 46, 47, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side wide midfielder', 'Engage the ball carrier'),
    (2, 'Back four', 'Slide across, close inside channels'),
    (3, 'Midfield line', 'Shift as a chain to keep distances'),
    (4, 'Far-side players', 'Tuck in, only short shift needed')
) AS v(so, role, job);

-- 38. pp.47-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'Cutting Passing Lanes and Defensive Compactness', 'Quick switch pressed with numbers',
    'Opponent recycles back and plays fast to the opposite flank to escape the block; City press that direct wide pass with several players to stall the attack while the block rotates over.',
    'Fast direct pass out to the far wide area',
    'Win the ball or delay until the block has shifted.',
    NULL, 47, 47, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Four nearest players', 'Shift and engage the receiver'),
    (2, 'Rest of block', 'Rotate across behind them')
) AS v(so, role, job);

-- 39. pp.48-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'Cutting Passing Lanes and Defensive Compactness', 'Near man-to-man high press',
    'Sometimes when the opponent has the ball in its own half, City go almost man-for-man; the striker splits the two centre backs and everyone else marks up.',
    'Opponent in possession in its own half',
    'Force a forward pass into a marked area, or delay so City can drop into the block.',
    NULL, 48, 48, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'Split the centre backs, cut the pass between them'),
    (2, 'Midfield and full backs', 'Mark the nearest opponent tightly'),
    (3, 'Wide attacker', 'Block the wide lane from the centre back')
) AS v(so, role, job);

-- 40. pp.48-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'Cutting Passing Lanes and Defensive Compactness', 'Forward curves to block switch-back',
    'As the opponent circulates across the back line, City''s wide attacker blocks the pass wide and the forward follows the ball, cutting the lane back inside.',
    'Ball moved across the opponent back line',
    'Opponent forced into a pass into pressure or back to the keeper.',
    NULL, 48, 48, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide attacker', 'Block the pass out to the full back'),
    (2, 'Centre forward', 'Track across cutting the return lane')
) AS v(so, role, job);

-- 41. pp.49-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', '8s as 10s', 'Two 8s high in half-spaces',
    'City''s 4-3-3 has two 8s (Silva, De Bruyne) pushing up level with or just behind the wide forwards in the half-spaces, giving a 5-5 split: CBs, 6 and full backs build, 8s, wingers and striker form the front five.',
    'City settle possession heading to final third',
    '8s receive between the lines and overload isolated defenders.',
    NULL, 49, 50, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two 8s (Silva, De Bruyne)', 'Hold high line in the half-spaces'),
    (2, 'Wide forwards', 'Stay very high and wide'),
    (3, 'CBs + 6 (Fernandinho) + full backs', 'Back five that progresses the ball'),
    (4, 'Full backs or 6', 'Step up later to link the two units')
) AS v(so, role, job);

-- 42. pp.51-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', '8s as 10s', 'Sideways pass to unlock vertical lane',
    'Against a 4-4-2 press, a short square pass between centre backs moves the ball to a player with a vertical lane into the high 8; short passes either draw the opponent out or find a forward angle.',
    'Ball holder''s forward pass blocked by press',
    'Ball reaches the 8''s feet in the half-space in one pass.',
    '4-4-2', 51, 51, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First centre back', 'Square pass to partner'),
    (2, 'Second centre back', 'Play vertical into the 8'),
    (3, '8 (De Bruyne)', 'Hold high in the half-space for the vertical ball')
) AS v(so, role, job);

-- 43. pp.51-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', '8s as 10s', '8s on staggered lines',
    'The two 8s often split heights, one dropping towards the ball and one staying high, so the opponent cannot set two central players to mark them.',
    'Opponent tries to settle central marking',
    'Opposition midfield cannot neutralise both 8s.',
    NULL, 51, 51, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearer 8', 'Drop to offer a short option in the half-space'),
    (2, 'Far 8', 'Stay high between the lines')
) AS v(so, role, job);

-- 44. pp.51-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', '8s as 10s', '8 drops wide of CB, chain of three',
    'Against a 4-1-4-1 press, Silva drops into the half-space beside/between centre back and full back, forming a three across the first line; left-back or 6 rotates up into his vacated space.',
    'Opponent pressing high, City struggling to progress',
    'Second pass becomes vertical, bypassing press layers.',
    '4-1-4-1', 51, 52, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left 8 (David Silva)', 'Drop into half-space beside centre back'),
    (2, 'Left back or 6', 'Rotate into the space Silva vacated'),
    (3, 'Centre back', 'Play first pass, then find the vertical')
) AS v(so, role, job);

-- 45. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', '8s as 10s', '8 drops beside 6, double pivot',
    'When the opponent presses with three forwards covering normal lanes, Silva drops alongside the 6 rather than into the back line, making a temporary double pivot and receiving the vertical pass to turn.',
    'Three-man front press blocking usual outlets',
    '8 receives in space and drives forward.',
    NULL, 53, 53, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left 8 (David Silva)', 'Drop level with the 6, receive and turn'),
    (2, '6', 'Pair with Silva as double pivot'),
    (3, 'Centre back', 'Pass vertical into Silva')
) AS v(so, role, job);

-- 46. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', '8s as 10s', 'Full backs inside vs compact 4-4-2',
    'If a deep compact 4-4-2 shuts passes into the 8s, full backs move into the half-spaces level with the 6 and progress, then feed the very high, wide forwards; when the block slides to press wide, the 8s find vacated space and combine.',
    'No pass into the 8s against compact block',
    'Ball progressed wide; 8s then exploit gaps the shift leaves.',
    '4-4-2', 53, 53, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'Step into half-spaces level with the 6, carry forward'),
    (2, 'Wide forwards', 'Hold high and wide for the ball'),
    (3, 'Two 8s', 'Attack space vacated when the block presses wide')
) AS v(so, role, job);

-- 47. pp.54-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', '8s as 10s', 'Wide 3v1 pin and return',
    'Opponent denies the centre, so City create a 3v1 out wide: full back passes to the winger, which pins the defender; quick inside ball to Silva in the half-space, winger runs diagonally beyond and Silva returns it into his path (De Bruyne same on the right).',
    'Opponent packs central lanes, defender isolated wide',
    'Defender overloaded and wide forward released behind.',
    NULL, 54, 55, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Pass to the wide forward, can offer the return'),
    (2, 'Wide forward', 'Receive to pin, lay inside, run diagonally behind'),
    (3, '8 in half-space (Silva / De Bruyne)', 'Receive inside and slide the return through'),
    (4, 'Opposing full back', 'Isolated, cannot cover both')
) AS v(so, role, job);

-- 48. pp.56-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Kyle Walker', 'Inverted full back / back three',
    'Against deep passive blocks Walker moves inside level with the 6 like a midfielder; at other times the left-back pushes high and Walker sits in a back three with the centre backs, shifting the ball along the line until a forward gap opens.',
    'Opponent sits deep and passive',
    'Extra central body for circulation and secure rest defence.',
    NULL, 56, 57, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Walker)', 'Invert next to the 6, or drop into back three'),
    (2, 'Left back', 'Advance to a high line'),
    (3, 'Centre backs', 'Circulate with Walker until a lane opens')
) AS v(so, role, job);

-- 49. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Kyle Walker', 'Full back blind-side overlap',
    'Ball moved from winger inside to the 8 in the half-space; defenders fixate on the ball and the wide lane opens, so the right-back runs outside on the blind side of the nearest defender.',
    'Ball played inside to the half-space 8',
    'Diagonal pass releases the full back behind the block.',
    NULL, 57, 57, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Walker)', 'Sprint outside on the blind side'),
    (2, '8 in half-space', 'Receive and play diagonally into the run'),
    (3, 'Wide forward', 'Give the ball inside and hold the defender')
) AS v(so, role, job);

-- 50. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Kyle Walker', 'Full back holds deep, then wide rotation',
    'While City are still securing the ball, the winger drifts into the half-space and Walker stays slightly deep to offer an easy angle; on receiving, the high 8 moves wide and the winger runs through the half-space.',
    'Centre back on the ball, early build',
    'Full back gets three options: inside, wide to the 8 or the forward''s run into the box.',
    NULL, 58, 58, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Walker)', 'Stay a little deep for a simple pass, then choose'),
    (2, 'Right winger', 'Step inside to empty the flank, then run through half-space'),
    (3, 'Right 8', 'Shift into the wide area, dragging a defender'),
    (4, 'Right centre back', 'Pass into Walker')
) AS v(so, role, job);

-- 51. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Kyle Walker', 'Full back mirrors winger lane',
    'The full back reads the winger: winger wide means full back takes the half-space, winger inside means full back goes wide; the 8''s habits (De Bruyne central, Bernardo drifting) also shape it. A diagonal run into the half-space can receive the winger''s through pass.',
    'Winger''s position ahead / pass 8 to winger',
    'Lanes always occupied; full back arrives into the box.',
    NULL, 59, 59, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Walker)', 'Take the lane the winger leaves; run diagonally into half-space'),
    (2, 'Right winger', 'Hold width and slip the ball through'),
    (3, 'Right 8', 'Connect to winger, adjust lane')
) AS v(so, role, job);

-- 52. pp.60-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Kyle Walker', 'Full back carries inside, switches',
    'Walker dribbles from wide into the half-space, drawing a defender out; instead of forcing past him he spots space in the far half-space and plays the releasing pass.',
    'Defender steps out to the carrying full back',
    'Team-mate released through the opposite half-space into the box.',
    NULL, 60, 60, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Walker)', 'Drive inside, pass into opposite half-space'),
    (2, 'Far-side runner', 'Attack the gap left by the stepping defender')
) AS v(so, role, job);

-- 53. pp.61-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Kyle Walker', 'Full back steps to the 6 line',
    'Ball on the right of the first line, a single defender ahead of Walker but none in the half-space; a short diagonal step puts him level with the 6 to receive higher; from the back three he then passes or carries through gaps.',
    'Isolated defender ahead, empty half-space',
    'Ball arrives on a more advanced platform and draws a defender out.',
    NULL, 61, 62, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Walker)', 'Diagonal step into half-space, receive, pass or carry forward'),
    (2, 'Right centre back', 'Feed Walker'),
    (3, 'Advanced players', 'Exploit the defender who steps out')
) AS v(so, role, job);

-- 54. pp.64-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'John Stones', 'Centre back splits wide for keeper',
    'Under heavy pressure on the goalkeeper, a centre back sprints diagonally backwards towards the corner to give Ederson a passing angle, then plays out to the wide forward away from the block.',
    'Opponent presses the keeper',
    'Escape the press without a long ball.',
    NULL, 64, 64, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Stones)', 'Angled run back towards corner, receive, play wide'),
    (2, 'Goalkeeper (Ederson)', 'Pass short to the centre back'),
    (3, 'Wide forward', 'Hold the wide outlet')
) AS v(so, role, job);

-- 55. pp.65-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'John Stones', 'Full back draws man, 8 drops inside',
    'Stones receives wide from the keeper; Walker offers a diagonal option which drags a presser, opening an inside lane to De Bruyne dropping into the half-space; the inside ball catches the block shifting the wrong way.',
    'Opponent shifts to the full back option',
    'Middle third reached against a block off balance.',
    NULL, 65, 65, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Stones)', 'Receive wide, pass inside'),
    (2, 'Right back (Walker)', 'Offer diagonal option to draw a presser'),
    (3, 'Right 8 (De Bruyne)', 'Drop into the half-space for the inside pass')
) AS v(so, role, job);

-- 56. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'John Stones', 'Centre back passes into pressured 8',
    'Stones uses long passes to switch to a strong-positioned winger when only one forward presses, and also plays into Bernardo dropping into a pocket even with three opponents close.',
    'Lone presser / 8 drops into a pocket',
    'Ball moved past the first line into the final third.',
    NULL, 66, 66, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Stones)', 'Switch long to winger or split pass into the pocket'),
    (2, '8 (Bernardo Silva)', 'Drop into the pocket to receive'),
    (3, 'Far wide forward', 'Hold width for the switch')
) AS v(so, role, job);

-- 57. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'John Stones', 'Centre back as deep 6',
    'With Fernandinho out, Stones played the 6, sitting deep almost between the centre backs and staying behind the ball to protect against counters rather than pushing on.',
    '6 unavailable / need extra counter cover',
    'Secure base, though less forward support.',
    NULL, 67, 67, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Stones)', 'Sit just ahead of the centre backs, cover counters'),
    (2, 'Centre backs', 'Split wide either side')
) AS v(so, role, job);

-- 58. pp.67-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'John Stones', 'Centre back steps up to the 6 line',
    'Against teams settling into a low compact block, a centre back steps from the first line up to the 6''s line to receive; this opens the vertical pass to the right 8. When the whole first line is in the opposition half, he finds the striker who holds it up.',
    'Opponent drops into a compact low block',
    'Vertical lane opened, ball into Bernardo or Aguero.',
    NULL, 67, 68, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Stones)', 'Step into midfield, play vertical or diagonal'),
    (2, 'Partner centre back (Laporte)', 'Pass across to Stones'),
    (3, 'Right 8 (Bernardo Silva)', 'Receive the vertical ball'),
    (4, 'Striker (Aguero)', 'Hold up and link play')
) AS v(so, role, job);

-- 59. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Aymeric Laporte', 'Centre back steps into channel',
    'Laporte on the left of the back line; the defender covering Delph has moved across and opened a channel from the block, so Laporte carries into it or passes forward through the line.',
    'Gap opens between opponents in front',
    'Ball progressed into central areas past a line.',
    NULL, 70, 70, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Laporte)', 'Drive into the channel or pass through the line'),
    (2, 'Left back (Delph)', 'Hold width to drag a defender')
) AS v(so, role, job);

-- 60. pp.71-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Aymeric Laporte', 'Recycle wide, set back for lane',
    'When forward and back passes are cut, the centre back plays out to the free left-back rather than forcing a ball into the 8''s feet; the opponent shifts to the ball, then the left-back sets it back and the half-space lane opens.',
    'Forward pass covered',
    'Opponent shift creates the forward lane on the return.',
    NULL, 71, 71, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Laporte)', 'Circulate wide, then pass forward on the return'),
    (2, 'Left back', 'Receive and set back'),
    (3, 'Left 8', 'Wait in the advanced half-space lane')
) AS v(so, role, job);

-- 61. pp.72-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Aymeric Laporte', 'Asymmetric full backs: one high, one deep',
    'With Laporte at left-back, Walker goes high into the right half-space while Laporte stays deep and cautious, collects wide on the left and plays vertical into the half-space.',
    'Ball on the defensive line, CB at left-back',
    'Security on one side, advanced platform reached by vertical pass.',
    NULL, 72, 72, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Laporte)', 'Stay deep, receive wide, pass vertically'),
    (2, 'Right back (Walker)', 'Push high into the half-space'),
    (3, 'Left half-space player', 'Receive the vertical pass')
) AS v(so, role, job);

-- 62. pp.73-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Aymeric Laporte', 'Press-resistant centre back',
    'Laporte receives from Ederson as two opponents press inward to stop the forward ball; he stays calm on the ball and finds a more advanced team-mate.',
    'Pressed on receiving from the keeper',
    'Press beaten by holding the ball then passing forward.',
    NULL, 73, 73, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Laporte)', 'Stay on the ball under pressure, pass forward'),
    (2, 'Goalkeeper (Ederson)', 'Feed the centre back')
) AS v(so, role, job);

-- 63. pp.73-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'to_defend', 'Aymeric Laporte', 'High line, centre back recovers wide',
    'City''s high line plus counter-press still leaves the space behind; when a direct ball goes over the top into the vacated left-back zone, the centre back collapses back with pace and defends wide 1v1.',
    'Ball lost with left back high / ball over the top',
    'Ball reached first and possession regained.',
    NULL, 73, 74, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Laporte)', 'Sprint back into the channel, win the ball, defend 1v1 wide'),
    (2, 'Left back', 'Caught high on the turnover'),
    (3, 'Back line', 'Stay high, trust recovery pace')
) AS v(so, role, job);

-- 64. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'David Silva', '8 in half-space pocket',
    'Silva plays as left 8 between the half-space and left lane; when the ball is on the back line he sits in the half-space pocket to receive on an advanced platform, which draws a defender and opens space elsewhere. He swaps half-space and wing with the winger by the ball/team-mates/opponent order.',
    'Ball on the defensive line',
    'Advanced platform and chain reaction in the block.',
    NULL, 76, 76, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left 8 (David Silva)', 'Occupy half-space pocket, swap lanes with the winger'),
    (2, 'Left winger', 'Hold width or step inside, opposite to Silva')
) AS v(so, role, job);

-- 65. pp.77-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'David Silva', 'Two-route left-side progression via 8',
    'Ball with the left-back; Silva on the line between wing and half-space, winger hard wide, De Bruyne central as pivot to switch. Either Silva gets it directly, or the winger receives and sets back to Silva, who then times the through ball for an angled run.',
    'Left back on the ball, block denies central return',
    'Through ball beyond the last line for a runner.',
    NULL, 77, 77, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left 8 (David Silva)', 'Receive in pocket, play through ball'),
    (2, 'Left winger', 'Hold width, set back, make angled run'),
    (3, 'Right 8 (De Bruyne)', 'Central pivot for switching left to right'),
    (4, 'Left back', 'Choose between Silva and the winger')
) AS v(so, role, job);

-- 66. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'David Silva', '8 drops in front of block',
    'When the first line cannot find a vertical pass because the block shifts fast, Silva drops between defenders to take the ball in front of the block, turns and breaks lines.',
    'No forward lane from the back line',
    'Lines broken by Silva''s turn.',
    NULL, 78, 78, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left 8 (David Silva)', 'Drop between opponents, receive, turn'),
    (2, 'Defensive line', 'Rotate the ball across to look for him')
) AS v(so, role, job);

-- 67. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'David Silva', 'Step off the presser''s shadow',
    'An opponent presses Fernandinho while blocking the lane to Silva; Silva makes a short diagonal move into the half-space, out of the cover shadow, receives and plays beyond the line for the winger.',
    'Pressing player blocks pass to the 8',
    'Press escaped and winger released.',
    NULL, 78, 78, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left 8 (David Silva)', 'Short diagonal move out of cover shadow'),
    (2, '6 (Fernandinho)', 'Pass once the lane opens'),
    (3, 'Left winger', 'Run in behind for the through ball')
) AS v(so, role, job);

-- 68. pp.79-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'David Silva', 'Cut-back goal from half-space pivot',
    'City''s trademark goal: ball fed into Silva in a pocket on the half-space/central line of a deep block; winger runs diagonally into the box and the striker moves off his marker; Silva slips it between two defenders and the runner drives a low ball across goal for a tap-in.',
    'Ball fed into Silva''s pocket vs deep block',
    'Low cross across the six-yard box for an easy finish.',
    NULL, 79, 79, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left 8 (David Silva)', 'Receive in pocket, through ball'),
    (2, 'Wide forward', 'Diagonal run into the box, low cross'),
    (3, 'Striker', 'Lose his marker, arrive for the tap-in')
) AS v(so, role, job);

-- 69. pp.80-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'David Silva', '8 runs through the block',
    'Against a deep compact block, with Laporte at left-back stepping level with the 6 in the half-space, Silva sits just off the striker and makes a short sharp run between two defenders to take the pass from deep.',
    'Ball with deep left player vs compact block',
    'Chance on goal by breaking the block with a run.',
    NULL, 80, 80, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left 8 (David Silva)', 'Short burst between two defenders'),
    (2, 'Left back (Laporte)', 'Step to 6 line in half-space, pass in behind'),
    (3, 'Striker', 'Pin the centre backs')
) AS v(so, role, job);

-- 70. pp.81-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'to_attack', 'Kevin De Bruyne', 'Right 8 carries the ball through transition',
    'After City win the ball, the right-sided 8 (De Bruyne) drives with it from his own half into the opponent''s half at speed instead of recycling it.',
    'Regain with space ahead of the 8',
    'Cross the halfway line before the opponent can reset, with the option of a long pass to any area.',
    NULL, 81, 82, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder (De Bruyne)', 'carry quickly forward, scanning for a long release pass'),
    (2, 'Wide forwards', 'sprint forward to stretch the retreating line')
) AS v(so, role, job);

-- 71. pp.82-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Kevin De Bruyne', 'Half-space 8 pins defender in no-man''s land',
    'With the wide forward hugging the touchline, the 8 stays central or in the half-space so that the defender between them cannot cover both. When the ball arrives from the centre back or full back, the defender has to choose.',
    'Ball with the right centre back or right back; wide forward holding the touchline',
    'If the defender goes wide, the 8 has room inside; if he stays narrow, the pass out to the winger is open.',
    NULL, 82, 85, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder (De Bruyne)', 'hold the central lane or half-space, off the defender''s shoulder'),
    (2, 'Right wide forward', 'stay wide on the touchline to fix the full back'),
    (3, 'Right centre back / right back (Stones, Walker)', 'feed the 8 or the winger, whichever the defender leaves open')
) AS v(so, role, job);

-- 72. pp.83-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Kevin De Bruyne', 'Receive in the pocket: press-or-drop dilemma',
    'The 8 moves from the half-space into a central pocket between several defenders (often off the striker at the edge of the box) and receives there.',
    'Gap between the opponent''s midfield and back lines',
    'If the block steps out, the 8 beats a man or combines; if it sits, he shoots from range or slides a pass through.',
    NULL, 83, 85, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder (De Bruyne)', 'find the pocket, receive half-turned, then shoot, combine or slip a pass through'),
    (2, 'Striker (Aguero)', 'offer a wall pass or run in behind'),
    (3, 'Right back (Walker)', 'play the vertical pass into the pocket')
) AS v(so, role, job);

-- 73. pp.83-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Kevin De Bruyne / Leroy Sane', 'Driven ball across the line to the far-side runner',
    'When a deep opposing line sits off and denies the space through it, the player on the ball (8 or winger, from the half-space or wide) looks for the far side. He plays a driven, curled or lifted ball across or over the line into the space behind for the opposite wide forward.',
    'Defenders sit off and deny the central pass; far-side winger free on the blind side',
    'The far-side forward runs onto the ball behind the line with a clear chance at goal.',
    NULL, 83, 90, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier: right 8 or wide player (De Bruyne, Sane)', 'spot the far-side space; drive or curl the pass behind the line'),
    (2, 'Far-side wide forward (Sane, Sterling)', 'time a run in behind on the blind side'),
    (3, 'Striker', 'stay central to occupy the centre backs')
) AS v(so, role, job);

-- 74. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Kevin De Bruyne', 'Wide 8/full back underlap overload',
    'The winger (Bernardo) on the touchline, the right back (Walker) deeper and the 8 (De Bruyne) inside form a 3v2 against the two defenders on that side. The ball goes inside to the 8 while the full back makes a delayed run between the two defenders.',
    'Two defenders static and watching the ball in front of them',
    'A quick through ball releases the full back behind the line within seconds.',
    NULL, 85, 85, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wide forward (Bernardo)', 'hold width and play inside to the 8'),
    (2, 'Right central midfielder (De Bruyne)', 'receive and slip the ball past the two defenders'),
    (3, 'Right back (Walker)', 'delayed run through the gap between full back and centre back')
) AS v(so, role, job);

-- 75. pp.86-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'to_attack', 'Leroy Sane', 'Winger release into the channel after regain',
    'On a regain while the opponent is still moving into its attacking shape (for example after their direct ball, or from a quick goalkeeper launch), City play the ball at once through the channel between the opposing right back and centre back. The winger waits a beat, then sprints.',
    'Turnover with the opponent''s shape in flux',
    'A pacy winger gives the defender a head start yet still beats him to goal.',
    NULL, 86, 87, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back / regaining player (Laporte)', 'play the first pass straight into the channel'),
    (2, 'Goalkeeper (Ederson)', 'launch the ball quickly to the wide forwards'),
    (3, 'Left wide forward (Sane)', 'delay the run a second, then accelerate past the defender')
) AS v(so, role, job);

-- 76. pp.88-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Leroy Sane', 'Short wide combination to release winger',
    'On the left, the half-space 8 (Silva), the full back (Mendy/Zinchenko), the winger and the striker combine in a few first-time touches. One option is an inside pass from the full back to Silva and through the right back/centre back channel. Another is a wall pass with Aguero. City slow the tempo with patient passing before this, then speed up sharply.',
    'Opposing right back marks the winger tightly; overload on that side',
    'The winger runs onto a through ball behind the line before cover can arrive.',
    NULL, 88, 89, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left central midfielder (David Silva)', 'circulate the ball and slip it through the channel'),
    (2, 'Left back (Mendy, Zinchenko)', 'feed the winger or the half-space'),
    (3, 'Left wide forward (Sane)', 'lay off first time, then spin in behind'),
    (4, 'Striker (Aguero)', 'wall pass for the through ball')
) AS v(so, role, job);

-- 77. pp.88-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Leroy Sane', 'Winger cushion then inside run',
    'Against a compact block during long possession, the winger stays wide but leaves his marker a five-yard cushion. When the pass is played inside the defender, he bursts into the box. Pace like this in wide areas also stops the back line pushing up, so it drops deeper and leaves room for the 8s.',
    'Ball circulated centrally (e.g. Fernandinho); defender set inside the winger',
    'Get a runner in behind even when the defender holds the better position, and push the whole line deeper.',
    NULL, 88, 90, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wide forward (Sane)', 'keep the cushion, then attack inside the defender onto the pass'),
    (2, 'Holding midfielder (Fernandinho)', 'play the pass in behind to the inside of the defender'),
    (3, '8s', 'use the central space vacated by the deeper line')
) AS v(so, role, job);

-- 78. pp.88-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Leroy Sane / Anatomy of a Goal', 'Ball across the face of goal',
    'Once a wide player is behind the line on an angled run, he looks to square or cut the ball across the six-yard box rather than shoot. The striker attacks the near post and the far-side winger mirrors the run to the far post. Several of the 2018/19 goals in the breakdown end this way.',
    'Wide forward in the box behind the back line',
    'A simple tap-in for the striker or the far-side winger.',
    NULL, 88, 111, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side wide forward (Sane, Sterling)', 'run in at an angle, then pass across the goal'),
    (2, 'Striker (Aguero, Jesus)', 'near-post run'),
    (3, 'Far-side wide forward (Sterling)', 'mirror the run to the far post')
) AS v(so, role, job);

-- 79. pp.92-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Bernardo Silva', 'Inverted winger combines with the 8 vs a lone defender',
    'When Bernardo plays right wing, he drifts inside into the half-space rather than holding width. City do not use the usual overload-isolate here. They bypass the block with quick combinations between him and the right 8 (Gundogan) around one isolated defender, while the opposite winger stays wide to stretch the block.',
    'Right winger collects in the half-space with one defender between him and the 8',
    'A fast one-two around or through the isolated defender into the box.',
    NULL, 92, 93, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wide forward (Bernardo)', 'receive inside, then combine or attack either side of the defender with either foot'),
    (2, 'Right central midfielder (Gundogan)', 'angle for the return pass'),
    (3, 'Far-side wide forward', 'hold width to stretch the block')
) AS v(so, role, job);

-- 80. pp.93-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Bernardo Silva', 'Half-space hub with four options',
    'As an 8 in the half-space, the playmaker receives in a pocket between two opponents and has about four passing outlets, each pressing on a different part of the block. He spreads the ball to build overloads across the width.',
    'Receiving in a pocket between two opponents',
    'Choose the outlet that attacks the weakest point of the block.',
    NULL, 93, 93, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Half-space 8 (Bernardo)', 'receive in the pocket and pick from the outlets'),
    (2, 'Wide forward, striker, full back, other 8', 'offer separate lanes at different depths')
) AS v(so, role, job);

-- 81. pp.94-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Bernardo Silva / Anatomy of a Goal', 'Empty the wide lane: winger inside, full back overlaps',
    'The winger runs off the ball from the wide area across the face of the block into the centre and takes his marker with him. The full back advances into the vacated wide space. The ball goes forward into the winger and is then played out wide to the full back. In the reverse version (goal vs Manchester United), Walker is narrow in the half-space, Sterling makes a decoy run inside and Bernardo runs inside-to-out into the empty wide lane to drive at goal.',
    'Defender follows the winger''s inside run',
    'Free a teammate in the space the run empties; vital against deep compact blocks.',
    NULL, 94, 104, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wide forward (Bernardo, Sterling)', 'decoy run inside to drag the marker'),
    (2, 'Right back (Walker)', 'push high into the emptied wide lane, or step inside to the half-space and play the ball on'),
    (3, 'Right 8 (Bernardo)', 'run inside-to-out into the vacated wide space')
) AS v(so, role, job);

-- 82. pp.95-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Bernardo Silva', 'Diagonal carry across the block',
    'The winger carries at speed from wide towards the centre across the front of the block. If a defender steps out, he passes through the gap left behind (e.g. to Jesus coming in from the left). If the block stays compact, he reverses the ball into the space he came from for a delayed runner.',
    'Winger carrying inside at speed',
    'Whatever the block does, a pass is left open.',
    NULL, 95, 95, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wide forward (Bernardo)', 'carry diagonally and read whether the defender steps out'),
    (2, 'Far-side forward (Jesus)', 'run into the box through the gap'),
    (3, 'Deep runner (full back / 8)', 'delayed run into the space behind the carrier')
) AS v(so, role, job);

-- 83. pp.95-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Bernardo Silva', 'Fake the cross, cut back',
    'A winger who breaks into the box from the right is expected to cross to the back post. As the defenders sprint back to their goal to cover it, he shapes to cross and instead cuts the ball back into the space they vacated.',
    'Defenders collapsing towards their own goal',
    'Find an unmarked teammate at the edge of the six-yard box or penalty spot.',
    NULL, 95, 95, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wide forward (Bernardo)', 'fake the cross, then pull the ball back'),
    (2, 'Right 8 (Gundogan)', 'play him in, then follow into the cut-back zone')
) AS v(so, role, job);

-- 84. pp.96-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Raheem Sterling', 'Far-side forward arrives in the centre',
    'When the ball is on the opposite flank, the far-side forward moves off the wing into the middle of the box, between the posts, to meet the cut-back.',
    'Ball on the opposite wing heading for the byline',
    'Be the free man for the cut-back across goal.',
    NULL, 96, 96, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Far-side wide forward (Sterling)', 'leave the wing and arrive between the posts'),
    (2, 'Ball-side wide forward (Sane, Silva)', 'cut the ball back across goal')
) AS v(so, role, job);

-- 85. pp.97-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Raheem Sterling', 'Cut inside to attack at a better angle',
    'Rather than go outside his man and shoot from an acute angle, the wide forward cuts back inside at pace through a gap between defenders and enters the box diagonally into the half-space, where expected goals are higher. This often pulls a second defender across and opens space elsewhere.',
    'Wide 1v1 with a gap between defenders inside',
    'Shoot from a central angle across the keeper, or play in a teammate once a second defender commits.',
    NULL, 97, 99, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wide forward (Sterling)', 'change direction inside at speed and enter the box diagonally'),
    (2, 'Striker / far-side forward', 'stay ready for the pass once a second defender shifts')
) AS v(so, role, job);

-- 86. pp.100-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Raheem Sterling', 'Angled through ball vs a compact block',
    'In the half-space facing a compact block with no clear route into the box, the forward does not force a dribble and lose the ball. He plays a disguised, angled, weighted pass through the defensive line for a teammate''s run, and resets the ball when nothing is on.',
    'Possession in the half-space against a set compact block',
    'Create a clear shot for a teammate, or keep the ball by resetting.',
    NULL, 100, 100, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Half-space forward / 8 (Sterling, Silva, Bernardo, De Bruyne)', 'play the angled pass through the line'),
    (2, 'Runner', 'time a run through the line')
) AS v(so, role, job);

-- 87. pp.101-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Raheem Sterling', 'Lay-off to the striker and spin outside',
    'The wide forward drops just ahead of the 8 (Gundogan) to receive. He plays straight into the striker, then spins outside his marker at speed for the return pass beyond the back line, near the edge of the box.',
    'Winger receives from the 8 with a defender tight behind',
    'A one-two puts the winger behind the line.',
    NULL, 101, 101, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wide forward (Sterling)', 'set the ball to the striker and spin outside'),
    (2, 'Striker (Aguero)', 'return the ball first time beyond the line'),
    (3, 'Right 8 (Gundogan)', 'start the move with the pass into the winger')
) AS v(so, role, job);

-- 88. pp.105-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'to_attack', 'Anatomy of a Goal (v Manchester United 24.04.19)', 'Regain from a deep block, then carry and slip',
    'City drop into a compact deep block with both wide forwards inside it. A centre back intercepts. The near winger (Sane) sprints forward at once while the ball goes to the other winger (Sterling), who turns and drives centrally. As the opponent streams back, he waits until the defenders collapse past the ball, then slips the sprinting winger through.',
    'Interception from the established deep block',
    'Score within seconds while the opponent''s structure is broken.',
    NULL, 105, 105, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Kompany)', 'intercept and play forward quickly'),
    (2, 'Right wide forward (Sterling)', 'turn, drive central, pause, then release the runner'),
    (3, 'Left wide forward (Sane)', 'sprint into space as soon as the ball is won')
) AS v(so, role, job);

-- 89. pp.106-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'out_of_possession', 'Anatomy of a Goal (v Fulham 30.03.19, 15.09.18)', 'Shut near options, bait the inside pass',
    'Against a team building out from the goalkeeper, City close off the passing lanes and man-mark the receiver''s two nearest options. They leave a lane into central midfield deliberately open, so the receiver forces a pass inside, and the 8 (De Bruyne) jumps onto it.',
    'Opponent building out from the back; pass into the baited central lane',
    'A turnover high up, followed at once by a forward pass (Aguero, then Bernardo drives in; or Sane''s diagonal run) for a goal.',
    NULL, 106, 111, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front line / near pressers', 'mark the two closest outlets and cut the lanes'),
    (2, 'Right central midfielder (De Bruyne)', 'read the forced pass inside and step in to win it'),
    (3, 'Wide forward (Sane, Bernardo)', 'run diagonally behind straight after the regain'),
    (4, 'Striker (Aguero)', 'receive centrally and feed the runner')
) AS v(so, role, job);

-- 90. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'set_piece', 'Anatomy of a Goal (v Chelsea 10.02.19)', 'Quick free kick to an early angled run',
    'On a free kick in the right half-space, the taker (De Bruyne) looks up straight away while the opponent is still organising. Both wingers stand very wide and high where the defence has left them uncovered. One makes an early angled run and gets a pass between defenders into the box. He then squares the ball with the striker going near post and the other winger arriving far post.',
    'Opponent switches off while setting its defensive shape after the foul',
    'Score from one run and one pass before the defence is set.',
    NULL, 107, 107, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free-kick taker (De Bruyne)', 'take it quickly through the gap'),
    (2, 'Right wide forward (Bernardo)', 'early angled run into the corner of the box'),
    (3, 'Striker (Aguero)', 'near-post run'),
    (4, 'Left wide forward (Sterling)', 'come in from very wide to the far post')
) AS v(so, role, job);

-- 91. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Anatomy of a Goal (v Arsenal 03.02.19)', 'Overload one side, switch to the isolated winger',
    'Against a compact block, City crowd the right side and leave the left winger alone out wide. The ball is switched to him. He drives at the corner of the box, plays a quick one-two with a deeper teammate to get behind the block, then squares the ball for the striker.',
    'Block shifted towards the overloaded side',
    'A 1v1 or 2v1 on the weak side, ending in a tap-in.',
    NULL, 108, 108, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side players', 'overload the right to draw the block across'),
    (2, 'Switching player', 'play the switch to the isolated side'),
    (3, 'Weak-side wide forward (Sterling)', 'drive at the box and combine to get behind'),
    (4, 'Striker (Aguero)', 'arrive for the square ball')
) AS v(so, role, job);

-- 92. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Anatomy of a Goal (v Wolves 14.01.19)', 'Full backs and one centre back level with the 6',
    'In build-up, both full backs and one centre back line up across the pitch level with the holding midfielder, which lets City move the ball from side to side to find open channels. The full back on the ball has a clear lane to his winger, who attacks the channel between the opposing full back and centre back.',
    'Settled possession in the opponent''s half',
    'A wide base for switching play, then a forward pass into the full back/centre back channel.',
    NULL, 108, 108, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'join the line level with the 6 across the width'),
    (2, 'Holding midfielder', 'anchor the line and circulate the ball'),
    (3, 'Wide forwards', 'stay wide; attack the channel when the full back looks up'),
    (4, 'Striker (Jesus)', 'finish the cross across goal')
) AS v(so, role, job);

-- 93. pp.109-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Anatomy of a Goal (v West Ham 24.11.18)', 'Full back carries inside to isolate the defender',
    'A full back on the ball with time and a winger wide outside him carries inside into the half-space rather than going forward or outside. This leaves one defender stuck between the ball and the winger. When the defender steps in to engage, the full back slips the ball outside, and the winger drives into the box while the central 8 times a late run to meet the cross.',
    'Full back unpressed; single defender between him and the winger',
    'The defender has to choose, and either choice leaves someone free; ends in a cross to the arriving 8.',
    NULL, 109, 109, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Walker)', 'carry inside, then release outside when the defender commits'),
    (2, 'Right wide forward', 'hold width, then drive into the box'),
    (3, 'Left central midfielder (David Silva)', 'late run beyond the defender to meet the cross')
) AS v(so, role, job);

-- 94. pp.110-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-mastering-the-premier-league'), 'in_possession', 'Anatomy of a Goal (v Burnley 20.10.18, v Cardiff 22.09.18)', 'Stack the lane, then diagonal run into the box',
    'A deeper player (an advanced centre back or full back) and a higher player (an 8 or winger) occupy the same vertical lane on one side. A simple forward pass progresses the ball in that lane. Then the ball is played quickly between two defenders, or worked into the wide spaces, for a diagonal run into the box, and the receiver squares it to a striker already making his central run.',
    'Ball reaches the higher player in the half-space',
    'Break the last line and finish with a simple square ball.',
    NULL, 110, 111, 940)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep player: centre back / full back (Laporte, Walker)', 'advance and play forward into the same lane'),
    (2, 'Half-space 8 / winger (David Silva, Bernardo)', 'receive higher up and play through quickly'),
    (3, 'Wide forward (Sterling)', 'diagonal run into the box'),
    (4, 'Striker (Aguero)', 'central run in front of the defenders for the square ball')
) AS v(so, role, job);

COMMIT;
