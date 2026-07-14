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
// The cap magnitude is `max_walk_speed * dribble_efficiency`.
void fillOwnedFields(BallControlResult&       res,
                     const BallControlSlot&   owner_slot) noexcept
{
    // Guard: params should never be null if Match populated inputs
    // correctly, but if it is, fall back to leaving velocity uncapped
    // rather than crashing — a stray zero-vector cap would freeze the
    // owner mid-dribble. `Fixed64::zero()` as fallback max_speed makes
    // clampSpeedXY return zero, which is defensive but visible in
    // tests if we ever regress.
    const Fixed64 walk_cap = (owner_slot.params != nullptr)
        ? owner_slot.params->max_walk_speed
        : Fixed64::zero();
    const Fixed64 dribble_cap = walk_cap * owner_slot.dribble_efficiency;

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

    // --- Rule 2: owner retention -------------------------------------
    // Try to keep the current owner if they still qualify. This runs
    // FIRST so that a slight tie in distance-sq between the retained
    // owner and a fresh candidate goes to the owner — natural "sticky"
    // possession that avoids per-tick owner flip-flop.
    if (current_owner.has_value()) {
        const BallControlSlot* prev = findSlot(slots, n_slots, *current_owner);
        if (prev != nullptr
            && prev->wants_dribble
            && distSqXY(prev->position, ball_position) <= radius_sq)
        {
            res.owner = prev->slot_id;
            fillOwnedFields(res, *prev);
            return res;
        }
        // Fall through: current owner released the ball or moved out
        // of range. Ball becomes loose UNLESS Rule 1 finds a new
        // taker this same tick (instant hand-off).
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
