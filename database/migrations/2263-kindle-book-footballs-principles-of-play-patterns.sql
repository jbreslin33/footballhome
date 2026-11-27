-- 2263 📚 Coaching book patterns: "Football's Principles of Play" (Peter
-- Prickett) — Kindle library (spreads s001–s140 from Kindle Cloud Reader).
-- Every spread read by readers; each distinct team behaviour written up in
-- OUR OWN WORDS with who does what.  Front matter, pure-technique practices
-- and sources left out.  Owner's personal library.  (James 11/27 Kindle picks)
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    method_note = 'A coach''s handbook on the principles of play: each attacking principle (overloads, penetration, support, width, mobility, improvisation, surprise) and defending principle (delay, depth, balance, concentration, discipline, show outside, compactness) explained with pro examples (Klopp''s Liverpool, Guardiola''s Barcelona, Ferguson''s United, Mourinho''s Inter), then alternative principles (positional play, diamonds and triangles, counter-pressing) and a practice section showing which game trains each principle. Patterns are the match behaviours in our words; pure 1v1 technique practices left out. Kindle edition: page numbers are screen spreads.'
WHERE slug = 'kindle-footballs-principles-of-play';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play');

-- 1. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Overloads and sub-phases', 'Press high to outnumber the ball',
    'Overloads are short sub-phases whose owner depends on pitch area and tactics: a side that sits off in its own half gifts the opponent a spare man, while a side that presses in the opponent''s half aims to outnumber the ball carrier.',
    'Opponent has the ball in their own half',
    'Create local numerical superiority to force a turnover instead of conceding an overload.',
    NULL, 16, 16, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest pressers', 'Close the ball so they outnumber the carrier locally'),
    (2, 'Covering midfielders', 'Step up to remove the free man')
) AS v(so, role, job);

-- 2. pp.19-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Penetration (or go forward)', 'Patient possession through the thirds',
    'Possession sides pass through the thirds: build in the defensive third, move into midfield, then create in the final third, restarting the move if no good penetrating chance appears.',
    'Settled possession, no clear forward pass',
    'Keep the ball and only penetrate when a good opening exists.',
    NULL, 19, 19, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'Build short in the defensive third'),
    (2, 'Midfielders', 'Carry the build into the central third'),
    (3, 'Attackers', 'Wait for a real opening, recycle if none')
) AS v(so, role, job);

-- 3. pp.19-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'to_defend', 'Penetration (or go forward)', 'Risky forward pass, counter-press if lost',
    'Pressing and counter-pressing teams (Guardiola, Bielsa, Klopp, Flick) accept risky penetrating passes because a failed pass becomes a chance to win the ball back high.',
    'Forward pass intercepted in the final third',
    'Turn a lost ball into an extra attack via immediate pressure.',
    NULL, 19, 20, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Attempt the penetrating pass rather than recycle'),
    (2, 'Nearby teammates', 'Counter-press the receiver at once')
) AS v(so, role, job);

-- 4. pp.19-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Penetration (or go forward)', 'Direct play into a target forward',
    'Coach chooses to skip midfield and play straight into a tall, strong striker who holds the ball up so the team can move up into support (Drogba at Chelsea, feet, chest or head).',
    'Ball won or held in the back third',
    'Penetrate quickly by bypassing the middle third.',
    NULL, 19, 21, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target centre forward', 'Hold up even poor passes with feet, chest or head'),
    (2, 'Midfielders and wide players', 'Push up into supporting positions once he retains it'),
    (3, 'Defenders', 'Play early forward into the striker')
) AS v(so, role, job);

-- 5. pp.19-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Penetration (or go forward)', 'Balls into space behind a high line',
    'When defenders use the offside line to push up and stop play into the striker, the space behind them opens; a quick attacker running onto passes beats it, so pairing forwards of different profiles stops one defensive plan killing the attack.',
    'Opponent''s back line steps up high',
    'Penetrate into the space behind instead of into feet.',
    NULL, 19, 21, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Quick forward', 'Run in behind onto balls over or through the line'),
    (2, 'Strong forward', 'Offer the alternative hold-up option to feet'),
    (3, 'Passer', 'Play into space rather than to the forward')
) AS v(so, role, job);

-- 6. pp.22-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Support', 'Diagonal support within passing range',
    'The ball carrier needs options in front, beside and behind at short to medium distance, ideally on diagonals (NE/NW/SE/SW) and not hidden behind defenders, since straight-line passes are easy to block. Xavi, Iniesta and Busquets stayed inside the shape at connecting distance so outer players always had an option.',
    'Teammate receives the ball',
    'Always give the carrier unblocked, angled passing options so possession is kept.',
    NULL, 22, 23, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Supporting players', 'Take angled spots at short or medium distance, off the defender''s shadow'),
    (2, 'Central midfielders (Xavi, Iniesta, Busquets)', 'Stay inside the shape and keep connecting distances'),
    (3, 'Support for a dribbler', 'Stay further away to give him room to beat his man')
) AS v(so, role, job);

-- 7. pp.24-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Width', 'Stretch long and wide, overload the flank',
    'In possession the team makes itself as long (centre backs to strikers) and as wide (wingers or full backs) as possible to open interior space; quick play to the flank then uses overlaps or underlaps to make a numbers-up out wide.',
    'Team in settled possession, central area crowded',
    'Open space inside and create a wide overload to make chances.',
    NULL, 24, 25, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers or full backs', 'Hold maximum width'),
    (2, 'Overlapping player', 'Run outside the man tackling the wide player'),
    (3, 'Underlapping player', 'Run inside the man tackling the wide player'),
    (4, 'Striker and centre backs', 'Hold maximum length')
) AS v(so, role, job);

-- 8. pp.25-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Width', 'Switch of play to the far side',
    'Once opponents are drawn out to one flank, space opens centrally or wide on the other side; the ball is switched in one long pass or two quick medium passes.',
    'Opponent block shifted to the ball side',
    'Attack the open weak side before the block can shift across.',
    NULL, 25, 26, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side player', 'Draw the block then play the switch'),
    (2, 'Central link player', 'Relay quickly in the two-pass switch'),
    (3, 'Far-side wide player', 'Stay wide to receive the switch')
) AS v(so, role, job);

-- 9. pp.26-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Width', 'Wide combination then low cross or cutback',
    'Crossing needs bodies in the box, which empties other areas and risks a counter, so some teams work the ball into the box for cutbacks and low crosses: the wide man combines with an inside player then drives a low ball across.',
    'Ball with the wide player near the box',
    'Create a box chance with fewer players committed than for high crosses.',
    NULL, 26, 26, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player', 'Combine with the inside player, then deliver low'),
    (2, 'Inside player', 'Offer the wall pass near the box edge'),
    (3, 'Box runners', 'Attack near post and the cutback zone')
) AS v(so, role, job);

