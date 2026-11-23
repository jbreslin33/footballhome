-- 🏆 USL League One proposal: who the principal owner can be (James 11/23 "can
-- we jack up the net worth of a board member legally" + "or can it be a
-- silent partner but have net worth?" + "explore both" + "yes add it to the
-- proposal"). New section 5 after The owner rule (old 5–16 move to 6–17):
-- the net worth must really be his; a quiet owner works, a hidden or
-- pretend one does not; how other leagues handle it. Step 3 and Sources follow.

BEGIN;

UPDATE proposal_sections s SET sort_order = s.sort_order + 100
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.sort_order >= 5;
UPDATE proposal_sections s SET sort_order = s.sort_order - 99
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.sort_order >= 105;

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, 5, 'Who the principal owner can be', $b$The owner rule cannot be met on paper only. Two things are true of every way of meeting it: the $10 million must really be his, and his authority must be real. U.S. Soccer can audit the first and reads the company's documents for the second.
**Can we raise a board member's net worth to meet the rule?**
|Way|Works?|Why
|Lighthouse transfers assets to him|No|A nonprofit cannot enrich its own board member. It brings penalty taxes on him and on those who approved it, and puts Lighthouse's tax exemption at risk
|A donor gives him $10 million outright|Legal, but no use|It is then his money. He owes Lighthouse nothing and can leave with it
|A donor gives it with strings: hold it for Lighthouse, or give it back later|No|Money he must give back is not his net worth. Stating it to U.S. Soccer as his would be false
|A loan to him|No|The debt cancels the asset
|Giving him the 15% share|No|The rule does not count the value of the team share, or his primary home
|**A proper valuation of what he already owns**|**Yes**|A business, investment property and investments all count. Someone may be nearer $10 million than anyone assumes
So the first step is to ask. Does a current board member, or a friend of Lighthouse, already meet the rule or come close?
**Can the owner be a silent partner?**
Not silent. Quiet.
- **What the rule requires of him.** He is named in the company's legal documents. He holds at least 15%. He has authority to sign for the team. He meets U.S. Soccer staff before the team plays, and he can be audited. He cannot be hidden from U.S. Soccer or the league.
- **What the rule does not require.** That he runs anything, or that the public knows his name. He can hold the authority and leave the running of the team to the board.
- **Detroit City FC did this.** In 2020 its principal holder was a company owned by one board member, at exactly the 35% then required, while the founders ran the club. Today the principal holder is a company, H Block, LLC, and the filing does not say who is behind it.
- **Where it breaks.** If a side agreement says his authority is not real and he is only a name, that is a false statement to U.S. Soccer. Leaving the work to the board is fine. Pretending is not.
**What we ask of him**
- Buy 15% of the team company. He can hold it through a company he owns.
- Give a set commitment: an amount each year for three years, and the bond.
- Sign the league documents and meet U.S. Soccer once.
- Accept an audit of his net worth.
As a shareholder he is not personally liable for the company's debts beyond what he commits.
**One thing to check.** The yearly benefit report names everyone who holds 5% or more. If he holds through his own company, the report may show the company's name. The lawyer must confirm this.
**How other sports handle it**
|League|Rule
|NFL|The controlling owner must hold 30%. Nonprofit ownership has been banned since 1960. The Green Bay Packers were owned by their community before the rule and were allowed to stay
|Major League Baseball|The controlling owner must hold at least 15% and have primary operational control
|Canadian Football League|Saskatchewan, Winnipeg and Edmonton are community-owned. The league allows it
No league is got around by raising someone's net worth. A league either allows community ownership, or it requires a real lead person holding a small share. U.S. Soccer's 15% is the second kind.
**Best fit for Lighthouse.** A board member or friend of Lighthouse who already has the net worth, as a quiet principal owner through his own company, with Lighthouse holding the board.
The points on nonprofit law and on false statements are ours. The lawyer must confirm them before anyone is approached.$b$
  FROM proposals p WHERE p.code = 'usl-league-one';

UPDATE proposal_sections s SET body = replace(s.body,
  '- **3 Benefactor.** Find the principal owner:',
  '- **3 Benefactor.** Start with the Lighthouse board and its friends: does anyone already meet the rule or come close? Find the principal owner:')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Steps';

UPDATE proposal_sections s SET body = s.body || $b$
- [Clifford Chance, September 2026](https://www.cliffordchance.com/content/dam/cliffordchance/briefings/2026/09/From%20Fifteen%20Percent%20to%20Twenty%20Percent%20-%20MLB%20Expands%20Private%20Equity%20Ownership%20of%20Franchises.pdf): Major League Baseball's controlling owner rule
- [Front Office Sports](https://frontofficesports.com/article/nfl-private-equity-mlb-nba/): NFL controlling owner at 30%
- [The American Prospect](https://prospect.org/2026/02/12/feb-2026-magazine-sports-green-bay-packers-nonprofit-community-owned/): the Green Bay Packers and the NFL's 1960 rule
- [Canadian Football League](https://www.cfl.ca/2007/09/01/community_ownership_a_port_in_cfl_s_storms/): community-owned teams$b$
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Sources';

COMMIT;
