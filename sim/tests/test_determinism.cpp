// footballhome sim - Cross-platform determinism test
//
// Runs a fixed-config match for N ticks with a fixed seed and dumps a
// canonical byte-form of the final snapshot. Two things happen:
//
//   1. The dump is FNV-1a-64 hashed and asserted equal to a golden hash.
//      This makes the test self-contained on every host — any drift in
//      Fixed64 math, in tick-loop ordering, or in RNG advancement will
//      change the hash immediately.
//
//   2. The dump itself is also written to stdout so a cross-arch script
//      (sim/scripts/check_determinism_cross_arch.sh) can diff the output
//      between amd64 and arm64 runs. Byte-identical stdout = deterministic
//      across platforms.
//
// If the golden hash needs to be updated (only when we intentionally change
// the model), run the test, copy the "actual hash" printed on failure into
// kExpectedHash below, and commit both changes together in the same PR.
//
// Design ref: DESIGN.md §16.1 (Determinism CI), §9 (bit-exact determinism).

#include "match/CanonicalHash.hpp"
#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "match/Snapshot.hpp"
#include "physics/BasicPhysics.hpp"
#include "physics/StubPhysics.hpp"
#include "common/M0Registry.generated.hpp"
#include "scenario/BallOnPitchScenario.hpp"
#include "scenario/BallOnPitchWithDefenderScenario.hpp"
#include "scenario/EmptyPitchScenario.hpp"
#include "scenario/GoalDrillScenario.hpp"
#include "scenario/HalfPitchScenario.hpp"
#include "scenario/SoftDrillScenario.hpp"
#include "scenario/Scenario.hpp"
#include "controller/Intent.hpp"
#include "common/M0Attributes.hpp"
#include "math/Fixed64.hpp"
#include "math/FixedMath.hpp"
#include "persistence/EventTypes.hpp"
#include "profile/PlayerProfile.hpp"
#include "test_harness.hpp"

#include <cstdint>
#include <cstdio>
#include <memory>
#include <optional>
#include <string>
#include <vector>

using fh::sim::ClientId;
using fh::sim::PersonId;
using fh::sim::SlotId;
using fh::sim::controller::Intent;
using fh::sim::match::canonicalDump;
using fh::sim::match::fnv1a64;
using fh::sim::match::Match;
using fh::sim::match::MatchConfig;
using fh::sim::match::RealtimeClock;
using fh::sim::match::Snapshot;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::physics::BasicPhysics;
using fh::sim::physics::StubPhysics;
using fh::sim::scenario::BallOnPitchScenario;
using fh::sim::scenario::BallSpawn;
using fh::sim::scenario::EmptyPitchScenario;
using fh::sim::scenario::HalfPitchScenario;
using fh::sim::scenario::SoftDrillScenario;

namespace {

// Slice 16.6: test-only scenario with BOTH a ball AND up to two claimable
// slots. Real production scenarios (Slice 16.5+ demos, M2 match modes)
// will grow their own SlotSpawns; for the cross-arch determinism golden
// we want a minimal, stable layout that never changes.
class BallAndTwoSlotsScenario : public fh::sim::scenario::Scenario {
public:
    BallAndTwoSlotsScenario(BallSpawn ball,
                            std::vector<fh::sim::scenario::SlotSpawn> slots)
        : ball_(ball), slots_(std::move(slots))
    {
        pitch_.length_m = Fixed64::fromInt(105);
        pitch_.width_m  = Fixed64::fromInt(68);
    }

    std::string  id() const override          { return "test_ball_and_slots"; }
    std::string  displayName() const override { return "Test — ball + slots"; }
    fh::sim::scenario::PitchSpec    pitch() const override        { return pitch_; }
    fh::sim::scenario::PlayableArea playableArea() const override { return {}; }
    std::vector<fh::sim::scenario::SlotSpawn> initialSpawns() const override
        { return slots_; }
    std::optional<BallSpawn> ballSpawn() const override { return ball_; }
    bool checkSuccess(const fh::sim::awareness::WorldView& w) const override
        { (void)w; return false; }
    bool checkReset(const fh::sim::awareness::WorldView& w) const override
        { (void)w; return false; }
    std::vector<std::string> hints() const override { return {}; }

private:
    fh::sim::scenario::PitchSpec pitch_;
    BallSpawn ball_;
    std::vector<fh::sim::scenario::SlotSpawn> slots_;
};

// Slice 31.5: test-only fixture for the first JockeyBehavior determinism
// golden. Slot 1 is human-claimed and dribbles laterally; slot 2 is an LCB
// Defender-kind AI with only `jockey` plugged, so the defender behavior bag
// selects JockeyBehavior rather than the higher-utility pursue behavior.
class JockeyVsLateralDribblerScenario : public fh::sim::scenario::Scenario {
public:
    JockeyVsLateralDribblerScenario()
    {
        pitch_.length_m = Fixed64::fromInt(105);
        pitch_.width_m  = Fixed64::fromInt(68);

        ball_.position = Vec3{Fixed64::fromFraction(-47, 10),
                              Fixed64::zero(),
                              Fixed64::zero()};
        ball_.velocity = Vec3{};

        fh::sim::scenario::SlotSpawn attacker;
        attacker.slot     = SlotId{1};
        attacker.position = Vec3{Fixed64::fromInt(-5),
                                 Fixed64::zero(),
                                 Fixed64::zero()};
        attacker.heading  = Fixed64::zero();
        attacker.role     = fh::sim::Role::Any;
        slots_.push_back(attacker);

        fh::sim::scenario::SlotSpawn defender;
        defender.slot     = SlotId{2};
        defender.position = Vec3{Fixed64::fromInt(-5),
                                 Fixed64::fromInt(-4),
                                 Fixed64::zero()};
        defender.heading  = fh::sim::math::FX_PI;
        defender.role     = fh::sim::Role::LCB;
        slots_.push_back(defender);
    }

    std::string id() const override { return "test_jockey_lateral_dribbler"; }
    std::string displayName() const override { return "Test — jockey lateral dribbler"; }
    fh::sim::scenario::PitchSpec pitch() const override { return pitch_; }
    fh::sim::scenario::PlayableArea playableArea() const override { return {}; }
    std::vector<fh::sim::scenario::SlotSpawn> initialSpawns() const override { return slots_; }
    std::optional<BallSpawn> ballSpawn() const override { return ball_; }
    bool checkSuccess(const fh::sim::awareness::WorldView& w) const override { (void)w; return false; }
    bool checkReset(const fh::sim::awareness::WorldView& w) const override { (void)w; return false; }
    std::vector<std::string> hints() const override { return {}; }

    fh::sim::scenario::UnclaimedControllerKind unclaimedControllerFor(SlotId slot) const override
    {
        return (slot == SlotId{2})
            ? fh::sim::scenario::UnclaimedControllerKind::Defender
            : fh::sim::scenario::UnclaimedControllerKind::Idle;
    }

