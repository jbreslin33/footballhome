// game/src/net/Codec.hpp
//
// Binary encode/decode for fh-game.v2 frames (PROTOCOL.md §§1–6).
// Little-endian throughout. Decoders are total functions: any malformed or
// truncated input returns std::nullopt — never UB, never a throw. Decoders
// ignore unknown trailing payload bytes (PROTOCOL.md §9: that's what makes
// minor versions safe); encoders write exactly the documented layout.

#pragma once

#include "math/Fixed64.hpp"
#include "net/Wire.hpp"

#include <climits>
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
    // 1.8 tail (G4.53): where his body faces, a unit vector ×127 — apart
    // from his velocity now (a backpedal faces against it).
    std::int8_t   face_x = 127, face_y = 0;
    // 2.3 tail (G5.77): his feet — bit0/bit1 foot 0/1 on the ground; where each stands (or, in
    // the air, will land), centimetres; how far through its stance / swing, 0..255.
    std::uint8_t  feet_down = 3;
    std::int16_t  foot_x[2] = {0, 0}, foot_y[2] = {0, 0};
    std::uint8_t  foot_prog[2] = {0, 0};
};

struct BallSnap {
    // The ball is the one entity with z on the wire (DESIGN.md §4).
    math::Fixed64 pos_x{}, pos_y{}, pos_z{};
    std::uint8_t  owner = 0xFF;  // slot carrying the ball; 0xFF = free
};

// 1.16 tail (G4.93): a match official — the referee (0) and the two
// assistants (1 = +y touchline, 2 = -y). Not a player slot.
struct OfficialSnap {
    math::Fixed64 pos_x{}, pos_y{};
    std::int8_t   face_x = 127, face_y = 0;   // unit vector ×127
    std::uint8_t  flags = 0;                  // bit0 = flag up (an assistant who just called offside)
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
    // Appended in 1.16 (after the 1.8 facing): the officials.
    std::vector<OfficialSnap> officials;
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



struct RosterEntry {
    std::string name;
};
struct RosterFrame {
    std::vector<RosterEntry> slots;
    // Each slot's position number (2 RB … 9 striker; 0 = unknown), from the
    // formation the engine plays.
    std::vector<std::uint8_t> numbers;
};
Bytes encodeRoster(const RosterFrame& f);
std::optional<RosterFrame> decodeRoster(const Bytes& payload);

// A list of names (2.0: the brain overlay's decision names, BRAIN_LEGEND).
struct NamesFrame {
    std::vector<std::string> names;
};
Bytes encodeNames(const NamesFrame& f);
std::optional<NamesFrame> decodeNames(const Bytes& payload);

// G4.76 (1.15): a team's numbers — each concept number ("concept.<code>.
// <param>") and the 3 rules by third ("ladder.<zone>.<rung>", percent) —
// milli-units, with where each comes from (0 the global row, 1 the model's
// own, 2 live, 3 inherited) and the model it came from (255 none).
struct ModelParamEntry {
    std::string key, unit;
    std::int32_t milli = 0;
    std::uint8_t source = 0, origin = 255;
};



// G4.30 (1.5): the two teams playing (game_demo_teams names) — the
// client's key into /api/game/roster for the attribute editor.
struct TeamsFrame {
    std::string home;
    std::string away;
    // G4.31 (1.5, trailing — older decoders stop after the names): kit
    // colours per team, shirt / shorts / socks / trim, 0xRRGGBB or -1.
    std::int32_t kit[2][4] = {{-1, -1, -1, -1}, {-1, -1, -1, -1}};
};
Bytes encodeTeams(const TeamsFrame& f);
std::optional<TeamsFrame> decodeTeams(const Bytes& payload);

// 2.1 (G5.35) TEAM_LIST: every team a match can be made of, on connect —
// the page's matchup dropdowns. NEW_MATCH (c→s admin) is a TEAMS payload,
// names only.
struct TeamListFrame {
    std::vector<std::string> names;
};
Bytes encodeTeamList(const TeamListFrame& f);
std::optional<TeamListFrame> decodeTeamList(const Bytes& payload);

// G4.41 (1.7): the brain overlay [Buckland's Simple Soccer debug view].
struct BrainEntry {
    std::uint8_t why = 0;        // index into the BRAIN_LEGEND names
    std::int16_t target_dm_x = 0, target_dm_y = 0;  // decimetres
    std::uint8_t other = 255;    // slot he's acting on (receiver / mark / carrier); 255 = none
    std::uint8_t concept_id = 255;   // 2.2: the game_concepts id he's playing out of possession; 255 = none
};
struct BrainFrame {
    std::vector<BrainEntry> slots;
};
// 2.2 CONCEPT_LEGEND (tactics trainer step 1): the concepts the BRAIN feed names —
// u8 count, per entry u8 id | u8 len name | u8 len title (wording from game_concepts).
struct ConceptLegendFrame {
    struct Entry { std::uint8_t id = 0; std::string name, title; };
    std::vector<Entry> entries;
};
Bytes encodeConceptLegend(const ConceptLegendFrame& f);
std::optional<ConceptLegendFrame> decodeConceptLegend(const Bytes& payload);

// 2.2 STEP (tactics trainer step 3): play on at pct % of real time until the next pass
// is received, the ball goes dead or is won, then pause. u16 pct (0 = 100).
struct StepFrame {
    std::uint16_t pct = 100;
};
Bytes encodeStep(const StepFrame& f);
std::optional<StepFrame> decodeStep(const Bytes& payload);

Bytes encodeBrain(const BrainFrame& f);
std::optional<BrainFrame> decodeBrain(const Bytes& payload);

struct BrainWatchFrame {
    std::uint8_t on = 0;
};
Bytes encodeBrainWatch(const BrainWatchFrame& f);
std::optional<BrainWatchFrame> decodeBrainWatch(const Bytes& payload);

// 1.10 SPEED (G4.61): sim speed in percent of real time — 100 = live,
// 5 = slow motion, 400 = fast forward, 0 = paused. The same ticks either
// way: only the wall-clock gap between them changes.
struct SpeedFrame {
    std::uint16_t pct = 100;
};
Bytes encodeSpeed(const SpeedFrame& f);
std::optional<SpeedFrame> decodeSpeed(const Bytes& payload);

}  // namespace fh::game::net
