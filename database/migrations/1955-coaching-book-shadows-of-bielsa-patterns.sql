-- 1955 📚 Coaching book patterns: Jed C. Davies, "The Football Philosophy In
-- Shadows of Marcelo Bielsa".  Every page (1-247) read.  Unlike the Terzis
-- match logs this is a philosophy book, so a "pattern" here is each named
-- on-pitch behaviour or principle the author describes (AAA, Pre-AAA, UBT,
-- OIO, WSFB, O-I, rotations, pressing traps, formation roles), written up in
-- OUR OWN WORDS with app page numbers as the citation and who does what.
-- Biography, anecdotes, theory without an on-pitch behaviour and drill
-- set-ups are left out.  Owner's personal library.  (James 11/26 'continue
-- with the reading of the coach viewer books')
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'The Football Philosophy In Shadows of Marcelo Bielsa',
    author      = 'Jed C. Davies',
    team        = 'Bielsa and the Bielsistas',
    season      = '2012-16',
    method_note = 'Not a match log: a coaching-philosophy book (written 2012-16) on Bielsa''s football and the coaches it shaped, built from interviews, translated material and match study (Athletic Bilbao 2012-13, Chile, Oxford, Wales and others). It names its own play patterns: Advanced Area Actions (AAA) into the Gold Zone, Pre-AAA ways to stretch a compact block, Up-Back-Through (UBT), Out-In-Out (OIO), the weak-side full back switch (WSFB), Overload-to-Isolate (O-I), rotations, FON+C scanning, and Bielsa''s 1-4-2-3-1 / 1-3-3-1-3 / 1-3-4-2-1 roles, then a training methodology for each. Patterns here are those named behaviours, in our words; drill set-ups are left out.'
WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa');

-- 1. pp.15-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Interview (Pre) / Principles of play', 'Objective ladder and six key spaces',
    'In possession the team ranks its aims: score, then assist, then set up the assist, then get the ball into one of six key spaces (behind or in front of the opposition centre backs and full backs, behind their central or wide midfielders).',
    'Any possession',
    'Every pass is judged by how high up that ladder it moves the team.',
    NULL, 15, 16, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player on the ball', 'pick the highest available objective'),
    (2, 'Forwards', 'occupy spaces behind or in front of the defenders'),
    (3, 'Supporting players', 'offer the next option when the higher ones are closed')
) AS v(so, role, job);

-- 2. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Interview (Pre) / Communication', 'Centre back drives to pull a midfielder',
    'A centre back carries the ball forward to draw an opposing central midfielder out of his line, opening the space behind him for a teammate (in its simplest form, a 2v1).',
    'Opposition midfield compact, centre back unpressed',
    'Remove a midfielder from the block and release the freed teammate.',
    NULL, 16, 16, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central defender', 'drive at the midfield line to attract a midfielder'),
    (2, 'Midfielder behind the line', 'exploit the space the drawn midfielder leaves'),
    (3, 'Striker', 'run behind the nearest centre back so he can''t step up to cover')
) AS v(so, role, job);

-- 3. pp.21-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'out_of_possession', '01 Bielsa: The Legacy', 'Ajax 1995: midfielders track wingers, back three narrow',
    'Van Gaal''s 1-3-3-3-1 Ajax (in the 1995 final against AC Milan) kept its wingers high when defending. The two outside central midfielders tracked the opposing wingers into the deep wide spaces, the back three stayed narrow, and the No.10 dropped in beside the holding midfielder. Bielsa later adopted this idea.',
    'Ball lost / opponent building through wide areas',
    'Keep a narrow central back unit and the front wingers in counter positions while still covering the wide channels.',
    NULL, 21, 22, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Outside central midfielders (Davids, R. de Boer)', 'track opposing wingers back into deep wide spaces'),
    (2, 'Back three (F. de Boer, Blind, Reiziger)', 'stay narrow, defend the central goal area'),
    (3, 'No.10 (Litmanen)', 'drop back to form a midfield two with the holding midfielder'),
    (4, 'Holding midfielder (Rijkaard)', 'screen the centre'),
    (5, 'Wingers (Overmars, George)', 'stay high')
) AS v(so, role, job);

-- 4. pp.25-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '02 The Common Idea', 'Football as 2 vs 1s: beat a flat line',
    'When a flat line of defenders guards a target player, only the defender nearest the passing lane really counts, so the situation is a 2v1. A near supporter drops and offers a bounce pass to draw that defender out, and then the vertical pass goes through.',
    'Defenders lined up flat across the passing lane',
    'Turn the situation into a 2v1 and pass vertically to penetrate.',
    NULL, 25, 27, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player A (on ball)', 'aim to transfer the ball vertically to B'),
    (2, 'Near supporter', 'drop and bounce a first-line pass to draw the active defender'),
    (3, 'Player B (target)', 'move into the 2v1 channel left open')
) AS v(so, role, job);

-- 5. pp.26-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'out_of_possession', '02 The Common Idea', 'Defending the third-line pass (6v2 rondo)',
    'Two defenders stand staggered on different lines, never flat. They block the passes around them and leave the through pass looking open while both keep an interception point on it, and where possible they also cut out passes in front.',
    'Opponent circulating around a small block',
    'Two defenders cover six attackers by inviting the through pass into two interception angles.',
    NULL, 26, 26, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First defender', 'stand off-set from the partner and cut the pass around one side'),
    (2, 'Second defender', 'stand on a different line and cut the pass around the other side, a second angle on the through pass'),
    (3, 'Both', 'intercept the first-line pass if close enough')
) AS v(so, role, job);

-- 6. pp.28-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '03 Advanced Area Actions (AAA)', 'Advanced Area Action (AAA): pull a defender out',
    'An AAA is any pass or dribble into the space between the opposition midfield and defence, or behind the defensive line. Its aim is to drag a defender out of his slot and open the gap behind for a teammate.',
    'Space between the lines or behind the line is reachable',
    'Open a gap between defenders for a teammate to exploit.',
    NULL, 28, 31, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver between the lines', 'receive in the midfield-defence channel and draw a centre back out'),
    (2, 'Passer', 'play into the in-between or behind space'),
    (3, 'Runner', 'attack the gap the drawn defender leaves')
) AS v(so, role, job);

-- 7. pp.31-31
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '03 Advanced Area Actions (AAA)', 'Square pass between lines then through',
    'A midfielder between the lines plays a square pass inside the block rather than backwards. The pass drags a centre back out of position and sets up an immediate through ball at goal.',
    'Attacking midfielder receives between lines with a CB tracking',
    'Keep the sequence moving forward and finish it with a through ball.',
    NULL, 31, 31, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder', 'play square between the lines to drag a centre back'),
    (2, 'Teammate between lines', 'receive and slide the through ball'),
    (3, 'Striker', 'run into the vacated CB slot')
) AS v(so, role, job);

-- 8. pp.34-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '04 Principles of Play', 'Situation-to-action-script priority order',
    'Penetration comes first: make an AAA by pass or dribble when possible. If not, stretch the opponent across the pitch or from front to back, or pull their lines flat. If that fails too, switch the ball at least two lanes. The last resort is to keep the ball and work the way out until those options return.',
    'Each possession phase',
    'The team shares one decision order in which every structure serves penetration.',
    NULL, 34, 35, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player on the ball', 'attempt the AAA first'),
    (2, 'Team shape', 'spread horizontally/vertically to create AAA gaps'),
    (3, 'Far-side players', 'offer the switch two or more lanes away'),
    (4, 'Nearby supporters', 'offer safe retention options')
) AS v(so, role, job);

-- 9. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '05 Advanced Area Actions: Further Detail', 'Aim AAAs at the Gold Zone',
    'Every AAA is meant to lead to a clear-cut shot from the central box area in front of goal (the ''Castle'' / ''Gold Zone''), where most goals come from.',
    'Final third entry',
    'Shoot from high-value central zones, not from low-percentage areas.',
    NULL, 36, 36, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attackers', 'get shots from inside the central box zone'),
    (2, 'Creators', 'deliver into the Gold Zone rather than shoot from outside')
) AS v(so, role, job);

-- 10. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '05 Advanced Area Actions: Further Detail', 'In front of the CBs: draw and third man',
    'A player who receives in front of the centre backs brings one of them out to meet him. He can beat that defender 1v1, or the space behind is taken by a third man run (up-back-through).',
    'Receiver turns in the space in front of the centre backs',
    'Create a goal chance from the slot the drawn centre back leaves.',
    NULL, 37, 37, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver in front of CBs', 'draw a centre back, beat him or lay off'),
    (2, 'Third man', 'run into the vacated slot behind'),
    (3, 'Passer', 'play the third-man ball through')
) AS v(so, role, job);

-- 11. pp.38-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '05 Advanced Area Actions: Further Detail', 'In front of the FB: exploit the chain reaction',
    'When the full back steps up to press, the nearest centre back slides across to cover him and the other centre back is meant to tuck in for balance. That last move is often late. The strikers drift onto the far centre back and then attack the gap between the two centre backs (examples: Vardy v Man Utd 2015, Gomis).',
    'Opposition full back steps out to engage',
    'Exploit the late covering movement of the far centre back.',
    NULL, 38, 39, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player', 'receive ahead of the full back and invite him out'),
    (2, 'Strikers', 'drift onto the far centre back, then run into the gap between the centre backs'),
    (3, 'Passer', 'play diagonally into the gap between the centre backs')
) AS v(so, role, job);

-- 12. pp.40-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '05 Advanced Area Actions: Further Detail', 'Behind the FB: punish the cover',
    'Once a player gets behind the full back, the defence answers in one of two ways. If a centre back goes out, the box is short of defenders, so cross. If the holding midfielder drops to cover, look for the cut-back.',
    'Ball carrier gets beyond the full back',
    'Pick the delivery that exploits whichever cover the opponent chooses.',
    NULL, 40, 41, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide carrier', 'get beyond the full back by 1v1, overlap or underlap'),
    (2, 'Box runners', 'attack the weakened box when a CB has gone out'),
    (3, 'Cut-back receiver', 'arrive in the space the holding midfielder has left')
) AS v(so, role, job);

