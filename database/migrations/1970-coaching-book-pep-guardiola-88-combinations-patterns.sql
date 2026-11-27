-- 1970 📚 Coaching book patterns: "Pep Guardiola - 88 Attacking Combinations" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Pep Guardiola - 88 Attacking Combinations and Positional Patterns of Play',
    subtitle    = 'Direct from Pep''s Training Sessions (Vol. 1)',
    author      = 'SoccerTutor.com',
    team        = 'Barcelona B / Barcelona, Bayern Munich, Manchester City',
    season      = '2007-08 to 2017-18',
    method_note = 'A compilation of attacking patterns from Guardiola''s training sessions: Barcelona B 2007-08 and the first team, Bayern 2015 and Manchester City 2017-18 (including the July 2017 Nashville pre-season session in a 3-5-2). It opens with his positional-play principles (juego de posición, pitch zones, half spaces, width first then run in behind), then gives positional patterns rehearsed unopposed or against mannequins by two teams of ten in turn: 4-3-3 with inverted full backs (2-3-2-3), 4-3-3 with regular full backs, Barcelona''s 4-3-3, City''s 3-5-2, then combination, finishing and speed circuits. Patterns are the fixed passing sequences and the movements they rehearse, in our words, with who does what.'
WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f');

-- 1. pp.13-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Pep Guardiola''s Attacking Philosophy: Key Aspects / Rules and Aims', 'Width first, then runs in behind',
    'Against a deep defence the team first stretches the pitch wide and circulates with short combinations to move defenders out of shape, building up gradually as a unit. Only after controlled possession does it arrive at the box with many players.',
    'Opponent defending deep and compact',
    'Defensive structure is disorganised so a pass in behind or a cross meets several attackers arriving in the box.',
    NULL, 13, 17, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'Hold maximum width, then attack the space in behind once the block is moved'),
    (2, 'Midfield trio', 'Use third-man combinations through triangles to free a man between lines'),
    (3, 'Back line', 'Push up with the team and keep a high line with an extra man in defence'),
    (4, 'Front players', 'Arrive in the penalty area in numbers for the final ball')
) AS v(so, role, job);

-- 2. pp.15-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Positional Play (Juego de Posicion) / Training Pitch Zones / Half Spaces', 'Wingers pin wide, half-space midfielders receive',
    'Against an organised block, wingers stay high on the touchline in the upper wide zones to fix the opposing full backs, leaving the inside channels between full back and centre back free. The most creative midfielders take up positions in those half spaces to receive between the lines.',
    'Settled possession in the opponent half',
    'An attacking midfielder receives unmarked in the half space, turns and plays the final pass in behind.',
    NULL, 15, 19, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'Stay wide and high at the edge of the pitch, occupy full backs, only activate for runs in behind late'),
    (2, 'Attacking midfielders (Silva, De Bruyne / Xavi, Iniesta)', 'Find the half space between lines, receive half-turned, look for a pass in behind'),
    (3, 'Defensive midfielder', 'Hold the central position and feed the half space'),
    (4, 'All players', 'Hold assigned zones and spacing; never leave position just to chase the ball')
) AS v(so, role, job);

-- 3. pp.16-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Manchester City''s 2-3-2-3 Attacking Formation (4-3-3) / Inverted Full Backs', 'Inverted full backs form 2-3-2-3',
    'In possession the 4-3-3 becomes a 2-3-2-3: both full backs step inside into the half spaces beside the defensive midfielder, creating four lines and a central overload. The holding midfielder no longer has to cover his flanks.',
    'Team gains settled possession / build-up from centre backs',
    'Numerical superiority in the middle third and safe progression from centre backs to the attacking midfielders or forward.',
    NULL, 16, 28, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (Walker, Zinchenko, Delph, Sagna)', 'Move inside into the half spaces, receive from CBs and help move the ball through lines'),
    (2, 'Defensive midfielder (Fernandinho)', 'Stay central without shuttling to cover wide'),
    (3, 'Centre backs (Stones, Otamendi)', 'Pass into DM or an inverted full back, then on to forward or AM'),
    (4, 'Wingers (Sterling, Sane)', 'Stay wide to pin defenders; engage only in the final stage with runs behind, finishes or low crosses')
) AS v(so, role, job);

-- 4. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Building Up Play from the GK: 3v3 Situation Out Wide (Example A)', 'Goal kick: winger bounce to full back',
    'From a goal kick the GK plays the centre back, who carries forward into a 3v3 on the flank. The opposing winger screens the pass to our full back and our DM is tightly marked.',
    'Pass to full back blocked and DM marked',
    'Winger''s first-time bounce frees the full back to run forward into the space and carry the ball up.',
    NULL, 22, 22, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Receive from GK, dribble forward to commit, pass into the dropping winger'),
    (2, 'Winger', 'Drop toward the ball dragging his marker, play first time to the full back'),
    (3, 'Full back', 'Run forward past the blocking winger to receive and dribble into space')
) AS v(so, role, job);

-- 5. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Building Up Play from the GK: 3v3 Situation Out Wide (Example B)', 'Goal kick: winger bounce inside to DM',
    'Same goal-kick 3v3 out wide, but now the pass to the DM is screened and our full back is closely marked.',
    'Pass to DM blocked and full back marked',
    'Winger''s first-time inside pass finds the DM running forward behind the screening attacker.',
    NULL, 23, 23, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Carry forward and pass to the dropping winger'),
    (2, 'Winger', 'Drop with his marker, lay first time inside to the DM'),
    (3, 'Defensive midfielder', 'Move forward off the blocker to receive and dribble into space')
) AS v(so, role, job);

-- 6. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Building Up Play from the GK: 3v3 Situation Out Wide (Example C)', 'Goal kick: CB direct to free full back',
    'Same goal-kick 3v3; the winger drops and pulls his marker, but the opposing winger slides across to block that pass while our DM is still marked.',
    'Pass to winger blocked and DM marked',
    'The opposing winger''s shift leaves our full back free, so the CB passes straight out wide for him to carry forward.',
    NULL, 24, 24, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Read the blocked lane and play directly to the full back'),
    (2, 'Winger', 'Drop to draw the opposing winger across'),
    (3, 'Full back', 'Receive unmarked and dribble forward into the space')
) AS v(so, role, job);

-- 7. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '4-3-3 with Inverted Full Backs: 1. Both Attacking Midfielders Combine Through the Centre', 'Half-space AM feeds other AM centrally',
    'Centre back to inverted right back, inside to the DM who carries and plays diagonally into the left AM in the half space. The left AM drifts inside and slips the other AM, who also moves inside and dribbles into the box.',
    'DM receives facing forward with the half space open',
    'Second attacking midfielder runs at goal centrally and shoots, with front three following in for rebounds.',
    NULL, 31, 31, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted right back (Sagna)', 'Receive from CB inside and pass to DM'),
    (2, 'Defensive midfielder (Fernandinho)', 'Carry forward, diagonal pass into left half space'),
    (3, 'Left attacking midfielder (De Bruyne)', 'Receive in half space, shift inside, pass to the other AM on the move'),
    (4, 'Right attacking midfielder (Silva)', 'Move inside, receive, dribble into the box and shoot'),
    (5, 'Forward and both wingers', 'Run into the penalty area to follow up rebounds')
) AS v(so, role, job);

