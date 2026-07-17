#include "MyController.h"

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../services/SessionService.h"
#include "../third_party/json.hpp"

#include <exception>
#include <iostream>
#include <optional>
#include <string>
#include <vector>

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

// Decode a JWT payload, look for the string "userId" claim (which is
// what AuthController emits at login time), then map users.id →
// persons.id.  Returns 0 on any failure.  Only called after the
// signature has been verified by verifyJwtHS256.
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
    std::optional<SessionService::ResolvedSession> session;
    std::optional<Response>                        error;
};

// Accepts either the fh_sess cookie session OR a JWT bearer.  MyController
// endpoints are called from both the magic-link flow (cookie) and the
// regular password/OAuth flow (JWT), so we transparently support both.
//
// SECURITY: When BOTH a Bearer JWT and an fh_sess cookie are present we
// prefer the Bearer JWT.  The JWT is scoped to localStorage of the
// specific browser/tab that just logged in via OAuth, while the cookie
// can bleed across users on shared devices (e.g. someone clicked a
// different user's magic-link email on this phone earlier).  Preferring
// the JWT prevents the "logged in as A but seeing B's data" class of
// bug — the 2026-07-06 incident that motivated this comment.
SessionGate requireSession(const Request& request) {
    const std::string authHeader = request.getHeader("Authorization");
    if (authHeader.size() > 7 && authHeader.substr(0, 7) == "Bearer ") {
        const std::string token = authHeader.substr(7);
        std::string payloadJson;
        if (fh::crypto::verifyJwtHS256(token, &payloadJson)) {
            const long long personId = personIdFromJwtPayload(payloadJson);
            if (personId > 0) {
                SessionService::ResolvedSession synth;
                synth.sessionId = "";
                synth.personId  = personId;
                return {std::move(synth), std::nullopt};
            }
        }
    }

    const std::string cookie  = request.getHeader("Cookie");
    const std::string sessVal = SessionService::parseCookieValue(
        cookie, SessionService::kCookieName);
    auto resolved = SessionService::getInstance().requireSession(sessVal);
    if (resolved) {
        return {std::move(resolved), std::nullopt};
    }

    return {std::nullopt,
            jsonError(HttpStatus::UNAUTHORIZED,
                      sessVal.empty() ? "Not signed in" : "Session expired")};
}

// ─── View-as / impersonation (2026-07-11) ───────────────────────────
// If `?asPersonId=N` is set in the query string, this helper swaps the
// caller's own person_id for N so reads render exactly what that
// person would see.  Gated to admins only, and refused on writes —
// writes always execute as the actual caller.
std::optional<Response> applyImpersonation(const Request& request,
                                            long long authPersonId,
                                            bool allowImpersonation,
                                            long long* effectivePersonId) {
    *effectivePersonId = authPersonId;
    const std::string q = request.getQueryParam("asPersonId");
    if (q.empty()) return std::nullopt;
    long long target = 0;
    try { target = std::stoll(q); } catch (...) { target = 0; }
    if (target <= 0 || target == authPersonId) return std::nullopt;

    if (!allowImpersonation) {
        return jsonError(HttpStatus::FORBIDDEN,
                          "view-as is read-only — write endpoints must run as the actual caller");
    }

    auto* db = Database::getInstance();
    try {
        auto isAdmin = db->query(
            "SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id "
            " WHERE u.person_id = $1::int LIMIT 1",
            {std::to_string(authPersonId)});
        if (isAdmin.empty()) {
            return jsonError(HttpStatus::FORBIDDEN,
                              "only admins may use view-as");
        }
        auto exists = db->query(
            "SELECT 1 FROM persons WHERE id = $1::int LIMIT 1",
            {std::to_string(target)});
        if (exists.empty()) {
            return jsonError(HttpStatus::NOT_FOUND,
                              "view-as target person not found");
        }
    } catch (const std::exception& e) {
        std::cerr << "[applyImpersonation] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR,
                          "view-as check failed");
    }
    *effectivePersonId = target;
    return std::nullopt;
}

