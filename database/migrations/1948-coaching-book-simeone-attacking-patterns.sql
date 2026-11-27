-- 1948 📚 Coaching book patterns: Terzis, "Diego Simeone Attacking Tactics -
-- Tactical Analysis and Sessions from Atlético Madrid's 4-4-2" (SoccerTutor),
-- Atlético 2017-18 and 2018-19.  Every page (1-196) read; each team pattern
-- the book describes written up in OUR OWN WORDS (short paraphrase, nothing
-- copied): moment, trigger, aim, opponent shape where the book splits by it,
-- app page numbers as the citation, and who does what.  Training sessions /
-- practices, intro, contents and adverts are left out.  Owner's personal
-- library.  (James 11/26 'continue with the reading of the coach viewer books')
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Diego Simeone Attacking Tactics',
    subtitle    = 'Tactical Analysis and Sessions from Atlético Madrid''s 4-4-2',
    author      = 'Athanasios Terzis',
    team        = 'Atlético Madrid',
    season      = '2017-18, 2018-19',
    method_note = 'Companion to the defending book: the author studied Atlético Madrid''s 2017-18 and 2018-19 matches in Simeone''s 4-4-2 and kept a behaviour only once it had recurred at least 10 times, drawn with positions, passes, movements and body shape, then turned into a training session. Covers the attacking phase (build-up v 4-4-2 / 4-2-3-1 / 4-3-3 / 3-5-2, full back and wide midfielder combinations, forwards creating and attacking space behind) and the transition from defence to attack (counters after winning the ball wide or central, open v closed ball, forwards'' positioning, width).'
WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad');

-- 1. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'The Attacking Phase - stages of build-up', 'Safe-first goal kick and build-up policy',
    'Build-up starts from the keeper and moves stage by stage: back line, then between their forwards and midfield, then between midfield and defence, then the final pass and finish. Stages get skipped when the ball is won higher up or when Oblak has to go long.',
    'Keeper in possession; how hard and how high the opponent presses',
    'Avoid risky short passing under a high press: go long and play safe; build short only when free options exist.',
    NULL, 17, 17, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Oblak)', 'Goes long to the forwards when the press is high and a short pass looks risky'),
    (2, 'Centre backs', 'Take the short ball only when there is real time and space'),
    (3, 'Central midfielder', 'Drops in to offer a safe short option'),
    (4, 'Front two', 'Target for the long ball when the build-up is skipped')
) AS v(so, role, job);

-- 2. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Benefits of Atletico''s Attacking Shape Against a 4-Man Defence', 'Inside wide mids, high full backs v back four',
    'Both full backs push high and wide while the two wide midfielders tuck in between the lines next to the forwards. This overloads the central area in front of the back four.',
    'Settled possession against a back four',
    'Put the opposing full backs in a dilemma: follow the inside mid inward and leave the flank for our full back, or stay wide and leave a central overload and gaps for the forwards.',
    NULL, 18, 18, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (F. Luis, Juanfran)', 'Hold width high up; attack the space when their full back comes inside'),
    (2, 'Wide midfielders (Koke, Correa)', 'Take up inside positions between the lines; most key passes and shots come from here'),
    (3, 'Front two', 'Look for gaps between defenders opened when the full backs narrow'),
    (4, 'Central midfielders', 'Feed the players between the lines')
) AS v(so, role, job);

-- 3. pp.19-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Benefits of Atletico''s Attacking Shape Against a 3-Man Defence', 'Central overload v back three',
    'Against a back three with wing backs, the flank space is mostly closed by the wing backs, so our full backs receive deeper. The wide midfielders still move inside between the lines.',
    'Opponent defends with 3 centre backs and wing backs',
    'Keep the central overload between their midfield and defence while the full backs stay as deeper outlets.',
    '3-5-2', 19, 19, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielders (Koke, Correa)', 'Play inside between the lines to overload the centre'),
    (2, 'Full backs', 'Receive in deeper wide spaces, not high'),
    (3, 'Front two', 'Occupy the three centre backs')
) AS v(so, role, job);

-- 4. pp.21-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 1: Build-up Play from the Back (v 4-4-2)', 'CM drops wide to overload wide mid',
    'Against two fairly passive forwards, the centre backs have room and the central midfielders drift back toward the touchline into the space beside the forwards. This puts two of ours in the opposing wide midfielder''s zone.',
    'Two opposing forwards who don''t press hard; ball with a centre back',
    'A 2v1 on their wide midfielder lets the CM take the ball, turn unmarked and pass forward.',
    '4-4-2', 21, 22, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Godin, Gimenez)', 'Step forward with the ball; look for the dropping CM'),
    (2, 'Central midfielder (Gabi)', 'Drops back and wide into free space, receives and turns'),
    (3, 'Full back (F. Luis)', 'Stays high so their wide mid has two players to watch'),
    (4, 'Central midfielder (Saul)', 'Offers the second, central option')
) AS v(so, role, job);

-- 5. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 1: Build-up Play from the Back (v 4-4-2)', 'Wide mid jumps CM, lofted ball to FB',
    'If their wide midfielder steps up to block the dropping CM, our full back behind him is left free near the touchline.',
    'Opposing wide midfielder steps forward onto our CM, either straight away or after the CB plays into the CM',
    'The full back receives unmarked in space down the flank.',
    '4-4-2', 23, 23, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Godin)', 'Chips an aerial pass into the space for the full back, directly or after a give-and-go'),
    (2, 'Central midfielder (Gabi)', 'Pulls the wide mid up; lays the ball back to the CB if pressed'),
    (3, 'Left back (F. Luis)', 'Runs forward into the free space behind their wide mid'),
    (4, 'Other central midfielder (Saul)', 'Alternative route: receive inside and pass on to the full back')
) AS v(so, role, job);

