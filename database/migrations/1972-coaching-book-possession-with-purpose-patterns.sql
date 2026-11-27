-- 1972 📚 Coaching book patterns: "Possession with Purpose to Maximise Performance" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Possession with Purpose to Maximise Performance',
    subtitle    = '50 Practices - Youth to Pro - Training Week - Football Periodization',
    author      = 'Adam Owen',
    team        = 'Football Periodization model (Rangers, Wales, Seattle Sounders, Lechia Gdańsk)',
    method_note = 'Possession games built on the author''s Football Periodization model, sorted by purpose: directional (progress to a target), transitional (the first actions after a turnover) and positional (spacing and structure, including rest defence). Each training day of the week (resistance with small-sided games in tight areas, speed endurance with large-sided games, reaction speed) gets its own possession practices. Patterns are the team behaviours the practices train (draw one side then switch, press and screen, counter-press, secure or penetrate on regain, combine through the centre forward), in our words; load theory and the weekly tables are left out.'
WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini');

-- 1. pp.25-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Directional Possession Practices with a Purpose', 'Purposeful directional possession toward an objective',
    'The team circulates the ball to reach a set objective (enter a zone, break a line, find an end player or the striker, reach a finishing area under control) instead of passing for its own sake.',
    'A forward option opens, a line is broken or a third-man option appears',
    'Progress when it is on and keep the ball to set up a better chance when it is not, so possession moves and unbalances the opponent.',
    NULL, 25, 26, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver between lines', 'scan early and receive on the half-turn facing forward'),
    (2, 'Third player', 'offer the third-man option beyond the pressure'),
    (3, 'Wide players', 'hold width and depth to stretch the block'),
    (4, 'Supporting players', 'time runs to help progression, not just to get on the ball')
) AS v(so, role, job);

-- 2. pp.26-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'to_defend', 'Directional / Positional Possession Practices with a Purpose', 'Rest-defence secured before committing forward',
    'While attacking, the team keeps enough players and a connected shape behind the ball so it can counter-press or recover the moment possession is lost.',
    'Team commits numbers into the attacking phase',
    'The team stays protected against the counter while it attacks.',
    NULL, 26, 28, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder', 'stay connected behind the ball as the counter-press screen'),
    (2, 'Centre backs', 'hold position to cover the opponent''s outlets'),
    (3, 'Units', 'keep short distances between lines so the counter-press is immediate')
) AS v(so, role, job);

-- 3. pp.27-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'to_attack', 'Transitional Possession Practices with a Purpose', 'First action after regain: secure or penetrate',
    'On winning the ball the first decision is either to protect it and connect a safe pass, or to go forward early while the opponent is disorganised. Teammates get into supporting angles behind, beside and beyond the ball quickly.',
    'Ball won',
    'Escape the counter-press or punish the disorganised opponent before it resets.',
    NULL, 27, 27, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'pick secure-and-connect or penetrate-early at once'),
    (2, 'Nearest teammates', 'arrive fast at angles behind and beside the ball'),
    (3, 'Forward teammate', 'offer depth beyond the ball for an early forward pass')
) AS v(so, role, job);

-- 4. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Positional Possession Practices with a Purpose', 'Positional spacing: width, depth, triangles, between lines',
    'Positional possession turns keeping the ball into team structure: players hold correct distances, form triangles and diamonds, and occupy different lines and zones so passing lanes stay open.',
    'Team in settled possession',
    'A stable passing network that pulls opponents out of position while the ball moves fast between connected units.',
    NULL, 28, 28, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players', 'keep width to stretch the line'),
    (2, 'Forward line', 'give depth'),
    (3, 'Midfielders', 'play on different lines and in the gaps, not around the outside'),
    (4, 'All players', 'judge when to leave a space and when to hold it, and form triangles and diamonds for short support')
) AS v(so, role, job);

