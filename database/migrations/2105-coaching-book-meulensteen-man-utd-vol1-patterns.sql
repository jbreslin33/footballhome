-- 2105 📚 Coaching book patterns: "René Meulensteen & Man Utd Methods of Success (2007-2013)" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'René Meulensteen & Man Utd Methods of Success (2007-2013)',
    subtitle    = 'René''s Coaching Philosophy and Training Sessions (94 Practices), Sir Alex Ferguson''s Management, Culture, Principles and Tactics',
    author      = 'René Meulensteen',
    team        = 'Manchester United (Sir Alex Ferguson)',
    season      = '2007-2013',
    method_note = 'Ferguson''s Manchester United seen by his first-team coach: club culture and management, then the on-pitch model. Opponent-specific game plans (Bolton, Chelsea, Arsenal); eight attacking patterns by the height and width of the opponent''s back four (Rotating Out / Rotating In); Ferguson''s flip-chart principles (press high, compact mid block, deep block and counter, Click-Clack with chasers, hunters and security); momentum, rhythm and rotations; a speed-power-penetration-unpredictability attacking model with 2-, 3- and 4-ball routines and attacking waves; Fergie Time against a deep block; 1v1 moves and finishing; and full sessions (rotations against two or three forwards, switching play, breaking the midfield line, counters through wide outlets). Patterns are the match behaviours, in our words.'
WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a');

-- 1. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'to_defend', 'Ch1 8 Key Aspects: Game Plan / Strategy and Tactics', 'Tactical foul to stop a counter',
    'Part of right decision-making is making the right foul at the right time when the opponent is breaking against us.',
    'Opponent counter-attack with our team outnumbered',
    'Kill the break before it becomes a chance.',
    NULL, 21, 21, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest midfielder or defender', 'commit a smart foul early in the counter, away from goal')
) AS v(so, role, job);

-- 2. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch2 Game Plans (Chelsea away)', 'Byline cut-backs against aerial defenders',
    'Against a centre back and keeper strong in the air (Terry, Cech), wide attacks go all the way to the byline and the final ball is a cut-back or low cross rather than a high cross.',
    'Ball in wide area near the box vs dominant aerial defence',
    'Avoid their strength and create chances on the ground at the penalty spot / edge of box.',
    NULL, 33, 33, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers / full backs', 'dribble or run to the byline before delivering'),
    (2, 'Striker', 'attack near post on the ground'),
    (3, 'Arriving midfielder', 'hold back for the cut-back to the edge of the box')
) AS v(so, role, job);

-- 3. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'out_of_possession', 'Ch2 Game Plans (Arsenal)', 'Cut the playmaker-striker link, counter at pace',
    'Against a fixed possession side whose build-up runs through a link between key midfielder and striker (Fabregas to van Persie), the team sets up to read and intercept passes into feet, then breaks fast with quick wide forwards and targets their defenders who are weak 1v1.',
    'Pass played into the feet of their link player',
    'Turn their combination play into our counter-attack chances.',
    NULL, 33, 33, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'screen and step onto passes into the playmaker/striker''s feet'),
    (2, 'Centre backs', 'stay tight to the striker to contest every ball to feet'),
    (3, 'Wide forwards (Park, Nani) and Rooney', 'break at pace on the turnover'),
    (4, 'Attackers', 'isolate defenders judged vulnerable 1v1')
) AS v(so, role, job);

-- 4. pp.33-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'out_of_possession', 'Ch2 Video Analysis and Game Plans Against Different Opponents', 'Starve a set-piece side of free kicks',
    'Against a direct opponent whose main weapon is dead balls (Bolton under Coyle), the whole team defends without fouling and avoids conceding corners; set pieces against are defended with clear organisation.',
    'Opponent analysed as set-piece reliant',
    'Take away their main scoring route so they must beat us in open play.',
    NULL, 33, 49, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'stay on feet, jockey rather than lunge near own third'),
    (2, 'Full backs', 'shepherd wide players without giving corners or fouls'),
    (3, 'Whole team', 'set-piece defending drilled, everyone knows his marking job')
) AS v(so, role, job);

-- 5. pp.33-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'out_of_possession', 'Ch2 Game Plans / Ch3 Pressing: Press Certain Players', 'Let the weak passer carry, then pounce',
    'A specific opposition centre back (David Luiz cited) is deliberately left free to carry the ball forward because he tends to force a pass that is not on and leaves space behind; midfield sits ready to intercept.',
    'Chosen centre back receives and steps in with the ball',
    'Win the ball off his risky forward pass in midfield and break into the space he vacated.',
    NULL, 33, 50, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'do not press the chosen centre back, screen the easy outlets'),
    (2, 'Central midfielders', 'read his forward pass and intercept'),
    (3, 'Wide forwards', 'break immediately into the space behind him')
) AS v(so, role, job);

-- 6. pp.37-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch2 Attacking Against a High and Narrow Defensive Line - Pattern of Play Example 1', 'Early ball behind a high narrow line',
    'Against a high, narrow back four the team looks for early passes into the space behind and out wide, from centre backs or midfield, with the whole of the opponent''s half to run into; attack at speed and with numbers.',
    'Opponent''s line is high and narrow; passer has time on the ball',
    'Put a runner through on goal or in a wide position to square for a tap-in.',
    NULL, 37, 38, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Vidic, Ferdinand)', 'play early long or diagonal forward passes into space behind'),
    (2, 'Central midfielder (Carrick)', 'receive from CB and pass between full back and centre back for the run'),
    (3, 'Striker (Rooney)', 'time a run onside behind the line'),
    (4, 'Wingers (Ronaldo, Giggs)', 'start inside, time runs wide in behind and square to a team-mate')
) AS v(so, role, job);

-- 7. pp.37-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch2 Attacking Against a Middle and Narrow Defensive Line - Pattern of Play Example 2', 'Rotating Out: back three and switch',
    'Against a mid-height narrow line, one central midfielder drops wide of a centre back to form a back three so the full backs can push high; the ball is switched to the advanced full back while the winger moves inside, creating a 5v4 attack.',
    'Opponent narrow at middle height; CM free to drop beside CB',
    'Overload the back four after the switch and finish via cross, lay-off or through ball between the centre backs.',
    NULL, 37, 39, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Scholes)', 'rotate out beside the centre back, receive, play into the other CM or advanced full back'),
    (2, 'Other central midfielder (Carrick)', 'switch play wide to the advanced full back'),
    (3, 'Advanced full back (Evra)', 'receive the switch, cross behind or pass inside'),
    (4, 'Winger (Nani)', 'move inside to make room, lay ball back to the arriving midfielder'),
    (5, 'Attacking midfielder (Giggs)', 'slide a through ball between the centre backs'),
    (6, 'Far winger (Ronaldo)', 'come inside and time a run behind the line')
) AS v(so, role, job);

-- 8. pp.37-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch2 Positioning of the Opposition''s Narrow / Wide Defensive Line', 'Read the back four: where is the space',
    'Before choosing a route, players assess the height (high, middle, deep, very deep) and width (narrow, wide) of the opposition back line: high = space behind, middle = behind, between the lines and wide, deep = in front and wide, very deep = in front for shots plus wide for cut-backs; a wide line also opens gaps between defenders.',
    'Any settled possession phase',
    'Pick the attacking pattern that targets the space the opponent''s line leaves.',
    NULL, 37, 42, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'assess opposition back line before deciding'),
    (2, 'Ball carrier', 'choose ball behind, between lines, wide or shot based on line'),
    (3, 'Forwards', 'move to the space the line height offers')
) AS v(so, role, job);

-- 9. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch2 Attacking Against a Deep and Narrow Defensive Line - Pattern of Play Example 3', 'Rotating In: drop between CBs, play through',
    'Against a deep, narrow block (shown with three central midfielders and three forwards, roughly 4-3-3), a central midfielder drops between the centre backs to form a back three; a centre back then dribbles forward to draw a winger and passes through the lines.',
    'Our CM under pressure; opponent deep and narrow',
    'Beat the press in front of a deep line and reach the edge of the box for a cross or a through ball.',
    NULL, 40, 40, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Carrick)', 'rotate in between the centre backs and pass to a CB under pressure'),
    (2, 'Centre back (Vidic)', 'carry forward to draw the press, pass through the lines'),
    (3, 'Receiving midfielder (Giggs) / advanced full back (Evra)', 'receive between lines and feed the winger'),
    (4, 'Winger (Nani)', 'stay wide, pass into the striker or dribble up the line and cross'),
    (5, 'Striker (Rooney)', 'receive near the edge of the box and slip a through ball between the CBs'),
    (6, 'Far winger (Ronaldo)', 'move inside and time the run behind')
) AS v(so, role, job);

-- 10. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch2 Attacking Against a Very Deep and Narrow Defensive Line - Pattern of Play Example 4', 'Camp around the box: one-twos, overlaps, back post',
    'Against a very deep, narrow line the whole team lives in the attacking half: centre backs near the halfway semicircle, both full backs high, three central midfielders central and two forwards in the box; the winger on the ball has several options.',
    'Opponent defending inside its own box',
    'Use quick one/two-touch play, overlaps and back-post deliveries or cut-backs for shots from the edge.',
    NULL, 41, 41, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger on ball (Nani)', 'pass to overlapping full back, back to midfield, or cross to the back post'),
    (2, 'Full backs (Evra, Neville)', 'make timed overlapping runs in advanced areas and cross'),
    (3, 'Central midfielders (Carrick, Scholes)', 'recycle, then shoot from the edge if space appears'),
    (4, 'Forwards (Ronaldo, Rooney)', 'attack the back post')
) AS v(so, role, job);

