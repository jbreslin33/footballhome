-- 5021 📚 Coaching book patterns: "Rondos & Positional Games: How to use
-- Spain's secret weapon" (Kieran Smith) — Kindle library (spreads s001–s029
-- from Kindle Cloud Reader).  Every spread read; each distinct team
-- behaviour a rondo / positional game trains written up in OUR OWN WORDS
-- with who does what.  Warm-up / technique rondos and front matter left out.
-- Owner's personal library.  (James 11/27 Kindle picks)
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    method_note = 'A short practical book on Spanish-style rondos and positional games: why rondos matter (tempo, overloads, passing lines, the free man), how they show up in match situations (playing out from the keeper, overloads, third-man combinations, changing zone), and a catalogue of rondos and positional games with progressions. Patterns are the match behaviours each practice trains, in our words. Kindle edition: page numbers are screen spreads.'
WHERE slug = 'kindle-rondos-positional-games';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games');

-- 1. pp.8-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', 'Tactical benefits of using rondos', 'Slow without pressure, fast when pressed',
    'After a switch into a zone with no pressure, keep the ball calmly; when pressure arrives, speed up and look for penetrative passes or the other side.',
    'Pressure arrives on the ball',
    'Control tempo instead of rushing every pass.',
    NULL, 8, 15, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Holds and waits to attract the defender before releasing'),
    (2, 'Supporting players', 'Prepare the penetrative or switching option for the moment pressure comes')
) AS v(so, role, job);

-- 2. pp.9-9
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', 'Overloading', 'Midfield 3v2 vs a flat 4-4-2',
    'Playing a 1-4-3-3 against a 1-4-4-2 gives three central midfielders against two; the team should deliberately route play through that central superiority.',
    'Opponent sets up with two central midfielders',
    'Use the extra central man to keep the ball and pull opponents out of position.',
    '4-4-2', 9, 9, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder', 'Sits between the opposing pair as the free man'),
    (2, 'Two interiors (8, 10)', 'Occupy the spaces either side of the opposing central pair')
) AS v(so, role, job);

-- 3. pp.9-10
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', 'Overloading', 'Overload chain from goalkeeper build-up',
    'Building from the goalkeeper, the team sees the pitch as a chain of small rondos: GK, centre backs and holding mid make 4v2/4v3 at the back, 4v2 with full backs, 3v1/3v2 triangles higher up and wide.',
    'Goal kick / GK in possession',
    'Keep the ball and move from one overloaded zone into the next where a new overload is easy to make.',
    NULL, 9, 10, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Acts as extra man to make the back 4v2'),
    (2, 'Centre backs', 'Split wide either side of the GK to stretch the first press line'),
    (3, 'Holding midfielder (4)', 'Drops into the gap to complete the back rondo'),
    (4, 'Full backs', 'Give width to form 4v2 triangles with CB and 4'),
    (5, 'Wingers and 8/10', 'Form 3v1 triangles in the next zone up')
) AS v(so, role, job);

-- 4. pp.10-11
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'out_of_possession', 'Maintaining possession in small spaces', 'Close the centre, press wide',
    'Medium/low block in 1-4-1-4-1 or 1-4-4-2 (Simeone''s Atletico style) shrinks the central space, leaves the wide areas open and then presses hard out wide with two or three players.',
    'Ball played into a wide area',
    'Deny the centre to possession sides and trap the ball against the touchline.',
    '4-1-4-1', 10, 11, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfield line', 'Stay compact and narrow, block passes through the middle'),
    (2, 'Nearest two or three players', 'Swarm the wide receiver aggressively'),
    (3, 'Touchline', 'Used as an extra defender to cut the escape route')
) AS v(so, role, job);

-- 5. pp.10-11
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', 'Maintaining possession in small spaces', 'Pin them and keep it centrally',
    'Against a compact block the team pins the opponent in its own half and keeps the ball in congested central spaces with very few touches, as players learn in tight rondos.',
    'Opponent drops into a compact medium/low block',
    'Control the central zone (Guardiola: the centre is the key part of a team) despite pressure.',
    NULL, 10, 11, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Play one/two touch in tight spaces, keep the ball under pressure'),
    (2, 'Attackers', 'Pin the back line in its own half')
) AS v(so, role, job);

