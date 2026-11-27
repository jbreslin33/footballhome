#include "CoachingBooksController.h"

#include <iostream>

#include "../database/Database.h"
#include "../models/CoachingBooks.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
}

CoachingBooksController::CoachingBooksController() {}

bool CoachingBooksController::gate(const Request& request, Response* error) {
    // Only the people menu_page_people lists for 'books' (mig 1928: the owner).
    const long long uid = bearerUserId(request);
    if (uid > 0) {
        auto r = Database::getInstance()->query(
            "SELECT 1 FROM menu_page_people mp JOIN users u ON u.person_id = mp.person_id "
            " WHERE mp.page_code = 'books' AND u.id = $1::bigint",
            {std::to_string(uid)});
        if (!r.empty()) return true;
    }
    *error = jsonError(denialStatus(request), "Coaching books are for the owner.");
    return false;
}

void CoachingBooksController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix,                       [this](const Request& r) { return handleLibrary(r); });
    router.get(prefix + "/:book/pages/:page", [this](const Request& r) { return handlePage(r); });
}

Response CoachingBooksController::handleLibrary(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try { return jsonOut(HttpStatus::OK, CoachingBooks::library()); }
    catch (const std::exception& e) {
        std::cerr << "[CoachingBooksController::library] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the books");
    }
}

Response CoachingBooksController::handlePage(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    // /api/coaching-books/<book>/pages/<page>
    const std::string path = request.getPath();
    int book = 0, page = 0;
    try {
        const auto p = path.rfind("/pages/");
        page = std::stoi(path.substr(p + 7));
        const auto b = path.rfind('/', p - 1);
        book = std::stoi(path.substr(b + 1, p - b - 1));
    } catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "Bad page"); }
    try {
        auto out = CoachingBooks::page(book, page);
        if (out.is_null()) return jsonError(HttpStatus::NOT_FOUND, "That page isn't loaded");
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "[CoachingBooksController::page] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the page");
    }
}
