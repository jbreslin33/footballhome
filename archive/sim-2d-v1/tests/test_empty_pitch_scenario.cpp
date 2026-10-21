// footballhome sim - EmptyPitchScenario tests

#include "scenario/EmptyPitchScenario.hpp"
#include "awareness/AwarenessView.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

#include <algorithm>
#include <cstdint>
#include <set>
#include <string>

using fh::sim::SlotId;
using fh::sim::awareness::WorldView;
using fh::sim::math::Fixed64;
using fh::sim::scenario::EmptyPitchScenario;

FH_TEST(pitch_is_regulation) {
    EmptyPitchScenario s;
    const auto p = s.pitch();
    FH_EXPECT_EQ(p.length_m, Fixed64::fromInt(105));
    FH_EXPECT_EQ(p.width_m,  Fixed64::fromInt(68));
}

FH_TEST(twelve_slots_default) {
    EmptyPitchScenario s;
    const auto spawns = s.initialSpawns();
    FH_EXPECT_EQ(spawns.size(), 12u);

    // Slot IDs are 1-based and unique.
    std::set<std::uint16_t> ids;
    for (const auto& sp : spawns) {
        FH_EXPECT_GE(sp.slot, SlotId{1});
        FH_EXPECT_LE(sp.slot, SlotId{12});
        ids.insert(static_cast<std::uint16_t>(sp.slot));
    }
    FH_EXPECT_EQ(ids.size(), 12u);
}

FH_TEST(no_ball_in_m0) {
    EmptyPitchScenario s;
    FH_EXPECT(!s.ballSpawn().has_value());
}

FH_TEST(success_and_reset_always_false) {
    EmptyPitchScenario s;
    WorldView w;
    FH_EXPECT(!s.checkSuccess(w));
    FH_EXPECT(!s.checkReset(w));
}

FH_TEST(id_and_display_name) {
    EmptyPitchScenario s;
    FH_EXPECT_EQ(std::string(s.id()),          std::string("empty_pitch"));
    FH_EXPECT_EQ(std::string(s.displayName()), std::string("Empty Pitch"));
}

FH_TEST(spawns_fit_inside_pitch) {
    EmptyPitchScenario s;
    const auto p       = s.pitch();
    const Fixed64 halfL = p.length_m * Fixed64::fromFraction(1, 2);
    const Fixed64 halfW = p.width_m  * Fixed64::fromFraction(1, 2);
    for (const auto& sp : s.initialSpawns()) {
        FH_EXPECT_GE(sp.position.x, -halfL);
        FH_EXPECT_LE(sp.position.x,  halfL);
        FH_EXPECT_GE(sp.position.y, -halfW);
        FH_EXPECT_LE(sp.position.y,  halfW);
    }
}

FH_TEST_MAIN()
