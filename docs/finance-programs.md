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
- players default = today's PAYING players, this year and next, youth and
  adults (owner 11/18 "for this year and next year assume current numbers
  of players we have now that are paying for programs"; replaces 11/16
  youth "full paid roster" and 11/17 adults "only grow"); later years move
  today's kids up an age per year (U16 → Men's / Women's). A typed box wins;
  👥 Full capacity still fills every team.
- teams default = players ÷ capacity (`teams.max_roster`), rounded up
- dues = players × monthly dues × months × the share of dues actually
  collected over the last 3 closed months (reality rule; Women's: none)
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

## 🧮 Program budgets (mig 1639, 11/20)

Owner: *"a pill for each program to figure out budget. then on that pill we
can have sub pills for 'inner' club wide like boys/girls club wide or mens
club wide. then also club wide share, grants, etc. use teams as pills … share
coach with other age groups and pay their share … a player is only counted
1x"*; *"u10 travel is paid for by u8, u9, 10. u12 travel is paid for by u11,
u12"*; *"travel kids can be listed 2x but their money goes to their age"*;
men: *"roll them all together as mens program"*.

Page: `FinancesScreen._pbHtml` (pill `budgets`). Same model, same numbers as
🧩 Programs' season table — no maths on the page.

- **A player is counted once**, in their age program: dues go by payer →
  program (`fh_finance_program`). A team holds no players in the budget, so a
  travel kid on two team lists never counts twice and a team with no players
  yet can carry costs.
- **A cost sits at one level** and is shared, by paying players, by the
  programs under it. `ProgramBudget::build` answers this as `parts` per
  program-season: `level` (program / team / coach / section / club / grant),
  `src` (team, coach or section name), `team`, `whole` (the cost before the
  split), `with` (program codes sharing it), plus the usual group / category /
  key / label / detail / amount. `lines` is unchanged.
- **Who pays for a team** = `finance_program_teams`. On a team's sub pill the
  "Paid for by" chips add / drop a program: `POST /api/finances/program-team`
  `{team_id, program, on}` (only teams already in the budget; never the last
  payer). U10 Travel fall / winter / spring = U8 + U9 + U10; U12 Travel = U11
  + U12; U8 Travel Fall = U7 + U8.
- **A shared coach** = a coaching-plan item (`CoachingPlan`): shared by the
  programs of the team it is for; a volunteer season drops that program's part.
- Sub pills: Overview (plan grid + money in + one row per sub pill + balance
  before / after the grant), `<program> only`, each team, 🧑‍🏫 Shared coaches,
  `<section>-wide`, Club-wide share (CASA rental share shown as money in),
  Grants. Each line: whole cost · shared by · % · this program's part.
- Men's here = the books' fall + the money still ahead, as every program.
  🧩 Programs' Men's ROW shows the Year plan (rate × qty, `_menYear`), so the
  two differ a little (11/20: before grant −$16,042 here vs −$16,289 there).
- Open: costs are still edited where they live (budget lines, team fee plans,
  coach schedule) — only the plan grid and "Paid for by" are editable here.

### The full year, editable (mig 1644, 11/20)

Owner: *"its program based not 'season' inside year based"* → *"show me it
simply for full year with ability to turn things on or off or edit numbers"*
→ *"for coach pay just look at my current hours for coaching and project. but
separate practice from games and have games listed by team then a total"* →
*"allow for it to be rolled minimized so it just shows coaching total … do
that for all items"*. Men's first; every program runs the same code.

- **Overview = one year column.** One block per sub pill, rolled up to its
  total; tap the name for its lines. Seasons are gone from this page (they are
  fixed month blocks, not when a program really changes); 🧩 Programs keeps them.
- **Tick + number on every block and line.** `program_budget_adjustments`
  (program, year, `line_key`, `is_on`, `amount_usd`); no row = worked out, on.
  `POST /api/finances/program-line {program, year, key, on?, amount?}`;
  `build()` answers them as `budgets[year].adjust[program]`. Page only: the
  standard reports, 🧩 Programs and the other programs' shares never read them.
  A balance that differs from the worked-out one says so.
- **🧑‍🏫 Coaching this year = hours really worked, projected**
  (`budgets[year].coach_hours[program]`): invoice shifts on a practice or a
  game since Aug 1, per coach — hours × 365 ÷ days since that coach's first
  shift × his rate. An event's hours are shared by the programs of its teams,
  by paying players; a game sits under its team. Practice first, then games by
  team, block total. The model's own labor lines (paid so far, coaching plan)
  are left out of the page when hours exist. Shifts on no event (other duties)
  are not counted. A straight-line projection: games are not spread evenly
  over a year, so type your own number where it reads wrong.

### Membership grows by the month (mig 1650, 11/23)

Owner: *"there is no reason to break it by season because its a membership. i
think better to do it by year/month … most of what we have is a fixed cost but
membership should grow … a way to project to get more members each month? with
possibly even go over 70 as that means we just don't put them on roster they
are 'reserves'"*.

- `program_season_plans.new_players_month` (NULL = none). The Overview's
  **New members a month** box sets every plan season of the year
  (`/program-plan`, season `all`).
- Each plan month's members = the season's players + the members added so far
  (running through the year and into the next; a later year with typed
  players starts from those). `build()` answers them as `months` per
  program-season; dues = Σ month members × monthly dues × collected share.
- **Only the dues move.** Teams, coaching and the shared-cost split stay on
  the season's players, and nothing caps the count — members past a full
  roster are money in with no cost.
- The dues line on 🧮 Program budgets is one year line, first plan month →
  last (`pb_dues_grow` / `pb_dues_flat`), not one formula per season. Other
  lines whose seasons differ name each season.

### 👥 MEMBERS section (mig 1656, 11/23)

Owner: *"members is key here and we need a good section for it. the rest is
like i said pretty fixed"*; *"show the current paying percent of members and
then we can use that to inform but there should be place for volunteers"*;
*"not all paying members will be on a roster"*.

Top of the Overview, per program. `build()` answers today's counts as
`members_now` (all / owing / paid_now / owing_rostered / free / volunteers /
free_rostered; on a roster = any live `team_persons` row whose status
`counts_as_on_roster`) and his own numbers, saved through `/program-plan`
(season `all`) on `program_season_plans`; NULL = today's count, shown grey:

- Members who owe tuition (`players`) and New members a month — move the dues.
- Share of them who pay (`collect_pct`) — moves the dues; live = last 3 closed
  months; the note shows who has paid so far this month.
- Volunteers and others who don't pay (`non_paying`), how many of them hold a
  roster spot (`non_paying_on_roster`), members who owe but hold none
  (`paying_off_roster`) — head count only, no money.
- **By the end of the year's last month:** all members, on a roster of
  teams × roster size, spots open or the overflow (reserves), and how many
  have no roster spot. New members are assumed to take a spot until it is full.

**As a card (mig 1668, 11/23)** — owner: *"we need the members section
better … it needs to be more clear"*; *"according to tuition page there are
43 current. 8 vols, 10 overdue"*. Above the money table, three parts: TODAY
beside BY THE END OF <month> (paying, owe and not paying, don't pay, all
members, on a roster, no roster spot); YOUR NUMBERS as labelled boxes (each
says whether it moves the money or is head count only); MONTH BY MONTH (all
members, paying, tuition, year total). TODAY uses the Tuition page's own
statuses — `next_due_at` ahead = paying, a current injury = injured, the rest
overdue — so the two pages count the same people. One difference: a boy too
old for U16 counts in Men's here (payer → program by age), so Men's
volunteers can read one higher than the Tuition page's Men tab.

### The whole year, month by month (mig 1707)

The card's MONTH BY MONTH grid runs the full budget year. Months already
lived are **REAL** (`months_real` on each real season, from
`ProgramBudget::build`): members = people with a LeagueApps membership open
at the month's end, paying = people whose approved tuition landed in the
month (net of refunds), tuition = what they paid. The current month is
marked `*` (so far). The rest are **PLAN** months from the boxes above.
"Paying" in a real month counts payments in that month, so it can differ by
one or two from TODAY's "current on tuition" (someone who paid ahead is
current without paying this month).