-- 11. pp.41-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'to_defend', 'Ch2 Pattern of Play Example 8 (coaching points)', 'Centre backs as rest defence',
    'While the team camps around the opponent''s box with full backs high, the two centre backs (with a holding midfielder such as Carrick) stay back responsible for rest defence.',
    'Team in sustained attack in the final third',
    'Be ready to stop counter-attacks the moment the ball is lost.',
    NULL, 41, 46, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'stay near the halfway line, prepared for counters while still switching play'),
    (2, 'Holding midfielder (Carrick)', 'screen in front of the centre backs')
) AS v(so, role, job);

-- 12. pp.42-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch2 Attacking Against a High and Wide Defensive Line - Pattern of Play Example 5', 'Split a high wide line through channels',
    'Against a high back four that is spread wide, the gaps between defenders become passing lanes; full backs look early for forward passes into central areas behind, between full back and centre back.',
    'Opponent line high with big gaps between defenders',
    'Release a forward through the gap into the space behind with the opponent''s half to run into.',
    NULL, 42, 43, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'move ball quickly to midfielder or full back'),
    (2, 'Full backs (Evra, Neville)', 'carry forward and pass between opposing RB and CB or around the defender'),
    (3, 'Strikers (Rooney, Berbatov)', 'time runs through the gaps between defenders'),
    (4, 'Wingers', 'pin wide defenders to keep the gaps open')
) AS v(so, role, job);

-- 13. pp.42-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch2 Attacking Against a Middle and Wide Defensive Line - Pattern of Play Example 6', 'Drop, shift their forwards, then switch',
    'Against a mid-height wide line, a central midfielder drops between the centre backs to drag the opposing forwards to one side, then the ball is switched; wingers come inside between the lines while full backs push up wide.',
    'Opposing forwards shifted to one side by our circulation',
    'Attack the far side between and behind defenders with a through ball or a full back''s cross to the back post.',
    NULL, 42, 44, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Carrick)', 'drop between centre backs and circulate to shift their front line'),
    (2, 'Centre back (Vidic)', 'pass inside to a midfielder or carry forward into space'),
    (3, 'Inside midfielders (Giggs, Scholes)', 'find the winger between the lines or switch to the advanced full back'),
    (4, 'Wingers (Ronaldo, Giggs)', 'come inside, receive between lines or run into the box'),
    (5, 'Full back (Neville)', 'push high wide, dribble forward and cross to the back post'),
    (6, 'Striker (Rooney)', 'run in behind for the through ball')
) AS v(so, role, job);

-- 14. pp.42-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch2 Attacking Against a Deep and Wide Defensive Line - Pattern of Play Example 7', 'Winger drops in, full back sprints beyond',
    'Against a deep, wide line there is room between defenders and in front but little behind; one central midfielder rotates out to form a back three, full backs push on and the other midfielders receive and play in behind; the winger drops between the lines and the full back sprints into the space he leaves.',
    'Winger checks back between the lines and draws his marker',
    'Get a runner in behind the deep line from the space the winger vacated, or off a defender''s shoulder.',
    NULL, 42, 45, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Carrick)', 'rotate out to make a back three, feed CB or midfield'),
    (2, 'Central midfielder (Scholes)', 'play in behind for the winger or striker run'),
    (3, 'Winger (Nani)', 'drop to receive between the lines, set back to midfield'),
    (4, 'Full back (Evra)', 'sprint forward into the space left by the winger'),
    (5, 'Right winger and striker (Ronaldo, Rooney)', 'make runs off the shoulder of defenders')
) AS v(so, role, job);

-- 15. pp.42-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch2 Attacking Against a Very Deep and Wide Defensive Line - Pattern of Play Example 8', 'Switch, then 1v1/2v1 wide and box combos',
    'Against a very deep, wide line with no space behind, full backs keep width or time runs high, centre backs switch play to the opposite wing, and the team uses quick one/two-touch combinations around the box or creates 1v1 and 2v1 situations wide with overlaps.',
    'Opponent packed deep across the width of its box',
    'Produce a shot from a give-and-go or turn-and-shoot, or a cross from a wide overload.',
    NULL, 42, 46, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Vidic, Ferdinand)', 'switch play quickly to the opposite wing'),
    (2, 'Full backs (Neville, Evra)', 'stay wide or overlap to make 2v1 wide, then cross'),
    (3, 'Central midfielders (Scholes, Giggs)', 'quick one-touch combos at the edge of the box, shoot first time'),
    (4, 'Winger (Nani)', 'take on his man 1v1 or combine with the overlap')
) AS v(so, role, job);

-- 16. pp.48-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'out_of_possession', 'Ch3 Ferguson''s Defensive Principles', 'Compact mid block, press in chosen areas',
    'At times the team drops into a compact midfield shape that is hard to play through, then presses only in certain areas of the pitch or on certain players depending on opponent and venue.',
    'Game plan or game state calls for dropping off; ball enters the chosen pressing zone or player',
    'Deny central play-through and win the ball where we choose.',
    NULL, 48, 49, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield line', 'stay compact and narrow, block passes through'),
    (2, 'Forwards', 'drop in and guide play into the pressing area'),
    (3, 'Nearest players', 'press hard once the ball reaches the agreed zone or player')
) AS v(so, role, job);

-- 17. pp.48-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'out_of_possession', 'Ch3 Ferguson''s Defensive Principles', 'Deep block, stop crosses, hit on the break',
    'When forced to defend really deep, the team keeps a close compact shape to stop chances, with special attention to blocking crosses, then counters on regaining.',
    'Pinned back near own box',
    'Concede no chances and launch counter-attacks from deep.',
    NULL, 48, 49, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'stay compact and protect the box'),
    (2, 'Wide players', 'close down crossers'),
    (3, 'Forwards', 'stay ready as counter outlets')
) AS v(so, role, job);

-- 18. pp.48-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'out_of_possession', 'Ch3 Ferguson''s Defensive Principles / Pressing: Press or Don''t', 'Pressing Game: press high, in numbers',
    'Especially at home, the team puts the opponent under severe pressure early and high up the pitch, pressing aggressively and in numbers; pressing takes courage, so players leave their positions and everyone moves up together.',
    'Opponent receiving while turning or passing back towards his own goal',
    'Force errors near their goal and an early goal.',
    NULL, 48, 50, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'jump onto the receiver as he turns or plays backwards'),
    (2, 'Midfielders', 'leave their zones to press the next options'),
    (3, 'Defenders', 'push the line up behind the press')
) AS v(so, role, job);

-- 19. pp.48-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'to_attack', 'Ch3 Transition Principles / Positive Transition', 'Counter fast, many runners, else keep it',
    'On regaining, players react while the opponent is disorganised: think and play forward with minimal touches, judge the opposing back four and play into the spaces, and many players join with deep runs at speed to overload; if the counter is not on, keep possession and set up a positional attack.',
    'Ball won, opponent disorganised',
    'Create immediate danger, or retain the ball and build rhythm if no counter exists.',
    NULL, 48, 50, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'look forward first, release quickly'),
    (2, 'Forwards', 'break the lines and get in behind the back four'),
    (3, 'Midfielders and wide players', 'make forward runs at speed to overload'),
    (4, 'Deeper players', 'if blocked, secure possession and restart a build-up')
) AS v(so, role, job);

-- 20. pp.48-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch3 Ferguson''s Attacking Principles: Possession is Key / Momentum and Rhythm', 'Slow build, fast line-break rhythm',
    'Possession always has a purpose: build up slower with one/two touches, then break lines fast with speed, power, penetration and unpredictability, keeping width and depth and playing one-touch in tight spaces; the ball carrier chooses between one-touch, receive-and-pass, hold-and-delay, through, around, or carry into space.',
    'Settled possession; line-breaking chance appears',
    'Keep knocking on the door to create chances and momentum.',
    NULL, 48, 51, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'pick the option: one-touch, hold, play through/around, or dribble into space'),
    (2, 'Wide players', 'hold width'),
    (3, 'Forwards', 'provide depth and runs in behind'),
    (4, 'Central midfielders (Giggs, Scholes type)', 'play one-touch in tight spaces to speed up')
) AS v(so, role, job);

-- 21. pp.49-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'to_defend', 'Ch3 Transition Principles / Negative Transition', 'Click-Clack: chasers, hunters, security',
    'On losing the ball everyone reacts instantly and decides by game situation whether to press aggressively around the ball or drop into shape (Meulensteen''s ''click-clack'' cue). Roles split three ways: chasers hurry the ball carrier and ball zone, hunters wait to win the next pass, security gives cover and forms a defensive block.',
    'Possession lost',
    'Win the ball back quickly or be organised before the opponent can attack.',
    NULL, 49, 50, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Chasers (nearest players)', 'pressure ball, deny space, press high in numbers'),
    (2, 'Hunters (next ring)', 'anticipate and intercept the next pass, or let them have it and press in set areas'),
    (3, 'Security (rear players)', 'provide cover and balance, form the defensive block')
) AS v(so, role, job);

