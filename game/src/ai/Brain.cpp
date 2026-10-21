// game/src/ai/Brain.cpp

#include "ai/Brain.hpp"

#include "ai/Formation.hpp"
#include "core/Ball.hpp"

namespace fh::game::ai {

using core::Action;
using core::MoveIntent;
using core::SlotIndex;
using core::World;
using math::Fixed64;
using math::Vec2;
using math::Vec3;

namespace {

// Shoot when the carrier is inside this range of the goal centre.
const Fixed64 kShootRange = Fixed64::fromInt(22);
// An opponent this close means "under pressure" — look for the pass before
// the touch-tight steal lands.
const Fixed64 kPressureRadius = Fixed64::fromFraction(5, 2);  // 2.5 m
// A passing lane is "closed" if any opponent stands within this of the
// carrier→receiver segment.
const Fixed64 kLaneWidth = Fixed64::fromInt(2);
// Pass only to receivers in this distance window: closer is a handover
// that achieves nothing, farther outruns a ground ball's roll-out.
const Fixed64 kPassMin = Fixed64::fromInt(5);
const Fixed64 kPassMax = Fixed64::fromInt(30);
// Feet-to-feet inside this → ShortPass (8 m/s); beyond → driven (14 m/s).
const Fixed64 kSoftPassRange = Fixed64::fromInt(14);
// Forward progress a receiver must offer to be worth it when NOT pressed.
const Fixed64 kEagerGain = Fixed64::fromInt(8);
// Chase a loose ball only within this radius of the anchor's duties —
// beyond it, trust a better-placed teammate (prevents 11-man ball-chasing,
// the classic youth-soccer failure the teaching tool exists to fix).
const Fixed64 kChaseRadius = Fixed64::fromInt(28);
// "Arrived" radius around the anchor — inside it, stand still instead of
// oscillating over the point.
const Fixed64 kArriveRadius = Fixed64::fromFraction(3, 2);

Vec2 seek(const Vec3& from, const Vec2& to, Fixed64 arrive) {
    const Vec2 d{to.x - from.x, to.y - from.y};
    if (math::lengthSquared(d) < arrive * arrive) {
        return Vec2{};  // close enough — stop
    }
    return math::normalized(d);
}

Fixed64 distSq(const Vec3& a, const Vec3& b) {
    const Vec2 d{a.x - b.x, a.y - b.y};
    return math::lengthSquared(d);
}

// Squared distance from point p to segment a→b (planar). Deterministic:
// one fixed-point division, clamped parameter.
Fixed64 pointSegmentDistSq(const Vec2& p, const Vec2& a, const Vec2& b) {
    const Vec2 ab{b.x - a.x, b.y - a.y};
    const Fixed64 len_sq = math::lengthSquared(ab);
    if (len_sq.raw == 0) {
        const Vec2 d{p.x - a.x, p.y - a.y};
        return math::lengthSquared(d);
    }
    Fixed64 t = (dot(Vec2{p.x - a.x, p.y - a.y}, ab)) / len_sq;
    if (t < Fixed64::zero()) t = Fixed64::zero();
    if (t > Fixed64::one()) t = Fixed64::one();
    const Vec2 c{a.x + ab.x * t, a.y + ab.y * t};
    const Vec2 d{p.x - c.x, p.y - c.y};
    return math::lengthSquared(d);
}

}  // namespace

TeamSetup TeamSetup::splitHalves(std::uint8_t slot_count) {
    TeamSetup s;
    s.team_of_slot.resize(slot_count);
    const std::uint8_t half = slot_count / 2;
    for (std::uint8_t i = 0; i < slot_count; ++i)
        s.team_of_slot[i] = i < half ? 0 : 1;
    return s;
}

Brain::Brain(TeamSetup setup, Fixed64 pitch_half_x, Fixed64 pitch_half_y)
    : setup_{std::move(setup)}, half_x_{pitch_half_x}, half_y_{pitch_half_y} {
    const auto n = setup_.team_of_slot.size();
    index_in_team_.resize(n);
    team_size_.resize(n);
    std::uint8_t count[2] = {0, 0};
    for (std::size_t i = 0; i < n; ++i)
        index_in_team_[i] = count[setup_.team_of_slot[i]]++;
    for (std::size_t i = 0; i < n; ++i)
        team_size_[i] = count[setup_.team_of_slot[i]];
}

bool Brain::isTeamClosest(SlotIndex slot, const World& world,
                          const Vec3& target) const {
    const Fixed64 mine = distSq(world.player(slot).pos, target);
    for (SlotIndex i = 0; i < world.playerCount(); ++i) {
        if (i == slot) continue;
        if (setup_.team_of_slot[i] != setup_.team_of_slot[slot]) continue;
        const Fixed64 d = distSq(world.player(i).pos, target);
        if (d < mine || (d == mine && i < slot)) return false;
    }
    return true;
}

Orders Brain::ordersFor(SlotIndex slot, const World& world) const {
    Orders out;
    const auto& ball = world.ball();
    const auto& me = world.player(slot);
    const int sign = attackSign(slot);

    // ── I have the ball: shoot in range; else look for a forward pass
    // ([Buckland]-lite: lane-checked, progress-scored); else dribble ─────
    if (ball.owner && *ball.owner == slot) {
        const Vec2 goal{sign >= 0 ? half_x_ : -half_x_, Fixed64::zero()};
        const Vec2 to_goal{goal.x - me.pos.x, goal.y - me.pos.y};
        if (math::lengthSquared(to_goal) < kShootRange * kShootRange) {
            out.move.move = seek(me.pos, goal, kArriveRadius);
            out.action = Action::GroundKick;  // shot
            return out;
        }

        // Am I pressed? (Pass eagerness rises under pressure.)
        bool pressed = false;
        for (SlotIndex i = 0; i < world.playerCount() && !pressed; ++i) {
            if (setup_.team_of_slot[i] == setup_.team_of_slot[slot]) continue;
            pressed = distSq(me.pos, world.player(i).pos) <
                      kPressureRadius * kPressureRadius;
        }

        // Best forward receiver with an open lane. Progress = x toward MY
        // goal; deterministic tie-break by slot order (iteration order).
        const Fixed64 sgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
        const Fixed64 my_progress = me.pos.x * sgn;
        bool have_target = false;
        Fixed64 best_progress{};
        Vec2 target{};
        Fixed64 target_dist_sq{};
        for (SlotIndex i = 0; i < world.playerCount(); ++i) {
            if (i == slot) continue;
            if (setup_.team_of_slot[i] != setup_.team_of_slot[slot]) continue;
            const auto& mate = world.player(i);
            const Fixed64 progress = mate.pos.x * sgn;
            if (progress < my_progress + Fixed64::fromInt(3)) continue;
            const Fixed64 dsq = distSq(me.pos, mate.pos);
            if (dsq < kPassMin * kPassMin || dsq > kPassMax * kPassMax)
                continue;
            // Lane check: any opponent near the carrier→mate segment?
            bool open = true;
            const Vec2 a{me.pos.x, me.pos.y};
            const Vec2 b{mate.pos.x, mate.pos.y};
            for (SlotIndex j = 0; j < world.playerCount() && open; ++j) {
                if (setup_.team_of_slot[j] == setup_.team_of_slot[slot])
                    continue;
                open = pointSegmentDistSq(
                           Vec2{world.player(j).pos.x, world.player(j).pos.y},
                           a, b) > kLaneWidth * kLaneWidth;
            }
            if (!open) continue;
            if (!have_target || progress > best_progress) {
                have_target = true;
                best_progress = progress;
                target = b;
                target_dist_sq = dsq;
            }
        }

        if (have_target &&
            (pressed || best_progress - my_progress > kEagerGain)) {
            out.move.move = seek(me.pos, target, Fixed64::fromFraction(1, 10));
            out.action = target_dist_sq < kSoftPassRange * kSoftPassRange
                             ? Action::ShortPass
                             : Action::GroundKick;
            return out;
        }

        // No pass: dribble at goal; if touch-tight with no outlet, clear
        // over the press rather than donating a steal.
        out.move.move = seek(me.pos, goal, kArriveRadius);
        if (pressed) {
            bool touch_tight = false;
            for (SlotIndex i = 0; i < world.playerCount() && !touch_tight;
                 ++i) {
                if (setup_.team_of_slot[i] == setup_.team_of_slot[slot])
                    continue;
                touch_tight = distSq(me.pos, world.player(i).pos) <
                              Fixed64::fromFraction(6, 5) *
                                  Fixed64::fromFraction(6, 5);
            }
            if (touch_tight) out.action = Action::LoftedKick;
        }
        return out;
    }

    // My formation anchor (ball-shifted), the default duty.
    const auto bases = formationBases(team_size_[slot]);
    const Vec2 anchor =
        anchorFor(bases[index_in_team_[slot]], sign, ball.pos, half_x_,
                  half_y_, /*is_keeper=*/team_size_[slot] >= 5 &&
                                           index_in_team_[slot] == 0);

    // ── loose ball: nearest teammate goes for it ────────────────────────
    // ── their ball: nearest teammate presses the carrier ────────────────
    const bool ours =
        ball.owner && setup_.team_of_slot[*ball.owner] ==
                          setup_.team_of_slot[slot];
    // Opponent's dead ball (G3.2): we can't touch it — hold shape and
    // defend the restart instead of crowding an untakeable ball.
    const std::uint8_t restart = world.restartTeam();
    const bool opponents_restart =
        restart != 0xFF && restart != setup_.team_of_slot[slot];
    if (!ours && !opponents_restart) {
        const bool in_range =
            distSq(me.pos, ball.pos) < kChaseRadius * kChaseRadius;
        if (in_range && isTeamClosest(slot, world, ball.pos)) {
            // Run THROUGH the ball: arrive radius far below the capture
            // radius, or the chaser stops forever just out of reach (the
            // calibration harness's first catch — 100% loose ball).
            out.move.move = seek(me.pos, Vec2{ball.pos.x, ball.pos.y},
                                 Fixed64::fromFraction(1, 10));
            return out;
        }
    }

    // ── our ball, off the ball: the carrier's nearest teammate offers a
    // support spot ahead of play ([Buckland]-lite single support player;
    // the sampled support-spot calculator replaces this) ────────────────
    if (ours && ball.owner && *ball.owner != slot) {
        // Nearest teammate to the carrier, EXCLUDING the carrier.
        const auto& carrier = world.player(*ball.owner);
        bool im_support = true;
        const Fixed64 mine_d = distSq(me.pos, carrier.pos);
        for (SlotIndex i = 0; i < world.playerCount() && im_support; ++i) {
            if (i == slot || i == *ball.owner) continue;
            if (setup_.team_of_slot[i] != setup_.team_of_slot[slot]) continue;
            const Fixed64 d = distSq(world.player(i).pos, carrier.pos);
            if (d < mine_d || (d == mine_d && i < slot)) im_support = false;
        }
        if (im_support) {
        const Fixed64 sgn = sign >= 0 ? Fixed64::one() : -Fixed64::one();
        // Candidate spots: 12 m goalward of the carrier, offset ±8 m wide;
        // pick the side with the more open spot (fewer close opponents).
        auto openness = [&](const Vec2& spot) {
            Fixed64 nearest = Fixed64::fromInt(1000);
            for (SlotIndex j = 0; j < world.playerCount(); ++j) {
                if (setup_.team_of_slot[j] == setup_.team_of_slot[slot])
                    continue;
                const Vec2 d{world.player(j).pos.x - spot.x,
                             world.player(j).pos.y - spot.y};
                const Fixed64 dd = math::lengthSquared(d);
                if (dd < nearest) nearest = dd;
            }
            return nearest;  // bigger = more open
        };
        const Fixed64 ahead = carrier.pos.x + sgn * Fixed64::fromInt(12);
        const Vec2 left{ahead, carrier.pos.y - Fixed64::fromInt(8)};
        const Vec2 right{ahead, carrier.pos.y + Fixed64::fromInt(8)};
        const Vec2 spot = openness(left) >= openness(right) ? left : right;
        out.move.move = seek(me.pos, spot, kArriveRadius);
        return out;
        }
    }

    // ── otherwise: hold the shifted anchor (shape IS support) ──────────
    out.move.move = seek(me.pos, anchor, kArriveRadius);
    return out;
}

}  // namespace fh::game::ai
