-- 1958 📚 Coaching book patterns: Delgado Bordonau & Mendez Villanueva,
-- "Tactical Periodization - A Proven Successful Training Model"
-- (SoccerTutor).  Every page (1-244) read.  A method book, so a "pattern"
-- is each on-pitch principle or worked example it gives (game-model
-- principles per phase, block reorganisation on loss, directing play,
-- collective pressing rules, counters by zone, Mourinho examples, match /
-- opponent analysis cases, practices tied to a match situation), written up
-- in OUR OWN WORDS with app page numbers as the citation and who does what.
-- Periodization theory, loads and drill set-ups are left out.  Pages
-- 187-196 were captured with a call notification over part of the screen;
-- read anyway.  Owner's personal library.  (James 11/26 'continue with the
-- reading of the coach viewer books')
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Tactical Periodization',
    subtitle    = 'A Proven Successful Training Model',
    author      = 'Juan Luis Delgado Bordonau, José Alberto Mendez Villanueva',
    team        = 'Vitor Frade''s method; José Mourinho examples',
    method_note = 'A training-method book: Vitor Frade''s Tactical Periodization, where every session serves the game model. The game model splits play into four phases with main, sub and sub-sub principles; training follows fractality, specificity, propensities, systematic repetition, complex progression, tactical fatigue and concentration, and performance stabilisation, on a fixed week after a Sunday game (Monday off, Tuesday recovery, Wednesday strength, Thursday endurance, Friday speed, Saturday activation). Each week''s objectives come from the game model, the last match and the next opponent. Patterns here are the on-pitch principles and worked examples (Mourinho''s Real Madrid, match and opponent analysis, practices tied to a match situation), in our words; periodization theory and loads are left out.'
WHERE slug = 'tactical-periodization-a-proven-successful-training-model';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model');

-- 1. pp.56-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 3: Fractality - Training Example 3', 'Centre backs defend zonally and cover',
    'Ball played in behind the back line; the two centre backs must protect depth together.',
    'Deep ball into space behind the defence',
    'Both centre backs set their position from the ball and cover each other, so neither is just tied to a forward.',
    NULL, 56, 56, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back', 'steps to the ball/forward in his zone'),
    (2, 'Far centre back', 'drops and angles to cover behind the partner'),
    (3, 'Both centre backs', 'shift together with the ball, never one fixed man-marker plus one sweeper')
) AS v(so, role, job);

-- 2. pp.65-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 3: Principle of Propensities - Probability', 'Win the second ball versus direct play',
    'Scouting says the opponent breaks after winning the ball with straight long balls to their front players.',
    'Opponent wins the ball and goes long',
    'Midfielders stand where the long ball will drop and press it so the knock-down is ours.',
    NULL, 65, 65, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'take up positions under the likely drop zone'),
    (2, 'Midfield unit', 'press the receiver as the long ball lands to win the knock-down'),
    (3, 'Centre backs', 'challenge the first header')
) AS v(so, role, job);

-- 3. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 3: Principles of Play - Practice Example (5v5 build-up, 2-1-2 from 4-3-3)', 'Build through the holding midfielder centrally',
    'Centre backs are not getting the ball into midfield through the middle; 4-3-3 with one holding midfielder.',
    'Ball with a centre back in build-up',
    'Play into the holding midfielder and on into an advanced central midfielder through the central channel.',
    NULL, 67, 67, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (pair)', 'receive from the keeper and look to play into the middle'),
    (2, 'Holding midfielder', 'shows between the centre backs'' lines to receive and turn or set'),
    (3, 'Two advanced central midfielders', 'offer high either side to receive the next pass')
) AS v(so, role, job);

-- 4. pp.68-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 3: Uniqueness of the Process - Specific Practices (Guilherme Oliveira''s transition example)', 'Safety transition: keep it after regaining',
    'Team wins the ball back and has to choose between keeping it (safety) and going straight forward (depth).',
    'Ball regained',
    'Unless a clear direct attack is on, secure possession first and build from there.',
    NULL, 68, 68, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins it', 'takes the secure pass out of the pressure area first'),
    (2, 'Nearby teammates', 'open short safe options around the ball'),
    (3, 'Front players', 'offer depth for when a direct attack is clearly on')
) AS v(so, role, job);

-- 5. pp.69-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 3: Specific (Tactical) Practice Example - Playing Out from the Back', 'Play out from the back under pressure',
    'Keeper has the ball with the back four, two central midfielders support; the opponent presses with three forwards and two midfielders.',
    'Keeper passes to a defender',
    'Move the ball forward from the back with a diagonal into a midfielder or a full back running forward, not a hopeful clearance.',
    NULL, 69, 69, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'starts it to a centre back or full back'),
    (2, 'Pressed full back', 'finds the free supporting teammate rather than clearing long'),
    (3, 'Centre backs', 'play the diagonal into a central midfielder'),
    (4, 'Central midfielders', 'move into free lanes to receive'),
    (5, 'Full backs', 'run forward to give the forward option')
) AS v(so, role, job);

-- 6. pp.84-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 3: Principle of Complex Progression - Ordering the Principles', 'Defend deep, break in behind fast',
    'A side with limited technique but quick strikers places its priority on a deep block and fast breaks.',
    'Ball won in the deep block',
    'Attack the space behind the opponent quickly before they recover.',
    NULL, 84, 84, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back unit and midfield', 'defend a deep, compact block'),
    (2, 'Player who wins it', 'releases forward early'),
    (3, 'Fast strikers', 'run behind the opponent''s line as soon as the ball is won')
) AS v(so, role, job);

-- 7. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_defend', 'Chapter 3: Example of How to Break Down a Principle of Play (transition attack to defence)', 'Press the ball and space immediately on loss',
    'Ball lost; the team switches straight into defending, rather than giving up the moment (Mourinho''s Benfica problem).',
    'Possession lost',
    'Instant pressure on the carrier and the space around him forces the opponent to play backwards while the team gets compact.',
    NULL, 85, 85, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player(s)', 'press the carrier at once and close the space around him'),
    (2, 'Players around the ball', 'switch mentally from attack to defence and cut forward passes so the ball goes backwards'),
    (3, 'Rest of team', 'get compact so the team can either keep pressing or settle into shape'),
    (4, 'All', 'talk to organise cover behind the press')
) AS v(so, role, job);

