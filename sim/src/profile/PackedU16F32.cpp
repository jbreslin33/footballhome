// footballhome sim - packed (u16 id, f32 value) codec implementation

#include "profile/PackedU16F32.hpp"

#include <algorithm>
#include <bit>
#include <cstdint>
#include <utility>
#include <vector>

namespace fh::sim::profile::detail {

namespace {

// Little-endian read/write helpers. All shifts operate on already-widened
// unsigned types so we avoid implicit int promotion and stay clean under
// -Wconversion.
constexpr std::uint16_t read_u16_le(const std::uint8_t* p) noexcept
{
    return static_cast<std::uint16_t>(
        static_cast<std::uint16_t>(p[0])
        | static_cast<std::uint16_t>(
              static_cast<std::uint16_t>(p[1]) << 8));
}

constexpr std::uint32_t read_u32_le(const std::uint8_t* p) noexcept
{
    return static_cast<std::uint32_t>(p[0])
         | (static_cast<std::uint32_t>(p[1]) << 8)
         | (static_cast<std::uint32_t>(p[2]) << 16)
         | (static_cast<std::uint32_t>(p[3]) << 24);
}

constexpr void write_u16_le(std::uint8_t* p, std::uint16_t v) noexcept
{
    p[0] = static_cast<std::uint8_t>(v & 0xFFu);
    p[1] = static_cast<std::uint8_t>((v >> 8) & 0xFFu);
}

constexpr void write_u32_le(std::uint8_t* p, std::uint32_t v) noexcept
{
    p[0] = static_cast<std::uint8_t>(v & 0xFFu);
    p[1] = static_cast<std::uint8_t>((v >> 8) & 0xFFu);
    p[2] = static_cast<std::uint8_t>((v >> 16) & 0xFFu);
    p[3] = static_cast<std::uint8_t>((v >> 24) & 0xFFu);
}

float bytes_to_float_le(const std::uint8_t* p) noexcept
{
    return std::bit_cast<float>(read_u32_le(p));
}

void float_to_bytes_le(std::uint8_t* p, float v) noexcept
{
    write_u32_le(p, std::bit_cast<std::uint32_t>(v));
}

} // namespace

std::vector<std::uint8_t> encodePackedU16F32(
    const std::unordered_map<std::uint16_t, math::Fixed64>& values)
{
    // u16 count caps us at 65535 records — this matches the DB SMALLSERIAL
    // registry key space, so it's the correct bound.
    if (values.size() > 0xFFFFu) {
        return {};
    }

    // Sort by id ascending so the byte output is deterministic regardless
    // of the map's iteration order.
    std::vector<std::pair<std::uint16_t, math::Fixed64>> sorted;
    sorted.reserve(values.size());
    for (const auto& [id, val] : values) {
        sorted.emplace_back(id, val);
    }
    std::sort(sorted.begin(), sorted.end(),
              [](const auto& a, const auto& b) { return a.first < b.first; });

    const std::size_t n = sorted.size();
    std::vector<std::uint8_t> out(2 + n * kRecordBytes);

    std::uint8_t* p = out.data();
    write_u16_le(p, static_cast<std::uint16_t>(n));
    p += 2;

    for (std::size_t i = 0; i < n; ++i) {
        write_u16_le(p, sorted[i].first);
        float_to_bytes_le(p + 2, sorted[i].second.toFloat());
        p += kRecordBytes;
    }
    return out;
}

std::unordered_map<std::uint16_t, math::Fixed64> decodePackedU16F32(
    std::span<const std::uint8_t> bytes)
{
    std::unordered_map<std::uint16_t, math::Fixed64> out;

    if (bytes.size() < 2) {
        return out;   // malformed → empty (documented behavior)
    }

    const std::uint16_t n = read_u16_le(bytes.data());
    const std::size_t expected = 2 + static_cast<std::size_t>(n) * kRecordBytes;
    if (bytes.size() < expected) {
        return {};
    }

    out.reserve(n);
    const std::uint8_t* p = bytes.data() + 2;
    for (std::size_t i = 0; i < n; ++i) {
        const std::uint16_t id = read_u16_le(p);
        const float f = bytes_to_float_le(p + 2);
        out.emplace(id, math::Fixed64::fromFloat(f));
        p += kRecordBytes;
    }
    return out;
}

} // namespace fh::sim::profile::detail
