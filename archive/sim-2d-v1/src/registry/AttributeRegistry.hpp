// footballhome sim - AttributeRegistry
//
// Runtime lookup for attribute keys (e.g. "physical.max_sprint_speed") ↔ AttrId.
// In production, populated at startup from `sim_attribute_registry` (§8).
// In tests, populated via addEntry().
//
// The registry is a passive lookup. It does NOT own attribute VALUES — those
// live in AttributeSet keyed by the AttrId issued here.
//
// See DESIGN.md §5.2, §8.

#pragma once

#include "common/IdTypes.hpp"

#include <optional>
#include <string>
#include <string_view>
#include <unordered_map>
#include <vector>

namespace fh::sim::registry {

class AttributeRegistry {
public:
    struct Entry {
        AttrId       id{0};
        std::string  key;         // e.g. "physical.max_sprint_speed"
        std::string  category;    // "physical" | "technical" | "mental"
    };

    AttributeRegistry() = default;

    // Insert or replace an entry. Returns false if `id` or `key` already
    // maps to a different record (caller should treat as a bug).
    bool addEntry(AttrId id, std::string key, std::string category);

    // Lookups return nullopt on miss.
    std::optional<AttrId>      lookup(std::string_view key) const;
    std::optional<std::string> keyOf(AttrId id) const;
    const Entry*               find(AttrId id) const;
    const Entry*               find(std::string_view key) const;

    std::size_t size() const noexcept { return by_id_.size(); }
    bool        empty() const noexcept { return by_id_.empty(); }
    void        clear() noexcept;

    // Snapshot of all entries, sorted ascending by id. Copies; not hot-path.
    // Used by the boot-time drift check (persistence::verifyM0RegistryConsistency).
    std::vector<Entry> entries() const;

private:
    std::unordered_map<AttrId, Entry>       by_id_;
    std::unordered_map<std::string, AttrId> by_key_;   // owned strings for lookup
};

} // namespace fh::sim::registry