-- 8. pp.32-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '4-3-3 with Inverted Full Backs: 2. AM Moves Inside for Forward''s Lay-off, Pass in Behind to Winger', 'Forward lay-off, AM slides winger behind',
    'After CB, inverted RB and DM, the ball goes diagonally to the left AM in the half space, who plays into the forward. The forward lays back to the right AM shifting into the centre.',
    'Forward receives with back to goal and an AM arriving inside',
    'Right AM opens up and plays a diagonal ball in behind for the right winger to finish.',
    NULL, 32, 32, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left attacking midfielder', 'Receive in half space, pass into the forward'),
    (2, 'Forward (Aguero)', 'Lay off first time to the arriving AM'),
    (3, 'Right attacking midfielder', 'Shift into the centre, receive, open body and pass diagonally in behind'),
    (4, 'Right winger (Sterling)', 'Hold width then run in behind the full back to receive and score')
) AS v(so, role, job);

-- 9. pp.33-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '4-3-3 with Inverted Full Backs: 3. / 5. Pass in Behind to Winger from the Half Space + Cut Back', 'Half-space AM releases winger, cut-back',
    'The left AM gets the ball in the half space, either straight from the DM''s diagonal or from a dropping forward''s pass, and carries inside before passing in behind for the left winger''s run. The winger drives on and cuts back.',
    'AM in half space facing goal with winger starting his run outside the full back',
    'Low cut-back to an AM or the forward arriving centrally to score.',
    NULL, 33, 35, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Diagonal into the half space, or into the dropping forward'),
    (2, 'Forward', 'Drop slightly and pass to AM in half space (p35 version); then attack the box'),
    (3, 'Left attacking midfielder', 'Carry inside and play the pass in behind'),
    (4, 'Left winger (Sane)', 'Run in behind, carry and cut the ball back'),
    (5, 'Right AM, forward, right winger', 'Make timed runs into the box for the cut-back')
) AS v(so, role, job);

-- 10. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '4-3-3 with Inverted Full Backs: 4. AM Moves Inside for Forward''s Lay-off, Dribble in Behind and Finish', 'Forward drops, lay-off, AM dribbles through',
    'The DM plays straight into the forward who drops off the back line. The right AM moves across inside to take the lay-off on the run.',
    'Forward drops and draws a centre back',
    'AM dribbles into the space in behind and into the box to shoot.',
    NULL, 34, 34, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Pass forward into the dropping striker'),
    (2, 'Forward', 'Drop slightly, lay off first time'),
    (3, 'Right attacking midfielder', 'Shift inside, receive the lay-off running, dribble through and finish')
) AS v(so, role, job);

-- 11. pp.36-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '4-3-3 with Inverted Full Backs: 6. / 7. Lay-off to AM for Pass in Behind (from DM or Full Back)', 'Lay-off, then through ball for AM diagonal run',
    'The forward drops to receive (from the DM, or directly from the inverted right back after a forward touch) and lays off to the right AM moving inside. That AM threads a pass between the two centre backs for the left AM''s diagonal run.',
    'Forward receives back to goal, both AMs close to him',
    'Second AM runs diagonally through the centre-back gap, takes a touch and scores.',
    NULL, 36, 37, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted right back', 'Pass to DM, or step forward and pass diagonally into the forward'),
    (2, 'Forward', 'Drop off, lay off to the near AM'),
    (3, 'Right attacking midfielder', 'Move inside, play through pass between centre backs'),
    (4, 'Left attacking midfielder', 'Diagonal run through the gap, receive and finish')
) AS v(so, role, job);

-- 12. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '4-3-3 with Inverted Full Backs: 8. DM''s Diagonal Aerial Pass in Behind to the Winger + Cut Back', 'Switch via inverted left back, aerial diagonal',
    'Ball moves across the back from right CB to left CB to the inverted left back, who finds the DM arriving on a curved run. The DM turns and lofts a diagonal ball in behind for the far-side winger.',
    'DM receives facing play with the weak-side winger free outside his full back',
    'Winger carries in and cuts back, here to the opposite winger at the back post.',
    NULL, 38, 38, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Circulate across to the left side'),
    (2, 'Inverted left back (Kolarov)', 'Receive and pass inside to DM'),
    (3, 'Defensive midfielder', 'Curved run to receive, open up, aerial diagonal in behind to right winger'),
    (4, 'Right winger (Sterling)', 'Run in behind, carry, cut back'),
    (5, 'Left AM, forward, left winger', 'Attack the box; far winger arrives at back post')
) AS v(so, role, job);

-- 13. pp.43-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '4-3-3 with Regular Full Backs: 1. Forward''s Lay-off for AM to Play in Behind to Winger', 'AM-DM wall, forward lay-off, winger behind',
    'With full backs staying wide, the CB plays directly into the left AM in the half space, who bounces it to the DM curving across. The DM carries and plays into the forward, who lays back to the other AM moving inside.',
    'AM in half space under pressure with DM arriving on a curved run',
    'Second AM plays a diagonal in behind for the winger, whose low cross is attacked by forward, AM and far winger.',
    NULL, 43, 43, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Stones, Otamendi)', 'Switch across, then pass into the AM in the half space'),
    (2, 'Left attacking midfielder (Gundogan)', 'Receive in half space, lay off to DM'),
    (3, 'Defensive midfielder', 'Curved run to collect the lay-off, carry, pass into forward'),
    (4, 'Forward', 'Lay off to the other AM, then attack the box'),
    (5, 'Right attacking midfielder (De Bruyne)', 'Move inside, open up, diagonal pass in behind'),
    (6, 'Right winger', 'Run behind, low cross for runners')
) AS v(so, role, job);

-- 14. pp.44-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '4-3-3 with Regular Full Backs: 2. Forward''s Dummy for AM to Run onto and Score', 'Forward steps over for third-man runner',
    'The right AM receives in the half space and lays off to the DM on his curved run. The DM drives a pass toward the forward, who steps over it.',
    'DM passes into the forward with the far AM ready to run',
    'The dummy lets the far AM''s third-man run collect the ball behind the line and shoot.',
    NULL, 44, 44, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right attacking midfielder', 'Receive in half space, set the DM'),
    (2, 'Defensive midfielder', 'Curved run, pass into the forward''s feet line'),
    (3, 'Forward', 'Dummy (step over the ball) to wrong-foot the centre backs'),
    (4, 'Left attacking midfielder', 'Third-man run onto the ball and shoot')
) AS v(so, role, job);

