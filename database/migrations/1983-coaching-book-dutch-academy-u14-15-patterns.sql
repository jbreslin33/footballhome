-- 1983 📚 Coaching book patterns: "Dutch Academy Football Coaching U14-15" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Dutch Academy Football Coaching U14-15',
    subtitle    = 'Functional Training & Tactical Practices from Top Dutch Coaches',
    author      = 'DeVoetbalTrainer (Andries Ulderink, Han Berger, Henk Mariman, Louis Coolen)',
    team        = 'Dutch academy 4-3-3',
    method_note = 'Dutch academy material for U14-15 in a 4-3-3. It opens with the age''s characteristics and a coaching method built on the four match moments, then positional requirements per line, a style of play, building up (through the full back, centre back stepping into midfield, forward pass first, keeper short or long, switches when the block shifts), attacking patterns (isolating the winger, wing one-twos, striker drops and the 10 runs beyond, box occupation for crosses) and defending patterns (high press, steering the build-up wide, taking over runners, back line shifting across), each with practices. App page = printed page + 1. Patterns are the team behaviours, in our words.'
WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr');

-- 1. pp.11-11
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Age Specific Characteristics: Players Coaching on the Pitch', 'Teammates call the situation',
    'Players guide each other during play. They warn the man on the ball when an opponent is close behind him and tell him where the ball should go next.',
    'Teammate about to receive under pressure he cannot see',
    'Better decisions for the man on the ball and shared responsibility.',
    NULL, 11, 11, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearby teammate', 'calls ''man on'' or ''time'' and points to the free option'),
    (2, 'Ball receiver', 'listens and adjusts his first touch')
) AS v(so, role, job);

-- 2. pp.12-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'to_defend', 'Age Specific Characteristics; The Match: The Transition Phases', 'Lost ball: press or drop',
    'When the ball is lost, each player has to choose at once between pressing the ball and dropping back into the team''s shape. The 4-3-3 helps them get organised quickly, and the team agrees in advance what it does with and without the ball, adjusting against a stronger opponent.',
    'Possession lost',
    'Get back into the agreed defensive organisation as fast as possible, with no hesitation.',
    NULL, 12, 52, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players nearest the ball', 'press immediately if that is the agreed choice'),
    (2, 'Players away from the ball', 'drop back into the 4-3-3 positions at once'),
    (3, 'Whole team', 'use the pre-agreed plan for with and without the ball, adjusted to the opponent')
) AS v(so, role, job);

-- 3. pp.18-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'Training / Coaching; Requirements for Full Backs', 'Full back pushes inside, pitch smaller',
    'When the ball is on the other side, the full back tucks inside to cover in a three- or four-man line. When the ball is on his side, he chooses to mark tight, push up, or track the run.',
    'Ball is on the far side, or an attacker comes into his zone',
    'Keep the back line compact and narrow, with cover behind the man engaging.',
    NULL, 18, 55, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Far-side full back', 'tucks inside to cover in a three- or four-man defence'),
    (2, 'Ball-side full back', 'marks tight, pushes up or tracks the run; cuts out passes to his man and blocks crosses'),
    (3, 'Centre backs', 'shift towards the ball')
) AS v(so, role, job);

-- 4. pp.18-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Training / Coaching (5 v 3 with formation)', 'Centre backs push into midfield',
    'In a 4+1 v 3 build-up the two centre backs have spare numbers. The free one carries or steps up into midfield instead of passing sideways.',
    'Our centre backs outnumber their front line, so one centre back is free',
    'Add a man to midfield and draw a presser out, which frees a teammate further forward.',
    NULL, 18, 56, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free centre back (4/5)', 'spots the moment to step up into midfield and keeps the build-up going with longer passes along the ground or in the air'),
    (2, 'Other centre back', 'holds the last line'),
    (3, 'Holding midfielder', 'makes room for the centre back stepping up')
) AS v(so, role, job);

-- 5. pp.18-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Training / Coaching; The Match: Vision and Awareness', 'Preliminary action: stay away, come now',
    'A receiving player first moves away from his marker or the space, then times a sharp move towards the ball as the pass is about to be played. He does not stand waiting in the receiving spot.',
    'Teammate is about to play the pass',
    'Receive free of the marker, on the move and facing forward.',
    NULL, 18, 57, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver (full back, midfielder or striker)', 'checks away from the marker, then accelerates into space just as the ball is played'),
    (2, 'Passer', 'plays the ball into the space the receiver is moving towards'),
    (3, 'Central midfielder (6/8)', 'calls for the ball at the right moment in the build-up from the back')
) AS v(so, role, job);

-- 6. pp.19-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'Training / Coaching (defending in lines)', 'Midfield screens before defence acts',
    'Against one or two attackers only the back line defends. As more attackers join, the midfielders and full backs take part, and ideally the midfielders win the ball before the defenders have to.',
    'More attackers join the attack',
    'Stop the ball in front of the back line.',
    NULL, 19, 20, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'intercept and screen in front of the defence'),
    (2, 'Full backs', 'join the defending as the number of attackers rises'),
    (3, 'Centre backs', 'deal with the remaining attackers')
) AS v(so, role, job);

-- 7. pp.19-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'The Importance of Crossing', 'Wing one-two to cross',
    'The winger checks away from his marker, receives facing forward and goes 1v1, or plays a one-two and makes a deep run to cross from near the byline.',
    'Winger receives under pressure on the flank',
    'Deliver an early cross with the ball moving forward.',
    NULL, 19, 21, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (7/11)', 'checks away, takes the 1v1 or plays the one-two, runs deep and crosses'),
    (2, 'Inside teammate', 'gives the wall pass'),
    (3, 'Striker (9)', 'attacks the cross')
) AS v(so, role, job);

-- 8. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Technical Training Methods / Vision', 'Play forward early, else keep it',
    'During the build-up the first look is for the forward pass to an open player. If nothing is on, the ball is kept until more teammates are available, or moved on first time.',
    'Receiving in the build-up',
    'Make progress quickly without forcing the ball and losing it.',
    NULL, 24, 24, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player receiving', 'checks before receiving, looks forward first and plays the forward pass as soon as it is on'),
    (2, 'Teammates', 'move away from their markers into space so they are available'),
    (3, 'Ball carrier with no option', 'shields and holds until support arrives, or plays a first-time pass')
) AS v(so, role, job);

-- 9. pp.27-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Progressive Training Session Example: Building Up Play with the Full Backs', 'Build-up through the full back',
    'Short build-up from the goalkeeper and centre back that goes deliberately through the full back. A presser comes out to meet the full back as the ball arrives.',
    'Centre back opens up and plays into the space in front of the full back',
    'The full back breaks past his direct opponent with a pass or a dribble, or combines with the midfielder in a 2v1, and the attack moves into midfield.',
    NULL, 27, 33, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (4)', 'first touch rolls the ball open towards himself, then a firm pass into the space ahead of the full back'),
    (2, 'Full back (2/3)', 'moves off the line, checks away before receiving, takes the ball on the move; goes outside or inside the presser, or plays forward at once if the presser closes fast'),
    (3, 'Central midfielder (6/8/10)', 'stays high as the forward outlet and makes the 2v1 with the full back; can turn and shoot or lay off'),
    (4, 'Goalkeeper', 'starts it short; no long balls')
) AS v(so, role, job);

