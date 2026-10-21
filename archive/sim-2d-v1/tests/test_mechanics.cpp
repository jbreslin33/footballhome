// footballhome sim - Mechanics tests

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
using fh::sim::math::fx_abs;
using fh::sim::math::Vec3;

namespace {

MechanicsParams m0params() { return MechanicsParams::fromPhysical(defaultPhysical()); }

// Convenience: assert |a-b| ≤ eps for Fixed64.
bool fx_close(Fixed64 a, Fixed64 b, Fixed64 eps) {
    const Fixed64 d = fx_abs(a - b);
    return d <= eps;
}

} // namespace

FH_TEST(idle_intent_yields_idle) {
    Intent in;   // zero direction, no flags
    EntityState st{};
    const auto out = applyIntent(in, st, Fixed64::one(),
                                 m0params(), Fixed64::fromFraction(1, 20));
    FH_EXPECT(out.new_motion == MotionState::Idle);
    FH_EXPECT_EQ(out.new_velocity.x, Fixed64::zero());
    FH_EXPECT_EQ(out.new_velocity.y, Fixed64::zero());
}

FH_TEST(walk_intent_selects_walk_tier) {
    Intent in;
    in.desired_direction = Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    in.wants_walk = true;

    EntityState st{};   // starts at rest
    const auto p  = m0params();
    const auto dt = Fixed64::fromFraction(1, 20);
    const auto out = applyIntent(in, st, Fixed64::one(), p, dt);
    FH_EXPECT(out.new_motion == MotionState::Walk);
    // First tick: velocity clamped to accel*dt (starting from rest).
    // accel * dt = 6 * 1/20 = 0.3 m/s.
    const Fixed64 eps = Fixed64::fromFraction(1, 1000);
    FH_EXPECT(fx_close(out.new_velocity.x, p.acceleration * dt, eps));
}

FH_TEST(sprint_downgrades_to_jog_when_stamina_empty) {
    Intent in;
    in.desired_direction = Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    in.wants_sprint = true;

    EntityState st{};
    const auto out = applyIntent(in, st, Fixed64::zero(),   // no stamina
                                 m0params(), Fixed64::fromFraction(1, 20));
    FH_EXPECT(out.new_motion == MotionState::Jog);
}

FH_TEST(sprint_drains_stamina) {
    Intent in;
    in.desired_direction = Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    in.wants_sprint = true;

    // Force a sprint-level speed so drain kicks in.
    EntityState st{};
    st.velocity = Vec3{Fixed64::fromInt(7), Fixed64::zero(), Fixed64::zero()};

    const auto p  = m0params();
    const auto dt = Fixed64::fromFraction(1, 20);
    const auto out = applyIntent(in, st, p.stamina_max, p, dt);
    FH_EXPECT(out.new_motion == MotionState::Sprint);
    // stamina = 1 - drain*dt = 1 - 0.10 * (1/20) = 0.995
    const Fixed64 expected = p.stamina_max - p.stamina_drain_rate * dt;
    const Fixed64 eps      = Fixed64::fromFraction(1, 10000);
    FH_EXPECT(fx_close(out.new_stamina, expected, eps));
}

FH_TEST(idle_recovers_stamina) {
    Intent in;   // no direction → Idle
    EntityState st{};
    const auto p  = m0params();
    const auto dt = Fixed64::fromFraction(1, 20);
    const Fixed64 start_stam = Fixed64::fromFraction(1, 2);
    const auto out = applyIntent(in, st, start_stam, p, dt);
    // stamina = 0.5 + recovery*dt = 0.5 + 0.05 * (1/20) = 0.5025
    const Fixed64 expected = start_stam + p.stamina_recovery_rate * dt;
    const Fixed64 eps      = Fixed64::fromFraction(1, 10000);
    FH_EXPECT(fx_close(out.new_stamina, expected, eps));
}

FH_TEST(stamina_clamped_to_max) {
    Intent in;   // Idle → recovery attempt
    EntityState st{};
    const auto p   = m0params();
    const auto dt  = Fixed64::fromFraction(1, 20);
    // Start at max already. Recovery must not exceed cap.
    const auto out = applyIntent(in, st, p.stamina_max, p, dt);
    FH_EXPECT_EQ(out.new_stamina, p.stamina_max);
}

FH_TEST(stamina_clamped_to_zero) {
    Intent in;
    in.desired_direction = Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    in.wants_sprint = true;

    EntityState st{};
    st.velocity = Vec3{Fixed64::fromInt(7), Fixed64::zero(), Fixed64::zero()};

    const auto p  = m0params();
    const auto dt = Fixed64::fromInt(10);   // huge dt to drive stamina below 0
    // Note: stamina check happens BEFORE motion selection is committed;
    // starting with a tiny positive stamina lets sprint be selected once.
    const Fixed64 tiny = Fixed64::fromFraction(1, 1000);
    const auto out = applyIntent(in, st, tiny, p, dt);
    FH_EXPECT_EQ(out.new_stamina, Fixed64::zero());
}

FH_TEST(velocity_change_clamped_by_acceleration) {
    // Ask for jog from a standing start; over one 1/20s tick velocity can
    // grow by at most accel * dt = 6 * 1/20 = 0.3, not the full 4.5.
    Intent in;
    in.desired_direction = Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};

    EntityState st{};
    const auto p  = m0params();
    const auto dt = Fixed64::fromFraction(1, 20);
    const auto out = applyIntent(in, st, p.stamina_max, p, dt);
    // Speed should equal accel*dt (== 0.3 m/s), NOT jog target 4.5.
    const Fixed64 speed = out.new_velocity.length();
    const Fixed64 eps   = Fixed64::fromFraction(1, 1000);
    FH_EXPECT(fx_close(speed, p.acceleration * dt, eps));
}

FH_TEST(heading_change_clamped_by_agility) {
    // Facing east (heading=0), asked to run north. One tick of 1/20s at
    // agility 6 rad/s means at most 0.3 rad of rotation.
    Intent in;
    in.desired_direction = Vec3{Fixed64::zero(), Fixed64::one(), Fixed64::zero()};

    EntityState st{};   // heading=0
    const auto p  = m0params();
    const auto dt = Fixed64::fromFraction(1, 20);
    const auto out = applyIntent(in, st, p.stamina_max, p, dt);
    // Delta should be exactly agility*dt in the positive direction (toward π/2).
    const Fixed64 expected_delta = p.agility * dt;
    const Fixed64 eps            = Fixed64::fromFraction(1, 1000);
    FH_EXPECT(fx_close(out.new_heading, expected_delta, eps));
}

FH_TEST_MAIN()
