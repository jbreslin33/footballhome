// core/Officials.cpp — see Officials.hpp (G4.88, mig 822).
#include "core/Officials.hpp"

#include "core/World.hpp"
#include "math/FixedMath.hpp"

namespace fh::game::core {

using math::Fixed64;
using math::Vec2;
using math::Vec3;

void Officials::configure(const ModelParams& p) {
    flash_lag_s_ = p.fixed("official.assistant.flash_lag_s", 80);
    noise_[0] = p.fixed("official.assistant.noise_m_at0", 1000);
    noise_[1] = p.fixed("official.assistant.noise_m_at50", 500);
    noise_[2] = p.fixed("official.assistant.noise_m_at100", 200);
    lag_[0] = p.fixed("official.assistant.lag_s_at0", 600);
    lag_[1] = p.fixed("official.assistant.lag_s_at50", 300);
    lag_[2] = p.fixed("official.assistant.lag_s_at100", 100);
    track_s_ = p.fixed("official.assistant.track_s", 500);
    touchline_off_ = p.fixed("official.assistant.touchline_off_m", 1000);
    diagonal_share_ = p.fixed("official.referee.diagonal_y_share", 600);
    ball_pull_ = p.fixed("official.referee.ball_pull", 500);
    behind_ = p.fixed("official.referee.behind_m", 8000);
}

void Officials::setOfficial(OfficialRole role, const OfficialRatings& r, const Body& body,
                            Fixed64 max_speed) {
    const int i = static_cast<int>(role);
    ratings_[i] = r;
    body_[i] = body;
    top_[i] = max_speed;
}

Fixed64 Officials::byRating(std::int16_t r, Fixed64 at0, Fixed64 at50, Fixed64 at100) {
    if (r < 0) r = 50;
    if (r > 100) r = 100;
    if (r <= 50) return at0 + (at50 - at0) * Fixed64::fromInt(r) / Fixed64::fromInt(50);
    return at50 + (at100 - at50) * Fixed64::fromInt(r - 50) / Fixed64::fromInt(50);
}

void Officials::place(Fixed64 half_x, Fixed64 half_y) {
    (void)half_x;
    state_[0] = OfficialState{Vec3{Fixed64::zero(), -Fixed64::fromInt(10), Fixed64::zero()}, Vec3{},
                              Vec2{Fixed64::zero(), Fixed64::one()}};
    const Fixed64 line = half_y + touchline_off_;
    state_[1] = OfficialState{Vec3{Fixed64::zero(), line, Fixed64::zero()}, Vec3{},
                              Vec2{Fixed64::zero(), -Fixed64::one()}};
    state_[2] = OfficialState{Vec3{Fixed64::zero(), -line, Fixed64::zero()}, Vec3{},
                              Vec2{Fixed64::zero(), Fixed64::one()}};
}

// Where each stands (game_ref_positionings).
Vec2 Officials::spotFor(int i, const World& w, Vec2* line_vel) const {
    if (line_vel) *line_vel = Vec2{};
    const Fixed64 hx = w.pitchHalfX(), hy = w.pitchHalfY();
    const auto& b = w.ball();
    if (i == 0) {
        // referee-wide-diagonal [IFAB guidelines; FH numbers]: on the
        // diagonal away from each half's assistant (corner (−x, +y) to
        // (+x, −y)), pulled toward the ball's y, behind the ball toward the
        // goal the attack comes from.
        std::uint8_t team = w.lastTouchTeam();
        if (b.owner) team = w.player(*b.owner).team;
        const Fixed64 asg = team == 0 ? Fixed64::one() : -Fixed64::one();
        Fixed64 x = b.pos.x - asg * behind_;
        if (x > hx) x = hx;
        if (x < -hx) x = -hx;
        const Fixed64 yd = -diagonal_share_ * hy * b.pos.x / hx;
        return Vec2{x, yd + (b.pos.y - yd) * ball_pull_};
    }
    // ar-second-last-defender [IFAB guidelines]: on his touchline, LEVEL
    // with the second-last defender of the team defending his half, or the
    // ball if it is nearer the goal line; at halfway when the line is in
    // the other half. He aims at the line as he read it his lag ago
    // (positioning, G4.90) — so he trails a moving line and the body law
    // does the rest. Measured, assistants sit ~1 m off the second-last
    // defender [Gonçalves et al. 2021], aligned (< 0.2 m) 14% of the time,
    // trailing ~53%, leading ~33% [Mallo et al. 2012]. G4.88 aimed him a
    // positioning slack BEYOND the line (Oudejans's "mostly beyond" is a
    // share, not a distance): mean +2 m, a third of kicks 3 m+.
    const Fixed64 s = i == 1 ? Fixed64::one() : -Fixed64::one();
    const std::uint8_t defending = i == 1 ? 1 : 0;   // team 0 defends −x
    const Fixed64 lag = byRating(ratings_[i].positioning, lag_[0], lag_[1], lag_[2]);
    Fixed64 d1 = Fixed64::fromInt(-1000), d2 = d1, v1{}, v2{};
    for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
        if (w.player(j).team != defending) continue;
        const auto& q = w.player(j);
        const Fixed64 depth = (q.pos.x - q.vel.x * lag) * s;
        if (depth > d1) { d2 = d1; v2 = v1; d1 = depth; v1 = q.vel.x; }
        else if (depth > d2) { d2 = depth; v2 = q.vel.x; }
    }
    Fixed64 line = d2, lv = v2;
    const Fixed64 ball_depth = b.pos.x * s;
    if (ball_depth > line) { line = ball_depth; lv = b.vel.x; }
    if (line_vel) *line_vel = Vec2{lv, Fixed64::zero()};
    if (line < Fixed64::zero()) line = Fixed64::zero();
    if (line > hx) line = hx;
    return Vec2{line * s, s * (hy + touchline_off_)};
}