    void applyConceptOverrides(SlotId slot,
                               fh::sim::profile::ConceptSet& concepts) const override
    {
        if (slot == SlotId{2}) {
            concepts.plug(fh::sim::m0::kJockey, Fixed64::one());
        }
    }

private:
    fh::sim::scenario::PitchSpec pitch_;
    BallSpawn ball_;
    std::vector<fh::sim::scenario::SlotSpawn> slots_;
};

// Slice 31.5: test-only fixture for the first MarkOpponentBehavior
// determinism golden. Slot 1 is a stationary unclaimed target; slot 2 is
// an LCB Defender-kind AI with only `marking` plugged and mark_target set
// to SlotId{1}, so the defender behavior bag selects MarkOpponentBehavior.
class MarkStationaryTargetScenario : public fh::sim::scenario::Scenario {
public:
    MarkStationaryTargetScenario()
    {
        pitch_.length_m = Fixed64::fromInt(105);
        pitch_.width_m  = Fixed64::fromInt(68);

        fh::sim::scenario::SlotSpawn target;
        target.slot     = SlotId{1};
        target.position = Vec3{Fixed64::fromInt(5),
                               Fixed64::zero(),
                               Fixed64::zero()};
        target.heading  = fh::sim::math::FX_PI;
        target.role     = fh::sim::Role::Any;
        slots_.push_back(target);

        fh::sim::scenario::SlotSpawn marker;
        marker.slot        = SlotId{2};
        marker.position    = Vec3{Fixed64::zero(),
                                  Fixed64::zero(),
                                  Fixed64::zero()};
        marker.heading     = Fixed64::zero();
        marker.role        = fh::sim::Role::LCB;
        marker.mark_target = SlotId{1};
        slots_.push_back(marker);
    }

    std::string id() const override { return "test_mark_stationary_target"; }
    std::string displayName() const override { return "Test — mark stationary target"; }
    fh::sim::scenario::PitchSpec pitch() const override { return pitch_; }
    fh::sim::scenario::PlayableArea playableArea() const override { return {}; }
    std::vector<fh::sim::scenario::SlotSpawn> initialSpawns() const override { return slots_; }
    std::optional<BallSpawn> ballSpawn() const override { return std::nullopt; }
    bool checkSuccess(const fh::sim::awareness::WorldView& w) const override { (void)w; return false; }
    bool checkReset(const fh::sim::awareness::WorldView& w) const override { (void)w; return false; }
    std::vector<std::string> hints() const override { return {}; }

    fh::sim::scenario::UnclaimedControllerKind unclaimedControllerFor(SlotId slot) const override
    {
        return (slot == SlotId{2})
            ? fh::sim::scenario::UnclaimedControllerKind::Defender
            : fh::sim::scenario::UnclaimedControllerKind::Idle;
    }