-- 15. pp.45-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '4-3-3 with Regular Full Backs: 3. Forward''s Through Ball for AM''s Third-Man Run', 'Forward first-time through ball, third-man run',
    'Left AM in the half space sets the DM, who carries and plays into the forward. The forward drops and plays first time in behind for the opposite AM''s third-man run.',
    'Forward receives dropping with the far AM starting a forward run',
    'AM dribbles into the box and finishes.',
    NULL, 45, 45, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left attacking midfielder', 'Receive in half space, lay off to DM'),
    (2, 'Defensive midfielder', 'Curved run, carry, pass to forward'),
    (3, 'Forward', 'Drop, first-time pass in behind'),
    (4, 'Right attacking midfielder', 'Third-man run in behind, dribble in and finish')
) AS v(so, role, job);

-- 16. pp.46-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '4-3-3 with Regular Full Backs: 4. DM''s Combination in the Centre + Diagonal Aerial Pass in Behind', 'Double lay-off to DM, aerial ball behind',
    'Right AM in the half space sets the DM, who passes to the left AM moving into the centre. That AM lays off again to the DM moving forward.',
    'DM receives the second lay-off facing forward',
    'DM lofts a diagonal pass in behind to the left winger, who dribbles on and crosses low for the forward to score centrally.',
    NULL, 46, 46, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right attacking midfielder', 'Receive in half space, set the DM'),
    (2, 'Left attacking midfielder', 'Move central, receive, lay off back to the DM'),
    (3, 'Defensive midfielder', 'Curved run, combine twice, diagonal aerial pass behind'),
    (4, 'Left winger', 'Run in behind, carry, low cross'),
    (5, 'Forward', 'Attack the cross and finish centrally')
) AS v(so, role, job);

-- 17. pp.49-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'FC Barcelona Formation (4-3-3) / Positioning and Receiving in the Half Spaces', 'Forward drops, feeds half-space AM, winger behind',
    'Barcelona 4-3-3 with both wingers wide (the far one too, to keep the centre open). The DM plays into the forward who drops and passes to the right AM in the half space.',
    'Right AM free and able to turn in the half space',
    'AM plays in behind for the right winger''s run, who delivers a low cross or cut-back to team-mates timing runs into the box.',
    NULL, 49, 50, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (7, 11)', 'Stay as wide as possible to occupy defenders; ball-side winger runs behind'),
    (2, 'Defensive midfielder (6)', 'Pass into the dropping forward'),
    (3, 'Forward (9)', 'Drop and pass to the AM in the half space'),
    (4, 'Right attacking midfielder (8)', 'Receive unmarked, turn, play in behind'),
    (5, 'Runners', 'Time arrival in the box for the low cross or cut-back')
) AS v(so, role, job);

-- 18. pp.51-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Positional Patterns of Play (4-3-3)', 'Drop-off lay-off to half-space 8, winger released',
    '4-3-3 build-up: ball travels across the back from right to left, the left 8 in the half space plays inside to the 6, the 6 finds the dropping 9, who lays off to the right 8 receiving in the half space.',
    '9 drops toward the ball with a teammate free in the half space',
    'The half-space 8 turns and slides the right winger in behind for a cross.',
    NULL, 51, 51, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (9)', 'Drops back, sets the ball first time to the far 8'),
    (2, 'Right attacking midfielder (8)', 'Receives in the half space facing goal, plays in behind'),
    (3, 'Right winger (7)', 'Holds width, runs in behind the full back, crosses'),
    (4, 'Defensive midfielder (6)', 'Links the two halves, plays forward into the 9')
) AS v(so, role, job);

-- 19. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Positional Patterns of Play (4-3-3)', 'Long switch to the free weak-side winger',
    'After a combination draws the defence to one side (left winger inside to the 9, back to the left 8 in the half space), the ball is moved quickly to the opposite flank.',
    'Opponent block shifted to the ball side after combination play',
    'Exploit the space out wide on the weak side: winger receives, dribbles forward and crosses.',
    NULL, 52, 52, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left attacking midfielder (10)', 'Receives the set in the half space, hits a long diagonal switch'),
    (2, 'Weak-side winger (7)', 'Stays wide and high, receives the switch, carries and crosses'),
    (3, 'Centre forward (9)', 'Moves across to receive from the winger and lays back'),
    (4, 'Left centre back (4)', 'Medium-length pass out to the winger to start it')
) AS v(so, role, job);

-- 20. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Positional Patterns of Play (4-3-3)', 'Aerial ball for the 8''s third-man run',
    'Ball goes left through the back four to the winger, inside to the 9 coming across, back to the left 8 in the half space, while the opposite 8 runs beyond.',
    'Half-space midfielder receives facing play with a runner arriving from deep',
    'Well-timed diagonal chip in behind for the far 8, who cuts it back for the winger arriving.',
    NULL, 53, 53, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left attacking midfielder (10)', 'Receives set from the 9 in the half space, chips diagonally in behind'),
    (2, 'Right attacking midfielder (8)', 'Third-man run from deep in behind the line, cut-back'),
    (3, 'Left winger (11)', 'Plays inside to the 9 then attacks the box for the cut-back'),
    (4, 'Centre forward (9)', 'Shifts across to receive and set back')
) AS v(so, role, job);

-- 21. pp.54-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Positional Patterns of Play (4-3-3)', 'Timed runs: overlap or switch, then cross',
    'Rapid combination between 6, winger, 9 and 8: 6 plays wide and pushes on, winger checks back and plays diagonally to 9, 9 sets for 8, who either releases the winger''s overlapping run or switches diagonally to the far winger.',
    '8 receives the lay-off on the move',
    'Cross into the box with the 9 and 8 making curved runs to near and far posts and the far winger attacking the back post.',
    NULL, 54, 55, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (7)', 'Checks back to receive, then runs up the line / overlaps to cross'),
    (2, 'Centre forward (9)', 'Receives and sets back, then curves a run into the box'),
    (3, 'Attacking midfielder (8)', 'Plays wide to the overlap or diagonal aerial switch, then runs in'),
    (4, 'Far winger (11)', 'Attacks far post or receives the switch and crosses'),
    (5, 'Defensive midfielder (6)', 'Starts it with a pass wide and a forward run')
) AS v(so, role, job);

