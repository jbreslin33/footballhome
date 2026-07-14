// footballhome sim - Match + ball wiring test (Slice 15.2)
//
// Verifies that a scenario whose ballSpawn() returns a non-null BallSpawn
// causes the Match to:
//   1. spawn a physics entity with is_ball=true and slot_id=0
//   2. run BallPhysics::tickBall on that entity every tick BEFORE the
//      position integration pass, so the ball's velocity decays and the
//      integrator advances position by the decayed velocity
//   3. emit the ball as a first SnapshotEntity with flags.is_ball=true,
//      preserving the "sorted by slot_id ascending" invariant §5.7
//      documents (ball at slot 0 < any player at slot >=1)
//
// Absent-ball scenarios (M0 EmptyPitchScenario) are covered by
// test_match_tick.cpp — snapshot() there emits exactly `slots.size()`
// entities and none has is_ball=true.

#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "physics/StubPhysics.hpp"
#include "physics/BallPhysics.hpp"
#include "scenario/Scenario.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

#include <memory>
#include <optional>
#include <string>
#include <vector>

using fh::sim::EntityState;
using fh::sim::MotionState;
using fh::sim::SlotId;
using fh::sim::awareness::WorldView;
using fh::sim::match::Match;
using fh::sim::match::MatchConfig;
using fh::sim::match::RealtimeClock;
using fh::sim::match::Snapshot;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::physics::StubPhysics;
using fh::sim::scenario::BallSpawn;
using fh::sim::scenario::PitchSpec;
using fh::sim::scenario::PlayableArea;
using fh::sim::scenario::Scenario;
using fh::sim::scenario::SlotSpawn;

namespace {

// Minimal test-file-local scenario: no player slots, optional ball spawn.
// Just enough surface for a Match to construct and tick.
class BallOnlyTestScenario : public Scenario {
public:
    explicit BallOnlyTestScenario(std::optional<BallSpawn> ball) noexcept
        : ball_(ball) {}

    std::string           id() const override            { return "test_ball_only"; }
    std::string           displayName() const override   { return "Test Ball Only"; }

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
    bool checkSuccess(const WorldView& w) const override { (void)w; return false; }
    bool checkReset  (const WorldView& w) const override { (void)w; return false; }
    std::vector<std::string> hints() const override { return {}; }

private:
    std::optional<BallSpawn> ball_;
};

std::unique_ptr<Match> makeMatch(std::optional<BallSpawn> ball,
                                 std::uint64_t seed = 42) {
    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = seed;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<BallOnlyTestScenario>(ball);
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    return std::make_unique<Match>(std::move(cfg));
}

} // namespace

// Absent-ball scenario ⇒ snapshot has zero entities and no is_ball flag
// ever appears. This locks the "nullopt is the default and it's safe" side
// of the Slice 15.2 contract — every existing M0 scenario must keep working
// with zero code changes.
FH_TEST(no_ball_snapshot_is_empty) {
    auto m = makeMatch(std::nullopt);
    m->tick();
    const Snapshot s = m->snapshot();
    FH_EXPECT_EQ(s.entities.size(), 0u);
}

// Ball spawn ⇒ snapshot contains exactly one SnapshotEntity with
// is_ball=true, slot_id=0, active=true, human_controlled=false.
FH_TEST(ball_spawn_creates_one_ball_entity) {
    BallSpawn bs;
    bs.position = Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()};
    bs.velocity = Vec3{};
    auto m = makeMatch(bs);
    const Snapshot s = m->snapshot();
    FH_EXPECT_EQ(s.entities.size(), 1u);
    FH_EXPECT(s.entities[0].flags.is_ball);
    FH_EXPECT(!s.entities[0].flags.human_controlled);
    FH_EXPECT(s.entities[0].flags.active);
    FH_EXPECT_EQ(s.entities[0].state.slot_id, SlotId{0});
}

// After one tick, a ball with 10 m/s along +x should:
//   - have velocity decayed by exactly kDefaultBallDecayPerTick
//   - have position advanced by decayed_velocity * dt (where dt = 1/20 s)
// This locks the ORDER: friction runs BEFORE integration, so the
// integrator sees the decayed velocity (not the pre-decay value).
FH_TEST(ball_velocity_decays_then_integrates_position) {
    BallSpawn bs;
    bs.position = Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()};
    bs.velocity = Vec3{Fixed64::fromInt(10), Fixed64::zero(), Fixed64::zero()};
    auto m = makeMatch(bs);

    m->tick();

    const Snapshot s = m->snapshot();
    FH_EXPECT_EQ(s.entities.size(), 1u);

    const EntityState& b = s.entities[0].state;

    // Expected velocity: 10 * (49/50)
    const Fixed64 expected_v =
        Fixed64::fromInt(10) * fh::sim::physics::kDefaultBallDecayPerTick;
    FH_EXPECT_EQ(b.velocity.x, expected_v);

    // Expected position: 0 + expected_v * (1/20 s)
    const Fixed64 dt = Fixed64::fromFraction(1, 20);
    FH_EXPECT_EQ(b.position.x, expected_v * dt);
    FH_EXPECT_EQ(b.position.y, Fixed64::zero());
    FH_EXPECT_EQ(b.position.z, Fixed64::zero());
}

