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

#include <cstdint>
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
    // Slice 25.2: ball-carry speeds. Default max_dribble_speed to
    // max_walk_speed so the pre-Slice-25.2 tests below (which set
    // efficiency and observe `walk × efficiency`) continue to observe
    // the exact same numbers — they now describe "dribble × efficiency"
    // where dribble == walk, but the arithmetic is identical.
    // max_carry_sprint_speed is set higher so the new sprint-with-ball
    // test can distinguish the two branches.
    p.max_dribble_speed      = max_walk_speed;                // 2 m/s default
    p.max_carry_sprint_speed = Fixed64::fromInt(3);           // 3 m/s
    return p;
}

// Compact BallControlSlot factory. `dribble_efficiency` defaults to 1.0
// so tests that don't care about the cap still get well-behaved motion
// (velocity magnitude preserved). Slice 25.2: `wants_sprint` defaults
// to false (dribble cap branch); tests that want to exercise the
// carry-sprint branch pass wants_sprint=true explicitly.
BallControlSlot makeSlot(SlotId                slot,
                         Vec3                  position,
                         bool                  wants_dribble,
                         const MechanicsParams* params,
                         Fixed64               dribble_efficiency = Fixed64::one(),
                         Vec3                  new_velocity = Vec3{},
                         Fixed64               heading      = Fixed64::zero(),
                         bool                  wants_sprint = false,
                         bool                  wants_to_press = false,
                         Fixed64               press_resistance = Fixed64::zero())
{
    BallControlSlot s;
    s.slot_id            = slot;
    s.position           = position;
    s.new_velocity       = new_velocity;
    s.heading            = heading;
    s.wants_dribble      = wants_dribble;
    s.wants_sprint       = wants_sprint;
    s.wants_to_press     = wants_to_press;
    s.dribble_efficiency = dribble_efficiency;
    s.press_resistance   = press_resistance;
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
FH_TEST(owned_velocity_capped_to_dribble_speed_times_efficiency) {
    // Slice 25.2: cap formula = max_dribble_speed × dribble_efficiency.
    // makeParams sets max_dribble_speed = max_walk_speed = 2 m/s.
    // efficiency = 0.5 → cap = 1 m/s.
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
    // Slice 25.2: cap = max_dribble_speed × efficiency = 2 × 1.0 = 2 m/s.
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

// Slice 25.2: sprint-with-ball uses max_carry_sprint_speed (not
// max_dribble_speed) as the base speed cap. Locks the branch on
// BallControlSlot::wants_sprint so a future refactor can't silently
// collapse the two branches back into one.
FH_TEST(owned_velocity_uses_carry_sprint_cap_when_wants_sprint) {
    // makeParams sets max_dribble_speed = 2, max_carry_sprint_speed = 3.
    // efficiency = 1.0 → dribble_cap = 2 m/s, sprint_cap = 3 m/s.
    // Owner intended 5 m/s east.
    // With wants_sprint = false → clamped to 2 m/s (dribble branch).
    // With wants_sprint = true  → clamped to 3 m/s (sprint branch).
    const auto p = makeParams(Fixed64::fromInt(2));

    // Dribble branch: capped to 2.
    {
        std::vector<BallControlSlot> slots{
            makeSlot(SlotId{1}, kBallAtOrigin, /*wants_dribble=*/true, &p,
                     /*eff=*/Fixed64::one(),
                     /*new_velocity=*/Vec3{Fixed64::fromInt(5),
                                           Fixed64::zero(), Fixed64::zero()},
                     /*heading=*/Fixed64::zero(),
                     /*wants_sprint=*/false),
        };
        const auto r = resolveBallControl(std::nullopt, kBallAtOrigin,
                                          slots.data(), slots.size());
        FH_EXPECT(r.owner.has_value());
        FH_EXPECT_EQ(r.owner_capped_velocity.x, Fixed64::fromInt(2));
        FH_EXPECT_EQ(r.owner_capped_velocity.y, Fixed64::zero());
    }

    // Sprint-with-ball branch: capped to 3.
    {
        std::vector<BallControlSlot> slots{
            makeSlot(SlotId{1}, kBallAtOrigin, /*wants_dribble=*/true, &p,
                     /*eff=*/Fixed64::one(),
                     /*new_velocity=*/Vec3{Fixed64::fromInt(5),
                                           Fixed64::zero(), Fixed64::zero()},
                     /*heading=*/Fixed64::zero(),
                     /*wants_sprint=*/true),
        };
        const auto r = resolveBallControl(std::nullopt, kBallAtOrigin,
                                          slots.data(), slots.size());
        FH_EXPECT(r.owner.has_value());
        FH_EXPECT_EQ(r.owner_capped_velocity.x, Fixed64::fromInt(3));
        FH_EXPECT_EQ(r.owner_capped_velocity.y, Fixed64::zero());
    }
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

// ===========================================================================
// Slice 24.3b — contest step (pressure-shrunken retention radius)
// ===========================================================================
//
// A NON-owner slot that asserts `wants_to_press` and is within
// kContestRadius of the ball shrinks the current owner's effective
// retention radius. Below a shrink threshold, Rule 2 fails naturally
// and the ball goes loose — no dedicated strip opcode.
//
// Helper: put the owner at the origin and the ball at the standard
// glue offset (kBallOwnerLeadDistance = 0.4 m east). Rule 2 uses
// player-to-ball distance (0.4 m); default kBallControlRadius = 0.5 m
// leaves 0.1 m of retention slack, which the contest step chips away.
namespace {

const Fixed64 kGlueOffset = kBallOwnerLeadDistance;
const Vec3    kOwnerAtOrigin{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()};
const Vec3    kBallAtGlue{kGlueOffset, Fixed64::zero(), Fixed64::zero()};

} // namespace

// Presser NOT asserting wants_to_press → no contest, owner retained
// even with high press_resistance rating. Proves the bit is what
// gates the mechanic, not just proximity.
FH_TEST(contest_no_press_bit_no_effect) {
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{1}, kOwnerAtOrigin, /*wants=*/true, &p,
                 /*eff=*/Fixed64::fromFraction(85, 100)),
        // Defender: high press_resistance but wants_to_press = false.
        makeSlot(SlotId{2},
                 Vec3{kGlueOffset, Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/false, &p,
                 /*eff=*/Fixed64::zero(),
                 /*new_velocity=*/Vec3{},
                 /*heading=*/Fixed64::zero(),
                 /*wants_sprint=*/false,
                 /*wants_to_press=*/false,
                 /*press_resistance=*/Fixed64::fromFraction(99, 100)),
    };
    const auto r = resolveBallControl(SlotId{1}, kBallAtGlue,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{1});
}

// Presser asserts wants_to_press but is OUTSIDE kContestRadius → no
// contest. Confirms proximity is a hard gate.
FH_TEST(contest_presser_outside_contest_radius_no_effect) {
    const auto p = makeParams();
    // Contest radius = 0.7 m; place defender 1.0 m north of the ball.
    const Vec3 defender_pos{kGlueOffset, Fixed64::fromInt(1), Fixed64::zero()};
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{1}, kOwnerAtOrigin, /*wants=*/true, &p,
                 /*eff=*/Fixed64::fromFraction(85, 100)),
        makeSlot(SlotId{2}, defender_pos,
                 /*wants=*/false, &p,
                 /*eff=*/Fixed64::zero(),
                 /*new_velocity=*/Vec3{},
                 /*heading=*/Fixed64::zero(),
                 /*wants_sprint=*/false,
                 /*wants_to_press=*/true,
                 /*press_resistance=*/Fixed64::fromFraction(99, 100)),
    };
    const auto r = resolveBallControl(SlotId{1}, kBallAtGlue,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{1});
}

