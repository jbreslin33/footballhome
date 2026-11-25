// game/tests/test_machines.cpp — ai/concepts/Machines: a player's concept machines, each in one
// state, asleep ("nothing to do") until it has something to do, several awake at once.

#include "test_harness.hpp"
#include "ai/concepts/Machines.hpp"

using namespace fh::game;
using fh::game::math::Fixed64;
using fh::game::math::Vec2;
namespace co = fh::game::ai::concepts;

namespace {
Vec2 v(int x, int y) { return Vec2{Fixed64::fromInt(x), Fixed64::fromInt(y)}; }
co::MachineSense defending(co::Job job) { co::MachineSense s; s.job = job; s.their_ball = true; return s; }
}  // namespace

// The marking scheme: asleep with our ball; zonal while the block has him marking; watching his
// direct opponent otherwise; free (the spare man) with nobody.
FH_TEST(marking_scheme_states) {
    co::PlayerMachines m;
    co::MachineSense s;  // our ball
    s.job = co::Job::Hold;
    m.update(0, s, 0);
    FH_EXPECT_EQ(m.of(0, co::MachineId::Marking).state, co::marking::Asleep);
    s = defending(co::Job::Mark); s.mark = 14; s.direct = 14;
    m.update(1, s, 0);
    FH_EXPECT_EQ(m.of(1, co::MachineId::Marking).state, co::marking::Zonal);
    FH_EXPECT_EQ(m.of(1, co::MachineId::Marking).other, 14);
    s = defending(co::Job::Hold); s.direct = 12;
    m.update(2, s, 0);
    FH_EXPECT_EQ(m.of(2, co::MachineId::Marking).state, co::marking::Watching);
    s = defending(co::Job::Hold);
    m.update(3, s, 0);
    FH_EXPECT_EQ(m.of(3, co::MachineId::Marking).state, co::marking::Free);
}

// Pressing distance is ON the whole time his side defends and he has a man; it STEPS only when
// he holds his place, his man is out of reach AND a side has the dial on. With no dial it never
// steps, and its proposal moves nothing — the sim as it was.
FH_TEST(pressing_distance_on_while_defending_steps_only_with_the_dial) {
    co::PlayerMachines m;
    co::MachineSense s = defending(co::Job::Hold);
    s.direct = 15; s.step = v(3, 0);
    m.update(0, s, 0);
    FH_EXPECT_EQ(m.of(0, co::MachineId::PressingDistance).state, co::pdist::On);
    FH_EXPECT_EQ(m.of(0, co::MachineId::PressingDistance).other, 15);
    Vec2 t = v(-30, 0);
    FH_EXPECT(!m.bendHold(0, s.step, Fixed64::one(), t));
    FH_EXPECT(t.x == Fixed64::fromInt(-30));
    s.press_hold = Fixed64::one();
    m.update(0, s, 1);
    FH_EXPECT_EQ(m.of(0, co::MachineId::PressingDistance).state, co::pdist::Stepping);
    FH_EXPECT(m.bendHold(0, s.step, Fixed64::fromFraction(1, 2), t));
    FH_EXPECT(t.x == Fixed64::fromFraction(-57, 2));   // half the 3 m step
}

// Commitment: awake, a machine stays awake hold_ticks even if the reason blinks away — but it
// leaves at once when what it lives in has gone (he stopped holding his place).
FH_TEST(an_awake_machine_is_committed_but_leaves_with_its_state) {
    co::PlayerMachines m;
    co::MachineSense s = defending(co::Job::Hold);
    s.direct = 15; s.step = v(3, 0); s.press_hold = Fixed64::one();
    m.update(0, s, 100);
    s.step = v(0, 0);                       // in reach for one tick
    m.update(0, s, 101);
    FH_EXPECT(m.awake(0, co::MachineId::PressingDistance));
    m.update(0, s, 100 + m.params().hold_ticks);
    FH_EXPECT_EQ(m.of(0, co::MachineId::PressingDistance).state, co::pdist::On);   // back to just on
    s.step = v(3, 0);
    m.update(0, s, 200);
    s.job = co::Job::Press;                 // he became the presser: pressing distance is not his business now
    m.update(0, s, 201);
    FH_EXPECT(!m.awake(0, co::MachineId::PressingDistance));
    s.job = co::Job::Hold; s.their_ball = false;   // our ball: asleep
    m.update(0, s, 300);
    FH_EXPECT(!m.awake(0, co::MachineId::PressingDistance));
}

// The cover shadow: someone hidden behind him just from where he stands is HIDING (passive); the
// presser with the dial on and a receiver to hide is ON THE LANE, and bends onto it.
FH_TEST(cover_shadow_hiding_and_on_the_lane) {
    co::PlayerMachines m;
    co::MachineSense s = defending(co::Job::Hold);
    s.hidden = 1u << 17;
    m.update(0, s, 0);
    FH_EXPECT_EQ(m.of(0, co::MachineId::CoverShadow).state, co::shadow::Hiding);
    FH_EXPECT_EQ(m.of(0, co::MachineId::CoverShadow).other, 17);
    s = defending(co::Job::Press); s.screen = 16;
    m.update(1, s, 0);
    FH_EXPECT_EQ(m.of(1, co::MachineId::CoverShadow).state, co::shadow::Asleep);   // no dial: he presses goal-side as fitted
    s.shadow_press = Fixed64::one();
    m.update(1, s, 1);
    FH_EXPECT_EQ(m.of(1, co::MachineId::CoverShadow).state, co::shadow::OnTheLane);
    // Carrier at the origin, receiver 12 m up the touchline (+y), stand-off 3 m: onto (0, 3).
    Vec2 t = v(-3, 0);
    FH_EXPECT(m.bendPress(1, v(0, 0), Fixed64::fromInt(3), v(0, 12), Fixed64::one(), t));
    FH_EXPECT(t.x == Fixed64::zero() && t.y == Fixed64::fromInt(3));
}

