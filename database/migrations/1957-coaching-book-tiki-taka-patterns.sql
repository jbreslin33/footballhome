-- 1957 📚 Coaching book patterns: Jed Davies, "Coaching the Tiki Taka Style
-- of Play" (SoccerTutor).  Every page (1-225) read.  Like Shadows of Bielsa
-- (mig 1955) this is a theory + practices book, not a match log, so a
-- "pattern" is each on-pitch team behaviour it describes (rondo pressing
-- rules, third-man runs, the six-second press, blocks, roles, solutions to
-- recurring problems, the Wigan case study), written up in OUR OWN WORDS
-- with app page numbers as the citation and who does what.  Of the 50
-- practices only those teaching a distinct match behaviour are kept; drill
-- set-ups, history and development theory are left out.  Owner's personal
-- library.  (James 11/26 'continue with the reading of the coach viewer books')
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Coaching the Tiki Taka Style of Play',
    author      = 'Jed Davies',
    team        = 'Barcelona, Spain, Swansea, Liverpool, Wigan',
    season      = '2008-14',
    method_note = 'Not a match log: a possession-football book in four parts — development theory, 50 practices the author watched first hand over about two years at Barcelona, Liverpool, Swansea, Wigan, Villarreal and others, the history of control-through-possession (Michels, Lobanovskyi, Cruyff, Van Gaal, Rijkaard, Guardiola), and tactical theory: positional system, transition, the six-second press, ball circulation, blocks, player roles in a 4-3-3 that becomes 3-4-3, five recurring tactical problems and a Wigan case study. Patterns here are the on-pitch behaviours it describes, in our words; drill set-ups are left out.'
WHERE slug = 'coaching-the-tiki-taka-style-of-play';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play');

-- 1. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', '2. Lack of Central Philosophy: A Critical Analysis of the Long Ball Approach', 'Narrow block that pushes play wide',
    'Without the ball the team stays narrow and compact so the opponent can only progress through the wide areas, where crosses rarely turn into goals.',
    'Opponent in possession building an attack',
    'Concede crosses rather than central chances and win the ball back behind the opponent''s winger and attacking players.',
    NULL, 22, 22, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders and centre backs', 'Stay narrow and close the central lanes'),
    (2, 'Full backs', 'Let the winger have the outside, defend the cross'),
    (3, 'Whole block', 'Steer the ball to the touchline, then win it back')
) AS v(so, role, job);

-- 2. pp.56-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Practice 1. FC Barcelona: The Rondo', 'First, second and third line passes',
    'Passes are ranked by what they get past: a first line pass goes to a near teammate and breaks no one, a second line pass goes round the pressers to the far side, and a third line pass splits two pressers through the middle.',
    'Gap opens between two pressing players',
    'Pick the third line pass whenever it is on (as a centre back fitting a ball into a striker who has dropped off his marker), the second line pass next, and avoid strings of first line passes.',
    NULL, 56, 58, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back on the ball', 'Look first for the split pass between the two pressers'),
    (2, 'Striker dropping off', 'Come off his marker to receive the line-breaking pass to feet'),
    (3, 'Far-side supporters', 'Give an outlet for the pass round the press'),
    (4, 'Near supporters', 'Short safety option only, never two in a row')
) AS v(so, role, job);

-- 3. pp.56-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Practice 1. FC Barcelona: The Rondo', 'Half-touch rebound pass (mig toc)',
    'When the ball is played in firmly, the receiver redirects it first time with half a touch instead of controlling it, so the ball moves faster than the press can shift.',
    'Hard pass arriving with a supporter already free',
    'Speed up the circulation and catch the pressers moving the wrong way.',
    NULL, 56, 58, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Play the ball in firm'),
    (2, 'Receiver', 'Glance first, then redirect it in one touch'),
    (3, 'Next supporter', 'Already in place for the redirected pass')
) AS v(so, role, job);

-- 4. pp.57-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', 'Practice 1. FC Barcelona: The Rondo', 'Teasing the ball player',
    'Two pressers stand close enough to cut out the short pass and angle their bodies to shut the pass round them, while seeming to leave the gap between them open. Because of their angles either one can step in on that split pass.',
    'Opponent receives with options around him',
    'Make the opponent''s play predictable, then pounce on the first or third line pass he is lured into.',
    NULL, 57, 58, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First presser', 'Close the ball and screen the pass round him with his body'),
    (2, 'Second presser', 'Show the gap between the pair as bait, ready to step across'),
    (3, 'Both pressers', 'Pounce together on the short or split pass')
) AS v(so, role, job);

-- 5. pp.57-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_defend', 'Practice 1. FC Barcelona: The Rondo', 'Losers become pressers immediately',
    'When the ball is lost, the player who gave it away and the teammate who passed to him switch straight into pressing at full speed, with no pause or walking.',
    'Ball given away',
    'Practise switching from attack to defence right away, so the team presses at once and the opponent gets no free time on the ball.',
    NULL, 57, 58, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost the ball', 'Turn and press at once'),
    (2, 'Player who passed to him', 'Join the press straight away'),
    (3, 'Rest of the team', 'Keep the shape and stay switched on, never stop')
) AS v(so, role, job);

-- 6. pp.60-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Practices 3-4. FC Barcelona: Adjacent Passing Square / Laureano Ruiz Simplified Triangulation', 'Side support and rotating triangles',
    'The ball carrier always has a supporter on each side, level with the ball, in the corner nearest to it. The three players keep a triangle that can turn in any direction as the ball moves. To change direction, the ball is laid back to the player who just passed it.',
    'Teammate receives under pressure',
    'The man on the ball always has two short angles and a way out, and receives across his body to see all options.',
    NULL, 60, 61, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Receive across the body, two touches, open to both sides'),
    (2, 'Near-side supporter', 'Move level with the ball, in the corner closest to it'),
    (3, 'Opposite supporter', 'Mirror on the other side to complete the triangle'),
    (4, 'Previous passer', 'Stay for the lay-back that switches direction')
) AS v(so, role, job);

-- 7. pp.62-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Practice 5. AFC Ajax: 4 v 4 (+2) End to End Possession Game', 'Make the pitch as big as possible',
    'In possession the team spreads to use the full length and width of the space, using the end players as rebound outlets that play quickly back to the side that passed to them.',
    'Team wins or holds the ball',
    'Stretch the opponent so passing lanes and time on the ball open up.',
    NULL, 62, 62, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players at the ends (kaasters)', 'Hold the length, return the ball in one or two touches'),
    (2, 'Outfield players', 'Spread wide and deep, create space for each other'),
    (3, 'Ball carrier', 'Use the far outlet to escape the press')
) AS v(so, role, job);

-- 8. pp.62-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', 'Practice 5. AFC Ajax: 4 v 4 (+2) End to End Possession Game', 'Pressing triggers: bad touch, heavy pass',
    'Players learn set cues for when to press. They step in when the man on the ball shields, takes a poor first touch or rushes, or when the pass to him is too heavy, which also tells his support to drop behind him.',
    'Poor first touch, heavy pass, rushed play, ball carrier shielding',
    'Press at the moment the opponent is least in control and win the ball back.',
    NULL, 62, 62, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'Spot the cue and jump onto the ball'),
    (2, 'Covering teammates', 'Shut the support behind once the heavy pass is seen')
) AS v(so, role, job);

-- 9. pp.64-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 7: FC Barcelona Shielding the Ball and Waiting for Support', 'Shield and wait for support',
    'A receiver under pressure with no pass on keeps the ball with his body instead of forcing it, until teammates arrive close.',
    'Receiver pressed, no free option',
    'Keep possession until a support triangle forms around the ball.',
    NULL, 64, 64, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'Shield ball, body between man and ball, wait'),
    (2, 'Nearest teammates', 'Arrive into the area to offer short angles')
) AS v(so, role, job);

-- 10. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 9: FC Barcelona 5 v 4 Breaking Out of the Middle Third', 'Circulate, then break out with overload',
    'The team keeps the ball in midfield with several passes, then plays into a forward and extra players join to outnumber the back line.',
    'Pass count done / forward free',
    'Link patient circulation to a numerical overload attack.',
    NULL, 66, 66, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield circulators', 'Move the ball to drag the block'),
    (2, 'Striker', 'Receive and set or turn'),
    (3, 'Joining midfielders', 'Break forward to overload defence')
) AS v(so, role, job);

-- 11. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 10: Liverpool FC Position Specific 8 v 8 (+1) Possession Exercise', 'Positional build-up in Rodgers 4-3-2-1',
    'Players hold their formation stations on the outside (centre backs deep, full backs wide) while a free central playmaker links them; ball goes out and back to the centre backs to control the game.',
    'Settled possession from centre back',
    'Control possession non-directionally using fixed positional width and depth.',
    NULL, 67, 67, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Start and recycle circulation'),
    (2, 'Full backs', 'Stay wide on the touchline as outlets'),
    (3, 'Central playmaker', 'Free man, linking both sides')
) AS v(so, role, job);