// Presser in range but WEAKER than the attacker (skill_delta clamped
// to zero) → only the baseline penalty applies:
//   effective_radius = 0.5 - 0.10 = 0.40 m
// Ball at 0.4 m ⇒ distance ≤ 0.40 m ⇒ retention holds on the knife
// edge. Confirms baseline-only pressure does NOT strip a defensible
// dribbler.
FH_TEST(contest_weak_presser_baseline_penalty_owner_retains) {
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{1}, kOwnerAtOrigin, /*wants=*/true, &p,
                 /*eff=*/Fixed64::fromFraction(85, 100)),
        makeSlot(SlotId{2},
                 Vec3{kGlueOffset, Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/false, &p,
                 /*eff=*/Fixed64::zero(),
                 /*new_velocity=*/Vec3{},
                 /*heading=*/Fixed64::zero(),
                 /*wants_sprint=*/false,
                 /*wants_to_press=*/true,
                 /*press_resistance=*/Fixed64::fromFraction(75, 100)),
    };
    const auto r = resolveBallControl(SlotId{1}, kBallAtGlue,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{1});
}

// Presser in range AND stronger than attacker → skill_delta = 0.10,
// effective_radius = 0.5 - 0.10 - 0.5*0.10 = 0.35 m. Ball at 0.4 m ⇒
// distance > radius ⇒ Rule 2 fails. The presser sits AT the ball
// (distance = 0) and asserts wants_dribble, so Rule 1 hands ownership
// to them in the same tick. This is the "touch-to-steal" moment the
// slice ships: strip = Rule-2-fails + Rule-1-picks-presser, no
// dedicated opcode.
FH_TEST(contest_strong_presser_strips_ball) {
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{1}, kOwnerAtOrigin, /*wants=*/true, &p,
                 /*eff=*/Fixed64::fromFraction(85, 100)),
        makeSlot(SlotId{2},
                 Vec3{kGlueOffset, Fixed64::zero(), Fixed64::zero()},
                 // Presser asserts wants_dribble so it's a Rule 1
                 // candidate when Rule 2 fails. This mirrors what
                 // DefenderController does in production.
                 /*wants=*/true, &p,
                 /*eff=*/Fixed64::zero(),
                 /*new_velocity=*/Vec3{},
                 /*heading=*/Fixed64::zero(),
                 /*wants_sprint=*/false,
                 /*wants_to_press=*/true,
                 /*press_resistance=*/Fixed64::fromFraction(95, 100)),
    };
    const auto r = resolveBallControl(SlotId{1}, kBallAtGlue,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{2});
}

