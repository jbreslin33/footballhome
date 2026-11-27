-- 5023 📚 Coaching book patterns: "Zonal Marking: From Ajax to Zidane, the
-- Making of Modern Soccer" (Michael Cox, Bold Type Books) — Kindle library
-- (spreads s001–s148 from Kindle Cloud Reader).  A tactics history: each
-- concrete team behaviour the author explains written up in OUR OWN WORDS,
-- naming the team / coach / season, with who does what.  Biography and
-- story left out.  Owner's personal library.  (James 11/27 Kindle picks)
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    team        = 'European football, nation by nation',
    season      = '1992-2018',
    method_note = 'A tactics history of European football from 1992 to 2018, told country by country in seven parts: Dutch total football (Cruyff and Van Gaal''s Ajax), Italian zonal defending and the number 10 (Sacchi and Capello''s Milan, Lippi''s Juventus, catenaccio), French speed and the water carrier, Portugal''s structure, wingers and Mourinho, Spain''s tiki-taka, false 9s and El Clasico (Guardiola''s Barcelona), Germany''s verticality and gegenpressing (Klopp, Tuchel, Low), and England''s mixer. Patterns are the concrete team behaviours the book explains, naming the side and season, in our words. Kindle edition: page numbers are screen spreads.'
WHERE slug = 'kindle-zonal-marking';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking');

-- 1. pp.8-8
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '1 Individual versus Collective', 'Total Football vertical-line interchange',
    'Dutch 1970s Ajax/Holland: players swap positions only within their own vertical lane; when a defender carries forward, the midfielder and forward in that lane drop to fill his slot.',
    'Defender advances with or without the ball',
    'Keep the shape intact while letting any player join the attack.',
    NULL, 8, 8, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back / centre back', 'Charges forward into attack'),
    (2, 'Midfielder in same lane', 'Drops back to cover the vacated spot'),
    (3, 'Forward in same lane', 'Retreats a line to rebalance')
) AS v(so, role, job);

-- 2. pp.10-10
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '1 Individual versus Collective', 'Van Gaal wingers: beat one, else switch',
    'Van Gaal''s Ajax used two touchline wingers (Overmars, Finidi) with a strict rule: take on a single defender, but if doubled, turn back inside and switch play.',
    'Winger faced by two defenders',
    'Keep possession and attack the weak side rather than lose the ball in a crowded flank.',
    NULL, 10, 10, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide winger (Overmars / Finidi George)', 'Hug touchline; go 1v1 when isolated'),
    (2, 'Winger when doubled', 'Turn inside and play back/across'),
    (3, 'Central midfielders', 'Receive and switch to the far flank')
) AS v(so, role, job);

-- 3. pp.10-11
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '1 Individual versus Collective', 'Deep-dropping forward feeding midfield runners',
    'Cruyff''s Barcelona: Laudrup started as a centre-forward but dropped deep to receive, threading no-look through balls for midfielders and Stoichkov/Romario running beyond.',
    'Forward drops off the centre-backs into midfield',
    'Pull a defender out and release runners into the gap behind.',
    NULL, 10, 11, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping forward (Laudrup)', 'Come short, turn, thread through balls'),
    (2, 'Midfield runners', 'Break beyond into the vacated space'),
    (3, 'Strikers (Stoichkov, Romario)', 'Run in behind for the final ball')
) AS v(so, role, job);

-- 4. pp.15-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '2 Space', 'The hunt: high line, compact pressing',
    'Michels'' Holland, then Cruyff''s Barcelona and Van Gaal''s Ajax: the striker is the first defender, the back line steps up toward halfway and lines stay no more than 10-15 m apart to box opponents into their own half; Michels used an aggressive offside trap with the whole line stepping together.',
    'Ball lost / opponent in possession in their half',
    'Shrink the active pitch, regain the ball high and catch attackers offside.',
    NULL, 15, 15, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker / number 10 (Litmanen)', 'First defender, presses the ball-holder'),
    (2, 'Back line (Vasovic, Krol)', 'Push up toward halfway, step together for offside'),
    (3, 'Midfield line', 'Stay within 10-15 m of the other lines'),
    (4, 'Holding player (Neeskens)', 'Aggressively mark the opposition playmaker')
) AS v(so, role, job);

-- 5. pp.15-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '2 Space', 'Space with ball big, without ball small',
    'Cruyff''s core principle taken from Michels: in possession spread to make the pitch as large as possible; on losing the ball, squeeze together immediately.',
    'Change of possession',
    'Maximise space for us and minimise it for the opponent.',
    NULL, 15, 15, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'Stretch to the touchlines on possession'),
    (2, 'Whole team', 'Contract quickly when the ball is lost')
) AS v(so, role, job);

-- 6. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '2 Space', 'Dutch 3-4-3 diamond vs two strikers',
    'Cruyff''s Ajax swapped a defender for a number 10: three at the back against the usual two forwards, a diamond midfield (holder between defence and midfield, box-to-boxers either side, 10 between midfield and attack) and three forwards.',
    'Opponent plays two up front',
    'Spare man at the back only by one, gain an extra creator in midfield.',
    '4-4-2', 16, 16, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'Cover two strikers with one spare'),
    (2, 'Holding midfielder', 'Shuttle between defence and midfield'),
    (3, 'Number 10', 'Link midfield and attack'),
    (4, 'Box-to-box pair', 'Support either side of the diamond')
) AS v(so, role, job);

-- 7. pp.16-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '2 Space', 'Wide wingers and decoy nine open 10',
    'Dutch 4-3-3/3-4-3: two chalk-on-boots wingers pull the full-backs wide and a centre-forward (Pettersson, R. de Boer) runs to push the centre-backs deep, so space opens for the number 10.',
    'Settled possession',
    'Stretch the back four horizontally and vertically to free the 10 between lines.',
    NULL, 16, 17, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (Van ''t Schip, Overmars, Roy)', 'Stay on touchline, do not drift inside'),
    (2, 'Centre-forward', 'Lead the line, run to drag centre-backs back'),
    (3, 'Number 10 / shadow striker (Bergkamp, Litmanen)', 'Exploit space between lines')
) AS v(so, role, job);

-- 8. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '2 Space', 'Schaduwspits: nine sacrifices for the ten',
    'The ''shadow striker'' role: a deeper-lying second striker arrives late from about 15 yards while the nine occupies both centre-backs; Holland v Germany Euro 92 - Van Basten ran near post dragging both centre-backs and signalled Winter to cut back to Bergkamp arriving behind.',
    'Wide player in crossing position',
    'Create a free finisher arriving behind the decoy run.',
    NULL, 17, 17, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 9 (Van Basten)', 'Sprint near post, take both centre-backs'),
    (2, 'Shadow striker (Bergkamp)', 'Hold back, arrive late into the space behind'),
    (3, 'Wide midfielder (Winter)', 'Pull back behind the nine''s run')
) AS v(so, role, job);

-- 9. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '2 Space', 'Between the lines vs flat back four',
    'Bergkamp found the English flat back four (two centre-backs v two strikers, no libero) left space between defence and midfield that an Italian sweeper would close.',
    'Opponent defends with a flat four and no spare man',
    'Receive between the lines and play or shoot before a centre-back can step out.',
    '4-4-2', 18, 18, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep-lying forward (Bergkamp)', 'Drop into the gap in front of the back four'),
    (2, 'Partner striker', 'Pin the centre-backs so neither can step up')
) AS v(so, role, job);

-- 10. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '2 Space', 'Van Gaal positional structure, no lane swaps',
    'Van Gaal''s Ajax banned the old Total Football up-and-down flank swapping: the right-back, right midfielder and right-winger kept their own zones so space was occupied evenly; trained with positional games.',
    'Any possession phase',
    'Stable structure for passing with less wasted running.',
    NULL, 18, 18, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'Stay behind the wingers, not past them'),
    (2, 'Wingers', 'Hold the width zone'),
    (3, 'Full backs', 'Keep their own lane')
) AS v(so, role, job);

-- 11. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '2 Space', 'Ajax 1995: hybrid holder, diamond, dropping 10',
    'Ajax 1994/95: back three of ball-players, Rijkaard as the hinge who moved between back three and back four, Seedorf and Davids either side supporting the strikers not the wingers, wingers left to isolate full-backs, Litmanen dropping to overload midfield then motoring into the box.',
    'Build-up from the back',
    'Overload midfield centrally while the wingers isolate full-backs 1v1.',
    NULL, 18, 18, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Rijkaard)', 'Drop between defenders or hold midfield as needed'),
    (2, 'Shuttlers (Seedorf, Davids)', 'Battle centrally, push up to support strikers'),
    (3, 'Number 10 (Litmanen)', 'Drop to overload midfield, then run into box'),
    (4, 'Wingers (Finidi, Overmars)', 'Stay wide to isolate full-backs')
) AS v(so, role, job);

-- 12. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '2 Space', 'Quick switch to the far winger',
    'When Ajax met a deep defence and the near winger could not get 1v1, two or three quick passes through Davids, Rijkaard and Seedorf (or one long crossfield ball) moved play to the opposite winger.',
    'Near-side winger crowded out',
    'Draw the opponent toward the centre, then give the far winger space to beat his full-back and cross.',
    NULL, 18, 18, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near winger', 'Draw defenders, recycle inside'),
    (2, 'Central midfielders (Davids, Rijkaard, Seedorf)', 'Move ball across in 2-3 touches'),
    (3, 'Far winger', 'Receive with space, dribble and cross')
) AS v(so, role, job);

-- 13. pp.18-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '2 Space', 'Holder drops in to stretch compact block',
    'Ajax v Capello''s Milan, 1995 final: after Milan''s forwards screened the centre-backs and Boban/Desailly marked Rijkaard and Litmanen, Van Gaal dropped Rijkaard into defence (Milan midfield would not push that high), added a fast forward (Kanu, then Kluivert) to push Milan''s line back.',
    'Opponent narrow, compact and marking the playmakers',
    'Free a deep playmaker and lengthen the opponent so space opens in midfield.',
    '4-4-2', 18, 19, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Rijkaard)', 'Drop into the back line and dictate play'),
    (2, 'Fast forward (Kanu / Kluivert)', 'Threaten in behind to push the line deep'),
    (3, 'Centre-forward (R. de Boer)', 'Move into midfield to add a body')
) AS v(so, role, job);

-- 14. pp.18-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '2 Space', 'Screen ball-players, force weak build-up',
    'Capello''s Milan v Ajax 1995: narrowed midfield four, the 10 (Boban) shadowed Rijkaard, Desailly man-marked Litmanen, and the two forwards positioned to block passes to Blind and F. de Boer so build-up went through the weaker Reiziger.',
    'Opponent goal kick / build-up through back three',
    'Steer possession to the least skilled defender and smother the creators.',
    '3-4-3', 18, 19, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards (Simone, Massaro)', 'Cut passing lanes to the best ball-playing defenders'),
    (2, 'Number 10 (Boban)', 'Mark the deep playmaker, then drop left'),
    (3, 'Defensive midfielder (Desailly)', 'Man-mark the opposing 10')
) AS v(so, role, job);

-- 15. pp.20-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '3 Playing Out from the Back', 'Sweeper-keeper as eleventh outfielder',
    'Cruyff''s idea, carried by Jongbloed, Menzo, Van der Sar and Busquets senior: the keeper starts high, sweeps behind an advanced line and is used as a safe outfield passer who recycles back passes instead of booting them.',
    'Back pass or ball over a high line',
    'Support a high defensive line and add a spare passer in build-up.',
    NULL, 20, 22, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Stand high, sweep behind, pass short to recycle'),
    (2, 'Defenders', 'Use the keeper as a safe back-pass option')
) AS v(so, role, job);

-- 16. pp.21-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '3 Playing Out from the Back', 'Calm keeper starts full-pitch move',
    'Ajax at MVV, 1995: under pressure Reiziger''s back pass forced Van der Sar to the byline; instead of clearing he beat the striker and returned it, then a defender dribbled forward, the forwards dropped to link and the centre-back ran through, finishing with a square ball to the far-post winger.',
    'Underhit back pass under pressure',
    'Escape pressure by keeping the ball and launch an attack from deep with defenders joining.',
    NULL, 21, 22, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Van der Sar)', 'Stay composed and pass back out short'),
    (2, 'Full back (Reiziger)', 'Carry forward past a man'),
    (3, 'Forwards (Litmanen, R. de Boer)', 'Drop to link'),
    (4, 'Centre back (Blind)', 'Run through into the box'),
    (5, 'Far winger (Overmars)', 'Arrive at far post')
) AS v(so, role, job);

-- 17. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '3 Playing Out from the Back', 'Defend forward at halfway',
    'Krol''s and Cruyff''s rule: keep the opponent on the halfway line rather than protect your own goal; defenders should move forward to pressure the ball rather than run back when it is lost.',
    'Possession lost',
    'Defend far from goal with a high line and pressure on the ball.',
    NULL, 23, 23, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'Step forward onto the ball, do not retreat'),
    (2, 'Quick full back (Reiziger)', 'Cover the space behind with pace')
) AS v(so, role, job);

