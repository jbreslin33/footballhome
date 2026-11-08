#include "TacticPlansController.h"

#include <iostream>

#include "../database/Database.h"
#include "../models/TacticPlans.h"
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

// The id is the last path segment (/states/<id>).  Controller::getPathParam
// is an unimplemented stub that always returns "" — never use it.
long long lastId(const std::string& path) {
    const auto q = path.find('?');
    const std::string p = path.substr(0, q);
    const auto slash = p.rfind('/');
    return slash == std::string::npos ? 0 : idOf(p.substr(slash + 1));
}

bool num1to11(const json& j, const char* k) {
    return j.contains(k) && j[k].is_number_integer() && j[k].get<int>() >= 1 && j[k].get<int>() <= 11;
}

// { opponents: [{number 1–11 once, x, y 0–100}] (≤ 11),
//   jobs: [{position_id 2–11 once, kind, targets [1–4 of their numbers], target_b? 1–11, stance?,
//           partner_position_id? 2–11 — mirrored by the partner}] (≤ 10) }
// Job kinds are checked against the table by the insert's foreign key.
std::string invalid(const json& b) {
    if (!b.is_object()) return "body must be an object";
    if (!b.contains("opponents") || !b["opponents"].is_array() || b["opponents"].size() > 11) return "opponents: up to 11";
    bool seen[12] = {};
    for (const auto& o : b["opponents"]) {
        if (!num1to11(o, "number") || !o.contains("x") || !o.contains("y") || !o["x"].is_number() || !o["y"].is_number())
            return "bad opponent: " + o.dump();
        const double x = o["x"], y = o["y"];
        if (x < 0 || x > 100 || y < 0 || y > 100) return "opponent x/y within 0–100";
        const int n = o["number"];
        if (seen[n]) return "opponent numbers once each";
        seen[n] = true;
    }
    if (!b.contains("jobs") || !b["jobs"].is_array() || b["jobs"].size() > 10) return "jobs: up to 10";
    bool pos[12] = {};
    for (const auto& j : b["jobs"]) {
        if (!j.contains("position_id") || !j["position_id"].is_number_integer()) return "bad job: " + j.dump();
        const int p = j["position_id"];
        if (p < 2 || p > 11 || pos[p]) return "job position_id 2–11, once each";
        pos[p] = true;
        if (!j.contains("kind") || !j["kind"].is_string() || j["kind"].get<std::string>().size() > 40) return "job kind";
        if (!j.contains("targets") || !j["targets"].is_array() || j["targets"].empty() || j["targets"].size() > 4)
            return "job targets: 1–4 of their numbers";
        bool tseen[12] = {};
        for (const auto& t : j["targets"]) {
            if (!t.is_number_integer() || t.get<int>() < 1 || t.get<int>() > 11) return "job targets 1–11";
            if (tseen[t.get<int>()]) return "job targets once each";
            tseen[t.get<int>()] = true;
        }
        if (j.contains("stance") && !(j["stance"].is_string() && j["stance"].get<std::string>().size() <= 20)) return "job stance";
        if (j.contains("target_b") && !j["target_b"].is_null() && !num1to11(j, "target_b")) return "job target_b 1–11";
        if (j.contains("partner_position_id") && !j["partner_position_id"].is_null()) {
            if (!j["partner_position_id"].is_number_integer()) return "job partner_position_id 2–11";
            const int q = j["partner_position_id"];
            if (q < 2 || q > 11 || q == p) return "job partner_position_id 2–11, not himself";
        }
    }
    // A partnered job (straddle, mig 1133) must be mirrored: the partner
    // carries the same kind on the same man, naming him back.
    for (const auto& j : b["jobs"]) {
        if (!j.contains("partner_position_id") || j["partner_position_id"].is_null()) continue;
        const int p = j["position_id"], q = j["partner_position_id"];
        bool mirrored = false;
        for (const auto& k : b["jobs"])
            if (k["position_id"].get<int>() == q && k.value("kind", std::string()) == j.value("kind", std::string()) &&
                k.contains("partner_position_id") && k["partner_position_id"].is_number_integer() &&
                k["partner_position_id"].get<int>() == p && k["targets"] == j["targets"])
                mirrored = true;
        if (!mirrored) return "partnered job must be mirrored by its partner";
    }
    return "";
}

}  // namespace

TacticPlansController::TacticPlansController() : model_(std::make_unique<TacticPlans>()) {}
TacticPlansController::~TacticPlansController() = default;

void TacticPlansController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "",                  [this](const Request& r) { return handleGet(r); });
    router.post(prefix + "",                  [this](const Request& r) { return handleCreate(r); });
    router.post(prefix + "/states",           [this](const Request& r) { return handleAddState(r); });
    router.post(prefix + "/solve",            [this](const Request& r) { return handleSolve(r); });
    router.put (prefix + "/states/:stateId",  [this](const Request& r) { return handlePutState(r); });
    router.del (prefix + "/states/:stateId",  [this](const Request& r) { return handleDeleteState(r); });
    router.post(prefix + "/shortcuts",        [this](const Request& r) { return handleShortcut(r); });
}

