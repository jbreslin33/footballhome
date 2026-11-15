# #finances — the standard nonprofit set

Status notes so we can pick this up later. Last updated 2026-11-14.

## The rule

Owner, 2026-11-14: *"please just the standard industry standard for non profits
and take out everything else root and stem. we can always add back but we will
start clean!"* … *"then we can add my special requests after we see if the
standard non profit stuff holds it already."*

So: build the standard reports first. Add back a bespoke view only when the
owner asks for it after seeing the standard reports.

## What is live (commit 4289d849, mig 1367)

| Pill | Standard name | Code |
|---|---|---|
| 📋 Budget | Operating budget | `finances.js` `_planHtml` ← `GET /api/finances/expenses` (`plan`, `budget`, `ref_fees`, `plan_heads`, `plan_dues`, `plan_grants`) |
| ⚖️ Budget vs Actual | Variance report (mig 1369) | `finances.js` `_varianceHtml` ← `_budgetModel` (same numbers as Budget) + `/cash-flow` items |
| 💵 Actuals | Statement of activities, cash basis | `components/money-view.js` ← `/cash-flow`, `/summary`, `/expenses` |
| 🗓 Cash forecast | Cash-flow forecast | `finances.js` `_expensesHtml` ← `/expenses` |

**Budget layout:** Revenue → Expenses by category → Net surplus / (deficit), per
year and per month. Year pills run Aug 1 – Jul 31 (`budget_years`). The Who pills
filter it, and a section pill carries its share of the club-wide costs, split
by paying members.

- **Dues** = paying members (active league program, never pickup, not free,
  volunteer or injured) × `dues_policies` monthly × 12, per section. Women's =
  the club covers them ($0). A team pill shows no dues, because dues are pooled
  per section.
- **Grants**: `income_awards` with status `awarded` or `received` are always
  revenue, restricted to their purpose (standard practice).
- **Expenses** = team fee plans (`team_fee_plan_lines`, rate × qty; `is_option`
  entries such as Liga 2 and Temple 7s are never counted), section and
  club-wide `budget_lines`, plus game coaching (`ref_fee_policies`
  kind='coaching', this year only).
- **Kits** = $35 × NEW players only (mig 1364, `fh_budget_new_players`: players
  who joined this budget year + open roster spots; a year ahead counts like
  this one). Kits are issued once, and a player pays for a lost kit.

**2026-27, All:**

| | |
|---|---|
| Dues | $47,880 |
| Grants (restricted) | $30,000 |
| Expenses | $65,738 |
| **Net surplus** | **+$12,142** (−$17,858 without the grants) |

**Expenses by category:**

| Category | Amount |
|---|---|
| Coaching | $27,330 |
| Referees | $10,645 |
| Facilities | $8,600 |
| League dues | $8,308 |
| Uniforms | $3,570 |
| Registrations | $3,260 |
| Equipment | $2,200 |
| Medical | $1,100 |
| Field rentals | $500 |
| Filming | $225 |

**Budget vs Actual** (added 2026-11-14, mig 1369): this budget year only. Each
Budget revenue line and expense category beside actual money through the last
closed month (cash-flow items with `!ahead`, `ym < this month`; prepaid
installments count). Budget to date = year budget × closed months / 12. Variance
+ = favourable. Money with no budget line shows as "(not in the budget)" (field
rentals). A section pill's club-wide share = club-scope money out × the same
paying-member fraction the Budget uses. Grants count as actual only once
`received`. Dues actual is net of LeagueApps fees; the budget is gross (the page
says so). Tap a row to see the lines behind its actual.

Also fixed the same day: 4289d849 had deleted `FinancesScreen.load()`, so the
page never loaded its data. Restored.

## Removed on 2026-11-14 (root and stem — in git history if wanted back)

- Members pill (Summary)
- Break-even / At capacity (mig 1360, `youth_age_capacities`)
- Scenarios / Playground (mig 1361, `budget_playground_*`, `BudgetPlayground`
  model, `/api/finances/playground`)
