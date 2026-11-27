-- 1969 📚 Coaching book patterns: "Marcelo Bielsa - Coaching Build Up Play Against High Pressing Teams" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Marcelo Bielsa - Coaching Build Up Play Against High Pressing Teams',
    author      = 'Athanasios Terzis',
    team        = 'Marseille, Athletic Bilbao',
    method_note = 'How Bielsa''s Marseille and Athletic Bilbao built up from the goalkeeper against high pressing; a phase counts as a pattern once seen about 10 times. Opponents are a 4-4-2 (two forwards) or a 4-2-3-1 (one forward). Four steps: give the keeper a free pass, move the ball to the target or free player, create a numerical edge in one area, exploit it. Bielsa''s 4-2-3-1 reshapes into a 3-3-3-1 (attacking option, holding midfielder drops in) or a 3-4-3 (safer option) against two forwards, and mostly stays 4-2-3-1 against one. Each situation has its analysis then a session of progressive practices. App page = printed page + 1. Patterns are the match behaviours, in our words.'
WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams');

-- 1. pp.11-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch1 1a) Creating a 3 v 2 at the back - attacking 3-3-3-1', 'Holding mid drops in: 3-3-3-1',
    'Against a front two the keeper faces a 2v2 at the back. The holding midfielder drops between the centre backs, the centre backs split wide and both full backs push up level with the other central midfielder.',
    'Goal kick / keeper in possession vs 2 pressing forwards',
    '3v2 at the back for a safe first pass and 4v4 in the front line.',
    '4-4-2', 11, 21, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (6)', 'Drop between the centre backs to make a back three'),
    (2, 'Centre backs (4, 5)', 'Split wide toward the box corners to receive from the keeper'),
    (3, 'Full backs (2, 3)', 'Push high in line with the other central mid'),
    (4, 'Central midfielder (8)', 'Stay central as the single pivot / link'),
    (5, 'Front four (7, 10, 11, 9)', 'Pin the back four: 4v4 in attack')
) AS v(so, role, job);

-- 2. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch1 1a) Creating a 3 v 2 at the back - attacking 3-3-3-1', 'Mid drops wide beside centre back',
    'A variant 3v2: instead of dropping between the centre backs, one central mid drops deep and wide toward the touchline. The centre backs slide across and the other mid moves into the middle.',
    'Pressed by 2 forwards, wide drop lane open',
    'Back three made on one side so the keeper still has a free outlet.',
    '4-4-2', 22, 22, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (6)', 'Drop deep and wide toward the sideline'),
    (2, 'Centre backs (4, 5)', 'Shift across to form the three'),
    (3, 'Other central mid (8)', 'Move into the central slot'),
    (4, 'Full backs', 'Stay high')
) AS v(so, role, job);

-- 3. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch1 1b) 3 v 2 at the back - defensive 3-4-3', 'Safer 3-4-3 build-up shape',
    'The 6 drops between the centre backs and one winger tucks into central midfield to make a midfield four. The 9 and 10 shift to rebalance, which gives a 3v2 at the back but 3v4 up front.',
    'Need more security in midfield when building vs 2 forwards',
    'Keep the back-line edge with an extra midfielder against losing the ball, at the cost of numbers in attack.',
    '4-4-2', 23, 23, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (6)', 'Drop between the centre backs'),
    (2, 'Winger (7)', 'Tuck into midfield for balance; join the attack if the ball goes forward'),
    (3, 'Forward (9)', 'Shift to the vacated side'),
    (4, 'No.10', 'Shift slightly the other way to keep the shape')
) AS v(so, role, job);

-- 4. pp.24-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch1 Step 2 / 2a) Who is the target player?', 'Target player and free player',
    'The wide centre backs are ''target players'': if one receives and gets past the nearest forward, there is a 3v2 near that sideline (both sides in 3-3-3-1, only one side in 3-4-3). Whoever the press leaves unmarked is the ''free player'' and gets the ball even when on the weak side.',
    'Keeper has the ball; read which back player is unmarked',
    'Ball reaches a player who can break the first press and start the sideline overload.',
    '4-4-2', 24, 25, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back (target)', 'Receive, beat the closest forward, carry to make 3v2'),
    (2, 'Goalkeeper', 'Read who is free and pass to him'),
    (3, 'Full back + winger', 'Form the 3v2 with the target near the line'),
    (4, 'Free player', 'Take the ball when the target is covered')
) AS v(so, role, job);