-- 10. pp.33-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Building Up Play with the Full Back (Step 4) / 4 v 4 Small Sided Games', 'Switch when the block shifts across',
    'The opponent shifts in a disciplined way towards the ball side. The team in possession moves it to the far side in one action, either a change of direction or a cross-field pass, for example full back to full back across the whole width.',
    'Defending block has shifted over to the ball side',
    'Get the ball to the free side before the block can slide back, and gain space to attack.',
    NULL, 33, 46, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back / carrier', 'draws the shift, then plays the switch in one action'),
    (2, 'Far-side full back', 'holds the full width, ready to receive the switch'),
    (3, 'Midfielders', 'provide the link if the direct switch is blocked')
) AS v(so, role, job);

-- 11. pp.35-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Progressive Training for 1 v 1 Duels', '1v1 decision by zone',
    'The attacker in a 1v1 decides what to do from where he is. In a central position he makes space and shoots. Out wide he goes inside or outside to make room for a cross. When tightly marked he plays first time and runs for the return. In a very tight space he draws a foul for a set piece.',
    'Attacker isolated against one defender',
    'Every duel has a purpose that leads to a goal chance.',
    NULL, 35, 44, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central attacker (9/10)', 'inside shooting range, shifts the ball and shoots with his stronger foot'),
    (2, 'Winger (7/11)', 'beats the full back on the inside or outside to cross or cut in'),
    (3, 'Tightly marked attacker', 'plays a one-two and spins in behind'),
    (4, 'Attacker in tight space', 'wins a free kick, corner or penalty')
) AS v(so, role, job);

-- 12. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Receive, Dribble & Beat a Defender on the Flank in a Passing Combination Practice', 'Long switch to isolate the winger',
    'The central midfielders move the ball across and then hit a long ball to the winger on the far side. The winger beats his man, the striker checks away and receives, and sets it for the No.10 arriving.',
    'Winger is free 1v1 on the far flank',
    'Isolate the winger, then combine inside towards goal.',
    NULL, 41, 41, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (6/8)', 'circulate, then play the long switch to the winger'),
    (2, 'Winger (7/11)', 'controls cleanly and dribbles past the defender'),
    (3, 'Striker (9)', 'checks away from his marker, then shows to receive'),
    (4, 'No.10', 'takes the lay-off and moves the attack on')
) AS v(so, role, job);

-- 13. pp.43-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Winning a 1 v 1 Duel in the Centre / on the Side', 'Receive forward and attack the defender',
    'A forward who gets the ball with one defender in front calls for it with conviction, takes his first touch forward and goes at the defender immediately.',
    'Pass played into a forward who has one defender in front of him',
    'Shoot or score before the defence recovers.',
    NULL, 43, 44, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving forward', 'calls loudly for the ball, first touch forward, attacks at once'),
    (2, 'Winger', 'receives out wide and drives at the defender on the edge of the box'),
    (3, 'Passer', 'does not hesitate when the call comes and plays it straight away')
) AS v(so, role, job);

-- 14. pp.54-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Requirements for Goalkeepers', 'Goalkeeper starts the build-up',
    'The goalkeeper is part of the build-up. He starts play with an aimed throw or roll, takes back-passes on either foot and continues with a short or long pass.',
    'Goalkeeper has the ball, or receives a back-pass',
    'Keep possession from the back and get the ball to a free player.',
    NULL, 54, 54, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (1)', 'targets a throw or roll, receives back-passes with both feet and picks short or long'),
    (2, 'Centre backs / full backs', 'spread to offer short options')
) AS v(so, role, job);

-- 15. pp.55-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Requirements for Full Backs / Central and Attacking Midfielders', 'Midfield runs and third-man play',
    'In the attacking phase the full back pushes up into midfield and keeps the attack going. The central midfielders shield the ball or create space and choose their moments to go deep. The No.10 sees third-man solutions before he receives and makes late runs for the final ball.',
    'Ball is secured in midfield',
    'Create chances in the final stage through combinations and supporting runs.',
    NULL, 55, 58, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (2/3)', 'pushes into midfield, plays longer passes and crosses'),
    (2, 'Central midfielders (6/8)', 'shield or turn, play through balls, pick the moment for a deep run'),
    (3, 'Attacking midfielder (10)', 'plays the third-man ball, follows up attacks, makes clever runs into the final stage')
) AS v(so, role, job);

-- 16. pp.56-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'Requirements for Centre Backs', 'Free centre back''s three choices',
    'The centre back who is not marking anyone decides what to do: push into midfield to mark or cover, step out to intercept when an opposing midfielder is about to receive, or hold on the last line.',
    'Centre back is the spare man',
    'Use the free defender where he helps most without leaving the last line open.',
    NULL, 56, 56, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free centre back (4/5)', 'steps into midfield, intercepts as the midfielder receives, or holds the last line'),
    (2, 'Marking centre back', 'stays tight, pushes up or tracks the run')
) AS v(so, role, job);

-- 17. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'Requirements for Central Midfielders', 'Centre backs take the runner',
    'When an opposing midfielder runs forward past the midfield line, the central midfielder hands him over to the centre backs and stays in his own position rather than dropping into the back line. He presses his man when the moment is right.',
    'Opposing midfielder runs forward beyond our midfield',
    'Keep the midfield line intact and the marking clear.',
    NULL, 57, 57, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (6/8)', 'passes the runner on, stays in midfield, presses at the right moment and reads passes to intercept'),
    (2, 'Centre back', 'picks up the runner')
) AS v(so, role, job);

-- 18. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'Requirements for Attacking Midfielders', 'Front line steers build-up wide',
    'The No.10 and the forwards angle their pressure so the opponent''s build-up goes out to the flanks, or so the opponent has to hit it long. The No.10 picks the moment to hunt the ball.',
    'Opponent builds up from the back',
    'Push their build-up into a wide or long, low-percentage option, then win the ball.',
    NULL, 58, 58, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (10)', 'blocks the central route, recognises the pressing moment and wins his duels'),
    (2, 'Forwards (7/9/11)', 'press together to steer the ball wide or force a long ball')
) AS v(so, role, job);

-- 19. pp.59-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'Ch5 Style of Play / Ch4 Requirements for Wingers and Strikers', 'Squeeze inside, steer play wide',
    'When the opponent has the ball the team narrows (squeezes) to shrink the pitch and pressures on one side; the front three, with the No.10, block the central route.',
    'Opponent in possession in build-up',
    'Force the ball to a flank or into a long ball, deny the forward pass and step up through the middle to press.',
    NULL, 59, 63, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front three + No.10', 'Angle runs so the build-up goes to the touchline, or force the long ball'),
    (2, 'Striker (9)', 'Pick the moment to hunt the ball'),
    (3, 'Wingers (7, 11)', 'Know how far to tuck in toward the ball side'),
    (4, 'Whole team', 'Push inside and cover a teammate; push up through the centre')
) AS v(so, role, job);

-- 20. pp.63-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch5 Style of Play / Ch6 Positional Roles when Building Up Play', 'Make the pitch big in possession',
    'In build-up every line spreads out: centre backs split, full backs high, three midfielders as link players between lines, wingers on the touchline and striker as high as possible to pin the back line.',
    'Team gains settled possession at the back',
    'Stretch the opponent so gaps open between their players for forward passes.',
    NULL, 63, 67, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (4, 5)', 'Split wide apart'),
    (2, 'Full backs (2, 3)', 'Take advanced positions'),
    (3, 'Midfielders (6, 8, 10)', 'Sit between defence and forwards as link players'),
    (4, 'Wingers (7, 11)', 'Hug the touchline'),
    (5, 'Striker (9)', 'Stay as deep in their half as possible, dragging defenders back')
) AS v(so, role, job);

