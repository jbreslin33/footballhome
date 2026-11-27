-- 2106 📚 Coaching book patterns: "René Meulensteen & Man Utd Methods of Success Vol. 2" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'René Meulensteen & Man Utd Methods of Success Vol. 2',
    subtitle    = 'Full Season Plan, Training Sessions and Match Tactics (87 Practices)',
    author      = 'René Meulensteen',
    team        = 'Manchester United (Sir Alex Ferguson)',
    season      = '2007-08 and later',
    method_note = 'Second volume of Meulensteen''s United work: a full season plan (pre-season transition wave games, one- and two-match weeks), the attacking and defending model (full-back width, central overloads, fast vertical play, one identity with three defending heights), a run of training sessions (switching play, build-up against a 4-4-2, crosses and box runs with crossing zones, combination play, link with the forward, pressing and defensive shape, defence to attack), Champions League preparation (parking on Pirlo against AC Milan) and opponent-specific plans (Chelsea, West Brom''s diamond, QPR''s compact block). Patterns are the match behaviours, in our words; load tables, warm-ups and technique drills are left out.'
WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi');

-- 1. pp.26-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'to_attack', 'Pre-Season Training: 3-Team 3v3v3 (+GKs) Transition Wave Game', 'Regain and attack the far goal at once',
    'Three small units rotate in waves; the defending unit that wins the ball immediately turns and attacks the other end against a waiting unit, while the unit that lost it is out.',
    'Ball won by the defending unit',
    'Turn a regain into a fast, direct attack before the next defence is set.',
    NULL, 26, 28, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins the ball', 'Play forward quickly toward the opposite goal'),
    (2, 'Nearest team-mates', 'Break forward in support at speed'),
    (3, 'Attacking unit (with ball)', 'Try to score quickly before defenders recover'),
    (4, 'Defending unit', 'Start from its own defensive zone, then engage')
) AS v(so, role, job);

-- 2. pp.27-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Pre-Season Training: 3v3v3 (+2) Overload / 6v6 (+2) Forward Link Play Transition Wave Games', 'Forward link play to create overload',
    'The attacking unit uses forwards positioned between the lines as link players, turning an even attack into a numerical overload (e.g. 5v3) near goal; in the bigger version the first pass must go into the forward.',
    'Possession won or start of the attack; forward free between the lines',
    'Play into the forward early and use his lay-offs and support runs to break the defence with an extra man.',
    NULL, 27, 28, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Link forward(s)', 'Show between the lines, receive the first forward pass, lay off or turn'),
    (2, 'Supporting midfielders', 'Run beyond or around the forward to receive the lay-off'),
    (3, 'Attackers out wide', 'Stretch the defence and attack the box'),
    (4, 'Coach-served second attack', 'Attack again straight away when the first attack ends')
) AS v(so, role, job);

-- 3. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'out_of_possession', 'Pre-Season Training: 3-Team 6v6 (+2) +GKs Forward Link Play Transition Wave Game', 'Back line holds edge of the box',
    'When defending an attack, the back unit sets its line level with or just a metre or few in front of the edge of its own box rather than dropping onto the goalkeeper.',
    'Opponent attack starts toward our goal',
    'Keep a compact, high-enough defensive line that denies space in front of goal and cuts out passes to the forward.',
    NULL, 28, 28, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Hold line at or 1-3 m outside the box edge'),
    (2, 'Midfield defenders', 'Screen the pass into the opposing forward'),
    (3, 'Goalkeeper', 'Sweep behind the set line')
) AS v(so, role, job);

-- 4. pp.30-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Pre-Season Training: Afternoon Session, 9v9 +3 GKs Game on Full Pitch', 'Keep ball, then shoot from distance or penetrate',
    'Full-pitch 9v9 where keepers act as extra outlets: first pure possession using the goalkeepers as spare men, then scoring only from outside the box, then scoring only from inside it.',
    'Opponent blocks the box / centre circle zones',
    'Circulate with the keeper as a safe extra man and choose the right finish: shoot from range when the box is crowded, play in when it opens.',
    NULL, 30, 30, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeepers', 'Act as spare outlet players to keep possession'),
    (2, 'Midfielders', 'Recycle and switch until a shooting lane opens'),
    (3, 'Attackers', 'Shoot early from outside the box when the area is blocked')
) AS v(so, role, job);

-- 5. pp.43-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'System and Tactical Periodization', 'Width from full backs, central overloads',
    'Across the systems used (4-4-2, 4-3-3, 4-2-3-1) the team keeps the same principles: full backs provide the width, extra players crowd the middle, and the team moves forward vertically fast in transition.',
    'Team in settled possession',
    'Stretch the opponent with full-back width so midfield and forwards can overload the centre and break vertically.',
    NULL, 43, 43, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'Push high and wide to give the width'),
    (2, 'Central midfielders and number 10', 'Overload the central zones'),
    (3, 'Forwards', 'Offer vertical runs for quick forward play')
) AS v(so, role, job);

-- 6. pp.52-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'United''s Playing Philosophy / Core Principles of Effective Possession Play / Decision Making Behaviours', 'Forward-first possession with purpose',
    'The team keeps the ball only to attack: every pass looks to break a line, carry into space or set up a new forward option, and the tempo is changed on purpose to unbalance the opponent.',
    'Any time in possession; forward lane open or space ahead of the carrier',
    'Possession turns into penetration and chances instead of sterile keep-ball.',
    NULL, 52, 56, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Decide early; pass forward, carry into open space or hold; few touches in tight areas'),
    (2, 'Supporting players', 'Give width, depth and clear angles around the ball; keep balance behind the attack'),
    (3, 'Midfielders and forwards', 'Rotate to free a man between the lines and open space higher up'),
    (4, 'Whole team', 'Speed up when space or pressure appears, slow down to rebuild shape; recycle only to find a new forward route')
) AS v(so, role, job);

-- 7. pp.53-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'out_of_possession', 'Tactical Identity / Managing Matches Through Initiative, Control, and Domination', 'One identity, three defending heights',
    'Without the ball the side picks a height from the match state: press high when it fits, drop into a compact block when needed, or defend deep while staying organised. When ahead it keeps attacking but shuts down the opponent''s spells of momentum.',
    'Opponent''s build-up quality, score and phase of the game (start of each half is a key moment)',
    'Stay in control of the game whatever the defensive height and give the opponent no route back into it.',
    NULL, 53, 54, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front line', 'Lead the high press only when the team calls it; otherwise screen the central lanes'),
    (2, 'Midfield unit', 'Squeeze up behind a high press or close the space in front of the back line in a mid/low block'),
    (3, 'Back line', 'Hold its line and compactness at the chosen height; stay disciplined in a deep block'),
    (4, 'Whole team', 'Watch for the start of each half and respond quickly when the opponent takes the initiative')
) AS v(so, role, job);

-- 8. pp.69-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 1: Build-Up Play (6v6+4 and 8v8+4 End Zone Centre Back Build-Up Possession Games)', 'Centre backs circulate before playing in',
    'Build-up starts with the two centre backs, who pass the ball across the back line to move the press before a forward pass goes into midfield. Midfielders keep the right distance from the centre backs to open passing lanes.',
    'Goalkeeper or a centre back has the ball under a first line of pressure',
    'Draw the opponent across, then play forward into a lane that has opened, without forcing it early.',
    NULL, 69, 70, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Quick, accurate passes between them; be patient and switch the point before playing into midfield'),
    (2, 'Central midfielders', 'Hold distances and angles off the centre backs to create space and a passing line'),
    (3, 'Full backs / wide players', 'Stretch the pitch so the switch across the back has a target'),
    (4, 'Whole team', 'Keep the positional structure and tempo while the ball moves; play forward at a clear moment')
) AS v(so, role, job);

