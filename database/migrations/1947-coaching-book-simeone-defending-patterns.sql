-- 1947 📚 Coaching book patterns: Terzis, "Diego Simeone Defending Tactics -
-- Tactical Analysis and Sessions from Atlético Madrid's 4-4-2" (SoccerTutor),
-- Atlético 2017-18 and 2018-19.  Every page (1-268) read; each team pattern
-- the book describes written up in OUR OWN WORDS (short paraphrase, nothing
-- copied): moment, trigger, aim, opponent shape where the book splits by it,
-- app page numbers as the citation, and who does what.  Training sessions /
-- practices, intro, contents and adverts are left out.  The build-up "keep a
-- spare man at the back" chapter is filed as to_defend (the book puts it
-- under the transition to defence).  Owner's personal library.
-- (James 11/26 'continue with the reading of the coach viewer books')
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Diego Simeone Defending Tactics',
    subtitle    = 'Tactical Analysis and Sessions from Atlético Madrid''s 4-4-2',
    author      = 'Athanasios Terzis',
    team        = 'Atlético Madrid',
    season      = '2017-18, 2018-19',
    method_note = 'The author studied Atlético Madrid''s matches across 2017-18 and 2018-19 in Simeone''s 4-4-2; a behaviour went in the book only once it had recurred at least 10 times. Each one is drawn with positions, passes, movements and body shape, split by the opponent''s shape, then turned into a training session. The defending book: defensive phase (forwards, midfield line, defenders, full backs, front and rear block, pressing from the goalkeeper) and the transition from attack to defence.'
WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad');

-- 1. pp.20-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 1: Positioning and Defensive Movements of the Forwards', 'Front two press-and-drop balance',
    'Opponent builds through two centre backs. The forward nearest the ball steps to press the carrier, and the other drops diagonally behind him into a balanced spot between the pass into midfield and the second centre back.',
    'Centre back receives in build-up',
    'Keep the space between forwards and midfield small and keep both the through pass and the far centre back in check.',
    NULL, 20, 21, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side forward (Torres)', 'Press the centre back on the ball'),
    (2, 'Far forward (Griezmann)', 'Drop diagonally and shade the through-pass lane while staying near the far centre back'),
    (3, 'Far forward error', 'If he shifts too far to close the lane, the far centre back gets free space to carry forward; sprint back across to restore balance')
) AS v(so, role, job);

-- 2. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 1: Positioning and Defensive Movements of the Forwards', 'Central midfielders mirror the forwards',
    'The two central midfielders copy the slanted shape of the front two, one step behind them, so the two lines move as one unit.',
    'Front two take their press/drop shape',
    'Keep the gap between the attack and midfield lines tight and leave the free centre back no easy forward option.',
    NULL, 22, 22, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (Gabi, Saul)', 'Copy the forwards'' angle a few yards behind them'),
    (2, 'Deepest forward (Griezmann)', 'Hold a balanced position the midfielders can mirror')
) AS v(so, role, job);

-- 3. pp.26-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 2: Defensive Reactions when the Positioning of 1 Forward is Incorrect', 'Wait to press until partner recovers',
    'One forward is caught too high to drop in behind his partner. The ball-side forward does not jump at the centre back yet. He stays near the midfielders to block the pass into the weak-side central midfielder and presses only once his partner has dropped into place.',
    'Partner forward out of position (too advanced) as a centre back gets the ball',
    'Avoid opening the space between the lines. Press with timing so both passing options stay covered.',
    '4-4-2', 26, 33, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side forward (Torres)', 'Stay close to the midfield line and screen the pass into the far central midfielder; step out only when his partner is back'),
    (2, 'Late forward (Griezmann)', 'Drop back fast; once in place he can intercept the direct pass or the one via a link player, and pressure the receiver'),
    (3, 'Error case', 'Pressing too early with the partner still high lets the defensive midfielder receive free between the lines')
) AS v(so, role, job);

-- 4. pp.27-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 2: Defensive Reactions when the Positioning of 1 Forward is Incorrect', 'Force inside pass then double-team',
    'With the weak-side central midfielder screened, the centre back can only feed the strong-side central midfielder, who receives in a crowded area.',
    'Centre back passes to strong-side central midfielder',
    'Trap and win the ball from the new receiver.',
    NULL, 27, 27, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deepest forward (Torres)', 'Close the receiver from behind'),
    (2, 'Ball-side central midfielder (Gabi)', 'Close the receiver from the front to complete the double mark')
) AS v(so, role, job);

-- 5. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 2: Defensive Reactions when the Positioning of 1 Forward is Incorrect', 'Centre back carries: deep forward drops across',
    'The free centre back dribbles forward while one forward is still high. The deeper forward drops back and across in front of the carrier, staying close to the midfield line.',
    'Opposing centre back moves forward with the ball',
    'Block the pass into the weak-side central midfielder, keep the lines compact and buy time for the other forward to recover.',
    NULL, 28, 28, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deepest forward (Torres)', 'Retreat diagonally to face the carrier and screen the inside pass'),
    (2, 'Advanced forward (Griezmann)', 'Use the time to recover into a balanced position'),
    (3, 'Central midfielders', 'Hold a compact line behind')
) AS v(so, role, job);

-- 6. pp.31-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 2: Defensive Reactions when the Positioning of 1 Forward is Incorrect', 'Mistimed press v one-holder midfield',
    'Against a single defensive midfielder with two attacking midfielders, the same wait-then-press rule applies. A forward who presses early either leaves the holder free for a direct pass, or blocks that pass only for the ball to reach him through an attacking midfielder dropping in as a link.',
    'Forward presses centre back while partner is still high',
    'Shows why the deep forward must stay near the midfield until his partner recovers, or a through ball into the back line follows.',
    '4-3-3', 31, 32, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing forward (Torres)', 'Do not step up early; even a lane-blocking press can be bypassed by a link player'),
    (2, 'Advanced forward (Griezmann)', 'Recover so the holder is covered'),
    (3, 'Defensive midfielder (opponent No.6)', 'The target the front two must deny')
) AS v(so, role, job);

-- 7. pp.38-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 3: Positioning of the Forwards to Prepare for Counter Attacks', 'Counter-ready 4-4-1-1 front pair',
    'Against two centre backs, one forward (usually Diego Costa) stays high between the two centre backs while the other (Griezmann) drops deep, so the block looks like a 4-4-1-1. The rest of the team shifts to the strong side.',
    'Opponent builds from the keeper to a centre back',
    'Keep a striker high to run at the space between the centre backs on a regain. This leaves more room between the lines than the normal shape.',
    NULL, 38, 39, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advanced forward (Diego Costa)', 'Stay between the centre backs as the outlet for a counter attack'),
    (2, 'Deep forward (Griezmann)', 'Stay near the midfielders, squeeze the strong-side central midfielder and block the pass to the weak-side central midfielder'),
    (3, 'Midfield line', 'Shift to the strong side')
) AS v(so, role, job);

-- 8. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 3: Positioning of the Forwards to Prepare for Counter Attacks', 'High forward screens inside, forces wide',
    'In the counter-ready shape, when the centre back carries forward the deep forward shifts across to close him, and the high forward drops a few yards to screen the pass into the weak-side central midfielder.',
    'Centre back dribbles forward in the 4-4-1-1 shape',
    'Narrow the inside lane, keep the lines tight and push the attack to one side predictably while staying ready to counter.',
    NULL, 40, 40, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep forward (Griezmann)', 'Shift across to close down the carrier'),
    (2, 'Advanced forward (Diego Costa)', 'Drop slightly to block the inside pass, still in a counter-ready spot'),
    (3, 'Central midfielders (Gabi, Saul)', 'Hold compact behind')
) AS v(so, role, job);

-- 9. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 3: Positioning of the Forwards to Prepare for Counter Attacks', 'Front two against a back three',
    'Against three centre backs the two forwards start wider to cover all three and give up the counter-ready setup. When a wide centre back gets the ball, the forward on that side presses with a curved run that cuts off the switch, and the other forward slides diagonally toward the ball.',
    'Ball played to a wide centre back of a back three',
    'Lock the ball on one side, take the central and far centre backs out of play and erase the opponent''s spare man at the back.',
    '3-5-2', 41, 41, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side forward (Diego Costa)', 'Curved pressing run that blocks the switch inside'),
    (2, 'Other forward (Griezmann)', 'Shift diagonally to outnumber the opponent near the ball')
) AS v(so, role, job);

-- 10. pp.46-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 4: Positioning and Defensive Movements of the Midfielders', 'Compact midfield four shifts with ball',
    'The four midfielders move together with the ball, defending space rather than men, about 10 yards apart when the ball is about 15 yards away. They keep a safety distance from the carrier so they can react and block passes.',
    'Ball in the centre with the opposing defenders',
    'Shut every through pass into the area between midfield and defence (the crucial central area).',
    NULL, 46, 47, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All four midfielders', 'Shift as a unit with the ball, keeping fixed spacing and body angles that cut passing lanes'),
    (2, 'Weak-side central midfielder (Saul)', 'Sit a little deeper to guard the space between the lines and help the back line'),
    (3, 'Ball-side central midfielder (Gabi)', 'Block attempted through passes near the ball')
) AS v(so, role, job);

-- 11. pp.47-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 4: Positioning and Defensive Movements of the Midfielders', 'Midfield squeezes as carrier approaches',
    'The nearer the ball carrier gets, the tighter the midfield line gets. When a centre back dribbles forward, the midfielders drop back to keep their safety distance and pull inward.',
    'Ball carrier closes in, e.g. centre back dribbles forward',
    'Keep through-pass lanes shut even with less time to react.',
    NULL, 47, 48, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield line', 'Drop back and squeeze horizontally to keep a safety distance from the ball'),
    (2, 'Central midfielders', 'Close the gaps between themselves first')
) AS v(so, role, job);

-- 12. pp.48-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 4: Positioning and Defensive Movements of the Midfielders', 'Midfield triangle press on carrier',
    'Once the midfield line is compact, the midfielder nearest the dribbling centre back steps out to press him, and his neighbours form a triangle behind him.',
    'Line compact horizontally and carrier within reach',
    'Narrow the through lanes and steer the ball toward the touchline.',
    NULL, 48, 48, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest central midfielder (Gabi)', 'Step out and press the carrier'),
    (2, 'Neighbouring midfielders', 'Form the back corners of the triangle and cut the lanes')
) AS v(so, role, job);