-- 22. pp.56-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Positional Patterns of Play (4-3-3)', 'Four-player flank combination, through ball, cross',
    'Full back in possession in the opposition half with winger, 8 and 9 on that side; winger and full back exchange (back-to-goal set or 1-2), full back finds the 9, who sets to the 8 and spins toward the box.',
    'Winger with back to goal near the full back',
    '8 plays a longer pass high up the flank for the winger to run onto and cross for the 9''s timed run.',
    NULL, 56, 57, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (2/3)', 'Combines with winger, plays diagonally into the 9'),
    (2, 'Winger (7/11)', 'Sets back to the full back, turns and runs high up the flank, crosses'),
    (3, 'Centre forward (9)', 'Lays off to the 8, then times a run into the box'),
    (4, 'Attacking midfielder (8/10)', 'Plays the through pass up the flank into the winger''s run')
) AS v(so, role, job);

-- 23. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Positioning and Receiving in the Half Spaces (3-5-2)', 'Wing backs wide, 8s receive in half spaces',
    'In the 3-5-2 the most creative players (attacking midfielders) aim to receive unmarked in the inside channels; the wing backs stay as wide as possible so those channels stay open.',
    'Attacking midfielder unmarked in the half space and able to turn',
    'Turn and play the final ball in behind, typically for the wing back''s run (De Bruyne to Walker). Pep''s principle: against a deep block be wide first, then run in behind.',
    NULL, 61, 61, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing backs (Sane 19, Walker 2)', 'Hold touchline width to stretch the line, run in behind when the 8 turns'),
    (2, 'Attacking midfielders (Silva 21, De Bruyne 17)', 'Find pockets in the half spaces, receive half-turned, play in behind'),
    (3, 'Second forward (Sterling 7)', 'Feeds the attacking midfielder in the half space')
) AS v(so, role, job);

-- 24. pp.64-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Defensive Midfielder''s Pass for Forward''s Lay-off with Third Man Runs Through the Centre', 'Striker-to-striker lay-off for third-man run',
    'Back three circulate, an attacking midfielder drops into the half space and sets to the 6 moving across; the 6 drives a pass into the advanced forward, who lays off to the deeper second forward.',
    'Advanced forward drops to receive with the second forward just behind him',
    'Opposite attacking midfielder makes a third-man run, receives in behind (or into the centre and dribbles), and squares for the forward''s curved run to score.',
    NULL, 64, 66, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (17/21)', 'Drops into half space to set, or makes the third-man run in behind'),
    (2, 'Defensive midfielder (25)', 'Moves across for the lay-off, plays forward into the striker'),
    (3, 'Advanced forward (10)', 'Drops to receive, sets to the other forward, then curves into the box'),
    (4, 'Second forward (7)', 'Sits deeper, plays the timed pass for the third-man runner'),
    (5, 'Back three (5, 4, 30)', 'Circulate to move the block before the first vertical pass')
) AS v(so, role, job);

-- 25. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Defensive Midfielder''s Pass for Forward''s Lay-off with Third Man Runs Through the Centre', 'Half-space 8 slots a run between lines',
    'Ball moves left to the wide wing back, inside to the attacking midfielder in the half space, to the 6, into the forward, who sets back to the same attacking midfielder; the other forward drops then spins.',
    'Attacking midfielder receives the lay-off facing goal in the half space',
    'Well-timed pass into the centre for the forward''s movement, who dribbles through the line and shoots.',
    NULL, 67, 67, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left attacking midfielder (21)', 'Receives twice in the half space, plays the pass into the centre'),
    (2, 'Defensive midfielder (25)', 'Moves across and forward for the lay-off, plays into the forward'),
    (3, 'Forward (10)', 'Sets back to the attacking midfielder'),
    (4, 'Forward (7)', 'Drops, then runs into the central space to finish'),
    (5, 'Left wing back (19)', 'Receives wide to open the half space')
) AS v(so, role, job);

-- 26. pp.68-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Defensive Midfielder''s Pass for Forward''s Lay-off with Third Man Runs Through the Centre', 'Centre back and 6 one-two to progress',
    'Middle centre back carries across and plays a 1-2 with the defensive midfielder, then the ball goes to the left centre back and up to the attacking midfielder in the half space.',
    'Middle centre back dribbling with the 6 close by',
    '6 curves forward for the lay-off and feeds the forward, who slips the second forward through to dribble and shoot.',
    NULL, 68, 68, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back (4)', 'Carries across, wall pass with the 6'),
    (2, 'Defensive midfielder (25)', 'Gives the return, then curved run to receive the next set and play into the forward'),
    (3, 'Left attacking midfielder (21)', 'Receives in the half space, sets back'),
    (4, 'Forwards (10, 7)', 'One receives and plays across for the other to run onto')
) AS v(so, role, job);

-- 27. pp.70-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Switching the Point of Attack and Passing in Behind to the Wing Back', 'Lay-off to weak-side 8, pass behind for wing back',
    'Ball circulated toward one flank (to the wing back and the near attacking midfielder in the half space), then via the 6 into the dropping forward, who lays off to the opposite attacking midfielder in his half space.',
    'Defence drawn to one side; far half-space midfielder free',
    'Far attacking midfielder plays in behind for the weak-side wing back''s overlapping or diagonal run, who crosses low for runners.',
    NULL, 70, 75, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near wing back and attacking midfielder', 'Draw the block to the first side with wide and half-space receptions'),
    (2, 'Defensive midfielder (25)', 'Moves across for the lay-off, plays into the dropping forward'),
    (3, 'Forward (7/10)', 'Drops and sets or plays across to the far attacking midfielder'),
    (4, 'Weak-side attacking midfielder', 'Receives in his half space or dribbling forward, plays in behind'),
    (5, 'Weak-side wing back', 'Overlapping or diagonal run in behind, low cross')
) AS v(so, role, job);

-- 28. pp.71-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Switching the Point of Attack and Passing in Behind to the Wing Back', '6''s aerial switch plus 8''s third-man run',
    'Ball goes left: wing back wide, back to the attacking midfielder moving across, into the forward, who lays off to the 6 arriving on a curved run.',
    '6 receives facing play with the far wing back high and unmarked',
    '6 hits an aerial switch to the far wing back''s forward run; the wing back finds the near attacking midfielder''s third-man run between the mannequins, who squares for the forward.',
    NULL, 71, 71, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (25)', 'Curved run for the lay-off, aerial diagonal switch'),
    (2, 'Right wing back (2)', 'Forward run to take the switch, passes inside'),
    (3, 'Right attacking midfielder (17)', 'Third-man run between defenders'),
    (4, 'Forward (7)', 'Moves across to receive and set to the 6'),
    (5, 'Forward (10)', 'Finishes the square pass')
) AS v(so, role, job);

