// footballhome sim - SoftDrillScenario implementation
//
// Slice 17.5: 40×30 m drill zone centred at the pitch origin, Soft
// pushback boundary. See header for context.

#include "scenario/SoftDrillScenario.hpp"

namespace fh::sim::scenario {

SoftDrillScenario::SoftDrillScenario() noexcept
{
    // Standard FIFA pitch (same as EmptyPitch / BallOnPitch / HalfPitch).
    pitch_.length_m = math::Fixed64::fromInt(105);
    pitch_.width_m  = math::Fixed64::fromInt(68);

    // Drill-zone rectangle. Centre = origin; corners in CCW order so
    // PlayableAreaConstraint's winding sign inference lands positive
    // and outward normals point away from the interior.
    //
    // Coordinates are integer-valued and therefore exactly
    // representable in Q32.32.
    const math::Fixed64 x_min = math::Fixed64::fromInt(-20);
    const math::Fixed64 x_max = math::Fixed64::fromInt( 20);
    const math::Fixed64 y_min = math::Fixed64::fromInt(-15);
    const math::Fixed64 y_max = math::Fixed64::fromInt( 15);
    const math::Fixed64 z0    = math::Fixed64::zero();

    playable_.polygon = {
        math::Vec3{x_min, y_min, z0},
        math::Vec3{x_max, y_min, z0},
        math::Vec3{x_max, y_max, z0},
        math::Vec3{x_min, y_max, z0},
    };
    playable_.constraint_mode = PlayableArea::Mode::Soft;
    playable_.zoom_hint       = math::Fixed64::zero();

    // Single demo slot at the centre of the drill zone. A claiming
    // client can walk out through any wall to feel the Soft pushback;
    // unclaimed slots default to WanderController which also passively
    // exercises the boundary.
    SlotSpawn s1;
    s1.slot     = SlotId{1};
    s1.position = math::Vec3{math::Fixed64::zero(),
                             math::Fixed64::zero(), z0};
    s1.heading  = math::Fixed64::zero();       // facing +x (east)
    s1.role     = Role::Any;

    spawns_.push_back(s1);
}

std::vector<std::string> SoftDrillScenario::hints() const
{
    return {
        "40×30 m drill zone centred on the pitch origin.",
        "Soft-mode boundary: leave the zone and you're bounced back.",
        "Slice 17.5 demo (DESIGN.md §23.3).",
    };
}

} // namespace fh::sim::scenario
