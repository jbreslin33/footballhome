#include "MagicLinkService.h"

#include <cstdlib>

#include "../core/Crypto.h"
#include "../database/Database.h"
#include "SessionService.h"

const std::string& MagicLinkService::publicBaseUrl() {
    static const std::string value = [] {
        const char* env = std::getenv("PUBLIC_BASE_URL");
        std::string v = (env && *env) ? std::string(env) : std::string("https://footballhome.org");
        while (!v.empty() && v.back() == '/') v.pop_back();
        return v;
    }();
    return value;
}

MagicLinkService::Minted MagicLinkService::mint(long long          personId,
                                                const std::string& channel,
                                                const std::string& contact,
                                                long long          adminUserId,
                                                long long          chatEventId) {
    // Token + hash; expires_at is computed server-side from NOW() so the
    // TTL is unaffected by clock skew between this process and Postgres.
    const std::string token     = fh::crypto::randomTokenB64Url(32);
    const std::string tokenHash = fh::crypto::sha256Hex(token);
    const std::string ttlSecs   = std::to_string(SessionService::kMagicLinkTtl.count());

    auto ins = Database::getInstance()->query(
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
         chatEventId > 0 ? std::to_string(chatEventId) : std::string{},
         channel, contact,
         adminUserId > 0 ? std::to_string(adminUserId) : std::string{},
         ttlSecs});

    Minted out;
    out.expiresIso = ins[0]["expires_iso"].as<std::string>();
    out.url = publicBaseUrl()
            + "/api/auth/magic-link/verify?token="
            + fh::crypto::urlEncode(token);
    return out;
}
