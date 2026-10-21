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
using fh::sim::net::kInputFlagWantsKick;
using fh::sim::net::kInputFlagWantsRelease;
using fh::sim::net::kInputFrameBaselineBytes;
using fh::sim::net::kInputFrameWithKickBytes;
using fh::sim::net::kInputKickRegionBytes;
using fh::sim::net::kInputPayloadBaselineBytes;
using fh::sim::net::kInputPayloadWithKickBytes;
using fh::sim::net::kInputTrailerLenBytes;
using fh::sim::net::kKickDirMaxMagnitude;
using fh::sim::net::kKickDirMinMagnitude;
using fh::sim::net::kWireCapInputKickTrailer;
using fh::sim::net::kWireCapScenarioMeta;
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
    std::vector<std::uint8_t> out(kInputFrameBaselineBytes);
    out[0] = kWireVersionV1;
    out[1] = static_cast<std::uint8_t>(MsgType::Input);
    out[2] = static_cast<std::uint8_t>(kInputPayloadBaselineBytes & 0xFFu);
    out[3] = static_cast<std::uint8_t>((kInputPayloadBaselineBytes >> 8) & 0xFFu);

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
    FH_EXPECT_EQ(bytes.size(), static_cast<std::size_t>(kInputFrameBaselineBytes));
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
    constexpr std::uint16_t kAllKnown =
        static_cast<std::uint16_t>(kWireCapSnapshotBallTrailer
                                   | kWireCapScenarioMeta);
    constexpr std::uint16_t kFuture   = 1u << 15;
    const auto out = encodeHelloAckFrame(1ull, 2u, 20u,
                                         static_cast<std::uint16_t>(kAllKnown | kFuture));
    FH_EXPECT_EQ(read_u16_le(out.data() + kFrameHeaderBytes + 14),
                 static_cast<std::uint16_t>(kAllKnown | kFuture));
}

// Slice 17.7a: the ScenarioMeta capability bit MUST occupy bit 1
// specifically. Any renumbering silently breaks the JS decoder mirror
// (which hard-codes the bit position too) — pin the value.
FH_TEST(scenario_meta_capability_bit_is_bit_one) {
    FH_EXPECT_EQ(kWireCapScenarioMeta, static_cast<std::uint16_t>(1u << 1));
    // Must not collide with the Slice 15.4 bit-0 cap.
    FH_EXPECT((kWireCapSnapshotBallTrailer & kWireCapScenarioMeta) == 0u);
}

// ---------------------------------------------------------------------------
// INPUT encoder — Slice 16.2 wants_dribble round-trip
// ---------------------------------------------------------------------------
FH_TEST(encode_input_default_args_have_no_dribble_or_walk) {
    // Legacy 4-arg callers get wants_walk = wants_dribble = false via
    // default args → flags byte should only reflect wants_sprint.
    const auto out = encodeInputFrame(1u, 0.0F, 0.0F, /*wants_sprint=*/true);
    FH_EXPECT_EQ(out.size(), kInputFrameBaselineBytes);
    const std::uint8_t flags = out[kFrameHeaderBytes + 12];
    FH_EXPECT_EQ(flags, kInputFlagWantsSprint);
}

