// footballhome sim - HumanController tests

#include "controller/HumanController.hpp"
#include "controller/Intent.hpp"
#include "awareness/AwarenessView.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

#include <string>

using fh::sim::ClientId;
using fh::sim::SlotId;
using fh::sim::awareness::AwarenessView;
using fh::sim::controller::HumanController;
using fh::sim::controller::Intent;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;

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
}

FH_TEST(returns_latest_input_verbatim) {
    HumanController c{ClientId{1}};
    Intent in;
    in.desired_direction = Vec3{Fixed64::fromInt(1), Fixed64::zero(), Fixed64::zero()};
    in.wants_sprint = true;
    c.updateInput(in);

    AwarenessView v;
    const Intent out = c.decide(v, SlotId{1});
    FH_EXPECT_EQ(out.desired_direction.x, Fixed64::fromInt(1));
    FH_EXPECT(out.wants_sprint);
    FH_EXPECT(!out.wants_walk);
}

FH_TEST(kind_string) {
    HumanController c{ClientId{1}};
    FH_EXPECT_EQ(std::string(c.kind()), std::string("human"));
}

FH_TEST_MAIN()
