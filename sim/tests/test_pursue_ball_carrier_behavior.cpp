// footballhome sim - PursueBallCarrierBehavior tests (Slice 30.2)
//
// Migrated from test_defender_pursuit.cpp (deleted) — the pursuit
// invariants that DefenderController encoded are now enforced against
// PursueBallCarrierBehavior::execute() directly. The behavior is the
// M3 replacement for the M2 hand-rolled controller; every branch of
// DefenderController::decide() has a counterpart branch in
// PursueBallCarrierBehavior::execute() (§25.2 debug-replay bullet 4).
//
// Isolation: this file exercises the behavior directly, NOT through
// AiController. Dispatch mechanics (concept gates, utility argmax,
// tie-break, abstention) are covered by test_ai_controller.cpp using
// MockBehavior. Here we lock the pursue implementation's semantics.
//
// Contract (mirrors the deleted test_defender_pursuit.cpp):
//   1. Given a ball in the view, execute() produces desired_direction
//      = unit vector from own position toward the ball, plus
//      wants_dribble + wants_to_press asserted (Slice 24.3b).
//   2. Missing own entity, missing ball, or standing exactly on the
//      ball all resolve to idle (zero desired_direction, no flags).
//   3. If self owns the ball, hold position with wants_dribble +
//      wants_to_press (Slice 24.3b bug fix) — a chase step would walk
//      the ball off the pitch since it's glued 0.4 m ahead of the
//      owner in the heading direction.
//   4. utility() returns Fixed64::one() in Slice 30.2 (single-behavior
//      bag; magnitude locked to 1 until JockeyBehavior lands in
//      Slice 31.4).
//   5. requiredConcepts() returns {kPressing}, minMastery() returns
//      Fixed64::zero() (presence-gated).
//   6. Consumes zero RNG (asserted by the surrounding determinism
//      goldens; not directly testable here without a match harness).

#include "awareness/AwarenessView.hpp"
#include "behavior/PursueBallCarrierBehavior.hpp"
#include "common/EntityState.hpp"
#include "common/M0Registry.generated.hpp"
#include "controller/Intent.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"
#include "profile/ConceptSet.hpp"
#include "test_harness.hpp"

#include <algorithm>
#include <string>

using fh::sim::EntityId;
using fh::sim::EntityState;
using fh::sim::MotionState;
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::awareness::AwarenessView;
using fh::sim::behavior::PursueBallCarrierBehavior;
using fh::sim::controller::Intent;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::profile::ConceptSet;

namespace {

// Helper: assemble an AwarenessView containing a defender entity at
// `defender_pos` (SlotId{2}, EntityId{2}) and — when `include_ball` is
// true — a ball entity at `ball_pos` (SlotId{0}, EntityId{1}) with the
// view's `ball` optional pointing at it. Identical shape to the deleted
// test_defender_pursuit.cpp helper so branch-coverage assertions stay
// literally the same.
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

// A ConceptSet with `pressing` plugged at 1.0 — the state
// BallOnPitchWithDefenderScenario produces for slot 2 via
// applyConceptOverrides. Passed to execute() by tests that only care
// about branch coverage; execute() doesn't currently read the set
// but the parameter is part of the IBehavior contract and passing a
// realistic one keeps the tests representative.
ConceptSet pressingConcepts()
{
    ConceptSet c;
    c.plug(fh::sim::m0::kPressing, Fixed64::one());
    return c;
}

} // namespace

FH_TEST(pursues_ball_directly_west) {
    // Defender at (+5, 0), ball at origin. Expected unit vector: (-1, 0).
    PursueBallCarrierBehavior b;
    const auto v = makeView(Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()},
                            /*include_ball=*/true,
                            Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()});
    const auto  concepts = pressingConcepts();
    const Intent intent  = b.execute(v, SlotId{2}, concepts);
    FH_EXPECT_EQ(intent.desired_direction.x, Fixed64::fromInt(-1));
    FH_EXPECT_EQ(intent.desired_direction.y, Fixed64::zero());
    FH_EXPECT(!intent.wants_sprint);
    FH_EXPECT(!intent.wants_walk);
    FH_EXPECT(intent.wants_dribble);
    FH_EXPECT(intent.wants_to_press);
    FH_EXPECT(!intent.wants_release);
}

