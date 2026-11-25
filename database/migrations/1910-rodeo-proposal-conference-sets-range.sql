-- 📣 Rodeo-day proposal: the first ask is the CONFERENCE's start-time range,
-- not a per-game approval (James 11/25 "also rule says as determined by conf
-- so we could get that overrode by our conf").
--
-- APSL Regulations & Club Manual 2026-27 §3.2.3.1: "Each conference may
-- determine the range of start times for matches for the respective
-- conference prior to the start of each conference season"; §3.2.3.2 the
-- 6–9 PM Saturday range applies "Unless otherwise agreed to by the competing
-- teams, or as determined by the conference".  Our conference = Delaware
-- River Conference (Lighthouse 1893 SC in DRC Group B).  A DRC range that
-- includes Saturday mornings makes them ordinary kickoffs: no visitor sign-off
-- per game.  Per-game approval (§3.2.3.3) stays the second route, Sunday the
-- third.

BEGIN;

CREATE TEMP TABLE _r (o int, a text, b text) ON COMMIT DROP;
INSERT INTO _r VALUES
(1, 'That kickoff is outside the APSL''s Saturday window (6 PM to 9 PM), so the visiting team and the conference commissioner must agree. **If they say no, the game is on the Sunday** (see Plan B), and the rodeo on Saturday is where we sell it.',
    'That kickoff is outside the APSL''s default Saturday window (6 PM to 9 PM). But the rules let **each conference set its own range**, so the first ask is for the Delaware River Conference to allow Saturday mornings before the 2027 season. Then a morning game is an ordinary kickoff and no visitor has to agree. If the conference will not, each game needs the visitor and the commissioner to approve it. **If that fails too, the game is on the Sunday** (see Plan B), and the rodeo on Saturday is where we sell it.'),
(4, '- Each conference may set its own range, so ask the commissioner whether ours allows a Saturday morning.',
    '- **Each conference may set its own range**, before its season starts (section 3.2.3.1), and the 6 PM to 9 PM window applies only "as determined by the conference" otherwise. If the Delaware River Conference sets its Saturday range to start in the morning, our 11 AM game needs nobody''s approval.
**Three routes, in order:**
|Route|Who decides|When
|1 The conference sets a Saturday range that includes mornings|The Delaware River Conference|Before the 2027 season starts
|2 Each game approved as an exception|The visiting team and the commissioner|Before the schedule is released
|3 Plan B: the Sunday|Nobody: Sunday 11 AM to 9 PM is the normal window|Any time; after the schedule is out, at least 14 days ahead'),
(5, 'If the visitor or the commissioner will not take a Saturday morning, the game goes on the Sunday.',
    'If neither the conference nor the visitor will take a Saturday morning, the game goes on the Sunday.'),
(8, '- **The commissioner.** Whether our conference allows Saturday mornings, and whether the commissioner will approve them on rodeo weekends. Ask before the 2027 schedule is made, with the rodeo dates in hand.',
    '- **The conference.** Ask the Delaware River Conference to set its 2027 Saturday start-time range to include mornings. The rules let a conference do this before its season starts. Other DRC clubs may want earlier Saturday games too, which helps the case.'),
(8, '- **The visiting teams.** A Saturday morning is outside the window, so each visitor must agree. Teams travelling far may not want an 11 AM start.',
    '- **The visiting teams.** Only if the conference says no: then each visitor must agree to a Saturday morning. Teams travelling far may not want an 11 AM start.'),
(10, '- **2 The commissioner.** Ask for Saturday-morning home games on rodeo weekends, with Sunday as the fallback, before the 2027 schedule is made.',
     '- **2 The conference.** Ask the Delaware River Conference to allow Saturday-morning kickoffs in its 2027 start-time range. If it will not, ask the commissioner to approve our rodeo-weekend mornings one by one, with Sunday as the fallback.'),
(11, '- **Plan B:** Sunday after the rodeo when a Saturday is refused, yes?',
     '- **The ask:** the conference''s Saturday range first, then game-by-game approval, then Sunday?
- **Plan B:** Sunday after the rodeo when a Saturday is refused, yes?');

DO $$
DECLARE r record; n int;
BEGIN
  FOR r IN SELECT * FROM _r LOOP
    UPDATE proposal_sections s SET body = replace(s.body, r.a, r.b)
      FROM proposals p
     WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.sort_order = r.o AND position(r.a IN s.body) > 0;
    GET DIAGNOSTICS n = ROW_COUNT;
    IF n <> 1 THEN RAISE EXCEPTION 'rodeo proposal: text not found in section %: %', r.o, left(r.a, 60); END IF;
  END LOOP;
END $$;

UPDATE proposals
   SET summary = 'From James Breslin: thousands come to Lighthouse for the rodeo and concerts, and almost nobody comes to the soccer. Play men''s home games on rodeo Saturdays in the morning, finished before the crowd parks on our field (no lights). Ask the Delaware River Conference to allow Saturday mornings (the APSL default is 6–9 PM), else game-by-game approval, else the Sunday.'
 WHERE code = 'rodeo-day-crowds';

COMMIT;
