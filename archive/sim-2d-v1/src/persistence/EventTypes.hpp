// footballhome sim - EventTypes
//
// Stable enum values for `sim_match_events.event_type`. APPEND-ONLY: once a
// value is written to Postgres it is forever bound to its meaning. Never
// reuse a retired value; never renumber. This is a wire-visible byte
// contract in the same class as registry IDs (see DESIGN.md §22.9) —
// re-ordering the enum silently corrupts every historical event row.
//
// M0 emits values 1..4 during a live match; scenario events (7, 8) plumb
// in for M1. Values 5 and 6 (slot claim / release) are wired in Slice 13
// alongside the input log. Value 9 (Goal) lands in Slice 28 and is the
// FIRST versioned-payload event — see ADR §22.25 for the payload layout
// convention (event_type >= 9 => payload[0] is a version tag; existing
// event_type in (1..8) are grandfathered unversioned).
//
// See DESIGN.md §16.6 (Slice 13 persistence spec), §22.12 (persistence
// architecture ADR), §22.25 (event_type >= 9 payload versioning ADR).

#pragma once

#include <cstddef>
#include <cstdint>
#include <string_view>
#include <vector>

namespace fh::sim::persistence {

enum class EventType : std::int16_t {
    MatchStart       = 1,   // emitted once at SimServer boot, after upsertMatch
    MatchEnd         = 2,   // emitted at SIGTERM/SIGINT, payload = 8-byte
                            //   canonical snapshot hash (big-endian FNV-1a-64)
    ClientConnect    = 3,   // WebSocket accepted, HELLO validated
    ClientDisconnect = 4,   // WebSocket closed or timed out
    SlotClaim        = 5,   // client took ownership of a scenario slot
    SlotRelease      = 6,   // slot returned to free pool
    ScenarioSuccess  = 7,   // M1+; scenario reported goal reached
    ScenarioReset    = 8,   // M1+; scenario returned to initial conditions
    Goal             = 9,   // M2 Slice 28; ball crossed a Scenario::goalRegions()
                            //   AABB. Payload is VERSIONED per ADR §22.25:
                            //     v1 (5 bytes) = [u8 version=1]
                            //                    [u8 goal_region_index]
                            //                    [u16 kicker_slot_id LE]
                            //                    [u8 reserved=0]
                            //   kicker_slot_id == 0 means "unknown kicker"
                            //   (loose ball, scenario-triggered goal, or own
                            //   goal from carry — see ADR §22.25).
};

// Compile-time helper for logs / debug output. Not a stable string API —
// consumers that need to survive across sim versions should compare the
// numeric event_type instead.
constexpr std::string_view eventTypeName(EventType e) noexcept
{
    switch (e) {
        case EventType::MatchStart:       return "match_start";
        case EventType::MatchEnd:         return "match_end";
        case EventType::ClientConnect:    return "client_connect";
        case EventType::ClientDisconnect: return "client_disconnect";
        case EventType::SlotClaim:        return "slot_claim";
        case EventType::SlotRelease:      return "slot_release";
        case EventType::ScenarioSuccess:  return "scenario_success";
        case EventType::ScenarioReset:    return "scenario_reset";
        case EventType::Goal:             return "goal";
    }
    return "unknown";
}

// ---------------------------------------------------------------------------
// Goal payload v1 layout constants (ADR §22.25). Emitters MUST use these
// symbols instead of hard-coded literals so a future v2 promotion updates one
// place. Wire-visible byte contract — do not renumber.
// ---------------------------------------------------------------------------
inline constexpr std::size_t   kGoalPayloadV1Bytes     = 5;   // [ver][region][slot_lo][slot_hi][rsv]
inline constexpr std::uint8_t  kGoalPayloadV1Version   = 1;   // payload[0] when emitting v1
inline constexpr std::uint16_t kGoalKickerSlotUnknown  = 0;   // slot ids run 1..22 in production

// Slice 28.3: encode a Goal event's payload per ADR §22.25 v1. Callers
// pass the region index (from Scenario::GoalRegion::index) and the
// kicker's slot id (or kGoalKickerSlotUnknown = 0 for goals with no
// attributable kicker — e.g. dribbled in, or the last kicker was
// cleared by an earlier goal). Returns exactly kGoalPayloadV1Bytes = 5
// bytes; the caller wraps them in an EventRow::payload and hands the
// row to IPgClient / EventLog. Deterministic and allocation-visible
// (returns a heap-backed std::vector — one alloc per goal event).
//
// Byte layout (little-endian for the u16, matching migration 221's
// `get_byte(payload, 2) | (get_byte(payload, 3) << 8)` decoder):
//   [0] = kGoalPayloadV1Version = 1
//   [1] = goal_region_index
//   [2] = kicker_slot_id & 0xFF
//   [3] = (kicker_slot_id >> 8) & 0xFF
//   [4] = 0 (reserved; migration 221 warns if nonzero)
inline std::vector<std::byte>
encodeGoalPayloadV1(std::uint8_t goal_region_index,
                    std::uint16_t kicker_slot_id) noexcept
{
    std::vector<std::byte> payload(kGoalPayloadV1Bytes);
    payload[0] = std::byte{kGoalPayloadV1Version};
    payload[1] = std::byte{goal_region_index};
    payload[2] = std::byte{static_cast<std::uint8_t>(kicker_slot_id & 0xFFu)};
    payload[3] = std::byte{static_cast<std::uint8_t>((kicker_slot_id >> 8) & 0xFFu)};
    payload[4] = std::byte{0};
    return payload;
}

} // namespace fh::sim::persistence
