// game/tests/test_player_attributes.cpp — G4.30 per-player attributes.
//
// levelForPlayer bends a band by one player's 0-100 attributes (50 = the
// band exactly, -1 = unrated); World/Brain take the result per slot and an
// unset slot keeps its team band, so band-only goldens can't move.

#include "test_harness.hpp"
#include "core/CanonicalHash.hpp"
#include "core/Levels.hpp"
#include "core/World.hpp"

using namespace fh::game;
using fh::game::math::Fixed64;

FH_TEST(unrated_player_is_his_band) {
    const auto band = core::levelParams("semipro");
    const auto lv = core::levelForPlayer(band, core::PlayerAttributes{});
    FH_EXPECT(lv.kick_angle_err_deg == band.kick_angle_err_deg);
    FH_EXPECT(lv.kick_power_err_pct == band.kick_power_err_pct);
    FH_EXPECT(lv.shot_angle_err_deg == -1);   // shots = kicks
    FH_EXPECT(lv.control_speed_mps == band.control_speed_mps);
    FH_EXPECT(lv.tackle_success_pct == band.tackle_success_pct);
    FH_EXPECT(lv.perception_delay_ticks == band.perception_delay_ticks);
    FH_EXPECT(lv.decision_jitter_pct == band.decision_jitter_pct);
    FH_EXPECT(lv.keeper_fumble_pct == band.keeper_fumble_pct);
}

FH_TEST(fifty_everywhere_is_the_band_exactly) {
    core::PlayerAttributes a;
    a.pace = a.passing = a.shooting = a.first_touch = a.tackling =
        a.anticipation = a.decisions = a.goalkeeping = 50;
    for (const char* name : {"u10", "amateur", "semipro", "world"}) {
        const auto band = core::levelParams(name);
        const auto lv = core::levelForPlayer(band, a);
        FH_EXPECT(lv.kick_angle_err_deg == band.kick_angle_err_deg);
        FH_EXPECT(lv.shot_angle_err_deg == band.kick_angle_err_deg);
        FH_EXPECT(lv.control_speed_mps == band.control_speed_mps);
        FH_EXPECT(lv.tackle_success_pct == band.tackle_success_pct);
        FH_EXPECT(lv.keeper_reaction_ticks == band.keeper_reaction_ticks);
    }
    FH_EXPECT(core::paceSpeedCms(50) == 640);
}

FH_TEST(ratings_bend_the_band_the_right_way) {
    const auto band = core::levelParams("amateur");  // {7,6,10,25,10,42,30,12,22}
    core::PlayerAttributes good, bad;
    good.passing = good.shooting = good.first_touch = good.tackling =
        good.anticipation = good.decisions = good.goalkeeping = 100;
    bad.passing = bad.shooting = bad.first_touch = bad.tackling =
        bad.anticipation = bad.decisions = bad.goalkeeping = 0;
    const auto g = core::levelForPlayer(band, good);
    const auto b = core::levelForPlayer(band, bad);
    FH_EXPECT(g.kick_angle_err_deg == 3 && b.kick_angle_err_deg == 9);    // x0.5 / x1.5
    FH_EXPECT(g.shot_power_err_pct == 5 && b.shot_power_err_pct == 15);
    FH_EXPECT(g.control_speed_mps == 13 && b.control_speed_mps == 8);    // x1.25 / x0.75
    FH_EXPECT(g.tackle_success_pct == 72 && b.tackle_success_pct == 12); // +/-30
    FH_EXPECT(g.perception_delay_ticks == 4 && b.perception_delay_ticks == 11);
    FH_EXPECT(g.keeper_fumble_pct == 11 && b.keeper_fumble_pct == 33);
    // A shooter who can't pass: shots tighten, passes don't.
    core::PlayerAttributes striker;
    striker.passing = 0;
    striker.shooting = 100;
    const auto s = core::levelForPlayer(band, striker);
    FH_EXPECT(s.kick_angle_err_deg == 9 && s.shot_angle_err_deg == 3);
    FH_EXPECT(core::paceSpeedCms(0) == 540 && core::paceSpeedCms(100) == 740);
}

FH_TEST(perfect_band_stays_perfect) {
    core::PlayerAttributes a;
    a.passing = a.tackling = a.first_touch = 0;
    const auto lv = core::levelForPlayer(core::levelParams("perfect"), a);
    FH_EXPECT(lv.kick_angle_err_deg == 0 && lv.control_speed_mps == 0 &&
              lv.tackle_success_pct == 0);
}

FH_TEST(world_slot_level_overrides_only_that_slot) {
    core::World w{4, Fixed64::fromInt(6), Fixed64::fromInt(52), Fixed64::fromInt(34)};
    const auto band = core::levelParams("semipro");
    w.setLevel(0, band);
    w.setLevel(1, band);
    const auto h0 = core::canonicalHash(w);
    FH_EXPECT(!w.hasSlotLevel(1));
    FH_EXPECT(w.levelOf(1).kick_angle_err_deg == band.kick_angle_err_deg);
    core::PlayerAttributes a;
    a.passing = 100;
    w.setSlotLevel(1, core::levelForPlayer(band, a));
    FH_EXPECT(w.hasSlotLevel(1) && !w.hasSlotLevel(2));
    FH_EXPECT(w.levelOf(1).kick_angle_err_deg == 2);   // (3*50+50)/100
    FH_EXPECT(w.levelOf(2).kick_angle_err_deg == band.kick_angle_err_deg);
    FH_EXPECT(core::canonicalHash(w) != h0);           // part of the run's identity
}

FH_TEST_MAIN()
