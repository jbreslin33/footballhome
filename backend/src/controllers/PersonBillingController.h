#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class PersonBilling;

// ────────────────────────────────────────────────────────────────────────────
// PersonBillingController — REST surface for admin-edited per-LA-user
// billing rows.  Pairs with the read side that's already used by the
// youth (Phase 7) and mens (Phase 8) roster screens.
//
// Routes (registered under prefix "/api/person-billing"):
//   POST /api/person-billing               body: {leagueAppsUserId,
//                                                 nextBillDate (YYYY-MM-DD),
//                                                 nextBillAmount}
//   POST /api/person-billing/mark-billed   body: {leagueAppsUserId}
//
// Bearer-presence auth (same as Phases 1-8).  `updated_by_user_id` is
// written NULL because we don't decode the JWT payload in C++.
// ────────────────────────────────────────────────────────────────────────────
class PersonBillingController : public Controller {
public:
    PersonBillingController();
    ~PersonBillingController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<PersonBilling> model_;

    Response handleUpsert    (const Request& request);
    Response handleMarkBilled(const Request& request);

};
