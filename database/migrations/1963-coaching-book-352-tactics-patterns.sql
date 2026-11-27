-- 1963 📚 Coaching book patterns: "Coaching 3-5-2 Tactics" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Coaching 3-5-2 Tactics',
    subtitle    = '125 Tactical Solutions and Practices',
    author      = 'Renato Montagnolo',
    team        = '3-5-2 (Conte''s Italy Euro 2016 examples)',
    method_note = 'The 3-5-2 as a possession system that plays through the lines with wing backs as the wide outlet. Chapter 1 sets out its strengths and weaknesses by line and phase (with the two-forward combinations of Conte''s Italy at Euro 2016); chapter 2 gives lettered tactical solutions against six opponent shapes (4-4-2, 4-2-3-1, 4-3-3, 4-3-1-2, 3-5-2, 3-4-3), each split into beating the first press, playing between and behind the lines, pressing and organising the back line; chapter 3 turns them into eight training sessions. Patterns here are the solutions and the match behaviours the sessions train, in our words; drill layouts are left out.'
WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices');

-- 1. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '1.1 The 3 centre backs - build-up play', 'Back three builds with spare man',
    'The three centre backs keep their spare man against one or two pressing forwards, so the DM can stay higher and does not drop between them. Against a three-man first line, the GK or DM adds the extra man, and CM/WB movements open lanes behind the press.',
    'Opponent presses with 1, 2 or 3 forwards',
    'Break the first line by a forward pass to the DM or a wide CB carrying the ball into space.',
    NULL, 17, 17, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre backs', 'split wide; the free one drives forward with the ball'),
    (2, 'Defensive midfielder', 'stays higher, between the opponent''s first and second lines, as the forward pass target'),
    (3, 'Goalkeeper', 'acts as the extra man when the press matches the three'),
    (4, 'Central midfielders and wing backs', 'combined movements to open lanes towards the free man')
) AS v(so, role, job);

-- 2. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '1.2 The 2 wing backs - exploiting space out wide', 'Wing back weak-side outlet and switch',
    'Opponents crowd the centre to stop the three CMs and two forwards, which leaves the wing backs free near the touchline with time. The team attacks the weak side and switches quickly to make the block shift.',
    'Opponent narrows centrally; their full backs tuck in near the CBs',
    'Isolate a defender 1v1 on the flank and open gaps to play in behind.',
    NULL, 18, 18, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side wing back', 'holds full width and receives the switch with time'),
    (2, 'Wing backs', 'beat their man 1v1 and cross quickly'),
    (3, 'Midfield / back three', 'switch quickly to drag the block from side to side')
) AS v(so, role, job);

-- 3. pp.19-19
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '1.3 The 3 midfielders - build-up, between the lines, midfield rotation', 'Staggered midfield occupies between lines',
    'The DM sits between the opponent''s attacking and midfield lines as the first receiver after the press. The left and right CMs move up into the space between the opponent''s midfield and defence, neither too deep nor too high. The coach picks one of three set-ups: the more incisive CM always goes up, the ball-side or far-side CM goes up, or both go up (only when rest defence is safe). When the DM is screened, the three rotate to free a lane.',
    'DM passing lane closed / ball in build-up',
    'Always have a receiver between the lines while keeping balance if the ball is lost.',
    NULL, 19, 19, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'first receiver beyond the first line of the press; rotates when marked'),
    (2, 'Incisive central midfielder', 'takes up a position between the lines, behind the opponent''s midfielders'),
    (3, 'Other central midfielder', 'stays in front of the opponent''s midfield for balance, or rotates with the DM')
) AS v(so, role, job);

-- 4. pp.20-20
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '1.4 Combination play between wing backs and central midfielders', 'Wing back and CM opposite movements',
    'The ball-side CM moves in the opposite direction to his wing back. If the WB comes deep for the ball, the CM pushes between the lines. If the WB goes high, the CM drops in front of the opponent''s midfield. If the WB is closed down, the CM gives him a short angle. If the WB has space to dribble, the CM attacks the space that opens up.',
    'Wing back position / opponent''s press on the wing back',
    'Keep a passing option and progress on the flank through linked movements.',
    NULL, 20, 20, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing back', 'comes short or goes high; carries the ball when allowed'),
    (2, 'Ball-side central midfielder', 'moves opposite to the WB: between the lines, short support, or into vacated space')
) AS v(so, role, job);

-- 5. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '1.5 The 2 forwards - combined movements', 'Forward pair stays close',
    'The two strikers play close together so they can combine quickly. Against a back four they stay central to keep a 2v2 on the centre backs. Against a back three they shift towards the ball to engage the two nearest defenders.',
    'Ball reaches a forward',
    'Force the defence either to stay narrow (leaving the flanks open) or to accept a 2v2 centrally, then combine on pre-set signals.',
    NULL, 21, 21, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward pair (F1, F2)', 'stay close; recognise the shared cues and react together'),
    (2, 'Forward pair vs back three', 'shift towards the ball onto the two nearest defenders')
) AS v(so, role, job);

-- 6. pp.22-25
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '1.6-1.7 Italy Euro 2016 combined movements (Conte)', 'Drop, dummy and run in behind',
    'The deeper forward comes short as if to receive and pulls his marker out. He lets the pass run through to his strike partner, then turns and sprints behind his marker to take the return. This works from central and horizontal passes and from the wing back''s inside pass, where F1 dummies and F2 plays F1 in behind.',
    'Pass played into the forwards with enough pace; marker follows the drop',
    'Get a forward in behind the centre back who stepped out.',
    NULL, 22, 25, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deeper forward', 'comes short, dummies the ball, spins in behind his marker'),
    (2, 'Advanced forward', 'receives the dummied ball and plays first time into his partner''s run'),
    (3, 'Passer (midfielder or wing back)', 'plays a firm pass into the forwards')
) AS v(so, role, job);

-- 7. pp.23-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '1.6C / 1.7B Combined movements', 'Dummy and receive the lay-off',
    'Same drop-and-dummy start, but the marker does not follow or there is no space behind the centre back. The dummying forward takes the lay-off from his partner instead of running.',
    'Marker not pulled out / no space in behind',
    'Keep possession and turn facing play.',
    NULL, 23, 26, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dummying forward', 'reads the space; receives the lay-off instead of running in behind'),
    (2, 'Partner forward', 'lays the ball back first time')
) AS v(so, role, job);

-- 8. pp.24-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '1.6D-E / 1.7E Opposite vertical movements', 'One drops, other runs in behind',
    'When a midfielder has time on the ball, one forward comes short and drags his marker. The other runs straight or diagonally into the vacated space, and the midfielder passes in behind, sometimes between the two centre backs.',
    'Midfielder with time on the ball',
    'Through ball behind the line into the space the dropping forward opened.',
    NULL, 24, 27, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping forward', 'checks short and pulls his marker'),
    (2, 'Second forward', 'runs straight or diagonally into the vacated space'),
    (3, 'Central midfielder', 'plays the through ball behind the line')
) AS v(so, role, job);

-- 9. pp.26-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '1.7C / 1.7F Diagonal ball in behind', 'Diagonal long ball after decoy drop',
    'The forward nearest the ball drops and pulls his marker. This opens a diagonal lane for the wing back, or for a centre back after a lateral pass, to play long behind the line for the other forward''s diagonal run. It needs a clear signal between the passer and the forwards.',
    'Wing back or wide CB in possession, forwards level, signal given',
    'Long diagonal pass behind the defensive line.',
    NULL, 26, 28, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near forward', 'drops to drag his marker and open the lane'),
    (2, 'Far forward', 'runs diagonally into the space behind'),
    (3, 'Wing back / left centre back', 'plays the long diagonal on the signal')
) AS v(so, role, job);

-- 10. pp.27-27
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '1.7D Moving towards central midfielder under pressure', 'Forwards come short to help pressed CM',
    'When a CM is pressed by several opponents, both forwards come towards him into open passing lanes.',
    'Central midfielder pressed by 3 opponents',
    'Release the pressure with a forward pass and move the attack forward.',
    NULL, 27, 27, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'move into the passing lanes towards the pressed CM'),
    (2, 'Pressed central midfielder', 'plays into the free forward')
) AS v(so, role, job);

-- 11. pp.29-29
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '1.8 Individual movements of the forwards', 'Separated forwards: counter-movement and blind side',
    'When the strikers are far apart, each one checks away before moving (short then long, in then out) and receives the pass on the side opposite his first move. The advanced forward stands behind the far-side CB''s shoulder so the CB cannot watch both man and ball. If the CB drops, the forward receives in front. If the CB holds his line, the forward runs in behind. The deeper forward finds space behind the opponent''s midfield line, body open to goal.',
    'Forwards distant from each other',
    'Beat markers individually, then link once one forward has the ball.',
    NULL, 29, 29, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Advanced forward', 'positions on the far CB''s blind side; chooses to come short or run in behind'),
    (2, 'Deeper forward', 'frees himself behind the opponent''s midfield line, body open to goal'),
    (3, 'Both forwards', 'counter-movement before every run; linked diagonally around the ball')
) AS v(so, role, job);

