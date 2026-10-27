// game/tests/test_codec.cpp
//
// Round-trip, truncation-safety, and forward-compatibility tests for the
// fh-game.v1 codec (PROTOCOL.md §§1–6, §9).

#include "test_harness.hpp"
#include "net/Codec.hpp"

using namespace fh::game::net;
using fh::game::math::Fixed64;

FH_TEST(envelope_round_trip) {
    Bytes payload{1, 2, 3, 4, 5};
    Bytes frame = encodeFrame(FrameType::PlayerIntent, payload);
    FH_EXPECT_EQ(frame.size(), kEnvelopeBytes + 5);

    std::size_t consumed = 0;
    auto d = decodeFrame(frame.data(), frame.size(), consumed);
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(consumed, frame.size());
    FH_EXPECT(d->type == FrameType::PlayerIntent);
    FH_EXPECT(d->payload == payload);
}

FH_TEST(envelope_partial_input_returns_nullopt) {
    Bytes frame = encodeFrame(FrameType::Snapshot, Bytes(10, 0xAB));
    std::size_t consumed = 0;
    // Every strict prefix of a valid frame must decode to "need more".
    for (std::size_t cut = 0; cut < frame.size(); ++cut) {
        auto d = decodeFrame(frame.data(), cut, consumed);
        FH_EXPECT(!d.has_value());
    }
}

FH_TEST(envelope_stream_decodes_two_frames) {
    Bytes a = encodeFrame(FrameType::Claim, Bytes{7, 1});
    Bytes b = encodeFrame(FrameType::Goodbye, Bytes{0});
    Bytes stream = a;
    stream.insert(stream.end(), b.begin(), b.end());

    std::size_t consumed = 0;
    auto first = decodeFrame(stream.data(), stream.size(), consumed);
    FH_EXPECT(first.has_value());
    FH_EXPECT(first->type == FrameType::Claim);
    auto second = decodeFrame(stream.data() + consumed,
                              stream.size() - consumed, consumed);
    FH_EXPECT(second.has_value());
    FH_EXPECT(second->type == FrameType::Goodbye);
}

FH_TEST(hello_round_trip) {
    HelloFrame h;
    h.match_id = 123456789ULL;
    h.tick_rate = 30;
    h.capabilities = kCapPlayer | kCapSpectator;
    h.slot_count = 22;
    h.pitch_half_x = Fixed64::fromFraction(105, 2);  // 52.5 m
    h.pitch_half_y = Fixed64::fromInt(34);

    auto d = decodeHello(encodeHello(h));
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->major, kProtoMajor);
    FH_EXPECT_EQ(d->match_id, h.match_id);
    FH_EXPECT_EQ(d->tick_rate, 30);
    FH_EXPECT_EQ(d->capabilities, h.capabilities);
    FH_EXPECT_EQ(d->slot_count, 22);
    FH_EXPECT_EQ(d->pitch_half_x.raw, h.pitch_half_x.raw);
    FH_EXPECT_EQ(d->pitch_half_y.raw, h.pitch_half_y.raw);
}

FH_TEST(hello_ignores_trailing_bytes) {
    // PROTOCOL.md §9: minor versions may append fields; old decoders must
    // accept and ignore them.
    Bytes p = encodeHello(HelloFrame{});
    p.push_back(0xDE);
    p.push_back(0xAD);
    FH_EXPECT(decodeHello(p).has_value());
}

FH_TEST(hello_truncated_fails) {
    Bytes p = encodeHello(HelloFrame{});
    p.resize(p.size() - 1);
    FH_EXPECT(!decodeHello(p).has_value());
}

FH_TEST(player_intent_round_trip) {
    PlayerIntentFrame f;
    f.slot = 9;
    f.move_x = Fixed64::fromFraction(-3, 4);
    f.move_y = Fixed64::fromFraction(1, 4);
    f.action = 0;

    auto d = decodePlayerIntent(encodePlayerIntent(f));
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->slot, 9);
    FH_EXPECT_EQ(d->move_x.raw, f.move_x.raw);
    FH_EXPECT_EQ(d->move_y.raw, f.move_y.raw);
}