-- 12. pp.69-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 12: Villarreal CF Match Realistic Overloads in a 3 Zone Small Sided Game', 'Overloads created by the system',
    'Shape is chosen so each third has a spare man (e.g. 2 + keeper vs 1 striker, 3 mids vs 2, as in a back-three side or 3-5-2 with a dropping forward); the ball carrier always has support beside, behind and ahead.',
    'Build-up begins',
    'Win numbers zone by zone, then unlock the last line via a midfielder''s one-two with the striker.',
    NULL, 69, 69, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two defenders + GK', 'Build 3v1 vs lone striker'),
    (2, 'Central midfield three', 'Beat two opponents with the spare man'),
    (3, 'Midfielder', 'One-two with striker, then run into final third'),
    (4, 'All', 'Scan every few seconds before receiving')
) AS v(so, role, job);

-- 13. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', 'Part 2, Practice 13: Liverpool FC Playing through the Lines in a 4 Zone Passing Exercise', 'Midfield trio blocks passing lanes',
    'The three central midfielders slide together as a unit to shadow and close lanes through their line while the opponent circulates.',
    'Opponent shifts ball across',
    'Stop passes being played through the midfield line.',
    NULL, 70, 70, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield trio', 'Shift across together, close gaps'),
    (2, 'Nearest midfielder', 'Step onto lane of the ball')
) AS v(so, role, job);

-- 14. pp.71-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 14: FC Barcelona Playing through the Thirds with 1 v 1 Duels', 'Move them first, then attack the gap',
    'The team passes patiently side to side to pull the opponent out of shape, and only dribbles at a defender into a channel once he is out of position.',
    'Defender out of position after circulation',
    'Create a favourable 1v1 by first disorganising the block.',
    NULL, 71, 71, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle player', 'Playmaker, keeps circulation going'),
    (2, 'Wide receiver', 'Receive open, dribble into channel when gap opens')
) AS v(so, role, job);

-- 15. pp.72-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 15 / 18: AFC Ajax / FC Barcelona (make the pitch big)', 'Big pitch with ball, small without',
    'With the ball the team spreads as wide and deep as possible (using unopposed wide spaces in its own half as pressure relief); without it the same players squeeze the space small.',
    'Possession won / lost',
    'Stretch the opponent in possession and compress space when defending.',
    NULL, 72, 75, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'Take wide positions in deep build-up'),
    (2, 'Wide players', 'Hold touchline width'),
    (3, 'All', 'Compact centrally when ball is lost')
) AS v(so, role, job);

-- 16. pp.74-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 17: AFC Ajax Passing in Behind the Defensive Line', 'Run in behind: opposite run-pass angles',
    'Forwards time runs beyond the offside line as the ball is played; a straight run pairs with a diagonal pass and a diagonal run with a straight pass.',
    'Pass to wide neutral / passer head up',
    'Receive behind the line onside with a correctly weighted ball.',
    NULL, 74, 74, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player', 'Play weighted ball into space behind'),
    (2, 'Runner', 'Time run on the pass, angle opposite the pass')
) AS v(so, role, job);

-- 17. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 19: FC Barcelona Playing Out from the Back 3 Zone SSG', 'Keeper and centre backs as pressure relief',
    'In the defensive third the keeper and centre backs act as an unpressed safety outlet so the team can reset and build again rather than lose the ball, with wide players stretching the play.',
    'Pressure on ball higher up',
    'Recycle through the back to rebuild against an organised block while still seeking chances.',
    NULL, 76, 76, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Safe outlet, restart build'),
    (2, 'Centre backs', 'Drop into safety zone to receive'),
    (3, 'Wide players', 'Stretch play, move ball quickly')
) AS v(so, role, job);

-- 18. pp.77-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 20: FC Barcelona 8 v 9 Phase of Play - Playing against the Deep Block', 'Breaking down the deep block',
    'Against a two-bank deep block protecting zone 14 and the byline, the team tries to pull it apart with dribbles, one-twos and a deliberate false touch to bait a tackle, while a deep playmaker controls tempo and guards against the counter; crosses only from the byline.',
    'Opponent sits in deep two banks',
    'Draw defenders out of their organisation to open central space.',
    NULL, 77, 77, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep-lying playmaker', 'Control possession, screen counters'),
    (2, 'Front three', 'Dribble, one-twos, false touch to lure tackles'),
    (3, 'Full backs', 'Width; go to byline only when isolated 1v1')
) AS v(so, role, job);

-- 19. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 21: Swansea City FC Position Specific Pattern Play', 'Fixed spacing between players',
    'Players keep set distances (about 20 yards on a full pitch) and move as a unit within their zones, checking space before receiving.',
    'Ball circulation in deep areas',
    'Keep a stable passing network with open angles.',
    NULL, 78, 78, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All outfield', 'Hold ~20 yd spacing, move as unit'),
    (2, 'Receiver', 'Check shoulders, open body before receiving')
) AS v(so, role, job);

-- 20. pp.79-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 22: Swansea City FC 8 v 6 Phase of Play - Playing Out from the Back', 'Building out vs a front two',
    'Keeper, back four and three midfielders build against a 4-4-2 front two, using the spare man created at the back to play out patiently into the forwards.',
    'Goalkeeper has ball, front two press',
    'Use the numerical edge in the first third to progress under control.',
    '4-4-2', 79, 79, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Start build, find free defender'),
    (2, 'Back four', 'Spread to create spare man'),
    (3, 'Spare player (midfielder)', 'Receive free and play into forwards')
) AS v(so, role, job);

-- 21. pp.80-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practices 23-24: Athletic Bilbao Finding Space within the Block (Pattern Play)', 'Midfielder''s timed sprint into pockets',
    'A central midfielder finds space inside a compact block with short, curved sprint bursts timed to the pass (not constant movement) while two defenders build patiently.',
    'Defender ready to pass',
    'Receive between opponents in congested midfield.',
    NULL, 80, 81, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'Short curved sprints into gaps on the pass'),
    (2, 'Ball-playing defenders', 'Patient circulation, disguised pass in')
) AS v(so, role, job);

-- 22. pp.82-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practices 25-26: FC Barcelona Team Positioning When Playing Out from the Back', 'Back four and controller shift as one',
    'The back four and deep controller take stations relative to the ball: full backs receive on the touchline, players stay ~20 yards apart and everyone slides toward the ball side; the controller''s direction sets the others. Same structure restarts from a throw-in.',
    'Ball moved to a flank / throw-in',
    'Keep a coherent passing network through the first line.',
    NULL, 82, 83, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'Receive wide on the touchline'),
    (2, 'Centre backs', 'Slide across, one drops deep on throw-ins'),
    (3, 'Deep controller', 'Direction of play dictates team shift')
) AS v(so, role, job);

-- 23. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 28: FC Barcelona Feeding the Ball into the Front 3', 'Striker holds, partners move off him',
    'A tightly marked striker receives with his back to goal, shields patiently until he can turn, while the other two forwards move to make space and offer options.',
    'Ball fed into striker under tight marking',
    'Keep the ball up front and create a turn or combination.',
    NULL, 85, 85, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'Shield, wait for moment to turn'),
    (2, 'Other two forwards', 'Move off to open space and angles')
) AS v(so, role, job);

-- 24. pp.86-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 29: Wigan Athletic FC Finding the Centre Forward in the Box', 'Third man run',
    'One player passes to a teammate who lays the ball on for a third player running in behind a tight marker; runs are disguised with dummy moves.',
    'Forward tightly marked',
    'Get a runner behind the defence thinking two passes ahead.',
    NULL, 86, 86, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First passer', 'Feed the setter'),
    (2, 'Setter', 'Lay ball off first time'),
    (3, 'Third man', 'Disguised run behind marker to receive')
) AS v(so, role, job);

-- 25. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 32: FC Barcelona The 3 Station Interchanges Exercise (Losing Your Man)', 'Losing your man with a feint',
    'Before receiving, a player makes a convincing dummy movement away from the ball and then checks back to create space from his marker.',
    'Teammate about to pass',
    'Free yourself to receive on the half-turn.',
    NULL, 89, 89, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'Dummy away, check back toward ball')
) AS v(so, role, job);

-- 26. pp.90-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', 'Part 2, Practice 33: Villarreal CF 4 v 4 Pressing Patterns', 'Organised zonal block line',
    'A line of four (e.g. a 4-4-2 midfield) defends spaces rather than men, setting staggered shapes and body angles that block passing lanes and make the opponent predictable.',
    'Opponent in possession in front of the line',
    'Protect goal through organised blocking instead of individual chasing.',
    NULL, 90, 90, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Line of four', 'Mark space, keep linked shape'),
    (2, 'Ball-side defender', 'Body angle to steer play')
) AS v(so, role, job);

