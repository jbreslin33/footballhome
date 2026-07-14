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
#include "physics/StubPhysics.hpp"
#include "scenario/BallOnPitchScenario.hpp"
#include "scenario/EmptyPitchScenario.hpp"
#include "scenario/Scenario.hpp"
#include "controller/Intent.hpp"
#include "common/M0Attributes.hpp"
#include "math/Fixed64.hpp"
#include "profile/PlayerProfile.hpp"
#include "test_harness.hpp"

#include <cstdint>
#include <cstdio>
#include <memory>
#include <optional>
#include <string>

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
using fh::sim::physics::StubPhysics;
using fh::sim::scenario::BallOnPitchScenario;
using fh::sim::scenario::BallSpawn;
using fh::sim::scenario::EmptyPitchScenario;

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
    cfg.scenario = std::make_unique<BallOnPitchScenario>(
        std::optional<BallSpawn>{spawn});
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
// velocity at max_walk*dribble_efficiency, and skips BallPhysics for the
// ball. 200 ticks (10 s) exercises the glue + speed-cap paths.
constexpr std::uint64_t kExpectedHashDribble200 = 0xad857d3402f4a975ULL;

// Slice 16.6: cross-arch golden for two humans racing to the same ball.
// Both slots start equidistant (SlotId{1} at x=-0.4, SlotId{2} at x=+0.4)
// from a ball at origin. Both assert wants_dribble. First-touch rule:
// closest wins → SlotId{1} and SlotId{2} tie on distance, so Rule 1's
// tie-breaker (lower SlotId) awards ownership to SlotId{1}. The losing
// slot's motion still gets recorded, so the hash locks BOTH ownership
// AND the tie-breaker rule.
constexpr std::uint64_t kExpectedHashFirstTouch200 = 0xdb8d91b26222ddaaULL;

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

FH_TEST_MAIN()
