-- 1966 📚 Coaching book patterns: "Jose Mourinho's Real Madrid: Attacking in the 4-2-3-1" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Jose Mourinho''s Real Madrid: A Tactical Analysis',
    subtitle    = 'Attacking in the 4-2-3-1',
    author      = 'Athanasios Terzis',
    team        = 'Real Madrid',
    season      = '2011-12',
    method_note = 'Video analysis of Mourinho''s 2011-12 La Liga-winning Real Madrid in a 4-2-3-1 (the attacking volume of a two-book set; the defending volume is the Terzis book above). Each phase of play is shown as an outline, progressions and 3D diagrams with named players (Casillas; Arbeloa, Pepe, Ramos, Marcelo; Khedira, Alonso; Di María, Özil, Ronaldo; Benzema) and a short assessment. Chapters: build-up (the 10 receiving from the centre backs, rhombuses on each flank, wingers inside and full backs overlapping), combinations after a long switch to the weak side, losing the ball (safety players, immediate pressure, steering wide), counters, attacking set pieces and playing with 10 men. Patterns are the phases of play, in our words, with who does what.'
WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book');

-- 1. pp.19-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Introduction / Ch2 Attacking Phase', 'Direct build-up and safe long balls',
    'Madrid aimed to create a chance within 3-4 passes, or with long balls to the forwards, rather than keeping long spells of possession. Under pressure, the defenders did not risk passes into midfield and instead played long to Benzema or Ronaldo.',
    'Centre backs pressed in the build-up',
    'Never lose the ball in dangerous areas and reach the forwards fast.',
    NULL, 19, 19, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Pepe, Ramos)', 'under pressure, skip midfield and play long'),
    (2, 'Forwards (Benzema, Ronaldo)', 'targets for the long ball'),
    (3, 'Left holding midfielder (Alonso)', 'sets the tempo; links defence to attack with short and long passes to the weak side')
) AS v(so, role, job);

-- 2. pp.19-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'out_of_possession', 'Ch2 Real Madrid in the Defensive Phase', 'High press with aggressive zonal marking',
    'Without the ball Madrid mostly pressed high near the opponent''s box. Defenders marked their zones aggressively with midfield and forwards, and midfielders positioned to double up on opponents.',
    'Opponent in possession in its own third',
    'Take away time and space and win the ball back fast so Madrid keep most of the possession.',
    NULL, 19, 29, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'aggressive zonal marking, step onto direct opponents'),
    (2, 'Midfielders', 'position to double-mark the ball-side opponent'),
    (3, 'Wingers', 'their positioning (balanced or goal-side) shapes how the press is set'),
    (4, 'Left holding midfielder (Alonso)', 'fills gaps in the back line and covers for Marcelo/Ronaldo on the left')
) AS v(so, role, job);

-- 3. pp.19-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Ch2 Real Madrid in the Transition from Attack to Defence', 'Safety player and immediate counter-press',
    'While attacking, Madrid always kept balance so that a safety player was near the ball when it was lost. Players around the ball zone reacted at once to win it back.',
    'Ball lost in the attacking phase',
    'Win the ball back immediately; if that fails, protect the centre and force play wide.',
    NULL, 19, 30, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest safety player (often Alonso)', 'press the new ball carrier straight away'),
    (2, 'Players in the ball zone', 'close down at once, work to regain'),
    (3, 'Whole team', 'if the regain fails, lock the central zone and push the ball to the flank'),
    (4, 'Right back (Arbeloa)', 'react fast: press or take a covering spot')
) AS v(so, role, job);

-- 4. pp.19-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch2 Real Madrid in the Attacking Phase', 'Crosses for tall forwards and driving cut-ins',
    'Final balls came from Ozil centrally, or from Di Maria and Ronaldo driving inside onto their stronger foot to play a vertical or diagonal pass to a runner. On the flanks, moves often ended in high out-swinging crosses from the full backs (or Ozil). Di Maria, Ozil and Ronaldo whipped in-swingers from just outside the box, and Khedira hit low crosses from the edge of the box on the right.',
    'Ball reaches the final third wide or in the half-space',
    'Use the forwards'' strength in the air and the inverted wingers'' shooting and killer passes.',
    NULL, 19, 31, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted wingers (Di Maria R, Ronaldo L)', 'drive inside to shoot, slip a pass to a runner, or whip an in-swinger'),
    (2, 'Full backs (Marcelo, Arbeloa)', 'push up to send high out-swinging crosses'),
    (3, 'Right holding midfielder (Khedira)', 'runs beyond the full back on the right; low crosses from the box edge'),
    (4, 'Centre forward (Benzema/Higuain)', 'attacks crosses in the box')
) AS v(so, role, job);

-- 5. pp.19-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_attack', 'Ch2 Real Madrid in the Transition from Defence to Attack', 'Fast break via Ronaldo''s high position',
    'Ronaldo did little defending and stayed high, and Mourinho used that as a launch point for counters. Ozil played the timed pass for the pace of Ronaldo, Di Maria, Benzema and Higuain. Madrid even broke from defending set pieces.',
    'Ball won, especially against an opponent pushed high',
    'Score before the opponent recovers its shape.',
    NULL, 19, 32, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left forward (Ronaldo)', 'stays high and wide as the outlet; runs onto the through ball'),
    (2, 'Attacking midfielder (Ozil)', 'plays the early, well-timed pass in behind'),
    (3, 'Right winger (Di Maria) / centre forward', 'sprint into space beside Ronaldo')
) AS v(so, role, job);

-- 6. pp.31-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch2 Attacking Phase / Ch3 Basic formation: width created by the full backs', 'Basic shape: full backs give width',
    'In the base 4-2-3-1 attack the wingers moved inside and the full backs pushed high and wide. Width came from Marcelo on the left, and on the right from Di Maria or from Arbeloa when Di Maria came inside. This gave Madrid a numbers advantage in the centre.',
    'Settled possession; wingers drift inside',
    'Overload the centre for short vertical and diagonal passes; if the opponent''s wide men tuck in, switch long to the free full back.',
    NULL, 31, 34, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'high, near the touchline'),
    (2, 'Right back (Arbeloa)', 'high and wide when Di Maria is inside'),
    (3, 'Wingers (Ronaldo, Di Maria)', 'move inside to create central superiority'),
    (4, 'Holding midfielders / centre backs', 'long pass to a full back when the centre gets crowded')
) AS v(so, role, job);

-- 7. pp.35-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch3 The Width on the Left Is Created by the Winger', 'Left winger wide, left back tucks in',
    'Ronaldo holds the touchline on the left, so Marcelo moves inside for balance and Arbeloa gives width on the right. Alonso shifts central or higher. If Benzema drifts left, Ozil sits central and Di Maria moves forward and inside.',
    'Ronaldo takes the touchline',
    'Keep one wide player per flank and a balanced rest of the team while the winger isolates his full back.',
    NULL, 35, 35, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'near the touchline, gives the width'),
    (2, 'Left back (Marcelo)', 'moves inside to balance'),
    (3, 'Right back (Arbeloa)', 'gives width on the right'),
    (4, 'Left holding midfielder (Alonso)', 'moves into the centre or higher'),
    (5, 'Attacking midfielder (Ozil) / right winger (Di Maria)', 'fill the centre if the striker drifts left')
) AS v(so, role, job);

-- 8. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch3 The Width on the Right Is Created by the Winger', 'Right winger wide, right back tucks in',
    'Di Maria stays on the right touchline, so Arbeloa moves inside to balance. Khedira steps higher and Alonso shifts to the centre.',
    'Di Maria holds the touchline',
    'Keep width on the right without losing central cover.',
    NULL, 36, 36, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'near the touchline'),
    (2, 'Right back (Arbeloa)', 'tucks in for balance'),
    (3, 'Right holding midfielder (Khedira)', 'moves higher up'),
    (4, 'Left holding midfielder (Alonso)', 'moves into the centre')
) AS v(so, role, job);

-- 9. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch3 Playing with 2 Forwards', 'Two strikers: Benzema shifts right',
    'When Benzema and Higuain both started, Benzema played to the right as a second forward. Ronaldo moved central and Ozil went to the right in a more attacking set-up. When Ozil went to the right touchline, Khedira pushed higher and Arbeloa moved inside.',
    'Benzema and Higuain both starting',
    'Get two strikers into the box and still cover the flanks.',
    NULL, 37, 37, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Second forward (Benzema)', 'plays right of Higuain'),
    (2, 'Left forward (Ronaldo)', 'moves central'),
    (3, 'Attacking midfielder (Ozil)', 'shifts right, sometimes to the touchline for width'),
    (4, 'Right holding midfielder (Khedira)', 'pushes higher when Ozil goes wide'),
    (5, 'Right back (Arbeloa)', 'moves inside when Ozil gives the width')
) AS v(so, role, job);

-- 10. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch3 Both the Winger and the Full Back Create Width', 'Winger and full back both wide',
    'Ronaldo and Marcelo, or Di Maria and Arbeloa, both stand near the same touchline, and Ozil shifts toward that side to support.',
    'Winger and full back both wide on one side',
    'Double up wide on the strong side with the playmaker close by.',
    NULL, 38, 38, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'near the touchline, high'),
    (2, 'Full back', 'wide, behind the winger'),
    (3, 'Attacking midfielder (Ozil)', 'shifts toward the strong side')
) AS v(so, role, job);

-- 11. pp.39-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch3 The Centre Forward Drops Deep on the Strong Side', 'Striker drops on the strong side',
    'With the winger and full back both wide and the attacking midfielder away from the ball side, Benzema drops deep on that side.',
    'Strong side lacks a central option because the 10 is far away',
    'Give the ball carrier an extra passing option.',
    NULL, 39, 39, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Benzema)', 'drops deep toward the strong side as a passing option'),
    (2, 'Winger + full back', 'hold the width'),
    (3, 'Ball-side centre back', 'has the ball, looks for the dropping striker')
) AS v(so, role, job);

-- 12. pp.40-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch3 Central Defender Build up Play from the Back', 'Alonso drops in, centre back carries',
    'Alonso drops into a centre-back position to get the ball free of marking or to keep balance. The centre back on his side (Ramos on the left, Pepe on the right) then carries the ball forward into midfield.',
    'Holding midfielder marked, or the build-up needs a spare man at the back',
    'Get the ball out from the back unmarked and step a defender into midfield.',
    NULL, 40, 41, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left holding midfielder (Alonso)', 'drops between or beside the centre backs'),
    (2, 'Left centre back (Ramos)', 'dribbles forward on the left'),
    (3, 'Right centre back (Pepe)', 'dribbles forward on the right'),
    (4, 'Attacking midfielder (Ozil)', 'drops to support')
) AS v(so, role, job);

-- 13. pp.42-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch3 The 3 Stages of the Build up & the Target Areas', 'Three build-up stages and A/B/C target areas',
    'Stage 1 moves the ball from defence to midfield, mostly with vertical and diagonal passes, sometimes skipped with a long ball. Stage 2 gets the ball into a target area: wide A (beside the box) or B (wide midfield) by creating overloads down the flanks or switching long, and central C (in front of the box) by central combinations or winger/full-back dribbles inside. Stage 3 is the final pass or cross: low or high out-swinging crosses from A, in-swingers from B, killer passes or shots from C.',
    'Possession won or established at the back',
    'Create as many chances as possible by mixing short combinations, long switches and balls in behind.',
    NULL, 42, 43, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs / holding midfielders', 'stage 1: vertical or diagonal passes, or go long'),
    (2, 'Full backs and wingers', 'stage 2: overload the flank to reach areas A/B'),
    (3, 'Attacking midfielder / inverted wingers', 'reach area C via central combinations or dribbles inside'),
    (4, 'Forwards and Khedira', 'stage 3: attack crosses from A and B')
) AS v(so, role, job);

-- 14. pp.44-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch3 Retaining the Team''s Balance during the Build up', 'Striker or 10 attacks space behind full back',
    'When the wingers are inside and drop back to receive, the striker or the attacking midfielder runs into the space left behind the opponent''s full back. Between them, Benzema and Ozil keep one player close to the strong side at all times.',
    'Winger drops inside and pulls the full back with him',
    'Use the space the inverted winger opens behind the full back.',
    NULL, 44, 46, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted winger (Ronaldo)', 'drops inside to receive, dragging his marker'),
    (2, 'Attacking midfielder (Ozil) or centre forward (Benzema)', 'whoever is closer runs into the space behind the full back'),
    (3, 'Left back (Marcelo)', 'holds the width')
) AS v(so, role, job);

-- 15. pp.44-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch3 Positioning: Creating the Correct Shapes', 'Closest of 9/10 tops the rhombus',
    'With the wingers wide and a centre back on the ball out wide, whichever of Ozil or Benzema is nearer the strong side moves to the top of the rhombus. The other forwards slide into the striker spot he left (Di Maria or Ronaldo).',
    'Centre back on the ball on one side, wingers holding width',
    'Always complete the rhombus around the ball carrier and keep the box occupied.',
    NULL, 44, 47, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Ozil)', 'goes to the top of the rhombus when he is closer'),
    (2, 'Centre forward (Benzema)', 'drops to the top of the rhombus when he is closer'),
    (3, 'Far winger (Di Maria) / Ronaldo', 'fill the vacated centre-forward spot'),
    (4, 'Ball-side centre back (Ramos)', 'the ball carrier at the base of the rhombus')
) AS v(so, role, job);

-- 16. pp.48-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch3 Movement with and without the Ball', 'Centre back carries, holder drops behind',
    'As Ramos dribbles forward on the left, Alonso drops deeper to keep balance. Ozil then drops into Alonso''s old spot, at the top or the side of the rhombus (with Ronaldo at the top), or Khedira supports from inside.',
    'Centre back starts a forward dribble',
    'Keep cover behind the carrying defender and a full set of passing options in front of him.',
    NULL, 48, 49, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Ramos)', 'carries the ball forward'),
    (2, 'Left holding midfielder (Alonso)', 'drops behind to cover'),
    (3, 'Attacking midfielder (Ozil)', 'drops into Alonso''s spot / side or top of the rhombus'),
    (4, 'Right holding midfielder (Khedira)', 'supports from inside'),
    (5, 'Left winger (Ronaldo)', 'top of the rhombus or touchline')
) AS v(so, role, job);

