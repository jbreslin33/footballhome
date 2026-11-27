-- 1974 📚 Coaching book patterns: "Spanish Academy Soccer Coaching" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Spanish Academy Soccer Coaching',
    subtitle    = '120 Practices from the Coaches of Real Madrid, Atlético Madrid & Athletic Bilbao',
    author      = 'Jon Moreno Martínez, Santiago Esposito, José A. Fernández López, Iván Madroño Campos',
    team        = 'Athletic Bilbao, Atlético Madrid U11, Real Madrid U15, Real Madrid youth',
    method_note = 'Youth-academy sessions from four Spanish academy coaches, one chapter each, every chapter opening with a profile and philosophy then timed practices (diagram, objective, description, coaching points). Shared method: technique and tactics are never trained apart, players decide before they act, and practices copy match situations with growing complexity. Most pages are technique drills; patterns are the team behaviours the practices train (support triangles, lose the marker and receive half-turned, lay-off and third-man run, short-long game, switches, numbers-up breaks, press as a unit), in our words.'
WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at');

-- 1. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch1 Moreno - Possession and Finishing Small Sided Game', 'Circulate then feed the end-zone forward',
    'Team keeps the ball in midfield with free touches while a lone forward waits in the end zone; the aim is to get the ball into him quickly so he can finish in two touches.',
    'Forward has lost or dragged his marker / passing lane to him opens',
    'Find the decisive forward pass as early as possible and finish quickly.',
    NULL, 24, 24, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield circulators', 'shield the ball with body angled away from the defender, look up early for the forward pass'),
    (2, 'Off-ball midfielders', 'pull their markers away to open lanes for teammates'),
    (3, 'End-zone forward', 'get free of his marker, finish in max two touches')
) AS v(so, role, job);

-- 2. pp.25-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch1 Moreno - Crossing and Finishing SSG; Aerial Passing and Finishing SSG', 'Fast attack via wide player cross',
    'Small-sided game in a double-penalty-box area: team moves the ball quickly to its wide player in the attacking half, who crosses for central runners to finish with volley or header.',
    'Ball reaches the free wide player in the attacking half',
    'Exploit the extra man out wide and score from a well-timed cross.',
    NULL, 25, 34, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide outlet (attacking half)', 'receive and deliver a cross timed to the runs, lofted where needed'),
    (2, 'Central attackers', 'run into space to use the overload, attack the cross with timed runs'),
    (3, 'Ball carrier', 'play and think quickly, release wide early')
) AS v(so, role, job);

-- 3. pp.26-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch1 Moreno - Triangular Support Play in a SSG; Possession Game 5v5(+5)', 'Triangular support and constant unmarking',
    'Possession with neutral/utility players giving a numerical advantage under touch limits; every receiver must have a support option on each side of him.',
    'Teammate receives the ball',
    'Keep the ball and exploit the overload by always offering two angled options and moving off markers.',
    NULL, 26, 35, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Supporting players', 'form a triangle: one option left and one right of the receiver'),
    (2, 'Receiver', 'take the ball half-turned on the back foot to see and play forward'),
    (3, 'All attackers / neutrals', 'keep moving, lose the marker, one-touch where required')
) AS v(so, role, job);

-- 4. pp.35-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'out_of_possession', 'Ch1 Moreno - Possession Game 5v5(+5)', 'Outnumbered defenders press as a unit',
    'Defending side is outnumbered by the team in possession plus neutrals and must win the ball back.',
    'Opponent circulating with numerical superiority',
    'Regain the ball through compact, coordinated pressing rather than isolated chasing.',
    NULL, 35, 35, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'press the ball carrier'),
    (2, 'Other defenders', 'press together, stay connected to cut passing lanes')
) AS v(so, role, job);