-- 5. pp.26-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch1 Step 2 / 2a) Who is the target player?', 'Forward shifts to make 3v2',
    'When the 6 and the far centre back are marked, the keeper passes to the free centre back, who faces only a 2v2 near the line. Our 9 slides over to the strong side and the 10 steps into the striker spot.',
    'Free player receives in a 2v2 near the sideline',
    'Turn the 2v2 near the sideline into a 3v2.',
    '4-4-2', 26, 26, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free centre back (4)', 'Receive from the keeper, carry up the line'),
    (2, 'Forward (9)', 'Shift toward the ball side to add a third man'),
    (3, 'No.10', 'Move up into the forward''s position'),
    (4, 'Full back (2) / winger (11)', 'Complete the strong-side triangle')
) AS v(so, role, job);

-- 6. pp.27-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch1 2b) Moving the ball to the target or free player', 'Link player reaches marked target',
    'If both wide centre backs are marked, the keeper plays short to the 6. When a forward leaves the far centre back to press the 6, the 6 plays forward to the 8, who sets it out to the now-free centre back stepping forward.',
    'Both target players marked; a forward jumps onto the 6',
    'Use a link player to reach the target player the press has just left free.',
    '4-4-2', 27, 28, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (6)', 'Free player: receive centrally and draw a forward'),
    (2, 'Central midfielder (8)', 'Link player: show, receive and redirect to the target'),
    (3, 'Target centre back (5)', 'Step forward into space to receive'),
    (4, 'Goalkeeper', 'Short pass into the 6')
) AS v(so, role, job);

-- 7. pp.29-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch1 2c) Building up and attacking from the centre when forced inside / Session 1', 'Read the winger when forced inside',
    'The front two stay wide and let the 6 carry forward through the middle. He looks for through passes to 7, 10 or 11 between the lines. If the opposing wingers squeeze in to block those lanes, he switches to a long aerial pass to the high wing backs.',
    'Opposing forwards stay wide and funnel the 6 inside',
    'The 6 picks the right pass each time: between the lines when lanes are open, out to the free wing back when the midfield closes.',
    '4-4-2', 29, 38, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (6)', 'Carry forward, read the wingers and choose the pass'),
    (2, 'Midfielders (7, 10, 11)', 'Find pockets between the lines; receive and turn'),
    (3, 'Wing backs (2, 3)', 'Stay very high and wide for the aerial pass'),
    (4, 'Forward (9)', 'Pin the centre backs')
) AS v(so, role, job);

-- 8. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch1 2c) Through pass when opposition wingers stay wide', 'Split pass past flat midfield four',
    'The opposing wingers hold wide to protect the flanks, which leaves gaps inside their midfield four. The 6 drives forward and slides a through pass to a midfielder (7) between the lines, who turns.',
    'Opposing wingers stay wide; midfield four not compact',
    'Take all four opposing midfielders out with one pass; up to a 6v4 if the wing backs are high.',
    '4-4-2', 30, 30, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (6)', 'Drive and play the split pass'),
    (2, 'Inside midfielder (7)', 'Receive between the lines and turn'),
    (3, 'Wing backs', 'Stay high to make the 6v4'),
    (4, 'Forward (9)', 'Hold the centre backs deep')
) AS v(so, role, job);

-- 9. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch1 2c) Opposition full back moves forward', 'Full back jumps, wing back runs behind',
    'The opposing full back steps up to stop our 7 receiving between the lines. The 6 plays a long aerial pass into the space behind him for our wing back, who has run forward.',
    'Opposing full back steps out onto our between-lines midfielder',
    'Get in behind the defence''s wide area: a 5v4 attack.',
    '4-4-2', 31, 31, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder (7)', 'Show between the lines to draw the full back up'),
    (2, 'Wing back (2)', 'Sprint into the space behind the full back'),
    (3, 'Holding midfielder (6)', 'Play the aerial pass in behind'),
    (4, 'Forward (9)', 'Pin the centre back')
) AS v(so, role, job);

