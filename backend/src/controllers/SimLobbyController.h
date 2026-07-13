#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"

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

private:
    Database* db_;

    Response handleListMatches(const Request& request);
    Response handleCreateMatch(const Request& request);
    Response handleJoinMatch(const Request& request);
    Response handleStopMatch(const Request& request);
};