// ─── Men's chat helpers ──────────────────────────────────────────────
long long mensChatId() {
    static long long cached = 0;
    if (cached > 0) return cached;
    try {
        auto* db = Database::getInstance();
        auto r = db->query("SELECT id FROM chats WHERE slug = 'mens' LIMIT 1", {});
        if (!r.empty() && !r[0]["id"].is_null()) {
            cached = r[0]["id"].as<long long>();
        }
    } catch (...) {}
    return cached;
}

// Return true if the caller is allowed to read/post in the men's chat.
// Rule: any un-removed men's roster row, OR any admins row.
bool isMensChatMember(long long personId) {
    if (personId <= 0) return false;
    try {
        auto* db = Database::getInstance();
        auto r = db->query(
            "SELECT 1 FROM roster_assignments ra "
            "  JOIN external_person_aliases epa "
            "    ON epa.provider = 'leagueapps' "
            "   AND epa.external_user_id = ra.leagueapps_user_id::text "
            " WHERE ra.domain = 'mens' "
            "   AND ra.removed_at IS NULL "
            "   AND epa.person_id = $1::int "
            " UNION ALL "
            "SELECT 1 FROM admins a "
            "  JOIN users u ON u.id = a.user_id "
            " WHERE u.person_id = $1::int "
            " LIMIT 1",
            {std::to_string(personId)});
        return !r.empty();
    } catch (const std::exception& e) {
        std::cerr << "[isMensChatMember] " << e.what() << std::endl;
        return false;
    }
}

// users.id for caller.  chat_messages.user_id is NOT NULL, so a
// missing users row means "cannot post" (403).
std::string usersIdForPerson(long long personId) {
    try {
        auto* db = Database::getInstance();
        auto r = db->query(
            "SELECT id FROM users WHERE person_id = $1::int LIMIT 1",
            {std::to_string(personId)});
        if (!r.empty() && !r[0]["id"].is_null()) {
            return std::to_string(r[0]["id"].as<long long>());
        }
    } catch (...) {}
    return {};
}

std::string trimCopy(const std::string& s) {
    auto b = s.find_first_not_of(" \t\r\n");
    if (b == std::string::npos) return {};
    auto e = s.find_last_not_of(" \t\r\n");
    return s.substr(b, e - b + 1);
}

}  // namespace

MyController::MyController() = default;
MyController::~MyController() = default;

void MyController::registerRoutes(Router& router, const std::string& prefix) {
    // prefix is "/api/my".
    router.get (prefix + "/chat/messages",  [this](const Request& r) { return handleGetChatMessages(r); });
    router.post(prefix + "/chat/messages",  [this](const Request& r) { return handlePostChatMessage(r); });
}

