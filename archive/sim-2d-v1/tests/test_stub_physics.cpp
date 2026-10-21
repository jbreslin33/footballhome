// footballhome sim - StubPhysics tests

#include "physics/IPhysicsWorld.hpp"
#include "physics/StubPhysics.hpp"
#include "common/EntityState.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

#include <algorithm>

using fh::sim::EntityId;
using fh::sim::MotionState;
using fh::sim::SlotId;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::physics::EntityDef;
using fh::sim::physics::StubPhysics;

FH_TEST(spawn_and_get) {
    StubPhysics p;
    EntityDef def;
    def.slot_id  = SlotId{7};
    def.position = Vec3{Fixed64::fromInt(1), Fixed64::fromInt(2), Fixed64::zero()};
    def.velocity = Vec3{};
    def.radius   = Fixed64::zero();
    def.height   = Fixed64::zero();
    def.is_ball  = false;

    const EntityId id = p.spawn(def);
    FH_EXPECT(p.contains(id));
    FH_EXPECT_EQ(p.size(), 1u);

    const auto s = p.get(id);
    FH_EXPECT_EQ(s.id, id);
    FH_EXPECT_EQ(s.slot_id, SlotId{7});
    FH_EXPECT_EQ(s.position.x, Fixed64::fromInt(1));
    FH_EXPECT_EQ(s.position.y, Fixed64::fromInt(2));
}

FH_TEST(step_integrates_velocity) {
    StubPhysics p;
    EntityDef def;
    def.slot_id  = SlotId{1};
    def.position = Vec3{};
    def.velocity = Vec3{Fixed64::fromInt(4),
                        Fixed64::fromInt(-2),
                        Fixed64::zero()};
    const EntityId id = p.spawn(def);

    // dt = 1/20 s. Use the same expression Physics uses so we match its
    // fixed-point rounding exactly (fromFraction(1,5) != 4 * fromFraction(1,20)
    // at the raw-bits level; the last few LSBs drift by truncation).
    const Fixed64 dt   = Fixed64::fromFraction(1, 20);
    const Fixed64 expX = Fixed64::fromInt(4)  * dt;
    const Fixed64 expY = Fixed64::fromInt(-2) * dt;
    p.step(dt);
    const auto s = p.get(id);
    FH_EXPECT_EQ(s.position.x, expX);
    FH_EXPECT_EQ(s.position.y, expY);
    FH_EXPECT_EQ(s.position.z, Fixed64::zero());
}

FH_TEST(all_is_sorted_ascending) {
    StubPhysics p;
    EntityDef def;
    def.slot_id = SlotId{1};
    p.spawn(def);
    def.slot_id = SlotId{2};
    p.spawn(def);
    def.slot_id = SlotId{3};
    p.spawn(def);

    const auto ids = p.all();
    FH_EXPECT_EQ(ids.size(), 3u);
    FH_EXPECT(std::is_sorted(ids.begin(), ids.end()));
}

FH_TEST(despawn_removes_only_target) {
    StubPhysics p;
    EntityDef def;
    def.slot_id = SlotId{10};
    const EntityId a = p.spawn(def);
    def.slot_id = SlotId{11};
    const EntityId b = p.spawn(def);

    p.despawn(a);
    FH_EXPECT(!p.contains(a));
    FH_EXPECT(p.contains(b));
    FH_EXPECT_EQ(p.size(), 1u);
}

FH_TEST(set_velocity_heading_motion_roundtrip) {
    StubPhysics p;
    EntityDef def;
    def.slot_id = SlotId{1};
    const EntityId id = p.spawn(def);

    p.setVelocity(id, Vec3{Fixed64::fromInt(3), Fixed64::zero(), Fixed64::zero()});
    p.setHeading (id, Fixed64::fromFraction(1, 2));
    p.setMotion  (id, MotionState::Sprint);

    const auto s = p.get(id);
    FH_EXPECT_EQ(s.velocity.x, Fixed64::fromInt(3));
    FH_EXPECT_EQ(s.heading,    Fixed64::fromFraction(1, 2));
    FH_EXPECT(s.motion == MotionState::Sprint);
}

FH_TEST_MAIN()
