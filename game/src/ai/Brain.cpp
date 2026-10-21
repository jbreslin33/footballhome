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
// An opponent this close means "under pressure" — shoot range or not,
// get the ball moving before the touch-tight steal lands.
const Fixed64 kPressureRadius = Fixed64::fromFraction(6, 5);  // 1.2 m: truly touch-tight
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

    // ── I have the ball: head for goal; shoot in range; clear when a
    // defender is touch-tight (holding on = losing it to the steal) ─────
    if (ball.owner && *ball.owner == slot) {
        const Vec2 goal{sign >= 0 ? half_x_ : -half_x_, Fixed64::zero()};
        out.move.move = seek(me.pos, goal, kArriveRadius);
        const Vec2 to_goal{goal.x - me.pos.x, goal.y - me.pos.y};
        // Carry under pressure rather than panic-kick: the touch-to-steal
        // contest supplies the turnovers (calibration showed kick-always
        // degenerates to 50-79% loose-ball ping-pong). Passing under
        // pressure — the real answer — arrives with the pass behavior.
        if (math::lengthSquared(to_goal) < kShootRange * kShootRange) {
            out.action = Action::GroundKick;  // shot
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
    if (!ours) {
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

    // ── otherwise: hold the shifted anchor (shape IS support) ──────────
    out.move.move = seek(me.pos, anchor, kArriveRadius);
    return out;
}

}  // namespace fh::game::ai
