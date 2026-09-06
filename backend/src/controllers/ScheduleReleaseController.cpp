#include "ScheduleReleaseController.h"

#include <algorithm>
#include <cctype>
#include <iostream>
#include <regex>
#include <string>

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

const char* kIsoUtc = "YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"";
const std::vector<std::string> kAdminLevels = {"club", "super"};

Response jsonResp(HttpStatus status, const json& body) {
    return Response(status, body.dump());
}
Response jsonErr(HttpStatus status, const std::string& msg) {
    return jsonResp(status, json{{"error", msg}});
}

// users.id from the bearer JWT ("userId" claim, a string).  0 if absent.
long long userIdFromRequest(const Request& request) {
    const std::string authHeader = request.getHeader("Authorization");
    if (authHeader.size() <= 7 || authHeader.substr(0, 7) != "Bearer ") return 0;
    std::string payload;
    if (!fh::crypto::verifyJwtHS256(authHeader.substr(7), &payload)) return 0;
    static const std::regex re("\"userId\":\"?([0-9]+)\"?");
    std::smatch m;
    if (!std::regex_search(payload, m, re)) return 0;
    try { return std::stoll(m[1].str()); } catch (...) { return 0; }
}

bool isIsoDate(const std::string& s) {
    static const std::regex re("^[0-9]{4}-[0-9]{2}-[0-9]{2}$");
    return std::regex_match(s, re);
}
bool isHHMM(const std::string& s) {
    static const std::regex re("^([01][0-9]|2[0-3]):[0-5][0-9]$");
    return std::regex_match(s, re);
}

// The one club this deployment serves, unless the caller names one.
std::string resolveClubId(Database* db, const std::string& requested) {
    if (!requested.empty()) return requested;
    auto r = db->query(
        "SELECT club_id FROM teams WHERE is_active AND club_id IS NOT NULL "
        " GROUP BY club_id ORDER BY COUNT(*) DESC LIMIT 1");
    if (r.empty()) return "";
    return r[0]["club_id"].as<std::string>();
}

std::string strOrEmpty(const json& j, const char* key) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null()) return {};
    if (it->is_string()) return it->get<std::string>();
    if (it->is_number_integer()) return std::to_string(it->get<long long>());
    return {};
}

const char* kWeekdayNames[] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};

json rowToRelease(const pqxx::row& r) {
    json j;
    j["id"]          = r["id"].as<long long>();
    j["club_id"]     = r["club_id"].as<int>();
    j["section_id"]  = r["club_section_id"].is_null() ? json(nullptr) : json(r["club_section_id"].as<int>());
    j["week_start"]  = r["week_start"].c_str();
    j["released_at"] = r["released_at_iso"].c_str();
    j["released_by"] = r["released_by"].is_null() ? json(nullptr) : json(r["released_by"].c_str());
    j["revoked_at"]  = r["revoked_at_iso"].is_null() ? json(nullptr) : json(r["revoked_at_iso"].c_str());
    j["revoked_by"]  = r["revoked_by"].is_null() ? json(nullptr) : json(r["revoked_by"].c_str());
    j["note"]        = r["note"].is_null() ? json(nullptr) : json(r["note"].c_str());
    return j;
}

const char* kReleaseSelect =
    "SELECT r.id, r.club_id, r.club_section_id, r.week_start::text AS week_start, r.note, "
    "       to_char(r.released_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS released_at_iso, "
    "       to_char(r.revoked_at  AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS revoked_at_iso, "
    "       (SELECT p.first_name || ' ' || p.last_name FROM users u JOIN persons p ON p.id = u.person_id "
    "         WHERE u.id = r.released_by_user_id) AS released_by, "
    "       (SELECT p.first_name || ' ' || p.last_name FROM users u JOIN persons p ON p.id = u.person_id "
    "         WHERE u.id = r.revoked_by_user_id) AS revoked_by "
    "  FROM schedule_week_releases r ";

}  // namespace

ScheduleReleaseController::ScheduleReleaseController() = default;
ScheduleReleaseController::~ScheduleReleaseController() = default;

