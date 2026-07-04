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

namespace {

// Extract a string-y value from the JSON record if present and non-empty.
std::string strOrEmpty(const json& rec, const char* key) {
    if (!rec.contains(key)) return {};
    const auto& v = rec[key];
    if (v.is_string())  return v.get<std::string>();
    if (v.is_number())  return std::to_string(v.get<long long>());
    return {};
}

// Trim ASCII whitespace on both ends.
std::string trimAscii(const std::string& s) {
    size_t a = 0, b = s.size();
    while (a < b && std::isspace(static_cast<unsigned char>(s[a])))   ++a;
    while (b > a && std::isspace(static_cast<unsigned char>(s[b - 1]))) --b;
    return s.substr(a, b - a);
}

} // namespace

void PersonLinker::upsertContact(int personId, const std::string& email, const std::string& phone) {
    const std::string cleanEmail = trimAscii(email);
    const std::string cleanPhone = trimAscii(phone);
    if (personId <= 0) return;

    if (!cleanEmail.empty()) {
        try {
            // person_emails has BOTH a global UNIQUE(email) and UNIQUE(person_id, email).
            // We DO NOT steal an email from another person — if the same email is
            // already attached elsewhere, log and skip (indicates a merge candidate).
            db_->query(
                "INSERT INTO person_emails (person_id, email) "
                "VALUES ($1::int, $2) "
                "ON CONFLICT (email) DO NOTHING",
                {std::to_string(personId), cleanEmail});
        } catch (const std::exception& e) {
            std::cerr << "[PersonLinker::upsertContact email] " << e.what()
                      << " personId=" << personId << " email=" << cleanEmail << std::endl;
        }
    }
    if (!cleanPhone.empty()) {
        try {
            // person_phones has BOTH a global UNIQUE(phone_number) and
            // UNIQUE(person_id, phone_number).  Use the broader constraint
            // so we never fail on a phone belonging to a different person
            // (indicates a merge candidate — do not steal).
            db_->query(
                "INSERT INTO person_phones (person_id, phone_number) "
                "VALUES ($1::int, $2) "
                "ON CONFLICT (phone_number) DO NOTHING",
                {std::to_string(personId), cleanPhone});
        } catch (const std::exception& e) {
            std::cerr << "[PersonLinker::upsertContact phone] " << e.what()
                      << " personId=" << personId << " phone=" << cleanPhone << std::endl;
        }
    }
}

void PersonLinker::ensureParentLink(int childPersonId, const json& rec) {
    if (childPersonId <= 0) return;
    const std::string userType = strOrEmpty(rec, "userType");
    // LA marks youth registrations userType='CHILD'.  Adults ('ADULT') have
    // no parent block — nothing to link.
    if (userType != "CHILD") return;

    const std::string parentUserId = strOrEmpty(rec, "parentUserId");
    const std::string parentFirst  = trimAscii(strOrEmpty(rec, "parentFirstName"));
    const std::string parentLast   = trimAscii(strOrEmpty(rec, "parentLastName"));
    const std::string parentEmail  = strOrEmpty(rec, "parentEmail");
    const std::string parentPhone  = strOrEmpty(rec, "parentPhone");

    if (parentUserId.empty() || (parentFirst.empty() && parentLast.empty())) {
        return;   // insufficient info to link
    }

    int parentPersonId = 0;
    try {
        // 1. Existing LA alias for the parent userId?
        auto hit = db_->query(
            "SELECT person_id FROM external_person_aliases "
            "WHERE provider = 'leagueapps' AND external_user_id = $1 LIMIT 1",
            {parentUserId});
        if (!hit.empty()) {
            parentPersonId = hit[0]["person_id"].as<int>();
        } else {
            // 2. Existing persons row by parent name?
            auto pHit = db_->query(
                "SELECT id FROM persons "
                "WHERE LOWER(BTRIM(first_name)) = $1 AND LOWER(BTRIM(last_name)) = $2 LIMIT 1",
                {normalizeName(parentFirst), normalizeName(parentLast)});
            if (!pHit.empty()) {
                parentPersonId = pHit[0]["id"].as<int>();
            } else {
                // 3. Insert parent persons row (no birth_date — LA export
                // gives the child's DOB, not the parent's).
                auto ins = db_->query(
                    "INSERT INTO persons (first_name, last_name) VALUES ($1, $2) "
                    "ON CONFLICT (first_name, last_name) DO UPDATE SET updated_at = NOW() "
                    "RETURNING id",
                    {parentFirst, parentLast});
                if (!ins.empty()) parentPersonId = ins[0]["id"].as<int>();
            }

            // 4. Upsert LA alias for the parent so step 1 hits next time.
            if (parentPersonId > 0) {
                db_->query(
                    "INSERT INTO external_person_aliases "
                    "  (provider, alias_first_name, alias_last_name, person_id, external_user_id) "
                    "VALUES ('leagueapps', $1, $2, $3::int, $4) "
                    "ON CONFLICT (provider, external_user_id) WHERE external_user_id IS NOT NULL "
                    "DO UPDATE SET person_id = EXCLUDED.person_id, updated_at = NOW()",
                    {parentFirst, parentLast, std::to_string(parentPersonId), parentUserId});
            }
        }
    } catch (const std::exception& e) {
        std::cerr << "[PersonLinker::ensureParentLink resolve] " << e.what()
                  << " parentUserId=" << parentUserId << std::endl;
        return;
    }

    if (parentPersonId <= 0) return;

    // 5. Contact backfill on the parent (this is the whole point).
    upsertContact(parentPersonId, parentEmail, parentPhone);

    // 6. Set the child's parent_person_id FK (only if not already set to
    // something else — never overwrite an existing linkage).
    try {
        db_->query(
            "UPDATE persons SET parent_person_id = $1::int, updated_at = NOW() "
            "WHERE id = $2::int AND parent_person_id IS DISTINCT FROM $1::int "
            "  AND (parent_person_id IS NULL OR parent_person_id = $1::int)",
            {std::to_string(parentPersonId), std::to_string(childPersonId)});
    } catch (const std::exception& e) {
        std::cerr << "[PersonLinker::ensureParentLink set-parent] " << e.what()
                  << " childPersonId=" << childPersonId
                  << " parentPersonId=" << parentPersonId << std::endl;
    }
}

