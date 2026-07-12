// footballhome sim - Canonical match snapshot hash
//
// Deterministic byte-form + FNV-1a-64 of a Match snapshot. Used by:
//   * `test_determinism` — asserts a golden hash for known scenarios
//     (proves refactors don't drift the model).
//   * `main.cpp` shutdown path — writes the 8-byte hash to
//     `sim_matches.result` and (via a match_end event) to
//     `sim_match_events.payload` so `fh-sim-replay` can verify byte
//     equality without a per-tick snapshot log (§16.6, §22.14).
//
// The dump format is not a public wire protocol — it's an internal
// canonical form. Changes to it are behaviour-preserving iff the FNV
// hash is stable for existing scenarios; the determinism golden
// hashes are the anchor.
//
// Format (matches what test_determinism used inline before this file
// existed — extracted here so hash values remain identical):
//
//   tick=<u32> time_ms=<u32> count=<size_t>\n
//   slot=<u16> eid=<u32> motion=<u8> flags=<hex4> pos=(0x<hex16>,0x<hex16>,0x<hex16>) vel=(...) h=0x<hex16>\n
//   ...
//
// Endianness: FNV consumes the ASCII bytes of the dump directly, so
// host endianness doesn't affect the hash. Fixed64 raw bits are
// serialized via memcpy → uint64 → lowercase hex, so bit-exact and
// portable.
//
// See DESIGN.md §22.14 (canonical hash) and §16.6 (replay verification).

#pragma once

#include "match/Match.hpp"

#include <array>
#include <cstddef>
#include <cstdint>
#include <string>
#include <string_view>

namespace fh::sim::match {

// FNV-1a-64 constants (RFC-compatible; identical across hosts).
inline constexpr std::uint64_t kFnvOffsetBasis64 = 0xcbf29ce484222325ULL;
inline constexpr std::uint64_t kFnvPrime64       = 0x100000001b3ULL;

// FNV-1a-64 over an arbitrary byte range.
std::uint64_t fnv1a64(std::string_view bytes) noexcept;

// Serialize `snap` to the canonical ASCII dump format documented above.
std::string canonicalDump(const Snapshot& snap);

// One-shot convenience: dump `match.snapshot()` and FNV-hash the result.
std::uint64_t canonicalMatchHash(const Match& match);

// Big-endian 8-byte encoding of the FNV-1a-64 hash. This is the exact
// byte form written to `sim_matches.result` and to the `match_end`
// event payload; keeping it in one place means the write path and the
// replay-verifier can never disagree.
std::array<std::byte, 8> hashToBytesBE(std::uint64_t hash) noexcept;

} // namespace fh::sim::match
