// game/src/ai/Concept.cpp — the class-based concepts (G4.33). See Concept.hpp.

#include "ai/Concept.hpp"

#include "math/FixedMath.hpp"

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
    follow_ = p.fixed(key("lateral_follow"), 600);
    lateral_max_ = p.fixed(key("lateral_max_m"), 20000);
    lead_s_ = p.fixed(key("long_ball_lead_s"), 800);
    long_ball_z_ = p.fixed(key("long_ball_height_m"), 1000);
}

Vec2 Libero::target(const ConceptContext& c) const {
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
    Fixed64 depth = deepest - depth_min_ - depth_span_ * c.degree;
    const Fixed64 floor_x = -(c.half_x - Fixed64::fromInt(6));
    if (depth < floor_x) depth = floor_x;
    Fixed64 y = c.seen_ball.y * follow_;
    if (y > lateral_max_) y = lateral_max_;
    if (y < -lateral_max_) y = -lateral_max_;
    return Vec2{depth * s, y};
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
    for (core::SlotIndex o = 0; o < w.playerCount(); ++o) {
        const auto& op = w.player(o);
        if (op.team == me.team) continue;
        if (dist2(op.pos, ball.pos) > sq(receive_radius_)) continue;
        if (facesForward(op) && !pressed(op)) return false;
    }
    return true;
}

std::optional<Fixed64> LineStep::stepLine(const ConceptContext& c) const {
    if (!covered(c)) return std::nullopt;
    const Fixed64 s = c.sign >= 0 ? Fixed64::one() : -Fixed64::one();
    return c.seen_ball.x * s - step_behind_;
}

}  // namespace fh::game::ai
