-- 2199 📚 Coaching book patterns: "Marcelo Bielsa: Thirteen Steps to the
-- Premier League" (Lee Scott, Pitch Publishing) — Kindle library (spreads
-- s001–s226 from Kindle Cloud Reader).  Every spread read by readers; each
-- distinct team behaviour written up in OUR OWN WORDS with who does what.
-- Biography, per-90 data, photo pages and front matter left out.  Owner's
-- personal library.  (James 11/27 picks 2,3,12,13,14,17,27,28,29,30,31)
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    team        = 'Leeds United (Marcelo Bielsa)',
    season      = '2018-21',
    method_note = 'An analyst''s study of Bielsa''s Leeds through their promotion and first Premier League season: the 4-1-4-1 / 3-3-1-3 structure, man-orientated marking, the minus-one press and its triggers, verticality (up-back-through, out-in-out), rotations (emptying the centre, vertical / horizontal / wide-diamond swaps), the wide players'' role, the free 8s, then player chapters on how Ben White, Stuart Dallas, Kalvin Phillips, Mateusz Klich, Pablo Hernandez, Jack Harrison and Patrick Bamford carry the model, ending with an anatomy of Leeds goals. Patterns are those on-pitch behaviours in our words; biography and data are left out. Kindle edition: page numbers are screen spreads.'
WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league');

-- 1. pp.8-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch1 4-1-4-1 or 3-3-1-3', 'Plus-one on the back line',
    'Leeds always keep one more defender on the first line than the opponent has strikers: two centre backs against one forward, three against two, which is why they toggle between 4-1-4-1 and 3-3-1-3.',
    'Opponent''s number of strikers',
    'There is always a free man to give cover behind the markers.',
    NULL, 8, 14, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Mark the strikers; one stays spare as the free man'),
    (2, 'Free centre back (Ben White)', 'Cover across the whole line'),
    (3, 'Coach / shape', 'Switch 4-1-4-1 to 3-3-1-3 when facing two strikers')
) AS v(so, role, job);

-- 2. pp.9-9
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch1 4-1-4-1 or 3-3-1-3', '6 drops into CB-FB slot',
    'Against a high aggressive press the single pivot does not split the centre backs but drops beside one of them, into the gap between centre back and full back.',
    'Opponent pressing the first line high',
    'Changes the angle of build-up and opens a vertical passing lane from a previously empty slot.',
    NULL, 9, 9, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Kalvin Phillips)', 'Drop into the half-space slot beside a centre back'),
    (2, 'Centre backs', 'Hold width, use the new angle to play forward'),
    (3, 'Full back', 'Push higher once the 6 fills the slot')
) AS v(so, role, job);

-- 3. pp.9-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch1 4-1-4-1 or 3-3-1-3', 'Inverted full back supports the 6',
    'In 4-1-4-1 build-up at least one full back moves into an inverted, central position beside the 6; in 3-3-1-3 the wing-backs start narrow or deep to help progression, then climb to overload wide later.',
    'Build-up phase',
    'Adds a passing option on the second line and links the back and front units.',
    NULL, 9, 14, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back / wing-back', 'Tuck inside next to the 6 early, push wide and high as ball progresses'),
    (2, '6', 'Use the extra option to progress'),
    (3, 'Ball-side full back', 'Overload the wide space once play reaches the final third')
) AS v(so, role, job);

-- 4. pp.9-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'to_defend', 'Ch1 4-1-4-1 or 3-3-1-3', 'Defensive triangle in front of the line',
    'In the 4-1-4-1 the 6 stays central or in a half-space, forming a triangle with the two centre backs; when the ball is lost he is first to cover the space in front of the defence.',
    'Loss of possession',
    'Opponent cannot quickly overload the zone in front of the back line or play into the strikers'' feet.',
    NULL, 9, 16, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Kalvin Phillips)', 'Screen centrally, step into space in transition'),
    (2, 'Centre backs', 'Form the base of the triangle')
) AS v(so, role, job);

-- 5. pp.9-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch1 4-1-4-1 or 3-3-1-3', 'Pivot switches to isolated winger',
    'Ball goes back to a centre back, then quickly into the 6, who hits a long diagonal to the far wide forward left one v one with the opposition full back.',
    'Opponent shifts to the ball side',
    'Switch the angle of attack quickly and isolate the weak-side winger.',
    NULL, 9, 16, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Recycle to the 6 at once'),
    (2, '6 (Kalvin Phillips)', 'Look vertical first; long diagonal to the far winger'),
    (3, 'Weak-side wide forward', 'Stay high and wide, attack the full back one v one')
) AS v(so, role, job);

-- 6. pp.10-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch1 4-1-4-1 or 3-3-1-3', 'Wingers high and wide pin the block',
    'Wide players hold the touchline high up so opposition defenders must mark them, which stops a deep compact block and leaves room centrally for 8s and striker.',
    'Attacking phase',
    'Stretch the defence and create one v one chances on the weak side.',
    NULL, 10, 14, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forwards (Harrison, Costa)', 'Stay high and wide, isolate the full back'),
    (2, '8s', 'Exploit the central room created'),
    (3, '9 (Patrick Bamford)', 'Occupy centre backs')
) AS v(so, role, job);

-- 7. pp.10-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch1 4-1-4-1 or 3-3-1-3', 'Enganche roams across the width',
    'In the 3-3-1-3 the single 8 (enganche, Klich) is the link between midfield and attack, drifting across the full width and into half-spaces to combine with wingers or wing-backs.',
    'Possession in middle third',
    'Overload the ball side and set the pace and angle of the attack.',
    NULL, 10, 14, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Enganche 8 (Mateusz Klich)', 'Drift into half-spaces, combine wide'),
    (2, 'Wing-backs', 'Occupy half-spaces in attack'),
    (3, 'Wide forwards', 'Isolate on the outside')
) AS v(so, role, job);

-- 8. pp.10-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch1 4-1-4-1 or 3-3-1-3', '9 links then attacks box space',
    'The 9 stays central or in a half-space to receive vertical passes with his back to goal and link play, then makes runs into empty areas of the penalty box once play reaches the final third.',
    'Vertical pass available / ball in final third',
    'Provide a target for vertical play and arrive in unguarded box space.',
    NULL, 10, 14, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '9 (Patrick Bamford)', 'Create separation, take vertical passes into feet, then run into box gaps'),
    (2, '8s / 6', 'Find the 9 vertically')
) AS v(so, role, job);

-- 9. pp.10-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch1 4-1-4-1 or 3-3-1-3', 'Free 8s join the front line',
    'In 4-1-4-1 both 8s push up close to the centre forward, forming a front five with the wingers and 9 and emptying the space between them and the 6; full backs link the two units.',
    'Ball progressed past the first line',
    'Create chaos in the opposition back line; the near 8 finds a pocket to take a vertical pass threatening the box.',
    NULL, 10, 20, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '8s (Klich, Hernandez)', 'Move high, find pockets near the 9'),
    (2, 'Near 8 on receiving', 'Play wide, through to the 9, or set back to the 6'),
    (3, '6', 'Stay deep with the centre backs'),
    (4, 'Full backs', 'Narrow/deep early, ball-side one overloads wide late')
) AS v(so, role, job);

-- 10. pp.17-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch1 4-1-4-1 or 3-3-1-3', '6 drags marker, 8 drops in',
    'In the 3-3-1-3 against a two-man press, with the +1 still kept on the first line, the 6 moves away from the ball to pull his marker out of the middle, and an 8 rotates back from a higher line into the vacated space.',
    '6 is marked tightly in build-up',
    '8 receives from the centre back in free central space.',
    NULL, 17, 18, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Kalvin Phillips)', 'Move left or right away from the ball to drag his man'),
    (2, '8', 'Drop into the emptied central zone'),
    (3, 'Centre back', 'Pass into the 8')
) AS v(so, role, job);

-- 11. pp.21-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch1 4-1-4-1 or 3-3-1-3', 'Winger inside, wing-back blind-side run',
    'Centre back plays into the feet of the wide forward, who has stretched the line; he lays the ball inside to the enganche while the wing-back runs off his marker''s blind side into the gap between full back and centre back, and the 8 plays him in.',
    'Vertical pass into winger''s feet with gap between FB and CB',
    'Wing-back breaks beyond the back line.',
    NULL, 21, 22, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Vertical pass into winger''s feet'),
    (2, 'Wide forward', 'Engage or lay inside to the 8'),
    (3, 'Enganche 8', 'Thread the ball into the gap'),
    (4, 'Wing-back', 'Blind-side run between full back and centre back')
) AS v(so, role, job);

-- 12. pp.23-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch2 Man-Orientated Marking', 'Man-orientated marking with a free man',
    'Unlike zonal handovers, every outfield Leeds player tracks a direct opponent all over the pitch (Koch following Firmino deep into midfield), except the spare centre back (White), who covers the line, and the 9, who blocks passing lanes back to the centre backs or presses.',
    'Opponent in possession',
    'Deny receivers time and space; the opponent''s movement does not break the shape.',
    NULL, 23, 28, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outfield markers', 'Stay tight to your own man wherever he goes'),
    (2, 'Free centre back (Ben White)', 'No man; cover across the line'),
    (3, '9', 'Screen passes back to centre backs or press'),
    (4, 'Goalkeeper', 'Not in the marking scheme')
) AS v(so, role, job);

