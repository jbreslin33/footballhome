// footballhome sim - WanderController
//
// Picks a random point on the pitch and jogs toward it. When the point is
// reached (within `close_thresh_m`) OR a dwell timer elapses, picks a new
// point. Fully deterministic — driven by an injected RngDet whose seed
// comes from sim_matches.seed.
//
// Concept required: `run_to_point` (M0-defined; see M0Attributes).
//
// See DESIGN.md §5.4, §16.1, §16.3.

#pragma once

#include "controller/IPlayerController.hpp"
#include "math/Fixed64.hpp"
#include "math/RngDet.hpp"
#include "math/Vec3.hpp"

namespace fh::sim::controller {

class WanderController : public IPlayerController {
public:
    // pitch_length_m / pitch_width_m match the scenario. rng must outlive
    // this controller; it is owned by Match (one RNG per match, seeded
    // from sim_matches.seed).
    //
    // close_thresh_m: distance at which the target is considered "reached".
    // min_dwell_s / max_dwell_s: bounds on how long between target picks.
    WanderController(math::Fixed64 pitch_length_m,
                     math::Fixed64 pitch_width_m,
                     math::RngDet* rng,
                     math::Fixed64 close_thresh_m = math::Fixed64::fromInt(1),
                     math::Fixed64 min_dwell_s    = math::Fixed64::fromInt(3),
                     math::Fixed64 max_dwell_s    = math::Fixed64::fromInt(8)) noexcept;

    Intent      decide(const awareness::AwarenessView& view,
                       SlotId self) override;
    const char* kind() const override { return "wander"; }

    // Test hooks — not part of the interface, but exposed for tests.
    math::Vec3     target() const noexcept { return target_; }
    math::Fixed64  nextPickAt() const noexcept { return choose_new_target_at_; }

private:
    void pickNewTarget(math::Fixed64 now_seconds);

    math::Fixed64 pitch_length_;
    math::Fixed64 pitch_width_;
    math::RngDet* rng_;
    math::Fixed64 close_thresh_;
    math::Fixed64 min_dwell_;
    math::Fixed64 dwell_range_;

    math::Vec3    target_{};
    math::Fixed64 choose_new_target_at_{math::Fixed64::zero()};
    bool          initialised_{false};
};

} // namespace fh::sim::controller