-- 18. pp.23-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '3 Playing Out from the Back', 'Centre backs as the playmakers',
    'Van Gaal: the space for the number 10 is so tight that the real playmakers are the two central defenders (Blind, Rijkaard), who must be technically and tactically gifted to start attacks.',
    'Build-up from the back',
    'Start attacks from the free centre-backs where there is time on the ball.',
    NULL, 23, 24, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Blind, Rijkaard)', 'Organise and distribute, step into midfield'),
    (2, 'Number 10', 'Receive in tight space from the defenders')
) AS v(so, role, job);

-- 19. pp.23-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '3 Playing Out from the Back', 'Defender bursts forward, midfield covers',
    'Total Football defenders (Krol, Suurbier, Koeman) stepped into midfield or attack when a chance arose, with midfielders and attackers dropping to cover; Krol swept and hit long diagonals to the wingers.',
    'Space ahead of a defender',
    'Add an extra attacker from deep without leaving the back exposed.',
    NULL, 23, 25, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-playing defender (Krol / Koeman)', 'Carry or pass forward, shoot from range'),
    (2, 'Midfielder', 'Drop into the defender''s slot'),
    (3, 'Wingers', 'Receive long diagonals')
) AS v(so, role, job);

-- 20. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '3 Playing Out from the Back', 'Left centre-back diagonal into far channel',
    'Frank de Boer''s signature: a 60-yard diagonal from left-back/left centre-back to a centre-forward who drifted into the opposite (right) channel, timed by eye contact (Bergkamp v Argentina 1998, and at Ajax v PSV 1993).',
    'Forward drifts into the far channel and makes eye contact',
    'Bypass midfield and put the striker in behind the full-back side of the line.',
    NULL, 24, 24, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (F. de Boer)', 'Read the run, hit the long diagonal'),
    (2, 'Centre forward (Bergkamp)', 'Drift to opposite channel, control and finish')
) AS v(so, role, job);

-- 21. pp.25-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '3 Playing Out from the Back', 'Midfielder-defenders in a three-man line',
    'Cruyff''s Barcelona 3-4-3: Koeman as centre-back and Guardiola as holder effectively the defence; Cruyff argued only three passes threatened them and each was covered: keeper sweeps balls over the top, fast full-backs take crossfield balls, short space centrally guarded by positioning.',
    'Opponent tries to play past an attacking-minded team',
    'Defend with technicians by assigning each danger pass to a cover role.',
    NULL, 25, 25, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Busquets)', 'Intercept balls over the top'),
    (2, 'Fast full backs (Ferrer, Barjuan)', 'Deal with crossfield balls'),
    (3, 'Centre back (Koeman)', 'Hold small central zone, long passes out'),
    (4, 'Holding midfielder (Guardiola)', 'Defend a small area, cover for attacking teammate')
) AS v(so, role, job);

-- 22. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '4 Flexibility', 'Full backs smother wingers, then counter',
    'Lippi''s Juventus v Ajax 1996 final: Pessotto and Torricelli stuck tight to Ajax''s touchline wingers and refused to let them turn, intercepting and launching quick counters; when a fresh winger came on, the full-backs swapped sides to match up.',
    'Ball switched to an opposition winger',
    'Neutralise wide 1v1 threats and turn interceptions into counters.',
    '4-3-3', 28, 28, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (Pessotto, Torricelli)', 'Tight marking, deny the turn, intercept'),
    (2, 'Fresher full back', 'Switch flank to face the most dangerous winger')
) AS v(so, role, job);

-- 23. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '4 Flexibility', 'Long balls to overlapping left-back',
    'Capello''s Real Madrid 1996/97: the most common move was centre-back Hierro hitting long balls for overlapping left-back Roberto Carlos.',
    'Centre back in possession, left-back sprinting up',
    'Go direct and attack the flank behind the opposition winger.',
    NULL, 30, 30, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Hierro)', 'Launch long ball down the left'),
    (2, 'Overlapping left back (Roberto Carlos)', 'Sprint beyond and attack the space')
) AS v(so, role, job);

-- 24. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '4 Flexibility', 'Screen a flank with diamond midfielder',
    'Real Madrid v Sevilla 1997, 2-0 down and battered down the flanks: Capello pushed Raul up, put Ze Roberto on the left of a midfield diamond to screen Roberto Carlos and added a fresh right-back.',
    'Being overrun on the flanks',
    'Restore defensive solidity first, then come back.',
    NULL, 31, 31, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left of diamond (Ze Roberto)', 'Screen and protect the attacking left-back'),
    (2, 'Forward (Raul)', 'Push up front'),
    (3, 'Fresh right back (Sanchis)', 'Shore up the beaten side')
) AS v(so, role, job);

-- 25. pp.32-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '4 Flexibility', 'Juve 4-3-1-2 with back three in possession',
    'Lippi''s Juventus 1996/97: Zidane as the 10 behind two strikers, wide midfielders Di Livio and Jugovic tucking in to support holder Deschamps; width from the left-back while the right-back tucked inside to form a back three in possession (old catenaccio habit).',
    'Juventus settle in possession',
    'Central overload with width from one full-back and a secure three behind.',
    NULL, 32, 32, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 10 (Zidane)', 'Play behind the two strikers'),
    (2, 'Wide midfielders (Di Livio, Jugovic)', 'Tuck in beside the holder'),
    (3, 'Left back (Pessotto)', 'Provide the width'),
    (4, 'Right back (Porrini / Torricelli)', 'Tuck in to make a back three')
) AS v(so, role, job);

-- 26. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '4 Flexibility', 'Four centre-backs, front three press',
    'Juventus v Ajax semi 1997: Lippi used two centre-backs at full-back for a physical back four, and Zidane joined Boksic and Vieri pressing Ajax''s three ball-playing defenders, forcing long balls into Juve''s tall defenders; Juve then went direct to the two strikers.',
    'Ajax back three in possession',
    'Disrupt build-up, win aerial balls and go direct.',
    '3-4-3', 33, 33, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front three (Zidane, Boksic, Vieri)', 'Press the three defenders energetically'),
    (2, 'Back four of centre-backs (Ferrara, Iuliano, Montero)', 'Win the long balls'),
    (3, 'Strikers', 'Receive direct balls to batter the defence')
) AS v(so, role, job);

-- 27. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '4 Flexibility', 'Chasing game: add a third forward',
    'Juventus 2-0 down (1997 final v Dortmund, 1998 v Parma) switched 4-3-1-2 to 4-3-3 or 3-4-3, sending on another forward for a wide midfielder, which forced the opponent to retreat.',
    'Trailing at half-time',
    'Push the opponent back and add attacking threat.',
    NULL, 33, 33, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Extra forward (Del Piero / Zalayeta)', 'Join as third attacker'),
    (2, 'Number 10', 'Move up or come off for the extra striker')
) AS v(so, role, job);

-- 28. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '4 Flexibility', 'Back seven block, free front three',
    'Lippi''s Juventus 1997/98: seven functional players form the defensive block while the front three (Zidane, Del Piero, Inzaghi) are freed from defensive duties to create; switching 4-3-1-2 to 3-4-1-2 against two strikers, or Zidane and Del Piero drifting inside in a 3-4-3.',
    'Possession phase',
    'Balance security and creativity by splitting the team in two.',
    NULL, 33, 33, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back seven', 'Hold shape, defend and recycle'),
    (2, 'Front three', 'Free to roam and create')
) AS v(so, role, job);

-- 29. pp.33-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_attack', '4 Flexibility', 'Long balls outside a three-man defence',
    'Juventus v Inter 1998: Juve aimed long balls into the space outside Inter''s three-man defence for Del Piero and Inzaghi; when wide defender West stepped up and lost the ball, they broke into the space behind and the sweeper was dragged across.',
    'Wide centre-back steps out and possession is won',
    'Exploit the channel beside a back three and pull the sweeper out of position.',
    NULL, 33, 34, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strikers (Del Piero, Inzaghi)', 'Run into the channel outside the back three'),
    (2, 'Midfielder (Davids)', 'Slip the forward in quickly')
) AS v(so, role, job);

-- 30. pp.35-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '5 The Third Attacker', 'Compact pressing 4-4-2, strikers stretch',
    'Sacchi-style 4-4-2 as used by Ancelotti''s Parma: compact block, aggressive pressing, two strikers told to stretch play and run in behind; no room for a number 10, a creative player had to work as an extra marker.',
    'Opponent in possession',
    'Keep a compact pressing shape and threaten depth on regains.',
    NULL, 35, 36, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two strikers', 'Stretch the line and run behind'),
    (2, 'Wide midfielders (Zola on the left)', 'Double up as markers'),
    (3, 'Midfield four', 'Stay compact and press')
) AS v(so, role, job);

-- 31. pp.36-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '5 The Third Attacker', 'Zeman three goalscorers, overlapping full-backs',
    'Zeman''s 4-3-3 (Foggia, Lazio, Roma): instead of touchline wingers, three scoring forwards play narrow, dragging defenders inside so full-backs rampage forward; at Roma one wide forward (Totti) drifted inside between the lines, making it more 4-3-1-2. Short passing, zonal defending, very high line.',
    'Settled possession',
    'Overload the box with finishers and free the flanks for full-backs.',
    NULL, 36, 37, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Narrow front three (Balbo, Delvecchio, Paulo Sergio)', 'Attack the box, pull defenders inside'),
    (2, 'Inside forward (Totti)', 'Drift in from the left between the lines'),
    (3, 'Full backs', 'Overlap into the space left wide'),
    (4, 'Back line', 'Hold a high line (exposed to quick strikers)')
) AS v(so, role, job);

-- 32. pp.37-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '5 The Third Attacker', 'Zaccheroni 3-4-3: three always stay up',
    'Zaccheroni''s Udinese and Milan: three defenders, a midfield four that can support attack and defence at once, and three forwards (target man flanked by runners) who never have to retreat; he disliked a midfield three forcing a 4-5-1 out of possession.',
    'Whole match',
    'Keep a permanent three-man attacking threat while four midfielders balance the side.',
    NULL, 37, 38, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target man (Bierhoff)', 'Lead the line, win headers and flick on'),
    (2, 'Channel runners (Poggi, Amoroso, Weah)', 'Run into space beside the target man'),
    (3, 'Midfield four', 'Support both attack and defence'),
    (4, 'Back three', 'Defend without extra help from the front three')
) AS v(so, role, job);

-- 33. pp.38-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '5 The Third Attacker', '3-4-1-2 trequartista with complementary pair',
    'Late-1990s Italian revival of the 10: Milan put Boban behind Bierhoff and Weah (also Inter with Seedorf/Baggio, Roma with Totti, Parma with Ortega); the 10 creates, the quick forward runs the channel, the target man attacks crosses in the air.',
    'Ball reaches the number 10 between lines',
    'Give the creator two different outlets so he can choose depth or a cross.',
    NULL, 38, 40, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 10 (Boban / Seedorf / Baggio)', 'Receive between lines, slip or cross'),
    (2, 'Quick forward (Weah)', 'Run into the channel'),
    (3, 'Target man (Bierhoff)', 'Attack the box and the aerial ball'),
    (4, 'Wing backs', 'Provide the width')
) AS v(so, role, job);

-- 34. pp.39-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '5 The Third Attacker', 'Trident: 10 starts, 2nd striker channel',
    'Trapattoni''s Fiorentina 1999/2000: Rui Costa as the 10 initiates the break, Chiesa runs into the channel (often the left) and crosses to Batistuta in the box.',
    'Number 10 gets the ball facing forward',
    'A repeatable three-man route from midfield to finish.',
    NULL, 39, 39, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 10 (Rui Costa)', 'Dribble and slip the ball into the channel'),
    (2, 'Second striker (Chiesa)', 'Run the channel and cross near post'),
    (3, 'Number 9 (Batistuta)', 'Finish in the box')
) AS v(so, role, job);

-- 35. pp.39-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '5 The Third Attacker', 'Drop and whip it round the corner',
    'Capello''s Roma 3-4-1-2: Totti retreats slightly to receive from midfield and plays a first-time ball round the corner for a runner down the right (striker breaking behind or wing-back sprinting from deep).',
    'Midfielder passes into the 10 who has dropped',
    'Release a runner behind the defence in one touch.',
    NULL, 39, 39, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 10 (Totti)', 'Drop a few yards, first-time ball round the corner'),
    (2, 'Striker (Montella)', 'Break in behind down the right'),
    (3, 'Right wing back (Cafu)', 'Sprint from deep into the space')
) AS v(so, role, job);

