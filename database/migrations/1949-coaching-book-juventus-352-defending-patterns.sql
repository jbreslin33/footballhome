-- 1949 📚 Coaching book patterns: Terzis, "Coaching the Juventus 3-5-2 -
-- Tactical Analysis and Sessions: Defending" (SoccerTutor), Conte's Juventus
-- 2013-14.  Every page (1-236) read; each team pattern the book describes
-- written up in OUR OWN WORDS (short paraphrase, nothing copied): moment,
-- trigger, aim, opponent shape where the book splits by it (sections that
-- name only "1/2/3 forwards" or "3/4 man defence" keep vs NULL and say it in
-- the situation), app page numbers as the citation, and who does what.
-- Training sessions / practices, intro, contents and adverts are left out.
-- Owner's personal library.  (James 11/26 'continue with the reading of the
-- coach viewer books')
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Coaching the Juventus 3-5-2',
    subtitle    = 'Tactical Analysis and Sessions: Defending',
    author      = 'Athanasios Terzis',
    team        = 'Juventus',
    season      = '2013-14',
    method_note = 'The author watched every Juventus match of Antonio Conte''s 2013-14 season (over 1000 hours). A phase of play went in once it had recurred at least 10 times; each player''s position, body shape and movement were then logged and drawn in Tactics Manager diagrams, and the situations turned into 40 practices. The defending book: the three-man defence against one, two and three forwards, midfield positioning, the rear block and the forwards'' positioning against each opponent shape, then passive defending and pressing against 3-4-3, 3-4-1-2, 3-5-2, 4-2-3-1, 4-4-2, 4-3-3 and 4-3-1-2.'
WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending');

-- 1. pp.10-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Basic Elements During the Defensive Phase / The 3 Man Defence', 'Win the duel only with a spare man',
    'General rule for the back three: keep an extra defender over the opposing forwards and stay compact with the midfield so forwards can be doubled.',
    'Any pass into an opposing forward',
    'Defend aggressively when outnumbering the forwards with cover behind; when level or short, delay and play for time instead.',
    NULL, 10, 14, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Barzagli, Bonucci, Chiellini)', 'Talk constantly; always one pressing, one covering, one balancing'),
    (2, 'Midfielders', 'Drop in to make up numbers when the back line is level with the forwards'),
    (3, 'Wing backs / attacking midfielders', 'Key pieces when pressing a back four')
) AS v(so, role, job);

-- 2. pp.16-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Defending Against 1 Forward - Horizontal Shifts (Pressure, Cover and Balance)', 'Back three slides around lone striker',
    'Against one forward the three centre backs shift mostly sideways with the ball; the one nearest the striker sits goal-side, the middle man covers, the far one keeps the line level.',
    'Ball moves across the opposing midfield; pass played into the striker',
    'Keep a 3 v 1 so the marker can attack the receiver and try to nick the ball first.',
    NULL, 16, 19, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back nearest the striker', 'Goal-side and tight; jumps on the receiver hard as the pass travels'),
    (2, 'Middle centre back (Bonucci)', 'Covers behind the challenger'),
    (3, 'Far centre back', 'Holds balance; when striker is central and middle CB marks, the wide CBs sit a few yards deeper as cover'),
    (4, 'Wide centre back without a direct opponent', 'Steps a few yards higher when the striker is on the other side')
) AS v(so, role, job);

-- 3. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Defending Against 1 Forward - Horizontal Shifts', 'Rotate when ball goes behind wide CB',
    'Lone striker near the middle centre back runs into the channel behind a wide centre back onto a long ball.',
    'Long pass into space behind the left or right centre back',
    'Striker is tracked and the middle is refilled at once so there is still cover.',
    NULL, 17, 17, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back (Bonucci)', 'Tracks the striker''s run into the channel'),
    (2, 'Wide centre back (Chiellini)', 'Drops and slides into the space the middle man left')
) AS v(so, role, job);

-- 4. pp.18-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Recovering When Caught in the Wrong Positions', 'Caught flat: delay until cover arrives',
    'Striker is on the middle centre back while the two outside centre backs are too high to cover, so a direct pass makes it 1 v 1 in the centre.',
    'Pass into the striker with no covering defender behind the marker',
    'Marker contains rather than tackles, buying time; once team-mates are back in cover he switches to aggressive pressure.',
    NULL, 18, 20, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back (Bonucci)', 'Stays on his feet, stops the turn, plays for time'),
    (2, 'Wide centre backs (Barzagli, Chiellini)', 'Sprint back into covering spots behind him'),
    (3, 'All defenders', 'If striker is on the weak side, use ball travel time to reset before the pass arrives')
) AS v(so, role, job);

-- 5. pp.20-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Defending When the Opposition Forward is Positioned Centrally', 'Show striker toward the covered side',
    'Central striker receives; one wide centre back is in line to cover but the other cannot get back in time.',
    'Pass to a central striker with cover on one side only',
    'Marker presses but angles his approach so the striker can only turn toward the covered side.',
    NULL, 20, 20, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back (Bonucci)', 'Presses, blocking the turn toward the uncovered side'),
    (2, 'Covering centre back (Chiellini)', 'Level and close, ready to support'),
    (3, 'Out-of-position centre back (Barzagli)', 'Recovers; his side is shut off by the marker''s angle')
) AS v(so, role, job);

-- 6. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Vertical Shifts of the Defenders in an Open Ball Situation', 'Drop on open ball, squeeze on closed',
    'Opponent on the ball is unpressed and can play forward, forwards ready to run in behind.',
    'Open ball (carrier free, facing forward); then midfielder closes him down or he passes backward',
    'Line drops to cover runs and keep a safety gap, then stops and steps up together when the ball is closed or goes back, catching the striker offside.',
    NULL, 21, 21, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'Retreat together, track the runner, keep shape and a safety distance'),
    (2, 'Strong-side midfielder (Marchisio)', 'Closes the carrier to turn the ball closed'),
    (3, 'Back three on backward pass', 'Push up quickly in one line during ball travel, then stop and reset when it arrives')
) AS v(so, role, job);

-- 7. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Vertical Shifts of the Defenders When the Man in Possession is in the Centre', 'Central runner: retreat, narrow, then step',
    'Central midfielder dribbles at the back three before the holding midfielder can reach him while the striker runs in behind.',
    'Opponent carries into space in front of the defence',
    'Back line drops and narrows to deny the through ball; when the carrier nears shooting range the nearest centre back steps out, the others stop and step up, leaving the striker offside.',
    NULL, 22, 22, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Pirlo)', 'Chases the carrier'),
    (2, 'Nearest centre back (Bonucci)', 'Steps out to close him near shooting range'),
    (3, 'Other centre backs', 'Stop retreating, step up a few yards as cover'),
    (4, 'Goalkeeper (Buffon)', 'Ready to sweep any ball in behind')
) AS v(so, role, job);

-- 8. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Vertical Shifts of the Defenders During an Open Ball Situation', 'Open ball, no run: hold the line',
    'Opponent has an open ball but stands still; drop only if a forward actually runs in behind.',
    'Forward run beyond the line (or none)',
    'No needless retreat: hold shape if nobody runs, drop only against an actual run.',
    NULL, 23, 23, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'Keep distance to the carrier; retreat only when a forward makes the run')
) AS v(so, role, job);

-- 9. pp.31-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Defending Against 2 Forwards - Effective Defending (Correct Positioning)', 'Two strikers: two mark, one spare',
    'Against a front two, two centre backs pick up the strikers goal-side and the third (often the strong-side wide CB staying deep) gives cover and balance.',
    'Pass into either striker',
    'Marker of the receiver steps in aggressively during ball travel while the spare man covers, keeping 3 v 2.',
    NULL, 31, 34, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back marking the receiver', 'Attacks the ball as it travels'),
    (2, 'Middle centre back (Bonucci)', 'Marks one striker and covers his neighbour'),
    (3, 'Spare centre back', 'Stays deep and close to team-mates for cover and balance')
) AS v(so, role, job);

