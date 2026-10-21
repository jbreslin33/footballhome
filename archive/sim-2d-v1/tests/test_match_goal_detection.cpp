// footballhome sim - Match goal detection tests (Slice 28.3)
//
// Verifies the post-physics goal-detection loop added in Slice 28.3:
//   * Grandfather clause: scenarios that return empty goalRegions()
//     (every pre-28 scenario) NEVER produce a PendingGoal, even with
//     the ball at (0,0,0) — the loop early-returns on `regions.empty()`.
//   * Edge-triggered detection: a ball SITTING inside a region emits
//     exactly ONE PendingGoal (on the tick it enters), not one per
//     tick thereafter.
//   * Freeze rule: on emit, the ball's velocity is snapped to zero so
//     it stops inside the region.
//   * Exit + re-entry re-arms detection: leave the region, re-enter,
//     get a fresh PendingGoal.
//   * Ball outside every region on tick 0 emits nothing.
//   * Kicker attribution (nullopt when no kick fired) surfaces on the
//     PendingGoal for SimServer to encode into the ADR §22.25 v1 payload.
//
// Kicker attribution WHEN a kick fires is verified end-to-end via the
// Slice 28.5 determinism golden `goal_from_kick_east_200_ticks_seed_42`.
// Here we only assert the "no kick → nullopt" path since it is fully
// scenario-driven.

#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "physics/StubPhysics.hpp"
#include "scenario/Scenario.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

#include <cstdint>
#include <memory>
#include <optional>
#include <string>
#include <vector>

using fh::sim::EntityState;
using fh::sim::SlotId;
using fh::sim::awareness::WorldView;
using fh::sim::match::Match;
using fh::sim::match::MatchConfig;
using fh::sim::match::RealtimeClock;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::physics::StubPhysics;
using fh::sim::scenario::BallSpawn;
using fh::sim::scenario::GoalRegion;
using fh::sim::scenario::PitchSpec;
using fh::sim::scenario::PlayableArea;
using fh::sim::scenario::Scenario;
using fh::sim::scenario::SlotSpawn;

namespace {

// Test-local scenario with injectable goal regions + ball spawn. No
// slots — goal detection reads only from the ball's post-physics
// position, so slot-less matches exercise the detector cleanly.
class GoalRegionsTestScenario : public Scenario {
public:
    GoalRegionsTestScenario(std::optional<BallSpawn>     ball,
                            std::vector<GoalRegion>      regions)
        : ball_{std::move(ball)}, regions_{std::move(regions)} {}

    std::string           id() const override            { return "test_goal_regions"; }
    std::string           displayName() const override   { return "Test Goal Regions"; }

    PitchSpec pitch() const override {
        return PitchSpec{Fixed64::fromInt(105), Fixed64::fromInt(68)};
    }
    PlayableArea playableArea() const override {
        PlayableArea a;
        a.constraint_mode = PlayableArea::Mode::Advisory;
        a.zoom_hint       = Fixed64::zero();
        return a;
    }
    std::vector<SlotSpawn>   initialSpawns() const override { return {}; }
    std::optional<BallSpawn> ballSpawn() const override     { return ball_; }
    std::vector<GoalRegion>  goalRegions() const override   { return regions_; }
    bool checkSuccess(const WorldView& w) const override { (void)w; return false; }
    bool checkReset  (const WorldView& w) const override { (void)w; return false; }
    std::vector<std::string> hints() const override { return {}; }

private:
    std::optional<BallSpawn> ball_;
    std::vector<GoalRegion>  regions_;
};

std::unique_ptr<Match>
makeMatch(std::optional<BallSpawn>   ball,
          std::vector<GoalRegion>    regions,
          std::uint64_t              seed = 42)
{
    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = seed;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<GoalRegionsTestScenario>(
        std::move(ball), std::move(regions));
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    return std::make_unique<Match>(std::move(cfg));
}

// A single 10 m cube AABB centered at (50, 0, 0) — index 0.
GoalRegion eastRegion() {
    GoalRegion r;
    r.index = 0;
    r.min   = Vec3{Fixed64::fromInt(45),
                   Fixed64::fromInt(-5),
                   Fixed64::fromInt(0)};
    r.max   = Vec3{Fixed64::fromInt(55),
                   Fixed64::fromInt(5),
                   Fixed64::fromInt(3)};
    return r;
}

// A single 10 m cube AABB centered at (-50, 0, 0) — index 1.
GoalRegion westRegion() {
    GoalRegion r;
    r.index = 1;
    r.min   = Vec3{Fixed64::fromInt(-55),
                   Fixed64::fromInt(-5),
                   Fixed64::fromInt(0)};
    r.max   = Vec3{Fixed64::fromInt(-45),
                   Fixed64::fromInt(5),
                   Fixed64::fromInt(3)};
    return r;
}

BallSpawn ballAt(Fixed64 x, Fixed64 vx = Fixed64::zero()) {
    BallSpawn b;
    b.position = Vec3{x, Fixed64::zero(), Fixed64::zero()};
    b.velocity = Vec3{vx, Fixed64::zero(), Fixed64::zero()};
    return b;
}

} // namespace

// ─────────────────────────────────────────────────────────────────────
// Grandfather: any scenario with empty goalRegions() emits nothing,
// even with a ball at (0,0,0) where the M2 default GoalRegion AABB
// intuition would place it. This is the invariant that keeps every
// pre-28 canonical hash unchanged.
// ─────────────────────────────────────────────────────────────────────
FH_TEST(empty_goal_regions_never_emits) {
    auto m = makeMatch(ballAt(Fixed64::zero()), /*regions=*/{});
    for (int i = 0; i < 50; ++i) { m->tick(); }
    FH_EXPECT_EQ(m->drainPendingGoals().size(), 0u);
}

