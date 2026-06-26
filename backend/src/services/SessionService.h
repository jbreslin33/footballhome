#pragma once

#include <chrono>
#include <optional>
#include <string>

// SessionService — owns the lifecycle of the `fh_sess` cookie-backed
// sessions table (migration 057).  Singleton: every controller that
// needs to check or mint a session goes through the same instance so
// cookie format, hashing, and sliding-TTL logic stay in one place.
//
// All persistence happens through the existing Database singleton; we
// keep no in-memory state of our own.  The class exists mainly to give
// the auth code a small, well-typed surface to call into instead of
// duplicating SQL and cookie strings across every handler.
class SessionService {
public:
    // 1 year (matches Node).  Sliding — every authenticated request
    // bumps expires_at = NOW() + this.
    static constexpr std::chrono::seconds kSessionTtl = std::chrono::seconds(365 * 24 * 60 * 60);

    // 24h (matches Node).  Fixed from mint time — verify does NOT
    // extend.  Tokens stay valid (and re-openable) until expiry.
    static constexpr std::chrono::seconds kMagicLinkTtl = std::chrono::seconds(24 * 60 * 60);

    // Cookie attribute name.  Must stay 'fh_sess' to match the Node
    // implementation; the system nginx and the SPA both assume it.
    static constexpr const char* kCookieName = "fh_sess";

    struct MintedSession {
        std::string sessionId;     // UUID, as returned by Postgres
        std::string cookieValue;   // raw base64url token to put in the cookie
    };

    struct ResolvedSession {
        std::string sessionId;
        long long   personId = 0;
    };

    static SessionService& getInstance();

    // Inserts a new sessions row and returns the random cookie value
    // (the caller is responsible for actually setting Set-Cookie).
    // userAgent / ip are best-effort — passed through to the audit
    // columns and may be empty.
    MintedSession createSession(long long personId,
                                const std::string& userAgent,
                                const std::string& ip);

    // Validates a raw cookie value: hashes it, bumps last_used_at +
    // expires_at by kSessionTtl, returns {sessionId, personId} if
    // active.  std::nullopt for missing / expired / revoked rows.
    std::optional<ResolvedSession> requireSession(const std::string& cookieValue);

    // Sets sessions.revoked_at = NOW() for the given session.
    void revoke(const std::string& sessionId);

    // Build the Set-Cookie header value for setting a fresh session.
    // The `useSecure` flag controls whether we append the Secure
    // attribute — required for HTTPS, must be off for plain-http dev.
    std::string buildSetCookie(const std::string& cookieValue,
                               std::chrono::seconds maxAge,
                               bool useSecure) const;

    // Build the Set-Cookie header value for clearing the session
    // (Max-Age=0, empty value).  Mirrors the Node clearSessionCookie.
    std::string buildClearCookie(bool useSecure) const;

    // Extract one cookie value from a raw "Cookie: ..." header by
    // name.  Returns empty string if not present.  Handles
    // URL-encoded values the same way the Node parser does.
    static std::string parseCookieValue(const std::string& cookieHeader,
                                        const std::string& name);

private:
    SessionService() = default;
    SessionService(const SessionService&) = delete;
    SessionService& operator=(const SessionService&) = delete;
};