-- 6. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 1: Build-up Play from the Back (v 4-4-2)', 'CM drops into a back three',
    'When the two opposing forwards press the centre backs actively, one central midfielder drops into the back line so we build with three.',
    'Two forwards press and squeeze the centre backs'' time on the ball',
    'Use the 3v2 to find the free player at the back, who carries or passes forward.',
    '4-4-2', 24, 24, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Gabi)', 'Drops between or beside the CBs, then passes to the free man'),
    (2, 'Free centre back (Gimenez)', 'Receives in space and moves the ball forward'),
    (3, 'Full backs', 'Stay high as outlets')
) AS v(so, role, job);

-- 7. pp.24-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 1: Build-up Play from the Back (v 4-4-2)', 'CM receives behind or between the forwards',
    'The central midfielders watch for a pocket in midfield: behind a forward who doesn''t drop after a CB-to-FB pass, or between two forwards standing flat in line.',
    'CB passes to FB and the nearest forward stays high, or the two forwards line up flat without cover',
    'The CM gets the ball unmarked, turns and drives the attack forward.',
    '4-4-2', 24, 25, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Gimenez)', 'Plays to the full back, or straight into the CM through the gap'),
    (2, 'Right back (Juanfran)', 'Passes inside to the CM behind the forward'),
    (3, 'Central midfielder (Saul / Gabi)', 'Finds the pocket, receives on the half-turn and plays forward')
) AS v(so, role, job);

-- 8. pp.25-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 1: Build-up Play from the Back (v 4-4-2)', 'Opp CM steps up, find inside wide mid',
    'When their central midfielder pushes up to shut down our CM, the passing lane to our tucked-in wide midfielder opens up, with space behind the CM who stepped up.',
    'Opposing central midfielder takes a high position on our CM',
    'Skip a line by passing straight from the back to the wide midfielder between the lines.',
    '4-4-2', 25, 25, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back / right back', 'Plays forward through the widened inside lane'),
    (2, 'Right midfielder (Correa)', 'Waits in a central position between the lines to receive and turn'),
    (3, 'Central midfielder (Saul)', 'Pulls their CM up and away')
) AS v(so, role, job);

-- 9. pp.26-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 1: Build-up Play from the Back (v 4-2-3-1)', 'Exploit space beside a lone striker',
    'With only one forward pressing, there is plenty of room either side of him. When he presses one centre back, the ball goes across to the other, who strides forward with it; or a CM drops into that space.',
    'Lone striker presses one of our centre backs',
    'The free CB carries into midfield, or the CM receives on the half-turn with no need to go wide, and looks for a forward pass.',
    '4-2-3-1', 26, 27, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressed centre back (Gimenez)', 'Passes square to the other CB'),
    (2, 'Free centre back (Godin)', 'Steps into the space, dribbles forward, picks a forward pass'),
    (3, 'Central midfielder (Gabi)', 'Opens up beside the striker, receives side-on and turns')
) AS v(so, role, job);

-- 10. pp.28-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 1: Build-up Play from the Back (v 4-3-3)', 'Lone striker plus jumping inside mids',
    'There is still space beside the single striker, but their advanced central midfielders (8/10) step up quickly onto whichever CB carries or CM receives, so the window is short.',
    'Striker presses one CB; their attacking mid jumps out',
    'Still progress through the free CB or CM, but release fast before the jumping midfielder closes in.',
    '4-3-3', 28, 29, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free centre back (Godin)', 'Receives and steps forward; must play quickly when the 10 closes'),
    (2, 'Central midfielder (Gabi)', 'Shifts across to receive; has little time, so plays early'),
    (3, 'Other centre back (Gimenez)', 'Switches across when the striker presses him')
) AS v(so, role, job);

-- 11. pp.30-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 1: Build-up Play from the Back (v 3-5-2)', 'Build out wide v 3-5-2',
    'Against a 3-5-2 we are outnumbered in midfield, but there is space outside their two forwards and even inside their half, because they have no wide midfielders. A fast switch between centre backs, or a CM drifting wide, uses it.',
    'Their two forwards are not active enough; ball with one CB',
    'The far CB carries into their half, or the wide CM receives on the half-turn and moves into their half.',
    '3-5-2', 30, 31, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Gimenez)', 'Switches play quickly to the other CB'),
    (2, 'Centre back (Godin)', 'Moves up into the wide space and dribbles into their half'),
    (3, 'Central midfielder (Gabi)', 'Moves out wide to receive, turns and drives forward')
) AS v(so, role, job);

-- 12. pp.32-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 1: Build-up Play from the Back (v 3-5-2)', 'CM drops for 3v2 v pressing pair',
    'When their two forwards press our centre backs man to man instead of guarding space, one CM drops toward the side to form a back three.',
    'Both opposing forwards press our two centre backs directly',
    'With 3v2 at the back, find the free player (the far CB or the dropped CM out wide) depending on how the forwards move.',
    '3-5-2', 32, 32, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Gabi)', 'Drops into the left-side space to make a back three'),
    (2, 'Centre backs (Gimenez, Godin)', 'Circulate the ball to whoever is free'),
    (3, 'Free player', 'Receives in space toward the side and progresses')
) AS v(so, role, job);

-- 13. pp.37-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 2: Dragging the Centre Back Out of Position to Create and Exploit Space', 'Forward drops, drags CB, FB fed high',
    'Near the box, a forward drops between the lines and their centre back follows him. The other defenders squeeze inward to cover, so their full back narrows.',
    'Their CB follows the dropping forward and their full back tucks inside',
    'Get the ball to our high full back free in a crossing position, with the CM switching after the lay-off or the forward passing straight wide (quicker, better). The full back crosses within two touches while the wide midfielders run into the gap the CB left.',
    NULL, 37, 39, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Griezmann)', 'Drops between the lines to pull the CB out; lays off, or passes straight to the full back'),
    (2, 'Central midfielder (Gabi)', 'Plays into the forward, then switches out to the full back'),
    (3, 'Left back (F. Luis)', 'Times his run high and wide; crosses early'),
    (4, 'Wide midfielders (Koke, Correa)', 'Attack the vacated CB space in the box for the cross')
) AS v(so, role, job);