-- 27. pp.91-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_defend', 'Part 2, Practices 34 / 40: Villarreal CF / AFC Ajax transition games', 'Recover into shape on loss',
    'When possession is lost, attackers sprint back with urgency to their defensive line (e.g. halfway) and block passes through them there.',
    'Ball lost',
    'Restore defensive shape before the opponent attacks.',
    NULL, 91, 97, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Sprint back to halfway zone'),
    (2, 'Front three', 'Block passing lanes from that zone'),
    (3, 'Defenders', 'Hold line until shape rebuilt')
) AS v(so, role, job);

-- 28. pp.92-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 35: FC Barcelona Switching Play through a Central Zone Transition Game', 'Switch through the middle',
    'Against defenders pressing in pairs and a compact block near the box, the team circulates on one side then switches the ball through the central screen to the other side.',
    'Press committed to one side',
    'Move the ball to the free side via the centre.',
    NULL, 92, 92, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side players', 'Circulate to draw press'),
    (2, 'Switch passer', 'Play through central gap to far side')
) AS v(so, role, job);

-- 29. pp.93-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', 'Part 2, Practices 36 / 41: FC Barcelona Triggers Pressing', 'Pressing triggers',
    'The team presses aggressively only when a cue appears (poor touch, poor pass, a cue call) rather than constantly.',
    'Bad touch, bad pass, other trigger',
    'Win the ball high when the opponent is vulnerable.',
    NULL, 93, 98, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players', 'Close ball aggressively on trigger'),
    (2, 'Rest of team', 'Support and cut short options')
) AS v(so, role, job);

-- 30. pp.95-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', 'Part 2, Practice 38: FC Barcelona Pressing Organisation Position Specific Pattern Play', 'Front five press shifts together',
    'In a 4-3-3 the front three and two central midfielders press as a unit, keeping set distances while shifting left, right or centre with the ball, then sprint back to stations when it is cleared.',
    'Ball moves to a side / ball cleared',
    'Collective organised press with no gaps.',
    NULL, 95, 95, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front three', 'Shift with ball, keep spacing'),
    (2, 'Two central midfielders', 'Follow shift behind front three'),
    (3, 'All five', 'Recover to start positions on clearance')
) AS v(so, role, job);

-- 31. pp.96-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', 'Part 2, Practice 39: Liverpool FC The Defensive Block Scoring Zone Game', 'Deep block slows the attack',
    'Back four and midfield trio form a deeper block that delays and slows the attack, pressing aggressively only when the moment is right, then counter on regain.',
    'Opponent advancing in possession',
    'Make the block hard to break and win the ball to counter.',
    NULL, 96, 96, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Hold compact deep line'),
    (2, 'Midfield trio', 'Screen and delay'),
    (3, 'Pressers', 'Press only at right moment')
) AS v(so, role, job);

-- 32. pp.97-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_defend', 'Part 2, Practices 40-42: AFC Ajax / FC Barcelona 6 Second Rule Pressing', '6-second press then drop',
    'On losing the ball the team presses aggressively high for a short window (about 6 seconds; 8 in another variant); if the opponent keeps it, everyone drops into a disciplined defensive block in the central third.',
    'Ball lost / window expires',
    'Regain immediately or retreat into organised block.',
    NULL, 97, 99, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players near ball', 'Hunt ball immediately'),
    (2, 'Front line', 'After window, fall back to central zone'),
    (3, 'Whole team', 'Switch between press and block phases')
) AS v(so, role, job);

-- 33. pp.100-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', 'Part 2, Practice 43: FC Barcelona Pressing Attacking Zone Game', 'Pressing into corner zones',
    'The defending side shapes its press to force the opponent''s build-up out toward the corners and sidelines (pressing attacking zones), where the ball is won or goes out.',
    'Goal kick / build-up to wide defender',
    'Control the game without the ball and regain near the opponent''s goal.',
    NULL, 100, 100, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Curve press to push play wide'),
    (2, 'Midfielders', 'Lock inside passes'),
    (3, 'Ball-side players', 'Trap in corner zone')
) AS v(so, role, job);

-- 34. pp.101-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', 'Part 2, Practice 44: AFC Ajax 3 v 3 / 6 v 3 Quick Phases Transition Game', 'Show attackers outside',
    'Defenders keep discipline and shape, making it hard rather than diving in, and steer attackers into wide areas away from goal.',
    'Attack approaching',
    'Control the attackers and keep them away from goal.',
    NULL, 101, 101, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'Stay on feet, show outside'),
    (2, 'Cover', 'Hold shape behind')
) AS v(so, role, job);

-- 35. pp.104-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 2, Practice 47: FC Barcelona Playing through the False 9 in a SSG', 'False 9 drops into the pocket',
    'The centre forward drops back into unmarked space between the lines to collect the ball, timing the run, and turns to attack with his first touch.',
    'Defenders cannot follow into the gap',
    'Receive free between lines and turn to attack.',
    NULL, 104, 104, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'False 9', 'Timed drop, open first touch to turn'),
    (2, 'Midfielders', 'Pass into the dropping 9')
) AS v(so, role, job);

-- 36. pp.111-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 3, ch 3-4: Archie McLean / Uruguay 1930', 'Short ground passing in triangles',
    'Early short-passing sides (Paisley-influenced Brazil and Uruguay) kept the ball on the ground with one-twos and quick combinations, using the interlocking triangles of a 2-3-5 / 2-3-2-3 shape.',
    'In possession anywhere',
    'Control the ball through short passing rather than long balls or lone dribbles.',
    NULL, 111, 112, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside forwards / halves', 'Form triangles for short passes'),
    (2, 'Winger', 'One-two combinations to escape markers')
) AS v(so, role, job);

-- 37. pp.113-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 3, ch 5-6: Matthias Sindelar / La Maquina', 'Withdrawn striker drags markers',
    'A centre forward drifts back into midfield; man-markers follow him out of position, opening space for the other forwards (Sindelar, Pedernera, later Hidegkuti).',
    'Opponent man-marks the centre forward',
    'Create space behind for teammates to exploit.',
    NULL, 113, 114, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'False 9 / withdrawn striker', 'Drop into midfield, pull marker'),
    (2, 'Other forwards', 'Attack the vacated space')
) AS v(so, role, job);

-- 38. pp.114-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 3, ch 6: La Maquina - Renato Cesarini and Jose Maria Minella', 'Rotating front five',
    'River Plate''s five forwards constantly swapped attacking positions, roaming the field so markers could not hold them.',
    'In possession in attack',
    'Unbalance marking with fluid positional rotation.',
    NULL, 114, 114, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front five', 'Interchange positions continuously')
) AS v(so, role, job);

-- 39. pp.115-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 3, ch 7: The Magnificent Magyars - Gusztav Sebes', 'Hungary''s flexible 2-3-3-2 interchanges',
    'Wingers dropped deeper and a deep-lying striker withdrew, making a flexible shape that pulled defenders out; players changed roles and positions, and everyone joined attack and defence.',
    'In possession',
    'Disrupt the opponent''s WM marking through versatility.',
    NULL, 115, 115, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep-lying centre forward', 'Withdraw to pull centre half out'),
    (2, 'Wingers', 'Drop deeper into midfield'),
    (3, 'Defenders', 'Join attacks'),
    (4, 'Forwards', 'Defend when ball lost')
) AS v(so, role, job);

-- 40. pp.116-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Part 3, ch 8: Maslov''s Pressing Approach', 'Maslov 4-4-2 roles in possession',
    'No wingers: wide midfielders work the space ahead of the full backs, full backs join circulation, a defensive midfielder anchors, the most creative player plays as an advanced playmaker, and passing is preferred over holding or dribbling.',
    'In possession',
    'Outnumber a two-man midfield and keep the ball moving as a system of roles.',
    NULL, 116, 116, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielders', 'Cover space in front of full backs'),
    (2, 'Full backs', 'Join ball circulation'),
    (3, 'Defensive midfielder', 'Anchor and screen'),
    (4, 'Advanced playmaker', 'Creative hub')
) AS v(so, role, job);

-- 41. pp.116-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', 'Part 3, ch 8: Maslov''s Pressing Approach', 'Maslov zonal pack pressing',
    'Dynamo Kyiv''s 4-4-2 dropped man marking for zonal cover; the midfield hunted the ball as a tight pack high up the pitch, squeezing space and closing gaps.',
    'Opponent has ball',
    'Win the ball back high through a collective zonal press.',
    NULL, 116, 117, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield four', 'Hunt ball as a compact unit'),
    (2, 'All players', 'Zonal cover, no man marking'),
    (3, 'Holding midfielder', 'Screen the back four')
) AS v(so, role, job);

