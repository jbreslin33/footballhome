// game/src/net/Wire.hpp
//
// Frame-type registry and protocol constants for fh-game.v2.
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
inline constexpr std::uint8_t kProtoMajor = 2;
inline constexpr std::uint8_t kProtoMinor = 3;  // 2.3 (G5.77) feet tail on SNAPSHOT; 2.0 (G5.23): the old brain's frames and fields gone; 2.1 (G5.35) TEAM_LIST + NEW_MATCH; 2.2 (G5.64) BRAIN concept + CONCEPT_LEGEND
inline constexpr std::uint8_t kProtoPatch = 0;

// Envelope: u16 payload_length | u8 frame_type | u8 flags | payload.
// payload_length counts PAYLOAD bytes only (the 4-byte header excluded).
inline constexpr std::size_t kEnvelopeBytes = 4;

enum class FrameType : std::uint8_t {
    Hello        = 0x01,
    Goodbye      = 0x02,
    PlayerIntent = 0x10,
    // 0x11 TACTICAL_INTENT reserved (PROTOCOL.md §5).
    Snapshot     = 0x20,
    Event        = 0x21,  // versioned match events; Goal is event 1
    Claim        = 0x30,
    Speed        = 0x31,  // c→s admin: set sim speed; s→c the current speed, on connect + change
    Roster         = 0x34, // s→c: per-slot names + position numbers
    Teams          = 0x38, // s→c: the two teams' names + kits, on connect
    ReloadRosters  = 0x39, // c→s admin: re-read both teams from the club DB
    Brain          = 0x3B, // s→c: each player's decision (why / target / other), ~5 Hz to watchers
    BrainWatch     = 0x3C, // c→s: switch the brain overlay feed on / off
    BrainLegend    = 0x3D, // s→c: the decision names, on connect
    TeamList       = 0x45, // s→c (2.1): every team a match can be made of, on connect
    NewMatch       = 0x46, // c→s admin (2.1): a TEAMS payload, names only — kick off that match
    ConceptLegend  = 0x47, // s→c (2.2): the trainer's labels — game_concepts id, name, title (mig 1199), on connect
    Step           = 0x48, // c→s admin (2.2): play to the next pass (received, dead or won), then pause — trainer step 3
    // Retired in 2.0 (G5.23) with the old brain — never reuse: 0x32 MATCH_SETTINGS,
    // 0x33 PLAYER_SETTINGS, 0x35 PRESETS, 0x36 APPLY_PRESET, 0x37 PLAYER_ATTRIBUTES,
    // 0x3A CONCEPTS, 0x3E PHASES, 0x3F RUN_PHASE, 0x40 MODEL_DEMANDS, 0x41 SET_DEMAND,
    // 0x42 SAVE_DEMAND, 0x43 MODEL_PARAMS, 0x44 SET_PARAM.
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
