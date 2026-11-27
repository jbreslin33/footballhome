-- 1967 📚 Coaching book patterns: "Jurgen Klopp's Attacking Tactics" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Jurgen Klopp''s Attacking Tactics',
    subtitle    = 'Tactical Analysis and Sessions from Borussia Dortmund''s 4-2-3-1',
    author      = 'Athanasios Terzis',
    team        = 'Borussia Dortmund',
    season      = '2013-14',
    method_note = 'Analysis of Klopp''s Dortmund 4-2-3-1 in attack from every 2013-14 match (Lewandowski, Reus, Mkhitaryan, Blaszczykowski, Sahin / Gündogan, Bender, Hummels, Subotic / Sokratis, Schmelzer, Piszczek). It sets out player roles, who joins the attack, how balance is kept through fluid rotations, and build-up shapes chosen by how many forwards the opponent presses with; then splits the attack into three stages (find the free man at the back, combine in midfield to reach the killer-pass player, finish). Twelve attacking tactical situations follow (space on the flank, forward drops and the 10 runs beyond, up-and-down movement, lay-offs, third-man runs, direct play, long balls in behind, switches), each with a progressive session, then defence-to-attack transitions (direct, indirect with a forward pass, indirect with a switch; finish in 6-10 seconds). Patterns are the match behaviours, in our words.'
WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do');

-- 1. pp.14-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 1: Role of the Centre Forward', 'Roaming centre forward drops into lanes',
    'The No.9 is based centrally but roams without the ball, often dropping back into the attacking midfielders'' zone toward open passing lanes.',
    'Ball carrier lacks a forward option',
    'Either receive and turn toward goal or drag a marker away to open space for team-mates.',
    NULL, 14, 14, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Lewandowski)', 'drop or drift into free lanes as a passing option'),
    (2, 'Attacking midfielders', 'exploit space the dropping 9 leaves')
) AS v(so, role, job);

-- 2. pp.15-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 1: Role of the Attacking Midfielders', 'Three attacking mids between the lines',
    'Against a mid-block, both wingers and the No.10 tuck into central positions between the opponent''s lines, close to the box.',
    'Opponent defends in the middle third',
    'Receive centrally where a final pass is one touch away; if one leaves the zone, the 9 or a holding mid fills the gap.',
    NULL, 15, 15, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (Reus, Blaszczykowski)', 'play narrow between midfield and defence'),
    (2, 'No.10 (Mkhitaryan)', 'central between the lines'),
    (3, 'Centre forward / defensive mid', 'fill the gap when an attacking mid drops or goes wide')
) AS v(so, role, job);

-- 3. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 1: Role of the Defensive Midfielders', 'Staggered double pivot links stages',
    'One holding mid is defensive-minded, the other more attacking; with the centre backs they move the ball from first-stage build-up into the advanced players.',
    'Build-up from the back / attacking mid drops deep or wide',
    'Advance the ball and keep midfield balance by stepping into vacated advanced spaces; one may drop into the back line.',
    NULL, 16, 16, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive mid (Bender/Kehl)', 'deeper, can drop into a centre back slot'),
    (2, 'Defensive mid (Sahin/Gundogan)', 'more advanced, steps up when an attacking mid leaves'),
    (3, 'Centre backs', 'share first passes with the pivots')
) AS v(so, role, job);

-- 4. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 1: Role of the Full Backs', 'One full back attacks, one balances',
    'Because the attacking midfielders stay central, width comes mainly from the full backs; usually one joins the front four while the other holds a balanced middle position.',
    'Team in settled attack',
    'Width in attack while the far full back can either drop to help the defence or push on.',
    NULL, 17, 17, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking full back', 'push high and wide, join the attack'),
    (2, 'Balancing full back', 'hold middle height, ready to drop or advance')
) AS v(so, role, job);

-- 5. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 1: Role of the Centre Backs', 'Ball-playing centre back carries forward',
    'The technical centre back (Hummels) dribbles into advanced areas and plays accurate forward passes; the other centre back plays short and safe.',
    'Free space ahead of the centre backs',
    'Break lines with carries and passes; under pressure the less technical centre back goes long to the 9.',
    NULL, 17, 17, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-playing centre back (Hummels)', 'carry forward and pass through lines'),
    (2, 'Defensive centre back (Subotic/Sokratis)', 'short safe passes, long ball to 9 when pressed'),
    (3, 'Centre forward', 'target for long balls')
) AS v(so, role, job);

-- 6. pp.19-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 2: Attack Through the Centre', 'Central attack with five, two at back',
    'With two centre backs staying back, five players attack through the middle: the front four plus one full back (either side), giving the carrier four forward options.',
    'Attack developing through the centre with a two-man back line',
    'Multiple forward options while one pivot and the other full back stay as support.',
    NULL, 19, 20, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front four (9, 10, wingers)', 'attacking positions'),
    (2, 'One full back', 'overlap into the attack'),
    (3, 'Other full back', 'balanced, ready to advance or drop'),
    (4, 'Deeper defensive mid', 'support behind, near centre backs')
) AS v(so, role, job);

-- 7. pp.20-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 2: Attack Through the Centre', 'Central attack with six, three at back',
    'When a holding mid drops to make a back three, both full backs join the front four so six attack through the middle.',
    'Defensive mid drops into the back line',
    'Ball carrier gets five forward passing options.',
    NULL, 20, 20, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping defensive mid (Bender)', 'becomes third centre back'),
    (2, 'Both full backs', 'push into attacking positions'),
    (3, 'Other defensive mid', 'supporting position centrally')
) AS v(so, role, job);

-- 8. pp.21-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 2: Attack On the Flank', 'Box occupation when full back crosses',
    'On a flank attack where a full back is the crosser, all three attacking midfielders plus the 9 fill the box; the advanced pivot waits on the edge.',
    'Full back in a crossing position',
    'Four runners in the box for the cross, with support behind for second balls and balance.',
    NULL, 21, 22, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Crossing full back', 'deliver'),
    (2, 'Centre forward and three attacking mids', 'attack the box'),
    (3, 'Advanced defensive mid', 'outside the box in support'),
    (4, 'Weak-side full back / deeper pivot', 'balanced or in back line')
) AS v(so, role, job);

-- 9. pp.21-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 2: Attack On the Flank', 'Box occupation when winger crosses',
    'If an attacking midfielder is the man in the crossing spot, three players enter the box while the strong-side full back and advanced pivot support behind.',
    'Winger in a crossing position',
    'Three in the box for the cross, two close supporters for recycles and rebounds.',
    NULL, 21, 22, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Crossing winger', 'deliver'),
    (2, 'Three remaining forwards', 'attack the box'),
    (3, 'Strong-side full back', 'support behind the ball'),
    (4, 'Advanced defensive mid', 'support at the edge')
) AS v(so, role, job);

-- 10. pp.25-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 3: Retaining Balance During An Attack', 'Refill the 9 spot when he drops',
    'When the centre forward drops into midfield to offer a pass, the No.10 moves up into his spot; if the 10 is too deep to see it, the near winger takes the striker position instead. Eye contact between 9 and 10 drives the swap.',
    'Centre forward drops into an attacking mid position',
    'Always keep at least five players in advanced attacking positions.',
    NULL, 25, 26, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'drop to provide a passing option'),
    (2, 'No.10', 'push into the centre forward area'),
    (3, 'Near winger', 'take the 9 position if the 10 is deep'),
    (4, 'Weak-side full back', 'provide width and join')
) AS v(so, role, job);

-- 11. pp.25-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 3: Retaining Balance During An Attack', '9 drifts to a side, others shift',
    'The centre forward either drops toward one flank to build an overload there or bends a run out to the weak side; the No.10 or a winger moves into the central striker area.',
    'Centre forward leaves the middle toward a flank',
    'Overload one side while the striker position stays occupied; the full back on the free side gives width.',
    NULL, 25, 26, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'drop toward the strong side or curve to the weak side'),
    (2, 'No.10 (Mkhitaryan)', 'advance into the striker area'),
    (3, 'Winger (Reus)', 'slide into the centre forward position when the 10 is deep'),
    (4, 'Opposite full back', 'create width')
) AS v(so, role, job);

-- 12. pp.27-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 3: Retaining Balance In The Midfield', 'Winger drops, pivot and full back push',
    'If the right winger drops deep into a holding mid slot, the full back pushes on into the space and the attacking pivot steps up to keep three in the attacking mid zone; alternatively the No.10 slides across to cover the winger''s spot and the pivot moves into the central advanced role.',
    'Winger drops into a defensive midfield position',
    'Keep five players (incl. the 9) in the opponent half and the shape intact.',
    NULL, 27, 27, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Blaszczykowski)', 'drop into the holding mid area'),
    (2, 'Right full back', 'advance into the space vacated'),
    (3, 'Defensive mid (Sahin)', 'step up into the attacking mid line'),
    (4, 'No.10', 'optionally shift over to fill the winger''s zone'),
    (5, 'Other defensive mid (Bender)', 'stay balanced')
) AS v(so, role, job);