-- 10. pp.32-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch1 2c) Opposition wingers move inside', 'Wingers tuck in, go wide 2v1',
    'The opposing midfield four narrows into a compact line, so the flanks open. The 6 plays an aerial ball to the wing back. When the opposing full back closes him, the 7 drifts out to make a 2v1 near the sideline.',
    'Opposing wingers converge, leaving the touchline area free',
    'A 2v1 on the flank leading to a 5v4 attack.',
    '4-4-2', 32, 32, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (6)', 'Switch to an aerial pass toward the wing back'),
    (2, 'Wing back (2)', 'Receive in space and draw the full back'),
    (3, 'Midfielder (7)', 'Move across to make the 2v1'),
    (4, 'Forward (9)', 'Hold the line')
) AS v(so, role, job);

-- 11. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch1 2c) Opposition full back and winger work together', 'Wing back covered: forward runs channel',
    'The opposing winger tracks our wing back and their full back steps onto our 7, which still leaves space behind the full back. The ball goes to the 7, who sets it first time inside to the 10. The 10 or the 6 then plays the 9 into the channel, directly or after a combination.',
    'Our wing back marked and the opposing full back pushed up',
    'The forward attacks the space behind the full back. The 6''s passes must be clean or the team faces a 2v2 counter.',
    '4-4-2', 33, 33, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder (7)', 'Link player: one-touch lay-off inside'),
    (2, 'No.10', 'Receive inside and release the forward'),
    (3, 'Forward (9)', 'Run diagonally into the channel behind the full back'),
    (4, 'Holding midfielder (6)', 'Start the move with an accurate pass')
) AS v(so, role, job);

-- 12. pp.40-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch2 Moving the ball to the target player on the weak side / Session 2', 'Strong side shut: switch to weak side',
    'The near forward presses the centre back who received first, making a 3v3/4v4 around the ball. A 3v2 still exists on the far side, so the team switches to the far centre back (now the target) or to the advanced far full back.',
    'Forward closes down the first receiver; no edge left near the ball',
    'Switch to a 3v2 near the far sideline or a 2v1 with the far full back and winger.',
    '4-4-2', 40, 48, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (4)', 'Draw the press, then move the ball on'),
    (2, 'Weak-side centre back (5)', 'New target: receive and carry up the line'),
    (3, 'Weak-side full back (3)', 'Stay high for a direct switch and a 2v1 with the winger'),
    (4, 'Central midfielder (8)', 'Accurate long switching passes')
) AS v(so, role, job);

