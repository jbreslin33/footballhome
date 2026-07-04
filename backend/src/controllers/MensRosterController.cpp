#include "MensRosterController.h"

#include <iostream>
#include <regex>
#include <sstream>

#include "../database/Database.h"
#include "../models/MensTeamAssignments.h"
#include "../models/MensTeamColumns.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

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
}

Response MensRosterController::handleGet(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }
    const bool includeAll = (request.getQueryParam("includeAll") == "1");
    try {
        auto result = model_->run(includeAll);
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
            teamIds = assignments_->addAssignment(userId, teamId, mutexGroup);
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

