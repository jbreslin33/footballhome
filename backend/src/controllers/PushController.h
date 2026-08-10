#pragma once

#include "../core/Controller.h"

// PushController — Web Push opt-in surface.
//
// Routes:
//   GET    /api/push/vapid-public-key
//     Public, no session required — the VAPID public key is not
//     secret (it's handed to every subscribing browser anyway).
//     Response: { key: "<base64url>" }.
//
//   POST   /api/my/push-subscriptions
//     Body: { endpoint, keys: { p256dh, auth }, userAgent? } — the
//     exact shape of PushSubscription.toJSON() plus an optional UA
//     string. Upserts on endpoint (a re-subscribe from the same
//     browser install just refreshes it). Session required (cookie
//     or bearer, same gate as MyController).
//
//   DELETE /api/my/push-subscriptions
//     Body: { endpoint }. Removes that subscription for the caller.
//     No-op (200) if it's already gone.
//
// Sending is WebPushService's job, not this controller's — this file
// only owns the subscribe/unsubscribe lifecycle.
class PushController : public Controller {
public:
    PushController();
    ~PushController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGetVapidPublicKey(const Request& request);
    Response handleSubscribe(const Request& request);
    Response handleUnsubscribe(const Request& request);
};
