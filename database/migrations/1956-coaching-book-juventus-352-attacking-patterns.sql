-- 1956 📚 Coaching book patterns: Terzis, "Coaching the Juventus 3-5-2 -
-- Tactical Analysis and Sessions: Attacking" (SoccerTutor), Conte's Juventus
-- 2013-14.  Every page (1-232) read; each team pattern the book describes
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
    subtitle    = 'Tactical Analysis and Sessions: Attacking',
    author      = 'Athanasios Terzis',
    team        = 'Juventus',
    season      = '2013-14',
    method_note = 'Companion to the defending book: the author watched every Juventus match of Antonio Conte''s 2013-14 season (over 1000 hours), kept a phase of play once it had recurred at least 10 times, logged positions, body shape and movements, drew them in Tactics Manager and built 64 practices. Covers the attacking phase against 3-4-3 (finding the free player, forwards'' and attacking midfielders'' actions, the front two combining centrally and near the sideline, synchronised movements for the AM), then against 3-4-1-2, 3-5-2, 4-4-2, 4-2-3-1, 4-3-1-2 and 4-3-3, the transition to defence (balance kept while attacking, a spare man at the back, per opponent shape) and the transition to attack (direct counter with a long diagonal, indirect counter with a switch).'
WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking');

-- 1. pp.10-10
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'The Attacking Phase - Playing Style', 'Patient build-up from back diamond',
    'The three centre backs plus the holding midfielder form a diamond that usually outnumbers the opposition''s first line; the team builds slowly and pushes players up in stages, wing backs high near the touchlines (one higher than the other), AMs between the lines often acting as a third striker.',
    'Own possession at the back',
    'Arrive with 5-6 attackers and 3-4 in the box for crosses while keeping numbers behind.',
    NULL, 10, 10, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three centre backs + Pirlo', 'Diamond base, numerical edge in first phase'),
    (2, 'Wing backs', 'High and wide; one more advanced than the other'),
    (3, 'Attacking midfielders (Vidal, Marchisio)', 'Move between the lines, take over a striker''s role'),
    (4, 'Front two', 'Occupy centre backs, combine')
) AS v(so, role, job);

-- 2. pp.15-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - Finding the Free Player v 3-4-3', 'Pirlo free in 4v3 first phase',
    'Against a front three the back three plus Pirlo make 4v3; when the opposing forwards stay wide to limit the outside centre backs, through lanes into the middle stay open and Pirlo angles himself into one.',
    'Opposing forwards wide, central lane open',
    'Ball reaches the free holding midfielder with time to play forward.',
    '3-4-3', 15, 16, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Pirlo)', 'Find the open lane at the right angle and show for the pass'),
    (2, 'Central centre back (Bonucci)', 'Play through the gap into Pirlo'),
    (3, 'Outside centre backs (Chiellini, Barzagli)', 'Stay wide to stretch the front three')
) AS v(so, role, job);

-- 3. pp.16-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - Finding the Free Player v 3-4-3', 'Link player bounces ball to Pirlo',
    'When the central forward screens Pirlo, or the front three stay compact so the outside centre backs have time, the ball goes to a centre back then to an AM (or a dropping forward) who steps towards the ball and returns it first time to Pirlo, also when Pirlo hides on the weak side behind the central forward.',
    'Direct pass to Pirlo blocked',
    'Pirlo receives facing play via a third man.',
    '3-4-3', 16, 17, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside centre back (Barzagli)', 'Receive the spare time and pass into the link player'),
    (2, 'Attacking midfielder (Vidal)', 'Drop towards the ball as link player, first-time pass to Pirlo'),
    (3, 'Defensive midfielder (Pirlo)', 'Move away from the screening forward into space to receive')
) AS v(so, role, job);

-- 4. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - Finding the Free Player v 3-4-3', 'Pirlo switches to free far CB',
    'If the weak-side opposing forward leaves his man to jump on Pirlo as soon as a centre back receives, the far-side centre back is left unmarked; Pirlo plays it there first time.',
    'Weak-side forward presses Pirlo',
    'Ball switched to the newly free outside centre back.',
    '3-4-3', 18, 18, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Pirlo)', 'Read the press, one-touch switch'),
    (2, 'Weak-side centre back (Chiellini)', 'Stay open wide to receive')
) AS v(so, role, job);

-- 5. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - Finding the Free Player v 3-4-3', 'Reset via keeper under full press',
    'When all three opposing forwards press aggressively and the man on the ball has no good option, the ball goes back to the goalkeeper and the outside centre backs spread wider.',
    'Front three press man-to-man',
    'Keep possession and restart the build-up with new angles.',
    '3-4-3', 18, 18, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central centre back (Bonucci)', 'Return pass to goalkeeper'),
    (2, 'Goalkeeper (Buffon)', 'Recycle possession'),
    (3, 'Outside centre backs', 'Move wider to offer new options')
) AS v(so, role, job);

-- 6. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - Individual Actions of the Forwards', 'Forward drops then spins in behind',
    'A strong-side forward drops towards the passing lane to a centre back with time; if his marker follows, he turns sharply and runs into the space vacated behind for a long pass.',
    'Defender/Pirlo on ball with time; marker follows the drop',
    'Quick forward runs onto a ball in behind; if the marker stays, the forward receives unmarked and turns.',
    '3-4-3', 22, 22, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side forward (Tevez)', 'Drop to drag marker, then change direction into space behind'),
    (2, 'Passer (Chiellini or Pirlo)', 'Long pass into the vacated space')
) AS v(so, role, job);

-- 7. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - Individual Actions of the Forwards', 'Blind-side run, long pass',
    'As Pirlo carries forward, the weak-side forward runs on the blind side of his marker so the defender cannot watch ball and man; a long pass, usually to the weak-side forward, finds him. A slower target forward instead gets a supporting partner for a lay-off.',
    'Pirlo or a centre back on ball facing forward',
    'Shot from a ball in behind on the defender''s blind side.',
    '3-4-3', 28, 28, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side forward (Quagliarella)', 'Curved run on the defender''s blind side'),
    (2, 'Defensive midfielder (Pirlo) or centre back', 'Long accurate pass into the run'),
    (3, 'Other forward', 'Support for a lay-off if the target is a slower striker')
) AS v(so, role, job);

-- 8. pp.32-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - Individual Actions of the Forwards', 'Unfollowed drop, turn and play',
    'A forward drops between the lines; when his marker does not follow he turns, the partner runs diagonally behind and drags a centre back, opening space for the weak-side AM''s forward run. Also used when a wing back has the ball near the touchline.',
    'Marker does not track the dropping forward',
    'Turn and final ball to the partner or the AM running into the freed space.',
    '3-4-3', 32, 32, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping forward (Llorente)', 'Receive between lines and turn'),
    (2, 'Other forward (Tevez)', 'Diagonal run behind to pull a defender'),
    (3, 'Attacking midfielder (Vidal)', 'Run forward into the space created, best option')
) AS v(so, role, job);

-- 9. pp.34-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - Individual Actions of the Attacking Midfielders', 'AM drifts wide for sideline 2v1',
    'The strong-side AM shifts towards the touchline, which pushes the wing back higher and creates 2v1 near the sideline if the opposing winger has stayed high; the gap to the holding midfielder lets the AM receive and carry forward. If the full back steps out, the wing back is free to cross; if the pass is blocked a forward acts as wall; if defenders drop to the box the AM has time for a final ball.',
    'Opposing winger advanced; AM moves wide',
    'Cross into the box for three runners, or final pass to a diagonal run.',
    '3-4-3', 34, 35, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side AM (Marchisio)', 'Move wide, receive, drive forward'),
    (2, 'Strong-side wing back (Asamoah)', 'Push high, receive free and cross'),
    (3, 'Forward (Llorente)', 'Link player if direct pass to wing back is blocked; diagonal run'),
    (4, 'Weak-side AM (Vidal)', 'Attack space between CB and wing back')
) AS v(so, role, job);

-- 10. pp.39-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - Individual Actions of the Attacking Midfielders', 'AM shift opens weak side',
    'The strong-side AM moves wide; the opposing deep midfielder shifts to cover him, and his partner shifts too, leaving space on the weak side for the other AM, reached via Pirlo.',
    'Opposing midfield slides to strong side',
    'Weak-side AM has time for a final pass to diagonal runs or the wing back high.',
    '3-4-3', 39, 39, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side AM (Marchisio)', 'Shift wide to drag midfielders'),
    (2, 'Defensive midfielder (Pirlo)', 'Switch the ball to the weak-side AM'),
    (3, 'Weak-side AM (Vidal)', 'Receive, carry, pick a runner'),
    (4, 'Forwards', 'Diagonal runs into the box'),
    (5, 'Weak-side wing back (Lichtsteiner)', 'Move up to support, balance kept behind')
) AS v(so, role, job);

-- 11. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - Individual Actions of the Attacking Midfielders', 'AMs receive between the lines',
    'Both AMs sit just behind the opposing midfield line so they can drop to defend or go forward. With Pirlo on the ball centrally, the strong-side AM drops (letting his wing back go high), the weak-side AM runs in between the lines, and the far wing back stays deep for balance.',
    'Pirlo receives centrally',
    'AM between the lines finds through balls to two forwards or the high wing back.',
    '3-4-3', 40, 40, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side AM (Marchisio)', 'Drop to balance and free the wing back'),
    (2, 'Weak-side AM (Vidal)', 'Forward movement to receive between lines, sometimes back to goal then turn'),
    (3, 'Strong-side wing back (Asamoah)', 'Advance high'),
    (4, 'Weak-side wing back (Lichtsteiner)', 'Stay deep for balance'),
    (5, 'Front two', 'Runs in behind the back line')
) AS v(so, role, job);

