// footballhome sim - AttributeRegistry implementation
// See DESIGN.md §5.2, §8.

#include "registry/AttributeRegistry.hpp"

#include <algorithm>
#include <string>
#include <utility>

namespace fh::sim::registry {

bool AttributeRegistry::addEntry(AttrId id, std::string key, std::string category)
{
    // Reject empty keys — DB has NOT NULL + UNIQUE on the key column.
    if (key.empty()) {
        return false;
    }

    const auto id_it = by_id_.find(id);
    if (id_it != by_id_.end()) {
        // Existing record for this id — must match exactly to be an idempotent re-insert.
        if (id_it->second.key != key || id_it->second.category != category) {
            return false;
        }
        return true;
    }

    const auto key_it = by_key_.find(key);
    if (key_it != by_key_.end() && key_it->second != id) {
        // Key already maps to a different id — bug.
        return false;
    }

    Entry entry{id, std::move(key), std::move(category)};
    // Insert by_key_ using a copy of the (now-moved) entry.key; we still own it in by_id_ below.
    by_key_.emplace(entry.key, id);
    by_id_.emplace(id, std::move(entry));
    return true;
}

std::optional<AttrId> AttributeRegistry::lookup(std::string_view key) const
{
    // unordered_map lookup with string_view via a transparent hasher would be nicer,
    // but stdlib unordered_map does not support heterogeneous lookup pre-C++20.
    // Copy is fine — registry lookups are load-time / rare.
    const auto it = by_key_.find(std::string{key});
    if (it == by_key_.end()) {
        return std::nullopt;
    }
    return it->second;
}

std::optional<std::string> AttributeRegistry::keyOf(AttrId id) const
{
    const auto it = by_id_.find(id);
    if (it == by_id_.end()) {
        return std::nullopt;
    }
    return it->second.key;
}

const AttributeRegistry::Entry* AttributeRegistry::find(AttrId id) const
{
    const auto it = by_id_.find(id);
    return (it == by_id_.end()) ? nullptr : &it->second;
}

const AttributeRegistry::Entry* AttributeRegistry::find(std::string_view key) const
{
    const auto key_it = by_key_.find(std::string{key});
    if (key_it == by_key_.end()) {
        return nullptr;
    }
    return find(key_it->second);
}

void AttributeRegistry::clear() noexcept
{
    by_id_.clear();
    by_key_.clear();
}

std::vector<AttributeRegistry::Entry> AttributeRegistry::entries() const
{
    std::vector<Entry> out;
    out.reserve(by_id_.size());
    for (const auto& [id, entry] : by_id_) {
        out.push_back(entry);
    }
    std::sort(out.begin(), out.end(),
              [](const Entry& a, const Entry& b) { return a.id < b.id; });
    return out;
}

} // namespace fh::sim::registry