-- 5. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch1 Moreno - Quick Pass, Move and Decision Making in a SSG', 'Pass and swap position, drive forward',
    '6v6 to goals where the passer must exchange positions with the receiver after each pass, and a player who has driven forward plays one touch.',
    'Pass played to a teammate',
    'Create fast attacks through movement after passing, positional rotation and quick one-touch play.',
    NULL, 37, 37, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'move immediately after the pass to swap places with the receiver'),
    (2, 'Advancing player', 'after carrying forward, play one touch with body protecting the ball'),
    (3, 'Team in possession', 'quick sharp movements to attack before defence settles')
) AS v(so, role, job);

-- 6. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'out_of_possession', 'Ch1 Moreno - Quick Pass, Move and Decision Making in a SSG', 'Don''t ball-watch, guard space behind',
    'Defenders facing a rotating, quick-passing attack are tempted to all go to the ball.',
    'Ball moves or attackers rotate',
    'Keep depth so runners and passes into the space behind are covered.',
    NULL, 37, 37, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'do not be drawn to the ball; check and protect the space in behind')
) AS v(so, role, job);

-- 7. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch2 Esposito - Feinting and Finishing Passageway (2)', '2v1 combination past a defender',
    'A pair attacks single defenders in successive channels and must beat them by dribble, pass or one-two, then shoot without being offside.',
    'Pair confronted by one defender',
    'Use the 2v1 to pass the defender with an early pass or one-two and finish.',
    NULL, 58, 58, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'keep ball close so the pass can be released early, commit the defender'),
    (2, 'Partner', 'time the run to the pass, stay onside, offer the one-two')
) AS v(so, role, job);

-- 8. pp.61-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch.2 Esposito / Ch.3 Fernandez Lopez - passing shapes coaching points', 'Check away, meet ball half-turned',
    'Before receiving, a player moves away from the ball to make space, then comes towards the pass with an open, half-turned body, taking it on the back foot so the next pass can go forward or across.',
    'Teammate about to pass to you',
    'Faster play with one or two touches, seeing teammates and opponents on the way in.',
    NULL, 61, 106, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Any receiver', 'Check away first, then move to meet the ball; open the hips and receive on the far foot'),
    (2, 'Passer', 'Pass hard and accurate to the side the receiver is facing; follow the pass to the next spot')
) AS v(so, role, job);

-- 9. pp.63-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch.2 Santiago Esposito (Atletico Madrid U11) - Passing / Shooting ''Y'' Shape', 'Lay-off then third-man run in behind',
    'A forward player drops short, lays the ball back to the passer and spins away; the passer plays a longer ball to a wider third player, who sets the spinning player running onto the ball towards goal.',
    'Short vertical pass into a player checking towards the ball',
    'Get a player running forward onto a pass in front of him, ready to dribble or shoot first time.',
    NULL, 63, 74, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep passer (1)', 'Pass in, take the lay-off, then hit the longer pass to the wide player'),
    (2, 'Checking forward (2)', 'Lay off with good weight, then hold or curve the run so the return ball lands in front'),
    (3, 'Wide third man (3)', 'Receive and either play back into the runner''s path or turn inside to shoot')
) AS v(so, role, job);

-- 10. pp.68-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch.3 Fernandez Lopez - Passing Triangles (1)-(4) / Squares with one-two', 'One-two to run past a marker',
    'The ball carrier passes to a nearby teammate and keeps running; the teammate returns it first time into the space ahead so the original carrier gets past the defender; repeated as double and triple one-twos and ''assist'' passes.',
    'Defender between the carrier and the space; teammate close enough to wall-pass',
    'Beat a defender by combining instead of dribbling and arrive on the move behind him.',
    NULL, 68, 96, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Pass and sprint immediately into the space past the defender'),
    (2, 'Wall player', 'Open up and return first time, weighting the ball ahead of the runner'),
    (3, 'Next support', 'Time the run while the ball travels between the previous two players, not too early')
) AS v(so, role, job);

-- 11. pp.79-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch.2 Esposito - 1 v 1 Duels in a Small Sided Game', 'Small-game quick attack behind defenders',
    'In a 3 v 3 the team plays at high tempo: players create space in the right areas, receive half-turned, then attack the space behind the defenders with feints and dribbles to score fast.',
    'Ball received with space to turn',
    'Score a quick goal by attacking in behind.',
    NULL, 79, 79, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'Get free, receive half-turned and look forward'),
    (2, 'Ball carrier', 'Use feints to beat the defender and attack the space behind'),
    (3, 'Teammates', 'Move into space away from markers')
) AS v(so, role, job);

