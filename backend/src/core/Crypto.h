#pragma once

#include <string>

// Crypto — small OpenSSL-backed helpers used by the magic-link auth
// stack (and reusable elsewhere).  Kept namespace-scoped on purpose:
// these are pure functions, never need instance state, and live in
// core/ so any service or controller can pull them in cheaply.
namespace fh::crypto {

// Hex-encoded SHA-256 of the input string.  Used for hashing session
// cookies and magic-link tokens before persisting them — the raw
// values are never written to disk.
std::string sha256Hex(const std::string& value);

// Cryptographically-strong random byte sequence, base64url-encoded
// (no padding, URL-safe alphabet).  Defaults to 32 bytes (256 bits)
// which gives 43-char tokens — long enough that brute force isn't
// a credible threat and short enough to fit comfortably in a URL.
std::string randomTokenB64Url(std::size_t bytes = 32);

// Convenience wrappers reused by the cookie + URL building.
std::string base64UrlEncode(const std::string& raw);
std::string urlEncode(const std::string& raw);

// Inverse of base64UrlEncode — accepts the URL-safe alphabet (- and _),
// re-pads to a multiple of 4 if needed, and returns the raw bytes.  Used
// when verifying JWT payloads and decoding magic-link tokens.
std::string base64UrlDecode(const std::string& encoded);

// ──────────────────────────────────────────────────────────────────────
// JWT (HS256) — used by AuthController and OAuthController for issuing
// login tokens, and by Controller::requireBearer for verifying them on
// every authenticated request.  Both issuers MUST use signJwtHS256 and
// the sole verifier MUST use verifyJwtHS256 so the two flows can never
// drift again.
// ──────────────────────────────────────────────────────────────────────

// Returns the JWT signing secret.  Reads the JWT_SECRET env var on
// first call; if unset (or empty), generates a cryptographically-random
// 32-byte secret and caches it in a function-local static, logging a
// loud warning that all sessions will be invalidated on the next
// process restart.  This is deliberately non-fatal so a fresh dev
// checkout still boots — production MUST set JWT_SECRET.
const std::string& jwtSecret();

// HMAC-SHA256(key, data).  Returns 32 raw bytes.
std::string hmacSha256(const std::string& key, const std::string& data);

// Signs a JWT using HS256 with the process JWT secret.  Header is the
// fixed literal {"alg":"HS256","typ":"JWT"} and the payload is passed
// through verbatim (caller is responsible for including "exp" and any
// other claims).  Returns "header.payload.signature" with all three
// parts base64url-encoded (no padding).
std::string signJwtHS256(const std::string& payloadJson);

// Verifies an HS256-signed JWT against the process JWT secret.
// Checks (in order):
//   1. token has exactly two '.' separators
//   2. header decodes and contains alg=HS256
//   3. signature matches, compared in constant time
//   4. payload's "exp" claim (if present) is >= now (Unix seconds)
// On success, if outPayloadJson is non-null, it receives the decoded
// payload JSON string.  Returns false on any failure without leaking
// which check failed.
bool verifyJwtHS256(const std::string& token, std::string* outPayloadJson = nullptr);

}  // namespace fh::crypto
