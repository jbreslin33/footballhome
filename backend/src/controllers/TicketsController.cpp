#include "TicketsController.h"

#include <iostream>

#include "../database/Database.h"
#include "../models/Tickets.h"
#include "../services/TicketOrderSync.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

json bodyOf(const Request& request) {
    try {
        json b = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        return b.is_object() ? b : json::object();
    } catch (...) { return json::object(); }
}

long long eventOf(const json& b) {
    if (!b.contains("e")) return 0;
    try { return b["e"].is_number() ? b["e"].get<long long>() : std::stoll(b["e"].get<std::string>()); }
    catch (...) { return 0; }
}

int intOf(const json& b, const char* key, int dflt) {
    if (!b.contains(key)) return dflt;
    try { return b[key].is_number() ? b[key].get<int>() : std::stoi(b[key].get<std::string>()); }
    catch (...) { return dflt; }
}

std::string strOf(const json& b, const char* key) {
    if (!b.contains(key) || b[key].is_null()) return "";
    if (b[key].is_string()) return b[key].get<std::string>();
    return b[key].dump();
}
}  // namespace

TicketsController::TicketsController() {}

void TicketsController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix + "/public/on-sale", [this](const Request& r) { return handleOnSale(r); });
    router.get(prefix + "/public/ticket",  [this](const Request& r) { return handleTicket(r); });
    router.get(prefix + "/gate/games",     [this](const Request& r) { return handleGames(r); });
    router.get(prefix + "/gate/summary",   [this](const Request& r) { return handleSummary(r); });
    router.post(prefix + "/gate/scan",     [this](const Request& r) { return handleScan(r); });
    router.post(prefix + "/gate/sell",     [this](const Request& r) { return handleSell(r); });
    router.post(prefix + "/gate/count",    [this](const Request& r) { return handleCount(r); });
    router.get(prefix + "/list",           [this](const Request& r) { return handleList(r); });
}

int TicketsController::callerPersonId(const Request& request) {
    const long long userId = bearerUserId(request);
    if (!userId) return 0;
    try {
        auto r = Database::getInstance()->query(
            "SELECT person_id FROM users WHERE id = $1::int LIMIT 1", {std::to_string(userId)});
        return r.empty() || r[0]["person_id"].is_null() ? 0 : r[0]["person_id"].as<int>();
    } catch (...) { return 0; }
}

bool TicketsController::adminAllowed(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "Tickets are for club admins.");
    return false;
}

bool TicketsController::gateAllowed(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    if (requireBearer(request) && Tickets::isGateStaff(callerPersonId(request))) return true;
    *error = jsonError(denialStatus(request), "The gate is for club admins and gate staff.");
    return false;
}

Response TicketsController::handleOnSale(const Request&) {
    try { return jsonOut(HttpStatus::OK, {{"products", Tickets::onSale()}}); }
    catch (const std::exception& e) {
        std::cerr << "[TicketsController::onSale] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load tickets");
    }
}

// No login: the token is the key.
Response TicketsController::handleTicket(const Request& request) {
    try {
        json t = Tickets::publicTicket(request.getQueryParam("k"));
        if (t.is_null()) return jsonError(HttpStatus::NOT_FOUND, "No such ticket");
        return jsonOut(HttpStatus::OK, {{"ticket", t}});
    } catch (const std::exception& e) {
        std::cerr << "[TicketsController::ticket] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the ticket");
    }
}

Response TicketsController::handleGames(const Request& request) {
    Response denied; if (!gateAllowed(request, &denied)) return denied;
    try {
        TicketOrderSync::refreshIfStale();
        json sources = json::array();
        for (const auto& r : Database::getInstance()->query(
                "SELECT code, label, icon FROM ticket_sources WHERE is_gate ORDER BY sort_order")) {
            sources.push_back({{"code", r["code"].c_str()}, {"label", r["label"].c_str()}, {"icon", r["icon"].c_str()}});
        }
        auto single = Database::getInstance()->query(
            "SELECT price::text AS price FROM ticket_products WHERE code = 'single-game' AND is_active");
        return jsonOut(HttpStatus::OK, {{"games", Tickets::gateGames()}, {"sources", sources},
                                        {"singlePrice", single.empty() ? "" : single[0]["price"].c_str()},
                                        {"isAdmin", requireAdminLevel(request, {"club", "super"})}});
    } catch (const std::exception& e) {
        std::cerr << "[TicketsController::games] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the games");
    }
}

Response TicketsController::handleSummary(const Request& request) {
    Response denied; if (!gateAllowed(request, &denied)) return denied;
    try {
        const long long e = std::stoll(request.getQueryParam("e"));
        return jsonOut(HttpStatus::OK, {{"summary", Tickets::gateSummary(e)}});
    } catch (const std::exception& e) {
        std::cerr << "[TicketsController::summary] " << e.what() << std::endl;
        return jsonError(HttpStatus::BAD_REQUEST, "Could not load the gate");
    }
}

Response TicketsController::handleScan(const Request& request) {
    Response denied; if (!gateAllowed(request, &denied)) return denied;
    json b = bodyOf(request);
    const long long e = eventOf(b);
    if (!e) return jsonError(HttpStatus::BAD_REQUEST, "Pick a game.");
    try {
        TicketOrderSync::refreshIfStale();
        json scan = Tickets::scan(e, strOf(b, "code"), intOf(b, "n", 0), callerPersonId(request));
        return jsonOut(HttpStatus::OK, {{"scan", scan}, {"summary", Tickets::gateSummary(e)}});
    } catch (const std::exception& ex) {
        std::cerr << "[TicketsController::scan] " << ex.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not check the ticket");
    }
}

Response TicketsController::handleSell(const Request& request) {
    Response denied; if (!gateAllowed(request, &denied)) return denied;
    json b = bodyOf(request);
    const long long e = eventOf(b);
    if (!e) return jsonError(HttpStatus::BAD_REQUEST, "Pick a game.");
    try {
        json sale = Tickets::sell(e, strOf(b, "source"), intOf(b, "people", 1), strOf(b, "amount"),
                                  strOf(b, "name"), strOf(b, "phone"), callerPersonId(request));
        if (sale.contains("error")) return jsonError(HttpStatus::BAD_REQUEST, sale["error"].get<std::string>());
        return jsonOut(HttpStatus::OK, {{"sale", sale}, {"summary", Tickets::gateSummary(e)}});
    } catch (const std::exception& ex) {
        std::cerr << "[TicketsController::sell] " << ex.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not record the sale");
    }
}

Response TicketsController::handleCount(const Request& request) {
    Response denied; if (!gateAllowed(request, &denied)) return denied;
    json b = bodyOf(request);
    const long long e = eventOf(b);
    if (!e) return jsonError(HttpStatus::BAD_REQUEST, "Pick a game.");
    try {
        return jsonOut(HttpStatus::OK, {{"summary", Tickets::count(e, intOf(b, "n", 0), callerPersonId(request))}});
    } catch (const std::exception& ex) {
        std::cerr << "[TicketsController::count] " << ex.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not count");
    }
}

Response TicketsController::handleList(const Request& request) {
    Response denied; if (!adminAllowed(request, &denied)) return denied;
    try {
        json sync = TicketOrderSync::refreshIfStale(request.getQueryParam("sync") == "1");
        return jsonOut(HttpStatus::OK, {{"tickets", Tickets::list()}, {"sync", sync}});
    } catch (const std::exception& e) {
        std::cerr << "[TicketsController::list] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the tickets");
    }
}