// Strong presser in contest range but presser does NOT assert
// wants_dribble → Rule 2 fails, Rule 1 also finds no closer taker
// (only the ex-owner at 0.4 m is a wants_dribble candidate, and
// they win by being the only one). This documents the corner case:
// pressure alone without an intent-to-take does not divorce the ball
// from the ex-owner — a real defender must want the ball, not just
// harass. DefenderController asserts both bits; this test guards
// against a future AI that separates them.
FH_TEST(contest_strong_presser_without_dribble_intent_owner_reclaims) {
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{1}, kOwnerAtOrigin, /*wants=*/true, &p,
                 /*eff=*/Fixed64::fromFraction(85, 100)),
        makeSlot(SlotId{2},
                 Vec3{kGlueOffset, Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/false, &p,          // no wants_dribble
                 /*eff=*/Fixed64::zero(),
                 /*new_velocity=*/Vec3{},
                 /*heading=*/Fixed64::zero(),
                 /*wants_sprint=*/false,
                 /*wants_to_press=*/true,
                 /*press_resistance=*/Fixed64::fromFraction(95, 100)),
    };
    const auto r = resolveBallControl(SlotId{1}, kBallAtGlue,
                                      slots.data(), slots.size());
    // Rule 2 fails (pressure shrinks radius below 0.4 m), Rule 1
    // sees only the ex-owner at 0.4 m ≤ kBallControlRadius 0.5 m
    // with wants_dribble = true → they re-claim it.
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{1});
}

// No current owner → contest step is a no-op even when a wants_to_press
// slot is right next to the ball. The Rule 1 first-touch scan runs
// against the FULL kBallControlRadius exactly as in Slice 16.3.
FH_TEST(contest_no_owner_no_shrink_rule1_full_radius) {
    const auto p = makeParams();
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{1},
                 // Slot 1 wants the ball and is at 0.45 m — INSIDE the
                 // full 0.5 m Rule-1 radius, OUTSIDE the shrunken 0.35 m
                 // Rule-2 radius that would apply if there were an owner.
                 Vec3{Fixed64::fromFraction(45, 100),
                      Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/true, &p,
                 /*eff=*/Fixed64::fromFraction(85, 100)),
        makeSlot(SlotId{2},
                 Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
                 /*wants=*/false, &p,
                 /*eff=*/Fixed64::zero(),
                 /*new_velocity=*/Vec3{},
                 /*heading=*/Fixed64::zero(),
                 /*wants_sprint=*/false,
                 /*wants_to_press=*/true,
                 /*press_resistance=*/Fixed64::fromFraction(95, 100)),
    };
    const auto r = resolveBallControl(std::nullopt, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{1});
}

