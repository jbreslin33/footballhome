#include "MessageTemplateController.h"

#include "../core/Controller.h"
#include "../models/WelcomeLog.h"
#include "../models/DuesPolicy.h"
#include "../third_party/json.hpp"

#include <cctype>
#include <iostream>
#include <sstream>
#include <vector>

using nlohmann::json;

namespace {

std::string quoteJson(const std::string& value) {
    std::ostringstream escaped;
    escaped << '"';
    for (char ch : value) {
        switch (ch) {
            case '"': escaped << "\\\""; break;
            case '\\': escaped << "\\\\"; break;
            case '\n': escaped << "\\n"; break;
            case '\r': escaped << "\\r"; break;
            case '\t': escaped << "\\t"; break;
            default: escaped << ch; break;
        }
    }
    escaped << '"';
    return escaped.str();
}

std::string normalizeCategory(const std::string& value) {
    std::string out;
    out.reserve(value.size());
    for (unsigned char ch : value) {
        if (std::isalnum(ch)) {
            out.push_back(static_cast<char>(std::tolower(ch)));
        }
    }
    return out;
}

} // namespace

MessageTemplateController::MessageTemplateController() {
    db_ = Database::getInstance();
}

void MessageTemplateController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& request) {
        return this->handleList(request);
    });
    router.get(prefix + "/copy", [this](const Request& request) {
        return this->handleClientCopy(request);
    });
}

// GET /api/messages/templates/copy — everything the browser needs to draft
// a message without holding any wording itself (migration 367): the
// client_side templates (form links already resolved), and the mailbox
// compose links open as.  Rendered by frontend/js/lib/message-copy.js.
// Any signed-in user: coaches use the roster boards too, and nothing
// here is secret — it is the text they are about to send.
Response MessageTemplateController::handleClientCopy(const Request& request) {
    if (!requireBearer(request)) {
        return Response(HttpStatus::UNAUTHORIZED, createJSONResponse(false, "Unauthorized"));
    }
    try {
        const std::string clubId = std::to_string(WelcomeLog::kLighthouseClubId);
        pqxx::result rows = db_->query(R"(
            SELECT kind, tier, COALESCE(fh_fill_form_links(subject, $1::int), '') AS subject,
                   fh_fill_form_links(body, $1::int) AS body
              FROM message_templates
             WHERE is_active AND client_side
             ORDER BY sort_order, id
        )", {clubId});
        nlohmann::json templates = nlohmann::json::array();
        for (const auto& row : rows) {
            templates.push_back({{"kind", row["kind"].c_str()}, {"tier", row["tier"].c_str()},
                                 {"subject", row["subject"].c_str()}, {"body", row["body"].c_str()}});
        }
        pqxx::result club = db_->query(
            "SELECT COALESCE(outreach_email, '') AS em FROM clubs WHERE id = $1::int", {clubId});
        // Dues policy (migration 401) rides along: billing-badge.js and the
        // roster / payments screens do prorate and months-behind math with
        // it, and no screen may carry the number itself.
        const DuesPolicy::Row dues = DuesPolicy::current();
        nlohmann::json out = {
            {"templates", templates},
            {"outreach_email", club.empty() ? "" : club[0]["em"].c_str()},
            {"dues_policy", {{"monthly_dues_usd", dues.monthlyDuesUsd},
                             {"pause_after_months", dues.pauseAfterMonths}}},
        };
        return Response(HttpStatus::OK, createJSONResponse(true, "Message copy", out.dump()));
    } catch (const std::exception& e) {
        std::cerr << "Error in MessageTemplateController::handleClientCopy: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Database error"));
    }
}

Response MessageTemplateController::handleList(const Request& request) {
    // kind=registration rows are the per-card league-form nudges on the
    // roster boards (migration 356), which coaches open too — a signed-in
    // user is enough for those.  Everything else stays admin-only.
    const std::string kind = request.getQueryParam("kind");
    const bool signedIn = (kind == "registration")
        ? requireBearer(request)
        : requireAdminLevel(request, {"club", "super", "marketing"});
    if (!signedIn) {
        return Response(HttpStatus::UNAUTHORIZED, createJSONResponse(false, "Unauthorized"));
    }
    try {
        std::string query = R"(
            SELECT id, category, label, kind, tier, icon, subject,
                   fh_fill_form_links(body, $1::int)      AS body,
                   fh_fill_form_links(html_body, $1::int) AS html_body,
                   is_active, sort_order
            FROM message_templates
            WHERE is_active = true
        )";
        // $1 = club whose club_forms rows resolve {form:<code>} links in
        // the copy (migration 365).
        std::vector<std::string> params{std::to_string(WelcomeLog::kLighthouseClubId)};
        const std::string category = request.getQueryParam("category");
        if (!category.empty()) {
            params.push_back(normalizeCategory(category));
            query += " AND lower(regexp_replace(category, '[^[:alnum:]]+', '', 'g')) = $"
                   + std::to_string(params.size()) + "::text";
        }
        // kind=registration → the per-card league-form nudges the roster
        // boards render as 💬/✉ buttons (migration 356).  Omitted → every
        // active template, which is what the Messages screen wants.
        if (!kind.empty()) {
            params.push_back(kind);
            query += " AND kind = $" + std::to_string(params.size()) + "::text";
        }
        query += " ORDER BY sort_order, id";

        pqxx::result result = db_->query(query, params);

        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;

            json << "{";
            json << "\"id\":" << row["id"].as<long long>() << ",";
            json << "\"category\":" << quoteJson(row["category"].as<std::string>()) << ",";
            json << "\"label\":" << quoteJson(row["label"].as<std::string>()) << ",";
            json << "\"kind\":" << quoteJson(row["kind"].as<std::string>()) << ",";
            json << "\"tier\":" << quoteJson(row["tier"].as<std::string>()) << ",";
            json << "\"icon\":" << (row["icon"].is_null() ? "null" : quoteJson(row["icon"].as<std::string>())) << ",";
            json << "\"subject\":" << (row["subject"].is_null() ? "null" : quoteJson(row["subject"].as<std::string>())) << ",";
            json << "\"body\":" << (row["body"].is_null() ? "null" : quoteJson(row["body"].as<std::string>())) << ",";
            json << "\"html_body\":" << (row["html_body"].is_null() ? "null" : quoteJson(row["html_body"].as<std::string>())) << ",";
            json << "\"is_active\":" << (row["is_active"].as<bool>() ? "true" : "false") << ",";
            json << "\"sort_order\":" << row["sort_order"].as<int>();
            json << "}";
        }
        json << "]";

        return Response(HttpStatus::OK, createJSONResponse(true, "Templates retrieved", json.str()));
    } catch (const std::exception& e) {
        std::cerr << "Error in MessageTemplateController::handleList: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Database error"));
    }
}
