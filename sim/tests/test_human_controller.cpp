// footballhome sim - HumanController tests

#include "controller/HumanController.hpp"
#include "controller/Intent.hpp"
#include "awareness/AwarenessView.hpp"
#include "common/EntityState.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

#include <string>

using fh::sim::ClientId;
using fh::sim::EntityId;
using fh::sim::EntityState;
using fh::sim::MotionState;
using fh::sim::SlotId;
using fh::sim::awareness::AwarenessView;
using fh::sim::controller::HumanController;
using fh::sim::controller::Intent;
using fh::sim::controller::kBallAutoDribbleRadius;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;

namespace {

// Compose an EntityState in one line — Slice 16.2 tests need to build
// small awareness views with a self entity and (sometimes) a ball entity.
EntityState makeEntity(EntityId id, SlotId slot, Vec3 pos) {
    EntityState e;
    e.id       = id;
    e.slot_id  = slot;
    e.position = pos;
    e.velocity = Vec3{};
    e.heading  = Fixed64::zero();
    e.motion   = MotionState::Idle;
    return e;
}

} // namespace

FH_TEST(defaults_to_idle_intent) {
    HumanController c{ClientId{42}};
    FH_EXPECT_EQ(c.owner(), ClientId{42});

    AwarenessView v;
    const Intent i = c.decide(v, SlotId{1});
    FH_EXPECT_EQ(i.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(i.desired_direction.y, Fixed64::zero());
    FH_EXPECT_EQ(i.desired_direction.z, Fixed64::zero());
    FH_EXPECT(!i.wants_sprint);
    FH_EXPECT(!i.wants_walk);
    FH_EXPECT(!i.wants_dribble);
}

FH_TEST(returns_latest_input_verbatim) {
    HumanController c{ClientId{1}};
    Intent in;
    in.desired_direction = Vec3{Fixed64::fromInt(1), Fixed64::zero(), Fixed64::zero()};
    in.wants_sprint = true;
    c.updateInput(in);

    // Empty awareness view (no ball) → auto-dribble hint MUST NOT fire.
    AwarenessView v;
    const Intent out = c.decide(v, SlotId{1});
    FH_EXPECT_EQ(out.desired_direction.x, Fixed64::fromInt(1));
    FH_EXPECT(out.wants_sprint);
    FH_EXPECT(!out.wants_walk);
    FH_EXPECT(!out.wants_dribble);
}

FH_TEST(kind_string) {
    HumanController c{ClientId{1}};
    FH_EXPECT_EQ(std::string(c.kind()), std::string("human"));
}

// ---------------------------------------------------------------------------
// Slice 16.2: auto-dribble hint when self is close to the ball.
//
// Rules under test:
//   * If AwarenessView has no ball, wants_dribble stays false.
//   * If AwarenessView has a ball but self is farther than
//     kBallAutoDribbleRadius, wants_dribble stays false.
//   * If self is within (or at) kBallAutoDribbleRadius, wants_dribble = true.
//   * A wire-set wants_dribble = true always passes through, regardless of
//     ball state (client explicit hint always wins on the true side).
// ---------------------------------------------------------------------------

FH_TEST(auto_dribble_stays_false_when_no_ball) {
    HumanController c{ClientId{1}};

    AwarenessView v;
    v.entities.push_back(makeEntity(EntityId{5}, SlotId{3},
                                    Vec3{Fixed64::zero(), Fixed64::zero(),
                                         Fixed64::zero()}));
    // v.ball intentionally left nullopt.
    const Intent out = c.decide(v, SlotId{3});
    FH_EXPECT(!out.wants_dribble);
}

FH_TEST(auto_dribble_fires_when_ball_within_radius) {
    HumanController c{ClientId{1}};

    // Self at origin; ball at (1.0, 0, 0) — well inside 1.5 m radius.
    AwarenessView v;
    v.entities.push_back(makeEntity(EntityId{0}, SlotId{0},
                                    Vec3{Fixed64::fromInt(1), Fixed64::zero(),
                                         Fixed64::zero()}));
    v.entities.push_back(makeEntity(EntityId{5}, SlotId{3},
                                    Vec3{Fixed64::zero(), Fixed64::zero(),
                                         Fixed64::zero()}));
    v.ball = EntityId{0};

    const Intent out = c.decide(v, SlotId{3});
    FH_EXPECT(out.wants_dribble);
}

FH_TEST(auto_dribble_stays_false_when_ball_far) {
    HumanController c{ClientId{1}};

    // Self at origin; ball at (5, 0, 0) — well outside 1.5 m radius.
    AwarenessView v;
    v.entities.push_back(makeEntity(EntityId{0}, SlotId{0},
                                    Vec3{Fixed64::fromInt(5), Fixed64::zero(),
                                         Fixed64::zero()}));
    v.entities.push_back(makeEntity(EntityId{5}, SlotId{3},
                                    Vec3{Fixed64::zero(), Fixed64::zero(),
                                         Fixed64::zero()}));
    v.ball = EntityId{0};

    const Intent out = c.decide(v, SlotId{3});
    FH_EXPECT(!out.wants_dribble);
}

FH_TEST(auto_dribble_ignores_z_component) {
    HumanController c{ClientId{1}};

    // Ball 0.5 m to the side but 100 m in the air — XY distance is only
    // 0.5 m, so the horizontal-only check must trigger. This locks the
    // "distSqXY (not 3D)" contract; changing that would break Slice 16.3
    // BallControl's floor-plane control model.
    AwarenessView v;
    v.entities.push_back(makeEntity(EntityId{0}, SlotId{0},
                                    Vec3{Fixed64::fromFraction(1, 2),
                                         Fixed64::zero(),
                                         Fixed64::fromInt(100)}));
    v.entities.push_back(makeEntity(EntityId{5}, SlotId{3},
                                    Vec3{Fixed64::zero(), Fixed64::zero(),
                                         Fixed64::zero()}));
    v.ball = EntityId{0};

    const Intent out = c.decide(v, SlotId{3});
    FH_EXPECT(out.wants_dribble);
}

FH_TEST(auto_dribble_respects_exact_radius_boundary) {
    HumanController c{ClientId{1}};

    // Ball exactly at kBallAutoDribbleRadius (1.5 m) along X → boundary
    // is inclusive per HumanController (d² <= r²) so wants_dribble fires.
    AwarenessView v;
    v.entities.push_back(makeEntity(EntityId{0}, SlotId{0},
                                    Vec3{kBallAutoDribbleRadius,
                                         Fixed64::zero(),
                                         Fixed64::zero()}));
    v.entities.push_back(makeEntity(EntityId{5}, SlotId{3},
                                    Vec3{Fixed64::zero(), Fixed64::zero(),
                                         Fixed64::zero()}));
    v.ball = EntityId{0};

    const Intent out = c.decide(v, SlotId{3});
    FH_EXPECT(out.wants_dribble);
}

FH_TEST(explicit_wire_dribble_wins_when_ball_far) {
    HumanController c{ClientId{1}};

    // Wire already asked for dribble → returned Intent must keep it true
    // even though the auto-hint wouldn't fire (ball is far).
    Intent in;
    in.wants_dribble = true;
    c.updateInput(in);

    AwarenessView v;
    v.entities.push_back(makeEntity(EntityId{0}, SlotId{0},
                                    Vec3{Fixed64::fromInt(50), Fixed64::zero(),
                                         Fixed64::zero()}));
    v.entities.push_back(makeEntity(EntityId{5}, SlotId{3},
                                    Vec3{Fixed64::zero(), Fixed64::zero(),
                                         Fixed64::zero()}));
    v.ball = EntityId{0};

    const Intent out = c.decide(v, SlotId{3});
    FH_EXPECT(out.wants_dribble);
}

FH_TEST(auto_dribble_does_not_fire_if_self_slot_missing_from_view) {
    HumanController c{ClientId{1}};

    // Ball is right there, but our slot has no entity in the view (e.g.
    // spawning tick). Auto-hint must NOT fabricate wants_dribble from
    // thin air — safer to withhold the hint than to grant it wrongly.
    AwarenessView v;
    v.entities.push_back(makeEntity(EntityId{0}, SlotId{0},
                                    Vec3{Fixed64::zero(), Fixed64::zero(),
                                         Fixed64::zero()}));
    // No entity with SlotId{3}.
    v.ball = EntityId{0};

    const Intent out = c.decide(v, SlotId{3});
    FH_EXPECT(!out.wants_dribble);
}

FH_TEST_MAIN()