-- 5. pp.33-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Resistance Day: Small Sided Possession', 'Escape immediate pressure in tight spaces',
    'In crowded, high-density areas the player on the ball shields it, then changes direction or uses a short combination to beat the press, while teammates keep moving to stay available.',
    'Opponent presses tightly as the ball arrives',
    'Keep possession and stay composed under time and contact pressure.',
    NULL, 33, 37, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'protect the ball with body shape and turn away from pressure'),
    (2, 'Close supports', 'make short sharp movements to offer an escape pass')
) AS v(so, role, job);

-- 6. pp.39-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Resistance Training Day: Directional Possession Practices', 'Circulate a set number of passes, then progress into the next zone',
    'The team keeps a quick, low-touch circulation until it has made enough passes or drawn the press. Then a player moves into the next zone to receive, and the rest of the team follows to rebuild the overload there.',
    'Set passes completed or the press has been drawn',
    'Move the ball and the overload into the next area under control, before the press can close it.',
    NULL, 39, 50, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advanced receiver', 'move early into the next zone to give the forward passing lane'),
    (2, 'Passer', 'play through or past the pressers into the next zone'),
    (3, 'Remaining players', 'move up quickly to support in the new zone with correct body shape')
) AS v(so, role, job);

-- 7. pp.40-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Resistance Training Day: Directional Possession Practices', 'Play through the central link player first',
    'The team uses a central joker or link player to make a central overload. The ball goes through the middle player before it is moved to an outside player, and a one-two with the outside player is the goal.',
    'Central link player free between the opponents',
    'Draw the opponent inwards and then exploit the space outside with quick one-touch combinations.',
    NULL, 40, 41, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central link player (joker)', 'find space in the middle, connect and set the rhythm'),
    (2, 'Outside players', 'receive after the central pass and return a one-two'),
    (3, 'Inside players', 'give quick support angles and stay aware of the centre')
) AS v(so, role, job);

-- 8. pp.42-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Resistance Training Day: Directional Possession Practices', 'Overload one side, switch via end or target player',
    'The team uses end or target players to make an overload that pulls the press across, then switches play quickly to the other end or side. The receiver may not pass straight back, so a third player has to support elsewhere.',
    'Pressure committed to one side',
    'Move the ball into the space the opponent has left before it can shift across.',
    NULL, 42, 43, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'End or target player', 'one-touch the switch or set a one-two to change direction'),
    (2, 'Third player', 'move away from the ball for the next pass, never offer a straight return'),
    (3, 'Inside players', 'make triangles to play through or around the defenders')
) AS v(so, role, job);

-- 9. pp.44-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Resistance Training Day: Directional / Transitional Possession Practices', 'Pass-and-swap rotation with outside player',
    'When an inside player passes out to an outside or target player, the passer rotates straight out and takes that player''s spot while the receiver comes inside, often dribbling in.',
    'Inside-to-outside pass',
    'Keep a high tempo and keep the defenders confused about who to mark, while the structure stays intact.',
    NULL, 44, 49, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'rotate out at once into the outside player''s position'),
    (2, 'Outside or target player', 'receive and carry or dribble inside to become an inside player'),
    (3, 'Other inside players', 'scan and adjust support angles to the new rotation')
) AS v(so, role, job);

-- 10. pp.45-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'out_of_possession', 'Resistance Training Day: Directional Possession Practices', 'Two press the ball, two screen the gap',
    'Out of possession, two defenders press the ball in the active zone while two others sit in the middle zone to cut off the forward pass into the next area.',
    'Opponent circulating in its zone',
    'Win the ball or intercept the progressing pass between zones.',
    NULL, 45, 45, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two pressers', 'close down the ball and its nearest support'),
    (2, 'Two screening players', 'sit in the gap between zones and read and intercept the forward pass')
) AS v(so, role, job);

-- 11. pp.46-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'to_defend', 'Resistance Training Day: Transitional Possession Practices', 'Immediate counter-press after losing the ball',
    'The moment the ball is lost, the nearest players press the ball while the others block the forward passing options, aiming to win it back straight away before the opponent can score or escape.',
    'Ball lost',
    'Regain quickly near where the ball was lost and deny the counter.',
    NULL, 46, 53, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'press the ball at once'),
    (2, 'Second and third nearest', 'close the nearby passing lanes and squeeze'),
    (3, 'Far players', 'block the forward options and the routes to goal')
) AS v(so, role, job);