-- 42. pp.119-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Influential Figures: Rinus Michels (Total Football)', 'Make the pitch big in possession',
    'On winning the ball the team spreads over the whole field: wingers touch the sidelines, forwards push up to stretch the back line, midfield gets the ball with room to circulate.',
    'Team has secure possession',
    'Maximise space and time for ball circulation by stretching the opponent''s block.',
    NULL, 119, 119, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'hold width on the touchline'),
    (2, 'Forwards', 'push high to stretch and pin the back line'),
    (3, 'Midfield', 'receive in the freed central space and circulate')
) AS v(so, role, job);

-- 43. pp.119-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', 'Influential Figures: Rinus Michels (Total Football)', 'Make the pitch small: pressing football / the hunt',
    'Without the ball the whole unit shifts toward the ball side, the back line steps up and lines stay close, squeezing the opponent into a congested area and hunting the ball in their half.',
    'Opponent has the ball, especially in their own half',
    'Win the ball back as fast and as high as possible by denying space and angles.',
    NULL, 119, 120, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive line', 'push up high to compress'),
    (2, 'All lines', 'stay close together, shift to ball side'),
    (3, 'Nearest players', 'hunt the ball in triangles'),
    (4, 'Goalkeeper/sweeper', 'cover space behind the high line')
) AS v(so, role, job);

-- 44. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Influential Figures: Rinus Michels (Total Football)', 'Position switching to shorten runs',
    'When a midfielder advances into a winger''s area, the winger takes over the midfielder''s spot instead of each sprinting back to his own position.',
    'A player leaves his zone to join the attack',
    'Keep the shape intact with shorter recovery runs so players stay fresh and pressing waves never break.',
    NULL, 120, 120, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advancing midfielder', 'push forward into the free wide zone'),
    (2, 'Winger', 'drop inside to fill the vacated midfield spot'),
    (3, 'Full back', 'cover the space behind the rotation')
) AS v(so, role, job);

-- 45. pp.124-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', 'Influential Figures: Valeriy Lobanovskyi - The Science of His Pressing Approach', 'Collective high press in opponent''s half',
    'The whole team presses as one coordinated unit high up the pitch, chasing opponents only in their half and in the zone each player is responsible for, while varying the size of the playing area to force mistakes.',
    'Ball in opponent''s half',
    'Deprive the opponent of the ball with 5 or all 11 players working as one system.',
    NULL, 124, 124, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'press and chase in the opponent''s half only'),
    (2, 'Midfield', 'press within own zone, do not leave it'),
    (3, 'Whole team', 'compact, vary the area to force the opponent where we want')
) AS v(so, role, job);

-- 46. pp.128-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Influential Figures: The Ajax Playing System Under Johan Cruyff', 'Build through the central axis (3-4-3 diamond)',
    'Build-up goes through a central spine of goalkeeper, centre back, libero, holding midfielder and striker, never through the full backs; the libero passes direct to the striker, who drops long and connects play for advanced midfielders.',
    'Ball with keeper, central defender or libero',
    'Use the whole width of options from the centre instead of the half-field a full back sees.',
    NULL, 128, 129, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'squeeze up as sweeper, 11th outfield player'),
    (2, 'Libero (No.4, Rijkaard)', 'start build-up, organise the side out of possession'),
    (3, 'Striker (No.9, Van Basten)', 'come short with the ball movement, make the pitch long'),
    (4, 'Attacking mid (No.10)', 'stay 5-10 yards from the striker to support'),
    (5, 'Full backs', 'pinched in, do not lead build-up')
) AS v(so, role, job);

-- 47. pp.129-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Influential Figures: The Ajax Playing System Under Johan Cruyff', 'Flank rotation: winger, collector, pinched full back',
    'The two flanking centre midfielders play behind the ball and swap with the pinched full back when he advances on the flank; the winger then fills the midfielder''s role. Only one full back goes forward at a time.',
    'Pinched full back steps into the advanced wide space',
    'Rotate positions on the flanks while keeping defensive balance.',
    NULL, 129, 129, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (7/11)', 'hug the touchline; fill midfield when a rotation happens'),
    (2, 'Supporting CMs (6/8)', 'collect, cover mistakes, swap with the full back'),
    (3, 'Full back (2/3)', 'only one advances at a time'),
    (4, 'Libero', 'cover centrally')
) AS v(so, role, job);

-- 48. pp.129-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Influential Figures: The Ajax Playing System Under Johan Cruyff', 'No centre forward: two wide forwards plus AM',
    'Variation without a central striker: a flat back four, two wide forwards and an attacking midfielder who empty the central space for midfield runners.',
    'No world-class target striker available',
    'Open the centre for midfielders to arrive while width and depth are kept.',
    NULL, 129, 129, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forwards', 'stay wide, threaten in behind'),
    (2, 'Attacking midfielder', 'vacate the space in front of the defence'),
    (3, 'Midfield runners', 'arrive into the emptied centre')
) AS v(so, role, job);

-- 49. pp.133-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Influential Figures: Frank Rijkaard', 'High compact line, possession deep in their half',
    'In a 4-1-2-2-1 the full backs push on while the screening midfielder covers the space they leave; the unit compresses high so short passing happens deep in the opponent''s half, waiting for the opening.',
    'Secure possession in opponent''s half',
    'Keep the ball close to their goal so a loss can be pressed immediately.',
    NULL, 133, 134, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'push forward and join the attack'),
    (2, 'Screening midfielder', 'cover the space behind the full backs'),
    (3, 'Defenders', 'hold a high line to compress the unit'),
    (4, 'Lone forward', 'be fed by creative players behind')
) AS v(so, role, job);

-- 50. pp.136-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Influential Figures: Pep Guardiola - Transitional / In Possession System Diagrams', '4-3-3 turns into 2-1-4-3 in possession',
    'From a 4-3-3 defensive block the full backs push to the height of the midfield, the centre backs split wide, the holding midfielder anchors and drops between them; the shape becomes an asymmetrical, zone-dependent 2-1-4-3 (even 2-1-2-5 at the extreme).',
    'Ball won and secured, slow build-up',
    'Create overloads in particular zones, with two possession playmakers instead of one.',
    NULL, 136, 139, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Valdes)', 'sweep the space behind the high line'),
    (2, 'Centre backs (Puyol, Pique)', 'spread to the flanks, carry the ball into space'),
    (3, 'Holding mid (Busquets)', 'anchor, drop between the centre backs'),
    (4, 'Wing backs (Alves, Abidal)', 'join the midfield line, give width'),
    (5, 'Centre mids (Xavi, Iniesta)', 'metronome and riskier forward playmaker'),
    (6, 'Inside forwards (7/11)', 'move inside to leave the flank to the wing backs')
) AS v(so, role, job);

-- 51. pp.140-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Influential Figures: Pep Guardiola - Lionel Messi', 'False 9 drops to create space',
    'The centre forward drops deep into midfield; a marking defender follows and opens space behind for the wide forwards to run into; if nobody follows he has a free man in midfield.',
    'Opponent marks man to man on the striker',
    'Draw defenders out of shape and add a midfield overload.',
    NULL, 140, 140, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'False 9 (Messi)', 'drop deep, receive, draw the marker'),
    (2, 'Wide forwards (Pedro, Villa)', 'attack the space left behind'),
    (3, 'Midfielders (Iniesta)', 'run into the vacated central zone')
) AS v(so, role, job);

-- 52. pp.142-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Influential Figures: Life After Pep Guardiola - Tito Vilanova', 'Once past midfield line, go forward',
    'Wingers hold more width; once the opponent''s midfield line is broken the team must not go back to the central playmaker but attack forward, and the keeper may play long to a wide winger.',
    'Opponent''s first line (midfield) is broken',
    'Exploit the broken line directly instead of resetting possession.',
    NULL, 142, 142, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'stay very wide, receive long balls'),
    (2, 'Forward players', 'offer forward options after the line is broken'),
    (3, 'Goalkeeper (Valdes)', 'long ball out to the wide winger when on')
) AS v(so, role, job);

-- 53. pp.145-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_defend', 'Tiki Taka Tactical Theory: What Are the Non-Variables of Tiki Taka Football?', 'Outnumber in key areas, then press immediately',
    'Players condense in key areas to outnumber the opponent in possession, so that if the ball is lost there they are already close enough to press at once and shrink the pitch.',
    'Possession in a crowded key area',
    'Make the ball circulation plan also the counter-press plan.',
    NULL, 145, 145, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side group', 'condense near the ball to outnumber'),
    (2, 'Same group on loss', 'press immediately'),
    (3, 'Defenders', 'close the play tighter the closer to own goal')
) AS v(so, role, job);

