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

FH_TEST_MAIN()
