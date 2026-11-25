-- 🚀 Proposal: APSL Pro — a Division III men's league built from APSL clubs
-- (James 11/24 "need a proopsal for apsl 'pro' and what we we need to do get
-- sanctioning as 3rd division even provisioanl at first. use ... current
-- clubs in usl league one and usl champtionsip and mls as examples of types
-- of clubs i think we need 8 teams to lanuch?" + "i nee this on proposals
-- page" + "i need it so it can be started as soon as possilbe and grow to 8
-- right?" + "would it be able to be benifit corparation and we could take
-- investors?" + "could it be non profit? we need both models in proposal and
-- prso and cons" + "we would need it setup with revenue share with clubs
-- right? ... revenue share with leagues below too to make them sustainalbe
-- and provide solidarity"). The split percentages are ours, for discussion.  A new #proposals row drawn from proposal_sections
-- (#proposals/apsl-pro).
--
-- Every U.S. Soccer rule is from the Professional League Standards dated
-- 3-26-2026 (Section I general; Section VI Division III Men's Outdoor;
-- Section II/III/VII for the grow-into comparisons).  Read 11/24 from the
-- PDF text.  Key finding for "start small and grow to 8": Division III men
-- has NO grow-into schedule ("League must have a minimum of 8 teams to
-- apply"), unlike Division II men (8 → 10 by year four) and Division III
-- women (6 → 8 by year three).  Fewer than 8 needs a one-year waiver (I.f)
-- or the Board's discretion / provisional sanctioning (I.g).
-- Club histories and NISA's 2018–19 timeline are press reports, named in
-- Sources.  Ownership-law points are ours and flagged for a lawyer.

BEGIN;

INSERT INTO proposals (code, icon, title, summary, status_code, as_of, screen, sort_order) VALUES
    ('apsl-pro', '🚀', 'APSL Pro: a third division from APSL clubs',
     'From James Breslin: turn the APSL''s strongest clubs into a Division III professional league. U.S. Soccer needs 8 teams to apply. Start with a pre-pro season as soon as clubs are ready, apply for provisional sanctioning at 8. Two ownership models compared: nonprofit and benefit corporation.',
     'draft', '2026-11-24', NULL, 5)
ON CONFLICT (code) DO NOTHING;

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, v.o, v.h, v.b
  FROM proposals p
  JOIN (VALUES
    (1, 'Summary', $b$From James Breslin.
Build **APSL Pro**, a men's professional league at **Division III**, the same level as USL League One and MLS NEXT Pro, out of the APSL's strongest clubs.
A new league has two advantages over joining USL League One. There is **no $5 million entry fee** to the USL, and the clubs set the rules, the season and the costs together.
U.S. Soccer still sets the floor. The league needs **8 teams to apply**. Each team needs an owner worth $10 million, a $250,000 bond, and a 1,000-seat stadium. The league needs a full-time commissioner and an office.
The money is shared: **equally among the pro clubs, and down to the amateur clubs beneath** so the whole pyramid is sustainable.
The plan: **start now with the clubs that are ready**, run a pre-pro season inside the APSL, and apply to U.S. Soccer for **provisional sanctioning** as soon as 8 teams can sign.$b$),

    (2, 'Can we start small and grow to 8?', $b$Not as a sanctioned Division III league. The men's Division III rule is a floor at the door, not a target to grow into.
|League level|Teams to apply|Grow to
|Division II men (USL Championship)|8|10 by year four
|**Division III men (USL League One, APSL Pro)**|**8**|**No grow-into rule**
|Division III women|6|8 by year three
So 8 is the number. There are three ways to start sooner:
- **Pre-pro season first.** Run APSL Pro as the APSL's top flight with as many clubs as are ready, even 4 to 6, under the sanctioning the APSL already has. Clubs build to the professional standard while they play. When 8 can sign, apply.
- **A one-year waiver.** The league can ask U.S. Soccer in writing to waive any standard, the team count included, for good cause. A waiver lasts one year and must show the steps to fix it.
- **Provisional sanctioning.** The U.S. Soccer Board can approve a league that does not fully comply, in its discretion, and use provisional sanctioning when it thinks a league may fall short. NISA was approved this way in February 2019 and played its first game in August 2019, with 8 teams.
Asking to launch with fewer than 8 is allowed to be asked. We found no league that has been sanctioned that way. The safe plan is 8 signed, with waivers for smaller gaps such as seats or coaching licences.$b$),

    (3, 'What U.S. Soccer requires', $b$From the U.S. Soccer Professional League Standards dated March 26, 2026.
**The league**
|Requirement|The standard
|Teams|At least **8** to apply. At least 75% based in the United States
|Champion|Decided each year, by the season or a playoff
|Office|A central office open in business hours all year
|Commissioner|A **full-time** chief executive or commissioner
|League staff|Publicity, marketing and sponsorship programmes, a director of officials (or delegated to U.S. Soccer), a professional registrar, a disciplinary body
|Referees|U.S. Soccer licensed or approved
|Player safety|Code of conduct signed by every team and player, anti-harassment policy, confidential reporting line, yearly player survey
|Reporting|An annual report to U.S. Soccer: compliance, finances, attendance and gate, youth development, team culture
|Media|Annual media guide, weekly statistics, regular press releases
|Cost of review|The league pays U.S. Soccer's costs of checking its finances
**Each team**
|Requirement|The standard
|Principal owner|Owns at least **15%**, has a controlling interest and authority to bind the team, and is worth at least **$10,000,000** not counting the team or a primary home. U.S. Soccer can audit it
|Three years|The ownership group shows it can run the team for three years, with a detailed budget
|Bond|**$250,000** a team, or league funds held to cover it (8 teams: $2,000,000). Used up during a season, it is refilled 120 days before the next
|Stadium|At least **1,000 seats**, controlled entry and exit
|Pitch|At least 70 × 110 yards, FIFA-approved surface
|Cup|Play in the U.S. Open Cup
|Coaches|Licences set by the standards. From 2026 waivers for coaches are limited
|Owner meeting|Each principal owner, and the league's senior staff, meet U.S. Soccer before the first game
Division III men has **no time-zone rule and no minimum city size**. Division II has both. A league along the East Coast with one or two clubs inland is allowed.$b$),

    (4, 'Types of clubs we can learn from', $b$Every professional club in the U.S. fits one of four shapes. APSL Pro clubs will be the last two.
|Type|Examples today|What it took|For APSL Pro
|Big-money franchise|**MLS:** Philadelphia Union, owned by an investor group, plays at Subaru Park|An expansion fee in the hundreds of millions and a large stadium|Not us. The Union's reserve side, Union II, plays in MLS NEXT Pro at Division III, our level
|Long-running club that stayed independent|**USL Championship:** Pittsburgh Riverhounds (since 1999). **USL League One:** Richmond Kickers (since 1993)|Local owners, a modest stadium, decades of steady running|The model for clubs with long roots, like Lighthouse (1893)
|Amateur club that climbed with its fans|**Detroit City FC:** amateur NPSL side, then NISA (Division III), now USL Championship (Division II). **Chattanooga FC:** amateur NPSL, then NISA, now MLS NEXT Pro. **Oakland Roots:** a founding NISA club in 2019, now USL Championship|Supporters, sold-out small grounds, fan share sales, then a real owner|**The closest model.** Detroit City and Chattanooga are where APSL clubs are now
|New local group in a mid-size city|**USL League One:** Union Omaha, Forward Madison, One Knoxville, Westchester SC|A local investor group, a rented or rebuilt stadium, the USL entry fee|What a market without a strong APSL club would need
Detroit City and Chattanooga both did one more thing: they sold shares to their own fans. Chattanooga became a benefit corporation to do it. See the ownership models below.$b$),

    (5, 'The first 8: one club from each conference', $b$The APSL already has eight conferences. One founding club from each gives the 8 teams the league needs to apply.
|Conference|Area|Clubs today (APSL table)
|Delaware River|Philadelphia, South Jersey|Lighthouse 1893 SC, Philadelphia Ukrainian Nationals, Philadelphia Heritage SC, WC Predators and others
|Metropolitan|New York, North Jersey|NY Greek Americans, NY Pancyprian Freedoms, Hoboken FC 1912, Lansdowne Yonkers FC and others
|Constitution|Connecticut|Glastonbury Celtic, KO Elites, Hermandad Connecticut and others
|Mayflower|Massachusetts|Dorchester City FC, Somerville United FC, New England Combine FC and others
|Mid-Atlantic|Maryland, Virginia|Baltimore City FC, MoCo 1776, Nova FC and others
|Mitten|Michigan|Inter Detroit, Grand Rapids SC, Hamtramck City FC and others
|Terminus|Georgia|Terminus FC, Buckhead SC, Peachtree FC and others
|Trinity|Texas|Midcities FC, AC Arlington FC, DFW Super Eagles and others
These are clubs playing in the APSL now, not clubs that have agreed to anything. The founding club in each area could be one club, or two or three merged into one professional side for that city, with the others staying in the APSL beneath it.
The amateur conferences carry on as they are. They become the pyramid under APSL Pro.$b$),

    (6, 'Ownership model A: nonprofit', $b$The team is run by a nonprofit, like Lighthouse itself.
**The problem with the rule.** U.S. Soccer requires a principal owner who owns at least 15% and is worth $10 million. A 501(c)(3) nonprofit has no owners and no shares, so a team that is wholly a nonprofit cannot meet the rule as written. Two ways round it:
- **A waiver**, asked for each year, for a community-owned team. U.S. Soccer has not published one.
- **A team company owned mostly by the nonprofit**, with one person holding 15% or more and meeting the $10 million rule. The lawyer must confirm how a 15% holder can have the "controlling interest" the rule asks for while the nonprofit holds the rest.
|Pros|Cons
|Gifts are tax-deductible, so donors and foundations can give|**No investors.** Nobody can buy a share or get a return
|Grants: city, state, foundations, sports-for-good funds|Running a pro team is not a charitable purpose by itself. Ticket, sponsorship and TV income may be taxed as unrelated business income, and too much of it risks the tax exemption
|Mission first: profit cannot be taken out|Pay for players and staff must be reasonable and approved by the board. No one may benefit privately
|The club can never be sold away from its community|Fails the principal-owner rule as written, so it needs a waiver or a second company anyway
|Fits Lighthouse, which is a nonprofit already|Slower: a board decides, there is no owner who can write a cheque fast
**Closest example.** The Green Bay Packers in the NFL are owned by their community, pay no dividends and cannot move. The NFL banned new ownership like that in 1960 and kept Green Bay as the exception. No U.S. professional soccer club is run as a 501(c)(3).$b$),

    (7, 'Ownership model B: benefit corporation', $b$The team is a **benefit corporation**: a company with shareholders that writes a public purpose, such as youth soccer and the neighbourhood, into its charter. Pennsylvania allows it. Chattanooga FC is one.
**Yes, it can take investors.**
- **A principal owner** buys 15% or more and meets the $10 million rule. This is the shape U.S. Soccer's rule expects.
- **Other investors** can own the rest. The rule counts only the principal owner's net worth.
- **Fans can buy shares** through equity crowdfunding (Regulation Crowdfunding), up to $5 million a year. Chattanooga FC sold shares to thousands of supporters in 2019. Detroit City FC sold shares to its fans in 2020.
- **Lighthouse can hold shares too**, in return for the name, the history and the use of the ground, and a seat on the board.
|Pros|Cons
|**Can take investors and fan shareholders**|Gifts to it are not tax-deductible. Donors give to Lighthouse, not to the team
|Meets the principal-owner rule as written. No waiver needed|Investors expect a return some day. Professional Division III clubs rarely make a profit
|The public purpose is in the charter: directors must weigh it, not only profit|A yearly benefit report must be published
|Fan shares build the crowd and the money together, as at Detroit and Chattanooga|A crowdfunding offer needs filings, an online portal and yearly reports to shareholders
|Can borrow, sell sponsorship and media rights with no limit on business income|Control can move to whoever buys the most shares, unless the charter protects it
|Can be sold or merged if it ever has to be|The purpose can drift if the board stops caring
**However many fans own shares,** the principal owner still has to be one real person, named in the company's documents and open to audit.$b$),

    (8, 'Recommended: both together', $b$Use each model for what it does best. This is how Chattanooga and others combine community and money.
- **Lighthouse stays the nonprofit.** It keeps the youth teams, the amateur men and women, the ground and the history. Gifts and grants go here.
- **The professional team is a Pennsylvania benefit corporation.** Its purpose: professional soccer for Philadelphia, a path for Lighthouse youth, and the neighbourhood.
- **Shares:** a principal owner with 15% or more who meets the $10 million rule; Lighthouse with a block of shares and a board seat for the name and the ground; fans through a crowdfunding offer; other investors for the rest.
- **The charter protects** the name, the home in Philadelphia, and Lighthouse's board seat, so the team cannot be moved or renamed by a buyer.
**The league** can follow the same pattern: APSL stays the amateur body, and APSL Pro is a company owned by its founding clubs.
The points on nonprofit and securities law are ours. A lawyer must confirm them before any money is taken.$b$),

    (9, 'Revenue share and solidarity', $b$A league of 8 small clubs only lasts if the money is shared: across the clubs, so no one club falls behind and folds, and down the pyramid, so the amateur clubs under APSL Pro are fed by it.
**Why it matters.** Small leagues lose clubs when the weakest cannot pay. NISA lost clubs every season. A shared pot keeps every club able to pay its players and its bond. Sharing with the amateur clubs keeps the pyramid underneath alive and gives them a reason to send players up.
**Shared among the pro clubs**
- **Into one league pot:** league sponsorship, streaming and TV, league-wide merchandise, the playoff final, and a small share of every gate.
- **Out in equal shares** to the 8 clubs, the way the NFL splits its TV money. A club in a small market gets the same as one in a big market.
- **The home gate** stays mostly with the home club, so clubs still work to fill their ground.
- **The bond fund.** Part of the pot builds the league fund that U.S. Soccer accepts in place of each club's $250,000 bond, so clubs do not each tie up the cash.
**Shared down the pyramid (solidarity)**
- **A fixed share of the league pot** goes to the APSL conferences below, split by the number of clubs in each, for referees, fields and running costs.
- **Training reward.** When an APSL Pro club sells a player, a share goes to the amateur and youth clubs that trained him, the way FIFA's solidarity rule pays 5% on international transfers. U.S. Soccer does not require this at home, so APSL Pro writes it into its own rules.
- **A club stepping down** (a bad year, an owner leaving) gets a reduced share for a season or two as it drops back into the APSL, instead of folding. This is the graceful way back down that the professional standards lack today.
**A starting split for discussion** (our numbers, to be set by the founding clubs)
|Share of the league pot|Goes to
|70%|The pro clubs, in equal shares
|10%|The bond fund and league reserve, until it holds 8 × $250,000
|10%|Solidarity to the APSL conferences below
|5%|Youth: clubs whose own players reach APSL Pro
|5%|A club stepping down, for up to two seasons
Other leagues do the same: the NFL shares national TV money equally, MLS runs as one company and shares centrally, and England's Premier League pays solidarity money to the leagues below it.$b$),

    (10, 'What it costs', $b$Per team. The bond is U.S. Soccer's. The running cost is a press figure for USL League One from about 2019 and is likely higher now. There is no USL entry fee in APSL Pro.
|Item|Per team|Source
|Entry fee to the league|Set by APSL Pro, not $5,000,000|The founding clubs decide
|Performance bond, or a league fund|$250,000|U.S. Soccer standards
|Running the team for a year|$1,300,000–$1,900,000|Beautiful Game Network, about 2019
|Three years' running, which must be shown|$3,900,000–$5,700,000|
A lean league can run below that range: a shorter season, regional travel by bus, part-time staff (Division III allows it), and stadiums shared with colleges or high schools.
**The league** needs its own budget: a full-time commissioner, an office, a registrar, a director of officials, marketing, legal and U.S. Soccer's review costs.$b$),

    (11, 'Timeline', $b$Our estimate, not a promise. NISA applied in September 2018, was provisionally approved in February 2019, and played in August 2019: about a year.
|When|Step
|Winter 2026–27|Talk to the APSL board and to the strongest club in each conference. Pick the ownership model. A lawyer reads the standards
|Spring 2027|Form APSL Pro as a company. Each founding club looks for its principal owner. Count seats at each ground
|2027 season|**Pre-pro season**: APSL Pro as the APSL's top flight with every club that is ready, under the APSL's present sanctioning
|By autumn 2027|8 clubs signed, each with an owner, a three-year budget and a stadium. Apply to U.S. Soccer, asking for provisional sanctioning and waivers for any smaller gaps
|Winter 2027–28|U.S. Soccer reviews. Owners meet U.S. Soccer. Bonds posted. Commissioner hired
|**2028**|First professional season, and the U.S. Open Cup$b$),

    (12, 'Steps', $b$- **1 The APSL.** Put APSL Pro to the APSL board. The pro league sits on top of the APSL, not against it.
- **2 Founding clubs.** One club in each of the eight conferences that wants to go professional.
- **3 Ownership.** Each club picks nonprofit, benefit corporation, or both together, and finds its principal owner.
- **4 The league company.** Form APSL Pro, owned by the founding clubs. Write its rules, season, fees, the revenue share and the solidarity share.
- **5 Pre-pro season.** Start as soon as clubs are ready. Grow to 8.
- **6 Apply.** With 8 signed, apply to U.S. Soccer for provisional Division III sanctioning, with written waiver requests for what is still missing.
- **7 Hire.** A full-time commissioner, a registrar, a director of officials.$b$),

    (13, 'Decisions', $b$- **Go or no go:** do we take APSL Pro to the APSL board?
- **Ownership model for Lighthouse's team:** nonprofit, benefit corporation, or both together (recommended)?
- **Founding clubs:** who do we talk to first in each conference?
- **Revenue share:** the split of the league pot between the clubs, the bond fund and the amateur clubs below?
- **Year:** pre-pro season in 2027, first professional season in 2028?$b$),

    (14, 'Sources', $b$- [U.S. Soccer Professional League Standards, March 26, 2026](https://cdn.sanity.io/files/oyf3dba6/production/c3f3ba1dd726d87f1079c91c12827958ad2aadda.pdf): every league and team rule, the 8-team minimum, waivers and provisional sanctioning
- [Soccer Stadium Digest](https://soccerstadiumdigest.com/2019/02/nisa-granted-provisional-division-iii-sanctioning/): NISA's provisional Division III sanctioning, February 2019
- [SocTakes](https://soctakes.com/2018/09/04/breaking-nisa-applies-for-d3-sanctioning): NISA applied in September 2018
- [Soccer Stadium Digest](https://soccerstadiumdigest.com/2019/07/nisa-fall-2019-competition-scheduled/): NISA's first season, autumn 2019
- [Hudson River Blue](https://www.hudsonriverblue.com/apsl-no-longer-affiliated-with-nisa-nation-2/): the APSL and NISA Nation
- [Front Office Sports](https://frontofficesports.com/chattanooga-fc-ownership): Chattanooga FC's fan ownership
- [NBC Sports](https://www.nbcsports.com/soccer/news/chattanooga-fc-opens-up-true-ownership-to-its-supporters): Chattanooga FC's 2019 share sale
- [Detroit City FC](https://www.detcityfc.com/news/2020/07/30/detroit-city-fc-launches-public-campaign-to-sell-portion-of-club-to-fans): Detroit City's 2020 fan share sale
- [Beautiful Game Network](https://www.bgn.fm/forcing-the-us-soccer-pyramid-league-and-team-rules/): running costs of $1.3–$1.9 million a year
- [Front Office Sports](https://frontofficesports.com/brooklyn-expansion-franchise-extends-usls-rise/): USL League One entry fee of $5 million
- [The American Prospect](https://prospect.org/2026/02/12/feb-2026-magazine-sports-green-bay-packers-nonprofit-community-owned/): the Green Bay Packers and the NFL's 1960 rule$b$)
  ) AS v(o, h, b) ON true
 WHERE p.code = 'apsl-pro'
ON CONFLICT (proposal_id, sort_order) DO NOTHING;

COMMIT;
