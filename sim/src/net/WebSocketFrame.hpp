// footballhome sim - RFC 6455 WebSocket frame codec (bytes only, no I/O)
//
// Implements the subset of RFC 6455 we actually use:
//   * Binary frames only (opcode 0x2). Text frames are rejected — the
//     application protocol is all binary (§7).
//   * Server → client frames are always FIN=1, unmasked.
//   * Client → server frames must be FIN=1 (no fragmentation), masked
//     (MASK bit set, 4-byte key applied per RFC 6455 §5.3).
//   * Fragmented frames, extensions (RSV1-3), and permessage-deflate
//     are rejected. Simpler = safer.
//   * Control frames (Close 0x8, Ping 0x9, Pong 0xA) are decoded but
//     never contain application payload — they're routed by the
//     transport, not delivered to onMessage.
//   * Max payload cap prevents unbounded-alloc DoS.
//
// This module is pure byte-shuffling: NO sockets, NO I/O, NO threading.
// The transport in slice 8b feeds bytes in and drains bytes out.

#pragma once

#include <cstddef>
#include <cstdint>
#include <span>
#include <vector>

namespace fh::sim::net::ws {

// -----------------------------------------------------------------------
// RFC 6455 §5.2 opcodes. Only the ones we care about.
// -----------------------------------------------------------------------
enum class Opcode : std::uint8_t {
    Continuation = 0x0,
    Text         = 0x1,
    Binary       = 0x2,
    Close        = 0x8,
    Ping         = 0x9,
    Pong         = 0xA,
};

// -----------------------------------------------------------------------
// Hard payload cap. 1 MiB is far more than any snapshot ever needs (M0
// SNAPSHOT is 374 bytes; even a 100-player future match is < 4 KiB). A
// tight bound converts a class of DoS into a clean rejection.
// -----------------------------------------------------------------------
inline constexpr std::size_t kMaxPayloadBytes = 1u << 20;   // 1 MiB

// -----------------------------------------------------------------------
// Decode outcome for a single frame at the start of a byte buffer.
// -----------------------------------------------------------------------
struct DecodedFrame {
    enum class Status : std::uint8_t {
        Ok,        // A complete valid frame is at the start of the buffer.
        NeedMore,  // Frame header/payload not yet fully in the buffer.
        Error,     // Malformed or policy-rejected frame — caller MUST close.
    };

    Status                       status = Status::NeedMore;
    Opcode                       opcode = Opcode::Binary;
    std::vector<std::uint8_t>    payload;         // unmasked, complete
    std::size_t                  bytes_consumed = 0;
};

// -----------------------------------------------------------------------
// Encode a server → client frame. FIN=1, MASK=0. `payload_size > kMaxPayloadBytes`
// returns an empty vector.
// -----------------------------------------------------------------------
std::vector<std::uint8_t> encodeServerFrame(Opcode opcode,
                                            std::span<const std::uint8_t> payload);

// Convenience for the common case: send a Binary frame carrying an app
// payload (SNAPSHOT / EVENT / HELLO_ACK etc. — already fh-sim.v1 framed).
inline std::vector<std::uint8_t> encodeServerBinary(std::span<const std::uint8_t> payload) {
    return encodeServerFrame(Opcode::Binary, payload);
}

// -----------------------------------------------------------------------
// Decode the first frame in `buffer` under RFC 6455 client-role rules:
//   * MASK bit MUST be set (per §5.1) — unmasked client frames are a
//     protocol violation.
//   * FIN bit MUST be set — we reject fragmentation.
//   * RSV1-3 MUST be zero — no extensions negotiated.
//   * Opcode MUST be one of: Binary, Close, Ping, Pong. Text is rejected.
//   * Payload length MUST fit in kMaxPayloadBytes.
//
// Returns NeedMore if the header or payload isn't yet fully buffered.
// Returns Error on any policy violation; caller must close the connection.
// On Ok, `payload` is unmasked and `bytes_consumed` tells the caller how
// many bytes to remove from the front of the buffer.
// -----------------------------------------------------------------------
DecodedFrame decodeClientFrame(std::span<const std::uint8_t> buffer);

} // namespace fh::sim::net::ws
