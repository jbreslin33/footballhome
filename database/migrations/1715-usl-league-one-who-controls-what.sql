-- 🏆 USL League One proposal: exactly what is outside Lighthouse's control and
-- what Lighthouse controls (James 11/23 "be specific about what would be
-- outside lh control as that is big thing here wiht this net worth owner
-- nonsense" + "and what lh can control"). The owner rule section's small
-- "Who decides what" table becomes two specific lists; The structure gains
-- one protected matter (new shares). Proposed terms, flagged as such.

BEGIN;

UPDATE proposal_sections s SET body = replace(s.body,
  '**Who decides what**
|The principal owner|Lighthouse
|Runs the team day to day|Holds seats on the board
|Signs the lease, the contracts and the league agreement|Must consent to the protected matters
|Casts the team''s vote in the league|Owns and licenses the name and the crest
|Backs the team''s losses|Receives the licence fee and the rent',
  '**In one line.** Lighthouse does not run the professional team. Lighthouse controls what the team is called, where it plays, who owns it next, and what it owes Lighthouse.
**Outside Lighthouse''s control.** The principal owner decides these, and Lighthouse cannot overrule him:
- **The board.** He elects the majority of the directors.
- **People.** Who is general manager, head coach and staff, and when they are replaced.
- **Players.** Who is signed, who is released, and what they are paid.
- **The budget.** How much the team spends each season, ticket prices, and which sponsors it takes.
- **Contracts.** He signs for the team: the league agreement, a rented stadium, the kit supplier, vendors and broadcast.
- **The league.** He casts the team''s vote on every league matter.
- **Raising money.** Whether to borrow or bring in other investors, within the limits below.
- **How long he keeps paying.** He can stop funding the team beyond what he has signed for. If he stops and no one follows, the team folds. Lighthouse cannot make him carry on.
- **Results.** How the team plays and how it is run day to day, under the Lighthouse name.
**In Lighthouse''s control**
- **The name, the crest and the colors.** Lighthouse owns them. The team uses them under a licence with conditions, and Lighthouse can end the licence if the conditions are broken.
- **Where the team is based.** It cannot move without Lighthouse''s consent.
- **Who owns it next.** The principal owner cannot sell or pass on his share without Lighthouse''s consent, and Lighthouse has the first right to choose who follows.
- **The purpose.** The charter cannot be changed without Lighthouse''s consent.
- **Its own share.** No new shares that would cut Lighthouse''s holding without its consent.
- **Its own ground.** The lease sets when the team uses the field. The youth and amateur teams come first on the days Lighthouse names.
- **What it is owed.** The licence fee, the rent and the youth soccer payment are contracts. They are debts the company must pay, not favours.
- **A seat at the table.** Lighthouse''s directors sit on the board, see the accounts, and see the benefit report before it is published.
- **Everything Lighthouse already runs.** The nonprofit, its board, the youth teams and the amateur teams are untouched.
**What Lighthouse gives up.** It does not pick the coach, the players or the budget, and it cannot stop the owner walking away. That is the price of the U.S. Soccer owner rule.
**If it goes wrong.** The team company fails, not Lighthouse. The name and the crest come back, the seats and field work stay, and Lighthouse''s teams play on.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'The owner rule';

UPDATE proposal_sections s SET body = replace(replace(s.body,
  '- Borrow against Lighthouse property.',
  '- Borrow against Lighthouse property.
- Issue new shares that would cut Lighthouse''s holding.'),
  'See The owner rule.',
  'See The owner rule for exactly what is outside Lighthouse''s control and what is in it.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'The structure';

UPDATE proposal_sections s SET body = replace(s.body,
  'Lighthouse holds most of the rest, owns the name and the crest, and sits on the board.',
  'Lighthouse holds most of the rest, owns the name and the crest, and sits on the board. Lighthouse does not run the team: the owner picks the coach, the players and the budget.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'usl-league-one' AND s.heading = 'Summary';

COMMIT;
