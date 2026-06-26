#pragma once

#include "../core/Controller.h"

// MagicLinkAuthController — the FH-native auth surface ported from
// meta-leads-webhook/index.js (Phase 4).  Four endpoints, all under
// /api/auth and all 1:1 with the Node implementation:
//
//   POST /api/auth/magic-link/mint    — admin, requires Bearer JWT
//   GET  /api/auth/magic-link/verify  — public; sets fh_sess cookie
//   GET  /api/auth/me                 — cookie-authed whoami
//   POST /api/auth/logout             — cookie-authed session revoke
//
// Mounted BEFORE the legacy AuthController in main.cpp so that the
// /me and /logout paths resolve here (cookie semantics) instead of
// the older bearer/email-password version.
class MagicLinkAuthController : public Controller {
public:
    MagicLinkAuthController();
    ~MagicLinkAuthController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleMint(const Request& request);
    Response handleVerify(const Request& request);
    Response handleMe(const Request& request);
    Response handleLogout(const Request& request);

    // Bearer-presence gate that matches the Node `requireAuth` middleware:
    // payload must decode and contain a `userId` field.  Populates
    // outUserId with the extracted value when present.  No signature
    // verification — same pre-existing gap as every other admin route.
    bool extractBearerUserId(const Request& request, std::string& outUserId);

    // Resolves whether Set-Cookie should include the Secure attribute.
    // Pulled from PUBLIC_BASE_URL — true for https://, false for plain
    // http (local dev would otherwise silently drop the cookie).
    bool useSecureCookies() const;
};
