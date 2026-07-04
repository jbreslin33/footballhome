#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class ChargeFlags;

// ────────────────────────────────────────────────────────────────────────────
// ChargeFlagsController — CRUD over person_charge_flags.
//
// Routes (registered under prefix "/api/charge-flags"):
//   POST /api/charge-flags                 body: {laUserId, laProgramId, amountCents, reason?}
//   GET  /api/charge-flags?program=&status=
//   GET  /api/charge-flags/:id
//   PUT  /api/charge-flags/:id             body: {status: "ran"|"canceled", note?}
//
// PUT is used instead of PATCH because the Router class does not expose a
// PATCH method — the semantic difference is irrelevant for a
// single-field state transition.
//
// All routes require Bearer auth.  created_by / resolved_by are taken
// from the JWT userId claim (same shape produced by AuthController &
// OAuthController).
// ────────────────────────────────────────────────────────────────────────────
class ChargeFlagsController : public Controller {
public:
    ChargeFlagsController();
    ~ChargeFlagsController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<ChargeFlags> flags_;

    // Pulls the userId claim out of a Bearer JWT.  Returns 0 if missing /
    // unparseable.  The bearer signature is validated separately via
    // requireBearer(); this helper only decodes the payload for the
    // userId claim (which is trusted because the signature already was).
    static int bearerUserId(const Request& req);

    Response handleCreate  (const Request& req);
    Response handleList    (const Request& req);
    Response handleGetById (const Request& req);
    Response handlePatch   (const Request& req);
};
