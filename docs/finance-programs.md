# #finances 🧩 Programs — a budget per program, per season

Started 2026-11-16 (mig 1390). Model: `backend/src/models/ProgramBudget.cpp`,
endpoint `GET /api/finances/programs` (laGet: syncs the four LA programs
first), page: `FinancesScreen._programsHtml` in `frontend/js/screens/finances.js`.

## What the owner asked for

- *"each team a separate item with its own budget then we can roll them up or
  total them. i need to see if a team itself is sustainable"*
- *"take in the whole year of an age bracket just like the mens program … youth
  from u8 up would have ppr league in fall, winter and spring. men you know have
  us open cup, u23 etc"*
- *"lets do singe age but leave open ability to do 2 or 3 year bands"*
- *"assume 1 potential coach for every practice session and game for eacch team"*
- Shared costs: **by players**.
- *"for current budget do what it currently is. i am talking about next year we
  need flexibilty"* + *"flexibilty in winter and spring and summer this year
  since we know fall"*.

The five standard reports are unchanged; Programs is the planning lens.

## Data

| Table | What |
|---|---|
| `finance_programs` | Men's, Women's, U5…U16 (`age_from`..`age_to` — a band = one row with a range, the single ages switched off) |
| `finance_program_teams` | a program's teams (calendar hours, fee plans, cash-flow scopes); a team in two programs splits by players |
| `budget_seasons` | fall Aug–Nov, winter Dec–Feb, spring Mar–May, summer Jun–Jul |
| `budget_season_actuals` | seasons read from the books (2026-27 fall) |
| `program_season_plans` | per program × year × season: players, teams, practice h/wk, practice weeks, games, h/game, coach paid + rate — NULL = live default |
| `program_season_entries` | youth leagues per plan season, priced from `league_fees` |
| `fh_finance_program(club, category, birth, years_ahead)` | payer → program (youth by US Club Soccer age; older than U16 → boys Men's, girls Women's) |

## The money

Four groups per program-season: **dues**, **own** costs, **shared** costs,
**support** (grant + CASA).

**Real season:** dues = approved LeagueApps money (before fees, fines in) by
payer → program; LA fees its own line. Costs = every CashFlow money-out item
in the months (bonds out) by scope: a team scope → its programs, a section
scope → that section's programs by players, club → shared.

**Plan season:**
- players default = today's paying players × the share of dues actually
  collected over the last 3 closed months (reality rule); later years move
  the youth up an age per year (U16 → Men's / Women's)
- teams default = players ÷ capacity (`teams.max_roster`), rounded up
- dues = players × monthly dues × months (Women's: none)
- coaching = teams × (practice h/wk × weeks + games × h/game) × rate —
  one coach per team for every practice and game; practice h/wk default = the
  calendar's next 4 weeks (busiest of the program's teams); weeks = the
  season's share of 50
- youth leagues = rate card: per kind + unit the band's row, else the
  band-free one; several left → the cheapest (PPR indoor's $100 "PPR teams"
  price vs $200); bonds and game coaching never count
- Men's / Women's: this year = Expenses' money still ahead (installments,
  refs) in the season's months; later years = their team fee plans by the
  league season's start (options, bonds, game coaching out)
- budget lines (not coaching): this year their projected months, later years
  year total × months ÷ 12; club scope → shared by paying players

**Support:** the restricted grant's used amount (≤ award, ≤ the year's spend on
its purposes) is split by each program-season's spend on those categories;
CASA rental (mig 1389) by paying players.

**Own net** = dues − own costs (does it pay for itself?). **Net with shared** =
own net − shared + support.

## Steps

1. ✅ Programs, seasons, plans, the read-only pill (11/16).
2. Editing on the page: players, teams, practice, games, coach paid / rate,
   leagues per plan season.
3. Full capacity = the same model with players at capacity; Operating Budget
   for later years reads the programs.