void ScheduleReleaseController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/window",               [this](const Request& r) { return this->handleWindow(r); });
    router.get (prefix + "/releases",             [this](const Request& r) { return this->handleListReleases(r); });
    router.post(prefix + "/releases",             [this](const Request& r) { return this->handleCreateRelease(r); });
    router.post(prefix + "/releases/:id/revoke",  [this](const Request& r) { return this->handleRevokeRelease(r); });
    router.put (prefix + "/policy",               [this](const Request& r) { return this->handlePutPolicy(r); });
}

// GET /api/schedule/window
Response ScheduleReleaseController::handleWindow(const Request& request) {
    const std::string weekStart = request.getQueryParam("week_start");
    if (!isIsoDate(weekStart)) return jsonErr(HttpStatus::BAD_REQUEST, "week_start (YYYY-MM-DD, a Monday) required");
    try {
        auto* db = Database::getInstance();
        const std::string clubId = resolveClubId(db, request.getQueryParam("club_id"));
        if (clubId.empty()) return jsonErr(HttpStatus::NOT_FOUND, "no club");
        const std::string sectionId = request.getQueryParam("section_id");

        auto rows = db->query(
            "WITH pol AS (SELECT * FROM fh_schedule_policy($1::int, $2::int, now()) WHERE id IS NOT NULL) "
            "SELECT $3::date AS week_start, "
            "       EXTRACT(ISODOW FROM $3::date)::int AS isodow, "
            "       (SELECT cutover_weekday FROM pol) AS weekday, "
            "       (SELECT to_char(cutover_time, 'HH24:MI') FROM pol) AS cutover_time, "
            "       (SELECT to_char(cutover_time, 'FMHH12:MI AM') FROM pol) AS cutover_time_label, "
            "       (SELECT time_zone FROM pol) AS time_zone, "
            "       (SELECT club_section_id FROM pol) AS policy_section_id, "
            "       to_char(fh_schedule_policy_opens_at($1::int, $2::int, $3::date) AT TIME ZONE 'UTC', $4) AS policy_opens_at, "
            "       to_char(fh_schedule_week_opens_at($1::int, $2::int, $3::date)   AT TIME ZONE 'UTC', $4) AS opens_at, "
            "       COALESCE(fh_schedule_week_opens_at($1::int, $2::int, $3::date) <= now(), false) AS open_now, "
            "       to_char(fh_schedule_window_end($1::int, $2::int, now()) AT TIME ZONE 'UTC', $4) AS window_end, "
            "       (SELECT id FROM fh_schedule_week_release($1::int, $2::int, $3::date) WHERE id IS NOT NULL) AS release_id",
            {clubId, sectionId.empty() ? std::string("0") : sectionId, weekStart, kIsoUtc});
        if (rows.empty()) return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR, "window query returned nothing");
        const auto& r = rows[0];
        if (r["isodow"].as<int>() != 1) return jsonErr(HttpStatus::BAD_REQUEST, "week_start must be a Monday");

        json out;
        out["club_id"]    = std::stoi(clubId);
        out["section_id"] = sectionId.empty() ? json(nullptr) : json(std::stoi(sectionId));
        out["week_start"] = weekStart;
        if (r["weekday"].is_null()) {
            out["policy"] = nullptr;
        } else {
            const int wd = r["weekday"].as<int>();
            out["policy"] = {
                {"weekday",    wd},
                {"time",       r["cutover_time"].c_str()},
                {"time_zone",  r["time_zone"].c_str()},
                {"section_id", r["policy_section_id"].is_null() ? json(nullptr) : json(r["policy_section_id"].as<int>())},
                {"label",      std::string(kWeekdayNames[wd]) + " " + r["cutover_time_label"].c_str()},
            };
        }
        out["policy_opens_at"] = r["policy_opens_at"].is_null() ? json(nullptr) : json(r["policy_opens_at"].c_str());
        out["opens_at"]        = r["opens_at"].is_null()        ? json(nullptr) : json(r["opens_at"].c_str());
        out["open_now"]        = r["open_now"].as<bool>();
        out["window_end"]      = r["window_end"].c_str();
        out["release"]         = nullptr;
        if (!r["release_id"].is_null()) {
            auto rel = db->query(std::string(kReleaseSelect) + " WHERE r.id = $1::int", {r["release_id"].as<std::string>()});
            if (!rel.empty()) out["release"] = rowToRelease(rel[0]);
        }
        return jsonResp(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "[ScheduleRelease] window failed: " << e.what() << std::endl;
        return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR, "window lookup failed");
    }
}

