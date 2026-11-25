// game/tests/test_direct_opponent.cpp — ai/concepts/DirectOpponent: who is my man right now?
//
// Owner 11/24: "a direct opponent is normally 9 vs 4,5  10 v 6 2 v 7 11v3 8v8 but of course in
// the heat of battle you have to adjust to the ball area".
//
// Two 4-4-2s without keepers, numbered as the club's formations (2 RB, 3 LB, 4/5 CB, 6/8 centre,
// 7/11 wide, 9/10 up front). Team 0 (slots 0-9) defends x = -52.5 and does not have the ball;
// team 1 (slots 10-19) attacks it. World y: team 0's right is +y; team 1 is the same shape turned
// round, so its left is +y — their winger on +y faces our right-back.

#include "test_harness.hpp"
#include "ai/concepts/DirectOpponent.hpp"
#include "core/World.hpp"

#include <vector>

using namespace fh::game;
using fh::game::math::Fixed64;
using fh::game::math::Vec2;
using fh::game::math::Vec3;
namespace co = fh::game::ai::concepts;

namespace {

Vec3 at(int x, int y) { return Vec3{Fixed64::fromInt(x), Fixed64::fromInt(y), Fixed64::zero()}; }
const Vec2 kEast{Fixed64::one(), Fixed64::zero()};
const Fixed64 kGoal = Fixed64::fromFraction(-105, 2);
std::vector<std::uint8_t> teams() { std::vector<std::uint8_t> t(20, 0); for (int i = 10; i < 20; ++i) t[i] = 1; return t; }

struct Man { int num; int x, y; int by100; };   // his number, where he stands, his formation base y × 100
// Ours, defending deep: 2 RB 3 LB 4 5 CB · 7 11 wide · 6 8 centre · 9 10 up top.
const Man kOurs[10] = {{2, -38, 22, 80}, {4, -40, 6, 30}, {5, -40, -6, -30}, {3, -38, -22, -80},
                       {7, -25, 24, 85}, {6, -26, 6, 20}, {8, -26, -6, -20}, {11, -25, -24, -85},
                       {9, -12, 3, 10}, {10, -14, -3, -10}};
// Theirs, attacking: their 9 and 10 high, wide men on our flanks, centre mids, full-backs, centre-backs.
const Man kTheirs[10] = {{9, -34, 2, -10}, {10, -30, -4, 10}, {7, -30, 24, 85}, {11, -30, -24, -85},
                         {6, -18, -5, -20}, {8, -18, 5, 20}, {2, -8, -25, -80}, {3, -8, 25, 80},
                         {4, 2, -7, -30}, {5, 2, 7, 30}};

struct Pitch {
    core::World w{20, Fixed64::fromInt(7), Fixed64::fromFraction(105, 2), Fixed64::fromInt(34), 0};
    std::vector<std::uint8_t> team = teams();
    std::vector<std::int16_t> number = std::vector<std::int16_t>(20, 0);
    std::vector<Fixed64> base_y = std::vector<Fixed64>(20);
    std::vector<Vec2> place = std::vector<Vec2>(20);
    Pitch() {
        for (int i = 0; i < 20; ++i) {
            const Man& m = i < 10 ? kOurs[i] : kTheirs[i - 10];
            w.setTeam(static_cast<std::uint8_t>(i), team[i]);
            w.placePlayer(static_cast<std::uint8_t>(i), at(m.x, m.y), kEast);
            number[i] = static_cast<std::int16_t>(m.num);
            base_y[i] = Fixed64::fromFraction(m.by100, 100);
            place[i] = Vec2{Fixed64::fromInt(m.x), Fixed64::fromInt(m.y)};
        }
        ball(40, 0);   // the ball far away, with their centre-back: no battle near ours
    }
    void ball(int x, int y) { core::BallState b; b.pos = at(x, y); w.placeBall(b); }
    int slotOf(int team_no, int num) const { for (int i = 0; i < 20; ++i) if (team[i] == team_no && number[i] == num) return i; return -1; }
    void run(co::DirectOpponents& d) { d.assign(0, w, team, place, kGoal, number, base_y); }
};

int theirNum(const Pitch& p, const co::DirectOpponents& d, int our_num) {
    const int o = d.of(static_cast<core::SlotIndex>(p.slotOf(0, our_num)));
    return o < 0 ? -1 : p.number[o];
}

}  // namespace

