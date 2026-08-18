#pragma once
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>
#include "../third_party/json.hpp"

class MensTeamColumns;
class MensTeamAssignments;

// ────────────────────────────────────────────────────────────────────────────
// WomensRoster — model behind GET /api/womens-roster.
//
// Live LA fetch of the Women's Club program (LEAGUEAPPS_WOMENS_PROGRAM_ID,
// default 5039340) crossed with `teams` rows where gender_category='womens'
// (MensTeamColumns/MensTeamAssignments domain "womens" — the same
// board-column machinery Mens/Boys/Girls already share, migration 250)
// to produce the same column/bucket payload shape those boards use.
//
// Deliberately NOT a port of MensRoster's billing/delinquency engine —
// the Women's Club LA program is NA_FREE (no dues to chase), so there's
// no PersonBilling, no nextBillDate/PAY-prorate math, no cross-program
// payment aggregation, no FH-only-squad synthesis, no pickup-tier
// auto-assign, no under16 flag. See BoysRoster (also billing-free) for
// the closer structural sibling, though this model still uses a single
// LA program like MensRoster rather than BoysRoster's boys+girls merge.
//
// Failure modes via Result:
//   - noColumns = true  → controller returns 409.
//   - error not empty   → controller returns 502 (LA fetch or DB blip).
// ────────────────────────────────────────────────────────────────────────────
class WomensRoster {
public:
    struct Result {
        nlohmann::json body;
        bool           noColumns = false;
        std::string    error;
    };

    WomensRoster();
    ~WomensRoster();

    // Run with pre-synced LA registration records. The controller (via
    // laGet(static)) is responsible for calling LaProgramSync::run on
    // `womensProgramId_` BEFORE dispatching, and passing the resulting
    // recs vector in. This model reads exclusively from Postgres (which
    // the pre-sync just refreshed) — no direct LeagueApps I/O.
    //
    // `refreshLa` is accepted for API parity with Mens/Boys but unused
    // here (no payment sync to gate — there's nothing to pay).
    // `personIdByUserId` (LaProgramSync::Result::personIdByUserId) is a
    // fallback identity map used when a player's live LA userId doesn't
    // match persons.la_user_id — see LaProgramSync.h.
    Result run(bool includeAll,
               bool refreshLa,
               const std::vector<nlohmann::json>& recs,
               const std::unordered_map<std::string, long long>& personIdByUserId = {},
               bool includeInactive = false);

    // Public accessor so controllers registering laGet(static) know
    // which LA program to sync.
    int womensProgramId() const { return womensProgramId_; }

private:
    std::unique_ptr<MensTeamColumns>     columns_;      // domain="womens"
    std::unique_ptr<MensTeamAssignments> assignments_;  // domain="womens"
    int womensProgramId_;

    static int envInt(const char* name, int fallback);
    static nlohmann::json shapeWomensPlayer(const nlohmann::json& rec);
};