-- 17. pp.49-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch3 Forwards: Rotating Positions', 'Ronaldo and Benzema swap roles',
    'When Ronaldo plays as the centre forward, Benzema (or Higuain) moves out to the left. Benzema may also drop to the top of the rhombus while Ronaldo moves into the striker position, or go to the touchline while Ronaldo stays central.',
    'Ronaldo moves central or Benzema drops',
    'Make the forward line unpredictable while keeping a striker and a wide player.',
    NULL, 49, 50, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left forward (Ronaldo)', 'moves into the centre-forward spot'),
    (2, 'Centre forward (Benzema/Higuain)', 'moves to the left wing or the top of the rhombus'),
    (3, 'Right winger (Di Maria)', 'comes inside toward the box')
) AS v(so, role, job);

-- 18. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch4 Build up Play on the Left Side with the Width Created by the Full Back', 'Left-side rhombus and triangle build-up',
    'Ramos has the ball. Marcelo gives width at left back, Ronaldo stands at the top of the rhombus, and Alonso supports inside, with Ozil forming a triangle beside it. Short combinations come out of these shapes.',
    'Left centre back on the ball',
    'Give the ball carrier several angled options for passing combinations.',
    NULL, 53, 53, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Ramos)', 'base of the rhombus, on the ball'),
    (2, 'Left back (Marcelo)', 'wide corner of the rhombus'),
    (3, 'Left winger (Ronaldo)', 'top of the rhombus'),
    (4, 'Left holding midfielder (Alonso)', 'inside corner'),
    (5, 'Attacking midfielder (Ozil)', 'completes a triangle with Ronaldo and Alonso')
) AS v(so, role, job);

-- 19. pp.54-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch4 Build up Play on the Left Side with the Width Created by the Full Back', 'Full back inside give-and-go with winger',
    'Marcelo plays into Ronaldo and moves inside to collect the return, either from Ramos''s pass via Ronaldo or by a direct wall pass.',
    'Full back on the ball near the touchline, winger close',
    'Get the full back into a central receiving position past the first line.',
    NULL, 54, 54, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'passes and cuts inside to receive the return'),
    (2, 'Left winger (Ronaldo)', 'wall pass or lay-off'),
    (3, 'Left centre back (Ramos)', 'starts the move')
) AS v(so, role, job);

-- 20. pp.54-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch4 Build up Play on the Left Side with the Width Created by the Full Back', 'Winger drops, runner attacks his space',
    'Ronaldo checks back toward the ball, which creates an overload in the ball zone and leaves space behind him. Ozil, or Marcelo with an opposite movement, runs into that space and receives from Marcelo or Ramos. Sometimes Ronaldo instead receives, lays it to Alonso, or turns and drives inside while Ozil drifts left.',
    'Winger''s marker follows him as he drops',
    'Free a runner in behind the full back in the channel the winger vacated.',
    NULL, 54, 55, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'drops to receive / pulls his marker'),
    (2, 'Attacking midfielder (Ozil)', 'runs in behind into the vacated space'),
    (3, 'Left back (Marcelo)', 'makes the opposite run forward; or plays the pass'),
    (4, 'Left centre back (Ramos)', 'passes into the runner'),
    (5, 'Left holding midfielder (Alonso)', 'takes the lay-off')
) AS v(so, role, job);

-- 21. pp.55-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch4 Build up Play on the Left Side with the Width Created by the Full Back', 'Third-man pass near the box',
    'Near the opponent''s box, Alonso passes to Ozil, who plays first time into Ronaldo as Ronaldo runs toward goal.',
    'Holding midfielder on the ball in the attacking third, winger already moving',
    'Release the runner behind the defence with a one-touch third-man pass.',
    NULL, 55, 55, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left holding midfielder (Alonso)', 'passes into Ozil'),
    (2, 'Attacking midfielder (Ozil)', 'one-touch pass into the runner'),
    (3, 'Left winger (Ronaldo)', 'runs toward goal before the ball arrives')
) AS v(so, role, job);

-- 22. pp.56-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch4 Numerical Superiority in the Centre', 'Wingers inside: overload centre, free flanks',
    'The wingers move inside to outnumber the opponent''s midfield and pull its full backs narrow, which frees the flanks for Madrid''s full backs. Wingers also drop deep to overload the ball zone, and the striker or 10 uses the space they leave. With Ramos on the ball, Marcelo, Ronaldo and Alonso make a rhombus and give him three passing options. The diagrams show a 4-4-2 opponent.',
    'Opponent full backs follow the inside wingers',
    'Win the centre and open space on the flanks for the full backs.',
    NULL, 56, 56, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (Ronaldo, Di Maria)', 'move inside, drop deep to outnumber'),
    (2, 'Full backs (Marcelo, Arbeloa)', 'use the free flank'),
    (3, 'Centre forward / attacking midfielder', 'attack the space the wingers leave'),
    (4, 'Left centre back (Ramos)', 'chooses from the three options in the rhombus')
) AS v(so, role, job);

-- 23. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch4 Defensive Midfielder''s Passing Options', 'Winger drops, holder switches play',
    'Marcelo receives near the touchline. Ronaldo drops back to outnumber the ball zone and opens space for Ozil to run behind the opponent''s right back. Ronaldo gets the ball unmarked and lays it to Alonso, who can play Ozil in behind, switch to Arbeloa on the far side, or play back to Pepe. The diagrams show a 4-4-2 opponent.',
    'Strong side overloaded and the opponent shifted across',
    'Draw the opponent to the left, then go behind or switch to the free right flank.',
    NULL, 57, 57, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'receives wide from Ramos'),
    (2, 'Left winger (Ronaldo)', 'drops to receive, lays back to Alonso'),
    (3, 'Attacking midfielder (Ozil)', 'runs behind the opponent''s right back'),
    (4, 'Left holding midfielder (Alonso)', 'picks one of three: Ozil in behind, switch to Arbeloa, or back to Pepe'),
    (5, 'Right back (Arbeloa)', 'stays wide on the weak side for the switch')
) AS v(so, role, job);

-- 24. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch4 Full Back''s Movement inside', 'Full back passes and moves inside',
    'With Marcelo on the ball wide, Ronaldo comes across to support and Ozil runs into the space behind the opponent''s right back. Marcelo passes to Ronaldo and runs inside to take the return. The diagrams show a 4-4-2 opponent. The section continues past p58.',
    'Winger offers short support to the full back',
    'Bring the full back inside on the ball while Ozil pins or exploits the space behind the full back.',
    NULL, 58, 58, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'pass and run inside for the return'),
    (2, 'Left winger (Ronaldo)', 'supports short, returns the pass'),
    (3, 'Attacking midfielder (Ozil)', 'runs behind the opponent''s right back'),
    (4, 'Left centre back (Ramos)', 'first pass out to Marcelo')
) AS v(so, role, job);

-- 25. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Full Back''s Movement inside', 'Full back carries inside, winger stays central',
    'Left full back receives near the touchline and dribbles infield into space before being closed; the winger has stayed central rather than coming to the ball.',
    'Full back receives wide with space ahead and inside',
    'Use the flank space the winger left free and give the carrier a wide and an inside option.',
    NULL, 59, 59, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left full back (Marcelo)', 'drive infield with the ball, then pick wide or inside pass'),
    (2, 'Left winger (Ronaldo)', 'stay central-ish; run down the flank only once the full back is central'),
    (3, 'Centre forward (Benzema)', 'show inside for a pass, can release the 10 in behind'),
    (4, 'Attacking midfielder (Ozil)', 'run in behind the back line')
) AS v(so, role, job);

-- 26. pp.60-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Creating Space to Receive on the Left Flank', 'Winger drops, No.10 drifts wide to receive',
    'Left winger drops deep into midfield and drags the opposing right back with him; the No.10 slides out to the touchline into the space left behind and receives from the centre back.',
    'Opposing right back follows the winger''s deep run',
    'Receive free on the flank and cross, or if the 10 is tracked, recycle with full back overlap and winger running beyond.',
    NULL, 60, 62, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'drop into midfield to pull the right back out'),
    (2, 'Attacking midfielder (Ozil)', 'drift to the touchline into vacated space and receive'),
    (3, 'Left centre back (Ramos)', 'play the pass down the line to the 10'),
    (4, 'Centre forward + right winger', 'attack the box for the cross'),
    (5, 'Left full back (Marcelo)', 'if the 10 is tracked and can''t turn, overlap down the flank'),
    (6, 'Defensive midfielder (Alonso)', 'support behind the 10 as a safe outlet')
) AS v(so, role, job);