FH_TEST(encode_input_wants_dribble_sets_bit_2) {
    const auto out = encodeInputFrame(1u, 0.0F, 0.0F,
                                      /*wants_sprint=*/false,
                                      /*wants_walk=*/false,
                                      /*wants_dribble=*/true);
    FH_EXPECT_EQ(out.size(), kInputFrameBaselineBytes);
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

// ===========================================================================
// Slice 26.2 (ADR §22.23) — INPUT frame length-prefixed kick trailer.
// ===========================================================================

// Byte-identity: an INPUT frame with wants_kick=false MUST encode to the
// EXACT same bytes it did before Slice 26.2. This is the core
// backward-compat guarantee — sim_match_inputs.payload rows written by
// pre-26.2 servers replay with byte-identical intent, and ops decoders
// keyed on the M0 20-byte frame keep working.
FH_TEST(no_kick_input_matches_m0_bytes) {
    // Reference encoding: the 7-arg pre-26.2 call. Slice 26.2 kept the
    // same signature (default-args added at the end) so this call
    // compiles and produces the same bytes as pre-26.2.
    const auto ref = encodeInputFrame(/*tick*/ 12345u,
                                      /*dx*/ 0.6F, /*dy*/ -0.8F,
                                      /*sprint*/ true, /*walk*/ false,
                                      /*dribble*/ true, /*release*/ false);
    FH_EXPECT_EQ(ref.size(), kInputFrameBaselineBytes);

    // New call with wants_kick=false + garbage kick fields (must be
    // ignored — no bytes for them are emitted). Must produce identical
    // bytes.
    const auto out = encodeInputFrame(/*tick*/ 12345u,
                                      /*dx*/ 0.6F, /*dy*/ -0.8F,
                                      /*sprint*/ true, /*walk*/ false,
                                      /*dribble*/ true, /*release*/ false,
                                      /*wants_kick*/ false,
                                      /*kick_dx*/ 999.0F,
                                      /*kick_dy*/ -777.0F,
                                      /*kick_power_hint*/ 65535u);
    FH_EXPECT_EQ(out.size(), kInputFrameBaselineBytes);
    for (std::size_t i = 0; i < ref.size(); ++i) {
        FH_EXPECT_EQ(ref[i], out[i]);
    }

    // Payload_sz field must be 16 (baseline).
    FH_EXPECT_EQ(read_u16_le(out.data() + 2),
                 static_cast<std::uint16_t>(kInputPayloadBaselineBytes));
    // Bit 4 (wants_kick) MUST be clear.
    FH_EXPECT_EQ(out[kFrameHeaderBytes + 12] & kInputFlagWantsKick,
                 static_cast<std::uint8_t>(0));
}

// The kick bit MUST be bit 4. Any renumbering would corrupt
// sim_match_inputs.payload replay across sim versions.
FH_TEST(kick_flag_bit_value_locked) {
    FH_EXPECT_EQ(kInputFlagWantsKick, static_cast<std::uint8_t>(1u << 4));
    // Must not collide with any earlier flag.
    FH_EXPECT((kInputFlagWantsKick & kInputFlagWantsSprint)  == 0u);
    FH_EXPECT((kInputFlagWantsKick & kInputFlagWantsWalk)    == 0u);
    FH_EXPECT((kInputFlagWantsKick & kInputFlagWantsDribble) == 0u);
    FH_EXPECT((kInputFlagWantsKick & kInputFlagWantsRelease) == 0u);
}

// The InputKickTrailer capability MUST be bit 3 of wire_capability_bits.
// The JS mirror in frontend/js/sim/wire.js hard-codes the same bit, so
// pinning it here catches accidental renumbering.
FH_TEST(input_kick_trailer_capability_bit_is_bit_three) {
    FH_EXPECT_EQ(kWireCapInputKickTrailer, static_cast<std::uint16_t>(1u << 3));
    // Must not collide with the Slice 15.4 / 17.7a caps.
    FH_EXPECT((kWireCapInputKickTrailer & kWireCapSnapshotBallTrailer) == 0u);
    FH_EXPECT((kWireCapInputKickTrailer & kWireCapScenarioMeta)        == 0u);
}

// Frame-size constants must land at exactly the ADR §22.23 values so any
// silent redefinition fails the build.
FH_TEST(kick_trailer_size_constants_locked) {
    FH_EXPECT_EQ(kInputPayloadBaselineBytes, 16u);
    FH_EXPECT_EQ(kInputTrailerLenBytes,       2u);
    FH_EXPECT_EQ(kInputKickRegionBytes,      10u);
    FH_EXPECT_EQ(kInputPayloadWithKickBytes, 28u);
    FH_EXPECT_EQ(kInputFrameBaselineBytes,   20u);   // 4 header + 16
    FH_EXPECT_EQ(kInputFrameWithKickBytes,   32u);   // 4 header + 28
}

// Happy path: encode a kick INPUT, verify size + wire layout, decode
// back and get the same values.
FH_TEST(encode_input_with_kick_roundtrip) {
    const auto out = encodeInputFrame(/*tick*/ 42u,
                                      /*dx*/ 0.0F, /*dy*/ 0.0F,
                                      /*sprint*/ false, /*walk*/ false,
                                      /*dribble*/ true, /*release*/ false,
                                      /*wants_kick*/ true,
                                      /*kick_dx*/ 1.0F, /*kick_dy*/ 0.0F,
                                      /*kick_power_hint*/ 20u);
    FH_EXPECT_EQ(out.size(), kInputFrameWithKickBytes);
    FH_EXPECT_EQ(read_u16_le(out.data() + 2),
                 static_cast<std::uint16_t>(kInputPayloadWithKickBytes));
    FH_EXPECT_EQ(out[kFrameHeaderBytes + 12] & kInputFlagWantsKick,
                 static_cast<std::uint8_t>(kInputFlagWantsKick));
    // Trailer-len prefix at payload offset 16 = frame offset 20.
    FH_EXPECT_EQ(read_u16_le(out.data() + kFrameHeaderBytes + 16),
                 static_cast<std::uint16_t>(kInputKickRegionBytes));

    const auto d = decodeInputFrame(out);
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->client_tick, 42u);
    FH_EXPECT(d->wants_dribble);
    FH_EXPECT(d->wants_kick);
    FH_EXPECT(d->kick_dir_x == 1.0F);
    FH_EXPECT(d->kick_dir_y == 0.0F);
    FH_EXPECT_EQ(d->kick_power_hint, 20u);
}

