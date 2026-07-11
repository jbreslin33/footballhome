// footballhome sim - PatternRegistry
//
// Runtime lookup for tactical-pattern keys (e.g. "pattern_2v1_defender") ↔ PatternId.
// In production, populated at startup from `sim_pattern_registry` (§8).
// Empty in M0 by design — the Recognition phase runs as an identity pass-through
// until patterns are registered in M4 (§12.5).
//
// See DESIGN.md §5.2, §8, §11, §12.5.

#pragma once

#include "common/IdTypes.hpp"

#include <optional>
#include <string>
#include <string_view>
#include <unordered_map>

namespace fh::sim::registry {

class PatternRegistry {
public:
    struct Entry {
        PatternId    id{0};
        std::string  key;         // e.g. "pattern_2v1_defender"
        std::string  category;    // "defensive_read" | "offensive_read" | "trigger" | "shape"
    };

    PatternRegistry() = default;

    bool addEntry(PatternId id, std::string key, std::string category);

    std::optional<PatternId>   lookup(std::string_view key) const;
    std::optional<std::string> keyOf(PatternId id) const;
    const Entry*               find(PatternId id) const;
    const Entry*               find(std::string_view key) const;

    std::size_t size() const noexcept { return by_id_.size(); }
    bool        empty() const noexcept { return by_id_.empty(); }
    void        clear() noexcept;

private:
    std::unordered_map<PatternId, Entry>    by_id_;
    std::unordered_map<std::string, PatternId> by_key_;
};

} // namespace fh::sim::registry
