-- 5024 📚 Coaching book patterns: "The Mixer: The Story of Premier League
-- Tactics, from Route One to False Nines" (Michael Cox, HarperCollins) —
-- Kindle library (spreads s001–s166 from Kindle Cloud Reader).  A tactics
-- history: each concrete team behaviour the author explains written up in
-- OUR OWN WORDS, naming the team / manager / season, with who does what.
-- Biography and anecdote left out.  Owner's personal library.  (James 11/27
-- Kindle picks)
--
-- Re-runnable: clears this book's patterns first (roles cascade).

BEGIN;

UPDATE coaching_books SET
    team        = 'Premier League, club by club',
    season      = '1992-2017',
    method_note = 'A history of Premier League tactics from 1992 to 2017: the back-pass law and the keeper, route one, Cantona''s deep 10, Blackburn''s crossing and Keegan''s Newcastle, the number 10s, Graham''s and Wenger''s Arsenal and the Invincibles, Ferguson''s United through every era, foreign imports and one up front, Allardyce''s Bolton and Pulis''s Stoke, the Makelele role and Mourinho''s Chelsea, Benitez''s Liverpool, three-man midfields, inverted wingers, the Italian managers, tiki-taka imports, Leicester''s title, Guardiola''s City and Conte''s 3-4-3. Patterns are the concrete team behaviours the book explains, naming the side and season, in our words. Kindle edition: page numbers are screen spreads.'
WHERE slug = 'kindle-the-mixer';

DELETE FROM coaching_book_patterns
WHERE book_id = (SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer');

-- 1. pp.6-6
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', 'Introduction', 'Route one into POMO',
    'English 1980s orthodoxy (Charles Hughes): hit the ball long into the box at once, aiming at the zone level with the far post, and live off the scramble that follows.',
    'Any possession in own half',
    'Get the ball into the danger zone as often as possible with as few passes as possible.',
    NULL, 6, 6, 10)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs / goalkeeper', 'launch early long balls into the box'),
    (2, 'Target striker', 'attack the far-post zone and win the first header'),
    (3, 'Second striker and midfielders', 'crowd the box for knock-downs and loose balls')
) AS v(so, role, job);

-- 2. pp.9-10
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '1 A Whole New Ball Game', 'Long balls plus offside goalie-blocker',
    'Wilkinson expected sides to answer the 1992 back-pass law by pumping balls in behind the defence while a striker hung about in an offside spot between the defenders and the keeper.',
    'Opposition defender turned towards his own goal chasing a long ball',
    'Cut off the safe pass back to the keeper so defenders have to kick the ball out or make a mistake.',
    NULL, 9, 10, 20)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Long passer (centre back/midfielder)', 'play the ball in behind the back line'),
    (2, 'Lurking striker (goalie-blocker)', 'stand between the retreating defender and the keeper to block the back-pass'),
    (3, 'Chasing forwards', 'close down the defender who has turned')
) AS v(so, role, job);

-- 3. pp.9-10
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '1 A Whole New Ball Game', 'Higher press after the back-pass law',
    'Defenders could no longer pass back for the keeper to pick up, so teams had more reason to press high and force mistakes. Back lines also stopped squeezing so aggressively, because the space behind now had to be played out of, not just collected. Games stretched and midfield opened up.',
    'Ball played back to a defender or keeper who has to use his feet',
    'Win the ball high or force a hurried clearance.',
    NULL, 9, 10, 30)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'chase back-passes and close down the keeper and centre backs'),
    (2, 'Back line', 'hold a less aggressive line, protecting the space behind')
) AS v(so, role, job);

-- 4. pp.10-11
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '1 A Whole New Ball Game', 'If in doubt, kick it out',
    'Early post-1992 defenders who were chasing balls back towards their own goal, with no back-pass option, simply hacked the ball into touch (Coventry''s instruction to put it in row Z).',
    'Defender facing own goal under pressure, no safe pass',
    'Remove the danger and give the defence time to reorganise, at the cost of possession.',
    NULL, 10, 11, 40)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Covering defender', 'clear the ball out of play instead of risking a pass'),
    (2, 'Rest of back line', 'reset shape while the throw is taken')
) AS v(so, role, job);

-- 5. pp.11-13
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '1 A Whole New Ball Game', 'Goalkeeper as eleventh outfielder',
    'Keepers such as Bryan Gunn, Seaman and later Van der Sar learned to receive back-passes and pass to teammates instead of hoofing, so teams began to play out from the back. Ball-playing centre backs (Paul McGrath, later Rio Ferdinand) became the model.',
    'Back-pass to the keeper or a centre back in build-up',
    'Keep possession from deep instead of giving it away with a long kick.',
    NULL, 11, 13, 50)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'control the back-pass and find a free teammate'),
    (2, 'Ball-playing centre backs', 'take the ball comfortably on either foot and pass out')
) AS v(so, role, job);

-- 6. pp.12-12
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '1 A Whole New Ball Game', 'Sweeper-keeper behind an offside trap',
    'Under George Graham, Arsenal''s aggressive offside trap meant Seaman was told to sweep proactively in the space behind the line and use both feet even before 1992.',
    'Ball played over a high back line',
    'The keeper mops up balls in behind so the trap can stay high.',
    NULL, 12, 12, 60)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'step up together to catch forwards offside'),
    (2, 'Goalkeeper (Seaman)', 'come off his line and clear balls played in behind')
) AS v(so, role, job);

-- 7. pp.12-12
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'set_piece', '1 A Whole New Ball Game', 'Keeper joins late attacking corners',
    'When United were chasing a result in the final minutes, Schmeichel ran up for corners. He pulled markers onto him and freed teammates in the box (equaliser against Blackburn, Boxing Day 1994).',
    'Losing or drawing in the dying minutes, attacking corner',
    'Add an extra aerial body and pull defenders away from other attackers.',
    NULL, 12, 12, 70)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Schmeichel)', 'charge into the box and attack the ball'),
    (2, 'Centre back (Pallister)', 'use the space the distracted markers leave'),
    (3, 'Midfielder (Ince)', 'follow up the knock-down')
) AS v(so, role, job);

-- 8. pp.12-13
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_attack', '1 A Whole New Ball Game', 'Keeper''s long throw starts the counter',
    'Schmeichel caught the ball and immediately threw it half the length of the pitch to fast wingers (Giggs, Kanchelskis, Sharpe) or a runner like Solskjaer, catching opponents before they could turn round.',
    'Keeper claims a cross, shot or loose ball',
    'Start a counter at once into the space behind opponents who are still pushed up.',
    NULL, 12, 13, 80)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Schmeichel)', 'release a quick, accurate long throw at once'),
    (2, 'Wingers (Giggs, Kanchelskis, Sharpe)', 'break wide and receive on the run'),
    (3, 'Forward (Cantona, Solskjaer)', 'run beyond the defence or link the play')
) AS v(so, role, job);

-- 9. pp.15-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '2 Cantona & Counters', 'Deep-lying forward between the lines',
    'Cantona played as a number 10 behind a traditional striker, turning United''s 4-4-2 into a 4-4-1-1. He dropped into the space between the opposition defence and midfield that neither centre backs nor central midfielders were set up to cover, held the ball and set up others.',
    'Opposition flat 4-4-2 with no one marking the space between the lines',
    'Give the side a free creator on the ball between the lines who links midfield, wingers and striker.',
    '4-4-2', 15, 16, 90)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Withdrawn forward (Cantona)', 'drop between the lines, receive, shield, play the killer pass'),
    (2, 'Centre forward (Hughes)', 'pin the centre backs'),
    (3, 'Wingers (Giggs, Kanchelskis)', 'provide width and run beyond')
) AS v(so, role, job);

-- 10. pp.16-16
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '2 Cantona & Counters', 'Free-role star excused from tracking',
    'Cantona had licence to roam wherever he liked and did little defending, so teammates such as Keane covered the extra running. English sides began to accept flair players freed from defensive jobs.',
    'Losing the ball / defensive phase',
    'Keep the creator fresh and high for the next transition while the others defend.',
    NULL, 16, 16, 100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free-role forward (Cantona)', 'stay available high and roam'),
    (2, 'Central midfielders (Keane, Ince)', 'do the extra defensive running and cover')
) AS v(so, role, job);

-- 11. pp.17-17
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '2 Cantona & Counters', 'Attacking full backs in a passing 4-4-2',
    'Mike Walker''s Norwich (1992/93) played passing football from a flexible 4-4-2, notable for pushing both full backs (Bowen, Culverhouse) high. A quick right winger, a passing central midfielder and a goalscoring striker completed the shape.',
    'Settled possession',
    'Build through passing and add width from full backs to beat route-one sides.',
    NULL, 17, 17, 110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (Bowen, Culverhouse)', 'push high to give width'),
    (2, 'Central midfielder (Crook)', 'spread passes'),
    (3, 'Right winger (Fox)', 'use pace on the flank'),
    (4, 'Striker (Robins)', 'finish')
) AS v(so, role, job);

-- 12. pp.17-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_attack', '2 Cantona & Counters', 'Wait, then break with multiple runners',
    'At Norwich in April 1993, United let the home side keep possession and push forward. Then they broke at speed into space with three wingers (Sharpe central) and Cantona waiting between the lines, scoring three times in 21 minutes.',
    'Ball regained when the opponent has committed men forward',
    'Score in a few seconds and few touches with several men breaking at once.',
    NULL, 17, 18, 120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Schmeichel)', 'throw quickly to a winger'),
    (2, 'Wingers (Sharpe, Giggs, Kanchelskis)', 'sprint forward together to beat the offside trap'),
    (3, 'Withdrawn forward (Cantona)', 'receive between the lines, pause for runners, slip the through ball'),
    (4, 'Central midfielder (Ince)', 'carry loose balls forward through the middle')
) AS v(so, role, job);

-- 13. pp.18-18
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '2 Cantona & Counters', '4-4-1-1: battlers inside, speedsters out wide',
    'United''s 1993/94 side (Keane and Ince inside, Giggs and Kanchelskis wide, Cantona behind the striker) looked like a 4-2-4 but was really a 4-4-1-1 close to a 4-2-3-1. It became the league''s template for a decade.',
    'Base shape',
    'Win the midfield battle and break fast down both flanks through a free 10.',
    NULL, 18, 18, 130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfield pair (Keane, Ince)', 'combative ball-winning and forward bursts'),
    (2, 'Wingers (Giggs left, Kanchelskis right)', 'pace and goal threat on the flanks'),
    (3, 'Number 10 (Cantona)', 'link between the lines')
) AS v(so, role, job);

-- 14. pp.20-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '3 The SAS & The Entertainers', 'Wingers to byline, crosses to two strikers',
    'Dalglish and Harford''s Blackburn (1994/95) played a simple 4-4-2. Touchline wingers (Ripley, Wilcox) dribbled to the byline and crossed for two box strikers, Shearer and Sutton (the SAS). Central midfielders recycled the ball wide rather than playing through balls.',
    'Ball to a winger with room to run at the full back',
    'Produce a constant supply of crosses for two strikers kept in the box.',
    NULL, 20, 21, 140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (Ripley, Wilcox)', 'hug the touchline, beat the full back, cross'),
    (2, 'Strikers (Shearer, Sutton)', 'both stay in the box to attack crosses'),
    (3, 'Central midfielders (Sherwood, Atkins/Batty)', 'one passes calmly wide, one protects the defence')
) AS v(so, role, job);

-- 15. pp.20-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '3 The SAS & The Entertainers', 'Winger comes short, striker drifts wide',
    'Blackburn''s second route: when the winger could not dribble forward, he came short and pulled the opposition full back up the pitch. A striker (often Shearer) then drifted wide into the space left behind and crossed.',
    'Winger marked tightly with no room to go forward',
    'Open the channel behind the full back for a striker to run into and cross.',
    NULL, 20, 21, 150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger', 'come towards the ball and drag the full back out'),
    (2, 'Striker (Shearer)', 'drift into the vacated channel and cross'),
    (3, 'Other striker (Sutton)', 'attack the box')
) AS v(so, role, job);

-- 16. pp.20-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '3 The SAS & The Entertainers', 'Big man knocks down for the finisher',
    'Blackburn''s opening goals often came from a long ball or cross headed down by Sutton for Shearer to strike (Southampton, Everton). Earlier, Newell played a deeper link role that drew a marker and left Shearer more room.',
    'Long pass or cross into the box',
    'Turn aerial balls into close-range chances for the main scorer.',
    NULL, 20, 21, 160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target striker (Sutton)', 'win the header and nod it down'),
    (2, 'Finisher (Shearer)', 'attack the knock-down'),
    (3, 'Supporting striker (Newell)', 'drop off to link and pull a defender out')
) AS v(so, role, job);

-- 17. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '3 The SAS & The Entertainers', 'Overlapping full back in matched 4-4-2',
    'In 4-4-2 against 4-4-2 the full backs had the most time on the ball, so Blackburn pushed left back Le Saux forward to combine with Wilcox and Shearer. Right back Berg, a converted centre back, stayed home.',
    'Mirrored 4-4-2 leaves the full back unpressed',
    'Use the free full back as a crosser and extra wide man.',
    '4-4-2', 21, 21, 170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking full back (Le Saux)', 'overlap and supply crosses'),
    (2, 'Defensive full back (Berg)', 'stay back to balance'),
    (3, 'Left winger (Wilcox)', 'combine with the overlapping full back')
) AS v(so, role, job);

-- 18. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '3 The SAS & The Entertainers', 'Cross from the magic box',
    'Harford insisted crosses come from the ''magic box'': the last 18 yards stretched across the full width of the pitch. Crosses from that advanced position produced better chances than early ones from deep.',
    'Winger or full back in a crossing position',
    'Only deliver crosses from advanced wide areas level with the penalty box.',
    NULL, 21, 21, 180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (Ripley, Wilcox)', 'get into the wide zone level with the box before crossing'),
    (2, 'Strikers', 'attack near and far post')
) AS v(so, role, job);

-- 19. pp.21-21
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '3 The SAS & The Entertainers', 'Sit deep, double up on wingers',
    'Part-timers Trelleborg knocked Blackburn out of the UEFA Cup by defending deeper than any league opponent and putting two players on each winger, which shut off the crossing supply.',
    'Facing a crossing-dependent 4-4-2',
    'Stop crosses at source by doubling up on the wide men.',
    '4-4-2', 21, 21, 190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'show the winger away from the byline'),
    (2, 'Wide midfielder', 'drop back to double up on the winger'),
    (3, 'Back line', 'sit deep so there is no space in behind')
) AS v(so, role, job);

-- 20. pp.22-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '3 The SAS & The Entertainers', 'All-out attack: crossers, link and runner',
    'Keegan''s Newcastle (1995/96): Ginola (left) and Gillespie (right) crossed constantly for Ferdinand. Beardsley linked from a deep-lying forward role, Rob Lee burst from midfield, and both full backs pushed on at the same time.',
    'Settled possession',
    'Overwhelm opponents with numbers and crosses, accepting defensive exposure.',
    NULL, 22, 23, 200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (Ginola, Gillespie)', 'beat the full back and cross'),
    (2, 'Target striker (Ferdinand)', 'attack crosses, bring others in'),
    (3, 'Deep-lying forward (Beardsley)', 'drop to link attacks'),
    (4, 'Box-to-box midfielder (Lee)', 'burst forward late'),
    (5, 'Full backs (Barton, Beresford)', 'both push on together')
) AS v(so, role, job);

