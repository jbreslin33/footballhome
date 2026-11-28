#include "SessionPlansController.h"

#include <iostream>
#include <sstream>
#include <vector>

#include "../database/Database.h"
#include "../models/EventAccess.h"
#include "../models/SessionPlans.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

std::vector<std::string> segments(const std::string& path) {
    // after /api/session-plans/
    std::vector<std::string> out;
    const std::string key = "/session-plans";
    auto p = path.find(key);
    std::string rest = p == std::string::npos ? "" : path.substr(p + key.size());
    auto q = rest.find('?'); if (q != std::string::npos) rest = rest.substr(0, q);
    std::stringstream ss(rest); std::string seg;
    while (std::getline(ss, seg, '/')) if (!seg.empty()) out.push_back(seg);
    return out;
}
long long num(const std::string& s) { try { return std::stoll(s); } catch (...) { return 0; } }
}

SessionPlansController::SessionPlansController() {}

void SessionPlansController::registerRoutes(Router& router, const std::string& prefix) {
    for (const char* pat : {"/teams", "/team/:a", "/event/:a"})
        router.get(prefix + pat, [this](const Request& r) { return handle(r, "GET"); });
    for (const char* pat : {"/team/:a/items", "/event/:a/edit", "/event/:a/items"})
        router.post(prefix + pat, [this](const Request& r) { return handle(r, "POST"); });
    for (const char* pat : {"/team/:a/theme", "/items/:k/:a"})
        router.put(prefix + pat, [this](const Request& r) { return handle(r, "PUT"); });
    for (const char* pat : {"/items/:k/:a", "/event/:a/edit"})
        router.del(prefix + pat, [this](const Request& r) { return handle(r, "DELETE"); });
}

Response SessionPlansController::handle(const Request& request, const std::string& method) {
    const long long uid = bearerUserId(request);
    if (uid <= 0) return jsonError(denialStatus(request), "Sign in to see session plans.");
    try {
        auto* db = Database::getInstance();
        auto who = db->query("SELECT person_id FROM users WHERE id = $1::bigint", {std::to_string(uid)});
        const long long personId = (who.empty() || who[0][0].is_null()) ? 0 : who[0][0].as<long long>();
        bool clubAdmin = !db->query(
            "SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id "
            " WHERE a.user_id = $1::bigint AND al.name IN ('club','super')", {std::to_string(uid)}).empty();
        json body = json::object();
        if (!request.getBody().empty()) {
            body = json::parse(request.getBody(), nullptr, false);
            if (body.is_discarded() || !body.is_object()) return jsonError(HttpStatus::BAD_REQUEST, "Bad body");
        }
        const auto seg = segments(request.getPath());
        auto forbid = [&]() { return jsonError(HttpStatus::FORBIDDEN, "Only the team's coaches can change this plan."); };
        auto exerciseId = [&]() { return body.contains("exercise_id") && body["exercise_id"].is_number_integer() ? body["exercise_id"].get<int>() : 0; };
        auto minutes = [&]() { return body.contains("minutes") && body["minutes"].is_number_integer() ? body["minutes"].get<int>() : 0; };

        if (seg.size() == 1 && seg[0] == "teams" && method == "GET")
            return jsonOut(HttpStatus::OK, {{"teams", SessionPlans::teamsFor(personId, clubAdmin)}});

        if (seg.size() >= 2 && seg[0] == "team") {
            const int teamId = (int)num(seg[1]);
            const bool can = SessionPlans::canPlanTeam(personId, clubAdmin, teamId);
            if (seg.size() == 2 && method == "GET") {
                json plan = SessionPlans::teamPlan(teamId);
                if (plan.is_null()) return jsonError(HttpStatus::NOT_FOUND, "No such team");
                plan["can_edit"] = can;
                return jsonOut(HttpStatus::OK, plan);
            }
            if (!can) return forbid();
            if (seg.size() == 3 && seg[2] == "items" && method == "POST") {
                if (!exerciseId() || !body.contains("slot")) return jsonError(HttpStatus::BAD_REQUEST, "exercise_id and slot needed");
                int id = SessionPlans::addToTemplate(teamId, body["slot"], exerciseId(), minutes());
                return jsonOut(HttpStatus::OK, {{"id", id}});
            }
            if (seg.size() == 3 && seg[2] == "theme" && method == "PUT") {
                SessionPlans::setTheme(teamId, body.value("slot", json::object()), body.value("theme", std::string()));
                return jsonOut(HttpStatus::OK, {{"ok", true}});
            }
        }

        if (seg.size() == 3 && seg[0] == "items" && (seg[1] == "template" || seg[1] == "event")) {
            const int itemId = (int)num(seg[2]);
            const long long owner = SessionPlans::itemOwner(seg[1], itemId);
            if (!owner) return jsonError(HttpStatus::NOT_FOUND, "No such item");
            const bool can = seg[1] == "template" ? SessionPlans::canPlanTeam(personId, clubAdmin, (int)owner)
                                                  : (personId && EventAccess::canCoach(db, personId, owner));
            if (!can) return forbid();
            if (method == "PUT") SessionPlans::updateItem(seg[1], itemId, body);
            else SessionPlans::deleteItem(seg[1], itemId);
            return jsonOut(HttpStatus::OK, {{"ok", true}});
        }

        if (seg.size() >= 2 && seg[0] == "event") {
            const long long ev = num(seg[1]);
            if (ev <= 0) return jsonError(HttpStatus::BAD_REQUEST, "Bad event");
            const bool canEvent = personId && EventAccess::canCoach(db, personId, ev);
            if (seg.size() == 2 && method == "GET") {
                json out = SessionPlans::eventSession(ev);
                if (out.is_null()) return jsonError(HttpStatus::NOT_FOUND, "No such event");
                out["can_edit"] = canEvent;
                out["can_edit_plan"] = !out["team"].is_null() && SessionPlans::canPlanTeam(personId, clubAdmin, out["team"]["id"].get<int>());
                return jsonOut(HttpStatus::OK, out);
            }
            if (!canEvent) return jsonError(HttpStatus::FORBIDDEN, "Only this event's coaches can change its session.");
            if (seg.size() == 3 && seg[2] == "edit" && method == "POST") { SessionPlans::startEventEdit(ev, personId); return jsonOut(HttpStatus::OK, {{"ok", true}}); }
            if (seg.size() == 3 && seg[2] == "edit" && method == "DELETE") { SessionPlans::resetEvent(ev); return jsonOut(HttpStatus::OK, {{"ok", true}}); }
            if (seg.size() == 3 && seg[2] == "items" && method == "POST") {
                if (!exerciseId()) return jsonError(HttpStatus::BAD_REQUEST, "exercise_id needed");
                return jsonOut(HttpStatus::OK, {{"id", SessionPlans::addToEvent(ev, exerciseId(), minutes(), personId)}});
            }
        }
        return jsonError(HttpStatus::NOT_FOUND, "Unknown session-plans route");
    } catch (const std::exception& e) {
        std::cerr << "[SessionPlansController] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the session plan");
    }
}