-- 8. pp.90-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 3: Principle of Tactical Fatigue and Concentration (Guilherme Oliveira on patience)', 'Patient possession until concentration breaks',
    'Facing a well-organised defence; long spells without the ball wear down the defenders'' concentration.',
    'Opponent set in an organised block',
    'Keep the ball patiently and wait for the concentration lapse that opens spaces, then exploit it.',
    NULL, 90, 90, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'keep circulating without forcing the final pass'),
    (2, 'Midfield', 'move the ball to stretch and tire the block'),
    (3, 'Front players', 'watch for the gap that appears when the block switches off, and attack it')
) AS v(so, role, job);

-- 9. pp.108-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_defend', 'Chapter 4: The Game Model - Combining the four phases', 'Rest defence while attacking',
    'While the team attacks it already keeps defensive balance: a numerical edge in the back line and the opposing forwards marked, with risk taken in wide channels and the central channel protected.',
    'Team in possession, especially in the final third',
    'Ready to stop the counter the instant the ball is lost.',
    NULL, 108, 125, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Keep a +1 against the opposing forwards'),
    (2, 'Holding midfielder', 'Screen the central channel'),
    (3, 'Attackers', 'Take risks out wide rather than through the middle')
) AS v(so, role, job);

-- 10. pp.110-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 4: The Game Model - Attacking passing lines with different systems', 'Triangles and diamonds for passing lines',
    'Whatever the shape (4-3-3, 4-4-2 diamond, 3-4-3), players keep staggered so every carrier sits inside triangles/diamonds with several diagonal lanes across width and depth; positions keep rotating so the geometry is dynamic, not fixed.',
    'Own possession, any zone',
    'Give the carrier about three passing options and keep the ball moving at speed.',
    NULL, 110, 125, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Body open (receive side-on) to see all three options'),
    (2, 'Nearest teammates', 'Offer diagonal angles, never flat lines'),
    (3, 'Far-side players', 'Hold width and depth to keep lanes long')
) AS v(so, role, job);

-- 11. pp.116-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 4: The Game Model - Principles of play', 'Defending principles: delay, depth, balance, concentration, composure',
    'The five specific defensive principles: first defender slows the attack and closes gaps, a second gives cover, numbers at the point of attack are at least equal while the goal area stays covered, the block squeezes the attack into a narrow predictable area, and defenders stay patient goal-side instead of diving in.',
    'Opponent has the ball',
    'Buy time for the block to organise and deny shooting chances.',
    NULL, 116, 116, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First defender', 'Delay: close the carrier, deny forward space'),
    (2, 'Second defender', 'Depth: cover behind the presser'),
    (3, 'Rest of the back line', 'Balance: match or outnumber attackers, cover the goal area'),
    (4, 'Whole block', 'Concentration: compress play into a small zone')
) AS v(so, role, job);

-- 12. pp.116-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 4: The Game Model - Principles of play', 'Attacking principles: penetration, depth, mobility, width, creativity',
    'The five specific attacking principles as team behaviours: beat opponents forward (pass, dribble, run, 2v1), support behind/around the ball, rotate and run off the ball to create overloads, attack on a broad front to isolate 1v1s, and individual flair (take-ons, overlaps, blind-side runs).',
    'Own possession',
    'Create numerical superiority and avoid equal or inferior situations near the ball.',
    NULL, 116, 117, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Penetrate when a line can be beaten'),
    (2, 'Supporting players', 'Give depth: safe option behind/beside the ball'),
    (3, 'Wide players', 'Stay wide to stretch the back line'),
    (4, 'Off-ball runners', 'Move to drag defenders and open overloads')
) AS v(so, role, job);

-- 13. pp.118-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 4: The Game Model - Compatibility of principles and phases', 'Out of the pressure zone, then choose',
    'On a regain the first job is getting the ball out of the zone where the opponent can press; then either one or two safety passes (sideways/back) to let the team spread out and start a possession attack, or a deep pass straight in behind to exploit the momentary disorganisation.',
    'Ball won',
    'Keep the ball and pick the right speed of attack for how disorganised the opponent is.',
    NULL, 118, 118, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winner of the ball', 'First pass away from the pressure, play easy'),
    (2, 'Nearest support', 'Offer a safe side or back option'),
    (3, 'Forwards', 'Show for the deep pass in behind')
) AS v(so, role, job);

-- 14. pp.124-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 5: Attacking Phase - Principles for the attacking phase', 'Create space with overloads and switches',
    'Ball circulation at high speed with varied rhythm (short and long) disrupts the defensive block: create 2v1s in central and wide channels, rotate positions to drag defenders out, and switch play side to side through all three channels.',
    'Opponent block organised',
    'Open gaps inside the opponent''s structure.',
    NULL, 124, 126, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'Rotate positions to pull markers'),
    (2, 'Wide pair (full back + winger)', 'Create 2v1 on the flank'),
    (3, 'Pivot', 'Switch play across the three corridors')
) AS v(so, role, job);

-- 15. pp.124-171
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 5: Attacking Phase - Principles for the attacking phase', 'Make the pitch big in build-up',
    'Building from the goalkeeper, centre backs split to receive, full backs and wingers push wide and the whole team spreads in width and depth; the back four aim to pass into the midfield line (or directly to the forward line).',
    'Goalkeeper or back four has the ball',
    'Stretch the opponent and find a free man in midfield.',
    NULL, 124, 171, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Comfortable on the ball, starts circulation'),
    (2, 'Centre backs', 'Split wide to receive from the keeper'),
    (3, 'Full backs', 'Push wide and high'),
    (4, 'Wingers', 'Hold the touchline, never drift inside'),
    (5, 'Midfielders', 'Set-up movements to receive between lines')
) AS v(so, role, job);

-- 16. pp.125-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 5: Attacking Phase - Attacking in the final third', 'Fill three box zones plus one outside',
    'When the ball reaches the final third, three players attack the front post, penalty spot and far post (the far post taken by the one with most time to read the ball) while one waits outside the box for a second ball or a cut-back; overlapping runs inside and outside create finishing chances.',
    'Ball in the final third / wide delivery coming',
    'Score while keeping enough balance behind.',
    NULL, 125, 126, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Runner 1', 'Attack the front post'),
    (2, 'Runner 2', 'Attack the penalty spot'),
    (3, 'Runner 3', 'Attack the far post late'),
    (4, 'Edge-of-box player', 'Second balls and cut-backs'),
    (5, 'Full back', 'Overlap outside or inside')
) AS v(so, role, job);