-- 21. pp.23-23
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '3 The SAS & The Entertainers', 'Winger won''t track the overlap',
    'Newcastle''s free wingers did not track back. When Keegan told Beresford to defend narrow against Villa''s three forwards, Villa''s right back overlapped into the space Ginola had left. The general lesson is that a free winger leaves his full back facing two.',
    'Opposition full back overlaps on the side of a non-tracking winger',
    'Shows the cost: a 2v1 on the flank and repeated crosses conceded.',
    NULL, 23, 23, 210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Winger (Ginola)', 'should track the overlapping full back (did not)'),
    (2, 'Full back (Beresford)', 'left choosing between the narrow striker and the overlap')
) AS v(so, role, job);

-- 22. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '3 The SAS & The Entertainers', 'Sweeper centre back bursts forward',
    'In a brief 3-5-2 switch, Newcastle used Philippe Albert as a sweeper with licence to stride forward from the back. Against Manchester City he scored twice and set up another from open play.',
    'Spare man at the back has space in front',
    'Add a surprise extra midfielder or attacker from centre back.',
    NULL, 24, 24, 220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Sweeper (Albert)', 'carry the ball out and join attacks'),
    (2, 'Two other centre backs', 'cover behind him')
) AS v(so, role, job);

-- 23. pp.24-24
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_attack', '3 The SAS & The Entertainers', 'Winger stays high behind the wing back',
    'In Newcastle''s 4-4-2 against Liverpool''s 3-5-2 (4-3, April 1996), Ginola did not track wing back McAteer. He stayed high and broke onto the open flank on the counter, but Liverpool used the space behind him for crosses.',
    'Ball won while the opposition wing back is advanced',
    'A free outlet behind the wing back for counters, traded for space conceded on that flank.',
    '3-5-2', 24, 24, 230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left winger (Ginola)', 'hold position high behind the wing back and break'),
    (2, 'Opposition wing back (McAteer)', 'left free to cross when Liverpool attack'),
    (3, 'Opposition drifting forward (McManaman)', 'move into the space behind the winger')
) AS v(so, role, job);

-- 24. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '4 Between the Lines', 'Number 10 against a flat back four',
    'English sides played a flat back four with no libero, two centre backs against two strikers. Neither centre back could step out to a forward dropping between the lines without exposing the other, so foreign 10s (Bergkamp, Zola) found time there.',
    'Opponent flat back four marking two strikers',
    'Receive and turn between the lines unopposed.',
    '4-4-2', 28, 28, 240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 10 (Bergkamp, Zola)', 'drop between the lines, receive and turn'),
    (2, 'Striker', 'occupy both centre backs')
) AS v(so, role, job);

-- 25. pp.28-28
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '4 Between the Lines', 'Drag a centre back, attack his space',
    'Zola (1997 FA Cup semi-final against Wimbledon) watched Di Matteo move between the lines and pull a centre back up. Zola sprinted into the gap, which drew the other centre back across, then took the pass and backheeled into the zone that second defender had left.',
    'Teammate between the lines draws a centre back forward',
    'Chain movements to create and exploit successive gaps in the back line.',
    NULL, 28, 28, 250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielder between the lines (Di Matteo)', 'move into the pocket to drag a centre back out, then pass'),
    (2, 'Free-role forward (Zola)', 'sprint into the vacated gap, receive, turn into the next gap')
) AS v(so, role, job);

-- 26. pp.28-30
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '4 Between the Lines', 'Man-mark the playmaker',
    'Opponents put one man on a creator wherever he went: Phil Neville on Zola, Kamark on Juninho in the 1997 League Cup final. It often worked, because those sides had no plan B, but it could open a flank (Chelsea''s two right backs crossed into the space Neville left).',
    'Opposition built entirely around one number 10',
    'Take the playmaker out of the game, accepting a gap where the marker would have stood.',
    NULL, 28, 30, 260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Man-marker (P. Neville, Kamark)', 'follow the playmaker everywhere'),
    (2, 'Rest of team', 'cover the zone the marker leaves')
) AS v(so, role, job);

-- 27. pp.29-33
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '4 Between the Lines', 'System bent around a free 10',
    'Middlesbrough (Juninho), Manchester City (Kinkladze) and Southampton (Le Tissier) built around one roaming creator, trying 4-3-2-1, 3-4-2-1 or 4-3-1-2 shapes. The creator drifted across the front and played through balls. A 10 who will not track runners costs goals and unbalances midfield, and the shape changes confused teammates.',
    'Ball to the playmaker anywhere in the final third',
    'Maximise the star''s touches, accepting defensive holes when he doesn''t track.',
    NULL, 29, 33, 270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free number 10 (Juninho, Kinkladze, Le Tissier)', 'drift to the ball and play through balls or dribble'),
    (2, 'Strikers', 'run channels for through balls'),
    (3, 'Midfield runners', 'cover the 10''s defensive duties')
) AS v(so, role, job);

-- 28. pp.32-32
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '4 Between the Lines', 'Two 10s behind one striker',
    'Hoddle''s England (against Italy, 1997) used a fluid 3-4-2-1 with Le Tissier and McManaman both behind Shearer.',
    'Settled possession',
    'Put two creators in the half-spaces behind the striker.',
    NULL, 32, 32, 280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two attacking midfielders (Le Tissier, McManaman)', 'operate between the lines behind the striker'),
    (2, 'Lone striker (Shearer)', 'lead the line and finish')
) AS v(so, role, job);

-- 29. pp.34-34
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '5 Arsenal', 'Graham''s offside trap and team press',
    'George Graham''s Arsenal won the ball back by pressing as a unit, denying space and stepping up together for offsides, behind a famously organised back four.',
    'Opposition building play or playing forward',
    'Squeeze the space, win the ball or catch attackers offside.',
    NULL, 34, 34, 290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four (Adams, Bould, Keown, Dixon, Winterburn)', 'step up in a line to spring the offside trap'),
    (2, 'Midfield and forwards', 'press together to deny space')
) AS v(so, role, job);

-- 30. pp.34-35
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '5 Arsenal', 'Pass through midfield to the 10',
    'Rioch (1995/96) moved Arsenal away from long balls over the top for Wright. Keepers and defenders played out from the back and passed through midfield into Bergkamp between the lines, who became more creator than scorer.',
    'Possession in own half',
    'Build on the ground through midfield to the creator instead of relying on the striker chasing long balls.',
    NULL, 34, 35, 300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper and centre backs', 'play out short'),
    (2, 'Central midfielders (Platt, Merson)', 'pass through midfield'),
    (3, 'Number 10 (Bergkamp)', 'receive between the lines and assist')
) AS v(so, role, job);

-- 31. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '5 Arsenal', '3-5-2 against 4-4-2',
    'In the mid-1990s the 3-5-2 was popular because it gave a spare centre back against two strikers and an extra central midfielder. Wing backs covered the whole flank, giving width and dropping to make a back five. Two 3-5-2 sides facing each other produced dull games with spare men at the back and a jammed midfield.',
    'Opponent plays a 4-4-2 with two centre forwards',
    'Free man at the back plus a central overload in midfield.',
    '4-4-2', 38, 38, 310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three centre backs (Adams, Bould, Keown)', 'two mark the strikers, one spare'),
    (2, 'Wing backs', 'provide width and drop to a back five'),
    (3, 'Central midfield three', 'outnumber the opponent''s midfield pair')
) AS v(so, role, job);

-- 32. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '5 Arsenal', 'Holding pair sits deeper to shield',
    'After a poor first half of 1997/98, Arsenal''s senior defenders asked for Petit and Vieira to sit deeper in front of the back four rather than press high. The defence then went 13 hours without conceding.',
    'Defence exposed by midfielders pressing too high',
    'Protect the back four with a screen of two defensive midfielders.',
    NULL, 38, 38, 320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive midfielders (Petit, Vieira)', 'hold position just in front of the centre backs'),
    (2, 'Centre backs (Adams, Bould)', 'rely on the screen and hold the line')
) AS v(so, role, job);

-- 33. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '5 Arsenal', 'Lopsided 4-4-2: wide runner, tucked shuttler',
    'Wenger''s 1997/98 4-4-2 was asymmetric. Overmars pushed high down the left as a goal threat, Parlour played narrow and shuttled on the right, and Petit slid across to cover. In attack it looked like a lopsided 4-3-3, later called a 4-2-3-1.',
    'Attacking phase',
    'Free one fast winger to attack while the other side keeps balance.',
    NULL, 38, 38, 330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Attacking left winger (Overmars)', 'push forward and run in behind'),
    (2, 'Right midfielder (Parlour)', 'tuck inside and shuttle'),
    (3, 'Left-sided holder (Petit)', 'shift across to cover Overmars'' flank'),
    (4, 'Holding midfielder (Vieira)', 'anchor, surge forward occasionally')
) AS v(so, role, job);

-- 34. pp.38-38
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '5 Arsenal', 'Through balls and flick-ons for a fast winger',
    'Against United (March 1998), almost all of Arsenal''s attacks went through Overmars running behind a young right back. Bergkamp played through balls, and Bergkamp and Anelka flicked on long balls for Overmars to race onto.',
    'Weak or slow full back facing the fast winger',
    'Isolate the winger against the weakest defender and feed runs in behind.',
    NULL, 38, 38, 340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Fast winger (Overmars)', 'attack the space behind the full back'),
    (2, 'Number 10 (Bergkamp)', 'slide through balls'),
    (3, 'Strikers (Bergkamp, Anelka)', 'flick long balls into the winger''s path')
) AS v(so, role, job);

-- 35. pp.40-40
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '6 Speed', 'Sprinter striker runs in behind',
    'Deep creative forwards needed strikers who could sprint in behind to reach through balls between defenders, so speed replaced aerial power up front. Anelka and Owen ran past slow, header-built centre backs, e.g. Anelka running onto a long chip from Winterburn. Continues past spread 40.',
    'Playmaker or full back has time to play over or through the back line',
    'Turn space behind the defence into one-on-ones with the keeper.',
    NULL, 40, 40, 350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Quick striker (Anelka, Owen)', 'time the run in behind and finish one-on-one'),
    (2, 'Creator / full back (Bergkamp, Winterburn)', 'play the through ball or chip over the line')
) AS v(so, role, job);

-- 36. pp.41-41
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '6 Speed', 'Link forward plus runner strike pair',
    'Arsenal paired a deep, creative forward (Bergkamp) with a runner (Anelka) who always went forward, so the link man always knew where the run would be.',
    'Link forward receives between the lines facing play',
    'Stretch the defence in different directions and feed the runner in behind.',
    NULL, 41, 41, 360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep-lying forward (Bergkamp)', 'Drop into own half / between lines, turn, check the run and lob or slide the pass'),
    (2, 'Running forward (Anelka)', 'Run diagonally into the inside channel ahead of the ball'),
    (3, 'Onrushing midfielder (Parlour)', 'Arrive late for the second wave of passes')
) AS v(so, role, job);

-- 37. pp.41-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '6 Speed', 'Sprinter striker runs in behind high line',
    'Late-1990s defences still squeezed high to keep aerial strikers away from goal, leaving big space behind for quick forwards like Owen and Anelka.',
    'Opponent back line stepping up high',
    'Through-ball or chip into the channel for a one-v-one with the keeper.',
    NULL, 41, 44, 370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Pace striker (Owen, Anelka)', 'Start on the last man''s shoulder, sprint into the channel, finish early'),
    (2, 'Passer (Bergkamp, Gerrard, Bjornebye)', 'Look up the moment the striker breaks and play the ball into the space behind')
) AS v(so, role, job);

-- 38. pp.41-44
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '6 Speed', 'Deep line to neutralise quick strikers',
    'As pace replaced aerial power as the striker''s weapon, defences (especially relegation sides) dropped deeper and recruited faster defenders, and keepers swept proactively.',
    'Facing a quick striker',
    'Remove the space in behind so speed cannot be used.',
    NULL, 41, 44, 380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Hold a deeper starting line, deny space behind'),
    (2, 'Goalkeeper', 'Sweep up through-balls proactively')
) AS v(so, role, job);

-- 39. pp.42-43
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '6 Speed', 'Force striker onto weaker foot',
    'Defenders worked out Owen was almost purely right-footed; Stam''s primary approach was to show him onto his left.',
    'One-footed striker receiving',
    'Make the chance harder by forcing the shot onto the weak side.',
    NULL, 42, 43, 390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Marking centre-back (Stam)', 'Body shape to block the strong side and show him onto his weaker foot')
) AS v(so, role, job);

-- 40. pp.46-46
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '7 Euro Progress & Squad Rotation', 'Strike pair dummy and one-two',
    'Yorke dropped deep between the lines while Cole stayed higher; their understanding produced quick combinations around the box (e.g. Cole''s goal at the Camp Nou).',
    'Ball played into the dropping forward',
    'Beat the centre-backs with a dummy or wall pass.',
    NULL, 46, 46, 400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Dropping forward (Yorke)', 'Come short, dummy or lay off first time'),
    (2, 'Higher forward (Cole)', 'Take the ball on, play the one-two and finish')
) AS v(so, role, job);

-- 41. pp.46-47
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '7 Euro Progress & Squad Rotation', 'Balanced 4-4-2 quartet and flank pairs',
    'Ferguson''s 1998/99 United: a crosser, a tackler, a passer and a dribbler across midfield, with each flank pairing set by the winger''s style.',
    'Ball to a wide player',
    'Constant crossing supply while keeping central balance.',
    NULL, 46, 47, 410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfield (Beckham)', 'Play narrower, deep, deliver early crosses'),
    (2, 'Right-back (G. Neville)', 'Overlap outside the narrow winger into crossing positions'),
    (3, 'Left midfield (Giggs)', 'Dribble at the full-back'),
    (4, 'Left-back (Irwin)', 'Overlap less, hold a more reserved position behind the dribbler'),
    (5, 'Holding midfield (Keane)', 'Sit deeper and spray passes wide'),
    (6, 'Advanced midfield (Scholes)', 'Push on and break into the box')
) AS v(so, role, job);

-- 42. pp.47-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '7 Euro Progress & Squad Rotation', 'Midfield triangles to keep the ball',
    'Ferguson learned from European defeats that top sides keep possession in small triangles and one-twos in midfield, unlike English mids who simply fed wide players.',
    'Possession in central midfield',
    'Retain the ball because in Europe it is hard to win back.',
    NULL, 47, 48, 420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Form short triangles, play one-twos rather than forcing it wide'),
    (2, 'Wide players and front men', 'Offer support angles instead of waiting for early service')
) AS v(so, role, job);

-- 43. pp.48-48
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '7 Euro Progress & Squad Rotation', 'Diamond with winger tucked inside',
    'Before 1998/99 Ferguson used a diamond against Porto with Giggs tucking in, and experimented with a single striker and three-man defences for Europe.',
    'European tie needing midfield control',
    'Extra central body to dominate possession.',
    NULL, 48, 48, 430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide-turned-central player (Giggs)', 'Tuck inside from the left into the diamond'),
    (2, 'Lone/front striker', 'Hold up play with fewer partners')
) AS v(so, role, job);

