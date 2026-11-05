// game/src/ai/Possession.hpp
//
// G5.22 (DESIGN §8.120): in possession, rebuilt clean on the player state
// machines (Players.hpp). The old possession code — the pass ladder, keep-it,
// support-spot calculator, give-and-go, blind-side runs, overlaps, rest
// defence, unmarking, the call system, the look-age model, lapses — is gone.
// What a pro side does with the ball comes from real data and is grown only
// where a measured gap asks.
//
//   OnBall   the carrier. Time on the ball is the World's (the StatsBomb hold
//            curves, physics.tempo.*, G5.4 / G5.18): he asks for his best
//            action every tick and carries meanwhile; the World releases it.
//            Best action, in order: a shot (the real policy: one roll a spell
//            against the share of releases at his spot that are shots, by distance
//            × goal angle, StatsBomb), a cross (wide inside cross_depth_m of their line),
//            the best safe pass (progress, less length, the race read says
//            ours), a clearance (our end, nothing safe), else keep carrying.
//   Support  his role's real spot for this ball (below), kept onside.
//   Receive  the pass is his: get in line with it (G5.5), else the race spot.
//   Keeper   set on the ball-goal line, depth with the ball's distance;
//            dives at a shot he can't run to.
//
// The support spot is real data, as the block's: by role and the ball's
// distance from THEIR line in 10 m bands, the mean metres off their line a pro
// side in possession stands — DFL tracking (benchmarks_tracking_possession.py
// POSSESSION SHAPE; Bundesliga, not a PL figure). Across: slideY.

#pragma once

#include "ai/Players.hpp"
#include "core/ModelParams.hpp"

namespace fh::game::ai {

struct PossessionParams {
    math::Fixed64 spot[kRoleCount][kBandCount]{};   // metres off THEIR line
    // The shot policy (G5.23): of the balls let go at a spot, the share that are
    // shots — by distance (<12, 12-18, 18-25, 25-35 m) × goal angle (<0.25,
    // 0.25-0.5, 0.5+ rad). StatsBomb PL 2015/16 open play
    // (benchmarks_statsbomb_shots.py SHOT POLICY); none past 35 m.
    math::Fixed64 shot_p[4][3]{};
    math::Fixed64 cross_depth_m{}, cross_wide_m{};
    math::Fixed64 clear_from_m{};                   // our end: within this of our line
    math::Fixed64 pass_min_m{}, pass_len_cost{}, loft_min_m{};
    math::Fixed64 onside_margin_m{};
    math::Fixed64 keeper_depth_m{}, keeper_depth_k{}, keeper_depth_max_m{}, keeper_long_m{};
    void configure(const core::ModelParams& p);
};

class Possession {
public:
    void configure(const core::ModelParams& p) { params_.configure(p); }
    const PossessionParams& params() const { return params_; }
    math::Vec2 spot(const PlayerView& v, const core::World& world) const;

    static const ActingState* onBall();
    static const ActingState* support();
    static const ActingState* receive();
    static const ActingState* keeper();

private:
    PossessionParams params_{};
};

}  // namespace fh::game::ai
