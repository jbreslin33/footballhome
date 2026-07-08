#include "MensRosterController.h"

#include <cstdlib>
#include <ctime>
#include <iostream>
#include <regex>
#include <sstream>
#include <unordered_set>

#include "../database/Database.h"
#include "../models/MensTeamAssignments.h"
#include "../models/MensTeamColumns.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

// Delinquency helpers duplicated locally from MensRoster's namespace —
// small, self-contained, no need to expose a shared header just for this.
int envIntFn(const char* name, int fallback) {
    const char* raw = std::getenv(name);
    if (!raw || !*raw) return fallback;
    try { return std::stoi(raw); }
    catch (const std::exception&) { return fallback; }
}

int daysBetweenTodayAnd(const std::string& iso) {
    if (iso.size() < 10) return 0;
    std::tm tm_bill{};
    if (sscanf(iso.c_str(), "%4d-%2d-%2d",
               &tm_bill.tm_year, &tm_bill.tm_mon, &tm_bill.tm_mday) != 3) return 0;
    tm_bill.tm_year -= 1900;
    tm_bill.tm_mon  -= 1;
    tm_bill.tm_hour  = 12;
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

// Look up next_bill_date for a single LA user.  Returns empty string on
// miss (no person_billing row) — caller falls back to PersonBilling
// DEFAULT_DATE-based delinquency calc.
std::string lookupNextBillDate(long long userId) {
    auto db = Database::getInstance();
    auto rows = db->query(
        "SELECT TO_CHAR(next_bill_date, 'YYYY-MM-DD') AS next_bill_date "
        "  FROM person_billing "
        " WHERE leagueapps_user_id = $1",
        {std::to_string(userId)}
    );
    if (rows.empty() || rows[0]["next_bill_date"].is_null()) return {};
    return rows[0]["next_bill_date"].c_str();
}

// Tolerant int extractor: accepts number or numeric string from JSON body.
bool readInt(const json& j, const char* key, long long& out) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null()) return false;
    if (it->is_number_integer())  { out = it->get<long long>(); return true; }
    if (it->is_number_unsigned()) { out = static_cast<long long>(it->get<unsigned long long>()); return true; }
    if (it->is_number_float())    { out = static_cast<long long>(it->get<double>()); return true; }
    if (it->is_string()) {
        try { out = std::stoll(it->get<std::string>()); return true; }
        catch (const std::exception&) { return false; }
    }
    return false;
}

bool readBool(const json& j, const char* key, bool fallback) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null()) return fallback;
    if (it->is_boolean()) return it->get<bool>();
    if (it->is_number())  return it->get<double>() != 0.0;
    if (it->is_string()) {
        const std::string s = it->get<std::string>();
        return s == "true" || s == "1";
    }
    return fallback;
}

std::string readStr(const json& j, const char* key) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null() || !it->is_string()) return {};
    return it->get<std::string>();
}

std::string jsonEscape(const std::string& s) {
    return json(s).dump();   // dumps quoted + escaped
}

Response badRequest(const std::string& msg) {
    std::ostringstream body;
    body << "{\"error\":" << jsonEscape(msg) << "}";
    return Response(HttpStatus::BAD_REQUEST, body.str());
}

Response notFound(const std::string& msg) {
    std::ostringstream body;
    body << "{\"error\":" << jsonEscape(msg) << "}";
    return Response(HttpStatus::NOT_FOUND, body.str());
}

Response conflict(const std::string& msg) {
    std::ostringstream body;
    body << "{\"error\":" << jsonEscape(msg) << "}";
    return Response(HttpStatus::CONFLICT, body.str());
}

Response internalErr(const std::string& msg) {
    std::ostringstream body;
    body << "{\"error\":" << jsonEscape(msg) << "}";
    return Response(HttpStatus::INTERNAL_SERVER_ERROR, body.str());
}

} // namespace

MensRosterController::MensRosterController()
    : model_      (std::make_unique<MensRoster>()),
      columns_    (std::make_unique<MensTeamColumns>()),
      assignments_(std::make_unique<MensTeamAssignments>()) {}