-- 17. pp.126-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 5: Attacking Phase - Principles for the attacking phase', 'Exploit the disorganisation moment',
    'Once space has been opened, spot the moment the opponent is unbalanced and pass well-weighted into that space; play forward to the next line whenever possible, and use a third man to set the ball back and play forward again rather than running with the ball.',
    'A gap appears after circulation',
    'Turn created space into forward progress before the block recovers.',
    NULL, 126, 126, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Weighted pass into the created space'),
    (2, 'Third man', 'Lay the ball off so it can be played forward again'),
    (3, 'Receiver', 'Play forward to the next sector line')
) AS v(so, role, job);

-- 18. pp.127-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 5: Attacking Phase - Jose Mourinho example: switching play to the weak side', 'No.10 drops to switch play (Mourinho, Real Madrid)',
    'The opponent shifts and triple-marks the left winger; the No.10 (Ozil) drops deep on that side to give a back pass angle, then has four options with the forward pass risky and the switch to the far side (right winger or right centre back) the best.',
    'Opponent compact and overloaded on the ball side',
    'Keep the ball and switch it to the weak side.',
    NULL, 127, 127, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 (Ozil)', 'Drop to support, receive, switch play'),
    (2, 'Left winger (Ronaldo)', 'Draw the triple mark, play back'),
    (3, 'Forward (Benzema)', 'Drop toward ball side'),
    (4, 'Right winger (Di Maria)', 'Hold far-side width for the switch')
) AS v(so, role, job);

-- 19. pp.128-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 5: Attacking Phase - Jose Mourinho example: switching play to the weak side', 'Holding midfielder switches play (Mourinho, Real Madrid)',
    'With the opponent shifted compactly toward the ball, the defensive midfielder (Xabi Alonso) quickly moves across to give a central option, receives and chooses the switch to the far winger or far centre back over the risky forward pass.',
    'Ball on one flank, opponent shifted',
    'Retain the ball and attack the weak side.',
    NULL, 128, 128, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Alonso)', 'Shift across, receive centrally, switch'),
    (2, 'Left back (Marcelo)', 'Play inside to the pivot'),
    (3, 'Far winger (Di Maria)', 'Wide on the weak side'),
    (4, 'Far centre back (Pepe)', 'Safe switch outlet')
) AS v(so, role, job);

-- 20. pp.130-172
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_defend', 'Chapter 5: Transition from Attack to Defence - Main principles', 'Press to win, press to win time, organise',
    'On losing the ball the first idea is to press the carrier and nearby space to regain and counter; if that fails, keep pressing to delay and stop forward play and balls in behind; once there is time, recover into defensive positions. Players switch to a defensive attitude instantly, press as a unit with cover, close lanes and use body shape to push play to one side and onto the weaker foot.',
    'Ball lost',
    'Stop the counter: force sideways/backward passes and keep the ball inside the pressure zone.',
    NULL, 130, 172, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'Press the new carrier at once'),
    (2, 'Next nearest', 'Close passing lanes and cover the presser'),
    (3, 'Midfield and back line', 'Stay balanced in position and numbers'),
    (4, 'Goalkeeper', 'Advanced, act as sweeper behind a high line')
) AS v(so, role, job);

-- 21. pp.131-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_defend', 'Chapter 5: Transition from Attack to Defence - Reorganising into defensive block positions', 'Reorganise into a high block',
    'If the ball is not won in the first seconds, the team sets up in the opponent''s half: back four on or beyond halfway, short vertical distances between lines, carrier pressed and lanes limited. Main position; risk is space behind and long balls, so the back four must hold a good line and know when to step or drop.',
    'Ball lost, no immediate regain, chosen main position',
    'Win the ball early in the opponent''s build-up and force rushed play.',
    NULL, 131, 132, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Line on the halfway line or higher'),
    (2, 'Midfield and forwards', 'Keep short vertical gaps, limit lanes'),
    (3, 'Presser', 'Close the ball carrier'),
    (4, 'Goalkeeper', 'Sweep the space behind')
) AS v(so, role, job);

-- 22. pp.133-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_defend', 'Chapter 5: Transition from Attack to Defence - Reorganising into defensive block positions', 'Reorganise into a middle block',
    'Team defends from inside its own half with only the striker in the other half; back line about 10-15 yards ahead of the penalty area and the lines 10-15 yards apart. Main position; the keeper plays high to cover the space behind, and an offside trap is available.',
    'Ball lost, main position chosen',
    'Compact block between ball and goal, keep opponent''s build-up far away and counter effectively.',
    NULL, 133, 133, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'Stay in the other half'),
    (2, 'Back four', '10-15 yards ahead of the box'),
    (3, 'Lines', 'Keep 10-15 yards between them'),
    (4, 'Goalkeeper', 'Play high behind the line')
) AS v(so, role, job);

-- 23. pp.134-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_defend', 'Chapter 5: Transition from Attack to Defence - Reorganising into defensive block positions', 'Drop into a deep block',
    'Secondary position used only when the opponent pushes the team back: defensive line in and around the edge of the box, other lines at preset vertical distances, keeper close to goal. Very protective and dense but cedes initiative and makes counters long.',
    'Opponent progresses and forces the team back',
    'Protect the goal with high defensive density.',
    NULL, 134, 134, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Hold around the edge of the penalty area'),
    (2, 'Midfield', '10-15 yards ahead, block shooting lanes'),
    (3, 'Goalkeeper', 'Stay close to the goal')
) AS v(so, role, job);

-- 24. pp.136-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_defend', 'Chapter 5: Transition from Attack to Defence - Jose Mourinho example: pressing immediately after losing possession', 'Condense the centre after a central loss (Mourinho, Real Madrid)',
    'When the ball is lost in the centre, both full backs tuck in goal-side of the opposing wingers while the two holding midfielders (Alonso, Khedira) step onto the receiver''s passing options and try to win it back; if the ball is regained, the full backs are already placed to receive a forward pass.',
    'Ball lost in the middle of the pitch',
    'Limit time and space so the opponent loses the ball.',
    NULL, 136, 136, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (Marcelo, Arbeloa)', 'Move inside, goal-side of the wingers'),
    (2, 'Defensive midfielder (Alonso)', 'Block the carrier''s passing options'),
    (3, 'Central midfielder (Khedira)', 'Safety player, press and close lanes')
) AS v(so, role, job);

