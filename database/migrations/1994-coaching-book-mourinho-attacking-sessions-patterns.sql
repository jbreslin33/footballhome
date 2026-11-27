-- 1994 📚 Coaching book patterns: "Jose Mourinho Attacking Sessions" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Jose Mourinho Attacking Sessions',
    subtitle    = '114 Practices from Goal Analysis of Real Madrid''s 4-2-3-1',
    author      = 'Michail Tsokaktsidis',
    team        = 'Real Madrid',
    season      = '2011-12',
    method_note = 'Goal analysis of Mourinho''s 2011-12 Real Madrid (121 league goals, 100 points) in their 4-2-3-1, each goal type turned into a progressive session. Chapters are split by the opponent''s defensive height (deep, middle, high line) and by the zone where the ball is won (low, middle, high), plus building up from the back: filling the box, advanced full backs, switches, dribble-in-and-release, diagonal runs between full back and centre back, timed runs, wide 1v1s, long switches against a compact block, breaking a high line, low-zone counters, pressing as a unit then attacking within 4-6 seconds, and the press after losing it. Patterns are the match behaviours, in our words.'
WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid');

-- 1. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Attacking against Opponents who use a Deep Defensive Line (intro)', 'Full backs high, four in box, two screening',
    'Opponent packs the area around its own box with numbers. Both full backs push high on the flanks so at least four players can attack the box, while the two holding midfielders stay just outside the area.',
    'Opponent drops deep and squeezes the area around its box',
    'Overload the box for crosses while keeping balance to win second balls and stop counters early.',
    NULL, 17, 17, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (Arbeloa, Marcelo)', 'Push up high and wide to supply width and crosses'),
    (2, 'Front four (wide forwards, 10, striker)', 'At least four arrive in the box'),
    (3, 'Holding midfielders (Khedira, Alonso)', 'Sit at the edge of the box for rebounds and act as first defender if the ball is lost')
) AS v(so, role, job);

-- 2. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Attacking against Opponents who use a Deep Defensive Line (intro)', 'Quick switch against ball-oriented block',
    'Against a well-organised deep block that shifts hard to the ball, keep possession and move the ball quickly from the crowded strong side to the weak side using full pitch width.',
    'Opponent block slides fully to the ball side',
    'Change the point of attack before the block can reshift and attack the weak side.',
    NULL, 17, 17, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Weak-side wide players', 'Hold maximum width to receive the switch'),
    (2, 'Holding midfielders / centre backs', 'Recycle quickly and efficiently across the pitch'),
    (3, 'Ball-side players', 'Draw the block in before releasing the ball')
) AS v(so, role, job);

-- 3. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Attacking against Opponents who use a Deep Defensive Line (intro)', 'Flank 2v1 with diagonal cut',
    'When the opponent crowds the centre and leaves its full backs exposed, Madrid build a 2v1 on the wing; after the pass goes wide, a midfielder or forward from the centre runs diagonally into the gap between the full back and centre back.',
    'Pass played out to the flank while the opponent''s centre is packed',
    'Get a runner in behind the full back in the channel next to the centre back.',
    NULL, 17, 17, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forward + full back', 'Form the 2v1 against the opposing full back'),
    (2, 'Central midfielder or forward', 'Diagonal cutting run into the full back / centre back gap')
) AS v(so, role, job);

-- 4. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Attacking against Opponents who use a Deep Defensive Line (intro)', 'Dribble at slow passive centre backs',
    'When attacking through the middle and the opponent does not press the man on the ball, skilful players carry the ball straight at the central defenders.',
    'Ball carrier unpressed centrally, opponent centre backs slower',
    'Commit defenders, then play the final ball or beat the line on the dribble.',
    NULL, 17, 17, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder / forwards', 'Run at the centre backs with the ball'),
    (2, 'Striker and wide forwards', 'Offer runs in behind for the final pass')
) AS v(so, role, job);

-- 5. pp.18-26
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Goal Analysis: One-Two Combination and Quick Final Ball', 'Inside-cut one-two then ball in behind',
    'A wide player cuts inside and plays a one-two with the striker; when a defender steps out to close him, a forward times a run into the space behind the line and gets a quick through ball to finish first time (Mallorca 1-2, Ozil-Benzema-Higuain). Variants: full back plays the one-two with the wide forward and drives inside; double one-two via a central midfielder; striker can instead cross while the far wide forward and central midfielders arrive.',
    'Defender leaves the line to close down the player coming inside',
    'Unbalance a deep, passive block with a fast combination and release a runner in behind onside.',
    NULL, 18, 26, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide attacking player (Ozil) / full back', 'Carry inside, play the one-two, then thread the final pass'),
    (2, 'Striker (Benzema) / wide forward', 'Short sharp movement inside to give the wall pass'),
    (3, 'Second forward (Higuain) / far wide forward', 'Run horizontally then curve diagonally behind the line to stay onside'),
    (4, 'Central midfielders', 'Support close behind and arrive at the edge of the box')
) AS v(so, role, job);

-- 6. pp.27-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Goal Analysis: One Touch Combination Play with a 3rd Man Run', 'Lay-off, carry inside, third-man run',
    'A vertical pass into a forward who is marked from behind is laid back; the receiver dribbles inside to pull the defensive shape while the attacking midfielder makes an opposite diagonal run; a teammate then plays first time into the runner''s path (Zaragoza 3-1, Alonso-Ronaldo-Granero-Kaka-Ozil).',
    'Forward receives with a defender tight behind him',
    'Play through a deep block with one-touch combinations and a third man arriving unmarked behind the line.',
    NULL, 27, 35, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Alonso) / centre back', 'Plays the vertical pass into the forward'),
    (2, 'Forward under pressure (Ronaldo) / striker', 'Cushioned one-touch lay-off back'),
    (3, 'Supporting midfielder (Granero)', 'Carries the ball inside to disrupt the shape, then passes'),
    (4, 'Second link (Kaka)', 'First-time pass into space behind'),
    (5, 'Third man (Ozil)', 'Starts the opposite diagonal run while the ball is still travelling')
) AS v(so, role, job);