-- 13. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 3: Retaining Balance In The Midfield', 'No.10 drops, strong-side pivot advances',
    'When the No.10 drops into a holding mid''s area, the strong-side defensive mid moves up into the advanced midfield line and the other pivot rebalances.',
    'No.10 drops into a deep position',
    'Midfield line stays populated and five remain in advanced positions.',
    NULL, 28, 28, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'drop deep to receive'),
    (2, 'Strong-side defensive mid (Sahin)', 'move into advanced position'),
    (3, 'Other defensive mid (Bender)', 'take a balanced position')
) AS v(so, role, job);

-- 14. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 3: Retaining Balance In The Midfield', 'Winger goes wide, pivot steps up',
    'When the winger moves out to the touchline, the strong-side defensive mid advances into the central space he left.',
    'Winger moves toward the sideline',
    'Keep three in the attacking mid zone and five in advanced positions.',
    NULL, 28, 28, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger', 'move wide to the sideline'),
    (2, 'Strong-side defensive mid', 'advance into the vacated inside space'),
    (3, 'Other defensive mid', 'hold balance')
) AS v(so, role, job);

-- 15. pp.30-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: Formations With 2 Players At The Back', '2-3-4-1 build-up with two centre backs',
    'From 4-2-3-1 one full back joins the three attacking mids; the advanced pivot supports the forwards while the deeper pivot and deeper full back protect the centre backs. Variations swap roles (a winger or the No.10 drops while a pivot advances).',
    'Build-up with two centre backs',
    'First forward passes come from the two centre backs and two pivots inside the build-up zone; balance kept behind the ball.',
    NULL, 30, 31, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advancing full back', 'join the line of four'),
    (2, 'Advanced defensive mid', 'support forwards'),
    (3, 'Deep defensive mid', 'stay near centre backs while the full back is up'),
    (4, 'Deep full back', 'drop even deeper if the deep pivot moves up'),
    (5, 'Centre backs and pivots', 'make the forward passes')
) AS v(so, role, job);

-- 16. pp.32-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: Formations With 3 Players At The Back', 'Back three via pivot or full back',
    'A back three forms either by a defensive mid dropping beside or between the centre backs (3-3-3-1, both full backs push up, other pivot moves central) or by the weak-side full back tucking in while the strong-side full back advances (3-2-4-1).',
    'Need for an extra man in first-stage build-up',
    'Three plus the remaining pivot circulate and pass forward; full backs are freed to support the forwards rather than build.',
    NULL, 32, 33, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive mid (Bender)', 'drop wide of or between the centre backs'),
    (2, 'Both full backs', 'push high when the pivot drops'),
    (3, 'Other defensive mid (Sahin)', 'shift to the centre'),
    (4, 'Weak-side full back (Schmelzer)', 'alternative: drop to form the three')
) AS v(so, role, job);

-- 17. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: Choosing The Appropriate Formation', 'Outnumber their forwards by one',
    'The number of players kept back is chosen to outnumber the opposing forwards by one; against a lone striker the two centre backs alone build (2v1) and both full backs go high.',
    'Opponent''s number of forwards in the first line',
    'A spare man at the back with time to carry or pass forward, and numerical edges higher up.',
    NULL, 34, 34, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two centre backs', 'build 2v1 against a single forward'),
    (2, 'Both full backs', 'move into advanced positions'),
    (3, 'Spare man', 'carry forward or pass into space')
) AS v(so, role, job);

-- 18. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'to_defend', 'Chapter 4: Choosing The Appropriate Formation', 'Spare man at back for rest defence',
    'Keeping one more player at the back than the opponent has forwards also prepares for losing the ball.',
    'Possession lost during the attack',
    'Negative transition is handled more easily because the forwards are already outnumbered.',
    NULL, 34, 34, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line plus dropped player', 'keep +1 over opposing forwards'),
    (2, 'Deep defensive mid', 'screen in front of the back line')
) AS v(so, role, job);

-- 19. pp.35-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: Choosing The Appropriate Formation', 'Two at back vs compact forward pair',
    'Against two forwards who defend passively and staggered (one high, one near the midfield), Dortmund still builds with two centre backs, with a full back sitting deeper alongside a pivot.',
    'Two opposing forwards defend passively, one dropping deep',
    'Retain a 2v1 or 3v2 at the back without sacrificing an attacker.',
    '4-4-2', 35, 35, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two centre backs', '2v1 against the high forward'),
    (2, 'Defensive mid (Bender)', 'with deeper full back, 3v2 against the second forward'),
    (3, 'Deeper full back (Schmelzer)', 'stay level with the pivot')
) AS v(so, role, job);

-- 20. pp.35-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: Choosing The Appropriate Formation', 'Back three vs pressing forward pair',
    'When two forwards press the centre backs high, a three forms: a pivot drops beside or between the centre backs, or a full back drops, giving 3v2.',
    'Two opposing forwards press the defenders',
    'Escape the press with a free man; full backs push on when the pivot drops (full-back drop is temporary).',
    '4-4-2', 35, 36, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive mid (Bender)', 'drop wide or into the centre of defence'),
    (2, 'Full backs', 'push forward, or one drops to make the three'),
    (3, 'Other defensive mid (Sahin)', 'balanced central position')
) AS v(so, role, job);

-- 21. pp.37-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: The Three Stages Of Attack', 'Skip stage one with long ball',
    'The attack is split into stage 1 (find a free man at the back), stage 2 (combine to reach the killer-pass player) and stage 3 (finish). Under pressure the keeper kicks long to the forwards, and when no spare man can be found the team goes long to the 9 or back to the keeper.',
    'Defenders under pressure / no route to the spare man',
    'Avoid risky passes at the back by jumping straight to stage two.',
    NULL, 37, 40, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Weidenfeller)', 'long kick to forwards instead of risky short pass'),
    (2, 'Centre backs', 'long ball to the 9 or back to keeper when pressed'),
    (3, 'Centre forward', 'target for the long ball')
) AS v(so, role, job);

-- 22. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: The First Stage Of Attack Against 2 Passive Forwards', 'Beat passive pair: pivot or weak CB',
    'With a 4v2 at the back and the split pass between the forwards blocked, the carrier passes to the strong-side pivot or sideways to the weak-side centre back, who carries forward before the No.10 closes. If the pivot is screened, the full back acts as a link to reach him.',
    'Through pass between the two forwards blocked',
    'Find the man with time and space to pass forward or carry into stage two.',
    '4-4-2', 38, 38, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (Hummels)', 'pass to pivot or switch to partner'),
    (2, 'Strong-side defensive mid (Bender)', 'show for the pass'),
    (3, 'Weak-side centre back (Subotic)', 'receive and drive forward quickly'),
    (4, 'Strong-side full back', 'link pass back inside to the pivot')
) AS v(so, role, job);

-- 23. pp.39-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: The First Stage Of Attack Against 2 Aggressive Forwards', 'Beat pressing pair: pivot drops',
    'If a forward presses to cut the centre-back pass, a holding mid drops to the side or between the centre backs; the forward then cannot block both the horizontal pass and the split pass, or the right back drops to make a 5v2 (fewer forward options).',
    'Opposing forward presses the centre back pass',
    'Free a player to pass forward or through the forwards into stage two.',
    '4-4-2', 39, 40, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive mid (Bender)', 'drop wide of or between the centre backs'),
    (2, 'Centre back (Hummels)', 'play to the dropped pivot or split the forwards'),
    (3, 'Other defensive mid (Sahin)', 'receive the through pass'),
    (4, 'Right back (Piszczek)', 'alternatively drop to form a back three')
) AS v(so, role, job);

-- 24. pp.41-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: Moving Towards Available Passing Lanes On The Side', 'Flank lanes, two at back',
    'With the ball at a centre back near the touchline, the strong-side full back, winger and No.10 move into open lanes; whichever of 9 and 10 is on the weak side drops or shifts to offer a lane; one pivot sits deeper and the weak-side full back stays deep. Rarely the weak-side winger shifts right across with the right back dropping to keep 3v2.',
    'Spare man found on the side in stage one',
    'Give the carrier several forward passing options while keeping balance behind.',
    NULL, 41, 45, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side full back and winger', 'move into wide passing lanes'),
    (2, 'No.10', 'occupy a lane or advance to keep balance'),
    (3, 'Centre forward', 'drop back for a lane when the 10 is on the weak side'),
    (4, 'Defensive mids', 'one higher (not beyond opposition midfield), one deeper'),
    (5, 'Weak-side full back', 'stay deep')
) AS v(so, role, job);

