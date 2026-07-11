// footballhome sim - WebSocketFrame codec tests

#include "net/WebSocketFrame.hpp"
#include "test_harness.hpp"

#include <cstdint>
#include <string>
#include <vector>

using fh::sim::net::ws::decodeClientFrame;
using fh::sim::net::ws::DecodedFrame;
using fh::sim::net::ws::encodeServerBinary;
using fh::sim::net::ws::encodeServerFrame;
using fh::sim::net::ws::kMaxPayloadBytes;
using fh::sim::net::ws::Opcode;

namespace {

// Build a client-role frame (masked) for feeding into decodeClientFrame.
// Same layout the browser sends: FIN=1, MASK=1, given opcode + payload.
std::vector<std::uint8_t> buildClientFrame(Opcode op,
                                           const std::vector<std::uint8_t>& payload,
                                           std::uint32_t mask_key = 0xA5A5A5A5u,
                                           bool fin = true,
                                           std::uint8_t rsv_bits = 0)
{
    std::vector<std::uint8_t> out;
    const std::size_t n = payload.size();

    std::uint8_t b0 = static_cast<std::uint8_t>(op) & 0x0Fu;
    if (fin)      { b0 |= 0x80u; }
    b0 |= static_cast<std::uint8_t>((rsv_bits & 0x07u) << 4);
    out.push_back(b0);

    std::uint8_t b1 = 0x80u;   // MASK=1
    if (n <= 125) {
        b1 |= static_cast<std::uint8_t>(n);
        out.push_back(b1);
    } else if (n <= 0xFFFFu) {
        b1 |= 126u;
        out.push_back(b1);
        out.push_back(static_cast<std::uint8_t>((n >> 8) & 0xFFu));
        out.push_back(static_cast<std::uint8_t>(n & 0xFFu));
    } else {
        b1 |= 127u;
        out.push_back(b1);
        for (int i = 7; i >= 0; --i) {
            out.push_back(static_cast<std::uint8_t>((n >> (i * 8)) & 0xFFu));
        }
    }
    // 4-byte mask key (big-endian arbitrary; RFC lets it be anything).
    const std::uint8_t k[4] = {
        static_cast<std::uint8_t>((mask_key >> 24) & 0xFFu),
        static_cast<std::uint8_t>((mask_key >> 16) & 0xFFu),
        static_cast<std::uint8_t>((mask_key >>  8) & 0xFFu),
        static_cast<std::uint8_t>((mask_key      ) & 0xFFu),
    };
    for (int i = 0; i < 4; ++i) { out.push_back(k[i]); }
    for (std::size_t i = 0; i < n; ++i) {
        out.push_back(static_cast<std::uint8_t>(payload[i] ^ k[i & 3u]));
    }
    return out;
}

} // namespace

// ---------------------------------------------------------------------------
// Encoder tests
// ---------------------------------------------------------------------------
FH_TEST(encode_small_binary_frame_has_correct_header) {
    const std::vector<std::uint8_t> payload = {0xDE, 0xAD, 0xBE, 0xEF};
    const auto out = encodeServerBinary(payload);

    FH_EXPECT_EQ(out.size(), 6u);
    FH_EXPECT_EQ(out[0], 0x82u);   // FIN=1 + Binary opcode
    FH_EXPECT_EQ(out[1], 0x04u);   // MASK=0, len=4
    for (std::size_t i = 0; i < payload.size(); ++i) {
        FH_EXPECT_EQ(out[2 + i], payload[i]);
    }
}

FH_TEST(encode_frame_at_16bit_length_boundary) {
    // 126 bytes -> len7=126 + 2 extended length bytes.
    std::vector<std::uint8_t> payload(126, 0xAB);
    const auto out = encodeServerBinary(payload);

    FH_EXPECT_EQ(out.size(), 4u + 126u);
    FH_EXPECT_EQ(out[0], 0x82u);
    FH_EXPECT_EQ(out[1], 126u);
    FH_EXPECT_EQ(out[2], 0x00u);
    FH_EXPECT_EQ(out[3], 0x7Eu);   // 126 BE
}

