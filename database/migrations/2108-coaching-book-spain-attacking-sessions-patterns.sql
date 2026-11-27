-- 2108 📚 Coaching book patterns: "Spain Attacking Sessions" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Spain Attacking Sessions',
    subtitle    = '140 Practices from Goal Analysis of the Spanish National Team',
    author      = 'Michail Tsokaktsidis',
    team        = 'Spain national team (Aragonés, Del Bosque)',
    season      = '2008-2012',
    method_note = 'All 86 goals Spain scored in 37 competitive matches from Euro 2008 to Euro 2012, sorted by phase: attacking a set defence in the low, middle or high zone, and transitions to attack from the low, middle or high zone. Each goal type gets diagrams from the real goal and a progressive session. Covers the 2008 4-4-2 with wide midfielders inside, the 2010 4-3-3 with Busquets as single pivot and Iniesta inside for a 4v3, the 2012 six-midfielder shape, crosses chosen by the back line''s height, third-man runs behind, weak-side switches, splitting a double pivot, drawing the press then going long, counter-pressing (open with the ball, close on loss), corner counters and high regains. Patterns are the goal-scoring behaviours, in our words.'
WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa');

-- 1. pp.15-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'UEFA Euro 2008 Finals - Spain formation 4-4-2', 'Wide midfielders tuck in, full backs overlap',
    'In a 4-4-2, the two wide midfielders (Silva, Iniesta) spend most possession inside to build a central overload. This leaves the flank free for the full backs to push high, and one striker drifts wide.',
    'Settled possession in the opposition half',
    'Win the numbers in the middle, use the free flank, and stretch the back line so midfield runners find room in the box.',
    NULL, 15, 15, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielders (Silva, Iniesta)', 'drift inside into central pockets for a numerical edge'),
    (2, 'Full backs (Ramos, Capdevila)', 'attack the flank space the wide men leave'),
    (3, 'Striker (Villa)', 'drop off and run wide, especially high on the left, to stretch the line'),
    (4, 'Central midfield runners', 'attack the penalty-area space opened by the stretched line')
) AS v(so, role, job);

-- 2. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'FIFA World Cup Finals 2010 - Spain formation 4-3-3', 'Single pivot screen, inside winger 4v3',
    'In a 4-3-3 with one holding midfielder (Busquets), the left winger (Iniesta) plays mostly inside to make a 4v3 in central midfield. A winger who stays wide (Navas) and the full backs give the width, because opponents sat deep and the centre was crowded.',
    'Opponent drops deep and packs the centre',
    'Keep the ball centrally with an extra man, while the width comes from full backs and one touchline winger who beats his man and crosses from the byline.',
    NULL, 18, 18, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Busquets)', 'screen the back four and keep circulation going by positioning'),
    (2, 'Central playmaker (Xavi)', 'dictate tempo from the centre with high pass volume'),
    (3, 'Inside winger (Iniesta)', 'come inside for a 4v3 in midfield'),
    (4, 'Wide winger (Navas)', 'stay wide, beat the full back on the outside, cross from the byline'),
    (5, 'Full backs', 'give width high up')
) AS v(so, role, job);

-- 3. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_defend', 'FIFA World Cup Finals 2010 - Spain formation 4-3-3', 'Midfield superiority to press their centre mids',
    'The extra central player that keeps possession is also used without the ball: Spain squeezes the opposition''s central midfielders straight away.',
    'Opponent has the ball, or Spain just lost it in midfield',
    'Give their central midfielders no time or space, so they cannot play a killer pass, and win the ball back fast.',
    NULL, 18, 18, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfield trio + inside winger', 'close down the opposition''s central midfielders at once'),
    (2, 'Holding midfielder (Busquets)', 'stay positioned to intercept and win the ball back')
) AS v(so, role, job);

-- 4. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'UEFA Euro 2012 Finals - Spain formation 4-2-3-1 / 4-3-3', 'Six central players, full back runs behind',
    'The wide forwards come inside and a false nine (Fabregas) drops, so six Spain players sit in the centre and both full backs give all the width. Quick short passing in midfield draws the block in, then the first ball in behind often goes to a full back running from deep.',
    'Opponent narrows to stop central circulation',
    'Use central superiority to draw the block in, then release the overlapping full back in behind or between the centre backs.',
    NULL, 21, 21, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central six (incl. false nine Fabregas)', 'constant quick short passing to keep the ball and draw the block in'),
    (2, 'Left full back (J. Alba)', 'make forward runs from deep, wide or between the two centre backs'),
    (3, 'Right full back (Arbeloa)', 'hold width on the far side'),
    (4, 'Striker (Torres, when used)', 'attack the gap between the centre backs')
) AS v(so, role, job);

-- 5. pp.26-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Attacking Against Teams which Defend in the Low Zone - 4. Attacking from the Flanks', 'Switch play, cross by line height',
    'When the low block crowds the centre, Spain uses the full width and switches play to hit the weak side. The type of cross depends on where the opposition back line stands.',
    'Centre is packed; the far flank is free after a switch',
    'Against a line on the edge of the box, cross at mid height behind it, mostly to the far post. Against a deeper line, make a 2v1 on the flank first, then play a low cross to the near or far post.',
    NULL, 26, 27, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'circulate side to side to change the point of attack'),
    (2, 'Winger + full back', 'build a 2v1 on the flank with an overlap or underlap'),
    (3, 'Crosser', 'mid-height cross behind a high line, low cross against a deep line'),
    (4, 'Strikers / runners', 'attack the near and far posts')
) AS v(so, role, job);

-- 6. pp.28-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Attacking Inside the Penalty Area (1)', 'Dribble inside, forwards swap, receive in box',
    'Against nine defenders behind the ball, a wide midfielder (Iniesta) dribbles inside from the left to pull a defender out of position. The players ahead of him check away from their markers and swap places (Guiza and Capdevila) to open a lane into the box.',
    'Ball carrier dribbles inside and a marker steps out',
    'Slip a forward pass into a player inside the box, who takes a directional first touch and finishes on his second touch, here in a 5v4 in a tight space.',
    '4-2-3-1', 28, 39, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wide midfielder (Iniesta)', 'carry inside to unbalance the block, then pass at the right moment'),
    (2, 'Front players (Guiza, Capdevila)', 'check away and swap positions to make passing lanes'),
    (3, 'Receiver in the box (Capdevila)', 'directional first touch away from pressure and a quick finish'),
    (4, 'Team (from the practices)', 'build a numerical edge around the ball zone and shoot within a few touches or seconds')
) AS v(so, role, job);

-- 7. pp.29-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Attacking Inside the Penalty Area (2) & (4)', 'Beat first man, draw cover, slip',
    'A creative player takes on his direct opponent in a 1v1 at the edge of the box, or one pass to the flank isolates him. When the covering defender or centre back steps up to him, he passes to the striker freed nearby, while other players hold balance behind.',
    'Covering defender commits to the dribbler',
    'Turn a 1v1 into a free finish inside the box. The second striker''s run drags a defender away and the striker finishes after a directional first touch.',
    '4-2-3-1', 29, 31, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dribbler (Iniesta on the left / Mata on the right)', 'beat the 1v1 at speed and draw the cover'),
    (2, 'Striker (Villa)', 'stay just inside the box, receive, finish to the far corner'),
    (3, 'Second striker (Negredo)', 'run to take the full back away'),
    (4, 'Support (Capdevila)', 'give an outside option'),
    (5, 'Holding mid + right back (Senna, Ramos)', 'hold defensive balance behind the ball')
) AS v(so, role, job);

-- 8. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Attacking Inside the Penalty Area (3)', 'Pass inside and diagonal run behind',
    'A forward on the right (Bojan) passes inside to a midfielder, then runs diagonally into the box between defenders. This gives the ball carrier a forward option and space to dribble forward. A free midfielder then draws the centre back and feeds the striker inside the full back.',
    'Inside pass to a free midfielder facing forward',
    'Pull defenders apart so the striker gets the ball on the half turn, shields it from the full back and finishes. In the example 5 attackers face 4(+4).',
    NULL, 30, 30, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right forward (Bojan)', 'pass inside, then run diagonally into the most dangerous area'),
    (2, 'Attacking midfielder (Fabregas)', 'carry towards the defender, then lay off to the free man'),
    (3, 'Central midfielder (Alonso)', 'dribble forward until the centre back closes, then pass'),
    (4, 'Striker (Villa)', 'take a spot inside the full back, receive on the half turn, shield and finish')
) AS v(so, role, job);

-- 9. pp.40-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Attacking in and Around the Penalty Area - one touch combination play and 3rd man run', 'Third man run behind the line',
    'Around the edge of a deep block, a forward has the opposition''s back line in front of him. He passes back inside and goes on a diagonal run, or a teammate under pressure plays a short combination. While the ball travels to a supporting player who has dropped to a good angle, a third player runs behind the defensive line.',
    'Ball played to a supporting player facing play; a defender is ball-watching',
    'The supporter plays a first-time pass (chipped or along the ground) into the runner''s path between full back and centre back, so the runner finishes in front of goal.',
    NULL, 40, 47, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Guiza / Mata)', 'pass inside, then run diagonally as the third man into the box'),
    (2, 'Midfielder under pressure (Ramos / Xavi)', 'play a quick pass to the supporting player'),
    (3, 'Supporting player (Fabregas / Silva)', 'drop or move across to a good angle and play a one-touch pass in behind'),
    (4, 'Other forwards (Silva)', 'make extra runs into the box to overload')
) AS v(so, role, job);

