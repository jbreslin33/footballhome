-- 2109 📚 Coaching book patterns: "Technical Practices to Maximise Performance" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Technical Practices to Maximise Performance',
    subtitle    = '50 Practices - Youth to Pro - Training Week - Football Periodization',
    author      = 'Adam Owen',
    team        = 'Football Periodization model',
    method_note = 'Technical practices slotted into a tapered training week from the author''s Football Periodization series: intensive small-space practices (receiving under pressure, quick turns, one- and two-touch play) early in the week and extensive large-space practices (longer passing, switches, overlaps, build-up circuits) later. A research chapter draws on match data (Rodri''s passing, La Liga pass lengths, tournament line breaks) for principles such as patient build-up, breaking one line at a time and the medium-range final pass. The practices are mostly unopposed, so patterns are the match behaviours they rehearse (open on the half-turn, one-two support, up-back-through third-man combinations, switches, overlaps, a 3-2-5 build-up from a 4-3-3), in our words.'
WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w');

-- 1. pp.33-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Technical Passing in Football: Lessons from Rodri''s Elite Performance', 'Pivot: short circulation then switch',
    'The holding midfielder (Rodri as the model) mixes frequent short combinations in tight central spaces with precise diagonal or vertical medium/long passes that switch play, break lines or launch counters.',
    'Pivot receives in the middle; space opens on far side or behind a line',
    'Keep the ball safely while also moving it forward or across quickly to exploit space.',
    NULL, 33, 36, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Rodri)', 'Short tidy passes to keep the ball, then the diagonal switch or vertical line-breaking pass'),
    (2, 'Far-side winger/full back', 'Hold width to receive the switch'),
    (3, 'Forwards', 'Show between lines for the vertical pass')
) AS v(so, role, job);

-- 2. pp.37-37
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'to_defend', 'Passing Dominance in La Liga: Real Madrid and Barcelona', 'Short spacing for instant regain',
    'Real Madrid and Barcelona rely on short and medium passes, which keeps players close to the ball; if it is lost, several players are already near to win it back.',
    'Ball lost during short-passing possession',
    'Regain possession quickly thanks to compact supporting positions.',
    NULL, 37, 37, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Players near the ball', 'Stay at short passing distance while attacking; press immediately on loss'),
    (2, 'Supporting midfielders', 'Close passing lanes around the ball to trap the opponent')
) AS v(so, role, job);

-- 3. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Analysis of Passing and Goal Scoring Trends at International Tournaments', 'Medium-range final pass',
    'Tournament data (World Cup 2014, Euro 2016) shows a large share of goals come from assists of about 10-24 m, and scoring chances drop as long-ball count rises.',
    'Team in the final third with a teammate in a scoring position',
    'Favour the medium-length assist over long balls to create goals.',
    NULL, 38, 38, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking midfielder / wide player', 'Deliver the assist from medium range rather than hitting long'),
    (2, 'Strikers', 'Occupy scoring zones within medium passing range of the ball')
) AS v(so, role, job);

-- 4. pp.39-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Positioning, Line Breaking and Diagonal Runs / Impact of Player Movements When Receiving Passes (La Liga Study)', 'Receiver frees himself to break lines',
    'A line-breaking pass succeeds more often when the receiver has separated from the nearest defender, moves towards the ball, and especially arrives on a diagonal run rather than standing still.',
    'Teammate on the ball looking for a pass past a defensive line',
    'Increase completion of line-breaking passes and the chance the move ends in a shot.',
    NULL, 39, 44, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver between/behind lines', 'Separate from marker, come towards the ball or run diagonally into the lane'),
    (2, 'Ball carrier', 'Play the pass into the moving receiver''s path at the moment of separation'),
    (3, 'Nearby teammates', 'Keep distance so the receiver''s space is not crowded')
) AS v(so, role, job);

-- 5. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Breaking Defensive Lines: Insights from Argentina''s World Cup Final vs France', 'Break one line at a time',
    'Data from Argentina vs France shows short passes through a single defensive line are far more reliable than medium passes past two lines or long passes past three.',
    'Opposition set in three lines',
    'Progress mostly with short passes that beat one line, keeping the riskier multi-line pass for clear chances.',
    NULL, 40, 40, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Build-up players', 'Prefer the short pass that beats the next line'),
    (2, 'Players between lines', 'Position just beyond the nearest line to receive the short line-breaker'),
    (3, 'Forwards', 'Offer the occasional multi-line ball in behind when it is on')
) AS v(so, role, job);

