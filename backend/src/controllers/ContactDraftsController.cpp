#include "ContactDraftsController.h"

#include <iostream>

#include "../models/ContactDrafts.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

long long n(const json& b, const char* k) {
    if (!b.contains(k) || b[k].is_null()) return 0;
    if (b[k].is_number()) return b[k].get<long long>();
    if (b[k].is_string()) { try { return std::stoll(b[k].get<std::string>()); } catch (...) {} }
    return 0;
}
std::string s(const json& b, const char* k) { return b.contains(k) && b[k].is_string() ? b[k].get<std::string>() : std::string{}; }
long long q(const Request& r, const char* k) { try { return std::stoll(r.getQueryParam(k)); } catch (...) { return 0; } }

}  // namespace

void ContactDraftsController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix,           [this](const Request& r) { return handleList(r); });
    router.post(prefix,           [this](const Request& r) { return handleSave(r); });
    router.del (prefix,           [this](const Request& r) { return handleDelete(r); });
    router.post(prefix + "/sent", [this](const Request& r) { return handleSent(r); });
}

bool ContactDraftsController::gate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "Contact drafts are for club admins.");
    return false;
}

Response ContactDraftsController::handleList(const Request& request) {
    Response err; if (!gate(request, &err)) return err;
    try {
        json out = ContactDrafts::forContact(q(request, "contact_id"));
        return out.is_null() ? jsonError(HttpStatus::NOT_FOUND, "No such contact.") : jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "[contact-drafts] list: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response ContactDraftsController::handleSave(const Request& request) {
    Response err; if (!gate(request, &err)) return err;
    try {
        json b = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        long long userId = bearerUserId(request); if (userId < 0) userId = 0;
        json d = ContactDrafts::save(n(b, "id"), n(b, "contact_id"), n(b, "match_id"), s(b, "subject"), s(b, "body"), userId);
        return d.is_null() ? jsonError(HttpStatus::NOT_FOUND, "Draft or contact not found (or already sent).") : jsonOut(HttpStatus::OK, {{"draft", d}});
    } catch (const std::exception& e) {
        std::cerr << "[contact-drafts] save: " << e.what() << std::endl;
        return jsonError(HttpStatus::BAD_REQUEST, e.what());
    }
}

Response ContactDraftsController::handleDelete(const Request& request) {
    Response err; if (!gate(request, &err)) return err;
    try {
        return ContactDrafts::remove(q(request, "id")) ? jsonOut(HttpStatus::OK, {{"ok", true}}) : jsonError(HttpStatus::NOT_FOUND, "No such draft.");
    } catch (const std::exception& e) {
        std::cerr << "[contact-drafts] delete: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response ContactDraftsController::handleSent(const Request& request) {
    Response err; if (!gate(request, &err)) return err;
    try {
        json b = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        long long userId = bearerUserId(request); if (userId < 0) userId = 0;
        json out = ContactDrafts::markSent(n(b, "id"), userId);
        return out.is_null() ? jsonError(HttpStatus::NOT_FOUND, "Draft gone or the contact has no email.") : jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "[contact-drafts] sent: " << e.what() << std::endl;
        return jsonError(HttpStatus::BAD_REQUEST, e.what());
    }
}
