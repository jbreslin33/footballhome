#pragma once
#include <memory>
#include <mutex>
#include <string>
#include <vector>
#include "../third_party/json.hpp"

class MensTeamColumns;
class MensTeamAssignments;

// ────────────────────────────────────────────────────────────────────────────
// BoysRoster — model behind GET /api/boys-roster.
//
// Live LA fetch of BOTH the Boys Club and Girls Club programs, crossed
// with `roster_columns` and `roster_assignments` scoped to
// `domain='boys'` to produce the same column/bucket payload shape the
// mens dashboard uses.  Coach places kids into columns manually via
// POST /api/boys-roster/assign — no auto-bucketing by age.  Cards
// surface:
//   - gender  ("Male" / "Female") — girls can be added to boys columns
//     per user directive; the badge tells admin who's who.
//   - ageGroup ("U8".."U19") — real school-year age computed from the
//     birth date (Aug 1 cutover, matching YouthRoster).
//
// No billing / delinquency / payments logic (youth dues live in a
// different flow).  No practice/pickup pool-team backfill.
//
// Failure modes via Result:
//   - noColumns = true  → controller returns 409.
//   - error not empty   → controller returns 502 (LA fetch or DB blip).
// ────────────────────────────────────────────────────────────────────────────
class BoysRoster {
public:
    struct Result {
        nlohmann::json body;
        bool           noColumns = false;
        std::string    error;
    };

    BoysRoster();
    ~BoysRoster();

    // refreshLa=true forces a live LeagueApps fetch; otherwise the cached
    // registrant snapshot is reused (initial load fetches unconditionally).
    Result run(bool includeAll, bool refreshLa);

private:
    std::unique_ptr<MensTeamColumns>     columns_;      // domain="boys"
    std::unique_ptr<MensTeamAssignments> assignments_;  // domain="boys"
    int boysProgramId_;
    int girlsProgramId_;

    // In-memory registrant snapshots (boys + girls program), guarded by
    // cacheMutex_.  See MensRoster::run for the rationale — a transient
    // LA outage shouldn't wedge the dashboard if we already have data.
    std::mutex                  cacheMutex_;
    std::vector<nlohmann::json> cachedBoys_;
    std::vector<nlohmann::json> cachedGirls_;
    bool                        cacheValid_ = false;

    static int envInt(const char* name, int fallback);
    static int defaultSeasonEndYear();

    // Shape a single LA rec.  `club` is "boys" or "girls" — determines
    // the gender fallback when LA didn't supply one.
    static nlohmann::json shapePlayer(const nlohmann::json& rec,
                                      const std::string& club,
                                      int seasonEndYear);
};