MensRosterController::~MensRosterController() = default;

void MensRosterController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& req) {
        return this->handleGet(req);
    });
    router.post(prefix + "/assign", [this](const Request& req) {
        return this->handleAssign(req);
    });
    router.post(prefix + "/roster-status", [this](const Request& req) {
        return this->handleRosterStatus(req);
    });
    router.post(prefix + "/reorder", [this](const Request& req) {
        return this->handleReorder(req);
    });
    // Ad-hoc game creation.  Lives outside /api/mens-roster because the
    // matches themselves aren't mens-specific (any team column on the
    // Lineups screen can add one) — mens & womens columns both POST here.
    router.post("/api/lineups/games", [this](const Request& req) {
        return this->handleCreateGame(req);
    });
    // Edit an ad-hoc match previously created via handleCreateGame.  Same
    // body shape (opponent, date, time?).  Only matches with match_type_id=2
    // are editable — see handleUpdateGame for the safety check.
    router.put("/api/lineups/games/:matchId", [this](const Request& req) {
        return this->handleUpdateGame(req);
    });
    // RSVP-eligibility endpoints (migration 107, 2026-07-07).  Read
    // uses a query param so the frontend can populate the popup on
    // open; write takes a full teamIds[] set and diffs vs. current.
    router.get(prefix + "/rsvp-eligibility", [this](const Request& req) {
        return this->handleGetRsvpEligibility(req);
    });
    router.put(prefix + "/rsvp-eligibility", [this](const Request& req) {
        return this->handlePutRsvpEligibility(req);
    });
}

Response MensRosterController::handleGet(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }
    const bool includeAll = (request.getQueryParam("includeAll") == "1");
    // refreshLa=1 forces a live LA fetch + payment sync.  Everything
    // else (initial cold cache aside) serves the cached snapshot so a
    // player-move round-trip doesn't get held up on the LeagueApps API.
    const bool refreshLa = (request.getQueryParam("refreshLa") == "1");
    try {
        auto result = model_->run(includeAll, refreshLa);
        if (result.noColumns) {
            std::ostringstream body;
            body << "{\"error\":" << jsonEscape(result.error) << "}";
            return Response(HttpStatus::CONFLICT, body.str());
        }
        return Response(HttpStatus::OK, result.body.dump());
    } catch (const std::exception& e) {
        std::cerr << "MensRosterController::handleGet error: " << e.what() << std::endl;
        std::ostringstream body;
        body << "{\"error\":" << jsonEscape(std::string("Failed to fetch mens roster: ") + e.what()) << "}";
        return Response(HttpStatus::BAD_GATEWAY, body.str());
    }
}