-- 22. pp.51-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch3 Ferguson''s Attacking Principles: Always Look to Create Chances', 'Dominate: keep ball when ahead',
    'Either the team creates chances or it keeps the ball because it is winning; once fully in control (2-0, 3-0 up) it decides when to let the opponent have the ball and when to take it back.',
    'Leading comfortably',
    'Control the match tempo and protect the lead through possession.',
    NULL, 51, 51, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'circulate safely, slow the tempo when ahead'),
    (2, 'Midfield', 'choose moments to re-press and regain')
) AS v(so, role, job);

-- 23. pp.62-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 3: The 3 Main Momentums in the Game', 'Three momentums: initiative, control, dominance',
    'Use good ball circulation from kick-off to take the initiative, and win the duels. Once ahead, keep control by staying ahead and staying focused so the other team cannot score against the run of play. Then dominate by keeping most of the ball, creating many chances and giving the opponent none.',
    'Kick-off, start of the second half, or taking the lead',
    'Turn early possession into a lead, and the lead into full control of the match.',
    NULL, 62, 62, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'Circulate the ball early to win the initiative'),
    (2, 'Midfield', 'Win the duels and keep possession once ahead'),
    (3, 'Back line', 'Stay focused and allow no goal against the run of play')
) AS v(so, role, job);

-- 24. pp.63-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 3: Rhythm, Rotations and Direction of Play', 'Rotations to overload and find the free man',
    'Players rotate into different positions to create an overload when playing out into midfield, to free a man between the lines during forward play, and to open space in the final third.',
    'Build-up meets a matched or numbered-up press',
    'Create a spare man to break lines.',
    NULL, 63, 63, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'Rotate out or drop to make a numerical edge in build-up'),
    (2, 'Forward / attacking midfielder', 'Rotate to become the free man between the lines'),
    (3, 'Full back', 'Fill the space a rotating midfielder leaves')
) AS v(so, role, job);

-- 25. pp.63-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 3: Rhythm, Rotations and Direction of Play', 'Direction: forward first, square, then back',
    'Think, look and play forward: pass through the lines or carry the ball into space in front. If that is not on, go square to set up a forward pass without risking the ball, and if square is not on either, play back to restart.',
    'Every time a player receives',
    'Play forward as much as possible without losing possession.',
    NULL, 63, 63, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Check forward pass or carry first, then square, then back'),
    (2, 'Teammates ahead of the ball', 'Offer forward options between and behind the lines'),
    (3, 'Support players', 'Give a safe square or backward outlet')
) AS v(so, role, job);

-- 26. pp.63-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 3: Rhythm, Rotations and Direction of Play / Speed Up Play (Rhythm)', 'Change rhythm: one-touch when squeezed',
    'Build-up from the back can be slow, but when pressed or when space closes, the team switches to one- and two-touch play to move the ball out of the crowded area, or switches play to change the angle of attack. Four players on one touch move the ball in about half the time of two-touch play.',
    'Pressure arrives or the area of play gets tight',
    'Escape the press and attack before the opponent can reset.',
    NULL, 63, 64, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep-lying central midfielder (Scholes type)', 'Set the tempo: slow down, play short or switch the angle'),
    (2, 'Players near the ball', 'Use only the touches needed, one-touch when pressed'),
    (3, 'Far-side players', 'Stay wide to receive the switch')
) AS v(so, role, job);

-- 27. pp.69-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 4: Speed, Power, Penetration and Unpredictability', 'Speed, Power, Penetration, Unpredictability attacking model',
    'The club''s attacking identity: high tempo with one-touch give-and-gos and runs past opponents, powerful runs in behind and fast reactions in transition, forward passes and carries through the midfield and back lines, and unpredictability from quick combinations, switches that create 1v1 and 2v2 situations or crosses, and dribbles.',
    'Any attacking possession',
    'Attack fast and varied enough to score many goals (goal difference wins titles).',
    NULL, 69, 70, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielders and forwards', 'Quick one- and two-touch combinations, then run in behind'),
    (2, 'Wingers', 'Isolate in 1v1 after a switch; beat the defender with speed, skill and disguise'),
    (3, 'Whole team', 'React quickly and powerfully when possession changes')
) AS v(so, role, job);

-- 28. pp.73-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 4: 2-Ball Routines (Variations 1-3)', 'Edge-of-box central combinations to shoot',
    'In front of a set defence, a central midfielder and a forward combine at the top of the box: a lay-off one-two, then the midfielder dribbles to create an angle and shoots; or the forward drops off at an angle and slips the midfielder in behind; or a lay-off and a through ball for the forward''s run.',
    'Midfielder receives facing play about 30 m out',
    'Get a shot or a run in behind through the centre.',
    NULL, 73, 75, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (A)', 'Pass in, take the lay-off or run in behind, finish'),
    (2, 'Forward (B)', 'Drop off at an angle, lay off with good weight or play the through ball'),
    (3, 'Wide players (C/D)', 'Hold width, ready for the next ball')
) AS v(so, role, job);

-- 29. pp.73-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 4: 2-Ball Routines / 3 or 4-Ball Routines', 'Waves: re-attack right after each finish',
    'As soon as one attack ends in a shot, a new ball goes wide at once so a second attack starts: the full back or winger opens up, dribbles forward and crosses for central players arriving in the box. Further balls go to the advanced full back or winger on the same side to cross or cut back again.',
    'Shot taken, cross cleared, or ball out of play near the box',
    'Keep the defence under continuous pressure with attack after attack.',
    NULL, 73, 82, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs / wingers', 'Receive the next ball, attack the flank and deliver a cross or cut-back'),
    (2, 'Central midfielders and forwards', 'Recover position at once and make new box runs'),
    (3, 'Advanced full back on the same side', 'Stay high to receive the refill and cut inside or cut back')
) AS v(so, role, job);

-- 30. pp.75-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 4: 2-Ball Routine (Variation 3)', 'Overlap and cut-back against deep defence',
    'Against a defence sitting on the edge of its box, the wide player receives on the front foot, draws his man, and releases the overlapping teammate, who goes high down the flank and cuts the ball back (or crosses to the back post).',
    'Defence deep on the edge of the box; wide player receives facing forward',
    'Get behind a low block and cut back into the space in front of it.',
    NULL, 75, 75, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player', 'Engage the defender, release the overlap at the right moment'),
    (2, 'Overlapping full back / wide player', 'Run high down the flank, cut back or cross to the back post'),
    (3, 'Central players (A, D)', 'Time runs into the box for the cut-back')
) AS v(so, role, job);

-- 31. pp.77-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 4: 3 or 4-Ball Routine (2 Defenders)', 'Third-man ball between centre backs',
    'A central midfielder plays into one forward, who moves to receive and passes across to the other forward. That forward has checked away from his marker and plays first time between the two centre backs for the midfielder''s late forward run.',
    'Pass into the forwards in front of the back line',
    'Put a late-arriving midfielder through on goal behind the centre backs.',
    NULL, 77, 79, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward 10 (Rooney)', 'Move to receive and set across to the partner'),
    (2, 'Forward 9 (Berbatov)', 'Check away from the marker, play the through ball between the centre backs'),
    (3, 'Central midfielder 24 (Fletcher)', 'Pass in, then make the late run in behind and finish'),
    (4, 'Centre backs 15/6 (opponent)', 'The pair the pass splits')
) AS v(so, role, job);

-- 32. pp.77-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 4: 3 or 4-Ball Routines', 'Midfielder rotates out, full back pushes high',
    'A central midfielder drifts wide to receive while the full back on that side pushes high. The midfielder plays forward to the winger, who sends an early cross, and the full back is then available for the next ball to dribble inside and cross or cut back.',
    'Ball switched to a central midfielder after a central attack',
    'Open the flank for an early cross while keeping a second wide threat.',
    NULL, 77, 82, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder 18 (Scholes) / 16 (Carrick)', 'Rotate out wide to receive, play forward to the winger'),
    (2, 'Full back 3 (Evra) / 2 (Neville)', 'Push high, offer the overlap or take the next ball'),
    (3, 'Winger 11 (Giggs) / 7 (Ronaldo)', 'Deliver the early cross or release the overlapping full back')
) AS v(so, role, job);

-- 33. pp.77-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 4: 3 or 4-Ball Routines / Attacking Waves', 'Three box runs: near, back, spot',
    'When a cross or cut-back is coming, three attackers attack fixed zones (near post, back post and penalty spot, or centre), with a mix of straight and diagonal crossover runs, and a supporting player follows in for rebounds.',
    'Wide player gets ready to deliver',
    'Cover every delivery zone so a quality ball always finds a finisher.',
    NULL, 77, 89, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near-post runner', 'Attack the front post'),
    (2, 'Back-post runner', 'Arrive late at the far post for balls over the top'),
    (3, 'Penalty-spot runner', 'Hold the spot for cut-backs'),
    (4, 'Supporting midfielder', 'Follow up for rebounds and second balls')
) AS v(so, role, job);

