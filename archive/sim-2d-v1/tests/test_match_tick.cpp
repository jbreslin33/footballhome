// footballhome sim - end-to-end Match tick smoke test
//
// Wires StubPhysics + EmptyPitchScenario + RealtimeClock into a Match,
// ticks it a bunch, and verifies:
//   - all scenario slots are spawned
//   - snapshot reflects state
//   - claim/release swaps controllers correctly
//   - human input flows through decide()

#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "physics/StubPhysics.hpp"
#include "scenario/EmptyPitchScenario.hpp"
#include "controller/Intent.hpp"
#include "common/M0Attributes.hpp"
#include "math/Fixed64.hpp"
#include "profile/PlayerProfile.hpp"
#include "test_harness.hpp"

#include <memory>

using fh::sim::ClientId;
using fh::sim::PersonId;
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::controller::Intent;
using fh::sim::match::Match;
using fh::sim::match::MatchConfig;
using fh::sim::match::RealtimeClock;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::physics::StubPhysics;
using fh::sim::scenario::EmptyPitchScenario;

namespace {

// Build the M0 baseline profile used by every test that just needs a
// "generic human player" for a slot claim. Uses the sanctioned default
// values from M0Attributes.cpp (§22.11).
fh::sim::profile::PlayerProfile makeDefaultProfile()
{
    fh::sim::profile::PlayerProfile p;
    p.physical = fh::sim::m0::defaultPhysical();
    p.concepts = fh::sim::m0::defaultConcepts();
    return p;
}

} // namespace

namespace {

std::unique_ptr<Match> makeMatch(std::uint64_t seed = 42) {
    MatchConfig cfg;
    cfg.id       = 1;
    cfg.seed     = seed;
    cfg.physics  = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<EmptyPitchScenario>();
    cfg.clock    = std::make_unique<RealtimeClock>(20);
    return std::make_unique<Match>(std::move(cfg));
}

} // namespace

FH_TEST(match_spawns_all_scenario_slots) {
    auto m = makeMatch();
    FH_EXPECT_EQ(m->slots().size(), 12u);
    const auto snap = m->snapshot();
    FH_EXPECT_EQ(snap.entities.size(), 12u);
}

FH_TEST(match_advances_tick_counter) {
    auto m = makeMatch();
    FH_EXPECT_EQ(m->tick_num(), TickNum{0});
    m->tick();
    FH_EXPECT_EQ(m->tick_num(), TickNum{1});
    for (int i = 0; i < 39; ++i) m->tick();
    FH_EXPECT_EQ(m->tick_num(), TickNum{40});
}

FH_TEST(claim_slot_makes_it_human_owned) {
    auto m = makeMatch();
    m->claimSlot(SlotId{3}, ClientId{999}, PersonId{999}, makeDefaultProfile());
    const auto snap = m->snapshot();
    bool found = false;
    for (const auto& e : snap.entities) {
        if (e.state.slot_id == SlotId{3}) {
            FH_EXPECT(e.flags.human_controlled);
            found = true;
        } else {
            FH_EXPECT(!e.flags.human_controlled);
        }
    }
    FH_EXPECT(found);
}

FH_TEST(claim_release_reverts_to_ai) {
    auto m = makeMatch();
    m->claimSlot(SlotId{5}, ClientId{1}, PersonId{1}, makeDefaultProfile());
    m->releaseSlot(SlotId{5});
    const auto snap = m->snapshot();
    for (const auto& e : snap.entities) {
        FH_EXPECT(!e.flags.human_controlled);
    }
}

FH_TEST(human_input_moves_entity) {
    auto m = makeMatch();
    m->claimSlot(SlotId{1}, ClientId{1}, PersonId{1}, makeDefaultProfile());

    // Send east-ward sprint intent.
    Intent in;
    in.desired_direction = Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    in.wants_sprint = true;
    m->applyInput(ClientId{1}, in);

    // Capture starting position.
    const auto snap0 = m->snapshot();
    Fixed64 x0{};
    for (const auto& e : snap0.entities) {
        if (e.state.slot_id == SlotId{1}) x0 = e.state.position.x;
    }

    // Tick 20 times (1 s).
    for (int i = 0; i < 20; ++i) m->tick();

    const auto snap1 = m->snapshot();
    Fixed64 x1{};
    for (const auto& e : snap1.entities) {
        if (e.state.slot_id == SlotId{1}) x1 = e.state.position.x;
    }
    FH_EXPECT(x1 > x0);
}

FH_TEST(deterministic_from_same_seed) {
    auto a = makeMatch(12345);
    auto b = makeMatch(12345);
    for (int i = 0; i < 40; ++i) { a->tick(); b->tick(); }
    const auto sa = a->snapshot();
    const auto sb = b->snapshot();
    FH_EXPECT_EQ(sa.entities.size(), sb.entities.size());
    for (std::size_t i = 0; i < sa.entities.size(); ++i) {
        FH_EXPECT_EQ(sa.entities[i].state.position.x, sb.entities[i].state.position.x);
        FH_EXPECT_EQ(sa.entities[i].state.position.y, sb.entities[i].state.position.y);
        FH_EXPECT_EQ(sa.entities[i].state.heading,    sb.entities[i].state.heading);
    }
}

FH_TEST_MAIN()
