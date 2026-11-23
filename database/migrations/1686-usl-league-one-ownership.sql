-- 🏆 USL League One proposal: Ownership becomes the lead section (James 11/23
-- "how do we solve the net worth owner standard if we are a non profit with a
-- board and no owner?" + "do deep dive on ownership waivers" + "this is THE
-- most important part of the proposal and plan").
--
-- New section 2 "Ownership" (old 2–9 move to 3–10): the rule as written, the
-- March 2026 cut from 35% to 15%, what the public record shows on waivers
-- (E.D.N.Y. 11/4/2017 ruling in NASL v. USSF, 2d Cir. 2/23/2018, SI 10/4/2017),
-- what community clubs did, and three routes. No public case of the owner
-- net-worth standard being waived for a club was found; the page says so.
-- Also: USL's own League One figures from its 2018 prospectus (3,500 seats,
-- market of 150,000) go into the stadium section.

BEGIN;

UPDATE proposals SET
  summary = 'From James Breslin: what it takes to put Lighthouse in USL League One, the third division of U.S. professional soccer. The owner standard comes first: one person worth $10 million holding at least 15%. Then a stadium, and about $6.5–$7 million in year one.'
WHERE code = 'usl-league-one';

-- old 2–9 → 3–10 (two steps: UNIQUE (proposal_id, sort_order))
UPDATE proposal_sections s SET sort_order = s.sort_order + 100
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.sort_order BETWEEN 2 AND 9;
UPDATE proposal_sections s SET sort_order = s.sort_order - 99
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.sort_order BETWEEN 102 AND 109;

UPDATE proposal_sections s SET body = $b$From James Breslin.
Put a Lighthouse men's team in **USL League One**, the third division of U.S. professional soccer.
A club does not win its way in. It applies to the league, pays an entry fee, and must meet the U.S. Soccer Professional League Standards for Division III.
**Ownership decides it.** The standards require one person worth at least $10 million who owns at least 15% of the team and controls it. Lighthouse is a nonprofit with a board and no owner. The Ownership section sets out how to solve that.
After that it is **a stadium** and **about $6.5–$7 million in year one**. Lighthouse already has the full-size pitch, the youth teams and the history.$b$
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.sort_order = 1;

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, 2, 'Ownership', $b$**The rule.** Each team "must designate one principal owner with a controlling interest who owns at least 15% of the team and has authority to bind the team." That owner "must have an individual net worth of at least ten million US dollars," not counting the team or a primary home. U.S. Soccer can order an audit to prove it.
**Our problem.** Lighthouse is a nonprofit run by a board. It has no owner. The rule counts one person's own wealth, so a board cannot meet it, and neither can the nonprofit's own assets.
**What changed in March 2026.** The share the principal owner must hold fell from 35% to 15%. The $10 million did not change. One person can now hold as little as 15%, and the other 85% can sit with someone else. For us that someone else can be Lighthouse.
**Waivers: what the rule says**
- The league asks, not the club. The USL would have to ask U.S. Soccer for us.
- The request is in writing: which standard, why a waiver is needed, and the steps being taken so it is not needed again.
- A waiver lasts one year.
- The U.S. Soccer Board grants one only "for good cause."
**Waivers: what the record shows**
|League|Years|What was waived
|MLS, Division I|Early years, 2012, 2013|Number of teams (8 when 10 were required), then team items
|NASL, Division II|Every year from 2011 to 2017 except 2013|Number of teams, time zones and others
|USL|2013, 2014, 2017|Team items. In 2017: two turf fields without FIFA certification and two stadiums of the wrong size
|NASL, Division II|2018|Asked for teams and time zones. **Denied**; the league lost its sanction
- Waivers are common. U.S. Soccer has granted them to every league.
- U.S. Soccer told a federal court that team waivers cover "less critical issues": coaching licences, a few hundred extra seats, field measurements.
- The same court recorded why the net worth rule exists: it stops an owner underfunding a team. U.S. Soccer treats it as a core rule, not a small one.
- In 2014 the U.S. Soccer president said too many waivers were hurting the standards.
- **We found no public case of the owner net worth rule being waived for a club.** U.S. Soccer does not publish its waiver decisions. Only the USL can tell us if it has happened.
**What community clubs did**
|Club|Ownership|What happened
|Detroit City FC|Five founders, then shares sold to supporters|To go pro it restructured so one owner held 35% and was worth $10 million
|Chattanooga FC|More than 3,200 supporter shareholders|Has a primary owner beside them. Plays in MLS Next Pro, also Division III
|Minnesota Aurora (women)|Community-owned|Withdrew its professional bid with no lead investor. Still amateur
|San Francisco City FC|51% a members' nonprofit, 49% investors|Plays in USL League Two, which is amateur and has no owner rule
Each club that went professional found a person who met the rule. None went in on a waiver that we can find.
**Three routes**
|Route|How it works|Risk
|**A A principal owner at 15%**|The professional team sits in its own company. One person worth $10 million holds 15% and control. Lighthouse holds up to 85%|That person, not the board, controls the team
|B A waiver|The USL asks U.S. Soccer to accept Lighthouse without a principal owner, with something in its place: a larger bond, a guarantor, or three years of costs paid up front|One year at a time. No case found of it being granted
|C USL League Two first|Play in the amateur league below, which has no owner rule, while the owner is found|It is not professional soccer
**Recommended: Route A.** It is the only route U.S. Soccer has plainly accepted. The owner can be a benefactor who does it for the club and not for profit. Lighthouse keeps its place by contract:
- Lighthouse owns the name and the crest and licenses them to the team company.
- The team cannot move or change its name without Lighthouse's consent.
- Lighthouse holds seats on the team company's board.
- If the owner leaves, Lighthouse has the first right to choose who follows.
**Questions for the USL at the first meeting**
- Has U.S. Soccer ever waived the owner rule for a League One club?
- What must "controlling interest" look like when the owner holds 15%?
- Can a nonprofit hold the other 85%?
- Would a guarantor or a larger bond be accepted in place of a principal owner?
A nonprofit holding a share of a professional team raises tax questions. A nonprofit lawyer must review the structure before anything is signed.$b$
  FROM proposals p WHERE p.code = 'usl-league-one'
