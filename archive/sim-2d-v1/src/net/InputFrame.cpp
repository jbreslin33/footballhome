// footballhome sim - INPUT decoder + HELLO_ACK encoder implementation

#include "net/InputFrame.hpp"

#include "net/LeCodec.hpp"

namespace fh::sim::net {

std::optional<DecodedInput> decodeInputFrame(std::span<const std::uint8_t> frame)
{
    // Slice 26.2 (ADR §22.23) — accept either the M0 baseline (20 bytes)
    // or the with-kick variant (32 bytes). Anything else is rejected.
    // The length is the primary dispatch because the frame header only
    // carries the payload size, not a "trailer present" bit.
    const std::size_t total = frame.size();
    if (total != kInputFrameBaselineBytes
        && total != kInputFrameWithKickBytes) { return std::nullopt; }

    const std::uint8_t* p = frame.data();
    const std::uint8_t  version    = p[0];
    const std::uint8_t  msg_type   = p[1];
    const std::uint16_t payload_sz = read_u16_le(p + 2);

    if (version    != kWireVersionV1)                             { return std::nullopt; }
    if (msg_type   != static_cast<std::uint8_t>(MsgType::Input))  { return std::nullopt; }

    // Cross-check payload_sz against the outer buffer length. Rejecting a
    // 20-byte outer with payload_sz != 16 (or a 32-byte outer with
    // payload_sz != 28) catches a hostile / broken client that resized
    // one but not the other.
    const bool with_kick = (total == kInputFrameWithKickBytes);
    if (!with_kick && payload_sz != kInputPayloadBaselineBytes) { return std::nullopt; }
    if ( with_kick && payload_sz != kInputPayloadWithKickBytes) { return std::nullopt; }

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
    di.wants_kick    = (flags & kInputFlagWantsKick)    != 0;   // Slice 26.2
    // p[13..15] reserved — ignored per spec.

    // Slice 26.2 (ADR §22.23) — cross-check the wants_kick bit against
    // the presence of the trailer. Any mismatch is a malformed frame:
    //   * baseline (20 bytes) with wants_kick=1  → decoder rejects
    //     (the flag lies — no trailer was sent).
    //   * with-kick (32 bytes) with wants_kick=0 → decoder rejects
    //     (the client attached a trailer with the flag clear — either
    //     bug or spoof; either way, don't accept it silently).
    if (di.wants_kick != with_kick) { return std::nullopt; }

    if (with_kick) {
        // Trailer layout: [u16 trailer_len][kick region].
        //
        // For M2 the outer buffer is locked at kInputFrameWithKickBytes
        // (32 bytes = 4 header + 28 payload), so the trailer region is
        // always exactly kInputKickRegionBytes (10) bytes. Requiring
        // strict equality catches a hostile / broken client that sets
        // trailer_len to some large sentinel while the outer buffer
        // still says 32 bytes — even though the decoder wouldn't OOB
        // (kick region is bounded by kInputKickRegionBytes below), a
        // lying prefix is a strong "malformed frame" signal.
        //
        // A future M3+ extension that widens kInputKickRegionBytes
        // will need to bump both kInputPayloadWithKickBytes AND the
        // constant here in lockstep; forward-compat then lives in
        // adding a THIRD payload-size variant (e.g. 32 + 4 more), not
        // in relaxing this equality.
        const std::uint16_t trailer_len = read_u16_le(p + kInputPayloadBaselineBytes);
        if (trailer_len != kInputKickRegionBytes) { return std::nullopt; }

        // Kick region starts immediately after the trailer_len prefix.
        const std::uint8_t* kick_p = p + kInputPayloadBaselineBytes + kInputTrailerLenBytes;
        di.kick_dir_x      = read_f32_le(kick_p + 0);
        di.kick_dir_y      = read_f32_le(kick_p + 4);
        di.kick_power_hint = read_u16_le(kick_p + 8);

        // Reject wildly-off-unit kick directions. Legitimate clients
        // send a normalised vector (magnitude ~ 1.0); the wide band
        // [0.5, 1.5]² tolerates float drift + minor un-normalisation
        // but rejects e.g. an accidentally-un-scaled screen-space
        // delta of hundreds. Sqrt is skipped in the reject path.
        const float mag_sq = di.kick_dir_x * di.kick_dir_x
                           + di.kick_dir_y * di.kick_dir_y;
        constexpr float kMinSq = kKickDirMinMagnitude * kKickDirMinMagnitude;
        constexpr float kMaxSq = kKickDirMaxMagnitude * kKickDirMaxMagnitude;
        if (mag_sq < kMinSq || mag_sq > kMaxSq) { return std::nullopt; }
    }

    return di;
}

std::vector<std::uint8_t> encodeInputFrame(std::uint32_t client_tick,
                                           float         desired_dir_x,
                                           float         desired_dir_y,
                                           bool          wants_sprint,
                                           bool          wants_walk,
                                           bool          wants_dribble,
                                           bool          wants_release,
                                           bool          wants_kick,
                                           float         kick_dir_x,
                                           float         kick_dir_y,
                                           std::uint16_t kick_power_hint)
{
    // Slice 26.2 (ADR §22.23) — encoder branches on wants_kick. The
    // no-kick path emits exactly kInputFrameBaselineBytes (20) so it's
    // byte-identical to what M0/M1 would have produced; the with-kick
    // path emits kInputFrameWithKickBytes (32).
    const std::size_t frame_bytes = wants_kick ? kInputFrameWithKickBytes
                                               : kInputFrameBaselineBytes;
    const std::uint16_t payload_bytes = static_cast<std::uint16_t>(
        wants_kick ? kInputPayloadWithKickBytes : kInputPayloadBaselineBytes);

    std::vector<std::uint8_t> out(frame_bytes);
    std::uint8_t* p = out.data();
    write_u8    (p + 0, kWireVersionV1);
    write_u8    (p + 1, static_cast<std::uint8_t>(MsgType::Input));
    write_u16_le(p + 2, payload_bytes);
    p += kFrameHeaderBytes;

    write_u32_le(p + 0,  client_tick);
    write_f32_le(p + 4,  desired_dir_x);
    write_f32_le(p + 8,  desired_dir_y);
    std::uint8_t flags = 0;
    if (wants_sprint)  { flags |= kInputFlagWantsSprint; }
    if (wants_walk)    { flags |= kInputFlagWantsWalk; }
    if (wants_dribble) { flags |= kInputFlagWantsDribble; }   // Slice 16.2
    if (wants_release) { flags |= kInputFlagWantsRelease; }   // Slice 16.4
    if (wants_kick)    { flags |= kInputFlagWantsKick; }      // Slice 26.2
    write_u8(p + 12, flags);
    // p[13..15] reserved — zero by vector-init.

    if (wants_kick) {
        // Trailer: [u16 trailer_len][f32 kick_dir_x][f32 kick_dir_y][u16 kick_power_hint].
        write_u16_le(p + kInputPayloadBaselineBytes,
                     static_cast<std::uint16_t>(kInputKickRegionBytes));
        std::uint8_t* kick_p = p + kInputPayloadBaselineBytes + kInputTrailerLenBytes;
        write_f32_le(kick_p + 0, kick_dir_x);
        write_f32_le(kick_p + 4, kick_dir_y);
        write_u16_le(kick_p + 8, kick_power_hint);
    }

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
