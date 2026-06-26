#pragma once
#include <set>
#include <string>
#include <unordered_map>
#include <vector>
#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// LaProgramSync — wraps the "fetch every LeagueApps registration for a
// program AND link active ones into the persons table" loop that lives
// in meta-leads-webhook/index.js as `syncLaProgramToDb(programId)`.
//
// Every endpoint that drives the lineups / pool screens must call this
// before its bucket SQL so freshly-paid LA registrants self-heal into
// the local DB (persons + external_person_aliases) and stop showing as
// phantom gmOnly entries.
//
// Singleton-style stateless service: instantiate once per request, call
// `run(programId)`, consume the Result.  Per-record errors are swallowed
// (logged) so one bad LA row never fails the whole request.
//
// Used by Phase 6 (la-pool), Phase 7 (youth-roster), Phase 8 (mens-
// roster) and any future reconciliation surface.
// ────────────────────────────────────────────────────────────────────────────
class LaProgramSync {
public:
    struct Result {
        // Stringified LA userIds whose registrationStatus is
        // SPOT_RESERVED or SPOT_PENDING.
        std::set<std::string>                       activeUserIds;
        // Stringified LA userId → uppercased status (covers every record,
        // active or not).
        std::unordered_map<std::string, std::string> statusByUser;
        // Raw LA records (every page, deduped) — JSON objects exactly as
        // returned by LeagueAppsService::fetchProgramRegistrations.
        std::vector<nlohmann::json>                  recs;
    };

    LaProgramSync() = default;

    // Fetch + link in one pass.  Throws on transport / token failure, but
    // never on a single bad record (those are logged + skipped).
    Result run(int programId);
};
