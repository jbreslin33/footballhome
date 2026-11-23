-- 🏆 USL League One proposal: Lighthouse holds the board (James 11/23 "this is
-- bad for lh", on the list of what the principal owner would decide). The
-- owner-controls-everything reading was the strictest one. The filings show
-- less: Detroit City FC's principal owner holds 34.59% of the vote and the
-- four founders are the board's majority; Chattanooga FC reported no holder
-- above 20%. Opening position now: Lighthouse elects the majority of the
-- board; the principal owner is named in the charter, signs for the team,
-- votes in the league and backs it with a set commitment. The strict reading
-- stays on the page as the fallback, with what we would give up and in what
-- order. Our reading of the filings; flagged as a question for the USL.

BEGIN;

UPDATE proposals SET
  summary = 'From James Breslin: a professional Lighthouse team in USL League One, owned through a benefit corporation. A principal owner holds 15% and meets the U.S. Soccer owner rule. Lighthouse holds most of the rest and the majority of the board, owns the name, and is paid before any profit.'
WHERE code = 'usl-league-one';

UPDATE proposal_sections s SET body = replace(s.body,
  'Lighthouse does not run the team: the owner picks the coach, the players and the budget.',
  'Lighthouse elects the majority of the board. The principal owner signs for the team, votes in the league and backs it with a set commitment.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Summary';

UPDATE proposal_sections s SET body = replace(replace(replace(s.body,
  '|**Principal owner**, a benefactor worth $10 million|Class A: 15% of the company, and the vote|Runs the team, signs for it, votes in the league, and backs its losses. Meets the U.S. Soccer owner rule',
  '|**Principal owner**, a benefactor worth $10 million|Class A: 15% of the company and of the vote|Named in the charter as principal owner. Signs for the team, votes in the league, sits on the board, and backs the team with a set commitment. Meets the U.S. Soccer owner rule'),
  '|**Lighthouse**|Class L: the rest, 75% to 85%|Most of the value of the club, seats on the board, and a veto on the protected matters',
  '|**Lighthouse**|Class L: the rest, 75% to 85%|Most of the value and most of the vote. Elects the majority of the board. A veto on the protected matters'),
  '**What protects Lighthouse**',
  '**What protects the principal owner.** The company cannot do these without his consent:
- Spend beyond the budget he has agreed to back.
- Borrow, or issue new shares that would cut his holding.
- Sell the company.
**What protects Lighthouse**')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'The structure';

UPDATE proposal_sections s SET body = $b$**The rule.** Each team "must designate one principal owner with a controlling interest who owns at least 15% of the team and has authority to bind the team." That owner "must have an individual net worth of at least ten million US dollars," not counting the team or a primary home. U.S. Soccer can order an audit to prove it.
**What changed in March 2026.** The share the principal owner must hold fell from 35% to 15%. The $10 million did not change.
**What "controlling interest" has meant in practice**
- Under the old rule the share was 35%. That was never a majority.
- **Detroit City FC.** The principal owner holds 34.59% of the vote. The four founders are the majority of the board, not the principal owner.
- **Chattanooga FC.** Its report for 2022 says no one held over 20% of the vote.
- So in practice the principal owner is the named person who can sign for the team and whose wealth stands behind it. He is not a person who outvotes everyone else.
This is our reading of the two clubs' filings. U.S. Soccer has not said it, and it is the first question for the USL.
**Our position: Lighthouse holds the board.** Lighthouse elects the majority of the directors. The principal owner is named in the charter, sits on the board, signs for the team and casts its vote in the league.
**In Lighthouse's control, through the board**
- **People.** Who is general manager and head coach.
- **The budget.** How much the team spends each season, within the money it has.
- **Prices and sponsors.** Ticket prices, and which sponsors the team takes.
- **Major contracts.** The board approves them before the principal owner signs.
**In Lighthouse's control, by right**
- **The name, the crest and the colors.** Lighthouse owns them and licenses them with conditions.
- **Where the team is based.** It cannot move without Lighthouse's consent.
- **Who owns it next.** The principal owner cannot sell or pass on his share without Lighthouse's consent, and Lighthouse has the first right to choose who follows.
- **The purpose.** The charter cannot be changed without Lighthouse's consent.
- **Its own ground.** The lease sets when the team uses the field. The youth and amateur teams come first on the days Lighthouse names.
- **What it is owed.** The licence fee, the rent and the youth soccer payment are contracts the company must pay.
- **Everything Lighthouse already runs.** The nonprofit, its board, the youth teams and the amateur teams are untouched.
**Still outside Lighthouse's control**
- **The league's own rules.** The USL sets the schedule, the fees, the standards and the discipline.
- **The principal owner's consent.** The company cannot spend beyond the budget he backs, borrow, cut his holding or be sold without him.
- **Whether he renews.** His commitment runs for a set term. He decides whether to give another.
- **Signing day to day.** He has authority to bind the team. The board sets what he may sign, but U.S. Soccer and the league deal with him.
- **What U.S. Soccer accepts.** It may require him to hold more control than this.
**Control follows money.** If Lighthouse holds the board, the principal owner will not back open-ended losses. He gives a set commitment: an amount each year for three years, and the bond. Beyond that the company lives on what it brings in: tickets, sponsors, supporters' shares and fundraising. The board must budget to the money it has. Lighthouse the nonprofit still does not guarantee the company's debts.
**If U.S. Soccer or the owner needs more.** We give ground in this order, and stop as early as we can:
- 1 Major contracts: he signs without board approval.
- 2 The budget: he sets it, and backs the losses in full.
- 3 People: he names the general manager and head coach.
- 4 The board: he elects the majority.
**Never given up.** The name, the crest and the colors. Where the team is based. Who owns it next. The purpose. What the company owes Lighthouse.
**If it goes wrong.** The team company fails, not Lighthouse. The name and the crest come back, the seats and field work stay, and Lighthouse's teams play on.$b$
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'The owner rule';

UPDATE proposal_sections s SET body = replace(replace(s.body,
  '- Two classes settle who controls and who holds the value.',
  '- A principal owner does not need the board. In Detroit the founders are the board''s majority and the principal owner holds about a third of the vote.'),
  '- The principal owner can hold through a company he owns.',
  '- The principal owner can hold through a company he owns.
- Two classes let supporters hold a share without a general vote.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'How Detroit and Chattanooga did it';

UPDATE proposal_sections s SET body = replace(s.body,
  '- **The protected matters.**',
  '- **Who holds the board.** Lighthouse elects the majority. This rests on our reading of how Detroit and Chattanooga met the rule.
- **The principal owner''s commitment.** A set amount each year for three years, and the bond. No amount is set.
- **The protected matters.**')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Draft terms';

UPDATE proposal_sections s SET body = replace(replace(s.body,
  '- What must "controlling interest" look like when the owner holds 15%? Which matters can Lighthouse keep a veto on?',
  '- Detroit City FC''s principal owner holds 34.59% of the vote and the founders are the majority of its board. Is a principal owner without a majority of the board accepted in League One?
- What is the least a principal owner must control: signing for the team and the league vote, or more?'),
  '- Can a nonprofit hold 75% to 85% of the team company?',
  '- Can a nonprofit hold 75% to 85% of the team company and elect the majority of its board?')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Questions for the USL';

UPDATE proposal_sections s SET body = replace(replace(s.body,
  '- **3 Benefactor.** Find the principal owner: worth $10 million, willing to hold 15%, be audited, and back the team.',
  '- **3 Benefactor.** Find the principal owner: worth $10 million, willing to hold 15%, be audited, sign for the team, and back it with a set commitment.'),
  '- **6 Budget.** Write the three-year budget U.S. Soccer asks for, with the licence fee, the rent and the youth soccer payment in it as costs.',
  '- **6 Budget.** Write the three-year budget U.S. Soccer asks for, within the owner''s commitment and the money the team can bring in, with the licence fee, the rent and the youth soccer payment in it as costs.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Steps';

UPDATE proposal_sections s SET body = replace(s.body,
  '- **Structure:** a benefit corporation with a principal owner at 15% and Lighthouse holding most of the rest?',
  '- **Structure:** a benefit corporation with a principal owner at 15% and Lighthouse holding most of the rest and the majority of the board?
- **How far we bend:** which of the four steps toward the owner would we accept, if any?')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Decisions';

COMMIT;