FH_TEST(pursues_ball_directly_east) {
    PursueBallCarrierBehavior b;
    const auto v = makeView(Vec3{Fixed64::fromInt(-3), Fixed64::zero(), Fixed64::zero()},
                            /*include_ball=*/true,
                            Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()});
    const auto  concepts = pressingConcepts();
    const Intent intent  = b.execute(v, SlotId{2}, concepts);
    FH_EXPECT_EQ(intent.desired_direction.x, Fixed64::fromInt(1));
    FH_EXPECT_EQ(intent.desired_direction.y, Fixed64::zero());
}

FH_TEST(pursues_ball_off_axis_is_unit_length) {
    // Defender at (3, 4), ball at origin. Diff is (-3, -4), length 5;
    // normalized should be (-0.6, -0.8). Assert the resulting vector's
    // squared length is close to 1 within Fixed64 rounding tolerance.
    PursueBallCarrierBehavior b;
    const auto v = makeView(Vec3{Fixed64::fromInt(3), Fixed64::fromInt(4), Fixed64::zero()},
                            /*include_ball=*/true,
                            Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()});
    const auto  concepts = pressingConcepts();
    const Intent intent  = b.execute(v, SlotId{2}, concepts);
    FH_EXPECT(intent.desired_direction.x < Fixed64::zero());
    FH_EXPECT(intent.desired_direction.y < Fixed64::zero());
    const Fixed64 lensq =
        intent.desired_direction.x * intent.desired_direction.x +
        intent.desired_direction.y * intent.desired_direction.y;
    FH_EXPECT_GE(lensq, Fixed64::fromFraction(95, 100));
    FH_EXPECT_LE(lensq, Fixed64::fromFraction(105, 100));
}

