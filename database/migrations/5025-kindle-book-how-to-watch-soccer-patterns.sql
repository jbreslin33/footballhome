-- 5025 📚 Coaching book patterns: "How to Watch Soccer" (Ruud Gullit,
-- Penguin) — Kindle library (spreads s001–s127 from Kindle Cloud Reader).
-- Every spread read; each concrete team behaviour Gullit explains written up
-- in OUR OWN WORDS, naming the team / coach where given, with who does what.
-- Memoir, money, media and culture chapters left out.  Owner's personal
-- library.  (James 11/27 Kindle picks)
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    method_note = 'Ruud Gullit''s guide to reading a match, drawn from his career under Cruyff at Feyenoord, at PSV, in Sacchi''s Milan and as Chelsea player-manager: how to watch a game (with modern examples such as Leicester 2015/16, Di Matteo''s Chelsea 2012 and pressing Barcelona), dead balls (walls, free kicks, corners, kickoff), systems (4-4-2, 3-4-3, 4-3-3, 5-3-2/3-5-2, 4-2-3-1 and how each is beaten), and positions from keeper to strikers, including inverted wingers and the false nine. Patterns are the on-pitch behaviours he explains, in our words; memoir, culture, money and media chapters left out. Kindle edition: page numbers are screen spreads.'
WHERE slug = 'kindle-how-to-watch-soccer';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer');

-- 1. pp.7-7
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Foreword', 'Keep the ball, don''t dribble in tight areas',
    'Barcelona vs Atletico 2015/16 CL: forwards kept dribbling into a packed, confined zone and lost the ball. The author''s fix is one- or two-touch circulation at tempo, waiting for space to open.',
    'Opponent defends compact and deep',
    'Avoid losing the ball and fouls; create the gap by patience rather than solo runs.',
    NULL, 7, 7, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front three', 'Release in one or two touches instead of dribbling into traffic'),
    (2, 'Midfielders', 'Keep circulating at pace, wait for space')
) AS v(so, role, job);

-- 2. pp.7-7
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Foreword', 'Plan B: tall centre back as target',
    'Barcelona pushed centre back Pique up front and played long high balls to him when Plan A failed; it was unrehearsed and teammates barely supplied him.',
    'Chasing the game, combination play not working',
    'Switch to direct aerial service; works only if practised.',
    NULL, 7, 7, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Tall centre back (Pique)', 'Move up as emergency target man'),
    (2, 'Full backs / midfielders', 'Deliver long high balls into him')
) AS v(so, role, job);

-- 3. pp.7-7
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Foreword', 'Push a spare back-three defender forward',
    'PSG switched to 3-5-2 vs Manchester City who played one striker (Aguero); City pressed the three defenders and PSG had no depth. The fix: two centre backs are enough against one striker, so the third steps into midfield to add structure.',
    'Opponent plays a lone striker against our back three',
    'Gain an extra midfielder and connect play to the striker instead of isolating him.',
    NULL, 7, 7, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Spare centre back', 'Step forward into midfield'),
    (2, 'Other two centre backs', 'Handle the lone striker 2v1'),
    (3, 'Striker (Ibrahimovic)', 'Gets support instead of being marooned')
) AS v(so, role, job);

-- 4. pp.7-7
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Foreword', 'Press a back three with front players',
    'Manchester City attacked PSG''s makeshift back three with sustained pressure, exploiting players unfamiliar with the shape.',
    'Opponent builds from an unfamiliar back three',
    'Force errors in the first line and take control.',
    '3-5-2', 7, 7, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker and attacking midfielders', 'Pile pressure on the three defenders'),
    (2, 'Midfield', 'Cut supply to the isolated striker')
) AS v(so, role, job);

-- 5. pp.9-10
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Feyenoord / Cruijff', 'Defensive full back as rest-defence anchor',
    'Cruijff''s Feyenoord (1983/84) used left back Stanley Brard mainly as an organiser when the ball was lost; he did little in possession but cleaned up on turnovers, letting Cruijff rest.',
    'Possession lost',
    'Keep the team organised behind a creative core that doesn''t defend.',
    NULL, 9, 10, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Brard)', 'Stay balanced, organise and clean up on loss'),
    (2, 'Playmaker (Cruijff)', 'Freed from defensive duty')
) AS v(so, role, job);

-- 6. pp.9-10
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Feyenoord / Cruijff', 'Pure winger holds width in 4-3-3',
    'Under Cruijff at Feyenoord the outside right''s job was to stay wide on the touchline, stretch the play and supply crosses, combining with the right midfielder (Hoekstra) who ran into the box.',
    'Team in possession',
    'Width creates space and chances for runners.',
    NULL, 9, 10, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside right (Gullit)', 'Hug the touchline, cross and create'),
    (2, 'Right midfielder (Hoekstra)', 'Keep arriving in front of goal to meet passes')
) AS v(so, role, job);

-- 7. pp.10-10
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'From Feyenoord to PSV', 'Winger drifts, full back overlaps and crosses',
    'PSV: outside right Van der Gijp opened space by leaving the flank, and right back Gerets ran up the touchline to cross; Gerets also closed the defensive gap the winger left.',
    'Winger vacates the flank / ball on the right',
    'Pair complementary right-side players so space is always used and covered.',
    NULL, 10, 10, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Gerets)', 'Overlap into vacated space and cross; cover the winger''s gap'),
    (2, 'Outside right (Van der Gijp)', 'Move off the line to create space, time passes for the overlap')
) AS v(so, role, job);

-- 8. pp.11-11
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Every corner of the pitch', 'Centre back steps into midfield, midfielder covers',
    'PSV in 4-4-2: central defender Gullit carried the ball into midfield and on into attack, while midfielder Van de Kerkhof dropped into the gap.',
    'Space in front of the centre back',
    'Add a man to the attack while keeping midfield and back-line balance.',
    NULL, 11, 11, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central defender', 'Step out with the ball into midfield/attack'),
    (2, 'Holding midfielder (Van de Kerkhof)', 'Drop to fill the defender''s gap')
) AS v(so, role, job);

-- 9. pp.12-12
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'The Milan puzzle', 'Right-side passing triangles',
    'At Milan the striker (Van Basten), right back (Tassotti) and midfielder (Rijkaard) stayed close and combined in triangles, very hard to defend however well prepared.',
    'Ball on the right side',
    'Play through pressure with short combinations.',
    NULL, 12, 12, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Van Basten)', 'Stay connected, offer the third angle'),
    (2, 'Right back (Tassotti)', 'Join as base of the triangle'),
    (3, 'Midfielder (Rijkaard)', 'Short support and combination')
) AS v(so, role, job);

-- 10. pp.12-12
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_attack', 'The Milan puzzle', 'Lure them out, surge down the touchline',
    'Opponents sat deep against Milan; Milan tempted them forward, then on winning the ball the right midfielder sprinted deep down the flank and crossed to the advancing strikers.',
    'Opponent drawn out, ball won',
    'Attack the space behind with fast flank runs and early crosses.',
    NULL, 12, 12, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfielder (Gullit)', 'Burst deep down the touchline, cross'),
    (2, 'Strikers (Van Basten / Virdis)', 'Advance into the box to meet the cross')
) AS v(so, role, job);

-- 11. pp.12-13
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Training for crosses', 'Whipped cross ahead of the striker',
    'In a 4-3-3 that plays in the opponent half, space is short, so the winger must cross without beating his man: a curled ball in front of the defender''s leg (Bananenflanke), struck with the inside of the foot halfway up, landing just ahead of the striker''s run.',
    'Winger in crossing zone without space to beat his man',
    'Deliver a timed cross the striker meets at full speed.',
    NULL, 12, 13, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'Curl the cross early past the defender''s leg, weighted ahead of the runner'),
    (2, 'Centre forward (Houtman)', 'Rehearsed run timed to meet it')
) AS v(so, role, job);

-- 12. pp.13-13
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Forward runs', 'Near-post dummy, far-post delivery',
    'Crossing and finishing runs must be automatic: if the striker dummies to the near post, the cross goes far, and vice versa. Near-post crosses tighter and lower, far-post with more power and height over the centre backs.',
    'Winger about to cross',
    'Shake markers and make the cross unpredictable for defenders.',
    NULL, 13, 13, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'Dummy run to one post, attack the other'),
    (2, 'Crosser', 'Read the run, vary pace and height by target post')
) AS v(so, role, job);

-- 13. pp.13-13
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Forward runs', 'Third-man run after a feint',
    'At Milan, Maldini or Ancelotti played into Van Basten, who set back to Albertini; meanwhile the right-sided player dragged his marker toward Albertini, then spun away deep to receive the ball into space.',
    'Striker receives with back to goal',
    'Release a runner in behind via a lay-off and through ball.',
    NULL, 13, 13, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender / midfielder (Maldini, Ancelotti)', 'Play into the striker'),
    (2, 'Striker (Van Basten)', 'Lay off to the midfielder'),
    (3, 'Midfielder (Albertini)', 'Feed the ball into space'),
    (4, 'Right-sided runner (Gullit)', 'Feint toward the ball, then sprint deep')
) AS v(so, role, job);

-- 14. pp.13-15
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_defend', 'Switching roles after losing possession', 'Instant role switch on losing the ball',
    'Milan drilled every player to know his defensive job the moment possession was lost mid-attack, and to sprint straight back after a missed chance instead of standing still, before the keeper can launch a counter.',
    'Ball lost or chance missed',
    'Re-form the organised team before the counter starts.',
    NULL, 13, 15, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'No pause after a miss: run back to position'),
    (2, 'Midfielders (Ancelotti, Albertini)', 'Swap to defensive positions automatically'),
    (3, 'Defenders (Baresi)', 'Organise and call players back')
) AS v(so, role, job);

-- 15. pp.14-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Rule 1: Never lose possession in the center when building an attack', 'No risky central build-up; go long',
    'Milan rule: never lose the ball centrally in build-up. Triangle passes between centre backs and keeper are too risky; if everyone is marked, go back to the keeper who kicks long for the strikers to fight for.',
    'Build-up options marked',
    'Avoid conceding from a central turnover.',
    NULL, 14, 14, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Don''t force central passes under pressure'),
    (2, 'Goalkeeper', 'Kick long into the other half'),
    (3, 'Strikers', 'Compete for the long ball')
) AS v(so, role, job);