-- 6. pp.11-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', 'Maintaining possession to change zone and affect the opponent', 'Overload one side to isolate far winger',
    'When our winger is better than his opponent, attract the opposition to one side and then switch quickly to him on the opposite side to create a 1v1 or 1v0.',
    'Qualitative superiority on the far side and opponent shifted across',
    'Give the best dribbler an isolated duel and a run at goal with the striker waiting.',
    NULL, 11, 23, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield group', 'Make several passes in the overloaded zone before releasing'),
    (2, 'Far-side winger', 'Hold width and wait, then take on his man 1v1'),
    (3, 'Centre forward', 'Attack the box for the finish after the 1v1')
) AS v(so, role, job);

-- 7. pp.11-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', 'Maintaining possession to change zone and affect the opponent', 'Draw the press, then change zone',
    'Keep the ball in an overloaded zone (e.g. a 4v2 from goal kicks played into midfield a few times) so the opponent commits more players there, then move the ball to an unmarked teammate in another zone.',
    'Opponent sends extra players to the ball zone after several passes',
    'Move the opponent rather than the ball and exploit the space they leave behind.',
    NULL, 11, 28, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players in the ball zone', 'Keep possession patiently, count passes, attract defenders'),
    (2, 'Free player in the far zone', 'Stay away from the cluster, move to receive when the ball is switched'),
    (3, 'Holding midfielder', 'Link pass to change zone'),
    (4, 'Outside players', 'After the switch, shift across to support the new zone')
) AS v(so, role, job);

-- 8. pp.12-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', 'Triangulation', 'Triangles at short distances',
    'Players keep at least two short passing options around the ball, roughly 10 yards apart, forming triangles that mirror rondo distances.',
    'Any possession phase',
    'Always have a safe passing line and keep correct spacing.',
    NULL, 12, 14, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Has two short options either side'),
    (2, 'Supporting players', 'Move to open a passing line based on ball position, about 10 yards away')
) AS v(so, role, job);

-- 9. pp.12-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', 'Third man concept', 'Third man release via full back',
    'Holding mid wants to reach a marked central midfielder; he passes to the same-side full back, the opponent shuffles across, the central midfielder steps slightly forward and receives from the full back as the free third man.',
    'Intended receiver is marked',
    'Use the opponent''s own pressure to free a player in a 3v1/3v2.',
    NULL, 12, 19, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder', 'Plays the second man (full back) instead of the marked target'),
    (2, 'Same-side full back', 'Second man: receives and finds the freed midfielder'),
    (3, 'Central midfielder', 'Small forward movement off his marker to become the third man')
) AS v(so, role, job);

-- 10. pp.13-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', '1st/2nd/3rd Line Passing', 'Look for the third line split pass',
    'Passes are classed: first line to a teammate alongside, second line past defenders but not between them, third line between two defenders (split pass). Midfield combinations move the defenders apart to open a split pass to the centre forward.',
    'Gap opens between two defenders',
    'Penetrate with the split pass whenever it is on.',
    NULL, 13, 17, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (4)', 'Circulates to shift the defenders, plays the split pass when it opens'),
    (2, 'Interiors (8, 10)', 'Move to drag the two defenders apart'),
    (3, 'Centre forward (9)', 'Hold position between lines to receive the third line pass')
) AS v(so, role, job);

-- 11. pp.16-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', 'Rondos: playing out from the back', 'Outnumber the first press line',
    'Playing out against two strikers uses GK, centre backs and holding mid as a 4v2; against three forwards pressing high the build-up adds the full backs (GK, CBs, FBs, DM) and plays around the press through the full backs.',
    'Opponent presses with two or three forwards',
    'Keep a numerical edge at the back and get round the press to the side away from it.',
    NULL, 16, 18, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Active as the spare man in the build-up'),
    (2, 'Centre backs', 'Spread wide to receive'),
    (3, 'Holding midfielder', 'Always the player inside the press, moves to be available between the forwards'),
    (4, 'Full backs', 'Hold width to play around the press and move the ball to the other side')
) AS v(so, role, job);

