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
#include "ai/concepts/CoverShadow.hpp"
#include "ai/concepts/DirectOpponent.hpp"
#include "ai/concepts/Machines.hpp"
#include "ai/concepts/DoubleTeam.hpp"
#include "ai/concepts/Marking.hpp"
#include "ai/concepts/PressingDistance.hpp"
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
    // G5.221 (§8.327): and it squeezes — while their ball stays there the spot climbs this many m a second, by role, for squeeze_max_s
    math::Fixed64 squeeze[kRoleCount]{}, squeeze_max_s{};
    math::Fixed64 wide_up[kRoleCount]{};            // G5.219 (§8.325): their ball 70 m+ off our line and by a touchline — the block's spot this much higher, by role (m)
    math::Fixed64 stand_off_deep[2][3]{};           // G5.218 (§8.324): the 70+ band split — ball in the middle / by a touchline (0 = the band's row)
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
    bool contest_close = true;   // G5.152 (§8.257): ours first by under cut_margin on their high ball — contest it too
    // G5.242 (§8.348) [concept: engage-or-contain, game_concepts 157]: the presser steps in when his cover has arrived
    // (a mate within engage_cover_m of the ball: his tackle clock × engage_cover) and when the carrier is pinned on the
    // touchline (within pinned_m of it: his stand-off × pinned_scale). 0 = off (he contains on the flat clock).
    math::Fixed64 engage_cover{}, engage_cover_m{}, pinned_scale{}, pinned_m{};
    bool press_on_pass = true;                      // G5.82 (§8.183): the presser steps out as their pass travels
    int cut_margin = 0;                             // G5.99 (§8.200): ticks our first must WIN their pass's race by to go for it
    int their_pass_margin = 0;                      // G5.82 (§8.183): ticks our first may lose their pass's race by and still go; -1 = off (always go)
    // G5.72 (§8.173): marking. Each CB / FB / DM takes the attacker nearest his block spot within
    // mark_r of it (by that man's metres off our goal 0-18 / 18-35 / 35-52 / 52+; one marker a man)
    // and stands mark_d goal-side of him. Fitted to the real nearest-defender tables (DFL
    // benchmarks_tracking_markers.py); mark_r 0 = off in that band.
    math::Fixed64 mark_r[4]{}, mark_d[4]{};
    // The marking mind (ai/concepts/Marking; docs/taxonomy-one-system.md): with a row
    // physics.mark.mind = 1 a marker runs it on the man assignMarks gave him — eyes, memory,
    // the steps of marking — instead of standing mark_d goal-side of him. No row = off: marking
    // is as fitted. It is for the harness to say whether the sim is nearer real with it on.
    bool mark_mind = false;
    // Stay in pressing distance (ai/concepts/PressingDistance): how much of the step that puts
    // his man back inside his reach a man holding his block spot takes (0 … 1). No row
    // physics.pressdist.hold = 0: he reads it and moves for nothing — the sim as fitted.
    math::Fixed64 press_hold{};
    // Press on the cover shadow (ai/concepts/CoverShadow): how far the presser's stand-off spot
    // moves off the line to our goal onto the line to the receiver he is hiding (0 … 1). No row
    // physics.shadow.press = 0: he stands goal-side as fitted.
    math::Fixed64 shadow_press{};
    // Double-team (ai/concepts/DoubleTeam, game_concepts 12): the share of their spells by a touchline,
    // our presser on the man, that a second man comes across and closes the inside. No row
    // physics.press.double_team = 0: the read runs and nobody moves for it.
    concepts::DoubleTeamParams double_team{};
    // G5.85 (§8.186): the ball within gs_r of our goal centre — a holder whose spot is within gs_w of
    // the ball and not gs_m nearer our goal centre than it slides straight toward the goal centre till
    // he is (coaching: in our box, between ball and goal). Fitted to the real goal-side counts (DFL
    // benchmarks_tracking_goalside.py). gs_r 0 = off — and OFF it ships: our targets already put as
    // many men goal-side as real; the men don't reach them (§8.186). Moved nothing at 20 / 25 / 30 m.
    math::Fixed64 gs_r{}, gs_w{}, gs_m{};
    bool depth_now = false;   // G5.162 (§8.267): the block's depth from the ball where it is, not where it's going
    void configure(const core::ModelParams& p);
};