-- 16. pp.14-14
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Rule 2: Never let the other side attack through the center', 'Force play wide, touchline as defender',
    'Milan rule: forwards steer the opponent''s attack to the flanks, where the touchline acts as an extra defender and the ball is easier to win; the centre is where you get outflanked.',
    'Opponent in possession',
    'Win the ball in wide areas, protect the middle.',
    NULL, 14, 14, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Angle runs to show play outside'),
    (2, 'Wide midfielders / full backs', 'Trap and close down against the touchline')
) AS v(so, role, job);

-- 17. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Pressure', 'Let them start, pounce in midfield',
    'Milan gave the opponent space to begin from a full back, then, when the ball was played into midfield, all ten pounced to win it; pressing too early just sent the ball back to the keeper (back-pass pick-up rule pre-1992). They also lured opponents to the touchline and piled pressure there.',
    'Pass into midfield / ball near the touchline',
    'Regain the ball in midfield with the whole compact block.',
    NULL, 16, 16, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two', 'Allow build-up via a full back, then show it inside to midfield'),
    (2, 'Midfield four', 'Jump on the receiver'),
    (3, 'Back four', 'Squeeze up behind')
) AS v(so, role, job);

-- 18. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'How to beat the wall', 'Compact block within five metres',
    'Milan trained pressing while staying within about five metres of each other and practised a high offside line (eleven vs seven defenders), so opponents could not get through even with through balls.',
    'Opponent in possession',
    'Leave no space between players; trap runners offside.',
    NULL, 16, 16, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four (Baresi, Galli/Costacurta, Maldini, Tassotti)', 'Hold and step a coordinated offside line'),
    (2, 'Midfielders (Ancelotti, Rijkaard)', 'Stay tight to the back line')
) AS v(so, role, job);

-- 19. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'How to beat the wall', 'Quick combinations against a packed defence',
    'As opponents dug in deeper against Milan, they trained 11v11 on a half pitch no wider than the box: there is no room to dribble, so decisions and combinations must be instant.',
    'Opponent in deep low block',
    'Unlock a crowded box through fast one-touch play.',
    NULL, 16, 16, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attackers', 'Decide instantly, combine rather than dribble'),
    (2, 'Midfielders', 'Constant short support')
) AS v(so, role, job);

-- 20. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Creativity in attack', 'Winger in, midfielder bounces, full back third',
    'The stock rotation every youth player learns: right winger comes inside, meets an opponent and plays back to the right midfielder, and the right back runs on as third man. Gullit says creative players must break this predictable pattern.',
    'Ball to the right winger facing a marker',
    'Free the overlapping full back, or surprise with an unexpected variation.',
    NULL, 16, 16, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger', 'Cut inside, lay back'),
    (2, 'Right midfielder', 'Receive and release'),
    (3, 'Right back', 'Overlap as the third man')
) AS v(so, role, job);

-- 21. pp.19-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'set_piece', 'English grass', 'Long grass corners and towel throw-ins',
    'Tranmere (1998/99) let corner grass grow; their centre backs cleared into the corners where the ball died, and from there they crossed or took long throw-ins into the box, even drying balls for extra run-up.',
    'Defensive clearance / throw-in near the corner',
    'Turn clearances into territory and box deliveries.',
    NULL, 19, 19, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Clear into the opponent''s corners'),
    (2, 'Long-throw taker', 'Hurl throw-ins to the penalty spot')
) AS v(so, role, job);

-- 22. pp.19-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Rocket man', 'Winger tracks attacking full back',
    'Netherlands vs Germany, Euro 92: Michels ordered right winger Gullit to shadow attacking left back Frontzeck everywhere, nullifying the German''s forward runs at the cost of his own attack.',
    'Opponent full back keeps bombing on',
    'Neutralise the overlapping full back.',
    NULL, 19, 19, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Gullit)', 'Man-mark the left back the whole way'),
    (2, 'Opponent left back (Frontzeck)', 'Kept busy and pinned')
) AS v(so, role, job);

-- 23. pp.20-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Manager', 'Go direct to beat a possession side',
    'Chelsea vs Van Gaal''s Ajax 4-3-3: play the ball to target striker Mark Hughes and keep midfielders running forward, because Ajax midfielders hated running back toward their own goal.',
    'Opponent is a possession side that pushes up',
    'Make their midfield defend facing its own goal.',
    '4-3-3', 20, 20, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target striker (Hughes)', 'Win and hold up long balls'),
    (2, 'Central midfielders', 'Keep running forward beyond him')
) AS v(so, role, job);

-- 24. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Building a team', 'Build from the back, ball to feet',
    'Gullit''s Chelsea replaced long balls from left back Le Saux to winger/striker with playing out from the back to possession players like Poyet and Wise, with right back Petrescu covering the whole flank.',
    'Ball with the full back or centre back',
    'Feed possession midfielders to feet instead of hitting long.',
    NULL, 21, 21, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left back (Le Saux)', 'Pass into midfield feet, not long'),
    (2, 'Possession midfielders (Poyet, Wise)', 'Show to receive and circulate'),
    (3, 'Right back (Petrescu)', 'Cover the whole flank up and down')
) AS v(so, role, job);

-- 25. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Two ways to win', 'Lock the midfield after 1-0',
    'Mourinho''s Chelsea 2014/15: once 1-0 up, he added an extra defender (Zouma) into midfield to close the game down.',
    'Taking a one-goal lead',
    'Protect the lead by shutting central space.',
    NULL, 23, 23, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Extra defender in midfield (Zouma)', 'Screen in front of the back four'),
    (2, 'Attackers', 'Fewer risks')
) AS v(so, role, job);

-- 26. pp.25-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Cause and effect', 'Support the ball carrier early',
    'Barkley kept losing the ball by running too long; the cause was teammates not offering options. An experienced partner (Barry) should give an easy pass and tell him to release.',
    'Teammate carrying the ball',
    'Shorter carries, fewer turnovers.',
    NULL, 25, 25, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-carrying midfielder', 'Release early to the easy option'),
    (2, 'Nearby midfielder', 'Offer the angle and coach the release')
) AS v(so, role, job);

-- 27. pp.26-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Decisive moments', 'Let them dominate, counter on error',
    'Chelsea at Anfield, April 2014: Chelsea sat in an airtight block, let Liverpool have the ball and pounced on a mistake (Gerrard''s slip, Ba scores). Liverpool needing only a draw should instead have stayed compact and handed Chelsea the initiative.',
    'Opponent must win and pushes forward',
    'Concede possession safely and strike on the turnover.',
    NULL, 26, 27, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Stay deep and organised'),
    (2, 'Midfield', 'Screen, wait calmly'),
    (3, 'Striker (Ba)', 'Pounce on any loose ball')
) AS v(so, role, job);

-- 28. pp.27-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_attack', 'The power of goals', 'Counter a side chasing an equaliser',
    'A side that falls behind late throws everyone forward and loses its organisation; a quick counter then often yields another goal. Conversely, the leader often panics, kicks away clearances and loses its forward outlet.',
    'Late in game, opponent committed forward',
    'Exploit lost organisation, keep a forward outlet.',
    NULL, 27, 28, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strikers', 'Stay available upfield rather than all defending'),
    (2, 'Midfielders', 'Play forward quickly on the regain'),
    (3, 'Leaders on the pitch (Terry, Keane, Baresi)', 'Keep shape and calm in the final minutes')
) AS v(so, role, job);

-- 29. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Dominating the game', 'Run between the lines, someone goes deep',
    'The best chance comes from moving forward fast with players weaving between the lines who show to receive, while another runs in behind to open the defence; the common pattern is pass to the deepest player, set to an arriving player, through ball to a runner.',
    'Defence and midfield lines separated',
    'Penetrate quickly before the defence organises.',
    NULL, 28, 28, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder', 'Find space between the lines, show to receive'),
    (2, 'Striker', 'Make the deep run'),
    (3, 'Arriving midfielder', 'Play the third pass in behind')
) AS v(so, role, job);

-- 30. pp.29-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Counterattacking', 'Chase the second goal, even with ten',
    'Gullit''s Milan dropped Italian 1-0 lock-down orthodoxy and kept attacking for a second and third goal; vs Como (1988) down to ten men they kept going forward and won 5-0.',
    'Leading 1-0 (or down a man)',
    'Kill the game by scoring again rather than defending the lead.',
    NULL, 29, 29, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfielder (Gullit)', 'Keep attacking down the flank'),
    (2, 'Whole team', 'Stay compact while pushing on')
) AS v(so, role, job);

-- 31. pp.29-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_attack', 'Counterattacking', 'Deep block, fast forwards between lines',
    'Leicester 2015/16 (Ranieri): airtight defence that let opponents think they dominated, defenders comfortable in their own box with little space behind; on the regain Vardy and Mahrez raced into gaps between the opponent''s lines, supported by Drinkwater and Kante.',
    'Ball won from a confident, committed opponent',
    'Hurt them in the space they left behind.',
    NULL, 29, 29, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Defend deep in the box, no space behind'),
    (2, 'Ball-winners (Kante, Drinkwater)', 'Win it and release fast'),
    (3, 'Striker (Vardy)', 'Sprint into space behind'),
    (4, 'Creator (Mahrez)', 'Run between lines')
) AS v(so, role, job);

-- 32. pp.29-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_attack', 'Counterattacking', 'Three passes to the striker''s run',
    'Wenger''s early Arsenal (Seaman, Adams, Keown, Petit, Vieira, Henry) could reach the other end in three passes, a system built around Henry''s pace with Bergkamp''s vision.',
    'Possession regained deep',
    'Score within a few passes before the defence recovers.',
    NULL, 29, 29, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielders (Vieira, Petit)', 'Win and play forward first time'),
    (2, 'Second striker (Bergkamp)', 'Thread the pass'),
    (3, 'Striker (Henry)', 'Run in behind at speed')
) AS v(so, role, job);

-- 33. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Move and countermove', 'Leave the attacking full back, crowd the ball side',
    'Real (Marcelo) and Bayern (Alaba) build right then finish left through their attacking left back. Opponents can leave him to build from deep, keep players concentrated where the ball is and organised near goal, since the right winger or striker becomes the final link.',
    'Opponent builds through an attacking left back',
    'Neutralise the attack at its final link and take the sting out.',
    NULL, 30, 30, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive block', 'Concentrate around the ball, stay organised near goal'),
    (2, 'Defenders facing the right winger/striker', 'Close the final link')
) AS v(so, role, job);

