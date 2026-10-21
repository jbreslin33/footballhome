// footballhome sim - RecognitionSet implementation

#include "profile/RecognitionSet.hpp"

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

} // namespace fh::sim::profile