-- 13. pp.24-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch2 Man-Orientated Marking', 'Cover comes from behind the ball',
    'When a Leeds player is beaten one v one centrally (e.g. 6 pulled up into a flat line with the 8s), the nearest players swap markings: an 8 sprints back in front of the carrier and the wide forward drops to pick up the man the 8 left. The free centre back or full backs do not step out.',
    'Marker beaten / opponent runs into space',
    'Rebalance without ever giving up the +1 on the first line.',
    NULL, 24, 32, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest 8 (Klich)', 'Burst back in front of the ball carrier'),
    (2, 'Wide forward (Harrison)', 'Sprint back and take over the 8''s man'),
    (3, 'Free centre back', 'Hold position, keep the +1'),
    (4, 'Full backs', 'Do not step out')
) AS v(so, role, job);

-- 14. pp.24-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'to_defend', 'Ch2 Man-Orientated Marking', 'Find your man, else cut the lane',
    'On losing the ball each player first locates and tightens onto his man; if he is too far away, he positions between the ball and that man (or another free attacker) to cut the passing lane, as Phillips does laterally.',
    'Immediate defensive transition, player out of position',
    'Delay progression and set up an interception and regain.',
    NULL, 24, 34, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Any player near his man', 'Get tight fast'),
    (2, 'Player caught out (Phillips)', 'Slide laterally into the passing lane to the free attacker'),
    (3, 'Free centre back', 'Stay back, do not step out')
) AS v(so, role, job);

-- 15. pp.29-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch2 Man-Orientated Marking', 'Spare defender covers balls in behind',
    'Full-pitch man-marking leaves mismatches such as a quick striker. When a marking centre back is beaten by a direct angled ball over the top, the free covering defender reads it and comes round to cover.',
    'Ball played in behind a marking defender',
    'Stop the chance on goal; this is why the +1 is never sacrificed.',
    NULL, 29, 30, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marking centre back', 'Track the striker'),
    (2, 'Covering free defender (White)', 'Read the pass early, swing round to cover')
) AS v(so, role, job);

-- 16. pp.35-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'to_attack', 'Ch2 Man-Orientated Marking', 'Sprint wide again on regain',
    'Wide forwards and wing-backs/full backs follow their men into central areas when defending; the moment Leeds win the ball (e.g. back to the keeper) they sprint back out to the touchlines.',
    'Regain of possession',
    'Make the pitch big immediately so build-up has width.',
    NULL, 35, 36, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forwards', 'Sprint out to the wide lanes'),
    (2, 'Full backs / wing-backs', 'Sprint out wide'),
    (3, 'Goalkeeper', 'Receive and restart')
) AS v(so, role, job);

-- 17. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch3 Pressing', 'Press angle set by ball location',
    'If the carrier is central, the presser angles his run to close the nearest passing lane; if he is wide, the run forces him towards the touchline, which acts as an extra defender.',
    'Position of the ball',
    'Remove the safe pass and steer the ball where Leeds can trap it.',
    NULL, 37, 37, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First presser', 'Curve to block nearest lane centrally, show outside when wide'),
    (2, 'Supporting presser', 'Same rule as the first')
) AS v(so, role, job);

-- 18. pp.37-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch3 Pressing', 'Minus-one press, man-to-man behind',
    'Leeds press the opponent''s centre backs with one player fewer than they build with: one presser against two centre backs (the 9), two against three (the 9 plus the ball-side wide forward); everyone else man-marks behind. If the press is broken they drop and keep marking.',
    'Opponent building from the back',
    'Stop comfortable progression and delay attacks while the rest lock onto their men; opponents dropping deep to help only pin themselves further back.',
    NULL, 37, 40, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '9 (Patrick Bamford)', 'Press the ball carrier, curving to cut the pass to the other centre back'),
    (2, 'Ball-side wide forward', 'Join the press against a back three'),
    (3, 'Rest of team', 'Man-mark everyone ahead of the ball'),
    (4, 'Free centre back', 'Keep balance at the back')
) AS v(so, role, job);

-- 19. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch3 Pressing', 'Wide trigger: inside-out press, corner trap',
    'The first presser closes the centre back from the inside, blocking the square pass, leaving only the near full back. When that pass goes, the presser carries on past the centre back to block the back pass to him or the keeper while teammates squeeze up on their men.',
    'Ball played out to the full back',
    'Pin the opponent in the corner and force a turnover.',
    NULL, 38, 38, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First presser', 'Press inside-out, then curve to cut the back pass'),
    (2, 'Near-side markers', 'Squeeze tight onto their men'),
    (3, 'Ball-side wide forward', 'Press the full back')
) AS v(so, role, job);

-- 20. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch3 Pressing', 'Trigger: receiver facing own goal',
    'A pass from the centre back into a deeper central midfielder is treated as a trap: when the receiver takes it facing his own goal, the marker presses at once from the goal side, with secondary pressure from an 8 or the nearest wide forward.',
    'Central receiver facing his own goal',
    'Deny the pass back into the centre backs and win the ball high up the pitch.',
    NULL, 38, 38, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Initial presser', 'Close from the goal side immediately'),
    (2, '8 or nearest wide forward', 'Add second pressure'),
    (3, 'Others', 'Squeeze up as opponents drop to support')
) AS v(so, role, job);

-- 21. pp.41-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch 3 Pressing', 'Press a back three: 9 plus one winger',
    'Opponent builds from three centre backs. The 9 presses the middle CB with a curved run that blocks one side, and the winger on the open side jumps onto his CB while the far winger tucks in to mark man for man.',
    'Middle centre back of a back three has the ball',
    'The receiving CB is pressed at once with the 9 ready to cut the pass back inside or to the keeper.',
    NULL, 41, 42, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Patrick Bamford)', 'Press the middle CB, run angled to shut one pass'),
    (2, 'Ball-side wide forward', 'Jump onto the CB whose lane the 9 left open'),
    (3, 'Far-side wide forward', 'Squeeze in and man-mark his nearest man'),
    (4, 'Midfield and back line', 'Tight man marking behind the press for balance')
) AS v(so, role, job);

-- 22. pp.43-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch 3 Pressing', 'Touchline pass pressing trigger',
    'In the opponent''s build-up the 9 blocks the pass across the back line, leaving the outlet to the full back near the line as the apparent escape.',
    'Ball arrives at a player standing on the touchline',
    'Trap the receiver against the line and force a hurried, uncontrolled pass that Leeds win back.',
    NULL, 43, 44, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Eddie Nketiah)', 'Press the CB and block the switch to the other CB'),
    (2, 'Two nearest ball-side players', 'Leave their men and press, curving runs to keep their old man in the cover shadow'),
    (3, 'Third nearby midfielder', 'Step in front of the line-down pass and cut it')
) AS v(so, role, job);

-- 23. pp.45-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch 3 Pressing', 'Receiver facing own goal trigger',
    'The 9 presses the goalkeeper on an angle that removes one option, inviting a vertical pass into the opposition 6 who must receive with his back to play.',
    'Central receiver gets the ball facing his own goal',
    'Swarm the turned receiver, make any back pass dangerous, and attack the goal quickly after the regain.',
    NULL, 45, 46, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Patrick Bamford)', 'Angle the press on the keeper, then drop back to cut passes to the CBs'),
    (2, 'Three closest Leeds players', 'Converge on the receiver from all sides'),
    (3, 'All attackers after regain', 'Flood forward into the area at once')
) AS v(so, role, job);

-- 24. pp.47-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch 3 Pressing', 'Recover when the press is played through',
    'An 8 gets drawn forward to help the 9 and a vertical pass reaches the free man he left, breaking the man-marking chain.',
    'Pass played through or behind the first press line to a free man',
    'Immediately re-engage the new ball carrier so defensive balance between ball and goal is kept.',
    NULL, 47, 50, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near-side wide forward', 'Leave his man and sprint back to press the new carrier'),
    (2, 'Out-of-position 8 (Mateusz Klich)', 'Recover his position and join the press on the ball'),
    (3, 'Striker (Patrick Bamford)', 'Redirect his run toward the new receiver')
) AS v(so, role, job);

-- 25. pp.51-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 4 Verticality', 'Verticality pass priority ladder',
    'Every Leeds player on the ball scans a fixed order of progressions: in behind the back line centrally, in behind wide, between the lines centrally, between the lines wide, then between first and second opposition lines centrally and wide.',
    'Any player receives the ball, in build-up or transition',
    'Pick the most forward pass that is still clean, so the ball moves through the thirds fast but under control.',
    NULL, 51, 52, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player in possession', 'Check team-mates on the furthest line first, then pockets, then the pressure on himself'),
    (2, '6 (Kalvin Phillips)', 'Main progressor; drop into the back line to make three when the angle must change'),
    (3, '8s', 'Push up into advanced spots ahead of the defensive line'),
    (4, 'Centre backs', 'Switch the ball across the first line when no vertical lane exists')
) AS v(so, role, job);