-- 25. pp.138-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 5: Defensive Phase - Zone defence', 'Zone defence anchored on the ball',
    'Each player owns an area and deals with whoever enters it, releasing them when they leave or the ball is won; zone positions always follow the ball so the team forms a compact, permanent block between ball and goal with numbers around the ball.',
    'Opponent in possession, block set',
    'Numerical superiority near the ball, constant cover, force sideways passes.',
    NULL, 138, 139, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Every defender', 'Defend the zone, positions referenced to the ball'),
    (2, 'Ball-zone players', 'Outnumber attackers near the ball'),
    (3, 'Teammates from same/other line', 'Repair individual mistakes at once')
) AS v(so, role, job);

-- 26. pp.140-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 5: Defensive Phase - Directing the opposition', 'Force play outside into the wide channel',
    'The block shuts the inside options: wide and central players block passes into the middle while the centre is kept compact and the potential central receivers are tightly marked, steering the carrier down the touchline.',
    'Opponent full back on the ball',
    'Trap the opponent in the wide channel where the touchline helps.',
    NULL, 140, 140, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger and forward', 'Block inside passes'),
    (2, 'Central midfielders', 'Mark central receivers tightly'),
    (3, 'Back line', 'Stay compact centrally')
) AS v(so, role, job);

-- 27. pp.140-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 5: Defensive Phase - Directing the opposition', 'Inviting play inside our block to trap',
    'Unusual but deliberate: the block lets the opponent pass into the central space between the lines so that several players (four in the example) can close the new carrier at once and win the ball in the congested area.',
    'Pass into a central receiver inside the block',
    'Win the ball in a crowded central area.',
    NULL, 140, 141, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Surrounding midfielders', 'Collapse on the receiver together'),
    (2, 'Back line', 'Hold so the receiver cannot turn and play through'),
    (3, 'Forwards', 'Close the return pass')
) AS v(so, role, job);

-- 28. pp.141-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 5: Defensive Phase - Directing the opposition', 'Force play into the central channel, outside our block',
    'The block keeps the central receivers marked so nothing goes ''inside'' the team, but lets the carrier pass back into the central channel in front of the block (e.g. to the centre back).',
    'Opponent wide player on the ball',
    'Push the opponent backwards and keep the ball in front of the block.',
    NULL, 141, 141, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Mark the opposing No.6/No.8'),
    (2, 'Forward', 'Mark the opposing No.9 lane / screen'),
    (3, 'Block', 'Stay compact, let the back pass go')
) AS v(so, role, job);

-- 29. pp.142-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 5: Defensive Phase - Collective pressing', 'Collective pressing rules',
    'All eleven press together: a player near an opponent about to receive in a poor position leads and sets the timing, the rest close space vertically and horizontally, mark close to the ball and keep the central corridor protected, pressing in a compact but staggered block; when the press is beaten they drop off and reorganise before pressing again.',
    'Tactical cue (opponent receiving badly, wrong body shape, no support)',
    'Win the ball by limiting the carrier''s options.',
    NULL, 142, 142, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lead presser', 'Choose the moment and the angle'),
    (2, 'Near-ball players', 'Mark receivers tightly'),
    (3, 'Second line', 'Staggered cover behind the presser'),
    (4, 'Whole team', 'Protect the centre, reorganise if bypassed')
) AS v(so, role, job);

-- 30. pp.143-143
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 5: Defensive Phase - Sub-principles for collective pressing', 'Compactness distances',
    'Once organised, the unit between ball and goal keeps lateral gaps inside each line of about 8-10 yards and vertical gaps between lines of about 14-16 yards, adjusted to the situation, and moves with the ball at speed to keep those distances wherever the ball is.',
    'Defensive shape set',
    'A small block nobody can play through.',
    NULL, 143, 143, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Each line', '8-10 yards between neighbours'),
    (2, 'Between lines', '14-16 yards'),
    (3, 'Whole block', 'Move together with the ball')
) AS v(so, role, job);

-- 31. pp.144-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 5: Defensive Phase - Sub-principles for collective pressing', 'Collective shifting to the ball',
    'The block shifts as one: sideways with every lateral pass (e.g. when the centre back plays wide to the full back all players slide across keeping their gaps), and backwards or forwards depending on whether the carrier has time to play behind the line.',
    'Ball moves laterally, or carrier unpressured with time',
    'Deny space horizontally and vertically, force backward or square passes, set up the next press.',
    NULL, 144, 145, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger', 'Step onto the new carrier'),
    (2, 'Midfielders', 'Slide across at the same spacing'),
    (3, 'Back four', 'Slide across; drop if the carrier is free'),
    (4, 'Far-side players', 'Tuck in, giving up the far flank')
) AS v(so, role, job);

-- 32. pp.146-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 5: Defensive Phase - Sub-principles for collective pressing', 'Active and non-active defensive areas',
    'By shifting, the team creates an active area near the ball, densely defended, and leaves the far side as a non-active area; the players nearest that free zone keep an eye on the opponents in it (e.g. the far full back and winger).',
    'Block shifted to one flank',
    'Cluster the block around the ball while monitoring the far side.',
    NULL, 146, 146, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side players', 'Defend the active area densely'),
    (2, 'Far full back and winger', 'Watch the passive zone''s opponents')
) AS v(so, role, job);

-- 33. pp.147-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 5: Defensive Phase - Sub-principles for collective pressing', 'Defensive cover around the presser',
    'When one player (No.10 in the example) presses the carrier, three nearby teammates immediately take covering positions around him, cutting the carrier''s time, space and passing options.',
    'Teammate engages the ball carrier',
    'Contain the carrier and stop progression.',
    NULL, 147, 147, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Presser', 'Close the ball carrier'),
    (2, 'Covering midfielders (e.g. No.6, No.7, No.8)', 'Form a cover ring, block passing lanes')
) AS v(so, role, job);