    void applyConceptOverrides(SlotId slot,
                               fh::sim::profile::ConceptSet& concepts) const override
    {
        if (slot == SlotId{2}) {
            concepts.plug(fh::sim::m0::kMarking, Fixed64::one());
        }
    }

private:
    fh::sim::scenario::PitchSpec pitch_;
    std::vector<fh::sim::scenario::SlotSpawn> slots_;
};

std::unique_ptr<Match> makeMatch(std::uint64_t seed) {
    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = seed;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<EmptyPitchScenario>();
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    return std::make_unique<Match>(std::move(cfg));
}

// Slice 15.6: constructs a Match seeded to reproduce a scripted ball trajectory
// deterministically. The ball starts at the centre spot with the caller-supplied
// velocity and BallPhysics decays it every tick — canonical hash after N ticks
// is the cross-arch fingerprint we lock below.
std::unique_ptr<Match> makeBallMatch(std::uint64_t seed,
                                     Vec3 pos, Vec3 vel) {
    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = seed;
    cfg.physics  = std::make_unique<StubPhysics>();
    BallSpawn spawn{pos, vel};
    cfg.scenario = std::make_unique<BallOnPitchScenario>(spawn);
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    return std::make_unique<Match>(std::move(cfg));
}

// -----------------------------------------------------------------------
// Golden hash for the 200-tick "wander only" run with seed = 42.
// If the model changes intentionally, update this and re-hash.
// -----------------------------------------------------------------------
constexpr std::uint64_t kExpectedHashWander200 = 0x6884c4833f3bb725ULL;

// Golden hash for the 400-tick "one human sprints east" run with seed=42.
constexpr std::uint64_t kExpectedHashHumanSprint400 = 0xb71c450c79f4bb4fULL;

// Golden hash for the 400-tick "ball rolls east at 20 m/s, seed=42" run.
// Slice 15.6: BallOnPitchScenario spawns the ball with a scripted initial
// velocity; BallPhysics decays it every tick until it snaps to rest around
// tick ~376 (20 * 0.98^n <= 0.01). This hash locks the deterministic ball
// trajectory across amd64 / arm64. Final position ~48.68 m matches the
// closed-form geometric sum v*dt/(1-decay) = 20*0.05/0.02 = 50 m minus a
// small truncation at the rest-snap threshold.
constexpr std::uint64_t kExpectedHashBallRoll400 = 0x7c3932be60cba2aaULL;

// Slice 16.6: cross-arch golden for a human dribbling a stationary ball.
// One player claims SlotId{1}, walks east from origin with wants_dribble
// asserted; ball spawns 0.3 m east (inside kBallControlRadius = 0.5 m) so
// first-touch fires on tick 1. After that, BallControl glues the ball to
// owner.position + kBallOwnerLeadDistance*heading, caps the owner's
// velocity at max_dribble_speed*dribble_efficiency (Slice 25.2:
// replaces prior max_walk*efficiency), and skips BallPhysics for the
// ball. 200 ticks (10 s) exercises the glue + speed-cap paths.
constexpr std::uint64_t kExpectedHashDribble200 = 0x60781ccf7af63f70ULL;

// Slice 16.6: cross-arch golden for two humans racing to the same ball.
// Both slots start equidistant (SlotId{1} at x=-0.4, SlotId{2} at x=+0.4)
// from a ball at origin. Both assert wants_dribble. First-touch rule:
// closest wins → SlotId{1} and SlotId{2} tie on distance, so Rule 1's
// tie-breaker (lower SlotId) awards ownership to SlotId{1}. The losing
// slot's motion still gets recorded, so the hash locks BOTH ownership
// AND the tie-breaker rule.
constexpr std::uint64_t kExpectedHashFirstTouch200 = 0x589c246919c1ba82ULL;

// Slice 17.6: cross-arch golden for HalfPitchScenario in Hard mode.
// SlotId{1} spawns at (10, 0) (declared by the scenario) and gets
// claimed + fed a sprint-east intent. Around tick 25-30 (~1.5 s at
// 20 Hz) it reaches the east wall at x = 52.5 m; from then on the
// Hard clamp fires every tick, snapping x back to 52.5 and zeroing
// the outward +x velocity. 400 ticks (20 s) locks in the whole
// approach + long tail of "player pressed against the wall".
// SlotId{2} is unclaimed → WanderController → also exercises the
// boundary passively. Final snapshot shows slot 1 at exactly
// pos.x = 0x3480000000 raw = 52.5 m with vel.x = 0 — the fingerprint
// of apply_hard doing its job at the wall.
constexpr std::uint64_t kExpectedHashHalfPitchHard400 = 0x489acd31dddb4587ULL;

// Slice 17.6: cross-arch golden for SoftDrillScenario in Soft mode.
// SlotId{1} spawns at (0, 0) (drill-zone centre) and gets claimed +
// fed a sprint-east intent. Around tick 15-20 it crosses the +20
// boundary. From then on Soft pushback adds an inward-facing
// velocity delta = penetration × k (k = 4/s default in Match.cpp)
// which decelerates the sprint and eventually reverses it. 400
// ticks (20 s) captures the full leave-drift-return cycle. Locks
// apply_soft's Fixed64 math AND the k=4 default stiffness constant.
// Final snapshot shows slot 1 oscillating near x ≈ 18.96 m with
// vel.x ≈ 7.47 m/s east — mid-cycle, about to cross the boundary
// again.
constexpr std::uint64_t kExpectedHashSoftDrill400 = 0x700808840ecc3183ULL;

// Slice 24.3b: cross-arch determinism proof for BallOnPitchWithDefender
// scenario. SlotId{1} (west side, unclaimed → Idle) never moves; the
// ball sits at centre at rest. SlotId{2} (east side, DefenderController)
// jogs west toward the ball every tick, asserting wants_dribble +
// wants_to_press unconditionally. Reaches the ball around tick ~50
// (5 m / 4.5 m/s ≈ 1.1 s at 20 Hz), at which point it becomes the ball
// owner via Rule 1 first-touch (slot 1 Idle never contests).
//
// Once slot 2 owns the ball the DefenderController's hold-when-owner
// branch (Slice 24.3b bug fix, gated on view.ball_owner == self) kicks
// in: desired_direction becomes zero, wants_dribble stays true so Rule
// 2 retention keeps ownership sticky. Final snapshot shows slot 2
// parked ~0.5 m west of the ball's original centre position with the
// ball glued 0.4 m further west (kBallOwnerLeadDistance ahead of the
// defender's heading).
//
// 400 ticks (20 s) covers the full approach + steady-state hold.
// Any Fixed64 drift in DefenderController::decide, in the wiring of
// wants_to_press through MechanicsParams / BallControlSlot, in the
// BallControl contest step (no-op here — the owner isn't a candidate
// against itself), or in the new ball_owner plumbing through
// WorldView / AwarenessView, trips the hash.
constexpr std::uint64_t kExpectedHashBallOnPitchWithDefender400 =
    0x71f639d918a32830ULL;

// Slice 31.5: cross-arch determinism proof for JockeyBehavior. Slot 1 is
// human-claimed, takes first touch on tick 1, and dribbles north. Slot 2 is
// an unclaimed LCB Defender-kind AI with only the `jockey` concept plugged,
// so AiController selects JockeyBehavior from the concrete defensive-role bag.
// The defender targets the deterministic 2 m lane behind the carrier's
// velocity vector and never asserts press/dribble. 200 ticks locks the first
// real defender posture golden before hysteresis or goal/team awareness lands.
constexpr std::uint64_t kExpectedHashDefenderJockeysDribbler200 =
    0x868f3c8ba8f86fbdULL;

// Slice 31.5: cross-arch determinism proof for MarkOpponentBehavior. Slot 1
// is an idle stationary target at (+5, 0). Slot 2 is an unclaimed LCB
// Defender-kind AI with only `marking` plugged and mark_target=SlotId{1}, so
// AiController selects MarkOpponentBehavior from the concrete defensive-role
// bag. No ball is spawned, keeping the golden focused on scenario-authored
// slot pairing and target-follow movement.
constexpr std::uint64_t kExpectedHashDefenderMarksStationaryTarget200 =
    0x603b1f6fda001167ULL;

// Slice 26.6: cross-arch golden for a short pass east. Locks the M2
// kick primitive introduced in Slice 26.3 (BallControl release-on-kick,
// BallPhysics::applyImpulse, kKickAliveTicks=40 friction-suppression
// window, MechanicsParams::pass_power default = 15 m/s from the
// physical.pass_power attribute registered at stable id=14 in
// migration 217). Setup: ball at origin at rest; SlotId{1} at
// (-0.3, 0, 0) claimed by a HumanController (0.3 m < kBallControlRadius
// = 0.5 m, so Rule 1 first-touch fires on tick 1); SlotId{2} at
// (+15, +5, 0) also claimed but never fed input — the +5 m y offset
// keeps it outside HumanController's kBallAutoDribbleRadius=1.5 m of
// the ball's east flight path so the auto-dribble augment never fires
// and Rule 1 never transfers ownership to slot 2 (that transfer is
// what PassReceive200 below tests separately). Script: tick 1 asserts
// dribble+east so slot 1 grabs the ball; ticks 2-9 dribble east;
// tick 10 asserts wants_kick + kick_direction=(+1,0,0) +
// kick_power_hint=0 so pass_power falls through to the 15 m/s default;
// ticks 11-400 the ball flies east through slot 2's neighborhood and
// coasts to rest under the M1 rest-band snap once kKickAliveTicks
// expires around tick 51. Any drift in release-on-kick timing, in
// applyImpulse magnitude / direction math, in kKickAliveTicks, in
// BallPhysics friction decay, or in the wants_kick INPUT path from
// Match::applyInput -> BallControl -> BallPhysics trips the hash.
constexpr std::uint64_t kExpectedHashPassEast400 = 0xd2287a0b3981f04dULL;

// Slice 26.6: cross-arch golden for the full pass-and-receive path.
// Same layout as PassEast400 but SlotId{2} is planted directly in
// the ball's flight path at (+15, 0, 0) and continuously asserts
// wants_dribble + desired_direction=(-1,0,0) (walking west toward
// the incoming pass). Around tick ~28-30 (ball at 15 m/s east, slot 2
// at ~2.5 m/s west, closing 15 m at 17.5 m/s ≈ 0.86 s ≈ 17 ticks post-
// kick) the ball crosses within kBallControlRadius=0.5 m of slot 2 →
// Rule 1 first-touch transfers ownership → Rule 3 glues the ball to
// slot 2 kBallOwnerLeadDistance ahead of its heading. Both continue
// west for the remainder of the 200 ticks. Locks everything
// PassEast400 locks PLUS: Rule 1 pickup at the receiving side
// (HumanController auto-dribble at 1.5 m, wants_dribble=true from
// explicit input, distance < 0.5 m threshold), Rule 3 glue behavior
// after the ownership transfer, and the deterministic tick timing of
// the crossover. This is the CI gate for the M2 exit criterion —
// two humans passing back and forth on BallOnPitch2v0 in the browser.
constexpr std::uint64_t kExpectedHashPassReceive200 = 0xdaa7989a56a58f5fULL;

// Slice 28.5 (§24.3, ADR §22.25): cross-arch determinism golden for a
// full goal-from-kick sequence in GoalDrillScenario. This is the
// authoritative end-to-end lock on the goal-detection pipeline landed
// in Slice 28.2 (goal regions) + 28.3 (post-physics detect + emit) +
// 28.4 (wire broadcast) — any drift in scenario geometry, ball
// physics friction / kick-alive suppression, BallControl release-on-
// kick timing, Match::tick's goal-region membership predicate, or the
// canonical dump encoding trips the hash.
//
// Script:
//   * seed = 42, GoalDrillScenario (slot 1 spawns at (-15, 0) heading
//     east; ball at centre spot at rest; east goal region at
//     x ∈ [+52.5, +54.5], y ∈ [-3.66, +3.66]).
//   * Slot 1 claimed with default M0 profile.
//   * Persistent intent (ticks 1..100): desired_direction=(+1,0,0),
//     wants_sprint = wants_dribble = true. Slot sprints east from -15
//     toward the ball, grabs it via Rule 1 first-touch (within
//     kBallControlRadius = 0.5 m AND wants_dribble asserted), then
//     carries east at max_carry_sprint_speed × dribble_efficiency =
//     6.0 × 0.85 = 5.1 m/s for the remaining ticks.
//   * Tick 101: fire wants_kick east with kick_power_hint = 25 m/s —
//     well above the profile default pass_power = 15 m/s to guarantee
//     the ball clears the ~50 m to the east goal line inside the 100-
//     tick remaining budget. BallControl releases ownership on the
//     kick tick, BallPhysics::applyImpulse launches the ball east at
//     25 m/s, kick_alive_ticks_remaining_ arms to 40.
//   * Ticks 102..200: idle intent (all flags cleared) so the persistent
//     wants_kick doesn't try to fire a second kick — defensive; the
//     released ball is now unowned so wants_kick is a no-op regardless.
//   * The ball crosses x = 52.5 while still inside the kick-alive
//     window and Match::tick's Slice-28.3 freeze rule zeroes velocity
//     + clears kick_alive_ticks_remaining_ + clears last_kicker_slot_
//     on emit — subsequent ticks sit motionless inside the east region.
//   * Post-tick assertions: exactly one PendingGoal drained, region
//     index = 1 (east), kicker = SlotId{1}. The v1 payload bytes
//     `[01 01 01 00 00]` = [ver=1][region=1][kicker_lo=1][kicker_hi=0]
//     [reserved=0] round-trip through encodeGoalPayloadV1 unchanged.
//   * Canonical snapshot dump hashed for cross-arch stability.
constexpr std::uint64_t kExpectedHashGoalFromKickEast200 =
    0x18c0949f8ab5f4aaULL;

// Slice 27.5: cross-arch determinism proof for a head-on player-vs-
// player collision under BasicPhysics (ADR §22.24). Two claimed slots
// spawn on the centre line 10 m apart (SlotId{1} at -5, SlotId{2} at
// +5) and BOTH assert wants_sprint with opposing desired_direction
// vectors so they run straight at each other at max sprint speed
// (default profile: max_sprint_speed = 7.5 m/s). Closing speed 15
// m/s over 10 m → first contact tick when 2*sprint*dt*n reaches the
// sum-of-radii gap (r_sum = 2 * kPlayerContactRadius = 0.8 m), i.e.
// around tick 13 (10 - 0.8) / (2 * 7.5 * 0.05) = 12.27.
//
// Post-contact BasicPhysics::resolveCollisions MTV-clamps the pair
// at exactly r_sum along the +x normal and zaps the closing +/-x
// component of each velocity to (approximately) zero via the
// tangential-slide branch. Both slots come to rest touching along
// the centre line and stay parked for the remainder of the 200 ticks
// (HumanController keeps re-asserting sprint intent every tick but
// the MTV re-fires and re-zaps every tick — net motion zero).
//
// Ball is spawned far off-axis at (0, +30, 0) at rest. The Slice
// 27.2 amendment guarantees ball is ALWAYS excluded from the
// collision pass regardless of ownership; the ball being present in
// the world at all is a byproduct of BallAndTwoSlotsScenario always
// having one, but its position / rest-state is invariant so it just
// contributes stable bytes to the canonical dump. Neither slot ever
// gets within kBallControlRadius = 0.5 m of the ball, so ownership
// never transfers.
//
// Any drift in BasicPhysics::resolveCollisions (MTV normal, mass
// split, velocity zap sign convention), in HumanController's sprint
// speed cap wiring, in the ascending-EntityId pair-iteration order,
// or in the ball-always-excluded rule, trips this hash.
constexpr std::uint64_t kExpectedHashCollideHeadOn200 = 0xda52a00e2a8c4b49ULL;

// Slice 27.5: cross-arch determinism proof for a claimed dribbler
// carrying an owned ball PAST a stationary obstacle under
// BasicPhysics (ADR §22.24 + Amendment 2026-07-17: ball is ALWAYS
// excluded from the collision pass, so no MTV-clamp is ever applied
// to the ball itself). Setup: SlotId{1} (dribbler) spawns at
// (-1, 0, 0), ball at (-0.7, 0, 0) at rest (0.3 m east of the
// dribbler, well inside kBallControlRadius = 0.5 m so Rule 1 first-
// touch fires on tick 1). SlotId{2} (obstacle) spawns at
// (+3, +0.15, 0) — nearly on the dribbler's east flight path but
// offset 0.15 m north so the MTV normal at contact has a non-zero
// y component and the dribbler slides tangentially past instead of
// stopping dead. SlotId{2} is claimed (so it runs HumanController,
// not the RNG-driven Wander controller) but never fed input — its
// default zero-Intent keeps it stationary at spawn.
//
// Ticks 1..400: dribbler asserts wants_dribble + wants_sprint +
// desired_direction=(+1,0,0). Owner + ball ride east as one
// kinematic unit (ball glued via BallControl to
// owner.position + kBallOwnerLeadDistance * heading). Around tick
// ~18-22 the dribbler's contact circle (radius 0.4) overlaps the
// obstacle's (also 0.4) at combined range 0.8 m; MTV clamps the
// dribbler outward along the (∂x, ∂y) normal (dominant +x, small
// -y since the dribbler was slightly BELOW the obstacle's y=+0.15
// centre) and the tangential-slide branch zaps only the closing
// normal component. The dribbler emerges south of the obstacle and
// keeps sprinting east; ball tracks the owner's south-of-obstacle
// trajectory.
//
// **Ownership transfers to SlotId{2} during the passthrough.**
// The critical observation for Slice 27.5: even though the ball is
// excluded from the COLLISION pass (Amendment 2026-07-17), the
// HumanController on the stationary obstacle auto-augments its
// zero-Intent with wants_dribble whenever the ball is within
// kBallAutoDribbleRadius = 1.5 m — and as the dribbler slides past
// with the ball glued 0.4 m ahead, the ball passes close enough to
// slot 2 (whose x-axis position stays ~3.0 m while the ball's y-
// track is only ~0.35 m away from slot 2's y=+0.15) that Rule 1's
// distance check fires and transfers ownership. Final snapshot
// shows ball_owner = 2. **That transfer is a legitimate
// AI-controller behaviour (not a physics bug)** — the ball itself
// was never MTV-clamped away from ANY owner during the collision
// pass, which is what the Amendment guarantees; ownership changed
// hands through the Rule-1 first-touch pathway, not through
// physics. Locking this exact outcome in the canonical hash catches
// any drift in: (a) the ball-always-excluded rule, (b) BallControl
// owner-glue math, (c) BasicPhysics tangential-slide sign
// convention, (d) HumanController auto-dribble augment threshold /
// wiring, (e) Rule 1 first-touch distance check with an existing
// owner, (f) the ascending-EntityId pair-iteration order in
// resolveCollisions.
constexpr std::uint64_t kExpectedHashCollisionBallPassthrough400 =
    0x77ca6ee4e965ccedULL;

} // namespace