-- 12. pp.31-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', '2.1 Strong central defensive core', 'Back three plus spare man',
    'Against two forwards, or one forward and a No.10, the three CBs mark the attackers tightly and always keep a spare man to cover and protect depth. The rule is to keep a numerical advantage at the back. Against three forwards (e.g. 4-3-3), one or both wing backs drop to make a back four.',
    'Opponent''s number of forwards',
    'Control the central area while keeping a free covering defender.',
    NULL, 31, 32, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two centre backs', 'mark the opposing forwards tightly'),
    (2, 'Spare centre back', 'covers and protects the space behind'),
    (3, 'Wing back(s)', 'drop into the line when the opponent fields 3 forwards')
) AS v(so, role, job);

-- 13. pp.33-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', '2.2 A centre back is always able to provide cover on the weak side', 'Defending crosses with five',
    'When the wing back goes out to close down a wide ball carrier, the near CB takes the front post and the other two CBs mark the two nearest attackers. The far wing back is free to pick up a runner arriving from the weak side. A CM drops in when 4 or more attackers are in the box.',
    'Wing back presses the ball carrier out wide',
    'Every box runner has a marker, including the late weak-side runner.',
    NULL, 33, 33, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near centre back', 'takes the front post'),
    (2, 'Middle and far centre backs', 'mark the two closest attackers'),
    (3, 'Far wing back', 'marks the weak-side runner into the box'),
    (4, 'Central midfielder', 'drops into the box when 4+ attackers arrive')
) AS v(so, role, job);

-- 14. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', '2.3 Numerical disadvantage in wide areas defended by 1 wing back', 'Midfielder slides wide to help wing back',
    'Only the wing back covers each flank, so a second attacker arriving there creates a 2v1. A CM slides out to help, and the other two midfielders tighten centrally.',
    'Extra opponent joins the wing back''s zone',
    'Close the wide overload while keeping central balance.',
    NULL, 34, 34, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing back', 'defends the depth on the flank'),
    (2, 'Ball-side central midfielder', 'slides wide to double up'),
    (3, 'Other two midfielders', 'tighten the central area')
) AS v(so, role, job);

-- 15. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', '2.4 Difficulty in performing aggressive pressing in the opposition half', 'Timed long pressing runs',
    'The 3-5-2 struggles to press full backs, the deepest opposing midfielder, and back-three build-ups. Forwards and midfielders must make long pressing runs timed so that no one arrives late on his man.',
    'Opponent builds through full backs or the DM',
    'Press high without leaving gaps from late pressers.',
    NULL, 34, 34, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'make medium to long pressing runs onto full backs / the DM'),
    (2, 'Forwards', 'time their press with the midfield line')
) AS v(so, role, job);

-- 16. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '4-4-2: 1.1 Overcoming the first line of pressing', 'Wide CB receives free and drives',
    'The three CBs spread wide against the two forwards (3v2), which makes it hard for the forwards to press or mark. The free wide CB takes the ball from the middle CB out wide and dribbles forward.',
    'Two forwards cannot cover three CBs',
    'Get past the first line of pressure with a wide CB carrying the ball.',
    '4-4-2', 38, 38, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back', 'passes to whichever wide CB is free'),
    (2, 'Wide centre back', 'receives wide and dribbles forward into space')
) AS v(so, role, job);

-- 17. pp.39-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '4-4-2: 1.2A Wide CB pressed by opposing winger', 'Wide CB options when winger presses',
    'After driving out, the RCB is closed down by the opposing winger. He has four options: pass straight to the advanced RWB; reach the RWB via the RCM; find the free DM, who plays diagonally into the LCM''s run behind the midfield line; or find the DM, who uses that run to switch to the LWB.',
    'Opposing winger steps up to the RCB',
    'Get the ball between the opponent''s midfield and defensive lines or switch to the far wing back.',
    '4-4-2', 39, 39, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back', 'chooses the open lane among the 4 options'),
    (2, 'Right wing back', 'advanced wide target'),
    (3, 'Defensive midfielder', 'free in the middle; plays the diagonal or the switch'),
    (4, 'Left central midfielder', 'runs forward in behind the midfield line'),
    (5, 'Left wing back', 'advanced far-side switch target')
) AS v(so, role, job);

-- 18. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '4-4-2: 1.2B Wide CB pressed by central midfielder', 'Wide CB options when CM presses',
    'The opponent''s left CM closes the RCB instead of the winger. The RCB can play diagonally to the advanced RWB, forward to the RCM, to the RCM via the DM, or to the DM in space, who switches long to the LWB. The pick depends on how the presser comes and which lanes he leaves open.',
    'Opposing central midfielder presses the RCB',
    'Get past the midfield line, or switch to the free far side.',
    '4-4-2', 40, 40, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back', 'reads the presser''s angle and picks the free lane'),
    (2, 'Right wing back', 'diagonal pass target out wide'),
    (3, 'Right central midfielder', 'receives forward between the lines'),
    (4, 'Defensive midfielder', 'link or long switch to the LWB')
) AS v(so, role, job);

-- 19. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '4-4-2: 1.2C Middle CB dribbling through the centre', 'Middle CB carries, four outlets',
    'The middle CB dribbles out through the centre. He then finds the RWB''s forward run between winger and CM, passes forward between the two opposing CMs to the RCM, reaches the RCM via the DM, or switches long in the air to the LWB.',
    'Middle CB unpressed and carrying centrally',
    'Play through or around the 4-4-2 midfield.',
    '4-4-2', 41, 41, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back', 'carries centrally and chooses among the outlets'),
    (2, 'Right wing back', 'runs forward into the lane between winger and CM'),
    (3, 'Right central midfielder', 'receives between the two opposing CMs'),
    (4, 'Left wing back', 'makes a forward run for the aerial switch')
) AS v(so, role, job);

-- 20. pp.42-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '4-4-2: 1.3A Wing back decides in behind or inside', 'Wing back reads full back press',
    'If the opposing full back presses the RWB aggressively, the RWB plays into the space behind him for the RCM''s forward run. If the full back holds the back four''s line and the winger presses instead, the RWB passes inside to the RCM, who has moved between the lines.',
    'Who presses the wing back: full back or winger',
    'Exploit the space behind the full back or get the ball between the lines.',
    '4-4-2', 42, 42, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back', 'reads the press and plays in behind or inside'),
    (2, 'Right central midfielder', 'runs behind the full back, or shows between the lines')
) AS v(so, role, job);

-- 21. pp.43-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '4-4-2: 1.3B CM options after receiving between the lines', 'Between-lines CM finds the final pass',
    'Once the RCM receives between the lines, he plays a forward in behind if the opposing CBs are close together and the full backs are open. If the CBs stay wide and track the forwards, he dribbles at the line to commit defenders (3v2, 5v4). If the whole back four is compact and narrow, he passes wide to either wing back running forward.',
    'RCM receives between the lines',
    'Get the ball behind the defensive line.',
    '4-4-2', 43, 43, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder', 'reads the back four: through ball, dribble, or wide pass'),
    (2, 'Forwards (F1, F2)', 'run in behind when the CBs are narrow'),
    (3, 'Wing backs', 'make advanced runs when the back four is narrow')
) AS v(so, role, job);

-- 22. pp.44-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', '4-4-2: 1.4 Pressing and defensive organisation', 'Press 4-4-2 build-up, back five',
    'The midfield three line up straight away. When the ball goes to a full back, F1 and F2 screen the two CBs, the RCM slides out to press the full back, and the DM and LCM close the opposing CMs. Behind them, the back five has a 3v2 on the forwards and each wing back takes his winger 1v1.',
    'Ball played to the opposing full back',
    'Lock the ball onto one side with every nearby receiver covered.',
    '4-4-2', 44, 44, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards (F1, F2)', 'cover the two centre backs'),
    (2, 'Right central midfielder', 'slides across to press the full back'),
    (3, 'DM and LCM', 'close down the opposing central midfielders'),
    (4, 'Three centre backs', '3v2 against the two forwards'),
    (5, 'Wing backs', '1v1 duels against the wingers')
) AS v(so, role, job);

-- 23. pp.46-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '4-2-3-1: 2.1A Ball moved between the 3 centre backs', 'Circulate across back three vs lone striker',
    'The three CBs stay spread (but not too far apart) against the lone forward (3v1). When he presses one wide CB, the ball moves calmly across to the other wide CB, who dribbles forward freely.',
    'Lone forward presses one wide CB',
    'Beat the first line by circulating to the far wide CB.',
    '4-2-3-1', 46, 46, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre backs', 'spread; the far one receives and drives'),
    (2, 'Middle centre back', 'links the switch across the back three')
) AS v(so, role, job);

