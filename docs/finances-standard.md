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

## Removed on 2026-11-14 (root and stem — in git history if wanted back)

- Members pill (Summary)
- Break-even / At capacity (mig 1360, `youth_age_capacities`)
- Scenarios / Playground (mig 1361, `budget_playground_*`, `BudgetPlayground`
  model, `/api/finances/playground`)
- Revenue pill
- Option switches, grants switch, the shared-by table, full-roster and
  team-count boxes (`/plan-roster`, `/plan-teams`)
- The home-games list and the budget-line editor (`/budget-lines/:id`)

## Open question for the owner

1. **Are the grants really awarded?** Coaches $15k, refs $5k and equipment $10k
   are each marked `awarded` for 2026-27, 2027-28 and 2028-29, so the Budget
   counts all $30k a year. If they are only expected, set the status to
   `applied` (by migration) and they drop out of revenue. This flips the year
   between +$12k and −$18k.

## Next, in order

1. **Budget vs Actual** (variance report). For each expense category: budget
   for the year, budget to date (pro-rated, or by Cash forecast timing), actual
   to date, and the difference. Actuals come from invoice lines by
   `invoice_line_categories`, the same tagging Actuals uses. Revenue gets the
   same treatment: dues budget vs LA money in.
2. **Fix Actuals' money-in overcount (~12%).** 26 ACH rows ($1,050) that LA
   dropped are still in `person_payments`. Fix with a periodic full re-pull that
   deletes missing rows and refreshes payout ids. See memory
   `project_la_ach_deleted_rows`.
3. **Statement of Financial Position** (balance sheet): cash in the bank (needs
   a source: LA payouts / bank deposits), dues receivable (`fh_dues_balance_usd`),
   payables (unpaid invoices), and refundable bonds (APSL $1,000) as assets.
   Bonds are currently a fee category (`bonds`, `is_refundable`), but a
   balance sheet treats them as assets.
4. Only after that: the owner's special requests (scenarios, break-even, team
   counts, etc.) if the standard reports don't already answer them.

## Checking the numbers

The owner's admin login can't be used from a Claude session, so the page is
not browser-verified. Totals were re-added in SQL. Use the queries in this
doc's commit history, or sum `team_fee_plan_lines` + `budget_lines` (year
units) + coaching policies × games for the year.
