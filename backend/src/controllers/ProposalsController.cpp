#include "ProposalsController.h"

#include <iostream>

#include "../models/Proposals.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
}

ProposalsController::ProposalsController() {}

bool ProposalsController::gate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "Proposals are for club admins.");
    return false;
}

void ProposalsController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix + "/public/:code", [this](const Request& r) { return handlePublic(r); });
    router.post(prefix + "/recipients/:id", [this](const Request& r) { return handleRecipientEmail(r); });
    router.get(prefix,            [this](const Request& r) { return handleList(r); });
    router.get(prefix + "/:code", [this](const Request& r) { return handleOne(r); });
}

Response ProposalsController::handleList(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try {
        return jsonOut(HttpStatus::OK, {{"proposals", Proposals::list()}});
    } catch (const std::exception& e) {
        std::cerr << "[ProposalsController::list] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load proposals");
    }
}

Response ProposalsController::handleOne(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const std::string path = request.getPath();
    const std::string code = path.substr(path.find_last_of('/') + 1);
    try {
        json p = Proposals::one(code);
        if (p.is_null()) return jsonError(HttpStatus::NOT_FOUND, "No such proposal");
        return jsonOut(HttpStatus::OK, {{"proposal", p}, {"recipients", Proposals::recipients()}});
    } catch (const std::exception& e) {
        std::cerr << "[ProposalsController::one] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the proposal");
    }
}

// No login: the standalone page /proposals/#<code> shows a proposal flagged
// is_public to anyone who has its link.  The page wording rides along.
Response ProposalsController::handlePublic(const Request& request) {
    const std::string path = request.getPath();
    const std::string code = path.substr(path.find_last_of('/') + 1);
    try {
        json copy = Proposals::copy();
        json p = Proposals::onePublic(code);
        if (p.is_null()) return jsonOut(HttpStatus::NOT_FOUND, {{"error", copy.value("public_missing", "")}, {"copy", copy}});
        return jsonOut(HttpStatus::OK, {{"proposal", p}, {"copy", copy}});
    } catch (const std::exception& e) {
        std::cerr << "[ProposalsController::public] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the proposal");
    }
}

// POST /api/proposals/recipients/:id  { email }  — club admins set (or clear)
// the address a proposal is emailed to.
Response ProposalsController::handleRecipientEmail(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const std::string path = request.getPath();
    try {
        const int id = std::stoi(path.substr(path.find_last_of('/') + 1));
        json body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        const std::string email = body.is_object() ? body.value("email", std::string()) : std::string();
        if (!email.empty() && (email.find('@') == std::string::npos || email.find(' ') != std::string::npos)) {
            return jsonError(HttpStatus::BAD_REQUEST, "That is not an email address.");
        }
        if (!Proposals::setRecipientEmail(id, email)) return jsonError(HttpStatus::NOT_FOUND, "No such recipient");
        return jsonOut(HttpStatus::OK, {{"recipients", Proposals::recipients()}});
    } catch (const std::exception& e) {
        std::cerr << "[ProposalsController::recipientEmail] " << e.what() << std::endl;
        return jsonError(HttpStatus::BAD_REQUEST, "Could not save the email address");
    }
}
