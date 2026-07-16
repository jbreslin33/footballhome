// footballhome sim - BallControl mechanic
//
// Slice 16.3: one-owner arbitration + ball-glue-to-owner. Runs each tick
// after per-slot Mechanics has computed new velocities/headings and
// written them back to physics, but BEFORE physics.step() integrates.
//
// Rules (DESIGN.md §23.3 Slice 16.3):
//
//   1. First-touch pickup
//      Ball has no owner. Candidates are the set of slots whose Intent
//      had wants_dribble = true AND whose horizontal distance to the
//      ball is <= kBallControlRadius. Winner = the candidate with the
//      smallest distance-squared; ties broken by lower SlotId. If the
//      candidate set is empty, the ball stays loose.
//
//   2. Owner retention
//      Ball already has an owner. If that owner's Intent still has
//      wants_dribble = true AND their horizontal distance to the ball
//      is <= kBallControlRadius, ownership is retained. Otherwise the
//      ball becomes loose immediately (release conditions extended in
//      Slice 16.4).
//
//   3. Ball motion while owned
//      * The owner's velocity magnitude is clamped to
//        `max_walk_speed * dribble_efficiency`. Direction preserved.
//        This is the "dribbling slows you down" invariant.
//      * The ball's velocity is set equal to the owner's (post-cap)
//        velocity so the wire snapshot's ball trailer shows coherent
//        motion for client-side prediction.
//      * The ball's PRE-STEP position is teleported to
//        `owner.position + kBallOwnerLeadDistance * (cos h, sin h, 0)`.
//        Since ball velocity == owner velocity, physics.step then
//        integrates both by the same delta and the glue point survives
//        the integration.
//      * Ball friction (BallPhysics::tickBall) is skipped for owned
//        balls; the owner dictates motion, not passive rolling.
//
// The mechanic is a pure function of its inputs. All state
// (ball_owner_ across ticks, physics writes) lives in Match; this
// module returns a plain-old-data description of what to do.
//
// See sim/DESIGN.md §5.7, §23.2, §23.3 Slice 16.3, ADR §22.21.

#pragma once

#include "common/IdTypes.hpp"
#include "match/Mechanics.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <cstddef>
#include <optional>