-- 13. pp.49-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 4: Positioning and Defensive Movements of the Midfielders', 'Midfield shape with ball near touchline',
    'When the opposing full back has the ball near the line, the wide midfielder presses at an angle that blocks the inside pass and covers a big area behind him. The ball-side central midfielder tucks in next to him, and the far central midfielder sits deeper.',
    'Opposing full back in possession near the side-line',
    'Leave only a narrow through lane and keep the ball out wide.',
    NULL, 49, 49, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side wide midfielder (Koke)', 'Press from the inside and block the pass inside'),
    (2, 'Ball-side central midfielder (Gabi)', 'Close the lane next to Koke'),
    (3, 'Weak-side central midfielder (Saul)', 'Drop deeper near the centre backs to guard the space between the lines'),
    (4, 'Far wide midfielder (Correa)', 'Tuck in with the line')
) AS v(so, role, job);

-- 14. pp.54-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 5: Positioning and Defensive Movements of the Defenders', 'Back four zonal man-focus rules',
    'Unlike the midfield, the defenders shift with the ball but mark the opponent in their own zone, tighter the closer the ball is to that opponent. They are positioned to win the ball first if it is passed to their man, or to close him down at once. The strong-side full back can''t get too tight to his winger (handled with the wide midfielder later).',
    'Any opposition possession',
    'Make sure any pass to a forward is intercepted or pressured on arrival.',
    NULL, 54, 54, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Mark the forward in their zone; tighter as the ball gets nearer'),
    (2, 'Full backs', 'Mark the winger; the strong-side full back keeps some limit on how tight he goes')
) AS v(so, role, job);

-- 15. pp.55-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 5: Positioning and Defensive Movements of the Defenders', 'Back four against three forwards',
    'With the ball central against a front three, both centre backs mark the lone striker (2v1) and the full backs sit wide on the wingers (1v1), as close to the centre backs as they can while still able to cut out a long ball to the winger. With the ball near a touchline the strong-side full back steps a bit higher and the other three stay level. If the striker drifts to the ball side all four slide, and the far full back closes up to the centre backs while still minding his winger.',
    'Opponent in a 4-3-3 with the ball central or near a side-line',
    'Deny elite wingers time and space on the ball and keep a spare centre back on the striker. Full backs narrow as the ball nears goal.',
    '4-3-3', 55, 56, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Godin, Gimenez)', 'Double up on the lone striker'),
    (2, 'Strong-side full back (Filipe Luis)', 'Slightly higher, tight to the winger'),
    (3, 'Weak-side full back (Juanfran)', 'Slide in toward the centre backs but keep the far winger in check'),
    (4, 'Whole back line', 'Shift across when the striker shifts')
) AS v(so, role, job);

-- 16. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 5: Positioning and Defensive Movements of the Defenders', 'Compact back four v narrow front three',
    'When the opponent''s three forwards play narrow, the full backs tuck in to mark the inside wingers and the centre backs still double the striker.',
    'Three opposing forwards positioned narrow, ball central',
    'A tight, compact back four with no gaps in the middle.',
    '4-3-3', 57, 57, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Godin, Gimenez)', 'Two on the central striker'),
    (2, 'Full backs (Filipe Luis, Juanfran)', 'Narrow positions, marking the narrow wingers 1v1')
) AS v(so, role, job);

-- 17. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 5: Positioning and Defensive Movements of the Defenders', 'Back four against two forwards',
    'With the ball central against a front two, each centre back stays close to one striker. The full backs take middle positions so they can support the centre backs and still limit the wide midfielders.',
    'Opponent in 4-4-2 with the ball central',
    'Cover both strikers one-on-one while the full backs give inside help.',
    '4-4-2', 58, 58, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Godin, Gimenez)', 'Stay tight to one forward each'),
    (2, 'Full backs (Filipe Luis, Juanfran)', 'Balanced half-wide positions between centre back and winger')
) AS v(so, role, job);

-- 18. pp.59-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 5: Positioning and Defensive Movements of the Defenders', 'Two forwards, ball wide: goal-side CB',
    'Against two strikers with the ball out wide, the strong-side centre back stays goal-side of his man because his partner is busy with the other striker and can''t cover behind. On a long ball from the full back he only steps in front if he has clearly read it in time. Otherwise he pressures from behind to spoil the touch and stop the turn, and the other defenders form a cover triangle.',
    'Ball near the side-line or long pass from the full back to a striker',
    'Kill passes in behind first, then force a bad first touch and keep the striker facing away from goal and pushed wide.',
    '4-4-2', 59, 60, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side centre back (Gimenez)', 'Goal-side; contest from behind, stop the inside turn and push him wide; step in front only if there is time'),
    (2, 'Weak-side centre back (Godin)', 'Control the second striker and drop back and across to cover'),
    (3, 'Full backs', 'Narrower, balanced positions ready to support')
) AS v(so, role, job);

-- 19. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 5: Positioning and Defensive Movements of the Defenders', 'Back four v 4-2-3-1 by No.10 height',
    'Against a 4-2-3-1 the back line depends on how high the No.10 plays. If he sits deep, the defenders play as against a front three, with both centre backs on the striker and the full backs wide. If he pushes high, they play as against a front two: one centre back takes the No.10, the other the striker, and the full backs move more central.',
    'Opposing No.10 deep vs advanced',
    'Always match the real number of attackers in the last line.',
    '4-2-3-1', 61, 61, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back 1 (Godin)', 'Deep No.10: double the striker; high No.10: mark him'),
    (2, 'Centre back 2 (Gimenez)', 'Mark the striker'),
    (3, 'Full backs', 'Wide on the wingers with a deep No.10; more central with a high No.10')
) AS v(so, role, job);

-- 20. pp.62-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 5: Positioning and Defensive Movements of the Defenders', 'Two centre backs on a lone striker',
    'Against a single striker both centre backs mark him in a 2v1, so the strong-side centre back can mark by anticipation rather than strictly goal-side, because his partner covers behind. On a long or medium pass from wide he steps in front of the striker and clears before it arrives.',
    'Long or medium pass from the opposing full back toward the lone striker',
    'Win nearly every ball aimed at the striker before he controls it. This works best on passes from wide areas.',
    '4-2-3-1', 62, 63, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side centre back (Gimenez)', 'Read the pass early and step in front to clear'),
    (2, 'Weak-side centre back (Godin)', 'Stay close enough to cover behind his partner'),
    (3, 'Full backs', 'Hold on the wingers')
) AS v(so, role, job);

-- 21. pp.63-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 5: Positioning and Defensive Movements of the Defenders', 'Partner CB covers ball in behind',
    'Because the two centre backs stay close on a lone striker, a ball chipped over the stepping centre back, or a run into his blind side, is cut out by his partner, who gets there first.',
    'Pass over the top, or the striker runs onto the blind side of the first centre back',
    'Leave no space behind or beside the first centre back. The partner intercepts.',
    '4-2-3-1', 63, 64, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First centre back (Gimenez)', 'Steps toward the striker or the pass'),
    (2, 'Covering centre back (Godin)', 'Read the ball over or the blind-side run and win it first; track the striker tightly')
) AS v(so, role, job);

-- 22. pp.74-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 6: Wide Positioning of the Full Backs to Contest the Opposing Wingers', 'Wide full back attacks pass to winger',
    'Against a front three, the full backs set up wide, close to the wingers, so a long ball out to a winger can be cut out before it arrives. After every pass, including a switch of play, the far full back resets so he can still reach that ball.',
    'Opponent''s centre back or holding midfielder shapes to play long to a winger',
    'Clear the ball before a fast 1v1 winger gets it, or else meet him at once so he has no time and no run-up.',
    '4-3-3', 74, 75, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (F. Luis)', 'steps in aggressively from a central start and heads or clears the long pass'),
    (2, 'Weak-side full back (Juanfran)', 'starts balanced; after each pass moves up to close the gap to his winger and reads the switch'),
    (3, 'Centre backs (Godin, Gimenez)', 'only one forward to mark, so they can let the full backs go wide')
) AS v(so, role, job);

-- 23. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 6: Wide Positioning of the Full Backs to Contest the Opposing Wingers', 'Balanced full backs against two forwards',
    'Against two strikers the full backs hold a more central, balanced spot so they stay near enough to the centre backs to support them. That means a switch to the winger usually reaches him.',
    'Switch of play to a wide midfielder',
    'Full back can''t always intercept, so he closes the receiver straight away to stop him building a 1v1 at speed, while the back line keeps 3v2 in the middle.',
    '4-4-2', 76, 76, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (F. Luis)', 'closes the winger as he takes the switch and limits his time and space'),
    (2, 'Far full back (Juanfran)', 'slides across and back inside so there are 3 defenders against the 2 forwards'),
    (3, 'Centre backs (Godin, Gimenez)', 'mark the two forwards, slightly wider than usual')
) AS v(so, role, job);

-- 24. pp.81-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 6: Wide Positioning of the Full Backs to Contest the Opposing Wingers', 'Full back width depends on the No.10',
    'Against a 4-2-3-1 the full backs read how high the opponent''s No.10 is. A deep 10 frees them to go wide, but a 10 sitting high between the lines pulls them in near the centre backs, as they would play against a 4-4-2.',
    'Position of the opposing No.10 as the ball circulates',
    'Go wide to intercept passes to the wingers only when the centre backs are not exposed to the 10.',
    '4-2-3-1', 81, 81, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (F. Luis, Juanfran)', 'go wide and attack the long ball when the 10 is deep; tuck in near the centre backs when he is high'),
    (2, 'Centre backs', 'handle the lone forward, and the 10 when he pushes up')
) AS v(so, role, job);