ON CONFLICT (proposal_id, sort_order) DO NOTHING;

-- Where Lighthouse stands: the owner row names the real gap.
UPDATE proposal_sections s SET body = replace(s.body,
  '|Owner worth $10 million|None named|**The main gap**',
  '|One owner worth $10 million holding 15%|A nonprofit with a board and no owner|**The main gap.** See Ownership')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Where Lighthouse stands';

-- The stadium: the USL's own League One figures.
UPDATE proposal_sections s SET body = replace(s.body,
  'League One grounds are usually bigger than the minimum. The average capacity was reported at about 5,500 in 2024.',
  'The USL asks for more than U.S. Soccer does. Its 2018 League One prospectus set 3,500 seats and a home market of at least 150,000 people. The average capacity in the league was reported at about 5,500 in 2024. The USL''s current figures are a question for the first meeting.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'The stadium';

-- Steps and Decisions follow the ownership route.
UPDATE proposal_sections s SET body = replace(replace(s.body,
  '- **1 Owner.** Find a principal owner who meets the $10 million standard and will own at least 15%.',
  '- **1 Owner.** Find a benefactor worth $10 million who will be principal owner of the team company at 15%, with Lighthouse holding the rest. Have a nonprofit lawyer draw up the structure.'),
  '- **2 USL.** Meet the USL expansion staff. Get the real entry fee, the yearly league fees and the league''s own stadium rules.',
  '- **2 USL.** Meet the USL expansion staff. Ask the ownership questions first. Get the real entry fee, the yearly league fees and the league''s own stadium rules.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Steps';

UPDATE proposal_sections s SET body = replace(s.body,
  '- **Owner:** who do we approach?',
  '- **Ownership route:** A a principal owner at 15%, B a waiver, or C USL League Two first?
- **Owner:** who do we approach?')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Decisions';

UPDATE proposal_sections s SET body = s.body || $b$
- [Midfield Press](https://midfieldpress.com/2026/05/03/what-the-new-ussf-ownership-rule-signals-for-pro-soccer/): the March 2026 cut from 35% to 15%
- [NASL v. U.S. Soccer, federal district court ruling, November 4, 2017](https://www.courthousenews.com/wp-content/uploads/2018/02/NASL-nov-ruling-ruling.pdf): waivers by league and year, team waivers, why the net worth rule exists
- [NASL v. U.S. Soccer, appeals court, February 23, 2018](https://caselaw.findlaw.com/court/us-2nd-circuit/1890279.html): how waivers are decided, NASL's 2018 denial
- [Sports Illustrated, October 4, 2017](https://www.si.com/soccer/2017/10/04/usl-division-2-application-us-soccer-nasl-lawsuit-jake-edwards): the USL's four waiver requests
- [Detroit News](https://www.detroitnews.com/story/sports/soccer/2020/07/30/niyo-detroit-city-fc-offers-piece-ownership-its-supporters/5545513002/): Detroit City FC's restructure
- [Chattanooga FC](https://chattanoogafc.com/news/grizzard-investment-mls-next-2025-2026-chattanooga-youth-soccer): supporter shareholders and a primary owner
- [Star Tribune](https://www.startribune.com/nwsl-minnesota-aurora-denver-kansas-city-current/601355160): Minnesota Aurora
- [San Francisco City FC](https://en.wikipedia.org/wiki/San_Francisco_City_FC): 51% members' nonprofit
- [USL League One prospectus, 2018](https://cdn3.sportngin.com/attachments/document/8027-1728291/League_OneProspectus_12718.pdf): the USL's own seat and market figures$b$
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Sources';

COMMIT;