-- 12. pp.45-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - Individual Actions of the Attacking Midfielders', 'AM runs into weak-side CB-WB gap',
    'After a few passes Pirlo gets space and the weak-side AM, who sits higher than the strong-side one, sprints into the gap between the opposing outside centre back and wing back for a long pass. The strong-side AM stays neutral as a link player.',
    'Pirlo receives in space',
    'AM runs onto a ball in behind and scores.',
    '3-4-3', 45, 45, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side AM (Marchisio)', 'Higher position, forward run into the gap'),
    (2, 'Defensive midfielder (Pirlo)', 'Accurate long pass into space'),
    (3, 'Strong-side AM (Vidal)', 'Medium-depth link player')
) AS v(so, role, job);

-- 13. pp.49-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - Individual Actions of the Attacking Midfielders', 'AM exploits strong-side CB-WB gap',
    'With the strong-side wing back deeper, a pass to the outside centre back pulls the opposing wing back up to mark him, leaving space behind for the AM''s run and cross. If the opposing wing back does not follow, the centre back passes short to the wing back, who waits to be pressed then releases the AM into the space behind. To avoid predictability the weak-side AM can come between the lines instead.',
    'Opposing wing back steps up to our deeper wing back',
    'AM crosses or combines with the front two; box attacked with equal or more numbers.',
    '3-4-3', 49, 53, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side wing back (Lichtsteiner)', 'Stay deeper to bait the opposing wing back'),
    (2, 'Outside centre back (Barzagli)', 'Read wing back''s position; long or short pass'),
    (3, 'Strong-side AM (Vidal)', 'Diagonal run behind the wing back, cross'),
    (4, 'Front two', 'Attack near and far post')
) AS v(so, role, job);

-- 14. pp.55-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - The 2 Forwards Combining in the Centre', 'Target drops, quick forward runs behind',
    'With Pirlo free centrally, the big striker drops and his centre back follows; the quick striker attacks the space left behind for a long pass. If the centre back does not follow, the dropping striker turns unmarked.',
    'Centre back follows the dropping target forward',
    'Quick forward through on goal.',
    '3-4-3', 55, 55, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target forward (Llorente)', 'Drop to drag the centre back'),
    (2, 'Quick forward (Tevez)', 'Diagonal run into the vacated space'),
    (3, 'Defensive midfielder (Pirlo)', 'Long pass into the run')
) AS v(so, role, job);

-- 15. pp.56-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - The 2 Forwards Combining in the Centre', 'Quick forward drops, target lays off',
    'Roles reversed: the quick striker drops to open space, the tall striker moves into it but gets the ball to feet (not in his path, since he lacks pace); the quick striker turns back to collect the lay-off.',
    'Quick forward''s drop opens space; ball to target''s feet',
    'Lay-off then shot or pass to the weak-side AM.',
    '3-4-3', 56, 56, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Quick forward (Tevez)', 'Drop, then reverse direction for the lay-off'),
    (2, 'Target forward (Llorente)', 'Move into space, receive to feet, lay off'),
    (3, 'Defensive midfielder (Pirlo)', 'Pass to the target''s feet'),
    (4, 'Weak-side AM (Vidal)', 'Forward run as an option')
) AS v(so, role, job);

-- 16. pp.62-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - The 2 Forwards Combining in the Centre', 'Drop, one-two, face goal',
    'When the dropping forward is followed but the partner is too far to use the space, the dropping forward plays first time into the advanced partner and spins for the return, receiving between the lines facing goal.',
    'Marker follows the drop; partner too far to run behind',
    'Forward facing goal with an AM and the partner running into the box.',
    '3-4-3', 62, 62, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping forward (Tevez)', 'Receive from Pirlo, first-time pass, move for the return'),
    (2, 'Advanced forward (Llorente)', 'Lay off, then run into the box'),
    (3, 'Strong-side AM (Marchisio)', 'Run into the box')
) AS v(so, role, job);

-- 17. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - The 2 Forwards Combining in the Centre', 'Forwards'' one-two behind high wing back',
    'An outside centre back carries forward; a forward drops and his centre back follows, while the opposing wing back is high. The forward plays first time to his partner and runs into the space behind the centre back; the partner returns it first time for a cross.',
    'Opposing wing back advanced, CB follows the drop',
    'Cross for the target forward and an AM arriving in the box.',
    '3-4-3', 66, 66, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside centre back (Barzagli)', 'Carry forward and feed the dropping forward'),
    (2, 'Dropping forward (Tevez)', 'First-time pass, attack the space behind'),
    (3, 'Other forward (Llorente)', 'First-time return, then run into box'),
    (4, 'AM (Marchisio)', 'Run into the box')
) AS v(so, role, job);

-- 18. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - The 2 Forwards Combining in the Centre', 'Lay-off to supporting forward',
    'One forward sits deeper on the strong side; when the ball goes into the central advanced forward, the deeper one moves to support and receives the lay-off facing goal, with an AM attacking the full back/centre back gap, the wing back high and the target opening up behind.',
    'Pass into the advanced central forward',
    'Forward facing goal picks one of three runners.',
    '3-4-3', 70, 70, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advanced forward (Llorente)', 'Receive and lay off, then spin to open behind'),
    (2, 'Deeper forward (Tevez)', 'Support and receive facing goal'),
    (3, 'AM (Marchisio)', 'Run between full back and centre back'),
    (4, 'Wing back (Asamoah)', 'Width high up the flank')
) AS v(so, role, job);

-- 19. pp.71-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Chapter 1: Juventus in the Attacking Phase - The 2 Forwards Combining in the Centre', 'Forward overloads the central CB',
    'The quick forward moves in front of the target forward so the opposing central centre back has two attackers in his zone; since he usually stays on the target, the quick forward receives unmarked and turns.',
    '2v1 in the central defender''s zone',
    'Forward facing goal with three options (AM gap run, high wing back, target opening behind).',
    '3-4-3', 71, 74, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Quick forward (Tevez)', 'Drop in front of the partner, receive unmarked, turn'),
    (2, 'Target forward (Llorente)', 'Pin the centre back, then open up behind'),
    (3, 'AM (Marchisio)', 'Run between full back and centre back'),
    (4, 'Wing back (Asamoah)', 'Width high')
) AS v(so, role, job);

-- 20. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH1 Attacking Phase: The 2 Forwards Combining Near the Sideline (a) Lay-off to receive between the lines', 'Wide lay-off frees forward between lines',
    'Ball is with the strong-side wing back near the touchline; the deeper forward drops, bounces a first-time ball to the higher forward (or the wing back finds the higher forward directly) and spins to collect the lay-off facing goal.',
    'Wing back receives near sideline with the two forwards close',
    'Deeper forward gets the ball between the lines facing goal with three through-ball choices behind the back line.',
    '3-4-3', 76, 76, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side wing back (Lichtsteiner)', 'feeds a forward from the touchline'),
    (2, 'Deeper forward (Tevez)', 'drops, plays first time, curls round to take the lay-off'),
    (3, 'Advanced forward (Llorente)', 'holds up and lays the ball off'),
    (4, 'Weak-side attacking midfielder / wing back', 'run in behind as through-ball targets')
) AS v(so, role, job);

-- 21. pp.81-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH1 Attacking Phase: The 2 Forwards Combining Near the Sideline (b) Creating then exploiting space in behind', 'Forward drops, marker follows, run behind',
    'Near-side forward drops off to offer to the wing back and the outside centre back tracks him, leaving a hole behind. The ball goes into the dropping forward (or straight to the other forward) and the space vacated by the defender is attacked with a pass from the other forward.',
    'Outside centre back follows the dropping forward',
    'Get a runner into the space behind the stepped-out defender and cross for the forward and weak-side midfielder arriving in the box.',
    '3-4-3', 81, 81, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side wing back (Lichtsteiner)', 'plays into a forward from wide, high position'),
    (2, 'Dropping forward (Tevez)', 'drags the centre back, plays first time or turns and attacks the space behind him'),
    (3, 'Other forward (Llorente)', 'plays the ball into the vacated space or runs into it'),
    (4, 'Weak-side attacking midfielder (Marchisio)', 'arrives in the box for the cross')
) AS v(so, role, job);

-- 22. pp.82-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH1 Attacking Phase: The 2 Forwards Combining Near the Sideline (c) Overload to receive unmarked between the lines', 'Two forwards overload one centre back',
    'When the wing back has the ball wide, one forward goes high while the other steps in front of him, so the outside centre back has two men in his zone. If he stays with the high forward, the other receives unmarked between the lines and turns.',
    'Ball played to the wide wing back; outside centre back sticks with the high forward',
    'Forward turns with 4 v 4 in front, the high forward peels to the touchline, weak-side midfielder runs diagonally into the box and far wing back holds width, giving three passes in behind.',
    '3-4-3', 82, 82, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward stepping short (Tevez)', 'creates 2 v 1 on the centre back, receives and turns'),
    (2, 'High forward (Llorente)', 'pins the centre back then runs toward the sideline'),
    (3, 'Weak-side attacking midfielder (Marchisio)', 'diagonal run into the box'),
    (4, 'Weak-side wing back (Asamoah)', 'keeps width on the far side'),
    (5, 'Strong-side wing back (Lichtsteiner)', 'supplies the ball from wide')
) AS v(so, role, job);

-- 23. pp.84-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH1 Attacking Phase: Synchronised Movements to Create Space for the Attacking Midfielder (a) Weak side', 'Forward drags centre back, weak-side midfielder runs behind',
    'With the holding midfielder free on the ball, the forward drops into the passing lane and his centre back follows; the attacking midfielder on that side bursts forward into the hole and receives a long accurate pass from the regista.',
    'Regista has time and space on the ball; centre back tracks dropping forward',
    'Long pass into the created gap behind the back line for a shot or cross.',
    '3-4-3', 84, 84, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Pirlo)', 'long lofted pass into the created space'),
    (2, 'Forward (Tevez)', 'drops toward the ball to pull his marker out'),
    (3, 'Attacking midfielder (Vidal)', 'times a forward run into the gap'),
    (4, 'Outside centre back (Chiellini)', 'starts the move by finding the regista')
) AS v(so, role, job);