FH_TEST(wander_only_200_ticks_seed_42) {
    auto m = makeMatch(42);
    for (int i = 0; i < 200; ++i) m->tick();

    const std::string canonical = canonicalDump(m->snapshot());
    // Emit canonical form to stdout so cross-arch script can diff.
    std::fputs("=== wander_only_200_ticks_seed_42 ===\n", stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashWander200) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update kExpectedHashWander200)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(kExpectedHashWander200));
    }
    FH_EXPECT_EQ(h, kExpectedHashWander200);
}

FH_TEST(human_sprint_east_400_ticks_seed_42) {
    auto m = makeMatch(42);
    fh::sim::profile::PlayerProfile profile;
    profile.physical = fh::sim::m0::defaultPhysical();
    profile.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{1}, ClientId{7}, PersonId{7}, std::move(profile));
    Intent in;
    in.desired_direction = Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    in.wants_sprint = true;
    m->applyInput(ClientId{7}, in);
    for (int i = 0; i < 400; ++i) m->tick();

    const std::string canonical = canonicalDump(m->snapshot());
    std::fputs("=== human_sprint_east_400_ticks_seed_42 ===\n", stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashHumanSprint400) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update kExpectedHashHumanSprint400)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(kExpectedHashHumanSprint400));
    }
    FH_EXPECT_EQ(h, kExpectedHashHumanSprint400);
}

