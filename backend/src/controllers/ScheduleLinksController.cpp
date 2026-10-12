#include "ScheduleLinksController.h"

#include <iostream>

#include "../database/Database.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
bool parseBody(const Request& request, json* body, Response* error) {
    try {
        *body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        if (!body->is_object()) *body = json::object();
        return true;
    } catch (const std::exception& e) {
        *error = jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
        return false;
    }
}
}  // namespace

ScheduleLinksController::ScheduleLinksController() {}

bool ScheduleLinksController::gate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "League schedules are for club admins.");
    return false;
}

void ScheduleLinksController::registerRoutes(Router& router, const std::string& prefix) {
    router.get   (prefix, [this](const Request& r) { return handleList(r); });
    router.post  (prefix, [this](const Request& r) { return handleUpsert(r); });
    router.del  (prefix, [this](const Request& r) { return handleRemove(r); });
}

json ScheduleLinksController::links() {
    json out = json::array();
    auto rows = Database::getInstance()->query(
        "SELECT id, label, url, note, sort_order FROM league_schedule_links "
        "WHERE is_active ORDER BY sort_order, id");
    for (const auto& r : rows) {
        out.push_back({{"id", r["id"].as<long long>()}, {"label", str(r, "label")}, {"url", str(r, "url")},
                       {"note", str(r, "note")}, {"sort_order", r["sort_order"].as<int>()}});
    }
    return out;
}

Response ScheduleLinksController::handleList(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try { return jsonOut(HttpStatus::OK, {{"links", links()}}); }
    catch (const std::exception& e) { std::cerr << "[schedule-links] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response ScheduleLinksController::handleUpsert(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    const long long id = body.contains("id") && body["id"].is_number() ? body["id"].get<long long>() : 0;
    const std::string label = body.contains("label") && body["label"].is_string() ? body["label"].get<std::string>() : "";
    const std::string url = body.contains("url") && body["url"].is_string() ? body["url"].get<std::string>() : "";
    const std::string note = body.contains("note") && body["note"].is_string() ? body["note"].get<std::string>() : "";
    const int sort = body.contains("sort_order") && body["sort_order"].is_number() ? body["sort_order"].get<int>() : 0;
    if (label.empty()) return jsonError(HttpStatus::BAD_REQUEST, "label is required");
    if (url.rfind("http://", 0) != 0 && url.rfind("https://", 0) != 0) return jsonError(HttpStatus::BAD_REQUEST, "url must start with http(s)://");
    try {
        auto* db = Database::getInstance();
        if (id > 0) {
            db->query("UPDATE league_schedule_links SET label=$2, url=$3, note=NULLIF($4,''), sort_order=$5::int, updated_at=now() WHERE id=$1::int",
                      {std::to_string(id), label, url, note, std::to_string(sort)});
        } else {
            db->query("INSERT INTO league_schedule_links (label, url, note, sort_order) "
                      "VALUES ($1, $2, NULLIF($3,''), COALESCE(NULLIF($4,'0')::int, (SELECT COALESCE(MAX(sort_order),0)+10 FROM league_schedule_links)))",
                      {label, url, note, std::to_string(sort)});
        }
        return jsonOut(HttpStatus::OK, {{"links", links()}});
    } catch (const std::exception& e) { std::cerr << "[schedule-links upsert] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response ScheduleLinksController::handleRemove(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    long long id = 0;
    if (request.hasQueryParam("id")) { try { id = std::stoll(request.getQueryParam("id")); } catch (...) {} }
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "id is required");
    try {
        Database::getInstance()->query("UPDATE league_schedule_links SET is_active=false, updated_at=now() WHERE id=$1::int", {std::to_string(id)});
        return jsonOut(HttpStatus::OK, {{"links", links()}});
    } catch (const std::exception& e) { std::cerr << "[schedule-links remove] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}
