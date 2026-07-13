#include "BoysRoster.h"

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cstdlib>
#include <ctime>
#include <iostream>
#include <limits>
#include <sstream>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "MensTeamAssignments.h"
#include "MensTeamColumns.h"
#include "PersonPayments.h"
#include "PayReminderLog.h"
#include "../database/Database.h"
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

// LA `birthDate` → "YYYY-MM-DD" (UTC).  Handles both number (epoch ms) and
// ISO string.  Mirrors YouthRoster::birthDateIso.
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

// School-year age group from DOB.  Aug 1 cutover: month >= 8 → cohort = yy+1,
// else cohort = yy.  ageGroup = "U" + (seasonEndYear - cohort).
// Returns json(nullptr) when the DOB can't be parsed.
json ageGroupFromDob(const std::string& bdIso, int seasonEndYear) {
    if (bdIso.size() < 10) return nullptr;
    try {
        const int yy = std::stoi(bdIso.substr(0, 4));
        const int mm = std::stoi(bdIso.substr(5, 2));
        const int cohort = (mm >= 8) ? yy + 1 : yy;
        return std::string("U") + std::to_string(seasonEndYear - cohort);
    } catch (const std::exception&) {
        return nullptr;
    }
}

} // namespace

BoysRoster::BoysRoster()
    : columns_    (std::make_unique<MensTeamColumns>("boys")),
      assignments_(std::make_unique<MensTeamAssignments>("boys")),
      payments_   (std::make_unique<PersonPayments>()),
      boysProgramId_ (envInt("LEAGUEAPPS_BOYS_CLUB_PROGRAM_ID",  5039252)),
      girlsProgramId_(envInt("LEAGUEAPPS_GIRLS_CLUB_PROGRAM_ID", 5039357)) {}

BoysRoster::~BoysRoster() = default;

int BoysRoster::envInt(const char* name, int fallback) {
    const char* raw = std::getenv(name);
    if (!raw || !*raw) return fallback;
    try { return std::stoi(raw); }
    catch (const std::exception&) { return fallback; }
}

int BoysRoster::defaultSeasonEndYear() {
    // June 1 cutover mirrors YouthAgeGroups::defaultSeasonEndYear so the
    // ageGroup we surface matches the mens-side / youth-side dashboard's
    // notion of the current season.
    std::time_t nowT = std::time(nullptr);
    std::tm tm{};
    localtime_r(&nowT, &tm);
    const int y = tm.tm_year + 1900;
    const int m = tm.tm_mon + 1;
    return (m >= 6) ? (y + 1) : y;
}