-- 34. pp.30-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'How to watch defenders', 'Watch the runner, not just the ball',
    'Poor defenders fixate on the ball on the wing while the danger is the forward running at goal. Good ones (Chiellini) keep checking strikers'' movement and stay in physical contact with their man.',
    'Ball wide, striker moving into the box',
    'Minimise the danger of the runner; never be a ball-watcher.',
    NULL, 30, 31, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Chiellini)', 'Keep contact with the striker, scan his movement'),
    (2, 'Far-side defender', 'Track runners into the box, not the ball')
) AS v(so, role, job);

-- 35. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Naive defending', 'Keeper goes long when defenders marked',
    'Dutch sides take needless build-up risks; Neuer and Schmeichel never passed to a marked defender, instead sending it long toward the strikers.',
    'Defenders marked at a goal kick or back pass',
    'Avoid turnovers in front of goal; turn possession into territory.',
    NULL, 31, 31, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Play long over the press'),
    (2, 'Strikers', 'Contest the long ball')
) AS v(so, role, job);

-- 36. pp.31-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'The art of defending', 'Box defence and break vs a stronger side',
    'Di Matteo''s Chelsea in the 2012 CL semi vs Barcelona dug in around their own box, then gambled on one or two breaks; goals from Ramires and Torres won it.',
    'Facing a much stronger possession side',
    'Survive behind the ball and score on rare breaks.',
    NULL, 31, 32, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Defend the box, no space behind'),
    (2, 'Midfield', 'Sit in front, block passing lanes'),
    (3, 'Forwards (Torres, Ramires)', 'Break on the counter')
) AS v(so, role, job);

-- 37. pp.31-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Naive defending', 'High press on Barcelona''s centre backs',
    'Combative plan vs Barcelona: compact, harass in one-v-ones, never pass in front of your own goal. Celta (2015) sent forwards to press Barcelona''s centre backs, covered passing lanes into midfield and exposed Pique''s weak build-up.',
    'Barcelona centre back on the ball',
    'Deny time and passes to midfield, force errors.',
    NULL, 31, 32, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Press the centre backs immediately'),
    (2, 'Midfielders', 'Cover passing lanes to Barcelona''s midfield'),
    (3, 'Defenders', 'Clear, no short passing in front of goal')
) AS v(so, role, job);

-- 38. pp.32-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_attack', 'Adapting to your opponent', 'Entice them, then come down on the break',
    'Ferguson''s Manchester United (Keane captain), and Hiddink''s PSV 2002-06 vs Ajax: let the opponent believe they had a chance, give them space and the ball, then counter decisively when they left the gate open (PSV via Van Nistelrooy, later Kezman).',
    'Opponent commits players while dominating the ball',
    'Exploit the space behind a possession side.',
    NULL, 32, 32, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defence and keeper (Gomes, Alex)', 'Stay secure, concede no chances'),
    (2, 'Midfield (Cocu, Van Bommel)', 'Absorb then release quickly'),
    (3, 'Striker (Van Nistelrooy)', 'Exploit space behind')
) AS v(so, role, job);

-- 39. pp.32-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Adapting to your opponent', 'Wingers cross to near-post headers',
    'Classic Ajax attacked from the flanks with crosses for strong-heading strikers (Kieft, Bosman) who moved automatically to the near post. Modern inverted wingers (left-footer on the right) cut in and combine instead.',
    'Winger in crossing position',
    'Score from flank crosses with a headed finish.',
    NULL, 32, 32, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'Cross from the flank'),
    (2, 'Centre forward (Kieft, Bosman)', 'Attack the near post')
) AS v(so, role, job);

-- 40. pp.32-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_defend', 'Naive defending', 'Pressure in their half and chase on loss',
    'Barcelona keep opponents under constant pressure both ways: combining in the opponent half when they have the ball and hunting the ball there immediately when they lose it.',
    'Possession lost in the opponent half',
    'Win it back high before the opponent escapes.',
    NULL, 32, 33, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Chase immediately after losing it'),
    (2, 'Midfielders', 'Close down the nearest options'),
    (3, 'Defenders', 'Push up to support')
) AS v(so, role, job);

-- 41. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Individual class', 'High press plus quick short positional play',
    'Luis Enrique''s Barcelona kept the system intact when Messi was out: forward pressure by defenders and midfielders, quick short positional passing and high possession, with Neymar taking the decisive role.',
    'Team in possession / out of possession high',
    'System, not one star, keeps the team winning.',
    NULL, 33, 33, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders and midfielders', 'Press forward'),
    (2, 'Midfield', 'Quick short positional play, keep the ball'),
    (3, 'Neymar / Suarez', 'Decisive man and focal point')
) AS v(so, role, job);

-- 42. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Balance in a team', 'Late acceleration in the final 15 minutes',
    'Ferguson''s Manchester United built on a stable back line and axis, often striking in the last quarter hour by raising the pace when opponents tired, with several clinical forwards.',
    'Final 15 minutes, opponent tiring',
    'Win games late by increasing tempo.',
    NULL, 34, 34, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield axis (Scholes)', 'Lift tempo'),
    (2, 'Forwards (Yorke, Cole, Solskjaer, Sheringham)', 'Take the one chance'),
    (3, 'Back line (Ferdinand, Vidic)', 'Stay stable behind')
) AS v(so, role, job);

-- 43. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'set_piece', 'The wall', 'Setting the free-kick wall',
    'The keeper sets the wall; tall players go in the centre and shorter ones at the ends, since most balls go between the first and second or second and third man. Four is normal, five near the box edge forcing the shot to the keeper''s corner; leave a one-player gap only if the keeper insists on seeing the ball.',
    'Free kick against near the box',
    'Block the direct shot and channel it to the keeper.',
    NULL, 36, 36, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Positions the wall and covers the open corner'),
    (2, 'Tall players', 'Centre of the wall'),
    (3, 'Shorter players', 'Ends of the wall')
) AS v(so, role, job);

-- 44. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'set_piece', 'Free-kick specialists', 'Free kick under or over the wall',
    'Takers fire the ball under a wall told to jump; most prefer about 20 metres out, and moving it slightly back gives room to dip it in under the bar (Van Hooijdonk). Keepers must hold position rather than guess.',
    'Direct free kick around 20 m',
    'Beat a well-set wall and keeper.',
    NULL, 36, 36, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free-kick taker', 'Read the wall''s jump; shoot under or dip over'),
    (2, 'Goalkeeper', 'Hold position until the strike')
) AS v(so, role, job);

-- 45. pp.36-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'set_piece', 'The corner', 'Short corner pulls defenders out',
    'Two players at the corner plus one on the box edge for a direct pass force two or three defenders out of the crowded box, making it easier to head the eventual cross.',
    'Attacking corner',
    'Empty the box of defenders before delivery.',
    NULL, 36, 37, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Corner taker', 'Play short to the second player'),
    (2, 'Second corner player', 'Draw a defender, cross or combine'),
    (3, 'Player on box edge', 'Receive direct, drag another defender')
) AS v(so, role, job);

-- 46. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'set_piece', 'The corner', 'Deliver to keep zonal defenders static',
    'Time the corner in front of goal out of the keeper''s reach; if zonal defenders must stay in place they jump lower than attackers running in.',
    'Attacking corner vs zonal marking',
    'Runners outjump static zonal defenders.',
    NULL, 37, 37, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Corner taker', 'Swing it in out of keeper''s reach in front of goal'),
    (2, 'Attackers', 'Attack the ball with a run-up')
) AS v(so, role, job);

-- 47. pp.37-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'set_piece', 'The corner', 'Leave forwards up when defending corners',
    'Barcelona kept three forwards around halfway when defending corners, so opponents had to keep four at the back and send few attackers forward; the keeper looks to launch them on a quick counter. Defending sides choose zonal, man-marking or a mix.',
    'Defending a corner',
    'Reduce attackers in the box and threaten a counter.',
    NULL, 37, 38, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three forwards', 'Stay on the halfway line'),
    (2, 'Goalkeeper', 'Catch and find a forward quickly'),
    (3, 'Zonal defenders', 'Each guard an area of the box')
) AS v(so, role, job);

-- 48. pp.39-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'set_piece', 'The corner', 'Near-post flick-on to blind runners',
    'Corner chipped to a tall, strong player at the near post who heads it on across goal for forwards running in blind; Milan''s most productive corner.',
    'Attacking corner',
    'Touch-in finish at the back post area.',
    NULL, 39, 39, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near-post target', 'Win the header and flick it on'),
    (2, 'Two runners', 'Arrive late across the six-yard box'),
    (3, 'Corner taker', 'Arc ball to the near post')
) AS v(so, role, job);

-- 49. pp.39-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'set_piece', 'The corner', 'Five run in, sixth peels to edge',
    'Surprise corner: five attackers sprint toward goal while a sixth runs out to the edge of the box, receiving a free shot from about 16 metres. Works once; then teams post a defender between spot and edge.',
    'Attacking corner, surprise variation',
    'Free edge-of-box shot while defenders follow the runners.',
    NULL, 39, 40, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Five runners', 'Sprint into the box, take markers'),
    (2, 'Sixth player', 'Run the opposite way to the box edge, shoot'),
    (3, 'Corner taker', 'Pull it back low to the edge')
) AS v(so, role, job);

-- 50. pp.43-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Systems / 4-4-2 game plan', 'Two strikers split the centre backs',
    'In 4-4-2 the two strikers each stand between a full back and a centre back, so the back four cannot build and the keeper must go long; English sides pair a tall target with a quick small striker.',
    'Opponent keeper or back four has the ball',
    'Pin both centre backs one-on-one and deny them a free covering man.',
    NULL, 43, 43, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Tall striker', 'attack the long ball and head it on or down'),
    (2, 'Small quick striker', 'run in behind or drop to receive the knock-down at feet'),
    (3, 'Centre backs (opponent)', 'forced into one-on-one duels without a spare cover man'),
    (4, 'Keeper', 'skip the back four with a long ball to the strikers')
) AS v(so, role, job);

