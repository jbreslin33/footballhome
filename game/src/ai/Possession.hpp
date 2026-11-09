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
//            nothing safe); else keep carrying. Whatever he has chosen, until
//            the World lets it go he carries the ball — at goal, off the nearest
//            man (G5.29) — and the kick goes at its aim, not the way he runs.
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
    // G5.59 (§8.160): the share is over every pass, but the chooser only picks among
    // zones holding a mate; × this when the zone is held (DFL recipient zones at the
    // kick, iterative fit — benchmarks_tracking_passzone.py kKappa). 1 = off.
    math::Fixed64 pass_kappa[10][10]{};
    math::Fixed64 risk_weight{};
    math::Fixed64 behind_risk{};
    bool space_on = true; math::Fixed64 space_wide_y{}, cross_depth_m{}, space_max_s{}, space_risk{}, space_roll_m{}; int space_margin_ticks = 0;   // G5.54: the ball into an empty zone ahead   // a ball in behind the race read says they win, at this share (G5.51)   // an unsafe pass's weight, × its zone share
    math::Fixed64 space_back_m = math::Fixed64::fromInt(2);   // physics.space.back_m (G5.58)
    math::Fixed64 clear_from_m{};                   // our end: within this of our line
    math::Fixed64 pass_min_m{};
    math::Fixed64 onside_margin_m{};
    math::Fixed64 keeper_depth_m{}, keeper_depth_k{}, keeper_depth_max_m{}, keeper_long_m{};
    // Runs into the box (G5.26), by the ball's zone (their line 0-18 / 18-35 /
    // 35-52 × centre or wide): the share of time with 0 / 1 / 2 / 3+ of ours in
    // the box zone (0-18 m, |y| < 20.16), the mean count by role, where they stand
    // (metres off the line, |y|) — DFL tracking (benchmarks_tracking_box.py).
    math::Fixed64 box_k[6][4]{}, box_role[6][kRoleCount]{}, box_depth[6]{}, box_ay[6]{};
    // G5.53 (§8.154): how many, by their line inside box_line_deep_m (16) or not — [zone][deep][0..3+], DFL.
    math::Fixed64 box_kl[6][2][4]{}, box_line_deep_m{}, box_line_deep_out_m{};   // G5.61: deep until back past out_m
    bool box_spot_near = true;   // G5.60: the box spots go to the runners nearest them (physics.box.spot_near)
    bool box_from_pass = true;   // G5.60: the zone our pass is going to (physics.box.from_pass)
    math::Fixed64 line_usual[14]{}, follow_line_m{};   // G5.62: their line's mean depth by the ball (5 m bins); support men follow a deeper one
    bool box_restart_keep = true;   // G5.61: our restart (or the call to come after their touch): runners held, no redraw (physics.box.restart_keep)
    bool box_stay = true;   // G5.61: a box runner in the box stays one when a redraw rolls fewer (physics.box.stay)
    bool box_spell_roll = true;   // G5.61: one roll a spell for how many run (box and channel), each zone reads it (physics.box.spell_roll)
    bool box_sticky = true;   // G5.60 (§8.161): a redraw keeps the men already running (physics.box.sticky)
    // G5.56 (§8.157): their wide channel on the ball's side — [zone][deep] mean men, by role, depth, |y| (DFL).
    math::Fixed64 chan_n[6][2]{}, chan_role[6][kRoleCount]{}, chan_depth[6]{}, chan_ay[6]{};
    // Balls in behind (G5.27): by the man's gap short of their line (2 m bins,
    // 0-18 m), the real share of passes for him that are played in behind him (met
    // past the line as it stood at the kick); where it is met past the line (p25-p75
    // roll); the share in the air — DFL tracking (benchmarks_tracking_behind.py).
    math::Fixed64 behind_gap[9]{}, behind_past_lo{}, behind_past_hi{}, behind_air{}, behind_lead_s{};
    // Runs onto their line (G5.45): a man of ours 0-12 m short of it, the ball not
    // going forward, starts a run at his role's real rate a second; he runs to a
    // gap short of the (live) line rolled from his role's real p25 / median / p75
    // of where such runs get to — DFL tracking (benchmarks_tracking_runs.py).
    math::Fixed64 run_rate[kRoleCount]{}, run_end[kRoleCount][3]{}, run_min_m{}, run_max_s{}, run_ball_fwd{};
    // His depth for the possession (G5.46): a real man's gap to their line is ~80%
    // a matter of which possession it is — he takes his own depth for the spell,
    // sd 4-9 m by role, little shared with his mates (corr 0.25), little to do with
    // the ball's side or the man. His spell offset from his role's spot, rolled once
    // a possession through the real p10 / p25 / p50 / p75 / p90 (+ = further from
    // their line) — DFL tracking (benchmarks_tracking_gapspread.py SPELL OFFSET).
    math::Fixed64 depth_q[kRoleCount][5]{};
    // The front man on their line (G5.47): a real side's most advanced outfielder
    // stands p10 / p25 / p50 / p75 / p90 -0.7 / 0.5 / 1.6 / 3.0 / 4.8 m short of
    // their offside line with the ball 10-60 m out (flat by band; past it 15-29% of
    // frames) and holds the job a median 2.2 s — DFL tracking
    // (benchmarks_tracking_shoulder.py, front man's gap). Ours rolls his gap through
    // it once a tenure, never nearer than onside_margin_m (no pass avoids a man
    // past the line yet); a mate takes the job only front_swap_m further on.
    // The second man (G5.49): 1.2 / 2.5 / 4.2 / 6.7 / 9.9 m short (p10 … p90, ball
    // 10-60 m out, DFL), never nearer than the front man's gap.
    math::Fixed64 front_q[5]{}, front_swap_m{}, second_q[5]{};
    // G5.50: how fast a line job closes on his spot on top of the line's velocity
    // [FH, fitted to the real ball-still runs, 41.7 a team-match, DFL]; 0 = uncapped.
    math::Fixed64 front_close{};
    void configure(const core::ModelParams& p);
};

