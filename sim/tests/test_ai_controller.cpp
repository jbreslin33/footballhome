// footballhome sim - AiController tests (Slice 30.1)
//
// Contract:
//   1. Empty behavior bag ⇒ decide() returns idle() every tick,
//      byte-identical to the pre-Slice-30.1 M0 skeleton. This is what
//      the two-arg legacy ctor produces and what every scenario that
//      calls defaultBehaviors() gets in Slice 30.1 (behaviors arrive
//      slice-by-slice starting 30.2).
//   2. Single gated-open, positive-utility behavior in the bag ⇒
//      decide() dispatches its execute() and returns that Intent.
//   3. Concept gate is honored: a behavior whose required concepts are
//      not plugged at the required min-mastery is skipped entirely
//      (utility() is not even invoked). Absent concept + minMastery > 0
//      ⇒ skipped. Present but under threshold ⇒ skipped.
//   4. Ties broken by insertion order: two gated-open behaviors with
//      identical utility ⇒ the first one in the vector wins.
//   5. All behaviors gated shut ⇒ decide() falls through to idle().
//   6. All behaviors abstaining (utility == 0) ⇒ decide() falls through
//      to idle() (zero-utility abstention per IBehavior::utility
//      contract).
//   7. defaultBehaviors(Role) returns an empty vector for every Role
//      in Slice 30.1. This assertion is the canary that trips (loudly)
//      when Slice 30.2+ starts populating the factory.

#include "awareness/AwarenessView.hpp"
#include "behavior/IBehavior.hpp"
#include "common/EntityState.hpp"
#include "common/IdTypes.hpp"
#include "common/Role.hpp"
#include "controller/AiController.hpp"
#include "controller/Intent.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"
#include "profile/AttributeSet.hpp"
#include "profile/ConceptSet.hpp"
#include "test_harness.hpp"

#include <memory>
#include <optional>
#include <utility>
#include <vector>

using fh::sim::ConceptId;
using fh::sim::EntityId;
using fh::sim::EntityState;
using fh::sim::MotionState;
using fh::sim::Role;
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::awareness::AwarenessView;
using fh::sim::behavior::IBehavior;
using fh::sim::controller::AiController;
using fh::sim::controller::Intent;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::profile::AttributeSet;
using fh::sim::profile::ConceptSet;

namespace {

// Minimal AwarenessView with a single self-entity. Enough for
// AiController::decide() to run — the behaviors under test in this
// file don't read the view, only inspect the passed ConceptSet.
AwarenessView makeSelfOnlyView(SlotId self_slot)
{
    AwarenessView v;
    v.tick         = TickNum{0};
    v.time_seconds = Fixed64::zero();

    EntityState self{};
    self.id       = static_cast<EntityId>(self_slot + 1);
    self.slot_id  = self_slot;
    self.position = Vec3{};
    self.motion   = MotionState::Idle;
    v.entities.push_back(self);

    return v;
}

// Test-only concrete IBehavior. Records how many times each virtual is
// called via optional callback hooks so tests can assert dispatch
// occurred (or didn't).
class MockBehavior : public IBehavior {
public:
    MockBehavior(std::string_view              id,
                 std::vector<ConceptId>        required,
                 Fixed64                       min_mastery,
                 Fixed64                       fixed_utility,
                 Intent                        execute_intent,
                 TickNum                       min_ticks = TickNum{10}) noexcept
        : id_(id),
          required_(std::move(required)),
          min_mastery_(min_mastery),
          fixed_utility_(fixed_utility),
            execute_intent_(execute_intent),
            min_ticks_(min_ticks) {}

    std::vector<ConceptId> requiredConcepts() const override { return required_; }
    Fixed64                minMastery()       const override { return min_mastery_; }
        TickNum                minTicks()         const override { return min_ticks_; }

    Fixed64 utility(const AwarenessView& /*view*/,
                    SlotId               /*self*/,
                    const ConceptSet&    /*concepts*/,
                    const AttributeSet&  /*technical*/,
                    const AttributeSet&  /*mental*/,
                    std::optional<SlotId> /*mark_target*/) override
    {
        ++utility_calls_;
        return fixed_utility_;
    }

    Intent execute(const AwarenessView& /*view*/,
                   SlotId               /*self*/,
                   const ConceptSet&    /*concepts*/,
                   std::optional<SlotId> /*mark_target*/) override
    {
        ++execute_calls_;
        return execute_intent_;
    }

    const char* id() const override { return id_.data(); }

    void setUtility(Fixed64 utility) noexcept { fixed_utility_ = utility; }

