// footballhome sim - HalfPitchScenario unit test (Slice 17.4)
//
// Verifies the declarative shape of the scenario:
//   - id / display / pitch dimensions
//   - Playable area: rectangle at (0..52.5, -34..+34), Hard mode
//   - Two SlotSpawns (slots 1 & 2), both inside the polygon
//   - No ballSpawn (M1 half-pitch drill has no ball)
//
// Also runs a Match against it to confirm Slice 17.3 wiring holds: a
// slot spawned inside the polygon stays inside across 100 ticks of
// WanderController drift, and a slot pre-translated OUTSIDE the polygon
// (via forced physics setPosition) is snapped back on the very next
// tick. This is the integration-level "Hard mode actually works with a
// real scenario" check that DESIGN.md §23.3 Slice 17.4 asks for.

#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "physics/StubPhysics.hpp"
#include "scenario/HalfPitchScenario.hpp"
#include "math/Fixed64.hpp"
#include "test_harness.hpp"

#include <memory>

using fh::sim::EntityState;
using fh::sim::SlotId;
using fh::sim::match::Match;
using fh::sim::match::MatchConfig;
using fh::sim::match::RealtimeClock;
using fh::sim::match::Snapshot;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::physics::StubPhysics;
using fh::sim::scenario::HalfPitchScenario;
using fh::sim::scenario::PlayableArea;

namespace {

// Polygon-membership predicate matching HalfPitchScenario's declared
// rectangle. Point is considered inside if x ∈ [0, 52.5] and
// y ∈ [-34, +34]. Uses raw comparisons — no floats.
bool insideHalfPitch(const Vec3& p)
{
    const auto x_max_raw = Fixed64::fromFraction(105, 2).raw;
    return p.x.raw >= Fixed64::zero().raw
        && p.x.raw <= x_max_raw
        && p.y.raw >= Fixed64::fromInt(-34).raw
        && p.y.raw <= Fixed64::fromInt( 34).raw;
}

std::unique_ptr<Match> makeMatch(std::uint64_t seed = 42)
{
    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = seed;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<HalfPitchScenario>();
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    return std::make_unique<Match>(std::move(cfg));
}

Vec3 slotPosition(const Snapshot& snap, SlotId slot)
{
    for (const auto& e : snap.entities) {
        if (e.state.slot_id == slot) { return e.state.position; }
    }
    return Vec3{};
}

} // namespace

// ---------------------------------------------------------------------------
// Declarative surface: id, pitch, playable-area shape and mode, spawns.
// ---------------------------------------------------------------------------

FH_TEST(scenario_reports_correct_id_and_pitch) {
    HalfPitchScenario s;
    FH_EXPECT(s.id() == "half_pitch_hard");
    FH_EXPECT_EQ(s.pitch().length_m, Fixed64::fromInt(105));
    FH_EXPECT_EQ(s.pitch().width_m,  Fixed64::fromInt(68));
}

FH_TEST(playable_area_is_hard_mode_east_half_rectangle) {
    HalfPitchScenario s;
    const auto a = s.playableArea();
    FH_EXPECT(a.constraint_mode == PlayableArea::Mode::Hard);
    FH_EXPECT_EQ(a.polygon.size(), 4u);
    // CCW rectangle: (0,-34) → (52.5,-34) → (52.5,+34) → (0,+34).
    FH_EXPECT_EQ(a.polygon[0].x, Fixed64::zero());
    FH_EXPECT_EQ(a.polygon[0].y, Fixed64::fromInt(-34));
    FH_EXPECT_EQ(a.polygon[1].x, Fixed64::fromFraction(105, 2));
    FH_EXPECT_EQ(a.polygon[1].y, Fixed64::fromInt(-34));
    FH_EXPECT_EQ(a.polygon[2].x, Fixed64::fromFraction(105, 2));
    FH_EXPECT_EQ(a.polygon[2].y, Fixed64::fromInt( 34));
    FH_EXPECT_EQ(a.polygon[3].x, Fixed64::zero());
    FH_EXPECT_EQ(a.polygon[3].y, Fixed64::fromInt( 34));
}

FH_TEST(scenario_spawns_two_slots_inside_playable_area) {
    HalfPitchScenario s;
    const auto spawns = s.initialSpawns();
    FH_EXPECT_EQ(spawns.size(), 2u);
    FH_EXPECT(spawns[0].slot == SlotId{1});
    FH_EXPECT(spawns[1].slot == SlotId{2});
    FH_EXPECT(insideHalfPitch(spawns[0].position));
    FH_EXPECT(insideHalfPitch(spawns[1].position));
}

FH_TEST(scenario_has_no_ball_spawn) {
    HalfPitchScenario s;
    FH_EXPECT(!s.ballSpawn().has_value());
}

// ---------------------------------------------------------------------------
// Integration: Match + HalfPitchScenario keeps slots inside across many
// ticks (Hard clamp gated on Mode::Hard fires every tick).
// ---------------------------------------------------------------------------

FH_TEST(slots_stay_inside_playable_area_across_many_ticks) {
    auto m = makeMatch();
    for (int i = 0; i < 100; ++i) {
        m->tick();
        const auto snap = m->snapshot();
        const Vec3 p1 = slotPosition(snap, SlotId{1});
        const Vec3 p2 = slotPosition(snap, SlotId{2});
        FH_EXPECT(insideHalfPitch(p1));
        FH_EXPECT(insideHalfPitch(p2));
    }
}

// If we forcibly push a slot outside the polygon between ticks, the next
// Match::tick's Hard pass must snap it back inside on that very tick.
// This proves the wiring isn't a one-shot "clamp at spawn" — it runs
// every step.
FH_TEST(forced_out_of_bounds_slot_is_snapped_back_next_tick) {
    auto m = makeMatch();
    m->tick();   // one baseline tick

    // Locate slot 1's entity, then poke its position to (100, 0, 0) —
    // way east of x_max = 52.5. Use the test-only physics accessor.
    const auto& slots = m->slots();
    const auto entity = slots.front().entity;
    m->physics_for_tests()->setPosition(
        entity, Vec3{Fixed64::fromInt(100),
                     Fixed64::zero(),
                     Fixed64::zero()});

    // Next tick: Hard pass must snap it back inside.
    m->tick();
    const Vec3 p = slotPosition(m->snapshot(), SlotId{1});
    FH_EXPECT(insideHalfPitch(p));
}

FH_TEST_MAIN()
