#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"
#include "../models/LaPool.h"

// ────────────────────────────────────────────────────────────────────────────
// ClubLaPoolController — REST surface for the club LA-pool list.
//
// Routes (registered under prefix "/api/clubs"):
//   GET /api/clubs/:clubId/la-pool[?gender=mens|womens]
//
// Bearer-presence auth (alg:none JWT decode happens in the frontend;
// backend just gates on header presence — matches Phases 1-3b).
//
// Mounted BEFORE ClubController so the /:clubId/la-pool path resolves
// to this handler rather than the more generic club detail handler.
// (ClubController currently only owns "" and "/:clubId" so there is no
// actual collision today, but ordering it first keeps it future-proof.)
// ────────────────────────────────────────────────────────────────────────────
class ClubLaPoolController : public Controller {
public:
    ClubLaPoolController();
    ~ClubLaPoolController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<LaPool> model_;

    Response handleGet(const Request& request);

    // Path parser: /api/clubs/123/la-pool → 123.
    static bool extractClubId(const std::string& path, int& clubId);

    // Bearer presence check (no signature verification).
};
