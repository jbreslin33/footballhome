-- 📣 Rodeo-day proposal: the APSL's own kickoff rules, no lights, the field
-- is the event's car park, and a Sunday Plan B (James 11/25 "we also need to
-- be able to do a sunday if the leage/team refuse us. check the apsl rules on
-- saturday games" / "i belive it says 7pm kickoff" / "we have no lights so
-- 7pm is a problem unless we can get lights lol. also the big events park on
-- our field lol so playing during main part of event is difficlut lol").
--
-- APSL Regulations & Club Manual 2026-27 (TeamPass PDF, 08.05.26):
--   §3.2.3.2 (p.15) Sunday kickoff 11:00 am–9:00 pm, Saturday 6:00 pm–9:00
--     pm, midweek make-ups 8:00–9:15 pm, unless the teams agree or the
--     conference sets its own range (§3.2.3.1).
--   §3.2.3.3 any other day or time: visiting team AND conference
--     commissioner approve first.
--   §3.2.2.2/3 home team sets venue + start time; none by schedule release =
--     fine, home games may move to the visitor's ground.
--   §4.2.4.2 schedule published no later than 14 days before the season.
--   §3.2.5.9 (p.16) Sat<->Sun move: no less than 14 days before, time >2 h or
--     >10 miles: 7 days, unless both teams agree.
--   §4.1.6/7 field access 30 min before kickoff; field held 2 hours.
-- Sunset times are approximate for Philadelphia (EDT, EST from Nov 1).
-- Section 3 onward shifts down one for the new Plan B section (5).

BEGIN;

UPDATE proposal_sections s SET sort_order = s.sort_order + 100
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.sort_order >= 5;
UPDATE proposal_sections s SET sort_order = s.sort_order - 99
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.sort_order >= 105;

