-- 🏆 USL League One proposal: a solvency fund in place of a person's net worth
-- (James 11/23 "why can't if the net worth is for purposes of solvency etc
-- cant it be stipluated that is all it can used for if we jack it up").
-- Money restricted to the team's solvency is not a person's net worth, so it
-- cannot be passed off as one; put openly, it is the strongest form of the
-- waiver and of the rule change. Both sections say so.

BEGIN;

UPDATE proposal_sections s SET body = replace(s.body,
  'So the first step is to ask.',
  '**What if the money can only be used to keep the team solvent?** Then it is not his. Money locked to one purpose is a fund, not a person''s net worth, and it cannot be stated to U.S. Soccer as his. But it is a better protection than the rule gives: the rule checks that a man could pay, and a fund is money that must pay. Offered openly, as a fund in place of an owner, it is the strongest case for a waiver and for changing the rule. See If no owner is found.
So the first step is to ask.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Who the principal owner can be';

UPDATE proposal_sections s SET body = replace(replace(s.body,
  '- **What Lighthouse offers in place of an owner.** A bond above the $250,000 minimum. A full season of costs held in escrow before the first game. Audited accounts every year. A benefit corporation that reports to the public.',
  '- **What Lighthouse offers in place of an owner: a solvency fund.** Money held by an outside trustee that can be used for one thing only: paying the players, the staff, the stadium and the league if the team cannot. It is on top of a bond above the $250,000 minimum, and holds at least a full season of costs before the first game. Donors can give to it, and no one can take it back out. Audited accounts every year, and a benefit corporation that reports to the public.
- **Why it is better than the rule.** The rule asks whether one man could pay. He is not required to. The fund is money that must pay.
- **What it costs us.** The net worth rule needs no cash at all. A fund needs real cash, raised before the season.'),
  '- **What we ask for.** One sentence added to Division III: a nonprofit or community-owned club may meet the financial standard without a principal owner by posting a larger bond and holding one season of costs in escrow.',
  '- **What we ask for.** One sentence added to Division III: a nonprofit or community-owned club may meet the financial standard without a principal owner by posting a larger bond and holding at least one season of costs in a fund that can only be used to meet the team''s obligations.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'If no owner is found';

UPDATE proposal_sections s SET body = replace(s.body,
  '- Would the USL ask for a waiver for Lighthouse, with a larger bond and a season of costs in escrow?',
  '- Would the USL ask for a waiver for Lighthouse, with a larger bond and a solvency fund holding at least a season of costs? How large would the fund need to be?')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Questions for the USL';

COMMIT;
