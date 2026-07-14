// footballhome sim - INPUT decoder + HELLO_ACK encoder implementation

#include "net/InputFrame.hpp"

#include "net/LeCodec.hpp"

namespace fh::sim::net {

std::optional<DecodedInput> decodeInputFrame(std::span<const std::uint8_t> frame)
{
    if (frame.size() != kInputFrameBytes) { return std::nullopt; }

    const std::uint8_t* p = frame.data();
    const std::uint8_t  version    = p[0];
    const std::uint8_t  msg_type   = p[1];
    const std::uint16_t payload_sz = read_u16_le(p + 2);

    if (version    != kWireVersionV1)                             { return std::nullopt; }
    if (msg_type   != static_cast<std::uint8_t>(MsgType::Input))  { return std::nullopt; }
    if (payload_sz != kInputPayloadBytes)                         { return std::nullopt; }

    p += kFrameHeaderBytes;

    DecodedInput di;
    di.client_tick   = read_u32_le(p + 0);
    di.desired_dir_x = read_f32_le(p + 4);
    di.desired_dir_y = read_f32_le(p + 8);
    const std::uint8_t flags = p[12];
    di.wants_sprint  = (flags & kInputFlagWantsSprint)  != 0;
    di.wants_walk    = (flags & kInputFlagWantsWalk)    != 0;
    di.wants_dribble = (flags & kInputFlagWantsDribble) != 0;   // Slice 16.2
    di.wants_release = (flags & kInputFlagWantsRelease) != 0;   // Slice 16.4
    // p[13..15] reserved — ignored per spec.
    return di;
}

std::vector<std::uint8_t> encodeInputFrame(std::uint32_t client_tick,
                                           float         desired_dir_x,
                                           float         desired_dir_y,
                                           bool          wants_sprint,
                                           bool          wants_walk,
                                           bool          wants_dribble,
                                           bool          wants_release)
{
    std::vector<std::uint8_t> out(kInputFrameBytes);
    std::uint8_t* p = out.data();
    write_u8    (p + 0, kWireVersionV1);
    write_u8    (p + 1, static_cast<std::uint8_t>(MsgType::Input));
    write_u16_le(p + 2, static_cast<std::uint16_t>(kInputPayloadBytes));
    p += kFrameHeaderBytes;
    write_u32_le(p + 0,  client_tick);
    write_f32_le(p + 4,  desired_dir_x);
    write_f32_le(p + 8,  desired_dir_y);
    std::uint8_t flags = 0;
    if (wants_sprint)  { flags |= kInputFlagWantsSprint; }
    if (wants_walk)    { flags |= kInputFlagWantsWalk; }
    if (wants_dribble) { flags |= kInputFlagWantsDribble; }   // Slice 16.2
    if (wants_release) { flags |= kInputFlagWantsRelease; }   // Slice 16.4
    write_u8(p + 12, flags);
    // p[13..15] reserved — zero by vector-init.
    return out;
}

std::vector<std::uint8_t> encodeHelloAckFrame(std::uint64_t match_id,
                                              std::uint16_t your_slot,
                                              std::uint32_t tick_hz,
                                              std::uint16_t wire_capability_bits)
{
    std::vector<std::uint8_t> out(kHelloAckFrameBytes);
    std::uint8_t* p = out.data();
    write_u8    (p + 0, kWireVersionV1);
    write_u8    (p + 1, static_cast<std::uint8_t>(MsgType::HelloAck));
    write_u16_le(p + 2, static_cast<std::uint16_t>(kHelloAckPayloadBytes));
    p += kFrameHeaderBytes;
    write_u64_le(p + 0,  match_id);
    write_u16_le(p + 8,  your_slot);
    write_u32_le(p + 10, tick_hz);
    write_u16_le(p + 14, wire_capability_bits);   // Slice 15.4 (§7.1 addendum)
    return out;
}

} // namespace fh::sim::net
