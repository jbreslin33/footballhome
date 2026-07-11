// footballhome sim - RFC 6455 WebSocket frame codec implementation

#include "net/WebSocketFrame.hpp"

#include <cstddef>
#include <cstdint>
#include <cstring>

namespace fh::sim::net::ws {

namespace {

// -----------------------------------------------------------------------
// RFC 6455 §5.2 — the fixed 2-byte prefix on every frame:
//   byte0: FIN(1) | RSV1(1) | RSV2(1) | RSV3(1) | opcode(4)
//   byte1: MASK(1) | payload_len(7)
// Followed by:
//   * 0 extra length bytes if payload_len ≤ 125
//   * 2 big-endian length bytes if payload_len == 126
//   * 8 big-endian length bytes if payload_len == 127
// Followed by:
//   * 4 masking key bytes iff MASK == 1
//   * payload
// -----------------------------------------------------------------------

// Big-endian reads (WebSocket is BE, unlike our fh-sim.v1 wire which is LE).
std::uint16_t read_u16_be(const std::uint8_t* p) noexcept {
    return static_cast<std::uint16_t>(
        (static_cast<std::uint16_t>(p[0]) << 8) | static_cast<std::uint16_t>(p[1]));
}

std::uint64_t read_u64_be(const std::uint8_t* p) noexcept {
    std::uint64_t v = 0;
    for (int i = 0; i < 8; ++i) {
        v = (v << 8) | static_cast<std::uint64_t>(p[i]);
    }
    return v;
}

void write_u16_be(std::uint8_t* p, std::uint16_t v) noexcept {
    p[0] = static_cast<std::uint8_t>((v >> 8) & 0xFFu);
    p[1] = static_cast<std::uint8_t>(v & 0xFFu);
}

void write_u64_be(std::uint8_t* p, std::uint64_t v) noexcept {
    for (int i = 7; i >= 0; --i) {
        p[i] = static_cast<std::uint8_t>(v & 0xFFu);
        v >>= 8;
    }
}

bool isKnownOpcode(std::uint8_t op) noexcept {
    return op == static_cast<std::uint8_t>(Opcode::Continuation)
        || op == static_cast<std::uint8_t>(Opcode::Text)
        || op == static_cast<std::uint8_t>(Opcode::Binary)
        || op == static_cast<std::uint8_t>(Opcode::Close)
        || op == static_cast<std::uint8_t>(Opcode::Ping)
        || op == static_cast<std::uint8_t>(Opcode::Pong);
}

bool isControlOpcode(std::uint8_t op) noexcept {
    return (op & 0x8u) != 0;
}

} // namespace

// ---------------------------------------------------------------------------
// encodeServerFrame — always FIN=1, unmasked.
// ---------------------------------------------------------------------------
std::vector<std::uint8_t> encodeServerFrame(Opcode opcode,
                                            std::span<const std::uint8_t> payload)
{
    const std::size_t n = payload.size();
    if (n > kMaxPayloadBytes) { return {}; }

    // RFC 6455 §5.5: control frame payload MUST NOT exceed 125 bytes.
    if (isControlOpcode(static_cast<std::uint8_t>(opcode)) && n > 125) {
        return {};
    }

    std::size_t header_bytes = 2;
    if (n > 125 && n <= 0xFFFFu) { header_bytes += 2; }
    else if (n > 0xFFFFu)        { header_bytes += 8; }

    std::vector<std::uint8_t> out(header_bytes + n);
    std::uint8_t* p = out.data();

    // FIN=1, RSV1-3=0, opcode
    p[0] = static_cast<std::uint8_t>(0x80u | (static_cast<std::uint8_t>(opcode) & 0x0Fu));

    // MASK=0
    if (n <= 125) {
        p[1] = static_cast<std::uint8_t>(n);
    } else if (n <= 0xFFFFu) {
        p[1] = 126u;
        write_u16_be(p + 2, static_cast<std::uint16_t>(n));
    } else {
        p[1] = 127u;
        write_u64_be(p + 2, static_cast<std::uint64_t>(n));
    }

    if (n > 0) {
        std::memcpy(p + header_bytes, payload.data(), n);
    }
    return out;
}

// ---------------------------------------------------------------------------
// decodeClientFrame — strict subset. See header for the rules we enforce.
// ---------------------------------------------------------------------------
DecodedFrame decodeClientFrame(std::span<const std::uint8_t> buffer)
{
    DecodedFrame r;

    if (buffer.size() < 2) { r.status = DecodedFrame::Status::NeedMore; return r; }

    const std::uint8_t b0 = buffer[0];
    const std::uint8_t b1 = buffer[1];

    const bool          fin       = (b0 & 0x80u) != 0;
    const std::uint8_t  rsv       = static_cast<std::uint8_t>((b0 >> 4) & 0x07u);
    const std::uint8_t  opcode_raw = static_cast<std::uint8_t>(b0 & 0x0Fu);
    const bool          mask_bit  = (b1 & 0x80u) != 0;
    const std::uint8_t  len7      = static_cast<std::uint8_t>(b1 & 0x7Fu);

    // Policy: no fragmentation, no extensions, no unknown opcodes, no
    // text frames, MUST be masked.
    if (!fin || rsv != 0 || !mask_bit)             { r.status = DecodedFrame::Status::Error; return r; }
    if (!isKnownOpcode(opcode_raw))                { r.status = DecodedFrame::Status::Error; return r; }
    if (opcode_raw == static_cast<std::uint8_t>(Opcode::Continuation)) {
        // We reject any Continuation because we've already rejected FIN=0;
        // a stray Continuation with FIN=1 has no matching non-final frame
        // ahead of it, which is a spec violation.
        r.status = DecodedFrame::Status::Error;
        return r;
    }
    if (opcode_raw == static_cast<std::uint8_t>(Opcode::Text)) {
        r.status = DecodedFrame::Status::Error;
        return r;
    }
    // Control frames MUST have a payload length ≤ 125 (RFC 6455 §5.5).
    if (isControlOpcode(opcode_raw) && len7 > 125) {
        r.status = DecodedFrame::Status::Error;
        return r;
    }

    // Resolve payload length.
    std::size_t header_bytes  = 2;
    std::uint64_t payload_len = 0;

    if (len7 <= 125) {
        payload_len = len7;
    } else if (len7 == 126) {
        if (buffer.size() < 4) { r.status = DecodedFrame::Status::NeedMore; return r; }
        payload_len = read_u16_be(buffer.data() + 2);
        // Per RFC 6455 §5.2: extended length MUST use the minimum
        // number of bytes; len7=126 with payload ≤ 125 is malformed.
        if (payload_len <= 125) { r.status = DecodedFrame::Status::Error; return r; }
        header_bytes = 4;
    } else {
        // len7 == 127
        if (buffer.size() < 10) { r.status = DecodedFrame::Status::NeedMore; return r; }
        payload_len = read_u64_be(buffer.data() + 2);
        if (payload_len <= 0xFFFFu)         { r.status = DecodedFrame::Status::Error; return r; }
        if (payload_len > kMaxPayloadBytes) { r.status = DecodedFrame::Status::Error; return r; }
        // §5.2 also forbids high bit set on 64-bit length; guarded by
        // the kMaxPayloadBytes ceiling above.
        header_bytes = 10;
    }
    if (payload_len > kMaxPayloadBytes) { r.status = DecodedFrame::Status::Error; return r; }

    // 4 bytes masking key.
    const std::size_t total_needed = header_bytes + 4 + static_cast<std::size_t>(payload_len);
    if (buffer.size() < total_needed) { r.status = DecodedFrame::Status::NeedMore; return r; }

    const std::uint8_t* mask_key = buffer.data() + header_bytes;
    const std::uint8_t* pdata    = mask_key + 4;

    r.payload.resize(static_cast<std::size_t>(payload_len));
    for (std::size_t i = 0; i < payload_len; ++i) {
        r.payload[i] = static_cast<std::uint8_t>(pdata[i] ^ mask_key[i & 3u]);
    }

    r.opcode         = static_cast<Opcode>(opcode_raw);
    r.bytes_consumed = total_needed;
    r.status         = DecodedFrame::Status::Ok;
    return r;
}

} // namespace fh::sim::net::ws