-- 36. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '5 The Third Attacker', '3-4-1-2 built round free number 10',
    'Ancelotti''s Juventus 1999/2000 dropped his preferred 4-4-2 and went 3-4-1-2 so Zidane played between the lines behind two strikers rather than wide left.',
    'Star creator uncomfortable in a wide midfield slot',
    'Put the playmaker in the pocket between opposition midfield and defence where he can receive facing goal.',
    NULL, 41, 41, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 10 (Zidane)', 'Floats between the lines behind the front two, receives and creates'),
    (2, 'Front two (Del Piero, Inzaghi)', 'Stay high to pin centre backs and offer runs for the 10'),
    (3, 'Back three', 'Give width-free cover so wing-backs and 10 can push on')
) AS v(so, role, job);

-- 37. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '5 The Third Attacker', '4-5-1 lone striker frees two creators',
    'Eriksson''s Lazio 1999/2000 switched from 4-4-2 to 4-5-1 with Salas alone up front and an extra midfielder, giving Veron and Nedved licence to roam and arrive.',
    'Need more control and freedom for attacking midfielders',
    'Extra body in midfield lets two creative midfielders break forward and shoot from range.',
    NULL, 41, 41, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lone striker (Salas)', 'Occupies centre backs alone, holds play'),
    (2, 'Creative midfielders (Veron, Nedved)', 'Freedom to drift and arrive late, long shots and assists'),
    (3, 'Extra central midfielder', 'Holds balance so the two creators can go')
) AS v(so, role, job);

-- 38. pp.43-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '6 Catenaccio', 'Hybrid: zonal midfield, man-marking back',
    'Trapattoni''s Juventus (1977-86) played a 3-5-2 / 4-4-2 hybrid: midfielders defended zones while the back line man-marked with a libero behind.',
    'Opposition attack enters the final third',
    'Combine compact midfield zones with tight control of strikers.',
    NULL, 43, 43, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'Hold zones and screen'),
    (2, 'Stoppers', 'Man-mark forwards with strength and aggression'),
    (3, 'Libero', 'Reads play, anticipates, sweeps behind')
) AS v(so, role, job);

-- 39. pp.43-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '6 Catenaccio', 'Sacchi flat four, high offside line',
    'Sacchi''s Milan and Italy replaced sweeper and stoppers with a flat zonal back four holding an aggressive offside line, squeezing play into the opposition half with pressing and 4-4-2.',
    'Opposition plays backwards or ball is under pressure',
    'Compress the pitch so the team dominates territory and plays on the front foot even away from home.',
    NULL, 43, 45, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Defend zones, step up together to catch forwards offside'),
    (2, 'Midfield four', 'Press forward and keep the block short behind the front two'),
    (3, 'Front two', 'Start the press high')
) AS v(so, role, job);

-- 40. pp.43-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '6 Catenaccio', 'Catenaccio: libero behind man-marking stoppers',
    'Classic Italian door-bolt: a spare sweeper sits behind stopper centre backs who each man-mark a forward; the extra defender costs a midfielder (Herrera''s Inter, Rocco''s Milan, Simoni''s Inter 1998).',
    'Opposition forwards in the final third',
    'Always have a free man behind the markers to clean up when one is beaten.',
    NULL, 43, 46, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Libero / sweeper', 'Stays spare behind the line, reads danger, covers beaten markers and brings ball out'),
    (2, 'Stoppers', 'Tight man-marking of a named forward, aggressive tackling and aerial duels'),
    (3, 'Attacking full back / wing-back', 'Freed to push on because the libero covers')
) AS v(so, role, job);

-- 41. pp.45-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '6 Catenaccio', 'Ball-playing centre back as playmaker',
    'Zonal defending meant centre backs no longer needed to win individual duels, so Eriksson put creative players there (Mihajlovic at Sampdoria/Lazio) to start attacks and take free kicks from the back four.',
    'Team has the ball in its own third',
    'Give the deep build-up a passer, like a libero, while still defending as a flat four.',
    NULL, 45, 45, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left centre back (Mihajlovic)', 'Distributes long and diagonal passes, playmaking from the back line'),
    (2, 'Partner centre back (Nesta)', 'Calm reading and covering, leaves playmaking to partner')
) AS v(so, role, job);

-- 42. pp.46-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '6 Catenaccio', 'Man-markers follow forwards across flanks',
    'Simoni''s Inter v Lazio, 1998 UEFA Cup Final: each defender stuck to his assigned opponent even when he drifted to the other flank or inside, with Fresi as libero behind.',
    'Assigned forward moves out of the defender''s zone',
    'Deny named threats any free touch; the sweeper handles anyone who escapes.',
    NULL, 46, 46, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (West, Colonnese)', 'Track their striker everywhere, even to the opposite wing'),
    (2, 'Right back (Winter)', 'Follows the drifting attacking midfielder inside'),
    (3, 'Libero (Fresi)', 'Steps in calmly when an attacker escapes his marker')
) AS v(so, role, job);

-- 43. pp.46-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '6 Catenaccio', 'Back three plus returning wide midfielder',
    'Cesare Maldini''s Italy 1998 (called 1-3-4-2) and Zoff''s Italy Euro 2000 (3-5-1-1): a spare defender between two markers, plus a ''returning'' right-sided midfielder dropping in as wing-back so the line becomes five.',
    'Losing possession / opposition attacking the flank',
    'Always have a spare man centrally and cover width, at the cost of attacking numbers.',
    NULL, 46, 48, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Spare central defender (Costacurta, Nesta)', 'Sweeps between the two markers'),
    (2, 'Markers (Cannavaro, Iuliano/Nesta)', 'Tight on strikers'),
    (3, 'Returning right midfielder (Di Livio, Zambrotta)', 'Drops into the back line as wing-back, five across'),
    (4, 'Left back (Maldini)', 'Holds the left side of the five')
) AS v(so, role, job);

-- 44. pp.47-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '6 Catenaccio', 'Back three stoppers carry ball forward',
    'Parma''s back three around 1999/2000: Sensini sweeping behind Cannavaro and Thuram, both aggressive defenders who also stepped out and brought the ball forward when needed.',
    'Space in front of a back-three stopper',
    'Add a carrier from the back without losing the spare man.',
    NULL, 47, 47, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Sweeper (Sensini)', 'Stays behind as the spare man'),
    (2, 'Right stopper (Thuram, ex-winger)', 'Steps into midfield with the ball'),
    (3, 'Left stopper (Cannavaro)', 'Wins the ball cleanly then carries or passes forward')
) AS v(so, role, job);

-- 45. pp.51-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '7 Speed', 'Two quick strikers run in behind',
    'France at Euro 2000 swapped a hold-up centre forward for two sprinters (Henry, Anelka) who attacked balls played behind the back line, especially into the inside channels.',
    'Opposition defence high or slow; midfielder gets ball facing forward',
    'Beat the back line with pure pace from through-balls rather than combination play.',
    NULL, 51, 53, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker 1 (Henry)', 'Drifts to inside-left channel, sprints onto passes behind'),
    (2, 'Striker 2 (Anelka)', 'Runs into the inside-right channel, takes on the keeper or squares'),
    (3, 'Playmaker (Zidane, Djorkaeff)', 'Plays the through-ball early behind the defence'),
    (4, 'Centre back (Blanc)', 'Long diagonal straight to a striker''s run')
) AS v(so, role, job);

-- 46. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '7 Speed', 'Attack wide channels against aerial centre backs',
    'Before France v Portugal (Euro 2000) Lemerre saw a slow but aerially strong centre-back pair, so his strikers were told to play down the sides; when Portugal sat deep the through-balls dried up and a pull-back from the channel did the damage.',
    'Opposition centre backs dominant in the air but slow',
    'Drag centre backs wide and use the pace mismatch rather than crosses into their strength.',
    NULL, 52, 52, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strikers (Henry, Anelka)', 'Run into wide channels, cut balls back'),
    (2, 'Midfield runners', 'Arrive for the pull-back')
) AS v(so, role, job);

-- 47. pp.53-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_attack', '7 Speed', 'Pack midfield, release lone fast striker',
    'Senegal v France, World Cup 2002: five in midfield crowded out France''s creators, then on winning the ball they played straight in behind for Diouf against a slow ageing back four.',
    'Ball won in midfield; opposition centre backs lack recovery pace',
    'Smother the opponent''s creativity and score on the break with one sprinter supported by midfield runners.',
    NULL, 53, 54, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lone striker (Diouf)', 'Sprints into left or right channel behind the centre backs'),
    (2, 'Five midfielders', 'Crowd the centre, win the ball, play the early pass behind'),
    (3, 'Late midfield runner (Bouba Diop)', 'Supports the break and finishes the cut-back')
) AS v(so, role, job);

-- 48. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '8 The Number 10', 'Two wide 10s drift inside',
    'France v Spain, Euro 2000: a 4-2-3-1 with Henry alone and Zidane flanked by two creative players (Djorkaeff, Dugarry) who swapped sides and drifted inside to overload the space between the lines.',
    'In possession in midfield',
    'Three playmakers between the lines create problems the opponent cannot mark.',
    NULL, 57, 57, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central 10 (Zidane)', 'Receives centrally behind the midfield'),
    (2, 'Wide 10s (Djorkaeff, Dugarry)', 'Start wide, rotate, move inside into pockets'),
    (3, 'Lone striker (Henry)', 'Stretches the line and runs off the 10s')
) AS v(so, role, job);

-- 49. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '8 The Number 10', 'Christmas tree: two 10s behind striker',
    'Jacquet''s France at Euro 96 and World Cup 98 played a Christmas tree (4-3-2-1) with Zidane and Djorkaeff floating behind a lone central striker; Zidane often dropped deeper while Djorkaeff pushed on.',
    'Lack of a top striker; two creators to fit in',
    'Fit two playmakers centrally with one dropping and one arriving in the box.',
    NULL, 57, 57, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deeper 10 (Zidane)', 'Drops towards midfield to collect and dictate'),
    (2, 'Advanced 10 (Djorkaeff)', 'Pushes on, times runs into the box, scores'),
    (3, 'Three central midfielders', 'Hold the base behind them')
) AS v(so, role, job);

-- 50. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '8 The Number 10', '4-3-1-2 free-roaming 10 with sprinters',
    'France v Portugal, Euro 2000 semi: 4-3-1-2 with two speedy forwards; Zidane was free to drift laterally into pockets left, right and centre, holding the ball to draw markers then releasing overlaps or balls behind.',
    '10 receives in a pocket',
    'Freedom for the 10 to find space plus fast strikers ahead gives both short combinations and balls in behind.',
    NULL, 58, 58, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 10 (Zidane)', 'Roams across the pitch, holds the ball to suck in a marker, then releases'),
    (2, 'Overlapping full backs (Lizarazu, Thuram)', 'Overlap into the space the 10 has drawn a marker from'),
    (3, 'Two fast forwards (Henry, Anelka)', 'Give one-twos and run in behind'),
    (4, 'Midfield three', 'Play diagonals into the 10 and hold the base')
) AS v(so, role, job);

-- 51. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '8 The Number 10', 'Wide midfielders tuck in, diamond for 10',
    'Lippi''s Juventus moved from 4-4-2 to 4-3-1-2: the wide players came inside to defend centrally and Deschamps became the holder, giving Zidane freedom to push forward from the left of a diamond.',
    'Creative midfielder needs freedom',
    'Protect a playmaker with a narrow, hard-working midfield and a dedicated holder.',
    NULL, 59, 59, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Deschamps)', 'Sits deepest and covers'),
    (2, 'Shuttling midfielders', 'Tuck inside, defend the centre'),
    (3, 'Number 10 (Zidane)', 'Pushes forward and drifts in from the left')
) AS v(so, role, job);

-- 52. pp.60-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_attack', '8 The Number 10', 'Move the ball before two banks settle',
    'Henry wanted the ball as early as possible after a regain, before the two opposition banks of four closed up; he preferred playing without a playmaker who slowed the attack.',
    'Ball won with the opposition out of shape',
    'Attack the transition window with fast forward passes instead of building slowly.',
    '4-4-2', 60, 60, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Henry)', 'Starts runs from deep and wants an early ball'),
    (2, 'Midfielders', 'Play forward first time on the regain')
) AS v(so, role, job);

-- 53. pp.63-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_attack', '9 The Water Carrier', 'Water carrier: win it, give it to 10',
    'French holding midfielders (Deschamps, Makelele) had a purely functional role: break up play, then pass straight to the star playmaker rather than build themselves.',
    'Holder wins or receives the ball',
    'Quick, simple transfer of possession to the creator keeps the team balanced and dangerous.',
    NULL, 63, 64, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Deschamps)', 'Wins the ball, keeps it simple, finds the 10 immediately'),
    (2, 'Playmaker (Zidane)', 'Receives from the holder and creates')
) AS v(so, role, job);

-- 54. pp.65-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '9 The Water Carrier', 'Three defensive midfielders behind playmaker',
    'France''s 1998 World Cup final: Zidane in front of three water carriers - Deschamps deepest, Petit left, Karembeu right supplying running.',
    'Team defending in midfield',
    'Solid screen in front of the back four lets one creator stay free.',
    NULL, 65, 65, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deepest midfielder (Deschamps)', 'Anchors and screens the centre backs'),
    (2, 'Left midfielder (Petit)', 'Defensive operator who also passes with left foot'),
    (3, 'Right midfielder (Karembeu)', 'Energy, covers ground and the right side'),
    (4, 'Number 10 (Zidane)', 'Spared defensive work')
) AS v(so, role, job);

