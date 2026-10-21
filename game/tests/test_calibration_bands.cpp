// game/tests/test_calibration_bands.cpp
//
// THE CI GATE G4 PROMISED (DESIGN.md §8, pillar 5): realism assertion
// bands over headless AI-vs-AI matches — the build fails if the sim goes
// arcadey (or airtight) again. The G4.11-era regression this exists to
// catch: the ladder INVERTED (world 30, pro 37 goals/game vs u10 30)
// and nobody noticed for three slices because only goldens gated.
//
// Bands are deliberately WIDE (a 4-match sample of a goals process is
// noisy): they assert the SHAPE of the ladder — youth chaos scores an
// order of magnitude more than world class, the middle sits between —
// not the exact tuning. Reference 12-match ladder at lock time
// (2026-10-21): u10 12.7 / u14 14.7 / amateur 9.1 / semipro 2.6 /
// pro 2.8 / world 2.2 / perfect 0.8 goals/game.
//
// Runtime: 12 matches x 90 min at free-run ≈ 25 s — the slowest test in
// the suite, and worth every tick.

#include "test_harness.hpp"

#include "ai/Brain.hpp"
#include "core/Levels.hpp"
#include "core/World.hpp"

using namespace fh::game;
using math::Fixed64;

namespace {

// One 90-minute 11v11 mirror at `band`, returning total goals.
// Mirrors calibrate_main's runner (the harness is the product here).
int mirrorGoals(const char* band, std::uint64_t seed) {
    constexpr std::uint8_t players = 22;
    core::World world{players, Fixed64::fromInt(6),
                      Fixed64::fromFraction(105, 2), Fixed64::fromInt(34)};
    ai::Brain brain{ai::TeamSetup::splitHalves(players),
                    Fixed64::fromFraction(105, 2), Fixed64::fromInt(34)};
    const auto lp = core::levelParams(band);
    world.setLevel(0, lp);
    world.setLevel(1, lp);
    world.setMatchSeed(seed);
    brain.setLevels(lp, lp, seed);

    const std::uint8_t per_team = players / 2;
    for (std::uint8_t i = 0; i < players; ++i) {
        const bool home = i < per_team;
        const std::uint8_t k = home ? i : i - per_team;
        const Fixed64 y =
            Fixed64::fromInt(-25) +
            Fixed64::fromInt(50) * Fixed64::fromFraction(k, per_team - 1);
        world.placePlayer(i,
                          math::Vec3{Fixed64::fromInt(home ? -15 : 15), y,
                                     Fixed64::zero()},
                          math::Vec2{home ? Fixed64::one() : -Fixed64::one(),
                                     Fixed64::zero()});
        world.setTeam(i, home ? 0 : 1);
        world.setKeeper(i, ai::builtinFormation(per_team).positions[k].keeper);
    }

    int goals = 0;
    const long ticks = 90L * 60 * core::kTickRate;
    for (long t = 0; t < ticks; ++t) {
        for (std::uint8_t s = 0; s < players; ++s) {
            const ai::Orders o = brain.ordersFor(s, world);
            world.setIntent(s, o.move);
            if (o.action != core::Action::None) world.setAction(s, o.action);
        }
        for (const core::MatchEvent& e : world.tick())
            if (e.type == core::MatchEventType::Goal) ++goals;
    }
    return goals;
}

double avgGoals(const char* band) {
    int total = 0;
    for (std::uint64_t m = 1; m <= 4; ++m) total += mirrorGoals(band, m);
    const double avg = total / 4.0;
    std::printf("    %s: %.1f goals/game\n", band, avg);
    return avg;
}

}  // namespace

FH_TEST(ladder_shape_holds) {
    const double u10 = avgGoals("u10");
    const double amateur = avgGoals("amateur");
    const double world = avgGoals("world");

    // Per-band sanity ranges (wide on purpose — shape, not tuning).
    FH_EXPECT(u10 >= 6.0 && u10 <= 25.0);
    FH_EXPECT(amateur >= 4.0 && amateur <= 16.0);
    FH_EXPECT(world >= 0.5 && world <= 6.0);

    // The ladder's shape: chaos >> Sunday league > world class.
    FH_EXPECT(u10 > amateur);
    FH_EXPECT(amateur > world);
    FH_EXPECT(u10 >= world * 2.0);
}

FH_TEST_MAIN()
