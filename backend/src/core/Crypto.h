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

}  // namespace fh::crypto
