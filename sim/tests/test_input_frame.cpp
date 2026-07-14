// footballhome sim - InputFrame codec tests

#include "net/InputFrame.hpp"
#include "net/LeCodec.hpp"
#include "net/WireFormat.hpp"
#include "test_harness.hpp"

#include <bit>
#include <cstdint>
#include <cstring>
#include <vector>

using fh::sim::net::decodeInputFrame;
using fh::sim::net::encodeHelloAckFrame;
using fh::sim::net::encodeInputFrame;
using fh::sim::net::kFrameHeaderBytes;
using fh::sim::net::kHelloAckFrameBytes;
using fh::sim::net::kHelloAckPayloadBytes;
using fh::sim::net::kInputFlagWantsSprint;
using fh::sim::net::kInputFlagWantsWalk;
using fh::sim::net::kInputFlagWantsDribble;
using fh::sim::net::kInputFlagWantsRelease;
using fh::sim::net::kInputFrameBytes;
using fh::sim::net::kInputPayloadBytes;
using fh::sim::net::kWireCapSnapshotBallTrailer;
using fh::sim::net::kWireVersionV1;
using fh::sim::net::MsgType;
using fh::sim::net::read_f32_le;
using fh::sim::net::read_u16_le;
using fh::sim::net::read_u32_le;
using fh::sim::net::read_u64_le;

namespace {

std::vector<std::uint8_t> buildInputFrame(std::uint32_t client_tick,
                                          float dir_x, float dir_y,
                                          std::uint8_t flags)
{
    std::vector<std::uint8_t> out(kInputFrameBytes);
    out[0] = kWireVersionV1;
    out[1] = static_cast<std::uint8_t>(MsgType::Input);
    out[2] = static_cast<std::uint8_t>(kInputPayloadBytes & 0xFFu);
    out[3] = static_cast<std::uint8_t>((kInputPayloadBytes >> 8) & 0xFFu);

    const std::uint32_t dx_bits = std::bit_cast<std::uint32_t>(dir_x);
    const std::uint32_t dy_bits = std::bit_cast<std::uint32_t>(dir_y);

    // client_tick
    out[4] = static_cast<std::uint8_t>(client_tick & 0xFFu);
    out[5] = static_cast<std::uint8_t>((client_tick >> 8) & 0xFFu);
    out[6] = static_cast<std::uint8_t>((client_tick >> 16) & 0xFFu);
    out[7] = static_cast<std::uint8_t>((client_tick >> 24) & 0xFFu);
    // dir_x
    out[8]  = static_cast<std::uint8_t>(dx_bits & 0xFFu);
    out[9]  = static_cast<std::uint8_t>((dx_bits >> 8) & 0xFFu);
    out[10] = static_cast<std::uint8_t>((dx_bits >> 16) & 0xFFu);
    out[11] = static_cast<std::uint8_t>((dx_bits >> 24) & 0xFFu);
    // dir_y
    out[12] = static_cast<std::uint8_t>(dy_bits & 0xFFu);
    out[13] = static_cast<std::uint8_t>((dy_bits >> 8) & 0xFFu);
    out[14] = static_cast<std::uint8_t>((dy_bits >> 16) & 0xFFu);
    out[15] = static_cast<std::uint8_t>((dy_bits >> 24) & 0xFFu);
    out[16] = flags;
    out[17] = out[18] = out[19] = 0;
    return out;
}

} // namespace

// ---------------------------------------------------------------------------
// INPUT decoder
// ---------------------------------------------------------------------------
FH_TEST(decode_input_happy_path) {
    const auto bytes = buildInputFrame(42, 1.0F, -0.5F,
                                       static_cast<std::uint8_t>(kInputFlagWantsSprint));
    const auto d = decodeInputFrame(bytes);
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->client_tick, 42u);
    FH_EXPECT(d->desired_dir_x == 1.0F);
    FH_EXPECT(d->desired_dir_y == -0.5F);
    FH_EXPECT(d->wants_sprint);
    FH_EXPECT(!d->wants_walk);
}

FH_TEST(decode_input_walk_flag) {
    const auto bytes = buildInputFrame(1, 0.0F, 0.0F,
                                       static_cast<std::uint8_t>(kInputFlagWantsWalk));
    const auto d = decodeInputFrame(bytes);
    FH_EXPECT(d.has_value());
    FH_EXPECT(!d->wants_sprint);
    FH_EXPECT(d->wants_walk);
}