-- 27. pp.63-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Centre Forward: Movement into ''Channels''', 'Centre forward runs into the left channel',
    'With the No.10 far from the ball zone and the winger tucked inside, the centre forward runs into the channel behind the opposing right back to take a pass down the line.',
    'Space behind the right back while the 10 is away from the ball',
    'Isolate the striker 1v1 near the touchline, then cross, cut back or drive in to shoot.',
    NULL, 63, 64, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Benzema/Higuain)', 'spin into the channel, take on the defender, cross/cut back/shoot'),
    (2, 'Left winger (Ronaldo)', 'come inside, then take a spot on the edge of the box'),
    (3, 'Attacking midfielder + right winger (Ozil, Di Maria)', 'attack the box for the cross'),
    (4, 'Left centre back (Ramos)', 'play into the channel')
) AS v(so, role, job);

-- 28. pp.65-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Receiving with Your Back to Goal', 'Winger drops for vertical pass and turns',
    'Left winger drops to take a vertical pass from the centre back; the right back does not follow and leaves him to the central midfielder, so he can turn and drive diagonally inside.',
    'Winger receives with room to turn towards the centre',
    'Reach the third build-up stage: final pass in behind, a shot, or a long switch to the far full back.',
    NULL, 65, 67, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'drop, receive, turn and drive diagonally inside'),
    (2, 'Left centre back (Ramos)', 'play the vertical pass into the winger''s feet'),
    (3, 'Centre forward + right winger', 'run in behind the back line for the final ball'),
    (4, 'Right full back (Arbeloa)', 'push high for a long switch if the inside passes are blocked'),
    (5, 'Attacking midfielder (Ozil)', 'move left to open space for the winger and use the space he creates')
) AS v(so, role, job);

-- 29. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Receiving with Your Back to Goal', 'Tight-marked winger: wall pass and spin',
    'When the midfield is squeezed and the right back follows the dropping winger, the centre forward comes short in front of him; the winger plays first time to the striker and spins away to the touchline.',
    'Winger receiving is followed / double marked',
    'Escape pressure with a one-two that releases the winger into the space behind on the flank, with a safe ball back to the 10 if not on.',
    NULL, 66, 66, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'play first time to the striker, spin round the marker to the sideline'),
    (2, 'Centre forward (Benzema)', 'read it and show in front of the winger'),
    (3, 'Attacking midfielder (Ozil)', 'safety option for the striker''s lay-off'),
    (4, 'Left full back (Marcelo)', 'push up the flank')
) AS v(so, role, job);

-- 30. pp.67-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Receiving with Your Back to Goal', 'Double-marked winger bounces to holding midfielder',
    'As the ball goes into the winger, two opponents close him; the defensive midfielder shifts across to offer a backward lay-off and then plays forward.',
    'Two defenders collapse onto the receiving winger',
    'Use the overload the opponent committed: the holder finds the striker, the 10, or switches long to the right full back.',
    NULL, 67, 68, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'lay the ball back first time'),
    (2, 'Defensive midfielder (Alonso)', 'shift across under the ball, receive and play forward or switch'),
    (3, 'Right full back (Arbeloa)', 'stay high and wide for the switch'),
    (4, 'Centre forward / No.10', 'show in the gaps the double team opened')
) AS v(so, role, job);

-- 31. pp.69-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Long Passes to Advancing Full Backs', 'Opposite movements, long ball to full back',
    'Left winger checks inside/short while the full back runs up the line; the right back follows the winger, so the centre back lofts the ball down the flank to the advancing full back.',
    'Opposing right back tracks the winger inside',
    'Full back arrives high in space and crosses for striker, 10 and far winger.',
    NULL, 69, 69, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'come short / inside to drag the right back'),
    (2, 'Left full back (Marcelo)', 'sprint up the line into the vacated space and cross'),
    (3, 'Left centre back (Ramos)', 'play the long ball over into the full back''s path'),
    (4, 'Centre forward, No.10, right winger', 'attack near post, centre and far post')
) AS v(so, role, job);

-- 32. pp.70-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Rhombus/diamond Shape in the Central Zone', 'Left-side rhombus around the holder',
    'Building on the left, a diamond forms around the ball: holder at the base (centre back, or the defensive midfielder taking his place), full back wide, winger on top and a midfielder inside (Khedira shifting across or Ozil dropping).',
    'Ball with the left centre back or holding midfielder in build-up',
    'Give the man on the ball three passing angles on the left so combinations stay the same whoever fills each corner.',
    NULL, 70, 71, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Base (Ramos or Alonso)', 'hold the ball at the bottom of the diamond'),
    (2, 'Left full back (Marcelo)', 'left corner, wide'),
    (3, 'Left winger (Ronaldo)', 'top of the diamond'),
    (4, 'Inside corner (Khedira shifting left or Ozil dropping)', 'fill the right-hand corner of the diamond')
) AS v(so, role, job);

-- 33. pp.72-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Defensive Midfielder''s Positioning', 'Holder drops wide-left of centre back',
    'With the centre back in the middle, the two opposition forwards cut the lanes into the 10 and Khedira, so the defensive midfielder drops into the left-back/centre-back space to take the ball unmarked.',
    'Opposition front two screen passes into midfield',
    'Get the ball to an unmarked holder, after which winger, full back and 10 make the left rhombus around him.',
    NULL, 72, 73, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Alonso)', 'drop wide of the centre back, receive free'),
    (2, 'Centre back (Ramos)', 'play into the dropped holder'),
    (3, 'Left winger, left full back, No.10', 'offer rhombus angles once he has it'),
    (4, 'Right midfielder (Khedira)', 'shift to complete the shape')
) AS v(so, role, job);

-- 34. pp.74-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Starting the Build up through the Centre with the Width Created by the Full Backs', 'Central diamond, 10 drops if blocked',
    'Centre back on the ball at the base, the two holding midfielders either side and the 10 on top; full backs give width. The 10 looks to receive between the lines, but drops to make a numerical advantage if lanes are shut.',
    'Centre back in possession centrally, full backs wide',
    'Keep it simple in a dangerous zone; use the dropping 10 as a bounce to free a holding midfielder facing play.',
    NULL, 74, 75, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Ramos)', 'base of the diamond; pass into the 10 or holders'),
    (2, 'Attacking midfielder (Ozil)', 'between the lines; drop to receive and set back when blocked'),
    (3, 'Holding midfielders (Alonso, Khedira)', 'side corners; receive the lay-off and play to winger or full back'),
    (4, 'Full backs', 'hold width for the next pass')
) AS v(so, role, job);

-- 35. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Alonso''s Role: Covering in Defence', 'Holder covers the dribbling centre back',
    'When the centre back carries the ball out to the left, the defensive midfielder drops into the space he vacated; the 10 drops to rebuild the shape and the striker takes the 10''s place, or the 10 goes on top if both left players are wide.',
    'Centre back dribbles out of the back line',
    'Keep defensive balance behind the ball while the rhombus re-forms on the new side.',
    NULL, 76, 76, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Alonso)', 'drop into the centre back''s empty spot'),
    (2, 'Centre back (Ramos)', 'carry the ball wide'),
    (3, 'Attacking midfielder (Ozil)', 'drop to rebuild the diamond, or move to its top'),
    (4, 'Centre forward (Benzema)', 'fill the 10''s space'),
    (5, 'Other midfielder (Khedira)', 'slide to the strong side')
) AS v(so, role, job);

-- 36. pp.77-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Developing the Build up Play through the Centre', 'Vertical-lay-off-diagonal runs from the holder',
    'With the defensive midfielder in possession centrally, a diamond of winger, 10 and striker on top forms; he plays vertically into the striker or 10, who sets it back and the front players run diagonally into the space opened.',
    'Defensive midfielder on the ball in the centre',
    'Third-man combinations that free a runner on a diagonal for the final pass.',
    NULL, 77, 78, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Alonso)', 'play the vertical pass'),
    (2, 'Centre forward (Benzema)', 'top of the diamond; set back first time, then spin diagonally'),
    (3, 'Attacking midfielder (Ozil)', 'receive the set-back, drive inside or pass on and run'),
    (4, 'Wingers (Ronaldo, Di Maria)', 'make diagonal runs inside off the ball')
) AS v(so, role, job);

-- 37. pp.79-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Defensive Midfielder at the Base of the Rhombus Shape', 'Holder as link, everyone into a lane',
    'The opposing forwards block passes into the 10 and Khedira, so the holder drops to collect from the centre back; once he has it centrally the wingers, striker and 10 each move into a passing lane.',
    'Holder receives centrally from the centre back',
    'Ball into a winger driving inside with striker and far winger running in behind for the last pass.',
    NULL, 79, 80, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Alonso)', 'link defence to attack; receive and play forward'),
    (2, 'Left winger (Ronaldo)', 'receive and drive inside, shoot or pass'),
    (3, 'Centre forward (Benzema)', 'run in behind the right back'),
    (4, 'Right winger (Di Maria)', 'diagonal run between the centre backs'),
    (5, 'Centre back (Ramos)', 'take the holder''s spot at the base')
) AS v(so, role, job);

-- 38. pp.81-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Decision Making in the Final Third', 'Final-third options after the forward pass',
    'Once the ball reaches a front player facing goal (via striker first-time, the 10 driving inside, or a winger driving central), the others split: one diagonal run behind, one run behind the near centre back, one option at the edge of the box.',
    'Attacker receives facing goal in the final third',
    'Give the carrier a through ball on each side, a pass outside the box and the shot.',
    NULL, 81, 84, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier (Ozil, Di Maria or Ronaldo)', 'drive towards the centre and choose pass or shot'),
    (2, 'Wingers', 'diagonal runs into free space behind'),
    (3, 'Centre forward (Benzema)', 'run behind the centre back who contests the carrier'),
    (4, 'Attacking midfielder', 'offer a pass outside the box if not carrying')
) AS v(so, role, job);

-- 39. pp.81-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Decision Making in the Final Third', 'Rest defence while attacking the box',
    'As the attack reaches the final third, the holding midfielder stays as safety, centre backs push up and the full backs tuck in towards the centre; a winger or midfielder sits outside the box.',
    'Team commits players into the box',
    'Be compact and ready for the negative transition if the attack breaks down.',
    NULL, 81, 97, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Alonso)', 'stay behind the ball as the safety'),
    (2, 'Centre backs (Ramos, Pepe)', 'step up to shorten the team'),
    (3, 'Full backs', 'converge towards the centre'),
    (4, 'Edge-of-box player (Di Maria / Khedira)', 'hold a spot outside the box for second balls')
) AS v(so, role, job);

-- 40. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Decision Making in the Final Third', 'No.10 lay-off for winger''s diagonal run',
    'The 10 moves into a passing lane, receives and plays first time into the left winger running diagonally into space the dropping striker left; the same combo was used striker-10 when the 10 was on the left.',
    'Centre forward drops and vacates space behind',
    'Winger always attacks the space a dropping striker creates.',
    NULL, 85, 85, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Ozil)', 'step into the lane, receive, first-time pass'),
    (2, 'Left winger (Ronaldo)', 'diagonal run into the space behind'),
    (3, 'Centre forward (Benzema)', 'drop to pull a centre back out'),
    (4, 'Defensive midfielder (Alonso)', 'feed the 10')
) AS v(so, role, job);

-- 41. pp.86-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Starting the Build up on the Right with the Width Created by the Full Back', 'Right rhombus: winger drops, runner behind',
    'Building right with the full back wide: diamond of centre back (base), Khedira, right back and winger on top. The winger drops to outnumber around the ball, opening space behind for the 10 (or Kaka) to run into; or he lays to the full back and spins to the sideline.',
    'Right centre back in possession, winger drops',
    'Exploit space behind the dropping winger with a long pass or a lay-off-and-spin.',
    NULL, 86, 87, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back (Pepe)', 'base; long ball behind or pass to the full back'),
    (2, 'Right winger (Di Maria)', 'drop to receive or drag the full back, then spin to the sideline'),
    (3, 'Right full back (Arbeloa)', 'width; receive when the winger pulls his man'),
    (4, 'Attacking midfielder (Ozil/Kaka)', 'run into the space behind the dropping winger')
) AS v(so, role, job);

-- 42. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'The Right Winger Dropping Deep to Maintain Possession', 'Central right winger drops free',
    'With the right winger starting central and the full back giving width, the ball goes to the full back while the winger drops; if the left back doesn''t follow, the winger receives free.',
    'Opposition left back stays when winger drops',
    'Keep the ball with a free man facing play, with options to the striker, inside or a switch to the left full back.',
    NULL, 88, 88, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'drop to receive unmarked'),
    (2, 'Right full back (Arbeloa)', 'wide; play inside to the winger'),
    (3, 'Centre forward (Benzema)', 'move into the little space behind the winger'),
    (4, 'Left full back (Marcelo)', 'high and wide for the switch')
) AS v(so, role, job);

-- 43. pp.89-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Centre Forward Receiving on the Flank', 'Striker runs behind tracking left back',
    'When the left back follows the dropping right winger, the striker runs in behind him to receive down the right touchline and takes on the centre back 1v1.',
    'Opposition left back tracks the winger''s deep run',
    'Striker beats his man near the touchline and crosses for Ronaldo and Ozil arriving in the box.',
    NULL, 89, 90, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Benzema)', 'run behind the left back, dribble to the line, cross'),
    (2, 'Right winger (Di Maria)', 'drop to drag the left back, then sit outside the box'),
    (3, 'Left winger + No.10 (Ronaldo, Ozil)', 'time runs into the box'),
    (4, 'Right centre back (Pepe)', 'play into the channel'),
    (5, 'Rest of team', 'move up to stay compact')
) AS v(so, role, job);

-- 44. pp.91-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Movement without the Ball: Creating Space', 'Winger and striker swap wide and inside',
    'The right winger goes out to the touchline while the striker comes short in front of the full back; the winger then receives inside while the striker moves out to the sideline, each opening space for the other.',
    'Right full back on the ball with the striker coming short',
    'Winger drives inside with the ball for a diagonal run by the left winger or a long switch to the left full back.',
    NULL, 91, 92, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'go wide, then come inside to receive and drive'),
    (2, 'Centre forward (Benzema)', 'support in front of the full back, then peel to the sideline'),
    (3, 'Right full back (Arbeloa)', 'play into whichever is free'),
    (4, 'Left winger (Ronaldo)', 'diagonal run for the final pass'),
    (5, 'Left full back (Marcelo)', 'high and wide for the switch')
) AS v(so, role, job);

-- 45. pp.93-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Diagonal Runs in the Final Third / Central Midfielder''s Forward Runs', 'Midfielder''s run behind the left back',
    'The right winger goes wide and the striker drops inside; an advanced central midfielder runs into the space behind the left back as the extra attacker. If the centre back picks up the midfielder, the striker is free to turn; if he follows the striker, the midfielder gets the ball down the line.',
    'Winger wide drags the left back, striker drops',
    'Create an extra man on the right and punish whichever choice the centre back makes.',
    NULL, 93, 96, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Khedira)', 'forward run into the space behind the left back'),
    (2, 'Centre forward (Benzema)', 'drop inside with back to goal; turn if left free, then pass to Ronaldo or Khedira'),
    (3, 'Right winger (Di Maria)', 'go to the touchline to pull the left back'),
    (4, 'Right full back (Arbeloa)', 'pick the free man'),
    (5, 'Left winger (Ronaldo)', 'diagonal run for the cross/through ball')
) AS v(so, role, job);

-- 46. pp.97-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Deep Movement: Creating Space in Behind', 'Winger drops, 10 runs behind left back',
    'The right winger drops deep to receive, and the 10 runs into the space behind the left back for a long ball from the centre back; variant: long ball to the striker who heads it on to the running 10. If the winger has room inside he turns and drives instead.',
    'Opposition left back steps up with the dropping winger',
    'No.10 receives in behind and crosses for Ronaldo and Benzema; or winger drives inside for their diagonal runs.',
    NULL, 97, 99, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'drop to receive and pull the left back; drive inside if space'),
    (2, 'Attacking midfielder (Ozil)', 'run in behind the left back, cross'),
    (3, 'Right centre back (Pepe)', 'long pass into the space or onto the striker'),
    (4, 'Centre forward (Benzema)', 'flick on headers, then attack the box'),
    (5, 'Left winger (Ronaldo)', 'attack the box')
) AS v(so, role, job);

-- 47. pp.100-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Central Midfield Passing Options (1 and 2)', 'Recycle through Khedira, then switch',
    'The right winger drops but is crowded with no room inside, or the 10 is marked; the ball goes back to the central midfielder, sometimes after the full back''s forward run opened space for the winger to drop free.',
    'Winger triple-marked / no space inside',
    'Central midfielder plays forward to the striker or switches long to the left full back.',
    NULL, 100, 103, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'drop, receive, lay back when crowded'),
    (2, 'Central midfielder (Khedira)', 'support behind, pick striker, 10 or long switch'),
    (3, 'Right full back (Arbeloa)', 'forward run to clear space for the winger'),
    (4, 'Attacking midfielder (Ozil)', 'support in front of the winger'),
    (5, 'Left full back (Marcelo)', 'stay wide for the switch')
) AS v(so, role, job);

-- 48. pp.101-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', '2 v 1 Attacking Down the Flank', 'Winger and full back 2v1 on right',
    'Winger passes to the advancing right full back; as the left back steps to the full back, the winger runs down the line behind him to get it back.',
    'Opposition left back steps out to the full back',
    'Winger gets in behind, comes inside and whips an inswinging cross for the striker and far winger.',
    NULL, 101, 102, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'pass and run down the line behind the left back, inswinging cross'),
    (2, 'Right full back (Arbeloa)', 'advance, draw the left back, return the ball'),
    (3, 'Centre forward + left winger', 'time runs to meet the cross')
) AS v(so, role, job);

-- 49. pp.104-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Correct Positioning When the Central Midfielder Has Possession', 'Central midfielder as base of right rhombus',
    'When Khedira has the ball he sits at the base of the right-side diamond with the 10 inside, winger on top and full back wide; Alonso supports behind-inside.',
    'Central midfielder on the ball on the right',
    'Same rhombus combinations as when the centre back is the base.',
    NULL, 104, 104, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Khedira)', 'base of the diamond'),
    (2, 'Right winger (Di Maria)', 'top'),
    (3, 'Right full back', 'wide corner'),
    (4, 'Attacking midfielder (Ozil)', 'inside corner'),
    (5, 'Defensive midfielder (Alonso)', 'support behind')
) AS v(so, role, job);

-- 50. pp.105-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Starting the Build up on the Left with Both the Full Back and the Winger Creating Width', 'Both wide on left, 10 tops rhombus',
    'With winger and full back both near the touchline, the 10 shifts across to the top of the rhombus. Combinations: full back-winger one-two, winger dribbles inside as the full back overlaps, 10 runs behind the winger, 10 drops to bounce to the holder, or 10 pass-and-run to the sideline while the winger drives inside.',
    'Left winger and full back both wide',
    'Stretch the opponent and create overlaps and third-man runs on the left.',
    NULL, 105, 106, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left full back (Marcelo)', 'one-two with the winger, overlap when he goes inside'),
    (2, 'Left winger (Ronaldo)', 'combine, dribble inside to shoot or pass'),
    (3, 'Attacking midfielder (Ozil)', 'move left to top the diamond; run behind the winger or drop to bounce'),
    (4, 'Left centre back (Ramos)', 'base; feed the full back or the dropping 10'),
    (5, 'Defensive midfielder (Alonso)', 'receive the set-back')
) AS v(so, role, job);

-- 51. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', '2 v 2 Attacking Down the Left Flank', 'Winger checks to ball, then spins behind',
    'Opponent shifts across to the left; the winger moves towards the full back on the ball, the right back follows, and the winger turns and runs into the space he created to receive in behind.',
    'Right back follows the winger''s check towards the ball',
    'Winger gets behind the right back and attacks the byline, with striker and right winger in the box and Khedira outside it.',
    NULL, 107, 107, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'check to the ball, then spin in behind'),
    (2, 'Left full back (Marcelo)', 'play the ball in behind'),
    (3, 'Centre forward + right winger', 'enter the box'),
    (4, 'Central midfielder (Khedira)', 'edge of the box')
) AS v(so, role, job);

-- 52. pp.108-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', '2 v 2 Attacking Down the Left Flank', 'Left 2v2 combos when space near ball',
    'When the opponent does not shift over, there is room around the ball: winger drops, full back plays a give-and-go and drives inside; or full back passes and overlaps while the winger drives inside to the 10 who returns it first time; or the 10 drops (taking his marker) to open space for the winger; or the striker drops for a square pass.',
    'Opponent fails to shift to the ball side',
    'Exploit the space by the ball with one-twos and overlaps that end in a final pass for Ronaldo or Benzema.',
    NULL, 108, 112, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left full back (Marcelo)', 'give-and-go, driving run, or overlap'),
    (2, 'Left winger (Ronaldo)', 'drop to receive, drive inside'),
    (3, 'Attacking midfielder (Ozil)', 'drop to drag a marker or return first time to the overlapping full back'),
    (4, 'Centre forward (Benzema)', 'diagonal run behind, or drop for a square pass')
) AS v(so, role, job);

-- 53. pp.113-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Switching Play to the Right Flank', 'Compact shift left, switch right',
    'The opponent shifts compactly to the left and crowds the ball zone; the triple-marked winger plays back to the dropping 10, or the holder shifts across to receive in the centre, and from there four options open including a long switch to the right.',
    'Opponent''s compact shift towards the left touchline',
    'Leave the crowded side and attack the right full back, right winger or Khedira, or go to the striker for the third stage.',
    NULL, 113, 115, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Ozil)', 'drop to give a backward option, then pick the pass'),
    (2, 'Defensive midfielder (Alonso)', 'shift across / drop deeper to receive centrally'),
    (3, 'Right full back (Arbeloa)', 'high and wide for the long switch'),
    (4, 'Central midfielder (Khedira)', 'free in the centre-right'),
    (5, 'Centre forward (Benzema)', 'show for the pass that unlocks stage three')
) AS v(so, role, job);

-- 54. pp.116-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ronaldo''s Driving Runs from the Left', 'Winger comes inside for diagonal pass',
    'The opposing right midfielder blocks the vertical pass to the winger and the 10 is too far away, so the winger comes inside to take a diagonal pass from the full back and keeps running at goal.',
    'Vertical lane to the winger blocked',
    'Winger drives at goal with the 10 running behind the right back, the striker and right winger as options, or shoots.',
    NULL, 116, 116, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'come inside, receive the diagonal pass, drive at goal'),
    (2, 'Left full back (Marcelo)', 'play the diagonal pass inside'),
    (3, 'Attacking midfielder (Ozil)', 'run in behind the right back'),
    (4, 'Centre forward + right winger', 'offer passing options in the box')
) AS v(so, role, job);

-- 55. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch4 Build-up on the left with both full back and winger wide - Assessment', 'Stretch them or switch when compact',
    'Width from full back and winger forces the opponent to stretch to mark; a compact, well-shifting block instead leaves the far side open.',
    'Opponent stretches vs opponent stays compact and shifts',
    'Attack the space near the ball if they stretch, otherwise play out on the strong side or switch to the free weak side.',
    NULL, 117, 117, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back + winger', 'Hold width on the ball side to stretch the block'),
    (2, 'Central midfielders', 'Read compactness and choose strong-side play or the switch'),
    (3, 'Weak-side players', 'Stay available for the switch')
) AS v(so, role, job);

-- 56. pp.118-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Attacking Midfielder Receiving Vertical Passes from Central Defenders', 'Double-marked 10 bounces to free full back',
    'Centre back plays vertically into the 10 (Ozil) behind the midfield line; two opponents close him, but the winger''s run has emptied the flank.',
    'Two defenders collapse on the 10 after the vertical pass',
    'First-time pass out to the advancing full back in the vacated wide space, who drives at the box with options.',
    NULL, 118, 119, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (Ramos)', 'Vertical pass into the 10 between the lines'),
    (2, 'Attacking midfielder (Ozil)', 'One-touch lay wide to the full back'),
    (3, 'Left winger (Ronaldo)', 'Run inside/forward to pull the right back and open the flank'),
    (4, 'Left back (Marcelo)', 'Drive into the space, choose winger, CF diagonal or square support'),
    (5, 'Holding midfielder (Alonso)', 'Shift to the strong side as support'),
    (6, 'Centre forward (Benzema)', 'Diagonal run for the final ball or square support')
) AS v(so, role, job);

-- 57. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Attacking Midfielder Receiving Vertical Passes - Example 2', '10 releases winger behind full back',
    'After the vertical pass from the centre back, the winger runs in behind the opposing right back; if the right back blocks that lane, the space he leaves is used by the 10.',
    'Winger beats the right back with a run in behind; or the right back blocks the lane',
    'First-time through pass to the winger, or the 10 dribbles out to the flank and takes on the 1v1.',
    NULL, 120, 120, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Ozil)', 'First-time ball behind the full back, or carry towards the free flank'),
    (2, 'Left winger (Ronaldo)', 'Run in behind the right back'),
    (3, 'Left back (Marcelo)', 'Push on in support'),
    (4, 'Holding midfielder (Alonso)', 'Drop/shift to cover')
) AS v(so, role, job);

-- 58. pp.121-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Attacking Midfielder Receiving Vertical Passes - Example 3', 'Winger frees himself, 10 overlaps outside',
    'Pass goes to the 10 between the lines; the winger shakes his marker to receive free down the flank and the 10 moves out towards the touchline to make a 2v1.',
    'Winger receives unmarked wide; right back''s reaction decides the branch',
    'Winger releases the overlapping 10 to cross, or if the back pass is blocked he drives inside for a pass to the 10, CF or a right-foot shot.',
    NULL, 121, 122, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Lose marker, receive wide, drive inside if the lane back is shut'),
    (2, 'Attacking midfielder (Ozil)', 'Run outside to the touchline to overload, then cross'),
    (3, 'Centre forward (Benzema)', 'Diagonal run into the box'),
    (4, 'Far winger (Di Maria)', 'Attack the far side of the box')
) AS v(so, role, job);

-- 59. pp.123-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Attacking Midfielder Receiving Vertical Passes - Example 4', '10 turns and runs at the back four',
    'The 10 receives between the lines with room to turn inside and face the defence.',
    'First touch inside facing goal',
    'CF and far winger make diagonal runs; the 10 picks the diagonal or square ball into the box area.',
    NULL, 123, 123, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Ozil)', 'Turn inside on the first touch and drive at the back four'),
    (2, 'Centre forward (Benzema)', 'Diagonal run behind the centre backs'),
    (3, 'Far winger (Di Maria)', 'Diagonal run inside to receive diagonal or square pass'),
    (4, 'Holding midfielder (Alonso)', 'Follow up behind as support')
) AS v(so, role, job);

-- 60. pp.124-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Attacking Midfielder: Dropping Deep to Receive', '10 drops in front, then switch long',
    'No lane to receive behind the midfield line, so the 10 drops in front of it to give the centre back an option; he cannot turn and plays back to the holder.',
    'No passing lane behind the opposition midfielders',
    'The narrowed opponent leaves the touchlines empty, so the holder recycles to the centre back or hits a long diagonal to the far full back.',
    NULL, 124, 125, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Ozil)', 'Drop in front of the midfield line, lay off to the holder'),
    (2, 'Holding midfielder (Alonso)', 'Receive facing play, choose back to centre back or long switch'),
    (3, 'Far full back (Arbeloa)', 'Hold width high for the long diagonal'),
    (4, 'Far centre back (Pepe)', 'Safe recycle option')
) AS v(so, role, job);

-- 61. pp.126-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Starting the Build up on the Right with Both the Winger and the Full Back Creating Width', 'Right-side rhombus with double width',
    'Winger and full back are both near the touchline on the right; the near-ball rhombus is completed by the centre forward dropping or the 10 shifting across to its top.',
    'Full back and winger both wide on the ball side',
    'Keep a rhombus of passing angles (centre back base, full back and DM sides, CF/10 top) next to the ball.',
    NULL, 126, 126, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria) + right back (Arbeloa)', 'Both hold the touchline'),
    (2, 'Centre forward (Benzema) or 10 (Ozil)', 'Drop or slide across to top of the rhombus'),
    (3, 'Defensive midfielder (Khedira)', 'Inside point of the rhombus'),
    (4, 'Right centre back (Pepe)', 'Base of the rhombus')
) AS v(so, role, job);

-- 62. pp.127-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Wingers Movement inside without the Ball', 'Winger drops inside, CF attacks the flank',
    'From the double-width right side, the winger checks back and inside to receive, pulling the opposing left back with him and emptying the flank.',
    'Opposing left back follows the winger inside (or does not)',
    'If followed, the full back plays the CF into the flank to win the 1v1 and cross; if not followed, the winger receives free, dribbles inside and finds the CF, a diagonal 10 run or an in-swinging cross.',
    NULL, 127, 130, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'Drop back and inside to drag the left back; receive free if unmarked'),
    (2, 'Centre forward (Benzema)', 'Run into the vacated flank, win 1v1, cross'),
    (3, 'Right back (Arbeloa)', 'Pass down the line into the CF''s run'),
    (4, 'Attacking midfielder (Ozil)', 'Drop to set the ball back for a switch, or diagonal run into the box'),
    (5, 'Far winger (Ronaldo)', 'Get between the centre backs for the cross'),
    (6, 'Rest of the team', 'Position for the negative transition')
) AS v(so, role, job);

-- 63. pp.131-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Limited Space in between the Midfield and Defensive Lines', 'Drop to receive, lay off, switch',
    'Opponent shuts the space between its lines; the CF (or 10) drops short to receive from the full back and lays it straight to the defensive midfielder.',
    'No space between the lines near the ball',
    'The DM, facing play, has several options and usually switches to the free far full back.',
    NULL, 131, 132, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Benzema) / 10 (Ozil)', 'Drop off the line, receive and lay off first time'),
    (2, 'Defensive midfielder (Khedira)', 'Receive facing forward, find the switch or a vertical pass'),
    (3, 'Far full back (Marcelo)', 'Advance high and wide for the switch'),
    (4, 'Holding midfielder (Alonso)', 'Extra central option for circulation')
) AS v(so, role, job);

-- 64. pp.133-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Limited Space in between the Lines - Example 3', '10 drags midfielder, CF finds gap',
    'The 10 is nearer the strong side and moves to support; the opposing No.8 follows and opens a gap in midfield.',
    'Opposing midfielder tracks the 10''s movement',
    'DM plays straight into the CF in the gap, who dribbles right and plays a diagonal to the winger running behind the left back while Ronaldo attacks the box.',
    NULL, 133, 134, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Ozil)', 'Move towards the ball to pull the No.8 away'),
    (2, 'Defensive midfielder (Khedira)', 'Pass immediately into the CF in the gap'),
    (3, 'Centre forward (Benzema)', 'Receive in the gap, carry right, diagonal pass'),
    (4, 'Right winger (Di Maria)', 'Run in behind the left back'),
    (5, 'Far winger (Ronaldo)', 'Enter the box for the cross'),
    (6, 'Rest of the team', 'Step up to stay compact for transition')
) AS v(so, role, job);

-- 65. pp.135-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Full Back''s Advancing Run', 'Full back goes when winger is blocked',
    'The passing lane to the winger is cut off by the opposing left back and centre back, so the right back advances and receives high to cross.',
    'Lane to the winger closed',
    'Right back crosses into the box; the DM shifts right to cover the space behind the advanced winger and full back.',
    NULL, 135, 135, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'Advance and receive in a crossing position'),
    (2, 'Right winger (Di Maria)', 'Occupy defenders, attack the box'),
    (3, 'Defensive midfielder (Khedira)', 'Cover towards the right'),
    (4, 'Far full back (Marcelo)', 'Push up on the weak side')
) AS v(so, role, job);

-- 66. pp.136-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Receiving in the ''Passing Lane''', 'Far winger steps into the lane',
    'The far winger (Ronaldo) moves inside into the lane between the opposition midfielders; the right back stays back to keep balance because Marcelo is advancing.',
    'Winger unmarked between the midfielders',
    'He receives free and dribbles to the centre; options are vertical to the CF, diagonal to the far winger or a short one-two with the 10.',
    NULL, 136, 136, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Move inside into the passing lane, receive and drive centrally'),
    (2, 'Centre forward (Benzema)', 'Vertical option'),
    (3, 'Right winger (Di Maria)', 'Diagonal run on the far side'),
    (4, 'Attacking midfielder (Ozil)', 'Short option for a one-two'),
    (5, 'Holding midfielder (Alonso)', 'Step up as the safety player')
) AS v(so, role, job);