-- 12. pp.46-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'to_attack', 'Resistance Training Day: Directional / Transitional Possession Practices', 'Quick counter to goal after regain',
    'Defenders who win the ball attack straight away by dribbling or passing at the goal, before the team that lost it can reorganise.',
    'Ball won while the opponent is spread for possession',
    'Score in the few seconds before the opponent recovers.',
    NULL, 46, 55, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'dribble or pass forward toward goal at once'),
    (2, 'Nearest teammate', 'support for a quick combination or the finish')
) AS v(so, role, job);

-- 13. pp.48-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Resistance Training Day: Transitional Possession Practices', 'Use the spare man, open pitch wide and deep',
    'With an extra or neutral player the team builds numerical superiority around the ball, supports the carrier from several sides, and keeps width and depth so the passing lines stay open.',
    'Team has a spare player in possession',
    'Control the tempo with quick combinations and keep a spread shape that suits counter-pressing.',
    NULL, 48, 53, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Spare player (joker)', 'join on the ball side to make the overload'),
    (2, 'Wide players', 'move to give width'),
    (3, 'Far players', 'give depth behind and beyond the ball')
) AS v(so, role, job);

-- 14. pp.51-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'to_attack', 'Resistance Training Day: Transitional Possession Practices', 'Regain then escape to the open area',
    'After winning the ball, the team does not keep it in the crowded zone. It connects with outside supporters or plays straight into the far, open area or half, where teammates move to receive.',
    'Ball won in a congested zone',
    'Get away from the counter-press and keep the ball where there is space.',
    NULL, 51, 54, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'play the first pass out of the pressure'),
    (2, 'Outside or wide supporters', 'be ready as the immediate outlet'),
    (3, 'Far-side players', 'move into the open half to receive the switch')
) AS v(so, role, job);

-- 15. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'to_defend', 'Resistance Training Day: Transitional Possession Practices', 'Protect the goals first, then press',
    'When an opponent wins the ball near goals it could score in, the team that lost it first gets between the ball and the goals, then presses to win it back.',
    'Ball lost with the opponent close to a scoring target',
    'Stop the quick goal, then regain the ball.',
    NULL, 52, 52, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players nearest the goals', 'drop to cover the goal and the shooting lanes'),
    (2, 'Nearest player to the ball', 'delay and press once the goal is covered')
) AS v(so, role, job);

-- 16. pp.55-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Resistance Training Day: Transitional Possession Practices', 'Circulate, feed the centre forward, run beyond',
    'The midfield keeps the ball against pressure for a set number of passes, then plays into the centre forward, who links play while others make forward runs beyond him to finish.',
    'Possession secured and the passing lane to the centre forward open',
    'Turn control into a chance through link play with the striker.',
    NULL, 55, 55, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'show for the pass, hold or lay off to set up runners'),
    (2, 'Midfielders', 'support around the ball, then break beyond the forward'),
    (3, 'Runner beyond', 'attack the space behind to finish')
) AS v(so, role, job);

-- 17. pp.63-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Speed Endurance Training Day: Directional Possession Practices', 'Secure one zone, drop-in link, then target',
    'Team keeps the ball 3v3+1 in one zone before moving it to the far zone; one player drops into the free zone between to link, then the team plays into the end target and gets a return pass.',
    'Possession secured in the first zone',
    'Progress the ball zone to zone and into the striker with a combination.',
    NULL, 63, 63, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Linking midfielder', 'Drop into the free gap to receive and transfer'),
    (2, 'Far-zone players', 'Create angles to receive the transfer'),
    (3, 'Target forward', 'Receive, lay off, set the next pass'),
    (4, 'Jokers', 'Side with the team in possession for the overload')
) AS v(so, role, job);

