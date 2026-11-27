-- 2153 📚 Coaching book patterns: "Pep Guardiola - 85 Passing, Rondos (Vol. 2)" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Pep Guardiola - 85 Passing, Rondos, Possession Games & Technical Circuits',
    subtitle    = 'Direct from Pep''s Training Sessions (Vol. 2)',
    author      = 'SoccerTutor.com',
    team        = 'Barcelona, Bayern Munich, Manchester City (Guardiola)',
    method_note = 'Second volume of practices from Guardiola''s sessions at Barcelona, Bayern and Manchester City: warm-ups and technical circuits, passing drills (City lay-offs, Bayern diamonds and third-man runs, Barcelona squares, triangles and Y shapes), rondos, juego de posición games (keep the ball with jokers, group press closing angles, instant counter-press, draw the press then switch long, defend the switch), Man City''s 4-3-3 attack (2-3-2-3 with inverted full backs and four rehearsed patterns) and small- to large-sided games. Patterns are the team behaviours the practices rehearse, in our words; fitness and pure technique are left out. App page 1 is the book''s printed page 1; the contents pages were partly covered by a phone-call screen when captured.'
WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-');

-- 1. pp.14-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Training Warm-up Exercises / Pre-Match Warm-up: 5v2 and 4 v 4 (+3) Rondo', 'Rondo keep-ball using the numerical overload',
    'A small group keeps the ball against fewer pressers in a tight grid; in the 4v4+3 the team on the ball plus three jokers (one at each end, one inside) make 7v4.',
    'Team in possession, defenders outnumbered',
    'Keep the ball by using the spare men on the edges and the inside joker to play around and through the press.',
    NULL, 14, 19, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside players (on the long sides)', 'Hold width, give angles, circulate quickly'),
    (2, 'End jokers', 'Always available as the safe outlet on the team in possession''s side'),
    (3, 'Inside joker', 'Find space between the pressers to split them')
) AS v(so, role, job);

-- 2. pp.19-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'to_defend', 'Manchester City Pre-Match Warm-up, Part 3/5: 4 v 4 (+3) Rondo', 'Instant role switch on turnover',
    'When the pressing team wins the ball in the rondo, the two teams swap roles at once: the winners move to the outside to keep possession, the losers step inside and press immediately.',
    'Ball won or lost',
    'Train both sides of transition: the losing team re-presses straight away while the winning team opens out to secure the ball.',
    NULL, 19, 19, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Team that lost the ball', 'Move inside immediately and press to win it back'),
    (2, 'Team that won the ball', 'Spread to the outside lines and secure possession with the jokers'),
    (3, 'Jokers', 'Switch support to whichever team now has the ball')
) AS v(so, role, job);

-- 3. pp.27-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Speed & Agility Exercises WITH a Ball (1-3); Technical Circuits (7)', 'Double one-two to shoot from distance',
    'A midfielder plays into a team-mate posted at the edge of the box, gets it back, plays a second one-two and receives in front of the defence to shoot from outside the area.',
    'Forward/target player available with back to goal at the box edge',
    'Break through the front of a compact block with quick wall passes and finish from range or after dribbling past the last man.',
    NULL, 27, 44, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Player A)', 'Pass in, move at speed, receive the return and shoot from outside the box'),
    (2, 'Target player at the box edge (Player B)', 'Set the ball back with one touch, then play it in front of the runner')
) AS v(so, role, job);

