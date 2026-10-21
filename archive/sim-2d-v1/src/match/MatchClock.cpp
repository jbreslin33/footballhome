// footballhome sim - MatchClock implementation

#include "match/MatchClock.hpp"

namespace fh::sim::match {

RealtimeClock::RealtimeClock(std::uint32_t hz) noexcept
    : hz_(hz == 0 ? 1u : hz)
    , dt_(math::Fixed64::fromFraction(1, static_cast<std::int32_t>(hz_ == 0 ? 1u : hz_)))
{
}

math::Fixed64 RealtimeClock::elapsedSeconds() const noexcept
{
    // tick_ * dt_. Fixed64 handles the multiplication.
    return math::Fixed64::fromInt(static_cast<std::int64_t>(tick_)) * dt_;
}

} // namespace fh::sim::match
