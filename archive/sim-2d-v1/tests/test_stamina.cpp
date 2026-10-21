// footballhome sim - Stamina drain/recovery over many ticks

#include "match/Mechanics.hpp"
#include "controller/Intent.hpp"
#include "common/EntityState.hpp"
#include "common/M0Attributes.hpp"
#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"
#include "math/Vec3.hpp"
#include "test_harness.hpp"

using fh::sim::EntityState;
using fh::sim::MotionState;
using fh::sim::controller::Intent;
using fh::sim::m0::defaultPhysical;
using fh::sim::match::applyIntent;
using fh::sim::match::MechanicsParams;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;

FH_TEST(sprint_drains_over_10_seconds) {
    // 10 s of continuous sprint at 20 Hz = 200 ticks.
    // drain 0.10/s → total 1.0. Starting at 1.0 → ends clamped at 0.
    const auto p  = MechanicsParams::fromPhysical(defaultPhysical());
    const auto dt = Fixed64::fromFraction(1, 20);

    Intent in;
    in.desired_direction = Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    in.wants_sprint = true;

    EntityState st{};
    // Cheat velocity to sprint tier so drain triggers immediately.
    st.velocity = Vec3{Fixed64::fromInt(7), Fixed64::zero(), Fixed64::zero()};

    Fixed64 stamina = p.stamina_max;
    // 250 ticks (12.5 s) — enough to guarantee we cross zero even after
    // the per-tick truncation shaves a few raw units off each subtraction.
    for (int i = 0; i < 250; ++i) {
        const auto out = applyIntent(in, st, stamina, p, dt);
        stamina = out.new_stamina;
        st.velocity = out.new_velocity;
    }
    FH_EXPECT_EQ(stamina, Fixed64::zero());
}

FH_TEST(recovery_climbs_back_over_20_seconds) {
    // Idle, 20 s at 0.05/s = 1.0 gained. Starting at 0 → ends at max.
    const auto p  = MechanicsParams::fromPhysical(defaultPhysical());
    const auto dt = Fixed64::fromFraction(1, 20);

    Intent in;   // Idle
    EntityState st{};

    Fixed64 stamina = Fixed64::zero();
    // 500 ticks (25 s) — enough to overshoot max and hit the clamp even
    // with per-tick truncation.
    for (int i = 0; i < 500; ++i) {
        const auto out = applyIntent(in, st, stamina, p, dt);
        stamina = out.new_stamina;
    }
    FH_EXPECT_EQ(stamina, p.stamina_max);
}

FH_TEST(jog_leaves_stamina_untouched) {
    const auto p  = MechanicsParams::fromPhysical(defaultPhysical());
    const auto dt = Fixed64::fromFraction(1, 20);

    Intent in;
    in.desired_direction = Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    // no wants_sprint, no wants_walk → jog

    EntityState st{};
    const Fixed64 start = Fixed64::fromFraction(1, 2);
    Fixed64 stamina = start;
    for (int i = 0; i < 60; ++i) {
        const auto out = applyIntent(in, st, stamina, p, dt);
        FH_EXPECT(out.new_motion == MotionState::Jog);
        stamina = out.new_stamina;
        st.velocity = out.new_velocity;
    }
    FH_EXPECT_EQ(stamina, start);
}

FH_TEST_MAIN()
