-- 1945 📚 Coaching book patterns: Terzis, "Jose Mourinho's Real Madrid: A
-- Tactical Analysis - Defending" (SoccerTutor, 2012), Real Madrid 2011-12 in
-- the 4-2-3-1.  Every page (1-244) read; each team pattern the book describes
-- written up in OUR OWN WORDS (short paraphrase, nothing copied): moment,
-- trigger, aim, opponent shape where the book splits by it, app page numbers
-- as the citation, and who does what.  Training drills (pp.14-17), player
-- profiles, contents and adverts are left out.  Owner's personal library.
-- (James 11/26 'continue with reading the coach viewer book and putting in db')
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    subtitle    = 'A Tactical Analysis - Defending',
    team        = 'Real Madrid',
    season      = '2011-12',
    method_note = 'The author watched every Real Madrid match of 2011-12, many of them 20 or more times (over 1000 hours). A situation went in the book only once it had recurred at least 10 times; he then logged each player''s position, body shape and movement, sorted by the opponent''s formation, and drew it up in Tactics Manager diagrams.'
WHERE slug = 'terzis-mourinho-real-madrid-defending';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending');

-- 1. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'to_defend', 'Real Madrid in the Four Phases of the Game', 'Nearest safety player presses, then shut the middle',
    'Madrid lose the ball while attacking; because balance was kept during the attack, a covering player is always close to the ball.',
    'Possession lost',
    'Win it back straight away; if that fails, protect the central zone and push the ball out wide.',
    NULL, 30, 30, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest safety player (often Alonso)', 'Goes to the ball at once'),
    (2, 'Players around the ball', 'React instantly and hunt the ball'),
    (3, 'Whole team', 'If the quick regain fails, fill the centre and show play to the flank')
) AS v(so, role, job);

-- 2. pp.32-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'to_attack', 'Real Madrid in the Four Phases of the Game', 'Ronaldo left high as the counter outlet',
    'Ronaldo rarely tracks back, so when Madrid win the ball he is already high; fast runners break and Ozil plays them in. They countered even from set pieces they were defending.',
    'Ball won, including from a defended set piece',
    'Attack the space before the opponent can reorganise.',
    NULL, 32, 32, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Stays high while the team defends, ready to break'),
    (2, 'No.10 (Ozil)', 'Times the release pass in behind'),
    (3, 'Right winger (Di Maria) and CF', 'Sprint into the space behind')
) AS v(so, role, job);

-- 3. pp.35-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Drop goal-side when the ball is open',
    'The press has failed and an opposing player has the ball with time to pass forward (open ball) while the line is high.',
    'Open ball: carrier unpressured and facing forward',
    'Each defender sits goal-side of his man with a few yards head start, so a ball in behind is reached first; offside is only played when safe.',
    NULL, 35, 40, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'Goal-side and inside the winger; first to a ball into the channel; closes at once if the winger gets it wide'),
    (2, 'Centre back on the striker (Pepe)', 'Tight and goal-side; wins any ball in behind; engages fast if it goes wide'),
    (3, 'Other defenders', 'Get into the box early so a delayed cross is harmless'),
    (4, 'Goalkeeper (Casillas)', 'Comes off his line towards the space in front of goal')
) AS v(so, role, job);

-- 4. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Aggressive zonal marking of forwards',
    'Standing rule from 2011-12: every defender marks the forward in his zone tightly, even when the forward drops deep, accepting 1v1 duels.',
    'An opponent enters a defenders zone',
    'Forwards get no time to turn, so the opponent cannot push extra men up; full backs marking tight are already high to attack once the ball is won. Needs quick, strong duel-winners because the gaps behind are wider.',
    NULL, 41, 41, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Mark direct opponents closely, accept equal numbers'),
    (2, 'Defensive midfielders and wingers', 'Support so the gaps behind are covered'),
    (3, 'Full backs', 'Go forward from the tight-marking spot when the ball is won')
) AS v(so, role, job);

-- 5. pp.42-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Flat compact line on a closed ball',
    'A defensive midfielder is on the opposing central midfielder (closed ball). The back four stand flat with short gaps, their width set by where the opposing wingers are.',
    'Closed ball: carrier pressed and unable to play forward',
    'A short, flat line; the full back facing a wide winger widens enough to close or intercept, and steps out of the line if his winger drops deep while the other three hold.',
    NULL, 42, 43, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.6 (Alonso)', 'Pressures the ball carrier'),
    (2, 'Right back (Arbeloa)', 'Level with the line but wider against a wide winger; steps higher if the winger drops'),
    (3, 'Pepe, Ramos, Marcelo', 'Flat line, short distances')
) AS v(so, role, job);

-- 6. pp.44-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Line breaks to goal-side spots when the ball turns open',
    'The pressed midfielder escapes by finding a free team-mate, so the ball goes from closed to open.',
    'Pass reaches an unpressured player',
    'Each defender takes a goal-side safety spot on his man; the line is no longer flat but every ball into the danger areas is covered.',
    NULL, 44, 45, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'Drop a few yards so their wingers cannot be found in behind'),
    (2, 'Centre back on the striker (Pepe)', 'Follows him if he comes short'),
    (3, 'Other centre back (Ramos)', 'Drops behind Pepe to cover'),
    (4, 'Back four', 'All retreat goal-side when the forwards run in behind')
) AS v(so, role, job);

-- 7. pp.46-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Full back tucks in behind a stepping centre back',
    'A centre back follows the striker who drops to receive, leaving a hole in the line; sometimes a second attacker runs into it, or striker and winger drop together.',
    'Centre back leaves the line to follow a dropping forward',
    'The weak-side full back (or both) gives up tight marking and narrows to fill or cover the gap so the line stays balanced.',
    NULL, 46, 47, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Pepe or Ramos)', 'Follows the dropping striker'),
    (2, 'Weak-side full back (Arbeloa)', 'Leaves his winger and moves inside to cover'),
    (3, 'Other full back (Marcelo)', 'Fills the gap when a runner attacks the space behind his centre back'),
    (4, 'Remaining centre back', 'Drops in behind when two defenders have followed men up')
) AS v(so, role, job);

-- 8. pp.48-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Retreat while open, step up once closed down',
    'An opposing central midfielder carries the ball forward unmarked while a Madrid midfielder races to close him.',
    'Free carrier advancing; then the midfielder reaches him and shows him to the touchline',
    'While the ball is open the back four backpedal to a safe distance; when the carrier is engaged they stop, and once he cannot play forward they step up together, regaining compactness and catching forwards offside.',
    NULL, 48, 49, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.6 (Alonso)', 'Closes the carrier and steers him towards the touchline'),
    (2, 'Back four', 'Drop while open, freeze on contact, step up as one when closed'),
    (3, 'Centre backs (Ramos, Pepe)', 'Track the strikers diagonal run and block the vertical pass to him')
) AS v(so, role, job);

-- 9. pp.50-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Full back drops below the line against a runner',
    'Open ball with a midfielder carrying forward and the opposing winger ready to run behind the full back.',
    'Uncovered ball plus a winger set to run in behind',
    'The full back drops a few yards deeper than his centre back to keep his head start; when the ball is closed and played back or square the line stops and steps up, leaving runners offside.',
    NULL, 50, 51, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'Drops deeper than the line to cover the run; tracks the winger if he comes inside'),
    (2, 'Left back (Marcelo)', 'Tracks his winger inside'),
    (3, 'Centre back (Pepe)', 'Stays tight on the striker'),
    (4, 'Other centre back (Ramos)', 'Drops a few yards to cover Pepe'),
    (5, 'No.6 (Alonso)', 'Closes the carrier and forces him backwards, the cue to step up')
) AS v(so, role, job);

-- 10. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Weak-side full back narrows near goal',
    'Ball on the far flank. High up the pitch the weak-side full back can stay tight on his winger, but as the attack nears the box he moves in beside his centre back.',
    'Attack approaches Madrids penalty area',
    'Distances shrink so defenders can cover each other; inside the box they mark man to man.',
    NULL, 52, 52, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side right back (Arbeloa)', 'Tight on his winger in midfield; near goal moves next to Pepe'),
    (2, 'Back four', 'Close up as the ball nears goal; man marking in the box')
) AS v(so, role, job);

-- 11. pp.53-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Midfielder beaten: line drops and narrows',
    'An opposing midfielder dribbles past the Madrid midfielder and runs at the defence with nobody on him.',
    'Defensive midfielder beaten in a duel',
    'The defenders retreat to buy time for a midfielder to recover and both full backs narrow to rebuild the line; if nobody can recover, a centre back steps out to meet the carrier before he reaches shooting range.',
    NULL, 53, 54, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Other defensive midfielder (Khedira)', 'Races back to close the carrier'),
    (2, 'Full backs', 'Leave their wingers and squeeze inside'),
    (3, 'Back four', 'Retreat together to restore cohesion'),
    (4, 'Centre back (Ramos)', 'Steps out to contest the carrier before he can shoot')
) AS v(so, role, job);

-- 12. pp.54-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Far full back tucks in when a centre back shifts wide',
    'The left centre back has to shift right out towards the touchline to engage play there.',
    'Big lateral shift of a centre back towards the sideline',
    'The other centre back slides across and the far-side full back leaves his man and moves inside so the line stays whole.',
    NULL, 54, 54, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Ramos)', 'Shifts wide to the ball'),
    (2, 'Right centre back (Pepe)', 'Slides across'),
    (3, 'Weak-side right back (Arbeloa)', 'Leaves his winger and moves central')
) AS v(so, role, job);