-- 6. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Adapting to Match Situations', 'Match-state switch: patient vs direct',
    'Against a compact defence the team relies on precise short passing and off-ball runs to unlock it; when trailing, it shifts to quicker, more direct and aggressive forward passing.',
    'Compact low block faced, or team losing late',
    'Pick the build-up style that fits the game state to create chances and regain momentum.',
    NULL, 41, 41, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders', 'Vs compact block: quick precise combinations and movement to pull defenders'),
    (2, 'Passers in build-up', 'When losing: look forward earlier, play more direct vertical balls'),
    (3, 'Forwards', 'Make runs in behind to give the direct option')
) AS v(so, role, job);

-- 7. pp.41-42
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Tactical Insights and Practical Applications for Coaches / Slower Progression: A Mark of Top Teams', 'Patient build-up, wait to break lines',
    'Team has the ball in its own half or midfield against an organised block; top teams move the ball sideways and keep it rather than forcing forward passes.',
    'No clean forward lane yet; opponent block set',
    'Keep possession and tempo control until a gap opens, then play through the opponent''s line with a deliberate attack.',
    NULL, 41, 42, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs and pivot', 'Circulate horizontally, keep the ball, scan for the opening'),
    (2, 'Midfielders', 'Stay available between lines, show for the forward pass when the gap appears'),
    (3, 'Full backs', 'Give width so the ball can be switched to stretch the block')
) AS v(so, role, job);

-- 8. pp.42-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Attacking Strategy: Penetrating Passes / Summary of the La Liga Study Findings', 'Final-third entries vs low block',
    'Top sides enter the final third more often, using through passes and crosses to penetrate deep defences; successful passes in the pre-attack and attack zones (central and wide-right pre-attack areas as key hubs) strongly raise the chance of a shot.',
    'Opponent defending deep; ball reaches the pre-attack zone',
    'Turn possession into frequent, varied entries that end in shots.',
    NULL, 42, 44, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central attacking midfielder', 'Receive in the central pre-attack zone and play the through pass'),
    (2, 'Wide players', 'Receive in the wide pre-attack zone and cross or combine'),
    (3, 'Strikers', 'Time runs to attack through balls and crosses')
) AS v(so, role, job);

-- 9. pp.51-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Practices 3, 4, 5, 8 (Technical Receiving Rotational Combinations; Bayern Munich Open Up to Receive; Receiving and Support Play; Ajax Triangle Open Up to Receive) / Key Coaching Points', 'Open up on half-turn, play forward',
    'Receiver checks away from the marker (mannequin/cone), opens his body on the half-turn and takes the first touch with the back foot around the defender, then passes on quickly; players then rotate positions.',
    'Pass coming to a player with a defender close behind or beside him',
    'Receive already facing forward so the next pass goes past the pressure in one or two touches.',
    NULL, 51, 59, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiving midfielder', 'Check away, open up on the half-turn, back-foot first touch away from pressure'),
    (2, 'Passer', 'Firm, well-weighted pass to the receiver''s back foot'),
    (3, 'Next receiver', 'Move into a new passing lane with a sharp change of direction')
) AS v(so, role, job);

-- 10. pp.56-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Practices 5 and 9 (Receiving and Support Play Combinations; Ajax Triangle Rotational Passing with One-Two Support Play)', 'One-two support around a defender',
    'The passer follows his pass to support the receiver, gets the ball back first time (wall pass), and the receiver times a curved run around the defender to collect the set ball.',
    'Receiver pressed, passer close by in support',
    'Bypass a defender with a quick give-and-go and keep the ball moving forward.',
    NULL, 56, 60, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer', 'Pass and move towards the receiver to offer the return'),
    (2, 'Wall player', 'Return first time with correct weight in front of the runner'),
    (3, 'Runner', 'Curve run around the defender, time arrival with the set pass')
) AS v(so, role, job);