PersonLinker::Result PersonLinker::linkLa(const json& rec, bool dryRun) {
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
            // Contact backfill even on the fast path — an existing alias
            // may have been created before we started ingesting email/phone,
            // and paused-program regs need their contact rows just as much
            // as active-program regs.  Skipped when dryRun.
            if (!dryRun) {
                const std::string email = strOrEmpty(rec, "email");
                const std::string phone = rec.contains("phoneNumber") && rec["phoneNumber"].is_string()
                                       ? rec["phoneNumber"].get<std::string>()
                                       : strOrEmpty(rec, "phone");
                upsertContact(out.personId, email, phone);
                ensureParentLink(out.personId, rec);
            }
            return out;
        }

        // 2. Name match with DOB tie-break.
        auto pHit = db_->query(
            "SELECT id, birth_date::text AS dob_iso FROM persons "
            "WHERE LOWER(BTRIM(first_name)) = $1 AND LOWER(BTRIM(last_name)) = $2 LIMIT 1",
            {normalizeName(firstName), normalizeName(lastName)});

        int personId = 0;
        bool needPersonInsert = false;
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
            needPersonInsert = true;
        }

        if (dryRun) {
            // In dry-run mode never write.  Report what we WOULD do so the
            // operator can audit before committing.
            if (needPersonInsert) {
                out.wouldCreatePerson = true;
            } else {
                out.wouldCreateAlias  = true;
                out.personId          = personId;
            }
            return out;
        }

        if (needPersonInsert) {
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

        // 5. Contact backfill on the (child or adult) person AND parent
        // linkage for youth.  Same logic as the fast-path branch above.
        {
            const std::string email = strOrEmpty(rec, "email");
            const std::string phone = rec.contains("phoneNumber") && rec["phoneNumber"].is_string()
                                   ? rec["phoneNumber"].get<std::string>()
                                   : strOrEmpty(rec, "phone");
            upsertContact(personId, email, phone);
            ensureParentLink(personId, rec);
        }
        return out;

    } catch (const std::exception& e) {
        std::cerr << "[PersonLinker::linkLa] " << e.what()
                  << " (laUserId=" << laUserId << ")" << std::endl;
        out.skipReason = std::string("db-error: ") + e.what();
        return out;
    }
}

void PersonLinker::recordMembership(int personId, long long programId) {
    if (personId <= 0 || programId <= 0) return;
    try {
        // 1. Person already has an OPEN row for THIS program? — nothing to do.
        auto hit = db_->query(
            "SELECT 1 FROM person_la_memberships "
            " WHERE person_id = $1::int AND la_program_id = $2::bigint AND ended_at IS NULL "
            " LIMIT 1",
            {std::to_string(personId), std::to_string(programId)});
        if (!hit.empty()) return;

        // 2. Close any OTHER open row for this person (active↔paused, or
        //    a category swap).  Preserves history — we UPDATE ended_at,
        //    we do not DELETE.
        db_->query(
            "UPDATE person_la_memberships SET ended_at = now(), updated_at = now() "
            " WHERE person_id = $1::int AND ended_at IS NULL AND la_program_id <> $2::bigint",
            {std::to_string(personId), std::to_string(programId)});

        // 3. Insert the new open row.
        db_->query(
            "INSERT INTO person_la_memberships (person_id, la_program_id) "
            "VALUES ($1::int, $2::bigint)",
            {std::to_string(personId), std::to_string(programId)});
    } catch (const std::exception& e) {
        std::cerr << "[PersonLinker::recordMembership] " << e.what()
                  << " (personId=" << personId << ", programId=" << programId << ")"
                  << std::endl;
    }
}