-- 44. pp.48-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '7 Euro Progress & Squad Rotation', 'Man-mark the opposition number 10',
    'United assigned a disciplined player to follow the playmaker: Keane on Kuhbauer, Johnsen on Okocha and on Zidane in the 3-2 win over Juventus.',
    'Opponent fields a free-roaming number 10',
    'Take the playmaker out of the game.',
    NULL, 48, 49, 440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Designated marker (Keane, Johnsen)', 'Stay tight to the opposition 10 wherever he goes'),
    (2, 'Rest of midfield', 'Keep zonal shape around the marker')
) AS v(so, role, job);

-- 45. pp.49-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '7 Euro Progress & Squad Rotation', 'Rotating markers on a dangerous winger',
    'Against Tottenham, with Neville sent off for fouling Ginola, Ferguson switched the man tasked with marking him (Keane, Johnsen, Berg, P. Neville) to avoid further cards.',
    'Marker booked or tiring against a key dribbler',
    'Keep the danger man shepherded into harmless areas without losing a player.',
    NULL, 49, 49, 450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Current marker', 'Shadow the winger, push him away from goal'),
    (2, 'Next marker', 'Take over the job when switched, fresh and unbooked')
) AS v(so, role, job);

-- 46. pp.49-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '7 Euro Progress & Squad Rotation', 'Narrow full-backs on two tens',
    'Against Inter''s 3-4-2-1 with two players floating behind Zamorano, United''s full-backs tucked in to pick up the two 10s.',
    'Opponent tens drifting into the half-spaces',
    'Protect the centre while keeping the back line intact.',
    '3-4-2-1', 49, 49, 460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full-backs (G. Neville, Irwin)', 'Play very narrow and mark the nearest 10'),
    (2, 'Centre-backs', 'Handle the lone striker')
) AS v(so, role, job);

-- 47. pp.49-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '7 Euro Progress & Squad Rotation', 'Attack outside the back three',
    'Same Inter tie: the space between wing-back and wide centre-back was open, so United''s winger pushed into it and crossed for the strikers.',
    'Ball to the wide midfielder',
    'Cross from the channel outside the back three for headers.',
    '3-4-2-1', 49, 49, 470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfield (Beckham)', 'Run into the gap between wing-back and wide centre-back, cross'),
    (2, 'Strikers (Yorke, Cole)', 'Attack the cross in the box')
) AS v(so, role, job);

-- 48. pp.49-49
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '7 Euro Progress & Squad Rotation', 'Double screen frees full-backs',
    'In the return leg Ferguson put Johnsen beside Keane to screen Inter''s 10s, so the full-backs no longer had to tuck in and could take the ball and control the game.',
    'Opponent tens operating in front of the back four',
    'Kill the 10s centrally and gain time on the ball wide.',
    '3-4-2-1', 49, 49, 480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two holding midfielders (Keane, Johnsen)', 'Sit in front of the defence and pick up the 10s'),
    (2, 'Full-backs (G. Neville, Irwin)', 'Stay wide, receive and dictate tempo')
) AS v(so, role, job);

-- 49. pp.49-50
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '7 Euro Progress & Squad Rotation', 'Winger tucks in vs diamond',
    'Juventus''s diamond (Deschamps deep, Conte and Davids shuttling, Zidane at the tip) overran Keane and Scholes; at the break Beckham moved inside as a third central man and Neville pushed on for width.',
    'Two central midfielders outnumbered by a diamond',
    'Match numbers in midfield, regain control and build pressure.',
    '4-3-1-2', 49, 50, 490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfield (Beckham)', 'Move inside to become the third central midfielder'),
    (2, 'Right-back (G. Neville)', 'Push forward to supply right-sided width'),
    (3, 'Central pair (Keane, Scholes)', 'Stop being dragged around by the 10')
) AS v(so, role, job);

-- 50. pp.50-51
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '7 Euro Progress & Squad Rotation', 'Targeted substitutes exploit weak defender',
    'Ferguson brought fresh forwards on for specific jobs: Cole at half-time to run at a centre-back just back from injury, Giggs late against an ageing Arsenal defence, Solskjaer studying weaknesses from the bench.',
    'Tired or slow opponent defender identified',
    'Late goals by putting pace or trickery directly against the weak link.',
    NULL, 50, 51, 500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Substitute forward (Cole, Solskjaer, Sheringham)', 'Attack the identified defender immediately'),
    (2, 'Wide supplier (Beckham)', 'Deliver crosses toward the fresh striker')
) AS v(so, role, job);

-- 51. pp.54-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '8 The Foreign Revolution', 'Ball-playing centre-back carries forward',
    'Foreign centre-backs (Albert, Popescu) were comfortable stepping out of defence with the ball, joining attacks and even popping up as a striker.',
    'Space ahead of the centre-back',
    'Add an unmarked attacker from deep.',
    NULL, 54, 54, 510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-back (Albert, Popescu)', 'Dribble into midfield, combine, shoot'),
    (2, 'Midfield partner', 'Cover the vacated centre-back spot')
) AS v(so, role, job);

-- 52. pp.54-54
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '8 The Foreign Revolution', 'Deep playmaker long diagonal switches',
    'Deep-lying playmakers such as Emerson at Middlesbrough spread the ball to the flanks with long diagonals, rare in 1990s England.',
    'Deep midfielder receives with time',
    'Switch play quickly to an open flank.',
    NULL, 54, 54, 520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep-lying playmaker (Emerson)', 'Receive deep, hit long diagonal passes to the far flank'),
    (2, 'Far-side winger / full-back', 'Hold width to receive the switch')
) AS v(so, role, job);

-- 53. pp.54-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '8 The Foreign Revolution', 'Libero steps into midfield',
    'Gullit as Chelsea''s sweeper received from the keeper, carried forward, played a one-two and arrived between the lines as a 10, while a midfielder dropped to cover.',
    'Sweeper receives at the back unpressed',
    'Create an extra midfielder and break lines from defence.',
    NULL, 54, 55, 530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Sweeper (Gullit)', 'Carry out from the back, wall pass, push into the space between lines'),
    (2, 'Covering midfielder (Spackman, ''Van de Kerkhof role'')', 'Drop into the back line to cover the sweeper''s run')
) AS v(so, role, job);

-- 54. pp.55-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '8 The Foreign Revolution', 'Aggressive offside trap vs long ball',
    'Gullit''s Chelsea used a very aggressive offside trap in the 1997 FA Cup semi-final to disrupt Wimbledon''s long-ball game.',
    'Opponent about to launch a long ball',
    'Catch target men and runners offside, nullify direct play.',
    NULL, 55, 55, 540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back line', 'Step up together as the long ball is struck'),
    (2, 'Midfield', 'Pressure the passer so the ball is hit early')
) AS v(so, role, job);

-- 55. pp.55-55
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '8 The Foreign Revolution', 'Chasing a game in 3-3-1-3',
    'Two down at half-time against Liverpool, Gullit brought on a striker for a full-back and went to a radical 3-3-1-3; Chelsea won 4-2.',
    'Trailing at half-time',
    'Flood the front line to overturn the deficit.',
    NULL, 55, 55, 550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Extra striker (Hughes)', 'Join the front three'),
    (2, 'Back three', 'Defend the width left by removing a full-back')
) AS v(so, role, job);

-- 56. pp.57-59
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '9 Big Sam & Long Balls', 'Route one into the box',
    'Allardyce''s Bolton played little out from the back: keeper boots it to the strikers, free-kicks launched into the box, long throws used often on a pitch set to minimum size.',
    'Goal-kick, free-kick or throw-in',
    'Get the ball into the danger area quickly and fight for it there.',
    NULL, 57, 59, 560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Jaaskelainen)', 'Kick long to the target man'),
    (2, 'Target man (Davies)', 'Win the first header and flick on'),
    (3, 'Long-throw taker', 'Throw into the six-yard area')
) AS v(so, role, job);

-- 57. pp.59-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '9 Big Sam & Long Balls', 'Second-ball hunters around flick-ons',
    'Bolton''s game was built on reaching the second ball: Nolan latched onto knock-downs and flick-ons, while runners like Giannakopoulos arrived unmarked.',
    'Target man contesting a high ball',
    'Convert knock-downs from close range.',
    NULL, 59, 60, 570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target man (Davies)', 'Nod the ball down toward the runners'),
    (2, 'Second-ball midfielder (Nolan)', 'Position close to the flick-on, attack the loose ball'),
    (3, 'Arriving midfielder (Giannakopoulos, Speed)', 'Time runs into the box unmarked')
) AS v(so, role, job);

-- 58. pp.60-60
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '9 Big Sam & Long Balls', '4-5-1 with wide target man',
    'From 2003/04 Bolton used 4-5-1, placing a second striker out wide (a Taylor/Olsen idea) to give two aerial targets plus a numerical edge in central midfield.',
    'Long ball toward the flank',
    'Win headers on the weaker full-back while outnumbering a two-man midfield.',
    NULL, 60, 60, 580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide forward (Davies)', 'Play wide right as an aerial outlet'),
    (2, 'Lone striker', 'Second aerial target centrally'),
    (3, 'Three central midfielders', 'Outnumber the opposition and collect knock-downs')
) AS v(so, role, job);

-- 59. pp.60-62
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '9 Big Sam & Long Balls', 'Stop-start game and deny skill time',
    'Bolton studied how to stop skilful sides having a second on the ball, making matches a scrappy stop-start contest around dead balls (Davies most fouls in aerial duels).',
    'Technical opponent in possession',
    'Break rhythm and pull the game toward set pieces.',
    NULL, 60, 62, 590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfielders (Nolan)', 'Close down skilful players instantly, physical challenges'),
    (2, 'Target man (Davies)', 'Contest every high ball, win free-kicks')
) AS v(so, role, job);

-- 60. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'set_piece', '9 Big Sam & Long Balls', 'Passive offside players at free-kicks',
    'After the 2003/04 offside tweak, Bolton put two players in offside positions at free-kicks who drop back to latch onto the second ball from positions defenders cannot mark.',
    'Attacking free-kick into the box',
    'Unmarked runners onto loose balls and scrambles.',
    NULL, 61, 61, 600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two ''passive offside'' players (Nolan)', 'Stand offside, ignore the first ball, run back onside onto the knock-down'),
    (2, 'Free-kick taker', 'Deliver into the crowded area')
) AS v(so, role, job);

-- 61. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'set_piece', '9 Big Sam & Long Balls', 'Block the keeper at free-kicks',
    'From 2005/06 Bolton stood a player (Nolan) face to face with the goalkeeper at set pieces, moving with him to block his view.',
    'Free-kick or corner delivery',
    'Stop the keeper claiming and create confusion.',
    NULL, 61, 61, 610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Keeper blocker (Nolan)', 'Stand in front of the goalkeeper and track his movement')
) AS v(so, role, job);

-- 62. pp.61-61
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '9 Big Sam & Long Balls', 'Aerial bombardment of keeper and full-back',
    'Against Arsenal Bolton targeted a shaky keeper (Almunia) with relentless high balls and a weak or out-of-position left-back (Cygan, Senderos) with diagonals.',
    'Scouted aerial weakness',
    'Win headers and second balls in the weakest zone.',
    NULL, 61, 61, 620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper', 'Kick long to the targeted zone'),
    (2, 'Target forward (Davies, Giannakopoulos)', 'Attack the weak defender in the air'),
    (3, 'Wide player (Diouf)', 'Cross after second-ball wins')
) AS v(so, role, job);

-- 63. pp.64-65
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '10 One Up Front', '4-5-1 to win the midfield battle',
    'After European defeats by sides using 4-3-3 and a diamond, Ferguson went to 4-5-1 with three central midfielders (Veron beside Keane and Scholes) and Van Nistelrooy alone up front.',
    'Facing technically stronger midfields',
    'Keep possession and stay solid centrally.',
    NULL, 64, 65, 630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lone striker (Van Nistelrooy)', 'Play alone up front, finish in the box'),
    (2, 'Three central midfielders (Keane, Scholes, Veron)', 'Outnumber the opposition and circulate'),
    (3, 'Wingers', 'One on each flank for width')
) AS v(so, role, job);

-- 64. pp.65-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '10 One Up Front', 'Penalty-box poacher lone striker',
    'Van Nistelrooy rarely chased the ball, waited for it, and lived on rebounds, crosses and cushioned first touches inside the box (all but one goal from inside the area).',
    'Cross or loose ball in the box',
    'Convert close-range chances.',
    NULL, 65, 68, 640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Poacher (Van Nistelrooy)', 'Stay in the box, read rebounds, cushion and finish'),
    (2, 'Wide crosser (Beckham)', 'Deliver early crosses for the poacher')
) AS v(so, role, job);

-- 65. pp.66-66
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_defend', '10 One Up Front', 'Star forward leads the counter-press',
    'Around 2003/04, after losing possession Henry chased hard to win it back, closing down two or three opponents alone and setting the example for team-mates.',
    'Forward loses the ball',
    'Start defensive pressure high and immediately.',
    NULL, 66, 66, 650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-forward (Henry)', 'Chase the ball carrier immediately and close down nearby passers'),
    (2, 'Team-mates', 'Follow the lead and press behind him')
) AS v(so, role, job);

-- 66. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '10 One Up Front', 'Forward drifts left and cuts inside',
    'Henry habitually took up positions outside the right-back, received near the touchline, cut inside and bent the ball into the far corner.',
    'Ball into the left channel',
    'Shot curled across the keeper from the left inside channel.',
    NULL, 67, 67, 660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-forward (Henry)', 'Drift to the left, receive wide, cut inside onto the right foot'),
    (2, 'Left midfield (Pires)', 'Move inside or combine as Henry takes the flank')
) AS v(so, role, job);

-- 67. pp.67-67
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '10 One Up Front', 'Pin the opposing full-back',
    'Henry''s wide positioning forced Ferguson to keep Gary Neville at home at all times, killing United''s right-sided overlap.',
    'Opponent full-back likes to attack',
    'Turn the opposing full-back into a pure defender.',
    NULL, 67, 67, 670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide-drifting striker (Henry)', 'Stay high and wide on the full-back''s side'),
    (2, 'Opposition full-back', 'Forced to stay back and mark')
) AS v(so, role, job);

-- 68. pp.67-68
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '10 One Up Front', 'Strikerless 4-4-2 (effectively 4-2-3-1)',
    'Arsenal''s 4-4-2 had no true number 9: Bergkamp dropped into the hole, Henry drifted left, so centre-backs had no one to mark and the wide midfielders became goalscorers.',
    'Settled possession',
    'Pull centre-backs out and let wide mids arrive in the box.',
    NULL, 67, 68, 680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Withdrawn forward (Bergkamp)', 'Drop between the lines, slide through-balls'),
    (2, 'Left-sided striker (Henry)', 'Drift left, quick one-twos with Pires'),
    (3, 'Left midfield (Pires)', 'Combine with Henry and move inside to score'),
    (4, 'Right midfield (Ljungberg)', 'Make darting runs from deep onto Bergkamp''s passes')
) AS v(so, role, job);

-- 69. pp.70-70
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '11 Invincibles & Convincibles', 'Old-school back four offside trap',
    'Graham''s Arsenal back four (Dixon, Keown/Bould, Adams, Winterburn) were tight markers and a cohesive unit at catching opponents offside.',
    'Opponent pass toward forwards',
    'Step up as one to play forwards offside.',
    NULL, 70, 70, 690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Move up in unison, tight marking')
) AS v(so, role, job);

