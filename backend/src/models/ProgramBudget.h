#pragma once
#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// ProgramBudget — #finances 🧩 Programs (migration 1390).
//
// Owner 2026-11-16: "each team a separate item with its own budget then we
// can roll them up … i need to see if a team itself is sustainable" → a
// PROGRAM is a year-round group (Men's, Women's, one youth age or band) →
// "assume 1 potential coach for every practice session and game for eacch
// team" → shared costs by players → flexibility for next year and for this
// year's winter / spring / summer ("we know fall").
//
// build(): every budget year from this one on, every season, every program:
// lines in four groups —
//   dues     money in from the program's own players
//   own      its own costs (its teams' leagues, refs, coaching, its section's
//            lines split by players); LeagueApps fees on its dues
//   shared   club-wide costs, split by PAYING players
//   support  its share of the restricted grant (by coaching + referees +
//            equipment) and of CASA rental (by paying players)
// A REAL season (budget_season_actuals) reads the books: LeagueApps payments
// by payer → program (fh_finance_program), CashFlow items by scope → program.
// A PLAN season reads program_season_plans / program_season_entries; NULL
// fields take the live default (see the migration). This year's plan seasons
// add the money still ahead from Expenses (installments, refs, budget lines)
// for Men's / Women's; youth plan seasons price their entries from the rate
// card instead (their team fee plans would count twice).
// docs/finance-programs.md.
class ProgramBudget {
public:
    static nlohmann::json build(int clubId);
};