-- 10. pp.27-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Width', 'Play narrow to stay close for regains',
    'A wide team leaves big gaps for counters, so some coaches use less width and a faster, shorter central passing game so players are near each other when the ball is lost.',
    'Team values quick recovery over stretching',
    'Keep short distances so the team can win the ball back quickly.',
    NULL, 27, 27, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players', 'Come inside and stay connected'),
    (2, 'Midfielders', 'Play quick short central passes')
) AS v(so, role, job);

-- 11. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Width (example)', 'Wide forwards tuck in, full backs overlap',
    'Ferguson''s Manchester United first used orthodox wingers (Giggs, Kanchelskis) who stretched the pitch and dribbled to cross, with Beckham drifting inside to free Neville''s overlap; the later 4-3-3 of Tevez, Ronaldo and Rooney tucked the wide men in near the striker, so full backs gave the width.',
    'Wide forward drifts inside',
    'Keep width while getting more players near the striker.',
    NULL, 28, 28, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forward (Ronaldo, Beckham)', 'Tuck inside, close to the central striker'),
    (2, 'Full back (Neville)', 'Overlap outside to provide width and crosses'),
    (3, 'Orthodox winger (Giggs, Kanchelskis)', 'Start very wide and dribble into crossing spots')
) AS v(so, role, job);

-- 12. pp.29-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'to_attack', 'Mobility/Movement', 'Sprint into attacking shape after regain',
    'On winning the ball players move quickly into an attacking shape; on a fast counter those runs go into dangerous areas that allow penetration.',
    'Possession regained',
    'Create the attacking shape and a chance before the opponent resets.',
    NULL, 29, 29, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Run into dangerous positions behind or between defenders'),
    (2, 'Supporting midfielders', 'Move up to offer the next option')
) AS v(so, role, job);

-- 13. pp.29-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Mobility/Movement', 'Crossover runs by two attackers',
    'Against a set defence two forwards cross paths so their markers are pulled across each other, freeing one to receive.',
    'Set defence, forwards tightly marked',
    'Lose markers and open space to receive.',
    NULL, 29, 30, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward one', 'Cut diagonally across his partner'),
    (2, 'Forward two', 'Cross the other way to drag his marker'),
    (3, 'Passer', 'Find whoever comes free')
) AS v(so, role, job);

-- 14. pp.29-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Mobility/Movement', 'Third-man combination',
    'Two wide players exchange passes to draw defenders, then release a third man who has run into the space they create.',
    'Defenders squeeze onto a one-two',
    'Release a free runner beyond the engaged defenders.',
    NULL, 29, 30, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First wide player', 'Start the combination'),
    (2, 'Second wide player', 'Return or lay off to set up the release'),
    (3, 'Third man', 'Time his run into the space behind')
) AS v(so, role, job);

-- 15. pp.29-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Mobility/Movement', 'Dribble to break lines',
    'Running with the ball at speed into space and close dribbling under pressure are both ways to carry the ball forward through a defence (Maradona v England 1986, Messi v Getafe).',
    'Space ahead or a single defender to beat',
    'Penetrate by carrying instead of passing.',
    NULL, 29, 31, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Run or dribble past defenders toward goal'),
    (2, 'Teammates', 'Stay away to leave him room')
) AS v(so, role, job);

-- 16. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Mobility/Movement', 'Rotation: pass, run, cover the gap',
    'A deeper player passes and then breaks forward, while a teammate shifts across to fill the space he left.',
    'Deep player releases the ball',
    'Add a forward runner without leaving a hole in the shape.',
    NULL, 30, 30, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep player', 'Pass then run forward'),
    (2, 'Adjacent teammate', 'Slide across into the vacated position')
) AS v(so, role, job);

-- 17. pp.32-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Mobility/Movement (example: off the ball)', 'Late runs and decoy movements into the box',
    'Midfielders like Platt and Lampard arrived late in the box to finish, sometimes with feints to lose markers first; Haaland moves toward the far post then darts across his defender to the near post.',
    'Ball in a crossing or final pass position',
    'Arrive unmarked in the box to finish.',
    NULL, 32, 32, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Platt, Lampard)', 'Time a late run from deep into the box'),
    (2, 'Centre forward (Haaland)', 'Fake far post, then cut in front to the near post')
) AS v(so, role, job);

-- 18. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Delay', 'Pick the pressure height',
    'The out-of-possession team chooses where to stop forward play, from very high pressure near the opponent''s goal to very low pressure in its own third, to suit personnel, ideas and the opponent.',
    'Opponent has the ball',
    'Stop the opponent playing forward quickly at the chosen height.',
    NULL, 36, 36, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'Set the agreed pressure zone'),
    (2, 'Front line', 'Start pressure only from the agreed height')
) AS v(so, role, job);

-- 19. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Delay', 'Close press with layered pressure',
    'Pressing and counter-pressing teams delay the opponent near their own goal through individual or unit pressure, set off by triggers or by a turnover; since pressing can be bypassed, layers of defenders sit behind wherever the pressure is.',
    'Pressing trigger or just lost possession',
    'Win the ball back quickly or at least stop the attack, without being bypassed.',
    NULL, 36, 36, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First presser', 'Engage the ball when triggered'),
    (2, 'Second layer', 'Sit behind the pressure to catch a bypass'),
    (3, 'Back line', 'Hold the last layer')
) AS v(so, role, job);

-- 20. pp.36-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Delay', 'Front three screen goal-kick build-up',
    'Three forwards cut off short passing from the goalkeeper and defenders: the central one blocks the straight pass, the two outside ones sit close enough to jump short passes and block passes into wide zones. Klopp''s Liverpool drilled Salah, Mane and Firmino in three-versus-six scenarios on goal kicks.',
    'Opponent goal kick or keeper build-up',
    'Stop short build-up and force a long ball with fewer pressers than receivers.',
    NULL, 36, 38, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central forward (Firmino)', 'Block the straight pass and screen the middle'),
    (2, 'Wide forwards (Salah, Mane)', 'Threaten short passes and close wide lanes'),
    (3, 'All three', 'Press together at the right moment')
) AS v(so, role, job);