CREATE TEMP TABLE _rodeo (o int PRIMARY KEY, h text, b text) ON COMMIT DROP;
INSERT INTO _rodeo VALUES
(1, 'Summary', $b$From James Breslin.
Thousands of people come to Lighthouse for the rodeo and the concerts. Almost nobody comes to watch our soccer.
The crowd is already at the gate. We play at the wrong time: every men's and women's home game in 2026 was on a Sunday, and since 2024 almost every rodeo has been on a Saturday: 11 to 17 of them a season, April to October.
Two facts shape the plan. **We have no lights**, so every game has to finish in daylight. And on big event days **the crowd parks on our field**, so we cannot play during the main part of the event.
**The plan:** on rodeo weekends, play the men's home game on the Saturday **before the rodeo opens**: kick off at about 11 AM or noon, and finish with the pitch clear before the first cars park. The early rodeo crowd, the vendors and the rodeo's staff see a live game, and our players, families and fans stay on for the rodeo.
That kickoff is outside the APSL's Saturday window (6 PM to 9 PM), so the visiting team and the conference commissioner must agree. **If they say no, the game is on the Sunday** (see Plan B), and the rodeo on Saturday is where we sell it.$b$),

(4, 'Rodeo Saturday: Lighthouse match day', $b$The game fits in the morning, before the field becomes the car park.
|Time|What
|10:30|Teams on the field (the APSL asks for field access 30 minutes before kickoff)
|**11:00**|**APSL kickoff**
|About 12:55|Final whistle. The pitch is cleared: goals, benches, corner flags off
|Before parking opens|Field handed over to the rodeo as parking. Ramiro tells us the time
|2:00–midnight|Rodeo. Players, families and fans stay on
If parking starts later, kick off at noon and finish near 2. The earliest time the cars come is the one fact that sets the kickoff; ask Ramiro for it on every date.
**What the APSL rules say** (Regulations & Club Manual 2026–27, section 3.2.3):
- Sunday kickoffs are 11 AM to 9 PM. Saturday kickoffs are **6 PM to 9 PM**.
- Any other day or time needs the **visiting team and the conference commissioner** to approve it before it goes on the schedule.
- The home team sets its venue and start times. Send them before the schedule is released (it is published at least 14 days before the season), or there is a fine.
- The 6 PM to 9 PM window does not work for us on a rodeo Saturday. At 6 PM the field is full of cars, and without lights a 6 PM game only finishes in daylight from about mid-May to mid-August.
- Each conference may set its own range, so ask the commissioner whether ours allows a Saturday morning.$b$),

(5, 'Plan B: Sunday', $b$If the visitor or the commissioner will not take a Saturday morning, the game goes on the Sunday. Sunday 11 AM to 9 PM is the APSL's normal window, so it needs nobody's approval.
- **Ask for both at once.** When we send our 2027 home dates, give each rodeo weekend as "Saturday 11 AM, or Sunday if not". That way a refusal never lands the game on some other weekend.
- **Sell Sunday at Saturday's rodeo.** A table at the gate, flyers, the rodeo announcer: "Lighthouse plays here tomorrow, free." The crowd comes back the next day instead of walking past.
- **Sunday rodeos.** Some rodeos were on Sundays: seven in 2023, three in 2024 (May 26, July 7, September 15), and September 13 2026. Ask Ramiro whether a few 2027 rodeos can be Sundays. On a Sunday rodeo the same morning game works, inside the normal window.
- **The field after the parking.** A Saturday of cars can leave ruts and litter. Agree with Ramiro who clears the field Saturday night, and check it early Sunday.
- **Finish by sunset.** With no lights, the latest Sunday kickoff is about two hours before sunset.
|Date|Sunset (about)|Latest kickoff
|Mid-April|7:35 PM|5:30 PM
|Mid-May to early August|8:05–8:30 PM|6:00 PM
|Early September|7:25 PM|5:15 PM
|Mid-September|7:05 PM|5:00 PM
|Mid-October|6:30 PM|4:30 PM
|Early November|4:55 PM|2:45 PM
- **Moving a game after the schedule is out.** Saturday to Sunday, or back, needs at least 14 days' notice unless both clubs agree (section 3.2.5). A time change of more than two hours needs 7 days.$b$),

(6, 'Bringing the rodeo crowd over', $b$The rodeo crowd does not know there is a game. We tell them, at the gate and before the day.
- **Free entry to the soccer.** The aim is people in the stands, not ticket money.
- **One wristband for both.** Ask Ramiro whether rodeo tickets can say "Lighthouse soccer free, 11 AM", and whether early arrivals can come in for the game.
- **On the rodeo's own channels.** The match goes on the rodeo's posts, flyers and announcer: "Lighthouse plays at 11 on the main field." On a Plan B weekend: "Lighthouse plays here tomorrow."
- **The early crowd.** Vendors, the rodeo's staff and the first families arrive before the gates. A morning game is the thing to watch while they set up.
- **Somewhere to stand and sit.** Bleachers facing the pitch, and ask whether a food vendor can open early.
- **Noise.** An announcer for line-ups and goals, music at half-time, the players walking out with the youth teams.
- **Who the rodeo crowd is.** Ask Ramiro. If many of his crowd follow soccer, say so on everything: the clubs we play, the countries our players come from. Ramiro's own LFC games at Lighthouse in spring 2025 are a start: ask how many came.$b$),

(8, 'What to check', $b$- **Ramiro: when the cars come.** On each date, what time parking starts on our field. That sets the kickoff.
- **The commissioner.** Whether our conference allows Saturday mornings, and whether the commissioner will approve them on rodeo weekends. Ask before the 2027 schedule is made, with the rodeo dates in hand.
- **The visiting teams.** A Saturday morning is outside the window, so each visitor must agree. Teams travelling far may not want an 11 AM start.
- **Lights.** We have none. Rented light towers would open up evening games on normal days, but not on a rodeo day, when the field is the car park.
- **The field after parking.** Ruts and litter after a rodeo Saturday, before a Sunday game.
- **Referees** for a Saturday morning.
- **Players.** Some men work Saturdays. Check the squad before asking the league.
- **CASA.** Liga 1 has its own rules on match days and times. Check them before putting Liga 1 on a rodeo Saturday.$b$),

(10, 'Steps', $b$- **1 Ramiro.** Get the 2027 rodeo dates, the time parking starts on each, and whether any can be Sundays. Agree on cross-promotion.
- **2 The commissioner.** Ask for Saturday-morning home games on rodeo weekends, with Sunday as the fallback, before the 2027 schedule is made.
- **3 The home dates.** Send every rodeo weekend as "Saturday 11 AM, or Sunday", before the schedule is released.
- **4 The squad.** Check who can play Saturday mornings.
- **5 Match day.** Signs, bleachers facing the pitch, an announcer, music, youth walk-out, the pitch cleared before parking.
- **6 Tell people.** The rodeo's channels, the club's Instagram, a table at the rodeo for the Sunday game.
- **7 Count.** A head count at every home game.$b$),

(11, 'Decisions', $b$- **Go or no go:** do we ask Ramiro and the commissioner for rodeo-weekend home games in 2027?
- **Kickoff:** 11 AM or noon on the Saturday, depending on when parking starts?
- **Plan B:** Sunday after the rodeo when a Saturday is refused, yes?
- **Which teams:** APSL only, or Liga 1 and the women as well, where their leagues allow?
- **Lights:** price rented light towers for normal-day evening games, or stay daylight only?
- **Free entry:** yes, for 2027?$b$);

UPDATE proposal_sections s SET heading = r.h, body = r.b
  FROM proposals p, _rodeo r
 WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.sort_order = r.o AND r.o <> 5;

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, r.o, r.h, r.b FROM proposals p, _rodeo r WHERE p.code = 'rodeo-day-crowds' AND r.o = 5
ON CONFLICT (proposal_id, sort_order) DO NOTHING;

UPDATE proposal_sections s
   SET body = replace(s.body, '|An evening home game before the concert, if the league allows', '|A home game that morning, finished before the concert crowd parks')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.heading = 'Other big days';

UPDATE proposals
   SET summary = 'From James Breslin: thousands come to Lighthouse for the rodeo and concerts, and almost nobody comes to the soccer. Play men''s home games on rodeo Saturdays in the morning, finished before the crowd parks on our field (no lights, APSL Saturday window is 6–9 PM so the visitor and commissioner must agree), with the Sunday as Plan B.',
       as_of = '2026-11-25'
 WHERE code = 'rodeo-day-crowds';

COMMIT;
