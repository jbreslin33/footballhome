#include "FieldPlanController.h"

#include <cmath>
#include <iostream>

#include "../database/Database.h"
#include "../models/FieldPlan.h"
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

bool parseBody(const Request& request, json* body, Response* error) {
    try {
        *body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        return true;
    } catch (const std::exception& e) {
        *error = jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
        return false;
    }
}

bool num(const json& j, const char* k) { return j.contains(k) && j[k].is_number(); }

// A pitch or box as pitch-planner.js sends it; sizes 1–200 yd, positions
// within a km of the site origin.
bool validItem(const json& it, bool spot) {
    if (!it.is_object() || !num(it, "length_yd") || !num(it, "width_yd") ||
        !num(it, "x") || !num(it, "z") || !num(it, "rot"))
        return false;
    const double L = it["length_yd"], W = it["width_yd"], x = it["x"], z = it["z"], r = it["rot"];
    if (L <= 0 || L > 200 || W <= 0 || W > 200 || std::abs(x) > 1000 || std::abs(z) > 1000 ||
        r < -360 || r > 720)
        return false;
    const char* key = spot ? "pitch" : "key";
    if (!it.contains(key) || !it[key].is_string() || it[key].get<std::string>().empty() ||
        it[key].get<std::string>().size() > 64)
        return false;
    if (spot || it.value("kind", "pitch") == "practice_box")
        return it.contains("name") && it["name"].is_string() && !it["name"].get<std::string>().empty() &&
               it["name"].get<std::string>().size() <= 80;
    return true;
}

}  // namespace

FieldPlanController::FieldPlanController() : model_(std::make_unique<FieldPlan>()) {}
FieldPlanController::~FieldPlanController() = default;

void FieldPlanController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "",        [this](const Request& r) { return handleGet(r); });
    router.put (prefix + "/layout", [this](const Request& r) { return handlePutLayout(r); });
    router.post(prefix + "/spot",   [this](const Request& r) { return handleAddSpot(r); });
    router.del (prefix + "/spot",   [this](const Request& r) { return handleDeleteSpot(r); });
    router.post(prefix + "/save",   [this](const Request& r) { return handleAddSave(r); });
    router.del (prefix + "/save",   [this](const Request& r) { return handleDeleteSave(r); });
}

bool FieldPlanController::requireAdmin(const Request& request, long long* userId, Response* error) {
    if (!requireBearer(request)) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "Sign in to change the field plan.");
        return false;
    }
    *userId = bearerUserId(request);
    if (Database::getInstance()->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1",
                                       {std::to_string(*userId)}).empty()) {
        *error = jsonError(HttpStatus::FORBIDDEN, "Only club admins change the field plan.");
        return false;
    }
    return true;
}

long long FieldPlanController::facility(const Request& request) {
    long long id = 0;
    try { id = std::stoll(request.getQueryParam("facility_id")); } catch (...) {}
    return model_->facilityId(id);
}

