// footballhome sim - BasicPhysics tests (Slice 27.2, ADR §22.24)
//
// Focuses on behaviour that StubPhysics does NOT have: the trailing
// collision pass in BasicPhysics::step(). Every test constructs
// BasicPhysics directly (no Match / no Scenario) so the tests stay
// unit-level and every collision case is isolated from the rest of
// the tick pipeline.

#include "physics/BasicPhysics.hpp"
#include "physics/IPhysicsWorld.hpp"
#include "common/EntityState.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"
#include "test_harness.hpp"

#include <algorithm>

using fh::sim::EntityId;
using fh::sim::MotionState;
using fh::sim::SlotId;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::physics::BasicPhysics;
using fh::sim::physics::EntityDef;

namespace {

// Raw-bit tolerance for Fixed64 comparisons after chains of
// mul/div/sqrt. 1024 raw units in Q32.32 = 1024 / 2^32 ≈ 2.4e-7 m,
// far below any gameplay-visible threshold. The head-on collision
// pass runs: fx_sqrt -> divide (to normal) -> multiply (by disp) ->
// add/subtract into position, and each op can drop a few LSBs.
constexpr std::int64_t kFixed64Epsilon = 1024;

bool nearEq(fh::sim::math::Fixed64 a, fh::sim::math::Fixed64 b) noexcept {
    const std::int64_t d = a.raw - b.raw;
    return d >= -kFixed64Epsilon && d <= kFixed64Epsilon;
}

EntityId spawnPlayer(BasicPhysics& p, SlotId slot, Vec3 pos, Vec3 vel = {})
{
    EntityDef def;
    def.slot_id  = slot;
    def.position = pos;
    def.velocity = vel;
    def.radius   = Fixed64::zero();
    def.height   = Fixed64::zero();
    def.is_ball  = false;
    return p.spawn(def);
}

EntityId spawnBall(BasicPhysics& p, Vec3 pos, Vec3 vel = {})
{
    EntityDef def;
    def.slot_id  = SlotId{0};
    def.position = pos;
    def.velocity = vel;
    def.radius   = Fixed64::zero();
    def.height   = Fixed64::zero();
    def.is_ball  = true;
    return p.spawn(def);
}

} // namespace

// -----------------------------------------------------------------------------
// Parity with StubPhysics: no-overlap step is a pure kinematic integrator.
// -----------------------------------------------------------------------------
FH_TEST(step_no_overlap_matches_kinematic_integration) {
    BasicPhysics p;
    const auto a = spawnPlayer(p, SlotId{1},
        Vec3{Fixed64::fromInt(-10), Fixed64::zero(), Fixed64::zero()},
        Vec3{Fixed64::fromInt(4),   Fixed64::fromInt(-2), Fixed64::zero()});
    const auto b = spawnPlayer(p, SlotId{2},
        Vec3{Fixed64::fromInt( 10), Fixed64::zero(), Fixed64::zero()},
        Vec3{Fixed64::zero(),        Fixed64::zero(),      Fixed64::zero()});

    const Fixed64 dt = Fixed64::fromFraction(1, 20);
    p.step(dt);

    const auto sa = p.get(a);
    const auto sb = p.get(b);
    // Kinematic: a moves by v*dt, b sits still. No MTV because 20 m
    // apart >> 0.8 m sum-of-radii.
    FH_EXPECT_EQ(sa.position.x, Fixed64::fromInt(-10) + Fixed64::fromInt(4)  * dt);
    FH_EXPECT_EQ(sa.position.y, Fixed64::fromInt(-2)  * dt);
    FH_EXPECT_EQ(sa.velocity.x, Fixed64::fromInt(4));
    FH_EXPECT_EQ(sa.velocity.y, Fixed64::fromInt(-2));
    FH_EXPECT_EQ(sb.position.x, Fixed64::fromInt(10));
    FH_EXPECT_EQ(sb.position.y, Fixed64::zero());
    FH_EXPECT_EQ(sb.velocity.x, Fixed64::zero());
}