-- 7. pp.36-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Goal Analysis: 3rd Man Overlapping Run & Final Ball Behind Defensive Line', 'Midfielder''s overlap around the forward',
    'Full back dribbles inside and finds a central midfielder in front of the box, where it is 5v5 with a spare wide man on each side; the midfielder passes into a forward and immediately overlaps round him, and after a one-touch lay-off the attacking midfielder plays him in behind (Espanyol 5-0, Arbeloa-Khedira-Ronaldo-Ozil-Khedira). Variant: the wide forward dribbles inside to open room for the overlap.',
    'Midfielder releases the pass into the forward',
    'Break a crowded 5v5 in front of the box with a late overlapping runner from midfield.',
    NULL, 36, 44, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Arbeloa)', 'Dribble inside and pass into the central midfielder'),
    (2, 'Central midfielder (Khedira)', 'Pass to the forward then overlap round his back straight away'),
    (3, 'Forward (Ronaldo) / wide forward', 'Receive, dribble inside or lay off first time'),
    (4, 'Attacking midfielder (Ozil) / striker', 'One-touch final ball into the overlapping run'),
    (5, 'Far wide players', 'Stay wide as spare support men on each side')
) AS v(so, role, job);

-- 8. pp.45-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Goal Analysis: 1v1 on the Flank with Runs from the Centre into the Box', 'Switch to isolate the winger 1v1',
    'When many players crowd the centre, the ball is switched long to a wide forward; teammates deliberately keep away so he is left 1v1 against the full back, then he beats him and crosses (Malaga 0-4 Kaka to Di Maria; Ronaldo vs Malaga and Osasuna).',
    'Centre congested, wide forward alone with the full back',
    'Exploit the best dribblers in clean 1v1s on the flank.',
    NULL, 45, 54, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Playmaker (Kaka) / striker / 10', 'Long pass changing direction to the free wide forward'),
    (2, 'Wide forward (Di Maria, Ronaldo)', 'Take on the full back, cut in or go outside, cross'),
    (3, 'Nearby teammates', 'Leave the flank empty so the 1v1 stays isolated')
) AS v(so, role, job);

-- 9. pp.45-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Goal Analysis: 1v1 on the Flank with Runs from the Centre into the Box', 'Box attack runs on the cross',
    'As the wide forward beats his man, the central players sprint into the box facing goal: one to the near post, one to the far post and the opposite wide forward arriving as a third, with a midfielder arriving behind, making 2v2 or 3v3 in the area; cross aimed behind the defensive line.',
    'Wide forward wins his 1v1 and gets set to cross',
    'Attack the cross with timed runs so a runner gets ahead of the defenders and finishes first time.',
    NULL, 45, 54, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Benzema/Higuain)', 'Near-post or far-post run, decided by communication'),
    (2, 'Attacking midfielder (Ozil/Kaka)', 'Takes the other post'),
    (3, 'Opposite wide forward (Di Maria/Ronaldo)', 'Arrives late from the far side as the third runner'),
    (4, 'Central midfielder', 'Arrives behind the runners at the edge of the box'),
    (5, 'Losing side players', 'React immediately to defend if the ball is lost in the wide zone')
) AS v(so, role, job);

-- 10. pp.55-56
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch1 Deep line - Intelligent Positioning in the Box with Quick Finishing', 'Staggered box occupation plus edge support',
    'When a wide player beats his man and crosses against a packed box, attackers fill three distinct spots (near post, behind him, far post) rather than all crowding in, while two players hold the edge of the area.',
    'Wide player gets past his full back and is about to cross',
    'Give the cross a target at every depth and have edge players ready to shoot first time from cleared second balls.',
    NULL, 55, 56, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Ronaldo/Benzema)', 'Attack the near post'),
    (2, 'Second forward', 'Arrive just behind the near-post runner'),
    (3, 'Far-side winger (Di Maria)', 'Late run to the far post'),
    (4, 'Central midfielder (Alonso)', 'Hold edge of box, strike first time on cleared ball'),
    (5, 'Second midfielder', 'Stay outside box as first line against a transition')
) AS v(so, role, job);

-- 11. pp.56-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_defend', 'Ch1 Deep line - Intelligent Positioning in the Box (Transition practices)', 'Immediate counter-press after final-third loss',
    'Attacking in the final third, two players are kept back in their own half for second balls; if possession is lost near the box the nearest players close the carrier straight away.',
    'Ball lost or cleared in the attacking third',
    'Stop the opponent turning or playing forward and win the ball back high for another shot.',
    NULL, 56, 58, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest attackers', 'Close down the ball carrier at once, block turn and forward pass'),
    (2, 'Two central midfielders', 'Sit behind the attack to win second balls and shoot from distance'),
    (3, 'Rest defenders', 'Stay in own half as cover for the transition')
) AS v(so, role, job);

-- 12. pp.59-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch1 Deep line - Full Back''s in Advanced Positions: Crossing and Finishing', 'Advanced full backs cross from both flanks',
    'Against an opponent with many bodies in the box, both full backs push high and wide; a cross from one side that clears the crowd is picked up by the opposite full back who crosses back to the far post.',
    'Opponent drops deep with numbers in the box',
    'Use full width for repeat crosses and finish at the back post with four attackers in the box.',
    NULL, 59, 61, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back (Arbeloa)', 'Advance and deliver the first cross'),
    (2, 'Left back (Marcelo)', 'Stay high and wide on far side, recycle cross to back post'),
    (3, 'Front four (Benzema, Higuain, Khedira, Ronaldo)', 'Spread in box at good distances, attack back post'),
    (4, 'Attacking midfielder (Ozil)', 'Wait at edge for knock-downs')
) AS v(so, role, job);

-- 13. pp.62-69
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch1 Deep line - Switching Play to Change the Point of Attack', 'Switch to weak side vs ball-oriented block',
    'An organised, ball-oriented defence crowds the centre and ball side; the team circulates quickly from one flank through the middle and out to the far side where a full back surges forward into free space by the touchline.',
    'Opponent shifted and compact around the ball, space free near far sideline',
    'Get the ball wide on the weak side for an early cross with four arriving in the box.',
    NULL, 62, 69, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-side attacking mid (Ozil)', 'Start circulation from the strong side'),
    (2, 'Left back (Marcelo)', 'One-touch inside to keep the switch fast, then arrive late at edge'),
    (3, 'Forward (Ronaldo)', 'Play wide pass out to weak-side full back'),
    (4, 'Weak-side full back (Ramos)', 'Surging run on the flank, cross into box'),
    (5, 'Box attackers', 'Near post, behind, far post plus late runner')
) AS v(so, role, job);