-- 9. pp.71-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 1: Build-Up Play (8v8+1 +GKs Build-Up to Overload Attack 3-Zone Game)', 'Dropping forward makes build-up overload',
    'A forward (Rooney) drops into the defensive third to give a 5v4 in build-up; once the ball reaches midfield the passer and the forward move up with it to make a 6v4 in the attacking zone.',
    'Opponent matches the back line in numbers during the goalkeeper''s build-up',
    'Win the numbers battle at the back, then carry the same spare man up the pitch to finish quickly.',
    NULL, 71, 71, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward (Rooney)', 'Drop deep to make the extra man, then push on with the ball into the attacking zone'),
    (2, 'Goalkeeper (De Gea)', 'Play out quickly and calmly to exploit the overload'),
    (3, 'Defenders', 'Use the spare man; support so the ball moves fast into the final zone'),
    (4, 'Passer into midfield', 'Follow the pass forward to add another body to the attack'),
    (5, 'Attacker', 'May drop into the middle zone to give a support angle')
) AS v(so, role, job);

-- 10. pp.72-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 1: Build-Up Play (9v9 +3 GKs Build-Up to Score in Two Goals vs Counter Attack Game)', 'Staggered support to protect build-up',
    'While building up under pressure the team circulates in one or two touches, and supporting players stand at different heights so a lost ball does not open a straight counter.',
    'Building up against a team set to counter the moment it wins the ball',
    'Keep control in build-up and have cover in place against a counter-attack if the ball is lost.',
    NULL, 72, 72, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs and holding midfielders', 'Stay behind the ball at staggered heights as rest defence'),
    (2, 'Central midfielders', 'Offer one-two touch angles to move the opponent and keep control'),
    (3, 'Wide players', 'Give width so the team can switch after attracting the press')
) AS v(so, role, job);

-- 11. pp.72-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'to_attack', 'Training Session 1 and 2: Build-Up Play / Possession', 'Regain then switch or forward fast',
    'The moment the ball is won, the first pass goes forward to an outside target or out to the far side, instead of a safe square pass, while the opponent is still out of shape.',
    'Interception or tackle won in midfield or the back third',
    'Exploit the opponent''s broken shape at once with a fast counter or a quick switch wide.',
    NULL, 72, 76, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins the ball', 'Look up at once and play forward or to the far side'),
    (2, 'Wide players', 'Spread wide immediately to receive the switch'),
    (3, 'Forwards', 'Offer a deep target or run beyond for the counter'),
    (4, 'Nearby teammates', 'React straight away to the change of possession and support the ball')
) AS v(so, role, job);

-- 12. pp.75-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 2: Possession (5v5+4, 6v6+1+6, 10v10 Directional Possession Games)', 'Attract pressure, then accelerate forward',
    'In directional possession the team overloads around the ball and moves it to draw the opponent in, then speeds up and plays into the end zone or a front target once the ball is past halfway or a lane opens.',
    'Opponent steps in to press the ball area, freeing a teammate or a forward lane',
    'Play forward early, but only into space you have created, rather than forcing the pass.',
    NULL, 75, 77, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players near the ball', 'Make the overload: give angles and support ahead of the ball so it can go forward early'),
    (2, 'Ball circulators', 'Draw pressure onto one side to free a teammate'),
    (3, 'Far-side players', 'Stretch the opponent to create space; the team then steps up together'),
    (4, 'End zone / target players', 'Stay available to receive the penetrating pass and keep it')
) AS v(so, role, job);

-- 13. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 2: Possession (Tactical Build-Up, Rotations, Switch Play, and Attack Through Gates Game)', '4-2-3-1 build-up with rotations and switches',
    'Lined up 4-2-3-1 against a 4-4-2, the goalkeeper starts with a centre back dropping to receive; the team then uses midfield rotations, combinations and switches to get through one of the opponent''s channel or central gates and attack the goal.',
    'Goalkeeper restart against a 4-4-2 front two',
    'Use the extra man in central build-up and the switch to get through the 4-4-2 block.',
    '4-4-2', 78, 78, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Drop and split to receive from the goalkeeper and start build-up'),
    (2, 'Central midfielders / attacking midfielder', 'Rotate to free a man and switch the play'),
    (3, 'Full backs and wingers', 'Hold width for the switch and attack the wide gates'),
    (4, 'Forward', 'Pin the centre backs and attack the space behind once the gate is broken')
) AS v(so, role, job);

-- 14. pp.81-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 3: Switching Play (4v4+2, Switching Play Runs in Behind, Controlled Possession with Wide Zones)', 'Switch to the weak side, then attack',
    'The team uses width and depth so there is always a clear passing lane across the pitch, moves the ball in central areas to pull the block over, then switches quickly to the free wide zone. From there the winger or full back dribbles, crosses, or the team combines inside.',
    'Opponent''s block has shifted to the ball side; free player or space on the weak side',
    'Stretch the block, then hit the weak side, or go through the centre once it has opened.',
    NULL, 81, 86, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (Carrick, Scholes, Fletcher)', 'Keep the ball in the middle and spot the moment for the long switch'),
    (2, 'Weak-side winger / full back (JS Park, Rafael)', 'Stay wide for the switch; winger can come inside so the full back overlaps, takes the switch, dribbles and crosses'),
    (3, 'Forwards (Tevez, Berbatov)', 'Make runs in behind the defensive line timed to the switch; one can drop on the half-turn instead'),
    (4, 'Wide players', 'Give width and angles on both sides so the ball can be kept and switched'),
    (5, 'Whole team', 'Control tempo: know when to keep circulating and when to switch')
) AS v(so, role, job);

-- 15. pp.82-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 3: Switching Play (3-Ball Switch Play and Play Through the Lines Finishing Combinations, Ball 1)', 'Switch to release the full back for a cross',
    'A centre back opens up to receive from the goalkeeper and plays diagonally to his full back, who passes inside to the central midfielder; the midfielder switches to the far full back, who drives forward and crosses for two forwards timing runs into the box.',
    'Goalkeeper has the ball with the near side crowded',
    'Free the far full back at speed to cross into a box that is being attacked.',
    NULL, 82, 82, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Smalling)', 'Open up to receive from the goalkeeper and play the diagonal to the full back'),
    (2, 'Full back (Fabio)', 'Play inside to the midfielder to start the switch'),
    (3, 'Central midfielder (Cleverley)', 'Weight and time the switch so the far full back can run onto it'),
    (4, 'Far full back (Young)', 'Run onto the switch, dribble forward and cross'),
    (5, 'Two forwards (Rooney, Welbeck)', 'Read the crossing zone, go late and arrive fast; vary near post, far post and cut-back runs')
) AS v(so, role, job);

