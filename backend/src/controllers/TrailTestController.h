#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"

// TrailTestController — persistence + retrieval for Trail Test
// (Learning Game 1 under Tactical Games).  See DB migration
// 210-trail-test.sql for the storage model and the design rationale
// (A+B must be back-to-back, complete-only saves, attempts logged
// separately for our telemetry).
//
// Endpoints (all mounted under /api/tactical/trail-test):
//
//   POST /api/tactical/trail-test/results
//     Body: { variant, layout_seed, part_a_time_ms, part_a_errors,
//             part_b_time_ms, part_b_errors, path_a, path_b }
//     Auth: same dual-mode as SimLobbyController — Bearer login JWT OR
//           fh_sess cookie. person_id resolved server-side; the client
//           does NOT get to name whose result this is.
//     Persists one row in trail_test_results plus a matching
//     'completed' row in trail_test_attempts.
//
//   POST /api/tactical/trail-test/attempts
//     Body: { variant, layout_seed, outcome, partial_ms?, partial_errors?,
//             partial_part? }
//     Auth: same.
//     Fire-and-forget telemetry the client sends when a session ends
//     WITHOUT a complete A+B pair (page unload, lift-during-part,
//     JS crash). Never surfaces in the player-facing history.
//
//   GET  /api/tactical/trail-test/results?limit=20
//     Auth: same.
//     Returns the caller's own most recent complete sessions, newest
//     first, with derived flexibility_cost_ms already computed.
//
// The controller does NOT talk to footballhome_sim. Trail Test is
// a pure client-side canvas game — this backend surface is just the
// storage seam.
class TrailTestController : public Controller {
public:
    TrailTestController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Database* db_;

    Response handlePostResult(const Request& request);
    Response handlePostAttempt(const Request& request);
    Response handleListMine(const Request& request);
};
