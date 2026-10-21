// footballhome sim - MatchEventFrame codec tests (Slice 28.4)
//
// Locks the fh-sim.v1 MATCH_EVENT (msg_type 0x04) wire layout per §7.6
// and the wire-side sibling to ADR §22.25. Payload bytes are the
// storage-side sim_match_events.payload bytes verbatim, so the codec
// treats them as opaque here — semantic checks live in the Goal-payload
// tests over in test_match_goal_detection (state side) and migration
// 221 tests (DB side).

#include "net/MatchEventFrame.hpp"

#include "net/LeCodec.hpp"
#include "net/WireFormat.hpp"
#include "persistence/EventTypes.hpp"
#include "test_harness.hpp"

#include <cstdint>
#include <span>
#include <vector>

using fh::sim::net::DecodedMatchEvent;
using fh::sim::net::decodeMatchEventFrame;
using fh::sim::net::encodeMatchEventFrame;
using fh::sim::net::kFrameHeaderBytes;
using fh::sim::net::kMatchEventHeaderBytes;
using fh::sim::net::kMaxPayloadBytes;
using fh::sim::net::kWireCapMatchEventFrame;
using fh::sim::net::kWireCapScenarioMeta;
using fh::sim::net::kWireCapInputKickTrailer;
using fh::sim::net::kWireVersionV1;
using fh::sim::net::MsgType;
using fh::sim::net::read_u16_le;
using fh::sim::net::read_u32_le;

using fh::sim::persistence::encodeGoalPayloadV1;
using fh::sim::persistence::EventType;
using fh::sim::persistence::kGoalKickerSlotUnknown;
using fh::sim::persistence::kGoalPayloadV1Bytes;
using fh::sim::persistence::kGoalPayloadV1Version;

// ---------------------------------------------------------------------------
// Wire constants pinned
// ---------------------------------------------------------------------------
FH_TEST(match_event_constants_pinned) {
    FH_EXPECT_EQ(kMatchEventHeaderBytes, std::size_t{7});
    FH_EXPECT_EQ(static_cast<std::uint8_t>(MsgType::MatchEvent),
                 std::uint8_t{0x04});
    FH_EXPECT_EQ(kWireCapMatchEventFrame,
                 static_cast<std::uint16_t>(1u << 2));
    // Bit 2 must not collide with the older caps that surround it.
    FH_EXPECT((kWireCapMatchEventFrame & kWireCapScenarioMeta)     == 0u);
    FH_EXPECT((kWireCapMatchEventFrame & kWireCapInputKickTrailer) == 0u);
}

// ---------------------------------------------------------------------------
// Encoder — byte layout locked
// ---------------------------------------------------------------------------
FH_TEST(encode_goal_frame_bytes_locked) {
    // Goal at tick 123 in region 1 (east) kicked by slot 7. Payload is
    // the ADR §22.25 v1 layout, produced by encodeGoalPayloadV1.
    const auto payload = encodeGoalPayloadV1(/*region*/ 1, /*kicker*/ 7);
    FH_EXPECT_EQ(payload.size(), kGoalPayloadV1Bytes);

    const std::uint8_t* pay_u8 =
        reinterpret_cast<const std::uint8_t*>(payload.data());
    const auto frame = encodeMatchEventFrame(
        /*tick_num*/   123u,
        /*event_type*/ static_cast<std::uint8_t>(EventType::Goal),
        std::span<const std::uint8_t>(pay_u8, payload.size()));

    // Frame size: 4 (frame hdr) + 7 (match_event hdr) + 5 (goal payload) = 16.
    FH_EXPECT_EQ(frame.size(),
                 kFrameHeaderBytes + kMatchEventHeaderBytes + kGoalPayloadV1Bytes);

    // Frame header.
    FH_EXPECT_EQ(frame[0], kWireVersionV1);
    FH_EXPECT_EQ(frame[1], static_cast<std::uint8_t>(MsgType::MatchEvent));
    FH_EXPECT_EQ(read_u16_le(frame.data() + 2),
                 static_cast<std::uint16_t>(kMatchEventHeaderBytes + kGoalPayloadV1Bytes));

    // MATCH_EVENT header.
    FH_EXPECT_EQ(read_u32_le(frame.data() + 4), std::uint32_t{123});
    FH_EXPECT_EQ(frame[8], static_cast<std::uint8_t>(EventType::Goal));
    FH_EXPECT_EQ(read_u16_le(frame.data() + 9),
                 static_cast<std::uint16_t>(kGoalPayloadV1Bytes));

    // Event payload: [ver=1][region=1][kicker_lo=7][kicker_hi=0][rsv=0].
    FH_EXPECT_EQ(frame[11], kGoalPayloadV1Version);
    FH_EXPECT_EQ(frame[12], std::uint8_t{1});
    FH_EXPECT_EQ(frame[13], std::uint8_t{7});
    FH_EXPECT_EQ(frame[14], std::uint8_t{0});
    FH_EXPECT_EQ(frame[15], std::uint8_t{0});
}

