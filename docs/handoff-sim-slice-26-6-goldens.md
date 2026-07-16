# Handoff: Slice 26.6 — Pass determinism goldens (close Slice 26)

> **Status:** ready for pickup — no blockers, no upstream dependencies.
> Slices 26.1 through 26.5 are all landed on origin/main. This slice is
> the last remaining item to close Slice 26 fully; when it lands, the
> M2 short-pass primitive is done and the next block of work is Slice 27
> (player-player collisions, blocked on ADR §22.23).
>
> **Scope:** ~120 lines of C++ test code + two golden hashes recorded
> after a first-time green run. Pure test-only — no runtime, wire, or
> schema change. If your golden ever fails afterwards, something *else*
> drifted; do NOT bump the constants without understanding what.

## Motivation

Slice 26.3 introduced the pass primitive (`BallControl` release-on-kick,
`BallPhysics::applyImpulse`, `kKickAliveTicks=40` friction-suppression
window, `MechanicsParams::pass_power`, `BallOnPitch2v0Scenario`). Slice
26.4 unblocked the two-human smoke test by fixing a `libpqxx` thread-
safety bug. Slice 26.5 added the client-side ball trail. All landed.

Missing: the CI gate. Right now if someone accidentally changes
`kPassPower`'s default, or bumps `kKickAliveTicks`, or nudges
`kBallDecayPerTick`, or reorders `BallControl` rules, or edits
`Match::tick`'s kick branch, the sim still compiles, `wire-snoop.js`
still shows a plausible-looking ball trajectory in a manual browser
smoke test, and 47 of 47 tests still pass — because none of the 9
existing determinism goldens exercise `wants_kick`. That's the exact
kind of silent drift the goldens exist to prevent.

Two new goldens close the gap:

| Golden | Ticks | Fingerprints |
|---|---|---|
| `pass_east_slot1_to_slot2_400_ticks_seed_42` | 400 | release-on-kick, `applyImpulse` math, `kKickAliveTicks` window, coast-to-rest post-window |
| `pass_receive_first_touch_200_ticks_seed_42` | 200 | above + Rule 1 pickup at the receiver + Rule 3 glue on the new owner |

## Preconditions (verify before starting)

```bash
cd /srv/footballhome
git log --oneline -3          # Should include the Slice 26.5 commit
                              # (subject "sim(slice-26.5): client-side
                              # motion trail on the ball", SHA 6bfb99db
                              # as of 2026-07-16).
grep -n 'kExpectedHash'  sim/tests/test_determinism.cpp
                              # Should list 8 constants (one per non-M0
                              # golden). Nine when you're done.
sudo podman build -f sim/Dockerfile -t footballhome_sim:test-26-5 sim/
                              # Should end with "47/47 tests green" —
                              # baseline before you touch anything.
```

If any of those disagree, STOP and re-check the head commit before
adding tests on top of a moving target.

## File touch surface

| File | Change |
|---|---|
| `sim/tests/test_determinism.cpp` | Add two new `constexpr uint64_t kExpectedHash…` constants + two new `FH_TEST(…)` blocks + one new `#include` if needed |
| `sim/DESIGN.md` §24.3 Slice 26 log | Flip 26.6 checkbox `[ ]` → `[x]` with the landing date, actual golden hashes, and "closes Slice 26" note |

Nothing else. No `CMakeLists.txt` edit (tests are discovered by
`sim/tests/CMakeLists.txt`'s existing `fh_add_test` glob when they
live in an already-compiled file). No new headers.

## Implementation

### Step 1 — imports (top of `test_determinism.cpp`)

Verify the existing block already has `#include "scenario/BallOnPitch2v0Scenario.hpp"`.
As of Slice 26.3 it does NOT — the file compiles because the two new
tests use the LOCAL `BallAndTwoSlotsScenario` (defined in the anonymous
namespace at the top of the file), NOT the production
`BallOnPitch2v0Scenario`. Keep it that way — `BallAndTwoSlotsScenario`
gives you an explicit ball spawn + slot spawn list that never rotates
as production scenarios evolve.

