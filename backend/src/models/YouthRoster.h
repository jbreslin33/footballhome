#pragma once
#include <memory>
#include <string>
#include <vector>
#include "../third_party/json.hpp"

class PersonBilling;
class PersonPayments;
class YouthAgeGroups;

// ────────────────────────────────────────────────────────────────────────────
// YouthRoster — model behind GET /api/youth-roster.
//
// Live LA fetch (boys + girls programs), bucketed via youth_age_groups for
// the requested season, billing projected onto each row.  Mirrors
// meta-leads-webhook/index.js `app.get('/api/youth-roster')` one-to-one so
// the wire payload is identical pre/post cutover.
//
// Behaviour:
//   1. loadFor(seasonEndYear) — fail-fast 409 when no buckets exist.
//   2. Fetch LA boys + girls program registrations (sequential — two HTTP
//      calls; Node uses Promise.all but the savings are <100ms and the C++
//      HttpClient is already singleton-guarded).
//   3. Filter to active (SPOT_RESERVED | SPOT_PENDING) unless includeAll.
//   4. Shape each rec with shapeYouthPlayer, attach billing + school-year
//      age group.
//   5. Bucket via YouthAgeGroups::matchBucket; sort each bucket by
//      (birthDate asc, lastName asc) and the unbucketed list.
//
// Failure modes surfaced via Result:
//   * noBuckets = true  → controller returns 409.
//   * error not empty   → controller returns 502 (LA fetch failure or
//                         any other std::exception bubbled up).
// ────────────────────────────────────────────────────────────────────────────
class YouthRoster {
public:
    struct Result {
        nlohmann::json body;
        bool           noBuckets = false;
        std::string    error;       // empty when ok; populated → 502
    };

    YouthRoster();
    ~YouthRoster();

    // Run with pre-synced LA registration records.  The controller
    // (via laGet(static)) is responsible for calling LaProgramSync::run
    // on `boysProgramId_` and `girlsProgramId_` BEFORE dispatching to
    // this method, and passing the resulting recs vectors in.  This
    // model no longer touches LeagueApps directly — reads exclusively
    // from Postgres (which the pre-sync has just refreshed) and shapes
    // the response from the passed-in recs.
    //
    // See .github/copilot-instructions.md "Membership Data Flow" and
    // Controller::laGet() docs.
    Result run(int seasonEndYear,
               bool includeAll,
               const std::vector<nlohmann::json>& boysRecs,
               const std::vector<nlohmann::json>& girlsRecs);

    // Public accessors so controllers registering laGet(static) know
    // exactly which LA programs to sync — keeps the routing table
    // and the model's declared dependencies in one place.
    int boysProgramId() const { return boysProgramId_; }
    int girlsProgramId() const { return girlsProgramId_; }

    static int defaultSeasonEndYear();

private:
    std::unique_ptr<YouthAgeGroups> ageGroups_;
    std::unique_ptr<PersonBilling>  billing_;
    std::unique_ptr<PersonPayments> payments_;
    int boysProgramId_;
    int girlsProgramId_;

    // shapeYouthPlayer(rec, club) → row JSON (matches the Node helper).
    // `club` is "boys" or "girls"; the wire field uses "Boys Club" / "Girls Club".
    static nlohmann::json shapeYouthPlayer(const nlohmann::json& rec,
                                           const std::string& club);

    static int envInt(const char* name, int fallback);
};