-- 14. pp.64-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch1 Deep line - Switching Play to Change the Point of Attack (2)-(4)', 'Dribble inside, release free wide man',
    'A wide player or midfielder dribbles inside at a packed central defence to pull defenders onto him; when they close him he slips the ball to the teammate left free on the flank, who plays a low cross behind the line where defenders face their own goal. A lofted pass over the midfield line to a forward who lays off inside can start the same move.',
    'Defenders step towards the dribbler, opening the flank',
    'Unbalance the block and deliver a low cross behind the back line for one-touch finishes.',
    NULL, 64, 70, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dribbling wide player (Ramos/Callejon)', 'Carry inside to draw defenders'),
    (2, 'Free wide player (Kaka/Benzema/Ozil)', 'Run the opposite way into the flank space, low first-time cross'),
    (3, 'Central midfielder (Alonso/Granero)', 'Beat direct opponent, pass to free man at right moment'),
    (4, 'Box runners (Ronaldo, Higuain)', 'Attack near post and gap behind line'),
    (5, 'Two supporting players', 'Hold position outside the box')
) AS v(so, role, job);

-- 15. pp.71-75
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch1 Deep line - Timed Runs in Between the Full Back and Centre Back', 'Diagonal run into full back/centre back gap',
    'With the opponent''s back four deep, the ball is moved to the wide attacking mid; a second player (overlapping full back or midfielder) makes a diagonal or horizontal-then-vertical cutting run between the left back and centre back to make 2v1 on the flank.',
    'Ball reaches wide attacker in front of a deep back four',
    'Get a runner behind the back line in the channel and cross for runners to head home.',
    NULL, 71, 75, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide attacking mid (Ozil/Benzema)', 'Receive wide, pass into channel at the moment of the run'),
    (2, 'Third-man runner (Arbeloa/Kaka)', 'Diagonal cut between full back and centre back, then cross'),
    (3, 'Box forwards (Ronaldo, Benzema, Higuain)', 'Make separate runs into the area, back post header'),
    (4, 'Deep midfielder (Alonso)', 'Switch to the wide man to bypass the opponent midfield')
) AS v(so, role, job);

-- 16. pp.76-80
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch1 Deep line - Attacking in Behind the Defensive Line Through the Centre', 'Run between centre backs, lofted ball over',
    'Facing a well-organised deep block, a forward reads the situation and runs between the two centre backs while the playmaker lifts a pass behind the line.',
    'Midfielder in possession facing a set defence with space behind',
    'Bypass all eight defending players with one well-timed pass and finish one-on-one with the keeper.',
    NULL, 76, 80, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Playmaker (Di Maria)', 'Lofted pass behind the defensive line on the run'),
    (2, 'Forward (Callejon)', 'Move forward and split the two centre backs'),
    (3, 'Midfielders/neutrals', 'Combine quickly (one-twos, third-man) to free the passer'),
    (4, 'Other attackers', 'Opposite runs to create space for the receiver')
) AS v(so, role, job);

-- 17. pp.81-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch1 Deep line - Timing Runs in Behind to be Onside', 'Exploit central overload, onside-timed run',
    'Spotting a numerical advantage in the centre, the winger feeds the attacking mid, who drives at the poorly positioned full back and releases the striker whose run is timed to stay onside.',
    'Central overload and a full back out of position',
    'Put the striker through on goal without being caught offside.',
    NULL, 81, 85, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Di Maria)', 'Recognise overload, pass inside'),
    (2, 'Attacking mid (Ozil)', 'Dribble forward at the weak full back, pass at the right moment'),
    (3, 'Striker (Benzema)', 'Hold the line then run in behind, first touch to goal and finish'),
    (4, 'Other attackers', 'Coordinate runs into different spaces to stretch the line')
) AS v(so, role, job);

-- 18. pp.87-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch2 Middle line - Creating Space for 1v1 Situations on the Flank', 'Isolate wide forward 1v1 on full back',
    'Against a middle line crowded in the centre, the full backs take the wide spots and the wide forwards start inside; when the opponent''s wide midfielder pushes onto the full back, the wide forward checks away and curls a run down the line to receive behind and face the full back alone.',
    'Full back receives and his marker steps up to close him',
    'Use the forward''s pace to beat the slow full back, dribble into the box and low-cross to runners.',
    NULL, 87, 94, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Ramos)', 'Start the attack with a pass to the full back'),
    (2, 'Full back (Marcelo)', 'Pass down the line past the pressing midfielder'),
    (3, 'Wide forward (Ronaldo)', 'Check away, curved run behind, beat full back, low cross'),
    (4, 'Striker (Higuain)', 'Attack the box for one-touch finish'),
    (5, 'Far winger (Di Maria)', 'Arrive at the back post')
) AS v(so, role, job);

-- 19. pp.89-94
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch2 Middle line - Creating Space for 1v1 Situations on the Flank (2)-(3)', '2v2 flank combination breaks the press',
    'When the full back is pressed in a 2v2 on the side, the wide forward or attacking mid offers support (behind the midfield line or for a one-two) so the full back can bypass the pressers and the ball goes into space behind the opponent full back.',
    'Full back closed down on the flank',
    'Eliminate the pressing midfield line and set up a 1v1 or run behind the full back.',
    NULL, 89, 94, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Marcelo)', 'Quick one-two or first-time pass past the press'),
    (2, 'Wide forward (Ronaldo)', 'Short support then sprint into the space behind'),
    (3, 'Attacking mid (Ozil/Kaka)', 'Show behind the midfield line, drive at centre back'),
    (4, 'Striker (Higuain)', 'Diagonal run into gap left when centre back steps out')
) AS v(so, role, job);

