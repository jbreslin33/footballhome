// footballhome sim - common ID typedefs
//
// Small integer aliases used across the codebase. Kept in one header so that
// the wire format (§7) and the DB schema (§8) can be validated against these
// widths at compile time.
//
// See DESIGN.md §5.2 (AttrId/ConceptId/PatternId), §5.3 (EntityId),
// §5.4 (SlotId), §7 (wire).

#pragma once

#include <cstdint>

namespace fh::sim {

// Registry-issued IDs. u16 because the DB uses SMALLSERIAL (int2).
using AttrId    = std::uint16_t;
using ConceptId = std::uint16_t;
using PatternId = std::uint16_t;

// Runtime IDs.
using EntityId  = std::uint16_t;    // physics entity within a match
using SlotId    = std::uint16_t;    // scenario slot; matches wire u16 slot_id
using TickNum   = std::uint32_t;    // 20 Hz × 90 min ≈ 108000, fits u32 easily
using ClientId  = std::uint64_t;    // fh person_id maps here (BIGINT in DB)
using MatchId   = std::uint64_t;    // sim_matches.id (BIGSERIAL)

// PersonId is the same width as ClientId. Two aliases exist because the
// semantic distinction matters at the persistence boundary: ClientId
// identifies a connected websocket peer during a match; PersonId identifies
// a row in `persons` that owns a `sim_player_profile`. In M0 they always
// coincide, but the interface types keep the distinction so a future
// spectator/guest-token flow can add a ClientId that maps to no PersonId
// without changing every persistence call site.
using PersonId  = std::uint64_t;

} // namespace fh::sim