-- 25. pp.41-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: Moving Towards Available Passing Lanes On The Side', 'Flank lanes, three at back',
    'Same flank build-up but with a back three: both full backs high and the remaining pivot held in a central balanced deep spot; the lane to the right of the carrier is taken by the 9 or right winger.',
    'Spare man found on the side with three at the back',
    'Passing options on the side without unbalancing the team.',
    NULL, 41, 45, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Both full backs', 'high up the pitch'),
    (2, 'Defensive mid (Sahin, No.18)', 'stay central and deep, do not climb'),
    (3, 'Centre forward or right winger', 'fill the lane right of the carrier')
) AS v(so, role, job);

-- 26. pp.46-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: Moving Towards Available Passing Lanes In The Centre', 'Three central lanes for the pivot',
    'When a pivot has the ball centrally, the three attacking mids move into three passing lanes, the 9 shows in a lane and the full back on the side the pivot will play to advances. If an attacking mid is in an opponent''s cover shadow, the 9 drops into his lane and that mid goes up to the striker spot.',
    'Defensive mid receives facing forward in the centre',
    'Multiple forward options; the screened mid stays involved, ready for a killer pass behind the line.',
    NULL, 46, 48, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive mid with ball (Sahin)', 'pass forward into a lane'),
    (2, 'Three attacking mids', 'take positions toward available lanes'),
    (3, 'Centre forward', 'drop into the lane of a screened team-mate'),
    (4, 'Screened attacking mid', 'move up into the centre forward position'),
    (5, 'Full back', 'advance on the side of the expected pass (or right back if Bender is third defender)')
) AS v(so, role, job);

-- 27. pp.49-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: The Second Stage Of Attack', 'Getting free of marking',
    'In stage two, players use up-and-down or dropping movements; e.g. winger and left back move in sequence, and if the opposing right back holds his zone instead of following, the winger receives unmarked and turns.',
    'Marker chooses between following and holding zone',
    'Either space is created for a team-mate or the mover receives free facing goal.',
    NULL, 49, 49, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Reus)', 'drop or up-and-down movement to lose the marker'),
    (2, 'Left back (Schmelzer)', 'move forward in sync'),
    (3, 'Centre back with ball', 'pass to whichever is free')
) AS v(so, role, job);

-- 28. pp.50-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: The Second Stage Of Attack', 'Third man run into vacated space',
    'The pivot carries forward; the No.10 is screened so the 9 drops to receive; his centre back stays at first, then steps up to close the 9 after the pass, opening space behind that the No.10 runs into and the 9 finds first time.',
    'Centre back steps out to the dropping 9 after the pass',
    'No.10 receives in behind the defensive line.',
    NULL, 50, 50, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive mid (Bender)', 'carry forward and pass to the dropping 9'),
    (2, 'Centre forward', 'drop into the open lane, lay first time'),
    (3, 'No.10 (Mkhitaryan)', 'run into the space behind the stepping centre back')
) AS v(so, role, job);

-- 29. pp.51-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: The Second Stage Of Attack', 'No.10 drifts wide for 2v1',
    'The No.10 moves out toward the flank beside the winger, so the opponent full back already marking the winger cannot also mark him.',
    'Opponent full back occupied by the winger',
    'The 10 receives with time to turn and play forward.',
    NULL, 51, 51, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 (Mkhitaryan)', 'drift to the side to create 2v1'),
    (2, 'Winger (Reus)', 'pin the full back'),
    (3, 'Centre back (Hummels)', 'carry and pass to the free 10')
) AS v(so, role, job);

-- 30. pp.51-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: The Second Stage Of Attack', 'Quick combination to 10 facing goal',
    'With the No.10 screened, the winger shifts inside, receives and plays first time to the 10, who now faces goal; the 9 runs in behind.',
    'No.10''s direct lane is closed',
    'Get the ball to a player between the lines facing goal for a killer pass.',
    NULL, 51, 51, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Blaszczykowski)', 'shift inside, first-time pass'),
    (2, 'No.10', 'receive facing goal, play the killer pass'),
    (3, 'Centre forward', 'run behind the defence')
) AS v(so, role, job);

-- 31. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: The Second Stage Of Attack', 'Direct long ball to 9''s blind side',
    'At times the team goes direct: the centre back hits a long pass for the centre forward running onto his marker''s blind side.',
    'Centre forward can get on the blind side of his marker',
    'Reach the box quickly and create a scoring chance.',
    NULL, 52, 52, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Hummels)', 'long pass toward the box'),
    (2, 'Centre forward', 'run off the marker''s blind side')
) AS v(so, role, job);

-- 32. pp.52-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Chapter 4: The Second Stage Of Attack', 'Switch to weak side, overlap to cross',
    'After a switch to the right winger, if he is closed and cannot turn inside he plays to the overlapping full back; the full back then carries forward with the winger making a 2v1 and crosses or the winger receives and crosses.',
    'Ball switched to the weak side winger',
    'Exploit weak-side superiority for a cross; if the 2v1 fails, recycle to the advancing pivots.',
    NULL, 52, 53, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Blaszczykowski)', 'receive switch, release overlapper or receive back and cross'),
    (2, 'Right full back (Piszczek)', 'provide width, overlap, carry forward'),
    (3, 'Defensive mids (Sahin, Sokratis)', 'push up for recycle')
) AS v(so, role, job);

-- 33. pp.57-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 1: Creating Space On The Flank', 'Winger drops, full back exploits space',
    'With a pivot or centre back on the ball, the winger drops toward an open lane, the opposing full back follows, and our advanced full back runs into the space behind for a long pass. This is the most frequent option and gets many players into the box for the cross.',
    'Opposing full back follows the dropping winger',
    'Full back receives in space on the flank and crosses.',
    NULL, 57, 62, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Reus)', 'drop toward passing lane to pull the full back'),
    (2, 'Full back (Schmelzer)', 'synchronised forward run into freed space'),
    (3, 'Defensive mid / centre back (Bender)', 'long pass into the space')
) AS v(so, role, job);

-- 34. pp.57-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 1: Creating Space On The Flank', 'Winger drops, centre forward exploits',
    'When our full back is deep (or has the ball), the winger drops, his marker follows, and the 9 - if on the strong side - runs across into the freed space for the pass.',
    'Winger''s marker follows; full back deep; 9 on strong side',
    'Centre forward receives on the flank behind the defence.',
    NULL, 57, 64, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'drop to create space'),
    (2, 'Centre forward (Lewandowski)', 'move across into the space when on the strong side'),
    (3, 'Full back / pivot', 'pass into the space'),
    (4, 'No.10', 'on the weak side')
) AS v(so, role, job);

-- 35. pp.57-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 1: Creating Space On The Flank', 'Winger drops, No.10 exploits',
    'When the 9 is on the weak side and the No.10 on the strong side, the winger drops, the opponent full back follows and the 10 runs into the gap; centre backs pinned by the 9 cannot help.',
    'Winger''s marker follows; No.10 on strong side, 9 on weak side',
    'No.10 receives behind the full back and breaks through the defence.',
    NULL, 57, 64, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Reus)', 'drop to pull the full back'),
    (2, 'No.10 (Mkhitaryan)', 'run into the space'),
    (3, 'Centre forward', 'stay central / weak side to pin centre backs'),
    (4, 'Defensive mid or full back', 'play into the No.10''s path')
) AS v(so, role, job);

-- 36. pp.65-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 1: Creating Space On The Flank (practices 3)', 'Winger drops, full-back height picks exploiter',
    'Building up under pressure from two forwards, the strong-side winger comes short and pulls his marker with him, opening the flank space behind. Who attacks it depends on where the full back is (opponent shape not named, two-forward press).',
    'Ball carried or passed into midfield past the first press line',
    'Get a runner into the free space behind the opposition full back with a long pass.',
    NULL, 65, 66, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side winger', 'Drop back towards the ball, drag the marker away from the flank'),
    (2, 'Strong-side full back (high)', 'If already high, sprint into the space the winger left'),
    (3, 'No.10 / centre forward', 'If the full back dropped low to help keep the ball, one of them runs into the flank space'),
    (4, 'Centre forward and No.10', 'Stay on opposite sides of the pitch to keep balance'),
    (5, 'Centre backs / defensive midfielders', 'Keep the ball, then play the forward pass that releases the runner')
) AS v(so, role, job);

-- 37. pp.67-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 1: Creating Space On The Flank (practices 4-6)', 'Flank space vs three-forward press',
    'Against three pressing forwards the No.10 drops very deep to help the build-up, so the centre forward slides to the strong side; when the winger drops and his marker follows, the full back or the centre forward runs into the flank space and crosses (opponent shape not named, three forwards pressing).',
    'Ball dribbled into the midfield zone or passed to the full back high on the side',
    'Exploit the vacated flank and cross for team-mates timing runs into the box.',
    NULL, 67, 71, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'Drop deep to add a man to the build-up against the three forwards'),
    (2, 'Centre forward', 'Position according to the No.10, shift to the strong side to attack the flank space'),
    (3, 'Strong-side winger', 'Drop back to pull his marker out'),
    (4, 'Strong-side full back', 'Overlap into the freed space if he is the best placed, then cross'),
    (5, 'Box runners', 'Time runs into the penalty area for the cross')
) AS v(so, role, job);