-- 4. pp.30-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Speed & Agility Exercises WITH a Ball (4-7): Lay-off, Pass Out Wide, Cross and Finish; Switch Play', 'Lay-off, ball out wide, cross with two runners',
    'A central player plays forward to a team-mate who lays it off for him; he then sends the ball wide (or switches it long to the far flank) to a winger running high up the touchline, who crosses while two players make curved runs into the box.',
    'Lay-off received facing play with a winger running in behind on the flank',
    'Move the ball from centre to wing quickly and deliver a cross with at least two attackers arriving in the penalty area.',
    NULL, 30, 33, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Player A)', 'Pass forward, take the lay-off, play out wide or switch long, then run into the box'),
    (2, 'Forward / second midfielder (Player C)', 'Check off, lay the ball back first time, then make a curved run into the area'),
    (3, 'Winger (Player B)', 'Sprint high up the flank to receive, carry forward and cross'),
    (4, 'Second box runner (Player D)', 'Arrive in the area for the far-side finish')
) AS v(so, role, job);

-- 5. pp.38-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Technical Circuits 2-3: Passing, Dribbling and Finishing in a Technical Speed Circuit', 'Dropping midfielder sets the striker; follow in',
    'A player carries the ball forward while two team-mates move to receive; the ball goes into a midfielder (or out wide first) who finds a player dropping deep, who sets a forward stepping off his cone to dribble and shoot, while another runner follows in for any rebound.',
    'Carrier driving forward with options moving to receive',
    'Combine through midfield with a short set from a dropping player and always have a second man following the shot for rebounds.',
    NULL, 38, 39, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier (Player A)', 'Dribble forward, pass in centrally or out wide'),
    (2, 'Wide option (Player B)', 'Sprint into a receiving position; in the variation receives and plays inside'),
    (3, 'Dropping player (Player E)', 'Drop back to set the ball for the forward, then follow in for rebounds'),
    (4, 'Forward (Player D)', 'Move forward off the cone to meet the pass, dribble and shoot')
) AS v(so, role, job);

-- 6. pp.42-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'out_of_possession', 'Technical Circuits 6: Press and Cover Defending in Threes', 'Press and cover in threes',
    'A unit of three defends a ball in front of it: whichever player the ball is played toward steps out quickly to it, and the other two squeeze inside or slide across behind him to cover; when the ball goes back, all three drop back to their line.',
    'Pass played toward one of the three (straight, left or right)',
    'One presses and two cover at once so no gap opens, then the line recovers together on a back pass.',
    NULL, 42, 43, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player nearest the ball', 'Step forward fast to meet the ball (pressure)'),
    (2, 'The two other players', 'Move inside or slide across together to cover behind the presser'),
    (3, 'Whole unit', 'Drop back to starting positions as soon as the ball is played back')
) AS v(so, role, job);

-- 7. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'out_of_possession', 'Technical Circuits - 16. Speed & Agility Circuits with Quick One-Touch Passing and Finishing', 'Press and cover pair shift',
    'Two defenders work as a pair as the ball moves between attackers in front of them.',
    'Pass played to the attacker on one side',
    'The nearest defender closes the receiver while the partner slides across behind him to cover, so there is never a free channel.',
    NULL, 53, 53, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side defender', 'Step out and press the player who receives'),
    (2, 'Second defender', 'Shift across and drop to cover behind the presser'),
    (3, 'Both', 'Swap roles as the ball switches side')
) AS v(so, role, job);

-- 8. pp.55-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Technical Circuits - 18. High Intensity Speed, Power and Agility Training Circuit + 3 v 2 Duel', '3v2 attack using underlap or overlap',
    'Three attackers against two defenders near goal; the extra man comes from behind the ball carrier.',
    'Defenders commit to the ball carrier',
    'A supporting runner goes inside (underlap) or outside (overlap) the carrier to make the 3v2 count and get a shot away.',
    NULL, 55, 55, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Drive at a defender to fix him'),
    (2, 'Supporting attacker', 'Run around the outside or through the inside of the carrier'),
    (3, 'Third attacker', 'Stay wide or arrive for the finish')
) AS v(so, role, job);