-- 55. pp.65-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '9 The Water Carrier', 'Holder and all-rounder double pivot',
    'Arsenal under Wenger used two defensive midfielders to protect the defence, with Petit or Grimandi as the pure holder freeing Vieira to roam box to box, leaving creativity to Bergkamp.',
    'Partnering an all-rounder in a two',
    'One midfielder always stays while the other drives forward.',
    NULL, 65, 66, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pure holder (Petit, Grimandi)', 'Stays in front of the defence, does the unglamorous jobs'),
    (2, 'Box-to-box (Vieira)', 'Free to go forward and support attacks'),
    (3, 'Second striker (Bergkamp)', 'Main creator')
) AS v(so, role, job);

-- 56. pp.66-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '9 The Water Carrier', 'Makelele role: shield behind star attackers',
    'At Real Madrid and Chelsea''s 4-3-3 Makelele sat at the base of midfield as first defender and first attacker, covering for everyone and protecting converted centre backs while four stars attacked.',
    'Attackers and full back committed forward',
    'One disciplined screen gives the team balance and lets the attackers go without fear.',
    NULL, 66, 67, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Base midfielder (Makelele)', 'Stays in front of the defence, wins the ball, sets tempo with short passes'),
    (2, 'Centre backs (Hierro, Helguera)', 'Protected from runners through the middle'),
    (3, 'Attacking left back (Roberto Carlos)', 'Overlaps knowing the holder covers'),
    (4, 'Front stars (Zidane, Figo, Raul, Ronaldo)', 'Attack freely')
) AS v(so, role, job);

-- 57. pp.73-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '10 Structure', 'Porto high press with high line',
    'Mourinho''s Porto 2003/04 pressed aggressively high with a very advanced line led by Costa and Carvalho, stepping up together to catch strikers offside and keeping target men away from the box.',
    'Opposition building from the back or playing forward',
    'Win the ball high and squeeze space; deny the striker the box.',
    NULL, 73, 73, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Costa, Carvalho)', 'Step up as one for offside, intercept through-balls'),
    (2, 'Full backs (Ferreira, Valente)', 'Hold the line with the centre backs'),
    (3, 'Goalkeeper (Baia)', 'Sweeps outside the box behind the high line')
) AS v(so, role, job);

-- 58. pp.73-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '10 Structure', 'Diamond press shows full backs touchline',
    'Porto''s 4-3-1-2 in the 2004 final left Monaco''s full backs time in theory, so the two forwards each covered a flank and pushed them to the touchline while the outside diamond midfielders pushed out wide; the holder dropped in as an extra centre back when needed.',
    'Ball goes to an opposition full back',
    'Cover the diamond''s natural weakness out wide and trap the ball on the touchline.',
    NULL, 73, 73, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards (Carlos Alberto, Derlei)', 'Each takes a flank, presses full back towards touchline'),
    (2, 'Wide diamond midfielders (Mendes, Maniche)', 'Shuffle out to crowd the full back'),
    (3, 'Holder (Costinha)', 'Protects centre, drops as extra centre back')
) AS v(so, role, job);

-- 59. pp.73-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_attack', '10 Structure', 'Counter via 10 and wide diamond runner',
    'When Porto led the 2004 final Mourinho brought on a fast left-diamond midfielder (Alenichev) and pushed Maniche up beside Deco; Porto then broke with Deco carrying through midfield and the wide runner breaking beyond.',
    'Leading and opponent pushing forward',
    'Exploit the space behind a chasing opponent with a carrier plus a fast runner.',
    NULL, 73, 74, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 10 (Deco)', 'Carries through midfield, gives and gets on the edge of the box'),
    (2, 'Left diamond midfielder (Alenichev)', 'Breaks forward on the counter, runs onto through balls'),
    (3, 'Second midfielder (Maniche)', 'Pushes higher to support')
) AS v(so, role, job);

-- 60. pp.74-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '10 Structure', 'Resting with the ball',
    'Mourinho''s Porto alternated intense pressing with long spells of calm possession to recover energy, and dominated possession in most European games.',
    'After a high-intensity pressing phase or when leading',
    'Keep the ball to rest so the team can sustain its pressing for 90 minutes.',
    NULL, 74, 74, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield (Costinha, Maniche, Mendes)', 'Keep the ball safely, circulate'),
    (2, 'Number 10 (Deco)', 'Receives under pressure, pauses, keeps possession')
) AS v(so, role, job);

-- 61. pp.74-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_defend', '10 Structure', 'Transitions: sprint back, explode forward',
    'Mourinho''s Chelsea 4-3-3 drilled both transitions: losing the ball meant immediate recovery sprints back into shape; winning it meant attacking within four or five seconds before the opponent reorganised.',
    'Change of possession',
    'Beat an unorganised opponent fast and never be caught out of shape.',
    NULL, 74, 74, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (Duff, Robben)', 'On loss sprint back; on regain explode forward at once'),
    (2, 'Striker (Drogba)', 'Leads the quick attack on the regain'),
    (3, 'Holding midfielder (Makelele)', 'Stays as the base when the ball is lost')
) AS v(so, role, job);

-- 62. pp.74-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '10 Structure', 'Switching shape on a hand signal',
    'Porto (and later Chelsea and Inter) were drilled in two systems, 4-3-3 and 4-3-1-2, and changed between them in-game on the coach''s hand gestures, keeping a clear structure in and out of possession.',
    'Coach signal / need for more midfield control',
    'Confuse the opponent by changing shape without substitutions.',
    NULL, 74, 74, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forwards / wide midfielders', 'Move between front-three and diamond positions'),
    (2, 'Number 10 (Deco)', 'Switches between left-centre midfield and the top of the diamond')
) AS v(so, role, job);

-- 63. pp.75-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '10 Structure', 'Opposition-specific marking plan',
    'Mourinho planned around the opponent''s stars: against Real Madrid''s galacticos he worked out he needed a marker each on Morientes, Figo, Zidane and the space Roberto Carlos used, plus a free midfielder near the striker.',
    'Facing a team with several specific threats',
    'Neutralise each danger man in his zone rather than play only your own way.',
    NULL, 75, 75, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Marks the target striker'),
    (2, 'Free midfielder', 'Sits close behind the striker''s marker'),
    (3, 'Assigned markers', 'Each tracks a creator (Figo, Zidane) in his zone'),
    (4, 'Right-sided player', 'Occupies the space the attacking left back pushes into')
) AS v(so, role, job);

-- 64. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '11 The First Port of Call', 'All-round 10 who presses',
    'Deco at Porto played as a 10 in the 4-3-1-2 or left-centre in a 4-3-3: composed receiving in tight spaces head up, pausing before the killer pass, but also pressing and tracking back hard.',
    'Receiving in a tight space / possession lost near him',
    'A creator who also defends lets the team press as a unit without carrying a passenger.',
    NULL, 78, 78, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 10 (Deco)', 'Receives in tight space, pauses, plays the incisive pass; presses and chases back'),
    (2, 'Deep pivot (Costinha, Maniche)', 'Holds behind him')
) AS v(so, role, job);

-- 65. pp.79-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '11 The First Port of Call', 'Quick passing and moving ball wide',
    'Portugal at Euro 2004 were too slow in possession with Rui Costa against Greece; with Deco in the 10 role they made quick passes, moved the ball out wide sooner and attacked at pace.',
    'Possession becoming ponderous against a deep side',
    'Speed up circulation and use the wings to break down a set defence.',
    NULL, 79, 79, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 10 (Deco)', 'Plays quickly, accelerates attacks'),
    (2, 'Wingers (Figo, Ronaldo)', 'Receive early out wide, cross or cut back'),
    (3, 'Midfielder (Maniche)', 'Arrives on the edge of the box for cut-backs')
) AS v(so, role, job);

-- 66. pp.79-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '11 The First Port of Call', 'Winger moves central, striker spins',
    'Portugal v Spain, Euro 2004: Scolari swapped Deco wide and Figo central; Figo received between the lines and flicked to the striker, who held the ball, faked the return pass to Figo''s run and turned to shoot.',
    'Central creator receives between the lines',
    'Use the striker''s hold-up and the expected give-and-go as a decoy to create a shot.',
    NULL, 79, 79, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central creator (Figo)', 'Receives between lines, plays to striker, runs for the return'),
    (2, 'Striker (Nuno Gomes)', 'Holds up, waits, spins away from the defender expecting the return'),
    (3, 'Wide playmaker (Deco)', 'Shifted to the flank to open the centre')
) AS v(so, role, job);

-- 67. pp.79-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '11 The First Port of Call', 'Chasing the game: all-out 4-2-4',
    'Portugal 1-0 down to England, Euro 2004: Scolari replaced the holder with a winger, a winger with a second striker and the right back with a playmaker, ending in a 4-2-4 with six attackers and Deco at right back.',
    'Behind late in a knockout game',
    'Flood the box with attackers and crossers to force an equaliser.',
    NULL, 79, 80, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two strikers (Postiga, Nuno Gomes)', 'Attack crosses in the box'),
    (2, 'Wingers (Simao, Ronaldo)', 'Deliver crosses from wide'),
    (3, 'Central pair (Rui Costa, Maniche)', 'Drive forward through the middle and shoot'),
    (4, 'Right back (Deco)', 'Playmaker in a defensive slot, presses and covers')
) AS v(so, role, job);

-- 68. pp.82-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '12 Wingers', 'Striker drops deep to free runners',
    'Queiroz''s Portugal (U20 1991 onward) used a forward who came short into build-up instead of staying as a pure number 9, pulling centre backs out so attacking midfielders and wingers could break past him.',
    'Ball in midfield build-up, centre backs marking the striker',
    'Drag a defender out of the back line and open space behind for midfield runners.',
    NULL, 82, 82, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-forward (Joao Pinto, later Nuno Gomes)', 'Drop into build-up, drift wide, disrupt defenders rather than poach'),
    (2, 'Attacking midfielders (Rui Costa)', 'Break forward into the space the striker vacates'),
    (3, 'Wingers (Figo)', 'Attack inside channels when the centre back follows')
) AS v(so, role, job);

-- 69. pp.83-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '12 Wingers', 'Centre recycles, wingers get free touches',
    'Sporting''s academy 4-3-3: central players were limited in touches and told to move the ball wide quickly, while wide players had licence to dribble and take on full backs one-v-one.',
    'Central midfielder receives',
    'Get the ball to a winger isolated against a full back as fast as possible.',
    NULL, 83, 84, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Few touches, switch the ball wide quickly'),
    (2, 'Wingers (Figo, Simao, Quaresma, Ronaldo, Nani)', 'Unlimited touches, beat the full back either side'),
    (3, 'Overlapping full back', 'Arrive outside for back-heel or layoff from the winger')
) AS v(so, role, job);

-- 70. pp.84-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '12 Wingers', 'Inverted vs ''inverted-inverted'' winger',
    'Portuguese wingers on the opposite flank to their strong foot (Ronaldo left, Nani right) cut inside to shoot, while Quaresma, a right-footer on the right, used the outside of his foot (trivela) to cross from the left side or curl shots from the right edge of the box.',
    'Winger isolated 1v1 with the full back',
    'Choose cut-in shot or outside-of-foot cross depending on the winger''s foot and flank.',
    NULL, 84, 87, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted winger (Ronaldo/Nani)', 'Cut inside onto strong foot, shoot or slip pass'),
    (2, 'Same-foot winger (Quaresma)', 'Go down the line, cross or shoot with outside of the boot'),
    (3, 'Centre-forward (Jardel)', 'Attack crosses in the box')
) AS v(so, role, job);

-- 71. pp.86-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_attack', '12 Wingers', 'Strikerless fluid front three counter',
    'Man Utd 2007/08 without a fixed number 9: Ronaldo, Rooney and Tevez interchanged and broke forward at speed, with Ronaldo sprinting in behind on the break and attacking crosses from deep runs.',
    'Ball won, opponent''s back line open',
    'Multiple fast attackers burst forward so no defender has a fixed man to mark.',
    NULL, 86, 86, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front three (Ronaldo, Rooney, Tevez)', 'Rotate freely, run beyond on the break'),
    (2, 'Ronaldo', 'Start runs from outside the box, attack the cross with a header'),
    (3, 'Midfield passer (Scholes)', 'Clip early crosses or passes into the runners')
) AS v(so, role, job);

-- 72. pp.86-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '12 Wingers', 'Free forward targets weakest defender',
    'Ferguson let Ronaldo pick his zone per opponent: down the right if the left back was weak, through the middle if centre backs were slow, or on the side of a makeshift full back poor in the air (Essien, 2008 CL final).',
    'Pre-match identification of an opponent weak link',
    'Create a repeated mismatch against the least capable defender.',
    NULL, 86, 86, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free forward (Ronaldo)', 'Position against the weakest defender, attack him in the air or 1v1'),
    (2, 'Wide supply (crosser)', 'Deliver to the mismatch zone')
) AS v(so, role, job);

