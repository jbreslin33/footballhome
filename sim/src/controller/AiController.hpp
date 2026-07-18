// footballhome sim - AiController
//
// Utility-AI over IBehavior. Owns a bag of behaviors handed in at
// construction; `decide()` filters them by concept-gate, scores the
// survivors via `IBehavior::utility()`, picks the highest score
// (ties broken by insertion order for determinism), and dispatches
// `IBehavior::execute()` to produce the tick's Intent.
//
// When the bag is empty — the M3 opening state, and also every M0/M1/M2
// call site that constructed AiController via the pre-Slice-30.1 two-arg
// ctor — `decide()` returns idle() every tick. This preserves the
// backward-compatible M0 skeleton behavior byte-for-byte.
//
// The `defaultBehaviors(Role)` static factory is the canonical entry
// point for scenarios that want the standard behavior bag for a role.
// In Slice 30.1 (this landing) the factory returns an empty vector for
// every role — behavior implementations arrive slice-by-slice starting
// with Slice 30.2 (PursueBallCarrierBehavior for Role::Defender).
// `sim/scripts/check_behavior_registration.sh` fails CI if a concrete
// IBehavior subclass ever lands under sim/src/behavior/ without being
// registered here (or in an explicitly allowlisted scenario factory).
//
// See DESIGN.md §5.4, §5.5, §16.4, §25.2 (M3 utility-AI scaffolding),
// §25.3 Slice 30.1.

#pragma once

#include "behavior/IBehavior.hpp"
#include "common/Role.hpp"
#include "controller/IPlayerController.hpp"
#include "profile/AttributeSet.hpp"
#include "profile/ConceptSet.hpp"

#include <memory>
#include <optional>
#include <utility>
#include <vector>

namespace fh::sim::controller {

class AiController : public IPlayerController {
public:
    AiController() = default;

    // Two-arg legacy ctor — kept so every pre-Slice-30.1 call site
    // (test_registry_loader, scenario spawn paths, Match ctor unit
    // tests) compiles unchanged. Equivalent to the three-arg form
    // with an empty behaviors bag.
    AiController(Role role, profile::ConceptSet concepts) noexcept
        : AiController(role, std::move(concepts), {}) {}

    // Three-arg canonical ctor (Slice 30.1). Takes ownership of the
    // behavior bag. Insertion order in `behaviors` IS the tie-break
    // order for equal-utility picks — callers who care about the
    // resolution order must lay them out deterministically.
    AiController(Role                                              role,
                 profile::ConceptSet                               concepts,
                 std::vector<std::unique_ptr<behavior::IBehavior>> behaviors) noexcept
                : AiController(role, std::move(concepts), {}, {}, std::nullopt,
                                             std::move(behaviors)) {}

        AiController(Role                                              role,
                                 profile::ConceptSet                               concepts,
                                 profile::AttributeSet                             technical,
                                 profile::AttributeSet                             mental,
                                 std::vector<std::unique_ptr<behavior::IBehavior>> behaviors) noexcept
                : AiController(role, std::move(concepts), std::move(technical),
                                             std::move(mental), std::nullopt, std::move(behaviors)) {}

        AiController(Role                                              role,
                                 profile::ConceptSet                               concepts,
                                 profile::AttributeSet                             technical,
                                 profile::AttributeSet                             mental,
                                 std::optional<SlotId>                              mark_target,
                                 std::vector<std::unique_ptr<behavior::IBehavior>> behaviors) noexcept
                : role_(role),
                    concepts_(std::move(concepts)),
                    technical_(std::move(technical)),
                    mental_(std::move(mental)),
                    mark_target_(mark_target),
                    behaviors_(std::move(behaviors)) {}

    Role                        role() const noexcept { return role_; }
    const profile::ConceptSet&  concepts() const noexcept { return concepts_; }
    const profile::AttributeSet& technical() const noexcept { return technical_; }
    const profile::AttributeSet& mental() const noexcept { return mental_; }
    std::optional<SlotId>       markTarget() const noexcept { return mark_target_; }

    // Number of behaviors in the bag. Public for tests + scenario-spawn
    // assertions that want to sanity-check the factory wired what they
    // expected.
    std::size_t behaviorCount() const noexcept { return behaviors_.size(); }

    Intent      decide(const awareness::AwarenessView& view,
                       SlotId self) override;
    const char* kind() const override { return "ai"; }

    // Canonical behavior bag for a given Role. Slice 30.1 returns an
    // empty vector for every role — implementations land slice-by-slice
    // (30.2 pursue, 31.2 jockey+mark, 33.2 feint). Scenarios that want
    // the standard bag call this factory; scenarios with bespoke needs
    // build their own vector and pass it directly to the three-arg
    // ctor (and register that bespoke factory in
    // scripts/check_behavior_registration.sh's allowlist).
    static std::vector<std::unique_ptr<behavior::IBehavior>>
    defaultBehaviors(Role role);

private:
    Role                                              role_{Role::Any};
    profile::ConceptSet                               concepts_{};
    profile::AttributeSet                             technical_{};
    profile::AttributeSet                             mental_{};
    std::optional<SlotId>                              mark_target_{};
    std::vector<std::unique_ptr<behavior::IBehavior>> behaviors_{};
    behavior::IBehavior*                               current_behavior_{nullptr};
    TickNum                                            current_behavior_started_at_{0};
};

} // namespace fh::sim::controller
