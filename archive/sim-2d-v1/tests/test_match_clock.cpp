// footballhome sim - MatchClock tests

#include "match/MatchClock.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

using fh::sim::TickNum;
using fh::sim::match::MatchClock;
using fh::sim::match::RealtimeClock;
using fh::sim::math::Fixed64;

FH_TEST(default_hz_is_20) {
    RealtimeClock c;
    FH_EXPECT_EQ(c.hz(), 20u);
    FH_EXPECT_EQ(c.dt(), Fixed64::fromFraction(1, 20));
    FH_EXPECT(c.shouldTick());
}

FH_TEST(zero_hz_is_clamped_to_one) {
    RealtimeClock c(0);
    FH_EXPECT_EQ(c.hz(), 1u);
    FH_EXPECT_EQ(c.dt(), Fixed64::fromInt(1));
}

FH_TEST(advance_increments_tick_and_elapsed) {
    RealtimeClock c(20);
    FH_EXPECT_EQ(c.current(), TickNum{0});
    FH_EXPECT_EQ(c.elapsedSeconds(), Fixed64::zero());
    c.advance();
    FH_EXPECT_EQ(c.current(), TickNum{1});
    FH_EXPECT_EQ(c.elapsedSeconds(), c.dt());
    for (int i = 0; i < 19; ++i) c.advance();   // total 20 ticks
    FH_EXPECT_EQ(c.current(), TickNum{20});
    // 20 * (1/20) ≈ 1 s (subject to fixed-point rounding)
    FH_EXPECT_EQ(c.elapsedSeconds(), Fixed64::fromInt(20) * c.dt());
}

FH_TEST_MAIN()