-- 26. pp.53-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 4 Verticality', '8 drops to take vertical pass from CB',
    'With the centre back unpressed on the first line, he ignores the safe pass to the full back or other CB. An 8 who had pushed high drops off his marker into the gap between the lines to take the split pass.',
    'First-line CB has time and the 8 drops back toward the ball',
    'One pass skips four or five opponents and creates an overload against the defensive line.',
    '4-5-1', 53, 58, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Liam Cooper / Ben White)', 'Look past safe options and play the clean vertical pass'),
    (2, '8 (Mateusz Klich / Pablo Hernandez)', 'Drop back from the high line to break from his marker and receive'),
    (3, 'Full back (Stuart Dallas)', 'Safe option that is passed over')
) AS v(so, role, job);

-- 27. pp.55-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 4 Verticality', '9 drops, winger runs into vacated centre',
    'The 9 drops toward the ball and drags a centre back with him. That empties the central space, which the far-side winger attacks on a diagonal run.',
    'CB on the ball and the 9 checks back pulling his marker',
    'Pass in behind to the diagonal runner takes all ten outfield opponents out of the game.',
    NULL, 55, 56, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Patrick Bamford)', 'Drop into the link role and pull a defender out'),
    (2, 'Left winger (Jack Harrison)', 'Diagonal run from outside into the hole'),
    (3, 'Centre back (Ben White)', 'Play past the easier options into the space')
) AS v(so, role, job);

-- 28. pp.59-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 4 Verticality', 'Up, back and through',
    'Two forward passes linked by a one-touch set-back: a vertical pass into a forward or 8, set back to a supporting player, who plays the second pass through the line for a diagonal run.',
    'Pressed or with a forward player showing for a vertical pass',
    'Quick one-touch tempo beats the press and sends a runner in behind between CB and full back.',
    NULL, 59, 60, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Liam Cooper)', 'Escape the striker''s press with an immediate vertical pass'),
    (2, '8 (Mateusz Klich)', 'Set the ball back first time'),
    (3, 'Full back inverting (Stuart Dallas)', 'Come inside and play the first-time through pass'),
    (4, 'Winger (Jack Harrison)', 'Run diagonally into the CB-FB gap')
) AS v(so, role, job);

-- 29. pp.61-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 4 Verticality', 'Out, in and out',
    'Variant of up-back-through using wide lanes: the 6 passes out to a winger who comes inside to the half-space, he sets back to the near 8, who plays first time diagonally out into the wide space.',
    '6 on the ball with no clean vertical lane',
    'Release the overlapping full back wide and behind the line into the box.',
    NULL, 61, 62, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Kalvin Phillips)', 'Play out to the half-space'),
    (2, 'Right winger (Helder Costa)', 'Come inside to receive and set back'),
    (3, 'Near-side 8 (Pablo Hernandez)', 'First-time diagonal pass out wide'),
    (4, 'Right back (Luke Ayling)', 'Run beyond into the wide channel behind the line')
) AS v(so, role, job);

-- 30. pp.63-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 4 Verticality', 'Switch to free first-line man',
    'When no vertical pass is on, the middle player of the first line passes sideways to an unpressed team-mate, who restarts the progression. The 6 moves late to drag a midfielder away and open a vertical lane to the 10.',
    'No vertical option for the first-line ball carrier',
    'Reset the angle and find the attacking midfielder who can turn and run at the back line.',
    NULL, 63, 64, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle CB in 3-3-1-3', 'Pass sideways to the free man'),
    (2, 'Wide first-line player', 'Restart the progression, look vertical first'),
    (3, '6 (Kalvin Phillips)', 'Late movement to pull a defender out of the lane'),
    (4, 'Attacking midfielder', 'Receive between the lines and turn')
) AS v(so, role, job);

-- 31. pp.65-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 5 Rotations', 'Empty the centre, 5+5 split',
    'Unlike most coaches, Bielsa leaves the centre empty: the 8s push up toward the 9 and the wingers go wide, splitting the team into a first block of five and a second of five. Full backs step inside, and 8s drop back into the space only to receive.',
    'Ball on the first line against a passive press',
    'Stretch the opponent''s midfield and control the centre without standing in it, opening vertical passes.',
    NULL, 65, 68, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two 8s', 'Move up toward the 9, then drop back into the empty middle on cue'),
    (2, 'Wide forwards', 'Diagonal runs out to the wide lanes'),
    (3, 'Full backs', 'Step inside into the empty central area when needed'),
    (4, 'CB and 6 (Ben White, Kalvin Phillips)', 'Passing range to hit the space')
) AS v(so, role, job);

-- 32. pp.69-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 5 Rotations', 'Vertical rotation: drop and replace',
    'A higher player drops toward the ball and pulls his marker out of slot, while a team-mate moves up into the space left behind (or one player alone drops or rises).',
    'Winger checks back toward the ball and the defender follows',
    'The 6 can play the vertical pass into the runner in the vacated space.',
    NULL, 69, 70, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Helder Costa)', 'Drop toward the ball to drag a defender'),
    (2, '8 (Pablo Hernandez)', 'Run up into the space left behind'),
    (3, '6 (Kalvin Phillips)', 'Play the vertical pass')
) AS v(so, role, job);

-- 33. pp.71-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 5 Rotations', 'Horizontal rotation: blind-side free man',
    'A player shifts sideways out of his slot; if his marker follows, a team-mate who was hidden behind moves on the defender''s blind side into the lane.',
    'CB wants the pocket between the lines but no clean lane',
    'Open a clean pass between the lines and set up an attacking platform.',
    NULL, 71, 72, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Kalvin Phillips)', 'Move from centre into the left half-space to draw a key defender'),
    (2, '8 (Mateusz Klich)', 'Slip on the defender''s blind side to show for the vertical pass'),
    (3, 'Centre back', 'Play the vertical pass through')
) AS v(so, role, job);

-- 34. pp.73-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 5 Rotations', 'Wide diamond rotation',
    'In wide build-up Leeds form a loose diamond: CB, full back or 6 at the base, winger at the tip, 8 inside. The winger drops diagonally toward the ball, the 8 rotates out into the space he left, and the full back runs beyond.',
    'CB with time on the ball and the winger drops diagonally',
    'Overload the flank and stretch the back line vertically, with the ball playable to either level.',
    NULL, 73, 74, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Helder Costa)', 'Drop diagonally to pull his defender'),
    (2, 'Right 8 (Pablo Hernandez)', 'Rotate into the space the winger created and receive'),
    (3, 'Right back (Luke Ayling)', 'Overlap beyond the ball'),
    (4, 'Centre back (Ben White)', 'Base of the diamond, play into the rotation')
) AS v(so, role, job);

-- 35. pp.75-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 5 Rotations', '8 goes wide, 9 drops into hole',
    'The half-space 8 rotates out toward the touchline and his defender goes with him, opening a central pocket the 9 drops into.',
    'Defender follows the 8''s move out wide',
    'Easy vertical pass from the CB to the dropping 9.',
    NULL, 75, 76, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '8 (Pablo Hernandez)', 'Rotate out to the wide area taking his marker'),
    (2, 'Striker (Patrick Bamford)', 'Drop into the vacated pocket'),
    (3, 'Centre back (Ben White)', 'Play the vertical pass')
) AS v(so, role, job);

-- 36. pp.77-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 5 Rotations', 'Full back dribbles into rotated space',
    'With pass options open, the full back instead watches an 8 rotate from the half-space out wide, pulling a defender, and carries the ball himself through the vacated half-space.',
    'Defender pulled out of the half-space by an 8''s rotation',
    'The carry forces another defender to step out, opening a pocket for a team-mate to receive; key against low blocks.',
    NULL, 77, 78, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Luke Ayling)', 'Drive inside through the half-space with the ball'),
    (2, '8 (Mateusz Klich)', 'Rotate from half-space to wide, pulling a defender'),
    (3, 'Nearby attackers', 'Fill the pocket the stepping defender leaves')
) AS v(so, role, job);

-- 37. pp.79-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 6 Role of the Wide Players', 'Wingers pin touchline to stretch line',
    'In build-up both wide forwards stay wide on the touchline, whether in 4-1-4-1 or 3-3-1-3. If the full back tucks in, the winger is free; if he goes out, a gap opens inside for the 8s.',
    'Build-up phase',
    'Stop the back line staying compact and give the opposition full back a dilemma.',
    NULL, 79, 80, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forwards (Helder Costa, Jack Harrison)', 'Hold width on the touchline'),
    (2, '8s', 'Move into the gap if the full back goes wide')
) AS v(so, role, job);

-- 38. pp.79-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 6 Role of the Wide Players', 'Overload right, switch to isolate',
    'Leeds overload the ball side, usually the right (Hernandez with Costa and Ayling), drawing the block over, while the far winger holds his width.',
    'Opposition block shifted to the overloaded flank',
    'Switch quickly to the far winger to attack his full back one v one (also mirrored on the left).',
    NULL, 79, 80, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right 8 (Pablo Hernandez)', 'Find pockets on the right to anchor the overload'),
    (2, 'Right winger (Helder Costa)', 'Combine inside on his left foot'),
    (3, 'Left winger (Jack Harrison)', 'Stay wide, take the switch and go one v one'),
    (4, '6 (Kalvin Phillips)', 'Switch play side to side quickly')
) AS v(so, role, job);