-- 21. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 Building Up Play', 'Build-up lasts until someone faces goal',
    'Possession in the opponent half against a deep block is still build-up if the ball carrier has his back to goal; e.g. a winger turned away recycles to the full back on halfway.',
    'Ball carrier cannot face the opponent goal',
    'Keep building (recycle, re-angle) until a player receives facing goal with a chance to create, then switch to attacking.',
    NULL, 66, 66, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (7)', 'With back to goal, play back to the full back rather than force it'),
    (2, 'Full back (2)', 'Offer the safe back option on the halfway line')
) AS v(so, role, job);

-- 22. pp.67-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 The Role of the Defence - Defensive Line''s Positioning', 'Back four never flat in build-up',
    'Full backs push higher than the centre backs, taking the opposing wingers with them; the centre backs drop and pull wide to take the goalkeeper''s pass. A lone striker cannot cover both, so one is free. With one centre back dropping deeper, the striker may follow and free the other.',
    'Goal kick / keeper in possession, opponent with one striker',
    'Create triangles and a free centre back to start the forward play.',
    NULL, 67, 68, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (2, 3)', 'Push high to drag the opposing wingers away'),
    (2, 'Centre backs (4, 5)', 'Drop and split wide to receive from the keeper'),
    (3, 'Goalkeeper', 'Find the centre back the striker cannot cover'),
    (4, 'One centre back', 'Step up through the centre when space appears')
) AS v(so, role, job);

-- 23. pp.68-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 Receiving with the Correct Body Shape, Communication and Accurate Passing', 'Open body shape, recycle to better angle',
    'A full back who controls with his sideline foot is limited to a pass down the line. Players receive with posture angled toward the next pass; if options are poor they go back inside (e.g. to the centre back) who has a better forward angle. Passes go to the receiver''s free side (away from his marker).',
    'Pass arriving in build-up',
    'Receive ready to play forward at once and keep possession by switching to the player with more options.',
    NULL, 68, 69, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (2)', 'Open up; if limited, pass back inside to the centre back'),
    (2, 'Centre back (5)', 'Play the forward pass from the better position'),
    (3, 'Passer', 'Aim to the side of the striker away from his marker; talk to the receiver')
) AS v(so, role, job);

-- 24. pp.69-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 The Role of the Midfield - Creating Space for the Centre Back to Push Forward into Midfield (1)', 'Six drops, eight clears, CB steps in',
    'One central midfielder drops to form a triangle with the two centre backs while the other runs forward taking his marker, leaving the middle free. Works when the opposing forwards are pressing high; against a deep block midfield is too congested.',
    'Opponent forwards pressing, midfielders marked',
    'Centre back steps into the vacated midfield space and receives, giving a numerical advantage in midfield.',
    NULL, 69, 70, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (6)', 'Drop to receive from the centre back (4)'),
    (2, 'Central midfielder (8)', 'Push up and take his direct marker away'),
    (3, 'Centre back (5)', 'Move into the freed space and take the pass from 6')
) AS v(so, role, job);

-- 25. pp.71-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 Creating Space for the Centre Back to Push Forward into Midfield (2)', 'Far CB steps up from FB''s ball',
    'With the left back on the ball, No.8 pushes forward with his marker. The opposition striker is occupied with the near centre back, so the far centre back moves up into central midfield.',
    'Full back in possession, striker on the other centre back',
    'Centre back receives in lots of space in the centre; forwards anticipate the next pass into a 1v1 up front.',
    NULL, 71, 71, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (3)', 'Play the diagonal into the stepping centre back'),
    (2, 'Central midfielder (8)', 'Push on and drag his man'),
    (3, 'Centre back (4)', 'Advance into midfield to receive'),
    (4, 'Forwards', 'Read it early and move for the next pass')
) AS v(so, role, job);

-- 26. pp.72-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 Creating Space for the Centre Back to Push Forward into Midfield (3) and (4)', 'CB dribbles into midfield, rest balances',
    'A centre midfielder moves wide and his marker follows, so the centre back carries the ball into midfield (or arrives without it). Nos.8 and 10 create space ahead; the other centre back and both full backs hold cover and balance. Centre backs alternate this role rather than one man all season; prefer a centre back to a full back for the step-up because full backs are tightly tracked.',
    'Central lane emptied by a midfielder''s movement',
    'Gain an extra man in midfield through the stepping centre back while the back line stays secure.',
    NULL, 72, 73, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (6)', 'Drift wide to pull his marker away'),
    (2, 'Centre back (4)', 'Recognise the moment and dribble forward into midfield'),
    (3, 'Nos. 8 and 10', 'Move away to open passing room'),
    (4, 'CB 5, full backs 2 and 3', 'Stay back as cover and balance')
) AS v(so, role, job);

-- 27. pp.74-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 The Role of the Attack - Creating a 1v1 Situation in the Front Line', 'Midfield overload frees striker 1v1',
    'With the centre back on the ball in midfield the opposition must commit a man (e.g. their 10) to close him, which leaves the striker isolated 1v1 with a defender.',
    'Opponent midfielder steps out to the advancing centre back',
    'Pass quickly to the striker in his 1v1 so he can turn, shield or set up.',
    NULL, 74, 74, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (4)', 'Carry into midfield and draw a presser'),
    (2, 'Striker (9)', 'Stay advanced as target man, move to be free in the 1v1'),
    (3, 'No.10 / 8', 'Create space by moving off'),
    (4, 'Full back (2)', 'Cover and balance')
) AS v(so, role, job);

-- 28. pp.75-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 Using the Striker as a Target Man', 'Striker checks off and receives angled',
    'When man-marked, the striker first moves away from his marker and then drops at an angle to take the pass from the stepping centre back, ideally with room to turn into a 1v1.',
    'Centre back with the ball in midfield, striker tightly marked',
    'Get the ball into the striker to start chances with support and runs behind; if still tightly marked he simply keeps it for the team.',
    NULL, 75, 75, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'Check away, then drop at an angle to receive'),
    (2, 'Centre back (5)', 'Find the striker when he comes free'),
    (3, 'Supporting players', 'Follow up and run beyond the back line')
) AS v(so, role, job);

-- 29. pp.76-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 Wingers Getting in Position to Receive the Ball', 'Wingers hold width, drop late',
    'Even when there is a 1v1 up front, wingers stay wide during build-up instead of drifting inside early. They drop back at the right moment to take the pass out wide, with heels on the touchline, facing their full back; coming inside is allowed only later.',
    'Central midfielder or centre back on the ball',
    'Keep the opponent stretched so there is more time and space for the attack later.',
    NULL, 76, 77, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (7, 11)', 'Stay on the line; time the drop to receive'),
    (2, 'Central midfielder / centre back', 'Play the ball out wide at the right moment')
) AS v(so, role, job);

-- 30. pp.77-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 Building Up Play: Key Points', 'Check away before receiving',
    'Attackers repeatedly make a move away from their marker first (e.g. walk offside) and then a second movement toward the ball, instead of standing near the ball and shrinking the space.',
    'Teammate about to pass',
    'Create a yard of space for yourself before the ball arrives.',
    NULL, 77, 77, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers and striker', 'Make a decoy run, then show at the right moment'),
    (2, 'Any receiver', 'Avoid coming too early; move away again if not found')
) AS v(so, role, job);

-- 31. pp.77-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 Building Up Play: Key Points / practices 82-85', 'Depth before width: forward pass first',
    'Build-up has a goal: if a forward pass is on, play it; sideways or back passes are only preparation for a forward one. The cue to go forward is the moment a defender closes the ball carrier. Everyone, defenders included, should dare to ask for the ball and try individual solutions.',
    'A defender commits pressure on the ball',
    'Break lines and progress quickly instead of possession for its own sake.',
    NULL, 77, 85, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Look forward first; play forward when pressed'),
    (2, 'Midfielders between lines', 'Check before moving to receive and lose the marker'),
    (3, 'Back line', 'Recycle only to set up the next forward pass')
) AS v(so, role, job);