-- 9. pp.58-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Manchester City Passing Practices - 3 v 1 + Lay-off, Pass in Behind and Finish in Mini Goal (1, 2)', 'Keep ball, lay off, release runner behind',
    'After keeping the ball in a small 3v1, the most advanced player lays back so a team-mate can play forward into a midfielder who lays off to either support player; that player slides the final ball past the last defender.',
    'Forward player receives with his back to goal',
    'Forward progression via a lay-off so the final pass is played facing play, timed with a forward run in behind.',
    NULL, 58, 59, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Most advanced player in the 3v1', 'Lay the ball back to the open man'),
    (2, 'Receiving midfielder (A)', 'Choose which supporter to lay off to'),
    (3, 'Support players (B/C)', 'Arrive facing forward and play the ball beyond the defender'),
    (4, 'Runner (D)', 'Time the run to finish first time')
) AS v(so, role, job);

-- 10. pp.60-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Manchester City Passing Practices - 3 v 1 + Lay-off, Aerial Pass in Behind and Finish (3, 4, 5)', 'Striker drops, lay-off, chip in behind',
    'A forward drops off to receive a vertical pass and lays it back; the supporter (sometimes after a switch across) chips the ball over the back line for a team-mate who first checked short and then spins in behind.',
    'Forward drops between the lines and receives',
    'Pull a defender out with the drop, then attack the space behind with a short lofted pass and a well-timed run.',
    NULL, 60, 62, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping forward (E)', 'Come short to receive and lay off first time'),
    (2, 'Supporting player (F)', 'Chip the ball into the space behind'),
    (3, 'Wide/far runner (D)', 'Check back first, then sprint in behind to score'),
    (4, 'Variation', 'Pass across or a quick extra combination before the chip to shift the defence')
) AS v(so, role, job);

-- 11. pp.65-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Bayern Munich Passing Practices - 1-4 (Passing Diamond, Double One-Two)', 'Third-man run around the marker',
    'Players show in front of a marker to receive and lay the ball off, then the third man arrives on the run around the defender to receive a pass into his path; done mostly one touch in a diamond.',
    'Ball played into a player in front of his marker',
    'Use bounce passes and timing of movement so the final receiver gets the ball moving forward beyond the marker.',
    NULL, 65, 68, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wall player (B/C)', 'Show in front of the marker, lay off one touch'),
    (2, 'Deep passer (A)', 'Move forward after the return to play the next pass'),
    (3, 'Third man (D)', 'Time the run around the marker to receive on the move'),
    (4, 'All', 'Drop back off the cone to open a passing angle before receiving')
) AS v(so, role, job);

-- 12. pp.69-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Bayern Munich Passing Practices - 5, 6 / FC Barcelona Passing Practices - 10, 11, 12', 'Lay-off for shot from distance',
    'Around the edge of the box, a short combination ends with a lay-off or pass into stride for a player arriving forward who shoots or dribbles at speed and shoots from outside the area.',
    'Ball reaches a player facing away near the box edge',
    'Create a front-on shooting chance from distance by having the shooter arrive onto a set-back pass.',
    NULL, 69, 85, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target player near the box', 'Lay the ball back or across into the shooter''s path'),
    (2, 'Arriving shooter', 'Move forward onto the ball and strike from outside the area'),
    (3, 'Wide player (B)', 'Give a 1-2, then move across to receive and feed the shooter'),
    (4, 'Central player (C)', 'Move off the cone to receive on the run and drive forward')
) AS v(so, role, job);

-- 13. pp.71-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Bayern Munich Passing Practices - 7. Passing Combination Play Around the Penalty Area and Finish', 'Late run onto ball to penalty spot',
    'The ball is worked from one side of the box to a player who drops off the byline area and plays it into the zone around the penalty spot.',
    'Wide player drops back to receive near the box',
    'The original passer, having made a delayed run into the area, arrives on the pass to finish.',
    NULL, 71, 71, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Starting player (A)', 'Pass and make a well-timed run into the box'),
    (2, 'Midfielder (B)', 'Open up at an angle to receive and move it on'),
    (3, 'Wide/deep forward (C)', 'Drop off to receive and play into the penalty spot zone')
) AS v(so, role, job);

