-- 🏆 USL League One proposal: how Detroit City FC and Chattanooga FC are built
-- (James 11/23 "how is detroit fc stuctured and chattanooga. do deep dive they
-- sold stock so should be public knowledte"). From their SEC crowdfunding
-- filings: DCFC Holdings, LLC (CIK 1630745: Form C 2020, Form C-AR for 2025)
-- and Beautiful Game, Inc. d/b/a Chattanooga FC (CIK 1754578: Form C 2019,
-- investment agreement, Form C-AR for 2022). Ownership section: the two table
-- rows are corrected to the filings and a block sets out each structure and
-- what Lighthouse takes from it. Chattanooga is a benefit corporation.

BEGIN;

UPDATE proposal_sections s SET body = replace(replace(replace(s.body,
  '|Detroit City FC|Five founders, then shares sold to supporters|To go pro it restructured so one owner held 35% and was worth $10 million',
  '|Detroit City FC|A company with voting units for the owners and non-voting units for supporters|When it went professional one owner held exactly 35% of the vote, through a company he owned'),
  '|Chattanooga FC|More than 3,200 supporter shareholders|Has a primary owner beside them. Plays in MLS Next Pro, also Division III',
  '|Chattanooga FC|A benefit corporation with voting stock for the owners and supporters'' stock for about 3,200 fans|Professional since 2020. Plays in MLS Next Pro, also Division III. Has a primary owner today'),
  'Each club that went professional found a person who met the rule. None went in on a waiver that we can find.',
  'Each club that went professional has a principal owner today. We found no waiver on the record for either.
**How Detroit City FC is built** (from its filings with the Securities and Exchange Commission)
- **The company.** DCFC Holdings, LLC, a Michigan company formed in 2015.
- **Two classes of units.** Class A units vote, elect the board and approve every major decision. Class B units do not vote.
- **The principal owner in 2020.** One holder had 30,240 of the 86,400 Class A units: exactly 35.0% of the vote, the standard at the time. The holder was a company owned by one man, Michael Lasinski.
- **The principal owner today.** H Block, LLC bought $10,000,000 of Class A units in April 2025 and holds 34.59% of the vote. Nobody else holds over 20%.
- **The supporters.** In 2020 fans bought Class B units at $125 each, at a club value of $10,800,000. Their units do not vote. A custodian holds them and votes for them if a vote is ever needed. They are asked about things like team colors and the hall of fame.
- **The board.** Seven managers. The four founders are the majority.
- **The name.** The trademarks sit in a separate company owned by the same group and are licensed to the club.
- **The money.** In 2025 the club took in $5,737,025 and lost $5,320,159. It plays in the USL Championship, Division II.
**How Chattanooga FC is built** (from its filings with the Securities and Exchange Commission)
- **The company.** Beautiful Game, Inc., a Tennessee for-profit **benefit corporation**, formed in 2018. This is the form we propose for Lighthouse.
- **Two classes of stock.** Class A common stock votes. Class S supporters'' stock, sold to fans at $125 a share, does not vote in general.
- **What the supporters do get.** They elect one director to the board, and the board must agree to seat that director. The club cannot change the team''s name, logo or crest, or add to its hall of fame, without a majority vote of the supporters.
- **Limits on the supporters.** The company can buy a share back before it is sold to anyone else. A share cannot go to a rival club. If the board and the voting owners agree to sell the club, the supporters must vote with them.
- **The split.** At the end of 2022 there were 53,350 voting shares and 6,972 supporters'' shares. The supporters held about 12%.
- **The principal owner.** The report for 2022 says "no one has over 20% voting power." The club was then in a Division III league, and the standard was 35%. Either a waiver was granted or the rule was not applied. This is our reading of the filing, and it is a question for the USL. The club names a primary owner today, Davis Grizzard.
- **The money.** In 2022 the club took in $1,105,907 and lost $1,412,242.
**What Lighthouse takes from them**
- **Two classes answer the control question.** The principal owner''s class votes. The other class holds most of the value. Both clubs are built this way.
- **The principal owner can hold through a company he owns.** Detroit did exactly that, to the decimal.
- **A benefit corporation can be a professional club.** Chattanooga is one, in Division III.
- **The class without control can still hold the name and the crest.** Chattanooga''s supporters have that veto and a seat on the board. Lighthouse would hold the same.
- **The name can sit outside the team company.** Detroit keeps its trademarks in a separate company and licenses them. Lighthouse would own the name and crest and license them the same way.
- **Both clubs lose money.** The principal owner and the budget must be ready for that.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Ownership';

UPDATE proposal_sections s SET body = replace(s.body,
  '- Has U.S. Soccer ever waived the owner rule for a League One club?',
  '- Has U.S. Soccer ever waived the owner rule for a League One club?
- Chattanooga FC reported no owner above 20% of the vote in 2022 while it played in Division III. How was the owner rule met?')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Ownership';

UPDATE proposal_sections s SET body = s.body || $b$
- [Detroit City FC annual report for 2025, SEC](https://www.sec.gov/Archives/edgar/data/1630745/000163074526000001/formcardcfc2025.pdf): unit classes, H Block, board, money
- [Detroit City FC offering statement, 2020, SEC](https://www.sec.gov/Archives/edgar/data/1630745/000167025420000980/document_1.pdf): the 35% holder, supporters' units, trademarks
- [Chattanooga FC supporters' stock agreement, 2019, SEC](https://www.sec.gov/Archives/edgar/data/1754578/000167025419000007/document_3.pdf): benefit corporation, supporters' rights
- [Chattanooga FC report for 2022, SEC](https://www.sec.gov/Archives/edgar/data/1754578/000167025423000404/document_2.pdf): share counts, voting power, money$b$
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Sources';

COMMIT;
