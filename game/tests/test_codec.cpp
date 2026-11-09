// game/tests/test_codec.cpp
//
// Round-trip, truncation-safety, and forward-compatibility tests for the
// fh-game.v2 codec (PROTOCOL.md §§1–6, §9).

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
    // (1.16 adds a 1-byte officials count, empty here.)
    p.resize(p.size() - 1 - 2 * 3 - 25 - 6 - 4);
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

FH_TEST(snapshot_officials_tail_round_trips) {
    // 1.16 (G4.93): the referee and two assistants after the facing tail.
    SnapshotFrame s;
    s.tick = 3;
    s.players.resize(22);
    for (int i = 0; i < 3; ++i) {
        OfficialSnap o;
        o.pos_x = Fixed64::fromFraction(10 * i + 1, 4);
        o.pos_y = -Fixed64::fromInt(35 * (i == 2 ? 1 : 0)) + Fixed64::fromInt(35 * (i == 1 ? 1 : 0));
        o.face_x = static_cast<std::int8_t>(i == 0 ? 127 : 0);
        o.face_y = static_cast<std::int8_t>(i == 1 ? -127 : (i == 2 ? 127 : 0));
        o.flags = i == 1 ? 1 : 0;
        s.officials.push_back(o);
    }
    const Bytes payload = encodeSnapshot(s);
    auto d = decodeSnapshot(payload);
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->officials.size(), 3u);
    FH_EXPECT_EQ(d->officials[2].pos_x.raw, s.officials[2].pos_x.raw);
    FH_EXPECT_EQ(d->officials[1].pos_y.raw, Fixed64::fromInt(35).raw);
    FH_EXPECT_EQ(d->officials[1].face_y, -127);
    FH_EXPECT_EQ(d->officials[1].flags, 1);
    FH_EXPECT_EQ(d->officials[0].flags, 0);
    // A 1.15 snapshot (no officials tail) still decodes, with none.
    Bytes old = payload;
    old.resize(old.size() - 1 - 3 * 19);
    auto o = decodeSnapshot(old);
    FH_EXPECT(o.has_value());
    FH_EXPECT_EQ(o->officials.size(), 0u);
    FH_EXPECT_EQ(o->players.size(), 22u);
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

FH_TEST(names_round_trip) {
    NamesFrame f;
    f.names = {"hold shape", "press", "chase ball"};
    auto d = decodeNames(encodeNames(f));
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->names.size(), 3u);
    FH_EXPECT(d->names[0] == "hold shape");
    FH_EXPECT(d->names[2] == "chase ball");
}

// G4.74 (1.14): the HUD's game-model panel.
// G4.76 (1.15): which model each value came from, and the model's parent.
// G4.76 (1.15): concept numbers + 3-rule weights, and the edit frame.
FH_TEST(teams_round_trip) {
    TeamsFrame f{"Leicester City", "Arsenal"};
    auto d = decodeTeams(encodeTeams(f));
    FH_EXPECT(d.has_value());
    FH_EXPECT(d->home == "Leicester City");
    FH_EXPECT(d->away == "Arsenal");
    FH_EXPECT(d->kit[0][0] == -1 && d->kit[1][3] == -1);   // no kits sent
}

FH_TEST(teams_kits_round_trip) {
    TeamsFrame f{"Leicester City", "Arsenal"};
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
// 1.17: ROSTER carries each slot's position number; a 1.16 frame (no
// trailer) still decodes, with none.
// 2.0: a brain entry is why / target / other.
// G5.35 (2.1): the matchup dropdowns' team list.
FH_TEST(team_list_round_trip) {
    TeamListFrame f;
    f.names = {"AFC Bournemouth", "Arsenal", "West Ham United"};
    auto d = decodeTeamList(encodeTeamList(f));
    FH_EXPECT(d.has_value());
    FH_EXPECT(d->names.size() == 3);
    FH_EXPECT(d->names[0] == "AFC Bournemouth" && d->names[2] == "West Ham United");
    FH_EXPECT(!decodeTeamList(Bytes{2, 3, 'A'}).has_value());   // truncated
    auto e = decodeTeamList(encodeTeamList(TeamListFrame{}));
    FH_EXPECT(e.has_value() && e->names.empty());
}

FH_TEST(brain_frame_round_trips) {
    BrainFrame f;
    BrainEntry a; a.why = 3; a.target_dm_x = -120; a.target_dm_y = 45; a.other = 7; a.concept_id = 164;
    BrainEntry b; b.why = 0;
    f.slots = {a, b};
    const auto back = decodeBrain(encodeBrain(f));
    FH_EXPECT(back.has_value() && back->slots.size() == 2);
    FH_EXPECT(back->slots[0].target_dm_x == -120 && back->slots[0].target_dm_y == 45 && back->slots[0].other == 7);
    FH_EXPECT(back->slots[1].why == 0 && back->slots[1].other == 255);
    FH_EXPECT(back->slots[0].concept_id == 164 && back->slots[1].concept_id == 255);   // 2.2
}

// 2.2 CONCEPT_LEGEND: the trainer's labels, titles past the 40-byte NAMES cap.
FH_TEST(concept_legend_round_trips) {
    ConceptLegendFrame f;
    f.entries.push_back({164, "pressing-distance", "Stay in pressing distance"});
    f.entries.push_back({168, "defend-your-man", "Defend your man: intercept, no turn, contain"});
    const auto back = decodeConceptLegend(encodeConceptLegend(f));
    FH_EXPECT(back.has_value() && back->entries.size() == 2);
    FH_EXPECT(back->entries[0].id == 164 && back->entries[0].name == "pressing-distance");
    FH_EXPECT(back->entries[1].title == "Defend your man: intercept, no turn, contain");
    FH_EXPECT(!decodeConceptLegend(Bytes{1, 5, 3, 'a'}).has_value());   // truncated
}

// 2.0: ROSTER = each slot's name, then each slot's position number.
FH_TEST(roster_round_trip) {
    RosterFrame f;
    RosterEntry a; a.name = "Vardy";
    RosterEntry b; b.name = "Kante";
    f.slots = {a, b};
    f.numbers = {9, 6};
    const auto back = decodeRoster(encodeRoster(f));
    FH_EXPECT(back.has_value() && back->slots.size() == 2 && back->numbers.size() == 2);
    FH_EXPECT(back->numbers[0] == 9 && back->numbers[1] == 6 && back->slots[1].name == "Kante");
}

FH_TEST_MAIN()
