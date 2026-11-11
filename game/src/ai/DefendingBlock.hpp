// game/src/ai/DefendingBlock.hpp
//
// G5.21 (DESIGN §8.119): out of possession, rebuilt clean on the player state
// machines (Players.hpp). States: HoldBlockSpot, PressBall, ChaseBall.
//
// The block spot is real data, not a rule: by role and by the ball's
// distance from our line in 10 m bands, the mean metres off our own line a
// pro defender stands — DFL tracking (Bundesliga, Bassek et al. 2025, CC BY;
// benchmarks_tracking_possession.py DEFENDING SHAPE). No public PL 2015/16
// tracking exists: these are pro tracking, not a PL figure. Across: slideY.
//
// The team's assignments, once a tick: the loose ball's man (our pass: the
// man it's for, unless they get there first; else the race read's first; our
// own dead ball: its taker), and the ONE man who steps to their carrier (the
// nearest outfielder, held until another is switch_m nearer).

#pragma once

#include "ai/Players.hpp"
#include "core/ModelParams.hpp"

namespace fh::game::ai {

struct BlockParams {
    math::Fixed64 spot[kRoleCount][kBandCount]{};   // metres off our own line
    // G5.38 (§8.138): how much of his formation width he keeps, by role and the
    // ball's band — the real settled pair's gap over the standard formation gap.
    math::Fixed64 width[kRoleCount][kBandCount]{};
    // Presser's distance from their carrier (G5.25): by the ball's metres from
    // our line (0-18 / 18-35 / 35-52 / 52-70 / 70+), the real nearest defender's
    // p25 / median / p75 — DFL (benchmarks_tracking_press.py); one roll a spell.
    math::Fixed64 stand_off[5][3]{};
    math::Fixed64 switch_m{};                       // a new presser / chaser must be this much nearer
    math::Fixed64 tackle_per_s{};                   // in reach and goal-side: chance a second he dives
    // G5.41 (§8.141): the back pair is never flat — by the ball's band, the real
    // depth gap between two CBs (DFL); the one marking their front man is deeper.
    math::Fixed64 stagger[kBandCount]{};
    // G5.52 (§8.153): the block's depth for their possession — a real defending
    // line's height goes ~half by the possession (between-spell sd 4.2 m, within
    // 3.6, ball 18-52 m out); one roll a spell of theirs for the whole block,
    // through the real spell offset p10 … p90 (+ = higher) — DFL
    // (benchmarks_tracking_linespell.py); faded out inside 18 m (fitted 18-52 only).
    math::Fixed64 line_q[5]{};
    // G5.70 (§8.171): each forward's own offset off his role's spot, by role p10 … p90 — one roll
    // a man a spell of theirs (DFL benchmarks_tracking_blockspread.py, net of line_q).
    math::Fixed64 man_q[kRoleCount][5]{}, man_near_q[kRoleCount][5]{};   // 20 m+ out / inside 20 m (forwards only)
    // G5.71 (§8.172): their high ball in the air (this high or more) that their man meets first — our
    // nearest outfielder goes to where he meets it, to contest it (0 = off). Real: the nearest of the
    // other side is 1.2-2.0 m off a high ball at head height (DFL benchmarks_tracking_aerial.py).
    math::Fixed64 contest_min_z{};
    bool press_on_pass = true;                      // G5.82 (§8.183): the presser steps out as their pass travels
    int their_pass_margin = 0;                      // G5.82 (§8.183): ticks our first may lose their pass's race by and still go; -1 = off (always go)
    // G5.72 (§8.173): marking. Each CB / FB / DM takes the attacker nearest his block spot within
    // mark_r of it (by that man's metres off our goal 0-18 / 18-35 / 35-52 / 52+; one marker a man)
    // and stands mark_d goal-side of him. Fitted to the real nearest-defender tables (DFL
    // benchmarks_tracking_markers.py); mark_r 0 = off in that band.
    math::Fixed64 mark_r[4]{}, mark_d[4]{};
    void configure(const core::ModelParams& p);
};

class DefendingBlock {
public:
    DefendingBlock() { params_.configure(core::ModelParams{}); }   // the real tables, no DB needed
    void configure(const core::ModelParams& p) { params_.configure(p); }
    const BlockParams& params() const { return params_; }

    void assign(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                const std::vector<Role>& role_of_slot, const Reads::FlightRead& fr, int restart_taker);
    int deepCb(std::uint8_t team) const { return deep_cb_[team & 1]; }
    int chaser(std::uint8_t team) const { return chaser_[team & 1]; }
    int presser(std::uint8_t team) const { return presser_[team & 1]; }
    int contester(std::uint8_t team) const { return contest_[team & 1]; }       // G5.71: our man contesting their high ball
    math::Vec2 contestAt(std::uint8_t team) const { return contest_at_[team & 1]; }
    // G5.82 (§8.183): their pass in flight, nobody of ours chasing it — the presser steps toward where
    // their man meets it (pressFlight true, pressAt the meet point) so he is on him as it arrives.
    bool pressFlight(std::uint8_t team) const { return press_flight_[team & 1]; }
    math::Vec2 pressAt(std::uint8_t team) const { return press_at_[team & 1]; }
    void reset() { for (auto& t : mark_) for (int& m : t) m = -1; contest_[0] = contest_[1] = -1; press_flight_[0] = press_flight_[1] = false; chaser_[0] = chaser_[1] = presser_[0] = presser_[1] = deep_cb_[0] = deep_cb_[1] = other_cb_[0] = other_cb_[1] = -1; their_won_[0] = their_won_[1] = 0; their_had_[0] = their_had_[1] = false; }

    // G5.72: after assign — each defender's block spot (by slot) and whether his role marks (CB/FB/DM).
    void assignMarks(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                     const std::vector<math::Vec2>& spot_of, const std::vector<bool>& marks);
    int markOf(std::uint8_t team, std::uint8_t slot) const { return slot < 32 ? mark_[team & 1][slot] : -1; }
    math::Vec2 markPoint(std::uint8_t team, int man, const core::World& world) const;   // mark_d goal-side of him
    math::Vec2 spot(const PlayerView& v, const core::World& world) const;
    // His share of his formation width for this ball (ball metres off our line).
    math::Fixed64 widthFactor(Role r, math::Fixed64 off_line) const { return bandLookup(params_.width[static_cast<int>(r)], off_line); }

    static const ActingState* holdBlockSpot();
    static const ActingState* pressBall();
    static const ActingState* chaseBall();
    static const ActingState* markMan();

private:
    void assignCover(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                     const std::vector<Role>& role_of_slot);
    BlockParams params_{};
    int chaser_[2] = {-1, -1};
    int contest_[2] = {-1, -1};
    int mark_[2][32] = {};   // G5.72: the attacker each of ours marks (by our slot), -1 none
    math::Vec2 contest_at_[2]{};
    int presser_[2] = {-1, -1};
    bool press_flight_[2] = {false, false};
    math::Vec2 press_at_[2]{};
    int deep_cb_[2] = {-1, -1};    // G5.41: the pair's deeper man (held), and his partner
    int other_cb_[2] = {-1, -1};
    std::uint64_t their_won_[2] = {0, 0};   // G5.52: the tick their live spell began (by the defending team)
    bool their_had_[2] = {false, false};
};

}  // namespace fh::game::ai