-- 18. pp.64-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Speed Endurance Training Day: Directional Possession Practices', 'Wide receiver dribbles in, passer swaps out',
    'When a wide/outside player receives, he carries the ball inside and the player who passed to him takes over his outside position, rotating roles to open fresh lanes while the team switches from side to side.',
    'Pass into a wide or outside player',
    'Rotations disorganise markers and create new passing options for the switch.',
    NULL, 64, 65, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player receiving', 'Dribble inside into central space'),
    (2, 'Passer', 'Run outside to occupy the vacated wide spot'),
    (3, 'Central players', 'Re-angle support for the new carrier'),
    (4, 'Far-side players', 'Hold width for the switch end to end')
) AS v(so, role, job);

-- 19. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Speed Endurance Training Day: Directional Possession Practices', 'Keep team shape, pick the moment forward',
    'In full team shape (e.g. 4-3-3) the team circulates to create space, angles and lanes, and only passes forward through a gap between opponents when a teammate on the far side is free.',
    'A line-breaking lane opens with a free receiver beyond',
    'Patient circulation that breaks lines at the right moment instead of forcing.',
    NULL, 66, 66, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Circulate wide to stretch the block'),
    (2, 'Midfield three', 'Find angles between opponents, offer to receive'),
    (3, 'Front three', 'Stay on the far side of the line ready for the through pass')
) AS v(so, role, job);

-- 20. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Speed Endurance Training Day: Directional Possession Practices', 'Third-man run into the wide box',
    'After the switch, the final ball goes to a third player arriving into a wide scoring area; receivers must arrive on the move, not wait inside the zone.',
    'Switch played, wide space open',
    'Receive in wide attacking areas on the run, unmarked.',
    NULL, 67, 67, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First receiver', 'Bounce the ball on quickly'),
    (2, 'Third-man runner', 'Start late, arrive in the wide box as the pass is played'),
    (3, 'Supporting midfielder', 'Provide the set pass for the runner')
) AS v(so, role, job);

-- 21. pp.67-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Speed Endurance Training Day: Directional / Positional Possession Practices', 'Draw one side, switch fast to wide',
    'The team keeps 8-10 passes on one side to pull the opponent across, then switches quickly to the far flank, where wide players hold high and wide positions ready to receive; neutrals/target players can be used as the switch link.',
    'Opponents shifted and compacted to ball side',
    'Attack the weak side before the block can shift back.',
    NULL, 67, 78, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side players', 'Keep the ball long enough to draw the block'),
    (2, 'Far-side winger/full back', 'Stay high and wide, out of the block''s reach'),
    (3, 'Central/link players', 'Act as the bounce for the switch'),
    (4, 'Opposite-side runner', 'Time the run onto the switched ball')
) AS v(so, role, job);

-- 22. pp.67-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'out_of_possession', 'Speed Endurance / Reaction Speed: Directional and Positional Practices', 'Shift across together, deny the switch',
    'The defending block slides across as a unit to the ball side, stays compact, protects the middle and covers both wide areas; when a switch does get through, nearest players sprint across to recreate pressure on the new side.',
    'Ball moves to one flank / a switch is played',
    'Keep the switch from creating free wide players.',
    NULL, 67, 94, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole defending unit', 'Slide together toward ball, keep short distances'),
    (2, 'Central midfielders', 'Screen the middle and the switching lanes'),
    (3, 'Far-side defender', 'Tuck in but stay able to reach the wide area'),
    (4, 'Two nearest pressers', 'Cross over to press the new side after a switch')
) AS v(so, role, job);

-- 23. pp.68-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'out_of_possession', 'Speed Endurance Training Day: Directional Possession Practices', 'Organised team press stops forward play',
    'Against a team building up, the whole side presses together on agreed triggers, stays compact, protects central spaces and blocks forward passes into the target.',
    'Pressing triggers (e.g. poor touch, backward or square pass)',
    'Prevent progression and win the ball centrally.',
    NULL, 68, 68, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front line', 'Press on the trigger, curve runs to cut lanes'),
    (2, 'Midfield line', 'Step up behind, close central lanes'),
    (3, 'Back line', 'Push up to keep the team compact')
) AS v(so, role, job);