-- 70. pp.70-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '11 Invincibles & Convincibles', 'Recovery-pace defending',
    'The Invincibles'' back line (Toure, Campbell, Lauren, Cole) relied on speed to catch up with forwards who got beyond them, rather than the old back four''s tight marking and offside trap.',
    'Striker breaks beyond the line',
    'Recover and win the ball back through pace and power.',
    NULL, 70, 71, 700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-backs (Toure, Campbell)', 'Track runners and catch up physically'),
    (2, 'Full-backs', 'Recover at pace after attacking')
) AS v(so, role, job);

-- 71. pp.71-71
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '11 Invincibles & Convincibles', 'Attacking full-backs vs 4-4-2',
    'With wide midfielders dropping alongside their midfield in a 4-4-2, full-backs had the most space; Arsenal used converted attackers (Cole, Lauren) to push on.',
    'Opposition wingers drop deep',
    'Full-backs become key attacking outlets.',
    '4-4-2', 71, 71, 710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left-back (A. Cole)', 'Bomb forward into the space ahead'),
    (2, 'Right-back (Lauren)', 'Push on, use midfielder''s passing'),
    (3, 'Holding midfielder (Gilberto)', 'Cover space left by full-backs')
) AS v(so, role, job);

-- 72. pp.72-72
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '11 Invincibles & Convincibles', 'Ball-carrying centre-back adds midfielder',
    'Ferdinand liked to dribble forward from defence; an extra body in midfield leaves the opposition unsure who to pick up.',
    'Centre-back unmarked with space ahead',
    'Create an overload in midfield.',
    NULL, 72, 72, 720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball-carrying centre-back (Ferdinand)', 'Carry into midfield calmly'),
    (2, 'Partner centre-back', 'Hold position to cover')
) AS v(so, role, job);

-- 73. pp.74-74
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '11 Invincibles & Convincibles', 'Deep line hides lack of pace',
    'Late in his career Ferdinand (with Vidic) sat back protecting space behind rather than stepping up to close down Messi in the 2009 final; at Newcastle he dropped miles behind the line.',
    'Facing quick attackers',
    'Protect space behind, but concedes space between the lines.',
    NULL, 74, 74, 730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-backs (Ferdinand, Vidic)', 'Drop off rather than step out'),
    (2, 'Quicker partner (Evans, Smalling)', 'Paired to cover the slower centre-back')
) AS v(so, role, job);

-- 74. pp.76-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '12 The Makelele Role', 'Box-to-box star needs a sitting partner',
    'Vieira played best next to Petit or Gilberto, Keane next to Ince or Butt: a disciplined holding midfielder let the combative captain charge forward.',
    'Midfield pair set-up',
    'Balance attack and protection in a two-man midfield.',
    NULL, 76, 77, 740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Box-to-box midfielder (Vieira, Keane)', 'Push forward and attack'),
    (2, 'Holding partner (Gilberto, Petit, Butt)', 'Stay in front of the defence')
) AS v(so, role, job);

-- 75. pp.77-77
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '12 The Makelele Role', 'Holding mid covers attacking full-back',
    'At Real Madrid Makelele was usually paired with another disciplined midfielder, and sometimes the left-sided player drifted wide to cover Roberto Carlos''s forward runs.',
    'Full-back bombs forward',
    'Keep the back line protected despite the full-back''s absence.',
    NULL, 77, 77, 750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Makelele)', 'Sit and screen the centre-backs'),
    (2, 'Left-sided midfielder (Solari)', 'Drift wide to cover the full-back''s space')
) AS v(so, role, job);

-- 76. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '12 The Makelele Role', 'Makelele triangle beats flat 4-4-2',
    'Mourinho''s 4-3-3 had Makelele sitting behind two midfielders; against a flat 4-4-2 nobody picks him up, and if he is closed one of the other mids or a wide player is free.',
    'Opponent central pair side by side',
    'Always have a spare man in midfield.',
    '4-4-2', 78, 78, 760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Makelele)', 'Sit between the opposition lines, receive and pass simply'),
    (2, 'Two advanced central mids (Lampard)', 'Take free space when Makelele is closed'),
    (3, 'Wingers / full-backs', 'Exploit the flank space when opposing wingers tuck in')
) AS v(so, role, job);

-- 77. pp.78-78
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '12 The Makelele Role', 'Lopsided 4-4-2 with tucked-in right mid',
    'Under Ranieri, Parker played nominally right midfield but tucked inside to form a trio with Makelele and Lampard, leaving the right flank bare so Makelele could sit deep.',
    'Holding mid overrun in a flat four',
    'Protect the holding midfielder with a three in the centre.',
    NULL, 78, 78, 770)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right midfielder (Parker)', 'Tuck inside to the central trio'),
    (2, 'Holding midfielder (Makelele)', 'Sit deep in front of defence'),
    (3, 'Right-back', 'Provide width alone on the bare flank')
) AS v(so, role, job);

-- 78. pp.78-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '12 The Makelele Role', 'Holding mid as simple recycler',
    'At Chelsea Makelele started attacks by winning the ball, holding position and passing short and sideways, no dribbles or killer passes.',
    'Ball regained in front of the defence',
    'Restart possession safely and keep the team compact.',
    NULL, 78, 79, 780)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Makelele)', 'Hold position, mop up and play short sideways passes')
) AS v(so, role, job);

-- 79. pp.79-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '12 The Makelele Role', 'Man-mark the holding midfielder',
    'Fulham (2006) put playmaker Malbranque at the tip of a diamond to follow Makelele when Chelsea had the ball, forcing Cech to kick long.',
    'Opponent builds through a single pivot',
    'Cut off the pivot and force long balls.',
    '4-3-3', 79, 79, 790)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Diamond tip (Malbranque)', 'Free in possession, man-marks the pivot out of it'),
    (2, 'Rest of team', 'Contest the forced long ball')
) AS v(so, role, job);

-- 80. pp.79-79
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '12 The Makelele Role', 'Early double change to match shape',
    'After 25 minutes at Fulham, Mourinho swapped two wingers for Duff and Drogba to match Fulham''s system and support Crespo, later switching to 3-5-2.',
    'Pivot neutralised and team losing control',
    'Restore a numerical match in midfield and add a target up front.',
    '4-3-1-2', 79, 79, 800)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Second striker (Drogba)', 'Support the lone striker against two centre-backs'),
    (2, 'Wide midfielder (Duff)', 'Help match up in midfield')
) AS v(so, role, job);

-- 81. pp.82-82
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '13 Iberian Influence I', 'Underdog deep shape with offside trap',
    'Porto 2004 (Mourinho) and Greece at Euro 2004 won as outsiders through a drilled defensive shape and an aggressive offside line. Greece man-marked at the back and relied on headed set-piece goals.',
    'Facing stronger opponents',
    'Concede almost nothing and win tight games by one goal.',
    NULL, 82, 82, 810)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four (Porto)', 'Hold a compact line and step up together to catch runners offside'),
    (2, 'Centre backs (Greece)', 'Man-mark the opposing forwards tightly'),
    (3, 'Whole team', 'React to the opponent rather than chase possession; score from set pieces')
) AS v(so, role, job);

-- 82. pp.84-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '13 Iberian Influence I', 'Mourinho deep block, forwards defend first',
    'Chelsea 2004/05 sat deep with Terry and Carvalho, a defensive left back and Makelele screening. Midfielders tracked runners and the centre forward started the defending.',
    'Opponent has the ball',
    'Record-low goals conceded and very few clear chances allowed from open play.',
    NULL, 84, 84, 820)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre backs (Terry, Carvalho)', 'Defend deep, win everything in the box'),
    (2, 'Holding midfielder (Makelele)', 'Sit in front of the back four'),
    (3, 'Central midfielders', 'Track opposition runners all the way'),
    (4, 'Centre forward', 'Lead the first line of defending')
) AS v(so, role, job);

-- 83. pp.84-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_defend', '13 Iberian Influence I', 'Five behind the ball in possession',
    'Mourinho''s possession drills at Chelsea always kept at least five players behind the ball, so the team stayed protected even while attacking.',
    'Team in possession',
    'A secure rest defence that can stop counters straight away when the ball is lost.',
    NULL, 84, 84, 830)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four + holding midfielder', 'Stay behind the ball while the others attack'),
    (2, 'Attacking players', 'Commit forward, knowing the base is covered')
) AS v(so, role, job);

-- 84. pp.84-84
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '13 Iberian Influence I', 'Diamond midfield ceding possession',
    'In early 2004/05 Chelsea played a defensive 4-4-2 diamond: Makelele at the base, two hard-running shuttlers, Lampard higher. They gave the opponent the ball and scored on the counter.',
    'No fit wingers available',
    'Win narrowly, e.g. 1-0, by soaking up pressure and hitting on the break.',
    NULL, 84, 84, 840)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Base of diamond (Makelele)', 'Screen the defence'),
    (2, 'Shuttling midfielders (Geremi, Smertin)', 'Run and close the half-spaces'),
    (3, 'Top of diamond (Lampard)', 'Support the two strikers and arrive late to score')
) AS v(so, role, job);

-- 85. pp.84-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_attack', '13 Iberian Influence I', '4-3-3 wingers sprint in behind',
    'Once Robben and Duff were fit, Chelsea switched to a 4-3-3 with true wingers high and wide on both flanks. The centre forward (Gudjohnsen/Drogba) worked as a target man flicking long balls on for the wingers to chase.',
    'Ball won deep / long ball to the target man',
    'Fast, direct goals from wingers running at and behind the defence.',
    NULL, 84, 85, 850)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (Robben, Duff)', 'Start high and wide, collect deep and sprint at goal or run in behind'),
    (2, 'Centre forward (Gudjohnsen, Drogba)', 'Win the long ball and flick it into the wingers'' path'),
    (3, 'Left-centre midfielder (Lampard)', 'Arrive at the edge of the box for cut-backs')
) AS v(so, role, job);

-- 86. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_attack', '13 Iberian Influence I', 'Transitions: win it and go, lose it and run back',
    'Mourinho made transition the main idea: sprint forward the moment the ball is won, while the opponent is out of shape, and sprint back at once when it is lost.',
    'Change of possession',
    'Score inside about four or five seconds of winning the ball, and give opponents no time to counter.',
    NULL, 85, 85, 860)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (Duff, Robben)', 'Explode forward on regain, then track their full back on loss'),
    (2, 'Midfielders', 'Make recovery runs immediately when the ball is lost'),
    (3, 'Whole team', 'Treat every turnover as the key moment')
) AS v(so, role, job);

-- 87. pp.85-85
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_defend', '13 Iberian Influence I', 'Wingers track the attacking full-backs',
    'As full backs became attacking weapons, Mourinho made his wingers work hard defensively and turned Joe Cole from a playmaker into a disciplined wide worker.',
    'Opponent full back pushes on',
    'Stop the opponent''s overlaps without dropping the back four.',
    NULL, 85, 85, 870)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Cole, Duff, Robben)', 'Follow the opposing full back back towards your own goal'),
    (2, 'Full back', 'Stay with the opposing winger')
) AS v(so, role, job);

-- 88. pp.86-86
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '13 Iberian Influence I', 'Rehearsed shapes for chasing or closing games',
    'Chelsea practised alternative shapes in training, such as throwing on extra forwards into a 3-1-4-2. Players knew exactly how to reorganise when chasing a game or shutting it down. Mourinho sent detailed notes on with substitutes. When chasing, Chelsea also went direct, e.g. a centre back pushed up front as a long-ball target.',
    'Scoreline needs a change (behind or protecting a lead)',
    'The team changes shape mid-game without losing its structure.',
    NULL, 86, 86, 880)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Substitutes', 'Bring the coach''s written instructions on to the pitch'),
    (2, 'Extra forwards', 'Crowd the box when the team is chasing'),
    (3, 'Centre back as emergency striker', 'Act as the target for long balls')
) AS v(so, role, job);

-- 89. pp.88-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '14 Iberian Influence II', 'Benitez vertical compactness, ''Compact!''',
    'Taking from Sacchi, Benitez''s Liverpool squeezed defence, midfield and attack close together (the accordion). In shadow drills the coach walked the ball between zones: the nearest player pressed and everyone else shifted. Liverpool could defend deep or hold a high offside line, but always stayed compact; the keeper stayed close to the back four.',
    'Ball moves into a zone',
    'No space between the lines and no room for the opponent to breathe.',
    NULL, 88, 89, 890)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest player', 'Press the ball carrier'),
    (2, 'Other lines', 'Shift together and close the gaps up and across'),
    (3, 'Goalkeeper (Reina)', 'Play as a sweeper close behind the back line')
) AS v(so, role, job);

-- 90. pp.89-89
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'set_piece', '14 Iberian Influence II', 'Zonal marking at defensive set pieces',
    'Benitez''s Liverpool defended corners and free kicks with each player covering an area rather than following a runner. It was mocked at first, but became one of the best set-piece defences in the league.',
    'Opponent corner or wide free kick',
    'Attack the ball in the danger zones and concede few dead-ball goals.',
    NULL, 89, 89, 900)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Zonal defenders', 'Hold your area and attack the ball when it enters it'),
    (2, 'Whole unit', 'Trust the system rather than switching to man-to-man')
) AS v(so, role, job);

-- 91. pp.90-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '14 Iberian Influence II', 'Narrow 4-4-2, forwards disrupt build-up',
    'Liverpool vs Leverkusen 2005 played narrow and compact. The two forwards pressed the opponent''s build-up and Hamann screened the back four.',
    'Opponent building from the back',
    'Upset the opponent''s first pass and protect the central zone.',
    NULL, 90, 90, 910)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front two', 'Press the centre backs and disrupt the build-up'),
    (2, 'Holding midfielder (Hamann)', 'Protect the back four'),
    (3, 'Wide midfielders', 'Tuck inside to keep the team narrow')
) AS v(so, role, job);

-- 92. pp.90-90
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '14 Iberian Influence II', 'Three centre backs vs narrow two-striker side',
    'Away at Juventus 2005, who played narrow with a two-man strike force, Benitez lined up in a 4-4-2 and then moved into a practised 3-5-1-1 within minutes, three centre backs plus three central midfielders.',
    'Opponent plays through the centre with two strikers and a playmaker',
    'A spare man at the back and control of the centre; a 0-0 to go through.',
    NULL, 90, 90, 920)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three centre backs', 'Mark the two strikers with one spare'),
    (2, 'Three central midfielders', 'Outnumber and smother Nedved''s playmaking'),
    (3, 'Lone forward', 'Hold the ball up')
) AS v(so, role, job);

-- 93. pp.90-92
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '14 Iberian Influence II', 'Istanbul switch to 3-4-2-1',
    'Liverpool were 3-0 down to Milan''s diamond (Pirlo, Seedorf and Kaka behind two strikers) and torn apart on the counter. At half time Benitez switched to a 3-4-2-1 and brought on Hamann to screen.',
    'Being overrun centrally by a diamond with two strikers',
    'A spare man against the two strikers, four against four in central midfield, natural wing balance, and freedom for Gerrard to drive forward.',
    '4-3-1-2', 90, 92, 930)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three centre backs', 'Handle the two strikers'' runs with one spare'),
    (2, 'Holding midfielder (Hamann)', 'Sit deep and stop the number 10 (Kaka)'),
    (3, 'Box-to-box midfielder (Gerrard)', 'Push on and attack the box'),
    (4, 'Wing backs (Riise, Smicer)', 'Give width and pin the opposing full backs')
) AS v(so, role, job);