-- 38. pp.73-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 2: The Centre Forward Creating Space in the Centre', 'Centre forward drops, No.10 runs beyond',
    'The No.9 drops into the No.10''s zone and the centre back follows him, leaving a hole in the middle of the back line. The No.10, who must be close and have eye contact, swaps with him and runs into the centre-forward space.',
    'No.9 starts dropping while a centre back or deep midfielder has time on the ball',
    'No.10 receives the forward pass in the free central space behind the defence and shoots.',
    NULL, 73, 79, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Lewandowski)', 'Drop towards the ball, pull the marking centre back out'),
    (2, 'No.10 (Mkhitaryan)', 'On seeing the drop, move forward into the centre-forward position and attack the gap'),
    (3, 'Passer (Hummels / Sahin / Piszczek)', 'Play the pass into the space behind once the defender follows the No.9'),
    (4, 'Defensive midfielder (Bender)', 'Step up behind as a back-up passing option if the forward pass is not on')
) AS v(so, role, job);

-- 39. pp.74-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 2: The Centre Forward Creating Space in the Centre', 'No.10 too deep: winger takes forward''s role',
    'When the No.9 drops but the No.10 is too deep to reach the space, the strong-side winger, who can see both, cuts inside to take over the centre-forward role and runs into the space the defender left.',
    'No.9 drops and the No.10 is far away / deep',
    'Keep balance up front so the space created by the forward is still used.',
    NULL, 74, 78, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Lewandowski)', 'Drop and drag his marker'),
    (2, 'Strong-side winger (Aubameyang / Reus)', 'Move diagonally inside into the centre-forward position and receive behind'),
    (3, 'No.10', 'If deep, act as support underneath'),
    (4, 'Deep midfielder (Sahin)', 'Play the forward pass into the winger''s run')
) AS v(so, role, job);

-- 40. pp.80-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 2: The Central Attacking Midfielder (No.10) Creating Space', 'No.10 decoy opens space for forward',
    'The No.10 moves into the open passing lane and a centre back steps out to pressure him; the centre forward then runs into the space that centre back vacated and receives a pass straight from deep.',
    'Centre back steps out towards the No.10',
    'Find the centre forward in the hole left by the stepping defender.',
    NULL, 80, 80, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 (Mkhitaryan)', 'Show in the free passing lane to draw the centre back'),
    (2, 'Centre forward (Lewandowski)', 'Attack the space behind the stepping defender'),
    (3, 'Defensive midfielder (Bender)', 'Pass directly into the forward''s run')
) AS v(so, role, job);

-- 41. pp.80-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 2: Creating Space for the Winger (and Full Back)', 'Forward drags centre back, winger cuts in',
    'The No.10 checks away and sets the full back free on the flank, or a centre back has the ball; the centre forward moves out towards the touchline or drops and his centre back follows, so the winger runs into the gap in the middle. If the winger is tracked by the opposition full back, the full back gets the flank.',
    'Full back or centre back in possession with time, forward''s marker follows him',
    'Release the winger centrally behind the line (3 v 2), or the overlapping full back on the flank.',
    NULL, 80, 81, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Lewandowski)', 'Move towards the sideline or drop to drag his centre back'),
    (2, 'Ball-side winger (Reus)', 'Run into the central space the centre back left'),
    (3, 'No.10 (Mkhitaryan / Reus)', 'Check away from the marker and play first time out to the full back'),
    (4, 'Full back (Schmelzer)', 'Carry forward; if the winger''s marker follows him, use the space on the flank'),
    (5, 'Centre back (Hummels)', 'Choose between the winger''s run and the full back')
) AS v(so, role, job);

-- 42. pp.83-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 3: Creating And Exploiting Space On The Flank By The Same Player', 'Drop, give-and-go, run into own space',
    'Near the flanks where nobody else is close enough, a forward or winger drops off, his marker follows, he plays a quick wall pass with the No.10 and spins on a curved run into the space he himself just opened.',
    'Marker follows the dropping player and no team-mate is near the space',
    'The same player who made the space receives the return ball in behind.',
    NULL, 83, 84, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward / winger (Lewandowski, Reus)', 'Drop to the ball, lay it off first time, then curve forward into the vacated space'),
    (2, 'No.10 (Mkhitaryan)', 'Receive the lay-off and pass straight into the runner''s path'),
    (3, 'Opposite full back', 'Stay in a balanced deep position'),
    (4, 'Deep passer (Hummels / Sahin)', 'Hit the first pass into the dropping player')
) AS v(so, role, job);

-- 43. pp.85-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 3: Getting Free Of Marking With An Up And Down Movement', 'Up and down move to get free',
    'When the passer has time, the forward or winger first runs towards goal so his marker goes with him, then suddenly checks back into the passing lane; the defender is off balance and cannot close, so he receives and turns. Team-mates then run beyond for the killer pass while a full back offers a safety option.',
    'Team-mate on the ball with time and space to pass forward (open ball)',
    'Receive unmarked facing goal, creating a 4 v 4 / 5 v 4 in the final third.',
    NULL, 85, 99, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward / winger (Lewandowski, Reus)', 'Move up to drag the marker, then drop sharply into the lane and turn on the half turn'),
    (2, 'Passer (Kehl, Sahin, Hummels, Schmelzer)', 'Pass the moment the receiver checks back'),
    (3, 'Other attackers (No.10, wingers)', 'Run in behind the line for the next pass'),
    (4, 'Far-side full back (Piszczek)', 'Offer a passing option if the ball in behind is blocked')
) AS v(so, role, job);

-- 44. pp.89-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 3: Getting Free Of Marking By Dropping Deep (Centre Forward)', 'Forward drops deep, defender won''t follow',
    'The centre forward simply drops into the passing lane between the lines; the centre back stays put so as not to leave space behind, so the forward receives unmarked (deeper than with the up-and-down move) and turns. The No.10 moves up to keep balance and wingers make diagonal runs.',
    'Defensive midfielder receives beyond the opposition forwards and turns',
    'Forward turns free, then plays a winger in behind or the overlapping full back.',
    NULL, 89, 92, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Lewandowski)', 'Drop into the lane, receive and turn'),
    (2, 'No.10 (Mkhitaryan)', 'Move forward into the striker position for balance'),
    (3, 'Wingers (Aubameyang, Reus)', 'Diagonal runs in behind once the forward turns'),
    (4, 'Full backs (Piszczek, Schmelzer)', 'One breaks forward as an option, the other drops for balance')
) AS v(so, role, job);

-- 45. pp.90-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 3: Getting Free Of Marking By Dropping Deep (Winger)', 'Winger drops, full back runs: marker''s dilemma',
    'From a three-man build-up, the winger drops into the gap between the opposition midfielders while his full back makes a coordinated forward run. The opposition full back must choose: following the winger opens the flank, so he holds and the winger receives unmarked and turns. If the No.9 is on the weak side, the far winger takes the centre-forward role with a diagonal run.',
    'Vertical lane blocked, ball goes to a defensive midfielder with a lane between the opposition midfielders',
    'Winger turns free creating a 5 v 4 / 6 v 4 attack, then a through ball or cross.',
    NULL, 90, 99, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger (Reus, Blaszczykowski)', 'Drop into the space between midfielders, receive and turn'),
    (2, 'Ball-side full back (Schmelzer, Piszczek)', 'Run forward at the same time so the marker cannot follow the winger'),
    (3, 'Defensive midfielder (Bender, Gundogan)', 'Form the three at the back, find the dropping winger'),
    (4, 'Far winger (Aubameyang)', 'If the No.9 is weak side, take over the forward role with a diagonal run'),
    (5, 'Forwards', 'Run behind the retreating back four for the killer pass')
) AS v(so, role, job);

-- 46. pp.101-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 4: Creating Space In The 2nd Stage With Simple Passing Combinations', '2nd-stage space: third man run',
    'The defender does not follow the centre forward as he drops, but steps out to press as soon as the ball reaches him (the 2nd stage). The No.10 or a winger, already moving, runs into the space that defender leaves and gets a first-time lay pass from the No.9.',
    'Pass played into the dropped centre forward and his marker steps out',
    'Third man receives in behind the line in the gap left by the pressing defender.',
    NULL, 101, 103, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Lewandowski)', 'Drop to offer, then play first time into the third man''s path'),
    (2, 'Third man (No.10 Mkhitaryan or winger Reus)', 'Move forward early for balance and continue into the space'),
    (3, 'Passer (Bender, Hummels, Sahin)', 'Pass into the forward with time and space'),
    (4, 'Defensive midfielder (Bender)', 'Drop back to keep a 3 v 2 at the back')
) AS v(so, role, job);