-- 24. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH1 Attacking Phase: Synchronised Movements to Create Space for the Attacking Midfielder (b) Strong side with 3rd man run, variation 1', 'Wing back drops, midfielder third-man run',
    'After a switch to the free outside centre back, the strong-side wing back comes short instead of pushing on and drags the opposing wing back with him. The attacking midfielder sprints into the space behind; the forward drops, takes the centre back''s pass and plays first time into the runner.',
    'Switch reaches the free outside centre back; opposing wing back follows our dropping wing back',
    'Third-man pass puts the attacking midfielder behind the line to cross into the box.',
    '3-4-3', 88, 88, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside centre back (Barzagli)', 'receives the switch, passes into the dropping forward'),
    (2, 'Strong-side wing back (Lichtsteiner)', 'drops short to pull his marker out'),
    (3, 'Strong-side attacking midfielder (Vidal)', 'third-man run behind the opposing wing back, crosses'),
    (4, 'Forward (Tevez)', 'drops and lays first time into the run'),
    (5, 'Other forward / weak-side players', 'attack the box')
) AS v(so, role, job);

-- 25. pp.92-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH1 Attacking Phase: Synchronised Movements to Create Space for the Attacking Midfielder (c) Strong side with 3rd man run, variation 2', 'Centre back stays, dropping forward turns',
    'Same strong-side set-up, but the opposing outside centre back declines to follow the dropping forward and instead picks up the midfielder''s forward run. The forward then receives unmarked and turns to face goal.',
    'Centre back chooses to track the attacking midfielder rather than the forward',
    'Forward turns into a 4 v 3 (or 4 v 4 if the far wing back recovers) with options in behind; players read which defender reacts and act accordingly.',
    '3-4-3', 92, 92, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Tevez)', 'drops, finds himself free, turns and plays through'),
    (2, 'Strong-side attacking midfielder (Vidal)', 'runs forward to draw the centre back'),
    (3, 'Outside centre back (Barzagli)', 'feeds the forward'),
    (4, 'Other forward and weak-side midfielder', 'runs to give three passing options')
) AS v(so, role, job);

-- 26. pp.94-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH2 Attacking Against the 3-4-1-2: Finding the free player when building up from the back', 'Spare man in build-up via link player',
    'Against two forwards plus a number 10 on the regista, the three centre backs and Pirlo outnumber them (3 v 2 / 4 v 3). The ball is moved to whichever back is unmarked; if the direct pass is cut, a link player (regista, goalkeeper, or an attacking midfielder or forward dropping) relays it.',
    'Opponent''s front three press, one of our backs is left free',
    'Free player gets time to carry forward or play an accurate forward pass.',
    '3-4-1-2', 94, 97, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free outside centre back (Barzagli)', 'receives with time, carries or passes forward'),
    (2, 'Defensive midfielder (Pirlo)', 'link player when not marked; becomes the free man if the 10 presses up'),
    (3, 'Goalkeeper (Buffon)', 'link player when Pirlo is on the wrong side'),
    (4, 'Strong-side attacking midfielder (Marchisio / Vidal)', 'drops to become the link player'),
    (5, 'Central centre back (Bonucci)', 'circulates; if pressed, finds the link')
) AS v(so, role, job);

-- 27. pp.100-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH2 Attacking Against the 3-4-1-2: Creating a numerical advantage near the sideline', 'Centre back carries into wide overload',
    'Their two holding midfielders cannot cover the full width, so the free outside centre back dribbles forward to create 4 v 3 by the touchline. When a holding midfielder steps out to him, the attacking midfielder drifts wide as the free man and the wing back pushes higher, pinning the opposing wing back.',
    'Spare centre back has space to carry; opposition midfielder steps to press him',
    'Free attacking midfielder receives facing forward near the sideline; if the near side gets crowded, switch to the weak side.',
    '3-4-1-2', 100, 100, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside centre back (Chiellini)', 'carries forward to draw a midfielder'),
    (2, 'Strong-side attacking midfielder (Marchisio)', 'slides toward the touchline as the free man'),
    (3, 'Strong-side wing back (Asamoah)', 'advances to pin the opposing wing back'),
    (4, 'Forwards', 'stay central to occupy the back three')
) AS v(so, role, job);

-- 28. pp.101-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH2 Attacking Against the 3-4-1-2: Taking advantage of the numerical advantage on the flank', 'Exploiting the 2 v 1 on the flank',
    'Attacking midfielder drives on with the ball and the opposing wing back steps up, leaving 2 v 1 with our wing back. Pass outside for a cross; if the wing back''s pass is screened, the near forward comes across as a link; if the outside centre back covers the overlap, the forward he left turns free.',
    'Opposing wing back steps out to the ball carrier',
    'Cross for three runners into the box, or a forward turning free with through-ball options to the other forward and far midfielder.',
    '3-4-1-2', 101, 101, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side attacking midfielder (Marchisio)', 'carries and chooses the release'),
    (2, 'Strong-side wing back (Asamoah)', 'overlaps and crosses'),
    (3, 'Near forward (Llorente)', 'offers as link, or turns if his centre back leaves'),
    (4, 'Other forward (Tevez) and far midfielder (Vidal)', 'runs into the box / in behind')
) AS v(so, role, job);

-- 29. pp.102-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH2 Attacking Against the 3-4-1-2: The opposition drop back collectively', 'Carry on when defence drops off',
    'If their defenders retreat together to avoid being outnumbered wide, the attacking midfielder keeps carrying. He then finds the far attacking midfielder attacking the gap between centre back and wing back, or a forward''s diagonal run, a low cross, or shoots.',
    'Opposition back line drops deeper instead of stepping out',
    'Final pass behind the defence from a carrier with time.',
    '3-4-1-2', 102, 102, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side attacking midfielder (Marchisio)', 'dribbles forward, picks the pass or shoots'),
    (2, 'Far attacking midfielder (Vidal)', 'runs into the centre back to wing back channel'),
    (3, 'Near forward (Llorente)', 'diagonal run to stretch and open space'),
    (4, 'Other forward (Tevez)', 'target for the killer pass'),
    (5, 'Wing backs', 'push high to keep the line stretched')
) AS v(so, role, job);

-- 30. pp.103-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH2 Attacking Against the 3-4-1-2: Creating an overload between the lines', 'Midfielder between the lines in centre back''s zone',
    'Attacking midfielder stands between the lines inside the outside centre back''s zone while that defender is busy with the near forward. After a couple of passes he receives unmarked and turns, since the defender stays with the forward and the holding midfielder is too far.',
    'Outside centre back occupied by forward; midfielder unmarked in his zone',
    'Midfielder turns and carries; forward drifts wide into free space, other forward runs diagonal, far midfielder attacks the CB-WB gap: three options in behind.',
    '3-4-1-2', 103, 103, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side attacking midfielder (Marchisio)', 'receives between lines, turns, drives on'),
    (2, 'Near forward (Llorente)', 'pins the centre back, then moves into the open flank'),
    (3, 'Other forward (Tevez)', 'diagonal run for the killer pass'),
    (4, 'Far attacking midfielder (Vidal)', 'attacks the space between centre back and wing back')
) AS v(so, role, job);

-- 31. pp.104-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH2 Attacking Against the 3-4-1-2: Numerical advantage with a diagonal run behind the wing back', 'Midfielder runs behind wing back',
    'When the opponent stays compact and presses the carrying centre back, the attacking midfielder runs diagonally toward the touchline behind their wing back to form a 2 v 1 and receive to cross. If the outside centre back tracks him, the centre forward is briefly left free.',
    'Compact opponent pressing the ball-carrying centre back',
    'Either a cross from behind the wing back, or the freed forward turns and slips Tevez or Vidal through.',
    '3-4-1-2', 104, 104, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side attacking midfielder (Marchisio)', 'diagonal run toward the sideline behind the wing back'),
    (2, 'Outside centre back (Chiellini)', 'carries under pressure and releases'),
    (3, 'Strong-side wing back (Asamoah)', 'feeds the freed forward'),
    (4, 'Centre forward (Llorente)', 'receives free when his marker follows the run, turns and plays final pass'),
    (5, 'Tevez / Vidal', 'runs in behind')
) AS v(so, role, job);

-- 32. pp.109-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH2 Attacking Against the 3-4-1-2: Switching play into the available space - weak side', 'Switch to the free weak-side midfielder',
    'If the opponent stays compact and presses the ball side, the ball is switched quickly to the weak-side attacking midfielder, who has lots of room. Same result can come with the near-side attacking midfielder dropping to receive and then switching.',
    'Ball-side compressed and carrier under pressure',
    'Weak-side midfielder carries forward; both forwards and the other midfielder run for the final pass while the wing back overlaps to stretch or take the ball.',
    '3-4-1-2', 109, 110, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside centre back (Chiellini)', 'long diagonal to the weak side'),
    (2, 'Weak-side attacking midfielder (Vidal)', 'receives in space and drives on'),
    (3, 'Near attacking midfielder (Marchisio)', 'alternative relay by dropping, then runs into box'),
    (4, 'Forwards (Llorente, Tevez)', 'move for the final pass'),
    (5, 'Weak-side wing back (Lichtsteiner)', 'supporting run outside')
) AS v(so, role, job);

-- 33. pp.110-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH2 Attacking Against the 3-4-1-2: Creating and exploiting space on the strong side', 'Midfielder''s run drags holder, others fill',
    'When the opponent keeps a spare man at the back, the attacking midfielder runs into the gap between outside centre back and wing back; the tracking holding midfielder opens space behind him. That space is used by the wing back cutting inside, by the midfielder checking back and turning, or by the outside centre back stepping in while the weak-side forward drops and the far midfielder runs in.',
    'Opponent holder follows the attacking midfielder''s run',
    'Ball carrier arrives in the freed zone with three passes behind the line, or a diagonal into the box for the far midfielder.',
    '3-4-1-2', 110, 111, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side attacking midfielder (Vidal)', 'run into the CB-WB gap, or checks back and turns'),
    (2, 'Strong-side wing back (Lichtsteiner)', 'moves inside on the run into freed space'),
    (3, 'Outside centre back (Barzagli)', 'steps into the space and plays a diagonal into the box'),
    (4, 'Weak-side forward (Llorente)', 'drops to pull his marker'),
    (5, 'Weak-side attacking midfielder (Marchisio)', 'runs into the box to finish')
) AS v(so, role, job);

