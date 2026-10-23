#include "GameRosterController.h"

#include <algorithm>
#include <iostream>
#include <vector>

#include "../database/Database.h"
#include "../models/GameRoster.h"

#include <stdexcept>
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    r.setHeader("Cache-Control", "no-store");
    return r;
}

Response jsonError(HttpStatus s, const std::string& message) {
    return jsonOut(s, {{"error", message}});
}

}  // namespace

GameRosterController::GameRosterController() : model_(std::make_unique<GameRoster>()) {}
GameRosterController::~GameRosterController() = default;

void GameRosterController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix + "/roster", [this](const Request& r) { return handleRoster(r); });
    router.put(prefix + "/player", [this](const Request& r) { return handleSavePlayer(r); });
    router.put(prefix + "/lineup", [this](const Request& r) { return handleSaveLineup(r); });
    router.get(prefix + "/game-center-lineups", [this](const Request& r) { return handleGameCenterLineups(r); });
    router.post(prefix + "/lineup/game-center", [this](const Request& r) { return handleImportGameCenter(r); });
}

// GET /roster?team=Lighthouse%20APSL — signed-in members (real people's
// names + ratings: never public, same as the game itself).
Response GameRosterController::handleRoster(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Sign in to see the game rosters.");
    const std::string team = request.getQueryParam("team");
    if (team.empty() || team.size() > 80) return jsonError(HttpStatus::BAD_REQUEST, "team required");
    try {
        json out = model_->team(team);
        if (out.is_null()) return jsonError(HttpStatus::NOT_FOUND, "No such game team.");
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "GameRosterController::handleRoster: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// PUT /player { team, shirt, attrs: { code: 0-100 | null }, description? } — admins.
Response GameRosterController::handleSavePlayer(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Sign in to edit players.");
    const long long userId = bearerUserId(request);
    auto* db = Database::getInstance();
    if (db->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1",
                  {std::to_string(userId)}).empty())
        return jsonError(HttpStatus::FORBIDDEN, "Only club admins edit game players.");
    json body;
    try {
        body = json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }
    if (!body.contains("team") || !body["team"].is_string() || !body.contains("shirt") ||
        !body["shirt"].is_number_integer())
        return jsonError(HttpStatus::BAD_REQUEST, "team and shirt required");
    json attrs = body.value("attrs", json::object());
    if (!attrs.is_object()) return jsonError(HttpStatus::BAD_REQUEST, "attrs must be an object");
    try {
        // Only registry codes, 0-100 or null.
        std::vector<std::string> codes;
        for (const auto& r : db->query("SELECT code FROM game_attributes")) codes.push_back(r[0].as<std::string>());
        for (auto it = attrs.begin(); it != attrs.end(); ++it) {
            if (std::find(codes.begin(), codes.end(), it.key()) == codes.end())
                return jsonError(HttpStatus::BAD_REQUEST, "Unknown attribute: " + it.key());
            if (!it.value().is_null() &&
                (!it.value().is_number_integer() || it.value().get<int>() < 0 || it.value().get<int>() > 100))
                return jsonError(HttpStatus::BAD_REQUEST, it.key() + " must be 0-100 or null");
        }
        json description = body.contains("description") ? body["description"] : json(nullptr);
        if (!description.is_null() && (!description.is_string() || description.get<std::string>().size() > 2000))
            return jsonError(HttpStatus::BAD_REQUEST, "description: text up to 2000 characters");
        if (!model_->savePlayer(body["team"].get<std::string>(), body["shirt"].get<int>(), attrs, description))
            return jsonError(HttpStatus::NOT_FOUND, "No such player.");
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) {
        std::cerr << "GameRosterController::handleSavePlayer: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

bool GameRosterController::requireAdmin(const Request& request, Response* error) {
    if (!requireBearer(request)) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "Sign in to edit the game.");
        return false;
    }
    if (Database::getInstance()->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1",
                                       {std::to_string(bearerUserId(request))}).empty()) {
        *error = jsonError(HttpStatus::FORBIDDEN, "Only club admins edit the game.");
        return false;
    }
    return true;
}

// PUT /lineup { team, shirts: [11 shirts, GK first] } — admins (mig 641).
Response GameRosterController::handleSaveLineup(const Request& request) {
    Response error(HttpStatus::OK, "");
    if (!requireAdmin(request, &error)) return error;
    try {
        const json body = json::parse(request.getBody());
        if (!body.contains("team") || !body["team"].is_string() || !body.contains("shirts") ||
            !body["shirts"].is_array())
            return jsonError(HttpStatus::BAD_REQUEST, "team and shirts required");
        std::vector<int> shirts;
        for (const auto& s : body["shirts"]) {
            if (!s.is_number_integer()) return jsonError(HttpStatus::BAD_REQUEST, "shirts are numbers");
            shirts.push_back(s.get<int>());
        }
        model_->saveLineup(body["team"].get<std::string>(), shirts);
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::invalid_argument& e) {
        return jsonError(HttpStatus::BAD_REQUEST, e.what());
    } catch (const std::exception& e) {
        std::cerr << "GameRosterController::handleSaveLineup: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// GET /game-center-lineups?team= — signed-in members.
Response GameRosterController::handleGameCenterLineups(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Sign in to see lineups.");
    const std::string team = request.getQueryParam("team");
    if (team.empty() || team.size() > 80) return jsonError(HttpStatus::BAD_REQUEST, "team required");
    try {
        return jsonOut(HttpStatus::OK, {{"matches", model_->gameCenterLineups(team)}});
    } catch (const std::exception& e) {
        std::cerr << "GameRosterController::handleGameCenterLineups: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /lineup/game-center { team, match_id } — admins (mig 641).
Response GameRosterController::handleImportGameCenter(const Request& request) {
    Response error(HttpStatus::OK, "");
    if (!requireAdmin(request, &error)) return error;
    try {
        const json body = json::parse(request.getBody());
        if (!body.contains("team") || !body["team"].is_string() || !body.contains("match_id") ||
            !body["match_id"].is_number_integer())
            return jsonError(HttpStatus::BAD_REQUEST, "team and match_id required");
        return jsonOut(HttpStatus::OK, model_->importGameCenterLineup(body["team"].get<std::string>(),
                                                                       body["match_id"].get<long long>()));
    } catch (const std::invalid_argument& e) {
        return jsonError(HttpStatus::BAD_REQUEST, e.what());
    } catch (const std::exception& e) {
        std::cerr << "GameRosterController::handleImportGameCenter: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