-- 73. pp.87-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '12 Wingers', 'Diamond with two inside-cutting forwards',
    'Portugal Euro 2016 under Santos dropped the pure striker for a fluid 4-4-2 diamond: Ronaldo cut in from the right and Nani from the left as a front two, an extra central midfielder behind.',
    'Settled possession',
    'Add a midfielder and use two mobile forwards instead of a static number 9.',
    NULL, 87, 88, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two (Ronaldo, Nani)', 'Start wide, cut inside, combine and cross low for each other'),
    (2, 'Diamond midfield', 'Extra central body for control'),
    (3, 'Late sub forward (Eder)', 'Hold with back to goal, turn and shoot as plan C')
) AS v(so, role, job);

-- 74. pp.91-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '13 Tiki-taka', 'Playmaker positions to drag then pass',
    'Xavi as the model passer: he positions himself to pull an opponent out of place, then plays the simple pass past him; receive, pass, repeat.',
    'Opponent steps towards the receiver',
    'Move opponents with positioning so the next simple pass breaks a line.',
    NULL, 91, 92, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right-centre midfielder (Xavi)', 'Draw the presser, release first or second time'),
    (2, 'Deep pivot (Busquets)', 'Protect the defence, recycle'),
    (3, 'Left-centre midfielder (Iniesta)', 'Use change of pace and croqueta to escape and drive into tight spaces')
) AS v(so, role, job);

-- 75. pp.93-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '13 Tiki-taka', 'Three playmakers, no width (Euro 2008)',
    'Aragones'' Spain played a 4-1-3-1-1: Senna deep, Iniesta/Xavi/Silva together behind Villa dropping off Torres, sacrificing width to crowd playmakers in the centre.',
    'Settled possession',
    'Dominate midfield through numbers of technical players.',
    NULL, 93, 93, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Senna)', 'Screen, occasionally drive forward and seek return pass'),
    (2, 'Three playmakers (Iniesta, Xavi, Silva)', 'Combine centrally, arrive in the box in numbers'),
    (3, 'Second striker (Villa)', 'Drop off the main striker')
) AS v(so, role, job);

-- 76. pp.93-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_attack', '13 Tiki-taka', 'Direct ball over empty midfield',
    'Even possession Spain struck directly: Capdevila intercepted inside his own half and hit a long ball over an empty midfield for Torres to outrun the last defender, or drove forward himself to start a counter.',
    'Interception with big space between opponent lines',
    'Bypass midfield entirely and isolate the striker against the last defender.',
    NULL, 93, 93, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Capdevila)', 'Intercept, hit the early long pass or dribble forward'),
    (2, 'Striker (Torres)', 'Sprint past last defender, square for the second striker'),
    (3, 'Second striker (Villa)', 'Follow in for the tap-in')
) AS v(so, role, job);

-- 77. pp.94-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '13 Tiki-taka', 'Overload the centre, extra midfielder',
    'Guardiola''s Barcelona answered ''three in midfield, they put four'' by always adding a body centrally: Iniesta from wide-left drifting inside, then Messi as false 9 dropping in as a number 10 to form a diamond.',
    'Opponent matches midfield numbers',
    'Keep a numerical edge in the zone of the ball.',
    NULL, 94, 94, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide-left forward (Iniesta)', 'Start wide, drift inside into midfield'),
    (2, 'False 9 (Messi)', 'Drop ahead of the three to make a diamond'),
    (3, 'Midfield three (Busquets, Xavi, Iniesta)', 'Circulate and outnumber')
) AS v(so, role, job);

-- 78. pp.94-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '13 Tiki-taka', 'Midfielders as centre backs; 3-3-1-3',
    'Guardiola filled the spine with midfielders: Busquets, Mascherano or Toure as centre backs, Ajax-style 3-3-1-3, even a 3-7-0 vs Santos with Alves as a right winger and Fabregas/Thiago drifting inside around a false 9.',
    'Need for control, opponent with few strikers',
    'Maximise passers on the pitch so the ball is never surrendered.',
    NULL, 94, 95, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Busquets, Mascherano)', 'Defend and start play like midfielders'),
    (2, 'Right back (Alves)', 'Push up as the right winger'),
    (3, 'Inside forwards (Fabregas, Thiago)', 'Drift in from the flanks'),
    (4, 'False 9 (Messi)', 'Drop, link, finish')
) AS v(so, role, job);

-- 79. pp.94-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '13 Tiki-taka', 'Kill the game with keep-ball',
    'When opponents threw on extra attackers (Ferguson''s 4-2-4 in the 2009 final), Barcelona used the freed midfield to keep the ball rather than chase a second goal; Spain 2010 likewise retained in deep positions once ahead.',
    'Leading, opponent commits more forwards',
    'Starve the opponent of the ball until the clock runs out.',
    '4-2-4', 94, 96, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield trio', 'Retain possession, no risky forward passes'),
    (2, 'Centre backs and pivot', 'Circulate deep, hold positions')
) AS v(so, role, job);

-- 80. pp.95-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '13 Tiki-taka', 'Double pivot, off-centre diamond (Spain 2010)',
    'Del Bosque''s 4-2-3-1: Busquets and Alonso as a deep duo, Xavi as a number 10 who dropped deep, Iniesta from wide drifting inside to form an off-centre diamond; too many bodies centrally left the opposition defence narrow.',
    'Settled possession',
    'Hold the ball for long spells; needs one true wide runner to stretch play.',
    NULL, 95, 96, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Double pivot (Busquets, Alonso)', 'Sit deep, circulate'),
    (2, 'Number 10 (Xavi)', 'Drop to dictate'),
    (3, 'Wide-left (Iniesta)', 'Drift inside'),
    (4, 'Wide runner (Pedro/Navas/Villa)', 'Hug the touchline or run in behind from wide for width')
) AS v(so, role, job);

-- 81. pp.96-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '13 Tiki-taka', 'Possession as defence',
    'Del Bosque''s Spain used possession to starve opponents of chances: patient circulation at 0-0 tires the opponent, then subs add penetration around the hour; against counter-attacking Germany Spain held midfield positions and refused to push on, so there was no space to counter.',
    'Facing a counter-attacking side',
    'Concede almost nothing by never giving the ball or the space behind.',
    NULL, 96, 97, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'Keep the ball, hold positions, do not overcommit'),
    (2, 'Holding midfielder (Busquets)', 'Shadow the opposing number 10 (Ozil)'),
    (3, 'Substitutes (Pedro, Fabregas, Navas, Llorente)', 'Bring forward thrust after about an hour')
) AS v(so, role, job);

-- 82. pp.96-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '13 Tiki-taka', 'Hatchet man on the key creator',
    'Holland in the 2010 final gave up on outplaying Spain and targeted Spain''s most dangerous playmakers with physical fouling, then relied on through-balls for Robben behind the line.',
    'Opponent''s playmaker receives',
    'Disrupt rhythm and attack only via balls in behind for the fastest winger.',
    NULL, 96, 97, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielders (Van Bommel, De Jong)', 'Close down and foul the playmaker (Iniesta, Alonso)'),
    (2, 'Right winger (Robben)', 'Run in behind for through-balls')
) AS v(so, role, job);

-- 83. pp.101-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '14 False 9s & Argentines', 'One striker plus extra midfielder',
    'Spain at Euro 2008 improved when injury forced them from Torres+Villa to a lone striker with Fabregas added in midfield; Torres, freed of a partner, sprinted into the channels and scored from inside-right.',
    'Two-striker system starving midfield',
    'Gain midfield control while the lone striker stretches the channels.',
    NULL, 101, 103, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lone striker (Torres)', 'Run into channels behind the full backs'),
    (2, 'Extra attacking midfielder (Fabregas)', 'Link and provide assists')
) AS v(so, role, job);

-- 84. pp.102-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '14 False 9s & Argentines', 'Positional swap to confuse markers',
    'Guardiola started Eto''o central and Messi right, then swapped them after about ten minutes (Sporting Gijon, 2009 CL final) so defenders'' pre-match plans broke; later he switched whole shapes after ten minutes in big games.',
    'About ten minutes in, once opponent has settled',
    'Break the opponent''s marking plan mid-game.',
    NULL, 102, 102, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-forward and right forward (Eto''o, Messi)', 'Swap positions on a pre-arranged cue')
) AS v(so, role, job);

-- 85. pp.102-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '14 False 9s & Argentines', 'Dribble to draw, then pass',
    'Guardiola wanted dribbling that carries the ball into zones that drag opponents out of position to open a pass, not long solo runs from too deep with teammates badly placed.',
    'Dribbler on the ball facing a set block',
    'Use the carry to unbalance defenders so a teammate is freed.',
    NULL, 102, 102, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Dribble into a zone to draw a marker, then release'),
    (2, 'Supporting teammates', 'Stay close in good positions to receive')
) AS v(so, role, job);

-- 86. pp.102-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '14 False 9s & Argentines', 'False 9 drop, wide forwards run behind',
    'Barcelona''s signature move: Messi as false 9 drops into midfield, creating a 3v2 against two holding midfielders with Xavi and Iniesta; centre backs will not follow, so he turns between the lines, tempts them forward and slides through-balls for Henry/Eto''o, later Villa and Pedro, breaking in from wide.',
    'Static centre-back pair that will not step into midfield',
    'Win the centre numerically and feed out-to-in runs behind the line.',
    NULL, 102, 105, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'False 9 (Messi)', 'Drop between lines, overload midfield, turn, slip the through-ball'),
    (2, 'Wide forwards (Henry, Eto''o, Villa, Pedro)', 'Start wide, run out-to-in behind the centre backs'),
    (3, 'Interior midfielders (Xavi, Iniesta)', 'Make the 3v2 against the holding pair')
) AS v(so, role, job);

-- 87. pp.104-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '14 False 9s & Argentines', 'Wall-pass chain through zones',
    'Messi''s double one-two vs Villarreal: receive outside the box with seven defenders ahead, play two quick give-and-goes with Pedro, touching the ball in front of midfield, between lines and behind the defence, finishing over the keeper.',
    'Packed block, one teammate close by',
    'Break a deep block with rapid wall passes rather than a dribble.',
    NULL, 104, 104, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Playmaker (Messi)', 'Pass and sprint, receive again further on'),
    (2, 'Wall partner (Pedro, Xavi)', 'Return first time without moving much')
) AS v(so, role, job);

-- 88. pp.104-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '14 False 9s & Argentines', 'Pivot drops as third centre back',
    'Against Atletico''s two strikers (Forlan, Aguero), Busquets dropped between the centre backs for a spare man, with Messi drifting deep as the third midfielder; Barca morphed between 4-3-1-2 and 3-4-1-2 shapes depending on Busquets and the full backs.',
    'Opponent plays two central strikers',
    'Keep a spare defender at the back without losing midfield numbers.',
    '4-4-2', 104, 104, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Busquets)', 'Drop into the back line as third centre back'),
    (2, 'False 9 (Messi)', 'Drop to become the third midfielder'),
    (3, 'Full backs', 'Push on to make the back three/four shift')
) AS v(so, role, job);

-- 89. pp.104-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '14 False 9s & Argentines', 'Strikerless 4-4-2, forwards drift wide',
    'Villarreal''s nominal 4-4-2 had mobile forwards Rossi and Nilmar drifting to the flanks while wide midfielders Cazorla and Cani moved into the centre, another way of playing without a fixed striker.',
    'Settled possession',
    'Pull centre backs wide and overload the middle with technical midfielders.',
    NULL, 104, 104, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards (Rossi, Nilmar)', 'Drift out to opposite flanks'),
    (2, 'Wide midfielders (Cazorla, Cani)', 'Move inside into the centre')
) AS v(so, role, job);

-- 90. pp.105-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '14 False 9s & Argentines', 'Rotating 9 and 10 pair',
    'Barca 2011/12 sometimes played a 3-3-4 with Fabregas next to Messi, the two alternating as number 9 and number 10, effectively two false 9s.',
    'Settled possession',
    'Make the striker role impossible for centre backs to mark.',
    NULL, 105, 105, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two false 9s (Messi, Fabregas)', 'Take turns dropping as 10 and pushing as 9')
) AS v(so, role, job);

-- 91. pp.105-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '14 False 9s & Argentines', 'Midfielder as false 9 (Spain 2012)',
    'Del Bosque played Fabregas or Silva as a false 9 against old-school Italian defenders; first they passed in front too much, then Silva receiving between lines slid passes for out-to-in runs, and in the final Fabregas ran into the channels instead of coming short to stretch the back line.',
    'Physical centre backs who want a conventional striker to fight',
    'Deny the centre backs a target and attack runs into the channels.',
    NULL, 105, 105, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'False 9 (Fabregas)', 'Lead the line, run into channels rather than always come short'),
    (2, 'Advanced playmaker (Silva)', 'Receive between lines, slip the pass'),
    (3, 'Wide runners (Pedro, Navas)', 'Break in behind from wide')
) AS v(so, role, job);