// Slice 15.6: cross-arch determinism proof for the Slice 15 ball path.
// Ball starts at the centre spot with 20 m/s velocity east. BallPhysics
// applies its 49/50 per-tick decay + 1/100 rest threshold, so the ball
// settles well within 400 ticks (20 s at 20 Hz). Any drift in the fixed-
// point decay math, tick ordering, or snapshot encoding trips the hash.
FH_TEST(ball_roll_east_400_ticks_seed_42) {
    auto m = makeBallMatch(
        /*seed*/  42,
        /*pos*/   Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
        /*vel*/   Vec3{Fixed64::fromInt(20), Fixed64::zero(), Fixed64::zero()});
    for (int i = 0; i < 400; ++i) m->tick();

    const std::string canonical = canonicalDump(m->snapshot());
    // Emit canonical form to stdout so cross-arch script can diff it
    // (sim/scripts/check_determinism_cross_arch.sh reads these blocks).
    std::fputs("=== ball_roll_east_400_ticks_seed_42 ===\n", stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashBallRoll400) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update kExpectedHashBallRoll400)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(kExpectedHashBallRoll400));
    }
    FH_EXPECT_EQ(h, kExpectedHashBallRoll400);
}

// Slice 16.6: one human dribbling a ball across the pitch. Fingerprints
// BallControl Rule 1 (first-touch on tick 1), Rule 2 (retention while in
// range), and Rule 3 (glue offset + speed cap). If any of those mutate,
// the canonical dump — which now includes ball_owner — changes.
FH_TEST(one_human_dribbles_ball_east_200_ticks_seed_42) {
    fh::sim::scenario::SlotSpawn s1;
    s1.slot     = SlotId{1};
    s1.position = Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()};
    s1.heading  = Fixed64::zero();

    BallSpawn ball{
        Vec3{Fixed64::fromFraction(3, 10),   // 0.3 m east (inside 0.5 m)
             Fixed64::zero(), Fixed64::zero()},
        Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()}
    };

    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = 42;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<BallAndTwoSlotsScenario>(ball,
        std::vector<fh::sim::scenario::SlotSpawn>{s1});
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    auto m = std::make_unique<Match>(std::move(cfg));

    fh::sim::profile::PlayerProfile profile;
    profile.physical = fh::sim::m0::defaultPhysical();
    profile.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{1}, ClientId{7}, PersonId{7}, std::move(profile));

    Intent in;
    in.desired_direction = Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    in.wants_dribble     = true;
    m->applyInput(ClientId{7}, in);

    for (int i = 0; i < 200; ++i) m->tick();

    const std::string canonical = canonicalDump(m->snapshot());
    std::fputs("=== one_human_dribbles_ball_east_200_ticks_seed_42 ===\n",
               stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashDribble200) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update kExpectedHashDribble200)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(kExpectedHashDribble200));
    }
    FH_EXPECT_EQ(h, kExpectedHashDribble200);
}

// Slice 16.6: two humans race for one ball from equal distance. Rule 1
// tie-breaker (lower SlotId wins) must be deterministic across arches.
// Slot 1 sits 0.4 m west of the ball, Slot 2 sits 0.4 m east — both
// exactly at kBallControlRadius/tied. Rule 1 ties on distance → lower
// SlotId wins → Slot 1 gets ownership.
FH_TEST(two_humans_first_touch_tie_break_200_ticks_seed_42) {
    fh::sim::scenario::SlotSpawn s1;
    s1.slot     = SlotId{1};
    s1.position = Vec3{Fixed64::fromFraction(-4, 10), Fixed64::zero(),
                       Fixed64::zero()};
    s1.heading  = Fixed64::zero();

    fh::sim::scenario::SlotSpawn s2;
    s2.slot     = SlotId{2};
    s2.position = Vec3{Fixed64::fromFraction( 4, 10), Fixed64::zero(),
                       Fixed64::zero()};
    s2.heading  = Fixed64::zero();

    BallSpawn ball{
        Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
        Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()}
    };

    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = 42;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<BallAndTwoSlotsScenario>(ball,
        std::vector<fh::sim::scenario::SlotSpawn>{s1, s2});
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    auto m = std::make_unique<Match>(std::move(cfg));

    fh::sim::profile::PlayerProfile p1;
    p1.physical = fh::sim::m0::defaultPhysical();
    p1.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{1}, ClientId{11}, PersonId{11}, std::move(p1));

    fh::sim::profile::PlayerProfile p2;
    p2.physical = fh::sim::m0::defaultPhysical();
    p2.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{2}, ClientId{22}, PersonId{22}, std::move(p2));

    Intent i1;
    i1.desired_direction = Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    i1.wants_dribble     = true;
    m->applyInput(ClientId{11}, i1);

    Intent i2;
    i2.desired_direction = Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    i2.wants_dribble     = true;
    m->applyInput(ClientId{22}, i2);

    for (int i = 0; i < 200; ++i) m->tick();

    const std::string canonical = canonicalDump(m->snapshot());
    std::fputs("=== two_humans_first_touch_tie_break_200_ticks_seed_42 ===\n",
               stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashFirstTouch200) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update kExpectedHashFirstTouch200)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(kExpectedHashFirstTouch200));
    }
    FH_EXPECT_EQ(h, kExpectedHashFirstTouch200);
}

