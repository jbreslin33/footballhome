#include "MenuController.h"

#include "../third_party/json.hpp"

#include <iostream>

MenuController::MenuController() {
    db_ = Database::getInstance();
}

void MenuController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& request) {
        return this->handleMenu(request);
    });
}

// Any signed-in user: players get This Week / Football / Club pages too.
Response MenuController::handleMenu(const Request& request) {
    if (!requireBearer(request)) {
        return Response(HttpStatus::UNAUTHORIZED, createJSONResponse(false, "Unauthorized"));
    }
    try {
        nlohmann::json groups = nlohmann::json::array();
        for (const auto& r : db_->query(
                "SELECT code, label, icon FROM menu_groups ORDER BY sort_order, code")) {
            groups.push_back({{"code", r["code"].c_str()}, {"label", r["label"].c_str()},
                              {"icon", r["icon"].c_str()}});
        }
        nlohmann::json pages = nlohmann::json::array();
        for (const auto& r : db_->query(
                "SELECT p.code, p.group_code, p.label, p.icon, p.audience, "
                "       array_to_json(p.screens)::text AS screens, "
                "       COALESCE(p.href, '') AS href, p.new_tab, p.download "
                "  FROM menu_pages p JOIN menu_groups g ON g.code = p.group_code "
                " WHERE p.is_active "
                " ORDER BY g.sort_order, p.sort_order, p.code")) {
            nlohmann::json screens = nlohmann::json::parse(r["screens"].c_str(), nullptr, false);
            pages.push_back({
                {"code", r["code"].c_str()}, {"group", r["group_code"].c_str()},
                {"label", r["label"].c_str()}, {"icon", r["icon"].c_str()},
                {"audience", r["audience"].c_str()},
                {"screens", screens.is_array() ? screens : nlohmann::json::array()},
                {"href", r["href"].c_str()},
                {"newTab", r["new_tab"].as<bool>()}, {"download", r["download"].as<bool>()},
            });
        }
        nlohmann::json out = {{"groups", groups}, {"pages", pages}};
        return Response(HttpStatus::OK, createJSONResponse(true, "Menu", out.dump()));
    } catch (const std::exception& e) {
        std::cerr << "Error in MenuController::handleMenu: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Database error"));
    }
}
