// footballhome sim - DefenderController tests (Slice 24.3a + 24.3b)
//
// Contract:
//   1. Given a ball in the view, the defender's desired_direction is
//      the unit vector from its own position toward the ball. This is
//      the whole point of the controller — the "chase" that gives
//      Slice 25.2 sprint-with-ball a reason to exist.
//   2. Missing own entity, missing ball, or standing exactly on the
//      ball all resolve to idle (zero desired_direction, no flags).
//   3. Consumes zero RNG. This is asserted via a passed-in RngDet — we
//      don't wire one in (Defender's ctor takes nothing) but the
//      determinism goldens that surround this slice will catch any
//      accidental RNG consumption at the match layer.
//   4. Never sets wants_sprint / wants_walk / wants_release. Slice
//      24.3b asserts BOTH wants_dribble (Rule-1 first-touch candidate)
//      AND wants_to_press (Rule-2 owner-radius shrinker) — the strip
//      is the emergent composition of those two rules.

#include "awareness/AwarenessView.hpp"
#include "common/EntityState.hpp"
#include "controller/DefenderController.hpp"
#include "controller/Intent.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"
#include "test_harness.hpp"

#include <string>

using fh::sim::EntityId;
using fh::sim::EntityState;
using fh::sim::MotionState;
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::awareness::AwarenessView;
using fh::sim::controller::DefenderController;
using fh::sim::controller::Intent;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;

namespace {

// Helper: assemble an AwarenessView containing a defender entity at
// `defender_pos` (SlotId{2}, EntityId{2}) and — when `include_ball` is
// true — a ball entity at `ball_pos` (SlotId{0}, EntityId{1}) with the
// view's `ball` optional pointing at it.
AwarenessView makeView(const Vec3& defender_pos,
                       bool include_ball,
                       const Vec3& ball_pos = Vec3{})
{
    AwarenessView v;
    v.tick         = TickNum{0};
    v.time_seconds = Fixed64::zero();

    if (include_ball) {
        EntityState ball{};
        ball.id       = EntityId{1};
        ball.slot_id  = SlotId{0};
        ball.position = ball_pos;
        ball.motion   = MotionState::Idle;
        v.entities.push_back(ball);
        v.ball = ball.id;
    }

    EntityState def{};
    def.id       = EntityId{2};
    def.slot_id  = SlotId{2};
    def.position = defender_pos;
    def.motion   = MotionState::Idle;
    v.entities.push_back(def);

    return v;
}

} // namespace

FH_TEST(pursues_ball_directly_west) {
    // Defender at (+5, 0), ball at origin. Expected unit vector: (-1, 0).
    DefenderController c;
    const auto v = makeView(Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()},
                            /*include_ball=*/true,
                            Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()});
    const Intent intent = c.decide(v, SlotId{2});
    FH_EXPECT_EQ(intent.desired_direction.x, Fixed64::fromInt(-1));
    FH_EXPECT_EQ(intent.desired_direction.y, Fixed64::zero());
    FH_EXPECT(!intent.wants_sprint);
    FH_EXPECT(!intent.wants_walk);
    // Slice 24.3b: defender asserts BOTH wants_dribble (Rule-1 candidate
    // once it reaches the ball) AND wants_to_press (Rule-2 shrinker for
    // any current owner). See DefenderController::decide.
    FH_EXPECT(intent.wants_dribble);
    FH_EXPECT(intent.wants_to_press);
    FH_EXPECT(!intent.wants_release);
}

FH_TEST(pursues_ball_directly_east) {
    // Defender at (-3, 0), ball at origin. Expected unit vector: (+1, 0).
    DefenderController c;
    const auto v = makeView(Vec3{Fixed64::fromInt(-3), Fixed64::zero(), Fixed64::zero()},
                            /*include_ball=*/true,
                            Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()});
    const Intent intent = c.decide(v, SlotId{2});
    FH_EXPECT_EQ(intent.desired_direction.x, Fixed64::fromInt(1));
    FH_EXPECT_EQ(intent.desired_direction.y, Fixed64::zero());
}

FH_TEST(pursues_ball_off_axis_is_unit_length) {
    // Defender at (3, 4), ball at origin. Diff is (-3, -4), length 5;
    // normalized should be (-0.6, -0.8). Assert the resulting vector's
    // squared length is 1 (within fixed-point rounding) — that's the
    // essential correctness property; the exact rounded components
    // depend on Fixed64 precision and are covered by Vec3 unit tests.
    DefenderController c;
    const auto v = makeView(Vec3{Fixed64::fromInt(3), Fixed64::fromInt(4), Fixed64::zero()},
                            /*include_ball=*/true,
                            Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()});
    const Intent intent = c.decide(v, SlotId{2});
    // Both components should be negative (heading toward origin from Q1).
    FH_EXPECT(intent.desired_direction.x < Fixed64::zero());
    FH_EXPECT(intent.desired_direction.y < Fixed64::zero());
    // |dir| ≈ 1  =>  |dir|² in [0.95, 1.05] tolerates Fixed64 rounding.
    const Fixed64 lensq =
        intent.desired_direction.x * intent.desired_direction.x +
        intent.desired_direction.y * intent.desired_direction.y;
    FH_EXPECT_GE(lensq, Fixed64::fromFraction(95, 100));
    FH_EXPECT_LE(lensq, Fixed64::fromFraction(105, 100));
}