Response MensRosterController::handleAssign(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) {
        return badRequest("Invalid JSON body");
    }

    long long userId = 0;
    long long teamIdLL = 0;
    if (!readInt(body, "leagueAppsUserId", userId) ||
        !readInt(body, "teamId",            teamIdLL) ||
        userId <= 0 || teamIdLL <= 0) {
        return badRequest("leagueAppsUserId, teamId, action(add|remove) required");
    }
    const int teamId = static_cast<int>(teamIdLL);

    std::string action = readStr(body, "action");
    for (auto& c : action) c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
    if (action != "add" && action != "remove") {
        return badRequest("leagueAppsUserId, teamId, action(add|remove) required");
    }

    try {
        auto col = columns_->findByTeamId(teamId);
        // Non-column teams are accepted iff they're pool teams
        // (teams.is_pool = true — Practice, Pickup).  Pool teams show up
        // in the Lineups screen's LA-Players pill row without needing a
        // dedicated mens_team_columns entry, and the roster-players SQL
        // has an `OR t.is_pool` branch that lets ANY mens assignment
        // satisfy the FH-member gate.  We still write the specific
        // (leagueapps_user_id, team_id) row here so the assignment is
        // durable and the pill toggle round-trips cleanly.
        std::string mutexGroup;
        if (col) {
            mutexGroup = col->mutexGroup;
        } else {
            auto db = Database::getInstance();
            auto rows = db->query(
                "SELECT COALESCE(is_pool, false) AS is_pool "
                "  FROM teams WHERE id = $1",
                {std::to_string(teamId)}
            );
            const bool isPool = !rows.empty()
                && !rows[0]["is_pool"].is_null()
                && rows[0]["is_pool"].as<bool>();
            if (!isPool) {
                return notFound("Team not configured as a mens column");
            }
            // mutexGroup stays empty — pool teams don't mutex.
        }

        std::vector<int> teamIds;
        if (action == "remove") {
            teamIds = assignments_->removeAssignment(userId, teamId);
        } else {
            // Delinquency gate REMOVED (2026-07-04 pm).  Admin decides
            // roster + Dues Owed placement manually now — the fetch-time
            // sweep and controller-side dues gate are both disabled per
            // user directive "don't auto manage it".  The card still
            // shows an "Nd OVERDUE" chip so admin sees the risk, but the
            // backend no longer refuses the assignment.

            teamIds = assignments_->addAssignment(userId, teamId, mutexGroup);

            // Practice / Pickup auto-membership on APSL / Liga 1 / Liga 2
            // assign (2026-07-04, extended 2026-07-07): immediate mirror
            // of the /api/mens-roster fetch-time backfill so admin sees
            // Practice + Pickup populated the instant they select someone
            // for a division roster.  Redundant with the fetch backfill
            // but zero-cost (INSERT ON CONFLICT DO NOTHING).
            constexpr int kApslTeamId     = 35;
            constexpr int kLiga1TeamId    = 120;
            constexpr int kLiga2TeamId    = 121;
            constexpr int kPracticeTeamId = 908;
            constexpr int kPickupTeamId   = 909;
            if (teamId == kApslTeamId || teamId == kLiga1TeamId || teamId == kLiga2TeamId) {
                try {
                    assignments_->bulkEnsureActive({userId}, kPracticeTeamId);
                    assignments_->bulkEnsureActive({userId}, kPickupTeamId);
                    // Refresh returned teamIds so the client sees Practice
                    // + Pickup without a round-trip.
                    teamIds = assignments_->teamIdsForUser(userId);
                } catch (const std::exception& e) {
                    std::cerr << "[MensRoster] practice/pickup auto-add on APSL/Liga1/Liga2 failed: "
                              << e.what() << std::endl;
                }
            }
        }

        json out;
        out["leagueAppsUserId"] = userId;
        out["teamIds"]          = teamIds;
        return Response(HttpStatus::OK, out.dump());
    } catch (const std::exception& e) {
        std::cerr << "MensRosterController::handleAssign error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to update assignment: ") + e.what());
    }
}

Response MensRosterController::handleRosterStatus(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) {
        return badRequest("Invalid JSON body");
    }

    long long userId = 0;
    long long teamIdLL = 0;
    if (!readInt(body, "leagueAppsUserId", userId) ||
        !readInt(body, "teamId",            teamIdLL) ||
        userId <= 0 || teamIdLL <= 0) {
        return badRequest("leagueAppsUserId and teamId required");
    }
    const int  teamId   = static_cast<int>(teamIdLL);
    const bool onRoster = readBool(body, "onRoster", false);

    try {
        auto result = assignments_->setRosterStatus(userId, teamId, onRoster);
        if (!result) {
            return notFound("No assignment exists for that player on that team");
        }
        // Manual JSON build — preserve Node's insertion order
        // {leagueAppsUserId, teamId, onRoster}.  nlohmann::json sorts keys
        // alphabetically (std::map), which would emit {leagueAppsUserId,
        // onRoster, teamId} and break byte equivalence.
        std::ostringstream out;
        out << "{\"leagueAppsUserId\":" << userId
            << ",\"teamId\":"          << teamId
            << ",\"onRoster\":"        << (*result ? "true" : "false")
            << "}";
        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "MensRosterController::handleRosterStatus error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to update roster status: ") + e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// POST /api/mens-roster/reorder — coach-defined ability ranking.