-- 67. pp.137-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Switching Play to the Left Flank', 'Winger drops, full back free wide',
    'Ronaldo drops inside again but this time the right back follows him, leaving the left flank empty.',
    'Opposing right back tracks the dropping winger',
    'Ball is switched to Marcelo totally unmarked on the flank for an out-swinging cross to four runners in or around the box.',
    NULL, 137, 137, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Drop inside to pull the right back away'),
    (2, 'Left back (Marcelo)', 'Receive unmarked high and wide, cross'),
    (3, 'Box attackers (Ronaldo, Benzema, Ozil, Di Maria)', 'Fill the box and its edge'),
    (4, 'Holding midfielder (Alonso)', 'Cover for both full back and winger')
) AS v(so, role, job);

-- 68. pp.138-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Right Winger''s Inside Runs', 'CF sets, then drags full back inside',
    'CF drops, receives from the centre back and passes out to the right winger, then runs inside to pull the left back and open space.',
    'Left back follows the CF''s inside run',
    'Winger dribbles inside into the freed space and whips an in-swinging cross to Ronaldo arriving in the box.',
    NULL, 138, 139, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Benzema)', 'Drop, set to the winger, run inside to drag the left back'),
    (2, 'Right winger (Di Maria)', 'Dribble inside and cross in-swinging'),
    (3, 'Far winger (Ronaldo)', 'Attack the box'),
    (4, 'Defensive midfielder (Khedira) + right back (Arbeloa)', 'Safety players behind the ball')
) AS v(so, role, job);