// GET /api/schedule/releases
Response ScheduleReleaseController::handleListReleases(const Request& request) {
    if (!requireAdminLevel(request, kAdminLevels)) return jsonErr(HttpStatus::FORBIDDEN, "admin only");
    try {
        auto* db = Database::getInstance();
        const std::string clubId = resolveClubId(db, request.getQueryParam("club_id"));
        auto rows = db->query(std::string(kReleaseSelect) +
            " WHERE r.club_id = $1::int ORDER BY r.week_start DESC, r.id DESC LIMIT 50", {clubId});
        json list = json::array();
        for (const auto& r : rows) list.push_back(rowToRelease(r));
        return jsonResp(HttpStatus::OK, json{{"releases", list}});
    } catch (const std::exception& e) {
        std::cerr << "[ScheduleRelease] list failed: " << e.what() << std::endl;
        return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR, "list failed");
    }
}

// POST /api/schedule/releases — open a week now.
Response ScheduleReleaseController::handleCreateRelease(const Request& request) {
    if (!requireAdminLevel(request, kAdminLevels)) return jsonErr(HttpStatus::FORBIDDEN, "admin only");
    json body;
    try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); }
    catch (const std::exception& e) { return jsonErr(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what()); }
    const std::string weekStart = strOrEmpty(body, "week_start");
    if (!isIsoDate(weekStart)) return jsonErr(HttpStatus::BAD_REQUEST, "week_start (YYYY-MM-DD, a Monday) required");
    const std::string sectionId = strOrEmpty(body, "section_id");
    const std::string note      = strOrEmpty(body, "note");
    const long long userId      = userIdFromRequest(request);
    try {
        auto* db = Database::getInstance();
        const std::string clubId = resolveClubId(db, strOrEmpty(body, "club_id"));
        if (clubId.empty()) return jsonErr(HttpStatus::NOT_FOUND, "no club");
        // One row per (club, section, week): a revoked row is re-opened
        // rather than duplicated, and the audit columns are reset.
        auto rows = db->query(
            "INSERT INTO schedule_week_releases (club_id, club_section_id, week_start, released_by_user_id, note) "
            "VALUES ($1::int, NULLIF($2, '')::int, $3::date, NULLIF($4, '0')::int, NULLIF($5, '')) "
            "ON CONFLICT (club_id, COALESCE(club_section_id, 0), week_start) DO UPDATE "
            "   SET released_at = now(), released_by_user_id = EXCLUDED.released_by_user_id, "
            "       revoked_at = NULL, revoked_by_user_id = NULL, "
            "       note = COALESCE(EXCLUDED.note, schedule_week_releases.note) "
            "RETURNING id",
            {clubId, sectionId, weekStart, std::to_string(userId), note});
        auto rel = db->query(std::string(kReleaseSelect) + " WHERE r.id = $1::int", {rows[0]["id"].as<std::string>()});
        return jsonResp(HttpStatus::CREATED, json{{"release", rowToRelease(rel[0])}});
    } catch (const std::exception& e) {
        std::cerr << "[ScheduleRelease] create failed: " << e.what() << std::endl;
        const std::string msg = e.what();
        if (msg.find("schedule_week_releases_week_start_check") != std::string::npos)
            return jsonErr(HttpStatus::BAD_REQUEST, "week_start must be a Monday");
        return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR, "could not open the week");
    }
}

