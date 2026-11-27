-- 2103 📚 Coaching book patterns: "Luis Enrique: PSG Tactical Analysis and Training Sessions" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Luis Enrique: PSG Tactical Analysis and Training Sessions',
    subtitle    = '107 Tactics & Practices',
    author      = 'Vaios Stergiopoulos',
    team        = 'Paris Saint-Germain',
    season      = '2023-2026',
    method_note = 'Analysis of Luis Enrique''s PSG 4-3-3 of 2023-26 (Donnarumma, Mendes, Pacho, Marquinhos, Hakimi, Vitinha, Neves / Fabián / Zaïre-Emery, Doué, Kvaratskhelia, Dembélé) in 10 tactical situations, each a set of recurring match patterns on diagrams with every player''s job, then a session of practices: rotations that keep the 4-3-3 shape, the full back pushing up for a 3v2, the false 9 and the holding midfielder''s run beyond, width and blind-side runs, third-man runs, weak-side switches, 5-second counter-pressing, rest defence, high pressing (including kicking off long to press the throw-in) and compact blocks. Patterns are the match behaviours, in our words.'
WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices');

-- 1. pp.15-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 1: Asymmetric Build-Up Play with Fluid Structures - A. Centre Back and Attacking Full Back Role', 'Asymmetric back three into 3-3-4',
    'In build-up the left back stays deep as a third centre back with wide spacing, while the right back goes to full height and width and the right winger tucks in towards the forward, turning the 4-3-3 into a 3-3-4.',
    'Own build-up from the back',
    'Safe circulation even against two pressing forwards while keeping four attackers pinning the back line.',
    NULL, 15, 15, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Mendes)', 'Stay deep and wide as third centre back'),
    (2, 'Right back (Hakimi)', 'Push to max height and width as a winger'),
    (3, 'Right winger (Doue)', 'Move inside near the forward'),
    (4, 'Centre backs', 'Wide spacing across the back three')
) AS v(so, role, job);

-- 2. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 1 - B. Inverted Left Back and Underlap Run of Right Back', 'Inverted full back and underlap',
    'Either full back can step inside as a second defensive midfielder, freeing the central midfielders to advance; on the other side the full back gives the ball to the winger, who goes wide, and underlaps inside him.',
    'Winger receives wide from the full back',
    'Central numerical edge over the opposing midfield and confusion in the defenders on the underlap.',
    NULL, 16, 16, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted full back (Mendes or Hakimi)', 'Move inside into a DM slot'),
    (2, 'Central midfielders', 'Advance higher thanks to the extra holder'),
    (3, 'Right back (Hakimi)', 'Pass to winger then underlap inside'),
    (4, 'Right winger', 'Drift wide to receive and free the inside lane')
) AS v(so, role, job);

-- 3. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 1: Defensive Midfielder Drops into Back 3 to Create a 3v2 Overload', 'DM drops left into back three',
    'Vitinha drops to the left side of the two centre backs to make a back three, beating a two-man first press 3v2 or 3v1; the left back steps up into midfield and a central midfielder covers the vacated DM spot.',
    'Opponent presses build-up with one or two forwards',
    'Beat the first press with a composed, technical passer at the base.',
    NULL, 17, 17, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Vitinha)', 'Drop beside left CB as build-up passer'),
    (2, 'Left back (Mendes)', 'Push up into central midfield'),
    (3, 'LCM or RCM', 'Fill the space the DM left'),
    (4, 'Centre backs', 'Form 3v2 with the DM')
) AS v(so, role, job);

-- 4. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 1: Centre Backs Spread Wide to Stretch the Opposition''s Defensive Block', 'Split centre backs, touchline full backs',
    'Early in build-up both centre backs split very wide and both full backs hug the touchlines; the right back does not hurry forward so full width is held first, and the goalkeeper is a spare outlet against a two-forward press.',
    'Initial build-up phase',
    'Stretch the block: if the opposing winger stays wide the channel into a central midfielder opens; if they narrow, go wide to the full back.',
    NULL, 18, 18, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Pacho, Marquinhos)', 'Split wide apart'),
    (2, 'Full backs', 'Stay on the touchline, hold width'),
    (3, 'LCM', 'Show in the channel inside the winger'),
    (4, 'Goalkeeper (Donnarumma)', 'Safe spare outlet vs 2 forwards')
) AS v(so, role, job);

-- 5. pp.19-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 1: "Sweeper-Keeper" at Base of Diamond Shape (4v2) to Play Out', 'Sweeper-keeper diamond 4v2',
    'Goalkeeper, two centre backs and DM form a diamond to beat two forwards 4v2; the keeper''s first choice is the free DM, otherwise a centre back, or a lofted pass to the full back when the opposing winger pushes up.',
    'Two-man press on goal kick / back pass',
    'Play out without risk, with the keeper as the link who switches sides.',
    NULL, 19, 19, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Donnarumma)', 'Base of diamond; DM first, else CB or chip to FB'),
    (2, 'Defensive midfielder (Vitinha)', 'Tip of diamond, unmarked option'),
    (3, 'Centre backs', 'Wide sides of diamond'),
    (4, 'Receiver', 'Quick directional first touch to next option')
) AS v(so, role, job);

-- 6. pp.20-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 1: Defensive Midfielder Drifts Wide to Create Space for Central Midfielders', 'DM drifts wide, CM drops in',
    'When Vitinha is closely marked he drifts wide, dragging his marker and opening central space for a central midfielder (Neves) to drop in and receive from the centre back; called a key PSG midfield rotation.',
    'DM tightly man-marked in build-up',
    'Build vertically through the first line; if the CM is still pressed, go long to the forward dropping between the lines.',
    NULL, 20, 20, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Vitinha)', 'Drift wide taking marker away'),
    (2, 'RCM (Neves)', 'Drop into vacated central space to receive'),
    (3, 'Centre back (Pacho)', 'Pass into the freed CM'),
    (4, 'Forward (Dembele)', 'Drop between lines for long pass if CM pressed')
) AS v(so, role, job);

-- 7. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 1: Keeping 3 at Back to Provoke Pressing and Exploit Space on Weak Side', 'Bait the press, diagonal to weak side',
    'Holding three at the back forces the opponent to commit a third presser from midfield, leaving a 5v3 behind; under pressure a weak-side midfielder or winger drops for a long diagonal from the CB or keeper, and a teammate immediately supports the receiver. Trained in Session 1 practice 4 (p29, 8v6 with three halfway goals).',
    'Opponent commits a third player to press the back three',
    'Release pressure by switching into the unguarded weak side and attack the midfield overload.',
    NULL, 21, 21, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three + GK', 'Draw the press, then play long diagonal'),
    (2, 'Weak-side winger (Kvaratskhelia)', 'Drop to receive the diagonal'),
    (3, 'LCM (Fabian)', 'Stay inside occupying a defender'),
    (4, 'Nearest teammate', 'Support the new ball carrier at once')
) AS v(so, role, job);