-- 94. pp.92-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '14 Iberian Influence II', 'Shuttling wide midfielders protect the full-back',
    'Benitez''s wide midfielders shuttled up and down the touchline and tracked the opposing full back. Riera at Madrid was told to stay in front of his left back and block passes into Robben. Liverpool''s full backs tucked inside, so the team was solid but had little attacking thrust.',
    'Opposing full back or winger threatens',
    'Shut down the opponent''s danger flank, at the cost of creativity against weaker sides.',
    NULL, 92, 93, 940)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide midfielder (Kuyt, Riera)', 'Track the full back and screen passes to the winger; do not drift inside'),
    (2, 'Full backs', 'Tuck in and defend first')
) AS v(so, role, job);

-- 95. pp.93-93
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'set_piece', '14 Iberian Influence II', 'Corners aimed at the scouted weakness',
    'Benitez studied opposition reports. If an opponent was weak at the near post, Liverpool hid it by taking corners to other zones in earlier games and then used rehearsed routines with surprise scorers in big matches.',
    'Scouting shows a weak zone on corners',
    'Score in big games from a routine the opponent has not seen.',
    NULL, 93, 93, 950)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Corner taker', 'Deliver to the weak zone the opponent has been shown'),
    (2, 'Surprise runner (e.g. Agger, Benayoun)', 'Attack the space unmarked')
) AS v(so, role, job);

-- 96. pp.95-95
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '15 The Midfield Trio', 'Three-man midfield triangle types',
    'The move to one striker added a third central midfielder for keeping the ball. Mourinho''s 4-3-3 used one holder with two box-to-box players. Benitez''s 4-2-3-1 used two players sharing the defensive job behind a true number 10.',
    'Team wants control of the centre',
    'Keep the ball in little triangles in midfield instead of moving it out quickly.',
    NULL, 95, 95, 960)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Single holder (4-3-3)', 'Anchor and screen'),
    (2, 'Two box-to-box players (4-3-3)', 'Carry the ball and arrive in the box'),
    (3, 'Double pivot (4-2-3-1)', 'Share the defending; one may step forward'),
    (4, 'Number 10 (4-2-3-1)', 'Create between the lines')
) AS v(so, role, job);

-- 97. pp.95-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '15 The Midfield Trio', 'Two-man midfield: one goes, one stays',
    'In a 4-4-2 the central pair must balance: two box-to-box players, one sitting while the other surges, or two holders. Ranieri coached Lampard to hold his runs (''Stay!'') and arrive at the edge of the box late.',
    'Attack developing',
    'Keep cover in front of the defence while still getting a midfielder into scoring spots.',
    NULL, 95, 98, 970)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deeper central midfielder', 'Hold position when the partner goes'),
    (2, 'Advanced central midfielder (Lampard)', 'Delay the forward run and arrive late at the box')
) AS v(so, role, job);

-- 98. pp.98-98
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '15 The Midfield Trio', 'Diamond with overlapping full-backs',
    'England at Euro 2004 tried a diamond with Scholes at the top. Neville and Ashley Cole overlapped to give width so the four midfielders could all play centrally, with Lampard deepest.',
    'Narrow midfield with no wingers',
    'Get creators into central zones while the full backs supply the width.',
    NULL, 98, 98, 980)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full backs (Neville, Cole)', 'Overlap high to give all the width'),
    (2, 'Top of diamond (Scholes)', 'Create behind the strikers'),
    (3, 'Base of diamond (Lampard)', 'Screen the defence')
) AS v(so, role, job);

-- 99. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '15 The Midfield Trio', 'Creator drifting inside from the left',
    'Scholes, played on the left of England''s midfield, kept drifting inside to create while Ashley Cole overlapped outside him.',
    'Wide-left midfielder receives',
    'An extra central playmaker without losing width on that flank.',
    NULL, 99, 99, 990)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Left midfielder (Scholes)', 'Move inside into central pockets to link play'),
    (2, 'Left back (Ashley Cole)', 'Overlap into the space he leaves')
) AS v(so, role, job);

-- 100. pp.99-99
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '15 The Midfield Trio', 'Attacking midfielder freed by deep passer',
    'Gerrard thrived at the top of Benitez''s 4-2-3-1 behind the striker, with two holders behind him. Alonso''s quick deep passing let him drive forward and become a regular goal threat.',
    'Deep playmaker on the ball',
    'Get the most dangerous midfielder on the ball high up and running at goal.',
    NULL, 99, 99, 1000)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Number 10 (Gerrard)', 'Play off the striker, drive at the defence, shoot'),
    (2, 'Deep playmaker (Alonso)', 'Feed the number 10 early with speed of thought'),
    (3, 'Holding partner', 'Protect the space behind')
) AS v(so, role, job);

-- 101. pp.100-101
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '15 The Midfield Trio', 'Holding midfielder behind two attackers',
    'England at the 2006 World Cup moved to 4-1-4-1 with a holder (Carrick, then Hargreaves) behind Gerrard and Lampard. Without one, at home to Croatia 2007, the pair were overrun and a holder''s zone was left open for the winning goal.',
    'Two attacking central midfielders together',
    'Cover the zone outside the box so the attacking pair can push on.',
    NULL, 100, 101, 1010)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Holding midfielder (Carrick, Hargreaves)', 'Guard the space in front of the box and set the tempo'),
    (2, 'Advanced midfielders (Gerrard, Lampard)', 'Attack freely'),
    (3, 'Lone striker (Rooney)', 'Lead the line')
) AS v(so, role, job);

-- 102. pp.103-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '16 Roonaldo', 'Strikerless interchanging front three',
    'Ferguson and Queiroz''s United (2006-09) dropped the penalty-box poacher. Rooney, Tevez and Ronaldo had no fixed positions and rotated freely, so the shape shifted between 4-3-3 and 4-4-2.',
    'Team in possession in the final third',
    'Defenders cannot pick up runners, and space is made for each other through movement and selflessness.',
    NULL, 103, 105, 1020)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front three (Rooney, Tevez, Ronaldo)', 'Rotate positions and drop and run in behind in turn'),
    (2, 'Wide workers (Park)', 'Fill in where a rotating attacker leaves space')
) AS v(so, role, job);

-- 103. pp.105-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_defend', '16 Roonaldo', 'Nearest attacker covers the vacated flank',
    'Because United''s attackers had no set positions, their rule was to cover whichever wide area was empty when the ball was lost. Tevez and Rooney did much of this work so Ronaldo could stay free.',
    'Ball lost during rotation',
    'Keep the defensive shape despite the fluid attack.',
    NULL, 105, 105, 1030)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest forward', 'Fill the free flank at once'),
    (2, 'Work-rate forwards (Tevez, Rooney)', 'Take on the extra running')
) AS v(so, role, job);

-- 104. pp.105-105
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '16 Roonaldo', 'False nine dropping into midfield',
    'Spalletti''s Roma played a strikerless system (called 4-6-0) with Totti dropping deep from centre forward and peeling into midfield. Teammates ran into the space he left. United later copied the idea.',
    'Centre backs follow or hold',
    'Pull a centre back out, or gain a spare man in midfield.',
    NULL, 105, 105, 1040)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'False nine (Totti)', 'Drop deep and link play'),
    (2, 'Midfield runners', 'Burst into the space behind him')
) AS v(so, role, job);

-- 105. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '16 Roonaldo', 'Target the weakest defender',
    'Ronaldo moved between right, left and centre within a game to find the defender weakest one-on-one against pace and power. In the 2008 final Ferguson put him wide left so he could attack Essien, a midfielder playing right back, in the air.',
    'A weak matchup spotted in the back four',
    'Isolate the forward against the weakest defender.',
    NULL, 106, 106, 1050)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free forward (Ronaldo)', 'Move across the front line to attack the weak defender'),
    (2, 'Other forwards (Rooney, Tevez)', 'Fill the position he leaves')
) AS v(so, role, job);

-- 106. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '16 Roonaldo', 'Late-arriving aerial false nine',
    'Away at Roma 2008, Ronaldo was nominally up front but drifted wide and started his runs from very deep, while Park and Rooney worked the flanks in a 4-3-3 that became 4-5-1. With no one to mark, he arrived late to head in.',
    'Cross from wide',
    'Score from crosses with no fixed striker for the centre backs to pick up.',
    NULL, 106, 106, 1060)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'False nine (Ronaldo)', 'Drift away, then attack the box late from deep'),
    (2, 'Hard-working wide forwards (Park, Rooney)', 'Work the flanks and drop into a five-man midfield without the ball')
) AS v(so, role, job);

-- 107. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '16 Roonaldo', 'Close central pair denies split passes',
    'Against Barcelona in the 2008 semi-final United played 4-4-1-1. Queiroz set Scholes and Carrick almost side by side so no penetrating pass could go between them.',
    'Possession side probing through the middle',
    'Barcelona hardly created a chance.',
    NULL, 106, 106, 1070)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two central midfielders (Scholes, Carrick)', 'Stay very close together and block the split pass'),
    (2, 'Number 10 (Tevez)', 'Defend the space in front of the pair'),
    (3, 'Wide players (Park, Rooney/Nani)', 'Work back on the flanks')
) AS v(so, role, job);

-- 108. pp.106-106
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '16 Roonaldo', '4-4-2 to 4-5-1 to regain midfield',
    'In the 2008 final, when Chelsea came back, Ferguson moved Rooney to the right and had Hargreaves tuck in as a third central midfielder alongside Carrick and Scholes.',
    'Losing the midfield battle',
    'Win back control of the midfield.',
    NULL, 106, 106, 1080)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide player tucking in (Hargreaves)', 'Become a third central midfielder'),
    (2, 'Forward moved wide (Rooney)', 'Cover the right flank')
) AS v(so, role, job);

-- 109. pp.106-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'set_piece', '16 Roonaldo', 'Scouted penalty shoot-out plan',
    'For the 2008 final Chelsea followed an economist''s data: kick first if you win the toss, and shoot to the side the opposing keeper does not expect from each foot. Van der Sar spotted the pattern and steered the last taker.',
    'Shoot-out',
    'Turn the shoot-out into planned, scouted game theory rather than a lottery.',
    NULL, 106, 108, 1090)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Captain', 'Choose to kick first'),
    (2, 'Penalty takers', 'Follow the scouted direction plan'),
    (3, 'Goalkeeper', 'Read the opponent''s patterns and try to influence the taker')
) AS v(so, role, job);

-- 110. pp.108-108
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_attack', '16 Roonaldo', 'Counter from a packed own box',
    'United against Arsenal 2009-10: with nine outfielders in their own box, Park won the ball and chipped it to Rooney dropping short. Rooney fed Nani, who was already sprinting. Park made an 80-yard decoy run that dragged a centre back away, and Rooney finished Nani''s cross.',
    'Ball regained inside own box',
    'Score within seconds from a deep defensive position.',
    NULL, 108, 108, 1100)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Regaining player (Park)', 'Pass forward at once, then make a long decoy run'),
    (2, 'Dropping centre forward (Rooney)', 'Come short, link, then burst forward to finish'),
    (3, 'Wide sprinter (Nani)', 'Break early, slow down to let support arrive, then cross')
) AS v(so, role, job);

-- 111. pp.109-109
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '17 A Wet and Windy Night at Stoke', 'Pulisball two banks of four',
    'Out of possession, Pulis''s Stoke sat in a deep, narrow shape, and treated the midfield four as a second back line. They drilled the midfield to shuffle sideways, deny passes between the lines and push attacks wide.',
    'Opponent in possession',
    'Make the opponent cross into tall, dominant centre backs.',
    NULL, 109, 109, 1110)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Midfield four', 'Shuffle across together and close the gaps'),
    (2, 'Centre backs', 'Win the aerial duels from crosses')
) AS v(so, role, job);

-- 112. pp.109-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '17 A Wet and Windy Night at Stoke', 'Route one to the tall forward',
    'In possession, Stoke went long to tall centre forwards picked for their height rather than goals. They won knock-downs for teammates and sometimes put an extra striker out wide just for aerial presence.',
    'Ball won anywhere',
    'Gain territory and second balls near the opponent''s box.',
    NULL, 109, 112, 1120)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target forward (Fuller, Kitson)', 'Win the header and flick it on'),
    (2, 'Supporting players', 'Collect the knock-downs'),
    (3, 'Wide striker', 'Add a second aerial target')
) AS v(so, role, job);

-- 113. pp.110-112
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'set_piece', '17 A Wet and Windy Night at Stoke', 'Delap long throw-in weapon',
    'Delap''s flat 40-yard throws reached the six-yard box like corners. Stoke packed the box with six-footers, brought centre backs up and crowded the keeper, and offside does not apply at throws. From midway in their own half, Stoke even played the ball into touch to win a throw.',
    'Throw-in in the attacking half (often within 30-40 yards)',
    'Turn every throw into a corner-like chance; more than half their early goals came this way.',
    NULL, 110, 112, 1130)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Thrower (Delap)', 'Throw flat and fast into the six-yard box'),
    (2, 'Tall forwards and centre backs', 'Attack the near post, flick on, crowd the keeper'),
    (3, 'Players in own half', 'Kick for touch high upfield to set up a throw')
) AS v(so, role, job);

-- 114. pp.115-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '18 Inverted Wingers', 'Block height set by the opponent',
    'Redknapp''s Spurs 2009/10 did not fight for possession. They sat deep and narrow against Arsenal to stop through balls, and pressed higher against Chelsea to keep Drogba away from goal. The two strikers dropped on to the opposing holding midfielder to even up the midfield.',
    'Opponent''s main threat (through balls or a target striker)',
    'Make up for being outnumbered in midfield and win on the counter.',
    NULL, 115, 115, 1140)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Strikers (Defoe, Pavlyuchenko)', 'Drop on to the opposing holding midfielder'),
    (2, 'Back four', 'Hold the line deep against passers and high against a target man'),
    (3, 'Wingers', 'Stay narrow when the team defends deep')
) AS v(so, role, job);

-- 115. pp.115-115
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '18 Inverted Wingers', 'Classic 4-4-2: wide, cross, target men',
    'Spurs went forward directly to natural-footed wingers (Bale left, Lennon right) who hugged the touchlines and crossed to a big-and-small striker pair (Crouch and Defoe). Bale released Assou-Ekotto on the overlap.',
    'Ball to a winger',
    'A stream of crosses for target men, plus wide pairs that both protect and attack the flank.',
    '4-4-2', 115, 115, 1150)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wingers (Bale, Lennon)', 'Hug the line, beat the full back, cross'),
    (2, 'Overlapping full back (Assou-Ekotto)', 'Run outside the winger for crosses'),
    (3, 'Target striker (Crouch)', 'Attack the cross'),
    (4, 'Small striker (Defoe)', 'Feed off flick-ons and run in behind')
) AS v(so, role, job);