-- 34. pp.148-148
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 5: Defensive Phase - Principles for the defensive phase', 'Pressing triggers to win the ball',
    'The team presses ''all together'' to force mistakes when cues appear: a poor first touch, poor pass or clearance under pressure; a throw-in deep in the opponent''s half with a short-range thrower; a ball in the air or bouncing awkwardly in their half; a back pass to a goalkeeper with poor feet or onto his weaker side; the ball in the last third where we have numbers. Half-and-half positions make the carrier hesitate.',
    'Any of the listed cues',
    'Regain by interception or tackle.',
    NULL, 148, 148, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'Press at speed with the correct angle and body shape'),
    (2, 'Near teammates', 'Close wide and forward passing options'),
    (3, 'Block', 'Shift across collectively')
) AS v(so, role, job);

-- 35. pp.149-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 5: Defensive Phase - Jose Mourinho example: collective pressing and directing opponent', 'High press forcing play outside (Mourinho, Real Madrid)',
    'Against the opponent''s goal kick build-up: the left winger stays goal-side of the full back, the defensive midfielder steps toward the free No.6, the No.10 moves to the strong side and the other central midfielder shifts across for balance; when the ball goes wide, the winger presses the new carrier, Alonso leaves his man because the body shape makes the inside pass unlikely, defenders follow their men, and when the ball reaches the winger the full back presses while the winger tracks back to double-mark, with roles handed over to cover.',
    'Opponent centre back plays out wide',
    'Force play outside and win it on the flank.',
    NULL, 149, 150, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Goal-side, then press the full back, then track back to double'),
    (2, 'Defensive midfielder (Alonso)', 'Squeeze the No.6, then release'),
    (3, 'Central midfielder (Khedira)', 'Shift to the strong side for balance, take the No.10'),
    (4, 'Left back (Marcelo)', 'Mark the winger tightly, press when he receives'),
    (5, 'Centre back (Ramos)', 'Follow the No.10, hand over and drop to cover'),
    (6, 'No.10 (Ozil)', 'Shift strong side, drop for midfield balance')
) AS v(so, role, job);

-- 36. pp.151-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 5: Transition from Defence to Attack - Transition from defence to attack', 'Consolidate or counter, depending on block',
    'On regaining, the team chooses between keeping the ball (when the opponent is still organised or the ball is won high against a deep side) and a counter (when space and imbalance exist); a winger in a wide defensive role both stops the switch and stays ready to counter.',
    'Ball won',
    'Take the ball out of the pressure zone in the way the opponent''s disorganisation allows.',
    NULL, 151, 152, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger on ball side', 'Defend the switch, ready to break'),
    (2, 'Ball winner', 'Read space and opponent balance'),
    (3, 'Team', 'Spread out if consolidating, sprint forward if countering')
) AS v(so, role, job);

-- 37. pp.153-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 5: Transition from Defence to Attack - From the low zone', 'Counter from the low zone (deep block)',
    'After an interception deep, the team first secures the ball, plays wide and switches out of the pressure zone; 3-5 players join, use all three channels to stretch the block, and finish in about 3-4 passes (possible set-back, outlet in behind, early second pass, finish).',
    'Ball won in the deep block',
    'Reach goal while the opponent is still stretched.',
    NULL, 153, 153, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (right winger)', 'Pass forward to the striker'),
    (2, 'Striker', 'Lay back to a midfielder'),
    (3, 'Defensive midfielder', 'Switch play to the far winger'),
    (4, 'Far winger', 'Run in behind, deliver or finish')
) AS v(so, role, job);

-- 38. pp.154-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 5: Transition from Defence to Attack - From the middle zone', 'Counter from the middle zone (middle block)',
    'Ball won by the holding midfielder: quick turnover played forward and in behind with 3-4 players, all three channels used once; about three passes (outlet in behind, second and third early passes, finish) aiming to get behind the back four by going over or around.',
    'Ball won by the No.6 in midfield',
    'Get in behind the back four before they recover.',
    NULL, 154, 154, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Win it and pass forward to the striker'),
    (2, 'Striker', 'Switch to the winger'),
    (3, 'Winger', 'Burst forward, cut back'),
    (4, 'No.10', 'Arrive and finish')
) AS v(so, role, job);

-- 39. pp.155-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 5: Transition from Defence to Attack - From the high zone', 'Counter from the high zone (high block)',
    'Ball won high (winger strips the full back): play straight in behind and finish fast with 2-3 players, 1-2 passes, no need to stretch the block; the receiver in the box has options of central midfielder, forward and far winger making forward runs.',
    'Ball won in the opponent''s half',
    'Quick finish before the defence can react.',
    NULL, 155, 155, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Win the ball, pass in behind'),
    (2, 'No.10', 'Run onto it in the box'),
    (3, 'Forward, central midfielder, far winger', 'Forward runs to finish')
) AS v(so, role, job);

-- 40. pp.156-174
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 5: Transition from Defence to Attack - Principles', 'Exploit disorganisation without needless risk',
    'Main principle: move the ball out of the pressure zone while the opponent is disorganised by switching instantly to an attacking attitude and spreading out; play forward and in behind if possible but not recklessly; circulate across the three corridors; or keep the ball safely while starting the attack. Supporters offer in front and behind, first pass must succeed, runs timed against offside, a runner in behind goes to goal or holds up for support.',
    'Ball won',
    'Take advantage of the transition moment while keeping possession.',
    NULL, 156, 174, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Successful first pass, play easy'),
    (2, 'Supporting players', 'Offer in front and behind the ball'),
    (3, 'Runners', 'Time runs to stay onside'),
    (4, 'Receiver in behind', 'Shoot or hold for support')
) AS v(so, role, job);

-- 41. pp.157-157
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 5: Transition from Defence to Attack - Jose Mourinho example: fast break attack', '4v3 fast break (Mourinho, Real Madrid)',
    'The No.10 intercepts in midfield and drives forward while the left winger moves wide to take the pass on the run; the winger pulls one centre back out, the striker runs in behind him and receives, the other centre back is drawn to him and gaps open, and the No.10 runs directly into the striker''s position to finish the cross.',
    'Interception in midfield',
    'Create a 4v3 and score before the defence resets.',
    NULL, 157, 157, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 (Ozil)', 'Intercept, carry, pass wide, then run into the centre forward spot'),
    (2, 'Left winger (Ronaldo)', 'Take it wide on the run, drag a centre back'),
    (3, 'Striker (Benzema)', 'Run behind the centre back, cross'),
    (4, 'Other winger (Di Maria)', 'Support the break')
) AS v(so, role, job);