-- 47. pp.104-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 4: Creating Space In The Centre And Exploiting It With A Complex Passing Combination', '2nd-stage space via two quick passes',
    'As above, the defender only presses the centre forward once he receives, but the third man is reached through an extra player: the No.9 lays off first time to a winger or advanced midfielder, who passes first time into the No.10 (or winger) running through the central gap.',
    'Defender steps to the centre forward on the pass',
    'Break the back line in the centre with fast, synchronised one-touch passes.',
    NULL, 104, 115, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Lewandowski)', 'Drop, receive, lay off first time to the side'),
    (2, 'Wide link (Aubameyang, Blaszczykowski) or advanced midfielder (Bender)', 'Receive the lay-off and pass first time into the runner'),
    (3, 'Runner (No.10 Mkhitaryan or Reus)', 'Move into the striker zone for balance, then attack the gap left by the pressing defender'),
    (4, 'Deep midfielder (Sahin)', 'Play the forward pass when he has time')
) AS v(so, role, job);

-- 48. pp.108-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 4: Creating And Exploiting Space Near The Sidelines In The 2nd Stage', 'Winger drops, full back steps, run behind',
    'A deep midfielder carries forward and the winger drops to receive; the opposition full back leaves him at first but steps out once the ball arrives, so the centre forward (strong side) or the No.10 runs into the space behind that full back, served by a first-time combination.',
    'Pass into the dropping winger and his full back steps to pressure',
    'Get a runner behind the full back near the touchline to cross or finish.',
    NULL, 108, 114, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger (Reus)', 'Drop to receive, play first time inside'),
    (2, 'Centre forward on strong side (Lewandowski)', 'Run into the space behind the full back'),
    (3, 'No.10 / far winger (Mkhitaryan, Blaszczykowski)', 'Link the first-time pass or make the run if the No.9 is weak side'),
    (4, 'Defensive midfielder (Bender)', 'Drop to collect, carry forward, find the winger')
) AS v(so, role, job);

-- 49. pp.117-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 5: Overloading on the Flank with The Centre Back or Defensive Midfielder', 'Free centre back carries ball wide',
    'Against two forwards Dortmund form a back three to free a man; the free centre back or a technical defensive midfielder (Hummels, Sahin, Gundogan) dribbles forward towards the flank to make a 3 v 2 with full back and winger. If the opposing wide midfielder blocks the pass to the full back, the winger drops as the link.',
    'Free player at the back with space to run forward with the ball',
    'Get the ball to the unmarked full back near the sideline with an extra man.',
    NULL, 117, 125, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free centre back / defensive midfielder (Hummels, Sahin)', 'Run forward with the ball towards the flank, draw the wide midfielder'),
    (2, 'Ball-side full back (Schmelzer)', 'Stay wide and free, receive and drive forward'),
    (3, 'Ball-side winger (Reus)', 'Drop into the lane as a link if the direct pass is blocked'),
    (4, 'Covering defensive midfielder (Bender)', 'Drop into the vacated defensive spot for cover'),
    (5, 'Other defensive midfielder (Sahin)', 'Hold a balanced position near the defenders')
) AS v(so, role, job);

-- 50. pp.119-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 5: Tactical Analysis - 2 v 1 on the flank', 'Full back pressed, winger underlaps behind',
    'After the full back receives, a 2 v 1 exists on the flank; when the opposition full back comes to press him, the winger runs inside-to-outside into the space behind for the ball down the line and crosses.',
    'Opposition full back steps up to the ball-carrying full back',
    'Cross from behind the full back for three runners in the box.',
    NULL, 119, 125, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Schmelzer)', 'Drive forward, play the ball down the line'),
    (2, 'Winger (Reus)', 'Underlapping run behind the full back, cross'),
    (3, 'Box runners (No.9, No.10, far winger)', 'Attack the penalty area for the cross')
) AS v(so, role, job);

-- 51. pp.126-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 6: Overloading On The Flank Or In The Centre With The ''No.10'' Moving To Receive', 'No.10 drifts into full back''s zone',
    'The No.10 moves into a passing lane in the opposition full back''s zone, making a 2 v 1 with the winger (wide or tucked in). If the full back presses the No.10, the winger is free; if he holds, the No.10 turns. The same can be done in the centre.',
    'Centre back on the ball, No.10 arrives in the full back''s zone',
    'Overload one defender so either the No.10 or winger breaks through.',
    NULL, 126, 128, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 (Mkhitaryan)', 'Move into the open lane near the winger, receive and turn if not pressed'),
    (2, 'Winger (Reus)', 'If his full back steps out, get free; if inside, go in or out depending on the full back''s spot'),
    (3, 'Centre back (Hummels)', 'Play the pass into the No.10'),
    (4, 'Full back (Schmelzer)', 'Hold width to give the winger room')
) AS v(so, role, job);

-- 52. pp.129-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 6: Overloading on the Flank or in the Centre with a Forward Moving to Receive', 'No.10 drifts strong side for 2v1',
    'Centre back carries the ball up on one side; the No.10 slides into the free passing lane in front of the opposing full back, who now has the winger and the No.10 to watch.',
    'Centre back stepping forward with the ball, lane to No.10 open',
    'No.10 receives unmarked and turns to create a 4v4 or 5v4 with runners into the box.',
    NULL, 129, 130, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 (Mkhitaryan)', 'move into the strong-side lane in front of the full back, receive and turn'),
    (2, 'Ball-side centre back (Hummels)', 'carry forward and feed the No.10'),
    (3, 'Strong-side winger (Reus)', 'pin the full back, then cut inside into the box'),
    (4, 'Strong-side full back (Schmelzer)', 'make an unmarked forward run outside for the pass and cross'),
    (5, 'Centre forward + far winger', 'diagonal runs into the box for the final ball')
) AS v(so, role, job);

-- 53. pp.130-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 6: Overloading on the Flank or in the Centre with a Forward Moving to Receive', 'No.10 overloads a centre back',
    'Holding midfielder has the ball centrally; the No.10 moves to receive just in front of the centre forward, so one opposing centre back has two attackers in his zone.',
    'Holding midfielder free to pass forward',
    'No.10 turns facing goal; if defenders drop to block the forwards, the pass to the right back breaking forward is free for a cross.',
    NULL, 130, 130, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 (Mkhitaryan)', 'receive in front of the centre forward and turn'),
    (2, 'Centre forward (Lewandowski)', 'hold the centre back so he cannot step out'),
    (3, 'Holding midfielder (Sahin)', 'play the vertical pass into the No.10'),
    (4, 'Right back (Piszczek)', 'break forward wide to receive and cross')
) AS v(so, role, job);

-- 54. pp.131-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 6: Tactical Analysis - Overloading with the No.9 Moving to Receive', 'Centre forward drops in front of winger',
    'With the No.10 on the weak side, the centre forward drops back on the ball side in front of the winger, creating a 2v1 on the opposing full back because the centre back does not follow him.',
    'No.10 away from strong side; centre back not tracking the drop',
    'Centre forward receives unmarked, turns and releases the overlapping full back or the No.10''s diagonal run; three players attack the box.',
    NULL, 131, 132, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Lewandowski)', 'drop in front of the winger, receive free and turn'),
    (2, 'Strong-side winger (Reus/Blaszczykowski)', 'stay high to pin the full back'),
    (3, 'No.10 (Mkhitaryan)', 'move up into the centre forward''s spot or make a diagonal run'),
    (4, 'Defensive midfielder (Sahin)', 'drop to keep balance, play the pass in'),
    (5, 'Strong-side full back', 'make a forward run outside for the pass and cross')
) AS v(so, role, job);

-- 55. pp.132-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 6: Tactical Analysis - Overloading with the No.9 Moving to Receive', 'Full back steps out, winger to sideline',
    'When the opposing full back leaves his zone to press the dropping centre forward, the winger he was minding moves out toward the touchline.',
    'Full back steps up onto the dropping forward',
    'Centre forward plays a first-time pass without turning to the winger high on the flank.',
    NULL, 132, 132, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Lewandowski)', 'drop to receive and play first time wide'),
    (2, 'Strong-side winger (Aubameyang)', 'spot the full back stepping and move to the sideline'),
    (3, 'Defensive midfielder (Sahin)', 'play into the dropping forward')
) AS v(so, role, job);