-- 51. pp.43-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_defend', 'Systems / 4-4-2 game plan', '4-4-2 wide mids drop on loss',
    'In possession the 4-4-2 wide midfielders act as wingers making a front four; on losing the ball they sprint back beside the full backs while the two central midfielders seal the middle.',
    'Ball lost',
    'Reform the two banks of four immediately so the centre is closed.',
    NULL, 43, 43, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielders', 'drop back toward the full back line to help on the flank'),
    (2, 'Central midfielders', 'take defensive roles and close the centre'),
    (3, 'Two strikers', 'stay up, ready to restart the attack when the ball is won')
) AS v(so, role, job);

-- 52. pp.43-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Systems / 4-4-2 game plan (Sacchi''s AC Milan)', 'Show the flank, deny the centre',
    'Sacchi''s Milan 4-4-2 let opponents advance along the touchline but never allowed a central build-up; once the ball is wide midfielders have only one side to defend.',
    'Opponent building from the back',
    'Funnel the ball wide where the side can trap it instead of being split down the middle.',
    NULL, 43, 43, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two', 'block the central passing lanes and steer the build-up wide'),
    (2, 'Central midfielders', 'stay compact in the middle, never get pulled out'),
    (3, 'Wide midfielder ball side', 'engage once the ball goes down the flank')
) AS v(so, role, job);

-- 53. pp.44-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Systems / 4-3-3 (central buildup)', '4-3-3 central build-up with stepping centre back',
    'Full backs push high, taking the opposing wingers with them, and the centre backs split wide to form a triangle with the keeper; against a lone striker one centre back dribbles into midfield.',
    'Keeper or centre back in possession against a single striker',
    'Create a 3v1 at the back and an extra man in every line further up.',
    NULL, 44, 44, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'go all the way up, dragging the opposing wingers back'),
    (2, 'Centre backs', 'split wide, triangle with the keeper'),
    (3, 'Free centre back', 'carry the ball into midfield to add a man'),
    (4, 'Keeper', 'third point of the triangle, first link of the build-up')
) AS v(so, role, job);

-- 54. pp.44-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Systems / 4-3-3 (central buildup)', 'Strikers force 4-3-3 build-up wide',
    'Against a 4-3-3 that builds centrally the strikers must disrupt it at source and push the ball to the flank so no midfielder faces two opponents; a stepping centre back who loses the ball wide leaves a hole behind him.',
    'Opponent 4-3-3 starts building centrally',
    'Stop the free centre back stepping in and exploit the space he leaves if he loses it.',
    '4-3-3', 44, 44, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strikers', 'press the build-up and force it to the touchline'),
    (2, 'Midfielders', 'avoid 2v1s in the centre once the ball goes wide'),
    (3, 'Forwards on regain', 'attack the space behind the stepped-up centre back one-on-one')
) AS v(so, role, job);

-- 55. pp.45-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Systems / Chipping as an attacking tactic (AC Milan)', 'Chip over midfield to the front two',
    'When opponents forced Milan wide and space ran out, the full backs (Maldini, Tassotti) played back to Baresi or Costacurta, who chipped over midfield to Van Basten and Gullit; the strikers held it or set it back to Rijkaard or Ancelotti coming forward.',
    'Build-up forced to the wing with no space',
    'Bypass a crowded midfield and attack from the strikers'' hold-up.',
    NULL, 45, 46, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (Maldini, Tassotti)', 'recycle back to the centre backs'),
    (2, 'Centre backs (Baresi, Costacurta)', 'chip precisely to where the striker will arrive'),
    (3, 'Front two (Van Basten, Gullit)', 'complementary runs, never both short or both deep; hold or lay off'),
    (4, 'Central midfielders (Rijkaard, Ancelotti)', 'arrive to take the lay-off and start the attack'),
    (5, 'Whole team', 'trained for the exposure to a counter when the strikers lose it')
) AS v(so, role, job);

-- 56. pp.48-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Systems / Ajax against Milan (Van Gaal, 1994/95)', 'Free defender steps into midfield, 4-3-3 becomes 3-4-3',
    'Van Gaal''s Ajax turned 4-3-3 into 3-4-3 in possession by moving Danny Blind into midfield, making 4v3 there and pushing Litmanen just behind the striker; Ajax''s wing backs pinned Milan''s wide midfielders and Ajax''s wingers held Milan''s full backs, so Milan''s two central men faced three or four.',
    'Ajax in possession',
    'Permanent extra man in midfield and 1v1s all over the front line.',
    '4-4-2', 48, 50, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free defender (Danny Blind)', 'step up into midfield to make the extra man'),
    (2, 'Number 10 (Litmanen)', 'move up just behind the striker'),
    (3, 'Wingers (Overmars, Kluivert)', 'beat the full back 1v1 to create 2v1 in the box'),
    (4, 'Full backs (De Boer, Reiziger)', 'tuck toward the centre when Blind leaves, keeping distances short'),
    (5, 'Holding midfielder (Rijkaard)', 'residual defence behind the attack'),
    (6, 'Davids', 'count players ahead of the ball; recall one if more than four')
) AS v(so, role, job);

-- 57. pp.50-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Systems / 4-3-3 game plan', '4-3-3 trios, wingers stretch, midfielders hit the channel',
    '4-3-3 plays in groups of three so the man on the ball always has two forward options; wingers hug the touchline to drag full backs wide and midfielders run into the gap between full back and centre back.',
    'Ball in midfield with wingers wide',
    'If the full backs stay wide the channel opens; if they tuck in the winger is free to go down the line and cross.',
    NULL, 50, 50, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'stay on the touchline to widen the opposing back four'),
    (2, 'Midfielders', 'dive into the full back-centre back gap'),
    (3, 'Ball carrier', 'pass with the right pace onto the correct foot of the moving trio'),
    (4, 'Opposing full backs', 'forced to choose between channel and flank')
) AS v(so, role, job);

-- 58. pp.51-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Systems / Crazy or brilliant? (Wimbledon 1996/97)', 'Diagonal to target man, win restarts deep',
    'Wimbledon built keeper to centre back to a winger slightly ahead of the right back, who hit a tight diagonal to the big striker (Gayle); the aim was a duel ending in a throw-in or corner deep in the opponent half, with three midfielders up to collect.',
    'Possession in own half',
    'Turn every throw-in and corner into a scoring chance.',
    NULL, 51, 51, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Keeper', 'start via the centre back'),
    (2, 'Winger', 'receive ahead of the right back, play the diagonal'),
    (3, 'Target striker (Marcus Gayle)', 'challenge for everything, force a throw or corner'),
    (4, 'Three midfielders', 'push up to pick up loose balls')
) AS v(so, role, job);

-- 59. pp.51-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Systems / Crazy or brilliant? (Gullit''s Chelsea vs Wimbledon)', 'Starve the long-ball side of restarts',
    'Gullit beat Wimbledon by dropping his 3-5-2 for a 4-4-2, cutting off the long ball and forcing them to play through the wings while conceding no corners, free kicks or throws.',
    'Facing a long-ball, set-piece team',
    'Make them play the football they are worst at.',
    NULL, 51, 51, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'help defend and shut the channels the long ball targets'),
    (2, 'Midfield and defence', 'avoid fouls, corners and throw-ins near goal'),
    (3, 'Whole team', 'push play out to the flanks')
) AS v(so, role, job);

-- 60. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Systems / New demands on the striker in 4-3-3', 'Inverted wingers inside, full backs overlap',
    'Modern 4-3-3 uses wrong-footed wingers who drift inside (Messi, Neymar, Robben, Ribery) while the full backs charge into the vacated flank and two midfielders hold behind; the striker must make room rather than wait in the box.',
    'Team in possession in the opponent half',
    'Pull defenders into the middle so the flank is open, then switch play to the far side.',
    NULL, 52, 52, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted wingers', 'come inside onto the stronger foot to combine or shoot'),
    (2, 'Full backs', 'dive into the open flank'),
    (3, 'Two midfielders', 'keep control behind the advancing full backs'),
    (4, 'Striker', 'drop or move to make space for the incoming players'),
    (5, 'Ball side', 'switch quickly to the side where the ball isn''t')
) AS v(so, role, job);

-- 61. pp.52-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_defend', 'Systems / New demands on the striker in 4-3-3', 'Wingers drop into a five- or six-man line',
    'When the ball is lost the 4-3-3 wingers chase their direct opponents back almost into full back positions, while the actual full backs move inside; five or six defenders end up in a line or crescent.',
    'Ball lost with full backs high',
    'Cover the flanks left by attacking full backs.',
    NULL, 52, 52, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'track their direct opponent all the way back'),
    (2, 'Full backs', 'move toward the centre to close the box'),
    (3, 'Striker', 'stay as the outlet, keep the ball under pressure when it comes')
) AS v(so, role, job);

-- 62. pp.53-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_attack', 'Systems / Van Gaal, Brazil, 2014', '5-3-2 flips to 3-5-2 on regain',
    'Van Gaal''s Netherlands defended in 5-3-2 with a striker (Van Persie) dropping half a line; on regain the two outer defenders sprint forward to make a 3-5-2 with a midfield edge, especially against 4-4-2, and drop back again on loss.',
    'Ball won / ball lost',
    'Solid when defending, numerical advantage in midfield when attacking.',
    '4-4-2', 53, 54, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing backs', 'move up into midfield on regain, back into the five on loss'),
    (2, 'Back three', 'hold the centre'),
    (3, 'Dropping striker (Van Persie)', 'fall back half a line to seal when defending'),
    (4, 'Fast forward (Robben)', 'cover all attacking space on the break')
) AS v(so, role, job);

-- 63. pp.54-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Systems / 3-5-2 game plan', '3-5-2 feeds the free playmaker',
    'Liverpool''s 3-5-2 gave John Barnes a free role: whenever the defenders won it they looked for him first; Juventus and Italy used the same shape around Pirlo, sometimes going 3-4-3 to shield him.',
    'Defender gains possession',
    'Run the attack through the best passer, with others ready to take over if he is man-marked.',
    NULL, 54, 54, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Playmaker (Barnes, Pirlo)', 'free role, shape the attack, can join as a striker'),
    (2, 'Back three', 'find the playmaker immediately'),
    (3, 'Wing backs (Lichtsteiner)', 'cover defender, midfielder and winger along the whole touchline')
) AS v(so, role, job);