-- 32. pp.78-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'to_defend', 'Ch6 Practice: Receive and Pass in 5v2 Zones', 'Close space immediately on loss',
    'When a team loses the ball it at once squeezes the space and blocks the pass to the other zone; the defending pair works together to cut passing angles.',
    'Ball lost',
    'Win the ball back straight away and prevent the escape pass.',
    NULL, 78, 79, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players', 'Close the ball carrier immediately'),
    (2, 'Defending pair', 'Shut passing angles together, make the space small')
) AS v(so, role, job);

-- 33. pp.86-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 Practices: Passing Direct from the Centre Back to the Striker (1), (2) and in SSGs', 'CB splits lines into striker',
    'Centre backs look for the moment the lane to the striker opens; the striker checks away from the back of his defender and seeks eye contact. If the lane is shut, the team keeps the pitch big and circulates fast, with full backs dropping early enough to open their bodies. After the pass the passer or the other centre back joins in to create a 2v1.',
    'Lane to the striker opens and eye contact is made',
    'Skip midfield with a firm ground pass to the striker''s free side and support him at once.',
    NULL, 86, 92, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (4, 5)', 'Control to look forward; pass hard along the ground to the striker''s free side'),
    (2, 'Striker (9)', 'Check away from the defender, time the call, do not come short too early'),
    (3, 'Full backs (2, 3)', 'Drop in time to give a turned-open option'),
    (4, 'Other centre back / passer', 'Push on after the pass to make a 2v1'),
    (5, 'Defending team', 'Make the pitch small, play offside or press collectively')
) AS v(so, role, job);

-- 34. pp.92-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 Practices: Goalkeeper''s Short & Long Distribution / Build-up from the Goalkeeper', 'Keeper as free man, short or long',
    'The keeper takes part as the extra player in build-up and chooses between a short pass to a free defender and a long ball to the most advanced open teammate; if the wingers are tightly marked he plays short, if they are free he goes long. Outfield players move to create space for him.',
    'Keeper in possession; one presser closes him after a back pass',
    'Start the attack through the most advanced free player as fast as possible.',
    NULL, 92, 96, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Read the press; short to free defender or long to free forward'),
    (2, 'Defenders', 'Move to create room to receive'),
    (3, 'Wingers', 'Get free of markers to invite the long ball')
) AS v(so, role, job);

-- 35. pp.94-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'to_attack', 'Ch6 Practice: Goalkeeper''s Distribution after Defending a Set Piece', 'Counter after claiming a cross',
    'After the keeper catches a cross (or a defender clears with purpose), he quickly throws/rolls to a winger left up for the counter while the rest sprint forward in support.',
    'Keeper claims the cross from a set piece',
    'Launch a fast counter before the opponent''s set-piece attackers recover.',
    NULL, 94, 94, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Roll short if wingers marked, throw/kick long if they are free'),
    (2, 'Wingers', 'Stay up and lose their markers'),
    (3, 'Defenders who cleared', 'Sprint forward to support')
) AS v(so, role, job);

-- 36. pp.96-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 Practices: Build-up Directly to the Forwards / Moving the Ball Forward from the Back', 'Defender steps up to equalise numbers',
    'Centre backs drop deep so the full backs can push high and wide; once the ball is played into the forwards (or space opens ahead) one defender passes or dribbles into the attacking half to turn 3v4 into 4v4. If the striker is marked and there is room ahead, a defender dribbles forward himself.',
    'Ball reaches the front line or space appears ahead of a defender',
    'Add a man to the attack quickly with high tempo and eye contact with the forwards.',
    NULL, 96, 98, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Drop deep to free the full backs'),
    (2, 'Full backs', 'Push forward and wide'),
    (3, 'One defender', 'Carry or pass into the attacking half to join'),
    (4, 'Forwards', 'Show for the pass at the moment the line opens')
) AS v(so, role, job);

-- 37. pp.99-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch6 Practice: Connecting the Full Backs with the Front Line', 'Full back connects with front three',
    'Full back controls ready to play, looking first to the striker. Pass to a forward''s feet only if he can turn; if the forward runs diagonally inside off the line, pass into the space ahead; never to the feet of a tightly marked winger near the touchline. If no early pass is on, beat the oncoming opponent and dribble into space to create a 2v1. A forward dropping into midfield can release the full back''s forward run.',
    'Full back receives in build-up',
    'Link full backs directly with wingers and striker to attack 4v4 in the final zones.',
    NULL, 99, 100, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (2, 3)', 'Play early, precise ground passes into feet or space; else cut past and dribble'),
    (2, 'Striker (9)', 'Stay advanced, move to the side, run behind, shield or one-touch'),
    (3, 'Wingers (7, 11)', 'Start deep and diagonal inside, check off, receive on the half-turn')
) AS v(so, role, job);

-- 38. pp.103-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch7 Attacking and Creating Opportunities / Positional Play in the Attacking Phase', 'Facing goal: pass in behind',
    'The attack begins once a player with the ball faces goal and can create, usually in the opponent half after breaking a high press. Positional play aims for a midfield overload or a 1v1 up front; then a pass goes behind the back line for an attacker.',
    'Ball carrier faces goal with an open player ahead',
    'Put a forward through on goal; final-third chances come from individual play, one-twos, wing play and a good final ball.',
    NULL, 103, 104, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (6)', 'Find the No.10 between lines'),
    (2, 'No.10', 'Turn and slip the pass behind the line'),
    (3, 'Striker (9)', 'Run in behind to receive and finish'),
    (4, 'Full backs', 'Join the attack when they receive')
) AS v(so, role, job);

-- 39. pp.105-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch7 The Role of the Defence - The Centre Back Pushes Up', 'Stepping CB: final pass or join',
    'A centre back who has pushed into midfield either plays the final pass to a forward in a good position (possible even from deep against a high press) or, if barely pressed, carries on or plays a one-two to join the attack. The No.10 moves the other way to clear space for the return.',
    'Centre back on the ball in midfield with little pressure',
    'Use the extra man from the back to create the decisive pass or overload.',
    NULL, 105, 105, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (4)', 'Pick final pass or dribble / one-two forward'),
    (2, 'No.10', 'Move away from the ball to open space, then give the return'),
    (3, 'Striker (9)', 'Offer the target for the final pass')
) AS v(so, role, job);

-- 40. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch7 The Full Back Receives Unmarked and Carries the Ball Forward', 'Free full back carries forward',
    'A full back who receives unmarked with space ahead (or after an interception) attacks it with a dribble, combination or pass and is free to take on a 1v1.',
    'Full back free with open space in front',
    'Add a runner from the back and drive the attack forward.',
    NULL, 106, 106, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (3)', 'Dribble into space, combine or beat his man'),
    (2, 'Winger ahead', 'Clear the lane or offer the combination')
) AS v(so, role, job);

-- 41. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch7 The Defence Push Forward when the Other Players Attack', 'Back line squeezes up behind attack',
    'When the forwards attack in the opponent half, the defenders and goalkeeper push up to close the gap instead of watching.',
    'Team attacking in the opponent half',
    'Keep the team compact and ready to win second balls or defend a loss.',
    NULL, 106, 106, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'Push forward to shorten the distance to midfield'),
    (2, 'Goalkeeper', 'Advance and organise the line (coach may make him responsible)')
) AS v(so, role, job);

