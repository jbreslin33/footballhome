#include "SmsOptInBoardController.h"

#include <algorithm>
#include <iostream>

#include "../database/Database.h"
#include "../models/MessageCopy.h"
#include "../models/SmsOptInBoard.h"
#include "../services/MagicLinkService.h"
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

long long intField(const json& body, const char* key) {
    if (!body.contains(key) || !body[key].is_number_integer()) return 0;
    return body[key].get<long long>();
}

}  // namespace

SmsOptInBoardController::SmsOptInBoardController() : model_(std::make_unique<SmsOptInBoard>()) {}
SmsOptInBoardController::~SmsOptInBoardController() = default;

void SmsOptInBoardController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/teams",  [this](const Request& r) { return handleTeams(r); });
    router.get (prefix + "/roster", [this](const Request& r) { return handleRoster(r); });
    router.post(prefix + "/nudge",  [this](const Request& r) { return handleNudge(r); });
}

bool SmsOptInBoardController::Scope::covers(long long teamId) const {
    return isAdmin ||
           std::find(coachTeamIds.begin(), coachTeamIds.end(), teamId) != coachTeamIds.end();
}

bool SmsOptInBoardController::resolveScope(const Request& request, Scope* scope, Response* error) {
    if (!requireBearer(request)) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return false;
    }
    scope->userId = bearerUserId(request);
    auto* db = Database::getInstance();
    scope->isAdmin = !db->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1",
                                {std::to_string(scope->userId)}).empty();
    if (scope->isAdmin) return true;

    auto teams = db->query(
        "SELECT DISTINCT tc.team_id FROM team_coaches tc "
        "  JOIN coaches c ON c.id = tc.coach_id "
        "  JOIN users u ON u.person_id = c.person_id "
        " WHERE u.id = $1::int AND tc.ended_at IS NULL",
        {std::to_string(scope->userId)});
    for (const auto& row : teams) scope->coachTeamIds.push_back(row["team_id"].as<long long>());
    if (scope->coachTeamIds.empty()) {
        *error = jsonError(HttpStatus::FORBIDDEN,
                           "The texts board is for club admins and coaches of a team.");
        return false;
    }
    return true;
}

Response SmsOptInBoardController::handleTeams(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;
    try {
        return jsonOut(HttpStatus::OK, {{"teams", model_->teams(scope.coachTeamIds)}});
    } catch (const std::exception& e) {
        std::cerr << "SmsOptInBoardController::handleTeams: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response SmsOptInBoardController::handleRoster(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;

    long long teamId = 0;
    try { teamId = std::stoll(request.getQueryParam("team_id")); } catch (...) {}
    if (teamId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "team_id required");
    if (!scope.covers(teamId)) return jsonError(HttpStatus::FORBIDDEN, "Not one of your teams.");
    try {
        return jsonOut(HttpStatus::OK, {{"team_id", teamId}, {"players", model_->roster(teamId)}});
    } catch (const std::exception& e) {
        std::cerr << "SmsOptInBoardController::handleRoster: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /nudge { team_id, person_id }
// The message is a text from the operator's own phone (sms_href): the
// recipient's mobile from the DB, never the request, and a magic link —
// minted the one way every FH link is (MagicLinkService) — pointed at
// footballhome.org/sms?t=…, where the form lands pre-filled and the
// consent it writes is tied to the person.  Copy = message_templates
// kind sms_opt_in, tier adult | parent.
Response SmsOptInBoardController::handleNudge(const Request& request) {
    Scope scope;
    Response error(HttpStatus::OK, "");
    if (!resolveScope(request, &scope, &error)) return error;
    json body;
    try {
        body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }
    const long long teamId   = intField(body, "team_id");
    const long long personId = intField(body, "person_id");
    if (teamId <= 0 || personId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "team_id and person_id required");
    if (!scope.covers(teamId)) return jsonError(HttpStatus::FORBIDDEN, "Not one of your teams.");

    try {
        if (!model_->onTeam(teamId, personId)) return jsonError(HttpStatus::BAD_REQUEST, "That player is not on this team.");
        std::string senderName;
        {
            auto s = Database::getInstance()->query(
                "SELECT COALESCE(p.first_name,'') AS fn FROM users u JOIN persons p ON p.id = u.person_id WHERE u.id = $1::int",
                {std::to_string(scope.userId)});
            if (!s.empty()) senderName = s[0]["fn"].c_str();
        }
        // Each parent opts in for themself (mig 682): one nudge per parent,
        // or the ones in recipient_person_ids.
        std::vector<long long> picked = model_->recipients(personId);
        if (body.contains("recipient_person_ids") && body["recipient_person_ids"].is_array()) {
            std::vector<long long> want;
            for (const auto& v : body["recipient_person_ids"]) {
                if (!v.is_number_integer() || std::find(picked.begin(), picked.end(), v.get<long long>()) == picked.end())
                    return jsonError(HttpStatus::BAD_REQUEST, "recipient_person_ids must be this player's parents");
                want.push_back(v.get<long long>());
            }
            picked = want;
        }
        json sends = json::array();
        json nudges;
        for (const long long rid : picked) {
            const auto who = model_->person(personId, rid);
            if (!who.found) return jsonError(HttpStatus::NOT_FOUND, "Person not found");
            if (who.phone.empty()) continue;

            const auto minted = MagicLinkService::mint(who.recipientPersonId, "sms", who.phone, scope.userId);
            // The same token, on the sign-up page instead of the sign-in
            // endpoint: /sms?t=… reads it to pre-fill the form.
            const std::string link = MagicLinkService::publicBaseUrl() + "/sms?t=" + minted.token;

            MessageCopy copy;
            const auto msg = copy.render("sms_opt_in", who.youth ? "parent" : "adult", {
                {"first", who.recipientFirstName}, {"child", who.playerFirstName},
                {"link", link}, {"sender", senderName}});
            if (!msg.ok()) return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "sms_opt_in template missing (migration 537)");

            nudges = model_->logNudge(personId, who.recipientPersonId, "sms", who.phone, scope.userId);
            json one = {{"url", link}, {"expires_at", minted.expiresIso},
                        {"recipient_person_id", who.recipientPersonId}, {"recipient_name", who.recipientFirstName},
                        {"contact", who.phone}};
            copy.addComposeHrefs(one, "sms", who.phone, "", msg.body, msg.body);
            sends.push_back(std::move(one));
        }
        if (sends.empty()) return jsonError(HttpStatus::CONFLICT, "No mobile number on file.");
        // Top level = the first send (callers that predate mig 682).
        json out = sends[0];
        out["nudges"] = nudges;
        out["sends"] = sends;
        return jsonOut(HttpStatus::CREATED, out);
    } catch (const std::exception& e) {
        std::cerr << "SmsOptInBoardController::handleNudge: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not build the nudge");
    }
}