FH_TEST(decode_input_no_flags) {
    const auto bytes = buildInputFrame(7, 0.0F, 1.0F, 0);
    const auto d = decodeInputFrame(bytes);
    FH_EXPECT(d.has_value());
    FH_EXPECT(!d->wants_sprint);
    FH_EXPECT(!d->wants_walk);
    FH_EXPECT(!d->wants_dribble);
}

// Slice 16.2: bit 2 = wants_dribble. Decoding must recognise it (isolated
// and combined with other flags) and legacy frames with bit 2 = 0 must
// continue to decode as wants_dribble = false.
FH_TEST(decode_input_dribble_flag) {
    const auto bytes = buildInputFrame(9, 0.0F, 0.0F,
                                       static_cast<std::uint8_t>(kInputFlagWantsDribble));
    const auto d = decodeInputFrame(bytes);
    FH_EXPECT(d.has_value());
    FH_EXPECT(!d->wants_sprint);
    FH_EXPECT(!d->wants_walk);
    FH_EXPECT(d->wants_dribble);
}

FH_TEST(decode_input_dribble_combined_with_sprint) {
    const auto bytes = buildInputFrame(9, 0.0F, 0.0F,
                                       static_cast<std::uint8_t>(kInputFlagWantsSprint
                                                                | kInputFlagWantsDribble));
    const auto d = decodeInputFrame(bytes);
    FH_EXPECT(d.has_value());
    FH_EXPECT(d->wants_sprint);
    FH_EXPECT(!d->wants_walk);
    FH_EXPECT(d->wants_dribble);
}

FH_TEST(decode_input_bit_value_locked) {
    // The wire spec (§7.3) numbers bits explicitly; any renumbering would
    // corrupt sim_match_inputs.payload replay across sim versions.
    FH_EXPECT_EQ(kInputFlagWantsSprint,  static_cast<std::uint8_t>(1u << 0));
    FH_EXPECT_EQ(kInputFlagWantsWalk,    static_cast<std::uint8_t>(1u << 1));
    FH_EXPECT_EQ(kInputFlagWantsDribble, static_cast<std::uint8_t>(1u << 2));   // Slice 16.2
    FH_EXPECT_EQ(kInputFlagWantsRelease, static_cast<std::uint8_t>(1u << 3));   // Slice 16.4
}

// Slice 16.4: bit 3 = wants_release. Decoding must recognise it (isolated
// and combined with dribble/sprint), and older frames with bit 3 unset
// continue to decode as wants_release = false.
FH_TEST(decode_input_release_flag) {
    auto bytes = buildInputFrame(42, -1.0F, 2.5F,
                                       static_cast<std::uint8_t>(kInputFlagWantsRelease));
    const auto d = decodeInputFrame(std::span<const std::uint8_t>(bytes));
    FH_EXPECT(d.has_value());
    FH_EXPECT(!d->wants_sprint);
    FH_EXPECT(!d->wants_walk);
    FH_EXPECT(!d->wants_dribble);
    FH_EXPECT(d->wants_release);
}

FH_TEST(decode_input_release_combined_with_dribble) {
    // wants_release AND wants_dribble on the same frame is legal at the
    // wire level — HumanController::decide is where the release-wins
    // semantic collapses wants_dribble to false. The wire decoder just
    // reports both bits faithfully.
    auto bytes = buildInputFrame(1, 0.0F, 0.0F,
                                       static_cast<std::uint8_t>(kInputFlagWantsDribble
                                                                | kInputFlagWantsRelease));
    const auto d = decodeInputFrame(std::span<const std::uint8_t>(bytes));
    FH_EXPECT(d.has_value());
    FH_EXPECT(d->wants_dribble);
    FH_EXPECT(d->wants_release);
}

FH_TEST(encode_input_release_bit_written) {
    // Round-trip: wants_release argument must appear as bit 3 of the
    // encoded flags byte and re-decode as true.
    const auto bytes = encodeInputFrame(/*tick*/ 7,
                                        /*dx*/ 0.0F, /*dy*/ 0.0F,
                                        /*sprint*/ false, /*walk*/ false,
                                        /*dribble*/ false, /*release*/ true);
    FH_EXPECT_EQ(bytes.size(), static_cast<std::size_t>(kInputFrameBytes));
    FH_EXPECT_EQ(bytes[kFrameHeaderBytes + 12] & kInputFlagWantsRelease,
                 static_cast<std::uint8_t>(kInputFlagWantsRelease));
    const auto d = decodeInputFrame(std::span<const std::uint8_t>(bytes));
    FH_EXPECT(d.has_value());
    FH_EXPECT(d->wants_release);
}

