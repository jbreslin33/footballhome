// footballhome sim - InputLog
//
// Thin typedef over AsyncPgLog<InputRow>. Kept as its own header so
// callers can spell `persistence::InputLog` without knowing the template
// alias and so future evolution (extra queueing metrics, alternate
// backends) has a stable name to grow into.
//
// See DESIGN.md §16.6 (Slice 13 spec — deterministic replay source),
// §22.12 (persistence architecture ADR).

#pragma once

#include "persistence/AsyncPgLog.hpp"
#include "persistence/IPgClient.hpp"

namespace fh::sim::persistence {

using InputLog = AsyncPgLog<InputRow>;

} // namespace fh::sim::persistence
