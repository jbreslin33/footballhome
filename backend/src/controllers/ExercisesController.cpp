#include "ExercisesController.h"

#include <iostream>

#include "../database/Database.h"
#include "../models/Exercises.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
}

ExercisesController::ExercisesController() {}

void ExercisesController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix,          [this](const Request& r) { return handleList(r); });
    router.get(prefix + "/:id", [this](const Request& r) { return handleOne(r); });
}

Response ExercisesController::handleList(const Request& request) {
    const long long uid = bearerUserId(request);
    if (uid <= 0) return jsonError(denialStatus(request), "Sign in to see the exercises.");
    try {
        json out = Exercises::catalog();
        auto r = Database::getInstance()->query(
            "SELECT 1 FROM menu_page_people mp JOIN users u ON u.person_id = mp.person_id "
            " WHERE mp.page_code = 'books' AND u.id = $1::bigint", {std::to_string(uid)});
        out["book_pages"] = !r.empty();
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/exercises] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the exercises");
    }
}

Response ExercisesController::handleOne(const Request& request) {
    if (bearerUserId(request) <= 0) return jsonError(denialStatus(request), "Sign in to see the exercises.");
    int id = 0;
    try { const std::string path = request.getPath(); id = std::stoi(path.substr(path.rfind('/') + 1)); } catch (...) {}
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "Bad exercise id");
    try {
        json ex = Exercises::one(id);
        if (ex.is_null()) return jsonError(HttpStatus::NOT_FOUND, "No such exercise");
        return jsonOut(HttpStatus::OK, {{"exercise", ex}});
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/exercises/:id] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the exercise");
    }
}