-- 29. pp.72-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Switching the Point of Attack and Passing in Behind to the Wing Back', 'Short combinations then 6 plays wing back in',
    'Centre backs carry forward; ball goes to a wing back who checks back, inside to the 6 in the half space, into the dropping forward, back to the attacking midfielder (1-2), and across to the other attacking midfielder pushed high.',
    'Opponent block pulled in by short passing in the centre',
    '6 receives the lay-off and plays the ball in behind for the far wing back to run onto and cross low.',
    NULL, 72, 72, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (4, 5)', 'Carry forward to commit opponents'),
    (2, 'Left wing back (19)', 'Drops back to receive'),
    (3, 'Attacking midfielders (21, 17)', '1-2 with the forward, then one high to set back to the 6'),
    (4, 'Defensive midfielder (25)', 'Moves to the half space, then into the lay-off and plays in behind'),
    (5, 'Right wing back (2)', 'Runs in behind, low cross')
) AS v(so, role, job);

-- 30. pp.73-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Switching the Point of Attack and Passing in Behind to the Wing Back', 'Centre back bypasses press, second forward finds wing back',
    'An opponent pushes up to block the pass to the middle centre back, so the right centre back passes straight across to the left one, who carries forward into midfield.',
    'Pass to the middle centre back blocked by an advanced opponent',
    'Via the half-space 8, the 6''s curved run and the forward, the second forward plays in behind for the far wing back, who crosses low.',
    NULL, 73, 73, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (5)', 'Receives across, dribbles forward to step into midfield'),
    (2, 'Left attacking midfielder (21)', 'Receives in the half space, sets to the 6'),
    (3, 'Defensive midfielder (25)', 'Drops then curves forward for the lay-off, plays into the forward'),
    (4, 'Forwards (10, 7)', '10 passes across to 7, who plays in behind'),
    (5, 'Right wing back (2)', 'Forward run in behind, low cross')
) AS v(so, role, job);

-- 31. pp.78-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Forward''s Lay-off for Attacking Midfielder to Pass in Behind', '8 on the run feeds wing back in behind',
    'Right attacking midfielder drops into the half space to receive from the back, sets to the 6 moving across, the 6 plays into a forward who lays off across for the far attacking midfielder running onto it.',
    'Attacking midfielder arriving at speed onto the forward''s lay-off',
    'Pass (ground or aerial) in behind for the wing back, who cuts back, crosses low or cuts inside and shoots.',
    NULL, 78, 81, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right attacking midfielder (17)', 'Drops into the half space to start it'),
    (2, 'Defensive midfielder (25)', 'Moves across or curves forward for the lay-off, plays into the forward'),
    (3, 'Forward (7/10)', 'Moves to receive and plays across for the runner'),
    (4, 'Running attacking midfielder (21)', 'Takes it on the run, plays in behind'),
    (5, 'Wing back (2/19)', 'Diagonal or forward run in behind, cut-back, low cross or shot')
) AS v(so, role, job);

-- 32. pp.82-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Forward''s Lay-off for Attacking Midfielder to Pass in Behind', 'Closed-down centre back passes through the lines',
    'Middle centre back dribbles across and gets closed down, so he plays to the right centre back moving forward, who passes through the lines to the forward dropping and shifting toward that side.',
    'Middle centre back pressed while carrying',
    'Forward sets to the attacking midfielder in the half space, who plays in behind for the wing back''s diagonal third-man run and low cross.',
    NULL, 82, 82, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back (4)', 'Carries until pressed, then releases'),
    (2, 'Right centre back (30)', 'Steps forward, line-breaking pass to the forward'),
    (3, 'Forward (10)', 'Drops and shifts across, lays off'),
    (4, 'Right attacking midfielder (17)', 'Receives in the half space, plays in behind'),
    (5, 'Right wing back (2)', 'Diagonal third-man run, low cross')
) AS v(so, role, job);

-- 33. pp.83-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Forward''s Lay-off for Attacking Midfielder to Pass in Behind', '8 slips the second forward through',
    'Middle centre back carries under pressure, plays to the advancing left centre back, who finds the attacking midfielder in the half space; via the 6''s curved run, the forward moves left and lays off for the attacking midfielder running on.',
    'Attacking midfielder receives the lay-off in the half space',
    'Through ball between the defenders for the second forward to receive in behind and score.',
    NULL, 83, 83, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back (4)', 'Carries under pressure, plays to the advancing centre back'),
    (2, 'Left attacking midfielder (21)', 'Receives in the half space twice, plays the through ball'),
    (3, 'Defensive midfielder (25)', 'Curved run for the lay-off, passes into the forward'),
    (4, 'Forward (10)', 'Shifts left, lays off'),
    (5, 'Second forward (7)', 'Runs between the centre backs to finish')
) AS v(so, role, job);

-- 34. pp.84-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Pep Guardiola Stops the Training Session at this Point and Makes Changes', '8 drops beside 6, striker fills half space',
    'Positional change in the 3-5-2: the left attacking midfielder drops next to the defensive midfielder to form a double pivot, the 6 shifts slightly right, and the second forward drops into the vacated half space to receive.',
    'Coach rearranges shape for the next set of patterns (one fewer opponent)',
    'Build with two holding midfielders and use the dropping forward as the half-space receiver.',
    NULL, 84, 84, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left attacking midfielder (21)', 'Drops beside the 6 as a second pivot'),
    (2, 'Defensive midfielder (25)', 'Shifts slightly to the right'),
    (3, 'Second forward (7)', 'Drops and moves into the half space to receive')
) AS v(so, role, job);

-- 35. pp.86-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Midfielder Drops Back and the Forward Moves into Half Space to Link Play', 'Forward in half space, 8 dribbles in behind',
    'The attacking midfielder drops, the second forward shifts into the half space and receives from the centre back, then lays off to the attacking midfielder, who finds the advanced forward dropping.',
    'Attacking midfielder drops, leaving the half space for the forward',
    'Forward plays across for the opposite attacking midfielder to run onto and dribble through the line into the box.',
    NULL, 86, 86, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left attacking midfielder (21)', 'Drops back, then steps up for the lay-off'),
    (2, 'Second forward (7)', 'Shifts into the half space to link play'),
    (3, 'Advanced forward (10)', 'Drops to receive, slides the far runner in'),
    (4, 'Right attacking midfielder (17)', 'Runs onto the ball and dribbles in behind to shoot')
) AS v(so, role, job);

-- 36. pp.87-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Midfielder Drops Back and the Forward Moves into Half Space to Link Play', 'Double lay-off, 6 finds far wing back',
    'Middle centre back carries under pressure and plays to the left centre back; the ball goes into the forward who shifted across, he sets to the second forward stepping forward, who sets again to the attacking midfielder moving into the centre.',
    'Two quick lay-offs pull the defence toward the ball',
    '6 receives the final lay-off and plays in behind for the far wing back; both forwards and the near wing back fill the box for a low cross.',
    NULL, 87, 87, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (10)', 'Shifts across to receive, first lay-off, then attacks the box'),
    (2, 'Second forward (7)', 'Steps forward for the second lay-off, then attacks the box'),
    (3, 'Right attacking midfielder (17)', 'Moves into the centre, sets for the 6'),
    (4, 'Defensive midfielder (25)', 'Plays the ball in behind'),
    (5, 'Right wing back (2)', 'Run in behind, low cross'),
    (6, 'Left wing back (19)', 'Runs into the box')
) AS v(so, role, job);

