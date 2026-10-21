// footballhome sim - ConceptSet implementation

#include "profile/ConceptSet.hpp"

namespace fh::sim::profile {

math::Fixed64 ConceptSet::level(ConceptId id) const
{
    const auto it = mastery_.find(id);
    return (it == mastery_.end()) ? math::Fixed64::zero() : it->second;
}

bool ConceptSet::has(ConceptId id, math::Fixed64 min_mastery) const
{
    const auto it = mastery_.find(id);
    if (it == mastery_.end()) {
        return false;
    }
    return it->second >= min_mastery;
}

void ConceptSet::plug(ConceptId id, math::Fixed64 mastery)
{
    mastery_[id] = mastery;
}

void ConceptSet::unplug(ConceptId id)
{
    mastery_.erase(id);
}

} // namespace fh::sim::profile
