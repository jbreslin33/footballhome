-- 1976 📚 Coaching book patterns: "Advanced Spanish Academy Coaching" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Advanced Spanish Academy Coaching',
    subtitle    = '120 Technical, Tactical and Conditioning Practices from Top Spanish Coaches',
    author      = 'David Aznar, Rafa Juanes, Manu Dorado, Fernando Gaspar',
    team        = 'Spanish Federation youth, Villarreal, Real Madrid academy',
    method_note = 'Older-youth (about 14-18) academy practices from four Spanish coaches, one chapter each: David Aznar (rondos, possession, transition and finishing games), Rafa Juanes of Villarreal (a position-by-position programme: centre backs, full backs and wingers, central midfielders, forwards), Manu Dorado of Real Madrid (back-four movements, final-third overloads, guided discovery) and Fernando Gaspar (speed, agility and strength games with the ball). Patterns are the team behaviours the practices train (relocate to the free side, collective press, back four sliding and stepping up, front-six semicircle press, near and far post runs, flank 2v1s), in our words; pure technique, fitness circuits and programme tables are left out.'
WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi');

-- 1. pp.14-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Aznar - Practices to Improve Vision & Spatial Awareness', 'Relocate to the free side after passing',
    'In a rondo with two players on one side and one on the others, when one of the pair passes, his partner moves to a side that has only one player so every side keeps an option.',
    'Pass played from the doubled side',
    'Keep a passing line open on every side of the defender and avoid two players sharing one lane.',
    NULL, 14, 20, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer on doubled side', 'pass, then hold'),
    (2, 'Partner on doubled side', 'run to the side with only one player'),
    (3, 'Receiver', 'open body, receive on back foot, 1-2 touches')
) AS v(so, role, job);

-- 2. pp.16-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'out_of_possession', 'Aznar - Vision & Spatial Awareness / Possession', 'Collective press: one closes, rest block lanes',
    'Small groups of defenders inside a possession game coordinate: the nearest one closes the ball carrier while the others mark or screen the likely passes.',
    'Opponent has the ball inside the zone',
    'Win the ball by reducing the carrier to no safe pass.',
    NULL, 16, 33, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'close down the ball carrier'),
    (2, 'Other defenders', 'mark receivers or stand in the passing lanes'),
    (3, 'Middle team (3-team game)', 'form shapes that cut the line-breaking passes')
) AS v(so, role, job);

-- 3. pp.17-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Aznar - Vision & Spatial Awareness / Possession', 'Holding midfielder as central link',
    'One or two holding players inside the box of outside players offer support behind or between defenders, with correct angle and distance, rotating the role.',
    'Outside player under pressure needs an inside option',
    'Give the team a central connection that turns the ball from one side to the other.',
    NULL, 17, 20, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder', 'find the angle between markers, open body, play away from pressure'),
    (2, 'Outside players', 'use the pivot to switch sides')
) AS v(so, role, job);

-- 4. pp.19-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Aznar - Practices to Improve Possession', 'Check away before showing to receive',
    'Inside players and outfield players in possession games move away from their marker first, then come into space to receive; nobody stands still.',
    'Teammate ready to pass',
    'Create a yard of space to receive and keep possession.',
    NULL, 19, 36, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'check away from marker, then move into space'),
    (2, 'Ball carrier', 'pass weighted and timed for the run'),
    (3, 'Rest of team', 'keep moving to create space')
) AS v(so, role, job);

-- 5. pp.22-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'to_attack', 'Aznar - Practices to Improve Possession', 'Regain and switch to the free zone',
    'The team that wins the ball in a crowded zone plays it straight out to teammates waiting in another zone, then everyone sprints across to support there.',
    'Ball won in a congested area',
    'Escape the counter-press and restart possession where the opponent is thin.',
    NULL, 22, 34, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'pass immediately to teammates in the other zone'),
    (2, 'Teammates in far zone', 'receive and keep the ball'),
    (3, 'Players near the regain', 'run across quickly to support'),
    (4, 'Team that lost it', 'become defenders at once')
) AS v(so, role, job);

-- 6. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'to_attack', 'Aznar - Practices to Improve Possession', 'Fast attack from a won overload',
    'After a set number of passes in midfield, the inside group attacks goal with numbers against fewer defenders, looking for passes and runs in behind the back line.',
    'Possession secured / numerical advantage',
    'Turn possession into a quick vertical attack while the defence is short.',
    NULL, 23, 23, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield group', 'break forward together'),
    (2, 'Runners', 'go in behind the defensive line into the box'),
    (3, 'Passer', 'slide the ball in behind early')
) AS v(so, role, job);