-- 24. pp.68-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Speed Endurance / Reaction Speed: Directional and Positional Practices', 'Build up and play into the goalkeeper',
    'From a structured shape (e.g. 4-2-3) the team builds forward under organised pressure and scores by finding the far goalkeeper/target with an aerial ball at the right moment; the keeper restarts by throwing to the other end.',
    'Front player or space behind becomes free after build-up',
    'Controlled progression into the final third rather than early long balls.',
    NULL, 68, 80, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Start the build-up, split wide'),
    (2, 'Holding midfielders', 'Offer central angles under pressure'),
    (3, 'Advanced players', 'Hold positions that stretch the press'),
    (4, 'Passer of final ball', 'Pick the moment to play the long target pass')
) AS v(so, role, job);

-- 25. pp.69-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Speed Endurance / Reaction Speed: Directional and Positional Practices', 'Combine through the centre forward',
    'After securing the ball, the team plays into the centre forward (or a forward in an end zone), who links play; supporting players can only enter the final area after the pass to him and then run beyond to receive and finish.',
    'Pass target reached, forward free to receive',
    'Use the striker as a wall to release runners from deep.',
    NULL, 69, 102, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Show to receive, lay off with two touches'),
    (2, 'Supporting midfielders', 'Make third-man and forward runs beyond the forward'),
    (3, 'Wide/attacking players', 'Arrive in finishing positions after the link')
) AS v(so, role, job);

-- 26. pp.71-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'to_defend', 'Speed Endurance / Reaction Speed: Transitional Possession Practices', 'Ball lost: instant switch to defending',
    'The moment a team gives the ball away it becomes the defending team at once and presses the new holders, while the others regroup to keep the ball.',
    'Possession lost',
    'No switch-off after losing the ball; pressure applied immediately.',
    NULL, 71, 73, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost it', 'Press the ball straight away'),
    (2, 'Nearest teammates', 'Close the passing options around the ball'),
    (3, 'Rest of team', 'Get compact behind the press')
) AS v(so, role, job);

-- 27. pp.72-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'to_attack', 'Speed Endurance / Reaction Speed: Transitional Possession Practices', 'Regain, release the free outlet',
    'When the ball is won, it is played quickly to a teammate left in space away from the regain (spare player in the far zone) and the team floods across to support.',
    'Ball won in a crowded area',
    'Escape pressure and start the counter with one pass.',
    NULL, 72, 72, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Find the free outlet first'),
    (2, 'Outlet player', 'Stay in the far space, receive and hold/progress'),
    (3, 'Others', 'Sprint across to support the outlet')
) AS v(so, role, job);

-- 28. pp.74-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'out_of_possession', 'Speed Endurance Training Day: Transitional Possession Practices', 'Stay compact centrally vs width',
    'When the opponent uses the full width, the defending team stays inside a compact central block and presses within it rather than chasing wide.',
    'Opponent spreads wide',
    'Protect the centre and win the ball there.',
    NULL, 74, 74, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All defenders', 'Stay narrow, short distances'),
    (2, 'Nearest player to ball', 'Press when ball enters the central area')
) AS v(so, role, job);

-- 29. pp.74-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'to_attack', 'Speed Endurance / Reaction Speed: Transitional and Positional Practices', 'After regain, spread wide to secure',
    'Once the ball is won in a tight central area, players immediately expand into the wider space and use both the inner and outer areas to keep it; the side that lost it collapses into the centre and presses.',
    'Regain in a compact central zone',
    'Make the pitch big quickly to secure possession after the regain.',
    NULL, 74, 105, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Secure first touch, play to an expanding teammate'),
    (2, 'Three nearest players', 'Spread out into the outer space'),
    (3, 'Remaining players', 'Give close central support')
) AS v(so, role, job);

-- 30. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Speed Endurance Training Day: Positional Possession Practices', 'Make it big, attack the open gate',
    'In balanced positions the team moves the ball to shift opponents, recognises early which of several targets is open and drives into that space with the ball under control.',
    'A target area left open by the shift',
    'Turn possession into penetration where the opponent is not.',
    NULL, 76, 76, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players', 'Keep the pitch big'),
    (2, 'Ball carrier', 'Recognise the open gate and dribble through'),
    (3, 'Each player', 'Hold his role within the team structure')
) AS v(so, role, job);