void Officials::tick(const World& w) {
    for (int i = 0; i < kOfficialCount; ++i) {
        OfficialState& o = state_[i];
        Vec2 line_vel{};
        const Vec2 spot = spotFor(i, w, &line_vel);
        const Vec2 d{spot.x - o.pos.x, spot.y - o.pos.y};
        const Fixed64 dist = math::length(d);
        // He faces the field (assistants, IFAB) or the ball (the referee).
        Vec2 face = i == 0 ? Vec2{w.ball().pos.x - o.pos.x, w.ball().pos.y - o.pos.y}
                           : Vec2{Fixed64::zero(), i == 1 ? -Fixed64::one() : Fixed64::one()};
        if (face.x.raw != 0 || face.y.raw != 0)
            o.face = body_[i].turnToward(o.face, math::normalized(face), kTickDt);
        Vec2 wanted{};
        if (i != 0) {
            // An assistant SHADOWS the line (G4.90; ar-side-steps): he moves
            // at its speed and closes the gap over track_s — walking to the
            // spot with an ease-in, he was always arriving: 29% of kicks 3 m+
            // short of a moving line, 25% 3 m+ beyond, 17% within 1 m.
            Vec2 v{line_vel.x + d.x / track_s_, line_vel.y + d.y / track_s_};
            const Fixed64 sp = math::length(v);
            const Fixed64 cap = top_[i] * body_[i].gait(o.face, sp.raw > 0 ? Vec2{v.x / sp, v.y / sp} : o.face);
            if (sp > cap) v = Vec2{v.x * cap / sp, v.y * cap / sp};
            wanted = v;
        } else if (dist > Fixed64::fromFraction(1, 5)) {
            const Vec2 u{d.x / dist, d.y / dist};
            // Full speed until 3 m out, then easing in [FH].
            Fixed64 k = dist / Fixed64::fromInt(3);
            if (k > Fixed64::one()) k = Fixed64::one();
            const Fixed64 sp = top_[i] * k * body_[i].gait(o.face, u);
            wanted = Vec2{u.x * sp, u.y * sp};
        }
        const Vec2 v = body_[i].step(Vec2{o.vel.x, o.vel.y}, wanted, kTickDt);
        o.vel = Vec3{v.x, v.y, Fixed64::zero()};
        o.pos += o.vel * kTickDt;
    }
}