-- 24. pp.47-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '4-2-3-1: 2.1B Opposition wingers press the wide centre backs', 'WB or DM drops to beat 3v3 press',
    'When the wingers push up to make a 3v3 on the back three, one or both wing backs and/or the DM drop to restore the extra man. Option 1: the RWB drops, then CB passes to RCB, who plays wide to the RWB. Option 2: the DM drops, then CB to RCB to DM, who plays out to the RWB. Option 3: if the winger tightly marks the RCB and the lane is open, the CB passes straight to the RWB.',
    'Opposing wingers step up onto the wide CBs',
    'Recreate a numerical advantage at the back and play out wide.',
    '4-2-3-1', 47, 47, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back', 'drops deeper to give an outlet'),
    (2, 'Defensive midfielder', 'drops between the CBs as the extra man'),
    (3, 'Middle centre back', 'finds the free outlet directly when the lane opens')
) AS v(so, role, job);

-- 25. pp.48-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '4-2-3-1: 2.2A-B Wide CB pressed by winger or central midfielder', 'DM drags No.10, LCM drops into space',
    'When the RCB is pressed by the winger or a CM, he can find the RWB directly, find the RWB via the RCM, or reach the RCM via the DM. The added solution is that the DM moves up and pulls the No.10 away, the LCM drops into the vacated space to take the RCB''s pass, and then switches to the advanced LWB.',
    'RCB closed down by winger or CM',
    'Get the ball between the lines or to the free far wing back.',
    '4-2-3-1', 48, 49, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right centre back', 'picks the lane left open by the presser'),
    (2, 'Defensive midfielder', 'pushes up to drag the No.10 away'),
    (3, 'Left central midfielder', 'drops into the vacated space, then switches play'),
    (4, 'Left wing back', 'makes a forward run for the switch')
) AS v(so, role, job);

-- 26. pp.50-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '4-2-3-1: 2.2C Wing back''s options when dribbling forward', 'CM drops for pressed wing back',
    'Following on from the WB-drop build-up, the RWB carries forward and is closed down by a CM. The RCM drops for a simple inside pass. The RCM then plays diagonally into the LCM''s diagonal run, or uses the LCM to switch play to the advanced LWB.',
    'Dribbling RWB pressed by opposing CM',
    'Get the ball between the midfield and defensive lines or switch to the far flank.',
    '4-2-3-1', 50, 50, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back', 'carries forward, then passes inside'),
    (2, 'Right central midfielder', 'drops to receive, then plays the diagonal'),
    (3, 'Left central midfielder', 'makes a diagonal run or lays off the switch'),
    (4, 'Left wing back', 'advanced far-side target')
) AS v(so, role, job);

-- 27. pp.51-52
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', '4-2-3-1: 2.3A-B Playing in behind the defensive line', 'Wing back read, then CM final ball',
    'Same reads as against the 4-4-2. If the full back presses the RWB, he plays in behind for the RCM. If a winger presses and the full back holds, he passes inside to the RCM between the lines. The RCM then plays a forward in behind (CBs narrow), dribbles at the line (CBs wide), or goes wide to a wing back (back four narrow).',
    'Who presses the wing back; then the shape of the back four',
    'Get the ball behind the opponent''s back four.',
    '4-2-3-1', 51, 52, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back', 'reads the press: in behind or inside'),
    (2, 'Right central midfielder', 'runs in behind or receives between the lines and picks the final ball'),
    (3, 'Forwards', 'run in behind when the CBs are close together'),
    (4, 'Wing backs', 'make advanced wide runs against a narrow back four')
) AS v(so, role, job);

-- 28. pp.53-53
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', '4-2-3-1: 2.4 Pressing and defensive organisation', 'Press 4-2-3-1, RCB steps to No.10',
    'This is the 4-4-2 press: midfield three in a line, forwards screen the CBs, the RCM slides to the full back, and the DM and LCM close the two CMs. When the RCM leaves, the RCB steps up to mark the No.10. The back five becomes a four, with LCB and CB 2v1 on the striker and the wing backs 1v1 on the wingers.',
    'Ball played to the opposing full back',
    'Cover every nearby receiver, including the No.10, while keeping a 2v1 on the striker.',
    '4-2-3-1', 53, 53, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards (F1, F2)', 'cover the two centre backs'),
    (2, 'Right central midfielder', 'presses the full back'),
    (3, 'DM and LCM', 'close down the two central midfielders'),
    (4, 'Right centre back', 'steps out to mark the No.10'),
    (5, 'LCB and CB', '2v1 against the lone striker'),
    (6, 'Wing backs', '1v1 against the wingers')
) AS v(so, role, job);

-- 29. pp.55-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 4-3-3 - 3.1 Overcoming the first line of pressing', 'Three centre backs beat lone forward (3v1)',
    'Against a single striker the three centre backs spread far enough apart that he cannot press or screen two of them; the pressed middle CB lays it to a wide CB.',
    'Lone forward closes the middle centre back',
    'Wide centre back becomes the free man and the team moves past the first line.',
    '4-3-3', 55, 55, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back', 'Draws the forward, passes to the wide CB'),
    (2, 'Wide centre back', 'If unpressed carry the ball forward; if the striker shifts across, pass into the DM'),
    (3, 'Defensive midfielder', 'Stays free in the centre as the outlet')
) AS v(so, role, job);

-- 30. pp.56-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 4-3-3 - 3.1 Overcoming the first line of pressing', 'Wing backs and DM drop vs pressing wingers',
    'When the opposing wingers push up to press the back three 3v3, one or both wing backs and/or the DM drop closer to rebuild a spare man at the back.',
    'Opposing wingers step up onto the wide centre backs',
    'Recreate numerical superiority and reach the wing back outside the press.',
    '4-3-3', 56, 56, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing back', 'Drops back to receive from the wide CB, or directly from the middle CB when the winger marks the wide CB tightly'),
    (2, 'Defensive midfielder', 'Drops to receive from the wide CB, then plays out wide to the wing back'),
    (3, 'Middle centre back', 'Chooses CB->RCB->RWB, CB->RCB->DM->RWB, or the direct pass to the wing back if the lane is open')
) AS v(so, role, job);

-- 31. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 4-3-3 - 3.1 Overcoming the first line of pressing', 'DM receives in gap behind pressing wingers',
    'When both wingers press high, a big space opens between their front line and midfield; the DM takes a simple pass there and drives forward.',
    'Both opposing wingers press high',
    'Bypass the front three via the DM in the vacated pocket.',
    '4-3-3', 57, 57, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Shows in the gap, receives and dribbles forward into space'),
    (2, 'Wide centre back', 'Plays the simple pass into the DM')
) AS v(so, role, job);

-- 32. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 4-3-3 - 3.1 Overcoming the first line of pressing', 'DM drops into back line, wide CBs split',
    'Variation: the wide centre backs go very wide, dragging the pressing wingers out, and the DM drops between them to make 2v1 in the centre with the middle CB.',
    'Wingers mark the wide centre backs',
    'Middle CB finds the dropping DM who carries into the space created.',
    '4-3-3', 57, 57, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre backs (LCB and RCB)', 'Push very wide to pull their markers away'),
    (2, 'Defensive midfielder', 'Drops into the defensive line, receives from the middle CB and dribbles forward'),
    (3, 'Middle centre back', 'Uses the 2v1 against the striker')
) AS v(so, role, job);

-- 33. pp.58-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 4-3-3 - 3.2 Moving the ball between the lines', 'Wide CB pressed: three routes through midfield',
    'The right centre back is closed down (by the winger, or in a variant by the opposing central midfielder) and must find a team-mate between the opposing midfield and back lines.',
    'Wide CB pressed by winger or central midfielder',
    'Ball reaches a free player between the lines or the far wing back high on the flank.',
    '4-3-3', 58, 59, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back', 'Option 1 pass straight to the wing back; option 2 to the RCM via the DM; option 3 inside to the DM'),
    (2, 'Defensive midfielder', 'Slides across to link, or receives in space and plays short to LCM or switches'),
    (3, 'Far wing back (LWB)', 'Holds an advanced wide position for the switch'),
    (4, 'Note', 'Which option depends on how the presser comes and which lanes stay open')
) AS v(so, role, job);

-- 34. pp.60-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 4-3-3 - 3.2 Moving the ball between the lines', 'Wing back pressed: CM drops, DM switches',
    'A deep wing back dribbling forward is pressed by the winger; the near central midfielder drops as a simple inside option and bounces it to the DM, who plays forward.',
    'Wing back pressed with little time or space',
    'DM finds the far CM''s diagonal run or switches to the far wing back.',
    '4-3-3', 60, 60, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side wing back', 'Plays inside to the dropping CM'),
    (2, 'Ball-side central midfielder (RCM)', 'Drops short, then lays it inside to the DM'),
    (3, 'Defensive midfielder', 'Moves across, then diagonal pass to the far CM''s run or long switch'),
    (4, 'Far central midfielder (LCM)', 'Makes a diagonal run between the lines')
) AS v(so, role, job);