-- 16. pp.83-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 3 and 4: Switching Play / Playing Through the Lines', 'Forward checks off to receive between lines',
    'A central midfielder plays a vertical pass into a forward who has come off his marker into the space between the lines; the forward receives on the half-turn and either turns and shoots, sets back, or slips in a second forward running behind.',
    'Vertical lane from midfield to a forward who has moved off his marker',
    'Break the midfield line in one pass and get a shot or a through ball quickly.',
    NULL, 83, 89, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Fletcher, Carrick)', 'Check away from the marker, then play the vertical pass with the right weight and timing'),
    (2, 'Receiving forward (Rooney, F1)', 'Receive on the half-turn; turn and shoot, set back, or play in the strike partner'),
    (3, 'Second forward (F2, Welbeck)', 'Run in behind for the through ball, or act as the set option'),
    (4, 'Passer', 'Move straight after the pass to support')
) AS v(so, role, job);

-- 17. pp.84-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 5: Attacking Overloads (8v8+1 +GKs Attacking Overloads Through the Zones Game; 3v2 Attack to Score)', 'Chain overloads zone by zone',
    'The team builds a numbers advantage in the back zone (4v3 with a free man), then a player steps up to make 3v2 in midfield, then two more push on to make 5v3 near goal, playing forward fast each time an overload appears.',
    'A spare man appears in the current zone',
    'Carry a numbers advantage up the pitch with supporting runs and finish before the defence can match up.',
    NULL, 84, 96, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free man / joker', 'Give the extra man in build-up, then step into midfield to make the next overload'),
    (2, 'Midfielders', 'Make supporting runs into the next zone so the attack keeps going'),
    (3, 'Forwards', 'Attack at speed when it is 3v2 or 5v3 and score quickly'),
    (4, 'Ball carrier', 'Spot the overload early and play forward quickly once it exists')
) AS v(so, role, job);

-- 18. pp.88-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 4 and 5: Unopposed Attacking Waves / Attacking Combination Play Through the Lines and Finishing Pattern', 'Lay-off and third-man run behind',
    'Short one-twos and set passes break the opponent''s midfield and back lines: a player sets the ball back for a teammate facing play, who plays it through for a third player running in behind, finished by a one-two and shot.',
    'A player receives with his back to goal while a teammate faces forward and a runner is ready',
    'Get through the defensive line with timed combinations and finish quickly.',
    NULL, 88, 95, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Setting player', 'Lay the ball back with good weight for the teammate facing play'),
    (2, 'Teammate facing play', 'Play the penetrating pass through the line for the runner'),
    (3, 'Third man / runner', 'Time the run in behind and finish, or play a final one-two'),
    (4, 'Central midfielder (Carrick)', 'Act as the link: three passes or a link through him unlocks the forward pass'),
    (5, 'Whole unit', 'Keep the rhythm through the weight and timing of every pass')
) AS v(so, role, job);

-- 19. pp.90-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 4: Playing Through the Lines (6v6+4 +GKs Play Through the Lines Quickly and Support to Finish)', 'Play forward quickly, support runs follow',
    'In a 2-3-1 shape the team keeps its lines apart to open space between them, then plays forward early into the forward or end ''wall player''; the midfielders follow at once with forward and diagonal runs so the wall player can lay off for a quick finish.',
    'The forward / wall player is open to receive between or beyond the lines',
    'Break the lines at speed and arrive in numbers to finish before the defence recovers.',
    NULL, 90, 90, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two defenders', 'Keep positional discipline at the back to stretch the space between the lines'),
    (2, 'Three midfielders (Carrick, Giggs, Nani)', 'Play forward early, then make immediate forward and diagonal support runs'),
    (3, 'Forward / wall player (Tevez)', 'Receive the forward pass and lay it off in two touches or fewer'),
    (4, 'Goalkeeper (v d Sar)', 'Start play with a quick forward pass')
) AS v(so, role, job);

-- 20. pp.91-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 4: Playing Through the Lines (Build-Up to Overload and Play Through the Lines to Finish Tactical Game)', 'Centre back carries in to overload',
    'The centre backs pass between themselves to shift the opponent''s front line; once a gap opens, one dribbles forward into midfield to make a 6v4 there, and the team then plays into the final third for a 5v5 attack.',
    'A gap opens in the first pressing line after the ball has been circulated across the back',
    'Gain an extra midfielder by carrying the ball in, then play through the lines at the right moment.',
    NULL, 91, 91, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Circulate to shift the press; wait for the moment, then dribble through into midfield'),
    (2, 'Midfielders (DM, CMs)', 'Return the ball to the centre backs in one touch until the moment comes; then use the 6v4 to play forward'),
    (3, 'Full backs / wingers', 'Give width in zone 2 and push into the final third'),
    (4, 'All players', 'Scan before receiving to judge pressure and forward options; know when to keep it and when to break the line')
) AS v(so, role, job);

-- 21. pp.93-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 5: Attacking Overloads (8v8+4 Rotational Overload Possession Game with End Zone Players)', 'Pass and rotate to keep structure',
    'When a player passes into a teammate higher or wider, the two swap positions, so the team keeps its shape while players move; spare players are used to keep a numerical advantage around the ball.',
    'A pass into a teammate in a more advanced or wider position',
    'Keep the ball under pressure through constant numerical superiority and rotation, without losing structure.',
    NULL, 93, 94, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Rotate straight into the receiver''s old position after the pass'),
    (2, 'Receiver (end zone player)', 'Take the ball and move it across or back to keep possession'),
    (3, 'Spare / free players', 'Join the ball area to create the overload'),
    (4, 'Whole team', 'Scan, move and keep secure passes to protect the ball')
) AS v(so, role, job);

-- 22. pp.97-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 5: Attacking Overloads (7v7+6 +GKs Attacking Overloads with Wide Zones and Support Players Game)', 'Go wide early to overload centrally',
    'Wide players take positions early on the touchline to stretch the opponent across the pitch, which opens numbers in the centre; the team then combines quickly there or switches to whichever player is free.',
    'Ball won or restart; the opponent''s back line is narrow',
    'Stretch the defence so central overloads and free players appear for a quick finish.',
    NULL, 97, 97, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players', 'Get wide early, then feed the centre or deliver in two touches'),
    (2, 'Central players', 'Use the extra space to combine quickly and finish'),
    (3, 'Goalkeeper', 'Restart quickly to an end or wide player to play forward'),
    (4, 'Whole team', 'Spot the free player and switch to him if the centre closes')
) AS v(so, role, job);

-- 23. pp.99-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Training Session 6: Crosses and Box Runs (3-Ball Combination Play, Crossing, and Finishing Patterns; 4-Corner Finishing)', 'Combine wide, cross, attack the box',
    'Central combinations (a one-two off a forward checking away, or a wide pass and lay-back) free a winger to cross, while forwards make timed runs into the box and meet low passes across the area first time.',
    'Winger or wide player gets free to deliver from a crossing zone',
    'Land quality deliveries for well-timed runs and finish first time with good contact.',
    NULL, 99, 100, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger / wide player (G2, E)', 'Get free through the combination and cross into the box'),
    (2, 'Forwards (B, G)', 'Check off the defender, then time runs to meet the cross or pass across'),
    (3, 'Central playmaker (A, C)', 'Start with a one-two or a pass out wide'),
    (4, 'Finishers', 'Set the body early and strike first time with either foot, accuracy before power')
) AS v(so, role, job);

-- 24. pp.101-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Session 6: Crosses and Box Runs', 'Ball wide, early support, timed box runs',
    'Ball is moved out to a wide player who has space; the nearest players support immediately and the forwards hold their runs until the wide man is ready to deliver.',
    'Ball played into the wide zone',
    'Stretch the back line with width, then a low, hard or bent cross meets attackers arriving at speed in the box.',
    NULL, 101, 103, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger / wide player', 'Carry past halfway, look up, deliver low and hard or cut back'),
    (2, 'Forwards', 'Attack the space in front of the defenders late, near post / centre / far post'),
    (3, 'Inside midfielder', 'Support the wide player early to help play into the wide zone'),
    (4, 'Attacking team', 'Enter the final third through the outside channels to reach crossing areas')
) AS v(so, role, job);