-- 34. pp.113-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH3 Attacking Against the 3-5-2: Numerical advantage at the back', '4 v 2 build-up versus two forwards',
    'Against two forwards Juve''s three centre backs plus Pirlo make 4 v 2. Whoever their wide forward ignores is free: the outside centre back if the forward screens Pirlo, Pirlo if he stays wide, and when the carrier is pressed and the return blocked, an attacking midfielder drops as a link to reach Pirlo.',
    'Two opposition forwards press our build-up',
    'Get the ball to the free back or regista with space to move up.',
    '3-5-2', 113, 114, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside centre back (Chiellini)', 'free when the forward tucks in; runs into space'),
    (2, 'Defensive midfielder (Pirlo)', 'free when the forward stays wide'),
    (3, 'Central centre back (Bonucci)', 'finds the free man'),
    (4, 'Attacking midfielder (Marchisio)', 'drops as link when direct lines are shut')
) AS v(so, role, job);

-- 35. pp.115-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH3 Attacking Against the 3-5-2: Space near the sideline when the ball is central', 'Midfielders slide wide to flank 2 v 1',
    'Their compact midfield three and back three close the middle, so with Pirlo carrying centrally the attacking midfielders shift to the touchline, the wing backs push on and the outside centre backs step forward. A 2 v 1 forms on the flank before their outside midfielder can close.',
    'Opposition midfield compact in front of its back line; Pirlo on the ball centrally',
    'Midfielder releases the wing back to cross, uses a forward as link if blocked, or if closed in an open-ball moment the teammates run for a final pass (forwards'' diagonals, midfielder into box, or switch to far wing back).',
    '3-5-2', 115, 117, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Pirlo)', 'carries forward and finds the wide midfielder'),
    (2, 'Attacking midfielders (Vidal, Marchisio)', 'drift to the sideline for space'),
    (3, 'Wing backs (Lichtsteiner, Asamoah)', 'push high; receive to cross'),
    (4, 'Forward (Tevez)', 'link when the wide pass is blocked; diagonal stretching runs'),
    (5, 'Llorente / far midfielder', 'runs into the box')
) AS v(so, role, job);

-- 36. pp.115-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH3 Attacking Against the 3-5-2: Centre back moving forward and switch to weak side', 'Outside centre back steps into wide space',
    'If an outside centre back has space he carries forward to make 4 v 3 near the sideline and uses the Chapter 1 combinations; if the opponent shifts across and evens numbers, Pirlo switches to the weak-side midfielder. When the attacking midfielder sits central, the outside centre back himself exploits the wide space.',
    'Free outside centre back with room ahead; opponent overshifts',
    '4 v 3 wide; midfielder in front of the forward makes 2 v 1, forward''s diagonal drags his centre back and frees the midfielder for the final pass.',
    '3-5-2', 115, 119, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside centre back (Barzagli / Chiellini)', 'carries forward into the flank space'),
    (2, 'Attacking midfielder (Vidal)', 'steps in front of the forward to overload; receives in dragged space'),
    (3, 'Forward (Tevez)', 'diagonal run pulling the centre back, or runs in behind for a ball down the line'),
    (4, 'Wing back (Lichtsteiner)', 'passes inside or down the line'),
    (5, 'Pirlo', 'switches to the free weak side')
) AS v(so, role, job);

-- 37. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH3 Attacking Against the 3-5-2: Using Pirlo vs teams reacting to him - CB/WB gap', 'Long ball into CB-wing back gap',
    'When the opponent leaves Pirlo free and their midfield three stay tight to the back line, the attacking midfielders run into the gap between outside centre back and wing back for his long pass, while our wing backs hold deeper for balance.',
    'Opponent defends reactively, letting Pirlo receive with time',
    'Exploit Pirlo''s long-pass accuracy into space beside the back three.',
    '3-5-2', 120, 120, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Pirlo)', 'long pass into the channel'),
    (2, 'Attacking midfielders (Vidal, Marchisio)', 'run into the centre back to wing back gap'),
    (3, 'Wing backs', 'stay deep to keep balance'),
    (4, 'Forwards', 'hold the back line')
) AS v(so, role, job);

-- 38. pp.121-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH3 Attacking Against the 3-5-2: Using Pirlo vs teams reacting to him - flanks', 'Pirlo finds advancing wing backs',
    'If their wing backs tuck in to narrow the space, Pirlo plays out to our wing backs running high on the flank, while the attacking midfielders stay deeper to secure rest defence for losing the ball.',
    'Opposition wing backs converge to the middle; Pirlo free',
    'Wing back crosses; when their wing back steps out it becomes 4 v 4 or 4 v 3 in the box with two forwards and two midfielders arriving.',
    '3-5-2', 121, 121, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Pirlo)', 'long diagonal to the advancing wing back'),
    (2, 'Wing backs (Asamoah, Lichtsteiner)', 'push on high and wide, cross'),
    (3, 'Attacking midfielders', 'start deep for balance, then join the box'),
    (4, 'Forwards', 'attack the box')
) AS v(so, role, job);

-- 39. pp.122-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH3 Attacking Against the 3-5-2: Space between the lines vs teams pressing Pirlo', 'Pressed regista opens space between lines',
    'When the opponent marks or presses Pirlo early, the gap between their midfield and defence opens. The outside centre back steps forward and plays into a forward between the lines, who combines with his partner for a pass in behind.',
    'Opposition midfielder jumps to Pirlo (pro-active)',
    'Bypass the pressed regista and attack the space between lines with the two forwards combining.',
    '3-5-2', 122, 122, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside centre back (Barzagli)', 'carries forward and passes into the forward between the lines'),
    (2, 'Central centre back (Bonucci)', 'goes round Pirlo to the outside centre back'),
    (3, 'Defensive midfielder (Pirlo)', 'draws the press away'),
    (4, 'Forwards (Tevez, Llorente)', 'receive between lines and combine for the final ball')
) AS v(so, role, job);

-- 40. pp.124-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH4 Attacking Against the 4-4-2: Numerical advantage at the back', '4 v 2 build-up against 4-4-2',
    'Against two forwards Juve again have three centre backs and Pirlo in a 4 v 2, though the wide midfielders restrict space for the outside centre backs. Same build-up rules as versus the 3-5-2 apply.',
    'Two opposition forwards press build-up',
    'Free back or regista gets the ball to start attacks.',
    '4-4-2', 124, 124, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Chiellini, Bonucci, Barzagli)', 'circulate to find the free man'),
    (2, 'Defensive midfielder (Pirlo)', 'free option in the centre'),
    (3, 'Wide centre backs', 'watch for the opposition wide midfielder closing')
) AS v(so, role, job);

-- 41. pp.126-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH4 Attacking Against the 4-4-2: Creating a numerical advantage near the sideline - AM drops', 'Attacking midfielder drops wide behind wide mid',
    'Outside centre back carries; their wide midfielder closes him, so the attacking midfielder slides to the touchline behind that player and our wing back pushes on, making 2 v 1 against the full back. Move fast before the wide midfielder recovers.',
    'Opposition wide midfielder steps up to the carrying centre back',
    'Wing back crosses; if full back blocks, forward links; if a centre back covers the wing back, the forward turns free; if no one steps out the midfielder carries on with four options including a switch to the far wing back.',
    '4-4-2', 126, 127, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside centre back (Chiellini)', 'carries and passes to the dropped midfielder'),
    (2, 'Strong-side attacking midfielder (Marchisio)', 'moves wide behind the wide midfielder, picks the release'),
    (3, 'Strong-side wing back (Asamoah)', 'advances, crosses'),
    (4, 'Near forward (Llorente)', 'link or turns free; diagonal run'),
    (5, 'Tevez / Vidal', 'near and far post runs'),
    (6, 'Far wing back (Lichtsteiner)', 'high on the far side for a switch')
) AS v(so, role, job);

-- 42. pp.132-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'CH4 Attacking Against the 4-4-2: Exploiting space behind the full back', 'Midfielder runs into gap behind full back',
    'When the full back to centre back gap is big, or the full back steps up to mark our wing back, the attacking midfielder runs into the space behind. The outside centre back plays it in (first phase) or the wing back between the lines does once the full back closes him (second phase).',
    'Opposition full back steps to our wing back or leaves a gap to his centre back',
    'Midfielder receives behind and crosses, giving 3 v 2 or even 3 v 3 / 2 v 3 in the box.',
    '4-4-2', 132, 136, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side attacking midfielder (Marchisio)', 'runs into the space behind the full back, crosses'),
    (2, 'Strong-side wing back (Asamoah)', 'pins / draws the full back, passes in'),
    (3, 'Outside centre back (Chiellini)', 'reads which way to play: in behind or to the wing back'),
    (4, 'Forwards and far midfielder', 'attack near and far post')
) AS v(so, role, job);

-- 43. pp.137-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch4 v 4-4-2: The Forward Exploits the Space Behind the Full Back', 'Forward attacks space behind full back',
    'When the strong-side attacking midfielder is too deep to run into the space behind an advanced full back, the near forward takes over that run and a wide centre back hits it long.',
    'Opposing full back steps up, AM too deep',
    'Get a forward in behind on the flank; a quick forward goes 1v1 and crosses, a target forward is supported by wing back and AM runs.',
    '4-4-2', 137, 137, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Chiellini)', 'long ball into the channel behind the full back'),
    (2, 'Strong-side forward (Llorente / Tevez)', 'run wide into the space; quick one beats his man 1v1 and crosses'),
    (3, 'Strong-side wing back (Asamoah)', 'supporting run outside when the target forward receives'),
    (4, 'Strong-side AM', 'support run; with a quick forward on the ball, AM and other forward attack the box for a 2v2')
) AS v(so, role, job);