bool TacticPlansController::requireStaff(const Request& request, long long* userId, Response* error) {
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

Response TacticPlansController::handleGet(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Sign in first.");
    try {
        json out = model_->lookups();
        const long long us = idOf(request.getQueryParam("formation_id"));
        const long long them = idOf(request.getQueryParam("opponent_formation_id"));
        const std::string moment = request.getQueryParam("moment");
        const std::string block = request.getQueryParam("block");
        if (us > 0 && them > 0 && !moment.empty() && !block.empty())
            out.update(model_->find(us, them, moment, block));
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "TacticPlansController::handleGet: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST { formation_id, opponent_formation_id, moment, block }
Response TacticPlansController::handleCreate(const Request& request) {
    long long userId = 0;
    Response error(HttpStatus::OK, "");
    if (!requireStaff(request, &userId, &error)) return error;
    try {
        const json b = json::parse(request.getBody());
        const long long id = model_->create(b.value("formation_id", 0LL), b.value("opponent_formation_id", 0LL),
                                            b.value("moment", std::string()), b.value("block", std::string()), userId);
        if (!id) return jsonError(HttpStatus::BAD_REQUEST, "Unknown formation, moment or block.");
        return jsonOut(HttpStatus::OK, {{"ok", true}, {"id", id}});
    } catch (const json::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    } catch (const std::exception& e) {
        std::cerr << "TacticPlansController::handleCreate: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /shortcuts { kind, on } — ⭐ Add (on true) or take away (on false) a
// job on the shortcut list atop the job dropdown (mig 1177).
Response TacticPlansController::handleShortcut(const Request& request) {
    long long userId = 0;
    Response error(HttpStatus::OK, "");
    if (!requireStaff(request, &userId, &error)) return error;
    try {
        const json b = json::parse(request.getBody());
        const std::string kind = b.value("kind", std::string());
        if (kind.empty() || !b.contains("on") || !b["on"].is_boolean()) return jsonError(HttpStatus::BAD_REQUEST, "kind and on (true/false) are required.");
        if (!model_->setShortcut(kind, b["on"].get<bool>(), userId)) return jsonError(HttpStatus::NOT_FOUND, "No such job.");
        return jsonOut(HttpStatus::OK, {{"ok", true}, {"shortcuts", model_->shortcuts()}});
    } catch (const json::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    } catch (const std::exception& e) {
        std::cerr << "TacticPlansController::handleShortcut: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /solve { formation_id, block, state: {ball_with, restart, opponents, jobs} }
// → our spots by the shared geometry, for a state being edited (nothing saved).
Response TacticPlansController::handleSolve(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Sign in first.");
    try {
        const json b = json::parse(request.getBody());
        const long long us = b.value("formation_id", 0LL);
        const std::string block = b.value("block", std::string());
        if (us <= 0 || block.empty() || !b.contains("state") || !b["state"].is_object())
            return jsonError(HttpStatus::BAD_REQUEST, "formation_id, block and state");
        return jsonOut(HttpStatus::OK, model_->solve(us, block, b["state"]));
    } catch (const json::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    } catch (const std::exception& e) {
        std::cerr << "TacticPlansController::handleSolve: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /states { parent_state_id, ball_with }
Response TacticPlansController::handleAddState(const Request& request) {
    long long userId = 0;
    Response error(HttpStatus::OK, "");
    if (!requireStaff(request, &userId, &error)) return error;
    try {
        const json b = json::parse(request.getBody());
        const long long parent = b.value("parent_state_id", 0LL);
        const int ballWith = b.value("ball_with", 0);
        if (parent <= 0 || ballWith < 1 || ballWith > 11) return jsonError(HttpStatus::BAD_REQUEST, "parent_state_id and ball_with 1–11");
        const long long id = model_->addState(parent, ballWith);
        if (!id) return jsonError(HttpStatus::NOT_FOUND, "No such state.");
        return jsonOut(HttpStatus::OK, {{"ok", true}, {"id", id}});
    } catch (const json::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    } catch (const std::exception& e) {
        std::cerr << "TacticPlansController::handleAddState: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// PUT /states/:stateId { opponents, jobs }
Response TacticPlansController::handlePutState(const Request& request) {
    long long userId = 0;
    Response error(HttpStatus::OK, "");
    if (!requireStaff(request, &userId, &error)) return error;
    const long long id = lastId(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "stateId must be a number");
    json b;
    try { b = json::parse(request.getBody()); }
    catch (const std::exception& e) { return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what()); }
    const std::string bad = invalid(b);
    if (!bad.empty()) return jsonError(HttpStatus::BAD_REQUEST, bad);
    try {
        if (!model_->putState(id, b)) return jsonError(HttpStatus::NOT_FOUND, "No such state.");
        // The list a pick may have grown (mig 1177 trigger), for the dropdown.
        return jsonOut(HttpStatus::OK, {{"ok", true}, {"id", id}, {"shortcuts", model_->shortcuts()}});
    } catch (const std::exception& e) {
        std::cerr << "TacticPlansController::handlePutState: " << e.what() << std::endl;
        return jsonError(HttpStatus::BAD_REQUEST, e.what());   // most likely an unknown job kind (FK)
    }
}

Response TacticPlansController::handleDeleteState(const Request& request) {
    long long userId = 0;
    Response error(HttpStatus::OK, "");
    if (!requireStaff(request, &userId, &error)) return error;
    const long long id = lastId(request.getPath());
    try {
        if (!model_->deleteState(id)) return jsonError(HttpStatus::NOT_FOUND, "No such pass (the first state can't be removed).");
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) {
        std::cerr << "TacticPlansController::handleDeleteState: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