-- 34. pp.79-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 4: 3 or 4-Ball Routine (4th Ball 5v2)', 'Central overload: drop, lay off, curved run',
    'With five central players against two centre backs, midfielders move the ball across and forward to the advanced midfielder, who plays into a dropping forward. That forward sets the ball to his partner, who plays in behind for the first forward''s curved run, or the attack switches to the winger for an early cross with four runners.',
    'Numerical advantage in the centre against the back line',
    'Break the back line with quick one- and two-touch play rather than rushing.',
    NULL, 79, 82, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders 18/16', 'Circulate and play forward to the advanced midfielder'),
    (2, 'Advanced midfielder 24', 'Find the dropping forward'),
    (3, 'Forward 9', 'Drop, lay off, then attack the space behind'),
    (4, 'Forward 10', 'Make a curved run into the box or play the final pass')
) AS v(so, role, job);

-- 35. pp.80-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 4: 3 or 4-Ball Routine (4 Defenders)', 'Long switch, overlap and cross',
    'After a central attack, one central midfielder passes to the other, who switches play with a long aerial ball to the far winger. The winger moves inside with the ball and plays the overlapping full back high down the flank (or crosses early himself), with runners filling the near post, back post and penalty spot.',
    'Opponent shifted to one side after a central attack',
    'Attack the weak side before the defence can shift across.',
    NULL, 80, 82, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder 18 (Scholes)', 'Play the long diagonal switch to the far winger'),
    (2, 'Right winger 7 (Ronaldo)', 'Move inside with the ball, release the overlap or cross early'),
    (3, 'Right back 2 (Neville)', 'Overlap high and deliver a cross or cut-back'),
    (4, 'Forwards and advanced midfielder', 'Make the three box runs')
) AS v(so, role, job);

-- 36. pp.84-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 4: Attacking Wave in Pairs', 'Catapult through link players between lines',
    'Deep players play into a link player in front of the opponent''s midfield, get the set back, then pass through the midfield line to a second link player between the lines, who plays between the centre backs for a deep run. Passes are deliberately slower until the right moment, then the attack is fired quickly through the centre.',
    'Link player free between the lines; deep runner ready',
    'Break both lines at once and put a runner through on goal.',
    NULL, 84, 85, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep attacker (pair)', 'Pass in, get the set back, break the midfield line, then sprint in behind'),
    (2, 'First link player', 'Show in front of midfield, set back first time'),
    (3, 'Second link player', 'Control between the lines and slip the ball between the centre backs'),
    (4, 'Supporting attacker', 'Follow up for rebounds')
) AS v(so, role, job);

-- 37. pp.86-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 4: Attacking Wave in Threes', 'Set back, then ball in behind to far side',
    'A wide player feeds the most advanced link player, who sets back to a supporting link player. He plays in behind the midfield line toward the side a teammate has run to. That player receives in behind, dribbles forward and crosses or cuts back while the other two make timed box runs. When the centre is crowded, look for a release on the outside.',
    'First pass reaches the most advanced link player',
    'Get all three attackers beyond the ball with a quality final ball.',
    NULL, 86, 87, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide attacker', 'Feed the advanced link player, then run behind the line'),
    (2, 'Advanced link player', 'Set back first time'),
    (3, 'Supporting link player', 'Play in behind toward the runner''s side'),
    (4, 'Other two attackers', 'Break the line and time runs into the box')
) AS v(so, role, job);

-- 38. pp.88-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 4: Attacking Wave in Fours', 'Through the middle, then switch wide',
    'In a four-man wave, the ball goes from a wide player into the first link player, back to a central player, through the midfield line to the second link player, and back to the other central player. He then switches to the far wide player (or plays short), who dribbles forward and cuts back or crosses while the others run into the box.',
    'Opponent drawn centrally by the inside combination',
    'Switch quickly to unbalance the defence and attack the far flank.',
    NULL, 88, 89, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central attackers', 'Play through the midfield line, then switch play'),
    (2, 'Link players (midfielders)', 'Rotate in and out to receive between the lines and set back'),
    (3, 'Wide players / full backs', 'Hold width, receive the switch, deliver crosses'),
    (4, 'Box runners', 'Attack the near post, back post and penalty spot')
) AS v(so, role, job);

-- 39. pp.90-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 4: 3-Ball Attacking Waves Overload Game', 'Fast 8v5 overload after GK restart',
    'From a goalkeeper restart, the centre backs drop deep and wide and the full backs push high. A centre back passes forward to a link player in the attacking half and everyone moves up, using many forward runs to create an 8v5 overload and a 2v1 out wide, aiming to score within about 20 seconds.',
    'Goalkeeper has the ball after a stoppage',
    'Build quickly and attack with overloads before the defence organises.',
    NULL, 90, 91, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Split deep and wide, pass forward to a link player'),
    (2, 'Full backs', 'Push high and wide to make a 2v1 on the flank'),
    (3, 'Link players', 'Receive between the lines and combine forward'),
    (4, 'Central midfielder', 'Join with forward runs')
) AS v(so, role, job);

-- 40. pp.90-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'to_attack', 'Chapter 4: 3-Ball Attacking Waves Overload Game', 'Win it and counter in numbers',
    'When the defending side wins the ball from an overloaded attack, they switch mindset at once and sprint forward, using the link players to counter at the other end in the same numbers.',
    'Ball won from an opponent attack that has committed players forward',
    'Punish an opponent who committed players forward.',
    NULL, 90, 91, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Release forward quickly to a link player'),
    (2, 'Link players', 'Support the counter centrally'),
    (3, 'Other defenders', 'Sprint forward to make the overload')
) AS v(so, role, job);

-- 41. pp.91-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'to_defend', 'Chapter 4: 3-Ball Attacking Waves Overload Game', 'Sprint back on losing the ball',
    'When the attacking team loses the ball, all its players switch mindset and sprint back to win the ball again and protect their goal.',
    'Possession lost during an attack',
    'Stop the counter and regain the ball quickly.',
    NULL, 91, 91, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest attackers', 'Press at once to win the ball back'),
    (2, 'All other players', 'Sprint back goal-side to defend')
) AS v(so, role, job);

-- 42. pp.94-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 5: Fergie Time - How Did Manchester United Score So Many Late Goals?', 'Fergie Time: composure under the clock',
    'Late in a match when chasing a result, keep composure and quality instead of rushing or forcing passes. Keep up the speed of play without hurrying, adjust tactics slightly, keep putting balls into the box, and try to force a mistake, a free kick in a dangerous zone or a penalty. When winning, keep the ball, run down the clock and tire the opponent.',
    'Final 10 minutes plus stoppage time, losing or drawing (or winning)',
    'Score late goals as a habit (or see out a lead).',
    NULL, 94, 96, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'Believe there is time; stay composed and quick without rushing'),
    (2, 'Wide players', 'Keep delivering quality balls into the box'),
    (3, 'Forwards', 'Keep attacking the box and try to earn fouls or penalties')
) AS v(so, role, job);

-- 43. pp.99-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 5: Fergie Time Phase 1 (based on 4-3-3)', 'Phase 1: wingers narrow, full backs high',
    'Ten minutes plus stoppage left, needing a goal against a deep 5-4-1 / 4-5-1 block (4-5-1 picked; 5-4-1 also described). The 4-3-3 tucks both wingers inside next to the centre forward to make 3v4 against the back line, the full backs push high to give width, and the three central midfielders control midfield. The ball goes wide for crosses with the far winger and one midfielder running into the box. The target is 7-8 balls into the box in 14 minutes.',
    '80th minute, losing or drawing',
    'Pin the back line and supply a steady stream of crosses.',
    '4-5-1', 99, 101, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (LW/RW)', 'Play inside and narrow, occupy the defenders 3v4 with the CF; the far winger attacks the box'),
    (2, 'Full backs (LB/RB)', 'Push up high and wide, deliver crosses'),
    (3, 'Central midfielders', 'Control midfield; one joins the box runs'),
    (4, 'Two centre backs and the other two midfielders', 'Act as rest defence behind the ball')
) AS v(so, role, job);

-- 44. pp.99-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'to_defend', 'Chapter 5: Fergie Time Scenario Set-up (Rest Defence)', 'Rest defence with a spare man',
    'While chasing a late goal, the players not in the attack stay behind the ball as rest defence: two centre backs plus one or two midfielders, cut to one centre back only in the final phase. Always keep a numerical edge at the back (2v1 or 3v2): one centre back marks the lone forward and the other drops slightly deeper to cover.',
    'Team commits numbers forward to chase a goal',
    'Be ready to stop a counter attack the moment the ball is lost.',
    '4-5-1', 99, 103, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marking centre back', 'Mark the opponent''s lone forward'),
    (2, 'Covering centre back', 'Hold a deeper position to give cover'),
    (3, 'Holding central midfielder', 'Sit behind the ball and screen counter attacks')
) AS v(so, role, job);

-- 45. pp.100-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 5: Fergie Time Phase 2 (based on 4-3-3)', 'Phase 2: extra forward, wingers wide',
    'Six minutes plus stoppage left and still needing a goal against a deep 4-5-1 / 5-4-1. Bring on a second centre forward in place of a midfielder, push the wingers high and wide, and push the full backs even higher to support them. A central midfielder makes late box runs and shoots from outside the box, and the far winger attacks the back post. The target is 5-6 balls into the box.',
    '84th minute, still losing or drawing',
    'Add a body in the box and keep the crosses coming.',
    '4-5-1', 100, 102, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Extra centre forward (substitute)', 'Pair up centrally and attack crosses'),
    (2, 'Wingers', 'Stay high and wide; the far winger attacks the back post'),
    (3, 'Full backs', 'Push higher to support the wingers'),
    (4, 'Advancing central midfielder', 'Make late box runs and shoot from distance')
) AS v(so, role, job);

