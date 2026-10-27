// game/src/ai/Concept.cpp — the class-based concepts (G4.33). See Concept.hpp.

#include "ai/Concept.hpp"

#include "core/Clock.hpp"
#include "math/FixedMath.hpp"

#include <optional>

namespace fh::game::ai {

using math::Fixed64;
using math::Vec2;

namespace {
Fixed64 sq(Fixed64 v) { return v * v; }
Fixed64 dist2(const math::Vec3& a, const math::Vec3& b) {
    return sq(a.x - b.x) + sq(a.y - b.y);
}
}  // namespace

// ── Libero ──────────────────────────────────────────────────────────────
void Libero::configure(const core::ModelParams& p) {
    depth_min_ = p.fixed(key("depth_min_m"), 2000);
    depth_span_ = p.fixed(key("depth_span_m"), 3000);
    follow_ = p.fixed(key("lateral_follow"), 1000);       // into the ball's channel
    lateral_max_ = p.fixed(key("lateral_max_m"), 19000);  // channels 2-4 only (mig 665)
    lead_s_ = p.fixed(key("long_ball_lead_s"), 800);
    long_ball_z_ = p.fixed(key("long_ball_height_m"), 1000);
    level_ = p.fixed(key("level_offset_m"), 500);
    lapse_window_ticks_ = p.integer(key("lapse_window_s"), 3) * core::kTickRate;
    if (lapse_window_ticks_ < 1) lapse_window_ticks_ = 1;
}

Vec2 Libero::target(const ConceptContext& c, bool can_play_long) const {
    const auto& w = c.world;
    const auto& ball = w.ball();
    const auto& me = w.player(c.slot);
    const Fixed64 s = c.sign >= 0 ? Fixed64::one() : -Fixed64::one();
    // A long ball dropping toward our goal: meet it where it lands.
    if (!ball.owner && ball.pos.z > long_ball_z_ && ball.vel.x * s < Fixed64::zero())
        return Vec2{ball.pos.x + ball.vel.x * lead_s_, ball.pos.y + ball.vel.y * lead_s_};
    Fixed64 deepest = Fixed64::fromInt(1000);
    for (core::SlotIndex j = 0; j < w.playerCount(); ++j) {
        if (j == c.slot || w.player(j).team != me.team || w.isKeeper(j)) continue;
        const Fixed64 d = w.player(j).pos.x * s;
        if (d < deepest) deepest = d;
    }
    // With the line (a step goal-side of it) while the ball is covered;
    // sweeping depth behind it only when they can play long.
    Fixed64 depth = can_play_long ? deepest - depth_min_ - depth_span_ * c.degree
                                  : deepest - level_;
    const Fixed64 floor_x = -(c.half_x - Fixed64::fromInt(6));
    if (depth < floor_x) depth = floor_x;
    Fixed64 y = c.seen_ball.y * follow_;
    if (y > lateral_max_) y = lateral_max_;
    if (y < -lateral_max_) y = -lateral_max_;
    return Vec2{depth * s, y};
}

// ── DeepSweeper / StepOut (the libero's lapses, G4.46) ──────────────────
namespace {
// x · s of the deepest outfield teammate (own goal negative).
Fixed64 deepestMate(const ConceptContext& c, Fixed64 s) {
    const auto& w = c.world;
    const auto& me = w.player(c.slot);
    Fixed64 deepest = Fixed64::fromInt(1000);
    for (core::SlotIndex j = 0; j < w.playerCount(); ++j) {
        if (j == c.slot || w.player(j).team != me.team || w.isKeeper(j)) continue;
        const Fixed64 d = w.player(j).pos.x * s;
        if (d < deepest) deepest = d;
    }
    return deepest;
}
Fixed64 clampY(Fixed64 y, Fixed64 m) { return y > m ? m : (y < -m ? -m : y); }
}  // namespace

void DeepSweeper::configure(const core::ModelParams& p) {
    depth_ = p.fixed(key("depth_m"), 4000);
    follow_ = p.fixed(key("lateral_follow"), 1000);
    lateral_max_ = p.fixed(key("lateral_max_m"), 19000);
    lead_s_ = p.fixed(key("long_ball_lead_s"), 800);
    long_ball_z_ = p.fixed(key("long_ball_height_m"), 1000);
}

Vec2 DeepSweeper::target(const ConceptContext& c) const {
    const auto& ball = c.world.ball();
    const Fixed64 s = c.sign >= 0 ? Fixed64::one() : -Fixed64::one();
    if (!ball.owner && ball.pos.z > long_ball_z_ && ball.vel.x * s < Fixed64::zero())
        return Vec2{ball.pos.x + ball.vel.x * lead_s_, ball.pos.y + ball.vel.y * lead_s_};
    Fixed64 depth = deepestMate(c, s) - depth_;
    const Fixed64 floor_x = -(c.half_x - Fixed64::fromInt(6));
    if (depth < floor_x) depth = floor_x;
    return Vec2{depth * s, clampY(c.seen_ball.y * follow_, lateral_max_)};
}

void StepOut::configure(const core::ModelParams& p) {
    reach_ = p.fixed(key("reach_m"), 20000);
    channel_ = p.fixed(key("channel_m"), 13600);
    gap_ = p.fixed(key("goal_side_m"), 1500);
    step_ = p.fixed(key("step_m"), 6000);
    follow_ = p.fixed(key("lateral_follow"), 1000);
    lateral_max_ = p.fixed(key("lateral_max_m"), 19000);
}

Vec2 StepOut::target(const ConceptContext& c) const {
    const auto& w = c.world;
    const auto& me = w.player(c.slot);
    const Fixed64 s = c.sign >= 0 ? Fixed64::one() : -Fixed64::one();
    const Fixed64 line = deepestMate(c, s);
    const Fixed64 my_y = clampY(c.seen_ball.y * follow_, lateral_max_);
    // The man between the lines in his channel: ahead of our line, within
    // reach, nearest across.
    std::optional<core::SlotIndex> best;
    Fixed64 best_dy = Fixed64::fromInt(1000);
    for (core::SlotIndex j = 0; j < w.playerCount(); ++j) {
        const auto& o = w.player(j);
        if (o.team == me.team || w.isKeeper(j)) continue;
        const Fixed64 ahead = o.pos.x * s - line;
        if (ahead < Fixed64::zero() || ahead > reach_) continue;
        const Fixed64 dy = math::fx_abs(o.pos.y - my_y);
        if (dy > channel_ || dy >= best_dy) continue;
        best_dy = dy;
        best = j;
    }
    if (best) {
        const auto& o = w.player(*best);
        return Vec2{o.pos.x - gap_ * s, o.pos.y};
    }
    return Vec2{(line + step_) * s, my_y};
}

// ── ShortSimple / DirectBall (the pass ladder's lapses, G4.47) ─────────
void ShortSimple::configure(const core::ModelParams& p) {
    min_ = p.fixed(key("min_m"), 5000);
    max_ = p.fixed(key("max_m"), 15000);
    back_ = p.fixed(key("back_m"), 5000);
}

std::optional<core::SlotIndex> ShortSimple::pick(const ConceptContext& c, const LaneOpen& open) const {
    const auto& w = c.world;
    const auto& me = w.player(c.slot);
    const Fixed64 s = c.sign >= 0 ? Fixed64::one() : -Fixed64::one();
    std::optional<core::SlotIndex> best;
    Fixed64 best_d2 = max_ * max_;
    for (core::SlotIndex j = 0; j < w.playerCount(); ++j) {
        const auto& m = w.player(j);
        if (j == c.slot || m.team != me.team) continue;
        if ((m.pos.x - me.pos.x) * s < -back_) continue;
        const Fixed64 d2 = dist2(m.pos, me.pos);
        if (d2 < min_ * min_ || d2 > best_d2) continue;
        if (!open(Vec2{me.pos.x, me.pos.y}, Vec2{m.pos.x, m.pos.y})) continue;
        best_d2 = d2;
        best = j;
    }
    return best;
}

void DirectBall::configure(const core::ModelParams& p) {
    min_gain_ = p.fixed(key("min_gain_m"), 10000);
    min_ = p.fixed(key("min_m"), 15000);
    max_ = p.fixed(key("max_m"), 30000);
}

std::optional<core::SlotIndex> DirectBall::pick(const ConceptContext& c) const {
    const auto& w = c.world;
    const auto& me = w.player(c.slot);
    const Fixed64 s = c.sign >= 0 ? Fixed64::one() : -Fixed64::one();
    std::optional<core::SlotIndex> best;
    Fixed64 best_x = me.pos.x * s + min_gain_;
    for (core::SlotIndex j = 0; j < w.playerCount(); ++j) {
        const auto& m = w.player(j);
        if (j == c.slot || m.team != me.team || w.isKeeper(j)) continue;
        const Fixed64 x = m.pos.x * s;
        if (x < best_x) continue;
        const Fixed64 d2 = dist2(m.pos, me.pos);
        if (d2 < min_ * min_ || d2 > max_ * max_) continue;
        best_x = x;
        best = j;
    }
    return best;
}

// ── MeetThePass (G4.49) ─────────────────────────────────────────────────
void MeetThePass::configure(const core::ModelParams& p) {
    reaction_ = p.fixed(key("reaction_s"), 200);
    keep_running_ = p.fixed(key("keep_running_mps"), 3000);
    horizon_ticks_ = p.integer(key("horizon_ticks"), 90);
}

// ── FaceThePlay (G4.53) ─────────────────────────────────────────────────
void FaceThePlay::configure(const core::ModelParams& p) {
    within_ = p.fixed(key("within_m"), 10000);
}

// ── SideOnJockey / DropStep (G4.54) ─────────────────────────────────────
void SideOnJockey::configure(const core::ModelParams& p) {
    stance_ = p.fixed(key("stance_deg"), 40000) * math::FX_PI / math::Fixed64::fromInt(180);
}
void DropStep::configure(const core::ModelParams& p) {
    carrier_ = p.fixed(key("carrier_mps"), 4500);
    within_ = p.fixed(key("within_m"), 4000);
    lead_ = p.fixed(key("lead_m"), 2000);
}

void EngageOrContain::configure(const core::ModelParams& p) {
    cover_ = p.fixed(key("cover_m"), 6000);
    touchline_ = p.fixed(key("touchline_m"), 6000);
    danger_ = p.fixed(key("danger_m"), 25000);
}

// ── ShotSelection (G4.55) ───────────────────────────────────────────────
void ShotSelection::configure(const core::ModelParams& p) {
    scale_ = p.fixed(key("xg_scale"), 640);
    decay_ = p.fixed(key("xg_decay_m"), 13500);
    pressed_ = p.fixed(key("pressed_factor"), 700);
    min_pressed_ = p.fixed(key("min_xg_pressed"), 50);
    min_free_ = p.fixed(key("min_xg_free"), 120);
    pass_better_ = p.fixed(key("pass_better"), 1500);
}
math::Fixed64 ShotSelection::xg(math::Fixed64 angle, math::Fixed64 dist, bool pressed) const {
    math::Fixed64 x = scale_ * angle * math::fx_exp_neg(dist / decay_);
    if (pressed) x = x * pressed_;
    const math::Fixed64 cap = math::Fixed64::fromFraction(95, 100);
    return x > cap ? cap : x;
}

// ── LineHold (G4.56) ────────────────────────────────────────────────────
void LineHold::configure(const core::ModelParams& p) {
    hold_ = p.fixed(key("hold_m"), 25000);
    squeeze_ = p.fixed(key("squeeze_m"), 13000);
    drop_ = p.fixed(key("uncovered_drop_m"), 6000);
}

// ── MarkPosition / LoseYourMarker (G4.57) ───────────────────────────────
void MarkPosition::configure(const core::ModelParams& p) {
    near_ = p.fixed(key("near_m"), 10000);
    far_ = p.fixed(key("far_m"), 30000);
    tuck_ = p.fixed(key("tuck_share"), 350);
}
void NearTightFarZone::configure(const core::ModelParams& p) {
    near_ = p.fixed(key("near_m"), 10000);
    far_ = p.fixed(key("far_m"), 35000);
    tight_ = p.fixed(key("tight_m"), 1000);
    loose_ = p.fixed(key("loose_m"), 6000);
}
math::Fixed64 NearTightFarZone::farShare(math::Fixed64 d) const {
    if (d <= near_ || far_ <= near_) return math::Fixed64::zero();
    if (d >= far_) return math::Fixed64::one();
    return (d - near_) / (far_ - near_);
}
void LoseYourMarker::configure(const core::ModelParams& p) {
    tight_ = p.fixed(key("tight_m"), 3000);
    step_ = p.fixed(key("step_m"), 5000);
    leash_ = p.fixed(key("leash_m"), 8000);
}

void DirectOpponent::configure(const core::ModelParams& p) {
    zone_ = p.fixed(key("zone_m"), 12000);
}

void KeepItUnderPressure::configure(const core::ModelParams& p) {
    own_third_ = p.fixed(key("own_third_m"), 35000);
    back_max_ = p.fixed(key("back_pass_max_m"), 30000);
    step_ = p.fixed(key("shield_step_m"), 3000);
    speed_ = p.fixed(key("shield_speed_share"), 500);
}

// ── the one-spot defender (G4.63) ───────────────────────────────────────
void PressingDistance::configure(const core::ModelParams& p) {
    pass_speed_ = p.fixed(key("pass_speed_mps"), 14000);
    reaction_ = p.fixed(key("reaction_s"), 300);
    contact_ = p.fixed(key("contact_m"), 1500);
    help_ = p.fixed(key("help_weight"), 1000);
    cost_ = p.fixed(key("move_cost_per_m"), 100);
    meet_ = p.fixed(key("meet_share"), 500);
    max_off_ = p.fixed(key("max_off_man_m"), 6000);
}

void ShadowSecondMan::configure(const core::ModelParams& p) {
    from_passer_ = p.fixed(key("lane_from_passer_m"), 4000);
    from_man_ = p.fixed(key("lane_from_man_m"), 3000);
    width_ = p.fixed(key("lane_width_m"), 1000);
    weight_ = p.fixed(key("lane_weight"), 2000);
}

void PackTheMiddle::configure(const core::ModelParams& p) {
    nine_ = p.integer(key("false_nine_number"), 9);
    right_ = p.integer(key("right_wing_number"), 7);
    left_ = p.integer(key("left_wing_number"), 11);
    mid_[0] = p.integer(key("midfield_number_a"), 6);
    mid_[1] = p.integer(key("midfield_number_b"), 8);
    mid_[2] = p.integer(key("midfield_number_c"), 10);
    tuck_ = p.fixed(key("tuck_width_m"), 14000);
    weak_tuck_ = p.fixed(key("weak_tuck_width_m"), 7000);
    central_ = p.fixed(key("central_width_m"), 18000);
    screen_ = p.fixed(key("screen_gap_m"), 3000);
    nine_screen_ = p.fixed(key("nine_screen_gap_m"), 8000);
    from_halfway_ = p.fixed(key("from_halfway_m"), 0);
    handover_ = p.fixed(key("handover_m"), 4000);
}

void PressTheFullBack::configure(const core::ModelParams& p) {
    gap_ = p.fixed(key("step_gap_m"), 1500);
    ahead_ = p.fixed(key("shadow_ahead_m"), 2000);
    handover_ = p.fixed(key("handover_m"), 3000);
}

void LockTheDoor::configure(const core::ModelParams& p) {
    gap_ = p.fixed(key("lock_gap_m"), 3000);
    shade_ = p.fixed(key("shade_m"), 2000);
    reach_ = p.fixed(key("reach_m"), 8000);
}

void DefendYourMan::configure(const core::ModelParams& p) {
    gap_ = p.fixed(key("no_turn_gap_m"), 700);
    within_ = p.fixed(key("no_turn_within_m"), 3000);
    contain_ = p.fixed(key("contain_gap_m"), 2200);
}

void ShadowTheLine::configure(const core::ModelParams& p) {
    from_fb_ = p.fixed(key("from_fb_m"), 3000);
    on_line_ = p.fixed(key("on_line_m"), 1500);
    handover_ = p.fixed(key("handover_m"), 3000);
}

void PlayOffLongBall::configure(const core::ModelParams& p) {
    off_ = p.fixed(key("off_m"), 7000);
    ahead_ = p.fixed(key("ahead_of_line_m"), 0);
}

void JumpThePass::configure(const core::ModelParams& p) {
    gap_ = p.fixed(key("arrive_gap_m"), 1000);
    max_ = p.fixed(key("jump_max_m"), 30000);
}

// ── CoverShadow ─────────────────────────────────────────────────────────
void CoverShadow::configure(const core::ModelParams& p) {
    deep_x_ = p.fixed(key("deep_x_m"), 15000);
    handover_ = p.fixed(key("handover_m"), 3500);
    gap_ = p.fixed(key("gap_m"), 2500);
    lane_width_ = p.fixed(key("lane_width_m"), 25000);
    ahead_ = p.fixed(key("receiver_ahead_m"), 3000);
}

std::optional<Vec2> CoverShadow::target(const ConceptContext& c) const {
    const auto& w = c.world;
    const auto& ball = w.ball();
    if (!ball.owner) return std::nullopt;
    const core::SlotIndex car_slot = *ball.owner;
    const auto& car = w.player(car_slot);
    const auto& me = w.player(c.slot);
    const Fixed64 s = c.sign >= 0 ? Fixed64::one() : -Fixed64::one();
    if (car.team == me.team || w.isKeeper(car_slot)) return std::nullopt;
    if (car.pos.x * s <= deep_x_) return std::nullopt;            // not building from the back
    if (dist2(me.pos, car.pos) <= sq(handover_)) return std::nullopt;  // close: the press takes over
    core::SlotIndex rcv = 255;
    Fixed64 best{};
    for (core::SlotIndex o = 0; o < w.playerCount(); ++o) {
        const auto& op = w.player(o);
        if (o == car_slot || op.team != car.team || w.isKeeper(o)) continue;
        if (op.pos.x * s > car.pos.x * s - ahead_) continue;      // must be ahead of him
        if (math::fx_abs(op.pos.y) > lane_width_) continue;        // central receiver
        const Fixed64 d = dist2(car.pos, op.pos);
        if (rcv == 255 || d < best) { rcv = o; best = d; }
    }
    if (rcv == 255) return std::nullopt;
    const auto& rp = w.player(rcv);
    const Vec2 lane = math::normalized(Vec2{rp.pos.x - car.pos.x, rp.pos.y - car.pos.y});
    return Vec2{car.pos.x + lane.x * gap_, car.pos.y + lane.y * gap_};
}

// ── LineStep ────────────────────────────────────────────────────────────
void LineStep::configure(const core::ModelParams& p) {
    step_behind_ = p.fixed(key("step_behind_m"), 12000);
    receive_radius_ = p.fixed(key("receive_radius_m"), 6000);
    pressure_radius_ = p.fixed(key("pressure_radius_m"), 3000);
    moving_speed_ = p.fixed(key("moving_speed_mps"), 4000);
    forward_ = p.fixed(key("forward_ball_m"), 5000);
}

bool LineStep::covered(const ConceptContext& c) const {
    const auto& w = c.world;
    const auto& ball = w.ball();
    const auto& me = w.player(c.slot);
    const Fixed64 s = c.sign >= 0 ? Fixed64::one() : -Fixed64::one();
    // An opponent "faces forward" when he faces OUR goal (-s along x).
    auto facesForward = [&](const core::PlayerState& p) { return p.face.x * s < Fixed64::zero(); };
    auto pressed = [&](const core::PlayerState& p) {
        for (core::SlotIndex j = 0; j < w.playerCount(); ++j)
            if (w.player(j).team == me.team && dist2(w.player(j).pos, p.pos) <= sq(pressure_radius_))
                return true;
        return false;
    };
    if (ball.owner) {
        const auto& car = w.player(*ball.owner);
        if (car.team == me.team) return false;
        return !facesForward(car) || pressed(car);   // turned back, or pressed
    }
    // The ball is moving between them: covered — unless a free opponent
    // is about to receive it facing forward.
    const Fixed64 speed2 = sq(ball.vel.x) + sq(ball.vel.y);
    if (speed2 < sq(moving_speed_)) return false;
    // Read by its flight (G4.49): we win it → covered; a ball played
    // FORWARD to them (toward our goal) → uncovered, whoever is near it now.
    math::Vec3 at = ball.pos;
    if (c.flight_first >= 0) {
        if (c.flight_first == me.team) return true;
        if ((ball.pos.x - c.flight_at.x) * s > forward_) return false;
        at = math::Vec3{c.flight_at.x, c.flight_at.y, Fixed64::zero()};
    }
    for (core::SlotIndex o = 0; o < w.playerCount(); ++o) {
        const auto& op = w.player(o);
        if (op.team == me.team) continue;
        if (dist2(op.pos, at) > sq(receive_radius_)) continue;
        if (facesForward(op) && !pressed(op)) return false;
    }
    return true;
}

std::optional<Fixed64> LineStep::stepLine(const ConceptContext& c) const {
    if (!covered(c)) return std::nullopt;
    const Fixed64 s = c.sign >= 0 ? Fixed64::one() : -Fixed64::one();
    return c.seen_ball.x * s - step_behind_;
}

// ── PassLadder ──────────────────────────────────────────────────────────
void PassLadder::configure(const core::ModelParams& p) {
    pocket_depth_ = p.fixed(key("pocket_depth_m"), 10000);
    central_half_width_ = p.fixed(key("central_half_width_m"), 20000);
    fire_min_ = p.integer(key("fire_rung_min"), 2);
    fire_span_ = p.fixed(key("fire_rung_span"), 2000);
    lead_s_ = p.fixed(key("lead_s"), 300);
    pass_speed_ = p.fixed(key("lead_pass_speed_mps"), 12000);
}

PassLadder::Lines PassLadder::lines(const core::World& w, core::SlotIndex passer, int sign) const {
    const Fixed64 s = sign >= 0 ? Fixed64::one() : -Fixed64::one();
    const auto team = w.player(passer).team;
    Lines l{Fixed64::fromInt(-1000), Fixed64::fromInt(1000), Fixed64::fromInt(-1000)};
    Fixed64 last = Fixed64::fromInt(-1000);
    for (core::SlotIndex j = 0; j < w.playerCount(); ++j) {
        if (w.player(j).team == team) continue;
        const Fixed64 d = w.player(j).pos.x * s;
        if (d > last) { l.offside = last; last = d; }
        else if (d > l.offside) l.offside = d;
        if (w.isKeeper(j)) continue;
        if (d > l.back) l.back = d;
        if (d < l.first) l.first = d;
    }
    return l;
}

int PassLadder::rung(Fixed64 progress, Fixed64 y, const Lines& l) const {
    const int wide = math::fx_abs(y) > central_half_width_ ? 1 : 0;
    if (progress > l.back) return 1 + wide;                  // in behind
    if (progress > l.back - pocket_depth_) return 3 + wide;  // the pocket in front of the line
    if (progress > l.first) return 5 + wide;                 // past their first line
    return 0;
}

int PassLadder::fireRung(Fixed64 degree) const {
    // Rounded: Bielsa's 90 reaches rung 4 (pocket wide) with the defaults.
    const Fixed64 extra = fire_span_ * degree + Fixed64::halfConst();
    return fire_min_ + static_cast<int>(extra.raw >> Fixed64::FRAC_BITS);
}

bool PassLadder::offsidePosition(Fixed64 progress, Fixed64 ball_progress, const Lines& l) {
    return progress > l.offside && progress > ball_progress && progress > Fixed64::zero();
}

Vec2 PassLadder::leadPoint(const core::PlayerState& p, const math::Vec3& from) const {
    const Fixed64 t = lead_s_ + math::length(Vec2{p.pos.x - from.x, p.pos.y - from.y}) / pass_speed_;
    return Vec2{p.pos.x + p.vel.x * t, p.pos.y + p.vel.y * t};
}

bool PassLadder::better(int ra, Fixed64 pa, int rb, Fixed64 pb) {
    const int a = ra == 0 ? 7 : ra;
    const int b = rb == 0 ? 7 : rb;
    return a != b ? a < b : pa > pb;
}

// ── BlindSideRun ────────────────────────────────────────────────────────
void BlindSideRun::configure(const core::ModelParams& p) {
    line_band_ = p.fixed(key("line_band_m"), 18000);
    marker_radius_ = p.fixed(key("marker_radius_m"), 10000);
    shoulder_ = p.fixed(key("shoulder_m"), 1500);
    onside_margin_ = p.fixed(key("onside_margin_m"), 2000);
    run_depth_ = p.fixed(key("run_depth_m"), 10000);
    channel_pull_ = p.fixed(key("channel_pull"), 600);
    carrier_free_ = p.fixed(key("carrier_free_m"), 3500);
    max_runners_ = p.integer(key("max_runners"), 2);
    blind_cos_ = p.fixed(key("blind_cos"), 0);
    end_margin_ = p.fixed(key("end_margin_m"), 6000);
}

bool BlindSideRun::go(const ConceptContext& c, core::SlotIndex marker) const {
    const auto& w = c.world;
    const auto& ball = w.ball();
    if (!ball.owner) return false;
    const auto& car = w.player(*ball.owner);
    for (core::SlotIndex j = 0; j < w.playerCount(); ++j)         // no time to pass yet
        if (w.player(j).team != car.team && dist2(w.player(j).pos, car.pos) < sq(carrier_free_))
            return false;
    const auto& mk = w.player(marker);
    const auto& me = w.player(c.slot);
    const Vec2 to_me = math::normalized(Vec2{me.pos.x - mk.pos.x, me.pos.y - mk.pos.y});
    return mk.face.x * to_me.x + mk.face.y * to_me.y < blind_cos_;  // behind his eyes
}

std::optional<Vec2> BlindSideRun::target(const ConceptContext& c) const {
    const auto& w = c.world;
    const auto& ball = w.ball();
    const auto& me = w.player(c.slot);
    if (!ball.owner || w.player(*ball.owner).team != me.team || *ball.owner == c.slot)
        return std::nullopt;
    const Fixed64 s = c.sign >= 0 ? Fixed64::one() : -Fixed64::one();
    // Their line: the deepest outfield opponent; the offside line: the
    // second-last opponent, keeper included.
    Fixed64 line = Fixed64::fromInt(-1000), last = line, offside = line;
    for (core::SlotIndex j = 0; j < w.playerCount(); ++j) {
        const auto& op = w.player(j);
        if (op.team == me.team) continue;
        const Fixed64 d = op.pos.x * s;
        if (d > last) { offside = last; last = d; }
        else if (d > offside) offside = d;
        if (!w.isKeeper(j) && d > line) line = d;
    }
    if (me.pos.x * s < line - line_band_) return std::nullopt;   // not up at their line
    // Only the most advanced few make the run (ties → lower slot).
    int ahead = 0;
    for (core::SlotIndex j = 0; j < w.playerCount(); ++j) {
        const auto& t = w.player(j);
        if (j == c.slot || t.team != me.team || w.isKeeper(j) || j == *ball.owner) continue;
        if (t.pos.x * s > me.pos.x * s || (t.pos.x * s == me.pos.x * s && j < c.slot)) ++ahead;
    }
    if (ahead >= max_runners_) return std::nullopt;
    // My man: the nearest line defender (within the band of the line).
    core::SlotIndex mk = 255;
    Fixed64 best{};
    for (core::SlotIndex j = 0; j < w.playerCount(); ++j) {
        const auto& op = w.player(j);
        if (op.team == me.team || w.isKeeper(j)) continue;
        if (op.pos.x * s < line - line_band_) continue;
        const Fixed64 d = dist2(me.pos, op.pos);
        if (d > sq(marker_radius_)) continue;
        if (mk == 255 || d < best) { mk = j; best = d; }
    }
    if (mk == 255) return std::nullopt;
    const auto& m = w.player(mk);
    // Far-from-ball shoulder: the side of him away from the ball.
    const Fixed64 side = m.pos.y >= c.seen_ball.y ? Fixed64::one() : -Fixed64::one();
    const Fixed64 shoulder_y = m.pos.y + side * shoulder_;
    // Wait onside on his blind shoulder — and a run the pass didn't find
    // (now offside with the ball still at our feet) comes back to re-time.
    const Fixed64 ball_x = w.ball().pos.x * s;
    const bool offside_now =
        me.pos.x * s > offside && me.pos.x * s > ball_x && me.pos.x * s > Fixed64::zero();
    if (offside_now || !go(c, mk)) return Vec2{(line - onside_margin_) * s, shoulder_y};
    // Go: across his back into the space behind, pulled toward the channel
    // between him and goal.
    Fixed64 depth = line + run_depth_;
    const Fixed64 cap = c.half_x - end_margin_;
    if (depth > cap) depth = cap;
    return Vec2{depth * s, shoulder_y * channel_pull_};
}

// ── ReleaseTiming ───────────────────────────────────────────────────────
void ReleaseTiming::configure(const core::ModelParams& p) {
    approach_ = p.fixed(key("approach_m"), 15000);
    runner_speed_ = p.fixed(key("runner_speed_mps"), 4000);
}

bool ReleaseTiming::hold(const core::World& w, core::SlotIndex carrier, int sign,
                         const PassLadder::Lines& l, const PassLadder&) const {
    const Fixed64 s = sign >= 0 ? Fixed64::one() : -Fixed64::one();
    const auto& car = w.player(carrier);
    for (core::SlotIndex j = 0; j < w.playerCount(); ++j) {
        const auto& m = w.player(j);
        if (j == carrier || m.team != car.team || w.isKeeper(j)) continue;
        const Fixed64 prog = m.pos.x * s;
        if (prog > l.offside) continue;                       // already offside: no
        if (l.offside - prog > approach_) continue;           // not near the line yet
        if (m.vel.x * s < runner_speed_) continue;            // not attacking it
        return true;
    }
    return false;
}

// ── Scanning / Vision (G4.66) ───────────────────────────────────────────
void Scanning::configure(const core::ModelParams& p) {
    at1_ = p.fixed(key("every_s_at1"), 20000);
    at100_ = p.fixed(key("every_s_at100"), 1250);
}

std::int32_t Scanning::everyTicks(std::uint8_t rating) const {
    // Looks per second on a straight line from the 1 to the 100 (James
    // 10/26: a 1 "should basically look less" — rarely, not every 5 s).
    const int r = rating < 1 ? 1 : (rating > 100 ? 100 : rating);
    const math::Fixed64 f1 = math::Fixed64::one() / at1_, f100 = math::Fixed64::one() / at100_;
    const math::Fixed64 f = f1 + (f100 - f1) * math::Fixed64::fromFraction(r - 1, 99);
    const std::int32_t t = static_cast<std::int32_t>((math::Fixed64::fromInt(core::kTickRate) / f).raw >> math::Fixed64::FRAC_BITS);
    return t < 1 ? 1 : t;
}

void Vision::configure(const core::ModelParams& p) {
    cos_half = math::fx_cos(p.fixed("physics.vision.view_half_deg", 100000) * math::FX_PI /
                            math::Fixed64::fromInt(180));
    feel = p.fixed("physics.vision.feel_m", 2000);
    const math::Fixed64 age = p.fixed("physics.vision.max_age_s", 3000);
    max_age_ticks = static_cast<std::int32_t>((age * math::Fixed64::fromInt(core::kTickRate)).raw >> math::Fixed64::FRAC_BITS);
    const math::Fixed64 blind = p.fixed("physics.vision.blind_pass_s", 500);
    blind_pass_ticks = static_cast<std::int32_t>((blind * math::Fixed64::fromInt(core::kTickRate)).raw >> math::Fixed64::FRAC_BITS);
}

}  // namespace fh::game::ai