//
// Body: {teamId, userIds:[...]}
//   userIds is the full ordered list of active players in the column,
//   top-to-bottom.  Server writes coach_sort_order = 1..N in that order
//   on the matching mens_team_assignments rows.  Any active row on the
//   team whose user is NOT in the list is left untouched (its rank
//   stays whatever it was — or NULL, i.e. alpha fallback).
//
// Returns {teamId, touched:N} for logging.
// ────────────────────────────────────────────────────────────────────────────
Response MensRosterController::handleReorder(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) {
        return badRequest("Invalid JSON body");
    }

    long long teamIdLL = 0;
    if (!readInt(body, "teamId", teamIdLL) || teamIdLL <= 0) {
        return badRequest("teamId (positive int) required");
    }
    const int teamId = static_cast<int>(teamIdLL);

    auto it = body.find("userIds");
    if (it == body.end() || !it->is_array()) {
        return badRequest("userIds (array of ints) required");
    }
    std::vector<long long> ordered;
    ordered.reserve(it->size());
    for (const auto& e : *it) {
        long long v = 0;
        if (e.is_number_integer())          v = e.get<long long>();
        else if (e.is_number_unsigned())    v = static_cast<long long>(e.get<unsigned long long>());
        else if (e.is_number_float())       v = static_cast<long long>(e.get<double>());
        else if (e.is_string()) {
            try { v = std::stoll(e.get<std::string>()); }
            catch (const std::exception&) { return badRequest("userIds contains a non-numeric entry"); }
        } else {
            return badRequest("userIds entries must be integers");
        }
        if (v <= 0) return badRequest("userIds entries must be positive");
        ordered.push_back(v);
    }

    try {
        const long long touched = assignments_->reorderTeam(teamId, ordered);
        std::ostringstream out;
        out << "{\"teamId\":" << teamId
            << ",\"touched\":" << touched
            << "}";
        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "MensRosterController::handleReorder error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to reorder team: ") + e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// POST /api/lineups/games — create an ad-hoc match anchored to a team.
