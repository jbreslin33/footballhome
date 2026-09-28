#include "InvoiceController.h"

#include <iostream>

#include "../database/Database.h"
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
        json inv = model_->get(id);
        if (inv.empty()) return jsonError(HttpStatus::NOT_FOUND, "no such invoice");
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