-- 25. pp.83-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 7: Controlling the Large Gaps Between the Centre Backs and Full Backs', 'Centre back steps across to advanced No.8',
    'With the full backs wide against a front three, big gaps open between them and the centre backs, and an attacking midfielder can run into one. The centre back on that midfielder''s side slides over to pick him up. The other centre back takes the striker, and the far full back tucks in. If both No.8s push high, the far full back moves toward the strong side to take the more dangerous one.',
    'An opposing attacking midfielder moves into an advanced spot near a CB-FB gap',
    'No free runner in the channel; the back line ends up shaped as it would against two forwards.',
    '4-3-3', 83, 85, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back nearer the advanced midfielder (Gimenez or Godin)', 'shifts across to control him'),
    (2, 'Other centre back', 'slides over and marks the No.9, staying in support'),
    (3, 'Weak-side full back (F. Luis)', 'moves inside to a balanced spot covering his centre back''s blind side; with both 8s high, shifts toward the strong side'),
    (4, 'All defenders', 'keep checking where the attacking midfielders are, not only the ball and their own man')
) AS v(so, role, job);

-- 26. pp.86-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 7: Controlling the Large Gaps Between the Centre Backs and Full Backs', 'Centre backs read the No.10''s height',
    'Against a lone striker plus a No.10, both centre backs concentrate on the striker while the 10 is deep, and the strong-side one keeps watching him. When the 10 pushes up on either side, the nearer centre back moves to him, the other one goes goal-side of the striker, and the weak full back tucks in.',
    'No.10 moves from a deep spot to an advanced one on the weak or strong side',
    'Shut the CB-FB gap and passes behind or blind-side of the centre backs.',
    '4-2-3-1', 86, 88, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearer centre back (Godin weak side / Gimenez strong side)', 'steps a few yards across to control the advanced 10'),
    (2, 'Other centre back', 'takes a goal-side spot on the No.9 and covers passes behind'),
    (3, 'Weak-side full back (F. Luis)', 'moves in to a balanced spot to close the gap and cover the blind side; fills the gap himself if the centre backs are late'),
    (4, 'Strong-side full back (Juanfran)', 'stays with the winger')
) AS v(so, role, job);

-- 27. pp.89-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 7: Controlling the Large Gaps Between the Centre Backs and Full Backs', 'Open-body full back cuts pass into gap',
    'The strong-side full back stands side-on so he can see his centre back, the space between them and the attacking midfielder. When the ball carrier shapes to slip the midfielder into that gap, the full back steps inside and cuts the pass out.',
    'Midfielder runs into the CB-FB gap and the passer looks to find him',
    'Win the ball in the channel; eye contact across the line also keeps the four defenders moving up and down together.',
    NULL, 89, 91, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side full back (Juanfran)', 'open body shape and wide view; slides in to intercept'),
    (2, 'Nearest centre back (Gimenez)', 'his position, and the gap it leaves, is what the full back reads'),
    (3, 'Back four', 'keep eye contact and step forward or drop together')
) AS v(so, role, job);

-- 28. pp.90-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 7: Controlling the Large Gaps Between the Centre Backs and Full Backs', 'Full back holds runner until centre back arrives',
    'When a No.10 runs into the gap and the centre back is too far off, the full back moves inside and marks him for the moment. Once the centre back takes over, the full back goes back out and presses the winger.',
    'No.10 runs into the gap before the centre back is close',
    'The more dangerous central runner is never left free, and the winger is still pressed once the handover is done.',
    NULL, 90, 91, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side full back (Juanfran)', 'marks the 10 for a moment, then presses the winger on the pass out wide'),
    (2, 'Strong-side centre back (Gimenez)', 'comes across and takes over the 10'),
    (3, 'Weak-side full back (F. Luis)', 'stays close to the weak-side centre back (Godin)')
) AS v(so, role, job);

-- 29. pp.99-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 8: Positioning and Defensive Movements of the Front Block', 'Front block narrows lanes to central zone',
    'The two forwards and four midfielders guard the key space between Atletico''s midfield and back lines. One forward presses the ball-carrying centre back while the other sits between the second centre back and the through lane. The midfielders stay as close together as the carrier''s distance requires.',
    'Opposing centre back has the ball in the middle',
    'Keep through-pass lanes so narrow that a pass into the zone in front of the back line is almost impossible, and force centre backs to pass from far away.',
    NULL, 99, 101, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing forward (Griezmann)', 'closes the ball-carrying centre back'),
    (2, 'Second forward (Torres)', 'balanced spot screening the other centre back and the through lane'),
    (3, 'Midfield four', 'compact side to side; the farther the ball, the wider they may stand'),
    (4, 'Front block', 'keeps a safe distance from the carrier so no one gets beaten')
) AS v(so, role, job);

-- 30. pp.101-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 8: Positioning and Defensive Movements of the Front Block', 'Slide to touchline, close inside lane',
    'When the ball goes out to the full back near the touchline, the whole block slides toward it. The nearest central midfielder shuts the pass inside to the key zone, and the ball down the line is left on purpose for the rear block to deal with.',
    'Pass to the opposing full back near the touchline',
    'Leave only the forward pass down the line, which the back four is set up to handle.',
    NULL, 101, 101, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side central midfielder (Gabi)', 'narrows the lane into the key central zone'),
    (2, 'All front-block players', 'shift across after the pass'),
    (3, 'Rear block', 'takes care of the down-the-line ball')
) AS v(so, role, job);

-- 31. pp.102-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 8: Positioning and Defensive Movements of the Front Block', 'Midfielder steps up on opposing No.8',
    'If the gap between Atletico''s forward and midfield lines lets an opposing central midfielder receive and turn, the nearest Atletico midfielder moves forward a few yards. When the opponent is already close or can''t get a pass, nobody steps.',
    'Opposing central midfielder is free to take a pass from his centre back with room to turn',
    'Keep the space between the lines small so a midfielder who receives there is pressed at once.',
    NULL, 102, 105, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest central midfielder (Gabi)', 'steps forward a few yards to cover the receiver'),
    (2, 'Other midfielders', 'keep their compact line')
) AS v(so, role, job);

-- 32. pp.104-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 8: Positioning and Defensive Movements of the Front Block', 'Press the receiving midfielder, forwards collapse',
    'When a pass reaches an opposing central midfielder in his own half, the nearest Atletico central midfielder presses him from behind so he can''t turn. Both forwards drop toward the ball to squeeze his room and wait for a heavy touch.',
    'Pass played into an opposing central midfielder',
    'Stop him turning and win the ball from a loose first touch.',
    NULL, 104, 104, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest central midfielder (Gabi or Saul)', 'presses the receiver and blocks the turn'),
    (2, 'Front two (Griezmann, Torres)', 'drop toward the ball area, close space, ready to intercept')
) AS v(so, role, job);

-- 33. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 8: Positioning and Defensive Movements of the Front Block', 'Forwards take a dropping midfielder',
    'An opposing midfielder sometimes drops between the Atletico forwards and midfielders to get away from his marker, which takes him into the forwards'' zone. The forwards watch him before the pass, and once the ball goes to him both forwards close him down.',
    'Opposing central midfielder drops in front of the Atletico midfield and is passed to',
    'He gets no free touch, and the midfielders don''t have to leave their line.',
    NULL, 106, 106, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards (Torres, Griezmann)', 'keep scanning around them; both press the dropped midfielder when he receives'),
    (2, 'Central midfielder (Saul)', 'holds his line once the forwards take over')
) AS v(so, role, job);

-- 34. pp.107-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 8: Positioning and Defensive Movements of the Front Block', 'Forward screens inside pass from full back',
    'With the ball at the full back near the touchline, the wide midfielder presses him and shuts the route inside. The strong-side forward drops back and across to cover the opposing central midfielder. If that midfielder pushes up away from the forward, the nearest Atletico central midfielder closes him as the pass arrives.',
    'Opposing full back has the ball wide and looks inside to the central midfielder',
    'Intercept the inside pass or press the receiver at once, so nothing gets into the space between the lines.',
    NULL, 107, 109, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Koke)', 'presses the full back and blocks the path inside'),
    (2, 'Strong-side forward (Griezmann)', 'drops back and across, cuts or intercepts the pass to the central midfielder'),
    (3, 'Nearest central midfielder (Gabi)', 'closes the midfielder if he moves up away from the forward'),
    (4, 'Front block', 'keeps the space between the lines small')
) AS v(so, role, job);

-- 35. pp.110-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 8: Positioning and Defensive Movements of the Front Block', 'Drop and converge when centre back dribbles',
    'If an opposing centre back gets past the first forward and carries the ball forward, the midfielders drop together to keep a safe distance and close up. The second forward drops back toward the ball to make a strong side.',
    'Opposing centre back beats the forward''s press and carries forward',
    'Midfielders get time to step in and cut out the through pass, and the attack becomes easy to read.',
    NULL, 110, 111, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield four (Koke, Gabi, Saul, wide mid)', 'drop back as one, keep a safe distance, close the gaps'),
    (2, 'Nearest midfielders (Koke, Gabi)', 'come together to block and intercept the through pass'),
    (3, 'Second forward (Torres)', 'drops back and across to the ball area to make the strong side')
) AS v(so, role, job);

-- 36. pp.112-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 8: Positioning and Defensive Movements of the Front Block', 'Triangle on carrier forces ball wide',
    'If the centre back keeps coming forward, the nearest central midfielder steps out to close him, but only once the midfield is compact, so a defensive triangle forms. A forward blocks the switch, which leaves only the pass to the full back, and the whole block then slides toward the touchline.',
    'Advancing centre back gets near the midfield line',
    'Push the play toward the touchline and gain time to reorganise.',
    NULL, 112, 112, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest central midfielder (Gabi)', 'steps out to close the carrier'),
    (2, 'Forward (Torres)', 'cuts off the switch of play'),
    (3, 'Front block', 'slides to the ball side after the pass goes wide')
) AS v(so, role, job);

-- 37. pp.119-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 9: Rear Block''s Positioning and Movements to Control Wide Areas', 'Allow the least dangerous forward passes',
    'A compact midfield leaves room out wide. Atletico let the opponent play square between centre backs, or forward to full backs and wingers near the touchline. Once the full back has the ball, about the only forward option left is the pass down the line to the winger.',
    'Opponent builds with centre back or full back on the ball',
    'Every forward pass goes to a player in a space Atletico have set up to defend.',
    NULL, 119, 121, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards (Griezmann, D. Costa)', 'control the centre backs'),
    (2, 'Midfielders', 'stay narrow and keep through lanes shut'),
    (3, 'Whole team', 'shifts slightly across when the ball goes to the full back')
) AS v(so, role, job);