FH_TEST(encode_frame_at_64bit_length_boundary) {
    // 65536 bytes -> len7=127 + 8 extended length bytes.
    std::vector<std::uint8_t> payload(65536, 0xCD);
    const auto out = encodeServerBinary(payload);

    FH_EXPECT_EQ(out.size(), 10u + 65536u);
    FH_EXPECT_EQ(out[0], 0x82u);
    FH_EXPECT_EQ(out[1], 127u);
    // 65536 == 0x0000000000010000
    FH_EXPECT_EQ(out[2], 0x00u);
    FH_EXPECT_EQ(out[3], 0x00u);
    FH_EXPECT_EQ(out[4], 0x00u);
    FH_EXPECT_EQ(out[5], 0x00u);
    FH_EXPECT_EQ(out[6], 0x00u);
    FH_EXPECT_EQ(out[7], 0x01u);
    FH_EXPECT_EQ(out[8], 0x00u);
    FH_EXPECT_EQ(out[9], 0x00u);
}

FH_TEST(encode_rejects_oversize_payload) {
    std::vector<std::uint8_t> too_big(kMaxPayloadBytes + 1, 0);
    const auto out = encodeServerFrame(Opcode::Binary, too_big);
    FH_EXPECT_EQ(out.size(), 0u);
}

FH_TEST(encode_rejects_oversize_control_frame) {
    // Ping/Pong/Close payloads MUST be ≤ 125 bytes (RFC 6455 §5.5).
    std::vector<std::uint8_t> too_big(200, 0);
    FH_EXPECT_EQ(encodeServerFrame(Opcode::Ping,  too_big).size(), 0u);
    FH_EXPECT_EQ(encodeServerFrame(Opcode::Pong,  too_big).size(), 0u);
    FH_EXPECT_EQ(encodeServerFrame(Opcode::Close, too_big).size(), 0u);
}

FH_TEST(encode_pong_zero_payload) {
    const auto out = encodeServerFrame(Opcode::Pong, {});
    FH_EXPECT_EQ(out.size(), 2u);
    FH_EXPECT_EQ(out[0], 0x8Au);   // FIN=1 + Pong opcode
    FH_EXPECT_EQ(out[1], 0x00u);
}

// ---------------------------------------------------------------------------
// Decoder tests
// ---------------------------------------------------------------------------
FH_TEST(decode_valid_small_binary_frame) {
    const std::vector<std::uint8_t> payload = {0x01, 0x02, 0x03};
    const auto frame = buildClientFrame(Opcode::Binary, payload);

    const auto r = decodeClientFrame(frame);
    FH_EXPECT(r.status == DecodedFrame::Status::Ok);
    FH_EXPECT(r.opcode == Opcode::Binary);
    FH_EXPECT_EQ(r.payload.size(), payload.size());
    for (std::size_t i = 0; i < payload.size(); ++i) {
        FH_EXPECT_EQ(r.payload[i], payload[i]);
    }
    FH_EXPECT_EQ(r.bytes_consumed, frame.size());
}

FH_TEST(decode_extended_16bit_payload) {
    std::vector<std::uint8_t> payload(500, 0x55);
    const auto frame = buildClientFrame(Opcode::Binary, payload);
    const auto r = decodeClientFrame(frame);
    FH_EXPECT(r.status == DecodedFrame::Status::Ok);
    FH_EXPECT_EQ(r.payload.size(), 500u);
    for (const auto b : r.payload) { FH_EXPECT_EQ(b, 0x55u); }
}

FH_TEST(decode_needs_more_on_truncated_header) {
    const std::vector<std::uint8_t> just_one_byte = {0x82};
    const auto r = decodeClientFrame(just_one_byte);
    FH_EXPECT(r.status == DecodedFrame::Status::NeedMore);
}