-- 21. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Delay', 'Drop off and block the path to goal',
    'Instead of pressing high, the team retreats and puts bodies between the opponent and the goal to deny space and a clear route forward; individually that means body between ball and goal, blocking passes and shots.',
    'Opponent in possession, team chooses not to press',
    'Roadblock the route to goal.',
    NULL, 37, 37, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'Get goal-side and block passes and shots'),
    (2, 'Midfielders', 'Drop in front of the defence to close space'),
    (3, 'Goalkeeper', 'Last block on the path to goal')
) AS v(so, role, job);

-- 22. pp.39-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Depth', 'Pressure and cover pair (job and a half)',
    'In a 2v2 the nearest defender presses the ball, and the second sits staggered, slightly behind and at an angle, close enough to the attacker without the ball and to help his partner.',
    'Attacker receives near two defenders',
    'Pressure the ball with cover behind so one beat does not mean a break.',
    NULL, 39, 39, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing defender', 'Engage the ball carrier'),
    (2, 'Covering defender', 'Stagger behind at an angle, watch the other attacker and help')
) AS v(so, role, job);

-- 23. pp.39-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Depth', 'Set defensive line height',
    'The deepest line sits high, medium or deep between halfway and the box edge, chosen on ideas or on the strengths of both teams; offside gives the line its natural reference.',
    'Team organising its block',
    'Fix the line where the team defends best.',
    NULL, 39, 40, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Hold the agreed height and step together'),
    (2, 'Goalkeeper', 'Adjust position to cover space behind the line')
) AS v(so, role, job);

-- 24. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Depth', 'Defensive layers as barriers',
    'Each unit (attack, midfield, defence, goalkeeper) forms a barrier so the opponent must break each line in turn; midfielders can be rearranged to add layers, and in 5v5 a 2-and-2 box plus the keeper gives three layers. Continues past s040.',
    'Opponent building an attack',
    'Make the opponent work through each layer before getting a good chance.',
    NULL, 40, 40, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward line', 'First barrier'),
    (2, 'Midfield line', 'Second barrier, can split to add a layer'),
    (3, 'Back line', 'Third barrier'),
    (4, 'Goalkeeper', 'Final layer')
) AS v(so, role, job);

-- 25. pp.41-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Depth', 'Layered defensive lines (Depth)',
    'The defending team arranges its units into horizontal layers (attack, midfield, defence, keeper). The midfield can be split to add an extra layer. The same idea applies to small-sided shapes: a 2-2 box gives 2 outfield layers and a 1-2-1 diamond gives 3.',
    'Opponent settles in possession',
    'Force the ball carrier to beat each line in turn before a good chance appears.',
    NULL, 41, 42, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'hold the last barrier in front of the keeper'),
    (2, 'Midfield unit', 'form one or two screening layers in front of the defence'),
    (3, 'Forwards', 'first layer, cut the easy forward passes'),
    (4, 'Goalkeeper', 'deepest layer behind the back line')
) AS v(so, role, job);

-- 26. pp.43-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Depth - Example', 'Deep line to bait and counter',
    'Leicester City 2015/16 kept a deep back line inside their own half even while attacking. This drew the opponent up the pitch.',
    'Opponent pushes up into our half',
    'Leave space behind the opponent so a turnover becomes a fast counter-attack into it.',
    NULL, 43, 43, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'stay inside own half even when the ball is deep in their half'),
    (2, 'Forwards', 'stay ready to run into the space behind the advanced opponent')
) AS v(so, role, job);

-- 27. pp.43-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Depth - Example', 'Very high line with sweeper-keeper',
    'Bayern Munich 2020 pushed their back line far up. When they attacked high in the opponent''s half, keeper Manuel Neuer was often the only player in his own half, well outside his box.',
    'Possession established high in opponent half',
    'Keep the whole team compressed in the opponent''s half, with the keeper covering the space behind.',
    NULL, 43, 43, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Neuer)', 'sweeper-keeper far outside the box, clears balls played in behind'),
    (2, 'Back line', 'push up near halfway behind the attack')
) AS v(so, role, job);

-- 28. pp.44-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Concentration (Compaction)', 'Compact block between ball and goal',
    'After losing the ball, a team that was spread out squeezes the gaps. It forms a tight central block about penalty-box width, in line with the goal.',
    'Turnover / opponent in possession',
    'Deny forward passes and dribbles through the middle, so only less threatening spaces are open.',
    NULL, 44, 44, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'narrow to about box width in front of goal'),
    (2, 'Midfield line', 'tuck in close behind the front players'),
    (3, 'Front players', 'screen in front of the block toward the ball')
) AS v(so, role, job);

-- 29. pp.45-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Concentration (Compaction) - Example', 'Atletico narrow 4-4-2 shoal shift',
    'Simeone''s Atletico Madrid defend in a very narrow 4-4-2. Wide midfielders tuck in beside the centre mids. One or both strikers drop as a screen or mark the holding midfielder. The whole block slides with the ball.',
    'Ball moves across the pitch',
    'Keep the barricade intact, then step out only at the right moment and prefer interceptions to tackles.',
    NULL, 45, 45, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielders', 'tuck in alongside the central midfielders'),
    (2, 'Strikers', 'drop in front of midfield as a screen or mark the opponent''s holding midfielder'),
    (3, 'Whole team', 'slide together with each ball movement'),
    (4, 'Defenders/midfielders', 'wait for interceptions instead of diving in')
) AS v(so, role, job);

-- 30. pp.46-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Balance', 'Back four shifts, far zones free',
    'The pitch width is split into five channels. With the ball central, the four defenders cover the middle channels. As the ball goes wide, the line shifts across and leaves the two channels furthest from the ball empty.',
    'Ball moves to a flank',
    'Protect the goal relative to the ball and ignore distant players who pose little threat.',
    NULL, 46, 47, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back', 'move out to the ball''s channel'),
    (2, 'Centre backs', 'slide across, staying between the ball and the goal'),
    (3, 'Far-side full back', 'tuck in and leave the far wide channel free')
) AS v(so, role, job);

-- 31. pp.47-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'to_defend', 'Balance', 'Seek numbers up when defending',
    'Balance is hardest during transitions and counters, when players are out of position. Defenders try to outnumber the attackers rather than just match them, so stable balance tilts toward the defending side.',
    'Turnover leaves defence out of balance',
    'Restore a numerical edge near the ball as quickly as possible.',
    NULL, 47, 47, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Recovering players', 'sprint back goal-side to add numbers'),
    (2, 'Defenders near ball', 'keep at least one more player than the attackers around the ball')
) AS v(so, role, job);

