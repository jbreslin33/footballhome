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
constexpr std::uint64_t kGolden400TicksSeed42 = 0x4b302451cf0e16e8ULL;

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