-- 25. pp.103-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'to_attack', 'Session 6: Crosses and Box Runs', 'Defend the box, win second ball, break',
    'A defending side under crossing pressure clears or wins the rebound and immediately counters toward the far end.',
    'Cross cleared or second ball won in own box',
    'Turn a defended cross into a fast counter before the attackers recover.',
    NULL, 103, 104, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Defend the cross, clear with purpose'),
    (2, 'Midfielders', 'React first to second balls'),
    (3, 'Forwards', 'Break forward for the counter pass')
) AS v(so, role, job);

-- 26. pp.104-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Session 6: Crosses and Box Runs / Session 8: Finishing', 'Release the full back for an early cross',
    'Build-up aims to free the full back in his own wide lane; the link players lay it wide for his advanced run and he crosses early with a first touch set-up.',
    'Full back free on the outside in his lane',
    'Early delivery from both flanks before the defence sets, with two or three box runners across the goal.',
    NULL, 104, 115, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Advance into wide zone, one touch to set, cross early'),
    (2, 'Link midfielders', 'Receive from the full back, play him in on the advanced run'),
    (3, 'Central midfielders', 'Make crossing runs through the middle of the box'),
    (4, 'Forwards', 'Time 2-3 runs across the line: near post, penalty spot, far post')
) AS v(so, role, job);

-- 27. pp.107-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Session 7: Attacking Combination Play', 'Combine central and wide to unbalance',
    'Attackers look early for a forward pass and then link central and wide players at speed, creating local overloads (e.g. 3v2) in one zone before moving into the next.',
    'Free forward option or local numbers up',
    'Shift and unbalance the block so the final pass or shot comes quickly, often first time.',
    NULL, 107, 111, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'Recognise the forward pass or combination early'),
    (2, 'Nearest two supporters', 'Give clear angles to make a 3v2 in the zone'),
    (3, 'Runner from behind', 'Time the run to receive moving and carry into the next zone'),
    (4, 'Wide players', 'Offer width so central combinations can switch outside')
) AS v(so, role, job);

-- 28. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Session 7: Attacking Combination Play', 'Striker lay-off to arriving midfielder',
    'Centre back plays into the holding midfielder, who uses a one-two with the attacking midfielder and then hits the forward; the forward sets back for the attacking midfielder to run on and shoot, or turns and dribbles in himself.',
    'Forward receives with back to goal',
    'Get a midfielder facing goal at the edge of the box, or let the forward turn his marker.',
    NULL, 108, 108, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'Start with a pass into the holding midfielder'),
    (2, 'Holding midfielder', 'One-two with attacking midfielder, then pass into the forward'),
    (3, 'Forward', 'Lay off for the attacking midfielder or spin past the defender'),
    (4, 'Attacking midfielder', 'Arrive at the edge of the box to receive and shoot')
) AS v(so, role, job);

-- 29. pp.109-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Session 7: Attacking Combination Play', 'Winger drives inside, striker curls in behind',
    'Ball is switched to a winger who comes inside and dribbles toward goal while a forward bends his run around the defender into the box.',
    'Winger receives facing inside with space to carry',
    'Winger either shoots from outside the box or slides the forward in behind.',
    NULL, 109, 109, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (inverted)', 'Carry inside at speed, shoot or play through'),
    (2, 'Second forward', 'Curved run around the last defender into the box'),
    (3, 'Attacking midfielder', 'Switch the ball to the winger')
) AS v(so, role, job);

-- 30. pp.109-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Session 7: Attacking Combination Play', 'Circulate, switch, full back overlaps to cross',
    'Keeper, centre backs and holding midfielder move the ball quickly to shift the block, then switch to the far winger; the winger combines with forward/central midfielder and the full back overlaps (or receives a one-two past the line) to cross or cut back.',
    'Block shifted to one side; winger receives on the switch',
    'Arrive on the far flank with a free full back delivering behind the line for three forwards in the box.',
    NULL, 109, 110, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper and centre backs (Van der Sar, Evans, Smalling)', 'Circulate quickly, then switch'),
    (2, 'Holding midfielder (Carrick)', 'Keep the ball moving side to side'),
    (3, 'Winger (Nani)', 'Combine inside with forward and central midfielder'),
    (4, 'Full back (Evra / right back)', 'Overlap or play one-two with winger to get past the line and cross'),
    (5, 'Three forwards (Rooney, Berbatov, Chicharito)', 'Attack the box with timing and balance')
) AS v(so, role, job);

-- 31. pp.110-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Session 7: Attacking Combination Play', 'Through the middle to shoot from distance',
    'Instead of going wide, the ball is played into midfield and combined through the centre, finishing with a strike from outside the box or a pass out to the winger.',
    'Central lane open in front of the block',
    'Threaten centrally with shots from range when the block leaves space at its front.',
    NULL, 110, 110, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Anderson)', 'Receive from the keeper, play forward'),
    (2, 'Midfielders (Carrick, Gibson)', 'Combine through the centre'),
    (3, 'Forward (Berbatov)', 'Set the ball for the onrushing midfielder'),
    (4, 'Shooter / winger (Bebe)', 'Shoot from outside the box or receive the wide outlet')
) AS v(so, role, job);

-- 32. pp.114-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Session 8: Finishing', 'Link with the striker before finishing',
    'In tight spaces every attack goes into the forward first; once he connects, teammates make immediate supporting runs to take his lay-off and finish.',
    'Forward receives in the final zone',
    'Quick decisions and combinations with the striker produce finishes under pressure with minimal touches.',
    NULL, 114, 114, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward', 'Be the reference point, connect and lay off'),
    (2, 'Supporting attackers', 'Run immediately past or around the forward to receive'),
    (3, 'Ball carrier', 'Find the forward quickly')
) AS v(so, role, job);

-- 33. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'out_of_possession', 'Session 9: Defensive Shape, Pressing and Recovery', 'Pass and press the receiver (''click-clack'')',
    'As the ball travels to an opponent the nearest player is already moving to close him down, so the press lands as the ball arrives.',
    'Pass played to an opponent nearby',
    'Receiver has no time to turn or play forward.',
    NULL, 120, 120, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'Close down at speed on the pass, arrive with the ball'),
    (2, 'Next defender', 'Get ready for the following pass')
) AS v(so, role, job);

-- 34. pp.121-121
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'to_defend', 'Session 9: Defensive Shape, Pressing and Recovery', 'Press as a pair, recover fast on loss',
    'Defenders press together with correct distances to shut passing lanes; when the ball is lost the team instantly switches roles and recovers to its pressing positions.',
    'Possession lost or ball moves to a new area',
    'Win the ball back through coordinated pressure and quick recovery runs.',
    NULL, 121, 121, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two pressing players', 'Press together, keep distance, block lanes'),
    (2, 'Team losing the ball', 'Become defenders immediately and recover'),
    (3, 'All', 'Talk early to organise when possession changes')
) AS v(so, role, job);