-- 42. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch7 Midfield Passing: Pass in Behind on the Flank', 'Winger checks, runs behind full back',
    'The winger checks toward the ball and then sprints behind the opposing full back; the central midfielder plays the through ball high up the flank.',
    'Midfielder facing forward, full back tight on winger',
    'Get the winger in behind the defensive line on the flank.',
    NULL, 107, 107, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (7)', 'Check back, then run in behind'),
    (2, 'Central midfielder (6)', 'Play the deep pass into the channel')
) AS v(so, role, job);

-- 43. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'to_attack', 'Ch7 Midfield Passing: Combination Play with the Forwards', 'Midfielder links with forwards on regain',
    'Especially just after winning the ball, a central midfielder advances and combines with the striker or wingers, who are often in 1v1s, then plays a winger in behind.',
    'Ball just won in midfield',
    'Work the ball behind the back line quickly for a scoring chance.',
    NULL, 107, 107, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (8)', 'Step up and combine with 9'),
    (2, 'Striker (9)', 'Lay off to the advancing midfielder'),
    (3, 'Wingers (7, 11)', 'Run in behind for the final pass')
) AS v(so, role, job);

-- 44. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch7 Midfield Passing: Through Pass Options', 'No.10 chooses dribble or through ball',
    'A midfielder on the ball between lines is an immediate threat: he either beats his man himself or picks one of several through-ball lanes to runners.',
    'No.10 receives facing goal',
    'Create a scoring chance through individual play or a through pass.',
    NULL, 108, 108, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'Choose dribble or through ball to the best run'),
    (2, 'Wingers and striker', 'Offer different runs in behind')
) AS v(so, role, job);

-- 45. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch7 Midfield Passing: Well Timed Pass for No.10''s Advanced Run', 'Forwards split, No.10 runs through gap',
    'A central midfielder has the ball facing goal; the winger and striker move in opposite directions dragging their markers, and the No.10 makes a diagonal run into the gap they leave.',
    'No.8 in possession with head up',
    'Find the arriving No.10 in space behind or between defenders.',
    NULL, 108, 108, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (11) and striker (9)', 'Move apart, taking defenders with them'),
    (2, 'No.10', 'Time a diagonal run into the space'),
    (3, 'Central midfielder (8)', 'Release the pass on the run')
) AS v(so, role, job);

-- 46. pp.109-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch7 Midfield Passing: Well Timed Pass for Central Midfielder''s Run from Deep', 'Deep midfielder arrives into created space',
    'The No.10 holds the ball centrally; the winger drops and the striker drifts aside, both pulling markers away, and a deep central midfielder bursts forward into the vacated space.',
    'No.10 on the ball, space opened by forwards'' movement',
    'Late run from deep receives in a dangerous position; timing is split-second.',
    NULL, 109, 109, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'Hold and release at the right moment'),
    (2, 'Winger (11)', 'Drop back to drag his man'),
    (3, 'Striker (9)', 'Move across to open the lane'),
    (4, 'Central midfielder (8)', 'Run forward into the space')
) AS v(so, role, job);

-- 47. pp.110-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch7 Winger Crosses from Out Wide / Making the Right Movements in Front of Goal', 'Box occupation for a wide cross',
    'When a winger prepares to cross: striker and No.10 split near and far post (talking so they do not make the same run), a midfielder holds the edge of the box for cut-backs and second balls, the holding midfielder stays behind for balance, and the far winger covers the deep cross. An alternative split: striker near post, No.10 penalty spot, far winger far post.',
    'Winger in a crossing position',
    'Fill the goal area with spread runs and secure the second ball and rest defence.',
    NULL, 110, 115, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9) and No.10', 'Near and far post runs, kept apart'),
    (2, 'Central midfielder (8)', 'Edge of the box for pull-back or second ball'),
    (3, 'Holding midfielder (6)', 'Control the area outside the box; collect clearances, track runners'),
    (4, 'Far winger (11)', 'Attack the deep cross at the back post'),
    (5, 'Crossing winger (7)', 'Deliver with intent, not routine')
) AS v(so, role, job);

-- 48. pp.111-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch7 The Role of the Attack - Wing Play: Coming Short or Running in Behind', 'Winger shows short or spins behind',
    'The three forwards keep their distances so they do not get in each other''s way. A winger either drops to receive on the flank (keep it or turn and attack), or, if his full back marks tightly, fakes a short burst then sprints in behind; if not marked tightly he fakes the run and drops into space.',
    'Team in possession, winger marked by the full back',
    'Get the winger on the ball with time or in behind the full back.',
    NULL, 111, 111, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (7)', 'Feint short then run long (or the reverse) depending on the marking'),
    (2, 'Central midfielder (6)', 'Play to feet or into the space behind'),
    (3, 'Front three', 'Keep spacing between each other')
) AS v(so, role, job);

-- 49. pp.112-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch7 Wing Play: Individual Play (Outside/Inside)', 'Winger 1v1, read the full back',
    'A winger receiving near the line against his full back feints and goes inside or outside depending on the defender''s body shape and position, then passes behind, crosses or shoots. Coaches encourage and praise the attempt.',
    'Winger isolated 1v1 with the full back',
    'Beat the man to create a scoring chance.',
    NULL, 112, 112, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (7)', 'Feint one way, go the other, choose from the defender''s shape'),
    (2, 'Central midfielder (6)', 'Feed the winger early near the touchline')
) AS v(so, role, job);

-- 50. pp.113-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch7 Wing Play: One-Two Combinations', 'Winger drops, one-two, spins behind',
    'The winger drops to make an angle and draws the opposing full back with him, lays it first time inside to a central midfielder who has moved across, then turns and runs into the space behind the full back to take the return.',
    'Centre back passes to the winger near the line, full back follows',
    'Winger receives in behind the defensive line in a dangerous position.',
    NULL, 113, 113, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (11)', 'Drop, play first-time inside, spin in behind'),
    (2, 'Central midfielder (8)', 'Move across and return first time into space'),
    (3, 'Centre back (4)', 'Start the move with the pass to the winger')
) AS v(so, role, job);

-- 51. pp.114-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch7 Midfielder and Striker Combine (Providing a Final Pass or Cross)', 'Striker drags marker, No.10 runs',
    'With the deep midfielder on the ball, the striker comes toward it pulling his centre back with him, and the No.10 runs into the space behind. If the marker does not follow, the striker receives and turns. If the direct lane to No.10 is shut, go via the striker''s lay-off to the advancing No.6 who plays No.10 in.',
    'Holding midfielder in possession facing forward',
    'Release the No.10 in behind or the striker on the turn.',
    NULL, 114, 114, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'Come short to take his marker; turn if left free; lay off first time'),
    (2, 'No.10', 'Run forward into the vacated space'),
    (3, 'Holding midfielder (6)', 'Pass direct or play the wall pass with 9 and then feed 10')
) AS v(so, role, job);

-- 52. pp.115-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Ch7 Midfielder and Striker Combine with a Third Man Run', 'Third-man run by striker',
    'As the holding midfielder''s pass travels to the No.10, the striker makes a horizontal run across his marker; the No.10 plays it first time into the run.',
    'Pass played into the No.10',
    'Striker escapes his marker and attacks goal.',
    NULL, 115, 115, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (6)', 'Play into the No.10'),
    (2, 'No.10', 'First-time pass into the striker''s run'),
    (3, 'Striker (9)', 'Time a lateral run off his marker to receive on the move')
) AS v(so, role, job);