-- 69. pp.140-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Right Winger''s Inside Runs - Example 2', '10 turns, passes wide and overlaps',
    'Kaka finds the lane behind the midfielders on the right; the opposing left centre back and left back are tied to direct opponents, so he has time to turn.',
    '10 receives between lines with defenders pinned',
    'He gives to the winger and runs past him to overload; if the left back blocks that, the winger cuts inside and crosses for Ronaldo and Higuain.',
    NULL, 140, 141, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Kaka)', 'Receive in the lane, turn, pass wide and run beyond'),
    (2, 'Right winger (Di Maria)', 'Use the overlap or dribble inside and cross'),
    (3, 'Strikers (Ronaldo, Higuain)', 'Take crossing positions'),
    (4, 'Right back (Arbeloa) + DM (Khedira)', 'Safety players'),
    (5, 'Rest of the team', 'Prepare for the negative transition')
) AS v(so, role, job);

-- 70. pp.142-143
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Starting the Build up on the Left with the Width Created by the Winger', 'Left rhombus with winger width',
    'When Ronaldo holds the left touchline, the rhombus is Marcelo at the base, Ronaldo and Ozil on the sides and the CF at the top; this mostly arises after a switch from right to left.',
    'Winger provides the width on the left',
    'Marcelo tucks in so Alonso can push higher; combinations are give-and-go forward, Marcelo overlapping as Ronaldo dribbles inside, and Ronaldo''s wall pass with the striker.',
    NULL, 142, 143, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'Base of the rhombus, tucked in; pass and move forward or overlap'),
    (2, 'Left winger (Ronaldo)', 'Hold the line, dribble inside, use wall passes'),
    (3, 'Attacking midfielder (Ozil)', 'Inside side of the rhombus'),
    (4, 'Centre forward (Benzema/Higuain)', 'Top of the rhombus, wall-pass partner'),
    (5, 'Holding midfielder (Alonso)', 'Push higher, covered by Marcelo''s inside position')
) AS v(so, role, job);

-- 71. pp.144-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Switching Play from the Right to the Left / Full Back''s Overlapping Runs on the Flank', 'Switch left, full back runs inside',
    'After a right-to-left switch both teams slide left; Marcelo passes to Ronaldo and runs inside while Benzema drops and drags the left centre back out.',
    'Ball arrives at the left back after the switch',
    'Marcelo receives in behind on the flank and crosses for Di Maria and Ozil, with Ronaldo for a cut-back.',
    NULL, 144, 145, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'Pass to winger, run inside, receive behind and cross'),
    (2, 'Left winger (Ronaldo)', 'Return pass in behind, then take cut-back position'),
    (3, 'Centre forward (Benzema)', 'Drop a few yards to drag a centre back, then edge of box'),
    (4, 'Holding midfielder (Alonso)', 'Shift left as safety'),
    (5, 'Rest of the team', 'Move up for the negative transition')
) AS v(so, role, job);

-- 72. pp.146-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Diagonal Runs in behind the Defensive Line', 'Centre back follows runner, CF freed',
    'Same left-side move but the opposing centre back shifts across to mark Marcelo''s forward run, leaving the dropping CF unmarked.',
    'Centre back leaves the CF to track the full back',
    'CF turns and plays the far winger''s diagonal run behind the line or the 10 into the space it opens.',
    NULL, 146, 146, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'Pass to winger and run forward to pull the centre back'),
    (2, 'Centre forward (Benzema)', 'Drop, receive unmarked, turn, play the final ball'),
    (3, 'Right winger (Di Maria)', 'Diagonal run behind the defensive line'),
    (4, 'Attacking midfielder (Ozil)', 'Run into the space left by the diagonal runner')
) AS v(so, role, job);

-- 73. pp.147-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'The Full Back Creating Space for the Winger', 'Overlap as winger dribbles inside',
    'Ronaldo receives and dribbles towards the centre; Marcelo overlaps to make a 2v1 on the flank while Benzema moves to receive and opens space for Ozil.',
    'Winger carries inside',
    'Ronaldo picks the overlapping full back or the 10 running into the space.',
    NULL, 147, 147, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Dribble inside, choose overlap or 10'),
    (2, 'Left back (Marcelo)', 'Overlap to create the 2v1'),
    (3, 'Centre forward (Benzema)', 'Move to receive and pull a defender away'),
    (4, 'Attacking midfielder (Ozil)', 'Run into the vacated space')
) AS v(so, role, job);

-- 74. pp.148-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'One Touch Combination Play on the Left / Ronaldo''s Final Pass in behind the Defence', 'Wall pass to escape right back pressure',
    'Ronaldo is pressed by the right back as he receives; Benzema comes across into the space behind/beside him.',
    'Right back stops the winger driving inside',
    'One-touch give-and-go with the CF, Ronaldo gets the return inside and then plays Benzema opening up left, a one-two with Ozil or a diagonal runner behind the defence.',
    NULL, 148, 150, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Pass to the CF, run inside, take the return and drive'),
    (2, 'Centre forward (Benzema)', 'Move across to support, one-touch return, then open up left'),
    (3, 'Attacking midfielder (Ozil)', 'Second one-two option'),
    (4, 'Right winger (Di Maria)', 'Diagonal run in behind'),
    (5, 'Left back (Marcelo) + holding mid (Alonso)', 'Take safety positions')
) AS v(so, role, job);

-- 75. pp.151-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Starting the Build up on the Right with the Width Created by the Winger', 'Right side, winger wide, back tucked',
    'Arbeloa starts inside and Di Maria provides the width; rhombus with Khedira, Ozil and Higuain.',
    'Ball to the right back with the winger wide',
    'Arbeloa overlaps as Di Maria dribbles inside, or Di Maria checks back to receive and Arbeloa runs forward past him.',
    NULL, 151, 151, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'Start inside; pass then overlap or run forward'),
    (2, 'Right winger (Di Maria)', 'Hold width, dribble inside or drop to receive'),
    (3, 'Defensive midfielder (Khedira)', 'Inside support point'),
    (4, 'Centre forward (Higuain)', 'Top of the shape')
) AS v(so, role, job);

-- 76. pp.152-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'The Right Winger Receiving the Ball Deep on the Flank', 'Full back runs past deep-receiving winger',
    'After a left-to-right switch both teams slide right; Di Maria receives near the touchline and Arbeloa runs inside past him to overload the left back.',
    'Winger receives deep and wide after the switch',
    'Return to the running full back to cross; if the left back blocks the direct pass, go via the CF; if the left winger tracks the full back, Di Maria dribbles inside with diagonal runs and a Kaka one-two available.',
    NULL, 152, 156, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'Pass and run inside or overlap to create a 2v1, then cross'),
    (2, 'Right winger (Di Maria)', 'Receive wide, release the full back or cut inside'),
    (3, 'Centre forward (Higuain)', 'Support as relay, open up or diagonal run'),
    (4, 'Attacking midfielder (Kaka)', 'Edge of box / one-two option'),
    (5, 'Far winger (Ronaldo)', 'Attack the box, diagonal run'),
    (6, 'Defensive midfielder (Khedira)', 'Safety player, shift right')
) AS v(so, role, job);

-- 77. pp.157-157
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'The Right Winger Receiving the Ball Deep - Example 5', 'Overload stopped, recycle to weak side',
    'The opponent copes with the flank overload (winger tracks the overlapping full back).',
    'Flank 2v1 is neutralised',
    'Winger plays back to the supporting DM who switches long to the far full back; the 10 offers a between-lines option.',
    NULL, 157, 157, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'Play back inside to the DM'),
    (2, 'Defensive midfielder (Khedira)', 'Supporting position, switch to the weak side'),
    (3, 'Far full back (Marcelo)', 'High and wide for the switch'),
    (4, 'Attacking midfielder (Kaka)', 'Option between the lines')
) AS v(so, role, job);

-- 78. pp.158-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'The Right Winger Receiving the Ball Deep - Example 4', 'Striker run behind full back opens lane',
    'Arbeloa stays as support behind Di Maria; Higuain runs into the space behind the left back to give the winger room.',
    'Left back blocks the pass to the striker but leaves space inside',
    'Di Maria dribbles inside; Kaka takes the space Higuain vacated, Ronaldo makes a diagonal run between right back and centre back for an in-swinger.',
    NULL, 158, 158, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'Stay in support behind the winger'),
    (2, 'Centre forward (Higuain)', 'Run behind the left back to drag him and open space'),
    (3, 'Right winger (Di Maria)', 'Dribble inside, pass or cross'),
    (4, 'Attacking midfielder (Kaka)', 'Move into the vacated space'),
    (5, 'Far winger (Ronaldo)', 'Diagonal run between right back and centre back')
) AS v(so, role, job);

-- 79. pp.160-161
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 The Long Pass is Directed towards the Left Side and the Full Back Provides Width', 'Long switch to full back, winger supports',
    'When the opponent squeezes the centre, Real hit long passes to the weak side; Marcelo receives the long ball from Pepe/Alonso and Ronaldo supports in front of him.',
    'Opponent narrow and compact in the middle',
    'Ronaldo either gives a return to Marcelo running inside, drops deep to receive, or moves opposite to Marcelo to clear the flank for him to receive high.',
    NULL, 160, 161, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Far centre back (Pepe) / holding mid (Alonso)', 'Long diagonal to the weak-side full back'),
    (2, 'Left back (Marcelo)', 'Receive wide; pass and go inside or run into space ahead'),
    (3, 'Left winger (Ronaldo)', 'Support in front, drop deep or move inside to create space')
) AS v(so, role, job);

-- 80. pp.162-165
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Long Pass: Switching Play to the Left Back with Time and Space', 'Winger drops inside for switched full back',
    'Marcelo receives the long switch with time; the opposing winger comes to close him and the right back covers, so Ronaldo drops inside to receive free (or into the lane between right back and winger if the right back stays).',
    'Opponent shifts and stays balanced after the switch',
    'Ronaldo gets the ball with the short pass to Kaka or diagonal runs by Higuain/Di Maria for an in-swinger; otherwise Marcelo advances into the space and crosses for Higuain and Kaka.',
    NULL, 162, 165, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'Receive the switch, advance into space and cross if winger drops'),
    (2, 'Left winger (Ronaldo)', 'Drop towards the centre/midfield to receive; stay central (rarely goes to the touchline)'),
    (3, 'Attacking midfielder (Kaka)', 'Short option to turn or one-two'),
    (4, 'Strikers (Higuain, Di Maria)', 'Diagonal runs for the in-swinging cross'),
    (5, 'Holding midfielder (Alonso)', 'Safety position, shift left')
) AS v(so, role, job);

-- 81. pp.166-169
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Long Pass: Switching Play to the Left Back - Example 4 and Assessment', 'Full back give-and-go in behind',
    'Marcelo gets the switch wide and deep; Ronaldo cannot turn under pressure from the centre back so returns it to Marcelo running past.',
    'Winger receives inside with a defender tight behind',
    'Marcelo receives in behind with three options: Ronaldo, Kaka into the free central space, or Higuain''s diagonal run.',
    NULL, 166, 169, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'Pass inside and run beyond for the return'),
    (2, 'Left winger (Ronaldo)', 'Lay the ball back first time, then attack the box'),
    (3, 'Attacking midfielder (Kaka)', 'Exploit the free central space'),
    (4, 'Centre forward (Higuain)', 'Diagonal run'),
    (5, 'Holding midfielder (Alonso)', 'Safety player')
) AS v(so, role, job);

-- 82. pp.168-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Long Pass: Switching Play to the Left Back - Example 5', 'Full back carries inside when winger marked',
    'Ronaldo drops to receive but the opposing winger blocks the pass to him.',
    'Pass to the dropping winger is cut off',
    'Marcelo dribbles inside himself; Higuain runs diagonally behind the line and Kaka offers between the lines.',
    NULL, 168, 168, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'Carry the ball inside towards the centre'),
    (2, 'Centre forward (Higuain)', 'Diagonal run behind the defensive line'),
    (3, 'Attacking midfielder (Kaka)', 'Receive between the lines'),
    (4, 'Left winger (Ronaldo)', 'Drop to pull the opposing winger')
) AS v(so, role, job);

-- 83. pp.170-171
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'The Long Pass is Directed towards the Left and the Winger Provides the Width', 'Long ball to wide winger, runner beyond',
    'The long switch goes to Ronaldo near the touchline; Marcelo runs ahead of him behind the right back or towards the box edge, or overlaps as Ronaldo dribbles inside.',
    'Winger receives the switch wide',
    'Release the runner behind the full back; if Marcelo is too deep, the CF runs into the space behind the right back instead.',
    NULL, 170, 171, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Far centre back (Pepe)', 'Long diagonal to the winger'),
    (2, 'Left winger (Ronaldo)', 'Receive wide, dribble inside, release the runner'),
    (3, 'Left back (Marcelo)', 'Run ahead behind the right back or overlap'),
    (4, 'Centre forward (Benzema)', 'Run into the channel behind the right back when the full back is far')
) AS v(so, role, job);

