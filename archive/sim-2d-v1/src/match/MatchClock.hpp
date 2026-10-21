// footballhome sim - MatchClock
//
// Interface + M0 fixed-rate implementation. Determines dt for each tick
// and monotonically advances the tick number. Kept behind an interface so
// tests can plug in a TurnBasedClock without touching Match.
//
// See DESIGN.md §5.7, §14, §9 (tick 20 Hz).

#pragma once

#include "common/IdTypes.hpp"
#include "math/Fixed64.hpp"

#include <cstdint>

namespace fh::sim::match {

class MatchClock {
public:
    virtual ~MatchClock() = default;

    // Called at the top of the main loop. True ⇒ Match should run tick().
    // In M0 this always returns true — Match calls tick() at whatever cadence
    // the caller drives it; wall-clock pacing is a caller concern.
    virtual bool          shouldTick() = 0;

    // Time delta for the next tick, in seconds (Fixed64).
    virtual math::Fixed64 dt() const noexcept = 0;

    // Current tick number (0-based, monotone). Advanced by advance().
    virtual TickNum       current() const noexcept = 0;

    // Advance to the next tick. Called by Match at the end of tick().
    virtual void          advance() noexcept = 0;

    // Wall-clock elapsed since tick 0 in seconds. Equals current() * dt().
    virtual math::Fixed64 elapsedSeconds() const noexcept = 0;
};

// -----------------------------------------------------------------------
// RealtimeClock — fixed 20 Hz cadence (dt = 1/20 s in Fixed64).
// Called by the run loop once per intended tick; does not wait or sleep.
// -----------------------------------------------------------------------
class RealtimeClock final : public MatchClock {
public:
    // hz must be > 0. Locked at match start per §14.
    explicit RealtimeClock(std::uint32_t hz = 20) noexcept;

    bool          shouldTick() override            { return true; }
    math::Fixed64 dt()      const noexcept override { return dt_; }
    TickNum       current() const noexcept override { return tick_; }
    void          advance()       noexcept override { ++tick_; }
    math::Fixed64 elapsedSeconds() const noexcept override;

    std::uint32_t hz() const noexcept { return hz_; }

private:
    std::uint32_t hz_;
    math::Fixed64 dt_;
    TickNum       tick_{0};
};

} // namespace fh::sim::match
