// game/src/core/CanonicalHash.cpp

#include "core/CanonicalHash.hpp"

namespace fh::game::core {

namespace {

constexpr std::uint64_t kFnvOffset = 14695981039346656037ULL;
constexpr std::uint64_t kFnvPrime  = 1099511628211ULL;

void mix(std::uint64_t& h, std::uint64_t v) {
    // FNV-1a, one byte at a time, little-endian byte order of v. Byte-wise
    // feeding keeps the hash identical across architectures regardless of
    // host endianness.
    for (int i = 0; i < 8; ++i) {
        h ^= (v >> (i * 8)) & 0xFFu;
        h *= kFnvPrime;
    }
}

void mixFixed(std::uint64_t& h, math::Fixed64 f) {
    mix(h, static_cast<std::uint64_t>(f.raw));
}

}  // namespace

std::uint64_t canonicalHash(const World& world) {
    std::uint64_t h = kFnvOffset;
    mix(h, world.tickCount());
    mix(h, world.playerCount());
    for (SlotIndex i = 0; i < world.playerCount(); ++i) {
        const PlayerState& p = world.player(i);
        mixFixed(h, p.pos.x);
        mixFixed(h, p.pos.y);
        mixFixed(h, p.pos.z);
        mixFixed(h, p.vel.x);
        mixFixed(h, p.vel.y);
        mixFixed(h, p.vel.z);
        mixFixed(h, p.max_speed);
    }
    return h;
}

}  // namespace fh::game::core