-- 39. pp.80-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch 6 Role of the Wide Players', 'Wide forward pressing and recovery role',
    'Whether a winger joins the first press depends on the opponent''s build-up numbers (the -1 rule): versus three CBs, or two CBs with a dropping 6, the ball-side winger presses with the striker while the other marks his man. Wingers also track their opponent deep or swap marks when a team-mate is beaten.',
    'Opponent builds with three on the first line, or the press is broken',
    'Stop clean progression and keep the man-marking shape whole, winning the ball back in the opponent''s half.',
    NULL, 80, 80, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side wide forward', 'Join the striker''s press'),
    (2, 'Far-side wide forward', 'Man-mark his most direct opponent, ready to join on a trigger'),
    (3, 'Both wide forwards', 'Recovery runs to track runners or take over a beaten team-mate''s man')
) AS v(so, role, job);

-- 40. pp.81-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 6 Role of the Wide Players', 'Touchline wingers stretch a compact low block',
    'Opponents sit deep and narrow and slide across as a unit with the ball, leaving no pockets in the middle. Leeds keep both wingers on the touchline while the two 8s push high.',
    'Opponent drops into a deep, compact block',
    'Each full back must pick between staying narrow and leaving the winger free, or going wide and opening a central pocket for the 8s.',
    NULL, 81, 84, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (Costa, Harrison)', 'stay wide on the touchline to pin the full backs'),
    (2, 'Two 8s', 'push high into the half-spaces between the lines'),
    (3, 'Ball carrier', 'keep circulating so the block has to keep making choices')
) AS v(so, role, job);

-- 41. pp.85-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 6 Role of the Wide Players', 'Overload ball side, isolate far winger',
    'Leeds attack down the right and build a 4v3 in the right half-space and flank with full back, 8 and winger, with Ben White feeding from the base. The left winger refuses to drift in and stays wide, 1v1 with his full back.',
    'Opponent shifts across to cope with the ball-side overload',
    'Either play through the 4v3 or switch quickly to the isolated far winger.',
    NULL, 85, 86, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'joins the overload on the right'),
    (2, 'Right 8 (Hernandez)', 'takes the right half-space inside the overload'),
    (3, 'Right winger (Costa)', 'holds width in the overload'),
    (4, 'Left winger (Harrison)', 'stays wide on the far side, 1v1 with the full back'),
    (5, 'Centre back (White)', 'chooses between the overload and the switch')
) AS v(so, role, job);

-- 42. pp.87-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 6 Role of the Wide Players', 'Up-back-through: winger''s blind-side diagonal run',
    'On the edge of the box against a flat back line spaced too wide, the striker drops to take a pass with his back to goal and sets it off to an 8. The far winger runs diagonally on the defender''s blind side.',
    'Striker drops and receives with back to goal; line watches him',
    'The 8 slides the ball past the line into the winger''s run for a chance on goal.',
    NULL, 87, 88, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Bamford)', 'drops short, receives and lays off first time'),
    (2, '8 (Klich)', 'receives the set and plays through the line'),
    (3, 'Winger (Harrison)', 'diagonal run on the blind side, behind the line')
) AS v(so, role, job);

-- 43. pp.89-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch 6 Role of the Wide Players', 'Winger joins the press vs back three (-1 rule)',
    'When the opponent builds with three centre backs, the -1 rule means Leeds need two players pressing the first line. The 9 presses the middle centre back and angles his run to cut the pass to one side, and the near winger steps up onto the wide centre back.',
    'Opponent builds up with three centre backs',
    'Stop clean progression from the first line; the far winger drops to mark his man.',
    NULL, 89, 90, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (9)', 'presses the middle centre back, run curved to block one passing lane'),
    (2, 'Ball-side winger', 'reads the back three and jumps onto the wide centre back'),
    (3, 'Far winger', 'drops to man-mark his nearest opponent, ready to join if a trigger fires')
) AS v(so, role, job);

-- 44. pp.91-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'to_attack', 'Ch 6 Role of the Wide Players', 'Wide forwards break wide on regain',
    'When Leeds win the ball in midfield against a central attack, the wide forwards sprint into the half-spaces and wide channels at once, trusting team-mates to keep the ball and play forward.',
    'Ball regained in central midfield',
    'Stretch the disorganised defence and open gaps for a fast vertical attack.',
    NULL, 91, 92, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forwards', 'sprint into the half-space or wide lane immediately'),
    (2, 'Midfield winner of the ball', 'keep it and look for the vertical pass')
) AS v(so, role, job);

-- 45. pp.93-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 7 Free 8s', 'Free 8s on advanced platforms',
    'In the 4-1-4-1 the two 8s push high as soon as build-up starts, leaving the centre empty, while the wingers hold width. The 8s settle in pockets between the opposing midfield and back lines (''advanced platforms'', Joey Lombardi''s term), with the 6 as the main progressor.',
    'Leeds start their build-up',
    'Give a safe receiving spot between the lines for vertical passes, then attack from there in the final third.',
    NULL, 93, 94, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two 8s (Klich, Hernandez)', 'move high into pockets between the lines and act as link players'),
    (2, '6 (Phillips)', 'stays at the base and progresses the ball'),
    (3, 'Wingers', 'keep width so the half-space pockets stay open')
) AS v(so, role, job);

-- 46. pp.95-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'to_attack', 'Ch 7 Free 8s', '8s hold split platforms after a regain',
    'After the left back wins a duel deep in his own half, the 8s move up for the attack but stop short of the top line. One holds a space on the left and one on the right.',
    'Possession regained after an opponent attack',
    'Give an advanced platform to build from instead of going too high too early.',
    NULL, 95, 96, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Dallas)', 'wins the duel and plays out'),
    (2, 'Left 8', 'takes a pocket of space on the left, not too high'),
    (3, 'Right 8', 'takes a matching pocket on the right')
) AS v(so, role, job);

-- 47. pp.97-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 7 Free 8s', 'Far 8 crosses over to overload',
    'The right 8 leaves his zone and moves across into the area the left 8 is in, behind the opposing midfielder''s blind side and between their midfield and back lines. The right back then plays into that crowded zone.',
    'Weak spot in the defence on the other side of the pitch',
    'Create a surprise overload between the lines and play through it.',
    NULL, 97, 98, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right 8 (Hernandez)', 'moves across on the midfielder''s blind side into the far half-space'),
    (2, 'Left 8 (Klich)', 'holds his zone to complete the overload'),
    (3, 'Right back (Ayling)', 'plays into the overloaded area')
) AS v(so, role, job);

-- 48. pp.99-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 7 Free 8s', '8 runs behind full back for a long pass',
    'Short options are open, but the 8 sprints from his slot into the half-space behind the opposing left back. The centre back passes over the line into that run.',
    '8 starts a run into the space behind the full back',
    'Go past the defence in one pass and threaten goal straight away; mix in direct passing rather than only short combinations.',
    NULL, 99, 100, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '8 (Hernandez)', 'runs from midfield into the half-space behind the full back'),
    (2, 'Centre back (White)', 'plays the lofted pass over the back line')
) AS v(so, role, job);

-- 49. pp.101-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch 7 Free 8s', '8s jump on the receiver facing his goal',
    'The keeper plays out to the right back, who is put under pressure and forces a loose pass into midfield. Both 8s jump together on the central receiver, who has his back to Leeds'' attack.',
    'Central receiver facing his own goal, or a loose pass into midfield',
    'Win the ball high in the opponent''s half and attack the edge of the box at once.',
    NULL, 101, 102, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two 8s', 'time the jump together and hunt the ball aggressively'),
    (2, 'Near-side presser', 'put pressure on the full back to force the loose pass')
) AS v(so, role, job);

-- 50. pp.103-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 7 Free 8s', '8 checks out, turns, switches behind',
    'The 6 plays a diagonal pass wide to the full back. The 8 moves slightly toward the ball while staying in the half-space, takes the next pass, then turns away from the ball side instead of returning it to the near winger.',
    '8 receives facing the play in the half-space',
    'A diagonal pass beats the back line into the far winger''s run in behind.',
    NULL, 103, 104, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Phillips)', 'plays the diagonal out to the full back'),
    (2, 'Full back (Alioski)', 'receives wide and finds the 8'),
    (3, '8 (Klich)', 'moves toward the ball in the half-space, turns out and plays the diagonal'),
    (4, 'Far winger', 'runs in behind the back line')
) AS v(so, role, job);

-- 51. pp.105-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 7 Free 8s', 'Winger inverts, 8 takes wide pocket',
    'The right winger moves inside and his full back follows him, which empties the wide area. The right 8 rotates into that pocket, takes the ball wide and immediately plays across into the far side of the box.',
    'Full back follows the inverting winger',
    'The far winger arrives on a diagonal run to meet the ball at the back post.',
    NULL, 105, 106, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Costa)', 'comes inside and drags the full back with him'),
    (2, 'Right 8 (Hernandez)', 'rotates into the wide pocket and delivers first time'),
    (3, 'Far winger (Harrison)', 'diagonal run to the far side of the box')
) AS v(so, role, job);

-- 52. pp.107-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch 8 Ben White', 'Spare centre back as free man',
    'In man-oriented defending, one centre back marks the striker and the other stays free to read play and cover. In a 2v2 after a loss of the ball, when his partner loses his footing, the free man holds a central position rather than diving in.',
    '2v2 or 2v1 break against the centre backs',
    'Delay, then win the ball cleanly when the carrier takes a heavy touch, and carry it out.',
    NULL, 107, 116, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marking centre back (Cooper)', 'takes the striker and wins first contacts'),
    (2, 'Free centre back (White)', 'spare man: covers, holds the middle, jumps on a heavy touch')
) AS v(so, role, job);