If you find you need `BallOnPitch2v0Scenario` for some reason during
development, stop and reconsider: the existing 4 ball-related goldens
(`BallRoll400`, `Dribble200`, `FirstTouch200`,
`BallOnPitchWithDefender400`) all use `BallAndTwoSlotsScenario` or a
similar minimal test scenario for exactly this stability reason.

### Step 2 — new constants (adjacent to the existing 8, right above `} // namespace`)

Paste these placeholder values in — they'll fail the test on the first
run so you can copy the actual hashes out of stderr. This is the same
recording protocol as every previous golden (see the file header
comment lines 15-19).

```cpp
// Slice 26.6: cross-arch golden for a short pass east — slot 1 picks
// up the ball, then kicks east at pass_power=15 m/s (default from the
// physical.pass_power attribute, migration 217). Slot 2 is unclaimed
// (Idle → no wants_dribble) so Rule 1 first-touch at the receiver
// side does NOT fire — this golden captures the pass FLIGHT and the
// coast-to-rest tail alone, not the receive. Locks:
//   * release-on-kick in BallControl.cpp Rule 2 branch
//   * BallPhysics::applyImpulse magnitude + direction normalization
//   * kKickAliveTicks = 40 window that suppresses the M1 snap-to-rest
//     clamp for the first 2 s after the kick
//   * post-window rest-band snap (ball freezes at pos ≈ 15 m + tail)
//   * the whole wants_kick INPUT path from Match::applyInput through
//     BallControl to BallPhysics.
constexpr std::uint64_t kExpectedHashPassEast400 = 0x0ULL;   // TODO fill after first green run

// Slice 26.6: cross-arch golden for the full pass-and-receive path.
// Same setup as PassEast400 but slot 2 IS claimed and continuously
// asserts wants_dribble + heading -x (walking west toward the
// incoming ball). Somewhere around tick ~30-50 the ball crosses
// within kBallControlRadius = 0.5 m of slot 2 → Rule 1 first-touch
// transfers ownership; from then on the ball glues to slot 2 via
// Rule 3 (kBallOwnerLeadDistance offset, max_dribble_speed cap) and
// both continue west. Locks:
//   * everything PassEast400 locks
//   * Rule 1 first-touch pickup on the receiving side (this is what
//     the M2 exit gate two-human test actually exercises)
//   * Rule 3 glue behavior after ownership transfer
//   * the deterministic timing of "at exactly which tick does the
//     ball cross the pickup radius" — the whole point of the golden
constexpr std::uint64_t kExpectedHashPassReceive200 = 0x0ULL;  // TODO fill after first green run
```

### Step 3 — new `FH_TEST` bodies (append at bottom of file, right BEFORE `FH_TEST_MAIN()`)

Copy-paste template based on `one_human_dribbles_ball_east_200_ticks_seed_42`
(lines 291-345) — that's the closest existing test in structure.

