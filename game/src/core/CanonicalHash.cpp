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
        mix(h, static_cast<std::uint64_t>(p.recovery_ticks));
        mix(h, static_cast<std::uint64_t>(p.dive_ticks));
        const Body& body = world.body(i);   // G4.52: his own locomotion
        mixFixed(h, body.tau());
        mixFixed(h, body.brake());
        mixFixed(h, body.brakeTau());
        mixFixed(h, body.turn());
        mixFixed(h, body.dribble());
        mixFixed(h, body.diveSpeed());
        mixFixed(h, body.side());
        mixFixed(h, body.back());
        mixFixed(h, body.yaw());
        mixFixed(h, body.reaction());
        mixFixed(h, p.max_speed);
    }
    // The officials (G4.88): where they stand decides offside calls.
    for (int i = 0; i < kOfficialCount; ++i) {
        const OfficialState& o = world.officials().official(i);
        mixFixed(h, o.pos.x);
        mixFixed(h, o.pos.y);
        mixFixed(h, o.vel.x);
        mixFixed(h, o.vel.y);
    }
    // Ball joined the state surface in G1.1 (golden re-locked then, once).
    mixFixed(h, world.ballFlight().k());   // G4.87: the air it flies through
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
    // The dead ball (G5.2).
    mix(h, static_cast<std::uint64_t>(world.restartKind()));
    mix(h, world.restartReadyTick());
    mixFixed(h, world.restartSpot().x);
    mixFixed(h, world.restartSpot().y);
    mix(h, world.outStage());
    mix(h, world.offsideMask());
    mix(h, world.offsideTeam());
    mix(h, world.lastLosingTeam());
    mix(h, world.turnoverTick());
    // The match seed and every player's skill (G5.23) drive evolution.
    mix(h, world.matchSeed());
    if (world.controlUntilTick() != 0) mix(h, world.controlUntilTick());   // G4.92
    for (SlotIndex s = 0; s < world.playerCount(); ++s) {
        const PlayerSkill& k = world.skillOf(s);
        for (const std::int32_t v : {k.perception_delay_ticks, k.kick_angle_err_deg, k.kick_power_err_pct,
                                     k.shot_angle_err_deg, k.shot_power_err_pct, k.control_speed_mps,
                                     k.tackle_success_pct, k.keeper_fumble_pct, k.kick_range_m,
                                     k.intercept_control_pct, k.control_settle_ms, k.control_per_mps_ms})
            mix(h, static_cast<std::uint64_t>(static_cast<std::int64_t>(v)));
    }
    return h;
}

}  // namespace fh::game::core