FH_TEST(decode_input_rejects_wrong_version) {
    auto bytes = buildInputFrame(1, 0.0F, 0.0F, 0);
    bytes[0] = 0x02;
    FH_EXPECT(!decodeInputFrame(bytes).has_value());
}

FH_TEST(decode_input_rejects_wrong_msg_type) {
    auto bytes = buildInputFrame(1, 0.0F, 0.0F, 0);
    bytes[1] = static_cast<std::uint8_t>(MsgType::Snapshot);
    FH_EXPECT(!decodeInputFrame(bytes).has_value());
}

FH_TEST(decode_input_rejects_wrong_payload_len) {
    auto bytes = buildInputFrame(1, 0.0F, 0.0F, 0);
    // Advertise 17-byte payload; actual frame is still 20 bytes total.
    bytes[2] = 17;
    FH_EXPECT(!decodeInputFrame(bytes).has_value());
}

FH_TEST(decode_input_rejects_short_frame) {
    auto bytes = buildInputFrame(1, 0.0F, 0.0F, 0);
    bytes.pop_back();   // 19 bytes
    FH_EXPECT(!decodeInputFrame(bytes).has_value());
}

FH_TEST(decode_input_rejects_long_frame) {
    auto bytes = buildInputFrame(1, 0.0F, 0.0F, 0);
    bytes.push_back(0);   // 21 bytes
    FH_EXPECT(!decodeInputFrame(bytes).has_value());
}

FH_TEST(decode_input_rejects_empty) {
    FH_EXPECT(!decodeInputFrame({}).has_value());
}

// ---------------------------------------------------------------------------
// HELLO_ACK encoder
// ---------------------------------------------------------------------------
FH_TEST(encode_hello_ack_size_and_header) {
    const auto out = encodeHelloAckFrame(0xDEADBEEF12345678ull, 3u, 20u);
    FH_EXPECT_EQ(out.size(), kHelloAckFrameBytes);
    FH_EXPECT_EQ(out[0], kWireVersionV1);
    FH_EXPECT_EQ(out[1], static_cast<std::uint8_t>(MsgType::HelloAck));
    FH_EXPECT_EQ(read_u16_le(out.data() + 2), kHelloAckPayloadBytes);
}

FH_TEST(encode_hello_ack_payload_bytes) {
    constexpr std::uint64_t kMatch = 0x0123456789ABCDEFull;
    constexpr std::uint16_t kSlot  = 0xABCDu;
    constexpr std::uint32_t kTick  = 20u;
    const auto out = encodeHelloAckFrame(kMatch, kSlot, kTick);
    FH_EXPECT_EQ(read_u64_le(out.data() + kFrameHeaderBytes + 0),  kMatch);
    FH_EXPECT_EQ(read_u16_le(out.data() + kFrameHeaderBytes + 8),  kSlot);
    FH_EXPECT_EQ(read_u32_le(out.data() + kFrameHeaderBytes + 10), kTick);
}

FH_TEST(encode_hello_ack_zero_slot_is_valid) {
    const auto out = encodeHelloAckFrame(1, 0u, 20u);
    FH_EXPECT_EQ(read_u16_le(out.data() + kFrameHeaderBytes + 8), 0u);
}

// ---------------------------------------------------------------------------
// HELLO_ACK v1.1 addendum (Slice 15.4): wire_capability_bits field
// ---------------------------------------------------------------------------
FH_TEST(hello_ack_payload_is_16_bytes) {
    // Slice 15.4 widened HELLO_ACK from 14 → 16 bytes (extra u16 for
    // wire_capability_bits). This test locks the size so future adds don't
    // silently drift the frame layout.
    FH_EXPECT_EQ(kHelloAckPayloadBytes, 16u);
    FH_EXPECT_EQ(kHelloAckFrameBytes,   kFrameHeaderBytes + 16u);
}