-- 8. pp.22-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 1: U-Shaped Build-Up Play to Secure Possession for Forward Passing Options', 'U-shaped circulation until vertical lane',
    'Ball moves full back - CB - CB - full back in a U until a forward lane opens; the right back drops, RCM takes the inside channel with the CB, and if RCM''s marker follows him deep the forward drops into the space or the right winger moves inside. Trained in Session 1 practice 3 (p28, 4-3 vs mannequins).',
    'No forward pass available yet',
    'Keep possession safely and switch until a vertical pass can be played.',
    NULL, 22, 22, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Circulate and read best forward pass under pressure'),
    (2, 'RCM (Neves)', 'Share inside channel with CB, drag marker deep'),
    (3, 'Forward (Dembele)', 'Drop deeper into space RCM created'),
    (4, 'Right winger (Doue)', 'Come inside if forward stays high'),
    (5, 'Right back (Hakimi)', 'Drop to give the U its width')
) AS v(so, role, job);

-- 9. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 1: Shifting from 3 at the Back to 2 at the Back in Seconds (Dynamic Transition)', 'Dynamic transition three to two',
    'Once the ball passes the first pressing line, the deep left back (or DM) surges into midfield, forming a diamond with the left winger, LCM and forward and a 4v2 on that side.',
    'Ball beats the opponent''s first pressing line',
    'Midfield superiority; if the winger is drawn, the lane to the winger opens, if he stays, the left back uses the space and draws a midfielder.',
    NULL, 23, 23, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Mendes) or DM', 'Push forward aggressively into midfield'),
    (2, 'Left winger (Kvaratskhelia)', 'Wide corner of the diamond; space behind if FB follows'),
    (3, 'LCM (Fabian)', 'Inside corner of the diamond'),
    (4, 'Forward (Dembele)', 'Top of diamond, run in behind')
) AS v(so, role, job);

-- 10. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 1: Midfielders Drop to Create Space Between the Lines for a Long Pass', 'Midfield drops, long pass between lines',
    'Against a high press all three midfielders drop towards the defence, pulling their markers and emptying the zone between the lines; keeper to right CB, who plays forward to the right winger or the forward moving into that space, with the right back high and wide as an extra outlet.',
    'Opponent applies high pressure',
    'Bypass the midfield press entirely with a direct route.',
    NULL, 24, 24, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'DM, LCM, RCM', 'Drop towards defensive line, take markers along'),
    (2, 'Goalkeeper (Donnarumma)', 'Pass to right CB'),
    (3, 'Right CB (Marquinhos)', 'Play forward into the emptied space'),
    (4, 'Right winger / Forward', 'Move into the space between the lines'),
    (5, 'Right back (Hakimi)', 'Push high and wide as extra outlet')
) AS v(so, role, job);

-- 11. pp.26-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Session 1: 10v3 Positional Rondo / 3-3-3 Team Combination Passing Pattern with Player Rotation', 'Keep 4-3-3 shape while rotating positions',
    'Practices where the team keeps its 4-3-3 shape under pressure, the three central midfielders shifting the ball away from the pressure zone, and players rotate into the next position along a chain after passing.',
    'Pressure zone forms around the ball',
    'Move the ball away from pressure with 1-2 touches, playing to the far foot, while staying in structure through rotations.',
    NULL, 26, 27, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'DM, LCM, RCM', 'Shift ball away from pressure'),
    (2, 'All players', 'Scan and create space before receiving'),
    (3, 'Rotating player', 'Take the next team-mate''s position after passing')
) AS v(so, role, job);

-- 12. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Session 1: 5. Build-Up Through Attacking Right Back Conditioned Game (4-3-3 v 4-4-2)', 'Right back advances for 3v2 overload',
    'Against a 4-4-2 the DM and central midfielders time the build-up so the right back can push into a midfield/attacking slot, making 3v2 on the right while the right winger moves inside and LCM drifts into the left half-space.',
    'DM and CMs judge the moment to advance',
    'Exploit the half-space with a 3v2 overload and score.',
    '4-4-2', 30, 30, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Push high into midfield line for 3v2'),
    (2, 'Right winger', 'Move inside'),
    (3, 'LCM', 'Move into the half-space'),
    (4, 'Defensive midfielder', 'Set timing of the advance')
) AS v(so, role, job);

-- 13. pp.32-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 2: Defensive Midfielder as the Connecting Link - Positioning Between the Lines to Receive and Accelerate the Play', 'DM in the intermediate space',
    'Vitinha sits 5-8 m behind the opponent''s first pressing line in the gap, always on a diagonal (never flat) line from GK or CB, as the bottom corner of the midfield triangle, receiving on the half-turn facing the weak side. Trained in Session 2 practices 1-2 (p38-39) where the DM supports each CM and switches play.',
    'GK or CB in possession under first-line pressure',
    'Hard-to-intercept support angle that speeds up build-up and switches play.',
    NULL, 32, 32, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Vitinha)', 'Hold intermediate space, diagonal angle, half-turn'),
    (2, 'GK / Centre back', 'Pass to DM''s correct (far) foot'),
    (3, 'LCM / RCM', 'Form triangle top corners, receive the switch')
) AS v(so, role, job);

-- 14. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 2: Scanning and Rotating with Central Midfielders to Create Space', 'DM-CM rotation drags markers',
    'The DM scans the opposing midfielders before receiving and reads how tightly he is marked; he moves into the RCM''s position taking his marker, LCM drops into the DM spot to receive and RCM shifts left. Trained in Session 2 practice 3 (p40) where a lateral DM run triggers the rotation.',
    'DM tightly marked',
    'Constant rotation unbalances the opposing midfield and frees a receiver.',
    NULL, 33, 33, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Vitinha)', 'Scan, then run laterally into RCM slot'),
    (2, 'LCM (Fabian)', 'Drop into the DM position to receive'),
    (3, 'RCM (Neves)', 'Shift across to the left'),
    (4, 'Centre back', 'Find the freed midfielder')
) AS v(so, role, job);

-- 15. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 2: "Third-Man" Principle with DM as Link Between Defence and Attack', 'DM as third man on the bounce',
    'If the DM cannot receive directly from the CB, he moves between the lines to take the lay-off from RCM; in wide play he supports Neves or the right winger, often swapping with Neves to sit near the high right back.',
    'Direct pass CB to DM blocked',
    'Fluid third-man combinations whose change of pace leaves opponents a split second late.',
    NULL, 34, 34, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Marquinhos)', 'Pass into RCM'),
    (2, 'RCM (Neves)', 'Lay off to the DM'),
    (3, 'Defensive midfielder (Vitinha)', 'Arrive as third man and play forward to winger'),
    (4, 'Right winger (Doue)', 'Receive from the third man')
) AS v(so, role, job);

-- 16. pp.35-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 2: Setting the Tempo: When to Hold, Carry the Ball, or Play Forward', 'La pausa: hold, carry or release',
    'The DM chooses between one-touch play and holding the ball (''la pausa'') to pull opponents out; versus two central midfielders he turns, accelerates into the space and carries into the attacking third if unmarked, passing to a free CM if closed down; against a deep block he slows tempo to build an overload.',
    'DM receives facing play; opponent shape (2 DMs or deep block)',
    'Control the rhythm and exploit midfield superiority.',
    NULL, 35, 35, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Vitinha)', 'Hold, carry into space or release'),
    (2, 'LCM / RCM', 'Stay free for the pass when DM is closed'),
    (3, 'Forward / wingers', 'Offer forward targets once DM carries')
) AS v(so, role, job);