json BoysRoster::shapePlayer(const json& rec, const std::string& club, int seasonEndYear) {
    const std::string first = trim(optStr(rec, "firstName"));
    const std::string last  = trim(optStr(rec, "lastName"));
    const std::string bd    = birthDateIso(rec);

    json out;
    json regId = nullptr;
    if (auto it = rec.find("registrationId"); it != rec.end() && !it->is_null()) regId = *it;
    else if (auto it = rec.find("id");         it != rec.end() && !it->is_null()) regId = *it;
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

    // Gender: LA-supplied wins; club default fills gaps.
    const std::string g = optStr(rec, "gender");
    if (!g.empty()) out["gender"] = g;
    else            out["gender"] = (club == "boys") ? "Male" : "Female";

    out["club"] = (club == "boys") ? "Boys Club" : "Girls Club";

    // Real school-year age group (U8/U10/U12/...) — the user-visible chip
    // that lets admin see the kid's actual age category regardless of
    // which selection column they're dropped into.
    out["ageGroup"] = ageGroupFromDob(bd, seasonEndYear);

    auto strOrNull = [&](const char* k) -> json {
        const std::string v = optStr(rec, k);
        return v.empty() ? json(nullptr) : json(v);
    };
    out["email"]              = strOrNull("email");
    out["phone"]              = strOrNull("phone");
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

BoysRoster::Result BoysRoster::run(bool includeAll, bool refreshLa) {
    Result out;

    auto cols          = columns_->loadAll();
    auto assignmentMap = assignments_->loadAll();
    if (cols.empty()) {
        out.noColumns = true;
        out.error = "No roster_columns configured for domain='boys'.  Seed the table to enable bucketing.";
        return out;
    }

    // ── LA registrant snapshots (boys + girls, cached) ───────────────
    std::vector<json> boysRecs, girlsRecs;
    {
        std::lock_guard<std::mutex> lk(cacheMutex_);
        // Source-of-truth rule (2026-07-09): LA is authoritative for
        // membership — every load hits LA live so a brand-new signup
        // shows in Unassigned immediately.  Cache is fallback on error.
        (void)refreshLa;
        const bool needFetch = true;
        if (needFetch) {
            try {
                cachedBoys_ = LeagueAppsService::getInstance()
                                  .fetchProgramRegistrations(boysProgramId_);
                cachedGirls_ = LeagueAppsService::getInstance()
                                   .fetchProgramRegistrations(girlsProgramId_);
                cacheValid_ = true;
            } catch (const std::exception& e) {
                if (cacheValid_) {
                    std::cerr << "[BoysRoster] LA refresh failed, serving cached snapshot: "
                              << e.what() << std::endl;
                } else {
                    throw;
                }
            }
        }
        boysRecs  = cachedBoys_;
        girlsRecs = cachedGirls_;
    }

    // ── Payments sync + 3-month window load (2026-07-05) ─────────────
    //
    // The frontend BillingBadge component renders a 3-month calendar
    // table from `p.paymentsWindow`; without this load every cell shows
    // $0 which caused the user to say "no youth payments picked up at
    // all lol".  We do a live sync from the LA transactions feed (best-
    // effort — cursor-based, cheap on the hot path) then load every
    // positive charge in the current + previous 2 calendar months for
    // both youth programs.
    if (refreshLa) {
        try {
            payments_->syncFromLa();
        } catch (const std::exception& e) {
            std::cerr << "[BoysRoster] payments syncFromLa failed: "
                      << e.what() << std::endl;
        }
    }

    // Precompute the 3-month window start (first day of month N-2 in UTC).
    std::string windowStartIso;
    {
        std::time_t nowT = std::time(nullptr);
        std::tm tm{};
        gmtime_r(&nowT, &tm);
        int y = tm.tm_year + 1900;
        int m = tm.tm_mon + 1;
        int wm = m - 2;
        int wy = y;
        while (wm < 1) { wm += 12; --wy; }
        char buf[16];
        std::snprintf(buf, sizeof(buf), "%04d-%02d-01", wy, wm);
        windowStartIso = buf;
    }

    // Per-registration payment list (children's LA registrations) for
    // the current + 2 previous months across BOTH youth programs.  We
    // key on la_registration_id because parents pay under their own
    // account — the payment's la_user_id is the parent's, not the
    // child's, so a user-id join misses every family payment.  The
    // registration id, in contrast, is the child's registration and
    // matches shapePlayer's `registrationId`.  Extra program IDs are
    // env-overridable via LEAGUEAPPS_BOYS_PAYMENT_PROGRAM_IDS.
    struct BoysPay {
        double      amount = 0.0;
        std::string paidAt;   // ISO8601 UTC
        long long   programId = 0;
    };
    std::unordered_map<long long, std::vector<BoysPay>> payByReg;
    {
        std::vector<std::string> programIds;
        if (const char* raw = std::getenv("LEAGUEAPPS_BOYS_PAYMENT_PROGRAM_IDS"); raw && *raw) {
            std::stringstream ss(raw);
            std::string tok;
            while (std::getline(ss, tok, ',')) if (!tok.empty()) programIds.push_back(tok);
        }
        if (programIds.empty()) {
            programIds.push_back(std::to_string(boysProgramId_));
            programIds.push_back(std::to_string(girlsProgramId_));
        }
        std::string inList;
        for (size_t i = 0; i < programIds.size(); ++i) {
            if (i) inList += ",";
            inList += "$" + std::to_string(i + 1);
        }
        try {
            auto* db = Database::getInstance();
            std::vector<std::string> params = programIds;
            params.push_back(windowStartIso);
            pqxx::result rows = db->query(
                "SELECT la_registration_id, amount, la_program_id, "
                "       TO_CHAR(paid_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS paid_iso "
                "  FROM person_payments "
                " WHERE la_program_id IN (" + inList + ") "
                "   AND la_registration_id IS NOT NULL "
                "   AND txn_type IN ('Charge','Bank','Offline Payment') "
                "   AND amount > 0 "
                "   AND paid_at >= $" + std::to_string(programIds.size() + 1) + "::timestamptz "
                " ORDER BY la_registration_id, paid_at DESC",
                params
            );
            for (const auto& r : rows) {
                if (r["la_registration_id"].is_null()) continue;
                BoysPay bp;
                bp.amount    = r["amount"].is_null() ? 0.0 : r["amount"].as<double>();
                bp.paidAt    = r["paid_iso"].is_null() ? std::string{} : r["paid_iso"].c_str();
                bp.programId = r["la_program_id"].is_null() ? 0 : r["la_program_id"].as<long long>();
                const long long regId = r["la_registration_id"].as<long long>();
                payByReg[regId].push_back(std::move(bp));
            }
        } catch (const std::exception& e) {
            std::cerr << "[BoysRoster] payments window load failed: " << e.what() << std::endl;
        }
    }

    // ── LA registration timestamp load (2026-07-06) ──────────────────
    //
    // Emitted as `laRegisteredAt` on every row.  The frontend uses it to:
    //   1) Show "Reg: MMM D, YYYY" on the roster card (all clubs).
    //   2) Decide whether to render the projected-prorate cell — only
    //      players registered on/after 2026-07-06 get the new
    //      single-invoice prorate model.
    std::unordered_map<long long, std::string> laRegisteredAtByRegId;
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
            std::cerr << "[BoysRoster] la_registered_at load failed: " << e.what() << std::endl;
        }
    }

    // ── LA-user-id fallback map (2026-07-09) ─────────────────────────
    // Fallback when a card has no matching boys-registration row (e.g.
    // a player surfaced via pickup/paused variant program with the
    // active program row missing).  Any known la_registered_at across
    // the player's memberships is better than blank.
    std::unordered_map<std::string, std::string> laRegisteredAtByUid;
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
        std::cerr << "[BoysRoster] la_registered_at (by uid) load failed: " << e.what() << std::endl;
    }

    // ── person_payments fallback keyed by la_registration_id ─────────
    //
    // Mirrors the mens-roster payments fallback (2026-07-09 commit
    // d0d938b5) but keyed on la_registration_id instead of la_user_id.
    // Rationale: on youth registrations the paying LA user is the
    // PARENT (payer), not the CHILD (member) — so joining payments by
    // la_user_id → child's external_user_id never matches (e.g. Kaiden
    // Pressley reg 106062084: parent la_user_id 57717823 paid $1, but
    // Kaiden's alias external_user_id is 57717830).  For any boys
    // registration whose la_registered_at row is NULL (LA-reg-date
    // backfill hasn't caught up yet) the earliest la_registration_id
    // payment is a reliable registration-date proxy — LA charges the
    // $1 card-capture fee at signup, so MIN(paid_at) ≈ signup date.
    std::unordered_map<long long, std::string> laRegisteredAtByRegIdFromPayments;
    try {
        auto* db = Database::getInstance();
        pqxx::result rows = db->query(
            "SELECT la_registration_id, "
            "       TO_CHAR(MIN(paid_at) AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS reg_iso "
            "  FROM person_payments "
            " WHERE la_registration_id IS NOT NULL "
            "   AND paid_at            IS NOT NULL "
            " GROUP BY la_registration_id "
        );
        for (const auto& r : rows) {
            if (r["la_registration_id"].is_null() || r["reg_iso"].is_null()) continue;
            laRegisteredAtByRegIdFromPayments[r["la_registration_id"].as<long long>()] =
                r["reg_iso"].c_str();
        }
    } catch (const std::exception& e) {
        std::cerr << "[BoysRoster] la_registered_at (payments fallback) load failed: "
                  << e.what() << std::endl;
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
        // Final fallback: earliest LA transaction for this registration.
        // Handles newly-registered youth whose la_registered_at hasn't
        // been backfilled yet (LA charges $1 at signup → MIN(paid_at)
        // ≈ signup timestamp within seconds).
        if (id > 0) {
            auto pit = laRegisteredAtByRegIdFromPayments.find(id);
            if (pit != laRegisteredAtByRegIdFromPayments.end()) return json(pit->second);
        }
        return json(nullptr);
    };

    // ── Last PAY-reminder click per user (2026-07-06) ─────────────────
    //
    // Boys roster PAY buttons (💬 SMS + ✉ Email on each parent card)
    // POST /api/pay-reminder-log on click.  Bulk-load newest row per
    // parent la_user_id so the frontend can render "📩 SMS · 2h ago"
    // on the card.  Non-fatal on failure.
    PayReminderLog::Map lastPayReminderByUid;
    try {
        std::vector<long long> uids;
        uids.reserve(boysRecs.size() + girlsRecs.size());
        auto pushUid = [&](const json& rec) {
            auto uidVal = optUserId(rec);
            if (uidVal.is_number_integer()) uids.push_back(uidVal.get<long long>());
        };
        for (const auto& r : boysRecs)  pushUid(r);
        for (const auto& r : girlsRecs) pushUid(r);
        PayReminderLog log;
        lastPayReminderByUid = log.latestFor(uids);
    } catch (const std::exception& e) {
        std::cerr << "[BoysRoster] pay_reminder_log load failed: " << e.what() << std::endl;
    }
    auto lastPayReminderJson = [&](const std::string& uid) -> json {
        auto it = lastPayReminderByUid.find(uid);
        if (it == lastPayReminderByUid.end()) return json(nullptr);
        json j = json::object();
        j["method"] = it->second.method;
        j["sentAt"] = it->second.sentAtIso;
        return j;
    };

    const int seasonEndYear = defaultSeasonEndYear();

    // ── Pickup exclusion (2026-07-09, universal rule) ────────────────
    //
    // Owner directive: "DO NOT SHOW ANYONE NOT IN LA member(not pickup)
    // for boys girls women or men IN THE ROSSTERS IN ANY CATEGORY".
    // Applied here on /api/boys-roster.  Same filter lives on the mens
    // and youth (women) endpoints.
    std::unordered_set<std::string> pickupUids;
    try {
        auto* db = Database::getInstance();
        pqxx::result rows = db->query(
            "SELECT DISTINCT epa.external_user_id AS uid "
            "  FROM person_la_memberships plm "
            "  JOIN external_person_aliases epa "
            "    ON epa.person_id = plm.person_id "
            "   AND epa.provider  = 'leagueapps' "
            "  JOIN leagueapps_programs lp "
            "    ON lp.program_id = plm.la_program_id "
            " WHERE plm.ended_at IS NULL "
            "   AND lp.variant   = 'pickup' "
            "   AND epa.external_user_id IS NOT NULL"
        );
        for (const auto& r : rows) {
            if (!r["uid"].is_null()) pickupUids.insert(r["uid"].c_str());
        }
    } catch (const std::exception& e) {
        std::cerr << "[BoysRoster] pickup exclusion load failed: "
                  << e.what() << std::endl;
    }
    auto notPickup = [&](const json& rec) -> bool {
        const std::string u = userIdString(optUserId(rec));
        return u.empty() || !pickupUids.count(u);
    };

    std::vector<json> all;
    all.reserve(boysRecs.size() + girlsRecs.size());
    for (const auto& r : boysRecs)
        if (isActive(r, includeAll) && notPickup(r))
            all.push_back(shapePlayer(r, "boys",  seasonEndYear));
    for (const auto& r : girlsRecs)
        if (isActive(r, includeAll) && notPickup(r))
            all.push_back(shapePlayer(r, "girls", seasonEndYear));

    // ── Bucket per column (keyed by teamId-as-string) ────────────────
    std::unordered_map<std::string, std::vector<json>> buckets;
    for (const auto& c : cols) buckets[std::to_string(c.teamId)];
    std::vector<json> unassigned;

    auto findCellInUser = [](const std::vector<MensTeamAssignments::Cell>& v, int teamId)
        -> const MensTeamAssignments::Cell* {
        for (const auto& c : v) if (c.teamId == teamId) return &c;
        return nullptr;
    };

    // Attach the 3-month rolling window of payments for this player to
    // `row`.  Frontend (BillingBadge.render3MonthTable) needs
    // `paymentsWindow` as an array of {amount, paidAt, programId}.
    // Payments are joined on la_registration_id (child's registration)
    // because youth transactions are on the parent's LA account.
    auto attachPayments = [&](json& row) {
        json paymentsWindow = json::array();
        double paymentsWindowSum = 0.0;
        long long regId = 0;
        {
            const json& v = row.at("registrationId");
            if      (v.is_number_integer())          regId = v.get<long long>();
            else if (v.is_number_unsigned())         regId = static_cast<long long>(v.get<unsigned long long>());
            else if (v.is_number_float())            regId = static_cast<long long>(v.get<double>());
            else if (v.is_string()) {
                try { regId = std::stoll(v.get<std::string>()); }
                catch (...) { regId = 0; }
            }
        }
        if (regId > 0) {
            auto pit = payByReg.find(regId);
            if (pit != payByReg.end()) {
                for (const auto& bp : pit->second) {
                    if (bp.paidAt.size() < 10) continue;
                    if (bp.paidAt.substr(0, 10) < windowStartIso) continue;
                    json r = json::object();
                    r["amount"]    = bp.amount;
                    r["paidAt"]    = bp.paidAt;
                    r["programId"] = bp.programId;
                    paymentsWindow.push_back(std::move(r));
                    paymentsWindowSum += bp.amount;
                }
            }
        }
        row["paymentsWindow"]    = std::move(paymentsWindow);
        row["paymentsWindowSum"] = paymentsWindowSum;
        {
            const std::string uidStr = userIdString(row.at("leagueAppsUserId"));
            row["laRegisteredAt"] = laRegIsoFor(row.at("registrationId"), uidStr);
        }
    };

    for (auto& p : all) {
        const std::string uid = userIdString(p.at("leagueAppsUserId"));

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
            // 2026-07-08: Suppress from Unassigned when the user is
            // already on some boys/girls team, just not one with a
            // visible roster_column (e.g. an archived / sunset team).
            // Otherwise pickup-style members with only off-view team
            // assignments clutter the selection-team draft view.
            if (userCells && !userCells->empty()) continue;

            json row       = p;
            row["teamIds"] = json::array();
            attachPayments(row);
            row["lastPayReminder"] = lastPayReminderJson(uid);
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
                attachPayments(row);
                row["lastPayReminder"] = lastPayReminderJson(uid);
                buckets[std::to_string(tid)].push_back(std::move(row));
            }
        }
    }

    // ── Sort: coach rank first, then on-roster, then alpha lastName ──
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

    // ── Emit columns array + buckets object ──────────────────────────
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

    out.body["fetchedAt"]        = nowIsoMs();
    out.body["seasonEndYear"]    = seasonEndYear;
    out.body["columns"]          = std::move(columnsArr);
    out.body["buckets"]          = std::move(bucketsJson);
    out.body["unassigned"]       = std::move(unassigned);
    out.body["unassignedCount"]  = static_cast<int>(out.body["unassigned"].size());
    out.body["total"]            = static_cast<int>(all.size());
    out.body["boysProgramId"]    = boysProgramId_;
    out.body["girlsProgramId"]   = girlsProgramId_;
    return out;
}
