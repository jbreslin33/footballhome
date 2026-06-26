#pragma once
#include <string>
#include "../third_party/json.hpp"

class Database;

// ────────────────────────────────────────────────────────────────────────────
// PersonLinker — find-or-create the `persons` row for an upstream record.
//
// LA path (linkLa):
//   1. Existing alias for (provider='leagueapps', external_user_id) → fast hit
//   2. Existing persons row for (LOWER(first_name), LOWER(last_name))
//      with DOB tie-break (skip with `dob-mismatch` reason if persons.dob and
//      LA dob both present and differ)
//   3. Otherwise INSERT a new persons row
//   4. UPSERT the LA alias so step 1 hits next time
//
// Skips (Result.skipReason populated) are non-fatal — the caller logs and
// keeps going.  This mirrors meta-leads-webhook person-data.js exactly.
// ────────────────────────────────────────────────────────────────────────────
class PersonLinker {
public:
    struct Result {
        int  personId       = 0;      // 0 if not linked (skip)
        bool created        = false;  // a new persons row was inserted
        bool aliasCreated   = false;
        std::string skipReason;       // e.g. "missing-la-userId", "dob-mismatch (...)"
        int  conflictPersonId = 0;    // only set for dob-mismatch
    };

    PersonLinker();

    // Find-or-create persons + alias from a LeagueApps registration record.
    // Always returns; never throws on schema-conformant input.
    Result linkLa(const nlohmann::json& rec);

private:
    Database* db_;

    // Lowercase + trim + collapse whitespace runs to a single space.
    static std::string normalizeName(const std::string&);

    // Pull "YYYY-MM-DD" out of `rec.birthDate` (LA returns either ISO string
    // or epoch millis).  Returns empty when no birthDate is present.
    static std::string birthDateIso(const nlohmann::json&);

    // Trim leading/trailing whitespace.
    static std::string trim(const std::string&);
};