-- 17. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 2: Line-Breaking (Penetrating) Forward Passes', 'DM vertical pass then follows',
    'The DM prefers line-breaking passes to safe lateral ones: to wingers when there is space behind the defenders, or through to the forward between the lines; he may then sprint up in support, with the nearest central midfielder covering his spot.',
    'Space behind defenders or forward free between lines',
    'Fast vertical progression while keeping balance if the ball is lost.',
    NULL, 36, 36, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Vitinha)', 'Play forward, then sprint to support'),
    (2, 'Forward (Dembele)', 'Move away from CBs to receive between lines'),
    (3, 'Wingers (Doue, Kvaratskhelia)', 'Run onto passes into space behind'),
    (4, 'Nearest CM', 'Cover the DM''s position for balance')
) AS v(so, role, job);

-- 18. pp.41-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Session 2: Attacking Combination Play / 6v6 (+GK) Defensive Midfielder as Playmaker', 'DM into false 9, then go',
    'Practices where the DM, using a 3v2 in midfield (3-3 shape vs 4-2), drives play: he passes into the forward dropping as a false 9 or carries forward, then moves between the lines to find an advancing CM or winger running behind the back line; CMs occupy the half-spaces.',
    'Right moment with forward available between lines',
    'Turn a midfield overload into runs in behind and finishes.',
    NULL, 41, 42, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Pass into false 9 or carry; then move between lines'),
    (2, 'Forward (false 9)', 'Drop to receive and lay off'),
    (3, 'LCM / RCM', 'Occupy half-spaces, run in behind'),
    (4, 'Wingers', 'Hold width, make well-timed runs into box')
) AS v(so, role, job);

-- 19. pp.44-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 3: Exploiting Width to Stretch Defences and Create Overloads - Maximising Full Width in a 3-3-4 Shape', '3-3-4 full-width attacking line',
    'In attack four players spread across the full width: right back as a winger, right winger inside as a second forward overloading the space in front of the CBs, left winger holding the left touchline; RB, RW and RCM form a triangle.',
    'Settled attack in opponent half',
    'Stretch the block so a central midfielder (LCM) can run between CB and FB onto a through pass in the box.',
    NULL, 44, 44, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Hakimi)', 'Join attacking line as a winger'),
    (2, 'Right winger (Doue)', 'Move inside as second forward; slip through pass'),
    (3, 'Left winger (Kvaratskhelia)', 'Hold full width on the left'),
    (4, 'LCM (Fabian)', 'Time run between CB and FB into the box')
) AS v(so, role, job);

-- 20. pp.45-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 3: Wingers Isolating Opposing Full Backs in 1v1 Situations', 'Winger isolation 1v1',
    'Teammates occupy central or opposite positions so the opposing full back is left alone and cannot help his centre backs; the winger beats him outside to cross or cuts inside to shoot or slide a final pass, and when the winger cuts in the full back overlaps (most often Hakimi on the right).',
    'Winger receives isolated against the full back',
    'Create a chance from a 1v1 on the flank.',
    NULL, 45, 45, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Kvaratskhelia / Doue)', 'Attack 1v1, cross or cut inside'),
    (2, 'Forward and RCM / far winger', 'Move into the box to finish'),
    (3, 'Same-side full back', 'Overlap outside when winger cuts in')
) AS v(so, role, job);

-- 21. pp.46-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 3: Wingers Drawing Defenders Wide to Exploit the Half-Space', 'Winger pins wide, CM attacks half-space',
    'The wide winger draws the opposing full back out, opening a gap to the centre back that a central midfielder attacks from deep, giving a 3-1-6 final-phase shape and a triple threat with the forward.',
    'Gap opens between opposing FB and CB',
    'Outnumber the back line and break through via the half-space.',
    NULL, 46, 46, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Kvaratskhelia)', 'Hold width, draw FB, pass at the right moment'),
    (2, 'LCM / RCM', 'Arrive late from deep into the half-space and cut into the box'),
    (3, 'Forward', 'Pin centre backs, add third threat'),
    (4, 'Same-side full back (Mendes)', 'Give a back-pass option')
) AS v(so, role, job);

-- 22. pp.47-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 3: Switching Play with a Long Diagonal Pass to Isolate the Weak Side Winger', 'Long diagonal to isolated weak-side winger',
    'The weak-side winger stays deliberately isolated; DM (or a full back, e.g. Mendes to Doue with Hakimi overlapping) plays a long diagonal before the block can shift, and the nearest CM moves to support while the forward runs in behind the full back.',
    'Opponent block shifted to ball side',
    'Immediate 1v1 against the isolated full back, played at high speed with minimal touches.',
    NULL, 47, 47, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Vitinha)', 'Pick the moment and hit the long diagonal'),
    (2, 'Weak-side winger (Kvaratskhelia)', 'Stay wide and isolated, attack the full back'),
    (3, 'Nearest CM', 'Move towards winger for a lay-off if pressed'),
    (4, 'Forward (Dembele)', 'Run behind the full back'),
    (5, 'Full back', 'Overlap down the flank')
) AS v(so, role, job);

-- 23. pp.48-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 3: Runs to the Back Post "Blind Spot" to Create Finishing Opportunities', 'Blind-spot runs to the back post',
    'When the winger beats or cuts inside his full back to cross, three runners make different movements: one runs across the centre back to the front post, the forward curves the opposite way into the far-post blind spot, and the far full back also arrives there.',
    'Winger has space to cross after 1v1',
    'Finish from the back post behind defenders'' line of sight, coordinated by visual communication.',
    NULL, 48, 48, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Kvaratskhelia)', 'Cut inside and cross behind defenders'),
    (2, 'Right winger (Doue)', 'Front-post run dragging the centre back'),
    (3, 'Forward (Dembele)', 'Opposite curved run to the far-post blind spot'),
    (4, 'Right back (Hakimi)', 'Arrive in the far-post area')
) AS v(so, role, job);

-- 24. pp.49-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 3 / Session 3: Exploiting Width to Stretch Defences and Create Overloads', 'Wing triangle with full back overlap/underlap',
    'When the winger is doubled up, full back, winger and near central midfielder form a passing triangle on the flank; the full back chooses an outside overlap or an inside underlap to get beyond the defenders and deliver. Drills on p51 and p54 rehearse the triangle and the overlap after the winger drives inside.',
    'Winger receives wide and is marked by two opponents',
    'Free the full back behind the defence to cross, using the doubled winger as bait',
    NULL, 49, 54, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right full back (Hakimi)', 'times overlap or underlap at full speed, crosses'),
    (2, 'Right winger', 'receives wide, holds two markers or drives inside to clear the lane'),
    (3, 'Right central midfielder', 'third point of the triangle, quick one-touch combinations'),
    (4, 'Forward (Dembele)', 'sits near the triangle, runs into space ahead or drops as false 9')
) AS v(so, role, job);

