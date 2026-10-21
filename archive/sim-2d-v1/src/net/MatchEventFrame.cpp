// footballhome sim - MATCH_EVENT codec implementation (Slice 28.4)

#include "net/MatchEventFrame.hpp"

#include "net/LeCodec.hpp"

#include <cstring>

namespace fh::sim::net {

std::vector<std::uint8_t>
encodeMatchEventFrame(std::uint32_t tick_num,
                      std::uint8_t  event_type,
                      std::span<const std::uint8_t> event_payload)
{
    // event_payload_len is a u16 AND the outer payload length is a u16,
    // so both caps apply. The outer cap is stricter here because the
    // event_payload rides inside the outer payload alongside a 7-byte
    // header — check that combined bound explicitly.
    if (event_payload.size() > kMaxPayloadBytes - kMatchEventHeaderBytes) {
        return {};
    }

    const std::size_t payload_bytes = kMatchEventHeaderBytes + event_payload.size();
    const std::size_t frame_bytes   = kFrameHeaderBytes + payload_bytes;

    std::vector<std::uint8_t> out(frame_bytes);
    std::uint8_t* p = out.data();

    // Frame header.
    write_u8    (p + 0, kWireVersionV1);
    write_u8    (p + 1, static_cast<std::uint8_t>(MsgType::MatchEvent));
    write_u16_le(p + 2, static_cast<std::uint16_t>(payload_bytes));
    p += kFrameHeaderBytes;

    // MATCH_EVENT header: [u32 tick_num][u8 event_type][u16 event_payload_len]
    write_u32_le(p + 0, tick_num);
    write_u8    (p + 4, event_type);
    write_u16_le(p + 5, static_cast<std::uint16_t>(event_payload.size()));
    p += kMatchEventHeaderBytes;

    if (!event_payload.empty()) {
        std::memcpy(p, event_payload.data(), event_payload.size());
    }

    return out;
}

std::optional<DecodedMatchEvent>
decodeMatchEventFrame(std::span<const std::uint8_t> frame)
{
    // Need at least frame header + MATCH_EVENT header.
    if (frame.size() < kFrameHeaderBytes + kMatchEventHeaderBytes) {
        return std::nullopt;
    }

    const std::uint8_t* p = frame.data();
    const std::uint8_t  version    = p[0];
    const std::uint8_t  msg_type   = p[1];
    const std::uint16_t payload_sz = read_u16_le(p + 2);

    if (version  != kWireVersionV1) {
        return std::nullopt;
    }
    if (msg_type != static_cast<std::uint8_t>(MsgType::MatchEvent)) {
        return std::nullopt;
    }
    if (frame.size() != kFrameHeaderBytes + payload_sz) {
        return std::nullopt;
    }
    if (payload_sz < kMatchEventHeaderBytes) {
        return std::nullopt;
    }

    p += kFrameHeaderBytes;

    DecodedMatchEvent out;
    out.tick_num                        = read_u32_le(p + 0);
    out.event_type                      = p[4];
    const std::uint16_t event_payload_sz = read_u16_le(p + 5);
    p += kMatchEventHeaderBytes;

    const std::size_t expected_payload =
        kMatchEventHeaderBytes + static_cast<std::size_t>(event_payload_sz);
    if (payload_sz != expected_payload) {
        return std::nullopt;
    }

    out.event_payload.assign(p, p + event_payload_sz);
    return out;
}

} // namespace fh::sim::net
