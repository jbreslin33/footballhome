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

    Response handleGetForProgram(const std::string& programKey, long long programId);
    Response handleGetMembersForProgram(const std::string& programKey, long long programId);
};
