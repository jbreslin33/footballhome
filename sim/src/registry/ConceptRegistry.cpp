// footballhome sim - ConceptRegistry implementation

#include "registry/ConceptRegistry.hpp"

#include <algorithm>
#include <string>
#include <utility>

namespace fh::sim::registry {

bool ConceptRegistry::addEntry(ConceptId id, std::string key, std::string category)
{
    if (key.empty()) {
        return false;
    }

    const auto id_it = by_id_.find(id);
    if (id_it != by_id_.end()) {
        if (id_it->second.key != key || id_it->second.category != category) {
            return false;
        }
        return true;
    }

    const auto key_it = by_key_.find(key);
    if (key_it != by_key_.end() && key_it->second != id) {
        return false;
    }

    Entry entry{id, std::move(key), std::move(category)};
    by_key_.emplace(entry.key, id);
    by_id_.emplace(id, std::move(entry));
    return true;
}

std::optional<ConceptId> ConceptRegistry::lookup(std::string_view key) const
{
    const auto it = by_key_.find(std::string{key});
    if (it == by_key_.end()) {
        return std::nullopt;
    }
    return it->second;
}

std::optional<std::string> ConceptRegistry::keyOf(ConceptId id) const
{
    const auto it = by_id_.find(id);
    if (it == by_id_.end()) {
        return std::nullopt;
    }
    return it->second.key;
}

const ConceptRegistry::Entry* ConceptRegistry::find(ConceptId id) const
{
    const auto it = by_id_.find(id);
    return (it == by_id_.end()) ? nullptr : &it->second;
}

const ConceptRegistry::Entry* ConceptRegistry::find(std::string_view key) const
{
    const auto key_it = by_key_.find(std::string{key});
    if (key_it == by_key_.end()) {
        return nullptr;
    }
    return find(key_it->second);
}

void ConceptRegistry::clear() noexcept
{
    by_id_.clear();
    by_key_.clear();
}

std::vector<ConceptRegistry::Entry> ConceptRegistry::entries() const
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
