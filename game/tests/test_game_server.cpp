// game/tests/test_game_server.cpp
//
// GameServer behavior against a scripted in-memory transport ([v1]'s
// FakeTransport testing pattern): HELLO on connect, claim rules, intent
// authorization, snapshot fan-out, disconnect slot release.

#include "test_harness.hpp"
#include "ai/Brain.hpp"
#include "net/Codec.hpp"
#include "net/Wire.hpp"
#include "server/GameServer.hpp"
#include "server/Rooms.hpp"

#include <cstdlib>
#include <cstdio>
#include <map>
#include <vector>

using namespace fh::game;
using namespace fh::game::net;
using fh::game::math::Fixed64;

namespace {

class FakeTransport final : public INetworkTransport {
public:
    void setOnConnect(OnConnectFn f) override { on_connect_ = std::move(f); }
    void setOnDisconnect(OnDisconnectFn f) override {
        on_disconnect_ = std::move(f);
    }
    void setOnMessage(OnMessageFn f) override { on_message_ = std::move(f); }

    bool send(fh::game::ClientId id, std::span<const std::uint8_t> b) override {
        sent[id].emplace_back(b.begin(), b.end());
        return true;
    }
    void disconnect(fh::game::ClientId id) override {
        if (on_disconnect_) on_disconnect_(id);
    }
    std::size_t clientCount() const override { return 0; }
    void poll(int) override {}

    // test drivers
    void scriptConnect(fh::game::ClientId id, const char* role = "") {
        auth::JwtClaims claims;
        claims.person_id = static_cast<std::int64_t>(id);
        claims.role = role;
        on_connect_(id, claims);
    }
    void scriptMessage(fh::game::ClientId id, const Bytes& bytes) {
        on_message_(id, std::span<const std::uint8_t>{bytes});
    }
    void scriptDisconnect(fh::game::ClientId id) { on_disconnect_(id); }

    std::map<fh::game::ClientId, std::vector<Bytes>> sent;

private:
    OnConnectFn on_connect_;
    OnDisconnectFn on_disconnect_;
    OnMessageFn on_message_;
};

Bytes claimBytes(std::uint8_t slot, std::uint8_t claim = 1) {
    ClaimFrame c;
    c.slot = slot;
    c.claim = claim;
    return encodeFrame(FrameType::Claim, encodeClaim(c));
}

// All frames of one type a client received (connect now also sends
// ROSTER, so index-based assumptions broke).
std::vector<Bytes> framesOf(const std::vector<Bytes>& sent, FrameType t) {
    std::vector<Bytes> out;
    for (const auto& b : sent) {
        std::size_t c = 0;
        auto f = decodeFrame(b.data(), b.size(), c);
        if (f && f->type == t) out.push_back(f->payload);
    }
    return out;
}

Bytes intentBytes(std::uint8_t slot, Fixed64 mx, Fixed64 my) {
    PlayerIntentFrame f;
    f.slot = slot;
    f.move_x = mx;
    f.move_y = my;
    return encodeFrame(FrameType::PlayerIntent, encodePlayerIntent(f));
}

struct Rig {
    FakeTransport t;
    server::GameServer s;
    Rig() : s{{.match_id = 7, .slot_count = 4}, t} {}
};

}  // namespace

FH_TEST(server_sends_hello_on_connect) {
    Rig r;
    r.t.scriptConnect(100);
    const auto hellos = framesOf(r.t.sent[100], FrameType::Hello);
    FH_EXPECT_EQ(hellos.size(), 1u);
    const auto rosters = framesOf(r.t.sent[100], FrameType::Roster);
    FH_EXPECT_EQ(rosters.size(), 1u);
    auto h = decodeHello(hellos[0]);
    FH_EXPECT(h.has_value());
    FH_EXPECT_EQ(h->match_id, 7u);
    FH_EXPECT_EQ(h->slot_count, 4);
    FH_EXPECT_EQ(h->capabilities, kCapPlayer | kCapSpectator);
}

FH_TEST(server_first_claim_wins) {
    Rig r;
    r.t.scriptConnect(100);
    r.t.scriptConnect(200);
    r.t.scriptMessage(100, claimBytes(2));
    r.t.scriptMessage(200, claimBytes(2));  // loses — already owned
    FH_EXPECT(r.s.slotClaimedBy(2, 100));
    FH_EXPECT(!r.s.slotClaimedBy(2, 200));
}