std::uint32_t Officials::offsidePositionTruth(const World& w, std::uint8_t kicker) {
    // Law 11.1, exactly (the World's G4.8 rule): second-last opponent (the
    // keeper counts), the ball and the halfway line.
    const std::uint8_t kt = w.player(kicker).team;
    const Fixed64 os = kt == 0 ? Fixed64::one() : -Fixed64::one();
    Fixed64 d1 = Fixed64::fromInt(-1000), d2 = d1;
    for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
        if (w.player(j).team == kt) continue;
        const Fixed64 depth = w.player(j).pos.x * os;
        if (depth > d1) { d2 = d1; d1 = depth; }
        else if (depth > d2) { d2 = depth; }
    }
    const Fixed64 ball_depth = w.ball().pos.x * os;
    std::uint32_t mask = 0;
    for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
        if (w.player(j).team != kt || j == kicker) continue;
        const Fixed64 depth = w.player(j).pos.x * os;
        if (depth > d2 && depth > ball_depth && depth > Fixed64::zero()) mask |= (1u << (j & 31));
    }
    return mask;
}

// offside-position, by the assistant, from where he stands:
//  - kick-moment-and-line [Helsen et al. 2006, flash-lag]: at the flash of
//    the kick every moving man is seen flash_lag_s further along his run;
//  - line-from-his-angle [Oudejans et al. 2000]: "level" is his line of
//    sight through the second-last defender — true when he stands level
//    with it; from beyond it a man farther across the pitch than the
//    defender projects ahead (a wrong flag), a nearer one behind (missed);
//  - his offside_judgement: a ± noise on the gap.
// The ball and halfway parts of the law he reads exactly (rows say so).
OffsideCall Officials::judgeOffsidePosition(const World& w, std::uint8_t kicker) const {
    OffsideCall c;
    c.truth = offsidePositionTruth(w, kicker);
    const std::uint8_t kt = w.player(kicker).team;
    const Fixed64 os = kt == 0 ? Fixed64::one() : -Fixed64::one();
    const int ar = kt == 0 ? 1 : 2;   // the half the attack goes into
    c.assistant = ar;
    // The second-last defender (the man, not just his depth).
    int first = -1, second = -1;
    for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
        if (w.player(j).team == kt) continue;
        const Fixed64 depth = w.player(j).pos.x * os;
        if (first < 0 || depth > w.player(static_cast<std::uint8_t>(first)).pos.x * os) {
            second = first;
            first = j;
        } else if (second < 0 || depth > w.player(static_cast<std::uint8_t>(second)).pos.x * os) {
            second = j;
        }
    }
    if (second < 0) return c;
    const auto& dp = w.player(static_cast<std::uint8_t>(second));
    const Vec3& a = state_[ar].pos;
    // vs the line he is to hold (G4.90): the second-last defender, or the
    // ball if nearer the goal line, or halfway — not the defender alone
    // (level with the ball read as metres "beyond").
    Fixed64 hold = dp.pos.x * os;
    if (w.ball().pos.x * os > hold) hold = w.ball().pos.x * os;
    if (hold < Fixed64::zero()) hold = Fixed64::zero();
    c.off_line_m = a.x * os - hold;
    const Vec2 dl{dp.pos.x + dp.vel.x * flash_lag_s_, dp.pos.y + dp.vel.y * flash_lag_s_};
    const Fixed64 noise = byRating(ratings_[ar].offside_judgement, noise_[0], noise_[1], noise_[2]);
    const Fixed64 ball_depth = w.ball().pos.x * os;
    for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
        const auto& p = w.player(j);
        if (p.team != kt || j == kicker) continue;
        const Fixed64 depth = p.pos.x * os;
        if (!(depth > ball_depth && depth > Fixed64::zero())) continue;
        const Vec2 pl{p.pos.x + p.vel.x * flash_lag_s_, p.pos.y + p.vel.y * flash_lag_s_};
        const Fixed64 dy = dl.y - a.y;
        Fixed64 line_x = dl.x;
        if (math::fx_abs(dy) > Fixed64::fromFraction(1, 10))
            line_x = a.x + (dl.x - a.x) * (pl.y - a.y) / dy;
        const Fixed64 gap = (pl.x - line_x) * os +
                            detNoise(w.matchSeed(), w.tickCount(), j, static_cast<std::uint8_t>(210 + ar)) * noise;
        if (gap > Fixed64::zero()) c.called |= (1u << (j & 31));
    }
    return c;
}

}  // namespace fh::game::core