-- 64. pp.54-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_attack', 'Systems / 4-5-1 game plan', '4-5-1: lone striker and support distances',
    'In 4-5-1 the back four stay home and two midfielders hold the balance, so attacks are the lone striker plus one or two runners; with a ball-playing striker rather than a sprinter the whole team must move up.',
    'Ball won in the 4-5-1 block',
    'Attack without leaving huge gaps for the opponent''s counter.',
    NULL, 54, 55, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'never join the attack'),
    (2, 'Two holding midfielders', 'keep defensive balance'),
    (3, 'Lone striker', 'solo run if quick; hold the ball if a ball player'),
    (4, 'One or two midfielders', 'support the striker; whole block steps up if the striker holds')
) AS v(so, role, job);

-- 65. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_attack', 'Systems / Leicester City 2015/16 (Ranieri)', 'Drop to 4-5-1, Vardy stays up, break as 4-2-3-1',
    'Leicester sent everyone behind the ball on losing it except Vardy, who harassed the build-up; on regain they became a 4-2-3-1 and fast players ran into the space their deep defending had invited.',
    'Possession regained deep',
    'Counter into the space in front of a deep block before the opponent can reset.',
    NULL, 57, 57, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lone striker (Jamie Vardy)', 'stay up, disrupt the build-up, run into space behind on regain'),
    (2, 'Mahrez, Kante', 'carry and switch quickly into the open field'),
    (3, 'Rest of the side', 'retreat into a tight 4-5-1 when the ball is lost')
) AS v(so, role, job);

-- 66. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Systems / Leicester City (how to beat them)', 'Give the ball to a counter side',
    'The way to beat a counter-attacking team like Leicester is to mirror them: sit back, offer them the initiative and attack only once you win it.',
    'Facing a deep-block counter team',
    'Take away the space they need and make them play with the ball, which they are not used to.',
    NULL, 57, 57, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'withdraw into a defensive position, do not commit forward'),
    (2, 'Forwards', 'attack only on regain')
) AS v(so, role, job);

-- 67. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Systems / Balance in midfield; Midfielders', 'Midfield trio of roles and default positions',
    'A balanced three has a box-to-box runner, a reader who sets pace and build-up, and a ball-winner who feeds playmakers; in a four the two central men stand diagonally, one organising behind, one going forward. Wide men drop to make 4-5-1/4-1-4-1, and in 4-4-2 attack two midfielders stay home.',
    'Any phase; especially at the moment of losing the ball',
    'Midfield always covered so a loss of possession does not leave the side outplayed.',
    NULL, 57, 57, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Box-to-box midfielder', 'shuttle up to the opponent goal and back'),
    (2, 'Controller', 'dictate build-up and tempo, read the opponent''s combinations'),
    (3, 'Ball-winner', 'take the ball off opponents, deliver it to the creators'),
    (4, 'Wide midfielders', 'drop to midfield when defending'),
    (5, 'Every midfielder', 'keep asking ''what if we lose it?'' and know his default position')
) AS v(so, role, job);

-- 68. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Systems / Third midfielder behind (4-1-2-3)', 'Holding six: one goes, one stays',
    'With the third midfielder behind, the two in front are dynamic but if one runs forward the other stays behind and wide; the two wide men cannot both join, and when the ball is crossed from one wing the opposite winger joins while his number recovers loose balls.',
    'A midfielder starts a forward run / cross from the flank',
    'Width of the midfield stays covered so a loss does not let the opponent counter unopposed.',
    NULL, 58, 58, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder', 'screen in front of the defence'),
    (2, 'Two advanced midfielders', 'one runs, the other holds behind and wide'),
    (3, 'Crossing-side winger', 'join the attack on goal'),
    (4, 'Far-side midfielder', 'move across to pick up overhit crosses and clearances')
) AS v(so, role, job);

-- 69. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_defend', 'Systems / Third midfielder forward (4-2-1-3)', 'Number 10 presses first on loss',
    'With the third midfielder forward only two cover the central line, so the number 10 plays around the striker as link and must chase and pressure when the ball is lost (Bergkamp, Litmanen, Mata).',
    'Ball lost in the attacking third',
    'Slow the opponent''s restart so the two holding midfielders are not overrun.',
    NULL, 58, 58, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 10', 'link midfield and attack; harass the opponent on loss'),
    (2, 'Two central midfielders', 'keep defensive control of the central line'),
    (3, 'Striker', 'work with the 10 in the first press')
) AS v(so, role, job);

-- 70. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_defend', 'Systems / Someone like Lampard', 'Fill the gap of the late-arriving midfielder',
    'A goal-scoring midfielder like Lampard arrives in the box from deep and is always near the ball, so teammates must fill the hole he leaves in midfield and switch quickly on losing possession.',
    'Attacking midfielder makes a late run into the box',
    'Keep midfield balance so his runs do not expose the side, especially against stronger opponents.',
    NULL, 58, 58, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Arriving midfielder (Lampard)', 'run in from distance to finish'),
    (2, 'Holding midfielder', 'cover the space he vacates'),
    (3, 'Rest of team', 'switch to defending immediately on loss')
) AS v(so, role, job);

-- 71. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Systems / Double accordion (Leicester 2015/16, AC Milan, Baresi)', 'Accordion block shifting with the ball',
    'Leicester and Sacchi''s Milan defended in a tight block that slid toward the ball side and up and down as one, keeping equal distances; Baresi led Milan''s version, the whole team moving a few metres at a time after losing the ball. Slow centre backs (Huth) are protected by placing the block around the own box.',
    'Opponent in possession / ball changes side',
    'Gaps so small the opponent cannot split the block.',
    NULL, 59, 59, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'move together, keep fixed distances, stay deep if slow'),
    (2, 'Midfield line', 'shift with the ball side and stay connected to the back line'),
    (3, 'Sweeper/leader (Baresi)', 'drive the shifts and punish anyone out of step'),
    (4, 'Fast midfielders and strikers', 'stay ready to counter on regain')
) AS v(so, role, job);

-- 72. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Systems / Superior numbers in midfield; Shifting position', 'Win midfield numbers: defender up or forward down',
    'To outnumber the midfield you either step a defender up (Blind at Ajax 1995, Rijkaard dropping in as striker cover) or drop a forward back (Messi at Barcelona, Cruijff as player and coach); Xavi-Iniesta-Busquets kept moving to offer each other passes.',
    'Opponent matches numbers in midfield',
    'Extra player in midfield because centre backs rarely follow a dropping forward.',
    NULL, 59, 59, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free defender (Blind)', 'move up into midfield'),
    (2, 'False nine (Messi, Cruijff)', 'drop back from striker to midfield'),
    (3, 'Defensive midfielder (Busquets)', 'screen, recycle'),
    (4, 'Playmaker (Xavi)', 'pass left and right'),
    (5, 'Attacking midfielder (Iniesta)', 'play forward and turn up near the striker')
) AS v(so, role, job);

-- 73. pp.59-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Systems / Shifting position (Chelsea 2012 CL semi-final)', 'Defending a man short in midfield',
    'When the opponent has the extra midfielder, keep distances short, anticipate where the ball is going and meet advancing runners physically, as Chelsea did against Barcelona in 2012.',
    'Outnumbered in central midfield',
    'Compensate for the missing man through organisation rather than chasing.',
    NULL, 59, 59, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'scan the whole game, no ball-watching, block runners coming through'),
    (2, 'Back line', 'stay close to the midfield to keep distances short')
) AS v(so, role, job);

-- 74. pp.59-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_attack', 'Systems / Scylla and Charybdis (Arsenal under Wenger)', 'Hold the block deep to leave space for Henry',
    'Wenger''s late-1990s Arsenal had a strong back four with Vieira and Petit and did not push the defensive block up too quickly, so Henry and the quick wingers had room to run into on the counter.',
    'Ball won',
    'Mix attacking in the opponent half with counter-attacks into open space.',
    NULL, 59, 60, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four (Adams, Keown etc.)', 'hold position, do not compress the space too early'),
    (2, 'Screening midfielders (Vieira, Petit)', 'win it and release quickly'),
    (3, 'Fast striker (Henry)', 'run into space behind'),
    (4, 'Wingers (Overmars, Ljungberg)', 'break alongside')
) AS v(so, role, job);

-- 75. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'set_piece', 'Kickoff (interlude)', 'Kickoff signals intent',
    'After the back pass from kickoff some teams send three or four players to rush the receiving defender; others knock it around to see whether the opponent presses; others play it to the keeper to kick long and fight for it.',
    'Kickoff',
    'Set the tone: early pressure, probing possession, or direct duels.',
    NULL, 61, 61, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three or four forwards', 'chase the long kickoff ball so the defender faces two or three opponents'),
    (2, 'Kickoff pair', 'tap it back to start a probe or a long ball'),
    (3, 'Keeper', 'hold or kick upfield to start the duels')
) AS v(so, role, job);

-- 76. pp.62-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Patterns of play / Moving trios', 'Moving trio and the third man',
    'Basic Dutch 4-3-3 patterns: give-and-go then pass to a third player going deep who serves the striker; or pass, move up, ball via a second man to an arriving third who plays the first in deep to cross. The third player always moves away from the passer into free space.',
    'Ball to a teammate with a third player able to run off',
    'Break a zonal defence with a runner it cannot track.',
    NULL, 62, 63, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player 1', 'pass and move, then go deep to receive or cross'),
    (2, 'Player 2', 'set the ball back or on with one touch'),
    (3, 'Player 3', 'run away from the ball into free space, receive and serve'),
    (4, 'Striker', 'attack the cross in the box')
) AS v(so, role, job);

-- 77. pp.64-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Patterns of play / The long ball', 'Long ball with team stepping up',
    'The long ball is a planned weapon: a forward who can receive facing up holds it among defenders while midfielders join and defenders move up, squeezing the opponent into its own half; it can target the centre forward or strikers running into the channels, straight into space or bending to a strong target (Mark Hughes, Ibrahimovic).',
    'Ball at the back with the striker ready to receive',
    'Win territory, trap the opponent in its half, gain corners, throws or free kicks.',
    NULL, 64, 66, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target forward', 'receive facing forward, control and keep it under pressure'),
    (2, 'Midfielders', 'arrive quickly to collect lay-offs and second balls'),
    (3, 'Defenders', 'push up so the lines stay compact behind the ball'),
    (4, 'Second striker', 'attack the flick-on through the defence'),
    (5, 'Wide strikers', 'run the channels for balls into the corners')
) AS v(so, role, job);

