// game/tests/test_marking.cpp — ai/concepts/Marking: recognise → choose → execute.
//
// A marker defends the goal at -x (sg = +1). Slot 0 is the marker, slot 1 his man.

#include "test_harness.hpp"
#include "ai/concepts/Marking.hpp"
#include "core/World.hpp"
#include "net/INetworkTransport.hpp"
#include "server/GameServer.hpp"

using namespace fh::game;
using fh::game::math::Fixed64;
using fh::game::math::Vec2;
using fh::game::math::Vec3;
namespace mk = fh::game::ai::concepts;

namespace {

Vec3 at(int x, int y) { return Vec3{Fixed64::fromInt(x), Fixed64::fromInt(y), Fixed64::zero()}; }
const Vec2 kEast{Fixed64::one(), Fixed64::zero()};

core::World pitch(Vec3 marker, Vec3 man, Vec3 ball) {
    core::World w{2, Fixed64::fromInt(7), Fixed64::fromFraction(105, 2), Fixed64::fromInt(34), 0};
    w.setTeam(0, 0); w.placePlayer(0, marker, kEast);
    w.setTeam(1, 1); w.placePlayer(1, man, kEast);
    core::BallState b;
    b.pos = ball;
    w.placeBall(b);
    return w;
}

}  // namespace

// Ball and man in front of him: he sees both and stands goal-side of his man.
FH_TEST(marker_sees_both_and_stands_goal_side) {
    core::World w = pitch(at(0, 0), at(5, 0), at(20, 0));
    mk::MarkingMind mind{mk::MarkKind::ManOriented, 1, Vec2{}};
    const mk::MarkView v = mind.think(w, 0, Fixed64::one());
    FH_EXPECT(v.eyes == mk::Eyes::Both);
    FH_EXPECT(v.sees_man && v.sees_ball);
    FH_EXPECT(v.step == mk::MarkStep::Position);
    FH_EXPECT(v.target.x < Fixed64::fromInt(5));               // between his man and our goal
    FH_EXPECT(v.target.x > Fixed64::fromInt(2));               // and close to him
}

// His man behind him, the ball in front: he cannot see both. Watching the ball, his picture
// of his man is where he LAST saw him — a move made behind his back is not known until he
// looks over his shoulder.
FH_TEST(a_run_on_his_blind_side_is_seen_late) {
    core::World w = pitch(at(0, 0), at(-8, 0), at(20, 0));
    mk::MarkingMind mind{mk::MarkKind::ManOriented, 1, Vec2{}};
    int looked_at_man = 0, looked_at_ball = 0;
    bool moved = false, stale_seen = false, caught_up = false;
    for (int i = 0; i < 80; ++i) {
        const mk::MarkView v = mind.think(w, 0, Fixed64::one());
        FH_EXPECT(v.eyes != mk::Eyes::Both);
        if (v.eyes == mk::Eyes::Man) ++looked_at_man; else ++looked_at_ball;
        if (!moved && v.eyes == mk::Eyes::Ball && i > 12) {     // he is watching the ball: his man goes
            w.placePlayer(1, at(-8, 12), kEast);
            moved = true;
        } else if (moved && !caught_up) {
            const bool knows = mind.memory().man.pos.y > Fixed64::fromInt(6);
            if (!knows && v.eyes == mk::Eyes::Ball) stale_seen = true;   // still thinks he is where he was
            if (knows) caught_up = true;
        }
        w.tick();
    }
    FH_EXPECT(looked_at_man > 0 && looked_at_ball > looked_at_man);   // mostly the ball, a look at his man
    FH_EXPECT(moved && stale_seen);                                    // for a while he did not know
    FH_EXPECT(caught_up);                                              // his next look found him
}

// The same steps, one rule different: zonal passes his man on when he leaves the zone,
// man-oriented goes after him.
FH_TEST(zonal_passes_him_on_man_oriented_follows) {
    for (const mk::MarkKind kind : {mk::MarkKind::Zonal, mk::MarkKind::ManOriented}) {
        core::World w = pitch(at(0, 0), at(20, 0), at(30, 0));          // his man 20 m from the marker's own spot
        mk::MarkingMind mind{kind, 1, Vec2{}};
        mk::MarkView v;
        for (int i = 0; i < 20; ++i) { v = mind.think(w, 0, Fixed64::one()); w.tick(); }
        if (kind == mk::MarkKind::Zonal) {
            FH_EXPECT(v.step == mk::MarkStep::PassOn);
            FH_EXPECT(v.target.x == Fixed64::zero());                    // back to his own spot
        } else {
            FH_EXPECT(v.step == mk::MarkStep::PickUp);
            FH_EXPECT(v.target.x > Fixed64::fromInt(10));                // after his man
        }
    }
}

// Every option is weighed each tick and kept for the viewer: the cue, and the score.
FH_TEST(options_are_kept_for_the_viewer) {
    core::World w = pitch(at(0, 0), at(5, 0), at(20, 0));
    mk::MarkingMind mind{mk::MarkKind::ManOriented, 1, Vec2{}};
    const mk::MarkView v = mind.think(w, 0, Fixed64::one());
    FH_EXPECT(v.options[static_cast<int>(mk::MarkStep::Position)].cue);
    FH_EXPECT(v.options[static_cast<int>(mk::MarkStep::Position)].score > 0);
    FH_EXPECT(!v.options[static_cast<int>(mk::MarkStep::JumpPass)].cue);
    FH_EXPECT_EQ(v.options[static_cast<int>(mk::MarkStep::JumpPass)].score, 0);
}

// The sim can select it: physics.mark.mind = 1 makes DefendingBlock's markers run the mind.
// Off (no row) the match is the match as fitted; on, it runs and plays differently.
FH_TEST(the_sim_can_use_the_mind_and_is_unchanged_without_it) {
    class Null final : public net::INetworkTransport {
    public:
        void setOnConnect(OnConnectFn) override {}
        void setOnDisconnect(OnDisconnectFn) override {}
        void setOnMessage(OnMessageFn) override {}
        bool send(fh::game::ClientId, std::span<const std::uint8_t>) override { return true; }
        void disconnect(fh::game::ClientId) override {}
        std::size_t clientCount() const override { return 0; }
        void poll(int) override {}
    };
    auto run = [](bool mind) {
        Null t;
        server::GameServer::Config cfg;
        cfg.slot_count = 22;
        cfg.match_seed = 11;
        if (mind) cfg.model_params.setMilli("physics.mark.mind", 1000);
        server::GameServer s{cfg, t};
        for (int i = 0; i < 1500; ++i) s.tickOnce();
        Fixed64 sum{};
        for (std::uint8_t p = 0; p < 22; ++p) sum += s.world().player(p).pos.x + s.world().player(p).pos.y;
        return sum.raw;
    };
    const auto off_a = run(false), off_b = run(false), on = run(true);
    FH_EXPECT(off_a == off_b);    // deterministic
    FH_EXPECT(on != off_a);       // and the mind changes how the markers move
}

FH_TEST_MAIN()