-- 10. pp.48-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Attacking in and Around the Penalty Area (3) - one-two combinations', 'Flank one-two, cut in, low cross',
    'A ball arrives on the flank in behind the opposition midfield. When a defender presses the receiver, he plays a give-and-go with a nearby forward to get inside, taking several defenders out of the game. He dribbles into the box and plays a low cross while runners split between the near and far posts.',
    'Full back steps out to press the wide receiver',
    'Beat the flank defenders with one combination, then finish from a low cross. The runs are coordinated: one to the near post, one to the far post.',
    '4-2-3-1', 48, 55, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ramos)', 'pass forward in behind the midfield'),
    (2, 'Striker (Torres)', 'receive between the lines, lay off wide, return the one-two'),
    (3, 'Right winger (Silva)', 'play the give-and-go, dribble into the box, cross low'),
    (4, 'Near-post runner (Mata)', 'attack the near post'),
    (5, 'Far-post runner (Alonso)', 'arrive at the far post for a one-touch finish'),
    (6, 'Variation', 'after the one-two, pass into space for a forward running wide, who crosses')
) AS v(so, role, job);

-- 11. pp.49-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Attacking in and Around the Penalty Area (4)', 'Hit an unbalanced back line',
    'After a corner is cleared, the opposition back line is badly placed and out of step. Spain win the second ball and quickly pass into the space on the weak side, which leaves a 1v1 against each defender.',
    'Cleared set piece leaves the back four out of shape',
    'A runner dribbles inside to make a 2v1 next to the striker. The striker checks away and then runs behind for the pass and a near-post finish.',
    '4-2-3-1', 49, 49, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder on the second ball (Alonso)', 'pass at once into the space behind the unbalanced side'),
    (2, 'Receiver (Fabregas)', 'dribble inside to make a 2v1 with the striker'),
    (3, 'Striker (Torres)', 'check away from his marker, time the run behind, finish at the near post'),
    (4, 'Other attackers', 'fill the box against the remaining defenders')
) AS v(so, role, job);

-- 12. pp.56-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Passing in Behind a Defensive Line Positioned on the Edge of the Box (1)', 'Drop to pull a centre back out',
    'The opposition has nine players in the area and a compact back four on the edge of the box. Spain players drop back one after another to receive (Cazorla, then Xavi, then Mata). When a centre back follows the dropping player, he leaves a hole in the line.',
    'A centre back follows a player who drops to support',
    'A runner sees the gap and attacks it. The midfielder chips a pass in behind into the box, and the runner finishes first time, here with a lob over the keeper.',
    '4-4-1-1', 56, 56, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders (Cazorla, Xavi)', 'drop to receive in turn and keep the ball under pressure'),
    (2, 'Attacking midfielder (Mata)', 'drop back to draw the right centre back out of the line'),
    (3, 'Passer (Xavi)', 'play a quality chipped pass into the vacated space'),
    (4, 'Runner (Fabregas)', 'spot the gap and run into it, finish first time'),
    (5, 'Full backs', 'stay high and wide to hold the back line''s width')
) AS v(so, role, job);

-- 13. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Passing in Behind a Defensive Line Positioned on the Edge of the Box (2)', 'Recycle to the better-sighted man, slide pass',
    'Spain are outnumbered overall but level in the ball zone near a deep line. The man on the ball plays back to a team-mate with a clearer view of goal, who spots a badly placed centre back and a gap behind.',
    'Ball carrier lacks a forward view; a centre back steps out of line',
    'Early through pass into the space behind for a runner to finish.',
    '4-2-3-1', 57, 57, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Silva)', 'pass back to the free deeper midfielder'),
    (2, 'Deep playmaker (Xavi)', 'read the gap while the ball travels, slide it through first time'),
    (3, 'Wide/inside forward (Mata)', 'time the run into the gap, good first touch, finish')
) AS v(so, role, job);

-- 14. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Passing in Behind a Defensive Line Positioned on the Edge of the Box (3)', 'Decoy one-two drags a centre back',
    'Against a back three, a midfielder asks for a return pass, pulling a centre back with him; the next defender is drawn too, and the wing back does not tuck in, leaving a channel.',
    'Centre back follows the one-two runner',
    'Third man runs into the vacated channel and receives a through ball to finish first time.',
    '3-5-2', 58, 58, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Iniesta)', 'play in and spin, asking for the return to drag his marker'),
    (2, 'Attacking midfielder (Silva)', 'take the ball the other way, then thread the pass behind'),
    (3, 'False nine / late runner (Fabregas)', 'run into the gap between wing back and centre back, one-touch finish')
) AS v(so, role, job);

-- 15. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Passing in Behind a Defensive Line Positioned on the Edge of the Box (4)', 'Short combinations open a back-four gap',
    'Quick short passing around an organised low block, a support run behind the midfield line, an overlap and a dribble in the opposite direction pull the full back and centre back apart.',
    'Gap appears between full back and centre back',
    'Pass into the box behind the back four; the receiver cuts it back to a near-post runner with a late runner arriving.',
    '4-1-2-1-2', 59, 59, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Silva)', 'after passing, run behind the midfield line for a new angle; then attack the near post'),
    (2, 'Central midfielder (Xavi)', 'dribble inside, pass and overlap; arrive late in the box'),
    (3, 'Inside midfielder (Iniesta)', 'dribble the opposite way, play the pass behind'),
    (4, 'Striker (Fabregas)', 'win the 1v1 behind, quick low cross')
) AS v(so, role, job);

-- 16. pp.60-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Passing in Behind a Defensive Line Positioned on the Edge of the Box (5)', 'Holding midfielder hits the line early',
    'Opponent has many bodies but defends passively. The holding midfielder has time in the centre and plays forward behind a line that is momentarily disorganised.',
    'Defensive line badly set at that moment; holder unpressed',
    'Striker runs onto it, draws the keeper and squares to a team-mate making an opposite run.',
    '4-1-2-1-2', 60, 60, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Busquets)', 'play forward behind the line as soon as it is unbalanced'),
    (2, 'Striker (Torres)', 'run towards the ball, draw the keeper, square it'),
    (3, 'Second forward (Mata)', 'opposite supporting run into the box for a tap-in')
) AS v(so, role, job);

-- 17. pp.61-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Session: Passing in Behind a Defensive Line (61-66)', 'Keep it in tight areas, then break the line',
    'Practices train keeping the ball under pressure in the middle zone (pass count, 30-second holds), finding combinations to get a player receiving under control behind the line, and finishing in two touches.',
    'Pass target reached or a runner is free behind the line',
    'Patient possession that produces a well-timed pass and run behind a deep line and a quick finish.',
    NULL, 61, 66, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'circulate with limited touches, find the angle for the forward pass'),
    (2, 'Attacking midfielders / forwards', 'time runs behind; arrive under control in the end zone'),
    (3, 'Full backs', 'give width so the block stretches'),
    (4, 'Finisher', 'shoot within 2 touches; aim for the central goal one-touch')
) AS v(so, role, job);

-- 18. pp.62-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Session: 6 (+4) v 4 Possession Play in the Centre Transition Game', 'Regain and switch to the free area',
    'A team defending outnumbered in one area wins the ball and immediately plays it to team-mates waiting in the other area, away from the crowd.',
    'Ball won in the congested zone',
    'Escape the pressure fast and restart possession where there is space.',
    NULL, 62, 62, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins it', 'first pass straight to the far area'),
    (2, 'Team-mates in the other zone', 'be open and ready to keep possession'),
    (3, 'Support players at the sides', 'act as bounce passes with limited touches')
) AS v(so, role, job);

-- 19. pp.67-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Attacking on the Flank: Crossing from Deep (1-4)', 'Early cross from deep behind the line',
    'When a low block is compact and closes the centre, Spain move the ball wide (often switching sides first) and the full back or a wide forward delivers early from deep, behind the defensive line.',
    'Centre closed; full back or wide man free out wide',
    'Runners from the far side and the striker attack the space between line and keeper and score from the cross.',
    NULL, 67, 70, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forward (Guiza)', 'hold the width to support the full back, shift ball to stronger foot and cross'),
    (2, 'Full back (Capdevila / Ramos)', 'overlap or receive the switch; cross early behind the line'),
    (3, 'Central midfielder (Alonso / Xavi)', 'switch the point of attack to the free flank'),
    (4, 'Striker and far-side forward (Villa, Llorente, Silva)', 'timed runs into the box from the far side'),
    (5, 'Forward offside-checking (Pedro)', 'drop back while the ball goes back to the full back to stay onside')
) AS v(so, role, job);

-- 20. pp.71-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Session: Full Back''s Support Play & Crossing from Deep (71-74)', 'Full backs out wide beat a central overload',
    'Practices force teams to use full backs in side zones because the centre is crowded (2v4 / 4v4), then cross into the box with everyone from the high central zone attacking it.',
    'Central route outnumbered',
    'Width from the full backs creates a free cross; goals from crosses are worth double.',
    NULL, 71, 74, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'stay wide in the side zone, receive and cross'),
    (2, 'Centre backs / midfielders', 'short quality passes to feet, open body, find the full back'),
    (3, 'High central players', 'attack the penalty area when the ball goes wide')
) AS v(so, role, job);

-- 21. pp.75-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Attacking on the Flank: Crossing from the Byline (1, 3)', 'Flank 2v1 to the byline cutback',
    'Against a team packed in or near its box, a supporting run by the full back makes 2v1 on the flank; the winger drives inside to fix the defender then releases the runner into space down the line.',
    'Overlapping/underlapping full back arrives; defender committed to the dribbler',
    'Runner reaches the byline and crosses or cuts back to a near-post runner.',
    '4-4-2', 75, 77, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Silva / Villa)', 'dribble inside to attract the defender, pass down the line at the right time'),
    (2, 'Full back (Ramos / J. Alba)', 'make the supporting run for the 2v1, cross first touch'),
    (3, 'Midfielder (Xavi)', 'after a one-two, switch to the far flank where space is'),
    (4, 'Near-post attacker (Llorente / Silva)', 'time the run, win the 1v1 or finish first time')
) AS v(so, role, job);