-- 7. pp.23-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'to_defend', 'Aznar - Practices to Improve Possession', 'Sprint back when the attack ends',
    'As soon as a shot or lost ball ends an attack, attackers retreat at speed because the opposing keeper restarts quickly into midfield.',
    'Goal scored, shot or ball lost',
    'Recover numbers behind the ball before the opponent attacks.',
    NULL, 23, 29, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attackers', 'retreat immediately behind the ball'),
    (2, 'Nearest player', 'delay the new ball carrier')
) AS v(so, role, job);

-- 8. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Aznar - Practices to Improve Possession', 'Aerial switch over a zone to a runner',
    'Team packs two zones, then lofts a ball over the next zone to a teammate who has run into the empty zone, and the block shifts across behind it.',
    'Empty zone beyond a crowded one',
    'Skip a congested area and receive in free space with a clean first touch.',
    NULL, 24, 24, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'accurate height and weight over the zone'),
    (2, 'Runner', 'run into the empty zone, control before it lands, pass on'),
    (3, 'Rest of team', 'shift so the team occupies two zones again')
) AS v(so, role, job);

-- 9. pp.26-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Aznar - Practices to Improve Possession', 'Angled support left and right of receiver',
    'When a ball reaches a target or wide player, at least two teammates immediately arrive on angles to his left and right for a first-time lay-off.',
    'Ball played into a target or wide player',
    'Target always has two quick release options and possession continues.',
    NULL, 26, 35, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target / wide player', 'play first time to a supporting teammate'),
    (2, 'Nearest two teammates', 'arrive at angles either side'),
    (3, 'Support players', 'correct distance, open body')
) AS v(so, role, job);

-- 10. pp.27-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Aznar - Practices to Improve Finishing', 'Shoot early when space appears',
    'In tight finishing games players shoot as soon as they have a yard, ideally within a few passes, using numerical advantage to make that yard.',
    'A yard of space in shooting range',
    'Finish quickly before the defence closes.',
    NULL, 27, 44, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player with space', 'shoot accurately, not hard'),
    (2, 'Supporting players / neutrals', 'create the overload that frees a shooter')
) AS v(so, role, job);

-- 11. pp.28-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Aznar - Practices to Improve Possession', 'One-two with wide support players',
    'Team progresses by playing wall passes with supporting players on the flanks or touchline; in a 4-2-1 or 2-4-1 shape the full backs or wingers move into the side lanes to play it.',
    'Wide support player available and free',
    'Beat a pressing opponent and move into an end or side zone with the ball.',
    NULL, 28, 32, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'pass to wide support and run for the return'),
    (2, 'Wide support / full back / winger', 'move into the side lane, return first time'),
    (3, 'Second-pass weight', 'lead the runner onto the ball')
) AS v(so, role, job);

-- 12. pp.29-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Aznar - Practices to Improve Possession', 'Keep the ball while outnumbered',
    'A smaller group must string consecutive passes against more opponents before releasing to teammates in the other half.',
    'Opponents outnumber the team in possession',
    'Survive pressure with constant movement and high passing speed.',
    NULL, 29, 29, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All players in possession', 'keep moving and offering'),
    (2, 'Ball carrier', 'pass fast, 1-2 touches')
) AS v(so, role, job);

-- 13. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Aznar - Practices to Improve Possession', 'Pass through the lines via rotating link',
    'Two outside groups try to pass through a middle group; each may place one support player in the central zone but must rotate who goes in.',
    'Middle line screens the direct pass',
    'Break a defensive or midfield line with a pass or by using a link player between lines.',
    NULL, 33, 33, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Link player in middle zone', 'find angle and distance between defenders, then swap out'),
    (2, 'Outside players', 'pass through the line or via the link')
) AS v(so, role, job);

-- 14. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Aznar - Practices to Improve Finishing', 'Use full width and length, no crowding',
    'In small sided games with several goals, attackers spread over the whole area and avoid bunching around the ball to open shooting chances.',
    'Team in possession',
    'Stretch defenders and create space to shoot.',
    NULL, 37, 37, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attackers', 'spread wide and deep, keep moving'),
    (2, 'Receiver', 'check away from marker first')
) AS v(so, role, job);

-- 15. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'to_attack', 'Aznar - Practices to Improve Finishing', 'Regain, release wide, quick counter',
    'Defending team wins the ball, the interceptor releases it at once to a wide teammate, and the attack is finished as fast as possible.',
    'Interception',
    'Score before the opponent recovers.',
    NULL, 38, 38, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Interceptor', 'do not hold it, pass wide immediately'),
    (2, 'Wide player', 'drive forward and deliver'),
    (3, 'Central players', 'break toward goal and finish quickly')
) AS v(so, role, job);

