// game/tests/test_restarts.cpp — G5.2: the ball out of play is the officials'
// call. James: "we need out of bounds with throw ins. we need goal kicks and
// corner kicks. refs should call them." IFAB Laws 9, 11.3, 15, 16, 17.

#include "test_harness.hpp"
#include "core/World.hpp"

using namespace fh::game;
using core::Action;
using core::MatchEventType;
using fh::game::math::Fixed64;
using fh::game::math::Vec2;
using fh::game::math::Vec3;

namespace {
Vec3 at(int x, int y) { return Vec3{Fixed64::fromInt(x), Fixed64::fromInt(y), Fixed64::zero()}; }
const Vec2 kUp{Fixed64::zero(), Fixed64::one()}, kEast{Fixed64::one(), Fixed64::zero()};

// Slot 0 home on the ball, facing `f`; slot 1 home, slot 2 and 3 away, far off.
core::World pitch(const Vec3& p0, const Vec2& f) {
    core::World w{4, Fixed64::fromInt(7), Fixed64::fromInt(52), Fixed64::fromInt(34), 0};
    w.setTeam(0, 0); w.placePlayer(0, p0, f);
    w.setTeam(1, 0); w.placePlayer(1, at(-40, 0), kEast);
    w.setTeam(2, 1); w.placePlayer(2, at(-30, 20), kEast);
    w.setTeam(3, 1); w.placePlayer(3, at(-30, -20), kEast);
    w.giveBall(0);
    return w;
}

// Kick, then tick until the given event; false if it never comes.
bool until(core::World& w, MatchEventType t, std::uint8_t* team = nullptr, int cap = 300) {
    for (int i = 0; i < cap; ++i)
        for (const auto& e : w.tick())
            if (e.type == t) { if (team) *team = e.team; return true; }
    return false;
}
}  // namespace

FH_TEST(over_the_touchline_is_called_then_a_throw_for_the_other_team) {
    auto w = pitch(at(10, 33), kUp);
    w.setAction(0, Action::GroundKick);
    bool out = false;
    int after_out = 0, called_after = -1;
    for (int i = 0; i < 120 && called_after < 0; ++i) {
        const auto ev = w.tick();
        if (w.outStage() == 1) { out = true; ++after_out; FH_EXPECT_EQ(w.restartTeam(), 0xFF); }
        for (const auto& e : ev)
            if (e.type == MatchEventType::ThrowIn) { called_after = after_out; FH_EXPECT_EQ(e.team, 1); }
    }
    FH_EXPECT(out);
    // Play stopped first; the call came a beat later, not on the crossing.
    FH_EXPECT(called_after >= w.officials().callTicks() - 1);
    FH_EXPECT_EQ(w.restartTeam(), 1);
    FH_EXPECT(w.restartKind() == MatchEventType::ThrowIn);
    // Law 15: on the touchline where it crossed. +y in the +x half = assistant 1.
    FH_EXPECT(w.restartSpot().y == Fixed64::fromInt(34));
    FH_EXPECT_EQ(w.lastOutCall().official, 1);
    // Still out there until it's fetched, then on the spot.
    FH_EXPECT_EQ(w.outStage(), 2);
    FH_EXPECT(w.ball().pos.y > Fixed64::fromInt(34));
    for (std::uint32_t i = 0; i <= w.officials().retrieveTicks(); ++i) w.tick();
    FH_EXPECT_EQ(w.outStage(), 0);
    FH_EXPECT(w.ball().pos.y == Fixed64::fromInt(34));
}

