#include "TeamRosterController.h"
#include <iostream>
#include <regex>
#include <sstream>

TeamRosterController::TeamRosterController()
    : model_(std::make_unique<TeamRoster>()) {}

void TeamRosterController::registerRoutes(Router& router, const std::string& prefix) {
    // POST /api/teams/:teamId/roster/:personId
    router.post(prefix + "/:teamId/roster/:personId", [this](const Request& request) {
        return this->handleSetMembership(request);
    });
}

// ────────────────────────────────────────────────────────────────────────────
// POST — add or remove `personId` from `teamId`'s roster.
//
// Body shape: {"action": "add"} or {"action": "remove"} (case-insensitive).
// Response shape (mirrors Node 1:1):
//   { teamId, personId, onRoster: true|false }
// where onRoster reflects the action taken, NOT a re-read from the DB —
// matching Node's behaviour.
// ────────────────────────────────────────────────────────────────────────────
Response TeamRosterController::handleSetMembership(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int teamId = 0, personId = 0;
    if (!extractTeamAndPerson(request.getPath(), teamId, personId)) {
        return errorResponse(HttpStatus::BAD_REQUEST,
                             "teamId and personId must be integers");
    }

    const std::string action = extractAction(request.getBody());
    if (action != "add" && action != "remove") {
        return errorResponse(HttpStatus::BAD_REQUEST,
                             "action must be 'add' or 'remove'");
    }

    try {
        if (action == "add") {
            (void)model_->add(teamId, personId);
        } else {
            (void)model_->remove(teamId, personId);
        }

        std::ostringstream json;
        json << "{\"teamId\":"   << teamId
             << ",\"personId\":" << personId
             << ",\"onRoster\":" << (action == "add" ? "true" : "false") << "}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::exception& e) {
        std::cerr << "TeamRosterController::handleSetMembership error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Path parser.
// ────────────────────────────────────────────────────────────────────────────
bool TeamRosterController::extractTeamAndPerson(const std::string& path,
                                                int& teamId,
                                                int& personId) const {
    static const std::regex re(R"(/api/teams/(\d+)/roster/(\d+))");
    std::smatch m;
    if (!std::regex_search(path, m, re)) return false;
    try {
        teamId   = std::stoi(m[1].str());
        personId = std::stoi(m[2].str());
    } catch (const std::exception&) {
        return false;
    }
    return true;
}

// ────────────────────────────────────────────────────────────────────────────
// JSON body parsing — regex-based, no JSON library.  We accept any of
//   {"action":"add"}     {"action": "ADD"}     {"action" : 'remove'}
// and return the lower-cased value, or "" when no recognisable action is
// present.  Strict enough for our single-field body shape.
// ────────────────────────────────────────────────────────────────────────────
std::string TeamRosterController::extractAction(const std::string& body) {
    static const std::regex re(
        R"rx("action"\s*:\s*["']([A-Za-z]+)["'])rx");
    std::smatch m;
    if (!std::regex_search(body, m, re)) return {};
    std::string v = m[1].str();
    for (auto& c : v) c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
    return v;
}

// ────────────────────────────────────────────────────────────────────────────
// Auth.
// ────────────────────────────────────────────────────────────────────────────
bool TeamRosterController::requireBearer(const Request& request) const {
    std::string h = request.getHeader("Authorization");
    if (h.empty()) h = request.getHeader("authorization");
    return h.size() > 7 && h.substr(0, 7) == "Bearer ";
}
