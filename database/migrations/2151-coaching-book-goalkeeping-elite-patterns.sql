-- 2151 📚 Coaching book patterns: "Goalkeeping Elite Training Program" (SoccerTutor).  Every page read by
-- paired-page readers; each distinct team behaviour the book teaches is
-- written up in OUR OWN WORDS with app page numbers as the citation and who
-- does what.  Drill layouts, warm-ups, theory and front matter are left out.
-- Owner's personal library.  (James 11/27 "yes start reading all the unread
-- books")
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    title       = 'Goalkeeping Elite Training Program',
    subtitle    = '60 Proven Drills - eBook (Vol. 1)',
    author      = 'Maarten Arts',
    team        = 'Goalkeeping',
    method_note = 'Sixty goalkeeper drills in five chapters: warm-ups, technical skills, passing, positioning and shot-stopping. Most drills are handling and footwork technique; the patterns here are the keeper''s on-pitch decisions and positions the coaching points teach (the 1-2-3 cycle of save, release, recover; dropping off after a goal kick and calling for the ball; scanning the far side and switching; repositioning after every pass and being set before the strike; the 1v1 block position; starting position and early calls on crosses; cut-back and near-post cover; parrying to safe areas; fast distribution after a catch), in our words. App page 1 is the book''s printed page 1 (roman front pages not captured).'
WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1');

-- 1. pp.8-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'to_attack', 'Goalkeeper Training Tips / Warm-Ups', '1-2-3 cycle: save, distribute, recover',
    'Every keeper action is followed straight away by a distribution and then a quick return to the correct position, rather than stopping after the save or catch.',
    'Keeper secures the ball (catch from cross or shot)',
    'Turn a regain into a fast release and never be caught out of position for the next phase.',
    NULL, 8, 23, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'after the catch, release quickly by throw or pass to a free team-mate'),
    (2, 'Goalkeeper', 'after distributing, sprint back into the correct starting position'),
    (3, 'Nearest outfield receiver', 'show early as the outlet for the quick release')
) AS v(so, role, job);

-- 2. pp.11-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'out_of_possession', 'Ch.2 Technical Skills: The ''Block Position''; Drills 2, 6, 10; Ch.1 Drill 1 variation', '1v1: close down into ''Block Position''',
    'When an attacker is through or the ball is played close to a forward''s feet, the keeper times his move off the line, attacks fast and sets in the low ''Block Position'' on the line of ball to goal, then reacts to the rebound.',
    'Pass to an attacker near goal, or attacker takes a heavy forward touch',
    'Cut the angle and the shortest route to goal, make a big barrier, and win the second ball after the block.',
    NULL, 11, 35, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'time the run out, approach fast with minimal steps, set before the shot'),
    (2, 'Goalkeeper', 'leading leg in line with the ball, legs closed so nothing goes under'),
    (3, 'Goalkeeper', 'if attacker pushes the ball forward, rush out to smother; else block'),
    (4, 'Goalkeeper', 'after the block, get up immediately and chase/secure the loose ball')
) AS v(so, role, job);

-- 3. pp.20-22
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'in_possession', 'Ch.1 Warm-Ups: Drills 10a/10b/10c Near Post Movement, Build-Up Lay-Off', 'Keeper receives wide of near post, switches',
    'In build-up the keeper leaves the centre of the goal to take a pass just outside the near post, then plays a second-touch diagonal ball through the lines to the far-side player or wide of the opposite post.',
    'Team-mate on one side plays the ball back toward the near post',
    'Use the keeper as a free man to shift play from the pressed side to the open side in two touches.',
    NULL, 20, 22, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'move across early to receive outside the near post, first touch out of feet'),
    (2, 'Goalkeeper', 'second touch: diagonal pass between the defenders to the far side'),
    (3, 'Wide defender/full back (ball side)', 'pass softly enough for a one-touch lay-off or a set'),
    (4, 'Far-side receiver', 'time the run to arrive as the switch is played, call for the ball before it arrives')
) AS v(so, role, job);

