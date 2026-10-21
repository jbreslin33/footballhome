// footballhome sim - Match profile wiring regression test

#include "common/M0Attributes.hpp"
#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "persistence/InMemoryPgClient.hpp"
#include "persistence/ProfileStore.hpp"
#include "physics/StubPhysics.hpp"
#include "scenario/OneVsOneAttackDefendScenario.hpp"
#include "test_harness.hpp"

#include <algorithm>
#include <memory>

using fh::sim::PersonId;
using fh::sim::math::Fixed64;
using fh::sim::match::Match;
using fh::sim::match::MatchConfig;
using fh::sim::match::RealtimeClock;
using fh::sim::persistence::InMemoryPgClient;
using fh::sim::persistence::ProfileStore;
using fh::sim::physics::StubPhysics;
using fh::sim::scenario::OneVsOneAttackDefendScenario;

FH_TEST(ai_profile_source_populates_ai_slot_profile_at_spawn)
{
    InMemoryPgClient db;
    ProfileStore profile_store(db);

    fh::sim::profile::PlayerProfile source_profile;
    source_profile.physical.set(fh::sim::m0::kMaxWalkSpeed,
                                Fixed64::fromInt(3));
    source_profile.concepts.plug(fh::sim::m0::kRunToPoint,
                                 Fixed64::fromDouble(0.5));
    profile_store.save(PersonId{42}, source_profile);

    MatchConfig cfg;
    cfg.physics = std::make_unique<StubPhysics>();
    cfg.scenario = std::make_unique<OneVsOneAttackDefendScenario>(PersonId{42});
    cfg.clock = std::make_unique<RealtimeClock>(20);
    cfg.profile_store = &profile_store;

    Match match(std::move(cfg));

    const auto& slots = match.slots();
    const auto defender_it = std::find_if(slots.begin(), slots.end(),
                                          [](const auto& slot) {
                                              return slot.slot_id == fh::sim::SlotId{2};
                                          });
    FH_EXPECT(defender_it != slots.end());
    FH_EXPECT_EQ(defender_it->profile.physical.get(fh::sim::m0::kMaxWalkSpeed,
                                                    Fixed64::zero()),
                 Fixed64::fromInt(3));
    FH_EXPECT(defender_it->profile.concepts.has(fh::sim::m0::kRunToPoint,
                                                Fixed64::zero()));
}

FH_TEST_MAIN()
