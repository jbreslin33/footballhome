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
// alongside the input log.
//
// See DESIGN.md §16.6 (Slice 13 persistence spec), §22.12 (persistence
// architecture ADR).

#pragma once

#include <cstdint>
#include <string_view>

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
    }
    return "unknown";
}

} // namespace fh::sim::persistence