-- 54. pp.150-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Tiki Taka Tactical Theory: Positional Systems', '3-4-3 becoming 3-5-2 vs 4-4-2',
    'Against a 4-4-2, a 3-4-3 becomes 3-5-2 when the false 9 drops: three defenders and the keeper against two strikers, three central midfielders against two, and 1v1 specialists everywhere else.',
    'Opponent sets up a 4-4-2 block',
    'Create numerical superiority in the build-up and in central midfield.',
    '4-4-2', 150, 150, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three + goalkeeper', 'outnumber the two strikers'),
    (2, 'Dropping centre forward', 'make a third central midfielder'),
    (3, 'Wide players', 'win 1v1 duels')
) AS v(so, role, job);

-- 55. pp.152-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Tiki Taka Tactical Theory: Ajax''s Positional System under Van Gaal', 'Winger as target, direct pass to striker',
    'Ajax''s positional system put five players on the central vertical line and used the wingers as target men (to feet or into space); the libero often hit a direct forward pass to the striker''s feet.',
    'Libero in possession on the third line',
    'Move the ball forward quickly with less running, using wingers and a central core.',
    NULL, 152, 152, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Libero (Rijkaard)', 'direct pass to the striker''s feet'),
    (2, 'Striker (Van Basten)', 'receive to feet in advanced areas'),
    (3, 'Wingers', 'act as target men and link to the core'),
    (4, 'Central core', 'five on the central line of play')
) AS v(so, role, job);

-- 56. pp.153-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Tiki Taka Tactical Theory: Barcelona''s Positional System under Guardiola', 'Central box of three midfielders',
    'Barcelona fills the central midfield box with three players so that whichever has the ball sees many passing triangles; the wide areas support this core, and build-up is slower over a wider 9x7 grid.',
    'Ball in midfield',
    'Circulate through a centralised core with triangles everywhere.',
    NULL, 153, 154, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three central mids', 'fill the central box, form triangles, act as playmakers'),
    (2, 'Wide players/wing backs (Alves)', 'support the core, cover long distances up and down'),
    (3, 'False 9', 'drop to make a central overload')
) AS v(so, role, job);

-- 57. pp.155-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Tiki Taka Tactical Theory: Brendan Rodgers and the Positional System of Play', 'Goal kick short, long when pressed',
    'The goal kick is played short to a centre back who has split wide toward the flank or to a midfielder dropping in front of the defence; if the opponent presses high, the keeper skips to the second or third line.',
    'Goal kick',
    'Build out short, or exploit the space behind a high press with fewer defenders left.',
    NULL, 155, 155, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'play short; if pressed, hit the second or third line'),
    (2, 'Centre backs', 'split wide toward the flanks'),
    (3, 'Holding midfielder', 'drop into the space just in front of the defence'),
    (4, 'Forwards', 'face fewer opponents when the long ball comes')
) AS v(so, role, job);

-- 58. pp.156-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_attack', 'Tiki Taka Tactical Theory: Marcelo Bielsa''s Positional Play', 'Bielsa end form within 8 seconds',
    'Against a 4-4-1-1 Chile took up its attacking shape within about 8 seconds of winning the ball: wing backs cut inside to complete a central diamond, the back three spread wide, the two central mids split into attacking and defensive roles, and the left mid goes wide; 5-3-1-1 becomes 3-6-1.',
    'Ball won and played out of danger',
    'Outnumber in build-up and centrally and isolate defenders 1v1 in the final third.',
    '4-4-1-1', 156, 156, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing backs', 'cut inside to complete the central diamond'),
    (2, 'Back three', 'spread across the width of the box'),
    (3, 'Central mids', 'one attacks, one holds'),
    (4, 'Left-sided mid', 'push wide for width'),
    (5, 'Striker + right winger', 'stay ready for a counter attack')
) AS v(so, role, job);

-- 59. pp.156-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_defend', 'Tiki Taka Tactical Theory: Marcelo Bielsa''s Positional Play', 'Press now or first three delay',
    'On losing the ball Chile had two choices: stay in the attacking positions and press to win it back, or have the nearest three players press, support and cover while the rest get back into the defensive shape within 5 seconds, the left mid tucking in to form a midfield three.',
    'Ball lost from the attacking form',
    'Win the ball back, or delay until the defensive block is set.',
    '4-4-1-1', 156, 156, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First presser', 'press the ball'),
    (2, 'Second and third players', 'support and cover'),
    (3, 'Rest of team', 'recover into the defensive shape within 5 s'),
    (4, 'Left-sided midfielder', 'tuck in to make the midfield three')
) AS v(so, role, job);

-- 60. pp.159-159
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '2. The Transition Differentials: Regaining Possession, a FC Barcelona Case Study', 'Chaotic football: shield and find the line',
    'In the chaos of a fresh regain or a tight space, the ball carrier first looks for a teammate in the passing lane; if none, he shields the ball with his body and holds it so the defender has to work while teammates come to help.',
    'Under pressure in a crowded area',
    'Never just give the ball away; buy time for support.',
    NULL, 159, 159, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'find a player in line; otherwise shield and hold'),
    (2, 'Teammates', 'move to help and open a passing line')
) AS v(so, role, job);

-- 61. pp.160-160
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_attack', '2. The Transition Differentials: Liverpool F.C. Coach Interview: Regaining Possession', 'Pass out of the counter-press, then expand',
    'After winning the ball the first job is to pass out of the opponent''s immediate pressure; then the shape expands: centre backs stretch wide, full backs become wingers, the holding midfielder anchors and forwards find space with movement off the ball.',
    'Ball won',
    'Escape the immediate press and switch to the positional attacking shape.',
    NULL, 160, 160, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins it', 'pass out of the pressure first'),
    (2, 'Centre backs', 'stretch wide'),
    (3, 'Full backs', 'push up as wingers'),
    (4, 'Holding midfielder', 'anchor centrally'),
    (5, 'Forwards', 'find space off the ball')
) AS v(so, role, job);

-- 62. pp.161-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', '3. The Art of Collective Pressing', 'Full press, half press, false press',
    'Three pressing modes: full press harasses everywhere in coordination; half press drops everyone back to a set block at about halfway or the final 30 yards and only engages when the opponent enters; false press sends only 1-2 players high while the rest drop, luring the opponent into rushing play out to the pressed side. Teams cycle between them, e.g. full press after kick-off then a false or half press.',
    'Game phase, time since kick-off, opponent''s build-up',
    'Control where the opponent plays, slow them down and force errors without the ball.',
    NULL, 161, 162, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front 1-2 (false press)', 'press alone to lure play'),
    (2, 'Whole team (full press)', 'harass all over in coordination'),
    (3, 'Block (half press)', 'drop to the set line, engage only in the pressed territory')
) AS v(so, role, job);

-- 63. pp.163-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_defend', '3. The Art of Collective Pressing: The 6 Second Rule', '6 second rule: press, support, cover',
    'When the ball is lost in the opponent''s half, the nearest three press immediately for six seconds as presser, supporter and cover, triggered by an opponent who must turn back to his own goal, a poor touch, or a pre-agreed cue; the back pass to the keeper is anticipated and pressed.',
    'Loss in opponent half; opponent facing own goal or bad touch',
    'Regain within 6 seconds near their goal, or force a rushed keeper clearance.',
    NULL, 163, 163, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'press the ball carrier'),
    (2, 'Second player', 'support'),
    (3, 'Third player', 'cover'),
    (4, 'Others', 'cut off the back pass, press the keeper')
) AS v(so, role, job);

-- 64. pp.164-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', '3. The Art of Collective Pressing: Liverpool F.C. Coach Interview: Pressing', 'Front three jump on the centre-half switch',
    'The front three press with fixed zones: when the opponent''s left centre-half is about to pass to the right centre-half, the left winger leaves his full back and jumps onto the receiving centre-half, and the full back steps onto the opponent''s right back, so the team swarms by covering zones, not by man marking.',
    'Pass between the opponent''s centre backs',
    'Lock the ball on one side and swarm it.',
    NULL, 164, 164, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger', 'leave the full back, jump onto the receiving centre-half'),
    (2, 'Left full back', 'step up onto the opponent''s right back'),
    (3, 'Front three', 'press as one unit with set zones')
) AS v(so, role, job);

-- 65. pp.164-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_defend', '3. The Art of Collective Pressing: FC Barcelona - Preparing for the Negative Transition', 'Compact possession prepares the counter-press',
    'High up the pitch Barcelona compresses play into a small, crowded area and passes short there (rondo style); when a risky through ball is coming, they compress further, so on a loss players are already close enough to press.',
    'Possession high up; risky forward pass about to be played',
    'Be in pressing positions before the ball is lost, with short recovery runs.',
    NULL, 164, 166, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players near the ball', 'stay close together in a tight zone'),
    (2, 'High defensive line', 'push up to compact'),
    (3, 'Goalkeeper', 'cover the space behind the high line'),
    (4, 'On loss', 'press the receiver; force back pass to keeper or out of play')
) AS v(so, role, job);