-- 20. pp.95-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch2 Middle line - Midfield Forward Runs in Behind the Defence', 'Attacking mid diagonal run from deep',
    'With width stretching an organised middle block, a midfielder or striker breaks from deep on a diagonal between centre back and full back, often into space a defender vacated by following a teammate''s support movement.',
    'Wide player has the ball and a defender is drawn out by a support run',
    'Get an unmarked runner behind the line onto a pass from the flank for a 1v1 or shot.',
    NULL, 95, 101, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking mid (Kaka)', 'Support the wide player, then diagonal run between CB and RB'),
    (2, 'Decoy (Ozil)', 'Show short to pull the full back out'),
    (3, 'Wide passer (Marcelo/Arbeloa)', 'Play into space behind the line (lofted if needed)'),
    (4, 'Striker (Higuain)', 'Alert to the freed space, diagonal run and first-time finish'),
    (5, 'Other attackers', 'Stay away to leave space for the runner')
) AS v(so, role, job);

-- 21. pp.102-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch2 Middle line - Through Balls from the Flank into the Centre & in Behind', 'Flank player threads ball between centre backs',
    'A wide player or defender facing a compact block (lines close, many players near the ball) dribbles inside or receives wide and plays a diagonal through ball between the centre backs or between full back and centre back for a forward running behind.',
    'Forward starts a run behind a centre back while wide player faces the defence',
    'Take most of the opposition out of the game with one diagonal pass and score.',
    NULL, 102, 107, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player (Marcelo/Di Maria/Carvalho)', 'Carry inside, see the run, diagonal pass in behind'),
    (2, 'Striker (Higuain)', 'Run between or behind the centre backs, good first touch'),
    (3, 'Attacking mid (Kaka)', 'Alternative runner into the FB/CB gap'),
    (4, 'Inside players', 'Make opposite runs to open space')
) AS v(so, role, job);

-- 22. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch2 Middle line - Long Switch of Play to Create Space for a Final Ball', 'Combine short, long switch, isolate far side',
    'Against a compact ball-oriented 5-4-1 with closed lines in front of the box, a short combination on one side draws the block before a long pass switches to the far full back, now 1v1 with the right back and the centre back too far to help.',
    'Block compressed to the ball side after a one-two',
    'Exploit the large gap between wing back and centre back with a dribble inside and a timed diagonal run.',
    '5-4-1', 108, 108, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking mid (Ozil)', 'One-two with Ronaldo then long switch to the left'),
    (2, 'Far full back (Coentrao)', 'Receive 1v1, dribble inside into the gap'),
    (3, 'Striker (Higuain)', 'Diagonal run into the space, timed with the pass'),
    (4, 'Forward (Ronaldo)', 'Short combination to draw the block')
) AS v(so, role, job);

-- 23. pp.109-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Long Switch of Play to Create Space for a Final Ball (Chapter 2, middle defensive line)', 'Switch wide to full back, then final ball behind',
    'Against a mid block (drill opponent is a back-three 5-4-1), the team keeps the ball centrally then switches it to an advanced full back isolated 1v1 on the flank.',
    'Full back receives wide in space after the switch',
    'Full back either slides a pass into the space behind the back three for supporting runners or dribbles inside to unbalance the line and plays a short pass in behind.',
    NULL, 109, 109, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs / holding midfielders', 'circulate and switch play to the far full back'),
    (2, 'Full back (2/3)', 'receive wide 1v1, pass in behind or dribble inside'),
    (3, 'Wide forwards (7/11) and striker', 'make supporting runs into space behind the back three'),
    (4, 'Attacking midfielder (10)', 'offer the short pass behind after the full back cuts in')
) AS v(so, role, job);

-- 24. pp.111-113
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Playing the Ball in Behind a High Defensive Line (Chapter 3)', 'Direct pass behind high back four',
    'Opponent defends with a compact, high line (often when chasing a game or a man down), leaving big space behind; a deep player on the ball faces most of the opponents.',
    'Deep player has time on the ball and a forward starts a run off the back of the line',
    'One pass into the lateral gap between full back and centre back takes out nearly the whole team; fast forwards finish while teammates sprint up in support.',
    NULL, 111, 113, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Ramos)', 'play the one long/diagonal pass over or through the line'),
    (2, 'Striker (Higuain)', 'leave his marker and make a diagonal run behind between full back and centre back'),
    (3, 'Far-side forward (Ronaldo)', 'attack the penalty area for the square/parallel pass'),
    (4, 'Attacking midfielder (Ozil)', 'carry inside then thread the ball for the diagonal run')
) AS v(so, role, job);

-- 25. pp.111-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Playing the Ball in Behind a High Defensive Line - session (Chapter 3)', 'Keep it under pressure, then go behind',
    'Facing high pressure with fewer players, the team first secures possession in its own third with short accurate passes to feet and 1-2 combinations, then looks for the player highest up the pitch.',
    'Pressure broken / a forward is free on the shoulder of the high line',
    'After a short spell of safe passes the ball goes into space behind the high line and support arrives fast to finish.',
    NULL, 111, 119, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defenders in low zone', 'pass accurately to feet, check away to get free'),
    (2, 'Central midfielders', 'open body on the half turn, offer one-touch wall passes'),
    (3, 'Wide players', 'check away from markers, shield the ball 1v1, receive with little space'),
    (4, 'Forward line', 'time runs into the zone behind the line'),
    (5, 'Supporting players', 'sprint forward to join the attack after the pass in behind')
) AS v(so, role, job);

-- 26. pp.114-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Building Up Play / Breaking Through Pressure (Chapter 3)', 'Beat the press by changing direction',
    'Under an intense press in one area, the team keeps the ball with numbers and quick support, drawing the opponent to that side.',
    'Opponent commits to the ball side (after 5-8 passes)',
    'Switch the play to the far side where width gives more space, and the whole block shifts across to support there.',
    NULL, 114, 122, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs', 'stay as the back outlet and recycle play'),
    (2, 'Full backs / wide forwards', 'hold the touchline width so the switch has a target'),
    (3, 'Central midfielders', 'move freely inside to give angles and support'),
    (4, 'Whole unit', 'move across together to the new side after the switch')
) AS v(so, role, job);