-- 44. pp.139-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch4 v 4-4-2: Individual Actions of the Forwards', 'Forward drops, then spins into vacated space',
    'A forward drops into the open lane toward a wide centre back; his marking centre back follows, so the forward checks back and runs into the hole left behind.',
    'Opposing CB follows the forward''s drop',
    'Receive a long pass behind the line unmarked and turn on goal.',
    '4-4-2', 139, 139, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side forward (Tevez)', 'drop toward the ball, then sharp change of direction into the created space'),
    (2, 'Left centre back (Chiellini)', 'long pass into the space the CB vacated'),
    (3, 'Pirlo', 'when he is on the ball the release pass is more accurate')
) AS v(so, role, job);

-- 45. pp.140-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch4 v 4-4-2: Individual Actions of the Forwards', 'Blind-side run off centre back',
    'With Pirlo carrying the ball in the centre, a quick forward slides onto the blind shoulder of a centre back so the defender cannot watch ball and man together.',
    'Pirlo on the ball facing forward with time',
    'Pirlo''s long pass finds the runner inside the box.',
    '4-4-2', 140, 140, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pirlo (DM)', 'carry forward, then accurate long pass over the line'),
    (2, 'Quick forward (Quagliarella / Tevez / Giovinco)', 'drift to the blind side of the CB and run in behind')
) AS v(so, role, job);

-- 46. pp.140-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch4 v 4-4-2: Individual Actions of the Forwards', 'Forward drops between lines and turns',
    'A forward drops between the lines; if his centre back does not follow, he receives from Pirlo, turns and plays the runners: a diagonal by the other forward, or the AM into space if that forward''s marker follows.',
    'Direct marker does not track the drop',
    'Turn facing goal with options behind the back four.',
    '4-4-2', 140, 140, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pirlo', 'feed the dropping forward after circulation'),
    (2, 'Dropping forward (Llorente)', 'receive, turn, pick the run'),
    (3, 'Other forward (Tevez)', 'diagonal run behind'),
    (4, 'Weak/strong AM (Vidal)', 'run into space opened when Tevez''s marker follows him (best option)'),
    (5, 'Wing back', 'same drop-and-turn also used when a wing back has the ball near the sideline')
) AS v(so, role, job);

-- 47. pp.142-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch4 v 4-4-2: Individual Actions of the Attacking Midfielder', 'AM drops off between the lines',
    'An AM already beyond the opposing midfield drops a few yards to offer a lane for Pirlo; the full back will not step in because that would open the flank for our wing back.',
    'Pirlo receives centrally after build-up',
    'AM receives unmarked, turns and has several passes behind the back line.',
    '4-4-2', 142, 142, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pirlo', 'receive from the centre back, find the AM'),
    (2, 'AM (Vidal)', 'short drop into pocket, receive and turn'),
    (3, 'Wing back (Lichtsteiner)', 'stays high and wide, pinning the full back'),
    (4, 'Front two', 'offer runs behind')
) AS v(so, role, job);

-- 48. pp.142-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch4 v 4-4-2: Individual Actions of the Attacking Midfielder', 'AM runs into weak-side CB-FB gap',
    'When Pirlo has time centrally and a gap opens between the far full back and centre back, the weak-side AM bursts forward into it.',
    'Pirlo unmarked with time, weak-side gap visible',
    'Long pass from Pirlo puts the AM through to shoot.',
    '4-4-2', 142, 142, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pirlo', 'accurate long pass into the AM''s path'),
    (2, 'Weak-side AM (Marchisio)', 'forward run between full back and centre back')
) AS v(so, role, job);

-- 49. pp.144-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch4 v 4-4-2: Attacking in the Centre - a) The 2 Forwards Combining in the Centre', 'Target drops, quick forward runs behind',
    'The stronger, taller forward comes short into the open lane and drags his centre back; the quicker forward runs diagonally into the vacated space for a long ball from a wide centre back.',
    'Open ball (carrier unpressed) and CB follows the drop',
    'Quick forward through on goal; if the CB stays, the dropping forward turns instead.',
    '4-4-2', 144, 144, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target forward (Llorente)', 'drop toward the ball to pull the CB out'),
    (2, 'Quick forward (Giovinco)', 'diagonal run into the created space'),
    (3, 'Wide CB (Chiellini)', 'carry, then long pass')
) AS v(so, role, job);

-- 50. pp.144-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch4 v 4-4-2: Attacking in the Centre - a) The 2 Forwards Combining in the Centre', 'Lay-off to the spinning forward',
    'Roles reversed: the quick forward drops and pulls his CB, the target forward moves into that gap and receives to feet; he lays off first time to the quick forward who has spun into the space the target vacated, or the AM drops, gets the lay-off and has passes behind.',
    'Ball to a wide CB or Pirlo with a forward/AM coming short and being followed',
    'Third player receives facing goal with up to 3 options behind the line.',
    '4-4-2', 144, 146, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Quick forward (Quagliarella / Tevez)', 'drop to pull the CB, then change direction to collect the lay-off'),
    (2, 'Target forward (Llorente)', 'receive to feet, first-time lay-off'),
    (3, 'Feeder (Pirlo / Barzagli)', 'pass into the target forward'),
    (4, 'Full back', 'if he refuses to follow a dropping player (to protect the wing back''s space) the narrow lane goes to the target man')
) AS v(so, role, job);

-- 51. pp.145-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch4 v 4-4-2: Attacking in the Centre - a) The 2 Forwards Combining in the Centre', 'Central one-two behind an advanced full back',
    'After a switch, a forward drops for a first-time wall pass from his partner; his CB follows and the nearby full back is too high to cover, so the forward spins into the space and receives back.',
    'Switch of play, opposing full back advanced on our wing back',
    'Forward through behind; AM and partner attack the box for a cross.',
    '4-4-2', 145, 145, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right CB (Barzagli)', 'receive the switch, step in and find the dropping forward'),
    (2, 'Dropping forward (Tevez)', 'first-time pass to partner, spin into created space'),
    (3, 'Partner forward (Llorente)', 'return pass, then run into the box'),
    (4, 'AM (Marchisio)', 'run into the box for the cross')
) AS v(so, role, job);

-- 52. pp.146-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch4 v 4-4-2: Attacking in the Centre - a) The 2 Forwards Combining in the Centre', 'Overload one centre back between lines',
    'A second forward/AM steps into the zone in front of the partner, putting two attackers in one CB''s zone; the CB stays with the deeper striker so the newcomer receives and turns.',
    'Ball wide with the wing back advanced, two attackers in one CB zone',
    'Receive unmarked facing goal, create 4v3 and pick passes behind the line.',
    '4-4-2', 146, 147, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Overloading player (Tevez / Quagliarella)', 'move in front of the partner into the same CB zone'),
    (2, 'Pinned forward (Llorente)', 'hold the CB'),
    (3, 'Wing back (Lichtsteiner)', 'pass in from the advanced wide spot, then run forward'),
    (4, 'AM (Vidal / Marchisio)', 'forward runs; one moves up into a forward''s position')
) AS v(so, role, job);

-- 53. pp.148-148
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch4 v 4-4-2: Attacking in the Centre - b) Attacking Midfielder and Forward Combining in the Centre', 'Forward drops, AM runs weak side',
    'When Pirlo is free centrally, a forward drops and drags his CB; the other forward is too far away, so the weak-side AM runs into the created space.',
    'Pirlo free in centre, CB follows the dropping forward',
    'Pirlo''s long pass finds the AM unmarked behind to shoot.',
    '4-4-2', 148, 148, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pirlo', 'carry forward, long pass into the gap'),
    (2, 'Dropping forward (Tevez)', 'come short to pull the CB'),
    (3, 'AM (Vidal)', 'forward run into the space')
) AS v(so, role, job);

-- 54. pp.148-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch4 v 4-4-2: Attacking in the Centre - b) Attacking Midfielder and Forward Combining in the Centre', 'Third-man run behind advanced full back',
    'After a switch to the free CB, the AM runs behind a full back who has pushed onto our wing back; the direct pass is blocked, so a forward drops as link and plays first time into the AM''s run.',
    'Opposing full back advanced to control our wing back, direct pass to AM blocked',
    'AM receives deep in the channel and crosses; if the CB stays with the AM, the link forward turns.',
    '4-4-2', 148, 151, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free CB (Barzagli)', 'pass into the dropping forward, not the AM'),
    (2, 'Link forward (Tevez / Llorente)', 'drop, first-time pass into the run'),
    (3, 'AM (Vidal)', 'run behind the full back, cross into the box'),
    (4, 'Wing back (Lichtsteiner)', 'hold wide position that drew the full back up')
) AS v(so, role, job);

-- 55. pp.150-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch4 v 4-4-2: Attacking Near the Sideline', 'Sideline one-two behind full back',
    'Wing back holds the ball high near the sideline and the full back steps to him; a forward drops, his CB follows, and the forward plays a one-two with his partner to run into the hole behind.',
    'Wing back in advanced position, full back pushed up, CB follows dropping forward',
    'Forward collects behind the line and crosses for the partner and AM.',
    '4-4-2', 150, 150, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back (Lichtsteiner)', 'receive high, pass into the dropping forward'),
    (2, 'Dropping forward (Tevez)', '1-2 then attack the created space'),
    (3, 'Other forward (Llorente)', 'return pass first time, then attack box'),
    (4, 'AM (Marchisio)', 'run into the box')
) AS v(so, role, job);