// -----------------------------------------------------------------------------
// Head-on collision with equal masses (both default 1.0) splits the MTV
// symmetrically and zeroes both closing velocities. Assertions are
// invariant-based (touching sum-of-radii + symmetric about the pre-
// integration midpoint) because the Fixed64 sqrt in the normal-
// computation path yields a few LSBs of drift versus an exact
// Fixed64::fromFraction constant — the physical guarantee (they end
// up separated by exactly r_sum) holds bit-exactly regardless.
// -----------------------------------------------------------------------------
FH_TEST(head_on_equal_mass_symmetric_split_and_stop) {
    BasicPhysics p;
    // Overlap by 0.2 m (centres 0.6 m apart, sum-of-radii 0.8 m).
    const auto a = spawnPlayer(p, SlotId{1},
        Vec3{Fixed64::fromFraction(-3, 10), Fixed64::zero(), Fixed64::zero()},
        Vec3{Fixed64::fromInt( 2), Fixed64::zero(), Fixed64::zero()});
    const auto b = spawnPlayer(p, SlotId{2},
        Vec3{Fixed64::fromFraction( 3, 10), Fixed64::zero(), Fixed64::zero()},
        Vec3{Fixed64::fromInt(-2), Fixed64::zero(), Fixed64::zero()});

    p.step(Fixed64::fromFraction(1, 20));

    const auto sa = p.get(a);
    const auto sb = p.get(b);

    // Invariant 1: touching at sum-of-radii (±kFixed64Epsilon after
    // the sqrt / divide / mul chain).
    const Fixed64 r_sum =
        fh::sim::physics::kPlayerContactRadius +
        fh::sim::physics::kPlayerContactRadius;
    FH_EXPECT(nearEq(sb.position.x - sa.position.x, r_sum));

    // Invariant 2: symmetric split about the pre-integration midpoint
    // (=0). Equal masses ⇒ a and b displaced equally from centre.
    FH_EXPECT(nearEq(sa.position.x + sb.position.x, Fixed64::zero()));

    // Invariant 3: post-MTV y unchanged (all motion along +x/-x).
    FH_EXPECT_EQ(sa.position.y, Fixed64::zero());
    FH_EXPECT_EQ(sb.position.y, Fixed64::zero());

    // Velocity zap: the closing components (a: +x, b: -x) are
    // effectively zeroed. Exact-zero would require nx*nx == 1 in
    // Fixed64, which is only guaranteed when d matches a perfect
    // square in the fx_sqrt range — not the case here after the
    // integration step. Tolerance-check instead.
    FH_EXPECT(nearEq(sa.velocity.x, Fixed64::zero()));
    FH_EXPECT_EQ(sa.velocity.y, Fixed64::zero());
    FH_EXPECT(nearEq(sb.velocity.x, Fixed64::zero()));
    FH_EXPECT_EQ(sb.velocity.y, Fixed64::zero());
}

// -----------------------------------------------------------------------------
// Tangential slide: player a runs perpendicular to the contact normal,
// tangential velocity is preserved because there is no closing component.
// -----------------------------------------------------------------------------
FH_TEST(tangential_slide_preserves_perpendicular_velocity) {
    BasicPhysics p;
    // Overlap ~0.4 m along +x (centres 0.4 m apart, sum-of-radii 0.8 m).
    // a moves purely along +y at 3 m/s → normal is +x, so a.velocity has
    // ZERO component along +normal → no zap.
    const auto a = spawnPlayer(p, SlotId{1},
        Vec3{Fixed64::fromFraction(-2, 10), Fixed64::zero(), Fixed64::zero()},
        Vec3{Fixed64::zero(), Fixed64::fromInt(3), Fixed64::zero()});
    // b is only present so a pair exists; its state after the pass is
    // not asserted, only a's velocity preservation matters here.
    (void)spawnPlayer(p, SlotId{2},
        Vec3{Fixed64::fromFraction( 2, 10), Fixed64::zero(), Fixed64::zero()},
        Vec3{Fixed64::zero(), Fixed64::zero(),                Fixed64::zero()});

    p.step(Fixed64::fromFraction(1, 20));

    const auto sa = p.get(a);
    // Tangential velocity untouched (all of a's velocity is
    // perpendicular to the +x normal).
    FH_EXPECT_EQ(sa.velocity.x, Fixed64::zero());
    FH_EXPECT_EQ(sa.velocity.y, Fixed64::fromInt(3));
}