-- 32. pp.48-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Balance - Example', 'One full back up for balance',
    'Mourinho''s first Chelsea side pushed only the ball-side full back forward and kept the far one beside the centre backs. Pulis''s Stoke kept both full backs (natural centre-back types) at home.',
    'Team in possession pushes on one flank',
    'Keep back-line distances unbreakable at the cost of some attacking support.',
    NULL, 48, 48, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back', 'advance to support the attack (Chelsea)'),
    (2, 'Far-side full back', 'stay level with the centre backs'),
    (3, 'Centre backs', 'hold position as rest defence')
) AS v(so, role, job);

-- 33. pp.49-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Discipline/Patience', 'Delay unless cover, hold the block',
    'A defender only tries to win the ball when a team-mate can cover. Otherwise he stands his ground and delays. Midfielders hold their zones instead of chasing. Inter v Barcelona 2010: Mourinho packed the centre and let Barcelona cross, trusting Lucio and Samuel in the air.',
    'Opponent on ball without cover behind the defender',
    'Block the route to goal, with winning the ball a lower priority than not conceding.',
    NULL, 49, 50, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender facing ball', 'delay, jockey, tackle only with cover in place'),
    (2, 'Covering defender', 'provide cover so a regain attempt becomes safe'),
    (3, 'Midfielders', 'hold central zones, do not leave space by chasing'),
    (4, 'Centre backs (Lucio, Samuel)', 'win the aerial duels when the opponent crosses')
) AS v(so, role, job);

-- 34. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'to_attack', 'Positive Transition', '6-6-6 fast attack after regain',
    'On winning the ball, attack fast before the opponent regains depth, cover and balance. England youth used a 6-6-6 rule: attack with at least six players, reach the opposition half in six passes or fewer, and win the ball back within six seconds of losing it.',
    'Ball regained',
    'Score before the defence recovers, with support runners so nobody counters alone.',
    NULL, 52, 52, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'play a quick short pass to a better-placed team-mate'),
    (2, 'Supporting players', 'sprint forward so at least six join the attack'),
    (3, 'Front players', 'run into the space left by the opponent')
) AS v(so, role, job);

-- 35. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'to_attack', 'Positive Transition - Example', 'Counter from defended corner',
    'Man Utd v Arsenal, Champions League 2008/09: a header cleared an Arsenal corner to Ronaldo outside the box. His lay-off was punched wide to Park, Rooney carried at the defence, and his low cross found Ronaldo. Four passes, about five seconds.',
    'Clearance from opponent''s corner',
    'Hit the opponent while their players are committed forward from the set piece.',
    NULL, 53, 53, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Edge-of-box forward (Ronaldo)', 'receive the clearance, lay off, then sprint to finish'),
    (2, 'Wide midfielder (Park)', 'take the pass and move it on wide quickly'),
    (3, 'Ball-carrying forward (Rooney)', 'run at the retreating defence, square low across the box')
) AS v(so, role, job);

-- 36. pp.54-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'to_defend', 'Negative transition / High Pressure When the Ball is Lost (5-Second Rule)', 'Counter-press for 5-6 seconds',
    'After losing the ball, press it hard for a set window (Guardiola''s Barcelona used 5 seconds, Rangnick''s Leipzig a metronome). When time is up, drop into an organised block.',
    'Possession lost',
    'Regain high and counter against a disorganised opponent, or else restore defensive shape.',
    NULL, 54, 55, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players to ball', 'press the new ball carrier immediately'),
    (2, 'Surrounding players', 'close the passing options around the ball'),
    (3, 'Whole team', 'after the window, retreat into the organised defensive shape')
) AS v(so, role, job);

-- 37. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Defend By Retaining Possession of the Ball', 'Possession as a defensive tool',
    'Keep the ball to stop the opponent attacking, for example keeping it for the last minutes when 1-0 up. Spain 2012 used dominant possession to starve deep-sitting opponents. Some coaches prefer to clear long for territory instead.',
    'Protecting a lead / opponent sits deep',
    'Deny the opponent the ball and run the clock down.',
    NULL, 58, 58, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'circulate safely and avoid risky forward passes'),
    (2, 'Back line and keeper', 'recycle to keep the ball away from pressure')
) AS v(so, role, job);

-- 38. pp.59-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Strong Position Play (Juego de posicion)', 'Zonal occupation with rotations',
    'The pitch is split into zones, each with its own jobs. Where the ball is tells players which other zones must be filled. If a player leaves his zone, a team-mate rotates in, and the whole team shifts as the ball moves (Guardiola''s Barcelona ''carousel''). A player can also find space without moving when team-mates vacate an area.',
    'Ball enters a given zone, or a team-mate vacates a zone',
    'Keep every key zone occupied so there is always a passing structure.',
    NULL, 59, 61, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player leaving zone', 'move out to pull a marker or receive'),
    (2, 'Nearest team-mate', 'rotate into the vacated zone'),
    (3, 'Whole team', 're-arrange zone occupation to match the ball''s zone')
) AS v(so, role, job);

-- 39. pp.62-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Playing in the Spaces', 'Use half-spaces around zone 14',
    'Zone 14 (the area just outside the box) became heavily guarded by a dedicated screening player. Teams moved their creators to its edges, the half-spaces between centre and flank. De Bruyne: low short through balls from the left half-space, curled far-post balls from the right.',
    'Opponent screens zone 14',
    'Create chances from the channels between the central and wide zones.',
    NULL, 62, 65, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Creative midfielder (De Bruyne)', 'receive in the half-space and slide through or curl far post'),
    (2, 'Opponent screen (zone 14)', 'the player the half-space use plays around'),
    (3, 'Forwards', 'run off the half-space passer into the box')
) AS v(so, role, job);

-- 40. pp.66-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Using the Width and Depth of the Pitch', 'Width-depth shape and passing web',
    'Shapes in possession combine width, depth and dispersal: high and deep width on both flanks with three central forwards; or high width only on the far side, with two offset forwards; or deep centre backs and keeper with full backs and wingers both wide and one striker. Positions link up in a web of passing lines.',
    'Settled possession',
    'Stretch the opponent and keep several connected passing options.',
    NULL, 66, 68, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs and keeper', 'stay deep for depth and circulation'),
    (2, 'Full backs', 'push wide to give deep width'),
    (3, 'Wingers', 'hold high width (both sides, or far side only)'),
    (4, 'Striker(s)', 'give the high central option, offset when two')
) AS v(so, role, job);