-- 53. pp.117-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Attacking Training Practices - Individual Play and One-Two Combinations', 'Beat your man or one-two past him',
    'An attacker faces one defender with a teammate close by out wide or ahead; he either takes the defender on or uses the teammate for a quick wall pass and receives behind.',
    'Defender confronts the dribbler / commits to the ball',
    'Get past the direct opponent at pace and into space behind him.',
    NULL, 117, 131, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Dribble at pace toward one side to make the defender commit, feint or pass at the right distance (not too far, not too close)'),
    (2, 'Support player (wide or ahead)', 'Stay close enough to give a real one-two option, return first time'),
    (3, 'Ball carrier after passing', 'Accelerate past the defender at once and take the return with a directional first touch'),
    (4, 'Second attacker in 2v2', 'Use the drag-to-one-side to create space for a decisive action on the other side')
) AS v(so, role, job);

-- 54. pp.120-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Attacking Training Practices - Escape from Defender + Score 1 v 1 versus the Goalkeeper', 'Shake the marker, finish 1v1 vs keeper',
    'A forward receives with a defender closing, escapes him, and is alone against the goalkeeper; too many such chances are wasted by poor decisions.',
    'Forward clear of his marker with only the keeper to beat',
    'Convert the 1v1 against the goalkeeper under pressure.',
    NULL, 120, 121, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Shield the ball from the chasing defender with the body'),
    (2, 'Forward with space behind keeper', 'Keep pace and dribble round the goalkeeper'),
    (3, 'Forward with keeper approaching close', 'Shoot hard and high, slip it through his legs, or chip after a fake'),
    (4, 'Forward with keeper far away', 'Strike hard and low into the corner')
) AS v(so, role, job);

-- 55. pp.122-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Movement With and Without the Ball (A): Call for Ball to Feet + Run Forward into Space', 'Show to feet, then spin in behind',
    'A winger or forward who is tightly marked has space behind him; he fakes coming short for the ball, drags the defender in, then sprints into the space beyond.',
    'Forward marked closely with space in front of him',
    'Lose the marker and receive a timed pass running into space.',
    NULL, 122, 122, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger / forward', 'Fake movement toward the ball, lure the marker, then sprint inside or down the line and call for it now'),
    (2, 'Passer (defender or midfielder)', 'Time and weight the ball into the run so the receiver keeps his speed'),
    (3, 'Receiver', 'Directional first touch toward goal at full pace')
) AS v(so, role, job);

-- 56. pp.123-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Movement With and Without the Ball (B): Receive, Feint + Dribble Past Defender', 'Loosely marked: receive, feint, go',
    'The forward''s marker stands off, so a run in behind will not surprise him; the forward threatens deep, comes to feet and takes the defender on.',
    'Defender standing off the forward',
    'Beat the defender with a move on the half-turn and break away.',
    NULL, 123, 123, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Threaten the deep run, then call for it to feet and take a forward touch at pace'),
    (2, 'Forward on the ball', 'Keep it close as the defender arrives; feint one way and go the other at the right moment'),
    (3, 'Passer', 'Play into feet early so the forward can turn forward')
) AS v(so, role, job);

-- 57. pp.124-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Movement With and Without the Ball (C): Receive + One-Two Combination with Curved Run', 'Lay off first time, curve run behind',
    'The forward is loosely marked but the defender is alert and jumps in as soon as the ball arrives; the forward lays it back first time and bends a run into the space the defender left.',
    'Defender closing in fast on the first pass',
    'Use the defender''s aggression to release the forward in behind.',
    NULL, 124, 124, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'One-touch set back that the defender cannot intercept, then curved run behind him'),
    (2, 'Supporting teammate (defender/midfielder)', 'Play first time into the space before the defender can recover the line'),
    (3, 'Forward on receiving', 'Keep the pace and take the first touch toward goal')
) AS v(so, role, job);

-- 58. pp.125-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Movement With and Without the Ball (D): Drop Deep to Receive + One-Two Combination', 'Drop with marker, wall pass, spin',
    'Forward and his marker both start high; the forward drops toward a teammate with the marker tight behind him, plays a one-touch wall pass and turns away into the space.',
    'Marker follows the dropping forward closely',
    'Release the forward behind his marker with the return pass.',
    NULL, 125, 125, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Drop off, call to feet, play a first-time inside-foot pass back, then sprint away into space'),
    (2, 'Teammate receiving in space', 'Play the return in front of the forward so he can run onto it')
) AS v(so, role, job);

-- 59. pp.126-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Movement (E) / Receiving with Back to Goal, Turning and Finishing in a 1 v 1', 'Back to goal: hold, feel, turn, finish',
    'A forward receives near the box with a defender behind him; he holds the ball, reads where the defender is and turns past him to finish.',
    'Defender too tight, too square or too eager to nick it from behind',
    'Create space with the back to goal, turn and get a shot off.',
    NULL, 126, 128, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Signal where you want the ball, shield it, keep it moving so the defender has to reposition'),
    (2, 'Forward', 'Use the arm to feel the defender and as a pivot; turn the moment he is close, still or leaning'),
    (3, 'Forward after turning', 'Accelerate forward and finish if the path is free, with either foot'),
    (4, 'Passer', 'Feed into the forward''s back foot side so he keeps his body between ball and defender')
) AS v(so, role, job);

-- 60. pp.129-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Creating Opportunities with the Striker''s Back to Goal (2 v 2 / 3 v 2)', 'Target striker: lay off, turn, or release',
    'The striker receives with his back to goal from a midfielder or winger while a second defender recovers; he must choose quickly between setting back, turning, or feeding a wide runner.',
    'Pass into the striker''s feet with a defender on his back',
    'Turn the striker''s hold-up into a goal chance with joining runners.',
    NULL, 129, 130, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'First-time set back to the player in his eye-line, then make himself available again; turn when defender is wrongly placed'),
    (2, 'Supporting passer', 'Pass so the striker can protect the ball, then join the attack staying in his eye-line'),
    (3, 'Wingers (3v2)', 'One stays in the striker''s eye-line as an outlet, the other makes an advanced run to finish'),
    (4, 'Striker', 'Watch for the offside trap when the defender steps up to contest')
) AS v(so, role, job);

-- 61. pp.132-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'to_attack', 'Exploiting a Numerical Advantage in a 3 Team Transition Game', 'Finish off the 3v2 overload',
    'An attack or counter gives one extra attacker (3v2) but chances are wasted; the team must play fast, use the overlap and time the last pass.',
    'Ball won or received with an extra attacker against the back line',
    'Turn a numerical advantage into a goal before defenders recover.',
    NULL, 132, 133, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Keep speed, no unnecessary passes; carry immediately if space ahead after an interception'),
    (2, 'Overlapping attacker', 'Run around the defender; ball arrives at the moment that beats defenders and offside line'),
    (3, 'Third attacker', 'Read it and arrive in front of goal to finish; follow shots for rebounds'),
    (4, 'Teammates on a counter', 'Run quickly into positions to receive in the final stage; pass and sprint if pressed at once')
) AS v(so, role, job);

-- 62. pp.134-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Duels in and Around the Penalty Area to Create Scoring Opportunities (3 v 3)', 'Front three duels and combinations',
    'Striker and two wingers versus three defenders near the box; the aim is to isolate a teammate 1v1 and use runs in front of goal.',
    'Ball played into the striker or a winger near the box',
    'Create 1v1s or 2v1s for the front three and finish.',
    NULL, 134, 135, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'Choose between setting back for a shooter, playing in behind, or turning to shoot'),
    (2, 'Winger facing goal on the touchline', 'Play inside to the forward and keep running to get it back behind'),
    (3, 'Winger', 'Show back to the striker when he has his back to goal; go behind if marked tightly; feint inside/outside with the run'),
    (4, 'Forward in front of goal', 'Attack the box on time between keeper and defender, or pull back behind the defender')
) AS v(so, role, job);