// kick_power_hint = 0 means "server picks from physical.pass_power".
// Wire encoder must faithfully carry the zero.
FH_TEST(encode_input_kick_power_hint_zero_roundtrip) {
    const auto out = encodeInputFrame(1u, 0.0F, 0.0F,
                                      false, false, false, false,
                                      /*wants_kick*/ true,
                                      /*kick_dx*/ 0.0F, /*kick_dy*/ 1.0F,
                                      /*kick_power_hint*/ 0u);
    const auto d = decodeInputFrame(out);
    FH_EXPECT(d.has_value());
    FH_EXPECT(d->wants_kick);
    FH_EXPECT_EQ(d->kick_power_hint, 0u);
}

// Reject: baseline 20-byte frame with the wants_kick bit set. The bit
// would lie about the trailer being present. Malformed → nullopt.
FH_TEST(decode_input_rejects_baseline_with_kick_bit_set) {
    auto bytes = buildInputFrame(1, 0.0F, 0.0F, kInputFlagWantsKick);
    FH_EXPECT_EQ(bytes.size(), kInputFrameBaselineBytes);
    FH_EXPECT(!decodeInputFrame(bytes).has_value());
}

// Reject: 32-byte kick-shaped frame with the wants_kick bit clear. The
// client attached a trailer but claimed no kick — spoof or bug, drop it.
FH_TEST(decode_input_rejects_with_kick_frame_bit_clear) {
    // Start from a valid kick encoding, then clear bit 4.
    auto bytes = encodeInputFrame(1u, 0.0F, 0.0F, false, false, false, false,
                                  /*wants_kick*/ true,
                                  /*kick_dx*/ 1.0F, /*kick_dy*/ 0.0F,
                                  /*kick_power_hint*/ 0u);
    FH_EXPECT_EQ(bytes.size(), kInputFrameWithKickBytes);
    bytes[kFrameHeaderBytes + 12] &= static_cast<std::uint8_t>(~kInputFlagWantsKick);
    FH_EXPECT(!decodeInputFrame(bytes).has_value());
}

// Reject: 21-byte frame is between baseline (20) and with-kick (32) —
// neither length is legitimate. Also rejects 31-byte, 17-byte, etc.
FH_TEST(decode_input_rejects_between_baseline_and_kick_lengths) {
    auto bytes = buildInputFrame(1, 0.0F, 0.0F, 0);
    bytes.push_back(0);   // 21 bytes
    FH_EXPECT(!decodeInputFrame(bytes).has_value());

    // 17 bytes (impossible header, but exercise the length dispatch).
    std::vector<std::uint8_t> short17(17, 0);
    short17[0] = kWireVersionV1;
    short17[1] = static_cast<std::uint8_t>(MsgType::Input);
    short17[2] = 13;   // fake payload_sz
    FH_EXPECT(!decodeInputFrame(short17).has_value());

    // 31 bytes (one shy of with-kick).
    std::vector<std::uint8_t> short31(31, 0);
    short31[0] = kWireVersionV1;
    short31[1] = static_cast<std::uint8_t>(MsgType::Input);
    short31[2] = static_cast<std::uint8_t>(kInputPayloadWithKickBytes);
    FH_EXPECT(!decodeInputFrame(short31).has_value());
}

