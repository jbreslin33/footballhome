#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class PersonLinker;

// ────────────────────────────────────────────────────────────────────────────
// AdminLaBackfillController — POST /api/admin/leagueapps-link/backfill
//
// Operator-driven sweep that walks one or more LA programs, calls
// PersonLinker::linkLa on every active registration, and reports a
// JSON summary (counts + per-program breakdown + bounded samples of
// conflicts / skipped records).
//
// Query params (Node parity):
//   ?dry=1            — write nothing, just report what would happen
//   ?programs=a,b,c   — comma-separated LA program ids
//                       (default: boys + girls + mens)
//
// Bearer-presence auth (consistent with Phases 1-9).  Hidden behind
// nginx's /api/ catch-all → :3001.
// ────────────────────────────────────────────────────────────────────────────
class AdminLaBackfillController : public Controller {
public:
    AdminLaBackfillController();
    ~AdminLaBackfillController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<PersonLinker> linker_;

    // Program-id env defaults (mirror Node's LA_BOYS_CLUB / LA_GIRLS_CLUB /
    // LA_MENS in meta-leads-webhook/index.js).
    int boysProgramId_;
    int girlsProgramId_;
    int mensProgramId_;

    Response handleBackfill(const Request& request);

};