-- 38. pp.122-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 9: Rear Block''s Positioning and Movements to Control Wide Areas', 'Rear block shape: compact mids, wide FBs',
    'In the 4-4-2 the rear block is the midfield four plus the back four. The midfielders stay compact to block the key central zone, the defenders stay on players in their zones, and the full backs sit wide. That leaves only long balls, which suit the defenders. The wide midfielders keep looking at the touchline space.',
    'Opponent''s centre back or deep midfielder on the ball, full back pushing on',
    'Force play out wide, then defend the touchline area with full back and wide midfielder working together.',
    NULL, 122, 124, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielders (Koke 6, Saul 8)', 'keep scanning the space near the touchline'),
    (2, 'Full backs (F. Luis, Juanfran)', 'stand wide to control wingers'),
    (3, 'Central midfielders', 'block passes to the central zone'),
    (4, 'Centre backs', 'handle long balls to the forwards')
) AS v(so, role, job);

-- 39. pp.125-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 9: Rear Block''s Positioning and Movements to Control Wide Areas', 'Split touchline lane: high and low',
    'The midfield and back lines stay about 12 yards apart, and the lane by the touchline is split into a high strip and a low strip of about 6 yards each. The wide midfielder takes the opposing full back in the high strip and the full back takes him in the low one. When the winger comes inside, the full back holds his zone and doesn''t follow.',
    'Opposing full back overlaps while the winger moves inside',
    'Clear handover of the overlapping full back; the winger moving inside meets the compact midfield.',
    NULL, 125, 126, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Koke)', 'owns the opposing full back while he is in the high strip; checks winger and full back movements'),
    (2, 'Full back (F. Luis)', 'owns the low strip; does not chase the winger inside')
) AS v(so, role, job);

-- 40. pp.127-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 9: Rear Block''s Positioning and Movements to Control Wide Areas', 'Close the full back who receives',
    'If the opposing full back takes the ball in the high strip, the wide midfielder closes him and blocks the pass inside, and the rest drop a few yards and slide over. If he receives further up the pitch, the Atletico full back closes him instead.',
    'Pass reaches the opposing full back in the high or low strip',
    'The full back has no time to look forward and usually has to shield the ball and play back.',
    NULL, 127, 127, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Koke)', 'closes the full back in the high strip and cuts the lane into the central zone'),
    (2, 'Full back (F. Luis)', 'intercepts or closes the full back once he is high'),
    (3, 'Rest of rear block', 'drop back a few yards and shift across')
) AS v(so, role, job);

-- 41. pp.128-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 9: Rear Block''s Positioning and Movements to Control Wide Areas', 'Wide full backs leave only space behind wingers',
    'Against a front three the full backs sit very wide, so the free space near the touchline is behind the wingers rather than in front of them. A winger can only take a long ball easily by dropping off.',
    'Centre back looks for a long pass out to a winger',
    'Wingers have to come short to receive, away from goal.',
    '4-3-3', 128, 128, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (F. Luis, Juanfran)', 'very wide, level with or goal-side of the wingers'),
    (2, 'Midfield four', 'compact in front of the back line')
) AS v(so, role, job);

-- 42. pp.129-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 9: Rear Block''s Positioning and Movements to Control Wide Areas', 'Ball-side full back nearer his winger',
    'Against two forwards the centre backs spread a little and the full backs come narrower. The full back on the ball side still stands closer to his winger than the far one does, because a pass from close by gives him less time to react.',
    'Centre back on the ball on one side',
    'Full backs stay connected to the centre backs and can still reach the long ball to the winger.',
    '4-4-2', 129, 129, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (F. Luis)', 'nearer his winger'),
    (2, 'Far full back (Juanfran)', 'a little farther from his winger'),
    (3, 'Centre backs (Godin, Gimenez)', 'slightly wider to control both forwards')
) AS v(so, role, job);

-- 43. pp.130-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 9: Rear Block''s Positioning and Movements to Control Wide Areas', 'Long ball to winger: intercept or smother',
    'On a long ball to a winger, the full back intercepts it if he can. Otherwise he gets tight so the winger can''t lift his head, while the wide midfielder on that side drops in to shut the inside pass to the No.10.',
    'Long pass from a centre back to the winger',
    'Win the ball, or leave the winger with no good forward or inside option.',
    NULL, 130, 130, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (Juanfran)', 'intercepts the long ball, or restricts the winger''s time and space'),
    (2, 'Ball-side wide midfielder (Saul)', 'drops back to narrow the inside lane to the No.10'),
    (3, 'Rest of team', 'adjust positions toward the ball')
) AS v(so, role, job);

-- 44. pp.131-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 9: Rear Block''s Positioning and Movements to Control Wide Areas', 'Winger drops: wide midfielder closes him',
    'When a winger drops off to find space, the wide midfielder closes him and the full back holds his zone near the other defenders, keeping the inside lane shut. If the No.10 then runs in behind, the full back, standing side-on, spots it and drops to block the pass between himself and the centre back.',
    'Winger comes short to receive; No.10 may run in behind',
    'The winger can only go down the line or back, and the run in behind is covered.',
    NULL, 131, 131, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Saul)', 'closes the dropping winger'),
    (2, 'Full back (Juanfran)', 'stays in his zone, open body; drops to block a through ball to the No.10 between him and the centre back'),
    (3, 'Nearest centre back (Gimenez)', 'keeps the pass behind covered with the full back')
) AS v(so, role, job);

-- 45. pp.136-143
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 10: Rear Block Controlling Passes within Wide Areas', 'Full back starting spot and timed press on winger',
    'The opposing full back has the ball near the touchline. Atletico''s strong-side full back stands a little higher than the other three defenders and about 12 yards from his wide midfielder, so he stays connected to the line and his zone. If he starts too high, the attacking midfielder (or the No.10 / second striker) runs into the space behind him and the back line is left 3v3.',
    'Ball played from the opposing full back to the winger, who is high in the full back''s zone',
    'The full back closes down while the pass travels and stops the winger turning, or at least keeps his head down so he has to pass backwards.',
    '4-3-3', 136, 143, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side full back (Juanfran)', 'Start slightly higher than the line; move as the pass is played if within about 6 yards of the winger; stop the turn'),
    (2, 'Wide midfielder (Correa)', 'Keep checking the winger''s position; stay within 12 yards of the full back; allow only backward passes or the pass down the line'),
    (3, 'Ball-side centre back (Gimenez)', 'Stay connected; too far from the strong side if the full back is high, which is the danger case'),
    (4, 'Rest of back four', 'Stay level, slightly deeper than the strong-side full back')
) AS v(so, role, job);

-- 46. pp.139-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 10: Rear Block Controlling Passes within Wide Areas', 'Full back reads and intercepts ball behind him',
    'The opposing full back tries a long ball into the space behind Atletico''s full back for the attacking midfielder''s forward run. A full back who starts close to his centre back, with an open body shape, sees the run coming.',
    'Attacking midfielder starts a forward run behind the full back; long pass from the opposing full back',
    'The full back drops off and intercepts. If the ball still gets through, he recovers at once to support the centre back who tracked the runner, so the line keeps 4 defenders against 3 attackers.',
    '4-3-3', 139, 140, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side full back (Juanfran)', 'Drop back early and cut out the pass; if it beats him, recover inside to support'),
    (2, 'Ball-side centre back (Gimenez)', 'Track the attacking midfielder''s run'),
    (3, 'Other centre back and far full back (Godin, F. Luis)', 'Drop toward goal and pick up the remaining runners')
) AS v(so, role, job);

-- 47. pp.144-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 10: Rear Block Controlling Passes within Wide Areas', 'Winger drops deep, wide midfielder takes him',
    'The winger comes short, more than about 6 yards away from the full back, to escape his marker. The full back would be too late to stop him turning, and chasing him would open space behind.',
    'Winger drops into the wide midfielder''s (deeper) band and receives',
    'Marking passes to the wide midfielder, who closes him down while blocking the inside pass. The full back holds a deep position to deny the run behind.',
    '4-3-3', 144, 145, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Correa)', 'Close down the receiver with a body shape that blocks passes inside (to the No.10 and No.9)'),
    (2, 'Full back (Juanfran)', 'Stay in his zone, deep, guarding the pass in behind to the No.10'),
    (3, 'Central midfielders', 'Shift across toward the ball side')
) AS v(so, role, job);

-- 48. pp.146-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 10: Rear Block Controlling Passes within Wide Areas', 'Double or triple team near the touchline',
    'Atletico''s trademark wide trap: the opponent is pushed out, and a short pass from full back to winger near the line is pressed by two wide players at once. Three conditions: full back and wide midfielder no more than 12 yards apart, both moving the moment the pass is struck, and the rear block keeping 12 yards between its lines.',
    'Short pass to a winger near the touchline',
    'The receiver has no time or space. The strong-side central midfielder screens inside, which makes it a triple team, and the ball is won.',
    '4-3-3', 146, 147, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Juanfran)', 'Close the receiver from behind and outside'),
    (2, 'Wide midfielder (Correa)', 'Close the receiver from in front and inside at the same moment'),
    (3, 'Strong-side central midfielder (Saul)', 'Block the pass into the Crucial Central Area / No.10; be ready to tackle if the winger dribbles inside'),
    (4, 'Rear block', 'Keep the 12-yard gap between lines so the inside lane stays closed')
) AS v(so, role, job);

-- 49. pp.154-157
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 11: Rear Block''s Reaction After the Extensive Shift of the Centre Back', 'Centre back tracks wide runner, holding midfielder fills',
    'The full back is busy with the winger, and the opposing attacking midfielder runs behind him toward the touchline. The ball-side centre back follows him out wide, which opens a gap in the middle of the back line (a possible 2v2 in the box from a cross).',
    'Ball played in behind the full back for the attacking midfielder; centre back follows him to the touchline',
    'The deepest central midfielder drops into the hole so three defenders stay in the box with a numerical edge. If the full back is already deep enough, he covers the centre back instead and the midfielder can stay.',
    '4-3-3', 154, 157, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (Gimenez)', 'Track the attacking midfielder all the way out wide'),
    (2, 'Deepest central midfielder (Gabi)', 'Drop into the centre-back gap in time'),
    (3, 'Other central and wide midfielders (Saul, Koke)', 'Drop back and inside to collect second balls after a clearance'),
    (4, 'Strong-side full back (Juanfran)', 'If not tied to the winger and deep enough, cover the centre back''s shift himself')
) AS v(so, role, job);

