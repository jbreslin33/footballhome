// footballhome sim - RecognitionSystem M0 identity pass-through tests
//
// M0 exit criterion: RecognitionSystem::apply is an identity copy of
// WorldView into AwarenessView, with recognized_patterns always empty
// regardless of what's in the perceiver's PlayerProfile.
//
// This test locks that invariant in so we don't accidentally start filtering
// entities before M4.

#include "awareness/RecognitionSystem.hpp"
#include "awareness/AwarenessView.hpp"
#include "common/EntityState.hpp"
#include "math/Fixed64.hpp"
#include "profile/PlayerProfile.hpp"
#include "registry/PatternRegistry.hpp"
#include "test_harness.hpp"

using fh::sim::EntityId;
using fh::sim::MotionState;
using fh::sim::PatternId;
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::awareness::AwarenessView;
using fh::sim::awareness::RecognitionSystem;
using fh::sim::awareness::WorldView;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::profile::PlayerProfile;
using fh::sim::registry::PatternRegistry;

namespace {

WorldView make_world_with_two_players()
{
    WorldView w;
    w.tick         = TickNum{7};
    w.time_seconds = Fixed64::fromDouble(0.35);

    fh::sim::EntityState a;
    a.id       = EntityId{1};
    a.position = Vec3{Fixed64::fromDouble(1.0),
                      Fixed64::fromDouble(2.0),
                      Fixed64::zero()};
    a.velocity = Vec3{Fixed64::fromDouble(0.5),
                      Fixed64::zero(),
                      Fixed64::zero()};
    a.heading  = Fixed64::zero();
    a.motion   = MotionState::Jog;

    fh::sim::EntityState b;
    b.id       = EntityId{2};
    b.position = Vec3{Fixed64::fromDouble(-3.0),
                      Fixed64::fromDouble(1.0),
                      Fixed64::zero()};
    b.velocity = Vec3{Fixed64::zero(),
                      Fixed64::zero(),
                      Fixed64::zero()};
    b.motion   = MotionState::Idle;

    w.entities = {a, b};
    w.ball     = std::nullopt;   // no ball in M0
    return w;
}

} // namespace

FH_TEST(recognition_pass_through_copies_tick_and_time)
{
    RecognitionSystem sys;
    const WorldView w = make_world_with_two_players();
    const PlayerProfile profile{};
    const AwarenessView av = sys.apply(w, profile, SlotId{0});

    FH_EXPECT_EQ(av.tick, w.tick);
    FH_EXPECT_EQ(av.time_seconds.raw, w.time_seconds.raw);
}

FH_TEST(recognition_pass_through_copies_all_entities)
{
    RecognitionSystem sys;
    const WorldView w = make_world_with_two_players();
    const PlayerProfile profile{};
    const AwarenessView av = sys.apply(w, profile, SlotId{0});

    FH_EXPECT_EQ(av.entities.size(), w.entities.size());
    for (std::size_t i = 0; i < w.entities.size(); ++i) {
        FH_EXPECT_EQ(av.entities[i].id, w.entities[i].id);
        FH_EXPECT_EQ(av.entities[i].position.x.raw,
                     w.entities[i].position.x.raw);
        FH_EXPECT_EQ(av.entities[i].position.y.raw,
                     w.entities[i].position.y.raw);
        FH_EXPECT_EQ(av.entities[i].velocity.x.raw,
                     w.entities[i].velocity.x.raw);
        FH_EXPECT(av.entities[i].motion == w.entities[i].motion);
    }
}

FH_TEST(recognition_pass_through_ball_optional_matches)
{
    RecognitionSystem sys;
    const WorldView w = make_world_with_two_players();
    const AwarenessView av = sys.apply(w, PlayerProfile{}, SlotId{0});
    FH_EXPECT(!av.ball.has_value());
    FH_EXPECT_EQ(av.ball.has_value(), w.ball.has_value());
}

FH_TEST(recognition_pass_through_recognized_patterns_always_empty_in_M0)
{
    // Even if a PatternRegistry has entries AND the perceiver has recognition
    // skill for one of them, M0 must NOT populate recognized_patterns.
    // (M4 flips this — this test will need updating then.)
    PatternRegistry patterns;
    patterns.addEntry(1, "pattern_2v1_defender", "defensive_read");

    PlayerProfile profile;
    profile.recognition.set(PatternId{1}, Fixed64::fromDouble(1.0));

    RecognitionSystem sys{patterns};
    const AwarenessView av = sys.apply(make_world_with_two_players(),
                                       profile, SlotId{0});
    FH_EXPECT(av.recognized_patterns.empty());
}

FH_TEST_MAIN()
