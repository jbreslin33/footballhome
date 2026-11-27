#include "FilmAnalysisController.h"

#include <iostream>

#include "../models/FilmAnalysis.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
}

FilmAnalysisController::FilmAnalysisController() {}

void FilmAnalysisController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix,          [this](const Request& r) { return handleList(r); });
    router.get(prefix + "/:id", [this](const Request& r) { return handleClip(r); });
}

Response FilmAnalysisController::handleList(const Request& request) {
    if (bearerUserId(request) <= 0) return jsonError(denialStatus(request), "Sign in to see film analysis.");
    try { return jsonOut(HttpStatus::OK, {{"clips", FilmAnalysis::list()}}); }
    catch (const std::exception& e) {
        std::cerr << "[GET /api/film-analysis] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the clips");
    }
}

Response FilmAnalysisController::handleClip(const Request& request) {
    if (bearerUserId(request) <= 0) return jsonError(denialStatus(request), "Sign in to see film analysis.");
    long long id = 0;
    try {
        const std::string path = request.getPath();
        id = std::stoll(path.substr(path.rfind('/') + 1));
    } catch (...) {}
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "Bad clip id");
    try {
        json out = FilmAnalysis::clip(id);
        if (out.is_null()) return jsonError(HttpStatus::NOT_FOUND, "No such clip");
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/film-analysis/:id] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the clip");
    }
}