-- 27. pp.117-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_defend', 'Building Up Play - coaching points (Chapter 3)', 'Instant pressure if build-up ball lost',
    'When building out against a high press, a lost ball near your goal is very dangerous (opponent gets a few passes to score).',
    'Possession lost during build-up',
    'Players react at once to the transition, press the ball carrier in a coordinated way and get bodies back behind the ball.',
    NULL, 117, 122, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players', 'press the ball carrier immediately'),
    (2, 'Rest of team', 'recover behind the ball and make the opponent''s switch hard')
) AS v(so, role, job);

-- 28. pp.117-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Building Up Play Through the Lines (Chapter 3)', 'Vertical pass, lay-off, play forward again',
    'Playing out from the goalkeeper against a high press, the team works the ball forward line by line: defender to midfielder, back to the supporting defender, then into the forward line and back to a facing midfielder.',
    'A line-breaking vertical pass is on',
    'Vertical passes take several pressers out at once and let the team advance quickly with support underneath the ball.',
    NULL, 117, 123, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper and back four', 'start play and be the supporting option after each lay-off'),
    (2, 'Holding midfielders (6/8)', 'receive between lines, return or turn, then find the front four'),
    (3, 'Front four (AM, wide forwards, striker)', 'check away then show for the vertical pass and set it back'),
    (4, 'Ball carrier', 'decide quickly between holding, a first-time pass or dribbling forward')
) AS v(so, role, job);

-- 29. pp.120-120
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Building Up Play against Opponents who Press High - goal analysis (Chapter 3)', 'Direct ball to striker, wide runner behind',
    'Opponent presses high and is short at the back (2v4 for Real in the final third), and their full back has been pulled too far inside.',
    'Deep midfielder sees a direct pass to a forward past the press',
    'Forward lays off to a supporting teammate who plays first time into the space the full back vacated for the quick wide man to run at goal.',
    NULL, 120, 120, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep midfielder (Alonso)', 'play the direct pass that skips six pressers'),
    (2, 'Forward (Ronaldo)', 'receive and set the ball back'),
    (3, 'Striker (Benzema)', 'support close and play first time into the flank space'),
    (4, 'Wide forward (Di Maria)', 'sprint into space behind the out-of-position full back and drive into the box')
) AS v(so, role, job);

-- 30. pp.124-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Breaking Through Pressure High Up the Pitch (Chapter 3)', '1-2 to step a player into midfield',
    'Pinned in their own third by a high press while two attackers wait against defenders further up, the team needs to move numbers forward.',
    'A teammate in the middle zone is available for a wall pass',
    'A 1-2 with the middle-zone player releases a low-zone player forward, creating 4v3 (or 5v3) to attack and score.',
    NULL, 124, 125, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Low-zone midfielder / defender', 'play the 1-2 and run forward into the next zone'),
    (2, 'Middle-zone attackers', 'give the wall pass and then attack the outnumbered defenders'),
    (3, 'Wide forward', 'provide the width for the overload')
) AS v(so, role, job);

-- 31. pp.128-133
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Transition from Defence to Attack in the Low Zone - overview (Chapter 4)', 'Deep block, fast break into 1v1/2v2',
    'Real often sit with many players in the low zone and only one or two near halfway, inviting an opponent with weak, slow transitions.',
    'Ball won deep with the opponent committed forward',
    'Quick forward passes into space let the faster forwards attack in 1v1 or 2v2 and finish within about 9-12 seconds.',
    NULL, 128, 133, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (Alonso)', 'pass forward at once to the playmaker'),
    (2, 'Attacking midfielder (Kaka)', 'dribble at pace to beat his man 1v1 in the centre'),
    (3, 'Forward (Ronaldo)', 'read it and make a diagonal run across to the free side behind the centre back'),
    (4, 'Striker (Higuain)', 'support from the other side behind the defender for the final pass'),
    (5, 'Practice detail: 10', 'check away before receiving, beat a defender with a turn or feint')
) AS v(so, role, job);

-- 32. pp.128-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Exploiting the Weak Side of the Opposition (Chapter 4)', 'Break to the opponent''s weak side',
    'After winning the ball, Real attack with about four players, move the ball to one side and exploit the far (weak) side where the opponent has few players (breaks of 7-9 seconds).',
    'Ball won, opponent''s block shifted to one side',
    'Forwards make runs on the weak side and the ball is played in behind the last defenders or hit hard to the free flank for a back-post finish.',
    NULL, 128, 144, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (Ramos) / playmaker (Ozil)', 'one-touch forward pass to start the break'),
    (2, 'Wide forward (Di Maria)', 'receive on the ball side and feed the sprinting forward'),
    (3, 'Forward on ball (Ronaldo)', 'carry at speed, see the weak-side run and pass behind the last two defenders'),
    (4, 'Weak-side striker (Benzema/Ozil)', 'run beyond the line on the far side, finish first time'),
    (5, 'Deep midfielder (Alonso)', 'spot free space on the far flank and hit a hard pass there'),
    (6, 'Team (practice)', 'flood forward with many runners using full width; finish in 8-10 s')
) AS v(so, role, job);

-- 33. pp.129-155
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Creating and Exploiting Space on the Flanks (Chapter 4)', 'Wide forward sprints into flank space',
    'Opponent has lots of players in the centre when the ball is won, leaving the flanks open (attacks of about 10 seconds).',
    'Regain in own half, playmaker on the ball facing forward',
    'The ball goes quickly to a central carrier who drives forward while a wide forward sprints up the flank, receives in stride and drives into the box; or the ball goes inside and is slipped behind into space on the opposite flank.',
    NULL, 129, 155, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (Khedira)', 'quick pass to the central playmaker'),
    (2, 'Central carrier (Ozil/Kaka)', 'dribble forward, then release the wide runner'),
    (3, 'Wide forward (Ronaldo / Di Maria)', 'sprint up the flank asking for the ball in space, go at goal'),
    (4, 'Full back (Marcelo)', 'receive wide and pass back inside to the striker'),
    (5, 'Striker (Benzema)', 'pass in behind before the opponent recovers'),
    (6, 'Practice rule', 'ball into middle zone within 4 s, 4v3/4v4 finished in 10-12 s')
) AS v(so, role, job);