-- 116. pp.116-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '18 Inverted Wingers', 'Hodgson structured 4-4-1-1, inverted wingers',
    'Hodgson''s Fulham drilled shape constantly in 11 v 11 work. Etuhu held, Zamora was the target man, Gera was the deep-lying creator just off him, and the wide men (Davies left, Duff right) cut inside on to their stronger foot.',
    'Settled possession',
    'Fit four creative players into a disciplined shape that reached the Europa League final.',
    NULL, 116, 116, 1160)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Target man (Zamora)', 'Hold up play and win the aerial balls'),
    (2, 'Second striker (Gera)', 'Create from just behind the front man'),
    (3, 'Inverted wingers (Davies, Duff)', 'Cut inside on to the stronger foot'),
    (4, 'Holding midfielder (Etuhu)', 'Protect the back four')
) AS v(so, role, job);

-- 117. pp.116-116
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '18 Inverted Wingers', 'Shepherd inverted wingers into the crowd',
    'Against sides whose wingers cut inside, Fulham were happy to let them come into the crowded centre, where there was little space. Games between two inverted-winger 4-4-2 sides became congested.',
    'Opposing winger cuts inside',
    'Kill the threat by forcing it into congestion rather than defending the touchline.',
    '4-4-2', 116, 116, 1170)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full back', 'Show the winger inside'),
    (2, 'Central midfielders', 'Close the inside lane and swamp the ball')
) AS v(so, role, job);

-- 118. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '18 Inverted Wingers', 'Inverted winger opens overlap lane',
    'Wingers on their unnatural side (Inter''s Eto''o and Pandev, Bayern''s Robben and Ribery) drifted inside to overload the centre, played through balls and shot with the stronger foot. This left the flank free for the attacking full back.',
    'Attacking full back pushing on',
    'Add a goal threat from wide and create space for the full back''s overlap.',
    NULL, 117, 117, 1180)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inverted winger', 'Drift inside, combine, shoot on the stronger foot'),
    (2, 'Attacking full back', 'Overlap into the vacated wide lane')
) AS v(so, role, job);

-- 119. pp.117-117
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '18 Inverted Wingers', 'Wide overload then switch',
    'Moyes''s Everton built around their left side: Pienaar drifted inside so Baines could overlap and cross for Cahill and Fellaini. Training made 2v1 and 3v2 overloads out wide, and used a game with three mini-goals so players learned to switch the ball to the far goal when one route was blocked.',
    'Wide route blocked by defenders',
    'Win crosses from wide overloads, or switch suddenly to the weak side.',
    NULL, 117, 117, 1190)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Inside-drifting winger (Pienaar)', 'Move infield and combine'),
    (2, 'Overlapping full back (Baines)', 'Get outside and cross'),
    (3, 'Box-arriving midfielders (Cahill, Fellaini)', 'Attack crosses'),
    (4, 'Ball carrier', 'Switch to the opposite flank when blocked')
) AS v(so, role, job);

-- 120. pp.118-118
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '18 Inverted Wingers', 'Double up on a star winger',
    'After Bale destroyed Maicon, whose Inter teammates gave no wide cover, opponents doubled up on him. Everton played two right backs, United''s Fletcher sprinted across to help Da Silva, and Bolton''s winger dropped deep in front of Steinsson.',
    'Dangerous winger receives',
    'Take away the winger''s space and productivity.',
    NULL, 118, 118, 1200)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right back', 'Engage the winger'),
    (2, 'Wide midfielder or extra full back', 'Drop in front of him and squeeze his space'),
    (3, 'Nearest central midfielder', 'Sprint across to make it two against one')
) AS v(so, role, job);

-- 121. pp.118-119
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '18 Inverted Wingers', 'Free-roaming winger covered by reverse runs',
    'Under Villas-Boas, Bale had licence to drift from the left or play as the number 10 in a 4-2-3-1. Holtby and Sigurdsson made reverse runs to keep the shape. When the centre was crowded he drifted right to cut inside on his left foot.',
    'Star attacker leaves position',
    'Get the star into central shooting positions without losing the team''s shape.',
    NULL, 118, 119, 1210)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Roaming attacker (Bale)', 'Drift inside or to the right to receive and shoot'),
    (2, 'Teammates (Holtby, Sigurdsson)', 'Make reverse runs into the spaces he leaves')
) AS v(so, role, job);

-- 122. pp.121-122
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '19 The Italian Job', 'Ancelotti narrow diamond, full-backs give width',
    'Chelsea 2009/10 played a 4-4-2 diamond: two strikers, a 10 at the tip, one holding midfielder and two shuttlers, with one of them roaming from the left. All the width came from the full-backs.',
    'Settled possession against a back four',
    'Win the centre with numbers and get two strikers into the box, with midfielders arriving late.',
    NULL, 121, 122, 1220)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Tip of diamond (Lampard)', 'Push up behind the strikers and arrive in the box'),
    (2, 'Left shuttler (Malouda)', 'Roam infield from left-centre and link with the strikers'),
    (3, 'Holding midfielder (Mikel)', 'Sit and screen the back four'),
    (4, 'Full-backs (Cole, Bosingwa)', 'Provide all the team''s width high up the pitch'),
    (5, 'Two strikers (Drogba, Anelka)', 'Stay central and attack crosses')
) AS v(so, role, job);

-- 123. pp.122-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '19 The Italian Job', 'Beating a diamond: pin one side, overload inside',
    'Ferguson''s United against Chelsea''s diamond: one winger stays wide to pin the opposition full-back, the other winger tucks in as an extra central midfielder to match the diamond, and both United full-backs push on.',
    'Opponent plays a narrow diamond with no wide midfielders',
    'Match them in the middle, force them to pass out to a weak full-back, and attack the free flanks.',
    '4-1-2-1-2', 122, 123, 1230)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Valencia)', 'Stay wide and pin the opposing full-back back'),
    (2, 'Left winger (Giggs)', 'Come inside to make a fourth central midfielder'),
    (3, 'Full-backs', 'Push forward into the space the diamond leaves wide'),
    (4, 'Pressers', 'Leave the weak converted full-back free so he gets the ball and loses it')
) AS v(so, role, job);

-- 124. pp.122-123
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '19 The Italian Job', 'Christmas tree: lone striker comes short',
    'Chelsea''s 4-3-2-1 / 4-3-3 hybrid with Drogba absent: Anelka alone up front drops short to link, and the two wide attackers (Malouda, Joe Cole) drift inside off the flanks.',
    'Centre-backs follow the dropping striker or stay deep',
    'Open the space the striker leaves for drifting wide men and late-arriving midfielders, and score through third-man runs.',
    NULL, 122, 123, 1240)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Lone striker (Anelka)', 'Come short to link play instead of running in behind'),
    (2, 'Inside forwards (Malouda, J. Cole)', 'Drift inside into the space the striker vacates'),
    (3, 'Central midfielders (Lampard, Ballack)', 'Make late runs into the box'),
    (4, 'Full-back (Ferreira)', 'Attack the space outside a narrow opposition winger')
) AS v(so, role, job);

-- 125. pp.123-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '19 The Italian Job', 'Full-back attacks a narrow winger',
    'When an opposition winger tucks in to help centrally (Giggs at left midfield), the full-back behind him is left alone, so our full-back on that side can bomb on.',
    'Opposition wide midfielder plays narrow',
    'Create sustained pressure and crossing chances down the unprotected flank.',
    NULL, 123, 125, 1250)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full-back on the weak side of their narrow winger (Ferreira, Zabaleta)', 'Overlap repeatedly into the free flank'),
    (2, 'Wide forward on that side', 'Drag the opposition full-back inside or pin him'),
    (3, 'Central midfielders', 'Switch play quickly to that flank')
) AS v(so, role, job);

-- 126. pp.124-124
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '19 The Italian Job', 'Three holding midfielders protect the back four',
    'Mancini''s early City set up defence first, often with three defensive midfielders (Vieira, De Jong, Barry) in front of a back four. In big games they settled for 0-0.',
    'Away or big matches',
    'Keep a clean sheet by crowding the zone in front of the defence, accepting little attacking threat.',
    NULL, 124, 124, 1260)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Three holding midfielders', 'Screen the centre-backs and break up play'),
    (2, 'Back four', 'Hold a compact, deep line'),
    (3, 'Forwards', 'Few attacking duties; can be replaced by a holder late on to protect the score')
) AS v(so, role, job);

-- 127. pp.124-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '19 The Italian Job', 'City 4-4-2 with narrow playmaking wide men',
    'Mancini''s City 2011/12: nominally a 4-4-2, but Silva and Nasri moved inside off the flanks. Aguero, behind a classic 9 (Dzeko/Balotelli), kept sprinting in behind instead of dropping between the lines, and Toure broke forward from midfield.',
    'Settled possession',
    'Pack the middle with creators while one forward stretches the defence with runs behind.',
    NULL, 124, 125, 1270)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide playmakers (Silva, Nasri)', 'Move inside between the lines to create'),
    (2, 'Second striker (Aguero)', 'Sprint in behind rather than drop deep'),
    (3, 'Box-to-box midfielder (Toure)', 'Break forward from the double pivot'),
    (4, 'Number 9 (Dzeko)', 'Hold the centre-backs and finish'),
    (5, 'Holding midfielder (Barry; De Jong in big games)', 'Hold the base so Toure can push higher')
) AS v(so, role, job);

-- 128. pp.124-125
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '19 The Italian Job', 'Drift to opposite flank, one-two, cut-back',
    'City''s Silva and Milner took turns drifting over to the far flank to join the play there, building local overloads and playing one-twos before squaring back across the box.',
    'Ball on one flank',
    'Outnumber the defenders on the ball side, get to the byline and pull the ball back to an arriving runner.',
    NULL, 124, 125, 1280)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Far-side wide man (Silva or Milner)', 'Leave his flank and join the ball-side overload'),
    (2, 'Ball-side wide man', 'Play a one-two and get to the byline'),
    (3, 'Strikers', 'Arrive late for the cut-back')
) AS v(so, role, job);

-- 129. pp.126-126
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '19 The Italian Job', 'Deep narrow block, long diagonal counter',
    'Di Matteo''s Chelsea 2012 against Barcelona and Bayern: an extremely deep, narrow block that gave up the ball, then countered with long diagonals from a deep midfielder to a running wide midfielder.',
    'Ball won deep; opponent''s full-back high',
    'Survive heavy pressure and score on the break, especially just before half-time.',
    NULL, 126, 126, 1290)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four', 'Defend narrow, deep inside the box'),
    (2, 'Central midfielders (Mikel, Meireles)', 'Hold position to cut passing lanes into the box'),
    (3, 'Deep passer (Lampard)', 'Hit an early long diagonal on regain'),
    (4, 'Runner (Ramires)', 'Sprint into the space behind the high full-back'),
    (5, 'Striker (Drogba)', 'Help the wide defending, then attack crosses')
) AS v(so, role, job);

-- 130. pp.128-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '20 Tiki-Taka', 'Barcelona midfield trio: anchor, orchestrator, dribbler',
    'Guardiola''s Barcelona midfield: Busquets sat deep in front of the defence, Xavi on the right circulated the ball with endless short passes, and Iniesta carried it forward into attack. Each kept repeating receive, pass, move to offer again.',
    'Any possession phase',
    'Keep total control of the ball and wear opponents down until gaps open.',
    NULL, 128, 129, 1300)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep midfielder (Busquets)', 'Protect the defence and recycle'),
    (2, 'Right central midfielder (Xavi)', 'Keep the ball moving with short safe passes and dictate tempo'),
    (3, 'Left central midfielder (Iniesta)', 'Dribble forward into the attacking line'),
    (4, 'All players', 'After passing, move straight away to offer a new angle')
) AS v(so, role, job);

-- 131. pp.129-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '20 Tiki-Taka', 'False nine overloads opponent midfield',
    'Messi started up front but dropped into midfield, giving Barcelona a spare man there. Against United''s 4-4-2 / 4-2-4 the striker tasked with Busquets did not mark him, and the two central midfielders were overrun.',
    'Opponent''s centre-backs won''t follow the dropping 9',
    'Outnumber the opponent''s central midfielders and dominate possession and chances.',
    '4-4-2', 129, 129, 1310)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'False nine (Messi)', 'Drop from striker into midfield to make the extra man'),
    (2, 'Wide forwards (Pedro, Villa)', 'Run in behind into the space the 9 leaves'),
    (3, 'Midfield trio', 'Combine with the false nine and keep the ball'),
    (4, 'Deep midfielder (Busquets)', 'Get free when no forward marks him')
) AS v(so, role, job);

-- 132. pp.129-129
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '20 Tiki-Taka', 'Sit deep rather than squeeze a passing side',
    'Ferguson''s lesson against Barcelona: the 2008 deep block worked, while the 2011 high line and attempt to engage high gave Barca the spaces they wanted.',
    'Facing a superior possession side',
    'Deny space between and behind the lines by defending deep and compact.',
    NULL, 129, 129, 1320)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-backs', 'Hold a deep line instead of pushing high'),
    (2, 'Midfield four', 'Stay compact in front of the back four'),
    (3, 'Forwards', 'Drop in rather than chase high')
) AS v(so, role, job);

-- 133. pp.130-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '20 Tiki-Taka', 'Deep playmaker sprays diagonals',
    'A withdrawn central midfielder sitting just in front of the defence (Scholes at United around 2010; Adam at Blackpool) switches play with long diagonal passes out to the wide men.',
    'Space on the far flank; no pressure on the deep midfielder',
    'Move the ball across and forward fast, finding wide attackers in space.',
    NULL, 130, 132, 1330)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep-lying playmaker (Scholes, Adam)', 'Receive in front of the defence and hit long diagonals'),
    (2, 'Wide forwards', 'Hold the touchline and stretch the defence'),
    (3, 'Holding partner', 'Give defensive cover so the playmaker is free to pass')
) AS v(so, role, job);

-- 134. pp.131-132
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '20 Tiki-Taka', 'Blackpool three-midfield with free playmaker',
    'Holloway''s Blackpool played 4-3-3 / 4-2-3-1 with three central midfielders and wide forwards stretching both flanks. When the playmaker (Adam) moved forward, the other two midfielders stayed back to balance.',
    'Playmaker on the ball in an advanced position',
    'Give one passer licence to roam while keeping cover behind him.',
    NULL, 131, 132, 1340)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Free playmaker (Adam)', 'Roam, switch play and take set pieces'),
    (2, 'Two other central midfielders', 'Sit back and provide balance when he advances'),
    (3, 'Wide forwards', 'Stay wide on both flanks to receive diagonals')
) AS v(so, role, job);

-- 135. pp.133-134
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '20 Tiki-Taka', 'Swansea possession as defence',
    'Rodgers'' Swansea 4-3-3: build from the back with a ball-playing keeper and centre-backs, a right-back who holds position and dictates rather than overlaps, a short sideways-passing anchor, and wingers stretching wide. They kept the ball for long spells in deep areas without trying to penetrate.',
    'Ahead, or when the game is going badly',
    'Deny the opponent the ball and protect the result; accept few chances created.',
    NULL, 133, 134, 1350)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Goalkeeper (Vorm)', 'Start build-up with short passes rather than kicking long'),
    (2, 'Centre-backs', 'Circulate the ball and take risks playing out'),
    (3, 'Right-back (Rangel)', 'Hold position and distribute, not overlap'),
    (4, 'Anchor midfielder (Britton)', 'Short, safe sideways passes only'),
    (5, 'Wingers (Dyer, Sinclair)', 'Stay wide to stretch the pitch')
) AS v(so, role, job);

