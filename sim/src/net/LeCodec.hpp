// footballhome sim - Little-endian codec helpers
//
// Header-only. Shared by every wire encoder/decoder in sim/src/net/. Uses
// std::bit_cast so it is safe under -fno-strict-aliasing and clean under
// -Wconversion. Same style as sim/src/profile/PackedU16F32.cpp uses
// internally — kept here so future serializers don't duplicate it.

#pragma once

#include <bit>
#include <cstdint>

namespace fh::sim::net {

// ---- Reads --------------------------------------------------------------
constexpr std::uint16_t read_u16_le(const std::uint8_t* p) noexcept {
    return static_cast<std::uint16_t>(
        static_cast<std::uint16_t>(p[0])
        | static_cast<std::uint16_t>(
              static_cast<std::uint16_t>(p[1]) << 8));
}

constexpr std::uint32_t read_u32_le(const std::uint8_t* p) noexcept {
    return static_cast<std::uint32_t>(p[0])
         | (static_cast<std::uint32_t>(p[1]) << 8)
         | (static_cast<std::uint32_t>(p[2]) << 16)
         | (static_cast<std::uint32_t>(p[3]) << 24);
}

constexpr std::uint64_t read_u64_le(const std::uint8_t* p) noexcept {
    return static_cast<std::uint64_t>(read_u32_le(p))
         | (static_cast<std::uint64_t>(read_u32_le(p + 4)) << 32);
}

inline float read_f32_le(const std::uint8_t* p) noexcept {
    return std::bit_cast<float>(read_u32_le(p));
}

// ---- Writes -------------------------------------------------------------
constexpr void write_u8(std::uint8_t* p, std::uint8_t v) noexcept {
    p[0] = v;
}

constexpr void write_u16_le(std::uint8_t* p, std::uint16_t v) noexcept {
    p[0] = static_cast<std::uint8_t>(v & 0xFFu);
    p[1] = static_cast<std::uint8_t>((v >> 8) & 0xFFu);
}

constexpr void write_u32_le(std::uint8_t* p, std::uint32_t v) noexcept {
    p[0] = static_cast<std::uint8_t>(v & 0xFFu);
    p[1] = static_cast<std::uint8_t>((v >> 8) & 0xFFu);
    p[2] = static_cast<std::uint8_t>((v >> 16) & 0xFFu);
    p[3] = static_cast<std::uint8_t>((v >> 24) & 0xFFu);
}

constexpr void write_u64_le(std::uint8_t* p, std::uint64_t v) noexcept {
    write_u32_le(p,     static_cast<std::uint32_t>(v & 0xFFFFFFFFu));
    write_u32_le(p + 4, static_cast<std::uint32_t>(v >> 32));
}

inline void write_f32_le(std::uint8_t* p, float v) noexcept {
    write_u32_le(p, std::bit_cast<std::uint32_t>(v));
}

} // namespace fh::sim::net