-- 34. pp.129-159
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Breaking from the Low Zone: Causing Imbalance in a Defensive Line with a Delayed Pass (Chapter 4)', 'Carry to the line, delayed pass',
    'Opponent loses the ball in Real''s low zone with 4-5 players behind the ball but few quick ones recovering, so Real break into a 4v4 or 5v5.',
    'Ball stolen in the low zone, defence retreating',
    'Carriers dribble right up to the defensive line to pull defenders out of position while others make opposite diagonal runs, then a late pass releases the free wide man for a low cross between the last defenders and the keeper.',
    NULL, 129, 159, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back (Marcelo)', 'steal the ball, pass and overlap to make a 2v1'),
    (2, 'Wide forward (Ronaldo)', 'drive inside to push the line back, then attack the box for the finish'),
    (3, 'Striker (Benzema)', 'carry up to the line to fix a centre back, then pass to the free flank'),
    (4, 'Attacking midfielder (Ozil)', 'make an opposite diagonal run at the back of the line to unbalance it'),
    (5, 'Far wide forward (Di Maria)', 'receive in space on the flank and cross low'),
    (6, 'Practice detail', 'pass to a teammate dropping from the high zone, 1-2, then 5v5 (+1)')
) AS v(so, role, job);

-- 35. pp.134-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Quick Counter Attacking from the Low Zone (Chapter 4)', 'Forward pass to furthest man, two 1v1s',
    'Opponent is caught high when it loses the ball; there is open space in the other half.',
    'Regain with the opponent''s defenders spread high',
    'One pass into space for the most advanced forward, a second forward follows to make two 1v1 duels, the carrier drives into the box and crosses low for a late runner from the far flank (about 9 seconds).',
    NULL, 134, 137, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep midfielder (Alonso)', 'pass forward into the free space straight away'),
    (2, 'Furthest forward (Ronaldo)', 'run onto it, beat his man, drive into the box'),
    (3, 'Second forward (Callejon)', 'follow up behind to create a second 1v1'),
    (4, 'Far-side wide forward (Di Maria)', 'arrive at the back post to finish the low cross'),
    (5, 'Support player (practice)', 'join the 10 for a quick 1-2 then repeat in the final zone')
) AS v(so, role, job);

-- 36. pp.135-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'out_of_possession', 'Transition from Defence to Attack in the Low Zone - sessions (Chapter 4)', 'Ball-oriented defence to set up break',
    'Defending in the low zone (often a 4-2 block of defenders and holding midfielders), the team uses ball-oriented defending to win the ball and launch the break.',
    'Opponent enters the low zone / restarts with a throw-in',
    'Press the ball hard with cover behind and correct distances, win it, and move it forward within seconds.',
    NULL, 135, 151, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest defender', 'pressure the ball as much as possible'),
    (2, 'Covering defenders', 'cover passing options and shuffle positions across (transpose)'),
    (3, 'Back four + two midfielders', 'keep tight distances between each other'),
    (4, 'Ball winner', 'look to play forward immediately (mini goal within 6 seconds in the drill)')
) AS v(so, role, job);

-- 37. pp.145-148
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Long Pass to Switch Play to the Weak Side on the Break (Chapter 4)', 'Long diagonal switch on the counter',
    'Real win a second ball with a numerical advantage while the opponent is gathered on one side.',
    'Second ball won in midfield, far flank empty',
    'A long pass changes the point of attack to the far flank; the wide receiver carries until a centre back engages and crosses to the far post for a timed run (about 9 seconds).',
    NULL, 145, 148, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder who wins the ball (Ozil)', 'choose the long switch to the weak side'),
    (2, 'Far-side receiver (Ramos as advanced full back / wide forward)', 'control on the flank, dribble until engaged, cross'),
    (3, 'Striker (Benzema)', 'time run from the opposite flank to the far post'),
    (4, 'Other forward (Ronaldo)', 'attack the near post'),
    (5, 'Midfield runner (Di Maria)', 'arrive at the edge of the box behind them')
) AS v(so, role, job);

-- 38. pp.161-161
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Transition from Defence to Attack in the Middle Zone - overview (Chapter 5)', 'Attack space behind a line staying high',
    'Many opponents keep a high line after losing the ball in midfield; Real recognise this at once.',
    'Ball won in midfield with opponent''s line still high',
    'The ball winner plays a quick pass to keep it and the next player sends the final pass into space behind for a fast runner.',
    NULL, 161, 161, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner', 'secure possession with a quick short pass'),
    (2, 'Second player', 'play the final pass into space behind the line'),
    (3, 'Fast forward', 'run onto it behind the defence')
) AS v(so, role, job);

-- 39. pp.161-161
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Transition from Defence to Attack in the Middle Zone - overview (Chapter 5)', 'Overload fast break with late runner',
    'Opponent loses the ball while unbalanced, with only two or three players behind the ball.',
    'Regain with few opponents behind the ball',
    'Real break fast into 2+1v2 or 3+1v3, the extra man arriving from deep with a timed run and receiving the pass into space in the high zone.',
    NULL, 161, 161, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front attackers', 'engage the remaining defenders'),
    (2, 'Runner from deep (+1)', 'time the run to become the free man'),
    (3, 'Ball carrier', 'time the pass into space for the spare man')
) AS v(so, role, job);

-- 40. pp.161-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Breaking from the Middle Zone: Causing Imbalance with a Delayed Pass (Chapter 5)', 'Middle-zone regain, dribble at retreating four',
    'Real win the ball in the centre (e.g. a forward pressing from behind) with four opponents back but far from their teammates, giving a 4v4.',
    'Ball stolen in midfield, opponent''s back four isolated',
    'The carrier dribbles up to the defensive line while teammates make diagonal runs behind it, then a delayed pass releases a runner to score.',
    NULL, 161, 162, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Benzema)', 'press the receiver from behind and steal the ball'),
    (2, 'Ball carrier', 'dribble at the back line to draw defenders'),
    (3, 'Other forwards (Ronaldo, Ozil, Di Maria)', 'diagonal runs behind the line for the delayed pass')
) AS v(so, role, job);