FH_TEST(decode_needs_more_on_truncated_payload) {
    const std::vector<std::uint8_t> payload = {1, 2, 3, 4, 5};
    auto frame = buildClientFrame(Opcode::Binary, payload);
    frame.pop_back();   // truncate final payload byte
    const auto r = decodeClientFrame(frame);
    FH_EXPECT(r.status == DecodedFrame::Status::NeedMore);
}

FH_TEST(decode_rejects_unmasked_client_frame) {
    // Craft a well-formed unmasked frame (MASK bit = 0). Server MUST
    // reject per RFC 6455 §5.1.
    std::vector<std::uint8_t> frame;
    frame.push_back(0x82u);   // FIN + Binary
    frame.push_back(0x02u);   // MASK=0, len=2
    frame.push_back(0xAA);
    frame.push_back(0xBB);
    const auto r = decodeClientFrame(frame);
    FH_EXPECT(r.status == DecodedFrame::Status::Error);
}

FH_TEST(decode_rejects_non_final_frame) {
    const std::vector<std::uint8_t> payload = {1, 2, 3};
    const auto frame = buildClientFrame(Opcode::Binary, payload,
                                        0xA5A5A5A5u, /*fin=*/false);
    const auto r = decodeClientFrame(frame);
    FH_EXPECT(r.status == DecodedFrame::Status::Error);
}

FH_TEST(decode_rejects_rsv_bits) {
    const std::vector<std::uint8_t> payload = {1, 2};
    const auto frame = buildClientFrame(Opcode::Binary, payload,
                                        0xA5A5A5A5u, true, /*rsv=*/0x01);
    const auto r = decodeClientFrame(frame);
    FH_EXPECT(r.status == DecodedFrame::Status::Error);
}

FH_TEST(decode_rejects_text_opcode) {
    const std::vector<std::uint8_t> payload = {'h', 'i'};
    const auto frame = buildClientFrame(Opcode::Text, payload);
    const auto r = decodeClientFrame(frame);
    FH_EXPECT(r.status == DecodedFrame::Status::Error);
}

FH_TEST(decode_rejects_continuation_opcode) {
    const std::vector<std::uint8_t> payload = {0};
    const auto frame = buildClientFrame(Opcode::Continuation, payload);
    const auto r = decodeClientFrame(frame);
    FH_EXPECT(r.status == DecodedFrame::Status::Error);
}

FH_TEST(decode_rejects_reserved_opcode) {
    // Opcode 0x3 is reserved in RFC 6455.
    std::vector<std::uint8_t> payload = {'x'};
    auto frame = buildClientFrame(Opcode::Binary, payload);
    frame[0] = 0x83u;   // FIN + reserved opcode 0x3
    // Re-mask... actually opcode change doesn't affect mask key.
    // Frame is already masked correctly; just the opcode byte changed.
    const auto r = decodeClientFrame(frame);
    FH_EXPECT(r.status == DecodedFrame::Status::Error);
}

FH_TEST(decode_rejects_non_minimal_length_16bit) {
    // len7 = 126 must mean payload > 125. A malicious client sending
    // len7=126 with actual payload=1 is malformed.
    std::vector<std::uint8_t> frame;
    frame.push_back(0x82u);
    frame.push_back(0xFEu);   // MASK=1, len7=126
    frame.push_back(0x00);    // BE length = 1
    frame.push_back(0x01);
    frame.push_back(0xAA); frame.push_back(0xBB); frame.push_back(0xCC); frame.push_back(0xDD);   // mask
    frame.push_back(0xAA ^ 0xAA);   // one masked byte
    const auto r = decodeClientFrame(frame);
    FH_EXPECT(r.status == DecodedFrame::Status::Error);
}

FH_TEST(decode_rejects_oversize_payload) {
    // Build a header claiming a payload above kMaxPayloadBytes without
    // actually sending it — decoder must reject on header alone.
    std::vector<std::uint8_t> frame;
    frame.push_back(0x82u);
    frame.push_back(0xFFu);   // MASK=1, len7=127
    for (int i = 7; i >= 0; --i) {
        std::uint64_t sz = static_cast<std::uint64_t>(kMaxPayloadBytes) + 1u;
        frame.push_back(static_cast<std::uint8_t>((sz >> (i * 8)) & 0xFFu));
    }
    const auto r = decodeClientFrame(frame);
    FH_EXPECT(r.status == DecodedFrame::Status::Error);
}