-- 53. pp.109-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 8 Ben White', 'Centre back drives into the vacated lane',
    'With no pressure on him near halfway, the centre back waits instead of hitting a hopeful long ball. The 8 ahead of him rotates out into the half-space, opening a lane, and he carries the ball through it while the striker drops toward the ball and then spins in behind.',
    '8 ahead of the ball rotates out and opens a lane',
    'Pull defenders out to the carrier so space opens elsewhere, then play the vertical pass behind.',
    NULL, 109, 118, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (White)', 'carries forward through the opened lane'),
    (2, '8 directly ahead', 'rotates out of his slot to open the lane'),
    (3, 'Striker (Bamford)', 'drops toward the ball, then spins in behind')
) AS v(so, role, job);

-- 54. pp.111-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 8 Ben White', 'Centre back''s diagonal switch to isolated winger',
    'After a throw-in, an overload forms on the ball side and there are vertical passes on, but the centre back opens his body and hits a long diagonal pass. It finds the far winger, who is 1v1 with his full back.',
    'Overload forming on the ball side with the far winger isolated',
    'Bypass the shifted block and give the far winger a 1v1.',
    NULL, 111, 112, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (White)', 'opens his body and plays the long diagonal'),
    (2, 'Far winger (Harrison)', 'holds width, isolated against the full back'),
    (3, 'Right back (Ayling)', 'restarts and helps build the ball-side overload')
) AS v(so, role, job);

-- 55. pp.113-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 8 Ben White', 'Fake the switch, play vertical behind',
    'The centre back has the ball in his half-space with the usual diagonal to the far winger on. He opens his body as if to switch, and the striker runs across the front of the defenders and in behind.',
    'Defence shifts to stop the expected switch while the striker runs across them',
    'Play the vertical pass behind the line for a goal chance.',
    NULL, 113, 114, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (White)', 'shows the switch, then plays vertical in behind'),
    (2, 'Striker (Bamford)', 'runs across the face of the line, then in behind'),
    (3, 'Far winger (Harrison)', 'stays wide so the switch looks real')
) AS v(so, role, job);

-- 56. pp.119-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'to_attack', 'Ch 8 Ben White', 'Composed carry after winning the long ball',
    'The opponent tries a quick long ball. One centre back wins the header and knocks it down to his partner while a forward rushes in to press. The partner keeps the ball instead of clearing it.',
    'Second ball dropping to the centre back under a fast press',
    'Dribble past the presser, carry into the opponent''s half and slide a pass through the line for a winger''s run.',
    NULL, 119, 120, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marking centre back (Cooper)', 'wins the aerial duel and heads it down to his partner'),
    (2, 'Free centre back (White)', 'controls, beats the presser, carries forward, plays through'),
    (3, 'Winger (Costa)', 'runs in behind for the through ball')
) AS v(so, role, job);

-- 57. pp.122-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 9 Stuart Dallas', 'Inverted full back when ball far side',
    'With the ball on the opposite flank, the left back (Dallas) drifts inside into a midfield slot next to the 6 instead of holding width.',
    'Ball switched or held on the far side',
    'Supports the 6 centrally so both 8s can stay high, pulls a marker inside and leaves the winger isolated 1v1 on that flank.',
    NULL, 122, 122, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Dallas)', 'Step inside to the half-space or next to the 6'),
    (2, '6 (Phillips)', 'Use the extra central support to circulate'),
    (3, 'Two 8s', 'Hold higher positions'),
    (4, 'Left winger (Harrison)', 'Stay wide and attack the isolated defender')
) AS v(so, role, job);

-- 58. pp.123-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 9 Stuart Dallas', 'Full back drives half-space, wall pass, vertical ball',
    'Leeds v Stoke: unpressed left back carries the ball from his own half into the half-space, plays a one-two with the advanced 8, then from a more central angle splits the back line for the striker''s diagonal run.',
    'No pressure on the full back in his own half',
    'Break the last line with a vertical pass into the 9 running in behind.',
    NULL, 123, 124, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Dallas)', 'Drive into the half-space, give and go, play the vertical through ball'),
    (2, 'Left 8 (Klich)', 'Offer a return pass ahead of the ball'),
    (3, 'Striker (Bamford)', 'Diagonal run across and behind the back line')
) AS v(so, role, job);

-- 59. pp.125-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 9 Stuart Dallas', '8 rotates wide to open the half-space lane',
    'Leeds v Luton: with the left back already in the half-space, the 8 runs out past the winger into the wide channel, pulling a defender away; the winger lays the ball inside to the full back.',
    '8 vacates the half-space and drags his marker',
    'Open a vertical lane from the half-space to the striker, who checks toward the ball then spins in behind.',
    NULL, 125, 126, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left 8 (Klich)', 'Rotate from the half-space out wide, beyond the winger'),
    (2, 'Left winger (Harrison)', 'Receive and play inside to the full back'),
    (3, 'Left back (Dallas)', 'Sit in the half-space, play vertically'),
    (4, 'Striker (Bamford)', 'Come short then turn and run behind')
) AS v(so, role, job);

-- 60. pp.127-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 9 Stuart Dallas', 'Winger cuts in, full back runs outside',
    'Leeds v Huddersfield: the winger dribbles inside from the left channel, taking his marker with him, and combines with the 10; the full back reads it, runs outside rather than inside, and gets the ball in the vacated wide space.',
    'Winger carrying inside drags a defender with him',
    'Free the full back running forward on the outside to attack the flank.',
    NULL, 127, 128, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Harrison)', 'Carry inside, pull marker, play combination'),
    (2, '10 (Hernandez)', 'Combine, then pass first time out wide'),
    (3, 'Left back (Dallas)', 'Start behind the ball, run outside into the vacated space')
) AS v(so, role, job);

-- 61. pp.129-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 9 Stuart Dallas', 'Drive at the block instead of switching',
    'Leeds v Bristol City: Leeds overload the right side with one player isolated on the left; the inverted left back on the edge of the overload gets a reset pass, but instead of switching he carries straight at the block.',
    'Reset pass to the central player on the edge of the overload',
    'Make the block step up, then slide the through ball to the striker moving laterally on the blind side of two defenders.',
    NULL, 129, 130, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back inverted (Dallas)', 'Receive the reset, drive at the block, play the through ball'),
    (2, 'Right-side overload players', 'Hold the block over to the ball side'),
    (3, 'Striker (Bamford)', 'Drift sideways on defenders'' blind side to run in behind'),
    (4, 'Isolated left winger', 'Hold width to keep the switch on as a threat')
) AS v(so, role, job);

-- 62. pp.131-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 9 Stuart Dallas', 'Half-space cross to far-side full back',
    'Leeds v Brentford: left back in the half-space with the 8 rotated out wide; the winger plays back to him. He fakes carrying forward, then swings a cross to the back post for the opposite full back''s late run.',
    'Lay-back to an unpressed full back in the half-space',
    'Hit the far-side full back arriving unmarked at the back post.',
    NULL, 131, 132, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Dallas)', 'Receive in the half-space, pause, cross early'),
    (2, 'Left 8 (Klich)', 'Hold the wide rotated position'),
    (3, 'Left winger (Harrison)', 'Play back inside to the full back'),
    (4, 'Right back (Ayling)', 'Sprint from the far touchline into the box')
) AS v(so, role, job);

-- 63. pp.133-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch 9 Stuart Dallas', 'Jump the loose pass in their half',
    'Leeds v Millwall: when the opponent builds through their full back to wide midfield and the next pass inside is loose, the nearby Leeds full back steps in aggressively to win it high up.',
    'Loose or under-hit pass inside from the opponent''s wide midfielder',
    'Win the ball cleanly in the opponent''s half and attack at once.',
    NULL, 133, 134, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Dallas)', 'Track his man closely, step in and intercept'),
    (2, 'Man-markers nearby', 'Stay tight to cut the other short options')
) AS v(so, role, job);

-- 64. pp.135-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 10 Kalvin Phillips', 'Single-pivot 6 as fixed reference',
    'In both the 4-1-4-1 and 3-3-1-3 shapes the 6 always plays as a lone pivot holding the centre, while others rotate high and low around him.',
    'Any Leeds possession',
    'Give the team a constant central reference to build around and be in place to stop counters.',
    NULL, 135, 135, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Phillips)', 'Hold central space, never join the rotations'),
    (2, '8s, wingers, full backs', 'Rotate around the fixed pivot'),
    (3, '9 (Bamford)', 'Second fixed reference up front')
) AS v(so, role, job);

-- 65. pp.136-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 10 Kalvin Phillips', '6 drops beside centre backs (+1)',
    'Against a front two pressing the two centre backs, the 6 drops into the back line to make three, going to the side of a centre back rather than between them; this lets the full back on that side push higher. Shown v Sheffield Wednesday, where he drops to the right of White and Cooper.',
    'Two forwards press the two centre backs',
    'Make a 3v2 so the centre back escapes with a sideways pass, and the 6 can then play a vertical ball in behind.',
    NULL, 136, 140, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Phillips)', 'Drop outside a centre back, receive, play vertically'),
    (2, 'Centre back (White)', 'Pass laterally to the dropped 6'),
    (3, 'Other centre back (Cooper)', 'Complete the back three'),
    (4, 'Full back on drop side', 'Advance to a higher line'),
    (5, 'Winger', 'Run in behind for the vertical pass')
) AS v(so, role, job);

