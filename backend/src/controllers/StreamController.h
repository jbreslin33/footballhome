// =============================================================================
// StreamController  (Phase 13 — /api/stream)
// =============================================================================
//
// Long-lived Server-Sent Events channel for /dashboard#lineups.  Each browser
// tab opens one EventSource to /api/stream?token=<alg:none JWT>; the server
// pushes:
//
//   : connected\n\n                 (sent immediately on connect)
//   : heartbeat\n\n                 (every 25 s, from the hub thread)
//   data: <fh_lineups payload>\n\n  (from the LISTEN/NOTIFY pump)
//
// Auth: same alg:none JWT scheme the rest of the API uses, BUT delivered via
// query string because the EventSource API can't set Authorization headers.
// We only require a present, decodable payload with a `userId` field
// (matching the Node webhook's behavior — full signature verification lives
// at the magic-link layer).
//
// =============================================================================
#pragma once

#include <string>
#include "../core/Controller.h"

class StreamController : public Controller {
public:
    StreamController() = default;
    ~StreamController() override = default;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleStream(const Request& request);
};