-- 11. pp.57-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Practice 6: Up, Back and Through Passing and Switching Play Combination', 'Up-back-through then switch',
    'A diagonal pass goes up to a central player, who lays it back to a teammate facing play; that player switches the ball to the far side where a wide player receives behind his marker with a directional first touch.',
    'Ball played into a central player who cannot turn',
    'Use the lay-off to change the angle and switch play to the free side quickly.',
    NULL, 57, 57, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central target player', 'Receive the diagonal ball and set it back first time'),
    (2, 'Facing midfielder', 'Take the lay-off and switch to the far side'),
    (3, 'Far-side wide player', 'Open up behind the marker, directional first touch away from pressure')
) AS v(so, role, job);

-- 12. pp.58-58
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Practice 7: End to End Third Man Run Combinations to Play Forward', 'Third-man run to play forward',
    'First player passes into a central midfielder, who sets it for a second player to play forward to another midfielder; that midfielder then sets it into the path of the first player, who has run on forward.',
    'Pass into a central player who sets it back',
    'Move the ball and a runner forward past pressure through timed set passes and third-man runs.',
    NULL, 58, 58, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Initial passer (third man)', 'Pass in, then sprint forward to receive later'),
    (2, 'Central midfielders', 'Set the ball first time for the forward pass and for the runner'),
    (3, 'Second player', 'Play forward to the next midfielder off the set')
) AS v(so, role, job);

-- 13. pp.61-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Intensive Technical Practices: Ajax triangle one-two, Give & Go Y, Inter Milan quick combination', 'Give-and-go to run past a marker',
    'Ball carrier plays into a near team-mate and sprints past him on a curved run to take the return in front of him, used both centrally and to release a wide runner.',
    'Team-mate close by with a defender between carrier and space',
    'Beat a man or line with a wall pass and arrive running onto the ball.',
    NULL, 61, 72, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball carrier', 'pass into the wall player and sprint round on a curved line'),
    (2, 'Wall player', 'check off his marker, return first time with the right weight in front of the runner'),
    (3, 'Next receiver', 'open up to take the onward pass')
) AS v(so, role, job);

-- 14. pp.61-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Intensive Technical Practices: Ajax triangle, Up-Back-Through Y, diamonds; Extensive: FC Barcelona Figure of 8', 'Up-back-through third-man combination',
    'A forward player checks away then shows to the ball, lets it come back to a supporting team-mate facing play, who then plays forward or diagonally into a third player already moving into space.',
    'Forward pass into a player with his back to play',
    'Progress the ball past a line by using the facing supporter instead of the receiver turning.',
    NULL, 61, 89, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front receiver (e.g. inside player B / D)', 'check away, receive and set back first time'),
    (2, 'Supporting player (passer A)', 'follow the pass into support, play the forward ball on the set-back'),
    (3, 'Third man (C / E)', 'time a curved run off the cone to arrive as the set-back is played'),
    (4, 'All', 'open body shape so the next pass is one touch')
) AS v(so, role, job);

-- 15. pp.61-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Key Coaching Points (Intensive and Extensive Technical Practices)', 'Check away, receive half-turned, play forward',
    'Before every reception the player moves away from the ball (or the cone/marker) then comes back, scans, and receives on the back foot with an open body so his first touch already faces the next forward pass.',
    'Team-mate about to pass to him',
    'Gain time and see more of the pitch so the team can play quickly forward.',
    NULL, 61, 107, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Any receiver', 'check away, scan, open body, receive across the body on the back foot'),
    (2, 'Passer', 'correct weight in front of the receiver''s back foot'),
    (3, 'All', 'follow your pass and rotate into the next position at speed')
) AS v(so, role, job);

-- 16. pp.68-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Intensive: Create Space to Lose a Defender, Scanning Double Movement Diamond; Extensive: Breaking Lines diamond (go long to come short)', 'Receiver''s double movement tells the passer',
    'The intended receiver makes a first movement one way (away or toward) then comes back the other; the direction of that first movement tells the passer whether to play to feet short or in behind long.',
    'Receiver scans and sees his marker''s position before the ball',
    'Lose the marker and give the passer a clear cue for short or long.',
    NULL, 68, 102, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver (B / D)', 'go long to receive short, or short to receive long; scan first'),
    (2, 'Passer (A / C)', 'read the first movement and choose the short or long pass'),
    (3, 'Receiver after control', 'turn and play first time if receiving in behind')
) AS v(so, role, job);