FH_TEST(encode_hello_ack_default_capability_bits_are_zero) {
    // Old 3-arg call sites (should be none in the tree post-Slice-15.4) get
    // capability_bits = 0 via the default arg — behaves like M0 for callers
    // that don't opt into the v1.1 trailer.
    const auto out = encodeHelloAckFrame(0xAAAAAAAAAAAAAAAAull, 5u, 20u);
    FH_EXPECT_EQ(out.size(), kHelloAckFrameBytes);
    FH_EXPECT_EQ(read_u16_le(out.data() + kFrameHeaderBytes + 14), 0u);
}

FH_TEST(encode_hello_ack_writes_capability_bits) {
    const auto out = encodeHelloAckFrame(1ull, 2u, 20u, kWireCapSnapshotBallTrailer);
    FH_EXPECT_EQ(out.size(), kHelloAckFrameBytes);
    // wire_capability_bits lives at payload offset 14 (immediately after the
    // 14-byte M0 payload).
    const std::uint16_t cap = read_u16_le(out.data() + kFrameHeaderBytes + 14);
    FH_EXPECT_EQ(cap, kWireCapSnapshotBallTrailer);
    FH_EXPECT((cap & kWireCapSnapshotBallTrailer) != 0u);
}

FH_TEST(encode_hello_ack_capability_bits_are_bitfield) {
    // Verify multiple bits can be OR'd together — the encoder is a passthrough.
    constexpr std::uint16_t kAllKnown = kWireCapSnapshotBallTrailer;
    constexpr std::uint16_t kFuture   = 1u << 15;
    const auto out = encodeHelloAckFrame(1ull, 2u, 20u,
                                         static_cast<std::uint16_t>(kAllKnown | kFuture));
    FH_EXPECT_EQ(read_u16_le(out.data() + kFrameHeaderBytes + 14),
                 static_cast<std::uint16_t>(kAllKnown | kFuture));
}

// ---------------------------------------------------------------------------
// INPUT encoder — Slice 16.2 wants_dribble round-trip
// ---------------------------------------------------------------------------
FH_TEST(encode_input_default_args_have_no_dribble_or_walk) {
    // Legacy 4-arg callers get wants_walk = wants_dribble = false via
    // default args → flags byte should only reflect wants_sprint.
    const auto out = encodeInputFrame(1u, 0.0F, 0.0F, /*wants_sprint=*/true);
    FH_EXPECT_EQ(out.size(), kInputFrameBytes);
    const std::uint8_t flags = out[kFrameHeaderBytes + 12];
    FH_EXPECT_EQ(flags, kInputFlagWantsSprint);
}

FH_TEST(encode_input_wants_dribble_sets_bit_2) {
    const auto out = encodeInputFrame(1u, 0.0F, 0.0F,
                                      /*wants_sprint=*/false,
                                      /*wants_walk=*/false,
                                      /*wants_dribble=*/true);
    FH_EXPECT_EQ(out.size(), kInputFrameBytes);
    const std::uint8_t flags = out[kFrameHeaderBytes + 12];
    FH_EXPECT_EQ(flags, kInputFlagWantsDribble);
}

FH_TEST(encode_input_all_flags_combined) {
    const auto out = encodeInputFrame(42u, 0.5F, -0.25F,
                                      /*wants_sprint=*/true,
                                      /*wants_walk=*/true,
                                      /*wants_dribble=*/true);
    const std::uint8_t flags = out[kFrameHeaderBytes + 12];
    FH_EXPECT_EQ(flags, static_cast<std::uint8_t>(kInputFlagWantsSprint
                                                 | kInputFlagWantsWalk
                                                 | kInputFlagWantsDribble));
    // Reserved bytes stay zero (spec §7.3: `[u8 reserved[3]]`).
    FH_EXPECT_EQ(out[kFrameHeaderBytes + 13], 0u);
    FH_EXPECT_EQ(out[kFrameHeaderBytes + 14], 0u);
    FH_EXPECT_EQ(out[kFrameHeaderBytes + 15], 0u);
}

FH_TEST(encode_input_decode_roundtrip_with_dribble) {
    const auto out = encodeInputFrame(123u, 0.75F, -0.5F,
                                      /*wants_sprint=*/false,
                                      /*wants_walk=*/true,
                                      /*wants_dribble=*/true);
    const auto d = decodeInputFrame(out);
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->client_tick, 123u);
    FH_EXPECT(!d->wants_sprint);
    FH_EXPECT(d->wants_walk);
    FH_EXPECT(d->wants_dribble);
}

FH_TEST_MAIN()
