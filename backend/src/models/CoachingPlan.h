#pragma once
#include <string>
#include <vector>

#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// CoachingPlan — every paid coach's hours and money for one budget year, per
// season (migration 1491; owner 2026-11-18 "this all needs to be stored in db
// as normalized … oop" + "we don't want spaghetti code").
//
// It reads FACTS only and works the numbers out here, once, for every report:
//   practice  practice_slots × practice_slot_coaches: each time the slot's
//             weekday falls in the season (less practice_season_breaks for its
//             programs' kind) × its minutes × the coach's hourly rate
//   arrival   coach_arrival_rules: minutes early before the coach's FIRST slot
//             of each practice day, per season
//   game      ref_fee_policies (kind 'coaching', coach_issuer_id) × their
//             ref_fee_seasons: games × hours a game × the policy's rate; a game
//             block counts in the season it starts in
// Each Item names the programs that share it (the slot's programs, or the
// policy team's finance programs) — a caller splits by its own weights.
// ────────────────────────────────────────────────────────────────────────────
class CoachingPlan {
public:
    struct Item {
        long long issuerId = 0;
        std::string coach;
        std::string kind;      // practice | arrival | game
        std::string season;    // budget_seasons.code
        std::string label;     // slot label / policy label
        int times = 0;         // sessions, practice days or games
        double hoursEach = 0;
        double rate = 0;
        std::vector<int> programs;   // finance_programs.id sharing it
        double hours() const { return times * hoursEach; }
        double amount() const { return hours() * rate; }
    };

    // budgetYear: a budget_years.label ("2026-27"); "" = this year
    CoachingPlan(int clubId, const std::string& budgetYear = "");

    const std::string& year() const { return year_; }
    const std::vector<Item>& items() const { return items_; }
    // { year, seasons:[{code,label}], coaches:[{issuer_id,name,rate,by_season,hours,amount}], items:[…] }
    nlohmann::json toJson() const;

private:
    int clubId_;
    int yearId_ = 0;
    std::string year_;
    std::vector<std::pair<std::string, std::string>> seasons_;   // code, label in order
    std::vector<Item> items_;
};
