#include "YouthRoster.h"

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cstdlib>
#include <ctime>
#include <iostream>
#include <sstream>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "PersonBilling.h"
#include "PersonPayments.h"
#include "YouthAgeGroups.h"
#include "../database/Database.h"

using nlohmann::json;

namespace {

// Trim ASCII whitespace at both ends.
std::string trim(const std::string& s) {
    size_t a = 0;
    while (a < s.size() && std::isspace(static_cast<unsigned char>(s[a]))) ++a;
    size_t b = s.size();
    while (b > a && std::isspace(static_cast<unsigned char>(s[b - 1]))) --b;
    return s.substr(a, b - a);
}

// Optional string from a JSON object, or "" if missing/null/not-string.
std::string optStr(const json& j, const char* key) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null() || !it->is_string()) return {};
    return it->get<std::string>();
}

// Pass-through optional value (returns json(nullptr) if missing/null).
json optAny(const json& j, const char* key) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null()) return nullptr;
    return *it;
}

// LA `birthDate` → "YYYY-MM-DD" (UTC).  Accepts number (epoch ms) or
// 10+-char ISO string.  Empty when not parseable.
std::string birthDateIso(const json& rec) {
    auto it = rec.find("birthDate");
    if (it == rec.end() || it->is_null()) return {};
    if (it->is_number()) {
        const long long ms = static_cast<long long>(it->get<double>());
        const std::time_t secs = static_cast<std::time_t>(ms / 1000);
        std::tm tm_utc{};
        if (gmtime_r(&secs, &tm_utc) == nullptr) return {};
        char buf[16];
        std::snprintf(buf, sizeof(buf), "%04d-%02d-%02d",
                      tm_utc.tm_year + 1900, tm_utc.tm_mon + 1, tm_utc.tm_mday);
        return std::string(buf);
    }
    if (it->is_string()) {
        const std::string s = it->get<std::string>();
        if (s.size() >= 10) return s.substr(0, 10);
    }
    return {};
}

// userId may arrive as int or string in LA payloads.  We always surface it
// as a JSON value (preserving the upstream type) so the wire stays identical
// to the Node response.
json optUserId(const json& rec) {
    auto it = rec.find("userId");
    if (it == rec.end() || it->is_null()) return nullptr;
    return *it;
}

// Stringified userId for billing-map lookup.
std::string userIdString(const json& v) {
    if (v.is_null()) return {};
    if (v.is_string()) return v.get<std::string>();
    if (v.is_number_integer())  return std::to_string(v.get<long long>());
    if (v.is_number_unsigned()) return std::to_string(v.get<unsigned long long>());
    if (v.is_number_float())    return std::to_string(static_cast<long long>(v.get<double>()));
    return {};
}

// `new Date().toISOString()` equivalent: "YYYY-MM-DDTHH:MM:SS.mmmZ".
std::string nowIsoMs() {
    using namespace std::chrono;
    const auto now = system_clock::now();
    const auto t   = system_clock::to_time_t(now);
    const auto ms  = duration_cast<milliseconds>(now.time_since_epoch()) % 1000;
    std::tm tm_utc{};
    gmtime_r(&t, &tm_utc);
    char buf[40];
    std::snprintf(buf, sizeof(buf), "%04d-%02d-%02dT%02d:%02d:%02d.%03lldZ",
                  tm_utc.tm_year + 1900, tm_utc.tm_mon + 1, tm_utc.tm_mday,
                  tm_utc.tm_hour, tm_utc.tm_min, tm_utc.tm_sec,
                  static_cast<long long>(ms.count()));
    return std::string(buf);
}

// LA registrationStatus → uppercase.
std::string upperAscii(const std::string& s) {
    std::string out;
    out.reserve(s.size());
    for (char c : s) out.push_back(static_cast<char>(std::toupper(static_cast<unsigned char>(c))));
    return out;
}

bool isActive(const json& rec, bool includeAll) {
    if (includeAll) return true;
    const std::string s = upperAscii(optStr(rec, "registrationStatus"));
    return s == "SPOT_RESERVED" || s == "SPOT_PENDING";
}

} // namespace

