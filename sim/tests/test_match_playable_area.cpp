// footballhome sim - Match + PlayableArea wiring test (Slice 17.3)
//
// Verifies that Match correctly delegates to
// `physics::apply_hard` / `physics::apply_soft` when the scenario's
// `playableArea().constraint_mode` selects them, and no-ops (preserving
// the M0/M1 canonical hash) for `Mode::Advisory`.
//
// See DESIGN.md §23.3 Slice 17.3.

#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "physics/StubPhysics.hpp"
#include "scenario/Scenario.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

#include <memory>
#include <optional>
#include <string>
#include <vector>

using fh::sim::Role;
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

// 20x20 CCW square centred on origin. Interior: x,y ∈ [-10, +10].
std::vector<Vec3> ccwSquare20()
{
    return {
        Vec3{Fixed64::fromInt(-10), Fixed64::fromInt(-10), Fixed64::zero()},
        Vec3{Fixed64::fromInt( 10), Fixed64::fromInt(-10), Fixed64::zero()},
        Vec3{Fixed64::fromInt( 10), Fixed64::fromInt( 10), Fixed64::zero()},
        Vec3{Fixed64::fromInt(-10), Fixed64::fromInt( 10), Fixed64::zero()},
    };
}

// Minimal scenario: one slot spawned at a caller-supplied position
// with a caller-supplied playable-area polygon + mode. No ball, no
// success/reset conditions. Just enough surface for a Match to
// construct, tick, and snapshot.
class PlayableAreaTestScenario : public Scenario {
public:
    PlayableAreaTestScenario(std::vector<Vec3>  polygon,
                             PlayableArea::Mode mode,
                             Vec3               slot1_pos) noexcept
        : polygon_(std::move(polygon))
        , mode_(mode)
        , slot1_pos_(slot1_pos)
    {}

    std::string           id() const override
        { return "test_playable_area"; }
    std::string           displayName() const override
        { return "Test Playable Area"; }

    PitchSpec pitch() const override {
        return PitchSpec{Fixed64::fromInt(105), Fixed64::fromInt(68)};
    }
    PlayableArea playableArea() const override {
        PlayableArea a;
        a.polygon         = polygon_;
        a.constraint_mode = mode_;
        a.zoom_hint       = Fixed64::zero();
        return a;
    }
    std::vector<SlotSpawn> initialSpawns() const override {
        SlotSpawn s;
        s.slot     = SlotId{1};
        s.position = slot1_pos_;
        s.heading  = Fixed64::zero();
        s.role     = Role::Any;
        return {s};
    }
    std::optional<BallSpawn> ballSpawn() const override { return std::nullopt; }
    bool checkSuccess(const WorldView& w) const override { (void)w; return false; }
    bool checkReset  (const WorldView& w) const override { (void)w; return false; }
    std::vector<std::string> hints() const override { return {}; }

private:
    std::vector<Vec3>  polygon_;
    PlayableArea::Mode mode_;
    Vec3               slot1_pos_;
};

std::unique_ptr<Match> makeMatch(std::vector<Vec3>  polygon,
                                 PlayableArea::Mode mode,
                                 Vec3               slot1_pos,
                                 std::uint64_t      seed = 42)
{
    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = seed;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<PlayableAreaTestScenario>(
        std::move(polygon), mode, slot1_pos);
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    return std::make_unique<Match>(std::move(cfg));
}

// Find slot 1's position in the snapshot. Slot 1 is the only player
// entity in these tests (no ball).
Vec3 slot1Position(const Snapshot& snap)
{
    for (const auto& e : snap.entities) {
        if (e.state.slot_id == SlotId{1}) { return e.state.position; }
    }
    return Vec3{};
}

} // namespace

// ---------------------------------------------------------------------------
// Advisory mode is a strict no-op — a slot spawned outside the polygon
// stays outside (position is NOT clamped, no velocity delta is applied).
// This is the M0/M1 baseline invariant that keeps EmptyPitchScenario and
// BallOnPitchScenario's canonical hash unchanged after Slice 17.3 lands.
// ---------------------------------------------------------------------------

