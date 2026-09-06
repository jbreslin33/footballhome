#include "WomensRoster.h"
#include "WelcomeLog.h"

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cstdlib>
#include <ctime>
#include <iostream>
#include <limits>
#include <pqxx/pqxx>
#include <sstream>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "ActiveTeamBadges.h"
#include "PickupMembership.h"
#include "MensTeamAssignments.h"
#include "MensTeamColumns.h"
#include "YouthAgeGroups.h"
#include "../database/Database.h"

using nlohmann::json;

namespace {

std::string trim(const std::string& s) {
    size_t a = 0;
    while (a < s.size() && std::isspace(static_cast<unsigned char>(s[a]))) ++a;
    size_t b = s.size();
    while (b > a && std::isspace(static_cast<unsigned char>(s[b - 1]))) --b;
    return s.substr(a, b - a);
}

std::string optStr(const json& j, const char* key) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null() || !it->is_string()) return {};
    return it->get<std::string>();
}

json optAny(const json& j, const char* key) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null()) return nullptr;
    return *it;
}

// JS JSON.stringify writes integer-valued numbers without a decimal point
// (35.00 → "35"). nlohmann::json distinguishes int vs double and would
// emit "35.0". Coerce whole-valued doubles to int64 for byte-equivalent
// output; pass non-finite values through as null.
json jsNumber(double v) {
    if (!std::isfinite(v)) return nullptr;
    const double r = std::round(v);
    if (v == r &&
        v >= static_cast<double>(std::numeric_limits<long long>::min()) &&
        v <= static_cast<double>(std::numeric_limits<long long>::max())) {
        return json(static_cast<long long>(r));
    }
    return json(v);
}

json jsNumberJ(const json& j) {
    if (j.is_number_float())    return jsNumber(j.get<double>());
    if (j.is_number_integer())  return j;
    if (j.is_number_unsigned()) return j;
    return j;
}

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

json optUserId(const json& rec) {
    auto it = rec.find("userId");
    if (it == rec.end() || it->is_null()) return nullptr;
    return *it;
}

std::string userIdString(const json& v) {
    if (v.is_null()) return {};
    if (v.is_string()) return v.get<std::string>();
    if (v.is_number_integer())  return std::to_string(v.get<long long>());
    if (v.is_number_unsigned()) return std::to_string(v.get<unsigned long long>());
    if (v.is_number_float())    return std::to_string(static_cast<long long>(v.get<double>()));
    return {};
}

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

WomensRoster::WomensRoster()
    : columns_    (std::make_unique<MensTeamColumns>("womens")),
      assignments_(std::make_unique<MensTeamAssignments>("womens")),
      womensProgramId_(envInt("LEAGUEAPPS_WOMENS_PROGRAM_ID", 5039340)) {}

WomensRoster::~WomensRoster() = default;

int WomensRoster::envInt(const char* name, int fallback) {
    const char* raw = std::getenv(name);
    if (!raw || !*raw) return fallback;
    try { return std::stoi(raw); }
    catch (const std::exception&) { return fallback; }
}

json WomensRoster::shapeWomensPlayer(const json& rec) {
    const std::string first = trim(optStr(rec, "firstName"));
    const std::string last  = trim(optStr(rec, "lastName"));
    const std::string bd    = birthDateIso(rec);

    json out;
    json regId = nullptr;
    if (auto it = rec.find("registrationId"); it != rec.end() && !it->is_null()) regId = *it;
    else if (auto it = rec.find("id");        it != rec.end() && !it->is_null()) regId = *it;
    out["registrationId"]   = regId;
    out["leagueAppsUserId"] = optUserId(rec);
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

    // US-Soccer age group (U23/U30/...) — same Aug-1 cohort math as the
    // youth rosters, and the same call MensRoster::shapeMensPlayer makes
    // for adult men (confirmed birth-year-generic, not youth-specific —
    // see YouthAgeGroups.h).
    {
        const std::string ag = YouthAgeGroups::ageGroupFromDob(bd, YouthAgeGroups::defaultSeasonEndYear());
        out["ageGroup"] = ag.empty() ? json(nullptr) : json(ag);
    }

    const std::string g = optStr(rec, "gender");
    out["gender"]             = g.empty() ? std::string("Female") : g;
    auto strOrNull = [&](const char* k) -> json {
        const std::string v = optStr(rec, k);
        return v.empty() ? json(nullptr) : json(v);
    };
    out["email"]              = strOrNull("email");
    out["phone"]              = strOrNull("phone");
    out["paymentStatus"]      = strOrNull("paymentStatus");
    out["outstandingBalance"] = jsNumberJ(optAny(rec, "outstandingBalance"));
    out["registrationStatus"] = strOrNull("registrationStatus");
    out["role"]               = strOrNull("role");
    out["season"]             = strOrNull("season");
    return out;
}

