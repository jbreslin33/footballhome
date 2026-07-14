// footballhome sim - BallControl unit tests (Slice 16.3)
//
// Covers the pure arbitration + glue logic in mechanics/BallControl.
// Integration with Match::tick (physics writes, ownership persistence
// across ticks) lives in test_match_ball.cpp.

#include "mechanics/BallControl.hpp"

#include "match/Mechanics.hpp"
#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"
#include "math/Vec3.hpp"
#include "test_harness.hpp"

#include <vector>

using fh::sim::SlotId;
using fh::sim::match::MechanicsParams;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::math::fx_cos;
using fh::sim::math::fx_sin;
using fh::sim::mechanics::BallControlSlot;
using fh::sim::mechanics::BallControlResult;
using fh::sim::mechanics::kBallControlRadius;
using fh::sim::mechanics::kBallOwnerLeadDistance;
using fh::sim::mechanics::resolveBallControl;

namespace {

// Compact params factory — every field is set explicitly to a benign
// value; individual tests override only what they care about. Kept
// local so the mechanics test suite here doesn't accidentally pin
// production defaults (M0Attributes.cpp is the single source of truth).
MechanicsParams makeParams(Fixed64 max_walk_speed = Fixed64::fromInt(2))
{
    MechanicsParams p;
    p.max_walk_speed        = max_walk_speed;
    p.max_jog_speed         = Fixed64::fromInt(4);
    p.max_sprint_speed      = Fixed64::fromInt(7);
    p.acceleration          = Fixed64::fromInt(6);
    p.deceleration          = Fixed64::fromInt(8);
    p.agility               = Fixed64::fromInt(6);
    p.stamina_max           = Fixed64::one();
    p.stamina_drain_rate    = Fixed64::zero();
    p.stamina_recovery_rate = Fixed64::zero();
    // dribble_efficiency intentionally NOT set here — BallControlSlot
    // carries its own copy (per-slot from profile), keeping the two
    // sources orthogonal in test setup.
    p.dribble_efficiency    = Fixed64::zero();
    return p;
}

// Compact BallControlSlot factory. `dribble_efficiency` defaults to 1.0
// so tests that don't care about the cap still get well-behaved motion
// (velocity magnitude preserved).
BallControlSlot makeSlot(SlotId                slot,
                         Vec3                  position,
                         bool                  wants_dribble,
                         const MechanicsParams* params,
                         Fixed64               dribble_efficiency = Fixed64::one(),
                         Vec3                  new_velocity = Vec3{},
                         Fixed64               heading      = Fixed64::zero())
{
    BallControlSlot s;
    s.slot_id            = slot;
    s.position           = position;
    s.new_velocity       = new_velocity;
    s.heading            = heading;
    s.wants_dribble      = wants_dribble;
    s.dribble_efficiency = dribble_efficiency;
    s.params             = params;
    return s;
}

const Vec3 kBallAtOrigin{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()};

} // namespace

// ---------------------------------------------------------------------------
// Rule 1 — first-touch pickup: loose ball, no candidates → stays loose.
// ---------------------------------------------------------------------------
FH_TEST(loose_ball_no_candidates_stays_loose) {
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        // wants_dribble = false → NOT a candidate even though it's on
        // top of the ball.
        makeSlot(SlotId{1}, kBallAtOrigin, /*wants=*/false, &p),
    };
    const auto r = resolveBallControl(std::nullopt, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(!r.owner.has_value());
}

FH_TEST(loose_ball_zero_slots_stays_loose) {
    const auto r = resolveBallControl(std::nullopt, kBallAtOrigin,
                                      nullptr, 0);
    FH_EXPECT(!r.owner.has_value());
}

// ---------------------------------------------------------------------------
// Rule 1 — first-touch pickup: closest wants_dribble in range wins.
// ---------------------------------------------------------------------------
FH_TEST(loose_ball_single_candidate_in_range_wins) {
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{3}, Vec3{Fixed64::fromFraction(1, 10),
                                 Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/true, &p),
    };
    const auto r = resolveBallControl(std::nullopt, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{3});
}

FH_TEST(loose_ball_candidate_out_of_range_stays_loose) {
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        // 2 m away — kBallControlRadius is 0.5 m.
        makeSlot(SlotId{1}, Vec3{Fixed64::fromInt(2),
                                 Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/true, &p),
    };
    const auto r = resolveBallControl(std::nullopt, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(!r.owner.has_value());
}

FH_TEST(loose_ball_boundary_at_radius_is_inclusive) {
    // Ball at exactly kBallControlRadius from candidate → inclusive
    // (dsq == r²). Locks the "<=" contract; flipping it to "<" would
    // introduce a 1-tick unreachable ring at the edge which nobody
    // wants (feels like the ball rejects you at arm's length).
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{1}, Vec3{kBallControlRadius,
                                 Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/true, &p),
    };
    const auto r = resolveBallControl(std::nullopt, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{1});
}