-- 41. pp.163-166
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Ch5 Transition in the Middle Zone - Breaking from the Middle Zone: delayed pass', 'Middle-zone regain: carry, draw, delayed release',
    'After winning the ball in midfield, the carrier dribbles straight at a defender while a teammate makes an inside overlap and the far winger runs in behind between full back and centre back.',
    'Ball won in middle zone, back line not yet set',
    'Pull a defender out of the line, then slip the runner into the gap he leaves for a finish.',
    NULL, 163, 166, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder (Ozil)', 'Carries the ball up to a defender to fix him, then plays the delayed pass into space'),
    (2, 'Centre forward (Benzema)', 'Inside overlap run to drag markers'),
    (3, 'Far winger (Ronaldo)', 'Reads the drawn defender and runs behind between right back and centre back'),
    (4, 'Whole team', 'Press as a unit to win it, then 1-2 touch tempo with coordinated timing')
) AS v(so, role, job);

-- 42. pp.167-168
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Ch5 Winning Possession in the Centre: Breaking vs a High Line (1)', 'Central regain, striker runs round full back',
    'A holding midfielder wins a duel in the centre and gives to the winger, who carries forward against an opponent still holding a high line.',
    'Regain in centre while opponent''s line is high',
    'Striker''s diagonal run behind the full back receives in behind and drives at goal.',
    NULL, 167, 168, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Khedira)', 'Wins the 1v1 and plays the first pass wide-forward'),
    (2, 'Winger (Di Maria)', 'Dribbles forward a few yards, then slides the ball into the space behind'),
    (3, 'Centre forward (Higuain)', 'Diagonal run around the back of the left back, receives and attacks the box')
) AS v(so, role, job);

-- 43. pp.169-170
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Ch5 Winning Possession in the Centre: Breaking vs a High Line (2)', 'Draw the full back, free man, diagonal runs',
    'Carrier dribbles out of a central regain with five opponents behind him; the full back steps out to close him and leaves the wide man free.',
    'Opposition full back leaves his line to press the carrier',
    'Quick pass to the free wide player, who passes behind the line to diagonal runners before defenders recover.',
    NULL, 169, 170, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central carrier (Di Maria)', 'Drives forward to attract the full back'),
    (2, 'Wide player (Ozil)', 'Receives free on the flank, does not wait, plays early pass behind the line'),
    (3, 'Forwards (Ronaldo, Di Maria)', 'Diagonal runs in behind; quickest one takes it round the keeper'),
    (4, 'Centre forward (Benzema)', 'Fills the box for a second option')
) AS v(so, role, job);

-- 44. pp.171-173
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Ch5 Winning Possession in the Centre - practices', 'Unit press then go in 4-6 seconds',
    'Team presses together in the middle zone against a 4-4 build-up; on regain the attack must reach the high zone within 4-5 seconds or 3-4 touches.',
    'Ball enters the middle zone / possession won there',
    'Instant, limited-touch counter that gets behind the defensive line before it reorganises.',
    NULL, 171, 173, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front players', 'Hold off when opponent is in its safe zone, press as soon as the ball enters midfield'),
    (2, 'Ball winner', 'First pass forward immediately'),
    (3, 'Runners', 'Intelligent runs behind the line at the moment of the regain')
) AS v(so, role, job);

-- 45. pp.174-178
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Ch5 Overload Fast Break Attack', 'Third runner turns 2v2 into 3v2',
    'Fast break with two attackers against two defenders; a midfielder sprints up from behind to add a third attacker.',
    '2v2 break with a teammate able to join',
    'Use the spare man: carrier draws a defender then releases the extra runner, who crosses first time for the far-side runner.',
    NULL, 174, 178, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide carrier (Altintop)', 'Dribbles inside from the left, passes inside, then runs into the box from the far side'),
    (2, 'Central forward (Ronaldo)', 'Dribbles at the defender and times the pass to the overlapping spare man'),
    (3, 'Late midfielder (Alonso)', 'Sprints from deep to create +1 and crosses first time'),
    (4, 'Side players', 'Stay alert to join immediately when the ball goes forward')
) AS v(so, role, job);

-- 46. pp.180-188
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_defend', 'Ch6 Transition from Attack to Defence & then Defence to Attack', 'High-zone counter-press, deny the turn',
    'Real lose the ball near the opponent''s box while attacking with safe possession; nearest players press the receiver at once with no time or space.',
    'Possession lost in the high zone',
    'Force a hurried or bad pass and win it back within about 6-8 seconds.',
    NULL, 180, 188, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest attackers', 'Press the man on the ball immediately, high tempo'),
    (2, 'Central midfielder (Alonso)', 'Steps up while the pass travels to close the receiver'),
    (3, 'Full back (Arbeloa)', 'Squeezes in from behind so the receiver cannot turn, dribble or pass'),
    (4, 'Rest of team', 'Hold formation positions while possessing so they are ready to press')
) AS v(so, role, job);

-- 47. pp.180-188
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_attack', 'Ch6 Transition from Attack to Defence & then Defence to Attack', 'High regain: forward pass into imbalance',
    'Immediately after a high-zone regain the defence is unbalanced and close to its own box.',
    'Ball won back high up the pitch',
    'Ball winner plays straight forward to a better-placed teammate; finish within about 6 seconds.',
    NULL, 180, 188, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (Arbeloa / Ozil)', 'First pass forward at once to a striker'),
    (2, 'Centre forward (Benzema / Higuain)', 'Takes a position in the gap of the disordered line; shoots or lays off when the centre back closes'),
    (3, 'Wide forward (Ronaldo)', 'Offers on the outside of the closing centre back and finishes first touch')
) AS v(so, role, job);