-- 56. pp.153-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch5: Advantages of the 3-5-2 Against the 4-2-3-1', 'Wide CBs exploit 4v2 at the back',
    'Against a 4-2-3-1 focused on screening Pirlo, the wingers stay deep and only two attackers are high, so Juve have 4v2 and the outside CBs are free.',
    'Opposition sits on Pirlo, wingers stay deep',
    'Wide centre backs receive and carry forward easily.',
    '4-2-3-1', 153, 153, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pirlo', 'attracts the pressure / screening'),
    (2, 'Left/right CBs (Chiellini, Barzagli)', 'receive and step forward with the ball'),
    (3, 'Bonucci', 'circulate to the free wide CB')
) AS v(so, role, job);

-- 57. pp.153-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch5: Advantages of the 3-5-2 Against the 4-2-3-1', 'Wing backs free when wingers press',
    'If the 4-2-3-1 wingers push up onto the wide CBs to make it 4v4, our wing backs are left unmarked out wide; the WB stands between winger and full back for a 2v1.',
    'Wingers move up to contest our wide CBs',
    'Wing back receives with time; with the AM a 2v1 near the sideline.',
    '4-2-3-1', 153, 155, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing back (Asamoah)', 'position between winger and full back, receive and play forward'),
    (2, 'Wide CB (Chiellini)', 'pass to the wing back when the winger steps'),
    (3, 'AM (Marchisio)', 'diagonal run behind the full back, or link player if the direct pass is blocked'),
    (4, 'Target forward (Llorente)', 'come toward the space to receive up the line, hold it with back to goal')
) AS v(so, role, job);

-- 58. pp.154-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch5: Advantages of the 3-5-2 Against the 4-2-3-1', 'Attack space behind the full back',
    'If the full back pushes up to mark our wing back, the space behind him is hit by an AM diagonal run or, if the AM is too deep, by the strong-side forward; a quick forward beats his man 1v1 and crosses.',
    'Opposing full back advances to mark the wing back',
    'Get in behind on the flank and cross; finish depends on who arrives.',
    '4-2-3-1', 154, 156, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide CB (Chiellini)', 'long pass into the space'),
    (2, 'AM (Marchisio)', 'diagonal run behind the full back'),
    (3, 'Strong-side forward (Giovinco/Quagliarella/Tevez)', 'take the run when the AM is deep; dribble past the uncovered CB and cross')
) AS v(so, role, job);

-- 59. pp.155-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch5: Advantages of the 3-5-2 Against the 4-2-3-1', 'Wing back overlaps after forward hold-up',
    'Target forward receives up the line in the stretched channel but cannot dribble, so he holds it; the wing back keeps running and takes the return pass with passes behind the line.',
    'Forward receives with back to goal in the channel',
    'Wing back arrives with three options behind; the cut-back to the second forward is the easiest goal.',
    '4-2-3-1', 155, 155, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target forward (Llorente)', 'shield, lay off to the overlapping wing back'),
    (2, 'Wing back (Asamoah)', 'continue run, receive, pick option'),
    (3, 'Second forward (Tevez)', 'arrive centrally for the pass')
) AS v(so, role, job);

-- 60. pp.157-157
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch5: Advantages of the 3-5-2 Against the 4-2-3-1', 'Wide CBs carry v compact block',
    'When the 4-2-3-1 shrinks into a compact 4-4-1-1 to choke Pirlo, the space between the lines disappears but the wide CBs have room to carry forward and pass; if it becomes a compact 4-4-2 with a forward shading wide, use the 4-4-2 solutions.',
    'Opponent compacts the centre around Pirlo',
    'Wide centre backs advance into the free lanes and break lines from there.',
    '4-2-3-1', 157, 157, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide CBs (Chiellini, Barzagli)', 'carry into the open space and pass forward'),
    (2, 'Pirlo', 'draws the block centrally'),
    (3, 'AM (Marchisio)', 'if deep, the opposing forward drifts wide to cut Chiellini''s space - switch to 4-4-2 patterns')
) AS v(so, role, job);

-- 61. pp.159-159
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch6: Advantages of the 3-5-2 Against the 4-3-1-2', '4v3 build-up and wing-back time',
    'Against a 4-3-1-2, Juve have 4v3 at the back to build to the free player, and the wing backs get time because the three central midfielders sit narrow; if a full back jumps the wing back, AM or strong-side forward attacks behind him.',
    'Opponent''s midfield three narrow, front three vs our back four',
    'Build cleanly through the free man and use wide time.',
    '4-3-1-2', 159, 159, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three + Pirlo', '4v3: pass to the free player (as v 3-4-1-2)'),
    (2, 'Wing backs (Asamoah, Lichtsteiner)', 'receive with time out wide'),
    (3, 'AM (Marchisio) / strong-side forward (Llorente)', 'run behind a full back who pushes onto the wing back')
) AS v(so, role, job);

-- 62. pp.160-160
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch6: Advantages of the 3-5-2 Against the 4-3-1-2', 'Switch to the weak side for 2v1',
    'If the 4-3-1-2 presses the ball near the sideline, the weak side opens; Marchisio drops to receive and switches to Vidal who also drops, giving 2v1 on the far flank, and Vidal releases the wing back before the shuttling midfielder arrives.',
    'Opposition pressure near the sideline with Pirlo marked',
    'Wing back free high on the far side, full back dragged across, 2v2 in the box.',
    '4-3-1-2', 160, 160, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side AM (Marchisio)', 'drop, receive and switch'),
    (2, 'Weak-side AM (Vidal)', 'drop to receive, carry, release the wing back'),
    (3, 'Weak-side wing back (Lichtsteiner)', 'receive with space ahead; full back is pinned central to keep the line'),
    (4, 'Front two', 'attack the box for a 2v2')
) AS v(so, role, job);

-- 63. pp.162-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch7: Advantages of the 3-5-2 Against the 4-3-3', 'Find free Pirlo, else the wing backs',
    'Against a 4-3-3 the back three have 4v3 including Pirlo who is left free; the key is to get the ball to him; when that is hard, play to the wing backs who have time because the opposing midfield three sit narrow.',
    'Three forwards press our back three, Pirlo free',
    'Build through Pirlo or the free wing backs.',
    '4-3-3', 162, 162, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'circulate to find Pirlo'),
    (2, 'Pirlo', 'free player, key receiver'),
    (3, 'Wing backs', 'second option out wide with time')
) AS v(so, role, job);

-- 64. pp.162-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch7: Advantages of the 3-5-2 Against the 4-3-3', 'CB steps up, wing back gets time',
    'When a wide CB carries into an advanced spot, the wing back on that side has time and space; if the full back comes forward to close him, the AM or strong-side forward runs behind.',
    'Wide CB advances with the ball',
    'Free wing back or run behind an advanced full back.',
    '4-3-3', 162, 162, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide CB', 'advance with the ball'),
    (2, 'Wing back (Asamoah)', 'receive with time'),
    (3, 'AM (Marchisio) / forward (Llorente)', 'exploit space behind a pushed full back')
) AS v(so, role, job);

-- 65. pp.163-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'in_possession', 'Ch7: Advantages of the 3-5-2 Against the 4-3-3', 'Switch past a shifted midfield three',
    'The 4-3-3 midfield three slides toward the ball, leaving the weak side open; Vidal drops to take Pirlo''s long switch while Lichtsteiner pushes on for a 2v1, then crosses for three runners while the rest keep a numerical edge at the back.',
    'Opponent midfield three shifted to the strong side',
    'Wing back crosses from high on the flank into a loaded box, with balance kept behind.',
    '4-3-3', 163, 163, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pirlo', 'long switch to the weak side'),
    (2, 'Weak-side AM (Vidal)', 'drop to receive, play the wing back in'),
    (3, 'Wing back (Lichtsteiner)', 'advance high, cross'),
    (4, 'Front two + Marchisio', 'three runners into the box'),
    (5, 'Back three', 'stay to keep the numerical advantage')
) AS v(so, role, job);

-- 66. pp.165-165
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Ch8: Transition From Attack to Defence', 'Delay, block forward pass, force wide',
    'On losing the ball Juve mostly did not counter-press to win it; the nearest man pressed the carrier to cut the forward pass and push play wide, buying time for team-mates to recover into a compact shape.',
    'Loss of possession',
    'Delay the counter, deny the direct forward pass, regroup compactly.',
    NULL, 165, 165, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'press the carrier at an angle that blocks the forward pass'),
    (2, 'Rest of team', 'sprint back into a compact defensive block'),
    (3, 'Back line', 'keep a numerical edge to defend aggressively; if level in numbers vs a forward on the ball, delay rather than tackle')
) AS v(so, role, job);

-- 67. pp.167-167
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Ch8: Balanced Positioning of the Wing Backs', 'Asymmetric wing backs for rest defence',
    'During build-up the ball-side wing back pushes high while the far wing back stays deeper; if possession is lost, the far wing back can drop straight in and the three CBs pick up the two strikers.',
    'Build-up on one flank; loss of possession',
    'Far wing back recovers fast so the back line is not outnumbered.',
    NULL, 167, 167, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side wing back (Asamoah)', 'advanced position'),
    (2, 'Weak-side wing back (Lichtsteiner)', 'deeper, adjusts to the situation, drops quickly on loss'),
    (3, 'Three CBs', 'immediately mark the two opposing forwards')
) AS v(so, role, job);

-- 68. pp.170-170
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Ch8: Retaining Balance Near the Sideline', 'Wing back and AM take opposite heights',
    'Against sides with full backs plus wide midfielders (4-4-2, 4-1-4-1, 4-4-1-1), the strong-side wing back and AM always balance: if the WB goes high the AM drops to cover, and vice versa; the far wing back''s depth frees the far AM to push up.',
    'Strong-side wing back makes a forward run',
    'Covering AM is already near the ball to press the winner immediately on a loss.',
    NULL, 170, 170, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side wing back (Asamoah)', 'go high (or stay deep and let the AM go)'),
    (2, 'Strong-side AM (Marchisio)', 'drop into covering spot when the WB goes'),
    (3, 'Weak-side wing back (Lichtsteiner)', 'stay deep'),
    (4, 'Weak-side AM (Vidal)', 'advanced position')
) AS v(so, role, job);

