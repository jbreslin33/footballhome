#include "InvoiceController.h"

#include <iostream>
#include <set>
#include <sstream>

#include "../database/Database.h"
#include "../models/Expenses.h"
#include "../models/WelcomeLog.h"
#include "../services/LeagueFixtureSync.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}
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

long long intField(const json& body, const char* key) {
    if (!body.contains(key)) return 0;
    if (body[key].is_number_integer()) return body[key].get<long long>();
    if (body[key].is_string()) { try { return std::stoll(body[key].get<std::string>()); } catch (...) {} }
    return 0;
}

// "/api/invoices/123" or "/api/invoices/123/update" → 123.
long long idFromPath(const std::string& path) {
    const std::string marker = "/api/invoices/";
    const auto at = path.find(marker);
    if (at == std::string::npos) return 0;
    std::string rest = path.substr(at + marker.size());
    const auto q = rest.find('?');
    if (q != std::string::npos) rest = rest.substr(0, q);
    const auto slash = rest.find('/');
    if (slash != std::string::npos) rest = rest.substr(0, slash);
    try { return std::stoll(rest); } catch (...) { return 0; }
}

long long queryId(const Request& request) {
    try { return std::stoll(request.getQueryParam("id")); } catch (...) { return 0; }
}

}  // namespace

InvoiceController::InvoiceController() : model_(std::make_unique<Invoice>()) {}
InvoiceController::~InvoiceController() = default;

void InvoiceController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/board",       [this](const Request& r) { return handleBoard(r); });
    // Referee fees to tick off (mig 490): the home games not yet on any
    // invoice, and one call that adds them as a Referees line.
    router.get (prefix + "/ref-fees",    [this](const Request& r) { return handleRefFees(r); });
    router.post(prefix + "/:id/ref-fees",[this](const Request& r) { return handleAddRefFees(r); });
    // 🧑‍⚖️ one fee on/off the sheet, or its amount (mig 624).
    router.post(prefix + "/:id/ref-fee-mark", [this](const Request& r) { return handleRefFeeMark(r); });
    router.post(prefix + "/new",         [this](const Request& r) { return handleNew(r); });
    router.post(prefix + "/plan",        [this](const Request& r) { return handlePlan(r); });
    router.del (prefix + "/plan",        [this](const Request& r) { return handleDeletePlan(r); });
    router.post(prefix + "/issuer",      [this](const Request& r) { return handleIssuer(r); });
    router.del (prefix + "/line",        [this](const Request& r) { return handleDeleteLine(r); });
    router.del (prefix + "/shift",       [this](const Request& r) { return handleDeleteShift(r); });
    router.post(prefix + "/default",     [this](const Request& r) { return handleDefault(r); });
    router.del (prefix + "/default",     [this](const Request& r) { return handleDeleteDefault(r); });
    router.del (prefix,                  [this](const Request& r) { return handleDelete(r); });
    router.get (prefix + "/public/:slug",[this](const Request& r) { return handlePublic(r); });
    // Param routes last so the static paths above win the prefix match.
    router.post(prefix + "/:id/update",  [this](const Request& r) { return handleUpdate(r); });
    router.post(prefix + "/:id/line",    [this](const Request& r) { return handleLine(r); });
    router.post(prefix + "/:id/shift",   [this](const Request& r) { return handleShift(r); });
    router.post(prefix + "/:id/fill",    [this](const Request& r) { return handleFill(r); });
    router.get (prefix + "/:id/games",   [this](const Request& r) { return handleGames(r); });
    router.post(prefix + "/:id/games",   [this](const Request& r) { return handleAddGames(r); });
    router.post(prefix + "/:id/event-mark", [this](const Request& r) { return handleEventMark(r); });
    router.get (prefix + "/:id",         [this](const Request& r) { return handleGet(r); });
}

bool InvoiceController::gate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "Invoices are for club admins.");
    return false;
}