-- 16. pp.39-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Aznar - Practices to Improve Finishing', 'Final-third 4v3 through ball',
    'Four attackers, two of them wide, must thread a pass through gaps in a defensive line before attacking goal, creating repeated 2v1s.',
    'Gap opens between defenders',
    'Get in behind and finish with a numerical edge.',
    NULL, 39, 39, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide attackers', 'stay close enough to goal to be a threat'),
    (2, 'Central attackers', 'change direction and combine 2v1'),
    (3, 'Passer', 'accurate through ball into the gate')
) AS v(so, role, job);

-- 17. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Aznar - Practices to Improve Finishing', 'Wide lay-in, overlap and cross',
    'Ball goes out wide, wide player plays inside, central player returns it into the run of the wide player who crosses while central runners attack the box.',
    'Ball reaches the wide player',
    'Create a cross from width with several runners in the box.',
    NULL, 40, 40, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player', 'pass inside, run on, cross'),
    (2, 'Central midfielder', 'play ball into the wide run, then sprint into the box'),
    (3, 'Other central players', 'attack near and far zones for the cross')
) AS v(so, role, job);

-- 18. pp.41-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Aznar - Practices to Improve Finishing', 'Lose the marker and run in behind',
    'Against man-to-man marking, attackers break from their markers with timed runs behind the line (onside) or short combinations, and the receiver reads teammates'' movement to pick the pass.',
    'Passer ready behind the line; marker tight',
    'Get free to receive behind or in space and finish.',
    NULL, 41, 44, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward runners', 'time run against offside line, never static'),
    (2, 'Passer', 'play in behind as the run starts'),
    (3, 'Receiver in midfield zone', 'scan teammates and choose the pass')
) AS v(so, role, job);

-- 19. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'to_attack', 'Juanes - Centre backs', 'Intercept, carry, long diagonal switch',
    'Centre backs drop together on a deep ball, one intercepts under pressure, carries a few yards and hits a long diagonal to the far flank away from the nearest opponent.',
    'Opponent''s long forward pass',
    'Turn a defensive interception into a build-up switch.',
    NULL, 52, 52, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Intercepting centre back', 'control, short carry, diagonal pass away from pressure'),
    (2, 'Partner centre back', 'drop with him and cover'),
    (3, 'Far-side wide player', 'hold width to receive')
) AS v(so, role, job);

-- 20. pp.53-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'out_of_possession', 'Juanes - Centre backs', 'Directed headed clearance to midfield',
    'On long or high balls the centre backs retreat together facing forward and head clear to a midfielder rather than anywhere, using height to give him time.',
    'Long ball or high cross toward the back line',
    'Clearance keeps the ball for the team and lets it push up.',
    NULL, 53, 56, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back attacking the ball', 'head under the ball for height toward a midfielder'),
    (2, 'Other centre back', 'cover and contest second attacker'),
    (3, 'Midfielders', 'position to collect the clearance')
) AS v(so, role, job);

-- 21. pp.54-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'out_of_possession', 'Juanes - Centre backs', 'Centre back covers the flank',
    'When the ball goes down the line, the back line shifts across and a centre back goes out to pressure the wide attacker, using shoulder contact and reading the run rather than the ball.',
    'Pass down the line to a wide attacker',
    'Stop the wide attack or win the ball with a legal challenge.',
    NULL, 54, 54, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near centre back', 'move across, pressure, shoulder challenge'),
    (2, 'Rest of back line', 'position by ball and teammates (zonal)')
) AS v(so, role, job);

-- 22. pp.55-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'set_piece', 'Juanes - Centre backs', 'Man-marking on crosses and set pieces',
    'On hanging balls from the side, defenders mark attackers man to man with physical contact and attack the ball with strong headers.',
    'High cross or set-piece delivery',
    'Win the first header and clear the danger.',
    NULL, 55, 55, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marking defenders', 'body contact with attacker, correct body shape'),
    (2, 'Defender at the ball', 'strong header clear')
) AS v(so, role, job);

-- 23. pp.59-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Juanes - Wide players', 'Short goal kick, full back carries, long pass',
    'Build-up under two pressing forwards: short goal kick to a centre back, across to the full back who carries forward or inside and plays long, either down the line to a forward or diagonally with the weaker foot to the far side of the opponent half.',
    'Short goal kick with two opposing forwards pressing',
    'Escape the first press and get the ball into the opposition half.',
    NULL, 59, 60, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'short goal kick'),
    (2, 'Centre backs', 'play across the back'),
    (3, 'Full back', 'receive on foot away from pressure, carry with arm protecting, long pass'),
    (4, 'Forward / far winger', 'receive the long ball in the opposition half')
) AS v(so, role, job);