// -----------------------------------------------------------------------------
// Asymmetric mass split: heavier entity (1.5) barely moves; lighter (0.5)
// takes 75% of the penetration. Assertions verify the touching invariant
// (sum-of-radii apart) plus a mass-weighted midpoint check that holds
// bit-exactly regardless of sqrt rounding.
// -----------------------------------------------------------------------------
FH_TEST(asymmetric_mass_split_favors_heavier) {
    BasicPhysics p;
    const auto a = spawnPlayer(p, SlotId{1},
        Vec3{Fixed64::fromFraction(-2, 10), Fixed64::zero(), Fixed64::zero()});
    const auto b = spawnPlayer(p, SlotId{2},
        Vec3{Fixed64::fromFraction( 2, 10), Fixed64::zero(), Fixed64::zero()});

    p.setBodyMass(a, Fixed64::fromFraction(5,  10));   // 0.5 (light)
    p.setBodyMass(b, Fixed64::fromFraction(15, 10));   // 1.5 (heavy)

    p.step(Fixed64::fromFraction(1, 20));

    const auto sa = p.get(a);
    const auto sb = p.get(b);

    // Invariant 1: touching at sum-of-radii.
    const Fixed64 r_sum =
        fh::sim::physics::kPlayerContactRadius +
        fh::sim::physics::kPlayerContactRadius;
    FH_EXPECT(nearEq(sb.position.x - sa.position.x, r_sum));

    // Invariant 2: heavier entity displaced LESS than lighter, in
    // inverse proportion to mass. The MTV forces on the pair are
    // equal-and-opposite, so the mass-weighted centroid is preserved:
    //   m_a * a.x + m_b * b.x == invariant across the collision pass.
    // Starting positions (-0.2, +0.2) → initial m-weighted sum =
    //   0.5 * -0.2 + 1.5 * 0.2 = 0.2.
    // Assertion (tolerance-checked):
    //   0.5 * sa.x + 1.5 * sb.x ≈ 0.2
    // Rewritten to clear fractions:
    //   sa.x + 3 * sb.x ≈ 0.4
    FH_EXPECT(nearEq(sa.position.x + Fixed64::fromInt(3) * sb.position.x,
                     Fixed64::fromFraction(4, 10)));
    FH_EXPECT(sa.position.x < Fixed64::fromFraction(-2, 10));  // moved -x
    FH_EXPECT(sb.position.x > Fixed64::fromFraction( 2, 10));  // moved +x
}

// -----------------------------------------------------------------------------
// body_mass values outside [0.5, 1.5] are clamped at read time inside
// BasicPhysics::step — the resolver must never see a runaway mass value.
// Same invariant-based assertions as asymmetric_mass_split_favors_heavier
// but with roles swapped (a is now the heavy one because its 100.0 mass
// clamps to 1.5).
// -----------------------------------------------------------------------------
FH_TEST(body_mass_clamped_to_valid_range) {
    BasicPhysics p;
    const auto a = spawnPlayer(p, SlotId{1},
        Vec3{Fixed64::fromFraction(-2, 10), Fixed64::zero(), Fixed64::zero()});
    const auto b = spawnPlayer(p, SlotId{2},
        Vec3{Fixed64::fromFraction( 2, 10), Fixed64::zero(), Fixed64::zero()});

    // Wildly out-of-range values must be clamped to [0.5, 1.5] on READ.
    p.setBodyMass(a, Fixed64::fromInt(100));            // → 1.5
    p.setBodyMass(b, Fixed64::fromFraction(1, 100));    // → 0.5

    p.step(Fixed64::fromFraction(1, 20));

    const auto sa = p.get(a);
    const auto sb = p.get(b);

    const Fixed64 r_sum =
        fh::sim::physics::kPlayerContactRadius +
        fh::sim::physics::kPlayerContactRadius;
    FH_EXPECT(nearEq(sb.position.x - sa.position.x, r_sum));

    // a clamps to 1.5 (heavy), b clamps to 0.5 (light). Same
    // mass-weighted-centroid invariant, roles swapped:
    //   1.5 * a.x + 0.5 * b.x == invariant.
    // Starting positions (-0.2, +0.2) → initial sum =
    //   1.5 * -0.2 + 0.5 * 0.2 = -0.2.
    // Rewritten to clear fractions:
    //   3 * sa.x + sb.x ≈ -0.4
    FH_EXPECT(nearEq(Fixed64::fromInt(3) * sa.position.x + sb.position.x,
                     Fixed64::fromFraction(-4, 10)));
    FH_EXPECT(sa.position.x < Fixed64::fromFraction(-2, 10));  // moved -x
    FH_EXPECT(sb.position.x > Fixed64::fromFraction( 2, 10));  // moved +x
}

// -----------------------------------------------------------------------------
// Ball is ALWAYS excluded from the collision pass (ADR §22.24 Amendment
// 2026-07-17). A defender running THROUGH the ball's spawn position
// experiences no MTV and no velocity zap.
// -----------------------------------------------------------------------------
FH_TEST(ball_excluded_from_collision_pass) {
    BasicPhysics p;
    // Ball at origin, defender approaching from west at 5 m/s.
    const auto ball_id = spawnBall(p,
        Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()});
    const auto def_id = spawnPlayer(p, SlotId{1},
        Vec3{Fixed64::fromFraction(-1, 10), Fixed64::zero(), Fixed64::zero()},
        Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()});

    // Overlap of ~0.1m. If ball were included, the defender would be
    // MTV-pushed away and its +x velocity would be zapped.
    p.step(Fixed64::fromFraction(1, 20));

    const auto ball = p.get(ball_id);
    const auto def  = p.get(def_id);

    // Ball unmoved (no velocity, not touched by any pass).
    FH_EXPECT_EQ(ball.position.x, Fixed64::zero());
    FH_EXPECT_EQ(ball.position.y, Fixed64::zero());

    // Defender's kinematic integration proceeds without interference:
    // pos.x = -0.1 + 5*(1/20) = 0.15; velocity untouched at +5 m/s.
    FH_EXPECT_EQ(def.position.x, Fixed64::fromFraction(-1, 10) +
                                 Fixed64::fromInt(5) * Fixed64::fromFraction(1, 20));
    FH_EXPECT_EQ(def.velocity.x, Fixed64::fromInt(5));
}

