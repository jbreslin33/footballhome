#pragma once
#include <memory>
#include <string>
#include "../third_party/json.hpp"

class Database;
class LaProgramSync;

// ────────────────────────────────────────────────────────────────────────────
// LaPool — model behind GET /api/clubs/:clubId/la-pool.
//
// Responsibilities:
//   1. Query teams in the club for the gender bucket (skipping pickup /
//      training / pool pseudo-teams).
//   2. Drive LaProgramSync for the matching LA program (mens or womens)
//      so the local persons+aliases tables warm up before we project.
//   3. Resolve every active LA registration → local personId via
//      external_person_aliases.
//   4. Pull each matched person's current rosters within the club.
//   5. Shape one row per active LA registrant with name, dob, raw LA
//      fields and the list of team_ids they're already rostered on.
//   6. Idempotent best-effort backfill of persons.birth_date when local
//      is null + LA has a value.
//
// Mirrors meta-leads-webhook/index.js `app.get('/api/clubs/:clubId/la-
// pool')` one-to-one so the wire payload is identical pre/post cutover.
// ────────────────────────────────────────────────────────────────────────────
class LaPool {
public:
    struct Result {
        nlohmann::json body;  // { teams, persons, sourceProgram, fetchedAt }
    };

    // gender ∈ {"mens", "womens"}.  Anything else is normalised to "mens".
    enum class Gender { Mens, Womens };

    LaPool();
    ~LaPool();

    Result run(int clubId, Gender gender);

    // Helper used by the controller to normalise the `?gender=` query.
    static Gender parseGender(const std::string& raw);

private:
    Database*                       db_;
    std::unique_ptr<LaProgramSync>  sync_;
    int                             mensProgramId_;
    int                             womensProgramId_;

    static int envInt(const char* name, int fallback);
};