class DefendingBlock {
public:
    DefendingBlock() { params_.configure(core::ModelParams{}); double_team_.configure(params_.double_team); }   // the real tables, no DB needed
    void configure(const core::ModelParams& p) { params_.configure(p); double_team_.configure(params_.double_team); }
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
    void reset() { double_team_.reset(); opponents_.reset(); press_dist_.reset(); shadows_.reset(); machines_.reset(); for (int& m : mind_man_) m = -1; for (auto& t : mark_) for (int& m : t) m = -1; contest_[0] = contest_[1] = -1; press_flight_[0] = press_flight_[1] = false; chaser_[0] = chaser_[1] = presser_[0] = presser_[1] = deep_cb_[0] = deep_cb_[1] = other_cb_[0] = other_cb_[1] = -1; their_won_[0] = their_won_[1] = 0; their_had_[0] = their_had_[1] = false; dw_since_[0] = dw_since_[1] = 0; }

    // G5.72: after assign — each defender's block spot (by slot) and whether his role marks (CB/FB/DM).
    void assignMarks(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                     const std::vector<math::Vec2>& spot_of, const std::vector<bool>& marks);
    int markOf(std::uint8_t team, std::uint8_t slot) const { return slot < 32 ? mark_[team & 1][slot] : -1; }
    math::Vec2 markPoint(std::uint8_t team, int man, const core::World& world) const;   // mark_d goal-side of him
    // Direct opponents (ai/concepts/DirectOpponent): who each outfielder's man is right now, for
    // the side without the ball. A recognition — it moves nobody; Brain::think keeps it current.
    concepts::DirectOpponents& opponents() const { return opponents_; }
    // Pressing distance (ai/concepts/PressingDistance): each defender's reach against the gap to
    // his man, read every tick after the pairs; it moves a man only with physics.pressdist.hold.
    concepts::PressingDistance& pressDistance() const { return press_dist_; }
    // Cover shadows (ai/concepts/CoverShadow): who each defender hides from the ball, and the pass
    // the presser should block; read every tick, it moves the presser only with physics.shadow.press.
    concepts::CoverShadows& shadows() const { return shadows_; }
    // The concept machines (ai/concepts/Machines): every player's marking-scheme, cover-shadow and
    // pressing-distance machines; Brain::think updates them after the job states, and the job
    // states apply their proposals where they set the target.
    concepts::PlayerMachines& machines() const { return machines_; }
    // Double-team (ai/concepts/DoubleTeam): the second man who traps their carrier on the touchline, read after assign.
    concepts::DoubleTeam& doubleTeam() const { return double_team_; }
    bool doubleTeams(std::uint8_t team, int slot) const { return params_.double_team.share.raw > 0 && double_team_.isSecond(team, slot); }
    // physics.mark.mind: the marker's mind for this tick, on the man he was given (a new man, a new mind).
    concepts::MarkView markMind(const PlayerView& v, int man, const core::World& world) const;
    math::Vec2 spot(const PlayerView& v, const core::World& world) const;
    // His share of his formation width for this ball (ball metres off our line).
    math::Fixed64 widthFactor(Role r, math::Fixed64 off_line) const { return bandLookup(params_.width[static_cast<int>(r)], off_line); }

    static const ActingState* holdBlockSpot();
    static const ActingState* pressBall();
    static const ActingState* chaseBall();
    static const ActingState* markMan();
    static const ActingState* doubleTeamBall();

private:
    void assignCover(std::uint8_t team, const core::World& world, const std::vector<std::uint8_t>& team_of_slot,
                     const std::vector<Role>& role_of_slot);
    BlockParams params_{};
    mutable concepts::MarkingMind mind_[32];   // by our slot (physics.mark.mind)
    mutable concepts::DirectOpponents opponents_{};
    mutable concepts::PressingDistance press_dist_{};
    mutable concepts::CoverShadows shadows_{};
    mutable concepts::PlayerMachines machines_{};
    mutable concepts::DoubleTeam double_team_{};
    mutable int mind_man_[32] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
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
    std::uint64_t dw_since_[2] = {0, 0};    // G5.221 (§8.327): the tick their ball became deep and wide (by the defending team); 0 = it is not
};

}  // namespace fh::game::ai
