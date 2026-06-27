#pragma once
#include "../core/Controller.h"

// ────────────────────────────────────────────────────────────────────────────
// LeadsWebhookController — Meta Lead-Ads webhook receiver.
//
// Phase 14: replaces the standalone meta-leads-webhook Node service.  Meta
// requires a publicly reachable HTTPS endpoint that
//   (a) responds to its subscription verification GET with the
//       `hub.challenge` token, and
//   (b) accepts the POST callback that arrives whenever a lead-form is
//       submitted; the callback only carries a leadgen_id so we have to
//       hit the Graph API for the actual field_data and then UPSERT into
//       the `leads` table.
//
// Routes (mounted at prefix "/webhook"):
//   GET  /webhook/meta-leads   verification handshake
//   POST /webhook/meta-leads   leadgen notification → upsert into `leads`
//
// Both routes are unauthenticated (Meta calls them from its own IPs).  The
// POST handler ACKs 200 immediately and processes the payload in a
// detached background thread, mirroring the Node `res.sendStatus(200)`-
// then-await pattern so Meta's tight callback timeout is honored even
// when the Graph fetch is slow.
// ────────────────────────────────────────────────────────────────────────────
class LeadsWebhookController : public Controller {
public:
    LeadsWebhookController() = default;
    ~LeadsWebhookController() override = default;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleVerify  (const Request& request);
    Response handleCallback(const Request& request);
};
