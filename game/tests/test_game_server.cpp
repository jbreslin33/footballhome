// game/tests/test_game_server.cpp
//
// GameServer behavior against a scripted in-memory transport ([v1]'s
// FakeTransport testing pattern): HELLO on connect, claim rules, intent
// authorization, snapshot fan-out, disconnect slot release.

#include "test_harness.hpp"
#include "net/Codec.hpp"
#include "net/Wire.hpp"
#include "server/GameServer.hpp"

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

FH_TEST(server_sends_the_curriculum_and_sized_rosters_on_connect) {
    // G4.37: a DB curriculum with a lesson far past the old 32 cap.
    core::ConceptRegistry db = core::ConceptRegistry::builtin();
    db.add(75, "command-box", 0);
    core::setConcepts(db);
    Rig r;
    r.t.scriptConnect(100);
    const auto cs = framesOf(r.t.sent[100], FrameType::Concepts);
    FH_EXPECT_EQ(cs.size(), 1u);
    auto names = decodePresets(cs[0]);   // same name-list layout as PRESETS
    FH_EXPECT(names.has_value() && names->names.size() == 76u);
    FH_EXPECT(names->names[29] == "pass-ladder" && names->names[75] == "command-box");
    FH_EXPECT(names->names[40].empty());   // an id hole
    auto roster = decodeRoster(framesOf(r.t.sent[100], FrameType::Roster).back());
    FH_EXPECT(roster.has_value() && roster->slots[0].ratings.size() == 76u);
    core::setConcepts(core::ConceptRegistry::builtin());
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

FH_TEST(server_admin_can_retune_levels_others_cannot) {
    Rig r;
    r.t.scriptConnect(100, "club");   // admin-ish club role
    r.t.scriptConnect(200);            // plain player

    // Admin's HELLO carries the admin capability; the player's doesn't.
    std::size_t consumed = 0;
    auto ha = decodeFrame(r.t.sent[100][0].data(), r.t.sent[100][0].size(),
                          consumed);
    auto hb = decodeFrame(r.t.sent[200][0].data(), r.t.sent[200][0].size(),
                          consumed);
    FH_EXPECT(decodeHello(ha->payload)->capabilities & kCapAdmin);
    FH_EXPECT(!(decodeHello(hb->payload)->capabilities & kCapAdmin));

    // Player tries u10/u10: ignored. Admin sets pro/u10: applied, and the
    // next snapshot's 1.3 tail reports it.
    MatchSettingsFrame ms;
    ms.level_home = 1;  // u10
    ms.level_away = 1;
    r.t.scriptMessage(200, encodeFrame(FrameType::MatchSettings,
                                       encodeMatchSettings(ms)));
    r.s.tickOnce();
    auto snap1 = [&] {
        const auto& fr = r.t.sent[100].back();
        std::size_t c = 0;
        auto f = decodeFrame(fr.data(), fr.size(), c);
        return *decodeSnapshot(f->payload);
    }();
    FH_EXPECT_EQ(snap1.level_home, 0);  // unchanged (test cfg default)

    ms.level_home = 5;  // pro
    ms.level_away = 1;  // u10
    r.t.scriptMessage(100, encodeFrame(FrameType::MatchSettings,
                                       encodeMatchSettings(ms)));
    r.s.tickOnce();
    auto snap2 = [&] {
        const auto& fr = r.t.sent[100].back();
        std::size_t c = 0;
        auto f = decodeFrame(fr.data(), fr.size(), c);
        return *decodeSnapshot(f->payload);
    }();
    FH_EXPECT_EQ(snap2.level_home, 5);
    FH_EXPECT_EQ(snap2.level_away, 1);
}

FH_TEST(preset_overlay_touches_only_named_dials) {
    core::ConceptRatings r{};
    r.fill(50);
    core::PresetOverlay o;
    o.fill(-1);
    o[18] = 95;   // man-mark
    o[1] = 0;     // marking — an explicit zero is meaningful (Sacchi)
    o[19] = 200;  // junk over 100 clamps
    core::applyPresetOverlay(r, o);
    FH_EXPECT_EQ(r[18], 95);
    FH_EXPECT_EQ(r[1], 0);
    FH_EXPECT_EQ(r[19], 100);
    FH_EXPECT_EQ(r[0], 50);  // unnamed dial untouched
}

FH_TEST(roster_wears_its_named_preset_at_boot) {
    persistence::StylePreset bielsa;
    bielsa.name = "Bielsa";
    bielsa.overlay.fill(-1);
    bielsa.overlay[18] = 95;  // man-mark

    persistence::DemoTeam team;
    team.level_band = "world";
    team.style_preset = "Bielsa";

    FakeTransport t;
    server::GameServer s{{.match_id = 7, .slot_count = 4,
                          .roster_home = team, .presets = {bielsa}}, t};
    t.scriptConnect(100, "club");
    auto rosters = framesOf(t.sent[100], FrameType::Roster);
    auto r0 = *decodeRoster(rosters.back());
    FH_EXPECT_EQ(r0.slots[0].ratings[18], 95);  // home wears Bielsa
    FH_EXPECT_EQ(r0.slots[2].ratings[18], 0);   // away does not

    // The identity survives a band change (MATCH_SETTINGS reset).
    MatchSettingsFrame ms;
    ms.level_home = 4;  // semipro
    ms.level_away = 4;
    t.scriptMessage(100, encodeFrame(FrameType::MatchSettings,
                                     encodeMatchSettings(ms)));
    rosters = framesOf(t.sent[100], FrameType::Roster);
    auto r1 = *decodeRoster(rosters.back());
    FH_EXPECT_EQ(r1.slots[0].ratings[18], 95);
    FH_EXPECT_EQ(r1.slots[2].ratings[18], 0);
}

FH_TEST(server_admin_applies_preset_to_one_team_only) {
    persistence::StylePreset bielsa;
    bielsa.name = "Bielsa";
    bielsa.overlay.fill(-1);
    bielsa.overlay[18] = 95;  // man-mark
    bielsa.overlay[19] = 90;  // verticality

    FakeTransport t;
    server::GameServer s{{.match_id = 7, .slot_count = 4,
                          .presets = {bielsa}}, t};
    t.scriptConnect(100, "club");  // admin
    t.scriptConnect(200);          // plain player

    // Catalog goes out on connect.
    const auto cat = framesOf(t.sent[100], FrameType::Presets);
    FH_EXPECT_EQ(cat.size(), 1u);
    auto pf = decodePresets(cat[0]);
    FH_EXPECT(pf.has_value());
    FH_EXPECT(pf->names.size() == 1 && pf->names[0] == "Bielsa");

    auto lastRoster = [&] {
        const auto rs = framesOf(t.sent[100], FrameType::Roster);
        return *decodeRoster(rs.back());
    };
    const auto before = lastRoster();

    // Plain player's apply is ignored.
    ApplyPresetFrame ap;
    ap.team = 1;  // away = slots 2,3 in the 4-slot rig
    ap.preset_id = 0;
    t.scriptMessage(200, encodeFrame(FrameType::ApplyPreset,
                                     encodeApplyPreset(ap)));
    FH_EXPECT_EQ(framesOf(t.sent[100], FrameType::Roster).size(), 2u);

    // Admin's apply paints the away slots' named dials, nothing else.
    t.scriptMessage(100, encodeFrame(FrameType::ApplyPreset,
                                     encodeApplyPreset(ap)));
    const auto after = lastRoster();
    FH_EXPECT_EQ(after.slots[2].ratings[18], 95);
    FH_EXPECT_EQ(after.slots[3].ratings[19], 90);
    // Home team untouched; away's unnamed dials keep their values.
    FH_EXPECT_EQ(after.slots[0].ratings[18], before.slots[0].ratings[18]);
    FH_EXPECT_EQ(after.slots[2].ratings[0], before.slots[2].ratings[0]);

    // Out-of-range preset id is ignored, not UB.
    ap.preset_id = 9;
    t.scriptMessage(100, encodeFrame(FrameType::ApplyPreset,
                                     encodeApplyPreset(ap)));
    FH_EXPECT_EQ(framesOf(t.sent[100], FrameType::Roster).size(), 3u);
}

FH_TEST_MAIN()