    int utility_calls() const noexcept { return utility_calls_; }
    int execute_calls() const noexcept { return execute_calls_; }

private:
    std::string_view       id_;
    std::vector<ConceptId> required_;
    Fixed64                min_mastery_;
    Fixed64                fixed_utility_;
    Intent                 execute_intent_;
    TickNum                min_ticks_;
    int                    utility_calls_{0};
    int                    execute_calls_{0};
};

// Convenience: build a std::unique_ptr<MockBehavior> and return both
// the owning ptr (moved into the vector) and a raw observer ptr for
// assertions after decide() runs.
struct MockHandle {
    std::unique_ptr<MockBehavior> owned;
    MockBehavior*                 raw{nullptr};
};

MockHandle makeMock(std::string_view       id,
                    std::vector<ConceptId> required,
                    Fixed64                min_mastery,
                    Fixed64                fixed_utility,
                    Intent                 execute_intent,
                    TickNum                min_ticks = TickNum{10})
{
    auto owned = std::make_unique<MockBehavior>(
        id, std::move(required), min_mastery, fixed_utility, execute_intent, min_ticks);
    MockBehavior* raw = owned.get();
    return MockHandle{std::move(owned), raw};
}

// Helper: distinctive Intent for equality assertions. desired_direction
// magnitude != 0 distinguishes from idle().
Intent makeIntent(Fixed64 dir_x)
{
    Intent i;
    i.desired_direction = Vec3{dir_x, Fixed64::zero(), Fixed64::zero()};
    return i;
}

} // namespace

FH_TEST(default_ctor_returns_idle_forever)
{
    // Backward-compat guarantee: default ctor + no behaviors ⇒ idle().
    AiController c;
    const auto v = makeSelfOnlyView(SlotId{1});
    const Intent out = c.decide(v, SlotId{1});

    FH_EXPECT_EQ(c.behaviorCount(), 0u);
    FH_EXPECT(out.desired_direction.x == Fixed64::zero());
    FH_EXPECT(out.desired_direction.y == Fixed64::zero());
    FH_EXPECT(out.wants_dribble == false);
    FH_EXPECT(out.wants_to_press == false);
    FH_EXPECT(out.wants_kick == false);
}

FH_TEST(two_arg_legacy_ctor_returns_idle)
{
    // The two-arg ctor is used by every pre-Slice-30.1 call site. It
    // must produce the same behavior as the default ctor plus an empty
    // behaviors bag — anything else silently rotates a determinism
    // golden.
    ConceptSet concepts;
    concepts.plug(ConceptId{1}, Fixed64::fromFloat(0.8f));

    AiController c(Role::Any, std::move(concepts));
    const auto v = makeSelfOnlyView(SlotId{1});
    const Intent out = c.decide(v, SlotId{1});

    FH_EXPECT_EQ(c.behaviorCount(), 0u);
    FH_EXPECT(out.desired_direction.x == Fixed64::zero());
    FH_EXPECT(out.desired_direction.y == Fixed64::zero());
}

FH_TEST(single_gated_open_behavior_dispatches)
{
    // One behavior; concept plugged at mastery ≥ minMastery; positive
    // utility ⇒ execute() runs, return value flows out of decide().
    auto mock = makeMock(
        "mock_press",
        /*required=*/{ConceptId{1}},
        /*min_mastery=*/Fixed64::fromFloat(0.1f),
        /*fixed_utility=*/Fixed64::fromFloat(0.75f),
        /*execute_intent=*/makeIntent(Fixed64::fromFloat(0.5f)));
    MockBehavior* raw = mock.raw;

    ConceptSet concepts;
    concepts.plug(ConceptId{1}, Fixed64::fromFloat(0.8f));

    std::vector<std::unique_ptr<IBehavior>> bag;
    bag.emplace_back(std::move(mock.owned));

    AiController c(Role::Any, std::move(concepts), std::move(bag));
    const auto v = makeSelfOnlyView(SlotId{1});
    const Intent out = c.decide(v, SlotId{1});

    FH_EXPECT_EQ(c.behaviorCount(), 1u);
    FH_EXPECT_EQ(raw->utility_calls(), 1);
    FH_EXPECT_EQ(raw->execute_calls(), 1);
    FH_EXPECT(out.desired_direction.x == Fixed64::fromFloat(0.5f));
}