-- 35. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 4-3-3 - 3.2 Moving the ball between the lines', 'DM drives through centre after high press',
    'When the front three press the back three high, the DM is free in midfield and carries the ball, looking to reach a team-mate between the lines.',
    'Front three press the centre backs; DM free',
    'Break the midfield line with a pass or switch.',
    '4-3-3', 61, 61, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Dribbles through the centre; picks one of four options'),
    (2, 'Right wing back', 'Forward run into an advanced wide spot'),
    (3, 'Right central midfielder', 'Receives a forward pass split between the two opposing CMs'),
    (4, 'Left central midfielder', 'Drops and comes across to relay to the RCM'),
    (5, 'Left wing back', 'Forward run for a long switch')
) AS v(so, role, job);

-- 36. pp.62-63
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 4-3-3 - 3.3 Playing in behind the defensive line', 'Wing back reads the full back: behind or inside',
    'The wing back on the ball decides from how he is pressed: if the opposing full back jumps out aggressively, the space behind him is attacked by the RCM''s run; if the full back holds in the back four, pass in front for the RCM running between the lines; if the winger blocks the forward pass, play back to the RCM behind the midfield line to keep the ball.',
    'Wing back in possession; type of pressure from full back or winger',
    'Exploit the space left by the full back, or keep possession safely.',
    '4-3-3', 62, 63, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing back', 'Read the presser and choose the pass'),
    (2, 'Ball-side central midfielder', 'Run in behind the full back, or run between lines, or offer behind the midfield line')
) AS v(so, role, job);

-- 37. pp.64-64
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 4-3-3 - 3.3 Playing in behind the defensive line', 'CM between lines picks the run behind',
    'After the RCM receives between the lines he looks to release a team-mate behind the back four depending on the centre backs and full backs.',
    'RCM receives between the lines facing the back four',
    'Ball played in behind or a numbers-up attack on the back line.',
    '4-3-3', 64, 64, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-carrying central midfielder', 'Picks the pass or keeps dribbling to commit defenders'),
    (2, 'Front two', 'Run into the gaps if the centre backs are tight and full backs open'),
    (3, 'Wing backs', 'Make advanced runs when the back four is compact and narrow'),
    (4, 'Note', 'If the CBs stay wide covering the strikers, the RCM dribbles on for a 3v2 or 5v4')
) AS v(so, role, job);

-- 38. pp.65-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 4-3-3 - 3.4 Pressing in a 4-4-2 or 4-4-1-1', '4-4-2 press: let CB carry, then press',
    'Out of possession the team reshapes to 4-4-2; the two forwards stand level and narrow to cut the pass into the opposing DM, inviting the wide centre back to dribble out. When he does, the nearest forward presses and the other slides onto the DM. Aim is to push play out to the full backs.',
    'Opposing centre back starts to dribble forward',
    'DM denied the ball; play forced wide toward the full backs.',
    '4-3-3', 65, 65, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two (F1, F2)', 'Level and narrow, screen the DM; F1 presses the carrier, F2 slides to mark the DM'),
    (2, 'Three central midfielders', 'Stay in a line to stop the DM receiving centrally')
) AS v(so, role, job);

-- 39. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 4-3-3 - 3.4 Pressing in a 4-4-2 or 4-4-1-1', '4-4-1-1 press: second forward marks DM',
    'Variant with one forward behind the other: F2 sits on the opposing DM while F1 presses the dribbling centre back; the three opposing central midfielders are all marked tightly.',
    'Opposing centre back dribbles forward',
    'Block all central passes.',
    '4-3-3', 66, 66, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lead forward (F1)', 'Presses the centre back when he carries'),
    (2, 'Second forward (F2)', 'Stays deeper marking the DM'),
    (3, 'Midfield three', 'Tight marking on the opposing central midfielders')
) AS v(so, role, job);

-- 40. pp.67-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 4-3-3 - 3.4 Pressing in a 4-4-2 or 4-4-1-1', 'CM jumps to full back, chain reaction',
    'When the centre back passes wide to the free full back, the near central midfielder (or the wing back) closes him down. Using the CM triggers a chain: DM shifts to cover the CM''s spot and pick up the runner, far CM tucks in, far wing back pushes up to press the other full back if the ball goes there. If the opposing CM and winger swap places, the near centre back steps to the inverted winger and the near wing back pushes up onto the wide CM instead.',
    'Ball played out wide to the free full back',
    'Protect the centre while the full back is pressed.',
    '4-3-3', 67, 68, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side central midfielder (RCM)', 'Presses the full back'),
    (2, 'Defensive midfielder', 'Shifts across to cover the RCM''s position and mark the forward-running CM'),
    (3, 'Far central midfielder (LCM)', 'Tucks in to tighten the centre'),
    (4, 'Far wing back (LWB)', 'Pushes up to shorten the distance to the other full back'),
    (5, 'Ball-side wing back', 'Marks the winger, or moves up onto the opposing CM who drifts wide')
) AS v(so, role, job);

-- 41. pp.69-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 4-3-3 - 3.4 Pressing in a 4-4-2 or 4-4-1-1', 'Wing back presses, far wing back makes back four',
    'If a wing back presses the full back he must start in front of the opposing winger; the near CM or wide CB takes the winger, and the opposite wing back drops to form a back four. CM pressing = higher press but easily read and a long ball to the far winger is a risk; wing-back pressing = more bodies in the middle but slower and risks 3v3 on a long pass.',
    'Full back receives; wing back positioned ahead of the winger',
    'Press the full back while keeping a solid back four.',
    '4-3-3', 69, 69, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side wing back', 'Steps out to press the full back'),
    (2, 'Ball-side CM or wide centre back', 'Marks the opposing winger'),
    (3, 'Far wing back', 'Drops into the back line to make four'),
    (4, 'Far central midfielder', 'Presses the other full back if the ball is switched')
) AS v(so, role, job);

-- 42. pp.70-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 4-3-3 - 3.5 Pressing in a 5-3-2', '5-3-2 press: CM presses full back, line reacts',
    'In a 5-3-2 the forwards screen the DM and the three midfielders block central lanes. When the full back gets it, the RCM presses him and the RWB, RCB and middle CB react to the opposing CM, winger and striker: if the winger stays wide (marked by the RWB), the RCB steps up to the opposing CM and the back line shifts; if the opposing CM and winger swap, the RCB steps to the inside winger, the RWB to the wide CM, CB to the striker and LCB shifts across.',
    'Opposing full back receives wide',
    'Keep the ball out of the centre while pressing the full back.',
    '4-3-3', 70, 71, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two', 'Block passing lanes into the DM'),
    (2, 'Midfield three', 'Block the centre or mark the CMs tight; RCM presses the full back'),
    (3, 'Right centre back', 'Steps forward onto the opposing CM or the inverted winger'),
    (4, 'Right wing back', 'Marks the winger or steps up onto the CM who goes wide'),
    (5, 'Middle and left centre backs', 'Shift across to mark the striker and keep cover and balance')
) AS v(so, role, job);

-- 43. pp.72-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 4-3-3 - 3.5 Pressing in a 5-3-2', '5-3-2 press: wing back presses, shows inside',
    'When the wing back presses the full back he angles his run and body to cut the pass up the line to the winger, pushing the carrier inside where numbers are. Chain: RCM takes the dropping winger, RCB the CM making the opposite run, CB the striker, LCB shifts, LWB drops in. If the CM instead drops short, the RCM tracks him and the RCB covers the winger.',
    'Full back receives; wing back closes',
    'Force play inside into a crowded centre.',
    '4-3-3', 72, 73, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side wing back', 'Presses with body shape blocking the line to the winger'),
    (2, 'Ball-side central midfielder', 'Picks up the winger who drops, or tracks the CM who checks short'),
    (3, 'Ball-side centre back', 'Marks the CM making a forward run, or the winger'),
    (4, 'Left centre back and left wing back', 'Shift across; LWB drops into the line for balance and numbers')
) AS v(so, role, job);

-- 44. pp.73-73
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 4-3-3 - 3.5 Pressing in a 5-3-2 (summary)', 'Defensive line: numbers up in the centre',
    'The back line always keeps a spare man in the central zone. Defending as a four, the far wing back is focused on the opposing winger while the near one can take the winger or the CM; defending as a five, wing back or CM pressing triggers the chain reaction above.',
    'Any opposition attack',
    'Never be level or outnumbered centrally.',
    '4-3-3', 73, 73, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'Keep a numerical superiority centrally'),
    (2, 'Far wing back', 'Responsible for the opposing far winger'),
    (3, 'Near wing back', 'Can take either the winger or the central midfielder')
) AS v(so, role, job);

-- 45. pp.75-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 4-3-1-2 - 4.1 Overcoming the first line of pressing', 'Three CBs stay wide vs two forwards (3v2)',
    'Against two strikers the back three stay as wide as possible so one wide CB is always the free man; he receives and carries forward. If the No.10 joins to press 3v3, the CBs come slightly closer and one or both wing backs drop, then the DM routes are used.',
    'Two forwards press; No.10 may join',
    'Wide centre back free to carry out of defence.',
    '4-3-1-2', 75, 75, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre backs', 'Stay wide; the free one receives and dribbles forward'),
    (2, 'Middle centre back', 'Finds the free wide CB'),
    (3, 'Wing backs', 'Drop if the No.10 joins the press')
) AS v(so, role, job);