-- 92. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '15 El Clasico', 'Man-mark false 9, block overlaps',
    'Juande Ramos'' Real used a 4-2-3-1 with a converted centre back (Heinze) tasked with tracking Messi and Marcelo as a defensive winger to stop Alves overlapping; Messi in the false 9 role still won the game 6-2.',
    'Facing Messi central plus attacking right back',
    'Neutralise the false 9 and the overlapping full back.',
    '4-3-3', 107, 107, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back/marker (Heinze)', 'Track Messi when he drops'),
    (2, 'Left winger (Marcelo)', 'Defend deep to stop Alves'' overlaps')
) AS v(so, role, job);

-- 93. pp.107-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '15 El Clasico', 'Full back pushed as right forward',
    'Guardiola vs Pellegrini''s diamond (April 2010): Alves played as right forward so Marcelo had to track him, leaving Xavi unmarked; Messi dropped to occupy Alonso, and Xavi in 20 yards of space chipped over the defence for Messi, or waited on halfway for Pedro''s run behind.',
    'Opponent''s narrow diamond with no one assigned to Xavi',
    'Use the diamond''s lack of width to free the deep playmaker.',
    '4-1-2-1-2', 107, 108, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back as forward (Alves)', 'Push high, pin the opposite full back'),
    (2, 'False 9 (Messi)', 'Drop onto the holding midfielder'),
    (3, 'Deep playmaker (Xavi)', 'Exploit space, chip or slip through-balls'),
    (4, 'Left forward (Pedro)', 'Run in behind')
) AS v(so, role, job);

-- 94. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_defend', '15 El Clasico', 'Slow the break, reorganise',
    'Barcelona''s midfielders were told to actively slow down Real''s counter-attacks and prolong the opponent''s build-up so teammates could get back into their positional structure.',
    'Ball lost against a fast counter-attacking side',
    'Buy time to restore shape before the counter develops.',
    NULL, 108, 108, 940)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest midfielders', 'Delay the ball carrier, block forward passes'),
    (2, 'Rest of team', 'Recover into the positional shape')
) AS v(so, role, job);

-- 95. pp.108-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '15 El Clasico', 'Concede ball, high line fails',
    'Mourinho''s first Clasico: Real let Barca have possession but kept a high defensive line; Ozil was asked to man-mark Xavi, who pushed high where Ozil was uncomfortable, and the false 9 fed Villa behind the high line (5-0). Dropping deep instead invites keep-ball.',
    'Facing a possession side',
    'Shows the risk of a half-way block: either sit deep and compact or press, not a high line without pressure.',
    '4-3-3', 108, 109, 950)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 10 (Ozil)', 'Man-mark the deep playmaker (failed)'),
    (2, 'Back four', 'High line, exposed to through-balls'),
    (3, 'Disciplined wide midfielder (Di Maria)', 'Track the overlapping full back')
) AS v(so, role, job);

-- 96. pp.109-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '15 El Clasico', 'High-pressure triangle, Pepe in midfield',
    'Mourinho dropped a creator for a ''high-pressure triangle'' with centre back Pepe as holding midfielder in front of the defence behind Khedira and Alonso, denying Messi space; in the cup final Pepe became a box-to-box presser on Xavi in a 4-3-3 with Ronaldo up front.',
    'Messi dropping into the zone in front of the defence',
    'Fill the space the false 9 wants and press the playmaker physically.',
    '4-3-3', 109, 110, 960)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Pepe)', 'Sit in front of defence on Messi, or press Xavi high'),
    (2, 'Central midfielders (Khedira, Alonso)', 'Screen and close down'),
    (3, 'Lone forward (Ronaldo)', 'Stay high for counters and crosses')
) AS v(so, role, job);

-- 97. pp.110-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '15 El Clasico', 'Deep block with playmaker man-marked',
    'In the 2011 CL semi first leg Real sat deep and blocked routes to goal with Pepe man-marking Xavi; once Pepe was sent off their 4-4-1 was outnumbered, Xavi was free and the gap between the defensive and midfield lines opened for Messi''s solo run.',
    'Opponent in settled possession',
    'Shut central routes; shows how a block collapses when the marker is removed.',
    NULL, 110, 110, 970)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Pepe)', 'Man-mark the playmaker, stay between the lines'),
    (2, 'Back four and midfield four', 'Stay compact, no gap between lines')
) AS v(so, role, job);

-- 98. pp.110-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_attack', '15 El Clasico', 'Quick ball wide, cross, header',
    'Real''s counter route against Barca: win it, move it quickly to a wide player, cross early into the box for a powerful header (Ronaldo cup-final winner); also Ozil drifting right to receive and slipping a through-ball for Ronaldo.',
    'Ball won in own half',
    'Score through the fast wide outlet before Barca recover.',
    NULL, 110, 112, 980)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Di Maria)', 'Receive early, cross'),
    (2, 'Number 10 (Ozil)', 'Drift wide right, play the through-ball'),
    (3, 'Forward (Ronaldo)', 'Attack the cross or the ball in behind')
) AS v(so, role, job);

-- 99. pp.111-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '15 El Clasico', 'Bold front-foot press vs Barca',
    'Real in the 2011 Supercopa and later Clasicos pressed proactively and high, with Benzema running in behind and Ronaldo wide-left attacking Alves'' space; a high press forced a Valdes error for a goal in 30 seconds.',
    'Barca building from the keeper and centre backs',
    'Win the ball high and exploit the space the attacking right back leaves.',
    NULL, 111, 111, 990)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front line (Benzema, Ronaldo)', 'Press the keeper and centre backs'),
    (2, 'Left forward (Ronaldo)', 'Attack the space behind the right back')
) AS v(so, role, job);

-- 100. pp.111-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '15 El Clasico', 'In-game shape switch to back three',
    'Barca in December 2011 switched after about ten minutes from 4-3-3 to a back three: Messi as number 10, Alves pushed forward as right winger, Puyol slid across to right centre back, and Busquets played a hybrid half-midfielder, half-defender role, finding space away from Ozil.',
    'Pre-planned switch early in the game',
    'Free the pivot from his marker and face the opponent''s star winger with two centre backs.',
    NULL, 111, 111, 1000)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Busquets)', 'Drop into a hybrid defender-midfielder role, feed midfield'),
    (2, 'Right back (Alves)', 'Become the right winger'),
    (3, 'Right centre back (Puyol)', 'Slide across to cover Alves'' side'),
    (4, 'Number 10 (Messi)', 'Move from right to the hole')
) AS v(so, role, job);

-- 101. pp.112-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '15 El Clasico', 'Follow-and-cover on the false 9',
    'Real''s 4-2-3-1 in April 2012: press early then drop off while holding an aggressive offside line; when Messi dropped, one centre back (Pepe or Ramos) followed him deep and the other covered the space behind. Barca were in a 3-3-1-3.',
    'False 9 drops into midfield',
    'Deny the false 9 time without leaving a hole behind.',
    NULL, 112, 112, 1010)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marking centre back (Pepe/Ramos)', 'Step out and follow the false 9'),
    (2, 'Covering centre back', 'Tuck in behind to cover the space left'),
    (3, 'Back line', 'Keep an aggressive offside line')
) AS v(so, role, job);

-- 102. pp.115-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '16 Verticality', 'Concede possession, deep block, break with wingers',
    'Heynckes'' Bayern 2013 vs Barcelona did not try to out-pass them; they sat deep, defended compactly and let Barca push forward, exploiting physicality and set pieces.',
    'Possession-dominant opponent commits players forward chasing a goal',
    'Absorb pressure, then attack the space behind with fast wide dribblers.',
    NULL, 115, 116, 1020)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (Robben, Ribery)', 'Defend long spells, then burst into space on regains'),
    (2, 'Full-backs (Alaba)', 'Long diagonal to the winger once the ball is won'),
    (3, 'Front men (Muller, Gomez)', 'Attack set pieces and far-post crosses')
) AS v(so, role, job);

-- 103. pp.116-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_attack', '16 Verticality', 'Two-winger counter with rapid interchanges',
    'Bayern under van Gaal/Heynckes attacked mainly through Robben and Ribery, who swapped quick passes at speed from deep in their own half while defenders could not keep up.',
    'Ball won around own box',
    'Score within seconds through the two flank dribblers.',
    NULL, 116, 116, 1030)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Robben)', 'Carry inside from the right, shoot with left foot'),
    (2, 'Left winger (Ribery)', 'Run the left, combine one-twos with partner')
) AS v(so, role, job);

-- 104. pp.116-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_attack', '16 Verticality', 'Vertikalspiel - vertical passes after regain',
    'Klopp''s Dortmund 2010-12 prioritised forward passes immediately after winning the ball; tucked-in wide midfielders sprinted into space vacated by advanced opposition full-backs while the No.10 drifted into pockets to prompt counters.',
    'Possession regained in own third',
    'Reach goal fast with few vertical passes before the opponent reorganises.',
    NULL, 116, 117, 1040)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielders (Grosskreutz, Blaszczykowski)', 'Sense the turnover early and sprint behind advanced full-backs'),
    (2, 'No.10 (Kagawa)', 'Drift laterally into pockets, make arced runs into channels'),
    (3, 'Striker (Lewandowski)', 'Lead the line, knock long balls down for runners'),
    (4, 'Full-back (Piszczek)', 'Intercept, play forward first time')
) AS v(so, role, job);

-- 105. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '16 Verticality', 'Wide midfielders double up on star wingers',
    'Against Bayern in the 2012 cup final, Dortmund''s wide midfielders sat deep in their own third helping full-backs double-team Ribery and Robben.',
    'Opponent attacks through elite wingers',
    'Neutralise wing threat while staying primed to break.',
    NULL, 117, 117, 1050)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielders', 'Drop beside full-back to double the winger'),
    (2, 'Full-backs', 'Engage the winger with cover behind')
) AS v(so, role, job);

-- 106. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_attack', '16 Verticality', 'Striker switches channel to stretch centre-backs',
    'On a fast break versus a side with advanced full-backs, Dortmund''s runner carried the ball while the striker shifted to the opposite channel, so both sides of the centre-back pair were attacked.',
    'Regain with opposition full-backs high and midfield pair bypassed',
    'Create a 2v2 or 3v2 across the width of the two centre-backs.',
    NULL, 117, 117, 1060)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Carrier (Kagawa)', 'Drive forward, slow dribble to let wide runner arrive'),
    (2, 'Wide midfielder (Grosskreutz)', 'Advance down the far side for the slip pass'),
    (3, 'Striker (Lewandowski)', 'Shift run to the opposite channel')
) AS v(so, role, job);

-- 107. pp.117-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '16 Verticality', 'No.10 lateral runs into channels',
    'Ozil, as Germany''s and Real Madrid''s counter-attacking creator, made lateral runs from the inside-right to the inside-left channel, opening passing angles and dragging holding midfielders out of position.',
    'Team breaking with space ahead',
    'Create passing lanes and space for an onrushing midfielder or winger.',
    NULL, 117, 118, 1070)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Ozil)', 'Run across into the opposite channel, receive on the move, square for tap-in'),
    (2, 'Box-to-box midfielder (Khedira)', 'Carry and use the angle Ozil''s run opens'),
    (3, 'Full-back (Lars Bender)', 'Sprint 80 yards into the space created')
) AS v(so, role, job);

-- 108. pp.118-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '16 Verticality', 'Overload centre with rotating midfield trio',
    'Germany at Euro 2012 dominated Netherlands by overloading the centre and rotating its midfield three intelligently when opponents sat deeper and denied counters.',
    'Opponent sits deep, no space to break into',
    'Win the middle numerically and keep possession.',
    NULL, 118, 118, 1080)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfield trio', 'Rotate positions to escape markers'),
    (2, 'Striker (Gomez)', 'Finish from central service')
) AS v(so, role, job);

-- 109. pp.118-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_attack', '16 Verticality', 'Break the first wave, attack split team',
    'Germany 2014 planned to win the ball quickly or break through Brazil''s first line of pressure, knowing Brazil would split into separate attack and defence units.',
    'Opponent presses or attacks with many men and loses the ball',
    'Exploit the gap between a stretched opponent''s lines.',
    NULL, 118, 119, 1090)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders (Kroos, Khedira)', 'Win ball, play past the first wave, run beyond'),
    (2, 'Forwards (Muller, Klose)', 'Exploit space between the split units')
) AS v(so, role, job);