-- 46. pp.100-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Chapter 5: Fergie Time Phase 3 (based on 4-3-3)', 'Phase 3: flood the box',
    'Two minutes plus stoppage left. Make drastic changes: one centre back pushes forward and both central midfielders push up, flooding the final third and the box with bodies. Chase rebounds and deflections and try to win free kicks in dangerous positions. Even with one minute left, still aim to get one quality ball into the box. The target is 3-4 balls into the box, and one of them must be a goal.',
    '88th minute, still needing a goal',
    'Force a goal through numbers and second balls.',
    '4-5-1', 100, 103, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pushed-up centre back', 'Join the attack as an extra target'),
    (2, 'Both central midfielders', 'Push forward into the box area'),
    (3, 'Wide players', 'Deliver into a crowded box'),
    (4, 'Remaining centre back', 'Stay back as sole rest defence, collect loose balls')
) AS v(so, role, job);

-- 47. pp.134-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Dominating 1v1 Situations: Key Points / Coaching Points', 'Seven-step 1v1 to create a better situation',
    'Any attacker isolated against a defender reads his position relative to goal, ball, opponents and team-mates, takes a directional first touch, then decides to drive straight at the defender or drag him into space, varying tempo before the move.',
    'Attacker receives with a single defender engaging',
    'Win the duel to create a better situation and finish with the right end product (shot, cross, pass or dribble) for that zone.',
    NULL, 134, 139, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Beat men, deliver crosses, create chances'),
    (2, 'Midfielders', 'Use moves to change the angle of attack and play forward'),
    (3, 'Ball carrier', 'First touch sets up next action; choose drive or drag; change pace')
) AS v(so, role, job);

-- 48. pp.137-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Skill Development: Dominating 1v1s in Different Positions', 'Pressed defender turns away, not back to keeper',
    'A defender in build-up who gets pressed should not automatically recycle to the goalkeeper; he scans, shifts and uses a turn to change direction away from the presser.',
    'Opponent closes down a defender on the ball',
    'Keep build-up moving forward or sideways by escaping pressure instead of retreating to the keeper.',
    NULL, 137, 137, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs / full backs', 'Look up, move the ball, change direction away from the presser'),
    (2, 'Goalkeeper', 'Back pass is not the default outlet')
) AS v(so, role, job);

-- 49. pp.141-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'How and Where to Use Up and Down Moves in a Competitive 11v11 Match', 'Up and down move against side challenge',
    'A full back driving down the line and closed by the opposing winger, a winger shaping to cross while the defender blocks, or a central midfielder challenged square on from the side all chop back the opposite way; a double up-and-down can beat the defender twice.',
    'Defender arrives from the side to block run or cross',
    'Escape the side challenge and keep the attack going in the new direction.',
    NULL, 141, 145, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (LB/RB)', 'Chop back inside, then pass to centre back or central midfielder'),
    (2, 'Winger (LW/RW)', 'Fake the cross, cut back the other way, pass into midfield; double move can create a cross'),
    (3, 'Central midfielder', 'Turn opposite way, carry forward or hit a long pass to the forward')
) AS v(so, role, job);

-- 50. pp.146-149
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'How and Where to Use Spin-Off Moves in a Competitive 11v11 Match', 'Spin-off to change the angle of attack',
    'A carrier dribbling at an angle drags the defender across, then spins away to open a new angle; in tight games the team shifts the ball quickly with one or two touches and feints toward one goal before attacking the other.',
    'Opponent approaches at an angle and commits across',
    'Open a new lane for a forward pass, a switch of play, or a run into the box.',
    NULL, 146, 149, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'Carry at an angle, spin away, then forward pass, switch or dribble into space'),
    (2, 'Wide player (LW/RW)', 'Dribble in or out to drag the full back, spin the other way, then cross, shoot, pass or enter box'),
    (3, 'Team-mates', 'Give width and depth so the switch after the spin is on')
) AS v(so, role, job);

-- 51. pp.150-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'How and Where to Use Direct Frontal 1v1s in a Competitive 11v11 Match', 'Frontal 1v1 penetrating move',
    'A wide player runs straight at the opposing full back and beats him outside to cross or cut back, or inside to shoot; a central midfielder dribbles at a defender in an advanced central area and beats him toward the box edge.',
    'Defender squares up in front with space behind him',
    'Penetrate the last line for a cross, cut-back or shot.',
    NULL, 150, 152, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger', 'Beat full back on the outside, cross or cut back to box edge'),
    (2, 'Left winger', 'Beat full back on the inside, shoot or cut back to free man'),
    (3, 'Central midfielder', 'Dribble past defender in advanced zone, shoot from box edge'),
    (4, 'Box runners', 'Arrive for the cross or cut-back')
) AS v(so, role, job);

-- 52. pp.153-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'How and Where to Turn Away or Spin-Off with Opponent Challenging from Behind', 'Turn away from marker behind',
    'A receiver with a defender tight behind him turns sharply on the first touch: a central midfielder receiving a straight pass from the centre back or an angled pass from the full back spins away into space; a winger near the touchline spins inside; a winger who drifted inside turns and shoots; a striker with back to goal spins into the space behind his marker.',
    'Pass arrives while marker presses from behind',
    'Lose the marker and break a whole defensive line with one action.',
    NULL, 153, 154, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back / full back', 'Play a well-weighted pass to the receiver''s correct foot'),
    (2, 'Central midfielder', 'Show, receive, spin away and look for options'),
    (3, 'Right winger near sideline', 'Spin inside behind defender, carry and cross'),
    (4, 'Left winger moved inside', 'Sharp inside turn, take ball into space and shoot'),
    (5, 'Forward with back to goal', 'Show to centre back''s pass, spin behind defender and shoot')
) AS v(so, role, job);

-- 53. pp.160-170
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch7 Finishing: The Different Shooting Zones / Zones L2-R2, L3-R3', 'Beat the defender inside towards Zone 1',
    'A wide or wide-of-centre attacker faces a defender blocking his shooting line from Zone 2 or Zone 3, where scoring directly is hard.',
    'Ball received in Zone L2/R2 or L3/R3 with a defender in front',
    'Improve the shooting angle by going inside into the central zone. If he beats the man on the outside instead, go to the by-line and pull it back into Zone 1.',
    NULL, 160, 170, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide attacker / winger in Zone 3', 'Dribble at pace, beat the defender on the inside into Zone 2 and bend the shot away from the GK into the far corner'),
    (2, 'Wide attacker going outside', 'If he beats the man on the outside, carry to the by-line and cross or cut back'),
    (3, 'Central forward in Zone 1', 'Arrive for the cut back from the by-line'),
    (4, 'Shooter', 'Read the GK''s position, as the goal is fixed but the keeper moves, and pick the corner')
) AS v(so, role, job);

-- 54. pp.169-169
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch7 Individual Finishing: Close Range Finishing with Ball Across the 6-Yard Box and Cut Back', 'Near post, back post and cut-back runs',
    'A low hard ball comes across the six-yard box from the flank, with three attackers making staggered runs.',
    'Wide player about to deliver low across the 6-yard box',
    'Fill the near post, the back post and the penalty spot, so any delivery or cut back meets a one-touch finisher.',
    NULL, 169, 169, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near-post runner', 'Attack the near post and finish one touch with the inside of the foot'),
    (2, 'Back-post runner', 'Arrive late at the back post for a ball that goes across everyone'),
    (3, 'Third runner', 'Make a dummy run past the defender, then peel back to the penalty spot for the cut back and shoot first time'),
    (4, 'All runners', 'Time the run, arrive late and fast')
) AS v(so, role, job);

-- 55. pp.170-176
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch7 Individual / Group Finishing: rebounds', 'Far-side runner follows every shot in',
    'A team-mate shoots from an angle or from the edge of the box.',
    'Shot taken by a team-mate',
    'A second attacker is always moving towards goal to bury the rebound or a parried save.',
    NULL, 170, 176, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Shooter from an angle', 'Shift the ball off the defender, cut inside and curl the shot around the GK into the far corner'),
    (2, 'Opposite-side / central forward', 'Move towards goal as the shot is struck and finish the rebound ruthlessly')
) AS v(so, role, job);

-- 56. pp.171-178
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch7 Finishing: One-Two / Team Finishing Free Play / 3v3 (+2) Finishing Game', 'Link up with a forward to finish',
    'Attackers around the edge of the box must turn service into a shot quickly, with few touches.',
    'Ball played into a forward or link player near the box',
    'A one-two or lay-off with a partner gets a shooter into the box for a one-touch finish. Shoot early whenever there is a chance.',
    NULL, 171, 178, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving forward', 'Come off the defender and set the ball back, or play a one-two'),
    (2, 'Second attacker', 'Move forward into the box for the return pass and finish first time'),
    (3, 'Attackers without the ball', 'Read when to show for the ball and when to run in behind'),
    (4, 'Wide servers / link players', 'Deliver accurately and varied, and use the extra man to open space')
) AS v(so, role, job);