-- 41. pp.69-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Play in The Opponent''s Half as Much as Possible', 'Squeeze into opponent half',
    'Keep the ball and the team as far into the opponent''s half as possible, valuing territory over possession. This makes any turnover far from your own goal.',
    'Possession',
    'Stay close to goal and set up an immediate high press on losing the ball.',
    NULL, 69, 69, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'push up to squeeze the team into the opponent''s half'),
    (2, 'Midfield and forwards', 'keep play high, ready to press on turnover')
) AS v(so, role, job);

-- 42. pp.70-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Play Forward Early and Consolidate Possession', 'Forward early, then consolidate (Leipzig)',
    'Move the ball into opposition territory early to gain a foothold, counter if space allows, and otherwise keep the ball. RB Leipzig skip slow build-up, aim for the final third quickly, and train with a 10-second shot clock.',
    'Possession begins',
    'Turn possession into a foothold or a shot quickly, then keep the ball if no counter is on.',
    NULL, 70, 71, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player on ball', 'look forward first and play into the final third early'),
    (2, 'Forwards', 'offer early forward targets'),
    (3, 'Midfielders', 'join quickly to secure possession high')
) AS v(so, role, job);

-- 43. pp.73-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'to_defend', 'Winning the Ball Back Quickly in High and Middle Areas With an Aggressive Pressing Game', 'Central counter-press during their spread',
    'A counter-press aimed at winning the ball back centrally, especially when it is lost in midfield. It strikes while the opponent is still opening its shape from compact to wide and deep.',
    'Ball lost in middle third',
    'Exploit gaps that open while the opponent spreads out after regaining the ball.',
    NULL, 73, 74, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'press the ball and the passes into central areas'),
    (2, 'Forwards', 'cut back-passes and squeeze from in front'),
    (3, 'Back line', 'step up to keep the press compact')
) AS v(so, role, job);

-- 44. pp.75-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Show Opponents Outside as Much as You Can', 'Show outside, concede flanks',
    'Individuals, units or the whole team block the centre and steer play wide, at the extreme even giving up wide space and crosses. Examples: Mourinho''s Inter v Barcelona 2010, Norwich at Liverpool 2011 (headed clearances became counters), and opponents at home to post-Ferguson Man Utd (81 crosses, 0-0).',
    'Opponent builds through the middle',
    'Make play predictable and push it into less dangerous wide areas, then win headers.',
    NULL, 75, 76, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central block', 'stay compact to deny central penetration'),
    (2, 'Wide defenders', 'angle to show the ball outside'),
    (3, 'Centre backs', 'defend the box and win aerial duels against crosses'),
    (4, 'Forwards', 'break on headed clearances while the opponent''s midfield is committed')
) AS v(so, role, job);

-- 45. pp.78-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Deception Principle', 'Double movement and dummy run-through',
    'A receiver makes a dummy movement toward one space, then darts into the space he actually wants. Ball carriers fake shots (Mahrez). A receiver can also let the ball run past him to a team-mate: Yorke stepped over a pass for Cole, then they played a one-two through Barcelona.',
    'Defender tracking the receiver or the ball carrier',
    'Make the opponent commit to the wrong action, then exploit the gap.',
    NULL, 78, 79, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'double movement: feint one way, move into the real space'),
    (2, 'Ball carrier (Mahrez)', 'fake shot or pass to put the defender into a block, then go past'),
    (3, 'Dummying forward (Yorke)', 'step over the pass so it reaches the partner'),
    (4, 'Partner forward (Cole)', 'take the dummied ball and one-two through the defence')
) AS v(so, role, job);

-- 46. pp.81-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Surprise Principle (example)', 'Surprise with unfamiliar movements',
    'The team uses a positional move opponents have not met before, such as Sheffield United''s centre backs overlapping, or a line-up with no fixed centre forward.',
    'Opponent''s defensive plan expects set roles',
    'Markers are caught unprepared and an extra man arrives in attack.',
    NULL, 81, 81, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back (Sheffield United)', 'Overlaps the wing-back to make an extra man out wide'),
    (2, 'Centre forward', 'Has no fixed post, so drops off and leaves the centre backs with nobody to mark')
) AS v(so, role, job);

-- 47. pp.82-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Mobility Principle', 'Quick circulation to drag the block',
    'The ball moves quickly from side to side while players keep moving, so the defending side is pulled away from the centre of the pitch.',
    'Defence sits compact in front of goal',
    'The central lanes in front of goal open up for penetration and chances.',
    NULL, 82, 82, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'Move the ball on quickly with few touches'),
    (2, 'Off-ball players', 'Time their movement to arrive just as the ball does')
) AS v(so, role, job);

-- 48. pp.83-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'to_attack', 'Opportunity Principle', 'Punish careless back passes',
    'Forwards stay alert to opponent errors. Henry read Gerrard''s back pass at Euro 2004, which was played without a look, then intercepted it and drew the penalty.',
    'Defender passes back without checking for the forward',
    'The forward cuts out the pass and goes through on goal.',
    NULL, 83, 84, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Henry)', 'Lurks in the passing line between the defender and the keeper and cuts out the back pass'),
    (2, 'Pressing teammates', 'Keep pressure on so the opponent is pushed into mistakes')
) AS v(so, role, job);

-- 49. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Cohesion Principle', 'Unit partnerships work as subsets',
    'Small units link up as partnerships: full back and winger, the centre back pair, the central midfielders and the forwards. Each line, and each flank, also works as one unit.',
    'Any phase: possession, out of possession or transition',
    'Everyone shares one plan, so chances are created and opponent chances are denied.',
    NULL, 85, 85, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back + winger', 'Combine as a pair down the flank'),
    (2, 'Centre back pair', 'Cover each other and move as a unit'),
    (3, 'Defence/midfield/attack lines', 'Move together with the side of the ball')
) AS v(so, role, job);

-- 50. pp.86-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Reserve Principle', 'Keep a reserve player behind the ball',
    'One or two players hold positions behind the ball so the man on the ball has a safe pass back when he cannot go forward. Pirlo stayed deep to find space and dictate play, and the keeper acts as the final reserve.',
    'Forward pass is blocked',
    'The team keeps the ball and resets. Too many players in reserve, though, makes penetration weak.',
    NULL, 86, 87, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep central midfielder (Pirlo)', 'Stays behind the line of the ball in free space and takes the recycle'),
    (2, 'Goalkeeper', 'Always available as the last-resort reserve pass'),
    (3, 'Ball carrier', 'Plays back to the reserve player when forward is blocked')
) AS v(so, role, job);

-- 51. pp.88-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Economy Principle', 'One-touch finishing in the box',
    'In the box, forwards finish with one or two touches instead of extra touches. Jelavic scored 12 of his first 15 Everton goals first time. Economy matters most when the result counts; youth players are allowed more elaborate play.',
    'Ball arrives in the penalty area',
    'The shot goes off before the defender can close the space.',
    NULL, 88, 89, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Jelavic)', 'Shoots first time and takes no settling touch')
) AS v(so, role, job);