-- 56. pp.133-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 6: Session (4 practices)', 'Forward moves to overload on trigger',
    'Centre backs circulate, then one carries forward or passes to the full back; the moment the centre back carries forward, the No.10 (or the dropping centre forward, with the No.10 staying weak side) moves to the side where a teammate already is to create the overload.',
    'Centre back dribbling forward',
    'The new man in possession turns and either releases the full back or curved-running winger on the sideline or slips a killer pass for a shot or cross.',
    NULL, 133, 138, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10', 'time the move to receive, turn quickly and choose wide pass or killer pass'),
    (2, 'Centre back', 'carry the ball forward as the trigger'),
    (3, 'Full back', 'join the attack only if the ball did not go to him deep'),
    (4, 'Winger', 'curved run outside or attack the box'),
    (5, 'Centre forward', 'drop to overload instead when No.10 is weak side')
) AS v(so, role, job);

-- 57. pp.141-148
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 7: Passing Combination: Vertical or Diagonal + Square Pass', 'Vertical-plus-square pass between lines',
    'Two attackers stand level with each other between the lines (winger and No.10). The pass goes into the wider, more open lane to one, who plays a first-time square pass to the other, who receives on the half turn facing goal.',
    'Lane to the No.10 too narrow, lane to the level teammate open',
    'Defenders have to shift twice, and the receiver gets the ball facing goal to make the final pass quickly.',
    NULL, 141, 148, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Blaszczykowski)', 'shift inside to offer the open lane, pass square first time'),
    (2, 'No.10 (Mkhitaryan)', 'stay level, receive the square pass on the half turn, play forward'),
    (3, 'Centre back / holding midfielder (Hummels/Bender)', 'play the vertical or diagonal pass into the open lane'),
    (4, 'Centre forward + far winger', 'runs to receive the final pass')
) AS v(so, role, job);

-- 58. pp.142-143
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 7: Tactical Analysis - Vertical or Diagonal + Square Pass', 'Centre forward or winger drops for set pass',
    'When the No.10''s lane is blocked and the winger is too far away, the centre forward (or the winger) drops into the open lane to be the first receiver, while another attacker fills the vacated centre forward spot.',
    'No.10 lane blocked by the opposing midfielder, near winger too wide',
    'The dropping player sets the ball square first time to the No.10 facing goal, who carries forward with two passing options; a defender who follows the drop leaves space behind.',
    NULL, 142, 143, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Lewandowski) or winger (Aubameyang)', 'drop into the open lane and set first time'),
    (2, 'No.10 (Mkhitaryan)', 'receive the square pass facing goal and attack'),
    (3, 'Winger (Blaszczykowski)', 'move into the centre forward position to keep balance'),
    (4, 'Weak-side full back (Piszczek)', 'stay deep when both holding midfielders are ahead of the ball')
) AS v(so, role, job);

-- 59. pp.150-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 8: The Lay-Off Passing Combination', 'Lay-off from advanced centre forward',
    'Holding midfielder plays forward to the centre forward high between the lines; while the ball travels, the No.10 moves toward him and receives the lay-off facing goal.',
    'Forward pass into the advanced centre forward',
    'No.10 quickly plays forward to the winger, the spinning centre forward, or the right back breaking forward if forward passes are blocked.',
    NULL, 150, 155, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Lewandowski)', 'get free into the lane high up, lay off first time'),
    (2, 'No.10 (Mkhitaryan)', 'move toward the receiver as the ball travels, take the lay-off facing goal'),
    (3, 'Holding midfielder (Bender)', 'play the forward pass into the centre forward'),
    (4, 'Wingers (Reus/Aubameyang)', 'offer forward options for the next pass'),
    (5, 'Right back (Piszczek)', 'break forward as the outlet')
) AS v(so, role, job);

-- 60. pp.151-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 8: Tactical Analysis - The Lay-Off Combination', 'Winger up-down run takes lay-off',
    'The winger checks up then back to unbalance the opposing full back, and the centre forward gets free; the ball goes into the forward and the winger collects the lay-off.',
    'Full back drawn by the winger''s up-and-down move',
    'Winger receives facing goal in a 5v4 and can shoot, carry inside or pass while the No.10, other winger and full back make runs.',
    NULL, 151, 151, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Reus)', 'up-and-down move, receive the lay-off and attack inside'),
    (2, 'Centre forward (Lewandowski)', 'get free of marking and lay off'),
    (3, 'No.10 + far winger', 'diagonal runs beyond'),
    (4, 'Right back (Piszczek)', 'push forward as a wide option')
) AS v(so, role, job);

-- 61. pp.157-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 9: Passing Combination with a Third Man Run', 'Third man run behind defence',
    'Centre forward drops to receive from the holding midfielder while the No.10 starting at about the same height runs forward at the same moment, in an opposite run.',
    'Pass played into the dropping centre forward',
    'Centre forward plays first time into the No.10 already on the move, who receives behind the back line.',
    NULL, 157, 163, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Lewandowski)', 'drop into the lane (not too deep) and play first time'),
    (2, 'No.10 (Mkhitaryan)', 'start level, run forward as the ball goes in, choose the path'),
    (3, 'Holding midfielder (Bender)', 'pass into the centre forward''s feet'),
    (4, 'Left winger (Reus)', 'can be the third man in the same combination')
) AS v(so, role, job);

-- 62. pp.159-159
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 9: Assessment', 'Third man only works high and stretched',
    'The third-man combination needs the runner high up the pitch and an opposing back line stretched with gaps between defenders; it was used the same way on both sides.',
    'Defence stretched, runner already high',
    'Use the third-man run only when there is space between defenders to run into.',
    NULL, 159, 159, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Third man (No.10 or winger)', 'stay high, not deep, before the combination'),
    (2, 'Front line', 'stretch the back line to open gaps')
) AS v(so, role, job);

-- 63. pp.165-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 10: Direct Play', 'Long ball to forward under pressure',
    'When the opposition forwards press the build-up, defenders avoid a risky short pass and go long to the centre forward (or back to the keeper); long passes from near the touchline turn into poor-angle crosses.',
    'Centre back pressed by the opposing striker',
    'Bypass the press and get the ball close to the opposition box quickly.',
    NULL, 165, 166, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Subotic)', 'play long to the centre forward instead of a risky short pass'),
    (2, 'Goalkeeper (Weidenfeller)', 'safe option if no long ball is on'),
    (3, 'Centre forward (Lewandowski)', 'target for the header or pass')
) AS v(so, role, job);

-- 64. pp.166-175
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 10: Long Pass to the Centre Forward Who Directs it Towards an Attacking Midfielder', 'Support run depends on distance to forward',
    'How the nearest attacking midfielder or winger reacts to the long ball depends on where he stands relative to the centre forward: close or level means run in behind; far or deeper means support underneath.',
    'Long ball played toward the centre forward',
    'Someone always arrives for the flick-on behind or the knock-down/lay-off in front.',
    NULL, 166, 175, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 / winger close or level', 'run into the space behind the forward for the flick or pass'),
    (2, 'No.10 / winger far or deeper', 'move into a supporting position for the back header or lay-off'),
    (3, 'Centre forward (Lewandowski)', 'drop back to win the ball when the pass is aimed deeper, direct it to the runner'),
    (4, 'Centre back (Subotic)', 'aim the long ball according to the gap between the two')
) AS v(so, role, job);

-- 65. pp.169-175
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 10: The Team''s Reaction to the Long Pass Towards the Centre Forward (Second Ball)', 'Swarm the second ball',
    'As soon as the long ball goes, the midfielders converge quickly and together on the target area, the full backs close in near the opposing wingers, and the centre backs push up for compactness.',
    'Long pass played toward the centre forward',
    'Numerical superiority wins the second ball, and the team attacks aggressively straight after; it changes the tempo of the game.',
    NULL, 169, 175, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders (No.10, wingers, holding mids)', 'rush to where the header or clearance will drop; strong-side runners go in behind'),
    (2, 'Full backs', 'squeeze in near the opposition wingers for long clearances'),
    (3, 'Centre backs', 'step forward to keep the team compact'),
    (4, 'Back three left behind', 'keep a 3v2 against the opposing forwards')
) AS v(so, role, job);

-- 66. pp.177-182
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 11: Long Passes in Behind the Defence (From the Centre)', 'Blind-side run for long pass',
    'A technically good deep player (centre back or holding midfielder) has time and space and carries forward; the centre forward moves onto the blind side of a centre back so the defender cannot watch ball and man.',
    'Ball carrier free with time; forward on defender''s blind side',
    'Long diagonal ball in behind finds the forward already moving, ahead of a defender not ready to drop.',
    NULL, 177, 182, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-playing centre back / midfielder (Hummels, Sahin, Gundogan)', 'carry forward, spot the run, play an accurate long diagonal'),
    (2, 'Centre forward (Lewandowski) or weak-side forward', 'slip onto the centre back''s blind side and time the run'),
    (3, 'Right centre back (Sokratis)', 'feed the passer')
) AS v(so, role, job);

