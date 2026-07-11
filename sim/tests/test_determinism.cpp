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

#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "match/Snapshot.hpp"
#include "physics/StubPhysics.hpp"
#include "scenario/EmptyPitchScenario.hpp"
#include "controller/Intent.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

#include <cstdint>
#include <cstdio>
#include <memory>
#include <string>

using fh::sim::ClientId;
using fh::sim::SlotId;
using fh::sim::controller::Intent;
using fh::sim::match::Match;
using fh::sim::match::MatchConfig;
using fh::sim::match::RealtimeClock;
using fh::sim::match::Snapshot;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::physics::StubPhysics;
using fh::sim::scenario::EmptyPitchScenario;

namespace {

// FNV-1a-64. Deterministic on every host; the whole point of the test is
// that its inputs are also deterministic.
constexpr std::uint64_t kFnvOffset = 0xcbf29ce484222325ULL;
constexpr std::uint64_t kFnvPrime  = 0x100000001b3ULL;

std::uint64_t fnv1a(const std::string& s) noexcept {
    std::uint64_t h = kFnvOffset;
    for (const char c : s) {
        h ^= static_cast<std::uint8_t>(c);
        h *= kFnvPrime;
    }
    return h;
}

// Serialize one Fixed64 as fixed-width lowercase hex of its raw int64 bits.
// (Reinterpret via memcpy — bit-exact and portable.)
void appendHex(std::string& out, Fixed64 f) {
    char buf[19];   // "0x" + 16 hex + NUL
    std::snprintf(buf, sizeof(buf), "0x%016lx",
                  static_cast<unsigned long>(static_cast<std::uint64_t>(f.raw)));
    out.append(buf);
}

std::string dump(const Snapshot& snap) {
    std::string out;
    out.reserve(snap.entities.size() * 128);

    char header[64];
    std::snprintf(header, sizeof(header),
                  "tick=%u time_ms=%u count=%zu\n",
                  static_cast<unsigned>(snap.tick),
                  static_cast<unsigned>(snap.match_time_ms),
                  snap.entities.size());
    out.append(header);

    for (const auto& e : snap.entities) {
        char prefix[64];
        std::snprintf(prefix, sizeof(prefix),
                      "slot=%u eid=%u motion=%u flags=%04x ",
                      static_cast<unsigned>(e.state.slot_id),
                      static_cast<unsigned>(e.state.id),
                      static_cast<unsigned>(e.state.motion),
                      static_cast<unsigned>(e.flags.toU16()));
        out.append(prefix);
        out.append("pos=("); appendHex(out, e.state.position.x);
        out.append(",");     appendHex(out, e.state.position.y);
        out.append(",");     appendHex(out, e.state.position.z);
        out.append(") vel=("); appendHex(out, e.state.velocity.x);
        out.append(",");       appendHex(out, e.state.velocity.y);
        out.append(",");       appendHex(out, e.state.velocity.z);
        out.append(") h=");    appendHex(out, e.state.heading);
        out.append("\n");
    }
    return out;
}

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

    const std::string canonical = dump(m->snapshot());
    // Emit canonical form to stdout so cross-arch script can diff.
    std::fputs("=== wander_only_200_ticks_seed_42 ===\n", stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a(canonical);
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
    m->claimSlot(SlotId{1}, ClientId{7});
    Intent in;
    in.desired_direction = Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    in.wants_sprint = true;
    m->applyInput(ClientId{7}, in);
    for (int i = 0; i < 400; ++i) m->tick();

    const std::string canonical = dump(m->snapshot());
    std::fputs("=== human_sprint_east_400_ticks_seed_42 ===\n", stdout);
    std::fputs(canonical.c_str(), stdout);

    const std::uint64_t h = fnv1a(canonical);
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