-- 69. pp.174-174
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Ch8: Retaining Balance Near the Sideline', 'Both AMs high, wing backs form five',
    'When the strong-side wing back stays deep, both AMs can be high; on a loss neither can help Pirlo, but Pirlo steps to block the forward pass while the three CBs tighten and both wing backs drop to make a back five.',
    'Loss of possession with both AMs advanced',
    'Safety in numbers: five behind Pirlo even without midfield support.',
    NULL, 174, 174, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pirlo', 'move to block the forward pass'),
    (2, 'Three CBs', 'squeeze close together'),
    (3, 'Both wing backs', 'drop to form a back five'),
    (4, 'Strong-side AM (Marchisio)', 'high to attack space/2v1 on the flank')
) AS v(so, role, job);

-- 70. pp.176-177
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Ch8: Balanced Positioning of the Attacking Midfielders', 'Staggered AMs: link-cover and third forward',
    'In attack the strong-side AM sits slightly behind the opposing midfield line as link player while the weak-side AM goes high as a third forward; on a loss Pirlo closes the new carrier and the strong-side AM drops to support him or cover an advanced wing back.',
    'Loss of possession in the middle third',
    'Pirlo is never alone and the flank behind a high wing back is covered.',
    NULL, 176, 177, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side AM (Marchisio)', 'balanced, slightly deeper; drop to support Pirlo / cover WB; goes wider if Pirlo is already on the ball side'),
    (2, 'Weak-side AM (Vidal)', 'advanced, runs into the box as third forward'),
    (3, 'Pirlo', 'press the player who won the ball')
) AS v(so, role, job);

-- 71. pp.181-181
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Ch8: Numerical Advantage at the Back', 'Keep one spare at the back',
    'While building, the back line keeps at least one more than the opposing attackers: vs one forward plus an AM, a 2v1 lets a wide CB step up; vs two forwards, all three CBs stay for a 3v2.',
    'Building up from the back',
    'If the ball is lost, defenders can contest direct passes aggressively.',
    NULL, 181, 181, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide CB (Chiellini)', 'free to carry forward when only 2v1 needed'),
    (2, 'Other CBs', 'hold back to keep +1 over the forwards'),
    (3, 'Rest', 'balanced positions in front')
) AS v(so, role, job);

-- 72. pp.182-183
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Ch8: Numerical Advantage at the Back', 'Far wing back drops to make +1',
    'Against three forwards, or two forwards plus an AM sitting behind Pirlo, the back three are only level, so the weak-side wing back drops into line with the deepest forward/AM; from there he can still push up for a switch or recover on a loss.',
    'Opponent leaves three attackers high (3v3 at the back)',
    'Restore numerical superiority; if level or short, the defender on the ball carrier delays until help arrives unless he is sure to win the duel.',
    NULL, 182, 183, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side wing back (Lichtsteiner)', 'drop level with the deepest forward (or with the AM if he is behind Pirlo)'),
    (2, 'Three CBs', 'mark the front players; contest aggressively only with superiority'),
    (3, 'Strong-side wing back', 'pushes on to receive')
) AS v(so, role, job);

-- 73. pp.188-189
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Chapter 8: Transition from Attack to Defence Against the 3-4-3 (1)-(2)', '3v2 at the back, CB attacks the receiver',
    'Juve lose the ball in midfield while keeping three defenders against the opponent''s two advanced forwards.',
    'Ball lost centrally; pass toward an opposing forward or winger who has dropped',
    'Use the spare defender to press the receiver from behind, stop him turning and win the ball back with a double team.',
    '3-4-3', 188, 189, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (Chiellini)', 'follow the receiver tight and stop him turning'),
    (2, 'Defensive midfielder (Pirlo)', 'close down the new carrier at once'),
    (3, 'Deep attacking midfielder (Marchisio)', 'support Pirlo, then drop to double-mark the receiver'),
    (4, 'Far attacking midfielder (Vidal)', 'make a recovery run'),
    (5, 'Weak-side wing back (Lichtsteiner)', 'drop as safety and shift across with the other CBs'),
    (6, 'Other centre backs (Bonucci, Barzagli)', 'stay close and keep the numerical edge')
) AS v(so, role, job);

-- 74. pp.189-216
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Chapter 8: Transition from attack to defence (all opponent shapes)', 'Open ball: back three drop and narrow',
    'Possession is lost and for a couple of seconds the new carrier is unpressed, with opposing forwards starting runs in behind.',
    'Ball lost, no Juve player yet pressing the carrier',
    'Deny the pass in behind and close the gaps between defenders until a midfielder can close the carrier down.',
    NULL, 189, 216, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three (Chiellini, Bonucci, Barzagli)', 'retreat together and squeeze inward with short distances between them'),
    (2, 'Nearest midfielder (Pirlo / Vidal / Marchisio)', 'sprint to close the carrier and turn the ball closed'),
    (3, 'Weak-side wing back', 'recover to add a fourth defender'),
    (4, 'Ball-side centre back', 'step out to contest only once the ball is closed and cover is set')
) AS v(so, role, job);

-- 75. pp.190-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Chapter 8: Transition from Attack to Defence Against the 3-4-3 (3)', 'Wing back high, weak side restores 4v3',
    'The left wing back is high when he loses the ball, leaving three defenders against three forwards.',
    'Advanced wing back dispossessed near the sideline; equal numbers at the back',
    'Pin the ball near the touchline and rebuild a spare defender so the CB can press hard.',
    '3-4-3', 190, 190, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side wing back (Lichtsteiner)', 'drop level with the deepest forward to make 4v3'),
    (2, 'Deep attacking midfielder (Marchisio)', 'close the full back right away and keep him on the sideline'),
    (3, 'Ball-side centre back (Chiellini)', 'mark the most obvious receiver tight, then contest him aggressively'),
    (4, 'Middle centre back (Bonucci)', 'cover behind Chiellini'),
    (5, 'Far centre back (Barzagli)', 'hold balance'),
    (6, 'Vidal / Asamoah / Pirlo', 'recover into midfield balance and move toward the ball')
) AS v(so, role, job);

-- 76. pp.192-194
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Chapter 8: Transition from Attack to Defence Against the 3-4-1-2 (1)-(3)', 'Weak wing back drops vs 3-4-1-2',
    'After a lost long ball or a turnover in midfield, the opponent''s front two plus an advanced No.10 can make it 3v3 at the back.',
    'Ball lost while the opposing No.10 is level with the front two',
    'Bring the weak-side wing back a few yards deeper to keep 4v3, then press the receiver with cover behind.',
    '3-4-1-2', 192, 194, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side wing back (Asamoah)', 'drop a few yards to offset the No.10 and help double-mark wide runners'),
    (2, 'Ball-side centre back (Chiellini / Bonucci)', 'contest a forward who runs outside him or drops'),
    (3, 'Middle / far centre back', 'shift across to cover and balance'),
    (4, 'Defensive midfielder (Pirlo)', 'close the new carrier, or cover behind Vidal'),
    (5, 'Attacking midfielder (Vidal)', 'close the carrier if nearer, or drop to support')
) AS v(so, role, job);

-- 77. pp.195-195
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Chapter 8: Transition from Attack to Defence Against the 3-4-1-2 (4)', 'Wing back pre-drops when the other is high',
    'In build-up the opposing No.10 pushes onto a CB, so it is 3v3 behind the ball while the right wing back is high.',
    'One wing back advanced and the opposing No.10 pressing high',
    'Prepare the defensive transition before the ball is lost, and release the drop when an opposing wide player retreats.',
    '3-4-1-2', 195, 195, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (Asamoah)', 'sit a few yards deeper in build-up while Lichtsteiner is high'),
    (2, 'Right wing back (Lichtsteiner)', 'need not drop when the opposing wide man retreats deep (4v3 already)'),
    (3, 'Attacking midfielder (Vidal)', 'act as link to feed Pirlo, then make a recovery run on loss'),
    (4, 'Ball-side centre back (Chiellini)', 'press the new carrier with Pirlo so he cannot turn; 2v2 never comes')
) AS v(so, role, job);

-- 78. pp.197-198
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Chapter 8: Transition from Attack to Defence Against the 3-5-2 (1)-(2)', '3v2 vs 3-5-2 front pair',
    'A through ball or a line-breaking pass is cut out and the opponent counters with two forwards against Juve''s three CBs.',
    'Interception by an opposing CB or midfielder',
    'Converge on the two forwards, mark the obvious receiver and press him with cover while both wing backs recover.',
    '3-5-2', 197, 198, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Pirlo)', 'close the carrier immediately'),
    (2, 'Attacking midfielder (Vidal / Marchisio)', 'drop into support or into Pirlo''s spot as cover'),
    (3, 'Ball-side centre back (Chiellini / Bonucci)', 'stay tight to the most likely receiver, then win the ball'),
    (4, 'Other centre backs', 'converge into covering and balancing positions'),
    (5, 'Both wing backs', 'recover for extra safety')
) AS v(so, role, job);

-- 79. pp.200-201
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Chapter 8: Transition from Attack to Defence Against the 4-4-2 (1)-(2)', 'Wing backs level with wingers vs 4-4-2',
    'Against a 4-4-2, each wing back keeps a starting position near the opposing winger, and an attacking midfielder balances near the sideline when the wing back goes forward.',
    'Ball lost to a full back or winger; forwards run in behind',
    'Step in quickly on the winger, deny equality at the back and leave the three CBs an easy clearance against two forwards.',
    '4-4-2', 200, 201, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side wing back (Lichtsteiner)', 'stay level with the winger, ready to push on or drop'),
    (2, 'Advancing wing back (Asamoah)', 'push forward only while the AM balances behind him'),
    (3, 'Attacking midfielder (Marchisio)', 'drop near the sideline and close the winger who receives'),
    (4, 'Back three', 'drop together vs the two forwards; one clears, two cover'),
    (5, 'Defensive midfielder (Pirlo)', 'close the central carrier')
) AS v(so, role, job);