FH_TEST(server_owner_intent_moves_player_foreign_intent_dropped) {
    Rig r;
    r.t.scriptConnect(100);
    r.t.scriptConnect(200);
    r.t.scriptMessage(100, claimBytes(0));

    // Players spawn at team lines now, so assert DELTAS from spawn.
    const auto x0 = r.s.world().player(0).pos.x.raw;
    const auto y0 = r.s.world().player(0).pos.y.raw;

    // Owner drives slot 0 east; an intruder tries to drive it north.
    // (Slot 1 is unclaimed and therefore AI-driven since G2.4 — a human
    // intent for it is overwritten by its brain every tick, so the old
    // "unclaimed stays frozen" assertion no longer applies.)
    r.t.scriptMessage(100, intentBytes(0, Fixed64::one(), Fixed64::zero()));
    r.t.scriptMessage(200, intentBytes(0, Fixed64::zero(), Fixed64::one()));
    r.s.tickOnce();

    FH_EXPECT(r.s.world().player(0).pos.x.raw > x0);
    FH_EXPECT_EQ(r.s.world().player(0).pos.y.raw, y0);  // intruder ignored
}

FH_TEST(server_one_client_may_hold_multiple_slots) {
    Rig r;
    r.t.scriptConnect(100);
    r.t.scriptMessage(100, claimBytes(0));
    r.t.scriptMessage(100, claimBytes(1));
    const auto x0 = r.s.world().player(0).pos.x.raw;
    const auto y1 = r.s.world().player(1).pos.y.raw;
    r.t.scriptMessage(100, intentBytes(0, Fixed64::one(), Fixed64::zero()));
    r.t.scriptMessage(100, intentBytes(1, Fixed64::zero(), Fixed64::one()));
    r.s.tickOnce();
    FH_EXPECT(r.s.world().player(0).pos.x.raw > x0);
    FH_EXPECT(r.s.world().player(1).pos.y.raw > y1);
}

FH_TEST(server_broadcasts_snapshot_to_all_clients) {
    Rig r;
    r.t.scriptConnect(100);
    r.t.scriptConnect(200);
    r.s.tickOnce();

    for (auto id : {fh::game::ClientId{100}, fh::game::ClientId{200}}) {
        const auto snaps = framesOf(r.t.sent[id], FrameType::Snapshot);
        FH_EXPECT_EQ(snaps.size(), 1u);
        auto s = decodeSnapshot(snaps.back());
        FH_EXPECT(s.has_value());
        FH_EXPECT_EQ(s->tick, 1u);
        FH_EXPECT_EQ(s->players.size(), 4u);
    }
}

FH_TEST(server_snapshot_flags_mark_claimed_slots) {
    Rig r;
    r.t.scriptConnect(100);
    r.t.scriptMessage(100, claimBytes(3));
    r.s.tickOnce();

    const auto& frames = r.t.sent[100];
    std::size_t consumed = 0;
    auto f = decodeFrame(frames.back().data(), frames.back().size(), consumed);
    auto s = decodeSnapshot(f->payload);
    FH_EXPECT(s.has_value());
    FH_EXPECT_EQ(s->players[3].flags, 1);
    FH_EXPECT_EQ(s->players[0].flags, 0);
}

FH_TEST(server_snapshot_carries_the_officials) {
    // 1.16 (G4.93): the referee and both assistants ride the snapshot,
    // the assistants out on their touchlines, no flag up at kick-off.
    Rig r;
    r.t.scriptConnect(100);
    r.s.tickOnce();
    const auto& frames = r.t.sent[100];
    std::size_t consumed = 0;
    auto f = decodeFrame(frames.back().data(), frames.back().size(), consumed);
    auto s = decodeSnapshot(f->payload);
    FH_EXPECT(s.has_value());
    FH_EXPECT_EQ(s->officials.size(), 3u);
    FH_EXPECT(s->officials[1].pos_y.raw > 0);
    FH_EXPECT(s->officials[2].pos_y.raw < 0);
    FH_EXPECT_EQ(s->officials[1].flags, 0);
}

FH_TEST(server_disconnect_releases_slots) {
    Rig r;
    r.t.scriptConnect(100);
    r.t.scriptMessage(100, claimBytes(2));
    FH_EXPECT(r.s.slotClaimedBy(2, 100));
    r.t.scriptDisconnect(100);
    FH_EXPECT(!r.s.slotClaimedBy(2, 100));

    // The freed slot is claimable by the next client.
    r.t.scriptConnect(200);
    r.t.scriptMessage(200, claimBytes(2));
    FH_EXPECT(r.s.slotClaimedBy(2, 200));
}

FH_TEST(server_release_frees_only_own_slot) {
    Rig r;
    r.t.scriptConnect(100);
    r.t.scriptConnect(200);
    r.t.scriptMessage(100, claimBytes(2));
    r.t.scriptMessage(200, claimBytes(2, /*claim=*/0));  // not the owner
    FH_EXPECT(r.s.slotClaimedBy(2, 100));
    r.t.scriptMessage(100, claimBytes(2, /*claim=*/0));
    FH_EXPECT(!r.s.slotClaimedBy(2, 100));
}