-- 66. pp.136-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'to_defend', 'Ch 10 Kalvin Phillips', '6 as first line in transition',
    'When Leeds lose the ball, the 6 is the first defender: he reads the counter, steps out to the carrier or shifts across to a receiver in the centre before they reach dangerous areas. V Swansea, after quick vertical passes found a free central man, he moved across and won it back.',
    'Ball lost and the opponent tries a quick vertical attack',
    'Stop the transition at source and win the ball back centrally.',
    NULL, 136, 144, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Phillips)', 'Step out early to engage the carrier or central receiver'),
    (2, 'Centre backs', 'Hold the line behind the engaging 6')
) AS v(so, role, job);

-- 67. pp.137-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 10 Kalvin Phillips', '6 chips over a deep block',
    'Leeds v Cardiff: sustained pressure pins the opponent deep, so the 6 gets the ball about 30 yards out; a defender steps out to close a Leeds player, freeing the man behind him.',
    'A defender leaves the line to close down, and the 6 is then pressed',
    'Lift the ball over the back line into the box for the freed runner.',
    NULL, 137, 138, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Phillips)', 'Push up high, receive, chip over the line'),
    (2, 'Advanced attacker', 'Draw a defender out of the line'),
    (3, 'Freed runner', 'Attack the space behind into the box')
) AS v(so, role, job);

-- 68. pp.141-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 10 Kalvin Phillips', '6 carries into space, then vertical pass',
    'Leeds v Blackburn: in a stretched game the 6 picks up the ball near his own box; the opponent''s midfield retreats to cover the high 8s, so he carries almost to halfway.',
    'Space in front because the opponent midfield drops to mark the high 8s',
    'When a midfielder finally presses, release a vertical pass behind the defence for a forward''s run.',
    NULL, 141, 142, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Phillips)', 'Carry forward into the open space, pass once engaged'),
    (2, 'Two 8s', 'Stay high to pin the opponent midfield'),
    (3, 'Striker', 'Spin in behind for the pass')
) AS v(so, role, job);

-- 69. pp.145-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch 10 Kalvin Phillips', 'Recovery press from behind the ball',
    'Leeds v Luton: when a direct pass beats the high press, the 6 chases the receiver from behind, makes him turn back toward his own goal, and keeps pressing the next carrier when the ball is moved on.',
    'Forward pass to a man the 6 is covering, which bypasses the press',
    'Drive play backward and win the ball for a Leeds attacking transition.',
    NULL, 145, 146, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Phillips)', 'Press the receiver from behind, keep chasing to the next carrier'),
    (2, 'Nearby midfielders', 'Close the short exits')
) AS v(so, role, job);

-- 70. pp.147-148
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'to_attack', 'Ch 10 Kalvin Phillips', 'Regain feeds 6, fake switch, through ball',
    'Leeds v QPR: after the full back wins a poor long ball in the air and finds the winger, the ball comes inside to the 6 holding the centre. He opens his body as if to switch to the far side.',
    'Ball returned to the central 6 just after a regain',
    'Sell the switch, then thread a pass through the line for the striker''s run into the box.',
    NULL, 147, 148, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Dallas)', 'Win the aerial duel, find the winger'),
    (2, 'Left winger (Harrison)', 'Play back inside to the 6'),
    (3, '6 (Phillips)', 'Open body, fake the diagonal, slide a through ball'),
    (4, 'Striker', 'Run through the back line')
) AS v(so, role, job);

-- 71. pp.149-149
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'to_defend', 'Ch 11 Mateusz Klich', 'Tactical foul to stop counters',
    'When possession is lost and the opponent breaks, the 8 takes a well-timed tactical foul to stop the move.',
    'Opponent counter starting with Leeds out of shape',
    'Slow the transition so team-mates can recover their defensive shape.',
    NULL, 149, 149, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '8 (Klich)', 'Commit the tactical foul at the right moment'),
    (2, 'Rest of team', 'Sprint back into defensive shape')
) AS v(so, role, job);

-- 72. pp.149-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 11 Mateusz Klich', 'Free 8 loses marker then checks back',
    'In possession the free 8 drifts into the half-space or wide areas to shake off his man, then darts back toward the ball to receive vertical passes into central pockets.',
    'Marker follows the 8 out of the centre',
    'Create a free receiving option between the lines.',
    NULL, 149, 150, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free 8 (Klich)', 'Drift away from his marker, then check back to receive'),
    (2, 'Builder (6 / centre back)', 'Play the vertical pass into the pocket')
) AS v(so, role, job);

-- 73. pp.150-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch 11 Mateusz Klich', 'Press while keeping man in cover shadow',
    'Inside the man-marking system the 8 first tucks into a compact position on his man, but he is often first to jump when a pressing trigger fires, curving his run so his own man stays in his cover shadow.',
    'Team pressing trigger',
    'Add a presser without opening the pass to his man as an escape.',
    NULL, 150, 150, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '8 (Klich)', 'Press the ball on an angle that blocks the pass to his man'),
    (2, 'Other man-markers', 'Stay tight to their own players')
) AS v(so, role, job);

-- 74. pp.151-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 11 Mateusz Klich', 'Right-side rotation, full back inverted run',
    'Leeds v Barnsley, against a stubborn block on the right: the winger moves inside from high wide, the 8 takes the pocket he left, and the right back passes into him. The 8 shields the ball while the full back runs inside into the 8''s old space.',
    'Winger inverts, opening a wide pocket',
    'Chain rotations to pull defenders out of position, then put the full back into the box.',
    NULL, 151, 152, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Costa)', 'Move inside from the advanced wide spot'),
    (2, 'Right 8 (Klich)', 'Fill the pocket, shield, feed the full back'),
    (3, 'Right back (Ayling)', 'Pass in, then make an inverted run into the area')
) AS v(so, role, job);

-- 75. pp.153-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 11 Mateusz Klich', '8 drops deep, disguises the vertical pass',
    'Leeds v Barnsley: the 8 rotates back to the base of midfield to get the ball. As the winger runs from wide right, he shapes to pass to him.',
    'Aggressive block with no easy route; the 8 drops to receive',
    'Shift his weight late and drive a vertical pass through to the penalty area.',
    NULL, 153, 154, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '8 (Klich)', 'Drop to the base, fake the wide pass, drive the ball through centrally'),
    (2, 'Right winger (Costa)', 'Run from wide to occupy defenders'),
    (3, 'Forward', 'Receive the vertical ball in the box')
) AS v(so, role, job);

-- 76. pp.155-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Ch 11 Mateusz Klich', 'Press from behind, 8 jumps the lay-back',
    'Leeds v Cardiff in the Leeds half: the 6 presses a receiver hard from behind so he cannot turn and has to lay the ball back. The 8 has read it, jumps onto the back pass and wins it.',
    'Forced back pass from the receiver under pressure',
    'Regain and start an attacking transition.',
    NULL, 155, 156, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Phillips)', 'Press the receiver from behind, stop him turning'),
    (2, '8 (Klich)', 'Cover across the midfield width, jump the lay-back')
) AS v(so, role, job);

-- 77. pp.157-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Ch 11 Mateusz Klich', 'Press-resistant 8 clips to blind-side run',
    'Leeds v Hull: the 8 gets the ball in the right half-space facing a set block with no vertical lane, and is pressed straight away.',
    'Pressure on an 8 who has no vertical option',
    'Keep calm and clip to the back of the box for the striker''s blind-side run (Bamford scored with a header).',
    NULL, 157, 158, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '8 (Klich)', 'Shield under pressure, clip to the back post area'),
    (2, 'Striker (Bamford)', 'Run off the defender''s blind side to the back of the box')
) AS v(so, role, job);

-- 78. pp.159-160
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'to_attack', 'Ch 11 Mateusz Klich', 'Contest the second ball after a long pass',
    'Leeds v Reading: a poor long ball from Leeds is headed clear into the centre and two opponents move to collect it. The 8, staying close to where it lands, wins the duel even though he is outnumbered 2v1.',
    'Opponent clearance drops into central midfield',
    'Regain the second ball, drive forward and shoot from the edge of the box.',
    NULL, 159, 160, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '8 (Klich)', 'Stay near the landing zone, attack the loose ball, carry and shoot'),
    (2, 'Other midfielders', 'Squeeze up around the landing zone')
) AS v(so, role, job);

-- 79. pp.161-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Chapter 11 Mateusz Klich', 'Free 8 at box edge waits for winger run',
    'Leeds have pinned Forest into a deep block; Klich rotates to the edge of the area, receives, and is stepped out on by a defender.',
    'Defender steps out to press the 8 at the box edge',
    'Hold the ball under pressure until the wide forward runs in behind, then time the through ball.',
    NULL, 161, 162, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free 8 (Klich)', 'Rotate to edge of area, receive, stay composed under the press'),
    (2, 'Right winger (Helder Costa)', 'Run from the right of the box behind the line as the defender steps out')
) AS v(so, role, job);