FH_TEST(defenders_touch_over_their_line_is_a_corner_attackers_a_goal_kick) {
    {
        auto w = pitch(at(51, 20), kEast);   // home attacks +x: home last touch
        w.setAction(0, Action::GroundKick);
        std::uint8_t team = 9;
        FH_EXPECT(until(w, MatchEventType::GoalKick, &team));
        FH_EXPECT_EQ(team, 1);
        FH_EXPECT_EQ(w.lastOutCall().official, 1);
        // Law 16: inside the goal area, on the side it went out.
        FH_EXPECT(w.restartSpot().x == Fixed64::fromInt(47));
        FH_EXPECT(w.restartSpot().y == Fixed64::fromInt(6));
        FH_EXPECT_EQ(w.boxClearTeam(), 0);
    }
    {
        core::World w{4, Fixed64::fromInt(7), Fixed64::fromInt(52), Fixed64::fromInt(34), 0};
        w.setTeam(0, 1); w.placePlayer(0, at(51, -20), kEast);   // away defends +x
        w.setTeam(1, 1); w.setTeam(2, 0); w.setTeam(3, 0);
        w.placePlayer(1, at(0, 0), kEast); w.placePlayer(2, at(-10, 0), kEast); w.placePlayer(3, at(-20, 0), kEast);
        w.giveBall(0);
        w.setAction(0, Action::GroundKick);
        std::uint8_t team = 9;
        FH_EXPECT(until(w, MatchEventType::Corner, &team));
        FH_EXPECT_EQ(team, 0);
        // Law 17: in the arc nearest where it went out.
        FH_EXPECT(w.restartSpot().x == Fixed64::fromFraction(103, 2));
        FH_EXPECT(w.restartSpot().y == -Fixed64::fromFraction(67, 2));
    }
}

FH_TEST(a_man_who_dribbles_over_the_line_has_put_it_out) {
    auto w = pitch(at(10, 34), kUp);
    core::MoveIntent mv;
    mv.move = kUp;
    std::uint8_t team = 9;
    bool called = false;
    for (int i = 0; i < 90 && !called; ++i) {
        w.setIntent(0, mv);
        for (const auto& e : w.tick())
            if (e.type == MatchEventType::ThrowIn) { called = true; team = e.team; }
    }
    FH_EXPECT(called);
    FH_EXPECT_EQ(team, 1);
}

FH_TEST(a_dead_ball_waits_for_the_referee_and_stays_dead_until_played) {
    auto w = pitch(at(10, 33), kUp);
    w.setAction(0, Action::GroundKick);
    FH_EXPECT(until(w, MatchEventType::ThrowIn));
    while (w.outStage() != 0) w.tick();
    // Away's man stands on it: too early for anyone, and it's not his anyway.
    w.placePlayer(2, Vec3{w.restartSpot().x, Fixed64::fromInt(33), Fixed64::zero()}, kUp);
    w.placePlayer(3, Vec3{w.restartSpot().x, Fixed64::fromFraction(69, 2), Fixed64::zero()}, kUp);
    w.tick();
    FH_EXPECT(!w.ball().owner);
    FH_EXPECT(w.tickCount() < w.restartReadyTick());
    while (w.tickCount() < w.restartReadyTick()) w.tick();
    w.tick();
    // Now away's (it's away's throw): he has it in his hands, over his head,
    // dead, on the line, and can't walk off with it.
    FH_EXPECT(w.ball().owner.has_value());
    const std::uint8_t taker = *w.ball().owner;
    FH_EXPECT_EQ(w.player(taker).team, 1);
    FH_EXPECT_EQ(w.restartTeam(), 1);
    FH_EXPECT(w.takingThrow(taker));
    w.tick();
    FH_EXPECT(w.ball().pos.z == core::kThrowHeight);
    const Vec3 stood = w.player(taker).pos;
    core::MoveIntent mv;
    mv.move = Vec2{-Fixed64::one(), Fixed64::zero()};
    w.setIntent(taker, mv);
    for (int i = 0; i < 5; ++i) w.tick();
    FH_EXPECT(w.player(taker).pos.x == stood.x);
    // Nobody can take it off him: home's man touch-tight for a second.
    w.placePlayer(0, w.player(taker).pos, kEast);
    for (int i = 0; i < 30; ++i) w.tick();
    FH_EXPECT_EQ(*w.ball().owner, taker);
    // Pressed PASS: it's a throw, in the air, and now it's live.
    while (w.tickCount() < w.ownedAtTick() + 30) w.tick();
    mv.move = Vec2{Fixed64::zero(), -Fixed64::one()};
    w.setIntent(taker, mv);
    w.setAction(taker, Action::ShortPass);
    w.tick();
    FH_EXPECT(!w.ball().owner);
    FH_EXPECT_EQ(w.restartTeam(), 0xFF);
    FH_EXPECT(w.ball().pos.z > Fixed64::one());
    FH_EXPECT(w.ball().vel.z > Fixed64::zero());
    FH_EXPECT(w.ball().vel.y < Fixed64::zero());
}