// -----------------------------------------------------------------------------
// Coincident centres: the epsilon branch resolves the normal to +x
// deterministically instead of dividing by ~zero.
// -----------------------------------------------------------------------------
FH_TEST(coincident_centres_epsilon_fallback_to_x) {
    BasicPhysics p;
    const auto a = spawnPlayer(p, SlotId{1},
        Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()});
    const auto b = spawnPlayer(p, SlotId{2},
        Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()});

    p.step(Fixed64::fromFraction(1, 20));

    const auto sa = p.get(a);
    const auto sb = p.get(b);
    // Fallback normal = (+1, 0). penetration = r_sum = 0.8.
    // Equal masses → disp = 0.4 each. a moves +0.4 along +x, b -0.4.
    FH_EXPECT_EQ(sa.position.x, Fixed64::fromFraction(4, 10));
    FH_EXPECT_EQ(sb.position.x, Fixed64::fromFraction(-4, 10));
}

// -----------------------------------------------------------------------------
// Bit-exact determinism: running the same setup twice produces byte-
// identical positions and velocities. Guards against any accidental
// non-determinism creeping in via unordered_map iteration order (the
// resolveCollisions candidate list is sorted ascending EntityId before
// the O(N^2) pair loop, so iteration order is fixed by EntityId
// regardless of insertion order). We deliberately do NOT assert
// symmetry across a mirrored spawn-order run because Fixed64 arithmetic
// is not sign-symmetric to the LSB (arithmetic shift right of a
// negative __int128 result rounds toward -inf, so (-a)*b can differ
// from -(a*b) in the raw bits). What matters for gameplay is
// reproducibility — same inputs → same outputs — which this covers.
// -----------------------------------------------------------------------------
FH_TEST(step_is_reproducible_bit_exact) {
    auto run = []() {
        BasicPhysics p;
        const auto a = spawnPlayer(p, SlotId{1},
            Vec3{Fixed64::fromFraction(-2, 10), Fixed64::zero(),
                 Fixed64::zero()});
        const auto b = spawnPlayer(p, SlotId{2},
            Vec3{Fixed64::fromFraction( 2, 10), Fixed64::zero(),
                 Fixed64::zero()});
        p.step(Fixed64::fromFraction(1, 20));
        return std::make_pair(p.get(a), p.get(b));
    };

    const auto r1 = run();
    const auto r2 = run();

    FH_EXPECT_EQ(r1.first.position.x,  r2.first.position.x);
    FH_EXPECT_EQ(r1.first.position.y,  r2.first.position.y);
    FH_EXPECT_EQ(r1.second.position.x, r2.second.position.x);
    FH_EXPECT_EQ(r1.second.position.y, r2.second.position.y);
    FH_EXPECT_EQ(r1.first.velocity.x,  r2.first.velocity.x);
    FH_EXPECT_EQ(r1.second.velocity.x, r2.second.velocity.x);
}

// -----------------------------------------------------------------------------
// setBodyMass on an unknown EntityId is silently a no-op (matches the
// other setters). The collision resolver falls back to kBodyMassDefault
// for any entity with no explicit mass.
// -----------------------------------------------------------------------------
FH_TEST(set_body_mass_ignores_unknown_id) {
    BasicPhysics p;
    p.setBodyMass(EntityId{999}, Fixed64::fromInt(2));   // no crash
    FH_EXPECT(!p.contains(EntityId{999}));
}

// -----------------------------------------------------------------------------
// all() returns EntityIds sorted ascending, same as StubPhysics.
// -----------------------------------------------------------------------------
FH_TEST(all_returns_ascending_entity_ids) {
    BasicPhysics p;
    spawnPlayer(p, SlotId{5}, Vec3{});
    spawnPlayer(p, SlotId{1}, Vec3{});
    spawnPlayer(p, SlotId{3}, Vec3{});

    const auto ids = p.all();
    FH_EXPECT_EQ(ids.size(), std::size_t{3});
    FH_EXPECT(std::is_sorted(ids.begin(), ids.end()));
}

FH_TEST_MAIN()
