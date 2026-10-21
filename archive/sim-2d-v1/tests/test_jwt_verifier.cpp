// footballhome sim - JwtVerifier tests
//
// Covers the happy path and every rejection branch. Uses a small
// in-test signer to mint tokens so each case builds exactly the bytes
// it wants to test against.

#include "auth/JwtVerifier.hpp"
#include "test_harness.hpp"

#include <openssl/hmac.h>

#include <array>
#include <cstdint>
#include <string>
#include <string_view>

namespace {

// -----------------------------------------------------------------------
// Minimal test-only base64url encoder + HS256 signer. Not shipped; if
// you find yourself wanting to use these outside tests, move them into
// sim/src/auth/ properly (with all the same no-exceptions discipline as
// JwtVerifier).
// -----------------------------------------------------------------------
constexpr char kB64Alpha[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

std::string b64url(std::string_view in) {
    std::string out;
    out.reserve(((in.size() + 2) / 3) * 4);
    std::uint32_t buf = 0;
    unsigned bits = 0;
    for (unsigned char c : in) {
        buf = (buf << 8) | c;
        bits += 8;
        while (bits >= 6) {
            bits -= 6;
            out.push_back(kB64Alpha[(buf >> bits) & 0x3Fu]);
        }
    }
    if (bits > 0) {
        out.push_back(kB64Alpha[(buf << (6 - bits)) & 0x3Fu]);
    }
    return out;   // no padding — RFC 7515 style
}

std::string hmacSha256(std::string_view key, std::string_view data) {
    std::array<unsigned char, EVP_MAX_MD_SIZE> out{};
    unsigned int out_len = 0;
    HMAC(EVP_sha256(),
         key.data(), static_cast<int>(key.size()),
         reinterpret_cast<const unsigned char*>(data.data()), data.size(),
         out.data(), &out_len);
    return std::string(reinterpret_cast<const char*>(out.data()), out_len);
}

std::string signHs256(std::string_view header_json,
                      std::string_view payload_json,
                      std::string_view secret) {
    const std::string h = b64url(header_json);
    const std::string p = b64url(payload_json);
    const std::string s = b64url(hmacSha256(secret, h + "." + p));
    return h + "." + p + "." + s;
}

// Canonical valid header + short-lived claims.
constexpr std::string_view kHeader = R"({"alg":"HS256","typ":"JWT"})";
constexpr std::string_view kSecret = "super-secret-shared-with-backend-32bytes!";

std::string simClaims(std::int64_t person_id,
                      std::int64_t iat,
                      std::int64_t exp) {
    std::string out;
    out.reserve(80);
    out.append("{\"person_id\":");
    out.append(std::to_string(person_id));
    out.append(",\"iat\":");
    out.append(std::to_string(iat));
    out.append(",\"exp\":");
    out.append(std::to_string(exp));
    out.append("}");
    return out;
}

// Frozen-clock helper so tests don't race the wall clock.
fh::sim::auth::Clock fixedClock(std::int64_t now) {
    return [now]() { return now; };
}

} // namespace

using fh::sim::auth::JwtClaims;
using fh::sim::auth::JwtVerifier;

FH_TEST(verifies_valid_token) {
    JwtVerifier v(std::string{kSecret}, fixedClock(1'000));
    const std::string tok = signHs256(kHeader, simClaims(42, 900, 2'000), kSecret);

    const auto claims = v.verify(tok);
    FH_EXPECT(claims.has_value());
    FH_EXPECT_EQ(claims->person_id, 42);
    FH_EXPECT_EQ(claims->iat,        900);
    FH_EXPECT_EQ(claims->exp,        2'000);
}

FH_TEST(rejects_expired_token) {
    // exp equals now — must be rejected (strict >).
    JwtVerifier v(std::string{kSecret}, fixedClock(2'000));
    const std::string tok = signHs256(kHeader, simClaims(42, 900, 2'000), kSecret);
    FH_EXPECT(!v.verify(tok).has_value());
}

FH_TEST(rejects_wrong_signature) {
    JwtVerifier v(std::string{kSecret}, fixedClock(1'000));
    // Sign with a different secret.
    const std::string tok = signHs256(kHeader, simClaims(42, 900, 2'000),
                                      "wrong-secret");
    FH_EXPECT(!v.verify(tok).has_value());
}

FH_TEST(rejects_tampered_payload) {
    JwtVerifier v(std::string{kSecret}, fixedClock(1'000));
    std::string tok = signHs256(kHeader, simClaims(42, 900, 2'000), kSecret);
    // Flip the last char of the payload segment — invalidates the sig.
    const std::size_t dot1 = tok.find('.');
    const std::size_t dot2 = tok.find('.', dot1 + 1);
    if (dot2 > dot1 + 1) {
        tok[dot2 - 1] = (tok[dot2 - 1] == 'A' ? 'B' : 'A');
    }
    FH_EXPECT(!v.verify(tok).has_value());
}

FH_TEST(rejects_alg_none) {
    // Classic JWT "alg:none" attack — must be refused before signature
    // is even checked.
    JwtVerifier v(std::string{kSecret}, fixedClock(1'000));
    const std::string tok = b64url(R"({"alg":"none","typ":"JWT"})") + "."
                          + b64url(simClaims(42, 900, 2'000)) + ".";
    FH_EXPECT(!v.verify(tok).has_value());
}

FH_TEST(rejects_wrong_algorithm) {
    JwtVerifier v(std::string{kSecret}, fixedClock(1'000));
    const std::string tok = signHs256(R"({"alg":"HS512","typ":"JWT"})",
                                      simClaims(42, 900, 2'000), kSecret);
    FH_EXPECT(!v.verify(tok).has_value());
}

FH_TEST(rejects_wrong_typ) {
    JwtVerifier v(std::string{kSecret}, fixedClock(1'000));
    const std::string tok = signHs256(R"({"alg":"HS256","typ":"JWE"})",
                                      simClaims(42, 900, 2'000), kSecret);
    FH_EXPECT(!v.verify(tok).has_value());
}

FH_TEST(rejects_missing_person_id) {
    JwtVerifier v(std::string{kSecret}, fixedClock(1'000));
    const std::string payload = R"({"iat":900,"exp":2000})";
    const std::string tok = signHs256(kHeader, payload, kSecret);
    FH_EXPECT(!v.verify(tok).has_value());
}

FH_TEST(rejects_zero_or_negative_person_id) {
    JwtVerifier v(std::string{kSecret}, fixedClock(1'000));
    // person_id must be a positive integer (postgres SERIAL starts at 1).
    const std::string zero_tok = signHs256(kHeader, simClaims(0, 900, 2'000), kSecret);
    const std::string neg_tok  = signHs256(kHeader, simClaims(-5, 900, 2'000), kSecret);
    FH_EXPECT(!v.verify(zero_tok).has_value());
    FH_EXPECT(!v.verify(neg_tok).has_value());
}

FH_TEST(rejects_missing_exp) {
    JwtVerifier v(std::string{kSecret}, fixedClock(1'000));
    const std::string payload = R"({"person_id":42,"iat":900})";
    const std::string tok = signHs256(kHeader, payload, kSecret);
    FH_EXPECT(!v.verify(tok).has_value());
}

FH_TEST(rejects_malformed_structure) {
    JwtVerifier v(std::string{kSecret}, fixedClock(1'000));
    FH_EXPECT(!v.verify("").has_value());
    FH_EXPECT(!v.verify("not.a.jwt.extra").has_value());
    FH_EXPECT(!v.verify("only.two").has_value());
    FH_EXPECT(!v.verify("...").has_value());
    FH_EXPECT(!v.verify("abc..xyz").has_value());   // empty payload segment
}

FH_TEST(rejects_bad_base64) {
    JwtVerifier v(std::string{kSecret}, fixedClock(1'000));
    // Legal shape but header contains a byte outside the base64url
    // alphabet — must fail cleanly, not crash.
    FH_EXPECT(!v.verify("abc!def.eyJhIjoxfQ.deadbeef").has_value());
}

FH_TEST(empty_secret_verifier_fails_every_token) {
    // A misconfigured server (no JWT_SECRET) must never authenticate anyone.
    JwtVerifier v("", fixedClock(1'000));
    const std::string tok = signHs256(kHeader, simClaims(42, 900, 2'000), "");
    FH_EXPECT(!v.verify(tok).has_value());
}

FH_TEST(tolerates_whitespace_in_payload) {
    // Backend emits compact JSON, but be lenient — some test fixtures /
    // future minters may add whitespace. Signature check still binds
    // the bytes, so this is safe: whitespace-in doesn't let an attacker
    // shift claims after signing.
    JwtVerifier v(std::string{kSecret}, fixedClock(1'000));
    const std::string payload = R"({ "person_id" : 42 , "iat" : 900 , "exp" : 2000 })";
    const std::string tok = signHs256(kHeader, payload, kSecret);
    const auto claims = v.verify(tok);
    FH_EXPECT(claims.has_value());
    FH_EXPECT_EQ(claims->person_id, 42);
}

FH_TEST(rejects_bad_signature_bytes) {
    // Signature segment decodes but bytes don't match — this is a
    // separate branch from "payload tampered" (which changes the
    // signing_input); make sure we cover the CT-compare failure path
    // for a valid-length decoded sig.
    JwtVerifier v(std::string{kSecret}, fixedClock(1'000));
    std::string tok = signHs256(kHeader, simClaims(42, 900, 2'000), kSecret);
    // Overwrite entire signature segment with a same-length base64url of
    // 32 zero bytes.
    const std::size_t dot2 = tok.rfind('.');
    std::string zeros(32, '\0');
    tok = tok.substr(0, dot2 + 1) + b64url(zeros);
    FH_EXPECT(!v.verify(tok).has_value());
}

FH_TEST_MAIN()
