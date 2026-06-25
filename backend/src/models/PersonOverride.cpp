#include "PersonOverride.h"
#include <regex>
#include <stdexcept>
#include <string>

namespace {
    // Read a nullable text column out of a pqxx::row into std::optional<string>.
    std::optional<std::string> nullableText(const pqxx::row& row, const char* col) {
        const auto& f = row[col];
        if (f.is_null()) return std::nullopt;
        return f.as<std::string>();
    }

    std::optional<int> nullableInt(const pqxx::row& row, const char* col) {
        const auto& f = row[col];
        if (f.is_null()) return std::nullopt;
        return f.as<int>();
    }
}

PersonOverride::PersonOverride() : db_(Database::getInstance()) {
    if (!db_) {
        throw std::runtime_error("PersonOverride: Database instance is null");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/persons/:personId/overrides
// ────────────────────────────────────────────────────────────────────────────
std::vector<PersonOverride::Row> PersonOverride::listFor(int personId) {
    static const std::string kSql = R"SQL(
        SELECT field_name,
               value,
               source_was,
               original_value,
               note,
               set_by_user_id,
               to_char(set_at AT TIME ZONE 'UTC',
                       'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS set_at_iso
          FROM person_field_overrides
         WHERE person_id = $1::int
         ORDER BY field_name
    )SQL";

    pqxx::result rs = db_->query(kSql, {std::to_string(personId)});

    std::vector<Row> out;
    out.reserve(rs.size());
    for (const auto& r : rs) {
        Row row;
        row.field         = r["field_name"].as<std::string>();
        row.value         = nullableText(r, "value");
        row.sourceWas     = nullableText(r, "source_was");
        row.originalValue = nullableText(r, "original_value");
        row.note          = nullableText(r, "note");
        row.setByUserId   = nullableInt (r, "set_by_user_id");
        row.setAt         = r["set_at_iso"].as<std::string>();
        out.push_back(std::move(row));
    }
    return out;
}

// ────────────────────────────────────────────────────────────────────────────
// POST /api/persons/:personId/overrides
//
// We forward the whole request body to Postgres as JSONB and extract the
// fields via `->>`.  This delegates JSON parsing + type coercion (number,
// bool, null) to the database, avoiding the need for a C++ JSON library.
// `->>` returns TEXT for strings/numbers/bools and NULL when the JSON value
// is null OR the key is missing — both of which map to a NULL column value,
// matching the Node behaviour (`value == null ? null : String(value)`).
//
// `setByUserId` is the authenticated admin and is NOT taken from the body;
// it is passed as a separate parameter (passing it via the body would let
// a request forge attribution).  An empty string is treated as NULL.
// ────────────────────────────────────────────────────────────────────────────
PersonOverride::Row PersonOverride::upsert(int personId,
                                           const std::string& rawBodyJson,
                                           const std::optional<int>& setByUserId) {
    // Pre-flight: body must contain `"field": "<non-empty-string>"`.  Postgres
    // would also reject a NULL field_name (NOT NULL constraint), but we want
    // to return a clean 400 from the controller, not a 500 from PG.
    static const std::regex kFieldRe(
        R"rx("field"\s*:\s*"([^"\\]*(?:\\.[^"\\]*)*)")rx");
    std::smatch m;
    if (!std::regex_search(rawBodyJson, m, kFieldRe) || m[1].str().empty()) {
        throw std::invalid_argument("Body must include `field` (non-empty string).");
    }

    static const std::string kSql = R"SQL(
        INSERT INTO person_field_overrides
            (person_id, field_name, value, source_was, original_value, note,
             set_by_user_id, updated_at)
        SELECT $1::int,
               ($2::jsonb)->>'field',
               ($2::jsonb)->>'value',
               ($2::jsonb)->>'sourceWas',
               ($2::jsonb)->>'originalValue',
               ($2::jsonb)->>'note',
               NULLIF($3, '')::int,
               now()
        ON CONFLICT (person_id, field_name) DO UPDATE
           SET value          = EXCLUDED.value,
               source_was     = EXCLUDED.source_was,
               original_value = EXCLUDED.original_value,
               note           = EXCLUDED.note,
               set_by_user_id = EXCLUDED.set_by_user_id,
               updated_at     = now()
        RETURNING field_name,
                  value,
                  source_was,
                  original_value,
                  note,
                  set_by_user_id,
                  to_char(set_at AT TIME ZONE 'UTC',
                          'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS set_at_iso
    )SQL";

    const std::string setByStr = setByUserId.has_value()
        ? std::to_string(*setByUserId) : std::string{};

    pqxx::result rs = db_->query(kSql, {
        std::to_string(personId),
        rawBodyJson,
        setByStr,
    });
    if (rs.empty()) {
        throw std::runtime_error("PersonOverride::upsert: no row returned");
    }

    const auto& r = rs[0];
    Row out;
    out.field         = r["field_name"].as<std::string>();
    out.value         = nullableText(r, "value");
    out.sourceWas     = nullableText(r, "source_was");
    out.originalValue = nullableText(r, "original_value");
    out.note          = nullableText(r, "note");
    out.setByUserId   = nullableInt (r, "set_by_user_id");
    out.setAt         = r["set_at_iso"].as<std::string>();
    return out;
}

// ────────────────────────────────────────────────────────────────────────────
// DELETE /api/persons/:personId/overrides/:field
// ────────────────────────────────────────────────────────────────────────────
bool PersonOverride::clear(int personId, const std::string& field) {
    static const std::string kSql = R"SQL(
        DELETE FROM person_field_overrides
         WHERE person_id  = $1::int
           AND field_name = $2
        RETURNING id
    )SQL";

    pqxx::result rs = db_->query(kSql, {std::to_string(personId), field});
    return !rs.empty();
}