YouthRoster::YouthRoster()
    : ageGroups_(std::make_unique<YouthAgeGroups>()),
      billing_  (std::make_unique<PersonBilling>()),
      payments_ (std::make_unique<PersonPayments>()),
      boysProgramId_ (envInt("LEAGUEAPPS_BOYS_CLUB_PROGRAM_ID",  5039252)),
      girlsProgramId_(envInt("LEAGUEAPPS_GIRLS_CLUB_PROGRAM_ID", 5039357)) {}

YouthRoster::~YouthRoster() = default;

int YouthRoster::defaultSeasonEndYear() {
    return YouthAgeGroups::defaultSeasonEndYear();
}

int YouthRoster::envInt(const char* name, int fallback) {
    const char* raw = std::getenv(name);
    if (!raw || !*raw) return fallback;
    try { return std::stoi(raw); }
    catch (const std::exception&) { return fallback; }
}

json YouthRoster::shapeYouthPlayer(const json& rec, const std::string& club) {
    const std::string first = trim(optStr(rec, "firstName"));
    const std::string last  = trim(optStr(rec, "lastName"));
    const std::string bd    = birthDateIso(rec);

    json out;
    // registrationId falls back to top-level `id`.
    json regId = nullptr;
    if (auto it = rec.find("registrationId"); it != rec.end() && !it->is_null()) regId = *it;
    else if (auto it = rec.find("id");        it != rec.end() && !it->is_null()) regId = *it;
    out["registrationId"]   = regId;

    const json uid = optUserId(rec);
    out["userId"]           = uid;
    out["leagueAppsUserId"] = uid;

    out["firstName"]        = first;
    out["lastName"]         = last;
    out["fullName"]         = trim(first + " " + last);
    out["birthDate"]        = bd.empty() ? json(nullptr) : json(bd);

    if (!bd.empty()) {
        try { out["birthYear"] = std::stoi(bd.substr(0, 4)); }
        catch (const std::exception&) { out["birthYear"] = nullptr; }
    } else {
        out["birthYear"] = nullptr;
    }

    out["club"] = (club == "boys") ? "Boys Club" : "Girls Club";

    // gender falls back to club default when LA didn't supply one.
    const std::string g = optStr(rec, "gender");
    if (!g.empty()) out["gender"] = g;
    else            out["gender"] = (club == "boys") ? "Male" : "Female";

    auto strOrNull = [&](const char* k) -> json {
        const std::string v = optStr(rec, k);
        return v.empty() ? json(nullptr) : json(v);
    };

    out["playerEmail"]        = strOrNull("email");
    out["parentFirstName"]    = strOrNull("parentFirstName");
    out["parentLastName"]     = strOrNull("parentLastName");

    const std::string pFirst = optStr(rec, "parentFirstName");
    const std::string pLast  = optStr(rec, "parentLastName");
    std::string parentName;
    if (!pFirst.empty()) parentName = pFirst;
    if (!pLast.empty()) {
        if (!parentName.empty()) parentName += ' ';
        parentName += pLast;
    }
    out["parentName"]         = parentName.empty() ? json(nullptr) : json(parentName);

    out["parentEmail"]        = strOrNull("parentEmail");
    out["parentPhone"]        = strOrNull("parentPhone");
    out["paymentStatus"]      = strOrNull("paymentStatus");
    out["outstandingBalance"] = optAny(rec, "outstandingBalance");
    out["registrationStatus"] = strOrNull("registrationStatus");
    out["programName"]        = strOrNull("programName");

    return out;
}

