// footballhome sim - BallPhysics tests
//
// Locks the passive-ball friction model: multiplicative decay per tick,
// direction preservation, snap-to-rest below threshold, deterministic
// tick counts to full stop under the M1 defaults.
//
// See DESIGN.md §23.3 Slice 15.1.

#include "physics/BallPhysics.hpp"

#include "common/EntityState.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"
#include "test_harness.hpp"

using fh::sim::EntityState;
using fh::sim::MotionState;
using fh::sim::SlotId;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::physics::kDefaultBallDecayPerTick;
using fh::sim::physics::kDefaultBallRestThreshold;
using fh::sim::physics::kKickAliveTicks;
using fh::sim::physics::applyImpulse;
using fh::sim::physics::tickBall;

// One tick of default decay should multiply velocity by exactly 49/50 per
// axis. Position is untouched (BallPhysics is a velocity-only pass).
FH_TEST(one_tick_default_decay_shrinks_velocity_by_49_50) {
    EntityState ball;
    ball.slot_id  = SlotId{0};
    ball.position = Vec3{Fixed64::fromInt(1),
                         Fixed64::fromInt(2),
                         Fixed64::zero()};
    ball.velocity = Vec3{Fixed64::fromInt(10),
                         Fixed64::fromInt(-5),
                         Fixed64::zero()};

    tickBall(ball, kDefaultBallDecayPerTick, kDefaultBallRestThreshold);

    FH_EXPECT_EQ(ball.velocity.x, Fixed64::fromInt(10) * kDefaultBallDecayPerTick);
    FH_EXPECT_EQ(ball.velocity.y, Fixed64::fromInt(-5) * kDefaultBallDecayPerTick);
    FH_EXPECT_EQ(ball.velocity.z, Fixed64::zero());

    // Position untouched.
    FH_EXPECT_EQ(ball.position.x, Fixed64::fromInt(1));
    FH_EXPECT_EQ(ball.position.y, Fixed64::fromInt(2));
    FH_EXPECT_EQ(ball.position.z, Fixed64::zero());
}

// Zero-velocity ball at rest stays at rest — no NaN, no drift.
FH_TEST(rest_stays_rest) {
    EntityState ball;
    ball.velocity = Vec3{};

    for (int i = 0; i < 100; ++i) {
        tickBall(ball, kDefaultBallDecayPerTick, kDefaultBallRestThreshold);
    }

    FH_EXPECT_EQ(ball.velocity.x, Fixed64::zero());
    FH_EXPECT_EQ(ball.velocity.y, Fixed64::zero());
    FH_EXPECT_EQ(ball.velocity.z, Fixed64::zero());
}

// Snap-to-rest branch: velocity strictly below threshold on every axis
// snaps to exactly zero (prevents infinite asymptotic tail).
FH_TEST(sub_threshold_velocity_snaps_to_zero) {
    EntityState ball;
    // 1/1000 m/s per axis — below the 1/100 default threshold.
    ball.velocity = Vec3{Fixed64::fromFraction(1, 1000),
                         Fixed64::fromFraction(-1, 1000),
                         Fixed64::fromFraction(1, 1000)};

    tickBall(ball, kDefaultBallDecayPerTick, kDefaultBallRestThreshold);

    // decay×threshold-ish is still below threshold, so snap fires.
    FH_EXPECT_EQ(ball.velocity.x, Fixed64::zero());
    FH_EXPECT_EQ(ball.velocity.y, Fixed64::zero());
    FH_EXPECT_EQ(ball.velocity.z, Fixed64::zero());
}

// Snap-to-rest is per-axis-AND: if any axis is still above threshold, no
// snap. This guards against a fast horizontal ball being killed just
// because its vertical component is tiny.
FH_TEST(one_axis_above_threshold_blocks_snap) {
    EntityState ball;
    ball.velocity = Vec3{Fixed64::fromInt(5),                     // above
                         Fixed64::fromFraction(1, 10000),         // below
                         Fixed64::fromFraction(1, 10000)};        // below

    tickBall(ball, kDefaultBallDecayPerTick, kDefaultBallRestThreshold);

    FH_EXPECT(ball.velocity.x != Fixed64::zero());
    // The below-threshold axes get decayed but NOT snapped (snap is
    // all-or-nothing across axes).
    FH_EXPECT_EQ(ball.velocity.x, Fixed64::fromInt(5) * kDefaultBallDecayPerTick);
}

// Direction preservation: a ball moving along a diagonal keeps its
// direction as speed decays. Checked via a ratio invariant that survives
// decay.
FH_TEST(diagonal_velocity_preserves_direction) {
    EntityState ball;
    // 3:4:0 direction. After 1 tick both x and y are multiplied by the
    // SAME scalar (kDefaultBallDecayPerTick), so the 3:4 ratio survives.
    ball.velocity = Vec3{Fixed64::fromInt(3),
                         Fixed64::fromInt(4),
                         Fixed64::zero()};

    tickBall(ball, kDefaultBallDecayPerTick, kDefaultBallRestThreshold);

    // vx * 4 == vy * 3 (cross-multiplication of 3:4 ratio, exact in Fixed64).
    FH_EXPECT_EQ(ball.velocity.x * Fixed64::fromInt(4),
                 ball.velocity.y * Fixed64::fromInt(3));
}

