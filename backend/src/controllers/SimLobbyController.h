#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"

namespace fh::orchestration {
class SimPool;   // §21.7 item 1 step 5D — forward decl; full defn in SimPool.h
}

// SimLobbyController — thin discovery + JWT-bridge surface for the
// fh-sim.v1 browser client. Three endpoints (DESIGN.md §16.1):
//
//   GET  /api/sim/matches            — list open matches (ended_at NULL)
//   POST /api/sim/matches            — no-op for M0: returns the single
//                                       running match (sim daemon serves
//                                       one SIM_MATCH_ID today).
//   POST /api/sim/matches/:id/join   — auth via existing session (Bearer
//                                       JWT or fh_sess cookie), resolves
//                                       the caller's person_id, mints a
//                                       sim-side HS256 JWT with claims
//                                       {person_id, iat, exp} matching
//                                       sim/src/auth/JwtVerifier, returns
//                                       {token, ws_url}.
//
// The lobby does NOT talk to the sim daemon — it just issues a token
// and lets the browser open the WS itself. The daemon verifies the JWT
// during the WebSocket handshake using the same JWT_SECRET both
// processes read from ./env.
class SimLobbyController : public Controller {
public:
    SimLobbyController();
    void registerRoutes(Router& router, const std::string& prefix) override;

    // §21.7 item 1 step 5D — attach a warm-daemon pool. When set to a
    // non-null pool, handleCreateMatch tries pool->take() before
    // falling back to SimOrchestrator::launchMatch. When null (the
    // default) the controller behaves byte-identically to before this
    // slice — pure additive. Called by HttpServer in 5E after
    // constructing + starting the pool.
    void setSimPool(fh::orchestration::SimPool* pool);

private:
    Database* db_;
    // §21.7 item 1 step 5D — see setSimPool() docblock. Non-owning.
    fh::orchestration::SimPool* pool_ = nullptr;

    Response handleListMatches(const Request& request);
    Response handleCreateMatch(const Request& request);
    Response handleJoinMatch(const Request& request);
    Response handleStopMatch(const Request& request);
};