-- 78. pp.65-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Patterns of play / Moving trios', 'Two strikers move in opposite directions',
    'In 4-4-2 or 5-3-2 the two strikers must always move apart: one comes to receive (ideally a ball chipped to chest), the other runs off, with someone deep available; two strikers standing together form a static trio that is easy to defend.',
    'Pass into the front two',
    'Force the defenders to choose so one striker is free.',
    NULL, 65, 65, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving striker', 'come to the ball, control on the chest or feet'),
    (2, 'Second striker', 'run off in the other direction'),
    (3, 'Deep supporter', 'stay available behind for the lay-off, ideally moving')
) AS v(so, role, job);

-- 79. pp.65-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Patterns of play / The long ball', 'Aim long balls at the far corner',
    'Sending the long ball toward the corner is safer: if it is lost the opponent must build from the corner of its own half in one direction only, whereas a ball lost in the middle lets them go left or right.',
    'Choosing the target of a long pass',
    'Limit the damage if possession is lost.',
    NULL, 65, 65, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'play toward the corner rather than the centre'),
    (2, 'Channel runner', 'chase into the corner, win a throw or corner if not the ball'),
    (3, 'Defenders', 'squeeze the opponent''s one-sided exit')
) AS v(so, role, job);

-- 80. pp.65-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Patterns of play / Moving trios; Positions / Central defender', 'Centre-back pair: one challenges, one covers',
    'Two centre backs facing two strikers mirror them: one challenges whoever gets the ball while the other lets the second striker go and covers the first; the ideal pair does this automatically and communicates.',
    'Ball played into a striker',
    'Never two defenders on the ball or both standing still.',
    NULL, 65, 79, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back near the ball', 'challenge the receiving striker'),
    (2, 'Other centre back', 'drop off the second striker into cover behind the first'),
    (3, 'Pair', 'communicate, never both run to a deep ball')
) AS v(so, role, job);

-- 81. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Patterns of play / The long ball (Man Utd late 1990s; vs Barcelona)', 'Go long when pressed, then return to build-up',
    'Under pressure Schmeichel skipped the press with long balls to Cole, Yorke, Sheringham or Solskjaer; once opponents stopped chasing and stepped back, he went back to building through the flanks. The same weapon is the answer to Barcelona''s six-second press.',
    'Opponent presses the build-up high',
    'Make pressing pointless, then take back control with short play.',
    NULL, 66, 66, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Keeper (Schmeichel)', 'kick long when pressed, build via right or left flank when not'),
    (2, 'Strikers', 'take on the defenders from the long ball'),
    (3, 'Defenders', 'accept duels instead of playing out under pressure')
) AS v(so, role, job);

-- 82. pp.66-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_defend', 'Patterns of play / Tiki-taka (Guardiola''s Barcelona)', 'Six-second rule, then retreat',
    'When Barcelona lost it the whole team, forwards included, hunted the ball for six seconds; if that failed they fell back 20-30 metres, reassembled and let the opponent come.',
    'Ball lost',
    'Win it back close to goal before the opponent can pick a pass; otherwise reset the shape.',
    NULL, 66, 67, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front three (Messi, Neymar, Suarez)', 'press immediately rather than run back 30 m later'),
    (2, 'Midfield trio', 'close the nearest options'),
    (3, 'Whole team', 'if not regained, retreat 20-30 m and reform')
) AS v(so, role, job);

-- 83. pp.67-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Patterns of play / High pressure and low pressure', 'Choosing high or low pressure',
    'High pressure locks the opponent in its own half; low pressure waits 10-15 m past halfway and pins them there, inviting them on to open counter space (Leicester and Vardy). Total pressure presses wherever the ball is won. Since high pressing cannot last 90 minutes, vary it: Ferguson''s United mixed both and went to total pressure in the final 15 minutes.',
    'Opponent has the ball; game state and players'' qualities',
    'Win the ball near goal or bait the opponent forward for the counter.',
    NULL, 67, 69, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'press defenders in high pressure; screen from the halfway line in low pressure'),
    (2, 'Midfield and back lines', 'stay compact behind the chosen pressing line'),
    (3, 'Whole team', 'switch to all-out pressure late in the match when chasing')
) AS v(so, role, job);

-- 84. pp.67-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Patterns of play / Smart defense (Kohler); Central defender', 'Stay behind the striker, step in front late',
    'Against long balls Kohler waited behind the striker and stepped in front only as the ball arrived; Gullit half-turned to always see his man. Stay close enough to be felt but not so close the forward can spin off you, and keep cover behind.',
    'Long ball toward a marked striker',
    'Intercept or deny the striker the ball without giving him a body to turn on.',
    NULL, 67, 70, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marking centre back', 'start behind, half-face, step in front as the ball comes'),
    (2, 'Covering defender', 'be in place if the striker still gets past')
) AS v(so, role, job);

-- 85. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Patterns of play / Player without portfolio (Feyenoord 1983/84)', 'False nine roams, runner goes deep, cover behind',
    'Cruijff, nominally outside left, roamed between the lines; Brard (left back pushed to left half) covered and cleared up behind him, and right midfielder Hoekstra started a deep run as soon as Cruijff received.',
    'False nine receives between the lines',
    'The best player gets the ball easily and feeds a runner in behind, with the team still protected.',
    NULL, 70, 70, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'False nine (Cruijff)', 'drop between midfield and forwards, make space for others to go deep'),
    (2, 'Cover man (Brard)', 'stay away from the ball, close gaps when it is lost'),
    (3, 'Runner (Hoekstra)', 'go deep the moment the 10 has the ball'),
    (4, 'Marker (opponent)', 'cannot follow the dropping 9 without opening space behind')
) AS v(so, role, job);

-- 86. pp.75-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Positions / Keeper as coach', 'Line height matched to the keeper',
    'A goal-line keeper is uncomfortable behind a line on halfway, while a one-on-one specialist can cover the space behind a high line; the keeper organises the defence and decides set-piece set-ups.',
    'Setting the defensive line',
    'Defensive line and keeper style fit so the space in behind is covered.',
    NULL, 75, 75, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Keeper', 'organise defenders, cover behind a high line if a sweeper type'),
    (2, 'Back line', 'set its height to what the keeper can cover')
) AS v(so, role, job);

-- 87. pp.75-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'set_piece', 'Positions / Keeper as coach (defending corners)', 'Defending corners: zonal, man or mixed',
    'The keeper and coach choose zonal, man-marking or a mix, and whether to put players on the posts; zonal is risky because static defenders jump lower than running attackers. Barcelona leave three up for a short-corner counter, which forces opponents to keep a fourth defender back.',
    'Corner against',
    'Clear the ball while keeping an outlet that pins opposing defenders.',
    NULL, 75, 75, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Keeper', 'decide the marking system and post players'),
    (2, 'Zonal defenders', 'attack the ball in their area'),
    (3, 'Man-markers', 'follow the main headers'),
    (4, 'Three forwards left up', 'threaten the counter, tying up a fourth defender')
) AS v(so, role, job);

-- 88. pp.75-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'set_piece', 'Positions / Keeper as coach (attacking corners)', 'Near-post flick, keeper screen, short corner',
    'A near-post header flicked on with three or four players crashing in is almost impossible to defend; Hugo Sanchez blocked the keeper''s view then ran to the far post; a short corner draws one or two defenders out and a near-post run can pull the keeper off his line.',
    'Corner for',
    'Create an unpredictable ball in the box with runners to finish it.',
    NULL, 75, 76, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near-post player', 'flick the first ball on'),
    (2, 'Three or four runners', 'surge in for the ricochet'),
    (3, 'Screener (Hugo Sanchez)', 'block the keeper, then slip to the far post'),
    (4, 'Short-corner pair', 'pull defenders out of the goalmouth')
) AS v(so, role, job);

-- 89. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Positions / Right back', 'Winger cuts in for overlapping full back',
    'The wide forward, often left-footed on the right, moves inside to free the flank for the full back (Swart/Suurbier at Ajax, Messi/Alves, Neymar/Alba at Barcelona); the full backs roam the channels and the defender faces a 1v2.',
    'Winger in possession or moving inside',
    'Create a 2v1 on the flank and force the defender to choose.',
    NULL, 76, 76, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted winger', 'come inside, distract defenders'),
    (2, 'Attacking full back', 'run into the freed flank or channel'),
    (3, 'Opposing full back', 'left choosing between two attackers')
) AS v(so, role, job);

-- 90. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Positions / Right back (4-4-2 AC Milan, Gary Neville)', '4-4-2 full back joins only when covered',
    'In 4-4-2 full backs are more defensive and go forward when a midfielder takes over their task; Milan''s right side (Gullit, Tassotti, Ancelotti or Rijkaard) worked as a trio that defended and attacked together. Neville picked the moment to overlap, offer a pass or stay back.',
    'Ball on the full back''s side',
    'Support the attack without leaving the flank open.',
    NULL, 76, 76, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Tassotti, Neville)', 'time the run; be back in place when possession is lost'),
    (2, 'Right midfielder (Gullit)', 'attack the flank, swap tasks with the full back'),
    (3, 'Central midfielder (Ancelotti/Rijkaard)', 'cover the full back''s zone when he goes')
) AS v(so, role, job);

-- 91. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_attack', 'Positions / Central defender (libero)', 'Libero as first link and cover',
    'A sweeper paired with a pure stopper takes the ball from the keeper and either carries into midfield or sits behind the others as cover; Baresi was the model at Milan.',
    'Keeper has the ball / opponent attack breaks down',
    'Start attacks from the back while keeping the formation intact.',
    NULL, 78, 78, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Libero/sweeper', 'receive from the keeper, step into midfield or cover behind'),
    (2, 'Stopper', 'neutralise the striker, pass simply to playmakers')
) AS v(so, role, job);

-- 92. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_defend', 'Positions / Central defender (Mascherano at Barcelona)', 'Sweeper pre-positions for the counter',
    'While Barcelona attacked, Mascherano read where a lost ball would lead the counter and moved there in advance, adjusting as the ball changed hands among Messi, Neymar and Suarez, then pounced to regain at once.',
    'Own team attacking with risky dribblers',
    'Kill the counter at source and keep the team pressing high.',
    NULL, 78, 78, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Sweeper (Mascherano)', 'anticipate the counter''s route and stand in it'),
    (2, 'Forwards', 'free to take on players knowing cover is set')
) AS v(so, role, job);

