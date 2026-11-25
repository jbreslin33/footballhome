-- 🚀 APSL Pro proposal: a class of non-voting supporter shares in the league
-- (James 11/24 "so the league benefit corp (bc) would we be able to sell
-- shares with the understaind they prob are not turning a profit and would
-- not have votes?" → "a class of shares like that").  New section 7
-- "Supporter shares in the league" (old 7–15 move to 8–16).  Securities and
-- Pennsylvania company-law points are ours, flagged for a lawyer.

BEGIN;

UPDATE proposal_sections s SET sort_order = s.sort_order + 100
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'apsl-pro' AND s.sort_order >= 7;
UPDATE proposal_sections s SET sort_order = s.sort_order - 99
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'apsl-pro' AND s.sort_order >= 107;

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, 7, 'Supporter shares in the league', $b$If the league is a benefit corporation, it can create a second class of shares for supporters: **non-voting, sold on the understanding that they will probably never pay a dividend**. People buy them to own a piece of the pyramid, not to make money.
**Two classes of shares**
|Class|Who holds it|Votes|Dividends
|**A: Club shares**|The founding clubs in equal blocks, and the APSL|Yes. Elect the board, decide the rules, the revenue share and new clubs|Only if the board pays any
|**B: Supporter shares**|Fans, players, parents, local businesses, anyone|**No**|Not expected. Ranked after the clubs' needs and the solidarity share
Control stays with the clubs however many supporter shares are sold. The $10 million owner rule is for each team, not the league, so U.S. Soccer does not limit who holds league shares.
**What a supporter gets**
- A real share in the league, in their name, with a certificate.
- The yearly benefit report and the yearly accounts.
- Perks the league chooses: a supporters' day, first chance at final tickets, their name on the founders' wall.
- No promise of money back. The offer says so plainly.
**How it is sold**
Shares are securities even when nobody expects a profit, so the sale needs an exemption from registration with the SEC.
|Route|Limit|Fits
|**Regulation Crowdfunding**|Up to $5 million a year, from anyone|**The usual route for fan shares.** Sold through a registered online portal, with a disclosure filing and yearly reports
|Regulation A|Much larger|Costs more and takes longer. Later, if ever
|Regulation D|Mostly wealthy investors|For a few larger backers, not for fans
**The offer must say**
- The league may never make a profit, the shares may never pay, and they are hard to sell on.
- Supporter shares have no vote.
- Where the money goes: the commissioner and office, the bond fund, media, the first seasons.
**What non-voting does not take away**
- Pennsylvania law may still give every shareholder the right to see the books, and a class vote on changes that hurt their class, such as a merger or changing the shares' terms.
- Benefit corporation law lets shareholders take the company to court if it ignores its stated purpose. Pennsylvania may require a minimum holding to do so.
**Examples.** The Green Bay Packers have sold "stock" to fans that pays no dividends and can hardly be resold. Chattanooga FC and Detroit City FC sold shares to their fans through crowdfunding. The same can be done club by club: Lighthouse's pro team can sell its own supporter shares too.
The securities and company-law points are ours. A lawyer must confirm them and draft the share terms before anything is offered.$b$
  FROM proposals p WHERE p.code = 'apsl-pro'
ON CONFLICT (proposal_id, sort_order) DO NOTHING;

UPDATE proposal_sections s SET body = replace(s.body,
  'Investors can buy a minority to fund the start: commissioner, office, media and the bond fund.',
  'Investors can buy a minority to fund the start: commissioner, office, media and the bond fund. Supporters can buy non-voting supporter shares (see Supporter shares in the league).')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'apsl-pro' AND s.heading = 'Recommended: the league and the teams';

UPDATE proposal_sections s SET body = replace(s.body,
  '- **Revenue share:**',
  '- **Supporter shares:** offer non-voting supporter shares in the league through crowdfunding, and how much to raise?
- **Revenue share:**')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'apsl-pro' AND s.heading = 'Decisions';

COMMIT;
