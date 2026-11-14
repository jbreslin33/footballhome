#pragma once
#include <optional>
#include <string>
#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// BudgetPlayground — 🧪 the Budget page's what-if copy of a budget year
// (migration 1361).
//
// Owner 2026-11-14: "for men i needed adjustable projections in current and
// years after or number of teams and players paying. for youth i need to be
// able to add x amount to u8 to u16 teams and add B teams etc. i need ability
// to add coaches to these for the hours. so i can see if we can scale" + "a
// button to put all back to default" + "a playground where i can do this and
// not touch current live ones and real projected".
//
// Its own tables (budget_playground_*); nothing in the real plan reads them.
// The first open of a year — and ↺ — runs fh_budget_playground_reset, which
// rebuilds that year's copy from the real plan.  The page does the sums:
//   team    team_count × (cost_per_team + players × kit) + its coaches × team_count
//   income  team_count × players × dues a month × 12
//   coach   rate_per_hour × hours × times (weeks or games)
class BudgetPlayground {
public:
    // { years: [{id, label}], year: {id, label, copied_from}, groups: [{code,
    //   label, emoji, dues_monthly, kit_per_player, note}], teams: [...],
    //   coaches: [...] } — seeds the year first if it has never been opened.
    // yearLabel empty = this budget year.
    static nlohmann::json state(int clubId, const std::string& yearLabel);
    static bool reset(int clubId, int yearId);
    static int yearId(int clubId, const std::string& yearLabel);   // empty = this budget year; 0 = none

    // Field edits (whitelisted per kind).  False = not this club's row.
    static bool saveTeam(int clubId, int id, const nlohmann::json& fields);
    static bool saveCoach(int clubId, int id, const nlohmann::json& fields);
    static bool saveGroup(int clubId, int yearId, const std::string& group, const nlohmann::json& fields);

    // New rows: a team (blank, or a copy of copyOf with its coaches — the
    // "B team"), a coach on a team or section-wide.  Returns the id, 0 if not found.
    static long long addTeam(int clubId, int yearId, const std::string& group, std::optional<int> copyOf, const std::string& label);
    static long long addCoach(int clubId, int yearId, const std::string& group, std::optional<int> teamId, const std::string& label);
    static bool remove(int clubId, const std::string& kind, int id);
};