-- 13. pp.55-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Weak-side full back: mark the man or the space',
    'The opposing right back has the ball near Madrids box on their left; Ronaldo presses him and Marcelo marks the winger. Where does the far full back go?',
    'Ball on the far flank near Madrids box',
    'By default he tucks in beside his centre back and leaves his winger, protecting the middle; he switches to tight marking only when a switch could find that winger free in front of the defence. Two-v-two outside the box is accepted because the centre backs win duels.',
    NULL, 55, 58, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Pressures the full back on the ball'),
    (2, 'Ball-side left back (Marcelo)', 'Marks the near winger'),
    (3, 'Centre backs (Pepe, Ramos)', 'Cover Marcelo; take their 2v2 duels outside the box'),
    (4, 'Weak-side right back (Arbeloa)', 'Stays near Pepe; moves tight on his winger when a switch through midfield is on')
) AS v(so, role, job);

-- 14. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Flat line when the full back presses at the box edge',
    'The opposing winger has the ball beside the penalty area; the full back presses him and the other three stay level with him rather than dropping deeper.',
    'Winger in possession at the side of the box',
    'If the winger cuts it back to the edge of the box, the nearest centre back is close enough to jump out and block the shot.',
    NULL, 59, 59, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'Pressures the winger'),
    (2, 'Pepe, Ramos, Marcelo', 'Stay flat and compact level with Arbeloa'),
    (3, 'Nearest centre back (Pepe)', 'Jumps onto the cut-back receiver to block')
) AS v(so, role, job);

-- 15. pp.60-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Alonso closes the full back Ronaldo leaves',
    'Ronaldo does not track the opposing right back, who carries the ball up Madrids left while Marcelo is busy with the winger.',
    'Opposing right back advancing unmarked on Madrids left',
    'Marcelo stays with his winger so there is no 2v1; Alonso becomes first defender while the line retreats to buy him time, then steps up once the carrier is closed and turns to the touchline.',
    NULL, 60, 62, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Does not track (the reason for the pattern)'),
    (2, 'Left DM (Alonso)', 'Slides wide as first defender on the advancing full back'),
    (3, 'Left back (Marcelo)', 'Stays with the winger, does not step out'),
    (4, 'Arbeloa, Pepe, Ramos', 'Retreat while open, stop when Alonso engages, step up when the carrier turns'),
    (5, 'Right DM (Khedira)', 'Drifts to the ball side for balance')
) AS v(so, role, job);

-- 16. pp.63-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Alonso drops into the centre-back gap (left side)',
    'Opposing winger has the ball wide on Madrids left near the box; Marcelo presses him and the striker drifts to the touchline, pulling Ramos out with him.',
    'Left centre back dragged towards the sideline',
    'Alonso drops into the empty centre-back slot, Marcelo slides in beside Ramos and Khedira guards the edge of the box, so the back four stays whole with an extra man.',
    NULL, 63, 64, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'Presses the winger, then supports Ramos'),
    (2, 'Left DM (Alonso)', 'Supports first, then drops into central defence'),
    (3, 'Left centre back (Ramos)', 'Follows the striker towards the sideline'),
    (4, 'Right DM (Khedira)', 'Holds just outside the box'),
    (5, 'Pepe, Arbeloa', 'Hold the box')
) AS v(so, role, job);

-- 17. pp.65-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Alonso fills the gap (right side)',
    'Mirror case on Madrids right: Arbeloa engages the winger with Khedira doubling, and Pepe follows a forward out to the touchline, opening the middle.',
    'Right centre back pulled wide',
    'Standing rule: whenever the gap between the centre backs grows too big, Alonso drops between them; Arbeloa supports Pepe and Khedira steps out of the box.',
    NULL, 65, 65, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'Contests the carrier, then supports Pepe'),
    (2, 'Right DM (Khedira)', 'Doubles, then holds outside the box'),
    (3, 'Right centre back (Pepe)', 'Follows his man wide'),
    (4, 'Left DM (Alonso)', 'Drops between the centre backs'),
    (5, 'Ramos, Marcelo', 'Shift across in the box')
) AS v(so, role, job);

-- 18. pp.66-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Di Maria tracks so Arbeloa can jump the winger',
    'The opposing left winger drops deep to receive on Madrids right while their left back overlaps.',
    'Winger comes short and the full back sets off forward',
    'With Di Maria tracking the overlap, Arbeloa follows the winger high and doubles him with Khedira so he cannot turn; if Di Maria is caught out, Arbeloa switches to the overlap and Khedira and Di Maria take the winger.',
    NULL, 66, 70, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'Tracks the overlapping left back, or doubles the winger after a swap'),
    (2, 'Right back (Arbeloa)', 'Steps out hard on the dropping winger; drops onto the overlap if Di Maria cannot track'),
    (3, 'Right DM (Khedira)', 'Doubles the winger from inside or takes him over'),
    (4, 'Centre backs and Marcelo', 'Hold the line')
) AS v(so, role, job);

-- 19. pp.70-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Winger fails to track: full back holds back',
    'Same picture but Di Maria does not follow the overlapping left back, so Arbeloa has to abandon the winger, who is left free to receive and turn.',
    'Winger not tracking the overlapping full back',
    'Damage limitation: Khedira closes the free carrier, the centre backs drop to cut the strikers diagonal run and the far full back goes goal-side in the danger area.',
    NULL, 70, 71, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'Out of position, recovering late'),
    (2, 'Right back (Arbeloa)', 'Drops off the winger to cover the overlap'),
    (3, 'Right DM (Khedira)', 'Closes the free ball carrier'),
    (4, 'Centre backs (Pepe, Ramos)', 'Drop to block the strikers diagonal run'),
    (5, 'Left back (Marcelo)', 'Goes goal-side of his winger')
) AS v(so, role, job);

-- 20. pp.72-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Marcelo hands the winger to Alonso and takes the overlap',
    'Ronaldo screens the pass from the opposing centre back to their right back, leaving the vertical pass open; their right winger drops to receive and the right back overlaps into the space. Seen often.',
    'Winger drops deep while the opposing right back pushes on',
    'Marcelo follows the winger briefly, then passes him to Alonso and picks up the overlapping full back, so nobody is free in the final third; Ronaldo can drop back to double and Ozil screens the inside switch.',
    NULL, 72, 73, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Screens the centre back to full back pass; then tracks back to double'),
    (2, 'Left back (Marcelo)', 'Tracks the winger, then releases him and follows the overlap'),
    (3, 'Left DM (Alonso)', 'Takes over the dropping winger and presses him'),
    (4, 'No.10 (Ozil)', 'Blocks the pass inside to the weak side')
) AS v(so, role, job);

-- 21. pp.74-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Covering the overlap: Ramos or Alonso',
    'Marcelo follows his winger into midfield (aggressive zonal marking) and the ball is played on to the overlapping opposing right back.',
    'Winger drops deep, then the ball goes to the overlap',
    'Whoever is better placed covers the flank: Ramos slides out to the touchline with Alonso dropping beside the centre backs, or Alonso goes wide himself while Ramos holds the middle; if the full back has time the line drops off and crowds the ball. The left side works only as a Marcelo-Ramos-Alonso unit.',
    NULL, 74, 76, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'Follows the winger, then shifts across to double the full back'),
    (2, 'Left centre back (Ramos)', 'Slides wide to contest the full back when he is the closer man'),
    (3, 'Left DM (Alonso)', 'Drops into the gap beside the centre backs, or is first defender on the full back himself'),
    (4, 'Ronaldo, Ozil', 'Drop back to add numbers near the ball')
) AS v(so, role, job);

-- 22. pp.77-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Covering for Ronaldo: Alonso marks the winger inside',
    'Ronaldo does not track; the opposing winger drifts inside to free the flank and their No.10 drops, receives and feeds the right back down the line.',
    'Winger moves inside, then the ball goes to the full back',
    'No 2v1 on Marcelo and no switch through midfield.',
    NULL, 77, 78, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'Hands the winger to Alonso, watches and then presses the full back'),
    (2, 'Left DM (Alonso)', 'Drops to mark the winger'),
    (3, 'No.10 (Ozil)', 'Drops onto their No.10 so play cannot be switched'),
    (4, 'Left winger (Ronaldo)', 'No defensive part')
) AS v(so, role, job);

-- 23. pp.79-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Wingers goal-side of the full backs at the restart',
    'The opposing keeper has the ball; each Madrid winger stands between his full back and the goal, seeing ball and man. Used against good build-up sides.',
    'Opposing goal kick or keeper in possession',
    'The team stays balanced, the defensive midfielders are free to mark their own men, and a centre back on the ball is pushed to pass wide.',
    NULL, 79, 80, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'Goal-side and close to the full back; Di Maria sits a little more central to block the vertical pass'),
    (2, 'Defensive midfielders', 'Mark their direct opponents'),
    (3, 'CF (Benzema) and No.10 (Ozil)', 'Share pressing the two centre backs')
) AS v(so, role, job);

-- 24. pp.81-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Winger in a balanced spot between centre back and full back',
    'The winger stands between the opposing centre back and full back so he can press one and still cover the other. Used when their full backs push high, or to press very high on weak build-up sides.',
    'Pass reaches the centre back',
    'The winger presses at the moment the centre back cannot fully turn, so the pass to the high full back is gone; on a long ball over him he races back. The same-side midfielder must also play balanced. Madrid were far steadier on the right (Di Maria) than the left (Ronaldo).',
    NULL, 81, 82, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'Press the centre back, sometimes with the CF; recover on a long ball to the full back'),
    (2, 'Same-side defensive midfielder', 'Takes a balanced position too'),
    (3, 'Left DM (Alonso)', 'Always covering, so the right DM is the one who can join attacks')
) AS v(so, role, job);