-- 63. pp.136-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Creating Scoring Opportunities from the Flank (6 v 4 / 6 v 6 / 8 v 8 / Corner Zone Games)', 'Isolate the winger, beat him, cross',
    'The team builds from the centre back through midfield and finds a winger high and wide, who beats his full back 1v1 and crosses for coordinated runners; if one side clogs, switch.',
    'Winger receives in wide zone with space before the full back',
    'Create crossing chances from 1v1 wins on the flank.',
    NULL, 136, 141, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back / central midfielders', 'Circulate quickly and play the ball out to the winger; switch quickly if an area becomes congested'),
    (2, 'Winger', 'Counter-move before receiving (go then come, or come then go), beat the defender outside and cross, or feint and run behind'),
    (3, 'Striker / opposite winger / midfielders', 'Make coordinated runs into the box: near post, far post, behind the defender'),
    (4, 'Passer to winger', 'Make the ball in behind unpredictable')
) AS v(so, role, job);

-- 64. pp.138-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Retaining Possession & Attacking on the Flank after a Long Pass from the Goalkeeper in a SSG', 'Keeper long to winger or short via midfield',
    'From the goalkeeper the team either goes long to a free winger or short to a central midfielder who then finds the flank, then keeps the ball and attacks wide (vs a 3-3 defending shape).',
    'Goalkeeper in possession; winger free or midfielder open',
    'Secure possession from the goal kick and turn it into a flank attack.',
    NULL, 138, 138, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Go long to the winger if space; high ball to a player strong in the air, precise ball into space/feet for a technical one'),
    (2, 'Central midfielders (6/8)', 'Offer short; on receiving play out to the flank'),
    (3, 'Winger', 'Win/control the long ball and attack the flank')
) AS v(so, role, job);

-- 65. pp.139-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Coordinated Movements and Finishing from Crosses in a 2 Zone Game', 'Box runs on the cross',
    'Before a cross (open play or set piece) the attackers occupy the key areas at once: near post, far post, penalty spot, and a player waiting on the edge for the drop.',
    'Wide player about to deliver',
    'Fill every scoring zone so any decent delivery finds a finisher.',
    NULL, 139, 139, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'Attack the near post'),
    (2, 'Far-side winger', 'Attack the far post'),
    (3, 'Attacking midfielder', 'Arrive around the penalty spot'),
    (4, 'Central midfielder', 'Hold at the edge of the area for knock-downs and cover')
) AS v(so, role, job);

-- 66. pp.142-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Combination Play Between the Midfield and Attack in a 6 v 4 (+GK) Game', 'Midfield-attack combinations with overloads',
    'Two central midfielders face one, wingers are 1v1 with full backs and striker plus No.10 are 2v1 against a centre back; a forward drops for the ball and the other forward runs behind.',
    'Forward pass into the striker or No.10 showing for it',
    'Exploit the central overload with an early final pass into space.',
    NULL, 142, 142, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Find the striker or No.10, then support; arrive as the third man on the lay-off'),
    (2, 'No.10 / striker', 'One comes to feet and lays into a runner''s path, the other runs behind to receive and shoot'),
    (3, 'Wingers', 'Make supporting runs and offer passes behind the line'),
    (4, 'Forwards', 'Always read the defender''s position; play the last pass early')
) AS v(so, role, job);

-- 67. pp.143-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Positional Play / Striker Drops / Forward Play: Coordinated Movements (6 v 5, 7 v 7)', '9 drops, 10 runs beyond, switch',
    'The striker drops deep (into a free pocket in front of the centre back) and plays first time to a midfielder; the No.10 runs into the space he vacated, the ball is switched to the far winger who beats his man and crosses into prepared runs.',
    'Striker drops and draws his centre back or receives in the pocket',
    'Use the striker''s drop to free space for the No.10 and switch play to an isolated winger.',
    NULL, 143, 145, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (5)', 'Find the winger who has pushed on and checked back'),
    (2, 'Striker (9)', 'Keep eye contact with the passer, pick the moment to drop, play first time back into a midfielder''s path'),
    (3, 'No.10', 'Run beyond into the space the 9 left; then show short again to receive'),
    (4, 'Central midfielder (8)', 'Switch to the far winger, then fill the edge of the box'),
    (5, 'Far winger (7) / near winger (11)', 'Beat the defender and cross / attack the far post')
) AS v(so, role, job);

-- 68. pp.146-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Build Up Play and Attacking the Space in the Opposition Half in a 7 v 6 (+GK) Game', 'Patient build-up, then pass into space',
    'The team keeps the ball in a tight area in its own half against a 3-3 block, then plays forward into space in the opposition half when a teammate makes a good run; everyone moves up behind it.',
    'Space opens behind the opposing midfield and a teammate runs into it',
    'Break the block with the forward pass and attack with the whole team.',
    NULL, 146, 146, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back / midfielders', 'Retain patiently in limited space; play forward only when space and a run exist'),
    (2, 'Forwards and wingers', 'Time runs into the space in the opposition half'),
    (3, 'Whole team', 'Push into the opposition half after the forward pass to support the attack')
) AS v(so, role, job);

-- 69. pp.147-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'in_possession', 'Exploiting Space in Behind the Opposition''s Defence in an 8 v 8 Small Sided Game', 'Through ball behind the back line',
    'A 3-1-3 team circulates quickly to free the striker and plays a through ball into space behind a back four; the receiver times his run and crosses or finishes.',
    'Forward''s run behind the defensive line timed with the passer',
    'Get in behind the defence and finish, often with a cross to the far post.',
    NULL, 147, 147, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders / centre back', 'Quick ball circulation and combinations to set the striker free; play the pass in behind'),
    (2, 'Forward or winger', 'Time the run to receive behind the line'),
    (3, 'Far winger', 'Attack the back post for the cross'),
    (4, 'Any player regaining the ball', 'Play forward behind the defensive line into space as fast as possible')
) AS v(so, role, job);

-- 70. pp.149-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'Defending - Positional Play in the Defensive Phase / Basic Defensive Tactical Principles of the 4-3-3', 'Whole team defends, from the front',
    'Whether pressing high or sitting compact in their own half, the whole team defends collectively starting with the forwards (attack, midfield, defence), making the pitch small.',
    'Opponent has the ball',
    'Win the ball back collectively and deny time and space in the final third.',
    '4-3-3', 149, 150, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Start the defending; first line of pressure'),
    (2, 'Midfielders', 'Collective reaction when a teammate is beaten in a duel: cover and recover shape'),
    (3, 'Whole team', 'Squeeze the pitch small, push up in the centre')
) AS v(so, role, job);

-- 71. pp.150-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'to_attack', 'Basic Defensive Tactical Principles - Look to Play a Combination with a Winger or Striker', 'Regain: find the forwards for 1v1s',
    'After winning the ball in the defensive phase, play forward fast while the opponent is disorganised; forwards are usually 1v1, so midfielders link with them to exploit those duels high up.',
    'Ball won in the defensive phase',
    'Exploit the forwards'' 1v1 situations before the opponent reorganises.',
    '4-3-3', 150, 150, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'Link up quickly with the wingers or striker'),
    (2, 'Wingers (7/11) / striker (9)', 'Take on the 1v1 high up the pitch')
) AS v(so, role, job);