-- 46. pp.76-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 4-3-1-2 - 4.2 Moving the ball between the lines', 'Exploit narrow diamond: wide CB to wing back',
    'With the right CB carrying and closed down by the opposing left CM, the diamond has no midfield width, so the target is the wing back.',
    'Wide CB pressed by the opposing central midfielder',
    'Ball to the wing back in the open flank.',
    '4-3-1-2', 76, 76, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back', 'Pass straight to the wing back, or via the RCM'),
    (2, 'Ball-side wing back', 'Free wide on the flank'),
    (3, 'Ball-side central midfielder', 'Bounce option to the wing back')
) AS v(so, role, job);

-- 47. pp.77-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 4-3-1-2 - 4.2 Moving the ball between the lines', 'Switch to weak-side wing back vs compact midfield',
    'If the opposing CM presses the wing back quickly and the block shifts across, switch to the weak-side wing back: the RCM drops to receive and plays a long diagonal; or without a long ball, the DM pushes forward to open space so the RCM can pass sideways to the dropping LCM who plays out to the LWB.',
    'Opposition shifts and compacts on the ball side',
    'Free wing back on the weak side.',
    '4-3-1-2', 77, 77, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side wing back', 'Plays inside to the RCM'),
    (2, 'Right central midfielder', 'Drops, receives and switches long, or passes across'),
    (3, 'Defensive midfielder', 'Moves forward to drag his marker and open the lane'),
    (4, 'Left central midfielder', 'Drops for the sideways pass and plays out wide'),
    (5, 'Left wing back', 'Waits high and wide on the weak side')
) AS v(so, role, job);

-- 48. pp.78-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 4-3-1-2 - 4.2 Moving the ball between the lines', 'Middle CB carries out of defence',
    'The middle centre back dribbles toward the right; the DM moves left to drag his marker and free the centre. If the opposing CM presses: RWB in space, or RCM who turns or relays wide. If not pressed: RWB, RCM then across to DM, direct diagonal to the DM, or long switch to LWB. Body shape of the presser and open lanes decide.',
    'Middle CB has space to dribble forward',
    'Ball reaches a team-mate between the lines.',
    '4-3-1-2', 78, 79, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back', 'Carries forward and chooses the option'),
    (2, 'Defensive midfielder', 'Pulls his marker away, then offers for a diagonal'),
    (3, 'Right wing back', 'Free in a wide position'),
    (4, 'Right central midfielder', 'Receives, turns or relays'),
    (5, 'Left wing back', 'Long switch target')
) AS v(so, role, job);

-- 49. pp.80-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 4-3-1-2 - 4.3 Playing in behind the defensive line', 'Use wide areas to get in behind',
    'Same wing-back read as vs 4-3-3: if the full back presses aggressively, pass into the space behind for the RCM''s forward run; if he holds his place, just pass inside to the RCM. Key point: a crowded diamond centre makes advanced central receiving hard, so the wide areas are the main route behind.',
    'Wing back on the ball, full back pressing or holding',
    'Get in behind through the flank.',
    '4-3-1-2', 80, 80, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing back', 'Read the full back; ball behind or inside'),
    (2, 'Ball-side central midfielder', 'Run behind the pressing full back or receive inside')
) AS v(so, role, job);

-- 50. pp.81-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 4-3-1-2 - 4.4 Pressing in a 3-5-2 or 3-5-1-1', 'Press the diamond: DM deeper on No.10',
    'Against 4-3-1-2 the DM sits deeper than the CMs and marks the No.10 tightly; the CMs tighten and block central lanes; the two forwards level and narrow block the DM so the CB dribbles; then F1 presses and F2 takes the DM. In 3-5-1-1, F2 starts behind F1 on the DM and the three CMs are marked tightly.',
    'Opposing centre back starts to carry the ball',
    'Force play away from the DM and the centre.',
    '4-3-1-2', 81, 82, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Deeper, tight on the No.10'),
    (2, 'Front two', 'Block the DM lane; F1 presses the carrier, F2 marks the DM'),
    (3, 'Central midfielders', 'Tighten and block passes inside')
) AS v(so, role, job);

-- 51. pp.83-83
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 4-3-1-2 - 4.4 Pressing in a 3-5-2 or 3-5-1-1', 'CM presses full back, wing back covers',
    'Near CM and wing back work as a pair on that flank: as the RCM goes to press the full back, the RWB moves across and up to tightly mark the opposing CM; if that CM drifts wide to receive, the RWB pushes up quickly onto him.',
    'Ball goes to the opposing full back',
    'Full back pressed, his nearest midfielder marked.',
    '4-3-1-2', 83, 83, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side central midfielder (RCM)', 'Presses the full back'),
    (2, 'Ball-side wing back (RWB)', 'Comes across and forward to mark the opposing CM tightly')
) AS v(so, role, job);

-- 52. pp.84-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 4-3-1-2 - 4.4 Pressing in a 3-5-2 or 3-5-1-1', 'Wing back presses full back, CM covers',
    'Mirror option: the RWB presses the full back with body shape forcing him inside; the RCM covers and tightly marks the opposing CM, tracking him even toward the touchline.',
    'Ball goes to the opposing full back',
    'Full back forced inside into numbers; CM cannot receive.',
    '4-3-1-2', 84, 84, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side wing back', 'Presses with body shape forcing play inside'),
    (2, 'Ball-side central midfielder', 'Tracks and marks the opposing CM')
) AS v(so, role, job);

-- 53. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 4-3-1-2 - 4.5 Organisation of the defensive line', 'Keep 3v2 and handle the No.10',
    'The back three keep a 3v2 against the two strikers; the DM deals with the No.10 when he comes to receive. If the No.10 escapes the DM and gets the ball, the line adjusts: CB marks the forward nearest the ball, LCB slides to cover and balance centrally, LWB shifts across to mark the second forward.',
    'No.10 receives after losing the DM',
    'Keep central numbers and mark both strikers.',
    '4-3-1-2', 85, 85, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Marks the No.10'),
    (2, 'Middle centre back', 'Marks the nearest forward'),
    (3, 'Left centre back', 'Shifts to cover and balance'),
    (4, 'Left wing back', 'Shifts across onto the second forward')
) AS v(so, role, job);

-- 54. pp.87-87
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 3-5-2 - 5.1 Overcoming the first line of pressing', 'Three CBs stay wide vs two forwards (3v2)',
    'Against the 3-5-2''s two strikers, the back three stay wide so one wide CB is free to receive from the middle CB and carry forward.',
    'Two forwards press the back three',
    'Free wide centre back carries out.',
    '3-5-2', 87, 87, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre backs', 'Stay wide; free one receives and dribbles'),
    (2, 'Middle centre back', 'Finds the free wide CB')
) AS v(so, role, job);

-- 55. pp.88-88
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 3-5-2 - 5.2 Moving the ball between the lines', 'Wing backs pin, ball-side CM goes wide',
    'Wing backs push high up against the opposing wing backs near their back line; the ball-side CM moves into the wide space as a receiver. The carrying RCB passes to him directly or via the DM near the ball, aiming for a through pass behind.',
    'Right CB carrying out of defence',
    'Get the CM free between the lines wide, then play through.',
    '3-5-2', 88, 88, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing backs', 'Advance to pin the opposing wing backs'),
    (2, 'Ball-side central midfielder', 'Drifts wide to receive'),
    (3, 'Defensive midfielder', 'Stays close to the ball as a relay'),
    (4, 'Wide centre back', 'Chooses direct or via the DM')
) AS v(so, role, job);

-- 56. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 3-5-2 - 5.2 Moving the ball between the lines', 'Switch via DM to far CM''s diagonal run',
    'If the opposing CM presses the RCM quickly, switch to the weak side: RCM inside to the DM, who plays a diagonal for the LCM''s forward run between the lines.',
    'Ball-side CM pressed; space limited',
    'Release the far central midfielder between the lines.',
    '3-5-2', 89, 89, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right central midfielder', 'Plays inside to the DM'),
    (2, 'Defensive midfielder', 'Diagonal pass to the LCM''s run'),
    (3, 'Left central midfielder', 'Runs forward between the lines')
) AS v(so, role, job);

-- 57. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 3-5-2 - 5.2 Moving the ball between the lines', 'Opposing wing back jumps: ball behind or to striker',
    'If the opposing wing back steps forward to mark the RCM, the RCB either plays in behind for the advanced RWB (if their defenders are slow to shift) or into the striker to use the 2v2 the forwards have centrally.',
    'Opposing wing back steps up onto the central midfielder',
    'Exploit the space behind or the 2v2 up front.',
    '3-5-2', 89, 89, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back', 'Pass behind for the wing back or into F1'),
    (2, 'Ball-side wing back', 'Runs behind the stepping wing back'),
    (3, 'Front two', 'Attack the 2v2 against the centre backs')
) AS v(so, role, job);

