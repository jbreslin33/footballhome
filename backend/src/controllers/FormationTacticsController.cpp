#include "FormationTacticsController.h"

#include <iostream>

#include "../database/Database.h"
#include "../models/FormationTactics.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    r.setHeader("Cache-Control", "no-store");
    return r;
}

Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

long long idOf(const std::string& s) {
    try { return std::stoll(s); } catch (...) { return 0; }
}

// A point on the 0–100 pitch.
bool point(const json& j) {
    if (!j.is_object() || !j.contains("x") || !j.contains("y") || !j["x"].is_number() || !j["y"].is_number())
        return false;
    const double x = j["x"], y = j["y"];
    return x >= 0 && x <= 100 && y >= 0 && y <= 100;
}

// { ball?: {x,y}, players: [{position_id 1–11 once each, x, y}] (≤ 11),
//   opponents: [{label ≤ 8 chars, x, y}] (≤ 11) }
std::string invalid(const json& b) {
    if (!b.is_object()) return "body must be an object";
    if (b.contains("ball") && !b["ball"].is_null() && !point(b["ball"])) return "ball: {x, y} within 0–100";
    if (!b.contains("players") || !b["players"].is_array() || b["players"].size() > 11) return "players: up to 11";
    bool seen[12] = {};
    for (const auto& p : b["players"]) {
        if (!point(p) || !p.contains("position_id") || !p["position_id"].is_number_integer()) return "bad player: " + p.dump();
        const int pos = p["position_id"];
        if (pos < 1 || pos > 11 || seen[pos]) return "position_id 1–11, once each";
        seen[pos] = true;
    }
    if (!b.contains("opponents") || !b["opponents"].is_array() || b["opponents"].size() > 11) return "opponents: up to 11";
    for (const auto& o : b["opponents"]) {
        if (!point(o)) return "bad opponent: " + o.dump();
        if (o.contains("label") && (!o["label"].is_string() || o["label"].get<std::string>().size() > 8))
            return "opponent label: up to 8 characters";
    }
    return "";
}

}  // namespace

FormationTacticsController::FormationTacticsController() : model_(std::make_unique<FormationTactics>()) {}
FormationTacticsController::~FormationTacticsController() = default;

void FormationTacticsController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix + "/:formationId",         [this](const Request& r) { return handleGet(r); });
    router.put(prefix + "/situations/:frameId", [this](const Request& r) { return handlePutSituation(r); });
}

bool FormationTacticsController::requireStaff(const Request& request, long long* userId, Response* error) {
    if (!requireBearer(request)) { *error = jsonError(HttpStatus::UNAUTHORIZED, "Sign in first."); return false; }
    *userId = bearerUserId(request);
    auto r = Database::getInstance()->query(
        "SELECT 1 FROM users u WHERE u.id = $1::int "
        "   AND (EXISTS (SELECT 1 FROM admins a WHERE a.user_id = u.id) "
        "        OR EXISTS (SELECT 1 FROM coaches c JOIN team_coaches tc ON tc.coach_id = c.id AND tc.ended_at IS NULL "
        "                    WHERE c.person_id = u.person_id)) LIMIT 1",
        {std::to_string(*userId)});
    if (r.empty()) { *error = jsonError(HttpStatus::FORBIDDEN, "Coaches and admins only."); return false; }
    return true;
}

// GET /:formationId — the formation's situations (empty list when none).
Response FormationTacticsController::handleGet(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Sign in first.");
    const long long formationId = idOf(getPathParam(request, "formationId"));
    if (formationId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "formationId must be a number");
    try {
        return jsonOut(HttpStatus::OK, model_->get(formationId));
    } catch (const std::exception& e) {
        std::cerr << "FormationTacticsController::handleGet: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// PUT /situations/:frameId — { ball?, players, opponents } replaces that
// situation's pieces.
Response FormationTacticsController::handlePutSituation(const Request& request) {
    long long userId = 0;
    Response error(HttpStatus::OK, "");
    if (!requireStaff(request, &userId, &error)) return error;
    const long long frameId = idOf(getPathParam(request, "frameId"));
    if (frameId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "frameId must be a number");
    json body;
    try {
        body = json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }
    const std::string bad = invalid(body);
    if (!bad.empty()) return jsonError(HttpStatus::BAD_REQUEST, bad);
    try {
        if (!model_->putSituation(frameId, body, userId))
            return jsonError(HttpStatus::NOT_FOUND, "No such situation.");
        return jsonOut(HttpStatus::OK, {{"ok", true}, {"id", frameId}});
    } catch (const std::exception& e) {
        std::cerr << "FormationTacticsController::handlePutSituation: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
