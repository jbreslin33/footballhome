#pragma once

#include <string>

// WebPushService — sends browser Web Push notifications (RFC 8291
// encrypted payload + RFC 8292 VAPID auth) to every subscription on
// file for a person.
//
// Self-hosted, no third-party relay: every push service (FCM for
// Chrome/Android, Apple's web push service for Safari/iOS 16.4+,
// Mozilla's for Firefox) speaks the same standard Web Push HTTP
// protocol, so this one implementation covers all platforms — there's
// no Firebase SDK or APNs cert involved.
//
// VAPID keypair: loaded once from VAPID_PRIVATE_KEY (a base64url-
// encoded raw 32-byte P-256 private scalar — not PEM, so it fits on
// one env-file line). The public key is re-derived from it at runtime,
// never stored separately.
//
// Singleton: the VAPID key load is the only state; every send is
// otherwise independent and safe to call from any thread.
class WebPushService {
public:
    static WebPushService& getInstance();

    WebPushService(const WebPushService&) = delete;
    WebPushService& operator=(const WebPushService&) = delete;

    // Base64url-encoded uncompressed P-256 public key (65 raw bytes:
    // 0x04 || X || Y). Frontend passes this directly to
    // PushManager.subscribe({applicationServerKey: <this>}).
    std::string vapidPublicKeyB64Url();

    // Sends {title, body, url?} as the push payload to every
    // subscription on file for `personId`. Meant to be called from a
    // detached thread — never throws, logs failures to stderr.
    // Subscriptions a push service reports gone (HTTP 404/410) are
    // deleted from push_subscriptions. Returns count of successful
    // deliveries.
    int sendToPerson(long long personId,
                      const std::string& title,
                      const std::string& body,
                      const std::string& url = "");

private:
    WebPushService() = default;

    struct Subscription {
        long long   id;
        std::string endpoint;
        std::string p256dhKeyB64Url;
        std::string authKeyB64Url;
    };

    // RFC 8291 §3.4: encrypts `plaintext` for one subscriber, returns
    // the wire body (16B salt || 4B record-size || 1B keyid-len ||
    // keyid || ciphertext+tag) ready to POST verbatim.
    std::string encryptPayload(const std::string& plaintext,
                                const std::string& p256dhKeyB64Url,
                                const std::string& authKeyB64Url);

    // RFC 8292 §3: builds the "vapid t=<JWT>, k=<pubkey>" Authorization
    // header value for a push service whose endpoint origin is
    // `audienceOrigin` (e.g. "https://fcm.googleapis.com").
    std::string vapidAuthHeader(const std::string& audienceOrigin);

    bool sendToSubscription(const Subscription& sub, const std::string& payloadJson);
};