-- 25. pp.83-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Mixed shape: one winger goal-side, one balanced',
    'At the opposing restart one winger is goal-side and the other balanced.',
    'Opposing keeper on the ball',
    'Stay balanced: the midfielder behind the goal-side winger marks his man, the one behind the balanced winger plays balanced too, and the No.10 marks or holds depending on which way the ball has been forced.',
    NULL, 83, 84, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'DM behind the goal-side winger', 'Marks his direct opponent'),
    (2, 'DM behind the balanced winger', 'Stays balanced or the team tips over'),
    (3, 'No.10 (Ozil)', 'Holds balanced against a 4-2-3-1; marks the midfielder on the forced side against a 4-3-3')
) AS v(so, role, job);

-- 26. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Force Barcelonas build-up onto their weaker side',
    'Against Barcelona building from the keeper, Madrid steer the ball to Barcas left (Puyol, Abidal), away from the better passers, and go 1v1 in every zone.',
    'Barcelona building up from the goalkeeper',
    'The best passers never get the ball; the weakest passer is deliberately left time.',
    NULL, 85, 85, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'Covers two men, the left centre back and left back'),
    (2, 'Left DM (Alonso)', 'Follows Xavi everywhere, even near their box'),
    (3, 'Left winger (Ronaldo)', 'Stays goal-side of Dani Alves'),
    (4, 'Right DM (Khedira)', 'Marks Iniesta; steps out to the left back if the ball gets behind Di Maria'),
    (5, 'CF (Benzema)', 'Screens the strong side')
) AS v(so, role, job);

-- 27. pp.86-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Benzema and Ozil take turns pressing the centre back',
    'With the wingers goal-side, the keeper passes to a centre back. If Benzema is near he presses and Ozil slides beside him; if not, Ozil presses and Benzema drops onto the nearest midfielder.',
    'Keepers pass to a centre back',
    'A strong side with at least equal numbers near the ball and the ball pushed to the touchline.',
    NULL, 86, 88, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Presses the centre back, or recovers onto the nearest midfielder'),
    (2, 'No.10 (Ozil)', 'Slides to the strong side, or presses the centre back himself'),
    (3, 'Ball-side winger', 'Blocks the vertical pass'),
    (4, 'Alonso, Ronaldo', 'Shift across')
) AS v(so, role, job);

-- 28. pp.89-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Press the goalkeeper at an angle to choose the side',
    'The opposing keeper has the ball.',
    'Keeper holding or bringing the ball out',
    'The keeper is steered to one centre back, who is pressed while the nearest midfielder is marked.',
    NULL, 89, 90, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Curves his run to force the keeper one way, then recovers onto the holding midfielder'),
    (2, 'No.10 (Ozil)', 'Moves across blocking the vertical ball, then contests the centre back'),
    (3, 'Khedira, Alonso, Ronaldo', 'Shift towards the ball')
) AS v(so, role, job);

-- 29. pp.91-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Winger presses the centre back, CF cuts the back pass',
    'Keeper passes to the left centre back with Di Maria in a balanced spot.',
    'Pass to the centre back',
    'The centre back has neither the back pass nor a pass into midfield.',
    NULL, 91, 91, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'First defender on the centre back'),
    (2, 'CF (Benzema)', 'Blocks the pass back to the keeper, ready to double the midfielder'),
    (3, 'No.10 (Ozil)', 'Marks the nearest midfielder tightly'),
    (4, 'Right DM (Khedira)', 'Covers both that midfielder and the full back')
) AS v(so, role, job);

-- 30. pp.92-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Strong-side shift; Alonso jumps his man',
    'Ronaldo is goal-side of the opposing right back and the ball reaches their right centre back; Benzema presses and shows him one way.',
    'Benzemas press on the centre back',
    'The whole team shifts to the strong side and the midfielder who comes short cannot turn; Alonso can go high only because Ronaldo guards the flank, and if Ronaldo started balanced he must drop a few yards when Alonso jumps so the full back is never free.',
    NULL, 92, 95, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Presses and sets the side'),
    (2, 'Left DM (Alonso)', 'Follows his man high and stops him turning'),
    (3, 'No.10 (Ozil)', 'Stays with the holding midfielder'),
    (4, 'Right DM (Khedira)', 'Moves central to balance'),
    (5, 'Right winger (Di Maria)', 'Tucks in for compactness'),
    (6, 'Left winger (Ronaldo)', 'Goal-side of the full back; drops off to block the pass to him if Alonso leaves from a balanced start')
) AS v(so, role, job);

-- 31. pp.96-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Alonso hands his man to Ozil and keeps the flank',
    'The other answer to the same high press: when a midfielder drops to receive, Alonso does not chase him but passes him to Ozil and stays near the full back.',
    'Benzema or Ronaldo presses the centre back and a midfielder comes short',
    'The flank stays covered and the incoming midfielder can be triple-marked.',
    NULL, 96, 100, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left DM (Alonso)', 'Stays near the opposing right back, covering him'),
    (2, 'No.10 (Ozil)', 'Shifts to the strong side and takes the dropping midfielder'),
    (3, 'Left winger (Ronaldo)', 'Free to stay balanced or press, knowing Alonso covers'),
    (4, 'Ozil, Ronaldo, Benzema', 'Triple-mark the midfielder if he receives'),
    (5, 'Right DM (Khedira)', 'Balances in midfield')
) AS v(so, role, job);

-- 32. pp.97-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Ronaldo presses the centre back, Alonso marks from outside',
    'Ronaldo, from a balanced start, presses the centre back himself, leaving the full back unmarked.',
    'Pass to the right centre back',
    'Alonso marks the inside midfielder from the outside so the line to the free full back is blocked and Ozil doubles from inside; a risky move by the books reading. Rule: once the first defender has closed the ball to one side, balanced players switch to goal-side spots and mark hard.',
    NULL, 97, 100, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'First defender on the centre back'),
    (2, 'Left DM (Alonso)', 'Jumps onto the midfielder from the outside'),
    (3, 'No.10 (Ozil)', 'Marks the same man from the inside for a double'),
    (4, 'CF (Benzema)', 'Balanced between keeper and holding midfielder'),
    (5, 'Right DM (Khedira)', 'Balances in midfield')
) AS v(so, role, job);

-- 33. pp.101-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase', 'Right-side press that ends on the touchline',
    'Di Maria and Khedira start balanced; the keeper passes to the left centre back, who finds a midfielder, who plays out to the left back.',
    'Keepers pass to the centre back',
    'A collective shift right shuts every inside pass and traps the ball against the touchline; play is always pushed wide because it is easier to outnumber there and the switch is denied.',
    NULL, 101, 104, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'Presses the centre back fast, then recovers to block the return or double the full back'),
    (2, 'Right DM (Khedira)', 'Closes the full back when he receives'),
    (3, 'CF (Benzema)', 'Marks the centre back to cut the return pass'),
    (4, 'No.10 (Ozil)', 'Takes over the midfielder'),
    (5, 'Alonso, Ronaldo', 'Shift to the strong side and tuck in')
) AS v(so, role, job);

-- 34. pp.106-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-4-2', 'Pin the ball near the touchline, deny the switch',
    'Against a 4-4-2 Madrid have three v two in midfield with Alonso spare. The keeper passes to the right centre back, who then plays out to his right back.',
    'Right centre back receives from the keeper',
    'The centre back can only go wide; the team slides across, closes the space and often wins it on the flank.',
    '4-4-2', 106, 108, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Presses the centre back, cutting the pass to the other centre back and keeper; then blocks the return pass'),
    (2, 'No.10 (Ozil)', 'Stays by the holding midfielder to stop the switch, ready to double the winger'),
    (3, 'Left DM (Alonso)', 'Spare man; blocks the vertical pass'),
    (4, 'Left winger (Ronaldo)', 'First defender when the full back receives'),
    (5, 'Left back (Marcelo)', 'Marks the winger tightly'),
    (6, 'Khedira, Di Maria', 'Balance and tuck in')
) AS v(so, role, job);

-- 35. pp.109-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-4-2', 'Long slide to the strong side',
    'Ozil is away from the ball and Ronaldo is goal-side, so Alonso steps onto the near central midfielder; the ball travels centre back, full back, winger.',
    'Keeper to centre back, then out to the full back',
    'Madrid outnumber the ball area while the back line hands men on and keeps cover; the long sideways shift of the far centre back is the risk.',
    '4-4-2', 109, 111, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left DM (Alonso)', 'Closes the near midfielder; leaves him once Ronaldos body shape blocks that pass'),
    (2, 'Left winger (Ronaldo)', 'Presses the full back, then tracks back to double the winger'),
    (3, 'Right DM (Khedira)', 'Shifts far left to balance, then takes the second striker'),
    (4, 'Left back (Marcelo)', 'Tight on the winger, then presses him'),
    (5, 'Left centre back (Ramos)', 'Follows the second striker, hands him to Khedira, then drops to cover Marcelo'),
    (6, 'Pepe, Arbeloa', 'Slide across to cover')
) AS v(so, role, job);

-- 36. pp.112-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-4-2', 'Swarm the midfielder who receives facing his own goal',
    'The centre back plays into a central midfielder who has his back to goal.',
    'Midfielder receives back to goal',
    'He is pressed before he can turn and every option is shut, so the ball is won. When their full backs are high and centre backs split, the wingers sit between them and the press waits for the first pass.',
    '4-4-2', 112, 113, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left DM (Alonso)', 'Presses the receiver before he turns'),
    (2, 'Ozil, Ronaldo, Benzema', 'Close all of his passing options')
) AS v(so, role, job);