FH_TEST(server_two_frames_in_one_message) {
    Rig r;
    r.t.scriptConnect(100);
    const auto x0 = r.s.world().player(0).pos.x.raw;
    Bytes combined = claimBytes(0);
    const Bytes intent = intentBytes(0, Fixed64::one(), Fixed64::zero());
    combined.insert(combined.end(), intent.begin(), intent.end());
    r.t.scriptMessage(100, combined);
    r.s.tickOnce();
    FH_EXPECT(r.s.world().player(0).pos.x.raw > x0);
}

FH_TEST(brain_overlay_goes_only_to_watchers) {
    Rig r;
    r.t.scriptConnect(100);
    r.t.scriptConnect(200);
    // The decision names arrive on connect.
    const auto legend = framesOf(r.t.sent[100], FrameType::BrainLegend);
    FH_EXPECT_EQ(legend.size(), 1u);
    auto names = decodeNames(legend[0]);
    FH_EXPECT(names.has_value() && static_cast<int>(names->names.size()) == ai::kWhyCount);
    FH_EXPECT(names->names[static_cast<int>(ai::Why::Press)] == "press");
    // 100 switches the overlay on; 200 doesn't.
    BrainWatchFrame on;
    on.on = 1;
    r.t.scriptMessage(100, encodeFrame(FrameType::BrainWatch, encodeBrainWatch(on)));
    r.t.scriptMessage(200, claimBytes(0));          // a human holds slot 0
    for (int i = 0; i < 12; ++i) r.s.tickOnce();
    const auto b100 = framesOf(r.t.sent[100], FrameType::Brain);
    FH_EXPECT(b100.size() >= 2u);
    FH_EXPECT(framesOf(r.t.sent[200], FrameType::Brain).empty());
    auto bf = decodeBrain(b100.back());
    FH_EXPECT(bf.has_value() && bf->slots.size() == 4u);
    FH_EXPECT_EQ(bf->slots[0].why, static_cast<std::uint8_t>(ai::Why::Human));
    // Off again: no more frames.
    BrainWatchFrame off;
    r.t.scriptMessage(100, encodeFrame(FrameType::BrainWatch, encodeBrainWatch(off)));
    const auto before = framesOf(r.t.sent[100], FrameType::Brain).size();
    for (int i = 0; i < 12; ++i) r.s.tickOnce();
    FH_EXPECT_EQ(framesOf(r.t.sent[100], FrameType::Brain).size(), before);
}

FH_TEST(admin_sets_the_sim_speed_everyone_hears_it) {
    // G4.61: SPEED 0x31 — admin only, 0 pauses, clamped 5..400, told to
    // every client (and to a late joiner on connect).
    Rig r;
    r.t.scriptConnect(100, "club");
    r.t.scriptConnect(200);
    FH_EXPECT_EQ(r.s.speedPct(), 100);
    FH_EXPECT_EQ(framesOf(r.t.sent[200], FrameType::Speed).size(), 1u);   // on connect
    r.t.scriptMessage(200, encodeFrame(FrameType::Speed, encodeSpeed(SpeedFrame{10})));
    FH_EXPECT_EQ(r.s.speedPct(), 100);                                      // players can't
    r.t.scriptMessage(100, encodeFrame(FrameType::Speed, encodeSpeed(SpeedFrame{10})));
    FH_EXPECT_EQ(r.s.speedPct(), 10);
    const auto told = framesOf(r.t.sent[200], FrameType::Speed);
    FH_EXPECT_EQ(told.size(), 2u);
    FH_EXPECT_EQ(decodeSpeed(told.back())->pct, 10);
    r.t.scriptMessage(100, encodeFrame(FrameType::Speed, encodeSpeed(SpeedFrame{1})));
    FH_EXPECT_EQ(r.s.speedPct(), 5);
    r.t.scriptMessage(100, encodeFrame(FrameType::Speed, encodeSpeed(SpeedFrame{9000})));
    FH_EXPECT_EQ(r.s.speedPct(), 400);
    r.t.scriptMessage(100, encodeFrame(FrameType::Speed, encodeSpeed(SpeedFrame{0})));
    FH_EXPECT_EQ(r.s.speedPct(), 0);
    // Paused: a heartbeat sends the frozen picture without a tick.
    const auto tick = r.s.world().tickCount();
    const auto snaps = framesOf(r.t.sent[200], FrameType::Snapshot).size();
    r.s.heartbeat();
    FH_EXPECT_EQ(r.s.world().tickCount(), tick);
    FH_EXPECT_EQ(framesOf(r.t.sent[200], FrameType::Snapshot).size(), snaps + 1);
}

// ── tactics trainer step 2: practice rooms (Rooms.hpp) ──────────────────

