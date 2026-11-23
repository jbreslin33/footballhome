-- 🏆 Proposal: Lighthouse in USL League One (James 11/23 "another proposal.
-- lighthouse in usl league one" + the U.S. Soccer Professional League
-- Standards PDF, dated 3-26-2026). A new #proposals row drawn from
-- proposal_sections (#proposals/usl-league-one).
--
-- Every requirement is from the Standards PDF (Section I general, Section VI
-- Division III Men's Outdoor League). The USL-side figures (entry fee,
-- running costs, season, crowds) are press reports and are named as such in
-- the page, each with its source; the running-cost range is from about 2019.
-- Year-one sum: $5,000,000 fee + $250,000 bond + $1.3–1.9M running
-- = $6.55M–$7.15M. Three years' running = $3.9M–$5.7M.

BEGIN;

INSERT INTO proposals (code, icon, title, summary, status_code, as_of, screen, sort_order) VALUES
    ('usl-league-one', '🏆', 'Lighthouse in USL League One',
     'From James Breslin: what it takes to put Lighthouse in USL League One, the third division of U.S. professional soccer. An owner worth $10 million, a 1,000-seat stadium, and about $6.5–$7 million in year one.',
     'draft', '2026-11-23', NULL, 3)
ON CONFLICT (code) DO NOTHING;

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, v.o, v.h, v.b
  FROM proposals p
  JOIN (VALUES
    (1, 'Summary', $b$From James Breslin.
Put a Lighthouse men's team in **USL League One**, the third division of U.S. professional soccer.
A club does not win its way in. It applies to the league, pays an entry fee, and must meet the U.S. Soccer Professional League Standards for Division III.
Three things decide it: **an owner worth at least $10 million**, **a stadium with 1,000 seats**, and **about $6.5–$7 million in year one**. Lighthouse already has the full-size pitch, the youth teams and the history.$b$),

    (2, 'What USL League One is', $b$- **Division III.** U.S. Soccer sanctions men's professional leagues in three divisions. MLS is Division I, the USL Championship is Division II, and USL League One is Division III.
- **Professional.** Players and coaches are paid. Our men play in the APSL today, which is amateur.
- **Season.** In 2026 the league had 17 or 18 clubs (reports differ), each playing about 34 league games from March to October, plus the U.S. Open Cup and the USL's own cup.
- **Crowds.** The 2026 league average was reported at about 2,800 a game. The best-supported club drew about 7,200 and the lowest about 1,000.
- **Growing.** Five new clubs joined in 2026, and four more were put forward for 2027.
- **Promotion and relegation.** USL owners voted in March 2025 to bring it in. A new first division, USL Premier, is planned for 2028, with the Championship and League One below it. The rules for going up and down are not published yet.$b$),

    (3, 'What U.S. Soccer requires', $b$From the U.S. Soccer Professional League Standards dated March 26, 2026. USL League One must hold every club to these.
|Requirement|The standard
|Principal owner|One owner with a controlling interest who owns at least 15% of the team and has a net worth of at least **$10,000,000**, not counting the team or a primary home
|Money to operate|The ownership group must show it can run the team for **three years**, with a detailed budget
|Performance bond|**$250,000** for each team, to cover salaries, the stadium lease and vendors if the team cannot pay
|Stadium|At least **1,000 seats**, with controlled entry and exit
|Pitch|At least **70 × 110 yards**, on a FIFA-approved surface
|Head coach|USSF A licence within two years of being appointed
|Assistant coaches|USSF B licence within two years. Every coach holds at least a C licence
|Staff|Someone handling each of: general manager, marketing and sales, communications, community relations, game operations, head coach, assistant coach, trainer, ticketing, finance, human resources, player safety officer, clerical
|Player safety|A player safety officer who does not report to the coaches, yearly training, and an anti-harassment policy
|Cup|Play in the U.S. Open Cup
|Home market|Show an ongoing commitment to promoting soccer at all levels in the home market
|Game day and media|A yearly media guide and a line-up card for every game
Division III does not require the staff to be full-time, and it sets no minimum size for the home city. Divisions I and II require both.$b$),

    (4, 'Where Lighthouse stands', $b$|Requirement|Lighthouse today|Gap
|Pitch 70 × 110 yards|Lighthouse Field is 74 × 110 yards, on grass|The size is met. The surface needs FIFA approval
|1,000 seats|Seating not counted yet|Seats to be counted, added or rented
|Controlled entry and exit|To be checked|A fenced ground with gates
|Owner worth $10 million|None named|**The main gap**
|Three years of operating money|Club budget covers amateur teams only|An ownership group and a professional budget
|$250,000 bond|None|Posted by the owner
|Head coach with an A licence|To be confirmed|Licence or a waiver showing yearly progress
|Staff roles|Volunteers and part-time coaches|Each role named. They do not have to be full-time
|Soccer at all levels in the home market|Men's, women's and youth teams. Soccer at Lighthouse since 1893|Met
|Player safety officer and policies|To be confirmed|Named officer, written policies, yearly training
|Paid players|Amateur|A professional squad$b$),

    (5, 'What it costs', $b$The bond is from the U.S. Soccer standards. The other figures are press reports, not quotes from the USL, and the running-cost range is from about 2019. The USL sets the real numbers.
|Item|Figure|Source
|Entry fee to the league|$5,000,000|Front Office Sports report
|Performance bond|$250,000|U.S. Soccer standards
|Running the team for a year|$1,300,000–$1,900,000|Beautiful Game Network, about 2019
|**Year one**|**$6,550,000–$7,150,000**|
|Three years of running costs, which the owner must show|$3,900,000–$5,700,000|
- The bond is security. It is not spent unless the team fails to pay its bills.
- A League One coach has put the cost of starting a club at about $5 million, counting the fee and running costs.
- Stadium work is not in these figures.
- Today's running costs are likely higher than the 2019 range.$b$),

    (6, 'The stadium', $b$Lighthouse Field already has a pitch of the right size. Two things are missing: 1,000 seats and FIFA approval of the surface.
|Option|What it means
|A Lighthouse Field|Add seating for 1,000 and controlled gates at 101 East Erie Avenue. The team plays at home in the neighbourhood
|B Rent a stadium|Play home games at a Philadelphia stadium that already has 1,000 seats. Faster, and no building
League One grounds are usually bigger than the minimum. The average capacity was reported at about 5,500 in 2024.$b$),

    (7, 'Steps', $b$- **1 Owner.** Find a principal owner who meets the $10 million standard and will own at least 15%.
- **2 USL.** Meet the USL expansion staff. Get the real entry fee, the yearly league fees and the league's own stadium rules.
- **3 Stadium.** Choose Lighthouse Field or a rented stadium. Sign a lease or a building plan.
- **4 Budget.** Write the three-year budget U.S. Soccer asks for.
- **5 Apply.** The USL puts new clubs forward to U.S. Soccer for sanctioning. The new principal owner meets U.S. Soccer staff before the team plays.
- **6 Build the club.** Name the staff, hire a head coach on the A licence path, sign players, post the bond.
The APSL men's team, the reserves, the women and the youth teams carry on as they are. They become the club's amateur and youth base under the professional team.$b$),

    (8, 'Decisions', $b$- **Go or no go:** is this worth a first meeting with the USL?
- **Owner:** who do we approach?
- **Stadium:** Lighthouse Field or a rented stadium?
- **Year:** which season do we aim for? The USL put its 2027 clubs forward in 2026, so 2028 is the earliest realistic start.$b$),

    (9, 'Sources', $b$- [U.S. Soccer Professional League Standards, March 26, 2026](https://cdn.sanity.io/files/oyf3dba6/production/c3f3ba1dd726d87f1079c91c12827958ad2aadda.pdf): every requirement, and the bond
- [Front Office Sports](https://frontofficesports.com/brooklyn-expansion-franchise-extends-usls-rise/): League One entry fee of $5 million
- [Beautiful Game Network](https://www.bgn.fm/forcing-the-us-soccer-pyramid-league-and-team-rules/): running costs of $1.3–$1.9 million a year
- [Y'all Street](https://www.yallstreet.com/discover/start-a-usl-team-leigh-veidman-says-it-costs-5-million/): about $5 million to start a club
- [USL League One](https://www.uslleagueone.com/news_article/show/1351434): the 2026 season format
- [U.S. Soccer](https://ussoccer.com/stories/2026/10/federation/everything-you-need-to-know-about-the-2026-usl-league-one-playoffs): the 2026 season and playoffs
- [FootyStats](https://footystats.org/usa/usl-league-one/attendance): 2026 attendance
- [League One Updater](https://leagueoneupdater.com/usl-league-one-expansion-report-four-clubs-submitted-for-2027/): clubs put forward for 2027
- [CBS Sports](https://www.cbssports.com/soccer/news/united-soccer-league-to-bring-promotion-and-relegation-to-american-soccer-for-first-time-starting-in-2028): promotion and relegation from 2028$b$)
  ) AS v(o, h, b) ON true
 WHERE p.code = 'usl-league-one'
ON CONFLICT (proposal_id, sort_order) DO NOTHING;

COMMIT;
