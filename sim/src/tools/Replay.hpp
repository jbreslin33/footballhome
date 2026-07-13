// footballhome sim - Replay driver
//
// Reconstructs a match's final state (and its canonical hash) from the
// persistent input log in Postgres. This is the library backend of the
// `fh-sim-replay` binary (§16.6 Slice 13 sub-slice 6) and one of the
// M0 exit criteria: `fh-sim-replay --match-id N` MUST produce a
// byte-identical snapshot hash to the live run that recorded the log
// (see §16.5).
//
// How it works (in one paragraph):
//   1. Look up the match row (scenario_id + seed + tick_hz) via
//      IPgClient::getMatch — the same values the live server used to
//      construct its Match determine what we build here.
//   2. Load every InputRow ordered by (tick_num ASC, slot_id ASC) — the
//      identical order the live server accepted them. Bounded by
//      `up_to_tick` when the caller wants a mid-match snapshot.
//   3. Walk ticks 0..target_tick. On each tick, decode every recorded
//      wire InputFrame at that tick, apply it via Match::applyInput,
//      then call Match::tick(). The first input for a given slot
//      auto-synthesizes a HumanController claim (see M0 profile
//      limitation below).
//   4. Return the canonical FNV-1a-64 hash of the final Snapshot.
//
// M0 profile limitation (see DESIGN.md §22.13):
//
//   The SlotClaim event does not (yet) carry the player profile that
//   the live server bound to the slot at claim time. In M0 this is
//   fine because no user has customized profiles — every synthesized
//   claim in replay uses `m0::defaultPhysical()` / `m0::defaultConcepts()`,
//   which is exactly what the live ProfileStore returns for any
//   person_id today. When M1 lands the profile-editor UI, the
//   SlotClaim event payload must carry a snapshot of the profile blob
//   or replay will diverge whenever a player uses a customized
//   profile. That change requires bumping the event_payload version
//   AND adding a fetch-profile-by-tick path.

#pragma once

#include "common/IdTypes.hpp"
#include "persistence/IPgClient.hpp"

#include <cstddef>
#include <cstdint>
#include <optional>
#include <string>

namespace fh::sim::tools {

struct ReplayOptions {
    // Stop after ticking this many times. If unset, defaults to the
    // tick_num of the match's MatchEnd event (i.e. reproduces the exact
    // final snapshot the live server hashed). If neither is available
    // (no MatchEnd row), replayMatch throws — the caller must decide
    // on an explicit target tick for an unfinished match.
    std::optional<TickNum> up_to_tick{std::nullopt};

    // When true, also fill ReplayResult::canonical_dump. This roughly
    // doubles the memory footprint of a replay (kept opt-in for
    // scripting scenarios like --emit-hex where the caller genuinely
    // needs the raw text).
    bool collect_dump{false};
};

struct ReplayResult {
    TickNum       final_tick{0};       // number of ticks actually applied
    std::uint64_t canonical_hash{0};   // FNV-1a-64 of canonical dump
    std::string   canonical_dump;      // empty unless opts.collect_dump=true
    std::size_t   inputs_applied{0};   // # of InputRow rows decoded + applied
    std::size_t   slots_synthesized{0};// # of distinct slots claimed by replay
};

// Runs the replay described in this header. Throws:
//   * persistence::PgError — any DB failure (bubbled from IPgClient).
//   * std::runtime_error — match row not found, unknown scenario_id,
//     or up_to_tick unresolvable (no explicit value AND no MatchEnd).
//
// Never mutates `db` — the replay is a pure read against the persistence
// layer, safe to run against production Postgres.
ReplayResult replayMatch(persistence::IPgClient& db,
                         MatchId                 match_id,
                         const ReplayOptions&    opts = {});

} // namespace fh::sim::tools