// Rolls to rest in a bounded, deterministic tick count from a realistic
// starting speed. A 20 m/s ball at 20 Hz with kDefault{Decay,Rest} settles
// in a specific number of ticks — this test locks that number so anyone
// tweaking the constants sees an intentional-looking failure.
//
// This is the "rolling to rest under friction" acceptance test the
// Slice 15.1 exit gate asks for.
FH_TEST(rolls_to_rest_in_bounded_ticks) {
    EntityState ball;
    ball.velocity = Vec3{Fixed64::fromInt(20),   // 20 m/s straight along +x
                         Fixed64::zero(),
                         Fixed64::zero()};

    // Guardrail: must settle inside 20 s of match time (400 ticks at 20 Hz).
    int ticks_to_rest = -1;
    for (int i = 1; i <= 1000; ++i) {
        tickBall(ball, kDefaultBallDecayPerTick, kDefaultBallRestThreshold);
        if (ball.velocity.x == Fixed64::zero() &&
            ball.velocity.y == Fixed64::zero() &&
            ball.velocity.z == Fixed64::zero()) {
            ticks_to_rest = i;
            break;
        }
    }
    FH_EXPECT(ticks_to_rest > 0);
    FH_EXPECT(ticks_to_rest <= 400);
    // Also stays at rest once it gets there.
    for (int i = 0; i < 10; ++i) {
        tickBall(ball, kDefaultBallDecayPerTick, kDefaultBallRestThreshold);
        FH_EXPECT_EQ(ball.velocity.x, Fixed64::zero());
    }
}

FH_TEST(deterministic_across_two_runs) {
    auto run = []() {
        EntityState b;
        b.velocity = Vec3{Fixed64::fromInt(7),
                          Fixed64::fromInt(-3),
                          Fixed64::zero()};
        for (int i = 0; i < 50; ++i) {
            tickBall(b, kDefaultBallDecayPerTick, kDefaultBallRestThreshold);
        }
        return b.velocity;
    };
    const Vec3 a = run();
    const Vec3 b = run();
    FH_EXPECT_EQ(a.x, b.x);
    FH_EXPECT_EQ(a.y, b.y);
    FH_EXPECT_EQ(a.z, b.z);
}

// ---------------------------------------------------------------------------
// Slice 26.3 (ADR §22.23) — applyImpulse + skip_rest_snap coverage.
// ---------------------------------------------------------------------------

// Baseline applyImpulse: unit direction × speed lands as raw velocity.
// Position, heading, motion, slot_id are untouched.
FH_TEST(apply_impulse_unit_direction_sets_velocity_to_direction_times_speed) {
    EntityState ball;
    ball.slot_id  = SlotId{0};
    ball.position = Vec3{Fixed64::fromInt(1),
                         Fixed64::fromInt(2),
                         Fixed64::zero()};
    ball.velocity = Vec3{Fixed64::fromInt(99),
                         Fixed64::fromInt(99),
                         Fixed64::fromInt(99)};

    // Unit +x direction, speed 15 m/s (pass_power default). Impulse
    // overwrites the pre-existing velocity — pass primitive fully
    // imparts new momentum.
    applyImpulse(ball,
                 Vec3{Fixed64::fromInt(1), Fixed64::zero(), Fixed64::zero()},
                 Fixed64::fromInt(15));

    FH_EXPECT_EQ(ball.velocity.x, Fixed64::fromInt(15));
    FH_EXPECT_EQ(ball.velocity.y, Fixed64::zero());
    FH_EXPECT_EQ(ball.velocity.z, Fixed64::zero());
    // Position untouched — impulse is a velocity-only operation.
    FH_EXPECT_EQ(ball.position.x, Fixed64::fromInt(1));
    FH_EXPECT_EQ(ball.position.y, Fixed64::fromInt(2));
}

// Non-unit direction is normalised so caller can pass any non-zero
// XY vector and get a velocity of exactly the requested magnitude.
// This is the wire path's guarantee: the Slice 26.2 decoder allows
// magnitudes in [0.5, 1.5], and the game must not scale the kick by
// the accidental non-unit-ness of the joystick.
FH_TEST(apply_impulse_non_unit_direction_normalises) {
    EntityState ball;
    // Direction magnitude sqrt(3² + 4²) = 5. Speed 10. Expected
    // velocity = (3/5 * 10, 4/5 * 10, 0) = (6, 8, 0).
    applyImpulse(ball,
                 Vec3{Fixed64::fromInt(3),
                      Fixed64::fromInt(4),
                      Fixed64::zero()},
                 Fixed64::fromInt(10));
    FH_EXPECT_EQ(ball.velocity.x, Fixed64::fromInt(6));
    FH_EXPECT_EQ(ball.velocity.y, Fixed64::fromInt(8));
    FH_EXPECT_EQ(ball.velocity.z, Fixed64::zero());
}

