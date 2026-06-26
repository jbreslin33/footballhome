#pragma once
#include <string>

// ────────────────────────────────────────────────────────────────────────────
// JwtRS256 — minimal JWT signer using OpenSSL EVP for RS256.
//
// Used by LeagueAppsService to mint the JWT-bearer assertion that LA's
// /v2/auth/token endpoint exchanges for an OAuth access token.  No other
// JWT operations (verify, decode, HS256, ES256) are implemented because
// nothing else in this codebase needs them yet.
//
// All methods are static and free of side-effects.  Thread-safe.
// ────────────────────────────────────────────────────────────────────────────
class JwtRS256 {
public:
    // Sign `claimsJson` (a UTF-8 JSON string forming the payload) with the
    // supplied PEM-encoded RSA private key.  Produces the compact
    // serialization "<base64url-header>.<base64url-payload>.<base64url-sig>".
    //
    // Throws std::runtime_error on:
    //   - malformed PEM
    //   - any OpenSSL EVP failure
    //   - empty key or empty claims
    static std::string sign(const std::string& claimsJson,
                            const std::string& privateKeyPem);

    // Base64url-encode arbitrary bytes (RFC 4648 §5, no padding).  Exposed
    // for callers that need the same encoding outside of JWT.
    static std::string base64UrlEncode(const std::string& bytes);
};