-- 22. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Attacking on the Flank: Crossing from the Byline (2)', 'Winger beats his man, far-post cross',
    'With the opponent packed in the box, the wide player is given the ball 1v1 on the flank and uses feints and changes of direction to go past.',
    'Wide player isolated 1v1',
    'Cross to the far post where a target man wins the header, with about six players in the box.',
    '4-4-2', 76, 76, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Cazorla)', 'beat the man with feints, cross to the far post'),
    (2, 'Inside midfielder (Silva)', 'feed the winger early'),
    (3, 'Striker (Llorente)', 'attack the far-post space and win the aerial duel')
) AS v(so, role, job);

-- 23. pp.78-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Session: Crossing & Finishing (78-80)', 'Coordinated box runs for crosses',
    'Practices on crossing, attacking and defending crosses, and wide 2v1 flank play into a cross from near the byline.',
    'Ball reaches the side zone',
    'Box filled with split runs and finishes in one touch; goals after a cross from the side zone count more.',
    NULL, 78, 80, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near-post runner', 'attack the near post'),
    (2, 'Far-post runner', 'attack the far post'),
    (3, 'Late runner', 'arrive from behind for the cutback'),
    (4, 'Wide forward + full back', 'create the 2v1 in the side zone and cross from near the byline')
) AS v(so, role, job);

-- 24. pp.79-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Session: Crossing & Finishing with Quick Transitional Wide Counter Attacks', 'Clearance becomes a wide counter',
    'Defenders who clear a cross play straight into the other half and out to a wide player, who crosses for a quick attack; in the zonal game the defending team must finish its counter within 10 seconds.',
    'Ball cleared or won after defending a cross',
    'Fast attack down the flank ending in a cross before the opponent reorganises.',
    NULL, 79, 80, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender who wins it', 'first pass forward to the other zone'),
    (2, 'Wide player', 'receive in space and cross early'),
    (3, 'Attackers', 'sprint into the box with split runs')
) AS v(so, role, job);

-- 25. pp.81-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis + Session: Creating Space to Shoot Using a Target Man', 'Chip to target man, knock-down shot',
    'A packed opponent sits in two zones in front of the ball; a chipped pass over the midfield line to the striker takes a whole line out, and two midfielders sprint forward either side to receive his headed knock-down.',
    'Chipped ball travelling to the striker',
    '3v3 on the edge of the box and a first-time strike from outside the area.',
    '5-4-1', 81, 85, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Fabregas)', 'chip accurately over the midfield line to the striker'),
    (2, 'Striker / target man (Guiza)', 'win the aerial duel, head down to a runner'),
    (3, 'Supporting midfielders (D. Red, Cazorla)', 'run forward left and right of the striker, adjust stride, shoot first time'),
    (4, 'Second runner', 'at least two players must support the target man')
) AS v(so, role, job);

-- 26. pp.86-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Creating Space to Shoot from Outside the Box (2-3)', 'Overload one side, free a shooter',
    'Full backs give the width while three midfielders play inside to overload one side; quick passes among them, with the striker running away to clear space, take several defenders out.',
    'Midfielder closed down after turning; a team-mate free in space',
    'A player receives in space at 25 yards and shoots before a centre back can close.',
    NULL, 86, 87, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (Capdevila, Ramos)', 'hold the width on both sides'),
    (2, 'Central midfielders (Xavi, Alonso)', 'short passes that give support angles in front, behind and beside'),
    (3, 'Inside forward (Iniesta)', 'come to support, turn, release the free man'),
    (4, 'Striker (Torres)', 'run away from the ball to open space and be an extra option'),
    (5, 'Shooter (Villa / Senna)', 'move across to receive, touch out of feet and strike from distance')
) AS v(so, role, job);

-- 27. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Creating Space to Shoot from Outside the Box (4)', 'Dribble across the edge to shoot',
    'Opponents defend in two tight lines close to the box with 4v4 at its edge; a quick pass finds a forward who dribbles parallel to goal and uses feints to win half a yard.',
    'Forward receives on the edge under pressure',
    'Low shot into the corner through the small window created.',
    '4-2-3-1', 88, 88, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Ramos)', 'feed the inside midfielder'),
    (2, 'Midfielder (Iniesta)', 'pass quickly to the forward'),
    (3, 'Forward (Villa)', 'dribble along the box edge onto his strong foot, feint and shoot low')
) AS v(so, role, job);

-- 28. pp.89-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Session: Attacking through the Centre and Shooting from Distance (89-91)', 'Break the midfield line, shoot early',
    'Practices on quick forward passing through the opponent''s first line and shooting before a recovering defender or blocker can close; the team needs good movement and support angles to exploit an overload.',
    'Ball through the first line',
    'Shot taken fast with a directional first touch, using one-touch combinations to drag defenders and open gaps.',
    NULL, 89, 91, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep players', 'pass forward through gaps in the line'),
    (2, 'Receiving midfielders/forwards', 'directional first touch out of feet, shoot quickly'),
    (3, 'Support players', 'one-touch combinations to move blockers'),
    (4, 'Defending team after loss', 'move fast from attack to defence')
) AS v(so, role, job);

-- 29. pp.92-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis + Session: Individual Play: Dribbling & Creativity', 'Switch to isolate the winger 1v1',
    'In the opposition half against a low block, a long diagonal switches from one flank to the winger on the other, who dribbles inside between the first defenders into the box.',
    'Long switch reaches the far-side winger with space',
    'Final 1v1 with a centre back won with feints and a finish to the far corner.',
    '4-2-3-1', 92, 96, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Ramos)', 'move the ball across to the centre back'),
    (2, 'Centre back (Pique)', 'long ball to switch the point of attack'),
    (3, 'Winger (Villa)', 'dribble inside at speed with soft touches, feint, shield the ball with body, shoot early in the box picking the corner'),
    (4, 'Rest of attack', 'after losing it, transition to defend immediately')
) AS v(so, role, job);

-- 30. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Chapter 2 intro: Attacking Against Teams which Defend in the Middle Zone', 'Switch to unbalance, receive between lines',
    'Against a mid block, Spain build from the back and switch the ball side to side to disturb the spacing of the midfield and defensive lines.',
    'Lines unbalanced by the switch',
    'A player moves and receives behind the midfield line at the right moment, taking up to six opponents out and facing only the back four.',
    NULL, 99, 99, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs / deep midfielders', 'switch the ball from side to side'),
    (2, 'Midfielder between the lines', 'move and ask for the ball behind the midfield line at the right time')
) AS v(so, role, job);

-- 31. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Chapter 2 intro: Attacking Against Teams which Defend in the Middle Zone', 'Keep it, then long ball in behind',
    'Spain hold possession in the middle zone, then a wide or attacking midfielder runs into the channel between full back and centre back to receive a long pass in the box.',
    'Run into the full back/centre back channel',
    'Short cross from the receiver to the striker running for the far post while others flood the box.',
    NULL, 99, 99, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide or attacking midfielder', 'run between full back and centre back to receive the long pass'),
    (2, 'Passer (deep midfielder)', 'long ball behind the line'),
    (3, 'Striker', 'run to the far post for the short cross'),
    (4, 'Other attackers', 'run into the box to support')
) AS v(so, role, job);

-- 32. pp.100-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis + Session: Attacking Combination Play: Switching Positions to Create Space', 'Inside-outside position switch',
    'In a crowded centre, as the ball goes forward to a midfielder, the wide man runs from outside to inside in front of him; the receiver gives it to him and runs the opposite way into the space he left, so markers lose their men.',
    'Pass into a central midfielder in traffic',
    'Defensive imbalance; the wide-run player gets time to pass between two defenders for the striker running behind.',
    '3-4-1-2', 100, 105, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep midfielder (Xavi)', 'play forward into the attacking midfielder'),
    (2, 'Wide midfielder (Cazorla)', 'curved run outside to inside in front of the receiver, take the ball and dribble'),
    (3, 'Attacking midfielder (Fabregas)', 'lay it off and run outside into the vacated space, then thread the pass behind'),
    (4, 'Striker (Villa)', 'run into the space between centre backs, beat the man, finish')
) AS v(so, role, job);

-- 33. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Maintaining Possession Before Quickly Switching Play to the Opposition''s Weak Side (1)', 'Switch, return pass, weak-side release',
    'A long switch moves the ball to a winger who is closed at once; he plays first time back to the free full back, who drives forward while forwards slot between the lines for a four-man combination.',
    'Winger pressed immediately after the switch',
    'Pass with the outside of the foot behind the line to a runner on the weak side where only one defender remains.',
    NULL, 106, 106, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Alonso)', 'long ball to switch from left to right'),
    (2, 'Winger (Iraola)', 'one-touch back to the free full back, then go wide'),
    (3, 'Full back (Ramos)', 'dribble into the free space'),
    (4, 'Forwards between the lines (Negredo, Riera)', 'offer support, play first time under pressure'),
    (5, 'Weak-side forward (Mata)', 'run into space behind the last defender and finish one touch')
) AS v(so, role, job);

