#pragma once
#include "../core/Controller.h"

// OrganizationController — the public club / league pages (migration 632).
//   GET /api/orgs/:slug  -> OrganizationRegistry::fromSlug(slug)->publicPage()
// No login: footballhome.org/<slug> is read by people who have no account.
class OrganizationController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGetPage(const Request& request);
};