YouthRoster::Result YouthRoster::run(int seasonEndYear,
                                     bool includeAll,
                                     const std::vector<json>& boysRecs,
                                     const std::vector<json>& girlsRecs) {
    Result out;

    auto bucketDefs = ageGroups_->loadFor(seasonEndYear);
    if (bucketDefs.empty()) {
        out.noBuckets = true;
        std::ostringstream msg;
        msg << "No youth_age_groups configured for season_end_year="
            << seasonEndYear
            << ".  Seed the table to enable bucketing.";
        out.error = msg.str();
        return out;
    }

    // ── LA snapshots supplied by caller ──────────────────────────────
    //
    // STRICT RULE (see .github/copilot-instructions.md "Membership Data
    // Flow" and /memories/repo/membership-source-of-truth.md): every
    // request MUST have LaProgramSync::run(programId) called for every
    // LA program feeding the response.  That responsibility now lives
    // in the controller via laGet(static, {boysProgramId, girlsProgramId}),
    // which fetches LA live, upserts persons/aliases/memberships, closes
    // stale rows, and hands us the resulting recs.  This model reads
    // the response payload from Postgres (which the pre-sync just
    // refreshed) — no direct LA I/O here.

    // Sync new LA transactions into person_payments (see MensRoster.cpp
    // for rationale).  Non-fatal on failure.
    try {
        payments_->syncFromLa();
    } catch (const std::exception& e) {
        std::cerr << "[YouthRoster] payment sync failed: " << e.what() << std::endl;
    }
    auto boysLastPaid  = payments_->loadLastPositiveByProgramByRegistration(boysProgramId_);
    auto girlsLastPaid = payments_->loadLastPositiveByProgramByRegistration(girlsProgramId_);
    auto boysRecent    = payments_->loadRecentByProgramByRegistration(boysProgramId_, 3);
    auto girlsRecent   = payments_->loadRecentByProgramByRegistration(girlsProgramId_, 3);

    // ── Pickup exclusion REMOVED (2026-07-14) ────────────────────────
    //
    // The old "if user is in pickup-variant, drop them from roster"
    // filter is BANNED (see copilot-instructions.md Membership Data
    // Flow section).  Members vs Pickup are TWO INDEPENDENT LA sub-
    // programs — a person can be in one, the other, both, or neither.
    // Whether they appear on this Members roster is decided purely by
    // whether LA returns them as an active member of the Members
    // sub-program (5039252 boys / 5039357 girls) — which is exactly
    // what `boysRecs` / `girlsRecs` (freshly synced above) reflect.

    std::vector<json> shapedAll;
    shapedAll.reserve(boysRecs.size() + girlsRecs.size());
    for (const auto& r : boysRecs)
        if (isActive(r, includeAll))
            shapedAll.push_back(shapeYouthPlayer(r, "boys"));
    for (const auto& r : girlsRecs)
        if (isActive(r, includeAll))
            shapedAll.push_back(shapeYouthPlayer(r, "girls"));

    auto billingMap = billing_->loadAll();

    // ── LA registration timestamp load (2026-07-06) ──────────────────
    // Emitted as `laRegisteredAt` on every row so the frontend can show
    // "Reg: MMM D, YYYY" on the roster card, and gate the projected-
    // prorate cell on the 2026-07-06 cutoff.  Keyed by la_registration_id.
    std::unordered_map<long long, std::string> laRegisteredAtByRegId;
    // See MensRoster / BoysRoster for rationale — LA user_id fallback
    // so cards with no matching registration in the current club still
    // surface a reg date from a companion program (pickup, paused,
    // sibling club).  Added 2026-07-09.
    std::unordered_map<std::string, std::string> laRegisteredAtByUid;
    {
        try {
            auto* db = Database::getInstance();
            pqxx::result rows = db->query(
                "SELECT la_registration_id, "
                "       TO_CHAR(la_registered_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS reg_iso "
                "  FROM person_la_memberships "
                " WHERE la_registration_id IS NOT NULL "
                "   AND la_registered_at IS NOT NULL "
            );
            for (const auto& r : rows) {
                if (r["la_registration_id"].is_null() || r["reg_iso"].is_null()) continue;
                laRegisteredAtByRegId[r["la_registration_id"].as<long long>()] = r["reg_iso"].c_str();
            }
        } catch (const std::exception& e) {
            std::cerr << "[YouthRoster] la_registered_at load failed: " << e.what() << std::endl;
        }
    }
    try {
        auto* db = Database::getInstance();
        pqxx::result rows = db->query(
            "SELECT epa.external_user_id AS la_user_id, "
            "       TO_CHAR(MIN(plm.la_registered_at) AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS reg_iso "
            "  FROM person_la_memberships plm "
            "  JOIN external_person_aliases epa "
            "    ON epa.person_id = plm.person_id "
            "   AND epa.provider  = 'leagueapps' "
            " WHERE plm.la_registered_at IS NOT NULL "
            "   AND epa.external_user_id IS NOT NULL "
            " GROUP BY epa.external_user_id "
        );
        for (const auto& r : rows) {
            if (r["la_user_id"].is_null() || r["reg_iso"].is_null()) continue;
            laRegisteredAtByUid[r["la_user_id"].c_str()] = r["reg_iso"].c_str();
        }
    } catch (const std::exception& e) {
        std::cerr << "[YouthRoster] la_registered_at (by uid) load failed: " << e.what() << std::endl;
    }
    auto laRegIsoFor = [&](const json& regJson, const std::string& uidFallback = std::string{}) -> json {
        long long id = 0;
        if      (regJson.is_number_integer())  id = regJson.get<long long>();
        else if (regJson.is_number_unsigned()) id = static_cast<long long>(regJson.get<unsigned long long>());
        else if (regJson.is_number_float())    id = static_cast<long long>(regJson.get<double>());
        else if (regJson.is_string()) {
            try { id = std::stoll(regJson.get<std::string>()); }
            catch (...) { id = 0; }
        }
        if (id > 0) {
            auto it = laRegisteredAtByRegId.find(id);
            if (it != laRegisteredAtByRegId.end()) return json(it->second);
        }
        if (!uidFallback.empty()) {
            auto it = laRegisteredAtByUid.find(uidFallback);
            if (it != laRegisteredAtByUid.end()) return json(it->second);
        }
        return json(nullptr);
    };

    for (auto& p : shapedAll) {
        const std::string uid = userIdString(p.at("leagueAppsUserId"));
        const auto bill = PersonBilling::resolve(billingMap, uid);
        p["nextBillDate"]   = bill.nextBillDate.empty() ? json(nullptr) : json(bill.nextBillDate);
        p["nextBillAmount"] = bill.nextBillAmount;
        p["isDefault"]      = bill.isDefault;
        p["laRegisteredAt"] = laRegIsoFor(p.at("registrationId"), uid);

        // lastPaid pill data.  Join by registrationId (parent pays for
        // child on youth, so la_user_id on transactions ≠ player uid).
        const std::string club = p.at("club").is_string() ? p.at("club").get<std::string>() : std::string{};
        const auto& lpMap  = (club == "Boys Club") ? boysLastPaid : girlsLastPaid;
        const auto& recMap = (club == "Boys Club") ? boysRecent   : girlsRecent;
        p["lastPaidAmount"] = nullptr;
        p["lastPaidAt"]     = nullptr;
        p["lastPaidType"]   = nullptr;
        p["lastPayments"]   = json::array();
        std::string regKey;
        if (p.at("registrationId").is_number_integer())       regKey = std::to_string(p.at("registrationId").get<long long>());
        else if (p.at("registrationId").is_number_unsigned())  regKey = std::to_string(p.at("registrationId").get<unsigned long long>());
        else if (p.at("registrationId").is_string())           regKey = p.at("registrationId").get<std::string>();
        if (!regKey.empty()) {
            if (auto pit = lpMap.find(regKey); pit != lpMap.end()) {
                p["lastPaidAmount"] = pit->second.amount;
                p["lastPaidAt"]     = pit->second.paidAt.empty() ? json(nullptr) : json(pit->second.paidAt);
                p["lastPaidType"]   = pit->second.txnType.empty() ? json(nullptr) : json(pit->second.txnType);
            }
            if (auto rit = recMap.find(regKey); rit != recMap.end()) {
                for (const auto& lp : rit->second) {
                    json row = json::object();
                    row["amount"]  = lp.amount;
                    row["paidAt"]  = lp.paidAt.empty()  ? json(nullptr) : json(lp.paidAt);
                    row["txnType"] = lp.txnType.empty() ? json(nullptr) : json(lp.txnType);
                    p["lastPayments"].push_back(std::move(row));
                }
            }
        }

        // School-year age group: cohortYear = (mm >= 8 ? yy+1 : yy);
        //                       ageGroup   = "U" + (seasonEndYear - cohortYear)
        if (p.at("birthDate").is_string()) {
            const std::string bd = p.at("birthDate").get<std::string>();
            try {
                const int yy = std::stoi(bd.substr(0, 4));
                const int mm = std::stoi(bd.substr(5, 2));
                const int cohort = (mm >= 8) ? yy + 1 : yy;
                p["ageGroup"] = std::string("U") + std::to_string(seasonEndYear - cohort);
            } catch (const std::exception&) {
                p["ageGroup"] = nullptr;
            }
        } else {
            p["ageGroup"] = nullptr;
        }
    }

    // Bucket allocation.
    std::vector<std::string> bucketOrder;
    bucketOrder.reserve(bucketDefs.size());
    std::unordered_map<std::string, std::vector<json>> buckets;
    for (const auto& b : bucketDefs) {
        bucketOrder.push_back(b.label);
        buckets[b.label]; // ensure key present even if empty
    }
    std::vector<json> unbucketed;

    for (auto& p : shapedAll) {
        const std::string club = (p.at("club").get<std::string>() == "Boys Club") ? "boys" : "girls";
        const std::string bd   = p.at("birthDate").is_string() ? p.at("birthDate").get<std::string>() : std::string{};
        const auto* hit = YouthAgeGroups::matchBucket(bd, club, bucketDefs);
        if (hit) buckets[hit->label].push_back(std::move(p));
        else     unbucketed.push_back(std::move(p));
    }

    // Sort each bucket: birthDate asc (empty last), then lastName asc.
    auto rowSort = [](const json& a, const json& b) {
        const std::string ad = a.at("birthDate").is_string() ? a.at("birthDate").get<std::string>() : std::string{};
        const std::string bd = b.at("birthDate").is_string() ? b.at("birthDate").get<std::string>() : std::string{};
        if (ad != bd) {
            if (ad.empty()) return false;
            if (bd.empty()) return true;
            return ad < bd;
        }
        const std::string al = a.at("lastName").is_string() ? a.at("lastName").get<std::string>() : std::string{};
        const std::string bl = b.at("lastName").is_string() ? b.at("lastName").get<std::string>() : std::string{};
        return al < bl;
    };
    for (auto& kv : buckets) std::sort(kv.second.begin(), kv.second.end(), rowSort);

    // Project buckets back to JSON in bucketOrder so the wire object retains
    // a meaningful key order even though JSON objects are unordered.
    json bucketsJson = json::object();
    json countsJson  = json::object();
    for (const auto& label : bucketOrder) {
        json arr = json::array();
        for (auto& row : buckets[label]) arr.push_back(std::move(row));
        countsJson[label]  = static_cast<int>(arr.size());
        bucketsJson[label] = std::move(arr);
    }

    json bucketDefsJson = json::array();
    for (const auto& b : bucketDefs) {
        json bd;
        bd["label"]        = b.label;
        bd["clubFilter"]   = b.clubFilter.empty() ? json(nullptr) : json(b.clubFilter);
        bd["minBirthDate"] = b.minBirthIso;
        bd["maxBirthDate"] = b.maxBirthIso;
        bd["maxRoster"]    = b.hasMaxRoster ? json(b.maxRoster) : json(nullptr);
        bd["color"]        = b.color.empty() ? json(nullptr) : json(b.color);
        bd["sortOrder"]    = b.sortOrder;
        bucketDefsJson.push_back(std::move(bd));
    }

    out.body["fetchedAt"]      = nowIsoMs();
    out.body["seasonEndYear"]  = seasonEndYear;
    out.body["bucketOrder"]    = bucketOrder;
    out.body["bucketDefs"]     = std::move(bucketDefsJson);
    out.body["buckets"]        = std::move(bucketsJson);
    out.body["counts"]         = std::move(countsJson);
    out.body["total"]          = static_cast<int>(shapedAll.size());
    out.body["unbucketed"]     = std::move(unbucketed);
    out.body["sourcePrograms"] = {
        {"boysClub",  boysProgramId_},
        {"girlsClub", girlsProgramId_},
    };
    return out;
}