-- 4. pp.27-39
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'out_of_possession', 'Ch.2 Drill 3 High Ball Timing and Controlled Punching; Ch.3 Drill 2 Communication Under Pressure', 'Crosses: call early, ''YOU'' when staying',
    'On a cross or lofted ball into the box the keeper decides and calls before the ball arrives; if he will not reach it he shouts ''YOU'' so defenders know to deal with it; if he comes but cannot hold it he punches with control.',
    'Ball on its way to the crosser or lofted into the box',
    'Clear ownership of the high ball between keeper and back line, no hesitation or collisions.',
    NULL, 27, 39, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'call early while the ball is still travelling to the crosser and again before the delivery'),
    (2, 'Goalkeeper', 'if not claiming, shout YOU so defenders do not expect him'),
    (3, 'Goalkeeper', 'if claiming but cannot catch, punch at chest height with a short motion to a controlled area'),
    (4, 'Centre backs', 'attack the ball on YOU; leave it on the keeper''s call')
) AS v(so, role, job);

-- 5. pp.32-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'to_attack', 'Ch.2 Drill 7 Long Throws and Long Passing; Drill 11 Long Distribution', 'Long throw / long ball to midfield',
    'After catching, the keeper can launch a straight overarm throw or long kick to a team-mate in midfield, who controls, lays off, and the move continues.',
    'Keeper catches a high ball with a team-mate free in midfield',
    'Bypass the opponent''s first lines and start a counter quickly.',
    NULL, 32, 36, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'straight, controlled overarm throw with one arm up, follow through only after the ball passes the head'),
    (2, 'Goalkeeper', 'kick long with the stronger foot when distance is too great to throw'),
    (3, 'Midfield receiver', 'control on the chest and set a team-mate'),
    (4, 'Supporting midfielder', 'receive the lay-off and play forward or back into the box')
) AS v(so, role, job);

-- 6. pp.36-36
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'out_of_possession', 'Ch.2 Drill 11 Backpedaling Recovery and Long Distribution', 'Recover toward first post vs lob',
    'When the keeper has come off his line and the ball is played over him, he backpedals with a cross-step start and turns his back toward the first post to cover the biggest part of the goal while tracking the flight.',
    'Long or lofted ball over a keeper standing high',
    'Get back in time to catch or tip the ball rather than being lobbed.',
    NULL, 36, 36, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'start the retreat with a cross step for balance and distance'),
    (2, 'Goalkeeper', 'turn toward the first post while running back, eyes on the ball'),
    (3, 'Team-mate (another keeper/defender)', 'fill the keeper''s vacated area while he recovers')
) AS v(so, role, job);

-- 7. pp.38-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'in_possession', 'Ch.3 Passing: Drill 1 Passing and Support Sequence; Drill 3 Distribution, Recovery Movement', 'Keeper drops after goal kick to support',
    'After playing the first pass from a goal kick the keeper retreats to open distance from a possible presser and offers himself again on the side furthest from goal, calling ''HERE'' with an open body.',
    'Goal kick played short; striker may press the return pass',
    'Give the defenders a safe return option with time and the chance to open up to the other side.',
    NULL, 38, 40, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'after the goal kick, step back to create space and distance as if a forward is pressing'),
    (2, 'Goalkeeper', 'call early, open hand and shout HERE, ask for the ball on the side away from goal'),
    (3, 'Goalkeeper', 'receive with open body, scan after every touch, able to play either foot'),
    (4, 'Centre back/receiving defender', 'play sharp, direct returns to the keeper''s far-from-goal foot')
) AS v(so, role, job);

-- 8. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'out_of_possession', 'Ch.3 Passing: Drill 3 Distribution, Recovery Movement and Positioning with Cut-Back Saves', 'Cut-back: keeper off the post',
    'When a wide player gets deep near the byline, the keeper recovers across but does not lean on or touch the post, staying ready for the cut-back pass into the box.',
    'Attacker makes a deep run behind the line toward the byline',
    'Be set to save a first-time finish from a cut-back as well as a near-post shot.',
    NULL, 40, 40, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'recover quickly after distributing, take position near but not touching the near post'),
    (2, 'Goalkeeper', 'stay set and balanced to move across for the cut-back finish'),
    (3, 'Wide attacker (opponent)', 'reaches deep and cuts the ball back')
) AS v(so, role, job);