-- 110. pp.119-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_attack', '16 Verticality', 'Target the zone behind attacking full-back',
    'Germany''s 5-0 half-time lead vs Brazil came largely from attacking the space behind Marcelo, who kept getting caught high at transitions and switching off.',
    'Opposition full-back caught upfield at turnover',
    'Repeatedly break into the same vacated zone.',
    NULL, 119, 119, 1100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right-sided attacker (Muller)', 'Run into space behind the advanced left-back'),
    (2, 'Midfield runner (Khedira)', 'Sprint alongside to support'),
    (3, 'Left forward (Ozil)', 'Drift across to the side where space is'),
    (4, 'Overlapping right-back (Lahm)', 'Join the break on the overlap')
) AS v(so, role, job);

-- 111. pp.119-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'set_piece', '16 Verticality', 'Throw-in combination for backheel layoff',
    'Germany repeated a rehearsed throw-in passing combination against Brazil; when the defender dropped too deep Muller was onside and backheeled for Klose.',
    'Throw-in in attacking third',
    'Create a close-range finish from a short throw routine.',
    NULL, 119, 119, 1110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver (Muller)', 'Peel into box, backheel layoff'),
    (2, 'Striker (Klose)', 'Arrive to finish')
) AS v(so, role, job);

-- 112. pp.119-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_defend', '16 Verticality', '15-pass rule - move up together',
    'Guardiola insisted Bayern keep possession long enough (around 15 passes) to advance as a unit and assume correct positions, because Bundesliga sides could counter in seconds.',
    'Team in possession before committing forward',
    'Never leave gaps for counters when the ball is lost.',
    NULL, 119, 120, 1120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'Advance a few metres together before risking the final pass'),
    (2, 'Holding midfielder', 'Stay behind the ball as balance')
) AS v(so, role, job);

-- 113. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '16 Verticality', 'High line to isolate wingers 1v1',
    'Guardiola''s Bayern pushed the defensive line very high with centre-backs where midfielders normally stand, so Ribery and Robben received high and only needed short accelerations against a single defender.',
    'Settled possession in opposition half',
    'Stop opponents doubling up on the wingers and create 1v1s, then cross for top finishers.',
    NULL, 120, 120, 1130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-backs', 'Hold position near halfway'),
    (2, 'Wingers (Ribery, Robben)', 'Stay high and wide, beat one man, cross'),
    (3, 'Target forward (Mandzukic, Lewandowski)', 'Attack crosses')
) AS v(so, role, job);

-- 114. pp.120-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '16 Verticality', 'Patient midfield, direct final third',
    'Guardiola''s Bayern hybrid: work the ball patiently into midfield (Spanish), then go direct in the final third (German), with long diagonals to wingers and crosses to a big No.9.',
    'Ball progressed into midfield',
    'Combine control with fast, direct finishing actions.',
    NULL, 120, 121, 1140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-backs (Boateng, Dante)', 'Diagonals to wingers when available'),
    (2, 'Midfielders (Alonso)', 'Line-breaking vertical passes into forwards'),
    (3, 'Big No.9', 'Aerial target in the box')
) AS v(so, role, job);

-- 115. pp.121-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '16 Verticality', 'Free centre-back launches long balls',
    'In a diamond-vs-diamond game, Tuchel''s Dortmund strikers pressed Bayern''s creative outer centre-backs and left the middle one free; Guardiola swapped Martinez and Boateng so the long passer was the free man, who hit balls over the top.',
    'Opponent''s front two leave one centre-back unpressed',
    'Bypass a congested, pressing midfield with direct passes to forwards.',
    '4-3-1-2', 121, 121, 1150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free centre-back (Boateng)', 'Hit long passes over the top'),
    (2, 'Forwards (Muller, Lewandowski)', 'Run beyond the line for the long ball'),
    (3, 'Opposition centre-back (Hummels)', 'Long diagonals to a fast striker (Aubameyang)')
) AS v(so, role, job);

-- 116. pp.124-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_defend', '17 Gegenpressing', 'Gegenpressing as an attacking tactic',
    'Klopp''s Dortmund counter-pressed immediately on loss, believing a regain near goal is the best chance creator; unlike Barcelona (press to get the ball back and keep it), Dortmund pressed to attack quickly.',
    'Ball lost in opposition half',
    'Win the ball back close to goal while the opponent is disorganised.',
    NULL, 124, 125, 1160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players', 'Swarm the ball carrier at once'),
    (2, 'Forwards', 'Press from the front'),
    (3, 'Midfielders', 'Close from behind and the side')
) AS v(so, role, job);

-- 117. pp.124-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '17 Gegenpressing', 'Medium block, press the second pass',
    'Dortmund usually stood off opposition centre-backs in a medium block (4-2-3-1 becoming 4-4-2) and pressed once the ball went into full-backs or midfielders, avoiding a full-pitch press that invites long balls.',
    'Pass from centre-back into full-back or midfielder',
    'Lure opponents into playing into trouble, then win the ball.',
    NULL, 124, 125, 1170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two', 'Screen, leave centre-backs the ball'),
    (2, 'Wide midfielders', 'Jump the full-back on the trigger pass'),
    (3, 'Central midfielders', 'Double up on receiving midfielder')
) AS v(so, role, job);

-- 118. pp.125-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_defend', '17 Gegenpressing', 'Crowd the ball, box in at touchline',
    'Dortmund piled players into the immediate vicinity of the ball, with wide midfielders tucked inside to keep horizontal compactness, often trapping opponents against the touchline.',
    'Opponent regains near a flank',
    'Overwhelm the carrier through numbers and intimidation.',
    NULL, 125, 125, 1180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Tucked wide midfielders', 'Stay narrow, collapse onto the ball'),
    (2, 'Striker (Lewandowski)', 'Close down from the front'),
    (3, 'Opposite winger (Mkhitaryan)', 'Come inside from far flank to congest play')
) AS v(so, role, job);

-- 119. pp.125-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_defend', '17 Gegenpressing', 'Regain at the moment of loss',
    'Klopp''s rule: the best moment to win the ball is right after losing it, because the opponent is looking for orientation and has spent energy on the tackle. Defenders already stepping into transition get caught out.',
    'Possession just lost',
    'Regain within seconds and score before the opponent''s shape forms.',
    NULL, 125, 125, 1190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players around the ball', 'Press immediately before the opponent orients'),
    (2, 'Attackers', 'Combine fast on the edge of the box after regain')
) AS v(so, role, job);

-- 120. pp.126-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '17 Gegenpressing', 'Man-orientated high press',
    'Heynckes'' Bayern 2012/13 pressed by man-marking in advanced positions and winning duels physically, led by a hard-working centre-forward, rather than cutting lanes or swarming one zone.',
    'Opponent plays out from the back or goal kick',
    'Force hopeful long balls or win the ball high via tackles.',
    NULL, 126, 126, 1200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-forward (Mandzukic)', 'Harry the back line, then drop to keep team compact'),
    (2, 'No.10 (Kroos)', 'Support the press'),
    (3, 'Midfielders (Schweinsteiger, Martinez)', 'Track and tackle their man, crowd the playmaker'),
    (4, 'Wingers (Robben, Ribery)', 'Join the pressing')
) AS v(so, role, job);

-- 121. pp.126-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '17 Gegenpressing', 'High press forces long ball, win second ball',
    'Bayern pressed Arsenal relentlessly early, forcing a hopeful hoof; they won the second ball and attacked immediately.',
    'Opponent forced to clear long under pressure',
    'Collect the loose ball and attack an unset defence.',
    NULL, 126, 126, 1210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front pressers', 'Force the long clearance'),
    (2, 'Midfielders', 'Win the second ball'),
    (3, 'No.10 (Kroos)', 'Arrive unmarked at edge of box')
) AS v(so, role, job);

-- 122. pp.127-127
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '17 Gegenpressing', 'Winger swaps to centre vs high line',
    'In the 2013 final Robben moved from right wing to centre-forward to use his pace against Dortmund''s high defensive line, getting in behind repeatedly.',
    'Opponent defends with a high line',
    'Use a fast attacker centrally to run in behind.',
    NULL, 127, 127, 1220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Robben)', 'Move central, run in behind the high line'),
    (2, 'Centre-forward (Muller)', 'Swap out to the right')
) AS v(so, role, job);

-- 123. pp.128-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_defend', '17 Gegenpressing', 'Four-second counter-press then retreat',
    'Guardiola drilled Bayern to move forward automatically on loss for a four-second press, then drop into a deeper block if it failed.',
    'Possession lost',
    'Win the ball fast or recover shape quickly.',
    NULL, 128, 128, 1230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards (Mandzukic, Muller)', 'Sprint back/diagonally at full speed to press'),
    (2, 'Whole team', 'If no regain in four seconds, retreat to deeper block')
) AS v(so, role, job);

-- 124. pp.128-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '17 Gegenpressing', 'Holder drops in to beat front two',
    'To beat heavy pressing, Guardiola''s Bayern dropped the holding midfielder between the centre-backs, making three against the opponent''s front two.',
    'Opponent presses with two forwards',
    'Create a free man in first phase of build-up.',
    NULL, 128, 128, 1240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Lahm, Alonso)', 'Drop between centre-backs'),
    (2, 'Centre-backs', 'Split wide')
) AS v(so, role, job);

-- 125. pp.128-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '17 Gegenpressing', 'Bypass press with long balls to two targets',
    'Against Dortmund''s press, Guardiola played midfielder-defender Martinez as a second striker with Mandzukic and hit long balls towards them, bypassing the press altogether.',
    'Opponent''s press is too strong to play through',
    'Skip the pressed zone and play off knock-downs.',
    NULL, 128, 128, 1250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Second striker (Martinez)', 'Aerial target beside the No.9'),
    (2, 'Centre-forward (Mandzukic)', 'Win headers'),
    (3, 'Defenders', 'Go long early')
) AS v(so, role, job);

-- 126. pp.128-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '17 Gegenpressing', 'Mirror back three to press 3v3',
    'Germany switched system against Italy at Euro 2016 to press Italy''s back three with three players, and engaged France in advanced positions.',
    'Opponent builds with a back three',
    'Match numbers in the press so no defender is free.',
    '3-5-2', 128, 128, 1260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front three', 'Each press one centre-back'),
    (2, 'Wing-backs', 'Push up on opposition wing-backs')
) AS v(so, role, job);

-- 127. pp.130-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '18 Reinvention', 'Midfield packs plus long balls behind',
    'Algeria in 2014 closed down Germany''s midfielders in packs, then hit long balls behind for a quick lone striker against slow centre-backs.',
    'Ball won after pack pressing in midfield',
    'Exploit a high, slow defence with pace in behind.',
    NULL, 130, 130, 1270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'Hunt the ball in groups'),
    (2, 'Lone striker (Slimani)', 'Run in behind into the channel')
) AS v(so, role, job);

-- 128. pp.130-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '18 Reinvention', 'Sweeper-keeper behind a high line',
    'Neuer adjusted his position continuously with the ball and the defensive line, often 15 yards out of the box, rushing out to clear balls in behind and acting as an extra outfield player.',
    'Ball played in behind a high defensive line',
    'Let the defence play high safely by covering the space behind.',
    NULL, 130, 132, 1280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Neuer)', 'Stand high, sweep balls in behind, slide or head clear'),
    (2, 'Defensive line', 'Push up, trust the keeper')
) AS v(so, role, job);

-- 129. pp.132-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '18 Reinvention', 'Back three vs front three, keeper as spare',
    'Guardiola normally fielded one more defender than the opponent''s forwards, but with Neuer sweeping he used a back three against Barcelona''s front three and pressed seven against seven high up.',
    'Facing a dangerous front three',
    'Free an extra player for pressing by counting the keeper as a defender.',
    '4-3-3', 132, 132, 1290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three (Boateng, Rafinha, Benatia)', 'Mark the front three high'),
    (2, 'Goalkeeper (Neuer)', 'Sweep balls over the top')
) AS v(so, role, job);

-- 130. pp.132-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '18 Reinvention', 'Positional play grid rules',
    'Guardiola divides the pitch into a grid and avoids players lining up vertically or horizontally; full-back and winger never in the same vertical strip, so when one goes wide the other narrows.',
    'Settled possession',
    'Offer varied passing lines and stay evenly spread to press on loss.',
    NULL, 132, 132, 1300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full-back', 'Take the opposite lane to the winger'),
    (2, 'Winger', 'Narrow when full-back goes wide (or vice versa)'),
    (3, 'All players', 'Avoid standing in line with a teammate')
) AS v(so, role, job);

-- 131. pp.132-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_defend', '18 Reinvention', 'Inverted full-backs as rest defence',
    'Guardiola''s Bayern brought full-backs into central midfield beside the holder in possession, so on loss five defensive players were already compact centrally, conceding only the flanks.',
    'Team in possession with wingers holding width',
    'Stop counters through the channels and the middle.',
    NULL, 132, 133, 1310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full-backs (Lahm, Alaba)', 'Step inside to sit either side of the holder'),
    (2, 'Holding midfielder', 'Anchor between the inverted full-backs'),
    (3, 'Centre-backs', 'Hold as a pair behind')
) AS v(so, role, job);

