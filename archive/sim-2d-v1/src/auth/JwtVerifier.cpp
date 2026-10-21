// footballhome sim - JWT (HS256) verifier implementation
//
// See JwtVerifier.hpp for the design contract. Nothing here throws.

#include "auth/JwtVerifier.hpp"

#include <openssl/crypto.h>   // CRYPTO_memcmp
#include <openssl/hmac.h>

#include <array>
#include <cctype>
#include <cstddef>
#include <cstdint>
#include <ctime>
#include <string>
#include <string_view>
#include <vector>

namespace fh::sim::auth {

namespace {

// ---------------------------------------------------------------------------
// Base64url decoder. RFC 7515 §2: alphabet A-Z a-z 0-9 -_, no padding.
// Padding-if-present is accepted (backend doesn't emit it, but be lenient
// on input). Returns empty on any invalid byte.
// ---------------------------------------------------------------------------
bool b64UrlChar(char c, unsigned& out) noexcept {
    if (c >= 'A' && c <= 'Z') { out = static_cast<unsigned>(c - 'A');       return true; }
    if (c >= 'a' && c <= 'z') { out = static_cast<unsigned>(c - 'a' + 26);  return true; }
    if (c >= '0' && c <= '9') { out = static_cast<unsigned>(c - '0' + 52);  return true; }
    if (c == '-')             { out = 62;                                   return true; }
    if (c == '_')             { out = 63;                                   return true; }
    return false;
}

std::string base64UrlDecode(std::string_view in) {
    // Strip any padding — RFC 7515 forbids it on the wire but tolerating
    // it in decode is cheap and avoids surprise interop failures.
    while (!in.empty() && in.back() == '=') { in.remove_suffix(1); }

    std::string out;
    out.reserve((in.size() * 3) / 4);

    std::uint32_t buf = 0;
    unsigned bits = 0;
    for (const char c : in) {
        unsigned v = 0;
        if (!b64UrlChar(c, v)) { return {}; }
        buf = (buf << 6) | v;
        bits += 6;
        if (bits >= 8) {
            bits -= 8;
            out.push_back(static_cast<char>((buf >> bits) & 0xFFu));
        }
    }
    return out;
}

// ---------------------------------------------------------------------------
// HMAC-SHA256 over `data` with `key`. Wraps the OpenSSL C API; returns
// empty on any failure. No exceptions.
// ---------------------------------------------------------------------------
std::string hmacSha256(std::string_view key, std::string_view data) {
    std::array<unsigned char, EVP_MAX_MD_SIZE> out{};
    unsigned int out_len = 0;
    const unsigned char* result = HMAC(
        EVP_sha256(),
        key.data(), static_cast<int>(key.size()),
        reinterpret_cast<const unsigned char*>(data.data()), data.size(),
        out.data(), &out_len);
    if (result == nullptr || out_len == 0) { return {}; }
    return std::string(reinterpret_cast<const char*>(out.data()), out_len);
}

// ---------------------------------------------------------------------------
// Constant-time comparison of two equal-length byte strings. Length is
// checked non-CT (leaking length is fine — signature length is public).
// ---------------------------------------------------------------------------
bool ctEqual(std::string_view a, std::string_view b) noexcept {
    if (a.size() != b.size()) { return false; }
    return CRYPTO_memcmp(a.data(), b.data(), a.size()) == 0;
}

// ---------------------------------------------------------------------------
// Header check. We accept exactly `{"alg":"HS256","typ":"JWT"}` shape,
// tolerating whitespace between tokens. Anything else — including
// "alg":"none" or "alg":"HS512" — is rejected.
// ---------------------------------------------------------------------------
void skipWs(std::string_view s, std::size_t& i) noexcept {
    while (i < s.size()
           && (s[i] == ' ' || s[i] == '\t' || s[i] == '\n' || s[i] == '\r')) {
        ++i;
    }
}

bool matchLiteral(std::string_view s, std::size_t& i, std::string_view lit) noexcept {
    if (s.size() - i < lit.size()) { return false; }
    for (std::size_t k = 0; k < lit.size(); ++k) {
        if (s[i + k] != lit[k]) { return false; }
    }
    i += lit.size();
    return true;
}

bool matchQuotedString(std::string_view s, std::size_t& i, std::string_view expected) noexcept {
    if (i >= s.size() || s[i] != '"') { return false; }
    ++i;
    if (!matchLiteral(s, i, expected)) { return false; }
    if (i >= s.size() || s[i] != '"') { return false; }
    ++i;
    return true;
}

bool headerIsHs256(std::string_view header_json) noexcept {
    // Expected: { "alg":"HS256" , "typ":"JWT" }   (either order accepted)
    std::size_t i = 0;
    skipWs(header_json, i);
    if (i >= header_json.size() || header_json[i] != '{') { return false; }
    ++i;

    bool saw_alg = false;
    bool saw_typ = false;
    for (int field = 0; field < 2; ++field) {
        skipWs(header_json, i);
        if (i >= header_json.size() || header_json[i] != '"') { return false; }
        ++i;
        // Field key
        const std::size_t key_start = i;
        while (i < header_json.size() && header_json[i] != '"') { ++i; }
        if (i >= header_json.size()) { return false; }
        const std::string_view key = header_json.substr(key_start, i - key_start);
        ++i;   // closing "

        skipWs(header_json, i);
        if (i >= header_json.size() || header_json[i] != ':') { return false; }
        ++i;
        skipWs(header_json, i);

        if (key == "alg") {
            if (!matchQuotedString(header_json, i, "HS256")) { return false; }
            saw_alg = true;
        } else if (key == "typ") {
            if (!matchQuotedString(header_json, i, "JWT")) { return false; }
            saw_typ = true;
        } else {
            // Unknown header field — reject conservatively. JWT header
            // extensions could go here later; for now HS256/JWT-only.
            return false;
        }

        skipWs(header_json, i);
        if (field == 0) {
            if (i >= header_json.size() || header_json[i] != ',') { return false; }
            ++i;
        }
    }
    skipWs(header_json, i);
    if (i >= header_json.size() || header_json[i] != '}') { return false; }
    return saw_alg && saw_typ;
}

// ---------------------------------------------------------------------------
// Extract a JSON integer claim: scan the payload for `"<name>"` followed
// (with optional whitespace) by ':' and an integer. Returns true and
// writes to `out` if found; false otherwise. Does NOT match integers
// inside nested objects or arrays — the sim's minted payloads are flat.
// ---------------------------------------------------------------------------
bool findIntClaim(std::string_view json,
                  std::string_view name,
                  std::int64_t&    out) noexcept
{
    // Build the exact needle including the quotes to avoid substring
    // collisions ("iat_" would match "iat").
    std::string needle;
    needle.reserve(name.size() + 2);
    needle.push_back('"');
    needle.append(name);
    needle.push_back('"');

    std::size_t pos = 0;
    while (pos + needle.size() <= json.size()) {
        pos = json.find(needle, pos);
        if (pos == std::string_view::npos) { return false; }
        std::size_t i = pos + needle.size();
        skipWs(json, i);
        if (i >= json.size() || json[i] != ':') { pos += needle.size(); continue; }
        ++i;
        skipWs(json, i);

        // Optional sign
        bool negative = false;
        if (i < json.size() && (json[i] == '-' || json[i] == '+')) {
            negative = (json[i] == '-');
            ++i;
        }
        if (i >= json.size() || !std::isdigit(static_cast<unsigned char>(json[i]))) {
            return false;
        }
        std::int64_t val = 0;
        while (i < json.size() && std::isdigit(static_cast<unsigned char>(json[i]))) {
            // Overflow-safe accumulation. Any overflow → reject.
            const int d = json[i] - '0';
            if (val > (INT64_MAX - d) / 10) { return false; }
            val = val * 10 + d;
            ++i;
        }
        out = negative ? -val : val;
        return true;
    }
    return false;
}

} // namespace

// ---------------------------------------------------------------------------
JwtVerifier::JwtVerifier(std::string secret, Clock clock)
    : secret_(std::move(secret))
    , clock_(clock ? std::move(clock)
                   : Clock{[]() -> std::int64_t {
                         return static_cast<std::int64_t>(std::time(nullptr));
                     }})
{}

std::optional<JwtClaims> JwtVerifier::verify(std::string_view token) const
{
    if (secret_.empty()) { return std::nullopt; }

    // -- Split on the two '.' separators -----------------------------------
    const std::size_t dot1 = token.find('.');
    if (dot1 == std::string_view::npos) { return std::nullopt; }
    const std::size_t dot2 = token.find('.', dot1 + 1);
    if (dot2 == std::string_view::npos) { return std::nullopt; }
    if (token.find('.', dot2 + 1) != std::string_view::npos) { return std::nullopt; }

    const std::string_view header_b64  = token.substr(0, dot1);
    const std::string_view payload_b64 = token.substr(dot1 + 1, dot2 - dot1 - 1);
    const std::string_view sig_b64     = token.substr(dot2 + 1);
    if (header_b64.empty() || payload_b64.empty() || sig_b64.empty()) {
        return std::nullopt;
    }

    // -- Header must be HS256/JWT ------------------------------------------
    const std::string header_json = base64UrlDecode(header_b64);
    if (header_json.empty() || !headerIsHs256(header_json)) {
        return std::nullopt;
    }

    // -- Verify signature over the raw base64url `header.payload` ----------
    const std::string signing_input =
        std::string(header_b64) + "." + std::string(payload_b64);
    const std::string expected_sig  = hmacSha256(secret_, signing_input);
    const std::string provided_sig  = base64UrlDecode(sig_b64);
    if (expected_sig.empty() || provided_sig.empty()) { return std::nullopt; }
    if (!ctEqual(expected_sig, provided_sig))         { return std::nullopt; }

    // -- Parse payload -----------------------------------------------------
    const std::string payload_json = base64UrlDecode(payload_b64);
    if (payload_json.empty()) { return std::nullopt; }

    JwtClaims claims;

    if (!findIntClaim(payload_json, "person_id", claims.person_id)) {
        return std::nullopt;
    }
    if (claims.person_id <= 0) { return std::nullopt; }

    if (!findIntClaim(payload_json, "exp", claims.exp)) {
        return std::nullopt;
    }
    findIntClaim(payload_json, "iat", claims.iat);   // optional

    // -- Expiry check ------------------------------------------------------
    const std::int64_t now = clock_();
    if (claims.exp <= now) { return std::nullopt; }

    return claims;
}

} // namespace fh::sim::auth
