// footballhome sim - ScenarioMetaFrame codec tests (Slice 17.7a)

#include "net/ScenarioMetaFrame.hpp"

#include "net/LeCodec.hpp"
#include "net/WireFormat.hpp"
#include "scenario/Scenario.hpp"
#include "test_harness.hpp"

#include <cstdint>
#include <cstring>
#include <span>
#include <vector>

using fh::sim::net::DecodedScenarioMeta;
using fh::sim::net::decodeScenarioMetaFrame;
using fh::sim::net::encodeScenarioMetaFrame;
using fh::sim::net::kFrameHeaderBytes;
using fh::sim::net::kScenarioMetaHeaderBytes;
using fh::sim::net::kScenarioMetaVertexBytes;
using fh::sim::net::kScenarioModeAdvisory;
using fh::sim::net::kScenarioModeHard;
using fh::sim::net::kScenarioModeSoft;
using fh::sim::net::kWireCapScenarioMeta;
using fh::sim::net::kWireCapSnapshotBallTrailer;
using fh::sim::net::kWireVersionV1;
using fh::sim::net::MsgType;
using fh::sim::net::read_f32_le;
using fh::sim::net::read_u16_le;
using fh::sim::net::ScenarioMetaVertex;

using fh::sim::scenario::PlayableArea;

// ---------------------------------------------------------------------------
// Wire constants pinned
// ---------------------------------------------------------------------------
FH_TEST(scenario_meta_constants_pinned) {
    FH_EXPECT_EQ(kScenarioMetaHeaderBytes, std::size_t{3});
    FH_EXPECT_EQ(kScenarioMetaVertexBytes, std::size_t{8});
    FH_EXPECT_EQ(kScenarioModeHard,     std::uint8_t{0});
    FH_EXPECT_EQ(kScenarioModeSoft,     std::uint8_t{1});
    FH_EXPECT_EQ(kScenarioModeAdvisory, std::uint8_t{2});
    FH_EXPECT_EQ(kWireCapScenarioMeta,  static_cast<std::uint16_t>(1u << 1));
    // Bit 1 must never collide with the older Slice 15.4 cap.
    FH_EXPECT((kWireCapSnapshotBallTrailer & kWireCapScenarioMeta) == 0u);
}

FH_TEST(scenario_meta_mode_matches_enum) {
    // The wire-mode constants must be a direct cast of
    // scenario::PlayableArea::Mode. The static_asserts in
    // ScenarioMetaFrame.hpp lock this at compile time; a runtime check
    // makes the contract visible in the test output too.
    FH_EXPECT_EQ(static_cast<std::uint8_t>(PlayableArea::Mode::Hard),
                 kScenarioModeHard);
    FH_EXPECT_EQ(static_cast<std::uint8_t>(PlayableArea::Mode::Soft),
                 kScenarioModeSoft);
    FH_EXPECT_EQ(static_cast<std::uint8_t>(PlayableArea::Mode::Advisory),
                 kScenarioModeAdvisory);
}

// ---------------------------------------------------------------------------
// Encoder — byte layout locked
// ---------------------------------------------------------------------------
FH_TEST(encode_empty_polygon_advisory) {
    // An Advisory + empty polygon (M0 baseline scenarios) still produces
    // a well-formed frame: header + mode + count=0.
    const auto out = encodeScenarioMetaFrame(kScenarioModeAdvisory, {});
    FH_EXPECT_EQ(out.size(), kFrameHeaderBytes + kScenarioMetaHeaderBytes);

    FH_EXPECT_EQ(out[0], kWireVersionV1);
    FH_EXPECT_EQ(out[1], static_cast<std::uint8_t>(MsgType::ScenarioMeta));
    FH_EXPECT_EQ(read_u16_le(out.data() + 2),
                 static_cast<std::uint16_t>(kScenarioMetaHeaderBytes));

    // Payload.
    FH_EXPECT_EQ(out[4], kScenarioModeAdvisory);
    FH_EXPECT_EQ(read_u16_le(out.data() + 5), std::uint16_t{0});
}

FH_TEST(encode_ccw_rectangle_hard_bytes_locked) {
    // Simulates the HalfPitchScenario east-half rectangle (CCW).
    const std::vector<ScenarioMetaVertex> poly = {
        {   0.0F, -34.0F },
        {  52.5F, -34.0F },
        {  52.5F,  34.0F },
        {   0.0F,  34.0F },
    };
    const auto out = encodeScenarioMetaFrame(
        kScenarioModeHard, std::span<const ScenarioMetaVertex>(poly));

    const std::size_t expected_payload =
        kScenarioMetaHeaderBytes + poly.size() * kScenarioMetaVertexBytes;
    FH_EXPECT_EQ(out.size(), kFrameHeaderBytes + expected_payload);

    // Header.
    FH_EXPECT_EQ(out[0], kWireVersionV1);
    FH_EXPECT_EQ(out[1], static_cast<std::uint8_t>(MsgType::ScenarioMeta));
    FH_EXPECT_EQ(read_u16_le(out.data() + 2),
                 static_cast<std::uint16_t>(expected_payload));

    // Payload.
    FH_EXPECT_EQ(out[4], kScenarioModeHard);
    FH_EXPECT_EQ(read_u16_le(out.data() + 5), std::uint16_t{4});

    // Vertices — floats decode back cleanly since all values are exact
    // in f32.
    const std::uint8_t* v = out.data() + kFrameHeaderBytes
                                       + kScenarioMetaHeaderBytes;
    FH_EXPECT(read_f32_le(v +  0) ==   0.0F);
    FH_EXPECT(read_f32_le(v +  4) == -34.0F);
    FH_EXPECT(read_f32_le(v +  8) ==  52.5F);
    FH_EXPECT(read_f32_le(v + 12) == -34.0F);
    FH_EXPECT(read_f32_le(v + 16) ==  52.5F);
    FH_EXPECT(read_f32_le(v + 20) ==  34.0F);
    FH_EXPECT(read_f32_le(v + 24) ==   0.0F);
    FH_EXPECT(read_f32_le(v + 28) ==  34.0F);
}

