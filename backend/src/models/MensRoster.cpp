#include "MensRoster.h"

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cmath>
#include <cstdlib>
#include <ctime>
#include <limits>
#include <sstream>
#include <unordered_map>
#include <vector>

#include "MensTeamAssignments.h"
#include "MensTeamColumns.h"
#include "PersonBilling.h"
#include "../services/LeagueAppsService.h"

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
// (35.00 → "35").  nlohmann::json distinguishes int vs double and would
// emit "35.0".  Coerce whole-valued doubles to int64 for byte-equivalent
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

// Coerce existing JSON numbers (possibly arriving as 0.0 from LA) into the
// same shape JS would emit.  Non-numbers pass through unchanged.
json jsNumberJ(const json& j) {
    if (j.is_number_float())            return jsNumber(j.get<double>());
    if (j.is_number_integer())          return j;
    if (j.is_number_unsigned())         return j;
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

// LeagueApps puts the user-supplied fields like "Preferred Jersey Number"
// and "Jersey Size" at the top of the rec.  Surface them as `jerseyNumber`
// / `jerseySize` on the wire (matches Node).  "Participant Shirt Size" is
// the fallback for jersey size.
json optJerseyNumber(const json& rec) {
    auto it = rec.find("Preferred Jersey Number");
    if (it == rec.end() || it->is_null()) return nullptr;
    return *it;
}

json optJerseySize(const json& rec) {
    auto it = rec.find("Jersey Size");
    if (it != rec.end() && !it->is_null()) return *it;
    it = rec.find("Participant Shirt Size");
    if (it != rec.end() && !it->is_null()) return *it;
    return nullptr;
}

} // namespace

MensRoster::MensRoster()
    : columns_    (std::make_unique<MensTeamColumns>()),
      assignments_(std::make_unique<MensTeamAssignments>()),
      billing_    (std::make_unique<PersonBilling>()),
      mensProgramId_(envInt("LEAGUEAPPS_MENS_PROGRAM_ID", 5039300)) {}

MensRoster::~MensRoster() = default;

int MensRoster::envInt(const char* name, int fallback) {
    const char* raw = std::getenv(name);
    if (!raw || !*raw) return fallback;
    try { return std::stoi(raw); }
    catch (const std::exception&) { return fallback; }
}

json MensRoster::shapeMensPlayer(const json& rec) {
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

    const std::string g = optStr(rec, "gender");
    out["gender"]             = g.empty() ? std::string("Male") : g;
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
    out["jerseyNumber"]       = optJerseyNumber(rec);
    out["jerseySize"]         = optJerseySize(rec);
    return out;
}

MensRoster::Result MensRoster::run(bool includeAll) {
    Result out;

    auto cols          = columns_->loadAll();
    auto assignmentMap = assignments_->loadAll();
    auto billingMap    = billing_->loadAll();

    if (cols.empty()) {
        out.noColumns = true;
        out.error = "No mens_team_columns configured.  Seed the table to enable bucketing.";
        return out;
    }

    auto recs = LeagueAppsService::getInstance().fetchProgramRegistrations(mensProgramId_);

    std::vector<json> all;
    all.reserve(recs.size());
    for (const auto& r : recs) {
        if (isActive(r, includeAll)) all.push_back(shapeMensPlayer(r));
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

    for (auto& p : all) {
        const std::string uid = userIdString(p.at("leagueAppsUserId"));
        const auto bill = PersonBilling::resolve(billingMap, uid);

        // Find the user's assignment list; intersect with the configured
        // columns so off-dashboard team_ids never leak into the response.
        const std::vector<MensTeamAssignments::Cell>* userCells = nullptr;
        auto it = assignmentMap.find(uid);
        if (it != assignmentMap.end()) userCells = &it->second;

        std::vector<int> relevant;
        if (userCells) {
            for (const auto& c : cols) {
                if (findCellInUser(*userCells, c.teamId)) relevant.push_back(c.teamId);
            }
        }

        if (relevant.empty()) {
            json row             = p;
            row["teamIds"]       = json::array();
            row["nextBillDate"]  = bill.nextBillDate.empty() ? json(nullptr) : json(bill.nextBillDate);
            row["nextBillAmount"] = jsNumber(bill.nextBillAmount);
            row["isDefault"]     = bill.isDefault;
            unassigned.push_back(std::move(row));
        } else {
            for (int tid : relevant) {
                const auto* cell = findCellInUser(*userCells, tid);
                json row             = p;
                row["teamIds"]       = relevant;
                row["onRoster"]      = cell ? cell->onRoster : false;
                row["nextBillDate"]  = bill.nextBillDate.empty() ? json(nullptr) : json(bill.nextBillDate);
                row["nextBillAmount"] = jsNumber(bill.nextBillAmount);
                row["isDefault"]     = bill.isDefault;
                buckets[std::to_string(tid)].push_back(std::move(row));
            }
        }
    }

    // Node sorts with String.prototype.localeCompare which is
    // case-insensitive ("base" sensitivity).  For the ASCII names in our
    // data, lowercasing both sides before std::stable_sort produces a
    // byte-equivalent ordering — and stable_sort preserves LA fetch
    // order for true ties (mirrors JS Array.sort stability).
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
    out.body["columns"]         = std::move(columnsArr);
    out.body["buckets"]         = std::move(bucketsJson);
    out.body["unassigned"]      = std::move(unassigned);
    out.body["unassignedCount"] = static_cast<int>(out.body["unassigned"].size());
    out.body["total"]           = static_cast<int>(all.size());
    out.body["sourceProgram"]   = mensProgramId_;
    return out;
}
