# #finances — the standard nonprofit reports, and only those

Last updated 2026-11-14 (mig 1379).

## The rule

Owner, 2026-11-14: *"it needs to be standard and standard only lol. we can
always add custom later."* (After *"just the standard industry standard for
non profits and take out everything else root and stem"*.) Nothing custom on
the page; add a bespoke view only when the owner asks for it.

## Soccer is a Lighthouse program

*"soccer is part of lighthouse. they have other programs. lh sends me money that
i invoice to lh … we will never physically see the casa or grant money"* + *"la
goes to lh too"* + *"invoices paid when final, casa always pays"*.

- Money in = LeagueApps dues, CASA field rental ($75/h, calendar bookings),
  grants and sponsorships (`income_awards`, receipts in `income_receipts`).
  All of it lands with Lighthouse.
- Money out = invoices only; paid once final (a draft = accounts payable).
- Soccer's books start at zero on Aug 1 of the budget year (`cash_flow_policies`).

## The five reports (`frontend/js/screens/finances.js`)

| Pill | Code | Scope |
|---|---|---|
| 🏦 Statement of Financial Position | `_positionHtml` ← `_ledger` | club-wide, as of today |
| 📊 Statement of Activities | `_activitiesHtml` ← `_ledger` | club-wide, Aug 1 → today |
| 📋 Operating Budget | `_planHtml` ← `_budgetModel` | year; Who pills |
| ⚖️ Budget vs Actual | `_varianceHtml` ← `_budgetModel` + cash-flow items | through last closed month; Who pills |
| 🗓 Cash Flow Forecast | `_forecastHtml` | club-wide, month by month |

Data: `/api/finances/summary`, `/expenses`, `/cash-flow`.

**Ledger (accrual):** expenses when invoiced (every line, bonds excluded);
a guaranteed (unconditional) grant/sponsorship is revenue in full in the year
it was promised (`income_awards.promised_on`, mig 1380, ASC 958-605) — every
year of a multi-year promise — with donor restrictions when `purposes` names
categories or the installment is for a later year (time). Its own year's
spending on those categories releases it (capped at the award); a purpose-free
one promised earlier is released when its year begins. Unpaid installments are
grants receivable, split due within one year / later (full amount, not
discounted). Statements cover the current budget year only. Dues = paid through LA (net of
fees) + dues owed now (receivable). Cash = received − (invoiced − drafts) −
bonds paid. The two statements tie by construction (tested).

**Uncollectible dues (mig 1381):** `dues_allowance_tiers` (club, months behind
from, % uncollectible; seeded 1 → 10%, 2 → 50%, 4+ → 100%) ages each member's
balance (`fh_dues_doubtful_usd`: CEIL(owed ÷ monthly rate) months). The total
is `summary.all.allowance`. Financial Position: dues receivable less the
allowance; Activities: the allowance is an expense. Budget dues × the
expected collection rate = 1 − allowance ÷ (dues paid since Aug 1 grossed up
for LA fees + owed now), so BvA uses it too.

**Restricted grant on the internal reports (mig 1382):** Budget vs Actual's
grant actual and the Cash Flow Forecast's grant receipts = spending on its
purposes, month by month, capped at the award (= released from restrictions
on the Statement of Activities). Unrestricted awards still count on receipt.

**Budget:** Revenue — earned (dues = paying × dues × 12; CASA bookings in the
year) and contributed (grants, sponsors awarded/received) — then expenses by
category (team fee plans, section + club-wide budget lines, game coaching;
`is_option` entries never counted; bonds never an expense), net surplus.

**Budget vs Actual:** budget to date = year × closed months / 12; + variance =
favourable.

**Cash Flow Forecast:** past months actual (LA dues per section, rentals,
invoices); this month on projected (members current in dues, calendar
bookings, grant receipts on their date, coaches' usual hours, game coaching +
refs, fee plans, budget lines). Beginning cash 0 on Aug 1.

## Data right now

- Grant: $50k/yr 2026-27 → 2028-29, guaranteed ("its gauranteed" 11/14),
  promised 11/14 → all $150k recognised in 2026-27 as restricted; restricted
  to coaching / referees / equipment (`purposes`); 2026-27 received 11/14
  (mig 1375). The Operating Budget / BvA still show this year's $50k
  installment (operating view).
- 2026-27 Budget: dues ~$48.3k + CASA $1.5k (fall bookings) + grant $50k −
  expenses $65.7k ≈ +$34k.
- No sponsors, no bonds recorded yet.
- LA payments reconcile (mig 1370) runs every ≤6 h and drops rows LA deleted
  into `person_payments_la_dropped`.

## Removed (root and stem, in git history)

Members, Break-even / At capacity, Scenarios / Playground, Revenue pill,
option switches, roster / team-count boxes, budget-line editor (mig 1367);
Soccer fund, Actuals (MoneyView), the custom cash grid, the two-layer
Budget, self-sufficiency line, the #cash-flow screen + its menu page (mig
1376–1379). `#cash-flow` links land on #finances (`NavigationStateMachine.RETIRED`).

## Possible later (only if the owner asks)

A form to enter grants / sponsors / receipts (today: by migration); splitting
the grant into per-purpose rows; budget to date by forecast timing.

## Checking the numbers

The owner's admin login can't be used from a Claude session, so the page is
not browser-verified; logic is tested in node with stub data.

**Dues from reality (mig 1385):** Budget dues per section = collected so far
(LA payouts after fees) + the last 3 finished months' average × months left
(next year: average × 12); the Cash Flow Forecast uses the same average ahead.
Dues items carry `section` (from the LA program's category) — never map dues
to sections through the scope tree (youth teams sit under Youth, so Boys lost
its team-tagged dues; Oct showed $1,898 instead of $3,080). The collection-rate
guess is out of the budget; the allowance stays on the statements.

**CASA rental seasons (mig 1389):** owner 11/16 *"casa will rent in sspring"*
→ same as fall, projected. `field_rental_seasons` (fall Sep–Nov, spring
Mar–May, 5 sessions × 4 h each) + `fh_field_rental_projected(club)`: per
budget year and season, any calendar booking in the season's months wins;
otherwise sessions × hours × the policy's rate, spread over the months.
CashFlow adds this year's unbooked months as `projected` items still ahead
(Cash Flow Forecast; never actuals, so statements and BvA ignore them) and
`rental_years` (booked + projected per year) for the Operating Budget and
Full capacity in later years. 2026-27: $1,500 booked + $1,500 spring
assumed; 2027-28 on: $3,000 assumed.
