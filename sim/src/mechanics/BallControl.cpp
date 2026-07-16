// footballhome sim - BallControl implementation
//
// See BallControl.hpp for the rules + contract. This file implements
// pure arithmetic — no I/O, no allocation, no side effects.

#include "mechanics/BallControl.hpp"

#include "math/FixedMath.hpp"

namespace fh::sim::mechanics {

namespace {

using math::Fixed64;
using math::Vec3;

// Horizontal (XY) distance-squared between two 3D positions. Kept
// squared to avoid a sqrt in the hot path; kBallControlRadius is
// pre-squared at the caller for comparison.
Fixed64 distSqXY(const Vec3& a, const Vec3& b) noexcept
{
    const Fixed64 dx = a.x - b.x;
    const Fixed64 dy = a.y - b.y;
    return dx * dx + dy * dy;
}

// Return the slot pointer whose slot_id matches `id`, or nullptr. The
// slots array is small (< 32) and a linear scan is measurably faster
// than a map lookup for these sizes.
const BallControlSlot* findSlot(const BallControlSlot* slots,
                                std::size_t             n,
                                SlotId                  id) noexcept
{
    for (std::size_t i = 0; i < n; ++i) {
        if (slots[i].slot_id == id) { return &slots[i]; }
    }
    return nullptr;
}

// Cap the magnitude of `v` to `max_speed`. If |v| <= max_speed the
// vector is returned unchanged; otherwise it's scaled to length
// max_speed with direction preserved. Zero vectors pass through
// unchanged (avoids a divide-by-zero in normalize()).
Vec3 clampSpeedXY(const Vec3& v, Fixed64 max_speed) noexcept
{
    // Guard: max_speed <= 0 means "no motion allowed" — return zero.
    // Also serves as a safety net if a rogue profile sets
    // dribble_efficiency to 0 (or, hypothetically, negative). Slice
    // 16.3 leaves that a game-design decision for BallControl callers;
    // the mechanic just enforces the cap it's given.
    if (max_speed <= Fixed64::zero()) {
        return Vec3{};
    }
    const Fixed64 len = v.length();
    if (len <= max_speed) { return v; }
    // Scale by max_speed / len. len > 0 is guaranteed here (else the
    // `<= max_speed` branch would have taken 0 <= max_speed).
    const Vec3 unit = v.normalized();
    return Vec3{unit.x * max_speed, unit.y * max_speed, unit.z * max_speed};
}

// Compute the ball's target position: owner.position offset by
// kBallOwnerLeadDistance in the direction of owner.heading. Z is
// preserved from the owner (M1 ball is grounded — Z stays 0 in
// practice but we pass it through cleanly for M2+ aerial cases).
Vec3 computeGluePosition(const Vec3& owner_position, Fixed64 owner_heading) noexcept
{
    const Fixed64 dx = math::fx_cos(owner_heading) * kBallOwnerLeadDistance;
    const Fixed64 dy = math::fx_sin(owner_heading) * kBallOwnerLeadDistance;
    return Vec3{owner_position.x + dx, owner_position.y + dy, owner_position.z};
}

// Populate the {owner_capped_velocity, ball_target_velocity,
// ball_target_position} fields of `res` for a given chosen owner slot.
//
// Slice 25.2 cap formula (replaces the prior `walk × efficiency`):
//
//     base_speed  = wants_sprint ? max_carry_sprint_speed  // 6.0 m/s
//                                : max_dribble_speed;      // 4.0 m/s
//     dribble_cap = base_speed × dribble_efficiency;       // per-player
//                                                          // attenuation
//
// See sim/DESIGN.md §23.3 Slice 25.2 and
// database/migrations/209-sim-attr-carry-speeds.sql for the semantic
// contract. wants_sprint is only meaningful for the chosen OWNER; a
// non-owner's velocity is not touched here at all.
void fillOwnedFields(BallControlResult&       res,
                     const BallControlSlot&   owner_slot) noexcept
{
    // Guard: params should never be null if Match populated inputs
    // correctly, but if it is, fall back to a zero cap rather than
    // crashing — clampSpeedXY(v, 0) returns zero, which is visibly
    // wrong in tests if we ever regress.
    const Fixed64 base_speed = (owner_slot.params != nullptr)
        ? (owner_slot.wants_sprint
            ? owner_slot.params->max_carry_sprint_speed
            : owner_slot.params->max_dribble_speed)
        : Fixed64::zero();
    const Fixed64 dribble_cap = base_speed * owner_slot.dribble_efficiency;

    const Vec3 capped_v = clampSpeedXY(owner_slot.new_velocity, dribble_cap);
    res.owner_capped_velocity = capped_v;
    res.ball_target_velocity  = capped_v;    // ball moves with owner
    res.ball_target_position  = computeGluePosition(owner_slot.position,
                                                    owner_slot.heading);
}

} // namespace

BallControlResult resolveBallControl(std::optional<SlotId>          current_owner,
                                     const Vec3&                    ball_position,
                                     const BallControlSlot*         slots,
                                     std::size_t                    n_slots)
{
    BallControlResult res{};

    if (slots == nullptr || n_slots == 0) {
        // No slots this tick — ball can't be controlled. Loose.
        return res;
    }

    const Fixed64 radius_sq = kBallControlRadius * kBallControlRadius;

    // --- Slice 24.3b: contest step (compute effective retention radius) ----
    //
    // If we have a current owner AND any non-owner slot is asserting
    // wants_to_press within kContestRadius of the ball, the owner's
    // retention radius shrinks by a pressure penalty. When the shrunken
    // radius falls below the ball's actual distance-from-owner (~0.4 m
    // via kBallOwnerLeadDistance), the Rule 2 check below fails
    // naturally, ball becomes loose, and the standard Rule 1 first-
    // touch scramble decides the next owner — no explicit "strip"
    // opcode needed.
    //
    // Formula (see BallControl.hpp for the constant rationale):
    //
    //   skill_delta      = max(0, press_resistance - dribble_efficiency)
    //   effective_radius = max(kMinPressureRadius,
    //                          kBallControlRadius
    //                          - kPressBaselineCost
    //                          - kPressSkillDelta * skill_delta)
    //
    // Choosing the CLOSEST presser (not the strongest) keeps this
    // deterministic and O(n); if a designer wants "best of many
    // pressers" behaviour, that's a future refinement.
    //
    // If there is NO current owner, or the owner has no ball-side
    // presser this tick, effective_radius_sq == radius_sq and Rule 2
    // is byte-identical to Slice 16.3. Existing determinism goldens
    // (Dribble200, FirstTouch200, BallRoll400) never see a
    // wants_to_press assertion, so they are unaffected.
    Fixed64 effective_radius_sq = radius_sq;
    if (current_owner.has_value()) {
        const BallControlSlot* owner_slot =
            findSlot(slots, n_slots, *current_owner);
        if (owner_slot != nullptr) {
            const Fixed64 contest_radius_sq = kContestRadius * kContestRadius;
            const BallControlSlot* presser = nullptr;
            Fixed64 presser_dsq = Fixed64::zero();
            for (std::size_t i = 0; i < n_slots; ++i) {
                const BallControlSlot& s = slots[i];
                if (s.slot_id == *current_owner) { continue; }
                if (!s.wants_to_press)           { continue; }
                const Fixed64 dsq = distSqXY(s.position, ball_position);
                if (dsq > contest_radius_sq)     { continue; }
                if (presser == nullptr
                    || dsq < presser_dsq
                    || (dsq == presser_dsq && s.slot_id < presser->slot_id))
                {
                    presser     = &s;
                    presser_dsq = dsq;
                }
            }
            if (presser != nullptr) {
                Fixed64 skill_delta =
                    presser->press_resistance - owner_slot->dribble_efficiency;
                if (skill_delta < Fixed64::zero()) {
                    skill_delta = Fixed64::zero();
                }
                Fixed64 effective_radius =
                    kBallControlRadius
                    - kPressBaselineCost
                    - kPressSkillDelta * skill_delta;
                if (effective_radius < kMinPressureRadius) {
                    effective_radius = kMinPressureRadius;
                }
                effective_radius_sq = effective_radius * effective_radius;
            }
        }
    }

    // --- Rule 2: owner retention -------------------------------------
    // Try to keep the current owner if they still qualify. This runs
    // FIRST so that a slight tie in distance-sq between the retained
    // owner and a fresh candidate goes to the owner — natural "sticky"
    // possession that avoids per-tick owner flip-flop.
    if (current_owner.has_value()) {
        const BallControlSlot* prev = findSlot(slots, n_slots, *current_owner);
        if (prev != nullptr
            && prev->wants_dribble
            && distSqXY(prev->position, ball_position) <= effective_radius_sq)
        {
            // Slice 26.3: release-on-kick. A retained owner asserting
            // wants_kick drops the ball this tick AND emits a kick
            // impulse in the result. Rule 1 does NOT run below — the
            // ball just left the foot and any near-by slot would
            // otherwise instantly re-grab it (auto-dribble hint fires
            // within kBallAutoDribbleRadius, wider than
            // kBallControlRadius). Returning early enforces
            // "kicker cannot re-claim in the same tick".
            if (prev->wants_kick) {
                res.owner  = std::nullopt;
                res.kicked = true;
                res.kick_direction = prev->kick_direction;
                // kick_power_hint (u16 m/s) overrides the profile's
                // pass_power when non-zero. Slice 26.2 wire decoder
                // guarantees the hint is a plausible u16; a client
                // sending an unrealistic value gets an unrealistic
                // kick but nothing crashes.
                res.kick_speed = (prev->kick_power_hint > 0)
                    ? Fixed64::fromInt(
                        static_cast<std::int32_t>(prev->kick_power_hint))
                    : prev->pass_power;
                return res;
            }
            res.owner = prev->slot_id;
            fillOwnedFields(res, *prev);
            return res;
        }
        // Fall through: current owner released the ball or moved out
        // of range (Slice 16.3) or was pressed off it (Slice 24.3b).
        // Ball becomes loose UNLESS Rule 1 finds a new taker this
        // same tick (instant hand-off).
    }

    // --- Rule 1: first-touch pickup ----------------------------------
    // Scan all slots, pick the closest qualifying one. Ties are broken
    // by lower SlotId. We DON'T sort — a single linear scan tracking
    // the best-so-far is cheaper and clearer for these sizes.
    const BallControlSlot* best      = nullptr;
    Fixed64                best_dsq  = Fixed64::zero();   // meaningful only when best != nullptr
    for (std::size_t i = 0; i < n_slots; ++i) {
        const BallControlSlot& s = slots[i];
        if (!s.wants_dribble) { continue; }
        const Fixed64 dsq = distSqXY(s.position, ball_position);
        if (dsq > radius_sq) { continue; }
        if (best == nullptr
            || dsq < best_dsq
            || (dsq == best_dsq && s.slot_id < best->slot_id))
        {
            best     = &s;
            best_dsq = dsq;
        }
    }

    if (best != nullptr) {
        res.owner = best->slot_id;
        fillOwnedFields(res, *best);
    }
    return res;
}

} // namespace fh::sim::mechanics