-- 12. pp.80-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch.2 Technical Possession Game with 4 Corners / Ch.3 Possession, Transition Play and Interchange', 'Angled support both sides of receiver',
    'When a teammate in a wide or corner position receives, two teammates immediately offer angled supporting runs, one to each side, and the play continues with quick combinations into their path.',
    'Ball played to a corner or wide player',
    'Give the receiver two safe options left and right so possession is kept and the play can go on.',
    NULL, 80, 109, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide/corner receiver', 'Control and dribble back into play, or pass to a support'),
    (2, 'Left support', 'Run on an angle to the receiver''s left'),
    (3, 'Right support', 'Run on an angle to the receiver''s right')
) AS v(so, role, job);

-- 13. pp.80-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch.2 Technical Possession Game with 4 Corners / Ch.3 possession and transition games', 'Switch play to the far zone',
    'The team in possession keeps the ball and then changes the point of attack from one corner or zone to the opposite one, and the whole team moves across to play in the new area.',
    'Target in the far corner/zone free after a set number of passes',
    'Move the ball away from the crowded area into space and pull the opponents across.',
    NULL, 80, 112, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer of the switch', 'Play the long pass to the free far player'),
    (2, 'Far target', 'Move to receive in space, keep it'),
    (3, 'Rest of team', 'Shift quickly into the new zone to support')
) AS v(so, role, job);

-- 14. pp.84-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'to_defend', 'Ch.3 Fernandez Lopez - What do we want from our teams?', 'Attack with balance, regain fast',
    'Team principle: attack while keeping a balanced defence behind the ball, and after losing it try to win it back quickly, being intense and organised without the ball.',
    'Possession lost',
    'Recover the ball quickly without leaving the defence open.',
    NULL, 84, 84, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players near the loss', 'Press with intensity to win it straight back'),
    (2, 'Defenders behind the ball', 'Keep a balanced shape while the team attacks')
) AS v(so, role, job);

-- 15. pp.96-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch.3 Fernandez Lopez - Passing Square (3) ''short-long game'' / Rectangle ''support play'' / Diamond (3)', 'Short-long game: short support then depth',
    'After a short frontal support pass (the lay-off), the next ball looks for depth: a longer forward pass to a third player who has offered further away; players move to where they passed to keep supporting.',
    'Ball returned by a short supporting teammate facing play',
    'Mix short and long passing so the ball keeps moving forward through a third player rather than sideways.',
    NULL, 96, 106, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Short support player', 'Come close in front of the ball, set it back first time'),
    (2, 'Receiver of the set', 'Look up and play the long pass for depth'),
    (3, 'Deep third player', 'Offer the long option, timed late, and receive half-turned'),
    (4, 'Every passer', 'Move after the pass to give the next support angle')
) AS v(so, role, job);

-- 16. pp.107-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'to_attack', 'Ch.3 Fernandez Lopez - Possession with Attack/Defence Transition Play', 'Win it, play to the far target',
    'When the defending team regains the ball, it moves it quickly to its free targets in the other zone and all players run across to attack there (the author''s attack/defence transition).',
    'Ball recovered',
    'Get out of the pressure zone at once and start the attack in space.',
    NULL, 107, 112, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins the ball', 'Pass quickly to the free target in the far zone'),
    (2, 'Far target players', 'Show to receive and keep it'),
    (3, 'All other players', 'Sprint across to support in the new zone')
) AS v(so, role, job);

-- 17. pp.108-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'out_of_possession', 'Ch.3 Fernandez Lopez - possession and transition games coaching points', 'Collective press: one presses, others cut',
    'When the opponents have the ball, one player closes down the ball carrier while the others mark nearby opponents or block the possible passing lanes.',
    'Opponents in possession in our area',
    'Win the ball back as a group rather than with lone chasing.',
    NULL, 108, 112, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'Close down the ball carrier'),
    (2, 'Teammates near the ball', 'Mark the closest receivers'),
    (3, 'Others', 'Stand in the passing lanes to block the pass')
) AS v(so, role, job);