FH_TEST(gate_closed_by_missing_concept_skips_behavior)
{
    // Behavior requires ConceptId{2} at minMastery 0.5; ConceptSet has
    // ConceptId{1} but not {2} ⇒ ConceptSet::has returns false ⇒
    // utility() is never invoked ⇒ decide() falls through to idle().
    auto mock = makeMock(
        "mock_needs_absent_concept",
        /*required=*/{ConceptId{2}},
        /*min_mastery=*/Fixed64::fromFloat(0.5f),
        /*fixed_utility=*/Fixed64::fromFloat(0.99f),
        /*execute_intent=*/makeIntent(Fixed64::fromFloat(1.0f)));
    MockBehavior* raw = mock.raw;

    ConceptSet concepts;
    concepts.plug(ConceptId{1}, Fixed64::fromFloat(0.8f));   // not {2}

    std::vector<std::unique_ptr<IBehavior>> bag;
    bag.emplace_back(std::move(mock.owned));

    AiController c(Role::Any, std::move(concepts), std::move(bag));
    const auto v = makeSelfOnlyView(SlotId{1});
    const Intent out = c.decide(v, SlotId{1});

    FH_EXPECT_EQ(raw->utility_calls(), 0);
    FH_EXPECT_EQ(raw->execute_calls(), 0);
    FH_EXPECT(out.desired_direction.x == Fixed64::zero());
}

FH_TEST(gate_closed_by_undermastery_skips_behavior)
{
    // Concept present but mastery below threshold ⇒ ConceptSet::has
    // returns false ⇒ behavior skipped.
    auto mock = makeMock(
        "mock_wants_high_mastery",
        /*required=*/{ConceptId{1}},
        /*min_mastery=*/Fixed64::fromFloat(0.9f),
        /*fixed_utility=*/Fixed64::fromFloat(0.99f),
        /*execute_intent=*/makeIntent(Fixed64::fromFloat(1.0f)));
    MockBehavior* raw = mock.raw;

    ConceptSet concepts;
    concepts.plug(ConceptId{1}, Fixed64::fromFloat(0.3f));   // below 0.9

    std::vector<std::unique_ptr<IBehavior>> bag;
    bag.emplace_back(std::move(mock.owned));

    AiController c(Role::Any, std::move(concepts), std::move(bag));
    const auto v = makeSelfOnlyView(SlotId{1});
    const Intent out = c.decide(v, SlotId{1});

    FH_EXPECT_EQ(raw->utility_calls(), 0);
    FH_EXPECT_EQ(raw->execute_calls(), 0);
    FH_EXPECT(out.desired_direction.x == Fixed64::zero());
}

FH_TEST(ties_broken_by_insertion_order)
{
    // Two behaviors, both gated open, both return utility 0.5. First
    // in the vector wins because `if (score > best_score)` is strict.
    auto first = makeMock(
        "mock_first",
        /*required=*/{ConceptId{1}},
        /*min_mastery=*/Fixed64::fromFloat(0.1f),
        /*fixed_utility=*/Fixed64::fromFloat(0.5f),
        /*execute_intent=*/makeIntent(Fixed64::fromFloat(1.0f)));
    auto second = makeMock(
        "mock_second",
        /*required=*/{ConceptId{1}},
        /*min_mastery=*/Fixed64::fromFloat(0.1f),
        /*fixed_utility=*/Fixed64::fromFloat(0.5f),
        /*execute_intent=*/makeIntent(Fixed64::fromFloat(2.0f)));
    MockBehavior* raw_first  = first.raw;
    MockBehavior* raw_second = second.raw;

    ConceptSet concepts;
    concepts.plug(ConceptId{1}, Fixed64::fromFloat(0.8f));

    std::vector<std::unique_ptr<IBehavior>> bag;
    bag.emplace_back(std::move(first.owned));
    bag.emplace_back(std::move(second.owned));

    AiController c(Role::Any, std::move(concepts), std::move(bag));
    const auto v = makeSelfOnlyView(SlotId{1});
    const Intent out = c.decide(v, SlotId{1});

    // Both utility() calls happen; only first's execute() runs.
    FH_EXPECT_EQ(raw_first->utility_calls(),  1);
    FH_EXPECT_EQ(raw_second->utility_calls(), 1);
    FH_EXPECT_EQ(raw_first->execute_calls(),  1);
    FH_EXPECT_EQ(raw_second->execute_calls(), 0);
    FH_EXPECT(out.desired_direction.x == Fixed64::fromFloat(1.0f));
}