-- 50. pp.156-157
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 11: Rear Block''s Reaction After the Extensive Shift of the Centre Back', 'Centre back follows forward wide v 4-4-2',
    'This is the same gap problem against a front two: one forward slides toward the touchline and runs behind the full back. Against a 4-2-3-1 the No.10 does it.',
    'A forward moves out wide and the ball goes behind the full back',
    'The centre back tracks the forward and the deepest central midfielder fills the central gap. This also covers the gap that can open on the weak side between full back and centre back.',
    '4-4-2', 156, 157, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (Gimenez)', 'Follow the forward toward the touchline'),
    (2, 'Deepest central midfielder (Gabi)', 'Drop into the hole in the back line'),
    (3, 'Full back', 'Support the centre back when possible')
) AS v(so, role, job);

-- 51. pp.164-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 12: Rear Block''s Defensive Reactions After Wide Players Receive', 'Midfielder tracks attacking midfielder behind full back',
    'The winger gets time near the touchline to turn or half-turn. Both centre backs are fixed on the No.9, so the space between the centre back and full back is big, and the attacking midfielder runs from deep to exploit it.',
    'Pass to the winger with time to turn, plus a forward run by the attacking midfielder',
    'The strong-side central midfielder tracks the runner into the space behind the full back. When the centre back has shifted across he hands the runner over and supports the full back, and the other midfielders slide over to make 2v1 around the ball.',
    '4-3-3', 164, 166, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side central midfielder (Thomas)', 'Track the No.10''s run until the centre back can take over, then support the full back from inside'),
    (2, 'Ball-side centre back (Gimenez)', 'Shift across in time to take over the runner'),
    (3, 'Weak-side central midfielder (Rodri)', 'Shift over to support the full back (2v1); drop to fill any gap the centre back leaves'),
    (4, 'Left midfielder (Koke)', 'Shift to the strong side for balance'),
    (5, 'Full back (Juanfran)', 'If he stops the winger turning, the midfielder need not track; he just supports')
) AS v(so, role, job);

-- 52. pp.167-169
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 12: Rear Block''s Defensive Reactions After Wide Players Receive', 'Compact lines shut inside pass from wide',
    'The opposing full back stands about 6 yards from both Atletico wide players, between them, and can receive and turn. Atletico''s full back sees he cannot get there in time, so he passes the marking to the wide midfielder and stays in his zone.',
    'Pass to the opposing full back positioned between Atletico''s full back and wide midfielder',
    'Both lines drop back together, close enough that the inside lane is shut or very narrow. If the pass inside is tried, the full back and strong-side midfielder step in to intercept or trap the winger in a double team.',
    '4-2-3-1', 167, 169, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Juanfran)', 'Hold the zone; step in to block the inside pass to the winger'),
    (2, 'Wide midfielder (Saul)', 'Take over the opposing full back on the ball'),
    (3, 'Strong-side central midfielder (Thomas)', 'Close the inside lane together with the full back'),
    (4, 'Both lines', 'Drop collectively and stay within about 12 yards of each other')
) AS v(so, role, job);

-- 53. pp.170-172
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 12: Rear Block''s Defensive Reactions After Wide Players Receive', 'Chain reaction: centre back takes inverted winger',
    'The opposing winger comes inside for a through ball while their full back pushes high into the advanced band. The strong-side centre back is close to the full back, so marking can slide along the line.',
    'Pass to the advanced opposing full back, with the winger inside',
    'The full back presses the ball, the wide midfielder doubles, and the centre back takes the winger. The weak-side central midfielder drops into the centre-back slot, which gives a double team and tight marking all around the ball.',
    '4-2-3-1', 170, 172, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (F. Luis)', 'Take the advanced full back and press as the pass arrives'),
    (2, 'Wide midfielder (Koke)', 'Drop to double the ball carrier'),
    (3, 'Strong-side centre back (Godin)', 'Pick up the inside winger; follow him if he runs in behind the full back'),
    (4, 'Weak-side central midfielder (Thomas)', 'Drop between the centre backs to fill the gap'),
    (5, 'Strong-side central midfielder (Rodri)', 'Help double the winger if he receives inside')
) AS v(so, role, job);

-- 54. pp.173-175
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 12: Rear Block''s Defensive Reactions After Wide Players Receive', 'Full back plays for time until centre back arrives',
    'The same set-up, but the strong-side centre back is too far away because he is tied to the No.9, so he cannot take the inside winger straight away.',
    'Pass to the advanced opposing full back while the centre back is far from the strong side',
    'The full back does not jump. He stays near his defenders and guards the winger and the run behind while the wide midfielder presses. Once the centre back has shifted across, the full back steps out to close the ball, and the weak-side central midfielder covers the centre-back gap.',
    '4-2-3-1', 173, 175, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (F. Luis)', 'Hold position, delay, track the winger''s run behind; press only when the centre back takes over'),
    (2, 'Wide midfielder (Koke)', 'Close down the ball carrier, then double'),
    (3, 'Strong-side centre back (Godin)', 'Shift across to take over the winger'),
    (4, 'Weak-side central midfielder (Thomas)', 'Be ready to fill the gap if the centre back goes wide')
) AS v(so, role, job);

-- 55. pp.176-177
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 12: Rear Block''s Defensive Reactions After Wide Players Receive', 'Inverted winger high: centre back presses, midfielder doubles',
    'The winger moves inside and receives a through pass in the advanced band (the lower 6 yards between the lines). The centre back is close to the strong side, and the full back looks after the overlapping full back.',
    'Through pass to the inside winger in the advanced band, with the centre back close',
    'The centre back presses to stop the turn and the deepest central midfielder doubles from inside. Passes to the No.9, No.10 and the far winger are cut off.',
    '4-2-3-1', 176, 177, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side centre back (Godin)', 'Step out and press, body shape preventing the inside turn'),
    (2, 'Deepest central midfielder (Thomas)', 'Double from inside; block the turn toward the Crucial Central Area'),
    (3, 'Full back (F. Luis)', 'Mark the advanced opposing full back')
) AS v(so, role, job);

-- 56. pp.178-178
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 12: Rear Block''s Defensive Reactions After Wide Players Receive', 'Inverted winger deep: midfielders close him',
    'The inside winger receives in the deep band (the upper 6 yards, the midfield''s zone). The centre back may have shifted, but he does not mark at that depth.',
    'Pass to the inside winger in the deep band',
    'Wide midfielder and strong-side central midfielder close him at once, and the weak-side central midfielder blocks his dribble or pass into the middle.',
    '4-2-3-1', 178, 178, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Koke)', 'Close down the winger'),
    (2, 'Strong-side central midfielder (Rodri)', 'Close down with the wide midfielder (double team)'),
    (3, 'Weak-side central midfielder (Thomas)', 'Block the route into the Crucial Central Area where the No.9 and No.10 wait'),
    (4, 'Strong-side centre back (Godin)', 'Shift toward the strong side but leave the marking to the midfielders')
) AS v(so, role, job);

-- 57. pp.179-181
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 12: Rear Block''s Defensive Reactions After Wide Players Receive', 'Winger turns and dribbles: drop and squeeze',
    'The winger gets between the lines and turns and dribbles forward, either from the deep band or because the centre back was too far away to take him in the advanced band.',
    'Winger receives and turns facing goal (open ball)',
    'The defenders drop and compact to buy time while the midfielders chase and close him. The weak-side midfielder blocks the middle, so the only outlet is the full back out wide. The centre back steps out only if the winger reaches shooting range, with the midfielder doubling and the defenders forming a triangle behind.',
    '4-2-3-1', 179, 181, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Drop back together, keep compact, form a covering triangle'),
    (2, 'Wide and strong-side midfielders (Koke, Rodri)', 'Track the dribbler and close him'),
    (3, 'Weak-side central midfielder (Thomas)', 'Block the dribble or pass into the Crucial Central Area; double from inside'),
    (4, 'Strong-side centre back (Godin)', 'Step out only if the winger reaches shooting range before the midfielder catches him')
) AS v(so, role, job);

-- 58. pp.187-187
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 13: How the Centre Backs Defend the Forwards'' Movements (Rear Block)', 'Win the long ball, triangle behind',
    'The compact block forces opponents to go long over midfield to the forwards. The centre back marking the target stays tight to him.',
    'Long ball toward a forward',
    'The tight centre back gets there first and wins the header, while the far full back and the other centre back form a covering triangle behind him.',
    NULL, 187, 187, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marking centre back (Godin)', 'Stay touch-tight to the forward and win the aerial duel'),
    (2, 'Other centre back (Gimenez)', 'Drop into cover as one corner of the triangle'),
    (3, 'Near full back (F. Luis)', 'Tuck in to complete the triangle')
) AS v(so, role, job);

-- 59. pp.188-188
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 13: How the Centre Backs Defend the Forwards'' Movements (Rear Block)', 'Own the Crucial Central Area by bands',
    'This is the base rule for through balls between the lines: the gap from the centre backs to the highest central midfielder stays at or under 12 yards and is split into two 6-yard bands, which can stretch 1-2 yards in a match. Whoever enters the upper band belongs to the midfielders; whoever enters the lower band belongs to the defenders.',
    'Through pass played into the space between the lines',
    'Nobody can receive unmarked and turn in front of the box. The weak-side central midfielder drops to shrink the space, make double teams easier and fill gaps in the line.',
    NULL, 188, 188, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (Gabi)', 'Close down anyone receiving in the upper band'),
    (2, 'Centre backs', 'Close down anyone receiving in the lower band'),
    (3, 'Weak-side central midfielder (Saul)', 'Sit deeper to restrict the space, help double, fill gaps')
) AS v(so, role, job);