-- 24. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Rafa Juanes - defenders: playing out under pressure', 'Circulate across back four, then long line ball',
    'From a short goal kick the back four move the ball across the line against a six-man front press; one supporter steps over the ball as a dummy so it runs to the far full back.',
    'Press loads one side of the back line',
    'Shift the ball to the free full back, who carries it to the touchline and plays long down the line to a forward.',
    NULL, 61, 61, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Move the ball quickly across the line'),
    (2, 'Dummy runner', 'Run over the ball and use body shape to pull pressers away'),
    (3, 'Far full back', 'Carry ball toward touchline shielding it with the body'),
    (4, 'Far full back', 'Long pass down the line for a running forward')
) AS v(so, role, job);

-- 25. pp.63-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Rafa Juanes - wide players: attacking the flank', 'Winger 1v1: byline or cut inside',
    'A central player feeds the winger, who must first lose his marker to receive in space, then beat the defender in front of him with a feint.',
    'Winger receives facing his full back',
    'Either go to the byline or drive inside, then cross for two forwards attacking the box.',
    NULL, 63, 64, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Check away from marker before receiving'),
    (2, 'Winger', 'Feint, then go outside to byline or inside to cross'),
    (3, 'Central midfielder', 'Feed the winger in the space he creates'),
    (4, 'Front two', 'Attack the box for the cross, at least near post')
) AS v(so, role, job);

-- 26. pp.65-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Rafa Juanes - wide players: attacking the flank', 'Winger cuts inside and switches play',
    'One winger receives, fakes, bursts inside and hits a long ball to the far flank; the far winger cushions it and walks at his defender before a change of pace.',
    'Near flank closed, far winger isolated',
    'Make the far defender back off, then use a change of pace and direction to beat him and cross or shoot.',
    NULL, 65, 65, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near winger', 'Lose marker, feint, explode inside, long switch'),
    (2, 'Far winger', 'Cushion the switch, advance slowly at defender'),
    (3, 'Far winger', 'Change pace and direction to get past and cross'),
    (4, 'Forward', 'Attack the cross')
) AS v(so, role, job);

-- 27. pp.66-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'out_of_possession', 'Rafa Juanes - defenders: back four with the ball wide', 'Back four slide to the wide ball',
    'When the opponent moves the ball across to a flank, the whole back line shifts together toward the ball zone; the nearest defender presses the winger.',
    'Ball switched to a wide attacker',
    'Stop the pass inside, force the winger outside and keep the line intact so any cross or shot is from a poor angle.',
    NULL, 66, 67, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back', 'Press aggressively, low stance, show outside, block pass inside'),
    (2, 'Centre backs', 'Slide across as one, hold line positions'),
    (3, 'Weak-side full back', 'Tuck in with the line'),
    (4, 'All defenders', 'Face play, read body cues for cross or shot timing')
) AS v(so, role, job);

-- 28. pp.68-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'out_of_possession', 'Rafa Juanes - defenders: tracking back', 'Centre backs track diagonal, intercept or clear',
    'Two centre backs face a long diagonal pass to a winger and supporting runners; they stay balanced and adjust to the wide player''s moves.',
    'Long diagonal played to the wide attacker',
    'Intercept the pass when possible, otherwise clear the cross with a header back the other way or aimed to a target.',
    NULL, 68, 68, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near centre back', 'Step sideways to block or intercept the pass'),
    (2, 'Far centre back', 'Hold balance and cover the box'),
    (3, 'Both centre backs', 'Read body signals for when the cross comes'),
    (4, 'Both centre backs', 'Clear opposite the cross direction, technique by ball height')
) AS v(so, role, job);

-- 29. pp.71-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Rafa Juanes - centre midfielders: build-up from the back', 'Two pivots coordinate in build-up',
    'From a short goal kick the nearest central midfielder positions behind and then in line with the ball carrier, receiving open on the far foot; the other midfielder runs diagonally to give a second line.',
    'Ball goes from goalkeeper to a full back or centre back',
    'The receiving midfielder always faces the opposition half with at least two passing options.',
    NULL, 71, 73, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near central midfielder', 'Offer behind or level with ball carrier, receive on back foot facing forward'),
    (2, 'Far central midfielder', 'Diagonal move inside as a second option, reacts to carrier''s choice'),
    (3, 'Full back', 'Pass to the near midfielder or straight to the far one'),
    (4, 'Forward', 'Option to receive and lay back to a facing midfielder')
) AS v(so, role, job);