-- 84. pp.172-174
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ronaldo in Space on the Left Flank', 'Isolate winger 1v1 after the switch',
    'Long ball to Ronaldo wide left when the opposing right winger is too far from his right back to help.',
    'Right back isolated without winger support',
    'Ronaldo beats the right back and crosses to Higuain/Di Maria or passes inside to Kaka; or Marcelo makes an inside run behind the right back during the ball''s flight and Ronaldo slips him in.',
    NULL, 172, 174, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Take on the right back 1v1, cross or pass inside'),
    (2, 'Left back (Marcelo)', 'Inside run behind the right back while the long ball travels'),
    (3, 'Strikers (Higuain, Di Maria)', 'Attack the box for the cross'),
    (4, 'Attacking midfielder (Kaka)', 'Inside option at the box edge'),
    (5, 'Far centre back (Pepe)', 'Long switch')
) AS v(so, role, job);

-- 85. pp.175-175
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 Ronaldo in Space on the Left Flank', 'Full back cross or cut-back to winger',
    'After the long switch reaches the left, Marcelo has the ball wide and can cross to the far post or slide it to Ronaldo just outside the box.',
    'Marcelo on ball wide in the final third',
    'Finish from a far-post cross or Ronaldo''s shot from the box edge while Alonso secures behind.',
    NULL, 175, 175, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'cross far post or cut back outside the box'),
    (2, 'Left winger (Ronaldo)', 'hold position on edge of box for the cut-back'),
    (3, 'Defensive midfielder (Alonso)', 'shift left to give safety'),
    (4, 'Rest of team', 'set up for the negative transition')
) AS v(so, role, job);

-- 86. pp.176-177
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 The Full Back in the Final Third', 'Striker drifts wide, full back drives inside',
    'Long switch from Pepe finds Ronaldo wide left; Higuain drifts out to the touchline taking his marker, which opens the inside lane for Marcelo.',
    'Opponent winger able to double Ronaldo',
    'Marcelo carries into the vacated half-space and plays Higuain or a Kaka one-two.',
    NULL, 176, 177, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'receive switch, lay inside to Marcelo'),
    (2, 'Centre forward (Higuain)', 'move to sideline to receive and empty the centre'),
    (3, 'Left back (Marcelo)', 'run with the ball towards goal through the gap'),
    (4, 'Attacking midfielder (Kaka)', 'come across for a one-two'),
    (5, 'Defensive midfielder (Alonso)', 'slide left for safety')
) AS v(so, role, job);

-- 87. pp.178-179
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 Full Back''s Overlapping Run on the Left Flank', 'Winger cuts in, full back overlaps, 9 drops',
    'Ronaldo carries inside as Marcelo overlaps; Higuain drops off unmarked between the lines while the opponent''s centre back has to retreat to stop a 2v1 wide.',
    'Ronaldo receives the switch and turns inside',
    'Pass into the free dropping striker (who then has three options) or, if the centre back steps out to him, release the overlapping full back to cross for Kaka and Di Maria.',
    NULL, 178, 179, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'dribble inside, choose Higuain or Marcelo'),
    (2, 'Left back (Marcelo)', 'overlap outside and cross'),
    (3, 'Centre forward (Higuain)', 'drop deep inside to receive unmarked'),
    (4, 'Kaka / Di Maria', 'attack the box for the cross'),
    (5, 'Defensive midfielder (Alonso)', 'cover the overlap')
) AS v(so, role, job);

-- 88. pp.180-180
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 Centre Forward Runs in behind the Right Back', 'Striker runs channel, winger isolates full back',
    'Marcelo is too deep to get ahead of Ronaldo, so Higuain runs into the channel behind the right back; the centre back follows him and the right back is left alone.',
    'Full back too deep to support ahead of the winger',
    'Ronaldo drives inside 1v1 with options to Higuain, Kaka or a shot.',
    NULL, 180, 180, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Higuain)', 'run wide behind the right back and drag the centre back'),
    (2, 'Left winger (Ronaldo)', 'dribble inside at the uncovered full back'),
    (3, 'Attacking midfielder (Kaka)', 'offer a central pass'),
    (4, 'Left back (Marcelo)', 'stay deep')
) AS v(so, role, job);

-- 89. pp.181-181
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 The Long Pass towards the Left with Both the Full Back and the Winger Providing Width', 'Both wide on left: overlap or diagonal inside run',
    'With Ronaldo and Marcelo both wide after a long switch, Ronaldo carries inside and Marcelo either overlaps outside or runs diagonally inside.',
    'Ronaldo receives the switch and carries inside',
    'Marcelo receives in behind wide or just outside the penalty area.',
    NULL, 181, 181, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Pepe)', 'long diagonal switch to the left'),
    (2, 'Left winger (Ronaldo)', 'carry inside then release'),
    (3, 'Left back (Marcelo)', 'overlap or diagonal run inside to box edge')
) AS v(so, role, job);

-- 90. pp.182-182
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 Positioning for the Negative Transition', 'Overlap draws full back, winger beats winger inside',
    'Marcelo overlaps during the ball''s flight; the opponent full back picks him up, leaving Ronaldo against the retreating winger, who cannot close him in time.',
    'Long ball in flight to Ronaldo',
    'Ronaldo dribbles inside with three passing options while Alonso and the rest are already placed to react to a loss.',
    NULL, 182, 182, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'overlap during the pass flight'),
    (2, 'Left winger (Ronaldo)', 'dribble inside past the winger'),
    (3, 'Defensive midfielder (Alonso)', 'take a safety position'),
    (4, 'Rest of team', 'position to counter-press if the ball is lost')
) AS v(so, role, job);

-- 91. pp.183-184
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 Diagonal Runs/Passes in the Final Third', 'Full back diagonal run off double team',
    'The opponent winger is well placed and doubles Ronaldo with the full back; Higuain widens to stretch them and Marcelo runs diagonally inside.',
    'Ronaldo double marked on the flank',
    'Marcelo receives centrally and slips one of two runners in behind the line.',
    NULL, 183, 184, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'draw two defenders, pass inside to Marcelo'),
    (2, 'Centre forward (Higuain)', 'move to the sideline to stretch the back line'),
    (3, 'Left back (Marcelo)', 'diagonal run inside, dribble at goal'),
    (4, 'Kaka / Di Maria', 'make runs in behind for the through pass')
) AS v(so, role, job);

-- 92. pp.185-186
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 The Long Pass Is Directed towards the Right and the Full Back Provides Width', 'Right back wide, winger comes short',
    'On a switch right with Arbeloa holding width, Di Maria either runs down the flank in front of him or checks back to support, freeing space for Benzema''s run to the flank or Khedira''s forward run.',
    'Long switch to Arbeloa on the right',
    'Arbeloa receives high with two options: the runner in behind or Di Maria short.',
    NULL, 185, 186, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'hold width and receive the switch'),
    (2, 'Right winger (Di Maria)', 'run down the line or drop to support'),
    (3, 'Centre forward (Benzema)', 'run out to the flank'),
    (4, 'Central midfielder (Khedira)', 'push into the vacated space'),
    (5, 'Centre back / DM (Ramos, Alonso)', 'play the long switch')
) AS v(so, role, job);

-- 93. pp.187-188
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 Right Winger with Back to Goal on the Flank', 'Winger receives on line, turns, in-swinger',
    'After a switch to Arbeloa, Di Maria moves into space near the sideline and receives with his back to goal while the team shifts across.',
    'Arbeloa receives switch, Di Maria free near touchline',
    'Di Maria turns and whips an in-swinging cross to Higuain and Ronaldo, with Khedira running inside as another option.',
    NULL, 187, 188, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'receive near sideline, turn and cross'),
    (2, 'Right back (Arbeloa)', 'pass up the line'),
    (3, 'Higuain / Ronaldo', 'attack the box'),
    (4, 'Central midfielder (Khedira)', 'inside run as extra option'),
    (5, 'Whole team', 'slide towards the ball side')
) AS v(so, role, job);

-- 94. pp.189-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 Centre Forward Runs in behind the Left Back', 'Midfielder or striker runs behind left back',
    'Di Maria drops to receive, so the left back steps or drops; Khedira (or in example 2 Higuain) runs in behind the left back towards the line.',
    'Winger checks back pulling the left back''s attention',
    'The runner receives behind the full back and crosses for Ronaldo/Higuain at the near/penalty spot or Kaka at the far post or box edge.',
    NULL, 189, 192, 940)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'carry forward and play in behind'),
    (2, 'Right winger (Di Maria)', 'drop back to drag the full back'),
    (3, 'Central midfielder (Khedira)', 'inside run behind the left back, then cross'),
    (4, 'Centre forward (Higuain)', 'run behind towards sideline (example 2) or attack box'),
    (5, 'Attacking midfielder (Kaka)', 'edge of box / far post')
) AS v(so, role, job);

-- 95. pp.193-194
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 The Long Pass Is Directed towards the Right and the Winger Provides Width', 'Winger wide, full back inside or overlap',
    'When Di Maria holds the width and Arbeloa sits narrower, Arbeloa runs inside behind the left back, or overlaps as Di Maria drives inside; if Arbeloa is too deep, Benzema runs to the sideline instead.',
    'Long switch to Di Maria on the right',
    'Get a runner into the space behind the opponent''s left back.',
    NULL, 193, 194, 950)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'receive wide, drive inside or play in behind'),
    (2, 'Right back (Arbeloa)', 'inside run or overlap behind the left back'),
    (3, 'Centre forward (Benzema)', 'run to the sideline when full back is too deep'),
    (4, 'Centre back (Ramos)', 'play the long ball')
) AS v(so, role, job);

-- 96. pp.195-196
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 Right Back''s Overlapping Runs on the Flank', 'Right back run during switch flight',
    'Alonso switches to Di Maria near the touchline and Arbeloa uses the flight time to run inside behind the left back, creating an overload on the flank.',
    'Long pass in the air to Di Maria',
    'Arbeloa receives and either crosses for Ronaldo and Higuain or cuts back to Kaka at the box edge; Khedira slides right for safety.',
    NULL, 195, 196, 960)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Alonso)', 'long switch to the right'),
    (2, 'Right winger (Di Maria)', 'receive and release Arbeloa'),
    (3, 'Right back (Arbeloa)', 'run behind the left back, cross or cut back'),
    (4, 'Central midfielder (Khedira)', 'shift right as safety'),
    (5, 'Ronaldo / Higuain / Kaka', 'box and edge-of-box targets')
) AS v(so, role, job);

-- 97. pp.197-199
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 Outnumbering the Opposition on the Flank', '2v1 on the left back',
    'Di Maria receives and goes inside while Arbeloa overlaps, leaving the opponent left back against two before the winger can help; if Arbeloa is too deep, Higuain exploits the space behind the left back instead and Kaka fills the striker spot.',
    'Winger receives switch with full back nearby',
    'Ball carrier has time: Higuain diagonal run in behind, Ronaldo between full back and centre back for a cross, or Arbeloa wide; Kaka''s low cross or cut-back to Khedira in example 2.',
    NULL, 197, 199, 970)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria)', 'drive inside, pick the option'),
    (2, 'Right back (Arbeloa)', 'overlap to create 2v1'),
    (3, 'Centre forward (Higuain)', 'diagonal run behind / exploit space behind left back'),
    (4, 'Left winger (Ronaldo)', 'attack gap between right back and centre back'),
    (5, 'Attacking midfielder (Kaka)', 'take striker''s position, receive in behind'),
    (6, 'Central midfielder (Khedira)', 'safety then support behind')
) AS v(so, role, job);

-- 98. pp.200-201
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 Long Diagonal Pass to the Centre Forward', 'Long diagonal into weak-side FB-CB gap',
    'Forwards run into the gap between the weak-side full back and centre back to receive a long diagonal (Benzema from Alonso, or Ronaldo from a dropping Di Maria).',
    'Space between weak-side full back and centre back',
    'Reach the box quickly and shoot.',
    NULL, 200, 201, 980)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Alonso) / Right winger (Di Maria)', 'hit the long diagonal'),
    (2, 'Centre forward (Benzema)', 'run between centre back and left back'),
    (3, 'Left winger (Ronaldo)', 'run in behind on the far side')
) AS v(so, role, job);

-- 99. pp.202-204
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch5 Building up from the Back Using a Long Ball', 'Long ball to aerial winner, flood second ball',
    'Under a press, Casillas or the defenders go long to the forwards (Ronaldo''s aerial duel when pressed from the right, or Pepe to Higuain) instead of risking a short pass.',
    'Opponent pressing high in the build-up',
    'Win the flick-on or second ball near the opponent''s box by moving the whole team up together to outnumber them in the ball zone.',
    NULL, 202, 204, 990)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Casillas) / Centre back (Pepe)', 'long ball to the target'),
    (2, 'Left winger (Ronaldo) / Centre forward (Higuain)', 'win the header'),
    (3, 'Attacking midfielder (Kaka)', 'run behind the full back for the flick'),
    (4, 'Centre forward (Higuain)', 'run behind the line (takes flick if Kaka dropped)'),
    (5, 'Far winger (Di Maria)', 'attack the potential header'),
    (6, 'Rest of team', 'push up in sync to the ball zone')
) AS v(so, role, job);

-- 100. pp.207-211
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Ch6 Transition from Attack to Defence / Retaining Possession', 'Full backs placed against wingers',
    'While the ball is with a midfielder, full backs keep a position relative to the opposition wingers so they can either go forward to receive or contest the winger if the ball is lost; one safety player sits behind the ball.',
    'Midfielder on the ball attempting to break a line',
    'Full back advances free if the pass goes through, or is immediately set against the winger if it fails.',
    NULL, 207, 211, 1000)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'stay ready to receive or contest No.11'),
    (2, 'Left back (Marcelo)', 'advance when Ozil is free'),
    (3, 'Defensive midfielder (Alonso)', 'safety player behind the ball, cover full back'),
    (4, 'Central midfielder (Khedira)', 'carry/pass forward')
) AS v(so, role, job);