-- 37. pp.114-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-4-2', 'CF sets the side, winger shows inside, three close the midfielder',
    'Keeper passes to the right centre back.',
    'Pass to the centre back, then his pass into the central midfielder',
    'The centre back is left one option, so the midfielders move early and outnumber the ball.',
    '4-4-2', 114, 115, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'First defender on the centre back, making the strong side; recovers to triple-mark'),
    (2, 'Left winger (Ronaldo)', 'Blocks the pass to the full back and forces play inside, then presses the midfielder'),
    (3, 'No.10 (Ozil)', 'Near the midfielder, then presses him'),
    (4, 'Left DM (Alonso)', 'Blocks the vertical pass, then the pass to the full back'),
    (5, 'Di Maria', 'Tucks in to cover both a midfielder and the far full back')
) AS v(so, role, job);

-- 38. pp.116-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-4-2', 'Body shape closes the passing lanes',
    'Benzema presses the keeper directly at an angle; the ball goes to the right centre back and into the central midfielder.',
    'Keeper in possession',
    'Every pass on offer leads into a trap, ending with the midfielder triple-marked.',
    '4-4-2', 116, 117, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Body shape cuts the keepers pass to the other centre back; then blocks the return to the keeper'),
    (2, 'No.10 (Ozil)', 'Focuses on the nearest midfielder, leaves the far one'),
    (3, 'Left winger (Ronaldo)', 'Presses the centre back with his body shutting off the high full back'),
    (4, 'Left DM (Alonso)', 'Moves wide to cover the full back and block the vertical pass'),
    (5, 'Ozil, Ronaldo, Benzema', 'Triple-mark the midfielder')
) AS v(so, role, job);

-- 39. pp.118-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-4-2', 'Both wingers balanced: press without a strong side',
    'Ozil stands near the far midfielder rather than between the two, so the near midfielder drops off free; the book calls this the hard case.',
    'Keeper to centre back, midfielder drops to get free',
    'When the press cannot win the ball, at least avoid a 2v1 on Marcelo and keep cover behind.',
    '4-4-2', 118, 120, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Presses the centre back'),
    (2, 'Left DM (Alonso)', 'Does not jump the midfielder; stays covering the full back, then takes the winger once Marcelo steps out'),
    (3, 'Left back (Marcelo)', 'Follows the winger while watching the full back, then contests the full back'),
    (4, 'Left centre back (Ramos)', 'Tight on the second striker, then drops back into line to cover Marcelo'),
    (5, 'Khedira, Pepe, Arbeloa', 'Shift, cover and balance')
) AS v(so, role, job);

-- 40. pp.121-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-4-2', 'Alonso jumps high and the defence marks tight',
    'The alternative answer: Alonso steps up onto the near midfielder because Ozil is too far away.',
    'Keeper to centre back to midfielder, who turns and finds the second striker',
    'Even if the midfielder turns, the free full back and second striker get no time; tight marking behind makes the jump safe.',
    '4-4-2', 121, 122, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Presses the centre back; with Alonso stops the full back receiving'),
    (2, 'Left DM (Alonso)', 'Marks the midfielder with his body blocking the full back; recovers when the ball goes forward'),
    (3, 'Left centre back (Ramos)', 'Marks the second striker aggressively, then presses him with Khedira'),
    (4, 'Right DM (Khedira)', 'Blocks the vertical pass or doubles'),
    (5, 'Arbeloa, Di Maria', 'Tuck in and shift across')
) AS v(so, role, job);

-- 41. pp.123-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-4-2', 'Build-up down the right: press fails, recover and trap the winger',
    'Benzema presses the keeper, who plays to the left centre back; he half-turns and escapes, the ball goes to the left back and their winger runs forward.',
    'Keepers pass to the centre back; then the full back has time and the winger runs',
    'First aim is to stop the centre back turning; when that fails the team rebalances and forces the ball wide, where the full back and then the winger are doubled and left without a pass.',
    '4-4-2', 123, 126, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Presses the keeper and sets the strong side'),
    (2, 'Right winger (Di Maria)', 'Presses the centre back fast, then drops back to double the full back'),
    (3, 'Right DM (Khedira)', 'Balanced between midfielder and full back; closes the full back, then doubles the winger'),
    (4, 'No.10 (Ozil)', 'Tight on the midfielder, blocks the pass back inside'),
    (5, 'Right back (Arbeloa)', 'Follows the winger goal-side, then presses him'),
    (6, 'Right centre back (Pepe)', 'Marks the striker, then drops to cover Arbeloa and hands the striker to Alonso'),
    (7, 'Left DM (Alonso)', 'Big shift right to take the striker')
) AS v(so, role, job);

-- 42. pp.127-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-4-2', 'Keeper plays straight to the full back',
    'The keeper passes long and direct to the opposing left back.',
    'Keepers pass to the full back',
    'The team shifts to the strong side and doubles the ball while the back line stays goal-side of everyone.',
    '4-4-2', 127, 127, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right DM (Khedira)', 'First defender on the full back'),
    (2, 'Right winger (Di Maria)', 'Doubles'),
    (3, 'Right back (Arbeloa)', 'Follows the winger, then hands him to Alonso'),
    (4, 'Left DM (Alonso)', 'Takes the winger'),
    (5, 'Right centre back (Pepe)', 'Follows the strikers run goal-side'),
    (6, 'Ramos, Marcelo', 'Drop and mark goal-side')
) AS v(so, role, job);

-- 43. pp.128-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-4-2', 'Triple-mark the midfielder near their box',
    'Ozil is away from the strong side and Khedira is balanced; the left centre back plays into a midfielder with his back to goal.',
    'Centre backs pass into the back-to-goal midfielder',
    'The receiver is swarmed; Madrid accept leaving others free because they expect to win the ball.',
    '4-4-2', 128, 129, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'Contests the centre back with Benzema, then drops to make the triple mark'),
    (2, 'Right DM (Khedira)', 'Steps onto the midfielder and closes the pass to the full back'),
    (3, 'No.10 (Ozil)', 'Moves to the strong side and doubles from inside'),
    (4, 'Left DM (Alonso)', 'Balance')
) AS v(so, role, job);

-- 44. pp.131-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-2-3-1', 'Winger position decides how midfield marks',
    'Midfield is three v three. Whether the midfielders mark tight or hold zones depends on where Madrids wingers stand.',
    'Wingers goal-side of the full backs, or balanced between centre back and full back',
    'Goal-side wingers free the midfield three to mark tight and overload near the touchline; balanced wingers force the midfielders to guard zones because they must also watch the full backs.',
    '4-2-3-1', 131, 132, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (Ronaldo, Di Maria)', 'Goal-side to free the midfield, or balanced'),
    (2, 'Alonso, Khedira, Ozil', 'Tight when the wingers are goal-side; zonal when balanced; always tight on anyone who comes near the ball'),
    (3, 'Left DM (Alonso)', 'Follows the No.10 towards the ball, then doubles the winger and hands the No.10 to Ozil'),
    (4, 'Ball-side centre back (Ramos)', 'Tight on the striker'),
    (5, 'Far centre back (Pepe)', 'Drops to cover Marcelo')
) AS v(so, role, job);

-- 45. pp.133-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-2-3-1', 'Centre back carries it: overload and step up for offside',
    'Wingers goal-side, midfielders tight; the keeper passes to the right centre back who dribbles forward.',
    'Keepers pass, then the centre back carrying',
    'Madrid outnumber near the ball, any receiver is marked tight or doubled, and the line steps up to leave the striker offside.',
    '4-2-3-1', 133, 134, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Presses the carrier from behind'),
    (2, 'No.10 (Ozil)', 'Leaves his man to press the centre back because numbers are already up; then drops to add a body'),
    (3, 'Left DM (Alonso)', 'Tracks the No.10, then doubles the winger'),
    (4, 'Left back (Marcelo)', 'Marks the dropping winger hard and stops him turning'),
    (5, 'Centre backs (Ramos, Pepe)', 'Goal-side of the striker; step up together when the winger receives'),
    (6, 'Left winger (Ronaldo)', 'Follows the overlap and becomes the third man on the ball')
) AS v(so, role, job);

-- 46. pp.135-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-2-3-1', 'Balanced press: Alonso steps up, Khedira slides across',
    'Balanced shape, keepers pass to the right centre back; in a variant Ozil presses first and Benzema drops onto the holding midfielder.',
    'Pass to the centre back; the next pass into midfield triggers the double or triple',
    'One midfielder steps into the passing lane and the other restores balance, so a short pass is doubled or tripled; Khediras long slide is what lets Alonso go.',
    '4-2-3-1', 135, 138, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First presser (Benzema or Ozil)', 'Presses the centre back at once'),
    (2, 'No.10 (Ozil)', 'Shadows the likely receiver, then doubles him with Ronaldo'),
    (3, 'Left DM (Alonso)', 'Leaves the No.10 and moves up and left to cut the vertical pass; cuts the switch if the full back gets it'),
    (4, 'Right DM (Khedira)', 'Slides far across, takes over the No.10, keeps midfield balanced'),
    (5, 'Right winger (Di Maria)', 'Tucks in near the far midfielder'),
    (6, 'Ramos, Marcelo, Pepe', 'Follow their men closely; Pepe covers')
) AS v(so, role, job);