-- 25. pp.52-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 3 / Session 3: Exploiting Width to Stretch Defences and Create Overloads', 'Draw to one flank, DM switches long to weak-side winger',
    'After combining in the ball-side triangle, the ball comes back to the defensive midfielder, who has shifted across, and he plays a long diagonal to the weak-side winger kept wide on the touchline. The wide-gate game (p55, 2-3-3 v 4-4) rewards stretching play this way before finishing.',
    'Opponent block has shifted to the ball-side triangle',
    'Attack the weak side with the winger in space and width that stretches the block',
    NULL, 52, 55, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'shifts to support ball side, then plays the long switch'),
    (2, 'Weak-side winger', 'holds width on the far touchline, receives the switch'),
    (3, 'Ball-side triangle (RB, RW, RCM)', 'combine to pull the block across')
) AS v(so, role, job);

-- 26. pp.53-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 4 / Session 4: The Free Central Midfielder''s Runs into the Final Third', 'Free CM runs into the CB-full back channel',
    'Wingers stay wide so the opposing full back is pinned and a channel opens between centre back and full back; a central midfielder times an unmarked run into that half-space channel to receive a pass from deep (often the DM after winning a duel) and enters the box. Session 3 (p53) and Session 4 (p67, after a DM switch) drill the same run, with a cut-back to the forward.',
    'Deep player (DM) has time to play forward; winger wide holds the full back',
    'CM receives in the half-space unmarked and penetrates the box with a quick first touch',
    NULL, 53, 67, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Fabian/Neves)', 'times the run into the channel between centre back and full back'),
    (2, 'Winger', 'stays wide to stretch and hold the full back'),
    (3, 'Defensive midfielder (Vitinha)', 'beats his man or switches, then threads the pass into the half-space'),
    (4, 'Forward', 'deep run that drags the centre back and opens space, finishes cut-back')
) AS v(so, role, job);

-- 27. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 4 / Session 4: The Free Central Midfielder''s Runs into the Final Third', 'CM rotation: one drops, other slips between midfielders',
    'When the DM is screened and cannot act as playmaker, PSG build through the central midfielders: one drops deep to ask for the ball while the other cuts between two opposing midfielders to receive behind their line; when the forward is fed and drags a centre back, a CM sprints into the space vacated. Sometimes one CM plays a freer advanced role as a second striker.',
    'DM not free to receive',
    'Break the midfield line through the CMs and confuse opposing marking',
    NULL, 57, 57, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left central midfielder (Fabian)', 'drops deep to receive from the back'),
    (2, 'Right central midfielder (Neves)', 'cuts between two opponents to receive behind the midfield line'),
    (3, 'Forward (Dembele)', 'receives the through ball and pulls a centre back towards him'),
    (4, 'Defensive midfielder', 'marked; stays as cover')
) AS v(so, role, job);

-- 28. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 4 / Session 4: The Free Central Midfielder''s Runs into the Final Third', 'Runs into blind spots behind lines',
    'Central midfielders move behind opposing midfielders who cannot watch ball and runner at once, e.g. when the forward holds the ball outside the box; they also overlap a winger who dribbles inside, so the opposing full back must choose between the winger and the runner behind him.',
    'Forward has the ball outside the box, or winger dribbles inside',
    'Arrive unmarked behind a line and create numerical advantages',
    NULL, 59, 59, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-far central midfielder (Neves)', 'moves behind the midfield line into blind spot 1'),
    (2, 'Ball-side central midfielder (Fabian)', 'runs outside/beyond the dribbling winger into blind spot 2'),
    (3, 'Winger (Kvaratskhelia)', 'dribbles inside to free the outside lane'),
    (4, 'Forward', 'holds the ball to fix opponents')
) AS v(so, role, job);

-- 29. pp.60-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 4 / Session 4: The Free Central Midfielder''s Runs into the Final Third', 'Third-man run through forward''s lay-off',
    'A key Enrique mechanism: winger or DM passes into the forward, who lays off first time for an oncoming central midfielder breaking the line at speed into the space outside the box; the DM stays behind to cover in case the pass is cut out. Drilled as a passing diamond (p64), an 8v4 game where CMs sprint to support after a pass to the dropping forward (p65), a pattern with a through ball for the far winger between full back and centre back (p66), and a 2-zone game (p68).',
    'Pass into the forward with his back to goal',
    'CM arrives facing goal in the zone in front of the box with a shooting chance',
    NULL, 60, 68, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Dembele)', 'drops, receives and lays off first time'),
    (2, 'Central midfielder (Fabian/Neves)', 'third-man run from deep onto the lay-off'),
    (3, 'Winger or defensive midfielder', 'plays the first pass into the forward'),
    (4, 'Defensive midfielder (Vitinha)', 'covers behind if the third-man pass is intercepted'),
    (5, 'Far winger', 'alternative: runs between full back and centre back for the through ball')
) AS v(so, role, job);

-- 30. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 4 / Session 4: The Free Central Midfielder''s Runs into the Final Third', 'False 9 drops wide, weak-side CM fills behind',
    'When an advanced full back has the ball, the forward drops out of the centre and pulls his marker, and the weak-side central midfielder runs into the space left behind the opposing centre back; the DM reads the timing and plays the through ball, giving a 1v1 near goal.',
    'Advanced full back in possession and forward drops dragging his marker',
    'Always have a player threatening goal and create a 1v1 in front of the box',
    NULL, 61, 61, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Dembele)', 'drops out of the central position and goes wide, taking his marker'),
    (2, 'Weak-side central midfielder (Fabian)', 'sprints into the space behind the centre back'),
    (3, 'Defensive midfielder (Vitinha)', 'plays the through pass at the right moment'),
    (4, 'Right full back (Hakimi)', 'advanced ball carrier')
) AS v(so, role, job);

-- 31. pp.62-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 4 / Session 4: The Free Central Midfielder''s Runs into the Final Third', 'Flood the box for cut-back crosses',
    'On a low cross into the six-yard box or penalty spot area PSG aim for four or more arrivals, so the centre backs face the forward plus at least two midfielders; runs across the front of the near post are key and an extra hidden runner arrives behind if the first is beaten. The 2-zone game (p68) requires 3-4 players to enter the final zone.',
    'Low cross or cut-back from the byline',
    'Overwhelm the opposing centre backs and get a shot',
    NULL, 62, 68, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Dembele)', 'attacks the box, sometimes arrives late as the hidden man'),
    (2, 'Central midfielders (LCM, RCM)', 'run quickly into the box, one to the near post'),
    (3, 'Far winger', 'attacks far post'),
    (4, 'Wide player on ball', 'delivers the low cut-back')
) AS v(so, role, job);

-- 32. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 5 / Session 5: Rotations and Unbalanced Attacking Structures', 'Overload to Isolate',
    'PSG build a 4v3 or 5v4 on one flank (full back pushes, forward drifts toward the ball) while circulating across the back three to shift the block; then within two passes the DM or centre back hits a quality switch to the weak-side winger, isolated 1v1 against his full back.',
    'Opposition block pulled across to the overloaded side',
    'Weak-side winger beats his full back 1v1 and attacks the box',
    NULL, 70, 70, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right full back (Hakimi)', 'pushes on to overload the right'),
    (2, 'Forward (Dembele)', 'moves toward the ball to occupy and drag defenders'),
    (3, 'Defensive midfielder (Vitinha) / centre back (Marquinhos)', 'switch within two passes'),
    (4, 'Left winger (Kvaratskhelia)', 'stays wide, isolates and beats the full back')
) AS v(so, role, job);