-- 17. pp.76-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Intensive: Ladder Back Foot Receiving and Shooting, Man City One-Touch Finishing; Extensive: Two Way Forward Passing, Wide Combinations, and Finishing', 'Set-back then slip the finisher in',
    'A forward pass is set back first time to a supporting player, who then plays a through or wide ball for an attacker to take a directional touch past his marker toward goal and finish.',
    'Attacker receives with back to goal near the box',
    'Create a clean shooting chance with a short combination.',
    NULL, 76, 106, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Supporting player (A/D)', 'pass forward, receive the set-back, play the final ball'),
    (2, 'Target / set player (B/E)', 'set the ball back first time'),
    (3, 'Finisher (C/F)', 'directional first touch past the cone toward goal, side-foot finish')
) AS v(so, role, job);

-- 18. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Extensive Technical Practices: Changing Lines and Angles Passing Combinations and Support Play', 'Support on different lines and angles',
    'Players around the ball must never stand on the same line as each other; each supporter takes a different height and angle so a forward or diagonal lane is always open, and moves inside off a marker to receive.',
    'Team-mate on the ball looking for a forward option',
    'Keep several passing lanes and keep the ball moving at high tempo.',
    NULL, 85, 85, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Supporting midfielders', 'stand on a different line or angle from the passer and each other'),
    (2, 'Receiver', 'move off the marker, receive half-turned on the back foot'),
    (3, 'Next player', 'double movement to offer the following pass')
) AS v(so, role, job);

-- 19. pp.86-103
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Extensive: PSG Switching Play, Positional and Rotational Combination Play with Switch of Play, Breaking Lines Combination Waves in Pairs', 'Open up and switch the play diagonally',
    'After the ball has been worked up one side, a central player opens his body as he receives and plays a long diagonal to the far side, where a team-mate is already opened up to receive and continue.',
    'One side congested, far side free',
    'Move the ball to the free side fast before the block can shift.',
    NULL, 86, 103, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielder (D)', 'turn inside on receiving and hit the diagonal switch'),
    (2, 'Far-side receiver (E / C1)', 'open up early, directional first touch forward'),
    (3, 'Near-side players', 'keep rotating into the positions vacated after passing')
) AS v(so, role, job);

-- 20. pp.90-102
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Extensive Technical Practices: Rotational Passing Combinations with Overlap Third Man Runs; Breaking Lines Diamond with Overlap; Third Man Run Overlaps with Defensive Pressure', 'Overlap third-man run round the wide receiver',
    'After passing wide, the player overlaps round the outside of the receiver; the wide player comes inside or lays the ball into a link player, and the through pass goes into the overlapping runner beyond the line.',
    'Wide player receives and fixes his marker',
    'Release a free runner round the outside behind the defensive line.',
    NULL, 90, 102, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Initial passer / full back (A/C)', 'pass wide then overlap on the outside at the right moment, communicate'),
    (2, 'Wide receiver (B/D)', 'double movement, receive, drive inside or play into the link'),
    (3, 'Link player (LP)', 'set position with open body, play the through ball for the overlap'),
    (4, 'Overlapping runner', 'arrive onto the through pass beyond the line')
) AS v(so, role, job);

-- 21. pp.92-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Extensive Technical Practices: High Intensity Game Speed Build Up Play Circuit; Play Out from the Back; Two Team Positional Build Up', 'Goalkeeper-led circulation across the back line',
    'Goalkeeper plays wide to the full back, who carries forward and passes inside; centre backs and a holding midfielder move the ball across in one or two touches to the far full back, who carries into space; build-up with a back four and two holding midfielders using support angles.',
    'Goalkeeper in possession, opponents not pressing the back line',
    'Switch the point of attack across the back line through the pivot and advance with a carry.',
    NULL, 92, 95, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'start wide and be the return option'),
    (2, 'Full backs (LB/RB)', 'receive wide, dribble forward, move the ball inside or kick-and-run into space'),
    (3, 'Centre backs (LCB/RCB)', '1-2 touch, open body, supporting angles'),
    (4, 'Holding midfielders (DM)', 'link the two centre backs and offer an angle between them')
) AS v(so, role, job);