-- 60. pp.189-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 13: How the Centre Backs Defend the Forwards'' Movements (Rear Block)', 'Forward drops: centre back steps up only 2-3 yards',
    'An opposing midfielder has turned with an open lane to the forward, who drops between the lines. Following him all the way would open space behind for the No.10, who is the threat against a 4-2-3-1; against a 4-3-3 or 4-4-2 it would be a midfielder or the second striker. If the forward cannot be found, the centre backs do not follow him at all.',
    'Forward drops to receive and a passing lane to him is open',
    'The nearest centre back steps up just 2-3 yards to stay in contact without leaving a hole. The weak-side central midfielder, sitting deeper, guards the space between the lines.',
    '4-2-3-1', 189, 190, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest centre back (Godin)', 'Step up 2-3 yards to a balanced position covering both the No.9 and the space behind'),
    (2, 'Weak-side central midfielder (Saul)', 'Sit deep and control the space between the lines')
) AS v(so, role, job);

-- 61. pp.190-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 13: How the Centre Backs Defend the Forwards'' Movements (Rear Block)', 'Centre back presses dropping forward, midfielder doubles',
    'The ball is actually played into the dropping forward''s feet.',
    'Pass to the forward who has dropped',
    'The centre back jumps tight to stop the turn and the weak-side midfielder doubles, blocking the turn inside and the lay-off to the No.10. The forward can only go wide, where he is less dangerous. The other two defenders form a triangle behind.',
    '4-2-3-1', 190, 190, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest centre back (Godin)', 'Press tight, prevent the turn'),
    (2, 'Weak-side central midfielder (Saul)', 'Double from inside; block the pass to the No.10'),
    (3, 'Other centre back and full back (Gimenez, F. Luis)', 'Form a support and cover triangle')
) AS v(so, role, job);

-- 62. pp.191-191
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 13: How the Centre Backs Defend the Forwards'' Movements (Rear Block)', 'Chipped ball behind stepping centre back',
    'The opposing central midfielder tries a lofted pass over the centre back who has stepped up.',
    'Aerial pass in behind the centre back',
    'Because he only stepped up a little, the centre back can turn and drop to win the ball. If he cannot get there, he is still close enough to recover beside the other defenders and stop a dangerous chance.',
    '4-2-3-1', 191, 191, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Stepping centre back (Godin)', 'Drop back immediately; intercept, or recover into a supporting position'),
    (2, 'Other defenders', 'Hold close spacing so the recovering centre back can rejoin')
) AS v(so, role, job);

-- 63. pp.192-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 13: How the Centre Backs Defend the Forwards'' Movements (Rear Block)', 'Forward drops deeper: follow or hand over',
    'The forward keeps dropping. If nobody is placed to use the space behind (the No.10 is far away), the centre back can follow him even into the upper band. If he drops as deep as the midfield line, the midfielders take him.',
    'Forward drops deep with no runner threatening behind, or drops right into the midfield zone',
    'The forward is marked at whatever depth he goes, without leaving a free runner behind. When the midfielders take over, the centre back recovers to his starting spot.',
    '4-2-3-1', 192, 192, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Godin)', 'Follow into the deeper band if no threat behind; otherwise pass him on and recover to his start position'),
    (2, 'Central midfielders', 'Close down the forward as soon as he receives in their zone')
) AS v(so, role, job);

-- 64. pp.197-199
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 14: Pressing High Up the Pitch (from the Goalkeeper)', 'High press on GK: curve to make strong side',
    'The opponent restarts from the GK against Atletico''s 4-4-2. Atletico are 2v3 up front because the GK is spare, 2v3 in central midfield, 2v1 at centre back and 1v1 in each wide pair. One forward bends his run to shut off one centre back and push play to the other side.',
    'Opposing GK has the ball for build-up',
    'Play is pushed to one side and the team shifts so they have more players where the next pass must go. Every long option from the GK is covered by players in balanced positions who have time to react.',
    '4-3-3', 197, 199, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (D. Costa)', 'Curve the run and use body shape to block the GK''s pass to the far centre back, creating a strong side'),
    (2, 'Other forward (Griezmann)', 'Keep the lane to the defensive midfielder narrow'),
    (3, 'Nearest central midfielder (Rodri)', 'Step up toward the defensive midfielder'),
    (4, 'Left midfielder and central midfielder (Koke, Thomas)', 'Each take a balanced spot controlling two opponents'),
    (5, 'Right midfielder (Saul)', 'Shift in to mark a central midfielder and support, but still watch the far full back and the pass to the far centre back')
) AS v(so, role, job);

-- 65. pp.199-200
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 14: Pressing High Up the Pitch (from the Goalkeeper)', 'Deny and jump the GK-to-pivot pass',
    'The GK''s short pass to the defensive midfielder is the most dangerous option, because a turn to the weak side reaches the free centre back and beats the strong side.',
    'GK looks for, or plays, the pass to the defensive midfielder',
    'The lane is kept so narrow the pass is almost impossible. If it is played, the nearest midfielder closes and stops the turn while both forwards collapse in. The far midfielder steps in to read the pass to the weak-side centre back, which leaves only a risky pass back to the GK.',
    '4-3-3', 199, 200, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest central midfielder (Rodri)', 'Close the defensive midfielder at once and prevent his turn to the weak side'),
    (2, 'Forward (Griezmann)', 'Block the turn toward the strong side'),
    (3, 'Forward (D. Costa)', 'Drop back and narrow the lane to the weak-side centre back'),
    (4, 'Weak-side midfielder (Saul)', 'Push up to narrow that lane further and intercept the pass to the far centre back'),
    (5, 'Central midfielder (Thomas)', 'Hold inside near the attacking midfielder')
) AS v(so, role, job);

-- 66. pp.201-201
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 14: Pressing High Up the Pitch (from the Goalkeeper)', 'Shift after GK plays to centre back',
    'The GK passes short to one centre back. The near forward presses him and does not need to curve, because the strong side already exists. His partner covers the return pass to the GK and the defensive midfielder is in his shadow.',
    'GK''s pass reaches a centre back',
    'With the pivot shut off, the nearest central midfielder slides toward the touchline to outnumber opponents near the ball. The wide midfielder and other midfielders take balanced spots that cover the full back and the attacking midfielder, and the long ball to the winger is easy to cut out.',
    '4-3-3', 201, 201, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near forward (Griezmann)', 'Press the centre back, keep the defensive midfielder in his cover shadow'),
    (2, 'Far forward (D. Costa)', 'Cut the back pass to the GK; pick up the pivot if he moves his way'),
    (3, 'Nearest central midfielder (Rodri)', 'Leave the pivot, shift toward the touchline for an overload'),
    (4, 'Central midfielder (Thomas)', 'Balance between the central midfielder and the attacking midfielder; jump onto the No.10 as the pass goes'),
    (5, 'Wide midfielder (Koke)', 'Balance between the full back and the No.10; do not over-shift wide or the lane to the winger opens')
) AS v(so, role, job);

-- 67. pp.202-202
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 14: Pressing High Up the Pitch (from the Goalkeeper)', 'Trap the No.10 after a through ball',
    'The pressed centre back tries a pass through to the attacking midfielder.',
    'Centre back plays toward the attacking midfielder',
    'The wide midfielder intercepts if he can. If not, he and the central midfielder double the receiver and the other central midfielder drops in, which makes three on one.',
    '4-3-3', 202, 202, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Koke)', 'Intercept; otherwise double the receiver'),
    (2, 'Central midfielder (Thomas)', 'Close the receiver with the wide midfielder'),
    (3, 'Other central midfielder (Rodri)', 'Drop back to make it a triple team')
) AS v(so, role, job);

-- 68. pp.202-202
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 14: Pressing High Up the Pitch (from the Goalkeeper)', 'Press the full back, tight marks around',
    'The centre back passes wide to the full back on the strong side.',
    'Pass to the full back on the strong side',
    'The wide midfielder presses while the ball travels and everyone else shifts across and marks the nearby receivers tightly, which makes about 4v3 at the ball. That is the moment to win it, with many players already up for the counter.',
    '4-3-3', 202, 202, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Koke)', 'Press the full back during the pass'),
    (2, 'Central midfielder (Rodri)', 'Block the route back to the defensive midfielder and add to the overload'),
    (3, 'Rest of team', 'Shift to the strong side; mark the winger, attacking midfielder and centre back tightly')
) AS v(so, role, job);

-- 69. pp.206-206
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 15: Pressing After the Goalkeeper''s Pass', 'Set-up to press the GK''s first pass',
    'Opponent restarts from the GK; Atletico wait for the first pass rather than pressing the keeper. Forwards sit between the centre backs and the deep DM, and one central midfielder steps up behind them.',
    'Opponent GK has the ball in build-up',
    'Make the central option unattractive so the GK plays wide to a centre back, where the press can start.',
    '4-3-3', 206, 206, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two (Griezmann, Torres)', 'Balanced spacing: narrow enough to reach both CBs, wide enough to screen the DM'),
    (2, 'Central midfielder (Gabi)', 'Step forward toward the DM but not so far he loses the opposing No.10'),
    (3, 'Rest of block', 'Stay in shape; if DM drops even deeper the forwards take him')
) AS v(so, role, job);

-- 70. pp.207-211
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 15: Pressing After the Goalkeeper''s Pass', 'Curved run creates strong side on CB',
    'GK passes to a centre back. The near forward closes him with a curved run that cuts off the return to the GK, and the whole block slides to that side.',
    'GK pass to a centre back',
    'Trap the ball on one side with no back pass and no switch available.',
    '4-3-3', 207, 211, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near forward (Griezmann / Torres)', 'Curved run blocking back pass to GK (and DM lane when possible)'),
    (2, 'Far forward', 'Slide across toward ball side to outnumber and pick up DM'),
    (3, 'Ball-side central midfielder (Gabi)', 'Shift over and watch both No.10 and DM, priority No.10'),
    (4, 'Ball-side wide midfielder (Koke / Correa)', 'Shift toward touchline but stay balanced between full back and No.10; block through pass'),
    (5, 'Far central midfielder (Saul)', 'Mark own direct opponent tightly')
) AS v(so, role, job);

-- 71. pp.208-213
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 15: Pressing After the Goalkeeper''s Pass', 'Double-team the DM after an inside pass',
    'When a centre back or full back stuck on the strong side has to play inside to the DM, two players squeeze him at once from front and side while the others block the way back.',
    'Inside pass from CB or full back to the DM',
    'Win the ball centrally close to goal for a short counter, and stop a return pass that would switch play.',
    '4-3-3', 208, 213, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Torres or weak-side Griezmann)', 'Close DM immediately / block the return to GK'),
    (2, 'Central midfielder (Gabi)', 'Second presser on DM, double marking'),
    (3, 'Other forward', 'Block pass back to the centre back'),
    (4, 'Remaining players near ball', 'Tight marks on full back, CM, No.10, winger')
) AS v(so, role, job);