-- 33. pp.71-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 5 / Session 5: Rotations and Unbalanced Attacking Structures', 'Both wingers on the same flank',
    'The far winger deliberately crosses over to join the other winger and create a 3v2 or 2v1 on one wing; if a midfielder follows him space opens centrally, if not the wingers combine with a give-and-go and cut back for the forward. The vacated side is covered by the full back acting as winger, so PSG can switch if the opponent over-commits.',
    'Opposition fails to match the extra winger on that side',
    'Win the flank overload and cut back, or switch to the emptied far side',
    NULL, 71, 71, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Doue)', 'shifts to the left flank to overload'),
    (2, 'Left winger (Kvaratskhelia)', 'give-and-go with the extra winger, gets in behind'),
    (3, 'Forward (Dembele)', 'arrives for the cut-back'),
    (4, 'Right full back', 'holds the right touchline as the winger')
) AS v(so, role, job);

-- 34. pp.72-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 5 / Session 5: Rotations and Unbalanced Attacking Structures', 'Three-player rotations to beat man-marking',
    'Full back, winger and central midfielder (plus forward) swap positions so markers hesitate: left side the forward drops, LCM goes wide and LW moves inside into the vacated striker space; right side RW comes back inside, RB pushes high and RCM drops into the full back slot. Practices drill a CM>W>F>CM wing rotation (p79), a CM>FB>W>CM rotation triggered by the DM''s pass to a centre back with a long ball for the overlapping full back (p80), and an 11v9 game (p82).',
    'Man-oriented marking; trigger in drill = DM passes back to a centre back',
    'Keep the ball, open gaps between defenders and free runners for through passes',
    NULL, 72, 82, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'drops, freeing the central space'),
    (2, 'Winger', 'moves inside into the forward''s space'),
    (3, 'Central midfielder', 'shifts wide or drops into the full back role'),
    (4, 'Full back', 'pushes high and wide or overlaps for a long ball')
) AS v(so, role, job);

-- 35. pp.73-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 5 / Session 5: Rotations and Unbalanced Attacking Structures', 'Decoy runs to free the winger',
    'Off-ball decoy runs empty a zone for a teammate: after the ball reaches the winger the CM overlaps behind him so the full back must follow, letting the winger drive inside; or the full back underlaps, dragging the opposing full back and CM and leaving the winger room to dribble high on the flank.',
    'Ball played to the winger',
    'Winger receives freedom to carry the ball into space',
    NULL, 73, 73, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left central midfielder', 'overlap run behind the left winger as decoy'),
    (2, 'Right full back', 'underlap run to drag the opposing full back'),
    (3, 'Winger', 'exploits freed space, dribbles inside or down the line')
) AS v(so, role, job);

-- 36. pp.74-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 5 / Session 5: Rotations and Unbalanced Attacking Structures', 'Diamonds everywhere: always three passing options',
    'PSG keep diamond shapes all over the pitch so the ball carrier always has three teammates to link with; e.g. when the forward goes wide a diamond forms of forward, full back, winger and CM. The shape is maintained as players rotate; a 10v6 possession game (p78) asks players to scan and keep the diamonds even after switching positions.',
    'Any player in possession, including under pressure',
    'Secure ball circulation with three options in all directions',
    NULL, 74, 78, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player on the ball', 'has three diamond options to choose'),
    (2, 'Forward', 'when wide, forms the top of a diamond with full back, winger, CM'),
    (3, 'Rotating players', 'scan and re-form the diamond after swapping')
) AS v(so, role, job);

-- 37. pp.75-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 5 / Session 5: Rotations and Unbalanced Attacking Structures', 'Asymmetric midfield; DM steps between lines',
    'The midfield is deliberately unbalanced: the DM often pushes up as a CM or attacking midfielder between the lines while a CM drops into his slot and the other CM pushes high, so markers are confused and the DM is often free between the lines with forward passing options.',
    'Settled possession in the opponent half',
    'Create overloads between the lines and pressure the centre backs',
    NULL, 75, 75, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Vitinha)', 'moves into the left CM slot between the lines, receives unmarked'),
    (2, 'Left central midfielder (Fabian)', 'drops into the DM position'),
    (3, 'Right central midfielder (Neves)', 'pushes high'),
    (4, 'Left back (Mendes)', 'plays the pass into the DM')
) AS v(so, role, job);

-- 38. pp.76-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 5 / Session 5: Rotations and Unbalanced Attacking Structures', 'Vertical rotation to empty Zone 14',
    'The forward drops out of the centre while a CM or winger surges up into his spot; centre backs (and possibly the DM) who follow the forward leave Zone 14, the area just outside the box, open for CMs or wingers, and the DM must play the quality pass into it. Drilled with the far winger sprinting in behind on the forward''s pass back to the DM (p81).',
    'Forward drops and a defender follows him; in drill, forward''s pass back to the DM',
    'Open Zone 14 for a shot or final pass',
    NULL, 76, 81, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Dembele)', 'drops to pull a centre back out'),
    (2, 'Central midfielders / wingers (Fabian, Neves, Kvaratskhelia, Doue)', 'surge into the vacated Zone 14'),
    (3, 'Defensive midfielder (Vitinha)', 'plays the vertical pass into Zone 14')
) AS v(so, role, job);

-- 39. pp.84-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 6 / Session 6: The ''False 9'' Attacking Movements of the Forward', 'False 9 drops to create central superiority',
    'The forward leaves both centre backs with nobody to mark and receives between the lines from a centre back or full back, then looks for a final pass in behind; both CMs drop to open a channel to him, the vacated striker spot is filled by a winger or CM, and the DM stays as support. Session 6 drills it as a double rondo with the forward in a central free zone switching play (p91), and build-up games where the dropping forward makes a 3v2 up front (p92) or a 4v3 in midfield (p93).',
    'Ball with a centre back or full back; CMs drop to open the lane',
    'Numerical superiority in the centre and a forward facing goal',
    NULL, 84, 93, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Dembele)', 'drops into space between the lines, receives and plays the final pass'),
    (2, 'Central midfielders (LCM, RCM)', 'drop or move wide to open the channel'),
    (3, 'Winger (Doue) or CM', 'fills the vacated centre-forward position'),
    (4, 'Defensive midfielder', 'stays back for support'),
    (5, 'Centre back / full back', 'passes into the dropping forward')
) AS v(so, role, job);

-- 40. pp.85-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 6 / Session 6: The ''False 9'' Attacking Movements of the Forward', 'False 9 pulls centre back, winger runs across',
    'When a centre back follows the forward''s deep drop, a big gap opens in the middle of the defence and the winger (with full back holding the width) sprints across into it; the forward positions over the opposing DM so a CM can push between the lines and support. A pattern (p94) adds the DM breaking the line into the forward and a through pass for the winger running in behind.',
    'Centre back follows the dropping forward',
    'Winger runs into the gap behind the defence, timing synchronised',
    NULL, 85, 94, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Dembele)', 'drops deep, unbalances the centre backs'),
    (2, 'Right winger (Doue)', 'runs across into the gap'),
    (3, 'Right back (Hakimi)', 'high and wide holding width'),
    (4, 'Right central midfielder', 'moves between the lines in support / plays through pass')
) AS v(so, role, job);

