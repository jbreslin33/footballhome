// footballhome sim - ConceptRegistry
//
// Runtime lookup for concept keys (e.g. "run_to_point", "marking") ↔ ConceptId.
// In production, populated at startup from `sim_concept_registry` (§8).
// See DESIGN.md §5.2.

#pragma once

#include "common/IdTypes.hpp"

#include <optional>
#include <string>
#include <string_view>
#include <unordered_map>
#include <vector>

namespace fh::sim::registry {

class ConceptRegistry {
public:
    struct Entry {
        ConceptId    id{0};
        std::string  key;         // e.g. "run_to_point"
        std::string  category;
    };

    ConceptRegistry() = default;

    bool addEntry(ConceptId id, std::string key, std::string category);

    std::optional<ConceptId>   lookup(std::string_view key) const;
    std::optional<std::string> keyOf(ConceptId id) const;
    const Entry*               find(ConceptId id) const;
    const Entry*               find(std::string_view key) const;

    std::size_t size() const noexcept { return by_id_.size(); }
    bool        empty() const noexcept { return by_id_.empty(); }
    void        clear() noexcept;

    // Snapshot of all entries, sorted ascending by id. Copies; not hot-path.
    std::vector<Entry> entries() const;

private:
    std::unordered_map<ConceptId, Entry>    by_id_;
    std::unordered_map<std::string, ConceptId> by_key_;
};

} // namespace fh::sim::registry