FH_TEST(higher_utility_wins_regardless_of_insertion_order)
{
    // Sanity check: if scores are NOT tied, argmax still works. Second
    // behavior has strictly higher utility ⇒ second wins.
    auto first = makeMock(
        "mock_low",
        /*required=*/{ConceptId{1}},
        /*min_mastery=*/Fixed64::fromFloat(0.1f),
        /*fixed_utility=*/Fixed64::fromFloat(0.3f),
        /*execute_intent=*/makeIntent(Fixed64::fromFloat(1.0f)));
    auto second = makeMock(
        "mock_high",
        /*required=*/{ConceptId{1}},
        /*min_mastery=*/Fixed64::fromFloat(0.1f),
        /*fixed_utility=*/Fixed64::fromFloat(0.9f),
        /*execute_intent=*/makeIntent(Fixed64::fromFloat(2.0f)));
    MockBehavior* raw_first  = first.raw;
    MockBehavior* raw_second = second.raw;

    ConceptSet concepts;
    concepts.plug(ConceptId{1}, Fixed64::fromFloat(0.8f));

    std::vector<std::unique_ptr<IBehavior>> bag;
    bag.emplace_back(std::move(first.owned));
    bag.emplace_back(std::move(second.owned));

    AiController c(Role::Any, std::move(concepts), std::move(bag));
    const auto v = makeSelfOnlyView(SlotId{1});
    const Intent out = c.decide(v, SlotId{1});

    FH_EXPECT_EQ(raw_first->execute_calls(),  0);
    FH_EXPECT_EQ(raw_second->execute_calls(), 1);
    FH_EXPECT(out.desired_direction.x == Fixed64::fromFloat(2.0f));
}

FH_TEST(all_behaviors_abstaining_falls_through_to_idle)
{
    // Zero-utility abstention: no behavior claims the tick ⇒ idle().
    auto mock = makeMock(
        "mock_abstains",
        /*required=*/{ConceptId{1}},
        /*min_mastery=*/Fixed64::fromFloat(0.1f),
        /*fixed_utility=*/Fixed64::zero(),
        /*execute_intent=*/makeIntent(Fixed64::fromFloat(1.0f)));
    MockBehavior* raw = mock.raw;

    ConceptSet concepts;
    concepts.plug(ConceptId{1}, Fixed64::fromFloat(0.8f));

    std::vector<std::unique_ptr<IBehavior>> bag;
    bag.emplace_back(std::move(mock.owned));

    AiController c(Role::Any, std::move(concepts), std::move(bag));
    const auto v = makeSelfOnlyView(SlotId{1});
    const Intent out = c.decide(v, SlotId{1});

    // utility() runs; execute() does not (score was 0 ⇒ no champion).
    FH_EXPECT_EQ(raw->utility_calls(), 1);
    FH_EXPECT_EQ(raw->execute_calls(), 0);
    FH_EXPECT(out.desired_direction.x == Fixed64::zero());
}

FH_TEST(min_ticks_keeps_current_behavior_before_reselection)
{
    auto first = makeMock(
        "mock_current",
        /*required=*/{ConceptId{1}},
        /*min_mastery=*/Fixed64::fromFloat(0.1f),
        /*fixed_utility=*/Fixed64::fromFloat(0.6f),
        /*execute_intent=*/makeIntent(Fixed64::fromFloat(1.0f)),
        /*min_ticks=*/TickNum{10});
    auto second = makeMock(
        "mock_challenger",
        /*required=*/{ConceptId{1}},
        /*min_mastery=*/Fixed64::fromFloat(0.1f),
        /*fixed_utility=*/Fixed64::fromFloat(0.5f),
        /*execute_intent=*/makeIntent(Fixed64::fromFloat(2.0f)),
        /*min_ticks=*/TickNum{10});
    MockBehavior* raw_first  = first.raw;
    MockBehavior* raw_second = second.raw;

    ConceptSet concepts;
    concepts.plug(ConceptId{1}, Fixed64::fromFloat(0.8f));

    std::vector<std::unique_ptr<IBehavior>> bag;
    bag.emplace_back(std::move(first.owned));
    bag.emplace_back(std::move(second.owned));

    AiController c(Role::Any, std::move(concepts), std::move(bag));
    auto v = makeSelfOnlyView(SlotId{1});
    Intent out = c.decide(v, SlotId{1});
    FH_EXPECT(out.desired_direction.x == Fixed64::fromFloat(1.0f));

    raw_first->setUtility(Fixed64::fromFloat(0.4f));
    raw_second->setUtility(Fixed64::fromFloat(0.9f));
    v.tick = TickNum{5};
    out = c.decide(v, SlotId{1});

    FH_EXPECT_EQ(raw_first->execute_calls(), 2);
    FH_EXPECT_EQ(raw_second->execute_calls(), 0);
    FH_EXPECT(out.desired_direction.x == Fixed64::fromFloat(1.0f));
}

