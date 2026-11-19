#include "OnboardingController.h"

#include <iostream>

#include "../models/Onboarding.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json; charset=utf-8"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

json parseBody(const Request& r, bool* ok) {
    *ok = true;
    try { return r.getBody().empty() ? json::object() : json::parse(r.getBody()); }
    catch (...) { *ok = false; return json::object(); }
}
std::string text(const json& b, const char* k) { return b.contains(k) && b[k].is_string() ? b[k].get<std::string>() : std::string(); }
long long num(const json& b, const char* k) { return b.contains(k) && b[k].is_number_integer() ? b[k].get<long long>() : 0; }
}  // namespace

OnboardingController::OnboardingController() {}

bool OnboardingController::gate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "Onboarding is for club admins.");
    return false;
}

void OnboardingController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& r) {
        Response denied; if (!gate(r, &denied)) return denied;
        try { return jsonOut(HttpStatus::OK, Onboarding::board()); }
        catch (const std::exception& e) {
            std::cerr << "[OnboardingController::board] " << e.what() << std::endl;
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load onboarding");
        }
    });
    router.post(prefix + "/track", [this](const Request& r) {
        Response denied; if (!gate(r, &denied)) return denied;
        bool ok; json b = parseBody(r, &ok);
        if (!ok) return jsonError(HttpStatus::BAD_REQUEST, "Invalid JSON");
        const long long pid = num(b, "person_id");
        if (pid <= 0) return jsonError(HttpStatus::BAD_REQUEST, "person_id required");
        try {
            const std::string err = Onboarding::setTrack(pid, text(b, "track"), bearerUserId(r));
            if (!err.empty()) return jsonError(HttpStatus::BAD_REQUEST, err);
            return jsonOut(HttpStatus::OK, Onboarding::board());
        } catch (const std::exception& e) {
            std::cerr << "[OnboardingController::track] " << e.what() << std::endl;
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not save");
        }
    });
    router.post(prefix + "/step", [this](const Request& r) {
        Response denied; if (!gate(r, &denied)) return denied;
        bool ok; json b = parseBody(r, &ok);
        if (!ok) return jsonError(HttpStatus::BAD_REQUEST, "Invalid JSON");
        const long long pid = num(b, "person_id");
        if (pid <= 0) return jsonError(HttpStatus::BAD_REQUEST, "person_id required");
        try {
            const std::string err = Onboarding::review(pid, text(b, "code"), text(b, "action"), text(b, "note"), bearerUserId(r));
            if (!err.empty()) return jsonError(HttpStatus::BAD_REQUEST, err);
            return jsonOut(HttpStatus::OK, Onboarding::board());
        } catch (const std::exception& e) {
            std::cerr << "[OnboardingController::step] " << e.what() << std::endl;
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not save");
        }
    });
}