FH_TEST(encode_empty_payload_produces_header_only_frame) {
    // An event with no payload is legitimate at the codec level — the
    // 7-byte MATCH_EVENT header alone plus the 4-byte frame header is
    // a valid on-wire message. Grandfathered event_types (<9) go through
    // this path since their payloads are typically empty.
    const auto frame = encodeMatchEventFrame(
        /*tick_num*/   0u,
        /*event_type*/ static_cast<std::uint8_t>(EventType::MatchStart),
        std::span<const std::uint8_t>{});
    FH_EXPECT_EQ(frame.size(), kFrameHeaderBytes + kMatchEventHeaderBytes);
    FH_EXPECT_EQ(frame[1], static_cast<std::uint8_t>(MsgType::MatchEvent));
    FH_EXPECT_EQ(read_u16_le(frame.data() + 2),
                 static_cast<std::uint16_t>(kMatchEventHeaderBytes));
    FH_EXPECT_EQ(read_u16_le(frame.data() + 9), std::uint16_t{0});
}

FH_TEST(encode_rejects_oversize_payload) {
    // event_payload.size() + kMatchEventHeaderBytes > u16 max → refuse
    // (return empty vector) instead of silently truncating.
    std::vector<std::uint8_t> too_big(kMaxPayloadBytes, std::uint8_t{0xAB});
    // too_big.size() == 65535, header adds 7 → exceeds cap.
    const auto frame = encodeMatchEventFrame(
        /*tick_num*/   1u,
        /*event_type*/ 0x09u,
        std::span<const std::uint8_t>(too_big));
    FH_EXPECT_EQ(frame.size(), std::size_t{0});
}

// ---------------------------------------------------------------------------
// Decoder — round-trip + malformed inputs
// ---------------------------------------------------------------------------
FH_TEST(round_trip_goal_frame) {
    const auto payload = encodeGoalPayloadV1(/*region*/ 0, /*kicker*/ 22);
    const std::uint8_t* pay_u8 =
        reinterpret_cast<const std::uint8_t*>(payload.data());
    const auto frame = encodeMatchEventFrame(
        /*tick_num*/   987654321u,
        /*event_type*/ static_cast<std::uint8_t>(EventType::Goal),
        std::span<const std::uint8_t>(pay_u8, payload.size()));

    const auto dec = decodeMatchEventFrame(
        std::span<const std::uint8_t>(frame.data(), frame.size()));
    FH_EXPECT(dec.has_value());
    FH_EXPECT_EQ(dec->tick_num, std::uint32_t{987654321});
    FH_EXPECT_EQ(dec->event_type,
                 static_cast<std::uint8_t>(EventType::Goal));
    FH_EXPECT_EQ(dec->event_payload.size(), kGoalPayloadV1Bytes);
    // Bytes must match the source payload exactly.
    for (std::size_t i = 0; i < kGoalPayloadV1Bytes; ++i) {
        FH_EXPECT_EQ(dec->event_payload[i],
                     static_cast<std::uint8_t>(payload[i]));
    }
}

