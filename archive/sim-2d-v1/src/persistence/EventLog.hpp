// footballhome sim - EventLog
//
// Thin typedef over AsyncPgLog<EventRow>. Same rationale as InputLog.hpp
// (stable spelling for callers, forward-compat for evolution).
//
// M0 emits ClientConnect / ClientDisconnect / SlotClaim / SlotRelease
// via this queue during a live match. MatchStart / MatchEnd stay on
// the synchronous db->insertEvent path in main.cpp — they are one-shot
// lifecycle markers that must land before/after any queued rows.
//
// See DESIGN.md §16.6 (Slice 13 spec), §22.12 (persistence ADR).

#pragma once

#include "persistence/AsyncPgLog.hpp"
#include "persistence/IPgClient.hpp"

namespace fh::sim::persistence {

using EventLog = AsyncPgLog<EventRow>;

} // namespace fh::sim::persistence
