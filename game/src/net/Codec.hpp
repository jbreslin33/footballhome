// game/src/net/Codec.hpp
//
// Binary encode/decode for fh-game.v1 frames (PROTOCOL.md §§1–6).
// Little-endian throughout. Decoders are total functions: any malformed or
// truncated input returns std::nullopt — never UB, never a throw. Decoders
// ignore unknown trailing payload bytes (PROTOCOL.md §9: that's what makes
// minor versions safe); encoders write exactly the documented layout.

#pragma once

#include "math/Fixed64.hpp"
#include "net/Wire.hpp"

#include <cstdint>
#include <optional>
#include <string>
#include <vector>

namespace fh::game::net {

using Bytes = std::vector<std::uint8_t>;

// ── Frame structs (host-side representations) ───────────────────────────

struct HelloFrame {
    std::uint8_t  major = kProtoMajor;
    std::uint8_t  minor = kProtoMinor;
    std::uint8_t  patch = kProtoPatch;
    std::uint64_t match_id = 0;
    std::uint8_t  tick_rate = 0;
    std::uint8_t  capabilities = 0;   // Capability bits for THIS client
    std::uint8_t  slot_count = 0;
    math::Fixed64 pitch_half_x{};     // pitch half-extents, metres
    math::Fixed64 pitch_half_y{};
};

struct GoodbyeFrame {
    GoodbyeReason reason = GoodbyeReason::Normal;
};

struct PlayerIntentFrame {
    std::uint8_t  slot = 0;
    math::Fixed64 move_x{};   // desire vector; server clamps to unit length
    math::Fixed64 move_y{};
    std::uint8_t  action = 0; // 0 = none (pass/shoot/press arrive in G1+)
};

struct PlayerSnap {
    // Players are planar (DESIGN.md §4) — no z on the wire. The ball gets
    // its own record WITH z when G1 adds it.
    math::Fixed64 pos_x{}, pos_y{};
    math::Fixed64 vel_x{}, vel_y{};
    std::uint8_t  flags = 0;  // bit0 = human-controlled; rest reserved
};

struct BallSnap {
    // The ball is the one entity with z on the wire (DESIGN.md §4).
    math::Fixed64 pos_x{}, pos_y{}, pos_z{};
    std::uint8_t  owner = 0xFF;  // slot carrying the ball; 0xFF = free
};

struct SnapshotFrame {
    std::uint64_t tick = 0;
    std::vector<PlayerSnap> players;
    // Appended after the player array in protocol 1.1 — 1.0 decoders
    // ignore it as trailing bytes (§9 additive rule).
    BallSnap ball;
    // Appended in 1.2 (G3): match structure.
    std::uint8_t  score0 = 0;
    std::uint8_t  score1 = 0;
    std::uint8_t  period = 1;
    std::uint32_t clock_ticks = 0;     // resets each full time
    std::uint8_t  restart_team = 0xFF; // 0xFF = live ball
    // Appended in 1.3: current level-band ids (core::kLevelNames).
    std::uint8_t  level_home = 0;
    std::uint8_t  level_away = 0;
};

struct EventFrame {
    // Versioned match events [v1 model]: append-only payloads keyed by
    // event_type; Goal = 1 carries the scoring team.
    std::uint8_t  event_type = 0;   // 1 = goal
    std::uint8_t  team = 0;         // scoring team for Goal
    std::uint64_t tick = 0;
};

struct ClaimFrame {
    std::uint8_t slot = 0;
    std::uint8_t claim = 1;   // 1 = claim, 0 = release
};

// ── Envelope ────────────────────────────────────────────────────────────

// Wraps a payload in the 4-byte envelope. Payloads over 65535 bytes are a
// protocol-design error; encodeFrame asserts in debug and truncation-guards
// in release by returning an empty vector (callers treat empty as bug).
Bytes encodeFrame(FrameType type, const Bytes& payload);

struct DecodedFrame {
    FrameType type;
    std::uint8_t flags;
    // Payload view copied out — frames are small and lifetime headaches
    // aren't worth it at G0. Revisit only if profiling says so.
    Bytes payload;
};

// Decodes ONE frame from the front of `buf`. Returns nullopt if `buf` holds
// less than a complete frame. On success also writes the total consumed
// byte count to `consumed` so stream callers can advance.
std::optional<DecodedFrame> decodeFrame(const std::uint8_t* data,
                                        std::size_t size,
                                        std::size_t& consumed);

// ── Per-frame payload codecs (round-trip tested) ────────────────────────

Bytes encodeHello(const HelloFrame& f);
std::optional<HelloFrame> decodeHello(const Bytes& payload);

Bytes encodeGoodbye(const GoodbyeFrame& f);
std::optional<GoodbyeFrame> decodeGoodbye(const Bytes& payload);

Bytes encodePlayerIntent(const PlayerIntentFrame& f);
std::optional<PlayerIntentFrame> decodePlayerIntent(const Bytes& payload);

Bytes encodeSnapshot(const SnapshotFrame& f);
std::optional<SnapshotFrame> decodeSnapshot(const Bytes& payload);

Bytes encodeClaim(const ClaimFrame& f);
std::optional<ClaimFrame> decodeClaim(const Bytes& payload);

Bytes encodeEvent(const EventFrame& f);
std::optional<EventFrame> decodeEvent(const Bytes& payload);

struct MatchSettingsFrame {
    // Level band ids (core::kLevelNames indices).
    std::uint8_t level_home = 0;
    std::uint8_t level_away = 0;
};
Bytes encodeMatchSettings(const MatchSettingsFrame& f);
std::optional<MatchSettingsFrame> decodeMatchSettings(const Bytes& payload);

struct PlayerSettingsFrame {
    std::uint8_t slot = 0;
    // 0-100 per concept, CONCEPTS.md order (1.4: graded knowledge).
    std::vector<std::uint8_t> ratings;
};
Bytes encodePlayerSettings(const PlayerSettingsFrame& f);
std::optional<PlayerSettingsFrame> decodePlayerSettings(const Bytes& payload);

struct RosterEntry {
    std::vector<std::uint8_t> ratings;  // 0-100 per concept
    std::string name;
};
struct RosterFrame {
    std::vector<RosterEntry> slots;
};
Bytes encodeRoster(const RosterFrame& f);
std::optional<RosterFrame> decodeRoster(const Bytes& payload);

// Style-preset catalog (1.4): names only — the vectors stay server-side;
// a preset's wire id is its INDEX in this list (mig 630 sort order).
struct PresetsFrame {
    std::vector<std::string> names;
};
Bytes encodePresets(const PresetsFrame& f);
std::optional<PresetsFrame> decodePresets(const Bytes& payload);

struct ApplyPresetFrame {
    std::uint8_t team = 0;       // 0 home, 1 away
    std::uint8_t preset_id = 0;  // PRESETS index
};
Bytes encodeApplyPreset(const ApplyPresetFrame& f);
std::optional<ApplyPresetFrame> decodeApplyPreset(const Bytes& payload);

}  // namespace fh::game::net