-- 14. pp.74-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'FC Barcelona Passing Practices - 1. Opening Up to Receive Passing Square', 'Open up body to receive',
    'Each receiver turns his body open toward the next target before the ball arrives, takes one touch and passes on.',
    'Pass coming to you',
    'Receive on the back foot facing the next pass so play moves on with minimal touches.',
    NULL, 74, 74, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'Open hips toward the next target, one touch to control'),
    (2, 'Passer', 'Play into the receiver''s far foot')
) AS v(so, role, job);

-- 15. pp.75-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'FC Barcelona Passing Practices - 2-6 (Squares, Triangles, Passing Y)', 'One-two then pass into stride',
    'A player gives and gets a 1-2, then passes ahead of the next team-mate who runs onto it; lay-offs bring the next player forward.',
    'Team-mate comes short for a return pass',
    'Keep play moving forward by passing into space in front of a runner rather than to feet.',
    NULL, 75, 79, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Play the 1-2 and move forward onto the return'),
    (2, 'Wall player', 'Return the ball into the passer''s path'),
    (3, 'Next receiver', 'Run around the marker onto a ball played in front of him')
) AS v(so, role, job);

-- 16. pp.80-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'FC Barcelona Passing Practices - 7, 8, 9 (Passing Rectangle)', 'Cross over movement and overlap',
    'Midfielders move across from the opposite side to free themselves to receive, the front player comes short, and a long or aerial ball reaches the far man; the forward then overlaps on the outside to receive again.',
    'Ball at the deep player ready to play forward',
    'Create free receivers through crossing movement and finish with an overlap run on the outside.',
    NULL, 80, 82, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep player (A)', 'Play a ground or aerial pass to the free player'),
    (2, 'Midfielders (B/C)', 'Move across from the opposite cone to receive'),
    (3, 'Front player (D)', 'Move diagonally off his cone, then overlap on the outside')
) AS v(so, role, job);

-- 17. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Rondos - 1. 3 v 1 Ground and Aerial Triangle Rondos', '3v1 triangle rondo, one touch',
    'Three players in a tight triangle keep the ball from one presser, mostly one touch, changing direction often.',
    'Single presser closes the ball',
    'Keep possession by giving the receiver two passing options at all times and moving the ball before the presser arrives.',
    NULL, 88, 88, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside players', 'Hold triangle angles 4-5 yards apart, one touch'),
    (2, 'Middle player', 'Play 1-2s with the outside players before swapping roles'),
    (3, 'Presser', 'Close the ball to force a mistake')
) AS v(so, role, job);

-- 18. pp.89-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Rondos', 'Rondo: play past the presser',
    'Ring of 4-7 players keeps the ball against two pressers inside a small square or rectangle, mostly first time.',
    'A presser closes in on the ball carrier',
    'Draw the presser in, then pass beyond him to the team-mate he has just left free.',
    NULL, 89, 94, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Play one touch, invite the press then pass past it'),
    (2, 'Side players (rectangle)', 'Keep sliding up and down to offer an angle at the ends'),
    (3, 'Two pressers', 'Work as a pair to shut passing angles and win the ball'),
    (4, 'Player who loses it', 'Swaps straight in as a presser')
) AS v(so, role, job);

-- 19. pp.97-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Juego de Posicion (Positional Games)', 'Juego de Posicion core principles',
    'Team keeps a fixed structure with players in set zones, ball position deciding where each one stands and how far apart.',
    'Any phase of possession',
    'Create triangles and lanes, place men between the lines and break lines with forward passes to a free player.',
    NULL, 97, 97, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All players', 'Hold your zone and correct distances; shift with the ball'),
    (2, 'Players between the lines', 'Stay in the gaps behind the opposing midfield line'),
    (3, 'Passer', 'Play forward to the man in space who has time to turn or set again')
) AS v(so, role, job);

