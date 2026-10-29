// game/tests/test_officials.cpp — G4.88: the assistant judges offside from
// where he stands [Oudejans et al. 2000: beyond the line, a far-side attacker
// level with the defender projects ahead of him].

#include "test_harness.hpp"
#include "core/World.hpp"

using namespace fh::game;
using fh::game::math::Fixed64;
using fh::game::math::Vec2;
using fh::game::math::Vec3;

namespace {
Vec3 at(int x, int y) { return Vec3{Fixed64::fromInt(x), Fixed64::fromInt(y), Fixed64::zero()}; }

// Team 0 attacks +x: kicker on the ball at x 10, an attacker LEVEL with the
// second-last defender (x 30) on the far side of the pitch from assistant 1
// (+y touchline); their keeper deeper at x 50.
core::World pitch() {
    core::World w{4, Fixed64::fromInt(7), Fixed64::fromInt(52), Fixed64::fromInt(34), 0};
    const Vec2 f{Fixed64::one(), Fixed64::zero()};
    w.setTeam(0, 0); w.placePlayer(0, at(10, 0), f);     // kicker
    w.setTeam(1, 0); w.placePlayer(1, at(30, -25), f);   // attacker, far side
    w.setTeam(2, 1); w.placePlayer(2, at(30, 20), f);    // second-last defender, near side
    w.setTeam(3, 1); w.placePlayer(3, at(50, 0), f);     // keeper
    core::BallState b;
    b.pos = Vec3{Fixed64::fromFraction(105, 10), Fixed64::zero(), Fixed64::zero()};
    w.placeBall(b);
    core::ModelParams p;
    for (const char* k : {"official.assistant.noise_m_at0", "official.assistant.noise_m_at50",
                          "official.assistant.noise_m_at100", "official.assistant.flash_lag_s"})
        p.setMilli(k, 0);
    w.officials().configure(p);
    return w;
}
}  // namespace

FH_TEST(officials_truth_is_the_law) {
    const core::World w = pitch();
    // Level is onside (Law 11.1).
    FH_EXPECT_EQ(core::Officials::offsidePositionTruth(w, 0), 0u);
}

FH_TEST(officials_level_assistant_sees_it_true) {
    core::World w = pitch();
    w.officials().placeOfficial(core::OfficialRole::Assistant1, at(30, 35));
    const core::OffsideCall c = w.officials().judgeOffsidePosition(w, 0);
    FH_EXPECT_EQ(c.assistant, 1);
    FH_EXPECT_EQ(c.called, 0u);
    FH_EXPECT(c.off_line_m == Fixed64::zero());
}

FH_TEST(officials_beyond_the_line_flags_the_far_man) {
    core::World w = pitch();
    w.officials().placeOfficial(core::OfficialRole::Assistant1, at(34, 35));
    const core::OffsideCall c = w.officials().judgeOffsidePosition(w, 0);
    FH_EXPECT_EQ(c.called, 1u << 1);      // the wrong flag
    FH_EXPECT_EQ(c.truth, 0u);
    FH_EXPECT(c.off_line_m == Fixed64::fromInt(4));
}

FH_TEST_MAIN()