-- 12. pp.19-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', 'Rondos and positional games: midfield play', 'Patient midfield, then feed the striker',
    'The midfield trio combines with the front three and keeps possession patiently against an organised defence, then plays into the centre forward or behind the back line; supporting players join once the pass is made.',
    'Passing lane to the striker or space behind opens',
    'Progress through midfield and turn possession into a penetrative attack.',
    NULL, 19, 27, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield three', 'Combine, keep the ball and use different pass types to move defenders'),
    (2, 'Centre forward', 'Holds up between lines as the target'),
    (3, 'Wingers (7, 11)', 'Give width and depth to stretch the block'),
    (4, 'Supporting midfielders', 'Run forward to support after the pass into the striker')
) AS v(so, role, job);

-- 13. pp.20-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'to_defend', 'Team 4v2 transitional rondos', 'Instant defensive switch on losing ball',
    'When a player loses the ball, he and his partner immediately switch to a defending mindset and go together to win it back; in the multi-purpose 4v4+3 the losing side reacts quickly as the ball changes hands.',
    'Ball lost',
    'React immediately in pairs to press and regain.',
    NULL, 20, 21, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost the ball', 'Switches straight to defending and presses'),
    (2, 'His partner', 'Joins him to make the press a 2v1')
) AS v(so, role, job);

-- 14. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', '8v2 Rondo with rotational movement', 'Move after the pass, rotate into vacated space',
    'After a pass, players move and communicate so a teammate fills the space they leave, keeping the shape intact while positions rotate.',
    'A player leaves his position',
    'Keep structure and passing lines while players rotate.',
    NULL, 21, 21, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Moves off after passing'),
    (2, 'Teammate', 'Reads and fills the vacated space, communicating where it is')
) AS v(so, role, job);

-- 15. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', '5v3 and 4v3 Sectional Rondos', 'Build out, combine wide, cross',
    'After playing out from the GK with a few passes, the team finds the midfielder in the next zone, then combines in the wide attacking area and crosses for the striker.',
    'Build-up rondo secured',
    'Turn deep possession into a wide combination and cross.',
    NULL, 23, 23, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'GK and back players', 'Keep the ball to draw pressure'),
    (2, 'Midfielder', 'Receives and moves play to the wide attackers'),
    (3, 'Wide attackers', 'Combine in the wide area and deliver'),
    (4, 'Striker', 'Attacks the cross')
) AS v(so, role, job);

-- 16. pp.24-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', 'Positional games: distances and progression', 'Progress by zones, skip a zone',
    'Players hold their positional zones based on ball position, avoid passes within the same zone or backwards, keep width and depth, and when possible skip a zone with a penetrative pass; extra free players are found in the next zone.',
    'Free player available in a further zone',
    'Progress the ball up the pitch through a structured positional shape.',
    NULL, 24, 28, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'Spread to give width and depth from the back'),
    (2, 'Midfielders', 'Occupy separate receiving lines, move to support'),
    (3, 'Free player in further zone', 'Stays open to receive the line-skipping pass')
) AS v(so, role, job);

-- 17. pp.27-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'to_attack', '6v6+GKs - Switching play/Transition/Pressing', 'Aggressive press, fast transition on regain',
    'Out of possession the team presses aggressively; when it wins the ball it attacks quickly, using either direction of play.',
    'Ball won',
    'Exploit the opponent''s unorganised moment with a fast attack.',
    NULL, 27, 27, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players', 'Press the ball aggressively'),
    (2, 'Player who wins it', 'Plays forward or dribbles through quickly'),
    (3, 'Teammates', 'Break out to offer fast forward options')
) AS v(so, role, job);

-- 18. pp.29-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-rondos-positional-games'), 'in_possession', '6v5+4 Positional game - Inverted Fullbacks', 'Inverted full backs, wingers hold width',
    'Full backs move inside into midfield while the wingers do the opposite movement and stay wide, creating a central overload.',
    'Team in settled possession',
    'Overload the centre while keeping width.',
    NULL, 29, 29, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (2, 3)', 'Step inside next to the holding midfielder'),
    (2, 'Wingers (7, 11)', 'Contrary movement: stay high and wide'),
    (3, 'Holding midfielder (6)', 'Can drop between centre backs as full backs invert')
) AS v(so, role, job);

COMMIT;