-- 57. pp.175-175
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch7 Group Finishing: "Take Over" from Team-mate', 'Take Over for a change of direction',
    'A team-mate is dribbling across the pitch at a defender, and a second attacker runs in from the opposite side.',
    'Dribbler reaches the defender with a team-mate crossing behind him',
    'The dribbler leaves or backheels the ball with disguise to the crossing runner, who takes it over in the new direction and drives past the defender to shoot.',
    NULL, 175, 175, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dribbling midfielder', 'Carry at the defender, then backheel or leave the ball with disguise at the right moment'),
    (2, 'Crossing runner', 'Time the run across behind the dribbler, take over the ball, beat the defender frontally and finish'),
    (3, 'Supporting players', 'One-touch link play to set the move up, receiving on the back foot to open out')
) AS v(so, role, job);

-- 58. pp.187-187
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'out_of_possession', 'Ch8 Adapting Practices for Specific Opponents (Chelsea)', 'Press the error-prone centre back',
    'One opposition centre back (David Luiz) is likely to make mistakes when he has the ball.',
    'That centre back receives the ball',
    'Use him as the pressing trigger and force errors high up the pitch.',
    NULL, 187, 187, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest forward', 'Press the weak centre back hard as soon as he has the ball'),
    (2, 'Supporting attackers', 'Cover his short passing options so the mistake can be punished')
) AS v(so, role, job);

-- 59. pp.187-187
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch8 Adapting Practices for Specific Opponents (Chelsea, Schalke)', 'Low crosses against dominant aerial defenders',
    'The opponent''s centre backs and keeper dominate high balls in the box (Terry and Cech), or the keeper is elite (Neuer).',
    'Final-third delivery or shooting chance against a strong aerial box',
    'Avoid high crosses and score with low deliveries, disguised shots that avoid blocks, follow-ups on rebounds and precisely placed finishes.',
    NULL, 187, 187, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers / full backs', 'Cross low and hard rather than high'),
    (2, 'Shooters', 'Disguise shots to avoid blocks and aim for precise gaps'),
    (3, 'Other attackers', 'Follow every shot in for rebounds')
) AS v(so, role, job);

-- 60. pp.187-187
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'to_attack', 'Ch8 Adapting Practices for Specific Opponents (Arsenal CL semi-final 2009)', 'Striker stays high for the break',
    'In a big away game the team defends deep and compact, but keeps its fastest forward (Ronaldo) up top.',
    'Ball regained in a good defensive block',
    'Win it and break at speed, with the quick attackers (Park, Nani, Rooney, Ronaldo) running at an exposed defence.',
    NULL, 187, 187, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lone high forward (Ronaldo)', 'Stay up top during the defensive phase as the outlet'),
    (2, 'Rest of team', 'Keep a good defensive shape until the ball is won'),
    (3, 'Wide and second forwards (Park, Nani, Rooney)', 'Sprint forward to support the counter at once')
) AS v(so, role, job);

-- 61. pp.187-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'out_of_possession', 'Ch8 Adapting Practices for Specific Opponents / AC Milan Session Examples', 'Man-press the deep playmaker',
    'The opponent runs its play through one deep playmaker (Pirlo for AC Milan) or one link between build-up and attack (Fabregas to van Persie for Arsenal).',
    'Opponent playmaker receives or looks to receive',
    'Take the playmaker out of the game with a dedicated presser, then intercept and break quickly. Against Arsenal the same idea cuts the link between their build-up and their striker.',
    NULL, 187, 190, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Park Ji-sung)', 'Play on the playmaker, press him intensely and deny him time on the ball'),
    (2, 'Midfield and defence', 'Block the passing link from the build-up into the opponent''s main forward'),
    (3, 'Forwards', 'Break quickly the moment the press wins the ball')
) AS v(so, role, job);

-- 62. pp.188-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Ch8 AC Milan Next Opponents: Session Examples 1 and 2', 'Vary tempo, hit wide, switch play',
    'Against an experienced side that likes to set its own rhythm, the team plays possession with changes of pace and attacks the flanks.',
    'Settled possession against a compact, experienced opponent',
    'Deny the opponent its preferred tempo by speeding up play often, finding the wide areas and switching the point of attack with good pass selection.',
    NULL, 188, 190, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'Change the tempo and speed play up when the chance appears'),
    (2, 'Wide players', 'Hold width so the ball can be hit to the wide areas'),
    (3, 'All players', 'Pick the right pass and the right decision rather than forcing play')
) AS v(so, role, job);

-- 63. pp.194-194
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session 1: 8v2 Boxes (1-Touch Rondos)', 'Split the pressing pair or go round',
    'A ring of passers keeps the ball against two defenders working together to close angles.',
    'Two defenders press as a pair',
    'Break through the two defenders with one touch, or circulate around them very quickly, with disguise.',
    NULL, 194, 194, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside passers', 'Scan, move the feet and play one touch through the gap between the two defenders when it opens'),
    (2, 'Two defenders', 'Work as a pair to close the passing angles and win the ball')
) AS v(so, role, job);

-- 64. pp.196-198
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session 1: Build-up Play vs 3 Forwards, CM "Rotating Out" (9v7, 11v11 Scenario 1)', 'Centre midfielder Rotates Out',
    'Building from the goalkeeper against a front three (e.g. a 4-3-3) that matches the two centre backs and blocks the full backs.',
    'GK has the ball against three forwards',
    'Free an extra man in the build-up and play forward through the lines to the forwards and the runs in behind.',
    '4-3-3', 196, 198, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Ferdinand, Vidic)', 'Split wide when the GK has it and circulate across the back'),
    (2, 'Full backs (Evra, Neville)', 'Push high, level with and outside the opposing wingers'),
    (3, 'Central midfielder (Carrick / Scholes)', 'Rotate out into the space between centre back and full back to receive, then carry or pass forward'),
    (4, 'Wingers (Giggs, Ronaldo)', 'Push inside and high, ready to drop between the lines or run in behind'),
    (5, 'Centre forward (Rooney)', 'Receive between the lines and play the winger in behind')
) AS v(so, role, job);

-- 65. pp.197-199
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session 1: Build-up Play vs 2 Forwards, CM "Rotating In" (10v8, 11v11 Scenario 2)', 'Centre midfielder Rotates In to a back three',
    'Building from the back against two forwards (e.g. a 4-4-2) who press the two centre backs.',
    'Full back has the ball against two forwards',
    'Make a 3v2 at the back, drag the forwards to one side, and let the free centre back carry into midfield.',
    '4-4-2', 197, 199, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Carrick)', 'Drop between the two centre backs to form a back three'),
    (2, 'Spare centre back (Ferdinand)', 'Rotate wider, then carry the ball forward into the space ahead'),
    (3, 'Full backs (Evra, Neville)', 'Push high and wide, with the far full back ready for the switch'),
    (4, 'Wingers (Giggs, Ronaldo)', 'Start high and inside, then drop between the lines to receive or run in behind'),
    (5, 'Other central midfielder (Scholes)', 'Support on the side of the ball carrier')
) AS v(so, role, job);

-- 66. pp.200-200
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session 1: "Second Phase Build-up" After the GK''s Long Kick (Scenario 3)', 'Second Phase Build-up from a long kick',
    'The goalkeeper kicks long and the team contests the first ball and the second ball.',
    'Long goal kick or punt from the GK',
    'Attack at once with a flick-on behind the defence. If that is not on, keep the ball and rebuild with the usual rotations.',
    NULL, 200, 200, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target forward (Berbatov)', 'Win the first header and flick it on into the winger''s run'),
    (2, 'Winger (Ronaldo)', 'Run in behind for the flick-on'),
    (3, 'Centre backs and full backs', 'Once the ball is kept or regained, drop and open out quickly to make space and time'),
    (4, 'Central midfielders', 'Rotate out or in depending on whether the opponent has 3 or 2 forwards')
) AS v(so, role, job);

-- 67. pp.202-204
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session 2: Possession (4v4+2, Pole Gates, 7v7+3 GKs)', 'Play around, away or through',
    'Possession against an organised block that is pressing to close the angles.',
    'A gap or gate between the opponents opens',
    'Recognise whether to play around, away from or through the opposition, mixing long and short, and penetrate the line when it is on.',
    NULL, 202, 204, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players in possession', 'Look for space and switch, and attack the gap when it is on'),
    (2, 'Link players / free man', 'Create overloads to penetrate between the opponents'),
    (3, 'Receiver after a line-breaking pass', 'Take the first touch into space'),
    (4, 'Off-ball attackers', 'Never stand in a team-mate''s passing lane, and make width and depth')
) AS v(so, role, job);

-- 68. pp.204-204
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'to_defend', 'Training Session 2: 7v7 (+3 GKs) Directional Possession', 'Lose ball, close the space',
    'The team has just lost the ball in a directional possession game.',
    'Possession lost',
    'Become compact straight away, block the path to the opponent''s target player and pick the right moment to press and intercept.',
    NULL, 204, 204, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players', 'Close the space around the ball at once'),
    (2, 'Defending unit', 'Stay compact and block the passing path to the target (GK in line)'),
    (3, 'All defenders', 'Recognise the moment to press and intercept')
) AS v(so, role, job);

