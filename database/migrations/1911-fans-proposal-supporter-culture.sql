-- 📣 The rodeo-day proposal becomes the FANS proposal: build a supporter
-- culture so the club can raise money for the youth; rodeo weekends are one
-- lever (James 11/25 "what do other clubs in country do to attract fans. i
-- know the summer usl2 etc do and npsl" / "we need this all in that prposal.
-- its really a get fans proposal" / "to create a suporter culture" / "so we
-- can raise money for club right? for youth etc").
--
-- Code stays 'rodeo-day-crowds' so existing links and the PDF path hold.
-- Other clubs, from published sources (no figure here is ours):
--   Annapolis Blues FC (NPSL, then USL League Two): Goal.com, Tom Hindle,
--     2025-07-21; club release 2023-06-05.  Opener 8,368 (Jun 3 2023), conf.
--     final 8,840, 2024 opener 11,171; local owners; name/crest by fan vote
--     (1,200+ votes); youth clubs + charities + small businesses; Autograph
--     Alley (first 500 kids a mini ball); scarves, flags; water-balloon fight
--     in the car park; W League side 4,000+ a game.
--   Detroit City FC: Sports Illustrated, Brian Straus, 2021-10-04.  Five
--     friends $2,200 each; Northern Guard march from a bar through Hamtramck;
--     ~500 supporters raised $750k+ to rebuild Keyworth Stadium and painted
--     the bleachers; ~2,700 supporters raised $1.5M and own 10%; Detroit City
--     Futbol League (coed adult league) came first; Friendly the Bear mascot;
--     fieldhouse watch parties with players.
--   Chattanooga FC (NPSL): MLSsoccer.com 2015; Midfield Press.  5,117 in
--     2010 (then an NPSL regular-season record), 8,878 semifinal, 18,227 at
--     the 2015 final; Saturday nights sold as the whole experience.
--   Hub City FC (NPSL): club ticket page: founding members, supporters
--     trust, annual members' meeting.
-- Lighthouse facts: men since 1893 (section founding years), pickup
-- programs, U8–U12 youth teams, the Barn.  No money figures are invented:
-- the money section lists sources of money, not amounts.

BEGIN;

UPDATE proposal_sections s SET sort_order = s.sort_order + 100
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.sort_order >= 2;
UPDATE proposal_sections s SET sort_order = s.sort_order - 97
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.sort_order >= 102;
-- now: 1 Summary, 5 Rodeo days, 6 Spring, 7 Rodeo Saturday, 8 Plan B, 9 Bringing,
-- 10 Other big days, 11 What to check, 12 Counting, 13 Steps, 14 Decisions

CREATE TEMP TABLE _f (o int PRIMARY KEY, h text, b text) ON COMMIT DROP;
INSERT INTO _f VALUES
(1, 'Summary', $b$From James Breslin.
Thousands of people come to Lighthouse for the rodeo and the concerts. Almost nobody comes to watch our soccer.
**The goal is fans: a supporter culture around Lighthouse**, people who come every home game, wear the scarf, sing, bring their kids, and back the club with their money. That money pays for the youth: coaches, kit, fields, fees.
Clubs at our level have done it. Annapolis Blues drew 8,368 to their first home game in 2023 and 11,171 a year later. Detroit City started with five friends and a few thousand dollars and was later rebuilt by its supporters. Chattanooga drew 18,227 to an amateur final. None of them started with a crowd; they built one (see What other clubs did).
**Rodeo weekends are where we start**, because the crowd is already at the gate. Two facts shape that part. **We have no lights**, so every game ends in daylight, and on big event days **the crowd parks on our field**, so we play before the event, not during it.
- Play the men's home game on the rodeo Saturday **morning** (about 11 AM), finished before the first cars park. The APSL default Saturday window is 6 PM to 9 PM, so we ask the Delaware River Conference to allow mornings. If it will not, each game needs the visitor and the commissioner, and **if they say no, the game is on the Sunday** (Plan B), and the rodeo on Saturday is where we sell it.
- Around it, the things that turn a crowd into supporters: a supporters' group, the youth on the pitch, the same rituals every game, members who belong to the club.$b$),

(2, 'Why fans: money for the club and the youth', $b$A crowd is not the end in itself. Supporters are how a club like ours pays its way.
|Where the money comes from|How it starts at Lighthouse
|**Members**|A yearly club membership: a scarf, a members' night, a say in the club (Hub City FC in the NPSL sells founding memberships and runs a supporters' trust with an annual members' meeting)
|**Merchandise**|Scarves first, then replica shirts. Annapolis Blues sold replica jerseys and commemorative scarves from the first home game
|**Sponsors**|Local businesses on the shirt, the boards and the matchday posts. Sponsors pay for a crowd, so the head count is what we sell
|**Food and drink**|A share of vendor sales on match days, agreed with Ramiro and the vendors
|**Giving**|A bucket and a QR code at every game: "this pays for the youth teams". A charity-of-the-month or youth-of-the-month game
|**Big projects**|Later, supporters pay for things themselves: Detroit City's supporters raised over $750,000 to rebuild their stadium and painted the bleachers by hand
Entry to the soccer stays **free** at the start. A full stand is worth more to sponsors and to the club than a small gate.
Every dollar is shown: what came in from match days, and what it paid for in the youth program.$b$),

(3, 'What other clubs did', $b$Three clubs at our level, and what they did. From published accounts; the figures are theirs.
**Annapolis Blues FC** (NPSL, now USL League Two), Annapolis, Maryland. 8,368 at the first home game in June 2023, 11,171 at the 2024 opener; by the end of 2024 they held the top eight crowds in NPSL history. Their women's team drew over 4,000 a game in 2025.
- Owned by local people: small business owners, broadcasters, a former U.S. international.
- **Fans chose the name and the crest** by public vote: more than 1,200 votes. The crest is a blue crab, for the area.
- Worked with local youth clubs, nearby charities and small businesses before the first game; players came from local youth clubs.
- **Autograph Alley:** the first 500 children got a mini soccer ball and met the players.
- Scarves, replica shirts and flags in the stand from day one; a water-balloon fight in the car park before the last home game, every year.
**Detroit City FC**, Detroit. Founded by five friends who put in $2,200 each.
- The supporters' group, the **Northern Guard**, started in the club's first month. Before every game they meet at a bar and **march** half a mile through the streets to the stadium, singing. Kids wave from the porches.
- An adult **community league** (the Detroit City Futbol League) came before the senior team and tied the club to its neighbourhoods, sponsors and local officials.
- About 500 supporters raised over $750,000 to rebuild their stadium. Later about 2,700 supporters raised $1.5 million and own 10% of the club.
- A mascot, Friendly the Bear, at half-time; watch parties where fans mix with players.
**Chattanooga FC** (NPSL), Chattanooga, Tennessee. 5,117 at a regular-season game in 2010, then an NPSL record; 8,878 at a 2015 semifinal and 18,227 at the 2015 final.
- Saturday-night games sold as **the whole evening**, not just the match: the club's view is that winning helps, but people come for the experience.
**What they share:** local people own and run it; the fans are given a part (the name, the march, the stand they built); the same rituals every game; the youth and the neighbourhood are part of match day; and they told everyone, everywhere, before the first game.$b$),

(4, 'A supporter culture at Lighthouse', $b$What we copy, made ours.
- **A supporters' group.** Five to ten men's players' friends and families to start, with a name, a drum, a flag and a section of the stand that is theirs. The club gives them the space and the scarves; they give the noise.
- **The march.** Before every home game the supporters walk in together from one meeting point (the Barn, or a bar or restaurant nearby), with the drum, through the gate to their stand.
- **The youth on match day.** Every U8–U12 player walks out with the men, free. **Autograph Alley** after the game: the kids meet the players. Their parents are our first crowd.
- **Our story.** A club playing since 1893. Put it on the scarves, the flags and every post: more than 130 years of Lighthouse soccer, and it is free to watch.
- **The fans choose things.** A vote on the scarf design, the supporters' group name, the walk-out song. People back what they helped make.
- **Our community league.** Our pickup players are our Detroit City Futbol League: over a hundred people who already play at Lighthouse. Every pickup player is told about every home game, and gets in free with family.
- **The same rituals every game.** The walk-out with the youth, the drum, one song, the players clapping the stand at the end, a man-of-the-match picked by the supporters.
- **The Barn.** Watch parties for big games with the players there, like Detroit City's fieldhouse.
- **Partners.** Local businesses and youth clubs nearby, and Ramiro's rodeo and festivals: each one tells its people about our games.
- **Say it everywhere, early.** The schedule, the rodeo channels, Instagram, the youth parents' chats, the pickup lists, a flyer at every event at Lighthouse.$b$);

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, f.o, f.h, f.b FROM proposals p, _f f WHERE p.code = 'rodeo-day-crowds' AND f.o IN (2, 3, 4)
ON CONFLICT (proposal_id, sort_order) DO NOTHING;
UPDATE proposal_sections s SET heading = f.h, body = f.b
  FROM proposals p, _f f WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.sort_order = 1 AND f.o = 1;

-- Counting: members and money too
UPDATE proposal_sections s
   SET body = replace(s.body, '- **Ask at the gate**, on one rodeo day: "Did you come for the soccer, the rodeo, or both?"',
     '- **Ask at the gate**, on one rodeo day: "Did you come for the soccer, the rodeo, or both?"
- **Count the supporters too:** members signed up, scarves sold, sponsors, money given, and what it paid for in the youth program.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.heading = 'Counting the crowd';

-- Steps + decisions: the supporter culture
UPDATE proposal_sections s
   SET body = s.body || $b$
- **8 The supporters' group.** Find the first five to ten, give them a section, a drum and scarves, and a meeting point for the march.
- **9 The youth.** Walk-out and Autograph Alley at every home game; tell every youth family the schedule.
- **10 The money.** Membership, scarves, a giving bucket and QR code, and the first local sponsors, ready for the first home game.$b$
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.heading = 'Steps';

UPDATE proposal_sections s
   SET body = s.body || $b$
- **Supporters' group:** who leads it, and where the march starts?
- **Membership:** do we sell a yearly club membership in 2027, and what comes with it?
- **The fans' vote:** what do they choose first: the scarf, the group's name, the walk-out song?$b$
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'rodeo-day-crowds' AND s.heading = 'Decisions';

UPDATE proposals
   SET title = 'Get fans: a supporter culture at Lighthouse',
       summary = 'From James Breslin: build a supporter culture around Lighthouse so match days raise money for the club and the youth, copying what Annapolis Blues, Detroit City and Chattanooga did. Start on rodeo weekends: a morning game before the crowd parks on our field (no lights), the Sunday as Plan B.',
       as_of = '2026-11-25'
 WHERE code = 'rodeo-day-crowds';

COMMIT;
