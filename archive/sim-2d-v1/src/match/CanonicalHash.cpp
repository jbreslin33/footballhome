// footballhome sim - Canonical match snapshot hash (impl).
//
// See CanonicalHash.hpp for the format contract. The exact byte layout
// here is anchored by the golden hashes in test_determinism.cpp — any
// change to canonicalDump() that alters output for the wander-200 or
// human-sprint-400 scenarios is a determinism break and must be
// reviewed as such.

#include "match/CanonicalHash.hpp"

#include "math/Fixed64.hpp"

#include <cstdio>

namespace fh::sim::match {

std::uint64_t fnv1a64(std::string_view bytes) noexcept
{
    std::uint64_t h = kFnvOffsetBasis64;
    for (const char c : bytes) {
        h ^= static_cast<std::uint8_t>(c);
        h *= kFnvPrime64;
    }
    return h;
}

namespace {

// Serialize one Fixed64 as fixed-width lowercase hex of its raw int64
// bits. (Reinterpret via memcpy — bit-exact and portable.)
void appendHex(std::string& out, math::Fixed64 f)
{
    char buf[19];   // "0x" + 16 hex + NUL
    std::snprintf(buf, sizeof(buf), "0x%016lx",
                  static_cast<unsigned long>(static_cast<std::uint64_t>(f.raw)));
    out.append(buf);
}

} // namespace

std::string canonicalDump(const Snapshot& snap)
{
    std::string out;
    out.reserve(snap.entities.size() * 128);

    char header[64];
    std::snprintf(header, sizeof(header),
                  "tick=%u time_ms=%u count=%zu\n",
                  static_cast<unsigned>(snap.tick),
                  static_cast<unsigned>(snap.match_time_ms),
                  snap.entities.size());
    out.append(header);

    for (const auto& e : snap.entities) {
        char prefix[64];
        std::snprintf(prefix, sizeof(prefix),
                      "slot=%u eid=%u motion=%u flags=%04x ",
                      static_cast<unsigned>(e.state.slot_id),
                      static_cast<unsigned>(e.state.id),
                      static_cast<unsigned>(e.state.motion),
                      static_cast<unsigned>(e.flags.toU16()));
        out.append(prefix);
        out.append("pos=("); appendHex(out, e.state.position.x);
        out.append(",");     appendHex(out, e.state.position.y);
        out.append(",");     appendHex(out, e.state.position.z);
        out.append(") vel=("); appendHex(out, e.state.velocity.x);
        out.append(",");       appendHex(out, e.state.velocity.y);
        out.append(",");       appendHex(out, e.state.velocity.z);
        out.append(") h=");    appendHex(out, e.state.heading);
        out.append("\n");
    }

    // Slice 16.6: append ball_owner ONLY when set, so scenarios that
    // never establish ownership (M0 wander, Slice 15.6 loose-ball
    // rolls) produce byte-identical dumps to their pre-Slice-16.6
    // form — their golden hashes remain valid. Any scenario where a
    // slot has actually claimed the ball emits a trailing line whose
    // presence + slot number are locked into the cross-arch hash.
    if (snap.ball_owner.has_value()) {
        char buf[48];
        std::snprintf(buf, sizeof(buf), "ball_owner=%u\n",
                      static_cast<unsigned>(*snap.ball_owner));
        out.append(buf);
    }
    return out;
}

std::uint64_t canonicalMatchHash(const Match& match)
{
    return fnv1a64(canonicalDump(match.snapshot()));
}

std::array<std::byte, 8> hashToBytesBE(std::uint64_t hash) noexcept
{
    std::array<std::byte, 8> out{};
    for (int i = 0; i < 8; ++i) {
        // Byte 0 = most-significant (network / big-endian order).
        out[static_cast<std::size_t>(i)] =
            static_cast<std::byte>((hash >> (56 - 8 * i)) & 0xffu);
    }
    return out;
}

} // namespace fh::sim::match