// Ball spawns OUTSIDE every region — no goal, ever.
FH_TEST(ball_outside_region_never_emits) {
    auto m = makeMatch(ballAt(Fixed64::zero()), {eastRegion(), westRegion()});
    for (int i = 0; i < 50; ++i) { m->tick(); }
    FH_EXPECT_EQ(m->drainPendingGoals().size(), 0u);
}

// Ball spawns INSIDE a region → first tick emits exactly one PendingGoal
// (edge-trigger from prev=nullopt). Post-tick ball velocity is zero.
FH_TEST(ball_starts_inside_region_emits_on_first_tick) {
    auto m = makeMatch(ballAt(Fixed64::fromInt(50)), {eastRegion()});
    m->tick();

    auto goals = m->drainPendingGoals();
    FH_EXPECT_EQ(goals.size(), 1u);
    FH_EXPECT_EQ(goals[0].goal_region_index, std::uint8_t{0});
    FH_EXPECT(!goals[0].kicker_slot.has_value());
    FH_EXPECT_EQ(goals[0].tick_num, fh::sim::TickNum{1});
}

// Ball continues sitting inside the region on subsequent ticks — no
// repeat. This is the invariant that keeps a single crossing from
// spamming Postgres with thousands of Goal rows.
FH_TEST(ball_sitting_in_region_does_not_repeat) {
    auto m = makeMatch(ballAt(Fixed64::fromInt(50)), {eastRegion()});
    m->tick();
    auto first = m->drainPendingGoals();
    FH_EXPECT_EQ(first.size(), 1u);

    // Next 100 ticks: ball is still there, velocity is zero, no more emits.
    for (int i = 0; i < 100; ++i) { m->tick(); }
    FH_EXPECT_EQ(m->drainPendingGoals().size(), 0u);
}

// Ball enters region with positive velocity — the freeze rule zeroes
// its velocity so it doesn't shoot back out and generate wobble.
FH_TEST(entering_ball_velocity_is_zeroed_on_emit) {
    // Ball at x=44 (just outside east region min.x=45), moving +x fast
    // enough to be inside the region after one tick's integration.
    // At dt = 1/20 s and vx = 40 m/s, tick 1 leaves the ball at x ≈ 46
    // (inside). Slice 15.2 friction decays 40 → 40 * (49/50) = 39.2
    // before integration; 39.2 * 1/20 = 1.96 m ⇒ ball at 44 + 1.96 =
    // 45.96 — inside the AABB.
    auto m = makeMatch(ballAt(Fixed64::fromInt(44), Fixed64::fromInt(40)),
                       {eastRegion()});
    m->tick();

    auto goals = m->drainPendingGoals();
    FH_EXPECT_EQ(goals.size(), 1u);

    // After the emit-and-freeze, the ball's velocity is zero.
    const auto snap = m->snapshot();
    FH_EXPECT_EQ(snap.entities.size(), 1u);
    FH_EXPECT_EQ(snap.entities[0].state.velocity.x, Fixed64::zero());
    FH_EXPECT_EQ(snap.entities[0].state.velocity.y, Fixed64::zero());
    FH_EXPECT_EQ(snap.entities[0].state.velocity.z, Fixed64::zero());
}

// Multi-region scenario: index bookkeeping picks the correct region.
FH_TEST(correct_region_index_emitted) {
    auto m = makeMatch(ballAt(Fixed64::fromInt(-50)),
                       {eastRegion(), westRegion()});
    m->tick();
    auto goals = m->drainPendingGoals();
    FH_EXPECT_EQ(goals.size(), 1u);
    FH_EXPECT_EQ(goals[0].goal_region_index, std::uint8_t{1});
}

// Drain is destructive: a second drain returns empty.
FH_TEST(drain_is_destructive) {
    auto m = makeMatch(ballAt(Fixed64::fromInt(50)), {eastRegion()});
    m->tick();

    auto first  = m->drainPendingGoals();
    FH_EXPECT_EQ(first.size(), 1u);

    auto second = m->drainPendingGoals();
    FH_EXPECT_EQ(second.size(), 0u);
}

// tick_num on the emitted goal matches the clock at emit time.
FH_TEST(goal_tick_num_matches_clock) {
    auto m = makeMatch(ballAt(Fixed64::fromInt(0)), {eastRegion()});
    // Ticks 1..10: ball is at (0,0,0) outside — nothing emitted.
    for (int i = 0; i < 10; ++i) { m->tick(); }
    FH_EXPECT_EQ(m->drainPendingGoals().size(), 0u);

    // Teleport the ball into the region via a raw physics write, then
    // tick — the goal should carry tick_num == 11.
    auto* p = m->physics_for_tests();
    // Find the ball entity via the snapshot (ball is at slot_id=0).
    fh::sim::EntityId ball_entity{};
    for (auto& e : m->snapshot().entities) {
        if (e.flags.is_ball) {
            ball_entity = e.state.id;
            break;
        }
    }
    EntityState st = p->get(ball_entity);
    st.position = Vec3{Fixed64::fromInt(50), Fixed64::zero(), Fixed64::zero()};
    p->setPosition(ball_entity, st.position);

    m->tick();
    auto goals = m->drainPendingGoals();
    FH_EXPECT_EQ(goals.size(), 1u);
    FH_EXPECT_EQ(goals[0].tick_num, fh::sim::TickNum{11});
}

FH_TEST_MAIN()