-- 52. pp.91-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Pressure/Pressing', 'Pressing distance in the dyad',
    'The nearest defender controls the distance to the ball carrier. Close enough to threaten the ball, not so close that he can be skipped past, with his body angled to stop the forward play. Pressure tightens the nearer the ball is to goal, so nobody gets an uncontested shot.',
    'Opponent receives the ball; tighter as play nears our goal',
    'Forward play is delayed and the opponent is forced into errors or a regain. A high press leaves space behind if it fails.',
    NULL, 91, 91, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'Closes to an optimal distance and angles his body to block the forward route'),
    (2, 'Defenders near own box', 'Raise pressure so there is no unopposed shot'),
    (3, 'Rest of team', 'Choose how high to press; cover the space a committed press leaves')
) AS v(so, role, job);

-- 53. pp.92-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'to_defend', 'Battle to exploit and protect space', 'Possession shape that protects turnovers',
    'When spreading out in possession, the team keeps three players just in front of the two centre backs so layers are already in place. A shape with big gaps in the channels between defenders is easy to exploit after a turnover.',
    'Losing the ball while spread out in possession',
    'Few central spaces are open to a counter.',
    NULL, 92, 93, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two centre backs', 'Stay close enough together to shut the channels'),
    (2, 'Three midfielders', 'Screen just ahead of the centre backs during possession'),
    (3, 'Wide players', 'Give width without leaving huge gaps behind')
) AS v(so, role, job);

-- 54. pp.93-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Battle to exploit and protect space', 'Whole-team compaction around ball',
    'The out-of-possession team squeezes into the area round the ball. Leverkusen against Freiburg in 2015 fitted the whole team bar the keeper into about a quarter of the pitch. Space behind is covered by the offside line and a sweeper-keeper, and zonal duties keep each zone small.',
    'Ball in a central or key zone',
    'The carrier finds no space; central areas in line with goal are layered and closed.',
    NULL, 93, 94, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Steps up to compress and plays offside'),
    (2, 'Sweeper-keeper', 'Stays high to sweep up long balls into the space behind'),
    (3, 'Midfield and forwards', 'Crowd the ball zone, each keeping a small zone')
) AS v(so, role, job);

-- 55. pp.95-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'One versus one domination', 'Defender keeps a 1-2 metre distance',
    'In a 1v1 the defender keeps about 1-2 metres from the attacker and mirrors his moves. Strong defensive 1v1 players keep the block balanced.',
    'Attacker carries at the defender',
    'The attacker cannot break the distance, and won duels become turnovers to counter from.',
    NULL, 95, 95, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender on the ball', 'Holds 1-2 m distance and moves with the attacker'),
    (2, 'Rest of back line', 'Keep a balanced structure behind the duel')
) AS v(so, role, job);

-- 56. pp.95-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'One versus one domination', 'Dribbler eliminates and pulls the cover',
    'A dominant dribbler beats his man, so a covering defender has to step out to him and leaves a player or a space. Maradona against Belgium in 1986 went through the gap in a diamond of defenders and the cover''s move opened space for his shot.',
    'Isolated 1v1 against a defender',
    'Each defender beaten breaks the defensive balance and frees teammates.',
    NULL, 95, 96, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dribbler (Maradona)', 'Takes on and accelerates through the gap between defenders'),
    (2, 'Teammates', 'Hold their positions to punish the covering defender who leaves them')
) AS v(so, role, job);

-- 57. pp.97-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Diamonds and triangles', 'Triangles and diamonds to overload zones',
    'Players form triangles and diamonds in small zones: keeper plus two centre backs against a lone striker, three central midfielders against two, four midfielders in a diamond against two. The ball moves from shape to shape.',
    'Building through a zone held by fewer opponents',
    'The team keeps the ball, then progresses through tight spaces using the angles.',
    NULL, 97, 98, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper + two centre backs', 'Form a triangle and play round the single striker'),
    (2, 'Central midfielders', 'Make a triangle or diamond to give angled passing lanes'),
    (3, 'Off-ball players', 'Their runs set the next pass, not the passer')
) AS v(so, role, job);

-- 58. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Overloads and numerical advantage', 'Midfield three beats a pair',
    'A midfield three, such as the one in a 4-3-3, outnumbers the two central midfielders of a 4-4-2. Teams aim never to allow an overload, avoid being level, and seek superiority.',
    'Opponent plays two central midfielders',
    'The team wins the middle of the pitch.',
    '4-4-2', 99, 99, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield three', 'Spread in a triangle so there is always a free man against the pair')
) AS v(so, role, job);

-- 59. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Overloads and numerical advantage', 'Midfield diamond against a three',
    'A midfield diamond of four outnumbers an opponent''s midfield three, as in a 4-3-3.',
    'Opponent plays a midfield three',
    'There is a 4v3 in central areas.',
    '4-3-3', 99, 99, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield diamond', 'Base, two sides and a tip, so one man is always spare')
) AS v(so, role, job);

-- 60. pp.99-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Overloads and numerical advantage', 'Box midfield against a diamond',
    'Teams rarely answer a diamond with five central players, because that strips other zones. Instead they set four midfielders in a square, or box, to give the diamond problems in different zones.',
    'Opponent''s midfield diamond',
    'The team stays level with the diamond without weakening the flanks.',
    '4-1-2-1-2', 99, 100, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two holding midfielders', 'Bottom of the box, deal with the tip and base'),
    (2, 'Two advanced midfielders', 'Top of the box, screen the sides of the diamond')
) AS v(so, role, job);

-- 61. pp.100-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'Overloads and numerical advantage', 'Back line one more than forwards',
    'However many forwards the opponent pushes onto the back line, the defending side keeps one extra defender. Two centre backs against a lone striker frees the full backs. Against two strikers the full backs tuck in close, or a third defender drops in.',
    'Number of opposition forwards on our back line',
    'Our back line is never level or outnumbered.',
    NULL, 100, 103, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two centre backs', '2v1 on a lone striker, one marks and one covers'),
    (2, 'Full backs', 'Free to push on against one striker; stay close to the centre backs against two'),
    (3, 'Holding midfielder', 'Drops in to make three against two strikers')
) AS v(so, role, job);

