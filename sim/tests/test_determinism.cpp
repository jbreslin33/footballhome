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
#include "scenario/EmptyPitchScenario.hpp"
#include "controller/Intent.hpp"
#include "common/M0Attributes.hpp"
#include "math/Fixed64.hpp"
#include "profile/PlayerProfile.hpp"
#include "test_harness.hpp"

#include <cstdint>
#include <cstdio>
#include <memory>
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

// -----------------------------------------------------------------------
// Golden hash for the 200-tick "wander only" run with seed = 42.
// If the model changes intentionally, update this and re-hash.
// -----------------------------------------------------------------------
constexpr std::uint64_t kExpectedHashWander200 = 0x6884c4833f3bb725ULL;

// Golden hash for the 400-tick "one human sprints east" run with seed=42.
constexpr std::uint64_t kExpectedHashHumanSprint400 = 0xb71c450c79f4bb4fULL;

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

FH_TEST_MAIN()