-- 20. pp.98-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Juego de Posicion (Positional Games)', 'Keep ball with jokers outnumbering',
    'Team in possession uses neutral jokers inside and outside players on the edges to keep a numerical edge against a pressing group (3v3+2 up to 9v9+2).',
    'Opponent presses in a block',
    'Circulate with two touches max, using the spare men inside to bounce out of pressure.',
    NULL, 98, 111, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Edge players', 'Hold width and length on the sides of the area'),
    (2, 'Inside jokers', 'Find pockets between pressers as the free man'),
    (3, 'Middle players of each team', 'Stay central throughout as link players')
) AS v(so, role, job);

-- 21. pp.98-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'out_of_possession', 'Juego de Posicion (Positional Games)', 'Group press closing passing angles',
    'Outnumbered pressing team works together inside the area to cut lanes rather than chase the ball.',
    'Ball played into the area / receiver under pressure',
    'Shut angles collectively until the carrier runs out of options and the ball is won.',
    NULL, 98, 111, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest presser', 'Press the ball on the angle that blocks the easiest pass'),
    (2, 'Cover pressers', 'Screen the lanes to the jokers and the next receiver')
) AS v(so, role, job);

-- 22. pp.98-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'to_defend', 'Juego de Posicion (Positional Games)', 'Instant counter-press after losing it',
    'In the possession and transition games the team that loses the ball has its outside players rush in at once while the winners move to the edges.',
    'Ball lost',
    'Win the ball back immediately before the other team can spread out.',
    NULL, 98, 111, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside players of losing team', 'Sprint inside and press as a group straight away'),
    (2, 'Players who won it', 'Spread to the edges to make the area big'),
    (3, 'Middle players', 'Stay central and switch roles with the ball')
) AS v(so, role, job);

-- 23. pp.106-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Juego de Posicion (Positional Games)', 'Draw press then long switch',
    'Team keeps the ball in one end zone against two pressers, then flights it over the middle to team-mates in the far zone.',
    '6-8 passes completed / pressers committed',
    'Move the ball out of the pressured area to the free side with an aerial switch.',
    NULL, 106, 107, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'End-zone possession group', 'Keep the ball while pressers come in, then lift it long'),
    (2, 'Far-zone team', 'Wait wide in the opposite zone ready for the switch'),
    (3, 'Middle interceptors', 'Leave the middle to cut out the long ball')
) AS v(so, role, job);

-- 24. pp.106-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'out_of_possession', 'Juego de Posicion (Positional Games)', 'Sprint across to defend the switch',
    'When play is switched into the opposite end zone, two defenders must race across to press there while the rest take the middle.',
    'Ball switched to the far zone',
    'Arrive fast enough to stop the receivers settling and win it.',
    NULL, 106, 107, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two nearest defenders', 'Sprint over to press the new ball zone'),
    (2, 'Remaining defenders', 'Drop into the middle zone to block the next long pass')
) AS v(so, role, job);

-- 25. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Juego de Posicion (Positional Games)', 'Pass through gates to receive',
    '7v7+3 possession where a point is scored by passing through pole gates for a team-mate to collect on the other side.',
    'A lane opens through a gate',
    'Break lines by splitting opponents to find a receiver behind them.',
    NULL, 108, 108, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Look for the gap and thread the ball through'),
    (2, 'Receiver', 'Move to the far side of the gate to take it on'),
    (3, 'Jokers', 'Support the team on the ball')
) AS v(so, role, job);

-- 26. pp.109-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'to_attack', 'Juego de Posicion (Positional Games)', 'Win ball, switch to other half',
    'Two-zone 8v6 game: the pressing team, on winning the ball, plays it at once to two team-mates waiting in the other half; everyone else then moves across.',
    'Ball regained',
    'Escape the regain zone with an immediate pass to the free side, then rebuild possession there.',
    NULL, 109, 109, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins it', 'Pass quickly to a team-mate in the other half'),
    (2, 'Two waiting players', 'Stay in the far half as the outlet'),
    (3, 'Rest of the team', 'Run across to join once the pass is received'),
    (4, 'Team that lost it', 'Counter-press at once to stop the switch')
) AS v(so, role, job);