-- 37. pp.88-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Midfielder Drops Back and the Forward Moves into Half Space to Link Play', 'Wing back combines with half-space forward',
    'With the attacking midfielder central and the second forward in the half space, the centre back plays into the forward, who sets for the midfielder; the ball goes to the wing back.',
    'Wing back receives with the forward in the half space beside him',
    'Wing back gets in behind either by a 1-2 with the forward or by checking back then running forward for the forward''s turn-and-pass out wide, then crosses or cuts back.',
    NULL, 88, 89, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (19)', 'Passes inside and spins, or checks back then sprints in behind'),
    (2, 'Second forward (7)', 'In the half space, returns the 1-2 or turns and plays wide in behind'),
    (3, 'Attacking midfielder (21/17)', 'Moves across for the lay-off or drops and feeds the forward'),
    (4, 'Middle centre back (4)', 'Carries forward to start, under pressure')
) AS v(so, role, job);

-- 38. pp.90-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Midfielder Drops Back and the Forward Moves into Half Space to Link Play', 'Combine on one side, aerial switch to far wing back',
    'Play is built down one side: the attacking midfielder drops or starts deep, the forward shifts into the half space, the wing back receives wide and plays inside to the attacking midfielder (or forward) stepping into the half space.',
    'Ball-side half space reached with the far wing back high',
    'Long diagonal aerial pass in behind the line to the far wing back, who dribbles on and crosses or cuts back for the forward.',
    NULL, 90, 93, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left attacking midfielder (21)', 'Drops, then moves forward to receive inside and hit the long aerial switch'),
    (2, 'Second forward (7)', 'Shifts into the half space, links or plays the diagonal himself'),
    (3, 'Near wing back', 'Receives wide to pull the defence across'),
    (4, 'Far wing back', 'Runs in behind on the weak side, crosses or cuts back'),
    (5, 'Advanced forward (10)', 'Sets back to the second forward, finishes')
) AS v(so, role, job);

-- 39. pp.92-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Midfielder Drops Back and the Forward Moves into Half Space to Link Play', 'Half-space lay-off, ball-side wing back in, box filled',
    'Attacking midfielder in the half space sets to the advancing centre back, who finds the second forward shifted into the half space; he lays off for the attacking midfielder moving forward.',
    'Attacking midfielder gets the lay-off facing forward',
    'Pass in behind for the ball-side wing back''s forward run; both forwards, the other attacking midfielder and the far wing back all run into the box for the cross.',
    NULL, 92, 92, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right attacking midfielder (17)', 'Receives in the half space, sets, then plays in behind'),
    (2, 'Right centre back', 'Steps forward to receive and pass into the half space'),
    (3, 'Second forward (7)', 'Shifts into the half space, lays off'),
    (4, 'Right wing back (2)', 'Forward run in behind, crosses'),
    (5, 'Box runners (7, 10, 21, 19)', 'Fill the penalty area for the cross')
) AS v(so, role, job);

-- 40. pp.95-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Consolidating Possession Before Playing a Decisive Diagonal Aerial Pass in Behind', 'Patient combinations, chip in behind for forward',
    'Team consolidates possession with fast short combinations in the centre (lay-offs, 1-2s between the 6, attacking midfielders and the forward in the half space) and uses the wing back wide to move the block.',
    'Attacking midfielder free facing forward after the build-up',
    'Short diagonal aerial pass in behind the defensive line to a forward, who cuts back or lays across for the other forward to score.',
    NULL, 95, 96, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Second forward (7)', 'Shifts into the half space to receive, then runs in behind'),
    (2, 'Attacking midfielders (17, 21)', 'Lay-offs and 1-2s, one plays the aerial ball'),
    (3, 'Defensive midfielder (25)', 'Receives lay-offs, recycles to the wing back'),
    (4, 'Left wing back (19)', 'Width to stretch, passes back inside'),
    (5, 'Forward (10)', 'Finishes the cut-back')
) AS v(so, role, job);

-- 41. pp.97-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Consolidating Possession Before Playing a Decisive Diagonal Aerial Pass in Behind', 'Central combinations, diagonal chip to weak-side wing back',
    'Ball is circulated through quick central combinations (centre back carries, forward in the half space sets, attacking midfielders 1-2 with the 6, ball moved to one flank) while the opposite wing back stays high.',
    'Defence compressed toward the ball with the far wing back unmarked',
    'Decisive diagonal aerial pass in behind to the opposite wing back, who cuts back for the forward.',
    NULL, 97, 100, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back (4)', 'Dribbles forward to engage'),
    (2, 'Forward (7/10)', 'Shifts into the half space, lay-offs, may play the aerial ball himself'),
    (3, 'Attacking midfielders (21, 17)', 'Curved runs for lay-offs, 1-2s with the 6, play the diagonal'),
    (4, 'Defensive midfielder (25)', 'Receives sets, links and can play the final aerial pass'),
    (5, 'Weak-side wing back', 'Holds height and width, receives in behind, cuts back')
) AS v(so, role, job);

-- 42. pp.98-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Consolidating Possession Before Playing a Decisive Diagonal Aerial Pass in Behind', 'Switch there and back, then aerial in behind',
    'Ball goes out to the left wing back, inside to the half-space midfielder and the forward, then through the 6 and right centre back to the right wing back, who passes back inside to the attacking midfielder shifting across.',
    'Opponent has shifted twice and the original wing back is free on the far side',
    'Aerial pass in behind back to the first-side wing back, who has moved forward.',
    NULL, 98, 98, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back (19)', 'Starts wide, then moves forward to receive the final aerial ball'),
    (2, 'Left attacking midfielder (21)', 'Receives in the half space, plays to the forward'),
    (3, 'Forward (7)', 'Moves into the half space, sets to the 6'),
    (4, 'Defensive midfielder (25) and right centre back (30)', 'Carry the switch to the right'),
    (5, 'Right wing back (2)', 'Receives, passes back inside'),
    (6, 'Right attacking midfielder (17)', 'Shifts across, plays the aerial ball in behind')
) AS v(so, role, job);

