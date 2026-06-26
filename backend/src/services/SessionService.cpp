#include "SessionService.h"

#include "../core/Crypto.h"
#include "../database/Database.h"

#include <iostream>
#include <sstream>

SessionService& SessionService::getInstance() {
    static SessionService instance;
    return instance;
}

SessionService::MintedSession SessionService::createSession(long long personId,
                                                            const std::string& userAgent,
                                                            const std::string& ip) {
    auto* db = Database::getInstance();

    const std::string cookieValue = fh::crypto::randomTokenB64Url(32);
    const std::string tokenHash   = fh::crypto::sha256Hex(cookieValue);

    // user_agent capped at 500 chars to match the Node slice; ip
    // empty-string flips to NULL via NULLIF.  Server-side NOW() +
    // interval keeps the TTL comparable in spite of any clock drift
    // between this process and Postgres.
    const std::string uaTrimmed = userAgent.size() > 500 ? userAgent.substr(0, 500) : userAgent;
    const std::string ttlSecs   = std::to_string(kSessionTtl.count());

    auto ins = db->query(
        "INSERT INTO sessions (person_id, token_hash, user_agent, ip, expires_at) "
        "VALUES ($1::int, $2, NULLIF($3, ''), NULLIF($4, '')::inet, "
        "        NOW() + ($5 || ' seconds')::interval) "
        "RETURNING id::text AS id",
        {std::to_string(personId), tokenHash, uaTrimmed, ip, ttlSecs});

    if (ins.empty()) {
        throw std::runtime_error("Failed to insert session row");
    }

    MintedSession out;
    out.sessionId   = ins[0]["id"].as<std::string>();
    out.cookieValue = cookieValue;
    return out;
}

std::optional<SessionService::ResolvedSession>
SessionService::requireSession(const std::string& cookieValue) {
    if (cookieValue.empty()) return std::nullopt;

    auto* db = Database::getInstance();
    const std::string hash    = fh::crypto::sha256Hex(cookieValue);
    const std::string ttlSecs = std::to_string(kSessionTtl.count());

    try {
        auto row = db->query(
            "UPDATE sessions "
            "   SET last_used_at = NOW(), "
            "       expires_at   = NOW() + ($2 || ' seconds')::interval "
            " WHERE token_hash = $1 "
            "   AND revoked_at IS NULL "
            "   AND expires_at > NOW() "
            " RETURNING id::text AS id, person_id",
            {hash, ttlSecs});

        if (row.empty()) return std::nullopt;

        ResolvedSession r;
        r.sessionId = row[0]["id"].as<std::string>();
        r.personId  = row[0]["person_id"].as<long long>();
        return r;
    } catch (const std::exception& e) {
        std::cerr << "[SessionService::requireSession] " << e.what() << std::endl;
        return std::nullopt;
    }
}

void SessionService::revoke(const std::string& sessionId) {
    auto* db = Database::getInstance();
    try {
        db->query(
            "UPDATE sessions SET revoked_at = NOW() WHERE id = $1::uuid",
            {sessionId});
    } catch (const std::exception& e) {
        std::cerr << "[SessionService::revoke] " << e.what() << std::endl;
    }
}

std::string SessionService::buildSetCookie(const std::string& cookieValue,
                                           std::chrono::seconds maxAge,
                                           bool useSecure) const {
    // URL-encode the value to keep base64url's +/= clones safe even
    // though our generator never emits them; matches Node behaviour
    // exactly so cookies issued under either backend stay decodable.
    std::ostringstream oss;
    oss << kCookieName << '=' << fh::crypto::urlEncode(cookieValue)
        << "; Path=/"
        << "; HttpOnly"
        << "; SameSite=Lax"
        << "; Max-Age=" << maxAge.count();
    if (useSecure) oss << "; Secure";
    return oss.str();
}

std::string SessionService::buildClearCookie(bool useSecure) const {
    std::ostringstream oss;
    oss << kCookieName << "="
        << "; Path=/"
        << "; HttpOnly"
        << "; SameSite=Lax"
        << "; Max-Age=0";
    if (useSecure) oss << "; Secure";
    return oss.str();
}

std::string SessionService::parseCookieValue(const std::string& cookieHeader,
                                             const std::string& name) {
    // Cookie header is `k1=v1; k2=v2; ...`.  Walk it manually instead
    // of pulling in a regex — header is usually <200 chars and this
    // gets called on every authenticated request.
    std::size_t pos = 0;
    while (pos < cookieHeader.size()) {
        // Skip leading whitespace / separator commas.
        while (pos < cookieHeader.size() &&
               (cookieHeader[pos] == ' ' || cookieHeader[pos] == ';')) {
            ++pos;
        }
        std::size_t eq = cookieHeader.find('=', pos);
        if (eq == std::string::npos) break;

        std::size_t end = cookieHeader.find(';', eq + 1);
        if (end == std::string::npos) end = cookieHeader.size();

        const std::string key = cookieHeader.substr(pos, eq - pos);
        if (key == name) {
            std::string val = cookieHeader.substr(eq + 1, end - eq - 1);
            // URL-decode the percent-encoded value the same way the
            // Node parser does.
            std::string decoded;
            decoded.reserve(val.size());
            for (std::size_t i = 0; i < val.size(); ++i) {
                if (val[i] == '%' && i + 2 < val.size()) {
                    auto hex = [](char c) -> int {
                        if (c >= '0' && c <= '9') return c - '0';
                        if (c >= 'a' && c <= 'f') return c - 'a' + 10;
                        if (c >= 'A' && c <= 'F') return c - 'A' + 10;
                        return -1;
                    };
                    int hi = hex(val[i + 1]);
                    int lo = hex(val[i + 2]);
                    if (hi >= 0 && lo >= 0) {
                        decoded.push_back(static_cast<char>((hi << 4) | lo));
                        i += 2;
                        continue;
                    }
                }
                decoded.push_back(val[i]);
            }
            return decoded;
        }
        pos = end + 1;
    }
    return {};
}