-- 14. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 2: Dragging the Centre Back Out of Position to Create and Exploit Space', 'FB holds width, go through centre',
    'If their full back stays wide instead of covering behind the CB who stepped out, there is little room on the flank but a gap in the middle of their back line.',
    'CB dragged out by the dropping forward; their full back keeps his wide position',
    'After the lay-off, the CM plays a straight lofted pass for the wide midfielder running into the gap the CB left.',
    NULL, 40, 40, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Griezmann)', 'Drops, pulls the CB, lays the ball back'),
    (2, 'Central midfielder (Gabi)', 'Plays the straight aerial ball over the line into the central gap'),
    (3, 'Left midfielder (Koke)', 'Runs from inside into the space behind the CB who stepped up'),
    (4, 'Left back (F. Luis)', 'Holds their full back wide with his run')
) AS v(so, role, job);

-- 15. pp.50-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 3: Options for the Full Back After Receiving High Up the Pitch', 'FB 1-2 with forward, cross',
    'Our full back gets the ball high on the flank, but their full back is close enough to press him.',
    'Opposing full back steps out to close down our advanced full back',
    'The full back gets in behind their back line with a give-and-go and crosses.',
    NULL, 50, 51, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (F. Luis)', 'Receives from the CM, plays a one-two and runs in behind'),
    (2, 'Forward (Griezmann)', 'Comes across into support and plays the return pass first time'),
    (3, 'Left midfielder (Koke)', 'Alternative one-two partner if he is positioned higher'),
    (4, 'Central midfielder (Gabi)', 'Plays the advanced pass out to the full back')
) AS v(so, role, job);

-- 16. pp.51-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 3: Options for the Full Back After Receiving High Up the Pitch', 'Wide mid runs behind their FB',
    'With their full back stepping out to our full back, our inside wide midfielder runs into the space behind him.',
    'Opposing full back presses our full back; space behind him is open',
    'Wide midfielder receives unmarked behind and crosses with only two defenders in the box.',
    NULL, 51, 51, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (F. Luis)', 'Slides the ball in behind for the run'),
    (2, 'Left midfielder (Koke)', 'Runs outside-in behind their full back to cross'),
    (3, 'Front two', 'Attack the box against just two defenders')
) AS v(so, role, job);

-- 17. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 3: Options for the Full Back After Receiving High Up the Pitch', 'CB tracks wide mid, forward drops in',
    'When their centre back follows our wide midfielder''s run in behind, the pass to him is closed but a pocket opens where the CB was.',
    'Opposing centre back tracks the wide midfielder''s run',
    'The forward drops into the pocket, receives unmarked and either shoots or plays a final ball to one of three runners (wide mid, other forward, far-side wide mid).',
    NULL, 52, 52, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (F. Luis)', 'Passes inside to the dropping forward'),
    (2, 'Forward (Griezmann)', 'Drops into the gap the CB left, receives facing goal'),
    (3, 'Left midfielder (Koke)', 'Keeps running behind as an option'),
    (4, 'Forward (Torres)', 'Runs behind the line for the final pass'),
    (5, 'Right midfielder (Correa)', 'Arrives from the far side into the box')
) AS v(so, role, job);

-- 18. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 3: Options for the Full Back After Receiving High Up the Pitch', 'Forward runs wide, wide mid inside',
    'The roles reverse: the forward runs into the space behind their full back and their centre back follows him out wide.',
    'Opposing centre back follows the forward''s run toward the flank',
    'The wide midfielder gets the ball unmarked in the central pocket and shoots or passes to the forward or the far-side wide midfielder as they make runs into the box.',
    NULL, 53, 53, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Griezmann)', 'Runs behind their full back and pulls the CB wide'),
    (2, 'Left back (F. Luis)', 'Passes inside to the wide mid in the pocket'),
    (3, 'Left midfielder (Koke)', 'Receives in the central space vacated by the CB'),
    (4, 'Forward (Torres) and right midfielder (Correa)', 'Run into the box for the final ball')
) AS v(so, role, job);

-- 19. pp.64-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 4: Synchronised Movements of the Full Back and Wide Midfielder', 'Wide 2v1: midfielder tucks in, opposing FB stays',
    'The wide midfielder drops inside between the opponent''s lines while our full back pushes up the touchline at the same moment, so the opposing full back has two men in his zone. If he stays wide, the wide midfielder is free inside.',
    'Opposing full back does not follow the wide midfielder inside',
    'The wide midfielder takes the ball unmarked between the lines, turns and plays in behind.',
    NULL, 64, 65, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left midfielder (Koke)', 'drop into a central pocket between midfield and defence, receive, turn'),
    (2, 'Left back (F. Luis)', 'run forward together with Koke to pin the opposing full back'),
    (3, 'Central midfielder (Gabi)', 'pass into Koke''s feet between the lines'),
    (4, 'Forwards (Griezmann, Torres)', 'run in behind for the through ball'),
    (5, 'Weak-side full back (Juanfran)', 'stay high and wide for a switch')
) AS v(so, role, job);

-- 20. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 4: Synchronised Movements of the Full Back and Wide Midfielder', 'Opposing FB tracks inside, our FB free high',
    'Same tuck-in plus overlap, but this time the opposing full back follows the wide midfielder inside, which leaves the flank behind him empty for our advancing full back.',
    'Opposing full back follows the wide midfielder''s inward drop',
    'The full back gets an aerial ball high up the flank, carries it on and crosses for the forwards arriving.',
    NULL, 66, 66, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left midfielder (Koke)', 'drop inside to drag the opposing full back'),
    (2, 'Left back (F. Luis)', 'run into the vacated wide space, dribble forward, cross'),
    (3, 'Central midfielder (Gabi)', 'lofted pass over the top to the full back'),
    (4, 'Forwards', 'attack the box for the cross')
) AS v(so, role, job);