-- 34. pp.107-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Goal Analysis: Maintaining Possession Before Quickly Switching Play to the Opposition''s Weak Side (2)', 'Holder drops in, circulate, weak-side finish',
    'The right back pushes high, a centre back goes wide and the holding midfielder drops into the back line; a stream of short passes follows, played back as soon as a man is closed, until a centre back steps into midfield as the support angle.',
    'Ball carrier pressed with no back pass',
    'Carry and one-twos, a third-man run and a dribble inside draw the defence, then the ball goes to the far-side striker free in the box.',
    '4-4-2', 107, 108, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Busquets)', 'drop between the centre backs and start the circulation'),
    (2, 'Centre back (Pique)', 'go wide, then run inside into midfield to support and dribble forward'),
    (3, 'Right back (Ramos)', 'high and wide; release the ball when pressed from behind'),
    (4, 'Attacking midfielder (Silva)', 'one-twos, third-man run between team-mates, dribble inside'),
    (5, 'Far-side striker (Villa)', 'arrive unmarked on the other side of the box')
) AS v(so, role, job);

-- 35. pp.109-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Session: Attacking Combination with Change of Direction (109-110)', 'Short-short-long change of direction',
    'Pattern drills where a short wall pass and support movement are followed by a long ball to the other side, repeated in both directions, all at one touch.',
    'Return pass sets up an open body shape',
    'Rhythm of short combinations that release a long switch to the opposite triangle.',
    NULL, 109, 110, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pivot player', 'pass, move to support, receive back facing forward'),
    (2, 'Switcher', 'open body, receive on back foot, play the long ball across'),
    (3, 'Far-side group', 'be ready to restart the combination')
) AS v(so, role, job);

-- 36. pp.111-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Session: Attacking from the Back with One-Two Combinations Pattern of Play', 'One-twos from the back, third-man run',
    'A deep player progresses through a series of one-two combinations with midfielders, then passes and makes a third-man run to receive in the box.',
    'Pass played to the forward who will set the third man',
    'Deep player arrives unmarked in the box for a shot.',
    NULL, 111, 111, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep central player', 'carry forward, combine one-two with each midfielder, then third-man run'),
    (2, 'Midfielders', 'set back first time and support'),
    (3, 'Forwards', 'lay the ball into the runner''s path')
) AS v(so, role, job);

-- 37. pp.112-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Session: Switching Play & Attacking the Opposition''s Weak Side in a Position Specific Attacking Combination Practice', 'Switch then early ball to far winger',
    'After the three midfielders combine, the No.8 switches to the far full back, who returns it to the centre back; he hits the striker, who sets the right forward. Two options follow on the weak side.',
    'Right forward receives facing goal after the set',
    'Preferred: ball behind the line to the far-side forward in the box before defenders recover; alternative: pass into space for the overlapping full back to cross with near/far/late runs.',
    '4-3-3', 112, 112, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders (6, 8, 10)', 'short combination, then 8 plays the long switch'),
    (2, 'Full back (2)', 'return to centre back, then advanced run outside for the cross'),
    (3, 'Striker (9)', 'lay off to the right forward; near-post run'),
    (4, 'Right forward (7)', 'choose the early ball behind the line first'),
    (5, 'Left forward (11)', 'attack the space behind the line on the weak side / far post'),
    (6, 'No.10 and others', 'run from behind and close the distances')
) AS v(so, role, job);

-- 38. pp.113-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch.2 Middle zone - Maintaining possession before quickly switching play to the weak side', 'Midfield trio combine, switch, attack weak side',
    'Team in a 4-3-3 keeps the ball with short passes between the three midfielders, then the No.8 hits a long switch to the far full back, who plays back inside to the centre back; the centre back finds the striker, who sets the ball to the near-side forward.',
    'Opponent block drawn to one side by short midfield combinations',
    'Finish on the weak side before the defence can shift across.',
    NULL, 113, 114, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield three (6, 8, 10)', 'Short combinations; No.8 switches long to the far full back; No.10 runs up from behind to support'),
    (2, 'Weak-side full back', 'Receives the switch, plays back to centre back, then makes an advanced run up the flank as option two'),
    (3, 'Wide forward (ball side, No.7)', 'Receives the striker''s lay-off; preferred option is a ball in behind the line to the far-side forward, else into space for the overlapping full back'),
    (4, 'Far-side forward (No.11)', 'Runs in behind the defensive line into the box, or attacks the far post on a cross'),
    (5, 'Striker (No.9)', 'Lays off from the centre back''s pass, then runs to the near post')
) AS v(so, role, job);

-- 39. pp.115-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch.2 Middle zone - Passing through the midfield line in the centre (1)', 'Opposite movements free man behind midfield line',
    'Against an organised middle-zone block (Russia 4-1-3-2), a defender passes inside to the holding midfielder, who dribbles inward; one attacking midfielder drops while the other slips in behind the opponents'' midfield line, away from their two central midfielders, and receives the vertical pass on the half-turn.',
    'Holding midfielder carries inside with time; gap opens behind the two opposing centre midfielders',
    'One pass removes the whole midfield line and turns the attack into an even number up front (4v4).',
    NULL, 115, 121, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Senna)', 'Takes the inside pass, dribbles inward to open a forward lane, plays vertically into the man between the lines'),
    (2, 'Dropping attacking midfielder (Silva)', 'Comes short in front of the line to pull a marker and offer a safe option'),
    (3, 'Advanced central midfielder (Xavi)', 'Moves behind the midfield line away from the two centre midfielders, receives half-turned and drives into the high zone'),
    (4, 'Striker (Torres)', 'Bends his run to one side to clear the centre'),
    (5, 'Other attackers (Iniesta, Fabregas)', 'Spread left and right to give the receiver 3 options in the 4v4')
) AS v(so, role, job);

-- 40. pp.116-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch.2 Middle zone - Passing through the midfield line in the centre (1)', 'Decoy overlap and late third-man box arrival',
    'When the defence collapses to penalty-box width, the side channels are empty; the ball-side wide player holds the ball against the full back while his own full back overlaps, then uses the overlap as a decoy and cuts inside onto the other foot while a midfielder arrives late from deep into the box.',
    'All defenders inside the box width with forwards in the box static and marked',
    'Short hard cross or cut-back finds the unmarked runner from deep for a first-time finish.',
    NULL, 116, 121, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide attacking midfielder (Iniesta)', 'Shields against the full back, gives time for the overlap, then cuts inside and crosses short and hard'),
    (2, 'Full back (Capdevila)', 'Overlaps into the empty side channel to create a 2v1 and drag the defender'),
    (3, 'Central midfielder from deep (Xavi)', 'Third man: after his pass, keeps running and arrives late in the box'),
    (4, 'Box forwards (Torres, Fabregas)', 'Hold positions to pin the centre backs')
) AS v(so, role, job);

-- 41. pp.117-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch.2 Middle zone - Passing through the midfield line in the centre (2)', 'Split the double pivot, slip striker FB-CB',
    'Against a 4-2-3-1 middle block, constant circulation and support runs make the opponent shift; as the ball goes wide and back inside to the holding midfielder, the playmaker positions behind the two holding midfielders and receives the pass between them, with only the back four ahead.',
    'Ball returned inside from the full back while the opponents'' 2-3-1 part is shifted to the ball',
    'Directional first touch to turn, second touch slides the striker through the gap between full back and centre back for a 1v1 race to goal.',
    '4-2-3-1', 117, 123, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left full back (Capdevila)', 'Receives wide and passes back inside to the holding midfielder'),
    (2, 'Holding midfielder (Senna)', 'Splits the two opposing centre midfielders with a forward pass'),
    (3, 'Playmaker (Xavi)', 'Hides behind the double pivot, turns with a directional first touch, passes into the full back-centre back channel'),
    (4, 'Striker (Torres)', 'Times a run from a better starting angle than the static centre back, wins the race and finishes (chip)'),
    (5, 'Wide players', 'Offer the alternative passes outside the full backs; the passer then runs on to support in the box')
) AS v(so, role, job);

-- 42. pp.124-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch.2 Middle zone - Passing through the midfield line on the flank', 'Central overload frees full back''s channel run',
    'In a 4-2-3-1 against a 4-1-4-1, every player except the full backs crowds the centre to win numbers around the ball while the full backs stay wide; when the left-sided midfielder dribbles forward it creates a 2v1 with the full back against the opposing right back.',
    'Wide midfielder gets space to carry forward on the flank, opposing right back isolated',
    'Full back sprints into the gap between right back and centre back, gets to the byline and crosses to the far post for a weak-side midfielder arriving unmarked.',
    '4-1-4-1', 124, 129, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (Busquets, Xavi, Iniesta)', 'Circulate left to right and back to move the block; Iniesta carries forward when space appears'),
    (2, 'Left full back (J. Alba)', 'Holds width, then accelerates and asks for the ball behind the right back, dribbles to the byline'),
    (3, 'Box runners (Iniesta, Fabregas, Silva)', 'Three players run into the box to support the cross'),
    (4, 'Weak-side midfielder (Alonso)', 'Times a late run from the far side to the back post and heads in')
) AS v(so, role, job);

-- 43. pp.126-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch.2 Middle zone - Passing through the midfield line on the flank (practice)', 'Wide forward give-and-go, diagonal cut',
    'Team keeps the ball in the central zone, waiting for the right moment to go wide; the advanced full back is the only player in the side channel. Two solutions: pass out to the full back to cross, or the wide forward plays the full back and makes a diagonal cutting run, creating a 2v1 on the flank.',
    'Full back free in the side channel ahead of the midfield line',
    'Full back gets the ball back down the line in an advanced position and crosses into the box.',
    '4-1-4-1', 126, 129, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advanced full back', 'Stays in the side channel, receives, plays to the wide forward and goes again down the line'),
    (2, 'Wide forward', 'Plays a one-two with the full back then cuts diagonally inside to drag his marker and attack the box'),
    (3, 'Central midfielders', 'Keep possession in the centre with opening body shape and back-foot receiving')
) AS v(so, role, job);