FH_TEST(idle_when_own_entity_missing) {
    DefenderController c;
    AwarenessView v;   // no entities at all
    v.ball = EntityId{1};   // even a ball reference can't help
    const Intent i = c.decide(v, SlotId{2});
    FH_EXPECT_EQ(i.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(i.desired_direction.y, Fixed64::zero());
    FH_EXPECT(!i.wants_sprint);
}

FH_TEST(idle_when_ball_absent) {
    // Defender present but view.ball is nullopt (empty pitch scenario).
    // The chase controller has nothing to chase — must stand still.
    DefenderController c;
    const auto v = makeView(Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()},
                            /*include_ball=*/false);
    const Intent i = c.decide(v, SlotId{2});
    FH_EXPECT_EQ(i.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(i.desired_direction.y, Fixed64::zero());
}

FH_TEST(idle_when_ball_id_not_in_entities) {
    // view.ball points at an EntityId that isn't present in entities
    // (shouldn't happen in a well-formed match, but if it does the
    // controller must degrade to idle rather than dereference garbage).
    DefenderController c;
    AwarenessView v;
    v.tick         = TickNum{0};
    v.time_seconds = Fixed64::zero();

    EntityState def{};
    def.id       = EntityId{2};
    def.slot_id  = SlotId{2};
    def.position = Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()};
    v.entities.push_back(def);

    v.ball = EntityId{42};   // stale reference — no entity with id 42

    const Intent i = c.decide(v, SlotId{2});
    FH_EXPECT_EQ(i.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(i.desired_direction.y, Fixed64::zero());
}

FH_TEST(idle_when_standing_on_ball) {
    // Distance-zero pursuit should idle rather than emit an ill-defined
    // direction. Otherwise the defender would jitter atop the ball
    // once it arrives — bad for the visual demo and worse for future
    // contest resolution.
    DefenderController c;
    const auto v = makeView(Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
                            /*include_ball=*/true,
                            Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()});
    const Intent i = c.decide(v, SlotId{2});
    FH_EXPECT_EQ(i.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(i.desired_direction.y, Fixed64::zero());
}

FH_TEST(kind_is_defender) {
    DefenderController c;
    FH_EXPECT_EQ(std::string(c.kind()), std::string("defender"));
}

// Slice 24.3b bug fix: when the defender IS the current ball owner
// (view.ball_owner == self), it must NOT chase the ball — the ball is
// glued kBallOwnerLeadDistance (0.4 m) ahead of it, so a raw
// diff-toward-ball step would push it forward every tick and walk the
// ball straight off the pitch. Expected behavior: idle motion but
// KEEP wants_dribble asserted so BallControl retains ownership.
FH_TEST(holds_position_when_owns_ball) {
    DefenderController c;
    // Defender at origin, ball 0.4 m east (the glue position). Ownership
    // is signalled explicitly via view.ball_owner = self.
    auto v = makeView(Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
                      /*include_ball=*/true,
                      Vec3{Fixed64::fromFraction(4, 10), Fixed64::zero(),
                           Fixed64::zero()});
    v.ball_owner = SlotId{2};

    const Intent i = c.decide(v, SlotId{2});
    // No movement — defender stands still.
    FH_EXPECT_EQ(i.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(i.desired_direction.y, Fixed64::zero());
    // But still wants the ball so Rule 2 retention holds next tick.
    FH_EXPECT(i.wants_dribble);
    FH_EXPECT(i.wants_to_press);
}

// Sanity: view.ball_owner set to SOMEONE ELSE must NOT trigger the
// hold path — defender should still chase. Guards against a future
// regression that checks .has_value() instead of == self.
FH_TEST(chases_when_ball_owned_by_other_slot) {
    DefenderController c;
    auto v = makeView(Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()},
                      /*include_ball=*/true,
                      Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()});
    v.ball_owner = SlotId{1};   // human owns it, not this defender

    const Intent i = c.decide(v, SlotId{2});
    // Chase behavior unchanged: unit vector from (5,0) toward (0,0).
    FH_EXPECT_EQ(i.desired_direction.x, Fixed64::fromInt(-1));
    FH_EXPECT_EQ(i.desired_direction.y, Fixed64::zero());
    FH_EXPECT(i.wants_dribble);
    FH_EXPECT(i.wants_to_press);
}

FH_TEST_MAIN()