-- 72. pp.209-211
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 15: Pressing After the Goalkeeper''s Pass', 'Second forward waits until strong side exists',
    'If the first forward has not yet sealed off the back pass to the GK, the other forward does not slide; he holds a high, central spot.',
    'First forward not yet blocking the GK return',
    'Keep both the return to the GK and the DM covered until the strong side is real; then slide over.',
    '4-3-3', 209, 211, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Second forward (Torres / Griezmann)', 'Hold a high balanced spot covering GK pass and DM; if DM goes deep, focus on GK'),
    (2, 'Second forward on pass to GK', 'Press the keeper with an angle that pushes play to one side'),
    (3, 'First forward', 'Get into the blocking line; once there the partner drops and slides')
) AS v(so, role, job);

-- 73. pp.210-210
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 15: Pressing After the Goalkeeper''s Pass', 'Forward''s body shape steers GK to chosen side',
    'With the CM already marking the DM, the forward can push up and use his angle and body shape to make the GK pass to the side Atletico want, where every receiver can be tightly marked.',
    'GK on the ball, DM already picked up by CM',
    'Send build-up to the side where the press matches up best man-for-man.',
    '4-3-3', 210, 210, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Gabi)', 'Advance to mark the DM and tell the forward'),
    (2, 'Forward (Griezmann)', 'Higher position, curved body shape forcing pass to the other CB'),
    (3, 'Far-side central midfielder (Saul)', 'Closer to his opponent so receivers on that side are tight')
) AS v(so, role, job);

-- 74. pp.211-212
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 15: Pressing After the Goalkeeper''s Pass', 'Wide midfielder jumps the full back on the pass',
    'After the CB receives, the ball-side wide midfielder stays in a middle position; on a through ball he and the CM cut it out, on a pass to the full back he sprints while the ball travels.',
    'CB considers a through pass, or passes to the full back',
    'Lock the full back down with all nearby options marked (3v3) so only the inside pass to the DM remains, which is then double-teamed.',
    '4-3-3', 211, 212, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side wide midfielder (Correa)', 'Balanced, not too wide; press the full back during the ball''s travel'),
    (2, 'Ball-side central midfielder (Saul)', 'With the wide man, intercept a through pass'),
    (3, 'Defenders around ball', 'Tight marks on winger and No.8'),
    (4, 'Gabi + Griezmann', 'Wait to squeeze the DM if he gets the inside ball')
) AS v(so, role, job);

-- 75. pp.214-215
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 15: Pressing After the Goalkeeper''s Pass', 'DM drops into a back three',
    'The opposing DM drops between the centre backs to build 3+GK v 2. The forwards take over responsibility for him; the CM retreats a few yards but stays higher than his partner. When the ball goes to a centre back, the near forward cuts off GK and DM, removing the overload.',
    'Opposing DM drops between the CBs',
    'Neutralise the build-up overload without pulling midfielders out of the block.',
    '4-3-3', 214, 215, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two', 'Own the deep DM; near forward blocks the GK and DM lanes once a CB receives'),
    (2, 'Other forward', 'Slide toward the strong side once partner blocks'),
    (3, 'Central midfielder (Gabi)', 'Drop a few yards, still higher than Saul'),
    (4, 'Midfield line', 'Slide to the strong side as in normal press')
) AS v(so, role, job);

-- 76. pp.215-216
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 15: Pressing After the Goalkeeper''s Pass', 'Deep DM forced to one side, then CB trapped',
    'When the GK finds the very deep DM, one forward presses him to make him play to one side; the other drops toward the centre ready to jump the only remaining outlet, a centre back.',
    'GK pass to the deep DM',
    'Make the build-up predictable and channel it into a prepared trap on one CB.',
    '4-3-3', 215, 216, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing forward (Torres)', 'Angle the press to force play one way'),
    (2, 'Other forward (Griezmann)', 'Drop back and in, then close the CB who receives; seal GK return'),
    (3, 'First forward after CB receives', 'Drop back toward strong side, cover DM; stay high if GK pass still possible')
) AS v(so, role, job);

-- 77. pp.216-217
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 15: Pressing After the Goalkeeper''s Pass', 'Strong-side CM''s two jobs vs wide CB',
    'When the wide centre back receives after the deep DM''s pass, the opponent''s full back pushes on, the winger comes inside and the No.10 drops. The strong-side CM must cut off the through ball to the winger and stop the No.10 receiving and turning; a pass into No.10 is double-teamed.',
    'Ball with the wide centre back; full back advances, winger tucks in, No.10 drops',
    'Prevent a 2v1 against the left back and smother the No.10.',
    '4-3-3', 216, 217, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side central midfielder (Gabi)', 'Block through pass to the winger and control the No.10'),
    (2, 'Wide midfielder (Koke)', 'With Gabi, react to and block a through pass to the winger'),
    (3, 'Forward (Griezmann)', 'Close down the CB'),
    (4, 'Two nearest players on pass to No.10', 'Close him at once, stop him turning, force a bad touch')
) AS v(so, role, job);

-- 78. pp.218-219
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 15: Pressing After the Goalkeeper''s Pass', 'Man-for-man press vs a rigid 4-4-2',
    'Against an unchanged 4-4-2 the shapes mirror, giving 1v1s everywhere except 2v3 at the top due to the GK. After the GK''s pass to a CB, each player focuses on his direct opponent.',
    'GK pass to a centre back',
    'Easy press: players match up and keep through lanes shut.',
    '4-4-2', 218, 219, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near forward (Griezmann)', 'Curved run onto the CB, cut GK return'),
    (2, 'Strong-side CM (Gabi)', 'Slide over to mark the opposing CM'),
    (3, 'Strong-side wide midfielder (Koke)', 'Ready to jump the full back'),
    (4, 'Gabi + Koke', 'Keep through lanes to winger / forward narrow'),
    (5, 'Weak-side forward (Torres)', 'Drop and slide to the strong side for an extra man')
) AS v(so, role, job);

-- 79. pp.220-220
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 15: Pressing After the Goalkeeper''s Pass', 'Press vs 4-2-3-1 like vs 4-4-2',
    'The 4-2-3-1 has a 3v2 in midfield through its No.10, but he can''t be a direct option for the GK or CBs, so the press works the same as against the 4-4-2. Only if a CM drops does the press adjust.',
    'GK pass to a centre back',
    'Ignore the midfield overload where it can''t hurt; adjust only to a shape change.',
    '4-2-3-1', 220, 220, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two', 'Same as vs 4-4-2: strong side on CB'),
    (2, 'Central midfielders', 'Mark direct opponents; No.10 not a direct GK/CB option'),
    (3, 'All', 'Re-adjust if a central midfielder drops deeper')
) AS v(so, role, job);

-- 80. pp.221-221
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 15: Pressing After the Goalkeeper''s Pass', 'Opposing CM drops deep vs 4-4-2',
    'One opposing CM drops low to outnumber the press. The nearest Atletico CM follows him forward, leaving his partner 1v1 in the middle, but this frees a central pocket the winger or forward can drop into as a new option for the CB.',
    'Opposing central midfielder drops into a deep position',
    'Keep the dropping CM marked while preparing to handle whoever fills the vacated space.',
    '4-4-2', 221, 221, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest central midfielder (Gabi)', 'Step up to control the dropping CM'),
    (2, 'Other central midfielder (Saul)', '1v1 with the remaining CM'),
    (3, 'Rest of block', 'Watch the freed pocket for winger / forward')
) AS v(so, role, job);

-- 81. pp.222-222
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 15: Pressing After the Goalkeeper''s Pass', 'Winger fills the pocket: full back holds',
    'After a CM drops, the opposing winger moves inside to receive from the CB. Wide and central midfielders keep the through lane narrow and cover the inside pass to the CM; the full back does not follow the winger but guards the space and prepares to take the advancing full back.',
    'Opposing wide midfielder comes inside into the vacated midfield space',
    'Avoid opening space behind the full back for the opponent''s full back or forward.',
    '4-4-2', 222, 222, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Koke) + CM (Gabi)', 'Keep through lane narrow, cover inside pass to dropping CM'),
    (2, 'Left back (F. Luis)', 'Don''t follow winger; defend space and pick up advancing full back'),
    (3, 'Mistake to avoid', 'Full back following inside leaves free space in behind')
) AS v(so, role, job);

-- 82. pp.223-223
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Tactical Situation 15: Pressing After the Goalkeeper''s Pass', 'Forward fills the pocket: CB steps, not chases',
    'If instead an opposing forward drops into the vacated midfield space, the near CB steps up a few yards but does not follow him deep. Midfielders block the through ball; a pass into the dropped CM is double-teamed.',
    'Opposing forward drops back to receive from a CB',
    'Keep the back line intact so no space opens behind for the winger or other forward.',
    '4-4-2', 223, 223, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Godin)', 'Step forward a few yards only; never follow too far'),
    (2, 'Koke + Gabi', 'Block potential through pass'),
    (3, 'Gabi + Torres', 'Double mark the dropped CM if he receives')
) AS v(so, role, job);

-- 83. pp.231-231
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_defend', 'Transition A->D Tactical Situation 1: Retaining a Numerical Advantage at the Back During Build-up Play', 'Weak-side full back drops for 3v2',
    'During build-up against two strikers, Atletico always keep a spare man at the back. With the ball on one side, the strong-side full back can go very high (covered by the strong-side CM), while the weak-side full back stays deep to make three on two.',
    'Own build-up vs a two-striker shape',
    'Rest defence ready: a lost ball can''t create an even counter against the CBs.',
    '4-4-2', 231, 231, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (Gimenez)', 'On the ball'),
    (2, 'Strong-side full back (Juanfran)', 'Very high'),
    (3, 'Strong-side central midfielder (Thomas)', 'Position to cover the opposing winger if ball lost'),
    (4, 'Weak-side full back (F. Luis)', 'Drop deep to form 3v2 with the CBs')
) AS v(so, role, job);

