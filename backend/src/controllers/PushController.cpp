#include "PushController.h"

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../services/SessionService.h"
#include "../services/WebPushService.h"
#include "../third_party/json.hpp"

#include <exception>
#include <iostream>
#include <optional>
#include <string>

using nlohmann::json;

namespace {

Response jsonError(HttpStatus s, const std::string& msg) {
    json body = {{"error", msg}};
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}

Response jsonOk(const json& body) {
    Response r(HttpStatus::OK, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}

// Same personId claim shape AuthController/OAuthController issue —
// mirrors MyController's personIdFromJwtPayload exactly.
long long personIdFromJwtPayload(const std::string& payloadJson) {
    const std::string needle = "\"userId\":\"";
    auto pos = payloadJson.find(needle);
    if (pos == std::string::npos) return 0;
    pos += needle.size();
    auto end = payloadJson.find('"', pos);
    if (end == std::string::npos) return 0;
    const std::string userIdStr = payloadJson.substr(pos, end - pos);
    if (userIdStr.empty()) return 0;

    try {
        auto* db = Database::getInstance();
        auto r = db->query(
            "SELECT person_id FROM users WHERE id = $1::int LIMIT 1",
            {userIdStr});
        if (r.empty() || r[0]["person_id"].is_null()) return 0;
        return r[0]["person_id"].as<long long>();
    } catch (...) {
        return 0;
    }
}

struct SessionGate {
    std::optional<long long> personId;
    std::optional<Response>  error;
};

// Cookie-or-bearer gate, bearer preferred when both present — same
// rule and same reasoning as MyController::requireSession (the
// 2026-07-06 cross-user session bug on shared devices).
SessionGate requireSession(const Request& request) {
    const std::string authHeader = request.getHeader("Authorization");
    if (authHeader.size() > 7 && authHeader.substr(0, 7) == "Bearer ") {
        const std::string token = authHeader.substr(7);
        std::string payloadJson;
        if (fh::crypto::verifyJwtHS256(token, &payloadJson)) {
            const long long personId = personIdFromJwtPayload(payloadJson);
            if (personId > 0) return {personId, std::nullopt};
        }
    }

    const std::string cookie  = request.getHeader("Cookie");
    const std::string sessVal = SessionService::parseCookieValue(
        cookie, SessionService::kCookieName);
    auto resolved = SessionService::getInstance().requireSession(sessVal);
    if (resolved) return {resolved->personId, std::nullopt};

    return {std::nullopt,
            jsonError(HttpStatus::UNAUTHORIZED,
                      sessVal.empty() ? "Not signed in" : "Session expired")};
}

}  // namespace

PushController::PushController() = default;
PushController::~PushController() = default;

void PushController::registerRoutes(Router& router, const std::string& prefix) {
    // prefix is "/api/my" (see main.cpp: router_.useController("/api/my", push_controller_)).
    // The VAPID key is public — registered at a literal path outside that prefix.
    router.get ("/api/push/vapid-public-key", [this](const Request& r) { return handleGetVapidPublicKey(r); });
    router.post(prefix + "/push-subscriptions", [this](const Request& r) { return handleSubscribe(r); });
    router.del (prefix + "/push-subscriptions", [this](const Request& r) { return handleUnsubscribe(r); });
}

// GET /api/push/vapid-public-key
Response PushController::handleGetVapidPublicKey(const Request& /*request*/) {
    try {
        json out = {{"key", WebPushService::getInstance().vapidPublicKeyB64Url()}};
        return jsonOk(out);
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/push/vapid-public-key] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "push not configured");
    }
}

// POST /api/my/push-subscriptions
// Body: { endpoint, keys: { p256dh, auth }, userAgent? }
Response PushController::handleSubscribe(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = *gate.personId;

    json body;
    try { body = json::parse(request.getBody()); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "invalid JSON"); }

    if (!body.contains("endpoint") || !body["endpoint"].is_string() ||
        !body.contains("keys") || !body["keys"].is_object()) {
        return jsonError(HttpStatus::BAD_REQUEST, "endpoint and keys required");
    }
    const std::string endpoint = body["endpoint"].get<std::string>();
    const auto& keys = body["keys"];
    if (!keys.contains("p256dh") || !keys["p256dh"].is_string() ||
        !keys.contains("auth") || !keys["auth"].is_string()) {
        return jsonError(HttpStatus::BAD_REQUEST, "keys.p256dh and keys.auth required");
    }
    const std::string p256dh = keys["p256dh"].get<std::string>();
    const std::string auth   = keys["auth"].get<std::string>();
    const std::string userAgent = (body.contains("userAgent") && body["userAgent"].is_string())
        ? body["userAgent"].get<std::string>() : request.getHeader("User-Agent");

    if (endpoint.empty() || p256dh.empty() || auth.empty()) {
        return jsonError(HttpStatus::BAD_REQUEST, "endpoint/keys cannot be blank");
    }

    try {
        auto* db = Database::getInstance();
        db->query(
            "INSERT INTO push_subscriptions (person_id, endpoint, p256dh_key, auth_key, user_agent, last_used_at) "
            "VALUES ($1::int, $2, $3, $4, $5, NOW()) "
            "ON CONFLICT (endpoint) DO UPDATE SET "
            "  person_id = EXCLUDED.person_id, "
            "  p256dh_key = EXCLUDED.p256dh_key, "
            "  auth_key = EXCLUDED.auth_key, "
            "  user_agent = EXCLUDED.user_agent, "
            "  last_used_at = NOW()",
            {std::to_string(personId), endpoint, p256dh, auth, userAgent});
        return jsonOk({{"ok", true}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/my/push-subscriptions] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "subscribe failed");
    }
}

// DELETE /api/my/push-subscriptions
// Body: { endpoint }
Response PushController::handleUnsubscribe(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    const long long personId = *gate.personId;

    json body;
    try { body = json::parse(request.getBody()); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "invalid JSON"); }

    if (!body.contains("endpoint") || !body["endpoint"].is_string()) {
        return jsonError(HttpStatus::BAD_REQUEST, "endpoint required");
    }
    const std::string endpoint = body["endpoint"].get<std::string>();

    try {
        // Scoped to the caller's own person_id so one signed-in player
        // can't delete another's subscription by guessing an endpoint.
        Database::getInstance()->query(
            "DELETE FROM push_subscriptions WHERE endpoint = $1 AND person_id = $2::int",
            {endpoint, std::to_string(personId)});
        return jsonOk({{"ok", true}});
    } catch (const std::exception& e) {
        std::cerr << "[DELETE /api/my/push-subscriptions] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "unsubscribe failed");
    }
}