-- 136. pp.135-137
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '21 Assisters & False Nines', 'Interchanging band of three assisters',
    'In the Spanish 4-2-3-1, the three attacking midfielders swap freely between left, right and centre and drift inside from wide to pop up between the lines. This is aimed at opponents who screen with two deep midfielders.',
    'Opponent defends with a double pivot guarding the zone between the lines',
    'Get creators on the ball between the lines without being marked tightly, and slip through-balls.',
    '4-2-3-1', 135, 137, 1360)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide assister (Silva, Mata, Cazorla)', 'Start wide, then drift inside between the lines'),
    (2, 'Central assister', 'Swap with the wide men'),
    (3, 'Striker', 'Run in behind to receive through-balls'),
    (4, 'Full-backs', 'Supply width when the assisters come inside')
) AS v(so, role, job);

-- 137. pp.136-136
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '21 Assisters & False Nines', 'Drifting creator confuses the full-back',
    'Silva starts wide and drifts inside. The opposing full-back can''t decide how far to follow him and only closes him down once he has the ball, by which time Silva can slide a pass to a teammate running beyond.',
    'Full-back hesitates to leave his line',
    'Receive unmarked in the half-space and thread a pass to an onrushing runner.',
    NULL, 136, 136, 1370)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Drifting wide playmaker (Silva)', 'Move inside into the gap between full-back and centre-back'),
    (2, 'Onrushing midfielder or striker', 'Run beyond as the full-back steps out'),
    (3, 'Opponent counter (man-marker such as Rodwell)', 'Follow the creator everywhere')
) AS v(so, role, job);

-- 138. pp.138-138
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_attack', '21 Assisters & False Nines', 'Dropping 9 drags centre-back, return run',
    'Rooney''s goal against Arsenal: the striker comes short to draw a centre-back up the pitch and receives deep. He lays it wide to a runner who carries the ball forward, while another player''s decoy run occupies the defenders. The striker then sprints into the box for the return.',
    'Ball won in own half; striker free to drop',
    'Pull defenders out of position on the counter and finish from the return pass.',
    NULL, 138, 138, 1380)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Rooney)', 'Drop short to drag a centre-back out, lay off, then sprint into the box'),
    (2, 'Ball carrier (Nani)', 'Dribble forward into the space'),
    (3, 'Decoy runner (Park)', 'Run to distract the defenders')
) AS v(so, role, job);