-- 67. pp.183-184
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 11: Long Passes in Behind the Defence (From the Sidelines)', 'Full back crosses early behind line',
    'When build-up runs near the touchline and the full back receives high enough with time (opponent''s wide midfielder has tucked in to block the inside lane), he delivers early into the space behind the defenders.',
    'Full back receives high with space; vertical lane blocked',
    'Forwards attack the space behind the back line on the move.',
    NULL, 183, 184, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Schmelzer)', 'receive high and cross early behind the defence'),
    (2, 'Centre back (Hummels)', 'find the full back when the vertical lane is blocked'),
    (3, 'Centre forward + far winger', 'run into the box behind the defenders')
) AS v(so, role, job);

-- 68. pp.183-184
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 11: Long Passes in Behind the Defence (From the Sidelines)', 'Winger runs behind full back',
    'When the full back receives deeper and is closed down before he can reach a crossing angle, the winger makes a timed run behind the opposing full back and the ball goes down the line to him.',
    'Full back deep and closed down by the opposing winger',
    'Winger receives in behind and crosses for the No.10, No.9 and far winger arriving in the box.',
    NULL, 183, 184, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Schmelzer)', 'receive deeper, play down the line in behind'),
    (2, 'Left winger (Reus)', 'time the run behind the right back, receive and cross'),
    (3, 'Right back (Piszczek)', 'stay deep for balance when both opposing midfielders are high'),
    (4, 'No.10, No.9, far winger', 'attack the box')
) AS v(so, role, job);

-- 69. pp.186-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 12: Switching Play - The Full Back Providing Width and the Winger Inside', 'Switch to wide full back, winger inside',
    'With the weak-side winger tucked between the lines, the weak-side full back holds the width (pushed high because the opposing No.6 dropped, leaving a 3v2 at the back). The holding midfielder switches to him and he drives forward.',
    'Holding midfielder able to switch; opposition shifted to the ball side',
    'Winger''s diagonal run or supporting position creates a 2v1 on the flank or a 4v3 around the box, leading to a cross or a pass to an unmarked attacker.',
    NULL, 186, 192, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side full back (Piszczek)', 'hold width high, receive the switch, drive forward'),
    (2, 'Weak-side winger (Blaszczykowski)', 'diagonal run outside or support between lines, receive and cross or one-two with the forward'),
    (3, 'Holding midfielder (Bender)', 'play the long switch'),
    (4, 'Centre forward + No.10 + far winger', 'attack the box, the No.9 with a diagonal run')
) AS v(so, role, job);

-- 70. pp.187-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 12: Switching Play - The Full Back Providing Width and the Winger Inside', 'Ball carrier reads three options',
    'After the switch, the defender who closes down the winger leaves space behind him, a 1v1 out wide, or a 2v2 in the box, depending on how he reacts.',
    'Opposing centre back steps out to the winger',
    'The man on the ball reads the defender''s choice and picks the free option: space behind, isolated full back, or attackers inside.',
    NULL, 187, 192, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back on the ball', 'read the defender''s reaction and choose the free option'),
    (2, 'Winger', 'go into the space left behind the stepping defender'),
    (3, 'Centre forward + No.10', 'stay in the box against the reduced back line')
) AS v(so, role, job);

-- 71. pp.188-188
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 12: Switching Play - The Full Back Providing Width and the Winger Inside', 'Compact opponent: winger lays back, overlap',
    'When the opponent is compact and the winger receiving the switch is closed down before he can go inside, he passes back to the full back and runs to help outnumber the flank.',
    'Winger closed down by the opposing midfielder',
    'Full back advances and crosses or uses the winger; if no overload is possible, the ball is recycled to the holding midfielder or centre back.',
    NULL, 188, 188, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side winger (Blaszczykowski)', 'lay back to the full back, then make a supporting/overlapping run'),
    (2, 'Weak-side full back (Piszczek)', 'carry forward and cross or combine'),
    (3, 'Holding midfielder / centre back (No.18 / No.4)', 'safe recycle option')
) AS v(so, role, job);

-- 72. pp.188-191
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 12: Switching Play - The Full Back Providing Width and the Winger Inside', 'Switch to winger between lines',
    'The centre back switches straight to the winger standing between the lines on the far side while the full back runs forward, which stops the opposing full back from stepping out onto the winger.',
    'Opponent not compact; winger free between the lines',
    'Winger carries forward and inside against a retreating back line (5v4) for a killer pass to diagonal runners or the overlapping full back.',
    NULL, 188, 191, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side winger (Blaszczykowski)', 'receive between the lines, drive forward and inside'),
    (2, 'Weak-side full back (Piszczek)', 'run forward to pin the opposing full back and offer the flank option'),
    (3, 'Centre back (Hummels)', 'play the long switch to the winger'),
    (4, 'Centre forward + far winger', 'diagonal runs for the killer pass')
) AS v(so, role, job);

-- 73. pp.193-196
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 12: Switching Play (session practices 4-7)', 'Read the weak-side defence after a switch',
    'After the ball is switched to the weak-side full back or winger, the attackers choose their movements from how the nearest defenders react rather than a fixed pattern.',
    'Switch arrives at weak-side full back/winger; watch whether opposing full back or centre back steps out',
    'Exploit whichever space the stepping defender leaves, usually a 2 v 1 on the flank or at the far post.',
    NULL, 193, 196, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side full back (Schmelzer/Piszczek)', 'receive the switch in a central or advanced zone and attack the space'),
    (2, 'Weak-side winger', 'if the opposing full back jumps him, release the full back into the space behind'),
    (3, 'Centre forward', 'if a centre back leaves to close the winger, slide into the hole he leaves'),
    (4, 'No.10 and far winger', 'attack the far post / penalty spot for the cross')
) AS v(so, role, job);

-- 74. pp.197-197
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 12: Switching Play', 'Long switch, deep winger overlaps full back',
    'Centre back (Hummels) hits a long switch to the wide full back while the winger is deep and central; if a holding midfielder screens the centre, the winger cannot receive inside.',
    'Full back receives the switch and the opposition DM drops to close the inside lane',
    'Winger overlaps outside the full back to make 2 v 1 on the flank and cross.',
    NULL, 197, 197, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side centre back (Hummels)', 'long diagonal switch to the far full back'),
    (2, 'Weak-side full back (Piszczek)', 'push into an advanced wide position, receive and carry forward'),
    (3, 'Winger (Blaszczykowski)', 'start deep and central, then overlap when the inside lane is shut'),
    (4, 'Centre forward and midfielders', 'fill the box for the cross')
) AS v(so, role, job);

-- 75. pp.198-198
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 12: Switching Play', 'Advanced winger drags full back inside',
    'With the winger high, he cuts inside on the strike of the long ball to offer a target for a flick from the centre forward behind the line, pulling the opposing full back with him.',
    'Centre back shapes to play the long switch',
    'Full back receives unmarked high on the flank and crosses; if the opposing full back ignores the winger and closes the full back, the winger offers a 1-2 or turns inside.',
    NULL, 198, 198, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Blaszczykowski)', 'run inside to drag the full back; offer the 1-2 if he is not followed'),
    (2, 'Full back (Piszczek)', 'receive in the freed space high up and deliver the cross'),
    (3, 'Centre forward (Lewandowski)', 'be the long-ball target and flick in behind if it comes to him'),
    (4, 'Centre back (Hummels)', 'play the long pass after receiving from the DM')
) AS v(so, role, job);

-- 76. pp.199-200
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'in_possession', 'Attacking Tactical Situation 12: Switching Play', 'Winger holds width, full back overlaps or underlaps',
    'The switch goes to the winger near the touchline (or both winger and full back are wide). The full back runs past him: outside if the opposing full back steps up, through the gap if the winger is double marked.',
    'Opposing full back closes the winger, or two defenders double the winger',
    'Create 2 v 1 on the flank and get a cross or a pass in behind the defensive line.',
    NULL, 199, 200, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Blaszczykowski)', 'receive wide, fix the full back, release the overlap up the line'),
    (2, 'Full back (Piszczek)', 'overlap behind the full back; underlap between two markers if the winger is doubled'),
    (3, 'Defensive midfielder (Bender)', 'play the switch to the winger'),
    (4, 'Centre forward (Lewandowski)', 'offer a 1-2 option near the box')
) AS v(so, role, job);