-- 80. pp.163-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Chapter 12 Pablo Hernandez', 'Structured build-up, freedom in final third',
    'Bielsa fixes occupation of space and rotations in early build-up, but once Leeds reach advanced areas creative players may improvise angles and movements around the box within the rotation/overload framework.',
    'Ball reaches the final third',
    'Break down stubborn low blocks through individual creativity on top of a fixed structure.',
    NULL, 163, 164, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Creative 8 / right-sided playmaker (Hernandez)', 'Find pockets in the block, set the tempo, make the game fluid'),
    (2, 'Wide players and 8s', 'Keep rotations and wide overloads going around the box')
) AS v(so, role, job);

-- 81. pp.164-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Chapter 12 Pablo Hernandez', '8 drops into midfield to progress vertically',
    'Playing as one of the two 8s, the playmaker drops back into the midfield block to take vertical passes from the 6 or a centre back.',
    '6 or centre back has the ball with a vertical lane to the 8',
    'Receive centrally and immediately play the next forward (progressive) pass.',
    NULL, 164, 164, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '8 (Hernandez)', 'Drop into midfield, receive the vertical pass, play the next progressive ball'),
    (2, '6 (Phillips) / centre back', 'Feed the dropping 8 vertically')
) AS v(so, role, job);

-- 82. pp.165-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'set_piece', 'Chapter 12 Pablo Hernandez', 'Quick goal kick to dropping playmaker',
    'Before either side has set its structure for a goal kick, the playmaker sprints back toward the box asking for the ball; the keeper fires it vertically to him.',
    'Opponent still jogging into shape at the goal kick',
    'Turn the restart into an immediate attack with a first-time diagonal over the defensive line for the wide forward.',
    NULL, 165, 166, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Restart fast with a vertical pass to the dropping 8'),
    (2, '8 (Hernandez)', 'Come short urgently, first touch out of feet, diagonal over the top'),
    (3, 'Left winger (Jack Harrison)', 'Run into space behind the line')
) AS v(so, role, job);

-- 83. pp.167-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Chapter 12 Pablo Hernandez', 'Fake one side, reverse to third runner',
    'The 8 drops left deep in his own half, rides a challenge and drives forward with his body open to the right, where two runners threaten behind.',
    'Defenders read the obvious pass to the right runners',
    'Sell the pass right so defenders shade over, then reverse the ball left to a third runner arriving from deep (verticality).',
    NULL, 167, 168, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '8 (Hernandez)', 'Carry forward, feint the pass right, reverse it left'),
    (2, 'Two right-side runners', 'Run behind the line to drag defenders across'),
    (3, 'Third runner from deep (left)', 'Arrive late into the vacated space')
) AS v(so, role, job);

-- 84. pp.169-170
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Chapter 12 Pablo Hernandez', 'Half-space receiver plus second 8 overload',
    'Winger sets back to the right back, who plays a diagonal into the playmaker in the half-space at the box edge; as he is pressed, the other 8 runs to overload that zone.',
    'Half-space receiver is pressed',
    'No-look disguised pass into the second 8''s run on the defender''s blind side.',
    NULL, 169, 170, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Helder Costa)', 'Set the ball back'),
    (2, 'Right back (Luke Ayling)', 'Diagonal into the half-space'),
    (3, 'Right 8 (Hernandez)', 'Receive at box edge, disguise, slip the pass'),
    (4, 'Other 8 (Klich)', 'Run beyond to overload the zone, blind side of defender')
) AS v(so, role, job);

-- 85. pp.171-172
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Chapter 12 Pablo Hernandez', 'Pause in the pocket, lift over',
    'The playmaker receives centrally in a pocket surrounded by several defenders and, rather than rushing, slows the game.',
    'Ball received under closing pressure between lines',
    'Wait for the advanced runner to start, then chip/lift the ball into the space behind for a chance.',
    NULL, 171, 172, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central playmaker (Hernandez)', 'Create separation, hold, then lift the pass'),
    (2, 'Advanced runner', 'Time the run in behind the line')
) AS v(so, role, job);

-- 86. pp.173-174
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'to_attack', 'Chapter 12 Pablo Hernandez', 'Regain, drop and first-time ball over',
    'Right back wins it back in the defensive third and plays a quick diagonal into the playmaker who has dropped to offer; his change of tempo leaves the opponent unsure.',
    'Ball regained in own third with a vertical option open',
    'No touch: play the ball first time over the top and outside for the wide forward to run onto goal.',
    NULL, 173, 174, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Luke Ayling)', 'Win the ball, quick diagonal into the 8'),
    (2, '8 (Hernandez)', 'Drop and demand it, first-time vertical ball over the line'),
    (3, 'Wide forward', 'Spin and run through on goal')
) AS v(so, role, job);

-- 87. pp.175-176
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Chapter 12 Pablo Hernandez', '8 rotates wide ahead of the ball',
    'In the settled attack the 8 rotates out to the left corner of the box ahead of the ball as it moves from the 6 to the left winger.',
    'Ball moves wide to the winger',
    'Receive with separation wide, shape to switch deep but curl a disguised ball into a runner attacking the box.',
    NULL, 175, 176, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Kalvin Phillips)', 'Feed the left winger'),
    (2, 'Left winger (Harrison)', 'Pass into the rotating 8'),
    (3, '8 (Hernandez)', 'Rotate wide, disguise the delivery'),
    (4, 'Box runner', 'Attack the penalty area')
) AS v(so, role, job);

-- 88. pp.177-178
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Chapter 13 Jack Harrison', 'Right triangle overload, left winger width',
    'Leeds built attacks mainly down the right through a triangle of right back, right winger and right 8; against deep compact blocks the left winger stays wide as an outlet.',
    'Opponent sits deep and compact; play loaded on the right',
    'Keep balance and a far-side isolation option so the weak side can be attacked.',
    NULL, 177, 178, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right triangle (Ayling, Costa, Hernandez)', 'Combine and overload the right'),
    (2, 'Left winger (Harrison)', 'Hold width on the weak side, stay disciplined')
) AS v(so, role, job);

-- 89. pp.179-180
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Chapter 13 Jack Harrison', 'Winger drops for vertical pass, turns',
    'Left centre back skips the safe pass to the left back and plays into the winger who has dropped deeper; the winger is closed down immediately.',
    'Winger receives from centre back with a defender tight',
    'Let the defender make contact, roll him, drive at the box and cross for teammates attacking the area.',
    NULL, 179, 180, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Liam Cooper)', 'Choose the vertical pass to the dropping winger'),
    (2, 'Left winger (Harrison)', 'Drop, absorb contact, turn and drive'),
    (3, 'Box attackers', 'Fill the central area for the cross')
) AS v(so, role, job);

-- 90. pp.181-182
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'to_attack', 'Chapter 13 Jack Harrison', 'Transition carry, far-post deep cross',
    'Winger collects in transition deep in the opponent half and carries quickly past defenders trying to engage him.',
    'Possession won/collected with the block not yet set',
    'Arrive at the box edge and whip a deep cross to the far post where the 9 has peeled across.',
    NULL, 181, 182, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Harrison)', 'Fast decisive carry, deep cross to far post'),
    (2, 'Striker (Patrick Bamford)', 'Move from central 9 spot to attack the far post')
) AS v(so, role, job);

-- 91. pp.183-186
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Chapter 13 Jack Harrison', 'Isolated winger: pause, accelerate, deliver',
    'Winger receives isolated against a full back on the edge of or inside the box; the opponent line is narrow, leaving space wide in the box, with 8s pushed high as support.',
    'Defender moves across to engage the winger',
    'Slow down, let the defender commit, then change pace past him on the outside and pick the right ball across goal (to the opposite winger or the lone runner).',
    NULL, 183, 186, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Harrison)', 'Pause then explode past the defender, composed final ball'),
    (2, '8s', 'Push high behind the ball to support'),
    (3, 'Opposite winger', 'Attack the far side for the ball across goal')
) AS v(so, role, job);

-- 92. pp.187-188
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Chapter 13 Jack Harrison', '8 goes wide, winger rotates inside',
    'The 8 rotates into the wide lane while the winger moves into the half-space; the winger is marked tight but steps away to create separation.',
    '8 receives wide with winger''s marker close',
    'Shift the ball inside to the winger in the pocket, who finds the 9 running across the defender''s blind side into the box.',
    NULL, 187, 188, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '8 (Klich)', 'Rotate into the wide space and receive'),
    (2, 'Winger (Harrison)', 'Move inside into half-space, separate from marker, through ball'),
    (3, 'Striker (Bamford)', 'Cross the defender''s blind side into the area')
) AS v(so, role, job);

-- 93. pp.189-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Chapter 13 Jack Harrison', 'Winger crashes in under the striker',
    'The 6 plays a quick pass into the box to the 9 posted on the far side, who wins the header and knocks it back.',
    '9 wins the aerial duel in the box',
    'The weak-side winger has run across the area to support underneath and carries on through the challenge to shoot.',
    NULL, 189, 190, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '6 (Kalvin Phillips)', 'Quick pass into the box'),
    (2, 'Striker (Bamford)', 'Take position far side, win the duel, lay it back'),
    (3, 'Left winger (Harrison)', 'Run across the box under the striker, receive and finish')
) AS v(so, role, job);