-- 22. pp.95-96
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Extensive Technical Practices: Positional and Rotational Combination Play Tactical Patterns', 'Wide-inside-wide progression to the front two',
    'Centre back plays wide to the full back, who passes inside to the midfielder; the midfielder plays a one-two with the winger, runs round to take the return and feeds a forward; done on both sides at once.',
    'Centre back on the ball with the full back open wide',
    'Advance from the back line to the forwards through a wide-in-wide combination.',
    NULL, 95, 96, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre back (A)', 'start with a pass wide'),
    (2, 'Full back (B)', 'receive on the half-turn, pass inside'),
    (3, 'Central midfielder (D)', 'one-two with the winger, run round his marker, feed the forward'),
    (4, 'Winger (E)', 'set the ball back or lay it into the midfielder''s run'),
    (5, 'Forward (F)', 'receive and finish the move / restart on the other side')
) AS v(so, role, job);

-- 23. pp.98-104
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Extensive Technical Practices: Real Madrid Breaking Lines and Support Play Combinations (Variations 1 and 2); Rangers FC Breaking Lines', 'Drop between lines, play forward, run beyond',
    'Players in pairs attack in waves: a midfielder drops off the opposition line to receive, plays forward to a team-mate who has moved round the next line (or wide), who can combine with a one-two before the ball reaches the end players.',
    'Forward pass available into the gap behind a line',
    'Break successive lines with support always arriving underneath.',
    NULL, 98, 104, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back pair (A/B)', 'circulate across, then pass forward into the gap'),
    (2, 'Dropping midfielder (C)', 'come off the line to receive, play forward, then shift across in support'),
    (3, 'Advanced midfielder (D)', 'move round the next line or wide to receive the vertical ball, one-two with C'),
    (4, 'End players (E/F)', 'receive and become the next wave')
) AS v(so, role, job);

-- 24. pp.101-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Extensive Technical Practices: Breaking Lines with Wide Combination Play Diamond Passing with Underlap', 'Underlap inside the wide receiver',
    'Same wide combination but the runner goes on the inside channel between wide player and the defensive line, and the wide receiver plays the outside-of-the-boot pass into that inside run.',
    'Defender on the wide player covering the outside',
    'Break the line through the half-space with an inside run.',
    NULL, 101, 101, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passer (A/C)', 'pass wide then underlap into the inside channel'),
    (2, 'Wide receiver (B/D)', 'double movement, receive and slide the ball inside into the run'),
    (3, 'Underlapping runner', 'attack the gap between defenders')
) AS v(so, role, job);

-- 25. pp.104-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Extensive Technical Practices: Rangers FC Breaking Lines with Dribbling Circuit + Finish', 'Receive behind line then drive through',
    'A player opens up to receive behind the first line, takes a back-foot first touch and carries the ball at speed through a gap in the next opposition line before shooting.',
    'Space opens in front after receiving behind a line',
    'Break the last line by dribbling and get a shot away.',
    NULL, 104, 105, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Receiver (B/D)', 'open up behind the line, first touch with back foot'),
    (2, 'Same player on the carry', 'ball close at speed through the gap, then shoot'),
    (3, 'Passer (A/C)', 'firm forward ground pass into the receiver')
) AS v(so, role, job);

-- 26. pp.107-107
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'technical-practices-to-maximise-performance-50-practices-youth-to-pro-training-w'), 'in_possession', 'Extensive Technical Practices: Tactical Build Up to Break Lines and Finish Attacks', '3-2-5 build-up with inverted right back',
    'From a 4-3-3 the team builds in a 3-2-5: the right back steps into midfield next to the holding player, the back three and goalkeeper circulate, wide players hold width, and passes are played wide before attacking runs into the box; the set shape can vary (e.g. 3-2-5) per coach.',
    'Goal kick / goalkeeper restart in own third',
    'Play through the opponent''s lines and finish with at least four players arriving in the box.',
    NULL, 107, 107, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted right back', 'move into central midfield beside the DM during build-up'),
    (2, 'Centre backs + left back', 'form the back three with the goalkeeper, circulate and break the first line'),
    (3, 'Holding midfielder (DM)', 'receive between lines and switch or play forward'),
    (4, 'Wingers (LW/RW)', 'hold width, receive wide, deliver'),
    (5, 'Two attacking midfielders + centre forward', 'movement and counter-movement, attacking runs into the box')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('2109-coaching-book-technical-practices-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