-- 72. pp.150-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'Everybody is Responsible for their Direct Opponent / Players Provide Cover for Each Other', 'Own your man, free centre back covers',
    'In a 4-3-3 mirror every outfield player is matched 1v1 with a direct opponent except one free centre back (the opponent''s lone striker must handle two); players still help and cover teammates.',
    'Opponent in possession with a mirrored shape',
    'Win individual duels across the pitch while the spare defender protects them.',
    '4-3-3', 150, 151, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Every outfield player', 'Win the 1v1 against your direct opponent'),
    (2, 'Free centre back (5)', 'Provide cover behind teammates'),
    (3, 'Nearby teammates', 'Tuck in to cover when a teammate''s man has the ball'),
    (4, 'Striker (9)', 'Learn to defend against two centre backs')
) AS v(so, role, job);

-- 73. pp.152-159
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'The Role of the Forwards - Preventing the Opposition''s Build Up Play / Pressing from the Front with the Forwards', '9 splits the CBs, wingers squeeze',
    'From the opposition goalkeeper the striker blocks the line between the two centre backs (2v1); when one centre back gets the ball the near winger presses him while the far winger tucks in to block the pass back; the No.10 screens the pivot.',
    'Opposition goalkeeper or centre backs start the build-up',
    'Stop the build-up through the centre, force play wide and win it.',
    '4-3-3', 152, 159, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'Run into the gap between the centre backs so they cannot pass to each other; force play wide; do not let them dribble past'),
    (2, 'Ball-side winger', 'Press the centre back; or let the full back open, step diagonally inside to block the long ball to the striker, then press the full back when he receives'),
    (3, 'Far winger', 'Come inside as soon as the striker presses; cover the 9 and 10, block/intercept the pass to the other centre back'),
    (4, 'No.10', 'Stand beside or in front of the opponent''s 6 to deny him; leave him to intercept a pass into their striker; coach the three forwards')
) AS v(so, role, job);

-- 74. pp.153-161
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'Pressing High Up in the Centre / Pressing High to Prevent Opposition''s Build Up (6 v 5, 8 v 8)', 'No.10 jumps, CB steps, keeper sweeps',
    'To press high through the centre the No.10 joins the front line on a centre back, a centre back steps into midfield to keep 3v3 there, and the goalkeeper pushes up as sweeper; pressers use curved runs to show opponents inside.',
    'Keeper plays short to a defender; slow pass; bad pass or heavy touch; weak build-up player on the ball',
    'Win the ball high in the opponent''s half and score from it.',
    '4-3-3', 153, 161, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'Push up to the front line and press a centre back'),
    (2, 'Centre back (5)', 'Step up into midfield to keep the 3v3 there'),
    (3, 'Goalkeeper', 'Push up as sweeper behind the high line'),
    (4, 'Pressing forwards', 'Curved runs and body shape to force the receiver where you want (e.g. winger forces full back inside); do not dive in'),
    (5, 'Others', 'Mark the likely next receivers and push high once play is forced inside')
) AS v(so, role, job);

-- 75. pp.154-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'The Role of the Midfield - Providing Cover and Taking Over Marking while Pressing as a Team', 'CB takes over the advancing No.10',
    'When our No.10 leaves to press a centre back, or an opposing midfielder runs forward, a centre back communicates and takes over marking that midfielder; ball-side midfielder presses, the other two cover inside.',
    'Our No.10 pushes up to press, or opponent''s 10 runs forward / receives',
    'Keep pressure on the ball without leaving a midfielder free.',
    '4-3-3', 154, 162, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'Pick the moment to press a centre back, talking with the striker and centre back; when pressing, stay on the inside of his man'),
    (2, 'Centre back (5)', 'Step forward and take over the opposing No.10; close him down after he receives'),
    (3, 'Ball-side central midfielder (6)', 'Press his opponent hard, even get in front of him'),
    (4, 'Far central midfielder (8)', 'Let his man go and slide inside behind 10 and 6 to cover'),
    (5, 'All three midfielders', 'Follow and win the duel with the direct opponent; avoid needless tackles')
) AS v(so, role, job);

-- 76. pp.155-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'The Role of the Defence - Goalkeeper Plays as a Sweeper', 'Keeper as last defender sweeper',
    'When the opposition has the ball the goalkeeper positions outside or at the edge of the penalty area as the last open defender, ready to deal with balls over the back line.',
    'Opponent in possession / long ball over the defence',
    'Cover the space behind a high line.',
    NULL, 155, 155, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Stand at the edge of the area as sweeper; keep doing it after errors'),
    (2, 'Coach / defenders', 'Back the keeper''s sweeping position rather than pushing him deeper')
) AS v(so, role, job);

-- 77. pp.155-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'The Role of the Defence - Centre Back Defends in Front of the Back-line (Leaving 3 at Back) / Maintaining Positioning in Midfield', 'One CB steps in front, three behind',
    'With one centre back pushed in front of the defence onto their No.10, the remaining three play 1v1 in the back line with the full backs tucking inside; if our No.10 goes very high the centre back steps up to keep a balanced midfield.',
    'Opponent''s No.10 between the lines, or our No.10 pressing very high',
    'Keep midfield balanced and the back line matched 1v1 without losing cover.',
    '4-3-3', 155, 156, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (5)', 'Defend in front of the back line, marking their 10; step up to hold midfield shape when our 10 is advanced'),
    (2, 'Other centre back (4)', 'Hold the last line 1v1'),
    (3, 'Full backs (2/3)', 'Push inside to defend 1v1 and stay connected')
) AS v(so, role, job);

-- 78. pp.156-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'Tactical Principles when Playing Against 2 Forwards (3-4-3 v 4-4-2)', 'Vs two strikers: full backs tuck, 3-4-3',
    'Against a 4-4-2 (diamond) the full backs come inside to mark the two forwards, leaving one centre back free behind or between them, while the other centre back steps in front onto their No.10 - effectively a 3-4-3. A flat back four is the alternative but asks too many decisions of youth full backs.',
    'Opponent plays with two forwards',
    'Mark both strikers with a spare man behind and cover their No.10.',
    '4-4-2', 156, 156, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (2/3)', 'Tuck inside to cover and mark the two forwards (3v2)'),
    (2, 'Centre back (4)', 'Stay free behind the line or in the middle as cover'),
    (3, 'Centre back (5)', 'Play in front of the defence, marking their No.10')
) AS v(so, role, job);

-- 79. pp.163-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'dutch-academy-football-coaching-u14-15-functional-training-tactical-practices-fr'), 'out_of_possession', 'Collective Movement of the Back 4 to Provide Cover & Keep Compact / Pressing and Shifting Across to Provide Cover', 'Back line shifts as a unit',
    'With one centre back stepping out to front their No.10 (or press and force play to one side), the remaining three defenders keep a tight line and slide across together; the ball-side full back closes the winger while the centre back and far full back shift over to cover.',
    'Ball switched or played to a winger',
    'Deny space round or behind the defence, force play back inside and win it collectively.',
    NULL, 163, 166, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back', 'Close the winger, kill his speed, then win the ball; know how far across to go'),
    (2, 'Centre back (4)', 'Shift across; decide whether to duel the striker or hold position and keep him in front'),
    (3, 'Far full back', 'Push inside to cover the centre back; take over the striker if the centre back steps out'),
    (4, 'Centre back (5)', 'Play in front, mark the No.10 or press and force play to one side'),
    (5, 'Goalkeeper', 'Coach the back line (who steps out, how far the full back comes in) and stay alert to cover'),
    (6, 'Defenders after a regain', 'Counter attack quickly')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1983-coaching-book-dutch-academy-u14-15-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