-- 47. pp.139-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-2-3-1', 'Balanced wingers: each midfielder covers two receivers',
    'Wingers between centre back and full back can press a pass to either centre back; with the ball on Madrids left each midfielder stands to cover two opponents.',
    'Keepers pass to a centre back; or a long ball over the press to the full back',
    'The receiver is pressed at once with short options covered; a long ball to the full back meets a midfielder already in place, and the line steps up once he is closed.',
    '4-2-3-1', 139, 142, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left DM (Alonso)', 'Wide left, covering the No.10 and full back; closes the full back if he receives'),
    (2, 'No.10 (Ozil)', 'Covers both holding midfielders, then marks the near one tight'),
    (3, 'Right DM (Khedira)', 'Central between the far midfielder and No.10, slides to the ball'),
    (4, 'Left winger (Ronaldo)', 'Presses the centre back; drops to double on a long ball'),
    (5, 'CF (Benzema)', 'Cuts the back pass while screening the holding midfielder; joins the triple mark'),
    (6, 'Back line', 'Marcelo covers Alonso; Ramos watches the striker; they stop dropping and step up once the full back is closed')
) AS v(so, role, job);

-- 48. pp.143-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-2-3-1', 'Centre back carries the ball out of defence',
    'The right centre back has space after the keepers pass and dribbles into midfield; Benzema started badly placed.',
    'Centre back carrying into midfield',
    'Two players close him with everything around blocked; his only outlet is the striker with his back to goal, who is triple-marked.',
    '4-2-3-1', 143, 144, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 (Ozil) and left winger (Ronaldo)', 'Close the carrier together'),
    (2, 'CF (Benzema)', 'Recovers towards the ball and blocks the pass back to the holding midfielder'),
    (3, 'Left DM (Alonso)', 'Cuts the vertical pass, then triple-marks the striker with Khedira and Ramos'),
    (4, 'Left centre back (Ramos)', 'Aggressive on the striker'),
    (5, 'Pepe, Marcelo, Arbeloa', 'Cover and balance the line')
) AS v(so, role, job);

-- 49. pp.145-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-2-3-1', 'Full back free on the halfway line',
    'Ball on Madrids right; a midfielder lays it off first time to the advanced left back who has time.',
    'Pass to the advanced full back',
    'He is pressed from the side with extra bodies around the ball; the striker is shadowed goal-side and then left offside when the line steps up.',
    '4-2-3-1', 145, 146, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'Sprints back from a balanced spot and presses the full back from the side'),
    (2, 'Right DM (Khedira)', 'Slides to the touchline'),
    (3, 'Right back (Arbeloa)', 'Tracks his man, then leaves him to close the ball'),
    (4, 'Centre backs (Pepe, Ramos)', 'Goal-side of the striker; step up together on the closed ball'),
    (5, 'Left DM (Alonso)', 'Tight on the No.10 coming towards the ball'),
    (6, 'Left back (Marcelo)', 'Holds rather than tucking in, numbers at the back are already enough')
) AS v(so, role, job);

-- 50. pp.147-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-2-3-1', 'Opponent circulates across the back via the keeper',
    'Di Maria presses the left centre back; the ball goes back to the keeper and out to the other centre back, so Madrid must shift across the pitch.',
    'Back pass to the keeper, then the switch to the other centre back',
    'The team moves across as one block; during the switch nobody can mark aggressively so wingers hold balanced spots, then the receiver is pressed and the far side trapped.',
    '4-2-3-1', 147, 151, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Di Maria, Benzema', 'Di Maria presses the first centre back; Benzema presses the keeper and the receiving centre back'),
    (2, 'Left DM (Alonso)', 'Stays in cover if Ronaldo is high; steps onto the midfielder if Ronaldo is goal-side; drops to double the winger'),
    (3, 'Left back (Marcelo)', 'Covers both winger and full back, closes the full back when he receives'),
    (4, 'Left winger (Ronaldo)', 'Drops to double or triple at the touchline'),
    (5, 'Right DM (Khedira)', 'Slides left to mark the No.10 and block the switch')
) AS v(so, role, job);

-- 51. pp.153-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-3', 'Mirror midfield: press the centre back, isolate the dropping midfielder',
    'Three v three in midfield; Madrids midfielders track their men only when they become receivers in a press. Keeper passes to the left centre back who has time.',
    'Keepers pass to a centre back',
    'The press creates a ball side; a midfielder who drops short cannot turn, is triple-marked, and can only go to the touchline where he is isolated.',
    '4-3-3', 153, 154, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Presses the centre back on an angle to make the ball side, then recovers as the third man'),
    (2, 'Right winger (Di Maria)', 'Goal-side of the advancing full back, blocks the pass to him'),
    (3, 'Right DM (Khedira)', 'Follows the dropping midfielder and stops him turning'),
    (4, 'No.10 (Ozil)', 'Shifts right and blocks the turn inside')
) AS v(so, role, job);

-- 52. pp.155-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-3', 'Winger comes inside while the full back overlaps',
    'The left centre back carries forward; their winger drops inside, the full back overlaps and a midfielder runs into the space left.',
    'Centre back carrying, winger moving inside, full back overlapping',
    'The back line hands men on and slides across; when the winger receives the four step up and the midfield closes him. A poor first press forces the winger to cover two men.',
    '4-3-3', 155, 156, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Closes the carrier'),
    (2, 'Right winger (Di Maria)', 'Follows the full back but loses his goal-side spot'),
    (3, 'Right back (Arbeloa)', 'Follows the winger, then stops to cover the overlap'),
    (4, 'Right DM (Khedira)', 'Tracks the runner, hands him to Pepe, then closes the ball'),
    (5, 'Right centre back (Pepe)', 'Slides right to cover Arbeloa'),
    (6, 'Ramos, Marcelo', 'Block the strikers run and step up for offside')
) AS v(so, role, job);

-- 53. pp.157-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-3', 'Mark forwards who drop deep to receive',
    'Keeper to right centre back; the right back runs forward while the winger and No.10 come short.',
    'Forwards dropping towards the ball',
    'The full back follows the dropping winger and marks him hard because Ronaldo covers the overlap behind; the ball is then doubled or tripled at the touchline.',
    '4-3-3', 157, 158, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Presses the centre back'),
    (2, 'Left winger (Ronaldo)', 'Tracks the full backs run, later third man on the ball'),
    (3, 'Left back (Marcelo)', 'Steps out and marks the dropping winger aggressively'),
    (4, 'Left DM (Alonso)', 'Tight on the No.10, then drops to double the winger'),
    (5, 'Left centre back (Ramos)', 'Tight on the striker in case of a long ball'),
    (6, 'Right DM (Khedira)', 'Shifts to the ball side')
) AS v(so, role, job);

-- 54. pp.159-160
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-3', 'Shut the inside, force play down the line',
    'Keeper to right centre back; their No.10 and holding midfielder try to get free.',
    'Pass to the centre back, then out to the full back',
    'All inside options are marked so the ball must go down the line to the winger, who is triple-marked with the switch cut.',
    '4-3-3', 159, 160, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Presses, then blocks the pass back to the centre back'),
    (2, 'Left winger (Ronaldo)', 'Presses the full back'),
    (3, 'Marcelo, Ronaldo, Alonso', 'Triple-mark the winger'),
    (4, 'No.10 (Ozil)', 'Leaves his man to sit beside the No.10 and block the switch through him')
) AS v(so, role, job);

-- 55. pp.161-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-3', 'Vertical pass to the winger at halfway',
    'Benzema does not get close enough and the centre back hits a longer vertical ball to the right winger near halfway.',
    'Longer forward pass to the winger while Ronaldo stays goal-side',
    'The three nearest players swarm the receiver and every nearby opponent is marked tight.',
    '4-3-3', 161, 162, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'Follows the winger as he comes short'),
    (2, 'Left winger (Ronaldo)', 'Holds goal-side, then makes three on the ball'),
    (3, 'Left DM (Alonso)', 'Cuts the vertical lane, then triple-marks'),
    (4, 'Ozil, Khedira', 'Mark the nearby midfielders'),
    (5, 'Left centre back (Ramos)', 'Covers')
) AS v(so, role, job);

-- 56. pp.163-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-3', 'Long ball to the striker: win the second ball',
    'Benzema is too far from the centre back and the wingers are goal-side; the centre back goes long to the striker.',
    'Long pass towards the striker',
    'The centre back heads it away and the midfielders, already sprinting back around the drop zone, win the second ball.',
    '4-3-3', 163, 164, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 (Ozil)', 'Closes the carrier'),
    (2, 'CF (Benzema)', 'Drops onto the holding midfielder'),
    (3, 'Left centre back (Ramos)', 'Tight on the striker and heads it clear'),
    (4, 'Khedira, Alonso, Ronaldo, Benzema', 'Collapse on the second ball'),
    (5, 'Pepe, Marcelo, Arbeloa', 'Cover and balance the line')
) AS v(so, role, job);

-- 57. pp.165-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-3', 'Two v two by the touchline becomes three or four v two',
    'Keeper to left centre back with Ozil pressing first; or Benzema presses the keeper who kicks long to the advanced left back.',
    'Ball to the full back or winger near the touchline',
    'The duel at the line is overloaded and the inside covered; once the full back is closed the line holds high and steps up on the back pass, leaving forwards offside.',
    '4-3-3', 165, 168, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 (Ozil)', 'First presser, steers the centre back to the touchline; then marks the holding midfielder'),
    (2, 'Right DM (Khedira)', 'Takes the holding midfielder, or closes the full back from his balanced spot'),
    (3, 'Right winger (Di Maria)', 'Presses the full back and doubles the winger, or tucks in and doubles the centre back after a back pass'),
    (4, 'Right back (Arbeloa)', 'Balanced between winger and midfielder, presses the winger goal-side'),
    (5, 'Right centre back (Pepe)', 'Slides towards the ball to cover until Alonso arrives'),
    (6, 'Back four', 'Steps up a few yards on the pass back')
) AS v(so, role, job);