-- 18. pp.111-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch.3 Fernandez Lopez - Possession and Wide Play Small Sided Game', 'Switch quickly wide to cross and finish',
    'Inside players move the ball forward fast and look to switch it out to free wide players, who cross while attackers time their runs to attack the ball in the box.',
    'Wide player free in his channel',
    'Use the width to create crossing chances and finishes.',
    NULL, 111, 111, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central players', 'Move the ball forward quickly and switch it to the wide player'),
    (2, 'Wide player', 'Stay wide in the channel and deliver the cross'),
    (3, 'Box attackers', 'Time the runs and attack the ball on the move')
) AS v(so, role, job);

-- 19. pp.112-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'to_attack', 'Ch.3 Fernandez Lopez - Possession Game with Transition and Support Play', 'Immediate side support for the regainer',
    'The moment the ball is intercepted, teammates offer support straight away to the left and right of the player who now has it.',
    'Interception by a teammate',
    'Keep the regained ball and avoid losing it straight back.',
    NULL, 112, 112, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Interceptor', 'Secure the ball, head up'),
    (2, 'Left support', 'Offer a short angle on the left'),
    (3, 'Right support', 'Offer a short angle on the right')
) AS v(so, role, job);

-- 20. pp.113-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch.3 Fernandez Lopez - Build-Up Play from the Back in 8 v 8 SSG', 'Build through the centre from the keeper',
    'The team builds up from the goalkeeper on a full pitch but must pass through central midfielders in a central square before entering the opposition half; players move off their markers to open space.',
    'Goalkeeper or centre back in possession',
    'Progress the ball through the middle with quick one- or two-touch combinations.',
    NULL, 113, 113, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Start the play short to a defender'),
    (2, 'Centre backs/full backs', 'Spread and find the central midfielder'),
    (3, 'Central midfielders', 'Get free from markers in the centre, receive and play forward'),
    (4, 'Other players', 'Move into space to drag markers and offer a pass')
) AS v(so, role, job);

-- 21. pp.114-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch.3 Fernandez Lopez - 2 v 1 / 3 v 2', 'Overload in front of goal: one-two and shoot',
    'Attackers with a 2 v 1 or 3 v 2 near goal use quick one-twos to get behind the defender and shoot as soon as a chance appears.',
    'Numerical advantage against the last defender(s)',
    'Turn the extra player into a clear shot quickly.',
    NULL, 114, 115, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Commit the defender, then one-two past him'),
    (2, 'Partner attacker', 'Offer the wall pass or run beyond'),
    (3, 'Defender', 'Position to delay and cover the pass and the goal')
) AS v(so, role, job);

-- 22. pp.114-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'to_attack', 'Ch.3 Fernandez Lopez - 2 v 1 / 3 v 2: Defence to Attack Transition', 'Steal then 3 v 2 counter',
    'When the lone defender steals the ball from the 2 v 1, two teammates join straight away so the play reverses into a quick 3 v 2 attack the other way.',
    'Defender wins the ball',
    'Turn a regain into a fast attack with a numerical advantage before the opponents recover.',
    NULL, 114, 115, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender who steals', 'Carry or pass forward immediately'),
    (2, 'Two joining teammates', 'Sprint in at once to form the 3 v 2'),
    (3, 'Former attackers', 'Recover back as the two defenders')
) AS v(so, role, job);

-- 23. pp.116-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Ch.3 Fernandez Lopez - Numerical Advantage 12 v 6 Small Sided Game', 'Use outside support to exploit overload',
    'Inside players keep moving into space and use one-touch support players around the area to create an overload and attack fast at goal.',
    'Support player available outside the area',
    'Make the numerical advantage count with quick fast attacks and early shots.',
    NULL, 116, 116, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside attackers', 'Keep moving into space, play quickly (two touches)'),
    (2, 'Outside support players', 'Return or switch one touch'),
    (3, 'Shooter', 'Shoot whenever a chance opens')
) AS v(so, role, job);

