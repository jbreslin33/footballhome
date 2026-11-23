-- 🏆 USL League One proposal: the case for the waiver, and asking U.S. Soccer
-- to change the rule (James 11/23 "yes add it as the case for the waiver. but
-- also we should ask for pls change right? how we would do that? its a
-- commitee right in us socer?"). Ownership section gains two blocks and a
-- Route D; Steps, Decisions and Sources follow.
--
-- How the standards are amended is from the E.D.N.Y. 11/4/2017 ruling in
-- NASL v. USSF (a Standards Task Force proposes, the professional leagues
-- comment, the Board votes) and U.S. Soccer's policy manual (the Board adopts
-- the standards). That is the process as of 2017; the page says so.

BEGIN;

UPDATE proposal_sections s SET body = replace(replace(replace(s.body,
  '|C USL League Two first|Play in the amateur league below, which has no owner rule, while the owner is found|It is not professional soccer',
  '|C USL League Two first|Play in the amateur league below, which has no owner rule, while the owner is found|It is not professional soccer
|D Change the rule|Ask U.S. Soccer to add a way for a nonprofit or community-owned club to meet the standard without a principal owner|Slow. The Board decides, and it last revised the standards in March 2026'),
  '**Questions for the USL at the first meeting**',
  '**The case for a waiver (Route B)**
- **What the rule is for.** U.S. Soccer told a federal court the net worth rule stops an owner underfunding a team.
- **What it tests.** It tests what an owner could pay, not what he will pay. A rich owner can stop paying, and professional clubs have folded with a qualifying owner in place.
- **What actually protects the league.** The bond. It is real money, posted before the season, and spent on salaries and the lease if the team fails.
- **What Lighthouse offers in place of an owner.** A bond above the $250,000 minimum. A full season of costs held in escrow before the first game. Audited accounts every year. A benefit corporation that reports to the public.
- **Why Lighthouse is the safer bet.** It has run soccer since 1893. A nonprofit cannot be sold, and it will not move the team.
- **The limits.** The USL has to make the request. A waiver lasts one year. We found no case of this rule being waived.
**Changing the rule (Route D)**
- **Who decides.** The U.S. Soccer Board of Directors adopts the standards.
- **How a change is made.** In the court record, a Standards Task Force reviews the standards and proposes amendments, the professional leagues comment, and then the Board votes. That describes the process in 2017. U.S. Soccer may run it differently now.
- **Lighthouse cannot file it alone.** We are not a direct member of U.S. Soccer. There are three ways in:
- 1 **The USL.** It sits on the Professional Council, which holds seats on the Board, and the professional leagues are asked to comment on every change.
- 2 **The Adult Council.** Our amateur leagues belong to U.S. Soccer through the adult associations, and the Adult Council elects its own Board members.
- 3 **A letter to the Board.** Sent to the U.S. Soccer Board and chief executive, asking that the Standards Task Force take it up.
- **What we ask for.** One sentence added to Division III: a nonprofit or community-owned club may meet the financial standard without a principal owner by posting a larger bond and holding one season of costs in escrow.
- **Timing.** The Board meets four times a year and the annual general meeting is in the winter. Expect this to take years. Run it beside Route A, not in place of it.
**Questions for the USL at the first meeting**'),
  '- Would a guarantor or a larger bond be accepted in place of a principal owner?',
  '- Would a guarantor or a larger bond be accepted in place of a principal owner?
- Would the USL ask for a waiver for Lighthouse on the case above?
- Would the USL back a change to the Division III owner rule for nonprofit and community-owned clubs?')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Ownership';

UPDATE proposal_sections s SET body = replace(s.body,
  '- **3 Stadium.**',
  '- **Alongside: the rule.** Write to the U.S. Soccer Board, and ask the USL and our adult association to carry the proposal to change the Division III owner rule.
- **3 Stadium.**')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Steps';

UPDATE proposal_sections s SET body = replace(replace(s.body,
  '- **Ownership route:** A a principal owner at 15%, B a waiver, or C USL League Two first?',
  '- **Ownership route:** A a benefit corporation with a principal owner at 15%, B a waiver, or C USL League Two first?'),
  '- **Owner:** who do we approach?',
  '- **Rule change:** do we also ask U.S. Soccer to change the owner rule (Route D)?
- **Owner:** who do we approach?')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Decisions';

UPDATE proposal_sections s SET body = s.body || $b$
- [U.S. Soccer Policy Manual](https://www.fysa.com/wp-content/uploads/sites/224/2025/04/US-Soccer-Policies.pdf): the Board adopts the standards
- [U.S. Soccer Board of Directors](https://www.ussoccer.com/governance/board-of-directors): who sits on the Board, and its meetings
- [U.S. Soccer Adult Council](https://www.ussoccer.com/governance/adult-council): the adult associations' seats$b$
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Sources';

COMMIT;