-- 13. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch2 Option 1: Pass back to goalkeeper who acts as a ''link player''', 'Keeper as link to switch',
    'The pressing forward blocks the inside pass but not the route back to the keeper. The centre back plays back and the keeper sends it to the far centre back, whom the other forward is too far away to press.',
    'Forward blocks the inside lane but leaves the back pass open',
    'Simplest switch: far centre back gets time and space and a 3v2 near the line.',
    '4-4-2', 41, 41, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (4)', 'Play back to the keeper'),
    (2, 'Goalkeeper', 'Link player: switch to the far centre back'),
    (3, 'Weak-side centre back (5)', 'Receive and advance')
) AS v(so, role, job);

-- 14. pp.42-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch2 Option 2: If the back pass is blocked, the inside pass is probably free', 'Inside pass to 8 switches',
    'The pressing forward cuts off the pass back to the keeper, which leaves the inside lane open. The 8 receives, turns and switches to the far centre back. This works when the other forward is high and away from the ball side and there is room between the lines.',
    'Forward''s press blocks the keeper option',
    'Switch through the central midfielder to the weak-side target.',
    '4-4-2', 42, 42, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (4)', 'Play the inside pass'),
    (2, 'Central midfielder (8)', 'Receive between the lines, turn and switch'),
    (3, 'Weak-side centre back (5)', 'Receive and attack the 3v2')
) AS v(so, role, job);

-- 15. pp.43-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch2 Option 3: Using the central midfielder to switch after quick combination', 'Winger drops to free the 8',
    'The 7 drops deep between the lines and takes a pass from the centre back, pulling the opposing winger and a midfielder onto him. That opens space for the 8, who receives facing forward and switches first time. If the 8 is marked, the 7 plays back to the keeper or the 6.',
    'Back pass and inside pass both screened; need a decoy',
    'Quick combination frees a forward-facing switcher toward the 3v2.',
    '4-4-2', 43, 43, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (7)', 'Drop deep as link player to draw two defenders'),
    (2, 'Central midfielder (8)', 'Receive open-bodied and switch first time'),
    (3, 'Ball-side centre back (4)', 'Feed the dropping winger'),
    (4, 'Weak-side centre back (5)', 'Target for the switch')
) AS v(so, role, job);

-- 16. pp.44-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch2 Option 4: Full back acts as a ''link player'' to switch play', 'Wing back drops as link',
    'The forward presses the centre back in a way that blocks both the keeper and the inside pass. The wing back reads this and drops to get free, receives, then plays back to the keeper, who switches to the far centre back.',
    'Both the back pass and the inside pass are cut by one forward''s press',
    'Recycle through the wing back and keeper to reach the 3v2 on the weak side.',
    '4-4-2', 44, 44, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing back (2)', 'Drop to come free and act as link'),
    (2, 'Ball-side centre back (4)', 'Pass to the dropping wing back'),
    (3, 'Goalkeeper', 'Switch to the far target'),
    (4, 'Weak-side centre back (5)', 'Receive and advance')
) AS v(so, role, job);

-- 17. pp.49-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Session 3: Switching play vs 2 forwards and exploiting an advantage on the weak side', 'Weak-side 3v2 combos in 6-8s',
    'After the switch the far side has a 3v2 or 2v1. Depending on who receives, the centre back carries and feeds the full back while the winger runs behind, the full back plays a 1-2 with the winger and overlaps, or the winger overlaps outside the full back. The 9 and 10 attack the box.',
    'Long switch received on the weak side',
    'Exploit the overload at speed, within about 6-8 seconds, before the defence shifts across.',
    '4-4-2', 49, 54, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side centre back (5)', 'Carry forward and feed the full back'),
    (2, 'Weak-side full back (3)', 'Receive in the 2v1, give and go, or draw the defender'),
    (3, 'Weak-side winger (11)', 'Diagonal run in behind or overlap outside the full back'),
    (4, 'Forward (9) and No.10', 'Time runs into the box to finish')
) AS v(so, role, job);

-- 18. pp.56-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch3 Positioning / Step 1-2 vs 1 forward', 'Keep 4-2-3-1 vs lone striker',
    'Against one forward the two centre backs already have a 2v1, so nobody drops in. The wide centre backs are the target players. If one receives directly and the 9 and 10 are too far away to press, a 3v2 forms near that sideline.',
    'Opponent presses with one forward (e.g. 4-2-3-1 or 4-3-3)',
    'Keeper always has a free centre back, and the target carries into a sideline 3v2.',
    '4-2-3-1', 56, 59, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (4, 5)', 'Split wide as targets; one is always free'),
    (2, 'Goalkeeper', 'Pass directly to the free target'),
    (3, 'Full back + winger', 'Make the 3v2 near the line with the target'),
    (4, 'Central midfielders (6, 8)', 'Stay in midfield, no drop needed')
) AS v(so, role, job);

-- 19. pp.60-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Ch3 Step 2: forward and No.10 shift to the strong side / Session 4', 'Lone forward plus 10 overload: switch',
    'The 9 presses the target centre back and the opposing 10 slides over, making a 3v3 near the line and 5v4 around the ball. The far-side 8 drops back for cover and as a link. The switch to the far centre back goes via the keeper, via the 7 or the 6 as link to the keeper or the 8, or via the full back dropping to the keeper.',
    'Opposing 9 and 10 shift quickly onto the first receiver',
    'Move the ball to the far centre back for a 3v2 on the weak side while keeping cover behind the ball.',
    '4-2-3-1', 60, 64, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side central mid (8)', 'Drop back for safety and act as switch outlet'),
    (2, 'Winger (7) / holding mid (6)', 'Link player to the keeper or the 8'),
    (3, 'Full back (2)', 'Drop as link if the back pass and inside pass are both blocked'),
    (4, 'Goalkeeper', 'Switch to the far centre back'),
    (5, 'Weak-side centre back (5)', 'Receive and attack the 3v2')
) AS v(so, role, job);

-- 20. pp.65-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Session 4: Playing through pressure on strong side and switch play against 1 forward', 'Escape strong-side press, switch via keeper',
    'Against a lone forward the opponent pushes numbers to our strong side to stop the switch. Our 4-2-2 reshapes to a 2-3-1 style back line with the holding midfielder dropping to cover.',
    'Forward presses the ball-side centre back and the rest of the block shifts across',
    'Get the ball to the far side where we have a 2v1 before the press can reset.',
    '4-2-3-1', 65, 65, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (4)', 'Pass back to keeper, or into the dropping winger or inside midfielder who returns it to the keeper'),
    (2, 'Goalkeeper', 'Switch play to the far centre back'),
    (3, 'Holding midfielder (6)', 'Drop back for balance; switch play himself if his lane is open'),
    (4, 'Far centre back (5)', 'Receive the switch and attack the 2v1')
) AS v(so, role, job);

-- 21. pp.66-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Session 5: Switching play against 1 forward and exploiting an advantage on the weak side', 'Four link-player routes to switch',
    'Keeper moves to one side and gives to a centre back who opens up; the lone forward and the block try to stop the switch. The team picks one of four routes depending on what is blocked.',
    'Keeper''s pass to a centre back with the forward shifting across',
    'Switch play quickly to the weak-side centre back or full back who is free.',
    '4-2-3-1', 66, 72, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (4)', 'Pass back to the keeper if the lane is open; otherwise use a link player'),
    (2, 'Ball-side winger (7)', 'Drop back as link player when the direct return to the keeper is blocked'),
    (3, 'Inside midfielder (8)', 'Act as link player to the keeper or to the holding midfielder'),
    (4, 'Ball-side full back (2)', 'Drop back as last link player to the keeper when inside passes are risky'),
    (5, 'Holding midfielder (6) / Goalkeeper', 'Deliver the long switch; weak-side midfielder drops deep to help switch and give safety')
) AS v(so, role, job);

-- 22. pp.67-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Session 5: Switching play against 1 forward and exploiting an advantage on the weak side', 'Weak-side 3v2 / 2v1 after switch',
    'After the switch, the receiver decides the combination by where he got the ball. A centre back carrying into the zone gives 3v2; a full back receiving gives 2v1.',
    'Long switch received on the weak side',
    'Break through the side zone and finish within 6-8 seconds of the switch.',
    '4-2-3-1', 67, 72, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side centre back (5)', 'Carry forward into the side zone and pass on to the full back'),
    (2, 'Weak-side full back (3)', 'Push on to receive; 1-2 with the winger or overlap to get in behind'),
    (3, 'Weak-side winger (11)', 'Diagonal run behind the defender, or give the wall pass and spin'),
    (4, 'Forward (9)', 'Time the run to finish the cross')
) AS v(so, role, job);

-- 23. pp.74-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 4: Step 3 - Creating a numerical advantage near the sideline', 'Centre back carries in to make 3v2',
    'Once the target player beats the first press, the ball-side centre back steps forward with the ball because the near forward (or No.10) is too far away. Against 2 forwards the back three shifts across for a 3v2 safety; against 1 forward it is a 2v1 safety.',
    'Opposing forward too far from the ball-carrying centre back',
    'Create a 3v2 near the sideline (centre back, full back, winger) while staying safe behind the ball.',
    NULL, 74, 75, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (5)', 'Step forward with the ball into midfield'),
    (2, 'Holding midfielder (6)', 'Drop into the back line to cover the advancing centre back'),
    (3, 'Rest of back line (6, 4, 2)', 'Shift to the strong side to keep numbers if the ball is lost'),
    (4, 'Full back (3) and winger (11)', 'Form the 3v2 with the carrier near the touchline')
) AS v(so, role, job);

-- 24. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 4: Step 4 - Option 1(a)', 'Direct pass to free full back',
    'Winger comes inside at an angle and full back stays wide so the opposing winger cannot block both lanes. The carrier reads which lane the winger closes.',
    'Opposing winger presses to cut the inside pass to our winger',
    'Find the unmarked full back near the sideline.',
    NULL, 76, 76, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-carrying centre back (5)', 'Read the opposing winger and pass to whichever option is free'),
    (2, 'Winger (11)', 'Take a central position at a good angle as the inside option'),
    (3, 'Full back (3)', 'Hold a wide, open position as the outside option')
) AS v(so, role, job);

-- 25. pp.77-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 4: Step 4 - Option 1(b)', 'Winger runs behind stepping full back',
    'The free full back carries forward, creating a 2v1 near the sideline and 5v4 overall. The opposing full back must step out to him.',
    'Opposing full back moves forward to contest our ball-carrying full back',
    'Launch a quick attack before the opposing midfield can recover.',
    NULL, 77, 77, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (3)', 'Drive forward into space, then slip the pass behind'),
    (2, 'Winger (11)', 'Diagonal run in behind the stepping full back')
) AS v(so, role, job);

-- 26. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 4: Step 4 - Option 1(c)', 'Forward pulls centre back wide',
    'Variation of the 2v1 near the sideline: the forward drifts toward the touchline as a passing option and his marker follows. This opens the centre of the defence.',
    'Opposing centre back follows our forward out wide',
    'Winger attacks the central gap and receives from the full back for a chance.',
    NULL, 78, 78, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (9)', 'Shift toward the sideline to drag his marker'),
    (2, 'Winger (11)', 'Read the gap and run forward into the centre'),
    (3, 'Full back (3)', 'Pass into the space for the winger''s run')
) AS v(so, role, job);

-- 27. pp.79-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 4: Step 4 - Option 2', 'Winger as link player to full back',
    'Opposing winger presses so as to block the direct pass to our full back, leaving our winger free. What the opposing full back does decides the next option (Options 2-4).',
    'Opposing winger blocks the centre back''s pass to the full back',
    'Move the ball to the full back via the winger, even if the opposing full back waits and presses during the pass.',
    NULL, 79, 79, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-carrying centre back (5)', 'Pass to the free winger'),
    (2, 'Winger (11)', 'Receive and set the ball first time to the full back'),
    (3, 'Full back (3)', 'Take the lay-off and continue with the 1(b) or 1(c) runs')
) AS v(so, role, job);

-- 28. pp.80-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 4: Step 4 - Option 3', 'Winger receives and turns, 2v1',
    'Opposing winger blocks the pass to the full back but the opposing full back holds a balanced position between our winger and full back. Our winger can receive unmarked and turn.',
    'Opposing full back stays balanced instead of stepping out',
    'Winger turns to cut out the midfielders, giving a quick 5v4 with two passing options.',
    NULL, 80, 80, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (11)', 'Receive, turn and drive forward; choose between the overlap and a through pass'),
    (2, 'Full back (3)', 'Overlap outside the winger'),
    (3, 'Attacking midfielder (10)', 'Time a run in behind for the through pass in the centre')
) AS v(so, role, job);

-- 29. pp.81-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 4: Step 4 - Option 4', 'Aerial pass behind jumping full back',
    'Opposing full back moves up to mark our winger before the pass, so neither our winger nor our full back can be found on the ground.',
    'Opposing full back jumps early onto our winger',
    'Exploit the space behind him with a forward run for a 4v3 attack.',
    NULL, 81, 81, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-carrying centre back (5)', 'With time on the ball, play an aerial pass into space'),
    (2, 'Full back (3)', 'Sprint forward into the space behind the opposing full back'),
    (3, 'Winger (11)', 'Pin the opposing full back')
) AS v(so, role, job);

-- 30. pp.83-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Session 6: Creating and exploiting 3v2 situations near the sideline', 'Read defenders, play the free man',
    'Centre back, full back and winger work as a trio against one, then two defenders near the sideline, choosing by the defenders'' reactions. In the team practice the centre backs split wide and a midfielder drops to make a three before a centre back carries into the side zone.',
    'Centre back enters the side zone with the ball',
    'Exploit the 3v2 by dribbling through or receiving in behind within 5-8 seconds.',
    '4-4-2', 83, 90, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Carry in; pass straight to the full back if it is open, otherwise use the winger as link'),
    (2, 'Winger', 'Drop back to receive and turn, or pull the defender to free the full back'),
    (3, 'Full back', 'Receive in space or run behind when the defender follows the winger'),
    (4, 'Holding midfielder (6)', 'Drop between the centre backs to make the back three')
) AS v(so, role, job);

-- 31. pp.92-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 5: Attacking solutions with a 3v3 situation near the sideline (against 2 forwards)', 'Free central midfielder hits space behind',
    'Opponent stops the 3v2 by shifting a central midfielder across to close our carrying centre back, and all their midfielders slide over. Our other central midfielder is left free.',
    'Opposing central midfielder leaves to close down our centre back',
    'Find the free midfielder, who plays long behind the opposing full back for a fast forward (3v3).',
    '4-4-2', 92, 93, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (5)', 'Pass directly to the free midfielder or via the winger'),
    (2, 'Winger (11)', 'Act as link player to the free midfielder'),
    (3, 'Free central midfielder (8)', 'Key player: receive in space and pick the long pass'),
    (4, 'Forward (9)', 'Run into the space behind the opposing full back')
) AS v(so, role, job);

-- 32. pp.93-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 5: Attacking solutions with a 3v3 situation near the sideline', 'Compact block: switch to weak side',
    'When the opponent shifts its midfield across and stays compact, through passes are blocked but the weak side is empty. Against 1 forward, one central midfielder drops deep beside the centre backs to receive the back pass and switch.',
    'Opponent''s midfield compact and shifted to the ball side',
    'Switch to the weak-side full back with space and set up a 2v1 near the sideline.',
    NULL, 93, 101, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free central midfielder (8)', 'Switch play long to the weak-side full back'),
    (2, 'Weak-side full back (2/3)', 'Receive with time and carry forward'),
    (3, 'Weak-side winger (7)', 'Diagonal run behind the opposing full back'),
    (4, 'Centre back (5)', 'Play back to the midfielder when the 3v3 closes')
) AS v(so, role, job);

-- 33. pp.94-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 5: Playing the through pass when the opposition midfield is not compact', 'Through pass into the midfield gap',
    'To stop the switch, the opposing weak-side winger stays wide, which breaks their midfield cohesion and leaves a central gap. Our No.10 sits in the opposing full back''s zone, where he is overloaded 2v1 with our winger.',
    'Opposing weak-side winger holds a wide position',
    'Midfielder (or the other midfielder after an inside pass) threads the ball to No.10, who turns and plays in behind with at least a 3v3 or 4v4.',
    NULL, 94, 101, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (8)', 'Play the through pass, or pass inside to 6 to play it'),
    (2, 'Attacking midfielder (10)', 'Receive between the lines, turn and play the final ball'),
    (3, 'Weak-side winger (7)', 'Pin the opposing full back so he cannot step to No.10'),
    (4, 'Holding midfielder (6)', 'Alternative passer through the gap')
) AS v(so, role, job);

-- 34. pp.95-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 5: Attacking solutions with a 3v3 situation near the sideline (against 1 forward)', 'One midfielder drops deep, not between',
    'Against a lone forward the back line does not need a midfielder dropping between the centre backs. One central midfielder still drops into a deep spot as a back-pass option.',
    'Opponent presses with 1 forward and a No.10 screening the centre',
    'Give the centre back a safe return pass and keep a 2v1 or 3v1 against the forward.',
    '4-2-3-1', 95, 96, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (6)', 'Drop deep near the centre backs, not into the line'),
    (2, 'Centre backs (4, 5)', 'Use him as the back pass, then switch'),
    (3, 'Other central midfielder (8)', 'Look for the switch or the through pass after the back pass')
) AS v(so, role, job);

-- 35. pp.103-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 6: Creating and exploiting space in a 4v3 (or 4v4) situation around the ball area', 'Forward drops across: 3v3 to 4v3',
    'In Bielsa''s 3-4-3 defensive option the ball goes to the free centre back, leaving a 3v3 on that side. The forward drops back and across to act as an extra midfielder. If their central midfielder steps out to close the carrier instead, we switch or play through as in Chapter 5.',
    'Free centre back receives from the keeper with a 3v3 on his side',
    'Make a 4v3 around the ball, then use the 3v2 combinations near the sideline.',
    '4-4-2', 103, 111, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (4)', 'Carry and read which defender closes him'),
    (2, 'Forward (9)', 'Drop back and across to become the extra man'),
    (3, 'Full back (2) and winger (11)', 'Take up the 3v2 combination roles once the opposing winger presses')
) AS v(so, role, job);

-- 36. pp.104-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 6: Opposition centre back follows the forward''s movement', 'No.10 runs behind the following centre back',
    'Opponent answers the dropping forward by sending a centre back with him to mark tightly, making it 4v4 around the ball. This leaves a big gap in the middle of their back line.',
    'Opposing centre back follows our dropping forward',
    'Long pass from the centre back into the gap for No.10''s run, ideally 2v2 or in on goal.',
    '4-4-2', 104, 111, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (9)', 'Drop to pull the centre back out'),
    (2, 'Attacking midfielder (10)', 'Run into the vacated central space'),
    (3, 'Ball-side centre back (4)', 'Play the accurate long pass over the top'),
    (4, 'Winger (11)', 'Join for a 2v2 against the remaining defenders')
) AS v(so, role, job);

-- 37. pp.108-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Session 8: Creating and exploiting space within a 4v3 or 4v4 situation', 'Winger holds, free midfielder switches',
    'In the 4v3/4v4 near the sideline, the opposing winger stays balanced on our full back and their centre back holds, or their midfielder closes the carrier so the winger can mark our full back. Our central player is left free.',
    'Opposing winger does not press the ball-carrying centre back',
    'Free central player receives and switches to the weak-side full back, who has space.',
    '4-4-2', 108, 111, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-carrying centre back', 'Read the opposing winger''s reaction to choose the solution'),
    (2, 'Central midfielder / winger (7)', 'Receive free in space and switch'),
    (3, 'Weak-side full back (3)', 'Receive the switch and drive forward'),
    (4, 'Forwards', 'Rotate positions; one makes a run in behind')
) AS v(so, role, job);

-- 38. pp.113-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 7: Building up play against ultra-offensive pressing (2 forwards)', 'Use 3-4-3 for two link players',
    'Ultra-pressing opponent: both forwards close our centre back and holding midfielder, and their winger sits balanced between our wide centre back and full back to force long balls. Bielsa prefers the defensive 3-4-3 over the 3-3-3-1 here.',
    'Opponent presses high with 2 forwards and a balanced winger',
    'Have two central midfielders available as link players to reach the free full backs.',
    '4-4-2', 113, 113, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three (4, 6, 5)', 'Spread to receive from the keeper'),
    (2, 'Central midfielders (7, 8)', 'Stay in central midfield as potential link players'),
    (3, 'Full backs (2, 3)', 'Push high and wide as the free players')
) AS v(so, role, job);

-- 39. pp.114-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 7: The ball is moved to the free full back through a ''link player''', 'Link player frees the blocked full back',
    'Keeper passes to the wide centre back; the opposing winger presses him on a curved run that cuts off the full back, but leaves the full back unmarked. Session practice: read where their central midfielder is before choosing the link.',
    'Opposing winger presses our centre back and blocks the pass to the full back',
    'Reach the free full back in one or two passes via the midfielder or winger.',
    '4-4-2', 114, 122, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back (5)', 'Pass into the link player'),
    (2, 'Central midfielder (8)', 'Move into the passing lane, receive and set to the full back'),
    (3, 'Winger (11)', 'Alternative link player when the midfielder is covered'),
    (4, 'Full back (3)', 'Receive free and attack, 2v1 with the winger')
) AS v(so, role, job);