-- 66. pp.167-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', '3. The Art of Collective Pressing: How 3 Players Can Successfully Press 5', 'Nearest man shows one way',
    'The nearest presser gets tight enough to block the forward pass and curves his run to show the carrier one way, while two supporters sit in balance behind ready to intercept the predictable sideways pass; delaying is as good as tackling.',
    'Opponent receives in front of the block',
    'Make play predictable so three can press five.',
    NULL, 167, 168, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest presser', 'close quickly, block the forward pass, show one way'),
    (2, 'Two supporters', 'balance behind, intercept the sideways pass')
) AS v(so, role, job);

-- 67. pp.171-172
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '4. Ball Circulation: Barcelona USA - Formation Structure and Phases of Play', 'Centre backs split, pivot drops in',
    'In possession the two centre backs open wide with a 30-40 yard gap and the holding midfielder drops between them as a third central defender in a 3-4-3; full backs push on; wingers get the ball with about 5 yards of space and take on 1v1s, using 2v1 numbers when available.',
    'Build-up from the back',
    'Free the full backs and give the wingers space to beat their man.',
    NULL, 171, 172, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'split wide, 30-40 yards apart'),
    (2, 'Holding midfielder', 'drop between them as the third defender'),
    (3, 'Full backs', 'push on, few defensive jobs'),
    (4, 'Wingers', 'receive with space, beat the man 1v1')
) AS v(so, role, job);

-- 68. pp.172-172
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '4. Ball Circulation: Choreographed Football', 'Choreographed patterns and the third man run',
    'The team rehearses set attacking patterns so 3-4 players move together: the third man starts his run as soon as the first pass goes, knowing the second man will set it to him.',
    'A rehearsed first pass is played',
    'Beat opponents'' reaction time with patterns known in advance.',
    NULL, 172, 172, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First passer', 'play into the second man'),
    (2, 'Second man', 'lay off first time to the runner'),
    (3, 'Third man', 'run early, before the second pass'),
    (4, 'Playmaker', 'start and direct the pattern')
) AS v(so, role, job);

-- 69. pp.175-175
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Tiki Taka Tactical Theory - Ball Circulation: 4 Possession Based Phases', 'Four phases of ball circulation',
    'Possession is split into construction from behind, midfield preparation, creation between the lines and penetration of the last lines; each phase has its own linking player.',
    'Team has the ball from the keeper or back line',
    'Move the ball up through the phases in order without losing control, each phase overlapping the next.',
    NULL, 175, 175, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central defenders', 'Split wide in phase 1 to make the pitch big'),
    (2, 'Anchor midfielder', 'Drops in and out of the gap between the centre backs as phase-1 link'),
    (3, 'Full backs', 'Push forward for width in phase 2'),
    (4, 'Number 10', 'Reference point in the final phases, finding free space')
) AS v(so, role, job);

-- 70. pp.175-175
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Tiki Taka Tactical Theory - Building Up Play', 'Build up through the centre',
    'Build-up and playmaking should run through central players rather than full backs or wingers, so both flanks stay available.',
    'Constructing play from the back',
    'Keep the whole width of the pitch open as passing options instead of being trapped on one touchline.',
    NULL, 175, 175, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central defenders / controller', 'Carry the build-up in central zones'),
    (2, 'Full backs / wingers', 'Stay wide as options, not as the main build-up route')
) AS v(so, role, job);

-- 71. pp.176-176
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', 'Tiki Taka Tactical Theory - The Importance to Implement all Aspects of Tiki Taka', 'Opportune, unpredictable final-third passing',
    'Further up the pitch passing becomes more creative and risky; tempo, direction and length of pass vary with the space offered so the opponent cannot predict it.',
    'Ball reaches phases 3 and 4',
    'Catch the opponent out of position and create chances rather than circulating sideways.',
    NULL, 176, 176, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advanced midfielders', 'Vary tempo and take opportune forward passes'),
    (2, 'Forwards', 'Move to exploit openings the varied passing creates')
) AS v(so, role, job);

-- 72. pp.177-182
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '5. The Attacking Attitudes', 'Target zone 14 and central box shots',
    'Goal and assist data show most goals come from the central penalty area and zone 14; crossing against a set defence is inefficient, crosses work best on the counter. Over-reliance on wide play (Villarreal 2011/12) drops central penetration.',
    'Final-third possession vs an organised defence',
    'Work the ball to a team-mate with a clear central shot inside the box; stretch the play wide only to open the middle, cross only when it is the best option.',
    NULL, 177, 182, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders / No.10', 'Play through the middle and into zone 14'),
    (2, 'Wide players', 'Stretch the back line; cross when it is clearly the best option'),
    (3, 'Strikers', 'Get free inside the central box')
) AS v(so, role, job);

-- 73. pp.183-183
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '5. The Attacking Attitudes - Comparing Swansea City and FC Barcelona', 'Three bodies in the box on crosses',
    'When crossing (mostly on the counter) the team gets three or more attackers into the box: the far-side winger comes in as a forward and the No.10 arrives from midfield.',
    'Cross on, especially in a counter attack',
    'Outnumber defenders in the box as the cross arrives.',
    NULL, 183, 183, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Crossing winger', 'Delivers'),
    (2, 'Far-side winger', 'Attacks the box as an extra forward'),
    (3, 'Number 10', 'Arrives late in the box'),
    (4, 'Striker', 'Occupies the central defenders')
) AS v(so, role, job);

-- 74. pp.184-184
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '5. The Attacking Attitudes - Comparing Swansea City and FC Barcelona', 'Diagonal long ball into the winger''s space',
    'Against a deep block, Ajax-style long diagonal balls are played not to a target man but into the space ahead of the advanced wide player.',
    'Opponent sits deep and blocks central routes',
    'Break a deep defence quickly by switching to the flank runner''s feet/space.',
    NULL, 184, 184, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep passer (CB / controller)', 'Hits the diagonal into space'),
    (2, 'Advanced wide player', 'Holds width high and runs onto it')
) AS v(so, role, job);

-- 75. pp.184-199
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '8. The Individual Basic Tasks - (10) The Box to Box or Advanced Central Midfielder', 'Midfielders dribble to draw players out',
    'Midfielders carry the ball not just to progress but to pull opponents out of position, opening space for more advanced team-mates; Barcelona use the dribble the same way.',
    'Midfielder on the ball in congested area',
    'Disorganise the block and free the next pass forward.',
    NULL, 184, 199, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Dribble to attract a defender'),
    (2, 'Advanced players', 'Move into the space vacated')
) AS v(so, role, job);

-- 76. pp.185-188
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_defend', '6. Defensive Organisation: The Block', 'Six-second regain, then set the block',
    'After losing the ball the team tries to win it back within about six seconds; if it cannot, it drops into a rehearsed low, medium or high block as one unit.',
    'Ball lost',
    'Regain immediately or move from chaotic transition into an organised structure, pressing again when an agreed trigger appears.',
    NULL, 185, 188, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players', 'Press the ball instantly for ~6 seconds'),
    (2, 'Whole team', 'If not won, retreat together into the agreed block'),
    (3, 'Full backs', 'Press if right, then drop back into the block line')
) AS v(so, role, job);

-- 77. pp.185-188
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', '6. Defensive Organisation: The Block - The 3 Types of Block', 'High block: compact team, high line',
    'The defensive line steps up in unison so the gap between last and first man is small (under a third of the pitch); the sweeper keeper and spare centre back cover the space behind. A deep line with a high midfield leaves a hole that three passes can exploit.',
    'Opponent tries to play out from the back',
    'Reduce the space and the target man''s influence, invite long balls that are easy to regain, and press very high.',
    NULL, 185, 188, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Squeeze up together, never sit deep while midfield is high'),
    (2, 'Sweeper goalkeeper', 'Cover balls in behind the high line'),
    (3, 'Spare centre back', 'Cover depth'),
    (4, 'Front and midfield lines', 'Press high, stay within a compact distance of the back line')
) AS v(so, role, job);

-- 78. pp.187-188
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', '6. Defensive Organisation: The Block - The 3 Types of Block', 'Lower or medium block alternative',
    'With slower defenders who would be exposed 1v1 by a long ball, the team defends in a lower block (or a medium block once well rehearsed), still as a whole-team unit, and marks tighter the closer the ball gets to goal.',
    'Back line lacks pace for a high line',
    'Force the opponent where you want them and regain in positions to counter or rebuild, without being run in behind.',
    NULL, 187, 188, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Hold a deeper line; mark tighter near own goal'),
    (2, 'Midfield', 'Stay connected to the back line, two clean lines'),
    (3, 'Forwards', 'Shape where the opponent can play')
) AS v(so, role, job);