-- 10. pp.32-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Defending Against 2 Forwards - Following the Forward''s Movement at the Wrong Time', 'Let a dropping striker go when it opens a hole',
    'A striker drops toward the ball; following him would pull a centre back out and leave a team-mate 1 v 1 with the other striker in the gap.',
    'Striker checks short with his partner able to attack the vacated space',
    'Defender stays with the line and passes the dropping man to a midfielder (or pressures him only once he receives), keeping cover and balance.',
    NULL, 32, 37, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back whose man drops (Barzagli/Bonucci)', 'Does not follow; stays close to the other centre backs; calls ''stay'''),
    (2, 'Midfielder', 'Takes over the dropping striker'),
    (3, 'Far centre back (Chiellini)', 'Must not over-shift across, which would unbalance the line')
) AS v(so, role, job);

-- 11. pp.34-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Defending Against 2 Forwards - Tracking the Forward Dropping Deep Without Causing Problems', 'Follow the dropping striker when safe',
    'A striker drops short while the other striker is far away on the weak side, or the middle centre back already covers.',
    'Striker drops with no team-mate near enough to exploit the gap',
    'Wide centre back follows his man tight since nobody can attack the space; needs team-mates to call it.',
    NULL, 34, 36, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back (Barzagli)', 'Follows the dropping striker'),
    (2, 'Middle centre back (Bonucci)', 'Covering position behind'),
    (3, 'Team-mates', 'Coach him ''go'' when the space is safe')
) AS v(so, role, job);

-- 12. pp.35-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: The Correct Defensive Positioning When Both Forwards are Positioned On the Weak Side', 'Free strong-side CB tucks in',
    'Both strikers sit on the weak side; the strong-side centre back has no direct opponent.',
    'Both forwards drift to one side',
    'Free centre back stays close to the others as the extra man; whichever striker receives is pressed while the rest cover and balance.',
    NULL, 35, 35, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side centre back (Barzagli)', 'No man to mark; tucks in to cover and keep numbers'),
    (2, 'Middle centre back (Bonucci)', 'Marks, or covers when the other striker receives'),
    (3, 'Weak-side centre back (Chiellini)', 'Marks goal-side; attacks his man when the ball comes')
) AS v(so, role, job);

-- 13. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Defending When the Ball is in the Centre and the Forwards are Near the Sidelines', 'Strikers wide: middle CB covers both',
    'Ball central, the two strikers split wide toward the touchlines and are marked by the outside centre backs.',
    'Pass from centre to a wide-split striker',
    'Outside centre back attacks his receiver knowing the middle man covers, keeping a 3 v 2.',
    NULL, 36, 36, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside centre backs', 'Goal-side of the wide strikers; press the receiver'),
    (2, 'Middle centre back (Bonucci)', 'Sits between them covering both')
) AS v(so, role, job);

-- 14. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Incorrect Positioning of the Left and Right Centre Backs When the Ball is in the Centre', 'Wide CBs too high v two strikers',
    'Against two forwards both outside centre backs are advanced, leaving the middle man alone 1 v 1 with a central striker.',
    'Central pass into the striker on the middle centre back',
    'Middle man plays for time while the outside centre backs drop behind him, then he turns aggressive.',
    NULL, 38, 38, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back (Bonucci)', 'Delays the receiver'),
    (2, 'Left and right centre backs', 'Run back into covering spots behind him')
) AS v(so, role, job);

-- 15. pp.39-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Recovering from Bad Defensive Positioning Using Offside Tactics', 'Step up to strand striker offside',
    'Middle centre back has dropped deeper than a wide centre back and cannot be covered; the striker sits in the gap.',
    'Carrier cannot play forward (touch away, head down, under pressure)',
    'Deep defender steps up level with the advanced one, leaving the striker offside instead of 1 v 1.',
    NULL, 39, 39, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep centre back (Bonucci)', 'Picks the moment and steps up into line'),
    (2, 'Advanced centre back (Chiellini)', 'Holds his line, does not drop and play the striker on')
) AS v(so, role, job);

-- 16. pp.47-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Defending Against 3 Narrow Forwards - Wing Back in Effective Position', 'Weak-side wing back makes a back four',
    'Against three narrow forwards (e.g. a 3-4-3), the weak-side wing back drops inside and deeper than the weak-side forward so the back line becomes four v three.',
    'Ball near a touchline, or moved from the flank into the centre',
    'Spare defender lets the nearest centre back attack whichever forward receives, with cover and balance behind.',
    NULL, 47, 51, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side wing back (Lichtsteiner)', 'Drops inside, behind the line of the weak-side forward'),
    (2, 'Strong-side wing back (Asamoah)', 'Presses the wide ball carrier'),
    (3, 'Strong-side centre back (Chiellini)', 'Goal-side on the wide forward, attacks him (even if he drops deep)'),
    (4, 'Middle and far centre backs', 'Cover and balance; the one opposite the receiver presses')
) AS v(so, role, job);

-- 17. pp.49-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Defending Against 3 Narrow Forwards - Wing Back in Ineffective Position', 'Wing back high: play for time',
    'Weak-side wing back is too high, so the back three are 3 v 3 with the forwards.',
    'Pass into any of the three forwards while the weak-side wing back is still upfield',
    'Defender on the receiver contains and lets a dropping forward go until the wing back gets back; then he switches to win the ball.',
    NULL, 49, 53, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back on the receiver', 'Plays for time, no lunge; switches to aggressive once 4 v 3 or 3 v 2'),
    (2, 'Weak-side wing back (Lichtsteiner)', 'Sprints back into the line'),
    (3, 'Other defenders', 'Call when the wing back is back in place')
) AS v(so, role, job);

-- 18. pp.62-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Defending a Diagonal Pass to a Wide Forward Behind the Wing Back', 'Diagonal behind the wing back',
    'With the weak-side wing back out of position, a switch ball goes into the wide forward high on the flank behind him.',
    'Diagonal pass into space behind the weak-side wing back',
    'Nearest centre back goes out to delay while the wing back runs into the box to fill his spot, avoiding 2 v 2 in the box.',
    NULL, 62, 62, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side centre back (Barzagli)', 'Slides out to the flank and plays for time'),
    (2, 'Weak-side wing back (Lichtsteiner)', 'Recovers into the box to cover Barzagli''s spot'),
    (3, 'Other centre backs', 'Shuffle across in the box')
) AS v(so, role, job);

-- 19. pp.63-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 1: Preventing the Opposition Creating Space On the Flank', 'Wide forward drops, full back overlaps',
    'Opposing wide forward checks short to pull his marker while the full back runs into the vacated flank space.',
    'Synchronised drop by the wide forward and overlap by the full back',
    'If the wing back is well placed the centre back may follow; if not, he lets the forward go, covers the overlap, and the line drops until the wing back is back, then the nearest man closes the carrier.',
    NULL, 63, 63, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side centre back (Chiellini)', 'Follows the dropping forward only if covered; otherwise drops to cover the full back''s run'),
    (2, 'Strong-side wing back (Asamoah)', 'Recovers into a good position'),
    (3, 'Middle centre back (Bonucci)', 'Covers; steps out to the carrier once the line is compact'),
    (4, 'Back line', 'Retreat to get compact when the carrier runs forward')
) AS v(so, role, job);

-- 20. pp.65-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 2: Midfield Positioning', 'Midfielders drop to fix back-line numbers',
    'Opposition midfielders push up so the back line is level or outnumbered.',
    'Equality or inferiority at the back',
    'Midfielders follow the advanced opponents back toward the defenders to restore the spare man and allow double marking of forwards.',
    NULL, 65, 65, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'Track forward-moving opponents to stay near the defenders'),
    (2, 'Defenders', 'Use short distances to midfield to double up on forwards')
) AS v(so, role, job);

-- 21. pp.65-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 2: Midfield Shape and Positioning to Prevent Through Passes From the Defenders', 'Midfield three screens defenders'' passes',
    'Passive block with an opposition defender on the ball: the three midfielders defend space, not men, keeping a compact shape and safety distance.',
    'Opposition centre back in possession; ball moves wide',
    'Close the lanes into the forwards and intercept through balls; the line shifts as one to the strong side.',
    NULL, 65, 66, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side midfielder (Marchisio)', 'Shifts across and slightly forward when the ball is wide'),
    (2, 'Holding midfielder (Pirlo)', 'Stays in line with the far midfielder, screens the middle'),
    (3, 'Far midfielder (Vidal)', 'Holds the line with Pirlo'),
    (4, 'Attacking midfielders (pressing)', 'Jump out to the opposing full backs and the rest slide to the strong side')
) AS v(so, role, job);

-- 22. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 2: The Midfielders Drop Back When the Defender in Possession is Free of Marking', 'Free carrier from the back: midfield retreats',
    'An opposition centre back carries forward unmarked into space.',
    'Unpressured defender dribbles forward',
    'Midfield drops and tightens to keep a safety gap and give the nearest forward time to close him down.',
    NULL, 67, 67, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielders (Marchisio, Vidal)', 'Tuck inside to cut through balls while dropping'),
    (2, 'Holding midfielder (Pirlo)', 'Retreats in line'),
    (3, 'Nearest forward', 'Chases the carrier')
) AS v(so, role, job);

-- 23. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 2: Defending Against the Opposition Midfielders', 'Midfield pressure, cover and balance',
    'Opposition midfielder has the ball in the middle third.',
    'Ball reaches an opposition midfielder',
    'Nearest midfielder presses, the other two form a covering triangle behind, so the presser can be aggressive.',
    NULL, 70, 70, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest midfielder (Marchisio wide / Pirlo central)', 'Presses the ball'),
    (2, 'Second midfielder (Pirlo)', 'Covers'),
    (3, 'Far midfielder (Vidal)', 'Balances; with Pirlo pressing, both wide mids drop to make the triangle')
) AS v(so, role, job);

-- 24. pp.74-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block (Defenders and Midfielders) - introduction', 'Rear block keeps a spare defender',
    'Defenders and midfielders defend as one compact block against any shape; the main rule is to always have one more defender than the opposing forwards at the back.',
    'Any opponent build-up into the middle/final third',
    'Numerical superiority at the back, short gaps between the lines, through passes blocked and support/cover for each other.',
    NULL, 74, 74, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side wing back', 'usually the player who tucks in to create the spare man'),
    (2, 'Defensive or attacking midfielder', 'drops close to the defenders when the wing back cannot get back in time'),
    (3, 'Whole block', 'keep a short distance between defence and midfield so defenders need not leave their spots and midfielders need not run far to cover')
) AS v(so, role, job);

-- 25. pp.76-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 3-4-3', 'Four at the back v three forwards',
    'Against a front three the weak-side wing back drops deeper than his partner to make a back four; when the ball goes to a central midfielder one midfielder presses and two others form a triangle behind; when the ball reaches a forward who has dropped, the nearest centre back steps out hard.',
    'Ball in opposition midfield / pass into a dropping forward',
    'Keep a 4 v 3 at the back, block through passes and win the ball from forwards receiving with their back to goal.',
    '3-4-3', 76, 77, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Lichtsteiner)', 'drops into a deeper line to form a back four, then covers behind the stepping centre back'),
    (2, 'Right central midfielder (Vidal)', 'slides toward the opposing wing back to contest him if he gets the ball'),
    (3, 'Defensive midfielder (Pirlo)', 'presses the midfielder who receives centrally'),
    (4, 'Other midfielders (Vidal, Marchisio)', 'form a covering triangle behind Pirlo to cut through passes'),
    (5, 'Right centre back (Barzagli)', 'follows a forward dropping into the passing lane and presses him aggressively so he cannot turn'),
    (6, 'Left central midfielder (Marchisio)', 'turns back to double mark the forward from the inside while Bonucci covers the other side')
) AS v(so, role, job);

-- 26. pp.77-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 3-4-3', 'Chain shift when ball goes wide',
    'When the ball moves from a central midfielder to the wide midfielder/wing back, the whole back line slides across in a chain, the ball-side wing back steps out while the ball travels and the centre back beside him picks up the near forward.',
    'Pass out to the opposition wing back / wide man',
    'Pass marking responsibilities quickly between defenders so no forward is free for more than a moment and 4 v 3 is kept.',
    '3-4-3', 77, 78, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side midfielder (Marchisio)', 'first to press if the ball goes to his side, then supports the wing back'),
    (2, 'Left wing back (Asamoah)', 'moves forward during the pass to press the new receiver'),
    (3, 'Left centre back (Chiellini)', 'steps forward to mark the near forward tightly'),
    (4, 'Centre backs (Barzagli, Bonucci)', 'slide across in one line, keeping short distances'),
    (5, 'Far wing back (Lichtsteiner)', 'tucks in to complete the back four'),
    (6, 'Other midfielders', 'shift and stay goal-side of the ball')
) AS v(so, role, job);

-- 27. pp.81-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 3-4-1-2', 'Pirlo screens the No.10',
    'Against two strikers plus a No.10, both wing backs often press high on the opposing wing backs, so the defensive midfielder plays deeper to cover a No.10 who may push up and make 3 v 3; the weak-side wing back stays in line with the No.10, not wide, so he can drop.',
    'Both wing backs pressing opposing wing backs high; No.10 in an advanced spot',
    'Avoid 3 v 3 at the back until the weak-side wing back recovers.',
    '3-4-1-2', 81, 82, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Lichtsteiner)', 'presses the opposing wing back'),
    (2, 'Defensive midfielder (Pirlo)', 'sits deeper than usual near the defenders, does not man-mark the No.10'),
    (3, 'Left wing back (Asamoah)', 'stays level with the No.10 inside, sees the whole pitch and drops to make 4 v 3 if the No.10 runs beyond'),
    (4, 'Three centre backs', 'hold 3 v 2 against the strikers'),
    (5, 'Players', 'talk: Asamoah tells Pirlo when the No.10 moves behind him')
) AS v(so, role, job);

-- 28. pp.83-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 3-4-1-2', 'Ball switched: Pirlo holds until recovery',
    'As the ball travels across midfield the ball-near midfielders press and form triangles while the rest shift; when the far wing back is still high as the ball reaches his side, the defensive midfielder stays deep beside the defenders.',
    'Switch of play while a wing back is still advanced',
    'Keep a numerical advantage at the back until the weak-side wing back drops into an effective position.',
    '3-4-1-2', 83, 83, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder (Vidal)', 'presses a midfielder on his side, forming a triangle with Lichtsteiner and Marchisio'),
    (2, 'Marchisio', 'closes the opposite central midfielder after a cross-field pass'),
    (3, 'Pirlo', 'steps up a few yards only when the far wing back is in place; otherwise stays deep'),
    (4, 'Left wing back (Asamoah)', 'goes forward to close the opposing wing back'),
    (5, 'Right wing back (Lichtsteiner)', 'drops back to restore the spare man')
) AS v(so, role, job);

-- 29. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 3-5-2', 'Keep 3 v 2 v a front two',
    'Against a 3-5-2 the three centre backs naturally outnumber two strikers, so the wing backs need not drop deep; only when an opposing midfielder runs forward does someone drop to stop 3 v 3.',
    'Opposition midfielder advancing beside the strikers',
    'Never be level in numbers at the back.',
    '3-5-2', 89, 89, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Asamoah)', 'presses the opposing wide midfielder/wing back on the ball'),
    (2, 'Defensive midfielder (Pirlo)', 'drops a few yards if the runner moves in front of him and the far wing back is high'),
    (3, 'Far wing back (Lichtsteiner)', 'drops into the line to make 4 v 3 when he can'),
    (4, 'Three centre backs', 'stay organised and balanced against the two strikers')
) AS v(so, role, job);

-- 30. pp.90-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 3-5-2', 'Centre back plus Pirlo double mark',
    'A pass into the advanced No.10 between the lines is met by a centre back pressing and the defensive midfielder closing from in front, while the other centre backs cover.',
    'Pass into the advanced midfielder/No.10',
    'Win the ball at once, and buy time for the weak-side wing back to drop back.',
    '3-5-2', 90, 90, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Bonucci)', 'presses the receiver'),
    (2, 'Defensive midfielder (Pirlo)', 'moves close to double mark'),
    (3, 'Other centre backs (Barzagli, Chiellini)', 'cover'),
    (4, 'Right wing back (Lichtsteiner)', 'keeps the line balanced and gets back')
) AS v(so, role, job);

-- 31. pp.90-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 3-5-2', 'Midfield triangle and shift to ball side',
    'As the ball moves between the opponent''s midfielders, the nearest Juve midfielder presses, the other two form a triangle, and the whole block shifts; when the ball finally goes wide the far centre back stays close to his partners and the far wing back gets ready to drop.',
    'Ball passed between opposition midfielders and out wide',
    'Block through passes and keep 4 v 2 at the back with a good midfield shape.',
    '3-5-2', 90, 91, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-near midfielder (Marchisio / Pirlo / Vidal)', 'presses whoever receives in his zone'),
    (2, 'Other two midfielders', 'cover and balance to form a triangle'),
    (3, 'Defenders', 'slide toward the ball side'),
    (4, 'Far centre back (Barzagli)', 'stays near the other defenders'),
    (5, 'Far wing back (Asamoah)', 'ready to drop to help the defenders'),
    (6, 'Vidal', 'supports the near wing back when the ball goes wide')
) AS v(so, role, job);

-- 32. pp.93-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-2-3-1', 'Wing back presses full back',
    'Against a 4-2-3-1 the near wing back closes the full back, a midfielder supports, and the defensive midfielder sits behind to watch the No.10 while the far wing back stays deep for 4 v 3; if the No.10 pushes forward a centre back marks him and Pirlo drops closer to the defenders.',
    'Opposition full back in possession',
    'Keep a spare man at the back even with the No.10 joining the forward line.',
    '4-2-3-1', 93, 93, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Asamoah)', 'presses the full back'),
    (2, 'Left central midfielder (Marchisio)', 'supports and blocks the inside pass'),
    (3, 'Left centre back (Chiellini)', 'covers Asamoah and marks the winger'),
    (4, 'Defensive midfielder (Pirlo)', 'behind Marchisio controlling a deep No.10; drops a few yards (not man-marking) if the No.10 advances'),
    (5, 'Middle centre back (Bonucci)', 'steps to mark an advanced No.10'),
    (6, 'Far wing back (Lichtsteiner)', 'stays deep to make four at the back')
) AS v(so, role, job);

-- 33. pp.94-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-2-3-1', 'Attacking midfielder presses full back',
    'Alternative: a central midfielder goes out to the full back so both wing backs stay deep; Pirlo need not drop even with an advanced No.10 because it is already 5 v 4 at the back.',
    'Full back receives; wing backs both deep',
    'Keep 5 v 4 at the back without asking the defensive midfielder to drop.',
    '4-2-3-1', 94, 94, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side attacking midfielder (Marchisio)', 'presses the full back'),
    (2, 'Defensive midfielder (Pirlo)', 'positions to block the through pass; presses a central midfielder who receives'),
    (3, 'Other midfielders (Marchisio, Vidal)', 'triangle behind Pirlo when he presses'),
    (4, 'Both wing backs', 'stay in the back line')
) AS v(so, role, job);

-- 34. pp.94-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-2-3-1', 'Switch to far full back',
    'When the ball goes to the opposite full back, the weak-side wing back steps out during the pass because the other wing back is already deep; the centre back takes the winger and an attacking midfielder drops to control the No.10 who is behind the midfield line.',
    'Pass from central midfielder out to the far full back',
    'Press the new carrier while keeping 4 v 4 controlled and the block hard to break.',
    '4-2-3-1', 94, 94, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Lichtsteiner)', 'goes forward while the ball travels to close the full back'),
    (2, 'Right centre back (Barzagli)', 'takes over marking the winger'),
    (3, 'Right attacking midfielder (Vidal)', 'drops into a supporting position'),
    (4, 'Left attacking midfielder (Marchisio)', 'drops a few yards to control the No.10 Pirlo cannot see')
) AS v(so, role, job);

-- 35. pp.95-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-2-3-1', 'Centre back follows dropping striker',
    'When Pirlo steps out to press a central midfielder, the striker drops into the space he left; with a spare man at the back the centre back follows him aggressively and a midfielder joins to double mark.',
    'Lone striker drops into the space behind the pressing defensive midfielder',
    'Stop the striker turning and win the ball while 5 v 4 at the back allows the centre back to leave the line.',
    '4-2-3-1', 95, 95, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Pirlo)', 'closes the central midfielder on the ball'),
    (2, 'Marchisio and Vidal', 'triangle behind Pirlo'),
    (3, 'Middle centre back (Bonucci)', 'follows the dropping striker and marks tightly'),
    (4, 'Vidal', 'drops in to double mark the striker')
) AS v(so, role, job);

-- 36. pp.96-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-2-3-1', 'Weak-side wing back high: wait',
    'If the other wing back is high, the wing back on the ball side waits until a midfielder closes the full back; during this open-ball moment the defenders drop to stop balls in behind. If the No.10 advances, an attacking midfielder drops beside the defenders and steps up again once the wing back has recovered.',
    'Full back receives while the opposite wing back is advanced',
    'Keep the spare man at the back and avoid being beaten in behind while nobody is pressing.',
    '4-2-3-1', 96, 96, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Lichtsteiner)', 'stays in the line until Vidal has closed the ball'),
    (2, 'Right attacking midfielder (Vidal)', 'goes out to the full back'),
    (3, 'Defenders', 'drop back while the carrier is unpressed'),
    (4, 'Left attacking midfielder (Marchisio)', 'drops near the defenders when the No.10 runs past; goes back up once Asamoah has recovered'),
    (5, 'Left wing back (Asamoah)', 'recovers into the line')
) AS v(so, role, job);

-- 37. pp.101-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-4-2', 'Attacking midfielder closes full back v 4-4-2',
    'Against a 4-4-2 an attacking midfielder presses the full back, leaving five at the back against two strikers and two wingers; if an opposing central midfielder pushes up to make 5 v 5, the nearest midfielder drops and a centre back steps forward to control him.',
    'Opposition full back on the ball / central midfielder advancing',
    'Keep 5 v 4 at the back.',
    '4-4-2', 101, 101, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Vidal)', 'pushes out to press the full back'),
    (2, 'Defensive midfielder (Pirlo)', 'the midfielder who can see the runner drops a few yards'),
    (3, 'Other attacking midfielder (Marchisio)', 'drops into a balanced central spot'),
    (4, 'Right centre back (Barzagli)', 'steps up to control the advanced midfielder without leaving his cover role for the wing back')
) AS v(so, role, job);

-- 38. pp.102-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-4-2', 'Long ball into striker: triple mark',
    'A long pass from the full back into a striker is met by the centre back pressing his back while two midfielders drop on him and the other centre backs tuck in to cover.',
    'Long forward pass into a striker',
    'Stop him turning and win the ball despite equal numbers up front.',
    '4-4-2', 102, 102, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back (Bonucci)', 'presses and stops the striker turning'),
    (2, 'Pirlo and Marchisio', 'drop back to triple mark'),
    (3, 'Barzagli and Chiellini', 'move inside to cover')
) AS v(so, role, job);

-- 39. pp.102-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-4-2', 'Ball to far full back: two options',
    'When the ball switches to the other full back, either a midfielder goes out and the defenders drop to give him time (safe but deeper, carrier has time), or the wing back steps out during the pass while the line chain-shifts and Pirlo drops to cover 4 v 4. If the pass then goes to the winger, the centre back presses to buy time until the wing back recovers behind him and the midfielder joins to double mark.',
    'Pass to the opposite full back, then on to the winger',
    'Close the ball and quickly restore the spare man at the back.',
    '4-4-2', 102, 103, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Marchisio)', 'option 1: closes the full back; later double marks the winger with Chiellini'),
    (2, 'Defenders', 'option 1: drop to keep the spare man'),
    (3, 'Left wing back (Asamoah)', 'option 2: steps out during the pass; then recovers into cover behind Chiellini'),
    (4, 'Defensive midfielder (Pirlo)', 'drops near the defenders while it is 4 v 4, moves back up when Asamoah has recovered'),
    (5, 'Left centre back (Chiellini)', 'presses the winger to play for time')
) AS v(so, role, job);

-- 40. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-3-1-2', 'Striker pushes up: handover and step',
    'When a dropping striker moves back up, his marking passes to the middle centre back, who tells the wide centre back to drop a few yards for balance, freeing the centre backs to attack any pass into the strikers.',
    'Striker moves into an advanced position',
    'Safety and balance in the line, with license to contest strikers aggressively.',
    '4-3-1-2', 107, 107, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back (Bonucci)', 'takes over the striker and coaches Chiellini'),
    (2, 'Left centre back (Chiellini)', 'drops back close to the other two'),
    (3, 'Barzagli and Bonucci', 'step out hard if the ball goes to a striker')
) AS v(so, role, job);

-- 41. pp.107-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-3-1-2', 'Far wing back narrow behind midfield',
    'Against a 4-3-1-2 three centre backs face two strikers; the near wing back presses the full back, a centre back marks a dropping striker and a deep No.10 is handed to the midfielders. The far wing back stands behind the deepest midfielder and not wide so he can drop into the line if the No.10 runs forward.',
    'Full back on the ball with No.10 near the midfield line',
    'Turn a potential 3 v 3 into 4 v 3.',
    '4-3-1-2', 107, 108, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Asamoah)', 'presses the full back'),
    (2, 'Left centre back (Chiellini)', 'marks a striker who drops'),
    (3, 'Midfielders', 'take responsibility for the No.10 while he is deep'),
    (4, 'Right wing back (Lichtsteiner)', 'starts narrow behind the deepest midfielder, drops level with Barzagli when the No.10 advances')
) AS v(so, role, job);

-- 42. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-3-1-2', 'Inside pass: midfielder presses, triangle',
    'If the full back passes inside to a midfielder, the near central midfielder closes him and the wing back plus defensive midfielder form a triangle behind; the weak-side wing back stays in his effective position to keep the numbers.',
    'Full back passes inside to a central midfielder',
    'Block through passes while 4 v 3 is held at the back.',
    '4-3-1-2', 108, 108, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left central midfielder (Marchisio)', 'presses the receiver'),
    (2, 'Left wing back (Asamoah)', 'drops in to form the triangle'),
    (3, 'Defensive midfielder (Pirlo)', 'completes the triangle'),
    (4, 'Right wing back (Lichtsteiner)', 'holds his spot to make the spare man')
) AS v(so, role, job);

-- 43. pp.109-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-3-1-2', 'Ball switched: midfielder goes, wing back stays',
    'When the ball switches to the full back on the side of the deeper wing back while the other wing back is still high, the deep wing back does not step out but stays near the defenders; a central midfielder closes the full back instead and the defenders drop during the open-ball moment.',
    'Switch to the full back while the far wing back is advanced and No.10 is high',
    'Keep 4 v 3 at the back and avoid a ball in behind before the carrier is closed.',
    '4-3-1-2', 109, 109, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Lichtsteiner)', 'shifts slightly across but stays close to the three defenders'),
    (2, 'Right central midfielder (Vidal)', 'goes out to close the full back'),
    (3, 'Defenders', 'drop back while the carrier has space'),
    (4, 'Players', 'shift across as the ball moves, keeping the shape')
) AS v(so, role, job);

-- 44. pp.115-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-3-3', 'Wing back presses, midfield follows ball',
    'Against a 4-3-3 the near wing back closes the full back (4 v 3 while the No.10 is deep). An inside pass to the holding player is closed by Pirlo with a triangle behind; a pass to the other midfielder is closed by Vidal and the wing back drops to make 5 v 3; a switch to the other full back sees the far wing back step out and the line chain-shift.',
    'Ball circulating between full backs and midfield three',
    'Always press the ball while keeping a spare man at the back and switching marks smoothly through short distances.',
    '4-3-3', 115, 116, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Asamoah)', 'presses the right back, drops after the ball goes inside'),
    (2, 'Defensive midfielder (Pirlo)', 'closes the holding midfielder at once'),
    (3, 'Marchisio and Vidal', 'form the triangle; Vidal presses the far midfielder'),
    (4, 'Right wing back (Lichtsteiner)', 'steps out to the left back when the ball arrives'),
    (5, 'Defenders', 'chain-shift to keep 4 v 3')
) AS v(so, role, job);

-- 45. pp.116-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-3-3', 'Advanced No.10: Pirlo drops, double mark',
    'When an opposing No.8/No.10 pushes up beside the front three, the defence shifts (including the far wing back) and Pirlo drops a few yards to deal with 4 v 4; a pass into that player is pressed by the nearest centre back and Pirlo''s deep spot lets him double mark at once.',
    'Opposition attacking midfielder in an advanced position / pass into him',
    'Compensate for the equality at the back and win the ball from the pass into the advanced midfielder.',
    '4-3-3', 116, 117, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Pirlo)', 'drops to support and balance, then double marks'),
    (2, 'Weak-side wing back (Lichtsteiner)', 'shifts across with the line'),
    (3, 'Nearest centre back (Bonucci)', 'presses the receiver')
) AS v(so, role, job);

-- 46. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-3-3', 'Hold zone, drop on open ball',
    'When the ball reaches the holding midfielder centrally, the Juve midfielders do not jump him but shift across; the nearest midfielder holds his zone so the midfield line is not unbalanced and the far midfielder is not freed. While the carrier is unpressed the defenders drop to stay a safe distance away, stopping at the edge of the box; if he dribbles forward Pirlo closes him with a triangle behind.',
    'Opposition holding midfielder receives centrally unpressed',
    'Stay balanced, give the wing back time to recover and keep a spare man at the back.',
    '4-3-3', 117, 117, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder (Vidal)', 'closest but stays in his zone to keep the line balanced'),
    (2, 'Defenders', 'drop back during the open ball, stop just outside the penalty area'),
    (3, 'Left wing back (Asamoah)', 'uses the time to recover into the line (5 v 4)'),
    (4, 'Defensive midfielder (Pirlo)', 'closes the carrier once he advances'),
    (5, 'Marchisio and Vidal', 'triangle behind Pirlo')
) AS v(so, role, job);

-- 47. pp.118-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 3: Defending With the Rear Block Against the 4-3-3', 'Step up on back pass, re-compact',
    'When the opponent plays backwards into midfield, a midfielder closes the receiver and the defenders use the travel time to step forward and across, compacting the block. A following pass wide to the full back is pressed by the wing back while the line chain-shifts; a midfielder drops beside the defenders if an attacking midfielder is high, and if both attacking midfielders push up, both Pirlo and Marchisio drop.',
    'Back pass to a midfielder, then out to the full back',
    'Push the block up and keep it compact while still covering advanced midfielders.',
    '4-3-3', 118, 118, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder (Vidal)', 'closes the midfielder who receives the back pass'),
    (2, 'Defenders', 'move forward and across while the ball travels'),
    (3, 'Right wing back (Lichtsteiner)', 'presses the left back'),
    (4, 'Left central midfielder (Marchisio)', 'drops near the defenders when the No.10 is high'),
    (5, 'Pirlo', 'also drops if two attacking midfielders are advanced')
) AS v(so, role, job);

-- 48. pp.124-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 4: Forwards'' Defensive Positioning - Defending in a Passive Way Against a 3 Man Defence', 'Front two passive v three centre backs',
    'Against a three-man back line (no shape named), the two strikers sit in the middle third between the centre backs; when a wide centre back near the touchline has the ball, the near striker shifts toward him and the other drops back to the centre.',
    'Opponent building up with a back three, team defending passively',
    'Block through passes, protect the centre and stay compact with the midfielders.',
    NULL, 124, 124, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker on the ball side (Tevez)', 'moves toward the wide centre back on the ball'),
    (2, 'Other striker (Llorente)', 'drops back toward the centre'),
    (3, 'Front two', 'stay close to the midfield line')
) AS v(so, role, job);

-- 49. pp.125-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 4: Forwards'' Defensive Positioning - Pressing Against a 3 Man Defence', 'Strikers start the press, force wide',
    'When pressing a back three, one striker runs at the middle centre back with a curved run to shut one side, the other striker shifts toward the strong side but first blocks a forward pass, then presses the wide centre back when he receives while the first striker blocks the pass back to the middle; if the goalkeeper passes straight to a wide centre back, the press starts after that first pass.',
    'Ball with the middle centre back, or goalkeeper pass to a wide centre back',
    'Create a strong side, pin the ball near the touchline and make the attack predictable so the whole team can shift and compact.',
    NULL, 125, 125, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First striker (Tevez)', 'curved run onto the middle centre back to shut one side, then blocks the back pass'),
    (2, 'Second striker (Llorente)', 'blocks the forward pass, waits, then presses the wide centre back on receipt (curved run)'),
    (3, 'Second striker', 'if the curved run worked, shifts straight to the strong side rather than going high first'),
    (4, 'Rest of team', 'shift across behind into a compact block')
) AS v(so, role, job);

-- 50. pp.126-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 4: Forwards'' Defensive Positioning - Using a Balanced Position Between 2 Players to Force the Ball Wide', 'Striker splits centre back and dropping 6',
    'When the opponent''s defensive midfielder drops deep to receive from a centre back (common in 3-4-1-2, 3-4-3, 3-5-2), the most advanced striker positions himself between that centre back and the 6 to cover both; the pass into the 6 is the priority to cut. The ball-side central midfielder does not chase the dropping 6 but stays in support of the wing back so the diagonal lane stays shut; if the 6 receives, the striker drops onto him with the midfielder pressing from the front.',
    'Opposition defensive midfielder drops near the centre backs',
    'Force the ball wide by cutting the central lane, leaving only a back pass.',
    NULL, 126, 135, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Most advanced striker (Tevez)', 'balanced between the middle centre back and the 6, focus on the 6'),
    (2, 'Other striker (Llorente)', 'drops into a balanced spot between the wide centre back and the 6 when the ball is on his side'),
    (3, 'Ball-side central midfielder (Marchisio)', 'stays in a supporting spot, does not follow the 6; presses him if he turns'),
    (4, 'Left wing back (Asamoah)', 'shifts to the strong side with Marchisio'),
    (5, 'Other midfielders', 'move close around the 6 so only a back pass is left')
) AS v(so, role, job);

-- 51. pp.127-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 4: Forwards'' Defensive Positioning - Defending in a Passive Way With the Front Block Against a 3 Man Defence', 'Passive mid-block, squeeze the lanes',
    'In the middle third against a back three the whole team shifts toward the ball with short distances, narrowing the passing lanes while midfielders keep a safe distance from the carrier so they have time to react; a pass into a central player is met at once by double or triple marking, and a centre back dribbling forward makes everyone converge to the centre.',
    'Opposition centre back in possession, team defending deep in the middle third',
    'Intercept or smother any pass into the centre; leave no space to exploit.',
    NULL, 127, 129, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strikers (Llorente, Tevez)', 'close to the midfield, block the lanes into the centre, join double/triple marking'),
    (2, 'Midfielders (Marchisio, Pirlo, Vidal)', 'keep a safe distance from the ball, converge on a central receiver'),
    (3, 'Wing backs (Asamoah, Lichtsteiner)', 'shift with the block; near one intercepts a pass between him and the midfielder'),
    (4, 'Whole block', 'gather near the ball zone if the carrier advances, squeezing space')
) AS v(so, role, job);

-- 52. pp.130-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 4: Forwards'' Defensive Positioning - Pressing With the Front Block (Forwards and Midfielders) Against a 3 Man Defence', 'Front block press to touchline trap',
    'From the goalkeeper''s ball, a striker presses the middle centre back to force play to one side; when the wide centre back receives, the other striker''s curved run cuts the pass back, midfielders and the wing back tightly mark the nearby receivers, and the first striker drops to add numbers. When the ball goes on to the wing back, the wing back and a midfielder timing his run during the pass double mark him while the strikers block the back pass and Pirlo shifts across.',
    'Goalkeeper or middle centre back passes to a wide centre back',
    'Strong side, pressure on the ball with all close receivers marked, then a numerical edge (about 5 v 3) around the ball to win it.',
    NULL, 130, 132, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First striker (Tevez)', 'presses the middle centre back to create the strong side, then drops back to add a man near the ball'),
    (2, 'Second striker (Llorente)', 'curved run onto the wide centre back, blocks the back pass'),
    (3, 'Ball-side central midfielder (Marchisio)', 'marks the near midfielder, then times his run to double mark the receiver'),
    (4, 'Ball-side wing back (Asamoah)', 'blocks the through pass, presses the opposing wing back'),
    (5, 'Defensive midfielder (Pirlo)', 'shifts toward the ball area to help'),
    (6, 'Far wing back (Lichtsteiner)', 'drops deeper to support the three defenders')
) AS v(so, role, job);

-- 53. pp.133-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 4: Forwards'' Defensive Positioning - Pressing With the Front Block Against a 3 Man Defence (Variation)', 'Late midfielder: support, not double',
    'If the ball-side central midfielder has not shifted in time when the ball goes to the wing back, he does not dive in but stays in support of the pressing wing back near the 6, blocking the horizontal and diagonal passes; the striker drops in to double mark instead, and Pirlo follows the No.10 if one appears.',
    'Pass to the opposing wing back while the attacking midfielder is away from the ball zone',
    'Keep central lanes shut; if double marking fails and the carrier has time, the team risks a switch of play.',
    NULL, 133, 134, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side central midfielder (Marchisio)', 'supporting position next to the 6, narrows the lane between himself and the wing back'),
    (2, 'Left wing back (Asamoah)', 'presses the ball'),
    (3, 'Striker (Llorente)', 'drops to double mark with Asamoah'),
    (4, 'Defensive midfielder (Pirlo)', 'tracks a No.10 offering inside')
) AS v(so, role, job);

-- 54. pp.144-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 4: Forwards'' Defensive Positioning - v 4 man defence (passive)', 'Front two screen midfield v back four',
    'Against a four-man back line Juve wait in the middle third; the two forwards sit near the midfielders to cut passes into the opposition midfield, the weak-side forward a little deeper.',
    'Opposition centre back or full back has the ball in his own half',
    'Keep the centre shut and the team compact so the opponent has to go round, not through.',
    NULL, 144, 144, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side forward (Llorente)', 'Stands between ball and inside midfielder, shifts toward strong side when ball goes to full back'),
    (2, 'Weak-side forward (Tevez)', 'Drops slightly deeper and tucks in to screen the centre'),
    (3, 'Midfielders', 'Stay close behind the forwards for compactness')
) AS v(so, role, job);

-- 55. pp.145-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 4: Forwards'' Defensive Positioning - v 4 man defence (passive, front + rear block)', 'Passive block narrows lanes then swarms the receiver',
    'Middle-third passive defence v a back four: the whole team slides to the ball side to narrow the two forward passing lanes (wide and inside); as the carrier steps forward the block tightens further. If a pass still reaches a midfielder inside the block, three players close him at once.',
    'Centre back receives from keeper, or carries the ball forward',
    'Deny through passes; any player receiving inside the block is double or triple marked immediately.',
    NULL, 145, 146, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side forward (Llorente)', 'Angle to cut the inside lane, collapse back on a central receiver'),
    (2, 'Ball-side central midfielder (Marchisio)', 'Narrows the lane to the deep receiver, joins triple mark inside'),
    (3, 'Holding midfielder (Pirlo)', 'Steps onto the central receiver as third marker'),
    (4, 'Whole team', 'Shift together; the closer the carrier the tighter the distances')
) AS v(so, role, job);

-- 56. pp.150-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 4: Forwards'' Defensive Positioning - v 4 man defence (pressing)', 'Who presses the full back v a back four',
    'When pressing a back four Juve aim to (1) force the ball to one side, (2) press the new wide receiver and tightly mark his options, (3) overload the ball zone with double marking. On the left the wing back presses an advanced full back, the attacking midfielder a deep one; on the right the attacking midfielder always goes because the right wing back stays deeper.',
    'Ball goes from centre back out to a full back',
    'Get pressure on the full back fast despite the long distances the wing backs and midfielders must cover.',
    NULL, 150, 151, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Asamoah)', 'First defender if the opposing full back is high'),
    (2, 'Left central midfielder (Marchisio)', 'First defender if the full back is deep'),
    (3, 'Right central midfielder (Vidal)', 'First defender on the right full back in all cases, starts slightly wide'),
    (4, 'Right wing back (Lichtsteiner)', 'Starts deeper, forms a back four on that side'),
    (5, 'Holding midfielder (Pirlo)', 'Slides across late to supply the extra man'),
    (6, 'Strong-side forward', 'Drops to double the full back with the midfielder')
) AS v(so, role, job);

-- 57. pp.151-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 4: Forwards'' Defensive Positioning - v 4 man defence (pressing)', 'Curved run creates strong side, deep full back',
    'A forward bends his run onto the centre back to show him one way, the team slides to that side and the far wing back drops to keep a spare man at the back. When the deep full back receives, the midfielder presses him and the forward drops behind to double; the holding midfielder steps up to mark the inside midfielder.',
    'Pass from centre back to a deep-lying full back',
    'Trap the ball near the sideline with two on the ball and all short options marked.',
    NULL, 151, 151, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near forward (Llorente)', 'Curved run on centre back, then drops to double the full back'),
    (2, 'Left central midfielder (Marchisio)', 'Presses the full back, triggers chain shift of the midfield'),
    (3, 'Holding midfielder (Pirlo)', 'Pushes up to take the opposing No.6'),
    (4, 'Far wing back (Lichtsteiner)', 'Drops to give numbers at the back')
) AS v(so, role, job);

-- 58. pp.152-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 4: Forwards'' Defensive Positioning - v 4 man defence (pressing)', 'Wing back jumps an advanced full back',
    'When the opposing full back is high, the left wing back uses the travel time of the pass to close him, the central midfielder arrives with a timed run to double, the forward cuts the return pass to the centre back. The holding midfielder stays deep to cover the space left by the wing back while the far forward slides in near the ball, giving 4 v 3 around it.',
    'Pass to a high-positioned full back',
    'Win the ball near the touchline with a local overload while the inside pass is screened.',
    NULL, 152, 152, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Asamoah)', 'Closes the full back during the ball''s travel'),
    (2, 'Left central midfielder (Marchisio)', 'Doubles the full back while still blocking the pass to No.6'),
    (3, 'Near forward (Llorente)', 'Blocks the pass back to the centre back'),
    (4, 'Holding midfielder (Pirlo)', 'Holds a deep cover position'),
    (5, 'Far forward (Tevez)', 'Shifts near the opposing No.6 in case it gets through')
) AS v(so, role, job);

-- 59. pp.153-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 4: Forwards'' Defensive Positioning - v 4 man defence (pressing)', 'Forward''s balanced position and midfielder''s choice',
    'If the opposing holding midfielder drops into a lane, the strong-side forward stands between the centre back and that midfielder to cover both, prioritising the pass to the midfielder. The central midfielder reads whether doubling the full back is worth it; if the timing is wrong he stays in a supporting spot behind the wing back, narrowing the line to the winger and the diagonal inside pass.',
    'Opposition No.6 drops to offer a passing option, or doubling is badly timed',
    'Never give up the central pass; double only when it will not open the inside.',
    NULL, 153, 153, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side forward (Llorente)', 'Balanced spot covering centre back and dropping No.6, drops to recompact'),
    (2, 'Left central midfielder (Marchisio)', 'Supports the wing back, blocks diagonal to No.10 instead of jumping'),
    (3, 'Left wing back (Asamoah)', 'Pressures full back with midfield cover behind')
) AS v(so, role, job);

-- 60. pp.154-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 4: Forwards'' Defensive Positioning - v 4 man defence (pressing)', 'Pressing on the right side v back four',
    'On the right the far forward bends his run onto the centre back to force play toward the opponent''s left back; the right central midfielder presses the left back and the forward drops to double, the holding midfielder picks up the near central midfielder. The right wing back stays back, so the far wing back need not drop deep. If an opposing midfielder drops, the forward takes a balanced spot between him and the centre back.',
    'Pass to the other centre back, then to the left back',
    'Strong side on the right with the ball double marked and short receivers covered.',
    NULL, 154, 154, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right forward (Tevez)', 'Curved run on centre back, drops to double, or balanced spot between CB and dropping midfielder'),
    (2, 'Right central midfielder (Vidal)', 'Presses the full back whether high or deep'),
    (3, 'Holding midfielder (Pirlo)', 'Marks the inside central midfielder, pushes up'),
    (4, 'Right wing back (Lichtsteiner)', 'Stays deep'),
    (5, 'Left central midfielder (Marchisio)', 'Supporting position, shifts as chain reaction')
) AS v(so, role, job);

-- 61. pp.155-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 4: Forwards'' Defensive Positioning - v 4 man defence (winger deep on strong side)', 'Winger deep: switch marks or stay home',
    'When the opposing winger sits deep near the wing back: if the near centre back is too far away to take the winger, the wing back stays with the winger (told by the centre back) and the central midfielder closes the full back. If the centre back is close, the wing back presses the full back during the pass, the centre back takes over the winger and the midfielder doubles - a chain reaction.',
    'Pass to full back with the winger deep on that flank',
    'Pressure the full back without leaving the winger free behind the wing back.',
    NULL, 155, 156, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Asamoah)', 'Stays on winger if gap to CB is big; else jumps full back'),
    (2, 'Left centre back (Chiellini)', 'Communicates; takes over the winger when close enough'),
    (3, 'Left central midfielder (Marchisio)', 'Closes full back or arrives as second marker')
) AS v(so, role, job);

-- 62. pp.166-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 5: Defending Against the 3-4-3 (passive)', 'Starting shape v 3-4-3',
    'Against a front three Juve make a back four by dropping the more defensive wing back, the near forward stands higher to steer the ball to one side, the far central midfielder shifts toward the opposing wing back.',
    'Ball with the opposition goalkeeper',
    'Avoid 3 v 3 at the back and set up a side to defend.',
    '3-4-3', 166, 166, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Lichtsteiner)', 'Drops to form a back four'),
    (2, 'Right forward (Tevez)', 'Slightly higher, shows ball toward Juve''s left'),
    (3, 'Right central midfielder (Vidal)', 'Edges toward the opposing wing back')
) AS v(so, role, job);

-- 63. pp.167-167
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 5: Defending Against the 3-4-3 (passive)', 'Middle-third shift with spare man v 3-4-3',
    'Juve wait in the middle third and slide with each pass. When a wide centre back or wing back gets it, the near central midfielder (not the wing back) goes to him so the deep wing back keeps 4 v 3 behind; a forward drops onto the inside midfielder. A centre back does not chase a forward who drops very deep - the holding midfielder picks him up.',
    'Pass to opposing wide centre back or wing back',
    'Keep a compact block at a safe distance and a numerical edge at the back.',
    '3-4-3', 167, 167, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder (Vidal)', 'Closes the wide receiver'),
    (2, 'Right forward (Tevez)', 'Drops to mark the inside central midfielder'),
    (3, 'Right wing back (Lichtsteiner)', 'Stays deep for 4 v 3'),
    (4, 'Right centre back (Barzagli)', 'Lets a dropping forward go'),
    (5, 'Holding midfielder (Pirlo)', 'Takes the forward who dropped')
) AS v(so, role, job);

-- 64. pp.168-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 5: Defending Against the 3-4-3 (passive)', 'Switch of play without time v 3-4-3',
    'When the opponent switches to the far wing back but he has no time, the near wing back uses the ball''s travel to close him and forces him wide so the midfielder can arrive; the near centre back picks up the winger. The back line, already 4 v 3, does not need to drop.',
    'Switch of play to a receiver with no time',
    'Contain the switch without adjusting the back line.',
    '3-4-3', 168, 168, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Asamoah)', 'Closes receiver, shows him to sideline'),
    (2, 'Left centre back (Chiellini)', 'Marks the winger'),
    (3, 'Left central midfielder (Marchisio)', 'Gets into support'),
    (4, 'Back line', 'Holds, no drop needed')
) AS v(so, role, job);

-- 65. pp.169-169
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 5: Defending Against the 3-4-3 (passive)', 'Not following a winger''s decoy run v 3-4-3',
    'The opposing wing back and winger move in opposite directions to open the flank. The centre back reads it and drops instead of tracking the winger, so the long ball into space is off; the back four drops a touch. If the winger then gets the ball short, three Juve players close him.',
    'Synchronised opposite runs by wing back and winger',
    'Deny space behind the wing back; swarm the short receiver.',
    '3-4-3', 169, 169, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Chiellini)', 'Drops, does not follow the winger'),
    (2, 'Back four', 'Drops slightly together'),
    (3, 'Nearby midfielders + wing back', 'Triple-mark the winger on receiving')
) AS v(so, role, job);

-- 66. pp.170-171
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 5: Defending Against the 3-4-3 (pressing)', 'Pressing v 3-4-3: strong side and contesting long ball',
    'A forward presses the first receiving centre back and shows him to one side, the other forward takes a balanced spot between the other centre back and the dropping midfielder, all shift, 4 v 3 at the back. With short lanes shut, a long pass to the winger is attacked hard by the centre back, with the holding and central midfielder collapsing to double and the wing back dropping to cut the next pass.',
    'Goalkeeper''s first pass; then a long ball to a front player',
    'Force predictable long balls and win them with an aggressive contest plus support.',
    '3-4-3', 170, 171, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right forward (Tevez)', 'Presses the receiver, creates strong side'),
    (2, 'Left forward (Llorente)', 'Presses next centre back'),
    (3, 'Left centre back (Chiellini)', 'Contests the winger aggressively, else makes him miscontrol'),
    (4, 'Holding midfielder (Pirlo)', 'Comes across to double'),
    (5, 'Left wing back (Asamoah)', 'Drops to block the pass to the wing back')
) AS v(so, role, job);

-- 67. pp.171-172
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 5: Defending Against the 3-4-3 (pressing)', 'Switch with time: play for time, then press',
    'After a switch to a receiver with time, the nearest wing back must judge. With forwards running behind (open ball) defenders drop and shift; the near centre back takes the inside forward, the wing back delays rather than jumps until midfield has recompacted, then presses with the central midfielder supporting. Once the receiver is shielding (closed ball) the back line stops dropping.',
    'Successful switch, receiver has time',
    'Avoid being caught 3 v 3 by delaying until the block is back in shape.',
    '3-4-3', 171, 172, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Lichtsteiner)', 'Delays, then closes the receiver once support exists'),
    (2, 'Right centre back (Barzagli)', 'Shifts out to mark the inside forward'),
    (3, 'Right central midfielder (Vidal)', 'Supporting position behind the press'),
    (4, 'Defenders', 'Drop on open ball, stop on closed ball')
) AS v(so, role, job);

-- 68. pp.173-173
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 5: Defending Against the 3-4-3 (pressing)', 'All receivers tightly marked when far wing back high',
    'Pressing on the right while the left wing back is high: the right wing back stays to keep 4 v 3, the central midfielder presses the wide receiver and the forward drops to double; the wing back takes the inside forward and the holding midfielder steps onto the central midfielder.',
    'Pass from centre back out to the opposing left midfielder',
    'Every short option marked tight so defenders can contest aggressively.',
    '3-4-3', 173, 173, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right forward (Tevez)', 'Presses CB, drops to double the wide man'),
    (2, 'Left forward (Llorente)', 'Shifts right after the inside pass is blocked'),
    (3, 'Right central midfielder (Vidal)', 'First pressure on wide receiver'),
    (4, 'Right wing back (Lichtsteiner)', 'Stays deep, takes the inside forward'),
    (5, 'Holding midfielder (Pirlo)', 'Advances to mark the central midfielder')
) AS v(so, role, job);

-- 69. pp.174-175
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 5: Defending Against the 3-4-3 (3 v 3 at the back)', 'Holding midfielder drops v 3 v 3',
    'The opponent''s best trick is a central midfielder running into a forward spot behind Juve''s midfield, making 4 v 4 at the back. The holding midfielder drops near the defenders to compensate; the wing back takes the advanced midfielder, the far wing back drops; if the ball reaches the extra man, a centre back contests and the holding midfielder doubles, buying time for the far wing back.',
    'Opposing central midfielder moves into an advanced position behind the midfield line',
    'Restore a spare man at the back.',
    '3-4-3', 174, 175, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Pirlo)', 'Drops close to the back line, later doubles'),
    (2, 'Right central midfielder (Vidal)', 'Presses the wide receiver'),
    (3, 'Right wing back (Lichtsteiner)', 'Takes over the advanced midfielder''s marking'),
    (4, 'Left wing back (Asamoah)', 'Drops into an effective spot (5 v 4)'),
    (5, 'Right centre back (Barzagli)', 'Contests the new carrier')
) AS v(so, role, job);

-- 70. pp.181-182
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 6: Defending Against the 3-4-1-2 (passive)', 'Spare man v 3-4-1-2 and the dropping wing back',
    'Versus two strikers Juve have 3 v 2 behind. When the attacking midfielder pushes up, a wing back drops to keep the extra man: usually the more defensive right wing back moves inside toward the centre, but if the ball is near the sideline it is the far-side wing back who drops.',
    'Opposition No.10 takes an advanced position',
    'Always keep one more defender than attackers.',
    '3-4-1-2', 181, 182, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Lichtsteiner)', 'Drops to a deeper, more central spot'),
    (2, 'Weak-side wing back (Asamoah when ball is on right)', 'Drops to restore the spare man'),
    (3, 'Back three', 'Stay with the two forwards')
) AS v(so, role, job);

-- 71. pp.182-182
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 6: Defending Against the 3-4-1-2 (passive)', 'Aggressive contest on forward inside compact block',
    'Defending passively, the team slides to the ball and the far wing back drops even with a 3 v 2. If a through ball still finds a striker, the short distances let the nearest centre back contest him aggressively while the midfielders and wing back drop around the ball zone.',
    'Through pass to a forward',
    'Win the ball on his first touch.',
    '3-4-1-2', 182, 182, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back (Barzagli)', 'Attacks the receiving forward'),
    (2, 'Left wing back (Asamoah)', 'Drops for safety'),
    (3, 'Right central midfielder, holding midfielder, right wing back', 'Drop near the ball zone')
) AS v(so, role, job);

-- 72. pp.183-183
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 6: Defending Against the 3-4-1-2 (passive)', 'Playing for time at equal numbers v 3-4-1-2',
    'A forward drifts to the sideline and the No.10 runs into the space created, leaving 3 v 3. The holding midfielder follows the No.10 a few yards, one centre back controls the No.10, another follows the forward; the far wing back drops. The defender on the ball delays rather than tackles until 4 v 3 is back, then becomes aggressive.',
    'Forward moves wide, No.10 attacks the vacated space',
    'Avoid being exposed 1 v 1; regain the spare man first.',
    '3-4-1-2', 183, 183, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back (Barzagli)', 'Follows the forward, plays for time'),
    (2, 'Central centre back (Bonucci)', 'Controls the No.10'),
    (3, 'Holding midfielder (Pirlo)', 'Tracks the No.10 for a few yards'),
    (4, 'Weak-side wing back (Asamoah)', 'Drops to restore numbers')
) AS v(so, role, job);

-- 73. pp.184-185
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 6: Defending Against the 3-4-1-2 (pressing)', 'Pressing v 3-4-1-2 and overload around the ball',
    'A forward closes the middle centre back so he can only go one way; the other forward presses the next centre back and the first forward takes a balanced spot when a midfielder drops. On the pass to the wing back, the wing back and a timed midfielder run double him, a forward blocks the inside pass, the far forward joins (6 v 5). If the ball still goes inside to the No.10, the three nearest close him.',
    'Goalkeeper passes to the middle centre back',
    'Use numbers around the ball so even a failed double ends in a swarm.',
    '3-4-1-2', 184, 185, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right forward (Tevez)', 'Blocks pass to the far centre back, then balanced spot'),
    (2, 'Left forward (Llorente)', 'Presses next centre back, then balanced spot to cut No.10/No.6'),
    (3, 'Left wing back (Asamoah)', 'Closes the opposing wing back'),
    (4, 'Left central midfielder (Pogba)', 'Timed run to double'),
    (5, 'Holding midfielder (Pirlo)', 'Third marker on a central receiver')
) AS v(so, role, job);

-- 74. pp.186-186
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 6: Defending Against the 3-4-1-2 (pressing)', 'Switch with time v 3-4-1-2: delay and recover',
    'After a switch to the far side the nearest wing back evaluates: jumping at once would leave the striker free while the centre back is still shifting and forwards attack the space (open ball), so all defenders drop. Once the centre back has the striker, the wing back presses to force the man to the sideline until the central midfielder supports; the far wing back recovers; on a closed ball, stop dropping.',
    'Switch of play reaches a receiver with time',
    'Recover shape before engaging the switched ball.',
    '3-4-1-2', 186, 186, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Lichtsteiner)', 'Waits, then presses and shows to sideline'),
    (2, 'Right centre back (Barzagli)', 'Takes over the striker'),
    (3, 'Right central midfielder (Vidal)', 'Arrives in support'),
    (4, 'Left wing back (Asamoah)', 'Drops back'),
    (5, 'Defenders', 'Drop on open ball, stop on closed ball')
) AS v(so, role, job);

-- 75. pp.187-187
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 6: Defending Against the 3-4-1-2 (pressing)', 'Weak-side wing back levels with 3 v 3',
    'When the No.10 sits behind Juve''s midfield on the weak side, the weak-side wing back drops level with him to remove the 3 v 3. A long ball to the striker on the strong side is then attacked by the centre back with two midfielders closing to triple mark and the near wing back and middle centre back covering behind.',
    'No.10 positions behind the midfield away from the ball',
    'Make the back line safe so the centre back can go hard at the long ball.',
    '3-4-1-2', 187, 187, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side wing back (Lichtsteiner)', 'Drops in line with the No.10'),
    (2, 'Left centre back (Chiellini)', 'Contests the receiver to get there first'),
    (3, 'Left central midfielder (Pogba) + holding midfielder (Pirlo)', 'Collapse for triple marking'),
    (4, 'Left wing back (Asamoah) + middle centre back (Bonucci)', 'Cover behind')
) AS v(so, role, job);

-- 76. pp.189-189
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 7: Defending Against the 3-5-2 (passive)', 'Spare man v 3-5-2 when No.10 pushes up',
    'Juve start with 3 v 2 at the back against a 3-5-2. If an opposing midfielder moves forward next to the strikers, the weak-side wing back moves across and back level with him for 4 v 3.',
    'Opposition attacking midfielder advances',
    'Keep a spare defender at all times.',
    '3-5-2', 189, 189, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side wing back (Asamoah)', 'Drops in line with the advancing midfielder'),
    (2, 'Back three', 'Hold 3 v 2 on the strikers')
) AS v(so, role, job);

-- 77. pp.190-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 7: Defending Against the 3-5-2 (passive)', 'Central receiver triple marked v 3-5-2',
    'When a centre back carries forward Juve squeeze up and narrow the lanes; if the pass reaches the central midfielder anyway, both forwards and the holding midfielder close him at once.',
    'Opposing centre back steps forward with the ball, pass to central midfielder',
    'Turn a successful central pass into an immediate loss.',
    '3-5-2', 190, 190, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two (Llorente, Tevez)', 'Collapse onto the central receiver'),
    (2, 'Holding midfielder (Pirlo)', 'Third marker from in front'),
    (3, 'Midfield line', 'Compact to block through passes')
) AS v(so, role, job);

-- 78. pp.191-191
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 7: Defending Against the 3-5-2 (passive)', 'Forward tracks back to get behind the ball',
    'If an opposing midfielder receives and carries forward, the central midfielder holds his place and the forward tracks back to close him and get goal-side again; the rest drop to a safe distance. Once he is forced wide, everyone stops retreating and steps up a few yards during the travel of the pass.',
    'Midfielder receives and dribbles into space',
    'Recover shape behind the ball, then reclaim ground when the ball goes wide.',
    '3-5-2', 191, 191, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right forward (Tevez)', 'Tracks and closes the carrier'),
    (2, 'Right central midfielder (Vidal)', 'Stays in line, hands the man to the forward'),
    (3, 'Rest of team', 'Drop, then step up on the wide pass')
) AS v(so, role, job);

-- 79. pp.192-193
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 7: Defending Against the 3-5-2 (pressing)', 'Pressing v 3-5-2 on the right',
    'A forward presses high so the pass to one centre back is blocked; the other forward presses the receiving wide centre back so he cannot go back inside, while the first drops beside the holding midfielder. The central midfielder and right centre back mark the inside options tight, the wing back jumps the wide receiver with the forward doubling: 3 v 2 behind.',
    'Goalkeeper passes to a centre back',
    'Steer the ball to a wing and mark every nearby receiver.',
    '3-5-2', 192, 193, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left forward (Llorente)', 'Blocks one side, then drops near the opposing No.6'),
    (2, 'Right forward (Tevez)', 'Presses wide centre back blocking the back pass, then doubles'),
    (3, 'Right central midfielder (Vidal)', 'Marks inside midfielder tight'),
    (4, 'Right centre back (Barzagli)', 'Marks the striker tight'),
    (5, 'Right wing back (Lichtsteiner)', 'Presses the wide receiver')
) AS v(so, role, job);

-- 80. pp.194-194
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 7: Defending Against the 3-5-2 (pressing)', 'Switch with time v 3-5-2',
    'After a switch the block shifts during the ball''s travel. If strikers do not run behind, defenders need not drop; the wing back reads that it is 4 v 2 (3 v 2 after he goes), the central midfielder is in support and the centre back already marks the striker, so he steps out and closes the carrier.',
    'Switch to a receiver with time on the ball',
    'Engage the switch only when cover and support are in place.',
    '3-5-2', 194, 194, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Lichtsteiner)', 'Judges, then closes the carrier'),
    (2, 'Right central midfielder (Vidal)', 'Supporting position'),
    (3, 'Right centre back (Barzagli)', 'Takes over the striker during ball travel')
) AS v(so, role, job);

-- 81. pp.195-195
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 7: Defending Against the 3-5-2 (3 v 3 at the back)', 'Compensating a 3 v 3 v 3-5-2',
    'An opposing midfielder runs into space behind the wing back for 3 v 3. The central midfielder follows briefly, the centre back gets ready to pick him up, the far wing back drops and all shift. If an accurate long ball arrives, the centre back contests to buy time until a wing back is back, then goes aggressive with the midfielder doubling.',
    'Opposing midfielder runs beyond the midfield into the wing back''s space',
    'Survive equal numbers by delay and talk, then win the ball once numbers return.',
    '3-5-2', 195, 195, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Chiellini)', 'Takes the runner, plays for time, then contests'),
    (2, 'Left central midfielder (Pogba)', 'Follows the runner a few yards, doubles'),
    (3, 'Far wing back (Lichtsteiner)', 'Drops to remove the 3 v 3'),
    (4, 'Near wing back (Asamoah)', 'Recovers if possible')
) AS v(so, role, job);

-- 82. pp.197-199
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 8: Defending Against the 4-2-3-1 - Starting positions', 'Uneven wing backs make a back four',
    'Against a 4-2-3-1 a 5 v 3 at the back is too cautious. So the left wing back starts high and the right wing back sits deep, giving 4 v 3 behind.',
    'Keeper or a centre back has the ball',
    'Keep a spare defender without giving up pressure on the full back.',
    '4-2-3-1', 197, 199, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Asamoah)', 'start high, first to press the right back when the ball goes there'),
    (2, 'Left centre back (Chiellini)', 'slide out onto the left winger once the wing back steps up (chain reaction)'),
    (3, 'Right wing back (Lichtsteiner)', 'start deep, marking the left winger'),
    (4, 'Right central midfielder (Vidal)', 'when their left CB has the ball, push wide to be close to their left back'),
    (5, 'Left central midfielder (Pogba)', 'sometimes presses the right back himself if the wing back is deep')
) AS v(so, role, job);

-- 83. pp.199-199
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 8: Defending Against the 4-2-3-1 - Starting positions', 'Deep wing back tucks in vs narrow wingers',
    'Both opposing wingers play narrow, giving three forwards close together in the middle.',
    'Wingers move inside',
    'Keep a spare man in the centre of the back line.',
    '4-2-3-1', 199, 199, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Lichtsteiner)', 'move inside, next to the back three'),
    (2, 'Back three', 'mark the narrow forwards with the wing back as the spare man')
) AS v(so, role, job);

-- 84. pp.199-199
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 8: Defending Against the 4-2-3-1 - Starting positions', 'High wing back drops vs advanced No.10',
    'The No.10 pushes up behind our midfield line, which would leave 4 v 4 at the back.',
    'Attacking midfielder steps up beyond our midfield',
    'Get the 5 v 4 back by dropping the advanced wing back.',
    '4-2-3-1', 199, 199, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Asamoah)', 'read it and drop into the back line'),
    (2, 'Back three', 'pick up the forwards and the No.10')
) AS v(so, role, job);

-- 85. pp.200-200
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 8: Defending Against the 4-2-3-1 - Defending in a Passive Way', 'Mid block shifts to block through balls',
    'A passive block waits in the middle third and slides as one to the ball side. As the centre back carries forward, the block tightens even more.',
    'Centre back has the ball or carries it in the middle third',
    'Narrow every forward lane, then intercept the pass forward.',
    '4-2-3-1', 200, 200, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'slide toward the ball and close the gaps between players'),
    (2, 'Left wing back (Asamoah)', 'cut out the pass to the right winger'),
    (3, 'Midfield three', 'close the central lanes')
) AS v(so, role, job);

-- 86. pp.200-201
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 8: Defending Against the 4-2-3-1 - Defending in a Passive Way', 'Triple mark the central receiver',
    'The block is compact, so a pass from the full back into the No.6 or No.10 (inside or diagonal) lands among three defenders.',
    'Full back plays into a central midfielder in the narrow lane',
    'Win the ball at once, or force a bad first touch.',
    '4-2-3-1', 200, 201, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lone forward + two nearest midfielders (Llorente, Pogba, Tevez)', 'close in from three sides on the receiver'),
    (2, 'Deep midfielder (Pirlo)', 'stay tight on the No.10 to cut the next pass, or attack the receiver hard if the ball reaches the No.10'),
    (3, 'Right midfielder (Vidal)', 'move closer to the ball zone in support')
) AS v(so, role, job);

-- 87. pp.202-203
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 8: Defending Against the 4-2-3-1 - Pressing', 'Curved-run press, man-mark ball side',
    'The forward bends his run at the centre back to show him one way. Everyone shifts, and when the ball reaches the full back he is double marked while all close receivers are man-marked.',
    'Keeper passes to a centre back',
    'Make a strong side, outnumber them around the ball, and win it.',
    '4-2-3-1', 202, 203, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Llorente)', 'curved run at the centre back, then a balanced spot cutting both the back pass and the pass to the No.6'),
    (2, 'Second forward (Tevez)', 'drop to the strong side to keep it compact'),
    (3, 'Left wing back + left midfielder (Asamoah, Pogba)', 'double mark the full back'),
    (4, 'Left centre back (Chiellini)', 'mark the winger tight; if the winger gets it, step out hard and triple mark him with Asamoah and Pirlo'),
    (5, 'Deep midfielder (Pirlo)', 'mark the No.10 tight')
) AS v(so, role, job);

-- 88. pp.203-205
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 8: Defending Against the 4-2-3-1 - Pressing', 'Track the No.10 when pressing',
    'In a left-side press with the wing back already high, the No.10 runs in behind Pirlo, which threatens 4 v 4.',
    'No.10 moves behind our deep midfielder',
    'Keep the extra man and help on long balls to the striker.',
    '4-2-3-1', 203, 205, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfielder (Vidal)', 'follow the No.10 back toward the defenders; on a long ball, double the striker'),
    (2, 'Central centre back (Bonucci)', 'if the striker wins the ball first, contain him and stop him turning, without diving in'),
    (3, 'Deep midfielder (Pirlo)', 'drop to help'),
    (4, 'Left wing back (Asamoah)', 'use the time bought to recover, so it is 5 v 4')
) AS v(so, role, job);

-- 89. pp.204-204
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 8: Defending Against the 4-2-3-1 - Defending the switch of play', 'Switch to their left: hold, then press',
    'The ball is switched to their left back, who has time and space (open ball), while the forwards run in behind.',
    'Long switch reaches the far full back unpressed',
    'Stop the ball in behind first, then press once we are compact.',
    '4-2-3-1', 204, 204, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'drop back and shift right while the ball is open'),
    (2, 'Right wing back (Lichtsteiner)', 'do not jump at first (it would be 3 v 3); hold until the midfield is closer, then press'),
    (3, 'Right centre back (Barzagli)', 'slide over and take the left winger'),
    (4, 'Right midfielder (Vidal)', 'move into support'),
    (5, 'Left wing back (Asamoah)', 'get back into a useful position')
) AS v(so, role, job);

-- 90. pp.205-206
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 8: Defending Against the 4-2-3-1 - Pressing', 'Press with the wing back held deep',
    'The left wing back is deep marking the winger (5 v 3), and the No.10 pushes up. We still have a spare man behind, so we press with a midfielder.',
    'Ball to the right back with the left wing back deep',
    'Press without losing numbers behind.',
    '4-2-3-1', 205, 206, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left midfielder (Pogba)', 'press the right back'),
    (2, 'Forward (Llorente)', 'drop to block the pass back to the No.6'),
    (3, 'Left wing back (Asamoah)', 'mark the winger tight'),
    (4, 'Right midfielder (Vidal)', 'leave the No.10 to the back line'),
    (5, 'Left centre back (Chiellini)', 'attack a long ball into the No.10, as we have the extra man')
) AS v(so, role, job);

-- 91. pp.206-206
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 8: Defending Against the 4-2-3-1 - Pressing', 'Right-side press, everyone marked',
    'Tevez bends his run to show the ball to their left back. A chain of shifts then man-marks every option near the ball.',
    'Centre back passes to the left back',
    'Get a balanced 4 v 3 with the ball double marked and nothing to change.',
    '4-2-3-1', 206, 206, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Second forward (Tevez)', 'curved run, then drop to double the ball and block the pass back to the CB'),
    (2, 'Right midfielder (Vidal)', 'close down the left back'),
    (3, 'Deep midfielder (Pirlo)', 'step up onto their No.8 (chain reaction)'),
    (4, 'Right wing back (Lichtsteiner)', 'start deep, step out to mark the left winger'),
    (5, 'Left wing back (Asamoah)', 'drop into the back line if needed')
) AS v(so, role, job);

-- 92. pp.207-208
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 8: Defending Against the 4-2-3-1 - Defending the switch of play', 'Switch to their right: drop, close, step up',
    'They switch to the right back, who carries forward with time. We drop and shift, then close him down, then step up when he passes back.',
    'Switch to the right back; then a closed ball; then a back pass',
    'Recover the shape, push their forwards offside and stay compact.',
    '4-2-3-1', 207, 208, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Chiellini)', 'take over the right winger while the ball travels'),
    (2, 'Left wing back (Asamoah)', 'step up and close the right back so he has to shield it'),
    (3, 'Left midfielder (Pogba)', 'move close to support'),
    (4, 'Back line', 'drop while the ball is open, stop once he is closed, and step up a few yards on the back pass'),
    (5, 'Midfield', 'keep sliding across')
) AS v(so, role, job);

-- 93. pp.210-211
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 9: Defending Against the 4-4-2 - Defending in a Passive Way', '3 v 2 base, passive winger trap',
    'Against a 4-4-2 the back three is already 3 v 2 with no tweaks. A pass out to the full back, then down the line to the winger, is met by a double mark near the touchline.',
    'Full back plays down the line to the winger',
    'Outnumber them by the touchline and win the ball.',
    '4-4-2', 210, 211, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near midfielder (Vidal)', 'move toward the full back without getting too close, then drop to double the winger'),
    (2, 'Second forward (Tevez)', 'drop to watch the No.8 and block the inside pass'),
    (3, 'Right wing back (Lichtsteiner)', 'mark the winger tight and stop him turning'),
    (4, 'Right centre back (Barzagli)', 'mark the near forward tight'),
    (5, 'Deep midfielder (Pirlo)', 'move into the ball zone to add a man')
) AS v(so, role, job);

-- 94. pp.212-212
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 9: Defending Against the 4-4-2 - Pressing', 'Press left, double the right back',
    'The forward presses the centre back to force play to our left. On the pass to the right back, an attacking midfielder jumps and the forward drops to double him.',
    'Keeper passes to a centre back',
    'Mark every receiver and double the ball, the ideal pressing picture.',
    '4-4-2', 212, 212, 940)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Llorente)', 'press the centre back, then drop to double the right back'),
    (2, 'Left midfielder (Pogba)', 'press the right back'),
    (3, 'Deep midfielder (Pirlo)', 'step up onto the No.6 (chain reaction)'),
    (4, 'Left wing back (Asamoah)', 'mark the winger tight'),
    (5, 'Second forward (Tevez)', 'be ready if the ball goes to the No.6')
) AS v(so, role, job);

-- 95. pp.213-213
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 9: Defending Against the 4-4-2 - Pressing', 'Cover a 5 v 5 at the back',
    'Their central midfielder runs past Pogba while the wing back is up, so it is level at the back. The centre back steps out and Pirlo drops in to double.',
    'Central midfielder runs beyond our pressing midfielder',
    'Make up for being level at the back, or the receiver can turn and attack.',
    '4-4-2', 213, 213, 950)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep midfielder (Pirlo)', 'follow the runner a few yards toward the defenders, then double the receiver'),
    (2, 'Left centre back (Chiellini)', 'step forward near the No.6 while still covering the wing back; press him as soon as he gets it'),
    (3, 'Left wing back (Asamoah)', 'step up onto the winger'),
    (4, 'Central centre back (Bonucci)', 'cover behind'),
    (5, 'Forward (Llorente)', 'drop')
) AS v(so, role, job);

-- 96. pp.214-214
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 9: Defending Against the 4-4-2 - Defending the switch of play', 'Absorb a switch v 4-4-2',
    'They switch to the left back, who has space. The defenders stay close together and retreat, and the right centre back takes the winger.',
    'Switch reaches the far full back unpressed',
    'Keep 5 v 4 behind, then stop dropping once the ball is closed.',
    '4-4-2', 214, 214, 960)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back (Barzagli)', 'slide across to the left winger'),
    (2, 'Right midfielder (Vidal)', 'shift across and become first defender on the left back'),
    (3, 'Right wing back (Lichtsteiner)', 'press the ball himself only if Vidal is too far, and only once the midfield has recovered'),
    (4, 'Back line', 'drop while the ball is open, then stop once he is closed')
) AS v(so, role, job);

-- 97. pp.216-216
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 10: Defending Against the 4-3-3 - Starting positions', 'Back four vs 4-3-3 via asymmetry',
    'To avoid a cautious 5 v 3, the left wing back plays high and the right wing back drops a few yards. Vidal edges toward their left back.',
    'Keeper has the ball',
    'Keep a four-man back line while still pressing the full back.',
    '4-3-3', 216, 216, 970)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Asamoah)', 'start high to press the right back'),
    (2, 'Right wing back (Lichtsteiner)', 'drop a few yards into the back line'),
    (3, 'Right midfielder (Vidal)', 'start wider, nearer their left back')
) AS v(so, role, job);

-- 98. pp.217-217
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 10: Defending Against the 4-3-3 - Defending in a Passive Way', 'Passive block, triple mark the winger',
    'The block slides left. The wing back closes the right back while cutting the line to the winger, and the forward drops to block the pass to the No.10.',
    'Ball goes to the right back, then down the line',
    'Leave only the harmless back pass, and triple mark the winger if he gets it.',
    '4-3-3', 217, 217, 980)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Llorente)', 'drop to block the pass into the No.10 rather than the back pass'),
    (2, 'Left wing back (Asamoah)', 'close the right back at a safe distance, then drop to double the winger'),
    (3, 'Left centre back (Chiellini)', 'press the winger hard and stop him turning'),
    (4, 'Left midfielder (Pogba)', 'join in to triple mark the winger')
) AS v(so, role, job);

-- 99. pp.218-218
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 10: Defending Against the 4-3-3 - Defending in a Passive Way', 'Intercept inside and diagonal passes',
    'The full back tries to play inside to the No.10, or diagonally into the striker. The narrow block leaves only tight lanes.',
    'Full back plays inside or diagonally',
    'Read the pass and intercept it.',
    '4-3-3', 218, 218, 990)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward + left midfielder (Llorente, Pogba)', 'close the inside lane; Llorente cuts out the pass to the No.10'),
    (2, 'Deep midfielder (Pirlo)', 'with more time to react, cut out the diagonal to the striker')
) AS v(so, role, job);

-- 100. pp.219-219
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 10: Defending Against the 4-3-3 - Pressing', 'Wing back presses the full back',
    'In a left-side press the high wing back is the one who presses the right back. The forward drops to double him.',
    'Ball to the right back',
    'Double the ball, man-mark the near receivers and keep numbers behind.',
    '4-3-3', 219, 219, 1000)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Llorente)', 'press the centre back to force play left, then drop to double the right back'),
    (2, 'Left wing back (Asamoah)', 'press the right back'),
    (3, 'Left midfielder (Pogba)', 'block the through pass and stay with the No.6 rather than jumping too'),
    (4, 'Deep midfielder (Pirlo)', 'follow the No.10''s run a few yards, then mark him tight'),
    (5, 'Left centre back (Chiellini)', 'mark the right winger tight')
) AS v(so, role, job);

-- 101. pp.220-220
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 10: Defending Against the 4-3-3 - Pressing', 'Pass on wingers who drop inside',
    'The weak-side No.8 pushes up and the right winger comes inside. Defenders hand him on instead of following him out.',
    'Weak-side No.8 advances; winger drifts inside',
    'Keep the extra man behind and win long balls with a triple mark.',
    '4-3-3', 220, 220, 1010)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfielder (Vidal)', 'drop back with the advancing No.8, close to the defenders'),
    (2, 'Left centre back (Chiellini)', 'stay near the back line instead of tracking the winger'),
    (3, 'Central centre back (Bonucci)', 'tell Chiellini to let him go; attack a long ball to the striker'),
    (4, 'Left midfielder (Pogba)', 'take over the dropped winger'),
    (5, 'Forward (Llorente)', 'take a balanced spot between their centre back and the No.10'),
    (6, 'Vidal + Pirlo', 'close in to double and then triple the striker')
) AS v(so, role, job);

-- 102. pp.221-221
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 10: Defending Against the 4-3-3 - Pressing', 'Right-side press, attack the striker',
    'Tevez presses the centre back to show the ball to their left back. Vidal presses, the chain moves across, and a pass into the striker is attacked hard.',
    'Centre back passes to the left back',
    'Win the striker''s touch while the others cover behind.',
    '4-3-3', 221, 221, 1020)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Second forward (Tevez)', 'press, then take a balanced spot cutting the back pass and the pass to the No.6'),
    (2, 'Right midfielder (Vidal)', 'close the left back while blocking the through pass'),
    (3, 'Deep midfielder (Pirlo)', 'slide onto the No.8, and drop to help if the striker gets it'),
    (4, 'Right wing back (Lichtsteiner)', 'step out to mark the left winger tight'),
    (5, 'Right centre back (Barzagli)', 'attack the striker hard'),
    (6, 'Bonucci + Asamoah', 'tuck in to cover behind')
) AS v(so, role, job);

-- 103. pp.222-222
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 10: Defending Against the 4-3-3 - Pressing', 'Outnumber them on the right',
    'Their No.8 pushes up while our right wing back is deep. Pirlo hands the No.8 to the centre back, and the far wing back drops to keep 5 v 4.',
    'No.8 advances while Vidal presses the left back',
    'Let defenders attack their men hard, knowing the extra man is behind.',
    '4-3-3', 222, 222, 1030)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfielder (Vidal)', 'press the left back, then drop to double the winger'),
    (2, 'Second forward (Tevez)', 'drop to double'),
    (3, 'Deep midfielder (Pirlo)', 'mark the No.6 and leave the No.8 to Barzagli'),
    (4, 'Right centre back (Barzagli)', 'step up onto the No.8 while still covering Lichtsteiner'),
    (5, 'Right wing back (Lichtsteiner)', 'attack a ball down the line to the winger without waiting'),
    (6, 'Left wing back (Asamoah)', 'drop into the back line')
) AS v(so, role, job);

-- 104. pp.224-224
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 11: Defending Against the 4-3-1-2 - Starting positions', 'Spare man vs two strikers',
    'Against a 4-3-1-2 the back three is 3 v 2. If the No.10 pushes up, the right wing back drops for 4 v 3. With the ball near a touchline, it is always the far wing back who drops.',
    'No.10 advances, or the ball is near a touchline',
    'Always keep one more defender than their forwards.',
    '4-3-1-2', 224, 224, 1040)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', '3 v 2 against the strikers'),
    (2, 'Right wing back (Lichtsteiner)', 'drop into the back line when the No.10 pushes up and the ball is central'),
    (3, 'Weak-side wing back', 'be the one who drops when the ball is near a touchline')
) AS v(so, role, job);

-- 105. pp.225-225
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 11: Defending Against the 4-3-1-2 - Defending in a Passive Way', 'Close the middle, double the No.10',
    'The block slides left and closes the lanes into the striker and the No.10. That pushes the ball wide, back, or to the dropping No.6.',
    'Centre back has the ball',
    'Stop play through the middle, and double mark it if it gets into the No.10.',
    '4-3-1-2', 225, 225, 1050)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left midfielder + left wing back (Pogba, Asamoah)', 'block the lane into the near striker'),
    (2, 'Second forward (Tevez)', 'cut across to block the lane into the No.10, then double him'),
    (3, 'Deep midfielder (Pirlo)', 'double the No.10'),
    (4, 'Vidal, Pogba, Llorente', 'close in on the ball zone')
) AS v(so, role, job);

-- 106. pp.226-226
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 11: Defending Against the 4-3-1-2 - Defending in a Passive Way', 'Drop behind the ball together',
    'The No.6 plays out to the No.8, who has space and an easy pass to the overlapping full back. The whole team drops together and re-sets.',
    'Pass reaches the No.8 in space',
    'Get eight behind the ball with the forwards tracking, then press the full back from a compact block.',
    '4-3-1-2', 226, 226, 1060)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'drop back together'),
    (2, 'Front two', 'track back and then shift across'),
    (3, 'Right wing back (Lichtsteiner)', 'press the advanced full back, as there is already 4 v 2 behind'),
    (4, 'Midfielders', 'sit just in front of the defenders')
) AS v(so, role, job);

-- 107. pp.227-228
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 11: Defending Against the 4-3-1-2 - Defending passively near the sideline', 'Trap near the touchline v 4-3-1-2',
    'The ball goes out to the right back. The block shifts and stays tight, so whoever receives next (striker, No.7) is surrounded straight away.',
    'Right back gets the ball near the touchline',
    'Double or triple mark the next receiver and win it.',
    '4-3-1-2', 227, 228, 1070)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Chiellini)', 'mark the striker early as he drifts wide, then attack him'),
    (2, 'Deep midfielder (Pirlo)', 'close the striker from the inside'),
    (3, 'Pogba + Asamoah', 'close in on the ball zone'),
    (4, 'Left midfielder (Pogba)', 'step up to block the inside pass to the No.7, or press him with Llorente')
) AS v(so, role, job);

-- 108. pp.229-230
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 11: Defending Against the 4-3-1-2 - Pressing', 'High press, wing back doubles the striker',
    'A high press on the left. The right back is deep, so Pogba is first to press, and Asamoah stays near the defenders. When the striker gets the ball, he is attacked and doubled.',
    'Centre back passes to the right back',
    'Surround the striker while the far wing back keeps numbers behind.',
    '4-3-1-2', 229, 230, 1080)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Llorente)', 'press first, then double the right back and block the pass to the No.6'),
    (2, 'Left midfielder (Pogba)', 'press the right back'),
    (3, 'Deep midfielder (Pirlo)', 'take the No.7 (chain reaction), then help on the striker'),
    (4, 'Left wing back (Asamoah)', 'stay near the defenders to block the through pass; with no man of his own, drop to double the striker'),
    (5, 'Left centre back (Chiellini)', 'attack the striker'),
    (6, 'Right wing back (Lichtsteiner)', 'drop for a spare man behind')
) AS v(so, role, job);

-- 109. pp.231-231
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 11: Defending Against the 4-3-1-2 - Pressing', 'Restore compactness during the pass',
    'The No.7 runs to the touchline and pulls the defenders back, which opens a gap to the midfield. When the ball goes inside, the defenders push up while it travels.',
    'Inside pass to the No.6 after the back line dropped',
    'Close the gap between the lines again so the team is ready to defend.',
    '4-3-1-2', 231, 231, 1090)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Lichtsteiner)', 'drop as weak-side wing back so 3 v 3 becomes 4 v 3'),
    (2, 'Left centre back (Chiellini)', 'take over the No.7 as he goes wide'),
    (3, 'Back line', 'step up together while the pass travels'),
    (4, 'Second forward (Tevez)', 'press the No.6'),
    (5, 'Deep midfielder (Pirlo)', 'move to the No.10, with the other midfielders just behind him')
) AS v(so, role, job);

-- 110. pp.232-232
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 11: Defending Against the 4-3-1-2 - Pressing', 'Two midfielders push up: delay',
    'Both the No.10 and the No.7 move up. Vidal drops toward the defence, and the centre back slows the receiver down instead of diving in.',
    'Two midfielders move into advanced positions',
    'Buy time to restore the extra man, then defend aggressively.',
    '4-3-1-2', 232, 232, 1100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfielder (Vidal)', 'drop toward the back line'),
    (2, 'Left centre back (Chiellini)', 'slow the No.7 and play for time'),
    (3, 'Left wing back (Asamoah)', 'get into support'),
    (4, 'Whole team', 'switch to aggressive pressure once the extra man is back')
) AS v(so, role, job);

-- 111. pp.233-233
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 11: Defending Against the 4-3-1-2 - Pressing', 'Wing back drops when No.10 pushes up',
    'The No.10 moves up and no midfielder follows him, so the far wing back drops into the line. That frees the centre backs to follow their men high.',
    'No.10 moves up behind our midfield unmarked',
    'Keep 3 v 2 behind and win the long balls.',
    '4-3-1-2', 233, 233, 1110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Lichtsteiner)', 'drop into the back line'),
    (2, 'Left centre back (Chiellini)', 'follow the striker high and mark him tight'),
    (3, 'Central centre back (Bonucci)', 'shift to the strong side, take the No.10, and attack long balls into him'),
    (4, 'Left wing back (Asamoah)', 'press the right back'),
    (5, 'Pogba + Llorente', 'support, and drop to narrow the lane to the No.7')
) AS v(so, role, job);

-- 112. pp.234-234
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 11: Defending Against the 4-3-1-2 - Pressing', 'Who presses their left back',
    'In a press on our right, who goes to their left back depends on how high he is and where the No.10 is.',
    'Ball heading to their left back',
    'A clear rule for who presses, so numbers behind stay right.',
    '4-3-1-2', 234, 234, 1120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfielder (Vidal)', 'press the left back when he is deep; also whenever the No.10 sits behind Pirlo'),
    (2, 'Right wing back (Lichtsteiner)', 'press an advanced left back when the No.10 is in front of Pirlo; drop for a back four when the No.10 is behind Pirlo'),
    (3, 'Both wing backs', 'start high when the No.10 is in front of Pirlo')
) AS v(so, role, job);

-- 113. pp.235-235
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-defending'), 'out_of_possession', 'Chapter 11: Defending Against the 4-3-1-2 - Pressing', 'Right-side press, attack the receiver',
    'The No.10 is high and our right wing back is deep and tucked in. On a pass to the left back, Vidal presses, Tevez balances and Pirlo shifts. The next receiver is attacked hard.',
    'Centre back passes to the left back',
    'Win the ball at once or force a poor first touch, with cover behind.',
    '4-3-1-2', 235, 235, 1130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfielder (Vidal)', 'close the left back'),
    (2, 'Second forward (Tevez)', 'drop into a balanced spot covering the back pass and the No.6'),
    (3, 'Deep midfielder (Pirlo)', 'take the No.8, then drop to double the No.11'),
    (4, 'Right centre back (Barzagli)', 'attack the No.11 hard'),
    (5, 'Lichtsteiner + Bonucci', 'tuck in to cover'),
    (6, 'Left wing back (Asamoah)', 'no need to drop deep')
) AS v(so, role, job);

COMMIT;
