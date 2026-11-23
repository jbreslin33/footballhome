-- 🏆 USL League One proposal rewritten around the benefit corporation (James
-- 11/23 "so write proposal with all this in mind and how this benefit
-- corpoaration would be used to help lh and thus the communty at larg").
--
-- One plan, in order: the structure (a Pennsylvania benefit corporation with a
-- principal owner at 15%, Lighthouse holding most of the rest, an optional
-- supporters' class), how it helps Lighthouse and the neighbourhood, the owner
-- rule and who controls what, how Detroit and Chattanooga did it, what to do
-- if no owner is found (waiver, rule change, League Two), then the league,
-- the requirements, the gaps, the costs, the stadium, steps, questions,
-- decisions, sources. Facts are the ones already sourced in migs 1684–1706.
-- The benefit terms (licence fee, rent, charter commitments, protected
-- matters, supporters' class) are proposed terms; the page says so.

BEGIN;

UPDATE proposals SET
  summary = 'From James Breslin: a professional Lighthouse team in USL League One, owned through a benefit corporation. A principal owner holds 15% and meets the U.S. Soccer owner rule. Lighthouse holds most of the rest, owns the name, and is paid before any profit.'
WHERE code = 'usl-league-one';

-- Kept sections move to their new places; the rest are rewritten below.
UPDATE proposal_sections s SET sort_order = s.sort_order + 100
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one';
DELETE FROM proposal_sections s USING proposals p
 WHERE p.id = s.proposal_id AND p.code = 'usl-league-one'
   AND s.heading IN ('Summary', 'Ownership', 'Steps', 'Decisions');
UPDATE proposal_sections s SET sort_order = v.o
  FROM proposals p, (VALUES
    ('What USL League One is', 7), ('What U.S. Soccer requires', 8), ('Where Lighthouse stands', 9),
    ('What it costs', 10), ('The stadium', 11), ('Sources', 15)) AS v(h, o)
 WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = v.h;

UPDATE proposal_sections s SET body = replace(s.body, '**The main gap.** See Ownership', '**The main gap.** See The owner rule')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Where Lighthouse stands';
UPDATE proposal_sections s SET body = s.body || $b$
- **Who pays.** The team company and its principal owner. Lighthouse the nonprofit does not pay these costs and does not guarantee them.$b$
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'What it costs';
UPDATE proposal_sections s SET body = s.body || $b$
Under option A the team company pays for the seats, gates and field work, and they stay at Lighthouse.$b$
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'The stadium';

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, v.o, v.h, v.b
  FROM proposals p
  JOIN (VALUES
    (1, 'Summary', $b$From James Breslin.
Put a professional Lighthouse men's team in **USL League One**, the third division of U.S. professional soccer, and build it so that it works for Lighthouse and the neighbourhood.
**The problem.** U.S. Soccer requires every professional team to have one owner worth at least $10 million who holds at least 15% of the team and controls it. Lighthouse is a nonprofit with a board and no owner.
**The answer.** A new company owns and runs the professional team: a Pennsylvania **benefit corporation**, a company with shareholders that is bound by its charter to a public purpose. A benefactor holds 15% and is the principal owner. Lighthouse holds most of the rest, owns the name and the crest, and sits on the board.
**What Lighthouse gets.** A licence fee and rent every year, a ground with seats and lights that stays at Lighthouse, youth soccer paid for by the team, jobs and tickets for the neighbourhood, and most of the value of the club. None of it depends on the team making a profit.
**What it takes.** The benefactor, a stadium with seats, and about $6.5–$7 million in year one, paid by the team company and not by Lighthouse.
Chattanooga FC is already a benefit corporation playing in Division III. Detroit City FC is built the same way with two classes of owners. Both are set out below.$b$),

    (2, 'The structure', $b$Lighthouse the nonprofit does not change. Its board, its youth teams and its amateur teams carry on as they are. A new company is formed beside it for the professional team.
|Who|What they hold|What it means
|**Principal owner**, a benefactor worth $10 million|Class A: 15% of the company, and the vote|Runs the team, signs for it, votes in the league, and backs its losses. Meets the U.S. Soccer owner rule
|**Lighthouse**|Class L: the rest, 75% to 85%|Most of the value of the club, seats on the board, and a veto on the protected matters
|**Supporters**, optional and later|Class S: up to 10%, sold to neighbours and fans at about $125 a share|A piece of their club, one seat on the board, and a say on the name and crest
**Why a benefit corporation**
- **Purpose in the charter.** The company must pursue a public benefit and can name its own. Ours: soccer for the young people and families of the neighbourhood, and support for Lighthouse.
- **Directors must weigh the community.** They answer for the effect of their decisions on the neighbourhood and the staff, not only for profit.
- **A public report every year.** It says what the company did for its purpose, is measured against an outside standard, is filed with the state and is posted on the website.
- **Owners are named.** The report lists everyone who holds 5% or more.
- **It has shares.** That is what lets one person own 15% and satisfy U.S. Soccer. A nonprofit has no shares to give.
- **It pays tax.** Gifts to the team company are not tax-deductible. Gifts to Lighthouse still are.
**Protected matters.** The company cannot do these without Lighthouse's consent:
- Change the team's name, crest or colors.
- Move the team out of the neighbourhood.
- Sell the company, or pass the principal owner's share to someone new.
- Change the purpose in the charter.
- Borrow against Lighthouse property.
**What protects Lighthouse**
- Lighthouse owns the name and the crest and licenses them to the company.
- Lighthouse does not guarantee the company's debts. The most it can lose is the value of its shares.
- If the company fails, the name and the crest come back to Lighthouse, and the seats, gates and field work stay at Lighthouse.
- If the principal owner leaves, Lighthouse has the first right to choose who follows.
These are proposed terms. A lawyer who knows nonprofits and Pennsylvania benefit corporations must draw them up, and the U.S. Soccer owner rule limits how far the vetoes can go. See The owner rule.$b$),

    (3, 'How it helps Lighthouse and the community', $b$Detroit City FC lost $5.3 million in 2025 and Chattanooga FC lost $1.4 million in 2022. A professional club at this level does not pay its owners a profit. So Lighthouse's benefit is not built on profit. It is built on payments and commitments the company owes first, every year, whether it wins or loses.
**To Lighthouse**
|Benefit|How it works
|Licence fee|The company pays Lighthouse every year to use the name and the crest
|Rent|The company pays Lighthouse for the field and the buildings it uses
|The ground|Seats, gates, lights and field work paid for by the company stay at Lighthouse. The youth and amateur teams use them every other day of the week
|Youth soccer|Written into the charter: the company pays toward Lighthouse youth soccer each year, and its players and coaches work with the youth teams
|Standing|A professional team in Lighthouse colors makes Lighthouse easier to fund: grants, sponsors and donors
|Value|If the company is ever sold, or pays a distribution, Lighthouse's share goes to the nonprofit
**To the neighbourhood**
|Benefit|How it works
|A path|A child can go from the under-8s to a professional first team without leaving the club
|Jobs|Game-day work and the staff roles U.S. Soccer requires, offered to the neighbourhood first
|Tickets|Free and low-price tickets for Lighthouse families and the neighbourhood's schools
|Game days|About 17 home league games a year bring crowds to the businesses around Erie Avenue
|A team of its own|A professional club that belongs to the neighbourhood and cannot be moved or renamed without Lighthouse
|Ownership|With a supporters' class, neighbours can own a share for about $125 and elect a director
**Held to it.** Each year the benefit report states what the company paid Lighthouse, what it spent on youth soccer, how many neighbourhood jobs and tickets it gave, and how that compares with the year before. Lighthouse's directors on the company board see it first.
The amounts are to be set with the principal owner and the lawyer. The order is the point: Lighthouse and the neighbourhood are paid as costs of running the team, before any profit.$b$),

    (4, 'The owner rule', $b$**The rule.** Each team "must designate one principal owner with a controlling interest who owns at least 15% of the team and has authority to bind the team." That owner "must have an individual net worth of at least ten million US dollars," not counting the team or a primary home. U.S. Soccer can order an audit to prove it.
**What changed in March 2026.** The share the principal owner must hold fell from 35% to 15%. The $10 million did not change. That is what makes this structure possible: one person holds 15%, and Lighthouse holds most of the rest.
**How 15% controls.** Owning and voting are separate. Class A carries the vote. Class L carries most of the value. Detroit City FC and Chattanooga FC are both built on two classes like this.
**Who decides what**
|The principal owner|Lighthouse
|Runs the team day to day|Holds seats on the board
|Signs the lease, the contracts and the league agreement|Must consent to the protected matters
|Casts the team's vote in the league|Owns and licenses the name and the crest
|Backs the team's losses|Receives the licence fee and the rent
**The limit.** The rule says "controlling interest." The more Lighthouse can veto, the less the owner's interest looks controlling. How long the list of protected matters can be is a question for the USL.
**The rule is about his money.** A federal court recorded its purpose: it stops an owner underfunding a team. U.S. Soccer will want the $10 million person to be the one who pays when the team loses money. The benefactor must accept the audit, sign for the team and back its losses, while Lighthouse holds most of the value.
**Who would do that.** Someone who wants a professional team for the neighbourhood more than a return. The owner can hold the share through a company he owns, as Detroit's principal owner did.$b$),

    (5, 'How Detroit and Chattanooga did it', $b$Both clubs sold shares to supporters, so their structures are on file with the Securities and Exchange Commission.
|Club|Company|Voting class|Supporters|Principal owner
|Detroit City FC|DCFC Holdings, LLC, Michigan|Class A units elect the board and approve every major decision|Class B units at $125, no vote, held by a custodian|2020: one holder with exactly 35.0% of the vote, through a company owned by one man. Today: H Block, LLC with 34.59%
|Chattanooga FC|Beautiful Game, Inc., a Tennessee **benefit corporation**|Class A common stock|Class S stock at $125. About 12% of the shares|Report for 2022: "no one has over 20% voting power." Names a primary owner today
**Detroit City FC**
- Seven managers on the board. The four founders are the majority.
- The trademarks sit in a separate company owned by the same group and are licensed to the club.
- Supporters are asked about things like team colors and the hall of fame.
- In 2025 it took in $5,737,025 and lost $5,320,159. It plays in the USL Championship, Division II.
**Chattanooga FC**
- Supporters elect one director, and the board must agree to seat that director.
- The club cannot change its name, logo or crest, or add to its hall of fame, without a majority vote of the supporters.
- The company can buy a share back before it is sold on. A share cannot go to a rival club. Supporters must vote with the board if the club is sold.
- In 2022 it took in $1,105,907 and lost $1,412,242. It plays in MLS Next Pro, Division III.
**What Lighthouse takes from them**
- A benefit corporation can be a professional club. Chattanooga is one.
- Two classes settle who controls and who holds the value.
- The principal owner can hold through a company he owns.
- The class without control can still hold a board seat and a veto on the name and crest.
- The name can sit outside the team company and be licensed to it.
- Both clubs lose money. The principal owner and the budget must be ready for that.
**An open question.** Chattanooga reported no owner above 20% of the vote while it played in a Division III league under a 35% rule. Either a waiver was granted or the rule was not applied. This is our reading of the filing, and it is a question for the USL.$b$),

    (6, 'If no owner is found', $b$The benefit corporation with a principal owner is the plan. If no benefactor comes forward, there are three other routes.
|Route|How it works|Risk
|A waiver|The USL asks U.S. Soccer to accept Lighthouse without a principal owner, with real security in its place|One year at a time. No case found of this rule being waived
|Change the rule|Ask U.S. Soccer to add a way for a nonprofit or community-owned club to meet the standard|Slow. The Board decides, and it last revised the standards in March 2026
|USL League Two first|Play in the amateur league below, which has no owner rule, while the owner is found|It is not professional soccer
**The case for a waiver**
- **What the rule tests.** It tests what an owner could pay, not what he will pay. A rich owner can stop paying, and professional clubs have folded with a qualifying owner in place.
- **What actually protects the league.** The bond. It is real money, posted before the season.
- **What Lighthouse offers in place of an owner.** A bond above the $250,000 minimum. A full season of costs held in escrow before the first game. Audited accounts every year. A benefit corporation that reports to the public.
- **Why Lighthouse is the safer bet.** It has run soccer since 1893. A nonprofit cannot be sold, and it will not move the team.
- **The limits.** The USL has to make the request, and a waiver lasts one year. U.S. Soccer has granted waivers to every league, but the ones on record are for team numbers, time zones, seats, field size and coaching licences. U.S. Soccer treats the owner rule as a core rule.
**Changing the rule**
- **Who decides.** The U.S. Soccer Board of Directors adopts the standards.
- **How a change is made.** In the court record, a Standards Task Force proposes amendments, the professional leagues comment, and the Board votes. That describes 2017. U.S. Soccer may run it differently now.
- **Lighthouse cannot file it alone.** We are not a direct member. The ways in are the USL, which sits on the Professional Council; the Adult Council, through our adult associations; and a letter to the Board and chief executive.
- **What we ask for.** One sentence added to Division III: a nonprofit or community-owned club may meet the financial standard without a principal owner by posting a larger bond and holding one season of costs in escrow.
- **Timing.** Expect years. Run it beside the plan, not in place of it.$b$),

    (12, 'Steps', $b$- **1 Lighthouse board.** Agree to explore a professional team held through a benefit corporation, with Lighthouse owning the name.
- **2 Lawyer.** Draft the benefit corporation: the charter purpose, the share classes, the protected matters, the licence for the name and crest, and the lease.
- **3 Benefactor.** Find the principal owner: worth $10 million, willing to hold 15%, be audited, and back the team.
- **4 USL.** Meet the USL expansion staff. Ask the ownership questions first. Get the real entry fee, the yearly league fees and the league's own stadium rules.
- **5 Stadium.** Choose Lighthouse Field or a rented stadium. Sign a lease or a building plan.
- **6 Budget.** Write the three-year budget U.S. Soccer asks for, with the licence fee, the rent and the youth soccer payment in it as costs.
- **7 Apply.** The USL puts new clubs forward to U.S. Soccer for sanctioning. The principal owner meets U.S. Soccer staff before the team plays.
- **8 Build the club.** Name the staff, hire a head coach on the A licence path, sign players, post the bond.
- **Alongside: the rule.** Write to the U.S. Soccer Board, and ask the USL and our adult association to carry the proposal to change the Division III owner rule.
The APSL men's team, the reserves, the women and the youth teams carry on as they are. They become the club's amateur and youth base under the professional team.$b$),

    (13, 'Questions for the USL', $b$- Is a benefit corporation acceptable as the team company?
- Can a nonprofit hold 75% to 85% of the team company?
- What must "controlling interest" look like when the owner holds 15%? Which matters can Lighthouse keep a veto on?
- Chattanooga FC reported no owner above 20% of the vote in 2022 while it played in Division III. How was the owner rule met?
- Has U.S. Soccer ever waived the owner rule for a League One club?
- Would the USL ask for a waiver for Lighthouse, with a larger bond and a season of costs in escrow?
- Would the USL back a change to the Division III owner rule for nonprofit and community-owned clubs?
- What are today's entry fee, yearly league fees, and seat and market minimums?$b$),

    (14, 'Decisions', $b$- **Go or no go:** is this worth a first meeting with the USL?
- **Structure:** a benefit corporation with a principal owner at 15% and Lighthouse holding most of the rest?
- **Supporters:** do we add a supporters' class for neighbours and fans?
- **Owner:** who do we approach?
- **If no owner:** a waiver, the rule change, or USL League Two first?
- **Stadium:** Lighthouse Field or a rented stadium?
- **Year:** which season do we aim for? The USL put its 2027 clubs forward in 2026, so 2028 is the earliest realistic start.$b$)
  ) AS v(o, h, b) ON true
 WHERE p.code = 'usl-league-one';

COMMIT;