-- 79. pp.190-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_attack', '7. The Conclusion of the Footballing States - Liverpool FC Ecosystem of Play', 'On regain: secure the ball or counter',
    'When the block wins the ball, the team either steadies possession back into phases 1 and 2 or counter attacks when the moment allows.',
    'Ball won from the block',
    'Choose between safe re-start of circulation and a fast break depending on space.',
    NULL, 190, 190, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Secure first pass'),
    (2, 'Defenders / controller', 'Offer the safe outlet to restart phase 1'),
    (3, 'Forwards', 'Break when the counter is on')
) AS v(so, role, job);

-- 80. pp.192-196
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '8. The Individual Basic Tasks - Case Study: A Typical 4-3-3 into a 3-4-3', '4-3-3 becoming 3-4-3 in possession',
    'The default 4-3-3 turns into an interchangeable 3-4-3 when the team has the ball: the controller drops between the widely split centre backs and the full backs advance.',
    'Team gains possession',
    'Create a dense triangle passing network across the pitch.',
    NULL, 192, 196, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Controller (6)', 'Drops into the void between the centre backs'),
    (2, 'Central defenders', 'Split wide'),
    (3, 'Full backs', 'Push up as wide midfielders'),
    (4, 'Front three', 'Hold width and depth')
) AS v(so, role, job);

-- 81. pp.193-193
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '8. The Individual Basic Tasks - (1) The Sweeper Goalkeeper', 'Sweeper keeper as first-phase distributor',
    'The keeper starts the build-up with his feet to the split centre backs and dropping controller, offers a side-to-side relief option, and against a high press looks for a lofted pass to an unmarked player on the second or third line instead of a straight long ball.',
    'Back pass or goal kick; high press on the short options',
    'Keep possession under pressure and exploit the extra space left by a high press.',
    NULL, 193, 193, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Distribute; lofted angled pass to the free man if press is high'),
    (2, 'Central defenders', 'Split wide for short options'),
    (3, 'Controller', 'Drops deep to receive'),
    (4, 'Wide midfielder / full back', 'Unmarked target high and wide')
) AS v(so, role, job);

-- 82. pp.194-194
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '8. The Individual Basic Tasks - (2 & 3) The Wing Backs', 'Full back as wide attacker in circulation',
    'In the block the full back is a tucked-in traditional defender; in ball circulation he advances into unmarked wide channels, supports midfield and aims for the byline, and helps press in advanced areas.',
    'Team in possession (ball circulation phase)',
    'Provide width and an extra attacker while still recovering into the block when needed.',
    NULL, 194, 194, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'Push high and wide, reach the byline, recover after loss'),
    (2, 'Wingers', 'Move inside to open the channel')
) AS v(so, role, job);

-- 83. pp.194-194
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', '8. The Individual Basic Tasks - (2 & 3) The Wing Backs', 'Full back shows outside or inside by zone',
    'Defending an attacker on the flank in the middle third, the full back forces him out to the touchline; when the opponent has the ball in their own defensive third, he can force the attacker inside because a regain there leads to a counter. In 2v2 he stays with his man unless the threat ends, a team-mate takes over, or the ball carrier beats a team-mate and needs help.',
    'Opposition winger on the ball',
    'Reduce the attacker''s options in mid-pitch and win the ball where it can be countered.',
    NULL, 194, 194, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Show outside in middle third, inside in their defensive third'),
    (2, 'Nearby defender', 'Take over marking or step in when beaten')
) AS v(so, role, job);

-- 84. pp.195-195
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '8. The Individual Basic Tasks - (4 & 5) The Central Defenders', 'Ball-playing centre backs and line control',
    'Centre backs stay composed under pressure, support keeper distribution, drive the line up to compact the team, and play drilled ground passes into the vertical lines that advanced players move into.',
    'Build-up and compaction moments',
    'Feed the early phases and keep the team compact.',
    NULL, 195, 195, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central defenders', 'Pass under pressure, ground passes into vertical lanes, push the line up'),
    (2, 'Front line', 'Move into vertical channels to receive')
) AS v(so, role, job);

-- 85. pp.196-204
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '8. The Individual Basic Tasks - (6) The Controller / (8) Second Controller', 'Drop a second controller when the six is marked',
    'If the opponent man-marks the controller (Rooney on Busquets, 2008), the central playmaker drops deeper as a second controller; this leaves the lone No.10 free space ahead. Rodgers likewise alternates two controllers + one advanced with one controller + two advanced.',
    'Controller man-marked or denied the ball',
    'Restore deep control of possession and free the advanced midfielder.',
    NULL, 196, 204, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Controller (6)', 'Drops between centre backs, dictates from deep'),
    (2, 'Central playmaker (8)', 'Drops to second-controller role'),
    (3, 'Number 10', 'Exploits the new space as solo advanced midfielder')
) AS v(so, role, job);

-- 86. pp.199-199
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_defend', '8. The Individual Basic Tasks - (10) The Box to Box or Advanced Central Midfielder', 'Midfield trio drops and wins in triggered press',
    'The 10 supports attacks then gets back into the block; the whole midfield must drop quickly out of the block and win the ball back during a triggered press.',
    'Ball lost / press trigger appears',
    'Recover shape and regain quickly through coordinated midfield movement.',
    NULL, 199, 199, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 10', 'Support high then recover into the block'),
    (2, 'Midfield trio', 'Drop and press together on the trigger')
) AS v(so, role, job);

-- 87. pp.200-200
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '8. The Individual Basic Tasks - (7 & 11) The Inside Forwards', 'Inside forwards: dynamic support and box filling',
    'Inside forwards dribble, make dynamic off-ball runs, get in behind the line into gaps the false 9 leaves, and when one is crossing the other attacks the box to add numbers.',
    'Ball circulation in the attacking third',
    'Outnumber defenders in the box and attack gaps behind the line.',
    NULL, 200, 200, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside forward (ball side)', 'Dribble / cross'),
    (2, 'Inside forward (far side)', 'Get into the box'),
    (3, 'False 9', 'Drop to open gaps for them')
) AS v(so, role, job);

-- 88. pp.200-200
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_attack', '8. The Individual Basic Tasks - (7 & 11) The Inside Forwards', 'Inside forwards in transitions',
    'In transitions the inside forwards either join the immediate press or find space to receive for a counter in threatening areas.',
    'Ball won or lost',
    'Be the first pressers on loss and the outlet on regain.',
    NULL, 200, 200, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside forwards', 'Press immediately on loss; offer counter outlet on win')
) AS v(so, role, job);

-- 89. pp.201-201
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '8. The Individual Basic Tasks - (9) The False 9', 'False 9 drops into midfield',
    'The central striker drops off; if a centre back follows, gaps open for the inside forwards and a 1v1 risk on the false 9; if not, he receives free in the dangerous central zone. He also presses in the transition.',
    'Ball circulation into the final third',
    'Create space for others or receive unmarked in zone 14.',
    NULL, 201, 201, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'False 9', 'Drop deep, take risks in creation, press on loss'),
    (2, 'Inside forwards', 'Attack gaps left by a following centre back')
) AS v(so, role, job);

-- 90. pp.203-203
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '9. Tactical Solutions - Tactical Problem 1: Build up from a Goal Kick', 'Goal kick hierarchy of options',
    'On goal kicks the centre backs split wide, full backs push on and the controller drops centrally; the keeper works through a hierarchy (short to CB, controller, then lofted passes to advanced wide players) and treats a high press as a chance to go long into space.',
    'Own goal kick',
    'Keep possession from the restart and ideally get the ball forward into advanced areas.',
    NULL, 203, 203, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Work through options 1-4 by priority'),
    (2, 'Central defenders', 'Split wide (option 1)'),
    (3, 'Controller', 'Drop central (option 2)'),
    (4, 'Full backs / wide midfielders', 'Push on as lofted targets (options 3-4)')
) AS v(so, role, job);

-- 91. pp.204-204
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '9. Tactical Solutions - Playing From The Defence Through To The Midfield', 'Ball-playing midfielder drops into central defence',
    'When the opponent lets defenders dwell but blocks passes into midfield, a ball-playing midfielder (Britton at Swansea) drops into a central defensive role so a comfortable passer receives and plays through the lines.',
    'Opponent lets our weaker-on-the-ball defenders have it but shuts midfield',
    'Turn the opponent''s tactic into a chance to play through the lines.',
    NULL, 204, 204, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-playing midfielder', 'Drop into the back line'),
    (2, 'Central defenders', 'Shift wider'),
    (3, 'Advanced midfielders', 'Move to receive between lines')
) AS v(so, role, job);

