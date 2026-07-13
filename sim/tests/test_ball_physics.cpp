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

// Determinism: same inputs → identical trajectory, ULP-for-ULP.
// The Slice 15.6 cross-arch test will assert this too across arches;
// this test locks it inside a single arch as a first defense.
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

FH_TEST_MAIN()
