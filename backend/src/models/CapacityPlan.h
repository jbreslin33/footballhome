#pragma once
#include <optional>
#include <string>
#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// CapacityPlan — #finances 👥 Full capacity (migration 1387).
//
// Owner 2026-11-15: "can we have a projection if we fill all teams to
// capicity with paid players … have option to also make the coach for each
// "team" paid or voluneter … allow it for finish of this year and for next"
// + "go by practice schedule on gcal … assume a game for allt eams above u9
// … like 20 games" + "$10 an hour" + "we would pay more with more expericen".
//
// state(): the scenario's teams (capacity_plan_teams) with capacity
// (teams.max_roster), games, hours per game, whether they pay dues, practice
// hours a week read from the calendar right now (the next N whole weeks,
// averaged; a practice that also carries a men's team counts for the men's
// teams only, so U16 — which carries the u17–u19 aliases — isn't paid for the
// men's session), and each budget year's coach setting (paid / volunteer,
// rate; no row = paid at the settings rate). The money itself is worked out
// on the page next to the Operating Budget it borrows the other lines from.
//
// saveCoach(): upsert one team coach for one budget year.
class CapacityPlan {
public:
    static nlohmann::json state(int clubId);
    static bool saveCoach(int clubId, int teamId, const std::string& budgetYear, bool isPaid,
                          std::optional<double> ratePerHour, std::optional<int> userId);
};
