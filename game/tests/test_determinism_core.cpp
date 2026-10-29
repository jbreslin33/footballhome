// game/tests/test_determinism_core.cpp
//
// First v2 determinism golden: 4 players driven by seeded-RNG intents for
// 400 ticks must hash to the locked value, on every architecture, forever.
// If a slice legitimately changes the state surface or integration math, it
// re-locks this constant ONCE, in the same commit, with a note here.

#include "test_harness.hpp"
#include "core/CanonicalHash.hpp"
#include "core/World.hpp"
#include "math/RngDet.hpp"

#include <cstdio>

using fh::game::core::MoveIntent;
using fh::game::core::World;
using fh::game::core::canonicalHash;
using fh::game::math::Fixed64;
using fh::game::math::RngDet;
using fh::game::math::Vec2;

namespace {

// Golden history (re-locked ONCE per deliberate state-surface change):
//   G0.2 2026-10-21 initial lock          0xba2dc29b0b1bbb1a
//   G1.1 2026-10-21 ball + facing joined  0x4b302451cf0e16e8
//   G2   2026-10-21 bounds + teams + steal 0x4ed209ee39dfa0f7
//   G3   2026-10-21 restarts + score/clock  0xfa9bf89e7f1477e9
//   G4.3 2026-10-21 level config in hash    0x2cad88c349759809
//   G4.4 2026-10-21 keepers+touch+swarm cfg 0x7fe31d46df486a49
//   G4.5 2026-10-21 player collisions       0x423841cf3a6eac06
//   G4.6 2026-10-21 tackles + recovery      0x997a2b004b2d98c6
//   G4.8 2026-10-21 offside + shot error    0x2f7a4328ec4cc0b9
//   G4.11 2026-10-21 graded + transitions   0x66874b880508cbe6
//   G4.51 2026-10-24 locomotion law + dive  0x19531f520b02f94f
//   G4.52 2026-10-24 per-player bodies      0x01a4b675f63d88f3
//   G4.53 2026-10-24 facing + gaits         0xf4d9c32e33211d89
//   G4.54 2026-10-24 side-on run gait       0x8265738e898a13f9
//   G4.80 2026-10-27 braking on brake_tau   0xcc37dec56712afa5
//   G4.85 2026-10-29 reaction in the body   0x86e09a1d63a55e25
//   G4.87 2026-10-29 air drag (BallFlight)  0xbfe63c836cfc5293
//   G4.88 2026-10-29 officials in the state (on G4.87) 0xb5e960d175a84ed0
//   G4.90 2026-10-29 assistant shadows level 0x6428149331d5d8b1
constexpr std::uint64_t kGolden400TicksSeed42 = 0x6428149331d5d8b1ULL;

std::uint64_t scriptedRun() {
    World w{4, Fixed64::fromInt(6), Fixed64::fromInt(52), Fixed64::fromInt(34)};
    RngDet rng{42};
    for (int t = 0; t < 400; ++t) {
        for (std::uint8_t slot = 0; slot < 4; ++slot) {
            MoveIntent intent;
            intent.move = Vec2{
                rng.nextRange(-Fixed64::one(), Fixed64::one()),
                rng.nextRange(-Fixed64::one(), Fixed64::one())};
            w.setIntent(slot, intent);
        }
        w.tick();
    }
    return canonicalHash(w);
}

}  // namespace

FH_TEST(determinism_two_runs_identical) {
    FH_EXPECT_EQ(scriptedRun(), scriptedRun());
}

FH_TEST(determinism_golden_400_ticks_seed_42) {
    const std::uint64_t h = scriptedRun();
    std::printf("canonical hash: 0x%016llx\n",
                static_cast<unsigned long long>(h));
    FH_EXPECT_EQ(h, kGolden400TicksSeed42);
}

FH_TEST_MAIN()