-- 58. pp.169-170
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-3', 'Keeper plays short to a dropping midfielder',
    'Benzemas position pushes play to Madrids right; a midfielder drops to take a short pass from the keeper.',
    'Keepers short pass to the midfielder',
    'The receiver is doubled and whoever gets the next pass has no nearby option; the switch is blocked.',
    '4-3-3', 169, 170, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right DM (Khedira)', 'Does not chase the midfielder (would unbalance); covers the full back and presses him'),
    (2, 'No.10 (Ozil)', 'Shifts right to press the midfielder, later blocks the switch'),
    (3, 'Right winger (Di Maria)', 'Doubles the midfielder, closes the centre back, then doubles the full back'),
    (4, 'CF (Benzema)', 'Blocks the pass back to the keeper'),
    (5, 'Right back (Arbeloa)', 'Tight on the winger')
) AS v(so, role, job);

-- 59. pp.171-172
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-3', 'Close down short passes high up',
    'Keeper to left centre back and a midfielder drops towards him.',
    'Short pass from the centre back to the midfielder',
    'The midfielder cannot turn, is triple-marked, and the pass to the full back is cut.',
    '4-3-3', 171, 172, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'Presses the centre back, then joins the triple'),
    (2, 'CF (Benzema)', 'Blocks the back pass, ready to double'),
    (3, 'No.10 (Ozil)', 'Follows the midfielder and stops him turning'),
    (4, 'Right DM (Khedira)', 'Sits between midfielder and full back, then cuts the pass to the full back'),
    (5, 'Left DM (Alonso)', 'Slides across to balance')
) AS v(so, role, job);

-- 60. pp.173-174
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-3', 'Keep the ball off the weak side',
    'The left centre back has time so Di Maria must step onto him; the holding midfielder comes short and the ball goes on to the left back.',
    'Midfielder offers, then the pass out to the full back',
    'The full back is closed and doubled and every route back inside is shut; Khedira covering two men buys the time.',
    '4-3-3', 173, 174, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'Steps onto the centre back, then recovers to double the full back'),
    (2, 'Right DM (Khedira)', 'Key man: between midfielder and full back, then closes the full back'),
    (3, 'CF (Benzema)', 'Blocks the back pass, helps Ozil double the midfielder, then takes him so Ozil can switch'),
    (4, 'No.10 (Ozil)', 'Blocks the switch'),
    (5, 'Right back (Arbeloa)', 'Tight on the winger'),
    (6, 'Right centre back (Pepe)', 'Follows the striker coming towards the ball')
) AS v(so, role, job);

-- 61. pp.176-177
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-1-2', 'Short in midfield: everyone covers two',
    'Four v three against Madrid in midfield, so the midfielders take balanced spots covering two men each; Madrids full backs have no direct man unless the strikers drift wide. The right centre back carries forward with his full back running on.',
    'Keeper to centre back; his pass to the wide midfielder triggers the triple mark',
    'The receiver is triple-marked and every nearby option marked. If their No.10 pushes up, a centre back takes him; the weak-side winger tucks in on the wide midfielder.',
    '4-3-1-2', 176, 177, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 (Ozil)', 'Presses the centre back because Benzema is far; then triples the wide midfielder'),
    (2, 'Left winger (Ronaldo)', 'Drops to stay goal-side of the full back'),
    (3, 'CF (Benzema)', 'Recovers onto the holding midfielder'),
    (4, 'Right DM (Khedira)', 'Marks the No.10'),
    (5, 'Left back (Marcelo)', 'Marks a striker who drifts wide'),
    (6, 'Right back (Arbeloa)', 'Tucks in to support the centre backs, no wide man to mark')
) AS v(so, role, job);

-- 62. pp.178-179
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-1-2', 'Triple-mark the receiver near their box',
    'Benzema is better placed and presses the centre back first; the wide midfielder drops to receive.',
    'Pass to the dropping wide midfielder',
    'He is triple-marked high, near his own box; Madrid commit numbers trusting only a very skilled side can play through.',
    '4-3-1-2', 178, 179, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'First presser, then part of the triple'),
    (2, 'No.10 (Ozil)', 'Shifts to the ball side and takes the receiver'),
    (3, 'Left DM (Alonso)', 'Hands the man to Ozil but stays close to add a body'),
    (4, 'Left winger (Ronaldo)', 'Completes the triple')
) AS v(so, role, job);

-- 63. pp.180-181
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-1-2', 'Cut vertical passes, overload at the ball',
    'Benzema presses the right centre back, Ozil shifts across; the ball goes to the full back and down the line to a striker drifting wide.',
    'Pass to the full back, then down the line to the striker',
    'Near options are blocked, the striker receives at the touchline and is doubled or tripled; the switch is cut.',
    '4-3-1-2', 180, 181, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Presses the full back, then recovers to help'),
    (2, 'No.10 (Ozil)', 'Blocks the pass to the wide midfielder, then marks him to stop the switch'),
    (3, 'Left back (Marcelo)', 'Blocks the striker, then doubles him with Alonso'),
    (4, 'Left DM (Alonso)', 'Adds a body near the ball'),
    (5, 'Left centre back (Ramos)', 'Slides to cover Marcelo'),
    (6, 'Right winger (Di Maria)', 'Tucks in on the far midfielder')
) AS v(so, role, job);

-- 64. pp.182-183
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-1-2', 'Hard shift to stop the switch of play',
    'Benzema presses the right centre back and the holding midfielder comes towards the ball; Marcelo is free because Ramos has the striker.',
    'Pass to the full back, then on to the striker drifting wide',
    'The team shifts hard towards the ball so it can mark aggressively, leaving one pass: to a player on the touchline with his back to goal, who is squeezed.',
    '4-3-1-2', 182, 183, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'First presser'),
    (2, 'No.10 (Ozil)', 'Follows the holding midfielder; with Benzema blocks the switch'),
    (3, 'Left back (Marcelo)', 'Spare at first, adds a body; then stops the striker turning'),
    (4, 'Left DM (Alonso)', 'Marks the wide midfielder, then triples the striker'),
    (5, 'Left centre back (Ramos)', 'Follows the striker behind Marcelo, stays in cover'),
    (6, 'Di Maria, Arbeloa', 'Di Maria tracks the far full back so Arbeloa can follow his man inside')
) AS v(so, role, job);

-- 65. pp.184-185
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-1-2', 'Striker drifts into the full backs zone',
    'Benzema presses the right centre back and a striker drifts out into Marcelos zone.',
    'Striker moves into the full backs zone',
    'The full back takes the striker and the centre back slides over behind him; inside lanes stay closed and the ball is pushed towards the touchline.',
    '4-3-1-2', 184, 185, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Presses the centre back'),
    (2, 'No.10 (Ozil)', 'Shifts left'),
    (3, 'Left DM (Alonso)', 'Tight on the wide midfielder'),
    (4, 'Left back (Marcelo)', 'Takes the striker'),
    (5, 'Left centre back (Ramos)', 'Slides left to cover Marcelo')
) AS v(so, role, job);

-- 66. pp.186-187
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-1-2', 'Press the keeper to create a strong side',
    'Wingers balanced, Benzema presses the keeper directly; the left centre back gets it, runs out of passes and plays back; the keeper goes long to the left back.',
    'Benzemas pressure on the keeper',
    'Play is boxed onto one flank; the long kick to the full back is attacked while the ball is in the air, doubled, and the switch is cut.',
    '4-3-1-2', 186, 187, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Presses the keeper, covers keeper and holding midfielder, closes the keeper on the back pass'),
    (2, 'Right winger (Di Maria)', 'Presses the centre back while blocking the pass to the full back; recovers to double'),
    (3, 'Right back (Arbeloa)', 'Balanced; attacks the full back while the long kick is in the air'),
    (4, 'Right DM (Khedira)', 'Follows his man, then leaves him to double the full back'),
    (5, 'No.10 (Ozil)', 'Marks the midfielder to block the switch'),
    (6, 'Right centre back (Pepe)', 'Tight on the striker, goal-side')
) AS v(so, role, job);

-- 67. pp.188-188
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 4-3-1-2', 'Long kick to the advanced full back',
    'Benzema presses the keeper directly again and the keeper kicks long straight to the pushed-up left back.',
    'Keepers long kick to the wide full back',
    'Using the time the ball is in the air, the receiver is doubled at once and the nearest midfielder blocks the switch.',
    '4-3-1-2', 188, 188, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'Closes the full back while the ball travels'),
    (2, 'Right winger (Di Maria)', 'Doubles with Arbeloa'),
    (3, 'Right DM (Khedira)', 'Marks the midfielder to block the switch'),
    (4, 'CF (Benzema)', 'His pressure on the keeper forced the long kick')
) AS v(so, role, job);

-- 68. pp.190-191
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 5-4-1', 'Base press against a back five',
    'The opponent builds with three centre backs and two wing backs. Each Madrid winger sits in the gap between a wide centre back and his wing back; the striker takes the middle centre back.',
    'Keepers pass to a wide centre back',
    'The near winger presses with every short option covered; when the ball reaches the wing back he is closed and doubled on the touchline and cannot switch.',
    '5-4-1', 190, 191, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Between centre back and wing back; presses the centre back, recovers to double the wing back'),
    (2, 'Left DM (Alonso)', 'Shades left to cover the wing backs runs; closes him when he receives'),
    (3, 'Right DM (Khedira)', 'Handles his man and the far wing back, helped by Di Maria'),
    (4, 'CF (Benzema)', 'Cuts the back pass to the keeper and the pass into midfield'),
    (5, 'No.10 (Ozil)', 'Marks a central midfielder; slides to block the switch'),
    (6, 'Ball-side centre back (Ramos)', 'Leaves the unreachable striker to cover Marcelo')
) AS v(so, role, job);

