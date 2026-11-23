-- 🏆 USL League One proposal: a "Draft terms" section saying what is still a
-- draft and what could change (James 11/23 "add all that to proposal and we
-- can edit as we go"). New section 12; Steps, Questions, Decisions, Sources
-- move to 13–16.

BEGIN;

UPDATE proposal_sections s SET sort_order = s.sort_order + 100
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.sort_order BETWEEN 12 AND 15;
UPDATE proposal_sections s SET sort_order = s.sort_order - 99
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.sort_order BETWEEN 112 AND 115;

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, 12, 'Draft terms', $b$This proposal is a working draft. The requirements, the costs and the two clubs' structures come from the sources listed. The terms of the Lighthouse company are ours, written to be edited.
**Drafted by us, not yet agreed with anyone**
- **The share split.** 15% to the principal owner, 75% to 85% to Lighthouse, up to 10% to supporters.
- **The protected matters.** The list of things the company cannot do without Lighthouse's consent.
- **The payments to Lighthouse.** The licence fee, the rent and the youth soccer payment. No amounts are set.
- **The supporters' class.** Whether to have one, its size and its price.
- **The charter purpose.** The wording of the public benefit.
**What could change them**
- **The owner rule.** It requires a "controlling interest." The USL or U.S. Soccer may say some of Lighthouse's vetoes go too far and must come out.
- **The principal owner.** He will have his own terms. Someone who backs the losses will want a say in how they are limited.
- **The law.** A lawyer who knows nonprofits and Pennsylvania benefit corporations must draw up the company. We have read the state's rule on the yearly benefit report. The rest of the benefit corporation law is still to be checked.
- **Tax.** A nonprofit holding most of a professional team raises tax questions that the lawyer must answer first.
**Figures that are not quotes**
- The $5,000,000 entry fee and the running costs are press reports. The running-cost range is from about 2019.
- The USL's own seat and market minimums are from its 2018 prospectus.
- The USL sets the real numbers. They are the last question on the list for the first meeting.$b$
  FROM proposals p WHERE p.code = 'usl-league-one';

COMMIT;