-- 35. pp.122-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'out_of_possession', 'Session 9: Defensive Shape, Pressing and Recovery', 'Compact back five protect space behind',
    'A back four plus holding midfielder keep tight distances between players and lines to deny through passes and guard the space behind the line, delaying or pushing play wide.',
    'Opponent builds through midfield toward the line',
    'No through balls; on winning it the line steps up together and the ball goes forward.',
    NULL, 122, 122, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four (Ferdinand, Vidic, Evra, Brown)', 'Stay compact, protect space behind the line'),
    (2, 'Holding midfielder', 'Screen and close central passing lanes'),
    (3, 'Defending unit', 'Delay or force play wide'),
    (4, 'Whole line', 'Push up quickly together after winning the ball')
) AS v(so, role, job);

-- 36. pp.123-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'out_of_possession', 'Session 9: Defensive Shape, Pressing and Recovery', 'High press on cues, far side tucks',
    'Against a team playing out from the back, the side presses high collectively, stepping up on a bad touch or backward pass; the far winger shifts inside and the far full back covers behind, while defenders step into midfield when the ball goes there.',
    'Pressing cue: poor touch, back pass, ball into middle zone',
    'Deny space, block lanes and force mistakes to win the ball high.',
    NULL, 123, 123, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards (Berbatov, Rooney)', 'Lead the press on the cue'),
    (2, 'Midfielders', 'Press through onto the receivers'),
    (3, 'Far-side winger', 'Shuffle inside to close the centre'),
    (4, 'Far-side full back (Fabio)', 'Protect space in behind'),
    (5, 'Centre backs', 'Push through and press when ball enters middle zone')
) AS v(so, role, job);

-- 37. pp.126-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'to_attack', 'Session 10: Transition from Defence to Attack', 'Win it as a unit, play out to far zone',
    'Defenders outnumbered in possession press as one unit with good positions to block lanes and intercept, and on winning the ball they immediately pass away from the pressure into the free area.',
    'Interception or ball won',
    'Escape the crowded zone at once into open space.',
    NULL, 126, 126, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressing unit', 'Press together, block lanes, intercept'),
    (2, 'Ball winner', 'Play the first pass into the opposite free area'),
    (3, 'Free teammate', 'Wait in the open area as outlet')
) AS v(so, role, job);

-- 38. pp.127-128
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'to_attack', 'Session 10: Transition from Defence to Attack', 'Regain and counter with forward runs',
    'Once the ball is won, every player is released forward; the first pass goes forward into space and runners from different lines support while the opponent is still out of shape. If the ball is lost again, counter-press to regain.',
    'Ball won in own half / zonal block',
    'Score before the opposition can recover its defensive shape.',
    '4-3-3', 127, 128, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'Play forward into space immediately'),
    (2, 'Forwards', 'Run in behind and wide to stretch'),
    (3, 'Midfielders and full backs', 'Support with forward runs from deeper lines'),
    (4, 'All', 'If lost, counter-press straight away')
) AS v(so, role, job);

-- 39. pp.129-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'to_attack', 'Session 10: Transition from Defence to Attack', 'Deep block, then ball over high line',
    'Prepared for Manchester City away: sit in a compact deep block, and on regain play early over the top and wide behind their high, narrow back line for fast forwards.',
    'Ball won against a high, narrow defensive line',
    'Take the shortest route to goal using the pace of the front players.',
    NULL, 129, 129, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep block (midfield and defence)', 'Stay compact, win the ball'),
    (2, 'Ball winner / midfielder', 'Hit an early pass over the top into wide space'),
    (3, 'Fast forwards (Valencia, Rooney, Nani)', 'Run in behind the high line'),
    (4, 'Supporting forwards and midfielders', 'Follow up with runs to add scoring options')
) AS v(so, role, job);

-- 40. pp.136-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Chapter 4: 3-Ball Routine / Crossing Zones', 'Three crossing zones dictate the delivery',
    'The final third flanks are split into early, main and byline crossing zones; each zone has its own type of cross and box runners read where the wide player is to know which run and finish are needed.',
    'Wide player enters a crossing zone',
    'Delivery and box movement are aligned so crosses become far more effective.',
    NULL, 136, 144, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers and full backs', 'Know the zone and the delivery it calls for'),
    (2, 'Forwards and attacking midfielders', 'Anticipate the cross type and pick the matching run'),
    (3, 'Opposite winger', 'Attack the back post for in-swingers and long crosses')
) AS v(so, role, job);

-- 41. pp.137-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Chapter 4: 3-Ball Routine Example 1 (Early Crossing Zone)', 'Early zone: curled cross behind centre backs',
    'From the deeper wide area a winger or overlapping full back curls a low, hard cross around the defenders into the space behind the centre backs; a right-footer on the left can whip an in-swinger to the back post.',
    'Wide player free in the early crossing zone',
    'Forwards attack the space behind the back line at speed before it drops.',
    NULL, 137, 139, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger / full back (Giggs, Evra)', 'Deliver early, low and bending round the defence'),
    (2, 'Forwards (Rooney, Berbatov)', 'Run across near post, spot and back post'),
    (3, 'Central midfielder (Scholes)', 'Play the winger in high on the flank'),
    (4, 'Opposite winger', 'Arrive at the far post')
) AS v(so, role, job);

-- 42. pp.138-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Chapter 4: 3-Ball Routine (Ball 1)', 'Striker drops, partner plays midfielder through',
    'Central midfielder passes into a forward, who plays across to his strike partner dropping short; the dropping forward slides a pass between the centre backs for the midfielder''s late forward run.',
    'Forward receives in front of the back line with a partner dropping',
    'Midfielder runs onto a through ball in behind and shoots.',
    NULL, 138, 144, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Fletcher)', 'Pass in, then make a late run beyond the forwards'),
    (2, 'Forward (Rooney)', 'Receive and lay across'),
    (3, 'Second forward (Berbatov)', 'Drop off, thread the ball between centre backs')
) AS v(so, role, job);

-- 43. pp.140-141
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Chapter 4: 3-Ball Routine Example 2 (Main Crossing Zone)', 'Main zone: switch, overlap, floated cross',
    'Midfield switches long to the far winger, who drives inside and slips the overlapping full back down the flank; the full back floats a precise cross toward the six-yard area.',
    'Switch reaches the winger with full back on the overlap',
    'Precise floated delivery from the main zone to near post, spot or far post for timed runners.',
    NULL, 140, 141, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (Scholes)', 'Long aerial switch to the far winger'),
    (2, 'Winger (Ronaldo)', 'Drive inside, play the overlap'),
    (3, 'Full back (Neville)', 'Overlap and float the cross'),
    (4, 'Three box runners', 'Attack near post, spot and back post')
) AS v(so, role, job);

-- 44. pp.142-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Chapter 4: 3-Ball Routine Example 3 (Byline Crossing Zone)', 'Byline zone: drilled ball or cut-back',
    'Wide player gets to the byline and either drives the ball low and hard across the six-yard box, chips to the back post, or cuts it back to the penalty spot / edge of the area.',
    'Winger or overlapping full back reaches the byline',
    'Turn defenders facing their own goal and serve runners arriving late.',
    NULL, 142, 144, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Giggs, Ronaldo)', 'Dribble to the byline zone, choose low drive, chip or cut-back'),
    (2, 'Overlapping full back (Neville)', 'Reach the byline on the overlap and cut back'),
    (3, 'Forward (Rooney)', 'Attack the near post / penalty spot'),
    (4, 'Central midfielders (Scholes, Carrick)', 'Switch play to set up the byline attack')
) AS v(so, role, job);