-- 30. pp.74-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Rafa Juanes - centre midfielders: switching play', 'Switch through midfield away from presser',
    'The full back plays into a central midfielder who moves the ball away from the side the opposing midfielder is pressing, alone or via a one-two with the second midfielder around the presser.',
    'One opposition midfielder pressing the receiving midfielder',
    'Turn the presser, then hit a long switch to the far winger with the foot least under pressure.',
    NULL, 74, 75, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Pass or one-touch into the central midfielder'),
    (2, 'Central midfielder', 'Play against the direction of the press'),
    (3, 'Second central midfielder', 'Give and go round the opponent for the return'),
    (4, 'Far winger', 'Hold width for the long switch')
) AS v(so, role, job);

-- 31. pp.76-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'to_attack', 'Rafa Juanes - centre midfielders: defending a long ball', 'Win opponent long ball, play wide fast',
    'Against an opposition goal kick or long ball the centre backs control or head it while running back, and central midfielders drop to reinforce rather than tracking like defenders.',
    'Opponent goal kick or long ball contested by our centre backs',
    'Turn a controlled interception or headed clearance to a teammate into an attack via a one-two or long pass to a winger.',
    NULL, 76, 77, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Controlled interception or header aimed at a teammate'),
    (2, 'Central midfielders', 'Drop back facing play, ready to receive the clearance'),
    (3, 'Wingers', 'Stay wide for the long switch'),
    (4, 'Second centre back', 'Cover behind the contesting partner')
) AS v(so, role, job);

-- 32. pp.78-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'to_attack', 'Rafa Juanes - centre midfielders: combination after a long ball', 'Pivot pair gives two options after regain',
    'A centre back controls an opponent long ball and passes short; the two central midfielders move off each other so the ball carrier always has two passes.',
    'Centre back wins and controls a long ball',
    'Use short passing between the two midfielders and the centre back to build an attack that ends with a winger or forward in on goal.',
    NULL, 78, 79, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Control the long ball, short pass to start'),
    (2, 'Central midfielder A', 'Move to be available for the return'),
    (3, 'Central midfielder B', 'Position relative to A so carrier has two options'),
    (4, 'Winger', 'Receive wide and attack')
) AS v(so, role, job);

-- 33. pp.81-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'out_of_possession', 'Rafa Juanes - forwards: front six with and without the ball', 'Front six close down in semicircle',
    'Forwards and midfielders press the opposition defence together, forming a semicircle across the pitch around the ball.',
    'Opponent has the ball in their back line',
    'Close off the opponents collectively as one unit.',
    NULL, 81, 81, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Press defenders, curve in to form the arc'),
    (2, 'Central midfielders', 'Close the gap behind the forwards'),
    (3, 'Wingers', 'Close the outer ends of the arc')
) AS v(so, role, job);

-- 34. pp.81-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Rafa Juanes - forwards: front six with and without the ball', 'Forwards invert the arc after wide ball',
    'Once the ball is played wide, forwards switch from pressing shape to an inverted semicircle offering the wide player two solutions, using waiting areas and combined diagonal-curved runs.',
    'Midfielder plays the ball out wide',
    'Give the wide player a diagonal pass into the near post or a one-two with a supporting midfielder to cross to the far post, timing runs to stay onside.',
    NULL, 81, 83, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near forward', 'Diagonal run to receive at the near post'),
    (2, 'Far forward', 'Curved run into waiting area, then far post'),
    (3, 'Supporting midfielder', 'Offer one-two for the wide player'),
    (4, 'Wide player', 'Choose between the two options'),
    (5, 'Forwards', 'Delay in waiting area to avoid offside')
) AS v(so, role, job);

-- 35. pp.84-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Rafa Juanes - forwards: attacking the flanks with crossing', 'Two forwards split near and far post',
    'As the winger dribbles down the side of the box, the two forwards coordinate so he has two crossing targets; under strong pressure the near post becomes the priority.',
    'Winger running at the box to cross',
    'Present near-post and far-post targets so the cross always has a destination, finished first time.',
    NULL, 84, 85, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward 1', 'Diagonal run to centre, then check back to near post for short cross'),
    (2, 'Forward 2', 'Short diagonal to box edge, curved run to far post facing ball'),
    (3, 'Forward 1 (winger pressed)', 'Direct diagonal across area for a pull-back along the goal line'),
    (4, 'Forward 2 (winger pressed)', 'Feint toward penalty spot, then sprint to near post'),
    (5, 'Winger', 'Hold off defender and pick the free post')
) AS v(so, role, job);