FH_TEST(switch_penalty_delays_near_equal_challenger_after_min_ticks)
{
    auto first = makeMock(
        "mock_current",
        /*required=*/{ConceptId{1}},
        /*min_mastery=*/Fixed64::fromFloat(0.1f),
        /*fixed_utility=*/Fixed64::fromFloat(0.6f),
        /*execute_intent=*/makeIntent(Fixed64::fromFloat(1.0f)),
        /*min_ticks=*/TickNum{1});
    auto second = makeMock(
        "mock_challenger",
        /*required=*/{ConceptId{1}},
        /*min_mastery=*/Fixed64::fromFloat(0.1f),
        /*fixed_utility=*/Fixed64::fromFloat(0.5f),
        /*execute_intent=*/makeIntent(Fixed64::fromFloat(2.0f)),
        /*min_ticks=*/TickNum{1});
    MockBehavior* raw_first  = first.raw;
    MockBehavior* raw_second = second.raw;

    ConceptSet concepts;
    concepts.plug(ConceptId{1}, Fixed64::fromFloat(0.8f));

    std::vector<std::unique_ptr<IBehavior>> bag;
    bag.emplace_back(std::move(first.owned));
    bag.emplace_back(std::move(second.owned));

    AiController c(Role::Any, std::move(concepts), std::move(bag));
    auto v = makeSelfOnlyView(SlotId{1});
    Intent out = c.decide(v, SlotId{1});
    FH_EXPECT(out.desired_direction.x == Fixed64::fromFloat(1.0f));

    raw_first->setUtility(Fixed64::fromFloat(0.80f));
    raw_second->setUtility(Fixed64::fromFloat(0.90f));
    v.tick = TickNum{1};
    out = c.decide(v, SlotId{1});
    FH_EXPECT(out.desired_direction.x == Fixed64::fromFloat(1.0f));

    v.tick = TickNum{6};
    out = c.decide(v, SlotId{1});
    FH_EXPECT_EQ(raw_second->execute_calls(), 1);
    FH_EXPECT(out.desired_direction.x == Fixed64::fromFloat(2.0f));
}

FH_TEST(default_behaviors_slice_33_4_roles_get_correct_bags)
{
    // Slice 33.4: defensive roles get 3 behaviors (pursue, jockey, mark),
    // attacker roles (ST9, ST10) get 1 behavior (feint_1v1),
    // and Role::Any, GK remain empty. (No Role::Forward enum yet —
    // 1v1 attacker slots use ST9; see OneVsOneAttackDefendScenario.)
    FH_EXPECT_EQ(AiController::defaultBehaviors(Role::Any).size(),  0u);
    FH_EXPECT_EQ(AiController::defaultBehaviors(Role::GK).size(),   0u);
    FH_EXPECT_EQ(AiController::defaultBehaviors(Role::LCB).size(),  3u);
    FH_EXPECT_EQ(AiController::defaultBehaviors(Role::RCB).size(),  3u);
    FH_EXPECT_EQ(AiController::defaultBehaviors(Role::CDM).size(),  3u);
    FH_EXPECT_EQ(AiController::defaultBehaviors(Role::ST9).size(),  1u);
    FH_EXPECT_EQ(AiController::defaultBehaviors(Role::ST10).size(), 1u);

    // Lock the defensive bag's identity by id string.
    const auto lcb_bag = AiController::defaultBehaviors(Role::LCB);
    FH_EXPECT_EQ(std::string(lcb_bag[0]->id()), std::string("pursue_ball_carrier"));
    FH_EXPECT_EQ(std::string(lcb_bag[1]->id()), std::string("jockey"));
    FH_EXPECT_EQ(std::string(lcb_bag[2]->id()), std::string("mark_opponent"));

    // Lock the attacking bag's identity by id string.
    const auto st9_bag = AiController::defaultBehaviors(Role::ST9);
    FH_EXPECT_EQ(std::string(st9_bag[0]->id()), std::string("feint_1v1"));

    const auto st10_bag = AiController::defaultBehaviors(Role::ST10);
    FH_EXPECT_EQ(std::string(st10_bag[0]->id()), std::string("feint_1v1"));
}

int main()
{
    if (::fh::sim::test::g_failures != 0) {
        std::fprintf(stderr, "\n%d assertion failure(s)\n",
                     ::fh::sim::test::g_failures);
        return 1;
    }
    std::fprintf(stdout, "\nall tests passed\n");
    return 0;
}