-- 139. pp.138-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '21 Assisters & False Nines', '''9 and a half'' links while winger runs behind',
    'A lone striker in a 4-3-3 (Van Persie, Tevez) drops off to join build-up and create, so a quick wide forward (Walcott) has to balance that by sprinting in behind.',
    'Striker dropping toward the ball',
    'Combine link play and goal threat from the front line without losing depth.',
    NULL, 138, 139, 1390)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Van Persie)', 'Drop off to link, then still get into scoring areas'),
    (2, 'Wide forward (Walcott)', 'Sprint in behind as the striker comes short'),
    (3, 'Attacking midfielders', 'Use the space the striker vacates')
) AS v(so, role, job);

-- 140. pp.139-139
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_defend', '21 Assisters & False Nines', 'Number 10 as striker leads the counter-press',
    'Klopp played Firmino, an attacking midfielder, as his most advanced man because he could combine with onrushing midfielders and had the energy to start the press.',
    'Possession lost high',
    'Win the ball back quickly near goal while keeping slick link play in possession.',
    NULL, 139, 139, 1400)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker / false 10 (Firmino)', 'Link with midfield runners; first to press when the ball is lost'),
    (2, 'Onrushing midfielders', 'Run beyond the dropping forward')
) AS v(so, role, job);

-- 141. pp.143-143
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '22 Rodgers'' Reversal', 'Two strikers attack two v two',
    'Liverpool 2013/14 played 3-4-1-2 to fit Suarez and Sturridge together. On regain they went two v two against the centre-backs and looked for long balls into the channels behind the opposition''s attacking full-backs.',
    'Possession won; opposition full-backs pushed high',
    'Isolate the centre-backs and get a striker in behind in the channel.',
    NULL, 143, 143, 1410)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two strikers (Suarez, Sturridge)', 'Split into the channels behind the full-backs'),
    (2, 'Midfielders and centre-backs', 'Play early long balls into the channels'),
    (3, 'Wing-backs', 'Supply width since the front two stay central')
) AS v(so, role, job);

-- 142. pp.143-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '22 Rodgers'' Reversal', 'Deep playmaker behind two box-to-box runners',
    'Gerrard was moved into a Pirlo-style deepest midfield role, flanked by two energetic box-to-box midfielders (Henderson, Lucas). Their energy created a pocket of space for him to hit long diagonals forward. The flaw: he was exposed defensively when opposition wide players drifted inside.',
    'Ball to the deep playmaker',
    'Start attacks from deep with long passes forward while the runners cover ground.',
    NULL, 143, 144, 1420)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep playmaker (Gerrard)', 'Receive deep, scan and hit long diagonals'),
    (2, 'Box-to-box midfielders (Henderson, Lucas)', 'Press, cover ground and give the playmaker space'),
    (3, 'Front three', 'Run onto the long passes')
) AS v(so, role, job);

-- 143. pp.144-144
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_attack', '22 Rodgers'' Reversal', 'Wide striker stays in the channel',
    'In a 4-3-3 with one of the two strikers on the wing, he was told not to track the opposition full-back. Instead he stays in the channel and offers a direct passing option at transitions, placed against the slowest defender.',
    'Ball regained',
    'Have an outlet ready in the channel to attack immediately at the turnover.',
    NULL, 144, 144, 1430)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wide-deployed striker (Sturridge or Suarez)', 'Stay high in the channel; don''t track the full-back'),
    (2, 'Midfield', 'Cover the full-back left unmarked'),
    (3, 'Passer on regain', 'Hit the first pass into the channel')
) AS v(so, role, job);

-- 144. pp.144-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_attack', '22 Rodgers'' Reversal', 'Midfield press springs direct counter',
    'Liverpool 2013/14 (the 5-1 against Arsenal) combined an aggressive midfield press with very direct counters using the pace of Suarez, Sturridge and Sterling.',
    'Opponent''s midfielder caught on the ball by the press',
    'Turn ball-wins into breakaway goals within seconds.',
    NULL, 144, 145, 1440)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Box-to-box midfielder (Henderson)', 'Press aggressively, then make forward runs'),
    (2, 'Fast forwards (Suarez, Sturridge, Sterling)', 'Break immediately behind the defence'),
    (3, 'Deep playmaker', 'Release a quick vertical pass on regain')
) AS v(so, role, job);

-- 145. pp.144-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '22 Rodgers'' Reversal', 'Opponent-specific week: runners past a high line',
    'Rodgers built each week''s training around the next opponent. For example, through-balls and midfield runners beyond the forwards, against a side whose midfielders don''t track runs and whose defence plays high.',
    'Opponent''s midfielders don''t track runners; high line',
    'Exploit the specific weakness with rehearsed through-balls.',
    NULL, 144, 145, 1450)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Passing midfielders', 'Play through-balls behind the high line'),
    (2, 'Midfield runners', 'Run beyond the forwards from deep'),
    (3, 'Forwards', 'Pin the centre-backs')
) AS v(so, role, job);

-- 146. pp.145-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'set_piece', '22 Rodgers'' Reversal', 'Score early from set pieces, then counter',
    'Liverpool 2013/14 often went ahead early from dead balls (Gerrard''s deliveries, Skrtel''s headers). That forced the opponent to come and attack, leaving space to counter into.',
    'Early corners and free-kicks',
    'Take the lead and turn the game into one suited to fast counters.',
    NULL, 145, 145, 1460)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Set-piece taker (Gerrard)', 'Deliver quality balls into the box'),
    (2, 'Centre-back (Skrtel)', 'Attack the delivery'),
    (3, 'Fast forwards', 'Exploit the space once the opponent chases the game')
) AS v(so, role, job);

-- 147. pp.145-145
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '22 Rodgers'' Reversal', 'Diamond with strikers attacking channels',
    'Against Manchester City, Rodgers used a diamond with Sterling at the tip. The two strikers ran into the channels, which pinned City''s full-backs so they would not push forward.',
    'Opponent''s full-backs like to push on',
    'Pin the full-backs and threaten in behind early.',
    NULL, 145, 145, 1470)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two strikers (Suarez, Sturridge)', 'Run into the channels outside the centre-backs'),
    (2, 'Tip of diamond (Sterling)', 'Run into the box from the tip'),
    (3, 'Deep midfielder (Gerrard)', 'Feed the channel runs')
) AS v(so, role, job);

-- 148. pp.145-146
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '22 Rodgers'' Reversal', 'Extra midfielder between diamond for 5v4',
    'Rodgers expected Norwich to play a diamond too, so he slotted Coutinho in between his own diamond of Gerrard, Lucas, Allen and Sterling (an unusual 4-1-3-1-1). That gave a five-against-four midfield.',
    'Opponent also plays a diamond',
    'Win the midfield numbers battle.',
    '4-1-2-1-2', 145, 146, 1480)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Extra midfielder (Coutinho)', 'Sit between the midfield and the front to make the fifth man'),
    (2, 'Diamond midfielders', 'Keep the shape and circulate'),
    (3, 'Lone striker (Suarez)', 'Occupy the centre-backs')
) AS v(so, role, job);

-- 149. pp.146-147
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '22 Rodgers'' Reversal', 'Park the bus, counter late',
    'Mourinho''s second-string Chelsea at Anfield 2014 defended extremely deep, leaving no room to run in behind and forcing Liverpool to cross and shoot from distance. They broke on the counter late after an attacking corner.',
    'Opponent needs to attack; a draw suits us',
    'Deny all space behind and in the box, and punish over-commitment on the break.',
    NULL, 146, 147, 1490)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Back four and midfield', 'Sit very deep and compact in front of goal'),
    (2, 'Striker (Ba)', 'Press the deep playmaker and pounce on errors'),
    (3, 'Counter runners (Torres, Willian)', 'Break when the opponent commits players forward, e.g. from their corner')
) AS v(so, role, job);

-- 150. pp.148-149
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '23 Pressing Issues', 'Barcelona collective high press',
    'Barcelona 2010 at the Emirates: forwards sprint to press, and even the right-back pushes all the way up to the opposition left-back near the corner flag, so the opponent can''t build. Arsenal''s response of pressing in ones and twos failed, and Barca passed through and hit long balls behind their higher line.',
    'Opponent tries to build from the back',
    'Win the ball back as soon as possible in the opponent''s half.',
    NULL, 148, 149, 1500)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Forwards', 'Sprint to press the defenders instantly'),
    (2, 'Full-back (Dani Alves)', 'Push right up to mark the opposite full-back high'),
    (3, 'Whole unit', 'Press together, not individually')
) AS v(so, role, job);

-- 151. pp.149-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '23 Pressing Issues', 'High block with aggressive line',
    'Villas-Boas'' 4-3-3 at Chelsea and Tottenham: all outfielders push up and press in advanced areas behind a very high line, compressing play. At Spurs everyone pressed except the opposition centre-backs, and the keeper played as a sweeper outside his box. It broke down when the midfield failed to pressure the ball, inviting through-balls and runners behind.',
    'Opposition in their own half',
    'Win the ball high and pin the opponent back.',
    NULL, 149, 150, 1510)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive line', 'Hold very high to compress the space'),
    (2, 'Midfield', 'Press the ball carrier so no through-ball can be played'),
    (3, 'Forwards', 'Press everyone except the centre-backs'),
    (4, 'Sweeper-keeper (Lloris)', 'Rush out to clear balls played behind the line')
) AS v(so, role, job);

-- 152. pp.149-150
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '23 Pressing Issues', 'Drop to medium or low block',
    'When the high block was being played through, Villas-Boas lowered the lines to a medium block, and in a must-win game used a full low block (Chelsea 3-0 Valencia).',
    'High press being bypassed in the first minutes',
    'Regain control and confidence by defending deeper and more compactly.',
    NULL, 149, 150, 1520)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Defensive line', 'Drop a few yards'),
    (2, 'Midfield', 'Sit deeper and concede possession in front'),
    (3, 'Forwards', 'Stop pressing high and screen the midfield')
) AS v(so, role, job);

-- 153. pp.151-151
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '23 Pressing Issues', 'Attacker-triggered high press (Pochettino)',
    'Pochettino''s Southampton: attackers start the press, midfielders push onto their direct opponents and the defence holds a high line. The pressers aim to leave the ball carrier only a poor pass and never several options.',
    'An attacker closes down a defender',
    'Harass and destabilise the build-up, regaining the ball high; Southampton led the league for possession largely through quick regains.',
    NULL, 151, 151, 1530)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Front player', 'Trigger the press on the ball carrier'),
    (2, 'Midfielders (Schneiderlin, Wanyama)', 'Push onto their direct opponents and shut options'),
    (3, 'Defensive line', 'Hold high behind the press'),
    (4, 'Everyone', 'Follow the trigger together')
) AS v(so, role, job);

-- 154. pp.151-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_attack', '23 Pressing Issues', 'Regain high, go vertical, re-press',
    'After winning the ball, Pochettino''s sides play an ambitious vertical pass straight away. If it fails they simply press again. Eriksen stealing the ball deep in Arsenal''s half and setting up Chadli is the model.',
    'Ball regained in advanced position',
    'Attack in one or two passes before the opponent recovers its shape.',
    NULL, 151, 152, 1540)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Ball winner (Eriksen)', 'Steal and play forward immediately'),
    (2, 'Forwards', 'Make runs to receive the vertical pass'),
    (3, 'Midfield', 'Re-press at once if the pass fails')
) AS v(so, role, job);

-- 155. pp.151-152
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '23 Pressing Issues', 'Lateral press boxes ball onto touchline',
    'Pochettino''s Tottenham: when the opponent has the ball on the far flank, the near-side wide midfielder moves into central midfield. The block shifts across and traps the ball against the touchline.',
    'Ball on the opposite flank',
    'Box the opponent in near the sideline and force a turnover.',
    NULL, 151, 152, 1550)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Far-side wide midfielder', 'Tuck into central midfield'),
    (2, 'Ball-side players', 'Close down and use the touchline as an extra defender'),
    (3, 'Central midfielders', 'Shift across to cut inside passes')
) AS v(so, role, job);

-- 156. pp.152-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_defend', '23 Pressing Issues', 'Gegenpressing: press the instant ball is lost',
    'Klopp''s counter-pressing focuses on timing rather than position: press immediately after losing the ball, while the opponent''s players are moving into their own attacking transition with full-backs pushing up.',
    'Possession lost',
    'Regain near the goal and catch the opponent spread out, one pass from a big chance.',
    NULL, 152, 153, 1560)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Nearest players to the loss', 'Jump on the ball immediately'),
    (2, 'Others', 'Close nearby passing options'),
    (3, 'Midfield runners', 'Attack straight away once regained')
) AS v(so, role, job);

-- 157. pp.153-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '23 Pressing Issues', 'Striker splits pitch, press full-back lane',
    'In Klopp''s Liverpool press, Firmino curves his run so the opposition can only play towards one full-back. He then blocks the pass between that full-back and the nearest centre-back, while teammates push up and mark other nearby options tightly.',
    'Opposition building from the back',
    'Lock the ball onto one side and win it back from a team trying to pass out.',
    NULL, 153, 153, 1570)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Firmino)', 'Force play to one full-back, then cut the full-back to centre-back pass'),
    (2, 'Midfielders and wide forwards', 'Push up tight on nearby options'),
    (3, 'Defensive line', 'Step up behind the press')
) AS v(so, role, job);

-- 158. pp.153-153
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '23 Pressing Issues', 'Man-marking midfield press, compact medium block',
    'Van Gaal''s United pressed simply, with midfielders man-marking their direct opponents. That could drag them out of shape, but their medium block was compact and conceded the fewest goals.',
    'Opponent in midfield',
    'Deny midfield receivers while staying compact and hard to score against.',
    NULL, 153, 153, 1580)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central midfielders', 'Mark their direct counterparts'),
    (2, 'Back four and wide players', 'Hold a compact medium block')
) AS v(so, role, job);

-- 159. pp.154-154
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '24 Leicester', 'Atletico 4-4-2: forwards drop, shepherd wide',
    'Simeone''s Atletico 2013/14: the two forwards drop very deep as extra midfielders, and the midfield four sit compact in front of the defence. They push opponents out wide, then press hard to force turnovers and counter.',
    'Opponent ball moves to a wide area',
    'Be impossible to play through centrally and turn wide regains into fast counters.',
    NULL, 154, 154, 1590)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Two forwards (Costa, Villa)', 'Drop in as auxiliary midfielders'),
    (2, 'Midfield four', 'Stay compact and push the ball wide'),
    (3, 'Ball-side players', 'Press intensely once the ball is out wide'),
    (4, 'Back four', 'Stay compact and deep')
) AS v(so, role, job);

-- 160. pp.155-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '24 Leicester', 'Leicester deep compact block, defend narrow',
    'Ranieri''s Leicester switched to a deeper back four that played narrow, conceding space outside rather than between the defenders. The slow centre-backs stayed on the edge of the box heading crosses away, and the full-backs were defensive types allowed to overlap only when losing.',
    'Defending a lead or settled defence',
    'Shut the channels between defenders and keep clean sheets.',
    NULL, 155, 156, 1600)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-backs (Morgan, Huth)', 'Stay deep at the box edge and win headers'),
    (2, 'Full-backs (Fuchs, Simpson)', 'Tuck in to protect the centre-backs; overlap only when behind'),
    (3, 'Central midfielders (Kante, Drinkwater)', 'Ball-win and screen the back four'),
    (4, 'Wide midfielders', 'Defend the outside space')
) AS v(so, role, job);

-- 161. pp.156-156
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '24 Leicester', 'Defensive second striker shuts the pivot',
    'Okazaki played between midfield and Vardy, dropping very deep to close down the opponent''s holding midfielder quickly. In effect he was a third central midfielder who started the team''s pressure.',
    'Opponent''s holding midfielder receives',
    'Deny the opposition pivot time and start the defensive pressure.',
    NULL, 156, 156, 1610)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Second striker (Okazaki)', 'Drop onto the holding midfielder and press'),
    (2, 'Ball-winning midfielder (Kante)', 'Hunt loose balls across the middle'),
    (3, 'Striker (Vardy)', 'Stay higher for the counter')
) AS v(so, role, job);

-- 162. pp.157-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_attack', '24 Leicester', 'One-pass counter to striker on last shoulder',
    'In Leicester''s 4-4-1-1, Vardy stays high on the shoulder of the last defender. On regain, a midfielder or the keeper''s throw sends the ball straight into the channel for him to run onto. Mahrez is excused from tracking the full-back so he can break too.',
    'Ball regained deep or keeper gathers',
    'Score in one pass by exploiting the space outside the centre-backs.',
    NULL, 157, 158, 1620)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Striker (Vardy)', 'Stay on the last defender''s shoulder and run the channel'),
    (2, 'Deep passer (Drinkwater, Mahrez)', 'Hit a first-time ball into the channel'),
    (3, 'Goalkeeper (Schmeichel)', 'Long throw to start the counter'),
    (4, 'Right winger (Mahrez)', 'Skip full-back tracking; carry and dribble on the break')
) AS v(so, role, job);

-- 163. pp.158-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '24 Leicester', 'Plan B tall striker against deep block',
    'Once opponents sat deep against Leicester''s counters, Ranieri brought on a taller centre-forward (Ulloa) to win crosses, at times even replacing a defender.',
    'Opponent parks men behind the ball; draw or losing late',
    'Change the route to goal from counters to crosses.',
    NULL, 158, 158, 1630)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Substitute target striker (Ulloa)', 'Attack crosses in the box'),
    (2, 'Wide players (Albrighton)', 'Deliver crosses early')
) AS v(so, role, job);

-- 164. pp.158-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'set_piece', '24 Leicester', 'Set pieces break deep defences',
    'When counters dried up, Leicester''s centre-backs (Huth, Morgan) scored from dead balls. An early set-piece goal forces a defensive opponent to come out, leaving space to counter.',
    'Corners and free-kicks against a deep block',
    'Get goals that counter-attacking alone can''t, and open the game up.',
    NULL, 158, 158, 1640)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-backs (Huth, Morgan)', 'Attack deliveries aggressively'),
    (2, 'Takers (Albrighton, Mahrez)', 'Deliver into the danger zone')
) AS v(so, role, job);

-- 165. pp.158-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '24 Leicester', 'Kick long into full-back zone, then box in',
    'Away at City, Leicester deliberately played a long diagonal into the opposition right-back zone, even sending it out for a throw. They then pushed up to trap City in that corner, and Kante won the first duel.',
    'Kick-off or a dead ball in the opposition corner',
    'Press high from a set position and win the ball near the opponent''s goal.',
    NULL, 158, 158, 1650)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Deep midfielder (Drinkwater)', 'Hit the long diagonal into the full-back zone'),
    (2, 'Whole team', 'Push up and box the opponent near the touchline'),
    (3, 'Ball-winner (Kante)', 'Win the first duel')
) AS v(so, role, job);

-- 166. pp.158-158
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_attack', '24 Leicester', 'Switch to winger who goes outside',
    'On regaining the ball, Leicester switched play straight to Mahrez on the right. City set up a narrow left midfielder to block his cut inside, so he went down the outside instead and won a foul.',
    'Ball regained; opponent guards the winger''s inside',
    'Use the alternative route when the favourite move is shut down.',
    NULL, 158, 158, 1660)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Right winger (Mahrez)', 'Go outside if the inside is blocked; otherwise cut onto the strong foot'),
    (2, 'Passer on regain', 'Switch quickly to the winger')
) AS v(so, role, job);

-- 167. pp.160-160
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '25 Three at the Back', 'Inverted full-backs and sweeper-keeper',
    'Guardiola''s City 2016/17: a ball-playing sweeper-keeper (Bravo) replaced a traditional keeper, an attacking left-back (Kolarov) played centre-back, and the full-backs moved inside to become central midfielders in possession.',
    'Build-up from the back',
    'Add numbers in central midfield and build through the middle from the keeper.',
    NULL, 160, 160, 1670)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Sweeper-keeper (Bravo)', 'Take part in build-up and sweep behind the line'),
    (2, 'Full-backs', 'Drift inside into central midfield'),
    (3, 'Centre-back (Kolarov)', 'Bring the ball out from the back')
) AS v(so, role, job);

-- 168. pp.161-161
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '25 Three at the Back (Chelsea 2016/17, early 4-3-3)', 'Attacking full-backs, five held behind',
    'In Conte''s opening 4-3-3/4-1-4-1, both full-backs pushed very high while the two outer central midfielders slid wider to guard the channels and the holding man dropped between the centre-backs.',
    'Team in settled possession',
    'Create a front five while keeping five players in a solid rest-defence block.',
    NULL, 161, 161, 1680)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Full-backs (Ivanovic, Azpilicueta)', 'Push up beside the front three to make a front five'),
    (2, 'Outer central midfielders (Matic, Oscar)', 'Stay back, shift slightly wide into the space the full-backs left'),
    (3, 'Holding midfielder (Kante)', 'Drop between the two centre-backs'),
    (4, 'Centre-backs', 'Hold the rest-defence line with the three above')
) AS v(so, role, job);

-- 169. pp.161-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '25 Three at the Back (Chelsea 2016/17 3-4-3)', '3-4-3 front five, free inside forward',
    'After switching to 3-4-3 the attacking shape stayed a front five, but with wing-backs supplying width the two inside forwards were freed from tracking back; one drifted inside at will, the other ran in behind, while the striker stayed central as a fixed reference point.',
    'Possession in the opposition half',
    'Give the star attacker freedom without losing width or defensive balance.',
    NULL, 161, 162, 1690)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing-backs (Alonso, Moses)', 'Push high either side to hold width'),
    (2, 'Left inside forward (Hazard)', 'Free of defensive duty, drift into central pockets'),
    (3, 'Right inside forward (Pedro)', 'Play higher and run in behind the defence'),
    (4, 'Centre-forward (Diego Costa)', 'Stay in the centre-forward zone as the point of reference'),
    (5, 'Two central midfielders (Kante, Matic)', 'Screen behind the front five')
) AS v(so, role, job);

-- 170. pp.162-162
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '25 Three at the Back (Chelsea 2016/17 training)', 'Rehearsed shape combinations (''automatisms'')',
    'Chelsea drilled the starting XI unopposed on team shape, repeating set passing combinations that end with a forward or a wing-back in a dangerous attacking spot, until the moves became automatic.',
    'Recognised cue in build-up',
    'Play fast, pre-learned combinations that free a forward or wing-back to attack.',
    NULL, 162, 162, 1700)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Starting XI', 'Run the same passing routes repeatedly so the movements are automatic'),
    (2, 'Forwards', 'Arrive in the pre-agreed scoring position'),
    (3, 'Wing-backs', 'Time the run to receive in an advanced wide area')
) AS v(so, role, job);

-- 171. pp.162-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '25 Three at the Back (Chelsea 2016/17)', 'Middle centre-back runs the line',
    'In the back three, the central defender plays a free reading role, choosing position and calling the line up and down; the wide centre-backs need mobility to cover out wide behind the wing-backs.',
    'Ball moves / opponents step up or drop',
    'Keep the back three coordinated and compact as one unit.',
    NULL, 162, 163, 1710)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central centre-back (David Luiz)', 'Read play, organise and call the line up or down'),
    (2, 'Right centre-back (Azpilicueta)', 'Cover wide areas behind the right wing-back'),
    (3, 'Left centre-back (Cahill)', 'Go inside and outside to cover more ground')
) AS v(so, role, job);

-- 172. pp.163-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '25 Three at the Back (Chelsea 2016/17)', 'Far-post wing-back vs back four',
    'Against a four-man defence, Chelsea''s front three plus a wing-back gave a five-against-four overload: the near full-back is dragged to the near wing-back and the centre-backs track the inside forwards, leaving the far full-back alone against the striker and the arriving far wing-back. Opponents also could not decide whether full-backs or wide midfielders should pick up the wing-backs.',
    'Ball on one flank with the back four shifted across',
    'Find the unmarked far-side wing-back at the back post to score.',
    NULL, 163, 163, 1720)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Near wing-back (Moses)', 'Pull the opposing full-back wide and deep'),
    (2, 'Inside forwards (Pedro, Hazard)', 'Occupy the centre-backs with runs'),
    (3, 'Centre-forward (Diego Costa)', 'Attack the far full-back aerially'),
    (4, 'Far wing-back (Alonso)', 'Lurk and arrive unmarked at the far post')
) AS v(so, role, job);

-- 173. pp.163-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '25 Three at the Back (Chelsea 2016/17)', 'Spare centre-back steps out',
    'When the opponent played one striker, one of the three centre-backs left the line: the middle one stepped into midfield as a deep playmaker, or the right one pushed forward ahead of the central midfielders, turning a 3-2-5 into a 2-3-5.',
    'Opponent with a lone striker, back three has a man spare',
    'Use the surplus defender as an extra passer or attacker.',
    NULL, 163, 163, 1730)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Central centre-back (David Luiz)', 'Step forward into midfield to dictate play'),
    (2, 'Right centre-back (Azpilicueta)', 'Shuttle forward beyond the midfield pair'),
    (3, 'Remaining two centre-backs', 'Hold a two against the lone striker'),
    (4, 'Central midfielders (Matic, Fabregas)', 'Adjust behind or beside the advancing defender')
) AS v(so, role, job);

-- 174. pp.163-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'to_attack', '25 Three at the Back (Chelsea v Man City, Dec 2016)', 'Punish a back three left bare',
    'Guardiola''s City used a 3-2-4-1 to dominate midfield and press the wing-backs, leaving their three defenders exposed against Chelsea''s front three; Chelsea went direct so each attacker needed only to beat his one marker. Same idea when Everton tried to mirror and were countered behind their wing-backs.',
    'Regain while the opponent''s wing-backs/midfield are committed high',
    'Go long or break fast into 1v1s against an exposed back three.',
    NULL, 163, 163, 1740)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Centre-forward (Diego Costa)', 'Win the long ball, outmuscle the centre-back, finish or lay off'),
    (2, 'Inside forwards (Willian, Hazard)', 'Sprint past the nearest defender into the space behind'),
    (3, 'Defenders/midfield', 'Play direct early before the opponent recovers numbers')
) AS v(so, role, job);

-- 175. pp.163-163
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'in_possession', '25 Three at the Back (Tottenham v Chelsea, Jan 2017)', 'Far-post cross onto small wide defender',
    'Tottenham attacked Chelsea''s back three by crossing early to the far post where a tall attacking midfielder had a height edge over the smaller wide centre-back.',
    'Ball in wide crossing position',
    'Win headers at the far post against a mismatch on the back three''s flank.',
    '3-4-3', 163, 163, 1750)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Crossing midfielder (Eriksen)', 'Deliver early to the far post'),
    (2, 'Attacking midfielder (Dele Alli)', 'Drift to the far post to attack the shorter wide centre-back')
) AS v(so, role, job);

-- 176. pp.163-164
WITH p AS (
  INSERT INTO coaching_book_patterns (book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, page_from, page_to, sort_order)
  VALUES ((SELECT id FROM coaching_books WHERE slug = 'kindle-the-mixer'), 'out_of_possession', '25 Three at the Back (Spurs and Arsenal v Chelsea 2016/17)', 'Mirror the 3-4-3 to contain it',
    'Because chasing the 3-4-3 with a back four left full-backs torn between wing-backs and inside forwards, rivals copied the shape: wing-back against wing-back and a back three against the front three, letting them press high man-for-man. Tottenham beat Chelsea this way, and Arsenal switched to 3-4-3 late in the season and beat them in the Cup final.',
    'Facing a 3-4-3',
    'Remove the overload by matching players and press aggressively in advanced areas.',
    '3-4-3', 163, 164, 1760)
  RETURNING id)
INSERT INTO coaching_book_pattern_roles (pattern_id, sort_order, role, job)
SELECT p.id, v.so, v.role, v.job FROM p, (VALUES
    (1, 'Wing-backs', 'Pick up the opposing wing-backs directly'),
    (2, 'Back three', 'Match the front three one-on-one'),
    (3, 'Front three', 'Press the opposing back three high'),
    (4, 'Central midfield pair', 'Mark the opposing midfield pair')
) AS v(so, role, job);

COMMIT;