-- 36. pp.86-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Rafa Juanes - forwards: movement of the forwards', 'Diagonal runs to escape the marker',
    'With two forwards against a defender, one drops deep and passes to the side of his partner, who checks off his marker, turns and sprints diagonally into empty space; in the box, diagonal runs to the near post meet crosses.',
    'Forward marked tight, space beside or behind defender',
    'Create space to run onto and finish with one or two touches, or shield with back to goal and turn when no shot is on.',
    NULL, 86, 92, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep forward', 'Pass into space at the side of the partner'),
    (2, 'Advanced forward', 'Check away, turn head toward ball, diagonal sprint'),
    (3, 'Striker in box', 'Diagonal run to near post, finish against run direction'),
    (4, 'Striker (no shot)', 'Arm on defender, shield, turn and shoot')
) AS v(so, role, job);

-- 37. pp.104-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'out_of_possession', 'Manu Dorado - collective defending / Practice 3 defensive line', 'Back four step and slide on switches',
    'A back four faces five or six attackers in a 2-4 or 4-2 shape passing and switching play; the line moves collectively by ball position.',
    'Ball circulated back or switched across',
    'Keep correct distances: step up together when the ball goes back, then drop and slide toward the touchline when play is switched.',
    NULL, 104, 112, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Move as a unit with the ball'),
    (2, 'Ball-side full back', 'Engage the wide ball'),
    (3, 'Centre backs', 'Hold distances, drop when ball is switched wide'),
    (4, 'Weak-side full back', 'Tuck in and drop with the line')
) AS v(so, role, job);

-- 38. pp.108-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Manu Dorado - Practice 1: build-up and decision making in a 5v4 attack', '5v4 final-third attack with overlapping full back',
    'Build from three defenders and two midfielders (team in 3-2-3, adaptable to own shape) against a back four; a midfielder carries forward and releases one of three attackers to start a 5v4, players choosing the combination.',
    'Midfielder releases a front player into the final third',
    'Get behind the back four and score, using full-back overlaps and width to create the extra man.',
    NULL, 108, 110, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Join the attack centrally or wide, get the ball out wide quickly'),
    (2, 'Full back', 'Overlap toward the byline'),
    (3, 'Midfielders', 'Cover lines, occupy space in front of centre backs, swap with wingers'),
    (4, 'Wingers', 'Width, isolate 1v1, move inside to open overlap lane'),
    (5, 'Centre forward', 'Face inside and protect ball; ball wide -> penalty spot or near post, leave space')
) AS v(so, role, job);

-- 39. pp.111-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Manu Dorado - Practice 2 and 4: flank play small-sided games', 'Create overload and 2v1 on flank',
    'Small-sided 2v2 and 3v3 games focused on attacking wide areas, with players free to pick their combinations or dribbles.',
    'Ball in a wide zone with even numbers',
    'Build a numerical edge out wide and turn it into 2v1s that carry the ball to the end zone.',
    NULL, 111, 113, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players', 'Create superiority wide, look for 2v1'),
    (2, 'Receiver', 'Check away from marker before moving to receive'),
    (3, 'Ball carrier', 'Get in front of marker and protect ball, drive to edge of zone'),
    (4, 'Central player', 'Support for combinations')
) AS v(so, role, job);

-- 40. pp.123-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'out_of_possession', 'Fernando Gaspar - conditioning games', 'Man-to-man pairs across the pitch',
    'In a small-sided game every outfield player is tied to one opponent and follows him everywhere; the coach can reassign pairs mid-game.',
    'Opponent has the ball / any movement of your man',
    'Deny every receiver time and space so the carrier must shield and release under contact.',
    NULL, 123, 123, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Every outfield defender', 'Pick one opponent and stay touch-tight to him'),
    (2, 'Ball carrier (attacking side)', 'Use arm and body as a barrier, protect then release'),
    (3, 'Marked receiver', 'Look early and shoot or pass quickly, pressure is immediate')
) AS v(so, role, job);

-- 41. pp.124-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Fernando Gaspar - speed and finishing practices', 'One-two then strike from the edge',
    'A runner dribbles at the box, plays a wall pass with a diagonal teammate and takes the return in stride to shoot from around the edge of the area.',
    'Defender or cone line blocks the dribble at the top of the box',
    'Bypass the last challenger without slowing the runner and finish first time from distance.',
    NULL, 124, 158, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder / runner', 'Dribble at pace, pass and keep sprinting past the blocker'),
    (2, 'Wall player (striker or support)', 'Return first time, weighted into the runner''s path so he never breaks stride'),
    (3, 'Shooter', 'First touch pushes the ball out from the body, or shoot first time')
) AS v(so, role, job);

