#pragma once
#include "../database/Database.h"
#include <optional>
#include <string>
#include <vector>

// ────────────────────────────────────────────────────────────────────────────
// PersonOverride — admin-supplied per-field overrides for the canonical
// `persons` row.
//
// Single table: person_field_overrides
//   (id, person_id, field_name, value, source_was, original_value, note,
//    set_by_user_id, set_at, updated_at)
//   UNIQUE (person_id, field_name)
//
// `value` is stored as TEXT and may be NULL (= "blank out" the field).  The
// resolver layer (Node `OverrideSource` today, future C++ `PersonResolver`
// tomorrow) always reads this table FIRST and short-circuits the upstream
// LeagueApps / GroupMe lookups when a row exists.
//
// Each operation runs as a single parameterised statement via the Database
// connection pool — atomic without an explicit transaction.
// ────────────────────────────────────────────────────────────────────────────
class PersonOverride {
public:
    struct Row {
        std::string field;                       // field_name
        std::optional<std::string> value;        // NULL ⇢ blank-out override
        std::optional<std::string> sourceWas;    // 'la' | 'gm' | 'footballhome' | nullopt
        std::optional<std::string> originalValue;
        std::optional<std::string> note;
        std::optional<int>         setByUserId;
        // ISO-8601 UTC string ("2026-06-25T19:08:39.000Z").  Empty if unset.
        std::string setAt;
    };

    PersonOverride();

    // List every override for one person, ordered by field_name.  Throws on DB error.
    std::vector<Row> listFor(int personId);

    // Upsert an override.  `rawBodyJson` is the request body, forwarded to
    // Postgres as JSONB so all of {string|number|bool|null} value types
    // resolve naturally via `->>'value'` (which always yields TEXT or NULL).
    // The body MUST contain `"field": "<name>"`; other keys are optional:
    //   { field, value?, sourceWas?, originalValue?, note? }
    // `setByUserId` is the authenticated admin (nullopt if none).
    //
    // Throws std::invalid_argument on missing `field`, std::runtime_error on DB error.
    Row upsert(int personId,
               const std::string& rawBodyJson,
               const std::optional<int>& setByUserId);

    // Clear one override.  Returns true iff a row was deleted.  Throws on DB error.
    bool clear(int personId, const std::string& field);

private:
    Database* db_;
};