-- 45. pp.146-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Chapter 5: Tactical Adaptability', 'Vs defensive sides: patience, rotations, width',
    'Against teams that sit deep the team stays patient in build-up, rotates players in midfield and wide areas, and keeps high width from wingers and full backs, accelerating when a moment appears.',
    'Opponent in a compact low block',
    'Pull the block apart and penetrate with combinations.',
    NULL, 146, 147, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs and holding midfielder', 'Circulate the ball quickly and patiently'),
    (2, 'Central midfielders', 'Rotate positions to unbalance markers'),
    (3, 'Wingers and full backs', 'Hold maximum width'),
    (4, 'Forwards', 'Penetrate through combinations when the gap opens')
) AS v(so, role, job);

-- 46. pp.147-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'out_of_possession', 'Chapter 5: Tactical Adaptability', 'Vs possession sides: compact block, counter wide',
    'Against possession-dominant opponents the team (4-4-2, 4-3-3 or 4-2-3-1 by need) defends in a compact block, transitions quickly and attacks the wide areas.',
    'Opponent dominates the ball',
    'Absorb, then hurt them on the break and in wide space.',
    NULL, 147, 147, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive block', 'Stay compact between the lines, protect the central channel'),
    (2, 'Midfield', 'Use collective pressing triggers, recover fast'),
    (3, 'Wingers and forwards', 'Break quickly into wide areas on regain')
) AS v(so, role, job);

-- 47. pp.147-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'set_piece', 'Chapter 5: Set Piece Preparation', 'Set pieces: near post, blocks, second balls',
    'Attacking set pieces use near-post runs, blocking movements and players placed for the second ball; defending set pieces use zonal jobs, blocking the opponent''s danger men, and organised transition after the clearance.',
    'Dead ball for or against',
    'Win the knock-out margins that set plays often decide.',
    NULL, 147, 147, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near-post runner', 'Attack the front post'),
    (2, 'Blockers', 'Screen markers to free the main target'),
    (3, 'Second-ball players', 'Sit at the edge for knock-downs and clearances'),
    (4, 'Zonal defenders', 'Hold their zones and block threats'),
    (5, 'Whole team after clearance', 'Organise the transition straight away')
) AS v(so, role, job);

-- 48. pp.151-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'out_of_possession', 'Ch5: How the Tactical Approach Evolved in Champions League Matches', 'Big-away-game discipline: wingers track full backs',
    'In tight European knockout games, especially away, the team favours stability and managing key moments over open play. Out of possession, each player''s job is fixed more strictly.',
    'Away leg or controlled knockout game',
    'Limit risk and stay compact, but keep counters and set pieces as ways to score.',
    NULL, 151, 151, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'track the opposing attacking full backs all the way back'),
    (2, 'Central midfielders', 'hold and control the central zones'),
    (3, 'Full backs', 'pick their moment to go forward instead of bombing on'),
    (4, 'Whole team', 'control tempo and protect possession at key moments')
) AS v(so, role, job);

-- 49. pp.151-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'to_attack', 'Ch5: How the Tactical Approach Evolved in Champions League Matches', 'Fast vertical counter behind the defence',
    'When the ball is won in a controlled European game, the team goes forward fast and vertically, into space behind the defenders.',
    'Possession won',
    'Hit the space behind before the opponent rebalances.',
    NULL, 151, 151, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins the ball', 'look for the early forward pass in behind'),
    (2, 'Nearby midfielders', 'give quick support around the ball'),
    (3, 'Forwards', 'run into the space behind the back line')
) AS v(so, role, job);

-- 50. pp.152-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Ch5: Preparation for AC Milan - MD-2 (Attack the Gates / Box to Box games)', 'Vary tempo, switch play, break lines',
    'Against an experienced side that is comfortable at its own pace, United change the tempo, often speed it up, and hit the wide areas with switches.',
    'Opponent block shifted to one side or a line left open',
    'Open a gap with a switch or a line-breaking pass, then drive through it and speed up to finish before the defence recovers.',
    NULL, 152, 155, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (Carrick, Scholes)', 'circulate and switch the point of attack, varying the speed'),
    (2, 'Wingers (Nani, Valencia)', 'hold width to receive switches'),
    (3, 'Ball carrier after breaking a line', 'attack forward with conviction'),
    (4, 'Supporting attackers', 'speed up the move right after the line is broken')
) AS v(so, role, job);

-- 51. pp.152-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'out_of_possession', 'Ch5: Preparation for AC Milan - Box to Box game / Second Leg tactical detail', 'Man-mark the deep playmaker (Park on Pirlo)',
    'Milan ran their game through deep playmaker Pirlo, so one industrious midfielder was given the job of playing on him and pressing him hard to deny their rhythm.',
    'Ball goes to or near the deep playmaker',
    'Stop the playmaker setting the tempo, pinch the ball off him and launch quick breaks.',
    NULL, 152, 158, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Park Ji-Sung (wide/central midfielder)', 'shadow Pirlo and press him intensely on every touch'),
    (2, 'Rest of midfield (Carrick, Fletcher)', 'keep central control while Park leaves his zone'),
    (3, 'Front players', 'be ready to break the moment Park intercepts')
) AS v(so, role, job);

-- 52. pp.162-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'to_attack', 'Ch6: Preparation for Possession Based Teams - Key Point', 'Intercept and counter before rebalance',
    'Reading passes and intercepting is the main regain tool against Arsenal. Quick forwards then break straight away, and 1v1s are sought in the wide areas where the opponent is weakest.',
    'Interception or turnover in midfield',
    'Score before the possession side gets its defensive balance back.',
    NULL, 162, 162, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Interceptor', 'play forward at once'),
    (2, 'Park Ji-Sung, Rooney, Ronaldo, Nani', 'break at speed into the spaces left open'),
    (3, 'Wide attackers', 'take on their full back 1v1')
) AS v(so, role, job);

-- 53. pp.162-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'out_of_possession', 'Ch6: Preparation for Possession Based Teams - Wenger''s Arsenal / 10v10 (+1) Pressing game', 'Press the ball carrier, stay with runners',
    'Against a quick-combination side (Arsenal built through Fabregas and van Persie), the man on the ball is pressed at once. Midfield pressure comes early and in numbers, units stay close together and every runner is tracked.',
    'Opponent tries to combine through central areas',
    'Deny time and space to combine and read forward passes to intercept.',
    NULL, 162, 164, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'chase down the man on the ball straight away'),
    (2, 'Midfielders', 'press early and in numbers and read the passing cues'),
    (3, 'All players', 'stay with their runners and do not let third-man runs go free'),
    (4, 'Defensive and midfield lines', 'keep short distances to cut central passing options')
) AS v(so, role, job);

-- 54. pp.164-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'to_defend', 'Ch6: 10v10 (+1) Pressing, Counter-pressing and Possession Under Pressure Game', 'Counter-press through collective midfield pressure',
    'When possession is lost against a possession side, the nearest players press at once and the midfield squeezes together to win it back before the opponent can settle.',
    'Ball lost',
    'Regain quickly in midfield and deny the opponent a calm build-up.',
    NULL, 164, 164, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players nearest the loss', 'press the new carrier immediately'),
    (2, 'Midfield unit', 'close in collectively and cut the escape passes'),
    (3, 'Players further away', 'pick up runners and anticipate the interception')
) AS v(so, role, job);