FH_TEST(loose_ball_closest_of_multiple_wins) {
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        // Farther candidate first — order shouldn't matter, only distance.
        makeSlot(SlotId{5}, Vec3{Fixed64::fromFraction(4, 10),
                                 Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/true, &p),
        makeSlot(SlotId{3}, Vec3{Fixed64::fromFraction(1, 10),
                                 Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/true, &p),
    };
    const auto r = resolveBallControl(std::nullopt, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{3});
}

FH_TEST(loose_ball_ties_broken_by_lower_slot_id) {
    // Two candidates equidistant — winner MUST be the lower SlotId
    // for deterministic first-touch resolution across arches.
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        // Higher SlotId listed first — makes sure the algorithm isn't
        // accidentally taking whoever appears first in the array.
        makeSlot(SlotId{7}, Vec3{Fixed64::fromFraction(2, 10),
                                 Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/true, &p),
        makeSlot(SlotId{2}, Vec3{Fixed64::fromFraction(2, 10),
                                 Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/true, &p),
    };
    const auto r = resolveBallControl(std::nullopt, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{2});
}

// ---------------------------------------------------------------------------
// Rule 2 — owner retention.
// ---------------------------------------------------------------------------
FH_TEST(owner_retained_when_still_wants_and_in_range) {
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{4}, Vec3{Fixed64::fromFraction(1, 10),
                                 Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/true, &p),
    };
    const auto r = resolveBallControl(SlotId{4}, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{4});
}

FH_TEST(owner_lost_when_released_wants_dribble) {
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        // Owner is on top of the ball but stopped wanting dribble.
        makeSlot(SlotId{4}, kBallAtOrigin, /*wants=*/false, &p),
    };
    const auto r = resolveBallControl(SlotId{4}, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(!r.owner.has_value());
}

FH_TEST(owner_lost_when_moved_out_of_range) {
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        // Owner still wants dribble but wandered 3 m away.
        makeSlot(SlotId{4}, Vec3{Fixed64::fromInt(3),
                                 Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/true, &p),
    };
    const auto r = resolveBallControl(SlotId{4}, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(!r.owner.has_value());
}

FH_TEST(sticky_ownership_beats_equidistant_challenger) {
    // Owner and challenger both exactly 0.2 m from ball. Rule 2 runs
    // before Rule 1, so the CURRENT owner keeps possession — even
    // though Rule 1's tie-break would have handed it to the lower
    // SlotId. Locks the "sticky ownership" contract that avoids
    // per-tick owner flip-flop when two players stand equidistant.
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{2}, Vec3{Fixed64::fromFraction(2, 10),
                                 Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/true, &p),
        makeSlot(SlotId{7}, Vec3{Fixed64::fromFraction(2, 10),
                                 Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/true, &p),
    };
    const auto r = resolveBallControl(SlotId{7}, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{7});
}

FH_TEST(owner_lost_challenger_picks_up_same_tick) {
    // Owner stopped wanting dribble AND wandered out of range.
    // Another slot is on top of the ball with wants_dribble = true.
    // Ownership should transfer this same tick (Rule 2 fails → falls
    // through to Rule 1). No dead frame where the ball is loose.
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{4}, Vec3{Fixed64::fromInt(3),
                                 Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/false, &p),
        makeSlot(SlotId{1}, Vec3{Fixed64::fromFraction(1, 10),
                                 Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/true, &p),
    };
    const auto r = resolveBallControl(SlotId{4}, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{1});
}

// ---------------------------------------------------------------------------
// Rule 3 — ball motion while owned: velocity cap + glue point.
// ---------------------------------------------------------------------------
FH_TEST(owned_velocity_capped_to_walk_speed_times_efficiency) {
    // walk = 2 m/s, efficiency = 0.5 → cap = 1 m/s.
    // Owner intended 3 m/s east; should be clamped to 1 m/s east.
    const auto p = makeParams(Fixed64::fromInt(2));
    const auto eff = Fixed64::fromFraction(1, 2);
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{1}, kBallAtOrigin, /*wants=*/true, &p,
                 eff,
                 /*new_velocity=*/Vec3{Fixed64::fromInt(3),
                                       Fixed64::zero(), Fixed64::zero()},
                 /*heading=*/Fixed64::zero()),
    };
    const auto r = resolveBallControl(std::nullopt, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());

    // Direction preserved (east), magnitude clamped to 1 m/s.
    FH_EXPECT_EQ(r.owner_capped_velocity.x, Fixed64::one());
    FH_EXPECT_EQ(r.owner_capped_velocity.y, Fixed64::zero());
    FH_EXPECT_EQ(r.owner_capped_velocity.z, Fixed64::zero());
    // Ball velocity == owner capped velocity (moves as one).
    FH_EXPECT_EQ(r.ball_target_velocity.x, Fixed64::one());
    FH_EXPECT_EQ(r.ball_target_velocity.y, Fixed64::zero());
}

