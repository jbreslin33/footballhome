#include "OrganizationController.h"
#include "../models/Organization.h"
#include <iostream>
#include <regex>

void OrganizationController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix + "/:slug", [this](const Request& r) { return handleGetPage(r); });
}

Response OrganizationController::handleGetPage(const Request& request) {
    // Same shape organizations.slug's CHECK allows (migration 632).
    static const std::regex re(R"(/api/orgs/([a-z0-9]+(?:-[a-z0-9]+)*)/?$)");
    std::smatch m;
    const std::string path = request.getPath();
    if (!std::regex_search(path, m, re)) {
        return Response(HttpStatus::NOT_FOUND, createJSONResponse(false, "Not found"));
    }
    try {
        std::unique_ptr<Organization> org = OrganizationRegistry::fromSlug(m[1].str());
        if (!org) return Response(HttpStatus::NOT_FOUND, createJSONResponse(false, "Not found"));
        return Response(HttpStatus::OK,
                        createJSONResponse(true, "Organization page", org->publicPage().dump()));
    } catch (const std::exception& e) {
        std::cerr << "❌ OrganizationController::handleGetPage: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Database error"));
    }
}