-- 92. pp.205-207
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '9. Tactical Solutions - Tactical Problem 2: Parking the Bus', 'Breaking the low block: stretch and false touch',
    'Against a deep compact block the team circulates horizontally to stretch it and make gaps vertically, uses the wide areas to decompact it, plays the striker deeper in zone 14, and the controller uses a ''false touch'' or dribble to tempt a midfielder to step out, freeing a team-mate behind him.',
    'Opponent sits deep and narrow, man-marks the controller''s options',
    'Penetrate the block through created space instead of hopeful shots or crosses.',
    NULL, 205, 207, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Controller', 'False touch / dribble to draw a defender out'),
    (2, 'Midfielders', 'Receive in the vacated space'),
    (3, 'Wide players', 'Stretch the block width-wise'),
    (4, 'Striker', 'Drop into zone 14 to receive')
) AS v(so, role, job);

-- 93. pp.208-209
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '9. Tactical Solutions - Tactical Problem 3', '5-4-1 without the ball into 3-5-2 with it',
    'Liverpool 2012: out of possession a 5-1-4/5-4-1; on winning the ball the wide midfielders push up beside the lone striker, the full backs advance wide, and three stay back (two wide centre backs plus controller) with a central midfield duo completing triangles.',
    'Possession won from the 5-4-1 block',
    'Keep 3-4-3-style positional play while defending with five.',
    NULL, 208, 209, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielders', 'Push into the final third beside the striker'),
    (2, 'Full backs', 'Advance to wide attacking positions'),
    (3, 'Two centre backs + controller', 'Form the back three'),
    (4, 'Central midfield duo', 'Provide passing triangles')
) AS v(so, role, job);

-- 94. pp.210-210
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '9. Tactical Solutions - Tactical Problem 4', 'Switch from two controllers to one',
    'If a 4-2-3-1 with two controllers dominates the ball but cannot play forward, move to a 4-1-4-1 with one controller and two advanced midfielders; centre backs take more playmaking and the full back gets more central support further up.',
    'Lots of possession but no final-third progress',
    'Increase the passing network in the final third at some cost of deep control.',
    NULL, 210, 210, 940)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Controller', 'Single holder'),
    (2, 'Two advanced midfielders', 'Offer more options in the final third'),
    (3, 'Central defenders', 'Take on playmaking from deep'),
    (4, 'Full backs', 'Support higher with less horizontal passing')
) AS v(so, role, job);

-- 95. pp.211-211
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '9. Tactical Solutions - Tactical Problem 5', 'Sit deeper and invite them on (slow back line)',
    'With defenders too slow for a high line, dominate deep possession with ball-playing defenders and a deep controller, invite the opponent to push up, then let fast inside forwards attack the space behind.',
    'Back line suffering against quick strikers',
    'Avoid being caught behind while creating space to run into.',
    NULL, 211, 211, 950)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-playing defenders / deep controller', 'Hold possession deep to draw the opponent up'),
    (2, 'Inside forwards / wingers', 'Run into space behind the higher opponent')
) AS v(so, role, job);

-- 96. pp.213-214
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '10. Wigan Athletic FC Case Study - 1. Through the Coach', 'Overload through the system',
    'A 3-5-2 against a 4-4-2 gives 3v2 in build-up, 3v2 centrally and 1v1s for specialist wide players up front, with an attacking midfielder joining to make 5v4; the 4-3-3 gets the same with a false 9 dropping and the anchor falling into defence.',
    'Opponent lines up 4-4-2',
    'Have a numerical overload in every third and isolate 1v1 specialists wide.',
    '4-4-2', 213, 214, 960)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three centre backs', '3v2 against their two strikers'),
    (2, 'Central midfield three', '3v2 against their two central midfielders'),
    (3, 'Wing backs / wingers', '1v1 specialists in wide zones'),
    (4, 'Attacking midfielder', 'Joins attacks to make 5v4')
) AS v(so, role, job);

-- 97. pp.214-218
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_defend', '10. Wigan Athletic FC Case Study - The Defensive Transition', 'Nearest man delays, recover in 4 seconds',
    'On loss the nearest player delays the carrier while the team recovers shape within about four seconds; dropping and delaying come before pressing, and square or slow opponent passes are triggers to step in.',
    'Ball lost / opponent counter attacks',
    'Regain defensive shape before the counter can hurt.',
    NULL, 214, 218, 970)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'Delay the ball carrier'),
    (2, 'Rest of team', 'Sprint back into shape'),
    (3, 'Midfield', 'Pounce on square or slow passes')
) AS v(so, role, job);

-- 98. pp.215-215
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '10. Wigan Athletic FC Case Study - 2. Through the Player', 'Mini overloads around the full back',
    'When a full back is pressed by the opposing winger, a 2v1 or 3v2 is made in varied ways: the winger gives an angle or drops deep, the controller breaks free, or a centre back offers depth behind; players vary their movements so the overload is not predictable.',
    'Full back in possession, pressed by winger',
    'Escape pressure and progress via small numerical superiorities.',
    NULL, 215, 215, 980)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'On the ball, uses the free man'),
    (2, 'Winger', 'Offer angle or drop deep'),
    (3, 'Controller', 'Break free inside'),
    (4, 'Central defender', 'Give depth behind')
) AS v(so, role, job);

-- 99. pp.215-216
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '10. Wigan Athletic FC Case Study - Wide Players: 1v1 Situations and Crossing', 'Isolate wide 1v1 and cross within seconds',
    'Against a low block the team builds and probes patiently; when it gets through the lines quickly it isolates 1v1 or 2v1 out wide and the winger aims to deliver a cross within about five seconds, choosing among early, whipped, cut-back or drilled crosses based on defenders and runners.',
    'Quickly through the lines with a wide 1v1',
    'Produce a quality cross before the defence recovers.',
    NULL, 215, 216, 990)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Beat his man or create an angle and cross early'),
    (2, 'Full back', 'Overlap or support wide'),
    (3, 'Runners', 'Late runs for cut-backs and the second 6-yard box')
) AS v(so, role, job);

-- 100. pp.217-217
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'in_possession', '10. Wigan Athletic FC Case Study - The Process of Possession', 'Wigan ball circulation principles',
    'Make the pitch big; play out from the back only with an overload or time; receive between lines and turn; play on many receiving lines; never turn down a forward pass when free; rotate and interchange; isolate 1v1s wide.',
    'Team in possession',
    'Patient, forward-minded possession that drags opponents out of shape.',
    NULL, 217, 217, 1000)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Play out only when there is an overload'),
    (2, 'Midfielders / forwards', 'Receive between lines and turn'),
    (3, 'Wide players', 'Isolate 1v1')
) AS v(so, role, job);

-- 101. pp.218-218
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'out_of_possession', '10. Wigan Athletic FC Case Study - The Process of Being Out of Possession', 'Press high, second man wins',
    'Win the ball as high as possible: press on a trigger in 1v1s, cut passing lanes, the first presser forces a rushed decision for the second or third man to win, agree to show inside or outside, and the back line knows when to press, drop and slide. If the opponent passes well and could play through, drop into a narrow compact unit.',
    'Opponent in possession, press trigger',
    'Regain high or deny penetration with a compact block.',
    NULL, 218, 218, 1010)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First presser', 'Force a hurried decision'),
    (2, 'Second / third man', 'Win the ball'),
    (3, 'Defenders', 'Body shape to show in or out'),
    (4, 'Back line', 'Press, drop and slide together')
) AS v(so, role, job);

-- 102. pp.218-218
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_attack', '10. Wigan Athletic FC Case Study - The Attacking Transition', 'Counter first: seven seconds to score',
    'On winning the ball the immediate priority is a counter attack with the farthest forward pass possible, cross runs, dribbles and forward runs; if no goal comes within about seven seconds the team switches to build and probe. Good shape behind the ball makes the forward pass low risk.',
    'Ball won',
    'Score before the opponent reorganises, else keep the ball.',
    NULL, 218, 218, 1020)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Play the farthest forward pass'),
    (2, 'Forwards', 'Cross runs and forward runs'),
    (3, 'Players behind the ball', 'Hold shape to cover a loss')
) AS v(so, role, job);

-- 103. pp.219-219
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-tiki-taka-style-of-play'), 'to_attack', '10. Wigan Athletic FC Case Study - Conclusion', 'Turnover vs 4-3-3: attack space left by full backs',
    'Against a modern 4-3-3, the first thought on winning the ball is to exploit the space their advanced full backs have left.',
    'Ball won vs a 4-3-3 with high full backs',
    'Hit the vacated wide channels immediately.',
    '4-3-3', 219, 219, 1030)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Find the runner into the full-back space'),
    (2, 'Wingers / inside forwards', 'Run into channels behind the full backs')
) AS v(so, role, job);

COMMIT;