-- 55. pp.165-165
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'out_of_possession', 'Ch6: Midfield Block Pressing vs Build-Up from the Back Tactical Game', 'Pressing line triggers midfield block press',
    'The team waits in a midfield block while the opponent builds from the back. A set pressing line tells the forwards when to engage, and the midfielders step up to press as the ball moves into their line.',
    'Ball crosses the pressing line',
    'Coordinated press that wins the ball in midfield and goes for goal at once.',
    NULL, 165, 165, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards (Welbeck)', 'hold off until the ball reaches the pressing line, then engage the carrier'),
    (2, 'Midfielders (Fletcher, Carrick)', 'press the next line as the ball progresses, blocking passing lanes'),
    (3, 'Whole block', 'stay compact and press together, not one by one')
) AS v(so, role, job);

-- 56. pp.166-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Ch6: 10v10 (+GKs) Attacking Patterns Through and Around Arsenal''s Defence', 'Switch, find the pocket, spot the far-side run',
    'United attack through and around a possession side''s defence. The two central midfielders switch the play quickly, attackers look forward first, and lines are broken by finding players in the pocket or forwards dropping in.',
    'Centre back or central midfielder on the ball with no pressure on him',
    'Get in behind using one-twos, through balls or a diagonal to a far-side runner.',
    NULL, 166, 166, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (Carrick, Scholes)', 'move the ball fast from one side to the other'),
    (2, 'Unpressured centre back or midfielder', 'look up for runs in behind from the far side'),
    (3, 'Far-side full back, winger or forward (e.g. Young, Evra)', 'time a run in behind for the diagonal'),
    (4, 'Forwards and No.10 (Rooney, Welbeck)', 'drop into pockets to link with one-twos')
) AS v(so, role, job);

-- 57. pp.167-167
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Ch6: 11v11 (+1) Positional Roles and Team Structure Tactical Game', 'Keep shape: wide in possession, compact out',
    'In a full-team MD-2 rehearsal of the game plan, the team keeps its structure. It spreads wide and plays forward quickly when it has the ball, and stays compact and steps in to win it when it does not.',
    'Possession changes either way',
    'Disciplined unit structure that carries the match plan under realistic pressure.',
    NULL, 167, 167, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers and full backs', 'spread out wide in possession'),
    (2, 'Midfield (DMs, AM)', 'play forward quickly and step in to win it when the ball is lost'),
    (3, 'Forwards', 'make runs in behind'),
    (4, 'Back line', 'stay compact and keep the unit shape')
) AS v(so, role, job);

-- 58. pp.173-174
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'out_of_possession', 'Ch7: Training Preparation for Complete Teams - Title Rival Chelsea', 'Let the risky centre back carry, then spring',
    'Chelsea''s ball-playing centre back (David Luiz) likes to step out and take risks, so he is allowed controlled time on the ball. The team delays and holds shape, then presses aggressively once he has carried into midfield.',
    'Centre back has carried the ball into midfield',
    'Force mistakes and interceptions high in midfield, with the defence already out of position.',
    NULL, 173, 174, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'do not press the centre back early; screen passes instead'),
    (2, 'Midfielders', 'hold shape, then jump on him and on his passing options together'),
    (3, 'Whole team', 'judge when to delay engagement and when to press hard')
) AS v(so, role, job);

-- 59. pp.173-183
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Ch7: Chelsea prep / Attacking Combinations Part 2: Attack Wide Areas', 'Byline, cut-backs and low crosses vs aerial defence',
    'Against a physically dominant defence that wins headers (Terry, Cech), attacks go wide to the byline and finish with cut-backs and low crosses rather than high balls.',
    'Ball reaches a wide player near the final third',
    'Avoid the opponent''s aerial strength and create low finishing chances, then win the rebounds.',
    NULL, 173, 183, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder (Carrick)', 'receive from the GK and play forward to the central midfielders'),
    (2, 'Central midfielders (Cleverley, Rooney)', 'combine and release the winger'),
    (3, 'Wingers (Young, Valencia)', 'dribble to the byline and cut back or drive a low cross'),
    (4, 'Centre forward (van Persie) and late runners', 'attack near post, back post and edge of box, then follow up rebounds'),
    (5, 'Shooters', 'disguise the shot to avoid blocks')
) AS v(so, role, job);

-- 60. pp.174-180
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'to_attack', 'Ch7: Defensive Shape and Quick Counter Attacks into Space (10v10 / 8v8 / +GKs)', 'Compact shape, win it, break fast',
    'The team starts with an organised, compact block and presses together to win the ball. It then breaks away quickly with short link play, releasing the wide players and a centre-forward run in behind.',
    'Ball won by the compact block',
    'Reach the final third before the opponent recovers and finish with low crosses or cut-backs.',
    NULL, 174, 180, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four and midfield (Ferdinand, Evans, Carrick, Cleverley)', 'stay compact and press collectively to win it'),
    (2, 'Link players (Rooney)', 'give quick support angles for one-two link play out of the regain'),
    (3, 'Wide players (Valencia, Young)', 'sprint wide and forward to receive the release pass'),
    (4, 'Centre forward (van Persie)', 'run in behind the defence'),
    (5, 'Final third', 'finish with low crosses, cut-backs or low shots')
) AS v(so, role, job);

-- 61. pp.181-181
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'out_of_possession', 'Ch7: Defensive Unit Press and Cover to Screen Passes, Step in Early and Stop the Turn', 'Step in early, stop the turn',
    'When the ball goes into the forwards and attacking midfielders in front of the box, the back four presses and covers as an organised compact unit. The defensive midfielder screens passes into the attackers.',
    'Pass played into an attacker''s feet between the lines',
    'Get tight before the receiver can turn and play forward, and intercept where possible.',
    NULL, 181, 181, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defender nearest the receiver (Rafael, Ferdinand, Evans, Evra)', 'step in early and get on top of him before he turns'),
    (2, 'Other defenders', 'cover behind the one who steps out and keep the line compact'),
    (3, 'Defensive midfielder (Carrick)', 'screen in front of the back four and intercept passes into attackers')
) AS v(so, role, job);

-- 62. pp.182-182
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'to_attack', 'Ch7: Attacking Combinations Part 1/3: Counter Attack', 'Rehearsed counter route: six-ten-nine-wide-cross',
    'A counter pattern rehearsed unopposed and then against a back four. The holding midfielder plays into the No.10, the striker lays off, the ball is released to a winger who carries forward, and the cross is attacked by runners.',
    'Ball won by the holding midfielder',
    'Turn a regain into a cross-and-finish in a few quick passes, with fixed rotations.',
    NULL, 182, 182, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Carrick)', 'play forward into the No.10 or central midfielder'),
    (2, 'No.10 (Rooney)', 'combine with the striker and release the winger'),
    (3, 'Striker (van Persie)', 'show short to set the ball, then spin into the box'),
    (4, 'Winger (Valencia)', 'dribble forward and deliver the cross'),
    (5, 'Far-side winger (Young)', 'run in to the back post')
) AS v(so, role, job);

-- 63. pp.184-189
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Ch7/Ch8: Central Shift and Shoot; Shots from Distance; Attacking the Final Third', 'Short central combos to shoot from edge of box',
    'Against a deep or crowded box, attackers play short, quick combinations in the centre to open a window for a shot from the zone just outside the box. Deep defenders are forced to step out, and the rebounds are attacked.',
    'Ball shifted into the central zone just outside the box',
    'Get a clean shot from distance or draw defenders out of their line to open space behind.',
    NULL, 184, 189, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders (Cleverley, Rooney)', 'play one- and two-touch combinations to create shooting space'),
    (2, 'Centre forward (van Persie)', 'set the ball back and occupy the centre backs'),
    (3, 'Wingers', 'move inside or hold width to keep the block stretched'),
    (4, 'Late midfield runners', 'arrive in the box for cut-backs and rebounds')
) AS v(so, role, job);