FH_TEST(advisory_mode_does_not_clamp_slot_outside_polygon) {
    // Spawn slot at (15, 0), way east of the [-10, +10] polygon.
    auto m = makeMatch(ccwSquare20(),
                       PlayableArea::Mode::Advisory,
                       Vec3{Fixed64::fromInt(15), Fixed64::zero(),
                            Fixed64::zero()});
    m->tick();
    // Slot must still be outside x > 10.
    const Vec3 p = slot1Position(m->snapshot());
    FH_EXPECT(p.x.raw > Fixed64::fromInt(10).raw);
}

// ---------------------------------------------------------------------------
// Hard mode clamps a slot spawned outside the polygon back inside on the
// very first tick's post-step pass.
// ---------------------------------------------------------------------------

FH_TEST(hard_mode_clamps_slot_outside_polygon_on_first_tick) {
    auto m = makeMatch(ccwSquare20(),
                       PlayableArea::Mode::Hard,
                       Vec3{Fixed64::fromInt(15), Fixed64::zero(),
                            Fixed64::zero()});
    m->tick();
    const Vec3 p = slot1Position(m->snapshot());
    // Post-tick position must satisfy the polygon: x ∈ [-10, +10].
    FH_EXPECT(p.x.raw <= Fixed64::fromInt(10).raw);
    FH_EXPECT(p.x.raw >= Fixed64::fromInt(-10).raw);
    // Y also inside — WanderController can drift a slot on any axis.
    FH_EXPECT(p.y.raw <= Fixed64::fromInt(10).raw);
    FH_EXPECT(p.y.raw >= Fixed64::fromInt(-10).raw);
}

FH_TEST(hard_mode_keeps_slot_inside_across_many_ticks) {
    // Slot spawns inside; wander drifts randomly. After many ticks the
    // slot must never have escaped the polygon — Hard clamps every tick.
    auto m = makeMatch(ccwSquare20(),
                       PlayableArea::Mode::Hard,
                       Vec3{Fixed64::zero(), Fixed64::zero(),
                            Fixed64::zero()});
    for (int i = 0; i < 200; ++i) {
        m->tick();
        const Vec3 p = slot1Position(m->snapshot());
        FH_EXPECT(p.x.raw <= Fixed64::fromInt(10).raw);
        FH_EXPECT(p.x.raw >= Fixed64::fromInt(-10).raw);
        FH_EXPECT(p.y.raw <= Fixed64::fromInt(10).raw);
        FH_EXPECT(p.y.raw >= Fixed64::fromInt(-10).raw);
    }
}

// ---------------------------------------------------------------------------
// Soft mode does NOT snap position on the first tick — the slot is
// allowed to briefly be outside. Over many ticks the accumulating
// inward velocity delta eventually bounces it back inside.
// ---------------------------------------------------------------------------

FH_TEST(soft_mode_does_not_snap_position_on_first_tick) {
    auto m = makeMatch(ccwSquare20(),
                       PlayableArea::Mode::Soft,
                       Vec3{Fixed64::fromInt(15), Fixed64::zero(),
                            Fixed64::zero()});
    m->tick();
    // Position is not clamped — one tick of inward velocity delta at
    // 20 Hz can shift x by at most a few metres, so x is still > 10.
    // (Sanity: k=4, penetration=5, dt=0.05 → -1 m per tick.)
    const Vec3 p = slot1Position(m->snapshot());
    // Not clamped exactly to 10: must still be strictly outside.
    FH_EXPECT(p.x.raw > Fixed64::fromInt(10).raw);
}

FH_TEST(soft_mode_eventually_pushes_slot_inside_polygon) {
    auto m = makeMatch(ccwSquare20(),
                       PlayableArea::Mode::Soft,
                       Vec3{Fixed64::fromInt(15), Fixed64::zero(),
                            Fixed64::zero()});
    // 100 ticks (5 seconds at 20 Hz) is comfortably enough for the
    // spring to overcome the 5 m initial penetration.
    for (int i = 0; i < 100; ++i) { m->tick(); }
    const Vec3 p = slot1Position(m->snapshot());
    FH_EXPECT(p.x.raw <= Fixed64::fromInt(10).raw);
}

FH_TEST_MAIN()