// Two pressers, only the CLOSER one matters. Verifies the O(n)
// scan picks the closest by (distance², slot_id) — the tie-break
// convention is the same as Rule 1.
FH_TEST(contest_closest_presser_wins) {
    const auto p = makeParams();
    // Far presser: much stronger (would strip if selected). At 0.65 m
    // north of the ball — inside kContestRadius but farther than the
    // near presser.
    const Vec3 far_pos{kGlueOffset,
                       Fixed64::fromFraction(65, 100),
                       Fixed64::zero()};
    // Near presser: weaker (would NOT strip). At 0.05 m south of the
    // ball.
    const Vec3 near_pos{kGlueOffset,
                        -Fixed64::fromFraction(5, 100),
                        Fixed64::zero()};
    std::vector<BallControlSlot> slots{
        makeSlot(SlotId{1}, kOwnerAtOrigin, /*wants=*/true, &p,
                 /*eff=*/Fixed64::fromFraction(85, 100)),
        makeSlot(SlotId{2}, far_pos,
                 /*wants=*/false, &p,
                 /*eff=*/Fixed64::zero(),
                 /*new_velocity=*/Vec3{},
                 /*heading=*/Fixed64::zero(),
                 /*wants_sprint=*/false,
                 /*wants_to_press=*/true,
                 /*press_resistance=*/Fixed64::fromFraction(99, 100)),
        makeSlot(SlotId{3}, near_pos,
                 /*wants=*/false, &p,
                 /*eff=*/Fixed64::zero(),
                 /*new_velocity=*/Vec3{},
                 /*heading=*/Fixed64::zero(),
                 /*wants_sprint=*/false,
                 /*wants_to_press=*/true,
                 /*press_resistance=*/Fixed64::fromFraction(75, 100)),
    };
    const auto r = resolveBallControl(SlotId{1}, kBallAtGlue,
                                      slots.data(), slots.size());
    // Closer presser (slot 3, resistance 0.75) is selected. It's
    // weaker than the attacker (eff 0.85) so only the baseline
    // penalty applies (0.5 - 0.10 = 0.40 m) — retention holds. The
    // stronger far presser is ignored precisely because it's farther.
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{1});
}

// ---------------------------------------------------------------------------
// Slice 26.3 (ADR §22.23) — release-on-kick coverage.
// ---------------------------------------------------------------------------

namespace {

// Extended slot factory that also populates the Slice 26.3 kick
// fields. Keeps the pre-26.3 makeSlot() call sites untouched so no
// existing test needs to be edited.
BallControlSlot makeKickerSlot(SlotId                 slot,
                               Vec3                   position,
                               bool                   wants_dribble,
                               const MechanicsParams* params,
                               bool                   wants_kick,
                               Vec3                   kick_direction,
                               Fixed64                pass_power,
                               std::uint16_t          kick_power_hint = 0)
{
    BallControlSlot s;
    s.slot_id            = slot;
    s.position           = position;
    s.new_velocity       = Vec3{};
    s.heading            = Fixed64::zero();
    s.wants_dribble      = wants_dribble;
    s.wants_sprint       = false;
    s.wants_to_press     = false;
    s.dribble_efficiency = Fixed64::one();
    s.press_resistance   = Fixed64::zero();
    s.wants_kick         = wants_kick;
    s.kick_direction     = kick_direction;
    s.kick_power_hint    = kick_power_hint;
    s.pass_power         = pass_power;
    s.params             = params;
    return s;
}

} // namespace

// Owner asserting wants_kick this tick drops ownership AND emits a
// kick impulse in the result. Ball position is inside the retention
// radius so Rule 2 would otherwise retain — the kick branch takes
// precedence.
FH_TEST(owner_kick_releases_ownership_and_emits_impulse) {
    const auto p = makeParams();
    const std::vector<BallControlSlot> slots{
        makeKickerSlot(SlotId{1},
                       Vec3{Fixed64::fromFraction(1, 10),   // 0.1 m from ball
                            Fixed64::zero(),
                            Fixed64::zero()},
                       /*wants_dribble=*/true,
                       &p,
                       /*wants_kick=*/true,
                       Vec3{Fixed64::fromInt(1),
                            Fixed64::zero(),
                            Fixed64::zero()},   // +x unit direction
                       /*pass_power=*/Fixed64::fromInt(15)),
    };
    const auto r = resolveBallControl(SlotId{1}, kBallAtOrigin,
                                      slots.data(), slots.size());

    // Ownership dropped.
    FH_EXPECT(!r.owner.has_value());
    // Kick flag raised, direction passed through raw (BallPhysics
    // normalises inside applyImpulse), speed = pass_power since
    // kick_power_hint == 0.
    FH_EXPECT(r.kicked);
    FH_EXPECT_EQ(r.kick_direction.x, Fixed64::fromInt(1));
    FH_EXPECT_EQ(r.kick_direction.y, Fixed64::zero());
    FH_EXPECT_EQ(r.kick_speed, Fixed64::fromInt(15));
}