- Revenue pill
- Option switches, grants switch, the shared-by table, full-roster and
  team-count boxes (`/plan-roster`, `/plan-teams`)
- The home-games list and the budget-line editor (`/budget-lines/:id`)

## Soccer is a Lighthouse program (owner 2026-11-14)

"soccer is part of lighthouse. they have other programs. lh sends me money that
i invoice to lh … we will never physically see the casa or grant money" + "la
goes to lh too". Lighthouse holds ALL the money and pays soccer's invoices.
So Budget and Budget vs Actual run in **two layers** (mig 1376): soccer's own
dues against its costs ("over budget" on dues alone is expected), then the
**Lighthouse credits** (grants, sponsors, CASA rental) and what is left after.

## Where the money comes from (owner 2026-11-14)

"all money that goes in comes in via league apps OR is a grant OR is CASA
Rental … same with sponsor it would go to lighthouse but not directly to soccer
but we need to budget credit for it. all expenses should be listed in
invoices." + "invoices paid when final, casa always pays".

- **Grants**: $50k a year for 2026-27, 2027-28 and 2028-29 (2026-27 `received` 11/14, mig 1375; later years `awarded`),
  restricted to coaches, referees and equipment (one row a year, purpose NULL —
  no split given; mig 1372 replaced the nine 11/13 prospect rows).
- **Sponsors**: `income_awards` kind `sponsorship` (none yet) — Budget revenue
  once awarded/received.
- **Received** grant/sponsor money = `income_receipts` (dated), or the whole
  award once its status is `received`.
- **CASA rentals**: calendar bookings × $75/h (`field_rental_policies`) — Budget
  revenue for the current year = bookings on the calendar in the year (only
  fall is booked so far: 5 × $300 = $1,500).
- **Bonds** are deposits: never an expense (Budget, Budget vs Actual), an asset
  on Soccer fund. None are recorded yet.

## 🏦 Soccer fund (mig 1372) — statement of financial position

Club-wide. Soccer has no bank account; Lighthouse holds its money. Cash =
LA dues net + rentals + grants/sponsors received since Aug 1 − invoices paid
(cash-flow out items to date − `invoices` draft totals). Plus dues owed
(`summary.all.owed`), awards not yet paid, bonds; less draft invoices = net
assets.

## Next, in order

1. ~~Budget vs Actual~~ — done (mig 1369). Possible follow-up: budget to
   date by Cash forecast timing instead of straight pro-rata, if seasonal
   costs make the variance noisy.
2. ~~Fix Actuals' money-in overcount~~ — done 2026-11-14 (mig 1370).
   `PersonPayments::reconcileFromLa` runs from `LaSyncScheduler` at most every
   6 h: re-pulls transactions-2 from `reconcile_from_ms` (2026-01-01), upserts
   every row (refreshes payout ids), and moves rows LA no longer returns into
   `person_payments_la_dropped` (whole row as jsonb; restore SQL in the table
   comment). Guards: nothing dropped if the pull hit the page cap, or if more
   than max(10, 5%) of judged rows are missing. First run dropped 36 ACH
   "Bank" rows, $2,197 net, 7/13 – 11/11 (all programs, not just soccer).
3. ~~Statement of Financial Position~~ — done as 🏦 Soccer fund (mig 1372).
   Possible follow-ups: split net assets into with / without donor
   restrictions (unspent grant money); a sponsor/grant entry form instead of
   migrations.
4. Only after that: the owner's special requests (scenarios, break-even, team
   counts, etc.) if the standard reports don't already answer them.

## Checking the numbers

The owner's admin login can't be used from a Claude session, so the page is
not browser-verified. Totals were re-added in SQL. Use the queries in this
doc's commit history, or sum `team_fee_plan_lines` + `budget_lines` (year
units) + coaching policies × games for the year.