-- 94. pp.191-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', 'Chapter 14 Patrick Bamford', '9 drops to link and drifts right',
    'The left-footed 9 likes to drift right to join the right-side overload and drops deep to receive with his back to goal under pressure.',
    'Build-up needs a vertical link or right-side overload',
    'Give a back-to-goal outlet and add a man to the right-side combinations.',
    NULL, 191, 192, 940)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Bamford)', 'Drop to feet with pressure behind, drift right to overload'),
    (2, 'Right-side players', 'Combine off his lay-offs')
) AS v(so, role, job);

-- 95. pp.192-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'out_of_possession', 'Chapter 14 Patrick Bamford', '9 leads the press, shuts lanes',
    'The centre forward works hard off the ball, pressing defenders and closing down passing lanes.',
    'Opponent in possession in build-up',
    'Make the first line of pressure and restrict opponent passing options.',
    NULL, 192, 192, 950)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Bamford)', 'Press the ball carrier and cut passing lanes')
) AS v(so, role, job);

-- 96. pp.194-195
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', '14. Patrick Bamford', 'Nine drops, 8 runs beyond',
    'Full back carries inverted into the right half-space looking to progress; the centre forward drops off the top line toward him to receive the vertical pass, vacating space that a free 8 attacks from behind the ball.',
    'Inverted full back on the ball in half-space facing forward',
    'Striker receives between lines and threads a through ball to the 8 running into the box.',
    NULL, 194, 195, 960)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'Invert into half-space and play vertical pass into feet'),
    (2, 'Centre forward (Bamford)', 'Drop off highest line to offer the connection, then lay through'),
    (3, 'Free 8 (Klich)', 'Run beyond the dropping striker into the vacated space')
) AS v(so, role, job);

-- 97. pp.196-197
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', '14. Patrick Bamford', 'Blind-side run after drag-out',
    'Base midfielder plays vertically into an attacker in the right half-space; a defender steps out of the line to engage him, leaving a gap. The striker, sitting on the blind shoulder of his marker, darts across the defender''s face into the gap as the defender watches the ball.',
    'Defender steps out to engage the half-space receiver / marker turns head to the ball',
    'Through pass to the angled onside run creates a shot.',
    NULL, 196, 197, 970)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Phillips)', 'Break lines with vertical pass into half-space'),
    (2, 'Half-space attacker (Hernandez)', 'Receive, draw a defender out of the line, slip the pass'),
    (3, 'Centre forward (Bamford)', 'Hold the blind shoulder, time the run across the defender while staying onside')
) AS v(so, role, job);

-- 98. pp.197-199
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'to_attack', '14. Patrick Bamford', 'Separation run on vertical cue',
    'In quick transition a midfielder drops into the half-space, receives and turns to play forward. The striker reads the turn as the cue and peels away from his marker, angling the run so the defender cannot body him, then runs onto the ball over the top.',
    'Midfielder receives and turns facing forward',
    'Striker collects in behind ahead of the defender and finishes.',
    NULL, 197, 199, 980)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping midfielder (Hernandez)', 'Drop to half-space, turn and play over the line immediately'),
    (2, 'Centre forward (Bamford)', 'Create separation, angle run away from defender, attack space behind')
) AS v(so, role, job);

-- 99. pp.200-201
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'to_attack', '14. Patrick Bamford', 'Striker pre-positions for regain',
    'While the opponent tries to build out of its own half under Leeds'' press, the striker stays in a pocket on the edge of the half-space and centre watching the ball, ready for a turnover.',
    'Press wins the ball back high',
    'Immediate run between centre backs gets a quick forward pass from the ball-winner and a finish.',
    NULL, 200, 201, 990)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Bamford)', 'Hold a pocket between lines during opponent build-up, sprint between centre backs on regain'),
    (2, 'Pressing players', 'Engage and win the ball, play forward at once to the striker')
) AS v(so, role, job);

-- 100. pp.201-203
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', '14. Patrick Bamford', 'Rotation chaos, far-post finisher',
    'On the right, the winger rotates inside past the ball and the full back rotates forward into the wide lane; defenders struggle to pass players on. The ball goes to the inverted winger who plays a vertical pass releasing the 8 into the box, who cuts it across goal while the striker lurks on the periphery to arrive at the back post.',
    'Ball with half-space player; winger inverts past the ball',
    'Break into the box and square cut-back finished at the far post.',
    NULL, 201, 203, 1000)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Costa)', 'Invert past the ball, then play vertical release pass'),
    (2, 'Right back (Ayling)', 'Rotate forward into the vacated wide lane'),
    (3, 'Free 8 (Klich)', 'Run into the box and pass across the face of goal'),
    (4, 'Centre forward (Bamford)', 'Stay on the edge of the move, attack the far post')
) AS v(so, role, job);

-- 101. pp.205-206
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', '15. Anatomy of a goal - 1) Bamford vs Millwall', 'Winger inverts, full back released',
    'Against a set low block, the winger passes inside to the half-space player and immediately runs inside himself, taking his full back with him and emptying the wide lane. A lateral pass to the stepping-up 8 finds the right back running into the empty flank.',
    'Winger passes inside and his marker follows his inverted run',
    'Overlapping full back released toward goal, crosses for the striker''s back-post run.',
    NULL, 205, 206, 1010)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Costa)', 'Pass inside then angle run into half-space to drag the defender'),
    (2, 'Half-space 10/8 (Hernandez)', 'Recycle laterally to the second 8'),
    (3, 'Second 8 (Klich)', 'Step forward and slip the ball out wide'),
    (4, 'Right back (Ayling)', 'Run into the emptied wide space and cross'),
    (5, 'Centre forward (Bamford)', 'Start far side of box, run off defender to back post')
) AS v(so, role, job);

-- 102. pp.207-208
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', '15. Anatomy of a goal - 2) Ayling vs Huddersfield', 'Central flood frees back post',
    'Leeds overload and compress the central zone around the box with attackers while a half-space player drives wide; defenders are sucked in, leaving the area round the back post open. The far-side full back, starting deep, makes an untracked run round the back of the box.',
    'Ball carrier drives toward the wide space with the centre crowded',
    'Cross to the unmarked weak-side full back arriving at the back post.',
    NULL, 207, 208, 1020)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left half-space player (Hernandez)', 'Drive with the ball to the wide area and cross'),
    (2, 'Front attackers / 8s', 'Flood and occupy central box zones to pin defenders'),
    (3, 'Weak-side right back (Ayling)', 'Make late unchecked run around the back of the area')
) AS v(so, role, job);

-- 103. pp.209-210
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', '15. Anatomy of a goal - 3) Hernandez vs Stoke', 'Dropping 8 bounce, vertical release',
    'From the back line, an 8 drops to offer a vertical option; as a defender steps in to engage him he plays first time out to the right back, who plays straight forward to the winger running beyond the line. The cut-back is dummied by the striker for the arriving midfielder.',
    'Defender engages the dropped 8',
    'Quick vertical play through the block ends with a pull-back finished from the edge of the box.',
    NULL, 209, 210, 1030)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (White)', 'Play into the dropping 8'),
    (2, 'Free 8 (Klich)', 'Drop deep, release first time to the full back when pressed'),
    (3, 'Right back (Ayling)', 'Play immediately vertical to the winger''s run'),
    (4, 'Right winger (Costa)', 'Run beyond the defensive line from wide, pull ball back'),
    (5, 'Centre forward (Bamford)', 'Step over the cut-back to fool defenders'),
    (6, 'Arriving midfielder (Hernandez)', 'Arrive at the edge of the area to strike')
) AS v(so, role, job);

-- 104. pp.211-212
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', '15. Anatomy of a goal - 4) Costa vs Stoke', 'Inverted full-back carry, winger behind',
    'The left back carries the ball inside toward the half-space; a half-space attacker moves inside-to-out to pull his defender away, opening a carrying lane. Meanwhile the far winger has drifted central and times a run behind the line.',
    'Full back carries inside and a defender is pulled wide',
    'Through ball into the space between back line and keeper for the winger to finish.',
    NULL, 211, 212, 1040)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Dallas)', 'Carry the ball inverted into half-space, play through pass'),
    (2, 'Half-space attacker (Hernandez)', 'Move inside-to-out to drag a defender away'),
    (3, 'Right winger (Costa)', 'Come central and time run behind the defensive line')
) AS v(so, role, job);

-- 105. pp.213-214
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-bielsa-thirteen-steps-premier-league'), 'in_possession', '15. Anatomy of a goal - 5) Dallas vs Charlton', 'Overlap decoy, angled 8 run',
    'Down the right, the full back plays forward into a midfielder who shifts it inside to the half-space player; the full back keeps going on an overlap round the outside, distracting defenders, and the midfielder copies the movement with an angled run into the box.',
    'Pass inside to the half-space player with the full back overlapping',
    'Through ball (here between a defender''s legs) finds the angled run of the 8 to score.',
    NULL, 213, 214, 1050)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Ayling)', 'Pass forward then overlap outside to occupy defenders'),
    (2, '8 (Dallas)', 'Lay inside then make an angled run into the penalty area'),
    (3, 'Half-space player (Hernandez)', 'Play the through ball to the angled run')
) AS v(so, role, job);

COMMIT;
