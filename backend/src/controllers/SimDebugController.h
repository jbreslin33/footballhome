#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"

#include <chrono>
#include <deque>
#include <mutex>
#include <unordered_map>

// SimDebugController — admin-only debug surface over `sim_match_inputs`
// and `sim_match_events`. Reads the packed bytea payloads via the SQL
// decode helpers landed in migration 201 (see sim/DESIGN.md §16.6
// sub-slice 7) and hands the caller a legible JSON view.
//
// Endpoints (mounted under /api/sim/debug):
//
//   GET /api/sim/debug/matches/:id/inputs?from_tick=N&to_tick=M&limit=L
//     Returns { match_id, from_tick, to_tick, count, rows: [
//         { tick_num, slot_id, payload_hex, decoded: {...} } ... ] }
//     `decoded` is the jsonb from sim_decode_input(payload).
//
//   GET /api/sim/debug/matches/:id/events?from_tick=N&to_tick=M&limit=L
//     Returns { match_id, from_tick, to_tick, count, rows: [
//         { id, tick_num, event_type, event_type_name, payload_hex,
//           decoded: {...} } ... ] }
//     `decoded` is the jsonb from sim_decode_event(event_type, payload).
//
//   GET /api/sim/debug/matches/:id/state?tick=T
//     Currently returns 501 Not Implemented. Real implementation needs
//     to spawn `fh-sim-replay --match-id N --up-to-tick T
//     --emit-json-snapshot` in a sandboxed subprocess, but the binary
//     lives in `footballhome_sim` while the backend runs in
//     `footballhome_backend` — cross-container invocation is out of
//     scope for this sub-slice. Tracked as sub-slice 8.1.
//
// Gating (both must be true or nothing is registered):
//   1. `FH_ENABLE_SIM_DEBUG=1` at process start. If unset, `registerRoutes`
//      logs "sim debug endpoints DISABLED" and returns without touching
//      the router. Prod stays clean.
//   2. Per-request admin check via the same query MyController uses:
//        SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id
//         WHERE u.person_id = $1 LIMIT 1
//
// Rate limit (per-admin, sliding-window, in-memory): 10 requests per
// 60 s. State lives on the controller instance behind a mutex — cheap
// to compute, resets on process restart. Prevents accidental heavy
// replay load; adequate for a single-instance debug tool.
//
// Row limit: LIMIT clamped to [1, 1000] with default 500. Prevents an
// admin from OOM-ing the backend by paging a million-input match.
class SimDebugController : public Controller {
public:
    SimDebugController();
    void registerRoutes(Router& router, const std::string& prefix) override;

    // Public for testability: same value read by main.cpp when logging
    // startup state. Reads FH_ENABLE_SIM_DEBUG once at construction.
    bool enabled() const { return enabled_; }

private:
    Database* db_;
    bool enabled_;

    // ----- rate limiter -----
    // person_id → sliding window of recent request times. Kept simple:
    // pop from the front while entries are outside the window, count
    // what remains, reject if the count is at the cap.
    std::mutex rate_mu_;
    std::unordered_map<long long,
                       std::deque<std::chrono::steady_clock::time_point>>
        rate_buckets_;

    static constexpr int kRateCap = 10;               // requests
    static constexpr std::chrono::seconds kRateWindow{60};

    // Returns true if the caller is under the cap (and records this hit).
    // Returns false if the caller is at/over the cap.
    bool allowRequest(long long personId);

    // Resolve caller person_id + admin flag. Returns 0 for unauthenticated;
    // returns -1 for authenticated-but-not-admin. Positive value is the
    // person_id of an authenticated admin.
    long long resolveAdminPersonId(const Request& request);

    Response handleInputs(const Request& request);
    Response handleEvents(const Request& request);
    Response handleState(const Request& request);
};
