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
        mixFixed(h, p.face.x);   // facing drives kicks — authoritative state
        mixFixed(h, p.face.y);
        mix(h, p.team);
        mix(h, world.isKeeper(i) ? 1u : 0u);
        mixFixed(h, p.max_speed);
    }
    // Ball joined the state surface in G1.1 (golden re-locked then, once).
    const BallState& b = world.ball();
    mixFixed(h, b.pos.x); mixFixed(h, b.pos.y); mixFixed(h, b.pos.z);
    mixFixed(h, b.vel.x); mixFixed(h, b.vel.y); mixFixed(h, b.vel.z);
    mix(h, b.owner ? *b.owner : 0xFFu);
    mix(h, static_cast<std::uint64_t>(b.kick_alive));
    mix(h, b.last_kicker);
    mix(h, static_cast<std::uint64_t>(b.kicker_lockout));
    mix(h, static_cast<std::uint64_t>(b.contest_ticks));
    // Match structure (G3.3).
    mix(h, world.score(0));
    mix(h, world.score(1));
    mix(h, world.period());
    mix(h, world.matchClockTicks());
    mix(h, world.restartTeam());
    // Skill-noise config (G4.3): drives evolution, so it is part of the
    // identity of a run. Zero everywhere for pre-G4.3 goldens.
    mix(h, world.matchSeed());
    for (int t = 0; t < 2; ++t) {
        const LevelParams& lv = world.level(t);
        mix(h, static_cast<std::uint64_t>(lv.perception_delay_ticks));
        mix(h, static_cast<std::uint64_t>(lv.kick_angle_err_deg));
        mix(h, static_cast<std::uint64_t>(lv.kick_power_err_pct));
        mix(h, static_cast<std::uint64_t>(lv.decision_jitter_pct));
        mix(h, static_cast<std::uint64_t>(lv.control_speed_mps));
        mix(h, static_cast<std::uint64_t>(lv.swarm_pct));
    }
    return h;
}

}  // namespace fh::game::core
