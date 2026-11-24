// game/tests/test_teaching_room.cpp
//
// The teaching room (docs/teaching-room.md): a GameServer child that places one side by a
// club tactic plan. No database here — the plan is built by hand.

#include "test_harness.hpp"
#include "server/Rooms.hpp"
#include "teach/TeachingPlan.hpp"
#include "teach/TeachingServer.hpp"

#include <cmath>

using namespace fh::game;

namespace {

class NullTransport final : public net::INetworkTransport {
public:
    void setOnConnect(OnConnectFn) override {}
    void setOnDisconnect(OnDisconnectFn) override {}
    void setOnMessage(OnMessageFn) override {}
    bool send(ClientId, std::span<const std::uint8_t>) override { return true; }
    void disconnect(ClientId) override {}
    std::size_t clientCount() const override { return 0; }
    void poll(int) override {}
};

// Both sides in the built-in eleven, numbered 1-11 by slot; every outfielder of ours marks
// their man of his own number, 2 m goal-side.
teach::Plan manForMan() {
    teach::Plan p;
    p.id = 1;
    p.us = p.them = ai::builtinFormation(11);
    for (int i = 0; i < 11; ++i) {
        p.us.positions[i].number = p.them.positions[i].number = static_cast<std::int16_t>(i + 1);
        const auto& b = p.us.positions[i].base;   // base.x -1 … 0 up the pitch, base.y -1 … 1 across
        p.frame.home[i + 1] = {50.0 + b.y.toDouble() * 50.0, 100.0 + b.x.toDouble() * 100.0};
    }
    p.frame.kinds["mark"] = {"mark", "mark", 2.0, std::nullopt, std::nullopt};
    p.concepts["mark"] = {18, "man-mark", "Man-mark"};
    teach::PlanState root;
    root.id = 1;
    root.ball_with = 1;
    for (int n = 2; n <= 11; ++n) {
        fh::tactics::Job j;
        j.position = n;
        j.kind = "mark";
        j.targets = {n};
        root.jobs.push_back(j);
    }
    p.states.push_back(root);
    teach::PlanState to4 = root;   // ball to their 4: the same jobs, a step of its own
    to4.id = 2;
    to4.parent = 1;
    to4.ball_with = 4;
    p.states.push_back(to4);
    return p;
}

}  // namespace

FH_TEST(teach_link_parses) {
    const auto a = server::parsePracticeAsk("/game?trainer=1&teach=16&home=Arsenal&away=Chelsea");
    FH_EXPECT(a.has_value() && a->teach_plan == 16);
    const auto b = server::parsePracticeAsk("/game?trainer=1");
    FH_EXPECT(b.has_value() && b->teach_plan == 0);
    FH_EXPECT(!server::parsePracticeAsk("/game?teach=16").has_value());   // a room is asked for with trainer=1
}

FH_TEST(plan_steps_follow_the_ball) {
    const teach::Plan p = manForMan();
    FH_EXPECT(p.next(p.root(), 4) == &p.states[1]);
    FH_EXPECT(p.next(&p.states[1], 1) == p.root());   // back to their keeper: the root again
    FH_EXPECT(p.next(p.root(), 9) == nullptr);        // no step drawn: the jobs stand
}

FH_TEST(teaching_room_puts_our_men_on_their_jobs) {
    NullTransport t;
    server::GameServer::Config cfg;
    cfg.slot_count = 22;
    cfg.match_seed = 7;
    teach::TeachingServer s{cfg, t, manForMan(), 0};
    FH_EXPECT_EQ(s.speedPct(), 0);                 // frozen on their goal kick, as any practice room
    FH_EXPECT_EQ(s.world().restartTeam(), 1);
    FH_EXPECT_EQ(s.stateId(), 1);
    // Our outfielders are on their plan jobs, and each one's target is 2 m from his man (or
    // held outside their area by Law 16), not the engine's block spot.
    int on_job = 0, on_man = 0;
    const auto& w = s.world();
    for (std::uint8_t i = 1; i < 11; ++i) {
        if (!s.onJob(i)) continue;
        ++on_job;
        const auto& o = s.lastOrders()[i];
        FH_EXPECT_EQ(o.other, static_cast<std::int16_t>(11 + i));   // the man his job names
        const auto& him = w.player(static_cast<std::uint8_t>(11 + i)).pos;
        const double d = std::hypot(o.target.x.toDouble() - him.x.toDouble(), o.target.y.toDouble() - him.y.toDouble());
        if (d > 1.5 && d < 2.5) ++on_man;
    }
    FH_EXPECT(on_job >= 8);
    FH_EXPECT(on_man >= 6);
    // Their side is the engine's own: played on, the keeper takes his goal kick.
    bool live = false;
    for (int i = 0; i < 600 && !live; ++i) { s.tickOnce(); live = s.world().restartTeam() == 0xFF; }
    FH_EXPECT(live);
}

FH_TEST_MAIN()
