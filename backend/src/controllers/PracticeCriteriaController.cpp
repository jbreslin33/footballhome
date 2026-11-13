#include "PracticeCriteriaController.h"

#include <iostream>

#include "../database/Database.h"
#include "../models/MessageCopy.h"
#include "../models/StarterCriteria.h"
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

bool isStaff(long long userId) {
    auto* db = Database::getInstance();
    if (!db->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1", {std::to_string(userId)}).empty()) return true;
    return !db->query(
        "SELECT 1 FROM users u "
        "  JOIN coaches co      ON co.person_id = u.person_id "
        "  JOIN team_coaches tc ON tc.coach_id = co.id AND tc.ended_at IS NULL "
        " WHERE u.id = $1::int LIMIT 1", {std::to_string(userId)}).empty();
}

std::string str(const json& b, const char* k) {
    return b.contains(k) && b[k].is_string() ? b[k].get<std::string>() : std::string{};
}

long long num(const json& b, const char* k) {
    if (!b.contains(k)) return 0;
    if (b[k].is_number_integer()) return b[k].get<long long>();
    if (b[k].is_string()) { try { return std::stoll(b[k].get<std::string>()); } catch (...) {} }
    return 0;
}

// The practice-day line's tier: what this day did or will do for him.
std::string lineTier(const StarterCriteria::Practice& p) {
    if (p.future) return p.rsvp == "yes" ? "line_going" : p.rsvp == "no" ? "line_out" : "line_open";
    if (p.status == "excused") return "line_excused";
    return p.counted ? "line_attended" : "line_missed";
}

}  // namespace

PracticeCriteriaController::PracticeCriteriaController() : model_(std::make_unique<StarterCriteria>()) {}
PracticeCriteriaController::~PracticeCriteriaController() = default;

void PracticeCriteriaController::registerRoutes(Router& router, const std::string& prefix) {
    router.post(prefix + "/message", [this](const Request& r) { return handleMessage(r); });
}

Response PracticeCriteriaController::handleMessage(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");

    json body;
    try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); }
    catch (const std::exception& e) { return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what()); }
    const long long personId = num(body, "person_id");
    const std::string channel = str(body, "channel");
    const std::string contact = str(body, "contact");
    if (personId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "person_id required");
    if (channel != "email" && channel != "sms" && channel != "copy")
        return jsonError(HttpStatus::BAD_REQUEST, "channel must be email, sms or copy");
    if (channel != "copy" && contact.empty()) return jsonError(HttpStatus::BAD_REQUEST, "contact required");

    try {
        if (!isStaff(userId)) return jsonError(HttpStatus::FORBIDDEN, "For club admins and coaches.");
        auto* db = Database::getInstance();
        const auto person = db->query("SELECT COALESCE(first_name, '') AS fn FROM persons WHERE id = $1::int",
                                      {std::to_string(personId)});
        if (person.empty()) return jsonError(HttpStatus::NOT_FOUND, "Person not found");

        MessageCopy copy;
        const auto r = model_->forPerson(personId);
        if (!r) {
            const auto none = copy.render("practice_criteria", "not_going", {{"first", person[0]["fn"].c_str()}});
            return jsonError(HttpStatus::NOT_FOUND, none.ok() ? none.body : "Not Going to a game in the next week.");
        }

        const auto days = [&](long long n) {
            const auto x = copy.render("practice_criteria", n == 1 ? "day_one" : "day_many", {{"n", std::to_string(n)}});
            return x.ok() ? x.body : std::to_string(n);
        };
        std::string practices;
        for (const auto& p : r->practices) {
            const auto line = copy.render("practice_criteria", lineTier(p), {{"when", p.when}});
            if (!line.ok()) continue;
            practices += (practices.empty() ? "" : "\n") + line.body;
        }
        const std::string tier =
            (r->state == "exceeding" || r->state == "exceeding_projected" || r->state == "met") ? "met"
            : r->state == "projected" ? "projected"
            : r->state == "needs" ? "short" : "not_met";
        const long long shortBy = std::max(0LL, r->needed - r->attended - r->projected);

        const auto minted = channel == "copy"
            ? MagicLinkService::mint(personId, "sms", "", userId, 0, r->matchId)
            : MagicLinkService::mint(personId, channel, contact, userId, 0, r->matchId);
        const MessageCopy::Tokens tokens = {
            {"first", person[0]["fn"].c_str()},
            {"game", r->game},
            {"when", r->when},
            {"needed", days(r->needed)},
            {"attended", std::to_string(r->attended)},
            {"projected", std::to_string(r->projected)},
            {"short", days(shortBy)},
            {"practices", practices},
            {"link", minted.url},
        };
        const auto msg = copy.render("practice_criteria", tier, tokens);
        if (!msg.ok()) return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "practice_criteria words missing (migration 1342)");
        const auto subj = copy.render("practice_criteria", "subject", tokens);

        json out = {
            {"url", minted.url}, {"expires_at", minted.expiresIso},
            {"state", r->state}, {"tier", tier},
            {"needed", r->needed}, {"attended", r->attended}, {"projected", r->projected},
            {"sms_body", msg.body},
        };
        if (channel != "copy") copy.addComposeHrefs(out, channel, contact, subj.ok() ? subj.body : "", msg.body, msg.body);
        return jsonOut(HttpStatus::CREATED, out);
    } catch (const std::exception& e) {
        std::cerr << "PracticeCriteriaController::handleMessage: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
