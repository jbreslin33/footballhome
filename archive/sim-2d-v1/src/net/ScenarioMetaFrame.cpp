// footballhome sim - SCENARIO_META codec implementation (Slice 17.7a)

#include "net/ScenarioMetaFrame.hpp"

#include "net/LeCodec.hpp"

namespace fh::sim::net {

std::vector<std::uint8_t>
encodeScenarioMetaFrame(std::uint8_t mode,
                        std::span<const ScenarioMetaVertex> vertices)
{
    if (vertices.size() > kMaxScenarioMetaVertices) {
        // Exceeds u16 payload cap. Caller supplies too many vertices —
        // return empty so the transport-level send is a visible no-op.
        return {};
    }

    const std::size_t payload_bytes =
        kScenarioMetaHeaderBytes + vertices.size() * kScenarioMetaVertexBytes;
    const std::size_t frame_bytes = kFrameHeaderBytes + payload_bytes;

    std::vector<std::uint8_t> out(frame_bytes);
    std::uint8_t* p = out.data();

    // Frame header.
    write_u8    (p + 0, kWireVersionV1);
    write_u8    (p + 1, static_cast<std::uint8_t>(MsgType::ScenarioMeta));
    write_u16_le(p + 2, static_cast<std::uint16_t>(payload_bytes));
    p += kFrameHeaderBytes;

    // Payload: [u8 mode][u16 num_vertices][vertex[num_vertices]]
    write_u8    (p + 0, mode);
    write_u16_le(p + 1, static_cast<std::uint16_t>(vertices.size()));
    p += kScenarioMetaHeaderBytes;

    for (const auto& v : vertices) {
        write_f32_le(p + 0, v.x);
        write_f32_le(p + 4, v.y);
        p += kScenarioMetaVertexBytes;
    }

    return out;
}

std::optional<DecodedScenarioMeta>
decodeScenarioMetaFrame(std::span<const std::uint8_t> frame)
{
    // Need at least the frame header + a mode byte + a u16 vertex count.
    if (frame.size() < kFrameHeaderBytes + kScenarioMetaHeaderBytes) {
        return std::nullopt;
    }

    const std::uint8_t* p = frame.data();
    const std::uint8_t  version    = p[0];
    const std::uint8_t  msg_type   = p[1];
    const std::uint16_t payload_sz = read_u16_le(p + 2);

    if (version  != kWireVersionV1) {
        return std::nullopt;
    }
    if (msg_type != static_cast<std::uint8_t>(MsgType::ScenarioMeta)) {
        return std::nullopt;
    }
    if (frame.size() != kFrameHeaderBytes + payload_sz) {
        return std::nullopt;
    }
    if (payload_sz < kScenarioMetaHeaderBytes) {
        return std::nullopt;
    }

    p += kFrameHeaderBytes;
    DecodedScenarioMeta out;
    out.mode = p[0];
    const std::uint16_t num_vertices = read_u16_le(p + 1);
    p += kScenarioMetaHeaderBytes;

    const std::size_t expected_payload =
        kScenarioMetaHeaderBytes
        + static_cast<std::size_t>(num_vertices) * kScenarioMetaVertexBytes;
    if (payload_sz != expected_payload) {
        return std::nullopt;
    }

    out.vertices.resize(num_vertices);
    for (std::uint16_t i = 0; i < num_vertices; ++i) {
        out.vertices[i].x = read_f32_le(p + 0);
        out.vertices[i].y = read_f32_le(p + 4);
        p += kScenarioMetaVertexBytes;
    }

    return out;
}

} // namespace fh::sim::net
