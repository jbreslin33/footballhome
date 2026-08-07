#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class PersonPayments;

// ────────────────────────────────────────────────────────────────────────────
// PaymentsController — read-only audit view over person_payments for the
// dedicated payments screen (Mens / Boys / Girls tabs).
//
// Routes (registered under prefix "/api/payments"):
//   GET /api/payments/mens
//   GET /api/payments/womens
//   GET /api/payments/boys
//   GET /api/payments/girls
//
// Each endpoint runs a LeagueApps transactions-2 sync first (same policy
// as the roster screens — every page load reflects reality) and then
// returns the full sorted-DESC payment history for that program.
//
// Bearer-presence auth.
// ────────────────────────────────────────────────────────────────────────────
class PaymentsController : public Controller {
public:
    PaymentsController();
    ~PaymentsController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<PersonPayments> payments_;

    int mensProgramId_;
    int womensProgramId_;
    int boysProgramId_;
    int girlsProgramId_;

    // "Inactive" sub-program per category (migration 266) — members moved
    // here in LA after 2 months unpaid.  Still shown on the payments
    // screen (separate top section) so ops can monitor for reactivation,
    // but excluded from rosters/pool (LaPool.cpp §3a).  0 = not configured
    // yet for that category (boys/girls pending LA-side id confirmation).
    int mensInactiveProgramId_;
    int womensInactiveProgramId_;
    int boysInactiveProgramId_;
    int girlsInactiveProgramId_;

    Response handleGetForProgram(const std::string& programKey,
                                 long long programId,
                                 const LaSyncMap& sync);
    Response handleGetMembersForProgram(const std::string& programKey,
                                        long long programId,
                                        long long inactiveProgramId,
                                        const LaSyncMap& sync);
    // Operator override: POST /api/payments/members/:regId/next-due.
    Response handleSetNextDue(const Request& request);
};
