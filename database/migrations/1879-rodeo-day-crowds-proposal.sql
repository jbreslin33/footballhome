-- 📣 Proposal: fans at Lighthouse home games — play on rodeo Saturdays
-- (James 11/24 "next proposal/plan. get fans to lightouse home games lol. we
-- get 1000s at the rodeo/concerts lol but cant' get fans at the soccer. we
-- can put the games as late as 2pm kickoff on rodeo days saturdays rodes are
-- like 2pm to 12am").  A new #proposals row (#proposals/rodeo-day-crowds).
--
-- Facts from the DB 11/24: ops calendar (gcal_events) 2026 rodeo Saturdays
-- = Ramiro Rodeo 14:00–00:00 on Jun 27, Jul 11, Aug 8, Sep 5, Sep 19,
-- Oct 10 (+ "Ramiro rodeo" Sep 12 20:00; Barn Post Rodeo Jul 11 21:00);
-- other big days: Concert and Western Event Fri Sep 11, Dominican Day
-- Festival Sun Aug 30 11:00–22:00, music festival hold Jun 10–12 2027.
-- Every 2026 men's and women's home game in fh_events was on a Sunday;
-- none on a rodeo day.  Invoice 17 (mig 465): a Liga 1 game moved to turf
-- because of a rodeo.  Crowd and kickoff figures are James's; the plan is ours.

BEGIN;

INSERT INTO proposals (code, icon, title, summary, status_code, as_of, screen, sort_order) VALUES
    ('rodeo-day-crowds', '📣', 'Fans at our home games: play on rodeo Saturdays',
     'From James Breslin: thousands come to Lighthouse for the rodeo and concerts, and almost nobody comes to the soccer. Move men''s home games to rodeo Saturdays, kicking off by 2 PM as the rodeo opens, and bring the rodeo crowd over to the pitch.',
     'draft', '2026-11-24', NULL, 6)
ON CONFLICT (code) DO NOTHING;

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, v.o, v.h, v.b
  FROM proposals p
  JOIN (VALUES
    (1, 'Summary', $b$From James Breslin.
Thousands of people come to Lighthouse for the rodeo and the concerts. Almost nobody comes to watch our soccer.
The crowd is already at the gate. We play at the wrong time: every men's and women's home game in 2026 was on a Sunday, and every rodeo was on a Saturday.
**The plan:** put men's home games on rodeo Saturdays, with the last kickoff at **2 PM**, when the rodeo opens. People arriving for the rodeo walk past a live game. Our players, families and fans stay on for the rodeo afterwards.$b$),

    (2, 'Rodeo days in 2026', $b$From the Lighthouse ops calendar. The rodeo runs from 2 PM to midnight.
|Date|Event|Our home game that weekend
|Sat June 27|Ramiro Rodeo|None (off-season)
|Sat July 11|Ramiro Rodeo, then Barn Post Rodeo at 9 PM|None. Intra-squad game Sunday
|Sat August 8|Ramiro Rodeo|APSL v Persepolis, **Sunday** 6 PM
|Sat September 5|Ramiro Rodeo|None
|Sat September 19|Ramiro Rodeo|None. Women's home game Sunday
|Sat October 10|Ramiro Rodeo|None
Also: a Ramiro rodeo on Saturday September 12 from 8 PM (APSL and Liga 1 at home on **Sunday** the 13th), and the Concert and Western Event on Friday September 11.
Six rodeo Saturdays, from June to October, overlap the APSL and Liga 1 fall seasons on at least four dates. Not one had a home game.$b$),

    (3, 'Rodeo Saturday: Lighthouse match day', $b$One day at Lighthouse, soccer into rodeo.
|Time|What
|10:00|Youth home games (U8–U12). Parents and kids on site early
|11:45|Liga 1 or the women at home
|**2:00**|**APSL kickoff**, as the rodeo gates open
|About 4:00|Final whistle. Players, families and fans go on to the rodeo
|2:00–midnight|Rodeo
If only one game fits, it is the APSL game at 2 PM. If 2 PM is too late for the rodeo's setup, kick off at noon so the second half meets the first rodeo arrivals.$b$),

    (4, 'Bringing the rodeo crowd over', $b$The rodeo crowd does not know there is a game. We tell them, at the gate and before the day.
- **Free entry to the soccer.** The aim is people in the stands, not ticket money.
- **One wristband for both.** Ask Ramiro whether rodeo tickets can say "Lighthouse soccer free, 2 PM", and whether a rodeo discount can go to anyone at the game.
- **On the rodeo's own channels.** The match goes on the rodeo's posts, flyers and announcer: "Lighthouse plays at 2 on the main field."
- **A route past the pitch.** The way from parking to the rodeo walks along the touchline, with a sign at the gate: "Lighthouse 1893 v [opponent], kickoff 2 PM."
- **Somewhere to stand and sit.** Bleachers moved to face the pitch, and the rodeo's food vendors open from noon so people eat while they watch.
- **Noise.** An announcer for line-ups and goals, music at half-time, the players walking out with the youth teams.
- **Who the rodeo crowd is.** Ask Ramiro. If many of his crowd follow soccer, say so on everything: the clubs we play, the countries our players come from.$b$),

    (5, 'Other big days', $b$The same idea works whenever a crowd is already coming.
|Day|Event|Our chance
|Sun August 30, 2026|Dominican Day Festival, 11 AM–10 PM|A Sunday: our normal game day
|Fri September 11, 2026|Concert and Western Event|A Friday night game under the concert lights, if the league allows
|June 10–12, 2027|Music festival (held)|A home game on the Saturday or Sunday
Every new big rental on the ops calendar should ask one question: is there a home game we can put next to it?$b$),

    (6, 'What to check', $b$- **The leagues.** APSL and CASA games are mostly on Sundays. Moving a home game to Saturday needs the league, and usually the opponent, to agree. Ask before the schedule is made, with the 2027 rodeo dates in hand.
- **The rodeo's space.** In 2026 one Liga 1 game had to move to turf because of a rodeo. Agree with Ramiro which pitch we use, where the rodeo sets up, and parking.
- **Referees and field prep** for a Saturday, not our usual Sunday.
- **Players.** Some men work Saturdays. Check the squad before asking the league.
- **Lights and timing.** A 2 PM kickoff ends near 4 PM, long before dark. A later game needs lights.$b$),

    (7, 'Counting the crowd', $b$We do not know what works unless we count.
- **A head count at every home game**, rodeo day or not: one person with a clicker at kickoff and at half-time.
- **Compare** rodeo Saturdays with normal Sundays.
- **Ask at the gate**, on one rodeo day: "Did you come for the soccer, the rodeo, or both?"
The count also matters for the future: a professional club must report its crowds to U.S. Soccer (see the APSL Pro proposal).$b$),

    (8, 'Steps', $b$- **1 Ramiro.** Get the 2027 rodeo dates and agree on the space, the 2 PM slot, and cross-promotion.
- **2 The leagues.** Ask the APSL and CASA to give us home games on those Saturdays, before the 2027 schedules are made.
- **3 The squad.** Check who can play Saturdays.
- **4 Match day.** Signs, bleachers facing the pitch, an announcer, music, youth walk-out.
- **5 Tell people.** The rodeo's channels, the club's Instagram, flyers at the rodeo the month before.
- **6 Count.** A head count at every home game.$b$),

    (9, 'Decisions', $b$- **Go or no go:** do we ask Ramiro and the leagues for rodeo-Saturday home games in 2027?
- **Kickoff:** 2 PM, or noon?
- **Which teams:** APSL only, or APSL plus Liga 1, the women and the youth on the same day?
- **Free entry:** yes, for 2027?$b$)
  ) AS v(o, h, b) ON true
 WHERE p.code = 'rodeo-day-crowds'
ON CONFLICT (proposal_id, sort_order) DO NOTHING;

COMMIT;
