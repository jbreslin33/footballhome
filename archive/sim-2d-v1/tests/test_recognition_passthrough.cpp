// footballhome sim - RecognitionSystem M0 identity pass-through tests
//
// M0 exit criterion: RecognitionSystem::apply is an identity copy of
// WorldView into AwarenessView. Slice 33.3 adds the first explicit pattern
// recognizer without changing the entity pass-through contract.
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

#include <algorithm>

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
    a.slot_id  = SlotId{1};
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
    b.slot_id  = SlotId{2};
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

WorldView make_one_v_one_world(TickNum tick, const Vec3& carrier_velocity)
{
    WorldView world;
    world.tick = tick;
    world.time_seconds = Fixed64::zero();
    world.ball_owner = SlotId{1};

    fh::sim::EntityState carrier;
    carrier.id       = EntityId{10};
    carrier.slot_id  = SlotId{1};
    carrier.position = Vec3{Fixed64::zero(), Fixed64::zero(), Fixed64::zero()};
    carrier.velocity = carrier_velocity;
    carrier.motion   = MotionState::Jog;

    fh::sim::EntityState defender;
    defender.id       = EntityId{11};
    defender.slot_id  = SlotId{2};
    defender.position = Vec3{Fixed64::fromInt(2), Fixed64::zero(), Fixed64::zero()};
    defender.velocity = Vec3{};
    defender.motion   = MotionState::Jog;

    world.entities = {carrier, defender};
    return world;
}

PlayerProfile profileWithBeatRecognition(PatternId pattern_id)
{
    PlayerProfile profile;
    profile.recognition.set(pattern_id, Fixed64::one());
    return profile;
}

bool containsPattern(const AwarenessView& view, PatternId pattern_id)
{
    return std::find(view.recognized_patterns.begin(),
                     view.recognized_patterns.end(),
                     pattern_id) != view.recognized_patterns.end();
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

FH_TEST(recognition_pass_through_recognized_patterns_empty_without_matching_world_state)
{
    // Even with a PatternRegistry entry and recognition skill, no pattern
    // fires unless the corresponding world-state predicate is true.
    PatternRegistry patterns;
    patterns.addEntry(1, "pattern_2v1_defender", "defensive_read");

    PlayerProfile profile;
    profile.recognition.set(PatternId{1}, Fixed64::fromDouble(1.0));

    RecognitionSystem sys{patterns};
    const AwarenessView av = sys.apply(make_world_with_two_players(),
                                       profile, SlotId{0});
    FH_EXPECT(av.recognized_patterns.empty());
}

FH_TEST(pattern_being_beaten_1v1_fires_on_nearby_carrier_reversal)
{
    PatternRegistry patterns;
    patterns.addEntry(1, "pattern_being_beaten_1v1", "defensive_read");

    RecognitionSystem sys{patterns};
    const PlayerProfile profile = profileWithBeatRecognition(PatternId{1});

    const AwarenessView first = sys.apply(
        make_one_v_one_world(TickNum{0}, Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()}),
        profile,
        SlotId{2});
    FH_EXPECT(first.recognized_patterns.empty());

    const AwarenessView second = sys.apply(
        make_one_v_one_world(TickNum{1}, Vec3{-Fixed64::one(), Fixed64::zero(), Fixed64::zero()}),
        profile,
        SlotId{2});
    FH_EXPECT(containsPattern(second, PatternId{1}));
}

FH_TEST(pattern_being_beaten_1v1_requires_recognition_skill)
{
    PatternRegistry patterns;
    patterns.addEntry(1, "pattern_being_beaten_1v1", "defensive_read");

    RecognitionSystem sys{patterns};
    const PlayerProfile profile{};

    (void)sys.apply(
        make_one_v_one_world(TickNum{0}, Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()}),
        profile,
        SlotId{2});
    const AwarenessView second = sys.apply(
        make_one_v_one_world(TickNum{1}, Vec3{-Fixed64::one(), Fixed64::zero(), Fixed64::zero()}),
        profile,
        SlotId{2});
    FH_EXPECT(second.recognized_patterns.empty());
}

FH_TEST(pattern_being_beaten_1v1_requires_nearby_non_owner)
{
    PatternRegistry patterns;
    patterns.addEntry(1, "pattern_being_beaten_1v1", "defensive_read");

    RecognitionSystem sys{patterns};
    const PlayerProfile profile = profileWithBeatRecognition(PatternId{1});

    (void)sys.apply(
        make_one_v_one_world(TickNum{0}, Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()}),
        profile,
        SlotId{2});

    WorldView far_world = make_one_v_one_world(
        TickNum{1}, Vec3{-Fixed64::one(), Fixed64::zero(), Fixed64::zero()});
    far_world.entities[1].position = Vec3{Fixed64::fromInt(4), Fixed64::zero(), Fixed64::zero()};
    const AwarenessView far_view = sys.apply(far_world, profile, SlotId{2});
    FH_EXPECT(far_view.recognized_patterns.empty());

    const AwarenessView owner_view = sys.apply(far_world, profile, SlotId{1});
    FH_EXPECT(owner_view.recognized_patterns.empty());
}

FH_TEST_MAIN()