//
// Body: {team_id, opponent, date:"YYYY-MM-DD", time?:"HH:MM"}
//
// Writes to public.matches with:
//   • match_type_id   = 2  (custom — see match_types lookup)
//   • match_status_id = 1  (scheduled)
//   • home_team_id    = <team_id>          (the mens/womens team column)
//   • away_team_id    = NULL               (opponent stored as free text in title)
//   • title           = "vs <opponent>"    (falls back to just opponent if it
//                                           already starts with "vs")
//
// Returns the newly-created match so the frontend can immediately treat it
// as td.nextMatch without a re-fetch round-trip.
// ────────────────────────────────────────────────────────────────────────────
Response MensRosterController::handleCreateGame(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) {
        return badRequest("Invalid JSON body");
    }

    long long teamIdLL = 0;
    if (!readInt(body, "team_id", teamIdLL) || teamIdLL <= 0) {
        return badRequest("team_id (int) required");
    }
    const int teamId = static_cast<int>(teamIdLL);

    // Optional match_type_id — 2=custom game (default, ad-hoc lineup),
    // 3=practice, 7=pickup.  Anything else is rejected so this endpoint
    // stays scoped to coach-managed ad-hoc events (league fixtures etc.
    // still go through EventController).
    long long matchTypeLL = 2;
    if (body.contains("match_type_id")) {
        (void)readInt(body, "match_type_id", matchTypeLL);
    }
    const int matchTypeId = static_cast<int>(matchTypeLL);
    if (matchTypeId != 2 && matchTypeId != 3 && matchTypeId != 7) {
        return badRequest("match_type_id must be 2 (game), 3 (practice), or 7 (pickup)");
    }
    const bool isGame = (matchTypeId == 2);

    // Games use opponent → title = "vs opponent".  Practices/pickups
    // use a free-form title (e.g. "Tuesday practice — Rowan turf").
    std::string opponent = readStr(body, "opponent");
    while (!opponent.empty() && std::isspace(static_cast<unsigned char>(opponent.front()))) opponent.erase(opponent.begin());
    while (!opponent.empty() && std::isspace(static_cast<unsigned char>(opponent.back())))  opponent.pop_back();

    std::string titleRaw = readStr(body, "title");
    while (!titleRaw.empty() && std::isspace(static_cast<unsigned char>(titleRaw.front()))) titleRaw.erase(titleRaw.begin());
    while (!titleRaw.empty() && std::isspace(static_cast<unsigned char>(titleRaw.back())))  titleRaw.pop_back();

    if (isGame && opponent.empty() && titleRaw.empty()) {
        return badRequest("opponent (string) required for games");
    }
    if (!isGame && titleRaw.empty()) {
        // Default title if the coach doesn't type one.
        titleRaw = (matchTypeId == 3) ? "Practice" : "Pickup";
    }

    const std::string dateStr = readStr(body, "date");
    static const std::regex dateRe(R"(^\d{4}-\d{2}-\d{2}$)");
    if (dateStr.empty() || !std::regex_match(dateStr, dateRe)) {
        return badRequest("date required, format YYYY-MM-DD");
    }

    // time is optional; when present must be HH:MM or HH:MM:SS
    std::string timeStr = readStr(body, "time");
    if (!timeStr.empty()) {
        static const std::regex timeRe(R"(^\d{2}:\d{2}(:\d{2})?$)");
        if (!std::regex_match(timeStr, timeRe)) {
            return badRequest("time (optional) must be HH:MM");
        }
        if (timeStr.size() == 5) timeStr += ":00";
    }

    // end_time is optional; same HH:MM validation.
    std::string endTimeStr = readStr(body, "end_time");
    if (!endTimeStr.empty()) {
        static const std::regex timeRe(R"(^\d{2}:\d{2}(:\d{2})?$)");
        if (!std::regex_match(endTimeStr, timeRe)) {
            return badRequest("end_time (optional) must be HH:MM");
        }
        if (endTimeStr.size() == 5) endTimeStr += ":00";
    }

    // Build the stored title.  Games auto-prefix "vs " unless the coach
    // already typed "vs "/"@" or supplied a direct title.  Practices &
    // pickups use titleRaw verbatim.
    std::string title;
    if (isGame) {
        if (!titleRaw.empty()) {
            title = titleRaw;
        } else {
            title = opponent;
            auto startsWithVs = [](const std::string& s) {
                if (s.size() < 3) return false;
                auto lc = [](char c) { return static_cast<char>(std::tolower(static_cast<unsigned char>(c))); };
                return lc(s[0]) == 'v' && lc(s[1]) == 's' && (s[2] == ' ' || s[2] == '.');
            };
            if (!startsWithVs(opponent) && opponent.rfind('@', 0) != 0) {
                title = "vs " + opponent;
            }
        }
    } else {
        title = titleRaw;
    }

    try {
        auto* db = Database::getInstance();
        // Verify the team actually exists (foreign key safety + nicer error).
        {
            auto rows = db->query("SELECT 1 FROM teams WHERE id = $1", {std::to_string(teamId)});
            if (rows.empty()) return notFound("Team not found");
        }

        // NULLIF('', ...)::time lets us pass the (optional) time via the
        // same $5/$6 slot without conditional SQL branches.
        auto rows = db->query(
            "INSERT INTO matches "
            "  (match_type_id, match_status_id, home_team_id, away_team_id, "
            "   title, match_date, match_time, end_time) "
            "VALUES ($1, 1, $2, NULL, $3, $4::date, NULLIF($5, '')::time, NULLIF($6, '')::time) "
            "RETURNING id, home_team_id, title, match_type_id, "
            "          match_date::text AS match_date, "
            "          COALESCE(match_time::text, '') AS match_time, "
            "          COALESCE(end_time::text, '')   AS end_time",
            { std::to_string(matchTypeId), std::to_string(teamId), title, dateStr, timeStr, endTimeStr }
        );
        if (rows.empty()) return internalErr("Failed to create match");

        const auto& r = rows[0];
        std::ostringstream out;
        out << "{\"id\":"            << r["id"].c_str()
            << ",\"home_team_id\":"  << r["home_team_id"].c_str()
            << ",\"match_type_id\":" << r["match_type_id"].c_str()
            << ",\"title\":"         << json(std::string(r["title"].c_str())).dump()
            << ",\"match_date\":"    << json(std::string(r["match_date"].c_str())).dump()
            << ",\"match_time\":"    << json(std::string(r["match_time"].c_str())).dump()
            << ",\"end_time\":"      << json(std::string(r["end_time"].c_str())).dump()
            << "}";
        return Response(HttpStatus::CREATED, out.str());
    } catch (const std::exception& e) {
        std::cerr << "MensRosterController::handleCreateGame error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to create match: ") + e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// PUT /api/lineups/games/:matchId — edit an ad-hoc match previously created