-- 101. pp.210-210
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Ch6 Applying Immediate Pressure When Possession Is Lost', 'Intercepted in midfield: block, tuck in',
    'A midfield pass is intercepted; both full backs come inside goal-side of the wingers and the two holding midfielders close the interceptor''s passing options.',
    'Pass intercepted in central midfield',
    'Win it back immediately or deny any forward pass.',
    NULL, 210, 210, 1010)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (Marcelo, Arbeloa)', 'move inside goal side of wingers'),
    (2, 'Defensive midfielder (Alonso)', 'safety player, block options'),
    (3, 'Central midfielder (Khedira)', 'second safety player, block options')
) AS v(so, role, job);

-- 102. pp.212-212
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch6 Defensive Midfielder Maintaining Balance and Cohesion', 'Holding mid fills for stepping centre back',
    'When a centre back carries the ball forward, Alonso drops into the space he left.',
    'Centre back (Ramos or Pepe) dribbles forward',
    'Back line keeps its numbers and the team stays balanced against a counter.',
    NULL, 212, 212, 1020)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Ramos/Pepe)', 'step forward with the ball'),
    (2, 'Defensive midfielder (Alonso)', 'drop into the centre back slot')
) AS v(so, role, job);

-- 103. pp.213-213
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Ch6 The Negative Transition', 'Three loss situations and the rules',
    'Losses are read as: pressing possible (receiver lacks control or faces own goal), pressing not possible (receiver has time), or lost wide while outnumbered.',
    'Ball lost; safety player reads receiver''s control and numbers',
    'Press when possible, otherwise force the ball wide/keep it on one side to buy recovery time.',
    NULL, 213, 213, 1030)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Safety player', 'press at once if receiver is unsettled; else stand off and steer wide'),
    (2, 'Strong-side centre back', 'mark direct opponent tightly'),
    (3, 'Weak-side centre back', 'cover'),
    (4, 'Defensive midfielder', 'become first defender when safety player is outnumbered wide'),
    (5, 'Defenders', 'track direct opponents'' forward runs')
) AS v(so, role, job);

-- 104. pp.214-220
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Ch6 Winning the Ball Back in the Central Zone / Regaining Possession in the Centre of the Field', 'Central loss: press back-to-goal receiver',
    'Ball lost centrally to a midfielder who receives facing his own goal or without clean control.',
    'Receiver back to goal or poor first touch',
    'Alonso presses without hesitation so he cannot turn, while everyone near the ball marks tightly.',
    NULL, 214, 220, 1040)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Alonso)', 'press the receiver instantly'),
    (2, 'Centre back (Ramos)', 'tight on No.9'),
    (3, 'Centre back (Pepe)', 'cover Ramos'),
    (4, 'Full backs', 'tuck inside to defensive positions'),
    (5, 'Central midfielder (Khedira)', 'balance and mark No.10 near the ball')
) AS v(so, role, job);

-- 105. pp.215-225
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Ch6 When Immediate Regaining of Possession is Not Possible', 'Receiver has time: screen centre, track runs',
    'The opponent wins it cleanly with time to pick a pass while No.7, No.9 and No.10 run into space.',
    'New ball carrier has time and space',
    'Close the central lane and track runners so the ball goes wide, gaining time for the rest to recover.',
    NULL, 215, 225, 1050)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Ramos)', 'follow No.9''s run'),
    (2, 'Left back (Marcelo)', 'regain goal-side position on No.7'),
    (3, 'Centre back (Pepe)', 'drop to cover, watch No.10'),
    (4, 'Right back (Arbeloa)', 'recover to make numbers'),
    (5, 'Alonso / Ozil', 'block pass towards the centre')
) AS v(so, role, job);

-- 106. pp.216-216
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Ch6 Preventing the Switch of Play', 'Outnumbered wide: safety player drops, DM engages',
    'Ball lost on the left with Marcelo facing two opponents; he does not step in but follows No.7.',
    'Loss near the sideline with our safety player outnumbered',
    'Alonso and Ozil keep the ball on that side, no switch, while the back line forms superiority.',
    NULL, 216, 216, 1060)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'follow No.7, do not engage'),
    (2, 'Defensive midfielder (Alonso)', 'become first defender'),
    (3, 'Attacking midfielder (Ozil)', 'help lock the ball on the left'),
    (4, 'Centre backs (Ramos, Pepe)', 'track No.9 together'),
    (5, 'Right back (Arbeloa)', 'tuck in for numbers')
) AS v(so, role, job);

-- 107. pp.217-231
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch6 Safety Players / In the Centre / Advanced Supporting Positions', 'Two safety players behind every attack',
    'Whoever has the ball, two players sit behind it as safety: Alonso and Ramos when Marcelo is on the line, Alonso and Khedira when Ozil has it centrally, Alonso and Ozil when Marcelo is about to cross; with Ronaldo crossing, Marcelo covers and Alonso steps up.',
    'Team in possession in the attacking half',
    'Ready-made counter-press and cover the moment possession is lost.',
    NULL, 217, 231, 1070)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Alonso)', 'constant safety player, slide to ball side'),
    (2, 'Central midfielder (Khedira)', 'second safety in central play'),
    (3, 'Centre back (Ramos)', 'safety behind full back on the line'),
    (4, 'Attacking midfielder (Ozil)', 'safety near the box when full back crosses'),
    (5, 'Left back (Marcelo)', 'cover when Ronaldo crosses')
) AS v(so, role, job);

-- 108. pp.218-227
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Ch6 Team Cohesion / Winning the Ball Back in an Advanced Wide Position / Keeping the Opposition near the Sideline', 'Lost on left flank: press, trap on line',
    'Marcelo or Ronaldo loses a dribble near the left touchline; the nearest safety player presses at once while the rest shuffle across.',
    'Possession lost near the sideline in an advanced wide area',
    'Win it immediately or keep the ball pinned on the touchline until the team has recovered.',
    NULL, 218, 227, 1080)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest safety (Alonso or Marcelo)', 'close the new carrier immediately'),
    (2, 'Defensive midfielder (Alonso)', 'take inside position to keep the ball on the left'),
    (3, 'Centre back (Ramos)', 'shift across to mark No.9'),
    (4, 'Centre back (Pepe)', 'cover Ramos'),
    (5, 'Central midfielder (Khedira)', 'extensive shift for midfield balance'),
    (6, 'Right back (Arbeloa)', 'tuck in as third centre back')
) AS v(so, role, job);

-- 109. pp.219-226
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'in_possession', 'Ch6 Safety Players / The Left Side / Ronaldo''s Driving Runs / Full Back''s inside Movement / Alonso''s Covering', 'Left side balance around Ronaldo''s free role',
    'Because Ronaldo roams freely, Marcelo and Alonso position relative to him: if Ronaldo is high/wide Marcelo stays deeper or moves inside to cover, letting Alonso go higher; if both Ronaldo and Marcelo push on (or Marcelo makes an inside run), Alonso slides out into the left back slot and Khedira takes the centre.',
    'Ronaldo''s position and Marcelo''s forward movement',
    'Always two covering players behind the ball on the left so a loss does not unbalance the team.',
    NULL, 219, 226, 1090)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'free role, carries the ball'),
    (2, 'Left back (Marcelo)', 'stay deep or tuck inside when Ronaldo is advanced'),
    (3, 'Defensive midfielder (Alonso)', 'shift left into left back role when both go'),
    (4, 'Central midfielder (Khedira)', 'take central balance position')
) AS v(so, role, job);

-- 110. pp.222-222
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Ch6 Limiting Passing Options for the New Ball Carrier', 'Double press with central lane blocked',
    'Ronaldo loses it on the left and No.6 tries to move forward.',
    'Opponent wins the ball and starts to carry forward',
    'Alonso and Khedira press together; if no regain, Khedira cuts off the lane to No.10 so the ball cannot go central and Arbeloa can recover.',
    NULL, 222, 222, 1100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Alonso)', 'press the new carrier'),
    (2, 'Central midfielder (Khedira)', 'press then block the pass to No.10'),
    (3, 'Right back (Arbeloa)', 'recover for numbers')
) AS v(so, role, job);

-- 111. pp.229-232
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Ch6 Losing Possession near the Opposition Penalty Area', 'Loss near box after switch: press and close centre',
    'After play moves right to left, Ronaldo (or Marcelo) loses it to the right back near the opposition box.',
    'Ball lost to opponent full back on the flank near their box',
    'First defender tries to win it at once; otherwise keep it near the sideline while forwards block the inside pass.',
    NULL, 229, 232, 1110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Marcelo)', 'safety player, press the new carrier'),
    (2, 'Defensive midfielder (Alonso)', 'track No.7''s run'),
    (3, 'Benzema / Ozil', 'shift left to block the pass inside'),
    (4, 'Central midfielder (Khedira)', 'rebalance after Alonso''s shift'),
    (5, 'Centre back (Ramos)', 'move to strong side for long ball from No.2'),
    (6, 'Right back (Arbeloa)', 'drop for superiority at the back')
) AS v(so, role, job);

-- 112. pp.233-235
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Chapter 6 Transitions - Safety Players: Supporting the Forward / Cohesion: Closing down in Numbers', 'Three safety players behind the striker',
    'With the centre forward on the ball near the box, the attacking mid, the ball-side holding mid and the right winger sit in a cover triangle behind him; if the pass to him is intercepted centrally the nearest two double the new carrier while others block passing lanes.',
    'Ball lost centrally just outside the opposition box',
    'Win the ball back at once or at least have more men than the opponents around the ball.',
    NULL, 233, 235, 1120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Ozil) + right winger (Di Maria)', 'Double mark the new ball carrier'),
    (2, 'Holding midfielders (Alonso, Khedira)', 'Block the passes into the opposing midfielders'),
    (3, 'Centre backs (Pepe, Ramos)', 'Step up to tighten on their nearest attackers'),
    (4, 'Full backs (Marcelo, Arbeloa)', 'Tuck inside to narrow the shape')
) AS v(so, role, job);

-- 113. pp.236-238
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Chapter 6 Transitions - Safety Players: The Right Side (+ Assessment)', 'Right-side triangle: winger, full back, holding mid',
    'Balance on the right came from the winger, full back and defensive midfielder sharing the cover: if the winger dropped deep the full back could push on; if both pushed on, the holding mid slid wide into the full back''s slot; if all three were high, the deeper holding mid (Alonso) shifted right. Here the winger has the ball and the full back and Khedira are the two safety players.',
    'Pass from the full back is intercepted on the right',
    'Never be caught short on the strong side; press the new carrier with numbers.',
    NULL, 236, 238, 1130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side holding mid (Khedira)', 'Closes the interceptor immediately'),
    (2, 'Right back (Arbeloa)', 'Joins to double mark'),
    (3, 'Attacking midfielder (Ozil)', 'Picks up the nearest central midfielder'),
    (4, 'Ball-side centre back (Pepe)', 'Steps out to mark their 10 tightly'),
    (5, 'Far centre back (Ramos) + Alonso', 'Shift towards the strong side to cover')
) AS v(so, role, job);

-- 114. pp.239-241
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Chapter 6 Transitions - Safety Players: Inside Right Positions / Creating a 5v2 Numerical Advantage around the Ball Zone', 'Holding pair shift right, 5v2 at the ball',
    'When the right back pushes high, both holding midfielders slide right as the safety players. If the winger then loses a 1v1 and the opponent drives forward, the team swarms the ball zone.',
    'Right winger loses a 1v1 and the opponent carries forward',
    'Create about a 5v2 around the ball and smother the break.',
    NULL, 239, 241, 1140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding mids (Alonso, Khedira)', 'Double mark the carrier'),
    (2, 'Attacking midfielder (Ozil)', 'Blocks the pass inside to the centre'),
    (3, 'Ball-side centre back (Pepe)', 'Marks their 10 tightly'),
    (4, 'Far centre back (Ramos)', 'Covers behind'),
    (5, 'Left back (Marcelo)', 'Recovers inside as the third defender')
) AS v(so, role, job);

-- 115. pp.242-244
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Chapter 6 Transitions - Safety Players: The Right Flank / Tracking Runners on a Counter Attack', 'Full back tucks in, tracks the runner',
    'With the winger on the ball by the touchline, Khedira runs inside/forward and the right back steps into a holding-mid spot as safety while Alonso shifts across. When a long ball to the winger is lost and the opposing winger sprints forward, the full back does not challenge the carrier in the 2v1 but follows the runner.',
    'Long ball to the right winger is won by their full back, who starts a counter',
    'Remove the run in behind and keep the ball on the right where support is close.',
    NULL, 242, 244, 1150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'Tracks the opponent''s forward runner rather than the ball'),
    (2, 'Holding mid (Alonso)', 'Closes the carrier and keeps play on the right'),
    (3, 'Centre forward (Benzema)', 'Shifts across to block the pass into midfield'),
    (4, 'Attacking midfielder (Ozil)', 'Drops back for balance'),
    (5, 'Centre backs (Pepe, Ramos)', 'Mark their 10, cover and watch their 9'),
    (6, 'Left back (Marcelo)', 'Tucks in for numbers at the back')
) AS v(so, role, job);

-- 116. pp.245-247
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Chapter 6 Transitions - Safety Players: The Right Flank (2) / Tracking Runners on a Counter Attack (2)', 'Khedira covers the overlapping full back',
    'When the right back makes an inside/forward run, Khedira slides right as safety. If the pass to the winger is lost and their full back carries forward, Khedira closes him at once and Alonso makes a long shift for balance.',
    'Ball lost on the right after the full back has advanced',
    'Stop the counter at source and keep the ball on that flank.',
    NULL, 245, 247, 1160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding mid (Khedira)', 'Covers the full back''s space, then closes the carrier'),
    (2, 'Holding mid (Alonso)', 'Big shift right for balance'),
    (3, 'Attacking midfielder (Ozil)', 'Helps keep the ball on the right'),
    (4, 'Ball-side centre back (Pepe)', 'Follows their 10'),
    (5, 'Far centre back (Ramos)', 'Covers')
) AS v(so, role, job);