-- 27. pp.114-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Attacking Positional Patterns of Play', 'Attacking philosophy: key behaviours',
    'Summary of Pep''s attack: dominate high up, stay in position, wingers high and wide, short passes, structured advance together.',
    'Settled possession in the opposition half',
    'Move opponents with combinations, use a third man to find the free man between lines and create 1v1s.',
    NULL, 114, 114, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'Stay high and wide on the touchline, strike when the defence is disorganised'),
    (2, 'All players', 'Never leave position to come for the ball'),
    (3, 'Third man', 'Arrive as the free man after a wall pass between the lines'),
    (4, 'Rest defence', 'Extra man in midfield and in defence with a high line, 2v4 up front accepted')
) AS v(so, role, job);

-- 28. pp.115-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Attacking Positional Patterns of Play', '2-3-2-3 with inverted full backs',
    'Man City''s 4-3-3 (Laporte, Stones, Zinchenko, Danilo, Rodrigo, Foden, De Bruyne, Bernardo, Sterling) reshapes to 2-3-2-3 in attack.',
    'Team in possession',
    'Four lines to pass through, full backs and 8s filling the half spaces, holding midfielder free to stay central.',
    NULL, 115, 116, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (Zinchenko, Danilo)', 'Step inside as inverted full backs into the half spaces'),
    (2, 'Holding midfielder (Rodrigo)', 'Stay central, no need to cover wide'),
    (3, 'Wingers (Bernardo + left winger)', 'Pin the wide defenders, open inside space'),
    (4, 'Centre backs (Laporte, Stones)', 'Look to play forward'),
    (5, 'Attacking mids (Foden, De Bruyne)', 'Occupy the half spaces between lines')
) AS v(so, role, job);

-- 29. pp.118-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Attacking Positional Patterns of Play', 'Inverted full back carries after lay-off',
    'Build-up from the centre backs: the left 8 drops inside, receives and sets back to the advancing left back in the half space.',
    'CB-to-CB pass and the 8 showing for it',
    'Left back dribbles forward, switches inside to the right 8 who slides a ball behind for the striker''s curved run.',
    NULL, 118, 118, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left attacking mid (Foden)', 'Come inside to receive, lay off, then run in behind'),
    (2, 'Left back (Zinchenko)', 'Advance in the half space, carry, pass across'),
    (3, 'Right attacking mid (De Bruyne)', 'Receive and pass in behind'),
    (4, 'Forward (Sterling)', 'Curve away from the defender to run in behind and shoot'),
    (5, 'Left winger', 'Also run in behind')
) AS v(so, role, job);

-- 30. pp.119-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Attacking Positional Patterns of Play', '8 sets for the 6 to slip striker',
    'Right back in the half space passes inside to the left 8 who has drifted central; he lays back to the holding midfielder arriving on a curved run.',
    '8 receives between lines facing his own goal',
    'Holding midfielder plays the final ball for the forward running in behind.',
    NULL, 119, 119, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Danilo)', 'Receive inside and play into the 8'),
    (2, 'Left attacking mid (Foden)', 'Shift to the centre and lay off first time'),
    (3, 'Holding mid (Rodrigo)', 'Curve forward onto the lay-off and pass through'),
    (4, 'Forward (Sterling)', 'Curved run away from his marker, then shoot'),
    (5, 'Left winger + left 8', 'Make runs in behind')
) AS v(so, role, job);