// The matchup: 9 on their 4 or 5, 4 and 5 on their 9 (one marks, one spare), 10 on 6, 6 on 10,
// 8 on 8, and each full-back on the winger along his own touchline.
FH_TEST(the_matchup_by_number) {
    Pitch p;
    co::DirectOpponents d;
    p.run(d);
    const int n9 = theirNum(p, d, 9);
    FH_EXPECT(n9 == 4 || n9 == 5);
    FH_EXPECT_EQ(theirNum(p, d, 10), 6);
    FH_EXPECT_EQ(theirNum(p, d, 6), 10);
    FH_EXPECT_EQ(theirNum(p, d, 8), 8);
    const int on9 = (theirNum(p, d, 4) == 9) + (theirNum(p, d, 5) == 9);
    FH_EXPECT_EQ(on9, 1);                                      // one centre-back on their 9 …
    const int spare = d.spare(0);
    FH_EXPECT(spare == p.slotOf(0, 4) || spare == p.slotOf(0, 5));   // … the other is the spare man, the +1
    const int fm = d.freeMan(0);
    FH_EXPECT(fm == p.slotOf(1, 4) || fm == p.slotOf(1, 5));         // one of their centre-backs is free, the -1
}

// Wide men by touchline: our right-back (+y) takes the winger on +y, whatever number he wears.
FH_TEST(full_backs_take_the_winger_on_their_side) {
    Pitch p;
    co::DirectOpponents d;
    p.run(d);
    const int rb = d.of(static_cast<core::SlotIndex>(p.slotOf(0, 2))), lb = d.of(static_cast<core::SlotIndex>(p.slotOf(0, 3)));
    FH_EXPECT(rb >= 0 && p.w.player(static_cast<core::SlotIndex>(rb)).pos.y > Fixed64::zero());
    FH_EXPECT(lb >= 0 && p.w.player(static_cast<core::SlotIndex>(lb)).pos.y < Fixed64::zero());
    const int rw = d.of(static_cast<core::SlotIndex>(p.slotOf(0, 7)));
    FH_EXPECT(rw >= 0 && p.w.player(static_cast<core::SlotIndex>(rw)).pos.y > Fixed64::zero());   // our wide man on their full-back, same flank
    FH_EXPECT(d.how(static_cast<core::SlotIndex>(p.slotOf(0, 10))) == co::PairHow::Matchup);
}

// A matchup man is never "the nearest man on the other side of the pitch": their 6 drifts out
// wide left; our 10 still has him, he does not swap for whoever is nearest.
FH_TEST(the_matchup_holds_when_he_drifts) {
    Pitch p;
    co::DirectOpponents d;
    p.run(d);
    p.w.placePlayer(static_cast<std::uint8_t>(p.slotOf(1, 6)), at(-18, -15), kEast);
    p.run(d);
    FH_EXPECT_EQ(theirNum(p, d, 10), 6);
}

// The heat of battle: the ball on our right, by their left winger and their 8 who has pushed
// up. The men in that scene pair with who is there — our 7, coming back, takes their 8 beside
// him, not their full-back 30 m up the line.
FH_TEST(near_the_ball_the_battle_decides) {
    Pitch p;
    p.w.placePlayer(static_cast<std::uint8_t>(p.slotOf(1, 8)), at(-27, 20), kEast);   // their 8 in our right channel
    p.ball(-30, 26);
    co::DirectOpponents d;
    p.run(d);
    const int our7 = p.slotOf(0, 7);
    FH_EXPECT(d.how(static_cast<core::SlotIndex>(our7)) == co::PairHow::Battle);
    FH_EXPECT_EQ(theirNum(p, d, 7), 8);
    FH_EXPECT(d.how(static_cast<core::SlotIndex>(p.slotOf(0, 9))) == co::PairHow::Matchup);   // far from it, still the matchup
}

// The table decides: given only 10:6, our 10 has their 6 and our 8 (no pair) takes the nearest man left.
FH_TEST(the_table_is_the_matchup) {
    Pitch p;
    core::ModelParams mp;
    mp.setMilli("concept.direct.pair_10_6", 1000);
    co::DirectOpponents d;
    d.configure(mp);
    FH_EXPECT(d.partners(10, 6));
    FH_EXPECT(!d.partners(9, 4));
    p.run(d);
    FH_EXPECT_EQ(theirNum(p, d, 10), 6);
    FH_EXPECT(d.how(static_cast<core::SlotIndex>(p.slotOf(0, 8))) == co::PairHow::Nearest);
}

// With the ball, a side has no direct opponents.
FH_TEST(the_side_with_the_ball_has_none) {
    Pitch p;
    co::DirectOpponents d;
    p.run(d);
    d.clear(0, p.team);
    for (std::uint8_t s = 0; s < 10; ++s) FH_EXPECT_EQ(d.of(s), -1);
    FH_EXPECT_EQ(d.spare(0), -1);
}

FH_TEST_MAIN()