FH_TEST(snapshot_round_trip_22_players_fits_envelope) {
    SnapshotFrame s;
    s.tick = 54321;
    for (int i = 0; i < 22; ++i) {
        PlayerSnap p;
        p.pos_x = Fixed64::fromInt(i - 11);
        p.pos_y = Fixed64::fromInt(2 * i - 22);
        p.vel_x = Fixed64::fromFraction(i, 7);
        p.vel_y = -Fixed64::fromFraction(i, 5);
        p.flags = (i == 10) ? 1 : 0;
        s.players.push_back(p);
    }

    Bytes payload = encodeSnapshot(s);
    // The u16 envelope cap check v1 catalogued: 22 planar players must sit
    // far below 65535 (ball + extensions join later).
    FH_EXPECT(payload.size() < 2000u);
    Bytes frame = encodeFrame(FrameType::Snapshot, payload);
    FH_EXPECT(!frame.empty());

    auto d = decodeSnapshot(payload);
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->tick, 54321u);
    FH_EXPECT_EQ(d->players.size(), 22u);
    FH_EXPECT_EQ(d->players[10].flags, 1);
    FH_EXPECT_EQ(d->players[21].pos_x.raw, Fixed64::fromInt(10).raw);
    FH_EXPECT_EQ(d->players[3].vel_y.raw, (-Fixed64::fromFraction(3, 5)).raw);
}

FH_TEST(snapshot_truncated_player_list_fails) {
    SnapshotFrame s;
    s.tick = 1;
    s.players.resize(3);
    Bytes p = encodeSnapshot(s);
    // Cut past the additive tails (25-byte ball + 6-byte match structure,
    // 2-byte levels, 1.8's 2-byte facing per player) AND into the last
    // player record. (Missing/partial tails alone are tolerated; the
    // PLAYER array is 1.0 structure and must be whole.)
    p.resize(p.size() - 2 * 3 - 25 - 6 - 4);
    FH_EXPECT(!decodeSnapshot(p).has_value());
}

FH_TEST(snapshot_ball_record_round_trips) {
    SnapshotFrame s;
    s.tick = 9;
    s.players.resize(2);
    s.ball.pos_x = Fixed64::fromInt(-3);
    s.ball.pos_y = Fixed64::fromFraction(7, 2);
    s.ball.pos_z = Fixed64::fromFraction(5, 4);
    s.ball.owner = 11;

    auto d = decodeSnapshot(encodeSnapshot(s));
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->ball.pos_x.raw, s.ball.pos_x.raw);
    FH_EXPECT_EQ(d->ball.pos_z.raw, s.ball.pos_z.raw);
    FH_EXPECT_EQ(d->ball.owner, 11);
}

FH_TEST(event_round_trip) {
    EventFrame e;
    e.event_type = 1;
    e.team = 1;
    e.tick = 777;
    auto d = decodeEvent(encodeEvent(e));
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->event_type, 1);
    FH_EXPECT_EQ(d->team, 1);
    FH_EXPECT_EQ(d->tick, 777u);
}

FH_TEST(claim_round_trip) {
    ClaimFrame c;
    c.slot = 4;
    c.claim = 0;
    auto d = decodeClaim(encodeClaim(c));
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->slot, 4);
    FH_EXPECT_EQ(d->claim, 0);
}

FH_TEST(presets_round_trip) {
    PresetsFrame f;
    f.names = {"Lighthouse", "Bielsa", "Positional Play"};
    auto d = decodePresets(encodePresets(f));
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->names.size(), 3u);
    FH_EXPECT(d->names[0] == "Lighthouse");
    FH_EXPECT(d->names[2] == "Positional Play");
}

FH_TEST(apply_preset_round_trip) {
    ApplyPresetFrame f;
    f.team = 1;
    f.preset_id = 7;
    auto d = decodeApplyPreset(encodeApplyPreset(f));
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->team, 1);
    FH_EXPECT_EQ(d->preset_id, 7);
}

// G4.74 (1.14): the HUD's game-model panel.
FH_TEST(model_demands_round_trip) {
    ModelDemandsFrame f;
    f.team = 1;
    f.model = 14;
    f.demand = {100, 0, 90};
    f.source = {0, 1, 2};
    auto d = decodeModelDemands(encodeModelDemands(f));
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->team, 1);
    FH_EXPECT_EQ(d->model, 14);
    FH_EXPECT_EQ(d->demand.size(), 3u);
    FH_EXPECT_EQ(d->demand[2], 90);
    FH_EXPECT_EQ(d->source[1], 1);
}

