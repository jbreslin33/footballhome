// game/src/core/CanonicalHash.hpp
//
// Canonical world-state hash: FNV-1a 64 (Fowler–Noll–Vo, public domain)
// over every piece of authoritative state, in a fixed documented order.
// Golden-hash methodology: [v1] (archive/sim-2d-v1 locked 12+ goldens this
// way across amd64/arm64). Two worlds with equal hashes after
// equal tick counts are byte-identical — this is the primitive behind every
// determinism golden (DESIGN.md §3) and the replay CI assertion
// (PROTOCOL.md §8).
//
// Order is part of the contract: tick count, then per slot in slot order:
// pos.x/y/z raw, vel.x/y/z raw, max_speed raw. Extending the state means
// extending this function in the same slice — a golden value then changes
// ONCE, deliberately, with the slice that changed the state surface.

#pragma once

#include "core/World.hpp"

#include <cstdint>

namespace fh::game::core {

std::uint64_t canonicalHash(const World& world);

}  // namespace fh::game::core