-- 44. pp.130-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch.2 Middle zone - Attacking in behind the defensive line (1)', 'One-side overload, dribble-and-one-two, run between FB-CB',
    'Spain in a 4-1-4-1 put most players on one side with small distances between the lines, width on the other side only from the right back; after long possession the wide midfielder dribbles past the opposing midfielder and plays a one-two that removes a centre midfielder.',
    'Ball carrier faces only the back four with space behind them',
    'Winger runs between right back and centre back to receive the through ball, dribbles to the box and passes across behind the defenders to the back post.',
    NULL, 130, 130, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left midfielder (Iniesta)', 'Beats the midfield line by dribble and one-two, then threads the ball between full back and centre back'),
    (2, 'Attacking midfielder (Silva)', 'Wall pass for the one-two'),
    (3, 'Winger (Riera)', 'Reads the moment, runs in behind, carries into the box and squares behind the defenders'),
    (4, 'Striker (Negredo)', 'Attacks the back post ahead of the centre back'),
    (5, 'Far-side full back (Iraola)', 'Alone provides width on the weak side')
) AS v(so, role, job);

-- 45. pp.131-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch.2 Middle zone - Attacking in behind the defensive line (2)', 'Striker drops, lofted ball into vacated space',
    'Opponent keeps good distances in a middle block but does not press the ball carrier; the striker comes short and his centre back follows, opening space behind the back four.',
    'Playmaker unpressed on the ball as the striker drags a defender out',
    'Lofted pass in behind for a wide attacker running into the space, who carries into the box and crosses short to the back post for a runner from deep.',
    NULL, 131, 131, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (J. Martinez)', 'Drops short to pull the centre back out of the line'),
    (2, 'Playmaker (Xavi)', 'Clips the ball behind the back four into the vacated space'),
    (3, 'Wide attacker (Mata)', 'Runs onto the ball ahead of the defenders, dribbles in, short cross to back post'),
    (4, 'Second striker (Llorente)', 'Run from deep to the back post to pressure the defender')
) AS v(so, role, job);

-- 46. pp.132-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch.2 Middle zone - Attacking in behind the defensive line (3)', 'Full back give-and-go, run in behind',
    'Goalkeeper pressed with no short option goes long to the left; the midfielder heads back to the quick full back who passes inside to the playmaker and keeps sprinting forward past an unbalanced midfield and a static back line (Italy 4-4-2 diamond).',
    'Opponent midfield line unbalanced, defenders static and facing the ball',
    'Playmaker returns the ball into the space behind the line at the right moment; the full back finishes with two touches.',
    '4-1-2-1-2', 132, 132, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Casillas)', 'Under pressure, long ball to the left side'),
    (2, 'Midfielder (Fabregas)', 'Wins the header under pressure and knocks back to the full back'),
    (3, 'Left full back (J. Alba)', 'Gets to the second ball first, passes inside, sprints in behind the defensive line'),
    (4, 'Playmaker (Xavi)', 'Reads the run and plays into space behind the defence with correct timing')
) AS v(so, role, job);

-- 47. pp.133-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch.2 Middle zone - Attacking in behind the defensive line (practices)', 'Pass count then release runner behind line',
    'Team builds a short-pass sequence (6-8 passes) in front of the defensive line, then plays the ball into the zone behind it for a teammate running forward; everyone else then moves up into the new zone to support and finish.',
    'Possession settled in front of the line and a runner starting from behind it',
    'Change of rhythm from circulation to a penetrating ball, with the whole team arriving to finish quickly (1-touch, crosses from wide).',
    NULL, 133, 137, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'Mix short passes to feet with medium/long passes into space'),
    (2, 'Runners (wide forwards, full backs, No.9)', 'Time very quick runs into the zone behind the line'),
    (3, 'Rest of team', 'Push up immediately behind the ball to support'),
    (4, 'Defenders out of possession', 'On regain, counter and finish within 6-8 seconds')
) AS v(so, role, job);

-- 48. pp.139-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch.3 High zone - intro', 'Draw the high press, then go long or switch',
    'Against the rare opponents who press high, the team keeps short passes to feet with many support movements, pulling the opponents into one area, then suddenly changes rhythm.',
    'Opponents committed to one area and unbalanced with space behind them',
    'Either one long pass beats the pressing block into space behind the defence, or the play is switched to the weak side and the attack goes in behind there.',
    NULL, 139, 139, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players near the ball', 'Short passes and constant support to attract pressure'),
    (2, 'Ball carrier', 'Recognises the moment and plays the long pass or the switch'),
    (3, 'Forwards', 'Run behind the high line as soon as the press is beaten')
) AS v(so, role, job);

-- 49. pp.140-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch.3 High zone - Building up play against opponents who press high (1)', 'Rondo escape on flank, run behind high line',
    'Russia (3-4-1-2) commit four players to press Spain''s left side in the low zone; Spain form a 4(+2)v4 rondo shape with players at top, bottom, inside and wide, using first-time passes to reach the free man.',
    'Four opponents press the ball in Spain''s low zone on one flank',
    'Once through the press the free wide player plays down the line for a midfielder who checked away and ran behind the high defensive line, who cuts back to a runner from behind.',
    '3-4-1-2', 140, 141, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Capdevila)', 'Under pressure, plays first time to the supporting midfielder'),
    (2, 'Holding midfielder (Alonso, Senna)', 'Take positions with good angles and distances; one-touch to the free man'),
    (3, 'Left winger (Iniesta)', 'Free man wide; with time, plays the ball down the line into space'),
    (4, 'Top player (Fabregas)', 'Gives length, checks away then runs behind the high line on the flank, dribbles into box'),
    (5, 'Centre back (Marchena)', 'Depth support at the bottom of the rondo'),
    (6, 'Late runners (Silva, Guiza)', 'Run forward from the centre and right to receive the cut-back')
) AS v(so, role, job);

-- 50. pp.142-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch.3 High zone - Building up play against opponents who press high (practices)', 'Escape pressing zone, then fast attack',
    'Build-up from the goalkeeper in a tight zone under pressure; after a set number of passes (about 8) the team plays out of the zone to a teammate beyond a line and everyone except one player sprints forward to support a fast attack with a numerical edge (5v4, 4v3).',
    'Pass count completed and an opening to the attacker beyond the pressing zone',
    'Turn press resistance into a fast attack on a short-handed defence.',
    NULL, 142, 146, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Starts the build-up into the zone'),
    (2, 'Players in the zone', 'Keep the ball with 1-2 touches, then pass forward and run across to support quickly'),
    (3, 'Forward beyond the line', 'Receives the release pass and leads the fast attack'),
    (4, 'One holding player', 'Stays back in the zone as rest defence')
) AS v(so, role, job);

-- 51. pp.142-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_defend', 'Ch.3 High zone - possession and pressing transition games', 'OPEN with ball, CLOSE on loss',
    'In tight possession games the team spreads out at good angles when it has the ball (OPEN) and on losing it every player moves in around the ball zone to press immediately (CLOSE), with the opponent given only a few seconds.',
    'Ball lost in a congested area',
    'Win the ball back at once by closing time and space, then reopen and restart possession.',
    NULL, 142, 153, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players', 'Press the new ball carrier immediately'),
    (2, 'Other players', 'Collapse in around the ball zone to cut short passes'),
    (3, 'Everyone after regain', 'Open up again to original wide positions')
) AS v(so, role, job);

-- 52. pp.147-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch.3 High zone - Building up play against opponents who press high (2)', 'Own-half rondo, switch to far full back',
    'From a deep throw-in on the left vs a Belgian 4-2-3-1 pressing high, Spain keep the ball in a diamond 4(+3)v4 (centre back bottom, holding mid top, full back left, other centre back right, three midfielders inside), drawing the press to that side.',
    'Opponents drawn into the left half of Spain''s pitch',
    'Quick switch to the far full back using full width into the big space in the opponents'' middle zone, who carries fast while four teammates sprint to support and finish.',
    '4-2-3-1', 147, 153, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Riera)', 'Checks away on the throw-in, receives, then moves for immediate support'),
    (2, 'Left back (Capdevila)', 'Throws in and joins the rondo on the left'),
    (3, 'Inside midfielders (Busquets, Xavi, Riera)', 'Pass, one-twos and movement to circulate from side to side'),
    (4, 'Right centre back (Pique)', 'Plays the switching pass to the right back'),
    (5, 'Right back (Arbeloa)', 'Holds full width, receives in space and dribbles forward quickly'),
    (6, 'Attackers (Silva, Villa, Xavi)', 'Sprint forward inside and outside the box; Silva receives and cuts inside to shoot')
) AS v(so, role, job);

-- 53. pp.157-157
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'set_piece', 'Ch.4 Low zone transition - Quick transition to attack when defending a corner kick', 'Defending corner: all in box set-up',
    'When defending a corner, every Spanish player is in the box: one on the near post, two in front of the goalkeeper (near and far post), the rest in a 4-2-1 shape.',
    'Opponent corner kick',
    'Protect the box while keeping players ready to break out the moment the ball is won or cleared.',
    NULL, 157, 157, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near post player', 'Guards the near post'),
    (2, 'Two players by the goalkeeper', 'Cover near and far post areas in front of the keeper'),
    (3, 'Remaining outfielders', 'Zonal 4-2-1 lines in the box, fastest players ready to break')
) AS v(so, role, job);