Response InvoiceController::handleBoard(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try {
        json out = model_->board();
        // Planned expenses a line can count toward (mig 490, #finances).
        out["budget_lines"] = Expenses::openBudgetLines(WelcomeLog::kLighthouseClubId);
        // Who is looking, so the page can tell "my invoice" from a coach's
        // (different email wording, the coach gets cc'd).
        long long viewerPerson = 0;
        const long long userId = bearerUserId(request);
        if (userId > 0) {
            auto rows = Database::getInstance()->query("SELECT person_id FROM users WHERE id = $1::int", {std::to_string(userId)});
            if (!rows.empty() && !rows[0]["person_id"].is_null()) viewerPerson = rows[0]["person_id"].as<long long>();
        }
        out["viewer_person_id"] = viewerPerson;
        return jsonOut(HttpStatus::OK, out);
    }
    catch (const std::exception& e) { std::cerr << "[invoices board] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response InvoiceController::handleNew(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    const long long issuerId = intField(body, "issuer_id");
    if (issuerId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "issuer_id is required");
    const std::string date = body.contains("date") && body["date"].is_string() ? body["date"].get<std::string>() : "";
    try {
        std::string err;
        const long long id = model_->create(issuerId, date, &err);
        if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, err.empty() ? "could not create" : err);
        return jsonOut(HttpStatus::OK, {{"id", id}, {"invoice", model_->get(id)}});
    } catch (const std::exception& e) { std::cerr << "[invoices new] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response InvoiceController::handleGet(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = idFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
    try {
        // Reality check against gcal on every open (owner 2026-10-12): a
        // draft's day rows follow the calendar — cancelled events come off,
        // moved ones are re-dated.  Admin path only; the public link never
        // writes.
        json reality = model_->realityCheck(id);
        // 🧑‍⚖️ default-on ref fees (mig 624): the same open-time reconcile
        // puts the period's played fees on the sheet unless declined.
        try { autoAddRefFees(id); } catch (const std::exception& e) { std::cerr << "[invoices auto ref-fees] " << e.what() << std::endl; }
        json inv = model_->get(id);
        if (inv.empty()) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
        if (reality["removed"].get<int>() > 0 || reality["moved"].get<int>() > 0) inv["reality"] = reality;
        return jsonOut(HttpStatus::OK, inv);
    } catch (const std::exception& e) { std::cerr << "[invoices get] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// No gate: the page is for whoever holds the link (the deputy director,
// the coach).  The slug is a UUID, so the only way in is the link.
Response InvoiceController::handlePublic(const Request& request) {
    const std::string marker = "/api/invoices/public/";
    const std::string path = request.getPath();
    const auto at = path.find(marker);
    if (at == std::string::npos) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
    std::string slug = path.substr(at + marker.size());
    const auto q = slug.find('?'); if (q != std::string::npos) slug = slug.substr(0, q);
    const auto sl = slug.find('/'); if (sl != std::string::npos) slug = slug.substr(0, sl);
    try {
        json inv = model_->getPublic(slug);
        if (inv.empty()) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
        // Nothing the viewer should not have: the sheet fields only.
        inv.erase("public_slug"); inv.erase("link_url"); inv.erase("note");
        if (inv.contains("issuer") && inv["issuer"].is_object()) { inv["issuer"].erase("email"); inv["issuer"].erase("person_id"); }
        inv.erase("shifts"); inv.erase("shift_hours");
        if (inv.contains("bill_to") && inv["bill_to"].is_object()) { inv["bill_to"].erase("email"); inv["bill_to"].erase("email_to_name"); inv["bill_to"].erase("email_label"); }
        return jsonOut(HttpStatus::OK, inv);
    } catch (const std::exception& e) { std::cerr << "[invoices public] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response InvoiceController::handleUpdate(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = idFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    try {
        std::string err;
        if (!model_->update(id, body, &err)) return jsonError(HttpStatus::BAD_REQUEST, err);
        return jsonOut(HttpStatus::OK, model_->get(id));
    } catch (const std::exception& e) { std::cerr << "[invoices update] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response InvoiceController::handleLine(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = idFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    try {
        std::string err;
        const long long lineId = model_->upsertLine(id, intField(body, "id"), body, &err);
        if (lineId <= 0) return jsonError(HttpStatus::BAD_REQUEST, err);
        return jsonOut(HttpStatus::OK, model_->get(id));
    } catch (const std::exception& e) { std::cerr << "[invoices line] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response InvoiceController::handleDeleteLine(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = queryId(request);
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "id is required");
    try {
        if (!model_->removeLine(id)) return jsonError(HttpStatus::NOT_FOUND, "no such line");
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) { return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response InvoiceController::handleShift(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = idFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    try {
        std::string err;
        const long long shiftId = model_->upsertShift(id, intField(body, "id"), body, &err);
        if (shiftId <= 0) return jsonError(HttpStatus::BAD_REQUEST, err);
        return jsonOut(HttpStatus::OK, model_->get(id));
    } catch (const std::exception& e) { std::cerr << "[invoices shift] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response InvoiceController::handleDeleteShift(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = queryId(request);
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "id is required");
    try {
        if (!model_->removeShift(id)) return jsonError(HttpStatus::NOT_FOUND, "no such day");
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) { return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response InvoiceController::handleFill(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = idFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    const bool force = body.contains("force") && body["force"].is_boolean() && body["force"].get<bool>();
    try {
        std::string err;
        const int added = model_->applyDefaults(id, force, &err);
        if (added <= 0 && !err.empty()) return jsonError(HttpStatus::BAD_REQUEST, err);
        json out = model_->get(id);
        out["added"] = added;
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) { std::cerr << "[invoices fill] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response InvoiceController::handleDefault(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    const long long issuerId = intField(body, "issuer_id");
    if (issuerId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "issuer_id is required");
    try {
        std::string err;
        const long long id = model_->upsertDefaultShift(issuerId, intField(body, "id"), body, &err);
        if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, err);
        return jsonOut(HttpStatus::OK, {{"id", id}});
    } catch (const std::exception& e) { std::cerr << "[invoices default] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response InvoiceController::handleDeleteDefault(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = queryId(request);
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "id is required");
    try {
        if (!model_->removeDefaultShift(id)) return jsonError(HttpStatus::NOT_FOUND, "no such default");
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) { return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response InvoiceController::handlePlan(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    const long long issuerId = intField(body, "issuer_id");
    const long long invoiceId = intField(body, "invoice_id");
    if (issuerId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "issuer_id is required");
    try {
        std::string err;
        const long long planId = model_->createPlan(issuerId, invoiceId, body, &err);
        if (planId <= 0) return jsonError(HttpStatus::BAD_REQUEST, err);
        json out = {{"plan_id", planId}};
        if (invoiceId > 0) out["invoice"] = model_->get(invoiceId);
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) { std::cerr << "[invoices plan] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response InvoiceController::handleDeletePlan(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = queryId(request);
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "id is required");
    try {
        if (!model_->removePlan(id)) return jsonError(HttpStatus::NOT_FOUND, "no such plan");
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) { return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response InvoiceController::handleIssuer(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    const long long id = intField(body, "id");
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "id is required");
    try {
        std::string err;
        if (!model_->updateIssuer(id, body, &err)) return jsonError(HttpStatus::BAD_REQUEST, err);
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) { std::cerr << "[invoices issuer] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

Response InvoiceController::handleDelete(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = queryId(request);
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "id is required");
    try {
        if (!model_->remove(id)) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
        return jsonOut(HttpStatus::OK, {{"ok", true}});
    } catch (const std::exception& e) { return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// ─── games off the calendar (mig 531) ───────────────────────────────────────
// GET /api/invoices/:id/games → { games: [...] } — the period's matches of
// a team the issuer coaches (or whose policy pays them), with the hours a
// day row would get and whether it is already one.
Response InvoiceController::handleGames(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = idFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
    try {
        return jsonOut(HttpStatus::OK, {{"games", model_->periodGames(id)}});
    } catch (const std::exception& e) { std::cerr << "[invoices games] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// POST /api/invoices/:id/games { fh_event_ids: [...] } → the sheet, with
// `added`.  Each picked game becomes a day row (kick-off to the policy's
// hours, else the calendar length); games already on the days are skipped.
Response InvoiceController::handleAddGames(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = idFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    std::vector<long long> ids;
    if (body.contains("fh_event_ids") && body["fh_event_ids"].is_array())
        for (const auto& v : body["fh_event_ids"]) if (v.is_number()) ids.push_back(v.get<long long>());
    if (ids.empty()) return jsonError(HttpStatus::BAD_REQUEST, "tick at least one game");
    try {
        std::string err;
        const int added = model_->addGames(id, ids, false, &err);
        if (added <= 0 && !err.empty()) return jsonError(HttpStatus::BAD_REQUEST, err);
        json out = model_->get(id);
        out["added"] = added;
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) { std::cerr << "[invoices add games] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// POST /api/invoices/:id/event-mark {fh_event_id | gcal_event_id, mark:
// worked|no|clear} → the sheet.  One answer per calendar row (mig 573): ✓
// bills it, ✗ takes it off and remembers, clear goes back to unanswered.  A
// claimed raw calendar row (mig 577) keys on gcal_event_id instead.
Response InvoiceController::handleEventMark(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = idFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    const long long fhEventId = intField(body, "fh_event_id");
    const long long gcalEventId = intField(body, "gcal_event_id");
    const std::string mark = body.value("mark", "");
    if (fhEventId <= 0 && gcalEventId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id or gcal_event_id is required");
    if (mark != "worked" && mark != "no" && mark != "clear" && mark != "partial")
        return jsonError(HttpStatus::BAD_REQUEST, "mark must be worked, partial, no or clear");
    // 🟡 partial (mig 621): there for part of it — the hours actually worked.
    std::string hours;
    if (mark == "partial") {
        const double h = body.contains("hours") && body["hours"].is_number() ? body["hours"].get<double>() : 0.0;
        if (h <= 0 || h > 24) return jsonError(HttpStatus::BAD_REQUEST, "partial needs hours between 0 and 24");
        std::ostringstream o; o.setf(std::ios::fixed); o.precision(2); o << h;
        hours = o.str();
    }
    try {
        std::string err;
        const bool ok = fhEventId > 0 ? model_->markEvent(id, fhEventId, mark, &err, hours)
                                      : model_->markCalendarEvent(id, gcalEventId, mark, &err, hours);
        if (!ok) return jsonError(HttpStatus::BAD_REQUEST, err);
        return jsonOut(HttpStatus::OK, model_->get(id));
    } catch (const std::exception& e) { std::cerr << "[invoices event-mark] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// ─── referee fees (mig 490) ─────────────────────────────────────────────────
// GET /api/invoices/ref-fees → { games: [...] } — every game that could
// carry a referee fee (home AND away since mig 577 — "we need all 'Soccer
// Games' for potential ref fees") that is not on an invoice yet, played
// first.  The league feeds are pulled first so a just-published game is
// here.
Response InvoiceController::handleRefFees(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try {
        for (const auto& r : Database::getInstance()->query(
                "SELECT DISTINCT fixture_league_label AS l FROM ref_fee_policies WHERE club_id = $1::int AND is_active AND fixture_league_label IS NOT NULL",
                {std::to_string((long long)WelcomeLog::kLighthouseClubId)}))
            LeagueFixtureSync::refreshLeague(r["l"].c_str());
        // ?invoice=<id> (mig 624): the 📅 calendar's view — include the
        // fees billed on THAT invoice (on_this + their billed amount) and
        // the ones declined off it, so chips can read green / red.
        long long invId = 0;
        try { invId = std::stoll(request.getQueryParam("invoice")); } catch (...) {}
        std::set<long long> myLines; std::set<std::string> declined;
        if (invId > 0) {
            auto* db = Database::getInstance();
            for (const auto& r : db->query("SELECT id FROM invoice_lines WHERE invoice_id = $1::int AND category = 'referees'", {std::to_string(invId)}))
                myLines.insert(r["id"].as<long long>());
            for (const auto& r : db->query("SELECT source, ref_id FROM invoice_ref_declines WHERE invoice_id = $1::int", {std::to_string(invId)}))
                declined.insert(std::string(r["source"].c_str()) + ":" + r["ref_id"].c_str());
        }
        json games = json::array();
        for (auto g : Expenses::games(WelcomeLog::kLighthouseClubId, true)) {
            if (g["kind"] != "referee" || g["amount"].get<double>() <= 0) continue;
            if (!g["invoiced"].is_null()) {
                if (invId > 0 && myLines.count(g["invoiced"].value("line_id", 0LL))) {
                    g["on_this"] = true;
                    if (g["invoiced"].contains("amount")) g["paid_amount"] = g["invoiced"]["amount"];
                    games.push_back(g);
                }
                continue;   // billed elsewhere: never offered
            }
            if (invId > 0) g["declined"] = declined.count(g["source"].get<std::string>() + ":" + std::to_string(g["ref_id"].get<long long>())) > 0;
            games.push_back(g);
        }
        return jsonOut(HttpStatus::OK, {{"games", games}});
    } catch (const std::exception& e) { std::cerr << "[invoices ref-fees] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// POST /api/invoices/:id/ref-fees { games: [{source, ref_id}] } → the sheet.
// ONE Referees line per invoice (owner 2026-10-13: "when adding to refs we
// update the line item instead of 2 lines"): new picks become
// ref_fee_payments rows on the existing line and the line rebuilds from
// them; the first pick creates it.  Deleting the line frees the games.
Response InvoiceController::handleAddRefFees(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = idFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    try {
        std::string err;
        if (addRefFeesTo(id, body.value("games", json::array()), &err) <= 0) return jsonError(HttpStatus::BAD_REQUEST, err);
        return jsonOut(HttpStatus::OK, model_->get(id));
    } catch (const std::exception& e) { std::cerr << "[invoices add ref-fees] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}

// The ONE picked Referees line is the one carrying ref_fee_payments — a
// hand-added referees line (mig 701: Luke's "Youth games ref fees") has
// none, and merging picks into it would let syncRefLine overwrite its
// amount from payments alone.
static const std::string kPickedRefLine =
    "AND EXISTS (SELECT 1 FROM ref_fee_payments rp WHERE rp.invoice_line_id = l.id)";

long long InvoiceController::addRefFeesTo(long long invoiceId, const json& picks, std::string* error) {
    json line = Expenses::refLineFor(WelcomeLog::kLighthouseClubId, picks);
    if (line["items"].empty()) { *error = "pick at least one game that is not invoiced yet"; return 0; }
    long long lineId = 0;
    auto existing = Database::getInstance()->query(
        "SELECT id FROM invoice_lines l WHERE invoice_id = $1::int AND category = 'referees' " + kPickedRefLine + " ORDER BY id LIMIT 1",
        {std::to_string(invoiceId)});
    if (!existing.empty()) lineId = existing[0]["id"].as<long long>();
    else {
        lineId = model_->upsertLine(invoiceId, 0, {{"category", "referees"}, {"description", "Referees — " + line["description"].get<std::string>()},
                                                   {"quantity", line["quantity"]}, {"amount", line["amount"]}}, error);
        if (lineId <= 0) return 0;
    }
    Expenses::recordRefPayments(lineId, line["items"]);
    Expenses::syncRefLine(lineId);
    return lineId;
}

// 🧑‍⚖️ Ref fees default ONTO the sheet (mig 624; owner: "green (on the
// invoice) by default, with a toggle to turn one red").  Every open of a
// DRAFT whose issuer bills expenses adds the period's played, in-gcal
// fees that sit on no invoice — minus the ones deliberately declined.
void InvoiceController::autoAddRefFees(long long invoiceId) {
    auto* db = Database::getInstance();
    auto inv = db->query(
        "SELECT i.period_start::text AS ps, i.period_end::text AS pe, iss.bills_expenses "
        "  FROM invoices i JOIN invoice_issuers iss ON iss.id = i.issuer_id "
        " WHERE i.id = $1::int AND NOT i.is_final AND i.period_start IS NOT NULL AND i.period_end IS NOT NULL",
        {std::to_string(invoiceId)});
    if (inv.empty() || !inv[0]["bills_expenses"].as<bool>()) return;
    const std::string ps = inv[0]["ps"].c_str(), pe = inv[0]["pe"].c_str();
    std::set<std::string> declined;
    for (const auto& r : db->query("SELECT source, ref_id FROM invoice_ref_declines WHERE invoice_id = $1::int", {std::to_string(invoiceId)}))
        declined.insert(std::string(r["source"].c_str()) + ":" + r["ref_id"].c_str());
    json picks = json::array();
    for (const auto& g : Expenses::games(WelcomeLog::kLighthouseClubId, true)) {
        if (g["kind"] != "referee" || !g["invoiced"].is_null() || g["amount"].get<double>() <= 0) continue;
        if (!g["played"].get<bool>() || g["in_gcal"] == false) continue;
        const std::string on = g["game_on"].get<std::string>();
        if (on < ps || on > pe) continue;
        if (declined.count(g["source"].get<std::string>() + ":" + std::to_string(g["ref_id"].get<long long>()))) continue;
        picks.push_back({{"source", g["source"]}, {"ref_id", g["ref_id"]}});
    }
    if (picks.empty()) return;
    std::string err;
    addRefFeesTo(invoiceId, picks, &err);
}

// POST /api/invoices/:id/ref-fee-mark {source, ref_id, action, amount?}
// (mig 624) — action 'off' takes the one fee off the sheet and remembers
// the choice (the red chip; auto-add skips it), 'on' puts it back,
// 'amount' re-prices its ref_fee_payments row.  The ONE Referees line
// mirrors its payments throughout and goes away with its last fee.
Response InvoiceController::handleRefFeeMark(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = idFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    const std::string source = body.value("source", ""), action = body.value("action", "");
    const long long refId = intField(body, "ref_id");
    if (refId <= 0 || (source != "event" && source != "fixture"))
        return jsonError(HttpStatus::BAD_REQUEST, "source (event|fixture) and ref_id required");
    try {
        auto* db = Database::getInstance();
        auto fin = db->query("SELECT is_final FROM invoices WHERE id = $1::int", {std::to_string(id)});
        if (fin.empty()) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
        if (fin[0]["is_final"].as<bool>()) return jsonError(HttpStatus::BAD_REQUEST, "the invoice is final");
        const std::string match = (source == "fixture") ? "league_fixture_id" : "fh_event_id";
        auto lineQ = db->query("SELECT id FROM invoice_lines l WHERE invoice_id = $1::int AND category = 'referees' " + kPickedRefLine + " ORDER BY id LIMIT 1",
                               {std::to_string(id)});
        // A fixture's id can drift when the league feed re-syncs, so the
        // payment row is found by id OR by (date, opponent) — the same
        // fallback Expenses::games pairs them with.
        const std::string gameOn = body.value("game_on", ""), opponent = body.value("opponent", "");
        const std::string where = " WHERE invoice_line_id = $1::int AND (" + match + " = $2::bigint"
            " OR (NULLIF($3, '') IS NOT NULL AND game_on = NULLIF($3, '')::date AND opponent = $4))";
        if (action == "off") {
            if (!lineQ.empty()) {
                const long long lineId = lineQ[0]["id"].as<long long>();
                db->query("DELETE FROM ref_fee_payments" + where,
                          {std::to_string(lineId), std::to_string(refId), gameOn, opponent});
                auto left = db->query("SELECT 1 FROM ref_fee_payments WHERE invoice_line_id = $1::int LIMIT 1", {std::to_string(lineId)});
                if (left.empty()) db->query("DELETE FROM invoice_lines WHERE id = $1::int", {std::to_string(lineId)});
                else Expenses::syncRefLine(lineId);
            }
            db->query("INSERT INTO invoice_ref_declines (invoice_id, source, ref_id) VALUES ($1::int, $2, $3::bigint) ON CONFLICT DO NOTHING",
                      {std::to_string(id), source, std::to_string(refId)});
        } else if (action == "on") {
            db->query("DELETE FROM invoice_ref_declines WHERE invoice_id = $1::int AND source = $2 AND ref_id = $3::bigint",
                      {std::to_string(id), source, std::to_string(refId)});
            std::string err;
            if (addRefFeesTo(id, json::array({json{{"source", source}, {"ref_id", refId}}}), &err) <= 0)
                return jsonError(HttpStatus::BAD_REQUEST, err);
        } else if (action == "amount") {
            const double amt = body.value("amount", -1.0);
            if (amt < 0 || amt > 10000) return jsonError(HttpStatus::BAD_REQUEST, "amount must be between 0 and 10000");
            if (lineQ.empty()) return jsonError(HttpStatus::BAD_REQUEST, "that fee is not on the sheet");
            const long long lineId = lineQ[0]["id"].as<long long>();
            std::ostringstream amtStr; amtStr.setf(std::ios::fixed); amtStr.precision(2); amtStr << amt;
            db->query("UPDATE ref_fee_payments SET amount_usd = $5::numeric" + where,
                      {std::to_string(lineId), std::to_string(refId), gameOn, opponent, amtStr.str()});
            Expenses::syncRefLine(lineId);
        } else return jsonError(HttpStatus::BAD_REQUEST, "action must be off, on or amount");
        db->query("UPDATE invoices SET updated_at = now() WHERE id = $1::int", {std::to_string(id)});
        return jsonOut(HttpStatus::OK, model_->get(id));
    } catch (const std::exception& e) { std::cerr << "[invoices ref-fee-mark] " << e.what() << std::endl; return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what()); }
}