// via handleCreateGame.
//
// Body: {opponent, date:"YYYY-MM-DD", time?:"HH:MM"}
//
// Constraints:
//   • Only matches with match_type_id=2 (ad-hoc, lineup-created) are
//     editable through this endpoint.  Anything else returns 404 so the
//     frontend surfaces "Match not found" rather than silently mutating a
//     real event/match (those route through EventController's heavier
//     PUT /api/matches/:matchId which owns the full events + matches
//     joined schema).
//   • team_id is NOT accepted — the match's home_team_id is immutable for
//     the life of a lineup match (moving between columns would break RSVP
//     joins on match_id).
//   • Empty time clears match_time back to NULL (same NULLIF idiom as
//     handleCreateGame so the two endpoints stay symmetric).
//
// Returns the updated match in the SAME shape as handleCreateGame so the
// frontend can drop the response into td.nextMatch without translation.
// ────────────────────────────────────────────────────────────────────────────
Response MensRosterController::handleUpdateGame(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    // Path is "/api/lineups/games/<matchId>" — extract the trailing int.
    // Matches the extractIdFromPath pattern used elsewhere but inlined
    // here to avoid pulling in the Utils include just for one call.
    std::string matchIdStr;
    {
        static const std::regex pathRe(R"(^/api/lineups/games/(\d+)/?$)");
        std::smatch m;
        const std::string path = request.getPath();
        if (!std::regex_match(path, m, pathRe)) {
            return badRequest("matchId (int) required in path");
        }
        matchIdStr = m[1].str();
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) {
        return badRequest("Invalid JSON body");
    }

    // Games send opponent → title becomes "vs opponent".
    // Practices/pickups send title directly.
    std::string opponent = readStr(body, "opponent");
    while (!opponent.empty() && std::isspace(static_cast<unsigned char>(opponent.front()))) opponent.erase(opponent.begin());
    while (!opponent.empty() && std::isspace(static_cast<unsigned char>(opponent.back())))  opponent.pop_back();

    std::string titleRaw = readStr(body, "title");
    while (!titleRaw.empty() && std::isspace(static_cast<unsigned char>(titleRaw.front()))) titleRaw.erase(titleRaw.begin());
    while (!titleRaw.empty() && std::isspace(static_cast<unsigned char>(titleRaw.back())))  titleRaw.pop_back();

    if (opponent.empty() && titleRaw.empty()) {
        return badRequest("title or opponent required");
    }

    const std::string dateStr = readStr(body, "date");
    static const std::regex dateRe(R"(^\d{4}-\d{2}-\d{2}$)");
    if (dateStr.empty() || !std::regex_match(dateStr, dateRe)) {
        return badRequest("date required, format YYYY-MM-DD");
    }

    std::string timeStr = readStr(body, "time");
    if (!timeStr.empty()) {
        static const std::regex timeRe(R"(^\d{2}:\d{2}(:\d{2})?$)");
        if (!std::regex_match(timeStr, timeRe)) {
            return badRequest("time (optional) must be HH:MM");
        }
        if (timeStr.size() == 5) timeStr += ":00";
    }

    // end_time is optional; same HH:MM validation.
    std::string endTimeStr = readStr(body, "end_time");
    if (!endTimeStr.empty()) {
        static const std::regex timeRe(R"(^\d{2}:\d{2}(:\d{2})?$)");
        if (!std::regex_match(endTimeStr, timeRe)) {
            return badRequest("end_time (optional) must be HH:MM");
        }
        if (endTimeStr.size() == 5) endTimeStr += ":00";
    }

    // If a direct title was supplied, use it verbatim.  Otherwise
    // reconstruct "vs opponent" for games (matches handleCreateGame).
    std::string title;
    if (!titleRaw.empty()) {
        title = titleRaw;
    } else {
        title = opponent;
        auto startsWithVs = [](const std::string& s) {
            if (s.size() < 3) return false;
            auto lc = [](char c) { return static_cast<char>(std::tolower(static_cast<unsigned char>(c))); };
            return lc(s[0]) == 'v' && lc(s[1]) == 's' && (s[2] == ' ' || s[2] == '.');
        };
        if (!startsWithVs(opponent) && opponent.rfind('@', 0) != 0) {
            title = "vs " + opponent;
        }
    }

    try {
        auto* db = Database::getInstance();
        // Safety check: only allow editing ad-hoc coach-managed events
        // (custom games / practices / pickups).  League fixtures etc.
        // still route through EventController's PUT /api/matches/:matchId.
        {
            auto rows = db->query(
                "SELECT 1 FROM matches WHERE id = $1 AND match_type_id IN (2, 3, 7)",
                {matchIdStr}
            );
            if (rows.empty()) return notFound("Match not found or not editable here");
        }

        auto rows = db->query(
            "UPDATE matches SET "
            "  title      = $1, "
            "  match_date = $2::date, "
            "  match_time = NULLIF($3, '')::time, "
            "  end_time   = NULLIF($4, '')::time "
            "WHERE id = $5 "
            "RETURNING id, home_team_id, title, "
            "          match_date::text AS match_date, "
            "          COALESCE(match_time::text, '') AS match_time, "
            "          COALESCE(end_time::text, '')   AS end_time",
            { title, dateStr, timeStr, endTimeStr, matchIdStr }
        );
        if (rows.empty()) return internalErr("Failed to update match");

        const auto& r = rows[0];
        std::ostringstream out;
        out << "{\"id\":"           << r["id"].c_str()
            << ",\"home_team_id\":" << r["home_team_id"].c_str()
            << ",\"title\":"        << json(std::string(r["title"].c_str())).dump()
            << ",\"match_date\":"   << json(std::string(r["match_date"].c_str())).dump()
            << ",\"match_time\":"   << json(std::string(r["match_time"].c_str())).dump()
            << ",\"end_time\":"     << json(std::string(r["end_time"].c_str())).dump()
            << "}";
        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "MensRosterController::handleUpdateGame error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to update match: ") + e.what());
    }
}