-- 93. pp.78-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_defend', 'Positions / Central defender (''What if?'')', 'Defenders think ''what if we lose it?''',
    'Good defenders (Baresi, Puyol, Vierchowod, a matured Ramos) position for the loss of the ball rather than drifting toward it to receive; at the back take no risks, clear it when in doubt.',
    'Own team in possession',
    'Formation stays organised when possession is lost, avoiding counters and fouls.',
    NULL, 78, 79, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'hold position to stop the counter, do not drift toward the ball'),
    (2, 'Defender on the ball', 'keep it simple, get rid of it under pressure'),
    (3, 'Back line', 'free the creative players to take risks further up')
) AS v(so, role, job);

-- 94. pp.81-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Positions - In the center (France, Hidalgo''s carre magique)', 'Carre magique: trio covers free playmaker',
    'France 1982-84: Platini roamed through central midfield with no fixed post. Giresse, Tigana and Genghini (later Fernandez) held the team''s balance behind and around him.',
    'Playmaker leaves his slot to join the attack',
    'The free creator can get forward without leaving the centre exposed, because the other three cover the gaps he leaves.',
    NULL, 81, 81, 940)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central playmaker (Platini)', 'free to roam forward and score'),
    (2, 'Supporting midfielders (Giresse, Tigana, Fernandez)', 'fill in behind him and deal with danger when he goes forward')
) AS v(so, role, job);

-- 95. pp.81-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Positions - In the center', 'Playmaker moved to the flank',
    'Modern teams switch from attack to defence very quickly, so a classic number 10 who might lose the ball centrally is a liability. Many coaches therefore station him wide, as late Zidane, Platini types and Pirlo-like players found.',
    'Team without the pace to protect a central playmaker',
    'Losing the ball wide costs far less than losing it in the middle, so the creator''s risks become affordable.',
    NULL, 81, 81, 950)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Playmaker', 'start wide, where a lost ball is less dangerous'),
    (2, 'Central midfielders', 'keep the middle secure')
) AS v(so, role, job);

-- 96. pp.82-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Dilemmas in midfield (1) - Lampard and Gerrard', 'Holding midfielder frees two attacking 8s',
    'England struggled to fit two forward-thinking central midfielders into a 4-4-1-1, where one had to play wide or tuck in behind the striker. Gullit argues that a 4-3-3 with the triangle pointing backwards, and a solid sitter such as Scholes at its base, would have let both get forward from midfield, as Lampard did in Chelsea''s 4-3-3.',
    'Two attacking midfielders who both arrive late from deep',
    'Both runners get forward from midfield without leaving the centre empty when the ball is lost.',
    NULL, 82, 82, 960)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Scholes type)', 'sit in front of the back four as the base of the triangle'),
    (2, 'Left 8 (Gerrard)', 'push forward from midfield'),
    (3, 'Right 8 (Lampard)', 'arrive from deep into the box')
) AS v(so, role, job);

-- 97. pp.83-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Barcelona''s midfield', 'Barcelona trio: brain, risk-taker, connector',
    'Barcelona''s midfield: Xavi never loses the ball and senses when to play it forward. Iniesta attacks from the left and risks the final pass. Busquets sits behind them for balance, blocks the opponent''s lines of attack and always gives the ball to Xavi or Iniesta. In build-up, everyone looks for Xavi.',
    'Build-up from the back',
    'Possession is so secure that they rarely have to win the ball back, and quick forward play leaves opponents little time to reorganise.',
    NULL, 83, 83, 970)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep-lying 6 (Busquets)', 'balance, block passing lanes, give the ball to Xavi or Iniesta'),
    (2, 'Right 8 (Xavi)', 'first option in build-up; never lose it; time the forward pass'),
    (3, 'Left 8 (Iniesta)', 'carry and turn under pressure; deliver the final pass to the front three'),
    (4, 'Busquets and Xavi', 'may swap places without getting in each other''s way')
) AS v(so, role, job);

-- 98. pp.83-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Conflict with the coach (1) - Luis Enrique''s MSN', 'Wide-right 10 opens overlap lane',
    'Under Luis Enrique, Messi starts wide right and drifts inside looking for space, as a fourth midfielder. Suarez and Neymar are left free along the front line, and others keep cutting in behind them.',
    'Messi moves inside from the right',
    'His inward drift clears the flank for the right back. Barcelona effectively have four in midfield and two strikers who are never tied down.',
    NULL, 83, 84, 980)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right forward (Messi)', 'start wide, drift inside, pick the pass'),
    (2, 'Right back (Alves)', 'overlap into the lane Messi vacates'),
    (3, 'Strikers (Suarez, Neymar)', 'move freely along the last line'),
    (4, 'Midfield runners', 'cut in behind the forwards')
) AS v(so, role, job);

-- 99. pp.83-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_defend', 'Barcelona''s midfield / Strikers (Guardiola''s six-second rule)', 'Six-second scramble after losing the ball',
    'Barcelona press straight away when they lose the ball. Distances stay short, so each player only needs a few metres to get there. Everyone, Messi included, joins the hunt and then returns to position.',
    'Ball lost',
    'Win the ball back high and fast, so non-runners like Iniesta never face long recovery sprints.',
    NULL, 83, 88, 990)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players', 'close down the ball within six seconds'),
    (2, 'All outfielders', 'keep tracking where the ball is and whom to mark if it is lost'),
    (3, 'Forwards (Messi)', 'join the scramble, then drop back into shape')
) AS v(so, role, job);

-- 100. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Wingers (Beckham, Waddle)', 'Deep wide deliverer with inside overlap',
    'A wide right midfielder like Beckham does not need to beat his man. He offers short in combinations, takes the ball to feet and whips early, dangerous balls to the striker from deep. Meanwhile the full back (Neville, Irwin) overlaps or he moves inside himself.',
    'Ball played to the wide midfielder''s feet',
    'Early quality service from deep, without needing the byline.',
    NULL, 85, 85, 1000)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide right midfielder (Beckham)', 'offer short, receive to feet, cross early from deep'),
    (2, 'Right back (Neville)', 'overlap outside into the space he creates'),
    (3, 'Striker', 'attack the early ball')
) AS v(so, role, job);

-- 101. pp.85-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Wingers', 'Inverted wingers cut in to shoot',
    'A right-footer on the left and a left-footer on the right (Robben, Ribery, Messi, Neymar, Ronaldo, Bale) rarely go to the byline. They dribble inside past the defender''s weak leg and shoot. Full backs are told to push on and time their runs behind, so the crosses come from them.',
    'Winger receives wide and isolated',
    'Wingers attack the box on their stronger foot, and the overlapping wide defenders deliver the touchline crosses.',
    NULL, 85, 87, 1010)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted winger', 'cut inside at pace and shoot before the defender can set his feet'),
    (2, 'Full back / wing back', 'push up and run behind at the right moment, without closing the winger''s space'),
    (3, 'Striker', 'make room for the winger coming inside')
) AS v(so, role, job);

-- 102. pp.87-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Strikers (Henry at Arsenal)', 'Switch to the drifting striker',
    'Henry was nominally the striker but kept drifting to the left-half area. Arsenal began attacks on the right to keep that space free, then switched the ball so he could run at goal from there.',
    'Striker pulls out to the left channel',
    'Centre backs face a dilemma: follow him and open gaps centrally, or stay and let him run at them from wide.',
    NULL, 87, 88, 1020)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Henry)', 'drift into the left-half space and attack from there'),
    (2, 'Right-side players', 'start the attack on the right to keep Henry''s side clear'),
    (3, 'Midfield', 'switch play to Henry; vary the move to keep surprise')
) AS v(so, role, job);

-- 103. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Strikers (classic finisher)', 'Last-line finisher in a possession team',
    'Strikers such as Drogba, Van Nistelrooy, Suarez and Inzaghi lurk on the shoulder of the last defender while their team keeps the ball. The defence must eventually give up space, and the striker runs in at the exact moment the pass comes.',
    'Defence steps up or leaves space during sustained possession',
    'Stretch the defence from front to back and finish the one ball that breaks through.',
    NULL, 88, 88, 1030)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'stay on the last line; time runs in behind to avoid offside'),
    (2, 'Midfield passer', 'release the through ball on the striker''s run')
) AS v(so, role, job);

-- 104. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Strikers (Hughes, Ibrahimovic)', 'Target man: play it to him',
    'With a strong hold-up forward like Mark Hughes or Ibrahimovic, the instruction is simply to play the ball into him all the time. Nobody gets near the ball once he has it.',
    'Any chance to go forward',
    'The ball sticks up front, which lets the team step up and relieves the defence.',
    NULL, 88, 88, 1040)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target forward', 'receive with back to goal and shield the ball'),
    (2, 'Midfield and defence', 'play into him early and support')
) AS v(so, role, job);

-- 105. pp.88-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Strikers (Messi false nine)', 'False nine drops; wide men run beyond',
    'Before Suarez arrived, Messi dropped from striker into midfield. The wingers and midfielders sprinted past him into the space behind while the defenders waited for his through ball.',
    'Centre forward checks back into midfield',
    'A centre back who follows him leaves a hole behind, and runners attack it.',
    NULL, 88, 109, 1050)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'False nine (Messi)', 'drop into midfield to receive, then thread passes in behind'),
    (2, 'Wingers (Neymar, Pedro)', 'sprint inside behind the defence'),
    (3, 'Full backs (Alba, Alves)', 'push high and wide'),
    (4, 'Midfielders (Xavi, Iniesta)', 'feed Messi and support')
) AS v(so, role, job);

-- 106. pp.94-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'National soccer cultures (Italy, Spain, Germany)', 'Solid block, lone striker counters',
    'Italian, Spanish and German sides start from not conceding. A well-organised defence is the base, and one top forward up front (Griezmann at Atletico, Higuain at Juventus, Aubameyang at Dortmund) finishes the few chances it creates.',
    'Opponent has the ball',
    'Not losing comes first; one striker turns the rare chances into goals.',
    NULL, 94, 94, 1060)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line and midfield', 'stay compact and disciplined'),
    (2, 'Lone striker', 'stay up and finish counters')
) AS v(so, role, job);

-- 107. pp.95-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_defend', 'National soccer cultures - France', 'Free 10 drops back into position',
    'In France''s 1998 side (Zidane roaming from the left as a forward) and 1986 side (Platini as a free number 10), the stars still went back to an assigned position when the ball was lost.',
    'Possession lost',
    'Every player has a defensive post, so the free creator''s licence costs the shape nothing.',
    NULL, 95, 95, 1070)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free playmaker (Zidane, Platini)', 'drop straight back into his tactical slot'),
    (2, 'Holding midfielders (Deschamps, Petit)', 'provide pace and balance')
) AS v(so, role, job);

-- 108. pp.97-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Youth programs - The Netherlands', 'Three-touch positional play',
    'Gullit criticises one- and two-touch position games and wants rondos where each player must take three touches. This forces midfielders to receive under pressure, shield, turn and choose the next action.',
    'Receiving in traffic',
    'Players learn to keep the ball, turn away from a challenger and choose a position quickly, rather than passing endlessly without going anywhere.',
    NULL, 97, 97, 1080)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving midfielder', 'control, shield and turn before passing'),
    (2, 'Pressing players', 'try to win the ball')
) AS v(so, role, job);

-- 109. pp.104-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Everything to win', 'Late siege: bodies in the box',
    'Chasing a late goal, teams pile tall players into the penalty area and pump the ball in. Ferguson''s United instead pushed up and pressed so hard that the keeper had to kick long, then won the ball back. The team pushing up is most exposed at that moment, and strikers dropping back to help defend become a liability.',
    'Behind or level in the final minutes and needing a goal',
    'Force a goal from aerial pressure or from high regains, accepting the risk of a counter.',
    NULL, 104, 104, 1090)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Tall players and centre backs', 'go up into the opponent''s box'),
    (2, 'Midfield and forwards', 'press high so the keeper is forced long'),
    (3, 'Strikers', 'stay up rather than defend in your own box')
) AS v(so, role, job);

-- 110. pp.104-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Everything to win - (Un)sporting solutions', 'Protect a lead in the corners',
    'When defending a late lead, take free kicks toward the opponent''s corner rather than into the box. Dribble the ball to the corner flag to win throw-ins, corners or fouls. Break the chasing side''s momentum with stoppages. Ginola''s long ball when France needed only a draw against Bulgaria in 1993 is the cautionary example.',
    'Ahead in the final minutes with the ball',
    'Run down the clock far from your own goal and guarantee the result.',
    NULL, 104, 105, 1100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free-kick taker', 'play into the opponent''s corner, not the box'),
    (2, 'Ball carrier', 'take it to the corner flag and shield'),
    (3, 'Whole team', 'no speculative long balls; keep possession')
) AS v(so, role, job);

-- 111. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'The coach gets involved', 'Press trap: let the weak full back build',
    'If the opponent''s left back cannot start attacks, mark their right back and both centre backs so the ball is funnelled to him, then wait for his mistake. The moves after the regain are agreed in advance.',
    'Opponent goal kick or build-up from the back',
    'Force the build-up through the weakest passer and turn his errors into prepared attacks.',
    NULL, 106, 106, 1110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'mark the opponent''s right back and both centre backs'),
    (2, 'Player near the left back', 'leave him free, then press when he receives'),
    (3, 'Whole team', 'run the pre-planned attack straight after the regain')
) AS v(so, role, job);

-- 112. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Red card', 'Down to ten: reshuffle',
    'After a red card, most managers swap a forward or attacking midfielder for a defender or holding player (Wenger at Chelsea, 2016). Gullit prefers dropping a midfielder into the back line so the front pairing stays together. Koeman kept target man Pelle up front alone, and he held the ball to relieve the pressure.',
    'Own player sent off',
    'Fill the defensive hole while keeping a way to hold the ball up front.',
    NULL, 107, 107, 1120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'drop into the back line'),
    (2, 'Target striker (Pelle, Giroud)', 'stay up, hold the ball and give the team space'),
    (3, 'Remaining midfield', 'close up the gaps')
) AS v(so, role, job);

-- 113. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'The star of the team', 'Winger hands runner on, or tracks',
    'In form, Hazard did not have to track back because his marker never dared leave him. When his opponent did go forward, the expectation was to drop ten metres and pass the runner on to the player behind. When Hazard''s form faded and he stopped getting into position, he was replaced.',
    'Opposing full back overlaps the winger',
    'No free runner on the flank. A winger who does not track or hand on his man hurts the team.',
    NULL, 107, 107, 1130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Hazard)', 'drop back about ten metres and warn the man behind, or track'),
    (2, 'Full back behind him', 'take over the runner')
) AS v(so, role, job);

-- 114. pp.107-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'The star of the team / Cutting out the star player', 'Cut the supply to the star',
    'Messi and Neymar cannot be stopped physically, because they move into position off the ball. The way to neutralise them is to press their main passers, Iniesta and Busquets, and starve them of the ball. Man-to-man is the fallback, but most teams defend by zone.',
    'Opponent''s chief passers receive',
    'Stop the ball ever reaching the star.',
    NULL, 107, 108, 1140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield pressers', 'close down and tie up the opponent''s main passers'),
    (2, 'Defenders near the star', 'fallback: physical one-on-one'),
    (3, 'Coach', 'react at once if one man breaks the plan')
) AS v(so, role, job);

-- 115. pp.107-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'The star of the team (Italian side vs Barcelona)', 'Two narrow blocks, concede crosses',
    'An Italian side stopped Barcelona with a back four or five and a second block in midfield, with one striker and a false striker ahead. The wide defenders did not chase down the flanks and let crosses come in, relying on a big keeper and tall centre backs.',
    'Opponent attacks down the flank',
    'Protect the centre completely and beat the crosses in the air.',
    NULL, 107, 108, 1150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four/five', 'stay narrow; do not follow wide forwards'),
    (2, 'Midfield block', 'screen the central lanes'),
    (3, 'Centre backs and keeper', 'win the crosses in the air'),
    (4, 'Striker and false striker', 'stay up as the outlets')
) AS v(so, role, job);

-- 116. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'in_possession', 'Cutting out the star player (Lampard)', 'Unmarked late runner from midfield',
    'Lampard roamed and never sprinted in a straight line, lulling markers, then suddenly appeared in front of the keeper. He was a striker playing from midfield whom no one could easily pick up.',
    'Defence focused on the forwards',
    'Arrive unmarked in the box from deep.',
    NULL, 108, 108, 1160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Lampard)', 'drift unnoticed, then make a late run into the box'),
    (2, 'Forwards', 'occupy the centre backs')
) AS v(so, role, job);

-- 117. pp.110-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_defend', '(Un)sporting defense', 'Body-check runners going in behind',
    'Attackers are only dangerous once they get behind the defence. Defenders should block sprinting runners with their body, a shoulder in the chest, to stop the run before it starts (Gentile on Maradona).',
    'Opponent starts a run in behind',
    'Kill the run in behind before it builds speed.',
    NULL, 110, 110, 1170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender near the runner', 'step into his path and block the sprint with the body'),
    (2, 'Marker (Gentile type)', 'stay tight and keep him off balance all game')
) AS v(so, role, job);

-- 118. pp.114-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Mysterious forces in sport', 'Ten men press harder',
    'Instead of forming a deep compact block when reduced to ten, Barcelona pile on more pressure and defend man-to-man more tightly. Players mark half a metre away instead of three and slide in to keep the ball in play.',
    'Team reduced to ten',
    'Raise intensity rather than retreat, using the extra urgency of being a man down.',
    NULL, 114, 115, 1180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'All outfielders', 'mark tighter and press harder'),
    (2, 'Defenders', 'go one-on-one and make the challenge')
) AS v(so, role, job);

-- 119. pp.121-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Dutch school', 'Shut down the Dutch 4-3-3',
    'The Dutch 4-3-3 relies on a central midfielder who links to the striker or drops between the centre backs. Opponents beat it by disrupting the build-up of the two centre backs and locking down midfield.',
    'Opponent''s centre backs start the build-up',
    'Choke the build-up at source, because the shape has no alternative.',
    '4-3-3', 121, 121, 1190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'press the two centre backs'),
    (2, 'Midfield', 'lock the midfield trio man-for-man')
) AS v(so, role, job);

-- 120. pp.121-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Dutch school (5-3-2 / 3-5-2)', '5-3-2 reactive, 3-5-2 aggressive',
    'Strong teams facing the Netherlands sit in a 5-3-2 (Netherlands 2014 World Cup, PSV vs Atletico). The same players become highly aggressive when the wing backs push up into a 3-5-2, as Juventus did against Bayern.',
    'Opponent has the ball / regain',
    'A deep five protects the space, and pushing the wing backs higher turns it into a pressing and attacking shape.',
    NULL, 121, 121, 1200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'hold the centre'),
    (2, 'Wing backs', 'drop to make five, or push up to make 3-5-2 and press'),
    (3, 'Two strikers', 'counter outlets')
) AS v(so, role, job);

-- 121. pp.122-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'to_defend', 'Dutch school', 'Back two exposed by two strikers',
    'Dutch teams get into trouble against two strikers. Defending one-on-one at the back, every long ball into the space behind the defence becomes very dangerous, as when Atletico threatened PSV.',
    'Opponent plays two forwards and goes long',
    'Centre backs must learn to deal with two strikers, or a 5-3-2 adds cover.',
    NULL, 122, 122, 1210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two centre backs', 'deal with two strikers; cover space behind'),
    (2, 'Keeper', 'sweep or save one-on-ones'),
    (3, 'Extra centre back (5-3-2)', 'provide the spare man')
) AS v(so, role, job);

-- 122. pp.126-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-how-to-watch-soccer'), 'out_of_possession', 'Epilogue (Atletico vs Barcelona)', 'Rope-a-dope: absorb, then strike',
    'Atletico Madrid eliminated Barcelona by letting them have the ball, absorbing pressure as Ali did against Foreman, and striking once Barcelona tired, while Barcelona had no plan B. The lesson is to adapt your plan to the opponent rather than only to yourself.',
    'Superior possession side attacking',
    'Delay being exposed as long as possible, then hit back when the opponent tires.',
    NULL, 126, 126, 1220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive block', 'soak up pressure in a compact shape'),
    (2, 'Forwards', 'wait and break when the opponent tires')
) AS v(so, role, job);

COMMIT;
