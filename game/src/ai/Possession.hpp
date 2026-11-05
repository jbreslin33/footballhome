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
//            × goal angle, StatsBomb); a pass by the real pass policy (each mate
//            weighted by the share of real passes from this zone to his zone,
//            shared among the mates there; only ones the race read says we win;
//            one roll a spell; lofted / crossed at the real shares) — each
//            pass for a man short of their line split into to-feet and IN
//            BEHIND by the real share for his gap (DFL, G5.27): the ball into
//            the space a real roll past the line, on the ground weighted to
//            arrive as his run does, else in the air; a clearance (our end,
//            nothing safe); else keep carrying.
//   Receive  ... a ball in behind for him: he runs on to its spot while it is
//            behind him and will get there, and keeps his run while it is loose.
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
    // The pass policy (G5.25): from each origin zone (their line 0-18 / 18-35 /
    // 35-52 / 52-70 / 70+ m × centre |y| < 20.16 or wide), the share of real
    // passes ending in each zone, and the share lofted / crossed — StatsBomb PL
    // 2015/16 open play (benchmarks_statsbomb_passes.py PASS POLICY).
    math::Fixed64 pass_to[10][10]{}, pass_loft[10]{}, pass_cross[10]{};
    math::Fixed64 risk_weight{};   // an unsafe pass's weight, × its zone share
    math::Fixed64 clear_from_m{};                   // our end: within this of our line
    math::Fixed64 pass_min_m{};
    math::Fixed64 onside_margin_m{};
    math::Fixed64 keeper_depth_m{}, keeper_depth_k{}, keeper_depth_max_m{}, keeper_long_m{};
    // Runs into the box (G5.26), by the ball's zone (their line 0-18 / 18-35 /
    // 35-52 × centre or wide): the share of time with 0 / 1 / 2 / 3+ of ours in
    // the box zone (0-18 m, |y| < 20.16), the mean count by role, where they stand
    // (metres off the line, |y|) — DFL tracking (benchmarks_tracking_box.py).
    math::Fixed64 box_k[6][4]{}, box_role[6][kRoleCount]{}, box_depth[6]{}, box_ay[6]{};
    // Balls in behind (G5.27): by the man's gap short of their line (2 m bins,
    // 0-18 m), the real share of passes for him that are played in behind him (met
    // past the line as it stood at the kick); where it is met past the line (p25-p75
    // roll); the share in the air — DFL tracking (benchmarks_tracking_behind.py).
    math::Fixed64 behind_gap[9]{}, behind_past_lo{}, behind_past_hi{}, behind_air{}, behind_lead_s{};
    void configure(const core::ModelParams& p);
};

class Possession {
public:
    Possession() { params_.configure(core::ModelParams{}); }   // the real tables, no DB needed
    void configure(const core::ModelParams& p) { params_.configure(p); }
    const PossessionParams& params() const { return params_; }
    math::Vec2 spot(const PlayerView& v, const core::World& world) const;

    static const ActingState* onBall();
    static const ActingState* support();
    static const ActingState* receive();
    static const ActingState* keeper();
    static const ActingState* attackBox();

    // Once a tick per team (Brain::think): who runs into the box — how many from
    // the real shares for the ball's zone, who by the real role counts (nearest
    // first among equals); re-drawn when the ball changes zone or every 3 s.
    void assignRunners(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                       const std::vector<Role>& role_of_slot, std::uint64_t match_seed);
    bool runner(std::uint8_t slot) const { return slot < 32 && ((runners_ >> slot) & 1u); }
    int runnerIndex(std::uint8_t slot) const;   // 0, 1, 2 … among his team's runners (their box spots)
    int ballZone(std::uint8_t team) const { return zone_[team & 1]; }
    void reset() { runners_ = 0; zone_[0] = zone_[1] = -1; drawn_[0] = drawn_[1] = 0; for (auto& l : led_) l = Led{}; }

    // A ball in behind as the passer meant it (G5.27): for whom, the spot it is
    // played to, the tick he asked for it. The man it is for runs to the spot
    // (Receive), not to the earliest point of its line.
    struct Led { std::uint8_t to = 0xFF; math::Vec2 at{}; std::uint64_t tick = 0; };
    void noteLed(std::uint8_t passer, std::uint8_t to, const math::Vec2& at, std::uint64_t tick) {
        if (passer < 32) led_[passer] = Led{to, at, tick};
    }
    const Led& led(std::uint8_t passer) const { static const Led none{}; return passer < 32 ? led_[passer] : none; }

private:
    PossessionParams params_{};
    std::uint32_t runners_ = 0;
    int zone_[2] = {-1, -1};
    std::uint64_t drawn_[2] = {0, 0};
    Led led_[32]{};
};

}  // namespace fh::game::ai