-- 48. pp.190-191
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch7 Passing Through the Midfield Line from the Back (1)', 'Split CBs, pass beyond a passive midfield',
    'Opponent sits in a 4-1-4-1 and does not press the ball, leaving big gaps between lines; centre backs split to the box edges and full backs give width.',
    'Opponent holds lines without pressing the carrier',
    'One forward pass from the back removes six opponents, winger turns between lines and runs at a deep back four.',
    '4-1-4-1', 190, 191, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Ramos, Pepe)', 'Open wide to the edges of the box'),
    (2, 'Full backs', 'High and wide to stretch'),
    (3, 'Deep midfielder (Alonso)', 'Carries forward and passes behind the midfield line'),
    (4, 'Winger (Di Maria)', 'Moves into the gap, directional first touch, turns and dribbles'),
    (5, 'Strikers (Ronaldo, Benzema)', 'Run between full backs and centre backs of the flat back four')
) AS v(so, role, job);

-- 49. pp.192-192
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch7 Passing Through the Midfield Line from the Back (2)', 'CB pass to 10 running behind midfield',
    'Against a 4-4-2 that leaves space between lines and does not press the carrier, a centre back passes to the attacking midfielder''s run behind the midfield line.',
    'Distance between opponent lines, no pressure on centre back',
    'Six players bypassed, 4v4 against the back line; play is finished by a cross with several timed box runs.',
    '4-4-2', 192, 192, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (Pepe)', 'Plays the pass through the midfield line'),
    (2, 'Attacking midfielder (Kaka)', 'Clever run behind midfield, carries forward, attempts chip pass'),
    (3, 'Left back (Marcelo)', 'Arrives on the loose ball and crosses'),
    (4, 'Forwards', 'Three or four runners attack near post and box spaces at the right time')
) AS v(so, role, job);

-- 50. pp.193-197
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'to_defend', 'Ch7 Passing Through the Midfield Line - practices', 'Zone loss: nearest press, two screen middle',
    'Possession game in zones where forward passes go through a middle zone; when the team loses the ball, the players in that zone counter-press while others drop to cut central passes.',
    'Ball lost while building in an outside zone',
    'Win it back within about 6 seconds and stop the opponent passing through to the far zone.',
    NULL, 193, 197, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players in the ball zone (3-4)', 'Press the ball immediately'),
    (2, 'Two middle players', 'Move into the central lane to intercept switches'),
    (3, 'Possession players', 'Open, half-turned body shape; seek early direct passes through the lines')
) AS v(so, role, job);

-- 51. pp.198-199
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch7 Building Up Play from the Back Through the Centre (1)', 'Central combos break the midfield line',
    'In build-up the pitch splits into 1v1s on the flanks and a 3v3 in the centre; one-touch combinations in the middle break the midfield line and find the winger.',
    'Even central numbers with gaps between players',
    'Winger drives inside with full back overlapping outside for +1, cutting runs behind a narrow back four.',
    NULL, 198, 199, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central trio (Alonso, Khedira, Kaka)', 'Quick one-touch combinations to get through midfield'),
    (2, 'Winger (Di Maria)', 'Dribbles inside, then plays through ball to the runner'),
    (3, 'Full back (Arbeloa)', 'Overlaps outside to create wide overload'),
    (4, 'Attacking mid and striker (Kaka, Higuain)', 'Diagonal cutting runs behind the line'),
    (5, 'Far forward (Ronaldo)', 'Runs the opposite way to clear space')
) AS v(so, role, job);

-- 52. pp.200-203
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch7 Building Up Play from the Back Through the Centre (2)', 'Dribble out of 3v3, full back steps up',
    'Playmaker on the ball in the low zone with a 3v3 in the centre; the wide forward stays inside so the full back pushes high and a centre back covers behind him.',
    'Playmaker beats his marker in the 3v3',
    'Ball goes wide to the advanced full back and into a 4v4 at the edge of the box, finished by dribble-and-inside pass to the striker.',
    NULL, 200, 203, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Playmaker (Ozil)', 'Dribbles past his man, passes wide and runs on'),
    (2, 'Wide forward (Ronaldo)', 'Holds inside position to free the flank'),
    (3, 'Left back (Marcelo)', 'Pushes up the flank to receive'),
    (4, 'Centre back (Carvalho)', 'Covers the full back''s space'),
    (5, 'Central mid (Coentrao)', 'Joins forward, dribbles at his man and slips the ball inside'),
    (6, 'Centre forward (Benzema)', 'Good first touch and finish from the return pass')
) AS v(so, role, job);

-- 53. pp.204-205
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch7 Build Up Play with a 4v4 Situation on the Flank', 'Switch direction, striker cuts in front',
    '4v4 on the side; the deep midfielder changes the direction of play with a pass inside to the attacking midfielder.',
    'Pass inside from the wide 4v4',
    'Striker''s cutting run in front of the receiver gets a first-time pass into his path, leaving a 3v3 and 1v1 v the centre back near the box.',
    NULL, 204, 205, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep midfielder (Alonso)', 'Switches the angle with pass to the attacking midfielder'),
    (2, 'Attacking midfielder (Kaka)', 'First-time pass into the striker''s run'),
    (3, 'Centre forward (Higuain)', 'Cuts across in front of the receiver while the ball travels, then beats the centre back 1v1'),
    (4, 'Second striker (Benzema)', 'Runs up to make 3v3 at the box')
) AS v(so, role, job);

-- 54. pp.206-209
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'jose-mourinho-attacking-sessions-114-practices-from-goal-analysis-of-real-madrid'), 'in_possession', 'Ch7 Creating 1v1 and 2v1 Situations Near the Penalty Area', 'Give it to the best 1v1, then support',
    '3v3 on the side near the box; the playmaker switches play to the striker and supports, and the striker feeds the team''s best dribbler who is isolated 1v1.',
    'Best dribbler isolated against one defender near the box',
    'Dribbler attacks his man with a nearby supporter offering a 2v1 or one-two; here he took on and won a penalty.',
    NULL, 206, 209, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Playmaker (Ozil)', 'Changes direction of play and gives quick support'),
    (2, 'Centre forward (Benzema)', 'Passes on to the better 1v1 player, then moves close to offer a 1-2'),
    (3, 'Wide forward (Ronaldo)', 'Takes on his defender 1v1'),
    (4, 'Supporting players', 'Leave their zone to create 2v1s; correct angle and distance for one-touch play')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('1994-coaching-book-mourinho-attacking-sessions-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
