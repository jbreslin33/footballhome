// footballhome sim - PatternRegistry implementation

#include "registry/PatternRegistry.hpp"

#include <string>
#include <utility>

namespace fh::sim::registry {

bool PatternRegistry::addEntry(PatternId id, std::string key, std::string category)
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

std::optional<PatternId> PatternRegistry::lookup(std::string_view key) const
{
    const auto it = by_key_.find(std::string{key});
    if (it == by_key_.end()) {
        return std::nullopt;
    }
    return it->second;
}

std::optional<std::string> PatternRegistry::keyOf(PatternId id) const
{
    const auto it = by_id_.find(id);
    if (it == by_id_.end()) {
        return std::nullopt;
    }
    return it->second.key;
}

const PatternRegistry::Entry* PatternRegistry::find(PatternId id) const
{
    const auto it = by_id_.find(id);
    return (it == by_id_.end()) ? nullptr : &it->second;
}

const PatternRegistry::Entry* PatternRegistry::find(std::string_view key) const
{
    const auto key_it = by_key_.find(std::string{key});
    if (key_it == by_key_.end()) {
        return nullptr;
    }
    return find(key_it->second);
}

void PatternRegistry::clear() noexcept
{
    by_id_.clear();
    by_key_.clear();
}

} // namespace fh::sim::registry