-- 42. pp.162-173
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 6: Analysing the Previous Match Performance - Transition from attack to defence / Defensive phase examples', 'Back line pushes up to shut the space between lines',
    'Analysis error corrected: on losing the ball, and when the opponent passes backwards, the defensive line must step up so the gap between midfield and defence stays small; otherwise the opponent''s centre back can play into the space between the lines and create a 4v4.',
    'Ball lost, or opponent plays back',
    'Deny receivers between the lines and keep collective pressure.',
    NULL, 162, 173, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Push up from back to front'),
    (2, 'Midfield line', 'Press forward and across'),
    (3, 'Whole team', 'Keep distances between sectors tight')
) AS v(so, role, job);

-- 43. pp.164-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 6: Analysing the Previous Match Performance - Transition from defence to attack example', 'Winger wins it: play in behind at once',
    'Analysis error corrected: the left winger wins the ball and plays safe back to the midfielder; he should instead exploit the temporary disorganisation by passing between the two centre backs for the striker''s run (1v1 with the keeper) or down the line for the No.10 to dribble or cross for the No.9.',
    'Wide player wins the ball from his direct opponent',
    'Turn the regain into a direct scoring chance.',
    NULL, 164, 164, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger', 'Pass in behind immediately'),
    (2, 'Striker', 'Run between the centre backs'),
    (3, 'No.10', 'Run down the line, dribble or cross')
) AS v(so, role, job);

-- 44. pp.166-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 6: Analysing the Next Opponent - Attacking phase example', 'Deny the direct 4-4-2''s long diagonals',
    'Next opponent skips midfield: forwards stay high on the centre backs and defenders hit long diagonals behind the line. Our defenders watch for these passes, drop off when needed and track the two forwards'' runs, while midfielders and forwards press the carrier so he cannot lift his head and pass accurately.',
    'Opponent defender has time on the ball',
    'Kill the long diagonal ball in behind.',
    '4-4-2', 166, 166, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Drop off and track the two forwards'),
    (2, 'Midfielders and forwards', 'Press the carrier, deny time')
) AS v(so, role, job);

-- 45. pp.167-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 6: Analysing the Next Opponent - Transition from attack to defence / Defensive phase examples', 'Switch fast to the weak side vs compact 4-4',
    'This opponent, on losing the ball, packs players behind the ball in a compact low 4-4 block and is hard to break centrally, but its wingers and a central midfielder leave gaps and it struggles with fast circulation; we switch play quickly out wide to counter and, in possession, attack the gap the left back leaves when he stays with our winger after the block shifts, playing through the centre into the box.',
    'Ball won centrally / compact block shifted to one side',
    'Exploit the weak far side and the full back-centre back gap.',
    '4-4-2', 167, 168, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (full back)', 'Switch to the far side quickly'),
    (2, 'Far winger', 'Receive wide and attack'),
    (3, 'Forwards', 'Time runs into the box through the gap'),
    (4, 'Midfielders', 'High-tempo circulation side to side')
) AS v(so, role, job);

-- 46. pp.169-169
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_defend', 'Chapter 6: Analysing the Next Opponent - Transition from defence to attack example', 'Guard the counter of a 4-4-2 that leaves two up',
    'The opponent keeps two forwards high and, on winning the ball, plays deep diagonals over our back four. As soon as we lose it, our centre backs drop off and track the forwards, the full backs and defensive midfielder sprint back to create a numerical edge, and the goalkeeper stands advanced to sweep.',
    'Ball lost against this opponent',
    'Neutralise long counter-attack balls in behind.',
    '4-4-2', 169, 169, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Drop and track the two forwards'),
    (2, 'Full backs', 'Track back quickly'),
    (3, 'Defensive midfielder', 'Recover to add numbers'),
    (4, 'Goalkeeper', 'Advanced position as sweeper')
) AS v(so, role, job);

-- 47. pp.180-180
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 8: Standard Weekly Training Pattern - Tuesday (Oliveira example)', 'Build up through the wide channels',
    'The next opponent''s forwards push the build-up out to the full backs by shutting the middle channel.',
    'Opponent forwards screen the centre backs and the central lane',
    'Have ready-made ways to build up out wide when the centre is closed.',
    NULL, 180, 180, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'split wide and give the ball to the full backs early'),
    (2, 'Full backs', 'take the first pass and carry or combine forward'),
    (3, 'Wide midfielders/wingers', 'come short or go in behind to give the full back options'),
    (4, 'Central midfielders', 'move across to the ball side to make triangles')
) AS v(so, role, job);

-- 48. pp.189-198
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_defend', 'Chapter 9: Training Sessions (1 Match Week) - Wednesday: Pressing as a Collective Unit', 'Create a Pressure Zone on loss',
    'Right after losing the ball the nearest players press the carrier and close the area around the ball as one unit. They show him inside or outside and onto his weaker foot.',
    'Possession lost',
    'Stop the opponent playing forward or behind our defensive line and win the ball back.',
    NULL, 189, 198, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'press the ball carrier at the right speed and angle'),
    (2, 'Second and third players', 'cover the presser and shut the nearby horizontal and vertical passing lines'),
    (3, 'Defensive line', 'hold the line so no ball can go in behind'),
    (4, 'All', 'talk to each other and switch from attacking to defending straight away')
) AS v(so, role, job);

-- 49. pp.189-199
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 9: Training Sessions (1 Match Week) - Wednesday Practice 3: Winning the Ball and Playing Wide to the Wingers', 'Win it and go wide for a 4v2',
    'After a regain the first look is a quick pass out to a winger in space, without taking big risks. A centre back steps up into midfield, so the team arrives in the final third as wingers plus a midfielder against two defenders.',
    'Ball regained in our own or the middle third',
    'Quick break from a wide area with more attackers than defenders.',
    NULL, 189, 199, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who regains (e.g. CM)', 'plays out wide to the winger at once'),
    (2, 'Wingers', 'stay high and wide, ready to receive and run at the defence'),
    (3, 'Centre back', 'steps up into midfield to add a man'),
    (4, 'Attacking midfielder', 'runs forward into the final zone to make it 4v2')
) AS v(so, role, job);