-- 21. pp.74-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 5: Forward Exploits Space Behind the Opposing Full Back', 'Centre back long ball behind high FB',
    'Our wide midfielders sit narrow and our full backs stay deep, which tempts the opposing full back to step up onto the wide midfielder and leaves space behind him. A centre back stepping out with the ball sees that space.',
    'Opposing full back steps up to mark the narrow wide midfielder',
    'A quick forward runs diagonally into the space behind the full back and takes a direct long pass.',
    NULL, 74, 75, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Godin)', 'carry the ball forward, then hit a long pass into the space behind the full back'),
    (2, 'Left midfielder (Koke)', 'stay narrow to draw the opposing full back up'),
    (3, 'Left back (F. Luis)', 'stay deep, which invites the full back to step up'),
    (4, 'Strong-side forward (Griezmann)', 'diagonal run in behind the full back')
) AS v(so, role, job);

-- 22. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 5: Forward Exploits Space Behind the Opposing Full Back', 'Bait the FB with a pass to the wide midfielder',
    'When the opposing full back is not already tight, passing to the narrow wide midfielder pulls him forward to press. The weak-side forward comes across short as a passing option, and the strong-side forward pulls the near centre back wide.',
    'Pass from the centre back into the wide midfielder draws the full back forward',
    'A layoff to the weak-side forward, then a ball into the space behind the full back, gives the strong-side forward a 1v1 because the far centre back is too far away to help.',
    NULL, 76, 76, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Godin)', 'pass into the wide midfielder'),
    (2, 'Left midfielder (Koke)', 'receive under pressure, lay inside first time'),
    (3, 'Weak-side forward (D. Costa)', 'come across short, play the ball into the space behind the full back'),
    (4, 'Strong-side forward (Griezmann)', 'drag the near centre back out, then attack the space for a 1v1, usually ending in a cross')
) AS v(so, role, job);

-- 23. pp.77-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 5: Forward Exploits Space Behind the Opposing Full Back', 'Weak-side forward turns for a 3v3',
    'Same bait pass to the wide midfielder, but the far centre back does not step out to the weak-side forward who has come short, so that forward can take the ball between the lines and face goal.',
    'Centre back does not contest the forward checking short',
    'The forward turns and slips the other forward in behind the full back, attacking 3v3 in the final third.',
    NULL, 77, 77, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left midfielder (Koke)', 'pass inside to the checking forward'),
    (2, 'Weak-side forward (D. Costa)', 'receive unmarked between the lines, turn, play the through ball'),
    (3, 'Strong-side forward (Griezmann)', 'run into the space behind the full back')
) AS v(so, role, job);

-- 24. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 5: Forward Exploits Space Behind the Opposing Full Back', 'Centre back to full back, then ground ball behind',
    'The centre back carries forward and the wide midfielder is free between the lines, which draws the opposing full back in to close him down. Instead of going direct, the centre back moves the ball wide to our full back.',
    'Opposing full back moves inside to the wide midfielder',
    'Our full back plays a ground pass into the space behind the opposing full back for the forward.',
    NULL, 78, 78, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Godin)', 'carry forward, then pass wide to the full back'),
    (2, 'Left midfielder (Koke)', 'hold the pocket between the lines to pull the full back in'),
    (3, 'Left back (F. Luis)', 'ground pass into the channel'),
    (4, 'Forward (Griezmann)', 'run onto the pass in a dangerous area')
) AS v(so, role, job);

-- 25. pp.79-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 5: Forward Exploits Space Behind the Opposing Full Back (Variation)', 'Forward drags centre back wide, midfielder attacks centre',
    'Our full back is high with the ball and the opposing full back goes to press him. The forward runs toward the touchline into the space behind that full back, and the centre back follows him out wide.',
    'Centre back follows the forward''s run toward the touchline',
    'The narrow wide midfielder runs into the gap left in the middle and takes a diagonal pass to shoot.',
    NULL, 79, 79, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (F. Luis)', 'receive high, play a diagonal pass inside'),
    (2, 'Forward (Griezmann)', 'run toward the touchline behind the full back to drag the centre back out'),
    (3, 'Left midfielder (Koke)', 'run into the central gap and shoot')
) AS v(so, role, job);

-- 26. pp.80-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 5: Forward Exploits Space Behind the Full Back with Width Created by Wide Midfielder', 'Wide midfielder gives width, finds the gap',
    'When our full back is positioned centrally, the wide midfielder goes out to the touchline to give width. When the full back is pressed, the wide midfielder drops a few yards into the gap between the opposing full back and wide midfielder.',
    'Left back on the ball is pressed by the opposing wide midfielder',
    'The wide midfielder gets time to turn. If the opposing full back closes him only after the pass, the forward runs into the space behind and takes his pass.',
    NULL, 80, 81, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (F. Luis)', 'start narrow, pass to the wide midfielder when pressed'),
    (2, 'Left midfielder (Koke)', 'hold width, drop into the gap, receive, turn, pass in behind'),
    (3, 'Forward (Griezmann)', 'run behind the full back once he steps out'),
    (4, 'Right back (Juanfran)', 'give width on the other side')
) AS v(so, role, job);

-- 27. pp.82-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 5: Forward Exploits Space Behind the Full Back with Width Created by Wide Midfielder', 'Full back marks early, long ball over',
    'The opposing full back steps up to mark the wide midfielder before any pass reaches him, so a pass to the midfielder would only see him stopped from turning, and the space behind the full back is already open.',
    'Opposing full back jumps onto the wide midfielder early',
    'Our full back skips the midfielder with a direct long pass into the space for the forward''s run.',
    NULL, 82, 82, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (F. Luis)', 'long direct pass behind the opposing full back'),
    (2, 'Left midfielder (Koke)', 'hold wide to keep the full back high'),
    (3, 'Forward (Griezmann)', 'run into the space behind the full back')
) AS v(so, role, job);

