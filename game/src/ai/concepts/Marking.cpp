// game/src/ai/concepts/Marking.cpp — see Marking.hpp.

#include "ai/concepts/Marking.hpp"

namespace fh::game::ai::concepts {

using math::Fixed64;
using math::Vec2;

namespace {

Vec2 v2(const math::Vec3& v) { return Vec2{v.x, v.y}; }
using math::dot;
Vec2 unit(Vec2 v) { return math::lengthSquared(v).raw > 0 ? math::normalized(v) : Vec2{}; }
// a at t = 0 … b at t = 1, t clamped.
Fixed64 mix(Fixed64 a, Fixed64 b, Fixed64 t) { return a + (b - a) * math::fx_clamp(t, Fixed64::zero(), Fixed64::one()); }

}  // namespace

// EYES. Where he looks this tick, and so what he can see.
// [behaviour: eyes_both]
Eyes MarkingMind::look(const core::World& w, core::SlotIndex slot, Vec2& gaze) {
    const Vec2 me = v2(w.player(slot).pos);
    const Vec2 to_ball = unit(v2(w.ball().pos) - me), to_man = unit(v2(w.player(man_).pos) - me);
    // Ball and man both in front of one stance: open up, see both (the bisector).
    if (dot(to_ball, to_man) > p_.both_cos) {
        gaze = unit(to_ball + to_man);
        if (math::lengthSquared(gaze).raw == 0) gaze = to_ball;
        return Eyes::Both;
    }
    // He cannot see both: the ball, with a look over the shoulder at his man on a rhythm.
    // [behaviour: eyes_man]
    const auto phase = static_cast<std::int32_t>((w.tickCount() + slot * 7u) % static_cast<std::uint64_t>(p_.scan_every));
    if (phase < p_.scan_for) { gaze = to_man; return Eyes::Man; }
    // [behaviour: eyes_ball]
    gaze = to_ball;
    return Eyes::Ball;
}

// RECOGNISE. What is inside his field of view goes into his memory, stamped with now.
void MarkingMind::see(const core::World& w, core::SlotIndex slot, Fixed64 sg, MarkView& out) {
    const Vec2 me = v2(w.player(slot).pos);
    const auto& man = w.player(man_);
    const auto& ball = w.ball();
    const Vec2 mp = v2(man.pos), bp = v2(ball.pos);
    const Vec2 to_man = mp - me;
    out.sees_man = dot(unit(to_man), gaze_) >= p_.fov_cos || math::lengthSquared(to_man) <= p_.feel_m * p_.feel_m;
    out.sees_ball = dot(unit(bp - me), gaze_) >= p_.fov_cos;
    if (out.sees_man) mem_.man = Seen{mp, v2(man.vel), w.tickCount(), true};
    if (out.sees_ball) {
        mem_.ball = Seen{bp, v2(ball.vel), w.tickCount(), true};
        mem_.man_has_ball = ball.owner && *ball.owner == man_;
        mem_.pass_to_man = !ball.owner && ball.pass_to == man_ && w.restartTeam() == 0xFF;
        // Back to goal: on the ball and facing away from the goal we defend (at -sg).
        mem_.man_back_to_goal = mem_.man_has_ball && man.face.x * sg > Fixed64::zero();
    }
}

// Where to stand on his man: goal-side, round to the ball's side and tighter the nearer the
// ball is; tighter again near our own goal.
// [behaviour: mark_position]
Vec2 MarkingMind::spot(Vec2 goal) const {
    const Vec2 m = mem_.man.pos;
    const Vec2 to_goal = unit(goal - m), to_ball = unit(mem_.ball.pos - m);
    const Fixed64 ball_d = math::length(mem_.ball.pos - m);
    const Fixed64 t = (ball_d - p_.ball_near_m) / (p_.ball_far_m - p_.ball_near_m);   // 0 near … 1 far
    Fixed64 d = mix(p_.tight_near, p_.tight_far, t);
    const Fixed64 goal_d = math::length(goal - m);
    if (goal_d < p_.goal_tight_m) d = mix(p_.tight_box, d, goal_d / p_.goal_tight_m);
    const Fixed64 side = mix(p_.ball_side_near, p_.ball_side_far, t);
    Vec2 dir = unit(to_goal * (Fixed64::one() - side) + to_ball * side);
    if (math::lengthSquared(dir).raw == 0) dir = to_goal;
    return m + dir * d;
}

MarkView MarkingMind::think(const core::World& w, core::SlotIndex slot, Fixed64 sg) {
    MarkView out;
    out.kind = kind_;
    const Vec2 me = v2(w.player(slot).pos);
    const Vec2 goal{-sg * w.pitchHalfX(), Fixed64::zero()};

    // Recognise.
    Vec2 gaze = gaze_;
    out.eyes = look(w, slot, gaze);
    gaze_ = gaze;
    see(w, slot, sg, out);
    if (!mem_.man.ever) mem_.man = Seen{v2(w.player(man_).pos), Vec2{}, w.tickCount(), true};    // he is told who his man is
    if (!mem_.ball.ever) mem_.ball = Seen{v2(w.ball().pos), Vec2{}, w.tickCount(), true};

    // Choose. Every step's cue, from his MEMORY (not the world), and its score.
    const Vec2 m = mem_.man.pos;
    const Vec2 ideal = spot(goal);
    const Fixed64 to_goal_mps = -(mem_.man.vel.x * sg);                 // + = his man moving at our goal
    const bool goal_side_of_me = (m.x - me.x) * sg < Fixed64::fromInt(2);   // his man level with him or beyond
    const bool in_zone = math::lengthSquared(m - home_) <= p_.zone_r * p_.zone_r;
    const bool cue[kMarkStepCount] = {
        /* PickUp        */ math::lengthSquared(ideal - me) > p_.pick_m * p_.pick_m,
        /* Position      */ true,
        /* TrackRunner   */ !mem_.man_has_ball && to_goal_mps > p_.run_mps && goal_side_of_me,
        /* FollowDropper */ kind_ == MarkKind::ManOriented && !mem_.man_has_ball && to_goal_mps < -p_.drop_mps,
        /* PassOn        */ kind_ == MarkKind::Zonal && !in_zone,
        /* JumpPass      */ mem_.pass_to_man,
        /* NoTurn        */ mem_.man_has_ball && mem_.man_back_to_goal,
        /* Contain       */ mem_.man_has_ball && !mem_.man_back_to_goal,
    };
    // [FH] priorities — the order a coach gives them; the numbers data should fit.
    static constexpr std::int16_t kScore[kMarkStepCount] = {40, 20, 70, 60, 75, 90, 85, 80};
    MarkStep best = MarkStep::Position;
    std::int16_t best_score = -1;
    for (int i = 0; i < kMarkStepCount; ++i) {
        out.options[i] = MarkOption{static_cast<MarkStep>(i), cue[i], cue[i] ? kScore[i] : std::int16_t{0}};
        if (cue[i] && kScore[i] > best_score) { best_score = kScore[i]; best = static_cast<MarkStep>(i); }
    }
    out.wants = best;
    // He acts on a new answer once it has held for his reaction time.
    if (!started_) { started_ = true; step_ = pending_ = best; pending_since_ = w.tickCount(); }
    if (best != pending_) { pending_ = best; pending_since_ = w.tickCount(); }
    if (pending_ != step_ && w.tickCount() - pending_since_ >= static_cast<std::uint64_t>(p_.react)) step_ = pending_;
    out.step = step_;

    // Execute.
    const Vec2 to_goal = unit(goal - m);
    switch (step_) {
        // [behaviour: mark_pick_up]
        case MarkStep::PickUp: out.target = ideal; out.full_pace = true; break;
        case MarkStep::Position: out.target = ideal; break;
        // [behaviour: mark_track_runner]
        case MarkStep::TrackRunner: out.target = m + mem_.man.vel * p_.lead_s + to_goal * Fixed64::one(); out.full_pace = true; break;
        // [behaviour: mark_follow_dropper]
        case MarkStep::FollowDropper: out.target = m + to_goal * p_.tight_near; out.full_pace = true; break;
        // [behaviour: mark_pass_on]
        case MarkStep::PassOn: out.target = home_; break;
        // [behaviour: mark_jump_pass]
        case MarkStep::JumpPass: out.target = m + to_goal * p_.noturn_m; out.full_pace = true; break;
        // [behaviour: mark_no_turn]
        case MarkStep::NoTurn: out.target = m + to_goal * p_.noturn_m; break;
        // [behaviour: mark_contain]
        case MarkStep::Contain: out.target = m + to_goal * p_.contain_m; break;
    }
    // [behaviour: mark_kind_man]
    // [behaviour: mark_kind_zonal]
    out.face = gaze_;
    return out;
}

}  // namespace fh::game::ai::concepts