-- 69. pp.204-204
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'to_attack', 'Training Session 2: 7v7 (+3 GKs) Directional Possession', 'Win ball, make the pitch big',
    'The team has just won the ball and needs to keep it.',
    'Possession won',
    'Spread out at once to make the pitch big, then keep good possession using the goalkeepers as support.',
    NULL, 204, 204, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players', 'Spread to the touchlines'),
    (2, 'Deepest player / GK', 'Offer a safe outlet behind the ball'),
    (3, 'Midfielders', 'Make angles and wait for the moment to play through the lines')
) AS v(so, role, job);

-- 70. pp.205-205
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session 2: Possession Specific Conditioned Game', 'Score first, then keep it',
    'The team has gone 1-0 up in a game.',
    'Taking the lead',
    'Switch from attacking to keeping possession with mixed interplay, using the goalkeeper as an extra man, so the opponent cannot equalise.',
    NULL, 205, 205, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Leading team outfield players', 'Circulate the ball with varied interplay rather than force attacks'),
    (2, 'Goalkeeper', 'Act as a free extra passer to recycle possession')
) AS v(so, role, job);

-- 71. pp.206-208
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session 3: Switching Play (warm-ups)', 'Switch play with a driven pass',
    'The ball is moved from one side of the pitch to the other to change the point of attack.',
    'One side is congested and the far side is free',
    'Move the ball across fast with driven, unlofted passes, either directly or after a carry, so the receiver can play on without breaking stride.',
    NULL, 206, 208, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Ping the ball, driving through it with an open body shape, not lofted'),
    (2, 'Receiver on the far side', 'Cushion the pass and carry forward without stopping'),
    (3, 'Carrier', 'Dribble in at an angle with the ball close, then release the switch')
) AS v(so, role, job);

-- 72. pp.211-214
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session Example 3: Switching Play', 'Diagonal full switch of play',
    'Team draws the opponent to one flank then moves the ball across to the far flank with diagonal passes, sometimes via a central link player or after a short combination on the first side.',
    'Ball-side crowded, far-side wide player free',
    'Arrive on the weak side with time so the wide man can drive forward and cross.',
    NULL, 211, 214, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders / link players', 'Use one or two touches to carry the ball across the middle; play diagonal not square'),
    (2, 'Far-side winger or full back', 'Hold width, read the cue, time a run higher to receive the switch'),
    (3, 'Receiving wide player', 'Take the first touch forward and carry the ball up the line, then cross'),
    (4, 'Forwards', 'React to the switch and make coordinated box runs, finish clinically')
) AS v(so, role, job);

-- 73. pp.216-221
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session Example 4: Playing Through The Lines', 'Breaking the midfield line to forwards',
    'Midfield circulates the ball across the opponent''s midfield four until a gap opens, then plays a firm pass through it to forwards moving between the lines; centre backs can also break the first line straight into a midfielder or receive, open up and drive forward.',
    'A gap appears in the opponent midfield line',
    'Get the ball to a forward between the lines facing goal to exploit an overload behind.',
    NULL, 216, 221, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Open wide off the GK, break the first line by passing through the front men into a midfielder'),
    (2, 'Central midfielders', 'Shift the ball quickly, change rhythm (delay or speed up), play firm passes through gaps, skip the nearest man when possible'),
    (3, 'Forwards between the lines', 'Keep moving to show in the gaps behind the midfield line'),
    (4, 'Free midfielder', 'Instead of laying back, receive, open up and dribble forward through the line')
) AS v(so, role, job);

-- 74. pp.219-221
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'out_of_possession', 'Training Session Example 4: Playing Through The Lines', 'Midfield line closes gaps together',
    'The four midfielders defend as one connected line to stop passes being threaded through them to forwards behind.',
    'Opponent shifting the ball looking for a gap',
    'No passing lanes through the line; interceptions to play forward at once.',
    NULL, 219, 221, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield four', 'Slide together with the ball, leave no gaps, talk and coach each other'),
    (2, 'Midfielder who intercepts', 'Play straight into own forwards or advanced full backs, or secure the ball first')
) AS v(so, role, job);

-- 75. pp.221-221
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session Example 4: Playing Through The Lines', 'Through the lines then full back overlap',
    'Playing 4-3-3 against a 4-4-2, once the ball is played through the midfield line into a forward, the full backs bomb on from deep to make a 5v4 in the final third, delivering for forwards attacking three posts.',
    'Ball reaches a forward behind the midfield line',
    'Use the full back''s late forward run to overload the back four and cross.',
    '4-4-2', 221, 221, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'Hold, then time the sprint forward when the ball goes through; give a quality final ball'),
    (2, 'Central midfielders', 'Release the full back; drop or rotate out to support build-up'),
    (3, 'Front three', 'Combine, then run near post, middle and far post')
) AS v(so, role, job);

-- 76. pp.224-226
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session Example 5: Attacking Overloads', 'Zone-by-zone overloads in build-up',
    'The team builds through three zones by always creating a spare man: 3v1 or 3v2 at the back with the GK or a dropping midfielder, 4v3 or 5v3 in midfield with a defender dribbling in, then 3v2 or 4v2 in the end zone.',
    'Goal kick / possession in own third',
    'Advance by numerical superiority in each zone and finish with an end-zone overload.',
    NULL, 224, 226, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Spread big in the low zone; dribble forward into midfield to create the extra man'),
    (2, 'Defensive / central midfielder', 'Drop in beside the defenders to help the first build-up phase'),
    (3, 'Midfielders', 'Make angles, position to drag opponents out and find the spare man'),
    (4, 'Attackers', 'Push two more players into the end zone to make 3v2 or 4v2 and score')
) AS v(so, role, job);

-- 77. pp.225-256
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'to_attack', 'Training Session Example 10: Transition From Defence To Attack', 'Counter through wide outlet players',
    'After winning the ball the team uses players holding width and depth (link players on the outside) to move the ball quickly away from pressure, then breaks forward with supporting runs; the same counter rule recurs whenever the defending side wins the ball in the session games.',
    'Ball won, opponent unbalanced',
    'Escape pressure via a wide/deep outlet and finish the counter with numbers arriving.',
    NULL, 225, 256, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide outlet / link players', 'Always hold width and depth for the first pass after the regain'),
    (2, 'Ball winner', 'Find the outlet quickly or go forward if space'),
    (3, 'Supporting runners', 'Recognise the moment to break and run forward to finish')
) AS v(so, role, job);

-- 78. pp.227-227
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session Example 5: Attacking Overloads', 'Midfield rotations, full backs high, wingers inside',
    'In 11v11 the central midfielders rotate to find space and come out wide when the ball goes back, while full backs push up high and wingers tuck in to form a front three, giving a 5v4 in the attacking zone.',
    'Ball played backwards / build-up from GK',
    'Overload the back four with wingers inside and an advanced full back crossing.',
    NULL, 227, 227, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Rotate to receive, decide to drop or move outside; rotate out when the pass goes backwards'),
    (2, 'Full backs', 'Push high into the attacking third and deliver the cross'),
    (3, 'Wingers', 'Move inside to join the striker as a front three')
) AS v(so, role, job);

-- 79. pp.229-232
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session Example 6: Crosses And Box Runs', 'Box-run structure for crosses',
    'When a cross is coming, three forwards attack separate areas (near post, middle, far post) and one midfielder sits behind for loose balls; runners go late and arrive fast; an over-hit cross is recycled by the far winger.',
    'Wide player about to cross',
    'Fill every target area at speed and win the second ball.',
    NULL, 229, 232, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three forwards', 'Split near post / middle / far post, go late, arrive fast, attack with head and feet'),
    (2, 'Supporting midfielder', 'Hold at the edge of the box for clearances and rebounds'),
    (3, 'Opposite winger', 'Collect an over-hit cross and return it into the box'),
    (4, 'Centre backs', 'If no cross is on, open out and rebuild via the wingers')
) AS v(so, role, job);

-- 80. pp.230-230
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session Example 6: Crosses And Box Runs', 'Early cross behind the back line',
    'After midfield combination and a switch out wide, the winger or full back crosses early, low and hard into the space between the goalkeeper and the centre backs.',
    'Wide player receives with defenders not yet set',
    'Forwards burst past the centre backs onto the cross before the defence turns.',
    NULL, 230, 230, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'Combine then switch a quality pass out wide'),
    (2, 'Wide player', 'Cross first time if speed of ball allows, otherwise control then cross, bending it behind the centre backs'),
    (3, 'Forwards', 'Time and link their runs past the centre backs; react to rebounds')
) AS v(so, role, job);

-- 81. pp.231-231
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session Example 6: Crosses And Box Runs', 'By-line chip to back post or cut-back',
    'Through rotations and underlap/overlap runs the ball is worked to a wide man near the by-line, who chips over keeper and defenders to the free back-post runner or cuts back to the edge of the box.',
    'Wide player reaches the by-line',
    'Find the free man at the back post or arriving at the edge of the box.',
    NULL, 231, 231, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Control the ball cleanly to start the move'),
    (2, 'Midfielders', 'Quick trained interplay and rotations to get the ball wide'),
    (3, 'Full back / winger', 'Underlap or overlap, then chip to back post or cut back'),
    (4, 'Arriving runners', 'Be composed on a cut-back and pick shot, cross or clever pass')
) AS v(so, role, job);