-- 41. pp.86-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 6 / Session 6: The ''False 9'' Attacking Movements of the Forward', 'Forward as wall for penetrating combinations',
    'The forward receives back to goal and lays off first time to an oncoming midfielder, who then plays a quick penetrating pass for the winger''s run, or plays a one-two back with the forward to get in behind; DM and CMs arrive from deep for shots or drives into the box.',
    'Pass into the forward''s feet with back to goal',
    'Penetrate behind the defence with quick combinations',
    NULL, 86, 86, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Dembele)', 'wall pass back to the midfielder'),
    (2, 'Right central midfielder (Neves)', 'plays first time in behind or returns one-two'),
    (3, 'Right winger (Doue)', 'attacks space between defenders'),
    (4, 'Defensive midfielder (Vitinha)', 'plays the first pass and arrives from deep')
) AS v(so, role, job);

-- 42. pp.87-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 6 / Session 6: The ''False 9'' Attacking Movements of the Forward', 'Provoke press, false 9 receives as playmaker',
    'PSG invite pressure and the CMs move wide to drag opposing midfielders with them, opening a lane from the centre back to the forward free in the central channel; he turns, attacks the defenders at speed and looks for a final pass to a winger or a forward-pushing CM.',
    'Opposing midfielders follow the CMs wide',
    'Forward receives facing goal between the lines and drives at the back line',
    NULL, 87, 87, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (Fabian, Neves)', 'move wide to pull opposing midfielders out'),
    (2, 'Centre back (Marquinhos)', 'passes into the forward in the central channel'),
    (3, 'Forward (Dembele)', 'receives, turns and drives, then slips a winger or CM in'),
    (4, 'Wingers', 'run in behind for the final pass')
) AS v(so, role, job);

-- 43. pp.88-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 6 / Session 6: The ''False 9'' Attacking Movements of the Forward', 'Late diagonal near-post run by false 9',
    'Once the ball goes wide, the forward makes a late diagonal or curved run toward the near post, starting forward and suddenly changing direction to arrive unmarked; the far winger attacks the far post and a CM and the full back also enter the box. Drilled with a switch to the wide winger who crosses for forward, CM and far winger (p95).',
    'Ball played wide, winger beats his full back',
    'Forward arrives unmarked in a central finishing spot',
    NULL, 88, 95, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Dembele)', 'late diagonal run to the near post'),
    (2, 'Left winger (Kvaratskhelia)', 'beats the full back and delivers low'),
    (3, 'Right winger (Doue)', 'run to the far post'),
    (4, 'Central midfielder (Fabian) and right back (Hakimi)', 'extra runs into the box')
) AS v(so, role, job);

-- 44. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 6 / Session 6: The ''False 9'' Attacking Movements of the Forward', 'False 9 one-twos with CMs and wingers',
    'The forward creates one-two chances to bypass the central block: a CM carries forward drawing the press and gets the return pass just outside the box; or a winger who moved inside (full back covering his lane) combines with the forward, who has moved into the half-space, and runs in behind the full back.',
    'CM carry draws a midfielder, or winger receives inside',
    'Break through the defensive structure into the box or a shooting spot',
    NULL, 89, 89, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Dembele)', 'offers support for the one-two'),
    (2, 'Left central midfielder (Fabian)', 'carries forward, gives and goes'),
    (3, 'Right winger (Doue)', 'moves inside, one-two, runs in behind the full back'),
    (4, 'Right back (Hakimi)', 'pushes on to cover the winger''s lane')
) AS v(so, role, job);

-- 45. pp.97-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'to_defend', 'Tactical Situation 7: Immediate Ball Recovery with 5-Second Counter-Pressing', '5-second counter-press: nearest three swarm',
    'The instant PSG lose the ball, the three players closest to it sprint at the carrier; in the final third that is usually the forward plus the ball-side winger and central midfielder. Session 7 games (5v3, 4v4+2, 6v5 wide, 6v6 in 2-3-1, 8v8) all drill keeping short distances in possession so the nearest three can win it back in 3-5 seconds.',
    'Ball lost, especially in the attacking third',
    'Deny the carrier time to look up, stop or spoil the first forward pass, and win it back within about 5 seconds.',
    NULL, 97, 106, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Dembele)', 'One of the three nearest; presses the carrier or his back pass'),
    (2, 'Ball-side winger (Kvaratskhelia)', 'Closes the carrier from the outside'),
    (3, 'Ball-side central midfielder (Fabian)', 'Closes from inside, shuts the central escape'),
    (4, 'Far full back', 'Sprints back into his defensive position'),
    (5, 'Defensive midfielder (Vitinha)', 'Safe outlet once the ball is won, so the next attack starts while the opponent is still disorganised')
) AS v(so, role, job);

-- 46. pp.98-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'to_defend', 'Tactical Situation 7: Immediate Ball Recovery with 5-Second Counter-Pressing', 'Counter-press ''4th player'' cuts release pass',
    'While three players press the new carrier, a fourth player near the pressure reads the opponent''s easiest release pass and positions to intercept it; most often the DM steps to the inside midfield option, and the ball-side full back presses the opposing winger.',
    'Three-man counter-press engaged on the carrier',
    'Remove the escape pass so the press wins the ball; if the press fails and the team is unbalanced, a tactical foul stops the counter.',
    NULL, 98, 98, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Vitinha)', 'Usual 4th player; presses the next pass option, normally the inside midfielder'),
    (2, 'Ball-side full back (Mendes)', 'Ready to press the opposing winger aggressively, forcing him to face his own goal'),
    (3, 'Forward, winger, central midfielder', 'The three pressing the ball carrier'),
    (4, 'Any player near an imbalance', 'Tactical foul if the counter-press is beaten')
) AS v(so, role, job);

-- 47. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 7: Immediate Ball Recovery with 5-Second Counter-Pressing', 'Compact attacking shape for counter-press',
    'In possession PSG keep players close together with tight lines, so circulation is easy and, when the ball is lost, several players are already within pressing range.',
    'Settled attack in the opposition half',
    'Have enough bodies near the ball to counter-press immediately after a turnover.',
    NULL, 99, 99, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Vitinha)', 'Pushes up behind the central midfielders as the counter-press anchor'),
    (2, 'Central midfielders (LCM, RCM)', 'Support the front three, ready to press on loss'),
    (3, 'Full backs (LB, RB)', 'Stay near the wingers as passing options and to press around the turnover')
) AS v(so, role, job);

-- 48. pp.100-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'to_defend', 'Tactical Situation 7: Immediate Ball Recovery with 5-Second Counter-Pressing', 'High back line keeps team compact after loss',
    'When possession is lost, the back line pushes beyond halfway to shrink the space behind the counter-press; centre backs and a full back mark the opposing forwards tightly so no attacker is free if the press fails.',
    'Ball lost high; opponent receives under pressure or with a poor first touch',
    'Keep the team short and stop opponents turning, playing a through ball or dribbling into space.',
    NULL, 100, 100, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Pacho, Marquinhos)', 'Push up and mark the opposing forwards tightly'),
    (2, 'Ball-side full back (Mendes)', 'Pushes up and marks his man'),
    (3, 'Back line', 'Reacts quickly to block counter-attack routes; nobody unmarked')
) AS v(so, role, job);