-- 42. pp.126-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Fernando Gaspar - speed and finishing practices', 'Overlap and three runners attack the cross',
    'Ball is worked wide (diagonal pass inside, out to the flank, or an overlapping full back); while the winger drives to the byline two or three teammates make crossing curved runs to near post, far post and centre.',
    'Ball reaches the wide player in space near the byline',
    'Fill the box at three heights with timed runs so the cross always has a target.',
    NULL, 126, 140, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Overlapping full back / winger', 'Run the outside, receive, dribble to byline and cross'),
    (2, 'Near-post runner', 'Curved run that arrives as the ball is struck'),
    (3, 'Far-post runner', 'Cross the near runner''s path, attack the back post'),
    (4, 'Third runner / centre midfielder', 'Arrive late at penalty spot; no sprint longer than needed (about 15 yards)')
) AS v(so, role, job);

-- 43. pp.131-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Fernando Gaspar - speed and finishing practices', 'Wide give-and-go, pass into channel, passer attacks box',
    'Midfielder passes wide, sprints forward and gets it back from a teammate who came inside; he then plays into space down the flank for that teammate and runs into the area for the cross.',
    'Winger moves inside to offer the one-two',
    'Use two quick combinations on the flank so the original passer finishes his own move in the box.',
    NULL, 131, 131, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'Pass wide, accelerate, take the return, play the ball into the channel, then run round into the box'),
    (2, 'Winger', 'Come inside to set the one-two, then spin and run onto the ball in the channel and cross')
) AS v(so, role, job);

-- 44. pp.133-157
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'to_attack', 'Fernando Gaspar - speed and finishing practices', 'Exploit the overload and finish fast',
    'Small groups (3v2, 2v2 on a flank, 3v3 vs a defence still organising) attack goal against a short clock of a few seconds; in the 3v2 the attackers keep the ball until the signal then attack at once.',
    'Ball won / coach signal / defenders not yet set',
    'Finish before the defence recovers, picking the quickest option and running into space behind defenders.',
    NULL, 133, 157, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Drive at the defenders, decide quickly, free choice of solution'),
    (2, 'Free attacker (spare man)', 'Stay wide of the last defender to receive the release pass'),
    (3, 'Off-ball runners', 'Run into the space behind the defenders, not to feet'),
    (4, 'Recovering defenders', 'React together and track the runner, cohesion over individual chasing')
) AS v(so, role, job);

-- 45. pp.137-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'out_of_possession', 'Fernando Gaspar - speed and finishing practices', '1v1 defending: surfboard stance, close fast',
    'Defender facing a dribbler or a receiver in the box closes the distance quickly and defends side-on, body angled away from his own goal, matching the attacker''s speed.',
    'Pass travelling to the attacker / attacker dribbles at you',
    'Stop the shot or at least spoil it with physical contact, showing the attacker away from goal.',
    NULL, 137, 138, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'Close quickly while the ball travels, arrive side-on (surfboard), front of body angled away from goal'),
    (2, 'Defender in box', 'Move across and make contact to block or affect the shot')
) AS v(so, role, job);

-- 46. pp.137-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Fernando Gaspar - speed and finishing practices', 'Touch away from the defender, shoot within seconds',
    'Attacker receiving at the edge of the box, or dribbling 1v1, has only a few seconds; first touch goes forward and away from the closing defender, then feints and a change of direction open the shot.',
    'Pass arrives with a defender closing from one side',
    'Create a shooting window before the defender can make contact.',
    NULL, 137, 156, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker on the edge of the box', 'First touch out in front, opposite side to the defender, shoot fast'),
    (2, '1v1 attacker', 'Keep the ball close, feint and change pace or direction to attack the space behind the opponent')
) AS v(so, role, job);

-- 47. pp.141-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Fernando Gaspar - speed and finishing practices', 'Play to the wing away from pressure',
    'Central player receives from a teammate who then moves to one side; he must play to the opposite wing, after which he and the far-side player run forward to attack the cross.',
    'Pressure or the passer arrives on one side of the receiver',
    'Switch away from the pressing side and fill the box from the weak side.',
    NULL, 141, 141, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'Read which side is closed and play to the other wing, then run into the box'),
    (2, 'Weak-side winger', 'Receive in space, cross early'),
    (3, 'Far-side forward', 'Attack the cross but keep the run short (about 15 yards)')
) AS v(so, role, job);