// Reject: 32-byte kick frame where the trailer_len prefix lies. Only
// exactly-10 is accepted; anything else (0, 9, 11, 1000) is rejected.
FH_TEST(decode_input_rejects_kick_frame_with_wrong_trailer_len) {
    auto ref = encodeInputFrame(1u, 0.0F, 0.0F, false, false, false, false,
                                /*wants_kick*/ true,
                                /*kick_dx*/ 1.0F, /*kick_dy*/ 0.0F,
                                /*kick_power_hint*/ 0u);
    FH_EXPECT_EQ(ref.size(), kInputFrameWithKickBytes);

    // trailer_len = 0
    {
        auto b = ref;
        b[kFrameHeaderBytes + kInputPayloadBaselineBytes    ] = 0;
        b[kFrameHeaderBytes + kInputPayloadBaselineBytes + 1] = 0;
        FH_EXPECT(!decodeInputFrame(b).has_value());
    }
    // trailer_len = 9 (< 10)
    {
        auto b = ref;
        b[kFrameHeaderBytes + kInputPayloadBaselineBytes    ] = 9;
        b[kFrameHeaderBytes + kInputPayloadBaselineBytes + 1] = 0;
        FH_EXPECT(!decodeInputFrame(b).has_value());
    }
    // trailer_len = 11 (> 10)
    {
        auto b = ref;
        b[kFrameHeaderBytes + kInputPayloadBaselineBytes    ] = 11;
        b[kFrameHeaderBytes + kInputPayloadBaselineBytes + 1] = 0;
        FH_EXPECT(!decodeInputFrame(b).has_value());
    }
    // trailer_len = 0xFFFF (silly sentinel)
    {
        auto b = ref;
        b[kFrameHeaderBytes + kInputPayloadBaselineBytes    ] = 0xFFu;
        b[kFrameHeaderBytes + kInputPayloadBaselineBytes + 1] = 0xFFu;
        FH_EXPECT(!decodeInputFrame(b).has_value());
    }
}

// Reject: kick direction magnitude outside [0.5, 1.5]. Guards against
// clients that forget to normalise a screen-space delta.
FH_TEST(decode_input_rejects_off_unit_kick_direction) {
    // Too small (~0.1 unit).
    {
        const auto b = encodeInputFrame(1u, 0.0F, 0.0F, false, false, false, false,
                                        /*wants_kick*/ true,
                                        /*kick_dx*/ 0.1F, /*kick_dy*/ 0.0F, 0u);
        FH_EXPECT(!decodeInputFrame(b).has_value());
    }
    // Too big (~100 units — mimics an un-scaled pixel delta).
    {
        const auto b = encodeInputFrame(1u, 0.0F, 0.0F, false, false, false, false,
                                        /*wants_kick*/ true,
                                        /*kick_dx*/ 100.0F, /*kick_dy*/ 0.0F, 0u);
        FH_EXPECT(!decodeInputFrame(b).has_value());
    }
    // Zero vector (magnitude 0 — no direction).
    {
        const auto b = encodeInputFrame(1u, 0.0F, 0.0F, false, false, false, false,
                                        /*wants_kick*/ true,
                                        /*kick_dx*/ 0.0F, /*kick_dy*/ 0.0F, 0u);
        FH_EXPECT(!decodeInputFrame(b).has_value());
    }
    // Boundary: exactly 0.5 unit passes.
    {
        const auto b = encodeInputFrame(1u, 0.0F, 0.0F, false, false, false, false,
                                        /*wants_kick*/ true,
                                        /*kick_dx*/ 0.5F, /*kick_dy*/ 0.0F, 0u);
        const auto d = decodeInputFrame(b);
        FH_EXPECT(d.has_value());
        FH_EXPECT(d && d->wants_kick);
    }
    // Boundary: exactly 1.5 unit passes.
    {
        const auto b = encodeInputFrame(1u, 0.0F, 0.0F, false, false, false, false,
                                        /*wants_kick*/ true,
                                        /*kick_dx*/ 1.5F, /*kick_dy*/ 0.0F, 0u);
        const auto d = decodeInputFrame(b);
        FH_EXPECT(d.has_value());
        FH_EXPECT(d && d->wants_kick);
    }
}

// Legacy 7-arg callers (pre-26.2) that never opt into wants_kick must
// keep compiling and produce byte-identical output vs the 11-arg call
// with wants_kick=false. Covered by no_kick_input_matches_m0_bytes but
// this test locks the encoded size specifically.
FH_TEST(encode_input_default_kick_args_stay_baseline_size) {
    const auto a = encodeInputFrame(1u, 0.0F, 0.0F, true, true, true, true);
    FH_EXPECT_EQ(a.size(), kInputFrameBaselineBytes);
}

FH_TEST_MAIN()