FH_TEST(round_trip_empty_payload_event) {
    const auto frame = encodeMatchEventFrame(
        /*tick_num*/   42u,
        /*event_type*/ static_cast<std::uint8_t>(EventType::ClientConnect),
        std::span<const std::uint8_t>{});
    const auto dec = decodeMatchEventFrame(
        std::span<const std::uint8_t>(frame.data(), frame.size()));
    FH_EXPECT(dec.has_value());
    FH_EXPECT_EQ(dec->tick_num, std::uint32_t{42});
    FH_EXPECT_EQ(dec->event_type,
                 static_cast<std::uint8_t>(EventType::ClientConnect));
    FH_EXPECT_EQ(dec->event_payload.size(), std::size_t{0});
}

FH_TEST(decode_rejects_short_buffer) {
    std::vector<std::uint8_t> too_short(kFrameHeaderBytes + kMatchEventHeaderBytes - 1,
                                        std::uint8_t{0});
    const auto dec = decodeMatchEventFrame(
        std::span<const std::uint8_t>(too_short.data(), too_short.size()));
    FH_EXPECT(!dec.has_value());
}

FH_TEST(decode_rejects_wrong_version) {
    // Build a valid Goal frame, then flip byte[0] to a bogus version.
    const auto payload = encodeGoalPayloadV1(0, kGoalKickerSlotUnknown);
    const std::uint8_t* pay_u8 =
        reinterpret_cast<const std::uint8_t*>(payload.data());
    auto frame = encodeMatchEventFrame(
        1u, static_cast<std::uint8_t>(EventType::Goal),
        std::span<const std::uint8_t>(pay_u8, payload.size()));
    frame[0] = static_cast<std::uint8_t>(kWireVersionV1 + 1);   // bogus
    const auto dec = decodeMatchEventFrame(
        std::span<const std::uint8_t>(frame.data(), frame.size()));
    FH_EXPECT(!dec.has_value());
}

FH_TEST(decode_rejects_wrong_msg_type) {
    // Flip msg_type to SNAPSHOT — decoder must refuse.
    const auto payload = encodeGoalPayloadV1(0, 0);
    const std::uint8_t* pay_u8 =
        reinterpret_cast<const std::uint8_t*>(payload.data());
    auto frame = encodeMatchEventFrame(
        1u, static_cast<std::uint8_t>(EventType::Goal),
        std::span<const std::uint8_t>(pay_u8, payload.size()));
    frame[1] = static_cast<std::uint8_t>(MsgType::Snapshot);
    const auto dec = decodeMatchEventFrame(
        std::span<const std::uint8_t>(frame.data(), frame.size()));
    FH_EXPECT(!dec.has_value());
}

FH_TEST(decode_rejects_payload_length_mismatch) {
    // Build a Goal frame, then lie about event_payload_len in the
    // MATCH_EVENT header (say the payload is 4 bytes when it's really
    // 5). The mismatch against the outer u16 payload_len must be
    // caught.
    const auto payload = encodeGoalPayloadV1(1, 3);
    const std::uint8_t* pay_u8 =
        reinterpret_cast<const std::uint8_t*>(payload.data());
    auto frame = encodeMatchEventFrame(
        1u, static_cast<std::uint8_t>(EventType::Goal),
        std::span<const std::uint8_t>(pay_u8, payload.size()));
    // event_payload_len is bytes 9..10 in the frame.
    frame[9]  = 0x04;
    frame[10] = 0x00;
    const auto dec = decodeMatchEventFrame(
        std::span<const std::uint8_t>(frame.data(), frame.size()));
    FH_EXPECT(!dec.has_value());
}

FH_TEST_MAIN()
