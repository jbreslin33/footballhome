// game/tests/test_phases.cpp — G5.21 (DESIGN §8.119): the team state machine
// over the phases of play. Who has the ball decides each team's phase; a
// change of side has to hold min_dwell before it counts; a transition
// settles after transition_s; a dead ball is a set piece for one side.
#include "test_harness.hpp"
#include "ai/Brain.hpp"
#include "core/World.hpp"

using namespace fh::game;
using ai::Phase;
using math::Fixed64;
using math::Vec2;
using math::Vec3;

namespace {
const Fixed64 kHX = Fixed64::fromFraction(105, 2);
const Fixed64 kHY = Fixed64::fromInt(34);

struct Rig {
    core::World world;
    ai::Brain brain;
    Rig() : world{22, Fixed64::fromInt(6), kHX, kHY}, brain{ai::TeamSetup::splitHalves(22), kHX, kHY} {
        for (std::uint8_t i = 0; i < 22; ++i) {
            const bool home = i < 11;
            world.placePlayer(i, Vec3{Fixed64::fromInt(home ? -10 : 10), Fixed64::fromInt((i % 11) * 4 - 20), Fixed64::zero()},
                              Vec2{home ? Fixed64::one() : -Fixed64::one(), Fixed64::zero()});
            world.setTeam(i, home ? 0 : 1);
        }
    }
    void step(int n) {
        for (int t = 0; t < n; ++t) { brain.think(world); world.tick(); }
        brain.think(world);
    }
};
}  // namespace

FH_TEST(won_ball_is_a_transition_that_settles) {
    Rig r;
    r.world.giveBall(5);
    r.step(1);
    FH_EXPECT(r.brain.phaseOf(0) == Phase::AttackingTransition);
    FH_EXPECT(r.brain.phaseOf(1) == Phase::DefensiveTransition);
    r.step(200);   // past the 6 s default
    FH_EXPECT(r.world.ball().owner && *r.world.ball().owner == 5 && r.world.restartTeam() == 0xFF);
    {
        FH_EXPECT(r.brain.phaseOf(0) == Phase::InPossession);
        FH_EXPECT(r.brain.phaseOf(1) == Phase::DefendingBlock);
    }
}

FH_TEST(a_change_of_side_must_hold_min_dwell) {
    Rig r;
    r.world.giveBall(5);
    r.step(200);
    r.world.giveBall(16);
    r.step(2);   // under the 0.3 s dwell: not yet theirs
    FH_EXPECT(r.brain.phaseOf(0) != Phase::DefensiveTransition);
    r.step(12);
    FH_EXPECT(r.world.ball().owner && *r.world.ball().owner == 16 && r.world.restartTeam() == 0xFF);
    {
        FH_EXPECT(r.brain.phaseOf(0) == Phase::DefensiveTransition);
        FH_EXPECT(r.brain.phaseOf(1) == Phase::AttackingTransition);
    }
}

FH_TEST(read_ball_side_follows_owner_then_last_touch) {
    Rig r;
    r.world.giveBall(16);
    const auto b = ai::readBallSide(r.world, ai::TeamSetup::splitHalves(22).team_of_slot);
    FH_EXPECT_EQ(b.side, 1);
    FH_EXPECT(!b.dead);
}

FH_TEST_MAIN()