class Possession {
public:
    Possession() { params_.configure(core::ModelParams{}); }   // the real tables, no DB needed
    void configure(const core::ModelParams& p) { params_.configure(p); }
    const PossessionParams& params() const { return params_; }
    math::Vec2 spot(const PlayerView& v, const core::World& world, const std::vector<std::uint8_t>& team_of_slot) const;

    static const ActingState* onBall();
    static const ActingState* support();
    static const ActingState* receive();
    static const ActingState* keeper();
    static const ActingState* attackBox();
    static const ActingState* runLine();

    // Once a tick per team (Brain::think): who runs into the box — how many from
    // the real shares for the ball's zone, who by the real role counts (nearest
    // first among equals); re-drawn when the ball changes zone or every 3 s.
    void assignRunners(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                       const std::vector<Role>& role_of_slot, std::uint64_t match_seed);
    // Once a tick per team (Brain::think, after assignRunners): who starts a run
    // onto their line (G5.45), and whose run is over.
    void assignRuns(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                    const std::vector<Role>& role_of_slot, std::uint64_t match_seed);
    // Once a tick per team (after assignRuns): who is the front man (G5.47).
    void assignFront(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot);
    std::uint8_t front(std::uint8_t team, int k = 0) const { return front_[team & 1][k & 1]; }
    std::uint64_t frontSince(std::uint8_t team, int k = 0) const { return front_at_[team & 1][k & 1]; }
    bool onLine(std::uint8_t team, std::uint8_t slot) const { return front_[team & 1][0] == slot || front_[team & 1][1] == slot; }
    // The front / second man's gap short of their line for this tenure (G5.47 / G5.49), metres.
    math::Fixed64 frontGap(const PlayerView& v) const;
    bool running(std::uint8_t slot) const { return slot < 32 && run_[slot].on; }
    math::Fixed64 runEndGap(std::uint8_t slot) const { return slot < 32 ? run_[slot].end_gap : math::Fixed64{}; }
    math::Fixed64 runY(std::uint8_t slot) const { return slot < 32 ? run_[slot].y : math::Fixed64{}; }
    // Their offside line in `team`'s attack direction (Law 11): their second-last
    // man, else halfway; never behind the ball. Metres along +sg.
    static math::Fixed64 offsideLine(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot);
    // How fast that line moves, world x m/s (G5.47): the velocity of whoever sets it
    // (their second-last man, or the ball past him); 0 at halfway.
    static math::Fixed64 offsideLineVelX(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot);
    bool runner(std::uint8_t slot) const { return slot < 32 && ((runners_ >> slot) & 1u); }
    bool channel(std::uint8_t slot) const { return slot < 32 && ((chan_ >> slot) & 1u); }   // G5.56: his runner spot is their wide channel
    int runnerIndex(std::uint8_t slot) const;   // 0, 1, 2 … among his team's runners (their box spots)
    int ballZone(std::uint8_t team) const { return zone_[team & 1]; }
    void reset() { runners_ = 0; chan_ = 0; zone_[0] = zone_[1] = -1; drawn_[0] = drawn_[1] = 0; deep_[0] = deep_[1] = false; won_[0] = won_[1] = 0; had_[0] = had_[1] = false; for (auto& f : front_) f[0] = f[1] = 0xFF; for (auto& f : front_at_) f[0] = f[1] = 0; for (auto& l : led_) l = Led{}; for (auto& r : run_) r = Run{}; }
    // The tick this team's live spell on the ball began (a restart or a loss ends one).
    std::uint64_t spellStart(std::uint8_t team) const { return won_[team & 1]; }
    // His depth offset for this spell (G5.46), metres further from their line.
    math::Fixed64 spellDepth(const PlayerView& v) const;

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
    std::uint8_t spot_k_[32]{};   // G5.60: his box spot (0 ball side, 1 far side, 2 middle, 3+ deeper) from the draw
    std::uint32_t chan_ = 0;   // G5.56: those of runners_ whose spot is the wide channel
    void assignChannel(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                       const std::vector<Role>& role_of_slot, std::uint64_t match_seed, int z, bool deep, std::uint32_t keep = 0);
    int zone_[2] = {-1, -1};
    std::uint64_t drawn_[2] = {0, 0};
    bool deep_[2] = {false, false};   // G5.53: their line was inside box_line_deep_m at the last draw
    std::uint64_t won_[2] = {0, 0};
    bool had_[2] = {false, false};
    std::uint8_t front_[2][2] = {{0xFF, 0xFF}, {0xFF, 0xFF}};   // [team][front man, second man]
    std::uint64_t front_at_[2][2] = {{0, 0}, {0, 0}};
    math::Fixed64 rollGap(const math::Fixed64* q, std::uint64_t at, const PlayerView& v, int salt) const;
    Led led_[32]{};
    struct Run { bool on = false; std::uint64_t until = 0; math::Fixed64 end_gap{}, y{}; };
    Run run_[32]{};
};

}  // namespace fh::game::ai
