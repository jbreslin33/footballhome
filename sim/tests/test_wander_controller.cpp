// footballhome sim - WanderController tests

#include "controller/WanderController.hpp"
#include "controller/Intent.hpp"
#include "awareness/AwarenessView.hpp"
#include "common/EntityState.hpp"
#include "math/Fixed64.hpp"
#include "math/RngDet.hpp"
#include "math/Vec3.hpp"
#include "test_harness.hpp"

using fh::sim::EntityId;
using fh::sim::EntityState;
using fh::sim::MotionState;
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::awareness::AwarenessView;
using fh::sim::controller::Intent;
using fh::sim::controller::WanderController;
using fh::sim::math::Fixed64;
using fh::sim::math::RngDet;
using fh::sim::math::Vec3;

namespace {

AwarenessView makeView(const Vec3& my_pos, SlotId my_slot,
                       Fixed64 t = Fixed64::zero()) {
    AwarenessView v;
    v.tick         = TickNum{0};
    v.time_seconds = t;
    EntityState e{};
    e.id       = EntityId{1};
    e.slot_id  = my_slot;
    e.position = my_pos;
    e.motion   = MotionState::Idle;
    v.entities.push_back(e);
    return v;
}

} // namespace

FH_TEST(target_is_inside_pitch_bounds) {
    RngDet rng(42);
    // 105 x 68 m pitch
    WanderController c(Fixed64::fromInt(105), Fixed64::fromInt(68), &rng);

    const auto v = makeView(Vec3{}, SlotId{1});
    const Intent intent = c.decide(v, SlotId{1});
    (void)intent;

    // After first decide, target should be picked.
    const Vec3 t = c.target();
    const Fixed64 halfL = Fixed64::fromInt(105) * Fixed64::fromFraction(1, 2);
    const Fixed64 halfW = Fixed64::fromInt(68)  * Fixed64::fromFraction(1, 2);
    FH_EXPECT_GE(t.x, -halfL);
    FH_EXPECT_LE(t.x,  halfL);
    FH_EXPECT_GE(t.y, -halfW);
    FH_EXPECT_LE(t.y,  halfW);
}

FH_TEST(different_seeds_produce_different_targets) {
    RngDet a(1);
    RngDet b(2);
    WanderController ca(Fixed64::fromInt(105), Fixed64::fromInt(68), &a);
    WanderController cb(Fixed64::fromInt(105), Fixed64::fromInt(68), &b);

    const auto v = makeView(Vec3{}, SlotId{1});
    (void)ca.decide(v, SlotId{1});
    (void)cb.decide(v, SlotId{1});
    // Overwhelmingly likely to differ; if this ever fires it's a bug not flakiness
    // (RngDet is deterministic).
    FH_EXPECT(ca.target().x != cb.target().x
           || ca.target().y != cb.target().y);
}

FH_TEST(same_seed_reproduces_target) {
    RngDet a(999);
    RngDet b(999);
    WanderController ca(Fixed64::fromInt(105), Fixed64::fromInt(68), &a);
    WanderController cb(Fixed64::fromInt(105), Fixed64::fromInt(68), &b);

    const auto v = makeView(Vec3{}, SlotId{1});
    (void)ca.decide(v, SlotId{1});
    (void)cb.decide(v, SlotId{1});
    FH_EXPECT_EQ(ca.target().x, cb.target().x);
    FH_EXPECT_EQ(ca.target().y, cb.target().y);
}

FH_TEST(idle_when_own_entity_missing) {
    RngDet rng(1);
    WanderController c(Fixed64::fromInt(105), Fixed64::fromInt(68), &rng);
    AwarenessView v;   // no entities
    const Intent i = c.decide(v, SlotId{1});
    FH_EXPECT_EQ(i.desired_direction.x, Fixed64::zero());
    FH_EXPECT_EQ(i.desired_direction.y, Fixed64::zero());
}

FH_TEST(retargets_after_dwell_expires) {
    RngDet rng(7);
    WanderController c(Fixed64::fromInt(105), Fixed64::fromInt(68), &rng);
    const auto v0 = makeView(Vec3{}, SlotId{1}, Fixed64::zero());
    (void)c.decide(v0, SlotId{1});
    const Vec3 first = c.target();

    // Jump time past max dwell (8s). Same starting position so distance
    // hasn't shrunk to zero — retarget must be triggered by the timer alone.
    const auto v1 = makeView(Vec3{}, SlotId{1}, Fixed64::fromInt(100));
    (void)c.decide(v1, SlotId{1});
    const Vec3 second = c.target();
    FH_EXPECT(first.x != second.x || first.y != second.y);
}

FH_TEST_MAIN()