-- 50. pp.191-194
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 9: Training Sessions (1 Match Week) - Tuesday Practice: Playing in behind the defensive line', 'Circulate through every channel, then go behind',
    'Build-up from the goalkeeper moves the ball across all five vertical channels to pull a compact back four apart. Only then does the team try to get in behind.',
    'Defending block compact in width and depth',
    'Stretch the block sideways until a gap opens for a timed run behind the line.',
    NULL, 191, 194, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'starts every build-up and picks the first pass'),
    (2, 'Centre backs/full backs', 'move the ball side to side quickly, short and long passes'),
    (3, 'Central midfielders', 'make triangles and set up switches'),
    (4, 'Forward/wingers', 'time runs behind the line as the ball changes channel')
) AS v(so, role, job);

-- 51. pp.203-204
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 9: Training Sessions (1 Match Week) - Thursday Practice 3: Building Up Play vs a Compact 4-4', 'Overload the full back out wide',
    'Against a compact middle block of two banks of four, the team circulates through all channels and then makes a 2v1 on one full back, with winger and full back, before crossing or shooting. A 3-4-1 version makes the 2v1 on one side and attacks the gap between the far centre back and wing back on the other.',
    'Opponent sits in a compact 4-4 middle block',
    'Get a free cross or a shot from a wide overload.',
    '4-4-2', 203, 204, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'overlaps or underlaps to make the 2v1 with the winger'),
    (2, 'Winger', 'pins the opponent''s full back and combines'),
    (3, 'Central midfielders', 'switch play so the overload comes on the weaker side'),
    (4, 'Whole team', 'after a loss, stay compact and press to force mistakes')
) AS v(so, role, job);

-- 52. pp.205-207
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 9: Training Sessions (1 Match Week) - Friday: Dropping Back and Stopping the Opposition Playing in Behind', 'Drop off and stop play in behind',
    'When a deep pass towards the wingers is coming, the defenders drop back. They mark goal-side with an open body so they can see ball, space and goal, and block or track runs. Covering for each other, the central channel comes first.',
    'Opponent midfielder ready to play a deep pass behind or wide',
    'Give no space behind the line, then attack quickly on the regain.',
    NULL, 205, 207, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'drop off, guard the central channel first, swap cover with each other'),
    (2, 'Full backs', 'track wingers'' runs and block crosses'),
    (3, 'Defender nearest the ball', 'goal-side body shape, eyes on ball and runner'),
    (4, 'Defence after regain', 'first pass forward or wide into the counter')
) AS v(so, role, job);

-- 53. pp.208-208
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 9: Training Sessions (1 Match Week) - Friday Practice 3: Dropping Off, Compactness and Counter Attack with Switch of Play', 'Counter with a diagonal switch',
    'After dropping off compactly, with midfielders helping the back four, the team wins the ball. The first pass is a long diagonal to the winger on the opposite side from where it was won.',
    'Ball regained in the low block',
    'Escape the ball-side pressure and attack the open weak side within seconds.',
    NULL, 208, 208, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who regains/CM', 'picks out the far-side winger at once with a deep diagonal'),
    (2, 'Far-side winger', 'stays wide on the weak side ready for the switch'),
    (3, 'Forward', 'runs on the defender''s blind side into the box'),
    (4, 'Midfielders', 'push up to support and finish from different lines')
) AS v(so, role, job);

-- 54. pp.212-212
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'set_piece', 'Chapter 9: Training Sessions (1 Match Week) - Saturday Practice 3: Defending Set Plays and Counter Attacking', 'Defend the corner, then break 4v2',
    'The team defends a corner with ten men and one forward left up. When the ball is cleared or won, the back four step up together to stay compact, and three players break forward with the forward.',
    'Opponent corner cleared or caught',
    'Finish a 4v2 counter within about five seconds while the back line keeps the team compact.',
    NULL, 212, 212, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'stays up during the corner as the outlet'),
    (2, 'Back four', 'push up together after the clearance'),
    (3, 'Winger (e.g. right winger)', 'dribbles into the attacking half'),
    (4, 'Attacking midfielder', 'overlaps to receive and make it 4v2'),
    (5, 'Player who wins the ball', 'safe first pass forward and deep if possible')
) AS v(so, role, job);

-- 55. pp.213-214
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 10: Training Sessions (2 Match Week) - Example Analysis of the Next 2 Opponents (3-5-2)', 'Exploit wing-back gaps after a regain',
    'On losing the ball the 3-5-2 keeps five players behind it (three centre backs and two midfielders), but its wing backs leave gaps nobody covers. On their own regain they switch fast to the weak-side wing back, and a forward drops between the lines.',
    'We win the ball against a 3-5-2',
    'Attack the spaces the wing backs leave before they recover.',
    '3-5-2', 213, 214, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who regains', 'plays quickly into the channel behind the wing back'),
    (2, 'Wingers', 'attack the space the wing back has left'),
    (3, 'Our centre backs and CMs (when they have the ball)', 'watch the forward who drops between the lines to receive'),
    (4, 'Our weak-side full back', 'guard against the quick switch to their far wing back')
) AS v(so, role, job);

-- 56. pp.213-220
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 10: Training Sessions (2 Match Week) - Example Analysis (3-5-2) and Monday Practices 1-2', 'Back four against a 3-5-2',
    'Against a 3-5-2 that plays direct, the back four move as one. They keep short gaps, shift across and step up or drop with the ball, swap markers, and take half-and-half positions. A centre back steps into the next zone to match numbers.',
    'Opponent 3-5-2 building up with numbers in midfield',
    'Win the ball without being outnumbered and break quickly on the regain.',
    '3-5-2', 213, 220, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'shift across to cover and move into the next zone to make 3v3'),
    (2, 'Full backs', 'squeeze in or track the wing backs, half-and-half positions'),
    (3, 'Back four', 'talk, switch markers, stay close together'),
    (4, 'Forwards', 'become outlets for a quick counter once the ball is won')
) AS v(so, role, job);