-- 31. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Attacking Positional Patterns of Play', 'Long ball to 9, third man run',
    'Left centre back plays long into the striker''s feet while the left 8 drops to offer and the 6 steps up.',
    'Forward receives the long pass to feet',
    'Forward sets a timed ball for the right 8 making a curved third-man run from deep to shoot.',
    NULL, 120, 120, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Laporte)', 'Long pass into the forward''s feet'),
    (2, 'Forward (Sterling)', 'Hold it and play the third man in'),
    (3, 'Right attacking mid (De Bruyne)', 'Curved run from deep onto the pass, finish'),
    (4, 'Left attacking mid (Foden)', 'Drop back and across as a short option'),
    (5, 'Holding mid (Rodrigo)', 'Move forward in support')
) AS v(so, role, job);

-- 32. pp.121-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Attacking Positional Patterns of Play', 'Switch then overlap and cross',
    'Ball goes left back to centre back to the 6 and across to the right centre back, who steps forward and finds the right winger coming off the line.',
    'Ball switched to the right centre back',
    'Winger lays off to the right 8, who plays the overlapping right back behind to cross for four runners into the box.',
    NULL, 121, 121, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding mid (Rodrigo)', 'Move across to link the switch between centre backs'),
    (2, 'Right winger (Bernardo)', 'Come inside off the flank and set first time'),
    (3, 'Right attacking mid (De Bruyne)', 'Pass in behind for the overlap'),
    (4, 'Right back (Danilo)', 'Overlap to near the by-line and cross'),
    (5, 'Forward + 3 runners', 'Attack the box, forward heads in')
) AS v(so, role, job);

-- 33. pp.123-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Small to Large Sided Games', 'Exploit overload, attack at tempo',
    'Small sided games with big goals, jokers or outside players helping the team on the ball; 1-3 touches, every restart from the keeper with short, medium or long distribution.',
    'Team gains possession / keeper restart',
    'Use the spare man to move the ball forward quickly and create chances.',
    NULL, 123, 125, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Start play, choose short, medium or long'),
    (2, 'Joker / outside players', 'Join the team on the ball as the extra man'),
    (3, 'Outfield players', 'Play fast with 1-3 touches toward goal')
) AS v(so, role, job);

-- 34. pp.126-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Small to Large Sided Games', 'Step up a man per zone',
    'Half pitch split into three zones (4v3 low, 2v2 middle, 3v3 end) in a 10v9 game; build from the keeper with the extra man.',
    'A pass is received in the next zone',
    'One player follows forward from the zone behind to create the overload in each new zone (3v2 then 4v3) and score.',
    NULL, 126, 126, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line + GK', 'Build out with the 4v3 overload, pass into the middle zone'),
    (2, 'Stepping player', 'Move forward one zone once the pass arrives'),
    (3, 'Middle players', 'Use the 3v2 to find the end zone'),
    (4, 'End-zone attackers', 'Finish with the 4v3')
) AS v(so, role, job);

-- 35. pp.127-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'in_possession', 'Small to Large Sided Games', 'Stretch a compact block, three goals',
    '9v7 on half a pitch: attacking team in 3-3-3 against a compact 4-3 defending three full goals.',
    'Coach serves a new ball to the build-up',
    'Build up and play in behind, attacking whichever goal the shifting block leaves open.',
    NULL, 127, 127, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'Build up and switch to move the block'),
    (2, 'Midfield three', 'Find lanes between the defenders'),
    (3, 'Front three', 'Run in behind and finish in any goal')
) AS v(so, role, job);

-- 36. pp.127-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-85-passing-rondos-possession-games-technical-circuits-direct-from-'), 'out_of_possession', 'Small to Large Sided Games', 'Compact 4-3 shifts across three goals',
    'Defending team in a compact 4-3 must protect three goals spread across the width, forcing more movement than normal.',
    'Ball moved to a new channel',
    'Shift as a unit to stay compact around the ball and win it.',
    NULL, 127, 127, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Slide together toward the ball-side goal'),
    (2, 'Midfield three', 'Shift with the ball and press to win it')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('2153-coaching-book-pep-guardiola-85-passing-rondos-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
