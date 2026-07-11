// footballhome sim - packed (u16 id, f32 value) codec
//
// Internal helper shared by AttributeSet, ConceptSet, RecognitionSet.
// All three types persist as:
//
//   [u16 count LE][ (u16 id LE)(f32 value LE) ] × count
//
// which matches the SQL decode helper in DESIGN.md §8.1 and the record
// stride (2 + count*6 bytes) it assumes.
//
// The DB stores f32 for readability + registry stability (see §5.2); the
// sim loop works in Fixed64. This codec converts at the persistence boundary
// only. Round-trip precision is therefore limited by f32 (~23-bit mantissa).

#pragma once

#include "common/IdTypes.hpp"
#include "math/Fixed64.hpp"

#include <cstddef>
#include <cstdint>
#include <span>
#include <unordered_map>
#include <vector>

namespace fh::sim::profile::detail {

// Record size in the packed byte layout. The SQL decoder in §8.1 also
// assumes 6 bytes: `2 + i*6`.
inline constexpr std::size_t kRecordBytes = 6;

// Encode a { u16 → Fixed64 } map into the packed byte format. Records are
// emitted sorted by id ascending so the byte layout is deterministic
// regardless of the map's iteration order.
std::vector<std::uint8_t> encodePackedU16F32(
    const std::unordered_map<std::uint16_t, math::Fixed64>& values);

// Decode packed bytes. On malformed input (short buffer, count/length
// mismatch), returns an empty map. Caller decides whether to log or fail
// at the persistence boundary.
std::unordered_map<std::uint16_t, math::Fixed64> decodePackedU16F32(
    std::span<const std::uint8_t> bytes);

} // namespace fh::sim::profile::detail