-- 64. pp.188-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Ch8: Training Preparation to Play Against Compact Teams or Low Blocks', 'Stretch the low block: fast circulation, width, switches',
    'A low block shrinks the space between its lines and pushes play wide, so it has to be stretched both ways. Width is held, the ball moves quickly with one or two touches, and the play is switched until gaps appear. The team stays patient and keeps its tempo.',
    'Opponent settles in a deep compact block',
    'Move the defence side to side until a gap opens, without forcing low-percentage attacks.',
    NULL, 188, 190, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'stay wide to isolate the opposing full backs'),
    (2, 'Full backs', 'overlap or underlap to make 2v1s on the flank'),
    (3, 'Midfielders', 'circulate quickly and switch from one flank to the other'),
    (4, 'All players', 'stay patient and composed, trusting the structure even when an attack does not lead to a chance')
) AS v(so, role, job);

-- 65. pp.189-189
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Ch8: Movement Between the Lines', 'Pockets: midfield finds space, strikers drop',
    'Against a compact defence, players need to receive between the defensive lines. Midfielders look for pockets of space, strikers drop in to link, and attacking midfielders swap positions to unsettle the markers.',
    'Gap opens between opponent midfield and defence',
    'Receive and turn between the lines to destabilise the block.',
    NULL, 189, 189, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'find pockets of space between the lines'),
    (2, 'Strikers', 'drop short to link play'),
    (3, 'Attacking midfielders', 'rotate positions to pull markers'),
    (4, 'Receiver', 'turn quickly in tight space or combine around the box')
) AS v(so, role, job);

-- 66. pp.189-189
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Ch8: Third Man Runs and Combinations', 'Third-man runs and blind-side runs',
    'One of the main ways to break a compact team is the third-man combination: A passes to B, and B sets the ball straight away for C, who is running forward. Quick wall passes, blind-side runs and overlap or underlap movements are added.',
    'Pass played into a player with his back to goal',
    'Get a runner through the defensive line faster than the block can shift.',
    NULL, 189, 189, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer (player A)', 'play into the set-up player'),
    (2, 'Set-up player (player B)', 'lay off first time to the runner'),
    (3, 'Third man (player C)', 'time a forward run, often on the defender''s blind side'),
    (4, 'Full back or midfielder', 'overlap or underlap to add a runner')
) AS v(so, role, job);

-- 67. pp.190-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'to_defend', 'Ch8: Counter-pressing After Losing Possession', 'Rest defence and counter-press vs low block',
    'Pushing many players forward against a low block leaves the team open to counters. Players keep compact defensive positions behind the ball while attacking, press at once on a loss and make quick recovery runs.',
    'Ball lost in the final third',
    'Keep attacking pressure on while stopping the opponent''s counter.',
    NULL, 190, 190, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players near the ball', 'press immediately after the loss'),
    (2, 'Holding players and centre backs', 'stay compact behind the ball during attacks'),
    (3, 'Players beaten by the turnover', 'sprint back on recovery runs')
) AS v(so, role, job);

-- 68. pp.191-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Ch8: Exploit Width Against a Narrow Diamond Midfield (phase of play + 8v8 game)', 'Combine centrally, release wide vs diamond',
    'Against a narrow diamond midfield (West Brom), United circulate centrally to draw the diamond in, then release the full back or winger into the free flank. The full back''s run is timed and coordinated box runs attack the cross. In build-up, the centre-back and midfield roles rotate.',
    'Diamond pinched in on central circulation, flank free',
    'Use the space the diamond leaves wide to deliver crosses into well-timed box runs.',
    '4-1-2-1-2', 191, 192, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs and central midfielders (Grimshaw, Carrick, Cleverley, Giggs)', 'rotate roles and combine in the centre first'),
    (2, 'Full back (Valencia at right back)', 'time the run so the pass meets him in space'),
    (3, 'Wide players', 'receive early after halfway and cross'),
    (4, 'Box attackers (Chicharito, Kagawa, Anderson)', 'split runs to front post, back post and edge of box')
) AS v(so, role, job);

-- 69. pp.193-193
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Ch8: Breaking Down a Compact Narrow Block with Switches and Crosses', 'Keep width, shift and switch before crossing',
    'Against a narrow block that defends within the width of the box (Bolton), United keep their shape to stretch it. The ball is moved quickly to shift the block, then switched to the far flank before the cross.',
    'Block shifted across to the ball side',
    'Cross from the weak side before the narrow block can slide over.',
    NULL, 193, 193, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide players (Ronaldo, Tevez)', 'stay wide on both flanks'),
    (2, 'Centre backs and midfielders (Vidic, Carrick, Fletcher)', 'move the ball fast and switch the play'),
    (3, 'Full backs (O''Shea, Neville)', 'support out wide to receive the switch'),
    (4, 'Box attackers (Berbatov, Anderson)', 'time runs to front post, back post and edge of box')
) AS v(so, role, job);

-- 70. pp.194-195
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Ch8: Switch Play Quickly to Exploit Wide Zones / Play Wide Early for Crosses vs a Compact Block', 'Switch early to wide zones vs 4-1-4-1',
    'Against a compact 4-1-4-1 block (QPR) that stays narrow, United use only quick combinations in the centre to shift it. They then switch early to the wide players, who attack crossing zones and deliver early crosses into timed box runs.',
    'Ball enters the attacking half with the block compact and narrow',
    'Get crosses in from the open flanks before the block slides across.',
    '4-1-4-1', 194, 195, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Ferdinand, Evans, Smalling)', 'build up and play forward early'),
    (2, 'Central midfielders (Carrick, Scholes, Rooney)', 'move the ball quickly in the centre, then switch'),
    (3, 'Wide players (Young, Valencia)', 'receive early in the wide zones and cross from the crossing zones'),
    (4, 'Full backs (Evra, Rafael)', 'support wide and give an extra option for the switch'),
    (5, 'Box attackers (Welbeck)', 'time box runs (no offsides) to front post, back post and edge of box')
) AS v(so, role, job);

-- 71. pp.196-196
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'ren-meulensteen-man-utd-methods-of-success-vol-2-full-season-plan-training-sessi'), 'in_possession', 'Ch8: Central and Wide Overloads Against a Compact Defence', 'Read the overload: 6v4 central or 2v1 wide',
    'Against a compact defence, the attack goes wherever the numbers are. If the ball goes central there is a 6v4 to attack through the middle. If it goes wide, the winger and full back make a 2v1 against one defender and cross.',
    'First pass from the GK goes central or wide',
    'Attack the numerical advantage quickly and decisively before the defence balances.',
    NULL, 196, 196, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders and forwards (Giggs, Rooney)', 'combine fast through the middle in the 6v4'),
    (2, 'Winger and full back (Ronaldo, Martin)', 'make the 2v1 and cross'),
    (3, 'Central players', 'support, then run to front post, back post and edge of box'),
    (4, 'Rotating central players', 'rotate to stay available')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('2106-coaching-book-meulensteen-man-utd-vol2-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
