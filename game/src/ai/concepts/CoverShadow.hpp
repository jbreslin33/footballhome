// game/src/ai/concepts/CoverShadow.hpp
//
// COVER SHADOW — who can the ball not be passed to, because I am standing in the way?
// (game_concepts cover-shadow: "Press on the cover shadow".)
//
// Owner 2026-11-24: cover shadow is the concept after pressing distance. The catalogue's cue:
// "Pressing their centre back: run at him along the line to his nearest receiver, so that
// pass is blocked by your body." One defender takes two opponents out — the one he presses
// and the one he hides.
//
// Built the way the taxonomy says a concept is built (docs/taxonomy-one-system.md):
//
//   recognise   every defender has a SHADOW: the strip of pitch behind him as seen from the
//               ball, as wide as what his body and a stride either side stop (body_m). An
//               opponent standing in that strip, further from the ball than he is, cannot be
//               found along the ground. Read for every outfielder of the side without the
//               ball, every tick: which of theirs he is hiding.
//               And for whoever closes the ball down: WHICH pass to block — the man on the
//               ball's nearest team-mate who is level with him or nearer our goal (a pass
//               back toward their own goal is not worth hiding).
//   choose      a dial, physics.shadow.press (0 … 1). No row = 0: the presser stands goal-side
//               as fitted, and the sim is unchanged.
//   execute     the presser's stand-off spot moves off the line to our goal onto the line to
//               that receiver, by the dial's share — he arrives along the pass he is blocking.
//
// Fixed point, no noise, no memory. body_m and the ranges are [FH] coaching values.

#pragma once

#include "core/World.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <array>
#include <cstdint>
#include <vector>

namespace fh::game::ai::concepts {

struct CoverShadowParams {
    using F = math::Fixed64;
    F body_m = F::fromFraction(6, 5);      // half the width he blocks: his body and a stride either side
    F behind_m = F::fromInt(1);            // the hidden man is at least this much further from the ball than he is
    F near_m = F::fromFraction(1, 2);      // … and he himself is at least this far from the ball
    F receiver_m = F::fromInt(30);         // a receiver worth blocking is within this of the man on the ball
    F back_m = F::fromInt(2);              // … and not more than this nearer their own goal than he is
};

class CoverShadows {
public:
    // One tick for `team`, the side without the ball. `sg` is +1 when `team` attacks toward +x
    // (its own goal at x = -sg × half-length).
    void read(std::uint8_t team, const core::World& w, const std::vector<std::uint8_t>& team_of_slot, math::Fixed64 sg);
    void clear(std::uint8_t team, const std::vector<std::uint8_t>& team_of_slot);
    void reset() { hidden_.fill(0); screen_[0] = screen_[1] = -1; }

    // Bit t set: opponent slot t is in his shadow.
    std::uint32_t hiddenBy(core::SlotIndex slot) const { return hidden_[slot & 31]; }
    // The receiver whoever closes the ball down for `team` should hide (a slot), or -1.
    int screen(std::uint8_t team) const { return screen_[team & 1]; }
    // Is `their` hidden from the ball by a man standing at `at`?
    bool hides(math::Vec2 ball, math::Vec2 at, math::Vec2 their) const;

    const CoverShadowParams& params() const { return p_; }

private:
    CoverShadowParams p_{};
    std::array<std::uint32_t, 32> hidden_{};
    int screen_[2] = {-1, -1};
};

}  // namespace fh::game::ai::concepts