-- 13. pp.42-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '05 Advanced Area Actions: Further Detail', 'Mixed positions between defenders',
    'Attackers stand on the diagonal between two defenders, for example between the two centre backs in the midfield-defence channel, so neither defender is clearly responsible. Out wide the same idea drags the full back across and creates a 2v1.',
    'Opposition defending zonally in lines',
    'Gain space to turn and unbalance the defence whichever defender comes out.',
    NULL, 42, 43, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacker in mixed position', 'stand diagonally between two defenders and receive'),
    (2, 'Wide pair', 'make a 2v1 against the full back once he is drawn'),
    (3, 'Passer', 'play into the angled pocket')
) AS v(so, role, job);

-- 14. pp.46-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '06 Pre-Advanced Area Actions', 'Three pre-AAA processes against compact blocks',
    'Before any AAA the team asks three questions. Can we stretch the opponent across the pitch to open channels? Can we stretch them from front to back to make the space between their midfield and defence bigger? Can we remove a layered midfield, or find the direction in which their lines are flat?',
    'Opponent compact horizontally, vertically or layered',
    'Create the conditions for an AAA.',
    NULL, 46, 47, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Team', 'diagnose which kind of compactness the opponent has'),
    (2, 'Wide players', 'stretch the width'),
    (3, 'Strikers', 'stretch the depth'),
    (4, 'Midfielders', 'attack layers or find flat lines')
) AS v(so, role, job);

-- 15. pp.48-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '06 Pre-AAA, Section 1.1', 'Principle of the diamond',
    'Four teammates form a diamond around two defenders. The bottom player passes to one side (a pass in front of the defenders) so a defender has to move across, and the ball is bounced back. That opens the pass through to the top of the diamond, or the pass around the other side. In a match the diamond might be a centre back, a full back, a midfielder dropping into a pocket, and a winger or striker at the top.',
    'Two defenders blocking the through pass',
    'Move the ball faster than the defenders can shift and open the through pass.',
    NULL, 48, 50, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Bottom of diamond (ball-playing CB or deep midfielder)', 'start with a pass to one side, then look for the through pass'),
    (2, 'Wide point (full back)', 'receive the pass to the side and bounce it back'),
    (3, 'Other side point (dropping central midfielder)', 'offer the pass around the other side'),
    (4, 'Top of diamond (winger or striker dropped into the pocket)', 'receive the through pass behind the midfield')
) AS v(so, role, job);

-- 16. pp.51-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '06 Pre-AAA, Section 1.2 / Overload-to-Isolate (O-I)', 'Overload-to-Isolate (O-I)',
    'The team stacks one side with a structural overload (Chile v Switzerland 2010 used a left winger, a wide left midfielder and a left back) so the low block slides across. The ball is then switched to the far wing-back, who is left 1v1 or 1v0. Every switch also forces the block to cover a wider area, which opens channels through the middle.',
    'Disciplined compact low block',
    'Win an isolated 1v1 on the far flank and stretch the block''s horizontal shift so central penetration opens up.',
    NULL, 51, 56, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Overload side (left winger, wide midfielder, left back)', 'draw the block across'),
    (2, 'Isolated far wing-back (Isla)', 'stay wide and attack after the switch'),
    (3, 'Central attackers between the lines (Valdivia, Fernandez, Sanchez)', 'float in the spaces between the lines and attack the channels that open'),
    (4, 'Central midfielder', 'deliver the quick switch')
) AS v(so, role, job);

-- 17. pp.55-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '06 Pre-AAA, Section 1.2', 'Underload-to-Overload: bait then switch',
    'The team plays into an underloaded area on purpose to set off the opponent''s press, then comes straight out and switches to the weak side within four or five seconds. Against a centre back who steps out sideways, a wide player draws the full back and a second runner pulls the centre back wide, leaving the box weak.',
    'Opponent presses wherever it has numbers',
    'Use the opponent''s own pressing trigger to move them, then exploit the far side.',
    NULL, 55, 56, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players in the underload', 'invite pressure, then release quickly'),
    (2, 'Switch player', 'move the ball to the weak side within about 5 seconds'),
    (3, 'Weak-side players', 'attack the unprotected flank'),
    (4, 'Second runner', 'pull the covering centre back wide')
) AS v(so, role, job);

-- 18. pp.55-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'out_of_possession', '06 Pre-AAA, Section 1.2', 'Touchline as best defender trap',
    'The defending team forces the opponent''s build-up towards one flank and closes in to trap the ball against the touchline, pressing where it has more players.',
    'Ball played to a wide player / numerical superiority near ball',
    'Win the ball in a wide area where the opponent has few exits.',
    NULL, 55, 56, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near-side presser', 'show the ball carrier towards the touchline'),
    (2, 'Ball-side teammates', 'flock to the area and lock it with extra numbers'),
    (3, 'Far side', 'shift across, leaving only the weak side open')
) AS v(so, role, job);

-- 19. pp.57-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'out_of_possession', '06 Pre-AAA, Section 1.3 (Oxford 2013/14)', 'Diamond trap: strikers wide, double the receiver',
    'In a 1-4-1-4-2 diamond, the two strikers sit wide between the opposition full backs and centre backs to stop passes or long balls to the full backs, which forces play into the midfield diamond. On any pass into the trap the nearest players double the receiver and everyone else takes the nearest free man. If the long ball goes to a winger, the nearest defender takes him and the libero drops back in. Every team they faced used a 1-4-3-3.',
    'Opposition centre back on the ball',
    'Make the opponent choose between a long ball and a pass into a central trap, then win it there.',
    '4-3-3', 57, 59, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two strikers', 'screen the passes to the full backs from wide-centre positions'),
    (2, 'Midfield diamond', 'trap, double the receiver and stop forward passes'),
    (3, 'Libero (Riddell)', 'step up to the nearest free man, then drop back into central defence'),
    (4, 'Nearest defender', 'deal with a long ball to the winger')
) AS v(so, role, job);

-- 20. pp.57-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '06 Pre-AAA, Section 1.3 (Oxford 2013/14)', 'Libero build-up with tucked full backs',
    'In possession the libero centre back steps into defensive midfield unless a full back is in trouble. The full backs tuck in to form a back three across the full width. The wide players of the diamond split to the touchlines, so the opposition midfield either follows them and opens passing channels, or leaves them free.',
    'Build-up from the back',
    'Get numbers in the first phase and pull the opposition midfield wide to open channels for the strikers or the No.10.',
    NULL, 57, 59, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Libero (Riddell)', 'sit in defensive midfield and play the forward passes'),
    (2, 'Full backs', 'tuck in to form a back three'),
    (3, 'Diamond wide players (Arambasic, Morgan)', 'split wide to drag the opposition midfield'),
    (4, 'Strikers and No.10 (Gomarsall)', 'float between the lines for channel passes')
) AS v(so, role, job);

-- 21. pp.61-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '06 Pre-AAA, Section 2.1', 'Invite pressure, then play beyond',
    'Short first-line passes, a centre back driving forward, holding the ball still (la pausa), a dribble past a man, or a deliberately loose touch all invite the opposition midfield to step out. The strikers keep the defensive line pinned back. As soon as the space opens the team plays in behind the midfield, for example: centre back to centre back, then into the striker in the AAA space, a lay-off to a forward-facing supporter, a through ball to a winger running diagonally, and a cut-back.',
    'Opposition midfield and defence compact vertically',
    'Make the gap between midfield and defence bigger and play into it straight away.',
    NULL, 61, 62, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'first-line passes, drive or pause to attract the press'),
    (2, 'Striker', 'start high to stretch the line, then drop to receive the AAA pass'),
    (3, 'Forward-facing supporter', 'receive the lay-off and play the through ball'),
    (4, 'Winger', 'make the diagonal run onto the through ball'),
    (5, 'Late arriver', 'finish the cut-back')
) AS v(so, role, job);

-- 22. pp.62-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'to_defend', '06 Pre-AAA, Section 2.2', 'Counter-press within about 5.5 seconds',
    'On losing the ball the team presses hard straight away, before the opponent can switch from its compact defensive shape to its attacking shape. Data suggests the first presser has about 2.3 seconds and the second about 5.5. Some teams build attacks down one side so that, if the ball is lost there, many players are already close enough to counter-press.',
    'Ball lost, especially in the opposition half',
    'Win the ball back before the opponent can play out of pressure.',
    NULL, 62, 63, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'First presser', 'close down the new ball carrier within about 2 seconds'),
    (2, 'Second presser', 'arrive within about 5.5 seconds to force the error'),
    (3, 'Nearby players', 'shut off the outlets around the ball')
) AS v(so, role, job);

-- 23. pp.62-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'out_of_possession', '06 Pre-AAA, Section 2.2', 'Pressing triggers: no control on the ball',
    'The block leaves its compact shape to press as a group when the receiver doesn''t have control. Triggers include a bouncing ball, a poor first touch, a ball that hasn''t yet reached the player, a slow or long backward pass, a receiver standing side-on or with his back to the target, a floated pass, a player turning to switch, the ball on his weak foot, and square short-to-medium passes. Teams can also set pressing traps, for example offering half a space and then closing it, and the attacking side can fake these triggers to draw players out.',
    'A control-breaking cue on the ball',
    'Press only when the opponent is least able to play through.',
    NULL, 62, 64, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'spot the cue and press'),
    (2, 'Pressing unit', 'press as a pack and cover the spaces between opponents'),
    (3, 'Rest of block', 'stay compact until the trigger')
) AS v(so, role, job);

-- 24. pp.63-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'to_attack', '06 Pre-AAA, Section 2.2', 'On regain: release or switch at once',
    'Instead of dribbling out, the player who wins the ball gives it to the nearest open teammate (as Barcelona did), or the team switches play straight away, so attackers can get into their attacking shape and the opponent''s counter-press is beaten.',
    'Ball won or intercepted',
    'Escape the immediate counter-press and keep possession.',
    NULL, 63, 63, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'release to the nearest open man'),
    (2, 'First receiver', 'scan and switch away from the pressure'),
    (3, 'Attackers', 'move into the attacking shape')
) AS v(so, role, job);