-- 49. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'in_possession', 'Tactical Situation 8: Rest Defence Structure and Defensive Transition', 'Rest defence 3-1 behind the ball',
    'While attacking in the opponent''s half PSG keep at least four players behind the ball in a 3-1 shape: back three with the DM just in front, all at short distances so one can step in if another is beaten. If the DM pushes on, a central midfielder holds; the keeper stays high to sweep long balls.',
    'Team attacking in the opposition half',
    'Be ready to stop counter-attacks the moment possession is lost.',
    NULL, 108, 108, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three (LB, CB, CB)', 'Cover the area that counter-attacks would use, short distances between them'),
    (2, 'Defensive midfielder (Vitinha)', 'Sits in front of the back three, short distance to them'),
    (3, 'LCM or RCM', 'Holds position for cover if Vitinha pushes higher'),
    (4, 'Goalkeeper (Donnarumma)', 'Plays outside his box to cut out long passes and offer a safe pass back')
) AS v(so, role, job);

-- 50. pp.109-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'to_defend', 'Tactical Situation 8: Rest Defence Structure and Defensive Transition', 'Rest defenders mark forwards, press on loss',
    'Even while PSG attack, the rest defenders stay tight to the opposing forwards and read their body shape so they can step in and press the receiver the moment the ball is lost. The deepest players direct the midfielders on which spaces to close.',
    'Possession lost; pass aimed at an opposing forward',
    'Stop the receiver turning or driving forward and keep defensive balance.',
    NULL, 109, 109, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Marquinhos, captain)', 'Leads and organises the press and the team''s balance'),
    (2, 'Rest-defence centre backs / full back', 'Track forwards closely, press the receiver'),
    (3, 'Defensive midfielder', 'Adds pressure on the carrier; tactical foul if a clear threat appears')
) AS v(so, role, job);

-- 51. pp.110-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'to_defend', 'Tactical Situation 8: Rest Defence Structure and Defensive Transition', 'Defensive diamond protects centre, forces wide',
    'With the attack deep in the final third, the rest-defence unit narrows into a diamond around the centre. On a turnover it blocks the direct route through the middle, double-marks the receiver (defender plus DM), covers with the deepest centre back, and clears any ball over the top out wide. Session 8 practices drill sprinting into the compact diamond, the DM+defender double press, and the nearest defender clearing to wide target areas while the centre backs shift to mark.',
    'Ball lost high up / long ball played to an opposing forward',
    'Make the counter go wide and far from goal, causing hesitation and errors.',
    NULL, 110, 115, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (Mendes)', 'Steps to the receiver and contests'),
    (2, 'Defensive midfielder (Vitinha)', 'Joins to double-mark the receiver, or intercepts from in front'),
    (3, 'Deepest centre back (Pacho)', 'Cover and balance behind'),
    (4, 'Nearest defender', 'On a ball over the top, clears it to a safe wide area'),
    (5, 'Other centre backs', 'Shift across to mark the remaining attackers')
) AS v(so, role, job);

-- 52. pp.111-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'to_defend', 'Tactical Situation 8: Rest Defence Structure and Defensive Transition', 'Delay wide counter until support recovers',
    'When an opposing forward drifts wide to receive, the nearest rest defender marks him tightly to slow the counter, the centre backs and midfielders slide across, and the ball-side winger drops to press and cut the supporting pass while weak-side players sprint back. Session 8 game 4 trains this with a 3v3 rest-defence zone and the winger delayed and supported.',
    'Opposing forward moves wide to receive a counter-attack pass',
    'Keep a spare player around the ball so no opponent breaks free while team-mates recover.',
    NULL, 111, 116, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side full back (LB)', 'Tracks the wide forward and marks him closely'),
    (2, 'Centre backs', 'Left one shifts across, right one picks up the other forward'),
    (3, 'DM and LCM', 'Move across; RCM drops into the DM spot'),
    (4, 'Ball-side winger (LW)', 'Drops quickly to press and block the support pass when the ball is near the touchline'),
    (5, 'Weak-side full back and winger (RB, RW)', 'Recovery sprints')
) AS v(so, role, job);

-- 53. pp.119-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'out_of_possession', 'Tactical Situation 9: High Pressing with Man-Oriented Triggers and Sideline Traps', 'Curved-run high press forces long',
    'PSG press right up onto the goalkeeper. The forward arcs his run to cut the pass to the nearest centre back, the wingers arc in to press the centre backs while blocking passes to the full backs, and the rest push up as a compact support zone behind.',
    'Opponent playing out from the goalkeeper',
    'Take away short options so the keeper or centre backs must risk a central pass or kick long.',
    NULL, 119, 119, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Dembele)', 'Curved run that blocks the centre back and forces play to one side or long'),
    (2, 'Wingers (LW, RW)', 'Press the centre backs in an arc, cutting off the full backs'),
    (3, 'Midfield and back line', 'Hold high, compress the gaps so pressers have close support')
) AS v(so, role, job);

-- 54. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'out_of_possession', 'Tactical Situation 9: High Pressing with Man-Oriented Triggers and Sideline Traps', 'Hakimi jumps; back three hold 3v3',
    'In the high press the right back pushes up to press the opposing left back while the right winger presses the centre back, creating 1v1s across the back line. Hakimi only jumps once the defenders are already under pressure; with the press on the far side he stays balanced to press after a switch or drop in. Behind him the back three mark the opposing front three and the DM covers in front.',
    'Ball goes wide to the opposing left back with defenders already pressed',
    'Man-for-man pressure across the opposition back line without losing balance at the back.',
    NULL, 120, 120, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Hakimi)', 'Presses the left back high; balanced if press is on the other side'),
    (2, 'Right winger (Doue)', 'Presses the centre back'),
    (3, 'Back three', 'Stay in place marking the front three, ready for 3v3'),
    (4, 'Defensive midfielder (Vitinha)', 'Covers the central area in front of the back three, wins second balls')
) AS v(so, role, job);

-- 55. pp.121-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'set_piece', 'Tactical Situation 9: High Pressing with Man-Oriented Triggers and Sideline Traps', 'Kick-off out of play, press throw-in',
    'From kick-off PSG sometimes kick the ball out of play deep in the opponent''s half on purpose, then press the resulting throw-in in a crowded wide area.',
    'Own kick-off',
    'Start the game or restart with a sideline trap high up the pitch.',
    NULL, 121, 121, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Kick-off taker', 'Plays the ball out deep in the opposition half'),
    (2, 'Front three and midfielders', 'Swarm the throw-in zone, strong-side overload')
) AS v(so, role, job);