```cpp
// Slice 26.6: cross-arch determinism proof for the pass primitive
// (kick flight + coast-to-rest). See kExpectedHashPassEast400 above
// for the setup rationale.
FH_TEST(pass_east_slot1_to_slot2_400_ticks_seed_42) {
    fh::sim::scenario::SlotSpawn s1;
    s1.slot     = SlotId{1};
    // Just inside kBallControlRadius = 0.5 m so first-touch fires on
    // tick 1 without any dribble travel — keeps the fingerprint tight
    // on kick-flight rather than dribble approach.
    s1.position = Vec3{Fixed64::fromFraction(-3, 10),  // -0.3 m west
                       Fixed64::zero(), Fixed64::zero()};
    s1.heading  = Fixed64::zero();  // east

    fh::sim::scenario::SlotSpawn s2;
    s2.slot     = SlotId{2};
    s2.position = Vec3{Fixed64::fromInt(15),           // +15 m east
                       Fixed64::zero(), Fixed64::zero()};
    s2.heading  = fh::sim::math::FX_PI;                // west (faces incoming pass)

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

    // Slot 1 is the kicker.
    fh::sim::profile::PlayerProfile p1;
    p1.physical = fh::sim::m0::defaultPhysical();
    p1.concepts = fh::sim::m0::defaultConcepts();
    m->claimSlot(SlotId{1}, ClientId{11}, PersonId{11}, std::move(p1));

    // Slot 2 stays IDLE — no claimSlot. IdleController never asserts
    // wants_dribble, so Rule 1 first-touch at the receiver side never
    // fires. This isolates the kick + flight + rest math.

    // Tick 1: dribble east so first-touch grabs the ball. wants_dribble
    // must be true for Rule 1 to fire, and desired_direction sets the
    // heading BallControl uses when it fills BallControlResult owned
    // fields.
    Intent dribble;
    dribble.desired_direction =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    dribble.wants_dribble     = true;
    m->applyInput(ClientId{11}, dribble);
    m->tick();  // First-touch on tick 1; ball glues to slot 1.

    // Ticks 2..9: continue dribbling east so the kick fires from a
    // predictable position (slot 1 will have travelled a few tenths
    // of a metre east under Rule 3's kBallOwnerLeadDistance +
    // max_dribble_speed cap).
    for (int i = 0; i < 8; ++i) m->tick();

    // Tick 10: fire the kick. wants_kick + explicit direction + hint=0
    // so pass_power is drawn from MechanicsParams (physical.pass_power
    // default = 15 m/s via migration 217).
    Intent kick;
    kick.desired_direction =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    kick.wants_dribble     = true;  // owner check gate; kick supersedes retention
    kick.wants_kick        = true;
    kick.kick_direction    =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    kick.kick_power_hint   = 0;
    m->applyInput(ClientId{11}, kick);
    m->tick();  // Ball released with impulse.

    // Ticks 11..400: coast to rest. kick continues to be reasserted
    // (harmless — the ball has no owner post-release, so Rule 2 is
    // never entered again by this slot until Rule 1 re-picks-up, which
    // won't happen because slot 1's position lags the ball once it
    // starts flying at 15 m/s while slot 1 is capped at
    // max_dribble_speed).
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
    s2.position = Vec3{Fixed64::fromInt(15),
                       Fixed64::zero(), Fixed64::zero()};
    s2.heading  = fh::sim::math::FX_PI;

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

    // Slot 2 walks west toward the incoming ball — asserts every tick
    // so Rule 1 first-touch fires the moment the ball crosses within
    // kBallControlRadius = 0.5 m.
    Intent walk_west;
    walk_west.desired_direction =
        Vec3{Fixed64{-1} * Fixed64::one() / Fixed64::one(),  // -1 east = west
             Fixed64::zero(), Fixed64::zero()};
    // NB: if that -1 construction doesn't compile in your build,
    // use Vec3{Fixed64::fromInt(-1), Fixed64::zero(), Fixed64::zero()}
    walk_west.wants_dribble = true;
    m->applyInput(ClientId{22}, walk_west);

    // Slot 1 pickup + kick — identical script to PassEast400.
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
    kick.wants_dribble  = true;
    kick.wants_kick     = true;
    kick.kick_direction =
        Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    kick.kick_power_hint = 0;
    m->applyInput(ClientId{11}, kick);
    m->tick();

    // Ticks 11..200: pass flight, slot 2 walks west, they meet
    // somewhere ~x=7-12 m, slot 2 first-touches, they continue west
    // together.
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
```

**Tuning knobs** if the golden turns out to be visually uninteresting
(e.g. slot 2 misses the ball in PassReceive200):

* Nudge `s2.position` closer to origin (say +10 m east instead of +15 m).
* Nudge slot 2's `walk_west.desired_direction` magnitude — it should
  already be a unit vector so probably fine.
* Push more ticks (300 instead of 200) so the receiver has more time.

Whatever you settle on, WRITE IT DOWN in the constant's comment so a
future maintainer knows why 15 not 10 m, why 200 not 300 ticks. Every
existing golden has this rationale — follow the pattern.

### Step 4 — record the hashes (first-time green run)

```bash
# Build. ctest will fail because the placeholder 0x0 hashes don't match.
sudo podman build -f sim/Dockerfile -t footballhome_sim:test-26-6 sim/

# Read the "got hash 0x..." lines out of the build stderr. There will
# be two — one per new test. Paste each into its constant.

# Rebuild. Should now show 49/49 tests green (was 47; +2 new).
sudo podman build -f sim/Dockerfile -t footballhome_sim:test-26-6 sim/
```

