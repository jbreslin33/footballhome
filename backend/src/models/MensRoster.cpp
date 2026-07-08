#include "MensRoster.h"

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cmath>
#include <cstdlib>
#include <ctime>
#include <iostream>
#include <limits>
#include <pqxx/pqxx>
#include <sstream>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "MensTeamAssignments.h"
#include "MensTeamColumns.h"
#include "PersonBilling.h"
#include "PersonPayments.h"
#include "PayReminderLog.h"
#include "../database/Database.h"
#include "../services/LeagueAppsService.h"

using nlohmann::json;

namespace {

// Days between two calendar dates (today - billDate).  Positive = billDate
// is in the past (overdue).  Zero when equal.  Returns 0 on parse failure
// so a bad date never trips the dues-owed flag unfairly.
int daysBetweenTodayAnd(const std::string& iso) {
    if (iso.size() < 10) return 0;
    std::tm tm_bill{};
    if (sscanf(iso.c_str(), "%4d-%2d-%2d",
               &tm_bill.tm_year, &tm_bill.tm_mon, &tm_bill.tm_mday) != 3) return 0;
    tm_bill.tm_year -= 1900;
    tm_bill.tm_mon  -= 1;
    tm_bill.tm_hour  = 12;   // noon to avoid DST edge on the diff
    const std::time_t billT = timegm(&tm_bill);
    if (billT == (std::time_t)-1) return 0;

    const std::time_t nowT = std::time(nullptr);
    std::tm tm_now{};
    if (gmtime_r(&nowT, &tm_now) == nullptr) return 0;
    tm_now.tm_hour = 12; tm_now.tm_min = 0; tm_now.tm_sec = 0;
    const std::time_t todayT = timegm(&tm_now);

    const long long diffSec = static_cast<long long>(todayT) - static_cast<long long>(billT);
    return static_cast<int>(diffSec / 86400);
}

int envIntFn(const char* name, int fallback) {
    const char* raw = std::getenv(name);
    if (!raw || !*raw) return fallback;
    try { return std::stoi(raw); }
    catch (const std::exception&) { return fallback; }
}

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
      payments_   (std::make_unique<PersonPayments>()),
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

MensRoster::Result MensRoster::run(bool includeAll, bool refreshLa) {
    Result out;

    auto cols          = columns_->loadAll();
    auto assignmentMap = assignments_->loadAll();
    auto billingMap    = billing_->loadAll();

    if (cols.empty()) {
        out.noColumns = true;
        out.error = "No roster_columns configured for domain='mens'.  Seed the table to enable bucketing.";
        return out;
    }

    // ── LA registrant snapshot (cached) ──────────────────────────────
    //
    // Historically every GET /api/mens-roster hit LeagueApps twice
    // (fetchProgramRegistrations + syncFromLa).  A transient LA 5xx
    // would break the whole page — including the redraw after a
    // move-player action, which does NOT need fresh LA data.  So we
    // now keep an in-memory snapshot on the singleton model and only
    // refetch when the caller explicitly asks for it (initial screen
    // load or the "Refresh" button in the UI).
    std::vector<nlohmann::json> recs;
    {
        std::lock_guard<std::mutex> lk(cacheMutex_);
        const bool needFetch = refreshLa || !cacheValid_;
        if (needFetch) {
            try {
                cachedRecs_ = LeagueAppsService::getInstance()
                                  .fetchProgramRegistrations(mensProgramId_);
                cacheValid_ = true;
                // Payment sync piggy-backs on refresh so the cards reflect
                // the freshest transactions when the operator clicks
                // Refresh.  Sync failure is non-fatal.
                try {
                    payments_->syncFromLa();
                } catch (const std::exception& e) {
                    std::cerr << "[MensRoster] payment sync failed: "
                              << e.what() << std::endl;
                }
            } catch (const std::exception& e) {
                if (cacheValid_) {
                    // Warm cache — degrade gracefully, log and reuse.
                    std::cerr << "[MensRoster] LA refresh failed, serving "
                                 "cached snapshot: " << e.what() << std::endl;
                } else {
                    // No cache yet — propagate to the controller which
                    // will surface a 502 to the browser.
                    throw;
                }
            }
        }
        recs = cachedRecs_;
    }
    auto lastPaidByReg = payments_->loadLastPositiveByProgramByRegistration(mensProgramId_);
    auto recentByReg   = payments_->loadRecentByProgramByRegistration(mensProgramId_, 3);

    // ── Cross-program payment view (2026-07-04 pm) ───────────────────
    //
    // Business rule (per user directive on Andy Hizdri): a player who
    // paid a lump sum into a *related* soccer program is current for as
    // many months as that lump paid for.  Andy's $99 (2026-05-29) to
    // la_program_id=5005948 (the legacy "Lighthouse 1893 Soccer Club
    // Membership" umbrella) covers ~3 months at the $35 monthly rate,
    // so he's paid through late-August 2026.  Ali's $35 into 5039300
    // (2026-07-04) covers ~1 month.  Programs considered: the current
    // mens program + the legacy membership umbrella (env-overridable via
    // LEAGUEAPPS_MENS_PAYMENT_PROGRAM_IDS, comma-separated).
    struct CrossPay {
        double      amount = 0.0;
        std::string paidAt;   // ISO8601 UTC
        long long   programId = 0;
    };
    std::unordered_map<long long, CrossPay> lastPayByUser;      // for coverage check
    std::unordered_map<long long, std::vector<CrossPay>> allPayByUser;  // for card display
    {
        std::vector<std::string> programIds;
        if (const char* raw = std::getenv("LEAGUEAPPS_MENS_PAYMENT_PROGRAM_IDS"); raw && *raw) {
            std::stringstream ss(raw);
            std::string tok;
            while (std::getline(ss, tok, ',')) if (!tok.empty()) programIds.push_back(tok);
        }
        if (programIds.empty()) {
            programIds.push_back(std::to_string(mensProgramId_));
            programIds.push_back("5005948");  // legacy "Lighthouse 1893 Soccer Club Membership"
        }
        std::string inList;
        for (size_t i = 0; i < programIds.size(); ++i) {
            if (i) inList += ",";
            inList += "$" + std::to_string(i + 1);
        }
        try {
            auto* db = Database::getInstance();
            pqxx::result rows = db->query(
                "SELECT la_user_id, amount, la_program_id, "
                "       TO_CHAR(paid_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS paid_iso "
                "  FROM person_payments "
                " WHERE la_program_id IN (" + inList + ") "
                "   AND txn_type IN ('Charge','Bank','Offline Payment') "
                "   AND amount > 0 "
                " ORDER BY la_user_id, paid_at DESC",
                programIds
            );
            for (const auto& r : rows) {
                if (r["la_user_id"].is_null()) continue;
                CrossPay cp;
                cp.amount    = r["amount"].is_null() ? 0.0 : r["amount"].as<double>();
                cp.paidAt    = r["paid_iso"].is_null() ? std::string{} : r["paid_iso"].c_str();
                cp.programId = r["la_program_id"].is_null() ? 0 : r["la_program_id"].as<long long>();
                const long long uid = r["la_user_id"].as<long long>();
                allPayByUser[uid].push_back(cp);
                // Row order is paid_at DESC per user → first hit wins.
                lastPayByUser.emplace(uid, std::move(cp));
            }
        } catch (const std::exception& e) {
            std::cerr << "[MensRoster] cross-program payment load failed: " << e.what() << std::endl;
        }
    }

    // ── LA registration timestamp load (2026-07-06) ──────────────────
    //
    // Emitted as `laRegisteredAt` on every row so the frontend can:
    //   1) Show "Reg: MMM D, YYYY" on the roster card (all clubs).
    //   2) Decide whether to render the projected-prorate cell.
    //      Per user directive: only players registered on/after
    //      2026-07-06 use the new single-invoice prorate model.  For
    //      everyone else the old model (late-June carry-in / manual LA
    //      invoicing) applies — no prorate projection.
    //
    // Keyed by la_registration_id, which matches the `registrationId`
    // already on each shaped player row.
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
            std::cerr << "[MensRoster] la_registered_at load failed: " << e.what() << std::endl;
        }
    }
    auto laRegIsoFor = [&](const json& regJson) -> json {
        long long id = 0;
        if      (regJson.is_number_integer())  id = regJson.get<long long>();
        else if (regJson.is_number_unsigned()) id = static_cast<long long>(regJson.get<unsigned long long>());
        else if (regJson.is_number_float())    id = static_cast<long long>(regJson.get<double>());
        else if (regJson.is_string()) {
            try { id = std::stoll(regJson.get<std::string>()); }
            catch (...) { id = 0; }
        }
        if (id <= 0) return json(nullptr);
        auto it = laRegisteredAtByRegId.find(id);
        if (it == laRegisteredAtByRegId.end()) return json(nullptr);
        return json(it->second);
    };

    // ── person_id per la_registration_id (2026-07-06) ─────────────────
    //
    // Needed so each roster row carries the FH `persons.id` — the
    // frontend JOIN buttons POST that to /api/auth/magic-link/mint, and
    // the FH-activity pill looks up `sessions.last_used_at` against it.
    //
    // Single query; failure is non-fatal (rows just get personId=null).
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
        std::cerr << "[MensRoster] person_id load failed: " << e.what() << std::endl;
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

    // ── FH last activity per person (sessions.last_used_at, 2026-07-06) ─
    //
    // SessionService bumps `sessions.last_used_at` on every
    // authenticated request (see SessionService::requireSession),
    // so MAX(last_used_at) per person is the natural signal for
    // "when did this player last do anything on footballhome.org".
    //
    // Bulk-load once for the whole roster and emit as `fhLastActivityAt`
    // (ISO string) or null when the player has never signed in.
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
            fhLastActivityByPerson[r["person_id"].as<long long>()] =
                r["last_iso"].c_str();
        }
    } catch (const std::exception& e) {
        std::cerr << "[MensRoster] fh_last_activity load failed: " << e.what() << std::endl;
    }
    auto fhLastActivityFor = [&](long long personId) -> json {
        if (personId <= 0) return json(nullptr);
        auto it = fhLastActivityByPerson.find(personId);
        if (it == fhLastActivityByPerson.end()) return json(nullptr);
        return json(it->second);
    };

    // ── Last PAY-reminder click per user (2026-07-06) ─────────────────
    //
    // The Mens/Boys roster PAY buttons (💬 SMS + ✉ Email) POST to
    // /api/pay-reminder-log on click.  For each roster fetch we look up
    // the newest row per la_user_id so the frontend can render
    // "📩 SMS · 2h ago" on the card.  Bulk single-query load; failure
    // is non-fatal (roster still renders, pill just doesn't show).
    PayReminderLog::Map lastPayReminderByUid;
    try {
        std::vector<long long> uids;
        uids.reserve(recs.size());
        for (const auto& r : recs) {
            auto uidVal = optUserId(r);
            if (uidVal.is_number_integer()) uids.push_back(uidVal.get<long long>());
        }
        PayReminderLog log;
        lastPayReminderByUid = log.latestFor(uids);
    } catch (const std::exception& e) {
        std::cerr << "[MensRoster] pay_reminder_log load failed: " << e.what() << std::endl;
    }
    auto lastPayReminderJson = [&](const std::string& uid) -> json {
        auto it = lastPayReminderByUid.find(uid);
        if (it == lastPayReminderByUid.end()) return json(nullptr);
        json j = json::object();
        j["method"] = it->second.method;
        j["sentAt"] = it->second.sentAtIso;
        return j;
    };

    std::vector<json> all;
    all.reserve(recs.size());
    for (const auto& r : recs) {
        if (isActive(r, includeAll)) all.push_back(shapeMensPlayer(r));
    }

    // ── Union in mens-team members NOT in the mens LA program (2026-07-07) ─
    //
    // Adult League (team 122) and pickup-only members are registered
    // only in OTHER LA programs (e.g. 5039252 "1897 Membership" or
    // 5070075 "Men's Club Pickup Membership"), so they never appear in
    // `recs` (the mens program 5039300 registrations).  Before
    // migration 107 they were invisible on the mens board — the Adult
    // column was permanently empty.  Now that assignmentMap comes from
    // v_team_members, we synthesize minimal shapeMensPlayer rows from
    // persons + external_person_aliases for any assigned uid missing
    // from `all`.  LA-only fields (paymentStatus, outstandingBalance,
    // registrationStatus, jersey*) are null on these rows; they render
    // as no-payment-badge cards on the board.
    std::unordered_map<std::string, long long> personIdByUid;  // fallback for personIdFor
    {
        std::unordered_set<std::string> haveUid;
        haveUid.reserve(all.size());
        for (const auto& p : all) {
            const std::string u = userIdString(p.at("leagueAppsUserId"));
            if (!u.empty()) haveUid.insert(u);
        }
        std::vector<std::string> missingUids;
        missingUids.reserve(assignmentMap.size());
        for (const auto& kv : assignmentMap) {
            const std::string& uid = kv.first;
            if (uid.empty() || haveUid.count(uid)) continue;
            // Guard: uid must be all digits (comes from bigint column, but
            // belt-and-suspenders since we splice it into a text[] literal).
            bool ok = !uid.empty();
            for (char c : uid) { if (c < '0' || c > '9') { ok = false; break; } }
            if (ok) missingUids.push_back(uid);
        }
        if (!missingUids.empty()) {
            try {
                std::string arrLit = "{";
                for (size_t i = 0; i < missingUids.size(); ++i) {
                    if (i) arrLit += ",";
                    arrLit += missingUids[i];
                }
                arrLit += "}";
                auto* db = Database::getInstance();
                pqxx::result rows = db->query(
                    "SELECT epa.external_user_id AS uid, "
                    "       p.id                 AS person_id, "
                    "       p.first_name, p.last_name, "
                    "       TO_CHAR(p.birth_date, 'YYYY-MM-DD') AS birth_date_iso, "
                    "       (SELECT email FROM person_emails "
                    "         WHERE person_id = p.id "
                    "         ORDER BY is_primary DESC, id ASC LIMIT 1) AS email, "
                    "       (SELECT phone_number FROM person_phones "
                    "         WHERE person_id = p.id "
                    "         ORDER BY is_primary DESC, id ASC LIMIT 1) AS phone "
                    "  FROM external_person_aliases epa "
                    "  JOIN persons p ON p.id = epa.person_id "
                    " WHERE epa.provider = 'leagueapps' "
                    "   AND epa.external_user_id = ANY($1::text[])",
                    {arrLit});
                for (const auto& r : rows) {
                    if (r["uid"].is_null()) continue;
                    const std::string uid = r["uid"].c_str();
                    json p = json::object();
                    p["registrationId"] = nullptr;
                    try { p["leagueAppsUserId"] = std::stoll(uid); }
                    catch (...) { p["leagueAppsUserId"] = uid; }
                    const std::string fn = r["first_name"].is_null() ? "" : r["first_name"].as<std::string>();
                    const std::string ln = r["last_name"].is_null()  ? "" : r["last_name"].as<std::string>();
                    p["firstName"] = fn;
                    p["lastName"]  = ln;
                    p["fullName"]  = trim(fn + " " + ln);
                    if (!r["birth_date_iso"].is_null()) {
                        const std::string bd = r["birth_date_iso"].as<std::string>();
                        p["birthDate"] = bd;
                        try { p["birthYear"] = std::stoi(bd.substr(0, 4)); }
                        catch (...) { p["birthYear"] = nullptr; }
                    } else {
                        p["birthDate"] = nullptr;
                        p["birthYear"] = nullptr;
                    }
                    p["gender"]             = "Male";
                    p["email"]              = r["email"].is_null() ? json(nullptr) : json(r["email"].as<std::string>());
                    p["phone"]              = r["phone"].is_null() ? json(nullptr) : json(r["phone"].as<std::string>());
                    p["paymentStatus"]      = nullptr;
                    p["outstandingBalance"] = 0;
                    p["registrationStatus"] = nullptr;
                    p["role"]               = nullptr;
                    p["season"]             = nullptr;
                    p["jerseyNumber"]       = nullptr;
                    p["jerseySize"]         = nullptr;
                    if (!r["person_id"].is_null()) {
                        personIdByUid[uid] = r["person_id"].as<long long>();
                    }
                    all.push_back(std::move(p));
                }
            } catch (const std::exception& e) {
                std::cerr << "[MensRoster] union-in v_team_members query failed: "
                          << e.what() << std::endl;
            }
        }
    }

    // ── Delinquency computation (2026-07-04) ─────────────────────────
    // Reads DUES_OWED_HOLD_DAYS (default 7).  For each active player:
    // daysOverdue = today - nextBillDate.  delinquencyState='dues_owed'
    // when daysOverdue >= threshold; 'ok' otherwise.  The auto
    // soft-delete + restore sweep was DISABLED per user directive
    // 2026-07-04 pm — see the block further down.
    const int holdDays = envIntFn("DUES_OWED_HOLD_DAYS", 7);

    // Precompute the current calendar month prefix (YYYY-MM) and the
    // "3-month rolling window start" (first of month-2), both used by
    // the payment-window override in the delinquency loop and again by
    // the row-assembly loop further down.
    std::string thisMonthPrefix;   // e.g. "2026-07"
    std::string windowStartIso;    // e.g. "2026-05-01"
    {
        std::time_t nowT = std::time(nullptr);
        std::tm tm{};
        gmtime_r(&nowT, &tm);
        int y = tm.tm_year + 1900;
        int m = tm.tm_mon + 1;
        char buf[16];
        std::snprintf(buf, sizeof(buf), "%04d-%02d", y, m);
        thisMonthPrefix = buf;
        int wm = m - 2;
        int wy = y;
        while (wm < 1) { wm += 12; --wy; }
        std::snprintf(buf, sizeof(buf), "%04d-%02d-01", wy, wm);
        windowStartIso = buf;
    }

    struct PlayerDelinquency {
        int  daysOverdue = 0;
        bool duesOwed    = false;
        std::string nextBillDate;
        bool   hasBalance = false;
        double balance    = 0.0;
    };
    std::unordered_map<std::string, PlayerDelinquency> delinqByUid;

    for (auto& p : all) {
        const std::string uid = userIdString(p.at("leagueAppsUserId"));
        if (uid.empty()) continue;
        const auto bill = PersonBilling::resolve(billingMap, uid);

        PlayerDelinquency d;
        d.daysOverdue  = daysBetweenTodayAnd(bill.nextBillDate);
        d.nextBillDate = bill.nextBillDate;

        // ── Payment-window override (2026-07-04 pm, revised) ─────────
        //
        // Business rule per user directive: the **$99 payment is a
        // one-time anomaly** (some players pre-paid the May/June/July
        // triple at $99 through the legacy membership program).  Rules:
        //   • Any $99 charge on record → covered for May, June, July.
        //     Next bill is $35 on the 1st Friday of August (2026-08-07).
        //   • Total ≥ $35 charged in the current calendar month →
        //     covered for the current month.  Split payments count
        //     (e.g. $1 card verification + $34 dues on same day —
        //     Kay Asante 2026-07-08).  Next bill = 1st of next month.
        //   • Otherwise fall through to person_billing.next_bill_date.
        //
        // Payments across ALL related programs count (see the cross-
        // program load above — mens program + legacy membership umbrella
        // + anything env-added).
        long long uidLL0 = 0;
        try { uidLL0 = std::stoll(uid); } catch (...) { uidLL0 = 0; }
        if (uidLL0 > 0) {
            auto ait = allPayByUser.find(uidLL0);
            if (ait != allPayByUser.end()) {
                bool   has99 = false;
                double thisMonthSum = 0.0;
                for (const auto& cp : ait->second) {
                    if (cp.paidAt.size() < 10) continue;
                    if (cp.amount >= 99.0 - 0.005) has99 = true;
                    if (cp.paidAt.substr(0, 7) == thisMonthPrefix) {
                        thisMonthSum += cp.amount;
                    }
                }
                const bool has35ThisMonth = (thisMonthSum >= 35.0 - 0.005);
                if (has99) {
                    d.daysOverdue = 0;
                    d.nextBillDate = "2026-08-07";  // 1st Friday of Aug 2026
                } else if (has35ThisMonth) {
                    d.daysOverdue = 0;
                    // Next bill = 1st of next month.
                    int y = std::stoi(thisMonthPrefix.substr(0, 4));
                    int m = std::stoi(thisMonthPrefix.substr(5, 2)) + 1;
                    while (m > 12) { m -= 12; ++y; }
                    char buf[16]; std::snprintf(buf, sizeof(buf), "%04d-%02d-01", y, m);
                    d.nextBillDate = buf;
                }
            }
        }

        auto obIt = p.find("outstandingBalance");
        if (obIt != p.end() && !obIt->is_null()) {
            if (obIt->is_number()) {
                d.hasBalance = true;
                d.balance = obIt->get<double>();
            }
        }

        // Dues-owed triggers on time-past-due alone.  outstandingBalance
        // is emitted for observability but does NOT gate the flag — LA's
        // balance number lags after payment and we don't want to hold
        // players as dues-owed after they've paid.  admin bumps
        // nextBillDate via /api/person-billing/mark-billed → daysOverdue
        // goes negative → state flips to ok on the next roster fetch.
        d.duesOwed = (d.daysOverdue >= holdDays);
        delinqByUid.emplace(uid, d);
    }

    // ── Auto-purge sweep + Dues Owed sin-bin RETIRED (2026-07-07) ─────
    //
    // History:
    //   • 2026-07-04 am: 7+ days overdue → auto soft-delete from every
    //     team; auto-restore on payment.
    //   • 2026-07-04 pm ("don't auto manage it"): sweep disabled, admin
    //     drove placement via a Dues Owed column (team 910).
    //   • 2026-07-07 (migration 100): Dues Owed column archived entirely.
    //     OVERDUE chip on cards + /mens-delinquent screen surface who
    //     owes dues without parking bodies in a sin-bin.
    //
    // delinquencyState + daysOverdue are still emitted per-player below
    // (via delinqByUid) so the chip + /#my banner + delinquent screen
    // keep working.  If we ever want auto-management back, resurrect
    // MensTeamAssignments::bulk{SoftDeleteForDelinquent,RestoreForDelinquent}
    // behind a feature flag.

    // ── Practice / Pickup membership (2026-07-07, migration 107) ───────
    //
    // Practice (908) and Pickup (909) are UNION teams: their membership
    // is derived from APSL + Liga 1 + Liga 2 + Adult League via
    // team_roster_sources + the v_team_members view.  No backfill runs
    // here anymore.  MensTeamAssignments::loadAll() already reads from
    // v_team_members, so 908/909 cells surface on every user with a
    // home-team assignment without any stored duplicate rows.
    //
    // Pickup-only members (LA program 5070075) still live as direct
    // roster_assignments rows on team 909; the view aggregates both.

    // Bucket per column (keyed by teamId-as-string).
    std::unordered_map<std::string, std::vector<json>> buckets;
    for (const auto& c : cols) buckets[std::to_string(c.teamId)];
    std::vector<json> unassigned;

    // (`windowStartIso` computed earlier — first day of month N-2 — is
    // used below to filter each player's payment history to the current
    // + previous 2 calendar months.)

    auto findCellInUser = [](const std::vector<MensTeamAssignments::Cell>& v, int teamId)
        -> const MensTeamAssignments::Cell* {
        for (const auto& c : v) if (c.teamId == teamId) return &c;
        return nullptr;
    };

    for (auto& p : all) {
        const std::string uid = userIdString(p.at("leagueAppsUserId"));
        const auto bill = PersonBilling::resolve(billingMap, uid);

        // lastPaid pill data — sourced from person_payments (synced above).
        // Joined by registrationId (the transaction's registration-id is
        // the reliable link even when the paying account differs from the
        // player account).
        json lastPaidAmount = nullptr;
        json lastPaidAt     = nullptr;
        json lastPaidType   = nullptr;
        json lastPayments   = json::array();
        std::string regKey;
        if (p.at("registrationId").is_number_integer())      regKey = std::to_string(p.at("registrationId").get<long long>());
        else if (p.at("registrationId").is_number_unsigned()) regKey = std::to_string(p.at("registrationId").get<unsigned long long>());
        else if (p.at("registrationId").is_string())          regKey = p.at("registrationId").get<std::string>();
        if (!regKey.empty()) {
            if (auto pit = lastPaidByReg.find(regKey); pit != lastPaidByReg.end()) {
                lastPaidAmount = jsNumber(pit->second.amount);
                lastPaidAt     = pit->second.paidAt.empty() ? json(nullptr) : json(pit->second.paidAt);
                lastPaidType   = pit->second.txnType.empty() ? json(nullptr) : json(pit->second.txnType);
            }
            if (auto rit = recentByReg.find(regKey); rit != recentByReg.end()) {
                for (const auto& lp : rit->second) {
                    json row = json::object();
                    row["amount"]  = jsNumber(lp.amount);
                    row["paidAt"]  = lp.paidAt.empty()  ? json(nullptr) : json(lp.paidAt);
                    row["txnType"] = lp.txnType.empty() ? json(nullptr) : json(lp.txnType);
                    lastPayments.push_back(std::move(row));
                }
            }
        }

        // 3-month rolling window of every successful payment for this
        // player across all related programs (sorted newest-first from
        // the cross-program load).  Card renders line items + total.
        json paymentsWindow      = json::array();
        double paymentsWindowSum = 0.0;
        {
            long long uidLL = 0;
            try { uidLL = std::stoll(uid); } catch (...) { uidLL = 0; }
            if (uidLL > 0) {
                auto ait = allPayByUser.find(uidLL);
                if (ait != allPayByUser.end()) {
                    for (const auto& cp : ait->second) {
                        if (cp.paidAt.size() < 10) continue;
                        if (cp.paidAt.substr(0, 10) < windowStartIso) continue;  // outside window
                        json row = json::object();
                        row["amount"]    = jsNumber(cp.amount);
                        row["paidAt"]    = cp.paidAt;
                        row["programId"] = cp.programId;
                        paymentsWindow.push_back(std::move(row));
                        paymentsWindowSum += cp.amount;
                    }
                }
            }
        }

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

        // Delinquency state resolved earlier — attach to every row so the
        // frontend can render the days-overdue counter + dues-owed badge.
        int         daysOverdueOut = 0;
        std::string stateOut       = "ok";
        auto dqIt = delinqByUid.find(uid);
        if (dqIt != delinqByUid.end()) {
            daysOverdueOut = dqIt->second.daysOverdue;
            stateOut       = dqIt->second.duesOwed ? "dues_owed" : "ok";
        }

        if (relevant.empty()) {
            // 2026-07-08: Suppress from Unassigned when the user is
            // already on some mens team, just not one with a visible
            // roster_column (e.g. Pickup 909, Practice 908, or a
            // sunset selection team).  Otherwise pickup-only members
            // clutter the selection-team draft view.  If the user has
            // zero mens assignments at all, they stay in Unassigned so
            // admin can drag them onto a selection team.
            if (userCells && !userCells->empty()) continue;

            json row             = p;
            row["teamIds"]       = json::array();
            row["nextBillDate"]  = bill.nextBillDate.empty() ? json(nullptr) : json(bill.nextBillDate);
            row["nextBillAmount"] = jsNumber(bill.nextBillAmount);
            row["isDefault"]     = bill.isDefault;
            row["lastPaidAmount"] = lastPaidAmount;
            row["lastPaidAt"]     = lastPaidAt;
            row["lastPaidType"]   = lastPaidType;
            row["lastPayments"]   = lastPayments;
            row["paymentsWindow"]      = paymentsWindow;
            row["paymentsWindowTotal"] = jsNumber(paymentsWindowSum);
            row["paymentsWindowStart"] = windowStartIso;
            row["daysOverdue"]    = daysOverdueOut;
            row["delinquencyState"] = stateOut;
            row["laRegisteredAt"] = laRegIsoFor(p.at("registrationId"));
            row["lastPayReminder"] = lastPayReminderJson(uid);
            {
                long long pid = personIdFor(p.at("registrationId"));
                if (pid <= 0) {
                    // Synthesized union row (not in mens LA program) —
                    // fall back to the uid→person_id map built during
                    // the union-in step above.
                    auto pit = personIdByUid.find(uid);
                    if (pit != personIdByUid.end()) pid = pit->second;
                }
                row["personId"] = pid > 0 ? json(pid) : json(nullptr);
                row["fhLastActivityAt"] = fhLastActivityFor(pid);
            }
            unassigned.push_back(std::move(row));
        } else {
            for (int tid : relevant) {
                const auto* cell = findCellInUser(*userCells, tid);
                json row             = p;
                row["teamIds"]       = relevant;
                row["onRoster"]      = cell ? cell->onRoster : false;
                row["coachSortOrder"] = (cell && cell->coachSortOrder)
                    ? json(*cell->coachSortOrder)
                    : json(nullptr);
                row["nextBillDate"]  = bill.nextBillDate.empty() ? json(nullptr) : json(bill.nextBillDate);
                row["nextBillAmount"] = jsNumber(bill.nextBillAmount);
                row["isDefault"]     = bill.isDefault;
                row["lastPaidAmount"] = lastPaidAmount;
                row["lastPaidAt"]     = lastPaidAt;
                row["lastPaidType"]   = lastPaidType;
                row["lastPayments"]   = lastPayments;
                row["paymentsWindow"]      = paymentsWindow;
                row["paymentsWindowTotal"] = jsNumber(paymentsWindowSum);
                row["paymentsWindowStart"] = windowStartIso;
                row["daysOverdue"]    = daysOverdueOut;
                row["delinquencyState"] = stateOut;
                row["laRegisteredAt"] = laRegIsoFor(p.at("registrationId"));
                row["lastPayReminder"] = lastPayReminderJson(uid);
                {
                    long long pid = personIdFor(p.at("registrationId"));
                    if (pid <= 0) {
                        auto pit = personIdByUid.find(uid);
                        if (pit != personIdByUid.end()) pid = pit->second;
                    }
                    row["personId"] = pid > 0 ? json(pid) : json(nullptr);
                    row["fhLastActivityAt"] = fhLastActivityFor(pid);
                }
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
        // Coach-defined ability rank wins over everything else.  NULL
        // coachSortOrder falls to INT_MAX so unranked players slide
        // below every ranked one (2026-07-04 pm, migration 089).
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

    // Aggregate delinquency summary (2026-07-04).  Emits threshold days
    // so the frontend renders the color scale with the same anchor the
    // backend used, and per-player counts so the delinquent tile can
    // show a badge count without walking every bucket.
    int duesOwedCount = 0;
    int overdueCount  = 0;
    for (const auto& kv : delinqByUid) {
        if (kv.second.duesOwed) ++duesOwedCount;
        if (kv.second.daysOverdue > 0) ++overdueCount;
    }
    json delinq;
    delinq["holdDays"]      = holdDays;
    delinq["duesOwedCount"] = duesOwedCount;
    delinq["overdueCount"]  = overdueCount;
    // Auto-sweep disabled 2026-07-04 pm — always 0.  Kept in the response
    // shape for backward compatibility with any clients still reading it.
    delinq["heldThisFetch"]     = 0;
    delinq["restoredThisFetch"] = 0;
    out.body["delinquency"] = std::move(delinq);
    return out;
}