-- 117. pp.248-250
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Chapter 6 Transitions - Safety Players: Alonso''s Covering Position / Ensuring Superiority in Numbers at the Back', 'Alonso''s long shift when both are high',
    'If the right back and Khedira are both advanced, Alonso must cross to the right to be the safety player. When the ball is then lost there, he is the one who presses, aiming to keep the ball on that side if it cannot be won at once.',
    'Ball lost on the right with full back and Khedira both ahead of the ball',
    'Hold the ball on the strong side and keep extra men at the back.',
    NULL, 248, 250, 1170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding mid (Alonso)', 'Presses the new carrier'),
    (2, 'Holding mid (Khedira)', 'Blocks the pass into the centre'),
    (3, 'Attacking midfielder (Ozil)', 'Drops for midfield balance'),
    (4, 'Centre backs (Pepe, Ramos)', 'Shift to the strong side watching their 10 and 9'),
    (5, 'Left back (Marcelo)', 'Moves in to give superiority at the back')
) AS v(so, role, job);

-- 118. pp.251-252
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Chapter 6 Transitions - Safety Players: Khedira''s Advanced Position / Shifting across into Covering Positions', 'Full back is safety, Khedira can advance',
    'If the right back already sits in a covering position behind the winger, Khedira is free to push higher. When the winger is dispossessed, the whole block slides across.',
    'Right winger loses the ball to their full back',
    'Press the carrier from the side and seal the inside pass.',
    NULL, 251, 252, 1180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'Closes the new carrier immediately'),
    (2, 'Holding mid (Khedira)', 'Helps keep the ball wide, blocks the pass to their winger'),
    (3, 'Attacking midfielder (Ozil)', 'Shifts across and marks their 8'),
    (4, 'Ball-side centre back (Pepe)', 'Tight on their 10 moving wide to receive'),
    (5, 'Far centre back (Ramos)', 'Covers Pepe'),
    (6, 'Left back (Marcelo)', 'Moves central as a third centre back')
) AS v(so, role, job);

-- 119. pp.253-255
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Chapter 6 Transitions - Safety Players: Support Play near the Penalty Area / Superiority in Numbers High up the Pitch', 'Rest defence when the winger crosses',
    'When the right winger is about to cross, the right back and Khedira stay behind the ball as safety. If the cross is cleared out to their winger, they pounce while the rest close the centre.',
    'Cross from the right winger is cleared to a wide opponent',
    'Win the second ball high up the pitch with numbers.',
    NULL, 253, 255, 1190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa) + Khedira', 'Press the receiver of the clearance at once'),
    (2, 'Attacking midfielder (Ozil)', 'Blocks the pass into the centre'),
    (3, 'Alonso + right centre back (Pepe)', 'Mark their 10'),
    (4, 'Ramos + Marcelo', 'Hold numbers behind')
) AS v(so, role, job);

-- 120. pp.256-258
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_defend', 'Chapter 6 Transitions - Safety Players: Near to the Byline / Positioning for Clearances from Crosses', 'Winger and Alonso cover a full back cross',
    'When the right back has the ball near the byline and Khedira has gone into the box, the winger takes a safety position and Alonso sees it and shifts right as the second safety player. If the cross is cleared wide, the nearest players close the receiver with up to three men.',
    'Cross from the full back is cleared to an opponent',
    'Trap the clearance near the opposition box.',
    NULL, 256, 258, 1200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Di Maria) + Ozil', 'Immediate pressure on the receiver'),
    (2, 'Centre forward (Benzema)', 'Joins to triple mark'),
    (3, 'Holding mid (Alonso)', 'Shifts right as second safety, marks their 10'),
    (4, 'Right centre back (Pepe)', 'Moves to block a pass down the line'),
    (5, 'Marcelo + Ramos', 'Watch their 9')
) AS v(so, role, job);

-- 121. pp.259-261
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_attack', 'Chapter 6 Transitions - Transition from Defence to Attack: Switching Play from the Strong Side to the Weak Side', 'Square passes to the weak side',
    'After winning the ball in midfield when vertical and diagonal lanes are blocked, the team moves it with square passes to the far side where space is; the aggressive full back on that side is already pushing on. If the opponents shift over in time, simply keep possession (the winger drops to offer).',
    'Ball won in midfield with forward lanes closed',
    'Exploit space on the weak side, or retain the ball if it closes.',
    NULL, 259, 261, 1210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (Alonso)', 'Plays square to the other holding mid'),
    (2, 'Holding mid (Khedira)', 'Switches to the far full back'),
    (3, 'Weak-side full back (Arbeloa)', 'Breaks forward into space'),
    (4, 'Weak-side winger (Di Maria)', 'Drops to support if the switch is closed')
) AS v(so, role, job);

-- 122. pp.262-263
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_attack', 'Chapter 6 Transitions - Transition to the Final Attacking Stage', 'Switch, then 2v1 on their full back',
    'Ball won in midfield, forward passes blocked, so it goes via the other holding mid to the free right back. The winger runs inside then out to overload their full back with the right back, while the striker and AM attack the box and the left winger arrives at its edge.',
    'Right back receives the switch with space ahead',
    'Overload the full back and cross into a filled box.',
    NULL, 262, 263, 1220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'Drives forward with the ball'),
    (2, 'Right winger (Di Maria)', 'Inside run towards the line to create 2v1, receives and crosses'),
    (3, 'Centre forward (Benzema) + Ozil', 'Attack the penalty area'),
    (4, 'Left winger (Ronaldo)', 'Arrives at the edge of the box for the cutback/cross')
) AS v(so, role, job);

-- 123. pp.264-265
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_attack', 'Chapter 6 Transitions - Transition to the Final Attacking Stage (Example 2)', 'Interception, diagonal to winger, three options',
    'Alonso intercepts, is pressed and plays to Khedira, who hits a diagonal to the winger because the opposing winger was slow to block. The winger drives at the box while the striker and far winger make diagonal runs.',
    'Opposing winger fails to close the diagonal lane',
    'Give the carrier a pass to the striker, a pass to the far winger, or a shot.',
    NULL, 264, 265, 1230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding mid (Khedira)', 'Diagonal pass to the right winger'),
    (2, 'Right winger (Di Maria)', 'Carries towards the box and picks the option'),
    (3, 'Centre forward (Benzema)', 'Diagonal run for the near option'),
    (4, 'Left winger (Ronaldo)', 'Diagonal run for the far option')
) AS v(so, role, job);

-- 124. pp.266-267
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_attack', 'Chapter 6 Transitions - Applying Immediate Pressure on the Ball Carrier', 'Ronaldo''s balanced high spot as outlet',
    'When their right back pushes up, Ronaldo stays between him and the centre back. The left back and Alonso double the receiver; Alonso wins it and passes straight to Ronaldo before the full back can recover. Ronaldo cuts in, Benzema runs diagonally behind the centre back and Ozil fills the space he leaves.',
    'Double-mark regain while their full back is upfield',
    'Hit the space behind the advanced full back instantly; Ronaldo can pass to Ozil, to Benzema, or shoot.',
    NULL, 266, 267, 1240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Holds a high spot between full back and centre back, receives first pass'),
    (2, 'Left back (Marcelo) + Alonso', 'Double mark and regain'),
    (3, 'Holding mid (Alonso)', 'Plays forward to Ronaldo immediately'),
    (4, 'Centre forward (Benzema)', 'Diagonal run behind the centre back'),
    (5, 'Attacking midfielder (Ozil)', 'Moves into the space Benzema vacates')
) AS v(so, role, job);

-- 125. pp.268-269
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_attack', 'Chapter 6 Transitions - Pressing near the Sideline: Quick Counter Attack (+ Assessment)', 'Wide regain, Ronaldo 1v1 on the flank',
    'After pressing near the touchline, Ozil wins the ball in midfield; Ronaldo moves wide to receive with space ahead and drives at his man, while Benzema runs in behind the centre back and Ozil takes up the striker''s spot.',
    'Ball won after pressing near the sideline',
    'Release Ronaldo into a 1v1 with runners for the cross.',
    NULL, 268, 269, 1250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Ozil)', 'Wins it, passes wide, then attacks the centre forward position'),
    (2, 'Left winger (Ronaldo)', 'Wide receiving spot, dribbles into the space'),
    (3, 'Centre forward (Benzema)', 'Run behind the centre back, receives and crosses'),
    (4, 'Right winger (Di Maria)', 'Joins the attack from the far side')
) AS v(so, role, job);

-- 126. pp.270-272
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'to_attack', 'Chapter 6 Transitions - Counter Attack from a Defensive Clearance', 'Clearance to Benzema, wingers stretch',
    'Defending deep, a cleared cross reaches Benzema, who sets it back to Ozil (or Khedira carries out after a header). The right winger opens towards the touchline to stretch the back line and Ronaldo, left high, runs diagonally inside.',
    'Headed or kicked clearance reaches a forward',
    'Turn a deep clearance into a fast break; final pass or cross to Ronaldo running diagonally.',
    NULL, 270, 272, 1260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Ramos/Pepe)', 'Clears towards Benzema'),
    (2, 'Centre forward (Benzema)', 'Lays off, then makes a diagonal run and can cross'),
    (3, 'Attacking midfielder (Ozil) / Khedira', 'Carries or plays to Di Maria'),
    (4, 'Right winger (Di Maria)', 'Opens wide, drives forward and makes the final pass'),
    (5, 'Left winger (Ronaldo)', 'Diagonal run into the free space to finish')
) AS v(so, role, job);

-- 127. pp.273-274
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'set_piece', 'Chapter 7 Attacking from Set Pieces - Corner Kicks', 'Corner: five in the box',
    'Five players go in the area; four attack towards goal for a header while Khedira stands in the six-yard box near the keeper. Two wait outside the box for clearances and one spare man stays back.',
    'Attacking corner',
    'Use height and strength (Ronaldo, Pepe, Ramos, Benzema) to win the header, with the second ball and rest defence covered.',
    NULL, 273, 274, 1270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ronaldo, Pepe, Ramos, Benzema', 'Attack the ball towards goal'),
    (2, 'Khedira', 'In the six-yard box on the keeper'),
    (3, 'Two players outside the area (e.g. Marcelo, Di Maria)', 'Pick up clearances'),
    (4, 'Spare man (Alonso/Arbeloa)', 'Stays back')
) AS v(so, role, job);

-- 128. pp.275-275
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'set_piece', 'Chapter 7 Attacking from Set Pieces - Free Kicks near the Sideline', 'Wide free kick: Ramos curved run',
    'For free kicks near the corner flag, Pepe, Ronaldo and Benzema run at goal to drag their markers away, and Ramos curls into the gap between the penalty spot and the six-yard box.',
    'Free kick wide near the corner flag',
    'Free Ramos for a header in the space the decoys open.',
    NULL, 275, 275, 1280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pepe, Ronaldo, Benzema', 'Decoy runs towards goal pulling markers'),
    (2, 'Ramos', 'Curved run into the space between spot and six-yard box'),
    (3, 'Marcelo, Di Maria', 'Outside the box for second balls'),
    (4, 'Arbeloa', 'Deep, against the long ball')
) AS v(so, role, job);

-- 129. pp.276-276
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'set_piece', 'Chapter 7 Attacking from Set Pieces - Free Kicks near the Sideline (Example 2)', 'Inswinging wide free kick, four attack',
    'From wider free kicks Ozil (right) or Alonso (left) whips in an inswinger; four players attack the goal, two wait just outside the area and two stay deeper.',
    'Free kick in a wide area further from goal',
    'Win the header with four runners while keeping second-ball and rest cover.',
    NULL, 276, 276, 1290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Taker (Ozil right, Alonso left)', 'Inswinging delivery'),
    (2, 'Benzema, Ronaldo, Ramos, Pepe', 'Run towards goal to head'),
    (3, 'Khedira, Di Maria', 'Just outside the area'),
    (4, 'Arbeloa, Marcelo', 'Deeper positions')
) AS v(so, role, job);

-- 130. pp.277-277
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'out_of_possession', 'Chapter 7 - Playing with 10 Men (+ Assessments)', '10 men: passive 4-4-1 mid block',
    'After a red card the team switches to 4-4-1 and defends zonally and passively around halfway. Ronaldo stays goal-side of their right back and tracks his runs so Alonso can help the centre backs; on crosses Alonso drops into the box. With 10 they do not build from the back, only attack after regains.',
    'A player sent off',
    'Stay compact and balanced and avoid being outnumbered in the box.',
    NULL, 277, 277, 1300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ronaldo)', 'Goal-side of their right back, tracks his runs'),
    (2, 'Holding mid (Alonso)', 'Supports the centre backs, drops into the box on crosses'),
    (3, 'Lone forward (Benzema)', 'Screens at the halfway line'),
    (4, 'Back four', 'Hold a deep zonal line')
) AS v(so, role, job);

-- 131. pp.278-279
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-s-real-madrid-a-tactical-analysis-attacking-in-the-4-2-3-1-book'), 'out_of_possession', 'Chapter 7 - Playing with 10 Men (pressing in the 4-4-1)', '10 men: force play to one side',
    'Even with 10, they sometimes pressed in the 4-4-1: Benzema angles his press to push the build-up to the side, Ronaldo stays goal-side of their full back, Alonso marks their 6 and the far winger shifts into the centre to support Khedira, leaving the far-side opponent free.',
    'Opponent centre back on the ball in build-up',
    'Make a strong side and win the ball there, giving up the far flank.',
    NULL, 278, 279, 1310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lone forward (Benzema)', 'Curved press to show play to the side'),
    (2, 'Left winger (Ronaldo)', 'Goal-side of their right back'),
    (3, 'Holding mid (Alonso)', 'Marks their 6'),
    (4, 'Far winger (Di Maria)', 'Big shift centrally to support Khedira')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1966-coaching-book-mourinho-real-madrid-attacking-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