// kick_power_hint (u16 m/s) OVERRIDES pass_power when non-zero. The
// wire trailer's per-kick hint always wins if the client sent one.
FH_TEST(owner_kick_power_hint_overrides_pass_power) {
    const auto p = makeParams();
    const std::vector<BallControlSlot> slots{
        makeKickerSlot(SlotId{1},
                       Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
                       /*wants_dribble=*/true,
                       &p,
                       /*wants_kick=*/true,
                       Vec3{Fixed64::fromInt(1),
                            Fixed64::zero(),
                            Fixed64::zero()},
                       /*pass_power=*/Fixed64::fromInt(15),
                       /*kick_power_hint=*/8),   // override to 8 m/s
    };
    const auto r = resolveBallControl(SlotId{1}, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(r.kicked);
    FH_EXPECT_EQ(r.kick_speed, Fixed64::fromInt(8));
}

// Non-owner asserting wants_kick is IGNORED — you can't kick a ball
// you don't own. The current-owner slot doesn't want_kick, so Rule 2
// retains as normal. The other slot's wants_kick has no effect.
FH_TEST(non_owner_wants_kick_is_ignored) {
    const auto p = makeParams();
    const std::vector<BallControlSlot> slots{
        // Slot 1 is the current owner — near ball, wants dribble,
        // NOT wanting kick. Should retain.
        makeKickerSlot(SlotId{1},
                       Vec3{Fixed64::fromFraction(1, 10),
                            Fixed64::zero(),
                            Fixed64::zero()},
                       /*wants_dribble=*/true,
                       &p,
                       /*wants_kick=*/false,
                       Vec3{},
                       Fixed64::fromInt(15)),
        // Slot 2 asserts wants_kick without owning. Should be ignored.
        makeKickerSlot(SlotId{2},
                       Vec3{Fixed64::fromInt(3),    // 3 m away, out of range
                            Fixed64::zero(),
                            Fixed64::zero()},
                       /*wants_dribble=*/false,
                       &p,
                       /*wants_kick=*/true,
                       Vec3{Fixed64::fromInt(1),
                            Fixed64::zero(),
                            Fixed64::zero()},
                       Fixed64::fromInt(15)),
    };
    const auto r = resolveBallControl(SlotId{1}, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(r.owner.has_value());
    FH_EXPECT_EQ(*r.owner, SlotId{1});
    FH_EXPECT(!r.kicked);
}

// Kick suppresses Rule 1 first-touch pickup in the same tick — the
// ball just left the foot; a near-by slot cannot instantly re-grab.
// Slot 1 kicks; slot 2 sits close enough that Rule 1 would normally
// take. Result: ball is loose (owner=nullopt) AND no first-touch
// hand-off, only the kick.
FH_TEST(kick_suppresses_first_touch_in_same_tick) {
    const auto p = makeParams();
    const std::vector<BallControlSlot> slots{
        // Owner slot 1 kicking.
        makeKickerSlot(SlotId{1},
                       Vec3{Fixed64::fromFraction(1, 10),
                            Fixed64::zero(),
                            Fixed64::zero()},
                       /*wants_dribble=*/true,
                       &p,
                       /*wants_kick=*/true,
                       Vec3{Fixed64::fromInt(1),
                            Fixed64::zero(),
                            Fixed64::zero()},
                       Fixed64::fromInt(15)),
        // Slot 2 is IN range and wants dribble but is not the owner
        // — under Rule 1 this would be the next taker. Kick must
        // suppress that path.
        makeKickerSlot(SlotId{2},
                       Vec3{Fixed64::fromFraction(-1, 10),
                            Fixed64::zero(),
                            Fixed64::zero()},
                       /*wants_dribble=*/true,
                       &p,
                       /*wants_kick=*/false,
                       Vec3{},
                       Fixed64::fromInt(15)),
    };
    const auto r = resolveBallControl(SlotId{1}, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(!r.owner.has_value());
    FH_EXPECT(r.kicked);
}

// Owner asserting wants_kick but OUT OF RANGE doesn't kick — Rule 2
// retention fails on the range check, so the release-on-kick branch
// never runs. Ball simply becomes loose (as in Slice 16.3 baseline),
// no impulse emitted.
FH_TEST(owner_kick_out_of_range_does_not_fire) {
    const auto p = makeParams();
    const std::vector<BallControlSlot> slots{
        makeKickerSlot(SlotId{1},
                       Vec3{Fixed64::fromInt(2),    // 2 m from ball, out of range
                            Fixed64::zero(),
                            Fixed64::zero()},
                       /*wants_dribble=*/true,
                       &p,
                       /*wants_kick=*/true,
                       Vec3{Fixed64::fromInt(1),
                            Fixed64::zero(),
                            Fixed64::zero()},
                       Fixed64::fromInt(15)),
    };
    const auto r = resolveBallControl(SlotId{1}, kBallAtOrigin,
                                      slots.data(), slots.size());
    FH_EXPECT(!r.owner.has_value());
    FH_EXPECT(!r.kicked);
}

FH_TEST_MAIN()