-- 40. pp.115-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 7: Overcoming pressure by playing back to GK + long pass towards the full back', 'Back to keeper, long to full back',
    'Opposing central midfielder shifts across in time to mark our link player tightly and the passing lane narrows, making the link pass too risky.',
    'Link player marked tightly and lane closing',
    'Keeper hits a long pass to the free full back into a 2v1; if their full back misses it, our winger runs in behind.',
    '4-4-2', 115, 122, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back (5)', 'Play back to the keeper'),
    (2, 'Goalkeeper', 'Long pass toward the free full back'),
    (3, 'Full back (3)', 'Receive in space and play in the winger'),
    (4, 'Winger (11)', 'Run behind the opposing full back after a failed interception')
) AS v(so, role, job);

-- 41. pp.116-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'marcelo-bielsa-coaching-build-up-play-against-high-pressing-teams'), 'in_possession', 'Chapter 7: Positioning for Bielsa''s defensive 3-4-3 option vs ultra-offensive pressing with 1 forward', 'Ultra-press with 1 forward',
    'Both opposing wingers take balanced spots controlling our centre back and full back on each side, and the forward marks our holding midfielder, giving 3v3 at the back. The link-player and long-ball solutions still apply, but with an extra opposing midfielder they are harder.',
    '1-forward opponent presses ultra-high with both wingers balanced',
    'Still reach the free full backs, with central midfielders dropping deeper to get free as link players.',
    '4-2-3-1', 116, 116, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (4, 5)', 'Receive from the keeper and draw the winger'),
    (2, 'Central midfielders (7, 8)', 'Drop deeper to escape the extra midfielder and act as links'),
    (3, 'Full backs (2, 3)', 'Stay free high and wide'),
    (4, 'Goalkeeper', 'Go long to a full back when links are covered')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1969-coaching-book-bielsa-build-up-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