-- 28. pp.92-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 6: Forward Drops Back to Receive or Create Space in Behind', 'Forward checks short, centre back holds',
    'Once a central midfielder receives unmarked or a defender carries the ball into midfield, the forward nearest the ball drops between the lines. This forces the centre back to choose whether to follow him.',
    'Centre back stays to guard the space',
    'The dropping forward receives free, turns, and has several passing options in behind.',
    NULL, 92, 92, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-near forward (Torres)', 'drop between the lines, receive and turn'),
    (2, 'Central midfielder / defender', 'find the dropping forward'),
    (3, 'Other forward and wide players', 'make runs to offer the final pass')
) AS v(so, role, job);

-- 29. pp.93-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 6: Forward Drops Back to Receive or Create Space in Behind', 'Centre back follows, partner runs in behind',
    'The centre back follows the forward who drops off, which opens space behind him straight away. If the other forward is close enough, he attacks it.',
    'Centre back follows the forward''s drop',
    'A central midfielder plays a long aerial pass into the vacated space for the second forward.',
    NULL, 93, 93, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping forward (Torres)', 'pull the centre back out of the line'),
    (2, 'Other forward (Griezmann)', 'run into the space behind the centre back'),
    (3, 'Central midfielder (Saul)', 'lofted pass into the space')
) AS v(so, role, job);

-- 30. pp.93-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 6: Forward Drops Back to Receive or Create Space in Behind', 'Centre back presses late, play through the narrow midfielder',
    'The centre back steps out only once the pass reaches the dropping forward, to stop him turning. The forward lays it inside to the narrow wide midfielder, who is free in the central zone.',
    'Centre back closes the forward as the pass arrives',
    'The wide midfielder sends the ball into the space behind the centre back for the other forward.',
    NULL, 93, 93, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping forward (Torres)', 'lay off first time inside'),
    (2, 'Left midfielder (Koke)', 'receive between the lines, pass in behind'),
    (3, 'Other forward (Griezmann)', 'run behind the centre back who stepped out')
) AS v(so, role, job);

-- 31. pp.94-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 6: Forward Drops Back to Receive or Create Space in Behind', 'Far forward too far, wide midfielder runs',
    'The centre back follows the dropping forward, but the other forward is too far away to use the space. The near-side wide midfielder runs into it instead.',
    'Centre back follows the drop while the weak-side forward is out of range',
    'The wide midfielder gets a direct aerial pass from a central midfielder behind the centre back. A quick wide man such as Correa suits this job better than Koke.',
    NULL, 94, 94, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping forward (Torres)', 'drag the centre back out'),
    (2, 'Right midfielder (Correa)', 'run into the space behind the centre back'),
    (3, 'Central midfielder (Saul)', 'direct aerial pass to the runner'),
    (4, 'Weak-side forward (Griezmann)', 'too far away, holds his position')
) AS v(so, role, job);

-- 32. pp.95-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 6: Forward Drops Back to Receive or Create Space in Behind', 'Third-man run after the forward''s layoff',
    'The centre back waits, then presses the dropping forward, and the other forward is again too far away. The forward lays it to the narrow wide midfielder, and the far-side wide midfielder starts his run as that pass is played.',
    'Inside layoff from the forward while the centre back presses',
    'The wide midfielder on the ball finds the third-man runner behind the centre back with 1-2 touches. Players read the forward''s body shape to know who gets the layoff.',
    NULL, 95, 95, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping forward (Torres)', 'lay off first time; his half-turn shows who gets the ball'),
    (2, 'Left midfielder (Koke)', 'receive and pass in behind with 1-2 touches'),
    (3, 'Right midfielder (Correa)', 'start the run on the layoff, or receive square himself'),
    (4, 'Central midfielder (Saul)', 'first pass into the forward')
) AS v(so, role, job);

-- 33. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 7: Weak Side Forward Drops Back to Create Space in Behind', 'Weak-side forward drops, wide midfielder runs behind',
    'The lane to the strong-side forward is too narrow for a through pass, so the weak-side forward drops off as an option instead. The centre back follows him.',
    'Centre back follows the weak-side forward''s drop',
    'The wide midfielder on that side runs into the space left behind and takes a long direct pass from a central midfielder.',
    NULL, 106, 106, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side forward (Griezmann)', 'drop back to drag the centre back out'),
    (2, 'Left midfielder (Koke)', 'run into the space behind the centre back'),
    (3, 'Central midfielder (Saul)', 'long direct pass to the runner'),
    (4, 'Strong-side forward', 'tightly marked, holds the line')
) AS v(so, role, job);

-- 34. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 7: Weak Side Forward Drops Back to Create Space in Behind', 'Full back covers inside, switch to our full back',
    'After the forward drops off, the opposing full back shifts inside to close the space the wide midfielder wants to run into, which leaves the flank open.',
    'Opposing full back tucks in to cover the wide midfielder',
    'Our full back runs forward on that flank and receives a long switch from the central midfielder.',
    NULL, 107, 107, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left midfielder (Koke)', 'run inside to pull the full back in'),
    (2, 'Left back (F. Luis)', 'run forward into the open flank'),
    (3, 'Central midfielder (Saul)', 'long switch to the full back'),
    (4, 'Weak-side forward (Griezmann)', 'drop to start the movement')
) AS v(so, role, job);

-- 35. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 7: Weak Side Forward Drops Back to Create Space in Behind', 'Centre back holds, weak-side forward turns',
    'The centre back refuses to follow the weak-side forward who drops off and stays to guard the space.',
    'Centre back holds his position',
    'The forward receives unmarked between the lines, turns, and looks for a final pass to a runner.',
    NULL, 107, 107, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side forward (Griezmann)', 'receive between the lines, turn, play the final pass'),
    (2, 'Central midfielder (Saul)', 'pass into the forward''s feet'),
    (3, 'Wide midfielders / other forward', 'run in behind for the final ball')
) AS v(so, role, job);

