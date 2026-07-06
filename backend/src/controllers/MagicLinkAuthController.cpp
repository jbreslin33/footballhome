#include "MagicLinkAuthController.h"

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "../services/SessionService.h"
#include "../third_party/json.hpp"

#include <algorithm>
#include <cctype>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <regex>
#include <sstream>
#include <stdexcept>

using nlohmann::json;

namespace {

// Mirror of the Node PUBLIC_BASE_URL: env override, default to prod,
// trailing slashes stripped.  Evaluated lazily and cached because the
// env doesn't change at runtime.
const std::string& publicBaseUrl() {
    static const std::string value = [] {
        const char* env = std::getenv("PUBLIC_BASE_URL");
        std::string v = (env && *env) ? std::string(env) : std::string("https://footballhome.org");
        while (!v.empty() && v.back() == '/') v.pop_back();
        return v;
    }();
    return value;
}

// JSON helpers — `j.value()` throws on type mismatch, so we wrap the
// common int/string extractions with explicit handling that mirrors
// Node's loose `parseInt` / `String(...)` coercions.
std::optional<long long> jsonInt(const json& j, const char* key) {
    if (!j.contains(key) || j[key].is_null()) return std::nullopt;
    if (j[key].is_number_integer())  return j[key].get<long long>();
    if (j[key].is_number_unsigned()) return static_cast<long long>(j[key].get<unsigned long long>());
    if (j[key].is_number_float())    return static_cast<long long>(j[key].get<double>());
    if (j[key].is_string()) {
        try { return std::stoll(j[key].get<std::string>()); }
        catch (...) { return std::nullopt; }
    }
    return std::nullopt;
}

std::string jsonStr(const json& j, const char* key) {
    if (!j.contains(key) || j[key].is_null()) return {};
    if (j[key].is_string()) return j[key].get<std::string>();
    return j[key].dump();
}

std::string trim(std::string s) {
    auto issp = [](unsigned char c) { return std::isspace(c) != 0; };
    while (!s.empty() && issp(static_cast<unsigned char>(s.front()))) s.erase(s.begin());
    while (!s.empty() && issp(static_cast<unsigned char>(s.back())))  s.pop_back();
    return s;
}

std::string toLower(std::string s) {
    std::transform(s.begin(), s.end(), s.begin(),
                   [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
    return s;
}

// Pull just the first IP out of an X-Forwarded-For chain (may be
// "client, proxy1, proxy2").  Matches the Node `.split(',')[0].trim()`.
std::string firstForwardedIp(const std::string& xff) {
    const std::size_t comma = xff.find(',');
    return trim(xff.substr(0, comma == std::string::npos ? xff.size() : comma));
}

Response htmlError(HttpStatus s, const std::string& msg) {
    Response r(s, msg);
    r.setHeader("Content-Type", "text/plain; charset=utf-8");
    return r;
}

Response jsonError(HttpStatus s, const std::string& message) {
    json body = {{"error", message}};
    return Response(s, body.dump());
}

}  // namespace

MagicLinkAuthController::MagicLinkAuthController() = default;
MagicLinkAuthController::~MagicLinkAuthController() = default;

void MagicLinkAuthController::registerRoutes(Router& router, const std::string& prefix) {
    router.post(prefix + "/magic-link/mint",   [this](const Request& r) { return handleMint(r); });
    router.get (prefix + "/magic-link/verify", [this](const Request& r) { return handleVerify(r); });
    router.get (prefix + "/me",                [this](const Request& r) { return handleMe(r); });
    router.post(prefix + "/logout",            [this](const Request& r) { return handleLogout(r); });
}

bool MagicLinkAuthController::useSecureCookies() const {
    // Node's check is `!/^http:\/\//i.test(PUBLIC_BASE_URL)` — i.e.
    // anything that's NOT plain HTTP gets the Secure flag.  We keep
    // identical semantics so cookies issued by either backend behave
    // the same way for the browser.
    const std::string& base = publicBaseUrl();
    if (base.size() < 7) return true;
    const std::string scheme = toLower(base.substr(0, 7));
    return scheme != "http://";
}

bool MagicLinkAuthController::extractBearerUserId(const Request& request,
                                                  std::string& outUserId) {
    const std::string h = request.getHeader("Authorization");
    if (h.size() < 8 || h.compare(0, 7, "Bearer ") != 0) return false;

    const std::string token = h.substr(7);
    const std::size_t dot1 = token.find('.');
    if (dot1 == std::string::npos) return false;
    const std::size_t dot2 = token.find('.', dot1 + 1);
    if (dot2 == std::string::npos) return false;

    std::string payload = token.substr(dot1 + 1, dot2 - dot1 - 1);
    // base64url → base64
    for (auto& c : payload) {
        if (c == '-') c = '+';
        else if (c == '_') c = '/';
    }
    while (payload.size() % 4) payload.push_back('=');

    auto b64decode = [](const std::string& in) -> std::string {
        static int t[256];
        static bool initted = false;
        if (!initted) {
            for (int i = 0; i < 256; ++i) t[i] = -1;
            const char* a = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
            for (int i = 0; i < 64; ++i) t[static_cast<unsigned char>(a[i])] = i;
            initted = true;
        }
        std::string out;
        int  val   = 0;
        int  valb  = -8;
        for (unsigned char c : in) {
            if (c == '=') break;
            int v = t[c];
            if (v < 0) continue;
            val   = (val << 6) | v;
            valb += 6;
            if (valb >= 0) {
                out.push_back(static_cast<char>((val >> valb) & 0xFF));
                valb -= 8;
            }
        }
        return out;
    };

    const std::string decoded = b64decode(payload);
    try {
        const json j = json::parse(decoded);
        if (!j.contains("userId")) return false;
        const auto& u = j["userId"];
        if (u.is_string())  outUserId = u.get<std::string>();
        else if (u.is_number_integer()) outUserId = std::to_string(u.get<long long>());
        else if (u.is_number_unsigned()) outUserId = std::to_string(u.get<unsigned long long>());
        else return false;
        return !outUserId.empty();
    } catch (...) {
        return false;
    }
}

Response MagicLinkAuthController::handleMint(const Request& request) {
    std::string adminUserIdStr;
    if (!extractBearerUserId(request, adminUserIdStr)) {
        return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    json body;
    try {
        body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
    } catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
    }

    auto personIdOpt = jsonInt(body, "person_id");
    if (!personIdOpt) return jsonError(HttpStatus::BAD_REQUEST, "person_id required");
    const long long personId = *personIdOpt;

    auto chatEventIdOpt = jsonInt(body, "chat_event_id");
    auto matchIdOpt     = jsonInt(body, "match_id");
    auto teamIdOpt      = jsonInt(body, "team_id");

    const std::string channel = toLower(trim(jsonStr(body, "channel")));
    const std::string contact = trim(jsonStr(body, "contact"));
    if (channel != "email" && channel != "sms") {
        return jsonError(HttpStatus::BAD_REQUEST, "channel must be 'email' or 'sms'");
    }
    if (contact.empty()) {
        return jsonError(HttpStatus::BAD_REQUEST, "contact required");
    }

    auto* db = Database::getInstance();

    try {
        // Resolve chat_event_id from (match_id, team_id) — picks the
        // most recently created chat_event for that match scoped to
        // the team's chat.  Mirrors the Node fallback verbatim.
        if (!chatEventIdOpt && matchIdOpt && teamIdOpt) {
            auto ev = db->query(
                "SELECT ce.id FROM chat_events ce "
                "JOIN chats c ON c.id = ce.chat_id "
                "WHERE ce.match_id = $1::int AND c.team_id = $2::int "
                "ORDER BY ce.id DESC LIMIT 1",
                {std::to_string(*matchIdOpt), std::to_string(*teamIdOpt)});
            if (!ev.empty()) chatEventIdOpt = ev[0]["id"].as<long long>();
        }

        // Resolve admin user (audit only; non-fatal if missing).
        std::string adminUserParam;
        try {
            auto admin = db->query(
                "SELECT id FROM users WHERE id = $1::int LIMIT 1",
                {adminUserIdStr});
            if (!admin.empty()) adminUserParam = admin[0]["id"].as<std::string>();
        } catch (...) {
            // Non-fatal — leave adminUserParam empty so we insert NULL.
        }

        // Fetch person.
        auto personRow = db->query(
            "SELECT id, first_name FROM persons WHERE id = $1::int LIMIT 1",
            {std::to_string(personId)});
        if (personRow.empty()) {
            return jsonError(HttpStatus::NOT_FOUND, "Person not found");
        }
        const std::string firstName = personRow[0]["first_name"].as<std::string>();

        // Fetch event (optional).  We let Postgres format the "when"
        // string in America/New_York so we don't have to drag a tz
        // database into the C++ side — exact same shape as the Node
        // toLocaleString output ("Sat, Jul 5 · 6:00 PM").
        std::string eventTitle;
        std::string eventLocation;
        std::string eventWhen;
        bool hasEvent = false;
        if (chatEventIdOpt) {
            auto evRow = db->query(
                "SELECT id, title, location, "
                "       to_char( "
                "         COALESCE(start_at, (event_date::timestamp + event_time))::timestamptz "
                "           AT TIME ZONE 'America/New_York', "
                "         'Dy, Mon FMDD\" \u00b7 \"FMHH12:MI AM') AS when_str "
                "  FROM chat_events WHERE id = $1::int LIMIT 1",
                {std::to_string(*chatEventIdOpt)});
            if (evRow.empty()) {
                return jsonError(HttpStatus::NOT_FOUND, "chat_event not found");
            }
            hasEvent = true;
            eventTitle    = evRow[0]["title"].is_null() ? std::string{} : evRow[0]["title"].as<std::string>();
            eventLocation = evRow[0]["location"].is_null() ? std::string{} : evRow[0]["location"].as<std::string>();
            eventWhen     = evRow[0]["when_str"].is_null() ? std::string{} : evRow[0]["when_str"].as<std::string>();
        }

        // Mint the token + write the row.  expires_at is computed
        // server-side from NOW() so the TTL is unaffected by clock
        // skew between this process and Postgres.
        const std::string token     = fh::crypto::randomTokenB64Url(32);
        const std::string tokenHash = fh::crypto::sha256Hex(token);
        const std::string ttlSecs   = std::to_string(SessionService::kMagicLinkTtl.count());

        auto ins = db->query(
            "INSERT INTO magic_link_tokens "
            "  (token_hash, person_id, chat_event_id, channel, contact, "
            "   minted_by_user_id, expires_at) "
            "VALUES ($1, $2::int, NULLIF($3, '')::int, $4, $5, "
            "        NULLIF($6, '')::int, "
            "        NOW() + ($7 || ' seconds')::interval) "
            "RETURNING to_char(expires_at AT TIME ZONE 'UTC', "
            "                   'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS expires_iso",
            {tokenHash,
             std::to_string(personId),
             chatEventIdOpt ? std::to_string(*chatEventIdOpt) : std::string{},
             channel, contact,
             adminUserParam,
             ttlSecs});
        const std::string expiresIso = ins[0]["expires_iso"].as<std::string>();

        const std::string verifyUrl = publicBaseUrl()
                                    + "/api/auth/magic-link/verify?token="
                                    + fh::crypto::urlEncode(token);

        // Body / subject — identical templates to Node.  Built once
        // because both the mailto: URI and the gmail compose URL need
        // the exact same encoded form.
        //
        // 2026-07-06: no-event branch reworked from a terse
        // "Tap to sign in" into a proper personal invite for roster
        // onboarding — coach clicks JOIN on a card and this becomes
        // the SMS / email body they see pre-filled.
        const std::string subject = hasEvent && !eventTitle.empty()
            ? "Football Home \u2014 RSVP for " + eventTitle
            : "Football Home \u2014 you're invited";

        std::ostringstream bodyOss;
        bodyOss << "Hi " << firstName << ",\n\n";
        if (hasEvent && !eventTitle.empty()) {
            bodyOss << "Tap to RSVP for " << eventTitle;
            const bool hasWhen = !eventWhen.empty();
            const bool hasLoc  = !eventLocation.empty();
            if (hasWhen) bodyOss << " (" << eventWhen;
            if (hasLoc)  bodyOss << (hasWhen ? ", " : " (") << eventLocation;
            if (hasWhen || hasLoc) bodyOss << ")";
            bodyOss << ":\n"
                    << verifyUrl << "\n\n"
                    << "This link signs you in automatically and expires in 24 hours.\n\n"
                    << "\u2014 Lighthouse Soccer";
        } else {
            bodyOss << "Lighthouse 1893 is rolling out a lightweight scheduling page "
                       "at footballhome.org so we have a clearer picture of who's coming each week.\n\n"
                    << "Tap the link below on your phone \u2014 no password needed \u2014 and "
                       "you'll land on your weekly schedule:\n"
                    << verifyUrl << "\n\n"
                    << "On the page you can:\n"
                    << "  \u2022 RSVP YES / NO / MAYBE for this week's games, practices, scrimmages and pickups\n"
                    << "  \u2022 Set default availability by day of week + event type so the page auto-fills\n"
                    << "  \u2022 Bookmark to your home screen (it works like an app)\n\n"
                    << "This link signs you in automatically and expires in 24 hours. "
                       "If you'd rather set a password for future visits, just tap "
                       "\"Forgot / set password\" on the sign-in screen.\n\n"
                    << "\u2014 Lighthouse Soccer";
        }
        const std::string bodyText = bodyOss.str();

        const std::string smsBody = (hasEvent && !eventTitle.empty())
            ? std::string("Lighthouse RSVP")
                + (eventWhen.empty()  ? std::string{} : (" " + eventWhen))
                + (eventTitle.empty() ? std::string{} : (" \u2014 " + eventTitle))
                + ": " + verifyUrl
            : std::string("Hey ") + firstName
                + " \u2014 Lighthouse 1893 is trying out a simple weekly RSVP page. "
                  "Tap here to see this week's games and let us know if you're in "
                  "(no password needed): " + verifyUrl;

        json out = {
            {"url",               verifyUrl},
            {"expires_at",        expiresIso},
            {"person_first_name", firstName},
            {"event_title",       hasEvent && !eventTitle.empty() ? json(eventTitle) : json(nullptr)},
            {"event_when",        hasEvent && !eventWhen.empty()  ? json(eventWhen)  : json(nullptr)},
        };

        if (channel == "email") {
            out["mailto_href"] = "mailto:" + fh::crypto::urlEncode(contact)
                               + "?subject=" + fh::crypto::urlEncode(subject)
                               + "&body="    + fh::crypto::urlEncode(bodyText);
            // Gmail web-compose form — same key order as Node's URLSearchParams
            // (view, fs, authuser, to, su, body) so the resulting URLs match
            // byte-for-byte in shape.
            out["gmail_href"]  = std::string("https://mail.google.com/mail/?")
                               + "view=cm"
                               + "&fs=1"
                               + "&authuser=" + fh::crypto::urlEncode("soccer@lighthouse1893.org")
                               + "&to="       + fh::crypto::urlEncode(contact)
                               + "&su="       + fh::crypto::urlEncode(subject)
                               + "&body="     + fh::crypto::urlEncode(bodyText);
        } else {
            out["sms_href"]    = "sms:" + fh::crypto::urlEncode(contact)
                               + "?body=" + fh::crypto::urlEncode(smsBody);
        }

        Response r(HttpStatus::OK, out.dump());
        r.setHeader("Content-Type", "application/json; charset=utf-8");
        return r;
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/auth/magic-link/mint] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response MagicLinkAuthController::handleVerify(const Request& request) {
    const std::string token = request.getQueryParam("token");
    if (token.empty()) return htmlError(HttpStatus::BAD_REQUEST, "Missing token");

    auto* db = Database::getInstance();
    const std::string hash = fh::crypto::sha256Hex(token);

    try {
        auto row = db->query(
            "SELECT id, person_id, chat_event_id, "
            "       (expires_at < NOW()) AS expired "
            "  FROM magic_link_tokens WHERE token_hash = $1",
            {hash});
        if (row.empty()) {
            return htmlError(HttpStatus::NOT_FOUND, "Invalid or expired link");
        }
        if (row[0]["expired"].as<bool>()) {
            return htmlError(HttpStatus(410),
                "This link has expired \u2014 ask Jim to send you a new one.");
        }

        const long long tokenRowId = row[0]["id"].as<long long>();
        const long long personId   = row[0]["person_id"].as<long long>();
        const bool      hasEvent   = !row[0]["chat_event_id"].is_null();
        const long long chatEventId = hasEvent ? row[0]["chat_event_id"].as<long long>() : 0;

        const std::string ua  = request.getHeader("User-Agent");
        const std::string xff = request.getHeader("X-Forwarded-For");
        const std::string ip  = firstForwardedIp(xff);

        auto& sessions = SessionService::getInstance();
        auto minted    = sessions.createSession(personId, ua, ip);

        db->query(
            "UPDATE magic_link_tokens "
            "   SET consumed_at = NOW(), consumed_session_id = $2::uuid "
            " WHERE id = $1::int",
            {std::to_string(tokenRowId), minted.sessionId});

        const std::string target = hasEvent
            ? (publicBaseUrl() + "/#rsvp/" + std::to_string(chatEventId))
            : (publicBaseUrl() + "/#my");

        Response r(HttpStatus::FOUND);
        r.setHeader("Location",   target);
        r.setHeader("Set-Cookie",
                    sessions.buildSetCookie(minted.cookieValue,
                                            SessionService::kSessionTtl,
                                            useSecureCookies()));
        // Browsers don't strictly need a body for 302 but some
        // intermediaries log warnings without one.
        r.setBody("Redirecting...");
        r.setHeader("Content-Type", "text/plain; charset=utf-8");
        return r;
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/auth/magic-link/verify] " << e.what() << std::endl;
        return htmlError(HttpStatus::INTERNAL_SERVER_ERROR, "Sign-in failed");
    }
}

Response MagicLinkAuthController::handleMe(const Request& request) {
    // SECURITY: Bearer JWT wins over cookie when both are present — see
    // MyController::requireSession comment for the full rationale.  The
    // pre-2026-07-06 order (cookie first) allowed a stale magic-link
    // cookie for user B to override a freshly-minted OAuth JWT for user
    // A on shared devices, silently returning B's identity + data.
    const std::string authHeader = request.getHeader("Authorization");
    if (authHeader.size() > 7 && authHeader.compare(0, 7, "Bearer ") == 0) {
        const std::string token = authHeader.substr(7);
        std::string payloadJson;
        if (fh::crypto::verifyJwtHS256(token, &payloadJson)) {
            try {
                json payload = json::parse(payloadJson);
                auto userIdOpt = jsonInt(payload, "userId");
                if (userIdOpt) {
                    auto* db = Database::getInstance();
                    auto row = db->query(
                        "SELECT u.id AS user_id, p.id AS person_id, "
                        "       p.first_name, p.last_name, "
                        "       COALESCE(pe.email, '') AS email, "
                        "       COALESCE(al.name, '') AS admin_level "
                        "  FROM users u "
                        "  JOIN persons p ON p.id = u.person_id "
                        "  LEFT JOIN LATERAL ("
                        "    SELECT email FROM person_emails "
                        "     WHERE person_id = u.person_id "
                        "     ORDER BY is_primary DESC, id ASC LIMIT 1"
                        "  ) pe ON true "
                        "  LEFT JOIN admins a ON a.user_id = u.id "
                        "  LEFT JOIN admin_levels al ON al.id = a.admin_level_id "
                        " WHERE u.id = $1::int LIMIT 1",
                        {std::to_string(*userIdOpt)});
                    if (row.empty()) {
                        return jsonError(HttpStatus::NOT_FOUND, "User not found");
                    }
                    const std::string first = row[0]["first_name"].is_null() ? "" : row[0]["first_name"].as<std::string>();
                    const std::string last  = row[0]["last_name"].is_null()  ? "" : row[0]["last_name"].as<std::string>();
                    const std::string adminLevel = row[0]["admin_level"].is_null() ? "" : row[0]["admin_level"].as<std::string>();
                    std::string full = first;
                    if (!last.empty()) { if (!full.empty()) full += " "; full += last; }
                    json user = {
                        {"id",         row[0]["user_id"].as<std::string>()},
                        {"email",      row[0]["email"].as<std::string>()},
                        {"first_name", first},
                        {"last_name",  last},
                        {"name",       full},
                        {"role",       adminLevel},
                    };
                    json out = {
                        {"success", true},
                        {"message", "Current user retrieved successfully"},
                        {"data",    {{"user", user}}},
                    };
                    Response r(HttpStatus::OK, out.dump());
                    r.setHeader("Content-Type", "application/json; charset=utf-8");
                    // Defense in depth: also clear any stale fh_sess
                    // cookie hitting this endpoint, so subsequent calls
                    // don't get silently re-attached to the wrong user.
                    r.setHeader("Set-Cookie",
                                "fh_sess=; Path=/; Max-Age=0; SameSite=Lax; HttpOnly");
                    return r;
                }
            } catch (const std::exception& e) {
                std::cerr << "[GET /api/auth/me] Bearer fallback: " << e.what() << std::endl;
                // fall through to cookie path
            }
        }
    }

    const std::string cookie  = request.getHeader("Cookie");
    const std::string sessVal = SessionService::parseCookieValue(cookie, SessionService::kCookieName);
    auto resolved = SessionService::getInstance().requireSession(sessVal);

    if (!resolved) {
        return jsonError(HttpStatus::UNAUTHORIZED,
                         sessVal.empty() ? "Not signed in" : "Session expired");
    }

    auto* db = Database::getInstance();
    try {
        auto row = db->query(
            "SELECT id, first_name, last_name, birth_date::text AS birth_date "
            "  FROM persons WHERE id = $1::int LIMIT 1",
            {std::to_string(resolved->personId)});
        if (row.empty()) {
            return jsonError(HttpStatus::NOT_FOUND, "Person not found");
        }
        json person = {
            {"id",         row[0]["id"].as<long long>()},
            {"first_name", row[0]["first_name"].as<std::string>()},
            {"last_name",  row[0]["last_name"].as<std::string>()},
            {"birth_date", row[0]["birth_date"].is_null()
                              ? json(nullptr)
                              : json(row[0]["birth_date"].as<std::string>())},
        };
        json out = {{"person", person}, {"sessionId", resolved->sessionId}};
        Response r(HttpStatus::OK, out.dump());
        r.setHeader("Content-Type", "application/json; charset=utf-8");
        return r;
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/auth/me] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response MagicLinkAuthController::handleLogout(const Request& request) {
    const std::string cookie  = request.getHeader("Cookie");
    const std::string sessVal = SessionService::parseCookieValue(cookie, SessionService::kCookieName);
    auto resolved = SessionService::getInstance().requireSession(sessVal);
    if (!resolved) {
        return jsonError(HttpStatus::UNAUTHORIZED,
                         sessVal.empty() ? "Not signed in" : "Session expired");
    }
    SessionService::getInstance().revoke(resolved->sessionId);

    json out = {{"ok", true}};
    Response r(HttpStatus::OK, out.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    r.setHeader("Set-Cookie",
                SessionService::getInstance().buildClearCookie(useSecureCookies()));
    return r;
}