-- 9. pp.41-45
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'in_possession', 'Chapter 3: Passing (Drills 4a, 4b, 7)', 'Keeper as vocal one-touch support outlet',
    'Keeper takes part in short build-up circulation with nearby team-mates, receiving and returning passes around pressure (mannequins).',
    'Team-mate on the ball needs a back or square option',
    'Keep possession flowing with one-touch passes played into the space in front of the receiver at a controllable pace.',
    NULL, 41, 45, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Call for the ball loudly (''HERE''), receive and play first time into the receiver''s path, not too hard'),
    (2, 'Nearest defender/support player', 'Show for the return, receive on the move in space'),
    (3, 'Third player', 'Stay open and time the run late so the next pass is on')
) AS v(so, role, job);

-- 10. pp.44-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'in_possession', 'Chapter 3: Passing (Drills 6, 9)', 'Scan far side before back pass, then switch long',
    'Keeper is about to receive a back pass or has just restarted play; the far side may be free for a lofted switch.',
    'Back pass on its way / goal kick just taken',
    'Keeper already knows the free side and can loft the ball over the pressure to a team-mate on the opposite side.',
    NULL, 44, 47, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Scan the opposite side and open the body before the ball arrives; after a goal kick drop back quickly to offer depth'),
    (2, 'Passing team-mate', 'Directional first touch before releasing the back pass'),
    (3, 'Far-side receiver', 'Control the long ball cleanly (chest or feet)')
) AS v(so, role, job);

-- 11. pp.44-57
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'out_of_possession', 'Chapter 3 Drills 6, 10; Chapter 4 Drill 7', 'Deeper starting position and early call on crosses',
    'Ball is wide and a lofted cross or ball over the top into the six-yard area is coming.',
    'Wide player shapes to deliver / ball leaves the crosser''s foot',
    'Keeper starts a bit deeper to cover the ball over him, then attacks the cross with an early, clear call so defenders know who takes it.',
    NULL, 44, 57, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Take a deeper start before the delivery, shout ''keeper'' as soon as the ball is struck, claim at the highest point'),
    (2, 'Defenders', 'Hear the call and clear the keeper''s path')
) AS v(so, role, job);

-- 12. pp.45-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'out_of_possession', 'Chapter 4: Positioning (Drills 3, 12); Chapter 3 Drill 7', 'Ground cut-back cross: time, don''t overcommit',
    'Wide player dribbles toward the byline and plays a low cross or cut-back across the six-yard area.',
    'Wide player reaches byline area with the ball',
    'Keeper holds an open, low, forward stance and times his approach so he is not beaten by the cut-back behind him.',
    NULL, 45, 62, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Do not move across too early; stay low, lead with hands, attack the ball only once the delivery is committed, reset quickly for the next side'),
    (2, 'Wide attacker (opponent)', 'Delivers along the ground or cuts back to the edge of the area')
) AS v(so, role, job);

-- 13. pp.46-76
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'to_attack', 'Chapter 3 Drill 8; Chapter 4 Drills 2, 9; Chapter 5 Drill 11', 'Fast distribution straight after a catch',
    'Keeper has just caught a shot or cross while opponents are still committed forward.',
    'Clean catch / ball secured',
    'Release the ball immediately by roll, underarm or overarm throw or volley to a moving team-mate to start the attack before the opponent resets.',
    NULL, 46, 76, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Choose distribution by distance: roll or underarm short, overarm throw with one bounce for medium, long throw or volley over pressure; use both feet'),
    (2, 'Receiving team-mate', 'Move into space to receive and play on quickly')
) AS v(so, role, job);

-- 14. pp.53-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'out_of_possession', 'Chapter 4: Positioning (Drills 5a, 5b, 4); Chapter 5 Drill 5', 'Reposition on every pass as if a shot',
    'Opponents circulate the ball around the edge of the box; each new ball location could produce a shot.',
    'Every pass / change of ball carrier',
    'Keeper is always on the correct line between ball and goal and set when any player can strike.',
    NULL, 53, 55, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Shift with each pass, treat every ball source as a live threat, go action after action without anticipating ahead')
) AS v(so, role, job);