// GET ?facility_id=  (default: Lighthouse Sport Complex)
Response FieldPlanController::handleGet(const Request& request) {
    try {
        const long long fid = facility(request);
        if (!fid) return jsonError(HttpStatus::NOT_FOUND, "No such facility.");
        return jsonOut(HttpStatus::OK, model_->get(fid));
    } catch (const std::exception& e) {
        std::cerr << "FieldPlanController::handleGet: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// PUT /layout  { kind: 'current'|'default', items: [{ key, kind, name?, length_yd, width_yd, x, z, rot }] }
Response FieldPlanController::handlePutLayout(const Request& request) {
    long long userId = 0;
    Response error(HttpStatus::OK, "");
    if (!requireAdmin(request, &userId, &error)) return error;
    json body;
    if (!parseBody(request, &body, &error)) return error;
    const std::string kind = body.value("kind", "");
    if (kind != "current" && kind != "default")
        return jsonError(HttpStatus::BAD_REQUEST, "kind must be 'current' or 'default'");
    if (!body.contains("items") || !body["items"].is_array() || body["items"].size() > 100)
        return jsonError(HttpStatus::BAD_REQUEST, "items: an array of up to 100");
    for (const auto& it : body["items"])
        if (!validItem(it, false)) return jsonError(HttpStatus::BAD_REQUEST, "Bad item: " + it.dump());
    try {
        const long long fid = facility(request);
        if (!fid) return jsonError(HttpStatus::NOT_FOUND, "No such facility.");
        model_->putLayout(fid, kind, body["items"], userId);
        return jsonOut(HttpStatus::OK, {{"ok", true}, {"kind", kind}, {"items", body["items"].size()}});
    } catch (const std::exception& e) {
        std::cerr << "FieldPlanController::handlePutLayout: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /spot  { pitch, name, length_yd, width_yd, x, z, rot }
Response FieldPlanController::handleAddSpot(const Request& request) {
    long long userId = 0;
    Response error(HttpStatus::OK, "");
    if (!requireAdmin(request, &userId, &error)) return error;
    json body;
    if (!parseBody(request, &body, &error)) return error;
    if (!validItem(body, true)) return jsonError(HttpStatus::BAD_REQUEST, "Bad spot.");
    try {
        const long long fid = facility(request);
        if (!fid) return jsonError(HttpStatus::NOT_FOUND, "No such facility.");
        return jsonOut(HttpStatus::OK, {{"id", model_->addSpot(fid, body, userId)}});
    } catch (const std::exception& e) {
        std::cerr << "FieldPlanController::handleAddSpot: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// DELETE /spot?id=
Response FieldPlanController::handleDeleteSpot(const Request& request) {
    long long userId = 0;
    Response error(HttpStatus::OK, "");
    if (!requireAdmin(request, &userId, &error)) return error;
    long long id = 0;
    try { id = std::stoll(request.getQueryParam("id")); } catch (...) {}
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "id required");
    try {
        const long long fid = facility(request);
        if (!model_->deleteSpot(fid, id)) return jsonError(HttpStatus::NOT_FOUND, "No such spot.");
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) {
        std::cerr << "FieldPlanController::handleDeleteSpot: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /save  { name, items: [{ key, kind, name?, length_yd, width_yd, x, z, rot }] }
// A named snapshot of the whole layout (migration 680); a repeated name is
// a new version.
Response FieldPlanController::handleAddSave(const Request& request) {
    long long userId = 0;
    Response error(HttpStatus::OK, "");
    if (!requireAdmin(request, &userId, &error)) return error;
    json body;
    if (!parseBody(request, &body, &error)) return error;
    const std::string name = body.contains("name") && body["name"].is_string() ? body["name"].get<std::string>() : "";
    if (name.find_first_not_of(" \t") == std::string::npos || name.size() > 80)
        return jsonError(HttpStatus::BAD_REQUEST, "name: 1–80 characters");
    if (!body.contains("items") || !body["items"].is_array() || body["items"].empty() ||
        body["items"].size() > 100)
        return jsonError(HttpStatus::BAD_REQUEST, "items: an array of 1 to 100");
    for (const auto& it : body["items"])
        if (!validItem(it, false)) return jsonError(HttpStatus::BAD_REQUEST, "Bad item: " + it.dump());
    try {
        const long long fid = facility(request);
        if (!fid) return jsonError(HttpStatus::NOT_FOUND, "No such facility.");
        return jsonOut(HttpStatus::OK, {{"id", model_->addSave(fid, name, body["items"], userId)}});
    } catch (const std::exception& e) {
        std::cerr << "FieldPlanController::handleAddSave: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// DELETE /save?id=
Response FieldPlanController::handleDeleteSave(const Request& request) {
    long long userId = 0;
    Response error(HttpStatus::OK, "");
    if (!requireAdmin(request, &userId, &error)) return error;
    long long id = 0;
    try { id = std::stoll(request.getQueryParam("id")); } catch (...) {}
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "id required");
    try {
        const long long fid = facility(request);
        if (!model_->deleteSave(fid, id)) return jsonError(HttpStatus::NOT_FOUND, "No such save.");
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) {
        std::cerr << "FieldPlanController::handleDeleteSave: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