-- 58. pp.90-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 3-5-2 - 5.2 Moving the ball between the lines', 'CB or DM carries into free midfield',
    'With our wing backs advanced there is space in midfield. If the middle CB carries and the opposing CM presses, pass to the RCM directly or via the DM. If not pressed, the DM dribbles forward and plays a diagonal for the RCM''s diagonal run between the lines.',
    'Middle CB or DM has space to carry',
    'Ball to the RCM between the lines.',
    '3-5-2', 90, 90, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back', 'Carries forward; to RCM or via DM'),
    (2, 'Defensive midfielder', 'Relay when CB carries; carrier with diagonal pass when unpressed'),
    (3, 'Right central midfielder', 'Diagonal run to receive between the lines')
) AS v(so, role, job);

-- 59. pp.91-91
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 3-5-2 - 5.3 Playing in behind the defensive line', 'CM between lines vs back three: four options',
    'As the RCM carries from between the lines, the two forwards move to unsettle the wide CBs and the LWB makes a cutting run between the opposing wing back and RCB. Pick: the cutting LWB if their RCB tucks in; out wide to the LWB if the wing back tucks in; dribble on and commit 3v3 if wide CBs go wider to cover the forwards; RWB run in behind if their LCB stays central and the LWB does not come inside.',
    'Central midfielder receives between the lines',
    'Ball behind the back three or a 3v3 attack.',
    '3-5-2', 91, 91, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-carrying central midfielder', 'Read the back three and pick the option'),
    (2, 'Front two', 'Movements to create doubt for the wide CBs'),
    (3, 'Far wing back (LWB)', 'Cutting run between wing back and centre back, or stays wide'),
    (4, 'Near wing back (RWB)', 'Runs in behind if space opens')
) AS v(so, role, job);

-- 60. pp.92-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 3-5-2 - 5.4 Pressing and defensive organisation', 'Press 3-5-2: CM jumps onto wide CB',
    'The three midfielders start in a line and keep the opposing DM out of the game, the two forwards block the lane into him. The RCM steps out to press the wide centre back, angling to send him inside into numbers. If the opposing wing back stays and their CM pushes on, the RWB holds on his direct opponent and the DM tracks the CM''s run.',
    'Opposing wide CB has the ball',
    'Force play inside and keep the DM out.',
    '3-5-2', 92, 92, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two', 'Block the passing lane to the DM'),
    (2, 'Ball-side central midfielder', 'Presses the wide CB, directing him inside'),
    (3, 'Ball-side wing back', 'Stays to mark the opposing wing back'),
    (4, 'Defensive midfielder', 'Tracks the opposing CM''s forward run')
) AS v(so, role, job);

-- 61. pp.93-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 3-5-2 - 5.4 Pressing and defensive organisation', 'Opposing CM drifts wide: chain reaction',
    'If the opposing left CM moves wide to receive the next pass: RWB tracks forward to mark him, DM drops in front of the defence to block lanes to the strikers, RCB shifts out onto the opposing wing back, CB and LCB slide across to mark the two strikers, LWB drops to keep a spare man at the back.',
    'Opposing CM moves into a wide position as the wide CB is pressed',
    'Mark all receivers while staying numbers-up at the back.',
    '3-5-2', 93, 93, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right wing back', 'Tracks and marks the CM who went wide'),
    (2, 'Defensive midfielder', 'Drops to screen passes into the strikers'),
    (3, 'Right centre back', 'Shifts across to mark the opposing wing back'),
    (4, 'Middle and left centre backs', 'Slide across to mark the two forwards'),
    (5, 'Left wing back', 'Drops back to retain superiority')
) AS v(so, role, job);

-- 62. pp.95-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 3-4-3 - 6.1 Overcoming the first line of pressing', 'Three CBs beat lone forward (3v1)',
    'Same as vs 4-3-3: against the lone central striker the back three spread, the pressed middle CB passes to a wide CB who dribbles if unpressed or plays into the free DM.',
    'Lone forward presses the middle centre back',
    'Wide CB or DM free to progress.',
    '3-4-3', 95, 95, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back', 'Draws the striker and passes wide'),
    (2, 'Wide centre back', 'Dribbles forward or plays into the DM'),
    (3, 'Defensive midfielder', 'Free in the centre')
) AS v(so, role, job);

-- 63. pp.96-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 3-4-3 - 6.1 Overcoming the first line of pressing', 'Wingers press 3v3: wing backs push, CM drops wide',
    'When the opposing wingers press to make 3v3, the back three tighten slightly, the wing backs push forward onto their direct markers, and the ball-side CM drops into a wide position. Route: RCM drops and gets it from the RCB; or DM drops and relays out to the RCM; or CB direct to the RCM if the winger marks the RCB. Space is behind their attacking line.',
    'Opposing wingers step up onto the wide CBs',
    'Reach the CM or DM behind the front three.',
    '3-4-3', 96, 96, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'Tighten slightly'),
    (2, 'Wing backs', 'Push high, right up against their direct markers'),
    (3, 'Ball-side central midfielder', 'Drops into a wide position to receive'),
    (4, 'Defensive midfielder', 'Drops to receive and play out to the RCM')
) AS v(so, role, job);

-- 64. pp.97-97
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 3-4-3 - 6.1 Overcoming the first line of pressing', 'DM drops into back line, wide CBs split',
    'Wide CBs push very wide to drag the wingers; wing backs and CMs stay up occupying their markers; the DM drops into the defensive line for a 2v1 centrally, receives from the middle CB and dribbles into space to play between the lines.',
    'Wingers mark the wide centre backs',
    'Middle CB and DM beat the lone striker 2v1.',
    '3-4-3', 97, 97, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre backs', 'Go very wide'),
    (2, 'Wing backs and central midfielders', 'Hold advanced spots occupying their direct opponents'),
    (3, 'Defensive midfielder', 'Drops between the CBs, receives and carries forward')
) AS v(so, role, job);

-- 65. pp.98-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 3-4-3 - 6.2 Moving the ball between the lines', 'Wing back pins, CM free wide',
    'The RWB pushes right up to force his direct opponent into their back line while the RCM takes a wide spot; with the RCB closed by the winger, he finds the free RCM directly or via the DM.',
    'Wide CB closed down by the opposing winger',
    'Free central midfielder between the lines.',
    '3-4-3', 98, 98, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing back', 'Pushes up to pin the opposing wing back'),
    (2, 'Ball-side central midfielder', 'Wide and free of marking'),
    (3, 'Wide centre back', 'Direct pass or through the DM')
) AS v(so, role, job);

-- 66. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 3-4-3 - 6.2 Moving the ball between the lines', 'DM as link player between the lines',
    'If the opposing CM presses the RCB quickly, the RCB passes to the DM, who plays through the gap the presser left for the RCM coming inside, or a diagonal for the LCM''s forward run. Variant: the RCM drops to receive with the wingers behind the ball, is pressed, and plays inside to the DM, who finds the LCM free between the lines.',
    'Opposing CM presses the wide CB or the dropping RCM',
    'Use the gap the presser leaves to reach a CM between the lines.',
    '3-4-3', 99, 99, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back or dropping RCM', 'Plays into the DM'),
    (2, 'Defensive midfielder', 'Link pass into the gap or diagonal to the far CM'),
    (3, 'Right central midfielder', 'Moves inside into the gap to receive'),
    (4, 'Left central midfielder', 'Runs forward between the lines')
) AS v(so, role, job);

-- 67. pp.100-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 3-4-3 - 6.2 Moving the ball between the lines', 'Opposing wing back jumps: ball behind or to striker',
    'If the opposing left wing back moves up to mark the RCM, the RCB plays in behind for the advanced RWB if their defenders are slow to shift, or into F1 to use the 2v2 up front.',
    'Opposing wing back steps up onto the RCM',
    'Exploit the space he leaves or the 2v2.',
    '3-4-3', 100, 100, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back', 'Pass behind or into the forward'),
    (2, 'Ball-side wing back', 'Runs behind'),
    (3, 'Front two', 'Attack 2v2')
) AS v(so, role, job);

-- 68. pp.100-100
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 3-4-3 - 6.2 Moving the ball between the lines', 'DM carries into midfield space when pressed',
    'With both wing backs high there is room in midfield; as the DM dribbles forward and the opposing CM steps up, he passes to the RCM directly or via the LCM.',
    'Opposing CM steps out onto the carrying DM',
    'Ball to the RCM between the lines.',
    '3-4-3', 100, 100, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'Carries forward to draw the CM'),
    (2, 'Right central midfielder', 'Receives between the lines'),
    (3, 'Left central midfielder', 'Relay option')
) AS v(so, role, job);

-- 69. pp.101-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch2 Tactics vs 3-4-3 - 6.3 Playing in behind the defensive line', 'CM between lines vs back three: four options',
    'Same as vs 3-5-2: as the RCM carries, the forwards unsettle the wide CBs and the LWB cuts between their CB and wing back; pass to the cutting LWB, to the LWB wide, dribble and commit 3v3, or play the RWB in behind depending on what the back three do.',
    'Central midfielder receives between the lines',
    'Ball behind the back three or a 3v3.',
    '3-4-3', 101, 101, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-carrying central midfielder', 'Reads the back three'),
    (2, 'Front two', 'Movements to create doubt'),
    (3, 'Left wing back', 'Cutting run or wide option'),
    (4, 'Right wing back', 'Run in behind')
) AS v(so, role, job);

