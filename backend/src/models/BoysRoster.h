#pragma once
#include <memory>
#include <string>
#include <vector>
#include "../third_party/json.hpp"

class MensTeamColumns;
class MensTeamAssignments;
class PersonPayments;

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

    // Run with pre-synced LA registration records.  The controller
    // (via laGet(static)) is responsible for calling LaProgramSync::run
    // on `boysProgramId_` and `girlsProgramId_` BEFORE dispatching, and
    // passing the resulting recs vectors in.  This model no longer
    // touches LeagueApps directly — reads exclusively from Postgres
    // (which the pre-sync just refreshed).
    //
    // `refreshLa` gates payment `syncFromLa()` (kept as a knob so
    // background jobs can skip it) — LA membership sync itself is
    // ALWAYS done by the caller regardless.
    Result run(bool includeAll,
               bool refreshLa,
               const std::vector<nlohmann::json>& boysRecs,
               const std::vector<nlohmann::json>& girlsRecs);

    // Public accessors so controllers registering laGet(static) know
    // exactly which LA programs to sync — keeps the routing table
    // and the model's declared dependencies in one place.
    int boysProgramId() const { return boysProgramId_; }
    int girlsProgramId() const { return girlsProgramId_; }

private:
    std::unique_ptr<MensTeamColumns>     columns_;      // domain="boys"
    std::unique_ptr<MensTeamAssignments> assignments_;  // domain="boys"
    std::unique_ptr<PersonPayments>      payments_;
    int boysProgramId_;
    int girlsProgramId_;

    static int envInt(const char* name, int fallback);
    static int defaultSeasonEndYear();

    // Shape a single LA rec.  `club` is "boys" or "girls" — determines
    // the gender fallback when LA didn't supply one.
    static nlohmann::json shapePlayer(const nlohmann::json& rec,
                                      const std::string& club,
                                      int seasonEndYear);
};