-- 24. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Fernandez Lopez - 9 v 9 Three Zone Small Sided Game', 'Step a player up to overload next zone',
    'The pitch is split into thirds and players hold their zones; as the ball moves forward, one player from the zone behind steps up into the next zone to create a spare man there.',
    'Ball played forward into the next zone',
    'Win a numbers-up situation in every zone the ball enters while the rest of the team keeps its positions.',
    NULL, 117, 117, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player in the zone behind the ball', 'Push up into the ball zone as the extra man'),
    (2, 'Receiver in the next zone', 'Receive moving forward, pass ahead of the runner'),
    (3, 'Supporting teammates', 'Third-man runs and overlaps into space'),
    (4, 'Defending team', 'Press together while keeping zone positions')
) AS v(so, role, job);

-- 25. pp.118-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Fernandez Lopez / Madrono - 2 v 1 duels, 1 v 1 + 2, 2 v 1 Three Zone Challenge', '2v1 one-two to get behind defender',
    'Two attackers face one defender (or a lone attacker has a wide wall player); the carrier drives at the defender and uses a quick one-two so his partner or he himself runs into the space behind.',
    'Defender commits to the ball carrier',
    'Beat the defender with one pass and get in behind to shoot.',
    NULL, 118, 158, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Dribble close, commit the defender, release early'),
    (2, 'Partner / wide wall player', 'Offer the one-two, return first time'),
    (3, 'Runner after the pass', 'Sprint into the space behind the defender'),
    (4, 'Shooter', 'Take the shot as soon as it is on')
) AS v(so, role, job);

-- 26. pp.119-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'out_of_possession', 'Fernandez Lopez - 2 v 1 / 1 v 2 Attacking and Defending Duels', 'Two defenders: one presses, one covers',
    'When two defenders face a single dribbler, one goes to engage the ball while the second sits behind covering the space in case he is beaten.',
    'Lone attacker dribbles toward goal',
    'Stop the dribbler with pressure plus depth cover.',
    NULL, 119, 119, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First defender', 'Close down the ball carrier'),
    (2, 'Second defender', 'Cover the space behind the first defender')
) AS v(so, role, job);

-- 27. pp.120-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'to_attack', 'Fernandez Lopez / Madrono - Fast Break Attack vs Defence, 4 v 4 Fast Break, 11 v 7 Fast Break SSG', 'Numbers-up fast break from midfield',
    'After winning or securing the ball in midfield the team attacks quickly with more attackers than defenders (6v4, 5v4, 4v4 to a line, shoot within 4 passes), using width and forward runs to stretch the back line.',
    'Ball secured in midfield with a numerical advantage',
    'Exploit the extra man before the defence recovers and finish quickly.',
    NULL, 120, 163, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield passers', 'Quick combinations, play into space behind'),
    (2, 'Forward runners', 'Make forward runs to stretch the defence and open gaps'),
    (3, 'Wide attackers', 'Use the full width to spread defenders'),
    (4, 'All attackers', 'Check away from markers to get free for the pass')
) AS v(so, role, job);

-- 28. pp.122-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Fernandez Lopez - 9 v 9 Six Zone Small Sided Game', 'Progress up the pitch through wide players',
    'Players may only move into the space ahead of them, so the team advances by using its side players as the main outlet to move up the pitch.',
    'Central lane congested',
    'Use wide players to carry the numerical advantage forward.',
    NULL, 122, 122, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players', 'Offer the outlet and drive the ball up the flank'),
    (2, 'Central players', 'Receive half-turned so the next pass flows forward')
) AS v(so, role, job);