-- 43. pp.102-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '3-5-2: Combination Play with the Wing Back Using Give-and-Go and Underlap Runs', 'Double one-two to free the wing back',
    'In a 3-5-2 the ball goes back to the middle centre back, then into the holding midfielder and on to the attacking midfielder in the half space. Two one-twos follow: first the attacking midfielder with the holding midfielder, then the wing back with the attacking midfielder.',
    'Attacking midfielder gets the ball in the half space with the wing back wide of him',
    'The wing back runs onto a ball in behind the full back and cuts a low cross across the box.',
    NULL, 102, 103, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back', 'takes the ball from a wide centre back, steps or dribbles forward and feeds the holding midfielder'),
    (2, 'Holding midfielder (25)', 'plays into the half space, takes the lay-off back and passes wide to the wing back'),
    (3, 'Attacking midfielder in the half space (21/17)', 'lays off first time, then slips the wing back in behind with the return pass'),
    (4, 'Wing back (19/2)', 'checks back to receive high up, plays inside, sprints in behind for the return and crosses low'),
    (5, 'Front two and far-side attacking midfielder', 'attack the box for the cross')
) AS v(so, role, job);

-- 44. pp.104-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '3-5-2: Combination Play with the Wing Back Using Give-and-Go and Underlap Runs', 'Wing back slips the underlapping attacking midfielder',
    'The ball reaches the advanced wing back, either down the same side through the wide centre back, or after a switch where a forward drifts into the half space and lays off. The attacking midfielder then runs inside the wing back, between the full back and the centre back.',
    'Advanced wing back receives facing forward and the full back goes to him',
    'The attacking midfielder gets in behind on the inside channel and squares the ball for runners to score.',
    NULL, 104, 105, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back (30/5)', 'carries forward and plays into the attacking midfielder or a forward who has shifted into the half space'),
    (2, 'Forward (7/10)', 'drifts across into the half space to receive and lays off'),
    (3, 'Holding midfielder (25)', 'moves to collect the lay-off and plays out to the advanced wing back'),
    (4, 'Wing back (2)', 'checks back, then moves forward to receive and passes in behind on the inside'),
    (5, 'Attacking midfielder (17)', 'underlaps inside the wing back, receives in behind and squares it across goal')
) AS v(so, role, job);

-- 45. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '3-5-2: Combination Play with the Wing Back Using Give-and-Go and Underlap Runs', 'Half-space give-and-go with the wing back, underlap',
    'A pass from the holding midfielder breaks a line to find the attacking midfielder in the half space. He releases the wing back down the line, then keeps running inside to take a one-two back from him.',
    'Half-space midfielder receives between the lines with the wing back free outside',
    'The midfielder arrives in behind on the underlap and cuts the ball back for the striker.',
    NULL, 106, 106, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (25)', 'checks away to lose his marker, receives from the middle centre back and breaks the line into the half space'),
    (2, 'Attacking midfielder (21)', 'plays the wing back down the line and makes an underlapping run in behind'),
    (3, 'Wing back (19)', 'runs onto the pass and returns it first time in behind the full back'),
    (4, 'Forward (10)', 'attacks the cut-back')
) AS v(so, role, job);

-- 46. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '3-5-2: Attacking Midfielder''s Penetrating Run to Receive and Dribble Through Centre', 'Half-space combination, far attacking midfielder dribbles centre',
    'The ball goes through the right-sided centre back to a forward, who lays off to the near attacking midfielder in the half space. He passes inside to the far-side attacking midfielder, who has run forward into the middle.',
    'Near-side combination pulls the defence towards the ball side',
    'The arriving midfielder dribbles through the gap between the centre backs and shoots from outside the box.',
    NULL, 108, 108, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back (30)', 'takes the ball from the holding midfielder and plays straight into the forward'),
    (2, 'Forward (10)', 'lays off to the attacking midfielder in the half space'),
    (3, 'Near attacking midfielder (17)', 'moves into the half space for the lay-off and passes into the centre'),
    (4, 'Far attacking midfielder (21)', 'makes a forward run into the middle, dribbles between the defenders and shoots')
) AS v(so, role, job);

-- 47. pp.109-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', '3-5-2: Attacking Midfielder''s Penetrating Run to Receive and Dribble Through Centre', 'Forwards shift across to empty the centre',
    'Both forwards drift towards the ball side, one of them into the left half space. That leaves the middle empty for the far-side attacking midfielder to run into.',
    'Left centre back steps forward with the ball after a switch from right to left',
    'The far attacking midfielder takes a pass into the vacated centre, dribbles between the centre backs and finishes from inside the box.',
    NULL, 109, 109, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle and left centre backs (4, 5)', 'move the ball across and step in to play forward'),
    (2, 'Forward (10)', 'shifts slightly across, receives and lays off'),
    (3, 'Second forward (7)', 'moves into the left half space, then steps forward for the lay-off and passes towards the centre'),
    (4, 'Far attacking midfielder (17)', 'runs forward into the central gap, dribbles through and shoots')
) AS v(so, role, job);

-- 48. pp.113-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Combination Play to Create Chances and Finish', 'Show, lay-off, third man finishes',
    'Attackers check back off their marker to receive and lay off first time for a team-mate moving forward. Third-man passes take the ball through the lines up to a forward who drops in at the top of the box.',
    'Attacker receives with his back to goal while a team-mate faces forward',
    'The last receiver either dribbles past the defender and shoots, or plays a one-two with the dropping forward and finishes in behind.',
    NULL, 113, 114, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep passer (A)', 'plays in and moves forward to take the return'),
    (2, 'Link player (B)', 'drops behind the pole to receive, lays off, then pushes forward to get the ball again'),
    (3, 'Dropping forward (D)', 'comes short at the edge of the box and lays off, or gives the return pass of a one-two'),
    (4, 'Arriving attacker (E)', 'sprints into position, receives facing goal, then dribbles or plays a one-two and shoots')
) AS v(so, role, job);

-- 49. pp.115-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Combination Play to Create Chances and Finish', 'Long switch to a curved runner, edge one-two',
    'A short one-two and wall passes draw defenders to one side. The longest pass of the move, on the ground or in the air, then goes to a player who has curved his run into open space.',
    'Defenders have moved towards the short combination',
    'The runner carries forward under pressure, then plays a one-two with a forward at the edge of the box and shoots.',
    NULL, 115, 116, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Combination players (A, B)', 'play the short one-two and set up the next pass'),
    (2, 'Switching passer (C)', 'plays the long ball, either along the ground or in the air'),
    (3, 'Curved runner (D)', 'bends his run into the space, carries the ball under pressure'),
    (4, 'Forward at the edge of the box (E)', 'gives the return pass in behind for the shot')
) AS v(so, role, job);

-- 50. pp.117-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Combination Play to Create Chances and Finish / Circuits', 'Diagonal chip over the line for third-man run',
    'A lay-off or one-two lets a player open his body. He then lifts a diagonal ball over the defensive line for a team-mate who has timed a forward run from outside.',
    'Team-mate opens up after a lay-off while a third player starts his run',
    'The runner controls the ball in behind and finishes in two touches.',
    NULL, 117, 121, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping player (D/C)', 'comes short and lays off'),
    (2, 'Passer (B/A)', 'opens up with two touches and chips a diagonal ball over the line'),
    (3, 'Third-man runner (C/B)', 'times a forward run from wide, controls and shoots')
) AS v(so, role, job);

