// footballhome sim - HalfPitchScenario implementation
//
// Slice 17.4: east-half rectangle with Hard-mode playable-area clamp.

#include "scenario/HalfPitchScenario.hpp"

namespace fh::sim::scenario {

HalfPitchScenario::HalfPitchScenario() noexcept
{
    // Standard FIFA pitch (same as EmptyPitch / BallOnPitch).
    pitch_.length_m = math::Fixed64::fromInt(105);
    pitch_.width_m  = math::Fixed64::fromInt(68);

    // Playable area: east half of the pitch. Rectangle corners in CCW
    // order (x_min, y_min) → (x_max, y_min) → (x_max, y_max) → (x_min, y_max)
    // so PlayableAreaConstraint's winding sign inference lands on
    // "positive" and the outward normals point away from the interior.
    //
    // Coordinates are chosen to be exactly representable in Q32.32:
    //   x_min = 0
    //   x_max = 52.5   (105 / 2 — 0.5 is exact in Fixed64)
    //   y_min = -34
    //   y_max = +34
    const math::Fixed64 x_min = math::Fixed64::zero();
    const math::Fixed64 x_max = math::Fixed64::fromFraction(105, 2);
    const math::Fixed64 y_min = math::Fixed64::fromInt(-34);
    const math::Fixed64 y_max = math::Fixed64::fromInt( 34);
    const math::Fixed64 z0    = math::Fixed64::zero();

    playable_.polygon = {
        math::Vec3{x_min, y_min, z0},
        math::Vec3{x_max, y_min, z0},
        math::Vec3{x_max, y_max, z0},
        math::Vec3{x_min, y_max, z0},
    };
    playable_.constraint_mode = PlayableArea::Mode::Hard;
    playable_.zoom_hint       = math::Fixed64::zero();

    // Two demo slots on the polygon's interior. Slot 1 sits near the
    // west boundary (x=0), slot 2 near the east boundary (x=52.5), so
    // a claiming client can walk toward either wall and observe the
    // Hard clamp snapping them back at x=0 or x=52.5.
    SlotSpawn s1;
    s1.slot     = SlotId{1};
    s1.position = math::Vec3{math::Fixed64::fromInt(10),
                             math::Fixed64::zero(), z0};
    s1.heading  = math::Fixed64::zero();       // facing +x (east)
    s1.role     = Role::Any;

    SlotSpawn s2;
    s2.slot     = SlotId{2};
    s2.position = math::Vec3{math::Fixed64::fromInt(40),
                             math::Fixed64::zero(), z0};
    s2.heading  = math::Fixed64::zero();
    s2.role     = Role::Any;

    spawns_.push_back(s1);
    spawns_.push_back(s2);
}

std::vector<std::string> HalfPitchScenario::hints() const
{
    return {
        "East half of the pitch (x ∈ [0, 52.5], y ∈ [-34, +34]).",
        "Hard-mode playable-area clamp: positions snap back at the wall.",
        "Slice 17.4 demo (DESIGN.md §23.3).",
    };
}

} // namespace fh::sim::scenario
