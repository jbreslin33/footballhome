#pragma once
#include <memory>
#include <string>

#include "../core/Controller.h"
#include "../core/Request.h"
#include "../core/Response.h"

// ────────────────────────────────────────────────────────────────────────────
// AdsController — `/api/ads/*` surface (formerly Node).
//
//   GET /api/ads/preview          full list of ads + creative for the
//                                 review queue (sorted PAUSED → ACTIVE →
//                                 other, newest-first within each group).
//   GET /api/ads/targeting        targeting + spend + region breakdown
//                                 (parallel per-ad region fetch for the
//                                 ACTIVE subset; mirrors Node Promise.all).
//   GET /api/ads/spend            spend totals grouped by lead_gen_form_id.
//   GET /api/ads/:adId/preview    302 redirect to Meta-hosted preview
//                                 iframe.  Returns an HTML error page (not
//                                 JSON) on failure so it renders cleanly
//                                 in a popped-out tab.
//
// All four require a bearer token (presence-only check, like every other
// controller in this project).
// ────────────────────────────────────────────────────────────────────────────
class AdsController : public Controller {
public:
    AdsController() = default;
    ~AdsController() override = default;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handlePreviewList(const Request& request);
    Response handleTargeting(const Request& request);
    Response handleSpend(const Request& request);
    Response handleAdPreviewIframe(const Request& request);

    // Pulled out so all four handlers share one auth gate.

    // /api/ads/:adId/preview returns HTML (rendered in a popped-out tab),
    // not JSON, on failure — keep the error template in one place.
    Response htmlError(int status,
                       const std::string& msg,
                       const std::string& adId,
                       const std::string& adFmt);
};