// ────────────────────────────────────────────────────────────────────────────
// RSVP eligibility (migration 107, 2026-07-07)
//
// Reads/writes `player_rsvp_eligibility` for one player.  Keyed by
// leagueapps_user_id because the table stores it directly; the frontend
// player card already carries `leagueAppsUserId` so no ID resolution is
// needed on either side.
//
// Team catalog is the four mens selection teams (35/120/121/122) plus
// the two pool teams (908/909).  Grants for other teams are ignored on
// write and hidden on read (defensive — an admin could add rows via SQL
// but the UI is not designed for arbitrary team_ids).
// ────────────────────────────────────────────────────────────────────────────

namespace {

// The full set of teams the player-card popup exposes as checkboxes.
// Order matches the display order in the popup: home teams first, then
// pool teams.  Changes here MUST be mirrored in the frontend
// mens-roster.js RSVP_ELIGIBILITY_TEAMS constant.
const int kEligibilityTeams[] = { 35, 120, 121, 122, 908, 909 };

bool isEligibilityTeamId(int teamId) {
    for (int t : kEligibilityTeams) if (t == teamId) return true;
    return false;
}

}  // namespace

Response MensRosterController::handleGetRsvpEligibility(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }
    long long userId = 0;
    const std::string q = request.getQueryParam("leagueAppsUserId");
    if (!q.empty()) {
        try { userId = std::stoll(q); }
        catch (const std::exception&) { userId = 0; }
    }
    if (userId <= 0) {
        return badRequest("leagueAppsUserId query param required");
    }
    try {
        auto db = Database::getInstance();
        auto rows = db->query(
            "SELECT team_id "
            "  FROM player_rsvp_eligibility "
            " WHERE leagueapps_user_id = $1 "
            " ORDER BY team_id",
            {std::to_string(userId)}
        );
        std::vector<int> teamIds;
        teamIds.reserve(rows.size());
        for (const auto& r : rows) {
            if (r["team_id"].is_null()) continue;
            const int tid = r["team_id"].as<int>();
            if (isEligibilityTeamId(tid)) teamIds.push_back(tid);
        }
        json out = json::object();
        out["leagueAppsUserId"] = userId;
        out["teamIds"]          = teamIds;
        return Response(HttpStatus::OK, out.dump());
    } catch (const std::exception& e) {
        std::cerr << "MensRosterController::handleGetRsvpEligibility error: "
                  << e.what() << std::endl;
        return internalErr(std::string("Failed to load RSVP eligibility: ") + e.what());
    }
}

