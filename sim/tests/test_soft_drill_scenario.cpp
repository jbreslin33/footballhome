// footballhome sim - SoftDrillScenario unit test (Slice 17.5)
//
// Verifies the declarative shape of the scenario:
//   - id / display / pitch dimensions
//   - Playable area: rectangle at (-20..+20, -15..+15), Soft mode
//   - One SlotSpawn (slot 1) at the drill-zone centre
//   - No ballSpawn
//
// Also runs a Match against it to confirm Slice 17.3 wiring holds in
// Soft mode: a slot spawned inside the drill zone spends most of its
// time inside despite wander drift (soft pushback keeps it herded),
// and a slot forcibly translated OUTSIDE via physics_for_tests()
// setPosition is bounced back inside within a few ticks by the
// accumulating inward velocity delta.

#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "physics/StubPhysics.hpp"
#include "scenario/SoftDrillScenario.hpp"
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
using fh::sim::scenario::PlayableArea;
using fh::sim::scenario::SoftDrillScenario;

namespace {

// Polygon-membership predicate matching SoftDrillScenario's declared
// rectangle. Point is inside if x ∈ [-20, +20] and y ∈ [-15, +15].
bool insideDrillZone(const Vec3& p)
{
    return p.x.raw >= Fixed64::fromInt(-20).raw
        && p.x.raw <= Fixed64::fromInt( 20).raw
        && p.y.raw >= Fixed64::fromInt(-15).raw
        && p.y.raw <= Fixed64::fromInt( 15).raw;
}

std::unique_ptr<Match> makeMatch(std::uint64_t seed = 42)
{
    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = seed;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<SoftDrillScenario>();
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
    SoftDrillScenario s;
    FH_EXPECT(s.id() == "soft_drill");
    FH_EXPECT_EQ(s.pitch().length_m, Fixed64::fromInt(105));
    FH_EXPECT_EQ(s.pitch().width_m,  Fixed64::fromInt(68));
}

FH_TEST(playable_area_is_soft_mode_drill_zone_rectangle) {
    SoftDrillScenario s;
    const auto a = s.playableArea();
    FH_EXPECT(a.constraint_mode == PlayableArea::Mode::Soft);
    FH_EXPECT_EQ(a.polygon.size(), 4u);
    // CCW rectangle: (-20,-15) → (+20,-15) → (+20,+15) → (-20,+15).
    FH_EXPECT_EQ(a.polygon[0].x, Fixed64::fromInt(-20));
    FH_EXPECT_EQ(a.polygon[0].y, Fixed64::fromInt(-15));
    FH_EXPECT_EQ(a.polygon[1].x, Fixed64::fromInt( 20));
    FH_EXPECT_EQ(a.polygon[1].y, Fixed64::fromInt(-15));
    FH_EXPECT_EQ(a.polygon[2].x, Fixed64::fromInt( 20));
    FH_EXPECT_EQ(a.polygon[2].y, Fixed64::fromInt( 15));
    FH_EXPECT_EQ(a.polygon[3].x, Fixed64::fromInt(-20));
    FH_EXPECT_EQ(a.polygon[3].y, Fixed64::fromInt( 15));
}

FH_TEST(scenario_spawns_one_slot_at_drill_zone_centre) {
    SoftDrillScenario s;
    const auto spawns = s.initialSpawns();
    FH_EXPECT_EQ(spawns.size(), 1u);
    FH_EXPECT(spawns[0].slot == SlotId{1});
    FH_EXPECT_EQ(spawns[0].position.x, Fixed64::zero());
    FH_EXPECT_EQ(spawns[0].position.y, Fixed64::zero());
    FH_EXPECT(insideDrillZone(spawns[0].position));
}

FH_TEST(scenario_has_no_ball_spawn) {
    SoftDrillScenario s;
    FH_EXPECT(!s.ballSpawn().has_value());
}

// ---------------------------------------------------------------------------
// Integration: Soft mode lets a slot briefly leave the drill zone but
// bounces it back within a small number of ticks. Poke slot 1 out to
// (50, 0) — 30 m east of the +20 boundary — then tick many times and
// assert it lands back inside eventually.
// ---------------------------------------------------------------------------

FH_TEST(forced_out_of_bounds_slot_bounces_back_within_100_ticks) {
    auto m = makeMatch();
    m->tick();   // one baseline tick

    const auto& slots = m->slots();
    const auto entity = slots.front().entity;

    // Poke slot 1 to x = 50 m (30 m east of the +20 boundary). Soft
    // pushback should bounce it back in within ~1-2 s at 20 Hz.
    m->physics_for_tests()->setPosition(
        entity, Vec3{Fixed64::fromInt(50),
                     Fixed64::zero(),
                     Fixed64::zero()});

    // First tick after the poke: the slot is still outside (Soft mode
    // never clamps position — it only nudges velocity). This locks in
    // the "not a Hard clamp in disguise" invariant.
    m->tick();
    {
        const Vec3 p = slotPosition(m->snapshot(), SlotId{1});
        FH_EXPECT(!insideDrillZone(p));
    }

    // Give the spring up to 100 ticks (5 s at 20 Hz) to drag the slot
    // back inside.
    bool bounced_back = false;
    for (int i = 0; i < 100; ++i) {
        m->tick();
        const Vec3 p = slotPosition(m->snapshot(), SlotId{1});
        if (insideDrillZone(p)) {
            bounced_back = true;
            break;
        }
    }
    FH_EXPECT(bounced_back);
}

FH_TEST_MAIN()