// Slice 17.6: cross-arch determinism proof for HalfPitchScenario (Hard
// mode). A sprint-east intent drives SlotId{1} into the east wall
// at x = 52.5. The Hard clamp fires every tick from then on. Any drift
// in apply_hard's Fixed64 math or in the Match wiring order (Soft
// pre-step, integrate, Hard post-step) trips the hash.
FH_TEST(half_pitch_hard_sprint_east_400_ticks_seed_42) {
    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = 42;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<HalfPitchScenario>();
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    auto m = std::make_unique<Match>(std::move(cfg));

    fh::sim::profile::PlayerProfile profile;
    profile.physical = fh::sim::m0::defaultPhysical();
    profile.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{1}, ClientId{7}, PersonId{7}, std::move(profile));

    Intent in;
    in.desired_direction =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    in.wants_sprint = true;
    m->applyInput(ClientId{7}, in);

    for (int i = 0; i < 400; ++i) m->tick();

    const std::string canonical = canonicalDump(m->snapshot());
    std::fputs("=== half_pitch_hard_sprint_east_400_ticks_seed_42 ===\n",
               stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashHalfPitchHard400) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update "
            "kExpectedHashHalfPitchHard400)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(kExpectedHashHalfPitchHard400));
    }
    FH_EXPECT_EQ(h, kExpectedHashHalfPitchHard400);
}

// Slice 17.6: cross-arch determinism proof for SoftDrillScenario (Soft
// mode). SlotId{1} spawns at (0, 0) and gets a sprint-east intent, so
// it exits the drill zone at x = 20 quickly and then experiences the
// Soft pushback. The canonical dump after 400 ticks locks
// apply_soft's Fixed64 math, the k = 4/s default stiffness constant,
// AND the Soft-pre-step / integrate / (no Hard post-step) tick
// ordering.
FH_TEST(soft_drill_sprint_east_400_ticks_seed_42) {
    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = 42;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<SoftDrillScenario>();
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    auto m = std::make_unique<Match>(std::move(cfg));

    fh::sim::profile::PlayerProfile profile;
    profile.physical = fh::sim::m0::defaultPhysical();
    profile.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{1}, ClientId{7}, PersonId{7}, std::move(profile));

    Intent in;
    in.desired_direction =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    in.wants_sprint = true;
    m->applyInput(ClientId{7}, in);

    for (int i = 0; i < 400; ++i) m->tick();

    const std::string canonical = canonicalDump(m->snapshot());
    std::fputs("=== soft_drill_sprint_east_400_ticks_seed_42 ===\n",
               stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashSoftDrill400) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update "
            "kExpectedHashSoftDrill400)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(kExpectedHashSoftDrill400));
    }
    FH_EXPECT_EQ(h, kExpectedHashSoftDrill400);
}

// Slice 24.3b: BallOnPitchWithDefender scenario cross-arch golden. See
// the constant comment above for the setup and expected owner flow.
FH_TEST(ball_on_pitch_with_defender_400_ticks_seed_42) {
    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = 42;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<
        fh::sim::scenario::BallOnPitchWithDefenderScenario>();
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    auto m = std::make_unique<Match>(std::move(cfg));

    // NO claimSlot — slot 1 stays Idle, slot 2 runs DefenderController.

    for (int i = 0; i < 400; ++i) m->tick();

    const std::string canonical = canonicalDump(m->snapshot());
    std::fputs("=== ball_on_pitch_with_defender_400_ticks_seed_42 ===\n",
               stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashBallOnPitchWithDefender400) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update "
            "kExpectedHashBallOnPitchWithDefender400)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(
                kExpectedHashBallOnPitchWithDefender400));
    }
    FH_EXPECT_EQ(h, kExpectedHashBallOnPitchWithDefender400);
}

// Slice 31.5: first defender posture golden. See constant comment above.
FH_TEST(defender_jockeys_dribbler_200_ticks_seed_42) {
    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = 42;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<JockeyVsLateralDribblerScenario>();
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    auto m = std::make_unique<Match>(std::move(cfg));

    fh::sim::profile::PlayerProfile profile;
    profile.physical = fh::sim::m0::defaultPhysical();
    profile.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{1}, ClientId{7}, PersonId{7}, std::move(profile));

    Intent in;
    in.desired_direction = Vec3{Fixed64::zero(), Fixed64::one(), Fixed64::zero()};
    in.wants_dribble = true;
    m->applyInput(ClientId{7}, in);

    for (int i = 0; i < 200; ++i) m->tick();

    const std::string canonical = canonicalDump(m->snapshot());
    std::fputs("=== defender_jockeys_dribbler_200_ticks_seed_42 ===\n",
               stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashDefenderJockeysDribbler200) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update "
            "kExpectedHashDefenderJockeysDribbler200)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(
                kExpectedHashDefenderJockeysDribbler200));
    }
    FH_EXPECT_EQ(h, kExpectedHashDefenderJockeysDribbler200);
}

// Slice 31.5: first mark-target posture golden. See constant comment above.
FH_TEST(defender_marks_stationary_target_200_ticks_seed_42) {
    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = 42;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<MarkStationaryTargetScenario>();
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    auto m = std::make_unique<Match>(std::move(cfg));

    for (int i = 0; i < 200; ++i) m->tick();

    const std::string canonical = canonicalDump(m->snapshot());
    std::fputs("=== defender_marks_stationary_target_200_ticks_seed_42 ===\n",
               stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashDefenderMarksStationaryTarget200) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update "
            "kExpectedHashDefenderMarksStationaryTarget200)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(
                kExpectedHashDefenderMarksStationaryTarget200));
    }
    FH_EXPECT_EQ(h, kExpectedHashDefenderMarksStationaryTarget200);
}

// Slice 26.6: cross-arch determinism proof for a short pass east.
// See kExpectedHashPassEast400 above for the setup rationale.
FH_TEST(pass_east_slot1_to_slot2_400_ticks_seed_42) {
    fh::sim::scenario::SlotSpawn s1;
    s1.slot     = SlotId{1};
    // 0.3 m west of the ball — inside kBallControlRadius=0.5 m so
    // Rule 1 first-touch fires on tick 1 with wants_dribble asserted.
    s1.position = Vec3{Fixed64::fromFraction(-3, 10),
                       Fixed64::zero(), Fixed64::zero()};
    s1.heading  = Fixed64::zero();  // east (kicker)

    fh::sim::scenario::SlotSpawn s2;
    s2.slot     = SlotId{2};
    // (+15, +5, 0): 5 m off-axis so HumanController's
    // kBallAutoDribbleRadius=1.5 m never trips as the ball flies past.
    // PassReceive200 below moves this back on-axis to test the receive.
    s2.position = Vec3{Fixed64::fromInt(15),
                       Fixed64::fromInt(5),
                       Fixed64::zero()};
    s2.heading  = fh::sim::math::FX_PI;  // west (nominally facing pass)

    BallSpawn ball{
        Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
        Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()}  // at rest
    };

    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = 42;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<BallAndTwoSlotsScenario>(ball,
        std::vector<fh::sim::scenario::SlotSpawn>{s1, s2});
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    auto m = std::make_unique<Match>(std::move(cfg));

    // Slot 1: the kicker.
    fh::sim::profile::PlayerProfile p1;
    p1.physical = fh::sim::m0::defaultPhysical();
    p1.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{1}, ClientId{11}, PersonId{11}, std::move(p1));

    // Slot 2: claimed but never fed input so its Intent stays idle.
    // Claimed (not unclaimed) to avoid the WanderController RNG stream
    // that would otherwise pollute the canonical dump.
    fh::sim::profile::PlayerProfile p2;
    p2.physical = fh::sim::m0::defaultPhysical();
    p2.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{2}, ClientId{22}, PersonId{22}, std::move(p2));

    // Tick 1: dribble east so first-touch grabs the ball.
    Intent dribble;
    dribble.desired_direction =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    dribble.wants_dribble = true;
    m->applyInput(ClientId{11}, dribble);
    m->tick();

    // Ticks 2-9: continue dribbling east.
    for (int i = 0; i < 8; ++i) m->tick();

    // Tick 10: fire the kick. wants_kick releases the ball and
    // BallPhysics::applyImpulse launches it along kick_direction at
    // MechanicsParams::pass_power (15 m/s default from migration 217).
    Intent kick;
    kick.desired_direction =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    kick.wants_kick        = true;
    kick.kick_direction    =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    kick.kick_power_hint   = 0;   // 0 = server uses MechanicsParams::pass_power
    m->applyInput(ClientId{11}, kick);
    m->tick();

    // Ticks 11-400: ball flies east, kKickAliveTicks=40 suppresses the
    // M1 rest-band snap for the first 40 ticks, then friction decay +
    // rest-snap wind the ball down to a stop somewhere east of pitch.
    // Slot 2 stays at (+15, +5) — Intent still idle from last-input
    // memory (never received an INPUT via applyInput).
    for (int i = 0; i < 389; ++i) m->tick();

    const std::string canonical = canonicalDump(m->snapshot());
    std::fputs("=== pass_east_slot1_to_slot2_400_ticks_seed_42 ===\n",
               stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashPassEast400) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update kExpectedHashPassEast400)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(kExpectedHashPassEast400));
    }
    FH_EXPECT_EQ(h, kExpectedHashPassEast400);
}