FH_TEST(set_demand_round_trip) {
    SetDemandFrame f;
    f.team = 0;
    f.concept_id = 178;
    f.demand = 255;
    auto d = decodeSetDemand(encodeSetDemand(f));
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->concept_id, 178);
    FH_EXPECT_EQ(d->demand, 255);
}

FH_TEST(player_attributes_round_trip) {
    PlayerAttributesFrame f;
    f.slot = 13;
    f.ratings = {70, 55, 255, 40, 100, 0, 61, 22};   // 255 = unrated
    auto d = decodePlayerAttributes(encodePlayerAttributes(f));
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->slot, 13);
    FH_EXPECT_EQ(d->ratings.size(), 8u);
    FH_EXPECT_EQ(d->ratings[2], 255);
    FH_EXPECT_EQ(d->ratings[4], 100);
    FH_EXPECT(!decodePlayerAttributes(Bytes{3, 8, 1}).has_value());  // truncated
}

FH_TEST(teams_round_trip) {
    TeamsFrame f{"Lighthouse APSL", "Ukrainian Nationals"};
    auto d = decodeTeams(encodeTeams(f));
    FH_EXPECT(d.has_value());
    FH_EXPECT(d->home == "Lighthouse APSL");
    FH_EXPECT(d->away == "Ukrainian Nationals");
    FH_EXPECT(d->kit[0][0] == -1 && d->kit[1][3] == -1);   // no kits sent
}

FH_TEST(teams_kits_round_trip) {
    TeamsFrame f{"Lighthouse APSL", "Ukrainian Nationals"};
    f.kit[0][0] = 0x14326e; f.kit[0][2] = 0xf4f6fb;
    f.kit[1][1] = 0xf4f6fb; f.kit[1][2] = 0x111111;
    auto d = decodeTeams(encodeTeams(f));
    FH_EXPECT(d.has_value());
    FH_EXPECT(d->kit[0][0] == 0x14326e && d->kit[0][1] == -1 && d->kit[0][2] == 0xf4f6fb);
    FH_EXPECT(d->kit[1][1] == 0xf4f6fb && d->kit[1][2] == 0x111111);
    // An older encoder (names only) still decodes: kits stay -1.
    Bytes names_only;
    for (const std::string s : {"A", "B"}) {
        names_only.push_back(static_cast<std::uint8_t>(s.size()));
        for (char c : s) names_only.push_back(static_cast<std::uint8_t>(c));
    }
    auto o = decodeTeams(names_only);
    FH_EXPECT(o.has_value() && o->home == "A" && o->kit[0][0] == -1);
}

// G4.41 + G4.66 (1.11): the brain overlay round-trips, vision block too;
// a 1.7 frame (no vision block) still decodes.
FH_TEST(brain_frame_round_trips_with_the_vision_block) {
    BrainFrame f;
    BrainEntry a; a.why = 3; a.target_dm_x = -120; a.target_dm_y = 45; a.other = 7; a.rung = 2;
    a.look_ds = 14; a.unseen = 3;
    BrainEntry b; b.why = 0;
    f.slots = {a, b};
    const Bytes wire = encodeBrain(f);
    const auto back = decodeBrain(wire);
    FH_EXPECT(back.has_value() && back->slots.size() == 2);
    FH_EXPECT(back->slots[0].target_dm_x == -120 && back->slots[0].other == 7 && back->slots[0].rung == 2);
    FH_EXPECT(back->slots[0].look_ds == 14 && back->slots[0].unseen == 3);
    FH_EXPECT(back->slots[1].look_ds == 255 && back->slots[1].unseen == 0);
    const Bytes old(wire.begin(), wire.begin() + 1 + 2 * 7);
    const auto legacy = decodeBrain(old);
    FH_EXPECT(legacy.has_value() && legacy->slots.size() == 2 && legacy->slots[0].look_ds == 255);
}

FH_TEST_MAIN()
