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
inline constexpr std::uint8_t kProtoMinor = 4;  // 1.4: graded knowledge + presets
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
    Speed        = 0x31,  // c→s admin: set sim speed; s→c the current speed, on connect + change (1.10)
    MatchSettings = 0x32,  // admin: set team skill levels live (1.3)
    PlayerSettings = 0x33, // admin: set one slot's graded knowledge (1.4)
    Roster         = 0x34, // s→c: per-slot names + concept ratings (1.4)
    Presets        = 0x35, // s→c: style-preset catalog, names only (1.4)
    ApplyPreset    = 0x36, // admin: overlay a preset onto one team (1.4)
    PlayerAttributes = 0x37, // admin: one slot's attributes, live (1.5, G4.30)
    Teams          = 0x38, // s→c: the two teams' names, on connect (1.5)
    ReloadRosters  = 0x39, // admin: re-read both teams from the club DB (1.5)
    Concepts       = 0x3A, // s→c: the curriculum's concept names by id, on connect (1.6)
    Brain          = 0x3B, // s→c: each player's decision (why / target / other), ~5 Hz to watchers (1.7)
    BrainWatch     = 0x3C, // c→s: switch the brain overlay feed on / off (1.7)
    BrainLegend    = 0x3D, // s→c: the decision names, on connect (1.7)
    Phases         = 0x3E, // s→c: the phase-of-play catalog (game_phases titles), on connect (1.9)
    RunPhase       = 0x3F, // c→s admin: set up a phase of play for one team: u8 team | u8 phase (1.9)
    ModelDemands   = 0x40, // s→c admin: one team's game-model demand per concept + its source (1.14, G4.74)
    SetDemand      = 0x41, // c→s admin: one concept's demand for one team, live: u8 team | u8 concept | u8 demand (255 = back to the model) (1.14)
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