// Slice 26.6: cross-arch determinism proof for the full pass-and-
// receive path. See kExpectedHashPassReceive200 above.
FH_TEST(pass_receive_first_touch_200_ticks_seed_42) {
    fh::sim::scenario::SlotSpawn s1;
    s1.slot     = SlotId{1};
    s1.position = Vec3{Fixed64::fromFraction(-3, 10),
                       Fixed64::zero(), Fixed64::zero()};
    s1.heading  = Fixed64::zero();

    fh::sim::scenario::SlotSpawn s2;
    s2.slot     = SlotId{2};
    // On-axis this time — slot 2 is the receiver, ball path passes
    // right through it.
    s2.position = Vec3{Fixed64::fromInt(15),
                       Fixed64::zero(), Fixed64::zero()};
    s2.heading  = fh::sim::math::FX_PI;  // west (walks toward pass)

    BallSpawn ball{
        Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()},
        Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()}
    };

    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = 42;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<BallAndTwoSlotsScenario>(ball,
        std::vector<fh::sim::scenario::SlotSpawn>{s1, s2});
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    auto m = std::make_unique<Match>(std::move(cfg));

    fh::sim::profile::PlayerProfile p1;
    p1.physical = fh::sim::m0::defaultPhysical();
    p1.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{1}, ClientId{11}, PersonId{11}, std::move(p1));

    fh::sim::profile::PlayerProfile p2;
    p2.physical = fh::sim::m0::defaultPhysical();
    p2.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{2}, ClientId{22}, PersonId{22}, std::move(p2));

    // Slot 2 walks west toward the incoming pass and asserts
    // wants_dribble so Rule 1 fires as soon as the ball is within
    // kBallControlRadius=0.5 m.
    Intent walk_west;
    walk_west.desired_direction = Vec3{Fixed64::fromInt(-1),
                                       Fixed64::zero(),
                                       Fixed64::zero()};
    walk_west.wants_dribble = true;
    m->applyInput(ClientId{22}, walk_west);

    // Slot 1 pickup + kick (same script as PassEast400).
    Intent dribble;
    dribble.desired_direction =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    dribble.wants_dribble = true;
    m->applyInput(ClientId{11}, dribble);
    m->tick();
    for (int i = 0; i < 8; ++i) m->tick();

    Intent kick;
    kick.desired_direction =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    kick.wants_kick        = true;
    kick.kick_direction    =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    kick.kick_power_hint   = 0;   // 0 = server uses MechanicsParams::pass_power
    m->applyInput(ClientId{11}, kick);
    m->tick();

    // Ticks 11-200: pass flight + first-touch handoff around tick
    // ~28-30 + slot 2 continues west with ball glued.
    for (int i = 0; i < 189; ++i) m->tick();

    const std::string canonical = canonicalDump(m->snapshot());
    std::fputs("=== pass_receive_first_touch_200_ticks_seed_42 ===\n",
               stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashPassReceive200) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update kExpectedHashPassReceive200)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(kExpectedHashPassReceive200));
    }
    FH_EXPECT_EQ(h, kExpectedHashPassReceive200);
}

// Slice 28.5: cross-arch determinism proof for a full goal-from-kick
// sequence in GoalDrillScenario. See kExpectedHashGoalFromKickEast200
// above for the setup rationale + the wire-side / DB-side implications.
FH_TEST(goal_from_kick_east_200_ticks_seed_42) {
    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = 42;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<fh::sim::scenario::GoalDrillScenario>();
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    auto m = std::make_unique<Match>(std::move(cfg));

    fh::sim::profile::PlayerProfile profile;
    profile.physical = fh::sim::m0::defaultPhysical();
    profile.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{1}, ClientId{7}, PersonId{7}, std::move(profile));

    // Ticks 1..100: sprint east from (-15, 0) toward the ball at
    // centre with wants_dribble asserted so Rule 1 first-touch fires
    // as soon as the slot is within kBallControlRadius = 0.5 m of the
    // ball. Persistent input — one applyInput, 100 ticks.
    Intent approach;
    approach.desired_direction =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    approach.wants_sprint  = true;
    approach.wants_dribble = true;
    m->applyInput(ClientId{7}, approach);
    for (int i = 0; i < 100; ++i) m->tick();

    // Tick 101: fire wants_kick east at 25 m/s (kick_power_hint
    // overrides profile pass_power). BallControl releases ownership,
    // BallPhysics::applyImpulse launches the ball, kick_alive_ticks_
    // remaining_ arms to 40 (2 s at 20 Hz).
    Intent kick;
    kick.desired_direction =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    kick.wants_kick      = true;
    kick.kick_direction  =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    kick.kick_power_hint = 25;
    m->applyInput(ClientId{7}, kick);
    m->tick();

    // Ticks 102..200: idle intent so the persistent wants_kick from
    // last input doesn't re-fire (defensive; ball is unowned anyway).
    Intent idle;
    m->applyInput(ClientId{7}, idle);
    for (int i = 0; i < 99; ++i) m->tick();

    // Slice 28.3 + 28.5 assertion: exactly one Goal event emitted, in
    // the east region (index 1), attributed to SlotId{1}.
    auto goals = m->drainPendingGoals();
    FH_EXPECT_EQ(goals.size(), std::size_t{1});
    if (goals.size() == std::size_t{1}) {
        FH_EXPECT_EQ(goals[0].goal_region_index, std::uint8_t{1});
        FH_EXPECT(goals[0].kicker_slot.has_value());
        if (goals[0].kicker_slot.has_value()) {
            FH_EXPECT_EQ(*goals[0].kicker_slot, SlotId{1});
        }

        // Slice 28.5: lock the ADR §22.25 v1 Goal payload bytes for
        // this scenario. Any drift in encodeGoalPayloadV1 or in the
        // slot-id / region-id plumbing that Match::tick feeds it
        // trips these direct byte assertions in addition to the
        // canonical-hash drift below.
        const std::uint16_t kicker_id =
            goals[0].kicker_slot.has_value() ? *goals[0].kicker_slot
                : fh::sim::persistence::kGoalKickerSlotUnknown;
        const auto payload = fh::sim::persistence::encodeGoalPayloadV1(
            goals[0].goal_region_index, kicker_id);
        FH_EXPECT_EQ(payload.size(),
                     fh::sim::persistence::kGoalPayloadV1Bytes);
        FH_EXPECT_EQ(static_cast<std::uint8_t>(payload[0]),
                     fh::sim::persistence::kGoalPayloadV1Version);
        FH_EXPECT_EQ(static_cast<std::uint8_t>(payload[1]),
                     std::uint8_t{0x01});   // region = 1 (east)
        FH_EXPECT_EQ(static_cast<std::uint8_t>(payload[2]),
                     std::uint8_t{0x01});   // kicker_lo (SlotId 1)
        FH_EXPECT_EQ(static_cast<std::uint8_t>(payload[3]),
                     std::uint8_t{0x00});   // kicker_hi
        FH_EXPECT_EQ(static_cast<std::uint8_t>(payload[4]),
                     std::uint8_t{0x00});   // reserved
    }

    const std::string canonical = canonicalDump(m->snapshot());
    std::fputs("=== goal_from_kick_east_200_ticks_seed_42 ===\n", stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashGoalFromKickEast200) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update "
            "kExpectedHashGoalFromKickEast200)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(
                kExpectedHashGoalFromKickEast200));
    }
    FH_EXPECT_EQ(h, kExpectedHashGoalFromKickEast200);
}