-- 36. pp.115-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 8: Creating an Overload and Attacking Through the Centre', 'Wide midfielder moves inside for a 2v1 on the centre back',
    'The wide midfielder moves into the centre between the opponent''s lines and enters the centre back''s zone, so the centre back now has two attackers to watch and cannot step out.',
    'Central midfielder receives from the centre back',
    'If the centre back holds, the wide midfielder receives, turns, and picks a final pass to the forwards or the wide full backs.',
    NULL, 115, 116, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left midfielder (Koke)', 'move inside, receive free, turn toward goal'),
    (2, 'Central midfielder (Gabi)', 'pass into Koke in the central pocket'),
    (3, 'Forwards (Griezmann, Torres)', 'run for the final pass once Koke turns'),
    (4, 'Full backs (F. Luis, Juanfran)', 'push up near the touchlines to keep width'),
    (5, 'Other central midfielder (Saul)', 'drop back to keep a numbers advantage at the back as the full backs go')
) AS v(so, role, job);

-- 37. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 8: Creating an Overload and Attacking Through the Centre', 'Centre back steps up, first-time pass to the forward',
    'The centre back tracks the wide midfielder inside and steps up to press him, which leaves the nearby forward unmarked.',
    'Centre back steps out onto the wide midfielder',
    'The wide midfielder plays first time into the forward, who has opened up to receive behind.',
    NULL, 117, 117, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left midfielder (Koke)', 'first-time pass under pressure'),
    (2, 'Forward (Griezmann)', 'open up and take the pass in the space the centre back left'),
    (3, 'Central midfielder (Gabi)', 'forward pass into Koke')
) AS v(so, role, job);

-- 38. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 8: Creating an Overload and Attacking Through the Centre', 'Centre back steps up, link through the other forward',
    'The same centre back press on the wide midfielder, but now the other forward comes close to offer a short option.',
    'Wide midfielder pressed by the stepping centre back',
    'A combination through the second forward gets the ball to the free forward behind the centre back.',
    NULL, 117, 117, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left midfielder (Koke)', 'pass to the link player under pressure'),
    (2, 'Other forward (Torres)', 'move close to Koke, play the forward on'),
    (3, 'Forward (Griezmann)', 'receive free of marking behind the centre back')
) AS v(so, role, job);

-- 39. pp.124-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 9: Making a Run on Blind Side of Defender to Receive a Long Pass in Behind', 'Weak-side forward''s blind-side run',
    'A central midfielder gets the ball unmarked in midfield. The weak-side forward slips behind the nearest centre back''s shoulder, where that defender cannot watch both him and the ball.',
    'CM receives free with time to look up',
    'Forward is free for a moment and takes a long aerial ball in behind to shoot.',
    NULL, 124, 124, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Gabi)', 'receive unmarked, lift long ball over the line'),
    (2, 'Weak-side forward (Griezmann)', 'time the run on the CB''s blind side, stay onside'),
    (3, 'Strong-side forward', 'occupy the other CB')
) AS v(so, role, job);

-- 40. pp.130-130
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 10: Forward Creates and Exploits Space to Receive in Behind', 'Drop, drag the CB, spin behind',
    'When a central midfielder has time on the ball, a forward drops towards him. The marking centre back follows him and leaves a hole behind.',
    'CM receives with time and space; marker follows the dropping forward',
    'Forward suddenly turns back into the vacated space, takes the long aerial pass and crosses or attacks the box.',
    NULL, 130, 130, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Griezmann)', 'drop short, then sharp change of direction in behind'),
    (2, 'Central midfielder (Gabi)', 'aerial pass into the space the CB left'),
    (3, 'Other forward', 'attack the box for the cross')
) AS v(so, role, job);

-- 41. pp.131-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 10: Forward Creates and Exploits Space to Receive in Behind', 'Forward drops as full back receives',
    'As the ball reaches our full back, a forward drops to offer a pass and the centre back follows him. The forward then either peels wide into the space or, against a CB who steps tight to win the ball first, spins in behind him.',
    'Pass played to the full back; CB follows or marks aggressively',
    'Full back''s ground pass finds the forward in space wide or behind the CB, and he crosses.',
    NULL, 131, 131, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (F. Luis)', 'ground pass into the forward''s new space'),
    (2, 'Forward (Griezmann)', 'show short, read the marker, go wide or spin behind'),
    (3, 'Opposite forward and midfielders', 'fill the box for the cross')
) AS v(so, role, job);

-- 42. pp.132-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'in_possession', 'Tactical Situation 10: Getting Onside to Exploit the Space Between the Opposing Defenders', 'Get back onside, then go behind',
    'On a back pass, the opposing back line steps up together and catches both forwards offside. The ball then reaches an unmarked central midfielder who turns.',
    'Defenders squeeze up; CM gets the ball and turns between the lines',
    'Forward drops into an onside gap between the full back and the CB, then times a run onto the CM''s lofted ball, goes in and crosses to the other forward.',
    NULL, 132, 133, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Diego Costa)', 'drop onside into the FB-CB gap, run in sync with the pass'),
    (2, 'Central midfielder (Gabi)', 'turn and loft the ball behind the line'),
    (3, 'Centre back / left back (Godin, F. Luis)', 'recycle to draw the line up'),
    (4, 'Other forward (Griezmann)', 'attack the cross')
) AS v(so, role, job);

-- 43. pp.135-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_attack', 'The Transition from Defence to Attack (Positive Transition) - definition and factors', 'Positive transition stages and reads',
    'From the moment we win the ball until the opponent is reorganised: win it, secure it to a man with time, push the advanced players into space, play forward, and the target beats a man or crosses. How we do it depends on where we won it, how the forwards were set, and whether the ball is open or closed.',
    'Possession won',
    'Counter shaped by where we won it, the forwards'' starting spots and pressure on the ball.',
    NULL, 135, 136, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'secure the ball or play forward at once'),
    (2, 'Forwards', 'move into open space to receive'),
    (3, 'Target player', '1v1 and shoot (direct) or final pass/cross (indirect)')
) AS v(so, role, job);