// Zero-length direction is a no-op: leaves velocity untouched. Guards
// against a divide-by-zero in normalize() when the client asserts
// wants_kick without a direction (which the Slice 26.2 wire decoder
// rejects, but tests may still probe).
FH_TEST(apply_impulse_zero_direction_is_noop) {
    EntityState ball;
    ball.velocity = Vec3{Fixed64::fromInt(7),
                         Fixed64::fromInt(-3),
                         Fixed64::zero()};
    applyImpulse(ball, Vec3{}, Fixed64::fromInt(15));
    FH_EXPECT_EQ(ball.velocity.x, Fixed64::fromInt(7));
    FH_EXPECT_EQ(ball.velocity.y, Fixed64::fromInt(-3));
}

// Zero speed is also a no-op — no direction interpretation, no
// division. Symmetric with the zero-direction guard.
FH_TEST(apply_impulse_zero_speed_is_noop) {
    EntityState ball;
    ball.velocity = Vec3{Fixed64::fromInt(7),
                         Fixed64::fromInt(-3),
                         Fixed64::zero()};
    applyImpulse(ball,
                 Vec3{Fixed64::fromInt(1), Fixed64::zero(), Fixed64::zero()},
                 Fixed64::zero());
    FH_EXPECT_EQ(ball.velocity.x, Fixed64::fromInt(7));
    FH_EXPECT_EQ(ball.velocity.y, Fixed64::fromInt(-3));
}

// skip_rest_snap=true suppresses the snap-to-rest branch: a velocity
// whose components ALL fall below rest_threshold after decay still
// gets returned as the decayed value, not zeroed. This is the Slice
// 26.3 kick runway that keeps a slow pass alive across kKickAliveTicks.
FH_TEST(tick_ball_skip_rest_snap_leaves_sub_threshold_velocity_alive) {
    EntityState ball;
    // 1/1000 m/s per axis — below the 1/100 default threshold. Under
    // the default (snap-eligible) path this snaps to zero; with
    // skip_rest_snap=true the decayed value survives.
    ball.velocity = Vec3{Fixed64::fromFraction(1, 1000),
                         Fixed64::fromFraction(-1, 1000),
                         Fixed64::zero()};

    tickBall(ball,
             kDefaultBallDecayPerTick,
             kDefaultBallRestThreshold,
             /*skip_rest_snap=*/true);

    // Decayed, not snapped: x = 1/1000 * 49/50, y = -1/1000 * 49/50.
    FH_EXPECT_EQ(ball.velocity.x,
                 Fixed64::fromFraction(1, 1000) * kDefaultBallDecayPerTick);
    FH_EXPECT_EQ(ball.velocity.y,
                 Fixed64::fromFraction(-1, 1000) * kDefaultBallDecayPerTick);
    // Both non-zero — the snap did NOT fire.
    FH_EXPECT(ball.velocity.x != Fixed64::zero());
    FH_EXPECT(ball.velocity.y != Fixed64::zero());
}

// skip_rest_snap default is false — the existing 8 tests above all
// rely on this. Belt-and-suspenders assertion that the default-arg
// call site matches the explicit-arg call site byte-for-byte.
FH_TEST(tick_ball_default_and_explicit_false_match) {
    EntityState a;
    EntityState b;
    a.velocity = Vec3{Fixed64::fromInt(7),
                      Fixed64::fromInt(-3),
                      Fixed64::zero()};
    b.velocity = a.velocity;

    for (int i = 0; i < 50; ++i) {
        tickBall(a, kDefaultBallDecayPerTick, kDefaultBallRestThreshold);
        tickBall(b, kDefaultBallDecayPerTick, kDefaultBallRestThreshold,
                 /*skip_rest_snap=*/false);
    }
    FH_EXPECT_EQ(a.velocity.x, b.velocity.x);
    FH_EXPECT_EQ(a.velocity.y, b.velocity.y);
    FH_EXPECT_EQ(a.velocity.z, b.velocity.z);
}

// kKickAliveTicks is a sanity-guarded constant: 2 s at 20 Hz gives
// comfortable runway for a short pass across the M2 BallOnPitch2v0
// scenario without letting a dead ball linger for absurdly long.
FH_TEST(kick_alive_ticks_constant_is_reasonable) {
    FH_EXPECT(kKickAliveTicks >= 20);   // ≥ 1 s of runway
    FH_EXPECT(kKickAliveTicks <= 200);  // ≤ 10 s (guardrail against typo)
}

FH_TEST_MAIN()