-- 31. pp.79-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Speed Endurance / Reaction Speed: Positional and Directional Practices', 'Pass and follow to overload next line',
    'The team plays into the next zone and the passer follows his pass, creating a numerical overload (e.g. 4v2, 5v4, 3v2) line by line; from the last zone it combines, finishes with a third-man run or plays long/back to restart.',
    'Pass into the next zone',
    'Progress through lines with an extra man in every line.',
    NULL, 79, 95, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Follow the pass into the next zone'),
    (2, 'Receiver', 'Receive on the half turn, combine'),
    (3, 'Third man', 'Run beyond for the return/finish'),
    (4, 'Goalkeeper', 'Start with a pass into the first zone')
) AS v(so, role, job);

-- 32. pp.81-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Speed Endurance Training Day: Positional Possession Practices', 'Overload and switch between zones',
    'The team builds a 3v2 overload with a target in one zone, then moves the ball to another zone where a defender joins and they must quickly create a new overload around the target player.',
    'Overload established, ball moves zones',
    'Shift numbers with the ball and keep an advantage wherever it goes.',
    NULL, 81, 81, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side trio', 'Create the 3v2 and play to target'),
    (2, 'Target player', 'Receive and connect zones'),
    (3, 'Players in next zone', 'Prepare to create the new overload')
) AS v(so, role, job);

-- 33. pp.82-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Speed Endurance Training Day: Positional Possession Practices', 'Build from keeper as pressure escalates',
    'The team starts with a big overload (5+GK v 2) in its half and keeps the ball as extra pressers join to make it even; after the pass target, it plays into the other half and loses the ball, so it then presses immediately in the same numbers.',
    'Extra pressers enter / pass target reached',
    'Keep structure and play through lines as pressure grows, then press straight away.',
    NULL, 82, 82, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Provide the free option in build-up'),
    (2, 'Back line', 'Spread to keep the overload useful'),
    (3, 'Wingers', 'Join to press immediately after the switch'),
    (4, 'Central players', 'Enter from midfield to press the new build-up')
) AS v(so, role, job);

-- 34. pp.83-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Speed Endurance / Reaction Speed: Positional Practices', 'Play through the central midfield unit',
    'The ball is progressed through central midfielders (link players in the circle, or a 3v3 midfield box in 4-3-3) before attacking; teams show patience, strong support angles and passing rhythm, and score by timed runs into wide goal zones.',
    'Ball with the centre backs / wide players',
    'Control the game through the middle before breaking forward.',
    '4-3-3', 83, 84, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Start play and find the midfield'),
    (2, 'Midfield three', 'Stay inside the central box, angle for the bounce'),
    (3, 'Wide forwards', 'Time runs into the wide goal zones'),
    (4, 'Centre forward', 'Target for central finishes')
) AS v(so, role, job);

-- 35. pp.86-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Reaction Speed Training Day: Medium Possession Practices', 'Read the trigger: press, switch, penetrate, secure',
    'Under constant pressure in medium spaces, players scan continuously and classify each picture as a moment to press, switch, play forward or keep the ball safe.',
    'Picture changes (pressure arrives, far side opens, line breaks, numbers drop)',
    'Faster, correct decisions as phases change without extra running.',
    NULL, 86, 90, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All outfield players', 'Scan before receiving, name the trigger early'),
    (2, 'Ball carrier', 'Penetrate if forward lane open, switch if ball side locked, secure if outnumbered'),
    (3, 'Nearest teammates', 'Adjust support to the chosen action')
) AS v(so, role, job);

-- 36. pp.92-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Reaction Speed Training Day: Directional Possession Practices', 'Goalkeeper as the extra build-up link',
    'The team uses its goalkeeper with feet as a link player to play forward and then back, receiving on the half turn around blockers to keep forward passing options.',
    'Pressure on outfield players',
    'Use the keeper to beat the first line and keep possession.',
    NULL, 92, 92, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Offer a passing angle and play forward'),
    (2, 'Midfielders', 'Receive on half turn after the keeper''s pass'),
    (3, 'Forwards', 'Stay available for the line-breaking ball')
) AS v(so, role, job);