-- 29. pp.123-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Fernandez Lopez / Madrono - possession, build-up and space-creation games', 'Lose the marker, receive half-turned',
    'Before receiving, players check away from their marker (inside-out, outside-in, checked runs or semi-circular movement) and open their body to receive half-turned, controlling across the body with the back foot.',
    'Teammate about to pass while you are marked',
    'Create a free angle to receive and see the next pass, enabling one- or two-touch play.',
    NULL, 123, 168, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Intended receiver', 'Check away then come back into the free space'),
    (2, 'Intended receiver', 'Open body, first touch with the back foot toward the next pass'),
    (3, 'Ball carrier', 'Head up, play into the space created'),
    (4, 'Ball carrier when space opens', 'Dribble into the free space')
) AS v(so, role, job);

-- 30. pp.124-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'to_attack', 'Fernandez Lopez - 9 v 9 Counter Attacking Small Sided Game', 'Counter to forwards held high',
    'Two players stay high in the far half while the rest defend; on a regain the ball goes straight to them, they hold it until teammates arrive, lay it back, then attack together.',
    'Ball stolen in own half',
    'Launch a quick counter while supporting the advanced forwards up the pitch.',
    NULL, 124, 125, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two advanced forwards', 'Wait high, receive the first pass and hold it up'),
    (2, 'Forwards on receiving', 'Play backwards to arriving support before attacking'),
    (3, 'Regaining players', 'Pass forward fast then sprint up to support')
) AS v(so, role, job);

-- 31. pp.125-157
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'out_of_possession', 'Fernandez Lopez / Madrono - Counter Attacking SSG, 3 Team Possession and Transition, 4 v 4 + 4', 'First man closes, others cut passing lanes',
    'When defending in possession games the nearest player presses the ball carrier while teammates mark or block the likely passes, communicating to press as a unit.',
    'Opponent has the ball in our zone',
    'Win the ball back collectively through pressure plus interception.',
    NULL, 125, 157, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'Close down the ball carrier'),
    (2, 'Second defender', 'Read and intercept the pass'),
    (3, 'Other defenders', 'Mark receivers or block lanes'),
    (4, 'Whole unit', 'Communicate to keep the press compact')
) AS v(so, role, job);

-- 32. pp.127-165
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Fernandez Lopez / Madrono - Dynamic 4 Zone, 9 v 4 Zonal, 3 v 3 + 3 Zonal', 'Support triangles around the ball',
    'In tight possession (e.g. 3v2 or 2v1 per zone) the two supporting players position on either side of the carrier to form a triangle and keep moving to stay available.',
    'Teammate on the ball under pressure',
    'Always give the carrier two passing angles to keep the ball.',
    NULL, 127, 165, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Head up, pick the free angle'),
    (2, 'Left support', 'Take an angle to one side of the carrier'),
    (3, 'Right support', 'Take an angle to the other side'),
    (4, 'Outside / utility players', 'Stay level with play, one-touch returns')
) AS v(so, role, job);

-- 33. pp.128-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Fernandez Lopez - Playing Wide and Switching Play in a SSG', 'Draw inside, go wide, switch',
    'The team plays through the middle to pull opponents in, then finds a wide player in the opposition half and switches quickly to the far side to finish; wide players and passers swap positions.',
    'Opponents narrow onto central passing',
    'Attack the weak side with a cross before the defence shifts.',
    NULL, 128, 128, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central players', 'Draw opponents in, create space in front and behind for the switch'),
    (2, 'Wide players', 'Receive high and wide, interchange with the passer'),
    (3, 'Passers', 'One touch where possible to switch fast'),
    (4, 'Runners from deep', 'Time runs to meet the final cross')
) AS v(so, role, job);

-- 34. pp.143-143
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Madrono - Player Position Specific Build-up and Combination', 'Build-up circulation keeper to keeper',
    'The ball is worked from one goalkeeper through every position on the full pitch to the far end, each player acting as his position would, with open body shape and 1-2 touches.',
    'Goalkeeper starts possession',
    'Rehearse a positional build-up route that moves the ball the length of the pitch.',
    NULL, 143, 143, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Start the build-up to a defender'),
    (2, 'Defenders and midfielders', 'Check to create space, open body, play in 1-2 touches'),
    (3, 'Front players', 'Receive and combine through to the far end')
) AS v(so, role, job);