-- 25. pp.64-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '06 Pre-AAA, Section 2.3 (Wales 2011)', 'Deep full backs free wingers 1v1',
    'Wales (1-4-1-4-1 under Gary Speed) kept their full backs deeper in the pre-AAA phase, so the opposing wingers had no runners to follow back. Their midfield became a 3v3 or 2v2 for the central midfielders, and the wide midfield spaces opened for the wingers. The wingers dropped a little to receive, turn and run at their full back, or played a one-two with the full back. Full backs pushed high would only have packed the midfield 5v5.',
    'Opponent''s midfield set up to match ours',
    'Create isolated 1v1s for the star wingers and a smaller midfield battle for the creators.',
    NULL, 64, 66, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'stay deep, offer the one-two to the winger'),
    (2, 'Wingers (Bale, Bellamy)', 'drop slightly, receive, turn and run at the defender'),
    (3, 'Central midfielders (Ramsey, Allen)', 'use the 3v3 or 2v2 to get on the ball between the lines'),
    (4, 'Lone striker', 'pin the centre backs')
) AS v(so, role, job);

-- 26. pp.66-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '06 Pre-AAA, Section 2.3', 'Inverted full backs (Guardiola''s Bayern)',
    'The full backs move into central midfield positions when the team has the ball. The wingers get licence to drop between the opposition wide midfielder and full back, and the creative midfielders are freed to receive in the AAA space. With three at the back the opponent is pulled into a 1-4-4-2 shape that is easier to play through. Bayern''s animation runs from the defensive shape to this attacking one: full backs step inside, the holding midfielder drops between the centre backs.',
    'Possession in build-up / defensive shape turning into attack',
    'Gain numbers in the middle and pull opposition midfielders out of their slots to open the space between the lines.',
    NULL, 66, 67, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (Rafinha, Alaba)', 'move inside into midfield'),
    (2, 'Holding midfielder', 'drop in between the centre backs to form a back three'),
    (3, 'Wingers (Robben, Ribery)', 'hold the touchline or drop between the wide midfielder and full back'),
    (4, 'Creative midfielders (Thiago)', 'receive in the AAA space')
) AS v(so, role, job);

-- 27. pp.67-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '06 Pre-AAA, Section 3', 'Removing layers of the midfield',
    'When the opposition midfield is layered (a holding player behind a line), the team targets the player who creates the layer and pulls the line flat. There are four ways. The target player can play a wall pass for a teammate to take the AAA space. He can play the wall pass and spin in behind his marker. He can turn and dribble past the displaced marker into the AAA space. Or he can move his marker without the ball before stepping back into the space.',
    'Opposition midfield staggered in layers',
    'Turn a layered midfield into flat lines so the AAA space opens.',
    NULL, 67, 70, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target attacker (No.10)', 'draw the layering midfielder to him, wall pass or spin in behind'),
    (2, 'Passer (deep midfielder)', 'play into the target to invite pressure'),
    (3, 'Third man (winger or full back)', 'take the AAA pass in the space created')
) AS v(so, role, job);

-- 28. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '06 Pre-AAA, Section 3', 'Find the flat direction with angles',
    'A midfield is always flat in some direction. The player on the ball dribbles in the pre-AAA space to change the angle, and the receiver shifts sideways between the diagonal lines, until a pocket opens behind a line that is flat from that angle.',
    'Diagonal midfield lines closing the straight pass',
    'Reach the AAA space through the diagonal pocket and still pull a defender out of his slot.',
    NULL, 70, 70, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'dribble to create a new passing angle'),
    (2, 'Receiver (No.10)', 'slide sideways to the pocket behind the flat line')
) AS v(so, role, job);

-- 29. pp.71-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', '06 Pre-AAA, Section 3.1 (Slovenia case study)', 'Wide-in-through vs 1-4-2-3-1',
    'The 1-4-2-3-1 protects the area in front of its two centre backs with a layered midfield. The team plays wide to a full back to draw the wide attacking midfielder, comes back inside to a player moving into the space he left, which pulls a holding midfielder out of his slot, and then plays through into the AAA space in front of the centre backs. Done well, this pulls the opponent into a flat 1-4-1-4-1 and invites the slow centre backs to step out.',
    'Opponent in 1-4-2-3-1 with layered midfield',
    'Remove the holding midfielder from in front of the centre backs and attack that space.',
    '4-2-3-1', 71, 72, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back', 'start the move with a pass wide'),
    (2, 'Full back', 'receive wide to draw the wide attacking midfielder'),
    (3, 'Central midfielder', 'move into the vacated inside space, receive and draw the holding midfielder'),
    (4, 'Attacker between lines', 'receive the through pass in front of the centre backs')
) AS v(so, role, job);

