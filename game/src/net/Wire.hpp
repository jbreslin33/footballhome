// game/src/net/Wire.hpp
//
// Frame-type registry and protocol constants for fh-game.v1.
// game/PROTOCOL.md is the contract; this header mirrors it. A frame id is
// never reused (PROTOCOL.md §9).
//
// Lineage: envelope + little-endian + length-prefix conventions from [v1]'s
// fh-sim.v1 wire; capability-gated clients and the two intent classes are
// [FH] (DESIGN.md §6 — they're what make manager mode and headless
// calibration ordinary clients).

#pragma once

#include <cstdint>

namespace fh::game::net {

// Protocol version — major bumps reject at HELLO, minor is additive.
inline constexpr std::uint8_t kProtoMajor = 1;
inline constexpr std::uint8_t kProtoMinor = 3;  // 1.3: live match settings
inline constexpr std::uint8_t kProtoPatch = 0;

// Envelope: u16 payload_length | u8 frame_type | u8 flags | payload.
// payload_length counts PAYLOAD bytes only (the 4-byte header excluded).
inline constexpr std::size_t kEnvelopeBytes = 4;

enum class FrameType : std::uint8_t {
    Hello        = 0x01,
    Goodbye      = 0x02,
    PlayerIntent = 0x10,
    // 0x11 TACTICAL_INTENT reserved — ships with G5 (PROTOCOL.md §5).
    Snapshot     = 0x20,
    Event        = 0x21,  // versioned match events; Goal is event 1 (G1)
    Claim        = 0x30,
    // 0x31 SPEED reserved — ships with manager/admin clients.
    MatchSettings = 0x32,  // admin: set team skill levels live (1.3)
    PlayerSettings = 0x33, // admin: set one slot's concept mask (1.3)
    Roster         = 0x34, // s→c: per-slot names + concept masks (1.3)
};

// Capability bits granted in HELLO (PROTOCOL.md §3).
enum Capability : std::uint8_t {
    kCapPlayer    = 1 << 0,
    kCapManager   = 1 << 1,
    kCapSpectator = 1 << 2,
    kCapAdmin     = 1 << 3,
};

enum class GoodbyeReason : std::uint8_t {
    Normal          = 0,
    VersionMismatch = 1,
    AuthFailed      = 2,
    MatchOver       = 3,
    ServerShutdown  = 4,
};

}  // namespace fh::game::net
