#include "MessageTemplateController.h"

#include "../core/Controller.h"
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
}

Response MessageTemplateController::handleList(const Request& request) {
    try {
        std::string query = R"(
            SELECT id, category, label, kind, tier, subject, body, html_body, is_active, sort_order
            FROM message_templates
            WHERE is_active = true
        )";
        std::vector<std::string> params;
        const std::string category = request.getQueryParam("category");
        if (!category.empty()) {
            query += " AND lower(regexp_replace(category, '[^[:alnum:]]+', '', 'g')) = $1::text";
            params = {normalizeCategory(category)};
        }
        query += " ORDER BY sort_order, id";

        pqxx::result result = params.empty() ? db_->query(query) : db_->query(query, params);

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