-- 70. pp.102-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 3-4-3 - 6.4 Pressing and defensive organisation', 'Press 3-4-3: forwards isolate one wide CB',
    'The three midfielders start in a line; the two forwards shift slightly to one side and tightly mark two of the three centre backs, leaving one wide CB free on purpose. When he gets the ball, the near CM (LCM) presses him, the DM steps up onto one opposing CM, the RCM marks the other, the near wing back marks his direct opponent and the far wing back drops to make a back four with a 4v3.',
    'Ball reaches the isolated opposing wide CB',
    'Press the free man while keeping 4v3 behind.',
    '3-4-3', 102, 102, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two', 'Shift to one side and mark two centre backs'),
    (2, 'Ball-side central midfielder (LCM)', 'Steps out to press the free wide CB'),
    (3, 'Defensive midfielder', 'Steps up onto an opposing central midfielder'),
    (4, 'Far central midfielder (RCM)', 'Marks the other central midfielder'),
    (5, 'Far wing back', 'Drops into a back four')
) AS v(so, role, job);

-- 71. pp.103-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Ch2 Tactics vs 3-4-3 - 6.5 Organisation of the defensive line', 'Keep 4v3 against the front three',
    'The defensive line must hold a 4v3 against the three attackers at all times. If our LWB contests the ball, LCB marks their right winger, CB the striker, RCB slides centrally and RWB drops to make four. If the LCM contests their wing back, the LWB marks the winger, LCB the striker, CB stays central and RCB covers the far winger while the RWB holds his midfield spot.',
    'Ball on our left flank with the front three ready',
    'Never lose numerical superiority at the back.',
    '3-4-3', 103, 103, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left wing back', 'Contests the ball or marks the right winger'),
    (2, 'Left centre back', 'Marks the winger or the striker'),
    (3, 'Middle centre back', 'Marks the striker or stays central covering'),
    (4, 'Right centre back', 'Shifts in or covers the far winger'),
    (5, 'Right wing back', 'Drops to make a back four or stays in midfield')
) AS v(so, role, job);

-- 72. pp.105-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Ch3 Training Session 1: Build-up play from the back - 1. Warm-up', 'Back three circulate, then break the line',
    'Unopposed warm-up rehearsing three build-up moves from the back three plus DM: a wide CB carrying forward into space; a CB passing into the DM and running past him for the lay-off (third-man run); and a wide CB switching with a diagonal aerial pass. Receiving players play first time into the DM as a quick transition.',
    'Back three circulating the ball, max two touches',
    'Rehearse the carry, CB overlap off the DM lay-off, and the switch.',
    NULL, 105, 108, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back', 'Receives and dribbles forward, or switches diagonally in the air'),
    (2, 'Centre back', 'Passes into the DM then runs forward for the lay-off'),
    (3, 'Defensive midfielder', 'Lays off first time and acts as transition link')
) AS v(so, role, job);

-- 73. pp.109-110
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Training Session 1: Build-up Play from the Back', 'Back three overload beats a two-man press',
    'Our 3 centre backs, the GK and DM/central midfielders build against an aggressive front two plus midfield press, using the extra man to get past the first line. The shape in the drill is our 3-5 against their 4-2.',
    'Opponent presses the back line aggressively and collectively',
    'Move the ball through the first and second line and break into the opposition half before they can win it.',
    '4-4-2', 109, 110, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'starts with short pass to a centre back and acts as extra player'),
    (2, 'Free wide centre back', 'if not pressed, dribble forward into midfield to make 4v3 there'),
    (3, 'Wing backs', 'stay wide and must be involved to stretch the press'),
    (4, 'DM, LCM, RCM', 'show between pressers, receive and look forward'),
    (5, 'Front two', 'drop to receive or support CM forward run')
) AS v(so, role, job);

-- 74. pp.111-111
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Training Session 1: Build-up Play from the Back', 'Skip the press into the space behind midfield',
    'When the opponent pushes three forwards on to our back line, we use the numerical advantage at the back (5v3 with GK) to find a direct pass past their midfield line to a forward or forward-running central midfielder.',
    'Ultra-aggressive high press by 3 attackers, midfield line high',
    'Bypass the press and attack the back line 2v1 straight away.',
    NULL, 111, 111, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide centre back', 'play the direct pass past the midfield line to the forward'),
    (2, 'Forward', 'receive in behind their midfield, attack the remaining defender'),
    (3, 'Ball-far central midfielder', 'run forward to make 2v1 with the forward'),
    (4, 'Goalkeeper', 'circulate short to pull the pressers up')
) AS v(so, role, job);

-- 75. pp.113-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Training Session 2: Playing Through the Lines', 'Timed arrival into the receiving zone',
    'To get on the ball between or behind the lines, the receiver must run into the space as the pass is played rather than wait there, then receive and finish with few touches.',
    'Ball carrier has a forward passing lane past the defenders'' line',
    'The receiver gets there unmarked and onside, facing goal with momentum.',
    NULL, 113, 115, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (LCM or RCM)', 'time a forward run so you arrive just after the pass'),
    (2, 'Centre back or DM', 'build-up, look for the forward pass once the run starts'),
    (3, 'Wing backs', 'give width and a numerical advantage to help circulate'),
    (4, 'Receiver', 'two touches max: control forward and shoot')
) AS v(so, role, job);

-- 76. pp.116-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Training Session 2: Playing Through the Lines', 'CM drop-or-run decision in build-up',
    'When a centre back dribbles forward or a wing back gets the ball, the central midfielder on that side either drops off to show for a short pass or runs in behind the opposition midfield line; the wing back picks the near CM or the DM, and the DM plays forward or across to the other CM.',
    'Centre back dribbles out or ball arrives at a wing back',
    'Get a midfielder receiving behind the opposition midfield line, facing forward.',
    NULL, 116, 117, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near-side central midfielder (LCM)', 'drop to unmark for short pass, or run behind midfield line'),
    (2, 'Wing back (LWB)', 'pass forward to CM or inside to DM'),
    (3, 'Defensive midfielder (DM)', 'shift across to receive; play forward or switch to far CM'),
    (4, 'Far central midfielder (RCM)', 'if near CM drops, run in behind; receive open, facing forward'),
    (5, 'Centre backs', 'circulate and dribble forward to start it')
) AS v(so, role, job);

-- 77. pp.118-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Training Session 2: Playing Through the Lines', 'Central overload with DM and stepping CB',
    'Our DM and two CMs create an extra man centrally (3v2), helped by a centre back who dribbles into midfield to make 6v5 there, so a central midfielder can receive behind their midfield and slip a pass behind the defence.',
    'CM finds a pass between opposition midfielders after GK/CB build-up',
    'Through ball for forwards with 2 extra runners joining to make 4v3 in the final third.',
    NULL, 118, 119, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielder', 'free man in the centre, links to the CMs'),
    (2, 'Centre back (e.g. RCB)', 'dribble into midfield to add an extra man'),
    (3, 'Central midfielder', 'receive in the gap, play behind the defensive line'),
    (4, 'Front two', 'make runs behind the defence'),
    (5, 'Wing back and other CM', 'push forward to support the attack')
) AS v(so, role, job);

-- 78. pp.121-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Training Session 3: Switching Play', 'Switch wing back to wing back',
    'With the wing backs holding the width and everyone else central, the team circulates through the centre backs and DM to move the ball from one wide zone to the other.',
    'Ball is wide and the opponent has squeezed to that side',
    'Find the far wing back free before the opposition can shift across.',
    NULL, 121, 122, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing backs', 'hold the touchline width on both sides'),
    (2, 'Middle centre back', 'hub of the switch, change sides quickly'),
    (3, 'Defensive midfielder', 'second hub, play to the far side'),
    (4, 'Wide centre backs', 'support the circulation and shift the ball across'),
    (5, 'Front two and CMs', 'show centrally to draw in the opponent')
) AS v(so, role, job);

-- 79. pp.123-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Training Session 3: Switching Play', 'Attack fast on the far side',
    'After the switch, the wing back is joined in the wide area by a central midfielder or forward to make 2v1 or 3v2 out wide, and the team attacks quickly while the defence is still moving across.',
    'Ball arrives at the far wing back after a switch',
    'Score or cross before the opposition has reorganised.',
    NULL, 123, 125, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Far wing back', 'receive, attack the space at once'),
    (2, 'Near central midfielder', 'move wide to make 2v1 with the wing back'),
    (3, 'Near forward', 'make a run into the channel to make 3v2'),
    (4, 'Other forward', 'attack the box for the cross')
) AS v(so, role, job);