-- 62. pp.102-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Overloads and numerical advantage', 'Front three play in between',
    'The wingers come inside to the gaps between the full backs and centre backs. The striker either sits between the centre backs or drops between the opponent''s central midfielders. Nobody stands directly on a marker.',
    'Opponent back four marking zonally',
    'Defenders are left unsure who to mark, which overloads the centre backs.',
    NULL, 102, 102, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'Move inside to the gap between full back and centre back'),
    (2, 'Central striker', 'Splits the centre backs or drops between the midfielders')
) AS v(so, role, job);

-- 63. pp.103-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Overloads and numerical advantage', 'Full back and winger overlap/underlap',
    'Out wide the full back and winger combine to make 2v1s: the full back overlaps outside the winger, or underlaps inside him. Sometimes the winger simply takes on his man 1v1.',
    'Winger receives wide, facing his full back',
    'There is a short-lived wide overload to get in behind.',
    NULL, 103, 104, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Holds or carries the ball inside or outside to draw the full back'),
    (2, 'Full back', 'Overlaps outside or underlaps inside past the winger')
) AS v(so, role, job);

-- 64. pp.105-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'Diamonds and triangles (example)', 'Ancelotti''s Milan midfield diamond',
    'Ancelotti''s AC Milan played a midfield diamond: Pirlo at the base, Gattuso and Seedorf on the two sides, and Kaka free to roam at the tip behind the forwards.',
    'Possession in central areas',
    'Connections stay close and short, giving central superiority through better geometry.',
    NULL, 105, 105, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Base midfielder (Pirlo)', 'Deep playmaker, dictates from the base'),
    (2, 'Side midfielders (Gattuso, Seedorf)', 'Link play, one covering and one creating'),
    (3, 'Tip (Kaka)', 'Supports the forwards with the freedom to roam')
) AS v(so, role, job);

-- 65. pp.107-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'How The Principles Impact Practice: Penetration / Penetration II', 'Play into the target and lay off',
    'Trains playing forward into a striker who lays the ball off to supporting runners, who finish in behind. Another option is to pass straight into space behind the defence for the striker to run onto.',
    'Striker has dropped in front of the defence, or space opens behind it',
    'The ball goes forward early and gets in behind the defence.',
    NULL, 107, 108, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target striker', 'Receives in front of the back line and lays off'),
    (2, 'Supporting midfielders', 'Arrive for the lay-off and run beyond'),
    (3, 'Passer', 'Plays forward into the target or into space behind')
) AS v(so, role, job);

-- 66. pp.109-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'How The Principles Impact Practice: Support / Support II', 'Shift with a switch for support',
    'After a long switch, the whole team moves across into the half the ball went to and finds new angles to support it. One player stays behind in each half. The receiver moves away from his marker, and teammates judge who is best placed to help the ball carrier straight away.',
    'Ball switched into the other half',
    'The receiver quickly has close support and options.',
    NULL, 109, 110, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver in far half', 'Moves off his marker to get free for the switch'),
    (2, 'Teammates', 'Sprint across to the ball''s half to give support angles'),
    (3, 'Holding player', 'Stays behind in the half the ball left')
) AS v(so, role, job);

-- 67. pp.111-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'How The Principles Impact Practice - Width', 'Wide players hold width, invert and rotate',
    'Two players per side stay wide in the opposition half so the team can stretch the defence; a wide receiver may drive inside like an inverted winger.',
    'Ball played out to a free wide player',
    'Stretch the block with width and keep the wide lane occupied when the winger cuts in.',
    NULL, 111, 111, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'hold the touchline in the opposition half, receive and drive inside or pass and follow'),
    (2, 'Passer (central midfielder)', 'after the pass, swap out to take the vacated wide spot'),
    (3, 'Nearest teammate', 'fill the wide position if the passer cannot')
) AS v(so, role, job);

-- 68. pp.112-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'How The Principles Impact Practice - Mobility/Movement', 'Runs off the ball into space behind',
    'Attackers read where the space behind the defensive line is and run to lose their marker, receiving in behind or carrying the ball into it.',
    'Teammate on the ball with time to play forward',
    'Get a receiver in behind the defence.',
    NULL, 112, 112, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'spot the space behind and time a run to shake the marker'),
    (2, 'Ball carrier', 'play into the runner or dribble into the space himself')
) AS v(so, role, job);

-- 69. pp.114-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'to_defend', 'How The Principles Impact Practice - Delay', 'Delay the outnumbered break for recoveries',
    'After losing the ball, two defenders face a three-man attack; they must slow it so recovering teammates can get back and flip the overload.',
    'Opponent counter-attacks with a numerical edge',
    'Buy time until recovering runners restore numbers, then regain and break.',
    NULL, 114, 114, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Last two defenders', 'jockey and hold up the ball, do not dive in'),
    (2, 'Recovering players', 'sprint back goal-side to reverse the overload'),
    (3, 'Goalkeeper', 'organise and cover behind')
) AS v(so, role, job);

-- 70. pp.115-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'How The Principles Impact Practice - Depth', 'Choose a point of engagement low/medium/high',
    'The team sets a pressure line: low (no pressure until the opponent crosses halfway, most defenders deep), medium, or high (most players in the top third, nobody deep).',
    'Opponent enters the chosen pressure zone',
    'Keep the team''s depth and pressing height disciplined to the chosen block.',
    NULL, 115, 115, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front players', 'only press once the ball enters the chosen zone'),
    (2, 'Back line', 'set depth to match: deep in a low block, high with no one left low in a high block'),
    (3, 'Whole team', 'stay patient and positioned until the trigger')
) AS v(so, role, job);

-- 71. pp.116-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'How The Principles Impact Practice - Compactness', 'Compact low block shifting as a unit',
    'Defending in its own half, the team packs the central areas, slides across with the ball and keeps short distances so nothing goes through the middle; a back four or back three plus extra midfielder.',
    'Ball moves side to side or goes wide',
    'Deny central passes and force play wide where only a cross is possible.',
    NULL, 116, 116, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'step out alone to pressure a crosser when the ball goes wide'),
    (2, 'Centre backs', 'watch ball, nearest opponent and teammates; set body shape'),
    (3, 'Central midfielders', 'screen in front of the striker to stop passes into him')
) AS v(so, role, job);

-- 72. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'How The Principles Impact Practice - Balance', 'Back line balances, concedes far side',
    'On a wide pitch the defenders shift with the ball to block its path to goal, leaving the space and the opponent furthest from the ball free.',
    'Ball switched or carried across',
    'Stay compact near the biggest threat without leaving a gap too large to recover.',
    NULL, 117, 117, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side defender', 'block the direct route to goal'),
    (2, 'Back line', 'slide across with each pass'),
    (3, 'Weak-side defender', 'drop the far man, but stay close enough to cover the ground on a switch')
) AS v(so, role, job);

