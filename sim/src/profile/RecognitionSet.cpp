// footballhome sim - RecognitionSet implementation

#include "profile/RecognitionSet.hpp"

#include "profile/PackedU16F32.hpp"

namespace fh::sim::profile {

math::Fixed64 RecognitionSet::skill(PatternId id) const
{
    const auto it = skill_.find(id);
    return (it == skill_.end()) ? math::Fixed64::zero() : it->second;
}

bool RecognitionSet::has(PatternId id) const
{
    return skill_.find(id) != skill_.end();
}

void RecognitionSet::set(PatternId id, math::Fixed64 skill)
{
    skill_[id] = skill;
}

void RecognitionSet::erase(PatternId id)
{
    skill_.erase(id);
}

std::vector<std::uint8_t> RecognitionSet::toBytes() const
{
    return detail::encodePackedU16F32(skill_);
}

RecognitionSet RecognitionSet::fromBytes(std::span<const std::uint8_t> bytes)
{
    RecognitionSet out;
    out.skill_ = detail::decodePackedU16F32(bytes);
    return out;
}

} // namespace fh::sim::profile