-- 15. pp.56-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'out_of_possession', 'Chapter 4: Positioning (Drills 8, 9, 6)', 'Near-post / short-corner coverage, post check',
    'Ball is played into an angled area near the goal line where a near-post shot is possible.',
    'Ball moves to a tight angle on either side',
    'Keeper follows the ball''s path and uses the near post as reference so the short side is closed.',
    NULL, 56, 59, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Follow the ball path, check the short-corner post, stay facing the play while moving, be ready for the low shot after the pass')
) AS v(so, role, job);

-- 16. pp.60-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'out_of_possession', 'Chapter 4 Drill 10; Chapter 5 Drills 4, 1a', 'Second-action recovery across goal',
    'After a first save or a pass, the ball is switched and a second shot comes from the other side.',
    'First save made or ball moved across the face of goal',
    'Keeper recovers across the line with cross-steps and is set for the follow-up shot.',
    NULL, 60, 68, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Get up immediately, cross-step across goal, reset on the line before the next shot'),
    (2, 'Covering defender', 'Get back to the goal line, feet aligned, to cover before the final shot')
) AS v(so, role, job);

-- 17. pp.60-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'out_of_possession', 'Chapter 4: Positioning (Drill 10); Chapter 5 Drill 7b', '1v1: narrow angle, block, make attacker commit',
    'An attacker dribbles in on goal after a one-two or a pass behind; keeper must choose a starting position and come out.',
    'Attacker carries the ball toward goal inside the box',
    'Keeper closes distance under control, sets early in a compact block position and forces the attacker to move first.',
    NULL, 60, 72, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Start where he can both pressure the ball and recover for a shot; come out with control, narrow the angle, set before contact, stay big and compact, do not go down early')
) AS v(so, role, job);

-- 18. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'out_of_possession', 'Chapter 4: Positioning (Drill 11)', 'Parry into safe area toward team-mate',
    'A shot or throw cannot be caught cleanly from close range.',
    'Ball too hard or awkward to hold',
    'Keeper deflects the ball wide in a controlled direction (to a team-mate) instead of back into the danger zone.',
    NULL, 61, 61, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Stay close to the line before attacking, parry with the upper arm toward the side, away from the centre'),
    (2, 'Nearest defender', 'Collect the parried ball')
) AS v(so, role, job);

-- 19. pp.65-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'out_of_possession', 'Chapter 5: Shot-Stopping (Drills 1b, 6, 7a, 8, 9); Chapter 4 Drill 3', 'Arrive set just before the strike',
    'Attackers combine (one-two, through pass into space, run onto ball) before shooting; the shooter may decide the target late.',
    'Combination releases a shooter / shot is triggered',
    'Keeper tracks the ball early, delays his final step so he is set and balanced just as the shot comes, then attacks the ball, especially toward the far post.',
    NULL, 65, 74, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Track the pass early, orient body shape, time the step into position to land just before contact, do not lean or commit early, check the post for reference'),
    (2, 'Shooter', 'Keep target hidden until the last moment')
) AS v(so, role, job);

-- 20. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'goalkeeping-elite-training-program-60-proven-drills-ebook-vol-1'), 'in_possession', 'Chapter 5: Shot-Stopping (Drill 3)', 'Recovering centre back''s back pass to keeper',
    'A centre back sprinting back toward his own goal under pressure plays the ball back to the keeper positioned at the corner of the six-yard box.',
    'Centre back turned and chased, facing own goal',
    'Keeper receives a weighted back pass he can play first time and stays ready for the next action if possession is lost.',
    NULL, 67, 67, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Recovering centre back', 'Play the back pass soft enough that the keeper can play direct'),
    (2, 'Goalkeeper', 'Offer angle at the corner of the six-yard box, play on, then readjust to the ball for a possible angled shot')
) AS v(so, role, job);

INSERT INTO schema_migrations (filename) VALUES ('2151-coaching-book-goalkeeping-elite-patterns.sql') ON CONFLICT DO NOTHING;
COMMIT;