-- 54. pp.157-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch.4 Low zone transition - Quick transition to attack when defending a corner kick', 'Corner clearance counter on opposite flank',
    'Corner ball goes through to the far side (or the keeper catches and rolls it out to the flank opposite the corner); the nearest player races to it while a teammate makes a diagonal cutting run behind the opponent to receive and carry over halfway, with others sprinting up.',
    'Ball won or cleared towards the side away from where the corner was taken',
    'Fast break with equal numbers (4v4+2): wide runners stay out of the box to leave space for the striker''s run between the centre backs; finish in roughly 10-15 seconds.',
    NULL, 157, 164, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player (Silva)', 'Sprints to the loose ball and releases first time'),
    (2, 'Full back (Capdevila)', 'Diagonal cutting run in behind the opponent, receives and dribbles past halfway'),
    (3, 'Central creator (Iniesta)', 'Supports inside, receives, beats men with feints and threads the final pass'),
    (4, 'Wide forward (Torres)', 'Overlaps outside and stays wide, out of the box, to free space'),
    (5, 'Striker (Villa)', 'Goes central and runs between the two centre backs for a first-time finish'),
    (6, 'Runners from the box', 'Three players break: near post, far post and one arriving behind')
) AS v(so, role, job);

-- 55. pp.165-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch.4 Low zone transition - Playing quickly from back to front: exploiting 1v1, 2v1 or 2v2 situations in the final third (1)-(2)', 'Win second ball, first-time long ball into channel',
    'With 8v8 packed into Spain''s half after an opponent long ball, a Spanish defender beats his man to the loose or second ball and immediately plays a one-touch long pass up the flank into the empty high zone for a forward against a single defender.',
    'Defender first to the second ball with the opposition crowded in Spain''s half',
    'Forward wins the 1v1 (dribble inside onto the strong foot, or flick past and cross short for a runner from deep) and the attack ends in 6-11 seconds.',
    NULL, 165, 166, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back / centre back (Capdevila, Marchena)', 'Quickest to the ball, one-touch long pass up the line into free space'),
    (2, 'Target forward (Torres, Guiza)', 'Chases into the channel, battles or heads the ball past the defender'),
    (3, 'Second striker (Villa)', 'Picks up the knock-on, beats his man 1v1 and shoots'),
    (4, 'Late runner (Riera)', 'Arrives from deep ahead of his marker for the short cross')
) AS v(so, role, job);

-- 56. pp.167-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch.4 Low zone transition - Playing quickly from back to front (3)', 'Press isolated carrier, ball behind last defender',
    'Opponent (Chile 4-3-3) plays to the flank in Spain''s half and the passer runs inside, leaving the receiver without support; a midfielder presses him, wins it and passes straight into the free space in the high zone behind the last defender.',
    'Ball carrier in Spain''s half with no passing options',
    'Forward sprints 1v1 at the defender and pressures the goalkeeper; a poor clearance is pounced on and finished within about 7 seconds.',
    '4-3-3', 167, 168, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder (Alonso)', 'Presses the unsupported carrier, wins the ball, immediate pass into space behind the last defender'),
    (2, 'Forward (Torres)', 'Sprints onto the pass, pressures defender and keeper'),
    (3, 'Second striker (Villa)', 'Follows up to collect the clearance and lob the keeper')
) AS v(so, role, job);

-- 57. pp.169-170
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch4 Playing Quickly from Back to Front: Exploiting 1v1, 2v2 or 2v1 Situations in the Final Third', 'Isolate and attack the direct opponent 1v1/2v2',
    'After quick circulation in midfield, the ball reaches a forward who is isolated against his marker (or two attackers against two defenders) with no other players involved.',
    'Forward receives facing a single marker with space around him',
    'Beat the man with dribbling/change of direction or a 2v2 combination and finish quickly before cover arrives.',
    NULL, 169, 170, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-carrying forward', 'Take on the direct opponent at speed, finish within a few touches'),
    (2, 'Second attacker (2v2)', 'Combine (one-two, overlap) with the carrier against the two nearest defenders'),
    (3, 'Midfield players', 'Keep the ball in the middle until the isolated runner is ready, then release him')
) AS v(so, role, job);

-- 58. pp.171-174
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch4 Playing Quickly from Back to Front: Press, Win the Ball & Quick Counter Attack with a Long Ball', 'Regain then immediate long ball to front two',
    'Team defends compactly in its own half (4-4 block) and leaves two forwards high; on winning the ball it hits a long pass to a forward within 3-5 seconds.',
    'Ball won in the low zone by the block',
    'Exploit the temporary 2v2 or attacker-v-defender situation upfield before the opponent''s rest defence is organised.',
    NULL, 171, 174, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner / nearest defender or midfielder', 'Quality first-time long pass to a forward''s feet or into the box'),
    (2, 'Front two (start central)', 'Ask for the ball on the flanks, control in space and attack 2v2 or 1v1 vs centre backs'),
    (3, 'Forward on the ball', 'Dribble out and switch to the far-side runner, or beat his defender and shoot'),
    (4, 'Midfield runners', 'Break forward to support once the long ball is played')
) AS v(so, role, job);

-- 59. pp.171-174
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'out_of_possession', 'Ch4 Press, Win the Ball & Quick Counter Attack with a Long Ball', 'Ball-oriented block shifts to the switched side',
    'A 4-4 block defends ball-oriented; when the opponent suddenly moves the ball to the other side of the pitch the whole unit must slide across together.',
    'Opponent switches play (new ball on far side)',
    'Keep the block compact and re-establish pressure on the new ball side before the opponent can exploit the gap.',
    NULL, 171, 174, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player to new ball', 'Close down the receiver quickly'),
    (2, 'Back four and midfield four', 'Communicate and slide across as one unit, staying compact'),
    (3, 'Ball-far players', 'Tuck in to protect the centre')
) AS v(so, role, job);

-- 60. pp.175-180
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch4 Transition to Attack from the Low Zone: Passing through the Lines', 'Dribble-and-release through the lines',
    'Spain win a 1v1 deep in their own box and play upward zone by zone (3v2 low, 4v4 middle, 3(+1)v4 high); each carrier dribbles until closed, then passes to the next man, who drives inside and slips a through ball between full back and centre back for the striker (Villa from Puyol-Iniesta-Xavi, 15 seconds).',
    'Defender wins the ball in a 1v1 near his own byline',
    'Cross every line of the opponent in a few passes and finish through the gap behind the back four before it reorganises.',
    '3-5-2', 175, 180, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Puyol)', 'Win the duel, carry the ball forward and find a midfielder in the middle zone'),
    (2, 'Midfielders (Iniesta, Xavi)', 'Check away from markers, receive to feet, dribble with changes of direction until closed, then pass on'),
    (3, 'Inside forward/playmaker on the ball (Xavi)', 'Drive inside and thread the ball into the full back-centre back gap'),
    (4, 'Striker (Villa)', 'Time the run behind the back four, take the keeper on and score')
) AS v(so, role, job);

-- 61. pp.181-187
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch4 Transition to Attack from the Low Zone: (4 v 3 +1 Situation)', '4v3+1 drive frees the flank runner',
    'After a clearance and won second ball, Spain break with 4 against 3 plus a recovering defender; the midfield carrier draws the full back, which opens the flank for the wide player, who then cuts inside and finds the far-side forward arriving in support (Busquets-Xavi-Navas-Villa, 10 seconds).',
    'Defensive midfielder wins the loose ball after a header clears a long ball',
    'Use the extra man in transition to pull a defender out and release the free runner into the box.',
    '4-4-1-1', 181, 187, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Pique)', 'Win the aerial duel against the long ball'),
    (2, 'Holding midfielder (Busquets)', 'Win the second ball and pass into the path of the advancing midfielder'),
    (3, 'Central carrier (Xavi)', 'Dribble forward until the full back closes, then release the overlapping wide man at the right moment'),
    (4, 'Wide player (Navas)', 'Sprint up the flank, carry the ball inside and pass when the box is closed'),
    (5, 'Far-side forward (Villa)', 'Come across to support, directional first touch, shoot on the second')
) AS v(so, role, job);

-- 62. pp.183-183
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_defend', 'Ch4 Transition to Attack from the Low Zone: Group A practice', 'Lose the ball, switch the point of defence',
    'Outnumbered team (7v9) that has just finished or lost a counter immediately faces a new attack in the opposite direction and must switch its defensive organisation to that side.',
    'Own attack ends / opponent restarts on the other side',
    'Reform a compact defensive shape in straight lines on the new ball side despite being outnumbered.',
    NULL, 183, 183, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All outfield players', 'React instantly, recover and get compact in straight lines'),
    (2, 'Nearest player', 'Pressure the new ball carrier to delay'),
    (3, 'Back line', 'Shift across to the ball side and protect the goal')
) AS v(so, role, job);

-- 63. pp.184-187
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch4 Transition to Attack from the Low Zone: 6v6 Quick Reactions / 4v5 Fast Break', 'Fast forward passing before rest defence reforms',
    'After collective pressing wins the ball (often while outnumbered), the team plays quickly to the keeper or forward and everybody sprints into the other half, attacking with forward passes at pace while only part of the opponent can get back.',
    'Collective press regains possession',
    'Exploit the opponent''s lack of defensive shape with a 5v3 or 4v2 break and score within about 10 seconds.',
    NULL, 184, 187, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing group', 'Press together to win the ball, then release it in 2 touches'),
    (2, 'Goalkeeper', 'Restart the attack immediately to a free teammate'),
    (3, 'All attackers', 'Sprint across to the attacking half, play forward passes at pace'),
    (4, 'Ball carrier in 4v3(+1)', 'Fast, quality dribble into the next zone')
) AS v(so, role, job);