The build log is enormous; if you get lost, use:

```bash
# NOTE: filtering only for the ONE-OFF hash extraction, per repo norms
# (see .github/copilot-instructions.md — don't habitually pipe to grep).
sudo podman build -f sim/Dockerfile -t footballhome_sim:test-26-6 sim/ 2>&1 \
  | grep -E 'determinism drift|expected hash'
```

### Step 5 — cross-arch verification (optional but recommended)

`sim/scripts/check_determinism_cross_arch.sh` diffs the canonical dumps
between amd64 and arm64 runs. If you have access to both arches:

```bash
./sim/scripts/check_determinism_cross_arch.sh
```

If you only have amd64 (which is the fishtown host), skip this — the
golden hash itself locks the amd64 output. Someone on arm64 can run it
next time they build.

### Step 6 — retag + smoke-test in prod

```bash
sudo podman tag localhost/footballhome_sim:test-26-6 \
                localhost/footballhome_footballhome_sim:latest
# No further action needed — the next tile-launch in tactical-games
# will spawn a container from the new image. Old sim_XXX containers
# are running the previous image; leaving them alone is fine.
```

### Step 7 — DESIGN.md log + commit

In `sim/DESIGN.md` §24.3 Slice 26, flip the 26.6 checkbox and record
the actual hashes:

```md
- [x] 26.6 (YYYY-MM-DD) — Determinism goldens for the pass primitive.
      pass_east_slot1_to_slot2_400_ticks_seed_42 = 0x… ;
      pass_receive_first_touch_200_ticks_seed_42 = 0x… .
      49/49 sim tests green (47 pre-existing + 2 new). Slice 26 CLOSED.
```

Update the exit-gate note two lines below to say "**Closed
YYYY-MM-DD** with Slice 26.6 landing."

Commit + push:

```bash
git -C /srv/footballhome add sim/tests/test_determinism.cpp sim/DESIGN.md
git -C /srv/footballhome commit -m "sim(slice-26.6): determinism goldens for the pass primitive

<body describing the two hashes and what they lock — see the Slice
26.4 / 26.5 commits for the tone / level of detail.>"
git -C /srv/footballhome push origin main
```

### Step 8 — delete this handoff doc

Once the commit lands, this doc is stale. Remove it (and its DESIGN.md
link) in a follow-up commit — do not leave a "ready for pickup"
document pointing at completed work.

```bash
git -C /srv/footballhome rm docs/handoff-sim-slice-26-6-goldens.md
# Also edit sim/DESIGN.md and drop the "Full handoff spec … at
# [docs/handoff-…]" line from the Slice 26 exit gate paragraph.
git -C /srv/footballhome commit -m "docs: remove Slice 26.6 handoff (landed)"
git -C /srv/footballhome push origin main
```

## What Slice 26.6 does NOT do

* No gameplay change. Nothing a coach can see in a browser will
  differ before vs after.
* No new attribute, no new scenario, no new INPUT flag, no new wire
  bit. Everything the tests exercise already exists on origin/main.
* No schema migration. The tests use `InMemoryPgClient` transitively
  via `Match` — Postgres is not touched.
* No CMake edit. Tests glob via `sim/tests/CMakeLists.txt`'s
  `fh_add_test` pattern and pick up new `FH_TEST` blocks in
  already-compiled files automatically.

## Next after 26.6 (context, not action items for this handoff)

`sim/DESIGN.md` §24.3 has Slice 27 sketched: player-player collisions,
blocked on ADR §22.23. That's the next real gameplay slice. Do not
start it as part of this handoff — write a fresh handoff doc for it,
matching this template.

## Rollback plan

If the goldens turn out to be flaky (they shouldn't — the sim is fully
deterministic — but sanity-check):

```bash
git -C /srv/footballhome revert <slice-26.6-sha>
git -C /srv/footballhome push origin main
sudo podman tag localhost/footballhome_sim:test-26-5 \
                localhost/footballhome_footballhome_sim:latest
```

The reverted state is `6bfb99db` (Slice 26.5). Slice 26.4 and earlier
are untouched by this slice so no image rebuild is needed to fall back
further.
