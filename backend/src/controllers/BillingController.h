#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class BillingExpectations;
class BillingProjector;

// ────────────────────────────────────────────────────────────────────────────
// BillingController — admin surface over billing_expectations.
//
// Routes (registered under prefix "/api/billing"):
//
//   POST /api/billing/projector/run
//       body: {}  (or {horizonDays:60, backfillDays:100} to override)
//       Runs BillingProjector::run() on-demand.  Returns a Summary
//       describing how many rows were inserted per kind, the horizon
//       window used, and whether the run was skipped due to advisory-
//       lock contention.  Requires Bearer.
//
//   GET  /api/billing/expectations?user_id=<laUserId>[&program_id=<pid>]
//       Returns all billing_expectations rows for one LA user, newest
//       charge_date first.  Used by the roster card drill-down and by
//       Phase 1b's 3-month calendar table.  Requires Bearer.
//
//   GET  /api/billing/queue[?program_id=<pid>&date=<YYYY-MM-DD>]
//       Returns every open expectation (invoice_added_at IS NULL AND
//       waived_at IS NULL) whose charge_date is on-or-before `date`
//       (default: today America/NY).  Ordered oldest-charge-date first —
//       this is what the "run this on LA today" admin queue consumes.
//       Requires Bearer.
//
//   POST /api/billing/expectations/:id/mark-invoice-added
//       body: {note?: string}
//       Idempotent: sets invoice_added_at=now() if not already set.
//       Returns the updated row.  Requires Bearer.
//
//   POST /api/billing/expectations/:id/mark-paid
//       body: {note?: string}
//       Idempotent: sets paid_at=now() (and invoice_added_at if null).
//       Returns the updated row.  Requires Bearer.
//
//   POST /api/billing/expectations/:id/waive
//       body: {note?: string}
//       Idempotent: sets waived_at=now().  Returns the updated row.
//       Requires Bearer.
//
//   POST /api/billing/la-registration-dates/backfill
//       body: {programId?: bigint}
//       Fetches LA registrations for one program (or all active programs
//       when programId is omitted) and populates
//       `person_la_memberships.la_registered_at`.  This is what unlocks
//       the projector's pro-rate logic for newly-registered players.
//       Requires Bearer.  Runs synchronously — returns a per-program
//       summary of {examined, updated, missingDate} counts.
//
// Notes:
//   • The Router uses regex path-params; the ":id" suffixes above become
//     the trailing bigint id.  We parse it in the handler.
//   • All error responses share the same {"error":"…"} shape used by
//     ChargeFlagsController et al.
// ────────────────────────────────────────────────────────────────────────────
class BillingController : public Controller {
public:
    BillingController();
    ~BillingController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<BillingExpectations> expectations_;
    std::unique_ptr<BillingProjector>    projector_;

    Response handleProjectorRun (const Request& req);
    Response handleGetByUser    (const Request& req);
    Response handleGetQueue     (const Request& req);
    Response handleMarkInvoice  (const Request& req);
    Response handleMarkPaid     (const Request& req);
    Response handleWaive        (const Request& req);
    Response handleLaRegBackfill(const Request& req);
};