-- 56. pp.121-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'out_of_possession', 'Tactical Situation 9: High Pressing with Man-Oriented Triggers and Sideline Traps', 'Strong-side overload sideline trap',
    'PSG steer the build-up to a flank, then the far winger tucks in centrally to create a numbers-up press (5v4 in the example) and lock the opponent near the touchline. The weak side is deliberately left empty because a switch under that pressure is very hard and PSG can recover while the ball travels. Session 9 drills (colour-called pressing shifts, 5v7 strong-side press, 5v4 ultra-high press game) train the shift and the overload.',
    'Opponent''s build-up goes to a wide area',
    'Squeeze the opponent into a narrow space where they cannot build and force an error to win the ball and break fast.',
    NULL, 121, 129, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side winger (Kvaratskhelia)', 'Presses the full back intensely'),
    (2, 'Far-side winger (Doue)', 'Moves inside to strengthen the press'),
    (3, 'Central midfielders (Fabian, Neves) and DM (Vitinha)', 'Slide across together to complete the overload'),
    (4, 'Front three', 'Set the direction of the press'),
    (5, 'Weak side', 'Left empty on purpose')
) AS v(so, role, job);

-- 57. pp.122-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'out_of_possession', 'Tactical Situation 9: High Pressing with Man-Oriented Triggers and Sideline Traps', 'Man-to-man midfield press, win second balls',
    'Each PSG midfielder takes a direct opponent so no opposing midfielder is free centrally; the three adapt their positions to match up and block easy lanes. Opposing defenders are left with no central pass and kick long, and as the ball travels the three midfielders drop toward the back line to contest the second ball, then break fast. Session 9 game 4 trains man-to-man marking with presses triggered from the front through midfield.',
    'Opponent defenders in possession; ball passes into midfield',
    'Force risky or long passes, win the second ball and counter while the opponent is disorganised.',
    NULL, 122, 128, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (Fabian, Neves)', 'Mark their opposite numbers, block central lanes'),
    (2, 'Defensive midfielder (Vitinha)', 'Matches the remaining midfielder'),
    (3, 'Midfield three', 'Drop toward the defence as a long ball is played to win the second ball'),
    (4, 'Defenders', 'Deal with the forced long ball')
) AS v(so, role, job);

-- 58. pp.123-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'out_of_possession', 'Tactical Situation 9: High Pressing with Man-Oriented Triggers and Sideline Traps', 'Back line pushes up behind press',
    'For the high press to work, the back three push up and the DM holds in front of them so the distance between the lines is no more than about 35 m; defenders stay close to the attackers, and the front three press the ball while blocking central lanes.',
    'Front line triggers a high press',
    'Keep the team short so every presser only has a short distance to cover; the whole team presses together.',
    NULL, 123, 123, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'Push up and stay tight to the attackers'),
    (2, 'Defensive midfielder (Vitinha)', 'Holds the space in front of the defenders'),
    (3, 'Forward and wingers (Dembele, Kvaratskhelia, Doue)', 'Press the ball while blocking central passes')
) AS v(so, role, job);

-- 59. pp.131-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'out_of_possession', 'Tactical Situation 10: Compact Defensive Blocks and Coordinated Defensive Movement', 'Compact block shifts as one',
    'Out of possession PSG form a tight block about 30 m deep with all ten outfield players moving together toward the ball, midfield-to-defence gap under 10 m. On a back pass the line steps up and the team pushes forward; when the ball is on a flank the whole block slides to that side, leaving the far side open. Session 10 practice 1 drills shifting against a back four passing across.',
    'Ball moves sideways or backwards in the opponent''s build-up',
    'Deny play between the lines and keep the ball away from the box.',
    NULL, 131, 136, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive line', 'Steps up the moment the opponent passes backwards'),
    (2, 'Midfield line', 'Stays within 10 m of the back line'),
    (3, 'Weak-side players', 'Move inside to close gaps to the group'),
    (4, 'All outfield players', 'Shift together at the same moment, close enough to stop any pass through gaps')
) AS v(so, role, job);

-- 60. pp.132-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'out_of_possession', 'Tactical Situation 10: Compact Defensive Blocks and Coordinated Defensive Movement', 'Midfield three locks central zone',
    'The central priority is the middle: the two central midfielders and the DM mark opposing midfielders tightly and block lanes to the attackers, squeezing them until they err. When the ball is on the far side, a full back may tuck in as an extra holding midfielder with the winger on that side dropping to cover the flank (extent depends on opponent shape). Session 10 practice 2 drills the three moving as a unit to intercept passes through the middle.',
    'Opponent tries to play through midfield',
    'Close every pass into the central zone and force mistakes.',
    NULL, 132, 137, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (LCM, RCM)', 'Mark opposing midfielders, block lanes to attackers'),
    (2, 'Defensive midfielder', 'Same, from the middle of the three'),
    (3, 'Far-side full back (LB or RB)', 'Tucks inside as an additional DM when the ball is far away'),
    (4, 'Corresponding winger', 'Drops to cover the flank')
) AS v(so, role, job);

-- 61. pp.133-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'out_of_possession', 'Tactical Situation 10: Compact Defensive Blocks and Coordinated Defensive Movement', '4-4-2 mid-block forces play wide',
    'In a mid-block PSG switch to a 4-4-2: one central midfielder steps up beside the forward to disrupt the centre backs, the wingers tuck in to block central lanes, the other central midfielder and DM guard the centre, and Vitinha presses any ball played between the lines. When full-width coverage matters more, a 4-5-1 is used; key opponents may get a man-marker (Vitinha or Dembele). Session 10 game 3 trains it against a 3-4-2-1.',
    'Opponent building in the middle third',
    'Shut the centre and push the opponent to the flanks.',
    NULL, 133, 138, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Fabian)', 'Steps up to the forward line to hassle the centre backs'),
    (2, 'Wingers (LW, RW)', 'Tuck inside to block central lanes, then defend the flanks vs full backs'),
    (3, 'Other CM and DM', 'Hold the centre'),
    (4, 'Defensive midfielder (Vitinha)', 'Screens the back line and presses balls into the gap'),
    (5, 'Forward (Dembele)', 'Front of the block; may man-mark a key opponent')
) AS v(so, role, job);

-- 62. pp.134-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'luis-enrique-psg-tactical-analysis-and-training-sessions-107-tactics-practices'), 'out_of_possession', 'Tactical Situation 10: Compact Defensive Blocks and Coordinated Defensive Movement', '4-1-4-1 low block triangles',
    'In a low block PSG sit in a 4-1-4-1. A central triangle of the DM and the two centre backs at the edge of the box blocks central penetration and runs into the box (Zone 14), with the DM filling in if a centre back steps out and dropping into the line on crosses so attackers can be man-marked. When the ball goes wide, full back, central midfielder and winger form a wide triangle that is very hard to break. Session 10 games 4-5 drill the DM shielding the centre backs and Zone-14 protection.',
    'Opponent in the final third / ball played wide or crossed',
    'Stop central entries and box runs, force play wide where there is less danger, then counter quickly on a regain.',
    NULL, 134, 140, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Vitinha)', 'Sits between the two banks of four; covers a centre back who steps out; becomes a centre back on crosses'),
    (2, 'Centre backs', 'Base of the central triangle; quick lateral moves'),
    (3, 'Ball-side full back (Hakimi)', 'Corner of the wide triangle'),
    (4, 'Ball-side CM (Neves) and winger (Doue)', 'Complete the wide triangle')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('2103-coaching-book-luis-enrique-psg-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
