// footballhome sim - EmptyPitchScenario implementation

#include "scenario/EmptyPitchScenario.hpp"

#include <algorithm>

namespace fh::sim::scenario {

EmptyPitchScenario::EmptyPitchScenario(std::size_t slot_count) noexcept
{
    pitch_.length_m = math::Fixed64::fromInt(105);
    pitch_.width_m  = math::Fixed64::fromInt(68);

    // M0: no playable-area constraint. Empty polygon + Advisory mode means
    // Match will not enforce anything.
    playable_.polygon.clear();
    playable_.constraint_mode = PlayableArea::Mode::Advisory;
    playable_.zoom_hint       = math::Fixed64::zero();

    // 4 columns × 3 rows grid centred on the pitch. Fits inside ±52.5 × ±34.
    // Slot IDs are 1-based (slot 0 is reserved for the ball in wire §7.2).
    constexpr int cols = 4;
    constexpr int rows = 3;
    const math::Fixed64 x_offsets[cols] = {
        math::Fixed64::fromInt(-30),
        math::Fixed64::fromInt(-10),
        math::Fixed64::fromInt( 10),
        math::Fixed64::fromInt( 30),
    };
    const math::Fixed64 y_offsets[rows] = {
        math::Fixed64::fromInt(-20),
        math::Fixed64::fromInt(  0),
        math::Fixed64::fromInt( 20),
    };

    const std::size_t max_slots = std::min<std::size_t>(slot_count, cols * rows);
    spawns_.reserve(max_slots);

    for (std::size_t i = 0; i < max_slots; ++i) {
        const std::size_t col = i % cols;
        const std::size_t row = i / cols;
        SlotSpawn s;
        s.slot     = static_cast<SlotId>(i + 1);
        s.position = math::Vec3{x_offsets[col], y_offsets[row], math::Fixed64::zero()};
        s.heading  = math::Fixed64::zero();   // facing +x
        s.role     = Role::Any;
        // ai_profile_source / ai_concepts / ai_profile all stay nullopt —
        // Match defaults unclaimed slots to WanderController. Real AI
        // pieces (M3+) will set one of these; see Scenario.hpp SlotSpawn.
        spawns_.push_back(s);
    }
}

std::vector<std::string> EmptyPitchScenario::hints() const
{
    return {
        "Empty pitch — no ball, no goals.",
        "Move around with joystick (mobile) or WASD (desktop).",
        "Hold sprint (right button / Shift) to drain stamina.",
    };
}

} // namespace fh::sim::scenario