FH_TEST(no_offside_from_a_throw_goal_kick_or_corner) {
    // Law 11.3: taker on the ball, a mate miles offside.
    core::World w{4, Fixed64::fromInt(7), Fixed64::fromInt(52), Fixed64::fromInt(34), 0};
    w.setTeam(0, 0); w.setTeam(1, 0); w.setTeam(2, 1); w.setTeam(3, 1);
    w.placePlayer(0, at(10, 34), kEast);
    w.placePlayer(1, at(48, 0), kEast);
    w.placePlayer(2, at(20, 0), kEast);
    w.placePlayer(3, at(30, 0), kEast);
    w.setDeadBall(MatchEventType::ThrowIn, 0, at(10, 34));
    w.tick();
    FH_EXPECT(w.ball().owner.has_value());
    while (w.tickCount() < w.ownedAtTick() + 30) w.tick();
    core::MoveIntent mv;
    mv.move = Vec2{Fixed64::one(), -Fixed64::one()};
    w.setIntent(0, mv);
    w.setAction(0, Action::ShortPass);
    w.tick();
    FH_EXPECT(!w.ball().owner);
    FH_EXPECT_EQ(w.offsideMask(), 0u);
    FH_EXPECT_EQ(w.offsideTeam(), 0xFF);
}

FH_TEST(each_line_belongs_to_one_official) {
    using core::Officials;
    auto v = [](int x, int y) { return Vec2{Fixed64::fromInt(x), Fixed64::fromInt(y)}; };
    FH_EXPECT_EQ(Officials::officialFor(v(52, 5), true), 1);
    FH_EXPECT_EQ(Officials::officialFor(v(-52, 5), true), 2);
    FH_EXPECT_EQ(Officials::officialFor(v(10, 34), false), 1);
    FH_EXPECT_EQ(Officials::officialFor(v(-10, 34), false), 0);    // the far half: the referee's
    FH_EXPECT_EQ(Officials::officialFor(v(-10, -34), false), 2);
    FH_EXPECT_EQ(Officials::officialFor(v(10, -34), false), 0);
}

FH_TEST(a_ball_off_a_man_can_be_given_the_wrong_way_a_clean_one_never) {
    auto w = pitch(at(10, 33), kUp);
    core::ModelParams p;
    p.setMilli("official.restart.wrong_pct_per_10m", 1000000);
    p.setMilli("official.restart.wrong_pct_max", 100000);
    w.officials().configure(p);
    const Vec2 crossed{Fixed64::fromInt(10), Fixed64::fromInt(35)};
    const Vec2 touch{Fixed64::fromInt(-40), Fixed64::zero()};
    const auto clean = w.officials().judgeOutOfPlay(w, crossed, false, false, touch, 0, 1);
    FH_EXPECT_EQ(clean.called, 0);
    const auto off = w.officials().judgeOutOfPlay(w, crossed, false, true, touch, 0, 1);
    FH_EXPECT_EQ(off.truth, 0);
    FH_EXPECT_EQ(off.called, 1);
}

FH_TEST_MAIN()
