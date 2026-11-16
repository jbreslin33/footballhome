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
2. ✅ Editing on the page (11/16, mig 1393): each plan season's players,
   teams, practice h/wk + weeks, games, hours a game, coach paid / volunteer
   + $/h (empty = back to the live default); the Total column sets every plan
   season of the year; youth leagues ✕ / ＋ from `league_options` (league
   seasons with a rate card, by the season their start falls in).
   `POST /api/finances/program-plan` {program, year, season|"all", fields} and
   `/program-entry` {program, year, season, league_season_id, age_band,
   teams, remove} answer the whole programs again. The books (CashFlow,
   Expenses) are cached 60 s in ProgramBudget so an edit takes ~2.5 s.
3. ✅ (11/16, mig 1397) 👥 Full capacity = `GET /programs?scenario=capacity`:
   every program fields at least one team per plan season, players = teams ×
   capacity (capacity = the program's own teams' `max_roster`; a team shared
   with another program only when it has none). Coach / practice / games /
   leagues are the same plan rows, so the two scenarios can't disagree; a
   real season stays real. mig 1387's CapacityPlan model, `/capacity` routes
   and `capacity_plan_teams` / `_coaches` tables are gone;
   `capacity_plan_settings` stays (coach rate, weeks a year, calendar weeks).
   The **Operating Budget of a later year** (2027-28 on) adds up from the
   programs, expected scenario (`_budgetFromPrograms`): dues per section,
   CASA + grant from the support lines, expenses = own + shared lines by
   category, one line per program; Who pills pick programs by section,
   Club-wide = the shared lines. This year's Operating Budget, Budget vs
   Actual, the statements and the forecast are unchanged.

## 💵 Men's money (mig 1407, 11/16)

Opening Men's on 🧩 Programs shows a card above the season table (page
only, `_menCompetitions` / `_menMoneyHtml`): money in (dues, CASA share),
money out in one coloured band per competition — APSL (+ Reserves), Liga 1,
U23, Cups with each cup its own block (by the entry's league) — then what
every men's team shares (Men's budget lines, LeagueApps fees) and the
club-wide share; balance BEFORE the grant (grant-proof or short), the grant,
balance after; dues per man a month that fund it (without / with the grant,
at paying-now and full-house heads, grossed up for LeagueApps' cut);
options (Liga 2, Temple 7s) beside it, never in the total. Out = the team
fee plans (rate × qty) + game coaching per team (`ref_fees.team_scope`).
This year matches the Year plan's Men's pill to the dollar; a later year's
dues / grant / CASA / club share come from the programs.
