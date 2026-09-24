#include "LockupController.h"

#include <iostream>
#include <sstream>

#include "../models/FacilityLockup.h"
#include "../models/MessageCopy.h"
#include "../services/LockupScheduler.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
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
std::string strField(const json& body, const char* key) {
    return (body.contains(key) && body[key].is_string()) ? body[key].get<std::string>() : std::string();
}

// The tap landing: structure only — every word is a lockup/page_* row.
Response htmlPage(const std::string& title, const std::string& body) {
    std::ostringstream h;
    h << "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">"
         "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
         "<meta name=\"robots\" content=\"noindex\">"
         "<title>";
    auto esc = [](const std::string& s) {
        std::string o;
        for (char c : s) {
            switch (c) {
                case '&': o += "&amp;"; break; case '<': o += "&lt;"; break;
                case '>': o += "&gt;"; break; default: o.push_back(c);
            }
        }
        return o;
    };
    h << esc(title) << "</title>"
         "<link rel=\"icon\" href=\"/images/lighthouse-1893-crest.png\" type=\"image/png\">"
         "<style>body{margin:0;background:#0b1c3d;color:#f6f8fc;font:18px/1.5 -apple-system,BlinkMacSystemFont,"
         "'Segoe UI',Roboto,sans-serif}main{max-width:560px;margin:0 auto;padding:48px 20px}"
         "h1{color:#ffcc00;font-size:28px;margin:0 0 16px}p{margin:0 0 12px}"
         "a{color:#ffcc00}</style></head><body><main><h1>"
      << esc(title) << "</h1>";
    std::istringstream lines(body);
    std::string line;
    while (std::getline(lines, line)) if (!line.empty()) h << "<p>" << esc(line) << "</p>";
    h << "<p><a href=\"/\">footballhome.org</a></p></main></body></html>";
    Response r(HttpStatus::OK, h.str());
    r.setHeader("Content-Type", "text/html; charset=utf-8");
    r.setHeader("Cache-Control", "no-store");
    return r;
}

}  // namespace

LockupController::LockupController() : model_(std::make_unique<FacilityLockup>()) {}
LockupController::~LockupController() = default;

void LockupController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/board",       [this](const Request& r) { return handleBoard(r); });
    router.get (prefix + "/tap",         [this](const Request& r) { return handleTap(r); });
    router.post(prefix + "/test",        [this](const Request& r) { return handleTest(r); });
    router.post(prefix + "/:id/confirm", [this](const Request& r) { return handleConfirm(r); });
}

bool LockupController::resolveScope(const Request& request, Scope* scope, Response* error) {
    if (!requireBearer(request)) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return false;
    }
    scope->userId   = bearerUserId(request);
    scope->personId = model_->personForUser(scope->userId);
    scope->isAdmin  = model_->isAdminUser(scope->userId);
    if (!model_->canView(scope->personId, scope->isAdmin)) {
        *error = jsonError(HttpStatus::FORBIDDEN, "The lock-up board is for club admins, coaches and the people on the lock-up list.");
        return false;
    }
    return true;
}

Response LockupController::handleBoard(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;
    try {
        model_->syncToday();
        json today = json::array();
        for (const auto& l : model_->todays()) today.push_back(model_->toJson(l));
        json hist = json::array();
        for (const auto& l : model_->history(30)) hist.push_back(model_->toJson(l));
        return jsonOut(HttpStatus::OK, {
            {"today", today}, {"history", hist}, {"people", model_->peopleJson()},
            {"is_admin", scope.isAdmin}, {"person_id", scope.personId},
        });
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/lockups/board] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response LockupController::handleConfirm(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;
    json body;
    if (!parseBody(request, &body, &error)) return error;
    long long id = 0;
    try { id = std::stoll(getPathParam(request, "id")); } catch (...) {}
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "bad lock-up id");
    try {
        FacilityLockup::Lockup l;
        if (!model_->get(id, &l)) return jsonError(HttpStatus::NOT_FOUND, "no such lock-up");
        if (l.confirmed()) return jsonOut(HttpStatus::OK, {{"already", true}, {"lockup", model_->toJson(l)}});
        model_->confirm(id, scope.personId, "board", strField(body, "note"));
        model_->get(id, &l);
        return jsonOut(HttpStatus::OK, {{"already", false}, {"lockup", model_->toJson(l)}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/lockups/confirm] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response LockupController::handleTap(const Request& request) {
    FacilityLockup::Lockup l;
    std::string firstName;
    std::string tier;
    try {
        switch (model_->confirmByToken(request.getQueryParam("t"), &l, &firstName)) {
            case FacilityLockup::TapOutcome::Confirmed: tier = "page_confirmed"; break;
            case FacilityLockup::TapOutcome::Already:   tier = "page_already";   break;
            default:                                    tier = "page_invalid";   break;
        }
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/lockups/tap] " << e.what() << std::endl;
        tier = "page_invalid";
    }
    const auto copy = MessageCopy().render("lockup", tier, model_->tokens(l, firstName, "", 0));
    if (!copy.ok()) return htmlPage("Football Home", "lockup/" + tier + " copy missing (migration 421)");
    return htmlPage(copy.subject, copy.body);
}

Response LockupController::handleTest(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;
    if (!scope.isAdmin) return jsonError(HttpStatus::FORBIDDEN, "Admins only");
    json body;
    if (!parseBody(request, &body, &error)) return error;
    const std::string channel = strField(body, "channel");
    if (channel != "email" && channel != "sms" && channel != "call")
        return jsonError(HttpStatus::BAD_REQUEST, "channel must be email, sms or call");
    try {
        model_->syncToday();
        // Tonight's row for the first facility (creating none): the copy
        // needs a real lock-up to log against.
        FacilityLockup::Lockup target;
        bool have = false;
        for (const auto& l : model_->todays()) if (l.id > 0) { target = l; have = true; break; }
        if (!have) return jsonError(HttpStatus::CONFLICT, "No lock-up tonight to test with (no events at a lock-up facility today).");
        // The caller's own contacts, whatever the list says.
        FacilityLockup::Recipient me;
        for (const auto& r : model_->recipients(target.id, "escalation")) if (r.personId == scope.personId) me = r;
        for (const auto& r : model_->recipients(target.id, "closer"))     if (r.personId == scope.personId && me.personId == 0) me = r;
        if (me.personId == 0) return jsonError(HttpStatus::CONFLICT, "You are not on the lock-up list for this facility (facility_lockup_people).");
        auto out = LockupScheduler::deliver(*model_, target, me, "test", channel, target.alertCount + 1);
        return jsonOut(HttpStatus::OK, {{"ok", out.ok}, {"contact", out.contact}, {"error", out.error},
                                        {"lockup", model_->toJson(target)}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/lockups/test] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
