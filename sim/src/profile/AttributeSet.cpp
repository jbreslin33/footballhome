// footballhome sim - AttributeSet implementation

#include "profile/AttributeSet.hpp"

#include "profile/PackedU16F32.hpp"

namespace fh::sim::profile {

math::Fixed64 AttributeSet::get(AttrId id, math::Fixed64 default_value) const
{
    const auto it = values_.find(id);
    return (it == values_.end()) ? default_value : it->second;
}

bool AttributeSet::has(AttrId id) const
{
    return values_.find(id) != values_.end();
}

void AttributeSet::set(AttrId id, math::Fixed64 value)
{
    values_[id] = value;
}

void AttributeSet::erase(AttrId id)
{
    values_.erase(id);
}

std::vector<std::uint8_t> AttributeSet::toBytes() const
{
    return detail::encodePackedU16F32(values_);
}

AttributeSet AttributeSet::fromBytes(std::span<const std::uint8_t> bytes)
{
    AttributeSet out;
    out.values_ = detail::decodePackedU16F32(bytes);
    return out;
}

} // namespace fh::sim::profile