FH_TEST(idle_when_own_entity_missing) {
    PursueBallCarrierBehavior b;
    AwarenessView v;
    v.ball = EntityId{1};
    const auto  concepts = pressingConcepts();
    const Intent i       = b.execute(v, SlotId{2}, concepts);
    FH_EXPECT_EQ(i.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(i.desired_direction.y, Fixed64::zero());
    FH_EXPECT(!i.wants_sprint);
}

FH_TEST(idle_when_ball_absent) {
    PursueBallCarrierBehavior b;
    const auto v = makeView(Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()},
                            /*include_ball=*/false);
    const auto  concepts = pressingConcepts();
    const Intent i       = b.execute(v, SlotId{2}, concepts);
    FH_EXPECT_EQ(i.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(i.desired_direction.y, Fixed64::zero());
}

FH_TEST(idle_when_ball_id_not_in_entities) {
    // view.ball points at an EntityId that isn't present in entities.
    // Behavior must degrade to idle rather than dereference garbage.
    PursueBallCarrierBehavior b;
    AwarenessView v;
    v.tick         = TickNum{0};
    v.time_seconds = Fixed64::zero();

    EntityState def{};
    def.id       = EntityId{2};
    def.slot_id  = SlotId{2};
    def.position = Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()};
    v.entities.push_back(def);

    v.ball = EntityId{42};   // stale reference — no entity with id 42

    const auto  concepts = pressingConcepts();
    const Intent i       = b.execute(v, SlotId{2}, concepts);
    FH_EXPECT_EQ(i.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(i.desired_direction.y, Fixed64::zero());
}

FH_TEST(idle_when_standing_on_ball) {
    PursueBallCarrierBehavior b;
    const auto v = makeView(Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
                            /*include_ball=*/true,
                            Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()});
    const auto  concepts = pressingConcepts();
    const Intent i       = b.execute(v, SlotId{2}, concepts);
    FH_EXPECT_EQ(i.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(i.desired_direction.y, Fixed64::zero());
}

FH_TEST(id_string_is_pursue_ball_carrier) {
    PursueBallCarrierBehavior b;
    FH_EXPECT_EQ(std::string(b.id()), std::string("pursue_ball_carrier"));
}

// Slice 24.3b bug-fix branch (still enforced): when the behavior IS
// the current ball owner, hold position with wants_dribble +
// wants_to_press asserted. A chase step would push the glued ball
// forward every tick and walk it off the pitch.
FH_TEST(holds_position_when_owns_ball) {
    PursueBallCarrierBehavior b;
    auto v = makeView(Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
                      /*include_ball=*/true,
                      Vec3{Fixed64::fromFraction(4, 10), Fixed64::zero(),
                           Fixed64::zero()});
    v.ball_owner = SlotId{2};

    const auto  concepts = pressingConcepts();
    const Intent i       = b.execute(v, SlotId{2}, concepts);
    FH_EXPECT_EQ(i.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(i.desired_direction.y, Fixed64::zero());
    FH_EXPECT(i.wants_dribble);
    FH_EXPECT(i.wants_to_press);
}

// Sanity: view.ball_owner set to SOMEONE ELSE must NOT trigger the
// hold path — behavior should still chase. Guards against a future
// regression that checks .has_value() instead of == self.
FH_TEST(chases_when_ball_owned_by_other_slot) {
    PursueBallCarrierBehavior b;
    auto v = makeView(Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()},
                      /*include_ball=*/true,
                      Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()});
    v.ball_owner = SlotId{1};

    const auto  concepts = pressingConcepts();
    const Intent i       = b.execute(v, SlotId{2}, concepts);
    FH_EXPECT_EQ(i.desired_direction.x, Fixed64::fromInt(-1));
    FH_EXPECT_EQ(i.desired_direction.y, Fixed64::zero());
    FH_EXPECT(i.wants_dribble);
    FH_EXPECT(i.wants_to_press);
}

// Slice 30.2 behavior-interface contract tests.
FH_TEST(utility_is_constant_one) {
    // Slice 30.2 shape: constant Fixed64::one() so the single-behavior
    // bag always claims the tick. The 1/distance shape lands in Slice
    // 31.4 when JockeyBehavior first competes with pursue.
    PursueBallCarrierBehavior b;
    const auto v = makeView(Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()},
                            /*include_ball=*/true,
                            Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()});
    const auto  concepts = pressingConcepts();
    FH_EXPECT_EQ(b.utility(v, SlotId{2}, concepts), Fixed64::one());

    // Also constant when self owns the ball — utility() doesn't inspect
    // the view in Slice 30.2, but lock the invariant so a future edit
    // that adds view inspection doesn't silently break the single-behavior
    // dispatch.
    auto v2 = makeView(Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
                       /*include_ball=*/true,
                       Vec3{Fixed64::fromFraction(4, 10), Fixed64::zero(),
                            Fixed64::zero()});
    v2.ball_owner = SlotId{2};
    FH_EXPECT_EQ(b.utility(v2, SlotId{2}, concepts), Fixed64::one());

    // And constant when there is no ball — same reason.
    const auto v3 = makeView(Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()},
                             /*include_ball=*/false);
    FH_EXPECT_EQ(b.utility(v3, SlotId{2}, concepts), Fixed64::one());
}

FH_TEST(required_concepts_is_pressing) {
    PursueBallCarrierBehavior b;
    const auto reqs = b.requiredConcepts();
    FH_EXPECT_EQ(reqs.size(), std::size_t{1});
    FH_EXPECT_EQ(reqs[0], fh::sim::m0::kPressing);
}

FH_TEST(min_mastery_is_zero_presence_gated) {
    PursueBallCarrierBehavior b;
    FH_EXPECT_EQ(b.minMastery(), Fixed64::zero());
}

FH_TEST_MAIN()