Response MensRosterController::handlePutRsvpEligibility(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }
    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) {
        return badRequest("Invalid JSON body");
    }
    long long userId = 0;
    if (!readInt(body, "leagueAppsUserId", userId) || userId <= 0) {
        return badRequest("leagueAppsUserId required");
    }
    auto tidsIt = body.find("teamIds");
    if (tidsIt == body.end() || !tidsIt->is_array()) {
        return badRequest("teamIds array required");
    }
    // Dedupe + validate against the eligibility catalog.  Silently
    // drops any team_id not in kEligibilityTeams so an out-of-date
    // client can't grant access to arbitrary teams.
    std::vector<int> desired;
    desired.reserve(tidsIt->size());
    {
        std::unordered_set<int> seen;
        for (const auto& j : *tidsIt) {
            int tid = 0;
            if      (j.is_number_integer())  tid = static_cast<int>(j.get<long long>());
            else if (j.is_number_unsigned()) tid = static_cast<int>(j.get<unsigned long long>());
            else if (j.is_number_float())    tid = static_cast<int>(j.get<double>());
            else if (j.is_string()) {
                try { tid = std::stoi(j.get<std::string>()); }
                catch (const std::exception&) { continue; }
            } else { continue; }
            if (!isEligibilityTeamId(tid)) continue;
            if (seen.insert(tid).second) desired.push_back(tid);
        }
    }

    try {
        auto db = Database::getInstance();

        // Load current grants for this user (filtered to the catalog).
        std::unordered_set<int> current;
        {
            auto rows = db->query(
                "SELECT team_id FROM player_rsvp_eligibility "
                " WHERE leagueapps_user_id = $1",
                {std::to_string(userId)}
            );
            for (const auto& r : rows) {
                if (r["team_id"].is_null()) continue;
                const int tid = r["team_id"].as<int>();
                if (isEligibilityTeamId(tid)) current.insert(tid);
            }
        }

        std::unordered_set<int> want(desired.begin(), desired.end());
        std::vector<int> toInsert, toDelete;
        for (int t : desired) if (!current.count(t))         toInsert.push_back(t);
        for (int t : current) if (!want.count(t))            toDelete.push_back(t);

        auto tx = db->beginTransaction();
        for (int t : toInsert) {
            tx->exec_params(
                "INSERT INTO player_rsvp_eligibility (leagueapps_user_id, team_id) "
                "VALUES ($1, $2) ON CONFLICT DO NOTHING",
                userId, t
            );
        }
        for (int t : toDelete) {
            tx->exec_params(
                "DELETE FROM player_rsvp_eligibility "
                " WHERE leagueapps_user_id = $1 AND team_id = $2",
                userId, t
            );
        }
        db->commit(tx);

        json out = json::object();
        out["leagueAppsUserId"] = userId;
        out["teamIds"]          = desired;
        out["inserted"]         = toInsert;
        out["deleted"]          = toDelete;
        return Response(HttpStatus::OK, out.dump());
    } catch (const std::exception& e) {
        std::cerr << "MensRosterController::handlePutRsvpEligibility error: "
                  << e.what() << std::endl;
        return internalErr(std::string("Failed to save RSVP eligibility: ") + e.what());
    }
}