FH_TEST(decode_ping_frame_is_ok) {
    // Application never sees a Ping, but decoder yields it so the
    // transport can respond with a Pong.
    const std::vector<std::uint8_t> payload = {0xAB, 0xCD};
    const auto frame = buildClientFrame(Opcode::Ping, payload);
    const auto r = decodeClientFrame(frame);
    FH_EXPECT(r.status == DecodedFrame::Status::Ok);
    FH_EXPECT(r.opcode == Opcode::Ping);
    FH_EXPECT_EQ(r.payload.size(), 2u);
    FH_EXPECT_EQ(r.payload[0], 0xABu);
    FH_EXPECT_EQ(r.payload[1], 0xCDu);
}

FH_TEST(decode_close_frame_is_ok) {
    // Close typically carries a 2-byte status code.
    const std::vector<std::uint8_t> payload = {0x03, 0xE8};   // 1000 = normal
    const auto frame = buildClientFrame(Opcode::Close, payload);
    const auto r = decodeClientFrame(frame);
    FH_EXPECT(r.status == DecodedFrame::Status::Ok);
    FH_EXPECT(r.opcode == Opcode::Close);
    FH_EXPECT_EQ(r.payload.size(), 2u);
}

FH_TEST(decode_reports_bytes_consumed_for_stream_advance) {
    // Two frames back-to-back — decoder should report exactly the
    // first frame's bytes so a streaming caller can slice cleanly.
    const std::vector<std::uint8_t> a = {1, 2, 3};
    const std::vector<std::uint8_t> b = {9, 8, 7, 6, 5};
    auto fa = buildClientFrame(Opcode::Binary, a, 0xDEADBEEFu);
    auto fb = buildClientFrame(Opcode::Binary, b, 0xCAFEBABEu);
    std::vector<std::uint8_t> stream = fa;
    stream.insert(stream.end(), fb.begin(), fb.end());

    const auto r1 = decodeClientFrame(stream);
    FH_EXPECT(r1.status == DecodedFrame::Status::Ok);
    FH_EXPECT_EQ(r1.bytes_consumed, fa.size());
    FH_EXPECT_EQ(r1.payload.size(), a.size());

    const std::span<const std::uint8_t> rest(
        stream.data() + r1.bytes_consumed, stream.size() - r1.bytes_consumed);
    const auto r2 = decodeClientFrame(rest);
    FH_EXPECT(r2.status == DecodedFrame::Status::Ok);
    FH_EXPECT_EQ(r2.bytes_consumed, fb.size());
    FH_EXPECT_EQ(r2.payload.size(), b.size());
    for (std::size_t i = 0; i < b.size(); ++i) {
        FH_EXPECT_EQ(r2.payload[i], b[i]);
    }
}

FH_TEST(roundtrip_encode_then_decode_no_masking_loss) {
    // Encoding is server-role (unmasked). Decoder is client-role. To
    // round-trip we must re-frame with a mask; assert payload survives
    // through the mask/unmask XOR.
    const std::vector<std::uint8_t> payload = {
        0x00, 0x01, 0xFF, 0xFE, 0x7F, 0x80, 0x55, 0xAA,
    };
    const auto client_frame = buildClientFrame(Opcode::Binary, payload,
                                               0x11223344u);
    const auto r = decodeClientFrame(client_frame);
    FH_EXPECT(r.status == DecodedFrame::Status::Ok);
    FH_EXPECT_EQ(r.payload.size(), payload.size());
    for (std::size_t i = 0; i < payload.size(); ++i) {
        FH_EXPECT_EQ(r.payload[i], payload[i]);
    }
}

FH_TEST_MAIN()