-- 82. pp.235-238
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session Example 7: Attacking Combination Play', 'Drop-back lay-off for running midfielder',
    'A midfielder drops back to offer a passing option, then lays the ball off square into the forward run of another midfielder (Scholes), who drives to the edge of the box and shoots.',
    'Ball carrier needs a forward outlet',
    'Third-man run arrives at the edge of the box with the ball for a shot.',
    NULL, 235, 238, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping midfielder (Hargreaves)', 'Drop quickly to receive, lay off first time'),
    (2, 'Running midfielder (Scholes)', 'Run past on the lay-off, carry to the box edge, strike for a corner'),
    (3, 'Forward receiving in front of a defender', 'Show to receive, turn away from the marker towards goal')
) AS v(so, role, job);

-- 83. pp.236-236
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session Example 7: Attacking Combination Play', 'Take-over with disguise to change direction',
    'A midfielder (Scholes) drives at an angle and back-heels for a team-mate (Carrick) who takes over the ball and goes the other way; the second man can then leave it for the winger''s fast inside run (Ronaldo).',
    'Ball carrier driving across a team-mate',
    'Swap the ball under disguise to switch the attack''s direction and get a shot from outside the box.',
    NULL, 236, 236, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder carrying (Scholes)', 'Drive at an angle, back-heel with disguise at the right moment'),
    (2, 'Second central midfielder (Carrick)', 'Take over and dribble the opposite way, back-heel again for the winger'),
    (3, 'Winger (Ronaldo)', 'Fast inside run, take over, dribble at speed and shoot with power or curl')
) AS v(so, role, job);

-- 84. pp.237-237
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session Example 7: Attacking Combination Play', 'Through ball for full back, cut-back',
    'A midfielder (Gibson) plays a low hard pass into the channel between centre back and left back for the overlapping right back (Neville), who cuts back while central midfielders run into the box.',
    'Full back starts a forward run outside',
    'Get behind the back line and cut back for an on-time near-post finish.',
    NULL, 237, 237, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep midfielder (Gibson)', 'Weight the pass between CB and FB so the cut-back can be first time'),
    (2, 'Right back (Neville)', 'Time the run and cut the ball back'),
    (3, 'Central midfielders (Carrick, Hargreaves)', 'Make different runs; one near post, one back post')
) AS v(so, role, job);

-- 85. pp.239-240
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session Example 7: Attacking Combination Play', 'Diagonal behind line, square to back post',
    'A diagonal forward pass finds a midfielder running round the front of the defence; he drives and slides a diagonal ball behind the line for a winger''s timed run, who squares across the box to the far-post winger. Practised against a live back four in a 6v5 game.',
    'Midfielder receives facing goal between lines',
    'Get round or through the back line and finish at the back post.',
    NULL, 239, 240, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep midfielder (Scholes)', 'Diagonal forward pass into the runner'),
    (2, 'Attacking midfielder (Carrick)', 'Run around the line, drive at the box, pass in behind'),
    (3, 'Near winger (Anderson)', 'Timed run behind the line, pass across the box'),
    (4, 'Far winger (J S Park)', 'Go late, arrive fast at the back post to finish')
) AS v(so, role, job);

-- 86. pp.244-245
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session Example 8: Finishing', 'Speed finishing with extra men',
    'In the attacking half the team uses link players for a numerical edge, moves the ball constantly and shoots at the first chance, with clever runs off the back four and follow-ups on every shot from outside the box.',
    'Any shooting window in the scoring zones',
    'Quick direct attacks producing many shots, with disguise to beat blocks.',
    NULL, 244, 245, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder and link players', 'Use the extra man to shift the ball fast and set up shots'),
    (2, 'Wingers / forward', 'Clever runs off the back four for finishes inside the box'),
    (3, 'Shooter', 'Feint to beat the block, be brave and positive'),
    (4, 'Other attackers', 'Follow every shot from distance for rebounds')
) AS v(so, role, job);

-- 87. pp.244-245
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'out_of_possession', 'Training Session Example 8: Finishing', 'Back four blocking shots, then counter',
    'A defending back four outnumbered near its box stays compact, presses the man on the ball while others cover, and gets bodies out to block shots; on winning the ball it counters fast.',
    'Opponent shaping to shoot',
    'Block as many shots as possible and break out quickly.',
    NULL, 244, 245, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender nearest ball', 'Press the shooter and block bravely'),
    (2, 'Covering defenders', 'Stay compact, cover and support, communicate'),
    (3, 'Defender who wins ball', 'Launch a fast counter attack')
) AS v(so, role, job);

-- 88. pp.246-246
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'in_possession', 'Training Session Example 8: Finishing', 'Alternate central and wide attacks',
    'The team alternates attacks through the centre (6v4 against central defenders) and out wide (winger plus overlapping full back making 2v1 against the full back), with the opposite winger joining and some deep crosses for variety.',
    'GK distributes to a winger or central midfielder',
    'Stop the defence settling by mixing central overloads with wide 2v1 crosses.',
    NULL, 246, 246, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central attackers (Giggs, Rooney)', 'Exploit the 6v4 through the middle'),
    (2, 'Winger and full back (Ronaldo, Martin)', 'Overlap to beat the full back 2v1 and cross'),
    (3, 'Opposite winger', 'Join the attack in the box or support behind and deliver deep crosses'),
    (4, 'Defending full back', 'Step out to the wing to meet the 2v1')
) AS v(so, role, job);

-- 89. pp.248-248
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'out_of_possession', 'Training Session Example 9: Defensive Shape, Pressing And Recovery', 'Move up, shift, hold, drop',
    'The whole team moves as a unit in reference to the ball: step up on a backward pass, slide across on a sideways pass, hold when correctly set, drop when the opponent has time to pass forward.',
    'Each opponent pass (back / sideways / free forward)',
    'Keep a compact, coordinated block at all times.',
    NULL, 248, 248, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Step up on back passes, drop when the passer is unpressed'),
    (2, 'Midfield line', 'Shift across with the ball, hold distances to the back line'),
    (3, 'Forwards', 'Lead the step up and the slide')
) AS v(so, role, job);

-- 90. pp.249-249
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'out_of_possession', 'Training Session Example 9: Defensive Shape, Pressing And Recovery', 'High press from GK in half positions',
    'From the opponent''s goal kick to a centre back, the front three take half positions covering two opponents each, wait for the cue, force the ball wide and hunt any receiver with head down or facing his own goal.',
    'GK passes short to a centre back; receiver head down or facing own goal',
    'Win the ball high and score within about 20 seconds.',
    NULL, 249, 249, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front three', 'Start in half positions covering two men, press on the cue, show the ball wide'),
    (2, 'Midfielders', 'Push up onto their men behind the press'),
    (3, 'Back four', 'Squeeze up to the halfway area'),
    (4, 'Player who wins ball high', 'Go to goal quickly; in midfield attack if space, else keep it')
) AS v(so, role, job);

-- 91. pp.250-251
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'to_defend', 'Training Session Example 9: Defensive Shape, Pressing And Recovery', 'Press or drop after losing the ball',
    'On a turnover the nearest player presses to delay the counter, going in hard if the carrier''s head is down or he faces his own goal and dropping off if his head is up with space; the rest recover centrally and force play to the sides.',
    'Ball lost',
    'Delay the counter, stay compact centrally and intercept forward passes.',
    NULL, 250, 251, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player closest to ball', 'Press and delay; aggressive if head down, drop off if head up'),
    (2, 'Defenders', 'Sprint recovery runs back into shape, stay compact in the central zone'),
    (3, 'Midfielders', 'Anticipate forward passes and intercept')
) AS v(so, role, job);

-- 92. pp.251-251
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'to_defend', 'Training Session Example 9: Defensive Shape, Pressing And Recovery', 'Rest Defence centre backs',
    'While the team attacks, the two centre backs (Ferdinand, Vidic) stay behind the ball as ''Rest Defence'' ready for a counter; if exposed they delay and push the attacker to one side while full backs and midfielders sprint back.',
    'Own attack in progress / ball lost high',
    'Survive the first counter phase until team-mates return.',
    NULL, 251, 251, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Ferdinand, Vidic)', 'Stay behind the ball; when exposed delay and force to one side'),
    (2, 'Full backs and midfielders', 'Run back as quickly as possible to help defend the goal')
) AS v(so, role, job);

-- 93. pp.255-256
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-2007-2013-ren-s-coaching-philosophy-a'), 'to_attack', 'Training Session Example 10: Transition From Defence To Attack', 'Anticipate interception, play early forward',
    'Defenders sit on the goal side and to one side of their direct opponent, ready to step in front and intercept; after the regain the team plays forward early and sprints to get behind the defence before it is set.',
    'Pass into a direct opponent that can be read',
    'Fast counter with a final ball into space behind the defensive line.',
    NULL, 255, 256, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender', 'Position beside the direct opponent, step in front to intercept'),
    (2, 'Player who regains', 'Play an early forward pass'),
    (3, 'Forwards and midfielders', 'Read the space, make forward runs at once; mindset switch from defend to attack'),
    (4, 'Whole team on losing it again', 'Sprint back to defend the goal')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('2105-coaching-book-meulensteen-man-utd-vol1-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