-- 57. pp.213-224
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 10: Training Sessions (2 Match Week) - Example Analysis of the Next 2 Opponents (3-5-2) and Tuesday practices', 'Build up against a 3-5-2 middle block',
    'The 3-5-2 defends in a middle block, leaves space behind its midfield line, and its left centre back and left wing back press badly together. The team builds through the thirds, a central midfielder drops in for a 4v2 at the back, and wide 2v1s go at the wing backs.',
    'Opponent 3-5-2 settled in a middle block',
    'Get the ball between their lines and into the gap between the left centre back and wing back, then cross.',
    '3-5-2', 213, 224, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'drop into the first line for a 4v2 against their two forwards'),
    (2, 'Full backs/wingers', 'make 2v1s out wide against the wing back'),
    (3, 'Attacking midfielder/forward', 'go into the space behind their midfield and the LCB-LWB gap'),
    (4, 'Wingers', 'cross from wide into the box')
) AS v(so, role, job);

-- 58. pp.213-225
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 10: Training Sessions (2 Match Week) - Example Analysis (3-5-2) and Tuesday Practice 3: Defending Crosses and Winning Second Balls', 'Stop long diagonals and crosses',
    'The 3-5-2 sends long diagonals behind the line and pushes its wing backs up to pin our full backs, opening the centre for two forwards who are strong in the air, who then attack crosses. The back line stays compact and shifts with the ball. The centre backs track the forwards'' runs or step up to play them offside, and the team wins the second balls.',
    'Ball wide with a wing back, or a long diagonal coming',
    'Deal with the cross and win the loose ball, then break.',
    '3-5-2', 213, 225, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'track the forwards'' runs or hold the offside line, attack the cross'),
    (2, 'Full backs', 'keep tight to the wing back and block the cross'),
    (3, 'Central midfielders', 'drop to cover the edge of the box for second balls'),
    (4, 'Whole team', 'switch to attack straight away when the ball is won')
) AS v(so, role, job);

-- 59. pp.213-233
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_attack', 'Chapter 10: Training Sessions (2 Match Week) - Example Analysis (4-4-2) and Friday objectives', 'Escape the 4-4-2''s counter-press',
    'The 4-4-2 presses hard right after losing the ball, and its wingers help their full backs make overloads out wide. On a regain the team switches play or plays forward straight away.',
    'Ball regained against an aggressive counter-pressing 4-4-2',
    'Get away from the first pressure before they can build a pressing zone around the ball.',
    '4-4-2', 213, 233, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who regains', 'first pass forward or a switch, no extra touches'),
    (2, 'Weak-side winger/full back', 'stay open for the switch'),
    (3, 'Forwards', 'show for the quick forward pass')
) AS v(so, role, job);

-- 60. pp.213-235
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'in_possession', 'Chapter 10: Training Sessions (2 Match Week) - Example Analysis (4-4-2) and Thursday/Saturday Practices', 'Beat a 4-4-2 high block',
    'The 4-4-2 presses high with two forwards, two wingers and one central midfielder. Its back four often fail to push up and freeze when the ball carrier is not pressed. The team builds up with a midfielder dropping to make 5v4, then full backs pushing on for 5v4 higher up. It switches to the weak side, and midfielders run past from the second line into the gap between the lines and in behind.',
    'Opponent 4-4-2 pressing high; their back four stationary or deep',
    'Play through or round the press and use third-man runs in behind the back four.',
    '4-4-2', 213, 235, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'drops into the first line to make 5v4 and switch play'),
    (2, 'Full backs', 'push on and overlap to cross'),
    (3, 'Attacking/central midfielders', 'make third-man runs from the second line in behind'),
    (4, 'Wingers', 'receive the switch on the weak side'),
    (5, 'Forwards', 'run into the box')
) AS v(so, role, job);

-- 61. pp.214-232
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'to_defend', 'Chapter 10: Training Sessions (2 Match Week) - Example Analysis (4-4-2) and Friday Practices 1-2: Defending Direct Play into 2 Forwards', 'Defend direct balls to two forwards',
    'When the 4-4-2 wins the ball it goes long and direct to both forwards. The team keeps more men than their two forwards back, the centre backs contest the duel, and midfielders track back to win the second ball.',
    'Opponent 4-4-2 regains and goes long to the front two',
    'Win the duel or the second ball, then counter with a forward or wide first pass.',
    '4-4-2', 214, 232, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'challenge the two forwards for the long ball, goal-side body shape'),
    (2, 'Central midfielders', 'drop and attack the second ball'),
    (3, 'Back four', 'move together and drop off behind the duel'),
    (4, 'Wingers', 'target for the first pass after the ball is won')
) AS v(so, role, job);

-- 62. pp.217-234
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 10: Training Sessions (2 Match Week) - Monday Practice 3 and Saturday objectives: Directing the Opponent''s Play to Force Mistakes', 'Show the build-up to the weak centre back',
    'The press directs the opponent''s build-up toward one known weak player, a right-footed left centre back who struggles on the ball. All players then press together to force the mistake. (In the book''s scouting table this belongs to the 4-4-2. The practice uses a 3-5-2.)',
    'Opponent goalkeeper or centre backs start the build-up',
    'Make the play predictable and win the ball off the weak passer.',
    NULL, 217, 234, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'curve their runs to shut the other centre back and push play to the weak one'),
    (2, 'Attacking midfielder', 'screens the pass into midfield'),
    (3, 'Ball-side winger', 'jumps the pass out from the weak centre back'),
    (4, 'Midfield and back line', 'step up together, switch markers, half-and-half positions')
) AS v(so, role, job);

-- 63. pp.235-237
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'tactical-periodization-a-proven-successful-training-model'), 'out_of_possession', 'Chapter 10: Training Sessions (2 Match Week) - Saturday Practices 2-3: Team Pressing Against the 4-4-2', 'Team press against a 4-4-2',
    'Against a 4-4-2 building from the back, the team presses together around the ball and shows the play outside. Players free to move across the halves make defensive overloads near the ball, so the carrier is pressed high with a numbers advantage.',
    'Opponent goalkeeper or centre back starts the build-up',
    'Win the ball high and counter at once.',
    '4-4-2', 235, 237, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward/attacking midfielder', 'press the centre back from inside so he plays outside'),
    (2, 'Ball-side winger', 'closes the full back once the ball goes wide'),
    (3, 'Central midfielders', 'step onto their midfielders around the ball zone'),
    (4, 'Back line', 'step up, switch markers, half-and-half positions'),
    (5, 'All', 'read the tactical cues for pressing and communicate starting spots')
) AS v(so, role, job);

COMMIT;