-- 44. pp.138-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_attack', 'Transition Tactical Situation 1: Counter Attack After Winning the Ball in a Wide Position', 'Full back''s wide regain, forward goes wide',
    'Both forwards are in their normal defensive spots and the full back steps in to intercept a pass to the opposing winger. The strong-side forward moves out wide into the space while the other forward pushes up. A ball to the far forward is hard to time and the centre backs can shift across, so the wide option is preferred.',
    'Full back intercepts near the touchline',
    'Forward takes the easy pass wide and dribbles on to cross: an indirect threat.',
    NULL, 138, 140, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (F. Luis)', 'step in front of the winger, win it, pass forward'),
    (2, 'Strong-side forward (Griezmann)', 'move across to receive wide, carry, cross'),
    (3, 'Far forward (Torres)', 'push forward, attack the box')
) AS v(so, role, job);

-- 45. pp.140-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_attack', 'Transition Tactical Situation 1: Counter Attack After Winning the Ball in a Wide Position', 'Wide regain, inside pass for direct threat',
    'Instead of going straight down the line after a wide regain, the full back passes inside to a free central midfielder. From the middle he has more forward options.',
    'Free CM available inside after the wide regain',
    'CM slides the ball to the forward who has run ahead and gets in on goal: a direct threat.',
    NULL, 140, 140, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (F. Luis)', 'quick inside pass'),
    (2, 'Central midfielder (Saul)', 'receive centrally, pass forward through the gaps'),
    (3, 'Forward (Torres)', 'advance between the centre backs'),
    (4, 'Wide forward (Griezmann)', 'offer the wide option')
) AS v(so, role, job);

-- 46. pp.147-149
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_attack', 'Transition Tactical Situation 2: Counter Attack After Winning the Ball in the Centre (Direct Threat)', 'Central interception against a 3-man rest defence',
    'Against a back four, the opponent usually keeps three defenders back to handle our two forwards, and that leaves gaps between them. Our CM intercepts a centre back''s through ball in the middle with the nearest opponent far away.',
    'CM intercepts in a central area with time to pass',
    'CM picks the best of three passes: the central forward (direct threat) or the wide forward or wide midfielder (indirect).',
    NULL, 147, 149, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Saul)', 'intercept, pass forward into the gaps'),
    (2, 'Central forward (Torres)', 'run into a gap for the direct threat'),
    (3, 'Wide forward (Griezmann)', 'wide outlet'),
    (4, 'Wide midfielder (Correa)', 'push up as the far-side option')
) AS v(so, role, job);

-- 47. pp.154-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Transition Tactical Situation 3: Defensive-Minded Positioning of the Forwards', 'Defensive-minded forward pair',
    'In the 4-4-2 out of possession, both forwards help cut the space between the lines. The forward nearer the ball sits higher and the other drops deeper. When the ball goes wide, the forwards and midfield slide back and across together and keep the same distances.',
    'Opponent in possession, ball in the centre or moved wide',
    'Compact block where both forwards help defend, which shapes how later counters can start.',
    NULL, 154, 154, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side forward', 'higher, screen the centre'),
    (2, 'Far forward', 'deeper, close the space between the lines'),
    (3, 'Midfield four', 'slide across with the forwards, keep the spacing')
) AS v(so, role, job);

-- 48. pp.155-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_attack', 'Transition Tactical Situation 3: Defensive-Minded Positioning of the Forwards', 'Strong-side forward attacks space behind full back',
    'With the forwards sitting deep, the strong-side forward is the target when we win the ball, whether a full back wins it wide or a centre back wins it centrally. The free space is wide, behind the opposing full back.',
    'Regain while both forwards are in defensive positions',
    'Forward moves across and forward to receive, takes on the covering CB and crosses to runners: an indirect threat.',
    NULL, 155, 156, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (F. Luis or Godin)', 'early forward pass into the wide space'),
    (2, 'Strong-side forward (Griezmann)', 'run into the space behind the FB, beat the CB, cross'),
    (3, 'Other forward and midfielders', 'run into the box')
) AS v(so, role, job);

-- 49. pp.157-157
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'out_of_possession', 'Transition Tactical Situation 3: Counter Attack-Minded Positioning of the Forwards', 'One forward left high for counters',
    'Often, and especially with Diego Costa playing, one forward stays very high while only the other (Griezmann) helps defend. The opponent gets more room between our forward and midfield lines.',
    'Coach chooses counter-minded set-up',
    'Advanced forward stays near goal, ready to receive and attack directly the moment the ball is won.',
    NULL, 157, 157, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advanced forward (Diego Costa)', 'stay high near the opposing CBs'),
    (2, 'Second forward (Griezmann)', 'track back and help the midfield'),
    (3, 'Midfield four', 'cover the extra space between the lines')
) AS v(so, role, job);

-- 50. pp.158-161
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_attack', 'Transition Tactical Situation 3: Counter Attack-Minded Positioning of the Forwards', 'Counter-minded wide regain: find the high forward',
    'With the forwards set for counters, a full back wins it wide. The usual outlet (the deeper forward) is covered because the opposing full back can recover. So the full back tries the harder ball into the gap between the centre backs, or behind the far CB''s blind side if that CB has closed the gap. A better route is often a quick inside pass to a free CM, who finds the forward more easily.',
    'Full back wins it wide; deeper forward covered',
    'High forward receives between or behind the CBs: a direct threat, but only if the pass is precise.',
    NULL, 158, 161, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (F. Luis)', 'accurate ball into the centre, or quick inside pass'),
    (2, 'Advanced forward (Diego Costa)', 'use the gap between the CBs or run on the blind side'),
    (3, 'Central midfielder (Rodri)', 'free man inside, plays the forward in'),
    (4, 'Deeper forward (Griezmann)', 'wide option, likely covered')
) AS v(so, role, job);