-- 73. pp.118-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'How The Principles Impact Practice - Discipline/Patience', 'Block lanes and wait for the interception',
    'A central unit sits between two opponent groups, shifting together to block passes and cut angles rather than lunging.',
    'Opponent tries a pass through the middle',
    'Win the ball by interception through patient, communicated shifting.',
    NULL, 118, 118, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield unit', 'move across as one, cut passing angles, talk'),
    (2, 'Intercepting player', 'after a steal, play out quickly to keep tempo')
) AS v(so, role, job);

-- 74. pp.119-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'to_attack', 'How The Principles Impact Practice - Counter-Attack', 'Instant restart before the opponent settles',
    'When the ball goes dead after an opponent attack, a wide player near the goal restarts immediately by dribble or pass instead of a slow goal kick.',
    'Ball won or dead after opponent''s shot',
    'Exploit the moment the opponent is still out of shape.',
    NULL, 119, 119, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player', 'restart at once and attack the goal'),
    (2, 'Teammates', 'react to the transition with forward support runs'),
    (3, 'Defenders (opponent)', 'must recover fast; trains their reaction too')
) AS v(so, role, job);

-- 75. pp.120-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'to_defend', 'How The Principles Impact Practice - Counter-Press / Counter-Press II', 'Counter-press: ferocious first, then triggers',
    'On losing the ball the team presses the ball immediately and hard (Guardiola 4v4+3 rondo); once the opponent settles, press less wildly and wait for poor passes or a bouncing ball, cutting lines to trap the carrier 1v2. Intense pressure goes on the central receiver, pressing together so a pass into him does not split them.',
    'Ball lost; later a poor pass or ball in the air',
    'Regain quickly near the loss, or isolate the carrier once the opponent is settled.',
    NULL, 120, 129, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player to loss', 'attack the ball at once, no relaxing'),
    (2, 'Second presser', 'close the carrier to make it 1v2'),
    (3, 'Other pressers', 'block passing lanes, especially into the central player'),
    (4, 'Whole unit', 'press together; drop intensity on wide players, raise it on central ones')
) AS v(so, role, job);

-- 76. pp.121-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'How The Principles Impact Practice - Possession and building out from the back', 'Goal kick build-out vs press height',
    'From a goal kick the goalkeeper reads the press: if the opponent sits high he chips over it into an overload, if they drop off he plays short; players move wide and centrally to open lines.',
    'Goal kick and the opponent''s pressing height',
    'Build out past halfway either short or over the first line.',
    NULL, 121, 121, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'choose short pass or chip over high pressers'),
    (2, 'Centre backs', 'split wide to offer short options'),
    (3, 'Midfielders / wide players', 'move to create passing lines centrally and wide')
) AS v(so, role, job);

-- 77. pp.122-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'How The Principles Impact Practice - Half-Spaces', 'Move into the half-space to assist',
    'Players arrive in the channels between wing and centre to give the assist or pre-assist; when one moves in, a teammate covers the spot he left.',
    'Half-space free between opponent lines',
    'Create chances from the half-space.',
    NULL, 122, 122, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger or inside player', 'step into the half-space to receive and assist'),
    (2, 'Nearest teammate', 'rotate to fill the vacated position')
) AS v(so, role, job);

-- 78. pp.123-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'out_of_possession', 'How The Principles Impact Practice - Showing Outside', 'Protect the central triangle, show outside',
    'The defending team guards a central triangle in front of its goal, moving as a unit with gaps tight enough that passes into it look unappealing.',
    'Opponent circulates around the block',
    'Keep the ball out of the direct path to goal and spring a counter on regain.',
    NULL, 123, 123, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'hold shape at the base of the triangle'),
    (2, 'Midfield', 'close gaps so no pass enters the centre'),
    (3, 'Regaining player', 'release the counter forward at once')
) AS v(so, role, job);

-- 79. pp.126-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'How The Principles Impact Practice - Mobility', 'Forward drops between lines, others run',
    'A forward drops into the empty space between the lines to receive, losing his marker who cannot follow; the passer then makes an overlap or underlap and another player runs forward.',
    'Space between lines empty and unguarded',
    'Receive between the lines and add runners beyond.',
    NULL, 126, 126, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'drop into the gap between lines to receive'),
    (2, 'Wide player / passer', 'after the pass, overlap or underlap to support'),
    (3, 'Other forward', 'run forward in behind'),
    (4, 'Defender', 'can step into midfield to receive as a variant')
) AS v(so, role, job);

-- 80. pp.128-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'How The Principles Impact Practice - Reserve', 'Deep reserve player as quarterback',
    'One player drops away from the play into the safe area in front of his own goal, always offering a spare pass with open body shape and full view, like Xabi Alonso or Andrea Pirlo.',
    'Pressure on the ball higher up',
    'Keep a guaranteed outlet and a playmaker with time to see the whole pitch.',
    NULL, 128, 128, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep midfielder (Alonso/Pirlo type)', 'drop into space behind the play, open up and distribute'),
    (2, 'Players under pressure', 'recycle back to the reserve player')
) AS v(so, role, job);

-- 81. pp.133-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'How The Principles Impact Practice - Diamonds and triangles I/II', 'Move to keep triangles and diamonds',
    'Support players rotate to fill the side of the shape left empty, while wide players slide along their wings and interior players move to support the wide man once he receives.',
    'Ball moves and one side of the shape is open',
    'Always give the ball carrier two or three angled options.',
    NULL, 133, 134, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players', 'slide up and down the wing to offer support'),
    (2, 'Interior players', 'move to support the wide receiver and keep a diamond'),
    (3, 'Supporting player', 'rotate round to fill the open side')
) AS v(so, role, job);

-- 82. pp.135-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-footballs-principles-of-play'), 'in_possession', 'How The Principles Impact Practice - Create Overloads', 'Follow the pass to overload a zone',
    'A player passes into the next zone and follows it, dribbles into that zone, or drops back into the ball zone, so the team outnumbers markers who stay in their area; in build-up the goalkeeper gives a natural extra man.',
    'Pass or dribble breaks into the next line',
    'Win local numerical superiority where the ball is.',
    NULL, 135, 135, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'follow the pass into the next zone'),
    (2, 'Ball carrier', 'dribble past the line to add a man'),
    (3, 'Nearby player', 'drop into the ball zone'),
    (4, 'Goalkeeper', 'act as the spare man in the defensive third')
) AS v(so, role, job);

COMMIT;
