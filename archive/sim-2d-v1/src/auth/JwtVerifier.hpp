// footballhome sim - JWT (HS256) verifier
//
// Wire contract: every /sim WebSocket connection presents a JWT via
//     Sec-WebSocket-Protocol: fh-sim.v1.bearer.<token>
// (see DESIGN.md §7, §13). The token is minted by footballhome_backend
// using the same JWT_SECRET shared with this process. This class checks
// the signature, decodes the payload, and returns the sim-relevant claims.
//
// Design notes:
//   * No exceptions. Verification fails by returning std::nullopt so
//     callers can log & drop the connection without unwinding through
//     the WebSocket layer.
//   * Constant-time signature comparison (`CRYPTO_memcmp`).
//   * "alg":"none" is refused up front — the whole point is to accept
//     ONLY tokens that were HMAC-signed with the shared secret.
//   * Time is injected (`Clock` callable) so tests can hit exp-boundary
//     cases without depending on wall clock.
//   * Payload parse is deliberately tiny: we look for `"person_id":N`,
//     `"iat":N`, `"exp":N` as integer claims. Anything else is ignored.
//     JSON structure beyond that is not our problem — the shared minter
//     controls the format.

#pragma once

#include <cstdint>
#include <functional>
#include <optional>
#include <string>
#include <string_view>

namespace fh::sim::auth {

struct JwtClaims {
    std::int64_t person_id = 0;   // required
    std::int64_t iat       = 0;   // optional; 0 if absent
    std::int64_t exp       = 0;   // required; used for expiry check
};

// Injectable "now" — returns unix seconds. Default calls std::time.
using Clock = std::function<std::int64_t()>;

class JwtVerifier {
public:
    // secret is the raw HMAC key bytes (byte-for-byte match with the
    // JWT_SECRET env var on the backend). Empty secret is allowed for
    // construction but every verify() will fail — surfaces misconfig
    // early in tests without crashing the server on startup.
    explicit JwtVerifier(std::string secret, Clock clock = {});

    // Returns claims on success; nullopt on any failure (malformed,
    // wrong alg, bad signature, expired, missing person_id).
    std::optional<JwtClaims> verify(std::string_view token) const;

    // Diagnostic — safe to log.
    std::size_t secretBytes() const noexcept { return secret_.size(); }

private:
    std::string secret_;
    Clock       clock_;
};

} // namespace fh::sim::auth