// ---------------------------------------------------------------------------
// Roundtrip — encode then decode preserves everything
// ---------------------------------------------------------------------------
FH_TEST(roundtrip_soft_drill_zone) {
    const std::vector<ScenarioMetaVertex> poly = {
        { -20.0F, -15.0F },
        {  20.0F, -15.0F },
        {  20.0F,  15.0F },
        { -20.0F,  15.0F },
    };
    const auto bytes = encodeScenarioMetaFrame(
        kScenarioModeSoft, std::span<const ScenarioMetaVertex>(poly));

    const auto d = decodeScenarioMetaFrame(
        std::span<const std::uint8_t>(bytes.data(), bytes.size()));
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->mode, kScenarioModeSoft);
    FH_EXPECT_EQ(d->vertices.size(), poly.size());
    for (std::size_t i = 0; i < poly.size(); ++i) {
        FH_EXPECT(d->vertices[i].x == poly[i].x);
        FH_EXPECT(d->vertices[i].y == poly[i].y);
    }
}

FH_TEST(roundtrip_empty_polygon) {
    const auto bytes = encodeScenarioMetaFrame(kScenarioModeAdvisory, {});
    const auto d = decodeScenarioMetaFrame(
        std::span<const std::uint8_t>(bytes.data(), bytes.size()));
    FH_EXPECT(d.has_value());
    FH_EXPECT_EQ(d->mode, kScenarioModeAdvisory);
    FH_EXPECT(d->vertices.empty());
}

// ---------------------------------------------------------------------------
// Malformed input — decoder returns nullopt without throwing
// ---------------------------------------------------------------------------
FH_TEST(decode_rejects_wrong_version) {
    auto bytes = encodeScenarioMetaFrame(kScenarioModeHard, {});
    bytes[0] = 0x02;   // bogus wire version
    const auto d = decodeScenarioMetaFrame(
        std::span<const std::uint8_t>(bytes.data(), bytes.size()));
    FH_EXPECT(!d.has_value());
}

FH_TEST(decode_rejects_wrong_msg_type) {
    auto bytes = encodeScenarioMetaFrame(kScenarioModeHard, {});
    bytes[1] = static_cast<std::uint8_t>(MsgType::Input);
    const auto d = decodeScenarioMetaFrame(
        std::span<const std::uint8_t>(bytes.data(), bytes.size()));
    FH_EXPECT(!d.has_value());
}

FH_TEST(decode_rejects_short_header) {
    const std::vector<std::uint8_t> bytes = {
        kWireVersionV1,
        static_cast<std::uint8_t>(MsgType::ScenarioMeta),
        0x03, 0x00,      // payload_sz = 3
        kScenarioModeAdvisory,
        // Missing 2 bytes of u16 num_vertices.
    };
    const auto d = decodeScenarioMetaFrame(
        std::span<const std::uint8_t>(bytes.data(), bytes.size()));
    FH_EXPECT(!d.has_value());
}

FH_TEST(decode_rejects_truncated_vertex_region) {
    // Claim 2 vertices in the count but ship only 1 vertex worth of
    // bytes.
    std::vector<std::uint8_t> bytes(kFrameHeaderBytes
                                    + kScenarioMetaHeaderBytes
                                    + kScenarioMetaVertexBytes);
    bytes[0] = kWireVersionV1;
    bytes[1] = static_cast<std::uint8_t>(MsgType::ScenarioMeta);
    const std::uint16_t payload_sz = static_cast<std::uint16_t>(
        kScenarioMetaHeaderBytes + kScenarioMetaVertexBytes);
    bytes[2] = static_cast<std::uint8_t>(payload_sz & 0xFFu);
    bytes[3] = static_cast<std::uint8_t>((payload_sz >> 8) & 0xFFu);
    bytes[4] = kScenarioModeHard;
    bytes[5] = 0x02;   // claim 2 vertices
    bytes[6] = 0x00;
    // Vertex-region bytes 7..14 present (one vertex worth), but count
    // says two — inconsistent → decode rejects.
    const auto d = decodeScenarioMetaFrame(
        std::span<const std::uint8_t>(bytes.data(), bytes.size()));
    FH_EXPECT(!d.has_value());
}

FH_TEST(decode_rejects_payload_length_mismatch) {
    // Header claims a much larger payload than the buffer actually
    // carries.
    auto bytes = encodeScenarioMetaFrame(kScenarioModeHard, {});
    bytes[2] = 0xFF;
    bytes[3] = 0x00;
    const auto d = decodeScenarioMetaFrame(
        std::span<const std::uint8_t>(bytes.data(), bytes.size()));
    FH_EXPECT(!d.has_value());
}

FH_TEST(encode_returns_empty_on_vertex_overflow) {
    // Way past the u16-payload cap. Encoder returns an empty vector so
    // the transport-level send is a visible no-op.
    std::vector<ScenarioMetaVertex> huge(
        fh::sim::net::kMaxScenarioMetaVertices + 1);
    const auto out = encodeScenarioMetaFrame(
        kScenarioModeHard,
        std::span<const ScenarioMetaVertex>(huge.data(), huge.size()));
    FH_EXPECT(out.empty());
}

FH_TEST_MAIN()
