#pragma once
#include <string>
#include "../core/Controller.h"

// FinancesController — the #finances page (migration 490): where the club
// stands and where it is heading, per section and overall.  Billing stays
// on #payments (owner 2026-09-29: "should this all be on separate page(s)
// including the summary to keep the billing part cleaner?").
//
//   GET /api/finances/summary    PaymentsOverview: members, paid up, behind,
//                                blocked, owed, and dues × members per month
//                                and year — registered through laGet so all
//                                four membership programs sync first
//   GET /api/finances/expenses   Expenses::projection + the referee game
//                                list; pulls every league feed the referee
//                                policies read (CASA SportsEngine, APSL iCal)
//                                before computing
class FinancesController : public Controller {
public:
    FinancesController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    int mensProgramId_, womensProgramId_, boysProgramId_, girlsProgramId_;
    bool gate(const Request& request, Response* error);
    Response handleSummary(const Request& request);
    Response handleExpenses(const Request& request);
};