-- 77. pp.204-220
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'to_attack', 'Chapter 6 / Positive Transition Tactical Situation 1: Direct Positive Transition (CF is first defender)', 'Direct positive transition: CF takes the flank',
    'Defending in the middle third, Dortmund leave free space on the strong side, in the central zone and on the weak side. When the ball is won high with no pressure on the winner and the centre forward was the strong-side first defender, everyone runs forward into those spaces at once.',
    'Interception high enough up with no pressure on the new ball carrier',
    'Fast counter finished within seconds: cross for runners in the box or cutback to the edge of the area.',
    NULL, 204, 220, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Lewandowski)', 'run to the space by the touchline behind the full back for the first pass, or pin his marker wide'),
    (2, 'No.10 (Mkhitaryan)', 'run between the two centre backs; if they stay apart, receive in the gap and shoot'),
    (3, 'Weak-side winger (Aubameyang)', 'diagonal run to beat the full back into the box; receive the through pass if the near CB stays wide'),
    (4, 'Ball winner (winger Reus / DM Kehl / Gundogan)', 'pass forward at once into the forward''s run, then move inside'),
    (5, 'Defensive midfielders', 'one supports at the edge of the box, the other stays deeper')
) AS v(so, role, job);

-- 78. pp.206-224
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'to_attack', 'Chapter 6: The Transition From Defence To Attack (recurring principle)', 'Stay balanced behind the counter',
    'In every counter only the runners into the three free spaces commit; the rest keep shape so the team is safe if the attack breaks down.',
    'Counter attack launched after a regain',
    'Keep good shape and cover while the forwards finish the attack.',
    NULL, 206, 224, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding defensive midfielder', 'stay in the deeper position while the partner supports outside the box'),
    (2, 'Opposite full back', 'if one full back goes forward, the other stays deep'),
    (3, 'Centre backs', 'hold positions for safety at the back')
) AS v(so, role, job);

-- 79. pp.209-242
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'out_of_possession', 'Positive Transition Tactical Situations 1 and 4 (how the ball is won)', 'Jump the receiver, double on the touchline',
    'In the middle-third block, the nearest Dortmund player closes the receiver of the opponent''s forward or wide pass immediately so he cannot turn; near the sideline a second player arrives to double mark.',
    'Opponent passes into midfield or out to a wide player near the touchline',
    'Win the ball high with space ahead so a direct transition is possible.',
    NULL, 209, 242, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defensive midfielder (Kehl)', 'close the receiver instantly and win the duel'),
    (2, 'Full back (Schmelzer)', 'step onto the winger who receives near the line to stop him turning'),
    (3, 'Second presser (DM or winger)', 'join to double mark near the touchline'),
    (4, 'Centre back (Hummels)', 'step in to attack a long ball into the striker and intercept')
) AS v(so, role, job);

-- 80. pp.211-220
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'to_attack', 'Positive Transition Tactical Situation 1: Direct Positive Transition (No.10 is first defender)', 'Direct transition: No.10 takes the flank',
    'When the No.10 pressed the centre back on the strong side, the centre forward stayed high; on the regain the No.10 attacks the strong-side space and the striker attacks the middle or the blind side of the weak-side centre back.',
    'Ball won on the strong side with the No.10 near the touchline and the CF still high',
    'Give the man in possession three forward options (flank, between centre backs, weak side) and pick the best.',
    NULL, 211, 220, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'No.10 (Mkhitaryan)', 'move into the free space on the strong flank to receive'),
    (2, 'Centre forward (Lewandowski)', 'run between the centre backs or to the blind side of the weak-side CB'),
    (3, 'Weak-side winger (Aubameyang)', 'adjust to the striker: fill the central zone if he goes wide, else the weak side'),
    (4, 'Ball winner', 'if he takes a first touch inside, the striker swaps to the weak side and the winger fills the middle'),
    (5, 'Defensive midfielder (Gundogan)', 'move up into support')
) AS v(so, role, job);

-- 81. pp.221-230
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'to_attack', 'Positive Transition Tactical Situation 2: Indirect Positive Transition with a Forward Pass', 'Indirect transition: show in the lane, lay off',
    'When the regain happens high but the ball winner is pressed at once, a pass into space is impossible, so the advanced forward(s) move into a passing lane instead of running in behind, receive and lay off to a midfielder or forward-running winger.',
    'Ball won but the new carrier is immediately under pressure with no time to look forward',
    'Turn a pressured regain into an open ball situation via forward pass + back/lay-off pass, then attack the free spaces.',
    NULL, 221, 230, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Most advanced forward (Lewandowski)', 'drop into the open passing lane, receive and lay off first time'),
    (2, 'No.10 (Mkhitaryan)', 'move to receive the lay-off, or be the second lane option when he is on the strong side'),
    (3, 'Wingers (Reus/Aubameyang)', 'run forward to take the lay-off or attack the space after it'),
    (4, 'Weak-side full back (Piszczek)', 'push on to give a safe outlet if the forward pass is blocked'),
    (5, 'Ball winner (Kehl)', 'play the first forward pass into the showing forward')
) AS v(so, role, job);

-- 82. pp.231-238
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'to_attack', 'Positive Transition Tactical Situation 3: Indirect Positive Transition with a Switch of Play', 'Indirect transition: switch to the breaking full back',
    'When pressure and the opponent''s shift block both the pass into space and the pass to the forward''s feet, the ball carrier dribbles or passes sideways and the ball is switched to the weak-side full back who sprinted forward on the regain.',
    'Forward pass impossible; opponents compress the ball side',
    'Attack the weak flank as in the switching-play patterns; slower than the other two transition types.',
    NULL, 231, 238, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (Kehl)', 'carry or pass horizontally away from the pressure, then switch'),
    (2, 'Weak-side winger (Aubameyang)', 'run forward to clear space for the full back, then run behind the full back for the pass'),
    (3, 'Weak-side full back (Piszczek)', 'break forward the moment the ball is won, receive the switch, pass down the line or inside'),
    (4, 'Forwards (Lewandowski, Mkhitaryan)', 'try to show in lanes first, then arrive in the box for the cross')
) AS v(so, role, job);

-- 83. pp.239-248
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'to_attack', 'Positive Transition Tactical Situation 4: Direct Positive Transition (Both the Centre Forward and the No.10 on the Strong Side)', 'Both forwards strong side: 2 v 1 on the CB',
    'When both the No.10 and centre forward end up on the strong side, they both break to the flank to create 2 v 1 against the near centre back near the touchline; the weak-side winger shifts in to become the centre forward and the other winger arrives at the edge of the box.',
    'Regain on the strong side with CF and No.10 both close to the ball',
    'Use the flank overload to get a forward in behind the centre back, then cross or cut back; the weak-side space is left empty.',
    NULL, 239, 248, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First forward (No.10 or CF)', 'move to the free space by the touchline to receive'),
    (2, 'Second forward', 'run in behind the near centre back to complete the 2 v 1'),
    (3, 'Weak-side winger (Aubameyang)', 'come inside and take over the centre forward role in the central zone'),
    (4, 'Strong-side winger (Reus)', 'move inside to arrive just outside the box'),
    (5, 'Defensive midfielder (Gundogan)', 'if the CB wins a long ball, carry forward and pick from three options')
) AS v(so, role, job);

-- 84. pp.249-252
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'to_attack', 'Positive Transition Tactical Situation 5: Indirect Positive Transition (Both the Centre Forward and the No.10 on the Strong Side)', 'Both forwards strong side: first-time lay to flank',
    'Regain on the strong side under immediate pressure with both forwards nearby: the striker shows in the passing lane and plays first time to the No.10 running into the space on the flank or into the central zone.',
    'Ball won high, carrier pressed, CF and No.10 both near the ball',
    'Create an open ball situation, then counter as in the direct transition with a cross or edge-of-box pass.',
    NULL, 249, 252, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (Lewandowski)', 'move into the passing lane and pass first time'),
    (2, 'No.10 (Mkhitaryan)', 'run forward into the central zone or the free flank space to receive'),
    (3, 'Weak-side winger (Aubameyang)', 'fill the central zone or attack the weak-side space'),
    (4, 'Ball winner (Reus / Schmelzer)', 'give the quick forward pass to the showing striker')
) AS v(so, role, job);

-- 85. pp.253-253
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jurgen-klopp-s-attacking-tactics-tactical-analysis-and-sessions-from-borussia-do'), 'to_attack', 'Positive Transition Tactical Situation 5: Indirect Positive Transition with a Switch of Play (Both CF and No.10 on Strong Side)', 'Both forwards strong side: switch to weak full back',
    'Centre back intercepts and gives to a DM who is pressed while the opponents shift back to block forward passes; the DM switches to the weak-side full back who has run into the free space.',
    'DM in possession pressed, forward passes blocked',
    'Full back carries on and either passes down the line for the winger to cross or inside for a final pass in behind.',
    NULL, 253, 253, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Hummels)', 'intercept the long ball and pass to the DM'),
    (2, 'Defensive midfielder (Gundogan)', 'switch to the weak side'),
    (3, 'Weak-side full back (Piszczek)', 'run forward into the free space and choose line or inside'),
    (4, 'Forwards and other DM (Kehl)', 'move into advanced positions; DM steps between the lines')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1967-coaching-book-klopp-attacking-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
