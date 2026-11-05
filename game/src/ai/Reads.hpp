// game/src/ai/Reads.hpp
//
// G5.22 (DESIGN §8.120): what a player can predict — physics, not choices.
// Moved whole out of the old Brain (they were never the old decision code):
//   the race (G4.49 / G4.86): who gets to a free ball first, and where —
//     the ball's own path tick by tick (gravity, drag, bounce, skid, roll),
//     each man after his own reaction + perception, his body's reach;
//   pass safety [Buckland] (G4.19 / G4.86): the same race on the pass a
//     passer is about to strike (ground or lofted);
//   get in line (G5.5): the spot on a rolling pass his body can be on early;
//   chance quality (G4.21): the goal angle, halved per body in the way;
//   kick helpers: the loft that drops at a moving mate (G4.48), the carry
//     that drops a loft on a spot, his kick range.

#pragma once

#include "core/BallFlight.hpp"
#include "core/ModelParams.hpp"
#include "core/World.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <cstdint>
#include <vector>

namespace fh::game::ai {

math::Fixed64 distSq(const math::Vec3& a, const math::Vec3& b);
// How far he runs toward `at` in t seconds (his body's law, G4.51/G4.52).
math::Fixed64 runToward(const core::World& world, core::SlotIndex slot, const math::Vec2& at, math::Fixed64 t);
// The goal-mouth angle at the shooter (radians), halved per outfield opponent
// inside the shooter→post→post triangle [FH, after the xG literature].
math::Fixed64 chanceQuality(const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                            core::SlotIndex shooter, const math::Vec2& goal);
struct Loft { math::Vec2 at; std::uint8_t carry_m; };
// Where to drop a lofted pass for a moving mate, and that carry (capped at max_m).
Loft loftTo(const core::BallFlight& flight, const core::PlayerState& mate, const math::Vec3& from, math::Fixed64 max_m);
// The carry that drops a loft on a fixed spot.
std::uint8_t aimedCarry(const math::Vec3& from, const math::Vec2& to, math::Fixed64 max_m);
// His loft range: max_m capped by his level's kick range.
math::Fixed64 rangeFor(const core::PlayerSkill& lv, math::Fixed64 max_m);

class Reads {
public:
    struct FlightRead {
        bool live = false;                 // a free ball in play
        std::vector<std::int16_t> tick;    // ticks until slot can take it; -1 = can't (horizon)
        std::vector<math::Vec2> at;        // where
        int first[2] = {-1, -1};           // each team's first man to it
    };
    struct RaceBall {
        math::Vec3 pos, vel;
        std::int64_t since = 0;            // ticks since the flight began
        core::SlotIndex kicker = 0xFF;
        int lockout = 0;                   // the kicker's own lockout ticks left
        std::uint8_t ours = 0xFF;          // the team whose ball it is
        bool offside = true;               // honour the live offside flags
        math::Fixed64 opp_margin{};
        bool first_only = false;
    };

    Reads(const std::vector<std::uint8_t>* team_of_slot, math::Fixed64 half_x, math::Fixed64 half_y)
        : team_of_slot_(team_of_slot), half_x_(half_x), half_y_(half_y) {}
    void configure(const core::ModelParams& p);
    void bind(const std::vector<std::uint8_t>* team_of_slot) { team_of_slot_ = team_of_slot; }

    // The free ball in play, cached per tick (all 22 ask the same question).
    const FlightRead& flightRead(const core::World& world) const;
    void race(const core::World& world, const RaceBall& rb, FlightRead& f) const;
    bool getInLine(core::SlotIndex slot, const core::World& world, math::Vec2& at) const;
    bool passSafe(const core::World& world, core::SlotIndex passer, const math::Vec2& from, const math::Vec2& to,
                  math::Fixed64 speed, math::Fixed64 reach) const;
    bool loftSafe(const core::World& world, core::SlotIndex passer, const math::Vec2& from, const math::Vec2& at,
                  std::uint8_t carry_m, math::Fixed64 reach) const;
    bool raceSafe(const core::World& world, core::SlotIndex passer, const math::Vec3& pos, const math::Vec3& vel,
                  math::Fixed64 reach) const;

private:
    const std::vector<std::uint8_t>* team_of_slot_;
    math::Fixed64 half_x_, half_y_;
    // physics.receive.* (were concept.meet-the-pass.*; same numbers).
    int horizon_ticks_ = 90;
    math::Fixed64 early_s_ = math::Fixed64::fromFraction(1, 4);
    math::Fixed64 on_line_m_ = math::Fixed64::fromFraction(1, 4);
    // G5.11: the race reads the head-height point of a dropping ball.
    std::int64_t read_header_ = 0;
    math::Fixed64 aerial_radius_{}, aerial_min_z_ = math::Fixed64::one();
    mutable FlightRead flight_, pass_race_;
    mutable std::uint64_t flight_tick_ = ~0ull;
    mutable std::int64_t flight_key_[3] = {0, 0, 0};
};

}  // namespace fh::game::ai
