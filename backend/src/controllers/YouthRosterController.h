#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"
#include "../models/YouthRoster.h"

// ────────────────────────────────────────────────────────────────────────────
// YouthRosterController — REST surface for the youth-roster screen.
//
// Routes (registered under prefix "/api/youth-roster"):
//   GET /api/youth-roster[?seasonEndYear=YYYY][&includeAll=1]
//
// Bearer-presence auth (same as Phases 1-6).
//
// Failure mapping:
//   no buckets configured → 409 + { error: "..." }
//   LA fetch / DB error   → 502 + { error: "Failed to fetch youth roster: ..." }
// ────────────────────────────────────────────────────────────────────────────
class YouthRosterController : public Controller {
public:
    YouthRosterController();
    ~YouthRosterController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<YouthRoster> model_;

    Response handleGet(const Request& request);

    // Bearer presence check (no signature verification).
};