// Slice 27.5: head-on player-vs-player collision under BasicPhysics.
// See kExpectedHashCollideHeadOn200 above for the setup rationale.
FH_TEST(two_humans_collide_head_on_200_ticks_seed_42) {
    fh::sim::scenario::SlotSpawn s1;
    s1.slot     = SlotId{1};
    s1.position = Vec3{Fixed64::fromInt(-5), Fixed64::zero(), Fixed64::zero()};
    s1.heading  = Fixed64::zero();

    fh::sim::scenario::SlotSpawn s2;
    s2.slot     = SlotId{2};
    s2.position = Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()};
    s2.heading  = Fixed64::zero();

    // Ball parked far off-axis; ball is ALWAYS excluded from the
    // collision pass (Slice 27.2 amendment) so its presence only
    // contributes stable bytes to the canonical dump.
    BallSpawn ball{
        Vec3{Fixed64::zero(), Fixed64::fromInt(30), Fixed64::zero()},
        Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()}
    };

    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = 42;
    cfg.physics  = std::make_unique<BasicPhysics>();
    cfg.scenario = std::make_unique<BallAndTwoSlotsScenario>(ball,
        std::vector<fh::sim::scenario::SlotSpawn>{s1, s2});
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    auto m = std::make_unique<Match>(std::move(cfg));

    fh::sim::profile::PlayerProfile p1;
    p1.physical = fh::sim::m0::defaultPhysical();
    p1.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{1}, ClientId{11}, PersonId{11}, std::move(p1));

    fh::sim::profile::PlayerProfile p2;
    p2.physical = fh::sim::m0::defaultPhysical();
    p2.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{2}, ClientId{22}, PersonId{22}, std::move(p2));

    Intent i1;
    i1.desired_direction =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    i1.wants_sprint = true;
    m->applyInput(ClientId{11}, i1);

    Intent i2;
    i2.desired_direction =
        Vec3{Fixed64::fromInt(-1), Fixed64::zero(), Fixed64::zero()};
    i2.wants_sprint = true;
    m->applyInput(ClientId{22}, i2);

    for (int i = 0; i < 200; ++i) m->tick();

    const std::string canonical = canonicalDump(m->snapshot());
    std::fputs("=== two_humans_collide_head_on_200_ticks_seed_42 ===\n",
               stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashCollideHeadOn200) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update "
            "kExpectedHashCollideHeadOn200)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(kExpectedHashCollideHeadOn200));
    }
    FH_EXPECT_EQ(h, kExpectedHashCollideHeadOn200);
}

// Slice 27.5: owned-ball passthrough of a stationary obstacle under
// BasicPhysics. See kExpectedHashCollisionBallPassthrough400 above
// for the setup rationale.
FH_TEST(collision_ball_passthrough_owned_400_ticks_seed_42) {
    fh::sim::scenario::SlotSpawn s1;
    s1.slot     = SlotId{1};
    s1.position = Vec3{Fixed64::fromInt(-1), Fixed64::zero(), Fixed64::zero()};
    s1.heading  = Fixed64::zero();

    fh::sim::scenario::SlotSpawn s2;
    s2.slot     = SlotId{2};
    s2.position = Vec3{Fixed64::fromInt(3),
                       Fixed64::fromFraction(15, 100),   // +0.15 m north
                       Fixed64::zero()};
    s2.heading  = Fixed64::zero();

    // Ball spawns 0.3 m east of dribbler — inside kBallControlRadius
    // = 0.5 m so Rule 1 first-touch fires on tick 1.
    BallSpawn ball{
        Vec3{Fixed64::fromFraction(-7, 10),
             Fixed64::zero(), Fixed64::zero()},
        Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()}
    };

    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = 42;
    cfg.physics  = std::make_unique<BasicPhysics>();
    cfg.scenario = std::make_unique<BallAndTwoSlotsScenario>(ball,
        std::vector<fh::sim::scenario::SlotSpawn>{s1, s2});
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    auto m = std::make_unique<Match>(std::move(cfg));

    fh::sim::profile::PlayerProfile p1;
    p1.physical = fh::sim::m0::defaultPhysical();
    p1.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{1}, ClientId{11}, PersonId{11}, std::move(p1));

    // Slot 2 is claimed (avoids the WanderController RNG stream) but
    // never fed input — its default zero-Intent keeps it stationary
    // at spawn for the entire run. Acts as a passive obstacle for
    // the dribbler to slide past.
    fh::sim::profile::PlayerProfile p2;
    p2.physical = fh::sim::m0::defaultPhysical();
    p2.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{2}, ClientId{22}, PersonId{22}, std::move(p2));

    Intent i1;
    i1.desired_direction =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    i1.wants_sprint  = true;
    i1.wants_dribble = true;
    m->applyInput(ClientId{11}, i1);

    for (int i = 0; i < 400; ++i) m->tick();

    const std::string canonical = canonicalDump(m->snapshot());
    std::fputs("=== collision_ball_passthrough_owned_400_ticks_seed_42 ===\n",
               stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a64(canonical);
    if (h != kExpectedHashCollisionBallPassthrough400) {
        std::fprintf(stderr,
            "  determinism drift: got hash 0x%016lx, expected 0x%016lx\n"
            "  (if this change is intentional, update "
            "kExpectedHashCollisionBallPassthrough400)\n",
            static_cast<unsigned long>(h),
            static_cast<unsigned long>(
                kExpectedHashCollisionBallPassthrough400));
    }
    FH_EXPECT_EQ(h, kExpectedHashCollisionBallPassthrough400);
}

FH_TEST_MAIN()