-- 30. pp.73-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 8: Retain & ''Play Your Way Out''', 'Principles of play priority order',
    'Each new pass asks in order: (1) can we make an Advanced Area Action (pass to feet or dribble with control between/beyond lines); (2) if not, can a pre-AAA structure spread the opponent horizontally, vertically or draw them into straight lines; (3) if not, can a switch of +2 lanes create an AAA; (4) if none, retain and play your way out until 1-3 reopens.',
    'Every new receiver on the ball',
    'Keep every action purposeful toward penetrating between or beyond the lines, with retention as the fallback.',
    NULL, 73, 85, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player on ball', 'check options in priority 1 to 4 each touch'),
    (2, 'Supporting players', 'create the pre-AAA or switch option for priorities 2 and 3'),
    (3, 'Whole team', 'recirculate patiently when nothing is on')
) AS v(so, role, job);

-- 31. pp.74-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 7: Changing Angles of Attack', 'Five vertical lanes as positional map',
    'The pitch is split into five vertical lanes (two wide, two half-spaces, centre); each lane the ball sits in draws a different shifting response from the opposition midfield block, and receivers position by lane.',
    'Ball moves into a new lane',
    'Read where the block is stretched by lane and position players so each switch asks a new question.',
    NULL, 74, 76, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'receiving CB stands in the correct lane relative to the ball, not just square'),
    (2, 'Wide players', 'hold lanes 1 and 5 to force the block to cover full width'),
    (3, 'Half-space players', 'occupy lanes 2 and 4 behind or in front of the midfield line')
) AS v(so, role, job);

-- 32. pp.77-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 7: Changing Angles of Attack', 'Play-rounds: four levels of horizontal circulation',
    'Horizontal circulation happens at four depths: around own box often via the GK (vs high block), through the back line in own half (vs high block), around the opposition midfield (vs medium block), and around the opposition box (vs low block); each round should keep the ball with purpose to break lines.',
    'Block height of opponent',
    'Move the ball sideways at the right depth to open a line-breaking angle rather than circulating aimlessly.',
    NULL, 77, 78, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'link the deepest round vs a high press'),
    (2, 'Defenders', 'run the back-level round in own half'),
    (3, 'Midfield', 'circulate around the opposition midfield at mid level'),
    (4, 'Forwards', 'circulate around the opposition box vs a low block')
) AS v(so, role, job);

-- 33. pp.77-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 7: Changing Angles of Attack', 'Switch and Slice (+2 lanes)',
    'Move the ball horizontally at least one full lane (ideally two, about 15 yards plus) so the receiver faces a different picture, then look to play through the opposition on his first touch.',
    'Block shifted to the ball lane; a player free one or more lanes away',
    'Force a large recovery shift and exploit the gap with a first-time penetrating pass before the block resets.',
    NULL, 77, 81, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'switch quickly and directly, not slow or aerial'),
    (2, 'Receiving player (often far CB)', 'stand a full lane away, open body, first touch forward'),
    (3, 'Forward players', 'be ready for the immediate slicing pass on the new side')
) AS v(so, role, job);

-- 34. pp.79-81
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 7: Changing Angles of Attack', 'Three ways to switch: direct, bounce, through the keeper',
    'Strong-to-weak switches go (1) directly player to player across more than a lane (best: CB to CB with control and a first-time slice option), (2) via a bounce pass off a deep midfielder or any player ahead of the ball, or (3) through the goalkeeper, a slow reset that invites pressure and needs numbers to rebuild.',
    'Need to change side of attack',
    'Pick the most direct switch available to keep speed and the first-time penetrating option.',
    NULL, 79, 81, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back on ball', 'switch direct to partner if the lane is open'),
    (2, 'Defensive midfielder', 'offer the bounce pass when the direct line is blocked'),
    (3, 'Goalkeeper', 'last-resort reset route, set an open angle'),
    (4, 'Weak-side centre back', 'open body shape; may need a touch before playing forward after a GK switch')
) AS v(so, role, job);

-- 35. pp.80-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 7: Changing Angles of Attack', 'Bounce through the #4 then 3v2 build',
    'After the DM bounces the switch, he drops between the two centre backs taking his marker, pulling the opponent into a flat 4-4-2; the full backs advance with their markers to create a 3v2 at the back, the #10 rotates onto the ball and the far winger moves inside or runs beyond while the striker drops.',
    'Direct transfer blocked; bounce pass used',
    'Turn the bounce into a numerical edge in build-up and new receiving options higher up.',
    NULL, 80, 80, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '#4 Defensive midfielder', 'bounce the ball, then drop between centre backs pulling his man'),
    (2, 'Full backs #2/#3', 'advance taking markers to leave 3v2 in build'),
    (3, '#10', 'rotate down onto the ball'),
    (4, '#11 winger', 'go inside between lines or diagonal run beyond the defence'),
    (5, '#9', 'drop into space the winger''s run opens')
) AS v(so, role, job);

-- 36. pp.87-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 9: Communication', 'Scanning order: Forwards, Opposite, Near, Communicate (FON+C)',
    'Before receiving, players look forward first for penetration, then opposite to the weak side for a lane switch, then near the ball for better support angles, and finally communicate the picture to teammates.',
    'Ball about to arrive',
    'Each receiver already knows the best option (penetrate, switch, support) before the first touch.',
    NULL, 87, 88, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'scan forward, then weak side, then near'),
    (2, 'Teammates near ball', 'adjust angle when forward and switch are off'),
    (3, 'All players', 'pass the picture on verbally or non-verbally')
) AS v(so, role, job);

-- 37. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'to_defend', 'Chapter 9: Communication', 'Attack with six, enough left to recover',
    'Bielsa''s Argentina attacked with six players spread over the three attacking areas (both flanks and the centre) while keeping enough players back to recover quickly after losing the ball.',
    'Team in attacking phase',
    'Unbalance the opponent in all three zones yet stay protected against the counter.',
    NULL, 88, 88, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Six attackers', 'occupy left, centre and right attacking zones'),
    (2, 'Remaining four plus GK', 'rest-defence ready to recover the ball immediately')
) AS v(so, role, job);

-- 38. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'to_defend', 'Chapter 9: Communication', '6-6-6 rule (Micciche England U16)',
    'Cross the halfway line within six passes, win the ball back within six seconds of losing it, and have at least six players in high areas when attacking.',
    'Possession won / possession lost',
    'Quick progression, immediate counter-press and numbers in attack.',
    NULL, 88, 88, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Whole team', 'progress past halfway in six passes or fewer'),
    (2, 'Nearest players on loss', 'counter-press to regain inside six seconds'),
    (3, 'Attack', 'at least six players in high areas')
) AS v(so, role, job);

-- 39. pp.89-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 10: Languages of the Game', 'Up-Back-Through (UBT)',
    'An entry pass goes up into the feet of a central player who engages and drags the opposition centre back out of his slot; he lays it back to a supporting player underneath, who plays first time through the space behind the dragged defender to a third-man runner (angled ball to straight run or straight ball to angled run).',
    'Central player receives between lines with a CB stepping to him',
    'Punish the defender pulled out of the line with a third-man run in behind.',
    NULL, 89, 91, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep passer', 'play the up pass into feet with speed for control'),
    (2, 'Central receiver (striker/midfielder)', 'lose the marker by checking/peeling, drag the CB, lay off back'),
    (3, 'Supporting player underneath', 'be at the right angle and pace to play first-time through'),
    (4, 'Third-man runner', 'time the run into the space the CB left')
) AS v(so, role, job);

-- 40. pp.91-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 10: Languages of the Game', 'Striker movements to unsettle the centre back',
    'Before the UBT, the player engaging the centre back uses varied movements: check away then back with contact; towards-away-towards; move behind the defender''s eye-line; move against the grain as the block shifts; drop between two defenders; peel off when a deeper player drives at his marker; rotate with teammates between lines.',
    'Wanting to receive between or beyond the lines',
    'Momentarily lose the marker so any reaction is late and the space behind opens.',
    NULL, 91, 91, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'choose a movement that loses the CB and engages him'),
    (2, 'Winger', 'drop between two defenders into central lanes'),
    (3, 'Deeper midfielder', 'drive at the striker''s marker to free him')
) AS v(so, role, job);

-- 41. pp.92-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 10: Languages of the Game', 'Out-In-Out (OIO)',
    'The winger moves from the widest lane into lane 2 or 4, engaging the opposition full back; the ball goes out to him, in to a central player, then out to a third man attacking the space vacated by the full back - the striker if the ball came from deep, or the overlapping full back if he is high.',
    'Winger inside draws the opposition full back',
    'Exploit the wide space behind a full back pulled inside, then centralise for a goal chance.',
    NULL, 92, 92, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'move inside from lane 1/5, receive and set inside'),
    (2, 'Central player', 'play back out into the vacated wide space'),
    (3, 'Full back', 'if high, overlap into the space for the third pass'),
    (4, 'Striker', 'third-man runner when the ball starts from the deepest line')
) AS v(so, role, job);

-- 42. pp.92-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 10: Languages of the Game', 'Overload-to-Isolate (O-I)',
    'Engage the opposition block on one side with many short passes between lines, drawing them across, then switch quickly to an isolated weak-side player with the profile to win a 1v0 or 1v1; his first touch should be forward or behind the line. A variant plays into a pressing trap then quickly out to the overload side.',
    'Block committed to the ball side',
    'Create a favourable one v one on the far side.',
    NULL, 92, 93, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side players (FB, CM, #10, W, #9)', 'overload with passes between lines to draw opposition'),
    (2, 'Weak-side winger', 'stay isolated and wide, attack first touch'),
    (3, 'Switch passer', 'change play quickly once the block is committed')
) AS v(so, role, job);

-- 43. pp.93-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 10: Languages of the Game', 'Overload-isolate with second runner',
    'If the opposition weak-side full back races out to the receiving winger, a second player (central midfielder) runs in behind that committed full back, making a 2v1 and often pulling a centre back wide.',
    'Weak-side full back jumps out to the switch receiver',
    'Beat the recovering full back with a 2v1 and weaken the central defence for the cross.',
    NULL, 93, 93, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side winger', 'receive and hold the full back'),
    (2, 'Central midfielder', 'run behind the committed full back'),
    (3, 'Overload group', 'draw opposition across before the switch')
) AS v(so, role, job);

-- 44. pp.94-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 10: Languages of the Game', 'Weak-side full back (WSFB) scenarios',
    'Once the ball reaches a central midfielder who can turn out with it from the left, three cases follow: (1) the opposition full back is tight to our winger - winger stays wide and the CM passes into the FB-CB gap; (2) the full back covers well - winger drops between lines or runs across his front, and our weak-side full back advances at pace for wide space (or underlaps); (3) winger left with space - he exploits it himself, with a second runner behind the reacting full back.',
    'Central midfielder turns out with the ball toward the weak side',
    'Exploit the weak side via the pairing of winger and weak-side full back depending on the opposition full back.',
    NULL, 94, 95, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'turn out and choose between gap pass and wide pass'),
    (2, 'Weak-side winger', 'stay wide, drop inside or run across the full back'),
    (3, 'Weak-side full back', 'advance at pace into vacated wide space or underlap')
) AS v(so, role, job);

-- 45. pp.95-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'to_defend', 'Chapter 11: Rotations: Non-Verbal Communication', 'Bilbao wing-backs tuck in as midfielders',
    'In Bilbao''s back-three vs Espanyol (2012), wing-back Perez gravitated to a central defensive-midfield slot when his winger Susaeta was deep; after a clean first progression he drifted central; on losing the ball both wing-backs tucked inside as temporary defensive midfielders in front of the back three, then returned wide once the midfield recovered.',
    'Ball lost / winger position changes',
    'Protect the centre during the negative transition, then restore width.',
    NULL, 95, 98, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing-backs (Iraola, Perez)', 'tuck inside as temporary DMs on loss, return wide once midfield is back'),
    (2, 'Left winger (Susaeta)', 'his depth decides whether Perez stays wide or goes central'),
    (3, 'Back three', 'hold behind the temporary midfield screen')
) AS v(so, role, job);

-- 46. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 11: Rotations: Non-Verbal Communication', 'Platforms (launch pads) low/medium/high',
    'Rotations aim to set a spare man on a platform (low, medium or high) from which he can play forwards; each platform draws a different opposition reaction, so rotations are chosen per platform and per lane (e.g. getting into lanes 2 and 4 of the medium platform).',
    'Need a free player to face forward',
    'Build a controlled launch pad for Advanced Area Actions.',
    NULL, 99, 99, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep players', 'create the low platform'),
    (2, 'Midfielders', 'seek lanes 2 and 4 of the medium platform'),
    (3, 'Advanced players', 'form high platforms between lines')
) AS v(so, role, job);

-- 47. pp.99-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 11: Rotations: Non-Verbal Communication', 'Rotation 1: midfielder drops between centre backs',
    'A central midfielder falls between the two centre backs (only as a 4th-priority, purposeful move): useful in the low platform when pushing full backs high pins the opposition wingers and makes a 4v2 with the GK, or after a switch through the goalkeeper; otherwise deep controllers should stay to pick the ball up behind the first press.',
    'CB under pressure, no AAA, switch or bounce available; opponent presses with two',
    'Gain a clean first progression and push full backs higher.',
    NULL, 99, 102, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'drop between CBs only when it adds value'),
    (2, 'Centre backs', 'split wide'),
    (3, 'Full backs', 'push high taking opposition wide players'),
    (4, 'Goalkeeper', 'make the 4v2 in the low platform')
) AS v(so, role, job);

-- 48. pp.102-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 11: Rotations: Non-Verbal Communication', 'Rotation 2: strong-side midfielder pulls wider than CB',
    'The strong-side central midfielder drops wide of the centre back into the full-back slot; the full back advances and the winger pushes inside behind the opposition midfield line. Best ball players sit in lanes 2 and 4, the weaker CB falls central.',
    'Opponent presses centrally; need wide build platform',
    'Add a player between opposition midfield and defence and make the opponent choose who to follow.',
    NULL, 102, 103, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side CM', 'drop wider than the CB to receive'),
    (2, 'Full back', 'advance higher'),
    (3, 'Winger', 'move inside behind the midfield line'),
    (4, 'Centre back on ball', 'play through any channel opened by followers')
) AS v(so, role, job);

-- 49. pp.104-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 11: Rotations: Non-Verbal Communication', 'Rotation 3: weak-side midfielder pulls wide',
    'The weak-side central midfielder takes up the diagonal pocket wide of the far centre back as the ball goes CB to CB; the weak-side full back pushes on expecting a switch and slice and the weak-side winger drops inside but stays behind the midfield line. If the midfielder is followed, reset the play-round so he can return central unmarked.',
    'Ball travels between centre backs',
    'Help the CBs switch and slice and open channels to Advanced Areas.',
    NULL, 104, 105, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side CM', 'take the diagonal pocket, return central if followed'),
    (2, 'Weak-side full back', 'push up for the switch'),
    (3, 'Weak-side winger', 'drop inside behind the midfield line'),
    (4, 'Centre backs', 'switch and slice or reset the play-round')
) AS v(so, role, job);

-- 50. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 11: Rotations: Non-Verbal Communication', 'Over and Under onto the ball',
    'Two or three midfielders rotate so the deepest moves away from the ball forward into an advanced area, opening space underneath for the far midfielder to come short and act as a platform; best when there is big space between opposition midfield and defence for the forward runner.',
    'Space between opposition lines; congested platform',
    'Create a free platform player and a forward runner simultaneously.',
    NULL, 106, 106, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deepest midfielder (#4)', 'run away from the ball into an advanced linear area'),
    (2, 'Far midfielder (#8)', 'come underneath to receive and play forward'),
    (3, 'Advanced midfielder (#10)', 'move laterally to open space')
) AS v(so, role, job);

-- 51. pp.107-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 11: Rotations: Non-Verbal Communication', 'Under and Over away from the ball',
    'The vertical midfielder (#10) moves toward the ball and drops to a deeper line (maybe as a bounce player), freeing the other midfielders to move into advanced lines; also done between sectors, e.g. striker drops while a midfielder runs beyond (Sampaoli''s Chile vs Netherlands 2014: empty a space then refill it).',
    'Congested space ahead of the ball',
    'Free advanced space for forward runners.',
    NULL, 107, 108, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '#10 / striker', 'drop toward the ball, bounce if needed'),
    (2, 'Other midfielders', 'run into the advanced space vacated'),
    (3, 'Ball carrier', 'play the runner beyond or the dropping player')
) AS v(so, role, job);

-- 52. pp.109-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 11: Rotations: Non-Verbal Communication', 'Rotation 5: full animation to free the striker',
    'Full backs pin the opposition full backs, wingers go inside to pin the centre backs, and the striker drops into the pocket between the lines; the CDM dropping between the CBs (or ball movement) pulls the opponent into a flat 4-4-2 shape.',
    'Wanting the key player free between lines facing forward',
    'Occupy every defender so the key player receives unmarked after the animation.',
    NULL, 109, 109, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs', 'pin the opposition full backs'),
    (2, 'Wingers', 'go inside to pin the centre backs'),
    (3, 'Striker (#9)', 'drop into the pocket between lines'),
    (4, 'CDM', 'drop between centre backs to flatten the opponent')
) AS v(so, role, job);

-- 53. pp.110-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 11: Rotations: Non-Verbal Communication', 'Simple per-player rules make complex patterns (Maric''s Barcelona)',
    'A set of simple reactive rules per position (e.g. right back gives width unless Messi and Rakitic are central; centre back moves narrow when right side drops; DM advances if space ahead; right CM moves forward or wide depending on Alves and Messi; striker drifts or drops when Messi moves central) yields dozens of coordinated positional structures.',
    'Teammates'' positions change',
    'Coordinated balance and width emerge without scripted moves.',
    NULL, 110, 111, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Alves)', 'width unless both Messi and Rakitic are central'),
    (2, 'Right CM (Rakitic)', 'forward centrally or wide to cover vacated areas'),
    (3, 'Defensive midfielder (Busquets)', 'advance when space opens and teammates give width'),
    (4, 'Left winger (Neymar)', 'sit between FB and CB when Suarez goes left'),
    (5, 'Striker (Suarez)', 'drift right or drop when Messi goes central')
) AS v(so, role, job);

-- 54. pp.110-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 11: Rotations: Non-Verbal Communication', 'Paired striker goal trees',
    'In a flat 4-4-2 one striker makes repeated diagonal runs into the CB-FB channel while the other occupies a centre back and holds the ball up; supported by the left winger drawing the full back, while right winger and central midfielder run beyond.',
    'Team in possession in 4-4-2',
    'Strikers complement each other so the runner gets space and the holder links play.',
    NULL, 110, 113, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker A', 'diagonal runs between centre back and full back'),
    (2, 'Striker B', 'pin a centre back, hold up, feed forward runners'),
    (3, 'Left winger', 'draw the opposition right back out of slot'),
    (4, 'Right winger and CM', 'run beyond the striker')
) AS v(so, role, job);

-- 55. pp.113-114
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'out_of_possession', 'Chapter 12: The Environment', 'Striker press splits the pitch',
    'The striker''s defensive job is to force play in one direction and cut the pitch in half from the front, stopping the opponent switching left to right.',
    'Opponent building from the back',
    'Lock the opponent onto one side for the press.',
    NULL, 113, 114, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'curve the press to block the switch'),
    (2, 'Second striker', 'drop into pockets in front of the other striker to pick up loose balls')
) AS v(so, role, job);

-- 56. pp.116-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 13: Bielsa''s #1-4-2-3-1', '4-2-3-1 lane rules, two deep midfielders',
    'When both deep midfielders are in front of the opposition midfield line, one covers lanes 1-3 and the other lanes 3-5, never both in lane 3; the #10 controls lanes 2-4 behind the midfield line; wingers cover the widest lane plus the next one in, opening Out-In-Out chances.',
    'Both deep midfielders below the opposition midfield',
    'Keep spacing and rotation structure across all five lanes.',
    NULL, 116, 117, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left deep midfielder', 'cover lanes 1-3'),
    (2, 'Right deep midfielder', 'cover lanes 3-5, never same lane as partner'),
    (3, '#10', 'control lanes 2-4 between lines'),
    (4, 'Wingers', 'cover lanes 1-2 / 4-5')
) AS v(so, role, job);

-- 57. pp.118-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 13: Bielsa''s #1-4-2-3-1', '4-2-3-1 with one deep midfielder',
    'If only one deep midfielder sits in front of the opposition midfield, he controls lanes 2-4, and the #8 and #10 share the full width beyond it, one left (lanes 1-3) and one right (lanes 3-5), never in the same lane; wingers stay wider near the defensive line rather than drifting central.',
    'Second deep midfielder has moved in line with or beyond the opposition midfield',
    'Keep a single pivot while adding a player between the lines.',
    NULL, 118, 118, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, '#4 deepest midfielder', 'control lanes 2-4'),
    (2, '#8 and #10', 'split width left/right between the lines'),
    (3, 'Wingers', 'get in line or beyond the defensive line in wide areas')
) AS v(so, role, job);

-- 58. pp.118-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 13: Bielsa''s #1-4-2-3-1', '4-2-3-1 weak-side / strong-side positioning',
    'With the ball on one side: GK supports behind at an angle with open body to switch; weak-side CB always gives a supporting angle; strong-side FB gives height behind the opposition midfield; weak-side CM takes the diagonal pocket toward the weak side; strong-side CM supports flexibly; weak-side FB tucks between lanes 4 and 5; weak-side winger stays wide on the limit of the defensive line; strong-side winger moves inside behind the midfield line; striker stretches the line; #10 hovers centre / weak-side.',
    'Ball concentrated on one side',
    'Create the initial conditions for weak-side languages (overload-isolate, WSFB).',
    NULL, 118, 119, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper / weak-side CB', 'support angles and switch option'),
    (2, 'Strong-side full back', 'height in the widest lane'),
    (3, 'Weak-side central midfielder', 'diagonal pocket with a weak-side passing channel'),
    (4, 'Weak-side full back', 'tuck between lanes 4 and 5'),
    (5, 'Weak-side winger', 'hold width on the last line'),
    (6, 'Striker / #10', 'stretch the line / occupy central-weak areas')
) AS v(so, role, job);

-- 59. pp.119-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'to_defend', 'Chapter 13: Bielsa''s #1-4-2-3-1', 'Half-field width for higher rest defence (UAE)',
    'UAE kept their weak-side players within half the pitch width rather than offering full width, so on losing the ball they could defend higher and counter-press, while their technical players combined in congestion.',
    'Losing the ball in possession phase',
    'Better defensive transition and quick goal chances at the cost of weak-side width.',
    NULL, 119, 119, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side players', 'stay within half-field width'),
    (2, 'Creative midfielders', 'combine in congested ball-side areas'),
    (3, 'Attackers', 'attack goal within three or four passes')
) AS v(so, role, job);

-- 60. pp.119-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 14: Bielsa''s #1-3-3-1-3', '3-3-1-3 roles and width',
    'At least one of three centre backs steps out and passes aggressively through the opposition midfield line; the deep midfielder is an ambitious passer; wing-backs either go out-and-out or tuck in as a lateral volante, complementing the winger (winger wide -> wing-back inverts, winger inside -> wing-back gives width); the team always has width and loads the box with at least three on crosses; the enganche (#10) stays behind the opposition midfield with licence to drift wide behind the full backs; three strikers stretch the back line to create space between lines.',
    'Team in possession in 3-3-1-3',
    'Create superiorities across the pitch and stretch the defensive line back.',
    NULL, 119, 122, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Stepping centre back', 'carry/pass aggressively through the midfield line'),
    (2, 'Deep central midfielder', 'pick out ambitious passes'),
    (3, 'Wing-backs', 'width or lateral volante, complementing winger'),
    (4, '#10 enganche', 'receive between lines, drift wide behind FBs'),
    (5, 'Three forwards', 'stretch the line; at least three load the box on crosses')
) AS v(so, role, job);

-- 61. pp.121-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'out_of_possession', 'Chapter 14: Bielsa''s #1-3-3-1-3', 'Aggressive ball-side pressing with numbers',
    'The 3-3-1-3 gives numbers for an aggressive negative transition and flexible cover; pressing patterns ask players to position ball-side rather than goal-side of their man, and the shape asks the opponent whether to go 4-4-2 and defend in straight lines.',
    'Ball lost / opponent in possession',
    'Swarm the ball quickly and force the opponent into flat lines.',
    NULL, 121, 122, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players around the ball', 'stand ball-side of their man'),
    (2, 'Back three', 'cover and step in the transition'),
    (3, 'Forwards', 'press immediately with numbers')
) AS v(so, role, job);

-- 62. pp.122-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 15: Adaptation: #1-3-4-2-1 or #1-3-5-2', '3-4-2-1 build-up from the goalkeeper',
    'The GK chooses a side; the central defender offers a supporting angle on the opposite side; the wide centre backs use box width as reference and sit 3-4 yards either side; the GK acts as sweeper and no defender drops into the box; the central CB slides to support whichever wide CB has the ball. A holding midfielder may drop in line (La Volpe) on the GK''s side with the wide CBs going deeper still.',
    'Goal kick / GK in possession',
    'Build out cleanly with supporting angles and the keeper as a free man.',
    NULL, 122, 123, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'choose the side, act as sweeper'),
    (2, 'Central centre back', 'offer angle on opposite side, slide to support'),
    (3, 'Wide centre backs', 'split to box width, drop deeper if DM drops'),
    (4, 'Holding midfielder', 'optionally drop in line (La Volpe)')
) AS v(so, role, job);

-- 63. pp.123-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 15: Adaptation: #1-3-4-2-1 or #1-3-5-2', '4v3 central box to free a CAM',
    'The two holding midfielders and two attacking midfielders form a 4v3 against the opposition midfield three; vs a high press the holder bounces back to the central CB, who plays first time into the attacking midfielder now free because his marker was pulled out; vs a medium/low block the wide CB drives at the opposition to release a midfielder.',
    'Opposition midfield three; high press or medium/low block',
    'Free one of the two attacking midfielders to receive between the lines.',
    NULL, 123, 124, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielders', 'control from deep, bounce to central CB'),
    (2, 'Central centre back', 'first-time pass into freed CAM'),
    (3, 'Wide centre backs', 'drive at opposition to attract a marker (vs block)'),
    (4, 'Attacking midfielders', 'stay available between lines')
) AS v(so, role, job);

-- 64. pp.124-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 15: Adaptation: #1-3-4-2-1 or #1-3-5-2', '3-4-2-1 one-side play and weak-side 2v1',
    'When play works down one side, the strong-side wing-back drops to invite the opposition full back out; the striker or strong-side CAM runs behind the full back or pins the line; the weak-side CAM holds his position and the weak-side wide player stays on the limit of the back line, giving the weak-side full back a choice and creating a 2v1 by diagonal runs behind the full back, not overlaps.',
    'Ball worked down one flank',
    'Drag the full back out and create a weak-side 2v1.',
    NULL, 124, 125, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side wing-back', 'drop back to give angle and invite FB out'),
    (2, 'Striker / strong-side CAM', 'run behind FB or pin the line'),
    (3, 'Weak-side CAM', 'hold position for the switch'),
    (4, 'Weak-side wide midfielder', 'hold max width on back line'),
    (5, 'Holding midfielder', 'stay underneath the ball')
) AS v(so, role, job);

-- 65. pp.125-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 15: Adaptation: #1-3-4-2-1 or #1-3-5-2', '3-4-2-1 languages: UBT, OIO, overload-isolate',
    'The central three invite the opposition centre backs out (via UBT or receiving and running at them); extreme width from the wide midfielders sets up overload-to-isolate; if the opposition full back engages the attacking midfielder, the wide midfielder becomes free for Out-In-Out. At least one forward runs behind to stretch the lines, and at least one holder stays underneath with wide CBs supporting.',
    'Attacking positions in 3-4-2-1',
    'Pull centre backs and full backs out of slot to exploit space.',
    NULL, 125, 126, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielders/striker', 'draw CBs out, combine UBT'),
    (2, 'Wide midfielders', 'extreme width for O-I and OIO'),
    (3, 'Holding midfielder', 'stay under the ball'),
    (4, 'Wide centre backs', 'support underneath the wing-back')
) AS v(so, role, job);

-- 66. pp.126-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 15: Adaptation: #1-3-4-2-1 or #1-3-5-2', 'Back-four team animating into a back three',
    'From 4-2-3-1 a wide midfielder moves inside to a second CAM slot, the full back behind progresses into the wide midfield slot and the weak-side full back tucks in to form the back three (Sousa''s Fiorentina); from 4-3-3 both full backs advance as wide midfielders, wingers come inside as attacking midfielders and the holder drops between the centre backs.',
    'Team in possession with back four',
    'Reach the 3-4-2-1 attacking shape while defending in a familiar back four.',
    NULL, 126, 126, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder', 'move inside as second CAM'),
    (2, 'Ball-side full back', 'progress to widest advanced slot'),
    (3, 'Weak-side full back', 'tuck in to make back three'),
    (4, 'Holding midfielder (4-3-3)', 'drop between centre backs')
) AS v(so, role, job);

-- 67. pp.128-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 16: #1-4-3-3 The Team''s Hat', 'The team''s hat: six front-three types',
    'The front three of a 4-3-3 can wear six ''hats'', each changing the team''s animation: balanced (two wingers and a striker), balanced/inverted mix, inverted (two inside cutters plus striker), wide No.10s (Christmas tree), false 9 with inside forwards, and random/free motion. When wingers invert or come inside, the full backs must push on and give width.',
    'Choice of front-three profile',
    'Flexibility and unpredictability matched to the best players.',
    NULL, 128, 131, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers', 'stay wide and dribble, or cut inside/play as wide 10s'),
    (2, 'Striker', 'stay central or drop as false 9'),
    (3, 'Full backs', 'provide width when wide players go inside')
) AS v(so, role, job);

-- 68. pp.132-135
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Chapter 17: Conclusion of Theory', 'Switzerland diamond: overload left, three exits',
    'Switzerland''s 4-4-2 diamond used Behrami as the ball-playing midfielder on the right (lane 4, medium platform) and overloaded the left with four or five players (DM, left CM, LB, left striker, left CB) to drag the opposition midfield across; the exits were Shaqiri at the diamond''s tip, Behrami playing quickly into advanced areas, or a switch to the right back high on the weak side.',
    'Opposition midfield drawn to the left overload',
    'Asymmetric routes to Advanced Areas away from the opposition midfield.',
    NULL, 132, 135, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left-side group (Inler, Xhaka, Rodriguez, Djourou, left striker)', 'overload and attract the opposition'),
    (2, 'Behrami (right CM)', 'ball player in lane 4, play quickly into AAA'),
    (3, 'Shaqiri (#10)', 'receive at the top of the diamond'),
    (4, 'Lichtsteiner (RB)', 'stay high on the weak side for the switch')
) AS v(so, role, job);

-- 69. pp.140-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Section One: Up Back Through (UBT) - rondo progressions', 'Manipulating two defenders for the third-line pass',
    'Two screening defenders try to sit on different lines to intercept any pass to the furthest player; the ball side has numbers in front of them.',
    'Defenders block the direct through pass',
    'Short and horizontal passes shift the screen and open a gap to penetrate to the advanced player; if no gap, play around the defenders and the threat pulls them out of shape.',
    NULL, 140, 142, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side players', 'Short square passes to drag the defenders, open hips to the target before receiving'),
    (2, 'Central player between the defenders', 'Move to receive in front of or behind the defensive line and turn'),
    (3, 'Receiver on the dividing line', 'Turn and play through in two touches to one of the three options ahead'),
    (4, 'Two screening defenders', 'Stand on different lines, block passes up the middle and around the sides')
) AS v(so, role, job);

-- 70. pp.140-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Section One: Up Back Through (UBT)', 'Up-Back-Through (UBT)',
    'Opponents block the direct pass into the forward zones; the centre forward peels off his centre back into the pocket between their midfield and back line to receive a vertical pass.',
    'Deep midfielder or centre back pushes the ball out of his feet and lifts his head; a passing lane into the receiving space opens',
    'The striker sets the ball back to a facing team-mate whose through ball finds a winger running diagonally into the gap left by the centre back who followed the striker.',
    NULL, 140, 152, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward (F9)', 'Stretch play, drop into the receiving space only when a pass is on, set back one-touch to the open side'),
    (2, 'Deep central midfielder', 'Carry to trigger, give an angle on the far side of the marker, play the through ball weighted for the winger''s first touch'),
    (3, 'Fullbacks / centre backs', 'Offer the alternative up pass and set-back target'),
    (4, 'Wingers', 'Drop deep to support, then only after the set-back run diagonally behind the vacated centre back space'),
    (5, 'Far winger', 'Preferred receiver - the winger furthest from the remaining centre backs finishes')
) AS v(so, role, job);

-- 71. pp.143-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Section One: Up Back Through (UBT)', 'Striker movements into the receiving space',
    'The striker has to lose his marker before dropping between the lines; if the pass does not come he must not idle in the pocket.',
    'Defender''s eyes go to the ball, or the striker is not followed',
    'Arrive in the pocket unmarked at the moment a pass can be played; if left free, turn and finish instead of setting back.',
    NULL, 143, 152, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'Check towards the defender then to the ball; or slip behind the defender''s eye-line and drop when he ball-watches; or push the defender one way and come off diagonally the other'),
    (2, 'Centre forward', 'If the pass does not arrive, reset by stretching high again and re-time the drop'),
    (3, 'Centre forward', 'Turn and finish when the centre back does not follow'),
    (4, 'Following centre back', 'Being pulled out of the line is what the pattern exploits')
) AS v(so, role, job);

-- 72. pp.153-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Section 2: Out-In-Out (OIO)', 'Out-In-Out (OIO)',
    'On the strong side the winger comes inside from the touchline to receive an ''in'' pass from deep while his fullback is on the outside.',
    'Central midfielder carries and lifts his head; winger is followed inside by his defender',
    'Winger lays back inside, the fullback overlaps into the space the winger''s marker vacated and receives the ''out'' pass to cross or go one v one against the tracking winger-defender.',
    NULL, 153, 162, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strong-side winger', 'Sprint inside to at least the edge of the receiving space, receive the ''in'' pass and lay off first touch to the midfielder'),
    (2, 'Strong-side fullback', 'Overlap aggressively as the ball goes to the winger, take the out ball, cut back or whip early into the channel'),
    (3, 'Central midfielder', 'Play the in pass, receive the lay-off and release the out ball, choosing type by the space'),
    (4, 'Winger (unfollowed)', 'If his marker does not track inside, receive and finish instead'),
    (5, 'Central midfielder (no overlap)', 'If the fullback misses the moment, turn and keep possession')
) AS v(so, role, job);

-- 73. pp.159-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Section 2: Out-In-Out (OIO) / Section 4: Overload-to-Isolate', 'Final-third option ladder',
    'After playing through (not via) the central area the attack has several ways to goal, taken in order of priority.',
    'Ball beyond the opposition midfield line',
    'Pick the most direct option the defence allows: striker turns and shoots, else UBT, else OIO, else switch to the isolated weak-side winger.',
    NULL, 159, 162, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre forward', 'First choice: receive and turn to finish if given space'),
    (2, 'Centre forward (tightly marked)', 'Set back to start an up-back-through'),
    (3, 'Winger (unfollowed)', 'Receive directly from the first zone and go'),
    (4, 'Winger (followed) + fullback', 'Trigger out-in-out with the overlap'),
    (5, 'Weak-side winger', 'Overload-to-isolate release into the final third (see O-I)')
) AS v(so, role, job);

-- 74. pp.163-172
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Section 3: Weak-side Fullback (WSFB)', 'Weak-side fullback (WSFB) switch',
    'Ball circulates across the back line and into the deep midfielder in the diagonal pocket; when he can turn out, the weak side is attacked.',
    'Strong-side ball reaches the deep/central midfielder and he can turn out to the weak side',
    'Weak-side winger sprints infield behind the opposition midfield line, dragging his marker, and the weak-side fullback overlaps at pace to receive the switch and cross first time (winger and striker attack the box 2v2).',
    NULL, 163, 172, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep midfielder', 'Sit in the diagonal pocket opposite the ball, open shoulders and hips to the field, turn and play the switch'),
    (2, 'Weak-side winger', 'Time an inside sprint behind the midfield line on the midfielder''s first touch; join the striker in the box or receive himself if not followed'),
    (3, 'Weak-side fullback', 'Advance and overlap at pace, cross on first touch: whipped behind the line, driven, cut back, lofted deep, curled to back post, or near post'),
    (4, 'Centre backs', 'Circulate without skipping, step off for an angle and take the first touch forwards'),
    (5, 'Centre forward', 'Attack the cross with the winger')
) AS v(so, role, job);

-- 75. pp.165-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Section 3: Weak-side Fullback (WSFB)', 'Strong-side / weak-side positional rules',
    'Positions of fullbacks, wingers, centre backs and deep midfielder change as the ball travels across the back line.',
    'Ball moves from one side to the other in build-up',
    'Always one wide and one inside per flank, with constant angles for the next pass, so a switch is ready.',
    NULL, 165, 168, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Fullback (ball side)', 'As wide as possible to receive'),
    (2, 'Fullback (far side)', 'Tuck inside towards his marker'),
    (3, 'Winger (ball side)', 'Tuck inside - one in, one out with his fullback'),
    (4, 'Winger (far side)', 'Hold the width while his fullback tucks'),
    (5, 'Centre backs', 'Stay central, shift with the ball, drop off for a deeper angle'),
    (6, 'Deep midfielder', 'Beside the ball when it is with a fullback; in the opposite diagonal pocket when it is with a centre back')
) AS v(so, role, job);

-- 76. pp.169-182
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Section 3: Weak-side Fullback (WSFB) / Section 4', 'FON + C scanning',
    'Players ahead of the opposition midfield line read the picture before receiving.',
    'Any receipt beyond the opposition midfield line',
    'Know the forward, weak-side and near options before the ball arrives and share them so the team picks the right language.',
    NULL, 169, 182, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players in front of opposition midfield line', 'Look Forward first, then Opposite (weak side), then Near the ball'),
    (2, 'All', 'Communicate what was seen, verbally and non-verbally')
) AS v(so, role, job);

-- 77. pp.173-184
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Section 4: Overload-to-Isolate (O-I)', 'Overload-to-Isolate (O-I)',
    'The team crowds one side with a numerical overload to draw defenders across, while the weak-side winger stays wide and high, level with the final-third entry line.',
    'Overload rondo on one side holds possession (around four or five passes) and defenders have shifted across',
    'Quick switch through the central midfielder isolates the weak-side winger one v one with a defender who must run across, or into early crosses to a filled box.',
    NULL, 173, 184, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Overload group (one side)', 'Keep the ball under pressure, signal and move to drag defenders across'),
    (2, 'Central midfielder', 'Show for the ball with body open to the far side and switch quickly with varied delivery'),
    (3, 'Weak-side winger', 'Hold width high; first touch forwards out of his feet, then beat his man or cross early'),
    (4, 'Box attackers', 'Fill different spaces collectively to meet the cross'),
    (5, 'Far defender', 'Must run across late to pressure the winger - the isolation')
) AS v(so, role, job);

-- 78. pp.175-178
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Section 4: Overload-to-Isolate (O-I) - Type B / C rondos', 'Escaping a pressed overload to the far side',
    'A second defender joins and the ball-side overload becomes outnumbered or locked.',
    'Extra defender closes the ball-side group',
    'Get out through central supporting players and across to the target on the weak side as fast as possible.',
    NULL, 175, 178, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side trio', 'Find tempo and angles to play out centrally'),
    (2, 'Central supporting players (CB, CM)', 'Offer the inside angle that links to the far side'),
    (3, 'Far target', 'Take a forward receiving touch and attack as support arrives'),
    (4, 'Defender on the far line', 'Slides side to side to block, leaves line only after the target''s first touch')
) AS v(so, role, job);

-- 79. pp.185-186
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Section 5: Rotations', 'Under-and-Over / Over-and-Under rotation',
    'Two linked players (two midfielders, winger and midfielder, striker and midfielder) move relative to each other to free one to receive centrally.',
    'Pass does not come in, or the ball is bounced back to the deeper player (he is pressed)',
    'Circular rotation lets one player come onto the ball facing forward or receive behind a line while the other drags markers.',
    NULL, 185, 186, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pair rule', 'Always one high and one low, one left and one right; if one drops the other goes high, if one goes across the other goes the other way'),
    (2, 'Lower player (under-over)', 'Run forward on the outside to the high spot (clockwise)'),
    (3, 'Higher player (under-over)', 'Come over the top to receive behind lines'),
    (4, 'Over-under variant', 'Player low rotates anti-clockwise, top player comes onto the ball and plays forward first touch'),
    (5, 'Both', 'Tick/checkmark and double movements to lose the marker, hips open to play forward')
) AS v(so, role, job);

-- 80. pp.187-190
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Section 5: Rotations - midfield small-sided games', 'Midfield-three collective rotation',
    'Three central midfielders against three, with the back four circulating behind and feeding in.',
    'Back four look to feed into midfield',
    'Structured rotations of the three open space to receive from deeper players and can isolate 2v2 or 1v1 in the centre.',
    NULL, 187, 190, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield three', 'Rotate together to create and time passing lanes from the back'),
    (2, 'Centre backs', 'Circulate fullback to fullback without skipping, then feed in'),
    (3, 'Fullbacks', 'Stay outside the centre and give supporting angles')
) AS v(so, role, job);

-- 81. pp.191-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Section 5: Rotations - phase of play', 'Wide and expansive rotations menu',
    'Width and a target in the end zone are always kept, but the players filling those posts rotate.',
    'Ball in central area, attack seeking space to play forwards',
    'Keep width and depth occupied while swapping who fills them, freeing a player between the lines.',
    NULL, 191, 192, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Fullback + winger', 'Wide rotation, one inside one outside (can include the central midfielder)'),
    (2, 'Striker + central midfielder', 'Swap - striker drops, midfielder goes up'),
    (3, 'Full expansive rotation', 'Both fullbacks go high and wide, both wingers into the box, striker drops to central zone - only once the deep midfielder has dropped between the two centre backs'),
    (4, 'Semi-expansive', 'One winger joins the striker, the other drops into the central zone')
) AS v(so, role, job);

-- 82. pp.193-194
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Section 6: Overloads - Rondo 3v1', 'First-line passes to draw a defender',
    'Small overload against a single defender around the ball.',
    'Defender commits to the ball',
    'Short first-line passes pull the defender across and open the longer pass behind him.',
    NULL, 193, 194, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Supporting players', 'Good angles to the ball, open body to the next pass, one and two touch'),
    (2, 'Ball carrier', 'Use fakes and movement before receiving')
) AS v(so, role, job);

-- 83. pp.195-202
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Training methodology 6: Overloads (rondos 6.2-6.5)', 'Find the spare man, isolate 2v1',
    'In tight central areas the team in possession scans for the free player and recognises when its local overload grows or shrinks, aiming for clean 2v1s rather than crowded 3v2s.',
    'Defender commits to the ball carrier or a pass lane',
    'Shift defenders with the type and direction of pass until one is left facing two and the line can be broken.',
    NULL, 195, 202, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'fix the nearest defender, choose pass type to move him'),
    (2, 'Spare man', 'hold the free angle away from pressure'),
    (3, 'Supporting players', 'body open, good distance and angle to give options'),
    (4, 'Defenders', 'work as a unit, cut passes rather than lunge into tackles')
) AS v(so, role, job);

-- 84. pp.197-202
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'to_attack', 'Training methodology 6: Overloads (rondos 6.3-6.5)', 'Regain: out to the free man',
    'The moment the ball is won, the winner plays immediately to an open team-mate away from the pressure and the rest sprint into attacking positions.',
    'Ball won inside the opponent''s block',
    'Convert the regain into a directional attack before the opponent can re-close spaces.',
    NULL, 197, 202, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who wins the ball', 'first pass to the open man, away from immediate pressure'),
    (2, 'Team-mates', 'sprint out wide/high to take up attacking shape'),
    (3, 'Spare man', 'receive and turn play forward')
) AS v(so, role, job);

-- 85. pp.203-206
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Training methodology 6.6: Overloading Opposition Midfield Lines (from the 1-3-4-2-1 theory)', 'Four midfielders overload a midfield three',
    'With two deep and two advanced midfielders against a central three, defenders pass into whichever midfielder is free to reach the centre forward, who sets the ball back to come again.',
    'A midfielder free between or beside the opposing three',
    'Draw an opposing midfielder out and exploit the space it leaves to get the ball into the striker.',
    NULL, 203, 206, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'pass into any of the four central midfielders, or through/over to the striker'),
    (2, 'Deep midfield pair', 'keep shape in the first band unless a rotation triggers'),
    (3, 'Advanced midfield pair', 'hold the second band, show between lines'),
    (4, 'Centre forward', 'receive and lay back to a defender to restart')
) AS v(so, role, job);

-- 86. pp.203-208
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'to_attack', 'Training methodology 6.7: Isolating and Identifying Overloads', 'Use the overload the regain creates',
    'On winning the ball the team spots where it has numbers and takes extra risk there to create advanced-area chances quickly; after regaining from a failed attack it may reset by going back before going forward again.',
    'Possession won where opponents are short in numbers',
    'Turn a momentary numerical advantage into a goal-scoring move.',
    NULL, 203, 208, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'find the side with the overload'),
    (2, 'Nearby midfielders', 'support the overload and accelerate'),
    (3, 'Front players', 'attack the advanced area while numbers favour us')
) AS v(so, role, job);

-- 87. pp.205-208
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'to_defend', 'Training methodology 6.7: Isolating and Identifying Overloads', 'Win it back within three seconds',
    'When the ball is lost the team around it tries to recover it at once; the player who lost it is only released from the effort if the ball is not regained within about three seconds.',
    'Loss of possession',
    'Counter-press immediately so the opponent cannot exploit the moment.',
    NULL, 205, 208, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Player who lost the ball', 'react instantly, join the regain'),
    (2, 'Players near the ball', 'swarm to recover within ~3 s')
) AS v(so, role, job);

-- 88. pp.207-212
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Training methodology 7.1-7.2: One vs One Bielsa (Crossing / Shooting)', 'Wide 1v1 at the box edge',
    'A wide attacker isolated against one defender along the 18-yard line uses changes of pace to find half a yard, then crosses (either foot, often out-swinging) or cuts in to shoot.',
    'Winger receives isolated against a single defender near the box',
    'Win the wide duel to deliver a cross or get a shot away.',
    NULL, 207, 212, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'accelerate/decelerate, cross or shoot with either foot'),
    (2, 'Defender', 'stay square to the ball, never turn the back to block')
) AS v(so, role, job);

-- 89. pp.211-218
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Training methodology 7.3-7.5: Protecting the Ball / Receiving: Defender Behind', 'Receive with defender behind, protect or turn',
    'A player receiving with an opponent pressing from behind reads the type of press and the defender''s body shape to decide whether to shield, receive on the far foot or turn first time, using a nearby team-mate as a wall to get past.',
    'Pass into a marked player with pressure from behind',
    'Keep the ball under pressure and outplay the marker, building trust to pass into marked players.',
    NULL, 211, 218, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver', 'move to get free, shield or turn based on the press'),
    (2, 'Supporting player', 'offer a wall pass to get beyond the defender'),
    (3, 'Passer', 'trust the marked team-mate and feed him')
) AS v(so, role, job);

-- 90. pp.217-224
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Training methodology 7.6-7.8: Receiving the Ball While Breaking Lines', 'Forward run to receive between lines',
    'A player makes a fast forward run into the gap between the opposition midfield and defence (or between their central midfielders) and is found on the move behind his marker, then carries forward.',
    'Space opening between opposition lines; first-time pass from deeper',
    'Receive behind a line at full speed and progress before new pressure arrives. Described as Bielsa''s most recurring training theme at Bilbao.',
    NULL, 217, 224, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Runner (CM or winger)', 'sprint into the gap, receive behind the marker'),
    (2, 'Passer', 'play first time into the space ahead of the run'),
    (3, 'Next supporter', 'set up to receive the set-back and repeat')
) AS v(so, role, job);

-- 91. pp.223-226
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Training methodology 7.9: Receiving While Breaking Lines Drill Type D', 'Bait the press with a flat pass',
    'A square pass between two players invites an opposing midfielder to jump out and press; once he fully commits, the ball goes back to the partner and the pressed player runs forward to receive behind him.',
    'Opposing midfielder commits to press after a horizontal pass',
    'Use a common pressing trigger to pull a defender out of his slot and create a 2v1 behind him.',
    NULL, 223, 226, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pressed player', 'release the ball back, then run past the presser'),
    (2, 'Partner', 'receive and play forward into the run'),
    (3, 'Opposing midfielder', 'drawn out of his slot by the flat pass')
) AS v(so, role, job);

-- 92. pp.225-228
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Training methodology 7.10: Receiving the Ball to Switch Angle of Attack', 'Central midfielder turns to switch play',
    'An angled pass reaches a central midfielder who checks his shoulder, receives across his body and turns out to the far side to change the angle of attack despite a defender sprinting to stop him; if blocked he plays back where it came from.',
    'Angled (not flat) pass into the central midfielder under pressure',
    'Move the attack to the opposite side quickly through the centre.',
    NULL, 225, 228, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder', 'scan, open body, turn and switch'),
    (2, 'Wide passer', 'give an angled pass into him'),
    (3, 'Far-side player', 'be available for the switch')
) AS v(so, role, job);

-- 93. pp.227-230
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Training methodology 8.1-8.2: Finishing Scenario A. Behind CBs', 'Striker drops, runner attacks vacated space',
    'The striker comes off the back line and drags his centre back with him; a central midfielder then slides a through ball (or a lofted ball over defenders stepping up) to a wide player or midfielder running diagonally into the gap behind (up-back-through finish).',
    'Centre back follows the dropping striker',
    'Finish one- or two-touch from the space behind the central defenders.',
    NULL, 227, 230, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'drop off the line, pull the CB, set the ball back'),
    (2, 'Central midfielder', 'play the through ball or chip over'),
    (3, 'Wide player', 'diagonal run behind into the vacated space')
) AS v(so, role, job);

-- 94. pp.229-236
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Training methodology 8.2-8.4: Finishing Scenario A. Behind CBs (wall pass / dummy)', 'Around-the-corner wall pass and spin',
    'An attacker comes towards the ball, lays a wall pass around the corner or a midfielder dummies a pass through to the striker, then spins in behind the centre back who stepped out to press. If the CB does not follow, the striker turns and shoots in front of the line.',
    'Central defender steps out to press a midfielder or dropping striker',
    'Pull a central defender out of slot and exploit the space behind him; seen in Athletic Bilbao v PSG, Sept 2011.',
    NULL, 229, 236, 940)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker', 'set wall pass, or turn and shoot if unmarked'),
    (2, 'Central midfielder', 'forward run, disguise and dummy the ball'),
    (3, 'Second striker', 'combine using the wall pass and UBT')
) AS v(so, role, job);

-- 95. pp.235-240
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Training methodology 8.5-8.6: Finishing Scenario C. Behind FBs', 'Get behind the full back to cross',
    'The winger plays a one-two with the attacking midfielder to get behind the full back; the defensive midfielder or nearest centre back must come out to him, and he picks the right delivery for the space that opens.',
    'Winger released behind the full back',
    'Draw a central defender or midfielder out and assist from the wide area, or finish if no one comes.',
    NULL, 235, 240, 950)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'one-two inside, attack behind the full back, choose cross type'),
    (2, 'Attacking midfielder', 'wall pass for the winger'),
    (3, 'Striker', 'attack the corridor between keeper and defensive line'),
    (4, 'Weak-side winger', 'come inside to attack deep/back-post deliveries')
) AS v(so, role, job);

-- 96. pp.237-240
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'to_attack', 'Training methodology 8.6: Finishing Scenario C. Behind FBs Functional Game', 'Defending side counters to two forwards',
    'After clearing high and wide, the defending side breaks quickly to its two forwards in a 2v1 while the back line pushes up aggressively to a high line.',
    'Ball cleared or won by the defending side',
    'Punish the attacking side with a fast counter while squeezing up the pitch.',
    NULL, 237, 240, 960)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders', 'clear high and wide, push up to hold a high line'),
    (2, 'Two forwards', 'receive quickly and attack the 2v1'),
    (3, 'Central midfielder', 'drop in to make a 4v2 when building out')
) AS v(so, role, job);

-- 97. pp.239-242
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Training methodology 8.7: Finishing Scenario D. In Front of FBs', 'Striker exploits the covering centre back',
    'The winger picks up the ball facing forward in front of the full back; the full back engages, the near centre back steps across to cover and the far one balances. The striker backpedals towards the far centre back, then times his run behind the covering centre back for the pass.',
    'Winger receives facing forward and the full back presses',
    'Score through the gap left when the centre back shifts to cover his full back.',
    NULL, 239, 242, 970)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'receive facing forward, slide the pass behind'),
    (2, 'Striker', 'backpedal to the far CB, then run behind the covering CB'),
    (3, 'Central midfielders', 'move the ball out to the winger')
) AS v(so, role, job);

-- 98. pp.241-243
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'the-football-philosophy-in-shadows-of-marcelo-bielsa'), 'in_possession', 'Training methodology 9: Match Day / Training Match Targets', 'Positional targets for UBT language',
    'Each position gets match-day targets that feed up-back-through play: keeper switches play, full backs and centre backs play into the striker''s feet or central midfielder, midfielders play through balls and into the striker, wingers make diagonal runs when the striker drags his defender out, the striker shows in the pocket behind the opposition midfield and resets if not found.',
    'Any build-up phase',
    'Make the whole team speak the same combination language so UBT patterns appear in games.',
    NULL, 241, 243, 980)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'switch play on receiving'),
    (2, 'Full backs / Centre backs', 'pass into the striker''s feet or central midfielder'),
    (3, 'Central midfielder', 'through balls and passes into the striker'),
    (4, 'Wingers', 'diagonal runs as the striker pulls his marker out'),
    (5, 'Centre forward', 'show in the pocket behind midfield, reset, lay off or turn')
) AS v(so, role, job);

COMMIT;