-- 69. pp.192-193
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 5-4-1', 'Triple the midfielder who takes a short pass',
    'Keeper to the wide centre back, Ronaldo presses, and the defender plays short into a midfielder.',
    'Vertical pass from a centre back into midfield',
    'Two or three players close the new carrier at once so he cannot turn.',
    '5-4-1', 192, 193, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Presses the centre back'),
    (2, 'No.10 (Ozil)', 'Squeezes the receiver'),
    (3, 'CF (Benzema)', 'Screens the pass into midfield and back to the keeper, then joins the trap')
) AS v(so, role, job);

-- 70. pp.194-195
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 5-4-1', 'Stop the dropping No.10 turning high up',
    'Keeper to the left centre back, who finds their No.10 dropping deep.',
    'No.10 drops to receive',
    'The receiver has no pass forward or sideways.',
    '5-4-1', 194, 195, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Presses the centre back'),
    (2, 'Right winger (Di Maria)', 'Ready to jump the No.10 or the wide centre back'),
    (3, 'Right DM (Khedira)', 'Steps to the No.10 on an angle that cuts the pass to the wing back'),
    (4, 'No.10 (Ozil)', 'Slides across and shuts lanes'),
    (5, 'Right back (Arbeloa)', 'Edges up towards the wing back but stays near Pepe because their winger has tucked in')
) AS v(so, role, job);

-- 71. pp.196-197
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 5-4-1', 'Ball played across the back five: chase it to the wing back',
    'The ball travels keeper, middle centre back, wide centre back, wing back.',
    'Each sideways pass along the back',
    'The ball is pushed to the touchline and the wing back is surrounded by three.',
    '5-4-1', 196, 197, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Presses the middle centre back'),
    (2, 'Right winger (Di Maria)', 'Presses the wide centre back at once, then recovers to triple the wing back'),
    (3, 'Khedira, Arbeloa', 'Cover the wing back, then double him'),
    (4, 'Right centre back (Pepe)', 'Marks the winger'),
    (5, 'No.10 (Ozil)', 'Marks their No.10 to stop the switch, which frees Di Maria to join the trap')
) AS v(so, role, job);

-- 72. pp.198-199
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 5-4-1', 'Pass wide to the wing back: close, double, step up',
    'The ball goes out to the left wing back high and wide; their winger stays wide.',
    'Pass to the wing back',
    'The ball is boxed in by the touchline, the line steps up to leave the winger offside, and the team is compact again; the whole-team shift stops the switch.',
    '5-4-1', 198, 199, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right DM (Khedira)', 'Closes the wing back so he cannot play forward'),
    (2, 'Right winger (Di Maria)', 'Sprints back to double'),
    (3, 'Right back (Arbeloa)', 'Follows the wingers run goal-side, then steps up once closed'),
    (4, 'Centre backs (Pepe, Ramos)', 'Pepe tight on the striker, Ramos covers; both step up when closed'),
    (5, 'No.10 (Ozil)', 'Marks their No.10 to keep the ball off the weak side')
) AS v(so, role, job);

-- 73. pp.200-200
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Real Madrid in the Defensive Phase against the 5-4-1', 'Back pass to the keeper: lock it on Madrids left',
    'A centre back plays back to the keeper.',
    'Back pass to the goalkeeper',
    'The whole team reacts together and seals the ball on Madrids left flank.',
    '5-4-1', 200, 200, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'CF (Benzema)', 'Presses the keeper at once, curving to force the kick left'),
    (2, 'Left DM (Alonso)', 'Moves early to the wing back and closes him when the pass arrives'),
    (3, 'Left back (Marcelo)', 'Stays behind Alonso as cover'),
    (4, 'No.10 (Ozil)', 'Marks the winger who drops in'),
    (5, 'Left winger (Ronaldo)', 'Slides inside to block the pass into midfield')
) AS v(so, role, job);

-- 74. pp.202-202
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Defending on the Weak Side', 'Switch to the weak side with Ronaldo goal-side',
    'The opponent switches play to their winger on Madrids left; Ronaldo is already goal-side of their full back.',
    'Switch pass reaches the winger',
    'Two v one at the ball, the box set for the cross and the edge of the area screened for clearances.',
    NULL, 202, 202, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'Contests the winger'),
    (2, 'Left DM (Alonso)', 'Slides across to make two v one'),
    (3, 'Other three defenders', 'Drop into the box for the cross'),
    (4, 'Right DM (Khedira)', 'Holds just outside the box'),
    (5, 'Left winger (Ronaldo)', 'Tracks the full backs forward run'),
    (6, 'No.10 and right winger', 'Come inside to win the second ball')
) AS v(so, role, job);

-- 75. pp.203-203
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Defending on the Weak Side', 'Switch finds the high full back: Marcelo waits for the handover',
    'The switch reaches the advanced full back while Ronaldo is badly placed; if Marcelo jumps at once the winger is left free.',
    'Advanced full back receives on the weak side',
    'Marcelo delays until Ramos can take the winger, then goes to the ball; the centre slides across and balance holds.',
    NULL, 203, 203, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'Stays near the winger until relieved, then presses the full back'),
    (2, 'Left centre back (Ramos)', 'Slides across, takes the winger and follows his inside run'),
    (3, 'Left DM (Alonso)', 'Drops into Ramoss centre-back spot'),
    (4, 'Khedira, Di Maria', 'Long shifts towards the ball to sit outside the box'),
    (5, 'No.10, Ronaldo', 'Ready for the second ball')
) AS v(so, role, job);

-- 76. pp.204-205
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Defending on the Weak Side', 'Two v two on the flank with Ronaldo working',
    'Their winger has the ball and the full back overlaps; Ronaldo is in a good defensive spot.',
    'Full back starts the overlap',
    'Marcelo and Ronaldo swap men on the overlap so the 2v2 holds without pulling the centre apart; Ramos stays central and Alonso at the box edge.',
    NULL, 204, 205, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'Closes the winger; hands him to Ronaldo and follows the overlap'),
    (2, 'Left winger (Ronaldo)', 'Tracks the overlap first, then takes the ball carrier'),
    (3, 'Left DM (Alonso)', 'Moves left to add the extra man'),
    (4, 'Other defenders', 'Set in the box for the cross')
) AS v(so, role, job);

-- 77. pp.206-207
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Defending on the Weak Side', 'Ronaldo absent on the weak side: Alonso takes the winger',
    'The switch reaches the winger with the full back also free because Ronaldo has not tracked back.',
    'Ball at the winger with the full back unmarked',
    'Both flank attackers are covered at the price of a large midfield slide.',
    NULL, 206, 207, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left DM (Alonso)', 'Long shift to contest the winger'),
    (2, 'Left back (Marcelo)', 'Freed to follow the full backs run'),
    (3, 'Left winger (Ronaldo)', 'Arrives late to double'),
    (4, 'Khedira, Di Maria', 'Shift to the ball side'),
    (5, 'Arbeloa, Pepe, Ramos', 'Into the box for the cross')
) AS v(so, role, job);

-- 78. pp.208-211
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Defending on the Weak Side', 'Full backs inside run: Alonso or Ramos tracks it',
    'Their winger has the ball and the full back runs inside him rather than round the outside; Ronaldo is out of position.',
    'Underlapping run by the full back',
    'The runner gets no time if he receives: Alonso follows him if he can get there, otherwise Ramos follows and Alonso drops into the centre-back gap. On the right Di Maria tracked, so this was rarely needed there.',
    NULL, 208, 211, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left DM (Alonso)', 'Long shift to follow the inside run, or drops into the centre-back spot'),
    (2, 'Left centre back (Ramos)', 'Follows the runner when he is the nearest man'),
    (3, 'Left back (Marcelo)', 'Stays on the ball carrier'),
    (4, 'Khedira, Di Maria', 'Shift left to keep balance'),
    (5, 'Left winger (Ronaldo)', 'Late recovery only')
) AS v(so, role, job);

-- 79. pp.212-212
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Defending on the Weak Side', 'Striker drifts to the touchline: Pepe follows, Alonso fills in',
    'Ball on Madrids right with their winger; the striker runs wide to overload the flank.',
    'Striker runs towards the touchline',
    'The overload is matched and the hole in the middle of defence closed.',
    NULL, 212, 212, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'Contests the ball carrier'),
    (2, 'Right centre back (Pepe)', 'Follows the striker wide'),
    (3, 'Left DM (Alonso)', 'Drops into the gap Pepe leaves'),
    (4, 'Right winger (Di Maria)', 'Doubles the ball carrier'),
    (5, 'Right DM (Khedira)', 'Joins to outnumber at the ball')
) AS v(so, role, job);

-- 80. pp.213-213
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Defending on the Weak Side', 'No.10 drifts to the touchline: Khedira tracks',
    'Same build-up on Madrids right but their No.10 makes the wide run.',
    'No.10 runs to the touchline',
    'The run is covered while the back four stays whole in the box.',
    NULL, 213, 213, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right DM (Khedira)', 'Nearest man, follows the No.10'),
    (2, 'Right back (Arbeloa)', 'Closes the ball carrier'),
    (3, 'Other three defenders', 'Drop into the box for the cross'),
    (4, 'Left DM (Alonso)', 'Holds balanced just outside the box')
) AS v(so, role, job);