-- 51. pp.162-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_attack', 'Transition Tactical Situation 3: Counter Attack-Minded Positioning of the Forwards', 'Counter-minded central regain: in behind at once',
    'A central midfielder intercepts in the middle and carries forward while the advanced forward is already high. The forward goes at once into the gap between the centre backs, or, if one CB closes that gap, runs on his blind side into the open space.',
    'CM intercepts in the centre with the high forward set',
    'CM plays the forward through and he gets in on goal: the most effective version of the counter-minded set-up.',
    NULL, 162, 164, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Rodri)', 'intercept, carry, slide the pass through'),
    (2, 'Advanced forward (Diego Costa)', 'attack the gap or the blind side, then shoot'),
    (3, 'Second forward (Griezmann)', 'support run')
) AS v(so, role, job);

-- 52. pp.171-173
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_attack', 'Transition Tactical Situation 4: Counter Attack with an Open Ball Situation', 'Open ball: both forwards run',
    'A central midfielder wins the ball and nobody is pressing him, so he has time to pass forward. Both forwards immediately sprint into space: one near the touchline and one between the two centre backs.',
    'Ball winner unpressed (open ball)',
    'Accurate forward pass: the wide forward gives a cross (indirect threat), the central one gets a shot (direct threat).',
    NULL, 171, 173, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Saul)', 'win it, look up, pass forward'),
    (2, 'Forward (Griezmann)', 'run into the space by the touchline'),
    (3, 'Forward (Diego Costa)', 'run between the CBs (or the CB-FB gap if a CB narrows)')
) AS v(so, role, job);

-- 53. pp.174-175
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_attack', 'Transition Tactical Situation 4: Role of the Midfielders During a Counter Attack with an Open Ball Situation', 'Narrow wide midfielders join the counter',
    'Atletico''s midfielders defend narrow and compact, so the central or wide midfielders win the ball and make the first pass. When the ball goes wide to a forward, the weak-side wide midfielder runs into the box and the strong-side one gives back-pass support. CMs and defenders push up behind.',
    'Open-ball counter with the ball played to a wide forward',
    'Box filled for the cross, a cutback outlet, and a compact team ready to stop a clearance.',
    NULL, 174, 175, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side wide midfielder (Correa)', 'run into the box to finish'),
    (2, 'Strong-side wide midfielder (Koke)', 'support behind the ball carrier for a back pass'),
    (3, 'Wide forward (Griezmann)', 'carry and cross'),
    (4, 'Central midfielders and back four', 'step up to stay compact behind the attack')
) AS v(so, role, job);

-- 54. pp.180-182
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_attack', 'Transition Tactical Situation 5: Counter Attack with a Closed Ball Situation', 'Closed ball: show short, then release',
    'The ball winner is pressed at once, so forward passes are blocked. Instead of running long, the forwards and nearby teammates move into open passing lanes for short passes. The ball goes to the deeper forward if he is free.',
    'Ball winner pressed straight after the regain (closed ball)',
    'Forward receives and turns, which makes an open ball. Then the other advanced players sprint into the space behind.',
    NULL, 180, 182, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Saul)', 'keep it, pick the pass that leaves the most opponents behind'),
    (2, 'Deeper forward (Diego Costa)', 'show in the lane, receive and turn'),
    (3, 'Other forward and wide midfielder (Griezmann, Correa)', 'once he turns, run into the space behind'),
    (4, 'Nearby teammates', 'give short options to secure the ball')
) AS v(so, role, job);

-- 55. pp.183-184
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_attack', 'Transition Tactical Situation 5: Counter Attack with a Closed Ball Situation', 'Pinned forward lays off to free man',
    'The forward receives the first pass but a centre back is on his back and he cannot turn. The nearest midfielders move into support so he can lay the ball off to one of them.',
    'Forward receiving with his back to goal is pressed',
    'Lay-off gives an open ball. As soon as the midfielder can play forward, the runners attack behind for an indirect (wide cross) or direct (between the CBs) threat.',
    NULL, 183, 184, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Diego Costa)', 'hold, lay off to the free supporter'),
    (2, 'Central midfielder (Thomas)', 'support angle, receive free, pass forward'),
    (3, 'Wide midfielder (Correa)', 'support, then run between the CBs'),
    (4, 'Other forward (Griezmann)', 'run wide in behind, carry and cross')
) AS v(so, role, job);

-- 56. pp.190-191
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_attack', 'Transition Tactical Situation 6: Exploiting Width During a Counter Attack', 'Full back runs into the wide space',
    'After we win the ball in the centre, the opponent presses it and their wide midfielders tuck in to block passes to our forwards. Our narrow wide midfielders cannot reach the touchline in time, so the full back bursts up the empty flank.',
    'Central regain, closed ball, opposition midfield squeezed narrow',
    'CM switches to the full back on the run, who crosses early into the space between the defenders and the keeper for a forward arriving.',
    NULL, 190, 191, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Gabi)', 'find the overlapping full back'),
    (2, 'Right back (Juanfran)', 'sprint forward, carry, early cross from deep'),
    (3, 'Forwards (Griezmann, Torres)', 'attack the space in front of the keeper')
) AS v(so, role, job);

-- 57. pp.192-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'diego-simeone-attacking-tactics-tactical-analysis-and-sessions-from-atl-tico-mad'), 'to_attack', 'Transition Tactical Situation 6: Exploiting Width During a Counter Attack', 'Full back finds wide midfielder behind',
    'The full back has carried forward wide but does not cross. He passes into the path of the wide midfielder, who runs behind the opposing full back, and that pulls the near centre back out wide.',
    'Full back advanced wide; opposing CB has to cover outside',
    'More room in the box: the wide midfielder crosses and a forward finishes at the near post.',
    NULL, 192, 192, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Juanfran)', 'pass into the wide midfielder''s run'),
    (2, 'Right midfielder (Correa)', 'run behind the FB, drag the CB, cross'),
    (3, 'Forward (Torres)', 'attack the near post'),
    (4, 'Other forward', 'occupy the far side of the box')
) AS v(so, role, job);

COMMIT;