-- 80. pp.127-131
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Training Session 4: Playing In Behind The Defensive Line', 'Lay-off then first-time ball in behind',
    'After circulating, a midfielder passes into a forward who lays it back; the midfielder then plays a one-touch ball behind the defensive line as both forwards time their runs to stay onside.',
    'Sideways or backward pass/lay-off that sets the next pass up facing forward',
    'A forward receives behind the back line and scores; the others follow in for rebounds.',
    NULL, 127, 131, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards (F1, F2)', 'one shows and lays off; both time runs in behind, one receives, other follows'),
    (2, 'Central midfielder (RCM/LCM)', 'play the final pass first time, on the ground or in the air'),
    (3, 'Defensive midfielder', 'keep possession and feed the CMs'),
    (4, 'Far-side RCM, RWB, forward', 'push forward to support and attack rebounds'),
    (5, 'Receiver', 'first touch forward, not back to goal')
) AS v(so, role, job);

-- 81. pp.133-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Training Session 5: Combined Movements of the 2 Forwards', 'Dummy and spin by the forwards',
    'When a pass comes to the front two and a defender is tight (''man-on'' call), the first forward lets the ball run to his partner, drops back to drag his marker, and then turns and runs into the space created behind.',
    'Teammate calls ''man-on'' as the pass goes into the forwards',
    'Partner lays off or plays in the forward who spun away from his marker.',
    NULL, 133, 133, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forward F1', 'dummy the pass, drop to pull marker, spin in behind'),
    (2, 'Forward F2', 'receive the dummied ball, play it into F1''s run'),
    (3, 'Wing back / CM', 'pass into the forwards and call ''time'' or ''man-on''')
) AS v(so, role, job);

-- 82. pp.134-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'in_possession', 'Training Session 5: Combined Movements of the 2 Forwards', 'Forward drags marker, partner attacks space',
    'The forward nearest the ball makes a move away from the centre to take his centre back with him, the central midfielder plays a diagonal pass into the gap, and the other forward runs on to it behind the line.',
    'After build-up, a CM dribbles into midfield and the forwards face a back line',
    'Release one forward through on goal using the space opened by his partner.',
    NULL, 134, 136, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near-ball forward (F2)', 'move wide away from the centre to pull his marker'),
    (2, 'Far forward (F1)', 'attack the vacated central space behind the line'),
    (3, 'Central midfielder (LCM)', 'dribble forward, play the diagonal pass into the space'),
    (4, 'Back three and DM', 'build up with 4-6 passes to draw the opponent')
) AS v(so, role, job);

-- 83. pp.138-140
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'to_defend', 'Training Session 6: Transition From Attack To Defence', 'Immediate press on the new ball carrier',
    'The moment we lose the ball, the nearest players close the new carrier at once to stop his first pass or shot and win it back straight away.',
    'Loss of possession',
    'Win the ball back before the opponent completes a pass or escapes.',
    NULL, 138, 140, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players nearest the ball', 'sprint to close the carrier and block his passing/shooting lanes'),
    (2, 'Next ring of players', 'block the closest potential receivers'),
    (3, 'All players', 'react instantly, no switching off after losing it')
) AS v(so, role, job);

-- 84. pp.140-142
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'to_defend', 'Training Session 6: Transition From Attack To Defence', 'Counter-press with balance and no back pass',
    'While the players near the ball press, the rest stay compact, recover their positions and keep balance so the press cannot be played through; pressers also cut off the safe pass back to the opposition GK.',
    'Ball lost in our build-up zones or during an attack',
    'Win it back or keep the opponent from breaking through or resetting via their keeper.',
    NULL, 140, 142, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players near ball', 'press carrier and close/block receivers, including the back pass'),
    (2, 'Players away from ball', 'stay compact, recover the right positions and distances'),
    (3, 'Back three and DM', 'keep defensive balance behind the press'),
    (4, 'Wing backs', 'tuck in and recover quickly')
) AS v(so, role, job);

-- 85. pp.144-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Training Session 7: Aggressive Pressing', 'High aggressive press on opponent build-up',
    'From the 3-5-2 the team presses high when the opponent builds from the GK, putting continuous pressure on the ball carrier and the possible receivers rather than just blocking the route to goal. The opponent can be in any shape (4-4-2, 4-2-3-1, 3-5-2, 3-4-3).',
    'Opponent GK plays short to a defender (or a fresh ball after we lose it)',
    'Win the ball high and counter attack or score at once; stay alert to balls played long behind.',
    NULL, 144, 147, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two', 'press the centre backs, cut passing lanes'),
    (2, 'Central midfielders', 'step up on to the opposing midfielders and receivers'),
    (3, 'Wing backs', 'push on to the opposing full backs or wide players'),
    (4, 'Back three', 'step up but cover the space behind against long balls'),
    (5, 'Whole team', 'press the carrier and receivers non-stop, counter quickly on a regain')
) AS v(so, role, job);

-- 86. pp.149-149
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Training Session 8: Organisation Of The Defensive Line', 'Nearest CB steps out to intercept',
    'When the opponent plays a forward ground pass into a player in front of our back three, the closest centre back reads it, steps out in front and wins the ball, then plays it into the DM.',
    'Forward ground pass towards a receiver just in front of the back line',
    'Intercept before the receiver can turn.',
    NULL, 149, 149, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest centre back (LCB)', 'anticipate, step out and intercept'),
    (2, 'Other centre backs', 'shift across to cover behind'),
    (3, 'Defensive midfielder', 'offer the outlet pass after the regain')
) AS v(so, role, job);

-- 87. pp.150-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Training Session 8: Organisation Of The Defensive Line', 'Attack the aerial ball, others cover',
    'On a lofted pass towards the back three, the centre back nearest the ball attacks it and heads or plays it forward while the other two slide across for cover and compactness.',
    'Aerial pass into the zone of a centre back',
    'Win the first ball with cover in place if it is missed.',
    NULL, 150, 150, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest centre back (LCB)', 'attack the aerial ball and play forward to DM'),
    (2, 'Middle and far centre backs', 'shift across behind, provide cover and balance'),
    (3, 'Defensive midfielder', 'drop to collect the second ball/pass')
) AS v(so, role, job);

-- 88. pp.151-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Training Session 8: Organisation Of The Defensive Line', 'Open ball: drop off, push up on back pass',
    'When an opponent has time on the ball and dribbles forward unpressed (''open ball''), the back three drop together in a line with the DM shifting across; as soon as the ball goes backwards they step up together to stay close to midfield.',
    'Carrier unpressured going forward = drop; pass played backwards = push up',
    'Protect the space behind without leaving gaps, then compress the pitch to allow pressing.',
    NULL, 151, 151, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back three', 'drop back together in a straight line, then push up together'),
    (2, 'Defensive midfielder', 'shift to the ball side to screen'),
    (3, 'Whole defence', 'move as one unit, keep the line')
) AS v(so, role, job);

-- 89. pp.152-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Training Session 8: Organisation Of The Defensive Line', 'Retreat and cover deep ball behind',
    'Against a long aerial pass behind the line, the centre backs turn and retreat quickly; the one in the best position (here the middle CB) attacks the ball and the two wide centre backs drop back to cover and balance.',
    'Opponent plays a long ball over the defensive line',
    'Win the ball behind the line with cover against a miss.',
    NULL, 152, 152, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Middle centre back (CB)', 'retreat, attack the aerial ball, pass to DM'),
    (2, 'Wide centre backs (LCB, RCB)', 'drop back to cover and balance'),
    (3, 'Defensive midfielder', 'receive the clearance/pass')
) AS v(so, role, job);

-- 90. pp.153-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'out_of_possession', 'Training Session 8: Organisation Of The Defensive Line', 'Ball wide: wing back contests, back line slides',
    'When the opponent plays wide (here a 4-4-2), the wing back on that side goes out to contest the ball, the centre backs shift across to stay compact and pick up the two forwards, and the far wing back drops into the back line.',
    'Opponent passes the ball out to the wing',
    'Close the wide player while keeping the centre covered against the front two.',
    '4-4-2', 153, 154, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side wing back (LWB)', 'press the wide receiver'),
    (2, 'Three centre backs', 'shift across, compact, mark the 2 forwards'),
    (3, 'Far-side wing back (RWB)', 'drop back to make a back four'),
    (4, 'Defensive midfielder', 'screen in front of the line')
) AS v(so, role, job);

-- 91. pp.154-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'coaching-3-5-2-tactics-125-tactical-solutions-and-practices'), 'to_attack', 'Training Session 8: Organisation Of The Defensive Line', 'Interception by CB into fast counter',
    'A centre back steps out of the line to intercept, passes to the DM, who plays wide at once for the advanced run of the far wing back to attack before the opponent recovers.',
    'Centre back wins the ball by stepping in front of the line',
    'Score quickly (within about 8 seconds) through the open wide space.',
    NULL, 154, 154, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (LCB)', 'step forward, intercept, pass to DM'),
    (2, 'Defensive midfielder', 'play wide into the wing back''s run first time'),
    (3, 'Far wing back (RWB)', 'make an advanced run and finish the counter')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1963-coaching-book-352-tactics-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
