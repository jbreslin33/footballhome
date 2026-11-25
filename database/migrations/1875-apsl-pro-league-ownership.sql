-- 🚀 APSL Pro proposal: the LEAGUE's own legal form, not only the teams'
-- (James 11/24 "i mean benefit corp or non profit of the league itself lol
-- but also teams").  New section 6 "The league itself: nonprofit or benefit
-- corporation" (old 6–14 move to 7–15); the two team-model headings say
-- "The teams"; "Recommended" covers the league and the teams.
--
-- From the Standards PDF (3-26-2026): nothing sets the league's legal form;
-- the league must be a U.S. Soccer organization member (I.x.1, I.x.13); a
-- single-entity league is allowed but needs separate people running each
-- team (I.iv.4) and must secure its own obligations (I.c.i).  NFL league
-- office 501(c)(6) until 2015, MLB until 2007: press facts.  Tax points
-- are ours and flagged for a lawyer.

BEGIN;

UPDATE proposal_sections s SET sort_order = s.sort_order + 100
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'apsl-pro' AND s.sort_order >= 6;
UPDATE proposal_sections s SET sort_order = s.sort_order - 99
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'apsl-pro' AND s.sort_order >= 106;

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, 6, 'The league itself: nonprofit or benefit corporation', $b$U.S. Soccer does not say what kind of body a league must be. It must join U.S. Soccer as a member, meet the standards and pay U.S. Soccer's costs of review. So APSL Pro, the league, can be a nonprofit or a company. Each team then makes its own choice (next sections).
**Three shapes for the league**
|Shape|What it is|Example
|**Nonprofit league owned by its clubs**|A members' association, tax-exempt as a business league (501(c)(6)). The clubs are the members. No shares, no profit taken out: what is left after costs goes back to the clubs and down the pyramid|The NFL's league office was a 501(c)(6) until 2015, and MLB's until 2007. The APSL and USASA are member associations today
|**Benefit corporation**|A company with shares, owned by the founding clubs and outside investors, with its public purpose (a pyramid with solidarity, amateur to pro) written into its charter|MLS is a company owned by its club owners, though not a benefit corporation. No U.S. soccer league is one yet
|**Single entity**|The league owns every team and runs them centrally. U.S. Soccer allows it, but separate people must run each team, and the league must secure every team's obligations itself|MLS, at its start in 1996
**Nonprofit league**
|Pros|Cons
|The revenue share and solidarity fit its purpose. Nobody takes a profit, so the pot goes to the clubs and the clubs below|**No investors.** It cannot sell shares to raise money for the office, media or a bond fund
|Neutral: no owner can run the league for himself. Clubs trust it|Money comes only from club dues, sponsors and media. A slow start
|Its income is not taxed while it serves its members|Dues and gifts to a 501(c)(6) are not tax-deductible as charity. Only a 501(c)(3) gets that
|Easy to sit beside the APSL, which works the same way|Pro leagues have given up this status (NFL, MLB) once their money grew
**Benefit corporation league**
|Pros|Cons
|**Can take investors** for the start-up money: commissioner, office, media, the bond fund|Investors want a return. They may push for an entry fee or a cut that the clubs pay
|The pyramid and solidarity are written into the charter, and the directors must keep to them|Its profit is taxed
|Can sign media and sponsor deals as a business, with no limits on business income|Control can drift to the biggest shareholder unless the charter protects the clubs
|Shares in the league can be given to the founding clubs, so they own what they build|A yearly benefit report must be published
**Single entity** is the cheapest for each club (the league posts the money) but needs the most money at the centre, and the clubs stop being independent. It does not suit old clubs like Lighthouse, so we do not recommend it.
**Gifts.** Neither a 501(c)(6) league nor a benefit corporation can take tax-deductible gifts. For that, the solidarity money can pass through a separate charity (a 501(c)(3) foundation) that funds amateur and youth soccer under the league. See Recommended.$b$
  FROM proposals p WHERE p.code = 'apsl-pro'
ON CONFLICT (proposal_id, sort_order) DO NOTHING;

UPDATE proposal_sections s SET heading = 'The teams, model A: nonprofit'
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'apsl-pro' AND s.heading = 'Ownership model A: nonprofit';
UPDATE proposal_sections s SET heading = 'The teams, model B: benefit corporation'
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'apsl-pro' AND s.heading = 'Ownership model B: benefit corporation';

UPDATE proposal_sections s SET heading = 'Recommended: the league and the teams', body = $b$Use each model for what it does best.
**The league**
- **APSL Pro is a benefit corporation owned mostly by its founding clubs**, each club with an equal block of shares, and the APSL holding a share and a board seat for the amateur pyramid. Investors can buy a minority to fund the start: commissioner, office, media and the bond fund.
- **The charter protects** the equal revenue share, the solidarity share to the clubs below, and the clubs' majority. No investor can buy control.
- **The APSL Pro Foundation**, a separate 501(c)(3), receives the solidarity share plus gifts and grants, and pays it out to the APSL conferences and youth clubs below. Gifts to it are tax-deductible.
- If the founding clubs would rather have no investors at all, the league can be a **nonprofit members' association** (501(c)(6)) instead, with the same foundation beside it. The trade: trust and simplicity, but slower money.
**The teams**
- **Lighthouse stays the nonprofit.** It keeps the youth teams, the amateur men and women, the ground and the history. Gifts and grants go here.
- **The professional team is a Pennsylvania benefit corporation.** Its purpose: professional soccer for Philadelphia, a path for Lighthouse youth, and the neighbourhood.
- **Shares:** a principal owner with 15% or more who meets the $10 million rule; Lighthouse with a block of shares and a board seat for the name and the ground; fans through a crowdfunding offer; other investors for the rest.
- **The charter protects** the name, the home in Philadelphia, and Lighthouse's board seat, so the team cannot be moved or renamed by a buyer.
Other founding clubs can choose their own model. The league only needs each team to meet U.S. Soccer's owner rule.
The points on nonprofit, tax and securities law are ours. A lawyer must confirm them before any money is taken.$b$
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'apsl-pro' AND s.heading = 'Recommended: both together';

UPDATE proposal_sections s SET body = replace(s.body,
  '- **3 Ownership.** Each club picks nonprofit, benefit corporation, or both together, and finds its principal owner.',
  '- **3 Ownership.** The founding clubs choose the league''s form: benefit corporation or nonprofit association, with a foundation beside it. Each club picks its own model and finds its principal owner.')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'apsl-pro' AND s.heading = 'Steps';

UPDATE proposal_sections s SET body = replace(s.body,
  '- **Ownership model for Lighthouse''s team:**',
  '- **The league''s form:** benefit corporation owned by the clubs (recommended), or nonprofit members'' association?
- **Ownership model for Lighthouse''s team:**')
  FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'apsl-pro' AND s.heading = 'Decisions';

UPDATE proposals SET summary = 'From James Breslin: turn the APSL''s strongest clubs into a Division III professional league. U.S. Soccer needs 8 teams to apply. Start with a pre-pro season as soon as clubs are ready, apply for provisional sanctioning at 8. The league and the teams each compared as nonprofit and benefit corporation, with revenue shared among the clubs and down the pyramid.'
 WHERE code = 'apsl-pro';

COMMIT;