-- 80. pp.202-203
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Chapter 8: Transition from Attack to Defence Against the 4-4-2 (3)', 'Midfielder takes over marking vs 4-4-2',
    'An opposing central midfielder breaks forward while a far winger advances, threatening 3v3 plus runners.',
    'Opposing No.6 carries forward; weak-side winger pushes up',
    'Keep 4v3 at the back by passing markers on, so the CBs can control runs in behind.',
    '4-4-2', 202, 203, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Pirlo)', 'shift across and close the carrier'),
    (2, 'Attacking midfielder (Marchisio)', 'drop to support, follow a runner, then take over a dropping forward'),
    (3, 'Weak-side wing back (Lichtsteiner)', 'drop and come across to make 4v3'),
    (4, 'Ball-side centre back (Chiellini)', 'hand his man on and drop to control a winger''s forward run'),
    (5, 'Middle centre back (Bonucci)', 'shift across to block the through pass')
) AS v(so, role, job);

-- 81. pp.205-207
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Chapter 8: Transition from Attack to Defence Against the 4-2-3-1 (1)-(3)', '5v4 rest defence vs 4-2-3-1',
    'With four opposing attackers high, the weak-side wing back stays deep so Juve keep five behind the ball.',
    'Ball lost while the opponent has four players in advanced positions',
    'Keep 5v4, close the carrier and contest the striker with cover from both sides.',
    '4-2-3-1', 205, 207, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side wing back (Lichtsteiner)', 'stay deep while Juve attack'),
    (2, 'Defensive midfielder (Pirlo)', 'close the carrier and block the pass to the free No.10'),
    (3, 'Deep attacking midfielder (Marchisio / Vidal)', 'stay ready to cover Pirlo or join the press'),
    (4, 'Middle centre back (Bonucci)', 'contest the striker when he receives and stop him turning'),
    (5, 'Outside centre backs (Chiellini, Barzagli)', 'move into cover as the pass goes in')
) AS v(so, role, job);

-- 82. pp.206-206
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Chapter 8: Transition from Attack to Defence Against the 4-2-3-1 (2)', '4v4 wide: contain, don''t dive in',
    'A long pass to an advanced wing back is headed away, leaving equal numbers at the back and Chiellini one-on-one with a winger near the sideline.',
    'Equal numbers at the back after a lost long ball',
    'Delay the winger near the sideline until teammates recover, then switch to aggressive defending.',
    '4-2-3-1', 206, 206, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back (Chiellini)', 'keep his man near the sideline and limit options, without going to ground'),
    (2, 'Other defenders and midfielders', 'sprint back to restore a spare man'),
    (3, 'Wide centre back (Chiellini)', 'press for the ball once support has arrived')
) AS v(so, role, job);

-- 83. pp.209-211
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Chapter 8: Transition from Attack to Defence Against the 4-3-1-2 (1)-(3)', 'Balance near the sideline vs 4-3-1-2',
    'Against a 4-3-1-2, an attacking midfielder and a wing back swap the high and deep roles on the flank so one of them always balances behind, and 4v3 is kept.',
    'One wide player goes forward; ball lost on that flank',
    'Keep one player behind the ball on the flank so a lost ball meets a double team and a spare defender.',
    '4-3-1-2', 209, 211, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Marchisio / Vidal)', 'push wide when the WB receives deep, or drop when the WB overlaps; close the full back on loss'),
    (2, 'Wing back (Asamoah / Lichtsteiner)', 'close the winger with Pirlo, or drop to cover the AM'),
    (3, 'Defensive midfielder (Pirlo)', 'join the ball area to double-mark'),
    (4, 'Ball-side centre back (Barzagli)', 'follow and mark tight a forward moving into a lane, then press'),
    (5, 'Middle centre back (Bonucci)', 'shift to cover; one CB clears long balls')
) AS v(so, role, job);

-- 84. pp.210-210
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Chapter 8: Transition from Attack to Defence Against the 4-3-1-2 (2)', 'Advanced No.10: drop, wait or step out',
    'The opposing No.10 sits high in front of Pirlo, so the weak-side wing back drops in line with him. After a turnover the No.10 carries at the back line.',
    'Interception gives the No.10 the ball running at a compact 4v3',
    'Either retreat and let Pirlo catch the No.10, or have the nearest CB step out while the others narrow and cover.',
    '4-3-1-2', 210, 210, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side wing back (Asamoah)', 'drop level with the No.10 to stop a 3v3'),
    (2, 'Back line', 'option 1: keep dropping until Pirlo can challenge from behind'),
    (3, 'Nearest centre back (Bonucci)', 'option 2: step up and contest the No.10'),
    (4, 'Other defenders', 'come inward and back to cover the stepping CB')
) AS v(so, role, job);

-- 85. pp.213-216
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_defend', 'Chapter 8: Transition from Attack to Defence Against the 4-3-3 (1)-(3)', '4-3-3: balanced wing back, delay to sideline',
    'Against a 4-3-3, a wing back holding a balanced position keeps 4v3. When it drops to 3v3 and a forward receives free centrally, the CB holds off until a through pass is impossible, then steps out to steer the carrier wide.',
    'Ball lost after a switch or a long ball; free opposing forward receives',
    'Restore a spare defender: delay the carrier toward the touchline so the far wing back can recover into a 4v3.',
    '4-3-3', 213, 216, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side wing back (Lichtsteiner / Asamoah)', 'keep a balanced spot, then recover to make 4v3'),
    (2, 'Defensive midfielder (Pirlo)', 'close the carrier and block the forward pass'),
    (3, 'Attacking midfielder (Vidal)', 'use his balanced position to slide into cover'),
    (4, 'Middle centre back (Bonucci)', 'drop if too far away to close; step out to delay and show the sideline once the through ball is gone'),
    (5, 'Other centre backs', 'converge and narrow to shrink the gaps for through passes')
) AS v(so, role, job);

-- 86. pp.219-220
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_attack', 'Chapter 9: Direct Counter Attack Against a 3 Man Defence', 'Long diagonal behind converging wide CB',
    'On a regain, the opponent''s wide CBs, who had split wide in build-up, tuck inside to close central gaps, which opens space near both touchlines.',
    'Ball won (e.g. CB beats the forward to it) while the opposing wide CBs are converging',
    'Hit the quick forward early with a long diagonal into the channel behind the wide CB, so he can shoot.',
    '3-4-1-2', 219, 220, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-winning centre back (Barzagli)', 'win the duel and play the ball to Pirlo dropping in'),
    (2, 'Playmaker (Pirlo / Marchisio / Vidal)', 'send a quick long diagonal into the free wide space'),
    (3, 'Quick forward (Giovinco / Tevez / Quagliarella)', 'curve a run on the blind side of the wide CB and finish'),
    (4, 'Tall forward (Llorente / Vucinic)', 'if targeted, receive back to goal and lay off to a runner')
) AS v(so, role, job);

-- 87. pp.221-221
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_attack', 'Chapter 9: Direct Counter Attack Against a 4 Man Defence', 'Counter v back four: channel or gap',
    'Against a 4-2-3-1 whose CBs spread wide in build-up, a headed clearance reaches an attacking midfielder in the centre.',
    'Defensive header won and the ball cleared to the central AM',
    'Exploit the CBs'' late recovery, either in the wide channel or through the central gap if they fail to close it.',
    '4-2-3-1', 221, 221, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Barzagli)', 'head the aerial ball clear to the central AM'),
    (2, 'Attacking midfielder (Marchisio)', 'carry forward, then pass into the channel or straight through the middle'),
    (3, 'Quick forward (Giovinco)', 'curve run on the blind side of a CB, or run diagonally between the CBs if the gap stays open')
) AS v(so, role, job);

-- 88. pp.224-226
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_attack', 'Chapter 9: Indirect Counter Attack With a Switch of Play (1)', 'Weak wing back stays high, switch on regain',
    'When the opponent attacks Juve''s right, the strong-side AM presses the full back so the strong-side wing back can stay home. That lets the weak-side wing back stay high.',
    'Ball regained on the strong side with the direct pass forward blocked',
    'Switch to the free weak-side wing back, then overload the final third on that side.',
    NULL, 224, 226, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side attacking midfielder (Vidal)', 'press the full back defensively'),
    (2, 'Strong-side wing back (Lichtsteiner)', 'stay back to keep the numerical edge'),
    (3, 'Defensive midfielder (Pirlo)', 'on receiving under pressure, switch long to the weak-side wing back'),
    (4, 'Weak-side wing back (Asamoah)', 'start high, receive the switch and cross or slip a pass'),
    (5, 'Weak-side attacking midfielder (Marchisio)', 'run diagonally between the lines for 3v2, or drag the CB to open the centre'),
    (6, 'Quick forward (Giovinco)', 'attack the central space if the CB follows Marchisio')
) AS v(so, role, job);

-- 89. pp.227-228
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-the-juventus-3-5-2-tactical-analysis-and-sessions-attacking'), 'to_attack', 'Chapter 9: Indirect Counter Attack With a Switch of Play (2)', 'Tall forward link, then switch',
    'Pirlo wins the ball but the forward pass is not on. The tall forward cannot attack space, so he drops into the lane as a link instead.',
    'Regain under pressure; no direct pass to the quick forward',
    'Use the tall forward''s lay-off to reach the AM, who switches to the weak-side wing back; the quick forward then runs behind the full back.',
    NULL, 227, 228, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Pirlo)', 'win the ball and pass to the dropping forward'),
    (2, 'Tall forward (Llorente)', 'drop into the passing lane, lay off first time, then attack the box'),
    (3, 'Attacking midfielder (Marchisio)', 'receive the lay-off and switch, then push between the lines for 3v2'),
    (4, 'Weak-side wing back (Asamoah)', 'carry forward and slip the quick forward in behind the full back who steps out'),
    (5, 'Quick forward (Giovinco)', 'run into the space behind the full back and cross for the runners')
) AS v(so, role, job);

COMMIT;