-- 37. pp.97-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'to_defend', 'Reaction Speed Training Day: Transitional Possession Practices', 'Counter-press, win it back within five passes',
    'After losing the ball the team counter-presses to win it back before the opponent strings five passes, with intense pressure and closure of central passing lanes.',
    'Possession lost',
    'Regain quickly before the opponent settles.',
    NULL, 97, 98, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'Press the ball carrier immediately'),
    (2, 'Second presser', 'Cut the easiest pass and trap'),
    (3, 'Central players', 'Close central lanes to force play wide')
) AS v(so, role, job);

-- 38. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Reaction Speed Training Day: Transitional Possession Practices', 'Inside-outside one-twos',
    'Inside players combine quickly with outside support players using one-twos to break pressure and keep the ball.',
    'Pressure on the ball carrier',
    'Beat the presser with a fast wall pass.',
    NULL, 99, 99, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Play into the wall and spin off'),
    (2, 'Outside/wall player', 'Return first time into the run')
) AS v(so, role, job);

-- 39. pp.100-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Reaction Speed Training Day: Transitional / Positional Practices', 'Zonal structure plus floaters overload',
    'Players hold a fixed structure (two per zone) and stay connected while floating jokers move between zones to create the overload and carry the switch end to end.',
    'Opponents leave zones to press',
    'Keep possession through structure rather than everyone chasing the ball.',
    NULL, 100, 106, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Zone players', 'Hold their zone and positional discipline'),
    (2, 'Floating midfielders/jokers', 'Move to the ball zone to create 3v2 or 5v3'),
    (3, 'End targets', 'Receive the switch from one end to the other')
) AS v(so, role, job);

-- 40. pp.100-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'to_attack', 'Reaction Speed Training Day: Transitional / Positional Practices', 'Win it and score fast',
    'On winning the ball the team attacks the goal at once, scoring within three passes; the side that lost it must react immediately to stop the quick attack.',
    'Ball won',
    'Punish the opponent before they reorganise.',
    NULL, 100, 107, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Play forward immediately'),
    (2, 'Nearest attackers', 'Run to goal for a 1-3 pass finish'),
    (3, 'Team that lost it', 'Recover goal side at once')
) AS v(so, role, job);

-- 41. pp.102-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'out_of_possession', 'Reaction Speed Training Day: Positional Possession Practices', 'Compact lines plus recovery run',
    'In two compact lines the defending team screens central lanes to stop passes into the forwards; when the ball does break the lines, one defender tracks back to pressure and protect the goals.',
    'Ball played past the midfield line',
    'Deny line-breaking passes and recover goal side when broken.',
    NULL, 102, 102, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front line', 'Screen central passing lanes'),
    (2, 'Back line', 'Stay compact, stop the pass into the forward'),
    (3, 'Recovering defender', 'Sprint back to pressure the ball')
) AS v(so, role, job);

-- 42. pp.103-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Reaction Speed Training Day: Positional Possession Practices', 'Central rotations keep the midfield count',
    'In a central 3v3 the possession team links play through the middle; whenever one midfielder rotates out, another must move in at once so the central numbers and balance stay the same.',
    'A central player leaves the middle',
    'Rotate freely without leaving the centre short.',
    NULL, 103, 103, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder leaving', 'Rotate out to the edge'),
    (2, 'Outside player', 'Fill the central slot immediately'),
    (3, 'Other central players', 'Rebalance angles and lanes')
) AS v(so, role, job);

-- 43. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'possession-with-purpose-to-maximise-performance-50-practices-youth-to-pro-traini'), 'in_possession', 'Reaction Speed Training Day: Positional Possession Practices', 'Patient overload before attacking',
    'With a large numerical advantage, the team keeps the ball with patience and support until a pass count is reached, then attacks any goal, aware that a lost ball will be punished by a fast counter.',
    'Pass count / opening reached',
    'Use overloads calmly and avoid careless losses.',
    NULL, 107, 107, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Possession team', 'Wide support, safe circulation'),
    (2, 'Rest-defence players', 'Stay ready to stop the instant counter')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1972-coaching-book-possession-with-purpose-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
