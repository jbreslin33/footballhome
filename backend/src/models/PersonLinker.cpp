#include "PersonLinker.h"
#include "../database/Database.h"
#include <algorithm>
#include <cctype>
#include <chrono>
#include <ctime>
#include <iomanip>
#include <iostream>
#include <sstream>

using nlohmann::json;

PersonLinker::PersonLinker() : db_(Database::getInstance()) {}

std::string PersonLinker::trim(const std::string& s) {
    auto begin = std::find_if_not(s.begin(), s.end(),
        [](unsigned char c) { return std::isspace(c); });
    auto end   = std::find_if_not(s.rbegin(), s.rend(),
        [](unsigned char c) { return std::isspace(c); }).base();
    return (begin >= end) ? std::string{} : std::string(begin, end);
}

std::string PersonLinker::normalizeName(const std::string& raw) {
    const std::string t = trim(raw);
    std::string out;
    out.reserve(t.size());
    bool prevSpace = false;
    for (unsigned char c : t) {
        if (std::isspace(c)) {
            if (!prevSpace) {
                out.push_back(' ');
                prevSpace = true;
            }
        } else {
            out.push_back(static_cast<char>(std::tolower(c)));
            prevSpace = false;
        }
    }
    return out;
}

std::string PersonLinker::birthDateIso(const json& rec) {
    if (!rec.contains("birthDate")) return {};
    const auto& v = rec["birthDate"];
    if (v.is_string()) {
        const std::string s = v.get<std::string>();
        return s.size() >= 10 ? s.substr(0, 10) : std::string{};
    }
    if (v.is_number()) {
        // LA passes epoch milliseconds.  Convert to UTC YYYY-MM-DD.
        const long long ms = v.get<long long>();
        const std::time_t t = static_cast<std::time_t>(ms / 1000);
        std::tm tm{};
        gmtime_r(&t, &tm);
        std::ostringstream out;
        out << std::put_time(&tm, "%Y-%m-%d");
        return out.str();
    }
    return {};
}

PersonLinker::Result PersonLinker::linkLa(const json& rec) {
    Result out;

    // Extract the three identifying fields.
    std::string laUserId;
    if (rec.contains("userId")) {
        const auto& v = rec["userId"];
        if      (v.is_string()) laUserId = v.get<std::string>();
        else if (v.is_number()) laUserId = std::to_string(v.get<long long>());
    }
    const std::string firstName = rec.contains("firstName") && rec["firstName"].is_string()
                                ? trim(rec["firstName"].get<std::string>()) : std::string{};
    const std::string lastName  = rec.contains("lastName")  && rec["lastName"].is_string()
                                ? trim(rec["lastName"].get<std::string>())  : std::string{};
    const std::string dob       = birthDateIso(rec);

    if (laUserId.empty()) {
        out.skipReason = "missing-la-userId";
        return out;
    }
    if (firstName.empty() && lastName.empty()) {
        out.skipReason = "missing-name";
        return out;
    }

    // 1. Alias fast-path.
    try {
        auto hit = db_->query(
            "SELECT person_id FROM external_person_aliases "
            "WHERE provider = 'leagueapps' AND external_user_id = $1 LIMIT 1",
            {laUserId});
        if (!hit.empty()) {
            out.personId = hit[0]["person_id"].as<int>();
            return out;
        }

        // 2. Name match with DOB tie-break.
        auto pHit = db_->query(
            "SELECT id, birth_date::text AS dob_iso FROM persons "
            "WHERE LOWER(BTRIM(first_name)) = $1 AND LOWER(BTRIM(last_name)) = $2 LIMIT 1",
            {normalizeName(firstName), normalizeName(lastName)});

        int personId = 0;
        if (!pHit.empty()) {
            const auto& row = pHit[0];
            const std::string rowIso = row["dob_iso"].is_null() ? std::string{} : row["dob_iso"].as<std::string>();
            if (!dob.empty() && !rowIso.empty() && rowIso != dob) {
                out.skipReason = "dob-mismatch (persons.birth_date=" + rowIso
                               + ", la.birthDate=" + dob + ")";
                out.conflictPersonId = row["id"].as<int>();
                return out;
            }
            personId = row["id"].as<int>();
        } else {
            // 3. Insert new persons row.  birth_date is nullable in this schema.
            auto ins = db_->query(
                "INSERT INTO persons (first_name, last_name, birth_date) "
                "VALUES ($1, $2, NULLIF($3, '')::date) RETURNING id",
                {firstName, lastName, dob});
            personId = ins[0]["id"].as<int>();
            out.created = true;
        }

        // 4. Upsert the LA alias (so step 1 hits next time).
        db_->query(
            "INSERT INTO external_person_aliases "
            "  (provider, alias_first_name, alias_last_name, person_id, external_user_id) "
            "VALUES ('leagueapps', $1, $2, $3::int, $4) "
            "ON CONFLICT (provider, external_user_id) WHERE external_user_id IS NOT NULL "
            "DO UPDATE SET person_id = EXCLUDED.person_id, updated_at = NOW()",
            {firstName, lastName, std::to_string(personId), laUserId});

        out.personId     = personId;
        out.aliasCreated = true;
        return out;

    } catch (const std::exception& e) {
        std::cerr << "[PersonLinker::linkLa] " << e.what()
                  << " (laUserId=" << laUserId << ")" << std::endl;
        out.skipReason = std::string("db-error: ") + e.what();
        return out;
    }
}