-- 35. pp.145-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Madrono - Deep Attacking Combination, Central Finishing Competition, Quick Interplay and Dynamic Finishing', 'Late runner from deep finishes combination',
    'A midfielder starts a combination with players ahead (pass, lay-off or long pass), then keeps running and arrives on the final pass to strike first time centrally.',
    'Midfielder plays the first pass into the front players',
    'Score from a well-timed run from deep that defenders struggle to track.',
    NULL, 145, 155, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep midfielder', 'Pass, keep running, attack the return on the move'),
    (2, 'Front players / wall players', 'Set or return the ball weighted into the runner''s path'),
    (3, 'Shooter', 'Check off the marker, strike first time')
) AS v(so, role, job);

-- 36. pp.149-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Madrono - Overlapping Runs, Crossing; Possession Crossing Zonal SSG; Overlapping Wide Play; 7 v 7 Fast Wide Play', 'Overlap and cross to split box runs',
    'After possession in the middle, the ball goes wide early, often into an overlapping runner, who crosses timed to forward runs; attackers communicate so one attacks the near post and another the far post.',
    'Wide player or overlapper free on the flank',
    'Deliver a timed cross into a box occupied at both posts.',
    NULL, 149, 164, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central passer', 'Release the ball wide ahead of the overlap'),
    (2, 'Overlapping wide player', 'Run beyond, cross timed to the runs'),
    (3, 'Near-post runner', 'Attack the near post'),
    (4, 'Far-post runner', 'Attack the far post')
) AS v(so, role, job);

-- 37. pp.150-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Madrono - Quick Interplay and Third Man Runs', 'Third-man run into the middle',
    'A player passes out to a teammate and a third player moves into the central space to receive the return, half-turned, while players rotate positions.',
    'Pass played to an outer teammate',
    'Find a free man in the middle via a third player who was not the original target.',
    NULL, 150, 150, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First passer', 'Play out to the wall player'),
    (2, 'Wall player', 'Time the second pass to the third man''s run'),
    (3, 'Third man', 'Move into the middle, receive half-turned with the back foot')
) AS v(so, role, job);

-- 38. pp.153-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'out_of_possession', 'Madrono - Possession, Crossing and Finishing Zonal SSG; Overlapping Wide Play SSG', 'Defending crosses side-on',
    'When the ball goes wide for a cross, defenders set their bodies side-on facing away from goal so they can see both the ball and the runners, then block, intercept or clear.',
    'Ball reaches the wide crosser',
    'Stop the cross being converted.',
    NULL, 153, 154, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Box defenders', 'Stand side-on to see cross and runners'),
    (2, 'Nearest defender', 'Block the cross'),
    (3, 'Others', 'Intercept or clear the delivery')
) AS v(so, role, job);

-- 39. pp.157-161
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'to_defend', 'Madrono - 4 v 4 + 4 Possession; 2 v 1 / 2 v 2 Attack and Defence Transition Game', 'Attackers switch instantly to defending',
    'In possession games and 2v1 then 2v2 transition games, the side that loses the ball reacts at once to the new situation rather than pausing.',
    'Ball lost or attack finished',
    'Defend the next action straight away with maximum decision speed.',
    NULL, 157, 161, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost the ball', 'React immediately to the change'),
    (2, 'Former attackers', 'Recover and defend the new 2v2')
) AS v(so, role, job);

-- 40. pp.166-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'spanish-academy-soccer-coaching-120-practices-from-the-coaches-of-real-madrid-at'), 'in_possession', 'Madrono - 4 v 4 + 5 Possession with 1 v 1 Break-Away Game', 'Overload centre, release winger 1v1',
    'Central midfielders keep the ball in the middle with help from a spare player, then after enough passes play a deep pass to a winger who attacks his full back one-on-one down the flank.',
    'Central possession secured (set number of passes)',
    'Isolate a winger against a lone defender on the flank.',
    NULL, 166, 166, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Keep possession in the middle, draw the opponents'),
    (2, 'Spare / utility midfielder', 'Add the extra man inside'),
    (3, 'Winger', 'Receive the deep pass and attack the defender 1v1')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1974-coaching-book-spanish-academy-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