FH_TEST(owned_velocity_not_capped_when_under_limit) {
    // walk = 2 m/s, efficiency = 1.0 → cap = 2 m/s.
    // Owner intended 1 m/s → passes through unchanged.
    const auto p = makeParams(Fixed64::fromInt(2));
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{1}, kBallAtOrigin, /*wants=*/true, &p,
                 /*eff=*/Fixed64::one(),
                 /*new_velocity=*/Vec3{Fixed64::one(),
                                       Fixed64::zero(), Fixed64::zero()}),
    };
    const auto r = resolveBallControl(std::nullopt, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(r.owner_capped_velocity.x, Fixed64::one());
}

FH_TEST(owned_zero_efficiency_freezes_owner) {
    // Pathological but well-defined: dribble_efficiency = 0 caps
    // walk speed to zero → the owner cannot move while dribbling.
    // This is what an eventual "totally exhausted" or "shackled"
    // debuff would produce. Locks the behaviour so nobody flips
    // the guard to "cap = max(cap, epsilon)" by accident.
    const auto p = makeParams(Fixed64::fromInt(2));
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{1}, kBallAtOrigin, /*wants=*/true, &p,
                 /*eff=*/Fixed64::zero(),
                 /*new_velocity=*/Vec3{Fixed64::fromInt(3),
                                       Fixed64::zero(), Fixed64::zero()}),
    };
    const auto r = resolveBallControl(std::nullopt, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(r.owner_capped_velocity.x, Fixed64::zero());
    FH_EXPECT_EQ(r.owner_capped_velocity.y, Fixed64::zero());
}

FH_TEST(glue_position_is_owner_plus_heading_offset) {
    // Owner at origin, heading east (0 rad) → glue point is at
    // (kBallOwnerLeadDistance, 0, 0). Uses the same fx_cos/fx_sin
    // path as the mechanic so the test doesn't recompute the offset
    // by hand — this asserts the CONTRACT (offset lives on the heading
    // ray at the lead distance), not a hard-coded coordinate.
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{1}, kBallAtOrigin, /*wants=*/true, &p,
                 /*eff=*/Fixed64::one(),
                 /*new_velocity=*/Vec3{},
                 /*heading=*/Fixed64::zero()),
    };
    const auto r = resolveBallControl(std::nullopt, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());

    const Fixed64 ex = fx_cos(Fixed64::zero()) * kBallOwnerLeadDistance;
    const Fixed64 ey = fx_sin(Fixed64::zero()) * kBallOwnerLeadDistance;
    FH_EXPECT_EQ(r.ball_target_position.x, ex);
    FH_EXPECT_EQ(r.ball_target_position.y, ey);
}

FH_TEST(glue_position_respects_owner_heading) {
    // Owner at (5, 5, 0), heading π/2 rad (north) → glue point at
    // (5, 5 + kBallOwnerLeadDistance, 0) up to Fixed64 rounding on
    // sin/cos LUT — comparison uses the same LUT so exact match holds.
    const auto p = makeParams();
    const Vec3 owner_pos{Fixed64::fromInt(5), Fixed64::fromInt(5),
                         Fixed64::zero()};
    const Fixed64 h = fh::sim::math::FX_PI * Fixed64::fromFraction(1, 2);

    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{1}, owner_pos, /*wants=*/true, &p,
                 /*eff=*/Fixed64::one(),
                 /*new_velocity=*/Vec3{},
                 /*heading=*/h),
    };
    // Ball must be within control radius of owner — put it right at
    // the owner's feet so Rule 1 fires.
    const auto r = resolveBallControl(std::nullopt, owner_pos,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());

    const Fixed64 ex = owner_pos.x + fx_cos(h) * kBallOwnerLeadDistance;
    const Fixed64 ey = owner_pos.y + fx_sin(h) * kBallOwnerLeadDistance;
    FH_EXPECT_EQ(r.ball_target_position.x, ex);
    FH_EXPECT_EQ(r.ball_target_position.y, ey);
    FH_EXPECT_EQ(r.ball_target_position.z, owner_pos.z);
}

FH_TEST_MAIN()