-- 64. pp.188-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch4 Fast Break Attack', 'Read the weak pass, break 1v1 (+2v2)',
    'With the opponent pushed high, the striker intercepts an under-hit back pass at halfway and drives at the last defender while two midfielders arrive fast from behind; they make opposite (crossing) overlapping runs and the striker lofts to one for a volley, the other following in for the rebound (Villa-Xavi-Fabregas, 12 seconds).',
    'Opponent plays a weak back pass with many players high',
    'Turn the interception into a 1v1 plus 2v2 break into empty space and finish with numbers arriving.',
    NULL, 188, 192, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Villa)', 'Anticipate and intercept the back pass, dribble at the defender, choose the pass'),
    (2, 'Supporting midfielders (Xavi, Fabregas)', 'Sprint from behind, make opposite overlapping runs to give two options'),
    (3, 'Second runner', 'Follow the shot to finish any rebound')
) AS v(so, role, job);

-- 65. pp.193-198
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch4 Transition to Attack with a Numerical Disadvantage in the Opposition Half', 'Keep it outnumbered, then hit the weak side',
    'Spain win the ball and carry it into the opposition half where they are 4v7; instead of forcing it they keep possession with shielding and quick support until a defender is pulled out, then attack the space on the weak side of the line (Puyol-Navas-Torres-Fabregas-Iniesta, World Cup final winner).',
    'Regain with only a few players able to join; defensive line becomes unbalanced',
    'Survive the numerical disadvantage on the ball until the defence is imbalanced, then finish on the weak side.',
    '4-2-3-1', 193, 198, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (Puyol, pressure from Ramos, cover Fabregas)', 'Press together to win it and dribble out of the box'),
    (2, 'Wide carrier (Navas)', 'Use stamina to dribble past opponents and keep running to support'),
    (3, 'Possession group', 'Protect the ball with the body, check away before receiving, give quick support angles'),
    (4, 'Striker (Torres)', 'Look for the runner behind the line'),
    (5, 'Late runners (Fabregas, Iniesta)', 'Straight run into the box for rebounds; spot the imbalance and play/arrive on the weak side')
) AS v(so, role, job);

-- 66. pp.201-201
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch5 The Transition from Defence to Attack in the Middle Zone (intro)', 'Middle-zone transition: first pass or fast dribble',
    'Common thread in Spain''s middle-zone transition goals: the first pass after the regain goes quickly into space behind an unbalanced defence, synchronised with a runner; or, when the opponent retreats or leaves big gaps, the second player dribbles forward quickly while teammates check away and run behind the line.',
    'Ball won in the middle third with the opponent unbalanced or retreating',
    'Choose the right option (early ball in behind vs fast carry) and finish with combination play.',
    NULL, 201, 201, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Quick, quality first pass into space behind when the defence is unbalanced'),
    (2, 'Second player (first receiver)', 'Dribble at speed up to the opposition when gaps open'),
    (3, 'Teammates', 'Check away from markers and run forward/behind to support')
) AS v(so, role, job);

-- 67. pp.202-211
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch5 Quick Counter Attack in a 2 v 2 Situation with Curved Outside Run', 'First-touch pass and curved outside run',
    'Two forwards mark the opponent''s centre backs; the full back intercepts a pass and with his first touch plays into space high up where a forward has moved, creating a 1v1 against a centre back. That forward takes the ball outside, the partner makes the opposite run into the box, the carrier cuts back inside and passes to the partner arriving from behind (Capdevila-Torres-Villa, 8.6 seconds).',
    'Interception in midfield while the two strikers are level with the centre backs',
    'Turn a 2v2 against the centre backs into a goal with an outside curved run and an inside cutting run.',
    '4-4-2', 202, 211, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Capdevila)', 'Read the pass, intercept and play first time into space behind'),
    (2, 'Receiving forward (Torres)', 'Curved outside run to receive in behind, take the ball outside then dribble inside'),
    (3, 'Second forward (Villa)', 'Opposite run into the area, arrive from behind to meet the pass and finish first time'),
    (4, 'Wide midfielder in support', 'Move forward from the middle zone for a pass out wide/first-time finish')
) AS v(so, role, job);

-- 68. pp.212-218
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'out_of_possession', 'Ch5 Winning the Ball in the Middle Zone, Quick Pass and Counter Attack', 'Trap the forward run, regain, pass in behind',
    'In a 4-4-2, when the opponent''s full back carries forward and feeds a midfielder running between the striker and central midfielder, the left back and central midfielder squeeze him and win the ball, then the team must play forward or in behind within about 5 seconds.',
    'Opponent midfielder receives running into the gap between striker and midfield line',
    'Win the ball in the middle zone with ball-oriented defence and immediately exploit the space behind the opponent''s advanced players.',
    '4-2-3-1', 212, 218, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (Capdevila)', 'Step in to press the receiver from the side'),
    (2, 'Central midfielder (Alonso)', 'Close from inside to trap and win the ball'),
    (3, 'Ball-side forward (Villa)', 'Stay available wide to take the first pass after the regain'),
    (4, 'Back four and centre mids', 'Ball-oriented defence to stop passes into the final zone'),
    (5, 'Wide midfielders', 'Receive the immediate pass behind the opponent''s line')
) AS v(so, role, job);

-- 69. pp.212-218
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch5 Group B: Dribbling the Ball Inside to Create Passing Options in Behind the Defensive Line (4-4-2 / 4-4-1-1 Pattern of Play)', 'Wide man dribbles inside, three runs behind',
    'After the regain the wide forward/midfielder dribbles inside from the flank while three teammates offer different options: one runs into space, one comes to feet, one makes a diagonal run behind; when two defenders close the dribbler, the diagonal runner is released (Villa to Silva, 10.9 seconds).',
    'Wide player receives the first pass after the regain with 3(+1) v 3(+2)',
    'Draw defenders onto the inward dribble and slip the free runner in behind the line.',
    '4-2-3-1', 212, 218, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forward on the ball (Villa / left midfielder)', 'Dribble inside, choose among three options at the right moment'),
    (2, 'Striker (Torres)', 'Opposite run outside/near post wanting it in space'),
    (3, 'Central midfielder from deep (Xavi / attacking mid)', 'Support to feet for a one-two or far-post run'),
    (4, 'Far-side wide midfielder (Silva)', 'Come inside, diagonal cutting run into the area behind the defence')
) AS v(so, role, job);

-- 70. pp.219-224
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch5 Creating a Numerical Advantage in the Centre & Quick Counter Attack using the Flank', 'Centre back carries into midfield overload',
    'A forward sprints back to press an opponent from behind and the ball breaks to Spain''s defence; the centre back has free space, dribbles forward between two opponents into the final third creating 5(+1)v5, passes left, and the ball is moved quickly to the forward who has run forward into the free space on the flank. In the box one defender presses him, another covers, a striker''s near-post run drags a centre back away and the centre back continues his run to score (Villa-Puyol-Pique-Xavi-Villa-Pique, 13.8 seconds).',
    'Forward''s back-press wins the ball; centre back finds free space in front of him',
    'Use the carrying centre back as the extra man in the centre, then switch to the flank and finish with coordinated box runs.',
    NULL, 219, 224, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Villa)', 'Sprint back to press the ball from behind, then run forward into space on the flank'),
    (2, 'Centre back (Pique)', 'Dribble forward into midfield to create the overload, keep running into the box'),
    (3, 'Central midfielder (Xavi)', 'Quick pass out to the flank runner'),
    (4, 'Striker (Torres)', 'Near-post run taking the centre back with him'),
    (5, 'Box runners (practices)', 'Coordinate near post, far post and one arriving from behind for the cross')
) AS v(so, role, job);

-- 71. pp.225-225
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch5 Transition from Defence to Attack in the Middle Zone - Creating a Numerical Advantage in the Centre & Quick Counter Attack using the Flank (practice 4)', 'Middle-zone regain, quick ball to wide outlet',
    'Team defends in a 4-4-2 mid block; on winning the ball centrally it releases a wide support player who has stayed out on the flank, then central players sprint into the box for the cross.',
    'Ball won in the middle zone',
    'Reach the wide outlet within about 4-6 seconds and finish with a cross within about 10-12 seconds.',
    NULL, 225, 225, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (central midfielder)', 'Pass quickly to the wide support player'),
    (2, 'Wide support player', 'Hold width during defence, deliver early cross/pass'),
    (3, 'Central midfielders and forwards', 'Run from the central zone into the box to attack the cross')
) AS v(so, role, job);

-- 72. pp.226-227
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_defend', 'Ch5 Goal Analysis: Quick Pass in Behind the Defensive Line after Regaining Possession (1)', 'Narrow up and stop the forward dribble',
    'After losing the ball in midfield, all players tuck inside, centre backs step up close to their direct opponents and full backs drop back and inside; the nearest midfielder (Busquets) steps to the carrier.',
    'Ball lost in the middle zone, carrier tries to dribble forward',
    'First stop the carrier running forward, then cut his passing options so the ball can be won back.',
    NULL, 226, 227, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Busquets)', 'Step up and press the carrier, anticipate the next touch'),
    (2, 'Centre backs', 'Push up and close the distance to their direct opponents'),
    (3, 'Full backs', 'Recover back and inside'),
    (4, 'All outfielders', 'Shift inside to compact the centre')
) AS v(so, role, job);