-- 48. pp.144-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'to_attack', 'Fernando Gaspar - conditioning games', 'Regain then secure five passes',
    'In a possession game the defending side, once it wins the ball, has to string several passes together before it counts.',
    'Ball won from the team in possession',
    'Turn a regain into a settled spell of possession rather than giving it straight back.',
    NULL, 144, 144, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins it', 'Protect the ball and find the first safe pass'),
    (2, 'Teammates of the ball winner', 'Spread out at once to give passing options')
) AS v(so, role, job);

-- 49. pp.144-167
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Fernando Gaspar - conditioning games', 'Support angles: always two easy options',
    'Rondos (4v1, 6v2) and 4v4 with outside support players: teammates move so the ball carrier always has at least two simple passing lanes, and receivers let the ball run across the body to play on with the back foot.',
    'Any pass played / defender closes a lane',
    'Keep possession under pressure and high tempo without forcing passes.',
    NULL, 144, 167, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Pass with the foot furthest from the ball, limited touches'),
    (2, 'Nearest supports', 'Open angles either side so two lanes are always free'),
    (3, 'Outside / bounce players', 'Offer a wall pass, but do not be overused (cap on passes to them)')
) AS v(so, role, job);

-- 50. pp.146-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Fernando Gaspar - speed and finishing practices', 'Check away to lose the marker',
    'Marked forward first moves away from where he wants the ball, then accelerates the opposite way to receive; in small games a goal is a pass through a gate to a teammate who has lost his man.',
    'Teammate is ready to pass / passer signals',
    'Win a yard of separation so the pass can be met and finished or controlled first time.',
    NULL, 146, 150, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marked forward', 'Feint away, then sprint the opposite way into the free space'),
    (2, 'Passer', 'Time and weight the pass to the run, not to the starting spot'),
    (3, 'Supporting teammates', 'Keep tempo high so gaps open between defenders')
) AS v(so, role, job);

-- 51. pp.163-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Fernando Gaspar - strength and conditioning circuit games', 'Full-team possession in match shape',
    'Eleven players in their match positions keep the ball from the goalkeeper with up to three touches each, always moving, staying compact as a formation and switching play; lines pass among themselves in their normal positions.',
    'Goalkeeper starts the move',
    'Rehearse team-shape circulation and switching while holding distances between lines.',
    NULL, 163, 168, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Start the circulation'),
    (2, 'Back line', 'Pass along the line and switch the play'),
    (3, 'Midfield and front lines', 'Keep moving to stay available while the formation stays tight')
) AS v(so, role, job);

-- 52. pp.170-170
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Fernando Gaspar - strength and conditioning circuit games', 'Goalkeeper as extra outfield support',
    'In a 6v6 possession game across zones, goalkeepers stand behind the zone and act as feet-only support for whichever side has the ball.',
    'Ball carrier is pressed with no forward option',
    'Use the keeper to escape pressure and restart circulation in the next zone.',
    NULL, 170, 170, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Stay available behind the play, play with feet only'),
    (2, 'Outfield players', 'Use the keeper as a bounce, then move the ball across zones')
) AS v(so, role, job);

-- 53. pp.171-171
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Fernando Gaspar - strength and conditioning circuit games', 'Whole team over halfway to score',
    'A goal only counts when every attacking player has crossed the halfway line, and counts double if an opponent is still stranded in the other half; defenders get few touches, attackers unlimited.',
    'Team builds an attack past halfway',
    'Push the whole block up behind the ball in attack, and punish opponents who fail to get back.',
    NULL, 171, 171, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Play quickly out (touch limit) and step up over halfway with the attack'),
    (2, 'Attacking players', 'Free touches to finish once the team is up'),
    (3, 'Defending team', 'Every player sprints back into own half')
) AS v(so, role, job);

-- 54. pp.172-172
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'advanced-spanish-academy-coaching-120-technical-tactical-and-conditioning-practi'), 'in_possession', 'Fernando Gaspar - strength and conditioning circuit games', 'Score through the wide outlets, quick restarts',
    '4v4 inside with each side''s extra players stationed round the edge; teams try to create goals via these outside players, who are limited to one touch, and the goalkeeper restarts at once when the ball goes dead.',
    'Inside players blocked centrally / ball out of play',
    'Use one-touch wide and end players to open the defence and keep the game tempo high.',
    NULL, 172, 172, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside players', 'Combine and look to release a wide outlet'),
    (2, 'Outside players', 'One-touch crosses and layoffs to set up the finish'),
    (3, 'Goalkeeper', 'Restart immediately when the ball goes out')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1976-coaching-book-advanced-spanish-academy-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