// Ball at rest with zero initial velocity stays at (0,0,0) indefinitely.
// Locks the "no NaN, no drift" invariant under many ticks.
FH_TEST(stationary_ball_never_drifts) {
    BallSpawn bs;
    bs.position = Vec3{};
    bs.velocity = Vec3{};
    auto m = makeMatch(bs);

    for (int i = 0; i < 200; ++i) {
        m->tick();
    }

    const Snapshot s = m->snapshot();
    FH_EXPECT_EQ(s.entities.size(), 1u);
    const EntityState& b = s.entities[0].state;
    FH_EXPECT_EQ(b.position.x, Fixed64::zero());
    FH_EXPECT_EQ(b.position.y, Fixed64::zero());
    FH_EXPECT_EQ(b.position.z, Fixed64::zero());
    FH_EXPECT_EQ(b.velocity.x, Fixed64::zero());
    FH_EXPECT_EQ(b.velocity.y, Fixed64::zero());
    FH_EXPECT_EQ(b.velocity.z, Fixed64::zero());
}

// Rolling ball eventually snaps to rest via BallPhysics's threshold branch,
// and after that both velocity and position freeze. Guards against the
// integrator continuing to add a sub-threshold velocity forever.
FH_TEST(rolling_ball_eventually_freezes) {
    BallSpawn bs;
    bs.position = Vec3{};
    bs.velocity = Vec3{Fixed64::fromInt(5), Fixed64::zero(), Fixed64::zero()};
    auto m = makeMatch(bs);

    // 20 s of ticks is well beyond the 15 s ceiling proven in test_ball_physics.
    for (int i = 0; i < 400; ++i) {
        m->tick();
    }

    const Snapshot s1 = m->snapshot();
    const EntityState frozen = s1.entities[0].state;
    FH_EXPECT_EQ(frozen.velocity.x, Fixed64::zero());

    // 20 more ticks, nothing should change.
    for (int i = 0; i < 20; ++i) { m->tick(); }
    const Snapshot s2 = m->snapshot();
    FH_EXPECT_EQ(s2.entities[0].state.position.x, frozen.position.x);
    FH_EXPECT_EQ(s2.entities[0].state.velocity.x, Fixed64::zero());
}

// ---------------------------------------------------------------------------
// Slice 16.4: Match::end() halts ticks AND clears ball ownership so the
// wire trailer emitted after end() reports a loose ball.
// ---------------------------------------------------------------------------

FH_TEST(match_end_stops_further_ticks_and_clears_ball_owner) {
    BallSpawn bs;
    bs.position = Vec3{};
    bs.velocity = Vec3{Fixed64::fromInt(2), Fixed64::zero(), Fixed64::zero()};
    auto m = makeMatch(bs);

    // Tick once so the ball advances.
    m->tick();
    const Snapshot pre = m->snapshot();
    const Fixed64 pre_x = pre.entities[0].state.position.x;

    m->end();
    FH_EXPECT(m->ended());

    // Snapshot immediately after end() must have ball_owner = nullopt
    // (Match::ball_owner_ cleared). This is the "match end" release
    // condition per §23.3 Slice 16.4.
    const Snapshot post = m->snapshot();
    FH_EXPECT(!post.ball_owner.has_value());

    // Additional ticks after end() must be no-ops — ball position
    // frozen at whatever end() saw.
    for (int i = 0; i < 5; ++i) { m->tick(); }
    const Snapshot post_more = m->snapshot();
    FH_EXPECT_EQ(post_more.entities[0].state.position.x, pre_x);
}

FH_TEST(match_end_is_idempotent) {
    BallSpawn bs;
    bs.position = Vec3{};
    bs.velocity = Vec3{};
    auto m = makeMatch(bs);

    m->end();
    m->end();   // must not throw / crash / do anything visible.
    FH_EXPECT(m->ended());
    FH_EXPECT(!m->snapshot().ball_owner.has_value());
}

FH_TEST_MAIN()