-- 73. pp.226-229
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch5 Goal Analysis: Quick Pass in Behind the Defensive Line after Regaining Possession (1-3)', 'Regain, then instant pass in behind',
    'On a middle-zone regain Spain look immediately for a runner attacking the space behind a disorganised or high, unbalanced back line (in behind a full back or between the centre backs), with a second runner arriving from the opposite side.',
    'Ball won while the opponent''s line is high, unbalanced or still reorganising',
    'Runner arrives faster than the defenders chasing him and finishes or squares to the free teammate within about 6-8 seconds.',
    NULL, 226, 229, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (Busquets/Capdevila/Silva)', 'Play the first forward pass at once into space ahead of the runner'),
    (2, 'Striker (Negredo/Torres)', 'Ask for the ball between the centre backs or take a directional first touch and slip the runner'),
    (3, 'Opposite-side attacker (Silva/Villa)', 'Run diagonally from the far side into free space behind the line'),
    (4, 'Midfield runner (Fabregas)', 'Run in behind the full back, then pass across to the better-placed teammate if the keeper comes')
) AS v(so, role, job);

-- 74. pp.230-231
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_defend', 'Ch5 Session: Regaining Possession Quickly (practices 1-2)', 'Close the ball zone immediately on loss',
    'When possession is lost every nearby player sprints to close space around the ball, creating a numerical advantage in the ball zone to stop forward passes, dribbles and shots.',
    'Possession lost',
    'Win the ball back within 6-8 seconds and then keep it again.',
    NULL, 230, 231, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'Close down the carrier at once'),
    (2, 'Players around the ball', 'Outnumber the opponent around the ball, block forward passing lanes'),
    (3, 'Far players', 'Read the change and react, anticipating the regain')
) AS v(so, role, job);

-- 75. pp.232-234
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch5 Session: Regaining Possession and Fast Break Attack (practices 3-5)', 'Fast break with combinations and runs behind',
    'After a midfield regain the ball goes forward quickly to attackers outside the block; carrier dribbles at pace, quick combinations and well-timed passes release runs behind, often creating 2v1s.',
    'Ball won by the midfield press',
    'Finish every counter quickly (within about 6-8 seconds) with an accurate, well-weighted final pass.',
    NULL, 232, 234, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Pass out at once to an attacker who is free'),
    (2, 'Attackers outside the block', 'React instantly, take position to attack the 2v1'),
    (3, 'Carrier', 'Dribble forward at pace, time the pass for the run in behind')
) AS v(so, role, job);

-- 76. pp.234-234
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'out_of_possession', 'Ch5 Session: Fast Break Attacks in a Dynamic 4 Zone 11 v 11 Transition Game (scenario 2)', 'Mid block presses when ball enters middle third',
    'Team in a 4-4-2/4-3-3 waits as the opponent builds from its keeper and starts pressing only when the ball reaches the middle zone.',
    'Ball enters the middle zone',
    'Win the ball in midfield with space behind the opponent to counter into, finishing in 6-8 seconds.',
    NULL, 234, 234, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front line and midfield', 'Hold shape until the trigger, then press together'),
    (2, 'Back line', 'Defend the final zone, stay ready to step up')
) AS v(so, role, job);

-- 77. pp.235-235
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'out_of_possession', 'Ch5 Goal Analysis: Breaking from the Middle Zone: Exploiting the Weaknesses in the Opposition Defence', 'Ball-oriented defence forces pass inside',
    'Spain''s ball-oriented defence makes it hard for the carrier to play out down the flank, steering the pass into the centre where a midfielder (Iniesta) is waiting to intercept.',
    'Opponent tries to build out from the flank',
    'Intercept the forced central pass and launch a fast transition.',
    NULL, 235, 235, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players and full back', 'Close the line down the flank'),
    (2, 'Central midfielder (Iniesta)', 'Read the forced inside pass and intercept')
) AS v(so, role, job);

-- 78. pp.235-240
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch5 Goal Analysis + Session: Breaking from the Middle Zone: Exploiting the Weaknesses in the Opposition Defence', 'Read the numbers, attack the imbalance',
    'After a central interception the carrier plays a one-two with the striker and drives forward with options on both sides; he reads the defenders'' choices and passes into the side where the line is unbalanced. Practices train recognising 3v2, 2v1, 1v1 or 7v5 overloads and choosing the right solution.',
    'Regain with the opposition defence short of numbers or out of balance',
    'Exploit the free space created by the imbalance and finish within about 9 seconds.',
    NULL, 235, 240, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Interceptor/carrier (Iniesta)', 'One-two with the striker, dribble forward, pick the free side'),
    (2, 'Striker (Torres)', 'Give the return pass, then run into the space on the unbalanced side'),
    (3, 'Opposite forward (Villa)', 'Provide the second option on the far side'),
    (4, 'Supporting players', 'Run into space, some in behind the defensive line')
) AS v(so, role, job);

-- 79. pp.243-269
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_defend', 'Ch6 The Transition from Defence to Attack in the High Zone; Goal Analyses (1-3); Sessions 249-253 and 265-269', 'Re-press in the same area where lost',
    'When the ball is lost high up the pitch the nearest player presses the new carrier to stop a dribble or a quick pass, while players nearby close down the nearest opponents and the whole team squeezes space; players sprint from behind to press if needed.',
    'Ball lost in the high zone (e.g. blocked through ball or cleared header)',
    'Win the ball back immediately in the same area (ideally the same grid) and attack again.',
    NULL, 243, 269, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player (Senna/Iniesta)', 'Sprint to press the new carrier, often from behind'),
    (2, 'Players nearby (Arbeloa/Xavi)', 'Close the closest receivers, anticipate the next pass and intercept'),
    (3, 'Whole team', 'Squeeze up and compress the space around the ball')
) AS v(so, role, job);

-- 80. pp.243-269
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'out_of_possession', 'Ch6 Goal Analysis: Pressing High Up the Pitch: Transition from Defence to Attack (1-2); Session practices 261-263, 268-269', 'High press without fouling, force errors',
    'Spain press the opponent''s build-up high: the presser closes the carrier (often a full back on the flank) leaving no space to dribble or pass forward, blocking passes out wide and forcing play inside, while teammates close the ball zone and remove options so the next player can pick off the poor pass.',
    'Opponent keeper or back plays out to a defender in the high zone',
    'Force a hurried or poor pass and win the ball near the opposition goal without committing a foul.',
    NULL, 243, 269, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Presser (Villa/Alonso)', 'Close the carrier fast, block the forward/outside pass with the body'),
    (2, 'Midfielders and attackers', 'Cooperate to close the ball zone and passing options'),
    (3, 'Next player (Busquets)', 'Anticipate and beat the direct opponent to the poor pass')
) AS v(so, role, job);

-- 81. pp.243-269
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch6 The Transition from Defence to Attack in the High Zone; Goal Analyses 244-248, 260, 264; practice 263', 'High regain, runs in behind, finish fast',
    'As soon as the ball is won high, teammates run into the gap between full back and centre back or between the centre backs while the back line is static; the winner passes to a better-placed teammate at the right moment. If nobody is in the box, the carrier dribbles inside to buy time for support runs.',
    'Ball won in the high zone',
    'Exploit the imbalance with a runner who has momentum over stationary defenders and finish within about 4-6 seconds.',
    NULL, 243, 269, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (Fabregas/Xavi/Busquets)', 'Pass at the right time to the teammate nearer goal, or dribble inside to create time'),
    (2, 'Runner (Iniesta/Torres/Silva)', 'Run in front of the carrier into the gap between defenders, ask for the ball'),
    (3, 'Support players (Cazorla, centre forward)', 'Arrive from behind and occupy the box')
) AS v(so, role, job);

-- 82. pp.244-249
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'in_possession', 'Ch6 Goal Analysis: Transition from Attack to Defence & then Defence to Attack (1, 3); Session practice 1', 'Long switch to the weak side',
    'After short passing on one side draws the opponent across, a midfielder or full back hits a long ball to change direction and rhythm toward the weakest side of the opposing back line, with a runner moving into the target area.',
    'Opponent shifts over to close down the ball side',
    'Attack the weak side before it can shift; if the switch is cut out the team is already close enough to press the second ball.',
    NULL, 244, 249, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Switching player (Xavi/Capdevila)', 'Spot the weak side and play the long diagonal'),
    (2, 'Weak-side runner (Fabregas/Silva)', 'Move into the zone the ball is played into'),
    (3, 'Ball-side players', 'Keep short combinations to draw the opponent over')
) AS v(so, role, job);

-- 83. pp.254-259
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spain-attacking-sessions-140-practices-from-goal-analysis-of-the-spanish-nationa'), 'to_attack', 'Ch6 Goal Analysis + Session: Winning the Ball & One-Two Combination High Up the Pitch', 'High regain, draw defender, one-two through',
    'After pressing wins the ball high, the carrier dribbles at the line to draw a defender in a 4v4, then plays a one-two with a teammate who offers support at the right angle near the edge of the box, receiving the return in the space behind.',
    'Ball won high with a balanced 4v4 in front',
    'Break the last line with a one-two and finish first time within about 4-5 seconds.',
    NULL, 254, 259, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Carrier (Fabregas)', 'Dribble to attract a defender, play the first pass accurately and run behind'),
    (2, 'Support player (Silva)', 'Offer at the correct angle and body shape, return first time into space'),
    (3, 'Pressing players (Silva/Capdevila)', 'Close the build-up so the midfielder can anticipate and win the ball')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('2108-coaching-book-spain-attacking-sessions-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