-- 84. pp.232-232
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_defend', 'Transition A->D Tactical Situation 1: Retaining a Numerical Advantage at the Back During Build-up Play', 'Weak-side CM drops for 3v2',
    'Alternative way to keep the spare man: the weak-side CM drops back into the defensive line, letting both full backs stay high. The weak-side full back stays level with the opposing winger so he can pick him up if the ball is lost.',
    'Own build-up vs a two-striker shape',
    'Keep 3v2 at the back while full backs push on.',
    '4-4-2', 232, 232, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side central midfielder (Rodri)', 'Drop into back line beside the CBs'),
    (2, 'Weak-side full back (F. Luis)', 'Stay high but in line with the winger'),
    (3, 'Centre backs', 'With Rodri, 3v2 against the strikers')
) AS v(so, role, job);

-- 85. pp.233-233
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_defend', 'Transition A->D Tactical Situation 1: Retaining a Numerical Advantage at the Back During Build-up Play', 'Re-balance after CB switch',
    'When the CB switches play to his partner, roles reshuffle: one CM drops into a wide-deep spot to keep 3v2, the other moves central. The strong-side full back retreats from very high to high so he can still pick up the winger.',
    'Centre back switches to the other centre back',
    'Keep the spare man and cover of the winger as the ball changes sides.',
    '4-4-2', 233, 233, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Rodri)', 'Drop deep and wide to keep 3v2'),
    (2, 'Other central midfielder (Thomas)', 'Move to the centre for balance'),
    (3, 'Strong-side full back (Juanfran)', 'Drop a few yards to a high (not very high) spot to cover the winger')
) AS v(so, role, job);

-- 86. pp.233-235
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_defend', 'Transition A->D Tactical Situation 1: Retaining a Numerical Advantage at the Back During Build-up Play', 'Full backs high while safe, one drops at risk',
    'When moving the ball into the CMs is easy (low pressure), both full backs stay high and both CMs sit deep. As soon as a CM receives and drives forward into an area where the ball could be lost, the far full back drops to form a back three.',
    'Ball played forward into a CM who carries it on',
    'Push numbers in safe moments, but guarantee 3v2 the moment loss becomes possible.',
    '4-4-2', 233, 235, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Gimenez)', 'Pass to CM; under heavy pressure go back to GK instead of forward'),
    (2, 'Central midfielder (Rodri)', 'Receive, cover the winger if ball lost'),
    (3, 'Left back (F. Luis)', 'Push very high when likely to receive'),
    (4, 'Right back (Juanfran)', 'Drop back to make three at the back when Rodri carries forward')
) AS v(so, role, job);

-- 87. pp.236-236
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_defend', 'Transition A->D Tactical Situation 1: Retaining a Numerical Advantage at the Back During Build-up Play', 'No drop needed vs a lone striker (4-2-3-1)',
    'Against a 4-2-3-1 whose No.10 sits deep, the two CBs already have 2v1 on the striker, so neither full back nor CM needs to drop. If the No.10 pushes up alongside the striker, treat it as a two-striker shape and drop one.',
    'Own build-up vs one forward',
    'Use all full backs and CMs high while still having a spare man.',
    '4-2-3-1', 236, 236, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', '2v1 vs lone striker'),
    (2, 'Full backs', 'Both high'),
    (3, 'Weak-side FB or CM', 'Drop only if No.10 joins the striker')
) AS v(so, role, job);

-- 88. pp.237-237
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_defend', 'Transition A->D Tactical Situation 1: Retaining a Numerical Advantage at the Back During Build-up Play', 'No drop needed vs 4-3-3 lone striker',
    'Against a 4-3-3 / 4-1-4-1 the CBs have 2v1 on the striker, so full backs and CMs can all be high; the strong-side CM covers the very high full back''s zone.',
    'Own build-up vs one forward',
    'Max numbers forward with the spare man kept.',
    '4-3-3', 237, 237, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', '2v1 vs striker'),
    (2, 'Right back (Juanfran)', 'Very high'),
    (3, 'Strong-side central midfielder (Thomas)', 'Cover for the full back if ball lost')
) AS v(so, role, job);

-- 89. pp.238-239
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_defend', 'Transition A->D Tactical Situation 1: Retaining a Numerical Advantage at the Back During Build-up Play', '3v2 at the back vs 3-5-2',
    'Against a 3-5-2''s two strikers, the same two methods apply: weak-side full back drops deep, or weak-side CM drops so the full back stays high.',
    'Own build-up vs two strikers',
    'Spare man so direct passes into the strikers can be defended actively.',
    '3-5-2', 238, 239, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side full back (F. Luis)', 'Drop deep for 3v2 (option 1)'),
    (2, 'Weak-side central midfielder (Rodri)', 'Drop deep instead (option 2)'),
    (3, 'Strong-side full back (Juanfran)', 'High')
) AS v(so, role, job);

-- 90. pp.245-247
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_defend', 'Transition A->D Tactical Situation 2: Negative Transition After Losing Possession from a Long Pass', 'Lost long ball: recover, compact, force wide',
    'After a long ball to the forwards is intercepted with nobody near to counter-press, Atletico don''t press: the spare man keeps 3v2, the deep forward retreats to a central spot by the midfield, midfielders squeeze into the centre to block through balls and push play to the touchline.',
    'Opponent CB intercepts a long pass and carries forward',
    'Make the attack predictable and buy time for out-of-position players to recover.',
    NULL, 245, 247, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep forward (Griezmann)', 'Track back to a central spot by midfielders, block a switch'),
    (2, 'Midfielders', 'Move centrally, become compact, block through passes'),
    (3, 'Centre backs + spare man', 'Keep 3v2 at the back'),
    (4, 'Advanced full back (F. Luis)', 'Recover while ball is forced wide')
) AS v(so, role, job);

-- 91. pp.248-248
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_defend', 'Transition A->D Tactical Situation 2: Negative Transition After Losing Possession from a Long Pass', 'Pass to full back gives time, then double-team winger',
    'Once the CB passes out to his full back, Atletico are balanced near the ball and the weak-side full back has recovered. The obvious next pass to the winger arrives in tight space and is double-marked.',
    'Opponent CB passes to his full back after winning a long ball',
    'Turn the regained shape into a trap on the winger.',
    NULL, 248, 248, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side wide midfielder and full back', 'Double the winger on the next pass'),
    (2, 'Weak-side full back (F. Luis)', 'Complete recovery to defensive line'),
    (3, 'Midfield block', 'Stay compact near ball')
) AS v(so, role, job);

-- 92. pp.252-253
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_defend', 'Transition A->D Tactical Situation 3: Negative Transition After Losing Possession During a Switch of Play', 'Switch intercepted: CB shifts wide for missing FB',
    'A switch to the advanced right back is cut out by the opposing full back, who carries forward. Everyone drops to get compact; with the right back stranded high, the near centre back moves toward the touchline to restrict the opposing winger, while a 2v1 is kept at the back.',
    'Attempted switch of play intercepted by the opponent''s full back',
    'Restore balance on the side missing a defender and stop the winger getting space.',
    NULL, 252, 253, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Gimenez)', 'Shift toward touchline to limit the winger'),
    (2, 'Stranded full back (Juanfran)', 'Recover'),
    (3, 'Midfielders', 'Drop back into a compact block'),
    (4, 'Back line', 'Keep numerical advantage (2v1)')
) AS v(so, role, job);

-- 93. pp.254-254
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_defend', 'Transition A->D Tactical Situation 3: Negative Transition After Losing Possession During a Switch of Play', 'CB jumps winger, CM fills back line',
    'When the ball goes on to the winger, the centre back shifts far out to close him while the nearest CM drops deep into the line to keep the spare man; the wide midfielder joins to double-team. If the CM can''t get back, the CB stays central and delays instead.',
    'Opponent full back passes to the winger after the turnover',
    'Pressure the winger without losing the numerical advantage in the middle.',
    NULL, 254, 254, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Gimenez)', 'Shift wide and close the winger (only if cover exists)'),
    (2, 'Central midfielder (Gabi)', 'Drop very deep to fill the gap in the back line'),
    (3, 'Right midfielder (Correa)', 'Double mark the winger'),
    (4, 'Centre back if no cover', 'Stay central and play for time')
) AS v(so, role, job);

-- 94. pp.258-259
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_defend', 'Transition A->D Tactical Situation 4: Counter-Pressing After Losing Possession During Combination Play', 'Pressing triangle after a central turnover',
    'Short combination play in the centre (triangles, short distances) means that when a pass is intercepted, three players are already close: they press the new ball carrier from different directions, while nearby receivers are marked and a 3v2 stays at the back.',
    'Pass intercepted during short combination play in the centre',
    'Win the ball back immediately before the opponent can look up.',
    NULL, 258, 259, 940)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder at base of triangle (Rodri)', 'Immediate front-on pressure, no time on the ball'),
    (2, 'Wide midfielder (Koke) + forward (D. Costa)', 'Press from behind, win it if he hesitates or turns'),
    (3, 'Central midfielder (Thomas) + CB (Gimenez)', 'Mark the nearest receivers'),
    (4, 'Back three (Godin, Gimenez, Juanfran)', 'Keep 3v2 against the two strikers')
) AS v(so, role, job);

-- 95. pp.260-261
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-defending-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_defend', 'Transition A->D Tactical Situation 4: Counter-Pressing After Losing Possession During Combination Play', 'Wide turnover: triangle press forces one side',
    'Same counter-press during wide combination play (10-12 m spacing). The front presser blocks forward passes and steers the carrier toward one flank; two others press from behind. A CB steps up tightly onto the nearest striker, and the other CB and right back slide over to keep 3v2.',
    'Pass intercepted during short combination play near the touchline',
    'Recover the ball at once or make the escape predictable.',
    NULL, 260, 261, 950)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Rodri)', 'Block forward passes and force play to one side'),
    (2, 'Wide midfielder (Koke) + CM (Thomas)', 'Press from behind'),
    (3, 'Centre back (Godin)', 'Step up and mark the striker tightly'),
    (4, 'Other CB (Gimenez) + right back (Juanfran)', 'Slide across to keep 3v2')
) AS v(so, role, job);

COMMIT;