-- 51. pp.118-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Combination Play to Create Chances and Finish', 'One-two then ball in behind the full back',
    'A central one-two moves the ball across. The wide player has moved away from his marker and then gets in behind the full back, and the ball goes into that space on the ground or in the air.',
    'Central player receives the return pass with an open body',
    'The wide runner delivers a low cross or cut-back to three runners who split into near post, centre and far post.',
    NULL, 118, 119, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central passer (A)', 'plays the one-two, opens up and passes in behind, then runs into the box himself'),
    (2, 'Wall player (B/B1)', 'checks away, gives the return pass and runs into the box'),
    (3, 'Wide runner (C/B2)', 'times his run in behind the full back, takes a touch forward and crosses low'),
    (4, 'Box runners', 'fill the near post, centre and far post')
) AS v(so, role, job);

-- 52. pp.120-143
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Combination Play to Create Chances and Finish / Conditioning and Speed', 'Wide pass, overlap, cross',
    'After a combination, the ball goes out to the wide player while he is still moving. A team-mate then overlaps around him, or makes a long curved run around the outside, to take the ball in behind.',
    'Wide player receives and holds the defender''s attention',
    'The overlapping player crosses into the box for runners arriving at both posts.',
    NULL, 120, 143, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central players (A, B)', 'play a one-two or lay-off, then pass out wide'),
    (2, 'Wide receiver (C1/C)', 'receives on the move and plays into the path of the overlap'),
    (3, 'Overlapping player (D/A)', 'makes a curved run around the outside and crosses'),
    (4, 'Central runners', 'attack the box, one near post and one far post')
) AS v(so, role, job);

-- 53. pp.122-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Combination Play to Create Chances and Finish / Conditioning and Speed', 'Lay-off then early ball high up the flank',
    'A player dribbles through, or plays a short one-two or double one-two with a dropping team-mate in front of the defenders. The next pass goes early, wide and high up the flank, for a winger making a curved run around his marker.',
    'Central lay-off gets the ball to a player facing forward',
    'The winger receives high up and crosses before the defence can reset.',
    NULL, 122, 142, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central passer (A/10)', 'combines short, then plays the ball out wide and high up the flank'),
    (2, 'Dropping link player (B/C/9)', 'drops in front of the defender and lays off'),
    (3, 'Winger (11/B)', 'makes a curved run around his marker into the space and crosses')
) AS v(so, role, job);

-- 54. pp.122-143
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Combination Play to Create Chances and Finish / Conditioning and Speed', 'Timed runs into the box for crosses',
    'When the ball goes wide for a cross, the attackers waiting outside the box hold their runs, then make curved or crossing runs around the defenders. One attacks the near post and one the far post, with the far winger joining in.',
    'Winger takes his touch to cross',
    'The box is filled at both posts as the ball arrives, and players follow up any rebound from the goalkeeper.',
    NULL, 122, 143, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Crosser (winger)', 'chooses a high cross or a low cut-back depending on the runs'),
    (2, 'Forward (9)', 'curves around the defender to the near post'),
    (3, 'Attacking midfielder (10)', 'makes a crossing run to the far post'),
    (4, 'Far-side winger', 'arrives at the back post'),
    (5, 'All runners', 'time the run to arrive with the ball and stay alert for rebounds')
) AS v(so, role, job);

-- 55. pp.125-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Combination Play to Create Chances and Finish', 'Flank one-two, overlap cross or cut-back',
    'On the flank, two players play a quick one-two. The second wide player runs onto the pass beyond them and crosses past the defenders, either high or as a low cut-back.',
    'Return pass of the wide one-two',
    'Two central players time their runs to meet the cross and stay alert for a rebound.',
    NULL, 125, 125, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside wide player (A)', 'plays the one-two, moves across and passes forward'),
    (2, 'Wall player (B)', 'returns the ball first time'),
    (3, 'Crosser (C)', 'runs onto the pass and chooses a high cross or a cut-back'),
    (4, 'Central runners (D1, D2)', 'attack the box and follow up any save')
) AS v(so, role, job);

-- 56. pp.126-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Combination Play to Create Chances and Finish', 'Circulate centrally, then wide one-two and cut-back',
    'Three players keep the ball outside the box and wait for the right moment to go wide. When it goes wide, one supports the wide player and the other two run into the box, as does the far-side wide player.',
    'A clear chance to play the ball wide comes up during central circulation',
    'The wide player, under pressure, plays a one-two with his support, gets back inside the box and finds a team-mate with a cross or cut-back past the two defenders.',
    NULL, 126, 126, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central trio', 'keep the ball and pick the moment to play it wide'),
    (2, 'Supporting central player', 'goes to the wide player for the one-two'),
    (3, 'Wide player', 'plays the one-two under pressure and delivers into the box'),
    (4, 'Other central players and far wide player', 'run into the box away from the defenders')
) AS v(so, role, job);

-- 57. pp.128-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'to_attack', 'Attacking Combination Play in 3v2 Duels', 'Fast 3v2: carrier fixes, others offer wide',
    'Three attackers against two defenders and a keeper, starting from a ball played in. The player who receives dribbles into the middle to occupy both defenders while the other two offer on each side. If a wide player gets the ball, the central player overlaps him.',
    'Attacker receives with the 3v2 overload',
    'The attack scores quickly, either through a well-timed pass to the free man or a low cut-back. If one defender starts from the side, they attack the space on the opposite side to him.',
    NULL, 128, 129, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'dribbles centrally at speed to draw both defenders'),
    (2, 'Wide attackers', 'split to either side to offer'),
    (3, 'Central player after a wide pass', 'overlaps the receiver'),
    (4, 'All attackers', 'go to the side away from the recovering defender')
) AS v(so, role, job);

-- 58. pp.131-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'pep-guardiola-88-attacking-combinations-and-positional-patterns-of-play-direct-f'), 'in_possession', 'Attacking Combination Play Circuits', 'Through ball between defenders after a wall pass',
    'After a combination in front of the back line, the ball is split between two defenders for a diagonal run in behind. In the variants it is chipped over them, or the receiver takes on the last defender 1v1.',
    'Passer gets a set-back pass facing forward',
    'The runner controls the ball in behind and shoots in two touches.',
    NULL, 131, 134, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer (A/B)', 'takes the set-back with an open body and splits the defenders, or chips them'),
    (2, 'Wall player (D)', 'gives the set-back pass'),
    (3, 'Runner (C)', 'moves off his starting point, times a diagonal run in behind or beats the defender 1v1, then shoots')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1970-coaching-book-pep-guardiola-88-combinations-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
