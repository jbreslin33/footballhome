-- 🏆 USL League One proposal: the team company is a Pennsylvania benefit
-- corporation (James 11/23 "make it a benefit corporation"). Route A in the
-- Ownership section: the professional team sits in a benefit corporation
-- (15 Pa.C.S. Chapter 33) — a for-profit company with shareholders whose
-- charter binds it to a public benefit. It does not replace the owner rule:
-- the 15% principal owner is still needed. Step 1 and Sources follow.

BEGIN;

UPDATE proposals SET
  summary = 'From James Breslin: what it takes to put Lighthouse in USL League One, the third division of U.S. professional soccer. The owner standard comes first: one person worth $10 million holding at least 15% of a team company set up as a benefit corporation. Then a stadium, and about $6.5–$7 million in year one.'
WHERE code = 'usl-league-one';

UPDATE proposal_sections s SET body = replace(replace(replace(replace(s.body,
  '|**A A principal owner at 15%**|The professional team sits in its own company. One person worth $10 million holds 15% and control. Lighthouse holds up to 85%|That person, not the board, controls the team',
  '|**A A benefit corporation with a principal owner at 15%**|The professional team sits in its own company, a Pennsylvania benefit corporation. One person worth $10 million holds 15% and control. Lighthouse holds up to 85%|That person, not the board, controls the team'),
  '**Recommended: Route A.** It is the only route U.S. Soccer has plainly accepted. The owner can be a benefactor who does it for the club and not for profit. Lighthouse keeps its place by contract:',
  '**Recommended: Route A.** It is the only route U.S. Soccer has plainly accepted. The owner can be a benefactor who does it for the club and not for profit.
**The team company is a benefit corporation.** Pennsylvania law allows a company with shareholders whose charter commits it to a public benefit. That fits both sides: it has shares, so one person can own 15%, and it is bound to a purpose, so it stays a Lighthouse team.
- **Purpose in the charter.** The company must pursue a general public benefit and can name specific ones. Ours: soccer for the young people and families of the neighbourhood, and support for Lighthouse.
- **Directors must weigh the community.** They answer for the effect of their decisions on the community and the staff, not only for profit.
- **A public report every year.** It tells the shareholders what the company did for its purpose, is measured against an outside standard, is filed with the state and is posted on the website.
- **Owners are named.** The report lists everyone who holds 5% or more.
- **It still pays tax.** A benefit corporation is not a nonprofit. Gifts to it are not tax-deductible. Gifts to Lighthouse still are.
**It does not replace the owner rule.** U.S. Soccer still needs one person worth $10 million holding 15% with control. The benefit corporation is what that person owns a share of.
On top of the charter, Lighthouse keeps its place by contract:'),
  '- Can a nonprofit hold the other 85%?',
  '- Can a nonprofit hold the other 85%?
- Is a benefit corporation acceptable as the team company?'),
  'A nonprofit holding a share of a professional team raises tax questions. A nonprofit lawyer must review the structure before anything is signed.',
  'A nonprofit holding a share of a professional team raises tax questions. A lawyer who knows nonprofits and Pennsylvania benefit corporations must draw up the structure before anything is signed.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Ownership';

UPDATE proposal_sections s SET body = replace(s.body,
  'Have a nonprofit lawyer draw up the structure.',
  'Have a lawyer form the team company as a Pennsylvania benefit corporation.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Steps';

UPDATE proposal_sections s SET body = s.body || $b$
- [Pennsylvania Department of State](https://www.dos.pa.gov/BusinessCharities/Business/Resources/Pages/Pennsylvania-Benefit-Corporation.aspx): benefit corporations
- [15 Pa.C.S. § 3331](https://law.onecle.com/pennsylvania/title-15/3331.html): the annual benefit report$b$
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Sources';

COMMIT;
