#include "MensRosterController.h"

#include <iostream>
#include <sstream>

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
        if (!col) return notFound("Team not configured as a mens column");

        std::vector<int> teamIds;
        if (action == "remove") {
            teamIds = assignments_->removeAssignment(userId, teamId);
        } else {
            teamIds = assignments_->addAssignment(userId, teamId, col->mutexGroup);
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