WomensRoster::Result WomensRoster::run(bool includeAll,
                                        bool /*refreshLa*/,
                                        const std::vector<nlohmann::json>& recs,
                                        const std::unordered_map<std::string, long long>& personIdByUserId,
                                        bool includeInactive) {
    Result out;

    auto cols          = columns_->loadAll(includeInactive);
    auto assignmentMap = assignments_->loadAll();

    if (cols.empty()) {
        out.noColumns = true;
        out.error = "No board columns configured for womens teams (teams.board_sort_order). Seed them to enable bucketing.";
        return out;
    }

    // ── LA snapshot supplied by caller ───────────────────────────────
    // Same STRICT rule as Mens/Boys (see .github/copilot-instructions.md
    // "Membership Data Flow"): the controller's laGet(static) wrapper
    // already ran LaProgramSync::run(womensProgramId_) before we got
    // here — `recs` is that fresh snapshot. No direct LA I/O, no cached
    // snapshot, no payment sync (Women's Club is NA_FREE — nothing to
    // pay, so there's no PersonPayments dependency here at all).

    // person_id per la_registration_id (mirrors MensRoster) — lets each
    // roster row carry the FH persons.id for the View button / cross-
    // team badge lookup below.
    std::unordered_map<long long, long long> personIdByRegId;
    try {
        auto* db = Database::getInstance();
        pqxx::result rows = db->query(
            "SELECT la_registration_id, person_id "
            "  FROM person_la_memberships "
            " WHERE ended_at IS NULL "
            "   AND la_registration_id IS NOT NULL");
        for (const auto& r : rows) {
            personIdByRegId[r["la_registration_id"].as<long long>()] =
                r["person_id"].as<long long>();
        }
    } catch (const std::exception& e) {
        std::cerr << "[WomensRoster] person_id load failed: " << e.what() << std::endl;
    }
    auto personIdFor = [&](const json& regJson) -> long long {
        long long id = 0;
        if      (regJson.is_number_integer())  id = regJson.get<long long>();
        else if (regJson.is_number_unsigned()) id = static_cast<long long>(regJson.get<unsigned long long>());
        else if (regJson.is_number_float())    id = static_cast<long long>(regJson.get<double>());
        else if (regJson.is_string()) {
            try { id = std::stoll(regJson.get<std::string>()); }
            catch (...) { id = 0; }
        }
        if (id <= 0) return 0;
        auto it = personIdByRegId.find(id);
        return it == personIdByRegId.end() ? 0 : it->second;
    };

    // Canonical FH names for linked persons (mirrors MensRoster) — the
    // LA alias can carry a stale display name; prefer the FH persons
    // row when a link exists.
    std::unordered_map<long long, std::pair<std::string, std::string>> canonicalNamesByPersonId;
    try {
        auto* db = Database::getInstance();
        pqxx::result rows = db->query("SELECT id, first_name, last_name FROM persons");
        for (const auto& r : rows) {
            if (r["id"].is_null()) continue;
            const long long pid = r["id"].as<long long>();
            const std::string first = r["first_name"].is_null() ? std::string{} : r["first_name"].c_str();
            const std::string last  = r["last_name"].is_null()  ? std::string{} : r["last_name"].c_str();
            canonicalNamesByPersonId[pid] = {trim(first), trim(last)};
        }
    } catch (const std::exception& e) {
        std::cerr << "[WomensRoster] canonical person names load failed: " << e.what() << std::endl;
    }
    auto applyCanonicalName = [&](json& p) {
        const long long pid = personIdFor(p.at("registrationId"));
        if (pid <= 0) return;
        auto it = canonicalNamesByPersonId.find(pid);
        if (it == canonicalNamesByPersonId.end()) return;
        const auto& [first, last] = it->second;
        if (!first.empty()) p["firstName"] = first;
        if (!last.empty())  p["lastName"]  = last;
        p["fullName"] = trim(first + " " + last);
    };

    // FH last activity per person (sessions.last_used_at) — same signal
    // Mens/Boys surface, generic across every roster.
    std::unordered_map<long long, std::string> fhLastActivityByPerson;
    try {
        auto* db = Database::getInstance();
        pqxx::result rows = db->query(
            "SELECT person_id, "
            "       TO_CHAR(MAX(last_used_at) AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS last_iso "
            "  FROM sessions "
            " WHERE revoked_at IS NULL "
            " GROUP BY person_id");
        for (const auto& r : rows) {
            if (r["last_iso"].is_null()) continue;
            fhLastActivityByPerson[r["person_id"].as<long long>()] = r["last_iso"].c_str();
        }
    } catch (const std::exception& e) {
        std::cerr << "[WomensRoster] fh_last_activity load failed: " << e.what() << std::endl;
    }
    auto fhLastActivityFor = [&](long long personId) -> json {
        if (personId <= 0) return json(nullptr);
        auto it = fhLastActivityByPerson.find(personId);
        if (it == fhLastActivityByPerson.end()) return json(nullptr);
        return json(it->second);
    };

    // "Member since" timestamp — la_registered_at, keyed by registration
    // id with a per-uid fallback (earliest across any of the person's
    // Women's Club memberships). Membership metadata, not a payments
    // feature — kept for the same "Reg: MMM D, YYYY" card signal
    // Mens/Boys show.
    std::unordered_map<long long, std::string> laRegisteredAtByRegId;
    std::unordered_map<std::string, std::string> laRegisteredAtByUid;
    try {
        auto* db = Database::getInstance();
        pqxx::result rows = db->query(
            "SELECT la_registration_id, "
            "       TO_CHAR(la_registered_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS reg_iso "
            "  FROM person_la_memberships "
            " WHERE la_registration_id IS NOT NULL "
            "   AND la_registered_at IS NOT NULL");
        for (const auto& r : rows) {
            if (r["la_registration_id"].is_null() || r["reg_iso"].is_null()) continue;
            laRegisteredAtByRegId[r["la_registration_id"].as<long long>()] = r["reg_iso"].c_str();
        }
        pqxx::result rowsByUid = db->query(
            "SELECT p.la_user_id AS la_user_id, "
            "       TO_CHAR(MIN(plm.la_registered_at) AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS reg_iso "
            "  FROM person_la_memberships plm "
            "  JOIN persons p ON p.id = plm.person_id "
            " WHERE plm.la_registered_at IS NOT NULL "
            "   AND p.la_user_id IS NOT NULL "
            " GROUP BY p.la_user_id");
        for (const auto& r : rowsByUid) {
            if (r["la_user_id"].is_null() || r["reg_iso"].is_null()) continue;
            laRegisteredAtByUid[r["la_user_id"].c_str()] = r["reg_iso"].c_str();
        }
    } catch (const std::exception& e) {
        std::cerr << "[WomensRoster] la_registered_at load failed: " << e.what() << std::endl;
    }
    auto laRegIsoFor = [&](const json& regJson, const std::string& uidFallback) -> json {
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

    std::vector<json> all;
    all.reserve(recs.size());
    for (const auto& r : recs) {
        if (!isActive(r, includeAll)) continue;
        json p = shapeWomensPlayer(r);
        applyCanonicalName(p);
        all.push_back(std::move(p));
    }

    // Bucket per column (keyed by teamId-as-string).
    std::unordered_map<std::string, std::vector<json>> buckets;
    for (const auto& c : cols) buckets[std::to_string(c.teamId)];
    std::vector<json> unassigned;

    auto findCellInUser = [](const std::vector<MensTeamAssignments::Cell>& v, int teamId)
        -> const MensTeamAssignments::Cell* {
        for (const auto& c : v) if (c.teamId == teamId) return &c;
        return nullptr;
    };

    // Every active team (any gender_category) each player currently holds
    // — batch-loaded once so cards can badge multi-team players (see
    // ActiveTeamBadges.h), same as Mens/Boys.
    std::unordered_map<long long, json> activeTeamsByPerson;
    std::unordered_map<long long, json> pickupByPerson;
    {
        std::vector<long long> personIds;
        personIds.reserve(all.size());
        for (const auto& p : all) {
            const std::string uid = userIdString(p.at("leagueAppsUserId"));
            long long pid = personIdFor(p.at("registrationId"));
            if (pid <= 0) {
                auto sit = personIdByUserId.find(uid);
                if (sit != personIdByUserId.end()) pid = sit->second;
            }
            if (pid > 0) personIds.push_back(pid);
        }
        activeTeamsByPerson = ActiveTeamBadges::loadForPersons(personIds);
        // Same personIds, one more batch lookup: who also holds a
        // current pickup-variant LA registration. Members and Pickup
        // are independent sub-programs and nobody is meant to hold
        // both, so the card flags it (owner 2026-08-25).
        pickupByPerson = PickupMembership::loadForPersons(personIds);
    }

    for (auto& p : all) {
        const std::string uid = userIdString(p.at("leagueAppsUserId"));

        // Find the user's assignment list; intersect with the configured
        // columns so off-dashboard team_ids never leak into the response.
        const std::vector<MensTeamAssignments::Cell>* userCells = nullptr;
        std::vector<MensTeamAssignments::Cell> fallbackCells;
        auto it = assignmentMap.find(uid);
        if (it != assignmentMap.end()) {
            userCells = &it->second;
        } else {
            // LA occasionally reports a drifting userId for the same
            // registration across syncs — fall back to the person id
            // THIS sync pass resolved, which isn't subject to that race.
            auto pit = personIdByUserId.find(uid);
            if (pit != personIdByUserId.end() && pit->second > 0) {
                fallbackCells = assignments_->cellsForPerson(pit->second);
                if (!fallbackCells.empty()) userCells = &fallbackCells;
            }
        }

        std::vector<int> relevant;
        if (userCells) {
            for (const auto& c : cols) {
                if (findCellInUser(*userCells, c.teamId)) relevant.push_back(c.teamId);
            }
        }

        long long pid = personIdFor(p.at("registrationId"));
        if (pid <= 0) {
            auto sit = personIdByUserId.find(uid);
            if (sit != personIdByUserId.end()) pid = sit->second;
        }
        // Pickup flag (owner 2026-08-25: "if a member is also pickup member then put pickup flag on his card"). null when they hold no current pickup registration.
        const json pickupJson = [&]() -> json {
            auto pit = pickupByPerson.find(pid);
            return (pit != pickupByPerson.end()) ? pit->second : json(nullptr);
        }();
        const json activeTeamsJson = [&]() -> json {
            auto ait = activeTeamsByPerson.find(pid);
            return (ait != activeTeamsByPerson.end()) ? ait->second : json::array();
        }();
        const json laRegisteredAt = laRegIsoFor(p.at("registrationId"), uid);
        const json personIdJson   = pid > 0 ? json(pid) : json(nullptr);
        const json fhLastActivity = fhLastActivityFor(pid);

        if (relevant.empty()) {
            json row               = p;
            row["teamIds"]         = json::array();
            row["personId"]        = personIdJson;
            row["fhLastActivityAt"] = fhLastActivity;
            row["activeTeams"]     = activeTeamsJson;
            row["pickupMembership"] = pickupJson;
            row["laRegisteredAt"]  = laRegisteredAt;
            unassigned.push_back(std::move(row));
        } else {
            for (int tid : relevant) {
                const auto* cell = findCellInUser(*userCells, tid);
                json row              = p;
                row["teamIds"]        = relevant;
                row["onRoster"]       = cell ? cell->onRoster : false;
                row["coachSortOrder"] = (cell && cell->coachSortOrder)
                    ? json(*cell->coachSortOrder)
                    : json(nullptr);
                row["lineupRole"] = (cell && cell->lineupRole)
                    ? json(*cell->lineupRole)
                    : json(nullptr);
                row["rosterStatus"] = (cell && cell->rosterStatus)
                    ? json(*cell->rosterStatus)
                    : json(nullptr);
                row["personId"]        = personIdJson;
                row["fhLastActivityAt"] = fhLastActivity;
                row["activeTeams"]      = activeTeamsJson;
                row["pickupMembership"] = pickupJson;
                row["laRegisteredAt"]   = laRegisteredAt;
                buckets[std::to_string(tid)].push_back(std::move(row));
            }
        }
    }

    // Node sorts with String.prototype.localeCompare which is
    // case-insensitive ("base" sensitivity). Lowercasing both sides
    // before std::stable_sort mirrors that for our ASCII data.
    auto lowerAscii = [](const std::string& s) {
        std::string o; o.reserve(s.size());
        for (char c : s) o.push_back(static_cast<char>(std::tolower(static_cast<unsigned char>(c))));
        return o;
    };
    auto alpha = [&](const json& a, const json& b) {
        const std::string al = a.at("lastName").is_string()  ? lowerAscii(a.at("lastName").get<std::string>())  : std::string{};
        const std::string bl = b.at("lastName").is_string()  ? lowerAscii(b.at("lastName").get<std::string>())  : std::string{};
        if (al != bl) return al < bl;
        const std::string af = a.at("firstName").is_string() ? lowerAscii(a.at("firstName").get<std::string>()) : std::string{};
        const std::string bf = b.at("firstName").is_string() ? lowerAscii(b.at("firstName").get<std::string>()) : std::string{};
        return af < bf;
    };
    auto sortByRosterThenName = [&](const json& a, const json& b) {
        auto coachRank = [](const json& x) {
            if (x.contains("coachSortOrder") && x["coachSortOrder"].is_number()) {
                return x["coachSortOrder"].get<int>();
            }
            return std::numeric_limits<int>::max();
        };
        const int ca = coachRank(a);
        const int cb = coachRank(b);
        if (ca != cb) return ca < cb;
        const int ar = a.contains("onRoster") && a["onRoster"].get<bool>() ? 0 : 1;
        const int br = b.contains("onRoster") && b["onRoster"].get<bool>() ? 0 : 1;
        if (ar != br) return ar < br;
        return alpha(a, b);
    };

    for (auto& kv : buckets) std::stable_sort(kv.second.begin(), kv.second.end(), sortByRosterThenName);
    std::stable_sort(unassigned.begin(), unassigned.end(), alpha);

    // Top-level columns array.
    json columnsArr = json::array();
    for (const auto& c : cols) {
        const auto& list = buckets[std::to_string(c.teamId)];
        int onRosterCount = 0;
        for (const auto& row : list) if (row.value("onRoster", false)) ++onRosterCount;

        json col;
        col["teamId"]        = c.teamId;
        col["label"]         = c.label;
        col["shortLabel"]    = c.shortLabel;
        col["color"]         = c.color.empty() ? json(nullptr) : json(c.color);
        col["mutexGroup"]    = c.mutexGroup.empty() ? json(nullptr) : json(c.mutexGroup);
        col["maxRoster"]     = c.hasMaxRoster ? json(c.maxRoster) : json(nullptr);
        col["fieldSize"]     = c.hasFieldSize ? json(c.fieldSize) : json(nullptr);
        col["sortOrder"]     = c.sortOrder;
        col["count"]         = static_cast<int>(list.size());
        col["onRosterCount"] = onRosterCount;
        columnsArr.push_back(std::move(col));
    }

    // Project buckets back to an object keyed by stringified teamId.
    json bucketsJson = json::object();
    for (const auto& c : cols) {
        const std::string k = std::to_string(c.teamId);
        auto it2 = buckets.find(k);
        json arr = json::array();
        if (it2 != buckets.end()) {
            for (auto& row : it2->second) arr.push_back(std::move(row));
        }
        bucketsJson[k] = std::move(arr);
    }

    out.body["fetchedAt"]       = nowIsoMs();
    // Welcome-outreach state per card (owner 2026-09-06, migration 339):
    // row["welcome"] = {due, lastSentAt, lastChannel, lastContact}.
    // Consistent across all four boards — WelcomeLog owns the rule.
    {
        WelcomeLog welcomes;
        welcomes.attachToRoster(unassigned, bucketsJson, /*youth=*/false);
    }
    out.body["columns"]         = std::move(columnsArr);
    out.body["buckets"]         = std::move(bucketsJson);
    out.body["unassigned"]      = std::move(unassigned);
    out.body["unassignedCount"] = static_cast<int>(out.body["unassigned"].size());
    out.body["total"]           = static_cast<int>(all.size());
    out.body["sourceProgram"]   = womensProgramId_;

    return out;
}