// GET /api/my/chat/messages?since_id=<int>
Response MyController::handleGetChatMessages(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    long long personId = gate.session->personId;
    if (auto err = applyImpersonation(request, personId, /*allowImpersonation=*/true, &personId))
        return *err;

    if (!isMensChatMember(personId)) {
        return jsonError(HttpStatus::FORBIDDEN, "Not a member of the men's chat");
    }

    const long long chatId = mensChatId();
    if (chatId <= 0) {
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "men's chat not configured");
    }

    long long sinceId = 0;
    const std::string sinceStr = request.getQueryParam("since_id");
    if (!sinceStr.empty()) {
        try { sinceId = std::stoll(sinceStr); } catch (...) { sinceId = 0; }
    }

    try {
        auto* db = Database::getInstance();
        auto r = db->query(
            "SELECT cm.id, cm.user_id, u.person_id, "
            "       p.first_name, p.last_name, cm.message, "
            "       TO_CHAR(cm.created_at AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at "
            "  FROM chat_messages cm "
            "  JOIN users   u ON u.id = cm.user_id "
            "  JOIN persons p ON p.id = u.person_id "
            " WHERE cm.chat_id = $1::int "
            "   AND cm.id > $2::int "
            " ORDER BY cm.created_at DESC, cm.id DESC "
            " LIMIT 200",
            {std::to_string(chatId), std::to_string(sinceId)});

        std::vector<json> messages;
        messages.reserve(r.size());
        for (auto it = r.rbegin(); it != r.rend(); ++it) {
            const auto& row = *it;
            messages.push_back({
                {"id",                row["id"].as<long long>()},
                {"user_id",           row["user_id"].as<long long>()},
                {"person_id",         row["person_id"].as<long long>()},
                {"author_first_name", row["first_name"].is_null() ? std::string{} : row["first_name"].as<std::string>()},
                {"author_last_name",  row["last_name"].is_null()  ? std::string{} : row["last_name"].as<std::string>()},
                {"message",           row["message"].as<std::string>()},
                {"created_at",        row["created_at"].as<std::string>()},
            });
        }
        const std::string viewerIdStr = usersIdForPerson(personId);
        const long long   viewerId    = viewerIdStr.empty() ? 0 : std::stoll(viewerIdStr);

        return jsonOk({
            {"chat_id",        chatId},
            {"viewer_user_id", viewerId},
            {"messages",       messages},
        });
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/my/chat/messages] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /api/my/chat/messages
Response MyController::handlePostChatMessage(const Request& request) {
    auto gate = requireSession(request);
    if (gate.error) return *gate.error;
    long long personId = gate.session->personId;
    if (auto err = applyImpersonation(request, personId, /*allowImpersonation=*/false, &personId))
        return *err;

    if (!isMensChatMember(personId)) {
        return jsonError(HttpStatus::FORBIDDEN, "Not a member of the men's chat");
    }

    const long long chatId = mensChatId();
    if (chatId <= 0) {
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "men's chat not configured");
    }

    const std::string userIdStr = usersIdForPerson(personId);
    if (userIdStr.empty()) {
        return jsonError(HttpStatus::FORBIDDEN, "no users row for caller");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "invalid JSON"); }

    if (!body.contains("message") || !body["message"].is_string()) {
        return jsonError(HttpStatus::BAD_REQUEST, "message string required");
    }
    const std::string trimmed = trimCopy(body["message"].get<std::string>());
    if (trimmed.empty()) {
        return jsonError(HttpStatus::BAD_REQUEST, "message cannot be blank");
    }
    if (trimmed.size() > 2000) {
        return jsonError(HttpStatus::BAD_REQUEST, "message too long (max 2000 chars)");
    }

    try {
        auto* db = Database::getInstance();

        // Rate limit: caller has posted <3 rows to this chat in the
        // last 10 seconds.  Cheap query — chat_messages is indexed
        // by (chat_id) and (user_id).
        auto rl = db->query(
            "SELECT COUNT(*) AS n FROM chat_messages "
            " WHERE chat_id = $1::int "
            "   AND user_id = $2::int "
            "   AND created_at > NOW() - INTERVAL '10 seconds'",
            {std::to_string(chatId), userIdStr});
        const long long recent = rl.empty() ? 0 : rl[0]["n"].as<long long>();
        if (recent >= 3) {
            return jsonError(HttpStatus::BAD_REQUEST,
                             "slow down — 3 messages / 10 sec limit");
        }

        auto ins = db->query(
            "INSERT INTO chat_messages (chat_id, user_id, message) "
            "VALUES ($1::int, $2::int, $3) "
            "RETURNING id, "
            "  TO_CHAR(created_at AT TIME ZONE 'UTC', "
            "          'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at",
            {std::to_string(chatId), userIdStr, trimmed});

        if (ins.empty()) {
            return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "insert failed");
        }

        auto meta = db->query(
            "SELECT p.first_name, p.last_name, u.person_id "
            "  FROM users u JOIN persons p ON p.id = u.person_id "
            " WHERE u.id = $1::int LIMIT 1",
            {userIdStr});

        json out = {
            {"id",         ins[0]["id"].as<long long>()},
            {"user_id",    std::stoll(userIdStr)},
            {"message",    trimmed},
            {"created_at", ins[0]["created_at"].as<std::string>()},
        };
        if (!meta.empty()) {
            out["author_first_name"] = meta[0]["first_name"].is_null() ? std::string{} : meta[0]["first_name"].as<std::string>();
            out["author_last_name"]  = meta[0]["last_name"].is_null()  ? std::string{} : meta[0]["last_name"].as<std::string>();
            out["person_id"]         = meta[0]["person_id"].as<long long>();
        }
        return jsonOk(out);
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/my/chat/messages] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