FH_TEST(practice_link_parses) {
    FH_EXPECT(!server::parsePracticeAsk("/game").has_value());
    FH_EXPECT(!server::parsePracticeAsk("/game?trainer=0&home=Arsenal").has_value());
    const auto a = server::parsePracticeAsk("/game?trainer=1&home=West%20Ham+United&away=Arsenal&gk=home");
    FH_EXPECT(a.has_value());
    FH_EXPECT(a->home == "West Ham United" && a->away == "Arsenal" && a->goal_kick == "home");
    const auto b = server::parsePracticeAsk("/game?trainer=1");
    FH_EXPECT(b.has_value() && b->home.empty() && b->goal_kick == "away");
}

FH_TEST(practice_room_starts_paused_on_their_goal_kick) {
    FakeTransport t;
    server::GameServer::Config cfg;
    cfg.match_id = 9;
    cfg.slot_count = 22;
    cfg.practice = true;
    cfg.goal_kick_team = 1;
    server::GameServer s{cfg, t};
    FH_EXPECT_EQ(s.speedPct(), 0);                  // frozen for the coach
    FH_EXPECT_EQ(s.world().restartTeam(), 1);       // still their dead ball: the taker waited
    FH_EXPECT(s.world().restartSpot().x.raw > 0);   // at the away goal (+x)
    FH_EXPECT(s.world().tickCount() >= 300u);       // the shape had its 10 s
    {   // G5.69: the taker is the away keeper, by the ball (within 6 m), not on the spawn line
        const auto& w = s.world();
        int near = -1;
        for (std::uint8_t i = 0; i < w.playerCount(); ++i) {
            const auto dx = (w.player(i).pos.x - w.ball().pos.x).toDouble(), dy = (w.player(i).pos.y - w.ball().pos.y).toDouble();
            if (dx * dx + dy * dy < 36.0) near = i;   // at the ball, or at his run-up
        }
        FH_EXPECT(near >= 11 && w.isKeeper(static_cast<std::uint8_t>(near)));
    }
    t.scriptConnect(100);                           // the viewer runs his own room
    const auto hellos = framesOf(t.sent[100], FrameType::Hello);
    FH_EXPECT(hellos.size() == 1u && (decodeHello(hellos[0])->capabilities & kCapAdmin));
    FH_EXPECT_EQ(framesOf(t.sent[100], FrameType::ConceptLegend).size(), 1u);
    // Played on, the keeper takes it (the engine's wait, then the kick): the ball is live.
    bool live = false;
    for (int i = 0; i < 600 && !live; ++i) { s.tickOnce(); live = s.world().restartTeam() == 0xFF; }
    FH_EXPECT(live);
}

// Trainer step 3: from the freeze, STEP plays the goal kick to where it lands — a man has
// it or it's dead — and pauses again; then the next pass the same way.
FH_TEST(trainer_step_plays_one_pass_then_freezes) {
    FakeTransport t;
    server::GameServer::Config cfg;
    cfg.slot_count = 22;
    cfg.practice = true;
    server::GameServer s{cfg, t};
    t.scriptConnect(100);
    for (int k = 0; k < 2; ++k) {
        t.scriptMessage(100, encodeFrame(FrameType::Step, encodeStep(StepFrame{100})));
        FH_EXPECT(s.stepping());
        FH_EXPECT_EQ(s.speedPct(), 100);
        int ticks = 0;
        while (s.stepping() && ticks < 30 * 25) { s.tickOnce(); ++ticks; }
        FH_EXPECT(!s.stepping());
        FH_EXPECT_EQ(s.speedPct(), 0);
        const auto& w = s.world();
        FH_EXPECT(w.ball().owner.has_value() || w.restartTeam() != 0xFF || w.outStage() != 0);
    }
    // A viewer of the live match can't step it.
    FakeTransport lt;
    server::GameServer live{server::GameServer::Config{.slot_count = 4}, lt};
    lt.scriptConnect(5);
    lt.scriptMessage(5, encodeFrame(FrameType::Step, encodeStep(StepFrame{100})));
    FH_EXPECT(!live.stepping());
}

FH_TEST(room_transport_sends_only_to_its_members) {
    FakeTransport real;
    server::RoomTransport a{real}, b{real};
    auth::JwtClaims c;
    a.join(1, c);
    b.join(2, c);
    const Bytes x{1, 2, 3};
    FH_EXPECT(a.send(1, x));
    FH_EXPECT(!a.send(2, x));   // a client of another room
    FH_EXPECT_EQ(real.sent[2].size(), 0u);
    FH_EXPECT_EQ(a.clientCount(), 1u);
    a.leave(1);
    FH_EXPECT_EQ(a.clientCount(), 0u);
}

FH_TEST_MAIN()