// Two machines awake at once: the presser hiding a man (cover shadow) while his marking scheme
// says he is watching his direct opponent.
FH_TEST(several_awake_at_once) {
    co::PlayerMachines m;
    co::MachineSense s = defending(co::Job::Press);
    s.direct = 13; s.screen = 16; s.shadow_press = Fixed64::one();
    m.update(0, s, 0);
    FH_EXPECT(m.awake(0, co::MachineId::CoverShadow));
    FH_EXPECT(m.awake(0, co::MachineId::Marking));
}

// The second five follow what the engine is doing: the presser's PRESS machine is on his carrier,
// the loose ball's man is GOING, the second man DOUBLE-TEAMS, the deeper centre-back COVERS, and a
// man whose place is behind him RECOVERS — each asleep otherwise.
FH_TEST(press_loose_ball_double_team_cover_recover) {
    co::PlayerMachines m;
    co::MachineSense s = defending(co::Job::Press); s.carrier = 18;
    m.update(0, s, 0);
    FH_EXPECT_EQ(m.of(0, co::MachineId::Press).state, co::press::Closing);
    FH_EXPECT_EQ(m.of(0, co::MachineId::Press).other, 18);
    s.job = co::Job::Hold;
    m.update(0, s, 1);
    FH_EXPECT(!m.awake(0, co::MachineId::Press));            // leaves with his job: no commitment needed
    s = defending(co::Job::Chase);
    m.update(1, s, 0);
    FH_EXPECT(m.awake(1, co::MachineId::LooseBall));
    s = defending(co::Job::DoubleTeam); s.carrier = 16;
    m.update(2, s, 0);
    FH_EXPECT_EQ(m.of(2, co::MachineId::DoubleTeam).other, 16);
    s = defending(co::Job::Hold); s.cover = true; s.behind = true;
    m.update(3, s, 0);
    FH_EXPECT(m.awake(3, co::MachineId::Cover));
    FH_EXPECT(m.awake(3, co::MachineId::Recover));             // two at once: covering AND getting back
    s.their_ball = false;
    m.update(3, s, 1);
    FH_EXPECT(!m.awake(3, co::MachineId::Cover) && !m.awake(3, co::MachineId::Recover));
}

// Marking a man the block gave him: that man is his man for pressing distance too.
FH_TEST(pressing_distance_follows_the_man_he_marks) {
    co::PlayerMachines m;
    co::MachineSense s = defending(co::Job::Mark);
    s.mark = 19; s.direct = -1;
    m.update(0, s, 0);
    FH_EXPECT_EQ(m.of(0, co::MachineId::PressingDistance).state, co::pdist::On);
    FH_EXPECT_EQ(m.of(0, co::MachineId::PressingDistance).other, 19);
}

// The resolver, and the first machine that takes his spot: with the line broken behind him and his
// man out of reach (dial on), RECOVER wins over pressing distance (machine_order) — straight back to
// his place, no bend to his man. Back on the line, recover sleeps and pressing distance bends again.
FH_TEST(recover_outranks_pressing_distance) {
    co::PlayerMachines m;
    co::MachineSense s = defending(co::Job::Hold);
    s.direct = 15; s.step = v(3, 0); s.press_hold = Fixed64::one(); s.behind = true;
    m.update(0, s, 0);
    FH_EXPECT(m.awake(0, co::MachineId::Recover));
    FH_EXPECT_EQ(m.of(0, co::MachineId::PressingDistance).state, co::pdist::Stepping);   // both awake
    bool driving = false;
    FH_EXPECT(m.driver(0, driving) == co::MachineId::Recover && driving);
    Vec2 t = v(10, 4);
    FH_EXPECT(m.recoverTo(0, v(10, 4), t));
    FH_EXPECT(!m.bendHold(0, s.step, Fixed64::one(), t));    // they fight: recover wins
    FH_EXPECT_EQ(t.x.raw, Fixed64::fromInt(10).raw);
    s.behind = false;
    m.update(0, s, 100);                                     // back, past the commitment
    FH_EXPECT(!m.awake(0, co::MachineId::Recover));
    FH_EXPECT(!m.recoverTo(0, v(10, 4), t));
    FH_EXPECT(m.bendHold(0, s.step, Fixed64::one(), t));
    FH_EXPECT_EQ(t.x.raw, Fixed64::fromInt(13).raw);
}

// The engine's order is the agreed one (copy row machine_order: recover,press,chase,double,mark,shadow,cover,pdist).
FH_TEST(priority_is_machine_order) {
    FH_EXPECT_EQ(co::rankOf(co::MachineId::Recover), 0);
    FH_EXPECT_EQ(co::rankOf(co::MachineId::Press), 1);
    FH_EXPECT_EQ(co::rankOf(co::MachineId::LooseBall), 2);
    FH_EXPECT_EQ(co::rankOf(co::MachineId::DoubleTeam), 3);
    FH_EXPECT_EQ(co::rankOf(co::MachineId::Marking), 4);
    FH_EXPECT_EQ(co::rankOf(co::MachineId::CoverShadow), 5);
    FH_EXPECT_EQ(co::rankOf(co::MachineId::Cover), 6);
    FH_EXPECT_EQ(co::rankOf(co::MachineId::PressingDistance), 7);
}

FH_TEST_MAIN()