-- 81. pp.215-218
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Defending when Pressing Application was not Possible', 'Free midfielder after a lay-off: drop, squeeze, then trap',
    'Their centre back goes long to the striker who lays it off to a midfielder in space in the centre; nobody is on the ball.',
    'Unpressured midfielder carrying forward',
    'Madrid retreat and compress the centre until the ball can be closed, forcing it wide; once closed, the line stops dropping and steps up.',
    NULL, 215, 218, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right DM (Khedira)', 'Backs off to avoid a 2v1, buying Di Maria time; contests the next receiver'),
    (2, 'Left DM (Alonso)', 'Tucks in to compact around the ball'),
    (3, 'Wingers (Di Maria, Ronaldo)', 'Track the full backs and squeeze in to help midfield; Di Maria doubles'),
    (4, 'Back four', 'While the ball is open track runs goal-side; stop once it is closed'),
    (5, 'Right back (Arbeloa)', 'Steps up to mark the winger tight once the carrier is under heavy pressure')
) AS v(so, role, job);

-- 82. pp.219-221
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Defending when Pressing Application was not Possible', 'Centre back carries out unpressed: Ozil goes, Di Maria guards the flank',
    'Benzemas first press did not force a side; the ball is switched through the keeper to the other centre back, who carries forward free.',
    'Free centre back dribbling out on Madrids right',
    'Madrid keep their numbers at the flank and retreat until someone presses; centre backs only get this room when the first press is late.',
    NULL, 219, 221, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'Does not step to the centre back (would leave Arbeloa 2v1); drops to cover the full back'),
    (2, 'No.10 (Ozil)', 'Slides across as first defender because he is nearer than Benzema'),
    (3, 'CF (Benzema)', 'Drops back to support Ozil'),
    (4, 'Right back (Arbeloa)', 'Closes the winger coming short, then returns to the full back'),
    (5, 'Right DM (Khedira)', 'Blocks the vertical pass'),
    (6, 'Back line', 'Pepe picks up the advancing No.10; Ramos and Marcelo recover goal-side of runners')
) AS v(so, role, job);

-- 83. pp.222-224
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Defending when Pressing Application was not Possible', 'Long kick into the centre: hand over the inside winger',
    'A long ball reaches their No.10 who sets a midfielder free in the centre; their winger drifts inside to open the flank for the full back on Madrids left.',
    'Free central carrier with the winger moving inside',
    'The ball is kept on Madrids left with an extra man at the ball.',
    NULL, 222, 224, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Cover the forwards runs goal-side while the ball is open'),
    (2, 'Left back (Marcelo)', 'Drops with the winger, hands him to Ramos, stays near the full back and steps out when he receives'),
    (3, 'Left centre back (Ramos)', 'Takes over the winger'),
    (4, 'Left DM (Alonso)', 'Squeezes the carrier, then supports Marcelo'),
    (5, 'Left winger (Ronaldo)', 'Recovers to cut the lane to the full back; marks the midfielder when Ozil is far')
) AS v(so, role, job);

-- 84. pp.225-226
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Defending when Pressing Application was not Possible', 'Free playmaker: block the middle, chain-slide the back line',
    'A long kick is laid off and their holding midfielder advances in space.',
    'Free midfielder moving forward',
    'Central passes are blocked so the ball goes wide, where the full back is doubled while the line keeps tracking forwards.',
    NULL, 225, 226, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield pair (Alonso, Khedira)', 'Squeeze to block vertical and diagonal passes'),
    (2, 'Full backs', 'Cover the wingers runs, goal-side'),
    (3, 'Wingers (Ronaldo, Di Maria)', 'Recovery runs to cut passes to the full backs'),
    (4, 'Centre backs', 'Ramos marks the dropping striker then slides to cover Marcelo; Pepe slides over to Ramos'),
    (5, 'Ronaldo, Alonso', 'Close and double the full back because Marcelo is pinned')
) AS v(so, role, job);

-- 85. pp.227-228
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'out_of_possession', 'Defending when Pressing Application was not Possible', 'Winger receives in space centrally: hold, cover, chase back',
    'Ozil shifted late so a midfielder is free; their winger comes inside to receive while the full back overlaps.',
    'Free midfielder, then the inside winger turns',
    'Protect the space behind until the carrier is closed. Three reactions to a free central player: take covering positions, track runs in behind, block vertical passes.',
    NULL, 227, 228, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 (Ozil)', 'Closes the free midfielder'),
    (2, 'Left DM (Alonso)', 'Holds and blocks the pass into the full backs run'),
    (3, 'Right DM (Khedira)', 'Marks the No.10, then chases back to close the winger who turned'),
    (4, 'Right back (Arbeloa)', 'Does not follow the winger inside; covers the overlapping full back'),
    (5, 'Back line', 'Keeps retreating until the forward pass is stopped')
) AS v(so, role, job);

-- 86. pp.230-230
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'set_piece', 'Defending from Set Pieces', 'Goal kick: compact block, best header on their target',
    'Madrids shape for the opposing keepers goal kick.',
    'Opponent goal kick',
    'The usual long target is contested and the receivers around him are marked.',
    NULL, 230, 230, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left DM (Alonso)', 'Stands closest to their best header, the usual target'),
    (2, 'Rest of the team', 'Each picks up a nearby opponent in a compact block around halfway'),
    (3, 'Benzema, Ozil', 'Higher, near their centre backs and midfielders')
) AS v(so, role, job);

-- 87. pp.231-231
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'set_piece', 'Defending from Set Pieces', 'Corner: mixed zonal and man marking',
    'Opponent corner.',
    'Corner kick',
    'Near post guarded zonally, aerial threats marked tight, clearances recovered.',
    NULL, 231, 231, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Benzema, Ronaldo', 'Zonal, guarding the near-post space'),
    (2, 'Ramos, Pepe, Alonso, Khedira, Arbeloa', 'Tight man-marking on the aerial threats'),
    (3, 'Di Maria, Marcelo', 'Outside the box for cleared balls'),
    (4, 'Ozil', 'Highest player, sometimes swapped with Di Maria')
) AS v(so, role, job);

-- 88. pp.232-232
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'set_piece', 'Defending from Set Pieces', 'Short corner: two go out to the flag',
    'Their full back comes short to the corner taker.',
    'Short option offered at the flag',
    'No two v one at the flag, while Madrid still outnumber attackers in the box.',
    NULL, 232, 232, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Benzema, Di Maria', 'Run out to mark the short receiver'),
    (2, 'Ozil', 'Drops into Di Marias slot'),
    (3, 'Rest', 'Keep superiority in the box')
) AS v(so, role, job);

-- 89. pp.233-233
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'set_piece', 'Defending from Set Pieces', 'Free kick near the corner flag',
    'Wide free kick close to the flag.',
    'Free kick in the corner area',
    'A two-man wall and one zonal man; everyone else marks a man.',
    NULL, 233, 233, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wall', 'Two players'),
    (2, 'Benzema', 'The only spare zonal player'),
    (3, 'Ronaldo', 'Marks a man near the front post'),
    (4, 'Ramos, Pepe, Arbeloa, Alonso', 'Man-mark the rest'),
    (5, 'Ozil, Marcelo', 'Outside the box')
) AS v(so, role, job);

-- 90. pp.234-234
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'set_piece', 'Defending from Set Pieces', 'Central free kick just outside the box',
    'Direct free kick a few yards outside the area.',
    'Free kick in shooting range',
    'The shot is blocked by a four-man wall and the markers hold one line so runners can be left offside.',
    NULL, 234, 234, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wall', 'Four players'),
    (2, 'Benzema', 'Spare man, defends the zone'),
    (3, 'Alonso, Pepe, Ramos', 'Man-mark, all on one line just inside the box'),
    (4, 'Arbeloa', 'Marks a man just outside the box'),
    (5, 'Ozil', 'Outside the box guarding the space')
) AS v(so, role, job);

-- 91. pp.235-235
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'set_piece', 'Defending from Set Pieces', 'Throw-in near halfway against two strikers',
    'Opponent throw-in on Madrids right level with halfway.',
    'Opponent throw-in',
    'A spare man stays at the back and every nearby receiver is marked.',
    '4-4-2', 235, 235, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right DM (Diarra)', 'Shifts to the touchline and takes the winger'),
    (2, 'Left DM (Alonso)', 'Slides right for balance'),
    (3, 'Arbeloa, Pepe', 'Mark the two strikers'),
    (4, 'Ramos', 'Spare man at the back'),
    (5, 'Ozil, Benzema', 'Mark a midfielder and the near centre back'),
    (6, 'Di Maria', 'Ready to double the winger if he receives')
) AS v(so, role, job);

-- 92. pp.236-236
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'set_piece', 'Defending from Set Pieces', 'Throw-in near halfway against one striker',
    'The same throw-in against a single striker.',
    'Opponent throw-in',
    'The back already has a spare man, so the midfield does not over-shift.',
    '4-2-3-1', 236, 236, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right DM (Diarra)', 'No long shift; stays near the No.10'),
    (2, 'Right back (Arbeloa)', 'Marks the winger'),
    (3, 'No.10 (Ozil)', 'Marks a midfielder'),
    (4, 'CF (Benzema)', 'Blocks the throwers pass back to the centre back')
) AS v(so, role, job);

-- 93. pp.237-237
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'terzis-mourinho-real-madrid-defending'), 'set_piece', 'Defending from Set Pieces', 'Throw-in near halfway against three forwards',
    'The same throw-in against a front three.',
    'Opponent throw-in',
    'Madrid keep an extra man at the back and every receiver near the ball is marked closely.',
    '4-3-3', 237, 237, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ramos', 'Spare man at the back'),
    (2, 'Players around the ball', 'Tight on every potential receiver'),
    (3, 'Left DM (Alonso)', 'Balances the midfield')
) AS v(so, role, job);

COMMIT;
