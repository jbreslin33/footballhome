// footballhome sim - ConceptSet implementation

#include "profile/ConceptSet.hpp"

#include "profile/PackedU16F32.hpp"

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

std::vector<std::uint8_t> ConceptSet::toBytes() const
{
    return detail::encodePackedU16F32(mastery_);
}

ConceptSet ConceptSet::fromBytes(std::span<const std::uint8_t> bytes)
{
    ConceptSet out;
    out.mastery_ = detail::decodePackedU16F32(bytes);
    return out;
}

} // namespace fh::sim::profile
