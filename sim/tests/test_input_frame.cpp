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
using fh::sim::net::kFrameHeaderBytes;
using fh::sim::net::kHelloAckFrameBytes;
using fh::sim::net::kHelloAckPayloadBytes;
using fh::sim::net::kInputFlagWantsSprint;
using fh::sim::net::kInputFlagWantsWalk;
using fh::sim::net::kInputFrameBytes;
using fh::sim::net::kInputPayloadBytes;
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

FH_TEST_MAIN()