namespace fh::sim::mechanics {

// Distance (m) inside which a wants_dribble intent can claim or retain
// the ball. Deliberately smaller than HumanController's
// kBallAutoDribbleRadius (1.5 m) so the auto-hint fires *before* a
// player is close enough to actually claim — that gives client-side
// prediction a few ticks of "about to pick up" warning. 0.5 m ≈ one
// long stride.
inline constexpr math::Fixed64 kBallControlRadius =
    math::Fixed64::fromFraction(1, 2);

// Distance (m) the ball leads ahead of the owner while dribbling. The
// direction is `owner.heading` — so the ball sits at the owner's feet
// on the side they're facing. 0.4 m ≈ arm's length; short enough that
// the ball rarely leaves kBallControlRadius during a turn, long enough
// to be visible on the client renderer.
inline constexpr math::Fixed64 kBallOwnerLeadDistance =
    math::Fixed64::fromFraction(2, 5);

// -- Slice 24.3b contest constants -----------------------------------
//
// Radius (m) within which a non-owner slot asserting
// Intent::wants_to_press contributes pressure to the current owner.
// Wider than kBallControlRadius so a defender arriving on the scene
// can start pressuring BEFORE they'd win a raw first-touch scramble.
// 0.7 m ≈ one lunge distance.
inline constexpr math::Fixed64 kContestRadius =
    math::Fixed64::fromFraction(7, 10);

// Fixed retention penalty (m) applied to kBallControlRadius as soon as
// a valid presser is inside kContestRadius. Baseline "you're being
// pressed" cost regardless of the skill delta. 0.1 m eats HALF of the
// current retention slack (kBallControlRadius 0.5 - kBallOwnerLeadDistance
// 0.4 = 0.1 m of slack) — a marginal press without a skill advantage
// still leaves the retained owner on a knife edge.
inline constexpr math::Fixed64 kPressBaselineCost =
    math::Fixed64::fromFraction(1, 10);

// Slope (m per rating-point) mapping the (press_resistance -
// dribble_efficiency) delta into an additional radius shrink. Positive
// delta ⇒ defender more skilled ⇒ radius shrinks further. At 0.5, a
// 0.10 skill advantage costs another 0.05 m of retention radius.
inline constexpr math::Fixed64 kPressSkillDelta =
    math::Fixed64::fromFraction(1, 2);

// Absolute floor (m) for the pressure-shrunken radius. Guards against
// pathological negative results from a wildly higher press_resistance
// than dribble_efficiency, and gives a hard minimum below which
// retention always fails at the standard 0.4 m glue distance.
inline constexpr math::Fixed64 kMinPressureRadius =
    math::Fixed64::fromFraction(15, 100);

// One slot's contribution to owner arbitration. Match builds these
// each tick after per-slot Mechanics has run: `heading` is the
// mechanics-computed post-tick heading (already written to physics),
// `dribble_efficiency` is the profile's `physical.dribble_efficiency`
// attribute (§16.1), `params` is a borrowed pointer to the slot's
// cached MechanicsParams for max_walk_speed lookup.
//
// The struct is trivially copyable; array-of-struct is cheap enough at
// M1 slot counts (< 32) that a linear scan for the winner is fine.
struct BallControlSlot {
    SlotId                        slot_id;
    math::Vec3                    position;            // pre-step, post-mechanics
    math::Vec3                    new_velocity;        // mechanics-computed
    math::Fixed64                 heading;             // mechanics-computed
    bool                          wants_dribble;
    // Slice 25.2: chooses between dribble cap and carry-sprint cap in
    // BallControl::fillOwnedFields. Populated from Intent::wants_sprint
    // in Match.cpp so a human (or future AI) that asserts sprint while
    // owning the ball moves at max_carry_sprint_speed × dribble_efficiency
    // instead of the slower dribble cap. Ignored when the slot is not
    // the chosen owner.
    bool                          wants_sprint;
    // Slice 24.3b: asserted by a non-owner slot (only defenders in
    // Slice 24.3b) to trigger the contest step. When the ball has an
    // owner and any wants_to_press slot is within kContestRadius of
    // the ball, the owner's effective retention radius shrinks by
    // kPressBaselineCost + kPressSkillDelta × max(0, press_resistance -
    // dribble_efficiency). See the resolveBallControl comment block.
    bool                          wants_to_press;
    math::Fixed64                 dribble_efficiency;  // [0,1] from profile
    // Slice 24.3b: press_resistance rating [0,1] from profile. Only
    // consumed for slots that assert wants_to_press this tick.
    math::Fixed64                 press_resistance;
    const match::MechanicsParams* params;              // borrowed
};

// Outcome of one BallControl tick pass. If `owner` is nullopt, the
// ball stays loose and Match should leave BallPhysics::tickBall +
// physics.step to handle it as before. If `owner` is set, Match must:
//   1. physics.setVelocity(owner_entity, owner_capped_velocity)
//   2. physics.setPosition(ball_entity, ball_target_position)
//   3. physics.setVelocity(ball_entity, ball_target_velocity)
//   4. SKIP BallPhysics::tickBall for this tick (owner dictates motion)
//
// Steps 1..3 must all happen BEFORE physics.step for the integration
// to land ball and owner at the same glue delta.
struct BallControlResult {
    std::optional<SlotId>  owner;

    // Only meaningful when owner.has_value(). Zeroed otherwise so a
    // caller that reads unconditionally still gets deterministic bytes.
    math::Vec3             owner_capped_velocity{};
    math::Vec3             ball_target_velocity{};
    math::Vec3             ball_target_position{};
};

// Resolve ball control for one tick.
//   current_owner   — result from LAST tick; nullopt on first tick or
//                     after Slice 16.4 release.
//   ball_position   — pre-step, post-mechanics ball position.
//   slots           — pointer-to-first + count over all controllable
//                     slots this tick. Callers pass in slot_id order
//                     for determinism; the arbitration algorithm sorts
//                     candidates by (distance², slot_id) internally
//                     but relies on stable input order for the tie
//                     equality check.
//
// Pure, deterministic, no allocation. Safe to call with n_slots == 0
// (returns {owner = nullopt}).
BallControlResult resolveBallControl(std::optional<SlotId>          current_owner,
                                     const math::Vec3&              ball_position,
                                     const BallControlSlot*         slots,
                                     std::size_t                    n_slots);

} // namespace fh::sim::mechanics