-- 132. pp.133-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '18 Reinvention', 'Full-back drifts in to free winger',
    'Alaba drifted infield from left-back; the opposing right winger followed him, opening space for Ribery to drop deeper and collect the ball.',
    'Opposing winger marks the full-back',
    'Drag a marker inside to create a free receiver wide.',
    NULL, 133, 133, 1320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left-back (Alaba)', 'Move into midfield, pull the winger inside'),
    (2, 'Left winger (Ribery)', 'Drop to receive in the space freed')
) AS v(so, role, job);

-- 133. pp.133-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '18 Reinvention', '2-3-3-2 diamond with half-backs',
    'Bayern lined up 2-3-4-1 then 2-3-3-2 with full-backs as the outside points of a midfield diamond, Kroos at the base, and wingers covering a whole flank each; the half-spaces between centre and wing were the full-backs'' zones.',
    'Facing an opponent that counters',
    'Dominate midfield and largely prevent counters.',
    NULL, 133, 133, 1330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full-backs (Lahm, Alaba, Rafinha)', 'Play as half-backs/central midfielders'),
    (2, 'Base midfielder (Kroos)', 'Anchor the diamond'),
    (3, 'Wingers (Ribery, Robben)', 'Provide all width on their flank'),
    (4, 'Front two (Muller, Mandzukic)', 'Lead the line')
) AS v(so, role, job);

-- 134. pp.134-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '18 Reinvention', 'Raumdeuter - late runs into space',
    'Muller''s role as ''space interpreter'': a floating forward who hangs in the space behind the opposition midfield and makes late, unpredictable runs into the box.',
    'Ball in wide or central build-up near the box',
    'Arrive unmarked in the box to score.',
    NULL, 134, 134, 1340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Raumdeuter (Muller)', 'Find space behind midfield, late runs into box')
) AS v(so, role, job);

-- 135. pp.134-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '18 Reinvention', 'Rotating front three with false 9',
    'Germany at the 2014 World Cup sometimes used Gotze, Muller and Ozil as a front three rotating constantly with no fixed striker, keeping defenders guessing.',
    'Settled attack',
    'Deny centre-backs a fixed reference to mark.',
    NULL, 134, 135, 1350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'False 9 (Gotze)', 'Drop and rotate with wide attackers'),
    (2, 'Wide attackers (Muller, Ozil)', 'Swap into central zones')
) AS v(so, role, job);

-- 136. pp.138-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'set_piece', '19 The Mixer', 'Win throws in channels for long throws',
    'Pulis'' Stoke played long balls into the channels to tempt defenders into heading out for throw-ins, then launched long throws into a box packed with tall players.',
    'Ball in attacking-third channel',
    'Manufacture set-piece chances in the box.',
    NULL, 138, 138, 1360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Long-throw specialist (Delap)', 'Hurl the throw into the box'),
    (2, 'Tall players', 'Pack the box and attack the throw')
) AS v(so, role, job);

-- 137. pp.138-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '19 The Mixer', 'Deep defence, blocks, long balls',
    'Dyche''s Burnley and Allardyce-style sides defended deep with many last-ditch blocks, showed little interest in possession and played long balls into attack.',
    'Opponent has the ball',
    'Concede possession, protect the box, play direct.',
    NULL, 138, 138, 1370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Defend deep, block shots'),
    (2, 'Front players', 'Target for long balls')
) AS v(so, role, job);

-- 138. pp.139-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '19 The Mixer', 'POMO - ball into the mixer',
    'Charles Hughes'' FA doctrine: launch the ball into the box toward the ''position of maximum opportunity'' and regain it there when possible; territory over possession.',
    'Any chance to go forward',
    'Get the ball into the box quickly and often.',
    NULL, 139, 139, 1380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders/keeper', 'Launch long into the box'),
    (2, 'Attackers', 'Contest and win it back near goal')
) AS v(so, role, job);

-- 139. pp.139-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '19 The Mixer', 'Dutch high line and offside trap',
    'Koeman''s Southampton/Everton kept a Dutch-style high line and offside trap with aggressive pressing, ball-playing defenders, attacking full-backs and a sweeping keeper.',
    'Opponent in possession',
    'Compress the pitch and catch forwards offside.',
    NULL, 139, 140, 1390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-backs (Van Dijk, Alderweireld)', 'Defend high, step up together'),
    (2, 'Goalkeeper (Stekelenburg)', 'Sweep behind the line'),
    (3, 'Full-backs (Baines, Coleman)', 'Attack, overlap direct wingers')
) AS v(so, role, job);

-- 140. pp.140-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '19 The Mixer', 'Defend near halfway with third centre-back',
    'Pochettino''s Tottenham pressed heavily with an aggressive line; the centre-back pair was comfortable defending close to halfway, and he added a third centre-back.',
    'Opponent building up',
    'Squeeze space and win the ball high.',
    NULL, 140, 140, 1400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-backs (Alderweireld, Vertonghen)', 'Hold line near halfway'),
    (2, 'Third centre-back', 'Extra cover in a back three'),
    (3, 'Front players', 'Press aggressively')
) AS v(so, role, job);

-- 141. pp.140-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '19 The Mixer', 'Wide wingers, cut-backs across six-yard box',
    'Guardiola''s City used genuine wide wingers on their natural side running the outside and delivering low balls across the six-yard box, finished by the far winger or the striker.',
    'Winger beats full-back on the outside',
    'Generate many open-play goals from low crosses.',
    NULL, 140, 140, 1410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Sterling)', 'Hug the line, cross low or arrive at far post'),
    (2, 'Left winger (Sane)', 'Same on the left, attack far post'),
    (3, 'Centre-forward (Aguero)', 'Attack the six-yard box')
) AS v(so, role, job);

-- 142. pp.140-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '19 The Mixer', 'Ball-playing defender shuttles into midfield',
    'City used a sweeper-keeper (Bravo) far off his line and defenders like Stones and Fernandinho shuttling between defence and holding midfield, echoing Rijkaard at Ajax.',
    'Building from the back',
    'Add a passer to midfield without losing defensive cover.',
    NULL, 140, 140, 1420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Bravo)', 'Play far off line, join build-up'),
    (2, 'Defender-midfielder (Stones, Fernandinho)', 'Step between lines as needed')
) AS v(so, role, job);

-- 143. pp.141-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '19 The Mixer', '3-4-3 wide forwards pin full-backs narrow',
    'Conte''s Chelsea: wide forwards started wide then drifted inside, dragging opposition full-backs narrow and freeing wing-backs to overlap, attacking a back four with five.',
    'Opponent defends with a back four',
    'Overload the back four with five attackers while staying solid.',
    NULL, 141, 141, 1430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside forwards (Hazard, Pedro, Willian)', 'Drift inside to drag full-backs'),
    (2, 'Wing-backs (Alonso, Moses)', 'Overlap into freed space'),
    (3, 'Striker (Costa)', 'Occupy centre-backs'),
    (4, 'Three CBs + two holders', 'Stay as counter-attack cover')
) AS v(so, role, job);

-- 144. pp.141-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '19 The Mixer', 'Libero steps out and switches play',
    'In Conte''s back three, the central defender (David Luiz, Bonucci-style) swept behind his partners, carried the ball forward and sprayed long diagonals, while calling the line up and down.',
    'Possession in first phase',
    'Turn the spare defender into a deep playmaker.',
    NULL, 141, 141, 1440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central CB (David Luiz)', 'Sweep, step into midfield, long diagonals'),
    (2, 'Outside CBs (Azpilicueta)', 'Cover wide and defend')
) AS v(so, role, job);

-- 145. pp.141-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '19 The Mixer', 'Mirror 3-4-3, wing-back tracks wing-back',
    'Opponents nullified Chelsea''s 3-4-3 by deploying a 3-4-3 themselves, with their wing-backs tracking Chelsea''s wing-backs.',
    'Facing a 3-4-3 with attacking wing-backs',
    'Remove the numerical advantage on the flanks.',
    '3-4-3', 141, 141, 1450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing-backs', 'Track the opposite wing-back all the way'),
    (2, 'Back three', 'Match the front three')
) AS v(so, role, job);

-- 146. pp.142-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '19 The Mixer', 'Ball-winning screen anticipates counters',
    'Kante as the classic French destroyer: anticipating when an attack is going wrong and stepping in to tackle or intercept, keeping distribution tidy; Leicester even paired two such ball-winners.',
    'Opponent regains and tries to break',
    'Stop counters at source in front of defence.',
    NULL, 142, 142, 1460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Kante)', 'Read play, tackle and intercept, simple pass'),
    (2, 'Second ball-winner (Ndidi)', 'Double the screen')
) AS v(so, role, job);

-- 147. pp.143-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '19 The Mixer', '4-3-3 sole holder plus free 8s',
    'Guardiola''s City used Fernandinho as lone holder with Silva and De Bruyne as ''free 8s'' storming through midfield, swapping passes and arriving in the final third.',
    'Settled possession',
    'Overload midfield with technical runners breaking from deep.',
    NULL, 143, 144, 1470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Sole holder (Fernandinho)', 'Screen and recycle'),
    (2, 'Free 8s (Silva, De Bruyne)', 'Drive forward, combine, deliver through balls and crosses')
) AS v(so, role, job);

-- 148. pp.144-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'to_defend', '19 The Mixer', 'Asymmetric full-backs cover free 8s',
    'With the 8s pushing on, City''s right-back (Walker) held as part of a back three while converted left-backs (Delph, Zinchenko) took narrow positions; the left winger provided width.',
    'Both free 8s commit forward',
    'Prevent being overrun in midfield on turnovers.',
    NULL, 144, 144, 1480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right-back (Walker)', 'Stay back to form a three'),
    (2, 'Left-back (Delph, Zinchenko)', 'Tuck inside into midfield'),
    (3, 'Left winger (Sane)', 'Hold width')
) AS v(so, role, job);

-- 149. pp.144-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'out_of_possession', '19 The Mixer', 'Striker funnels play, box in full-back',
    'Klopp''s Liverpool: the centre-forward angles his run to steer opposition passing down one flank, then teammates trap the full-back against the touchline.',
    'Opponent building from the back',
    'Win the ball high in a predictable zone.',
    NULL, 144, 145, 1490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-forward (Firmino)', 'Curve run to cut one side and funnel play'),
    (2, 'Winger and midfielder (Mane, Keita)', 'Box the receiver in at the line'),
    (3, 'Full-back (Robertson)', 'Join to finish the regain and attack')
) AS v(so, role, job);

-- 150. pp.145-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '19 The Mixer', 'False 9 drops, midfielder runs beyond',
    'Firmino as Liverpool''s false 9 dropped deep, pulling a centre-back up the pitch and opening space for a midfielder (Wijnaldum) to run in behind.',
    'Centre-back follows the dropping striker',
    'Create space between the lines for onrushing midfielders.',
    NULL, 145, 145, 1500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'False 9 (Firmino)', 'Drop deep, link play, drag centre-back'),
    (2, 'Midfield runner (Wijnaldum)', 'Run into the vacated space'),
    (3, 'Wide forwards (Mane, Salah)', 'Attack from wide, counter threat')
) AS v(so, role, job);

-- 151. pp.145-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '19 The Mixer', 'Compact shape for second balls',
    'Guardiola adapted at City by training second, third and fourth balls; the team must stay compact to win loose balls after aerial duels in the English game.',
    'Ball in the air or loose after a duel',
    'Win the loose ball and keep possession.',
    NULL, 145, 145, 1510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'Stay close around duel zones'),
    (2, 'Whole team', 'Keep compact distances')
) AS v(so, role, job);

-- 152. pp.146-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'in_possession', '19 The Mixer', '3-5-2 with spare man carrying, free 8s',
    'England 2018 used a 3-3-2-2: a ball-playing spare centre-back (Stones) carrying forward, an ex-full-back as right centre-back (Walker), wing-backs chosen for set pieces, one holder (Henderson) and two free 8s running beyond; Kane dropped to make space for Sterling.',
    'Settled possession',
    'Progress via the spare defender and create runs behind the defence.',
    NULL, 146, 146, 1520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Spare centre-back (Stones)', 'Carry the ball out'),
    (2, 'Right centre-back (Walker)', 'Tuck in from full-back role'),
    (3, 'Sole holder (Henderson)', 'Screen'),
    (4, 'Free 8s (Alli, Lingard)', 'Off-ball runs behind the defence'),
    (5, 'Striker (Kane)', 'Drop to create space for Sterling')
) AS v(so, role, job);

-- 153. pp.146-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-zonal-marking'), 'set_piece', '19 The Mixer', 'Set-piece specialists as wing-backs',
    'England picked Trippier and Young at wing-back largely for set-piece delivery; six of 11 tournament goals came from free kicks or corners.',
    'Corners and free kicks',
    'Make set pieces a main scoring route.',
    NULL, 146, 146, 1530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing-backs (Trippier, Young)', 'Deliver set pieces'),
    (2, 'Aerial players', 'Attack deliveries')
) AS v(so, role, job);

COMMIT;