// POST /api/schedule/releases/:id/revoke — close an early-opened week.
Response ScheduleReleaseController::handleRevokeRelease(const Request& request) {
    if (!requireAdminLevel(request, kAdminLevels)) return jsonErr(HttpStatus::FORBIDDEN, "admin only");
    const std::string id = getPathParam(request, "id");
    if (id.empty() || !std::all_of(id.begin(), id.end(), ::isdigit)) return jsonErr(HttpStatus::BAD_REQUEST, "bad id");
    const long long userId = userIdFromRequest(request);
    try {
        auto* db = Database::getInstance();
        auto rows = db->query(
            "UPDATE schedule_week_releases SET revoked_at = now(), revoked_by_user_id = NULLIF($2, '0')::int "
            " WHERE id = $1::int AND revoked_at IS NULL RETURNING id",
            {id, std::to_string(userId)});
        if (rows.empty()) return jsonErr(HttpStatus::NOT_FOUND, "no open release with that id");
        auto rel = db->query(std::string(kReleaseSelect) + " WHERE r.id = $1::int", {id});
        return jsonResp(HttpStatus::OK, json{{"release", rowToRelease(rel[0])}});
    } catch (const std::exception& e) {
        std::cerr << "[ScheduleRelease] revoke failed: " << e.what() << std::endl;
        return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR, "could not close the week");
    }
}

// PUT /api/schedule/policy — set the standing rule (new row effective today).
Response ScheduleReleaseController::handlePutPolicy(const Request& request) {
    if (!requireAdminLevel(request, kAdminLevels)) return jsonErr(HttpStatus::FORBIDDEN, "admin only");
    json body;
    try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); }
    catch (const std::exception& e) { return jsonErr(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what()); }
    const std::string weekday = strOrEmpty(body, "cutover_weekday");
    const std::string time    = strOrEmpty(body, "cutover_time");
    if (weekday.size() != 1 || weekday[0] < '0' || weekday[0] > '6') return jsonErr(HttpStatus::BAD_REQUEST, "cutover_weekday must be 0 (Sunday) to 6 (Saturday)");
    if (!isHHMM(time)) return jsonErr(HttpStatus::BAD_REQUEST, "cutover_time must be HH:MM (24h)");
    const std::string sectionId = strOrEmpty(body, "section_id");
    const long long userId      = userIdFromRequest(request);
    try {
        auto* db = Database::getInstance();
        const std::string clubId = resolveClubId(db, strOrEmpty(body, "club_id"));
        if (clubId.empty()) return jsonErr(HttpStatus::NOT_FOUND, "no club");
        auto rows = db->query(
            "INSERT INTO schedule_release_policies (club_id, club_section_id, cutover_weekday, cutover_time, effective_from, created_by_user_id) "
            "VALUES ($1::int, NULLIF($2, '')::int, $3::smallint, $4::time, CURRENT_DATE, NULLIF($5, '0')::int) "
            "ON CONFLICT (club_id, COALESCE(club_section_id, 0), effective_from) DO UPDATE "
            "   SET cutover_weekday = EXCLUDED.cutover_weekday, cutover_time = EXCLUDED.cutover_time, "
            "       created_by_user_id = EXCLUDED.created_by_user_id, created_at = now() "
            "RETURNING id, cutover_weekday, to_char(cutover_time, 'HH24:MI') AS t, to_char(cutover_time, 'FMHH12:MI AM') AS tl, "
            "          effective_from::text AS effective_from",
            {clubId, sectionId, weekday, time, std::to_string(userId)});
        const auto& r = rows[0];
        const int wd = r["cutover_weekday"].as<int>();
        return jsonResp(HttpStatus::OK, json{{"policy", {
            {"id", r["id"].as<long long>()},
            {"weekday", wd},
            {"time", r["t"].c_str()},
            {"label", std::string(kWeekdayNames[wd]) + " " + r["tl"].c_str()},
            {"effective_from", r["effective_from"].c_str()},
        }}});
    } catch (const std::exception& e) {
        std::cerr << "[ScheduleRelease] policy failed: " << e.what() << std::endl;
        return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR, "could not save the rule");
    }
}
